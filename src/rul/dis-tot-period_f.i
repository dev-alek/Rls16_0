/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Функции для объекта операнда dis-tot-period

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/07
Author: Bakhtadze Natalya
Creation date: 03/22/07

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{1}" = "get_prev_sum-id_by-date" &then

FUNCTION get_prev_sum-id_by-date returns character(
                                                    input p-date as date
                                                  , input p-caller-id as character):
define buffer buf_prop-ref for ub.prop-ref.
define variable v-date-char as character no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
assign
v-date-char = string(year(p-date), "9999") + "/" +
              string(month(p-date), "99") + "/" +
            string(day(p-date), "99")
v-date-char = v-date-char + "-" + v-date-char
.
find last buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = 5
      and buf_prop-ref.sum-id <= v-date-char
      and buf_prop-ref.caller_id = p-caller-id use-index idtsum no-error .
if not available buf_prop-ref then do:
  return {&question-mark}.
end.
v-date-char = buf_prop-ref.sum-id.
find last buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = 5
      and buf_prop-ref.sum-id < v-date-char
      and buf_prop-ref.caller_id = p-caller-id use-index idtsum no-error .
if not available buf_prop-ref then do:
  return {&question-mark}.
end.
return buf_prop-ref.sum-id.
end function.

&endif


&if "{1}" = "get_current_sum-id_by-date" &then

FUNCTION get_current_sum-id_by-date returns character(
                                                    input p-date as date
                                                  , input p-caller-id as character ):
define buffer buf_prop-ref for ub.prop-ref.
define variable v-date-char as character no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
assign
v-date-char = string(year(p-date), "9999") + "/" +
              string(month(p-date), "99") + "/" +
            string(day(p-date), "99")
v-date-char = v-date-char + "-" + v-date-char
.
find last buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = 5
      and buf_prop-ref.sum-id <= v-date-char
      and buf_prop-ref.caller_id = p-caller-id use-index idtsum
      no-error .
if not available buf_prop-ref then do:
  return {&question-mark}.
end.
return buf_prop-ref.sum-id.
end function.

&endif

&if "{1}" = "get_sum-id_by-date_dct" &then
FUNCTION get_sum-id_by-date_dct returns character
                           ( input p-date as date
                            , input p-caller-id as character
                            , input p-emitent-host-code as integer
                            , input p-type as character
                            ):
define variable v-date-char as character no-undo .
define buffer buf_prop-ref-call for ub.prop-ref-call.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_dis-card-type for ub.dis-card-type.
assign
v-date-char = string(year(p-date), "9999") + "/" +
              string(month(p-date), "99") + "/" +
            string(day(p-date), "99")
v-date-char = v-date-char + "-" + v-date-char
.
find last buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = 5
      and buf_prop-ref.sum-id <= v-date-char
      and buf_prop-ref.caller_id = p-caller-id use-index idtsum
      no-error .
if not available buf_prop-ref then do:
 return {&question-mark}.
end.
find first buf_dis-card-type no-lock where
          buf_Dis-card-type.type = p-type
      and buf_Dis-card-type.emitent-host-code = p-emitent-host-code
      and buf_Dis-card-type.host-code = 0
      and buf_Dis-card-type.obj-type = '':U
      and buf_Dis-card-type.obj-code = 0 no-error.
if not available buf_dis-card-type then do:
 return {&question-mark}.
end.
find first buf_prop-ref-call no-lock where
          buf_prop-ref-call.call_id = buf_Dis-card-type.uniq-key-rec
      and buf_prop-ref-call.dt-code = buf_prop-ref.dt-code no-error.
if not available buf_prop-ref-call then do:
  return {&question-mark}.
end.
return  buf_prop-ref.sum-id.
end FUNCTION.

&endif


/* $Workfile$ e n d */