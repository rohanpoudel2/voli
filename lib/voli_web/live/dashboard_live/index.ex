defmodule VoliWeb.DashboardLive.Index do
  use VoliWeb, :live_view

  alias Voli.Accountability
  alias Voli.Accounts

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    if connected?(socket) do
      VoliWeb.Endpoint.subscribe("user:#{current_user.id}")
      friends = Accounts.list_friends(current_user)
      for friend <- friends, do: VoliWeb.Endpoint.subscribe("user:#{friend.id}")
    end

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

    socket = stream_delete(socket, :tasks, task)
    {:noreply, stream_insert(socket, :tasks, updated_task, at: 0)}
  end

  @impl true
  def handle_event("log_habit_completion", %{"id" => habit_id}, socket) do
    habit = Accountability.get_habit!(habit_id)
    today = Date.utc_today()

    case Accountability.log_habit_completion(habit, socket.assigns.current_user, today) do
      {:ok, %{habit: updated_habit}} ->
        socket =
          socket
          |> put_flash(:info, "'#{updated_habit.title}' completed for today!")
          |> stream_insert(:habits, updated_habit)

        {:noreply, socket}

      {:error, :already_completed_today} ->
        socket = put_flash(socket, :error, "You've already logged that habit today.")
        {:noreply, socket}
    end
  end

  def handle_event("delete_habit", %{"id" => habit_id}, socket) do
    habit = Accountability.get_habit!(habit_id)
    {:ok, _} = Accountability.delete_habit(habit)

    socket =
      socket
      |> put_flash(:info, "Habit '#{habit.title}' deleted successfully.")
      |> stream_delete(:habits, habit)

    {:noreply, socket}
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

  @impl true
  def handle_info({:task_completed, task}, socket) do
    if task.user_id != socket.assigns.current_user.id do
      friend = Accounts.get_user!(task.user_id)
      flash_message = "#{friend.email} just completed a task: '#{task.title}'"
      {:noreply, put_flash(socket, :info, flash_message)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:habit_completed, user, habit}, socket) do
    if user.id != socket.assigns.current_user.id do
      friend = Accounts.get_user!(user.id)

      flash_message =
        "#{friend.email} just completed a habit: '#{habit.title}! Their streak is now #{habit.current_streak}.'"

      {:noreply, put_flash(socket, :info, flash_message)}
    else
      {:noreply, socket}
    end
  end
end
