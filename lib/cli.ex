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

      File.cd!("./data")
      filename = "chunk_#{index}_" <> opts[:filename]
      StrazhaData.CsvExporter.export(filename, csv_data)
      File.cd!("../")
    end)
  end
end
