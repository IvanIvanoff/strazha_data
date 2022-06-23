defmodule StrazhaData.ParliamentGroup do
  # /46-ima-takuv-narod/index.json
  @base_url "https://strazha-data2.eu-central-1.linodeobjects.com/parl-groups"
  def run() do
    get_data()
  end

  def list_parliament_groups() do
    get_data()[:parliament_group_slugs]
  end

  def get_members_of_parliament() do
    # get_data()[:parliament_group_slugs]

    # |> Enum.map(& &1["slug"])

    data =
      ["47-ima-takuv-narod"]
      |> Enum.map(fn slug ->
        url = Path.join([@base_url, slug, "index.json"])

        result = HTTPoison.get(url)

        case result do
          {:ok, %{body: body, status_code: 200}} ->
            %{"persons" => persons} = Jason.decode!(body)

            Enum.map(persons, fn p ->
              %{
                first_name: p["firstName"],
                middle_name: p["middleName"],
                last_name: p["lastName"],
                # slug: p["slug"],
                email: p["email"] |> hd()
              }
            end)

          error ->
            raise(error)
        end
      end)
      |> List.flatten()

    headers = ["firstName", "middleName", "lastName", "email"]
    rows = Enum.map(data, &[&1.first_name, &1.middle_name, &1.last_name, &1.email])

    StrazhaData.CsvExporter.export("itn_members_with_emails.csv", [headers] ++ rows)
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
