define input parameter parparentproc as widget-handle no-undo .
define input parameter parref-mode as character no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   DEFINE NEW GLOBAL SHARED VARIABLE hpApi AS HANDLE NO-UNDO.
   IF NOT VALID-HANDLE(hpApi) THEN run gbl/windows.p PERSISTENT SET hpApi.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW GLOBAL SHARED VARIABLE hpWinFunc AS HANDLE NO-UNDO.
  IF NOT VALID-HANDLE(hpWinFunc) THEN run gbl/winfunc.p PERSISTENT SET hpWinFunc.
FUNCTION GetLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION GetParent
         RETURNS INTEGER
         (input hwnd as INTEGER)
         IN hpWinFunc.
FUNCTION ShowLastError
         RETURNS INTEGER
         ()
         IN hpWinFunc.
FUNCTION CreateProcess
         RETURNS INTEGER
         (input CommandLine as CHAR,
          input CurrentDir  as CHAR,
          input wShowWindow as INTEGER)
         in hpWinFunc.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function IsProcessRunning return integer
  (PID AS INTEGER) :
  DEFINE VARIABLE IsRunning   AS LOGICAL NO-UNDO INITIAL NO.
  DEFINE VARIABLE hProcess    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ExitCode    AS INTEGER NO-UNDO.
  DEFINE VARIABLE ReturnValue AS INTEGER NO-UNDO.
  define variable rv          as integer no-undo .
  RUN OpenProcess in hpapi
                  ( 1024,
                    0,
                    PID,
                    OUTPUT hProcess).
  IF hProcess NE 0 THEN DO:
     RUN GetExitcodeProcess in hpapi
                  ( hProcess,
                    OUTPUT ExitCode,
                    OUTPUT ReturnValue).
     rv = (if (ExitCode=259) AND (ReturnValue NE 0)
          then  - 1
          else ReturnValue).
     RUN CloseHandle in hpapi (hProcess, OUTPUT ReturnValue).
  END.
  RETURN rv.
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define temp-table tt-tso no-undo
  field db-num        as integer
  field obj-code      as integer
  field tso-num       as integer
  field tso-addr      as character
  field PosStatus     as character
  field FiscalStatus  as character
  field zReportDate   as character
  field FiscalQueue   as integer
  field ShiftNum      as integer
  field ShiftState    as character
  field ShiftBegin    as character
  field CashierNum    as integer
  index pi as primary unique
    tso-num obj-code
.
define temp-table tt-pump no-undo
  field pump-code   as integer
  field obj-type    as character
  field obj-code    as integer
  field status_     as character
  field numTr       as integer
  index pi as primary unique
    pump-code obj-type obj-code
.
define temp-table tt-pids no-undo
  field pid as integer
  index pi as primary unique
    pid
