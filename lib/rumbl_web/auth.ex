defmodule RumblWeb.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Rumbl.Account

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_username_and_pass(conn, username, pass) do
    case Rumbl.Account.authenticate_user(username, pass) do
      {:ok, user} -> {:ok, login(conn, user)}
      {:error, reason} -> {:error, reason, conn}
    end
  end

  def logout(conn) do
    delete_session(conn, :user_id)
  end

  ## Plugs

  # make sure `conn.assigns.current_user` exists
  def fetch_user_from_session(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      conn.assigns[:current_user] ->
        conn

      user = user_id && Account.get_user(user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def require_login(conn, _opts) do
    import Phoenix.Controller
    alias RumblWeb.Router.Helpers

    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
