defmodule DailyTwangWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use DailyTwangWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import DailyTwangWeb.ConnCase

      alias DailyTwangWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint DailyTwangWeb.Endpoint
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(DailyTwang.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in accounts.

      setup :register_and_log_in_account

  It stores an updated connection and a registered account in the
  test context.
  """
  def register_and_log_in_account(%{conn: conn}) do
    account = DailyTwang.AccountsFixtures.account_fixture()
    %{conn: log_in_account(conn, account), account: account}
  end

  @doc """
  Logs the given `account` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_account(conn, account) do
    token = DailyTwang.Accounts.generate_account_session_token(account)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:account_token, token)
  end
end