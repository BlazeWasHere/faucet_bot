defmodule FaucetBot.Sender do
  @moduledoc """
  Sends gas to users on chain
  """

  alias Ethers.Signer

  @magic "https://replete.fi"
  @chains Application.compile_env!(:faucet_bot, :drip)
          |> Map.keys()
          |> Enum.map(&(to_string(&1) |> String.replace("_", " ")))

  @spec send_gas(String.t(), Ethers.Types.t_address()) :: {:ok, String.t()} | {:error, term()}
  def send_gas(chain, to_address) when chain in @chains do
    chain =
      chain
      |> String.replace(" ", "_")
      |> String.to_existing_atom()

    {:ok, [from]} =
      Application.fetch_env!(:ethers, :default_signer_opts)
      |> Signer.Local.accounts()

    Ethers.send(
      %{
        data: Ethers.Utils.hex_encode(@magic),
        to: to_address
      },
      value: Ethers.Utils.to_wei(get_drip_value!(chain)),
      gas: 50_000,
      from: from,
      rpc_opts: [
        url: get_rpc_url!(chain)
      ]
    )
  end

  def send_gas(_chain, _to_address) do
    {:error, :invalid_chain}
  end

  @spec get_rpc_url!(atom()) :: String.t()
  defp get_rpc_url!(chain) do
    Application.fetch_env!(
      :faucet_bot,
      :rpc
    )[chain]
  end

  @spec get_drip_value!(atom()) :: float()
  defp get_drip_value!(chain) do
    Application.fetch_env!(
      :faucet_bot,
      :drip
    )[chain]
  end
end
