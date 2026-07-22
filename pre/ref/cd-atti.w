DEFINE TEMP-TABLE Temp-hattr NO-UNDO LIKE ub.cash-desk-attr
       field user-can-edit as log
       field code as character
       field value_ as character
       field to-send as logical
       iNDEX pi is unique primary
       db-num
       obj-code
       pos-type
       cash-num
       upper-attr-code
       code
       INDEX attrc
       attr-code
       db-num
       INDEX ichar
       upper-attr-code
       attr-code
       attr-value-character
       iNDEX idate
       upper-attr-code
       attr-code
       attr-value-date
       INDEX idec
       upper-attr-code
       attr-code
       attr-value-decimal
       INDEX iint
       upper-attr-code
       attr-code
       attr-value-integer
       INDEX ilog
       upper-attr-code
       attr-code
       attr-value-logical
       INDEX iuattr
       upper-attr-code
       db-num
       index itype
       attr-value-type.
define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode as char no-undo.
define input parameter p-ref-mode as character no-undo .
define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo.
define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo.
define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input parameter p-glog   as LOGICAL no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Атрибуты и/или параметры кассы".
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
procedure cd-attr-spr-tara-ref :
define input parameter parparentproc as widget-handle no-undo .
define input  parameter p-db-num      like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code    like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type    like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num    like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-character as character no-undo .
define input-output parameter p-date      as date      no-undo .
define input-output parameter p-decimal   as decimal   no-undo .
define input-output parameter p-integer   as integer   no-undo .
define input-output parameter p-logical   as logical   no-undo .
define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-spr-tara-ref in g#attr-lib
      (input  parparentproc
      ,input  p-db-num
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
procedure cd-attr-di-tara-ref :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-db-num     like ub.cash-desk-attr.db-num no-undo .
define input parameter p-obj-code   like ub.cash-desk-attr.obj-code no-undo .
define input parameter p-pos-type   like ub.cash-desk-attr.pos-type no-undo .
define input parameter p-cash-num   like ub.cash-desk-attr.cash-num no-undo .
define input parameter p-upper-attr-code  like ub.cash-desk-attr.upper-attr-code no-undo .
define input parameter p-attr-code  like ub.cash-desk-attr.attr-code no-undo .
define input parameter p-character as character no-undo .
define input parameter p-date      as date      no-undo .
define input parameter p-decimal   as decimal   no-undo .
define input parameter p-integer   as integer   no-undo .
define input parameter p-logical   as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-di-tara-ref in g#attr-lib
      (input parparentproc
      ,input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-upper-attr-code
      ,input p-attr-code
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-attr-property  no-undo
field upper-attr-code as character
field attr-code as character
field table-name as character
field edit-menu-section-num as integer
field attr-label as character
field menu-item-handle as widget-handle
field user-can-edit as logical
field menu-name as character
field parent-handle as handle
index pi is unique primary
table-name
menu-name
upper-attr-code
attr-code
index i-section
edit-menu-section-num
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure attr-pop-create-items :
define input parameter p-table-name as character no-undo .
define input parameter p-get-section-num-proc-name as character no-undo .
define input parameter p-get-attr-label-proc-name as character no-undo .
define input parameter p-attr-choose-proc-name as character no-undo .
define input parameter p-menu-handle as widget-handle no-undo .
define input parameter p-upper-attr-code as character no-undo .
define input parameter p-attr-list as character no-undo .
define variable ii as integer no-undo .
define variable V-CREATED as logical no-undo .
define variable v-tool-tip as character no-undo .
define variable v-dop as character no-undo .
define variable v-attr-item as character no-undo .
define buffer buf_tt-attr-property for tt-attr-property.
  do
  on error undo, return error return-value
  :
     do ii = 1 to num-entries (p-attr-list):
       v-attr-item = entry(ii, p-attr-list) .
       find first tt-attr-property where
                 tt-attr-property.table-name = p-table-name
             and tt-attr-property.attr-code = v-attr-item
             and tt-attr-property.upper-attr-code = p-upper-attr-code
             and tt-attr-property.menu-name = p-menu-handle:name  no-error .
       if not available tt-attr-property then do:
         create tt-attr-property.
         assign
         tt-attr-property.table-name = p-table-name
         tt-attr-property.attr-code = v-attr-item
         tt-attr-property.upper-attr-code = p-upper-attr-code
         tt-attr-property.menu-name = p-menu-handle:name
         .
         run value ( p-get-section-num-proc-name) (
                                                   input p-upper-attr-code,
                                                   input tt-attr-property.attr-code
                                                  ,output tt-attr-property.edit-menu-section-num ) no-error .
         run value ( p-get-attr-label-proc-name ) (
                                        input p-upper-attr-code,
                                        input tt-attr-property.attr-code
                                       ,output v-tool-tip
                                       ,output tt-attr-property.attr-label
                                      ) no-error .
         release tt-attr-property.
       end.
     end.
     for each tt-attr-property where tt-attr-property.menu-name = p-menu-handle:name
     break
     by  tt-attr-property.edit-menu-section-num
     by  tt-attr-property.attr-label
     :
       if tt-attr-property.edit-menu-section-num > 0
       then do:
          if not valid-handle(tt-attr-property.menu-item-handle) then do:
            if num-entries(tt-attr-property.attr-code, chr(4)) > 1
            and entry(2, tt-attr-property.attr-code, chr(4)) <> '':U
            then do:
              find first buf_tt-attr-property where
                        buf_tt-attr-property.table-name = p-table-name
                    and buf_tt-attr-property.menu-name = p-menu-handle:name
                    and buf_tt-attr-property.upper-attr-code = p-upper-attr-code
                    and buf_tt-attr-property.attr-code = entry(1, tt-attr-property.attr-code, chr(4)) no-error .
              if not available buf_tt-attr-property then do:
                create buf_tt-attr-property.
                assign
                buf_tt-attr-property.table-name = p-table-name
                buf_tt-attr-property.attr-code = entry(1, tt-attr-property.attr-code, chr(4))
                buf_tt-attr-property.upper-attr-code = p-upper-attr-code
                buf_tt-attr-property.menu-name = p-menu-handle:name
                .
                create sub-menu buf_tt-attr-property.menu-item-handle
                assign
                name = entry(1, tt-attr-property.attr-code, chr(4))  + chr(4)  + p-menu-handle:name
                parent = p-menu-handle.
              end.
              create menu-item tt-attr-property.menu-item-handle
              assign
              label = tt-attr-property.attr-label
              name = tt-attr-property.attr-code  + chr(4)  + p-menu-handle:name
              parent = buf_tt-attr-property.menu-item-handle
              triggers:
                on choose
                  persistent run value(p-attr-choose-proc-name + "-2") (
                                                                        input tt-attr-property.upper-attr-code,
                                                                         input  entry(1, tt-attr-property.attr-code, chr(4) )
                                                                        ,input entry(2, tt-attr-property.attr-code, chr(4) )
                                                                          ) .
              end triggers.
              assign
              v-created = yes.
            end.
            else do:
              create menu-item tt-attr-property.menu-item-handle
              assign
              label = tt-attr-property.attr-label
              name = entry(1, tt-attr-property.attr-code, chr(4)) + chr(4)  + p-menu-handle:name
              parent = p-menu-handle
              triggers:
                on choose
                  persistent run value(p-attr-choose-proc-name) (
                                                                  input tt-attr-property.upper-attr-code,
                                                                 input  entry(1, tt-attr-property.attr-code, chr(4) )) .
              end triggers.
              assign
              v-created = yes.
            end.
          end.
          if last-of(tt-attr-property.edit-menu-section-num)
            then do:
            find first buf_tt-attr-property where
                      buf_tt-attr-property.table-name = p-table-name
                 and  buf_tt-attr-property.attr-code = substitute("&1&2&3"
                                                         , p-table-name
                                                         , tt-attr-property.edit-menu-section-num
                                                         , p-menu-handle:name
                                                         )
                  and buf_tt-attr-property.menu-name = p-menu-handle:name  no-error .
            if not available buf_tt-attr-property then do:
              create buf_tt-attr-property.
              assign
              buf_tt-attr-property.table-name = p-table-name
              buf_tt-attr-property.edit-menu-section-num =  - 1
              buf_tt-attr-property.menu-name = p-menu-handle:name
              buf_tt-attr-property.upper-attr-code = ''
              buf_tt-attr-property.attr-code = substitute("&1&2&3"
                                                          , p-table-name
                                                          , tt-attr-property.edit-menu-section-num
                                                          , p-menu-handle:name
                                                          )
              .
              create menu-item buf_tt-attr-property.menu-item-handle
              assign
              subtype = "rule"
              parent = p-menu-handle
              .
            end.
          end.
       end.
     end.
     if not v-created then do:
        run attr-pop-clean-up in this-procedure ( input p-table-name).
     end.
  end.
end procedure.
procedure attr-pop-clean-up :
define input parameter p-table-name as character no-undo .
  for each tt-attr-property where
          tt-attr-property.table-name = p-table-name
    and tt-attr-property.edit-menu-section-num > 0:
    if valid-handle ( tt-attr-property.menu-item-handle) then do:
      delete widget tt-attr-property.menu-item-handle.
    end.
    delete tt-attr-property.
  end.
  for each tt-attr-property where
           tt-attr-property.table-name = p-table-name
       and tt-attr-property.edit-menu-section-num =  - 1:
    if valid-handle ( tt-attr-property.menu-item-handle) then do:
      delete widget tt-attr-property.menu-item-handle.
    end.
    delete tt-attr-property.
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable updated as logical no-undo.
DEFINE VARIABLE added  as logical no-undo .
define variable add-option as character no-undo.
define variable add-option-section as character no-undo.
define variable send-option as char no-undo.
define variable temp-doc-rec as recid no-undo.
define variable v-view-col as logical no-undo extent 6.
define buffer buf_cash-desk for ub.cash-desk.
DEFINE VARIABLE v-ch_ AS WIDGET-HANDLE NO-UNDO EXTENT 5.
define variable v-glog as logical no-undo .
define variable v-cash-desk-host-code as integer no-undo .
DEFINE MENU MENU-b-ins .
DEFINE MENU POPUP-MENU-B-send
       MENU-ITEM m_current      LABEL "Выделенный"
       MENU-ITEM m_all          LABEL "Все"           .
DEFINE VARIABLE CtrlFrame AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE chCtrlFrame AS COMPONENT-HANDLE NO-UNDO.
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 10 BY 1 TOOLTIP "Изменить атрибут/параметр кассы".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить  атрибут/параметр кассы".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-ins
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Добавить атрибут/параметр кассы".
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход ":L
     SIZE 10 BY 1 TOOLTIP "Выход из режима".
DEFINE BUTTON B-send
     LABEL "&Послать"
     SIZE 10 BY 1.
DEFINE VARIABLE cd-cash-num AS INTEGER FORMAT ">>>9":U INITIAL 0
     LABEL "№"
      VIEW-AS TEXT
     SIZE 6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE cd-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "БД"
      VIEW-AS TEXT
     SIZE 9.6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE cd-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "маг"
      VIEW-AS TEXT
     SIZE 6 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE cd-pos-type AS CHARACTER FORMAT "X(10)":U
     LABEL "Тип"
      VIEW-AS TEXT
     SIZE 16 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE QUERY br-attrs FOR
      Temp-hattr SCROLLING.
DEFINE BROWSE br-attrs
  QUERY br-attrs DISPLAY
      Temp-hattr.attr-code COLUMN-LABEL "Атрибут/Параметр" FORMAT "X(255)":U
            WIDTH 30
      Temp-hattr.attr-value-character COLUMN-LABEL "Значение!(строковое)"  FORMAT "X(255)":U
            WIDTH 35
      Temp-hattr.attr-value-date COLUMN-LABEL "Значение!(Дата)" FORMAT "99/99/9999":U
      Temp-hattr.attr-value-decimal COLUMN-LABEL "Значение!(Десятичное)" FORMAT "->>>,>>>,>>9.99":U
            WIDTH 16
      Temp-hattr.attr-value-integer COLUMN-LABEL "Значение!(Целое)" FORMAT "->>>,>>>,>>9":U
      Temp-hattr.attr-value-logical COLUMN-LABEL "Значение!(Логическое)" FORMAT "+/-":U
      to-send COLUMN-LABEL "Подлежит!пересылке" FORMAT "+/-":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.97
         FONT 4.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-ins AT ROW 1 COL 21
     b-chg AT ROW 1 COL 31
     b-lkp AT ROW 1 COL 41
     b-del AT ROW 1 COL 51
     B-send AT ROW 1 COL 61
     b-help AT ROW 1.03 COL 95
     br-attrs AT ROW 4.47 COL 1
     cd-db-num AT ROW 3.3 COL 1
     cd-obj-code AT ROW 3.3 COL 15
     cd-pos-type AT ROW 3.3 COL 33.8
     cd-cash-num AT ROW 3.3 COL 58.8
     SPACE(31.49) SKIP(19.14)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Атрибуты и/или Параметры кассы".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-send:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-B-send:HANDLE.
CREATE CONTROL-FRAME CtrlFrame ASSIGN
       FRAME           = FRAME Dialog-Frame:HANDLE
       ROW             = 1.53
       COLUMN          = 81.5
       HEIGHT          = 1.6
       WIDTH           = 5.5
       WIDGET-ID       = 2
       HIDDEN          = yes
       SENSITIVE       = yes.
      CtrlFrame:MOVE-AFTER(b-help:HANDLE IN FRAME Dialog-Frame).
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  if not avail temp-hattr then return no-apply.
  run proc-add-chg in this-procedure ( input no ) no-error.
  if error-status:error then return no-apply.
  run init-proc in this-procedure .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable loc#log as logical no-undo.
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable v-prop-list as character no-undo .
define variable glog as logical no-undo .
DEFINE VARIABLE v-check AS CHARACTER NO-UNDO.
define variable v-correct as logical no-undo .
define variable v-error-code as character no-undo .
DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  if not avail temp-hattr then return no-apply.
    if not p-glog and Temp-hattr.code = "last-check-params" then
    return no-apply .
    if not v-glog and Temp-hattr.code <> "last-check-params" then return no-apply .
  run cd-attr-code in this-procedure (
                                       input  temp-hattr.upper-attr-code
                                      ,input  temp-hattr.code
                                      ,output attr-type
                                      ,output attr-format
                                      ,output attr-label
                                      ,output attr-user-can-edit
                                      ,output attr-output-display
                                      ,output attr-other
                                      ,output v-prop-list
                                      ) .
  if not attr-user-can-edit then do:
    message
    "Атрибут/Параметр нельзя удалить вручную"
    view-as alert-box error .
    return no-apply.
  end.
     do jj = 1 to num-entries(attr-other, chr(47)):
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "check":U then do:
      assign
      v-check = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
      .
    end.
  end.
  if v-check <> "":U then do:
    run value(v-check) (
                       input p-db-num
                      ,input p-obj-code
                      ,input p-pos-type
                      ,INPUT p-cash-num
                      ,input temp-hattr.upper-attr-code
                      ,input temp-hattr.code
                      ,input "0":U
                      ,input 'удаление':U
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности удаления атрибута/параметра" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return no-apply .
    end.
    if not v-correct then do:
      message
      "Удаление атрибута/параметра некорректно" skip
      return-value
      view-as alert-box error .
      undo, return no-apply .
    end.
  end.
  glog = no.
  message
  "Вы уверены, что хотите удалить атрибут/параметр " temp-hattr.attr-code skip
  " для кассы"
  view-as alert-box QUESTIOn buttons YES-NO update glog.
  if NOT glog then return no-apply.
    run cd-attr-delete in this-procedure (
                                          input p-db-num
                                        ,input p-obj-code
                                        ,input p-pos-type
                                        ,input p-cash-num
                                        ,input temp-hattr.upper-attr-code
                                        ,input temp-hattr.code
                                        ,output loc#log) no-error .
    if error-status:error or not loc#log then do:
       message "Ошибка при удалении атрибута/параметра кассы!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
       return no-apply.
    end.
    delete temp-hattr.
    updated = yes.
    run init-proc in this-procedure .
END.
ON CHOOSE OF b-ins IN FRAME Dialog-Frame
DO:
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable loc#log as logical no-undo.
define buffer buf_temp-hattr for temp-hattr.
if add-option = "" then do:
  run gbl/pop-up.p ( input self:handle, input no) no-error.
end.
if add-option = "":U then return no-apply.
run proc-add-chg in this-procedure ( input yes) no-error .
if error-status:error then do:
  add-option = "":U.
  add-option-section = ''.
  return no-apply.
end.
run init-proc in this-procedure .
find first buf_temp-hattr no-lock where
                        buf_temp-hattr.code = add-option no-error.
add-option = "":U.
add-option-section = ''.
if avail buf_temp-hattr then
    temp-doc-rec = recid(buf_temp-hattr).
    else temp-doc-rec = ?.
reposition br-attrs to recid temp-doc-rec no-error.
if error-status:error then return no-apply.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
    if not avail temp-hattr then return no-apply.
  run proc-b-lkp IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF B-send IN FRAME Dialog-Frame
DO:
  if send-option = "" then do:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if send-option = "":U then return no-apply.
  if send-option = 'все':U then send-option = '':U.
  run proc-b-send in this-procedure ( input '', input send-option ) no-error .
  if error-status:error then do:
    send-option = "":U.
    return no-apply.
  end.
END.
PROCEDURE CtrlFrame.PSTimer.Tick .
IF p-ref-mode <> "oper"
OR p-mode <> 'ПРОСМОТР':U
THEN RETURN.
RUN init-proc IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.
ON CHOOSE OF MENU-ITEM m_all
DO:
  send-option = 'все':U.
  apply "CHOOSE" to b-send in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_current
DO:
  IF NOT AVAILABLE temp-hattr THEN RETURN NO-APPLY.
  send-option = temp-hattr.CODE.
  apply "CHOOSE" to b-send in frame Dialog-Frame.
END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-attrs :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
 frame Dialog-Frame:TITLE = frame Dialog-Frame:TITLE.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
ON ROW-DISPLAY OF br-attrs IN frame Dialog-Frame
DO:
  IF AVAIL temp-hattr THEN DO:
    RUN set-row-color IN THIS-PROCEDURE ( INPUT temp-hattr.attr-value-type).
  END.
END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  find first buf_Cash-desk where
            buf_cash-desk.obj-code =  p-obj-code
        and buf_cash-desk.db-num =  p-db-num
        AND buf_cash-desk.pos-type = p-pos-type
        AND buf_cash-desk.cash-num = p-cash-num
            no-lock no-error .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run MyEnable in this-procedure no-error.
  if error-status:error then do:
    message p-mode skip error-status:error error-status:get-message(1)
    view-as alert-box .
    return error.
  end.
  if return-value = "return" then do:
    run attr-pop-clean-up in this-procedure ( input 'cash-desk-attr':U ).
    run disable_UI in this-procedure .
    return.
  end.
  run init-proc in this-procedure .
  view frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input 'cash-desk-attr':U ).
if updated then return 'ИЗМЕНЕНИЕ':U.
PROCEDURE choose-to-edit :
define input parameter p-upper-attr-code as character no-undo .
define input parameter p-attr-code as character no-undo .
assign
add-option = p-attr-code
add-option-section = p-upper-attr-code
.
APPLY "CHOOSE" to b-ins in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE control_load :
DEFINE VARIABLE UIB_S    AS LOGICAL    NO-UNDO.
DEFINE VARIABLE OCXFile  AS CHARACTER  NO-UNDO.
OCXFile = SEARCH( "exe\wrx\ref\cd-atti.wrx":U ).
IF OCXFile = ? THEN
  OCXFile = SEARCH(SUBSTRING(THIS-PROCEDURE:FILE-NAME, 1,
                     R-INDEX(THIS-PROCEDURE:FILE-NAME, ".":U), "CHARACTER":U) + "wrx":U).
IF OCXFile <> ? THEN
DO:
  ASSIGN
    chCtrlFrame = CtrlFrame:COM-HANDLE
    UIB_S = chCtrlFrame:LoadControls( OCXFile, "CtrlFrame":U)
    CtrlFrame:NAME = "CtrlFrame":U
  .
END.
ELSE MESSAGE "exe\wrx\ref\cd-atti.wrx":U SKIP(1)
             "The binary control file could not be found. The controls cannot be loaded."
             VIEW-AS ALERT-BOX TITLE "Controls Not Loaded".
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  RUN control_load.
  DISPLAY cd-db-num cd-obj-code cd-pos-type cd-cash-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-ins b-chg b-lkp b-del B-send b-help cd-db-num cd-obj-code
         cd-pos-type cd-cash-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-attrs FOR EACH Temp-hattr NO-LOCK.
END PROCEDURE.
PROCEDURE init-proc :
define variable  attr-type as character no-undo .
define variable  attr-format as character no-undo .
define variable  attr-label as character no-undo .
define variable  attr-character as character no-undo .
define variable  attr-date as date no-undo .
define variable  attr-decimal as decimal no-undo .
define variable  attr-integer as integer no-undo .
define variable  attr-logical as logical no-undo .
define variable  attr-user-can-edit as logical no-undo .
define variable  attr-output-display as logical no-undo .
define variable  attr-other as char no-undo .
define variable v-prop-list as character no-undo .
define variable attr-from-gbd as logical no-undo .
define variable attr-from-ubd as logical no-undo .
define variable attr-news as logical no-undo .
define variable v-one-send-param as logical no-undo .
define variable v-all-send-param as logical no-undo .
define variable v-compl-root as logical no-undo .
define variable jj as integer no-undo .
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
for each  Temp-hattr share-lock:
  delete Temp-hattr.
end.
add-option = "".
add-option-section = "".
Assign
cd-db-num = buf_cash-desk.db-num
cd-obj-code = buf_cash-desk.obj-code
cd-pos-type = buf_cash-desk.pos-type
cd-cash-num = buf_cash-desk.cash-num
v-view-col[1] = no
v-view-col[2] = no
v-view-col[3] = no
v-view-col[4] = no
v-view-col[5] = no
v-view-col[6] = no
.
display
cd-db-num
cd-obj-code
cd-pos-type
cd-cash-num
with frame Dialog-Frame  .
_cash-desk-attr:
For each buf_cash-desk-attr where
        buf_cash-desk-attr.obj-code = p-obj-code
  and  buf_cash-desk-attr.db-num  = p-db-num
  and  buf_cash-desk-attr.pos-type  = p-pos-type
  and  buf_cash-desk-attr.cash-num  = p-cash-num
        no-lock :
  if buf_cash-desk-attr.upper-attr-code = '' then do:
    if p-ref-mode = "oper" then do:
      if not (buf_Cash-desk-attr.attr-code begins buf_Cash-desk-attr.pos-type + "_operative") then next.
    end.
    else do:
      if (buf_Cash-desk-attr.attr-code begins buf_Cash-desk-attr.pos-type + "_operative") then next.
    end.
  end.
  else do:
    if p-ref-mode = "oper" then do:
      if not (buf_Cash-desk-attr.upper-attr-code begins buf_Cash-desk-attr.pos-type + "_operative") then next.
    end.
    else do:
      if (buf_Cash-desk-attr.upper-attr-code begins buf_Cash-desk-attr.pos-type + "_operative") then next.
    end.
  end.
  v-compl-root = no.
  run cd-attr-code in this-procedure (
                                          input buf_cash-desk-attr.upper-attr-code
                                        , input buf_cash-desk-attr.attr-code
                                        , output attr-type
                                        , output attr-format
                                        , output attr-label
                                        , output attr-user-can-edit
                                        , output attr-output-display
                                        , output attr-other
                                        , output v-prop-list
                                        ).
  if index( attr-other,  "compl-root=") > 0
  and num-entries(buf_cash-desk-attr.attr-code , chr(4)) > 1 then do:
    do jj = 1 to num-entries(attr-other, chr(47)):
      if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "compl-root":U then do:
        assign
        v-compl-root = logical(entry(lookup(entry(1, buf_cash-desk-attr.attr-code, chr(4)),v-prop-list), entry(2, entry(jj, attr-other, chr(47)), "=":U)))
        .
      end.
      if v-compl-root  then next _cash-desk-attr.
    end.
  end.
  if p-mode <> 'ПРОСМОТР':U
  then do:
    run cd-attr-news in this-procedure (
                                        input buf_cash-desk-attr.upper-attr-code
                                      , input buf_cash-desk-attr.attr-code
                                      , output attr-news
                                      , output attr-from-gbd
                                      , output attr-from-ubd).
    if v-cntxt-db-num = 0
    and buf_cash-desk.db-num <> v-cntxt-db-num
    and attr-from-gbd <> yes
    then  attr-user-can-edit = no.
    if buf_cash-desk.db-num = v-cntxt-db-num
    and attr-from-ubd <> yes and v-cntxt-db-num <> 0
    then
    assign
    attr-user-can-edit = no.
  end.
  if attr-output-display = true then DO:
    run cd-attr-value in this-procedure (
                                            input buf_cash-desk-attr.db-num
                                          ,input buf_cash-desk-attr.obj-code
                                          ,input buf_cash-desk-attr.pos-type
                                          ,input buf_cash-desk-attr.cash-num
                                          ,input buf_cash-desk-attr.upper-attr-code
                                          ,input buf_cash-desk-attr.attr-code
                                          ,output attr-character
                                          ,output attr-date
                                          ,output attr-decimal
                                          ,output attr-integer
                                          ,output attr-logical
                                          ,output attr-type ) .
    create Temp-hattr.
    assign
    temp-hattr.obj-code = buf_cash-desk-attr.obj-code
    temp-hattr.pos-type = buf_cash-desk-attr.pos-type
    temp-hattr.cash-num = buf_cash-desk-attr.cash-num
    temp-hattr.db-num = buf_cash-desk-attr.db-num
    Temp-hattr.upper-attr-code = buf_cash-desk-attr.upper-attr-code
    Temp-hattr.attr-code = attr-label
    Temp-hattr.attr-value-character = attr-character
    Temp-hattr.attr-value-date = attr-date
    Temp-hattr.attr-value-decimal = attr-decimal
    Temp-hattr.attr-value-integer = attr-integer
    Temp-hattr.attr-value-logical = attr-logical
    Temp-hattr.attr-value-type = attr-type
    Temp-hattr.user-can-edit = attr-user-can-edit
    Temp-hattr.code = buf_cash-desk-attr.attr-code
    .
    case attr-type:
      when 'character':U then do:
        assign
        v-view-col[1] = yes.
      end.
      when 'date':U then do:
        assign
        v-view-col[2] = yes.
      end.
      when 'decimal':U then do:
        assign
        v-view-col[3] = yes.
      end.
      when 'integer':U then do:
        assign
        v-view-col[4] = yes.
      end.
      when 'logical':U then do:
        assign
        v-view-col[5] = yes.
      end.
    end case.
    case Temp-hattr.code:
       when 'USE_FFD_VERSION':U then do:
          case Temp-hattr.attr-value-character :
             when "0" then Temp-hattr.attr-value-character = "авт" .
             when "2" then Temp-hattr.attr-value-character = "1.05" .
             when "3" then Temp-hattr.attr-value-character = "1.1" .
             when "4" then Temp-hattr.attr-value-character = "1.2" .
             otherwise Temp-hattr.attr-value-character = " " .
          end case .
       end.
       when 'KKT_FFD_VERSION':U then do:
          case Temp-hattr.attr-value-character :
             when "0" then Temp-hattr.attr-value-character = "авт" .
             when "2" then Temp-hattr.attr-value-character = "1.05" .
             when "3" then Temp-hattr.attr-value-character = "1.1" .
             when "4" then Temp-hattr.attr-value-character = "1.2" .
             otherwise Temp-hattr.attr-value-character = " " .
          end case .
       end.
       when 'KKT_SCHEMA':U then do:
          case Temp-hattr.attr-value-character :
             when "0" then Temp-hattr.attr-value-character = "с ожиданием ответа" .
             when "1" then Temp-hattr.attr-value-character = "без ожидания ответа" .
             otherwise Temp-hattr.attr-value-character = " " .
          end case .
       end.
    end case .
    run cd-attr-send-param in this-procedure ( input Temp-hattr.upper-attr-code
                                              ,input Temp-hattr.code
                                              ,output Temp-hattr.to-send).
    v-all-send-param = Temp-hattr.to-send or v-all-send-param.
    assign
    v-view-col[6] = v-all-send-param.
  End.
End.
RUN view-hide-columns IN THIS-PROCEDURE (INPUT NO).
b-send:sensitive in frame Dialog-Frame = v-all-send-param.
OPEN QUERY br-attrs FOR EACH Temp-hattr NO-LOCK.
END PROCEDURE.
PROCEDURE MyEnable :
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-value as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable v-prop-list as character no-undo .
define variable attr-from-gbd as logical no-undo .
define variable attr-from-ubd as logical no-undo .
define variable attr-news as logical no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-auto as character no-undo .
DEFINE variable v-ch0 AS HANDLE NO-UNDO.
define variable v-found as logical no-undo .
RUN control_load IN THIS-PROCEDURE .
ASSIGN
B-send:POPUP-MENU IN FRAME Dialog-Frame = MENU POPUP-MENU-B-send:HANDLE
temp-hattr.attr-value-character:resizable IN BROWSE br-attrs = YES
b-ins:POPUP-MENU IN FRAME Dialog-Frame = MENU MENU-b-ins:HANDLE
temp-hattr.attr-code:resizable in browse br-attrs = yes
b-ins:MENU-MOUSE = 1
chCtrlFrame:PSTimer:ENABLED  = (p-pos-type = 'IBS-TH':U
                               OR
                               p-pos-type = 'IBS-TH-MOB':U
                               )
                               AND
                               p-mode = 'ПРОСМОТР':U
chCtrlFrame:PSTimer:INTERVAL = IF NOT (p-pos-type = 'IBS-TH':U
                               OR
                               p-pos-type = 'IBS-TH-MOB':U
                               )
                               AND
                               p-mode = 'ПРОСМОТР':U THEN 0
                                ELSE 3000
.
ASSIGN
v-ch0 = br-attrs:FIRST-COLUMN IN FRAME Dialog-Frame.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = "Значение!(строковое)" THEN
   v-ch_[1] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Дата)" THEN
   v-ch_[2] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Десятичное)" THEN
   v-ch_[3] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Целое)" THEN
   v-ch_[4] = v-ch0.
   IF v-ch0:LABEL = "Значение!(Логическое)" THEN
   v-ch_[5] = v-ch0.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
