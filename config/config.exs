import Config

config :ethers,
  # Don't worry this is testnet, not production :)
  default_signer: Ethers.Signer.Local

config :hammer,
  backend: {
    # Change backend if load balancing the application.
    Hammer.Backend.ETS,
    [expiry_ms: 60000 * 60 * 24, cleanup_interval_ms: 60_000 * 10]
  }

config :faucet_bot,
  rate_limit_ms: 60_000 * 60 * 24,
  drip: %{
    sepolia: 0.1,
    arbitrum_sepolia: 0.1,
    optimism_sepolia: 0.1,
    bsc: 0.5
  },
  explorer: %{
    sepolia: "https://sepolia.etherscan.io",
    arbitrum_sepolia: "https://sepolia.arbiscan.io",
    optimism_sepolia: "https://sepolia-optimism.etherscan.io",
    bsc: "https://testnet.bscscan.com"
  }

import_config("secrets.exs")
