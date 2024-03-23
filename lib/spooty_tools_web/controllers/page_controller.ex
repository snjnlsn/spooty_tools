defmodule SpootyToolsWeb.PageController do
  use SpootyToolsWeb, :controller

  alias SpootyTools.Spotify

  def callback(conn, %{"code" => code, "state" => "yeehaw"}) do
    with {:ok, auth} <- Spotify.get_auth(code) do
      conn
      |> put_layout(false)
      |> live_render(SpootyToolsWeb.HomeLive, session: %{"auth" => auth})
    else
      e ->
        IO.inspect(e)
        redirect(conn, to: "/error")
    end
  end

  def error(conn, _params) do
    conn
    |> put_view(html: SpootyToolsWeb.ErrorHTML)
    |> render(:error)
  end
end
