block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись связки ПРОФАЙЛ ПРАВИЛ - МЕСТО ВЫЗОВА

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/07/07
Author: Bakhtadze Natalya
Creation date: 01/07/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.rp-by-call OLD old_rp-by-call.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись связки ПРОФАЙЛ ПРАВИЛ - МЕСТО ВЫЗОВА".
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                         , ub.rp-by-call.profile_id
                         , ub.rp-by-call.call#_id
                         , ub.rp-by-call.once-more
                         ) " }

{ cmp/trg-def.i }

{ gbl/cur-time.i }
{ gbl/key-rec.i }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-call#-id as integer no-undo .
define variable v-host-code as integer   no-undo .
define buffer buf_c-rp-by-call for ub.c-rp-by-call.
define buffer buf_c-dis-card-type for ub.c-dis-card-type.
define buffer buf_c-thbj-attr for ub.c-thbj-attr.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_c-cli-hist for ub.c-cli-hist.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news
  and new(ub.rp-by-call) then do:
    if ub.rp-by-call.call#_id = 0 then do:
      run rul/g-callid.p ( input entry(1, ub.rp-by-call.call_Id, {&delim-par})
                          ,input ub.rp-by-call.call_Id
                          ,output v-call#-id).
      assign
      ub.rp-by-call.call#_id = v-call#-id
      .

    end.
  end.
  if not g#news
  or g#db-num <> 0 then do:
    define variable v-cmp as logical no-undo .
    if not new(ub.rp-by-call) then do:
      buffer-compare ub.rp-by-call
      to old_rp-by-call
      case-sensitive
      save result in v-cmp.
    end.
    else do:
      v-cmp = no.
    end.
    if not v-cmp then do:
      run cur-time in this-procedure ( output v-date, output v-time).
      create buf_c-rp-by-call.
      assign
      buf_c-rp-by-call.call_id = ub.rp-by-call.call_id
      buf_c-rp-by-call.call#_id = ub.rp-by-call.call#_id
      buf_c-rp-by-call.profile_id = ub.rp-by-call.profile_id
      buf_c-rp-by-call.once-more = ub.rp-by-call.once-more
      buf_c-rp-by-call.corr-time          = v-time
      buf_c-rp-by-call.corr-user-db-num   = g#db-num
      buf_c-rp-by-call.corr-user-name     = (if g#news
                                      then {&nts-user}
                                      else g#userid)
      buf_c-rp-by-call.corr-date          = v-date
      .
      run  gen-key-fv in this-procedure (
                                          input ub.rp-by-call.call_id
                                        ,output v-field-list
                                        ,output v-value-list).
      if ub.rp-by-call.call_id begins {&table_dis-card-type} then do:
        create buf_c-dis-card-type.
        buffer-copy buf_c-rp-by-call
        except chip-num
        to buf_c-dis-card-type
        assign
        buf_c-dis-card-type.chip-num =  next-value (s-dc-chip, {&db-name_schema})
        buf_c-rp-by-call.chip-num    = buf_c-dis-card-type.chip-num
        buf_c-dis-card-type.uniq-key-rec = buf_c-rp-by-call.call_id
        buf_c-dis-card-type.type =  entry(lookup("type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
        buf_c-dis-card-type.emitent-host-code = integer(entry(lookup("emitent-host-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
        buf_c-dis-card-type.action             = integer(if new(ub.rp-by-call) then {&hn-create} else {&hn-update})
        buf_c-dis-card-type.subject            = {&table_rp-by-call}
        .
      end.
      if ub.rp-by-call.call_id begins {&table_thbj-attr} then do:
        create buf_c-thbj-attr.
        buffer-copy buf_c-rp-by-call
        except chip-num
        to buf_c-thbj-attr
        assign
        buf_c-thbj-attr.chip-num =  next-value (s-cli-chip, {&db-name_schema})
        buf_c-rp-by-call.chip-num    = buf_c-thbj-attr.chip-num
        buf_c-thbj-attr.prop-code         = entry(lookup("prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key})
        buf_c-thbj-attr.upper-prop-code   = entry(lookup("upper-prop-code", v-field-list, {&delim-key}), v-value-list, {&delim-key})
        buf_c-thbj-attr.obj-type          = entry(lookup("obj-type", v-field-list, {&delim-key}), v-value-list, {&delim-key})
        buf_c-thbj-attr.obj-code          = integer(entry(lookup("obj-code", v-field-list, {&delim-key}), v-value-list, {&delim-key}))
        buf_c-thbj-attr.action             = integer(if new(ub.rp-by-call) then {&hn-create} else {&hn-update})
        buf_c-thbj-attr.subject            = {&table_rp-by-call}
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
        buf_c-cli-hist.action = (if new (ub.thbj-attr )
                                then integer({&hn-create})
                                else integer({&hn-update}))
        buf_c-cli-hist.subject = {&table_thbj-attr}
        buf_c-cli-hist.host-code = v-host-code
        buf_c-cli-hist.is-news = g#news
        buf_c-cli-hist.source-type = (if g#news then {&hn-source-db} else "":U)
        buf_c-cli-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
        .
      end.
      if ub.rp-by-call.call_id begins {&table_schedule} then do:
        /*нет куста истории у расписания*/
        buf_c-rp-by-call.chip-num = next-value(s-ref-corr-chip, {&db-name_schema}).
      end.

    end.
  end.
  /*callnews.p не вызываем, потому что работаем через cmd-bush*/
  if g#oxml = yes
  then do:
    run str/calloxml.p (
        input {&nwsdochs_action_update}
      , input {&table_rp-by-call}
      , input ( buffer ub.rp-by-call:handle )
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
end. /*doe*/