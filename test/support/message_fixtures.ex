defmodule GCMessager.MessageFixtures do
  alias GCMessager.Message
  alias GCMessager.Messager
  import Ex2ms

  def make_assigns(n) do
    Enum.to_list(1..n) |> Enum.map(&{"k#{&1}", "v#{&1}"}) |> Enum.into(%{})
  end

  def valid_personal_message(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        cfg_id: 1,
        id: System.unique_integer([:positive]),
        from: System.unique_integer([:positive]),
        to: System.unique_integer([:positive])
      })
      |> Message.build_personal_message()

    message
  end

  def create_messager(_args \\ []) do
    opts = [id: 1, handler: SimpleHandler]
    {:ok, state, {:continue, continue}} = Messager.init(opts)
    {:noreply, state} = Messager.handle_continue(continue, state)
    %{state: state}
  end

  def make_range_ids_match_spec(id_from, id_to) do
    fun do
      {_, key, _, _, _}
      when key >= ^id_from and key <= ^id_to ->
        key
    end
  end
end
