block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Передача настроек для проверки КМ".
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
define variable mdb-num     as integer   no-undo.
define variable mObjType    as character no-undo.
define variable mObjCode    as integer   no-undo.
define variable mPostType   as character no-undo.
define variable mCashNum    as integer   no-undo.
define variable mDeviceKind as integer   no-undo.
define variable mSend       as logical   no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE shared TEMP-TABLE thbjattr-list no-undo like ub.thbj-attr .
 define variable gismt-AdressPort   as character no-undo.
 define variable gismt-DopParam     as character no-undo.
 define variable gismt-GisAdress    as character no-undo.
 define variable gismt-ProxyLogin   as character no-undo.
 define variable gismt-ProxyPswd    as character no-undo.
 define variable gismt-MaxTime      as integer   no-undo.
 define variable gismt-RegKey       as character no-undo.
 define variable gismt-TimeFalStart as integer   no-undo.
 define variable gismt-WaitTime     as decimal   no-undo.
 define variable gismt-WaitTimePlus as decimal   no-undo.
 define variable gismt-CrashSituat  as logical   no-undo.
 define variable gismt-BanDate      as integer   no-undo.
 define variable gismt-cdnTurnOn    as logical   no-undo.
 define variable gismt-cdnAdress    as character no-undo.
 define variable gismt-cdnRepeat    as logical   no-undo.
 define variable gismt-cdnChange    as logical   no-undo.
 define variable gismt-cdnTimeUpd   as integer   no-undo.
 define variable gismt-UpdateRequest as logical   no-undo.
 define variable gismt-OflineAdress  as character no-undo.
 define variable gismt-OflineAutoriz as character no-undo.
 define variable gismt-OflineLogin   as character no-undo.
 define variable gismt-OflinePswd    as character no-undo.
 define variable gismt-OflineDate    as date      no-undo.
function ConvBase64 return character
(input iString as char):
  define variable vSize       as integer   no-undo.
  define variable vDataDc1    as memptr    no-undo.
  define variable vDataDc2    as memptr    no-undo.
  define variable vEnCode     as character no-undo.
  define variable vBase64Str  as character no-undo.
  do
  on error undo, return error return-value
  :
    if iString = ?
    then return "".
    vSize  = length(iString).
    SET-SIZE(vDataDc1 ) = vSize + 1.
    SET-SIZE(vDataDc2 ) = vSize.
    put-string(vDataDc1, 1, vSize) = iString.
    copy-lob from vDataDc1 starting at 1 for vSize to vDataDc2 no-convert.
    vEnCode =  base64-encode (vDataDc2).
    vBase64Str = substring(vEnCode,1).
    SET-SIZE(vDataDc1)  = 0 no-error.
    SET-SIZE(vDataDc2)  = 0 no-error.
  end.
  return vBase64Str.
end.
function get-thbj-attr-prop return character
(input p-obj-type as char,
 input p-obj-code as int,
 input p-upper-prop-code as char,
 input p-prop-code as char
 ):
    define buffer buf_thbj-attr for ub.thbj-attr.
    define variable v-reg-code as integer no-undo.
    find first buf_thbj-attr no-lock where
               buf_thbj-attr.obj-type = p-obj-type
           and buf_thbj-attr.obj-code = p-obj-code
           and buf_thbj-attr.upper-prop-code = p-upper-prop-code
           and buf_thbj-attr.prop-code = p-prop-code
    no-error.
    if not available buf_thbj-attr and p-obj-type = 'БД':U then
    do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run regcode in ibs.th.gbl.gbl-hndllib:g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-reg-code
  )  .
       if v-reg-code <> ? and v-reg-code <> 0 then do:
           find first buf_thbj-attr no-lock where
                      buf_thbj-attr.obj-type = 'регион':U
                  and buf_thbj-attr.obj-code = v-reg-code
                  and buf_thbj-attr.upper-prop-code = p-upper-prop-code
                  and buf_thbj-attr.prop-code = p-prop-code
           no-error.
       end.
    end.
    if not available buf_thbj-attr and p-obj-type <> ""
    then do:
       find first buf_thbj-attr no-lock where
                  buf_thbj-attr.obj-type = ""
              and buf_thbj-attr.obj-code = 0
              and buf_thbj-attr.upper-prop-code = p-upper-prop-code
              and buf_thbj-attr.prop-code = p-prop-code
       no-error.
    end.
    if avail buf_thbj-attr then do:
        case buf_thbj-attr.prop-value-type:
            when "character"
               then return buf_thbj-attr.property-value-character.
            when "integer"
               then return string(buf_thbj-attr.property-value-integer).
            when "decimal"
               then return string(buf_thbj-attr.property-value-decimal).
            when "logical"
               then return string(buf_thbj-attr.property-value-logical).
        end case.
    end.
    return "".
