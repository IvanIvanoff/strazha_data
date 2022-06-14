defmodule StrazhaData.Speech do
  def get_speeches(sessions, size) when is_list(sessions) do
    Enum.flat_map(sessions, &get_speeches(&1, size))
  end

  def get_speeches(session, size) do
    Enum.reduce_while(0..(size - 1), [], fn i, acc ->
      url = to_url(session, i)

      result = HTTPoison.get(url)

      case result do
        {:ok, %{body: body, status_code: 200}} ->
          rows = decode_body(body)

          {:cont, rows ++ acc}

        _ ->
          # There are less than `size` speeches in that session
          {:halt, acc}
      end
    end)
  end

  defp to_url(session, i) do
    Path.join([
      "https://strazha-data2.eu-central-1.linodeobjects.com",
      "sessions/#{session}",
      "steno",
      "#{i}.json"
    ])
  end

  defp decode_body(body) do
    %{"sessionStatements" => statements} = Jason.decode!(body)

    rows =
      statements
      |> Enum.map(fn statement ->
        %{
          "parlSession" => parl_session,
          "person" => person,
          "paragraphs" => paragraphs,
          "title" => title,
          "position" => position
        } = statement

        [
          parl_session,
          person,
          paragraphs,
          title,
          position
        ]
      end)

    rows
  end
end
