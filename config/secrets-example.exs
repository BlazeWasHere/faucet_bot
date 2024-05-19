import Config

config :nostrum,
  token: ""

config :ethers,
  default_signer_opts: [private_key: ""]

config :faucet_bot,
  rpc: %{
    sepolia: "https://eth-sepolia.public.blastapi.io",
    arbitrum_sepolia: "https://sepolia-rollup.arbitrum.io/rpc",
    optimism_sepolia: "https://optimism-sepolia.blockpi.network/v1/rpc/public",
    bsc: "https://bsc-testnet-rpc.publicnode.com"
  }
