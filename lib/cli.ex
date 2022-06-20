defmodule StrazhaData.Cli do
  def main(args) do
    options = [switches: [filename: :string, mode: :string]]

    {opts, _, _} = OptionParser.parse(args, options)

    case opts[:mode] do
      "speeches" -> get_speeches(opts)
      "members_of_parliament" -> get_members_of_parliament(opts)
    end
  end

  defp get_members_of_parliament(opts) do
    members_of_parliament = StrazhaData.ParliamentGroup.get_members_of_parliament()

    data =
      Enum.map(members_of_parliament, fn map ->
        [map.first_name, map.middle_name, map.last_name, map.slug]
      end)

    headers = ["first_name", "middle_name", "last_name", "slug"]
    csv_data = [headers] ++ data

    File.cd!("./data/people")
    filename = opts[:filename]
    StrazhaData.CsvExporter.export(filename, csv_data)
    File.cd!("../../")
  end

  defp get_speeches(opts) do
    sessions = StrazhaData.Session.get_session_slugs()

    sessions
    |> tap(fn sessions -> IO.puts("Start exporting data for #{length(sessions)} sessions") end)
    |> Enum.chunk_every(10)
    |> tap(fn chunks -> IO.puts("Exporting data for #{length(chunks)} chunks of 10 sessions") end)
    |> Enum.with_index(1)
    |> Enum.each(fn {sessions_chunk, index} ->
      IO.puts("Start exporting sessions chunk #{index}")

      data = StrazhaData.Speech.get_speeches(sessions_chunk, 200)

      data =
        Enum.map(data, fn row ->
          [parl_session, person, paragraphs, title, position] = row
          [parl_session, person, Enum.join(paragraphs, "\n"), title, position]
        end)

      headers = [
        "parl_session",
        "person",
        "speech",
        "title",
        "position"
      ]

      csv_data = [headers] ++ data

      File.cd!("./data/speeches")
      filename = "chunk_#{index}_" <> opts[:filename]
      StrazhaData.CsvExporter.export(filename, csv_data)
      File.cd!("../../")
    end)
  end
end
