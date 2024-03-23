defmodule SpootyTools.Spotify do
  alias SpootyTools.Spotify.{Auth, Playlist}

  def get_auth(code), do: Auth.get_access_token(code)

  def refresh_auth(auth), do: Auth.refresh_auth_token(auth)

  def fetch_artists(pid, %{"access_token" => token}),
    do: Playlist.get_artists_from_playlist(pid, token)
end
