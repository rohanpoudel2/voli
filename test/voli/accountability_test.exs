defmodule Voli.AccountabilityTest do
  use Voli.DataCase

  alias Voli.Accountability

  import Voli.AccountsFixtures
  import Voli.AccountabilityFixtures

  describe "habits" do
    alias Voli.Accountability.Habit

    test "create_habit/2 with valid data creates a habit" do
      user = user_fixture()
      valid_attrs = %{title: "Go for a run", frequency: "daily"}

      assert {:ok, %Habit{} = habit} = Accountability.create_habit(user, valid_attrs)
      assert habit.title == "Go for a run"
      assert habit.frequency == "daily"
      assert habit.user_id == user.id
    end

    test "create_habit/2 with invalid data returns an error changeset" do
      user = user_fixture()
      invalid_attrs = %{title: "Invalid Habit"}
      assert {:error, %Ecto.Changeset{}} = Accountability.create_habit(user, invalid_attrs)
    end

    test "list_user_habits/1 returns all habits for a user" do
      user = user_fixture()
      habit1 = habit_fixture(user, %{title: "Habit A"})
      habit2 = habit_fixture(user, %{title: "Habit B"})

      other_user = user_fixture()
      habit_fixture(other_user)

      assert [^habit1, ^habit2] =
               Accountability.list_user_habits(user) |> Enum.sort_by(& &1.title)
    end

    test "get_habit!/1 returns the habit with given id" do
      user = user_fixture()
      habit = habit_fixture(user)
      assert Accountability.get_habit!(habit.id) == habit
    end

    test "update_habit/2 with valid data updates the habit" do
      user = user_fixture()
      habit = habit_fixture(user)
      update_attrs = %{title: "Updated Habit Title", frequency: "weekly"}

      assert {:ok, %Habit{} = updated_habit} = Accountability.update_habit(habit, update_attrs)
      assert updated_habit.title == "Updated Habit Title"
      assert updated_habit.frequency == "weekly"
    end

    test "delete_habit/1 deletes the habit" do
      user = user_fixture()
      habit = habit_fixture(user)
      assert {:ok, %Habit{}} = Accountability.delete_habit(habit)
      assert_raise Ecto.NoResultsError, fn -> Accountability.get_habit!(habit.id) end
    end
  end

  describe "habit completions and streaks" do
    alias Voli.Accountability.HabitCompletion

    test "log_habit_completion creates a completion and starts a streak" do
      user = user_fixture()
      habit = habit_fixture(user)
      today = Date.utc_today()

      assert {:ok, %{completion: %HabitCompletion{}, habit: updated_habit}} =
               Accountability.log_habit_completion(habit, user, today)

      assert updated_habit.current_streak == 1
      assert updated_habit.longest_streak == 0
      assert updated_habit.streak_start_date == today
      assert updated_habit.streak_last_updated_at == today
    end

    test "log_habit_completion continues a streak" do
      user = user_fixture()
      today = Date.utc_today()
      yesterday = Date.add(today, -1)

      habit = habit_fixture(user, %{current_streak: 3, streak_last_updated_at: yesterday})

      assert {:ok, %{habit: updated_habit}} =
               Accountability.log_habit_completion(habit, user, today)

      assert updated_habit.current_streak == 4
      assert updated_habit.streak_last_updated_at == today
    end

    test "log_habit_completion breaks a streak and updates longest_streak" do
      user = user_fixture()
      today = Date.utc_today()
      two_days_ago = Date.add(today, -2)

      habit =
        habit_fixture(user, %{
          current_streak: 5,
          longest_streak: 5,
          streak_last_updated_at: two_days_ago
        })

      assert {:ok, %{habit: updated_habit}} =
               Accountability.log_habit_completion(habit, user, today)

      assert updated_habit.current_streak == 1
      assert updated_habit.longest_streak == 5
      assert updated_habit.streak_last_updated_at == today
    end

    test "log_habit_completion does not create duplicate completions for the same day" do
      user = user_fixture()
      habit = habit_fixture(user)
      today = Date.utc_today()

      Accountability.log_habit_completion(habit, user, today)

      assert {:error, :already_completed_today} =
               Accountability.log_habit_completion(habit, user, today)
    end
  end
end
