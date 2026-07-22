block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись для таблицы правила скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/05/24
Author: Bakhtadze Natalya
Creation date: 04/05/24

*/

TRIGGER PROCEDURE FOR WRITE OF ub.dis-time-rule OLD old_dis-time-rule.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы расписания скидок".
{ cmp/vssrevis.i "substitute('&1', ub.dis-time-rule.time-rule-num) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/distruls.i "work" }
{ trg/new-bcod.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-chr as character no-undo .
define variable v-changed as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-confirmed as logical no-undo .
define variable v-start-level as integer no-undo .
define variable level as integer no-undo .
define variable v-p as character no-undo .
define buffer buf_c-dis-time-rule for ub.c-dis-time-rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  buffer-compare ub.dis-time-rule to old_dis-time-rule
  case-sensitive
  save result in v-chr.

  if ub.dis-time-rule.time-rule-num <= {&max-num-dr-template} then do:
      _ii:
      do v-ii = 1 to num-entries(v-chr):
        if lookup(entry(v-ii, v-chr), "other-inf,uniq-field,des,sts") = 0 then do:
          assign
          v-changed = yes.
          leave _ii.
        end.
      end.
    if not ( g#db-num > 0 ) then do:
      if (v-chr <> "sts" and v-changed
          AND old_dis-time-rule.sts <> integer({&non-used-status-int})
          and not new(ub.dis-time-rule)
          ) then do:
        assign
        v-changed = yes.
      end.
    end.
    if (( g#db-num > 0 ) and not g#news and v-changed and not new(ub.dis-time-rule))
    or (not ( g#db-num > 0 ) and v-changed and not new(ub.dis-time-rule))
    then do:
      /*проверим от куда вызвали*/
      assign
      v-start-level = 2
      .
      assign
        level = v-start-level
      .
      _repeat:
      repeat while program-name( level ) <> ? :
        v-p = program-name( level ).
        if substring(v-p, length(v-p) - length("fixdr.p") + 1) = "fixdr.p":U
        or substring(v-p, length(v-p) - length("fixdr.p") + 1) = "fixdr.r":U
        or substring(v-p, length(v-p) - length("distrul0.p") + 1) = "distrul0.p":U
        or substring(v-p, length(v-p) - length("distrul0.p") + 1) = "distrul0.r":U
        then do:
          v-confirmed = yes.
          leave _repeat.
        end.
        assign
          level = level + 1
        .
      end.
      if not v-confirmed then do:
        message
        vss-workfile vss-revision vss-description skip
        "Для используемых записей ШАБЛОНОВ РАСПИСАНИЙ можно менять только статус записи и только в ГБД"
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
  end.
  if new(ub.dis-time-rule) then do:
    run gen-new-code-range-if-neces( input (if g#news then g#news-source-db else g#db-num),
                                     input {&gbl-dr-code},
                                     input ub.dis-time-rule.time-rule-num,
                                     input g#news,
                                     input g#db-num,
                                     input g#news-source-db
                                   ) .

  end.

  if ub.dis-time-rule.upper-time-rule-num <= {&max-num-dr-template} then do:
    run str/callnews.p
      (input {&table_dis-time-rule}
      ,input (buffer ub.dis-time-rule:handle)
      ).
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  create buf_c-dis-time-rule.
  buffer-copy old_dis-time-rule
  except time-rule-num upper-time-rule-num
  templ-rl-root
  rl-root
  to buf_c-dis-time-rule
  assign
  buf_c-dis-time-rule.date-from          = (if new(ub.dis-time-rule)
                                            then (if ub.dis-time-rule.date-from = 12/31/1989
                                                  then  ub.dis-time-rule.date-from
                                                  else 01/01/1990 )
                                            else old_dis-time-rule.date-from)
  buf_c-dis-time-rule.date-to          = (if new(ub.dis-time-rule)
                                            then (if ub.dis-time-rule.date-to = 12/31/1989
                                                  then  ub.dis-time-rule.date-to
                                                  else 01/01/1990 )
                                            else old_dis-time-rule.date-to)
  buf_c-dis-time-rule.time-rule-num      = ub.dis-time-rule.time-rule-num
  buf_c-dis-time-rule.upper-time-rule-num = ub.dis-time-rule.upper-time-rule-num
  buf_c-dis-time-rule.rl-root            = ub.dis-time-rule.rl-root
  buf_c-dis-time-rule.templ-rl-root      = ub.dis-time-rule.templ-rl-root
  buf_c-dis-time-rule.chip-num           = next-value (s-dc-chip, {&db-name_schema})
  buf_c-dis-time-rule.corr-time          = v-time
  buf_c-dis-time-rule.corr-user-db-num   = g#db-num
  buf_c-dis-time-rule.corr-user-name     = g#userid
  buf_c-dis-time-rule.corr-date          = v-date
  buF_c-dis-time-rule.action             = (if new(ub.dis-time-rule) then integer({&hn-create}) else integer({&hn-update}))
  buf_c-dis-time-rule.is-news            = g#news
  .


  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_dis-time-rule}
        , input ( buffer ub.dis-time-rule:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.