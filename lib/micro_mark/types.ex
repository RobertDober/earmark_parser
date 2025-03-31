defmodule MicroMark.Types do
  @moduledoc ~S"""
  All types for the MicroMark parser
  """

  defmacro __using__(_opts \\ []) do
    quote do
      @type ast :: list(ast_node())
      @type ast_node ::
              {:error, binary()}
              | {block_symbol(), ast()}
              | binary()
              | IO.chardata()

      @type block_symbol ::
              :emph
              | :section

      @type binaries :: list(binary())
      @type binary? :: maybe(binary())

      @type continuation :: {ast(), binary()}

      @type either(lht, rht) :: {:ok, lht} | {:error, rht}

      @type maybe(t) :: nil | t

      @type natural :: non_neg_integer()
      @type positive :: pos_integer()

      @type result :: either(ast(), binaries())

      @type unary_fn :: (any() -> any())
    end
  end
end

# SPDX-License-Identifier: AGPL-3.0-or-later
