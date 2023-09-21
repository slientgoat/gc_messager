defmodule GCMessager do
  @moduledoc """
  Documentation for `GCMessager`.
  """
  import Ex2ms

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour GCMessager.Behaviour
      alias GCMessager.Message
      alias GCMessager.Messager

      @opts opts

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      def start_link(opts \\ []) do
        GCMessager.Supervisor.start_link(__MODULE__, opts)
      end

      def load_messages() do
        []
      end

      defdelegate build_personal_message(attrs), to: Message
      defdelegate deliver(message), to: Messager
      defdelegate pull_message_ids(last_message_id, to), to: GCMessager
      defdelegate get_message(message_id), to: GCMessager.MessageCache, as: :get
      defdelegate get_messages(message_ids), to: GCMessager.MessageCache, as: :get_all
      defdelegate cache_messages(messages), to: GCMessager.MessageCache, as: :put_all
      defoverridable load_messages: 0
    end
  end

  def pull_message_ids(last_message_id, to) when is_integer(to) do
    make_message_ids_match_spec(last_message_id, to)
    |> GCMessager.MessageCache.all()
    |> Enum.uniq()
  end

  defp make_message_ids_match_spec(nil, target) do
    fun do
      {_, _key, %{to: to, id: message_id}, _, _} when to == ^target ->
        message_id
    end
  end

  defp make_message_ids_match_spec(last_message_id, target) do
    fun do
      {_, _, %{to: to, id: message_id}, _, _}
      when to == ^target and message_id > ^last_message_id ->
        message_id
    end
  end
end
