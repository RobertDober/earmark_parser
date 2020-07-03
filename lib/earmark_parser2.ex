defmodule EarmarkParser2 do
  alias EarmarkParser.Options

  @moduledoc """
  Coming Soon
  """

  @doc """
  Coming even sooner
  """
  def as_ast2(lines, options \\ %Options{})

  def as_ast2(lines, %Options{} = options) do
    _as_ast(lines, options)
  end

  def as_ast2(lines, options) when is_list(options) do
    _as_ast(lines, struct(Options, options))
  end

  def as_ast2(lines, options) when is_map(options) do
    _as_ast(lines, struct(Options, options |> Map.delete(:__struct__) |> Enum.into([])))
  end

  @crlf ~r{\n\r?}
  @default_timeout_in_ms 5000
  defp _as_ast(lines, options)

  defp _as_ast(lines, options) when is_list(lines) do
    lines
    |> Stream.zip(Stream.iterate(1, &(&1 + 1)))
    |> Enum.to_list()
    |> _pflat_map(&_tokenize_numbered_line/1, options.timeout || @default_timeout_in_ms)
  end

  defp _as_ast(lines, options) when is_binary(lines) do
    lines
    |> String.split(@crlf)
    |> _as_ast(options)
  end

  defp _pflat_map(collection, func, timeout \\ @default_timeout_in_ms) do
    collection
    |> Enum.map(fn item -> Task.async(fn -> func.(item) end) end)
    |> Task.yield_many(timeout)
    |> Enum.flat_map(&_join_pmap_results_or_raise(&1, timeout))
  end

  defp _join_pmap_results_or_raise(yield_tuples, timeout)

  defp _join_pmap_results_or_raise({_task, {:ok, result}}, _timeout) do
    result
  end

  defp _join_pmap_results_or_raise({task, {:error, reason}}, _timeout) do
    raise(Error, "#{inspect(task)} has died with reason #{inspect(reason)}")
  end

  defp _join_pmap_results_or_raise({task, nil}, timeout) do
    raise(
      Error,
      "#{inspect(task)} has not responded within the set timeout of #{timeout}ms, consider increasing it"
    )
  end

  defp _tokenize_numbered_line({line, lnb}) do
    [{:nl, "", len: 0, lnb: lnb} | EarmarkParser.Lexer.tokenize(line, lnb: lnb)]
  end
end
