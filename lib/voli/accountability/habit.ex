defmodule Voli.Accountability.Habit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "habits" do
    field :description, :string
    field :frequency, :string
    field :start_date, :date
    field :title, :string
    field :current_streak, :integer, default: 0
    field :longest_streak, :integer, default: 0
    field :streak_start_date, :date
    field :streak_last_updated_at, :date

    belongs_to :user, Voli.Accounts.User

    has_many :habit_completions, Voli.Accountability.HabitCompletion
    has_many :time_entries, Voli.Accountability.TimeEntry

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(habit, attrs) do
    habit
    |> cast(attrs, [:title, :description, :frequency, :start_date])
    |> validate_required([:title, :description, :frequency, :start_date])
  end
end
