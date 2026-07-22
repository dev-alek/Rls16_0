block-level on error undo, throw.
define input parameter parparentproc as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-encoding as character no-undo .
DEFINE INPUT PARAMETER file_ as longchar no-undo.
define input parameter p-spool-or-data as character no-undo .
define input-output parameter p-view-log as logical  no-undo .
DEFINE VARIABLE vss-revision    as character no-undo init "$Revision$":u .
DEFINE VARIABLE vss-author      as character no-undo init "$Author$":u .
DEFINE VARIABLE vss-date        as character no-undo init "$Date$":u .
DEFINE VARIABLE vss-workfile    as character no-undo init "$Workfile$":u .
DEFINE VARIABLE vss-archive     as character no-undo init "$Archive$":u .
DEFINE VARIABLE vss-description as character no-undo init "Программа приема чеков с касс IBM-XML" .
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
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info7 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info7, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info7, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info7 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info7, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info7, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info7, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info7, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info7, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info7, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info7 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info7, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info7 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info7 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info7, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info7, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable vss-include-info9 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_xmlparse-attrs no-undo
field field-name as character
field attr-code as character
field attr-value as character
index pi is unique primary
field-name attr-code
.
procedure xmlparse :
define input parameter p-handle         as handle           no-undo.
define input parameter p-XML-buffer     as character        no-undo.
define input parameter p-call-mode      as character        no-undo.
    define variable v-procedure-type        as character    no-undo.
    define variable v-procedure-name        as character    no-undo.
    define variable v-temp-string           as character    no-undo.
    define variable v-current-position      as integer      no-undo.
    define variable v-end-position          as integer      no-undo.
    define variable v-text-position         as integer      no-undo.
    define variable v-input-buffer-length   as integer      no-undo.
    define variable v-handle                as handle       no-undo.
    define variable v-call-mode             as character    no-undo.
    define variable v-proc-type             as character    no-undo.
    define variable v-proc-name             as character    no-undo.
    define variable v-decode-string         as character    no-undo.
do
on error undo, return error
:
    if not valid-handle( p-handle )
    then do:
        return.
    end.
    assign
        v-end-position          = 1
        v-current-position      = 1
        v-input-buffer-length   = length( p-XML-buffer )
    .
    do
    while v-end-position < v-input-buffer-length
    :
        assign
            v-current-position = index( p-XML-buffer, "<":U, v-end-position )
        .
        if v-current-position = 0
        then do:
            assign
                v-decode-string = substring( p-XML-buffer, v-end-position )
            .
            run xmlchar-decode in this-procedure (
                  input v-decode-string
                , output v-temp-string
            ).
            assign
                v-handle     = p-handle
                v-call-mode  = p-call-mode
                v-proc-type  = 'text':U
                v-proc-name  = '':U
            .
            run run-callback-procedure in this-procedure (
                  input v-handle
                , input v-call-mode
                , input v-proc-type
                , input v-proc-name
                , input v-temp-string
            ).
            assign
                v-end-position = v-input-buffer-length
            .
        end.
        else do:
            if v-current-position > v-end-position
            then do:
                assign
                    v-decode-string = substring( p-XML-buffer, v-end-position, v-current-position - v-end-position )
                .
                run xmlchar-decode in this-procedure (
                      input v-decode-string
                    , output v-temp-string
                ).
                assign
                    v-end-position = v-current-position
                .
                assign
                    v-handle     = p-handle
                    v-call-mode  = p-call-mode
                    v-proc-type  = 'text':U
                    v-proc-name  = '':U
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-proc-type
                    , input v-proc-name
                    , input v-temp-string
                ).
            end.
            assign
                v-decode-string = substring( p-XML-buffer, v-end-position + 1, 1 )
            .
            if v-decode-string = "/":U
            then do:
                assign
                    v-procedure-type    = "tag-end":U
                    v-end-position      = v-current-position + 1
                .
            end.
            else do:
                assign
                    v-procedure-type    = "tag-start":U
                    v-end-position      = v-current-position
                .
            end.
            assign
                v-current-position  = index(p-XML-buffer, "/>":U, v-end-position)
            .
            if v-current-position <= v-end-position
            then do:
                assign
                    v-current-position  = index(p-XML-buffer, ">":U, v-end-position)
                .
            end.
            assign
                v-end-position      = v-end-position + 1
            .
            if v-current-position <= v-end-position
            then do:
                run run-cb-xmlparse-error in this-procedure
                                        (   input p-handle
                                        ,   input 'Ошибка: знак < без завершающего > на той же строке'
                                        ).
                assign
                    v-temp-string   = "<":U + substring(p-XML-buffer, v-end-position)
                    v-end-position  = v-input-buffer-length
                .
                assign
                    v-handle     = p-handle
                    v-call-mode  = p-call-mode
                    v-proc-type  = 'text':U
                    v-proc-name  = '':U
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-proc-type
                    , input v-proc-name
                    , input v-temp-string
                ).
            end.
            else do:
                assign
                    v-temp-string   = trim( substring(      p-XML-buffer
                                                        ,   v-end-position
                                                        ,   v-current-position - v-end-position
                                          )          )
                    v-text-position = index( v-temp-string, " ":U )
                .
                if v-text-position <> 0
                then do:
                    assign
                        v-procedure-name    =   trim( substring(      v-temp-string
                                                                    ,   1
                                                                    ,   v-text-position
                                                      )          )
                        v-temp-string       =   trim( substring(    v-temp-string
                                                                ,   v-text-position + 1
                                                    )          )
                    .
                end.
                else do:
                    assign
                        v-procedure-name    =   v-temp-string
                        v-temp-string       =   "":U
                    .
                end.
                assign
                    v-end-position      = v-current-position + 1
                .
                assign
                    v-handle          = p-handle
                    v-call-mode       = p-call-mode
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-procedure-type
                    , input v-procedure-name
                    , input v-temp-string
                ).
            end.
        end.
    end.
end.
end procedure.
procedure run-callback-procedure :
define input parameter p-handle             as handle           no-undo.
define input parameter p-call-mode          as character        no-undo.
define input parameter p-procedure-type     as character        no-undo.
define input parameter p-procedure-name     as character        no-undo.
define input parameter p-param-value        as character        no-undo.
    define variable v-data-type         as character            no-undo.
    define variable v-data-value        as character            no-undo.
    define variable v-procedure-name    as character            no-undo.
    define variable v-procedure-exists  as logical      no-undo.
do
on error undo, return error
:
    if p-call-mode = "call-all":U
    or p-call-mode = "call-named":U
    then do:
        case p-procedure-type :
            when "text":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-text":U
                .
            end.
            when "tag-end":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-tag-end-":U + p-procedure-name
                .
            end.
            when "tag-start":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-tag-start-":U + p-procedure-name
                .
            end.
            otherwise do:
                assign
                    v-procedure-name = p-procedure-name
                .
            end.
        end case.
        if p-handle :get-signature( v-procedure-name ) = "":U
        then do:
            assign
                v-procedure-exists = no
            .
        end.
        else do:
            assign
                v-procedure-exists = yes
            .
        end.
        if v-procedure-exists = yes
        then do:
            run value(v-procedure-name) in p-handle (input p-param-value) no-error.
            if error-status :error
            then do:
                run run-cb-xmlparse-error in this-procedure (
                    input p-handle
                    , input "Ошибка при вызове программы " + v-procedure-name
                ).
            end.
        end.
    end.
    if ( p-call-mode = "call-all":U
        and v-procedure-exists <> yes )
    or p-call-mode = "call-unnamed":U
    then do:
        case p-procedure-type :
            when 'text':U
            then do:
                assign
                    v-data-type     = 'text':U
                    v-data-value    = p-param-value
                .
            end.
            when 'tag-end':U
            then do:
                assign
                    v-data-type     = 'tag-end':U
                    v-data-value    = p-procedure-name
                .
            end.
            when 'tag-start':U
            then do:
                assign
                    v-data-type     = 'tag-start':U
                    v-data-value    = p-procedure-name
                .
            end.
            otherwise do:
                assign
                    v-data-type     = 'text':U
                    v-data-value    = p-procedure-name
                .
            end.
        end case.
        run run-cb-xmlparse-procedure-not-found in this-procedure (
              input p-handle
            , input v-data-type
            , input v-data-value
            , input p-param-value
        ).
    end.
end.
end procedure.
procedure run-cb-xmlparse-error :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-error-message as char no-undo.
    if lookup("cb-xmlparse-error", p-handle :internal-entries) > 0
    then do:
        run cb-xmlparse-error in p-handle  (input p-error-message).
    end.
end.
end procedure.
procedure run-cb-xmlparse-procedure-not-found :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-data-type         as char no-undo.
    def input parameter p-data-value        as char no-undo.
    def input parameter p-param-value       as char no-undo.
    if lookup("cb-xmlparse-procedure-not-found", p-handle :internal-entries) > 0
    then do:
        run cb-xmlparse-procedure-not-found in p-handle    (   input p-data-type
                                                          , input p-data-value
                                                          , input p-param-value
                                                        ) no-error.
        if error-status :error
        then do:
            run run-cb-xmlparse-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы cb-xmlparse-procedure-not-found"
                                    ).
        end.
    end.
    else do:
        run run-cb-xmlparse-error in this-procedure
                                (   input p-handle
                                ,   input "Ошибка: Не определена программа cb-xmlparse-procedure-not-found"
                                ).
    end.
end.
end procedure.
procedure cb-xmlparse-attributes :
define input  parameter p-handle            as handle no-undo.
define input  parameter p-field-name        as character no-undo .
define input  parameter p-field-value       as character no-undo .
define variable ii as integer no-undo init 1.
define variable v-input-buffer-length   as integer no-undo.
define variable v-dc as logical no-undo .
define variable v-sc as logical no-undo .
define variable v-eq as logical no-undo .
define variable v-char as character no-undo .
define variable v-code as character no-undo .
define variable v-value as character no-undo .
define buffer buf_temp_xmlparse-attrs for temp_xmlparse-attrs.
  do
  on error undo, return error
  :
    if index(p-field-value, '>':U) > 0 then do:
      run run-cb-xmlparse-error in this-procedure
                              (   input p-handle
                              ,   input substitute("Ошибка: тэг &1 содержит другие тэги", p-field-name)
                              ).
    end.
    assign
    p-field-value = trim(p-field-value)
    .
    for each buf_temp_xmlparse-attrs where
            buf_temp_xmlparse-attrs.field-name = p-field-name:
      delete buf_temp_xmlparse-attrs.
    end.
    assign
    v-input-buffer-length = length( p-field-value )
    .
    do while ii <= v-input-buffer-length:
      assign
      v-char = substr(p-field-value, ii, 1)
      ii = ii + 1
      .
      CASE v-char:
        when "=":U then do:
          if v-eq
          and not v-dc
          and not v-sc then do:
            return error.
          end.
          assign
          v-eq = yes
          .
        end.
        when chr(34) then do:
        if v-eq then
        assign
        v-dc = not(v-dc)
        .
        else return error.
        end.
        when chr(39) then do:
        if v-eq then
        assign
        v-sc = not(v-sc)
        .
        else return error.
        end.
        when chr(32) then do:
          if not v-dc
          and not v-sc
          then do:
            assign
            v-sc = no
            v-dc = no
            v-eq = no
            .
            create buf_temp_xmlparse-attrs.
            assign
            buf_temp_xmlparse-attrs.field-name = p-field-name
            buf_temp_xmlparse-attrs.attr-code  = v-code
            buf_temp_xmlparse-attrs.attr-value = trim(v-value, (if v-value begins chr(34) then chr(34) else chr(39)))
            v-code = "":U
            v-value = "":U
            .
          end.
        end.
      END CASE.
      if not v-eq
      then do:
        if not v-char = chr(32) then
        assign
        v-code = v-code + v-char
        .
      end.
      else do:
        if v-char <> "=":U
        then
        assign
        v-value = v-value + v-char
        .
      end.
    end.
    if v-code <> "":U then do:
      create buf_temp_xmlparse-attrs.
      assign
      buf_temp_xmlparse-attrs.field-name = p-field-name
      buf_temp_xmlparse-attrs.attr-code  = v-code
      buf_temp_xmlparse-attrs.attr-value = trim(v-value, (if v-value begins chr(34) then chr(34) else chr(39)))
      .
    end.
  end.
end procedure.
FUNCTION cb-xmlparse-get-attr returns character (
      input p-handle        as handle
    , input p-field-name    as character
    , input p-field-value   as character
    , input p-attr-code     as character
    , input p-reparse       as logical
) :
define buffer buf_temp_xmlparse-attrs for temp_xmlparse-attrs.
  do
  on error undo, return error
  :
    if p-reparse then do:
      run cb-xmlparse-attributes in this-procedure (
                                                    input p-handle
                                                  , input p-field-name
                                                  , input p-field-value) no-error .
      if error-status:error then return ? .
    end.
    find first buf_temp_xmlparse-attrs no-lock where
              buf_temp_xmlparse-attrs.field-name = p-field-name
          AND buf_temp_xmlparse-attrs.attr-code   = p-attr-code no-error .
    if not avail buf_temp_xmlparse-attrs then return ?.
    return buf_temp_xmlparse-attrs.attr-value.
  end.
end FUNCTION.
FUNCTION cb-xmlparse-get-date returns date (
                                            input p-string as character):
define variable v-date as date.
if index(p-string, "-":U) = 0
or NOT (length(p-string) = 10
        or
        length(p-string) = 19)
then return error.
assign
v-date =  date(
          int( substr( p-string, 6, 2 ) ) ,
          int( substr( p-string, 9, 2 ) ),
          int( substr( p-string, 1, 4 ) )
            )
no-error .
if error-status:error then return error.
return v-date.
END FUNCTION.
FUNCTION cb-xmlparse-get-time returns integer (input p-string as character):
define variable v-time as integer no-undo .
define variable v-shift as integer no-undo .
if index(p-string, ":":U) = 0
or not (
        length(p-string) = 19
        or
        length(p-string) = 8
        )
then return error.
if length(p-string) = 19 then v-shift = 11.
assign
v-time =  int( substr( p-string, v-shift + 1, 2 ) ) * 3600 +
          int( substr( p-string, v-shift + 4, 2 ) ) * 60  +
          int( substr( p-string, v-shift + 7, 2) )
no-error .
if error-status:error then return error.
return v-time.
END FUNCTION.
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-xmlvalid-error-mode       as character    no-undo.
define variable v-xmlvalid-tag-value        as character    no-undo.
define variable v-xmlvalid-current-level    as integer      no-undo.
define variable v-xmlvalid-in-tag           as logical      no-undo.
define variable v-xmlvalid-read-vartype     as logical      no-undo.
define temp-table temp_xmlvalid-taglist no-undo
    field level-num as integer
    field tag-name  as character
    index lv  is primary unique level-num
.
define temp-table temp_xmlvalid-field-types no-undo
    field field-name as character
    field field-type as character
    index fn is primary unique field-name
.
procedure xmlvalid :
  do
  on error undo, return error
  :
    def input parameter p-handle                as handle   no-undo.
    def input parameter p-buffer-string         as char     no-undo.
    def input parameter p-xmlvalid-error-mode   as char     no-undo.
    assign
        v-xmlvalid-error-mode   = p-xmlvalid-error-mode
    .
    run xmlparse in this-procedure (
              input p-handle
            , input p-buffer-string
            , input "call-all":U
    ).
  end.
end procedure.
procedure cb-xmlparse-tag-start-varType :
do
on error undo, return error
:
define input parameter p-param as character    no-undo.
    assign
        v-xmlvalid-read-vartype = yes
    .
    run cb-xmlparse-procedure-not-found in this-procedure (
          input "tag-start":U
        , input "varType":U
        , input p-param
    ).
end.
end procedure.
procedure cb-xmlparse-tag-end-varType :
do
on error undo, return error
:
define input parameter p-param as character    no-undo.
    assign
        v-xmlvalid-read-vartype = no
    .
    define variable v-vartype-list     as character         no-undo.
    for each temp_xmlvalid-field-types
    :
        if index( "character,integer,decimal,date,logical", temp_xmlvalid-field-types.field-type ) = 0
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Замечание: Тип переменной в секции varType определен неверно. "
                                                    + "Тэг " + temp_xmlvalid-field-types.field-name
                                                    + " не будет проверен на соответствие типу данных"
                                        ).
            delete temp_xmlvalid-field-types.
        end.
        else do:
                                        assign
                                            v-vartype-list = v-vartype-list + temp_xmlvalid-field-types.field-name
                                            + temp_xmlvalid-field-types.field-type + chr(10)
                                        .
        end.
    end.
    run cb-xmlparse-procedure-not-found in this-procedure (
                                        input "tag-end":U
                                        , input "varType":U
                                        , input p-param
                                                        ).
end.
end procedure.
procedure cb-xmlparse-procedure-not-found :
do
on error undo, return error
:
def input parameter p-tag-type      as char no-undo.
def input parameter p-tag-value     as char no-undo.
def input parameter p-param-value   as char no-undo.
def buffer buf_temp_xmlvalid-taglist for temp_xmlvalid-taglist.
def var v-found    as logical  no-undo.
if p-tag-type = "tag-start"
then do:
    assign
        v-xmlvalid-current-level = v-xmlvalid-current-level + 1
        v-xmlvalid-in-tag        = yes
    .
    find first temp_xmlvalid-taglist
         where temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
    no-error.
    if not available temp_xmlvalid-taglist
    then do:
        create temp_xmlvalid-taglist.
        assign
            temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
        .
    end.
    assign
        temp_xmlvalid-taglist.tag-name = p-tag-value
        v-xmlvalid-tag-value = ""
    .
    if v-xmlvalid-read-vartype = yes and p-tag-value <> "varType":U
    then do:
        find first temp_xmlvalid-field-types
             where temp_xmlvalid-field-types.field-name = p-tag-value
        no-error.
        if available temp_xmlvalid-field-types
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Замечание: Тип переменной в секции varType определен повторно"
                                        ).
        end.
        else do:
            create temp_xmlvalid-field-types.
            assign
                temp_xmlvalid-field-types.field-name = p-tag-value
            .
        end.
    end.
end.
if p-tag-type = "tag-end"
then do:
    find first temp_xmlvalid-taglist
         where temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
           and temp_xmlvalid-taglist.tag-name  = p-tag-value
    no-error.
    if available temp_xmlvalid-taglist
    then do:
        assign
            v-xmlvalid-current-level = v-xmlvalid-current-level - 1
            v-xmlvalid-in-tag        = no
        .
    end.
    else do:
        if v-xmlvalid-error-mode = 'fatal'
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Ошибка: Попытка закрыть не открытый тэг"
                                        ).
        end.
        else do:
            find first temp_xmlvalid-taglist
                 where temp_xmlvalid-taglist.tag-name = p-tag-value
            no-error.
            if not available temp_xmlvalid-taglist
            then do:
                assign
                    v-xmlvalid-tag-value = v-xmlvalid-tag-value + "</" + p-tag-value + ">" + chr(10)
                .
            end.
            else do:
                for each buf_temp_xmlvalid-taglist
                   where buf_temp_xmlvalid-taglist.level-num > temp_xmlvalid-taglist.level-num
                :
                    assign
                        v-xmlvalid-tag-value = "<" + buf_temp_xmlvalid-taglist.tag-name + ">" + chr(10) + v-xmlvalid-tag-value
                        v-xmlvalid-current-level = temp_xmlvalid-taglist.level-num - 1
                    .
                end.
            end.
        end.
    end.
end.
if p-tag-type = "text"
then do:
    if v-xmlvalid-read-vartype = yes
    then do:
        if available temp_xmlvalid-field-types
        then do:
            assign
                temp_xmlvalid-field-types.field-type = v-xmlvalid-tag-value
            .
        end.
    end.
    else do:
        find first temp_xmlvalid-field-types
            where temp_xmlvalid-field-types.field-name = temp_xmlvalid-taglist.tag-name
        no-error.
        if available temp_xmlvalid-field-types
        then do:
        end.
        else do:
        end.
    end.
    assign
        v-xmlvalid-tag-value = v-xmlvalid-tag-value + p-tag-value
    .
end.
run run-cb-xmlvalid-procedure-not-found in this-procedure
                                        (     input this-procedure :handle
                                            , input p-tag-type
                                            , input p-tag-value
                                            , input p-param-value
                                        ).
end.
end procedure.
procedure run-cb-xmlvalid-procedure-not-found :
do
on error undo, return error
:
    def input parameter p-handle            as handle   no-undo.
    def input parameter p-data-type         as char     no-undo.
    def input parameter p-data-value        as char     no-undo.
    def input parameter p-param-value       as char     no-undo.
    if lookup("cb-xmlvalid-procedure-not-found", p-handle :internal-entries) > 0
    then do:
        run cb-xmlvalid-procedure-not-found in p-handle (   input p-data-type
                                                          , input p-data-value
                                                          , input p-param-value
                                                        ) no-error.
        if error-status :error
        then do:
            run run-cb-xmlvalid-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы cb-xmlvalid-procedure-not-found"
                                    ).
        end.
    end.
    else do:
        run run-cb-xmlvalid-error in this-procedure
                                (   input p-handle
                                ,   input "Ошибка: Не определена программа cb-xmlvalid-procedure-not-found"
                                ).
    end.
end.
end procedure.
procedure run-cb-xmlvalid-error :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-error-message as char no-undo.
    if lookup("cb-xmlvalid-error", p-handle :internal-entries) > 0
    then do:
        run cb-xmlvalid-error in p-handle  (input p-error-message).
    end.
end.
end procedure.
procedure run-cb-xmlvalid-procedure :
do
on error undo, return error
:
def input parameter p-handle            as handle no-undo.
def input parameter p-procedure-name    as char no-undo.
def var v-data-type     as char no-undo.
def var v-data-value    as char no-undo.
def var v-param-value   as char no-undo.
    if lookup( p-procedure-name, p-handle :internal-entries) > 0
    then do:
        run value(p-procedure-name) in p-handle no-error.
        if error-status :error
        then do:
            run run-cb-xmlvalid-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы " + p-procedure-name
                                    ).
        end.
    end.
    else do:
        if substring(p-procedure-name, 1, 20) = "cb-xmlvalid-tag-end-"
        then do:
            assign
                v-data-type     = "tag-end"
                v-data-value    = substring(p-procedure-name, 21)
            .
        end.
        else do:
            if substring(p-procedure-name, 1, 22) = "cb-xmlvalid-tag-start-"
            then do:
                assign
                    v-data-type     = "tag-start"
                    v-data-value    = substring(p-procedure-name, 23)
                .
            end.
            else do:
                assign
                    v-data-type     = "text"
                    v-data-value    = p-procedure-name
                .
            end.
        end.
        run run-cb-xmlvalid-procedure-not-found in this-procedure
                                               (   input p-handle
                                                  , input v-data-type
                                                  , input v-data-value
                                                  , input v-param-value
                                                ).
    end.
end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure chkdocat-name :
do
  on error undo, return error return-value
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'lock':U then do:     assign     p-label = "Блокировка атрибутов на изменение"     p-type = 'L':U      p-format = "yes/no"     p-label = "Блокировка атрибутов на изменение"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'out-code-2':U then do:     assign     p-label = "Номер док-та, использующего чек"     p-type = 'C':U      p-format = "X(14)"     p-label = "Номер док-та, использующего чек"     p-user-can-edit  = false     p-output-display = true     p-other = ""      .   end.
            when 'qr-alchol':U then do:     assign     p-label = "Qr-коды от ЕГАИС по алкоголю (кроме пива)"     p-type = 'C':U      p-format = "X(64)"     p-label = "Qr-коды от ЕГАИС по алкоголю (кроме пива)"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when '':U then do:     assign     p-label = "Qr-коды от ЕГАИС по пиву)"     p-type = 'C':U      p-format = "X(64)"     p-label = "Qr-коды от ЕГАИС по пиву)"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут чека &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure chkdocat-tooltip :
