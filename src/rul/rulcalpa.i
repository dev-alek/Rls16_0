/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции для редактировани параметров вызова правил

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/05/08
Author: Bakhtadze Natalya
Creation date: 10/05/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION get-param-value RETURNS CHARACTER
  ( INPUT p-data-type AS CHARACTER
   ,INPUT p-2-data-type AS character
   ,INPUT p-3-data-type AS CHARACTER
   ,INPUT p-p-index AS INTEGER
   ,INPUT p-value-character AS CHARACTER
   ,INPUT p-value-date AS DATE
   ,INPUT p-value-decimal AS DECIMAL
   ,INPUT p-value-integer AS INTEGER
   ,INPUT p-value-logical AS LOGICAL

     ) :
define buffer buf_cash-pay for ub.cash-pay.
define variable v-view-value as character no-undo .
if (p-3-data-type = "LIST"
     or
     p-3-data-type = "SORTED-LIST"
     )
and p-p-index = 0 then return '':U.

if p-2-data-type > '' then do:
  case p-2-data-type:
    when {&table_cash-pay}
    or
    when {&table_cash-pay} + "_null"
    then do:
      if p-2-data-type = {&table_cash-pay} + "_null"
      and p-value-character = substitute("&1,&2", 0, 0) then return "Тип касс. платежа не задан".
      else do:
        find first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = integer(entry(1, p-value-character))
              and buf_cash-pay.curr-code = integer(entry(2, p-value-character)) no-error.
        if available buf_cash-pay then return buf_cash-pay.obj-name.
        else return "!!!Неизвестный тип касс.платежа".
      end.
    end.
    when {&table_chk-doc} + "_wth-type_null"
    or when {&table_chk-doc} + "_wth-type" then do:
&scop  wth-receipt-code string(p-value-integer)
      return {&wth-receipt-name}.
    end.
    when {&discnt-v-type-manual} then do:
      &scop discnt-v-code string(p-value-integer)
      return {&discnt-v-name}.
    end.
    otherwise do:
      if lookup(p-2-data-type, {&calc-point-discnt-role-list}) > 0  then do:
         if lookup(p-value-character, {&disgdsru-list}) > 0
         then do:
           &scop dis-gds-rule-code  p-value-character
           return {&dis-gds-rule-name}.
         end.
         if lookup(p-value-character, {&dthbjr-list}) > 0
         then do:
           &scop dis-thbj-rule-code  p-value-character
           return {&dis-thbj-rule-name}.
         end.
         if lookup(p-value-character, {&dcpr-list}) > 0
         then do:
           &scop dis-cp-rule-code  p-value-character
           return {&dis-cp-rule-name}.
         end.
         if lookup(p-value-character, {&ddcr-list}) > 0
         then do:
           &scop dis-dc-rule-code  p-value-character
           return {&dis-dc-rule-name}.
         end.
         if lookup(p-value-character, {&ddctr-list}) > 0
         then do:
           &scop dis-dct-rule-code  p-value-character
           return {&dis-dct-rule-name}.
         end.
         if lookup(p-value-character, {&dggrr-list}) > 0
         then do:
           &scop dis-ggr-rule-code  p-value-character
           return {&dis-ggr-rule-name}.
         end.
         if lookup(p-value-character, {&dclgr-list}) > 0
         then do:
           &scop dis-clgr-rule-code  p-value-character
           return {&dis-clgr-rule-name}.
         end.
      end.
    end.
  end case.

end. /*if p-2-data-type > '' then do:*/
case p-data-type:
  when {&abl-datatype-character} then do:
    return p-value-character.
  end.
  when {&abl-datatype-date} then do:
    return string(p-value-date, "99/99/9999").
  end.
  when {&abl-datatype-decimal} then do:
    return string(p-value-decimal).
  end.
  when {&abl-datatype-integer} then do:
    return string(p-value-integer).
  end.
  when {&abl-datatype-logical} then do:
    return string(p-value-logical).
  end.
end.
END FUNCTION.



/* $Workfile$ e n d */