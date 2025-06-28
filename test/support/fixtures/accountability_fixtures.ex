defmodule Voli.AccountabilityFixtures do

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
