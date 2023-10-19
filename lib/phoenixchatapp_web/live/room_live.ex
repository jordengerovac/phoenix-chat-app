defmodule PhoenixchatappWeb.RoomLive do
  use PhoenixchatappWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)
    if connected?(socket) do
      PhoenixchatappWeb.Endpoint.subscribe(topic)
      PhoenixchatappWeb.Presence.track(self(), topic, username, %{})
    end
    {:ok,
      assign(socket,
        room_id: room_id,
        topic: topic,
        username: username,
        current_message: "",
        messages: [],
        user_list: [],
        temporary_assigns: [messages: []]
      )
    }
  end

  @impl true
  def handle_event("submit_message", %{"current_message" => current_message}, socket) do
    messageObj = %{uuid: UUID.uuid4(), content: current_message, username: socket.assigns.username}
    PhoenixchatappWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", messageObj)
    {:noreply, assign(socket, current_message: "")}
  end

  @impl true
  def handle_event("form-change", %{"current_message" => current_message}, socket) do
    {:noreply, assign(socket, current_message: current_message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: current_message}, socket) do
    {:noreply, assign(socket, messages: [current_message])}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    join_messages = joins
      |> Map.keys()
      |> Enum.map(fn username -> %{uuid: UUID.uuid4(), content: username <> " joined", type: :system} end)
    leave_messages = leaves
      |> Map.keys()
      |> Enum.map(fn username -> %{uuid: UUID.uuid4(), content: username <> " left", type: :system} end)
    user_list = PhoenixchatappWeb.Presence.list(socket.assigns.topic)
      |> Map.keys()
    {:noreply, assign(socket, messages: join_messages ++ leave_messages, user_list: user_list)}
  end

  def display_message(%{type: :system, uuid: uuid, content: content}) do
    ~E"""
      <p id="<%= uuid %>">
        <em><%=content %></em>
      </p>
    """
  end

  def display_message(%{uuid: uuid, content: content, username: username}) do
    ~E"""
      <p id="<%= uuid %>">
        <strong><%= username %></strong>: <%= content %>
      </p>
    """
   end
end
