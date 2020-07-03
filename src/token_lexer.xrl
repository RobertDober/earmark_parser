Definitions.

LETTER       = [a-zA-Z]
OL_HEADER_DIGITS = ([0-9]|[0-9][0-9]|[0-9][0-9][0-9]|[0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]|[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])

BAR          = \|
BQUOTE       = `+
CLOSE_TAG    = \<\/{LETTER}+\>
COLON        = :
DASH         = -+
DQUOTE       = "
ESCAPE       = \\
HEADER       = #|##|###|####|#####|######
LACC         = \{
LBRACKET     = \[
LPAREN       = \(
OL_HEADER    = {OL_HEADER_DIGITS}\.\s+
OPEN_IAL     = \{:
RACC         = \}
RBRACKET     = \]
RPAREN       = \)
SQUOTE       = '
STAR         = \*+
TAG_PFX      = <{LETTER}+
TAG_SFX      = \s*>
TILDE        = ~+
UL_HEADER    = [-*]\s+
UNDERSCORE   = _+
VOID_TAG_SFX = \s*/>
WS           = \s+
ANY          = [^-|`"{COLON}{ESCAPE}{LACC}{LBRACKET}{LPAREN}{RACC}{RBRACKET}{RPAREN}{SQUOTE}*~_\s<>]+

Rules.

{BAR}            : {token, {bar, TokenChars, length(TokenChars)}}.
{BQUOTE}         : {token, {bquote, TokenChars, length(TokenChars)}}.
{CLOSE_TAG}      : {token, {close_tag, TokenChars, length(TokenChars)}}.
{COLON}          : {token, {colon, TokenChars, length(TokenChars)}}.
{DASH}           : {token, {dash, TokenChars, length(TokenChars)}}.
{DQUOTE}         : {token, {dquote, TokenChars, length(TokenChars)}}.
{SQUOTE}         : {token, {squote, TokenChars, length(TokenChars)}}.
{ESCAPE}         : {token, {escape, TokenChars, length(TokenChars)}}.
{HEADER}         : {token, {header, TokenChars, length(TokenChars)}}.
{LACC}           : {token, {lacc, TokenChars, length(TokenChars)}}.
{LBRACKET}       : {token, {lbracket, TokenChars, length(TokenChars)}}.
{OL_HEADER}      : {token, {ol_header, TokenChars, length(TokenChars)}}.
{LPAREN}         : {token, {lparen, TokenChars, length(TokenChars)}}.
{OPEN_IAL}       : {token, {open_ial, TokenChars, length(TokenChars)}}.
{RACC}           : {token, {racc, TokenChars, length(TokenChars)}}.
{RBRACKET}       : {token, {rbracket, TokenChars, length(TokenChars)}}.
{RPAREN}         : {token, {rparen, TokenChars, length(TokenChars)}}.
{STAR}           : {token, {star, TokenChars, length(TokenChars)}}.
{TAG_PFX}        : {token, {tag_pfx, TokenChars, length(TokenChars)}}.
{TAG_SFX}        : {token, {tag_sfx, TokenChars, length(TokenChars)}}.
{TILDE}          : {token, {tilde, TokenChars, length(TokenChars)}}.
{UL_HEADER}      : {token, {ul_header, TokenChars, length(TokenChars)}}.
{UNDERSCORE}     : {token, {underscore, TokenChars, length(TokenChars)}}.
{VOID_TAG_SFX}   : {token, {void_tag_sfx, TokenChars, length(TokenChars)}}.
{WS}             : {token, {ws, TokenChars, length(TokenChars)}}.
{ANY}            : {token, {text, TokenChars, length(TokenChars)}}.

Erlang code.

