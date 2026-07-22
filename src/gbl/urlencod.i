/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Url-encode

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/03/06
Author: Bakhtadze Natalya
Creation date: 05/03/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* Unsafe characters that must be encoded in URL's.  See RFC 1738 Sect  2.2. */
DEFINE VARIABLE url_unsafe   AS CHARACTER NO-UNDO
    INITIAL " <>~"#%~{}|~\^~~[]`":U.

/* Reserved characters that normally are not encoded in URL's */
DEFINE VARIABLE url_reserved AS CHARACTER NO-UNDO
    INITIAL "~;/?:@=&":U.


FUNCTION url-encode RETURNS CHARACTER
    (INPUT p_value AS CHARACTER,
     INPUT p_enctype AS CHARACTER) :
/****************************************************************************
Notes:            Borrowed from web/method/cgiutil

Description:      Encodes unsafe characters in a URL as per RFC 1738 section 2.2.
                  <URL:http://ds.internic.net/rfc/rfc1738.txt>, 2.2

Input Parameters: Character string to encode, Encoding option where
                  "query",
                  "cookie",
                  "default" or any specified string of characters
                  are valid.

                  In addition, all characters specified in the global variable
                  url_unsafe plus ASCII values 0 <= x <= 31 and 127 <= x <= 255
                  are considered unsafe.

Returns:          Encoded string  (unkown value is returned as blank)

Global Variables: url_unsafe, url_reserved
****************************************************************************/

DEFINE VARIABLE hx          AS CHARACTER NO-UNDO INITIAL "0123456789ABCDEF":U.
DEFINE VARIABLE encode-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE i           AS INTEGER   NO-UNDO.
DEFINE VARIABLE c           AS INTEGER   NO-UNDO.

/* Don't bother with blank or unknown  */
IF LENGTH(p_value) = 0 OR p_value = ? THEN
  RETURN "":U.

/* What kind of encoding should be used? */
CASE p_enctype:
  WHEN "query":U THEN              /* QUERY_STRING name=value parts */
    encode-list = url_unsafe + url_reserved + "+":U.
  WHEN "cookie":U THEN             /* Persistent Cookies */
    encode-list = url_unsafe + " ,~;":U.
  WHEN "default":U OR WHEN "" THEN /* Standard URL encoding */
    encode-list = url_unsafe.
  OTHERWISE
    encode-list = url_unsafe + p_enctype.   /* user specified ... */
END CASE.

/* Loop through entire input string */
ASSIGN i = 0.
DO WHILE TRUE:
  ASSIGN
    i = i + 1
    /* ASCII value of character using single byte codepage */
    c = ASC(SUBSTRING(p_value, i, 1, "RAW":U), "1251", "1251").
  IF c <= 31 OR c >= 127 OR INDEX(encode-list, CHR(c)) > 0 THEN DO:
    /* Replace character with %hh hexidecimal triplet */
    SUBSTRING(p_value, i, 1, "RAW":U) =
      "%":U +
      SUBSTRING(hx, INTEGER(TRUNCATE(c / 16, 0)) + 1, 1, "RAW":U) +
/* high */
      SUBSTRING(hx, c MODULO 16 + 1, 1, "RAW":U).             /* low digit */
    ASSIGN i = i + 2.   /* skip over hex triplet just inserted */
  END.
  IF i = LENGTH(p_value,"RAW") THEN LEAVE.
END.

RETURN p_value.

END FUNCTION.

/* $Workfile$ e n d */
