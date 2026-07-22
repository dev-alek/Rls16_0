block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num no-undo .
DEFINE INPUT PARAMETER file_ as character no-undo.
define input parameter p-close-shift as logical no-undo .
define input parameter p-other as character no-undo .
define input-output parameter p-view-log as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: get-mari.p $":u .
define variable vss-archive     as character no-undo init "$Archive: str/get-mari.p $":u .
define variable vss-description as character no-undo init "Программа приема чеков с касс МАРИЯ" .
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alienini-getkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define output parameter o-value as char.
define variable EntryPointer as integer no-undo.
define variable mem1 as memptr no-undo.
define variable mem2 as memptr no-undo.
define variable mem1size as integer no-undo.
define variable mem2size as integer no-undo.
define variable ii       as integer    no-undo.
define variable cbReturnSize  as integer    no-undo.
assign
set-size(mem1)  = 4000
mem1size = 4000.
if i-key = "" then EntryPointer = 0.
else do:
  assign
  set-size(mem2) = 128
  mem2size = 128
  EntryPointer = get-pointer-value(mem2)
  put-string(mem2, 1) = i-key.
end.
run getprivateprofilestringA
                              (i-section,
                               EntryPointer,
                               "",
                               get-pointer-value(mem1),
                               input mem1size,
                               i-filename,
                               output cbReturnSize).
do ii = 1 to cbReturnSize:
  o-value = if (get-byte(mem1, ii) = 0 and ii ne cbReturnSize)
               then o-value + ","
               else o-value + chr(get-byte(mem1, ii)).
end.
  set-size(mem1) = 0.
  set-size(mem2) = 0.
end procedure.
procedure alienini-putkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define input parameter i-value as char.
define variable cbReturnSize as integer.
run writeprivateprofilestringA
                               (i-section,
                                i-key,
                                i-value,
                                i-filename,
                                output cbReturnSize ).
end procedure.
PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS LONG.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG.
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS LONG.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS LONG.
END PROCEDURE.
PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS LONG.
END PROCEDURE.
define  temp-table temp-tekka-tsk no-undo
field filename      as character
field obj-num       as integer
field obj-name      as character
field num-records   as integer
field max-records   as integer
field min-plu       as integer
field max-plu       as integer
field num-fields    as integer
field task-num      as character
field by-record     as logical
field send-get      as character
field cash-num      as integer
field cash-num-char as character
field port-num      as character
field way           as character
field is-script     as logical
field pswd          as character
field waiting-sek   as integer
field other-info    as character
field order-num     as integer
field secondary     as integer
field shift-fields  as integer
field binary        as logical
field range         as integer
index pi is unique primary
filename
range
index lpi
filename
min-plu
index gpi
filename
max-plu
index iorder
order-num
.
define  temp-table temp-tekka-schema no-undo
field obj-num as integer
field obj-name as character
field field-num as integer
field field-name as character
field num-records as integer
field size_ as integer
field host as character
field progress-type as character
field custom-type as character
field start-pos as integer
field end-pos as integer
field bin-group as character
index pi is unique primary
host obj-num field-num
.
define temp-table temp-tekka-record no-undo
field obj-num as integer
field plu as integer
field body as character
field shift as integer
index pi is unique primary obj-num plu.
FUNCTION tekka-is-closed-shift-journal returns integer ( input p-journal-num as integer ):
define variable v-is-closed-shift-journal as integer no-undo .
assign
v-is-closed-shift-journal = (if lookup( string( p-journal-num), '30,31,32,33':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '43':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '17':U) > 0 then 1 else 0)
.
return v-is-closed-shift-journal.
END FUNCTION.
FUNCTION tekka-is-first-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-first-journal as logical no-undo .
assign
v-is-first-journal = (p-journal-num =  integer(entry(1, '30,31,32,33':U)))
                  or (p-journal-num = integer(entry(1, '26,27,28,29':U)))
                  or (p-journal-num =  integer(entry(1, '17':U)))
                  or (p-journal-num = integer(entry(1, '16':U)))
.
return v-is-first-journal.
END FUNCTION.
FUNCTION tekka-is-petrol-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-petrol-journal as logical no-undo .
assign
v-is-petrol-journal = lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0.
return v-is-petrol-journal.
END FUNCTION.
FUNCTION tekka-get-max-journal-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489
                    else 2340).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-get-max-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489 * num-entries('30,31,32,33':U)
                    else 2340 * num-entries('17':U)).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-num-recs returns integer( input p-journal-num as integer
                                        ,input p-rec-no as integer):
define variable v-num-recs as integer no-undo .
if tekka-is-petrol-journal (p-journal-num) then do:
  if tekka-is-closed-shift-journal(p-journal-num) = 1 then do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '30,31,32,33':U))) * 1489 + p-rec-no
    .
  end.
  else do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '26,27,28,29':U)) ) * 1489 + p-rec-no
    .
  end.
end.
else do:
  if lookup(string(p-journal-num), '16,17':U) > 0 then do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '17':U))) * 2340 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '16':U)) ) * 2340 + p-rec-no
      .
    end.
  end.
  else do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '43':U))) * 2978 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '42':U)) ) * 2978 + p-rec-no
      .
    end.
  end.
end.
return v-num-recs.
END FUNCTION.
FUNCTION tekka-get-obj-num returns integer( input p-num-recs as decimal
                                           ,input p-is-petrol as logical
                                           ,input p-is-current as logical
                                           ,output p-rec-no as decimal
                                           ):
define variable v-obj-num0 as integer no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-num2 as integer no-undo .
define variable p-num-recs2 as integer no-undo .
define variable p-rec-no2 as integer no-undo .
if p-is-petrol then do:
  assign
  v-obj-num0 = trunc(p-num-recs / 1489, 0)
  .
  if p-is-current and num-entries('26,27,28,29':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '26,27,28,29':U))
  p-rec-no = p-num-recs modulo 1489
  .
  if not p-is-current and num-entries('30,31,32,33':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '30,31,32,33':U))
  p-rec-no = p-num-recs modulo 1489
  .
