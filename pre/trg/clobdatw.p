block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.clob-data.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись CLOB-data".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable v-send as logical   no-undo .
define variable v-call-handle as handle no-undo .
define buffer buf_clob-bind for ub.clob-bind.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
    if lookup(ub.clob-data.resource-type, 'data,gate,upgrade,report,report-xml,list,list-macro,ref,egais-wb,egais-ref-b,egais-ab,egais-awo,egais-wb-act,egais-ticket,egais-wb-ticket,egais-ab_shop,egais-awo_shop,egais-tts,egais-tfs,egais-qb':U) = 0 then do:
      message
      substitute("Неизвестный resource-type = &1 для clob-data", ub.clob-data.resource-type)
      view-as alert-box error .
      undo main-block, return error .
    end.
    if not g#news then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output ub.clob-data.user-db-num
  ,output ub.clob-data.user-name
  ,output ub.clob-data.sys-date
  ,output ub.clob-data.sys-time
  ,output ub.clob-data.sys-time-int
  )  .
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
          (input 'clob-data':U
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
   else do:
      find first buf_clob-bind no-lock where
        buf_clob-bind.db-num = ub.clob-data.db-num
        and buf_clob-bind.int64-id = ub.clob-data.int64-id no-error.
     if ub.clob-data.is-cs = yes
     and g#db-num = 0
     and ub.clob-data.crc-field <> '':U
     and not
      (available (buf_clob-bind)
          and (buf_clob-bind.resource-type = 'egais-wb':U
          or buf_clob-bind.resource-type = 'egais-ref-b':U
          or buf_clob-bind.resource-type = 'egais-wb-act':U
          or buf_clob-bind.resource-type = 'egais-ticket':U
          or buf_clob-bind.resource-type = 'egais-wb-ticket':U
          or buf_clob-bind.resource-type = 'egais-ab':U
          or buf_clob-bind.resource-type = 'egais-awo':U
          or buf_clob-bind.resource-type = 'egais-ab_shop':U
          or buf_clob-bind.resource-type = 'egais-awo_shop':U
          or buf_clob-bind.resource-type = 'egais-tts':U
          or buf_clob-bind.resource-type = 'egais-tfs':U
          or buf_clob-bind.resource-type = 'egais-qb':U))
     then do:
      run str/callnews.p ( input 'clob-data':U
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
    end.
  end.
end.
