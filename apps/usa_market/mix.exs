defmodule UsaMarket.MixProject do
  use Mix.Project

  def project do
    [
      app: :usa_market,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {UsaMarket.Application, []}
    ]
  end

  defp deps do
    [
      {:shared, in_umbrella: true}
    ]
  end
end
