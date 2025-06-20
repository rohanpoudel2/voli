defmodule VoliWeb.DashboardLive.Show do
  use VoliWeb, :live_view

  alias Voli.Page

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:dashboard, Page.get_dashboard!(id))}
  end

  defp page_title(:show), do: "Show Dashboard"
  defp page_title(:edit), do: "Edit Dashboard"
end
