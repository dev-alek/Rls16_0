/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

{1} - таблица , хранящая настройки - какие коды посылать - shop или временна Коды товаров в спуле NCR-GM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/06/03
Author: Bakhtadze Natalya
Creation date: 10/06/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure ncr-gdsc :
define output parameter IBM-good-code as character no-undo .
define output parameter IBM-good-code-2 as character no-undo .
define output parameter is-sc as logical no-undo .
define output parameter p-taracode-bc as character no-undo .

define variable v-taracode-bc as character no-undo .
define variable v-type as character no-undo .
define variable v-bc-buf as character no-undo .
define variable iii as integer no-undo .

  do
  on error undo, return error
  :

    if cash-gds.b-str = "" then do:
      assign
      b_code = string(cash-gds.b-code,'>>>>>>>>>>>>9').
      if  LOOKUP( {&weight}, cash-gds.unit-type ) = 0 or cash-gds.unit-base <> cash-gds.unit-cli then do:
        /*  НЕвесовой товар или товар с доп ед изм*/
        if (({1}.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            ({1}.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:

          RUN gen-bc( input cash-gds.b-code, output bar_code ).
          IBM-good-code  = fill( " ", 13 - length( trim( bar_code ) ) ) + trim( bar_code ).

        end.
        if (({1}.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            ({1}.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          IBM-good-code-2 = b_code.
        end.
      end.
    end.
    else do:
      if cash-gds.b-str begins "*" then cash-gds.b-str = left-trim(cash-gds.b-str, "*").
      IBm-good-code = ( if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
                          (LOOKUP( {&weight}, cash-gds.unit-type ) > 0
                           or
                           cash-gds.bc-on-type = {&loc-pg-code})
                        then string( integer( cash-gds.b-str ), ">>>>>>>>>>>>9" )
                        else string( fill( " ", 13 - length( trim( cash-gds.b-str ) ) ) +
                                    trim( cash-gds.b-str ), "9999999999999" ) ).
       if action <> "D":U then do:
        is-sc = no.
        find first request_prod-bc no-lock where
                  request_prod-bc.b-str = cash-gds.b-str no-error .
        if not avail request_prod-bc then do :
          if mask_s-c <> "" then do :
            iii_ :
            do iii = 1 to num-entries(mask_s-c) :
              if length(cash-gds.b-str) = (num-entries(entry(iii, mask_s-c), '*') - 1) then do :
                v-bc-buf = trim(entry(1, entry(iii, mask_s-c), '*') + cash-gds.b-str).
                find first request_prod-bc no-lock where request_prod-bc.b-str = v-bc-buf no-error .
                if available request_prod-bc then leave iii_ .
              end. /*  if length(v-bc-buf) =  */
            end. /* do iii = 1 to num-entries(mask_s-c) */
          end.  /* if mask_s-c <> "" */
        end.
        if avail request_prod-bc then do :
          if LOOKUP( {&weight}, cash-gds.unit-type ) > 0 then do:
            { gbl/prodbcat.i request_prod-bc 'scaleable=request' is-sc no-error }
          end.
          if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
             LOOKUP( {&weight}, cash-gds.unit-type ) > 0
             then do:
            /*сформируем шаблон для кассы*/

            { str/bc-gnrti.i ncrsc  "decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U)"  IBm-good-code }
            /*
            {1} - bc - для формирования собственного бар-кода, pl - для бар-кода складского места
            ncrsc - весовой префикс NCR
            {2} - переменная - строка для бар-кода
            {3} - переменная - сгенерированый бар-код
            {4} - без message
            */
          end.
          if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
             cash-gds.bc-on-type = {&loc-pg-code}
             then do:
            /*сформируем шаблон для кассы*/

            { str/bc-gnrti.i ncrpg  "decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U)"  IBm-good-code }
            /*
            {1} - bc - для формирования собственного бар-кода, pl - для бар-кода складского места
            ncrpg - штучный префикс NCR
            {2} - переменная - строка для бар-кода
            {3} - переменная - сгенерированый бар-код
            {4} - без message
            */
          end.
        end. /*avail request_prod-bc*/
      end. /*not D*/
    end. /*prod-bc*/
    if LOOKUP( {&weight}, cash-gds.unit-type ) > 0
    and (LOOKUP( {&divisional}, cash-gds.unit-cli-type ) > 0
          or
          LOOKUP( {&weight}, cash-gds.unit-cli-type ) > 0)
    then do:
        run bc-oattr_value in this-procedure ( input cash-gds.b-code
                                            ,input {&attr-taracode-bc}
                                            ,input {&shop}
                                            ,input i-obj-code
                                            ,output v-taracode-bc
                                            ,output v-type) no-error.
        if not error-status:error
        and v-taracode-bc <> '' then do:
          is-sc = yes.
          p-taracode-bc = v-taracode-bc.
        end.
    end.
  end. /*doe*/

end procedure. /* ncr-gdsc */



/* $Workfile$ e n d */