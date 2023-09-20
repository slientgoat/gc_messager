defmodule GCMessager.Sup do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true

  def init(opts) do
    children = GCMessager.Messager.start_args(opts)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
