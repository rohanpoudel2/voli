defmodule Voli.Repo.Migrations.CreateFriendships do
  use Ecto.Migration

  def change do
    create table(:friendships) do
      add :status, :string
      add :requester_id, references(:users, on_delete: :nothing)
      add :receiver_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:friendships, [:requester_id])
    create index(:friendships, [:receiver_id])
  end
end
