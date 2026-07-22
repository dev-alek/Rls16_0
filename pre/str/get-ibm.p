block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
DEFINE INPUT PARAMETER file_ as character no-undo.
define input-output parameter p-view-log as logical no-undo .
DEFINE VARIABLE vss-revision    as character no-undo init "$Revision$":u .
DEFINE VARIABLE vss-author      as character no-undo init "$Author$":u .
DEFINE VARIABLE vss-date        as character no-undo init "$Date$":u .
DEFINE VARIABLE vss-workfile    as character no-undo init "$Workfile$":u .
DEFINE VARIABLE vss-archive     as character no-undo init "$Archive$":u .
DEFINE VARIABLE vss-description as character no-undo init "Программа приема чеков с касс IBM" .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define  shared variable base-cass as int no-undo.
define  shared variable right-curs as log no-undo.
define  shared variable curr-list as char no-undo.
define  shared variable pay-list as character no-undo.
define  shared variable nal as integer no-undo.
define  shared variable kassa-rub-code      as  integer  no-undo .
define  shared variable unq-artc as logical no-undo init no.
define  shared variable val-abbr as character no-undo.
define  shared variable val-cass as character no-undo.
define  shared variable val-shop as character no-undo.
define  shared variable pay-val as character no-undo.
define  shared variable pay-cass as character no-undo.
define  shared variable pay-shop as character no-undo.
define  shared variable nal-rub as integer no-undo.
define  shared variable abbr as character no-undo.
define  shared variable pay-nal as integer no-undo.
define  shared variable cass-card as character no-undo.
define  shared variable trade-card as character no-undo.
define  shared variable curr-card as character no-undo.
define  shared variable not-nal as integer no-undo.
define  shared variable lll as int no-undo initial 0.
define  shared variable ibmspool as character no-undo .
define  shared variable ibmgroup as logical no-undo init yes.
define  SHARED variable specgrp as character no-undo init '':U.
define  shared variable varscales-pref as character no-undo .
define  shared variable varpgscales-pref as character no-undo .
define  SHARED temp-table chk_doc no-undo
field doc-code as char
field chk-date as date
field chk-time as int
field chk-num as int
field g-lines as int
field p-lines as int
.
define variable os-er     as integer.
define variable v-index   as integer   no-undo .
define variable conf-attr as character no-undo.
define variable conf-par  as character no-undo.
define variable par-type  as character no-undo.
define temp-table tt-sum-grp no-undo
    like  ub.sum-grp
    field code-2 as integer
    field gtype  as integer
    .
procedure get-last-check-date-time :
    define input parameter p-db-num like ub.cash-desk.db-num no-undo .
    define input parameter p-obj-code like ub.cash-desk.obj-code no-undo .
    define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
    define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
    define output parameter p-date like ub.chk-doc.chk-date no-undo .
    define output parameter p-time like ub.chk-doc.chk-time no-undo .
    define variable v-last-date like ub.chk-doc.chk-date no-undo .
    define variable v-last-time like ub.chk-doc.chk-date no-undo .
    define variable v-character as character no-undo .
    define variable v-date      as date      no-undo .
    define variable v-decimal   as decimal   no-undo .
    define variable v-integer   as integer   no-undo .
    define variable v-logical   as logical   no-undo .
    define variable v-attr-type as character no-undo .
    define buffer buf_chk-doc     for ub.chk-doc.
    define buffer buf_c-cash-desk for ub.c-cash-desk.
    do
        on error undo, return error
        :
        run cd-attr-value in this-procedure (
            input g#db-num
            ,input p-obj-code
            ,input p-pos-type
            ,input p-cash-num
            ,input 'MAGIA-XML_operative':U
            ,input 'last-check-date-time':U
            ,output v-character
            ,output v-date
            ,output v-decimal
            ,output v-integer
            ,output v-logical
            ,output v-attr-type     ) no-error.
        if v-character = "":U
            or v-character = ?
            then
        do:
            FIND FIRST BUF_c-CASh-DESK NO-LOCK where
                buf_c-cash-desk.db-num = g#db-num
                AND buf_c-cash-desk.pos-type = p-pos-type
                AND buf_c-cash-desk.cash-num = p-cash-num
                AND buf_c-cash-desk.subject  = 'cash-desk':U
                and buf_c-cash-desk.action = integer('1':U) use-index pi no-error .
            if available buf_c-cash-desk then
            do:
                assign
                    p-date = buf_c-cash-desk.corr-date
                    p-time = buf_c-cash-desk.corr-time
                    .
            end.
            else
            do:
                find first buf_chk-doc no-lock where
                    buf_chk-doc.obj-type = 'маг':U
                    AND buf_chk-doc.obj-code = p-obj-code no-error.
                if not available buf_chk-doc then
                do:
                    return error.
                end.
                assign
                    p-date = buf_chk-doc.chk-date - 1
                    p-time = buf_chk-doc.chk-time
                    .
            end.
        end.
        else
        do:
            assign
                p-date = cd-attr-parse-date-time( v-character, output p-time )
        no-error .
            if error-status:error then return error .
        end.
    end.
end procedure.
procedure get-last-check-params :
    define input parameter p-db-num like ub.cash-desk.db-num no-undo .
    define input parameter p-obj-code like ub.cash-desk.obj-code no-undo .
    define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
    define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
    define output parameter p-date like ub.chk-doc.chk-date no-undo .
    define output parameter p-time like ub.chk-doc.chk-time no-undo .
    define output parameter p-shift-num like ub.chk-doc.shift-num no-undo init 0.
    define output parameter p-z-count like ub.chk-doc.z-number no-undo init 0.
    define output parameter p-chk-num like ub.chk-doc.chk-num no-undo init 0.
    define variable v-last-date like ub.chk-doc.chk-date no-undo .
    define variable v-last-time like ub.chk-doc.chk-date no-undo .
    define variable v-character as character no-undo .
    define variable v-date      as date      no-undo .
    define variable v-decimal   as decimal   no-undo .
    define variable v-integer   as integer   no-undo .
    define variable v-logical   as logical   no-undo .
    define variable v-attr-type as character no-undo .
    define buffer buf_chk-doc     for ub.chk-doc.
    define buffer buf_c-cash-desk for ub.c-cash-desk.
    do
        on error undo, return error
        :
        run cd-attr-value in this-procedure (
            input g#db-num
            ,input p-obj-code
            ,input p-pos-type
            ,input p-cash-num
            ,input if p-pos-type eq 'IBM-XML':U
            then 'IBM-XML_operative':U
            else 'AUTOTANK_operative':U
            ,input if p-pos-type = 'IBM-XML':U
            then 'last-check-params':U
            else 'last-check-params':U
            ,output v-character
            ,output v-date
            ,output v-decimal
            ,output v-integer
            ,output v-logical
            ,output v-attr-type     ) no-error.
        if v-character = "":U
            or v-character = ?
            then
        do:
            FIND FIRST BUF_c-CASh-DESK NO-LOCK where
                buf_c-cash-desk.db-num = g#db-num
                AND buf_c-cash-desk.pos-type = p-pos-type
                AND buf_c-cash-desk.cash-num = p-cash-num
                AND buf_c-cash-desk.subject  = 'cash-desk':U
                and buf_c-cash-desk.action = integer('1':U) use-index pi no-error .
            if available buf_c-cash-desk then
            do:
                assign
                    p-date = buf_c-cash-desk.corr-date
                    p-time = buf_c-cash-desk.corr-time
                    .
            end.
            else
            do:
                find first buf_chk-doc no-lock where
                    buf_chk-doc.obj-type = 'маг':U
                    AND buf_chk-doc.obj-code = p-obj-code no-error.
                if not available buf_chk-doc then
                do:
                    return error.
                end.
                assign
                    p-date      = buf_chk-doc.chk-date - 1
                    p-time      = buf_chk-doc.chk-time
                    p-shift-num = buf_chk-doc.shift-num
                    p-z-count   = buf_chk-doc.z-number
                    p-chk-num   = buf_chk-doc.chk-num
                    .
            end.
        end.
        else
        do:
            assign
                p-date      = cd-attr-parse-date-time( substring(v-character, 1, 19), output p-time )
                p-shift-num = integer(entry(3, v-character, chr(32) ))
                p-shift-num = (if p-shift-num = ? then 0 else p-shift-num)
                p-z-count   = integer(entry(4, v-character, chr(32) ))
                p-z-count   = (if p-z-count = ? then 0 else p-z-count)
                p-chk-num   = integer(entry(5, v-character, chr(32) ))
        no-error .
            if error-status:error then return error .
        end.
    end.
