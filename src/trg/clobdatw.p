block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись CLOB-data

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/07
Author: Bakhtadze Natalya
Creation date: 12/28/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.clob-data.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись CLOB-data".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-send as logical   no-undo .
define variable v-call-handle as handle no-undo .
define buffer buf_clob-bind for ub.clob-bind.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
    /*отследим возможные типы ub.clob-data.resource-type*/
    if lookup(ub.clob-data.resource-type, {&clob-res-codes}) = 0 then do:
      message
      substitute("Неизвестный resource-type = &1 для clob-data", ub.clob-data.resource-type)
      view-as alert-box error .
      undo main-block, return error .
    end.


    if not g#news then do:
      { gbl/curdburt.i
        ub.clob-data.user-db-num
        ub.clob-data.user-name
        ub.clob-data.sys-date
        ub.clob-data.sys-time
        ub.clob-data.sys-time-int
      }
      if ub.clob-data.crc-field <> '':U then do:
        v-call-handle = this-procedure:instantiating-procedure.
        if lookup("cb_set-send-nws", v-call-handle:internal-entries) > 0 then do:
          run cb_set-send-nws in v-call-handle ( output v-send) .
        end.
        else do:
          v-send = yes.
        end.
        if v-send then do:
        run str/callnews.p
          (input {&table_clob-data}
          ,input (buffer ub.clob-data:handle)
          ) no-error .
        if error-status:error then do:
          if error-status :get-message(1) <> ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры callnews.p" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          undo main-block,  return error return-value .
        end.
      end.
   end.
   end.
   else do:  /*если g#news*/
      find first buf_clob-bind no-lock where
        buf_clob-bind.db-num = ub.clob-data.db-num
        and buf_clob-bind.int64-id = ub.clob-data.int64-id no-error.
     if ub.clob-data.is-cs = yes
     and g#db-num = 0
     and ub.clob-data.crc-field <> '':U
     and not
      (available (buf_clob-bind)
          and (buf_clob-bind.resource-type = {&lob-egais-wb}
          or buf_clob-bind.resource-type = {&lob-egais-ref-b}
          or buf_clob-bind.resource-type = {&lob-egais-wb-act}
          or buf_clob-bind.resource-type = {&lob-egais-ticket}
          or buf_clob-bind.resource-type = {&lob-egais-wb-ticket}
          or buf_clob-bind.resource-type = {&lob-egais-ab}
          or buf_clob-bind.resource-type = {&lob-egais-awo}
          or buf_clob-bind.resource-type = {&lob-egais-ab_shop}
          or buf_clob-bind.resource-type = {&lob-egais-awo_shop}
          or buf_clob-bind.resource-type = {&lob-egais-tts}
          or buf_clob-bind.resource-type = {&lob-egais-tfs}
          or buf_clob-bind.resource-type = {&lob-egais-qb}))
     then do:
      run str/callnews.p ( input {&table_clob-data}
                        ,input (buffer ub.clob-data:handle)
                        ) no-error .
      if error-status:error then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове callnews.p" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo main-block,  return error return-value .
      end.
    end. /*if ub.clob-data.is-cs = yes*/
  end. /*else do:  если g#news*/
end.