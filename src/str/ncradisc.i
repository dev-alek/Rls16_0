/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/06/03
Author: Bakhtadze Natalya
Creation date: 10/06/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".



function ncr-amnt-disc returns character (
  input p-pcnt-discnt-rule as integer, input p-price-sale as decimal).
define variable v-result as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo extent 3.

for each cash-dis-rule  no-lock where
      cash-dis-rule.upper-rule-num = p-pcnt-discnt-rule:
  assign
  ii = ii + 1
  v-entry[ii] = "000000":U + string(round(cash-dis-rule.doc-qnty / cash-gds.cli-base-rate, 0), "999999":U) +
                replace(string(p-price-sale * (1 - cash-dis-rule.discnt-value / 100), "999999.99"), ".":U, "":U)
  .
end.

if v-entry[2] = "":U then
assign
v-entry[2] = v-entry[1]
.
if v-entry[3] = "":U then
assign
v-entry[3] = v-entry[2]
.
assign
v-result = v-entry[1] + v-entry[2] + v-entry[3]
.
return v-result.

END FUNCTION.


function ncr-date-disc returns character (
  input p-date-discnt-rule  as integer, input p-price-sale as decimal).

define variable v-result as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo extent 3.

for each cash-dis-rule  no-lock where
      cash-dis-rule.upper-rule-num = p-date-discnt-rule,
    first cash-dis-time-rule no-lock where cash-dis-time-rule.time-rule-num = cash-dis-rule.time-rule-num :
  assign
  ii = ii + 1
  v-entry[ii] =               /*западло для потомков*/
                substring(string(year(cash-dis-time-rule.date-from), "9999":U), 3, 2)   +
                string(month(cash-dis-time-rule.date-from), "99":U) +
                string(day(cash-dis-time-rule.date-from), "99":U)  +
                substring(string(year(cash-dis-time-rule.date-to), "9999":U), 3, 2)   +
                string(month(cash-dis-time-rule.date-to), "99":U) +
                string(day(cash-dis-time-rule.date-to), "99":U) +
                replace(string(cash-gds.price-sale * (1 - cash-dis-rule.discnt-value / 100), "999999.99"), ".":U, "":U).

end.

if v-entry[2] = "":U then
assign
v-entry[2] = v-entry[1]
.
if v-entry[3] = "":U then
assign
v-entry[3] = v-entry[2]
.
assign
v-result = v-entry[1] + v-entry[2] + v-entry[3]
.
return v-result.

END FUNCTION.


function ncr-temp-disc returns character (
  input p-temp-discnt-rule  as integer, input p-price-sale as decimal, p-temp-disc-dec as decimal).

define variable v-result as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo extent 3.
define variable v-dec as decimal no-undo .
define variable v-disc-price-sale as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .

define buffer buf_cash-dis-rule for cash-dis-rule.
find first buf_cash-dis-rule where
         buf_cash-dis-rule.rule-num = p-temp-discnt-rule no-error .
if not available buf_cash-dis-rule then return "":U.
if buf_cash-dis-rule.templ-rl-root <> 29
and buf_cash-dis-rule.templ-rl-root <> 86
then do:
  assign
  v-entry[1] =
  /*это неспецифически NCR скидка  и мы ее уже нашли*/
  "000"                                                   +
  "0"                                                     + /*все дни недели*/
  "0000"                                                  + /*с нуля часов*/
  "2359"                                                    /*до полуночи*/ +
   replace(string(cash-gds.price-sale * (1 + p-temp-disc-dec / 100), "999999.99"), ".":U, "":U)
   .
end.
else do:
  for each cash-dis-rule  no-lock where
        cash-dis-rule.upper-rule-num = p-temp-discnt-rule ,
      first cash-dis-time-rule no-lock where cash-dis-time-rule.time-rule-num = cash-dis-rule.time-rule-num :
    case cash-dis-rule.value-type:
      when integer({&discnt-v-pcnt}) then do:
        v-dec = cash-gds.price-sale * (1 - cash-dis-rule.discnt-value / 100).
      end.
      when integer({&discnt-v-pdf-fp}) then do:
         /*получим v-dec = цене полученной из прайс-листа типа cash-dis-rule.charkey_one*/
        find first cash-gds-discnt where
                  cash-gds-discnt.b-code = cash-gds.b-code
              and cash-gds-discnt.rule-num = cash-dis-rule.rule-num
              and cash-gds-discnt.obj-type = {&shop}
              and cash-gds-discnt.obj-code = i-obj-code
              no-error.
        if not available cash-gds-discnt then do:
          v-dec = cash-gds.price-sale.
        end.
        else do:
          assign
          v-dec = cash-gds-discnt.discnt-value
          .
        end.
      end.
      otherwise do:
        v-dec = cash-gds.price-sale.
      end.
    end case.
    assign
    ii = ii + 1
    v-entry[ii] =
                  "000"                                                   +
                  (if cash-dis-time-rule.week-day-0 then "0" else "":U)   +
                  (if cash-dis-time-rule.week-day-7 then "1" else "":U)   +
                  (if cash-dis-time-rule.week-day-1 then "2" else "":U)   +
                  (if cash-dis-time-rule.week-day-2 then "3" else "":U)   +
                  (if cash-dis-time-rule.week-day-3 then "4" else "":U)   +
                  (if cash-dis-time-rule.week-day-4 then "5" else "":U)   +
                  (if cash-dis-time-rule.week-day-5 then "6" else "":U)   +
                  (if cash-dis-time-rule.week-day-6 then "7" else "":U)   +
                  replace(string(cash-dis-time-rule.time-from, "HH:MM"), ":":U, "":U) +
                  replace(string(cash-dis-time-rule.time-to, "HH:MM"), ":":U, "":U) +
                  replace(string(v-dec, "999999.99"), ".":U, "":U)
    .
if ii = 3 then leave.
  end.
end.
if v-entry[2] = "":U then
assign
v-entry[2] = v-entry[1]
.
if v-entry[3] = "":U then
assign
v-entry[3] = v-entry[2]
.
assign
v-result = v-entry[1] + v-entry[2] + v-entry[3]
.
return v-result.

END FUNCTION.



function ncr-d-rank returns character (
  input p-d-rank as character, input p-pcnt-discnt-rule  as integer, input p-temp-discnt-rule as integer, input p-date-discnt-rule as integer).
define variable v-result as character no-undo .
define variable ii as integer no-undo .

do ii = 1 to length(p-d-rank):
  CASE substr(p-d-rank, ii, 1):
    when "X":U then do:
      if p-pcnt-discnt-rule <> 0 then v-result = "X":U.
    end.
    when "T":U then do:
      if p-temp-discnt-rule <> 0 then v-result = "T":U.
    end.
    when "D":U then do:
      if p-date-discnt-rule <> 0 then v-result = "D":U.
    end.
  END CASE.
  if v-result <> "":U then LEAVE.
end.
if v-result = "":U then v-result = {&space-char}.
return v-result.

END FUNCTION.
/* $Workfile$ e n d */