defmodule UsaMarket.SendConsumer do
  @moduledoc false

  use GenStage

  use UmbrellaStage,
    type: :consumer,
    producers: [{
        Converter.SendProducerConsumer,
        [selector: fn(%{currency: currency}) -> currency == :usd end]
      }]

  @name __MODULE__

  def start_link(_opts), do: GenStage.start_link(@name, :ok, name: @name)

  def init(:ok) do
    umbrella_sync_subscribe()
    {:consumer, :nothing}
  end

  def handle_events(events, _from, state) do
    Enum.each(events, &Shared.Interface.process_info(UsaMarketInterface, &1))
    # For `Shared.DataGenerator.generate`
    # credo:disable-for-next-line
    # Enum.each(events, &(IO.inspect(&1, label: "[US interface] ")))
    {:noreply, [], state}
  end
end
