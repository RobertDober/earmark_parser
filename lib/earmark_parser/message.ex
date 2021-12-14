defmodule EarmarkParser.Message do
  @moduledoc false

  alias EarmarkParser.Context
  alias EarmarkParser.Options

  @type message_type :: :error | :warning
  @type t :: {message_type, number, binary}
  @type ts :: list(t)
  @type container_type :: Options.t() | Context.t()

  def add_messages(container, messages),
    do: Enum.reduce(messages, container, &add_message(&2, &1))

  def add_message(container, message)

  def add_message(options = %Options{}, message) do
    %{options | messages: [message | options.messages]}
  end

  def add_message(context = %Context{}, message) do
    %{context | options: %{context.options | messages: [message | get_messages(context)]}}
  end

  def get_messages(container)
  def get_messages(%Context{options: %{messages: messages}}), do: messages

  @doc """
  For final output
  """
  def sort_messages(container) do
    container
    |> get_messages()
    |> Enum.sort(fn {_, l, _}, {_, r, _} -> r >= l end)
  end

end

# SPDX-License-Identifier: Apache-2.0
