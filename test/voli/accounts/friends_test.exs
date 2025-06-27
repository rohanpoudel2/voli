defmodule Voli.Accounts.FriendsTest do
  use Voli.DataCase, async: true

  alias Voli.Accounts

  describe "change_friend_search/1" do
    test "returns a valid changeset with a proper email" do
      attrs = %{"email" => "test@example.com"}
      changeset = Accounts.change_friend_search(attrs)

      assert changeset.valid?
      assert changeset.changes.email == "test@example.com"
    end

    test "returns error if email is missing" do
      changeset = Accounts.change_friend_search(%{})

      refute changeset.valid?
      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns error for invalid email format" do
      changeset = Accounts.change_friend_search(%{"email" => "not-an-email"})

      refute changeset.valid?
      assert %{email: ["has invalid format"]} = errors_on(changeset)
    end
  end

  describe "CRUD operations on Friends schema" do
     test "creates, fetches, updates, deletes a friend record" do
      valid_attrs = %{field1: "value1", field2: "value2"}  # Replace with actual fields
      {:ok, friend} = Accounts.create_friends(valid_attrs)
      assert friend.id

      fetched = Accounts.get_friends!(friend.id)
      assert fetched.id == friend.id

      {:ok, _} = Accounts.delete_friends(friend)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_friends!(friend.id) end
    end
  end
end
