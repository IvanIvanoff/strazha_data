defmodule StrazhaData.Session do
  @base_url "https://strazha-data2.eu-central-1.linodeobjects.com/sessions"
  @year_to_id %{
    2022 => "61aa046720e632bbcca6e9ce",
    2021 => "61584a8247fa1c1194721321",
    2017 => "60d682dd1cce8d7b4edc9a93",
    2016 => "60d682dd1cce8d7b4edc8f9c",
    2015 => "60d682dd1cce8d7b4edc8f9c",
    2013 => "60d682dc1cce8d7b4edc73d3",
    2009 => "60d682dc1cce8d7b4edc6c25",
    2008 => "60d682dc1cce8d7b4edc6c25",
    2007 => "60d682dc1cce8d7b4edc6c25",
    2006 => "60d682dc1cce8d7b4edc6c25",
    2005 => "60d682dc1cce8d7b4edc6c25"
  }

  def get_session_slugs() do
    for year <- Map.keys(@year_to_id), month <- 1..12 do
      get_sessions(year, month)
    end
    |> List.flatten()
  end

  def get_sessions(year, month) do
    url = Path.join([@base_url, @year_to_id[year]]) <> "-#{year}-#{month - 1}.json"

    result = HTTPoison.get(url)

    case result do
      {:ok, %{status_code: 200, body: body}} ->
        %{"parlSessions" => parl_sessions} = Jason.decode!(body)

        parl_sessions
        |> Enum.map(& &1["slug"])

      _ ->
        []
    end
  rescue
    _ ->
      []
  end
end
