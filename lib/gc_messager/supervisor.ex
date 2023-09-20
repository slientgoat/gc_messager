defmodule GCMessager.Supervisor do
  use Supervisor

  def start_link(handler, opts) do
    Supervisor.start_link(__MODULE__, handler, [{:name, __MODULE__} | opts])
  end

  @impl true
  def init(handler) do
    children = [
      {GCMessager.MessageCache, []},
      {GCMessager.Sup, [handler: handler]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