do v-jj = 1 to num-entries ('MAGIA-XML_operative,IBM-XML_operative,IBM-XML_general,MARIA_operative,MARIA_general,INFOKIOSK_operative,NCR-GM_general,NCR-AS-R_general,IBS-TH_devices,IBS-TH_fisreg,IBS-TH_rec-print,IBS-TH_main,IBS-TH_interface,IBS-TH-MOB_main,IBS-TH-MOB_rec-print,AUTOTANK_operative':u):
  if not entry(v-jj, 'MAGIA-XML_operative,IBM-XML_operative,IBM-XML_general,MARIA_operative,MARIA_general,INFOKIOSK_operative,NCR-GM_general,NCR-AS-R_general,IBS-TH_devices,IBS-TH_fisreg,IBS-TH_rec-print,IBS-TH_main,IBS-TH_interface,IBS-TH-MOB_main,IBS-TH-MOB_rec-print,AUTOTANK_operative':u) begins p-pos-type then next.
  if p-ref-mode = "oper" then do:
    if not entry(v-jj, 'MAGIA-XML_operative,IBM-XML_operative,IBM-XML_general,MARIA_operative,MARIA_general,INFOKIOSK_operative,NCR-GM_general,NCR-AS-R_general,IBS-TH_devices,IBS-TH_fisreg,IBS-TH_rec-print,IBS-TH_main,IBS-TH_interface,IBS-TH-MOB_main,IBS-TH-MOB_rec-print,AUTOTANK_operative':u) begins (p-pos-type + "_operative") then next.
  end.
  else do:
    if entry(v-jj, 'MAGIA-XML_operative,IBM-XML_operative,IBM-XML_general,MARIA_operative,MARIA_general,INFOKIOSK_operative,NCR-GM_general,NCR-AS-R_general,IBS-TH_devices,IBS-TH_fisreg,IBS-TH_rec-print,IBS-TH_main,IBS-TH_interface,IBS-TH-MOB_main,IBS-TH-MOB_rec-print,AUTOTANK_operative':u) begins (p-pos-type + "_operative") then next.
  end.
  v-found = yes.
  if p-mode <> 'ПРОСМОТР':U then do:
    v-prop-list = ''.
    run cd-attr-code in this-procedure (
                                        input  entry(v-jj, 'MAGIA-XML_operative,IBM-XML_operative,IBM-XML_general,MARIA_operative,MARIA_general,INFOKIOSK_operative,NCR-GM_general,NCR-AS-R_general,IBS-TH_devices,IBS-TH_fisreg,IBS-TH_rec-print,IBS-TH_main,IBS-TH_interface,IBS-TH-MOB_main,IBS-TH-MOB_rec-print,AUTOTANK_operative':u)
                                        ,input  ''
                                        ,output attr-type
                                        ,output attr-format
                                        ,output attr-label
                                        ,output attr-user-can-edit
                                        ,output attr-output-display
                                        ,output attr-other
                                        ,output v-prop-list
                                        )  .
    run attr-pop-create-items in this-procedure  (
                                                  input 'cash-desk-attr':U
                                                  ,input 'cd-attr-manual-edit'
                                                  ,input 'cd-attr-tooltip'
                                                  ,input 'choose-to-edit'
                                                  ,input menu menu-b-ins:handle
                                                  ,input entry(v-jj, 'MAGIA-XML_operative,IBM-XML_operative,IBM-XML_general,MARIA_operative,MARIA_general,INFOKIOSK_operative,NCR-GM_general,NCR-AS-R_general,IBS-TH_devices,IBS-TH_fisreg,IBS-TH_rec-print,IBS-TH_main,IBS-TH_interface,IBS-TH-MOB_main,IBS-TH-MOB_rec-print,AUTOTANK_operative':u)
                                                  ,input v-prop-list
                                                ).
  end.