end.
else do:
  assign
  p-num-recs2 = (p-num-recs - trunc(p-num-recs, 0)) * 10000
  p-num-recs = trunc(p-num-recs, 0)
  v-obj-num0 = trunc(p-num-recs / 2340, 0)
  v-obj-num2 = trunc(p-num-recs2 / 2978, 0)
  .
  if p-is-current and num-entries('16':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '16':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if not p-is-current and num-entries('17':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '17':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if p-is-current and num-entries('42':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '42':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  if not p-is-current and num-entries('43':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '43':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  assign
  p-rec-no = p-rec-no + p-rec-no2 / 10000
  .
end.
if v-obj-num = 0 then v-obj-num = 100.
return v-obj-num.
END FUNCTION.
FUNCTION tekka-get-next-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '17':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
   if p-is-ptrl then
   return integer(entry(1, '26,27,28,29':U)).
   if not p-is-ptrl then
   return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
FUNCTION tekka-get-next-current-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical ):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '26,27,28,29':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
  if p-is-ptrl then
  return integer(entry(1, '26,27,28,29':U)).
  if not p-is-ptrl then
  return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
procedure tekkatsk-verify-schema :
define input parameter p-obj-list as character no-undo .
define input parameter p-dir-path as character no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-name as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-size_ as integer no-undo .
define variable v-value as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable ii-ibs as integer no-undo .
define variable ii-tekka as integer no-undo .
define variable v-result as character no-undo .
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer buf2_temp-tekka-schema for temp-tekka-schema.
  do
  on error undo, return error
  :
     for each buf_temp-tekka-schema:
       delete buf_temp-tekka-schema.
     end.
     input from value('tekkasch.d').
     repeat :
       create buf_temp-tekka-schema.
       import buf_temp-tekka-schema.
       assign
       buf_temp-tekka-schema.host = 'IBS'
       ii = ii + 1.
       .
     end.
     input close.
     ii-ibs = ii.
      _ii:
      do ii = 1 to 256:
        if p-obj-list = "ALL"
        or lookup(string(ii), p-obj-list) > 0 then do:
          assign
          v-obj-num = 0
          v-obj-name = ''
          v-num-records = 0
          v-size_ = 0
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'oname'
                                                  ,output v-value) no-error .
          if v-value = ? then next _ii.
          assign
          v-obj-num = ii
          v-obj-name = v-value
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'size'
                                                  ,output v-value) no-error .
          assign
          v-num-records = integer(v-value) no-error  .
          if error-status:error
          or v-num-records = 0 then next _ii.
          run alienini-getkey in this-procedure (
                                                   input  (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input 'obj' + string(ii, '999')
                                                  ,input 'f000'
                                                  ,output v-value) no-error .
          assign
          v-size_ = integer(v-value) no-error  .
          if error-status:error
          or v-size_ = 0 then next _ii.
          _jj:
          do jj = 1 to 256:
            run alienini-getkey in this-procedure (
                                                     input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999')
                                                    ,input 'f' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value = ? then next _ii.
            create buf_temp-tekka-schema.
            assign
            buf_temp-tekka-schema.host = 'tekka'
            buf_temp-tekka-schema.obj-num = v-obj-num
            buf_temp-tekka-schema.obj-name = v-obj-name
            buf_temp-tekka-schema.num-records = v-num-records
            buf_temp-tekka-schema.size_ = v-size_
            buf_temp-tekka-schema.field-num = jj
            buf_temp-tekka-schema.custom-type = entry(1, entry(2, v-value, '#'), ':')
            buf_temp-tekka-schema.bin-group = (if num-entries(entry(2, v-value, '#'), ':') > 1
                                               then entry(2, entry(2, v-value, '#'), ':')
                                               else '':U)
            buf_temp-tekka-schema.start-pos = integer(entry(1, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.end-pos = integer(entry(2, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.progress-type = entry( LOOKUP(buf_temp-tekka-schema.custom-type, 'Sx,B,BF,BN,UI,UL,FL,SL,VL':U)
                                                        , 'C,I,I,I,D,D,D,D,D':U)
            no-error
            .
            if error-status:error then do:
              delete buf_temp-tekka-schema.
              next _jj.
            end.
            run alienini-getkey in this-procedure (
                                                    input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999') + 'name'
                                                    ,input 'n' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value <> ? then
            buf_temp-tekka-schema.field-name = v-value.
          end.
        end.
      end.
      ii-tekka = ii - 1.
     if p-obj-list <> 'ALL' then do:
      if ii-tekka <> ii-ibs then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS &1 объектов&1по даным OLE-сервера &2"
                                , ii-ibs
                                , ii-tekka).
      end.
     end.
     for each buf_temp-tekka-schema where
            buf_temp-tekka-schema.host = 'tekka':
       find first buf2_temp-tekka-schema where
                 buf2_temp-tekka-schema.obj-num = buf_temp-tekka-schema.obj-num
             AND buf2_temp-tekka-schema.host = 'ibs'
             AND buf2_temp-tekka-schema.field-num = buf_temp-tekka-schema.field-num no-error .
       if not available buf2_temp-tekka-schema then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS нет поля &1 для объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
       buffer-compare buf_temp-tekka-schema
       to buf2_temp-tekka-schema
       save result in v-result.
       if v-result <> '':U then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS для поля &1 объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
     end.
  end.
end procedure.
FUNCTION set-Sx returns character (input p-string as character):
return p-string.
END FUNCTION.
FUNCTION get-Sx returns character (input p-string  as character):
return p-string.
END FUNCTION.
FUNCTION set-B returns character (input p-string  as character):
return chr(integer(p-string)).
END FUNCTION.
FUNCTION get-B returns character (input p-string  as character):
return string(asc(p-string)).
END FUNCTION.
FUNCTION set-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
do ii = 1 to 8:
  put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable ii as integer no-undo .
v-dopi = asc(p-string).
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
return v-dops.
END FUNCTION.
FUNCTION set-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-grp-nums as integer no-undo .
define variable v-dopi2 as integer no-undo .
v-grp-nums = num-entries(p-bin-group).
do jj = 0 to v-grp-nums - 1:
  v-dopi2 = integer(substring(p-string, jj + 1, 3)).
  do ii = 1 to 8:
    put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
  end.
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable v-grp-nums as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
v-dopi = asc(p-string).
v-grp-nums = num-entries(p-bin-group).
do jj = 1 to v-grp-nums:
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
end.
return v-dops.
END FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
procedure cp-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-range          as integer   no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'grp-code':U then do:     assign     p-label = "Группа платежа"     p-type = 'C':U      p-format = "X(45)"     p-label = "Группа платежа"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=grp-code':u      .   end.
            when 'is-use':U then do:     assign     p-label = "Используется"     p-type = 'C':U      p-format = "X(255)"     p-label = "Используется"     p-range = 4     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=is-use':u      .   end.
            when 'dop-doc':U then do:     assign     p-label = "Дополнительный документ"     p-type = 'C':U      p-format = "X(255)"     p-label = "Дополнительный документ"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=dop-doc':u      .   end.
            when 'paycard-all-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'form_km3':U then do:     assign     p-label = "Формировать КМ-3 по чекам возврата"     p-type = 'L':U      p-format = "+/-"     p-label = "Формировать КМ-3 по чекам возврата"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'bal_malina':U then do:     assign     p-label = "Оплата баллами Малина"     p-type = 'L':U      p-format = "+/-"     p-label = "Оплата баллами Малина"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'max_proc_sum':U then do:     assign     p-label = "Максимальный % порог от суммы"     p-type = 'D':U      p-format = ">>9.99"     p-label = "Максимальный % порог от суммы"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'mask_card_kup':U then do:     assign     p-label = "Маска карты\купона"     p-type = 'C':U      p-format = "x(129)"     p-label = "Маска карты\купона"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure cp-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для выгрузки в XML)"     p-label = "Префиксы платежных карт (для выгрузки в XML)" .   end.
            when 'grp-code':U then do:     assign     p-tooltip = "Группа платежа"     p-label = "Группа платежа" .   end.
            when 'is-use':U then do:     assign     p-tooltip = "Используется"     p-label = "Используется" .   end.
            when 'dop-doc':U then do:     assign     p-tooltip = "Дополнительный документ"     p-label = "Дополнительный документ" .   end.
            when 'paycard-all-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)" .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт, разрешенных для редактировани"     p-label = "Префиксы платежных карт, разрешенных для редактирования" .   end.
            when 'form_km3':U then do:     assign     p-tooltip = "Формировать КМ-3 по чекам возврата"     p-label = "Формировать КМ-3 по чекам возврата" .   end.
            when 'bal_malina':U then do:     assign     p-tooltip = "Оплата баллами Малина"     p-label = "Оплата баллами Малина" .   end.
            when 'max_proc_sum':U then do:     assign     p-tooltip = "Максимальный % порог от суммы"     p-label = "Максимальный % порог от суммы" .   end.
            when 'mask_card_kup':U then do:     assign     p-tooltip = "Маска карты\купона"     p-label = "Маска карты\купона" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure cp-attr-value :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input  parameter p-code        like ub.cash-pay-attr.attr-code      no-undo .
    define output parameter p-value       like ub.cash-pay-attr.attr-value    no-undo .
    define output parameter p-type        as character no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr no-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code  = p-code
      no-error .
    if avail buf_cash-pay-attr then do:
      assign
        p-value =  buf_cash-pay-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure cp-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define input parameter p-value    like ub.cash-pay-attr.attr-value no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define buffer last_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if not available buf_cash-pay-attr then do:
      create buf_cash-pay-attr .
      assign
      buf_cash-pay-attr.cdpay-code = p-cdpay-code
      buf_cash-pay-attr.curr-code  = p-curr-code
      buf_cash-pay-attr.host-code  = p-host-code
      buf_cash-pay-attr.obj-type   = p-obj-type
      buf_cash-pay-attr.obj-code   = p-obj-code
      buf_cash-pay-attr.attr-code = p-code
      .
    end.
    assign
      buf_cash-pay-attr.attr-value = p-value
    .
    release buf_cash-pay-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cp-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if  available buf_cash-pay-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure cp-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_cash-pay-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_cash-pay-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure cp-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-news = true.   end.
            when 'grp-code':U then do:     assign     p-news = true.   end.
            when 'is-use':U then do:     assign     p-news = true.   end.
            when 'dop-doc':U then do:     assign     p-news = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-news = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-news = true.   end.
            when 'form_km3':U then do:     assign     p-news = false.   end.
            when 'bal_malina':U then do:     assign     p-news = false.   end.
            when 'max_proc_sum':U then do:     assign     p-news = true.   end.
            when 'mask_card_kup':U then do:     assign     p-news = true.   end.
      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.
procedure cp-attr-hist :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-hist           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-hist = true.   end.
            when 'form_km3':U then do:     assign     p-hist = true.   end.
            when 'bal_malina':U then do:     assign     p-hist = true.   end.
            when 'max_proc_sum':U then do:     assign     p-hist = true.   end.
            when 'mask_card_kup':U then do:     assign     p-hist = true.   end.
      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.
DEFINE VARIABLE accept-types               as   character no-undo .
define variable v-flag-card                as   logical   no-undo .
define variable v-end-of-check             as   logical no-undo init yes.
define variable is-cdinv                   as character no-undo .
define variable v-is-petrol-check          as logical no-undo .
define variable prev-z-count               as integer no-undo .
define variable v-hundred as logical no-undo .
define temp-table tt-ss no-undo
field z-count as integer
field chk-num as integer
field jour-no as integer
field rec-no as integer
field is-head as logical
field is-shift as logical
field num-fields as integer
field first-check as logical
field n-entry  as character extent 20
field hundred as logical
index pi is unique primary jour-no rec-no
index ihead is-head
index ichkn chk-num
index ishift is-shift
.
define buffer buf_tt-ss for tt-ss.
define variable v-petrol-mode              as logical no-undo .
define variable mariapayg as character no-undo .
define variable mariapayp as character no-undo .
define variable v-rec-no as integer no-undo .
define variable v-rec-no2 as integer no-undo .
define variable v-jour-no as integer no-undo .
define variable v-jour-no2 as integer no-undo .
define variable v-rec-no-start-check as integer no-undo .
define variable v-shift-date as date no-undo .
define variable v-first-check-in-jo as logical no-undo init yes.
define variable v-first-journal as logical no-undo .
define variable v-two-files as logical no-undo .
define variable filename2 as character no-undo .
define temp-table temp-cash-desk no-undo
field last-date like ub.chk-doc.chk-date
field last-z-count like ub.chk-doc.z-number
field last-num-recs as decimal
field last-p-date like ub.chk-doc.chk-date
field last-p-z-count like ub.chk-doc.z-number
field last-p-num-recs as integer
field cash-num like ub.cash-desk.cash-num
index pi is unique primary
cash-num.
assign
shop-type = p-obj-type
shop-code = p-obj-code
dflt-cd = p-pos-type
.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
FUNCTION convert-pay-code returns integer (input p-spool-pay-code as integer
                                          , output p-curr-code as integer
                                             ):
define variable v-cdpay-code like ub.cash-pay.cdpay-code no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo .
p-curr-code = ?.
_do:
do ii = 1 to num-entries(mariapayg, ';'):
  v-entry = entry(ii, mariapayg, ';').
  if v-entry begins substitute("&1/", p-spool-pay-code) then do:
     assign
     v-cdpay-code = integer(entry(1, entry(2, v-entry, chr(47))))
     p-curr-code =  integer(entry(2, entry(2, v-entry, chr(47))))
     no-error
     .
     leave _do.
  end.
end.
if p-curr-code = ? then
assign
p-curr-code = 0
v-cdpay-code = 0
.
return v-cdpay-code.
END FUNCTION.
FUNCTION convert-pet-pay-code returns integer (input p-spool-pay-code as integer
                                             , input p-emitent-code as integer
                                             , input p-petrol-card as character
                                             , output p-curr-code as integer
                                             ):
define variable v-cdpay-code like ub.cash-pay.cdpay-code no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
p-curr-code = ?.
if p-petrol-card <> '':U then do:
  p-petrol-card = string(integer(p-petrol-card)).
  for each buf_cash-pay-attr no-lock where
          buf_cash-pay-attr.attr-code = 'paycard-all-prefix':U:
    do ii = 1 to num-entries(buf_cash-pay-attr.attr-value):
       if p-petrol-card begins string(decimal(entry(ii, buf_cash-pay-attr.attr-value))) then do:
          assign
          v-cdpay-code = buf_cash-pay-attr.cdpay-code
          p-curr-code = buf_caSH-PAY-ATTR.CURR-CODE
          .
          LEAVE.
       end.
    end.
  end.
end.
else do:
  _do:
  do ii = 1 to num-entries(mariapayp, ';'):
    v-entry = entry(ii, mariapayp, ';').
    if v-entry begins substitute("&1,&2/", p-spool-pay-code, p-emitent-code) then do:
      assign
      v-cdpay-code = integer(entry(1, entry(2, v-entry, chr(47))))
      p-curr-code =  integer(entry(2, entry(2, v-entry, chr(47))))
      no-error
      .
      leave _do.
    end.
  end.
end.
if p-curr-code = ? then
assign
p-curr-code = 0
v-cdpay-code = 0
.
return v-cdpay-code.
END FUNCTION.
FUNCTION convert-chk-type returns integer( input p-spool-chk-type as character):
define variable v-chk-type like ub.chk-doc.chk-type no-undo .
CASE p-spool-chk-type:
  when '001':U then do:
     v-chk-type = integer('1':U).
  end.
  when '002':U  then do:
     v-chk-type = integer('6':U).
  end.
END CASE.
return v-chk-type.
END FUNCTION.
FUNCTION convert-pet-chk-type returns integer( input p-spool-chk-type as character):
define variable v-chk-type like ub.chk-doc.chk-type no-undo .
CASE p-spool-chk-type:
  when '001':U
  or
  when '002':U  then do:
     v-chk-type = integer('1':U).
  end.
  when '003':U then do:
     v-chk-type = integer('6':U).
  end.
  when '004':U then do:
     v-chk-type = integer('17':U).
  end.
  when '005':U then do:
     v-chk-type = integer('15':U).
  end.
END CASE.
return v-chk-type.
END FUNCTION.
RUN get-mari-c in this-procedure ( input file_ ) no-error .
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
PROCEDURE get-mari-c.
define input parameter filename as char no-undo.
define variable rr as integer no-undo .
define variable v-l as integer no-undo .
define variable v-check-es as logical no-undo .
define buffer buf_cash-desk for ub.cash-desk.
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
if index('16-42,17-43,':U, string(integer(v-file-name-ext)) + '-') > 0 then do:
  assign
  v-file-name-ext = substring('16-42,17-43,':U, index('16-42,17-43,':U, string(integer(v-file-name-ext)) + '-'))
  v-file-name-ext = entry(2, v-file-name-ext, '-')
  v-file-name-ext = entry(1, v-file-name-ext)
  .
  filename2 = v-path + chr(47) + v-file-name-no-ext + '.' + string(integer(v-file-name-ext), '999').
  if search( filename2) <> ? then do:
     v-two-files = yes.
  end.
end.
run get-mar-parameters in this-procedure ( input v-file-name-ext) no-error.
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
error-status:error = FALSE.
do rr = 1 to (if v-two-files then 2 else 1):
  if rr = 1 then do:
    input stream ChkStream from value( filename ).
  end.
  if rr = 2 then do:
    input stream ChkStream from value( filename2 ).
  end.
  _repeat:
  REPEAT :
    import stream ChkStream unformatted ss.
    assign
    var-file-line-num = var-file-line-num + 1
    .
    if var-file-line-num modulo 100 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle ( substitute("Файл &1: предварительно прочитано строк &2", filename, var-file-line-num)).
    end.
    if ss = '':U
    or ss = ? then next _repeat.
    assign
    v-first-check-in-jo = (v-jour-no <> integer(entry(1, ss, chr(3))))
    v-jour-no = integer(entry(1, ss, chr(3)))
    v-rec-no = integer(entry(2, ss, chr(3)))
    ss = entry(3, ss, chr(3))
    no-error
    .
    if error-status:error then do:
      if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
    end.
    if v-first-check-in-jo then do:
      assign
      v-first-journal = tekka-is-first-journal (v-jour-no)
      .
    end.
    find first tt-ss where
                tt-ss.jour-no = v-jour-no
            and tt-ss.rec-no = v-rec-no no-error .
    if not available tt-ss then do:
      create tt-ss.
      assign
      tt-ss.jour-no = v-jour-no
      tt-ss.rec-no = v-rec-no
      tt-ss.is-head = (rr = 1)
      tt-ss.first-check = (v-first-journal and tt-ss.rec-no = 1)
      .
      if ss begins 'close-shift=' then do:
        tt-ss.is-shift  = yes.
      end.
      if ss begins 'tekka-date-time=' then do:
        run tekka-date-time in this-procedure ( input entry(2, ss, '=':U), input entry(3, ss, '=':U )) no-error .
        delete tt-ss.
        next _repeat.
      end.
      DO ii = 1 to num-entries(ss, chr(4)):
        v-check-es = no.
        tt-ss.n-entry[ii] = entry(ii, ss, chr(4)) .
        if tt-ss.is-shift = no then do:
          if v-petrol-mode then do:
            if ii = 9 then do:
              assign
              tt-ss.chk-num = integer(tt-ss.n-entry[ii])
              no-error
              .
              v-check-es = yes.
            end.
            if ii = 5 then do:
              assign
              tt-ss.z-count = integer(tt-ss.n-entry[ii])
              tt-ss.hundred = (if tt-ss.z-count = 0 or tt-ss.z-count = 100 then yes else no)
              tt-ss.z-count = (if tt-ss.hundred then 11 else tt-ss.z-count)
              no-error
              .
              v-check-es = yes.
            end.
          end.
          else do:
            if (rr = 1 and ii = (7 + 0) )
            or (rr = 2 and ii = 3 )
            then do:
              assign
              tt-ss.chk-num = integer(tt-ss.n-entry[ii])
              no-error
              .
              v-check-es = yes.
            end.
            if (rr = 1 and ii = 1 )
            then do:
              assign
              tt-ss.z-count = integer(tt-ss.n-entry[ii])
              tt-ss.hundred = (if tt-ss.z-count = 0 or tt-ss.z-count = 100 then yes else no)
              tt-ss.z-count = (if tt-ss.hundred then 11 else tt-ss.z-count)
              no-error
              .
              v-check-es = yes.
            end.
          end.
          if v-check-es = yes
          and error-status:error then do:
            if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
          end.
        end.
      END.
      tt-ss.num-fields = ii - 1.
    end.
  end.
  input stream ChkStream close.
end.
if v-petrol-mode then do:
  _tt-ss1:
  for each tt-ss:
    if tt-ss.is-shift then do:
      run proc-shift in this-procedure ( buffer tt-ss, input tt-ss.num-fields ) no-error .
      next _tt-ss1.
    end.
    else do:
      run proc-petrol-str in this-procedure no-error .
      run proc-end in this-procedure no-error .
    end.
  end.
end.
else do:
  _tt-ss2:
  for each tt-ss where
          tt-ss.is-head = yes:
    if tt-ss.is-shift then do:
      run proc-shift in this-procedure ( buffer tt-ss, input tt-ss.num-fields ) no-error .
    end.
    else do:
      v-l = 0.
      _v-l:
      for  each buf_tt-ss where
           buf_tt-ss.is-head = no
        and buf_tt-ss.chk-num = tt-ss.chk-num:
        assign
        v-jour-no2 = buf_tt-ss.jour-no
        v-rec-no2 = buf_tt-ss.rec-no
        v-l = v-l + 1
        .
        run proc-str in this-procedure ( input (v-l = 1)) no-error .
        if exist then leave _v-l.
      end.
      if not exist then do:
        run proc-end in this-procedure no-error .
      end.
        run process-maria-attr in this-procedure ( input (tekka-num-recs(tt-ss.jour-no, tt-ss.rec-no) +
                                                          tekka-num-recs(v-jour-no2, v-rec-no2) / 10000) ).
    end.
  end.
END .
for each temp-cash-desk:
  find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = g#db-num
        AND buf_cash-desk.obj-code = p-obj-code
        AND buf_cash-desk.pos-type = 'MARIA':U
        AND buf_cash-desk.cash-num = temp-cash-desk.cash-num no-error .
  if available buf_cash-desk then do:
    run cd-attr-write in this-procedure (
                                           input g#db-num
                                          ,input p-obj-code
                                          ,input 'MARIA':U
                                          ,input temp-cash-desk.cash-num
                                          ,input 'MARIA_operative':U
                                          ,input 'last-check-maria':U
                                          ,input (cd-attr-CD-DatetoString (temp-cash-desk.last-date)  + chr(32) +
                                                  string(temp-cash-desk.last-z-count) + chr(32) +
                                                  string(temp-cash-desk.last-num-recs) + chr(32) +
                                                  cd-attr-CD-DatetoString (temp-cash-desk.last-p-date)  + chr(32) +
                                                  string(temp-cash-desk.last-p-z-count) + chr(32) +
                                                  string(temp-cash-desk.last-p-num-recs) )
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input no
                                                  ) no-error .
    if error-status:error then
    message
    error-status:get-message(1) return-value
    view-as alert-box .
  end.
end.
END PROCEDURE.
procedure proc-end :
  do
  on error undo, return error
  :
     get-chkc_context.ll = lll.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
     assign
     prev-code = "":U
     p-view-log = (p-view-log or get-chkc_context.view-log)
     lll = get-chkc_context.ll
     .
  end.
end procedure.
procedure proc-str :
define input parameter p-check-start as logical no-undo .
DEFINE VARIABLE pre-pay-type as character no-undo .
DEFINE VARIABLE cur-pay-type as character no-undo .
DEFINE VARIABLE TotSum-Value as decimal no-undo .
define variable v-year as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-clu_ as integer no-undo .
define variable v-discnt-dir as integer no-undo .
define variable pay-type2 as character no-undo .
define variable pay_code2 as integer no-undo .
define variable curr_code2 as integer no-undo .
define variable tot_sum2 as decimal no-undo .
define variable pp as integer no-undo .
define variable discnt-from-check-prim as decimal no-undo .
define variable file_ as character no-undo .
define buffer buf_shift-cash for ub.shift-cash.
do
on error undo, return error return-value
:
  if p-check-start then do:
    assign
    gbl-type = tt-ss.n-entry[3]
    .
    if lookup (gbl-type, accept-types) = 0 then do:
      assign
      exist = yes
      .
      return.
    end.
    assign
    v-is-petrol-check = no
    chk-date_ = 01/01/1990
    chk-time_ = 0
    shift-date_ = chk-date_
    shift-num_ = 0
    shift-name_ = ''
    shop-code = 0
    shop-type = "":U
    sales-man_ = 0
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
    exist = no
    .
    run cur-time in this-procedure ( output v-today, output v-time).
    assign
    v-year    = (if int( substr( tt-ss.n-entry[6 + 0 ], 1, 3 ) ) = month(v-today)
                  then year(v-today)
                  else year(v-today) - 1)
    chk-date_ = date(
                        int( substr( tt-ss.n-entry[6 + 0 ], 1, 3 ) ),
                        int( substr( tt-ss.n-entry[6 + 0 ], 4, 2 ) ),
                        int( v-year)
                        )
    chk-time_ =  int( substr( tt-ss.n-entry[5 + 0 ], 1, 3 ) ) * 3600 +
                 int( substr( tt-ss.n-entry[5 + 0 ], 4, 2 ) ) * 60
    shop-code = p-obj-code
    shop-type = p-obj-type
    chk-num_ = tt-ss.chk-num
    sales-man_ = 0
    cashier_ = integer( tt-ss.n-entry[2] )
    pay-desk_ = p-cash-num
    z-num_ =  tt-ss.z-count
    cash-rate_ = 1
    d-card_   = '':U
    v-clu_ = 0
    cli-type_ =  '':U
    cli-code_ = 0
    shift-num_ =  z-num_
    shift-name_ = string(shift-num_)
    shift-num_ = if get-chkc_context.shift-on then 0 else shift-num_
    doc-num_ = '':U
    chk-type_ = convert-chk-type(gbl-type)
    pay-type = substring(tt-ss.n-entry[4], 1, 3)
    pay_code = convert-pay-code(input integer(pay-type), output curr_code)
    pay-type2 = (if 0 = 1
                 then tt-ss.n-entry[5]
                 else substring(tt-ss.n-entry[4], 4, 3))
    pay_code2 = (if pay-type2 <> '000':U
                then convert-pay-code(input integer(pay-type2), output curr_code2)
                else 0)
    tot_sum  = integer(tt-ss.n-entry[8 + 0]) / 100
    tot_sum2  = integer(tt-ss.n-entry[9 + 0]) / 100
    pay-card_ = tt-ss.n-entry[10 + 0] + tt-ss.n-entry[11 + 0]
    no-error .
    .
    if error-status:error then do:
      var-file-line-num = tt-ss.rec-no.
      if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
    end.
    if tt-ss.first-check then do:
      v-shift-date = chk-date_.
    end.
    else do:
      if tt-ss.z-count <> prev-z-count then do:
        find first buf_shift-cash  no-lock where
                  buf_shift-cash.obj-type = p-obj-type
              and buf_shift-cash.obj-code = p-obj-code
              and buf_shift-cash.cash-num = p-cash-num
              and buf_shift-cash.shift-date >= (chk-date_ - 1)
              and buf_shift-cash.z-num = (if tt-ss.hundred then 100 else tt-ss.z-count) no-error.
        if available buf_shift-cash then do:
          v-shift-date = buf_shift-cash.shift-date.
        end.
        else do:
          run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при обработке данных с кассы &1: Невозможно получить дату смены с № &2"
                                    , p-cash-num
                                    , tt-ss.z-count
                                  )
                                                  ).
          assign
          p-view-log = yes
          .
        end.
      end.
      prev-z-count = tt-ss.z-count.
    end.
    assign
    shift-date_ = if cas-shft
                  then v-shift-date
                  else chk-date_
    .
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
    IF (NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc)
    then do:
      CREATE ub.chk-doc.
      assign
      lll = lll + 1
      exist = no
      lng = 0
      lnp = 0
      cr = 0
      sub-d = 0
      var-discnt-id = 0
      lng-sub-d = 0
      netto-for-sub-d = 0
      v-rec-no-start-check = v-rec-no
      ub.chk-doc.pay-desk = p-cash-num
      ub.chk-doc.chk-num = chk-num_
      ub.chk-doc.obj-type = p-obj-type
      ub.chk-doc.obj-code = p-obj-code
      ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                          then string(next-value(s-chk, ub))
                          else string( shop-code ) + chr(47) + string( next-value( s-chk, ub ) ))
      ub.chk-doc.office = ?
      for-chk-type = ""
      prev-code = ub.chk-doc.doc-code
      ub.chk-doc.sales-man = sales-man_
      ub.chk-doc.chk-date = chk-date_
      ub.chk-doc.chk-time = chk-time_
      ub.chk-doc.shift-date = ub.chk-doc.chk-date
      ub.chk-doc.src-shift-date = ub.chk-doc.shift-date
      ub.chk-doc.cash-rate = 1
      ub.chk-doc.cash-scale = 1
      ub.chk-doc.z-number = z-num_
      ub.chk-doc.correct = yes
      ub.chk-doc.d-pcnt = 0
      ub.chk-doc.src-d-pcnt = 0
      ub.chk-doc.shift-num = (if cas-shft then shift-num_ else 0)
      ub.chk-doc.cashier = cashier_
      ub.chk-doc.chk-type = chk-type_
      ub.chk-doc.correct = yes
      ub.CHK-DOC.discnt = 0
      ub.chk-doc.src-d-card =  d-card_
      ub.chk-doc.src-d-pcnt = 0
      ub.chk-doc.src-shift-date = (if cas-shft then shift-date_ else chk-date_)
      ub.chk-doc.cash-rate = 1
      ub.chk-doc.cash-scale = 1
      ub.chk-doc.z-number = z-num_
      ub.chk-doc.doc-num = doc-num_ + (if shift-name_ <> '':U
                                      then (chr(4) + shift-name_)
                                      else '':U)
      ub.chk-doc.correct = yes
      .
    end.
    else do:
      assign
      exist = yes
      .
      return.
    end.
  end.
  assign
  v-discnt-dir = (if substring(buf_tt-ss.n-entry[1], 1, 3) = '001' then 1 else - 1)
  bc-buf = left-trim(buf_tt-ss.n-entry[4], '0')
  curr-string-qnty = integer(buf_tt-ss.n-entry[5]) / 10000 * (if chk-type_ = integer('6':U) then -1 else 1)
  Sum-from-check = integer(buf_tt-ss.n-entry[7]) / 100  * (if chk-type_ = integer('6':U) then -1 else 1)
  price-from-check =  abs(sum-from-check / curr-string-qnty)
  discnt-from-check = integer(buf_tt-ss.n-entry[6]) / 100 * (if chk-type_ = integer('6':U) then -1 else 1) * v-discnt-dir
  discnt-from-check-prim = discnt-from-check / abs(curr-string-qnty) * (if chk-doc.chk-type = integer('6':U)
                                                                        then - 1
                                                                        else 1)
  no-error .
  if error-status:error then do:
     var-file-line-num = buf_tt-ss.rec-no.
     file_ = filename2.
    if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
  end.
  IF not AVAILABLE ub.CHK-GDS
    or NOT (ub.chk-gds.doc-code = ub.chk-doc.doc-code
            AND ub.chk-gds.src-code = bc-buf)
    or NOT (ub.chk-gds.doc-code = ub.chk-doc.doc-code
        AND ub.chk-gds.src-code = bc-buf
        AND pre-pay-type = cur-pay-type
        AND round(ub.chk-gds.src-discnt, 2) = round(discnt-from-check / curr-string-qnty, 2)
        )
    or not (ub.chk-gds.doc-code = ub.chk-doc.doc-code
            and ub.chk-gds.line-num = tt-ss.rec-no - v-rec-no-start-check + 1)
    or not ub.chk-gds.src-price = price-from-check
      then do:
    CREATE ub.chk-gds.
    assign
    lng = lng + 1
    ub.chk-gds.doc-code = chk-doc.doc-code
    ub.chk-gds.line-num = lng
    ub.chk-gds.chk-date = chk-doc.chk-date
    pre-pay-type = cur-pay-type
    ub.chk-gds.b-code =  0
    ub.chk-gds.grp-code = 0
    ub.chk-gds.src-code = bc-buf
    ub.chk-gds.is-error = no
    ub.chk-gds.discnt = 0
    ub.chk-gds.time-oper = chk-doc.chk-time
    ub.chk-gds.src-qnty = 0
    ub.chk-gds.doc-qnty = 0
    ub.chk-gds.src-price = price-from-check
    ub.chk-gds.src-sum = 0
    ub.chk-gds.src-qnty = curr-string-qnty
    ub.chk-gds.src-discnt = discnt-from-check-prim
    ub.chk-gds.pass-gds = 0
    ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer('1':U)
                        then (ub.chk-gds.src-qnty >= 0)
                        else (ub.chk-gds.src-qnty <= 0)
                        )
    ub.chk-gds.line-type =  "":U
    .
  end.
  else do:
    assign
    ub.chk-gds.src-discnt = (ub.chk-gds.src-discnt * abs(ub.chk-gds.src-qnty) + discnt-from-check-prim * abs(curr-string-qnty)) / abs( chk-gds.src-qnty + curr-string-qnty)
    ub.chk-gds.src-qnty = ub.chk-gds.src-qnty + curr-string-qnty
    .
  end.
  assign
  ub.chk-gds.src-sum = ub.chk-gds.src-sum + sum-from-check
  .
  if ub.chk-gds.src-discnt <> 0 then do:
    create ub.chk-discnt.
    assign
    ub.chk-discnt.doc-code = ub.chk-doc.doc-code
    ub.chk-discnt.record-type = 0
    ub.chk-discnt.discnt-id = (var-discnt-id + 1)
    ub.chk-discnt.line-num = ub.chk-gds.line-num
    ub.chk-discnt.time-oper = ub.chk-doc.chk-time
    ub.chk-discnt.line-type = integer('1':U)
    ub.chk-discnt.line-sign =  (ub.chk-gds.src-qnty >= 0 ) NE (ub.chk-gds.src-discnt > 0 )
    ub.chk-discnt.pass-discnt = integer('0':U)
    ub.chk-discnt.value-type = integer('0':U)
    ub.chk-discnt.discnt-type = integer('0':U)
    ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
    ub.chk-discnt.discnt-value-abs = ub.chk-gds.src-discnt
    ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
    ub.chk-discnt.object-sum = ub.chk-gds.src-sum
    ub.chk-discnt.discnt-value-pcnt = if ub.chk-gds.src-sum <> 0 then
                                    ub.chk-gds.src-discnt / ub.chk-gds.src-sum * 100
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
  if p-check-start then do:
    do pp = 1 to (if pay_code2 > 0 then 2 else 1):
      if pp = 2 then do:
        assign
        pay_code = pay_code2
        curr_code = curr_code2
        tot_sum = tot_sum2
        .
      end.
      FIND ub.chk-pay where
              ub.chk-pay.doc-code = ub.chk-doc.doc-code AND
              ub.chk-pay.curr-code = curr_code AND
              ub.chk-pay.pay-code = pay_code      NO-ERROR.
      if NOT available ub.chk-pay then do:
        CREATE ub.chk-pay.
        assign
        lnp = lnp + 1
        ub.chk-pay.doc-code = ub.chk-doc.doc-code
        ub.chk-pay.line-num = lnp
        ub.chk-pay.chk-date = ub.chk-doc.chk-date
        ub.chk-pay.obj-code = p-obj-code
        ub.chk-pay.obj-type = p-obj-type
        ub.chk-pay.pay-code = pay_code
        ub.chk-pay.pay-card = pay-card_
        ub.chk-pay.curr-code = curr_code
        ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + tot_sum * (if chk-type_ = integer('6':U) then -1 else 1)
        ub.chk-pay.time-oper = ub.chk-doc.chk-time
        ub.chk-pay.line-type = "":U
        ub.chk-pay.line-sign =  (if ub.chk-doc.chk-type = integer('1':U)
                              then (ub.chk-pay.tot-sum >= 0)
                              else (ub.chk-pay.tot-sum <= 0)
                              )
        ub.chk-pay.cash-rate = 1
        ub.chk-pay.bank-rate = 1
        ub.chk-pay.bank-scale = 1
        ub.chk-pay.pass-pay  = 0
        ub.chk-pay.is-error = no
        .
      end.
      else do:
        assign
        ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + tot_sum * (if chk-type_ = integer('6':U) then -1 else 1)
        .
      end.
    end.
  end.
end.
end procedure.
procedure proc-petrol-str :
DEFINE VARIABLE pre-pay-type as character no-undo .
DEFINE VARIABLE cur-pay-type as character no-undo .
DEFINE VARIABLE TotSum-Value as decimal no-undo .
define variable v-year as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-clu_ as integer no-undo .
define variable v-discnt-dir as integer no-undo .
define variable bc-buf-int as integer no-undo .
define variable v-emitent as integer no-undo .
define variable discnt-from-check-prim as decimal no-undo .
define variable v-petrol-plus as logical no-undo .
define variable v-forma-opl as integer no-undo .
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cd-clu for ub.cd-clu.
define buffer buf_shift-cash for ub.shift-cash.
do
on error undo, return error
:
  assign
  gbl-type = substring(tt-ss.n-entry[1], 7, 3)
  .
  if can-do(accept-types,  gbl-type ) then do:
    assign
    v-is-petrol-check = no
    chk-date_ = 01/01/1990
    chk-time_ = 0
    shift-date_ = chk-date_
    shift-num_ = 0
    shift-name_ = ''
    shop-code = 0
    shop-type = "":U
    sales-man_ = 0
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
    exist = no
    .
    run cur-time in this-procedure ( output v-today, output v-time).
    assign
    v-discnt-dir = (if substring(tt-ss.n-entry[1], 1, 3) = '001' then 1 else - 1)
    chk-type_ = convert-pet-chk-type(gbl-type)
    v-year    = (if int( substr( tt-ss.n-entry[8], 1, 3 ) ) = month(v-today)
                  then year(v-today)
                  else year(v-today) - 1)
    chk-date_ = date(
                        int( substr( tt-ss.n-entry[8], 1, 3 ) ),
                        int( substr( tt-ss.n-entry[8], 4, 2 ) ),
                        int( v-year)
                        )
    chk-time_ =  int( substr( tt-ss.n-entry[7], 1, 3 ) ) * 3600 + int( substr( tt-ss.n-entry[7], 4, 2 ) ) * 60
    shift-date_ = if get-chkc_context.cas-shft
                  then v-shift-date
                  else chk-date_
    shop-code = p-obj-code
    shop-type = p-obj-type
    chk-num_ = tt-ss.chk-num
    sales-man_ = 0
    cashier_ = integer( trim( tt-ss.n-entry[6] ) )
    pay-desk_ = p-cash-num
    z-num_ =  tt-ss.z-count
    cash-rate_ = 1
    pay-card_   = tt-ss.n-entry[15] + tt-ss.n-entry[16]
    pay-card_ = (if trim(pay-card_, '0') = '':U then '':U else pay-card_)
    v-forma-opl = integer(substring(tt-ss.n-entry[2], 3))
    v-petrol-plus = if ((v-forma-opl = 0 or v-forma-opl = 1)
                    AND
                    integer(substring(tt-ss.n-entry[3], 4, 3)) = 20
                    and
                    (integer(substring(tt-ss.n-entry[1], 4, 3)) = 1 or integer(substring(tt-ss.n-entry[1], 4, 3)) = 2)
                    )
                    then yes
                    else no
    v-clu_ = (if v-forma-opl <> 255
              and not v-petrol-plus
              then (v-forma-opl + 1)
              else 0)
    shift-num_ =  z-num_
    shift-name_ = string(shift-num_)
    shift-num_ = if get-chkc_context.shift-on then 0 else shift-num_
    doc-num_ = tt-ss.n-entry[10]
    bc-buf = substring(tt-ss.n-entry[3], 1, 3)
    bc-buf-int = integer(bc-buf)
    price-from-check =  integer( tt-ss.n-entry[12]) / 100
    curr-string-qnty = integer(tt-ss.n-entry[11]) / 100 * (if chk-type_ = integer('6':U) then -1 else 1)
    Sum-from-check = integer(tt-ss.n-entry[14]) / 100 * (if chk-type_ = integer('6':U) then -1 else 1)
    discnt-from-check     = integer(tt-ss.n-entry[13]) / 100 * (if chk-type_ = integer('6':U) then -1 else 1) * v-discnt-dir
    discnt-from-check-prim =  discnt-from-check / abs(curr-string-qnty) * (if chk-type_ = integer('6':U)
                                                                            then - 1
                                                                            else 1)
    pay-type = substring(tt-ss.n-entry[1], 4, 3)
    v-emitent = integer(substring(tt-ss.n-entry[3], 4, 3))
        v-emitent = (if v-emitent = 31 then 0 else v-emitent)
    pay_code = (if chk-type_ = integer('17':U)
                or chk-type_ = integer('15':U)
                then 0
                else convert-pet-pay-code(input integer(pay-type)
                                  , input v-emitent
                                  , input (if v-petrol-plus then pay-card_ else '':U)
                                  , output curr_code))
    pump_ = integer(substring(tt-ss.n-entry[4], 1, 3)) + 1
    nozzle_ = integer(substring(tt-ss.n-entry[4], 4, 3)) + 1
    no-error .
    if error-status:error then do:
      var-file-line-num = tt-ss.rec-no.
      if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
    end.
    if tt-ss.first-check then do:
      v-shift-date = chk-date_.
    end.
    else do:
      if tt-ss.z-count <> prev-z-count then do:
        find first buf_shift-cash  no-lock where
                  buf_shift-cash.obj-type = p-obj-type
              and buf_shift-cash.obj-code = p-obj-code
              and buf_shift-cash.cash-num = p-cash-num
              and buf_shift-cash.shift-date >= (chk-date_ - 1)
              and buf_shift-cash.z-num = (if tt-ss.hundred then 100 else tt-ss.z-count) no-error.
        if available buf_shift-cash then do:
          v-shift-date = buf_shift-cash.shift-date.
        end.
        else do:
          run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при обработке данных с кассы &1: Невозможно получить дату смены с № &2"
                                    , p-cash-num
                                    , tt-ss.z-count
                                  )
                                                  ).
          assign
          p-view-log = yes
          .
        end.
      end.
      prev-z-count = tt-ss.z-count.
    end.
    assign
    shift-date_ = if cas-shft
                  then v-shift-date
                  else chk-date_
    .
    find first buf_cd-plu no-lock where
           buf_cd-plu.obj-type = p-obj-type
       and buf_cd-plu.obj-code = p-obj-code
       and buf_cd-plu.pos-type = 'MARIA':U
       and buf_cd-plu.plu-type = 'топ':U
       and buf_cd-plu.plu-code = (bc-buf-int + 1)  no-error .
    if not available buf_cd-plu then do:
      assign
      bc-buf = chr(4) + bc-buf.
    end.
    else do:
      assign
      bc-buf = string(buf_cd-plu.b-str) + chr(4) + string(bc-buf-int + 1, '99999':U).
    end.
    if v-clu_ <> 0 then do:
      find first buf_cd-clu no-lock where
               buf_cd-clu.obj-type = p-obj-type
           and buf_cd-clu.obj-code = p-obj-code
           and buf_cd-clu.pos-type = 'MARIA':U
           and buf_cd-clu.clu-type = '':U
           and buf_cd-clu.clu-code = v-clu_
      no-error .
      if not available buf_cd-clu then do:
        assign
        cli-type_ = '':U
        cli-code_ = 0
        .
      end.
      else do:
        assign
        cli-type_ = buf_cd-clu.cli-type
        cli-code_ = buf_cd-clu.cli-code
        d-card_   =  ('K':U + string(if cli-type_ = 'орг':U then 1 else 0) + string(cli-code_, '999999999'))
        .
      end.
    end.
  end.
  else do:
    assign
    exist = yes
    .
    return.
  end.
  if can-do( accept-types , gbl-type ) then do:
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
    IF (NOT AVAIL ub.chk-doc AND NOT LOCKED ub.chk-doc  AND NOT AMBIGUOUS ub.chk-doc)
    then do:
        run proc-end in this-procedure .
        CREATE ub.chk-doc.
        assign
        lll = lll + 1
        exist = no
        lng = 0
        lnp = 0
        cr = 0
        sub-d = 0
        var-discnt-id = 0
        lng-sub-d = 0
        netto-for-sub-d = 0
        v-rec-no-start-check = v-rec-no
        ub.chk-doc.pay-desk = pay-desk_
        ub.chk-doc.chk-num = chk-num_
        ub.chk-doc.obj-type = p-obj-type
        ub.chk-doc.obj-code = p-obj-code
        ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                            then string(next-value(s-chk, ub))
                            else string( shop-code ) + chr(47) + string( next-value( s-chk, ub ) ))
        ub.chk-doc.office = ?
        for-chk-type = ""
        prev-code = ub.chk-doc.doc-code
        ub.chk-doc.sales-man = sales-man_
        ub.chk-doc.chk-date = chk-date_
        ub.chk-doc.chk-time = chk-time_
        ub.chk-doc.shift-date = ub.chk-doc.chk-date
        ub.chk-doc.src-shift-date = ub.chk-doc.shift-date
        ub.chk-doc.cash-rate = 1
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.z-number = z-num_
        ub.chk-doc.correct = yes
        ub.chk-doc.d-pcnt = 0
        ub.chk-doc.src-d-pcnt = 0
        ub.chk-doc.shift-num = (if cas-shft then shift-num_ else 0)
        ub.chk-doc.cashier = cashier_
        ub.chk-doc.chk-type = chk-type_
        ub.chk-doc.correct = yes
        ub.CHK-DOC.discnt = 0
        ub.chk-doc.src-d-card =  d-card_
        ub.chk-doc.src-d-pcnt = - tot-d-pcnt
        ub.chk-doc.src-shift-date = (if cas-shft then shift-date_ else chk-date_)
        ub.chk-doc.cash-rate = 1
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.z-number = z-num_
        ub.chk-doc.doc-num = doc-num_ + (if shift-name_ <> '':U
                                        then (chr(4) + shift-name_)
                                        else '':U)
        v-is-petrol-check = lookup(string(ub.chk-doc.chk-type) , '14,15,16,17,36':U) > 0
        ub.chk-doc.correct = yes
        .
      end.
      else do:
        assign
        exist = yes
        .
        return.
      end.
      IF not AVAILABLE ub.CHK-GDS
        or NOT (ub.chk-gds.doc-code = ub.chk-doc.doc-code
                AND ub.chk-gds.src-code = bc-buf)
        or NOT (ub.chk-gds.doc-code = ub.chk-doc.doc-code
            AND ub.chk-gds.src-code = bc-buf
            AND pre-pay-type = cur-pay-type
            AND ub.chk-gds.pump = pump_ + 1000 * nozzle_
            )
            then do:
        CREATE ub.chk-gds.
        assign
        lng = lng + 1
        ub.chk-gds.doc-code = ub.chk-doc.doc-code
        ub.chk-gds.line-num = lng
        ub.chk-gds.chk-date = ub.chk-doc.chk-date
        pre-pay-type = cur-pay-type
        ub.chk-gds.b-code =  0
        ub.chk-gds.grp-code = 0
        ub.chk-gds.src-code = bc-buf
        ub.chk-gds.is-error = no
        ub.chk-gds.discnt = 0
        ub.chk-gds.time-oper = ub.chk-doc.chk-time
        ub.chk-gds.src-qnty = 0
        ub.chk-gds.doc-qnty = 0
        ub.chk-gds.src-price = price-from-check
        ub.chk-gds.src-sum = 0
        ub.chk-gds.src-qnty = curr-string-qnty
        ub.chk-gds.src-discnt = discnt-from-check-prim
        ub.chk-gds.pass-gds = 0
        ub.chk-gds.line-sign = (if ub.chk-doc.chk-type = integer('1':U)
                            then (ub.chk-gds.src-qnty >= 0)
                            else (ub.chk-gds.src-qnty <= 0)
                            )
        ub.chk-gds.line-type =  "":U
        ub.chk-gds.pump = pump_ + 1000 * nozzle_
        .
      end.
      else do:
        assign
        ub.chk-gds.src-discnt = (ub.chk-gds.src-discnt * abs(ub.chk-gds.src-qnty) + discnt-from-check-prim * abs(curr-string-qnty)) / abs( chk-gds.src-qnty + curr-string-qnty)
        ub.chk-gds.src-qnty = ub.chk-gds.src-qnty + curr-string-qnty
        .
      end.
      assign
      ub.chk-gds.src-sum = ub.chk-gds.src-sum + sum-from-check
      .
      if ub.chk-gds.src-discnt <> 0 then do:
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
        ub.chk-discnt.src-d-card = ub.chk-doc.src-d-card
        ub.chk-discnt.discnt-value-abs = ub.chk-gds.src-discnt
        ub.chk-discnt.object-qnty = ub.chk-gds.src-qnty
        ub.chk-discnt.object-sum = ub.chk-gds.src-sum
        ub.chk-discnt.discnt-value-pcnt = if ub.chk-gds.src-sum <> 0 then
                                        ub.chk-gds.src-discnt / ub.chk-gds.src-sum * 100
                                        else 0
        ub.chk-discnt.object-line-num = chk-gds.line-num
        ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
        ub.chk-discnt.obj-code = ub.chk-doc.obj-code
        ub.chk-discnt.obj-type = ub.chk-doc.obj-type
        ub.chk-discnt.chk-date = ub.chk-doc.chk-date
        ub.chk-discnt.chk-time = ub.chk-doc.chk-time
        var-discnt-id = var-discnt-id + 1
        .
      end.
      if not (chk-type_ = integer('17':U)
             or chk-type_ = integer('15':U)) then do:
        FIND ub.chk-pay where
              ub.chk-pay.doc-code = ub.chk-doc.doc-code AND
              ub.chk-pay.curr-code = curr_code AND
              ub.chk-pay.pay-code = pay_code      NO-ERROR.
        if NOT available ub.chk-pay
        or ub.chk-pay.pay-card <> pay-card_
        then do:
          CREATE ub.chk-pay.
          assign
          lnp = lnp + 1
          ub.chk-pay.doc-code = ub.chk-doc.doc-code
          ub.chk-pay.line-num = lnp
          ub.chk-pay.chk-date = ub.chk-doc.chk-date
          ub.chk-pay.obj-code = p-obj-code
          ub.chk-pay.obj-type = p-obj-type
          ub.chk-pay.pay-code = pay_code
          ub.chk-pay.curr-code = curr_code
          ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + sum-from-check - discnt-from-check
          ub.chk-pay.time-oper = ub.chk-doc.chk-time
          ub.chk-pay.line-type = "":U
          ub.chk-pay.line-sign =  (if ub.chk-doc.chk-type = integer('1':U)
                                then (ub.chk-pay.tot-sum >= 0)
                                else (ub.chk-pay.tot-sum <= 0)
                                )
          ub.chk-pay.pay-card = pay-card_
          ub.chk-pay.cash-rate = 1
          ub.chk-pay.bank-rate = 1
          ub.chk-pay.bank-scale = 1
          ub.chk-pay.pass-pay  = 0
          ub.chk-pay.is-error = no
          .
        end.
        else do:
          assign
          ub.chk-pay.tot-sum = ub.chk-pay.tot-sum + sum-from-check - discnt-from-check
          .
        end.
      end.
    end.
