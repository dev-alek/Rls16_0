block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-pos-type  like ub.cash-desk.pos-type no-undo .
DEFINE INPUT PARAMETER file_ as character no-undo.
define input parameter p-table as character no-undo .
define input parameter p-file-num  as integer no-undo .
define input-output parameter p-view-log as logical no-undo .
DEFINE VARIABLE vss-revision    as character no-undo init "$Revision: 9263cff4388a, 1753, rls $":u .
DEFINE VARIABLE vss-author      as character no-undo init "$Author: SMMolotkov $":u .
DEFINE VARIABLE vss-date        as character no-undo init "$Date: Thu Feb 07 16:50:10 2019 +0300 $":u .
DEFINE VARIABLE vss-workfile    as character no-undo init "$Workfile: get-rkep.p $":u .
DEFINE VARIABLE vss-archive     as character no-undo init "$Archive: str/get-rkep.p $":u .
DEFINE VARIABLE vss-description as character no-undo init "Программа приема чеков с касс R-keeper" .
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
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-categ no-undo
field  SIFR  as integer         column-label "Идентификатор"
field  NAME  as character       column-label "Название"
field  is-DEL  as logical       column-label "удаленная / действующая"
index pi is unique primary
sifr.
define SHARED temp-table temp-menu no-undo
field   SIFR          as integer       column-label "Идентификатор"
field   NAME          as character     column-label "Название"
field   CODE-chr      as character     column-label "Код"
field   TREETYPE      as character     column-label "Тип записи"
field   CATEG         as integer       column-label "Идентификатор категории"
field   PRICE         as decimal       column-label "Цена блюда"
field   PARENT        as integer       column-label "Идентификатор группы"
field   DEL           as logical       column-label "удаленное / действующee"
field   bar-code-chr  as character     column-label "штрих-код"
field   lvl-num       as integer
index pi is unique primary
SIFR
index itype
treetype
.
define SHARED temp-table temp-modify no-undo
field   SIFR       as integer      column-label "Идентификатор"
field   NAME       as character    column-label "Название"
field   REALPRICE  as decimal      column-label "Не используется"
field   DEL        as logical      column-label "удаленный / действующий"
field   parent     as integer      column-label "код группы"
index pi is unique primary
SIFR.
define SHARED temp-table temp-money no-undo
field   SIFR       as integer    column-label "Идентификатор"
field   NAME       as character  column-label "Название"
field   CODE-str   as character  column-label "код"
field   KURS       as decimal    column-label "курс"
field   PARENT     as integer    column-label "Идентификатор группы"
field   DEL        as logical    column-label "удаленная / действующая"
field   TIP        as integer    column-label "Тип платежа/валюты"
field   TREE       as logical    column-label "Тип записи"
index pi is unique primary
sifr.
define SHARED temp-table temp-Personal no-undo
field   SIFR     as integer   column-label "Идентификатор"
field   NAME     as character column-label "имя"
field   CODE-str as character column-label  "код"
field   TYPE     as character column-label "тип"
field   DEL      as logical   column-label " удаленный / действующий"
index pi is unique primary
sifr.
define SHARED temp-table temp-Reasons no-undo
field  SIFR     as integer    column-label "Идентификатор"
field  NAME     as character  column-label "название"
field  USED     as logical    column-label "применять списание"
field  DEL      as logical    column-label "удаленная / действующая"
index pi is unique primary
sifr.
define SHARED temp-table temp-Charges   no-undo
field  SIFR     as integer    column-label "Идентификатор"
field  NAME     as character  column-label "Название"
field  DEL      as logical    column-label "удаленная / действующая"
index pi is unique primary
sifr.
define SHARED temp-table temp-Avcheck no-undo
field  LOGICDATE as date  column-label "Кассовая дата"
field  REALDATE  as date  column-label "Физическая дата"
field  f_TIME      as character   column-label "Физическое время"
field  SIFR      as integer     column-label "Идентификатор"
field  COMP      as integer     column-label "Тип строчки"
field  QNT       as decimal     column-label "количество"
field  PRICE     as decimal      column-label "цена"
field  REASON    as integer    column-label "причина удаления"
field  MANAGER   as integer    column-label "Идентификатор менеджера"
field  WAITER    as integer    column-label "Идентификатор официанта"
field  TABLE_     as character  column-label "стол"
field  UNIT      as character  column-label "станция"
field  DEPART    as character  column-label "группа станций"
field  sys_num   as integer    column-label "ссылка на номер чека которую мы сами прописали"
field  del-time   as decimal
field  line-num   as integer
index pi is primary
sifr
index ifind
depart
unit
logicdate
del-time
index isys_num
sys_num
index iline-num
sys_num
line-num
.
define SHARED temp-table temp-Acheck no-undo
field  SYS_NUM     as integer column-label  "Идентификатор чека"
field  CNUM        as integer column-label "Номер чека"
field  LOGICDATE   as date column-label "кассовая дата закрытия чека"
field  REALDATE    as date column-label "физическая дата закрытия чека"
field  OPENTIME    as character column-label "время открытия заказа"
field  CLOSETIME   as character column-label "время закрытия заказа"
field  COVER       as integer column-label "кол-во гостей"
field  CASHIER     as integer column-label "Идентификатор кассира"
field  WAITER      as integer column-label "Идентификатор официанта"
field  UNIT        as character column-label "станция"
field  DEPART      as character column-label "группа станций"
field  TOTAL       as decimal column-label "сумма чека без всех скидок/наценок в базовой валюте"
field  BASEKURS    as decimal column-label "курс базовой валюты"
field  DELETED     as integer
field  MANAGER     as integer column-label "Идентификатор менеджера"
field  CHARGE      as decimal column-label "Не используется"
field  TABLE_      as integer column-label "стол"
field  OPENDATE    as date    column-label "Кассовая дата открытия заказа"
field  NACKURS     as decimal column-label "курс национальной валюты"
field  TAXSUM      as decimal column-label "сумма налога с продаж в базовой валюте"
field  TAXRATE     as decimal column-label "отношение налог с продаж/(сумма чека+налог)"
field  DOP1        as decimal column-label "Не используется"
field  DOP2        as integer column-label "Не используется"
field  DOP3        as decimal column-label "Не используется"
field  DOP4        as decimal column-label "Не используется"
field  start-time   as decimal
field  end-time     as decimal
index pi is unique primary
sys_num
index ifind
depart
unit
logicdate
start-time
end-time
.
define SHARED temp-table temp-Adcheck no-undo
field  SYS_NUM      as integer column-label "Идентификатор чека"
field  CNUM         as integer column-label "Номер чека"
field  SIFR         as integer column-label "Идентификатор скидки (наценки)"
field  SUM          as decimal column-label "сумма скидки (отрицательная) или наценки (положительная)"
field  CARDCOD      as integer column-label "Не используется"
field  PERSON       as integer column-label "0-автоматическая; иначе - Идентификатор применившего скидку"
 field  dop1  as decimal column-label "?????????????????"
field  line-num   as integer
index pi is primary
sys_num
index iline-num
sys_num
line-num
.
define SHARED temp-table temp-Apcheck no-undo
field  SYS_NUM       as integer    column-label "Идентификатор чека"
field  CNUM          as integer    column-label "Номер чека"
field  CURRENCY      as integer    column-label "Идентификатор валюты"
field  BASESUMEQW    as decimal    column-label "сумма в базовой валюте, включающая скидку на валюту"
field  ORIGSUM       as decimal    column-label "сумма в валюте CURRENCY, не включающая скидку на валюту"
field  KURS          as decimal    column-label "курс валюты CURRENCY"
field  DISCOUNT      as decimal    column-label "скидка"
field  EXTRA         as character  column-label "Не используется"
field  DOP1          as decimal    column-label "Не используется"
field  DOP2          as decimal    column-label "Не используется"
field  DOP3          as logical
field  line-num   as integer
index pi is primary
sys_num currency
index iline-num
sys_num
line-num
.
define SHARED temp-table temp-Archeck  no-undo
field  SYS_NUM      as integer     column-label "Идентификатор чека"
field  CNUM         as integer     column-label "Номер чека"
field  SIFR         as integer     column-label "Идентификатор блюда или модификатора"
field  QNT          as decimal     column-label "количество порций"
field  PRICE        as decimal     column-label "цена по меню"
field  COMPONENT    as logical     column-label "'T'-модификатор; 'F'-блюдо"
field  PAYSUM       as decimal     column-label  "Сумма"
field  DOP1         as decimal     column-label "Не используется"
field  NALOG        as decimal     column-label "налог с продаж в долях"
field  CONSUMANT    as logical     column-label "Консумант"
field  PAYPRICE     as decimal     column-label "цена нетто "
field  line-num   as integer
index pi is primary
sys_num sifr
index iline-num
sys_num
line-num
.
define SHARED temp-table temp-control  no-undo
field  FILE_        as character column-label "название файла"
field  RECORDS      as integer   column-label "количество записей"
field  RESTSIFR     as integer   column-label "Идентификатор ресторана"
field  RESTNAME     as character column-label "Название ресторана"
field  STARTDATE    as date      column-label "Начальная кассовая дата экспортируемой информации"
field  STOPDATE     as date      column-label "Конечная кассовая дата экспортируемой информации"
index pi is unique primary
file_.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table temp-i-categ no-undo
field  SIFR  as integer         column-label "Идентификатор"
field  NAME  as character       column-label "Название"
field  is-DEL  as logical       column-label "удаленная / действующая"
index pi is unique primary
sifr.
define   temp-table temp-i-menu no-undo
field   SIFR          as integer       column-label "Идентификатор"
field   NAME          as character     column-label "Название"
field   CODE-chr      as character     column-label "Код"
field   TREETYPE      as character     column-label "Тип записи"
field   CATEG         as integer       column-label "Идентификатор категории"
field   PRICE         as decimal       column-label "Цена блюда"
field   PARENT        as integer       column-label "Идентификатор группы"
field   DEL           as logical       column-label "удаленное / действующee"
field   bar-code-chr  as character     column-label "штрих-код"
index pi is unique primary
SIFR
index itype
treetype
.
define   temp-table temp-i-modify no-undo
field   SIFR       as integer      column-label "Идентификатор"
field   NAME       as character    column-label "Название"
field   REALPRICE  as decimal      column-label "Не используется"
field   DEL        as logical      column-label "удаленный / действующий"
field   parent     as integer      column-label "код группы"
index pi is unique primary
SIFR.
define   temp-table temp-i-money no-undo
field   SIFR       as integer    column-label "Идентификатор"
field   NAME       as character  column-label "Название"
field   CODE-str   as character  column-label "код"
field   KURS       as decimal    column-label "курс"
field   PARENT     as integer    column-label "Идентификатор группы"
field   DEL        as logical    column-label "удаленная / действующая"
field   TIP        as integer    column-label "Тип платежа/валюты"
field   TREE       as logical    column-label "Тип записи"
index pi is unique primary
sifr.
define   temp-table temp-i-Personal no-undo
field   SIFR     as integer   column-label "Идентификатор"
field   NAME     as character column-label "имя"
field   CODE-str as character column-label  "код"
field   TYPE     as character column-label "тип"
field   DEL      as logical   column-label " удаленный / действующий"
index pi is unique primary
sifr.
define   temp-table temp-i-Reasons no-undo
field  SIFR     as integer    column-label "Идентификатор"
field  NAME     as character  column-label "название"
field  USED     as logical    column-label "применять списание"
field  DEL      as logical    column-label "удаленная / действующая"
index pi is unique primary
sifr.
define   temp-table temp-i-Charges   no-undo
field  SIFR     as integer    column-label "Идентификатор"
field  NAME     as character  column-label "Название"
field  DEL      as logical    column-label "удаленная / действующая"
index pi is unique primary
sifr.
define   temp-table temp-i-Avcheck no-undo
field  LOGICDATE as date  column-label "Кассовая дата"
field  REALDATE  as date  column-label "Физическая дата"
field  f_TIME      as character   column-label "Физическое время"
field  SIFR      as integer     column-label "Идентификатор"
field  COMP      as integer     column-label "Тип строчки"
field  QNT       as decimal     column-label "количество"
field  PRICE     as decimal      column-label "цена"
field  REASON    as integer    column-label "причина удаления"
field  MANAGER   as integer    column-label "Идентификатор менеджера"
field  WAITER    as integer    column-label "Идентификатор официанта"
field  TABLE_     as character  column-label "стол"
field  UNIT      as character  column-label "станция"
field  DEPART    as character  column-label "группа станций"
index pi is primary
sifr
.
define   temp-table temp-i-Acheck no-undo
field  SYS_NUM     as integer column-label  "Идентификатор чека"
field  CNUM        as integer column-label "Номер чека"
field  LOGICDATE   as date column-label "кассовая дата закрытия чека"
field  REALDATE    as date column-label "физическая дата закрытия чека"
field  OPENTIME    as character column-label "время открытия заказа"
field  CLOSETIME   as character column-label "время закрытия заказа"
field  COVER       as integer column-label "кол-во гостей"
field  CASHIER     as integer column-label "Идентификатор кассира"
field  WAITER      as integer column-label "Идентификатор официанта"
field  UNIT        as character column-label "станция"
field  DEPART      as character column-label "группа станций"
field  TOTAL       as decimal column-label "сумма чека без всех скидок/наценок в базовой валюте"
field  BASEKURS    as decimal column-label "курс базовой валюты"
field  DELETED     as integer
field  MANAGER     as integer column-label "Идентификатор менеджера"
field  CHARGE      as decimal column-label "Не используется"
field  TABLE_      as integer column-label "стол"
field  OPENDATE    as date    column-label "Кассовая дата открытия заказа"
field  NACKURS     as decimal column-label "курс национальной валюты"
field  TAXSUM      as decimal column-label "сумма налога с продаж в базовой валюте"
field  TAXRATE     as decimal column-label "отношение налог с продаж/(сумма чека+налог)"
field  DOP1        as decimal column-label "Не используется"
field  DOP2        as integer column-label "Не используется"
field  DOP3        as decimal column-label "Не используется"
field  DOP4        as decimal column-label "Не используется"
index pi is unique primary
sys_num
.
define   temp-table temp-i-Adcheck no-undo
field  SYS_NUM      as integer column-label "Идентификатор чека"
field  CNUM         as integer column-label "Номер чека"
field  SIFR         as integer column-label "Идентификатор скидки (наценки)"
field  SUM          as decimal column-label "сумма скидки (отрицательная) или наценки (положительная)"
field  CARDCOD      as integer column-label "Не используется"
field  PERSON       as integer column-label "0-автоматическая; иначе - Идентификатор применившего скидку"
 field  dop1  as decimal column-label "?????????????????"
