defmodule DailyTwang.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias DailyTwang.Repo

  alias DailyTwang.Posts.Post
  alias FeederEx
  alias HTTPoison

  @feeds [
    "https://cointelegraph.com/rss",
    "https://hnrss.org/frontpage",
    "http://america.aljazeera.com/content/ajam/articles.rss"
  ]

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%FeederEntry{}, ...]

  """
  def list_posts do
    @feeds
    |> Enum.map(&parse_feed(&1))
    |> List.flatten()
    |> Enum.shuffle()
  end

  # Gets the given content from a URL and parses it in readable format
  defp parse_feed(url) do
    source_name = get_source_name(url)

    {:ok, results, _} =
      HTTPoison.get!(url)
      |> Map.get(:body)
      |> FeederEx.parse()

    Enum.map(results.entries, &Map.put(&1, :source, source_name))
  end

  defp get_source_name(url) do
    cond do
      String.starts_with?(url, "https://") -> String.split(url, "https://")
      String.starts_with?(url, "http://") -> String.split(url, "http://")
    end
    |> List.last()
    |> String.split(".")
    |> List.first()
    |> String.downcase()
    |> String.to_atom()
  end
end