end.
if not v-found then do:
  if p-ref-mode = "oper" then do:
    message
    "Для данного типа кассы не найдено оперативных данных для изменения/просмотра"
      view-as alert-box warning.
  end.
  else do:
    message
    "Для данного типа кассы не найдено настроек для изменения/просмотра"
      view-as alert-box warning.
  end.
    return "return".
end.
if p-mode <> 'ПРОСМОТР':U then do:
  for each tt-attr-property where
            tt-attr-property.table-name = 'cash-desk-attr':U:
    v-prop-list = ''.
    run cd-attr-code in this-procedure (
                                         input  tt-attr-property.upper-attr-code
                                        ,input  tt-attr-property.attr-code
                                        ,output attr-type
                                        ,output attr-format
                                        ,output attr-label
                                        ,output attr-user-can-edit
                                        ,output attr-output-display
                                        ,output attr-other
                                        ,output v-prop-list
                                        ) .
    v-auto = '':U.
    do jj = 1 to num-entries(attr-other, chr(47)):
      if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "auto":U then do:
        assign
        v-auto = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
        .
      end.
    end.
    if valid-handle (tt-attr-property.menu-item-handle) then do:
      assign
      tt-attr-property.menu-item-handle:sensitive = (v-auto = '':U
                                                        or
                                                        lookup(string(buf_cash-desk.auto),  v-auto) > 0)
      .
      run cd-attr-news in this-procedure (
                                           input  tt-attr-property.upper-attr-code
                                          ,input  tt-attr-property.attr-code
                                          ,output attr-news
                                          ,output attr-from-gbd
                                          ,output attr-from-ubd).
      if v-cntxt-db-num = 0
      and buf_cash-desk.db-num <> v-cntxt-db-num
      and attr-from-gbd <> yes  then do:
        tt-attr-property.menu-item-handle:sensitive = no.
      end.
      if buf_cash-desk.db-num = v-cntxt-db-num
      and attr-from-ubd <> yes and v-cntxt-db-num <> 0 then do:
        tt-attr-property.menu-item-handle:sensitive = no.
      end.
      release tt-attr-property.
    end.
 end.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  v-found = no.
  for each  tt-attr-property where
           tt-attr-property.table-name = 'cash-desk-attr':U:
    if tt-attr-property.menu-item-handle:sensitive = yes then do:
      v-found = yes.
      leave.
    end.
  end.
  if not v-found then do:
    if p-ref-mode = "oper" then do:
      message
      "Для данного типа кассы не найдено оперативных данных, которые разрешено менять из данной БД"
      view-as alert-box warning.
    end.
    else do:
      message
      "Для данного типа кассы не найдено настроек, которые разрешено менять из данной БД"
      view-as alert-box warning.
    end.
    return "return".
  end.
