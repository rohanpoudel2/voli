defmodule Voli.Repo.Migrations.CreateTimeEntries do
  use Ecto.Migration

  def change do
    create table(:time_entries) do
      add :start_time, :naive_datetime
      add :end_time, :naive_datetime
      add :task_id, references(:tasks, on_delete: :delete_all), null: true
      add :habit_id, references(:habits, on_delete: :delete_all), null: true

      timestamps(type: :utc_datetime)
    end

    create index(:time_entries, [:task_id])
    create index(:time_entries, [:habit_id])

    execute """
      ALTER TABLE time_entries
      ADD CONSTRAINT task_or_habit_check
      CHECK (
        (task_id IS NOT NULL AND habit_id IS NULL) OR
        (task_id IS NULL AND habit_id IS NOT NULL)
      )
    """
  end
end
