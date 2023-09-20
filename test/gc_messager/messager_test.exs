defmodule GCMessager.MessagerTest do
  use GCMessager.DataCase
  import GCMessager.MessageFixtures
  alias GCMessager.Messager

  describe "deliver/1" do
    setup [:create_messager]

    test "submit message with invalid message", %{state: state} do
      {:noreply, state} = Messager.handle_cast({:deliver, "invalid message"}, state)
      assert [] == state.prepare_messages
    end

    test "submit message with valid message", %{state: state} do
      message = valid_personal_message()
      {:noreply, state} = Messager.handle_cast({:deliver, message}, state)
      assert [message] == state.prepare_messages
    end
  end

  describe "handle_prepare_messages/1" do
    setup [:create_messager]

    test "will do nothing if prepare_messages is empty", %{state: state} do
      loop_interval = 1
      state = put_in(state.loop_interval, loop_interval)
      assert 0 == length(state.prepare_messages)
      state = Messager.handle_prepare_messages(state)
      assert 0 == length(state.prepare_messages)
    end

    test "will handle [#{Messager.batch_num()}] items if prepare_messages has 1000 message items",
         %{state: state} do
      total_num = 1000
      batch_num = Messager.batch_num()

      state =
        Enum.to_list(1..total_num)
        |> Enum.reduce(state, fn _, acc ->
          {:noreply, acc} = Messager.handle_cast({:deliver, valid_personal_message()}, acc)

          acc
        end)

      assert batch_num <= total_num
      assert total_num == length(state.prepare_messages)
      state = Messager.handle_prepare_messages(state)
      assert batch_num == total_num - length(state.prepare_messages)
    end
  end

  describe "exec_callback/3" do
    setup [:create_messager]

    test "", %{state: state} do
      for fun <- [
            :dump_messages,
            :on_handle_message_success
          ] do
        assert {:error, _} = GCMessager.Messager.exec_callback(state.handler, fun, "invalid arg")
      end
    end
  end

  test "cache_messages/1 with 1m num in 1 second" do
    ids = Enum.to_list(1..100_000)

    ids
    |> Enum.map(&valid_personal_message(%{id: &1}))
    |> GCMessager.Messager.cache_messages()

    assert GCMessager.MessageCache.count_all(make_range_ids_match_spec(1, 100_000)) == 200_000
  end
end