do
  on error undo, return error return-value
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'lock':U then do:     assign     p-tooltip = "Блокировка атрибутов на изменение"     p-label = "Блокировка атрибутов на изменение" .   end.
            when 'out-code-2':U then do:     assign     p-tooltip = "Номер док-та, использующего чек (кроме продажи)"     p-label = "Номер док-та, использующего чек" .   end.
            when 'qr-alchol':U then do:     assign     p-tooltip = "Qr-коды от ЕГАИС по алкоголю, (кроме пива)"     p-label = "Qr-коды от ЕГАИС по алкоголю (кроме пива)" .   end.
            when '':U then do:     assign     p-tooltip = "Qr-коды от ЕГАИС по пиву"     p-label = "Qr-коды от ЕГАИС по пиву)" .   end.
      otherwise do:
        undo, return error substitute("Неизвестный атрибут чека &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure chkdocat-value :
 do
  on error undo, return error
  :
    define input  parameter p-doc-code like ub.chk-doc-attr.doc-code   no-undo .
    define input  parameter p-code     like ub.chk-doc-attr.attr-code  no-undo .
    define output parameter p-value    like ub.chk-doc-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_chk-doc-attr for ub.chk-doc-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run chkdocat-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_chk-doc-attr no-lock where
               buf_chk-doc-attr.doc-code  = p-doc-code AND
               buf_chk-doc-attr.attr-code = p-code
      no-error .
    if avail buf_chk-doc-attr then do:
      assign
        p-value =  buf_chk-doc-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure chkdocat-write :
  do
  on error undo, return error
  :
    define input parameter p-doc-code like ub.chk-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.chk-doc-attr.attr-code  no-undo .
    define input parameter p-value    like ub.chk-doc-attr.attr-value no-undo .
    define buffer buf_chk-doc-attr for ub.chk-doc-attr .
    define buffer lock_chk-doc-attr for ub.chk-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run chkdocat-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_chk-doc-attr exclusive-lock where
               buf_chk-doc-attr.doc-code  = p-doc-code AND
               buf_chk-doc-attr.attr-code = p-code no-error .
    if not available buf_chk-doc-attr then do:
      create buf_chk-doc-attr .
      assign
        buf_chk-doc-attr.doc-code  = p-doc-code
        buf_chk-doc-attr.attr-code = p-code
        buf_chk-doc-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_chk-doc-attr.attr-value = p-value no-error.
  end.
end procedure.
procedure chkdocat-exist :
  do
  on error undo, return error
  :
    define input parameter p-doc-code like ub.chk-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.chk-doc-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .
    define buffer buf_chk-doc-attr for ub.chk-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run chkdocat-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_chk-doc-attr no-lock where
               buf_chk-doc-attr.doc-code  = p-doc-code AND
               buf_chk-doc-attr.attr-code = p-code no-error .
    if available buf_chk-doc-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure chkdocat-delete :
  do
  on error undo, return error
  :
    define input parameter p-doc-code like ub.chk-doc-attr.doc-code   no-undo .
    define input parameter p-code     like ub.chk-doc-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .
    define buffer buf_chk-doc-attr for ub.chk-doc-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run chkdocat-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_chk-doc-attr exclusive-lock where
               buf_chk-doc-attr.doc-code  = p-doc-code AND
               buf_chk-doc-attr.attr-code = p-code no-error .
    if not available buf_chk-doc-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_chk-doc-attr.
       P-DELETED = YES.
    END.
  end.
end procedure.
define stream stmXMLOut.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-xml-file-name     as character            no-undo.
define variable v-xml-file-name-path as character            no-undo.
define variable v-log-file-name     as character            no-undo.
define variable v-locked            as logical              no-undo.
define variable v-log-string        as character            no-undo.
define variable v-oper-num          as integer              no-undo.
define variable v-obj-list          as character            no-undo.
DEF VAR strDummy    AS CHAR view-as editor size 50 by 4 NO-UNDO.
DEF VAR intRep      AS INT NO-UNDO.
define variable hEDT             AS HANDLE NO-UNDO.
define variable hCNT             AS HANDLE NO-UNDO.
procedure xml-cd-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name       as character    no-undo.
define input parameter p-xml-file-name-path  as character    no-undo.
define input parameter p-doc-name            as character    no-undo.
define input parameter p-version             as character    no-undo.
define input parameter p-obj-list            as character    no-undo.
define input parameter p-correspondent       as character    no-undo .
define input parameter p-write-header        as logical      no-undo .
define variable OS-time as character no-undo .
define variable id as character no-undo .
define buffer buf_db for ub.db.
output stream stmXMLOut to value( p-xml-file-name-path + "xm1":U ) convert target "1251" append.
put stream stmXMLOut unformatted "<?xml version='1.0' encoding='windows-1251'?>".
assign
OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
.
run bgelib-tag-open in this-procedure (
                                     1
                                    ,p-doc-name
                                    ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", p-xml-file-name, p-obj-list, p-correspondent, OS-time )
                                      ).
if p-write-header then do:
  run bgelib-tag-open(2, "Header","").
  run bgelib-tag-put( 3, "DocumentName", p-doc-name, 1).
  run bgelib-tag-put( 3, "DateFormat", "DD.MM.YYYY":U, 1).
  run bgelib-tag-put( 3, "DocumentVersion", "1.02":U, 1).
  run bgelib-tag-put( 3, "DocumentVersionDate", "09.09.2004":U, 1).
  run bgelib-tag-put( 3, "ExportDate", string(today, "99.99.9999":U), 1).
  run bgelib-tag-put( 3, "ExportTime", string(time, "hh:mm:ss":U), 1).
  run bgelib-tag-put( 3, "objList",             p-obj-list                    , 1).
  find first buf_db where buf_db.db-num = g#db-num no-lock.
  run bgelib-tag-put( 3, "dbEncKey",            buf_db.db-key-enc, 1).
  run bgelib-tag-close( 2, "Header" ).
end.
output stream stmXMLOut close.
end.
end procedure.
procedure xml-cd-write-footer:
do
on error undo, return error
:
define input parameter p-pos-type      like ub.cash-desk.pos-type no-undo .
define input parameter p-xml-file-name as character    no-undo.
define input parameter p-doc-name      as character    no-undo .
define variable v-error-num     as integer           no-undo.
define variable v-md5-signature as character no-undo .
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run bgelib-tag-close( 0, p-doc-name ).
put stream stmXMLOut unformatted skip.
output stream stmXMLOut close.
run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
if v-error-num > 0
then do:
   return error.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-cd-filename :
do
on error undo, return error
:
define input parameter  p-out               as character no-undo .
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-xml-file-name-path   as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-out as character     no-undo.
define variable loc#log as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable v-remote as character no-undo .
assign
p-xml-file-name = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
p-xml-file-name-path = p-out + p-xml-file-name + ".":U
p-log-file-name = p-out + "actions.log"
p-locked = ( search ( p-xml-file-name-path + "lk" ) <> ? )
.
end.
end procedure.
FUNCTION Xml-CD-DatetoString returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
FUNCTION Xml-CD-DateTimetoString returns character (input  p-date as date, p-time as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U) + chr(32) +
             string(p-time, "HH:MM:SS").
return v-date-str.
END FUNCTION.
function string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 4, 2))
                ,integer(substring(p-string, 1, 2))
                ,integer(substring(p-string, 7, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION string-IS0-8601-to-sec returns integer (input p-string-iso-8601 as character ):
define variable v-time as integer no-undo init ?.
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
assign
v-dop1 = entry(1, p-string-iso-8601, chr(32) )
v-dop2 = entry(2, p-string-iso-8601, chr(32) )
no-error .
if error-status:error then return ?.
assign
v-time =  integer(entry(1, v-dop2, ";":U)) * 3600 +
          integer(entry(2, v-dop2, ";":U)) * 60 +
          integer(entry(3, v-dop2, ";":U)) no-error .
return v-time.
END FUNCTION.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-ivs-ibs no-undo
field chtype as character
field cstype as character
field cancelcode as character
field modificator as LOGICAL
field modificator-np as LOGICAL
field positive-num-chk as logical
field rcpt-type-1 as character
field wro-code as character
field create-return-write-off as logical
field return-line as logical
field qnty-sign as integer
field step_ as integer
field positive-netto-sum as logical
field main-record as logical
field rcpt-type-2 as character
index pi is primary
chtype
cstype
cancelcode
modificator
rcpt-type-1
rcpt-type-2
index chk-doc
chtype
positive-num-chk
positive-netto-sum
main-record
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-ivs-ibs-line no-undo
field line-num as integer
field chtype as character
field cstype as character
field cancelcode as character
field modificator as LOGICAL
field modificator-np as LOGICAL
field positive-num-chk as logical
field rcpt-type-1 as character
field wro-code as character  extent 2
field create-return-write-off as logical
field return-line as logical
field qnty-sign as integer  extent 2
field step_ as integer  extent 2
field positive-netto-sum as logical
field main-record as logical
field rcpt-type-2 as character
index pi is primary
chtype
cstype
cancelcode
modificator
rcpt-type-1
rcpt-type-2
index chk-doc
chtype
positive-num-chk
positive-netto-sum
main-record
.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-ivs-ibsproc no-undo
field chtype as character
field cstype as character
field cancelcode as character
field modificator as LOGICAL
field modificator-np as LOGICAL
field positive-num-chk as logical
field rcpt-type-1 as character
field wro-code as character
field create-return-write-off as logical
field return-line as logical
field qnty-sign as integer
field step_ as integer
field positive-netto-sum as logical
field main-record as logical
field rcpt-type-2 as character
index pi is primary
chtype
cstype
cancelcode
modificator
rcpt-type-1
rcpt-type-2
index chk-doc
chtype
positive-num-chk
positive-netto-sum
main-record
.
procedure create-temp-ivs-ibs-line :
define input parameter ret-item as character no-undo .
define input parameter wro-item as character no-undo .
define input parameter ret-chk as character no-undo .
define input parameter wro-chk as character no-undo .
define input parameter ret-ord as character no-undo .
define input parameter wro-ord as character no-undo .
define variable ii as integer no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_temp-ivs-ibs for temp-ivs-ibs.
define buffer buf2_temp-ivs-ibs for temp-ivs-ibs.
  do
  on error undo, return error return-value
  :
run gbl/filename.p (
                input 'cmp/ivs-ibs.d'
               ,output v-full-path
               ,output v-path
               ,output v-file-name
               ,output v-file-name-no-ext
               ,output v-file-name-ext
               ) no-error .
    input from value(v-full-path).
    repeat:
      create buf_temp-ivs-ibs.
      import buf_temp-ivs-ibs.
    END.
    input close.
    _n:
    for each buf_temp-ivs-ibs:
      if buf_temp-ivs-ibs.chtype = '':U then do:
        delete buf_temp-ivs-ibs.
        next _n.
      end.
      assign
      buf_temp-ivs-ibs.rcpt-type-1 = replace(buf_temp-ivs-ibs.rcpt-type-1, 'rcpt-sale', '1':U)
      buf_temp-ivs-ibs.rcpt-type-2 = replace(buf_temp-ivs-ibs.rcpt-type-2, 'rcpt-sale', '1':U)
      buf_temp-ivs-ibs.rcpt-type-1 = replace(buf_temp-ivs-ibs.rcpt-type-1, 'rcpt-return-write-off', '96':U)
      buf_temp-ivs-ibs.rcpt-type-2 = replace(buf_temp-ivs-ibs.rcpt-type-2, 'rcpt-return-write-off', '96':U)
      buf_temp-ivs-ibs.rcpt-type-1 = replace(buf_temp-ivs-ibs.rcpt-type-1, 'rcpt-return', '6':U)
      buf_temp-ivs-ibs.rcpt-type-2 = replace(buf_temp-ivs-ibs.rcpt-type-2, 'rcpt-return', '6':U)
      buf_temp-ivs-ibs.rcpt-type-1 = replace(buf_temp-ivs-ibs.rcpt-type-1, 'rcpt-write-off', '69':U)
      buf_temp-ivs-ibs.rcpt-type-2 = replace(buf_temp-ivs-ibs.rcpt-type-2, 'rcpt-write-off', '69':U)
      buf_temp-ivs-ibs.rcpt-type-1 = replace(buf_temp-ivs-ibs.rcpt-type-1, 'rcpt-annu', '8':U)
      buf_temp-ivs-ibs.rcpt-type-2 = replace(buf_temp-ivs-ibs.rcpt-type-2, 'rcpt-annu', '8':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-without-payment', '1':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-without-payment', '1':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-r-modificator-wp', '3':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-r-modificator-wp', '3':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-r-modificator', '2':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-r-modificator', '2':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-cancell-item', '-6':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-cancell-item', '-6':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-cancell-all', '-9':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-cancell-all', '-9':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator-ci', '-3':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator-ci', '-3':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator-ca', '-4':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator-ca', '-4':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator', '-2':U)
      buf_temp-ivs-ibs.wro-code = replace(buf_temp-ivs-ibs.wro-code, 'wro-v-modificator', '-2':U)
      .
      if buf_temp-ivs-ibs.cancelcode = 'ret-item':U then do:
        do ii = 1 to num-entries(ret-item, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, ret-item, ';':U)).
        end.
         delete buf_temp-ivs-ibs.
         next _n.
      end.
      if buf_temp-ivs-ibs.cancelcode = 'wro-item':U then do:
        do ii = 1 to num-entries(wro-item, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, wro-item, ';':U)).
        end.
        delete buf_temp-ivs-ibs.
        next _n.
      end.
      if buf_temp-ivs-ibs.cancelcode = 'ret-chk':U then do:
        do ii = 1 to num-entries(ret-chk, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, ret-chk, ';':U)).
        end.
        delete buf_temp-ivs-ibs.
        next _n.
      end.
      if buf_temp-ivs-ibs.cancelcode = 'wro-chk':U then do:
        do ii = 1 to num-entries(wro-chk, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, wro-chk, ';':U)).
        end.
        delete buf_temp-ivs-ibs.
        next _n.
      end.
      if buf_temp-ivs-ibs.cancelcode = 'ret-ord':U then do:
        do ii = 1 to num-entries(ret-ord, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, ret-ord, ';':U)).
        end.
        delete buf_temp-ivs-ibs.
        next _n.
      end.
      if buf_temp-ivs-ibs.cancelcode = 'wro-ord':U then do:
        do ii = 1 to num-entries(wro-ord, ';'):
          create
          buf2_temp-ivs-ibs.
          buffer-copy buf_temp-ivs-ibs to
          buf2_temp-ivs-ibs
          assign
          buf2_temp-ivs-ibs.cancelcode = entry(1, entry(ii, wro-ord, ';':U)).
        end.
         delete buf_temp-ivs-ibs.
         next _n.
      end.
      end.
    end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
DEFINE VARIABLE n-entry                    as   char no-undo extent 20.
DEFINE VARIABLE accept-types               as   character no-undo .
define variable v-flag-salesman            as   logical   no-undo .
define variable v-flag-card              as   logical   no-undo .
define variable cstype_                    as   integer   no-undo .
define variable v-start-check as integer no-undo .
define variable v-record-name as character no-undo .
define variable v-last-date as date no-undo .
define variable v-last-time as integer no-undo .
define variable v-last-shift-num as integer no-undo .
define variable v-last-z-count as integer no-undo .
define variable v-last-chk-num as integer no-undo .
define variable v-exit-processing as logical no-undo .
define variable v-create-return-write-off as logical no-undo .
define variable v-write-off-code-2 as integer   no-undo .
define variable v-is-without-payment as logical no-undo .
define variable v-chk-type as integer no-undo extent 2.
define variable v-to-delete as logical no-undo extent 2.
define variable ret-chk as character no-undo .
define variable kriv3 as logical no-undo .
define variable p-second-mode as character no-undo .
define variable v-is-petrol-check          as logical no-undo .
define variable autotank-pay-list as character no-undo .
define variable autotank-sum-return as decimal no-undo .
define variable v-doc-code like ub.chk-doc.doc-code no-undo .
define variable spool-date_ as date no-undo .
define variable spool-time_ as integer no-undo .
define variable v-eff-date as date no-undo .
define variable v-eff-time as integer no-undo .
define variable v-oss-code as character no-undo init "".
define variable price-old as decimal no-undo .
define variable disc-d-card as character no-undo.
define variable ibm-ccm as integer no-undo.
define variable seasonDT as integer no-undo.
define buffer buf_ext-classif for ub.ext-classif.
define temp-table temp-cash-desk no-undo
    field last-date like ub.chk-doc.chk-date
    field last-time like ub.chk-doc.chk-time
    field last-shift-num like ub.chk-doc.shift-num
    field last-z-count like ub.chk-doc.z-number
    field last-chk-num like ub.chk-doc.chk-num
    field cash-num like ub.cash-desk.cash-num
    index pi is unique primary
    cash-num.
define temp-table achd no-undo
    field num as integer
    field chk-date as date
    field chk-time as integer
    field obj-type as character
    field obj-code as integer
    field pay-desk as integer
    field src-code as character
    field pump as integer
    field nozzle-code as integer
    field src-qnty as decimal
    field trans-num as integer
    index pi is unique primary
    num.
define temp-table ache no-undo
    field chk-date as date
    field chk-time as integer
    field total-exp as decimal
    field month-exp as decimal
    field day-exp as decimal
    field src-code as character
    index pi is unique primary
    src-code
    .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile: cd-xmlg.i $ $Revision: de2ec29bf3dd, 3632, test $".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-temp no-undo
field id as character
field ctime as integer
field cr as integer
field record-name as character
field field-name as character
field field-value as character
index iid id ctime
index ifile record-name field-name
index icr is unique primary cr
.
define temp-table temp-temp-attr no-undo
field id as character
field cr  as integer
field cra as integer
field record-name as character
field field-name as character
field attr-name as character
field attr-value as character
index iid id
index icr is unique primary cr cra
.
define temp-table temp-param no-undo
field desk as integer
field cr as integer
field group-name as character
field record-name as character
field key-name as character
field attr-value as character
field field-name as character
field field-value as character
index ifile record-name field-name key-name group-name
index icr is unique primary cr
.
define variable v-mail-parameters-start     as logical        no-undo.
define variable v-date-format as character no-undo .
define variable v-version as character no-undo .
define variable v-pos-version as character no-undo .
define variable v-from as character no-undo .
define variable v-is-spool-file as logical no-undo .
define variable v-start-err as integer no-undo .
define variable v-num-errors as integer no-undo .
define variable v-dec-sep as character no-undo init ".":U.
define variable v-encoding as character no-undo .
define variable v-db-key-enc as character no-undo .
define variable cri as integer no-undo .
define variable crai as integer no-undo .
define variable v-id as character no-undo .
define variable m-head-db-num   as integer no-undo.
define variable m-head-obj-code as integer no-undo.
define variable m-head-pos-type as character no-undo.
define variable m-head-cash-num as integer no-undo.
define variable v-ctrl as character no-undo .
define variable v-time as integer no-undo .
define variable v-time-char as character no-undo .
define variable v-cd-fatal-error as logical no-undo .
define variable v-cd-fatal-message as character no-undo .
define variable v-errorSeverity as integer no-undo .
define variable v-errormessage as character no-undo .
define variable v-errornum as character no-undo .
define variable v-group as character no-undo .
define variable v-key as character no-undo .
define variable ErrorMessage as character no-undo.
define variable mOk as logical no-undo.
define variable mtagbeg as int64  no-undo.
define variable mtagend as int64 no-undo.
procedure get-xml-ibm-c-buff-or-file.
   define input parameter p-Type as character  no-undo.
   define input parameter p-str  as longchar   no-undo.
   define variable hParser as handle no-undo.
   mtagbeg = 0.
   mtagend = 0.
run get-ibm-parameters in this-procedure no-error.
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке данных от кассы произошла ошибка при получении значений настроечных параметров: &1"
                          , return-value
                        )
                                        ).
  undo, return .
end.
   create sax-reader hParser.
   if p-Type eq "file"
   then
      hParser:set-input-source(p-Type, string(p-str)).
   else do:
      if p-Type = "longchar"
      then do:
         define variable vmemptr as memptr no-undo.
         copy-lob p-str to vmemptr.
         hParser:set-input-source("memptr", vmemptr).
      end.
      else
         hParser:set-input-source(p-Type, p-str).
   end.
   hParser:sax-parse () no-error.
   if error-status:error then do:
      delete object hParser.
      if error-status:num-messages > 0
      then do:
          run write-log-and-file in p-log-handle (
           input 1
         , input log-file-name
         , input 1
         , input substitute( "!!!При  произошла ошибка при получении полного пути файлу: &1 &2"
                             , ErrorMessage
                             , return-value
                           )
                                     ).
          return error error-status:get-message(1).
      end.
      else do:
           return error return-value.
      end.
   end.
   delete object hParser.
   if ErrorMessage <> ""
   then do:
      run write-log-and-file in p-log-handle (
           input 1
         , input log-file-name
         , input 1
         , input substitute( "!!!При  произошла ошибка при получении полного пути файлу: &1 "
                             , ErrorMessage
                           )
                                     ).
      return error ErrorMessage .
   end.
DO TRANSACTION:
  run proc-end in this-procedure no-error .
END.
assign
error-status:error = false.
define buffer buf_cash-desk for ub.cash-desk.
for each temp-cash-desk:
  find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = g#db-num
        AND buf_cash-desk.obj-code = p-obj-code
        AND buf_cash-desk.pos-type = p-pos-type
        AND buf_cash-desk.cash-num = temp-cash-desk.cash-num no-error .
  if available buf_cash-desk then do:
    run cd-attr-write in this-procedure (
                                          input g#db-num
                                         ,input p-obj-code
                                        ,input p-pos-type
                                        ,input temp-cash-desk.cash-num
                                        ,input (if buf_cash-desk.pos-type = 'IBM-XML':U
                                                then 'IBM-XML_operative':U
                                                else if  buf_cash-desk.pos-type = 'Autotank':U
                                                then 'AUTOTANK_operative':U
                                                else 'MAGIA-XML_operative':U)
                                        ,input (if buf_cash-desk.pos-type = 'IBM-XML':U
                                                then 'last-check-params':U
                                                else if  buf_cash-desk.pos-type = 'Autotank':U
                                                then 'last-check-params':U
                                                else 'last-check-date-time':U
                                               )
                                        ,input (cd-attr-CD-DatetoString (temp-cash-desk.last-date) + chr(32)  +  string(temp-cash-desk.last-time, "HH:MM:SS":U)
                                             +  (if buf_cash-desk.pos-type = 'IBM-XML':U
                                                 or buf_cash-desk.pos-type = 'Autotank':U
                                               then (chr(32) + string(temp-cash-desk.last-shift-num) +
                                                      chr(32) + string(temp-cash-desk.last-z-count) +
                                                      chr(32) + string(temp-cash-desk.last-chk-num))
                                               else  "":U)
                                               )
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input no
                                        ) no-error.
  end.
end.
end.
procedure StartDocument:
end procedure.
procedure StartElement:
   define input parameter namespaceURI as character.
   define input parameter localName    as character.
   define input parameter qname        as character.
   define input parameter ihAttributes as handle.
   define variable v-attr-num    as integer   no-undo.
   define variable v-temp-string as character no-undo.
   do v-attr-num = 1 to ihAttributes:num-items:
      v-temp-string = substitute ('&1 &2="&3"',
                                  v-temp-string,
                                  ihAttributes:get-qname-by-index(v-attr-num),
                                  ihAttributes:get-value-by-index(v-attr-num)).
   end.
   v-temp-string = trim(v-temp-string).
     mtagbeg =  mtagbeg + 1.
    run run-callback-procedure in this-procedure (
                      input this-procedure:handle
                    , input "call-all":U
                    , input "tag-start"
                    , input qname
                    , input v-temp-string
                ).
end procedure.
define variable mcurrentContent as character no-undo.
procedure Characters:
    define input parameter charData as memptr.
    define input parameter numChars as integer.
    define variable mcurrentContent as character no-undo.
    mcurrentContent = get-string(charData, 1, get-size(charData)).
    run run-callback-procedure in this-procedure (
                      input this-procedure:handle
                    , input "call-all":U
                    , input "text"
                    , input ""
                    , input mcurrentContent
                ).
end procedure.
procedure EndElement:
define input parameter name_     as character.
define input parameter localName as character.
define input parameter qName     as character.
    if qname = "ErrorMessage" then do:
      ErrorMessage = mcurrentContent.
      self:stop-parsing ().
    end.
    mtagend = mtagend + 1.
    if mtagend mod 100 = 0 or qName eq "check"
    then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Прочитано открытых тегов &1 из них закрытых &2", mtagbeg, mtagend)).
    end.
    run run-callback-procedure in this-procedure (
                      input this-procedure:handle
                    , input "call-all":U
                    , input "tag-end"
                    , input qname
                    , input ""
                ).
end procedure.
procedure EndDocument:
    run hide-counter in p-log-handle .
    mOk = true.
end procedure.
procedure Warning:
    define input parameter ErrMessage as character no-undo.
    message "The following WARNING was generated:~n" + ErrMessage
        view-as alert-box information buttons ok.
end procedure.
procedure Error:
    define input parameter ErrMessage as character no-undo.
    mOk = false.
    message "The following NONFATAL ERROR was generated:~n" + ErrMessage
        view-as alert-box information buttons ok.
end procedure.
procedure FatalError:
    define input parameter ErrMessage as character no-undo.
    mOk = false.
    return error "The following FATAL ERROR was generated:~n" + ErrMessage.
end procedure.
PROCEDURE get-xml-ibm-c.
define input parameter p-filename as char no-undo.
define variable v-new-filename-full     as character         no-undo.
define variable v-xml-buffer as character no-undo.
define variable v-my-string as character no-undo .
define variable v-read-char as character no-undo .
define buffer buf_cash-desk for ub.cash-desk.
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
                          , p-filename
                          , return-value
                        )
                                        ).
  undo, return .
end.
error-status:error = FALSE.
run gbl/fileapnd.p
  ( input p-filename
   ,input ""
   ,input 5
  ) no-error .
if error-status:error then do:
   run write-log-and-file in p-log-handle (
       input 1
     , input log-file-name
     , input 1
     , input return-value
     ).
   assign
      p-view-log = yes
      .
   undo, return.
end.
if p-encoding = "utf-8":U  then  do:
  input stream ChkStream from value( p-filename ) convert source "utf-8".
end.
else do:
  input stream ChkStream from value( p-filename ) .
end.
_repeat:
REPEAT :
  if v-exit-processing then leave _repeat.
  _line:
  DO TRANSACTION:
    import stream Chkstream unformatted  v-xml-buffer  .
    if v-xml-buffer = "":U then do:
      NEXT _repeat.
    end.
    assign
    var-file-line-num = var-file-line-num + 1
    .
    if left-trim(v-xml-buffer)  begins "<?xml":U then do:
      assign
      v-encoding = cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input "xml":U
                             ,input trim(v-xml-buffer, "?>")
                             ,input "encoding":U
                             ,input yes)
     .
     if v-encoding <> p-encoding
     then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка чтения файла &1: кодировка НЕ &2"
                                , p-filename
                                , p-encoding
                              )
                                            ).
      assign
      p-view-log = yes
      .
      undo, return .
     end.
    end.
    run xmlvalid in this-procedure (
          input this-procedure:handle
        , input v-xml-buffer
        , input 'fatal':u
    ) no-error .
    if error-status:error  then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка импорта файла &1: &2"
                                , p-filename
                                , return-value
                              )
                                            ).
      assign
      p-view-log = yes
      .
      undo, return .
    end.
    if v-cd-fatal-error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Файл &1 строка &2 фатальные ошибки: &3 - импорт прекращен"
                              , p-filename
                              , var-file-line-num
                              , v-cd-fatal-message
                            )
                                          ).
      assign
      p-view-log = yes
      .
      undo, return.
    end.
    if var-file-line-num modulo 100 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Файл &1: прочитано строк &2", p-filename, var-file-line-num)).
    end.
  END .
end.
DO TRANSACTION:
  run proc-end in this-procedure no-error .
END.
assign
error-status:error = false.
input stream ChkStream close.
for each temp-cash-desk:
  find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = g#db-num
        AND buf_cash-desk.obj-code = p-obj-code
        AND buf_cash-desk.pos-type = p-pos-type
        AND buf_cash-desk.cash-num = temp-cash-desk.cash-num no-error .
  if available buf_cash-desk then do:
  run cd-attr-write in this-procedure (
                                          input g#db-num
                                         ,input p-obj-code
                                        ,input p-pos-type
                                        ,input temp-cash-desk.cash-num
                                        ,input (if buf_cash-desk.pos-type = 'IBM-XML':U
                                                then 'IBM-XML_operative':U
                                                else if  buf_cash-desk.pos-type = 'Autotank':U
                                                then 'AUTOTANK_operative':U
                                                else 'MAGIA-XML_operative':U)
                                        ,input (if buf_cash-desk.pos-type = 'IBM-XML':U
                                                then 'last-check-params':U
                                                else if  buf_cash-desk.pos-type = 'Autotank':U
                                                then 'last-check-params':U
                                                else 'last-check-date-time':U
                                               )
                                        ,input (cd-attr-CD-DatetoString (temp-cash-desk.last-date) + chr(32)  +  string(temp-cash-desk.last-time, "HH:MM:SS":U)
                                             +  (if buf_cash-desk.pos-type = 'IBM-XML':U
                                                 or buf_cash-desk.pos-type = 'Autotank':U
                                               then (chr(32) + string(temp-cash-desk.last-shift-num) +
                                                      chr(32) + string(temp-cash-desk.last-z-count) +
                                                      chr(32) + string(temp-cash-desk.last-chk-num))
                                               else  "":U)
                                               )
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input no
                                        ) no-error.
end.
end.
END PROCEDURE.
procedure cb-xmlparse-tag-start-Header :
do
on error undo, return error
:
  assign
      v-mail-parameters-start = yes
  .
end.
end procedure.
procedure cb-xmlparse-tag-end-Header :
do
on error undo, return error
:
  assign
      v-mail-parameters-start = no
  .
end.
end procedure.
procedure cb-xmlparse-tag-start-spool :
define input parameter p-parameter as character no-undo .
define variable v-file-type as character no-undo .
define variable v-adresat as character no-undo .
define variable v-FO-version as character no-undo .
define variable v-OptVersion as character no-undo .
define variable v-OptVersion1 as character no-undo .
define variable v-OptVersion2 as character no-undo .
define variable v-OptVersion3 as character no-undo .
define variable v-OptVersion4 as character no-undo .
define variable v-OptVer      as character no-undo .
define variable v-old-fo-version as character no-undo .
define variable v-pay-desk as integer no-undo .
define variable v-dop as character no-undo .
define buffer cash-desk for ub.cash-desk.
define variable v-date as date no-undo .
define variable v-decimal as decimal no-undo .
define variable v-integer as integer no-undo .
define variable v-logical as logical no-undo .
define variable v-err-message as character no-undo .
do
on error undo, return error
:
  if v-is-spool-file = no then do:
    IF INDEX(p-parameter,"OptVersion") > 0 THEN v-OptVer = 'OptVer'.
    assign
    v-file-type = cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "type":U
                             ,input yes)
    v-adresat =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "to":U
                             ,input no)
    v-pos-version =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "version":U
                             ,input no)
    v-FO-version =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "release":U
                             ,input no)
    v-from =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "from":U
                             ,input no)
    v-OptVersion =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "OptVersion":U
                             ,input no)
    v-OptVersion1 =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "OptVersion1":U
                             ,input no)
    v-OptVersion2 =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "OptVersion2":U
                             ,input no)
    v-OptVersion3 =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "OptVersion3":U
                             ,input no)
    v-OptVersion4 =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "OptVersion4":U
                             ,input no)
    .
    if v-file-type = "REPLY":U AND
    (v-adresat begins ('маг':U + string(p-obj-code))
    )
    then do:
      assign
      v-is-spool-file = yes
      .
      if v-from begins ('маг':U + string(p-obj-code) + "_" + "касса") then do:
        v-pay-desk = ?.
        v-pay-desk = integer(replace(v-from, ('маг':U + string(p-obj-code) + "_" + "касса"), "")) no-error.
        assign
           m-head-db-num    = ?
           m-head-obj-code  = ?
           m-head-pos-type  = ?
           m-head-cash-num  = ?
        .
        find first cash-desk where
                         cash-desk.db-num = g#db-num
                     and cash-desk.obj-code = p-obj-code
                     and cash-desk.cash-num = v-pay-desk
        no-lock no-error.
        if available cash-desk
        then do transaction :
           assign
              m-head-db-num    = cash-desk.db-num
              m-head-obj-code  = cash-desk.obj-code
              m-head-pos-type  = cash-desk.pos-type
              m-head-cash-num  = cash-desk.cash-num
           .
          if p-pos-type = 'IBM-XML':U then
          do:
            run cd-attr-write in this-procedure (
              input cash-desk.db-num
              ,input cash-desk.obj-code
              ,input cash-desk.pos-type
              ,input cash-desk.cash-num
              ,input  (if p-pos-type = 'IBM-XML':U
              then 'IBM-XML_operative':U
              else 'AUTOTANK_operative':U)
              ,input 'last-date-polls':U
              ,input string (today,"99.99.9999")
              ,input ?
              ,input 0
              ,input 0
              ,input no
              ) .
            run cd-attr-write in this-procedure (
              input cash-desk.db-num
              ,input cash-desk.obj-code
              ,input cash-desk.pos-type
              ,input cash-desk.cash-num
              ,input  (if p-pos-type = 'IBM-XML':U
              then 'IBM-XML_operative':U
              else 'AUTOTANK_operative':U)
              ,input 'last-time-polls':U
              ,input string (time,"HH:MM:SS")
              ,input ?
              ,input 0
              ,input 0
              ,input no
              ) .
          end.
          IF v-OptVer = 'OptVer' THEN DO:
            v-OptVer = "".
            IF v-OptVersion  <> ? THEN v-OptVer = TRIM(v-OptVersion," ").
            IF v-OptVersion1 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion1," ")) .
            IF v-OptVersion2 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion2," ")) .
            IF v-OptVersion3 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion3," ")) .
            IF v-OptVersion4 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion4," ")) .
            v-OptVer = TRIM(v-OptVer,",").
                IF v-OptVer = "" THEN v-OptVer = "?" .
                    run cd-attr-write in this-procedure (
                                                   input cash-desk.db-num
                                                  ,input cash-desk.obj-code
                                                  ,input cash-desk.pos-type
                                                  ,input cash-desk.cash-num
                                                  ,input  (if cash-desk.pos-type = 'IBM-XML':U
                                                           then 'IBM-XML_operative':U
                                                           else 'AUTOTANK_operative':U)
                                                  ,input  (if cash-desk.pos-type = 'IBM-XML':U
                                                       then 'OptVer':U
                                                       else 'OptVer':U)
                                                  ,input v-OptVer
                                                  ,input no
                                                  ,input no
                                                  ,input no
                                                  ,input no
                                                  ) no-error.
               v-OptVer = '' .
           END.
          if error-status:error then do :
              v-err-message = return-value .
              run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input v-err-message
                                          ).
              p-view-log = yes .
            end .
           run cd-attr-value in this-procedure (
                                               input cash-desk.db-num
                                              ,input cash-desk.obj-code
                                              ,input cash-desk.pos-type
                                              ,input cash-desk.cash-num
                                              ,input  (if cash-desk.pos-type = 'IBM-XML':U
                                                      then 'IBM-XML_operative':U
                                                      else 'AUTOTANK_operative':U)
                                              ,input  (if cash-desk.pos-type = 'IBM-XML':U
                                                       then 'fo-version':U
                                                       else 'fo-version':U)
                                              ,output v-old-fo-version
                                              ,output v-date
                                              ,output v-decimal
                                              ,output v-integer
                                              ,output v-logical
                                              ,output v-dop) no-error.
           if     v-old-fo-version <> v-fo-version
              and v-FO-version <> ?
           then do:
              run cd-attr-write in this-procedure (
                                                   input cash-desk.db-num
                                                  ,input cash-desk.obj-code
                                                  ,input cash-desk.pos-type
                                                  ,input cash-desk.cash-num
                                                  ,input  (if cash-desk.pos-type = 'IBM-XML':U
                                                           then 'IBM-XML_operative':U
                                                           else 'AUTOTANK_operative':U)
                                                  ,input (if cash-desk.pos-type = 'IBM-XML':U
                                                          then 'fo-version':U
                                                          else 'fo-version':U)
                                                  ,input v-fo-version
                                                  ,input ?
                                                  ,input 0
                                                  ,input 0
                                                  ,input no
                                                  ) no-error.
            if error-status:error then do :
              v-err-message = return-value .
              run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input v-err-message
                                          ).
              p-view-log = yes .
            end .
          end.
        end.
      end.
    end.
    else do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!В директории приема файлов обнаружен файл с неизвестным адресатом: &1 и/или неизвестного типа: &2"
                              , v-adresat
                              , v-file-type
                            )
                                          ).
      assign
      p-view-log = yes
      v-exit-processing = yes
      .
    end.
  end.
  else do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Нарушение протокола обмена : тэг <&1>", p-spool-or-data
                            )
                                          ).
      assign
      p-view-log = yes
      .
  end.
end.
end procedure.
procedure cb-xmlparse-tag-start-config :
define input parameter p-parameter as character no-undo .
  run cb-xmlparse-tag-start-spool in this-procedure ( input p-parameter) no-error.
  if error-status:error then return error return-value .
end procedure.
procedure cb-xmlparse-tag-start-control :
define input parameter p-parameter as character no-undo .
  run cb-xmlparse-tag-start-spool in this-procedure ( input p-parameter) no-error.
  if error-status:error then return error return-value .
end procedure.
procedure cb-xmlparse-tag-end-spool :
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
  assign
  v-is-spool-file = no
  .
  end.
