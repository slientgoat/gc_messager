Benchee.run(
  %{
    "deliver" => fn ->
      GCMessager.SimpleHandler.deliver(
        GCMessager.SimpleHandler.build_personal_message(%{
          cfg_id: 1,
          from: 123,
          to: System.unique_integer([:positive])
        })
        |> elem(1)
      )
    end
  },
  parallel: 1,
  time: 60
)

Benchee.run(
  %{
    "pull_global_ids" => fn ->
      GCMessager.SimpleHandler.pull_message_ids(1, 1)
    end
  },
  parallel: 1,
  time: 5
)