.
define variable log-exit          as logical    no-undo .
define variable curl-path         as character  no-undo .
define variable v-post-file-name  as character  no-undo .
define variable v-cmd-file-name   as character  no-undo .
define variable v-command         as character  no-undo .
define variable v-out-str         as character  no-undo .
define variable v-pid-list        as character  no-undo .
define variable v-time-str        as character  no-undo .
define variable v-del-file        as character  no-undo .
define variable v-parsesub        as character  no-undo .
define variable hDoc              as handle     no-undo .
define variable hRoot             as handle     no-undo .
define variable good              as logical    no-undo .
define variable v-temp-dir        as character  no-undo .
define variable rv                as integer    no-undo .
define variable cash-recids       as character  no-undo .
define variable ii                as integer    no-undo .
define variable rid-list          as character  no-undo .
define buffer buf_cash-desk for ub.cash-desk .
define buffer buf_cash-desk-attr for ub.cash-desk-attr .
define buffer buf_clients for ub.clients .
define buffer buf_pump for ub.pump .
DEFINE BUTTON b-close
     LABEL "Закрыть смену"
     SIZE 18 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-open
     LABEL "Открыть смену"
     SIZE 18 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-start
     LABEL "Запустить смену"
     SIZE 18 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-stop
     LABEL "Остановить смену"
     SIZE 18 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-z-report
     LABEL "Снять Z-отчет"
     SIZE 18 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-cashier
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE VARIABLE f-cashier AS INTEGER FORMAT ">>>>9":U
     label "Кассир"
     VIEW-AS FILL-IN
     SIZE 5.5 BY 1 NO-UNDO.
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
define query br-tso for tt-tso scrolling .
define browse br-tso
  query br-tso no-lock display
    mark-string ( INPUT RECID( tt-tso ), INPUT rid-list) format "X(1)" label "*"
    tt-tso.db-num format "999" label "БД"
    tt-tso.obj-code format "99999" label "Магазин"
    tt-tso.tso-num format ">>>>9" label "№ ТСО"
    tt-tso.tso-addr format "X(27)" label "Адрес ТСО"
    tt-tso.FiscalStatus format "X(11)" label "Статус ФР"
    tt-tso.zReportDate format "X(20)" label "Посл. Z-отчет"
    tt-tso.FiscalQueue format ">>>9" label "Очередь ФР"
    tt-tso.ShiftNum format ">>9" label "№ Смены"
    tt-tso.ShiftState format "X(11)" label "Статус Смены"
    tt-tso.ShiftBegin format "X(20)" label "Начало Смены"
    tt-tso.CashierNum format ">>>>>>9" label "Кассир"
WITH NO-ROW-MARKERS SEPARATORS SIZE 143 BY 6
         TITLE "ТСО" FIT-LAST-COLUMN.
define query br-pump for tt-pump scrolling .
define browse br-pump
  query br-pump no-lock display
    tt-pump.obj-code format "99999" label "Магазин"
    tt-pump.pump-code format ">>9" label "№ ТРК"
    tt-pump.status_ format "X(24)" label "Статус"
    tt-pump.numTr   format ">>>>>>9" label "Кол-во транзакций"
WITH NO-ROW-MARKERS SEPARATORS SIZE 143 BY 8
         TITLE "ТРК" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.24 COL 2
     b-mark at row 1.24 col 12
     b-stop AT ROW 1.24 COL 21 WIDGET-ID 2
     b-start AT ROW 1.24 COL 39 WIDGET-ID 4
     b-close AT ROW 1.24 COL 57 WIDGET-ID 6
     b-open AT ROW 1.24 COL 75 WIDGET-ID 8
     b-z-report AT ROW 1.24 COL 93 WIDGET-ID 10
     f-cashier at row 1.24 col 118
     b-cashier at row 1.24 col 130
     br-tso at row 3 col 2
     br-pump at row 9.2 col 2
     SPACE(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Управление ТСО"
         CANCEL-BUTTON b-exit WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-cashier IN FRAME Dialog-Frame
DO:
  cash-recids = "" .
  run ref/staffs.w ( input parparentproc
              , input "b-sel"
              , input 'C':U
              , input (if v-cntxt-db-num = 0 then ? else v-cntxt-db-num)
              , input 0
              , output cash-recids ) .
  if cash-recids = "" then do:
  end.
  else do:
    do ii = 1 to num-entries( cash-recids ) :
       FIND FIRST ub.staff no-lock WHERE
                    recid( ub.staff ) = integer( entry( ii, cash-recids ) ) .
       f-cashier = ub.staff.staff-code .
       display f-cashier with frame Dialog-Frame.
    end.
  end.
END.
ON CHOOSE OF b-open IN FRAME Dialog-Frame
DO:
  assign f-cashier .
  if f-cashier = ? or f-cashier <= 0
  then do :
    message "Сначала выберите кассира" view-as alert-box .
    return no-apply .
  end.
  define variable v-shift-num as integer no-undo .
  define variable v-ok as logical no-undo .
  run ref/tso-shift.w (input parparentproc,
                       output v-shift-num,
                       output v-ok) .
  if not v-ok
  then do :
    return no-apply .
  end.
  v-cmd-file-name = "tso-shift-open.xml" .
  v-command = substitute('<?xml version="1.0" encoding="UTF-8"?><control type="REQUEST">  <Command ctrl="ADD">    <CommType>tsoOperate</CommType>    <CommValue>shift_open</CommValue>    <CashierCode>&1</CashierCode>    <ShiftNumber>&2</ShiftNumber>  </Command></control>', string(f-cashier), string(v-shift-num)) .
  output to value (v-cmd-file-name) .
  put unformatted v-command skip .
  output close .
  if trim(rid-list) > ""
  then do :
    do ii = 1 to num-entries(rid-list) :
      find first tt-tso no-lock where recid(tt-tso) = integer( entry( ii, rid-list ) ) .
      if tt-tso.ShiftState = "Running" or tt-tso.ShiftState = "ОК" then next .
      v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-cmd-file-name
                        , tt-tso.tso-addr
                        , "tso-temp.xml") + chr(10)  .
      os-command silent value (v-command) .
    end.
  end.
  else do :
    for each tt-tso no-lock :
      if tt-tso.ShiftState = "Running" or tt-tso.ShiftState = "ОК" then next .
      v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-cmd-file-name
                        , tt-tso.tso-addr
                        , "tso-temp.xml") .
      os-command silent value (v-command) .
    end.
  end.
  run tso-send-cmd .
