block-level on error undo, throw.
define input  parameter parparentproc   as widget-handle         no-undo.
define input  parameter p-parent-handle as widget-handle         no-undo.
define input  parameter p-log-handle    as handle                no-undo.
define input  parameter p-log-file-name as character             no-undo.
define input  parameter p-obj-type      like ub.clients.obj-type no-undo.
define input  parameter p-obj-code      like ub.clients.obj-code no-undo.
define output parameter p-ok            as logical               no-undo.
define variable vss-revision    as character no-undo init "$Revision: 75e9ec6019c5, 3128, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Чт сен 15 14:05:53 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-chk-Report.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/get-chk-Report.p $":U .
define variable vss-description as character no-undo init "Обмен данными с кассой по кассовым отчетам".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define variable vss-revision5    as character no-undo init "$Revision:$":U .
define variable vss-author5      as character no-undo init "$Author:$":U .
define variable vss-date5        as character no-undo init "$Date:$":U .
define variable vss-workfile5    as character no-undo init "$Workfile:$":U .
define variable vss-archive5     as character no-undo init "$Archive:$":U .
define variable vss-description5 as character no-undo init "Работа С сокетом".
procedure PutMesAsunc:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext, yes)  .
end.
procedure PutMesAsuncNoTime:
    define input  parameter Itext as character no-undo.
    define variable vflag as logical no-undo.
    Publish "WriteLogAsunc" (Itext,no)  .
end.
procedure PutStatAsunc:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no) .
     run
    PutMesAsunc (itext).
end.
procedure PutStatAsuncNoTime:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,no)  .
     run
    PutMesAsuncNoTime (itext).
end.
procedure PutStatAsuncAdd:
    define input  parameter Itext as character no-undo.
    Publish "PutStatAsunc" (Itext,yes)  .
end.
procedure PutFileLogAsunc:
    define input  parameter IFile as character no-undo.
    Publish "PutFileLogAsunc" (ifile)  .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable mHSocket       as handle      no-undo.
define variable mWebRespHead   as longchar    no-undo.
define variable mWebResp       as longchar    no-undo.
define variable mWebRespMptr   as memptr      no-undo.
define variable OerrMsg        as character   no-undo.
define variable mFileLogSocet  as character   no-undo.
define variable mReturnHttp    as logical     no-undo.
define variable mAddTimeOut    as logical     no-undo init yes.
define variable mSocetBegTime  as datetime-tz no-undo.
define variable mSocetEndTime  as dec         no-undo.
define variable mWriteRespFile as character   no-undo.
define variable mTypeResponse  as character   no-undo init "POST".
publish "getSocetLog" (output mFileLogSocet).
if
   (   mFileLogSocet eq ""
    or mFileLogSocet eq ?)
   and session:debug-alert
then
   mFileLogSocet = "socet.log".
procedure ConectSocet:
   define input  parameter iHost       as character no-undo.
   define input  parameter iPort       as character no-undo.
   define input  parameter iUrl        as character no-undo.
   define input  parameter iPostData   as longchar  no-undo.
   define input  parameter iReturnType as character no-undo.
   define input  parameter iTimeOut    as decimal   no-undo.
   define input  parameter iSilent     as logical   no-undo.
   define input  parameter iTextWait   as character no-undo.
   mWaitFramTextBeg = iTextWait.
   run SendReqSocet (iHost, iPort, iUrl, iPostData, iReturnType, 'getResponse').
   if OerrMsg eq ""
   then
      run waitrespsocet (iTimeOut, iSilent, iTextWait).
   mSocetEndTime = (now - mSocetBegTime) / 1000.
end.
procedure SendReqSocet:
   define input  parameter iHost            as character no-undo.
   define input  parameter iPort            as character no-undo.
   define input  parameter iUrl             as character no-undo.
   define input  parameter iPostData        as longchar  no-undo.
   define input  parameter iReturnType      as character no-undo.
   define input  parameter iProcGetResponse as character no-undo.
   mSocetBegTime = now.
   run writeLogSocet in this-procedure (substitute("Подключаемся к адресу &1 по порту &2",iHost,iPort )).
   assign
      mWebResp         = ""
      mWebResphead     = ""
      OerrMsg          = ""
      mReturnHttp      = iReturnType eq "xml" or iReturnType eq "http" or iReturnType eq "yes"
      iProcGetResponse = "getResponse"  when iProcGetResponse eq ? or iProcGetResponse eq ""
   .
   define variable vPostData as longchar                       no-undo.
   if    iHost eq ""
      or iHost eq ?
   then do:
      oErrMsg = substitute("Не задан host &1 или port &2.", ihost ,iport).
      run writeLogSocet in this-procedure (oErrMsg).
      return oErrMsg.
   end.
   run waitfram-show (substitute("Подключаемся к адресу &1 по порту &2",iHost,iPort )).
   create socket mHSocket.
   mHSocket:connect('-H ' + iHost + ' -S ' + iPort) no-error.
   if mHSocket:connected() = false
   then do:
      run waitfram-hide .
      oErrMsg = substitute( "Не удалось установить соединение: &1" , error-status:get-message(1)).
      run writeLogSocet in this-procedure (oErrMsg).
      delete object mHSocket.
      return oErrMsg.
   end.
   run waitfram-show ("Отправка данных").
   mHSocket:set-read-response-procedure(iProcGetResponse).
   run PostRequest (
    input iUrl,
    input iHost + ":" + iPort,
    input iPostData
    ).
    run waitfram-hide .
