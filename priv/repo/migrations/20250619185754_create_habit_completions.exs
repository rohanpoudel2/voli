defmodule Voli.Repo.Migrations.CreateHabitCompletions do
  use Ecto.Migration

  def change do
    create table(:habit_completions) do
      add :completed_at, :date
      add :habit_id, references(:habits, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:habit_completions, [:habit_id])
    create index(:habit_completions, [:user_id])
  end
end
