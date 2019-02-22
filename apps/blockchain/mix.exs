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
      deps: deps()
    ]
  end

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
