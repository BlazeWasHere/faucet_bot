defmodule FaucetSenderTest do
  use ExUnit.Case, async: false
  doctest FaucetBot.Sender

  import Mock

  alias FaucetBot.Sender

  @to "0x3f88459d0ea72268453df224fFaeB9997b761518"

  test "send_gas/2 error on invalid chain" do
    assert {:error, :invalid_chain} = Sender.send_gas("xxx", "abc")
  end

  test_with_mock(
    "send_gas/2 sends tx to rpc",
    Ethereumex.HttpClient,
    [:passthrough],
    eth_send_raw_transaction: fn _transaction, _opts ->
      {:ok, "0x"}
    end
  ) do
    assert {:ok, "0x"} =
             Sender.send_gas("sepolia", @to)
  end

  test_with_mock(
    "send_gas/2 sends correct data",
    Ethereumex.HttpClient,
    [:passthrough],
    eth_send_raw_transaction: fn transaction, _opts ->
      value =
        Application.fetch_env!(
          :faucet_bot,
          :drip
        ).bsc
        |> Ethers.Utils.to_wei()
        |> :binary.encode_unsigned()

      <<2, raw_transaction::binary>> = Ethers.Utils.hex_decode!(transaction)
      gas = :binary.encode_unsigned(50_000)
      to = Ethers.Utils.hex_decode!(@to)

      assert [_, _, _, _, ^gas, ^to, ^value, "https://replete.fi", _, _, _, _] =
               ExRLP.decode(raw_transaction)

      {:ok, "0x"}
    end
  ) do
    assert {:ok, "0x"} =
             Sender.send_gas("bsc", @to)
  end

  test_with_mock(
    "send_gas/2 works on l2",
    Ethereumex.HttpClient,
    [:passthrough],
    eth_send_raw_transaction: fn _transaction, _opts ->
      {:ok, "0x"}
    end
  ) do
    assert {:ok, "0x"} =
             Sender.send_gas("arbitrum sepolia", "0x3f88459d0ea72268453df224fFaeB9997b761518")
  end
end
