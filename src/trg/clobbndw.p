block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись clob-bind

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/07
Author: Bakhtadze Natalya
Creation date: 12/28/07

*/

TRIGGER PROCEDURE FOR WRITE OF ub.clob-bind.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись clob-bind".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-send as logical   no-undo .
define variable v-call-handle as handle no-undo .
define buffer buf_clob-bind for ub.clob-bind.
output to delclob.txt append.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

    /*отследим возможные типы ub.clob-bind.resource-type*/
    if lookup(ub.clob-bind.resource-type, {&clob-res-codes}) = 0 then do:
      message
      substitute("Неизвестный resource-type = &1 для clob-bind", ub.clob-bind.resource-type)
      view-as alert-box error .
      undo main-block, return error .
    end.
    if ub.clob-bind.resource-type = {&lob-res-gate}
    and g#db-num > 0
    and not g#news then do:
      message
      substitute("Не разрешено менять gate в УБД")
      view-as alert-box error .
      undo main-block, return error .
    end.
    if ub.clob-bind.resource-type = {&lob-res-gate}
    or new(ub.clob-bind) then do:
      { gbl/curdburt.i
        ub.clob-bind.user-db-num
        ub.clob-bind.user-name
        ub.clob-bind.sys-date
        ub.clob-bind.sys-time
        ub.clob-bind.sys-time-int
      }
    end.

   if g#db-num = 0 
   and
    (ub.clob-bind.resource-type = {&lob-egais-wb}
        or ub.clob-bind.resource-type = {&lob-egais-ref-b}
        or ub.clob-bind.resource-type = {&lob-egais-wb-act}
        or ub.clob-bind.resource-type = {&lob-egais-ticket}
        or ub.clob-bind.resource-type = {&lob-egais-wb-ticket}
        or ub.clob-bind.resource-type = {&lob-egais-ab}
        or ub.clob-bind.resource-type = {&lob-egais-awo}
        or ub.clob-bind.resource-type = {&lob-egais-ab_shop}
        or ub.clob-bind.resource-type = {&lob-egais-awo_shop}
        or ub.clob-bind.resource-type = {&lob-egais-tts}
        or ub.clob-bind.resource-type = {&lob-egais-tfs}
        or ub.clob-bind.resource-type = {&lob-egais-qb})
   and not g#news
   then do:     
     if ub.clob-bind.db-num = 0 
       then 
     do:
       find first buf_clob-bind no-lock
         where buf_clob-bind.db-num <> 0 and  buf_clob-bind.resource-type = ub.clob-bind.resource-type and  buf_clob-bind.uniq-key-rec = ub.clob-bind.uniq-key-rec and recid (buf_clob-bind) <> recid (ub.clob-bind) no-error.
       if available (buf_clob-bind)
         then 
       do:
         undo main-block,  return error
           vss-workfile + vss-revision + vss-description + {&new-line} +
           "Ошибка при вызове при сохранении записи clob-bind" + {&new-line} +
           "Уже есть запись для " + ub.clob-bind.resource-type + {&new-line} +
           "С индетификатором " + ub.clob-bind.uniq-key-rec + {&new-line} +
           "полученная из БД " + string (buf_clob-bind.db-num) + {&new-line}
           .
       end.
     end.
   end.

    if not g#news then do:
      v-call-handle = this-procedure:instantiating-procedure.
      if valid-handle (v-call-handle) and lookup("cb_set-send-nws", v-call-handle:internal-entries) > 0 then do:
        run cb_set-send-nws in v-call-handle ( output v-send) .
      end.
      else do:
        v-send = yes.
      end.
      if (g#db-num = 0 
         and
          (ub.clob-bind.resource-type = {&lob-egais-wb}
              or ub.clob-bind.resource-type = {&lob-egais-ref-b}
              or ub.clob-bind.resource-type = {&lob-egais-wb-act}
              or ub.clob-bind.resource-type = {&lob-egais-ticket}
              or ub.clob-bind.resource-type = {&lob-egais-wb-ticket}
              or ub.clob-bind.resource-type = {&lob-egais-ab}
              or ub.clob-bind.resource-type = {&lob-egais-awo}
              or ub.clob-bind.resource-type = {&lob-egais-ab_shop}
              or ub.clob-bind.resource-type = {&lob-egais-awo_shop}
              or ub.clob-bind.resource-type = {&lob-egais-tts}
              or ub.clob-bind.resource-type = {&lob-egais-tfs}
              or ub.clob-bind.resource-type = {&lob-egais-qb}))
        then v-send = false.                      
      if v-send then do:
        run str/callnews.p
          (input {&table_clob-bind}
          ,input (buffer ub.clob-bind:handle)
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
   else do: /*если g#news*/
     if g#db-num = 0 
     and not
      (ub.clob-bind.resource-type = {&lob-egais-wb}
          or ub.clob-bind.resource-type = {&lob-egais-ref-b}
          or ub.clob-bind.resource-type = {&lob-egais-wb-act}
          or ub.clob-bind.resource-type = {&lob-egais-ticket}
          or ub.clob-bind.resource-type = {&lob-egais-wb-ticket}
          or ub.clob-bind.resource-type = {&lob-egais-ab}
          or ub.clob-bind.resource-type = {&lob-egais-awo}
          or ub.clob-bind.resource-type = {&lob-egais-ab_shop}
          or ub.clob-bind.resource-type = {&lob-egais-awo_shop}
          or ub.clob-bind.resource-type = {&lob-egais-tts}
          or ub.clob-bind.resource-type = {&lob-egais-tfs}
          or ub.clob-bind.resource-type = {&lob-egais-qb})
     then do:
      define buffer buf_clob-data for ub.clob-data.
      find first buf_clob-data no-lock where
                buf_clob-data.db-num = ub.clob-bind.db-num
            and buf_clob-data.int64-id = ub.clob-bind.int64-id no-error.
      if available buf_clob-data
      and buf_clob-data.is-cs = yes then do:
        run str/callnews.p ( input {&table_clob-bind}
                          ,input (buffer ub.clob-bind:handle)
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
      end. /*if available buf_clob-data*/
     end. /*if g#db-num = 0 then do:*/
     if g#db-num = 0 
     and
      (ub.clob-bind.resource-type = {&lob-egais-wb}
          or ub.clob-bind.resource-type = {&lob-egais-ref-b}
          or ub.clob-bind.resource-type = {&lob-egais-wb-act}
          or ub.clob-bind.resource-type = {&lob-egais-ticket}
          or ub.clob-bind.resource-type = {&lob-egais-wb-ticket})
     then do:     
       for each buf_clob-bind where 
         buf_clob-bind.uniq-key-rec = ub.clob-bind.uniq-key-rec and recid (buf_clob-bind) <> recid (ub.clob-bind)
         and buf_clob-bind.resource-type = ub.clob-bind.resource-type and buf_clob-bind.db-num = 0:
          export buf_clob-bind.
          delete buf_clob-bind.
       end.
     end.
   end. /*else do: если g#news*/
   
   /*calloxml.p вызывать не надо*/
end.

/* $Workfile$ e n d */