END.
ON CHOOSE OF b-close IN FRAME Dialog-Frame
DO:
  assign f-cashier .
  if f-cashier = ? or f-cashier <= 0
  then do :
    message "Сначала выберите кассира" view-as alert-box .
    return no-apply .
  end.
  v-cmd-file-name = "tso-shift-close.xml" .
  v-command = substitute('<?xml version="1.0" encoding="UTF-8"?><control type="REQUEST">  <Command ctrl="ADD">    <CommType>tsoOperate</CommType>    <CommValue>&1</CommValue>    <CashierCode>&2</CashierCode>  </Command></control>', "shift_close", string(f-cashier)) .
  output to value (v-cmd-file-name) .
  put unformatted v-command skip .
  output close .
  if trim(rid-list) > ""
  then do :
    do ii = 1 to num-entries(rid-list) :
      find first tt-tso no-lock where recid(tt-tso) = integer( entry( ii, rid-list ) ) .
      v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-cmd-file-name
                        , tt-tso.tso-addr
                        , "tso-temp.xml") .
      os-command silent value (v-command) .
    end.
  end.
  else do :
    for each tt-tso no-lock :
      v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-cmd-file-name
                        , tt-tso.tso-addr
                        , "tso-temp.xml") .
      os-command silent value (v-command) .
    end.
  end.
  run tso-send-cmd .
END.
ON CHOOSE OF b-start IN FRAME Dialog-Frame
DO:
  assign f-cashier .
  if f-cashier = ? or f-cashier <= 0
  then do :
    message "Сначала выберите кассира" view-as alert-box .
    return no-apply .
  end.
  v-cmd-file-name = "tso-shift-start.xml" .
  v-command = substitute('<?xml version="1.0" encoding="UTF-8"?><control type="REQUEST">  <Command ctrl="ADD">    <CommType>tsoOperate</CommType>    <CommValue>&1</CommValue>    <CashierCode>&2</CashierCode>  </Command></control>', "shift_start", string(f-cashier)) .
  output to value (v-cmd-file-name) .
  put unformatted v-command skip .
  output close .
  if trim(rid-list) > ""
  then do :
    do ii = 1 to num-entries(rid-list) :
      find first tt-tso no-lock where recid(tt-tso) = integer( entry( ii, rid-list ) ) .
      v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-cmd-file-name
                        , tt-tso.tso-addr
                        , "tso-temp.xml") .
      os-command silent value (v-command) .
    end.
  end.
  else do :
    for each tt-tso no-lock :
      v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-cmd-file-name
                        , tt-tso.tso-addr
                        , "tso-temp.xml") .
      os-command silent value (v-command) .
    end.
  end.
  run tso-send-cmd .
