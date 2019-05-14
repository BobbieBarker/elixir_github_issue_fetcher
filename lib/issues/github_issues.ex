defmodule Fetcher.GithubIssues do
  @github_url Application.get_env(:fetcher, :github_url)
  def fetch(user_agent, user, project) do
    issues_url(user, project)
    |> HTTPoison.get([{"User-agent", user_agent}])
    |> handle_response
    |> error_catcher
  end

  def issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    {
      status_code |> check_for_error(),
      body |> Poison.Parser.parse!(%{})
    }
  end

  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error


  defp error_catcher({:ok, body}), do: body
  defp error_catcher({:error, error}) do
    IO.puts "Error Fetching from github: #{error["message"]}"
    System.halt(2)
  end
end
