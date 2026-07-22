/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Коды товары в спуле IBM-POS

{1} - таблица , хранящая настройки - какие коды посылать - shop или временна

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/24/03
Author: Bakhtadze Natalya
Creation date: 06/24/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure ibm-gdsc :
define input  parameter p-zeros         as logical no-undo .
define output parameter IBM-good-code as character no-undo .
define output parameter IBM-good-code-2 as character no-undo .
define output parameter IBM2-short      as character no-undo .

define variable v-delim as character no-undo .
define variable v-format-str-16 as character no-undo .

  do
  on error undo, return error
  :
    if p-zeros then do:
      assign
      v-delim = '0'
      v-format-str-16 =  "9999999999999999"
      .
    end.
    else do:
      assign
      v-delim = {&space-char}
      v-format-str-16 =  ">>>>>>>>>>>>>>>9"
      .
    end.

    if cash-gds.b-str = "" then do:
      assign
      b_code = string( cash-gds.b-code, v-format-str-16 ) . /* лок. код */
      if  LOOKUP( {&weight}, cash-gds.unit-type ) = 0
      or cash-gds.unit-base <> cash-gds.unit-cli
      or (LOOKUP( {&weight}, cash-gds.unit-type ) > 0  and not {1}.cd-sc-base)
      then
      /*  НЕвесовой товар или товар с доп ед изм или весовой и весовые коды не ходят*/
      do:
        if (({1}.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            ({1}.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:

          RUN gen-bc( input cash-gds.b-code, output bar_code ).
          iBM2-short = bar_code.
&if "{2}" = "left" &then
          IBM-good-code  = string( trim( bar_code ) + fill( v-delim, 16 - length( trim( bar_code ) ) ), "9999999999999999" ) .
&else
          IBM-good-code  = string( fill( v-delim, 16 - length( trim( bar_code ) ) ) + trim( bar_code ), "9999999999999999" ) .
&endif
        END. /* на кассу посылаются bc*/
        if (({1}.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            ({1}.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          IBM-good-code-2 = b_code.
&if "{2}" = "left" &then
          IBM-good-code-2  =  trim( IBM-good-code-2 ) + fill( v-delim, 16 - length( trim( IBM-good-code-2 ) ) ) .
&endif
        end.
      end.
    end.
    else do:
      IBm-good-code =
      ( if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
        (LOOKUP( {&weight}, cash-gds.unit-type ) > 0
         or
         cash-gds.bc-on-type = {&loc-pg-code})
      then string( decimal( cash-gds.b-str ), v-format-str-16)
      else string( fill( v-delim, 16 - length( trim( cash-gds.b-str ) ) ) + trim( cash-gds.b-str ), "9999999999999999" ) ).
&if "{2}" = "left" &then
      IBM-good-code  =  trim( IBM-good-code ) + fill( v-delim, 16 - length( trim( IBM-good-code ) ) ) .
&endif
      /* bar_code */
    end.
  end.
end procedure. /* ibm-gdsc */

/* $Workfile$ e n d */