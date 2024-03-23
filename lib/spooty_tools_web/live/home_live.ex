defmodule SpootyToolsWeb.HomeLive do
  alias Phoenix.LiveView.AsyncResult
  alias SpootyTools.Spotify
  use SpootyToolsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="my-4 text-center">
      <.button :if={!@async_result_artist.loading} phx-click="fetch-artists">Start</.button>
      <.button :if={@async_result_artist.loading} phx-click="cancel-fetch-artists">Cancel</.button>
    </div>

    <span><%= Enum.map_join(@artists, ", ", &Map.get(&1, "name")) %></span>
    """
  end

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:auth, session["auth"])
      |> assign(:async_result_artist, %AsyncResult{})
      |> assign(:artists, [])

    {:ok, socket}
  end

  def handle_event("fetch-artists", _unsigned_params, socket) do
    socket =
      socket
      |> start_fetch_artists()

    {:noreply, socket}
  end

  def handle_event("cancel-fetch-artists", _params, socket) do
    socket =
      socket
      |> cancel_async(:fetching_artists)
      |> assign(:async_result_artist, %AsyncResult{})
      |> put_flash(:info, "Cancelled")

    {:noreply, socket}
  end

  def handle_info({:loaded_data, data, value}, socket) do
    socket =
      socket
      |> assign(data, socket.assigns[data] |> List.insert_at(-1, value) |> List.flatten())

    IO.inspect(socket.assigns.artists)

    {:noreply, socket}
  end

  def start_fetch_artists(socket) do
    live_view_pid = self()
    auth = socket.assigns.auth

    # for the future commands this might need to be a stream and not an AsyncResult
    socket
    |> assign(:async_result_artist, AsyncResult.loading())
    |> start_async(:fetching_artists, fn ->
      Spotify.fetch_artists(live_view_pid, auth)
    end)
  end

  # success
  def handle_async(:fetching_artists, {:ok, :ok}, socket) do
    socket =
      socket
      |> put_flash(:info, "Artists Loaded!")
      |> assign(:async_result_artist, AsyncResult.ok(%AsyncResult{}, :ok))

    {:noreply, socket}
  end

  # error
  def handle_async(:fetching_artists, {:ok, {:error, reason}}, socket) do
    socket =
      socket
      |> put_flash(:error, reason)
      |> assign(:async_result_artist, AsyncResult.failed(%AsyncResult{}, reason))

    {:noreply, socket}
  end

  # exit
  def handle_async(:fetching_artists, {:exit, reason}, socket) do
    socket =
      socket
      |> put_flash(:error, "Task failed: #{inspect(reason)}")
      |> assign(:async_result_artist, %AsyncResult{})

    {:noreply, socket}
  end
end
