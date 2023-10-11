defmodule GCMessager.MixProject do
  use Mix.Project

  def project do
    [
      app: :gc_messager,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  if Mix.env() == :test do
    def application do
      [
        mod: {BenchTestApplication, []},
        extra_applications: [:logger]
      ]
    end
  else
    def application do
      []
    end
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "benchmarks"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.10.0"},
      {:enum_type, "~> 1.1.0"},
      {:shorter_maps, git: "https://github.com/boyzwj/shorter_maps.git", tag: "master"},
      {:mix_test_watch, "~> 1.1", only: :dev, runtime: false},
      {:faker, "~> 0.17.0", only: :test},
      {:oban, "~> 2.15"},
      {:nebulex, "~> 2.5"},
      {:shards, "~> 1.0"},
      {:decorator, "~> 1.4"},
      {:telemetry, "~> 1.0"},
      {:benchee, "~> 1.1", only: [:dev, :test]},
      {:jchash, "~> 0.1.4"},
      {:ex2ms, "~> 1.6"},
      {:local_cluster, "~> 1.2", only: [:test]}
    ]
  end
end
