defmodule Converter.ReceiveProducerConsumer do
  @moduledoc false

  use GenStage

  use UmbrellaStage,
    type: :producer_consumer,
    producers: [
      {GerMarket.ReceiveProducer, []},
      {UsaMarket.ReceiveProducer, []}
    ]

  @name __MODULE__
  @eur_to_gbp 0.90
  @usd_to_gbp 0.75

  def start_link(_opts), do: GenStage.start_link(@name, :ok, name: @name)

  def init(:ok) do
    umbrella_sync_subscribe()
    {:producer_consumer, :nothing}
  end

  def handle_events(events, _from, state) do
    converted = Enum.map(events, &convert_to_gbp/1)
    {:noreply, converted, state}
  end

  defp convert_to_gbp(
    %{price_per_share: pps, currency: :eur} = event
  ) do
    %{
      event |
      price_per_share: round(pps * @eur_to_gbp),
      currency: :gbp
    }
  end

  defp convert_to_gbp(
    %{price_per_share: pps, currency: :usd} = event
  ) do
    %{
      event |
      price_per_share: round(pps * @usd_to_gbp),
      currency: :gbp
    }
  end
end
