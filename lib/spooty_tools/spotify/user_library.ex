defmodule SpootyTools.Spotify.UserLibrary do
  def sort_saved_artists(artists, token) do
    artists
    |> Enum.chunk_every(50)
    |> Enum.map(&Task.async(fn -> is_saved_artist?(&1, token) end))
    |> Enum.map(&Task.await/1)
    |> Enum.reduce(
      %{saved: [], unsaved: []},
      &%{
        saved: List.flatten([&1.saved | &2.saved]),
        unsaved: List.flatten([&1.unsaved | &2.unsaved])
      }
    )
  end

  defp is_saved_artist?(artists, token) do
    with query_ids <- Enum.map_join(artists, ",", & &1["id"]),
         request <- base_request(token, query_ids),
         {:ok, %{body: resp}} <- Req.get(request),
         artists <-
           Enum.zip_reduce(
             artists,
             resp,
             %{saved: [], unsaved: []},
             &reducer/3
           ) do
      artists
    else
      e -> e
    end
  end

  defp reducer(artist, true, %{saved: saved, unsaved: unsaved}),
    do: %{saved: [artist | saved], unsaved: unsaved}

  defp reducer(artist, _, %{saved: saved, unsaved: unsaved}),
    do: %{saved: saved, unsaved: [artist | unsaved]}

  defp base_request(token, ids) do
    Req.new(
      url: "https://api.spotify.com/v1/me/following/contains",
      headers: [{"authorization", "Bearer #{token}"}],
      params: [
        ids: ids,
        type: "artist"
      ]
    )
  end
end
