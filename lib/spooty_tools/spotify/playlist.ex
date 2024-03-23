defmodule SpootyTools.Spotify.Playlist do
  def get_artists_from_playlist(pid, token) do
    with base_request <- base_request(token),
         {:ok, %{body: %{"total" => total} = body}} <- Req.get(base_request),
         remaining_calls <- determine_remaining_calls(total),
         :ok <- async_fetch_remaining_items(pid, remaining_calls, token),
         initial_artists <- map_to_artists(body) do
      send(pid, {:loaded_data, :artists, initial_artists})
      :ok
    else
      e ->
        e
    end
  end

  defp async_fetch_remaining_items(pid, calls, token) do
    1..calls
    |> Enum.map(fn multiplier ->
      Task.async(fn ->
        with base <- base_request(token),
             request <- Req.update(base, params: [offset: multiplier * 50]),
             {:ok, %{body: body}} <- Req.get(request),
             artists <- map_to_artists(body) do
          send(pid, {:loaded_data, :artists, artists})
        else
          _ -> []
        end
      end)
    end)

    :ok
  end

  defp determine_remaining_calls(total) when total <= 50, do: 0

  defp determine_remaining_calls(total) do
    ((total - 50) / 50)
    |> Float.to_string()
    |> Decimal.new()
    |> Decimal.round(0, :up)
    |> Decimal.to_integer()
  end

  defp map_to_artists(%{"items" => items}),
    do: items |> Enum.map(&Enum.at(&1["track"]["artists"], 0))

  defp map_to_artists(_), do: []

  defp base_request(token, playlist_id \\ "16YtIGQgt5OZvlTPBAGcUF") do
    Req.new(
      url: "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks",
      headers: [{"authorization", "Bearer #{token}"}],
      params: [
        fields: "total,offset,items(track(artists(name,id,uri,href)))",
        limit: 50
      ]
    )
  end
end