index pi is primary
sys_num
.
define   temp-table temp-i-Apcheck no-undo
field  SYS_NUM       as integer    column-label "Идентификатор чека"
field  CNUM          as integer    column-label "Номер чека"
field  CURRENCY      as integer    column-label "Идентификатор валюты"
field  BASESUMEQW    as decimal    column-label "сумма в базовой валюте, включающая скидку на валюту"
field  ORIGSUM       as decimal    column-label "сумма в валюте CURRENCY, не включающая скидку на валюту"
field  KURS          as decimal    column-label "курс валюты CURRENCY"
field  DISCOUNT      as decimal    column-label "скидка"
field  EXTRA         as character  column-label "Не используется"
field  DOP1          as decimal    column-label "Не используется"
field  DOP2          as decimal    column-label "Не используется"
field  DOP3          as logical
index pi is primary
sys_num currency
.
define   temp-table temp-i-Archeck  no-undo
field  SYS_NUM      as integer     column-label "Идентификатор чека"
field  CNUM         as integer     column-label "Номер чека"
field  SIFR         as integer     column-label "Идентификатор блюда или модификатора"
field  QNT          as decimal     column-label "количество порций"
field  PRICE        as decimal     column-label "цена по меню"
field  COMPONENT    as logical     column-label "'T'-модификатор; 'F'-блюдо"
field  PAYSUM       as decimal     column-label  "Сумма"
field  DOP1         as decimal     column-label "Не используется"
field  NALOG        as decimal     column-label "налог с продаж в долях"
field  CONSUMANT    as logical     column-label "Консумант"
field  PAYPRICE     as decimal     column-label "цена нетто "
index pi is primary
sys_num sifr
.
define   temp-table temp-i-control  no-undo
field  FILE_        as character column-label "название файла"
field  RECORDS      as integer   column-label "количество записей"
field  RESTSIFR     as integer   column-label "Идентификатор ресторана"
field  RESTNAME     as character column-label "Название ресторана"
field  STARTDATE    as date      column-label "Начальная кассовая дата экспортируемой информации"
field  STOPDATE     as date      column-label "Конечная кассовая дата экспортируемой информации"
index pi is unique primary
file_.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref14 as character no-undo .
define variable varpgscales-pref14 as character no-undo .
define variable varscales-pref-type14 as character no-undo.
define variable varpgscales-pref-type14 as character no-undo.
varscales-pref14  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref14
  ,output varscales-pref-type14
  ) no-error .
  if varscales-pref14 = ? then do:
    assign
      varscales-pref14 = '21,23,25':U.
  end.
varpgscales-pref14  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref14
  ,output varpgscales-pref-type14
  ) no-error .
  if varpgscales-pref14 = ? then do:
    assign
      varpgscales-pref14 = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
  end.
function get-rkgTH-price returns decimal(input p-obj-type as character
                                       , input p-obj-code as integer
                                       , input p-b-code as integer
                                       , output p-doc-num as character):
define variable v-price-sale as decimal   no-undo init ?.
define variable v-road-tax   as decimal   no-undo .
define variable v-excise     as decimal   no-undo .
define variable v-vat-pc     as decimal   no-undo .
define variable v-slt-pc     as decimal   no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-b-code
  ,input  0
  ,input  0
  ,output p-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ,output v-vat-pc
  ,output v-slt-pc
  ) no-error .
if not error-status:error then return v-price-sale.
END FUNCTION.
function get-rkgTH-name returns character(input p-obj-type as character
                                          ,input p-obj-code as integer
                                          ,input p-b-code as integer
                                          , buffer buf_goods for ub.goods):
define variable v-gds-name as character no-undo .
define VARIABLE varresult   as character                no-undo.
define VARIABLE vartype-bc  as character                no-undo.
define VARIABLE varweight   as decimal                  no-undo.
DEFINE VARIABLE v-unit-cli AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-f-name AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_bar-code FOR ub.bar-code.
DEFINE BUFFER buf_prod-bc FOR ub.prod-bc.
DEFINE BUFFER buf_place FOR ub.place.
DEFINE BUFFER buf_gds-prt FOR ub.gds-prt.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  STRING(p-b-code)
,input  0
,input  p-obj-type
,input  p-obj-code
,input  NO
,input  YES
,input  varscales-pref14
,input  varpgscales-pref14
,output varresult
,output vartype-bc
,output varweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
if not available buf_bar-code then
return "!!!НЕИЗВЕСТНЫЙ ТОВАР".
FIND FIRST buf_goods NO-LOCK WHERE
          buf_goods.gds-code = buf_bar-code.gds-code NO-ERROR.
IF NOT AVAILABLE buf_goods THEN DO:
  return "!!!НЕИЗВЕСТНЫЙ ТОВАР".
END.
else do:
  assign
  v-gds-name = buf_goods.chk-name
  .
end.
IF buf_bar-code.unit-cli <> buf_goods.unit-base THEN DO:
  ASSIGN
  v-unit-cli = "*" + string(buf_bar-code.cli-base-rate).
END.
FIND FIRST buf_gds-prt NO-LOCK WHERE
          buf_gds-prt.upper-code = buf_goods.prt-root NO-ERROR.
if buf_gds-prt.node-name <>  '_Пустая шкала':U THEN DO:
    FIND FIRST buf_gds-prt NO-LOCK WHERE
              buf_gds-prt.node-code = buf_bar-code.node-code NO-ERROR.
END.
ASSIGN
v-f-name = (IF AVAILABLE buf_gds-prt THEN buf_gds-prt.f-name ELSE "":U).
ASSIGN
v-gds-name = v-gds-name + chr(32) + v-f-name + v-unit-cli.
return v-gds-name.
END FUNCTION.
function get-rkgTH-group returns integer(input p-obj-type as character
                                        , input p-obj-code  as integer
                                        , input p-gds-code as integer
                                        , output p-grp-name as character
                                        ):
DEFINE BUFFER buf_fbr-gds-obj FOR ub.fbr-gds-obj.
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.
FIND FIRST buf_fbr-gds-obj NO-LOCK WHERE
        buf_fbr-gds-obj.obj-type = p-obj-type
    AND buf_fbr-gds-obj.obj-code = p-obj-code
    AND buf_fbr-gds-obj.gds-code = p-gds-code NO-ERROR.
IF AVAILABLE buf_fbr-gds-obj THEN DO:
  RUN fbrglib-get-full-name IN THIS-PROCEDURE(
                                              input p-obj-type
                                              ,INPUT p-obj-code
                                              ,INPUT buf_fbr-gds-obj.fbr-grp-code
                                              ,OUTPUT p-grp-name) NO-ERROR.
  return buf_fbr-gds-obj.fbr-grp-code.
END.
return ?.
END FUNCTION.
function get-rkgTH-modificator returns logical(input p-obj-type as character
                                        , input p-obj-code  as integer
                                        , input p-gds-code as integer
                                        , output p-is-null-price as logical
                                        ):
DEFINE BUFFER buf_fbr-gds-obj FOR ub.fbr-gds-obj.
FIND FIRST buf_fbr-gds-obj NO-LOCK WHERE
        buf_fbr-gds-obj.obj-type = p-obj-type
    AND buf_fbr-gds-obj.obj-code = p-obj-code
    AND buf_fbr-gds-obj.gds-code = p-gds-code NO-ERROR.
IF AVAILABLE buf_fbr-gds-obj THEN DO:
  assign
  p-is-null-price = buf_fbr-gds-obj.is-null-price
  .
  return buf_fbr-gds-obj.is-modificator.
END.
assign
p-is-null-price = no.
return no.
END FUNCTION.
function get-rkgTH-group-name returns character(input p-obj-type as character
                                              , input p-obj-code  as integer
                                              , input p-out-code as integer):
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.
find first buf_fbr-gds-grp no-lock where
          buf_fbr-gds-grp.obj-type = p-obj-type
      AND buf_fbr-gds-grp.obj-code = p-obj-code
      and buf_fbr-gds-grp.out-code = p-out-code no-error .
if not available buf_fbr-gds-grp then return ?.
return buf_fbr-gds-grp.node-name.
END FUNCTION.
function get-rkgTH-parent returns integer(input p-obj-type as character
                                          , input p-obj-code  as integer
                                          , input p-out-code as integer):
DEFINE BUFFER buf_fbr-gds-grp FOR ub.fbr-gds-grp.
DEFINE BUFFER upper_fbr-gds-grp FOR ub.fbr-gds-grp.
find first buf_fbr-gds-grp no-lock where
          buf_fbr-gds-grp.obj-type = p-obj-type
      AND buf_fbr-gds-grp.obj-code = p-obj-code
      and buf_fbr-gds-grp.out-code = p-out-code no-error .
if not available buf_fbr-gds-grp then return ?.
find first upper_fbr-gds-grp no-lock where
          upper_fbr-gds-grp.obj-type = p-obj-type
      AND upper_fbr-gds-grp.obj-code = p-obj-code
      and upper_fbr-gds-grp.out-code = buf_fbr-gds-grp.upper-code no-error .
if not available upper_fbr-gds-grp then return ?.
return upper_fbr-gds-grp.out-code.
END FUNCTION.
procedure get-rkep-full-grp-name :
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER p-grp-code LIKE ub.cd-grp.grp-code NO-UNDO.
define output parameter p-full-name as character    no-undo.
define variable v-upper-code    as integer  no-undo.
define buffer buf_cd-grp       for ub.cd-grp.
define buffer buf_upper_cd-grp for ub.cd-grp.
do
on error undo, return error
:
    if P-grp-code = 0
    then do:
        assign
            p-full-name = ""
        .
    end.
    else do:
        find first buf_cd-grp no-lock where
               buf_cd-grp.obj-type = 'маг':U
           and buf_cd-grp.obj-code = p-obj-code
           and buf_cd-grp.pos-type = 'r-keeper':U
           and buf_cd-grp.grp-type = '':U
           and buf_cd-grp.grp-code = p-grp-code
        no-error.
        if not available buf_cd-grp
        then do:
            undo, return error substitute("get-rkep-grp-name: Не найдена группа меню на кассе R-KEEPER с кодом &1", p-grp-code).
        end.
        assign
            p-full-name  = ""
            v-upper-code = 0
        .
        do while true
        on error undo, return error "get-rkep-grp-name: Ошибка составления полного имени группы"
        :
            assign
            p-full-name  = buf_cd-grp.grp-name
                        + (if p-full-name <> "" then chr(47) else "")
                        + p-full-name
            v-upper-code = buf_cd-grp.upper-grp-code
            .
            if buf_cd-grp.grp-code = 0
            then do:
                leave.
            end.
            find first buf_cd-grp no-lock where
                      buf_cd-grp.obj-type = 'маг':U
                  and buf_cd-grp.obj-code = p-obj-code
                  and buf_cd-grp.pos-type = 'r-keeper':U
                  and buf_cd-grp.grp-type = '':U
                  and buf_cd-grp.grp-code = v-upper-code no-error.
            if not available buf_cd-grp
            then do:
                undo, return error "get-rkep-grp-name: Не найдена группа товаров с кодом "
                                    + string( v-upper-code )
                                    + ". Ошибка ссылки в дереве товаров для узла p-id".
            end.
        end.
        assign
            p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
        .
    end.
end.
end procedure.
function get-price-id-from-int returns character ( input p-file-num as integer):
  return ('price-list':U + chr(32) +  string(p-file-num)).
end function.
define variable vss-include-info16 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbrglib_grp no-undo
    field sel           as character
    field full-name     as character
    field out-code      as integer
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field name          as character
    field level         as integer
    field mark          as character
    field obj-type      as character
    field obj-code      as integer
    field global-code   as integer
    index pi is primary unique obj-type obj-code sort-name
    index fn obj-type obj-code full-name
    index nc is unique obj-type obj-code node-code
    index sl obj-type obj-code sel
    index uc obj-type obj-code upper-code
.
define temp-table temp_fbrglib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    field obj-type      as character
    field obj-code      as integer
    index pi is primary unique obj-type obj-code sort-name
    index fn obj-type obj-code full-name
    index lv obj-type obj-code level
    index it obj-type obj-code is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as integer
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
procedure fbrglib-get-sort-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type  = p-obj-type
           and buf_fbr-gds-grp.obj-code  = p-obj-code
           and buf_fbr-gds-grp.node-code = p-node-code
    no-error.
    if not available buf_fbr-gds-grp
    then do:
        undo, return error "fbrglib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while true
    on error undo, return error "fbrglib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_fbr-gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_fbr-gds-grp.upper-code
        .
        if buf_fbr-gds-grp.upper-code = 1
        then do:
            leave.
        end.
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "fbrglib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
procedure fbrglib-get-full-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-full-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_fbr-gds-grp for ub.fbr-gds-grp.
    if p-node-code = 1
    then do:
        assign
            p-full-name = ""
        .
    end.
    else do:
        find first buf_fbr-gds-grp no-lock
             where buf_fbr-gds-grp.obj-type  = p-obj-type
               and buf_fbr-gds-grp.obj-code  = p-obj-code
               and buf_fbr-gds-grp.node-code = p-node-code
        no-error.
        if not available buf_fbr-gds-grp
        then do:
            undo, return error "fbrglib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
        end.
        assign
            p-full-name  = ""
            v-upper-code = 1
        .
        do while true
        on error undo, return error "fbrglib-get-full-name: Ошибка составления полного имени группы"
        :
            assign
                p-full-name  = buf_fbr-gds-grp.node-name
                            + (if p-full-name <> "" then chr(47) else "")
                            + p-full-name
                v-upper-code = buf_fbr-gds-grp.upper-code
            .
            if buf_fbr-gds-grp.upper-code = 1
            then do:
                leave.
            end.
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type  = p-obj-type
                   and buf_fbr-gds-grp.obj-code  = p-obj-code
                   and buf_fbr-gds-grp.node-code = v-upper-code
            no-error.
            if not available buf_fbr-gds-grp
            then do:
                undo, return error "fbrglib-get-full-name: Не найдена группа товаров с кодом "
                                    + string( v-upper-code )
                                    + ". Ошибка ссылки в дереве товаров для узла p-node-code".
            end.
        end.
        assign
            p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
        .
    end.
end.
end procedure.
procedure fbrglib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.upper-code = 0
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_fbr-gds-grp.node-code
        .
    end.
