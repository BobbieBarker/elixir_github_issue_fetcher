defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generationg a table of the3 last _n_ issues
  in a github project
  """

  def run(argv) do
    argv
    |>parse_args
    |>process
  end

  @doc """
  `argv` can be -h or --help which returns :help.
  Otherwise it is a github user name projecrt name, and (optionally)
  the number of entries to format

  Return a tuple of `{user, project, count}`, or `:help` if help was given.
  """

  def parse_args(argv) do
    OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    |> elem(1)
    |> parse()
  end

  defp parse([user, project, count]) do {user, project, String.to_integer(count)}
  defp parse([user, project]) do {user, project, @default_count}
  defp parse(_) do :help

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count}]
    """
    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
  end

end
