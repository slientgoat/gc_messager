import Config

config :gc_messager, GCMessager.MessageCache,
  model: :inclusive,
  stats: true,
  levels: [
    # Default auto-generated L1 cache (local)
    {
      GCMessager.MessageCache.L1,
      # GC interval for pushing new generation: 24 hrs
      # Max 1 million entries in cache
      gc_interval: :timer.hours(24), max_size: 1_000_000
    },
    # Default auto-generated L2 cache (partitioned cache)
    {
      GCMessager.MessageCache.L2,
      primary: [
        # GC interval for pushing new generation: 48 hrs
        gc_interval: :timer.hours(48),
        # Max 1 million entries in cache
        max_size: 1_000_000
      ]
    }
  ]
