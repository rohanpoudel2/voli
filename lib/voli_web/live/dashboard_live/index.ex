defmodule VoliWeb.DashboardLive.Index do
  use VoliWeb, :live_view

  alias Voli.Accountability

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    socket =
      socket
      |> assign(:page_title, "Dashboard")
      |> assign(:current_user, current_user)
      |> stream(:tasks, Accountability.list_user_tasks(current_user))
      |> stream(:habits, Accountability.list_user_habits(current_user))
      |> assign(:show_task_modal, false)
      |> assign(:show_habit_modal, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("show_task_modal", _, socket) do
    {:noreply, assign(socket, :show_task_modal, true)}
  end

  @impl true
  def handle_event("hide_task_modal", _, socket) do
    {:noreply, assign(socket, :show_task_modal, false)}
  end

  @impl true
  def handle_event("show_habit_modal", _, socket) do
    {:noreply, assign(socket, :show_habit_modal, true)}
  end

  @impl true
  def handle_event("hide_habit_modal", _, socket) do
    {:noreply, assign(socket, :show_habit_modal, false)}
  end

  @impl true
  def handle_event("delete_task", %{"id" => task_id}, socket) do
    task = Accountability.get_task!(task_id)
    {:ok, _} = Accountability.delete_task(task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end

  @impl true
  def handle_event("toggle_task_completion", %{"id" => task_id}, socket) do
    task = Accountability.get_task!(task_id)
    {:ok, updated_task} = Accountability.toggle_task_completion(task)

    {:noreply, stream_insert(socket, :tasks, updated_task)}
  end

  @impl true
  def handle_info({:task_created, task}, socket) do
    socket =
      socket
      |> put_flash(:info, "Task created successfully.")
      |> stream_insert(:tasks, task, at: 0)

    {:noreply, assign(socket, :show_task_modal, false)}
  end

  @impl true
  def handle_info({:habit_created, habit}, socket) do
    socket =
      socket
      |> put_flash(:info, "Habit created successfully.")
      |> stream_insert(:habits, habit, at: 0)

    {:noreply, assign(socket, :show_habit_modal, false)}
  end
end