end.
function get-gismt-prop return character
(input p-obj-type as char,
 input p-obj-code as int):
    define buffer buf_code for ub.code.
    define buffer buf_thbj-attr for ub.thbj-attr.
    assign
       gismt-AdressPort = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'adressPort':U)
       gismt-DopParam   = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'dopParam':U)
       gismt-GisAdress  = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'gisAdress':U)
       gismt-ProxyLogin = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'proxyLogin':U)
       gismt-ProxyPswd  = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'proxyPswd':U)
       gismt-MaxTime    = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'maxTime':U))
       gismt-RegKey     = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'regKey':U)
       gismt-TimeFalStart = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'timeFalStart':U))
       gismt-WaitTime    = decimal(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'waitTime':U))
       gismt-CrashSituat = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'crashSituat':U))
       gismt-BanDate     = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'banDate':U))
       gismt-cdnTurnOn   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnTurnOn':U))
       gismt-cdnAdress   = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnAdress':U)
       gismt-cdnRepeat   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnRepeat':U))
       gismt-cdnChange   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnChange':U))
       gismt-cdnTimeUpd  = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnTimeUpdate':U))
       gismt-UpdateRequest = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'UpdateRequest':U))
       gismt-OflineAdress  = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'OflineAdress':U)
       gismt-OflineLogin   = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'OflineLogin':U)
       gismt-OflinePswd    = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'OflinePswd':U)
       .
    if gismt-OflineLogin <> "" and gismt-OflinePswd <> ""
    then gismt-OflineAutoriz = ConvBase64(gismt-OflineLogin + ":" + gismt-OflinePswd).
    find first buf_code no-lock where
               buf_code.parent eq "GisMtOffline"
           and buf_code.code   eq string(p-obj-code)
       no-error.
    if not avail buf_code then
    find first buf_code no-lock where
               buf_code.parent eq "GisMtOffline"
           and buf_code.code   eq "0"
       no-error.
    if avail buf_code then  gismt-OflineDate = date(buf_code.CodeValue) no-error.
    else gismt-OflineDate = today.
  return "".
end.
function get-code-typemark return character
    (p-typemark as character):
        def buffer buf_code for ub.code.
   find first buf_code where
            buf_code.parent = "MarkType"
        and buf_code.CodeValue = p-typemark
       no-lock no-error.
   if avail buf_code then return buf_code.code.
   else return "".
end.
function get-list-code-typemark return character
    (p-list-typemark as character):
   def var vCount as int no-undo.
   def var vListCode as char no-undo.
   def var vCode as char no-undo.
   do vCount = 1 to num-entries(p-list-typemark):
      vCode = get-code-typemark(entry(vCount,p-list-typemark)).
      if vCode <> "" then vListCode = substitute("&1,&2",vListCode,int(vCode)).
   end.
   vListCode = substring(vListCode,2).
   return vListCode.
