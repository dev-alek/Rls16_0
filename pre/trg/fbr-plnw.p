block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.fbr-pln old buffer old-fbr-pln .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись документа план-меню".
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
main-block:
do transaction
on error undo main-block, return error
:
    if ub.fbr-pln.creid = ""
    then do:
        assign
            ub.fbr-pln.creid = g#userid
        .
    end.
    if not g#news
    then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output ub.fbr-pln.user-db-num
  ,output ub.fbr-pln.user-name
  ,output ub.fbr-pln.sys-date
  ,output ub.fbr-pln.sys-time
  ,output ub.fbr-pln.sys-time-int
  )  .
    end.
    if not g#news
    then do:
        run trg/fbr-plnh.p (
              buffer old-fbr-pln
            , buffer ub.fbr-pln
        ) no-error .
        if error-status:error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при создании истории изменений документа план-меню"
                skip "Документ" ub.fbr-pln.doc-code
            view-as alert-box .
            undo main-block, return error.
        end.
    end.
    if ub.fbr-pln.status_ = 'факт':U
    then do:
        if not g#news
        then do:
            run gbl/chk-date.p (
                  input ub.fbr-pln.obj-type
                , input ub.fbr-pln.obj-code
                , input ub.fbr-pln.fact-date
                , input 1
                , input ub.fbr-pln.shift-date
                , input ub.fbr-pln.shift-num
                , yes
            ) no-error.
            if error-status:error
            then do:
                message
                    "Ошибка при установке дат, времен, смен в документе план-меню (fbr-pln)."
                view-as alert-box error.
                undo main-block, return error.
            end.
        end.
        if old-fbr-pln.status_ <> ub.fbr-pln.status_
        then do:
            run str/callnews.p (
                  input "fbr-pln"
                , input (buffer  ub.fbr-pln :handle)
            ) no-error .
            if error-status:error
            then do:
                message
                    vss-workfile vss-revision vss-description
                    skip "Ошибка при передаче документа план-меню в новости"
                    skip "Документ" ub.fbr-pln.doc-code
                view-as alert-box .
                undo main-block, return error.
            end.
        end.
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'fbr-pln':U
        , input ( buffer ub.fbr-pln:handle )
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
END.
