defmodule V2.EarmarkParser.Unit.TokenLexer.TokenLexerTest do
  use V2.Support.LexerTest

  describe "all the single tokens:" do
    [
      {:bar, "|"},
      {:bquote, "`"},
      {:bquote, "```"},
      {:bquote, "````"},
      {:close_tag, "</end>"},
      {:colon, ":"},
      {:dash, "--"},
      {:dash, "---"},
      {:dquote, "\""},
      {:escape, "\\"},
      {:header, "#"},
      {:header, "##"},
      {:header, "######"},
      {:lacc, "{"},
      {:lbracket, "["},
      {:lparen, "("},
      {:ol_header, "1. "},
      {:ol_header, "012345678.  "},
      {:open_ial, "{:"},
      {:racc, "}"},
      {:rbracket, "]"},
      {:rparen, ")"},
      {:squote, "'"},
      {:star, "*"},
      {:star, "**"},
      {:star, "****"},
      {:tag_pfx, "<hello"},
      {:tag_sfx, ">"},
      {:tag_sfx, " >"},
      {:tilde, "~"},
      {:tilde, "~~"},
      {:ul_header, "- "},
      {:ul_header, "-  "},
      {:ul_header, "* "},
      {:ul_header, "*  "},
      {:underscore, "_"},
      {:underscore, "___"},
      {:void_tag_sfx, "/>"},
      {:void_tag_sfx, " />"},
      {:ws, "  "},
      {:ws, " "}
    ]
    |> Enum.each(fn {token, content} ->
      quote do
        unquote do
          test ~s{token #{token} with "#{content}"} do
            expected = [{unquote(token), unquote(content), len: String.length(unquote(content))}]

            assert tokenize(unquote(content)) == expected
          end
        end
      end
    end)
  end

  describe "tokens that are scanned for each occurance" do
    [
      {:bar, "|"},
      {:colon, ":"},
      {:dquote, ~s{"}},
      {:escape, "\\"},
      {:lparen, "("},
      {:lacc, "{"},
      {:lbracket, "["},
      {:open_ial, "{:"},
      {:rparen, ")"},
      {:racc, "}"},
      {:rbracket, "]"},
      {:squote, "'"}
    ]
    |> Enum.each(fn {token, string} ->
      quote do
        unquote do
          test ~s{double token: #{token} for "#{string}"} do
            assert_multiple(unquote(token), 2, unquote(string))
          end
        end
      end
    end)
  end

  describe "tokens that are limited in length" do
    test "too long an ol is not an ol" do
      input = "1234567890.  "
      expected = [{:text, "1234567890.", len: 11}, {:ws, "  ", len: 2}]

      assert tokenize(input) == expected
    end

    test "####### The Magnificent 7" do
      input = "#######"
      expected = [{:text, input, len: 7}]

      assert tokenize(input) == expected
    end
  end

  describe "more tokens, but the same" do
    test "some text" do
      input = "c'est ça"

      expected = [
        {:text, "c", len: 1},
        {:squote, "'", len: 1},
        {:text, "est", len: 3},
        {:ws, " ", len: 1},
        {:text, "ça", len: 2}
      ]

      assert tokenize(input) == expected
    end
  end
end
