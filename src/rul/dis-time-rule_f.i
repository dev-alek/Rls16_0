/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/14/06
Author: Bakhtadze Natalya
Creation date: 12/14/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(dis-time-rule_f_i) = 0 &then

&glob dis-time-rule_f_i


function loc-weekday returns integer ( input p-date as date):
Case weekday(p-date):
  when 1 then return 7.
  otherwise return  weekday(p-date) - 1.
end case.

end function.

FUNCTION DIS-TIME-RULE_-1 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Не задается расписание*/
return yes.
end function.


FUNCTION DIS-TIME-RULE_-50001 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Не задается расписание*/
return yes.
end function.



FUNCTION DIS-TIME-RULE_00000 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Неопределено*/
return yes.
end function.


FUNCTION DIS-TIME-RULE_00001 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Всегда*/
return yes.
end function.

FUNCTION DIS-TIME-RULE_00002 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Период времени*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  if buf_dis-time-rule.time-from <= p-time
  and buf_dis-time-rule.time-to >= p-time then do:
    return yes.
  end.
end.
return no.
end function.

FUNCTION DIS-TIME-RULE_00003 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Период дат*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  if buf_dis-time-rule.date-from <= p-date
  and buf_dis-time-rule.date-to >= p-date then do:
    return yes.
  end.
end.
return no.
end function.


FUNCTION DIS-TIME-RULE_00004 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Один или несколько дней недели*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  if buffer buf_dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes
  then do:
    return yes.
  end.
end.
return no.
end function.

FUNCTION DIS-TIME-RULE_00005 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Выходные*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  if buffer buf_dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes
  then do:
    return yes.
  end.
end.
return no.
end function.

FUNCTION DIS-TIME-RULE_00006 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@День месяца*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  if buf_dis-time-rule.month-day = day(p-date) then do:
    return yes.
  end.
  return no.
end.
else do:
  return no.
end.
end function.

FUNCTION DIS-TIME-RULE_00007 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Период дат с временем*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  if buf_dis-time-rule.date-from <= p-date
  and buf_dis-time-rule.date-to >= p-date
  and buf_dis-time-rule.time-from <= p-time
  and buf_dis-time-rule.time-to >= p-time then do:
    return yes.
  end.
end.
return no.
end function.

FUNCTION DIS-TIME-RULE_00008 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Период дат с временем и днями недели*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  if buf_dis-time-rule.date-from <= p-date
  and buf_dis-time-rule.date-to >= p-date
  and (buffer buf_dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes
       or buf_dis-time-rule.week-day-0 = yes)
  and buf_dis-time-rule.time-from <= p-time
  and buf_dis-time-rule.time-to >= p-time
  then do:
    return yes.
  end.
end.
return no.
end function.

FUNCTION DIS-TIME-RULE_00009 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@По дням недели и часам - POS NCR-GM-три в одном*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer buf_term-dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  for each buf_term-dis-time-rule no-lock where
          buf_term-dis-time-rule.upper-time-rule-num = buf_dis-time-rule.time-rule-num:
    if buf_term-dis-time-rule.time-from <= p-time
    and buf_term-dis-time-rule.time-to >= p-time
    and buffer buf_term-dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes
    then do:
      return yes.
    end.
  end.
end.
return no.
end function.


FUNCTION DIS-TIME-RULE_00010 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@Один день недели*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  if buffer buf_dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes
  then do:
    return yes.
  end.
end.
return no.
end function.

FUNCTION DIS-TIME-RULE_00011 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@По дням недели и часам - POS NCR-GM*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  if (buf_dis-time-rule.week-day-0 = yes
  or (buffer buf_dis-time-rule:buffer-field("week-day-" + string(loc-weekday(p-date) )):buffer-value = yes))
  and (buf_dis-time-rule.time-from <= p-time
  and buf_dis-time-rule.time-to >= p-time)
  then do:
    return yes.
  end.
end.
return no.
end function.


FUNCTION DIS-TIME-RULE_00012 returns logical ( input p-time-rule-num as integer, input p-date as date, input p-time as integer):
/*@По интервалу времени - POS R-KEEPER*/
define buffer buf_dis-time-rule for ub.dis-time-rule.
find first buf_dis-time-rule no-lock where
          buf_dis-time-rule.time-rule-num = p-time-rule-num no-error.
if available buf_dis-time-rule
and buf_dis-time-rule.sts = integer ({&current-status-int}) then do:
  if buf_dis-time-rule.time-from <= p-time
  then do:
    return yes.
  end.
end.
return no.
end function.


&endif



/* $Workfile$ e n d */