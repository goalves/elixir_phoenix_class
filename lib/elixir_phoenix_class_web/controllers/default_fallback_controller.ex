defmodule EPClassWeb.DefaultFallbackController do
  use EPClassWeb, :controller
  alias EPClassWeb.{ChangesetView, ErrorView}
  require Logger

  def call(conn, {:error, changeset = %Ecto.Changeset{}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ChangesetView)
    |> render("error.json", changeset)
  end

  def call(conn, {:error, :user_does_not_exist}), do: call_not_found_error_view(conn)

  def call(conn, params) do
    Logger.error(
      "Route was called and did not match anything in controller or fallback. Controller:#{
        inspect(conn.private.phoenix_controller)
      }. Method: #{inspect(conn.private.phoenix_action)}. Parameters: #{inspect(conn.body_params)} The error catch was: #{
        inspect(params)
      }."
    )

    conn
    |> put_status(:internal_server_error)
    |> put_view(ErrorView)
    |> render("500.json")
  end

  defp call_not_found_error_view(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(ErrorView)
    |> render("404.json")
  end
end
