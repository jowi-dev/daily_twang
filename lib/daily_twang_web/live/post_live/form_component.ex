defmodule DailyTwangWeb.PostLive.FormComponent do
  use DailyTwangWeb, :live_component

  alias DailyTwang.Posts

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Posts.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Posts.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  def handle_event("save", thing, socket) do
    IO.inspect(thing, pretty: true)
    date = Timex.now()
    {:ok, format} = Timex.format(date, "{YYYY}-{0M}-{0D}")

    message = %DailyTwang.Posts.Post{
      id: UUID.uuid1(),
      title: "NEW MESSAGE",
      source: "Anonymous",
      link: "/",
      updated: date,
      uploaded_at: format
    }

    case Cachex.get(:chatter, "messages") do
      {:ok, nil} ->
        IO.puts("MADE IT")
        Cachex.put(:chatter, "messages", [message])

      {:ok, val} ->
        IO.inspect(val, pretty: true, label: "val is")
        Cachex.put(:chatter, "messages", [message] ++ val)

      _ ->
        IO.puts("MISSED")
    end

    Phoenix.PubSub.broadcast(DailyTwang.PubSub, "messages", {:new_message, message})

    {:noreply,
     socket
     |> assign(:has_messages, true)
     |> put_flash(:info, "Post created successfully")
     |> push_redirect(to: socket.assigns.return_to)}
  end

  defp save_post(socket, :edit, post_params) do
    case Posts.update_post(socket.assigns.post, post_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    case Posts.create_post(post_params) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