end.
ENABLE
b-quit
b-lkp
b-del when p-mode = 'ИЗМЕНЕНИЕ':U
b-ins when p-mode = 'ИЗМЕНЕНИЕ':U
b-chg when p-mode = 'ИЗМЕНЕНИЕ':U
b-help br-attrs
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
OPEN QUERY br-attrs FOR EACH Temp-hattr NO-LOCK.
ASSIGN
b-ins:MENU-MOUSE = 1
b-send:MENU-MOUSE = 1
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  p-obj-code
  ,output v-cash-desk-host-code
  )  .
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-reference_input-deletion-updating':U
    ,input  'object':U
    ,input  v-cash-desk-host-code
    ,input  'маг':U
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-glog
    )  .
end.
END PROCEDURE.
PROCEDURE proc-add-chg :
define input parameter p-add as logical no-undo .
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable attr-character as character no-undo .
define variable attr-date as date no-undo .
define variable attr-decimal as decimal no-undo .
define variable attr-integer as integer no-undo .
define variable attr-logical as logical no-undo .
define variable v-prop-list as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-init as character no-undo .
define variable jj as integer no-undo.
DEFINE VARIABLE v-spr as character no-undo .
DEFINE VARIABLE v-sprlevel as character no-undo .
DEFINE VARIABLE v-setted as logical no-undo .
DEFINE VARIABLE v-deleted as logical no-undo .
define variable v-check as character no-undo .
define variable v-error-code as character no-undo .
define variable v-correct as logical no-undo .
define variable glog  as logical no-undo .
define variable loc#log as logical no-undo.
case p-add:
  when yes then do:
    if p-mode <> 'ДОБАВЛЕНИЕ':U then do:
    if not p-glog and add-option = "last-check-params" then
    return no-apply .
    if not v-glog and add-option <> "last-check-params" then return no-apply .
      run temp-cd-attr-exist in this-procedure (
                                                   input p-db-num
                                                  ,input p-obj-code
                                                  ,input p-pos-type
                                                  ,input p-cash-num
                                                  ,input add-option-section
                                                  ,input add-option
                                                  ,output loc#log)  no-error.
      if error-status:error then return error.
      if loc#log then do:
        message
        "Данный атрибут/параметр уже существует"
        view-as alert-box error .
        return error.
      end.
    end.
    run cd-attr-code in this-procedure (
                                           input  add-option-section
                                          ,input  add-option
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other
                                          ,output v-prop-list
                                          ) no-error .
    if error-status :error then do:
      return error .
    end.
    assign
    added = yes.
    do jj = 1 to num-entries(attr-other, chr(47)):
      if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "init":U then do:
        assign
        v-init = string(entry(2, entry(jj, attr-other, chr(47)), "=":U))
        .
      end.
    end.
    if  v-init <> "":U then do:
        run  value(v-init)
                    in this-procedure (
                                         input p-db-num
                                        ,input p-obj-code
                                        ,input p-pos-type
                                        ,input p-cash-num
                                        ,output attr-character
                                        ,output attr-date
                                        ,output attr-decimal
                                        ,output attr-integer
                                        ,output attr-logical
                                        ) no-error .
          if error-status:error then do:
              assign
              attr-character = "":U
              .
          end.
    end.
    CASE attr-type:
      when 'L':U then do:
        assign
        v-attr-value = "yes":U
        .
      end.
      when 'I':U or when 'D':U then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-character
                      else string(0)
        .
      end.
      when 'T':U then do:
        assign
        v-attr-value = ?
        .
      end.
      when 'C':U then do:
        assign
        v-attr-value = if v-init <> "":U
                      then attr-character
                      else "":U
        .
      end.
    END CASE.
    assign
    attr-character = v-attr-value
    .
  end.
  when no then do:
    if not p-glog and TEMP-hattr.code = "last-check-params" then
    return no-apply .
    if not v-glog and TEMP-hattr.code <> "last-check-params" then return no-apply .
    run cd-attr-code in this-procedure (
                                           input TEMP-hattr.upper-attr-code
                                          ,input TEMP-hattr.code
                                          ,output attr-type
                                          ,output attr-format
                                          ,output attr-label
                                          ,output attr-user-can-edit
                                          ,output attr-output-display
                                          ,output attr-other
                                          ,output v-prop-list
                                          ) no-error.
    IF ERROR-STATUS:ERROR
    THEN DO:
        message "Ошибка при определении названия и типа атрибута/параметра кассы!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
        return error.
    END.
    if temp-hattr.user-can-edit = no then do:
      message
      "Нельзя менять атрибут/параметр!"
      view-as alert-box error .
      undo, return error .
    end.
    RUN cd-ATTR-VALUE IN THIS-PROCEDURE (
                                          INPUT p-db-num
                                         ,INPUT p-obj-code
                                         ,INPUT p-pos-type
                                         ,input p-cash-num
                                         ,input TEMP-hattr.upper-attr-code
                                         ,input TEMP-hattr.code
                                         ,OUTPUT ATTR-character
                                         ,output attr-date
                                         ,output attr-decimal
                                         ,output attr-integer
                                         ,output attr-logical
                                         ,OUTPUT attr-type) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        message "Ошибка при определении значения атрибута/параметра кассы!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
        return error.
    END.
  end.
END CASE.
IF attr-user-can-edit Then DO:
  do jj = 1 to num-entries(attr-other, chr(47)):
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "sprlevel":U then do:
      assign
      v-sprlevel = entry(2, entry(jj, attr-other, chr(47)), "=":U)
      .
    end.
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "spr":U then do:
      if v-sprlevel = "cd" then do:
        assign
        v-spr = entry(2, entry(jj, attr-other, chr(47)), "=":U)
        .
      end.
      else do:
        assign
        v-spr = string(entry(lookup(if p-add then add-option else temp-hattr.code, v-prop-list ),  entry(2, entry(jj, attr-other, chr(47)), "=":U)))
        .
      end.
    end.
    if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "check":U then do:
      assign
      v-check = string(entry(lookup(if p-add then add-option else temp-hattr.code, v-prop-list ),  entry(2, entry(jj, attr-other, chr(47)), "=":U)))
      .
    end.
  end.
  if v-spr = "":U then do:
    define variable v-ok as logical no-undo .
     case attr-type:
      when 'character':U then do:
        run gbl/d-character.w (
             input ?
            ,input (
            'title=':u + "Изменение атрибута/параметра кассы" + '\':u
          + 'text1=':u + attr-label + '\':u
          + 'format=' + (if attr-type = 'L':U then "yes/no" else attr-format) + '\':u
          + 'fillin_row=4\':u
          + 'fillin_col=4\':u
          + 'fillin_width=20\':u
          + 'fillin_height=1\':u
          + 'max-chars=70\':u
          + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U then 'yes':u else 'no':u) + '\':u  )
          , input-output attr-character
          , output v-ok
                ).
      end.
      when 'date':U then do:
        run gbl/d-inpday.w
          (input ?
          ,input substitute("Изменение атрибута/параметра кассы &1", attr-label)
          ,input ""
          ,input-output attr-date
          ,output v-ok
          ) NO-ERROR.
      end.
      when 'decimal':U then do:
        run gbl/d-decimal.w (
              input ?
              ,input (
              'title=':u + "Изменение атрибута/параметра кассы" + '\':u
            + 'text1=':u + attr-label + '\':u
            + 'format=' + attr-format + '\':u
            + 'fillin_row=3\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u
            + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U then 'yes':u else 'no':u) + '\':u  )
            , input-output attr-decimal
            , output v-ok
                ).
      end.
      when 'integer':U then do:
        run gbl/d-integer.w (
              input ?
              ,input (
              'title=':u + "Изменение атрибута/параметра кассы" + '\':u
            + 'text1=':u + attr-label + '\':u
            + 'format=' + attr-format + '\':u
            + 'fillin_row=3\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u
            + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U then 'yes':u else 'no':u) + '\':u  )
            , input-output attr-integer
            , output v-ok
                ).
      end.
      when 'logical':U then do:
        run gbl/d-logical.w (
           input ?
          ,input  (
          'title=':u + "Изменение атрибута/параметра кассы" + '\':u
          + 'text1=':u + attr-label + '\':u
          + 'format=' + "yes/no"  + '\':u
          + 'fillin_row=2\':u
          + 'fillin_col=4\':u
          + 'fillin_width=20\':u
          + 'fillin_height=1\':u
          + 'max-chars=70\':u
          + 'readonly=' + (if p-mode <> 'ИЗМЕНЕНИЕ':U then 'yes':u else 'no':u) + '\':u)
          , input-output attr-logical
          , output v-ok
                ).
      end.
    end case.
    if not v-ok then return error.
    run cd-attr-write in this-procedure (
                                          input p-db-num
                                          ,input p-obj-code
                                          ,input p-pos-type
                                          ,input p-cash-num
                                          ,input (if p-add then add-option-section else temp-hattr.upper-attr-code)
                                          ,input (if p-add then add-option else temp-hattr.code)
                                          ,input attr-character
                                          ,input attr-date
                                          ,input attr-decimal
                                          ,input attr-integer
                                          ,input attr-logical
                                        ) no-error .
    IF NOT error-status:error then do:
        assign
        updated = yes
        .
    END.
    else do:
        message "Ошибка при изменении значения атрибута/параметра кассы!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
    end.
  END.
  ELSE DO:
    if v-sprlevel = '' then do:
      run  value(v-spr) in this-procedure (
                                       input parparentproc
                                      ,input p-db-num
                                      ,input p-obj-code
                                      ,input p-pos-type
                                      ,INPUT p-cash-num
                                      ,input-output attr-character
                                      ,input-output attr-date
                                      ,input-output attr-decimal
                                      ,input-output attr-integer
                                      ,input-output attr-logical
                                      ,output v-setted) no-error .
    end.
    if v-sprlevel = 'cd' then do:
      run  value(v-spr) (
                                       input parparentproc
                                      ,input 'ИЗМЕНЕНИЕ':U
                                      ,input p-db-num
                                      ,input p-obj-code
                                      ,input p-pos-type
                                      ,INPUT p-cash-num
                                      ,input (if p-add then add-option-section else temp-hattr.upper-attr-code)
                                      ,input (if p-add then add-option else temp-hattr.code)
                                      ,output v-setted) no-error .
    end.
    if not v-setted then return error.
  end.
  if v-check <> "":U then do:
    run value(v-check) (
                       input p-db-num
                      ,input p-obj-code
                      ,input p-pos-type
                      ,input p-cash-num
                      ,input (if p-add = yes then add-option-section else temp-hattr.upper-attr-code)
                      ,input (if p-add = yes then add-option else temp-hattr.code)
                      ,input attr-character
                      ,input attr-date
                      ,input attr-decimal
                      ,input attr-integer
                      ,input attr-logical
                      ,input (if p-add then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
                      ,output v-correct
                      ,output v-error-code) no-error.
    if error-status:error then do:
      message
      "Ошибка при проверке корректности задаваемого значения атрибута/параметра" skip
      error-status:get-message(1) skip
      view-as alert-box error .
      undo, return error .
    end.
    if not v-correct then do:
      message
      "Задаваемое значение атрибута/параметра некорректно" skip
      return-value
      view-as alert-box error .
      undo, return error .
    end.
  end.
  run cd-attr-write in this-procedure (
                                        input p-db-num
                                        ,input p-obj-code
                                        ,input p-pos-type
                                        ,input p-cash-num
                                        ,input (if p-add then add-option-section else temp-hattr.upper-attr-code)
                                        ,input (if p-add then add-option else temp-hattr.code)
                                        ,input attr-character
                                        ,input attr-date
                                        ,input attr-decimal
                                        ,input attr-integer
                                        ,input attr-logical
                                      ) no-error .
  IF NOT error-status:error then do:
    assign
    updated = yes
    .
  END.
  else do:
    message "Ошибка при изменении значения атрибута/параметра кассы!"         "Обратитесь к администратору системы" skip error-status:get-message(1) skip         return-value skip view-as alert-box ERROR.
  end.
End.
Else message "Изменение атрибута/параметра невозможно !" view-as alert-box error.
END PROCEDURE.
PROCEDURE proc-b-lkp :
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable attr-value as char no-undo .
define variable v-prop-list as character no-undo .
define variable v-run-name as character no-undo .
define variable v-sprlevel as character no-undo .
define variable v-setted as logical no-undo .
define variable jj as integer no-undo .
  run cd-attr-code in this-procedure (
                       input temp-hattr.upper-attr-code
                      ,input temp-hattr.code
                      ,output attr-type
                      ,output attr-format
                      ,output attr-label
                      ,output attr-user-can-edit
                      ,output attr-output-display
                      ,output attr-other
                      ,output v-prop-list
                      ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    return error.
END.
do jj = 1 to num-entries(attr-other, chr(47)):
  if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "sprlevel":U then do:
    assign
    v-sprlevel = entry(2, entry(jj, attr-other, chr(47)), "=":U)
    .
  end.
  if entry(1, entry(jj, attr-other, chr(47)), "=":U) = "display":U then do:
    if v-sprlevel = "cd" then do:
      assign
      v-run-name = entry(2, entry(jj, attr-other, chr(47)), "=":U)
      .
    end.
    else do:
      assign
      v-run-name = string(entry(lookup(entry(1, temp-hattr.code, chr(4)), v-prop-list ),  entry(2, entry(jj, attr-other, chr(47)), "=":U)))
      .
    end.
  end.
end.
if v-sprlevel = 'cd' then do:
  run  value(v-run-name) (
                                    input parparentproc
                                  ,input 'ПРОСМОТР':U
                                  ,input p-db-num
                                  ,input p-obj-code
                                  ,input p-pos-type
                                  ,INPUT p-cash-num
                                  ,input temp-hattr.upper-attr-code
                                  ,input temp-hattr.code
                                  ,output v-setted) no-error .
end.
else do:
  run value(v-run-name) in this-procedure(
                                         input parparentproc
                                        ,input temp-hattr.db-num
                                        ,input temp-hattr.obj-code
                                        ,input temp-hattr.pos-type
                                        ,input temp-hattr.cash-num
                                        ,input temp-hattr.upper-attr-code
                                        ,input temp-hattr.code
                                        ,input temp-hattr.attr-value-character
                                        ,input temp-hattr.attr-value-date
                                        ,input temp-hattr.attr-value-decimal
                                        ,input temp-hattr.attr-value-integer
                                        ,input temp-hattr.attr-value-logical
                                          )
                                          no-error .
end.
if error-status:error then undo, return error .
return .
END PROCEDURE.
PROCEDURE proc-b-send :
define input parameter p-section as character no-undo .
DEFINE INPUT PARAMETER p-what-send AS CHARACTER NO-UNDO.
define variable v-parameter as character no-undo .
define variable v-one-send-param as logical no-undo .
if v-parameter <> '':U then do:
  run cd-attr-send-param in this-procedure ( input Temp-hattr.upper-attr-code
                                            ,input Temp-hattr.code
                                            ,output v-one-send-param) no-error .
  if not v-one-send-param then do:
    message
    "Данный атрибут/параметр пересылке не подлежит"
    view-as alert-box WARNING.
    return error.
  end.
end.
assign
v-parameter =  string(buf_cash-desk.db-num) + chr(4) +
            string(buf_cash-desk.obj-code) + chr(4) +
            buf_cash-desk.pos-type + chr(4) +
            string(buf_cash-desk.cash-num) + chr(4) +
            'U' + chr(4) + p-what-send + chr(4) + p-section.
if buf_cash-desk.db-num = v-cntxt-db-num then do:
  run str/diallog.w ( INPUT parparentproc
                , INPUT this-procedure
                , INPUT 'str/send-par.p':U
                , input v-parameter
                , no
                , ''
                , 'Отправка параметров касс').
end.
else do:
    run nws/cr-route.p (
                   input 'send-cmd':U
                  ,input "command" + chr(1) + "run-file" + chr(1) + "str/send-par.p" + chr(1) + v-parameter
                  ,input ?
                  ,input string(buf_cash-desk.db-num)
                  ) no-error .
    if error-status:error then do:
      message
      substitute("Ошибка при отсылке параметра на кассу через СПН&1"  +
                 "&2&1&3&1"
                 , error-status:get-message(1)
                 , return-value )
      view-as alert-box error .
    end.
    else do:
       message
       "Команда на отсылку параметра на кассу успешно отправлена через СПН"
       view-as alert-box.
    end.
end.
END PROCEDURE.
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch_[1]:FGCOLOR = GREY_COLOR
v-ch_[1]:BGCOLOR = GREY_Color
v-ch_[1]:PFCOLOR = GREY_Color
v-ch_[2]:FGCOLOR = GREY_COLOR
v-ch_[2]:BGCOLOR = GREY_Color
v-ch_[2]:PFCOLOR = GREY_Color
v-ch_[3]:FGCOLOR = GREY_COLOR
v-ch_[3]:BGCOLOR = GREY_Color
v-ch_[3]:PFCOLOR = GREY_Color
v-ch_[4]:FGCOLOR = GREY_COLOR
v-ch_[4]:BGCOLOR = GREY_Color
v-ch_[4]:PFCOLOR = GREY_Color
v-ch_[5]:FGCOLOR = GREY_COLOR
v-ch_[5]:BGCOLOR = GREY_Color
v-ch_[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN 'character':U THEN DO:
      ASSIGN
      v-ch_[1]:FGCOLOR = BLACK_COLOR
      v-ch_[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'decimal':U THEN DO:
      ASSIGN
      v-ch_[3]:FGCOLOR = BLACK_COLOR
      v-ch_[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'integer':U THEN DO:
      ASSIGN
      v-ch_[4]:FGCOLOR = BLACK_COLOR
      v-ch_[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'date':U THEN DO:
      ASSIGN
      v-ch_[2]:FGCOLOR = BLACK_COLOR
      v-ch_[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN 'logical':U THEN DO:
       ASSIGN
       v-ch_[5]:FGCOLOR = BLACK_COLOR
       v-ch_[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.
END PROCEDURE.
PROCEDURE temp-cd-attr-exist :
do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
    define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
    define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
    define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
    define input parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
    define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_temp-hattr for temp-hattr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-prop-list      as character no-undo .
    run cd-attr-code in this-procedure (
                                         input  p-ucode
                                        ,input  p-code
                                        ,output v-type
                                        ,output v-format
                                        ,output v-label
                                        ,output v-user-can-edit
                                        ,output v-output-display
                                        ,output v-other
                                        ,output v-prop-list
                                        ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_temp-hattr exclusive-lock
      where buf_temp-hattr.db-num  = p-db-num
        and buf_temp-hattr.obj-code  = p-obj-code
        and buf_temp-hattr.pos-type  = p-pos-type
        and buf_temp-hattr.cash-num  = p-cash-num
        and buf_temp-hattr.code = p-code
        and buf_temp-hattr.upper-attr-code = p-ucode
      no-error .
    if  available buf_temp-hattr then do:
      p-exist = yes.
    end.
  end.
END PROCEDURE.
PROCEDURE view-hide-columns :
DEFINE INPUT PARAMETER p-find AS LOGICAL NO-UNDO.
IF p-find THEN DO:
   v-view-col[1] = CAN-FIND(temp-hattr WHERE temp-hattr.attr-value-type = 'character':U).
   v-view-col[2] = CAN-FIND(temp-hattr WHERE temp-hattr.attr-value-type = 'date':U).
   v-view-col[3] = CAN-FIND(temp-hattr WHERE temp-hattr.attr-value-type = 'decimal':U).
   v-view-col[4] = CAN-FIND(temp-hattr WHERE temp-hattr.attr-value-type = 'integer':U).
   v-view-col[5] = CAN-FIND(temp-hattr WHERE temp-hattr.attr-value-type = 'logical':U).
END.
assign
temp-hattr.attr-value-character:visible in browse br-attrs = v-view-col[1]
temp-hattr.attr-value-date:visible in browse br-attrs = v-view-col[2]
temp-hattr.attr-value-decimal:visible in browse br-attrs = v-view-col[3]
temp-hattr.attr-value-integer:visible in browse br-attrs = v-view-col[4]
temp-hattr.attr-value-logical:visible in browse br-attrs = v-view-col[5]
temp-hattr.to-send:visible in browse br-attrs = v-view-col[6]
.
END PROCEDURE.