end.
procedure WaitRespSocet:
   define input  parameter iTimeOut   as decimal   no-undo.
   define input  parameter iSilent    as logical   no-undo.
   define input  parameter iTextWait  as character no-undo.
   if    not valid-handle (mHSocket )
   then do:
      run writeLogSocet in this-procedure (substitute("Потерян объект соединения")).
      return "End connected".
   end.
   if mHSocket:connected() = false
   then do:
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной WaitRespSocet")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   mWaitFramView = if iSilent ne yes then yes else no.
   mWaitFramTextBeg = iTextWait.
   mWaitFramTimeOut = iTimeOut.
   mWaitFramTextEnd = "".
   mWaitFramStop = no.
   if mAddTimeOut
   then do:
      mWaitFramTimeOut = 300.
      run writeLogSocet in this-procedure (substitute ("Таймаут увеличен до &1 при уcтановке соодинения",mWaitFramTimeOut)).
   end.
   run writeLogSocet in this-procedure (substitute("Ожидаем ответ TimeOut &1 сек.",iTimeOut )).
   subscribe   to "WaitFramStop" anywhere run-procedure "WaitRespTestStop".
   run WaitFramWaitFor(1).
   unsubscribe "WaitFramStop".
   if mWaitFramStopUser
   then do:
      OerrMsg = substitute("Операция прервана пользователем." ).
      run writeLogSocet in this-procedure (OerrMsg).
   end.
   else if mWaitFramStopTimeOut
   then do:
      OerrMsg = substitute("Привышено время ожидания &1 сек. Ответ не получен.",iTimeOut ).
      run writeLogSocet in this-procedure (OerrMsg).
   end.
   run waitfram-hide .
   mHSocket:disconnect() no-error.
   delete object mHSocket.
end.
procedure WaitRespTestStop:
   if mWaitFramStopTimeOut
   then
      return.
   if     (mWebResp ne ""
       and mWebResp ne ?)
   then do:
      mWaitFramStop = yes.
      return.
   end.
   else if mHSocket:connected() = false
   then do:
      mWaitFramStop = yes.
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной WaitRespTestStop")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   wait-for read-response of mHSocket pause 0.001.
end.
procedure PostRequest:
   define input parameter iPostUrl  as char.
   define input parameter iPostHost as char.
   define input parameter iPostData as longchar.
   define variable vCRequest      as longchar.
   define variable vMRequest       as memptr.
   if iPostUrl ne ?
   then do:
      vCRequest =substitute(
      '&5 /&2 HTTP/1.1&1'                                   +
      'Host: &4&1'                                           +
      'User-Agent: Apache-HttpClient/4.1.1 (java 1.5)&1'    +
      'Accept: */*&1' +
      'Content-Type: text/xml&1'               +
      'Content-Length: &3&1'                                  +
      '&1'
      ,
      chr(13) + chr(10),
      iPostUrl,
      length(iPostData),
      iPostHost,
      mTypeResponse) + iPostData.
   end.
   else
      vCRequest = iPostData.
   run writeLogSocet in this-procedure (substitute("Отправляем запрос &1.",chr(13) + chr(10) )).
   run writeLogSocet in this-procedure (vCRequest).
   SET-SIZE(vMRequest)            = 0.
   SET-SIZE(vMRequest)            = length(vCRequest) + 1.
   SET-BYTE-ORDER(vMRequest)      = big-endian.
   PUT-STRING(vMRequest,1)        = vCRequest .
   if mHSocket:connected() = false then
   do:
      run writeLogSocet in this-procedure ("Соединение было разорвано другой стороной getResponse").
      oErrMsg = "Not connected".
      delete object mHSocket no-error.
      return oErrMsg.
   end.
   mHSocket:write(vMRequest, 1, length(vCRequest)).
   run writeLogSocet in this-procedure ("Запрос отправлен.").
end procedure.
function hex-to-int returns integer (
  input p-hex-code  as character  ).
  define variable v-int-code as integer   no-undo .
  define variable v-ind      as integer   no-undo .
  define variable v-digit    as integer   no-undo .
  define variable v-letter   as character no-undo .
  do v-ind = 1 to length(p-hex-code)
  :
    assign
      v-letter = caps(substring(p-hex-code, v-ind, 1))
    .
    assign
      v-digit = index('123456789ABCDEF':u, v-letter)
    .
    assign
      v-int-code = v-int-code * 16 + v-digit
    .
  end.
  return v-int-code .
