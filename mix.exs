defmodule BoardGameGeekClient.Mixfile do
  use Mix.Project

  def project do
    [app: :boardgamegeek_client,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     source_url: "https://github.com/ElixirCLE/boardgamegeek_client"
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpotion]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:exml, "~> 0.1"},
      {:httpotion, "~> 3.0.0"},
      {:poison, "~> 2.0"},
      {:floki, "~> 0.17.0"},
      {:html_sanitize_ex, "~> 1.0"}
    ]
  end

  defp package do
    [
      name: :boardgamegeek_client,
      maintainers: ["Chris Rees"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ElixirCLE/boardgamegeek_client"}
    ]
  end
end