END.
ON CHOOSE OF b-stop IN FRAME Dialog-Frame
DO:
  assign f-cashier .
  if f-cashier = ? or f-cashier <= 0
  then do :
    message "Сначала выберите кассира" view-as alert-box .
    return no-apply .
  end.
  v-cmd-file-name = "tso-shift-stop.xml" .
  v-command = substitute('<?xml version="1.0" encoding="UTF-8"?><control type="REQUEST">  <Command ctrl="ADD">    <CommType>tsoOperate</CommType>    <CommValue>&1</CommValue>    <CashierCode>&2</CashierCode>  </Command></control>', "shift_stop", string(f-cashier)) .
  output to value (v-cmd-file-name) .
  put unformatted v-command skip .
  output close .
  if trim(rid-list) > ""
  then do :
    do ii = 1 to num-entries(rid-list) :
      find first tt-tso no-lock where recid(tt-tso) = integer( entry( ii, rid-list ) ) .
      v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-cmd-file-name
                        , tt-tso.tso-addr
                        , "tso-temp.xml") .
      os-command silent value (v-command) .
    end.
  end.
  else do :
    for each tt-tso no-lock :
      v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-cmd-file-name
                        , tt-tso.tso-addr
                        , "tso-temp.xml") .
      os-command silent value (v-command) .
    end.
  end.
  run tso-send-cmd .
END.
ON CHOOSE OF b-z-report IN FRAME Dialog-Frame
DO:
  assign f-cashier .
  if f-cashier = ? or f-cashier <= 0
  then do :
    message "Сначала выберите кассира" view-as alert-box .
    return no-apply .
  end.
  v-cmd-file-name = "tso-z-report.xml" .
  v-command = substitute('<?xml version="1.0" encoding="UTF-8"?><control type="REQUEST">  <Command ctrl="ADD">    <CommType>tsoOperate</CommType>    <CommValue>&1</CommValue>    <CashierCode>&2</CashierCode>  </Command></control>', "print_z_report", string(f-cashier)) .
  output to value (v-cmd-file-name) .
  put unformatted v-command skip .
  output close .
  if trim(rid-list) > ""
  then do :
    do ii = 1 to num-entries(rid-list) :
      find first tt-tso no-lock where recid(tt-tso) = integer( entry( ii, rid-list ) ) .
      v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-cmd-file-name
                        , tt-tso.tso-addr
                        , "tso-temp.xml") .
      os-command silent value (v-command) .
    end.
  end.
  else do :
    for each tt-tso no-lock :
      v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                        , curl-path
                        , v-cmd-file-name
                        , tt-tso.tso-addr
                        , "tso-temp.xml") .
      os-command silent value (v-command) .
    end.
  end.
  run tso-send-cmd .
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
define variable glog as logical no-undo .
if available tt-tso then  do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid7 as character no-undo .
define variable v-num-entry7 as integer   no-undo .
assign
  v-str-recid7 = trim( string( recid( tt-tso ) , "->>>>>>>>>>>9":U ) )
  v-num-entry7 = lookup( v-str-recid7 , rid-list )
