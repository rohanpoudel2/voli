defmodule Voli.Repo.Migrations.DropTasksTable do
  use Ecto.Migration

  def change do
    drop table(:tasks)
  end
end