end function .
procedure getResponse:
   define variable vFlagTag     as logical          no-undo init no.
   define variable vResponse    as memptr           no-undo.
   define variable vCnt         as int64            no-undo.
   define variable vMessage     as longchar         no-undo.
   define variable v-cont-length as int64 no-undo.
   define variable vi           as integer no-undo.
   define variable v-hd-line    as character no-undo.
   define variable level        as integer no-undo initial 2.
   repeat while program-name(level) <> ?:
     if program-name(level) = program-name(1) then do:
       run writeLogSocet in this-procedure (substitute("Повторный вызов getResponse.")).
       return "".
     end.
     level = level + 1.
   end.
   if mHSocket:connected() = false then
   do:
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной getResponse")).
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   if mAddTimeOut
   then do:
      mWaitFramTimeOut = 1000.
      run writeLogSocet in this-procedure (substitute ("Таймаут увеличен до &1 при получении ответа",mWaitFramTimeOut)).
   end.
   run writeLogSocet in this-procedure (substitute("Получаем ответ")).
   mWaitFramTextEnd = "Получаем ответ".
   define variable vWaitProcEvent as logical no-undo.
   vWaitProcEvent = mWaitProcEvent.
   mWaitProcEvent = no.
   run WaitFramRunPause (?).
   define variable vByte as int64 no-undo.
   define variable vNextMese as int64 no-undo init 100000.
   define variable VFlag as logical no-undo init ? .
   mWaitFramStop = no.
   mWaitFramStopTimeOut = no.
   block-wait:
   do while mHSocket:get-bytes-available() > 0:
      VFlag = no.
      define variable vNumByte as integer no-undo.
      vNumByte =   mHSocket:get-bytes-available().
      if vNumByte > 30000 then vNumByte = 30000.
      SET-SIZE(vResponse) = vNumByte + 1.
      SET-BYTE-ORDER(vResponse) = big-endian.
      mHSocket:read(vResponse,1,vNumByte).
      vMessage = vMessage + GET-STRING(vResponse,1).
      if  mReturnHTTp
      then do:
         vCnt = index(vMessage,chr(13) + chr(10) + chr(13) + chr(10)).
         if vCnt > 0
         then do:
            mReturnHttp = no.
            mWebResphead = substring (vMessage,1,vCnt).
            vMessage     = substring (vMessage,vCnt + 4).
            mWebResphead = replace (mWebResphead,";",chr(13) + chr(10)).
            do vi = 1 to num-entries(mWebResphead,chr(13) + chr(10)):
               v-hd-line = trim(entry(vi,mWebResphead,chr(13) + chr(10))).
               if  v-hd-line  begins "Content-Length"  then  do:
                  v-cont-length = INT(trim(substring(v-hd-line,16,length(v-hd-line)))).
               end.
               else if v-hd-line  begins "Transfer-Encoding"
               then do :
                  define variable vChunked as logical no-undo.
                  vchunked = index(v-hd-line,"chunked",19) > 0.
               end.
            end.
         end.
      end.
      vByte = vByte + vNumByte.
      SET-SIZE(vResponse) = 0.
      if v-cont-length > 0 and length (vMessage) >= v-cont-length
      then
         leave block-wait.
      if not mHSocket:get-bytes-available() > 0
      then do:
         VFlag = yes.
         run WaitFramRunPause (?).
         run gbl/pause.p (1000) .
      end.
      else if vByte > vNextMese
      then do:
         vNextMese = vNextMese + 100000.
         mWaitFramTextEnd = substitute ("Получаем ответ прочитано &1 байт ",vByte) .
         run WaitFramRunPause (?).
      end.
      if mWaitFramStopTimeOut
      then do:
         mWebResp = "".
         leave block-wait.
      end.
   end.
   if VFlag ne false
   then
      run writeLogSocet in this-procedure (substitute ("Завершена обработка &1",If VFlag eq  yes then " 0 байт за последнию секунду" else " пустой ответ(((")).
   mWaitFramStop = yes.
   run writeLogSocet         in this-procedure ("Получен ответ").
   run writeLogSocetOnlyText in this-procedure (mWebResphead).
   run writeLogSocetOnlyText in this-procedure (substitute("&1&2&1&2",chr(13) , chr(10) )).
   run writeLogSocetOnlyText in this-procedure (vMessage).
   run writeLogSocetOnlyText in this-procedure (substitute("&1&2",chr(13) , chr(10) )).
   mHSocket:disconnect() no-error.
   if v-cont-length > 0
   then
      mWebResp = substring (vMessage,1,v-cont-length).
   else if vChunked
   then do:
      define variable vByteCopy as int64 no-undo init 1.
      Block-Copy:
      do while length(vMessage) > 0:
         vByteCopy = 1.
         vCnt = index (vMessage,chr(13) + chr(10)) - 1.
         vByteCopy = vByteCopy +  vCnt + 2.
         v-cont-length = hex-to-int(string(substring (vMessage,1,vCnt))).
         if v-cont-length eq 0
         then
            leave Block-copy.
         mWebResp = mWebResp + substring (vMessage,vByteCopy,  v-cont-length).
         vByteCopy = vByteCopy + v-cont-length + 2.
         vMessage = substring  (vMessage,vByteCopy).
      end.
      run writeLogSocet         in this-procedure ("Заголовок").
      run writeLogSocetOnlyText in this-procedure (mWebResphead).
      run writeLogSocet         in this-procedure ("Тело ответа").
      run writeLogSocetOnlyText in this-procedure (mWebResp).
     run writeLogSocetOnlyText in this-procedure (substitute("&1&2",chr(13) , chr(10) )).
   end.
   else
      mWebResp = vMessage.
   mWaitProcEvent = vWaitProcEvent.
   mSocetEndTime = (now - mSocetBegTime) / 1000.
   copy-lob mWebResp to mWebRespMptr.
   if     mWriteRespFile ne ""
      and mWriteRespFile ne ?
   then
        run gbl/fileapnd.p
             ( mWriteRespFile
             , mWebResp + chr(13) + chr(10)
             ,input 10
             ) no-error .
