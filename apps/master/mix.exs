defmodule Master.MixProject do
  use Mix.Project

  def project do
    [
      app: :master,
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
      mod: {Master.Application, []}
    ]
  end

  defp deps do
    [
      {:ger_market, in_umbrella: true},
      {:usa_market, in_umbrella: true},
      {:converter, in_umbrella: true},
      {:my_uk_app, in_umbrella: true}
    ]
  end
end
