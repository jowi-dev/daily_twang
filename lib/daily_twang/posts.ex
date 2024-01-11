defmodule DailyTwang.Posts do
  @moduledoc """
  The Posts context.
  """

  alias DailyTwang.Posts.Post
  alias FeederEx
  alias Timex
  alias HTTPoison

  @feeds [
    "https://cointelegraph.com/rss",
    "https://hnrss.org/frontpage",
    "https://elixirstatus.com/rss",
    "https://www.aljazeera.com/xml/rss/all.xml"
    # "https://www.eink.com/rss.php?feed_type=1"
  ]

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%FeederEntry{}, ...]

  """
  def list_posts do
    case Cachex.get(:chatter, "messages") do
      {:ok, nil} ->
        Cachex.put(:chatter, "messages", get_fresh_list(), ttl: :timer.hours(12))

      {:ok, list} ->
        list
    end

    get_fresh_list()
  end

  defp get_fresh_list() do
    @feeds
    |> Enum.map(&fetch_results/1)
    |> List.flatten()
    |> Enum.map(&parse_feed/1)
    |> Enum.sort(&compare_dates/2)
    |> Enum.filter(&is_struct/1)
  end

#  defp get_cached_messages do
#  end

  defp fetch_results(url) do
    source_name = get_source_name(url)

    with {:ok, %{entries: entries}, _} <-
           HTTPoison.get!(url)
           |> Map.get(:body)
           |> FeederEx.parse() do
      Enum.map(entries, &Map.put(&1, :source, source_name))
    end
  end

  # Gets the given content from a URL and parses it in readable format
  defp parse_feed(entry) when is_map(entry) do
    string_date = Map.get(entry, :updated)

    date = parse_date(string_date)
    {:ok, format} = Timex.format(date, "{YYYY}-{0M}-{0D}")

    %Post{
      link: Map.get(entry, :link),
      source: Map.get(entry, :source),
      title: Map.get(entry, :title),
      uploaded_at: format,
      updated: date,
      id: UUID.uuid1()
    }
  end

  defp parse_feed(entry), do: IO.inspect(entry, label: "entry", pretty: true)

  defp parse_date(date) do
    cond do
      matches_format?(date, "%a, %d %b %Y %T %z") ->
        parse_format(date, "%a, %d %b %Y %T %z")

      matches_format?(date, "%d %b %Y %T %z") ->
        parse_format(date, "%d %b %Y %T %z")

      true ->
        # This is bad fix it
        parse_format("0" <> date, "%d %b %Y %T %z")
    end
  end

  defp matches_format?(date, format) do
    case Timex.parse(date, format, :strftime) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp parse_format(date, format) do
    with {:ok, parsed} <- Timex.parse(date, format, :strftime) do
      parsed
    end
  end

  defp compare_dates(%{updated: date1}, %{updated: date2}) do
    0 >= Timex.compare(date2, date1)
  end
  
  defp compare_dates(_, _), do: false

  defp get_source_name(url) do
    cond do
      String.starts_with?(url, "https://") -> String.split(url, "https://")
      String.starts_with?(url, "http://") -> String.split(url, "http://")
    end
    |> List.last()
    |> String.split(".")
    |> case do
      ["www" | tail] -> tail
      result -> result
    end
    |> List.first()
    |> String.downcase()
    |> String.to_atom()
  end

  def change_post(post) do
    Post.changeset(post, %{})
  end
end