end procedure.
procedure writeLogSocet:
   define input  parameter itext as longchar no-undo.
   if mFileLogSocet eq "Async"
   then
      run PutMesAsunc(itext).
   else if     mFileLogSocet ne ?
           and mFileLogSocet ne ""
   then do:
      run gbl/fileapnd.p
          ( mFileLogSocet
          , substitute("&1 &2 ", string(today), string(time, "HH:MM:SS"))
          ,input 10
          ) no-error .
      run writeLogSocetOnlyText(itext).
      run gbl/fileapnd.p
          ( mFileLogSocet
          , substitute(" &1&2", chr(13) , chr(10))
          ,input 10
          ) no-error .
   end.
end.
procedure writeLogSocetOnlyText:
   define input  parameter itext as longchar no-undo.
   if mFileLogSocet eq "Async"
   then
      run PutMesAsunc(itext).
   else if     mFileLogSocet ne ?
           and mFileLogSocet ne ""
   then do:
      if length(itext) > 32000
      then
         copy-lob
   from object itext
   to file mFileLogSocet append
   no-error
   .
      else
      run gbl/fileapnd.p
          ( mFileLogSocet
          , string(itext)
          ,input 10
          ) no-error .
   end.
end.
procedure Disconect:
   mHSocket:disconnect() no-error.
   delete object mHSocket no-error.
end.
define variable Mreq as longchar no-undo.
define variable m-time          as character no-undo.
function fConvetDate returns datetime
    (input iTStamp as character):
    define variable vDateTime as datetime no-undo.
    define variable vDate     as date     no-undo.
    define variable vDays     as int64    no-undo.
    define variable vSec      as integer  no-undo.
    vDays = truncate(int64(iTStamp) / 3600 / 24, 0).
    vDate = date("01/01/1970") + vDays.
    return vDate.
end function.
function fConvetDateTime returns datetime
    (input iTStamp as character):
    define variable vDateTime as datetime no-undo.
    define variable vDate     as date     no-undo.
    define variable vDays     as int64    no-undo.
    define variable vSec      as integer  no-undo.
    vDays = truncate(int64(iTStamp) / 3600 / 24, 0).
    vDate = date("01/01/1970") + vDays.
    vSec = (int64(iTStamp) - vDays * 3600 * 24).
    vDateTime = datetime(string(vDate) + " " + string(vSec, "HH:MM:SS")).
    return vDateTime.
end function.
define temp-table tt-chk-report-head no-undo like chk-slip-head .
define temp-table tt-one-chk-report-head no-undo like chk-slip-head .
define temp-table tt-chk-report-string no-undo like chk-slip-string .
define variable v-tth                as handle    no-undo.
define variable v-Param-Type         as character no-undo.
define variable out                  as character no-undo.
define variable in_                  as character no-undo.
define variable glog                 as logical   no-undo.
define variable v-value-character    as character no-undo.
define variable v-value-date         as date      no-undo.
define variable v-value-decimal      as decimal   no-undo.
define variable v-value-integer      as integer   no-undo.
define variable v-value-logical      as logical   no-undo.
define variable v-no-get-chk         as logical   no-undo.
define variable m-obj-code           as integer   no-undo.
define variable m-cash-num           as integer   no-undo.
define variable m-pos-type           as character no-undo.
define variable m-post-file-name     as character no-undo.
define variable m-response-file-name as character no-undo.
define variable m-xml-file-name      as character no-undo.
define variable m-obj-list           as character no-undo.
define variable m-correspondent      as character no-undo.
define variable m-timestamp          as character no-undo.
define variable Check-ctrl           as character no-undo.
define variable ErrorMessage         as character no-undo.
define variable mElement             as character no-undo.
define variable mCount               as int64     no-undo.
define variable m-err-msg            as character no-undo.
define variable m-textCheq           as longchar  no-undo.
define variable m-ParamJson          as longchar  no-undo.
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'get-chk':U
    ,input  'no-get-chk':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
