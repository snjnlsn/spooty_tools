defmodule SpootyToolsWeb.PageController do
  use SpootyToolsWeb, :controller

  alias SpootyTools.Spotify

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def authorize(conn, _params) do
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

  def callback(conn, %{"code" => code, "state" => "yeehaw"}) do
    # make this an async assign live view
    %{saved: saved, unsaved: _unsaved} =
      Spotify.get_saved_artists_from_playlist(code)

    render(conn, :artists, saved_artists: saved)
  end
end
