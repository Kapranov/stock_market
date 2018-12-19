defmodule Shared.Interface do
  @moduledoc false

  use GenServer

  @name __MODULE__

  def start_link(name, test_pid) do
    GenServer.start_link(@name, test_pid, name: name)
  end

  def process_info(name, event) do
    GenServer.call(name, {:process_info, event})
  end

  def init(test_pid), do: {:ok, test_pid}

  def handle_call({:process_info, event}, _from, test_pid) do
    send(test_pid, {:received, event})
    {:reply, :ok, test_pid}
  end
end
