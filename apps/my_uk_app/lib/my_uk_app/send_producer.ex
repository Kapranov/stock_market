defmodule MyUkApp.SendProducer do
  @moduledoc false

  use GenStage

  use UmbrellaStage,
    type: :producer

  @name __MODULE__

  def start_link(_opts), do: GenStage.start_link(@name, :ok, name: @name)

  def send_info(event), do: GenStage.call(@name, {:send_info, event})

  def init(:ok) do
    umbrella_sync_subscribe()
    {:producer, :nothing}
  end

  def handle_call({:send_info, event}, _from, state) do
    {:reply, :ok, [event], state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
