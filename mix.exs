defmodule FaucetBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :faucet_bot,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {FaucetBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev], runtime: false},
      {:ethers, "~> 0.4.5"},
      {:ex_secp256k1, "~> 0.7.2"},
      {:hammer, "~> 6.1"},
      {:mock, "~> 0.3.0", only: :test},
      {:nostrum, "~> 0.9"}
    ]
  end
end