end.
end procedure.
PROCEDURE get-mar-parameters:
define input parameter p-read-object as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
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
  undo, return "error":U.
end.
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
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl'
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  NO
  ,output conf-par
  ,output par-type
  ) NO-ERROR .
assign
is-ptrl = logical(conf-par) no-error .
if is-wth = yes then do:
end.
if LOOKUP(left-trim(p-read-object, '0'), '26,27,28,29,30,31,32,33') > 0 then do:
  accept-types =  "001,002,003":U.
  if is-ptrl
  and ptrl-check then
  assign
  accept-types = accept-types + ",004,005":U.
  assign
  v-petrol-mode = yes.
end.
if LOOKUP(left-trim(p-read-object, '0'), '42,43') > 0 then do:
  accept-types =  "001,002,003":U.
end.
run adm/shattri.p (
      input "get":U
      ,input  'маг':U
      ,input  p-obj-code
      ,input  'cd-type-maria':U
      ,input  'mariapayg':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
IF not error-status:error then do:
  mariapayg = v-value-character.
  delete object v-tth.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
run adm/shattri.p (
      input "get":U
      ,input  'маг':U
      ,input  p-obj-code
      ,input  'cd-type-maria':U
      ,input  'mariapayp':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
IF not error-status:error then do:
  mariapayp = v-value-character.
  delete object v-tth.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
END PROCEDURE.
procedure process-maria-attr :
define input parameter p-num-recs as decimal no-undo .
define variable v-last-date as date no-undo .
define variable v-last-z-count as integer no-undo .
define variable v-last-num-recs as integer no-undo .
define variable v-p-last-date as date no-undo .
define variable v-p-last-z-count as integer no-undo .
define variable v-p-last-num-recs as integer no-undo .
define variable v-old as character no-undo .
define variable v-new as character no-undo .
define variable v-new-rel-z-count as integer no-undo .
define variable v-old-rel-z-count as integer no-undo .
  do
  on error undo, return error
  :
  find first temp-cash-desk where
           temp-cash-desk.cash-num = pay-desk_ no-error.
  if not available temp-cash-desk then do:
    run get-last-check-maria in this-procedure (
                                                            input g#db-num
                                                            ,input p-obj-code
                                                            ,input pay-desk_
                                                            ,output v-last-date
                                                            ,output v-last-z-count
                                                            ,output v-last-num-recs
                                                            ,output v-p-last-date
                                                            ,output v-p-last-z-count
                                                            ,output v-p-last-num-recs
                                                            ) no-error.
    create temp-cash-desk.
    assign
    temp-cash-desk.cash-num = pay-desk_
    temp-cash-desk.last-date = v-last-date
    temp-cash-desk.last-z-count = v-last-z-count
    temp-cash-desk.last-num-recs = v-last-num-recs
    temp-cash-desk.last-p-date = v-p-last-date
    temp-cash-desk.last-p-z-count = v-p-last-z-count
    temp-cash-desk.last-p-num-recs = v-p-last-num-recs
    .
  end.
  assign
  v-old = string(year(temp-cash-desk.last-date), "9999") +
          string(month(temp-cash-desk.last-date), "99") +
          string(day(temp-cash-desk.last-date), "99") +
          string(temp-cash-desk.last-z-count, "99999") +
          string(temp-cash-desk.last-num-recs, "9999.9999") +
          string(year(temp-cash-desk.last-p-date), "9999") +
          string(month(temp-cash-desk.last-p-date), "99") +
          string(day(temp-cash-desk.last-p-date), "99") +
          string(temp-cash-desk.last-p-z-count, "99999") +
          string(temp-cash-desk.last-p-num-recs, "9999")
  .
  if v-petrol-mode then do:
    assign
    v-new = string(year(temp-cash-desk.last-date), "9999") +
            string(month(temp-cash-desk.last-date), "99") +
            string(day(temp-cash-desk.last-date), "99") +
            string(temp-cash-desk.last-z-count, "99999") +
            string(temp-cash-desk.last-num-recs, "9999.9999") +
            (if chk-date_ <> 01/01/1990 then
            (string(year(chk-date_), "9999") +
            string(month(chk-date_), "99") +
            string(day(chk-date_), "99"))
            else
            (string(year(temp-cash-desk.last-p-date), "9999") +
            string(month(temp-cash-desk.last-p-date), "99") +
            string(day(temp-cash-desk.last-p-date), "99")))  +
            string((if v-hundred and z-num_ = 11 then 100 else  z-num_), "99999") +
            string(p-num-recs, "9999")
    .
  end.
  else do:
    assign
    v-new = (if chk-date_ <> 01/01/1990 then
            (string(year(chk-date_), "9999") +
            string(month(chk-date_), "99") +
            string(day(chk-date_), "99"))
            else
            (string(year(temp-cash-desk.last-date), "9999") +
            string(month(temp-cash-desk.last-date), "99") +
            string(day(temp-cash-desk.last-date), "99")))  +
            string((if v-hundred and z-num_ = 11 then 100 else  z-num_), "99999") +
            string(p-num-recs, "9999.9999") +
            string(year(temp-cash-desk.last-p-date), "9999") +
            string(month(temp-cash-desk.last-p-date), "99") +
            string(day(temp-cash-desk.last-p-date), "99") +
            string(temp-cash-desk.last-p-z-count, "99999") +
            string(temp-cash-desk.last-p-num-recs, "9999")
            .
  end.
  if v-new > v-old then do:
    if v-petrol-mode then do:
      assign
      temp-cash-desk.last-p-date      = (if chk-date_ <> 01/01/1990 then chk-date_ else temp-cash-desk.last-p-date)
      temp-cash-desk.last-p-z-count   = (if v-hundred and z-num_ = 11 then 100 else  z-num_)
      temp-cash-desk.last-p-num-recs  = p-num-recs
      .
    end.
    else do:
      assign
      temp-cash-desk.last-date     = (if chk-date_ <> 01/01/1990 then chk-date_ else temp-cash-desk.last-date)
      temp-cash-desk.last-z-count  = (if v-hundred and z-num_ = 11 then 100 else  z-num_)
      temp-cash-desk.last-num-recs = p-num-recs
      .
    end.
  end.
  end.
end procedure.
procedure proc-shift :
define parameter buffer buf_tt-ss for tt-ss.
define input parameter p-ii as integer no-undo .
define variable shift-info as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
    pay-desk_ = p-cash-num
    z-num_ = integer(entry(2, buf_tt-ss.n-entry[1], '=':U))
    no-error .
    if error-status:error then do:
      var-file-line-num = tt-ss.rec-no.
      if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
    end.
    assign
    chk-date_ = 01/01/1990
    .
    if p-ii > 2 then do:
      assign
      shift-num_ = z-num_ modulo 100
      v-hundred = (if shift-num_ = 0
                   or shift-num_ = 100 then yes else no)
      shift-num_ = (if shift-num_ = 0
                   or shift-num_ = 100 then 11 else shift-num_)
      shift-date_ = date(
                        int( substr( buf_tt-ss.n-entry[2], 6, 2 ) ),
                        int( substr( buf_tt-ss.n-entry[2], 8, 2 ) ),
                        int( substr( buf_tt-ss.n-entry[2], 2, 4  ) )
                        )
      shift-open-time_ = int( substr( buf_tt-ss.n-entry[3], 1, 7 ) ) * 3600 + int( substr( buf_tt-ss.n-entry[4], 8, 2 ) ) * 60
      chk-date_ = date(
                        int( substr( buf_tt-ss.n-entry[4], 6, 2 ) ),
                        int( substr( buf_tt-ss.n-entry[4], 8, 2 ) ),
                        int( substr( buf_tt-ss.n-entry[4], 2, 4 ) )
                        )
      chk-time_ =  int( substr( buf_tt-ss.n-entry[5], 1, 7 ) ) * 3600 + int( substr( buf_tt-ss.n-entry[5], 8, 2 ) ) * 60
      no-error
      .
      if error-status:error then do:
        var-file-line-num = buf_tt-ss.rec-no.
        if file_ begins "<?xml" then                                                   v-error-message = "!!!Неверный формат спула файла: " +  substring(error-status:get-message(1),1,300).   else                                                                           v-error-message = "!!!Неверный формат спула файла " + substring(file_, 1, 150) +       ": строка " + string(var-file-line-num) + ": " + substring(error-status:get-message(1),1,300).   if v-error-message = ? then v-error-message = "!!!Неверный формат спула файла ".   run write-log-and-file in p-log-handle (                                           input 1                                                                    , input log-file-name                                                        , input 1                                                                    , input v-error-message                                                                                      ).                                            assign                                                                       p-view-log = yes                                                            exist = yes                                                                  mc-exist = yes                                                               .                                                                            return.
      end.
    end.
    if get-chkc_context.cas-shft then do:
      if current-pay-desk <> pay-desk_
      or NOT (current-cas-shift-name =  shift-name_
          AND current-cas-shift-date = shift-date_)
      OR not avail buf_shift-cash then do:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    assign
    pay-desk_ = p-cash-num
    z-num_ = z-num_ + 1
    z-num_ = (if z-num_ = 101 then  1 else z-num_)
    .
    run process-maria-attr in this-procedure ( input 0.0).
  end.
end procedure.
procedure tekka-date-time  :
define input parameter p-tekka-date-time as character no-undo .
define input parameter p-cash-num as character no-undo .
  do
  on error undo, return error return-value
  :
define variable v-date as date.
define variable v-time as integer no-undo .
define variable v-type as character no-undo .
define variable v-date-time-info as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-cd-date-time-info as character no-undo .
assign
v-date =  date(
          int( substr( p-tekka-date-time, 6, 2 ) ),
          int( substr( p-tekka-date-time, 8, 2 ) ),
          int( substr( p-tekka-date-time, 2, 4 ) )
            )
v-time =  int( substr( p-tekka-date-time, 16, 2 ) ) * 3600 +
          int( substr( p-tekka-date-time, 18, 2 ) ) * 60
no-error .
if error-status:error then return error.
assign
v-cd-date-time-info = string(YEAR(v-date), "9999":U) + "-":U +
             string(Month(v-date), "99":U) + "-":U +
             string(DAY(v-date), "99":U) +
             chr(32)  +  string(v-time, "HH:MM:SS":U).
  run cd-attr-value in this-procedure (
                                                          input g#db-num
                                                          ,input p-obj-code
                                                          ,input 'MARIA':U
                                                          ,input integer(p-cash-num)
                                                          ,input 'MARIA_operative':U
                                                          ,input 'data-actuality':U
                                                          ,output v-date-time-info
                                                          ,output v-value-date
                                                          ,output v-value-decimal
                                                          ,output v-value-integer
                                                          ,output v-value-logical
                                                          ,output v-type
                                                          ) no-error.
  if v-date-time-info < v-cd-date-time-info then do:
    run cd-attr-write in this-procedure (
                                          input g#db-num
                                          ,input p-obj-code
                                          ,input 'MARIA':U
                                          ,input integer(p-cash-num)
                                          ,input 'MARIA_operative':U
                                          ,input 'data-actuality':U
                                          ,input v-cd-date-time-info
                                          ,input ?
                                          ,input 0.0
                                          ,input 0
                                          ,input no
                                          ).
  end.
end.
end procedure.