end.
end procedure.
procedure fbrglib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-obj-type     as character    no-undo.
define input parameter p-obj-code     as integer      no-undo.
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-not-found     as logical init yes no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define variable v-node-name     as character      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run fbrglib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "fbrglib-find-grp-by-full-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_fbrglib_found-grp
    :
        delete temp_fbrglib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            assign
                v-node-name = entry( v-counter, p-search-name, chr(2) )
            .
            find first buf_fbr-gds-grp no-lock
                 where buf_fbr-gds-grp.obj-type   = p-obj-type
                   and buf_fbr-gds-grp.obj-code   = p-obj-code
                   and buf_fbr-gds-grp.upper-code = v-upper-code
                   and buf_fbr-gds-grp.node-name  = v-node-name
            no-error .
            if not available buf_fbr-gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "fbrglib-find-grp-by-full-name: не найдена группа " + entry( v-level, p-search-name, chr(47) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_fbr-gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_fbr-gds-grp.node-name
                    v-upper-code = buf_fbr-gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_fbrglib_found-grp.
                    assign
                        temp_fbrglib_found-grp.full-name = v-full-name + chr(47)
                        temp_fbrglib_found-grp.sort-name = v-sort-name
                        temp_fbrglib_found-grp.node-code = v-upper-code
                        temp_fbrglib_found-grp.level     = v-counter
                        temp_fbrglib_found-grp.obj-type  = p-obj-type
                        temp_fbrglib_found-grp.obj-code  = p-obj-code
                    .
                end.
            end.
        end.
        else do:
            for each buf_fbr-gds-grp no-lock
               where buf_fbr-gds-grp.obj-type   = p-obj-type
                 and buf_fbr-gds-grp.obj-code   = p-obj-code
                 and buf_fbr-gds-grp.upper-code = v-upper-code
                 and buf_fbr-gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    v-not-found = no
                .
                create temp_fbrglib_found-grp.
                assign
                    temp_fbrglib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_fbr-gds-grp.node-name + chr(47)
                    temp_fbrglib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_fbr-gds-grp.node-name
                    temp_fbrglib_found-grp.node-code = buf_fbr-gds-grp.node-code
                    temp_fbrglib_found-grp.level     = v-level
                    temp_fbrglib_found-grp.obj-type  = p-obj-type
                    temp_fbrglib_found-grp.obj-code  = p-obj-code
                .
            end.
            if v-not-found = yes
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_fbrglib_found-grp
                :
                    delete temp_fbrglib_found-grp.
                end.
                return error "fbrglib-find-grp-by-full-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-obj-type     as character    no-undo.
define input parameter p-start-obj-code     as integer      no-undo.
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run fbrglib-get-full-name in this-procedure (
          input p-start-obj-type
        , input p-start-obj-code
        , input p-start-node-code
        , output v-start-full-name
    ).
    run fbrglib-get-full-name in this-procedure (
          input p-start-obj-type
        , input p-start-obj-code
        , input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_fbr-gds-grp no-lock
           where buf_fbr-gds-grp.obj-type   = p-start-obj-type
             and buf_fbr-gds-grp.obj-code   = p-start-obj-code
             and buf_fbr-gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run fbrglib-is-terminal in this-procedure (
                  input buf_fbr-gds-grp.obj-type
                , input buf_fbr-gds-grp.obj-code
                , input buf_fbr-gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_fbrglib_found-grp.
                assign
                    temp_fbrglib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                    temp_fbrglib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                    temp_fbrglib_found-grp.node-code   = buf_fbr-gds-grp.node-code
                    temp_fbrglib_found-grp.is-terminal = yes
                    temp_fbrglib_found-grp.obj-type  = p-start-obj-type
                    temp_fbrglib_found-grp.obj-code  = p-start-obj-code
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_fbr-gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_fbrglib_found-grp.
                    assign
                        temp_fbrglib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_fbr-gds-grp.node-name + chr(47)
                        temp_fbrglib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_fbr-gds-grp.node-name + chr(2)
                        temp_fbrglib_found-grp.node-code   = buf_fbr-gds-grp.node-code
                        temp_fbrglib_found-grp.is-terminal = no
                        temp_fbrglib_found-grp.obj-type  = p-start-obj-type
                        temp_fbrglib_found-grp.obj-code  = p-start-obj-code
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure fbrglib-expand-name :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-start-name as character    no-undo.
define output parameter p-end-name  as character    no-undo.
    define variable v-is-terminal     as logical           no-undo.
    define buffer buf_temp_fbrglib_found-grp     for temp_fbrglib_found-grp.
    run fbrglib-find-grp-by-full-name in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-start-name
        , input no
    ) no-error.
    run fbrglib-get-max-substring in this-procedure (
           input p-obj-type
        ,  input p-obj-code
        ,  input length( p-start-name )
        , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_fbrglib_found-grp
             where temp_fbrglib_found-grp.full-name = p-end-name
                AND temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
                     no-error.
        if available temp_fbrglib_found-grp
        then do:
            find first buf_temp_fbrglib_found-grp
                 where buf_temp_fbrglib_found-grp.full-name begins p-end-name
                   and recid( buf_temp_fbrglib_found-grp ) <> recid( temp_fbrglib_found-grp )
                AND temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
            no-error.
            if not available buf_temp_fbrglib_found-grp
            then do:
                run fbrglib-is-terminal in this-procedure (
                      input p-obj-type
                    , input p-obj-code
                    , input temp_fbrglib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-get-max-substring :
do
on error undo, return error
:
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_fbrglib_found-grp  where
                   temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
        no-error.
        if not available temp_fbrglib_found-grp
        then do:
            undo, return error "fbrglib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string = temp_fbrglib_found-grp.full-name
            .
            counter-block:
            do while yes
            on error undo, return error "fbrglib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_fbrglib_found-grp
                where temp_fbrglib_found-grp.obj-type  = p-obj-type
                AND temp_fbrglib_found-grp.obj-code  = p-obj-code
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_fbrglib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure fbrglib-is-terminal :
do
on error undo, return error "Ошибка процедуры fbrglib-is-terminal"
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type   = p-obj-type
           and buf_fbr-gds-grp.obj-code   = p-obj-code
           and buf_fbr-gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_fbr-gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure fbrglib-have-goods :
do
on error undo, return error
:
define input parameter p-obj-type           as character    no-undo.
define input parameter p-obj-code           as integer      no-undo.
define input parameter p-node-code          as integer      no-undo.
define output parameter p-have-fbr-gds-obj  as logical      no-undo.
    define buffer buf_fbr-gds-obj         for ub.fbr-gds-obj.
    find first buf_fbr-gds-obj no-lock
         where buf_fbr-gds-obj.obj-type     = p-obj-type
           and buf_fbr-gds-obj.obj-code     = p-obj-code
           and buf_fbr-gds-obj.fbr-grp-code = p-node-code
    no-error .
    if available buf_fbr-gds-obj
    then do:
        assign
            p-have-fbr-gds-obj = yes
        .
    end.
    else do:
        assign
            p-have-fbr-gds-obj = no
        .
    end.
end.
end procedure.
procedure fbrglib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-obj-type     as character    no-undo.
define input parameter p-start-obj-code     as integer      no-undo.
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    search-grp:
    for each buf_fbr-gds-grp no-lock
        where buf_fbr-gds-grp.obj-type  = p-start-obj-type
          and buf_fbr-gds-grp.obj-code  = p-start-obj-code
          and buf_fbr-gds-grp.node-code > p-start-code
    :
        if index( buf_fbr-gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_fbr-gds-grp.node-code
                v-found      = yes
            .
            run fbrglib-get-full-name in this-procedure (
                  input p-start-obj-type
                , input p-start-obj-code
                , input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "fbrglib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure fbrglib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-obj-type       as character            no-undo.
define input parameter p-obj-code       as integer              no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        run fbrglib-get-full-name in this-procedure (
              input p-obj-type
            , input p-obj-code
            , input p-upper-code
            , output v-full-name
        ) no-error .
        if error-status :error
        then do:
            undo, return error "fbrglib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
        end.
        if length( v-full-name ) + 1 + length( p-grp-name ) > 120
        then do:
            assign
                p-error-message = 'Полное название группы не может содержать более 120 символов.'
            .
        end.
    end.
end.
end procedure.
procedure fbrglib-delete-grp :
do
on error undo, return error
:
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-node-code  as integer      no-undo.
define output parameter p-deleted   as logical      no-undo.
    define variable v-have-goods    as logical        no-undo.
    define variable v-yesno         as logical        no-undo.
    define variable v-upper-code    as integer        no-undo.
    define variable v-root-code     as integer        no-undo.
    define buffer buf_fbr-gds-grp           for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-obj           for ub.fbr-gds-obj.
    define buffer buf_second_fbr-gds-grp    for ub.fbr-gds-grp.
    run fbrglib-get-root-code in this-procedure (
        output v-root-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "Не найден корневой узел." + chr(10) + return-value.
    end.
    if p-node-code = v-root-code
    then do:
        message
            "Корневую группу удалить невозможно."
        view-as alert-box error.
        assign
            p-deleted = no
        .
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type     = p-obj-type
           and buf_fbr-gds-grp.obj-code     = p-obj-code
           and buf_fbr-gds-grp.upper-code   = p-node-code
    no-error.
    if available buf_fbr-gds-grp
    then do:
        message
            "Не терминальную группу удалить невозможно."
        view-as alert-box error.
        assign
            p-deleted = no
        .
        undo, return.
    end.
    find first buf_fbr-gds-grp no-lock
         where buf_fbr-gds-grp.obj-type     = p-obj-type
           and buf_fbr-gds-grp.obj-code     = p-obj-code
           and buf_fbr-gds-grp.node-code    = p-node-code
    .
    assign
        v-upper-code = buf_fbr-gds-grp.upper-code
    .
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ).
    if v-have-goods = yes
    then do:
        find first buf_second_fbr-gds-grp no-lock
             where buf_second_fbr-gds-grp.obj-type      = buf_fbr-gds-grp.obj-type
               and buf_second_fbr-gds-grp.obj-code      = buf_fbr-gds-grp.obj-code
               and buf_second_fbr-gds-grp.upper-code    = buf_fbr-gds-grp.upper-code
               and recid( buf_second_fbr-gds-grp )      <> recid( buf_fbr-gds-grp )
        no-error.
        if available buf_second_fbr-gds-grp
        then do:
            message
                "В группе есть товары,"
                skip "которые нельзя перенести в родительскую группу,"
                skip "потому что у родительской группы есть еще одна подгруппа."
                skip(1)
                skip "Перенесите товары в другую группу"
                skip "или удалите все остальные подгруппы родительской группы."
            view-as alert-box error.
            assign
                p-deleted = no
            .
            undo, return.
        end.
        message
            "В группе есть товары."
            skip "После удаления группы"
            skip "все ее товары будут привязаны"
            skip "к ее родительской группе."
            skip(1)
            skip "Удалить группу?"
        view-as alert-box warning
        buttons yes-no
        title "Удаление группы"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            do transaction
            on error undo, return error
            :
                for each buf_fbr-gds-obj exclusive-lock
                   where buf_fbr-gds-obj.obj-type     = p-obj-type
                     and buf_fbr-gds-obj.obj-code     = p-obj-code
                     and buf_fbr-gds-obj.fbr-grp-code = p-node-code
                on error undo, return error
                :
                    assign
                        buf_fbr-gds-obj.fbr-grp-code = v-upper-code
                    .
                end.
            end.
            do transaction
            on error undo, return error
            :
                find current buf_fbr-gds-grp exclusive-lock .
                delete buf_fbr-gds-grp no-error .
                if error-status:error then do:
                  undo, return error return-value .
                end.
            end.
        end.
    end.
    else do:
        message
            "Имя группы: " buf_fbr-gds-grp.node-name
            "Код группы: " buf_fbr-gds-grp.node-code
            skip(1)
            skip "Удалить группу?"
        view-as alert-box warning
        buttons yes-no
        title "Удаление группы"
        update v-yesno
        .
        if v-yesno = yes
        then do:
            do transaction
            on error undo, return error
            :
                find current buf_fbr-gds-grp exclusive-lock .
                delete buf_fbr-gds-grp no-error.
                if error-status:error then do:
                  undo, return error return-value .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure fbrglib-add-grp :
do
on error undo, return error
:
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define input parameter p-node-code      as integer      no-undo.
define input parameter p-interface      as logical      no-undo.
define input parameter p-node-name      as character    no-undo.
define input parameter p-out-code       as integer      no-undo.
define input parameter p-global-code    as integer      no-undo.
define output parameter p-new-node-code as integer      no-undo.
define output parameter p-cancel        as logical      no-undo.
    define variable v-have-goods    as logical  no-undo.
    define variable v-host-code     as integer        no-undo.
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer bf_fbr-gds-grp        for ub.fbr-gds-grp.
    define buffer buf_fbr-gds-obj       for ub.fbr-gds-obj.
    run fbrglib-have-goods in this-procedure (
          input p-obj-type
        , input p-obj-code
        , input p-node-code
        , output v-have-goods
    ) no-error .
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка определения наличия товаров в группе."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find first buf_fbr-gds-grp no-lock where
              buf_fbr-gds-grp.upper-code = p-node-code
          AND buf_fbr-gds-grp.obj-type   = p-obj-type
          AND buf_fbr-gds-grp.obj-code   = p-obj-code
          AND buf_fbr-gds-grp.node-name  = p-node-name no-error .
    if available buf_fbr-gds-grp then do:
        if p-node-code <> 1 then do:
          find first buf_fbr-gds-grp no-lock where
                    buf_fbr-gds-grp.node-code = p-node-code
                AND buf_fbr-gds-grp.obj-type   = p-obj-type
                AND buf_fbr-gds-grp.obj-code   = p-obj-code  .
        end.
                message
        "Для объекта" p-obj-type p-obj-code
        "уже есть группа блюд" p-node-name "в подгруппе" (if p-node-code = 1 then "БЛЮДА" else buf_Fbr-gds-grp.node-name)
        view-as alert-box error .
        undo, return error .
    end.
    do transaction
    on error undo, return error
    :
        create buf_fbr-gds-grp.
        assign
            buf_fbr-gds-grp.node-code   = next-value( s-gds-grp, ub )
            p-new-node-code             = buf_fbr-gds-grp.node-code
            buf_fbr-gds-grp.upper-code  = p-node-code
            buf_fbr-gds-grp.host-code   = v-host-code
            buf_fbr-gds-grp.obj-type    = p-obj-type
            buf_fbr-gds-grp.obj-code    = p-obj-code
            buf_fbr-gds-grp.node-name    = ""
            buf_fbr-gds-grp.out-code    = 0
        .
        if p-interface then do:
          run ref/fbrggrpd.w (
                input parparentproc
              , input 'ИЗМЕНЕНИЕ':U
              , input p-obj-type
              , input p-obj-code
              , input buf_fbr-gds-grp.node-code
              , input buf_fbr-gds-grp.upper-code
              , input buf_fbr-gds-grp.node-name
              , input buf_fbr-gds-grp.out-code
              , output buf_fbr-gds-grp.node-name
              , output buf_fbr-gds-grp.out-code
              , output p-cancel
          ).
          if p-cancel = yes
          then do:
              delete buf_fbr-gds-grp.
              undo, return.
          end.
        end.
        else do:
          find first bf_fbr-gds-grp no-lock
              where bf_fbr-gds-grp.obj-type   = p-obj-type
                and bf_fbr-gds-grp.obj-code   = p-obj-code
                and bf_fbr-gds-grp.out-code   = p-out-code
          no-error.
          assign
          buf_fbr-gds-grp.node-name    = p-node-name
          buf_fbr-gds-grp.global-code  = p-global-code
          buf_fbr-gds-grp.out-code     = (if available bf_fbr-gds-grp then 0 else p-out-code)
          .
        end.
        if v-have-goods = yes
        then do:
            for each buf_fbr-gds-obj exclusive-lock
               where buf_fbr-gds-obj.obj-type      = p-obj-type
                 and buf_fbr-gds-obj.obj-code      = p-obj-code
                 and buf_fbr-gds-obj.fbr-grp-code  = p-node-code
            on error undo, return error
            :
                assign
                    buf_fbr-gds-obj.fbr-grp-code = p-new-node-code
                .
            end.
        end.
    end.
end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-session-status_ as character no-undo .
DEFINE TEMP-TABLE tt-cash-pay-r-keeper NO-UNDO LIKE ub.cash-pay
       field r-keeper-cdpay-code like ub.cash-pay.cdpay-code
       index pi is unique primary r-keeper-cdpay-code.
DEFINE TEMP-TABLE tt-dis-rule-r-keeper NO-UNDO LIKE ub.dis-rule
       field r-keeper-rule-num like ub.dis-rule.rule-num
       index pi is unique primary r-keeper-rule-num.
FUNCTION convert-cash-pay returns integer
                                          ( input p-cdpay-code-r-keeper as integer
                                           ,output p-curr-code as integer
                                          ) :
find first tt-cash-pay-r-keeper no-lock where
          tt-cash-pay-r-keeper.r-keeper-cdpay-code = p-cdpay-code-r-keeper    no-error .
if available tt-cash-pay-r-keeper then do:
  assign
  p-curr-code = tt-cash-pay-r-keeper.curr-code.
  return tt-cash-pay-r-keeper.cdpay-code.
end.
assign
p-curr-code = 0.
return p-cdpay-code-r-keeper.
END FUNCTION.
FUNCTION get-sales-man returns integer
                                          ( input p-r-keeper-sifr as integer
                                           ,input p-date as date
                                          ) :
define variable v-seller-code as integer no-undo .
define variable v-s-password as character no-undo .
define buffer buf_cd-clu for ub.cd-clu.
find first buf_cd-clu no-lock where
          buf_cd-clu.obj-type = p-obj-type
      and buf_cd-clu.obj-code = p-obj-code
      and buf_cd-clu.pos-type = 'r-keeper':U
      and buf_cd-clu.clu-type = 'W'
      and buf_cd-clu.clu-code = p-r-keeper-sifr no-error .
if not available buf_cd-clu then do :
  find first buf_cd-clu no-lock where
            buf_cd-clu.obj-type = p-obj-type
        and buf_cd-clu.obj-code = p-obj-code
        and buf_cd-clu.pos-type = 'r-keeper':U
        and buf_cd-clu.clu-type = 'M'
        and buf_cd-clu.clu-code = p-r-keeper-sifr no-error .
end.
if available buf_cd-clu and
            buf_cd-clu.cli-code <> ?
        and buf_cd-clu.cli-code <> 0 then do:
  assign
  v-seller-code = gbclcode-get-db-role (  input 'S':U
                                         ,input g#db-num
                                         ,input buf_cd-clu.cli-code
                                         ,input p-date
                                         ,output v-s-password ) no-error .
  if error-status:error
  then do:
     return ?.
  end.
  if buf_cd-clu.clu-type = 'M' and ( v-seller-code = ? or v-seller-code = 0 ) then do :
     v-seller-code = gbclcode-get-db-role (  input 'C':U
                                            ,input g#db-num
                                            ,input buf_cd-clu.cli-code
                                            ,input p-date
                                            ,output v-s-password ) no-error .
     if error-status:error
     then do:
       return ?.
     end.
  end.
  return v-seller-code.
end.
return 0.
END FUNCTION.
FUNCTION get-cashier returns integer
                                          ( input p-r-keeper-sifr as integer
                                            ,input p-date as date
                                          ) :
define variable v-cashier-code as integer no-undo .
define variable v-s-password as character no-undo .
define buffer buf_cd-clu for ub.cd-clu.
find first buf_cd-clu no-lock where
          buf_cd-clu.obj-type = p-obj-type
      and buf_cd-clu.obj-code = p-obj-code
      and buf_cd-clu.pos-type = 'r-keeper':U
      and buf_cd-clu.clu-type = 'K'
      and buf_cd-clu.clu-code = p-r-keeper-sifr no-error .
if not available buf_cd-clu then do :
  find first buf_cd-clu no-lock where
            buf_cd-clu.obj-type = p-obj-type
        and buf_cd-clu.obj-code = p-obj-code
        and buf_cd-clu.pos-type = 'r-keeper':U
        and buf_cd-clu.clu-type = 'M'
        and buf_cd-clu.clu-code = p-r-keeper-sifr no-error .
end.
if available buf_cd-clu and
            buf_cd-clu.cli-code <> ? then do:
  assign
  v-cashier-code = gbclcode-get-db-role (
                                          input 'C':U
                                         ,input g#db-num
                                         ,input buf_cd-clu.cli-code
                                         ,input p-date
                                         ,output v-s-password ) no-error .
  if error-status:error
  then do:
     return ?.
  end.
  if buf_cd-clu.clu-type = 'M' and ( v-cashier-code = ? or v-cashier-code = 0 ) then do :
     v-cashier-code = gbclcode-get-db-role (   input 'S':U
                                              ,input g#db-num
                                              ,input buf_cd-clu.cli-code
                                              ,input p-date
                                              ,output v-s-password ) no-error .
     if error-status:error
     then do:
       return ?.
     end.
  end.
  return v-cashier-code.
end.
return 0.
END FUNCTION.
DEFINE VARIABLE accept-types               as   character no-undo .
define variable v-flag-salesman            as   logical   no-undo .
define variable v-flag-card              as   logical   no-undo .
define variable v-end-of-check             as   logical no-undo init yes.
define variable v-seek                      as integer no-undo .
define variable ll-loc                      as integer no-undo .
assign
shop-type = p-obj-type
shop-code = p-obj-code
dflt-cd = 'r-keeper':U
.
if file_ <> "":U then  do:
  RUN get-r-keeper-c in this-procedure ( input file_)  no-error .
  if error-status:error then do:
  session:date-format = "dmy":U.
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
  session:date-format = "dmy":U.
end.
else do:
  run check-records-num in this-procedure no-error .
  if error-status:error then do:
    assign
    p-view-log = yes
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!При обработке данных с кассы &1 &2&3 нарушена целостность данных: &4"
                            , p-pos-type
                            , p-obj-type
                            , p-obj-code
                            , return-value
                          )
                                          ).
    undo, return.
  end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run get-r-keeper-parameters in this-procedure no-error.
  if error-status:error then do:
    assign
    p-view-log = yes
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!При обработке данных с кассы &1 &2&3 произошла ошибка при получении значений настроечных параметров:&4&5"
                            , p-pos-type
                            , p-obj-type
                            , p-obj-code
                            , chr(10)
                            , return-value
                          )
                                          ).
    undo, return.
  end.
  run save-r-keeper-data in this-procedure no-error .
  if error-status:error then do:
    assign
    p-view-log = yes
    .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!При обработке данных с кассы &1 &2&3 произошла ошибка при сохранении данных в БД:&4&5"
                            , p-pos-type
                            , p-obj-type
                            , p-obj-code
                            , chr(10)
                            , return-value
                          )
                                          ).
    undo, return.
  end.
