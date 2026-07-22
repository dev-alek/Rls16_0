block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "пересылка номера кассы - пускальник".
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
DEFINE NEW SHARED TEMP-TABLE cash-cash no-undo
FIELD stts like ub.clients.stts
FIELD psn-code like ub.person.psn-code
FIELD cash-code as integer
FIELD slr-code  as integer
FIELD superviser as integer
FIELD cash-name like ub.clients.obj-name
FIELD psswd as character
FIELD s-psswd as character
FIELD ident-type as integer
index icli IS PRIMARY psn-code
index icash cash-code stts
index islr  slr-code stts
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table stf-list no-undo like ub.staff
field to-del     as logical
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define NEW shared variable base-cass as int no-undo.
define NEW shared variable right-curs as log no-undo.
define NEW shared variable curr-list as char no-undo.
define NEW shared variable pay-list as character no-undo.
define NEW shared variable nal as integer no-undo.
define NEW shared variable kassa-rub-code      as  integer  no-undo .
define NEW shared variable unq-artc as logical no-undo init no.
define NEW shared variable val-abbr as character no-undo.
define NEW shared variable val-cass as character no-undo.
define NEW shared variable val-shop as character no-undo.
define NEW shared variable pay-val as character no-undo.
define NEW shared variable pay-cass as character no-undo.
define NEW shared variable pay-shop as character no-undo.
define NEW shared variable nal-rub as integer no-undo.
define NEW shared variable abbr as character no-undo.
define NEW shared variable pay-nal as integer no-undo.
define NEW shared variable cass-card as character no-undo.
define NEW shared variable trade-card as character no-undo.
define NEW shared variable curr-card as character no-undo.
define NEW shared variable not-nal as integer no-undo.
define NEW shared variable lll as int no-undo initial 0.
define NEW shared variable ibmspool as character no-undo .
define NEW shared variable ibmgroup as logical no-undo init yes.
define NEW SHARED variable specgrp as character no-undo init '':U.
define NEW shared variable varscales-pref as character no-undo .
define NEW shared variable varpgscales-pref as character no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref-type5 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type5
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type5 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type5
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
define NEW SHARED temp-table chk_doc no-undo
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable path as char no-undo.
define variable atr as char no-undo.
define variable file as char no-undo.
define variable adr as char no-undo.
def stream DirStream .
define variable in_ as char no-undo.
define variable spl as char no-undo.
define variable sav as char no-undo.
define variable out as char no-undo.
define variable out2 as character no-undo .
define variable v-remote as char no-undo.
define variable v-dir-remote as character no-undo .
define variable v-dir-remote-tmp as character no-undo .
define variable yestr as character no-undo .
define variable kass-list as char no-undo.
define variable cycle as logical no-undo.
def buffer for-cash-desk for ub.cash-desk.
define variable jj as int no-undo.
define variable v-lock-global as logical no-undo.
def frame a
path format "x(30)"
with view-as dialog-box side-labels
size 50 by 4.17 three-d title "Обработка файла ...".
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-bgelib-bgefmt        as character         no-undo.
define variable v-bgelib-bgeflold      as character         no-undo.
define stream stmXMLOut.
define stream stmXMLLog.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "X(65)" no-undo
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
define variable v-bgelib-bgeclall           as logical      no-undo.
define variable v-bgelib-bgedict            as logical      no-undo.
define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character
    index pi is primary unique
        edt-key
.
define temp-table temp_bgelib_goods no-undo
    field gds-code as integer
    index pi is primary unique
        gds-code
.
define temp-table temp_bgelib_clients no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bgelib_dis-card no-undo
    field d-card as character
    index pi is primary unique
        d-card
.
define temp-table temp_bgelib_trn-doc no-undo
    field doc-code as integer
.
procedure bgelib-tag-open:
do
on error undo, return error
:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill(" ", 4 * v-tag-level)
        + "<" + v-tag-name
        + ( if v-tag-value = "" or v-tag-value = ? then "" else " " )
        + v-tag-value + ">"
    .
