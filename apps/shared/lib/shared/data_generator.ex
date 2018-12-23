defmodule Shared.DataGenerator do
  @moduledoc false

  @step 1000..3000
  @steps 1..10

  def generate do
    for _x <- (@steps) do
      [{"US", :usd}, {"GER", :eur}, {"UK", :gbp}]
      |> Enum.random()
      |> generate()
    end
  end

  defp generate({"US", _} = data) do
    event = events(data)
    random_sleep()
    # credo:disable-for-next-line
    IO.inspect(event, label: "[US interface] ")
    UsaMarket.ReceiveProducer.receive_info(event)
  end

  defp generate({"GER", _} = data) do
    event = events(data)
    random_sleep()
    # credo:disable-for-next-line
    IO.inspect(event, label: "[GER interface] ")
    GerMarket.ReceiveProducer.receive_info(event)
  end

  defp generate({"UK", _} = data) do
    event = events(data)
    random_sleep()
    # credo:disable-for-next-line
    IO.inspect(event, label: "[UK interface] ")
    MyUkApp.SendProducer.send_info(event)
  end

  defp events({location, currency}) do
    %{
      company: "company: #{location}, #{random_name()}",
      price_per_share: random_price(),
      currency: currency
    }
  end

  defp random_sleep do
    time = Enum.random(@step)
    :timer.sleep(time)
  end

  defp random_name do
    Enum.random(["A", "B", "C", "D", "E", "F"])
  end

  defp random_price do
    Enum.random(@steps)
  end
end
