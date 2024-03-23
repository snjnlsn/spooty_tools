defmodule SpootyTools.Spotify.Artist do
  def get_artist_details(artist_ids, token) do
    # how to fix this re: rate limiting - only care about genre details here, and return that top-level. allow UI options of follow-up call to fetch related artists and their details, and do that with built in rate handling

    artist_ids
    |> Enum.chunk_every(100)
    |> Enum.map(&Task.async(fn -> fetch_artists(&1, token) end))
    |> Enum.flat_map(&Task.await(&1))
  end

  def get_related_artists(artist_ids, token) when is_list(artist_ids) do
    # need to handle rate-limiting

    artist_ids
    |> Enum.map(&Task.async(fn -> get_related_artists(&1, token) end))
  end

  defp fetch_artists(artist_ids, token) do
    req =
      Req.new(
        url: "https://api.spotify.com/v1/artists",
        params: [ids: Enum.join(artist_ids, ",")],
        headers: [{"authorization", "Bearer #{token}"}]
      )

    with {:ok, resp} <- Req.get(req),
         body <- Map.get(resp, :body) do
      body
    end
  end

  defp fetch_related_artists(artist_id, token) do
    req =
      Req.new(
        url: "https://api.spotify.com/v1/artists/#{artist_id}/related-artists",
        headers: [{"authorization", "Bearer #{token}"}]
      )

    with {:ok, resp} <- Req.get(req),
         body <- Map.get(resp, :body) do
      body
    end
  end
end
