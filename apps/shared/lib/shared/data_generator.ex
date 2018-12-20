defmodule Shared.DataGenerator do
  @moduledoc false

  @steps 1..1000

  def generate do
    for _x <- (@steps) do
      [{"US", :usd}, {"GER", :eur}, {"UK", :gbp}]
      |> Enum.random()
      |> generate()
    end
  end

  defp generate({"US", _} = data) do
    data
  end

  defp generate({"GER", _} = data) do
    data
  end

  defp generate({"UK", _} = data) do
    data
  end
end