end.
PROCEDURE get-r-keeper-c.
def input parameter filename as char no-undo.
define variable v-file-size as integer no-undo .
define variable v-sys_num as integer no-undo .
define variable v-line-num as integer no-undo .
define buffer buf_temp-control for temp-control.
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
  return.
end.
error-status:error = FALSE.
run gbl/filesize.p (
                input v-full-path
               ,output v-file-size)
               no-error .
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении длины файла: &2"
                          , filename
                          , return-value
                        )
                                  ).
  return.
end.
input stream ChkStream from value( filename ) convert source "ibm866".
if Lookup(p-table, "acheck,avcheck,control") > 0 then session:date-format = "mdy":U.
else session:date-format = "dmy":U.
_repeat:
REPEAT :
_line:
  DO TRANSACTION:
    v-seek  = seek(CHkstream).
    if (v-seek = ?) or (v-file-size - v-seek <= 2) then do:
      return.
    end.
    CASE p-table:
      when "ACHECK":U then do:
        if available temp-i-acheck then delete temp-i-acheck.
        create temp-i-acheck.
        import stream ChkStream temp-i-acheck no-error .
        if not error-status:error then do:
          create temp-acheck.
          buffer-copy temp-i-acheck to temp-acheck
          assign
          temp-acheck.start-time = integer(temp-acheck.opendate) +
                                   0.00001 * (integer(entry(1, temp-acheck.opentime, ":":U)) * 3600 + integer (entry(2, temp-acheck.opentime, ":":U)) * 60 )
          temp-acheck.end-time = integer(temp-acheck.realdate) +
                                   0.00001 * (integer(entry(1, temp-acheck.closetime, ":":U)) * 3600 + integer (entry(2, temp-acheck.closetime, ":":U)) * 60 )
          .
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "ADCHECK":U then do:
        if available temp-i-adcheck then delete temp-i-adcheck.
        create temp-i-adcheck.
        import stream ChkStream temp-i-adcheck no-error .
        if not error-status:error then do:
          create temp-adcheck.
          buffer-copy temp-i-adcheck to temp-adcheck
          assign
          v-line-num = (if v-sys_num = temp-i-adcheck.sys_num
                        then v-line-num
                        else 0)
          temp-adcheck.line-num = v-line-num + 1
          v-line-num = v-line-num + 1
          v-sys_num = temp-i-adcheck.sys_num
          .
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "APCHECK":U then do:
        if available temp-i-apcheck then delete temp-i-apcheck.
        create temp-i-apcheck.
        import stream ChkStream temp-i-apcheck no-error .
        if not error-status:error then do:
          create temp-apcheck.
          buffer-copy temp-i-apcheck to temp-apcheck
          assign
          v-line-num = (if v-sys_num = temp-i-apcheck.sys_num
                        then v-line-num
                        else 0)
          temp-apcheck.line-num = v-line-num + 1
          v-line-num = v-line-num + 1
          v-sys_num = temp-i-apcheck.sys_num
          .
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "ARCHECK":U then do:
        if available temp-i-archeck then delete temp-i-archeck.
        create temp-i-archeck.
        import stream ChkStream temp-i-archeck no-error .
        if not error-status:error then do:
          create temp-archeck.
          buffer-copy temp-i-archeck to temp-archeck
          assign
          v-line-num = (if v-sys_num = temp-i-archeck.sys_num
                        then v-line-num
                        else 0)
          temp-archeck.line-num = v-line-num + 1
          v-sys_num = temp-i-archeck.sys_num
          v-line-num = v-line-num + 1
          .
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "AVCHECK":U then do:
        if available temp-i-avcheck then delete temp-i-avcheck.
        create temp-i-avcheck.
        import stream ChkStream temp-i-avcheck no-error .
        if not error-status:error then do:
          create temp-avcheck.
          buffer-copy temp-i-avcheck to temp-avcheck
          assign
          temp-avcheck.del-time = integer(temp-avcheck.realdate) +
                                  0.00001 * (integer(entry(1, temp-avcheck.f_time, ":":U)) * 3600 + integer (entry(2, temp-avcheck.f_time, ":":U)) * 60 )
          temp-avcheck.line-num = v-line-num + 1
          v-line-num = v-line-num + 1
          temp-avcheck.sys_num = 0
          .
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "CATEG":U then do:
        if available temp-i-categ then delete temp-i-categ.
        create temp-i-categ.
        import stream ChkStream temp-i-categ no-error .
        if not error-status:error then do:
          create temp-categ.
          buffer-copy temp-i-categ to temp-categ.
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "CHARGES":U then do:
        if available temp-i-charges then delete temp-i-charges.
        create temp-i-charges.
        import stream ChkStream temp-i-charges no-error .
        if not error-status:error then do:
          create temp-charges.
          buffer-copy temp-i-charges to temp-charges.
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "CONTROL":U then do:
        if available temp-i-control then delete temp-i-control.
        create temp-i-control.
        import stream ChkStream temp-i-control no-error .
        if not error-status:error then do:
          create temp-control.
          buffer-copy temp-i-control to temp-control.
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "MENU":U then do:
        if available temp-i-menu then delete temp-i-menu.
        create temp-i-menu.
        import stream ChkStream temp-i-menu no-error .
        if not error-status:error then do:
          create temp-menu.
          buffer-copy temp-i-menu to temp-menu.
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "MODIFY":u then do:
        if available temp-i-modify then delete temp-i-modify.
        create temp-i-modify.
        import stream ChkStream temp-i-modify no-error .
        if not error-status:error then do:
          create temp-modify.
          buffer-copy temp-i-modify to temp-modify.
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "MONEY":u then do:
        if available temp-i-money then delete temp-i-money.
        create temp-i-money.
        import stream ChkStream temp-i-money no-error .
        if not error-status:error then do:
          create temp-money.
          buffer-copy temp-i-money to temp-money.
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "PERSONAL":u then do:
        if available temp-i-personal then delete temp-i-personal.
        create temp-i-personal.
        import stream ChkStream temp-i-personal no-error .
        if not error-status:error then do:
          create temp-personal.
          buffer-copy temp-i-personal to temp-personal.
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      when "REASONS":u then do:
        if available temp-i-reasons then delete temp-i-reasons.
        create temp-i-reasons.
        import stream ChkStream temp-i-reasons no-error .
        if not error-status:error then do:
          create temp-reasons.
          buffer-copy temp-i-reasons to temp-reasons.
          find first buf_temp-control where                 buf_temp-control.file_ = chr(4) + p-table  no-error .        if not available buf_temp-control then do:                                     create buf_temp-control.                                                      assign                                                                        buf_temp-control.file_ = chr(4) + p-table                             .                                                                             error-status:error = no.                                                    end.                                                                          assign                                                                        buf_temp-control.records = buf_temp-control.records + 1.
        end.
        if error-status:error then do:                                                  run write-log-and-file in p-log-handle (                                            input 1                                                                     , input log-file-name                                                         , input 1                                                                     , input substitute("!!!При чтении данных из файла &1 в строке &2 произошла ошибка:&3&4"                                , filename                                                                                           , var-file-line-num                                                                                  , chr(10)                                                                                      , error-status:get-message(1)                                                                          )).                                                                          assign                                                                                               p-view-log = yes                                                                                     .                                                                                                  end.
      end.
      otherwise do:
        return.
      end.
    END CASE.
    assign
    var-file-line-num = var-file-line-num + 1
    .
    if var-file-line-num modulo 100 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Файл &1: прочитано строк &2", filename, var-file-line-num)).
    end.
  END.
