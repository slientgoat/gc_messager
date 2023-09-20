defmodule GCMessager.Behaviour do
  @type callback_fun ::
          :dump_messages
          | :load_messages
          | :on_handle_message_success
  @callback dump_messages(list(GCMessager.Message.t())) ::
              {:error, Ecto.Changeset.t()} | {:ok, list(GCMessager.Message.t())}

  @callback load_messages() :: list(GCMessager.Message.t())

  @callback on_handle_message_success([GCMessager.Message.t()]) :: :ok
  @callback on_callback_fail(fun :: callback_fun(), arg :: any(), reason :: any()) :: :ok

  @optional_callbacks [
    on_handle_message_success: 1
  ]
end