end.
procedure putc :
   define input parameter iSAXWriter as handle no-undo .
   define input parameter i-action   as character  no-undo .
   define input parameter p-value    as character  no-undo .
   define output parameter oSend      as logical    no-undo.
   define variable vTypesForKass as character no-undo.
   define variable vTimeDate as character no-undo.
   define buffer buf_code for ub.code.
   define buffer buf_thbj-attr for ub.thbj-attr.
   DEFINE BUFFER buf_sys-ctrl FOR ub.sys-ctrl .
   DEFINE VARIABLE vRetProp AS CHARACTER NO-UNDO.
   DEFINE VARIABLE vCdnAdr AS CHARACTER NO-UNDO.
   define variable vCount        as integer   no-undo.
   define variable vAll as logical no-undo.
   define variable vCheckBlock    as character no-undo.
   define variable vCheckDate     as character no-undo.
   define variable vCheckMRC      as character no-undo.
   define variable vCheckOwner    as character no-undo.
   define variable vCheckStatusKM as character no-undo.
   define variable vCheckTracking as character no-undo.
   define variable vMACC_Timeout  as decimal   no-undo.
   define variable vResp_TH_requiredr as integer no-undo.
   define variable vMACC_IP        as character no-undo.
   define variable vLmCHzPort      as character no-undo.
   define variable vTH_IP          as character no-undo.
   define variable vTH_Port        as character no-undo.
   define variable vAddTimeoutPIoT as decimal   no-undo.
   define variable vMaxApiToken    as character no-undo.
   define variable vAgeConfirm     as integer   no-undo.
   define variable v-reg-code      as integer   no-undo.
   assign
      vAll = yes
      vMACC_IP = ""
      vTH_IP = ""
      vTH_Port = ""
      vLmCHzPort = ""
      vMaxApiToken = ""
      mSend = no.
   .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run regcode in ibs.th.gbl.gbl-hndllib:g#library
  (input  'БД':U
  ,input  mdb-num
  ,output v-reg-code
  )  .
   thlist:
   for each thbjattr-list :
     if vAll = yes then vAll = no.
       if    thbjattr-list.obj-type = 'регион':U
         and (thbjattr-list.obj-code <> v-reg-code
              or can-find(first buf_thbj-attr no-lock where
                                buf_thbj-attr.obj-type = 'БД':U
                            and buf_thbj-attr.obj-code = mdb-num
                            and buf_thbj-attr.upper-prop-code = thbjattr-list.upper-prop-code
                            and buf_thbj-attr.prop-code = thbjattr-list.prop-code)  )
          then next thlist.
       if thbjattr-list.upper-prop-code = 'gisMT':U
          and thbjattr-list.obj-type = ""
          and can-find(first buf_thbj-attr no-lock where
                             buf_thbj-attr.obj-type = 'регион':U
                         and buf_thbj-attr.obj-code = v-reg-code
                         and buf_thbj-attr.upper-prop-code = thbjattr-list.upper-prop-code
                         and buf_thbj-attr.prop-code = thbjattr-list.prop-code)
          then next thlist.
     find first buf_thbj-attr no-lock where
               buf_thbj-attr.obj-type = thbjattr-list.obj-type
           and buf_thbj-attr.obj-code = thbjattr-list.obj-code
           and buf_thbj-attr.upper-prop-code = thbjattr-list.upper-prop-code
           and buf_thbj-attr.prop-code = thbjattr-list.prop-code
           no-error.
     if not avail buf_thbj-attr then next thlist.
     case buf_thbj-attr.prop-code:
        when 'checkBlock':U then do:
           run put-xml-data(iSAXWriter,"GS1","checkBlock",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки блокировок контролирующих органов").
        end.
        when 'checkDate':U then do:
           run put-xml-data(iSAXWriter,"GS1","checkDate",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки срока годности").
        end.
        when 'checkMRC':U then do:
           run put-xml-data(iSAXWriter,"GS1","checkMRC",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки МРЦ").
        end.
        when 'checkOwner':U then do:
           run put-xml-data(iSAXWriter,"GS1","checkOwner",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки владельца").
        end.
        when 'checkStatusKM':U then do:
           run put-xml-data(iSAXWriter,"GS1","checkStatusKM",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки статуса КМ").
        end.
        when 'checkTracking':U then do:
           run put-xml-data(iSAXWriter,"GS1","checkTracking",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки флага прослеживаемости").
        end.
        when 'maxTime':U then do:
           run put-xml-data(iSAXWriter,"GS1","Max_allowed_time",string(buf_thbj-attr.property-value-integer),"Макс. допустимое время разрешения продажи при сбое онлайн проверки (часы)").
        end.
        when 'timeFalStart':U then do:
           run put-xml-data(iSAXWriter,"GS1","Failure_time",string(buf_thbj-attr.property-value-integer),"Время с момента сбоя до начала уведомления персонала (часы)").
        end.
        when 'crashSituat':U then do:
           run put-xml-data(iSAXWriter,"GS1","emergencyMode",(if buf_thbj-attr.property-value-logical then "1" else "0"),"Признак аварийной ситуации в ГИС МТ").
        end.
        when 'banDate':U then do:
           run put-xml-data(iSAXWriter,"GS1","Before_Expiration",string(buf_thbj-attr.property-value-integer),"Опережение срабатывания запрета по сроку годности в минутах").
        end.
        when 'adressPort':U then do:
            run put-xml-data(iSAXWriter,"GS1","Proxy_IP",buf_thbj-attr.property-value-character,"Адрес и порт прокси").
        end.
        when 'proxyLogin':U then do:
           run put-xml-data(iSAXWriter,"GS1","Proxy_Login",buf_thbj-attr.property-value-character,"Логин для подключения к прокси-серверу").
        end.
        when 'proxyPswd':U then do:
            run put-xml-data(iSAXWriter,"GS1","Proxy_Pass",buf_thbj-attr.property-value-character,"Пароль для подключения к прокси-серверу").
        end.
        when 'waitTime':U then do:
            run put-xml-data(iSAXWriter,"GS1","MACC_TimeoutGISMT",string(buf_thbj-attr.property-value-decimal),"Длительность ожидания ответа ТС ПИоТ").
        end.
        when 'MACC_Timeout':U then do:
           if buf_thbj-attr.property-value-decimal <> 0 then
              run put-xml-data(iSAXWriter,"GS1","MACC_Timeout",string(buf_thbj-attr.property-value-decimal),"Длительность ожидания ответа ТН").
        end.
        when 'OflineLogin':U then do:
            run put-xml-data(iSAXWriter,"GS1","LmCHzLogin",buf_thbj-attr.property-value-character,"Логин для доступа ЛМ ЧЗ").
         END.
        when 'OflinePswd':U then do:
            run put-xml-data(iSAXWriter,"GS1","LmCHzPass",buf_thbj-attr.property-value-character,"Пароль для доступа ЛМ ЧЗ").
        end.
        when 'Resp_TH_required':U then do:
            run put-xml-data(iSAXWriter,"GS1","Resp_TH_required",string(buf_thbj-attr.property-value-integer),"Обязательность получения результатов проверки КМ в ТН").
        end.
        when 'TH_IP':U then vTH_IP = buf_thbj-attr.property-value-character.
        when 'TH_Port':U then vTH_Port = buf_thbj-attr.property-value-character.
        when 'LmCHzPort':U then vLmCHzPort = buf_thbj-attr.property-value-character.
        when 'AddTimeoutPIoT':U then do:
             run put-xml-data(iSAXWriter,"GS1","MACC_additionalTimeoutPIoT",string(buf_thbj-attr.property-value-decimal),"Длительность обработки ответа ГИС МТ в ТС ПИоТ").
        end.
        when 'MaxApiToken':U then do:
           run put-xml-data(iSAXWriter,"GS1","MaxApiToken",buf_thbj-attr.property-value-character,"Токен авторизации MAX").
        end.
        when 'AgeConfirm':U then do:
            run put-xml-data(iSAXWriter,"UiSettings","NeedUserSimpleAgeConfirm",buf_thbj-attr.property-value-integer,"Проверка возраста при продаже НП").
        end.
     end case.
   end.
   if not vAll then do:
       if vTH_IP = ? then vTH_IP = "".
       if vTH_Port = ? then vTH_Port = "".
       if vTH_IP = "" and vTH_Port <> "" then vTH_IP = get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'TH_IP':U).
       if vTH_IP <> "" and vTH_Port = "" then vTH_Port = get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'TH_Port':U).
       if vTH_IP <> "" and vTH_Port <> "" then vMACC_IP = substitute("&1:&2",vTH_IP,vTH_Port).
       if vMACC_IP <> "" then
         run put-xml-data(iSAXWriter,"GS1","MACC_IP",vMACC_IP,"Адрес и порт для отправки запроса проверки марки в ТН").
       IF vTH_IP = "" and vTH_Port = "" and vLmCHzPort <> ""
       then do:
           vTH_IP = get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'TH_IP':U).
           vTH_Port = get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'TH_Port':U).
           if vTH_IP <> "" and vTH_Port <> "" then vMACC_IP = substitute("&1:&2",vTH_IP,vTH_Port).
       end.
       if vMACC_IP <> "" and vLmCHzPort <> "" then
         run put-xml-data(iSAXWriter,"GS1","LmCHzPort",vLmCHzPort,"Порт для отправки запроса проверки марки в ЛМ ЧЗ ").
   end.
   else do:
      assign
        vCheckBlock     = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,'marking':U,'checkBlock':U))
        vCheckDate      = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,'marking':U,'checkDate':U))
        vCheckMRC       = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,'marking':U,'checkMRC':U))
        vCheckOwner     = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,'marking':U,'checkOwner':U))
        vCheckStatusKM  = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,'marking':U,'checkStatusKM':U))
        vCheckTracking  = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,'marking':U,'checkTracking':U))
        .
      vRetProp = get-gismt-prop ('БД':U, mdb-num) NO-ERROR.
      assign
        vMACC_TimeOut   = DEC(get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'MACC_Timeout':U))
        vResp_TH_requiredr = INT(get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'Resp_TH_required':U))
        vTH_IP = get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'TH_IP':U)
        vTH_Port = get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'TH_Port':U)
        vLmCHzPort = get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'LmCHzPort':U)
        vAddTimeoutPIoT = DEC(get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'AddTimeoutPIoT':U))
        vMaxApiToken = get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'MaxApiToken':U)
        vAgeConfirm = INT(get-thbj-attr-prop('БД':U,mdb-num,'gisMT':U,'AgeConfirm':U))
        no-error.
      if vTH_IP = ? then vTH_IP = "".
      if vTH_Port = ? then vTH_Port = "".
      if vLmCHzPort = ? then vLmCHzPort = "".
      if vMaxApiToken = ? then vMaxApiToken = "".
      if vTH_IP <> "" and vTH_Port <> "" then vMACC_IP = substitute("&1:&2",vTH_IP,vTH_Port).
      if vCheckBlock <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkBlock",vCheckBlock,"Типы маркированной продукции для проверки блокировок контролирующих органов").
      if vCheckDate <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkDate",vCheckDate,"Типы маркированной продукции для проверки срока годности").
      if vCheckMRC <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkMRC",vCheckMRC,"Типы маркированной продукции для проверки МРЦ").
      if vCheckOwner <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkOwner",vCheckOwner,"Типы маркированной продукции для проверки владельца").
      if vCheckStatusKM <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkStatusKM",vCheckStatusKM,"Типы маркированной продукции для проверки статуса КМ").
      if vCheckTracking <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkTracking",vCheckTracking,"Типы маркированной продукции для проверки флага прослеживаемости").
      if vMACC_IP <> "" and vMACC_IP <> ? then
         run put-xml-data(iSAXWriter,"GS1","MACC_IP",vMACC_IP,"Адрес и порт для отправки запроса проверки марки в ТН").
      if gismt-OflineLogin <> ? then
      run put-xml-data(iSAXWriter,"GS1","LmCHzLogin",gismt-OflineLogin,"Логин для доступа ЛМ ЧЗ").
      if gismt-OflinePswd <> ? then
      run put-xml-data(iSAXWriter,"GS1","LmCHzPass",gismt-OflinePswd,"Пароль для доступа ЛМ ЧЗ").
      if gismt-AdressPort <> ? then
      run put-xml-data(iSAXWriter,"GS1","Proxy_IP",gismt-AdressPort,"Адрес и порт прокси").
      if gismt-ProxyLogin <> ? then
      run put-xml-data(iSAXWriter,"GS1","Proxy_Login",gismt-ProxyLogin,"Логин для подключения к прокси-серверу").
      if gismt-ProxyPswd <> ? then
      run put-xml-data(iSAXWriter,"GS1","Proxy_Pass",gismt-ProxyPswd,"Пароль для подключения к прокси-серверу").
      if vMACC_IP <> "" and vLmCHzPort <> ""
         and vMACC_IP <> ? and vLmCHzPort <> ? then
         run put-xml-data(iSAXWriter,"GS1","LmCHzPort",vLmCHzPort,"Порт для отправки запроса проверки марки в ЛМ ЧЗ ").
      if gismt-WaitTime <> ? then
      run put-xml-data(iSAXWriter,"GS1","MACC_TimeoutGISMT",string(gismt-WaitTime),"Длительность ожидания на стороне ТС ПИоТ ответа от ГИС МТ").
      if vAddTimeoutPIoT <> ? then
      run put-xml-data(iSAXWriter,"GS1","MACC_additionalTimeoutPIoT",string(vAddTimeoutPIoT),"Длительность обработки ответа ГИС МТ в ТС ПИоТ").
      if gismt-BanDate <> ? then
      run put-xml-data(iSAXWriter,"GS1","Before_Expiration",string(gismt-BanDate),"Опережение срабатывания запрета по сроку годности в минутах").
      if gismt-MaxTime <> ? then
      run put-xml-data(iSAXWriter,"GS1","Max_allowed_time",string(gismt-MaxTime),"Макс. допустимое время разрешения продажи при сбое онлайн проверки (часы)").
      if gismt-TimeFalStart <> ? then
      run put-xml-data(iSAXWriter,"GS1","Failure_time",string(gismt-TimeFalStart),"Время с момента сбоя до начала уведомления персонала (часы)").
      if gismt-CrashSituat <> ? then
      run put-xml-data(iSAXWriter,"GS1","emergencyMode",(if gismt-CrashSituat then "1" else "0"),"Признак аварийной ситуации в ГИС МТ").
      if vMACC_Timeout <> 0 and vMACC_Timeout <> ? then
         run put-xml-data(iSAXWriter,"GS1","MACC_Timeout",string(vMACC_Timeout),"Длительность ожидания ответа ТН").
      if vResp_TH_requiredr <> ? then
      run put-xml-data(iSAXWriter,"GS1","Resp_TH_required",string(vResp_TH_requiredr),"Обязательность получения результатов проверки КМ в ТН").
      run put-xml-data(iSAXWriter,"GS1","MaxApiToken",vMaxApiToken,"Токен авторизации MAX").
      if vAgeConfirm <> ? then
      run put-xml-data(iSAXWriter,"UiSettings","NeedUserSimpleAgeConfirm",string(vAgeConfirm),"Проверка возраста при продаже НП").
   end.
   for each thbjattr-list:
       delete thbjattr-list.
   end.
   oSend = mSend.