end procedure.
procedure get-last-report-params :
    define input parameter p-db-num like ub.cash-desk.db-num no-undo .
    define input parameter p-obj-code like ub.cash-desk.obj-code no-undo .
    define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
    define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
    define output parameter p-date like ub.chk-slip-head.slip-dt no-undo .
    define output parameter p-time like ub.chk-doc.chk-time no-undo .
    define output parameter p-shift-num like ub.chk-slip-head.CashShiftNum no-undo init 0.
    define variable v-last-date like ub.chk-doc.chk-date no-undo .
    define variable v-last-time like ub.chk-doc.chk-date no-undo .
    define variable v-character as character no-undo .
    define variable v-date      as date      no-undo .
    define variable v-decimal   as decimal   no-undo .
    define variable v-integer   as integer   no-undo .
    define variable v-logical   as logical   no-undo .
    define variable v-date1     as character no-undo .
    define variable v-date2     as character no-undo .
    define variable v-attr-type as character no-undo .
    define buffer buf_chk-slip-head for ub.chk-slip-head.
    define buffer buf_c-cash-desk   for ub.c-cash-desk.
    do
        on error undo, return error
        :
        run cd-attr-value in this-procedure (
            input g#db-num
            ,input p-obj-code
            ,input p-pos-type
            ,input p-cash-num
            ,input if p-pos-type eq 'IBM-XML':U
            then 'IBM-XML_operative':U
            else 'AUTOTANK_operative':U
            ,input if p-pos-type = 'IBM-XML':U
            then 'last-report-params':U
            else 'last-report-params':U
            ,output v-character
            ,output v-date
            ,output v-decimal
            ,output v-integer
            ,output v-logical
            ,output v-attr-type     ) no-error.
        if v-character = "":U
            or v-character = ?
            then
        do:
            find last buf_chk-slip-head no-lock where
                buf_chk-slip-head.obj-code = p-obj-code
                and buf_chk-slip-head.cash-num = p-cash-num
                and buf_chk-slip-head.db-num = p-db-num
                and buf_chk-slip-head.is-report = 1 no-error.
            if not available buf_chk-slip-head then
            do:
                return error.
            end.
            v-date2 = entry(2,string(buf_chk-slip-head.slip-dt)," ") .
            v-date1 = string(substr( entry(1,string(buf_chk-slip-head.slip-dt)," "), 7, 4 )) + "-" +
                string( substr( entry(1,string(buf_chk-slip-head.slip-dt)," "), 4, 2 ) ) + "-" +
                string( substr( entry(1,string(buf_chk-slip-head.slip-dt)," "), 1, 2 ) )
                + " " + entry(1,v-date2,".") .
            assign
                p-date      = cd-attr-parse-date-time( string(v-date1), output p-time )
                p-shift-num = buf_chk-slip-head.CashShiftNum
                .
        end.
        else
        do:
            assign
                p-date      = cd-attr-parse-date-time( substring(v-character, 1, 19), output p-time )
                p-shift-num = integer(entry(3, v-character, chr(32) ))
                p-shift-num = (if p-shift-num = ? then 0 else p-shift-num)
        no-error .
            if error-status:error then return error .
        end.
    end.
end procedure.
procedure get-last-check-maria :
    define input parameter p-db-num like ub.cash-desk.db-num no-undo .
    define input parameter p-obj-code like ub.cash-desk.obj-code no-undo .
    define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
    define output parameter p-date like ub.chk-doc.chk-date no-undo .
    define output parameter p-z-count like ub.chk-doc.z-number no-undo init 0.
    define output parameter p-num-recs as integer no-undo .
    define output parameter p-p-date like ub.chk-doc.chk-date no-undo .
    define output parameter p-p-z-count like ub.chk-doc.z-number no-undo init 0.
    define output parameter p-p-num-recs as integer no-undo .
    define variable v-last-date like ub.chk-doc.chk-date no-undo .
    define variable v-last-time like ub.chk-doc.chk-date no-undo .
    define variable v-character as character no-undo .
    define variable v-date      as date      no-undo .
    define variable v-decimal   as decimal   no-undo .
    define variable v-integer   as integer   no-undo .
    define variable v-logical   as logical   no-undo .
    define variable v-attr-type as character no-undo .
    define buffer buf_chk-doc     for ub.chk-doc.
    define buffer buf_c-cash-desk for ub.c-cash-desk.
    do
        on error undo, return error
        :
        run cd-attr-value in this-procedure (
            input p-db-num
            ,input p-obj-code
            ,input 'MARIA':U
            ,input p-cash-num
            ,input 'MARIA_operative':U
            ,input 'last-check-maria':U
            ,output v-character
            ,output v-date
            ,output v-decimal
            ,output v-integer
            ,output v-logical
            ,output v-attr-type     ) no-error.
        if v-character = "":U
            or v-character = ?
            then
        do:
            FIND FIRST BUF_c-CASh-DESK NO-LOCK where
                buf_c-cash-desk.db-num = p-db-num
                AND buf_c-cash-desk.pos-type = 'MARIA':U
                AND buf_c-cash-desk.cash-num = p-cash-num
                AND buf_c-cash-desk.subject  = 'cash-desk':U
                and buf_c-cash-desk.action = integer('1':U) use-index pi no-error .
            if available buf_c-cash-desk then
            do:
                assign
                    p-date   = buf_c-cash-desk.corr-date
                    p-p-date = buf_c-cash-desk.corr-date
                    .
            end.
            else
            do:
                find first buf_chk-doc no-lock where
                    buf_chk-doc.obj-type = 'маг':U
                    AND buf_chk-doc.obj-code = p-obj-code no-error.
                if not available buf_chk-doc then
                do:
                    assign
                        p-date       = 01/01/1990
                        p-z-count    = 1
                        p-num-recs   = 0
                        p-p-date     = 01/01/1990
                        p-p-z-count  = 1
                        p-p-num-recs = 0
                        .
                end.
                assign
                    p-date       = buf_chk-doc.chk-date - 1
                    p-z-count    = (if buf_chk-doc.z-number = ? then 1 else  buf_chk-doc.z-number)
                    p-num-recs   = 0
                    p-p-date     = buf_chk-doc.chk-date - 1
                    p-p-z-count  = (if buf_chk-doc.z-number = ? then 1 else  buf_chk-doc.z-number)
                    p-p-num-recs = 0
                    .
            end.
        end.
        else
        do:
            assign
                p-date       = date( integer(entry(2, entry(1, v-character, chr(32)), '-':U))
                      ,integer(entry(3, entry(1, v-character, chr(32)), '-':U))
                      ,integer(entry(1, entry(1, v-character, chr(32)), '-':U))
                      )
                p-z-count    = integer(entry(2, v-character, chr(32) ))
                p-z-count    = (if p-z-count = ? then 0 else p-z-count)
                p-num-recs   = integer(entry(3, v-character, chr(32) ))
                p-num-recs   = (if p-num-recs = ? then 0 else p-num-recs)
                p-p-date     = date( integer(entry(2, entry(4, v-character, chr(32)), '-':U))
                      ,integer(entry(3, entry(4, v-character, chr(32)), '-':U))
                      ,integer(entry(1, entry(4, v-character, chr(32)), '-':U))
                      )
                p-p-z-count  = integer(entry(5, v-character, chr(32) ))
                p-p-z-count  = (if p-z-count = ? then 0 else p-z-count)
                p-p-num-recs = integer(entry(6, v-character, chr(32) ))
                p-p-num-recs = (if p-p-num-recs = ? then 0 else p-p-num-recs)
        no-error .
            if error-status:error then return error .
        end.
    end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#libchkvl as handle no-undo .
