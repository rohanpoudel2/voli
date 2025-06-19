defmodule Voli.Accountability do
  import Ecto.Query, warn: false
  alias Voli.Repo

  alias Voli.Accountability.Task
  alias Voli.Accountability.Habit
  alias Voli.Accountability.TimeEntry
  alias Voli.Accountability.HabitCompletion

  def create_task(user, attrs \\ %{}) do
    %Task{user_id: user.id}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end
end
