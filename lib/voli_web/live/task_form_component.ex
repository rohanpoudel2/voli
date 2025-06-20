defmodule VoliWeb.TaskFormComponent do
  use VoliWeb, :live_component

  alias Voli.Accountability
  alias Voli.Accountability.Task

  @impl true
  def update(assigns, socket) do
    changeset = Accountability.change_task(%Task{})

    socket =
      socket
      |> assign(assigns)
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset =
      Accountability.change_task(%Task{}, task_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"task" => task_params}, socket) do
    current_user = socket.assigns.current_user

    case Accountability.create_task(current_user, task_params) do
      {:ok, task} ->
        send(self(), {:task_created, task})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
