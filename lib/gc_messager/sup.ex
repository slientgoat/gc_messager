defmodule GCMessager.Sup do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true

  def init(opts) do
    init_hook(opts)
    children = GCMessager.Messager.start_args(opts)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp init_hook(opts) do
    handler = opts[:handler] || "raise opts's handler need be set"
    set_message_ttl(handler)
  end

  defp set_message_ttl(handler) do
    GCMessager.Message.set_ttl(handler.ttl())
  end
end
