defmodule SpootyTools.Spotify do
  alias SpootyTools.Spotify.UserLibrary
  alias SpootyTools.Spotify.{Auth, Playlist, UserLibrary}

  def get_saved_artists_from_playlist(code) do
    with %{"access_token" => token} <- Auth.get_access_token(code),
         {:ok, artists} <-
           Playlist.get_artists_from_playlist(token),
         {:ok, sorted_artists} <-
           UserLibrary.sort_saved_artists(artists, token) do
      {:ok, sorted_artists}
    else
      e ->
        e
    end
  end

  def get_saved_artists_from_playlist(token, :token) do
    with {:ok, artists} <-
           Playlist.get_artists_from_playlist(token),
         {:ok, sorted_artists} <-
           UserLibrary.sort_saved_artists(artists, token) do
      {:ok, sorted_artists}
    else
      e ->
        e
    end
  end
end