function libchkvl_right-netto-sign returns integer ( input p-chk-type as integer) in G#libchkvl.
define variable log-file-name as character no-undo init "get-chkf.log".
define stream ChkStream .
define stream InvStream.
DEFINE VARIABLE ss                         as   character             no-undo .
DEFINE VARIABLE var-file-line-num          as   integer               no-undo .
DEFINE VARIABLE ii                         as   integer               no-undo .
DEFINE VARIABLE bc-buf                     as   character             no-undo .
DEFINE VARIABLE b-c                        like ub.bar-code.b-code       no-undo .
DEFINE VARIABLE v-base-code                like ub.sysconf.base-code  no-undo .
DEFINE VARIABLE shop-type                  as   character             no-undo .
DEFINE VARIABLE shop-code                  as   integer               no-undo .
DEFINE VARIABLE chk-type_                  like ub.chk-doc.chk-type   no-undo .
DEFINE VARIABLE chk-date_                  like ub.chk-doc.chk-date   no-undo .
DEFINE VARIABLE chk-time_                  like ub.chk-doc.chk-time   no-undo .
DEFINE VARIABLE shift-date_                like ub.chk-doc.shift-date no-undo .
DEFINE VARIABLE shift-num_                 like ub.chk-doc.shift-num  no-undo .
DEFINE VARIABLE shift-name_                like ub.chk-doc.shift-name  no-undo .
define variable shift-open-time_           as integer no-undo .
DEFINE VARIABLE z-num_                     like ub.chk-doc.z-number   no-undo.
DEFINE VARIABLE cash-rate_                 as decimal                 no-undo .
DEFINE VARIABLE cash-scale_                like ub.chk-doc.cash-scale no-undo .
DEFINE VARIABLE chk-num_                   like ub.chk-doc.chk-num    no-undo .
DEFINE VARIABLE AuthType_                  as integer  no-undo .
DEFINE VARIABLE qr-alchol_                 like ub.chk-doc-attr.attr-value  no-undo .
DEFINE VARIABLE CBCType_                   as integer  no-undo .
DEFINE VARIABLE CBCString_                 like ub.chk-gds-attr.line-num  no-undo .
DEFINE VARIABLE CBCBarcode_                like ub.chk-doc-attr.attr-value  no-undo .
DEFINE VARIABLE pay-desk_                  like ub.chk-doc.pay-desk   no-undo .
DEFINE VARIABLE cashier_                   like ub.chk-doc.cashier    no-undo .
DEFINE VARIABLE sales-man_                 like ub.chk-doc.sales-man  no-undo .
DEFINE VARIABLE d-card_                    like ub.chk-doc.d-card     no-undo .
DEFINE VARIABLE cli-type_                  like ub.chk-doc.cli-type   no-undo .
DEFINE VARIABLE cli-code_                  like ub.chk-doc.cli-code   no-undo .
DEFINE VARIABLE d-mask_                    like ub.chk-doc.d-card     no-undo .
DEFINE VARIABLE tot-d-pcnt                 like ub.chk-doc.src-d-pcnt no-undo .
DEFINE VARIABLE doc-num_                   like ub.chk-doc.doc-num    no-undo .
DEFINE VARIABLE doc-num2_                   like ub.chk-doc.doc-num2  no-undo .
DEFINE VARIABLE num-str_                   as   integer               no-undo .
DEFINE VARIABLE gbl-type                   as   character             no-undo .
DEFINE VARIABLE prev-gbl-type              as   character             no-undo .
define variable dflt-cd                    as   character             no-undo .
DEFINE VARIABLE split-check                as   logical               no-undo init no .
DEFINE VARIABLE current-pay-desk           as   integer               no-undo .
DEFINE VARIABLE current-cas-shift-name     as   character             no-undo .
DEFINE VARIABLE current-cas-shift-date     as   date                  no-undo .
DEFINE VARIABLE time-oper_                 like ub.chk-gds.time-oper  no-undo .
DEFINE VARIABLE t-c-d                      as   decimal               no-undo .
DEFINE VARIABLE pass-gds_                  like ub.chk-gds.pass-gds   no-undo .
DEFINE VARIABLE pump_                      like ub.chk-gds.pump       no-undo .
DEFINE VARIABLE nozzle_                    as   integer               no-undo .
DEFINE VARIABLE place_                     as   integer               no-undo .
DEFINE VARIABLE pl-code_                   as   integer               no-undo .
DEFINE VARIABLE road-tax_                  as   decimal               no-undo .
DEFINE VARIABLE curr-string-qnty           as   decimal               no-undo .
DEFINE VARIABLE sum-from-check             as   decimal               no-undo .
DEFINE VARIABLE discnt-from-check          as   decimal               no-undo .
DEFINE VARIABLE units-rate                 as   decimal               no-undo .
DEFINE VARIABLE units-dpcnt                as   decimal               no-undo .
DEFINE VARIABLE cass-rate                  as   decimal               no-undo .
DEFINE VARIABLE rate-por                   as   integer               no-undo .
DEFINE VARIABLE bank-rate_                 as   decimal               no-undo .
DEFINE VARIABLE bank-scale_                as   integer               no-undo .
DEFINE VARIABLE pass-pay_                  like ub.chk-pay.pass-pay   no-undo .
DEFINE VARIABLE pay-card_                  like ub.chk-pay.pay-card   no-undo .
DEFINE VARIABLE exist                      as   logical init TRUE     no-undo .
DEFINE VARIABLE mc-exist                   as   logical init TRUE     no-undo .
DEFINE VARIABLE price-from-check           like ub.chk-gds.price-base    no-undo .
DEFINE VARIABLE sub-d                      like ub.chk-doc.sub-discnt    no-undo .
DEFINE VARIABLE for-chk-type               as   character             no-undo init "".
DEFINE VARIABLE mc-for-chk-type            as   character             no-undo init "".
DEFINE VARIABLE prev-code                  like ub.chk-doc.doc-code      no-undo init "".
DEFINE VARIABLE mc-prev-code               like ub.chk-doc.doc-code    no-undo init "".
DEFINE VARIABLE pay_code                   like ub.cash-pay.cdpay-code     no-undo .
DEFINE VARIABLE curr_code                  like ub.cash-pay.curr-code    no-undo .
DEFINE VARIABLE pay-type                   as   character             no-undo .
DEFINE VARIABLE cstCode                    as   character             no-undo .
DEFINE VARIABLE cstValue                   as   decimal               no-undo .
DEFINE VARIABLE tot_sum                    as   decimal               no-undo .
DEFINE VARIABLE curr-chk-type              as   character             no-undo .
DEFINE VARIABLE mc-curr-chk-type           like ub.chk-doc.chk-type no-undo .
DEFINE VARIABLE r-bar-code                 like ub.bar-code.b-code       no-undo .
define variable v-curr-r-b                as character               no-undo .
DEFINE VARIABLE lng                        as   integer               no-undo .
DEFINE VARIABLE lnp                        as   integer               no-undo .
DEFINE VARIABLE lnc                        as   integer               no-undo .
DEFINE VARIABLE netto-for-sub-d           as    decimal               no-undo .
DEFINE VARIABLE accum-src-for-sub-d       as    decimal               no-undo .
define variable netto-sum_                as    decimal               no-undo .
define variable brutto-sum_               as    decimal               no-undo .
DEFINE VARIABLE lng-sub-d                 as   integer               no-undo .
DEFINE VARIABLE var-discnt-id             as   integer               no-undo .
define variable v-src-tot-doc             as decimal                 no-undo .
define variable chk-id_                   as character               no-undo .
DEFINE VARIABLE v-path                    as character               no-undo .
DEFINE VARIABLE v-full-path               as character               no-undo .
DEFINE VARIABLE v-file-name               as character               no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character               no-undo .
DEFINE VARIABLE v-file-name-ext           as character               no-undo .
DEFINE VARIABLE v-error-message           as longchar                no-undo .
define buffer buf_shift-cash for ub.shift-cash .
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2dr-flddf: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define temp-table tt-wd no-undo
field doc-code like ub.chk-doc.doc-code
field record-type like ub.chk-discnt.record-type
field line-type like ub.chk-discnt.line-type
field discnt-id like ub.chk-discnt.discnt-id
field line-num like ub.chk-gds.line-num
field wd-sum   like ub.chk-doc.netto
index pi is primary
line-num
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table get-chkc_context  no-undo
field parparentproc       as widget-handle
field p-log-handle        as handle
field p-log-file-name     as character
field view-log            as logical
field ll                  as integer
field tt-wd-bh            as handle
field pos-type            as character
field cash-num            as integer
field obj-type            as character init 'маг':U
field obj-code            as integer
field db-num              as integer
field r-b                 as character
field host-code           as integer
field base-code           as integer
field cre-pay             as integer
field is-catering         as logical
field is-cdinv            as logical
field is-ptrl             as logical
field is-wth              as logical
field process-sale        as logical
field dc-mask             as logical
field card-by-mask        as logical
field sclspref            as character
field scpgpref            as character
field scpgpref-pre        as character
field doc-prt             as logical
field shift-on            as logical
field cas-shft            as logical
field t-shft              as integer
field v-shft              as integer
field ptrl-check          as logical
field annu-check          as logical
field z-check             as logical
field hnum                as logical
field is-100-discnt       as logical
field zero-cashier        as integer
field rnd-znak            as integer
field cas-curs            as logical
field nam-2str            as logical
field nam-artc            as logical
field cod-pcod            as logical
field name-2cd            as character
field how-temp-disc       as character
field nalc                as integer
field rmethod-type        as character
field rmethod-coeff       as decimal
field serial-code         as character
field salesman-mandatory  as integer
field sales-man           as integer
field salesman-psn-code   as integer
field pos-type-for-discnt as character
field manual-discnt       as integer
field is-grp-totals       as logical
field is-gds-totals       as logical
field cash-counter        as decimal
field pre-cash-counter    as decimal
field qnty-change         as logical
field log-level           as integer
field chk-discnt-table    as handle
help 'cntxt_chk-discnt-table':U
field chk-gds-table       as handle
help 'cntxt_chk-gds-table':U
field chk-pay-table       as handle
help  'cntxt_chk-pay-table':U
field z-number            as integer
field shift-num           as integer
field shift-date          as date
field shift-name          as character
field emulator-mode       as integer
field ibmgroup            as logical
index pi is unique primary
db-num
obj-code
pos-type
cash-num
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION CIntBinS RETURNS CHARACTER(input vl_int as integer):
def var vl_bin as char no-undo init "".
if vl_int < 0 OR vl_int = ? then return ?.
do while vl_int > 0:
  assign
  vl_bin = (if vl_int modulo 2 = 0
              then "0":U
              else "1":U) + vl_bin
  vl_int = truncate(vl_int / 2,0).
end.
return fill( "0":U, 32 - length(vl_bin)) + vl_bin .
END FUNCTION.
FUNCTION BinMask RETURNS LOGICAL(input vl_int as integer,
                                 input vl_binm as character):
DEFINE VARIABLE vl_bin as character no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-len as integer no-undo.
DEFINE VARIABLE ii-lenm as integer no-undo.
DEFINE VARIABLE mchar as character no-undo.
DEFINE VARIABLE ichar as character no-undo.
if vl_binm = ? then return ?.
vl_bin = CIntBinS(vl_int).
if vl_bin = ? then return ?.
assign
vl_binm = LEFT-TRIM(vl_binm, "X":U)
ii-lenm = LENGTH(vl_binm)
ii-len = LENGTH(vl_bin) - ii-lenm
.
if II-LENM > 32 THEN RETURN ?.
DO II = 1 to II-LENm:
  assign
  mchar = SUBSTR(vl_binm, ii, 1)
  ichar = SUBSTR(vl_bin, ii + ii-len, 1)
  .
  IF not (MCHAR = "0":u or MCHAR = "1":u or MCHAR = "X":u) then return ?.
  IF ichar <> mchar AND mchar <> "X":U then return no.
END.
return yes.
END FUNCTION.
DEFINE VARIABLE n-entry                    as   char no-undo extent 20.
DEFINE VARIABLE kriv2                      as   logical no-undo.
DEFINE VARIABLE accept-types               as   character no-undo .
define variable v-flag-salesman            as   logical   no-undo .
define variable v-flag-card                as   logical   no-undo .
define variable v-end-of-check             as   logical no-undo init yes.
define variable v-is-petrol-check          as logical no-undo .
assign
shop-type = p-obj-type
shop-code = p-obj-code
dflt-cd = p-pos-type
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION convert-discount returns integer
                                          ( input p-disc-reason as integer
                                          , input p-disc-type  as integer
                                          , input p-line-type as integer) :
define variable v-disc-type as integer no-undo .
if p-line-type = integer('1':U)
or p-line-type = integer('0':U)
then do:
  if p-disc-type = 0
  or p-disc-type = 1
  or p-disc-type = 2
  then do:
    if p-disc-reason <> 0 then
    p-disc-type = p-disc-reason
    .
  end.
end.
if p-line-type = integer('3':U)
or p-line-type = integer('2':U) then do:
  if p-disc-type = 101
  or p-disc-type = 102
  then do:
    if p-disc-reason <> 0 then
    p-disc-type = p-disc-reason
    .
  end.
