defmodule Voli.Repo.Migrations.AddUniqueIndexToFriendships do
  use Ecto.Migration

  def change do
    execute("""
    DELETE FROM friendships
    WHERE id NOT IN (
      SELECT MIN(id)
      FROM friendships
      GROUP BY requester_id, receiver_id
    )
    """)

    create unique_index(:friendships, [:requester_id, :receiver_id])
  end
end