.
if v-num-entry7 > 0 then do:
  assign
    entry( v-num-entry7, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid7
  .
end.
  glog = br-tso:refresh() .
  if last-event:function <> "MOUSE-SELECT-DBLCLICK"
  then do:
    glog = br-tso:select-next-row ().
    apply "iteration-changed" to br-tso in frame Dialog-Frame.
  end.
end.
apply "entry" to br-tso in frame Dialog-Frame.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  for each tt-tso no-lock :
    v-del-file = v-temp-dir + "\tsoresp_" + string(tt-tso.db-num) + "_" + string(tt-tso.obj-code) + "_" + string(tt-tso.tso-num) + ".xml" .
    v-del-file = search(v-del-file) .
    if v-del-file = ? or trim(v-del-file) = ""
    then next .
    os-delete value(v-del-file) .
    v-del-file = v-temp-dir + "\tsoreq_" + string(tt-tso.db-num) + "_" + string(tt-tso.obj-code) + "_" + string(tt-tso.tso-num) + ".bat" .
    v-del-file = search(v-del-file) .
    if v-del-file = ? or trim(v-del-file) = ""
    then next .
    os-delete value(v-del-file) .
  end.
  pause 1 .
  os-delete value (search(v-temp-dir)) recursive .
  assign
    log-exit = true
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
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
  v-temp-dir = "TSO_temp-cmd" .
  os-delete value (v-temp-dir) recursive no-error .
  os-create-dir value(v-temp-dir) .
  empty temp-table tt-pids .
  assign
    curl-path = search("exe/curl.exe")
  .
  v-post-file-name = "tso-stat.xml" .
  v-out-str = '<?xml version="1.0" encoding="UTF-8"?><control type="REQUEST">  <Status ctrl="READ">    <PumpStatus></PumpStatus>    <PosStatus></PosStatus>    <FiscalStatus></FiscalStatus>    <ShiftStatus></ShiftStatus>    <StatCashier></StatCashier>  </Status></control>' .
  output to value (v-post-file-name) .
  put unformatted v-out-str skip .
  output close .
  run init-tt .
  run tso-send-cmd .
  RUN enable_UI.
  open query br-tso for each tt-tso indexed-reposition .
  open query br-pump for each tt-pump indexed-reposition .
  do while not log-exit
  on error undo, return error
  :
    wait-for
      go of frame Dialog-Frame
      or close of this-procedure
      or value-changed of br-tso in frame Dialog-Frame
      or value-changed of br-pump in frame Dialog-Frame
      focus frame Dialog-Frame
      pause 1
    .
    v-time-str = string(time, "HH:MM:SS") .
    if substring(v-time-str, 7) = "01"
    then do :
      run tso-send-cmd .
    end.
    run tso-read-sts .
  end.
END.
RUN disable_UI.
procedure tso-send-cmd :
  define variable bat-file              as character    no-undo .
  define variable cmd                   as character    no-undo .
  define variable v-response-file-name  as character    no-undo .
  define variable v-pid                 as integer      no-undo .
  for each tt-tso no-lock :
    v-response-file-name = v-temp-dir + "\tsoresp_" + string(tt-tso.db-num) + "_" + string(tt-tso.obj-code) + "_" + string(tt-tso.tso-num) + ".xml" .
    cmd = substitute('"&1" -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                    , curl-path
                    , v-post-file-name
                    , tt-tso.tso-addr
                    , v-response-file-name) .
    bat-file = v-temp-dir + "\tsoreq_" + string(tt-tso.db-num) + "_" + string(tt-tso.obj-code) + "_" + string(tt-tso.tso-num) + ".bat" .
    output to value(bat-file) .
    put unformatted cmd skip .
    output close .
    run gbl/run-gpid.p (  input bat-file
                         ,input '':U
                         ,output v-pid).
    pause 1 no-message .
    rv = IsProcessRunning(v-pid).
    if rv >= 0 then do :
    end.
    else do :
      os-delete value(bat-file) .
    end.
    find first tt-pids no-lock where tt-pids.pid = v-pid no-error .
    if not available tt-pids
    then do :
      create tt-pids.
      tt-pids.pid = v-pid .
    end.
  end.
end procedure .
procedure tso-read-sts :
  define variable v-file    as character no-undo .
  for each tt-tso exclusive-lock :
    v-file = v-temp-dir + "\tsoresp_" + string(tt-tso.db-num) + "_" + string(tt-tso.obj-code) + "_" + string(tt-tso.tso-num) + ".xml" .
    v-file = search(v-file) .
    if v-file = ? or trim(v-file) = ""
    then next .
    file-info:file-name = v-file .
    if file-info:file-size = 0
    then do :
      tt-tso.FiscalStatus = "НЕ ОТВЕЧАЕТ" .
      os-delete value(v-file) .
      next.
    end.
    run parse-xml (input v-file,
                   input-output table tt-tso) .
    os-delete value(v-file) .
  end.
  define buffer buf_tt-tso for tt-tso .
  find first buf_tt-tso no-error .
  if available buf_tt-tso
  then
  br-tso:refresh () in frame Dialog-Frame .
  br-pump:refresh () in frame Dialog-Frame .
end procedure .
procedure parse-xml :
  define input parameter p-file as character .
  define input-output parameter table for tt-tso .
  CREATE X-DOCUMENT hDoc.
  CREATE X-NODEREF hRoot.
  hDoc:LOAD("file",p-file,FALSE).
  hDoc:GET-DOCUMENT-ELEMENT(hRoot).
  RUN GetChildren(hRoot, 1).
  DELETE OBJECT hDoc.
  DELETE OBJECT hRoot.
end procedure .
PROCEDURE GetChildren:
DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
DEFINE VARIABLE hText AS HANDLE NO-UNDO.
define variable client as character no-undo.
CREATE X-NODEREF hNoderef.
CREATE X-NODEREF hText .
REPEAT i = 1 TO hParent:NUM-CHILDREN:
    good = hParent:GET-CHILD(hNoderef,i).
    IF NOT good THEN
        LEAVE.
    IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
    hNoderef:GET-CHILD(hText, 1) no-error .
    IF hNoderef:NAME = "PumpStatus"
    then do :
      assign v-parsesub = "Pump" .
      find first tt-pump exclusive-lock where tt-pump.pump-code = integer(hNoderef:get-attribute("num"))
                                          and tt-pump.obj-type  = v-cntxt-obj-type
                                          and tt-pump.obj-code  = v-cntxt-obj-code
                                          no-error .
    end.
    IF hNoderef:NAME = "PosStatus" then assign tt-tso.PosStatus = hText:node-value no-error .
    IF hNoderef:NAME = "FiscalStatus" then assign v-parsesub = "Fiscal" .
    IF hNoderef:NAME = "ShiftState"
    then do :
      tt-tso.ShiftBegin = hNoderef:get-attribute("begin") no-error .
      tt-tso.ShiftNum   = integer(hNoderef:get-attribute("num")) no-error .
      tt-tso.ShiftState = hText:node-value no-error .
      if tt-tso.ShiftState = "Running" then tt-tso.ShiftState = "Запущена и открыта" .
      if tt-tso.ShiftState = "Unknown" then tt-tso.ShiftState = "?" .
      if tt-tso.ShiftState = "Closed"  then tt-tso.ShiftState = "Закрыта" .
      if tt-tso.ShiftState = "Stopped" then tt-tso.ShiftState = "Остановлена и открыта" .
    end.
    IF hNoderef:NAME = "StatCashier" then assign tt-tso.CashierNum = integer(hText:node-value) no-error .
    IF hNoderef:NAME = "State"
    then do :
      case v-parsesub :
        when "Pump"
        then do :
          if available tt-pump
          then do :
            tt-pump.status_ = hText:node-value no-error .
            if tt-pump.status_ = 'Idle' then tt-pump.status_ = 'Незанята' .
            if tt-pump.status_ = 'Unreacable' then tt-pump.status_ = 'Недоступна' .
            if tt-pump.status_ = 'Inoperative' then tt-pump.status_ = 'Не работает' .
            if tt-pump.status_ = 'Closed' then tt-pump.status_ = 'Закрыта' .
            if tt-pump.status_ = 'Calling' then tt-pump.status_ = 'Вызов' .
            if tt-pump.status_ = 'Authorized' then tt-pump.status_ = 'Авторизована' .
            if tt-pump.status_ = 'Started' then tt-pump.status_ = 'Запущена' .
            if tt-pump.status_ = 'Started_susp' then tt-pump.status_ = 'Приостановлена' .
            if tt-pump.status_ = 'Fueling' then tt-pump.status_ = 'Заправка' .
            if tt-pump.status_ = 'Fueling_susp' then tt-pump.status_ = 'Заправка приостановлена' .
          end.
        end.
        when "Fiscal"
        then do :
          tt-tso.FiscalStatus = hText:node-value no-error .
        end.
      end case .
    end.
    IF hNoderef:NAME = "ErrorText"
    and v-parsesub = "Fiscal"
    and tt-tso.FiscalStatus = "Error"
    then do :
      tt-tso.FiscalStatus = hText:node-value no-error .
    end.
    IF hNoderef:NAME = "LastZreportDate" then assign tt-tso.zReportDate = hText:node-value no-error .
    IF hNoderef:NAME = "QueueSize" then assign tt-tso.FiscalQueue = integer(hText:node-value) no-error .
    IF hNoderef:NAME = "NumTrans"
    and available tt-pump
    then assign tt-pump.numTr = integer(hText:node-value) no-error .
    RUN GetChildren(hNoderef, (level + 1)).
END.
DELETE OBJECT hNoderef.
DELETE OBJECT hText.
END PROCEDURE.
procedure init-tt :
  CASE parref-mode:
    when 'все':U then do:
      for each buf_cash-desk no-lock where buf_cash-desk.device-kind = 2
                                       and buf_cash-desk.is-del   = no :
          create tt-tso.
          assign
            tt-tso.db-num       = buf_cash-desk.db-num
            tt-tso.obj-code     = buf_cash-desk.obj-code
            tt-tso.tso-num      = buf_cash-desk.cash-num
            tt-tso.tso-addr     = replace(buf_cash-desk.addr-path, chr(4), '://')
          .
        end.
      for each buf_pump no-lock :
        create tt-pump .
        assign
          tt-pump.pump-code = buf_pump.pump-code
          tt-pump.obj-type  = buf_pump.obj-type
          tt-pump.obj-code  = buf_pump.obj-code
        .
      end.
    end.
    when 'объект':U then do:
        for each buf_cash-desk no-lock where buf_cash-desk.obj-code = v-cntxt-obj-code
                                           and buf_cash-desk.is-del   = no
                                           and buf_cash-desk.device-kind = 2:
          create tt-tso.
          assign
            tt-tso.db-num       = buf_cash-desk.db-num
            tt-tso.obj-code     = buf_cash-desk.obj-code
            tt-tso.tso-num      = buf_cash-desk.cash-num
            tt-tso.tso-addr     = replace(buf_cash-desk.addr-path, chr(4), '://')
          .
        end.
      for each buf_pump no-lock where buf_pump.obj-type = v-cntxt-obj-type
                                  and buf_pump.obj-code = v-cntxt-obj-code :
        create tt-pump .
        assign
          tt-pump.pump-code = buf_pump.pump-code
          tt-pump.obj-type  = buf_pump.obj-type
          tt-pump.obj-code  = buf_pump.obj-code
        .
      end.
    end.
    when "db":U then do:
      for each buf_cash-desk no-lock where buf_cash-desk.db-num   = v-cntxt-db-num
                                           and buf_cash-desk.is-del   = no
                                           and buf_cash-desk.device-kind = 2
                                           :
          create tt-tso.
          assign
            tt-tso.db-num       = buf_cash-desk.db-num
            tt-tso.obj-code     = buf_cash-desk.obj-code
            tt-tso.tso-num      = buf_cash-desk.cash-num
            tt-tso.tso-addr     = replace(buf_cash-desk.addr-path, chr(4), '://')
          .
      end.
      for each buf_clients no-lock where buf_clients.db-num = v-cntxt-db-num :
        for each buf_pump no-lock where buf_pump.obj-type = buf_clients.obj-type
                                    and buf_pump.obj-code = buf_clients.obj-code :
          create tt-pump .
          assign
            tt-pump.pump-code = buf_pump.pump-code
            tt-pump.obj-type  = buf_pump.obj-type
            tt-pump.obj-code  = buf_pump.obj-code
          .
        end.
      end.
    end.
  END CASE.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-exit b-stop b-start b-close b-open br-tso br-pump b-z-report
         b-cashier b-mark
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