END.
session:date-format = "dmy":U.
error-status:error = false.
input stream ChkStream close.
END PROCEDURE.
PROCEDURE get-r-keeper-parameters:
define variable v-cash-pay-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-cdpay-code-r-keeper LIKE ub.cash-pay.cdpay-code NO-UNDO.
define variable v-dis-rule-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-rule-num-r-keeper LIKE ub.dis-rule.rule-num NO-UNDO.
define variable ii as integer no-undo .
define variable v-entry as character no-undo .
DEFINE VARIABLE v-cdpay-code LIKE ub.cash-pay.cdpay-code NO-UNDO.
DEFINE VARIABLE v-curr-code LIKE ub.cash-pay.curr-code NO-UNDO.
DEFINE VARIABLE v-rule-num LIKE ub.dis-rule.rule-num NO-UNDO.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_dis-rule for ub.dis-rule.
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
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-type-r-keeper':U
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
                        , 'r-keeper':U
                        , p-obj-code)
                                        ).
    assign
    p-view-log = yes
    .
    undo, return .
end.
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.obj-type = p-obj-type
    and thbjattr_thbj-attr.obj-code = p-obj-code
    and thbjattr_thbj-attr.upper-prop-code =  'cd-type-r-keeper':U
on error undo, return error :
  case thbjattr_thbj-attr.prop-code :
    when 'cash-pay-list':U then do:
      assign
      v-cash-pay-list = thbjattr_thbj-attr.property-value-character.
    end.
    when 'dis-rule-list':U then do:
      assign
      v-dis-rule-list = thbjattr_thbj-attr.property-value-character.
    end.
  end case.
end.
if v-cash-pay-list <> "":U then do:
_ii:
DO ii = 1 TO  NUM-ENTRIES(v-cash-pay-list, ";"):
   ASSIGN
   v-entry = entry(ii, v-cash-pay-list, ";":U)
   v-cdpay-code-r-keeper = integer(entry(1, entry(1, v-entry, chr(47)), chr(44)))
   v-cdpay-code = integer(entry(1, entry(2, v-entry, chr(47)), chr(44)))
   v-curr-code = integer(entry(2, entry(2, v-entry, chr(47)), chr(44)))
   .
   FIND FIRST buf_cash-pay NO-LOCK WHERE
                buf_cash-pay.cdpay-code = v-cdpay-code
        AND buf_cash-pay.curr-code = v-curr-code  NO-ERROR.
   IF NOT AVAILABLE buf_cash-pay THEN NEXT _ii.
    CREATE tt-cash-pay-r-keeper.
    BUFFER-COPY buf_cash-pay TO tt-cash-pay-r-keeper
    ASSIGN
    tt-cash-pay-r-keeper.r-keeper-cdpay-code = v-cdpay-code-r-keeper
    .
END.
end.
if v-dis-rule-list <> "":U then do:
  _ii:
  DO ii = 1 TO  NUM-ENTRIES(v-dis-rule-list, ";"):
    ASSIGN
    v-entry = entry(ii, v-dis-rule-list, ";":U)
    v-rule-num-r-keeper = integer(entry(1, entry(1, v-entry, chr(47)), chr(44)))
    v-rule-num = integer(entry(1, entry(2, v-entry, chr(47)), chr(44)))
    .
    FIND FIRST buf_dis-rule NO-LOCK WHERE
                buf_dis-rule.rule-num = v-rule-num  NO-ERROR.
    IF NOT AVAILABLE buf_dis-rule THEN NEXT _ii.
    CREATE tt-dis-rule-r-keeper.
    BUFFER-COPY buf_dis-rule TO tt-dis-rule-r-keeper
    ASSIGN
    tt-dis-rule-r-keeper.r-keeper-rule-num = v-rule-num-r-keeper
    .
  END.
end.
END PROCEDURE.
procedure check-records-num :
define variable v-return-value as character no-undo .
define buffer buf_temp-control for temp-control.
  do
  on error undo, return error return-value
  :
    for each temp-control no-lock:
      if  temp-control.file_ begins chr(4) then NEXT.
      if LOOKUP(temp-control.file, "control,menu,modify,money,personal,reasons,charges,acheck,adcheck,apcheck,archeck,avcheck":U) = 0  then NEXT.
      if p-file-num < 0 and LOOKUP(temp-control.file, "control,menu,reasons,acheck,adcheck,apcheck,archeck,avcheck":U) = 0   then NEXT.
      find first buf_temp-control no-lock where
                buf_temp-control.file_ begins (chr(4) + temp-control.file_) no-error .
      if (not available buf_temp-control and temp-control.records <> 0)
      or (available buf_temp-control and temp-control.records <> buf_temp-control.records)
      then do:
        assign
        v-return-value = v-return-value + chr(10) +
                         substitute("Файл &1: ожидалось &2 записей - получено &3"
                                    , temp-control.file_
                                    , temp-control.records
                                    , (if available buf_temp-control then buf_temp-control.records else 0)
                                    ).
      end.
    end.
    if v-return-value <> "":u then do:
      return error v-return-value.
    end.
  end.
end procedure.
procedure save-r-keeper-data :
define buffer buf_cd-doc for ub.cd-doc.
  do
  on error undo, return error return-value
  :
      run save-goods in this-procedure no-error .
      if error-status:error then do:
        return error return-value .
      end.
      run save-modifiers in this-procedure no-error .
      if error-status:error then do:
        return error return-value .
      end.
      run save-clients in this-procedure no-error .
      if error-status:error then do:
        return error return-value .
      end.
    find first buf_cd-doc exclusive-lock where
            buf_cd-doc.obj-type = p-obj-type
        and buf_cd-doc.obj-code = p-obj-code
        and buf_cd-doc.pos-type = 'r-keeper':U
        and buf_cd-doc.doc-type = '':U
        and buf_cd-doc.doc-code = string((abs(p-file-num))) no-wait no-error.
    if not available buf_cd-doc then do:
      return error substitute("!!!Не найдена запись сессии чтения чеков с касс R-KEEPER для маг&1", p-obj-code).
    end.
    assign
    buf_cd-doc.to-send = yes
    buf_cd-doc.charkey_one = '':U
    .
    run get-checks in this-procedure no-error .
    assign
    buf_cd-doc.charkey_one = v-session-status_
    buf_cd-doc.to-send = (v-session-status_ = 'U')
    .
    if error-status:error then do:
       return error return-value .
    end.
  end.
end procedure.
procedure save-goods :
define variable v-mode as character no-undo .
define variable v-update-price as logical no-undo .
define variable v-update-name as logical no-undo .
define variable v-update-group as logical no-undo .
define variable v-update-modificator as logical no-undo .
define variable v-update-parent as logical no-undo .
define variable v-deleted    as logical   no-undo .
define variable v-price      as decimal  no-undo .
define variable v-price-sale as decimal no-undo .
define variable v-doc-num    as character no-undo .
define variable v-gds-name   as character no-undo .
define variable v-grp-code   as integer no-undo .
define variable v-grp-name   as character no-undo .
define variable v-modif      as logical no-undo .
define variable v-null-price as logical no-undo .
define variable v-parent     as integer no-undo .
define variable v-dop-code-int as integer no-undo .
define variable v-lvl-num as integer no-undo .
define variable v-upper-num as integer no-undo .
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cd-grp for ub.cd-grp.
define buffer buf_cd-doc-line for ub.cd-doc-line.
define buffer ucs_cd-grp for ub.cd-grp.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer buf_clients for ub.clients.
define buffer buf_goods for ub.goods.
define buffer upper_temp-menu for temp-menu.
  _main:
  do
  on error undo, return error return-value
  :
    _temp-menu:
    for each temp-menu:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Сохранение полученных данных: обработано записей &1", ll-loc)).
      assign
      v-dop-code-int = integer(temp-menu.code-chr)
      no-error
      .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Ошибка при обработке записи блюда с id &1 код меню &2 &3:&4&5 &6"
                                  , temp-menu.sifr
                                  , temp-menu.code-chr
                                  , temp-menu.name
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value
                                )
                                                ).
      end.
      assign
      v-mode = "":U
      v-update-name = no
      v-update-price = no
      v-update-group = no
      v-update-modificator = no
      v-price-sale = ?
      v-gds-name  = "":U
      v-grp-code  = 0
      v-modif = no
      v-null-price = no
      .
      if temp-menu.treetype = "F":U
      or temp-menu.treetype = "L":U then do:
        find first buf_cd-plu where
                  buf_cd-plu.obj-type = p-obj-type
             and  buf_cd-plu.obj-code = p-obj-code
             and buf_cd-plu.pos-type = 'r-keeper':U
             and buf_cd-plu.plu-type = '':U
             and buf_cd-plu.plu-code = temp-menu.sifr no-error.
        if not available buf_cd-plu then do:
          assign
          v-mode = 'ДОБАВЛЕНИЕ':U.
        end.
        else do:
          find last buf_cd-doc-line where
                   buf_cd-doc-line.obj-type = p-obj-type
               and buf_cd-doc-line.obj-code = p-obj-code
               and buf_cd-doc-line.pos-type = 'r-keeper':U
               and buf_cd-doc-line.doc-type = 'переоценка':U
               and buf_cd-doc-line.doc-code < string(p-file-num)
               AND buf_cd-doc-line.plu-type = '':U
               AND buf_cd-doc-line.plu-code = temp-menu.sifr no-error .
          if not available buf_cd-doc-line then do:
            assign
            v-price = ?
            v-update-price = yes
            v-update-name =  yes
            v-update-group = yes
            v-update-modificator = yes
            .
          end.
          else do:
            assign
            v-price = buf_cd-doc-line.deckey_one
            .
          end.
          if buf_cd-plu.b-code <> 0 then do:
            assign
            v-price-sale = get-rkgTH-price(shop-type, shop-code, buf_cd-plu.b-code, output v-doc-num)
            v-gds-name   = get-rkgTH-name(shop-type, shop-code, buf_cd-plu.b-code, buffer buf_goods)
            v-grp-code   = get-rkgTH-group(shop-type, shop-code, buf_cd-plu.b-code
                          , output v-grp-name)
            v-modif      = get-rkgTH-modificator(shop-type, shop-code, buf_cd-plu.b-code, output v-null-price)
            .
            assign
            v-update-price = (temp-menu.price <> v-price-sale) or v-price-sale = ?
            v-update-name =  (temp-menu.name <> v-gds-name)
            v-update-group  =  (temp-menu.parent <> v-grp-code)
            v-update-modificator =  ((temp-menu.price = 0 and not v-null-price)
                                     or
                                   (temp-menu.price <> 0 and v-null-price))
            .
          end.
          if (buf_cd-plu.key#_two <> temp-menu.parent)
          or (buf_cd-plu.charkey_one <> temp-menu.name)
          or v-update-name
          or (buf_cd-plu.to-del <>  (not temp-menu.del))
          or (buf_cd-plu.to-send <> temp-menu.del)
          or (buf_cd-plu.b-code > 0 and (v-price = ? or (temp-menu.price <> v-price) or v-update-price or v-price-sale = ? ))
          or (buf_cd-plu.key#_one <> v-dop-code-int)
          or v-update-group
          or v-update-modificator
          then do:
            assign
            v-mode = 'ИЗМЕНЕНИЕ':U
            .
          end.
        end.
        if v-mode <> "":U then do:
          run update-product in this-procedure (
                                                   input v-mode
                                                  ,input v-update-name
                                                  ,input v-update-price
                                                  ,input v-update-group
                                                  ,input v-update-modificator
                                                  ,input temp-menu.sifr
                                                  ,input temp-menu.code-chr
                                                  ,input temp-menu.name
                                                  ,input temp-menu.treetype
                                                  ,input temp-menu.price
                                                  ,input temp-menu.parent
                                                  ,input temp-menu.del
                                                  )
          no-error .
          if error-status:error then do:
            run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "!!!Ошибка при сохранении записи блюда меню с id &1 код меню &2 &3:&4&5 &6"
                                      , temp-menu.sifr
                                      , temp-menu.code-chr
                                      , temp-menu.name
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                    )
                                                    ).
            assign
            p-view-log = yes
            .
            undo _temp-menu, next _temp-menu.
          end.
        end.
      end.
      if temp-menu.treetype = "T":U then do:
        assign
        v-update-name = no
        v-update-parent = no
        v-grp-name = "":U
        v-parent = 0
        .
        if temp-menu.parent = 0 then v-lvl-num = 0.
        else do:
          assign
          v-upper-num = temp-menu.parent
          .
          v-lvl-num = - 1.
          do while available  upper_temp-menu or v-lvl-num = - 1:
            find first upper_temp-menu no-lock where
                      upper_temp-menu.sifr = v-upper-num
                        no-error.
            assign
            v-lvl-num = (if v-lvl-num = - 1 then 0 else v-lvl-num )
            v-lvl-num = (if available upper_temp-menu then v-lvl-num + 1 else v-lvl-num)
            v-upper-num = (if available upper_temp-menu then upper_temp-menu.parent else v-upper-num)
            .
          end.
          if v-lvl-num = 0 then do:
            run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "!!!Ошибка при сохранении записи группы блюд меню с id &1 &2:&3не удалось определить уровень грппы"
                                      , temp-menu.sifr
                                      , temp-menu.name
                                      , chr(10)
                                    )
                                                    ).
            assign
            p-view-log = yes
            .
            undo _temp-menu, next _temp-menu.
          end.
          assign
          temp-menu.lvl-num = v-lvl-num.
        end.
        find first buf_cd-grp no-lock where
                 buf_cd-grp.obj-type = p-obj-type
            and buf_cd-grp.obj-code = p-obj-code
            and buf_cd-grp.pos-type = 'r-keeper':U
            and buf_cd-grp.grp-type = '':U
            and buf_cd-grp.grp-code = temp-menu.sifr no-error .
        if not available buf_cd-grp then do:
          assign
          v-mode = 'ДОБАВЛЕНИЕ':U
          v-update-name =  yes
          v-update-parent = yes
          .
        end.
        else do:
          assign
          v-grp-name   = get-rkgTH-group-name(shop-type, shop-code, temp-menu.sifr)
          v-parent    = get-rkgTH-parent(shop-type, shop-code, temp-menu.sifr)
          .
          assign
          v-update-name =  v-grp-name = ? or v-grp-name <> temp-menu.name
          v-update-parent = v-parent = ? or v-parent <> temp-menu.parent
          .
          if buf_cd-grp.grp-name <> temp-menu.name
          OR buf_cd-grp.upper-grp-code <> temp-menu.parent
          or buf_cd-grp.key#_one <> temp-menu.lvl-num
          or v-update-name
          or v-update-parent
          then do:
            assign
            v-mode = 'ИЗМЕНЕНИЕ':U
            .
          end.
        end.
        if v-mode <> "":U then do:
          run update-country in this-procedure (
                                                   input v-mode
                                                  ,input v-update-name
                                                  ,input v-update-parent
                                                  ,input temp-menu.sifr
                                                  ,input temp-menu.name
                                                  ,input temp-menu.parent
                                                  ,input temp-menu.del
                                                  ,input temp-menu.lvl-num
                                                  )
          no-error .
          if error-status:error then do:
            run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "!!!Ошибка при обработке сохранении записи группы меню с id &1 &2:&3&4 &5"
                                      , temp-menu.sifr
                                      , temp-menu.name
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                    )
                                                    ).
            assign
            p-view-log = yes
            .
            undo _temp-menu, next _temp-menu.
          end.
        end.
      end.
    end.
    for each buf_cd-plu :
      if buf_cd-plu.charkey_two= "M" then next.
      if not can-find(first temp-menu no-lock where
                           temp-menu.sifr = buf_cd-plu.plu-code
                       AND (temp-menu.treetype = "F":U or
                            temp-menu.treetype = "L":U )) then do:
        delete buf_cd-plu .
      end.
    end.
    for each buf_cd-grp where
            buf_cd-grp.obj-type = p-obj-type
        and buf_cd-grp.obj-code = p-obj-code
        and buf_cd-grp.pos-type = 'r-keeper':U
        and buf_cd-grp.grp-type = '':U  :
      if not can-find(first temp-menu no-lock where
                           temp-menu.sifr = buf_cd-grp.grp-code
                       AND temp-menu.treetype = "T":U)  then do:
        for each buf_fbr-gds-grp where
                buf_fbr-gds-grp.obj-type = p-obj-type
            AND buf_fbr-gds-grp.obj-code = p-obj-code
            and buf_fbr-gds-grp.out-code = buf_cd-grp.grp-code
        on error undo _main, return error return-value :
          assign
          buf_fbr-gds-grp.out-code = 0
          .
        end.
        delete buf_cd-grp .
      end.
    end.
  end.
