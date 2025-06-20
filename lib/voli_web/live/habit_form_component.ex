defmodule VoliWeb.HabitFormComponent do
  use VoliWeb, :live_component

  alias Voli.Accountability
  alias Voli.Accountability.Habit

  @impl true
  def update(assigns, socket) do
    changeset = Accountability.change_habit(%Habit{})

    socket =
      socket
      |> assign(assigns)
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"habit" => habit_params}, socket) do
    changeset =
      Accountability.change_habit(%Habit{}, habit_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"habit" => habit_params}, socket) do
    current_user = socket.assigns.current_user

    case Accountability.create_habit(current_user, habit_params) do
      {:ok, habit} ->
        send(self(), {:habit_created, habit})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
