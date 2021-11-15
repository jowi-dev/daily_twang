defmodule DailyTwangWeb.Pwa.PostController do
  use DailyTwangWeb, :controller

  alias DailyTwang.Posts
  alias DailyTwang.Posts.Post

  def index(conn, _params) do
    posts = Posts.list_posts()

    meta_attrs = [
      %{name: "og:title", content: "Daily Twang"},
      %{name: "og:image", content: "/images/cat-banjo-icon.png"},
      %{name: "og:description", content: "Daily Twang PWA"},
      %{name: "description", content: "Daily Twang PWA"}
    ]

    conn
    |> assign(:meta_attrs, meta_attrs)
    |> assign(:page_title, "Daily Twang")
    |> assign(:manifest, "/manifest.json")
    |> render("index.html", posts: posts)
  end

  #  def new(conn, _params) do
  #    changeset = Posts.change_post(%Post{})
  #    render(conn, "new.html", changeset: changeset)
  #  end
  #
  #  def create(conn, %{"post" => post_params}) do
  #    case Posts.create_post(post_params) do
  #      {:ok, post} ->
  #        conn
  #        |> put_flash(:info, "Post created successfully.")
  #        |> redirect(to: Routes.pwa_post_path(conn, :show, post))
  #
  #      {:error, %Ecto.Changeset{} = changeset} ->
  #        render(conn, "new.html", changeset: changeset)
  #    end
  #  end
  #
  #  def show(conn, %{"id" => id}) do
  #    post = Posts.get_post!(id)
  #    render(conn, "show.html", post: post)
  #  end
  #
  #  def edit(conn, %{"id" => id}) do
  #    post = Posts.get_post!(id)
  #    changeset = Posts.change_post(post)
  #    render(conn, "edit.html", post: post, changeset: changeset)
  #  end
  #
  #  def update(conn, %{"id" => id, "post" => post_params}) do
  #    post = Posts.get_post!(id)
  #
  #    case Posts.update_post(post, post_params) do
  #      {:ok, post} ->
  #        conn
  #        |> put_flash(:info, "Post updated successfully.")
  #        |> redirect(to: Routes.pwa_post_path(conn, :show, post))
  #
  #      {:error, %Ecto.Changeset{} = changeset} ->
  #        render(conn, "edit.html", post: post, changeset: changeset)
  #    end
  #  end
  #
  #  def delete(conn, %{"id" => id}) do
  #    post = Posts.get_post!(id)
  #    {:ok, _post} = Posts.delete_post(post)
  #
  #    conn
  #    |> put_flash(:info, "Post deleted successfully.")
  #    |> redirect(to: Routes.pwa_post_path(conn, :index))
  #  end
end
