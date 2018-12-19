defmodule Converter.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Converter.ReceiveProducerConsumer,
      Converter.SendProducerConsumer
    ]

    opts = [strategy: :one_for_one, name: Converter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
