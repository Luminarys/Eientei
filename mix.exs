defmodule Eientei.Mixfile do
  use Mix.Project

  def project do
    [app: :eientei,
     version: "0.3.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Eientei, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :ex_rated,
                    :phoenix_ecto, :postgrex, :httpoison, :con_cache]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.0.2"},
     {:phoenix_ecto, "~> 1.1"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.1"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:mimerl, "~> 1.0"},
     {:httpoison, "~> 0.7.4"},
     {:pipe, "~> 0.0.2"},
     {:con_cache, "~> 0.9.0"},
     {:ex_rated, "~> 0.0.6"},
     {:cowboy, "~> 1.0"}]
  end
end
