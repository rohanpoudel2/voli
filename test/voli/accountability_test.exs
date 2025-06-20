defmodule Voli.AccountabilityTest do
  use Voli.DataCase

  alias Voli.Accountability

  import Voli.AccountsFixtures
  import Voli.AccountabilityFixtures

  describe "tasks" do
    alias Voli.Accountability.Task

    @valid_attrs %{title: "New Task", description: "New Task Description"}
    @invalid_attrs %{description: "Error task description"}

    test "create_task/2 with valid attributes" do
      user = user_fixture()
      assert {:ok, %Task{} = task} = Accountability.create_task(user, @valid_attrs)
      assert task.title == "New Task"
      assert task.description == "New Task Description"
      assert task.user_id == user.id
    end

    test "create_task/2 with invalid attributes" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accountability.create_task(user, @invalid_attrs)
    end

    test "list_user_tasks/1 returns all tasks for a user" do
      user = user_fixture()
      task1 = task_fixture(user, %{title: "Task 1"})
      task2 = task_fixture(user, %{title: "Task 2"})

      other_user = user_fixture(%{email: "other@email.com"})
      task_fixture(other_user, %{title: "Other User Task"})

      assert [^task1, ^task2] = Accountability.list_user_tasks(user) |> Enum.sort_by(& &1.title)
    end

    test "get_task!/1 returns the task with given id" do
      user = user_fixture()
      task = task_fixture(user)
      assert Accountability.get_task!(task.id) == task
    end

    test "update_task/2 with valid data updates the task" do
      user = user_fixture()
      task = task_fixture(user)
      update_attrs = %{title: "Updated Title", description: "Updated Description"}

      assert {:ok, %Task{} = updated_task} = Accountability.update_task(task, update_attrs)
      assert updated_task.title == "Updated Title"
      assert updated_task.description == "Updated Description"
    end

    test "delete_task/1 deletes the task" do
      user = user_fixture()
      task = task_fixture(user)
      assert {:ok, %Task{}} = Accountability.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Accountability.get_task!(task.id) end
    end

    test "toggle_task_completion/1 toggles the completed_at_status" do
      user = user_fixture()
      task = task_fixture(user)

      assert is_nil(task.completed_at)

      {:ok, completed_task} = Accountability.toggle_task_completion(task)
      assert !is_nil(completed_task.completed_at)

      {:ok, incompleted_task} = Accountability.toggle_task_completion(completed_task)
      assert is_nil(incompleted_task.completed_at)
    end
  end

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
