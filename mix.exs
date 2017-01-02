defmodule Exbuilder.Mixfile do
  use Mix.Project

  def project do
    [app: :exbuilder,
     version: "0.1.3",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Macros to support Ruby-like jbuilder templates to generate JSON",
     name: "ExBuilder",
     source_url: "https://github.com/aportnov/exbuilder.git",
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :xmerl]]
  end

  def package do
  	[
		maintainers: ["Alexander Portnov"],
		licenses: ["MIT"],
		links: %{"GitHub" => "https://github.com/aportnov/exbuilder.git"}
	]
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
		{:poison, "~> 3.0"},
		{:inflex, "~> 1.7"},
		{:credo, "~> 0.5", only: [:dev, :test]},
		{:dialyxir, "~> 0.4", only: [:dev]},
		{:ex_doc, "~> 0.14", only: :dev}
	]
  end
end
