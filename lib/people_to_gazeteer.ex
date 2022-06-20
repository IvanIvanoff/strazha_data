defmodule StrazhaData.PeopleToGazeteer do
  def run() do
    # Drop the first line
    file_stream =
      File.stream!("./data/people/people.csv")
      |> Stream.drop(1)

    rows =
      Enum.flat_map(file_stream, fn line ->
        [first, middle, last, _slug] = String.split(line, ",", trim: true)

        [
          [first],
          [last],
          [first <> " " <> last],
          [first <> " " <> middle <> " " <> last]
        ]
      end)
      |> Enum.uniq()

    headers = ["name"]

    StrazhaData.CsvExporter.export("people_gazeteer.csv", [headers] ++ rows)
  end
end
