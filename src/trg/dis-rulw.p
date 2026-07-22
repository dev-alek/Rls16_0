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

TRIGGER PROCEDURE FOR WRITE OF ub.dis-rule OLD old_dis-rule.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись для таблицы правила скидок".
{ cmp/vssrevis.i "substitute('&1', ub.dis-rule.rule-num) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/disrules.i  "work" }
{ trg/new-bcod.i }


define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable v-chr as character no-undo .
define variable v-changed as logical no-undo .
define variable v-confirmed as logical no-undo .
define variable v-start-level as integer no-undo .
define variable level as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-p as character no-undo .
define buffer buf_c-dis-rule for ub.c-dis-rule.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  buffer-compare ub.dis-rule to old_dis-rule
  case-sensitive
  save result in v-chr.
    if ub.dis-rule.rule-num <= {&max-num-dr-template} then do:
      _ii:
      do v-ii = 1 to num-entries(v-chr):
        if lookup(entry(v-ii, v-chr), "other-inf,uniq-field,des,sts,dis-kat,doc-qnty,tot-sum,":U +
                                      "charkey_one,charkey_two,charkey_three":U +
                                      "deckey_one,deckey_two,deckey_three":U +
                                      "key#_one,key#_two,key_#three":U
                                      ) = 0
        then do:
          assign
          v-changed = yes
          .
          leave _ii.
        end.
     end.
     if lookup("dis-kat":U, v-chr) > 0 then do:
       if ub.dis-rule.discnt-type = integer({&discnt-t-categ}) then
       assign
       v-changed = yes.
     end.
     if lookup("doc-qnty":U, v-chr) > 0 then do:
       if ub.dis-rule.discnt-type = integer({&discnt-t-qnty}) then
       assign
       v-changed = yes.
     end.
     if not ( g#db-num > 0 ) then do:
      if (v-chr <> "sts" and v-changed
          AND old_dis-rule.sts <> integer({&non-used-status-int})
          and not new(ub.dis-rule)
          ) then do:
        assign
        v-changed = yes.
      end.
    end.
    if (( g#db-num > 0 ) and not g#news and v-changed and not new(ub.dis-rule))
    or (not ( g#db-num > 0 ) and v-changed and not new(ub.dis-rule))
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
        or substring(v-p, length(v-p) - length("disrul0.p") + 1) = "disrul0.p":U
        or substring(v-p, length(v-p) - length("disrul0.p") + 1) = "disrul0.r":U
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
        substitute("Правило №&1", ub.dis-rule.rule-num) skip
        "Для используемых записей ШАБЛОНОВ СКИДОК можно менять только статус записи и только в ГБД"
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
  end.

  if new(ub.dis-rule)
  and ub.dis-rule.rule-num > {&max-num-dr-template}
  then do:
    run gen-new-code-range-if-neces
                                   (  input (if g#news then g#news-source-db else g#db-num)
                                     ,input {&gbl-dr-code}
                                     ,input ub.dis-rule.rule-num
                                     ,input g#news
                                     ,input g#db-num
                                     ,input g#news-source-db
                                   ) no-error .

   if error-status:error then do:
      /*отследим вдруг это откат two-commit*/
      if g#news
      then do:
        find first buf_c-dis-rule no-lock where
                  buf_c-dis-rule.rule-num = ub.dis-rule.rule-num
              and buf_c-dis-rule.corr-user-db-num = g#news-source-db no-error.
      end.
      else do:
        find first buf_c-dis-rule no-lock where
                  buf_c-dis-rule.rule-num = ub.dis-rule.rule-num
              and buf_c-dis-rule.corr-user-db-num = g#db-num no-error.
      end.
      if not available buf_c-dis-rule
      and ub.dis-rule.upper-rule-num > {&max-num-dr-template}
      and g#news then do:
        find first buf_c-dis-rule no-lock where
                  buf_c-dis-rule.rule-num = ub.dis-rule.rule-num
              and buf_c-dis-rule.corr-user-db-num = g#db-num no-error.
      end.
      if available buf_c-dis-rule then do:
        define buffer buf_code-range for ub.code-range.
        find first buf_code-range no-lock where
                  buf_code-range.range-type = {&gbl-dr-code}
             and  buf_code-range.first-code <= ub.dis-rule.rule-num
             and  buf_code-range.last-code >= ub.dis-rule.rule-num
             and  (buf_code-range.stts = "u":U
                   or
                   buf_code-range.stts = "a":U  )
             no-error.
        if available buf_Code-range then do:
        end.
        else do:
          undo main-block, return error substitute("&2&1&3&1&4&1&5&1&6&1"
                                                  , {&new-line}
                                                  , vss-workfile
                                                  , vss-revision
                                                  ,vss-description
                                                  , error-status:get-message(1)
                                                  , return-value ).
        end.
      end.
      else do:
       undo main-block, return error substitute("&2&1&3&1&4&1&5&1&6&1"
                                               , {&new-line}
                                               , vss-workfile
                                               , vss-revision
                                               ,vss-description
                                               , error-status:get-message(1)
                                               , return-value ).
     end.
   end.
  end.


  if not g#news then do:
    if ( g#db-num > 0 )   then do:
      if (ub.dis-rule.host-code = 0
      or ub.dis-rule.obj-code = 0 )
      and v-changed and not new(ub.dis-rule)
      then do:
        message
        vss-workfile vss-revision vss-description skip
        substitute("Правило №&1", ub.dis-rule.rule-num) skip
        "Нельзя изменять глобальную запись ПРАВИЛА СКИДОК  или запись ПРАВИЛА СКИДОК по фирме в УБД"
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.

    if ub.dis-rule.obj-code > 0 then do:
      { gbl/objdbnum.i ub.dis-rule.obj-type ub.dis-rule.obj-code v-db-num }
      if v-db-num <> g#db-num and ( g#db-num > 0 ) then do:
        message
        vss-workfile vss-revision vss-description skip
        substitute("Правило №&1", ub.dis-rule.rule-num) skip
        "Нельзя изменять запись ПРАВИЛА СКИДОК на объекте в чужой УБД"
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
  end.
  run cur-time in this-procedure(output v-date, output v-time).
  if new(ub.dis-rule) then do:
    create buf_c-dis-rule.
    buffer-copy old_dis-rule
    except
    rule-num
    upper-rule-num
    templ-rl-root
    rl-root
    host-code
    obj-type
    obj-code
    to buf_c-dis-rule
    assign
    buf_c-dis-rule.rule-num           = ub.dis-rule.rule-num
    buf_c-dis-rule.upper-rule-num     = ub.dis-rule.upper-rule-num
    buf_c-dis-rule.templ-rl-root      = ub.dis-rule.templ-rl-root
    buf_c-dis-rule.rl-root            = ub.dis-rule.rl-root
    buf_c-dis-rule.host-code          = ub.dis-rule.host-code
    buf_c-dis-rule.obj-type           = ub.dis-rule.obj-type
    buf_c-dis-rule.obj-code           = ub.dis-rule.obj-code
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
    buF_c-dis-rule.action             = (if new(ub.dis-rule) then integer({&hn-create}) else integer({&hn-update}))
    buf_c-dis-rule.is-news            = g#news
    .
  end.
  else do:
    if v-chr <> '':U then do:
      create buf_c-dis-rule.
      buffer-copy old_dis-rule
      except
      rule-num  to buf_c-dis-rule
      assign
      buf_c-dis-rule.rule-num           = ub.dis-rule.rule-num
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
      buF_c-dis-rule.action             = (if new(ub.dis-rule) then integer({&hn-create}) else integer({&hn-update}))
      buf_c-dis-rule.is-news            = g#news
      .
    end.
  end.
  if g#db-num = 0
  and old_dis-rule.sts = integer({&to-delete-status-int})
  and ub.dis-rule.sts <> integer({&to-delete-status-int}) then do:
    create buf_c-dis-rule.
    buffer-copy ub.dis-rule
    except
    rule-num  to buf_c-dis-rule
    assign
    buf_c-dis-rule.rule-num           = ub.dis-rule.rule-num
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
    buF_c-dis-rule.action             = integer({&hn-correction})
    buf_c-dis-rule.is-news            = g#news
    .
  end.


  if (new(ub.dis-rule)
  or v-chr <> '':U )
  AND (ub.dis-rule.obj-code = 0 or not g#news)
  and ub.dis-rule.upper-rule-num <= {&max-num-dr-template}
  and not (v-chr = 'sts' and ub.dis-rule.sts = integer({&to-delete-status-int}))
       /*последнее - выполняется по two-commit*/
    then do:
    run str/callnews.p
      (input {&table_dis-rule}
      ,input (buffer ub.dis-rule:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_dis-rule}
        , input ( buffer ub.dis-rule:handle )
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