end procedure.
procedure cb-xmlparse-tag-end-config :
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-end-spool  in this-procedure ( input p-parameter) no-error.
if error-status:error then return error return-value .
end procedure.
procedure cb-xmlparse-tag-end-control :
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-end-spool  in this-procedure ( input p-parameter) no-error.
if error-status:error then return error return-value .
end procedure.
procedure cb-xmlparse-tag-start-data :
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
  if v-is-spool-file = yes then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Нарушение протокола обмена : тэг <&1>",
 "data":U
                           )
                                          ).
      assign
      p-view-log = yes
      .
  end.
  else do:
    assign
    v-exit-processing = yes
    .
  end.
end.
end procedure.
procedure cb-xmlparse-tag-end-data :
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
end.
end procedure.
procedure cb-xmlparse-tag-start-error:
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-start-err in this-procedure ( input p-parameter)  .
end procedure .
procedure cb-xmlparse-tag-end-error :
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-end-err in this-procedure ( input p-parameter)  .
end procedure .
procedure cb-xmlparse-tag-end-ErrorMessage :
define input parameter p-parameter as character no-undo .
assign
v-ErrorMessage = v-xmlvalid-tag-value
.
if p-pos-type = 'IBM-XML':U
or p-pos-type = 'Autotank':U
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!&1"
                            ,v-ErrorMessage
                          )
                                        ).
    assign
    p-view-log = yes
    .
end.
end procedure .
procedure cb-xmlparse-tag-end-ErrorSeverity :
define input parameter p-parameter as character no-undo .
assign
v-Errorseverity = integer(v-xmlvalid-tag-value)
no-error
.
if p-pos-type = 'IBM-XML':U
or p-pos-type = 'Autotank':U
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!&1"
                          , (if v-errorseverity = 0
                              then "Информация"
                              else (if v-Errorseverity = 1
                                    then "Предупреждение"
                                    else "Ошибка"
                                    )
                              ))
                              ).
    assign
    p-view-log = yes
    .
end.
end procedure .
procedure cb-xmlparse-tag-start-err:
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
  if v-is-spool-file
  then do:
    assign
    v-start-err = v-start-err + 1
    v-num-errors = v-num-errors + 1
    v-errormessage = '':U
    v-errorseverity = 0
    v-errornum = '':U
    .
    if p-pos-type = 'MAGIA-XML':U then do:
      assign
      v-ErrorMessage = cb-xmlparse-get-attr(
                                input this-procedure:handle
                              ,input p-spool-or-data
                              ,input p-parameter
                              ,input "ErrorMessage":U
                              ,input yes)
      v-ErrorNum =  cb-xmlparse-get-attr(
                                input this-procedure:handle
                              ,input p-spool-or-data
                              ,input p-parameter
                              ,input "Error":U
                              ,input no)
      v-ErrorSeverity =  integer(cb-xmlparse-get-attr(
                                input this-procedure:handle
                              ,input p-spool-or-data
                              ,input p-parameter
                              ,input "ErrorSeverity":U
                              ,input no))
      no-error
      .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!&1: &2 &3                   Код &4"
                              , (if v-errorseverity = 0
                                then "Информация"
                                else (if v-Errorseverity = 1
                                      then "Предупреждение"
                                      else "Ошибка"
                                      )
                                )
                              , v-ErrorMessage
                              , chr(10)
                              , v-ErrorNum
                            )
                                          ).
      assign
      p-view-log = yes
      .
    end.
  end.
  else do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Нарушение протокола обмена : тэг Err", p-spool-or-data
                            )
                                          ).
      assign
      p-view-log = yes
      .
  end.
end.
end procedure.
procedure cb-xmlparse-tag-end-err :
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
  if p-pos-type = 'MAGIA-XML':U then do:
    if v-start-err =  1 then do:
      assign
      v-start-err = 0
      .
    end.
    else do:
      assign
      v-start-err = v-start-err - 1
      .
    end.
  end.
  if p-pos-type = 'IBM-XML':U
  or p-pos-type = 'Autotank':U
  then do:
    assign
    v-errornum = v-xmlvalid-tag-value
    no-error .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!           Код &1"
                            , v-ErrorNum  )
                                        ).
    assign
    p-view-log = yes
    .
  end.
end.
end procedure.
PROCEDURE fill-doc-property :
do
on error undo, return error
:
define input parameter p-tag-name   as character    no-undo.
define input parameter p-tag-value  as character    no-undo.
define buffer buf_db for ub.db.
if v-mail-parameters-start = yes
then do:
  CASE p-tag-name:
    when "DocumentName":U
    then do:
      if p-tag-value = p-spool-or-data then do:
      end.
      else do:
      end.
    end.
    when "DateFormat":U
    then do:
      assign
      v-date-format = p-tag-value
      .
    end.
    when "DocumentVersion":U
    then do:
      assign
      v-version = p-tag-value
      .
    end.
    when "DecimalSeparator":U
    then do:
      assign
      v-dec-sep = p-tag-value
      .
    end.
    when "objList":U then do:
    end.
    when "dbEncKey":U then do:
      assign
      v-db-key-enc = p-tag-value
      .
      find first buf_db where buf_db.db-num = g#db-num no-lock.
      if buf_db.db-key-enc = v-db-key-enc then do:
        return error
        substitute("Кодир. значение ключа БД-приемника &1 совпадает с кодир. значением ключа БД-источника &2&3- импорт данных со своей БД на свою БД невозможен"
                   , buf_Db.db-key-enc
                   , v-db-key-enc
                   , chr(10)).
      end.
    end.
  end case.
end.
end.
end PROCEDURE.
procedure create-temp-table-record :
define input parameter p-record-name as character no-undo .
define input parameter p-field-name as character no-undo .
define input parameter p-field-value as character no-undo .
  do
  on error undo, return error
  :
    if p-record-name = "Param" or p-record-name = "FuelPump" then do:
    find first temp-param where
               temp-param.cr = cri + 1 no-error .
    if not avail temp-param then do:
      create
      temp-param.
      assign
      temp-param.cr = cri + 1
      .
    end.
    assign
    temp-param.record-name = p-record-name
    temp-param.field-name  = p-field-name
    temp-param.field-value = p-field-value
    temp-param.desk        = m-head-cash-num
    temp-param.key-name    = v-key
    temp-param.group-name  = v-group
    cri                   = cri + 1
    .
    end.
    else do:
    find first temp-temp where
               temp-temp.cr = cri + 1 no-error .
    if not avail temp-temp then do:
      create
      temp-temp.
      assign
      temp-temp.cr = cri + 1
      .
    end.
    assign
    temp-temp.record-name = p-record-name
    temp-temp.field-name  = p-field-name
    temp-temp.field-value = p-field-value
    temp-temp.id          = v-id
    temp-temp.ctime       = v-time
    cri                   = cri + 1
    .
    end.
  end.
end procedure.
define TEMP-TABLE tt-chk-doc      LIKE ub.chk-doc.
define TEMP-TABLE tt-chk-doc-attr LIKE ub.chk-doc-attr.
define TEMP-TABLE tt-chk-gds      LIKE ub.chk-gds.
define TEMP-TABLE tt-chk-gds-attr LIKE ub.chk-gds-attr.
define TEMP-TABLE tt-chk-gds-pay  LIKE ub.chk-gds-pay.
define TEMP-TABLE tt-chk-pay      LIKE ub.chk-pay.
define TEMP-TABLE tt-chk-pay-attr LIKE ub.chk-pay-attr.
define TEMP-TABLE tt-bar-code      LIKE ub.bar-code.
define TEMP-TABLE tt-marking-chk   LIKE ub.marking-chk.
define TEMP-TABLE tt-chk-discnt   LIKE ub.chk-discnt.
define TEMP-TABLE tt-chk-discnt-attr LIKE ub.chk-discnt-attr.
define TEMP-TABLE tt-cd-trans LIKE ub.cd-trans.
DEFINE VARIABLE doc-code-txt AS CHARACTER NO-UNDO.
FUNCTION fdecimal returns decimal
    ( input p-str-value as character
        ) :
    define variable v-dec as decimal no-undo .
    CASE v-dec-sep:
        when chr(44) then do:
            assign
                v-dec = decimal(replace(p-str-value, chr(44), ".":U))
                no-error
                .
        end.
        when ".":U then do:
            assign
                v-dec = decimal(p-str-value)
                no-error
                .
        end.
        otherwise  do:
            assign
                v-dec = ?
                .
        end.
    END CASE.
    return v-dec.
END FUNCTION.
FUNCTION convert-pay-code returns integer
    ( input p-pos-type as character
    ,input p-pos-pay-code as integer
    ,output p-curr-code as integer
        ) :
    define variable v-pay-code as integer no-undo .
    define variable v-ii as integer no-undo .
    define variable v-entry as character no-undo .
    define buffer buf_currency for ub.currency.
    define buffer buf_cash-pay for ub.cash-pay.
    case p-pos-type:
        when 'Autotank':U then do:
            do v-ii = 1 to num-entries(autotank-pay-list, ";"):
                v-entry = entry(v-ii, autotank-pay-list, ";").
                if entry(1, entry(1, v-entry, chr(47)), chr(44)) = string(p-pos-pay-code) then do:
                    assign
                        v-pay-code = integer(entry(1, entry(2, v-entry, chr(47)), chr(44)))
                        p-curr-code = integer(entry(2, entry(2, v-entry, chr(47)), chr(44)))
                        .
                    return v-pay-code.
                end.
            end.
            return v-pay-code.
        end.
        when 'MAGIA-XML':U then do:
            if p-pos-pay-code < 1000 then do:
                if p-pos-pay-code = 1 then do:
                    assign
                        p-curr-code = 0
                        .
                    return p-pos-pay-code.
                end.
                find first buf_currency no-lock where
                    buf_currency.okv-code = p-pos-pay-code no-error .
                if not avail buf_currency then do:
                    assign
                        p-curr-code = - 1
                        .
                    return (- 1).
                end.
                assign
                    p-curr-code = buf_currency.curr-code
                    .
                return 1.
            end.
            else do:
                assign
                    v-pay-code = p-pos-pay-code - 10000
                    .
                find buf_cash-pay no-lock where
                    buf_cash-pay.cdpay-code = v-pay-code no-error .
                if not available buf_cash-pay then do:
                    assign
                        p-curr-code = - 1
                        .
                    return (- 1).
                end.
                assign
                    p-curr-code = buf_cash-pay.curr-code
                    .
                return buf_cash-pay.cdpay-code.
            end.
        end.
    end case.
END FUNCTION.
assign
    shop-type = p-obj-type
    shop-code = p-obj-code
    .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
process events.
if p-spool-or-data begins "readbuffer" + chr(4)
then do:
    assign
        p-second-mode = entry(2, p-spool-or-data, chr(4) )
        p-spool-or-data = ""
        .
    output to answerblock.txt .
    export file_ .
    output close .
    RUN get-xml-ibm-c-buff-or-file(input "longchar",input file_) no-error .
    if error-status :error
    then do:
        run write-log-and-file in p-log-handle (
            input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка при обработке ответа &1"
            , return-value
            )
            ).
        assign
            p-view-log = yes
            .
        undo, return .
    end.
end.
else do:
    assign
        p-second-mode   = p-spool-or-data
        p-spool-or-data = ""
        .
    RUN get-xml-ibm-c-buff-or-file(input "file",input file_) no-error .
    if error-status :error
    then do:
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
        undo, return .
    end.
end.
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer locked_cash-desk for ub.cash-desk.
p-second-mode = trim(p-second-mode,chr(4)).
if entry(1, p-second-mode) = "version" then do:
    do transaction:
        run gen-row-keyr in this-procedure
            ( input  replace(p-second-mode, "version,", "")
            ,input ?
            ,input "ub":U
            ,input ?
            ,input share-lock
            ,output v-rowid
            ,output v-tbl-name
            ) no-error .
        find first locked_cash-desk share-lock where
            rowid(locked_cash-desk) = v-rowid.
        if v-from <> substitute('&1&2_касса&3', 'маг':U, locked_cash-desk.obj-code, locked_cash-desk.cash-num) then do:
            run write-log-and-file in p-log-handle (
                input 1
                , input log-file-name
                , input 1
                , input substitute("!!!ОШИБКА! Запрашивалась версия ПО &1&2_касса&3, а получена версия ПО для &4."
                , 'маг':U
                , locked_cash-desk.obj-code
                , locked_cash-desk.cash-num
                , v-from
                )).
            p-view-log = yes .
        end.
        else if locked_cash-desk.version <> v-pos-version then do:
            assign
                locked_cash-desk.version = v-pos-version
                .
            release locked_cash-desk no-error .
            if not error-status:error then do:
                run write-log-and-file in p-log-handle (
                    input 1
                    , input log-file-name
                    , input 1
                    , input substitute("Изменена версия ПО для &1. Версия ПО принимается равной &2."
                    , v-from
                    , v-pos-version
                    )).
            end.
        end.
    end.
