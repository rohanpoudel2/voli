defmodule VoliWeb.FriendsLiveTest do
  use VoliWeb.ConnCase
  import Phoenix.LiveViewTest

  import Voli.AccountsFixtures

  alias Voli.Accounts

  describe "FriendsLive.Index" do
     test "shows a pending friend request for the receiver", %{conn: conn} do
      sender = user_fixture(%{email: "sender@example.com"})
      receiver = user_fixture(%{email: "receiver@example.com"})

      {:ok, _friendship} = Accounts.send_friend_request(sender, receiver)

      conn = log_in_user(conn, receiver)
      {:ok, _view, html} = live(conn, ~p"/friends")

      assert html =~ "Pending Requests"
      assert html =~ "sender@example.com"
     end

     test "accepts a friend request from the UI", %{conn: conn} do
      sender = user_fixture(%{email: "sender@example.com"})
      receiver = user_fixture(%{email: "receiver@example.com"})

      {:ok, _friendship} = Accounts.send_friend_request(sender, receiver)

      conn = log_in_user(conn, receiver)
      {:ok, view, _html} = live(conn, ~p"/friends")

      # Simulate clicking the "Accept" button
      view
      |> element("#accept-#{sender.id}")
      |> render_click()

      # Verify the sender now appears in the friends list
      assert render(view) =~ "My Friends"
      assert render(view) =~ "sender@example.com"
    end

    test "declines a friend request from the UI", %{conn: conn} do
      sender = user_fixture(%{email: "decline_sender@example.com"})
      receiver = user_fixture(%{email: "receiver@example.com"})

      {:ok, friendship} = Accounts.send_friend_request(sender, receiver)

      conn = log_in_user(conn, receiver)
      {:ok, view, _html} = live(conn, ~p"/friends")

      # Simulate clicking the "Decline" button
      view
      |> element("#decline-#{friendship.id}")
      |> render_click()

      # Confirm the request is no longer shown
      refute render(view) =~ "decline_sender@example.com"
    end

    test "friends are visible to both users after acceptance", %{conn: conn} do
      sender = user_fixture(%{email: "sender@example.com"})
      receiver = user_fixture(%{email: "receiver@example.com"})

      {:ok, friendship} = Accounts.send_friend_request(sender, receiver)
      {:ok, _updated_friendship} = Accounts.accept_friend_request(friendship)

      # Both users should now see each other in their friends list

      conn = log_in_user(conn, receiver)
      {:ok, _view, html1} = live(conn, ~p"/friends")
      assert html1 =~ "sender@example.com"

      conn = log_in_user(conn, sender)
      {:ok, _view, html2} = live(conn, ~p"/friends")
      assert html2 =~ "receiver@example.com"
    end

    test "shows empty state when user has no friends or requests", %{conn: conn} do
      user = user_fixture(%{email: "lonely@example.com"})

      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/friends")

      assert render(view) =~ "added any friends yet."
      assert render(view) =~ "You have no pending friend requests."

    end

    test "does not allow duplicate friend requests", _ do
      user = user_fixture(%{email: "sender@example.com"})
      target = user_fixture(%{email: "target@example.com"})

      {:ok, _friendship} = Accounts.send_friend_request(user, target)
      assert {:error, changeset} = Accounts.send_friend_request(user, target)

      assert {"Friend request already sent", _meta} = changeset.errors[:requester_id]
    end

    test "shows error on invalid email in add friend form", %{conn: conn} do
      user = user_fixture(%{email: "user@example.com"})
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/friends")

      form_data = %{"search" => %{"email" => "notanemail"}}

      # Submit the invalid form
      view
      |> element("form")
      |> render_submit(form_data)

      # Assert the error is shown
      assert render(view) =~ "must have the @ sign and no spaces"
    end
  end
  end
