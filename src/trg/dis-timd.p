block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление расписания скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/24
Author: Bakhtadze Natalya
Creation date: 04/05/24

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-time-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление расписания скидок".
{ cmp/vssrevis.i "substitute('&1',  ub.dis-time-rule.time-rule-num) " }
{ cmp/trg-def.i }
{ gbl/distruls.i "work" }
{ gbl/cur-time.i }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-dis-time-rule for ub.c-dis-time-rule.
define buffer buf_dis-time-rule  for ub.dis-time-rule.
define buffer buf_dis-rule  for ub.dis-rule.
define variable v-db-num like ub.db.db-num no-undo .

main-block :
do transaction
on error undo main-block, return error
:
  if not g#news
  and ub.dis-time-rule.time-rule-num <= {&max-num-dr-template}
    and ub.dis-time-rule.sts <> integer({&non-used-status-int})
    and ub.dis-time-rule.time-rule-num < ({&num-dtr-templates} + {&dtr-templates-shift}) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись ШАБЛОНОВ РАСПИСАНИЙ СКИДОК"
    view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news then do:
    if can-find(first buf_dis-time-rule no-lock where
                      buf_dis-time-rule.upper-time-rule-num = ub.dis-time-rule.time-rule-num
                  AND buf_dis-time-rule.time-rule-num < ({&num-dtr-templates} + {&dtr-templates-shift})
                      ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять запись РАСПИСАНИЙ СКИДОК, если к ней привязана другая запись"
      view-as alert-box error .
      undo main-block, return error .
    end.
    if can-find(first buf_dis-rule no-lock where
                      buf_dis-rule.time-rule-num = ub.dis-time-rule.time-rule-num) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалить запись РАСПИСАНИЙ СКИДОК, если к ней привязана запись ШАБЛОНА ПРАВИЛ СКИДОК"
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.
    /* посылаем команду на удаление расписания */
  if ub.dis-time-rule.upper-time-rule-num <= {&max-num-dr-template}
  then do:
    run nws/cmd-del.p
      ( input "dis-time-rule":U
      ,input (buffer ub.dis-time-rule:handle)
      ,input "":U
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-time-rule.
  buffer-copy ub.dis-time-rule to buf_c-dis-time-rule
  assign
  buf_c-dis-time-rule.time-rule-num             = ub.dis-time-rule.time-rule-num
  buf_c-dis-time-rule.chip-num           = next-value (s-dc-chip, {&db-name_schema})
  buf_c-dis-time-rule.corr-time          = v-time
  buf_c-dis-time-rule.corr-user-db-num   = g#db-num
  buf_c-dis-time-rule.corr-user-name     = (if g#news
                                           then {&nts-user}
                                           else (if g#esys
                                                 then {&esys-user}
                                                 else g#userid)
                                           )
  buf_c-dis-time-rule.corr-date          = v-date
  buf_c-dis-time-rule.is-news            = g#news
  buf_c-dis-time-rule.action             = integer({&hn-delete})
  .
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_dis-time-rule}
        , input ( buffer ub.dis-time-rule:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.