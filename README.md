# Faucet Bot

Discord bot to allow users to request testnet gas on supported networks.

Uses [Slash Commands](https://discord.com/blog/slash-commands-are-here) and [Ephemeral Messages](https://support.discord.com/hc/en-us/articles/1500000580222-Ephemeral-Messages-FAQ) to keep users wallet addresses private.

## Slash Commands

- `/faucet <address> <chain>`
  - Requests X native gas on `<chain>`

## Installation

```sh
$ mix deps.get
```

## Configuration

Copy the example secrets file and edit the secrets accordingly

```sh
$ cp config/secrets-example.exs config/secrets.exs
```

<details>
  <summary>Discord</summary>

Discord bot token can be grabbed from [Discord Developer Portal](https://discord.com/developers/applications) then `Your application > Bot > Click to reveal token`

```elixir
config :nostrum,
  token: "..."
```

</details>

<details>
  <summary>Ethers</summary>

The bot uses [elixer_ethers](https://github.com/ExWeb3/elixir_ethers) to handle EVM interactions. It uses a private key to sign messages locally, which can be set in `config/secrets.exs`

```elixir
config :ethers,
  default_signer_opts: [
    private_key: "..."
  ]
```

You can configure how much native gas will be sent with each faucet request in `config/config.exs`

```elixir
config :faucet_bot,
  drip: %{
    sepolia: 0.1, # 0.1 ETH
    arbitrum_sepolia: 0.1, # 0.1 ETH
    optimism_sepolia: 0.1, # 0.1 ETH
    bsc: 0.5 # 0.5 BNB
  }
```

Each supported network will require a JSON-RPC API to use which can be set in `config/secrets.exs`

```elixir
config :faucet_bot,
  rpc: %{
    sepolia: "https://...",
    arbitrum_sepolia: "https://...",
    optimism_sepolia: "https://...",
    bsc: "https://..."
  }
```

Additionally, each supported network will require an explorer URL to use which can be configured in `config/config.exs`

```elixir
explorer: %{
    sepolia: "https://sepolia.etherscan.io",
    arbitrum_sepolia: "https://sepolia.arbiscan.io",
    optimism_sepolia: "https://sepolia-optimism.etherscan.io",
    bsc: "https://testnet.bscscan.com"
  }
```

</details>

<details>
  <summary>Rate Limit</summary>

It is important to rate limit the faucet to prevent testnet gas being depleted. By default it is set to 1 day and can be changed in `config/config.exs`

```elixir
config :faucet_bot,
  rate_limit_ms: 60_000 * 60 * 24
```

</details>

## Running

```sh
$ mix run --no-halt
```

## License

[BSL-1.0](https://www.boost.org/users/license.html)
