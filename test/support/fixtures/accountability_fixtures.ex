defmodule Voli.AccountabilityFixtures do
  def task_fixture(user, attrs \\ %{}) do
    valid_attrs = %{title: "A valid title", description: "A valid description"}
    final_attrs = Map.merge(valid_attrs, attrs)
    {:ok, task} = Voli.Accountability.create_task(user, final_attrs)

    task
  end

  def habit_fixture(user, attrs \\ %{}) do
    valid_attrs = %{
      title: "Read a Book",
      description: "Read 20 pages of a non-fiction book.",
      frequency: "daily"
    }

    final_attrs = Map.merge(valid_attrs, attrs)
    {:ok, habit} = Voli.Accountability.create_habit(user, final_attrs)

    habit
  end
end
