defmodule Voli.Accountability do
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Voli.Repo

  alias Voli.Accountability.Task
  alias Voli.Accountability.Habit
  alias Voli.Accountability.HabitCompletion

  def create_task(user, attrs \\ %{}) do
    %Task{user_id: user.id}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  def list_user_tasks(user) do
    Repo.all(
      from t in Task,
        where: t.user_id == ^user.id,
        order_by: [asc: :inserted_at]
    )
  end

  def get_task!(id), do: Repo.get!(Task, id)

  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  def create_habit(user, attrs \\ %{}) do
    %Habit{user_id: user.id}
    |> Habit.changeset(attrs)
    |> Repo.insert()
  end

  def list_user_habits(user) do
    Repo.all(
      from h in Habit,
        where: h.user_id == ^user.id,
        order_by: [asc: :inserted_at]
    )
  end

  def get_habit!(id), do: Repo.get!(Habit, id)

  def update_habit(%Habit{} = habit, attrs) do
    habit
    |> Habit.changeset(attrs)
    |> Repo.update()
  end

  def delete_habit(%Habit{} = habit) do
    Repo.delete(habit)
  end

  def log_habit_completion(%Habit{} = habit, %Voli.Accounts.User{} = user, completion_date) do
    if completion_exists?(habit, completion_date) do
      {:error, :already_completed_today}
    else
      Multi.new()
      |> Multi.insert(:completion, %HabitCompletion{
        habit_id: habit.id,
        user_id: user.id,
        completed_at: completion_date
      })
      |> Multi.update(:habit, &update_habit_streak(&1, habit.id, completion_date))
      |> Repo.transaction()
    end
  end

  defp completion_exists?(%Habit{} = habit, completion_date) do
    Repo.exists?(
      from(c in HabitCompletion,
        where: c.habit_id == ^habit.id and c.completed_at == ^completion_date
      )
    )
  end

  defp update_habit_streak(_repo, habit_id, completion_date) do
    habit = Repo.get!(Habit, habit_id)

    days_since_last =
      if habit.streak_last_updated_at do
        Date.diff(completion_date, habit.streak_last_updated_at)
      else
        999
      end

    changes =
      case days_since_last do
        0 ->
          %{}

        1 ->
          %{
            current_streak: habit.current_streak + 1,
            streak_last_updated_at: completion_date
          }

        _ ->
          %{
            current_streak: 1,
            longest_streak: max(habit.current_streak, habit.longest_streak),
            streak_start_date: completion_date,
            streak_last_updated_at: completion_date
          }
      end

    Habit.changeset(habit, changes)
  end
end
