defmodule SpootyTools.Spotify.Auth do
  def get_client_id(), do: config(:spotify_client_id)

  def get_access_token(code) do
    encoded_auth =
      Base.encode64("#{config(:spotify_client_id)}:#{config(:spotify_client_secret)}")

    req =
      Req.new(
        method: :post,
        url: "https://accounts.spotify.com/api/token",
        headers: [
          {"authorization", "Basic #{encoded_auth}"},
          {"content-type", "application/x-www-form-urlencoded"}
        ],
        form: [
          grant_type: "authorization_code",
          code: code,
          redirect_uri: "http://localhost:4000/callback"
        ]
      )

    with {:ok, resp} <- Req.post(req),
         200 <- Map.get(resp, :status),
         body <- Map.get(resp, :body) do
      {:ok, Map.put(body, "fetched_at", DateTime.utc_now())}
    else
      {:error, _} = error ->
        error

      _ ->
        {:error, "Authorization code expired"}
    end
  end

  def refresh_auth_token(%{"refresh_token" => refresh_token}) do
    encoded_auth =
      Base.encode64("#{config(:spotify_client_id)}:#{config(:spotify_client_secret)}")

    Req.new(
      method: :post,
      url: "https://accounts.spotify.com/api/token",
      headers: [
        {"authorization", "Basic #{encoded_auth}"},
        {"content-type", "application/x-www-form-urlencoded"}
      ],
      form: [
        grant_type: "refresh_token",
        refresh_token: refresh_token
      ]
    )
    |> Req.post!()
    |> Map.get(:body)
    |> Map.put(:fetched_at, DateTime.utc_now())
  end

  defp config(key) do
    Application.get_env(:spooty_tools, __MODULE__)[key]
  end
end
