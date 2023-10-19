defmodule PhoenixchatappWeb.PageLive do
  use PhoenixchatappWeb, :live_view
  require Logger

  # def render(assigns) do
  #   ~H"""
  #   ...
  #   """
  # end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("random-room", _params, socket) do
    random_slug = "/" <> MnemonicSlugs.generate_slug(4)
    {:noreply, push_redirect(socket, to: random_slug)}
  end
end
