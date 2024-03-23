defmodule SpootyToolsWeb.SpotifyAuth do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]
  alias SpootyTools.Spotify

  def init(opts), do: opts

  def call(%{assigns: %{auth: auth}} = conn, _opts) do
    if expired?(auth[:refreshed_at]) do
      refresh_token(conn) |> halt()
    else
      conn
    end
  end

  # no auth present, default case
  def call(conn, _opts) do
    conn |> authorize()
  end

  defp expired?(%{fetched_at: fetched_at}),
    do: DateTime.utc_now() |> DateTime.after?(fetched_at)

  defp authorize(conn) do
    params =
      URI.encode_query(%{
        client_id: Spotify.Auth.get_client_id(),
        response_type: "code",
        scope: "user-follow-read",
        state: "yeehaw",
        redirect_uri: "http://localhost:4000/callback"
      })

    redirect_path =
      URI.parse("https://accounts.spotify.com/authorize")
      |> URI.append_query(params)
      |> URI.to_string()

    redirect(conn, external: redirect_path)
  end

  defp refresh_token(conn) do
    updated_auth =
      conn[:assigns]
      |> Map.get(:auth)
      |> Spotify.refresh_auth()

    conn
    |> assign(:auth, updated_auth)
  end
end
