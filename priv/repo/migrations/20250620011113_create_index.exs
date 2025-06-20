defmodule Voli.Repo.Migrations.CreateIndex do
  use Ecto.Migration

  def change do
    create table(:index) do

      timestamps(type: :utc_datetime)
    end
  end
end