end procedure.
procedure put-xml-data:
    define input parameter iSAXWriter  as handle    no-undo .
    define input parameter p-group     as character no-undo.
    define input parameter p-prop-code as character no-undo.
    define input parameter p-value     as character no-undo.
    define input parameter p-discr     as character no-undo.
    define buffer buf_code for ub.code.
    find first buf_code no-lock where
               buf_code.parent = substitute("cash-param&1&2&1&3&1&4",chr(4),mDeviceKind,"1",p-group)
           and buf_code.code  = p-prop-code
      no-error.
    if available buf_code
    then do:
        iSAXWriter:start-element("Param") .
        iSAXWriter:insert-attribute("ctrl", "ADD").
        iSAXWriter:insert-attribute("group", p-group).
        iSAXWriter:insert-attribute("key", p-prop-code).
        iSAXWriter:write-data-element("ParamValue" , p-value ) .
        iSAXWriter:write-data-element("ParamDesc" , p-discr).
        iSAXWriter:end-element("Param" ).
        mSend = yes.
    end.
end procedure.
procedure set-cash-info:
   define input         parameter iDB-num        as integer     no-undo.
   define input         parameter iObjType       as character   no-undo.
   define input         parameter iObjCode       as integer     no-undo.
   define input         parameter iPostType      as character   no-undo.
   define input         parameter iCashNum       as integer     no-undo.
   define buffer buf_cash-desk-attr for ub.cash-desk-attr .
   assign
      mDB-num       = iDB-num
      mObjType      = iObjType
      mObjCode      = iObjCode
      mPostType     = iPostType
      mCashNum      = iCashNum
   .
   find first buf_cash-desk-attr no-lock
       where buf_cash-desk-attr.db-num   = mDB-num
         and buf_cash-desk-attr.obj-code = mObjCode
         and buf_cash-desk-attr.pos-type = mPostType
         and buf_cash-desk-attr.cash-num = mCashNum
         and buf_cash-desk-attr.upper-attr-code = mPostType + "_operative":U
         and buf_cash-desk-attr.attr-code       = "device-kind":U no-error .
   if available buf_cash-desk-attr then
       mDeviceKind = buf_cash-desk-attr.attr-value-integer .
   else
      mDeviceKind = 0 .
end.
procedure get-cash-types:
   define output parameter otypes as character no-undo init "IBM-XML".
end.
procedure get-root-teg:
   define output parameter otypes as character no-undo init "config".
end.
procedure get-xml-encoding:
   define output parameter oEncoding as character no-undo init "UTF-8".
end.
procedure get-tag-from:
   define output parameter oValue as character no-undo init "empty".
end.
procedure get-tag-to:
   define output parameter oValue as character no-undo init "*".
end.
procedure Warning:
  define input parameter ErrMessage as character no-undo.
  message "The following WARNING was generated:~n" + ErrMessage
       view-as alert-box info buttons ok.
end procedure.
procedure Error:
  define input parameter ErrMessage as character no-undo.
  message "The following NONFATAL ERROR was generated:~n" + ErrMessage
       view-as alert-box info buttons ok.
end procedure.
procedure FatalError:
  define input parameter ErrMessage as character no-undo.
  return error "The following FATAL ERROR was generated:~n" + ErrMessage.
end procedure.
