defmodule Blockchain.MixProject do
  use Mix.Project

  def project do
    [
      app: :blockchain,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env)
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/helpers.exs"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Blockchain.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      { :elixir_uuid, "~> 1.2" },
      { :mix_test_watch, "~> 0.8", only: :dev, runtime: false },
      { :coverex, "~> 1.4.10", only: :test },
      { :excoveralls, "~> 0.10", only: :test },
      { :timex, "~> 3.1" }
    ]
  end
end
