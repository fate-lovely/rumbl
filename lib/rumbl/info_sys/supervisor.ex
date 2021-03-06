defmodule Rumbl.InfoSys.Supervisor do
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(backend, query, query_ref, owner, limit) do
    spec = %{
      id: Rumbl.InfoSys, 
      start: {
        Rumbl.InfoSys, 
        :start_link, 
        [backend, query, query_ref, owner, limit],
      },
      restart: :temporary,
    }

    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