end.
PROCEDURE get-ibm-parameters:
    define variable ret-item as character no-undo .
    define variable wro-item as character no-undo .
    define variable wro-chk as character no-undo .
    define variable ret-ord as character no-undo .
    define variable wro-ord as character no-undo .
    define variable ii as integer no-undo .
    define variable v-param-type as character no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    assign
        v-tth = buffer thbjattr_thbj-attr:table-handle .
    define buffer buf_tt-sum-grp for tt-sum-grp.
    if get-chkc_context.shift-on and not get-chkc_context.cas-shft then do:
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
        undo, return .
    end.
    get-chkc_context.ibmgroup = ibmgroup.
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
        undo, return .
    end.
    if get-chkc_context.is-wth = yes then do:
        accept-types =  "1,2,3,4,5,6,7,13,40,43,44":U.
    end.
    else do:
        accept-types =  "1,6,13,40,43,44":U.
    end.
    dflt-cd = p-pos-type.
    get-chkc_context.pos-type = p-pos-type.
    if get-chkc_context.is-ptrl
    and get-chkc_context.ptrl-check then
        assign
            accept-types = accept-types + ",14,15,16,17":U.
    if is-ptrl and ptrl-check
    and (p-pos-type = 'IBM-XML':U or p-pos-type = 'Autotank':U)
    then
        assign
            accept-types = accept-types + ",36":U.
    if p-pos-type = 'MAGIA-XML':U
    or get-chkc_context.annu-check then
        assign
            accept-types = accept-types + ",8":U
            .
    if get-chkc_context.z-check then
        assign
            accept-types = accept-types + ",12":U
            .
    if get-chkc_context.is-cdinv then accept-types = accept-types + ",11":U.
    if p-pos-type = 'MAGIA-XML':U then do:
        for each thbjattr_thbj-attr:
            delete thbjattr_thbj-attr.
        end.
        run adm/shattri.p (
            input "get":U
            ,input  p-obj-type
            ,input  p-obj-code
            ,input  'cd-type-magia-xml':U
            ,input  '':U
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error .
        IF error-status:error then do:
            run write-log-and-file in p-log-handle (
                input 1
                , input log-file-name
                , input 1
                , input  substitute(
                "Не удалось получить настройки для  POS типа &1 для маг&2"
                , 'MAGIA-XML':U
                , p-obj-code)
                ).
            assign
                v-cd-fatal-error = yes
                v-cd-fatal-message = "неверные настройки"
                p-view-log = yes
                .
            return "error".
        end.
        for each thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
                and thbjattr_thbj-attr.obj-code = p-obj-code
                and thbjattr_thbj-attr.upper-prop-code =  'cd-type-magia-xml':U
                on error undo, return error :
            case thbjattr_thbj-attr.prop-code :
                when 'ret-item':U then do:
                    assign
                        ret-item = thbjattr_thbj-attr.property-value-character.
                end.
                when 'wro-item':U then do:
                    assign
                        wro-item = thbjattr_thbj-attr.property-value-character.
                end.
                when 'wro-chk':U then do:
                    assign
                        wro-chk = thbjattr_thbj-attr.property-value-character.
                end.
                when 'ret-chk':U then do:
                    assign
                        ret-chk = thbjattr_thbj-attr.property-value-character.
                end.
                when 'wro-ord':U then do:
                    assign
                        wro-ord = thbjattr_thbj-attr.property-value-character.
                end.
                when 'ret-ord':U then do:
                    assign
                        ret-ord = thbjattr_thbj-attr.property-value-character.
                end.
            end case.
        end.
        run create-temp-ivs-ibs-line in this-procedure (
            input ret-item
            ,input wro-item
            ,input ret-chk
            ,input wro-chk
            ,input ret-ord
            ,input wro-ord ) .
    end.
    if p-pos-type = 'IBM-XML':U then do :
        run adm/shattri.p (
            input "get":U
            ,input  p-obj-type
            ,input  p-obj-code
            ,input  'cd-type-IBM-XML':U
            ,input  'ibm-ccm':U
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error .
        IF not error-status:error then do:
            delete object v-tth.
            ibm-ccm = v-value-integer.
        end.
        else do:
            ibm-ccm = ?.
            delete object v-tth.
            return error return-value .
        end.
    end.
    if (p-pos-type = 'IBM-XML':U or p-pos-type = 'Autotank':U) and get-chkc_context.ibmgroup then do:
        for each buf_tt-sum-grp:
            delete buf_tt-sum-grp.
        end.
        do ii = 1 to num-entries(specgrp, ';'):
            create buf_tt-sum-grp.
            assign
                buf_tt-sum-grp.grp-code = integer(entry(1, entry(ii, specgrp, ';'), '-':U))
                buf_tt-sum-grp.code-2 = integer(entry(2, entry(ii, specgrp, ';'), '-':U))
                no-error
                .
            if error-status:error then do:
                delete buf_tt-sum-grp.
            end.
        end.
    end.
    if p-pos-type = 'Autotank':U then do:
        for each thbjattr_thbj-attr:
            delete thbjattr_thbj-attr.
        end.
        run adm/shattri.p (
            input "get":U
            ,input  p-obj-type
            ,input  p-obj-code
            ,input  'cd-type-autotank':U
            ,input  '':U
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error .
        IF error-status:error then do:
            run write-log-and-file in p-log-handle (
                input 1
                , input log-file-name
                , input 1
                , input  substitute(
                "Не удалось получить настройки для  POS типа &1 для маг&2"
                , 'MAGIA-XML':U
                , p-obj-code)
                ).
            assign
                v-cd-fatal-error = yes
                v-cd-fatal-message = "неверные настройки"
                p-view-log = yes
                .
            return "error".
        end.
        for each thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
                and thbjattr_thbj-attr.obj-code = p-obj-code
                and thbjattr_thbj-attr.upper-prop-code =  'cd-type-autotank':U
                on error undo, return error :
            case thbjattr_thbj-attr.prop-code :
                when 'cash-pay-list':U then do:
                    assign
                        autotank-pay-list = thbjattr_thbj-attr.property-value-character.
                end.
            end case.
        end.
    end.
END PROCEDURE.
procedure proc-00 :
    define variable is-shift-date as logical no-undo .
    define variable prev-code2 like ub.chk-doc.doc-code no-undo .
    define variable netto-sum2_ as decimal no-undo .
    define variable iexist as integer no-undo .
    define variable v-new as character no-undo .
    define variable v-old as character no-undo .
    define variable v-step as integer   no-undo .
    define buffer buf_temp-temp for temp-temp.
    define buffer buf_chk-doc for tt-chk-doc.
    define buffer buf_chk-doc-attr for tt-chk-doc-attr.
    define buffer buf_tt-chk-pay for tt-chk-pay.
    define variable vCHFlag1           as character no-undo.
    define variable vCHNumberKKT       as character no-undo.
    define variable vCHMgrKey          as character no-undo.
    define variable vCHNumberFN        as character no-undo.
    define variable vCHFiscalDocSign   as character no-undo .
    define variable vCHFiscalDocNumber as integer no-undo .
    do
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
            :
        find first buf_temp-temp no-lock where
            buf_temp-temp.record-name = "CHead"
            AND buf_temp-temp.field-name = "CHType"
            AND buf_temp-temp.id = v-id
            no-error .
        if not available buf_temp-temp then do:
            assign
                v-start-check = 0
                .
            return.
        end.
        assign
            prev-gbl-type = ''
            gbl-type = string(integer(buf_temp-temp.field-value))
            no-error .
        if error-status:error then do:
            if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
        end.
        if can-do(accept-types,  gbl-type ) then do:
            assign
                chk-date_ = 01/01/1990
                chk-time_ = 0
                shift-date_ = chk-date_
                shift-num_ = 0
                shift-name_ = ''
                shift-open-time_ = 0
                shop-code = p-obj-code
                shop-type = 'маг':U
                sales-man_ = 0
                cashier_ = 0
                pay-desk_ = 0
                z-num_ = 0
                cash-rate_ = 0
                d-card_ = "":U
                d-mask_ = "":U
                tot-d-pcnt = 0
                doc-num_ = "":U
                doc-num2_ = "":U
                chk-num_ = 0
                netto-sum_ = 0
                AuthType_ = 0
                qr-alchol_ = "":u
                brutto-sum_ = 0
                v-flag-salesman  = no
                v-flag-card = no
                d-mask_ = "":U
                cli-type_ = "":U
                v-oss-code = "":U
                price-old = 0
                cli-code_ = 0
                v-chk-type[1] = 0
                v-chk-type[2] = 0
                v-is-petrol-check = no
                cstCode = ""
                cstValue = 0
                spool-date_ = ?
                spool-time_ = ?
                vCHMgrKey = ""
                vCHNumberKKT = ""
                vCHFlag1    = ""
                no-error
                .
            _buf_temp:
            for each buf_temp-temp no-lock where
                buf_temp-temp.record-name = "CHead":U
                    AND buf_temp-temp.id = v-id:
                CASE buf_temp-temp.field-name:
                    when "CHMode":U then do:
                        assign
                            iexist = int(buf_temp-temp.field-value)
                            no-error .
                        if not error-status:error
                        and (not (iexist = 1
                        or
                        (iexist = 2 and get-chkc_context.annu-check)
                        ))
                        then do:
                            assign
                                exist = yes
                                mc-exist = yes
                                .
                            return .
                        end.
                        if iexist = 2 then do:
                            assign
                                prev-gbl-type = gbl-type
                                gbl-type = '8'.
                        end.
                    end.
                    when "CHNum":U then do:
                        assign
                            chk-num_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CHDate":U then do:
                        assign
                            chk-date_ =  cb-xmlparse-get-date( buf_temp-temp.field-value)
                            chk-time_ =  cb-xmlparse-get-time( buf_temp-temp.field-value)
                            spool-date_ = cb-xmlparse-get-date( v-time-char)
                            spool-time_ = cb-xmlparse-get-time( v-time-char)
                            no-error .
                    end.
                    when "CHShop":U then do:
                        assign
                            shop-code = if get-chkc_context.hnum
                            then int(buf_temp-temp.field-value)
                            else shop-code
                            shop-type = 'маг':U
                            no-error .
                    end.
                    when "CHCashNum":U then do:
                        assign
                            pay-desk_ = int(buf_temp-temp.field-value)
                            no-error
                            .
                    end.
                    when "CHCashier":U then do:
                        assign
                            cashier_ = int(buf_temp-temp.field-value)
                            no-error
                            .
                    end.
                    when "CHZcount":U then do:
                        assign
                            z-num_ = integer(buf_temp-temp.field-value)
                            no-error
                            .
                    end.
                    when "CHSBeg":U then do:
                        assign
                            shift-date_ = cb-xmlparse-get-date(buf_temp-temp.field-value)
                            is-shift-date = yes
                            shift-open-time_ = cb-xmlparse-get-time( buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CHSNum":U then do:
                        assign
                            shift-name_ = buf_temp-temp.field-value
                            shift-num_ = integer(buf_temp-temp.field-value)
                            no-error
                            .
                    end.
                    when "CHRate":U then do:
                        assign
                            cash-rate_ = fdecimal(buf_temp-temp.field-value)
                            no-error
                            .
                    end.
                    when "CHDoc":U then do:
                        run xmlchar-decode in this-procedure (
                            input trim(buf_temp-temp.field-value)
                            , output doc-num_
                            ) no-error.
                    end.
                    when "CHBrutto":U then do:
                        assign
                            brutto-sum_ = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CHNetto":U then do:
                        assign
                            netto-sum_ = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CAuthorization":U then do:
                        CASE buf_temp-temp.field-name:
                            when "CAuthType mes":U then do:
                                assign
                                    AuthType_ = fdecimal(buf_temp-temp.field-value)
                                    no-error .
                            end.
                            when "CAuthUrl mes":U then do:
                                run xmlchar-decode in this-procedure (
                                    input trim(buf_temp-temp.field-value)
                                    , output qr-alchol_
                                    ) no-error.
                            end.
                        end case.
                    end.
                    when "CSClient":U then do:
                        if p-pos-type = 'MAGIA-XML':U then
                            assign
                            cli-code_ = integer(buf_temp-temp.field-value)
                            cli-type_ = if cli-code_ > 9999999999 then 'орг':U else 'чел':U
                                no-error .
                    end.
                    when "CSCCardN":U then do:
                        if p-pos-type = 'MAGIA-XML':U then
                            assign
                            d-card_ = (if buf_temp-temp.field-value = "0" then "":u else buf_temp-temp.field-value)
                                no-error .
                    end.
                    when "CHAgreement":U then do:
                        if p-pos-type = 'IBM-XML':U OR p-pos-type = 'Autotank':U then
                            assign
                            doc-num2_ = (if buf_temp-temp.field-value = "0" then "":u else buf_temp-temp.field-value)
                                no-error .
                    end.
                    when "CHNumberKKT":U then do:
                        vCHNumberKKT = buf_temp-temp.field-value no-error .
                    end.
                    when "CHNumberFN":U then do:
                        vCHNumberFN = buf_temp-temp.field-value no-error .
                    end.
                    when "CHFiscalDocSign":U then do :
                        vCHFiscalDocSign = buf_temp-temp.field-value no-error .
                    end .
                    when "CHFiscalDocNumber":U then do :
                        vCHFiscalDocNumber = integer(buf_temp-temp.field-value) no-error .
                    end .
                    when "CHMgrKey":U then do :
                        vCHMgrKey = buf_temp-temp.field-value no-error .
                    end .
                    when "CHFlag1":U then do:
                        vCHFlag1 = buf_temp-temp.field-value no-error .
                    end.
                    otherwise do:
                        error-status:error = no.
                    end.
                END CASE.
                if error-status:error then do:
                    if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
                end.
            END.
        end.
        else do:
            assign
                exist = yes
                mc-exist = yes
                .
            return.
        end.
        if cas-shft then . else assign
            shift-date_      = chk-date_
            shift-num_       = 0
            shift-open-time_ = 0
            .
        find first ub.cash-desk no-lock where
            ub.cash-desk.cash-num = pay-desk_
            AND ub.cash-desk.obj-code = p-obj-code no-error.
        If not available  ub.cash-desk
        then do:
            assign
                p-view-log = yes
                .
            run write-log-and-file in p-log-handle (
                input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!При обработке файла произошла ошибка. На объекте &1 нет кассы с номером &2", p-obj-code, pay-desk_
                )
                ).
            undo, return .
        end.
        If available  ub.cash-desk and  ub.cash-desk.pos-type = p-pos-type then.
        else do:
            p-pos-type =  ub.cash-desk.pos-type.
            run get-ibm-parameters in this-procedure no-error.
            if error-status:error then do:
                assign
                    p-view-log = yes
                    .
                run write-log-and-file in p-log-handle (
                    input 1
                    , input log-file-name
                    , input 1
                    , input substitute( "!!!При обработке файла &1 произошла ошибка при получении значений настроечных параметров"
                    )
                    ).
                undo, return .
            end.
        end.
        find first temp-cash-desk where
            temp-cash-desk.cash-num = (if p-pos-type = 'Autotank':U then 0 else pay-desk_) no-error.
        if not available temp-cash-desk then do:
            if p-pos-type = 'MAGIA-XML':U then
                run get-last-check-date-time in this-procedure (
                    input g#db-num
                    ,input p-obj-code
                    ,input p-pos-type
                    ,input pay-desk_
                    ,output v-last-date
                    ,output v-last-time) no-error.
            else
                run get-last-check-params in this-procedure (
                input g#db-num
                ,input p-obj-code
                ,input p-pos-type
                ,input (if p-pos-type = 'Autotank':U then 0 else pay-desk_)
                    ,output v-last-date
                    ,output v-last-time
                    ,output v-last-shift-num
                    ,output v-last-z-count
                    ,output v-last-chk-num
                    ) no-error.
            create temp-cash-desk.
            assign
                temp-cash-desk.cash-num = (if p-pos-type = 'Autotank':U then 0 else pay-desk_)
                temp-cash-desk.last-date = v-last-date
                temp-cash-desk.last-time = v-last-time
                temp-cash-desk.last-shift-num = v-last-shift-num
                temp-cash-desk.last-z-count = v-last-z-count
                temp-cash-desk.last-chk-num = v-last-chk-num
                .
        end.
        assign
            v-old = string(year(temp-cash-desk.last-date), "9999") +
            string(month(temp-cash-desk.last-date), "99") +
            string(day(temp-cash-desk.last-date), "99") +
            string(temp-cash-desk.last-time, "HH:MM:SS") +
            string(temp-cash-desk.last-shift-num, "99") +
            string(temp-cash-desk.last-z-count, "99999") +
            string(temp-cash-desk.last-chk-num, "-999999999")
            .
        assign
            v-eff-date = if p-pos-type = 'Autotank':U then spool-date_ else chk-date_
            v-eff-time = if p-pos-type = 'Autotank':U then spool-time_ else chk-time_
            .
        define variable vTimestring as character no-undo.
        Vtimestring = string(v-eff-time, "HH:MM:SS").
        entry(1,Vtimestring,":") = string(int(entry(1,Vtimestring,":")) - 1,"99") no-error.
        if    vTimestring begins "?"
        or error-status:error
        then do:
            entry(1,Vtimestring,":") = "00".
            v-eff-date = v-eff-date - 1.
        end.
        else
            v-eff-time = v-eff-time - 1 * 60 * 60.
        assign
            v-new = string(year(v-eff-date), "9999") +
            string(month(v-eff-date), "99") +
            string(day(v-eff-date), "99") +
            Vtimestring +
            string(integer(shift-name_), "99") +
            string(z-num_, "99999") +
            string(chk-num_, "-999999999")
            .
        if v-new > v-old then do:
            assign
                temp-cash-desk.last-date       = v-eff-date
                temp-cash-desk.last-time       = v-eff-time
                temp-cash-desk.last-shift-num  = integer(shift-name_)
                temp-cash-desk.last-z-count    = z-num_
                temp-cash-desk.last-chk-num    = chk-num_
                .
        end.
        run  proc-shift-open.
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
                ub.chk-doc.sales-man = sales-man_
                NO-LOCK NO-ERROR.
            IF NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc then do:
                assign
                    mc-exist = NO .
                CREATE buf_chk-doc.
                assign
                    buf_chk-doc.chk-type = 0
                    buf_chk-doc.office = ?
                    lng = 0
                    lnp = 0
                    lnc = 0
                    var-discnt-id = 0
                    buf_chk-doc.chk-id = v-id
                    buf_chk-doc.correct = yes
                    buf_chk-doc.obj-code = shop-code
                    buf_chk-doc.obj-type = shop-type
                    buf_chk-doc.doc-code = (if get-chkc_context.db-num = 0
                    then string(next-value(s-chk, ub ))
                    else string( shop-code ) + chr(47) + string( next-value( s-chk, ub ) ))
                    buf_chk-doc.chk-num = chk-num_
                    buf_chk-doc.chk-date = chk-date_
                    buf_chk-doc.chk-time = chk-time_
                    buf_chk-doc.sales-man = (if sales-man_ = ? then 0 else sales-man_)
                    buf_chk-doc.pay-desk = pay-desk_
                    buf_chk-doc.cashier = cashier_
                    buf_chk-doc.src-shift-date = shift-date_
                    shift-name_ = if cas-shft then string(shift-num_) else '':U
                    shift-num_ = if get-chkc_context.shift-on then 0 else shift-num_
                    buf_chk-doc.shift-num = shift-num_
                    buf_chk-doc.src-shift-name = shift-name_
                    buf_chk-doc.shift-name = shift-name_
                    buf_chk-doc.z-number = z-num_
                    buf_chk-doc.chk-type = int(gbl-type)
                    buf_chk-doc.prev-chk-type = int(prev-gbl-type)
                    buf_chk-doc.cash-rate = cash-rate_
                    buf_chk-doc.cash-scale = 1
                    buf_chk-doc.doc-num = doc-num_
                    buf_chk-doc.tot-doc = 0
                    buf_chk-doc.netto = 0
                    buf_chk-doc.discnt = 0
                    buf_chk-doc.d-pcnt = 0
                    buf_chk-doc.src-d-pcnt = 0
                    buf_chk-doc.doc-qnty = 0
                    buf_chk-doc.src-tot-doc = 0
                    buf_chk-doc.src-d-mask = ''
                    buf_chk-doc.d-mask = ''
                    buf_chk-doc.d-card = ''
                    buf_chk-doc.src-d-card = ''
                    buf_chk-doc.src-cli-type = ?
                    buf_chk-doc.src-cli-code = ?
                    buf_chk-doc.cli-type = ?
                    buf_chk-doc.cli-code = ?
                    buf_chk-doc.doc-num2 = ?
                    buf_chk-doc.out-2-code = ?
                    no-error
                    .
                if error-status:error then do:
                    assign
                        buf_chk-doc.correct = no
                        .
                end.
                if vCHNumberKKT ne ""
                then do:
                    create buf_chk-doc-attr.
                    assign
                        buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                        buf_chk-doc-attr.attr-code  = "CHNumberKKT"
                        buf_chk-doc-attr.attr-value = vCHNumberKKT
                        .
                end.
                if v-id > "" then do:
                    create buf_chk-doc-attr.
                    assign
                        buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                        buf_chk-doc-attr.attr-code  = "CheckId"
                        buf_chk-doc-attr.attr-value = v-id
                        .
                end.
                if vCHMgrKey ne ""
                then do:
                    create buf_chk-doc-attr.
                    assign
                        buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                        buf_chk-doc-attr.attr-code  = "CHMgrKey"
                        buf_chk-doc-attr.attr-value = vCHMgrKey
                        .
                end.
                if vCHFlag1 ne ""
                then do:
                    create buf_chk-doc-attr.
                    assign
                        buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                        buf_chk-doc-attr.attr-code  = "CHFlag1"
                        buf_chk-doc-attr.attr-value = vCHFlag1
                        .
                end.
                if vCHNumberFN ne ""
                then do:
                    create buf_chk-doc-attr.
                    assign
                        buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                        buf_chk-doc-attr.attr-code  = "CHNumberFN"
                        buf_chk-doc-attr.attr-value = vCHNumberFN
                        .
                end.
                if vCHFiscalDocSign > "" then do:
                    create buf_chk-doc-attr.
                    assign
                        buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                        buf_chk-doc-attr.attr-code  = "CHFiscalDocSign"
                        buf_chk-doc-attr.attr-value = vCHFiscalDocSign
                        .
                end.
                if vCHFiscalDocNumber > 0 then do:
                    create buf_chk-doc-attr.
                    assign
                        buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                        buf_chk-doc-attr.attr-code  = "CHFiscalDocNumber"
                        buf_chk-doc-attr.attr-value = string(vCHFiscalDocNumber)
                        .
                end.
                mc-prev-code = buf_chk-doc.doc-code.
            end.
            else
                mc-curr-chk-type = 0 .
            return.
        end.
        if lookup(gbl-type, accept-types) > 0
        or (p-pos-type = 'MAGIA-XML':U and integer(gbl-type) = 8)
        then do:
            assign
                for-chk-type = ""
                exist = yes
                v-create-return-write-off = no
                v-is-without-payment = no
                v-to-delete[1] = no
                v-to-delete[2] = no
                .
            FIND  buf_chk-doc where
                buf_chk-doc.obj-type = shop-type and
                buf_chk-doc.obj-code = shop-code and
                buf_chk-doc.chk-date = chk-date_ and
                buf_chk-doc.pay-desk = pay-desk_ and
                buf_chk-doc.chk-time = chk-time_ and
                buf_chk-doc.chk-num = chk-num_ and
                (p-pos-type = 'MAGIA-XML':U
                or buf_chk-doc.cashier = cashier_
                ) NO-ERROR NO-WAIT.
            IF NOT AVAILABLE buf_chk-doc
            AND NOT LOCKED buf_chk-doc
            AND NOT AMBIGUOUS buf_chk-doc
            or (p-pos-type = 'MAGIA-XML':U
            AND
            (AVAILABLE buf_chk-doc
            and
            NOT AMBIGUOUS buf_chk-doc)
            )  then do:
                v-chk-type[1] = integer(gbl-type).
                if p-pos-type = 'MAGIA-XML':U then do:
                    for each temp-ivs-ibs where
                        temp-ivs-ibs.chtype = gbl-type
                            AND temp-ivs-ibs.positive-num-chk = (chk-num_ > 0)
                            AND temp-ivs-ibs.positive-netto-sum = ((netto-sum_ > 0) or (netto-sum_ = 0  and chk-num_ < 0))
                            and temp-ivs-ibs.main-record = yes:
                        if temp-ivs-ibs.step_ = 1 then v-chk-type[1] = integer(temp-ivs-ibs.rcpt-type-1).
                        if temp-ivs-ibs.step_ = 2 then do:
                            assign
                                v-chk-type[2] = integer(temp-ivs-ibs.rcpt-type-1)
                                v-create-return-write-off = temp-ivs-ibs.create-return-write-off
                                v-write-off-code-2 = integer(temp-ivs-ibs.wro-code)
                                .
                        end.
                    end.
                    if v-chk-type[1] = 0 then do:
                        assign
                            exist = yes.
                        run write-log-and-file in p-log-handle (
                            input 1
                            , input log-file-name
                            , input 1
                            , input substitute( "!!!Неизвестный тип чека:&1" +
                            "код типа чека &2 сумма нетто &3 номер чека на кассе &4 касса &5"
                            , chr(10)
                            , gbl-type
                            , netto-sum_
                            , chk-num_
                            , pay-desk_
                            )
                            ).
                        assign
                            p-view-log = yes
                            .
                        return.
                    end.
                    if AMBIGUOUS buf_chk-doc
                    or available buf_chk-doc then do:
                        if v-chk-type[2] = 0 then return.
                        do v-step = 2 to 1 by -1:
                            FIND  buf_chk-doc no-lock where
                                buf_chk-doc.obj-type = shop-type and
                                buf_chk-doc.obj-code = shop-code and
                                buf_chk-doc.chk-date = chk-date_ and
                                buf_chk-doc.pay-desk = pay-desk_ and
                                buf_chk-doc.chk-time = chk-time_ and
                                buf_chk-doc.chk-num = chk-num_ and
                                buf_chk-doc.chk-type = integer(v-chk-type[v-step])
                                NO-ERROR NO-WAIT.
                            if available buf_chk-doc then do:
                                assign
                                    v-to-delete[v-step] = yes
                                    .
                                if v-step = 1 then do:
                                    prev-code = buf_chk-doc.doc-code.
                                end.
                            end.
                        end.
                        if v-to-delete[1] = yes
                        and v-to-delete[2] = yes then return.
                        if v-create-return-write-off
                        and v-to-delete[1]
                        and not v-to-delete[2]
                        then do:
                            exist = yes.
                            return.
                        end.
                    end.
                    else do:
                    end.
                end.
                for each temp-ivs-ibs-line:
                    delete temp-ivs-ibs-line.
                end.
                assign
                    exist = NO.
                create buf_chk-doc.
                assign
                    buf_chk-doc.office = ?
                    v-to-delete[1] = NO
                    v-to-delete[1] = NO
                    kriv3 = NO
                    lng = 0
                    lnp = 0
                    lnc = 0
                    sub-d = 0
                    var-discnt-id = 0
                    lng-sub-d = 0
                    netto-for-sub-d = 0
                    accum-src-for-sub-d = 0
                    buf_chk-doc.chk-id = v-id
                    buf_chk-doc.obj-code = shop-code
                    buf_chk-doc.obj-type = shop-type
                    buf_chk-doc.doc-code = (if get-chkc_context.db-num = 0
                    then string(next-value(s-chk, ub ))
                    else string( shop-code ) + chr(47) + string( next-value( s-chk, ub ) ))
                    buf_chk-doc.chk-num =  chk-num_
                    buf_chk-doc.chk-date = chk-date_
                    buf_chk-doc.chk-time = chk-time_
                    buf_chk-doc.sales-man = (if sales-man_ = ? then 0 else sales-man_)
                    buf_chk-doc.pay-desk = pay-desk_
                    buf_chk-doc.cashier = cashier_
                    buf_chk-doc.discnt = 0
                    buf_chk-doc.src-d-card =  (if d-card_ <> "":U then d-card_ else ?)
                    buf_chk-doc.src-d-pcnt = - tot-d-pcnt
                    buf_chk-doc.src-cli-type = (if cli-type_ = "":u then ? else cli-type_)
                    buf_chk-doc.src-cli-code = (if cli-code_ = 0    then ? else cli-code_)
                    buf_chk-doc.src-shift-date = (if is-shift-date then shift-date_ else chk-date_)
                    shift-name_ = if cas-shft then string(shift-num_) else '':U
                    shift-num_ = if get-chkc_context.shift-on then 0 else shift-num_
                    buf_chk-doc.shift-num = shift-num_
                    buf_chk-doc.src-shift-name = shift-name_
                    buf_chk-doc.shift-name = shift-name_
                    buf_chk-doc.cash-rate = cash-rate_
                    buf_chk-doc.cash-scale = 1
                    buf_chk-doc.z-number = z-num_
                    buf_chk-doc.doc-num = doc-num_
                    buf_chk-doc.chk-type = v-chk-type[1]
                    buf_chk-doc.out-code = if buf_chk-doc.chk-type eq 13 or buf_chk-doc.chk-type eq 40 then 'смена':U else buf_chk-doc.out-code
                    buf_chk-doc.prev-chk-type = int(prev-gbl-type)
                    v-is-petrol-check = lookup(string(v-chk-type[1]) , '14,15,16,17,36':U) > 0
                    buf_chk-doc.correct = YES
                    no-error
                    .
                if error-status:error then do:
                    buf_chk-doc.correct = no.
                end.
                if buf_chk-doc.chk-type eq 13 or buf_chk-doc.chk-type eq 40
                then do:
                    create buf_chk-doc-attr.
                    assign
                        buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                        buf_chk-doc-attr.attr-code  = "CHFlag1S"
                        buf_chk-doc-attr.attr-value = 'no'
                        .
                end.
                if vCHNumberKKT ne ""
                then do:
                    create buf_chk-doc-attr.
                    assign
                        buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                        buf_chk-doc-attr.attr-code  = "CHNumberKKT"
                        buf_chk-doc-attr.attr-value = vCHNumberKKT
                        .
                end.
                if v-id > "" then do:
                create buf_chk-doc-attr.
                assign
                buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                buf_chk-doc-attr.attr-code  = "CheckId"
                buf_chk-doc-attr.attr-value = v-id
                .
                end.
                if vCHMgrKey ne ""
                then do:
                create buf_chk-doc-attr.
                assign
                buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                buf_chk-doc-attr.attr-code  = "CHMgrKey"
                buf_chk-doc-attr.attr-value = vCHMgrKey
                .
                end.
                if vCHNumberFN ne ""
                then do:
                create buf_chk-doc-attr.
                assign
                buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                buf_chk-doc-attr.attr-code  = "CHNumberFN"
                buf_chk-doc-attr.attr-value = vCHNumberFN
                .
                end.
                if vCHFiscalDocSign > "" then do:
                create buf_chk-doc-attr.
                assign
                buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                buf_chk-doc-attr.attr-code  = "CHFiscalDocSign"
                buf_chk-doc-attr.attr-value = vCHFiscalDocSign
                .
                end.
                if vCHFiscalDocNumber > 0 then do:
                create buf_chk-doc-attr.
                assign
                buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                buf_chk-doc-attr.attr-code  = "CHFiscalDocNumber"
                buf_chk-doc-attr.attr-value = string(vCHFiscalDocNumber)
                .
                end.
                if vCHFlag1 ne ""
                then do:
                create buf_chk-doc-attr.
                assign
                buf_chk-doc-attr.doc-code   = buf_chk-doc.doc-code
                buf_chk-doc-attr.attr-code  = "CHFlag1"
                buf_chk-doc-attr.attr-value = vCHFlag1
                .
                end.
                if buf_chk-doc.chk-type = integer('43':U) or buf_chk-doc.chk-type = integer('44':U)
                then do :
                assign
                buf_chk-doc.tot-doc = brutto-sum_
                buf_chk-doc.netto   = netto-sum_
                .
                end.
                prev-code = buf_chk-doc.doc-code.
                if v-chk-type[1] = integer('8':U)
                then do:
                assign
                netto-sum_ = 0
                .
                end.
            end.
        end.
    end.
end procedure .
procedure proc-Parameter :
    define buffer buf_temp-param for temp-param.
    define buffer buf_chk-doc for tt-chk-doc.
    define buffer buf_shift-obj for ub.shift-obj.
    define variable v-ffd-version as character no-undo .
    define variable v-KKT_SCHEMA as character no-undo .
    do
        on error undo, return error
            :
        for each buf_temp-param where
            buf_temp-param.record-name = "Param":U
                AND buf_temp-param.desk = m-head-cash-num
                and buf_temp-param.field-name = "ParamValue":
            run cd-attr-write in this-procedure (        m-head-db-num
                ,m-head-obj-code
                ,m-head-pos-type
                ,m-head-cash-num
                ,input  (if p-pos-type = 'IBM-XML':U
                then 'IBM-XML_operative':U
                else 'AUTOTANK_operative':U)
                ,input buf_temp-param.key-name
                ,input buf_temp-param.field-value
                ,input ?
                ,input 0
                ,input 0
                ,input no
                ) no-error.
            if error-status:error then do:
                if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
            end.
        end.
    END.
end procedure.
procedure proc-FuelPump :
    define buffer buf_temp-param     for temp-param.
    define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer buf_pl-gds-pump    for ub.pl-gds-pump.
    do
        on error undo, return error
            :
        if v-key = "READ" then
        do:
            for each buf_pl-pump-nozzle where
                buf_pl-pump-nozzle.obj-type = p-obj-type
                    AND buf_pl-pump-nozzle.obj-code = p-obj-code
                    and buf_pl-pump-nozzle.pump-code = integer(v-group) no-lock,
                    each buf_pl-gds-pump exclusive-lock where buf_pl-gds-pump.obj-code = buf_pl-pump-nozzle.obj-code and
                    buf_pl-gds-pump.obj-type = buf_pl-pump-nozzle.obj-type and
                    buf_pl-gds-pump.pump-code = buf_pl-pump-nozzle.pump-code and
                    buf_pl-gds-pump.pl-code = buf_pl-pump-nozzle.pl-code:
                find first buf_temp-param where
                    buf_temp-param.record-name = "FuelPump":U
                    AND buf_temp-param.desk = m-head-cash-num
                    and buf_temp-param.key-name = "READ"
                    and buf_temp-param.field-name = "FPFNzl"
                    and buf_temp-param.group-name = v-group
                    and buf_pl-pump-nozzle.nozzle-code = integer(buf_temp-param.field-value) no-error .
            end.
        END.
    end.
end procedure.
procedure proc-CAuthorization :
    define buffer buf_temp-temp for temp-temp.
    define buffer buf_chk-doc for tt-chk-doc.
    define buffer buf_shift-obj for ub.shift-obj.
    do
        on error undo, return error
            :
        assign
            AuthType_ = 0
            qr-alchol_ = "":u
            no-error
            .
        _buf_temp:
        for each buf_temp-temp no-lock where
            buf_temp-temp.record-name = "CAuthorization":U
                AND buf_temp-temp.id = v-id:
            CASE buf_temp-temp.field-name:
                when "CAuthType":U then do:
                    assign
                        AuthType_ = fdecimal(buf_temp-temp.field-value)
                        no-error .
                end.
                when "CAuthUrl":U then do:
                    run xmlchar-decode in this-procedure (
                        input trim(buf_temp-temp.field-value)
                        , output qr-alchol_
                        ) no-error.
                end.
                otherwise do:
                    error-status:error = no.
                end.
            END CASE.
            if error-status:error then do:
                if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
            end.
        END.
        define variable v-value as character no-undo .
        define variable v-type  as character no-undo .
        find first buf_chk-doc no-error.
        if AuthType_ = 2 then do:
            run chkdocat-write IN THIS-PROCEDURE(
                input buf_chk-doc.doc-code
                ,INPUT "qr-alchol-pv"
                ,INPUT qr-alchol_ ) NO-ERROR.
        end.
        if AuthType_ <> 2 and AuthType_ <> 0 then do:
            run chkdocat-write IN THIS-PROCEDURE(
                input buf_chk-doc.doc-code
                ,INPUT "qr-alchol"
                ,INPUT qr-alchol_ ) NO-ERROR.
        end.
    end.
end procedure.
procedure proc-01-gds :
    DEFINE VARIABLE no-add-price as logical no-undo .
    define variable vCSTValue as decimal no-undo.
    define variable vCSTaxValue as decimal no-undo.
    define variable lng-spl as integer no-undo .
    define variable depart-id_ as integer no-undo .
    define variable v-d-pcnt-categ as decimal no-undo .
    define variable v-d-sum-categ as decimal no-undo .
    define variable v-d-pcnt-time as decimal no-undo .
    define variable v-d-sum-time as decimal no-undo .
    define variable v-d-pcnt-qnty as decimal no-undo .
    define variable v-d-sum-qnty as decimal no-undo .
    define variable v-d-pcnt-manual as decimal no-undo .
    define variable v-d-sum-manual as decimal no-undo .
    define variable write-off-reason-code_ as integer no-undo .
    define variable v-is-modificator as logical no-undo .
    define variable D-CARD2_ as character no-undo .
    define variable v-step as integer   no-undo .
    define variable v-line-type as character no-undo .
    define variable v-dt-season as integer no-undo .
    define variable v-VAT-pc like ub.chk-gds.VAT-pc no-undo .
    define variable v-promo as integer no-undo .
    define variable v-promo-sum as decimal no-undo .
    define buffer buf_chk-gds for tt-chk-gds.
    define buffer buf2_chk-gds for tt-chk-gds.
    define buffer buf_chk-gds-attr for tt-chk-gds-attr.
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_temp-temp for temp-temp.
    define buffer buf_chk-doc for tt-chk-doc.
    define buffer buf_sum-grp for tt-sum-grp.
    do
        on error undo, return error
            :
        assign
            d-card_ = "":U
            d-mask_ = "":U
            cli-type_ = "":U
            cli-code_ = 0
            b-c = 0
            nozzle_ = 0
            place_ = 0
            pump_ = 0
            .
        if not exist
        or (v-to-delete[1] = yes
        and
        v-to-delete[2] = no)
        then  do:
            for each buf_temp-temp where
                buf_temp-temp.record-name = "CSale":U
                    AND buf_temp-temp.id = v-id:
                CASE buf_temp-temp.field-name:
                    when "CSType":U then do:
                        assign
                            cstype_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSCode":U then do:
                        assign
                            bc-buf = buf_temp-temp.field-value
                            no-error
                            .
                    end.
                    when "CSLocal":U then do:
                        integer(buf_temp-temp.field-value) no-error .
                        if error-status:error = no then
                        do:
                            assign
                                b-c = integer(buf_temp-temp.field-value)
                                .
                        end.
                    end.
                    when "CSPriceOrig":u then do:
                        assign
                            price-old = dec(buf_temp-temp.field-value)
                            no-error
                            .
                    end.
                    when "CSPrice":u then do:
                        assign
                            price-from-check = dec(buf_temp-temp.field-value)
                            no-error
                            .
                    end.
                    when "CSQty":u then do:
                        assign
                            curr-string-qnty = dec(buf_temp-temp.field-value)
                            no-error
                            .
                    end.
                    when "CSTrk":u then do:
                        assign
                            pump_ = int(buf_temp-temp.field-value)
                            no-error
                            .
                    end.
                    when "CSSaleman":U or
                    when "CSGarcon":U then do:
                        assign
                            sales-man_ = int(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSCCard":U then do:
                        assign
                            d-card2_ = buf_temp-temp.field-value
                            no-error .
                    end.
                    when "CSCNum":U then do:
                        assign
                            d-card_ = buf_temp-temp.field-value
                            no-error .
                    end.
                    when "CSCMask":U then do:
                        assign
                            d-mask_ = buf_temp-temp.field-value
                            no-error .
                    end.
                    when "CSCCode":U then do:
                        assign
                            cli-code_ = integer(buf_temp-temp.field-value)
                            cli-type_ = if cli-code_ > 9999999999 then 'орг':U else 'чел':U
                            no-error .
                    end.
                    when "CSString":U then do:
                        assign
                            lng-spl = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSTotal":u then do:
                        assign
                            sum-from-check = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSTValue":U then do:
                        assign
                            cstValue = fdecimal(buf_temp-temp.field-value)
                            vCSTValue = fdecimal (buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSTCode":U then do:
                        run xmlchar-decode in this-procedure (
                            input trim(buf_temp-temp.field-value)
                            , output cstCode
                            ) no-error.
                    end.
                    when "CSSNoTotal":U then do:
                        if p-pos-type <> 'MAGIA-XML':U then
                            assign
                            no-add-price = if integer(buf_temp-temp.field-value) = 1
                            then yes
                                else no
                                no-error .
                            else do:
                                assign
                                    error-status:error = no.
                            end.
                    end.
                    when "CSTValue":U then do:
                        assign
                            vCSTValue = decimal (buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSTTaxValue":U then do:
                        assign
                            vCSTaxValue = decimal (buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSSHandCode":u then do:
                        assign
                            pass-gds_ =   (if integer(buf_temp-temp.field-value) = 1
                            then 1
                            else 0)
                            no-error .
                    end.
                    when "CSGcode":U then do:
                        if p-pos-type = 'MAGIA-XML':U then do:
                            assign
                                depart-id_ = integer(buf_temp-temp.field-value)
                                no-error .
                        end.
                        else do:
                            if buf_temp-temp.field-value <> string(0) then do:
                                If cstype_ = 37 then v-oss-code =  buf_temp-temp.field-value.
                                else do:
                                    for each buf_sum-grp where string (buf_sum-grp.grp-code) = buf_temp-temp.field-value:
                                        find first ub.goods-attr where ub.goods-attr.gds-code = buf_sum-grp.code-2
                                            and ub.goods-attr.attr-code = 'office-type':U and ub.goods-attr.attr-value = 'oss-pay':U no-error.
                                        if available ub.goods-attr
                                        then assign v-oss-code = bc-buf.
                                    end.
                                    assign
                                        bc-buf = buf_temp-temp.field-value
                                        v-line-type = 'grp'
                                        no-error
                                        .
                                end.
                            end.
                            else do:
                                assign
                                    error-status:error = no.
                            end.
                        end.
                    end.
                    when "CSDiscnt1Pcnt":U then do:
                        assign
                            v-d-pcnt-categ = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSDiscnt1Sum":U then do:
                        assign
                            v-d-sum-categ = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSDiscnt2Pcnt":U then do:
                        assign
                            v-d-pcnt-time = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSDiscnt2Sum":U then do:
                        assign
                            v-d-sum-time = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSDiscnt3Pcnt":U then do:
                        assign
                            v-d-pcnt-qnty = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSDiscnt3Sum":U then do:
                        assign
                            v-d-sum-qnty = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSDiscnt4Pcnt":U then do:
                        assign
                            v-d-pcnt-manual = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSDiscnt4Sum":U then do:
                        assign
                            v-d-sum-manual = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSSModificator":U then do:
                        assign
                            v-is-modificator = if integer(buf_temp-temp.field-value) = 1
                            then yes
                            else no
                            no-error .
                    end.
                    when "CSSModificatorNullPrice":U then do:
                        assign
                            no-add-price = if integer(buf_temp-temp.field-value) = 1
                            then yes
                            else no
                            no-error .
                    end.
                    when "CSSCancelCode":U then do:
                        assign
                            write-off-reason-code_ = integer(buf_temp-temp.field-value)
                            no-error
                            .
                    end.
                    when "CSNozzle":U then do:
                        assign
                            nozzle_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSTank":U then do:
                        assign
                            place_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSTankCode":U then do:
                        assign
                            pl-code_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CHBrutto":U then do:
                        assign
                            v-src-tot-doc = decimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CSPromo":U then do:
                        assign
                            v-promo = decimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    otherwise do:
                        error-status:error = no.
                    end.
                END CASE.
                if error-status:error then do:
                    if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
                end.
                if (p-pos-type = 'IBM-XML':U
                or p-pos-type = 'Autotank':U)
                and  LOOKUP(string(cstype_), "6,7,8":U) > 0
                and not get-chkc_context.ibmgroup
                then return.
                delete buf_temp-temp.
            end.
            if error-status:error then do:
                if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
            end.
            if v-promo = 1 then do:
                sum-from-check = Round(price-from-check * curr-string-qnty,2).
            end.
            if cstype_ = 18 then do:
            FIND FIRST buf_chk-doc.
                assign
                    d-card_ = (if d-card_ = ""
                    and d-mask_ <> ""
                    then d-mask_
                    else d-card_)
                    buf_chk-doc.src-d-card       = (if d-card_ = "":U
                    or buf_chk-doc.src-d-card = d-card_
                    then buf_chk-doc.src-d-card
                    else (if not v-flag-card
                    and (buf_chk-doc.src-d-card = ? or tt-chk-doc.src-d-card = "":U)
                    then d-card_
                    else d-card_
                    )
                    )
                    buf_chk-doc.src-cli-type   = (if cli-type_ = "":U
                    or buf_chk-doc.src-cli-type = cli-type_
                    then buf_chk-doc.src-cli-type
                    else (if not v-flag-card
                    and (buf_chk-doc.src-cli-type = ? or buf_chk-doc.src-cli-type = "":U)
                    then cli-type_
                    else ?)
                    )
                    buf_chk-doc.src-cli-code   = (if cli-code_ = 0
                    or buf_chk-doc.src-cli-code = cli-code_
                    then buf_chk-doc.src-cli-code
                    else (if not v-flag-card
                    and (buf_chk-doc.src-cli-code = ? or buf_chk-doc.src-cli-code = 0)
                    then cli-code_
                    else ?)
                    )
                    buf_chk-doc.d-card = if d-CARD2_ <> "":U then d-CARD2_ else buf_chk-doc.d-card
                    v-flag-card         = (if not v-flag-card  and d-card_ <> "":U
                    then yes
                    else v-flag-card)
                    .
                return.
            end.
            assign
                time-oper_ =  (if p-pos-type = 'MAGIA-XML':U
                then (v-time modulo 86400)
                else string-IS0-8601-to-sec(v-time-char))
                no-error
                .
            if p-pos-type = 'MAGIA-XML':U
            then do:
                if gbl-type = "8"
                and cstype_ = 6
                and lookup(string(write-off-reason-code_), ret-chk) > 0 then do:
                    run recalc-write-off in this-procedure(buffer tt-chk-doc, input gbl-type, input "6").
                    if v-to-delete[1] = yes
                    and v-to-delete[2] = yes then do:
                        assign
                            v-to-delete[1] = no
                            v-to-delete[2] = no
                            .
                        return.
                    end.
                end.
                do v-step = 1 to (if v-create-return-write-off then 2 else 1):
                    if v-is-modificator = ? then
                        v-is-modificator = no.
                    if v-is-modificator
                    and not no-add-price then v-is-modificator = no.
                    find first temp-ivs-ibs where
                        temp-ivs-ibs.chtype = gbl-type
                        AND temp-ivs-ibs.cstype = string(cstype_)
                        and temp-ivs-ibs.cancelcode = string(write-off-reason-code_)
                        and temp-ivs-ibs.positive-num-chk = (chk-num_ > 0)
                        and temp-ivs-ibs.positive-netto-sum = (netto-sum_ >= 0)
                        and temp-ivs-ibs.modificator = v-is-modificator
                        and (v-is-modificator = no or temp-ivs-ibs.modificator-np = no-add-price)
                        and temp-ivs-ibs.step_ = v-step no-error .
                    if not available temp-ivs-ibs then do:
                        assign
                            exist = yes.
                        run write-log-and-file in p-log-handle (
                            input 1
                            , input log-file-name
                            , input 1
                            , input substitute( "!!!Неизвестный тип строки чека:&1" +
                            "код типа чека &2 код типа строки чека &3 код списания &4&1" +
                            "&7&1" +
                            "номер чека на кассе &5 касса &6"
                            , chr(10)
                            , gbl-type
                            , cstype_
                            , write-off-reason-code_
                            , chk-num_
                            , pay-desk_
                            , (if v-is-modificator
                            then ('модификатор' + chr(32) + (if no-add-price
                            then 'без цены'
                            else '':U))
                            else '')
                            )
                            ).
                        assign
                            p-view-log = yes
                            .
                        return.
                    end.
                    if available temp-ivs-ibs then do:
                        if v-step = 1 then
                            create
                                temp-ivs-ibs-line
                                .
                        if v-step  = 1 then do:
                            assign
                                temp-ivs-ibs-line.chtype = temp-ivs-ibs.chtype
                                temp-ivs-ibs-line.cstype = temp-ivs-ibs.cstype
                                temp-ivs-ibs-line.cancelcode = temp-ivs-ibs.cancelcode
                                temp-ivs-ibs-line.modificator = temp-ivs-ibs.modificator
                                temp-ivs-ibs-line.modificator-np = temp-ivs-ibs.modificator-np
                                temp-ivs-ibs-line.create-return-write-off =  temp-ivs-ibs.create-return-write-off
                                temp-ivs-ibs-line.return-line = temp-ivs-ibs.return-line
                                temp-ivs-ibs-line.line-num = (if lng-spl = 0 then - lng else lng-spl)
                                temp-ivs-ibs-line.rcpt-type-1                        = temp-ivs-ibs.rcpt-type-1
                                temp-ivs-ibs-line.wro-code[v-step]                   = temp-ivs-ibs.wro-code
                                temp-ivs-ibs-line.qnty-sign[v-step]                  = temp-ivs-ibs.qnty-sign
                                temp-ivs-ibs-line.step_[v-step]                      = temp-ivs-ibs.step_
                                .
                        end.
                        if v-step = 2
                        and available temp-ivs-ibs-line
                        and available temp-ivs-ibs then do:
                            assign
                                temp-ivs-ibs-line.rcpt-type-2                        = temp-ivs-ibs.rcpt-type-2
                                temp-ivs-ibs-line.wro-code[v-step]                   = temp-ivs-ibs.wro-code
                                temp-ivs-ibs-line.qnty-sign[v-step]                  = temp-ivs-ibs.qnty-sign
                                temp-ivs-ibs-line.step_[v-step]                      = temp-ivs-ibs.step_
                                .
                        end.
                    end.
                end.
            end.
            if v-to-delete[1] = yes then return.
            if (p-pos-type = 'IBM-XML':U
            or p-pos-type = 'Autotank':U)
            and v-line-type = 'grp':U
            and get-chkc_context.ibmgroup
            and can-find(first buf_sum-grp)
            and gbl-type <> "43" and gbl-type <> "44"
            then do:
                find first buf_sum-grp no-lock where
                    buf_sum-grp.grp-code = integer(bc-buf)
                    no-error .
                if not available buf_sum-grp then do:
                    assign
                        bc-buf = chr(4) + bc-buf.
                end.
                else do:
                    assign
                        bc-buf = string(buf_sum-grp.code-2) + chr(4) + bc-buf.
                end.
                v-line-type = '':U.
                assign
                    curr-string-qnty = sum-from-check
                    price-from-check = 1
                    .
            end.
            if p-pos-type = 'Autotank':U and lng-spl = 2 then
            do:
                if sum-from-check > 0 then
                do:
                    assign
                        autotank-sum-return = - sum-from-check
                        netto-sum_ = netto-sum_ + autotank-sum-return
                        .
                end.
                return .
            end.
            If cstype_ = 37 and (p-pos-type = 'IBM-XML':U OR p-pos-type = 'Autotank':U) then for first ub.goods-attr no-lock where ub.goods-attr.gds-code = int(bc-buf)
                and ub.goods-attr.attr-code = 'office-type':U and ub.goods-attr.attr-value = 'oss-pay':U:
                assign
                    curr-string-qnty = sum-from-check
                    price-from-check = 1.
            end.
            run gds-attr_check-code-dt-seasons in this-procedure
                (b-c, shop-type, shop-code, output b-c,output v-dt-season).
            FIND FIRST buf_chk-doc NO-ERROR.
            CREATE buf_chk-gds.
            assign
                buf_chk-gds.doc-code = buf_chk-doc.doc-code
                lng = lng + 1
                buf_chk-gds.line-num = (if lng-spl = 0 then - lng else lng-spl)
                buf_chk-gds.grp-code = 0
                buf_chk-gds.chk-date = buf_chk-doc.chk-date
                buf_chk-gds.b-code = b-c
                buf_chk-gds.src-code = bc-buf
                buf_chk-gds.src-price = price-from-check
                buf_chk-gds.src-sum   = sum-from-check
                buf_chk-gds.src-qnty = curr-string-qnty
                buf_chk-gds.src-discnt = 0
                buf_chk-gds.doc-qnty = 0
                buf_chk-gds.price-service = 0
                buf_chk-gds.time-oper = time-oper_
                buf_chk-gds.pass-gds = pass-gds_
                buf_chk-gds.is-error = NO
                buf_chk-gds.doc-qnty = 0
                buf_chk-gds.pump = (if pump_ > 0 then pump_ else 0)
                buf_chk-gds.nozzle = (if nozzle_ > 0 then nozzle_ else 0)
                buf_chk-gds.loc1 = (if place_ > 0 then string(place_) else '':U)
                buf_chk-gds.src-pl-code = (if pl-code_ > 0 then pl-code_ else 0)
                buf_chk-gds.road-tax = road-tax_
                buf_chk-gds.line-sign = (if buf_chk-doc.chk-type = integer('1':U)
                then (buf_chk-gds.src-qnty >= 0)
                else (buf_chk-gds.src-qnty <= 0)
                )
                buf_chk-gds.line-type = v-line-type
                buf_chk-gds.src-d-card = (if d-card_ <> "":U then d-card_ else ?)
                buf_chk-gds.src-d-mask = (if d-mask_ <> "":U then d-mask_ else ?)
                buf_chk-gds.src-cli-type = (if cli-type_ = "":u then ? else cli-type_)
                buf_chk-gds.src-cli-code = (if cli-code_ = 0 then ? else cli-code_)
                buf_chk-gds.d-card = if d-CARD2_ <> "":U then d-CARD2_ else buf_chk-gds.d-card
                buf_chk-doc.src-d-card       = (if d-card_ = "":U
                or buf_chk-doc.src-d-card = d-card_
                then buf_chk-doc.src-d-card
                else (if not v-flag-card
                and (buf_chk-doc.src-d-card = ? or buf_chk-doc.src-d-card = "":U)
                then d-card_
                else d-card_
                )
                )
                buf_chk-doc.src-d-mask       = (if d-mask_ = "":U
                or buf_chk-doc.src-d-mask = d-mask_
                then buf_chk-doc.src-d-mask
                else (if not v-flag-card
                and (buf_chk-doc.src-d-mask = ? or buf_chk-doc.src-d-mask = "":U)
                then d-mask_
                else "-0":U
                )
                )
                buf_chk-doc.src-cli-type   = (if cli-type_ = "":U
                or buf_chk-doc.src-cli-type = cli-type_
                then buf_chk-doc.src-cli-type
                else (if not v-flag-card
                and (buf_chk-doc.src-cli-type = ? or buf_chk-doc.src-cli-type = "":U)
                then cli-type_
                else ?)
                )
                buf_chk-doc.src-cli-code   = (if cli-code_ = 0
                or buf_chk-doc.src-cli-code = cli-code_
                then buf_chk-doc.src-cli-code
                else (if not v-flag-card
                and (buf_chk-doc.src-cli-code = ? or buf_chk-doc.src-cli-code = 0)
                then cli-code_
                else ?)
                ) .
                buf_chk-doc.d-card = if d-CARD2_ <> "":U then d-CARD2_ else buf_chk-doc.d-card .
                v-flag-card         = (if not v-flag-card  and d-card_ <> "":U
                then yes
                else v-flag-card) .
                buf_chk-gds.depart-id = depart-id_ .
                buf_chk-gds.sales-man  = sales-man_ .
                buf_chk-doc.sales-man = (if not v-flag-salesman
                and
                (
                buf_chk-doc.sales-man = 0
                or buf_chk-doc.sales-man = sales-man_
                or sales-man_ = 0
                )
                then sales-man_
                else 0) .
                buf_chk-doc.sales-man = (if buf_chk-doc.sales-man = ? then 0 else buf_chk-doc.sales-man) .
                v-flag-salesman   = (if not v-flag-salesman
                and (sales-man_ <> 0 and sales-man_ <> buf_chk-doc.sales-man)
                then yes
                else v-flag-salesman) .
                buf_chk-doc.src-tot-doc = v-src-tot-doc .
                buf_chk-gds.VAT-pc = vCSTaxValue  .
                buf_chk-gds.VAT-sum-rubl = vCSTValue .
            if p-pos-type = 'Autotank':U
            and buf_chk-gds.VAT-pc = 0
            and buf_chk-gds.VAT-sum-rubl = 0
            then do:
                for first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code :
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_bar-code.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-VAT-pc
  ) no-error .
                    buf_chk-gds.VAT-pc = v-VAT-pc .
                    buf_chk-gds.VAT-sum-rubl = (( buf_chk-gds.src-price *  buf_chk-gds.VAT-pc)/(100 +  buf_chk-gds.VAT-pc)) *  buf_chk-gds.src-qnty .
                end .
            end .
            // run proc-01-tax in this-procedure (output ub.chk-gds.VAT-pc, output ub.chk-gds.VAT-sum-rubl).
            if v-oss-code <> "" then do:
                case p-pos-type:
                    when 'Autotank':U then do:
                        find first buf_ext-classif where buf_ext-classif.CharKey_One = v-oss-code no-error.
                        if available buf_ext-classif then do:
                            assign
                                v-oss-code = string (buf_ext-classif.Key#_One)
                                .
                        end.
                    end.
                end case.
                create buf_chk-gds-attr.
                assign
                    buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
                    buf_chk-gds-attr.line-num = buf_chk-gds.line-num
                    buf_chk-gds-attr.attr-code = "oss-code"
                    buf_chk-gds-attr.attr-value =  v-oss-code
                    .
                v-oss-code = "".
            end.
            if v-dt-season <> 0 then do:
                create buf_chk-gds-attr.
                assign
                    buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
                    buf_chk-gds-attr.line-num = buf_chk-gds.line-num
                    buf_chk-gds-attr.attr-code = "SeasonDT"
                    buf_chk-gds-attr.attr-value =  string(v-dt-season)
                    .
            end.
            create buf_chk-gds-attr.
            assign
                buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
                buf_chk-gds-attr.line-num = buf_chk-gds.line-num
                buf_chk-gds-attr.attr-code = "cstype"
                buf_chk-gds-attr.attr-value =  string(cstype_)
                .
            if price-old <> 0 then do:
                create buf_chk-gds-attr.
                assign
                    buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
                    buf_chk-gds-attr.line-num = buf_chk-gds.line-num
                    buf_chk-gds-attr.attr-code = "CSPriceOrig"
                    buf_chk-gds-attr.attr-value =  string(price-old)
                    .
            end.
            if p-pos-type = 'IBM-XML':U
            or p-pos-type = 'Autotank':U
            then do:
                if buf_chk-doc.chk-type = integer('43':U) or buf_chk-doc.chk-type = integer('44':U)
                then do :
                    buf_chk-gds.road-tax = cstValue .
                    buf_chk-gds.depart-type = cstCode .
                end.
                if buf_chk-doc.chk-type = integer('17':U) then do:
                    assign
                        buf_chk-gds.write-off-code =  integer('17':U)
                        netto-for-sub-d = netto-for-sub-d + (if v-is-petrol-check then 0
                        else (buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty)
                        .
                end.
                else  do:
                    assign
                        buf_chk-gds.write-off-code = (if no-add-price
                        then (if lookup(string(buf_chk-doc.chk-type), '1,69,14,15,16,36':U) > 0
                        then integer('1':U)
                        else integer('-6':U)
                        )
                        else 0
                        )
                        netto-for-sub-d = netto-for-sub-d + (if (buf_chk-gds.write-off-code = ?
                        or buf_chk-gds.write-off-code <= 0)
                        and not v-is-petrol-check
                        then
                        ((buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty)
                        else 0)
                        accum-src-for-sub-d = accum-src-for-sub-d + buf_chk-gds.src-qnty
                        .
                end.
                buf_chk-doc.doc-num2 = doc-num2_.
            end.
            else do:
                assign
                    buf_chk-gds.write-off-code = integer(temp-ivs-ibs-line.wro-code[1])
                    netto-for-sub-d = netto-for-sub-d + if temp-ivs-ibs-line.return-line
                    then 0
                    else (
                    (if buf_chk-gds.write-off-code = ?
                    or buf_chk-gds.write-off-code <= 0
                    then
                    ((buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty)
                    else 0)
                    )
                    accum-src-for-sub-d = accum-src-for-sub-d + (if temp-ivs-ibs-line.return-line then 0 else buf_chk-gds.src-qnty)
                    .
                release temp-ivs-ibs-line.
                if v-d-pcnt-categ <> 0 or
                v-d-sum-categ <> 0 then do:
                    run proc-magia-discnt in this-procedure (v-d-pcnt-categ, v-d-sum-categ, integer('12':U)) no-error .
                end.
                if v-d-pcnt-time <> 0 or
                v-d-sum-time <> 0 then do:
                    run proc-magia-discnt in this-procedure (v-d-pcnt-time, v-d-sum-time, integer('3':U)) no-error .
                end.
                if v-d-pcnt-qnty <> 0 or
                v-d-sum-qnty <> 0 then do:
                    run proc-magia-discnt in this-procedure (v-d-pcnt-qnty, v-d-sum-qnty, integer('4':U)) no-error .
                end.
                if v-d-pcnt-manual <> 0 or
                v-d-sum-manual <> 0 then do:
                    run proc-magia-discnt in this-procedure (v-d-pcnt-manual, v-d-sum-manual, integer('13':U)) no-error .
                end.
            end.
            if v-promo <> 0 then do:
                find first buf_chk-gds-attr exclusive-lock where
                           buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
                       and buf_chk-gds-attr.line-num = buf_chk-gds.line-num
                       and buf_chk-gds-attr.attr-code = "CSPromo"
                no-wait no-error.
                if locked buf_chk-gds-attr then .
                else do:
                   if not available buf_chk-gds-attr
                   then
                   create buf_chk-gds-attr.
                   assign
                      buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
                      buf_chk-gds-attr.line-num = buf_chk-gds.line-num
                      buf_chk-gds-attr.attr-code = "CSPromo"
                      buf_chk-gds-attr.attr-value =  string(v-promo)
                      .
                end.
            end.
        end.
    end.
end procedure.
procedure proc-02-gds :
    define variable v-attr-code as character no-undo .
    define buffer buf_chk-doc for tt-chk-doc.
    define buffer buf_chk-gds for tt-chk-gds.
    define buffer buf_chk-gds-attr for tt-chk-gds-attr.
    define buffer buf_temp-temp for temp-temp.
    define buffer buf_tt-sum-grp for tt-sum-grp.
    define buffer buf_marking-chk for tt-marking-chk .
    do
        on error undo, return error
            :
        for each buf_temp-temp where
            buf_temp-temp.record-name = "CBarCode":U
                AND buf_temp-temp.id = v-id:
            CASE buf_temp-temp.field-name:
                when "CBCType":U then do:
                    CBCType_ = fdecimal(buf_temp-temp.field-value) no-error .
                end.
                when "CBCString":U then do:
                    CBCString_ = fdecimal(buf_temp-temp.field-value) no-error .
                end.
                when "CBCBarcode":U then do:
                    run xmlchar-decode in this-procedure (
                        input trim(buf_temp-temp.field-value)
                        , output CBCBarcode_
                        ) no-error.
                end.
                otherwise do:
                    error-status:error = no.
                end.
            END CASE.
            if error-status:error then do:
                if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
            end.
        end.
        if error-status:error then do:
            if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
        end.
        if CBCType_ <> 0 and
        (not exist
        or (v-to-delete[1] = yes
        and
        v-to-delete[2] = no))
        then do:
            if CBCType_ = 32768 then do :
                v-attr-code = "agent-gd-code":U .
            end .
            else
                if CBCType_ = 65536
                or CBCType_ = 65537
                then do :
                    v-attr-code = "tobacco-mark":U .
                end .
            else do :
                v-attr-code = "mark-code":U .
            end .
            if v-attr-code = "tobacco-mark" AND CBCBarcode_ = ""
            then do :
               assign  p-view-log = yes  .
                run write-log-and-file in p-log-handle (
                input 1
                , input log-file-name
                , input 1
                , input substitute("Ошибка при загрузке чека &1. Не заполнен тег CBCBarcode", chk-num_ )
                ).
            end.
            FIND FIRST buf_chk-doc NO-ERROR.
            if v-attr-code = "tobacco-mark"
            then do :
                if CBCBarcode_ <> "" then do :
                find first buf_marking-chk exclusive-lock where buf_marking-chk.mark      = CBCBarcode_
                    and buf_marking-chk.doc-code  = buf_chk-doc.doc-code
                    and buf_marking-chk.line-num  = CBCString_
                    no-error .
                if not available buf_marking-chk
                then do :
                    create buf_marking-chk .
                    assign
                        buf_marking-chk.mark      = CBCBarcode_
                        buf_marking-chk.doc-code  = buf_chk-doc.doc-code
                        buf_marking-chk.line-num  = CBCString_
                        .
                end .
                assign
                    buf_marking-chk.date-modify = today
                    buf_marking-chk.time-modify = time
                    .
                end .
            end .
            else do :
                find first buf_chk-gds-attr
                    where buf_chk-gds-attr.doc-code  = buf_chk-doc.doc-code
                    and buf_chk-gds-attr.line-num  = CBCString_
                    and buf_chk-gds-attr.attr-code = v-attr-code no-error.
                if available buf_chk-gds-attr then do:
                    CBCBarcode_ = buf_chk-gds-attr.attr-value + "," + CBCBarcode_ .
                    buf_chk-gds-attr.attr-value =  CBCBarcode_ .
                end.
                else do:
                    create buf_chk-gds-attr.
                    assign
                        buf_chk-gds-attr.doc-code = buf_chk-doc.doc-code
                        buf_chk-gds-attr.line-num = CBCString_
                        buf_chk-gds-attr.attr-code = v-attr-code
                        buf_chk-gds-attr.attr-value =  CBCBarcode_
                        .
                end.
            end .
        end.
        CBCType_ = 0.
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure proc-shift-open :
    do
        on error undo, return error
            :
        if get-chkc_context.cas-shft then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_get-cash-shift in g#libchkvl
  (input  buffer get-chkc_context:handle
  ,buffer buf_shift-cash
  ,input  pay-desk_
  ,input  shift-date_
  ,input  shift-name_
  ,input ?
  ,input shift-date_
  ,input shift-open-time_
  ,input 0
    ) no-error .
        end.
    end.
end procedure.
procedure proc-end :
    do
        on error undo, return error
            :
        define variable  prev-code2 as character no-undo .
        define variable netto-sum2_ as decimal no-undo .
        if v-to-delete[1] = no then do:
            get-chkc_context.ll = lll.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_getcheck in g#libchkvl
  (input  buffer get-chkc_context:handle
  ,input  'ДОБАВЛЕНИЕ':U
  ,input  ''
  ,input  yes
  ,input  yes
  ,input  netto-sum_
  ,input  lng-sub-d
  ,input  sub-d
  ,input  var-discnt-id
  ,input-output prev-code
    ) no-error .
                assign
                p-view-log = (p-view-log or get-chkc_context.view-log)
                lll = get-chkc_context.ll
                .
        end.
        if p-pos-type = 'MAGIA-XML':U
        and v-create-return-write-off
        and prev-code2 <> "":U
        then do:
            run proc-netto-2 in this-procedure (input prev-code
                ,input prev-code2
                ,output netto-sum2_).
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_getcheck in g#libchkvl
  (input  buffer get-chkc_context:handle
  ,input  'ДОБАВЛЕНИЕ':U
  ,input  ''
  ,input  yes
  ,input  yes
  ,input  netto-sum2_
  ,input  lng-sub-d
  ,input  sub-d
  ,input  var-discnt-id
  ,input-output prev-code2
    ) no-error .
                assign
                p-view-log = (p-view-log or get-chkc_context.view-log)
                lll = get-chkc_context.ll
                .
        end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libchkvl) <> true) then do:   run str/libchkvl.p persistent no-error .   if error-status :error or (valid-handle(g#libchkvl) <> true) then do:     message       "Error starting nws/libchkvl.p" skip       g#libchkvl skip       g#libchkvl :type skip       g#libchkvl :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libchkvl_getwcheck in g#libchkvl
  (input  buffer get-chkc_context:handle
  ,input  'ДОБАВЛЕНИЕ':U
  ,input  ''
  ,input  yes
  ,input  yes
  ,input  netto-sum_
  ,input-output mc-prev-code
    ) no-error .
            assign
            p-view-log = (p-view-log or get-chkc_context.view-log)
            lll = get-chkc_context.ll
            .
        assign
            prev-code = "":U
            prev-code2 = "":U
            mc-prev-code = "":U
            .
    end.
end procedure.
procedure proc-end-chk :
 DO on error undo, return error :
    FIND FIRST tt-chk-doc NO-ERROR.
    IF AVAILABLE tt-chk-doc THEN DO:
       FIND FIRST ub.chk-doc WHERE
                  ub.chk-doc.chk-id    = tt-chk-doc.chk-id
              AND ub.chk-doc.obj-code  = tt-chk-doc.obj-code
              AND ub.chk-doc.obj-type  = tt-chk-doc.obj-type
              AND ub.chk-doc.chk-date  = tt-chk-doc.chk-date
              AND ub.chk-doc.chk-time  = tt-chk-doc.chk-time
              AND ub.chk-doc.pay-desk  = tt-chk-doc.pay-desk
              AND ub.chk-doc.chk-num   = tt-chk-doc.chk-num
              AND ub.chk-doc.sales-man = tt-chk-doc.sales-man
              NO-LOCK  NO-ERROR.
       IF NOT AVAILABLE ub.chk-doc THEN DO:
          lll = lll + 1 .
          CREATE ub.chk-doc.
          buffer-copy tt-chk-doc to ub.chk-doc.
          FOR EACH tt-chk-doc-attr WHERE tt-chk-doc-attr.doc-code = tt-chk-doc.doc-code :
             CREATE ub.chk-doc-attr.
             buffer-copy tt-chk-doc-attr to ub.chk-doc-attr.
          END.
          FOR EACH tt-chk-gds WHERE tt-chk-gds.doc-code = tt-chk-doc.doc-code :
             CREATE ub.chk-gds.
             buffer-copy tt-chk-gds to ub.chk-gds.
             FOR EACH tt-chk-gds-attr WHERE tt-chk-gds-attr.doc-code = tt-chk-doc.doc-code
                                        AND tt-chk-gds-attr.line-num = tt-chk-gds.line-num :
                CREATE ub.chk-gds-attr.
                buffer-copy tt-chk-gds-attr to ub.chk-gds-attr.
             END.
             FOR EACH tt-chk-gds-pay WHERE tt-chk-gds-pay.doc-code = tt-chk-doc.doc-code
                                       AND tt-chk-gds-pay.b-code = tt-chk-gds.b-code :
                CREATE ub.chk-gds-pay.
                buffer-copy tt-chk-gds-pay to ub.chk-gds-pay.
             END.
          END.
          FOR EACH tt-chk-pay :
             CREATE ub.chk-pay.
             buffer-copy tt-chk-pay to ub.chk-pay.
             FOR EACH tt-chk-pay-attr  WHERE tt-chk-pay-attr.doc-code = tt-chk-pay.doc-code
                                         AND tt-chk-pay-attr.line-num = tt-chk-pay.line-num :
                CREATE ub.chk-pay-attr.
                buffer-copy tt-chk-pay-attr to ub.chk-pay-attr.
             END.
          END.
          FOR EACH tt-chk-discnt WHERE tt-chk-doc.doc-code = tt-chk-discnt.doc-code:
              CREATE ub.chk-discnt.
              buffer-copy tt-chk-discnt to ub.chk-discnt.
              FOR EACH tt-chk-discnt-attr WHERE tt-chk-discnt-attr.doc-code = tt-chk-discnt.doc-code
                                          AND   tt-chk-discnt-attr.line-num = tt-chk-discnt.line-num
                                          AND   tt-chk-discnt-attr.discnt-id = tt-chk-discnt.discnt-id
                                          :
                 FIND FIRST ub.chk-discnt-attr   WHERE
                            ub.chk-discnt-attr.doc-code         = tt-chk-discnt-attr.doc-code
                        AND ub.chk-discnt-attr.line-num         = tt-chk-discnt-attr.line-num
                        AND ub.chk-discnt-attr.record-type      = tt-chk-discnt-attr.record-type
                        AND ub.chk-discnt-attr.discnt-id        = tt-chk-discnt-attr.discnt-id
                        AND ub.chk-discnt-attr.object-line-num  = tt-chk-discnt-attr.object-line-num
                        AND ub.chk-discnt-attr.attr-code        = tt-chk-discnt-attr.attr-code
                        AND ub.chk-discnt-attr.attr-value       = tt-chk-discnt-attr.attr-value
                        AND ub.chk-discnt-attr.out-code         = tt-chk-discnt-attr.out-code
                  NO-ERROR .
                  IF NOT AVAILABLE ub.chk-discnt-attr THEN DO:
                     CREATE  ub.chk-discnt-attr .
                     buffer-copy tt-chk-discnt-attr to ub.chk-discnt-attr.
                  END.
              END.
          END.
          FOR EACH tt-cd-trans:
              find first ub.cd-trans no-lock where
                         ub.cd-trans.db-num = tt-cd-trans.db-num
                     and ub.cd-trans.trans-id = tt-cd-trans.trans-id
                     no-error.
              if not available ub.cd-trans then do:
                create ub.cd-trans.
                buffer-copy tt-cd-trans to ub.cd-trans.
              end.
          end.
          FOR EACH  tt-bar-code:
             CREATE ub.bar-code.
             buffer-copy tt-bar-code to ub.bar-code.
          END.
          FOR EACH  tt-marking-chk:
             find first ub.marking-chk exclusive-lock where
                        ub.marking-chk.mark      = tt-marking-chk.mark
                    and ub.marking-chk.doc-code  = tt-marking-chk.doc-code
                    and ub.marking-chk.line-num  = tt-marking-chk.line-num
                    no-error .
             if not available ub.marking-chk
             then
             CREATE ub.marking-chk.
             buffer-copy tt-marking-chk to ub.marking-chk.
          END.
       END.
       EMPTY TEMP-TABLE     tt-chk-doc.
       EMPTY TEMP-TABLE     tt-chk-doc-attr.
       EMPTY TEMP-TABLE     tt-chk-gds.
       EMPTY TEMP-TABLE     tt-chk-gds-attr.
       EMPTY TEMP-TABLE     tt-chk-gds-pay.
       EMPTY TEMP-TABLE     tt-chk-pay.
       EMPTY TEMP-TABLE     tt-chk-pay-attr.
       EMPTY TEMP-TABLE     tt-chk-discnt.
       EMPTY TEMP-TABLE     tt-chk-discnt-attr.
       EMPTY TEMP-TABLE     tt-bar-code.
       EMPTY TEMP-TABLE     tt-marking-chk.
       EMPTY TEMP-TABLE     tt-cd-trans.
    END.
 END.
end procedure.
procedure proc-inv :
    define variable i-code_ as character no-undo .
    define variable i-qnty_ as decimal no-undo .
    define variable i-place_ as integer no-undo .
    define variable lng-spl as integer no-undo .
    define variable v-line-type as character no-undo .
    define buffer buf_chk-gds for tt-chk-gds.
    define buffer buf_temp-temp for temp-temp.
    define buffer buf_chk-doc for tt-chk-doc.
    do
        on error undo, return error return-value
            :
        if not exist then do:
            if get-chkc_context.is-cdinv = yes then do:
                for each buf_temp-temp where
                    buf_temp-temp.record-name = "Invent":U
                        AND buf_temp-temp.id = v-id:
                    CASE buf_temp-temp.field-name:
                        when "ICode":U then do:
                            assign
                                i-code_ = buf_temp-temp.field-value
                                no-error .
                        end.
                        when "IQty":U then do:
                            assign
                                i-qnty_ = fdecimal(buf_temp-temp.field-value)
                                no-error .
                        end.
                        when "IPlace":U then do:
                            assign
                                i-place_ = integer(buf_temp-temp.field-value)
                                no-error .
                        end.
                        when "IString":U then do:
                            assign
                                lng-spl = integer(buf_temp-temp.field-value)
                                no-error .
                        end.
                        otherwise do:
                            error-status:error = no.
                        end.
                    END CASE.
                    if error-status:error then do:
                        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
                    end.
                    delete buf_temp-temp.
                end.
            end.
            assign
                time-oper_ =  (if p-pos-type = 'MAGIA-XML':U
                then (v-time modulo 86400)
                else string-IS0-8601-to-sec(v-time-char))
                no-error
                .
            FIND FIRST buf_chk-doc NO-ERROR.
            CREATE buf_chk-gds.
            assign
                buf_chk-gds.doc-code = buf_chk-doc.doc-code
                lng = lng + 1
                buf_chk-gds.line-num = (if lng-spl = 0 then - lng else lng-spl)
                buf_chk-gds.grp-code = 0
                buf_chk-gds.chk-date = buf_chk-doc.chk-date
                buf_chk-gds.src-code = i-code_
                buf_chk-gds.src-qnty = i-qnty_
                buf_chk-gds.src-discnt = 0
                buf_chk-gds.src-price = 0
                buf_chk-gds.doc-qnty = 0
                buf_chk-gds.price-service = 0
                buf_chk-gds.time-oper = time-oper_
                buf_chk-gds.is-error = no
                buf_chk-gds.doc-qnty = 0
                buf_chk-gds.pump = 0
                buf_chk-gds.road-tax = 0
                buf_chk-gds.line-sign = buf_chk-gds.src-qnty >= 0
                buf_chk-gds.line-type =  '':U
                .
        end.
    end.
end procedure.
procedure proc-bonus :
    define variable  bonus-obj_         as integer no-undo .
    define variable  bonus-trans-id_    as integer no-undo .
    define variable  bonus-card-no      as character no-undo .
    define variable  bonus-curr-code_   as integer no-undo .
    define variable  bonus-qty_         as decimal no-undo .
    define variable  bonus-reason_      as integer no-undo .
    define variable  bonus-type-chr_    as character no-undo .
    define variable  bonus-string       as integer no-undo .
    define variable  bonus-src-code_    as decimal no-undo .
    define variable  bonus-src-code-chr as character no-undo .
    define variable  bonus-relation     as character no-undo .
    define variable  i-bonus-relation   as integer   no-undo .
    define variable  dt-season          as integer   no-undo .
    define buffer buf_temp-temp for temp-temp .
    define buffer buf_chk-gds for tt-chk-gds.
    define buffer buf_chk-doc for tt-chk-doc.
    define buffer buf_chk-discnt for tt-chk-discnt.
    define buffer buf_chk-discnt-attr for tt-chk-discnt-attr.
    define variable local-netto-for-sub-d as decimal no-undo .
    do
        on error undo, return error
            :
        if not exist then do:
            for each buf_temp-temp where
                buf_temp-temp.record-name = "BonusAdd":U
                    AND buf_temp-temp.id = v-id:
                CASE buf_temp-temp.field-name:
                    when "BAString":U then do:
                        assign
                            bonus-string = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "BAobj":U then do:
                        assign
                            bonus-obj_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "BATransID":U then do:
                        assign
                            bonus-trans-id_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "BACurr":U then do:
                        assign
                            bonus-curr-code_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "BAReason":U then do:
                        assign
                            bonus-reason_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "Ltype":U then do:
                        assign
                            bonus-type-chr_ = buf_temp-temp.field-value
                            no-error .
                    end.
                    when "BAQty":U then do:
                        assign
                            bonus-qty_ = fdecimal(buf_temp-temp.field-value) / 100
                            no-error .
                    end.
                    when "BACardNo":U then do:
                        assign
                            bonus-card-no = buf_temp-temp.field-value
                            no-error .
                    end.
                    when "BARelation":U then do:
                        assign
                            bonus-relation = buf_temp-temp.field-value
                            no-error .
                    end.
                    otherwise do:
                        error-status:error = no.
                    end.
                END CASE.
                if error-status:error then do:
                    if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
                end.
                delete buf_temp-temp.
            end.
            FIND FIRST buf_chk-doc NO-ERROR.
            FIND FIRST buf_chk-gds NO-ERROR.
            create buf_chk-discnt.
            assign
                buf_chk-discnt.doc-code = buf_chk-doc.doc-code.
                buf_chk-discnt.record-type = 4.
                buf_chk-discnt.line-num = buf_chk-gds.line-num.
                buf_chk-discnt.discnt-id = (if bonus-trans-id_ = 0 then buf_chk-discnt.line-num else bonus-trans-id_).
                buf_chk-discnt.time-oper = buf_chk-gds.time-oper.
                buf_chk-discnt.line-type = (if bonus-type-chr_ = 'I' or bonus-type-chr_ = '0'
                then integer('1':U)
                else (if bonus-type-chr_ = 'T'
                then integer('2':U)
                else integer('0':U)
                )
                ).
                buf_chk-discnt.pass-discnt = bonus-obj_.
                buf_chk-discnt.value-type = integer('5':U).
                buf_chk-discnt.src-d-card = bonus-card-no .
                buf_chk-discnt.d-card = bonus-card-no .
                buf_chk-discnt.discnt-value-abs = bonus-qty_.
                buf_chk-discnt.discnt-value-pcnt = (if buf_chk-discnt.line-type = integer('1':U)
                then bonus-src-code_
                else 0).
                buf_chk-discnt.discnt-type = bonus-reason_.
                buf_chk-discnt.kateg = (if bonus-curr-code_ > 0
                then bonus-curr-code_
                else (if bonus-curr-code_ = kassa-rub-code
                then 0
                else -1 )
                ).
                buf_chk-discnt.object-line-num = (if bonus-string <= 0
                then bonus-string
                else buf_chk-gds.line-num).
                buf_chk-discnt.pay-desk = buf_chk-doc.pay-desk.
                buf_chk-discnt.obj-code = buf_chk-doc.obj-code.
                buf_chk-discnt.obj-type = buf_chk-doc.obj-type.
                buf_chk-discnt.chk-date = buf_chk-doc.chk-date.
                buf_chk-discnt.chk-time = buf_chk-doc.chk-time.
            if bonus-relation <> "" then do:
                dt-season = 0.
                i-bonus-relation = integer(bonus-relation) no-error.
                if not error-status:error then
                do:
                    run gds-attr_check-code-dt-seasons in this-procedure
                        (i-bonus-relation, shop-type, shop-code, output i-bonus-relation,output dt-season).
                    bonus-relation = string(i-bonus-relation).
                end.
                find first buf_chk-discnt-attr EXCLUSIVE-LOCK where buf_chk-discnt-attr.attr-code = "RRN-bonus"
                    and buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                    and buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                    and buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                    and buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num no-error .
                if AVAILABLE buf_chk-discnt-attr then do:
                    buf_chk-discnt-attr.attr-value = bonus-relation .
                end.
                else do:
                    create buf_chk-discnt-attr .
                    assign
                        buf_chk-discnt-attr.attr-code = "RRN-bonus"
                        buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                        buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                        buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                        buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                        buf_chk-discnt-attr.attr-value = bonus-relation
                        .
                end.
                if dt-season <> 0 then do:
                    find first buf_chk-discnt-attr EXCLUSIVE-LOCK where buf_chk-discnt-attr.attr-code = "SeasonDT"
                        and buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                        and buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                        and buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                        and buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num no-error .
                    if AVAILABLE buf_chk-discnt-attr then do:
                        buf_chk-discnt-attr.attr-value = string(dt-season) .
                    end.
                    else do:
                        create buf_chk-discnt-attr .
                        assign
                            buf_chk-discnt-attr.attr-code = "SeasonDT"
                            buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                            buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                            buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                            buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                            buf_chk-discnt-attr.attr-value = string(dt-season)
                            .
                    end.
                end.
            end.
            if buf_chk-discnt.line-type = integer('1':U) then do:
                if available buf_chk-gds
                and (bonus-src-code-chr = buf_chk-gds.src-code
                or bonus-string  = buf_chk-gds.line-num ) then do:
                end.
                else do:
                    for each buf_chk-gds no-lock where
                        buf_chk-gds.doc-code = buf_chk-doc.doc-code:
                        if buf_chk-gds.src-code = bonus-src-code-chr then do:
                            buf_chk-discnt.object-line-num = buf_chk-gds.line-num.
                            leave.
                        end.
                    end.
                end.
            end.
            if buf_chk-discnt.line-type = integer('2':U)
            and available buf_chk-gds
            and buf_chk-discnt.object-line-num = buf_chk-gds.line-num then do:
                assign
                    buf_chk-discnt.object-sum = local-netto-for-sub-d
                    buf_chk-discnt.discnt-value-pcnt = (if local-netto-for-sub-d <> 0
                    and (buf_chk-discnt.kateg = - 1
                    or buf_chk-discnt.kateg <> - 1
                    and (
                    (buf_chk-discnt.kateg = 0
                    and v-curr-r-b = 'rubl':U
                    )
                    or
                    (buf_chk-discnt.kateg = v-base-code
                    and v-curr-r-b = 'base':U)
                    ))
                    then bonus-qty_ / chk-gds.src-sum
                    else buf_chk-discnt.discnt-value-pcnt)
                    .
            end.
        end.
    end.
end procedure.
procedure proc-disc :
    define variable lnd-spl as integer no-undo .
    define buffer buf_temp-temp for temp-temp .
    define variable disc-sum_ as decimal no-undo .
    define variable disc-pcnt_ as decimal no-undo .
    define variable disc-reason_ as integer no-undo .
    define variable disc-vtype_ as integer no-undo .
    define variable disc-type_ as integer no-undo .
    define variable disc-mode_ as character no-undo .
    define variable disc-promo-id_ as character no-undo .
    define variable disc-sign_ as logical no-undo .
    define variable local-netto-for-sub-d as decimal no-undo .
    define buffer buf_chk-gds for tt-chk-gds.
    define buffer buf2_chk-gds for tt-chk-gds.
    define buffer buf_chk-gds-attr for tt-chk-gds-attr.
    define buffer buf2_chk-gds-attr for tt-chk-gds-attr.
    define buffer buf_chk-doc for tt-chk-doc.
    define buffer buf_chk-discnt for tt-chk-discnt.
    define buffer buf2_chk-discnt for tt-chk-discnt.
    define buffer buf_chk-discnt-attr for tt-chk-discnt-attr.
    define variable disc-gds-reason as int no-undo .
    do
        on error undo, return error
            :
            FIND FIRST buf_chk-doc NO-ERROR.
        if not exist then do:
            if  buf_chk-doc.chk-type = integer('8':U) then return.
            for each buf_temp-temp where
                buf_temp-temp.record-name = "CDisc":U
                    AND buf_temp-temp.id = v-id:
                CASE buf_temp-temp.field-name:
                    when "CDSum":U then do:
                        assign
                            disc-sum_ = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CDPersent":U then do:
                        assign
                            disc-pcnt_ = fdecimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CDString":U then do:
                        assign
                            lnd-spl = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CDReason":U then do:
                        assign
                            disc-reason_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CDRank":U then do:
                        assign
                            disc-type_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CDType":U then do:
                        assign
                            disc-sign_ = if integer(buf_temp-temp.field-value) = 1
                            or integer(buf_temp-temp.field-value) = 3
                            then no
                            else yes
                            no-error .
                    end.
                    when "CDVType":U then do:
                        assign
                            disc-vtype_ = (if buf_temp-temp.field-value = "P":U
                            then integer('1':U)
                            else (if buf_temp-temp.field-value = "A":U
                            then integer('2':U)
                            else (if buf_temp-temp.field-value = "G":U
                            then integer('14':U)
                            else integer('0':U)
                            )
                            )
                            )
                            no-error .
                    end.
                    when "CDMode":U then do:
                        assign
                            disc-mode_ = buf_temp-temp.field-value
                            no-error .
                    end.
                    when "CDCard":U then do:
                        assign
                            disc-d-card = buf_temp-temp.field-value
                            no-error .
                    end.
                    when "CDDoc":U then do:
                        assign
                            disc-gds-reason = int(buf_temp-temp.field-value)
                            no-error .
                        error-status:error = no.
                    end.
                    otherwise do:
                        error-status:error = no.
                    end.
                END CASE.
                if error-status:error then do:
                    if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
                end.
                delete buf_temp-temp.
            end.
            if disc-mode_ = "B":U  then return.
            if disc-mode_ <> 'T':U then do:
                find first buf_chk-gds where
                    buf_chk-gds.doc-code = buf_chk-doc.doc-code
                    AND buf_chk-gds.line-num = lnd-spl no-error .
                if disc-mode_ = 'I':U then do:
                    if not Available buf_chk-gds then do:
                        assign
                            p-view-log = yes.
                        run write-log-and-file in p-log-handle (
                            input 1
                            , input log-file-name
                            , input 1
                            , input substitute( "!!!Несуществующая строка чека &1 для скидки:&2" +
                            "номер чека на кассе &5 касса &6"
                            , lnd-spl
                            , chr(10)
                            , chk-num_
                            , pay-desk_
                            )).
                        return.
                    end.
                    if disc-reason_ = 15  then do:
                        find first buf_chk-gds-attr
                            where buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
                            and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
                            and buf_chk-gds-attr.attr-code = "CSPromo"
                            and can-do("1,6", buf_chk-gds-attr.attr-value)
                            no-error.
                        if avail buf_chk-gds-attr
                        then do:
                           find first buf2_chk-gds-attr
                                where buf2_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
                                  and buf2_chk-gds-attr.attr-code = "CSPromo"
                                  and can-do("2,4,5", buf2_chk-gds-attr.attr-value)
                            no-error.
                           if avail buf2_chk-gds-attr
                           then do:
                              find first buf2_chk-gds
                                   where buf2_chk-gds.doc-code  = buf2_chk-gds.doc-code
                                     and buf2_chk-gds.line-num  = buf2_chk-gds-attr.line-num
                                     no-error.
                              if avail buf2_chk-gds then
                                 disc-sum_ = disc-sum_ + buf2_chk-gds.src-sum.
                           end.
                           find first buf2_chk-gds-attr exclusive-lock where
                                      buf2_chk-gds-attr.doc-code = buf_chk-gds.doc-code
                                  and buf2_chk-gds-attr.line-num = buf_chk-gds.line-num
                                  and buf2_chk-gds-attr.attr-code = "CSPromoSum"
                                  no-wait no-error.
                           if locked buf2_chk-gds-attr then .
                           else do:
                              if not available buf2_chk-gds-attr
                              then
                              create buf2_chk-gds-attr.
                              assign
                                 buf2_chk-gds-attr.doc-code = buf_chk-gds.doc-code
                                 buf2_chk-gds-attr.line-num = buf_chk-gds.line-num
                                 buf2_chk-gds-attr.attr-code = "CSPromoSum"
                                 buf2_chk-gds-attr.attr-value =  string(-1 * disc-sum_)
                                 .
                              disc-sum_ = 0.
                              disc-pcnt_ = 0.
                           end.
                        end.
                    end.
                end.
                else if not (disc-mode_ = 'C':U or disc-mode_ = 'P':U) then do:
                    assign
                        p-view-log = yes.
                    run write-log-and-file in p-log-handle (
                        input 1
                        , input log-file-name
                        , input 1
                        , input substitute( "!!!Неопределенный тип скидки с № строки &1 в чеке:&2" +
                        "номер чека на кассе &3 касса &4&2" +
                        "скидка не будет обработана"
                        , lnd-spl
                        , chr(10)
                        , chk-num_
                        , pay-desk_
                        )).
                    return.
                end.
            end.
            if disc-mode_ = "T":U
            and lng > lnd-spl
            and (p-pos-type = 'IBM-XML':U
            or
            p-pos-type = 'Autotank':U
            )
            then do:
                for each buf_chk-gds no-lock where
                    buf_chk-gds.doc-code = buf_chk-doc.doc-code
                        and buf_chk-gds.line-num <= lnd-spl:
                    if buf_chk-doc.chk-type = integer('17':U) then do:
                        assign
                            local-netto-for-sub-d = local-netto-for-sub-d + (if v-is-petrol-check then 0
                            else (buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty)
                            .
                    end.
                    else  do:
                        assign
                            local-netto-for-sub-d = local-netto-for-sub-d + (if (buf_chk-gds.write-off-code = ?
                            or buf_chk-gds.write-off-code <= 0)
                            and not v-is-petrol-check
                            then
                            ((buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty)
                            else 0)
                            .
                    end.
                end.
            end.
            else do:
                local-netto-for-sub-d = netto-for-sub-d.
            end.
            if disc-reason_ = 15 then do:
                disc-promo-id_ = disc-d-card.
                disc-d-card  = '':U.
            end.
            create buf_chk-discnt.
            assign
                buf_chk-discnt.doc-code = buf_chk-doc.doc-code
                buf_chk-discnt.record-type = if disc-mode_ = "C":U then 10 else 0
                buf_chk-discnt.discnt-id = (var-discnt-id + 1)
                buf_chk-discnt.time-oper = v-time
                buf_chk-discnt.line-type = (if disc-mode_ = "I":U
                then integer('1':U)
                else (if disc-mode_ = "T":U or (disc-mode_ = "P":U and disc-reason_ = 16)
                then integer('2':U)
                else integer('0':U)
                )
                )
                kriv3 = (if disc-mode_ = "T"
                and p-pos-type = 'IBM-XML':U
                then yes
                else kriv3 )
                buf_chk-discnt.line-sign =   disc-sign_
                buf_chk-discnt.pass-discnt = integer('0':U)
                buf_chk-discnt.value-type = if disc-vtype_ = 0
                then integer('0':U)
                else disc-vtype_
                buf_chk-discnt.src-d-card = (if available buf_chk-gds
                then buf_chk-gds.src-d-card
                else (if available buf_chk-gds
                then buf_chk-gds.src-d-card
                else '')
                )
                buf_chk-discnt.d-card = (if available buf_chk-gds
                then  buf_chk-gds.d-card
                else (if available buf_chk-gds
                then buf_chk-gds.d-card
                else '')
                )
                buf_chk-discnt.d-card = (if disc-d-card = "" or disc-d-card = ? then buf_chk-discnt.d-card else disc-d-card)
                buf_chk-discnt.discnt-value-abs = - disc-sum_
                buf_chk-discnt.discnt-value-pcnt = (if p-pos-type = 'IBM-XML':U then (- disc-pcnt_) else disc-pcnt_)
                buf_chk-discnt.object-line-num = lnd-spl
                buf_chk-discnt.pay-desk = buf_chk-doc.pay-desk
                buf_chk-discnt.obj-code = buf_chk-doc.obj-code
                buf_chk-discnt.obj-type = buf_chk-doc.obj-type
                buf_chk-discnt.chk-date = buf_chk-doc.chk-date
                buf_chk-discnt.chk-time = buf_chk-doc.chk-time
                buf_chk-discnt.shift-date = buf_chk-doc.shift-date
                buf_chk-discnt.shift-num = buf_chk-doc.shift-num
                buf_chk-discnt.object-qnty = (if buf_chk-discnt.line-type = integer('2':U)
                or not available buf_chk-gds
                then accum-src-for-sub-d
                else buf_chk-gds.src-qnty)
                buf_chk-discnt.object-sum = (if buf_chk-discnt.line-type = integer('2':U)
                or not available buf_chk-gds
                then  local-netto-for-sub-d
                else buf_chk-gds.src-sum)
                var-discnt-id = var-discnt-id + 1
                sub-d = (if buf_chk-discnt.line-type = integer('2':U) then (sub-d - disc-sum_) else sub-d)
                buf_chk-discnt.promo-id = disc-promo-id_
                buf_chk-discnt.templ-rl-root = disc-gds-reason
                .
            if buf_chk-discnt.line-type = integer('2':U) then do:
                buf_chk-discnt.line-num = (if p-pos-type = 'IBM-XML':U
                    then lnd-spl
                    else (if available buf_chk-gds then buf_chk-gds.line-num else 0)
                    ).
            end.
            else do:
                buf_chk-discnt.line-num = (if p-pos-type = 'IBM-XML':U
                    then lnd-spl
                    else (if available buf_chk-gds then buf_chk-gds.line-num else 0)
                    ).
            end.
            if disc-promo-id_ <> "" then do:
                create buf_chk-discnt-attr .
                assign
                    buf_chk-discnt-attr.attr-code = "promo-id"
                    buf_chk-discnt-attr.attr-value = disc-promo-id_
                    buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                    buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                    buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                    buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                    buf_chk-discnt-attr.record-type = buf_chk-discnt.record-type
                    .
            end.
            if disc-gds-reason <> ? then do:
                create buf_chk-discnt-attr .
                assign
                    buf_chk-discnt-attr.attr-code = "gds-reason"
                    buf_chk-discnt-attr.attr-value = string(disc-gds-reason)
                    buf_chk-discnt-attr.discnt-id = buf_chk-discnt.discnt-id
                    buf_chk-discnt-attr.doc-code = buf_chk-discnt.doc-code
                    buf_chk-discnt-attr.line-num = buf_chk-discnt.line-num
                    buf_chk-discnt-attr.object-line-num = buf_chk-discnt.object-line-num
                    buf_chk-discnt-attr.record-type = buf_chk-discnt.record-type
                    .
            end.
            if buf_chk-discnt.record-type <> 10
            then netto-for-sub-d =  netto-for-sub-d - buf_chk-discnt.discnt-value-abs
                .
            if available buf_chk-gds  and buf_chk-discnt.record-type <> 10 then
            do:
              if buf_chk-discnt.line-type <> integer('2':U)
                and buf_chk-discnt.value-type = integer('1':U)
                and buf_chk-discnt.discnt-value-pcnt = 100
              then do:
                 buf_chk-gds.src-discnt = buf_chk-gds.src-price.
              end.
              else if buf_chk-discnt.line-type <> integer('2':U)
              then do:
                 buf_chk-gds.src-discnt = buf_chk-gds.src-discnt + buf_chk-discnt.discnt-value-abs / buf_chk-gds.src-qnty.
              end.
            end.
            assign
                buf_chk-discnt.discnt-type = if disc-reason_ > 0 or disc-type_ > 0
                then convert-discount(disc-reason_, disc-type_, buf_chk-discnt.line-type)
                else integer('0':U)
                .
            if buf_chk-discnt.record-type = 10 then buf_chk-discnt.rank = disc-type_.
            if kriv3 = yes
            and disc-mode_ = "I" then do:
                for each buf2_chk-discnt where
                    buf2_chk-discnt.doc-code = buf_chk-discnt.doc-code
                        AND buf2_chk-discnt.line-type = integer('2':U)
                        and buf2_chk-discnt.line-num >= buf_chk-discnt.object-line-num:
                    assign
                        buf2_chk-discnt.object-sum = buf2_chk-discnt.object-sum - buf_chk-discnt.discnt-value-abs.
                end.
            end.
        end.
        assign
            disc-d-card = "".
    end.
end procedure.
procedure proc-magia-discnt :
    define input parameter p-d-pcnt as decimal no-undo .
    define input parameter p-d-sum as decimal no-undo .
    define input parameter p-type as integer no-undo .
    do
        on error undo, return error
            :
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
            ub.chk-discnt.discnt-type = p-type
            ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
            ub.chk-discnt.discnt-value-abs = (if p-d-sum <> 0
            then p-d-sum
            else 0)
            ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
            ub.chk-discnt.object-sum = ub.chk-gds.src-sum
            ub.chk-discnt.discnt-value-pcnt =
            if ub.chk-gds.src-sum <> 0 and p-d-pcnt <> 0
            then  p-d-pcnt
            else (if ub.chk-gds.src-sum <> 0
            then ub.chk-discnt.discnt-value-abs / ub.chk-gds.src-sum * 100
            else 0)
            ub.chk-discnt.object-line-num = ub.chk-gds.line-num
            ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
            ub.chk-discnt.obj-code = ub.chk-doc.obj-code
            ub.chk-discnt.obj-type = ub.chk-doc.obj-type
            ub.chk-discnt.chk-date = ub.chk-doc.chk-date
            ub.chk-discnt.chk-time = ub.chk-doc.chk-time
            ub.chk-gds.src-discnt =   ub.chk-gds.src-discnt + ub.chk-discnt.discnt-value-abs / ub.chk-gds.src-qnty
            var-discnt-id = var-discnt-id + 1
            .
    end.
end procedure.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile: getxibm3.i $ $Revision: cd82ba7bd738, 2912, rls $".
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function  gettegjson returns character
(istr  as char,
 iteg  as char):
    define variable vpos as integer no-undo.
   istr = left-trim (istr,"~{") .
   iteg = '"' + iteg + '"'  .
   vpos = index (istr,iteg) + 1.
   if vpos eq 1
   then
      return "".
   istr = trim(substring (istr,vpos + length(iteg))).
   if istr begins '"'
   then return trim(right-trim(entry(1,istr),"~}"),'"').
   else do:
      define variable vbeg as integer no-undo.
      define variable vbegpos as integer no-undo  init 1.
      define variable vend as integer no-undo.
      define variable vCol as integer no-undo.
      vbeg  = index (istr,"~{",vbegpos).
      vend  = index (istr,"~}",vbegpos).
      if vbeg < vend
      then do:
         vCol = 1.
         vbegpos = vbeg + 1.
         block-str:
         do while vCol > 0:
            vbeg  = index (istr,"~{",vbegpos).
            vend  = index (istr,"~}",vbegpos).
            if vbeg < vend
               and vbeg  ne 0
            then assign
               vbegpos = vbeg + 1
               vcol    = vcol + 1
            .
            else do:
               if vend eq 0
               then
                  leave block-str.
               assign
                  vbegpos = vend + 1
                  vcol    = vcol - 1
               .
            end.
         end.
         if vcol eq 0
         then do:
            istr = substring(istr,1,vbegpos - 1).
            return istr.
         end.
      end.
      else
      return istr.
   end.
end.
procedure proc-03 :
define input parameter par-mode as integer no-undo .
define input parameter loc-exist as logical no-undo .
define variable lnp-spl as integer no-undo .
define buffer buf_temp-temp for temp-temp.
define buffer buf_chk-doc for tt-chk-doc.
define buffer buf_chk-doc-attr for tt-chk-doc-attr.
define buffer buf_chk-pay for tt-chk-pay.
define buffer buf_chk-pay-attr for tt-chk-pay-attr.
define variable i-cpdoc      as int no-undo.
define variable c-attr-code   as character no-undo.
define variable c-attr-value  as character no-undo.
define variable vCPAgreement  as character no-undo.
define variable vCPWithdrawal as character no-undo.
define variable vsbpstat as character no-undo.
define variable vsbprrn as character no-undo.
define variable vqrpay  as character no-undo.
  _proc-03:
  do
  on error undo, return error
  :
    if not loc-exist then do:
      pay-card_ = "".
      for each buf_temp-temp where
              buf_temp-temp.record-name = "CPay":U
        and buf_temp-temp.id = v-id:
        CASE buf_temp-temp.field-name:
          when "CPCode":U then do:
            if p-pos-type = 'IBM-XML':U
            then do:
              if integer(buf_temp-temp.field-value) = ibm-ccm then do:
                   assign pay_code = 1
                   c-attr-code  = "IBM-CCM".
                   c-attr-value = 'yes'.
              end.
              else assign pay_code = integer(buf_temp-temp.field-value)      no-error .
            end.
            else do:
              assign
              pay_code = convert-pay-code(p-pos-type, integer(buf_temp-temp.field-value), output curr_code)
              no-error .
            end.
          end.
          when "CPCurr":U then do:
            if p-pos-type = 'IBM-XML':U
            then
            assign
            curr_code = if kassa-rub-code = integer(buf_temp-temp.field-value)
                        then 0
                        else integer(buf_temp-temp.field-value)
            no-error .
            if p-pos-type = 'Autotank':U then do:
              assign
              curr_code = 0 no-error.
            end.
          end.
          when "CPTotal":U then do:
            assign
            tot_sum = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPCard":U then do:
            assign
            pay-card_ = trim(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPRate":U then do:
            assign
            cass-rate = fdecimal(buf_temp-temp.field-value)
            rate-por = 0
            no-error .
          end.
          when "CPCBR":U then do:
            assign
            bank-rate_ = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPMCBR":U then do:
            assign
            bank-scale_ = integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPString":U then do:
            assign
            lnp-spl = integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPSHandCard":u then do:
            assign
            pass-pay_ =   (if integer(buf_temp-temp.field-value) = 1
                          then 1
                          else 0)
            no-error .
          end.
          when "CPDOC":U then do:
            do i-cpdoc = 1 to num-entries(buf_temp-temp.field-value,',':U):
                if num-entries(entry(i-cpdoc,buf_temp-temp.field-value),'=':U) >= 2 then do:
                    c-attr-code  = entry(1,entry(i-cpdoc,buf_temp-temp.field-value,','),'=':U).
                    c-attr-value = entry(2,entry(i-cpdoc,buf_temp-temp.field-value,','),'=':U).
                end.
              else do:
                    c-attr-code  = "CPDOC".
                    c-attr-value = entry(i-cpdoc,buf_temp-temp.field-value,',').
              end.
            end.
          end.
          when "CPAgreement" then do:
             vCPAgreement = buf_temp-temp.field-value.
          end.
          when "CPMisc" then do:
             vsbpstat = gettegjson(buf_temp-temp.field-value,"SBpStat").
             vsbprrn  = gettegjson(buf_temp-temp.field-value,"SBPRRN").
             vqrpay   = gettegjson(buf_temp-temp.field-value,"QRPay").
          end.
          when "CPWithdrawal" then do:
             vCPWithdrawal = buf_temp-temp.field-value.
          end.
          otherwise do:
            error-status:error = no.
          end.
        END CASE.
        if error-status:error then do:
          if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
        end.
        delete buf_temp-temp.
      end.
      assign
      time-oper_ =  v-time
      no-error
      .
      if error-status:error then do:
        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
      end.
      find first buf_chk-doc NO-ERROR.
      find first buf_chk-pay-attr where
            buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
        and buf_chk-pay-attr.line-num   = lnp-spl
        and buf_chk-pay-attr.attr-code  = 'RTA_RefundExport' no-error.
      if available buf_chk-pay-attr then do:
        assign
          buf_chk-pay-attr.attr-value = buf_chk-pay-attr.attr-value + c-attr-value
          no-error.
        leave _proc-03.
      end.
      CASE par-mode:
        when 0
        or when 1
        then do:
          FIND buf_chk-pay WHERE
                buf_chk-pay.doc-code = buf_chk-doc.doc-code
            AND buf_chk-pay.curr-code = curr_code
            AND buf_chk-pay.pay-code = pay_code
            and buf_chk-pay.line-num = lnp-spl
            NO-ERROR.
          if NOT available buf_chk-pay
          then  do:
            CREATE buf_chk-pay .
            assign
            buf_chk-pay.doc-code = buf_chk-doc.doc-code
            buf_chk-pay.line-num = lnp-spl
            buf_chk-pay.chk-date = buf_chk-doc.chk-date
            buf_chk-pay.obj-code = shop-code
            buf_chk-pay.obj-type = shop-type
            buf_chk-pay.tot-rubl = 0
            buf_chk-pay.tot-sum  = 0
            buf_chk-pay.tot-base = 0
            buf_chk-pay.pay-code = pay_code
            buf_chk-pay.curr-code = curr_code
            buf_chk-pay.time-oper = time-oper_
            cass-rate = cass-rate * exp( 10, int( rate-por ) )
            buf_chk-pay.cash-rate = cass-rate
            buf_chk-pay.bank-rate = bank-rate_
            buf_chk-pay.bank-scale = bank-scale_
            buf_chk-pay.pass-pay  = pass-pay_
            buf_chk-pay.pay-card  = pay-card_
            buf_chk-pay.line-type = "":U
            buf_chk-pay.line-sign = (if buf_chk-doc.chk-type = integer('1':U)
                                then (buf_chk-pay.tot-sum >= 0)
                                else (buf_chk-pay.tot-sum <= 0)
                                )
            buf_chk-pay.is-error = no
            .
            assign
              pay-card_ = "".
            if not (c-attr-code = "" or c-attr-code = ?) then do:
              create buf_chk-pay-attr.
              assign
              buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
              buf_chk-pay-attr.line-num   = lnp-spl
              buf_chk-pay-attr.attr-code  = c-attr-code
              buf_chk-pay-attr.attr-value = c-attr-value
              no-error.
            end.
            if vCPAgreement ne "" and vCPAgreement ne ?
            then do:
              create buf_chk-pay-attr.
              assign
              buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
              buf_chk-pay-attr.line-num   = lnp-spl
              buf_chk-pay-attr.attr-code  = "CPAgreement"
              buf_chk-pay-attr.attr-value = vCPAgreement
              no-error.
            end.
            if vsbpstat ne "" and vsbpstat ne ?
            then do:
               create buf_chk-pay-attr.
               assign
               buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
               buf_chk-pay-attr.line-num   = lnp-spl
               buf_chk-pay-attr.attr-code  = "SBPStat"
               buf_chk-pay-attr.attr-value = vsbpstat
               no-error.
            end.
            if vsbprrn ne "" and vsbprrn ne ?
            then do:
               create buf_chk-pay-attr.
               assign
               buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
               buf_chk-pay-attr.line-num   = lnp-spl
               buf_chk-pay-attr.attr-code  = "SBPRRN"
               buf_chk-pay-attr.attr-value = vsbprrn
               no-error.
            end.
            if vqrpay ne "" and vqrpay ne ?
            then do:
               create buf_chk-pay-attr.
               assign
               buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
               buf_chk-pay-attr.line-num   = lnp-spl
               buf_chk-pay-attr.attr-code  = "QRPay"
               buf_chk-pay-attr.attr-value = vqrpay
               no-error.
            end.
            if vCPWithdrawal ne "" and vCPWithdrawal ne ? and dec(vCPWithdrawal) ne 0
            then do:
              create buf_chk-pay-attr.
              assign
              buf_chk-pay-attr.doc-code   = buf_chk-doc.doc-code
              buf_chk-pay-attr.line-num   = lnp-spl
              buf_chk-pay-attr.attr-code  = "CPWithdrawal"
              buf_chk-pay-attr.attr-value = left-trim(string (dec(vCPWithdrawal),">>>>>>>>>>>9.99") )
              no-error.
            end.
          end.
          assign
          buf_chk-pay.tot-sum = buf_chk-pay.tot-sum + tot_sum
          .
        end.
      END CASE.
    end.
  end.
end procedure.
procedure proc-cash :
define input parameter loc-exist as logical no-undo .
define variable par-val_ as decimal no-undo .
define variable lnp-spl as integer no-undo .
define variable tot_rubl as decimal no-undo .
define variable tot_base as decimal no-undo .
define buffer buf_temp-temp for temp-temp.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-pay for ub.chk-pay.
  do
  on error undo, return error
  :
    if not loc-exist then do:
      for each buf_temp-temp where
              buf_temp-temp.record-name = "Cash":U
        AND buf_temp-temp.id = v-id:
        CASE buf_temp-temp.field-name:
          when "CSValue":U then do:
            assign
            tot_sum = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CCCode":U then do:
            assign
            curr_code = if kassa-rub-code = integer(buf_temp-temp.field-value)
                        then 0
                        else integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CAMount":U then do:
            assign
            curr-string-qnty = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CValue":u then do:
            assign
            par-val_ =   fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPString":u then do:
            assign
            lnc =   integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CString":u then do:
            assign
            lnp-spl =   integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CPayCode":U then do:
            if p-pos-type = 'IBM-XML':U
            or p-pos-type = 'Autotank':U
            then do:
              assign
              pay_code = integer(buf_temp-temp.field-value)
              no-error .
            end.
          end.
          when "CCCode":U then do:
            if p-pos-type = 'IBM-XML':U
            or p-pos-type = 'Autotank':U
            then
            assign
            curr_code = if kassa-rub-code = integer(buf_temp-temp.field-value)
                        then 0
                        else integer(buf_temp-temp.field-value)
            no-error .
          end.
          when "CRate":U then do:
            assign
            rate-por = 0
            cass-rate = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CSBase" then do:
            assign
            tot_base = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          when "CSNat" then do:
            assign
            tot_rubl = fdecimal(buf_temp-temp.field-value)
            no-error .
          end.
          otherwise do:
            error-status:error = no.
          end.
        END CASE.
        if error-status:error then do:
          if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
        end.
        delete buf_temp-temp.
      end.
      assign
      time-oper_ =  v-time
      no-error
      .
      find first buf_chk-doc no-error.
      if par-val_ = 0
      and buf_chk-doc.chk-type = integer('7':U) then do:
      end.
      else do:
      FIND buf_chk-pay WHERE
            buf_chk-pay.doc-code = buf_chk-doc.doc-code
        AND buf_chk-pay.curr-code = curr_code
        AND buf_chk-pay.pay-code = pay_code
        and buf_chk-pay.line-num = lnp-spl
        and buf_chk-pay.src-val = par-val_
        NO-ERROR.
      if NOT available buf_chk-pay then  do:
        CREATE buf_chk-pay .
        assign
        buf_chk-pay.doc-code = buf_chk-doc.doc-code
        buf_chk-pay.line-num = lnp-spl
        buf_chk-pay.chk-date = buf_chk-doc.chk-date
        buf_chk-pay.obj-code = shop-code
        buf_chk-pay.obj-type = shop-type
        buf_chk-pay.tot-rubl = 0
        buf_chk-pay.tot-sum = 0
        buf_chk-pay.tot-base = 0
        buf_chk-pay.pay-code = pay_code
        buf_chk-pay.curr-code = curr_code
        buf_chk-pay.time-oper = time-oper_
        cass-rate = cass-rate * exp( 10, int( rate-por ) )
        buf_chk-pay.cash-rate = cass-rate
        buf_chk-pay.bank-rate = 1
        buf_chk-pay.bank-scale = 1
        buf_chk-pay.pass-pay = 1
        buf_chk-pay.pay-card = ''
        buf_chk-pay.line-type = "":U
        buf_chk-pay.line-sign = (if buf_chk-doc.chk-type = integer('2':U)
                              or buf_chk-doc.chk-type =  integer('5':U
                              )
                            then (buf_chk-pay.tot-sum <= 0)
                            else (buf_chk-pay.tot-sum >= 0)
                            )
        buf_chk-pay.is-error = no
        .
      end.
      assign
      buf_chk-pay.tot-sum = buf_chk-pay.tot-sum + (if par-val_ = 0
                                     then tot_sum
                                     else 0)
      .
      if par-val_ > 0
      or curr-string-qnty <> 0 then do:
        assign
        buf_chk-pay.src-qnty = curr-string-qnty
        buf_chk-pay.src-val  = par-val_
        buf_chk-pay.tot-sum = par-val_ * curr-string-qnty
        .
      end.
      end.
    end.
  end.
end procedure.
procedure cb-xmlparse-tag-start-check :
    define input parameter p-parameter as character no-undo .
    do
        on error undo, return error
            :
        if v-is-spool-file
        and
        v-start-check = 0 then do:
            assign
                v-start-check = v-start-check + 1
                .
        end.
        else do:
            if v-is-spool-file then do:
                run write-log-and-file in p-log-handle (
                    input 1
                    , input log-file-name
                    , input 1
                    , input substitute( "!!!Тэг Check не закрыт - чек не завершен перед строкой &1", var-file-line-num)).
                assign
                    p-view-log = yes
                    .
            end.
        end.
    end.
end procedure.
procedure cb-xmlparse-tag-end-check :
    define input parameter p-parameter as character no-undo .
    do
        on error undo, return error
            :
        if v-start-check =  1 then do:
            assign
                v-start-check = 0
                .
            run proc-end-chk in this-procedure no-error .
            run proc-end in this-procedure no-error .
        end.
        else do:
            assign
                v-start-check = v-start-check - 1
                .
        end.
    end.
end procedure.
PROCEDURE cb-xmlvalid-procedure-not-found :
    do
        on error undo, return error
            :
        define input parameter p-type       as character    no-undo.
        define input parameter p-value      as character    no-undo.
        define input parameter p-parameters as character    no-undo.
        define variable v-id-loc as character no-undo .
        define variable v-time-loc as integer no-undo .
        define variable v-time-loc-char as character no-undo .
        define variable v-group-loc as character no-undo .
        define variable v-key-char as character no-undo .
        define buffer first_temp-temp for temp-temp.
        define buffer slave_temp-temp for temp-temp.
        define buffer buf_cash-desk-attr for ub.cash-desk-attr .
        define buffer buf_chk-pay-attr for tt-chk-pay-attr.
        define buffer buf_chk-pay for tt-chk-pay.
        case p-type
            :
            when "tag-end" then do:
                CASE p-value:
                    when "CHead":U then do:
                        if v-start-check = 1 then
                            run proc-00 in this-procedure no-error .
                    end.
                    when "CACHistory":U then do:
                        run proc-ach in this-procedure ( input exist) no-error .
                    end.
                    when "CBarCode":U then do:
                        CBCType_= 0.
                        CBCString_ = 0.
                        CBCBarcode_ = "".
                        if v-start-check = 1 then
                            run proc-02-gds in this-procedure no-error .
                    end.
                    when "CAuthorization":U then do:
                        AuthType_ = 0.
                        qr-alchol_ = "".
                        if v-start-check = 1 then
                            run proc-CAuthorization in this-procedure no-error .
                    end.
                    when "ACHData":U then do:
                        run proc-ach-data in this-procedure no-error.
                    end.
                    when "ACHExp":U then do:
                        run proc-ach-exp in this-procedure no-error.
                    end.
                    when "CFReg":U then do:
                        if get-chkc_context.z-check then do:
                            run proc-cfreg in this-procedure no-error.
                        end.
                        else do:
                            error-status:error = no.
                        end.
                    end.
                    when "CSale":U then do:
                        if v-start-check = 1 then
                        CASE gbl-type:
                            when "1" or
                            when "6" or
                            when "8" or
                            when "14" or
                            when "15" or
                            when "16" or
                            when "17" or
                            when "36" or
                            when "43" or
                            when "44"
                            then do:
                                run proc-01-gds in this-procedure no-error .
                            end.
                            when "4" then do:
                                run proc-01-wth in this-procedure no-error .
                            end.
                            otherwise do:
                            end.
                        END CASE.
                    end.
                    when "CPay":U then do:
                        if v-start-check = 1 then
                        do:
                            run proc-03 in this-procedure (input (if gbl-type = "4" then 1 else 0)
                                , input (if gbl-type = "4" then mc-exist else exist)
                                ) no-error .
                            if p-pos-type = 'Autotank':U and autotank-sum-return < 0  then
                            do:
                                run create-temp-table-record( input v-record-name, input "CPCode", input  "0")  .
                                run create-temp-table-record( input v-record-name, input "CPTotal", input  string(autotank-sum-return))  .
                                run create-temp-table-record( input v-record-name, input "CPString", input  "2")  .
                                run proc-03 in this-procedure (input (if gbl-type = "4" then 1 else 0)
                                    , input (if gbl-type = "4" then mc-exist else exist)
                                    ) no-error .
                                find first buf_chk-pay no-error.
                                if available buf_chk-pay
                                then do:
                                    create buf_chk-pay-attr.
                                    assign buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                                        buf_chk-pay-attr.line-num = 2
                                        buf_chk-pay-attr.attr-code = "autotank-sum-return"
                                        buf_chk-pay-attr.attr-value = string(autotank-sum-return)
                                        autotank-sum-return = 0
                                        .
                                end.
                            end .
                        end .
                    end.
                    when "BonusAdd":U then do:
                        if v-start-check = 1 then
                            run proc-bonus in this-procedure no-error .
                    end.
                    when "CPromo":U then do:
                        if v-start-check = 1 then
                            run proc-promo in this-procedure no-error .
                    end.
                    when "CDisc":U then do:
                        if v-start-check = 1 then
                            run proc-disc in this-procedure no-error .
                    end.
                    when "Param":U then do:
                        run proc-Parameter in this-procedure no-error .
                    end.
                    when "FuelPump":U then do:
                        run proc-FuelPump in this-procedure no-error .
                    end.
                    when "Invent":U then do:
                        if v-start-check = 1 then
                            run proc-inv in this-procedure no-error .
                    end.
                    when "Cash":U then do:
                        if v-start-check = 1 then
                            run proc-cash in this-procedure (input mc-exist) no-error .
                    end.
                    when "CFiscal":U then do:
                        if v-start-check = 1 then do:
                            if get-chkc_context.z-check then do:
                                run proc-cfiscal in this-procedure ( input exist) no-error .
                            end.
                            else do:
                                error-status:error = no.
                            end.
                        end.
                    end.
                    when "Advance":U then do:
                    end.
                    when "DocumentName":U
                    or
                    when "DateFormat":U
                    or
                    when "DocumentVersion":U
                    or
                    when "objList":U then do:
                        run fill-doc-property in this-procedure (
                            input p-value
                            , input v-xmlvalid-tag-value
                            ) no-error .
                        if error-status :error
                        then do:
                            assign
                                p-view-log = yes
                                .
                            run write-log-and-file in p-log-handle (
                                input 1
                                , input log-file-name
                                , input 1
                                , input substitute( "!!!При обработке файла &1 произошла ошибка при чтении свойств документа XML: &2"
                                , file_
                                , return-value
                                )
                                ).
                            assign
                                p-view-log = yes
                                .
                            return "error":U.
                        end.
                    end.
                    otherwise do:
                        run create-temp-table-record( input v-record-name, input p-value, input  v-xmlvalid-tag-value) no-error .
                        if error-status :error
                        then do:
                            run write-log-and-file in p-log-handle (
                                input 1
                                , input log-file-name
                                , input 1
                                , input substitute( "!!!При обработке файла &1 произошла ошибка при чтении записей документа XML: &2"
                                , file_
                                , return-value
                                )
                                ).
                            assign
                                p-view-log = yes
                                .
                            return "error":U.
                        end.
                    end.
                end CASE.
            end.
            when "tag-start" then do:
                CASE p-value:
                    when "CHead":U
                    or
                    when "CBarCode":U
                    or
                    when "CAuthorization":U
                    or
                    when "CSale":U
                    or
                    when "CPay":U
                    or
                    when "CDisc":U
                    or
                    when "BonusAdd":U
                    or
                    when "CPromo":U
                    or
                    when "BonusAdd":U
                    or
                    when "Invent":U
                    or
                    when "Cash":U
                    or
                    when "Advance":U
                    or
                    when "CACHistory"
                    or
                    when "ACHData"
                    or
                    when "ACHExp"
                    or
                    when "CFReg"
                    or
                    when "CFiscal"
                    then do:
                        if p-value = "CACHistory" then do:
                            define buffer buf_achd for achd.
                            define buffer buf_ache for ache.
                            for each buf_achd:
                                delete buf_achd.
                            end.
                            for each buf_ache:
                                delete buf_ache.
                            end.
                        end.
                        if v-start-check = 1 then do:
                            assign
                                v-record-name = p-value
                                .
                            if  not (p-value = "ACHData"
                            or
                            p-value = "ACHExp"
                            or
                            p-value = "CFReg"
                            ) then do:
                                assign
                                    CRI = 0
                                    CRAI = 0
                                    .
                                assign
                                    v-id-loc = ?
                                    v-time-loc = ?
                                    v-time-loc-char = ?
                                    v-id-loc = cb-xmlparse-get-attr(
                                    input this-procedure:handle
                                    ,input p-value
                                    ,input p-parameters
                                    ,input "id":U
                                    ,input yes)
                                    v-time-loc-char = cb-xmlparse-get-attr(
                                    input this-procedure:handle
                                    ,input p-value
                                    ,input p-parameters
                                    ,input "time":U
                                    ,input no)
                                    v-time-loc   = if p-pos-type = 'MAGIA-XML':U then integer(v-time-loc-char) else v-time-loc
                                    no-error
                                    .
                            end.
                            if (p-value <> "CHead":U
                            and
                            v-id-loc <> v-id
                            and p-value <> "ACHData" and p-value <> "ACHExp" and p-value <> "CFReg"
                            ) then do:
                                assign
                                    v-start-check = v-start-check - 1
                                    .
                                run write-log-and-file in p-log-handle (
                                    input 1
                                    , input log-file-name
                                    , input 1
                                    , input substitute( "!!!Тэг &1 - атрибут id=&2 не равен соответствующему атрибуту тэга Check - нарушен порядок данных"
                                    ,p-value
                                    ,v-id-loc
                                    )
                                    ).
                                assign
                                    v-cd-fatal-error = yes
                                    v-cd-fatal-message = "нарушение протокола обмена"
                                    p-view-log = yes
                                    .
                                return "error".
                            end.
                            if  (v-id-loc = ?
                            and
                            not (p-value = "ACHData"
                            or
                            p-value = "ACHExp"
                            or
                            p-value = "CFReg"
                            )
                            )
                            or (v-time-loc-char = ?
                            and p-value = "CHead":U)
                            then do:
                                assign
                                    v-start-check = v-start-check - 1
                                    .
                                run write-log-and-file in p-log-handle (
                                    input 1
                                    , input log-file-name
                                    , input 1
                                    , input substitute( "!!!Тэг &1 - отсутствует необходимый атрибут &2"
                                    , p-value
                                    , (if v-id-loc = ? then "id" else "time")
                                    )
                                    ).
                                assign
                                    v-cd-fatal-error = yes
                                    v-cd-fatal-message = "нарушение протокола обмена"
                                    p-view-log = yes
                                    .
                                return "error".
                            end.
                            else do:
                                if
                                not (p-value = "ACHData"
                                or
                                p-value = "ACHExp"
                                or
                                p-value = "CFReg"
                                )
                                then
                                    assign
                                        v-id = v-id-loc
                                        v-time = v-time-loc
                                        v-time-char = v-time-loc-char
                                        .
                            end.
                        end.
                    end.
                    when "FuelPump":U then do:
                        assign
                            v-record-name = p-value
                            CRI = 0
                            CRAI = 0
                            .
                        assign
                            v-key-char = ?
                            v-group-loc = ? .
                        v-group-loc = cb-xmlparse-get-attr(
                            input this-procedure:handle
                            ,input p-value
                            ,input p-parameters
                            ,input "code":U
                            ,input yes) .
                        v-key-char = cb-xmlparse-get-attr(
                            input this-procedure:handle
                            ,input p-value
                            ,input p-parameters
                            ,input "ctrl":U
                            ,input no) .
                        if v-group-loc = ?
                        or v-key-char = ?
                        then do:
                            assign
                                v-start-check = v-start-check - 1
                                .
                            run write-log-and-file in p-log-handle (
                                input 1
                                , input log-file-name
                                , input 1
                                , input substitute( "!!!Тэг &1 - отсутствует необходимый атрибут &2"
                                , p-value
                                , (if v-group-loc = ? then "code" else "ctrl")
                                )
                                ).
                            assign
                                v-cd-fatal-error = yes
                                v-cd-fatal-message = "нарушение протокола обмена"
                                p-view-log = yes
                                .
                            return "error".
                        end.
                        else do:
                            assign
                                v-group = v-group-loc
                                v-key = v-key-char
                                .
                        end.
                    end.
                    when "Param":U
                    then do:
                        assign
                            v-record-name = p-value
                            CRI = 0
                            CRAI = 0
                            .
                        assign
                            v-key-char = ?
                            v-group-loc = ? .
                        v-group-loc = cb-xmlparse-get-attr(
                            input this-procedure:handle
                            ,input p-value
                            ,input p-parameters
                            ,input "group":U
                            ,input yes) .
                        v-key-char = cb-xmlparse-get-attr(
                            input this-procedure:handle
                            ,input p-value
                            ,input p-parameters
                            ,input "key":U
                            ,input no) .
                        if v-group-loc = ?
                        or v-key-char = ?
                        then do:
                            assign
                                v-start-check = v-start-check - 1
                                .
                            run write-log-and-file in p-log-handle (
                                input 1
                                , input log-file-name
                                , input 1
                                , input substitute( "!!!Тэг &1 - отсутствует необходимый атрибут &2"
                                , p-value
                                , (if v-group-loc = ? then "group" else "key")
                                )
                                ).
                            assign
                                v-cd-fatal-error = yes
                                v-cd-fatal-message = "нарушение протокола обмена"
                                p-view-log = yes
                                .
                            return "error".
                        end.
                        else do:
                            assign
                                v-group = v-group-loc
                                v-key = v-key-char
                                .
                        end.
                    end.
                    otherwise do:
                        error-status:error = no.
                    end.
                END CASE.
            end.
            when "text"
            then do:
            end.
            otherwise do:
            end.
        end case.
    end.
END PROCEDURE.
procedure proc-create-return-write-off :
    define input parameter p-doc-code like ub.chk-doc.doc-code no-undo .
    define input parameter p-chk-type like ub.chk-doc.chk-type no-undo .
    define input  parameter p-write-off-code-2 like ub.chk-gds.write-off-code  no-undo .
    define output parameter p-doc-code2 like ub.chk-doc.doc-code no-undo .
    define output parameter p-netto-sum as decimal no-undo .
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer first_chk-doc for ub.chk-doc.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer buf_chk-pay for ub.chk-pay.
    define buffer buf_chk-discnt for ub.chk-discnt.
    do
        on error undo, return error
            :
        find first first_chk-doc where first_chk-doc.doc-code = p-doc-code no-lock no-error.
        if not available first_chk-doc then do:
            return.
        end.
        FIND  buf_chk-doc where
            buf_chk-doc.obj-type = first_chk-doc.obj-type and
            buf_chk-doc.obj-code = first_chk-doc.obj-code  and
            buf_chk-doc.chk-date = first_chk-doc.chk-date and
            buf_chk-doc.pay-desk = first_chk-doc.pay-desk and
            buf_chk-doc.chk-time = first_chk-doc.chk-time and
            buf_chk-doc.chk-num =  first_chk-doc.chk-num and
            buf_chk-doc.sales-man = first_chk-doc.sales-man and
            buf_chk-doc.chk-type = p-chk-type   NO-ERROR NO-WAIT.
        IF NOT AVAIL buf_chk-doc AND NOT LOCKED buf_chk-doc  AND NOT AMBIGUOUS buf_chk-doc then do:
            CREATE buf_chk-doc .
            assign
                lll = lll + 1
                buf_chk-doc.chk-date = first_chk-doc.chk-date
                buf_chk-doc.chk-time = first_chk-doc.chk-time
                buf_chk-doc.chk-num = first_chk-doc.chk-num
                buf_chk-doc.sales-man = first_chk-doc.sales-man
                buf_chk-doc.pay-desk = first_chk-doc.pay-desk
                buf_chk-doc.cashier = first_chk-doc.cashier
                buf_chk-doc.office = first_chk-doc.office
                buf_chk-doc.obj-type = first_chk-doc.obj-type
                buf_chk-doc.obj-code = first_chk-doc.obj-code
                buf_chk-doc.tot-doc =  0
                buf_chk-doc.discnt = 0
                p-doc-code2 = (if get-chkc_context.db-num = 0
                then string(next-value(s-chk, ub ))
                else string( shop-code ) + chr(47) + string( next-value( s-chk, ub ) ))
                buf_chk-doc.doc-code = p-doc-code2
                buf_chk-doc.netto = 0
                p-netto-sum = - first_chk-doc.netto
                buf_chk-doc.shift-date = first_chk-doc.shift-date
                buf_chk-doc.shift-num = first_chk-doc.shift-num
                buf_chk-doc.src-d-card = first_chk-doc.src-d-card
                buf_chk-doc.src-shift-date = first_chk-doc.src-shift-date
                buf_chk-doc.cash-rate = first_chk-doc.cash-rate
                buf_chk-doc.cash-scale = first_chk-doc.cash-scale
                buf_chk-doc.z-number = first_chk-doc.z-number
                buf_chk-doc.correct = first_chk-doc.correct
                buf_chk-doc.chk-type = p-chk-type
                buf_chk-doc.src-d-pcnt = first_chk-doc.src-d-pcnt
                .
            FOR EACH ub.chk-pay WHERE
                ub.chk-pay.doc-code = first_chk-doc.doc-code :
                BUFFER-COPY ub.chk-pay TO buf_chk-pay
                    assign
                    buf_chk-pay.tot-sum = - ub.chk-pay.tot-sum
                    buf_chk-pay.tot-rubl = - ub.chk-pay.tot-rubl
                    buf_chk-pay.tot-base = - ub.chk-pay.tot-base
                    buf_chk-pay.doc-code = buf_chk-doc.doc-code
                    .
            END.
            assign
                netto-for-sub-d = 0
                accum-src-for-sub-d = 0
                .
            FOR EACH ub.chk-gds WHERE
                ub.chk-gds.doc-code = first_chk-doc.doc-code :
                find first temp-ivs-ibs-line where
                    temp-ivs-ibs-line.line-num = abs(chk-gds.line-num) no-error .
                BUFFER-COPY ub.chk-gds TO buf_chk-gds
                    assign
                    buf_chk-gds.src-qnty = (if available temp-ivs-ibs-line
                    then (if temp-ivs-ibs-line.qnty-sign[2] = 0
                    then 0
                    else  - ub.chk-gds.src-qnty)
                    else - ub.chk-gds.src-qnty)
                    buf_chk-gds.src-sum = - (if temp-ivs-ibs-line.qnty-sign[2] = 0
                    then 0
                    else  ub.chk-gds.src-sum)
                    buf_chk-gds.doc-code = buf_chk-doc.doc-code
                    buf_chk-gds.write-off-code = (if available temp-ivs-ibs-line
                    then integer(temp-ivs-ibs-line.wro-code[2])
                    else p-write-off-code-2)
                    netto-for-sub-d = netto-for-sub-d + if temp-ivs-ibs-line.return-line
                    or buf_chk-gds.doc-qnty = 0
                    then 0
                    else (
                    (if buf_chk-gds.write-off-code = ?
                    or buf_chk-gds.write-off-code <= 0
                    then
                    ((buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty)
                    else 0)
                    )
                    accum-src-for-sub-d = accum-src-for-sub-d + (if temp-ivs-ibs-line.return-line then 0 else buf_chk-gds.src-qnty)
                    .
            END.
            var-discnt-id = 0.
            FOR EACH ub.chk-discnt WHERE
                ub.chk-discnt.doc-code = first_chk-doc.doc-code
                    AND ub.chk-discnt.record-type = 0:
                BUFFER-COPY ub.chk-discnt TO buf_chk-discnt
                    assign
                    buf_chk-discnt.discnt-value-abs = - ub.chk-discnt.discnt-value-abs
                    buf_chk-discnt.discnt-value-pcnt = - ub.chk-discnt.discnt-value-pcnt
                    buf_chk-discnt.object-qnty = - ub.chk-discnt.object-qnty
                    buf_chk-discnt.object-sum = - ub.chk-discnt.object-sum
                    buf_chk-discnt.doc-code = buf_chk-doc.doc-code
                    var-discnt-id = (if buf_chk-discnt.discnt-id > var-discnt-id
                    then buf_chk-discnt.discnt-id
                    else var-discnt-id)
                    .
            END.
        end.
    end.
end procedure.
procedure proc-netto-2 :
    define input parameter p-doc-code like ub.chk-doc.doc-code no-undo .
    define input parameter p-doc-code2 like ub.chk-doc.doc-code no-undo .
    define output parameter p-netto-sum as decimal no-undo .
    define buffer buf1_chk-doc for ub.chk-doc.
    define buffer buf_chk-doc for ub.chk-doc.
    do
        on error undo, return error
            :
        find first buf1_chk-doc where buf1_chk-doc.doc-code = p-doc-code no-lock no-error.
        if not available buf1_chk-doc then do:
            return.
        end.
        find first buf_chk-doc where buf_chk-doc.doc-code = p-doc-code2 no-error.
        if not available buf_chk-doc then do:
            return.
        end.
        assign
            buf_chk-doc.netto = - buf1_chk-doc.netto
            p-netto-sum = buf_chk-doc.netto.
        .
    end.
end procedure.
procedure recalc-write-off :
    define parameter buffer buf_chk-doc for ub.chk-doc.
    define input  parameter p-old-gbl-type as character no-undo .
    define input  parameter p-gbl-type as character no-undo .
    define variable old-chk-type as integer   no-undo extent 2.
    define variable old-create-return-write-off as logical   no-undo .
    define variable old-return-line as logical   no-undo .
    define variable v-step as integer   no-undo .
    define variable v-is-modificator as logical   no-undo .
    define buffer find_chk-doc for ub.chk-doc.
    define buffer buf_chk-gds for ub.chk-gds.
    define buffer return_chk-gds for ub.chk-gds.
    define buffer buf_temp-ivs-ibs-line for temp-ivs-ibs-line.
    do
        on error undo, return error return-value
            :
        assign
            gbl-type = p-gbl-type.
        for each temp-ivs-ibs where
            temp-ivs-ibs.chtype = gbl-type
                AND temp-ivs-ibs.positive-num-chk = (chk-num_ > 0)
                AND temp-ivs-ibs.positive-netto-sum = (netto-sum_ > 0)
                and temp-ivs-ibs.main-record = yes:
            if temp-ivs-ibs.step_ = 1 then do:
                assign
                    old-chk-type[1] = v-chk-type[1]
                    v-chk-type[1] = integer(temp-ivs-ibs.rcpt-type-1).
                v-step = temp-ivs-ibs.step.
            end.
            if temp-ivs-ibs.step_ = 2 then do:
                assign
                    old-chk-type[2] = v-chk-type[2]
                    v-chk-type[2] = integer(temp-ivs-ibs.rcpt-type-1)
                    old-create-return-write-off = v-create-return-write-off
                    v-create-return-write-off = temp-ivs-ibs.create-return-write-off
                    v-write-off-code-2 = integer(temp-ivs-ibs.wro-code)
                    v-step = temp-ivs-ibs.step.
                .
            end.
            if v-step = 2
            or (old-chk-type[v-step] <> v-chk-type[v-step]
            and v-step = 1)
            then do:
                FIND  find_chk-doc no-lock where
                    find_chk-doc.obj-type = shop-type and
                    find_chk-doc.obj-code = shop-code and
                    find_chk-doc.chk-date = chk-date_ and
                    find_chk-doc.pay-desk = pay-desk_ and
                    find_chk-doc.chk-time = chk-time_ and
                    find_chk-doc.chk-num = chk-num_ and
                    find_chk-doc.chk-type = integer(v-chk-type[v-step])
                    NO-ERROR NO-WAIT.
                if available find_chk-doc
                then do:
                    if v-step <> 1
                    or find_chk-doc.doc-code <> buf_chk-doc.doc-code then
                        v-to-delete[v-step] = yes.
                end.
                else do:
                    v-to-delete[v-step] = no.
                end.
            end.
        end.
        if v-to-delete[1] = yes then return.
        assign
            sub-d = 0
            var-discnt-id = 0
            lng-sub-d = 0
            netto-for-sub-d = 0
            accum-src-for-sub-d = 0
            buf_chk-doc.chk-type = v-chk-type[1]
            .
        for each buf_chk-gds where buf_chk-gds.doc-code = buf_chk-doc.doc-code:
            if buf_chk-gds.line-num < 0 then next.
                        v-is-modificator = (lookup (string(buf_chk-gds.write-off-code),  '2,-2,3,-3,-4':U) > 0).
            do v-step = 1 to (if v-create-return-write-off then 2 else 1):
                find first buf_temp-ivs-ibs-line where
                    buf_temp-ivs-ibs-line.line-num = abs(buf_chk-gds.line-num).
                find first temp-ivs-ibs where
                    temp-ivs-ibs.chtype = gbl-type
                    AND temp-ivs-ibs.cstype = buf_temp-ivs-ibs-line.cstype
                    and temp-ivs-ibs.cancelcode = buf_temp-ivs-ibs-line.cancelcode
                    and temp-ivs-ibs.positive-num-chk = (buf_chk-doc.chk-num > 0)
                    and temp-ivs-ibs.positive-netto-sum = (netto-sum_ > 0)
                    and temp-ivs-ibs.modificator = buf_temp-ivs-ibs-line.modificator
                    and (v-is-modificator = no or temp-ivs-ibs.modificator-np = buf_temp-ivs-ibs-line.modificator-np)
                    and temp-ivs-ibs.step_ = v-step no-error .
                if available temp-ivs-ibs then do:
                    if v-step  = 1 then do:
                        assign
                            temp-ivs-ibs-line.chtype = temp-ivs-ibs.chtype
                            temp-ivs-ibs-line.create-return-write-off =  temp-ivs-ibs.create-return-write-off
                            old-return-line = buf_temp-ivs-ibs-line.return-line
                            temp-ivs-ibs-line.return-line = temp-ivs-ibs.return-line
                            temp-ivs-ibs-line.rcpt-type-1                        = temp-ivs-ibs.rcpt-type-1
                            temp-ivs-ibs-line.wro-code[v-step]                   = temp-ivs-ibs.wro-code
                            temp-ivs-ibs-line.qnty-sign[v-step]                  = temp-ivs-ibs.qnty-sign
                            .
                    end.
                    if v-step = 2
                    and available buf_temp-ivs-ibs-line
                    and available temp-ivs-ibs then do:
                        assign
                            buf_temp-ivs-ibs-line.rcpt-type-2                        = temp-ivs-ibs.rcpt-type-1
                            buf_temp-ivs-ibs-line.wro-code[v-step]                   = temp-ivs-ibs.wro-code
                            buf_temp-ivs-ibs-line.qnty-sign[v-step]                  = temp-ivs-ibs.qnty-sign
                            .
                    end.
                end.
            end.
            if old-return-line = no
            and buf_temp-ivs-ibs-line.return-line = no then do:
                find first return_chk-gds where
                    return_chk-gds.doc-code = buf_chk-doc.doc-code
                    AND return_chk-gds.line-num = - buf_chk-gds.line-num no-error .
                if available return_chk-gds then delete return_chk-gds.
            end.
            assign
                buf_chk-gds.write-off-code = integer(buf_temp-ivs-ibs-line.wro-code[1])
                netto-for-sub-d = netto-for-sub-d + if buf_temp-ivs-ibs-line.return-line
                then 0
                else (
                (if buf_chk-gds.write-off-code = ?
                or buf_chk-gds.write-off-code <= 0
                then
                ((buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty)
                else 0)
                )
                accum-src-for-sub-d = accum-src-for-sub-d + (if buf_temp-ivs-ibs-line.return-line then 0 else buf_chk-gds.src-qnty)
                .
            if old-return-line  = no
            and buf_temp-ivs-ibs-line.return-line = yes then do:
                create return_chk-gds.
                buffer-copy buf_chk-gds to return_chk-gds
                    assign
                    return_chk-gds.src-sum   = - buf_chk-gds.src-sum
                    return_chk-gds.src-qnty  = - buf_chk-gds.src-qnty
                    return_chk-gds.src-discnt = - buf_chk-gds.src-discnt
                    return_chk-gds.doc-qnty = - buf_chk-gds.doc-qnty
                    return_chk-gds.line-sign = (not buf_chk-gds.line-sign)
                    return_chk-gds.line-num = - buf_chk-gds.line-num
                    .
                return.
            end.
        end.
    end.
end procedure.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ach-data :
    define variable num_ as integer no-undo .
    define variable loc-shop-code as integer no-undo .
    define variable trans-num_ as integer no-undo .
    define buffer buf_temp-temp for temp-temp.
    define buffer buf_achd for achd.
    do
        on error undo, return error
            :
        assign
            chk-date_ = ?
            chk-time_ = 0
            pay-desk_ = 0
            bc-buf = ""
            pump_ = 0
            nozzle_ = 0
            curr-string-qnty = 0
            .
        for each buf_temp-temp where
            buf_temp-temp.record-name = "ACHData":U
                AND buf_temp-temp.id = v-id:
            CASE buf_temp-temp.field-name:
                when "ACHDNum":U then do:
                    assign
                        num_ =  integer( buf_temp-temp.field-value)
                        no-error .
                end.
                when "ACHDDate":U then do:
                    assign
                        chk-date_ =  cb-xmlparse-get-date( buf_temp-temp.field-value)
                        chk-time_ =  cb-xmlparse-get-time( buf_temp-temp.field-value)
                        no-error .
                end.
                when "ACHDShop" then do:
                    assign
                        loc-shop-code = integer(buf_temp-temp.field-value)
                        no-error.
                end.
                when "ACHDCashNum" then do:
                    assign
                        pay-desk_ = integer(buf_temp-temp.field-value)
                        no-error .
                end.
                when "ACHDCode" then do:
                    assign
                        bc-buf = buf_temp-temp.field-value
                        no-error .
                end.
                when "ACHDTRNum" then do:
                    assign
                        trans-num_ = integer(buf_temp-temp.field-value)
                        no-error .
                end.
                when "ACHDTRK" then do:
                    assign
                        pump_ = integer(buf_temp-temp.field-value)
                        no-error .
                end.
                when "ACHDNozzle" then do:
                    assign
                        nozzle_ = integer(buf_temp-temp.field-value)
                        no-error .
                end.
                when "ACHDVol" then do:
                    assign
                        curr-string-qnty = decimal(buf_temp-temp.field-value)
                        no-error .
                end.
                otherwise do:
                    error-status:error = no.
                end.
            END CASE.
            if error-status:error then do:
                if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
            end.
            delete buf_temp-temp.
        end.
        find first buf_achd where
            buf_achd.num = num_ no-error.
        if not available buf_achd then do:
            create buf_achd.
            assign
                buf_achd.num = num_.
        end.
        assign
            buf_achd.chk-date = chk-date_
            buf_achd.chk-time = chk-time_
            buf_achd.obj-type = 'маг':U
            buf_achd.obj-code = loc-shop-code
            buf_achd.pay-desk = pay-desk_
            buf_achd.src-code = bc-buf
            buf_achd.pump = pump_
            buf_achd.nozzle-code = nozzle_
            buf_achd.src-qnty = curr-string-qnty
            buf_achd.trans-num = trans-num_
            .
    end.
end procedure.
procedure proc-ach-exp :
    define variable bc-buf_e as character no-undo .
    define variable total-exp as decimal no-undo .
    define variable month-exp as decimal no-undo .
    define variable day-exp as decimal no-undo .
    define variable chk-date_el as date no-undo .
    define variable chk-time_el as integer no-undo .
    define buffer buf_temp-temp for temp-temp.
    define buffer buf_ache for ache.
    do
        on error undo, return error
            :
        for each buf_temp-temp where
            buf_temp-temp.record-name = "ACHExp":U
                AND buf_temp-temp.id = v-id:
            CASE buf_temp-temp.field-name:
                when "ACHECode" then do:
                    assign
                        bc-buf_e = buf_temp-temp.field-value
                        no-error
                        .
                end.
                when "ACHEExp" then do:
                    assign
                        total-exp = decimal(buf_temp-temp.field-value)
                        no-error
                        .
                end.
                when "ACHEMonthExp" then do:
                    assign
                        month-exp = decimal(buf_temp-temp.field-value)
                        no-error
                        .
                end.
                when "ACHEDayExp" then do:
                    assign
                        day-exp = decimal(buf_temp-temp.field-value)
                        no-error
                        .
                end.
                when "ACHELastDate" then do:
                    assign
                        chk-date_el =  cb-xmlparse-get-date( buf_temp-temp.field-value)
                        chk-time_el =  cb-xmlparse-get-time( buf_temp-temp.field-value)
                        no-error .
                end.
                otherwise do:
                    error-status:error = no.
                end.
            END CASE.
            if error-status:error then do:
                if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
            end.
            delete buf_temp-temp.
        end.
        find first buf_ache where
            buf_ache.src-code = bc-buf_e no-error.
        if not available buf_ache then do:
            create buf_ache.
            assign
                buf_ache.src-code = bc-buf_e
                .
        end.
        assign
            buf_ache.chk-date = chk-date_el
            buf_ache.chk-time = chk-time_el
            buf_ache.total-exp = total-exp
            buf_ache.month-exp = month-exp
            buf_ache.day-exp = day-exp
            .
    end.
end procedure.
procedure proc-ach :
    define input parameter loc-exist as logical no-undo .
    define variable status-int as integer no-undo .
    define variable error-code-int as integer no-undo .
    define variable error-code-char as character no-undo .
    define variable curr-string-qnty-2 as decimal no-undo .
    define variable ret-flag-log as logical no-undo .
    define variable trans-num_ as integer no-undo .
    define variable dur-int as integer no-undo .
    define variable bc-buf_e as character no-undo .
    define variable total-exp as decimal no-undo .
    define variable month-exp as decimal no-undo .
    define variable day-exp as decimal no-undo .
    define variable chk-date_el as date no-undo .
    define variable chk-time_el as integer no-undo .
    define variable v-ach-id as character no-undo .
    define buffer buf_temp-temp for temp-temp.
    define buffer buf_cd-trans for tt-cd-trans.
    define buffer buf2_cd-trans for tt-cd-trans.
    define buffer buf3_cd-trans for tt-cd-trans.
    define buffer buf_chk-doc for tt-chk-doc.
    define buffer buf_achd for achd.
    define buffer buf_ache for ache.
    do
        on error undo, return error
            :
        assign
            bc-buf = ""
            price-from-check = 0
            curr-string-qnty = 0
            chk-id_ = ""
            d-card_ = ""
            pump_ = 0
            v-ach-id = ''
            .
        if loc-exist then return.
        find first buf_chk-doc no-error.
        for each buf_temp-temp where
            buf_temp-temp.record-name = "CACHistory":U
                AND buf_temp-temp.id = v-id:
            CASE buf_temp-temp.field-name:
                when "CACHDate":U then do:
                    assign
                        chk-date_ =  cb-xmlparse-get-date( buf_temp-temp.field-value)
                        chk-time_ =  cb-xmlparse-get-time( buf_temp-temp.field-value)
                        no-error .
                end.
                when "CACHCardNum" then do:
                    assign
                        d-card_ = buf_temp-temp.field-value
                        no-error.
                end.
                when "CACHStatus" then do:
                    assign
                        status-int = integer(buf_temp-temp.field-value)
                        no-error .
                end.
                when "CACHErrCode" then do:
                    assign
                        error-code-int = integer(buf_temp-temp.field-value)
                        no-error .
                end.
                when "CACHErrMess" then do:
                    assign
                        error-code-char = buf_temp-temp.field-value
                        no-error .
                end.
                when "CACHTRKNum" then do:
                    assign
                        pump_ = integer(buf_temp-temp.field-value)
                        no-error .
                end.
                when "CACHCode" then do:
                    assign
                        bc-buf = buf_temp-temp.field-value
                        no-error .
                end.
                when "CACHOrderVol" then do:
                    assign
                        curr-string-qnty = decimal(buf_temp-temp.field-value)
                        no-error .
                end.
                when "CACHTakeVol" then do:
                    assign
                        curr-string-qnty-2 = decimal(buf_temp-temp.field-value)
                        no-error .
                end.
                when "CACHRet" then do:
                    assign
                        ret-flag-log = logical(buf_temp-temp.field-value)
                        no-error .
                end.
                when "CACHTranzNum" then do:
                    assign
                        trans-num_ = integer(buf_temp-temp.field-value)
                        no-error .
                end.
                when "CACHTime" then do:
                    assign
                        dur-int = integer(buf_temp-temp.field-value)
                        no-error .
                end.
                when "CACHPrice" then do:
                    assign
                        price-from-check = decimal(buf_temp-temp.field-value)
                        no-error .
                end.
                when "CACHCheckID" then do:
                    assign
                        chk-id_ = buf_temp-temp.field-value
                        no-error .
                end.
                when "CACHistoryID" then do:
                    assign
                        v-ach-id = buf_temp-temp.field-value
                        no-error .
                end.
                otherwise do:
                    error-status:error = no.
                end.
            END CASE.
            if error-status:error then do:
                if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
            end.
            delete buf_temp-temp.
        end.
        find first buf_cd-trans share-lock where
            buf_cd-trans.trans-id-chr = v-ach-id
            and buf_cd-trans.trans-type  = integer('40':U)
            and buf_cd-trans.obj-type = shop-type
            and buf_cd-trans.obj-code = shop-code
            and buf_cd-trans.chk-date = chk-date_
            and buf_cd-trans.chk-time = chk-time_
            no-error.
        if not available buf_cd-trans then do:
            create buf_cd-trans.
            assign
                buf_cd-trans.db-num   = g#db-num
                buf_cd-trans.trans-id = next-value(s-cd-trans, ub)
                buf_cd-trans.trans-type  = integer('40':U)
                buf_cd-trans.obj-type = shop-type
                buf_cd-trans.obj-code = shop-code
                buf_cd-trans.trans-id-chr = v-ach-id
                buf_cd-trans.chk-date = chk-date_
                buf_cd-trans.chk-time = chk-time_
                .
        end.
        assign
            buf_cd-trans.src-shift-date = buf_chk-doc.src-shift-date
            buf_cd-trans.src-shift-name = buf_chk-doc.src-shift-name
            buf_cd-trans.pay-desk = buf_chk-doc.pay-desk
            buf_cd-trans.chk-id = chk-id_
            buf_cd-trans.charkey_one = d-card_
            buf_cd-trans.charkey_two = bc-buf
            buf_cd-trans.charkey_three = error-code-char
            buf_cd-trans.deckey_one = curr-string-qnty
            buf_cd-trans.deckey_two = curr-string-qnty-2
            buf_cd-trans.deckey_three = price-from-check
            buf_cd-trans.key#_one = status-int
            buf_cd-trans.key#_two = error-code-int
            buf_cd-trans.key#_three = trans-num_
            buf_cd-trans.key#_four = dur-int
            buf_cd-trans.key#_five = pump_
            buf_cd-trans.logkey_one = ret-flag-log
            .
        for each buf_ache:
            find first buf2_cd-trans share-lock where
                buf2_cd-trans.trans-id-chr = v-ach-id
                and buf2_cd-trans.trans-type  = integer('41':U)
                and buf2_cd-trans.obj-type = shop-type
                and buf2_cd-trans.obj-code = shop-code
                and buf2_cd-trans.charkey_two = buf_ache.src-code
                no-error.
            if not available buf2_cd-trans then do:
                create buf2_cd-trans.
                assign
                    buf2_cd-trans.db-num   = g#db-num
                    buf2_cd-trans.trans-id = next-value(s-cd-trans, ub)
                    buf2_cd-trans.trans-type  = integer('41':U)
                    buf2_cd-trans.obj-type = shop-type
                    buf2_cd-trans.obj-code = shop-code
                    buf2_cd-trans.trans-id-chr = v-ach-id
                    buf2_cd-trans.charkey_two = buf_ache.src-code
                    .
            end.
            assign
                buf2_cd-trans.charkey_one = d-card_
                buf2_cd-trans.deckey_one = buf_ache.total-exp
                buf2_cd-trans.deckey_two = buf_ache.month-exp
                buf2_cd-trans.deckey_three = buf_ache.day-exp
                buf2_cd-trans.chk-date = buf_ache.chk-date
                buf2_cd-trans.chk-time = buf_ache.chk-time
                .
        end.
        for each buf_achd:
            find first buf2_cd-trans share-lock where
                buf2_cd-trans.trans-id-chr = v-ach-id
                and buf2_cd-trans.trans-type  = integer('42':U)
                and buf2_cd-trans.obj-type = buf_achd.obj-type
                and buf2_cd-trans.obj-code = buf_achd.obj-code
                and buf2_cd-trans.chk-date = buf_achd.chk-date
                and buf2_cd-trans.chk-time = buf_achd.chk-time
                and buf2_cd-trans.key#_one = buf_achd.num
                no-error.
            if not available buf2_cd-trans then do:
                create buf2_cd-trans.
                assign
                    buf2_cd-trans.db-num   = g#db-num
                    buf2_cd-trans.trans-id = next-value(s-cd-trans, ub)
                    buf2_cd-trans.trans-type  = integer('42':U)
                    buf2_cd-trans.trans-id-chr = v-ach-id
                    buf2_cd-trans.obj-type = buf_achd.obj-type
                    buf2_cd-trans.obj-code = buf_achd.obj-code
                    buf2_cd-trans.chk-date = buf_achd.chk-date
                    buf2_cd-trans.chk-time = buf_achd.chk-time
                    buf2_cd-trans.key#_one = buf_achd.num
                    buf2_cd-trans.pay-desk = buf_achd.pay-desk
                    buf2_cd-trans.charkey_one = d-card
                    buf2_cd-trans.charkey_two = buf_achd.src-code
                    buf2_cd-trans.key#_five = buf_achd.pump
                    buf2_cd-trans.key#_four = buf_achd.nozzle-code
                    buf2_cd-trans.key#_three = buf_achd.trans-num
                    buf2_cd-trans.deckey_one = buf_achd.src-qnty
                    .
            end.
        end.
    end.
end procedure.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-cfiscal :
    define input parameter loc-exist as logical no-undo .
    define variable v-field-name as character no-undo .
    define variable v-datatype as character no-undo .
    define variable v-int-trans-type as integer no-undo .
    define buffer buf_temp-temp for temp-temp.
    define buffer buf_cd-trans for tt-cd-trans .
    defin buffer buf_chk-doc for tt-chk-doc.
    defin buffer buf_chk-pay for tt-chk-pay.
    do
        on error undo, return error
            :
        if not loc-exist then do:
            assign
                tot_sum = 0
                z-num_ = 0
                .
            find first buf_chk-doc no-error.
            for each buf_temp-temp where
                buf_temp-temp.record-name = "CFiscal":U
                    AND buf_temp-temp.id = v-id:
                v-field-name = ''.
                CASE buf_temp-temp.field-name:
                    when "CFSalesAccum" then do:
                        assign
                            v-field-name = "deckey_one"
                            v-datatype = 'decimal':U
                            v-int-trans-type = integer('15':U)
                            tot_sum = decimal(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CFRetAccum" then do:
                        assign
                            v-field-name = "deckey_one"
                            v-datatype = 'decimal':U
                            v-int-trans-type = integer('16':U)
                            no-error .
                    end.
                    when "CFZCount" then do:
                        assign
                            v-field-name = "key#_one"
                            v-datatype = 'integer':U
                            v-int-trans-type = integer('9':U)
                            z-num_ = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "CFSerial" then do:
                        assign
                            v-field-name = "charkey_one"
                            v-datatype = 'character':U
                            v-int-trans-type = integer('5':U)
                            no-error .
                    end.
                    when "CFRegNum" then do:
                        assign
                            v-field-name = "charkey_one"
                            v-datatype = 'character':U
                            v-int-trans-type = integer('6':U)
                            no-error .
                    end.
                    when "CFOwner" then do:
                        assign
                            v-field-name = "charkey_one"
                            v-datatype = 'character':U
                            v-int-trans-type = integer('7':U)
                            no-error .
                    end.
                    when "CFEKLZSerial" then do:
                        assign
                            v-field-name = "charkey_one"
                            v-datatype = 'character':U
                            v-int-trans-type = integer('8':U)
                            no-error .
                    end.
                    when "CFDate" then do:
                        assign
                            v-field-name = "charkey_one"
                            v-datatype = 'character':U
                            v-int-trans-type = integer('10':U)
                            no-error .
                    end.
                    when "CFXCount" then do:
                        assign
                            v-field-name = "key#_one"
                            v-datatype = 'integer':U
                            v-int-trans-type = integer('11':U)
                            no-error .
                    end.
                    when "CFEJCount" then do:
                        assign
                            v-field-name = "key#_one"
                            v-datatype = 'integer':U
                            v-int-trans-type = integer('12':U)
                            no-error .
                    end.
                    when "CFCash" then do:
                        assign
                            v-field-name = "deckey_one"
                            v-datatype = 'decimal':U
                            v-int-trans-type = integer('13':U)
                            no-error .
                    end.
                    when "CFDocCount" then do:
                        assign
                            v-field-name = "key#_one"
                            v-datatype = 'integer':U
                            v-int-trans-type = integer('14':U)
                            no-error .
                    end.
                    otherwise do:
                        error-status:error = no.
                    end.
                END CASE.
                if error-status:error then do:
                    if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
                end.
                if v-field-name > '' then do:
                    find first buf_cd-trans share-lock where
                        buf_cd-trans.trans-type = v-int-trans-type
                        and buf_cd-trans.obj-type = shop-type
                        and buf_cd-trans.obj-code = shop-code
                        and buf_cd-trans.chk-date = chk-date_
                        and buf_cd-trans.chk-time = chk-time_
                        and buf_cd-trans.pay-desk = buf_chk-doc.pay-desk
                        and buf_cd-trans.chk-id = v-id
                        no-error.
                    if not available buf_cd-trans then do:
                        create buf_cd-trans.
                        assign
                            buf_cd-trans.db-num   = g#db-num
                            buf_cd-trans.trans-id = next-value(s-cd-trans, ub)
                            buf_cd-trans.trans-type = v-int-trans-type
                            buf_cd-trans.obj-type = shop-type
                            buf_cd-trans.obj-code = shop-code
                            buf_cd-trans.chk-date = chk-date_
                            buf_cd-trans.chk-time = chk-time_
                            buf_cd-trans.chk-id = v-id
                            buf_cd-trans.z-number = buf_chk-doc.z-number
                            buf_cd-trans.doc-code = buf_chk-doc.doc-code
                            buf_cd-trans.src-shift-date = buf_chk-doc.src-shift-date
                            buf_cd-trans.src-shift-name = buf_chk-doc.src-shift-name
                            buf_cd-trans.pay-desk = buf_chk-doc.pay-desk
                            buf_cd-trans.chk-num = buf_chk-doc.chk-num
                            .
                    end.
                    assign
                        buf_cd-trans.doc-code = buf_chk-doc.doc-code
                        .
                    case v-datatype:
                        when 'character':U then do:
                            buffer buf_cd-trans:handle:buffer-field(v-field-name):buffer-value = string(buf_temp-temp.field-value)
                                no-error .
                        end.
                        when 'date':U then do:
                            buffer buf_cd-trans:handle:buffer-field(v-field-name):buffer-value = date(buf_temp-temp.field-value)
                                no-error .
                        end.
                        when 'decimal':U then do:
                            buffer buf_cd-trans:handle:buffer-field(v-field-name):buffer-value = decimal(buf_temp-temp.field-value)
                                no-error .
                        end.
                        when 'integer':U then do:
                            buffer buf_cd-trans:handle:buffer-field(v-field-name):buffer-value = integer(buf_temp-temp.field-value)
                                no-error .
                        end.
                        when 'logical':U then do:
                            buffer buf_cd-trans:handle:buffer-field(v-field-name):buffer-value = logical(buf_temp-temp.field-value)
                                no-error .
                        end.
                    end.
                    if error-status:error then do:
                        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
                    end.
                end.
                delete buf_temp-temp.
            end.
            FIND buf_chk-pay WHERE
                 buf_chk-pay.doc-code = buf_chk-doc.doc-code
                AND buf_chk-pay.curr-code = 0
                AND buf_chk-pay.pay-code = 0
                NO-ERROR.
            if NOT available buf_chk-pay
            then  do:
                create buf_chk-pay.
                assign
                    lnp = lnp + 1
                    buf_chk-pay.doc-code = buf_chk-doc.doc-code
                    buf_chk-pay.line-num = lnp
                    buf_chk-pay.chk-date = buf_chk-doc.chk-date
                    buf_chk-pay.obj-code = shop-code
                    buf_chk-pay.obj-type = shop-type
                    buf_chk-pay.tot-rubl = 0
                    buf_chk-pay.tot-sum = 0
                    buf_chk-pay.tot-base = 0
                    buf_chk-pay.pay-code = 0
                    buf_chk-pay.curr-code = 0
                    buf_chk-pay.time-oper = buf_chk-doc.chk-time
                    buf_chk-pay.cash-rate = buf_chk-doc.cash-rate
                    buf_chk-pay.bank-rate = 1
                    buf_chk-pay.bank-scale = 1
                    buf_chk-pay.pass-pay =  0
                    buf_chk-pay.pay-card = '':U
                    buf_chk-pay.line-type = "":U
                    buf_chk-pay.line-sign = yes
                    buf_chk-pay.is-error = no
                    buf_chk-doc.z-number = ( if z-num_ < buf_chk-doc.z-number
                    and z-num_ > 0
                    then z-num_ else buf_chk-doc.z-number)
                    .
            end.
            assign
                buf_chk-pay.tot-sum = buf_chk-pay.tot-sum + tot_sum
                .
        end.
    end.
end procedure.
procedure proc-cfreg :
    define variable v-cfrtype as character no-undo .
    define variable v-cframount as decimal no-undo .
    define variable v-cfrcount as integer no-undo .
    define buffer buf_temp-temp for temp-temp.
    define buffer buf_cd-trans for tt-cd-trans.
    define buffer buf_chk-doc for tt-chk-doc.
    do
        on error undo, return error
            :
        for each buf_temp-temp where
            buf_temp-temp.record-name = "CFReg":U
                AND buf_temp-temp.id = v-id:
            CASE buf_temp-temp.field-name:
                when "CFRType" then do:
                    assign
                        v-cfrtype = buf_temp-temp.field-value
                        no-error
                        .
                end.
                when "CFRCount" then do:
                    assign
                        v-cfrcount = integer(buf_temp-temp.field-value)
                        no-error
                        .
                end.
                when "CFRAmount" then do:
                    assign
                        v-cframount = decimal(buf_temp-temp.field-value)
                        no-error
                        .
                end.
                otherwise do:
                    error-status:error = no.
                end.
            END CASE.
            if error-status:error then do:
                if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
            end.
            delete buf_temp-temp.
        end.
        find first buf_chk-doc no-error.
        find first buf_cd-trans share-lock where
            buf_cd-trans.trans-type = integer('17':U)
            and buf_cd-trans.obj-type = shop-type
            and buf_cd-trans.charkey_one = v-cfrtype
            and buf_cd-trans.obj-code = shop-code
            and buf_cd-trans.chk-date = chk-date_
            and buf_cd-trans.chk-time = chk-time_
            and buf_cd-trans.chk-id = v-id
            and buf_cd-trans.doc-code = buf_chk-doc.doc-code
            no-error.
        if not available buf_cd-trans then do:
            create buf_cd-trans.
            assign
                buf_cd-trans.db-num   = g#db-num
                buf_cd-trans.trans-id = next-value(s-cd-trans, ub)
                buf_cd-trans.trans-type = integer('17':U)
                buf_cd-trans.obj-type = shop-type
                buf_cd-trans.obj-code = shop-code
                buf_cd-trans.chk-date = chk-date_
                buf_cd-trans.chk-time = chk-time_
                buf_cd-trans.chk-id = v-id
                buf_cd-trans.z-number = buf_chk-doc.z-number
                buf_cd-trans.doc-code = buf_chk-doc.doc-code
                buf_cd-trans.src-shift-date = buf_chk-doc.src-shift-date
                buf_cd-trans.src-shift-name = buf_chk-doc.src-shift-name
                buf_cd-trans.pay-desk = buf_chk-doc.pay-desk
                buf_cd-trans.chk-num = buf_chk-doc.chk-num
                buf_cd-trans.chk-num = buf_chk-doc.chk-num
                buf_cd-trans.charkey_one = v-cfrtype
                buf_cd-trans.key#_one = v-cfrcount
                buf_cd-trans.deckey_one = v-cframount
                .
        end.
    end.
end procedure.
procedure proc-promo :
    define variable  Promo-Id        as char no-undo .
    define variable  promo-count     as integer no-undo .
    define variable  promo-misc      as character no-undo .
    define buffer buf_temp-temp for temp-temp .
    define buffer buf_chk-gds for tt-chk-gds.
    define buffer buf_chk-doc for tt-chk-doc.
    define buffer buf_chk-discnt for tt-chk-discnt.
    define buffer buf_chk-discnt-attr for tt-chk-discnt-attr.
    define variable local-netto-for-sub-d as decimal no-undo .
    do
        on error undo, return error
            :
        if not exist then do:
            for each buf_temp-temp where
                buf_temp-temp.record-name = "CPromo":U
                    AND buf_temp-temp.id = v-id:
                CASE buf_temp-temp.field-name:
                    when "cPromoId":U then do:
                        assign
                            Promo-Id = buf_temp-temp.field-value
                            no-error .
                    end.
                    when "cPromoCount":U then do:
                        assign
                            promo-count = integer(buf_temp-temp.field-value)
                            no-error .
                    end.
                    when "cPromoMisc":U then do:
                        assign
                            promo-misc = buf_temp-temp.field-value
                            no-error .
                    end.
                    otherwise do:
                        error-status:error = no.
                    end.
                END CASE.
                if error-status:error then do:
                    if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
                end.
                delete buf_temp-temp.
            end.
            FIND FIRST buf_chk-doc NO-ERROR.
            find first buf_chk-discnt-attr exclusive-lock where
                buf_chk-discnt-attr.doc-code = buf_chk-doc.doc-code and
                buf_chk-discnt-attr.record-type = 5 and
                buf_chk-discnt-attr.line-num = 0 and
                buf_chk-discnt-attr.attr-code = "promo-id" and
                buf_chk-discnt-attr.attr-value = Promo-Id no-error .
            if not available (buf_chk-discnt-attr) then
            do:
                create buf_chk-discnt-attr .
                assign
                    buf_chk-discnt-attr.doc-code        = buf_chk-doc.doc-code
                    buf_chk-discnt-attr.record-type     = 5
                    buf_chk-discnt-attr.line-num        = 0
                    buf_chk-discnt-attr.discnt-id       = (var-discnt-id + 1)
                    buf_chk-discnt-attr.object-line-num = 0
                    buf_chk-discnt-attr.attr-code       = "promo-id"
                    buf_chk-discnt-attr.attr-value      = Promo-Id
                    var-discnt-id                      = var-discnt-id + 1.
                .
            end.
            find first buf_chk-discnt exclusive-lock where
                       buf_chk-discnt.doc-code = buf_chk-discnt-attr.doc-code
                   and buf_chk-discnt.record-type = buf_chk-discnt-attr.record-type
                   and buf_chk-discnt.discnt-id = buf_chk-discnt-attr.discnt-id no-error.
            if available buf_chk-discnt then
            do:
                buf_chk-discnt.object-sum = buf_chk-discnt.object-sum + promo-count.
            end.
            else do:
                create buf_chk-discnt.
                assign
                    buf_chk-discnt.doc-code = buf_chk-doc.doc-code
                    buf_chk-discnt.record-type = buf_chk-discnt-attr.record-type
                    buf_chk-discnt.promo-id = Promo-Id
                    buf_chk-discnt.line-num = 0
                    buf_chk-discnt.object-sum = promo-count
                    buf_chk-discnt.discnt-id =  buf_chk-discnt-attr.discnt-id
                    buf_chk-discnt.object-line-num = 0
                    buf_chk-discnt.pay-desk = buf_chk-doc.pay-desk
                    buf_chk-discnt.obj-code = buf_chk-doc.obj-code
                    buf_chk-discnt.obj-type = buf_chk-doc.obj-type
                    buf_chk-discnt.chk-date = buf_chk-doc.chk-date
                    buf_chk-discnt.shift-date = buf_chk-doc.shift-date
                    buf_chk-discnt.shift-num = buf_chk-doc.shift-num
                    buf_chk-discnt.chk-time = buf_chk-doc.chk-time
                    .
                var-discnt-id = var-discnt-id + 1.
            end.
        end.
    end.
end procedure.