end.
if p-disc-reason <> 0 then do:
  CASE p-disc-reason:
    when 0 then do:
      return integer('0':U).
    end.
    when 1 then do:
      return integer('11':U).
    end.
    when 2 then do:
      return integer('1':U).
    end.
    when 3 or when 15 then do:
      return integer('7':U).
    end.
    when 4 then do:
      return integer('4':U).
    end.
    when 5 then do:
      return integer('12':U).
    end.
    when 6 then do:
      return integer('3':U).
    end.
    when 7 then do:
      return integer('13':U).
    end.
    when 8
    or
    when 9
    or
    when 10
    then do:
      return integer('20':U).
    end.
    when 11
    then do:
      return integer('21':U).
    end.
    when 13
    then do:
      return integer('22':U).
    end.
    when 16 then do:
      return integer('23':U).
    end.
  END CASE.
end.
CASE p-disc-type:
  when 0 then do:
    return integer('0':U).
  end.
  when 1 then do:
    return integer('13':U).
  end.
  when 2 then do:
    return integer('2':U).
  end.
  when 3 then do:
    return integer('4':U).
  end.
  when 4 then do:
    return integer('12':U).
  end.
  when 5 then do:
    return integer('1':U).
  end.
  when 6 then do:
    return integer('3':U).
  end.
  when 7 then do:
    return integer('14':U).
  end.
  when 8 then do:
    return integer('15':U).
  end.
  when 9 then do:
    return integer('16':U).
  end.
  when 101 then do:
    return integer('13':U).
  end.
  when 102 then do:
    return integer('5':U).
  end.
  when 103 then do:
    return integer('1':U).
  end.
  when 104 then do:
    return integer('5':U).
  end.
  when 105 then do:
    return integer('1':U).
  end.
  when 106 then do:
    return integer('1':U).
  end.
END CASE.
END FUNCTION.
run get-general-parameters in this-procedure .
procedure get-general-parameters :
define buffer buf_get-chkc_context for get-chkc_context.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  for each buf_get-chkc_context:
    delete buf_get-chkc_context.
  end.
  create buf_get-chkc_context.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_create-context in g#libchkvl
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buffer buf_get-chkc_context:handle
  ) no-error .
  if error-status:error then do:
    undo, return error substitute("Ошибка при создании контекста&1&2&1&3"
                                   , chr(10)
                                   , error-status:get-message(1)
                                   , return-value ).
  end.
  find first buf_get-chkc_context.
  assign
  buf_get-chkc_context.parparentproc = parparentproc
  buf_get-chkc_context.p-log-handle = p-log-handle
  buf_get-chkc_context.tt-wd-bh     = buffer tt-wd:handle
  .
  release buf_get-chkc_context.
  find first get-chkc_context.
end.
end procedure.
get-chkc_context.pos-type = p-pos-type.
RUN get-ibm-c(file_) no-error .
if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибка при обработке файла &1: &2"
                            , file_
                            , return-value
                          )
                                          ).
  assign
  p-view-log = yes
  .
  undo, return "error":U.
end.
PROCEDURE get-ibm-c.
def input parameter filename as char no-undo.
run get-ibm-parameters in this-procedure no-error.
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении значений настроечных параметров: &2"
                          , filename
                          , return-value
                        )
                                        ).
  undo, return "error":U.
end.
run gbl/filename.p (
                input filename
               ,output v-full-path
               ,output v-path
               ,output v-file-name
               ,output v-file-name-no-ext
               ,output v-file-name-ext
               ) no-error .
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении полного пути файлу: &2"
                          , filename
                          , return-value
                        )
                                  ).
  return "error":U.
end.
error-status:error = FALSE.
input stream ChkStream from value( filename ).
_repeat:
REPEAT :
_line:
DO TRANSACTION:
  ss = '':U.
  import stream ChkStream unformatted ss.
  assign
  var-file-line-num = var-file-line-num + 1
  .
  if var-file-line-num modulo 100 = 0 then do:
    run show-counter in p-log-handle .
    run write-counter in p-log-handle (substitute("Файл &1: прочитано строк &2", filename, var-file-line-num)).
  end.
  if ss = "" or ss = ? then do:
      n-entry[1] = "".
      leave _line.
  end.
  repeat:
      ss = REPLACE(ss, "  ", " ").
      if INDEX(ss, "  ") = 0 then leave.
  end.
  DO ii = 1 to num-entries(ss, " "):
      if SUBSTR(ss,1,2) = "03" AND INDEX(entry(5, ss, " "), "E") > 0 and ii >= 3 then do:
          assign
          n-entry[3] = "0"
          n-entry[ii + 1] = entry(ii, ss, " ")
          kriv2 = yes
          .
      end.
      else
      assign
      kriv2 = no
      n-entry[ii] = entry(ii, ss, " ")
      .
  END.
  DO ii = (num-entries(ss, " ") + 1 + if kriv2 then 1 else 0) to 20:
      assign
      n-entry[ii] = "".
  END.
  kriv2 = no.
  assign
  ii = num-entries(ss, " ")    .
END.
DO TRANSACTION :
  CASE n-entry[1]:
    when '' then do:
      run proc-end in this-procedure no-error .
    end.
    when '00' then  do:
      run proc-end in this-procedure no-error .
      run proc-00 in this-procedure no-error .
    end.
    when "03" then do:
      CASE gbl-type:
        when "1" or when "6" or when "8" then do:
          run proc-03 in this-procedure(input exist) no-error .
        end.
        when "2" or when "3" or when "4" or when "5" then do:
          run proc-03 in this-procedure(input mc-exist) no-error .
        end.
        otherwise do:
        end.
      END CASE.
    end.
    when "01" then  do:
      CASE gbl-type:
        when "1"
        or
        when "6"
        or
        when "8"
        or
        when "14"
        or
        when "15"
        or
        when "16"
        or
        when "17" then do:
          run proc-01-gds in this-procedure no-error .
        end.
        otherwise do:
          error-status:error = no.
        end.
      END CASE.
    end.
    when "02" then do:
      run proc-02-gds in this-procedure no-error .
    end.
    when "04" then do:
      run proc-04-gds in this-procedure no-error .
    end.
    when "05" then do:
      if gbl-type = "11" then do:
        run proc-01-gds in this-procedure no-error .
      end.
    end.
    when "07" then do:
    end.
    when "08"  then do:
      run proc-08 in this-procedure .
    end.
    when "09"  then do:
      run proc-09 in this-procedure .
    end.
    when "10" then do:
      run proc-10 in this-procedure .
    end.
    when '16' then  do:
      run proc-16 in this-procedure no-error .
    end.
    otherwise do:
      run proc-end in this-procedure no-error .
    end.
    END CASE .
  END.
END .
DO TRANSACTION:
  run proc-end in this-procedure no-error .
END.
assign
tot-d-pcnt = 0
error-status:error = false.
input stream ChkStream close.
END PROCEDURE.
PROCEDURE get-ibm-parameters:
define variable ii as integer no-undo .
define buffer buf_tt-sum-grp for tt-sum-grp.
if get-chkc_context.shift-on
and not get-chkc_context.cas-shft then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Внимание! На объекте &1&2 требуется использование смен, а настройка СМЕНЫ НА КАССЕ выключена - это недопустимо."
                         , get-chkc_context.obj-type
                         , get-chkc_context.obj-code
                          )).
  assign
  p-view-log = yes
  .
  undo, return "error":U.
end.
get-chkc_context.ibmgroup          = ibmgroup.
if get-chkc_context.t-shft > 0 and get-chkc_context.shift-on = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Внимание! На объекте &1&2 требуется использование смен,&3" +
                          "а настройка СМЕЩЕННЫЕ СМЕНЫ НА КАССЕ&3" +
                          "(АРМ Администратор - Справочники - Магазины - Параметры - время начала пересменки)&3" +
                          "включена - это недопустимо."
                         , get-chkc_context.obj-type
                         , get-chkc_context.obj-code
                         , chr(10)
                          )).
  assign
  p-view-log = yes
  .
  undo, return "error":U.
end.
if get-chkc_context.is-wth = yes then do:
  accept-types =  "1,2,3,4,5,6,7,13":U.
end.
else do:
  accept-types =  "1,6,13":U.
end.
if logical(get-chkc_context.is-cdinv) then accept-types = accept-types + ",11":U.
if get-chkc_context.is-ptrl
and get-chkc_context.ptrl-check then
assign
accept-types = accept-types + ",14,15,16,17":U.
if get-chkc_context.annu-check then
accept-types = accept-types + ",8":U.
if get-chkc_context.z-check then
accept-types = accept-types + ",12":U.
if get-chkc_context.ibmgroup then do:
  for each buf_tt-sum-grp:
    delete buf_tt-sum-grp.
  end.
  do ii = 1 to num-entries(specgrp, ';'):
    create buf_tt-sum-grp.
    assign
    buf_tt-sum-grp.grp-code = integer(entry(1, entry(ii, specgrp, ';'), '-':U))
    buf_tt-sum-grp.code-2 = integer(entry(2, entry(ii, specgrp, ';'), '-':U))
    buf_tt-sum-grp.gtype = integer(entry(3, entry(ii, specgrp, ';'), '-':U))
    no-error
    .
    if error-status:error then do:
      delete buf_tt-sum-grp.
    end.
  end.
