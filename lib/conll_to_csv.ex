defmodule StrazhaData.ConllToCsv do
  def run() do
    # Drop the first line
    file_stream =
      File.stream!("./data/conll/extended_ner.conll")
      |> Stream.drop(1)
      |> Stream.drop(-1)

    {rows, _sentence_idx, _tag} =
      Enum.reduce(file_stream, {[], 0, "O"}, fn line, {acc, sentence_idx, previous_tag} ->
        case line_to_csv_row(line, previous_tag) do
          :begin_new_sentence ->
            {acc, sentence_idx + 1, "O"}

          %{word: word, tag: tag, is_end_tag: is_end_tag} ->
            row = [sentence_idx, word, tag]
            {[row] ++ acc, sentence_idx, if(is_end_tag, do: "O", else: tag)}
        end
      end)

    rows = rows |> Enum.reverse()
    IO.inspect(Enum.take(rows, 100))
    headers = ["sentence_idx", "word", "tag"]

    StrazhaData.CsvExporter.export("ner.csv", [headers] ++ rows)
  end

  defp line_to_csv_row("\n", _previous_tag) do
    :begin_new_sentence
  end

  defp line_to_csv_row(line, previous_tag) do
    [_author, _doc_number, _word_in_sentence_num, word, _, _, _, _, _, _, tag, _] =
      String.split(line, " ", trim: true)

    %{tag: tag, is_end_tag: is_end_tag} = tag(tag, previous_tag)
    %{word: word, tag: tag, is_end_tag: is_end_tag}
  end

  defp tag(tag, previous_tag) do
    case tag do
      "*" when previous_tag == "O" -> %{tag: "O", is_end_tag: true}
      "*" when previous_tag != "O" -> %{tag: continue_tag(previous_tag), is_end_tag: false}
      "*)" when previous_tag != "O" -> %{tag: continue_tag(previous_tag), is_end_tag: true}
      "*)" when previous_tag == "O" -> %{tag: "O", is_end_tag: true}
      "(PER*" -> %{tag: "B-PER", is_end_tag: false}
      "(PER)" -> %{tag: "B-PER", is_end_tag: true}
      "(ORG*" -> %{tag: "B-ORG", is_end_tag: false}
      "(ORG)" -> %{tag: "B-ORG", is_end_tag: true}
      "(LOC*" -> %{tag: "B-LOC", is_end_tag: false}
      "(LOC)" -> %{tag: "B-LOC", is_end_tag: true}
      "(OTH*" -> %{tag: "O", is_end_tag: true}
      "(OTH)" -> %{tag: "O", is_end_tag: true}
    end
  end

  defp continue_tag(tag) do
    tag |> String.replace("B-", "I-")
  end
end
