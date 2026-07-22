/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Тело процедуры формирования бар-кода

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/01
Author: Dmitry Ukhanov
Creation date: 04/12/01

*/
/*
{1} - bc - для формирования собственного бар-кода, pl - для бар-кода складского места
{2} - переменная - строка для бар-кода
{3} - переменная - сгенерированый бар-код
{4} - без message
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


  define variable tmp-str{&vssseq}  as character no-undo.
  define variable tmp-num{&vssseq}  as character no-undo.
  define variable i{&vssseq}        as integer   no-undo.
  define variable sum{&vssseq}      as integer   no-undo.
  define variable len-code{&vssseq} as integer   no-undo.
  define variable varcont{&vssseq}  as logical   initial yes no-undo.

  /* состыковка префикса и внутреннего кода */
  CASE {1}-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str{&vssseq} = string( {2}, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str{&vssseq} = string( {2}, "9999999" )
      .
    end.
    OTHERWISE DO:
       &IF "{4}" = "" &THEN
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " {1}-frmt " ."
        view-as alert-box error.
        return error.
       &ELSE
          assign {3}     = ""
                 varcont{&vssseq} = no.
       &ENDIF
    END.
  END CASE.
  if varcont{&vssseq} = yes then do:
    if integer( substring( tmp-str{&vssseq}, 1, length( {1}-pfx ) ) ) <> 0
    then do:
      &IF "{4}" = "" &THEN
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " {2}
        view-as alert-box error title "подрезание кода".
      return error.
      &ELSE
         assign {3}     = ""
                varcont{&vssseq} = no.
      &ENDIF
    end.
    else do:
      assign
        {3} = {1}-pfx + substring( tmp-str{&vssseq}, length( {1}-pfx ) + 1, length( tmp-str{&vssseq} ) - length( {1}-pfx ) )
        len-code{&vssseq}    = length( {3} )
      .

      /* подсчет контрольной суммы */
      define variable v-sum-char{&vssseq} as character no-undo .
      assign
        sum{&vssseq} = 0
      .
      do i{&vssseq} = 1 to len-code{&vssseq} by 2
      :
        assign
          v-sum-char{&vssseq} = substr({3}, len-code{&vssseq} - i{&vssseq} + 1, 1)
        .
        if v-sum-char{&vssseq} < "0"
        or v-sum-char{&vssseq} > "9"
        then do:
          &IF "{4}" = "" &THEN
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " {2} skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
          &ELSE
             assign {3}     = ""
                    varcont{&vssseq} = no.
          &ENDIF
        end.
        assign
          sum{&vssseq} = sum{&vssseq} + integer(v-sum-char{&vssseq})
        .
      end.
      if varcont{&vssseq} = yes then do:
        assign
          sum{&vssseq} = sum{&vssseq} * 3
        .
        do i{&vssseq} = 2 to len-code{&vssseq} by 2
        :
          assign
            v-sum-char{&vssseq} = substr({3}, len-code{&vssseq} - i{&vssseq} + 1, 1)
          .

          if v-sum-char{&vssseq} < "0"
          or v-sum-char{&vssseq} > "9"
          then do:
            &IF "{4}" = "" &THEN
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " {2} skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
            &ELSE
               assign {3}     = ""
                      varcont{&vssseq} = no.
            &ENDIF
          end.
          assign
            sum{&vssseq} = sum{&vssseq} + integer(v-sum-char{&vssseq})
          .
        end.
        if varcont{&vssseq} = yes then do:
           if sum{&vssseq} mod 10 = 0 then do:
             assign
               {3} = {3} + '0'
             .
           end.
           else do:
             assign
               {3} = {3} + string(10 - sum{&vssseq} mod 10)
             .
           end.
        end.
      end. /*varcont{&vssseq} = yes*/
    end.
  end. /*varcont{&vssseq} = yes*/

  /* $Workfile$ e n d */