end.
end procedure.
procedure bgelib-tag-put:
do
on error undo, return error
:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.
    v-tag-name = trim(v-tag-name).
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "" and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "" and v-tag-value <> ? and v-tag-value <> "0"))
    or (v-empty-mode = 3 and (v-tag-value <> "" and v-tag-value <> ? and caps(v-tag-value) <> "no"))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            chr(10) + fill(" ", 4 * v-tag-level)
                        + '<' + v-tag-name + '>'
                        + v-tag-value
                        + '</' + v-tag-name + '>'
        .
    end.
end.
end procedure.
procedure bgelib-tag-close:
do
on error undo, return error
:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill( " ", 4 * v-tag-level)
        + '</' + v-tag-name + '>'
    .
end.
end procedure.
procedure bgelib-write-log:
do
on error undo, return error
:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.
    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        chr(10)
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine"
          or v-out-string = "&Line"
          then ""
          else cur-time-string-sec() + " " )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line"
          then fill( "-", 80 )
          else if v-out-string = "&DLine"
               then fill( "=", 80 )
               else v-out-string )
    .
    output stream stmXMLLog close.
end.
end procedure.
procedure bgelib-write-edt:
do
on error undo, return error
:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.
    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine"
                                          or v-out-string = "&Line"
                                          then ""
                                          else cur-time-string-sec() + " "
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line"
                                          then fill( "-", 80 )
                                          else if v-out-string = "&DLine" then fill("=", 80)
                                          else fill( " ", v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( chr(10) ).
    end.
    process events.
    output to 'bgescn.txt' append.
        put unformatted
            chr(10)
            string( ( if v-log-level = 0
                      or v-out-string = "&DLine"
                      or v-out-string = "&Line"
                      then ""
                      else string( today ) + " " + string( time, "hh:mm:ss" ) + " "
                  ) )
            string( ( if v-out-string = "&Line"
                      then fill( "-", 80 )
                      else if v-out-string = "&DLine"
                           then fill( "=", 80 )
                           else fill( " ", v-log-level ) + v-out-string
                  ) )
        .
    output close.
end.
end procedure.
procedure bgelib-show-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :visible = true
        .
    end.
end.
end procedure.
procedure bgelib-hide-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign v-fillin-handle :visible = false.
    end.
end.
end procedure.
procedure bgelib-write-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.
procedure bgelib-write-header:
do
on error undo, return error
:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-obj-list       as character    no-undo.
define input parameter p-doc-type-list  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.
    define variable v-counter    as integer        no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run bgelib-tag-open( input 0, input "root"  , input "" ).
    run bgelib-tag-open( input 0, input "header", input "" ).
    run bgelib-tag-put( input 1, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 1, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 1, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 1, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 1, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 1, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run bgelib-tag-close( input 0, input "header" ).
    output stream stmXMLOut close.
    output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
    if p-first-file = yes
    then do:
        put stream stmXMLOut unformatted
            "<?xml version='1.0' encoding='windows-1251'?>"
        .
        run bgelib-tag-open( input 0, input "export", input "" ).
    end.
    run bgelib-tag-open( input 1, input "file", input "" ).
    run bgelib-tag-put( input 2, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 2, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 2, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 2, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 2, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 2, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 2
            , input trim(entry( 2 * v-counter, p-parameter-list ))
            , input trim(entry( 2 * v-counter + 1, p-parameter-list ))
            , input 0
        ).
    end.
    run bgelib-tag-close( input 1, input "file" ).
    output stream stmXMLOut close.
end.
end procedure.
procedure bgelib-write-footer:
do
on error undo, return error
:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.
    define variable v-error-num     as integer           no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run bgelib-tag-open( input 0, input "footer", "" ).
        run bgelib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run bgelib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run bgelib-tag-close( input 0, input "footer" ).
    end.
    run bgelib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + "tmp"
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
            run bgelib-tag-close( input 0, input "export" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + "tmp"
            , input p-list-file-name + "xml"
            , output v-error-num
        ).
    end.
end.
end procedure.
procedure bgelib-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.
    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.
    get-key-value section "BGE" key "outdir" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run bge/genfname.p (
          input v-home-dir
        , input p-prefix
        , input ""
        , input "xml"
        , input "tmp"
        , output p-xml-file-name
    ).
    assign
        p-xml-file-name     = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
        p-log-file-name     = v-home-dir + chr(92) + "actions.log"
        p-list-file-name    = v-home-dir + chr(92) + "lst":U + substring( p-xml-file-name, length( p-xml-file-name ) - 5, 5 ) + ".":U
    .
end.
end procedure.
procedure bgelib-read-config :
do
on error undo, return error
:
define variable v-par-type as character     no-undo.
  define variable v-param-type      as character  no-undo .
  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .
    assign
        v-bgelib-bgeclall = no
        v-bgelib-bgedict  = no
    .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeclall = no
      .
    end.
    else do:
      assign
        v-bgelib-bgeclall = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgedict':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgedict = no
      .
    end.
    else do:
      assign
        v-bgelib-bgedict = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgefmt':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bgelib-bgefmt  = v-value-character
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeflold':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeflold  = "old":U
      .
    end.
    else do:
      assign
        v-bgelib-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
end.
end procedure.
procedure bgelib-check-file-size :
do
on error undo, return error
:
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.
    define variable v-current-position    as integer        no-undo.
    assign
        v-current-position = seek( stmXMLOut )
    .
    if v-current-position / 1024 / 1024  >= 100
    then do:
        assign
            p-is-big = yes
        .
    end.
end.
end procedure.
procedure bgelib-init-ext-doc-type :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_ext-doc-type     for temp_ext-doc-type.
do
for buf_temp_ext-doc-type
on error undo, return error
:
    empty temp-table buf_temp_ext-doc-type.
    do v-counter = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
    :
        create buf_temp_ext-doc-type.
        assign
            buf_temp_ext-doc-type.edt-key               = v-counter
            buf_temp_ext-doc-type.ext-doc-type          = entry( v-counter, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
            buf_temp_ext-doc-type.ext-doc-type-label    = entry( v-counter, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
        .
    end.
end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable choice        as integer   no-undo.
define variable cli-list      as character no-undo.
define variable kk            as integer   no-undo.
define variable callpoint     as char      no-undo.
define variable glog          as logical   no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-view-log    as logical   no-undo .
define variable i-obj-code    like ub.clients.obj-code no-undo.
define variable mode          as character no-undo.
define variable v-work-place  as character no-undo .
DEFINE VARIABLE v-today       as date      no-undo .
DEFINE VARIABLE v-time        as integer   no-undo .
define variable cash-num      as character no-undo .
define variable reful         as integer   no-undo .
define variable cash-reful    as integer   no-undo .
define variable cmd           as character no-undo .
define variable ii            as integer   no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_staff   for ub.staff.
define variable v-xml-file as character no-undo .
define variable OS-time    as character no-undo .
define variable id         as character no-undo .
define buffer buf_db for ub.db.
assign
  i-obj-code = integer(entry(1, p-parameter, chr(4)))
  cash-num   = entry(2, p-parameter, chr(4))
no-error
  .
if error-status:error then
do:
  run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute("Ошибка входных параметров &1:&2&3"
    , p-parameter
    , chr(10)
    , error-status:get-message(1)
    )).
  v-view-log = yes.
  undo, return error .
end .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
do ii = 1 to num-entries (cash-num,";"):
  for each ub.cash-desk NO-LOCK WHERE
    ub.cash-desk.db-num = g#db-num
    and ub.cash-desk.obj-code = i-obj-code
    and ub.cash-desk.cash-num = integer(entry(ii,cash-num,";"))
    and ub.cash-desk.pos-type = 'IBM-XML':U
    and ub.cash-desk.cash-on:
    run xml-cd-filename in this-procedure (
      input out
      ,output v-xml-file-name
      ,output v-xml-file-name-path
      ,output v-log-file-name
      ,output v-locked
      ).
    assign
      v-obj-list = 'маг':U + string(ub.cash-desk.obj-code)
      .
    v-xml-file = ibs.th.gbl.gbl-inipar:logDir + v-xml-file-name-path + "xml" .
    output stream stmxmlout to value( v-xml-file ) convert target "1251" append.
    put stream stmXMLOut unformatted
      "<?xml version='1.0' encoding='windows-1251'?>".
    assign
      OS-time = string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
      .
    run bgelib-tag-open in this-procedure (
      1
      ,"config"
      ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", v-xml-file-name, v-obj-list, (v-obj-list + "_":U + "касса" + string(ub.cash-desk.cash-num)), OS-time )
      ).
    run bgelib-tag-open in this-procedure ( input 2, input "Param", input substitute("ctrl='&2' group='&1' key='&3'", "UFO2":u, "ADD":u, "KassaNumber":U)).
    run bgelib-tag-put in this-procedure ( input 3, input "ParamValue", input string(ub.cash-desk.cash-num), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ParamDesc", input "Номер кассы", input 1 ).
    run bgelib-tag-close in this-procedure ( input 2, input "Param").
    run bgelib-tag-open in this-procedure ( input 2, input "Param", input substitute("ctrl='&2' group='&1' key='&3'", "UFO2":u, "ADD":u, "ShopNumber":U)).
    run bgelib-tag-put in this-procedure ( input 3, input "ParamValue", input string(ub.cash-desk.obj-code), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ParamDesc", input "Номер магазина", input 1 ).
    run bgelib-tag-close in this-procedure ( input 2, input "Param").
    run bgelib-tag-close( 1, "config" ).
    output stream stmxmlout close.
    assign
      log-file-name = 'get-chkf.log'.
    assign
      cmd = substitute('&1 -X POST -H "Content-Type: text/xml" -d @&2 &3 >&4'
                      , search ("exe/curl.exe")
                      , search (v-xml-file)
                      , (entry(1, ub.cash-desk.addr-path, chr(4)) + '://' + entry(2, ub.cash-desk.addr-path, chr(4)))
                      , "cashParNum.txt")
      .
    os-command silent value (cmd) .
    os-delete value( v-xml-file).
  end.
end.
for each ub.cash-desk NO-LOCK WHERE
  ub.cash-desk.db-num = g#db-num
  and ub.cash-desk.obj-code = i-obj-code
  and ub.cash-desk.cash-num = cash-reful
  and ub.cash-desk.pos-type = 'IBM-XML':U
  and ub.cash-desk.cash-on:
  run xml-cd-filename in this-procedure (
    input out
    ,output v-xml-file-name
    ,output v-xml-file-name-path
    ,output v-log-file-name
    ,output v-locked
    ).
  assign
    v-obj-list = 'маг':U + string(ub.cash-desk.obj-code)
    .
  v-xml-file = ibs.th.gbl.gbl-inipar:logDir + v-xml-file-name-path + "xml" .
  output stream stmxmlout to value( v-xml-file ) convert target "1251" append.
  put stream stmXMLOut unformatted
    "<?xml version='1.0' encoding='windows-1251'?>".
  assign
    OS-time = string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
    .
  run bgelib-tag-open in this-procedure (
    1
    ,"config"
    ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", v-xml-file-name, v-obj-list, (v-obj-list + "_":U + "касса" + string(ub.cash-desk.cash-num)), OS-time )
    ).
  run bgelib-tag-open in this-procedure ( input 2, input "Param", input substitute("ctrl='&2' group='&1' key='&3'", "UFO2":u, "ADD":u, "RfNumber":U)).
  run bgelib-tag-put in this-procedure ( input 3, input "ParamValue", input string(reful), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ParamDesc", input "RfNumber кассы", input 1 ).
  run bgelib-tag-close in this-procedure ( input 2, input "Param").
  run bgelib-tag-close( 1, "config" ).
  output stream stmxmlout close.
  assign
    log-file-name = 'get-chkf.log'.
  assign
    cmd = substitute('&1 -X POST -H "Content-Type: text/xml" -d @&2 &3 >&4'
                      , search ("exe/curl.exe")
                      , search (v-xml-file)
                      , (entry(1, ub.cash-desk.addr-path, chr(4)) + '://' + entry(2, ub.cash-desk.addr-path, chr(4)))
                      , "cashParNum.txt")
    .
  os-command silent value (cmd) .
  os-delete value( v-xml-file).
end.
finally :
  run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute("&1", chr(10))
    ).
  define variable v-save-file-name as character no-undo .
  v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
  // где смотрят файл и где его удаляют - не известно.
  // поэтому здесь мы его только копируем
  OS-APPEND value(log-file-name) value(v-save-file-name).
end finally .