end procedure.
procedure save-modifiers :
define variable v-mode as character no-undo .
define variable v-update-name as logical no-undo .
define variable v-update-modificator as logical no-undo .
define variable v-deleted    as logical   no-undo .
define variable v-price      as decimal  no-undo .
define variable v-price-sale as decimal   no-undo .
define variable v-gds-name   as character no-undo .
define variable v-doc-num    as character no-undo .
define variable v-modif      as logical no-undo .
define variable v-null-price as logical no-undo .
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cd-doc-line for ub.cd-plu.
define buffer buf_goods for ub.goods.
  _main:
  do
  on error undo, return error return-value
  :
    _temp-modify:
    for each temp-modify no-lock:
      if temp-modify.parent = 0 then next _temp-modify.
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Сохранение полученных данных: обработано записей &1", ll-loc)).
      assign
      v-mode = "":U.
      find first buf_cd-plu where
                buf_cd-plu.obj-type = p-obj-type
            and buf_cd-plu.obj-code = p-obj-code
            and buf_cd-plu.pos-type = 'r-keeper':U
            and buf_cd-plu.plu-type = 'modifier':U
            and buf_cd-plu.plu-code = temp-modify.sifr no-error.
      if not available buf_cd-plu then do:
        assign
        v-mode = 'ДОБАВЛЕНИЕ':U
        v-update-name = no
        v-update-modificator = no
        .
      end.
      else do:
        if buf_cd-plu.b-code <> 0 then do:
          assign
          v-gds-name   = get-rkgTH-name(shop-type, shop-code, buf_cd-plu.b-code, buffer buf_goods)
          v-modif      = get-rkgTH-modificator(shop-type, shop-code, buf_cd-plu.b-code, output v-null-price)
          .
          assign
          v-update-name =  (temp-modify.name <> v-gds-name)
          v-update-modificator  =  ( not v-modif OR not v-null-price)
          .
        end.
        if (buf_cd-plu.charkey_one <> temp-modify.name)
        or (buf_cd-plu.to-send <>  temp-modify.del)
        or (buf_cd-plu.to-del <>  (not temp-modify.del))
        or v-update-name
        or v-update-modificator
        then do:
          assign
          v-mode = 'ИЗМЕНЕНИЕ':U
          .
        end.
      end.
      if v-mode <> "":U then do:
        run update-product in this-procedure (
                                                 input v-mode
                                                ,input v-update-name
                                                ,input no
                                                ,input no
                                                ,input v-update-modificator
                                                ,input - temp-modify.sifr
                                                ,input 0
                                                ,input temp-modify.name
                                                ,input "M":U
                                                ,input temp-modify.realprice
                                                ,input 0
                                                ,input temp-modify.del
                                                )
        no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при сохранении записи модификатора с id&1 &2:&3&4 &5"
                                    , temp-modify.sifr
                                    , temp-modify.name
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                  )
                                                  ).
          assign
          p-view-log = yes
          .
          undo _temp-modify, next _temp-modify.
        end.
      end.
    end.
    for each buf_cd-plu :
      if not buf_cd-plu.charkey_two= "M":U then next.
      if not can-find(first temp-modify no-lock where
                           temp-modify.sifr = buf_cd-plu.plu-code
                                                   ) then do:
        delete buf_cd-plu .
      end.
    end.
  end.
end procedure.
procedure save-clients :
define variable v-mode as character no-undo .
define variable v-deleted    as logical   no-undo .
define buffer buf_cd-clu for ub.cd-clu.
  _main:
  do
  on error undo, return error return-value
  :
    _temp-personal:
    for each temp-personal no-lock:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Сохранение полученных данных: обработано записей &1", ll-loc)).
      assign
      v-mode = "":U.
        find first buf_cd-clu no-lock where
                  buf_cd-clu.obj-type = p-obj-type
              and buf_cd-clu.obj-code = p-obj-code
              and buf_cd-clu.pos-type = 'r-keeper':U
              and buf_cd-clu.clu-type = temp-personal.type
              and buf_cd-clu.clu-code = temp-personal.sifr no-error.
      if not available buf_cd-clu then do:
        assign
        v-mode = 'ДОБАВЛЕНИЕ':U.
      end.
      else do:
        if (buf_cd-clu.charkey_one <> temp-personal.name)
        or buf_cd-clu.to-send <>  temp-personal.del
        or buf_cd-clu.to-del <>  (not temp-personal.del)
        then do:
          assign
          v-mode = 'ИЗМЕНЕНИЕ':U.
        end.
      end.
      if v-mode <> "":U then do:
        run update-clients in this-procedure (
                                                 input v-mode
                                                ,input temp-personal.sifr
                                                ,input temp-personal.name
                                                ,input temp-personal.type
                                                ,input temp-personal.del
                                                )
        no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при сохранении записи персонала с id &1 &2:&3&4 &5"
                                    , temp-personal.sifr
                                    , temp-personal.name
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                  )
                                                  ).
          assign
          p-view-log = yes
          .
          undo _temp-personal, next _temp-personal.
        end.
      end.
    end.
    for each buf_cd-clu :
      if not can-find(first temp-personal no-lock where
                           temp-personal.sifr = buf_cd-clu.clu-code) then do:
        delete buf_cd-clu .
      end.
    end.
  end.
end procedure.
procedure update-product :
define input parameter p-mode     as character no-undo .
define input parameter p-update-name as logical no-undo .
define input parameter p-update-price as logical no-undo .
define input parameter p-update-group as logical no-undo .
define input parameter p-update-modificator as logical no-undo .
define input parameter p-sifr     as integer no-undo .
define input parameter p-code-chr as character no-undo .
define input parameter p-name     as character no-undo .
define input parameter p-treetype as character no-undo .
define input parameter p-price    as decimal no-undo .
define input parameter p-parent   as integer no-undo .
define input parameter p-del      as logical no-undo .
define variable v-old-treetype as character no-undo .
define variable v-old-parent   as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-b-code     as integer   no-undo .
define variable v-doc-num    as character no-undo .
define variable v-price-sale as decimal   no-undo .
define variable v-road-tax   as decimal   no-undo .
define variable v-excise     as decimal   no-undo .
define variable v-vat-pc     as decimal   no-undo .
define variable v-slt-pc     as decimal   no-undo .
define variable v-line-num as integer no-undo .
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cd-doc-line for ub.cd-doc-line.
define buffer buf_cd-doc for ub.cd-doc.
define buffer buf_goods for ub.goods.
define buffer buf_cd-grp        for ub.cd-grp.
  _main:
  do
  on error undo, return error return-value
  :
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      create buf_cd-plu.
      assign
      buf_cd-plu.obj-type    = p-obj-type
      buf_cd-plu.obj-code    = p-obj-code
      buf_cd-plu.pos-type    = 'r-keeper':U
      buf_cd-plu.plu-type    = (if p-sifr > 0 then '':U else 'modifier')
      buf_cd-plu.plu-code    = abs(p-sifr)
      .
    end.
    else do:
      find first buf_cd-plu exclusive-lock where
              buf_cd-plu.obj-type    = p-obj-type
          and buf_cd-plu.obj-code    = p-obj-code
          and buf_cd-plu.pos-type    = 'r-keeper':U
          and buf_cd-plu.plu-type    = (if p-sifr > 0 then '':U else 'modifier')
          and buf_cd-plu.plu-code = abs(p-sifr) no-error.
      if not available buf_cd-plu then do:
        return error substitute("не найдена или занята запись товара/группы для кассы R-KEEPER с id = &1"
                              ,p-sifr).
      end.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    assign
    buf_cd-plu.charkey_one = p-name
    buf_cd-plu.key#_one = integer(p-code-chr)
    buf_cd-plu.to-del   =  not p-del
    buf_cd-plu.to-send   =  p-del
    buf_cd-plu.key#_two = p-parent
    buf_cd-plu.charkey_two = p-treetype
    buf_cd-plu.logkey_one = p-update-name
    buf_cd-plu.logkey_two = p-update-price
    buf_cd-plu.logkey_three = p-update-group
    buf_cd-plu.logkey_four = p-update-modificator
    .
    if not (p-treetype = "M":U and p-price = 0) then do:
      find first buf_cd-doc no-lock where
                buf_cd-doc.obj-type = p-obj-type
            and buf_cd-doc.obj-code = p-obj-code
            and buf_cd-doc.pos-type = 'r-keeper':U
            and buf_cd-doc.doc-type = 'переоценка':U
            and buf_cd-doc.doc-code = string(p-file-num)   no-error .
      if not available buf_cd-doc then do:
        run cur-time in this-procedure( output v-today, output v-time).
        create buf_cd-doc.
        assign
        buf_cd-doc.doc-type = 'переоценка':U
        buf_cd-doc.pos-type = 'r-keeper':U
        buf_cd-doc.doc-code = string(p-file-num)
        buf_cd-doc.obj-type = p-obj-type
        buf_cd-doc.obj-code = p-obj-code
        buf_cd-doc.datekey_one = v-today
        .
      end.
      find first buf_cd-doc-line no-lock where
              buf_cd-doc-line.obj-type = p-obj-type
          and buf_cd-doc-line.obj-code = p-obj-code
          and buf_cd-doc-line.pos-type = 'r-keeper':U
          and buf_cd-doc-line.doc-type = 'переоценка':U
          and buf_cd-doc-line.doc-code = string(p-file-num)
          and buf_cd-doc-line.plu-type = '':U
          and buf_cd-doc-line.plu-code = p-sifr no-error.
      if not available buf_cd-doc-line then do:
        find last buf_cd-doc-line no-lock where
                buf_cd-doc-line.obj-type = p-obj-type
            and buf_cd-doc-line.obj-code = p-obj-code
            and buf_cd-doc-line.pos-type = 'r-keeper':U
            and buf_cd-doc-line.doc-type = 'переоценка':U
            and buf_cd-doc-line.doc-code = string(p-file-num)
            and buf_cd-doc-line.plu-type = '':U no-error.
        if not available buf_cd-doc-line then do:
          v-line-num = 1.
        end.
        else do:
          assign
          v-line-num = buf_cd-doc-line.line-num  + 1.
        end.
        define variable v-price-id as character no-undo .
        create buf_cd-doc-line.
        assign
        buf_cd-doc-line.obj-type = p-obj-type
        buf_cd-doc-line.obj-code = p-obj-code
        buf_cd-doc-line.pos-type = 'r-keeper':U
        buf_cd-doc-line.plu-code = p-sifr
        buf_cd-doc-line.plu-type = '':U
        buf_cd-doc-line.deckey_one = p-price
        buf_cd-doc-line.doc-type = 'переоценка':U
        buf_cd-doc-line.doc-code = string(p-file-num)
        buf_cd-doc-line.to-del  = (not p-del)
        buf_cd-doc-line.to-send  = p-del
        buf_cd-doc-line.line-num = v-line-num
        .
      end.
    end.
    if p-mode = 'ДОБАВЛЕНИЕ':U
    or buf_cd-plu.b-code  = 0 then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Блюдо меню/модификатор на кассе R-KEEPER с id &1 код в меню &2 <&3> - не сопоставлен товар в системе IBS TH"
                                , p-sifr
                                , p-code-chr
                                , p-name
                              )
                                              ).
      assign
      p-view-log = yes
      .
    end.
    if buf_cd-plu.b-code > 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_cd-plu.b-code
  ,input  ?
  ,output v-b-code
  )  .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ,output v-vat-pc
  ,output v-slt-pc
  )  .
    end.
    lll = lll + 1 .
    ll-loc = ll-loc + 1.
    release buf_cd-plu no-error .
    if error-status:error then undo _main, return error return-value .
    release buf_cd-doc-line no-error .
    if error-status:error then undo _main, return error return-value .
  end.