end.
END PROCEDURE.
procedure proc-00 :
define variable v-pay-desk as integer no-undo .
define variable v-no-shift as logical no-undo .
  do
  on error undo, return error
  :
    assign
    gbl-type = trim(n-entry[10])
    .
    if can-do(accept-types,  gbl-type ) then do:
      assign
      v-is-petrol-check = no
      chk-date_ = 01/01/1990
      chk-time_ = 0
      shift-date_ = chk-date_
      shift-num_ = 0
      shift-name_ = '':U
      shop-code = 0
      shop-type = "":U
      sales-man_ = 0
      v-flag-salesman  = no
      v-flag-card = no
      cashier_ = 0
      pay-desk_ = 0
      z-num_ = 0
      cash-rate_ = 0
      d-card_ = "":U
      d-mask_ = "":U
      cli-type_ = "":U
      cli-code_ = 0
      tot-d-pcnt = 0
      doc-num_ = "":U
      v-end-of-check = no
      .
      if get-chkc_context.cas-shft = yes
      and n-entry[(if ii> 15 then 14 else 13)] = "0000000000" then do:
        assign
        shift-date_ = 01/01/1990
        .
        assign
        v-pay-desk = int( trim( n-entry[5] ) )
        v-no-shift = yes
        no-error .
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Неверный формат спула файла &1: строка &2:&3не установлен режим сменной работы на кассе &4"
                                , file_
                                , var-file-line-num
                                , chr(10)
                                , v-pay-desk
                              )
                                            ).
        assign
        p-view-log = yes
        .
      end.
      assign
      chk-date_  =   date(
                                    int( substr( n-ENTRY[2], 3, 2 ) ) ,
                                    int( substr( n-ENTRY[2], 1, 2 ) ),
                                    int( substr( n-ENTRY[2], 5, 4 ) )
                                    )
      chk-time_ =  int( substr( n-entry[3], 1, 2 ) ) * 3600 + int( substr( n-entry[3], 3, 2 ) ) * 60  +
                    int( substr(n-entry[3], 5, 2) )
      shift-date_ = if cas-shft
                    then (if v-no-shift then shift-date_ else date(substr(n-entry[(if ii> 15 then 14 else 13)], 3 ) ))
                    else chk-date_
      shop-code = ( if get-chkc_context.hnum
                    then int( trim(  n-entry[4] ) )
                    else p-obj-code )
      shop-type = ( if get-chkc_context.hnum then 'маг':U else p-obj-type )
      chk-num_ = int( trim( n-entry[8] ) )
      sales-man_ = int( trim( n-entry[6] ) )
      cashier_ = int( trim( n-entry[7] ) )
      pay-desk_ = int( trim( n-entry[5] ) )
      z-num_ =  int(trim(n-entry[11]))
      cash-rate_ = dec(trim(n-entry[12]))
      d-card_ = if integer(ibmspool) < 6
                then ( if trim( n-entry[9] ) = "0"
                       then "":U
                       else trim( n-entry[9])
                      )
                else "":U
      cli-code_ = (if integer(ibmspool) < 6
                  then 0
                  else integer(trim( n-entry[9] ))
                  )
      cli-type_  = (if integer(ibmspool) < 6
                   then "":U
                   else (if cli-code_ <= 999999999
                         then 'чел':U
                         else 'орг':U)
                   )
      tot-d-pcnt = dec( trim( n-entry[(if ii> 15 then 16 else 15)] ) )
      shift-name_ = if cas-shft
                   then string(integer(substr(n-entry[(if ii> 15 then 14 else 13)], 1, 2 ) ))
                   else '':U
      shift-open-time_ = if cas-shft and can-do("13":U,  gbl-type)
                         then (integer(substr(n-entry[(if ii> 15 then 13 else 12)], 9, 2 ) ) * 3600 +
                               integer(substr(n-entry[(if ii> 15 then 13 else 12)], 11, 2 ) ) * 60
                              )
                         else 0
      doc-num_ = if ii> 15 then trim( n-entry[13] ) else '':U
      shift-num_ = integer(shift-name_)
      shift-num_ = if get-chkc_context.shift-on then 0 else shift-num_
      no-error
      .
      if error-status:error then do:
        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
      end.
    end.
    else do:
      assign
      exist = yes
      mc-exist = yes
      .
      return.
    end.
    if can-do("13":U,  gbl-type) then do:
      run proc-13 in this-procedure no-error .
    end.
    if get-chkc_context.is-wth and can-do("2,3,4,5,7":U ,  gbl-type) then do:
      assign
      mc-for-chk-type = ""
      mc-exist = yes
      .
      FIND  ub.chk-doc where
            ub.chk-doc.obj-type = shop-type and
            ub.chk-doc.obj-code = shop-code and
            ub.chk-doc.chk-date = chk-date_ and
            ub.chk-doc.pay-desk = pay-desk_ and
            ub.chk-doc.chk-time = chk-time_ and
            ub.chk-doc.chk-num  = chk-num_ and
            ub.chk-doc.sales-man = sales-man_ NO-ERROR NO-WAIT.
      IF NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc then do:
        assign
        mc-exist = no
        cr = 0
        lll = lll + 1 .
        CREATE ub.chk-doc.
        assign
        ub.chk-doc.chk-type = 0
        lng = 0
        lnp = 0
        var-discnt-id = 0
        ub.chk-doc.office = ?
        ub.chk-doc.correct = yes
        ub.chk-doc.obj-code = shop-code
        ub.chk-doc.obj-type = shop-type
        ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                              then string(next-value(s-chk, ub))
                              else string( shop-code ) + chr(47) + string( next-value( s-chk, ub ) ))
        ub.chk-doc.chk-num = chk-num_
        ub.chk-doc.chk-date = chk-date_
        ub.chk-doc.chk-time = chk-time_
        ub.chk-doc.sales-man = sales-man_
        ub.chk-doc.pay-desk = pay-desk_
        ub.chk-doc.cashier = cashier_
        ub.chk-doc.discnt = 0
        ub.chk-doc.src-shift-date = shift-date_
        ub.chk-doc.src-shift-name = shift-name_
        ub.chk-doc.shift-name = shift-name_
        ub.chk-doc.shift-num = (if not get-chkc_context.shift-on then shift-num_ else chk-doc.shift-num)
        ub.chk-doc.z-number = z-num_
        ub.chk-doc.chk-type = int(gbl-type)
        ub.chk-doc.cash-rate = cash-rate_
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.doc-num = doc-num_
        ub.chk-doc.tot-doc = 0
        ub.chk-doc.netto = 0
        ub.chk-doc.discnt = 0
        ub.chk-doc.d-pcnt = 0
        ub.chk-doc.src-d-pcnt = 0
        ub.chk-doc.doc-qnty = 0
        ub.chk-doc.src-tot-doc = 0
        ub.chk-doc.src-d-mask = ''
        ub.chk-doc.d-mask = ''
        ub.chk-doc.d-card = ''
        ub.chk-doc.src-d-card = ''
        ub.chk-doc.src-cli-type = ?
        ub.chk-doc.src-cli-code = ?
        ub.chk-doc.cli-type = ?
        ub.chk-doc.cli-code = ?
        ub.chk-doc.doc-num2 = ?
        ub.chk-doc.out-2-code = ?
        no-error
        .
        if error-status:error then do:
          assign
          ub.chk-doc.correct = no
          .
        end.
        mc-prev-code = ub.chk-doc.doc-code.
      end.
      else
      mc-curr-chk-type = 0 .
    end.
    if can-do( "1,6,8,11,12,13,14,15,16,17" , gbl-type ) then do:
      assign
      for-chk-type = ""
      exist = yes
      .
      FIND  ub.chk-doc where
            ub.chk-doc.obj-type = shop-type and
            ub.chk-doc.obj-code = shop-code and
            ub.chk-doc.chk-date = chk-date_ and
            ub.chk-doc.pay-desk = pay-desk_ and
            ub.chk-doc.chk-time = chk-time_ and
            ub.chk-doc.chk-num = chk-num_ and
            ub.chk-doc.sales-man = sales-man_ NO-ERROR NO-WAIT.
      IF NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc then do:
        assign
        exist = no
        cr = 0
        lll = lll + 1 .
        create ub.chk-doc.
        assign
        ub.chk-doc.office = ?
        lng = 0
        lnp = 0
        sub-d = 0
        var-discnt-id = 0
        lng-sub-d = 0
        netto-for-sub-d = 0
        ub.chk-doc.obj-code = shop-code
        ub.chk-doc.obj-type = shop-type
        ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                            then string(next-value(s-chk, ub))
                            else string( shop-code ) + chr(47) + string( next-value( s-chk, ub ) ))
        ub.chk-doc.chk-num = chk-num_
        ub.chk-doc.chk-date = chk-date_
        ub.chk-doc.chk-time = chk-time_
        ub.chk-doc.sales-man = sales-man_
        ub.chk-doc.pay-desk = pay-desk_
        ub.chk-doc.cashier = cashier_
        ub.chk-doc.discnt = 0
        ub.chk-doc.src-d-card =  d-card_
        ub.chk-doc.src-d-pcnt = - tot-d-pcnt
        ub.chk-doc.src-shift-date = shift-date_
        ub.chk-doc.src-shift-name = shift-name_
        ub.chk-doc.shift-name = shift-name_
        ub.chk-doc.shift-num = (if not get-chkc_context.shift-on then shift-num_ else ub.chk-doc.shift-num)
        ub.chk-doc.cash-rate = cash-rate_
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.z-number = z-num_
        ub.chk-doc.doc-num = doc-num_
        ub.chk-doc.chk-type = integer(gbl-type)
        v-is-petrol-check = lookup(string(ub.chk-doc.chk-type) , '14,15,16,17,36':U) > 0
        ub.chk-doc.correct = yes
        no-error
        .
        if error-status:error then do:
          ub.chk-doc.correct = no.
        end.
        prev-code = ub.chk-doc.doc-code.
        if gbl-type = "12" then do:
          define variable v-curr-abbr as character no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  get-chkc_context.base-code
  ,input  ub.chk-doc.chk-date
  ,output bank-rate_
  ,output bank-scale_
  ,output v-curr-abbr
  )  .
          create ub.chk-pay.
          assign
          lnp = lnp + 1
          ub.chk-pay.doc-code = ub.chk-doc.doc-code
          ub.chk-pay.line-num = lnp
          ub.chk-pay.chk-date = ub.chk-doc.chk-date
          ub.chk-pay.obj-code = shop-code
          ub.chk-pay.obj-type = shop-type
          ub.chk-pay.tot-rubl = 0
          ub.chk-pay.tot-sum = 0
          ub.chk-pay.tot-base = 0
          ub.chk-pay.pay-code = 0
          ub.chk-pay.curr-code = 0
          ub.chk-pay.time-oper = time-oper_
          ub.chk-pay.cash-rate = ub.chk-doc.cash-rate
          ub.chk-pay.bank-rate = 1
          ub.chk-pay.bank-scale = 1
          ub.chk-pay.pass-pay =  0
          ub.chk-pay.pay-card = '':U
          ub.chk-pay.line-type = "":U
          ub.chk-pay.line-sign = yes
          ub.chk-pay.is-error = no
          .
        end.
      end.
      else
    end.
  end.
