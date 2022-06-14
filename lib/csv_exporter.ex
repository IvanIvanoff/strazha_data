defmodule StrazhaData.CsvExporter do
  NimbleCSV.define(CsvParser, separator: ",", escape: "\"")

  def export(filename, data) do
    data = CsvParser.dump_to_iodata(data)

    File.write!(filename, [data])
  end
end
