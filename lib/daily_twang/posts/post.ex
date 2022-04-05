defmodule DailyTwang.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    timestamps()
    field :title, :string
    field :source, :string
    field :link, :string
    field :updated, :naive_datetime
    field :uploaded_at, :string
  end

  def create_changeset(attrs) do
    %DailyTwang.Posts.Post{}
    |> cast(attrs, [:source, :link, :uploaded_at, :updated])
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:source, :link, :uploaded_at, :updated])
    |> validate_required([])
  end
end