end procedure.
procedure proc-01-gds :
DEFINE VARIABLE no-add-price as logical no-undo .
define buffer buf_cd-plu for ub.cd-plu.
  do
  on error undo, return error
  :
    if not exist then do:
      if v-end-of-check then do:
        if available ub.chk-doc then do:
          assign
          ub.chk-doc.correct = no
          for-chk-type = for-chk-type + 'сум-ош':U + chr(44)
          .
        end.
        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
      end.
      assign
      nozzle_ = 0
      place_ = 0
      .
      if ub.chk-doc.chk-type = Integer('11':U) then do:
         assign
         bc-buf = trim( n-entry[2] )
         curr-string-qnty = dec( n-entry[3] )
         price-from-check = 0
         sum-from-check = 0
         t-c-d = 0
          time-oper_ =  if integer(ibmspool) >= 4
                        then (
                              int( substr( n-entry[9], 1, 2 ) ) * 3600 + int( substr( n-entry[9], 3, 2 ) ) * 60  +
                              int( substr(n-entry[9], 5, 2) )
                              )
                        else ub.chk-doc.chk-time
         pass-gds_ =  0
         pump_ = 0
         road-tax_ = 0
         no-add-price = no
         no-error
         .
      end.
      else do:
        assign
        curr-string-qnty = dec( n-entry[4] )
        bc-buf = trim( n-entry[2] )
        price-from-check = dec( n-entry[3] )
        sum-from-check = dec( n-entry[7] )
        t-c-d = - dec ( n-entry[5])
        time-oper_ =  if integer(ibmspool) >= 4
                      then (
                            int( substr( n-entry[9], 1, 2 ) ) * 3600 + int( substr( n-entry[9], 3, 2 ) ) * 60  +
                            int( substr(n-entry[9], 5, 2) )
                            )
                      else ub.chk-doc.chk-time
        pass-gds_ =  (if integer(ibmspool) >= 4 and integer(n-entry[8]) > 1
                      then 1
                      else 0
                      )
        pump_ = int(n-entry[6] )
        road-tax_ = (if ii > 8 and integer(ibmspool) <= 3 then dec(n-entry[9]) else 0 )
        no-add-price = if ii   > 7 and BinMask(int(n-entry[8]), "1") = yes
                      then yes
                      else no
        nozzle_ = if integer(ibmspool) >= 6
                  then integer(n-entry[10])
                  else 0
        place_ = if integer(ibmspool) >= 6
                  then integer(n-entry[11])
                  else 0
        no-error
        .
      end.
      if error-status:error then do:
        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
      end.
      CREATE ub.chk-gds.
      assign
      lng = lng + 1
      ub.chk-gds.doc-code = ub.chk-doc.doc-code
      ub.chk-gds.line-num = lng
      ub.chk-gds.grp-code = 0
      ub.chk-gds.chk-date = ub.chk-doc.chk-date
      ub.chk-gds.b-code = 0
      ub.chk-gds.src-code = bc-buf
      ub.chk-gds.src-price = price-from-check
      ub.chk-gds.src-sum   = sum-from-check
      ub.chk-gds.src-qnty = curr-string-qnty
      ub.chk-gds.doc-qnty = 0
      ub.chk-gds.price-service = (if no-add-price
                               then price-from-check
                               else 0)
      ub.chk-gds.time-oper = time-oper_
      ub.chk-gds.src-discnt = if integer(ibmspool) < 6 and curr-string-qnty <> 0
                           then  (t-c-d / curr-string-qnty)
                           else 0
      ub.chk-gds.pass-gds = pass-gds_
      ub.chk-gds.is-error = no
      ub.chk-gds.doc-qnty = 0
      ub.chk-gds.pump = pump_
      ub.chk-gds.nozzle = nozzle_
      ub.chk-gds.loc1 = (if place_ = 0 then '':U else string(place_))
      ub.chk-gds.road-tax = road-tax_
      ub.chk-gds.sales-man = sales-man_
      ub.chk-doc.sales-man = (if not v-flag-salesman
                          and
                          (
                          ub.chk-doc.sales-man = 0
                          or ub.chk-doc.sales-man = sales-man_
                          or sales-man_ = 0
                          )
                          then sales-man_
                          else 0)
      ub.chk-doc.sales-man = (if ub.chk-doc.sales-man = ? then 0 else ub.chk-doc.sales-man)
      v-flag-salesman   = (if not v-flag-salesman
                          and (sales-man_ <> 0 and sales-man_ <> ub.chk-doc.sales-man)
                          then yes
                          else v-flag-salesman)
      ub.chk-gds.src-d-card = (if d-card_ <> "":U then d-card_ else ?)
      ub.chk-gds.src-cli-type = (if cli-type_ = "":u then ? else cli-type_)
      ub.chk-gds.src-cli-code = (if cli-code_ = 0 then ? else cli-code_)
      ub.chk-gds.src-d-card = (if d-mask_ <> "":U then d-mask_ else ?)
      ub.chk-gds.d-card = (if d-mask_ <> "":U
                       and (d-card_ = "":U or trim(d-card_)  = string(0))
                       then d-mask_
                       else (if d-card_ <> "":U
                             then d-card_
                             else ub.chk-gds.d-card)
                       )
      ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer('1':U)
                          then (chk-gds.src-qnty >= 0)
                          else (chk-gds.src-qnty <= 0)
                          )
      ub.chk-gds.line-type = "":U
      ub.chk-gds.write-off-code = (if ub.chk-doc.chk-type = integer('17':U)
                                then  integer('17':U)
                                else 0)
      netto-for-sub-d = netto-for-sub-d + (if v-is-petrol-check then 0
                                           else (chk-gds.src-price - ub.chk-gds.src-discnt) * ub.chk-gds.src-qnty)
      .
      if ub.chk-gds.src-discnt <> 0
      and integer(ibmspool) < 6
      then do:
        create ub.chk-discnt.
        assign
        ub.chk-discnt.doc-code = ub.chk-doc.doc-code
        ub.chk-discnt.record-type = 0
        ub.chk-discnt.discnt-id = (var-discnt-id + 1)
        ub.chk-discnt.line-num = ub.chk-gds.line-num
        ub.chk-discnt.time-oper = ub.chk-doc.chk-time
        ub.chk-discnt.line-type = integer('1':U)
        ub.chk-discnt.line-sign =  (chk-gds.src-qnty >= 0 ) NE (chk-gds.src-discnt > 0 )
        ub.chk-discnt.pass-discnt = integer('0':U)
        ub.chk-discnt.value-type = integer('0':U)
        ub.chk-discnt.discnt-type = integer('0':U)
        ub.chk-discnt.src-d-card = ub.chk-gds.src-d-card
        ub.chk-discnt.d-card = ub.chk-gds.d-card
        ub.chk-discnt.discnt-value-abs = t-c-d
        ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
        ub.chk-discnt.object-sum = ub.chk-gds.src-sum
        ub.chk-discnt.discnt-value-pcnt = if ub.chk-gds.src-sum <> 0 then
                                        ub.chk-gds.src-discnt * curr-string-qnty / ub.chk-gds.src-sum * 100
                                        else 0
        ub.chk-discnt.object-line-num = ub.chk-gds.line-num
        ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
        ub.chk-discnt.obj-code = ub.chk-doc.obj-code
        ub.chk-discnt.obj-type = ub.chk-doc.obj-type
        ub.chk-discnt.chk-date = ub.chk-doc.chk-date
        ub.chk-discnt.chk-time = ub.chk-doc.chk-time
        var-discnt-id = var-discnt-id + 1
        .
       end.
    end.
  end.
end procedure.
procedure proc-02-gds :
DEFINE VARIABLE var-sub-d as decimal no-undo .
  do
  on error undo, return error
  :
    if exist then return.
    assign
    var-sub-d =  - dec( n-entry[2] )
    lng-sub-d = lng
    no-error
    .
    if error-status:error then dO:
      if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
    end.
    if var-sub-d = 0 then return.
    create ub.chk-discnt.
    assign
    ub.chk-discnt.doc-code = ub.chk-doc.doc-code
    ub.chk-discnt.record-type = 0
    ub.chk-discnt.discnt-id = (var-discnt-id + 1)
    ub.chk-discnt.line-num = ub.chk-gds.line-num
    ub.chk-discnt.time-oper = ub.chk-doc.chk-time
    ub.chk-discnt.line-type = integer('2':U)
    ub.chk-discnt.line-sign = yes
    ub.chk-discnt.pass-discnt = integer('0':U)
    ub.chk-discnt.value-type = integer('2':U)
    ub.chk-discnt.discnt-type = if ub.chk-doc.src-d-card <> ""
                              then integer('1':U)
                              else integer('5':U)
    ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
    ub.chk-discnt.discnt-value-abs = var-sub-d
    ub.chk-discnt.discnt-value-pcnt = if netto-for-sub-d = 0
                                    then 0
                                    else var-sub-d * 100 / netto-for-sub-d
    ub.chk-discnt.object-line-num = 0
    ub.chk-discnt.object-sum = netto-for-sub-d
    ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
    ub.chk-discnt.obj-code = ub.chk-doc.obj-code
    ub.chk-discnt.obj-type = ub.chk-doc.obj-type
    ub.chk-discnt.chk-date = ub.chk-doc.chk-date
    ub.chk-discnt.chk-time = ub.chk-doc.chk-time
    var-discnt-id = var-discnt-id + 1
    sub-d = sub-d + var-sub-d
    netto-for-sub-d = netto-for-sub-d - sub-d
    .
    release ub.chk-discnt.
  end.
