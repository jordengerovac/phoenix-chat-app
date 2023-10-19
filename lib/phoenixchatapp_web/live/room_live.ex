defmodule PhoenixchatappWeb.RoomLive do
  use PhoenixchatappWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    {:ok, assign(socket, room_id: room_id)}
  end
end
