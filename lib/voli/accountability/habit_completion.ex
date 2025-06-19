defmodule Voli.Accountability.HabitCompletion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "habit_completions" do
    field :completed_at, :date

    belongs_to :habit, Voli.Accountability.Habit
    belongs_to :user, Voli.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(habit_completion, attrs) do
    habit_completion
    |> cast(attrs, [:completed_at])
    |> validate_required([:completed_at])
  end
end
