defmodule GCMessager.SimpleHandler do
  use GCMessager
  require Logger

  @impl true
  def dump_messages(messages) when is_list(messages) do
    messages = Enum.map(messages, &Map.put(&1, :id, System.unique_integer([:positive])))
    Process.sleep(50)
    {:ok, messages}
  end

  @impl true
  def on_callback_fail(_fun, _arg, _error) do
    # Logger.error(fun: fun, arg: arg, error: error)
    :ok
  end
end
