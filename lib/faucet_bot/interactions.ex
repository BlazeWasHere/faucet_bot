defmodule FaucetBot.Interactions do
  @moduledoc """
  Register slash commands and handles interactions
  """

  alias Nostrum.Constants.ApplicationCommandOptionType
  alias Nostrum.Struct.ApplicationCommand

  # Fetch keys from config and then nice-ify.
  @chains Application.compile_env!(:faucet_bot, :drip)
          |> Map.keys()
          |> Enum.map(&(to_string(&1) |> String.replace("_", " ")))

  @spec get_commands() :: [ApplicationCommand.application_command_map()]
  def get_commands do
    [
      %{
        name: "faucet",
        description: "request native gas on a chain",
        type: ApplicationCommandOptionType.sub_command(),
        options: [
          %{
            type: ApplicationCommandOptionType.string(),
            name: "address",
            description: "receiver wallet address",
            required: true
          },
          %{
            # ApplicationCommandType::STRING
            type: ApplicationCommandOptionType.string(),
            name: "chain",
            description: "chain gas to receive",
            required: true,
            choices:
              Enum.map(
                @chains ++ ["avax"],
                &%{name: &1, value: &1}
              )
          }
        ]
      }
    ]
  end
end