end procedure.
procedure update-country :
define input parameter p-mode as character no-undo .
define input parameter p-update-name as logical no-undo .
define input parameter p-update-parent as logical no-undo .
define input parameter p-sifr as integer no-undo .
define input parameter p-name  as character no-undo .
define input parameter p-parent as integer no-undo .
define input parameter p-del   as logical no-undo .
define input parameter p-lvl-num as integer no-undo .
define buffer buf_cd-grp for ub.cd-grp.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
  _main:
  do
  on error undo, return error return-value
  :
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      create buf_cd-grp.
      assign
      buf_cd-grp.obj-type = p-obj-type
      buf_cd-grp.obj-code = p-obj-code
      buf_cd-grp.pos-type = 'r-keeper':U
      buf_cd-grp.grp-type = '':U
      .
    end.
    else do:
      find first buf_cd-grp exclusive-lock where
                buf_cd-grp.obj-type = p-obj-type
            and buf_cd-grp.obj-code = p-obj-code
            and buf_cd-grp.pos-type = 'r-keeper':U
            and buf_cd-grp.grp-type = '':U
            and buf_cd-grp.grp-code = p-sifr no-error.
      if not available buf_cd-grp then do:
        return error substitute("не найдена или занята запись группы для кассы R-KEEPER с id &1"
                              ,p-sifr
                              ).
      end.
    end.
    assign
    buf_cd-grp.grp-code = p-sifr
    buf_cd-grp.upper-grp-code = p-parent
    buf_cd-grp.grp-name = p-name
    buf_cd-grp.to-del = not p-del
    buf_cd-grp.to-send = p-del
    buf_cd-grp.logkey_one = p-update-name
    buf_cd-grp.logkey_two = p-update-parent
    buf_cd-grp.key#_one = p-lvl-num
    .
    lll = lll + 1 .
    ll-loc = ll-loc + 1.
    if p-mode = 'ДОБАВЛЕНИЕ':U
    or not can-find(first buf_fbr-gds-grp no-lock where
                         buf_fbr-gds-grp.obj-type = p-obj-type
                     AND buf_fbr-gds-grp.obj-code = p-obj-code
                     AND buf_fbr-gds-grp.out-code = p-sifr ) then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Группа блюд меню кассе R-KEEPER с id &1 <&2> - не сопоставлена группа блюд на &3&4 в системе IBS TH"
                                , p-sifr
                                , p-name
                                , p-obj-type
                                , p-obj-code
                              )    ).
      assign
      p-view-log = yes
      .
    end.
    release buf_cd-grp no-error .
    if error-status:error then undo _main, return error return-value .
 end.
end procedure.
procedure update-clients :
define input parameter p-mode as character no-undo .
define input parameter p-sifr as integer no-undo .
define input parameter p-name  as character no-undo .
define input parameter p-type  as character no-undo .
define input parameter p-del   as logical no-undo .
define buffer buf_cd-clu        for ub.cd-clu.
  _main:
  do
  on error undo, return error return-value
  :
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      create buf_cd-clu.
      assign
      buf_cd-clu.obj-type = p-obj-type
      buf_cd-clu.obj-code = p-obj-code
      buf_cd-clu.pos-type = 'r-keeper':U
      buf_cd-clu.clu-type = p-type
      buf_cd-clu.clu-code = p-sifr
      .
    end.
    else do:
      find first buf_cd-clu exclusive-lock where
                buf_cd-clu.obj-type = p-obj-type
            and buf_cd-clu.obj-code = p-obj-code
            and buf_cd-clu.pos-type = 'r-keeper':U
            and buf_cd-clu.clu-type = p-type
            and buf_cd-clu.clu-code = p-sifr no-error.
      if not available buf_cd-clu then do:
        return error substitute("не найдена или занята запись персонала с id = &1 для кассы R-KEEPER "
                              ,p-sifr).
      end.
    end.
    assign
    buf_cd-clu.cli-type = 'чел':U
    buf_cd-clu.charkey_one = p-name
    buf_cd-clu.to-send = (p-del = yes)
    buf_cd-clu.to-del = (p-del = no)
    .
    if buf_cd-clu.cli-code = ? then do:
      run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!на кассе R-KEEPER &3 с id &1 <&2> - не сопоставлен сотрудник в системе IBS TH"
                                , p-sifr
                                , p-name
                                , entry(lookup(p-type, "W,M,K,B":U), "Официант,Менеджер,Кассир,Бармен")
                              )    ).
      assign
      p-view-log = yes
      .
    end.
    lll = lll + 1 .
    ll-loc = ll-loc + 1.
    release buf_cd-clu no-error .
    if error-status:error then undo _main, return error return-value .
 end.
end procedure.
procedure get-checks :
define variable v-create-write-off as logical no-undo .
define variable v-create-return as logical no-undo .
define variable v-gds-create-write-off as logical no-undo .
define variable v-gds-create-return as logical no-undo .
define variable chk-type2 as integer no-undo .
define variable chk-sign as integer no-undo .
define variable chk-sign2 as integer no-undo .
define variable gds-sign as integer no-undo .
define variable gds-sign2 as integer no-undo .
define variable gds-wo-type as integer no-undo .
define variable gds-wo-type2 as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable prev-code2 as character no-undo .
define buffer buf_cd-plu for ub.cd-plu.
  do
  on error undo, return error
  :
    for each temp-acheck no-lock,
        each temp-avcheck where
            temp-avcheck.unit = temp-acheck.unit
        AND temp-avcheck.depart = temp-acheck.depart
        AND temp-avcheck.logicdate = temp-acheck.logicdate
          and temp-avcheck.del-time >= temp-acheck.start-time
          AND temp-avcheck.del-time <= temp-acheck.end-time
          AND temp-avcheck.sys_num = 0 :
      assign
      temp-avcheck.sys_num = temp-acheck.sys_num.
    end.
     _temp-acheck:
    for each temp-acheck no-lock:
      assign
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
      for-chk-type = ""
      prev-code = "":U
      prev-code2 = "":U
      v-create-write-off = no
      v-create-return = no
      .
      assign
      shop-code = ( if get-chkc_context.hnum
                    then integer(temp-acheck.depart)
                    else p-obj-code )
      shop-type = ( if get-chkc_context.hnum then 'маг':U else p-obj-type )
      no-error
      .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Для чека &1 неверный(нецифровой) номер магазина &2" +
                                  "чек не будет сохранен и обработан"
                                  , temp-acheck.cnum
                                  , temp-acheck.depart
                                  , chr(10)
                                )    ).
        assign
        p-view-log = yes
        .
        run save-for-future in this-procedure .
        next _temp-acheck.
      end.
      assign
      pay-desk_ =  integer(temp-acheck.unit)
      no-error
      .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Для чека &1 неверный(нецифровой) номер кассы &2" +
                                  "чек не будет сохранен и обработан"
                                  , temp-acheck.cnum
                                  , temp-acheck.unit
                                  , chr(10)
                                )    ).
        assign
        p-view-log = yes
        .
        run save-for-future in this-procedure .
        next _temp-acheck.
      end.
      if temp-achecK.deleted  <> 0 then do:
        find first temp-reasons no-lock where
                  temp-reasons.sifr = temp-acheck.deleted no-error.
        if not available temp-reasons then do:
          run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Для чека &1 кассы &2 не найдена причина отмены с идентификатором &3&4" +
                                    "чек не будет сохранен и обработан"
                                    , temp-acheck.cnum
                                    , temp-acheck.unit
                                    , temp-acheck.deleted
                                    , chr(10)
                                  )    ).
          assign
          p-view-log = yes
          .
          run save-for-future in this-procedure .
          next _temp-acheck.
        end.
        if temp-reasons.used then do:
          assign
          chk-type_ = integer('1':U)
          chk-sign  = 1
          v-create-write-off = yes
          chk-type2 = integer('96':U)
          chk-sign2  = - 1
          .
        end.
        else do:
          assign
          chk-type_ = integer('1':U)
          chk-sign  = 1
          v-create-return = yes
          chk-type2 = integer('6':U)
          chk-sign2  = - 1
          .
        end.
      end.
      else do:
        assign
        chk-type_ = integer('1':U)
        chk-sign  = 1
        .
      end.
      assign
      sales-man_ = get-sales-man(temp-acheck.waiter, chk-date_)
      cashier_  = get-cashier(temp-acheck.cashier, chk-date_)
      no-error .
      _do:
      do ii = 1 to 2:
        FIND  ub.chk-doc where
              ub.chk-doc.obj-type = shop-type and
              ub.chk-doc.obj-code = shop-code and
              ub.chk-doc.chk-date = temp-acheck.realdate and
              ub.chk-doc.pay-desk = integer(temp-acheck.unit) and
              ub.chk-doc.chk-time = integer(entry(1, temp-acheck.closetime, ":":U)) * 3600 + integer (entry(2, temp-acheck.closetime, ":":U)) * 60 and
              ub.chk-doc.chk-num = temp-acheck.cnum and
              ub.chk-doc.sales-man = sales-man_
              NO-ERROR NO-WAIT.
        if (avail ub.chk-doc and ub.chk-doc.chk-type = (if ii = 1 then chk-type_ else chk-type2))
        or locked ub.chk-doc then do:
          if not v-create-return and not v-create-write-off then leave _do.
          else next _do.
        end.
        if ambiguous ub.chk-doc then do:
          FIND  ub.chk-doc where
                ub.chk-doc.obj-type = shop-type and
                ub.chk-doc.obj-code = shop-code and
                ub.chk-doc.chk-date = temp-acheck.realdate and
                ub.chk-doc.pay-desk = integer(temp-acheck.unit) and
                ub.chk-doc.chk-time = integer(entry(1, temp-acheck.closetime, ":":U)) * 3600 + integer (entry(2, temp-acheck.closetime, ":":U)) * 60 and
                ub.chk-doc.chk-num = temp-acheck.cnum and
                ub.chk-doc.sales-man = sales-man_ and
                ub.chk-doc.chk-type = (if ii = 1 then chk-type_ else chk-type2)
                NO-ERROR NO-WAIT.
          if (avail ub.chk-doc and ub.chk-doc.chk-type = (if ii = 1 then chk-type_ else chk-type2))
          or locked ub.chk-doc
          or ambiguous ub.chk-doc then do:
            if not v-create-return and not v-create-write-off then leave _do.
            else next _do.
          end.
        end.
        assign
        exist = no
        cr = 0
        lll = lll + 1
        .
        create ub.chk-doc.
        assign
        lng = 0
        lnp = 0
        sub-d = 0
        var-discnt-id = 0
        lng-sub-d = 0
        netto-for-sub-d = 0
        ub.chk-doc.obj-code = shop-code
        ub.chk-doc.obj-type = shop-type
        ub.chk-doc.office = ?
        ub.chk-doc.doc-code = (if get-chkc_context.db-num = 0
                              then string(next-value(s-chk, ub ))
                              else string( shop-code ) + chr(47) + string( next-value( s-chk, ub ) ))
        ub.chk-doc.chk-num = temp-acheck.cnum
        ub.chk-doc.chk-date = temp-acheck.realdate
        ub.chk-doc.chk-time = integer(entry(1, temp-acheck.closetime, ":":U)) * 3600 + integer (entry(2, temp-acheck.closetime, ":":U)) * 60
        ub.chk-doc.pay-desk = pay-desk_
        ub.chk-doc.sales-man = sales-man_
        ub.chk-doc.cashier = cashier_
        ub.chk-doc.discnt = 0
        ub.chk-doc.src-d-card = "":U
        ub.chk-doc.src-d-pcnt = 0
        ub.chk-doc.src-shift-date = temp-acheck.logicdate
        ub.chk-doc.shift-num = 0
        ub.chk-doc.shift-name = '':U
        ub.chk-doc.src-shift-name = '':U
        ub.chk-doc.cash-rate = temp-acheck.basekurs
        ub.chk-doc.cash-scale = 1
        ub.chk-doc.z-number = 0
        ub.chk-doc.doc-num = "Стол-" + string(temp-acheck.table_) + chr(32) + "Персон-" + string(temp-acheck.cover)
        ub.chk-doc.chk-type = (if ii = 1 then chk-type_ else chk-type2)
        ub.chk-doc.correct = yes
        brutto-sum_ = (if ii = 1 then chk-sign else chk-sign2) * temp-acheck.total
        no-error
        .
        if error-status:error then do:
          ub.chk-doc.correct = no.
        end.
        if ii = 1
        then
        prev-code = ub.chk-doc.doc-code.
        if ii = 2
        then
        prev-code2 = ub.chk-doc.doc-code.
        for each temp-archeck no-lock where
                temp-archeck.sys_num = temp-acheck.sys_num:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-gds-create-write-off = no
v-gds-create-return = no
gds-sign = 1
gds-wo-type = chk-type_
.
find first buf_cd-plu no-lock where
          buf_cd-plu.obj-type = p-obj-type
      and buf_cd-plu.obj-code = p-obj-code
      and buf_cd-plu.pos-type = 'r-keeper':U
      and buf_cd-plu.plu-type = (if temp-archeck.component then 'modifier':U else '':U)
      and buf_cd-plu.plu-code = ( temp-archeck.sifr) no-error.
if available buf_cd-plu then do:
  if buf_cd-plu.b-code > 0 then do:
    assign
    bc-buf = string(buf_cd-plu.b-code)
    .
  end.
  else do:
    run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Для строки чека &1 кассы &2 блюдo/модификатор с идентификатором &3&4" +
                              "не привязано к товару в IBS TH&4" +
                              "чек не будет сохранен и обработан"
                              , temp-acheck.cnum
                              , temp-acheck.unit
                              , temp-archeck.sifr
                              , chr(10)
                            )    ).
    assign
    p-view-log = yes
    .
    run save-for-future in this-procedure .
    undo  _temp-acheck, next _temp-acheck.
  end.
end.
else do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Для строки чека &1 кассы &2 не найдено блюдo с идентификатором &3&4" +
                            "чек не будет сохранен и обработан"
                            , temp-acheck.cnum
                            , temp-acheck.unit
                            , temp-archeck.sifr
                            , chr(10)
                          )    ).
  assign
  p-view-log = yes
  .
  run save-for-future in this-procedure .
  undo  _temp-acheck, next _temp-acheck.
