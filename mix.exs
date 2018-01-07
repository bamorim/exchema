defmodule Exchema.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exchema,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo,       "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir,    "~> 0.5", only: [:dev, :test], runtime: false},
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp package do
    [
      name: "exchema",
      description: "Exchema is a library to build schemas that can coerce and validate input",
      licenses: ["Apache 2.0"],
      maintainers: ["Bernardo Amorim"],
      links: %{"GitHub" => "https://github.com/bamorim/exchema"}
    ]
  end
end
