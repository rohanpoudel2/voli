defmodule Voli.Repo.Migrations.CreateHabits do
  use Ecto.Migration

  def change do
    create table(:habits) do
      add :title, :string
      add :description, :text
      add :frequency, :string
      add :start_date, :date
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:habits, [:user_id])
  end
end
