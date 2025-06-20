defmodule Voli.PageFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Voli.Page` context.
  """

  @doc """
  Generate a dashboard.
  """
  def dashboard_fixture(attrs \\ %{}) do
    {:ok, dashboard} =
      attrs
      |> Enum.into(%{

      })
      |> Voli.Page.create_dashboard()

    dashboard
  end
end
