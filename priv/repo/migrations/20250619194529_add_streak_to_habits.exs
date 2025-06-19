defmodule Voli.Repo.Migrations.AddStreakToHabits do
  use Ecto.Migration

  def change do
    alter table(:habits) do
      add :current_streak, :integer, default: 0, null: false
      add :longest_streak, :integer, default: 0, null: false
      add :streak_start_date, :date
      add :streak_last_updated_at, :date
    end

    create index(:habits, [:current_streak])
    create index(:habits, [:longest_streak])
  end
end
