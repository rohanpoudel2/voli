defmodule Voli.Accounts.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friendships" do
    field :status, :string

    belongs_to :requester, Voli.Accounts.User, foreign_key: :requester_id
    belongs_to :receiver, Voli.Accounts.User, foreign_key: :receiver_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [:status, :requester_id, :receiver_id])
    |> validate_required([:status, :requester_id, :receiver_id])
    |> validate_inclusion(:status, ["pending", "accepted", "declined"])
    |> check_constraint(:requester_id, name: :friendships_requester_id_fkey)
    |> check_constraint(:receiver_id, name: :friendships_receiver_id_fkey)
    |> unique_constraint([:requester_id, :receiver_id],
      name: :friendships_requester_id_receiver_id_index,
      message: "Friend request already sent"
    )
  end
end
