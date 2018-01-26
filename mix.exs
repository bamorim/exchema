defmodule Exchema.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exchema,
      version: "0.2.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      groups_for_modules: groups_for_modules(),
      extras: [
        "README.md"
      ]
    ]
  end

  defp deps do
    [
      {:credo,       "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir,    "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
    ]
  end

  defp package do
    [
      name: "exchema",
      description: "Exchema is a library to build schemas that can coerce and validate input",
      licenses: ["Apache 2.0"],
      maintainers: ["Bernardo Amorim"],
      links: %{"GitHub" => "https://github.com/bamorim/exchema"}
    ]
  end

  defp groups_for_modules do
    [
      "Types": ~r/^Exchema\.Types/
    ]
  end
end
