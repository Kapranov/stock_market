defmodule Converter.SendProducerConsumer do
  @moduledoc false

  use GenStage

  use UmbrellaStage,
    type: :producer_consumer,
    producers: [
      {MyUkApp.SendProducer, []}
    ]

  @name __MODULE__
  @gbp_to_eur 1.10
  @gbp_to_usd 1.30

  def start_link(_opts), do: GenStage.start_link(@name, :ok, name: @name)

  def init(:ok) do
    umbrella_sync_subscribe()
    {:producer_consumer, :nothing, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_events(events, _from, state) do
    converted = convert_to_eur_usd(events, [])
    {:noreply, converted, state}
  end

  defp convert_to_eur_usd([], converted) do
    converted
  end

  defp convert_to_eur_usd([%{price_per_share: pps} = event | events], converted) do
    eur = %{
      event |
      price_per_share: round(pps * @gbp_to_eur),
      currency: :eur
    }

    usd = %{
      event |
      price_per_share: round(pps * @gbp_to_usd),
      currency: :usd
    }

    convert_to_eur_usd(events, [eur, usd | converted])
  end
end