end.
_do-gds:
do jj = 1 to 2:
  CREATE ub.chk-gds.
  assign
  lng = lng + 1
  ub.chk-gds.doc-code = chk-doc.doc-code
  ub.chk-gds.line-num = lng
  ub.chk-gds.grp-code = 0
  ub.chk-gds.chk-date = chk-doc.chk-date
  ub.chk-gds.b-code = 0
  ub.chk-gds.src-code  = bc-buf
  ub.chk-gds.src-price = temp-archeck.price
  ub.chk-gds.src-sum   = temp-archeck.price * temp-archeck.qnt
  ub.chk-gds.src-qnty = (if jj = 1 then gds-sign else gds-sign2) * (if ii = 1 then chk-sign else chk-sign2) * temp-archeck.qnt
  ub.chk-gds.doc-qnty = (if jj = 1 then gds-sign else gds-sign2) * (if ii = 1 then chk-sign else chk-sign2) * temp-archeck.qnt
  ub.chk-gds.price-service = 0
  ub.chk-gds.time-oper = chk-doc.chk-time
  ub.chk-gds.src-discnt = 0
  ub.chk-gds.pass-gds = ?
  ub.chk-gds.is-error = no
  ub.chk-gds.pump = 0
  ub.chk-gds.road-tax = 0
  ub.chk-gds.depart-id = p-obj-code
  ub.chk-gds.write-off-code = if v-create-write-off and ii = 2
                           then (if not temp-archeck.component
                                 then integer('-9':U)
                                 else integer('-4':U)
                                 )
                           else  (if not temp-archeck.component
                                 then 0
                                 else (if chk-doc.chk-type =  integer('1':U)
                                       then  integer('2':U)
                                       else  integer('-2':U)
                                      )
                                 )
  ub.chk-gds.sales-man = chk-doc.sales-man
  ub.chk-gds.line-sign = (if chk-doc.chk-type = integer('1':U)
                      then (chk-gds.src-qnty >= 0)
                      else (chk-gds.src-qnty <= 0)
                      )
  ub.chk-gds.line-type = '':U
  netto-for-sub-d = netto-for-sub-d +
  (if ub.chk-gds.write-off-code = ?
  or ub.chk-gds.write-off-code <= 0
  then
  ((chk-gds.src-price - ub.chk-gds.src-discnt) * (if jj = 1 then gds-sign else gds-sign2) * (if ii = 1 then chk-sign else chk-sign2) * ub.chk-gds.src-qnty)
  else 0)
  .
  if not v-gds-create-return then leave _do-gds.
end.
        end.
        for each temp-avcheck where
                temp-avcheck.sys_num = temp-acheck.sys_num:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-gds-create-write-off = no
v-gds-create-return = no
gds-sign = 1
gds-wo-type = chk-type_
.
find first buf_cd-plu no-lock where
          buf_cd-plu.obj-type = p-obj-type
      and buf_cd-plu.obj-code = p-obj-code
      and buf_cd-plu.pos-type = 'r-keeper':U
      and buf_cd-plu.plu-type = '':U
      and buf_cd-plu.plu-code = ((if temp-avcheck.comp > 0 then - 1 else 1 ) * temp-avcheck.sifr) no-error.
if available buf_cd-plu then do:
  if buf_cd-plu.b-code > 0 then do:
    assign
    bc-buf = string(buf_cd-plu.b-code)
    .
  end.
  else do:
    run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Для строки чека &1 кассы &2 блюдo/модификатор с идентификатором &3&4" +
                              "не привязано к товару в IBS TH&4" +
                              "чек не будет сохранен и обработан"
                              , temp-acheck.cnum
                              , temp-acheck.unit
                              , temp-avcheck.sifr
                              , chr(10)
                            )    ).
    assign
    p-view-log = yes
    .
    run save-for-future in this-procedure .
    undo  _temp-acheck, next _temp-acheck.
  end.
end.
else do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Для строки чека &1 кассы &2 не найдено блюдo с идентификатором &3&4" +
                            "чек не будет сохранен и обработан"
                            , temp-acheck.cnum
                            , temp-acheck.unit
                            , temp-avcheck.sifr
                            , chr(10)
                          )    ).
  assign
  p-view-log = yes
  .
  run save-for-future in this-procedure .
  undo  _temp-acheck, next _temp-acheck.
end.
find first temp-reasons no-lock where
          temp-reasons.sifr = temp-avcheck.reason no-error.
if not available temp-reasons then do:
  run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Для удаленной строки (товар с идентификатором & 5) чека &1 кассы &2 не найдена причина отмены с идентификатором &3&4" +
                            "чек не будет сохранен и обработан"
                            , temp-acheck.cnum
                            , temp-acheck.unit
                            , temp-acheck.deleted
                            , temp-avcheck.sifr
                            , chr(10)
                          )    ).
  assign
  p-view-log = yes
  .
  run save-for-future in this-procedure .
  undo _temp-acheck, next _temp-acheck.
end.
if temp-reasons.used then do:
  assign
  v-gds-create-write-off = yes
  gds-wo-type2 = integer('96':U)
  gds-sign2  = - 1
  .
end.
else do:
  assign
  v-gds-create-return = yes
  gds-wo-type2 = integer('6':U)
  gds-sign2  = - 1
  .
end.
_do-gds:
do jj = 1 to 2:
  CREATE ub.chk-gds.
  assign
  lng = lng + 1
  ub.chk-gds.doc-code = chk-doc.doc-code
  ub.chk-gds.line-num = lng
  ub.chk-gds.grp-code = 0
  ub.chk-gds.chk-date = chk-doc.chk-date
  ub.chk-gds.b-code = 0
  ub.chk-gds.src-code  = bc-buf
  ub.chk-gds.src-price = temp-avcheck.price
  ub.chk-gds.src-sum   = temp-avcheck.price * temp-avcheck.qnt
  ub.chk-gds.src-qnty = (if jj = 1 then gds-sign else gds-sign2) * (if ii = 1 then chk-sign else chk-sign2) * temp-avcheck.qnt
  ub.chk-gds.doc-qnty = (if jj = 1 then gds-sign else gds-sign2) * (if ii = 1 then chk-sign else chk-sign2) * temp-avcheck.qnt
  ub.chk-gds.price-service = 0
  ub.chk-gds.time-oper = (temp-avcheck.del-time - integer(temp-avcheck.realdate) ) * 10000
  ub.chk-gds.src-discnt = 0
  ub.chk-gds.pass-gds = ?
  ub.chk-gds.is-error = no
  ub.chk-gds.pump = 0
  ub.chk-gds.road-tax = 0
  ub.chk-gds.depart-id = p-obj-code
  ub.chk-gds.write-off-code = if v-gds-create-write-off
                           then (if temp-avcheck.comp = 0
                                 then  integer('1':U)
                                 else (if chk-doc.chk-type =  integer('1':U)
                                       then  integer('3':U)
                                       else  integer('-3':U)
                                      )
                                 )
                           else (if temp-avcheck.comp = 0
                                 then 0
                                 else (if chk-doc.chk-type =  integer('1':U)
                                       then  integer('2':U)
                                       else  integer('-2':U)
                                      )
                                )
  ub.chk-gds.sales-man = chk-doc.sales-man
  ub.chk-gds.line-sign = (if chk-doc.chk-type = integer('1':U)
                      then (chk-gds.src-qnty >= 0)
                      else (chk-gds.src-qnty <= 0)
                      )
  ub.chk-gds.line-type = '':U
  netto-for-sub-d = netto-for-sub-d +
  (if ub.chk-gds.write-off-code = ?
  or ub.chk-gds.write-off-code <= 0
  then
  ((chk-gds.src-price - ub.chk-gds.src-discnt) * (if jj = 1 then gds-sign else gds-sign2) * (if ii = 1 then chk-sign else chk-sign2) * ub.chk-gds.src-qnty)
  else 0)
  .
  if not v-gds-create-return then leave _do-gds.
end.
        end.
        for each temp-adcheck no-lock where
            temp-adcheck.sys_num = temp-acheck.sys_num:
          find first tt-dis-rule-r-keeper no-lock where
                    tt-dis-rule-r-keeper.r-keeper-rule-num = temp-adcheck.sifr no-error.
          if not available tt-dis-rule-r-keeper then  do:
            run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "!!!Для чека &1 кассы &2 не найдено соответствующее правило скидки для скидки с идентификатором &3&4" +
                                      "чек не будет сохранен и обработан"
                                      , temp-acheck.cnum
                                      , temp-acheck.unit
                                      , temp-adcheck.sifr
                                      , chr(10)
                                    )    ).
            assign
            p-view-log = yes
            .
            run save-for-future in this-procedure .
            undo _temp-acheck,  next _temp-acheck.
          end.
          if tt-dis-rule-r-keeper.discnt-type = integer('2':U)
          or tt-dis-rule-r-keeper.discnt-type = integer('3':U)
          or tt-dis-rule-r-keeper.discnt-type = integer('4':U)
          or tt-dis-rule-r-keeper.discnt-type = integer('5':U) then do:
            sub-d = sub-d + (if ii = 1 then chk-sign else chk-sign2) * (- temp-adcheck.sum).
          end.
          create ub.chk-discnt.
          assign
          ub.chk-discnt.doc-code = ub.chk-doc.doc-code
          ub.chk-discnt.record-type = 0
          ub.chk-discnt.discnt-id = (var-discnt-id + 1)
          ub.chk-discnt.line-num = lng
          ub.chk-discnt.time-oper = ub.chk-doc.chk-time
          ub.chk-discnt.line-type = tt-dis-rule-r-keeper.subject-type
          ub.chk-discnt.line-sign =  (if temp-adcheck.sum <= 0 then  yes else no)
          ub.chk-discnt.pass-discnt = if temp-adcheck.person = 0 then integer('0':U) else integer('1':U)
          ub.chk-discnt.value-type = tt-dis-rule-r-keeper.value-type
          ub.chk-discnt.discnt-type = tt-dis-rule-r-keeper.discnt-type
          ub.chk-discnt.src-d-card = string(temp-adcheck.CARDCOD)
          ub.chk-discnt.d-card = "":U
          ub.chk-doc.src-d-card = (if temp-adcheck.cardcod <> 0 then string(temp-adcheck.CARDCOD) else ub.chk-doc.src-d-card)
          ub.chk-discnt.discnt-value-abs = (if ii = 1 then chk-sign else chk-sign2) * - temp-adcheck.sum
          ub.chk-discnt.object-qnty = (if ii = 1 then chk-sign else chk-sign2) * ub.chk-doc.doc-qnty
          ub.chk-discnt.object-sum = (if ii = 1 then chk-sign else chk-sign2) * netto-for-sub-d
          ub.chk-discnt.discnt-value-pcnt = (if ub.chk-discnt.object-sum = 0 then 0 else (if ii = 1 then chk-sign else chk-sign2) * (- temp-adcheck.sum)  / ub.chk-discnt.object-sum  * 100)
          ub.chk-discnt.object-line-num = 0
          ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
          ub.chk-discnt.obj-code = ub.chk-doc.obj-code
          ub.chk-discnt.obj-type = ub.chk-doc.obj-type
          ub.chk-discnt.chk-date = ub.chk-doc.chk-date
          ub.chk-discnt.chk-time = ub.chk-doc.chk-time
          var-discnt-id = var-discnt-id + 1
          netto-for-sub-d = netto-for-sub-d - (- temp-adcheck.sum)
          .
        END.
        for each temp-apcheck no-lock where
                temp-apcheck.sys_num = temp-acheck.sys_num:
          assign
          curr_code = 0
          pay_code = convert-cash-pay ( input temp-apcheck.currency, output curr_code)
          .
          CREATE ub.chk-pay .
          assign
          lnp = lnp + 1
          ub.chk-pay.doc-code = ub.chk-doc.doc-code
          ub.chk-pay.line-num = lnp
          ub.chk-pay.chk-date = ub.chk-doc.chk-date
          ub.chk-pay.obj-type = ub.chk-doc.obj-type
          ub.chk-pay.obj-code = ub.chk-doc.obj-code
          ub.chk-pay.tot-rubl = 0
          ub.chk-pay.tot-sum = (if ii = 1 then chk-sign else chk-sign2) * temp-apcheck.origsum
          ub.chk-pay.tot-base = 0
          ub.chk-pay.pay-code = pay_code
          ub.chk-pay.curr-code = curr_code
          ub.chk-pay.time-oper = ub.chk-doc.chk-time
          ub.chk-pay.cash-rate = temp-apcheck.kurs
          ub.chk-pay.line-type = "":U
          ub.chk-pay.line-sign = (if ub.chk-doc.chk-type = integer('1':U)
                              then (chk-pay.tot-sum >= 0)
                              else (chk-pay.tot-sum <= 0)
                              )
          ub.chk-pay.is-error = no
          .
          if temp-apcheck.discount <> 0 then do:
            create ub.chk-discnt.
            assign
            ub.chk-discnt.doc-code = ub.chk-doc.doc-code
            ub.chk-discnt.record-type = 0
            ub.chk-discnt.discnt-id = (var-discnt-id + 1)
            ub.chk-discnt.line-num = lng
            ub.chk-discnt.time-oper = ub.chk-doc.chk-time
            ub.chk-discnt.line-type = integer('5':U)
            ub.chk-discnt.pass-discnt = integer('0':U)
            ub.chk-discnt.value-type = integer('1':U)
            ub.chk-discnt.discnt-type = integer('0':U)
            ub.chk-discnt.src-d-card = chk-gds.src-d-card
            ub.chk-discnt.d-card = chk-gds.d-card
            ub.chk-discnt.discnt-value-pcnt = temp-apcheck.discount  * 100
            ub.chk-discnt.discnt-value-abs = (if ii = 1 then chk-sign else chk-sign2) * (temp-apcheck.basesumeqw  * temp-apcheck.discount) / (1 - temp-apcheck.discount)
            ub.chk-discnt.line-sign =  (if temp-apcheck.discount >= 0 then  yes else no)
            ub.chk-discnt.object-qnty = (if ii = 1 then chk-sign else chk-sign2) * ub.chk-doc.doc-qnty
            ub.chk-discnt.object-sum = (if ii = 1 then chk-sign else chk-sign2) * netto-for-sub-d
            ub.chk-discnt.object-line-num = 0
            ub.chk-discnt.pay-desk = ub.chk-doc.pay-desk
            ub.chk-discnt.obj-code = ub.chk-doc.obj-code
            ub.chk-discnt.obj-type = ub.chk-doc.obj-type
            ub.chk-discnt.chk-date = ub.chk-doc.chk-date
            ub.chk-discnt.chk-time = ub.chk-doc.chk-time
            var-discnt-id = var-discnt-id + 1
            sub-d = sub-d + (if ii = 1 then chk-sign else chk-sign2) * ub.chk-discnt.discnt-value-abs
            netto-for-sub-d = netto-for-sub-d - (if ii = 1 then chk-sign else chk-sign2) * ub.chk-discnt.discnt-value-abs
            ub.chk-pay.tot-sum = ub.chk-pay.tot-sum - ub.chk-discnt.discnt-value-abs
            .
          end.
        end.
        if ii = 1 then do:
          get-chkc_context.ll = lll.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
          p-view-log = (p-view-log or get-chkc_context.view-log)
          lll = get-chkc_context.ll
          .
        end.
        if not v-create-return and not v-create-write-off then leave _do.
        if ii = 2 then do:
          get-chkc_context.ll = lll.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  ,input-output prev-code2
    ) no-error .
          assign
          p-view-log = (p-view-log or get-chkc_context.view-log)
          lll = get-chkc_context.ll
          .
        end.
      end.
     end.
  end.
end procedure.
procedure save-for-future :
  do
  on error undo, return error
  :
    assign
    v-session-status_ = "U".
  end.
end procedure.
