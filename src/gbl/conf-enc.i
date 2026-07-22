/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

проверка правильности кодирования параметров и ключа БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* функция реверсии последовательности символов в строке */
Function reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .

   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.

procedure check-enc.

  define input  parameter p-db-num    as integer   no-undo .  /* Номер БД */
  define input  parameter p-db-key    as character no-undo .  /* ключ БД */
  define input  parameter p-code      as character no-undo .  /* метка ключа, пустое значение используется дл
                                                                 идентификации вызова для кодирования имени базы */
  define input  parameter p-value     as character no-undo .  /* значение параметра */
  define input  parameter p-beg-date  as date      no-undo .  /* дата начала действия параметра */
  define input  parameter p-end-date  as date      no-undo .  /* дата окончания действия параметра */
  define input  parameter p-enc-value as character no-undo .  /* кодированное значение */
  define output parameter p-answer    as logical   no-undo .  /* yes - если значение закодировано правильно */

  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .

  if p-db-num <> 0
    and p-db-key = "":U
  then do:
    /* это означает, что УБД отключена */
    assign
      p-answer = true
    .
    return.
  end.

  if p-db-key = "unload-db":U then do:
    /* это означает, что БД выгружается из копии */
    assign
      p-answer = true
    .
    return.
  end.

  if p-code = ""  then do:
    /* требуется кодированное значение ключа базы */
    assign
      tmp = string( p-db-num ) + reverse (p-db-key).
    .
  end.
  else do:
    assign
      tmp = string( p-db-num )
            + trim( p-db-key )
            + reverse( trim( p-code ) )
            + reverse( trim( p-value ) )
            + reverse( string( p-beg-date, "99.99.9999" ) )
            + reverse( string( p-end-date, "99.99.9999" ) )
    .
  end.

  run pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .

  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.

  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.

end.             /* check-enc */

{ adm/pswd-enc.i
  &proc-name=pswd-enc
}

/* $Workfile$ e n d */