block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись алгоритма расчетов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/15/06
Author: Bakhtadze Natalya
Creation date: 08/15/06

*/


TRIGGER PROCEDURE FOR WRITE OF ub.rule-by-call OLD old_rule-by-call.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись алгоритма расчетов".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4'
                         , ub.rule-by-call.call#_id
                         , ub.rule-by-call.codex_id
                        , ub.rule-by-call.ruleset_id
                        , ub.rule-by-call.order_id
                         ) " }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/key-rec.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-descr as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-call-id-type as character no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_c-rule-by-call for ub.c-rule-by-call.
define buffer buf_c-dis-card-type for ub.c-dis-card-type.
define buffer buf_c-thbj-attr for ub.c-thbj-attr.
define buffer buf_c-cli-hist for ub.c-cli-hist.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    if new(ub.rule-by-call) then do:
       if ub.rule-by-call.call#_id = 0 then do:
         case entry(1, ub.rule-by-call.call_Id, {&delim-key}):
           when {&table_dis-card-type} then do:
             v-call-id-type = {&table_dis-card-type}.
           end.
         end case.
         run rul/g-callid.p (
                              input v-call-id-type
                             ,input ub.rule-by-call.call_id
                             ,output ub.rule-by-call.call#_id).
      end.
      run gen-key-rec in this-procedure ( input {&table_rule-by-call}
                                        ,input buffer ub.rule-by-call:handle
                                        ,output v-uniq-key-rec).
      if ub.rule-by-call.uniq-key-rec <> v-uniq-key-rec
      then do:
        if ub.rule-by-call.uniq-key-rec = '':U then do:
          ub.rule-by-call.uniq-key-rec = v-uniq-key-rec.
        end.
        else do:
          run vss-get-parameters in this-procedure (output v-descr).
          message
          vss-workfile vss-revision vss-description skip
          "Неверное значение поля uniq-key-rec" ub.rule-by-call.uniq-key-rec skip
          v-descr  "Должно быть " v-uniq-key-rec
          view-as alert-box error .
          undo main-block, return error .
        end.
      end.
    end.
    else do:
      if ub.rule-by-call.call_id <> old_rule-by-call.call_id
      or ub.rule-by-call.call#_id <> old_rule-by-call.call#_id
      or ub.rule-by-call.codex_id <> old_rule-by-call.codex_id
      or ub.rule-by-call.ruleset_id <> old_rule-by-call.ruleset_id
      or ub.rule-by-call.order_id <> old_rule-by-call.order_id
      then do:
        run vss-get-parameters in this-procedure (output v-descr).
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя изменять поля первичного ключа" skip
        v-descr skip
        "Старый ПК" old_rule-by-call.uniq-key-rec
        view-as alert-box error .
        undo main-block, return error .
      end.
    end.
  end.
  if not g#news
  or g#db-num <> 0 then do:
    define variable v-cmp as logical no-undo .
    if not new(ub.rule-by-call) then do:
      buffer-compare ub.rule-by-call
      to old_rule-by-call
      case-sensitive
      save result in v-cmp.
    end.
    else do:
      v-cmp = no.
    end.
    if not v-cmp then do:
      if entry(1, ub.rule-by-call.call_id, {&delim-key}) <> {&table_layout-elem-rule} then do:
        run cur-time in this-procedure(output v-date, output v-time).
        create buf_c-rule-by-call.
        buffer-copy old_rule-by-call to buf_c-rule-by-call
        assign
        buf_c-rule-by-call.call_id              = ub.rule-by-call.call_id
        buf_c-rule-by-call.call#_id             = ub.rule-by-call.call#_id
        buf_c-rule-by-call.uniq-key-rec         = ub.rule-by-call.uniq-key-rec
        buf_c-rule-by-call.ruleset_id           = ub.rule-by-call.ruleset_id
        buf_c-rule-by-call.codex_id             = ub.rule-by-call.codex_id
        buf_c-rule-by-call.order_id             = ub.rule-by-call.order_id
        buf_c-rule-by-call.corr-time          = v-time
        buf_c-rule-by-call.corr-user-db-num   = g#db-num
        buf_c-rule-by-call.corr-user-name     = g#userid
        buf_c-rule-by-call.corr-date          = v-date
        .
        run  gen-key-fv in this-procedure (
                                          input ub.rule-by-call.call_id
                                          ,output v-field-list
                                          ,output v-value-list).
        case entry(1, ub.rule-by-call.call_id, {&delim-key}):
          when {&table_dis-card-type} then do:

            create buf_c-dis-card-type.
            buffer-copy buf_c-rule-by-call
            except uniq-key-rec
            to buf_c-dis-card-type
            assign
            buf_c-dis-card-type.chip-num           = next-value (s-dc-chip, {&db-name_schema})
            buf_c-rule-by-call.chip-num           = buf_c-dis-card-type.chip-num
            buf_c-dis-card-type.type =  entry(lookup("type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
            buf_c-dis-card-type.emitent-host-code = integer(entry(lookup("emitent-host-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
            buf_c-dis-card-type.uniq-key-rec = buf_c-rule-by-call.call_id
            buf_c-dis-card-type.action = (if new ub.rule-by-call then integer({&hn-create}) else integer({&hn-update}))
            buf_c-dis-card-type.subject = {&table_rule-by-call}
            .
          end.
          when {&table_thbj-attr} then do:
            create buf_c-thbj-attr.
            buffer-copy buf_c-rule-by-call to buf_c-thbj-attr
            assign
            buf_c-thbj-attr.chip-num           = next-value (s-cli-chip, {&db-name_schema})
            buf_c-rule-by-call.chip-num           = buf_c-thbj-attr.chip-num
            buf_c-thbj-attr.prop-code         = entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key})
            buf_c-thbj-attr.upper-prop-code   = entry(lookup("upper-prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key})
            buf_c-thbj-attr.obj-type          = entry(lookup("obj-type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
            buf_c-thbj-attr.obj-code          = integer(entry(lookup("obj-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
            buf_c-thbj-attr.action = (if new ub.rule-by-call then integer({&hn-create}) else integer({&hn-update}))
            buf_c-thbj-attr.subject = {&table_rule-by-call}
            .
            if buf_c-thbj-attr.obj-type = {&shop}
            or buf_c-thbj-attr.obj-type = {&stock} then do:
              { gbl/hostcode.i buf_c-thbj-attr.obj-type buf_c-thbj-attr.obj-code v-host-code }
            end.
            if buf_c-thbj-attr.obj-type = {&cmp} then do:
              assign
              v-host-code = buf_c-thbj-attr.obj-code.
            end.
            create buf_c-cli-hist.
            buffer-copy buf_c-thbj-attr to buf_c-cli-hist
            assign
            buf_c-cli-hist.action = (if new (ub.rule-by-call )
                                    then integer({&hn-create})
                                    else integer({&hn-update}))
            buf_c-cli-hist.subject = {&table_thbj-attr}
            buf_c-cli-hist.host-code = v-host-code
            buf_c-cli-hist.is-news = g#news
            buf_c-cli-hist.source-type = (if g#news then {&hn-source-db} else "":U)
            buf_c-cli-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
            .
          end.
        when {&table_schedule} then do:
          /*нет куста истории у расписания*/
          buf_c-rule-by-call.chip-num = next-value(s-ref-corr-chip, {&db-name_schema}).
        end.
          otherwise do:
            message
            vss-workfile vss-revision vss-description skip
            "НЕПОНЯТНАЯ ТОЧКА ВЫЗОВА " entry(1, ub.rule-by-call.call_id, {&delim-key})
            view-as alert-box error .
            undo main-block, return error .
          end.
        end case .
      end.
    end.
  end.
  /*callnews.p не вызываем, потому что работаем через cmd-bush*/
  if g#oxml = yes
  then do:
  run str/calloxml.p (
        input {&nwsdochs_action_update}
      , input {&table_rule-by-call}
      , input ( buffer ub.rule-by-call:handle )
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