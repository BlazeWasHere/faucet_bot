defmodule FaucetBot.Consumer do
  @moduledoc """
  Consumes events from the Discord API connection
  """

  use Nostrum.Consumer

  alias Nostrum.Constants.InteractionCallbackType
  alias Nostrum.Struct.Interaction
  alias Nostrum.Api
  alias FaucetBot.Interactions
  alias FaucetBot.Sender

  require Logger

  @avax_faucet "https://core.app/tools/testnet-faucet"
  @rate_limit_ms Application.compile_env!(:faucet_bot, :rate_limit_ms)
  # https://discord.com/developers/docs/interactions/receiving-and-responding#create-followup-message
  @ephemeral_flag 64
  @chains Application.compile_env!(:faucet_bot, :drip)
          |> Map.keys()
          |> Enum.map(&(to_string(&1) |> String.replace("_", " ")))

  def handle_event({:READY, %{guilds: guilds} = _event, _ws_state}) do
    guilds
    |> Enum.map(fn guild -> guild.id end)
    |> Enum.each(fn guild_id ->
      Interactions.get_commands()
      |> Enum.each(&Api.create_guild_application_command(guild_id, &1))
    end)
  end

  def handle_event(
        {:INTERACTION_CREATE, %Interaction{data: %{name: "faucet"}} = interaction, _ws_state}
      ) do
    handle_faucet_request(interaction)
  end

  defp handle_faucet_request(
         %Interaction{
           data: %{options: [%{value: address}, %{value: chain}]},
           member: %{user_id: user_id}
         } = interaction
       )
       when chain in @chains do
    with true <- Ethers.Types.matches_type?(address, :address),
         {:allow, 1} <- Hammer.check_rate("#{chain}:#{user_id}", @rate_limit_ms, 1),
         {:ok, tx_hash} <- Sender.send_gas(chain, address) do
      reply_drip_success(interaction, chain, tx_hash)
    else
      false ->
        Api.create_interaction_response(
          interaction,
          create_command_response("invalid address")
        )

      {:deny, _limit} ->
        message =
          case Hammer.inspect_bucket("#{chain}:#{interaction.id}", @rate_limit_ms, 1) do
            {:ok, {_count, _count_remaining, ms_to_next_bucket, _created_at, _updated_at}} ->
              try_after = (:os.system_time(:millisecond) + ms_to_next_bucket) / 1000
              "please try again after <t:#{inspect(trunc(try_after))}>"

            {:error, error} ->
              Logger.error("error reporting rate limit, details: #{inspect(error)}")
              "please try again later"
          end

        Api.create_interaction_response(
          interaction,
          create_command_response(message)
        )

      {:error, error} ->
        reply_drip_error(interaction, error)
    end
  end

  defp handle_faucet_request(%Interaction{data: %{options: [_, %{value: chain}]}} = interaction)
       when chain == "avax" do
    Api.create_interaction_response(
      interaction,
      create_command_response(
        "Use the [avax faucet](#{@avax_faucet}) with coupon code `replete-finance`"
      )
    )
  end

  defp handle_faucet_request(%Interaction{data: %{options: [_, %{value: chain}]}} = interaction) do
    Api.create_interaction_response(
      interaction,
      create_command_response("#{chain} is unsupported, pick one from: #{inspect(@chains)}")
    )
  end

  defp reply_drip_success(interaction, chain, tx_hash) do
    Api.create_interaction_response(
      interaction,
      create_command_response("#{get_chain_explorer!(chain)}/tx/#{tx_hash}")
    )
  end

  defp reply_drip_error(interaction, error) do
    Logger.error(
      "error while sending gas for #{inspect(interaction)}, details: #{inspect(error)}"
    )

    Api.create_interaction_response(
      interaction,
      create_command_response("failed to send gas")
    )
  end

  @spec get_chain_explorer!(String.t()) :: String.t()
  defp get_chain_explorer!(chain) do
    chain =
      chain
      |> String.replace(" ", "_")
      |> String.to_existing_atom()

    Application.fetch_env!(
      :faucet_bot,
      :explorer
    )[chain]
  end

  defp create_command_response(content) do
    %{
      type: InteractionCallbackType.channel_message_with_source(),
      data: %{
        content: content,
        flags: @ephemeral_flag
      }
    }
  end
end
