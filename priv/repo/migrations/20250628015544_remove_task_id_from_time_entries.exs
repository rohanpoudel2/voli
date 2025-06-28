defmodule Voli.Repo.Migrations.RemoveTaskIdFromTimeEntries do
  use Ecto.Migration

  def change do
    # Drop the check constraint first
    execute "ALTER TABLE time_entries DROP CONSTRAINT IF EXISTS task_or_habit_check"

    # Drop the foreign key and column
    alter table(:time_entries) do
      remove :task_id
    end

    # Recreate a simpler check constraint if you still want to enforce habit_id presence
    execute """
      ALTER TABLE time_entries
      ADD CONSTRAINT habit_only_check
      CHECK (
        habit_id IS NOT NULL
      )
    """
  end
end
