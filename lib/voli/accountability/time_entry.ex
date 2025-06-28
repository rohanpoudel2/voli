defmodule Voli.Accountability.TimeEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "time_entries" do
    field :end_time, :naive_datetime
    field :start_time, :naive_datetime

    belongs_to :habit, Voli.Accountability.Habit, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(time_entry, attrs) do
    time_entry
    |> cast(attrs, [:start_time, :end_time])
    |> validate_required([:start_time, :end_time])
  end
end