end procedure.
procedure proc-04-gds :
define buffer buf_tt-sum-grp for tt-sum-grp.
  do
  on error undo, return error return-value
  :
    if ( NOT exist ) AND ( dec( n-entry[4] ) <> 0 ) then  do:
      assign
      curr-string-qnty = dec( n-entry[4] )
      bc-buf = trim( n-entry[2] )
      price-from-check = dec( n-entry[3] )
      t-c-d = - dec( n-entry[5] )
      sum-from-check = dec(n-entry[6])
      time-oper_ =  if integer(ibmspool) >= 4
                    then (
                          int( substr( n-entry[9], 1, 2 ) ) * 3600 + int( substr( n-entry[9], 3, 2 ) ) * 60  +
                          int( substr(n-entry[9], 5, 2) )
                          )
                    else ub.chk-doc.chk-time
      pass-gds_ =  (if integer(ibmspool) >= 4 and integer(n-entry[8]) > 1
                    then 1
                    else 0
                    )
      no-error
      .
      if error-status:error then do:
        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
      end.
      if curr-string-qnty <> 0 then  do:
        if get-chkc_context.ibmgroup and  can-find(first tt-sum-grp) then do:
          find first buf_tt-sum-grp no-lock where
                  buf_tt-sum-grp.grp-code = integer(bc-buf)
          no-error .
          if not available buf_tt-sum-grp then do:
            assign
            bc-buf = chr(4) + bc-buf.
          end.
          else do:
            assign
            bc-buf = string(buf_tt-sum-grp.code-2) + chr(4) + bc-buf.
          end.
          CREATE ub.chk-gds.
          assign
          lng = lng + 1
          ub.chk-gds.doc-code = ub.chk-doc.doc-code
          ub.chk-gds.line-num = lng
          ub.chk-gds.chk-date = ub.chk-doc.chk-date
          ub.chk-gds.src-code = bc-buf
          ub.chk-gds.doc-qnty = 0
          ub.chk-gds.src-discnt = t-c-d
          ub.chk-gds.src-qnty = sum-from-check
          ub.chk-gds.src-price = 1
          ub.chk-gds.src-sum = sum-from-check
          ub.chk-gds.time-oper =  time-oper
          ub.chk-gds.pass-gds = pass-gds_
          ub.chk-gds.sum-base = ub.chk-gds.src-qnty * ub.chk-gds.src-price
          ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer('1':U)
                              then (chk-gds.src-qnty >= 0)
                              else (chk-gds.src-qnty <= 0)
                              )
          ub.chk-gds.line-type = "":U
          .
          if available buf_tt-sum-grp and buf_tt-sum-grp.gtype = 24
          and integer(ibmspool) < 6
          then do:
            assign
            ub.chk-doc.src-d-card = entry(1, ub.chk-doc.doc-num, chr(4) ).
          end.
        end.
        else do:
          CREATE ub.chk-gds.
          assign
          lng = lng + 1
          ub.chk-gds.doc-code = ub.chk-doc.doc-code
          ub.chk-gds.line-num = lng
          ub.chk-gds.grp-code = integer(bc-buf)
          ub.chk-gds.chk-date = ub.chk-doc.chk-date
          ub.chk-gds.b-code = 0
          ub.chk-gds.price-base = price-from-check
          ub.chk-gds.doc-qnty = curr-string-qnty
          ub.chk-gds.src-discnt = t-c-d
          ub.chk-gds.src-qnty = curr-string-qnty
          ub.chk-gds.src-price = price-from-check
          ub.chk-gds.src-sum = sum-from-check
          ub.chk-gds.time-oper =  time-oper
          ub.chk-gds.pass-gds = pass-gds_
          ub.chk-gds.sum-base = ub.chk-gds.doc-qnty * ub.chk-gds.price-base
          ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer('1':U)
                              then (chk-gds.src-qnty >= 0)
                              else (chk-gds.src-qnty <= 0)
                              )
          ub.chk-gds.line-type = "grp":U
          .
        end.
      end.
    end.
  end.
end procedure.
procedure proc-13 :
do
on error undo, return error
:
  if get-chkc_context.cas-shft then do:
    if current-pay-desk <> pay-desk_
    or NOT (current-cas-shift-name =  shift-name_
        AND current-cas-shift-date = shift-date_)
    OR not avail buf_shift-cash then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_get-cash-shift in g#libchkvl
  (input  buffer get-chkc_context:handle
  ,buffer buf_shift-cash
  ,input  pay-desk_
  ,input  shift-date_
  ,input  shift-name_
  ,input z-num_
  ,input chk-date_
  ,input chk-time_
  ,input shift-open-time_
    ) no-error .
      if available buf_shift-cash then do:
        assign
        current-pay-desk = buf_shift-cash.cash-num
        current-cas-shift-name = buf_shift-cash.shift-name
        current-cas-shift-date = buf_shift-cash.shift-date
        .
      end.
      else do:
        current-pay-desk = -1.
      end.
    end.
  end.
end.
end procedure.
procedure proc-08 :
  do
  on error undo, return error
  :
    assign
    sales-man_ = integer(n-entry[2])
    no-error .
    if error-status:error then do:
      if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
    end.
    assign
    ub.chk-doc.sales-man = (if ub.chk-doc.sales-man = sales-man_
                          or (not v-flag-salesman
                            and
                            (ub.chk-doc.sales-man = 0 or ub.chk-doc.sales-man = ?)
                            )
                        then sales-man_
                        else 0)
    v-flag-salesman   = (if not v-flag-salesman  and sales-man_ <> 0
                        then yes
                        else v-flag-salesman)
    .
  end.
end procedure.
procedure proc-09 :
define variable v-dopi as integer no-undo .
define variable src-d-card_ as character no-undo .
  do
  on error undo, return error
  :
    if not exist and available ub.chk-doc then do:
      assign
      cli-code_ = 0
      cli-type_ =  "":U
      d-card_ = "":U
      d-mask_ = "":U
      src-d-card_ = '':U
      .
      assign
      src-d-card_ = n-entry[3]
      d-card_ = n-entry[5]
      cli-code_ = integer(n-entry[2])
      d-mask_ = n-entry[4]
      cli-type_ = (if cli-code_ > 999999999 then 'орг':U else 'чел':U)
      no-error .
      if error-status:error then do:
        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
      end.
      assign
      v-dopi = integer(ub.chk-doc.src-d-card)
      no-error .
      assign
      ub.chk-doc.src-d-card       = (if   ub.chk-doc.src-d-card = d-card_
                                then ub.chk-doc.src-d-card
                                else (if true
                                      then (if d-mask_ <> '0':U then src-d-card_ else d-card_)
                                      else "-0":U
                                      )
                                )
      ub.chk-doc.src-cli-type   = (if cli-type_ = "":U
                                or ub.chk-doc.src-cli-type = cli-type_
                                then ub.chk-doc.src-cli-type
                                else (if true
                                      then cli-type_
                                      else ?)
                              )
      ub.chk-doc.src-cli-code   = (if cli-code_ = 0
                                or ub.chk-doc.src-cli-code = cli-code_
                                then ub.chk-doc.src-cli-code
                                else (if true
                                      then cli-code_
                                      else ?)
                              )
      ub.chk-doc.src-d-mask   = (if d-mask_ = "":U
                                or ub.chk-doc.src-d-mask = d-mask_
                                then ub.chk-doc.src-d-mask
                                else (if true
                                      then d-mask_
                                      else ?)
                              )
      ub.chk-doc.d-card = if d-mask_ <> "":U
                      and trim(n-entry[5]) = string(0)
                      then d-mask_
                      else (if ub.chk-doc.d-card <> "":U then ub.chk-doc.d-card else d-card_)
      .
    end.
  end.
end procedure.
procedure proc-10 :
define variable lnd-spl as integer no-undo .
define variable disc-sum_ as decimal no-undo .
define variable disc-pcnt_ as decimal no-undo .
define variable disc-reason_ as integer no-undo .
define variable disc-vtype_ as integer no-undo .
define variable disc-type_ as integer no-undo .
define variable disc-mode_ as character no-undo .
define variable disc-kat_   as integer no-undo .
define variable v-dop-vtype_ as integer no-undo .
define variable src-sum_ as decimal no-undo .
  do
  on error undo, return error
  :
    if not exist then do:
      assign
      disc-sum_ = - decimal(n-entry[6])
      disc-pcnt_ = - decimal(n-entry[8])
      disc-reason_ = 0
      disc-type_ = integer(substring(n-entry[3], 3, 2))
      v-dop-vtype_ = integer(substring(n-entry[3], 1, 2))
      disc-vtype_  = if v-dop-vtype_ = 1
                     then integer('1':U)
                     else (if v-dop-vtype_ = 2
                           then integer('2':U)
                           else  (if v-dop-vtype_ = 3
                                  then integer('3':U)
                                  else integer('0':U)
                                 )
                          )
      disc-kat_    =  integer(n-entry[7])
      src-sum_ = decimal(n-entry[5])
      no-error
      .
      if error-status:error then do:
        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
      end.
      create ub.chk-discnt.
      assign
      ub.chk-discnt.doc-code = ub.chk-doc.doc-code
      ub.chk-discnt.record-type = 0
      ub.chk-discnt.discnt-id = (var-discnt-id + 1)
      ub.chk-discnt.line-num = ub.chk-gds.line-num
      ub.chk-discnt.time-oper = ub.chk-gds.time-oper
      ub.chk-discnt.line-type = integer('1':U)
      ub.chk-discnt.line-sign =  (chk-gds.src-qnty >= 0 ) NE (chk-gds.src-discnt > 0 )
      ub.chk-discnt.pass-discnt = integer('0':U)
      ub.chk-discnt.value-type = if disc-vtype_ = 0
                              then integer('0':U)
                              else disc-vtype_
      ub.chk-discnt.src-d-card = ub.chk-gds.src-d-card
      ub.chk-discnt.d-card = ub.chk-gds.d-card
      ub.chk-discnt.discnt-value-abs = (if disc-sum_ <> 0 then disc-sum_ else (disc-pcnt_ * src-sum_  / 100))
      ub.chk-discnt.discnt-value-pcnt = disc-pcnt_
      ub.chk-discnt.kateg = disc-kat_
      ub.chk-gds.src-discnt  = ub.chk-gds.src-discnt + (if disc-sum_ <> 0
                                                  then disc-sum_
                                                  else (disc-pcnt_ * src-sum_  / 100)) / ub.chk-gds.src-qnty
      netto-for-sub-d = netto-for-sub-d - (chk-gds.src-discnt  * ub.chk-gds.src-qnty)
      ub.chk-discnt.object-line-num = ub.chk-gds.line-num
      ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
      ub.chk-discnt.obj-code = ub.chk-doc.obj-code
      ub.chk-discnt.obj-type = ub.chk-doc.obj-type
      ub.chk-discnt.chk-date = ub.chk-doc.chk-date
      ub.chk-discnt.chk-time = ub.chk-doc.chk-time
      ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
      ub.chk-discnt.object-sum = src-sum_
      var-discnt-id = var-discnt-id + 1
      .
      assign
      ub.chk-discnt.discnt-type = if disc-type_ > 0
                               then convert-discount(disc-reason_, disc-type_, ub.chk-discnt.line-type)
                               else integer('0':U)
      .
    end.
  end.