v-no-get-chk = v-value-logical.
if v-no-get-chk then
do:
    m-err-msg = substitute( "Согласно настроечным параметрам НЕТ приема отчетов в &1&2!!!&3"
        ,p-obj-type
        ,p-obj-code
        ,chr(10)
        ).
    return error m-err-msg.
end.
run verify-ini-entry("in":U,
    substitute("kassa-&1":U, 'IBM-XML':U),
    substitute ("отсутствует путь к подкаталогу out" + chr(10) + "для отсылки информации на POS &1", 'IBM-XML':U),
    yes,
    output in_) no-error.
if error-status:error or in_ = ? then return error return-value .
RUN verify-file in this-procedure
    ( in_
    , substitute("Не найден каталог &1 параметр in, секция [kassa-&2] ini-файла", in_, 'IBM-XML':U)
    ,yes
    ,output glog) no-error.
if error-status:error or not glog then return error return-value .
run verify-ini-entry("out":U,
    substitute("kassa-&1":U, 'IBM-XML':U),
    substitute ("отсутствует путь к подкаталогу out" + chr(10) + "для отсылки информации на POS &1", 'IBM-XML':U),
    yes,
    output out) no-error.
if error-status:error or out = ? then return error return-value .
run verify-file in this-procedure
    ( out
    , substitute("Не найден каталог &1 параметр out, секция [kassa-&2] ini-файла", out, 'IBM-XML':U)
    , yes
    ,output glog) no-error.
