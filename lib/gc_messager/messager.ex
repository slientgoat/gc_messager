defmodule GCMessager.Messager do
  use GenServer
  alias GCMessager.Messager, as: M
  alias GCMessager.Message

  import ShorterMaps

  defstruct id: nil, loop_interval: nil, prepare_messages: [], handler: nil

  @worker_num System.schedulers_online()
  @loop_intervals Enum.to_list(0..@worker_num) |> Enum.map(&(200 + &1 * 10)) |> List.to_tuple()
  @batch_num 1000

  def batch_num, do: @batch_num

  @spec deliver(%Message{}) :: :ok
  def deliver(message) do
    cast(message.send_at, {:deliver, message})
  end

  def call(key, event) do
    choose_worker(key) |> GenServer.call(event)
  end

  def cast(key, event) do
    choose_worker(key) |> GenServer.cast(event)
  end

  def choose_worker(key) do
    # (:erlang.phash2("#{key}", @worker_num) + 1) |> via()
    key
    |> :erlang.phash2()
    |> :jchash.compute(@worker_num - 1)
    |> via()
  end

  def start_args(opts) do
    for id <- 1..@worker_num do
      {__MODULE__, [{:id, id} | opts]}
    end
  end

  def child_spec(opts) do
    id = opts[:id]

    %{
      id: via(id),
      start: {__MODULE__, :start_link, [opts]},
      shutdown: 5_000,
      restart: :permanent,
      type: :worker
    }
  end

  def start_link(opts) do
    id = opts[:id]

    GenServer.start_link(__MODULE__, opts, name: via(id))
  end

  def via(id) do
    Module.concat(__MODULE__, "#{id}")
  end

  def init(opts) do
    id = opts[:id]
    handler = opts[:handler]

    loop_interval = elem(@loop_intervals, id)
    {:ok, %M{id: id, loop_interval: loop_interval, handler: handler}, {:continue, :initialize}}
  end

  def handle_continue(:initialize, ~M{%M id,handler,loop_interval} = state) do
    if id == 1 do
      load_messages_to_cache(handler)
    end

    loop_handle_prepare_messages(loop_interval)
    {:noreply, state}
  end

  defp load_messages_to_cache(handler) do
    load_messages(handler)
    |> cache_messages()
  end

  def handle_cast({:deliver, message}, ~M{%M prepare_messages} = state) do
    with true <- is_struct(message, Message) do
      {:noreply, %{state | prepare_messages: [message | prepare_messages]}}
    else
      _ ->
        {:noreply, state}
    end
  end

  def handle_cast(_event, state) do
    {:noreply, state}
  end

  def handle_info(:loop_handle_prepare_messages, ~M{%M loop_interval} = state) do
    state = handle_prepare_messages(state)
    loop_handle_prepare_messages(loop_interval)
    {:noreply, state}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end

  def handle_prepare_messages(~M{%M handler,prepare_messages} = state) do
    with true <- prepare_messages != [],
         {prepare_messages, tails} <- Enum.split(prepare_messages, -@batch_num),
         {:ok, messages} <- dump_messages(handler, tails),
         :ok <- cache_messages(messages) do
      if function_exported?(handler, :on_handle_message_success, 1) do
        exec_callback(handler, :on_handle_message_success, messages)
      end

      ~M{state|prepare_messages}
    else
      _e ->
        state
    end
  end

  defp dump_messages(handler, tails) do
    exec_callback(handler, :dump_messages, tails)
  end

  defp load_messages(handler) do
    exec_callback(handler, :load_messages)
  end

  @spec cache_messages(any) :: :ok
  def cache_messages(messages) do
    Enum.map(messages, &{&1.id, &1})
    |> GCMessager.MessageCache.put_all()
  end

  defp loop_handle_prepare_messages(loop_interval) do
    Process.send_after(self(), :loop_handle_prepare_messages, loop_interval)
  end

  def exec_callback(handler, fun) do
    exec_callback(handler, fun, nil)
  end

  def exec_callback(handler, fun, arg) do
    try do
      if arg != nil do
        apply(handler, fun, [arg])
      else
        apply(handler, fun, [])
      end
    rescue
      error ->
        handler.on_callback_fail(fun, arg, error)
        {:error, error}
    catch
      error ->
        handler.on_callback_fail(fun, arg, error)
        {:error, error}
    end
  end
end