end procedure.
procedure proc-16 :
define variable  bonus-accounter_  as integer no-undo .
define variable  bonus-trans-id_   as integer no-undo .
define variable  bonus-src-d-card_ as character no-undo .
define variable  bonus-curr-code_  as integer no-undo .
define variable  bonus-sum_        as decimal no-undo .
define variable  bonus-schema_     as integer no-undo .
define variable  bonus-line-type-chr_ as character no-undo .
define variable  bonus-object-line-num_ as integer no-undo .
define variable  bonus-src-code_   as decimal no-undo .
define variable  bonus-src-code-chr as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    if not exist then do:
      assign
      bonus-accounter_ = integer(n-entry[2])
      bonus-trans-id_ = integer(n-entry[3])
      bonus-src-d-card_ = n-entry[4]
      bonus-curr-code_ = integer(n-entry[5])
      bonus-sum_ = decimal(n-entry[6])
      bonus-schema_ = integer(n-entry[7])
      bonus-line-type-chr_ = n-entry[8]
      bonus-object-line-num_ = integer(n-entry[9])
      bonus-src-code-chr = n-entry[10]
      bonus-src-code_ = decimal(n-entry[10])
      no-error
      .
      if error-status:error then do:
        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
      end.
      create ub.chk-discnt.
      assign
      ub.chk-discnt.doc-code = ub.chk-doc.doc-code
      ub.chk-discnt.record-type = 4
      ub.chk-discnt.line-num = ub.chk-gds.line-num
      ub.chk-discnt.discnt-id = (if bonus-trans-id_ = 0 then ub.chk-discnt.line-num else bonus-trans-id_)
      ub.chk-discnt.time-oper = ub.chk-gds.time-oper
      ub.chk-discnt.line-type = (if bonus-line-type-chr_ = 'I'
                              then integer('1':U)
                              else (if bonus-line-type-chr_ = 'T'
                                    then integer('2':U)
                                    else integer('0':U)
                                   )
                              )
      ub.chk-discnt.pass-discnt = bonus-accounter_
      ub.chk-discnt.value-type = integer('5':U)
      ub.chk-discnt.src-d-card = bonus-src-d-card_
      ub.chk-discnt.d-card = bonus-src-d-card_
      ub.chk-discnt.discnt-value-abs = bonus-sum_
      ub.chk-discnt.discnt-value-pcnt = (if ub.chk-discnt.line-type = integer('1':U)
                                      then bonus-src-code_
                                      else 0)
      ub.chk-discnt.discnt-type = bonus-schema_
      ub.chk-discnt.kateg = (if bonus-curr-code_ > 0
                          then bonus-curr-code_
                          else (if bonus-curr-code_ = kassa-rub-code
                                then 0
                                else -1 )
                          )
      ub.chk-discnt.object-line-num = (if bonus-object-line-num_ <> 0
                                    then bonus-object-line-num_
                                    else ub.chk-gds.line-num)
      ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
      ub.chk-discnt.obj-code = ub.chk-doc.obj-code
      ub.chk-discnt.obj-type = ub.chk-doc.obj-type
      ub.chk-discnt.chk-date = ub.chk-doc.chk-date
      ub.chk-discnt.chk-time = ub.chk-doc.chk-time
      .
      if ub.chk-discnt.line-type = integer('1':U) then do:
        if available ub.chk-gds
        and (bonus-src-code-chr = ub.chk-gds.src-code
            or bonus-object-line-num_  = ub.chk-gds.line-num ) then do:
        end.
        else do:
          for each buf_chk-gds no-lock where
                  buf_Chk-gds.doc-code = ub.chk-doc.doc-code:
            if buf_chk-gds.src-code = bonus-src-code-chr then do:
              ub.chk-discnt.object-line-num = buf_chk-gds.line-num.
              leave.
            end.
          end.
        end.
      end.
      if ub.chk-discnt.line-type = integer('2':U)
      and available ub.chk-gds
      and ub.chk-discnt.object-line-num = ub.chk-gds.line-num then do:
        assign
        ub.chk-discnt.object-sum = netto-for-sub-d
        ub.chk-discnt.discnt-value-pcnt = (if netto-for-sub-d <> 0
                                       and (chk-discnt.kateg = - 1
                                       or ub.chk-discnt.kateg <> - 1
                                       and (
                                            (chk-discnt.kateg = 0
                                            and get-chkc_context.r-b = 'rubl':U
                                            )
                                            or
                                            (chk-discnt.kateg = get-chkc_context.base-code
                                            and get-chkc_context.r-b = 'base':U)
                                           ))
                                       then bonus-sum_ / ub.chk-gds.src-sum * 100
                                       else ub.chk-discnt.discnt-value-pcnt)
        .
      end.
    end.
  end.
end procedure.
procedure proc-end :
  do
  on error undo, return error
  :
     get-chkc_context.ll = lll.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_getcheck in g#libchkvl
  (input  buffer get-chkc_context:handle
  ,input  'ДОБАВЛЕНИЕ':U
  ,input  ''
  ,input  yes
  ,input  yes
  ,input  ?
  ,input  lng-sub-d
  ,input  sub-d
  ,input  var-discnt-id
  ,input-output prev-code
    ) no-error .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_getwcheck in g#libchkvl
  (input  buffer get-chkc_context:handle
  ,input  'ДОБАВЛЕНИЕ':U
  ,input  ''
  ,input  yes
  ,input  yes
  ,input  ?
  ,input-output mc-prev-code
    ) no-error .
      .
     assign
     prev-code = "":U
     mc-prev-code = "":U
     p-view-log = (p-view-log or get-chkc_context.view-log)
     lll = get-chkc_context.ll
     .
  end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-03 :
define input parameter loc-exist as logical no-undo .
  do
  on error undo, return error
  :
    assign
    v-end-of-check = yes
    pay-card_ = ""
    .
    if not loc-exist then do:
      assign
      tot_sum = dec( n-entry[5] )
      curr_code = ( if kassa-rub-code = INT(n-entry[4] )
                    then 0
                    else int( n-entry[4] )
                  )
      pay_code = int(n-entry[2])
      cass-rate = dec( substr( n-entry[6], 1, 11 ) )
      rate-por = int( substr( n-entry[6], 13, 3 ) )
      time-oper_ =  (if ibmspool ="4"
                    then
                          (
                          int( substr( n-entry[10], 1, 2 ) ) * 3600 +
                          int( substr( n-entry[10], 3, 2 ) ) * 60  +
                          int( substr(n-entry[10], 5, 2) )
                          )
                    else ub.chk-doc.chk-time
                    )
      bank-rate_ = dec(n-entry[7])
      bank-scale_ = int(n-entry[8])
      pass-pay_ = int(n-entry[9])
      pay-card_ =  (if n-entry[3] <> "0":U
                    then trim(n-entry[3])
                    else "":U
                    )
      no-error
      .
      if error-status:error then do:
        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
      end.
      FIND ub.chk-pay WHERE
            ub.chk-pay.doc-code = ub.chk-doc.doc-code AND
            ub.chk-pay.curr-code = curr_code AND
            ub.chk-pay.pay-code = pay_code
            NO-ERROR.
      if NOT available ub.chk-pay then  do:
        CREATE ub.chk-pay .
        assign
        lnp = lnp + 1
        ub.chk-pay.doc-code = ub.chk-doc.doc-code
        ub.chk-pay.line-num = lnp
        ub.chk-pay.chk-date = ub.chk-doc.chk-date
        ub.chk-pay.obj-code = shop-code
        ub.chk-pay.obj-type = shop-type
        ub.chk-pay.tot-rubl = 0
        ub.chk-pay.tot-sum = 0
        ub.chk-pay.tot-base = 0
        ub.chk-pay.pay-code = pay_code
        ub.chk-pay.curr-code = curr_code
        ub.chk-pay.time-oper = time-oper_
        cass-rate = cass-rate * exp( 10, int( rate-por ) )
        ub.chk-pay.cash-rate = cass-rate
        ub.chk-pay.bank-rate = bank-rate_
        ub.chk-pay.bank-scale = bank-scale_
        ub.chk-pay.pass-pay = pass-pay_
        ub.chk-pay.pay-card = pay-card_
        ub.chk-pay.line-type = "":U
        ub.chk-pay.line-sign = (if ub.chk-doc.chk-type = integer('1':U)
                            or not (chk-doc.chk-type = integer('2':U)
                                    or
                                    ub.chk-doc.chk-type =  integer('5':U)
                                    )
                            then (chk-pay.tot-sum >= 0)
                            else (chk-pay.tot-sum <= 0)
                            )
        ub.chk-pay.is-error = no
        .
      end.
      assign
      ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + tot_sum
      .
    end.
  end.
end procedure.
