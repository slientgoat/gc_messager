defmodule GCMessager.MessageTest do
  alias GCMessager.Message.Type
  alias GCMessager.Message
  use GCMessager.DataCase
  import GCMessager.MessageFixtures

  describe "validate_assigns/1" do
    test "invalid subset " do
      {:error, changeset} =
        Message.validate(&Message.validate_assigns/1, %{assigns: %{"k1" => 1}})

      expert_tips = "is invalid"
      assert %{assigns: [expert_tips]} == errors_on(changeset)
    end

    test "length over limit " do
      maximum = Message.max_assigns_length()
      invalid_assigns = make_assigns(maximum * 2)

      {:error, changeset} =
        Message.validate(&Message.validate_assigns/1, %{assigns: invalid_assigns})

      expert_tips = "should have at most #{maximum} item(s)"
      assert %{assigns: [expert_tips]} == errors_on(changeset)
    end
  end

  describe "build_personal_message/1" do
    test "requires cfg_id,from,to" do
      assert {:error, changeset} = Message.build_personal_message(%{})

      assert %{
               cfg_id: ["can't be blank"],
               from: ["can't be blank"],
               to: ["can't be blank"]
             } ==
               errors_on(changeset)
    end

    test ":type will not be setup" do
      assert {:ok,
              %Message{
                type: Type.PersonalMessage,
                from: 123,
                to: 1,
                cfg_id: 1,
                assigns: %{"k1" => "v1"},
                send_at: 1,
                ttl: 1
              }} ==
               Message.build_personal_message(%{
                 type: "type",
                 from: 123,
                 to: 1,
                 cfg_id: 1,
                 assigns: %{"k1" => "v1"},
                 send_at: 1,
                 ttl: 1
               })
    end

    test "return message with the least valid attrs" do
      type = Type.PersonalMessage

      assert {:ok, %Message{cfg_id: 1, to: 1, type: ^type, from: 123} = ret} =
               Message.build_personal_message(%{cfg_id: 1, type: type, from: 123, to: 1})

      assert ret.send_at > 0
      assert ret.ttl == Message.ttl()
    end

    test "return message after set ttl" do
      type = Type.PersonalMessage
      Message.set_ttl(199)

      assert {:ok, %Message{cfg_id: 1, to: 1, type: ^type, from: 123} = ret} =
               Message.build_personal_message(%{cfg_id: 1, type: type, from: 123, to: 1})

      assert 199 == ret.ttl
    end
  end

  test "set_ttl/1" do
    Message.set_ttl(1)
    assert 1 == Message.ttl()
  end
end
