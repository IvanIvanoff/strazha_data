defmodule Strazha.ParliamentGroup do
  # /46-ima-takuv-narod/index.json
  @base_url "https://strazha-data2.eu-central-1.linodeobjects.com/parl-groups"
  def run() do
    get_data()
  end

  def get_members_of_parliament() do
    get_data()[:parliament_group_slugs]
    |> Enum.map(& &1["slug"])
    |> Enum.map(fn slug ->
      url = Path.join([@base_url, slug, "index.json"])

      result = HTTPoison.get(url)

      case result do
        {:ok, %{body: body, status_code: 200}} ->
          %{"persons" => persons} = Jason.decode!(body)

          Enum.map(persons, fn p ->
            %{
              first: p["firstName"],
              middle: p["middleName"],
              last: p["lastName"],
              slug: p["slug"]
            }
          end)

        error ->
          raise(error)
      end
    end)
  end

  defp get_data() do
    url = Path.join([@base_url, "index.json"])
    result = HTTPoison.get(url)

    case result do
      {:ok, %{body: body, status_code: 200}} ->
        %{"parlGroups" => parl_groups, "parliaments" => parliaments} = Jason.decode!(body)

        %{
          parliament_group_slugs: parl_groups,
          parliaments: parliaments
        }

      error ->
        error
    end
  end
end
