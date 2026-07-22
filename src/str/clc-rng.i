/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Значения допустимых диапазонов кодов в зависимости от db-num

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

*/

/*
input  my-db-num as integer - номер БД для которой надо определить валидность кода или
                                                получить диапазоны
input  mycode as integer - код который надо проверить на валидность
input p-range-type as character - тип дипазона для объекта код которого проверяетс
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION calc-range RETURNS LOGICAL(
                                     input  my-db-num as integer
                                    ,input  my-code-src as integer
                                    ,input p-range-type as character
                                    ):
define variable mycode as integer no-undo .
mycode = abs(my-code-src).
if mycode = 0 then return no.
define buffer buf_code-range for ub.code-range.
find first  buf_code-range no-lock where
        buf_code-range.db-num = my-db-num
    and buf_code-range.range-type = p-range-type
    and buf_code-range.stts = 'u'
    and buf_code-range.first-code <= mycode
    and buf_code-range.last-code >= mycode no-error .
if available buf_code-range then return yes.
find first buf_code-range no-lock where
        buf_code-range.db-num = my-db-num
    and buf_code-range.range-type = p-range-type
    and buf_code-range.stts = 'a':U
    and buf_code-range.first-code <= mycode no-error .
if p-range-type = {&gbl-fm-code}
and available buf_code-range
and (buf_code-range.stts = 'u'
    or
    mycode <  current-value(s-fmgb-code, {&db-name_schema})) then return yes.
if p-range-type = {&gbl-pn-code}
and available buf_code-range
and (buf_code-range.stts = 'u'
    or
    mycode <  current-value(s-pngb-code, {&db-name_schema})) then return yes.
if my-code-src < 0 then do:
  find first buf_code-range no-lock where
          buf_code-range.db-num = my-db-num
      and buf_code-range.range-type = p-range-type
      and buf_code-range.stts = 'f':U
      and buf_code-range.first-code <= mycode
      and buf_code-range.last-code >= mycode  no-error .
  if available buf_code-range then return yes.
end.
  find first buf_code-range no-lock where
          buf_code-range.db-num = my-db-num
      and buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= mycode
      and buf_code-range.last-code >= mycode  no-error .
if available buf_code-range then return no.
return ?.
END FUNCTION.


/* $Workfile$ e n d */