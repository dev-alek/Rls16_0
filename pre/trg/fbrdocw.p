block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.fbr-doc old buffer old-fbr-doc .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись документа производства".
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
define variable v-message as character no-undo .
main-block:
do transaction
on error undo main-block, return error
:
    if ub.fbr-doc.creid = "" then do:
        assign
        ub.fbr-doc.creid = g#userid
        .
    end.
    if not g#news
    then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output ub.fbr-doc.user-db-num
  ,output ub.fbr-doc.user-name
  ,output ub.fbr-doc.sys-date
  ,output ub.fbr-doc.sys-time
  ,output ub.fbr-doc.sys-time-int
  )  .
    end.
    if not g#news
    then do:
        run trg/fbrdoch.p (
          buffer old-fbr-doc
        , buffer ub.fbr-doc
        ) no-error .
        if error-status:error
        then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при создании истории изменений документа производства" skip
                "Документ" ub.fbr-doc.doc-code skip
                view-as alert-box .
            undo main-block, return error.
        end.
    end.
    if ub.fbr-doc.status_ = 'факт':U then do:
        if not g#news then do:
        run gbl/chk-date.p
            (input ub.fbr-doc.obj-type
            ,input ub.fbr-doc.obj-code
            ,input ub.fbr-doc.fact-date
            ,input 1
            ,input ub.fbr-doc.shift-date
            ,input ub.fbr-doc.shift-num
            ,yes) no-error.
        if error-status:error then do:
            message "Ошибка при установке дат, времен, смен в документе производства(fbr-doc)."
            view-as alert-box.
            undo main-block, return error.
        end.
        end.
        if old-fbr-doc.status_ <> ub.fbr-doc.status_
        then do:
            run str/callnews.p
            (input "fbr-doc"
            ,input (buffer ub.fbr-doc:handle)
            ) no-error .
            if error-status:error then do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при передаче документа производства в новости" skip
                "Документ" ub.fbr-doc.doc-code skip
                view-as alert-box .
            undo main-block, return error.
            end.
        end.
    end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'fbr-doc':U
        , input ( buffer ub.fbr-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'event_fbr-doc':U
  ,input  buffer old-fbr-doc:handle
  ,input  buffer ub.fbr-doc:handle
  ,input ''
  ,input ''
  ) no-error .
    if error-status:error
    then do:
      v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
                            ,vss-workfile
                            ,vss-revision
                            ,vss-description
                            ,chr(10)
                            , error-status:get-message(1)
                            , return-value ).
      if not g#news then do:
        message
        v-message
        view-as alert-box error .
      end.
      undo main-block,  return error v-message.
    end.
END.
