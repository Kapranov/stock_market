defmodule UsaMarket.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      UsaMarket.ReceiveProducer,
      UsaMarket.SendConsumer
    ]

    opts = [strategy: :one_for_one, name: UsaMarket.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
