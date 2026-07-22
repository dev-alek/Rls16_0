/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры поддержки глобальных кодов клиентов - через code-range

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

*/

&if defined(gbclcode_i) = 0 &then

&glob gbclcode_i


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* { gbl/cur-time.i } 18/I-2019  вызов cur-time() заменено на просто today */

/*этот код клиента принадлежит этой БД?*/
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when {&gbl-pn-code} then do:
    v-seq-val = current-value(s-pngb-code, {&db-name_schema}).
  end.
  when {&gbl-fm-code} then do:
    v-seq-val = current-value(s-fmgb-code, {&db-name_schema}).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.

/*этот код клиента принадлежит этой БД? - упрощенно - нельяз использовать при выдаче новых кодов*/
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when {&gbl-pn-code} then do:
    v-seq-val = current-value(s-pngb-code, {&db-name_schema}).
  end.
  when {&gbl-fm-code} then do:
    v-seq-val = current-value(s-fmgb-code, {&db-name_schema}).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.

/*найти код чел , у которого код кассирв данной БД = p-cashier*/
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
/*DEFINE VARIABLE v-time as integer no-undo .*/
define buffer buf_staff for ub.staff.
if p-date = ? then do:
/* 18/I-2019 - параметр v-time не используется
   run cur-time in this-procedure ( output p-date, output v-time).
*/
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = {&role-level-db}
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.

/*найти первого попавшегося role для данной БД */
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
/*DEFINE VARIABLE v-time as integer no-undo .*/
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
/* 18/I-2019 - параметр v-time не используется
  run cur-time in this-procedure ( output p-date, output v-time).
*/
  p-date = today .  
end.

for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = {&role-level-db}
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.

/*найти код role для данного чела в данной БД */
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
/*DEFINE VARIABLE v-time as integer no-undo .*/
define buffer buf_staff for ub.staff.
if p-date = ? then do:
/* 18/I-2019 - параметр v-time не используется
  run cur-time in this-procedure ( output p-date, output v-time).
*/
  p-date = today .  
end.

find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = {&role-level-db}
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.


/*а он вообще продавец?  */
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
/*DEFINE VARIABLE v-time as integer no-undo .*/
define buffer buf_staff for ub.staff.
if p-date = ? then do:
/* 18/I-2019 - параметр v-time не используется
  run cur-time in this-procedure ( output p-date, output v-time).
*/
  p-date = today .  
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.

/*найти имя роли*/
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
&scop role-code p-role
assign
v-role-name = {&role-name}
no-error .
return v-role-name.
END.

{ gbl/getposit.i }


/*получить значение work-place*/
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when {&role-level-db} then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when {&role-level-firm} then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when {&role-level-object} then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.

/*найти последнее role для данной БД */
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
/*DEFINE VARIABLE v-time as integer no-undo .*/
define buffer buf_staff for ub.staff.
if p-work-place = {&question-mark} then return ?.
if p-date-start = ? then do:
/* 18/I-2019 - параметр v-time не используется
  run cur-time in this-procedure(output v-today, output v-time).
*/
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.



&endif

/* $Workfile$ e n d */