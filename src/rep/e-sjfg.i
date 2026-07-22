/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функция определение строковых значений для товара при печати журнала продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION get-strokes
RETURNS CHARACTER
  ( buffer loc-sj-goods for sj-goods,
    input name-len as integer,
    input prod-len as integer,
    input-output loc-namebuf1 as char,
    input-output loc-namebuf2 as char,
    input-output loc-prodbuf1 as char,
    input-output loc-prodbuf2 as char) :

    def var for-name as char no-undo.
    if loc-sj-goods.node-name <> ""
    then for-name = loc-sj-goods.name + "\" + loc-sj-goods.node-name.
    else for-name = loc-sj-goods.name.
    loc-namebuf1 = breakstr(for-name,
                             name-len,
                             input-output loc-namebuf1,
                             input-output loc-namebuf2).
    if v-curr-r-b = {&r-b-base} and my-Set_Val_Type = {&v-all} then  do:
      loc-prodbuf1 = breakstr(loc-sj-goods.prod-name,
                               prod-len,
                               input-output loc-prodbuf1,
                               input-output loc-prodbuf2).
    end.
    else do:
      loc-prodbuf1 = breakstr(loc-sj-goods.prod-name,
                               prod-len,
                               input-output loc-prodbuf1,
                               input-output loc-prodbuf2).
    end.


  RETURN loc-namebuf1.   /* Function return value. */

END FUNCTION.

/* $Workfile$ e n d */