if error-status:error or not glog then return error return-value .
run gbl/dir-cre.p ( input in_ + 'Report\') no-error .
if error-status:error then
do:
    return error substitute(
        "!!!Каталог &1 не найден&2" +
        "и/или попытка его создания не удалась:&2&3 &4"
        , in_ + 'Report\'
        , chr(10)
        , error-status:get-message(1)
        , return-value
        ).
end.
run gbl/dir-cre.p ( input out + 'Report\') no-error .
if error-status:error then
do:
    return error substitute(
        "!!!Каталог &1 не найден&2" +
        "и/или попытка его создания не удалась:&2&3 &4"
        , out + 'Report\'
        , chr(10)
        , error-status:get-message(1)
        , return-value
        ).
end.
run MainProc no-error.
if error-status:error then
do:
    return error return-value.
end.
procedure MainProc:
    define buffer cash-desk for cash-desk.
    define variable vMsg as character no-undo.
    _cash-desk:
    FOR EACH cash-desk WHERE
        cash-desk.db-num   = g#db-num
        and cash-desk.obj-code = p-obj-code
        and cash-desk.pos-type = 'IBM-XML':U
        and cash-desk.cash-on  = yes
        no-lock:
        empty temp-table tt-chk-report-head.
        empty temp-table tt-chk-report-string.
        assign
            m-xml-file-name      = substring(string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
            m-obj-list           = 'маг':U + "_" + string(cash-desk.obj-code)
            m-correspondent      = ("касса_" + string(cash-desk.cash-num) + "_" + m-obj-list)
            m-post-file-name     = replace(out + "Report/" + m-xml-file-name, "/", "\" ) + ".xml":U
            m-response-file-name = replace(in_ + "Report/" + m-xml-file-name, "/", "\" ) + ".xml":U
            m-obj-code           = cash-desk.obj-code
            m-pos-type           = cash-desk.pos-type
            m-cash-num           = cash-desk.cash-num
            mCount               = 0
            .
        run pGetLastTStamp(m-obj-code,
            m-pos-type,
            m-cash-num,
            output m-timestamp).
        m-time = m-timestamp .
        run write-log-and-file in p-log-handle (
            input 1
            , input p-log-file-name
            , input 1
            , input substitute('Получаем данные кассовых отчетов с кассы &1://&2'
            ,entry(1, cash-desk.addr-path, chr(4))
            ,entry(2, cash-desk.addr-path, chr(4))
            )
            ).
        run SaxWriter no-error.
        if error-status:error then
        do:
            return error return-value.
        end.
        mWriteRespFile = m-response-file-name + "sckt".
        run ConectSocet (entry(1,entry(2, cash-desk.addr-path, chr(4)),":"),
            entry(2,entry(2, cash-desk.addr-path, chr(4)),":"),
            "",
            Mreq,
            "xml",
            300,
            no,
            substitute ("Чтение данных кассовых отчетов с кассы &1. ",entry(2, cash-desk.addr-path, chr(4)))
            ).
        if    mWebResp eq ""
            or OerrMsg  ne ""
            then
        do:
            run write-log-and-file in p-log-handle (
                input 1
                , input p-log-file-name
                , input 1
                , input substitute( "!!!Касса &1 маг&2 не ответила:&3&4 &5"
                ,cash-desk.cash-num
                ,cash-desk.obj-code
                , chr(10)
                , OerrMsg
                )
                ).
            nEXT _cash-desk.
        end.
        else
        do:
            run write-log-and-file in p-log-handle (
                input 1
                , input p-log-file-name
                , input 1
                , input substitute('Время ожидания выполнения задания на кассе - &1 c',
                mSocetEndTime
                )
                ).
        end.
        run SaxReader no-error.
        if ErrorMessage <> "" or error-status:error then
        do:
            return error ErrorMessage + " " + return-value.
        end.
        do transaction:
            for each tt-chk-report-head where
                tt-chk-report-head.cash-num = m-cash-num:
                find first chk-slip-head where
                    chk-slip-head.db-num       = tt-chk-report-head.db-num
                    and chk-slip-head.ID       = tt-chk-report-head.ID
                    and chk-slip-head.CheckID  = tt-chk-report-head.CheckID
                    and chk-slip-head.RRN      = tt-chk-report-head.RRN
                    no-lock no-error.
                if not avail chk-slip-head then
                do:
                    create chk-slip-head .
                    buffer-copy tt-chk-report-head to chk-slip-head .
                    for each tt-chk-report-string no-lock where
                        tt-chk-report-string.db-num  = tt-chk-report-head.db-num
                        and tt-chk-report-string.ID      = tt-chk-report-head.ID
                        and tt-chk-report-string.CheckID = tt-chk-report-head.CheckID
                        and tt-chk-report-string.RRN     = tt-chk-report-head.RRN
                        :
                        find first chk-slip-string where
                            chk-slip-string.db-num    = tt-chk-report-string.db-num
                            and chk-slip-string.ID        = tt-chk-report-string.ID
                            and chk-slip-string.CheckID   = tt-chk-report-string.CheckID
                            and chk-slip-string.RRN       = tt-chk-report-string.RRN
                            and chk-slip-string.str-num   = tt-chk-report-string.str-num
                            no-lock no-error.
                        if not avail chk-slip-string then
                        do:
                            create chk-slip-string .
                            buffer-copy tt-chk-report-string to chk-slip-string .
                        end .
                    end .
                    mCount = mCount + 1.
                end.
            end.
            vMsg = "Загружено ФО: " + string(mCount).
            run write-log-and-file in p-log-handle (
                input 1
                , input p-log-file-name
                , input 1
                , input vMsg).
            p-ok = true.
            find last chk-slip-head no-lock where chk-slip-head.cash-num = cash-desk.cash-num and
                chk-slip-head.obj-code = cash-desk.obj-code and
                chk-slip-head.db-num = cash-desk.db-num and
                chk-slip-head.is-report = 1 no-error .
            define variable v-value as character no-undo .
            define variable v-time1 as character no-undo .
            define variable v-time  as character no-undo .
            v-time1 = entry(2,string(chk-slip-head.slip-dt)," ") .
            v-time =  entry(1,v-time1,".") .
            v-value = string(YEAR(date(chk-slip-head.slip-dt)), "9999":U) + "-":U +
                string(Month(date(chk-slip-head.slip-dt)), "99":U) + "-":U +
                string(DAY(date(chk-slip-head.slip-dt)), "99":U) .
  run cd-attr-write in this-procedure (
                                         input cash-desk.db-num
                                        ,input cash-desk.obj-code
                                        ,input cash-desk.pos-type
                                        ,input cash-desk.cash-num
                                        ,input (if cash-desk.pos-type = 'IBM-XML':U
                                                then 'IBM-XML_operative':U
                                                else if cash-desk.pos-type = 'Autotank':U
                                                then 'AUTOTANK_operative':U else "")
                                        ,input (if cash-desk.pos-type = 'IBM-XML':U
                                                then 'last-report-params':U
                                                else if cash-desk.pos-type = 'Autotank':U
                                                then 'last-report-params':U
                                                else "")
                                        ,input (v-value + chr(32) + v-time
                                             +  (if cash-desk.pos-type = 'IBM-XML':U
                                                 or cash-desk.pos-type = 'Autotank':U
                                               then (chr(32) + string(chk-slip-head.CashShiftNum) )
                                               else  "":U)
                                               )
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input no
                                        ) no-error.
end.
end.
  define variable slip-dt as character no-undo .
  define buffer buf_chk-slip-head for ub.chk-slip-head .
  if m-time = "0" then slip-dt = string(01/01/1900) . else slip-dt = string(fConvetDateTime(m-time)) .
          find first buf_chk-slip-head no-lock where buf_chk-slip-head.db-num = g#db-num and
          buf_chk-slip-head.obj-code = p-obj-code and
          buf_chk-slip-head.is-report = 1 and
          buf_chk-slip-head.slip-dt > datetime(slip-dt) no-error .
          if available (buf_chk-slip-head) then do:
          run bge\send1cerp.p (parparentproc,
            this-procedure,
            this-procedure,
            "chkSlipHead",
            (buffer buf_chk-slip-head:handle),
            ?,
            ?) no-error.
        if  error-status:error then
        do:
            message return-value
                view-as alert-box.
            return .
        end.
        end.
end procedure.
procedure pGetLastTStamp:
    define input  parameter p-obj-code as integer   no-undo.
    define input  parameter p-pos-type as character no-undo.
    define input  parameter p-cash-num as integer   no-undo.
    define output parameter oTStamp    as character no-undo.
    define buffer chk-slip-head for chk-slip-head.
    define variable v-last-date      as date    no-undo .
    define variable v-last-time      as integer no-undo .
    define variable v-last-shift-num as integer no-undo .
    define variable v-last-z-count   as integer no-undo .
    define variable v-last-chk-num   as integer no-undo .
    run get-last-report-params in this-procedure ( input g#db-num
        ,input p-obj-code
        ,input p-pos-type
        ,input p-cash-num
        ,output v-last-date
        ,output v-last-time
        ,output v-last-shift-num
        ) no-error.
    if v-last-date <> ? then
        oTStamp = string( ( v-last-date - date( "01/01/1970" ) ) * 24 * 3600 + v-last-time - Timezone * 60 - 1 * 60 * 60, ">>>>>>>>>9" ).
    else
        oTStamp = "0".
end procedure.
procedure SaxWriter:
    define variable hSAXWriter as handle no-undo.
    create sax-writer hSAXWriter.
    hSAXWriter:set-output-destination("longchar", Mreq) no-error.
    hSAXWriter:formatted = true.
    hSAXWriter:encoding = "windows-1251".
    hSAXWriter:start-document() no-error.
    hSAXWriter:start-element("reports") no-error.
    hSAXWriter:insert-attribute("type",   "REQUEST")       no-error.
    hSAXWriter:insert-attribute("id",     m-xml-file-name) no-error.
    hSAXWriter:insert-attribute("from",   m-obj-list)      no-error.
    hSAXWriter:insert-attribute("to",     m-correspondent) no-error.
    hSAXWriter:insert-attribute("tstamp", m-timestamp)     no-error.
    hSAXWriter:end-element("reports") no-error.
    hSAXWriter:end-document() no-error.
    if hSAXWriter:write-status = 7 then
    do:
        delete object hSAXWriter no-error.
        return error.
    end.
    delete object hSAXWriter no-error.
end.
procedure SaxReader:
    define variable hParser as handle no-undo.
    create sax-reader hParser.
    define variable vmemptr as memptr no-undo.
    copy-lob mWebResp to vmemptr.
    hParser:set-input-source("memptr", vmemptr).
    hParser:sax-parse () no-error.
    if error-status:error then
    do:
        if error-status:num-messages > 0 then
            return error error-status:get-message(1).
        else
            return error return-value.
    end.
    delete object hParser.
end.
PROCEDURE StartDocument:
END PROCEDURE.
PROCEDURE StartElement:
    DEFINE INPUT PARAMETER namespaceURI AS CHARACTER.
    DEFINE INPUT PARAMETER localName AS CHARACTER.
    DEFINE INPUT PARAMETER qname AS CHARACTER.
    DEFINE INPUT PARAMETER attributes AS HANDLE.
    mElement = qname.
    if mElement = "report" then
    do:
        if attributes:GET-VALUE-BY-QNAME("code") <> ? then
        do:
            empty temp-table tt-one-chk-report-head.
            create tt-one-chk-report-head.
            assign
                tt-one-chk-report-head.db-num    = g#db-num
                tt-one-chk-report-head.obj-code  = m-obj-code
                tt-one-chk-report-head.ID        = attributes:GET-VALUE-BY-QNAME("code")
                tt-one-chk-report-head.is-report = 1
                .
        end.
    end.
    if mElement = "STextCheq" then
    do:
        m-textCheq = "" .
    end .
    if mElement = "SParamJSON" then
    do:
        m-ParamJSON = "" .
    end .
END PROCEDURE.
PROCEDURE Characters:
    DEFINE INPUT PARAMETER charData AS MEMPTR.
    DEFINE INPUT PARAMETER numChars AS INTEGER.
    define variable vCurrContent  as longchar no-undo.
    define variable vLengthMemptr as int64    no-undo.
    define variable vReadByte     as int64    no-undo.
    define variable vRead         as integer  no-undo.
    vLengthMemptr = numChars.
    do while vLengthMemptr - vReadByte > 0 :
        vRead = min(vLengthMemptr - vReadByte,30000).
        vCurrContent = vCurrContent + GET-STRING(charData,vReadByte + 1,vRead).
        vReadByte = vReadByte + vRead.
    end.
    if trim(vCurrContent) = "" then return.
    case mElement:
        when "SUuidCheq" then
            tt-one-chk-report-head.CheckID = vCurrContent .
        when "SRRN" then
            tt-one-chk-report-head.RRN = vCurrContent .
        when "SDate" then
            tt-one-chk-report-head.slip-dt = fConvetDateTime(string(vCurrContent)) no-error.
        when "ShiftDate" then
            tt-one-chk-report-head.CashShiftDate = fConvetDate(string(vCurrContent)) no-error.
        when "ShiftNum" then
            tt-one-chk-report-head.CashShiftNum = integer(vCurrContent) no-error.
        when "SProc" then
            tt-one-chk-report-head.proc-type = integer(vCurrContent) no-error.
        when "RSrc" then
            tt-one-chk-report-head.src_ = integer(vCurrContent) no-error.
        when "RType" then
            tt-one-chk-report-head.kind = integer(vCurrContent) no-error.
        when "Report" then
            tt-one-chk-report-head.is-report = integer(vCurrContent) no-error.
        when "KassaNumber" then
            tt-one-chk-report-head.cash-num = integer(vCurrContent) no-error.
        when "SParamJSON" then
            do :
                m-ParamJson = m-ParamJson + vCurrContent .
            end .
        when "ErrorMessage" then
            ErrorMessage = vCurrContent.
        when "STextCheq"
        then
            do :
                m-textCheq = m-textCheq + vCurrContent .
            end .
    end case.
END PROCEDURE.
PROCEDURE EndElement:
    DEFINE INPUT PARAMETER name_ AS CHARACTER.
    DEFINE INPUT PARAMETER localName AS CHARACTER.
    DEFINE INPUT PARAMETER qName AS CHARACTER.
    define variable ii as integer no-undo .
    if qname = "ErrorMessage" then
    do:
        self:stop-parsing ().
    end.
    else
        if qName = "report" then
        do:
            if tt-one-chk-report-head.ID > "" and tt-one-chk-report-head.cash-num > 0
                then
            do :
                find first tt-chk-report-head where tt-chk-report-head.db-num    = tt-one-chk-report-head.db-num
                    and tt-chk-report-head.ID        = tt-one-chk-report-head.ID
                    no-error .
                if not available tt-chk-report-head
                    then
                do :
                    create tt-chk-report-head .
                    buffer-copy tt-one-chk-report-head to tt-chk-report-head .
                end .
            end .
        end.
    if qName = "STextCheq" then
    do:
        if tt-one-chk-report-head.ID > ""
            then
        do :
            do ii = 1 to num-entries(m-textCheq, chr(10)) :
                create tt-chk-report-string.
                assign
                    tt-chk-report-string.db-num    = tt-one-chk-report-head.db-num
                    tt-chk-report-string.ID        = tt-one-chk-report-head.ID
                    tt-chk-report-string.CheckID   = tt-one-chk-report-head.CheckID
                    tt-chk-report-string.RRN       = tt-one-chk-report-head.RRN
                    tt-chk-report-string.str-num   = ii
                    tt-chk-report-string.str-value = entry(ii, m-textCheq, chr(10))
                    .
            end .
        end .
    end.
    if qName = "SParamJSON" then
    do:
        if tt-one-chk-report-head.ID > ""
            then
        do :
            do ii = 10001 to num-entries(m-ParamJson, chr(10)) :
                create tt-chk-report-string.
                assign
                    tt-chk-report-string.db-num    = tt-one-chk-report-head.db-num
                    tt-chk-report-string.ID        = tt-one-chk-report-head.ID
                    tt-chk-report-string.CheckID   = tt-one-chk-report-head.CheckID
                    tt-chk-report-string.RRN       = tt-one-chk-report-head.RRN
                    tt-chk-report-string.str-num   = ii
                    tt-chk-report-string.str-value = entry(ii, m-ParamJson, chr(10))
                    .
            end .
        end .
    end .
END PROCEDURE.
PROCEDURE EndDocument:
    p-ok = true.
END PROCEDURE.
PROCEDURE Warning:
    DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.
    MESSAGE "The following WARNING was generated:~n" + ErrMessage
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
END PROCEDURE.
PROCEDURE Error:
    DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.
    p-ok = false.
    MESSAGE "The following NONFATAL ERROR was generated:~n" + ErrMessage
        VIEW-AS ALERT-BOX INFO BUTTONS OK.
END PROCEDURE.
PROCEDURE FatalError:
    DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.
    p-ok = false.
    RETURN ERROR "The following FATAL ERROR was generated:~n" + ErrMessage.
END PROCEDURE.
