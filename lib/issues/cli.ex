defmodule Fetcher.CLI do
  @default_count 4
  import Fetcher.TableFormatter, only: [print_table_for_columns: 2]
  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generationg a table of the last _n_ issues
  in a github project
  or a weather update from a noaa weather station
  """

  def main(argv) do
    argv
    |>parse_args
    |>process
  end

  def parse_args(argv) do
    OptionParser.parse(argv, switches: [
      help: :boolean,
      weather: :boolean,
      issue: :boolean
    ],
    aliases: [
      h: :help,
      w: :weather,
      i: :issue
    ])
    |> parse()
  end
# update this to throw an error/handle no flag being sent.
  defp parse({ [issue: true], [user_agent, user, project, count], _ }), do: {:issue, user_agent, user, project, String.to_integer(count)}
  defp parse({ [issue: true], [user_agent, user, project], _ }), do: {:issue, user_agent, user, project, @default_count}

  defp parse({ [weather: true], [station_code], _ }), do: {:weather, station_code}
  defp parse({ [help: true], _, _ }), do: :help
  defp parse({ [], _, _ }), do: :help
  defp parse({ _, [], _ }), do: :help
  defp parse({ _, _, _ }), do: :help

  def process(:help) do
    IO.puts """
    Fetch github issues for a user from a project.
    usage: fetcher -i <github_user_agent> <user> <project> [ count | #{@default_count}]
    example: ./fetcher -i chad@polarity.io pragdave earmark

    Fetch a weather update from a NOAA weather station.
    usage: fetcher -w <noaa_station code>
    example: ./fetcher -w PABR

    A list of NOAA station codes can be found here:
    https://www.weather.gov/arh/stationlist
    """
    System.halt(0)
  end

  def process({:issue, user_agent, user, project, count}) do
    Fetcher.GithubIssues.fetch(user_agent, user, project)
    |> sort_into_descending_order()
    |> last(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  def process({:weather, station_code }) do
    Fetcher.Weather.fetch(station_code)
    |> print_table_for_columns(["observed on", "temp", "weather", "wind"])
  end

  def sort_into_descending_order(issues) do
    issues
    |> Enum.sort(fn i1, i2 ->
      i1["created_at"] >= i2["created_at"]
    end)
  end

  def last(list, count) do
    list
    |> Enum.take(count)
    |> Enum.reverse
  end
end
