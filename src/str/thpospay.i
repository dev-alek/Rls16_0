/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/13/08
Author: Bakhtadze Natalya
Creation date: 08/13/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

DEFINE TEMP-TABLE {2}temp-cash-pay-list
FIELD cdpay-code AS INTEGER
FIELD curr-code AS INTEGER
FIELD frpay-code AS INTEGER
INDEX pi IS UNIQUE PRIMARY
cdpay-code curr-code
INDEX ifr frpay-code
    .

DEFINE TEMP-TABLE {2}temp-pay-names
FIELD frpay-code AS INTEGER
FIELD frpay-name AS CHARACTER
INDEX pi IS UNIQUE PRIMARY frpay-code.

&endif

&if "{1}" = "proc" &then
procedure {2}get-cash-pay-list :
define input parameter p-cp-list as character no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-dop1 as character no-undo .
define variable v-fr-code as integer no-undo .
define variable v-cp-list as character no-undo .
define buffer buf_temp-cash-pay-list for {2}temp-cash-pay-list.

do
on error undo, return error
:
  DO v-ii = 1 TO num-entries(p-cp-list, {&delim-par}):
    v-dop1 = ENTRY(v-ii, p-cp-list, {&delim-par}).
    ASSIGN
    v-fr-code = INTEGER(ENTRY(1, v-dop1, "="))
    v-cp-list = ENTRY(2, v-dop1, "=")
    NO-ERROR.
    IF v-fr-code >= 2
    AND v-fr-code <= 4 THEN DO:
      DO v-jj = 1 TO num-entries(v-cp-list, ";"):
        FIND FIRST buf_temp-cash-pay-list WHERE
                  buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), {&colon-char}))
            AND buf_temp-cash-pay-list.curr-code = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), {&colon-char})) NO-ERROR.
        IF NOT AVAILABLE buf_temp-cash-pay-list THEN DO:
          CREATE buf_temp-cash-pay-list.
          ASSIGN
          buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), {&colon-char}))
          buf_temp-cash-pay-list.curr-code = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), {&colon-char}))
          buf_temp-cash-pay-list.frpay-code = v-fr-code
          .
        END. /*IF NOT AVAILABLE buf_temp-cash-pay-list THEN DO:*/
      end. /*DO v-jj = 1 TO num-entries(v-cp-list, ";"):*/
    end. /*IF v-fr-code >= 2*/
  end. /**do v-ii*/
END. /*doe*/
end procedure. /* get-cash-pay-list */

procedure {2}get-pay-names :
define input parameter p-pay-names-list as character no-undo .
define variable v-ii as integer no-undo .
define variable v-fr-code as integer no-undo .
define variable v-name as character no-undo .
define buffer buf_temp-pay-names for {2}temp-pay-names.

do
on error undo, return error
:
  DO v-ii = 1 TO num-entries(p-pay-names-list, {&delim-par}):
    ASSIGN
    v-fr-code = v-ii + 1
    v-name = ENTRY(v-ii, p-pay-names-list, {&delim-par})
    NO-ERROR.
    IF v-fr-code >= 2
    AND v-fr-code <= 4 THEN DO:
      FIND FIRST buf_temp-pay-names WHERE
                buf_temp-pay-names.frpay-code = v-fr-code NO-ERROR.
      IF NOT AVAILABLE buf_temp-pay-names THEN DO:
        CREATE buf_temp-pay-names.
        ASSIGN
        buf_temp-pay-names.frpay-code = v-fr-code
        buf_temp-pay-names.frpay-name = v-name
        .

      END. /*IF NOT AVAILABLE buf_temp-pay-names THEN DO:*/
    END.
  END.
end.  /*doe*/
end procedure.

procedure {2}set-cash-pay-list :
define output parameter p-cash-pay-list as character no-undo .
define buffer buf_temp-cash-pay-list for {2}temp-cash-pay-list.

do
on error undo, return error
:


  FOR EACH buf_temp-cash-pay-list
  BREAK BY
  buf_temp-cash-pay-list.frpay-code:
    IF not(buf_temp-cash-pay-list.frpay-code  >= 2
         AND
         buf_temp-cash-pay-list.frpay-code  <= 4) THEN DO:
    undo, return error  substitute("Неверно заполнено соответствие для типа кассового платежа TH с кодом &1 и валютой &2"
               , buf_temp-cash-pay-list.cdpay-code
               , buf_temp-cash-pay-list.curr-code).
    END.
    IF FIRST-OF(buf_temp-cash-pay-list.frpay-code) THEN DO:
      ASSIGN
      p-cash-pay-list = substitute("&1&2&3="
                                  ,p-cash-pay-list
                                  ,{&delim-par}
                                    ,buf_temp-cash-pay-list.frpay-code) .

    END.
    ASSIGN
    p-cash-pay-list = substitute("&1&2:&3;"
                                ,p-cash-pay-list
                                  ,buf_temp-cash-pay-list.cdpay-code
                                  ,buf_temp-cash-pay-list.curr-code
                                  ) .

    IF last-OF(buf_temp-cash-pay-list.frpay-code) THEN DO:
      ASSIGN
      p-cash-pay-list = right-trim(p-cash-pay-list, ";").
    END.
  END.
  assign
  p-cash-pay-list = LEFT-TRIM(p-cash-pay-list, {&delim-par})
  p-cash-pay-list = right-TRIM(p-cash-pay-list, ";")
  .
end. /*doe*/
end procedure. /* set-cash-pay-list */


procedure {2}set-pay-names :
define output parameter p-pay-names as character no-undo .
define buffer buf_temp-pay-names for {2}temp-pay-names.
do
on error undo, return error
:
  FOR EACH buf_temp-pay-names
  BY buf_temp-pay-names.frpay-code
      :
    IF buf_temp-pay-names.frpay-code >= 2
    OR buf_temp-pay-names.frpay-code <= 2
    THEN
    ASSIGN
    p-pay-names = substitute("&1&2&3"
                                  ,p-pay-names
                                  ,{&delim-par}
                                  ,buf_temp-pay-names.frpay-name) .

  END.
  ASSIGN
  p-pay-names = left-trim(p-pay-names, {&delim-par})
  .
end.

end procedure. /* set-pay-names */


&endif


/* $Workfile$ e n d */