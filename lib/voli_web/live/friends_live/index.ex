defmodule VoliWeb.FriendsLive.Index do
  use VoliWeb, :live_view

  alias Voli.Accounts

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    socket =
      socket
      |> assign(:page_title, "Friends")
      |> assign(:friends, Accounts.list_friends(current_user))
      |> assign(:pending_requests, Accounts.list_pending_requests(current_user))
      |> assign(:form, to_form(Accounts.change_friend_search(), as: :search))

    {:ok, socket}
  end

  @impl true
  def handle_event("accept_request", %{"id" => friendship_id}, socket) do
    friendship = Accounts.get_friendship!(friendship_id)
    Accounts.accept_friend_request(friendship)

    current_user = socket.assigns.current_user

    socket =
      socket
      |> put_flash(:info, "Friend request accepted.")
      |> assign(:friends, Accounts.list_friends(current_user))
      |> assign(:pending_requests, Accounts.list_pending_requests(current_user))

    {:noreply, socket}
  end

  @impl true
  def handle_event("decline_request", %{"id" => friendship_id}, socket) do
    friendship = Accounts.get_friendship!(friendship_id)
    Accounts.decline_friend_request(friendship)

    current_user = socket.assigns.current_user

    socket =
      socket
      |> put_flash(:info, "Friend request declined.")
      |> assign(:pending_requests, Accounts.list_pending_requests(current_user))

    {:noreply, socket}
  end

  @impl true
  def handle_event("send_request", %{"search" => %{"email" => email}}, socket) do
    current_user = socket.assigns.current_user
    form_changeset = Accounts.change_friend_search(%{"email" => email})

    if form_changeset.valid? do
      socket =
        case Accounts.get_user_by_email(email) do
          nil ->
            put_flash(socket, :error, "No user found with that email.")

          recipient when recipient.id == current_user.id ->
            put_flash(socket, :error, "You cannot add yourself as a friend.")

          recipient ->
            case Accounts.send_friend_request(current_user, recipient) do
              {:ok, _} ->
                assign(socket, :form, to_form(Accounts.change_friend_search(), as: :search))
                |> put_flash(:info, "Friend request sent!")

              {:error, _} ->
                put_flash(
                  socket,
                  :error,
                  "Could not send friend request. You may have already sent one."
                )
            end
        end

      {:noreply, socket}
    else
      {:noreply, assign(socket, :form, to_form(form_changeset, as: :search))}
    end
  end
end
