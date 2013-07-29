defmodule Atlas.Database.Client do
  import Atlas, only: [database_config: 0]
  alias Atlas.Logger

  def raw_query(string) do
    :gen_server.call :db_server, {:execute_query, string}
  end

  def raw_prepared_query(string, args) do
    :gen_server.call :db_server, {:execute_prepared_query, string, args}
  end

  def adapter do
    database_config[:adapter]
  end

  def execute_query(query_string) do
    Logger.info(String.replace(query_string, "\n", ""))
    {:ok, _count, columns, rows} = raw_query(query_string)

    keyword_lists_from_query(columns, rows)
  end

  def execute_prepared_query(query_string, args) do
    Logger.info("#{String.replace(query_string, "\n", " ")}, #{inspect args}")
    {:ok, _count, columns, rows} = raw_prepared_query(query_string, args)

    keyword_lists_from_query(columns, rows)
  end

  def keyword_lists_from_query(columns, rows) do
    Enum.map rows, Enum.zip(columns, &1)
  end

  def keyword_lists_to_records(kwlists, record) do
    Enum.map kwlists, fn row -> record.new(row) end
  end
end
