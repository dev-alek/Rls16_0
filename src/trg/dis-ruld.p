block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление правил скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/24
Author: Bakhtadze Natalya
Creation date: 04/05/24

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление правил скидок".
{ cmp/vssrevis.i "substitute('&1',  ub.dis-rule.rule-num) " }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ gbl/disrules.i "work" }
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_c-dis-rule for ub.c-dis-rule.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-list as character no-undo .
define buffer buf_dis-rule for ub.dis-rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1) )
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  and ub.dis-rule.rule-num <= {&max-num-dr-template}
  and ub.dis-rule.sts <> integer({&non-used-status-int})
  and ub.dis-rule.rule-num < {&num-dr-templates}
  then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя удалять запись ШАБЛОНОВ СКИДОК"
    view-as alert-box error .
    undo main-block, return error .
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      if ub.dis-rule.host-code = 0
      or ub.dis-rule.obj-code = 0 then do:
        find first buf_dis-rule no-lock where
                  buf_dis-rule.templ-rl-root = ub.dis-rule.templ-rl-root no-error.
        if buf_dis-rule.sts <> integer({&non-used-status-int}) then do:
          message
          vss-workfile vss-revision vss-description skip
          "Нельзя удалять ИСПОЛЬЗУЕМУЮ глобальную запись ПРАВИЛА СКИДОК  или запись ПРАВИЛА СКИДОК по фирме в УБД"
          view-as alert-box error .
          undo main-block, return error .
        end.
      end.
    end.
    if ub.dis-rule.obj-code > 0 then do:
      { gbl/objdbnum.i ub.dis-rule.obj-type ub.dis-rule.obj-code v-db-num }
      if v-db-num <> g#db-num and ( g#db-num > 0 ) then do:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя удалять запись ПРАВИЛА СКИДОК на объекте в чужой БД"
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    if can-find(first buf_dis-rule no-lock where
                    buf_dis-rule.upper-rule-num = ub.dis-rule.rule-num
                AND buf_dis-rule.rule-num < {&num-dr-templates} ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять запись ПРАВИЛА СКИДОК, если к ней привязана другая запись"
      view-as alert-box error .
      undo main-block, return error .
    end.
  end.

    /* посылаем команду на удаление правила сикдок */
  if ub.dis-rule.upper-rule-num <= {&max-num-dr-template}
  then do:
    if ub.dis-rule.sts <> integer({&to-delete-status-int}) then do:
      if ub.dis-rule.obj-code <> 0 then do:
        { gbl/objdbnum.i ub.dis-rule.obj-type ub.dis-rule.obj-code v-db-num }
        if g#db-num = 0
        and v-db-num <> 0  then do:
          assign
          v-db-list = string( v-db-num ) .
        end.
        if g#db-num <> 0 then do:
          assign
          v-db-list = "0"
          .
        end.
      end.
      run nws/cmd-del.p
        ( input {&table_dis-rule}
        ,input (buffer ub.dis-rule:handle)
        ,input v-db-list
        ) no-error .
      if error-status :error then do:
        undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
      end.
    end.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-rule.
  buffer-copy ub.dis-rule to buf_c-dis-rule
  assign
  buf_c-dis-rule.rule-num             = ub.dis-rule.rule-num
  buf_c-dis-rule.chip-num           = next-value (s-dc-chip, {&db-name_schema})
  buf_c-dis-rule.corr-time          = v-time
  buf_c-dis-rule.corr-user-db-num   = g#db-num
  buf_c-dis-rule.corr-user-name     = (if g#news
                                       then {&nts-user}
                                       else (if g#esys
                                             then {&esys-user}
                                             else g#userid)
                                             )
  buf_c-dis-rule.corr-date          = v-date
  buf_c-dis-rule.is-news            = g#news
  buf_c-dis-rule.action             = integer({&hn-delete})
  .
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_dis-rule}
        , input ( buffer ub.dis-rule:handle )
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