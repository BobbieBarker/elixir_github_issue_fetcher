# https://www.weather.gov/arh/stationlist
defmodule Fetcher.Weather do
  import SweetXml
  @noaa_url Application.get_env(:fetcher, :noaa_url)
  def fetch(station_code) do
    weather_url(station_code)
    |> HTTPoison.get()
    |> handle_response
    |> error_catcher
  end

  def weather_url(station_code) do
    "#{@noaa_url}/#{station_code}.xml"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    {
      status_code |> check_for_error(),
      body |> parse_response
    }
  end

  def parse_response(body) do
    [%{"observed on" => getTime(body), "weather" => getWeather(body), "temp" => getTemp(body), "wind" => getWind(body)}]
  end

  defp getTime(body), do: xpath(body, ~x"//current_observation/observation_time_rfc822/text()"s)
  defp getWeather(body), do: xpath(body, ~x"//current_observation/weather/text()"s)
  defp getTemp(body), do: xpath(body, ~x"//current_observation/temp_f/text()"s)
  defp getWind(body), do: xpath(body, ~x"//current_observation/wind_string/text()"s)

  defp check_for_error(200), do: :ok
  defp check_for_error(_), do: :error

  defp error_catcher({:ok, body}), do: body
  defp error_catcher({:error, error}) do
    IO.puts "Error Fetching from NOAA: #{error["message"]}"
    System.halt(2)
  end
end
