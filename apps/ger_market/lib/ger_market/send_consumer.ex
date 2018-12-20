defmodule GerMarket.SendConsumer do
  @moduledoc false

  use GenStage

  use UmbrellaStage,
    type: :consumer,
    producers: [{
        Converter.SendProducerConsumer,
        [selector: fn(%{currency: currency}) -> currency == :eur end]
      }]

  @name __MODULE__

  def start_link(_opts), do: GenStage.start_link(@name, :ok, name: @name)

  def init(:ok) do
    umbrella_sync_subscribe()
    {:consumer, :nothing}
  end

  def handle_events(events, _from, state) do
    # Enum.each(events, &Shared.Interface.process_info(GerMarketInterface, &1))
    Enum.each(events, &(IO.inspect(&1, label: "[GER interface] ")))
    {:noreply, [], state}
  end
end
