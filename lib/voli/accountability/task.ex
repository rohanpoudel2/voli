defmodule Voli.Accountability.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :completed_at, :naive_datetime
    field :description, :string
    field :due_date, :date
    field :title, :string

    belongs_to :user, Voli.Accounts.User
    has_many :time_entries, Voli.Accountability.TimeEntry

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :due_date, :completed_at])
    |> validate_required([:title, :description, :due_date, :completed_at])
  end
end
