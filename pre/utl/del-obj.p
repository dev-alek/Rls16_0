block-level on error undo, throw.
define input  parameter p-obj-list           as character no-undo .
define input  parameter p-check-rest         as logical   no-undo .
define input  parameter p-pswd-list          as character no-undo .
define input  parameter p-check-string-file  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-obj.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/del-obj.p $":U .
define variable vss-description as character no-undo init "Удаление объекта и всех связанных таблиц".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table doc-list no-undo
  field doc-code         like ub.trn-doc.doc-code
  field obj-type         like ub.trn-doc.obj-type
  field obj-code         like ub.trn-doc.obj-code
  field fact-date        like ub.trn-doc.fact-date
  field shift-date       like ub.trn-doc.shift-date
  field shift-num        like ub.trn-doc.shift-num
  field shift-name       like ub.trn-doc.shift-name
  field fact-order       as decimal
  field is-trn-doc       as logical
  field doc-type         like ub.trn-doc.doc-type
  field is-archive-exist as logical
  index xpk is primary unique doc-code doc-type
  index xfact-order fact-order
  index xfact-date  fact-date
  .
define temp-table doclslib-goods no-undo
  field gds-code  as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  index xpk is primary unique gds-code
  index xie1 artic prod-type prod-code
  .
define buffer inkas_trn-doc for ub.trn-doc .
define stream doclsliblog .
procedure doclslib-clear-doc-list :
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    for each buf_doc-list
    on error undo, return error
    :
      delete buf_doc-list .
    end.
  end.
end procedure.
procedure doclslib-init-trn-doc :
  define input parameter p-obj-type      as character no-undo .
  define input parameter p-obj-code      as integer   no-undo .
  define input parameter p-cut-date      as date      no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    if p-cut-date = ?
    then do:
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type = p-obj-type
          and buf_trn-doc.obj-code = p-obj-code
          and buf_trn-doc.status_  = 'факт':U
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_trn-doc.doc-code
          buf_doc-list.doc-type   = buf_trn-doc.doc-type
          buf_doc-list.fact-date  = buf_trn-doc.fact-date
          buf_doc-list.shift-date = buf_trn-doc.shift-date
          buf_doc-list.shift-num  = buf_trn-doc.shift-num
          buf_doc-list.shift-name = buf_trn-doc.shift-name
          buf_doc-list.fact-order = buf_trn-doc.fact-order
          buf_doc-list.is-trn-doc = true
        .
      end.
    end.
    else do:
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type  = p-obj-type
          and buf_trn-doc.obj-code  = p-obj-code
          and buf_trn-doc.status_   = 'факт':U
          and buf_trn-doc.fact-date >= p-cut-date
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_trn-doc.doc-code
          buf_doc-list.doc-type   = buf_trn-doc.doc-type
          buf_doc-list.fact-date  = buf_trn-doc.fact-date
          buf_doc-list.shift-date = buf_trn-doc.shift-date
          buf_doc-list.shift-num  = buf_trn-doc.shift-num
          buf_doc-list.shift-name = buf_trn-doc.shift-name
          buf_doc-list.fact-order = buf_trn-doc.fact-order
          buf_doc-list.is-trn-doc = true
        .
      end.
    end.
  end.
end procedure.
procedure doclslib-init-price-doc :
  define input parameter p-obj-type      as character no-undo .
  define input parameter p-obj-code      as integer   no-undo .
  define input parameter p-cut-date      as date      no-undo .
  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    if p-cut-date = ?
    then do:
      for each buf_price-doc no-lock
        where buf_price-doc.obj-type = p-obj-type
          and buf_price-doc.obj-code = p-obj-code
          and buf_price-doc.status_  = 'акт':U
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_price-doc.doc-num
          buf_doc-list.doc-type   = ''
          buf_doc-list.fact-date  = buf_price-doc.fact-date
          buf_doc-list.shift-date = buf_price-doc.shift-date
          buf_doc-list.shift-num  = buf_price-doc.shift-num
          buf_doc-list.shift-name = buf_price-doc.shift-name
          buf_doc-list.fact-order = buf_price-doc.fact-order
          buf_doc-list.is-trn-doc = false
        .
      end.
    end.
    else do:
      for each buf_price-doc no-lock
        where buf_price-doc.obj-type = p-obj-type
          and buf_price-doc.obj-code = p-obj-code
          and buf_price-doc.status_  = 'акт':U
          and ub.buf_price-doc.fact-date >= p-cut-date
      on error undo, return error
      :
        create buf_doc-list .
        assign
          buf_doc-list.doc-code   = buf_price-doc.doc-num
          buf_doc-list.doc-type   = ''
          buf_doc-list.fact-date  = buf_price-doc.fact-date
          buf_doc-list.shift-date = buf_price-doc.shift-date
          buf_doc-list.shift-num  = buf_price-doc.shift-num
          buf_doc-list.shift-name = buf_price-doc.shift-name
          buf_doc-list.fact-order = buf_price-doc.fact-order
          buf_doc-list.is-trn-doc = false
        .
      end.
    end.
  end.
end procedure.
procedure doclslib-clear-bydate-doc-list :
  define input parameter p-fact-date as date no-undo .
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    if p-fact-date <> ?
    then do:
      for each buf_doc-list
        where buf_doc-list.fact-date < p-fact-date
      on error undo, return error
      :
        delete buf_doc-list .
      end.
    end.
  end.
end procedure.
procedure doclslib-clear-rst :
  define input parameter p-fact-date as date no-undo .
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    if p-fact-date <> ?
    then do:
      for each buf_doc-list
        where buf_doc-list.fact-date >= p-fact-date
      on error undo, return error
      :
        delete buf_doc-list .
      end.
    end.
  end.
end procedure.
procedure doclslib-export-doc-list :
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer no-undo .
  define input  parameter p-log-file-name as character no-undo .
  define input  parameter p-description   as character no-undo .
  define buffer buf_doc-list for doc-list .
  do
  on error undo, return error
  :
    output stream doclsliblog to value(p-log-file-name) .
    export stream doclsliblog "#############################################################" .
    export stream doclsliblog "Список документов" .
    export stream doclsliblog p-description .
    export stream doclsliblog "Объект" p-obj-type p-obj-code .
    export stream doclsliblog "Дата" string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U).
    for each buf_doc-list
    by buf_doc-list.fact-order
    on error undo, return error
    :
      export stream doclsliblog buf_doc-list .
    end.
    export stream doclsliblog "#############################################################" .
    output stream doclsliblog close .
  end.
end procedure.
procedure doclslib-clear-batch-process :
  define input parameter p-bp_type like ub.batchprocess.bp_type no-undo .
  define buffer buf_batchprocess        for ub.batchprocess .
  define buffer execdelete_batchprocess for ub.batchprocess .
  define buffer buf_doc-list            for doc-list .
  for each buf_doc-list
  on end-key undo, return error substitute( "doclslib-clear-batch-process. end-key   &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  on error   undo, return error substitute( "doclslib-clear-batch-process. error     &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  on stop    undo, return error substitute( "doclslib-clear-batch-process. STOP      &2"
                                 + "bp_type &3&2"
                                 + "Документ &4"
                                 , chr(10)
                                 , p-bp_type
                                 , buf_doc-list.doc-code
                                )
  :
    find first buf_batchprocess exclusive-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_batchprocess.bp_type     = p-bp_type
        and buf_batchprocess.charkey_one = buf_doc-list.doc-code
      no-error .
    if available buf_batchprocess
    then do:
      delete buf_batchprocess .
    end.
  end.
end procedure.
procedure doclslib-calc-arh :
  define input  parameter p-log-handle     as handle    no-undo .
  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-cut-date       as date      no-undo .
  define input  parameter p-update-recalc  as logical   no-undo .
  define variable v-prev-fact-date as date      no-undo .
  define buffer buf_doc-list for doc-list .
  define buffer stop-arh-restore-lock_btpr for ub.batchprocess .
  define buffer stop-arh-news-lock_btpr    for ub.batchprocess .
  do
  on stop    undo, return error substitute( "doclslib-calc-arh. stop      &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  on end-key undo, return error substitute( "doclslib-calc-arh. end-key   &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  on error   undo, return error substitute( "doclslib-calc-arh. error     &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
  :
    define buffer buf_lock_gdsrenart_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grar':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrenart_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования артикула товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    define buffer buf_lock_gdsrengc_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grgc':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrengc_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования кода товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    for each buf_doc-list
    by buf_doc-list.fact-order
    on stop    undo, return error substitute( "f e . stop      &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
    on end-key undo, return error substitute( "f e . end-key   &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
    on error   undo, return error substitute( "f e . error     &1&2&3", return-value, chr(10), error-status :get-message ( 1 ) )
    :
      find first stop-arh-restore-lock_btpr no-lock
        where stop-arh-restore-lock_btpr.bp_type       = 'lock':U + 'rsrs':U
          and stop-arh-restore-lock_btpr.bp_status     = 'N':U
          and stop-arh-restore-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-arh-restore-lock_btpr.Key#_Two      = 0
          and stop-arh-restore-lock_btpr.Key#_Three    = 0
          and stop-arh-restore-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-arh-restore-lock_btpr.CharKey_Two   = ""
          and stop-arh-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-arh-restore-lock_btpr
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input "Процедура восстановления складского архива запросила остановку процедуры расчета складского архива"
          ) .
        undo, return error "Процедура восстановления складского архива запросила остановку процедуры расчета складского архива" .
      end.
      find first stop-arh-news-lock_btpr no-lock
        where stop-arh-news-lock_btpr.bp_type       = 'lock':U + 'rsrn':U
          and stop-arh-news-lock_btpr.bp_status     = 'N':U
          and stop-arh-news-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-arh-news-lock_btpr.Key#_Two      = 0
          and stop-arh-news-lock_btpr.Key#_Three    = 0
          and stop-arh-news-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-arh-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-arh-news-lock_btpr
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input "Система новостей запросила остановку процедуры расчета складского архива"
          ) .
        undo, return error "Система новостей запросила остановку процедуры расчета складского архива" .
      end.
      if buf_doc-list.is-trn-doc
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/calc-arh.p
          (input buf_doc-list.doc-code
          ,input p-cut-date
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.
      else do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/calc-apc.p
          (input buf_doc-list.doc-code
          ,input p-cut-date
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.
      if  p-update-recalc  = true
      and v-prev-fact-date <> ?
      and buf_doc-list.fact-date > v-prev-fact-date
      then do:
        run gbl/clntat-w.p
          (input p-obj-type
          ,input p-obj-code
          ,input 'arh-recalc':U
          ,input string(buf_doc-list.fact-date, '99/99/9999':U)
          ) .
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Завершён расчет дня &1. Устанавливается дата перерасчёта &2"
                           ,string(v-prev-fact-date, '99/99/9999':u)
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           )
          ) .
      end.
      assign
        v-prev-fact-date = buf_doc-list.fact-date
      .
    end.
  end.
end procedure.
procedure doclslib-calc-aht :
  define input  parameter p-log-handle    as handle    no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define input  parameter p-cut-date      as date      no-undo .
  define input  parameter p-update-recalc as logical   no-undo .
  define variable v-prev-fact-date as date      no-undo .
  define buffer buf_doc-list for doc-list .
  define buffer stop-aht-restore-lock_btpr for ub.batchprocess .
  define buffer stop-aht-news-lock_btpr    for ub.batchprocess .
  do
  on error undo, return error return-value
  :
    define buffer buf_lock_gdsrenart_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grar':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrenart_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования артикула товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    define buffer buf_lock_gdsrengc_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grgc':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrengc_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования кода товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    for each buf_doc-list
    by buf_doc-list.fact-order
    on error undo, return error
    :
      find first stop-aht-restore-lock_btpr no-lock
        where stop-aht-restore-lock_btpr.bp_type       = 'lock':U + 'rsts':U
          and stop-aht-restore-lock_btpr.bp_status     = 'N':U
          and stop-aht-restore-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-aht-restore-lock_btpr.Key#_Two      = 0
          and stop-aht-restore-lock_btpr.Key#_Three    = 0
          and stop-aht-restore-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-aht-restore-lock_btpr.CharKey_Two   = ""
          and stop-aht-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-aht-restore-lock_btpr
      then do:
        undo, return error "Процедура восстановления складского архива запросила остановку процедуры автоматического расчета складского архива" .
      end.
      find first stop-aht-news-lock_btpr no-lock
        where stop-aht-news-lock_btpr.bp_type       = 'lock':U + 'rstn':U
          and stop-aht-news-lock_btpr.bp_status     = 'N':U
          and stop-aht-news-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-aht-news-lock_btpr.Key#_Two      = 0
          and stop-aht-news-lock_btpr.Key#_Three    = 0
          and stop-aht-news-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-aht-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-aht-news-lock_btpr
      then do:
        undo, return error "Система новостей запросила остановку процедуры автоматического расчета складского архива" .
      end.
      if buf_doc-list.is-trn-doc
      then do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/aht-doc.p
          (input buf_doc-list.doc-code
          ,input p-cut-date
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Документ &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.
      else do:
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Начало расчёта. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
        run trg/aht-prc.p
          (input buf_doc-list.doc-code
          ,input p-cut-date
          ).
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Расчёт завершен. Переоценка &1. Факт &2. Номер &3"
                           ,buf_doc-list.doc-code
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           ,buf_doc-list.fact-order
                           )
          ) .
      end.
      if  p-update-recalc  = true
      and v-prev-fact-date <> ?
      and buf_doc-list.fact-date > v-prev-fact-date
      then do:
        run gbl/clntat-w.p
          (input p-obj-type
          ,input p-obj-code
          ,input 'aht-recalc':U
          ,input string(buf_doc-list.fact-date, '99/99/9999':U)
          ) .
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Завершён расчет дня &1. Устанавливается дата перерасчёта &2"
                           ,string(v-prev-fact-date, '99/99/9999':u)
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           )
          ) .
      end.
      assign
        v-prev-fact-date = buf_doc-list.fact-date
      .
    end.
  end.
end procedure.
procedure doclslib-calc-ahsp :
  define input  parameter p-log-handle    as handle    no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define input  parameter p-cut-date      as date      no-undo .
  define input  parameter p-update-recalc as logical   no-undo .
  define variable v-prev-fact-date as date      no-undo .
  define buffer buf_doc-list for doc-list .
  define buffer stop-ahsp-restore-lock_btpr for ub.batchprocess .
  define buffer stop-ahsp-news-lock_btpr    for ub.batchprocess .
  do
  on error undo, return error return-value
  :
    define buffer buf_lock_gdsrenart_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grar':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrenart_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования артикула товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    define buffer buf_lock_gdsrengc_batchprocess for ub.batchprocess .
    run gbl/lockrngd.p
      (input  'grgc':U
      ,input  'disable':U
      ,buffer buf_lock_gdsrengc_batchprocess
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при блокировании функции переименования кода товара" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
    for each buf_doc-list
      where buf_doc-list.is-trn-doc = true
    by buf_doc-list.fact-order
    on error undo, return error
    :
      find first stop-ahsp-restore-lock_btpr no-lock
        where stop-ahsp-restore-lock_btpr.bp_type       = 'lock':U + 'rsss':U
          and stop-ahsp-restore-lock_btpr.bp_status     = 'N':U
          and stop-ahsp-restore-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-ahsp-restore-lock_btpr.Key#_Two      = 0
          and stop-ahsp-restore-lock_btpr.Key#_Three    = 0
          and stop-ahsp-restore-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-ahsp-restore-lock_btpr.CharKey_Two   = ""
          and stop-ahsp-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-ahsp-restore-lock_btpr
      then do:
        undo, return error "Процедура восстановления складского архива запросила остановку процедуры расчета складского архива" .
      end.
      find first stop-ahsp-news-lock_btpr no-lock
        where stop-ahsp-news-lock_btpr.bp_type       = 'lock':U + 'rssn':U
          and stop-ahsp-news-lock_btpr.bp_status     = 'N':U
          and stop-ahsp-news-lock_btpr.Key#_One      = buf_doc-list.obj-code
          and stop-ahsp-news-lock_btpr.Key#_Two      = 0
          and stop-ahsp-news-lock_btpr.Key#_Three    = 0
          and stop-ahsp-news-lock_btpr.CharKey_One   = buf_doc-list.obj-type
          and stop-ahsp-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-ahsp-news-lock_btpr
      then do:
        undo, return error "Система новостей запросила остановку процедуры расчета складского архива" .
      end.
      run doclslib-log-information in this-procedure
        (input p-log-handle
        ,input substitute("Начало расчёта. Документ &1. Факт &2. Номер &3"
                          ,buf_doc-list.doc-code
                          ,string(buf_doc-list.fact-date, '99/99/9999':u)
                          ,buf_doc-list.fact-order
                          )
        ) .
      define variable v-need-process as logical   no-undo .
      run trg/ah-csptr.p
        (input  buf_doc-list.doc-code
        ,input  p-cut-date
        ,input  false
        ,output v-need-process
        ).
      run doclslib-log-information in this-procedure
        (input p-log-handle
        ,input substitute("Расчёт завершен. Документ &1. Факт &2. Номер &3"
                          ,buf_doc-list.doc-code
                          ,string(buf_doc-list.fact-date, '99/99/9999':u)
                          ,buf_doc-list.fact-order
                          )
        ) .
      if  p-update-recalc  = true
      and v-prev-fact-date <> ?
      and buf_doc-list.fact-date > v-prev-fact-date
      then do:
        run gbl/clntat-w.p
          (input p-obj-type
          ,input p-obj-code
          ,input 'ahsp-recalc':U
          ,input string(buf_doc-list.fact-date, '99/99/9999':U)
          ) .
        run doclslib-log-information in this-procedure
          (input p-log-handle
          ,input substitute("Завершён расчет дня &1. Устанавливается дата перерасчёта &2"
                           ,string(v-prev-fact-date, '99/99/9999':u)
                           ,string(buf_doc-list.fact-date, '99/99/9999':u)
                           )
          ) .
      end.
      assign
        v-prev-fact-date = buf_doc-list.fact-date
      .
    end.
  end.
end procedure.
procedure doclslib-log-information :
  define input  parameter p-log-handle as handle    no-undo .
  define input  parameter p-message    as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-log-procedure-name as character no-undo .
    assign
      v-log-procedure-name = "cb-doclslib-log"
    .
    if valid-handle(p-log-handle)
    and p-log-handle :get-signature(v-log-procedure-name) <> ""
    then do:
      run value(v-log-procedure-name) in p-log-handle
        (input p-message
        ) no-error .
    end.
  end.
end procedure.
procedure doclslib-find-last-fact-date :
  define output parameter p-last-fact-date  as date      no-undo .
  define output parameter p-reason          as character no-undo .
  do
  on error undo, return error
  :
    define variable v-last-fact-date    as date      no-undo .
    define buffer buf_doc-list for doc-list .
    assign
      v-last-fact-date    = ?
    .
    for each buf_doc-list
    by buf_doc-list.fact-order
    on error undo, return error
    :
      if buf_doc-list.is-archive-exist = false
      or buf_doc-list.fact-date = ?
      then do:
        assign
          p-reason = p-reason + substitute("По документу &1 отсутствует рассчитанный складской архив"
                                          ,buf_doc-list.doc-code
                                          )
        .
        leave .
      end.
      if buf_doc-list.fact-date = ?
      then do:
        assign
          p-reason = p-reason + substitute("Документ &1 имеет не заданную фактическую дату "
                                          ,buf_doc-list.doc-code
                                          )
        .
        leave .
      end.
      if v-last-fact-date = ?
      or (v-last-fact-date <> ?
          and v-last-fact-date < buf_doc-list.fact-date
         )
      then do:
        assign
          v-last-fact-date = buf_doc-list.fact-date
          p-reason         = substitute("Последний рассчитанный документ &1" + chr(10)
                                       ,buf_doc-list.doc-code
                                       )
        .
      end.
    end.
    assign
      p-last-fact-date = v-last-fact-date
    .
  end.
end procedure.
procedure doclslib-check-arh-exist :
  define input parameter  p-obj-type       as character no-undo .
  define input parameter  p-obj-code       as integer   no-undo .
  define input parameter  p-cut-fact-order as decimal   no-undo .
  define output parameter p-archive-exist  as logical   no-undo .
  define buffer buf_stk-tot for ub.stk-tot .
  do
  on error undo, return error
  :
    find first buf_stk-tot no-lock
      where buf_stk-tot.obj-type   = p-obj-type
        and buf_stk-tot.obj-code   = p-obj-code
        and buf_stk-tot.fact-order > p-cut-fact-order
      no-error .
    assign
      p-archive-exist = (available buf_stk-tot)
    .
  end.
end procedure.
procedure doclslib-check-aht-exist :
  define input parameter  p-obj-type       as character no-undo .
  define input parameter  p-obj-code       as integer   no-undo .
  define input parameter  p-cut-fact-order as decimal   no-undo .
  define output parameter p-archive-exist  as logical   no-undo .
  define buffer buf_aht-stk-tot for ub.aht-stk-tot .
  do
  on error undo, return error
  :
    find first buf_aht-stk-tot no-lock
      where buf_aht-stk-tot.obj-type   = p-obj-type
        and buf_aht-stk-tot.obj-code   = p-obj-code
        and buf_aht-stk-tot.fact-order > p-cut-fact-order
      no-error .
    assign
      p-archive-exist = (available buf_aht-stk-tot)
    .
  end.
end procedure.
procedure doclslib-check-ahsp-exist :
  define input parameter  p-obj-type       as character no-undo .
  define input parameter  p-obj-code       as integer   no-undo .
  define input parameter  p-cut-fact-order as decimal   no-undo .
  define output parameter p-archive-exist  as logical   no-undo .
  define buffer buf_stk-supp-tot for ub.stk-supp-tot .
  do
  on error undo, return error
  :
    find first buf_stk-supp-tot no-lock
      where buf_stk-supp-tot.obj-type   = p-obj-type
        and buf_stk-supp-tot.obj-code   = p-obj-code
        and buf_stk-supp-tot.fact-order > p-cut-fact-order
      no-error .
    assign
      p-archive-exist = (available buf_stk-supp-tot)
    .
  end.
end procedure.
procedure doclslib-check-doc-arh-exist :
  define buffer buf_doc-list for doc-list .
  define buffer buf_ot-tot for ub.ot-tot .
  do
  on error undo, return error return-value
  :
    for each buf_doc-list
    on error undo, return error
    :
      find first buf_ot-tot no-lock
        where buf_ot-tot.doc-code = buf_doc-list.doc-code
        no-error .
      if available buf_ot-tot
      then do:
        assign
          buf_doc-list.is-archive-exist = true
        .
      end.
      else do:
        assign
          buf_doc-list.is-archive-exist = false
        .
      end.
    end.
  end.
end procedure.
procedure doclslib-check-doc-aht-exist :
  define buffer buf_doc-list for doc-list .
  define buffer buf_aht-doc for ub.aht-doc .
  do
  on error undo, return error return-value
  :
    for each buf_doc-list
    on error undo, return error
    :
      find first buf_aht-doc no-lock
        where buf_aht-doc.doc-code = buf_doc-list.doc-code
        no-error .
      if available buf_aht-doc
      then do:
        assign
          buf_doc-list.is-archive-exist = true
        .
      end.
      else do:
        assign
          buf_doc-list.is-archive-exist = false
        .
      end.
    end.
  end.
end procedure.
procedure doclslib-check-doc-ahsp-exist :
  define buffer buf_doc-list for doc-list .
  define buffer buf_ot-supp-line for ub.ot-supp-tot .
  do
  on error undo, return error return-value
  :
    for each buf_doc-list
    on error undo, return error
    :
      find first buf_ot-supp-line no-lock
        where buf_ot-supp-line.doc-code = buf_doc-list.doc-code
        no-error .
      if available buf_ot-supp-line
      then do:
        assign
          buf_doc-list.is-archive-exist = true
        .
      end.
      else do:
        if buf_doc-list.doc-type = 'инв':U
        then do:
          define variable v-need-process as logical   no-undo .
          run trg/ah-csptr.p
            (input  buf_doc-list.doc-code
            ,input  0
            ,input  true
            ,output v-need-process
            ).
          if v-need-process = true
          then do:
            assign
              buf_doc-list.is-archive-exist = false
            .
          end.
          else do:
            assign
              buf_doc-list.is-archive-exist = true
            .
          end.
        end.
        else do:
          assign
            buf_doc-list.is-archive-exist = false
          .
        end.
      end.
    end.
  end.
end procedure.
procedure doclslib-clear-ahsp-doc-list :
  define buffer buf_doc-list for doc-list .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_parts    for ub.parts .
  do
  on error undo, return error return-value
  :
    check-doc-list :
    for each buf_doc-list
    on error undo, return error return-value
    :
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-list.doc-code
        .
      if buf_trn-doc.office = true
      then do:
        delete buf_doc-list .
        next check-doc-list .
      end.
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
        no-error .
      if not available buf_doc-line
      then do:
        delete buf_doc-list .
        next check-doc-list .
      end.
      find first buf_parts no-lock
        where buf_parts.out-code = buf_trn-doc.doc-code
          and buf_parts.fact-qnty <> 0
        no-error .
      if not available buf_parts
      then do:
        delete buf_doc-list .
        next check-doc-list .
      end.
    end.
  end.
end procedure.
procedure doclslib-init-goods :
  define buffer buf_doclslib-goods for doclslib-goods .
  define buffer buf_doc-list       for doc-list .
  define buffer buf_trn-doc        for ub.trn-doc .
  define buffer buf_price-doc      for ub.price-doc .
  define buffer buf_doc-line       for ub.doc-line .
  define buffer buf_price-list     for ub.price-list .
  define variable v-gds-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_doclslib-goods
    on error undo, return error return-value
    :
      delete buf_doclslib-goods .
    end.
    for each buf_doc-list
    on error undo, return error return-value
    :
      if buf_doc-list.is-trn-doc
      then do:
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_doc-list.doc-code
          .
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
        on error undo, return error return-value
        :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-gds-code
  )  .
          find first buf_doclslib-goods
            where buf_doclslib-goods.gds-code = v-gds-code
            no-error .
          if not available buf_doclslib-goods
          then do:
            create buf_doclslib-goods .
            assign
              buf_doclslib-goods.gds-code  = v-gds-code
              buf_doclslib-goods.artic     = buf_doc-line.artic
              buf_doclslib-goods.prod-type = buf_doc-line.prod-type
              buf_doclslib-goods.prod-code = buf_doc-line.prod-code
            .
          end.
        end.
      end.
      else do:
        find first buf_price-doc no-lock
          where buf_price-doc.doc-num = buf_doc-list.doc-code
          .
        for each buf_price-list no-lock
          where buf_price-list.doc-num = buf_price-doc.doc-num
        on error undo, return error return-value
        :
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_price-list.artic
  ,input  buf_price-list.prod-type
  ,input  buf_price-list.prod-code
  ,output v-gds-code
  )  .
          find first buf_doclslib-goods
            where buf_doclslib-goods.gds-code = v-gds-code
            no-error .
          if not available buf_doclslib-goods
          then do:
            create buf_doclslib-goods .
            assign
              buf_doclslib-goods.gds-code  = v-gds-code
              buf_doclslib-goods.artic     = buf_price-list.artic
              buf_doclslib-goods.prod-type = buf_price-list.prod-type
              buf_doclslib-goods.prod-code = buf_price-list.prod-code
            .
          end.
        end.
      end.
    end.
  end.
end procedure.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info5 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info5, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info5, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info5 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info5, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info5, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info5, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info5, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info5, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info5, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info5 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info5, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info5 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-index_name-value no-undo
field name-key  as character
field value-key as character
index pi name-key
.
define temp-table temp-sub-index_name no-undo
field name-key  as character
field nn as integer
index pi nn
.
procedure def-hash :
  do
  on error undo, return error return-value
  :
  define input  parameter p-full-string as character no-undo .
  define output parameter p-possb-keep-string as logical   no-undo .
  define output parameter p-string            as character no-undo .
  define output parameter p-hash-string       as character no-undo .
    p-full-string = trim( p-full-string ) .
    if length (p-full-string ) > 150 then do:
    assign
      p-possb-keep-string =  false
      p-string            =  substring(p-full-string,1,150)
      p-hash-string       =  encode(p-full-string)
    .
    end.
    else do:
    assign
      p-possb-keep-string =  true
      p-string            =  p-full-string
      p-hash-string       =  encode(p-full-string)
    .
    end.
  end.
end procedure.
procedure find-from-hash :
  do
  on error undo, return error return-value
  :
define input  parameter  p-full-string            as character no-undo .
define input  parameter  p-table-name             as character no-undo .
define input  parameter  p-field-possb-keep-name  as character no-undo .
define input  parameter  p-field-string-name      as character no-undo .
define input  parameter  p-field-hash-string-name as character no-undo .
define input  parameter  p-sub-table-name         as character no-undo .
define output parameter  p-recid                  as recid     no-undo .
define variable v-possb-keep-string as logical   no-undo .
define variable v-string            as character no-undo .
define variable v-hash-string       as character no-undo .
define variable v-query-prepare     as character no-undo .
define variable i  as integer no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable p-rez as logical   no-undo .
run def-hash in this-procedure (input  p-full-string ,
              output v-possb-keep-string ,
              output v-string            ,
              output v-hash-string
              ).
p-recid = ? .
create buffer bh for table p-table-name.
create query qh.
   v-query-prepare =
    "for each " + p-table-name + " no-lock where "
    + p-field-possb-keep-name   + " = "  + string(v-possb-keep-string) + " and "
    + p-field-string-name       + " = '" + v-string            + "' and "
    + p-field-hash-string-name  + " = '" + v-hash-string       + "'"
    .
if v-possb-keep-string = true then do:
    qh:set-buffers(bh).
    qh:query-prepare(v-query-prepare).
    qh:query-open.
    qh:get-first.
    p-recid = bh:recid.
end.
else do:
message false "анализ hash" .
  qh:set-buffers(bh).
  qh:query-prepare(v-query-prepare).
  qh:query-open.
  qh:get-first.
  p-recid = bh:recid.
  repeat :
    qh:get-next.
    if bh:available then do:
       qh:get-first.
       run ver-sub-table in this-procedure (
           input  p-full-string ,
           input  p-table-name ,
           input  p-sub-table-name ,
           input  bh:recid  ,
           output p-rez
           ).
       if p-rez = true  then do:
          p-recid = bh:recid .
          leave.
       end.
       else do:
         next.
       end.
    end.
    leave.
  end.
end.
delete widget bh.
delete widget qh.
  end.
end procedure.
procedure ver-sub-table :
  do
  on error undo, return error return-value
  :
define input  parameter p-full-string as character no-undo .
define input  parameter p-name-table as character no-undo .
define input  parameter p-sub-name-table as character no-undo .
define input  parameter p-recid as recid no-undo .
define output parameter p-ok as logical   no-undo .
define variable v-query-prepare     as character no-undo .
define variable i  as integer no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable p-rez as logical   no-undo .
for each temp-index_name-value : delete temp-index_name-value . end.
for each temp-sub-index_name : delete temp-sub-index_name . end.
    create buffer bh for table p-name-table.
    create query qh.
    v-query-prepare = "for each " + p-name-table + " no-lock where recid(" + p-name-table + ") = " + string ( p-recid ) .
    qh:set-buffers(bh).
    qh:query-prepare(v-query-prepare).
    qh:query-open.
    qh:get-first.
    p-recid = bh:recid.
define variable v-inf-ind AS CHAR NO-UNDO.
define variable v-name-pi as character no-undo .
define variable v-num-fl-inkey as integer   no-undo .
define variable v-num-fl       as integer   no-undo .
define variable j as integer   no-undo .
v-name-pi = bh:PRIMARY .
v-inf-ind = "1".
i = 0.
DO while ( v-inf-ind <> ? )
    on error undo, return error:
    i = i + 1 .
    v-inf-ind = bh:INDEX-INFORMATION(i) .
    if v-inf-ind = ? then leave.
    if entry( 1 , v-inf-ind ) = v-name-pi then do:
       v-num-fl-inkey = ( num-entries(v-inf-ind) - 4 ) / 2 .
       v-num-fl       = ( num-entries(v-inf-ind) - 4 )     .
      if v-num-fl-inkey >= 1 then do:
          do j = 5 to v-num-fl  by 2 :
              create temp-index_name-value .
              assign
                temp-index_name-value.name-key  = entry( j , v-inf-ind )
                temp-index_name-value.value-key = bh:BUFFER-FIELD(entry( j , v-inf-ind )):BUFFER-VALUE
              .
          end.
       end.
    end.
END.
define variable qh-sub as widget-handle no-undo .
define variable bh-sub as widget-handle no-undo .
    create buffer bh-sub for table p-sub-name-table.
    create query qh-sub.
define variable k as integer   no-undo init 0 .
    v-query-prepare = "for each " + p-sub-name-table + " no-lock where " .
    for each temp-index_name-value :
        v-query-prepare = v-query-prepare  + p-sub-name-table + "." + temp-index_name-value.name-key +
                      " = " + temp-index_name-value.value-key + " and " .
    end.
    v-query-prepare = v-query-prepare + " true = true " .
    qh-sub:set-buffers(bh-sub).
    qh-sub:query-prepare(v-query-prepare).
    qh-sub:query-open.
      v-name-pi = bh-sub:PRIMARY .
      v-inf-ind = "1".
      i = 0.
      DO while ( v-inf-ind <> ? )
          on error undo, return error:
          i = i + 1 .
          v-inf-ind = bh-sub:INDEX-INFORMATION(i) .
          if v-inf-ind = ? then leave.
          if entry( 1 , v-inf-ind ) = v-name-pi then do:
            v-num-fl-inkey = ( num-entries(v-inf-ind) - 4 ) / 2 .
            v-num-fl       = ( num-entries(v-inf-ind) - 4 )     .
            if v-num-fl-inkey >= 1 then do:
                do j = 5 to v-num-fl  by 2 :
                    if not can-find (first temp-index_name-value  where temp-index_name-value.name-key =  entry( j , v-inf-ind )) then do:
                        create temp-sub-index_name .
                        assign
                          temp-sub-index_name.name-key  = entry( j , v-inf-ind )
                          temp-sub-index_name.nn  = j
                        .
                    end.
                end.
            end.
          end.
      END.
      define variable v-qw as character no-undo .
      v-qw = "".
      qh-sub:GET-first.
      DO WHILE (bh-sub:AVAILABLE):
        for each temp-sub-index_name :
            v-qw = v-qw + string(bh-sub:BUFFER-FIELD(temp-sub-index_name.name-key):BUFFER-VALUE) .
        end.
        v-qw = v-qw + ",".
        qh-sub:GET-NEXT.
      END.
      p-ok = false .
      if trim(p-full-string, ",")  =  trim (v-qw, ",") then p-ok = true  .
    delete widget bh-sub.
    delete widget qh-sub.
    delete widget bh.
    delete widget qh.
  end.
end procedure.
PROCEDURE update-rang-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-a as decimal   no-undo .
define input  parameter p-b as decimal   no-undo .
define input  parameter p-c as decimal   no-undo .
define input  parameter p-d as decimal   no-undo .
define input  parameter p-e as decimal   no-undo .
define input  parameter p-f as decimal   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define buffer buf_rang-abc-def     for ub.rang-abc-def.
define buffer buf_rang-abc-def-obj for ub.rang-abc-def-obj.
find first buf_rang-abc-def exclusive-lock where recid(buf_rang-abc-def) = p-recid no-error .
if not available buf_rang-abc-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_rang-abc-def.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
end.
else do:
  assign
      v-exist = true
      p-id = buf_rang-abc-def.raad-id
      p-db = buf_rang-abc-def.db-num
      p-hash-string-obj       = buf_rang-abc-def.raad-hash-string-obj
      p-possb-keep-string-obj = buf_rang-abc-def.raad-possb-keep-string-obj
      p-string-obj            = buf_rang-abc-def.raad-string-obj
  .
end.
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_rang-abc-def.raad-hash-string-obj       = p-hash-string-obj
          buf_rang-abc-def.raad-possb-keep-string-obj = p-possb-keep-string-obj
          buf_rang-abc-def.raad-string-obj            = p-string-obj
          buf_rang-abc-def.raad-a                     = p-a
          buf_rang-abc-def.raad-b                     = p-b
          buf_rang-abc-def.raad-c                     = p-c
          buf_rang-abc-def.raad-d                     = p-d
          buf_rang-abc-def.raad-e                     = p-e
          buf_rang-abc-def.raad-f                     = p-f
          buf_rang-abc-def.raad-id                    = p-id
          buf_rang-abc-def.raad-date                  = v-date
          buf_rang-abc-def.raad-db-num                = g#db-num
          buf_rang-abc-def.db-num                     = p-db
          buf_rang-abc-def.raad-time                  = v-time
          buf_rang-abc-def.raad-who                   = g#userid
      .
if v-exist = true then do:
   for each buf_rang-abc-def-obj exclusive-lock where
            buf_rang-abc-def-obj.raad-id = buf_rang-abc-def.raad-id and
            buf_rang-abc-def-obj.db-num  = buf_rang-abc-def.db-num :
            delete buf_rang-abc-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, "," ).
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_rang-abc-def-obj.
  assign
    buf_rang-abc-def-obj.raad-id  = buf_rang-abc-def.raad-id
    buf_rang-abc-def-obj.db-num   = buf_rang-abc-def.db-num
    buf_rang-abc-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_rang-abc-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
RELEASE buf_rang-abc-def .
END PROCEDURE.
PROCEDURE update-rang-xyz-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-x as decimal   no-undo .
define input  parameter p-y as decimal   no-undo .
define input  parameter p-z as decimal   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define buffer buf_rang-xyz-def     for ub.rang-xyz-def.
define buffer buf_rang-xyz-def-obj for ub.rang-xyz-def-obj.
find first buf_rang-xyz-def exclusive-lock where recid(buf_rang-xyz-def) = p-recid no-error .
if not available buf_rang-xyz-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_rang-xyz-def.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
end.
else do:
  assign
      v-exist = true
      p-id = buf_rang-xyz-def.raxd-id
      p-db = buf_rang-xyz-def.db-num
      p-hash-string-obj       = buf_rang-xyz-def.raxd-hash-string-obj
      p-possb-keep-string-obj = buf_rang-xyz-def.raxd-possb-keep-string-obj
      p-string-obj            = buf_rang-xyz-def.raxd-string-obj
  .
end.
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_rang-xyz-def.raxd-hash-string-obj       = p-hash-string-obj
          buf_rang-xyz-def.raxd-possb-keep-string-obj = p-possb-keep-string-obj
          buf_rang-xyz-def.raxd-string-obj            = p-string-obj
          buf_rang-xyz-def.raxd-x                     = p-x
          buf_rang-xyz-def.raxd-y                     = p-y
          buf_rang-xyz-def.raxd-z                     = p-z
          buf_rang-xyz-def.raxd-id                    = p-id
          buf_rang-xyz-def.raxd-date                  = v-date
          buf_rang-xyz-def.raxd-db-num                = g#db-num
          buf_rang-xyz-def.db-num                     = p-db
          buf_rang-xyz-def.raxd-time                  = v-time
          buf_rang-xyz-def.raxd-who                   = g#userid
      .
if v-exist = true then do:
   for each buf_rang-xyz-def-obj exclusive-lock where
            buf_rang-xyz-def-obj.raxd-id = buf_rang-xyz-def.raxd-id and
            buf_rang-xyz-def-obj.db-num  = buf_rang-xyz-def.db-num :
            delete buf_rang-xyz-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, "," ).
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_rang-xyz-def-obj.
  assign
    buf_rang-xyz-def-obj.raxd-id  = buf_rang-xyz-def.raxd-id
    buf_rang-xyz-def-obj.db-num   = buf_rang-xyz-def.db-num
    buf_rang-xyz-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_rang-xyz-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
RELEASE buf_rang-xyz-def .
END PROCEDURE.
PROCEDURE update-doc-xyz-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-list-doc as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define variable  p-possb-keep-string-doc as logical   no-undo .
define variable  p-string-doc            as character no-undo .
define variable  p-hash-string-doc       as character no-undo .
define buffer buf_doc-xyz-def     for ub.doc-xyz-def.
define buffer buf_doc-xyz-def-obj for ub.doc-xyz-def-obj.
define buffer buf_doc-xyz-def-doc for ub.doc-xyz-def-doc.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
    run def-hash in this-procedure  (
         input   p-list-doc
        ,output  p-possb-keep-string-doc
        ,output  p-string-doc
        ,output  p-hash-string-doc
        ).
find first buf_doc-xyz-def exclusive-lock where recid(buf_doc-xyz-def) = p-recid no-error .
if not available buf_doc-xyz-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_doc-xyz-def.
end.
else do:
  assign
      v-exist = true
      p-id = buf_doc-xyz-def.doxd-id
      p-db = buf_doc-xyz-def.db-num
  .
end .
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_doc-xyz-def.doxd-hash-string-obj       = p-hash-string-obj
          buf_doc-xyz-def.doxd-possb-keep-string-obj = p-possb-keep-string-obj
          buf_doc-xyz-def.doxd-string-obj            = p-string-obj
          buf_doc-xyz-def.doxd-hash-string-doc       = p-hash-string-doc
          buf_doc-xyz-def.doxd-possb-keep-string-doc = p-possb-keep-string-doc
          buf_doc-xyz-def.doxd-string-doc            = p-string-doc
          buf_doc-xyz-def.doxd-id                    = p-id
          buf_doc-xyz-def.doxd-date                  = v-date
          buf_doc-xyz-def.doxd-db-num                = g#db-num
          buf_doc-xyz-def.doxd-time                  = v-time
          buf_doc-xyz-def.doxd-who                   = g#userid
          buf_doc-xyz-def.db-num                     = p-db
      .
if v-exist = true then do:
   for each buf_doc-xyz-def-doc exclusive-lock where
            buf_doc-xyz-def-doc.doxd-id = buf_doc-xyz-def.doxd-id and
            buf_doc-xyz-def-doc.db-num  = buf_doc-xyz-def.db-num :
            delete buf_doc-xyz-def-doc.
   end.
   for each buf_doc-xyz-def-obj exclusive-lock where
            buf_doc-xyz-def-obj.doxd-id = buf_doc-xyz-def.doxd-id and
            buf_doc-xyz-def-obj.db-num  = buf_doc-xyz-def.db-num :
            delete buf_doc-xyz-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, ",")  .
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_doc-xyz-def-obj.
  assign
    buf_doc-xyz-def-obj.doxd-id  = buf_doc-xyz-def.doxd-id
    buf_doc-xyz-def-obj.db-num   = buf_doc-xyz-def.db-num
    buf_doc-xyz-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_doc-xyz-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
p-list-doc = trim(p-list-doc , ",") .
k = num-entries(p-list-doc, ",") .
repeat  i = 1 to k :
  create buf_doc-xyz-def-doc.
  assign
    buf_doc-xyz-def-doc.doxd-id  = buf_doc-xyz-def.doxd-id
    buf_doc-xyz-def-doc.db-num   = buf_doc-xyz-def.db-num
    buf_doc-xyz-def-doc.dxdd-ext-doc-type = entry(i, p-list-doc)
  .
end.
RELEASE buf_doc-xyz-def .
END PROCEDURE.
PROCEDURE update-doc-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-list-doc as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define variable  p-possb-keep-string-doc as logical   no-undo .
define variable  p-string-doc            as character no-undo .
define variable  p-hash-string-doc       as character no-undo .
define buffer buf_doc-abc-def     for ub.doc-abc-def.
define buffer buf_doc-abc-def-obj for ub.doc-abc-def-obj.
define buffer buf_doc-abc-def-doc for ub.doc-abc-def-doc.
    run def-hash  in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
    run def-hash  in this-procedure (
         input   p-list-doc
        ,output  p-possb-keep-string-doc
        ,output  p-string-doc
        ,output  p-hash-string-doc
        ).
find first buf_doc-abc-def exclusive-lock where recid(buf_doc-abc-def) = p-recid no-error .
if not available buf_doc-abc-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_doc-abc-def.
end.
else do:
  assign
      v-exist = true
      p-id = buf_doc-abc-def.doad-id
      p-db = buf_doc-abc-def.db-num
  .
end .
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_doc-abc-def.doad-hash-string-obj       = p-hash-string-obj
          buf_doc-abc-def.doad-possb-keep-string-obj = p-possb-keep-string-obj
          buf_doc-abc-def.doad-string-obj            = p-string-obj
          buf_doc-abc-def.doad-hash-string-doc       = p-hash-string-doc
          buf_doc-abc-def.doad-possb-keep-string-doc = p-possb-keep-string-doc
          buf_doc-abc-def.doad-string-doc            = p-string-doc
          buf_doc-abc-def.doad-id                    = p-id
          buf_doc-abc-def.doad-date                  = v-date
          buf_doc-abc-def.doad-db-num                = g#db-num
          buf_doc-abc-def.doad-time                  = v-time
          buf_doc-abc-def.doad-who                   = g#userid
          buf_doc-abc-def.db-num                     = p-db
      .
if v-exist = true then do:
   for each buf_doc-abc-def-doc exclusive-lock where
            buf_doc-abc-def-doc.doad-id = buf_doc-abc-def.doad-id and
            buf_doc-abc-def-doc.db-num  = buf_doc-abc-def.db-num :
            delete buf_doc-abc-def-doc.
   end.
   for each buf_doc-abc-def-obj exclusive-lock where
            buf_doc-abc-def-obj.doad-id = buf_doc-abc-def.doad-id and
            buf_doc-abc-def-obj.db-num  = buf_doc-abc-def.db-num :
            delete buf_doc-abc-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, ",")  .
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_doc-abc-def-obj.
  assign
    buf_doc-abc-def-obj.doad-id  = buf_doc-abc-def.doad-id
    buf_doc-abc-def-obj.db-num   = buf_doc-abc-def.db-num
    buf_doc-abc-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_doc-abc-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
p-list-doc = trim(p-list-doc , ",") .
k = num-entries(p-list-doc, ",") .
repeat  i = 1 to k :
  create buf_doc-abc-def-doc.
  assign
    buf_doc-abc-def-doc.doad-id  = buf_doc-abc-def.doad-id
    buf_doc-abc-def-doc.db-num   = buf_doc-abc-def.db-num
    buf_doc-abc-def-doc.dadd-ext-doc-type = entry(i, p-list-doc)
  .
end.
RELEASE buf_doc-abc-def .
END PROCEDURE.
PROCEDURE find-def-analysis-obj :
define input  parameter p-type     as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-abc-id   as integer   no-undo .
define output parameter p-db-num   as integer   no-undo .
  do
  on error undo, return error return-value
  :
  if p-type = "abc"  then do:
      define buffer buf_abc-analysis-obj for ub.abc-analysis-obj  .
      define buffer buf_abc-analysis     for ub.abc-analysis      .
      find first buf_abc-analysis-obj no-lock where
                buf_abc-analysis-obj.obj-type = p-obj-type and
                buf_abc-analysis-obj.obj-code = p-obj-code and
                buf_abc-analysis-obj.is-def   = true use-index objdef no-error .
                if available buf_abc-analysis-obj then do:
                    p-abc-id = buf_abc-analysis-obj.abc-id .
                    p-db-num = buf_abc-analysis-obj.db-num .
                end.
                else do:
                    p-abc-id = 0 .
                    p-db-num = 0.
                    return "На объекте нет анализа по умолчанию" .
                end.
  end.
  if p-type = "xyz"  then do:
      define buffer buf_xyz-analysis-obj for ub.xyz-analysis-obj  .
      define buffer buf_xyz-analysis     for ub.xyz-analysis      .
      find first buf_xyz-analysis-obj no-lock where
                buf_xyz-analysis-obj.obj-type = p-obj-type and
                buf_xyz-analysis-obj.obj-code = p-obj-code and
                buf_xyz-analysis-obj.is-def   = true use-index objdef no-error .
                if available buf_xyz-analysis-obj then do:
                    p-abc-id = buf_xyz-analysis-obj.xyz-id .
                    p-db-num = buf_xyz-analysis-obj.db-num .
                end.
                else do:
                    p-abc-id = 0 .
                    p-db-num = 0 .
                    return "На объекте нет анализа по умолчанию" .
                end.
  end.
  return .
end.
END PROCEDURE.
procedure save-def-analysis-obj :
define input  parameter p-type     as character no-undo .
define input  parameter p-db-num   as integer   no-undo .
define input  parameter p-abc-id   as integer   no-undo .
define output parameter v-log      as logical   no-undo .
  do
  on error undo, return error return-value
  :
  v-log = true .
  if p-type = "abc"  then do:
      define buffer buf_abc-analysis-obj for ub.abc-analysis-obj  .
      define buffer buf_abc-obj          for ub.abc-analysis-obj  .
      define buffer buf_abc-analysis     for ub.abc-analysis      .
      for each buf_abc-obj no-lock where
               buf_abc-obj.abc-id = p-abc-id and
               buf_abc-obj.db-num = p-db-num :
            define variable v-exist    as logical   no-undo init false .
            define variable v-list-anal as character no-undo init ""    .
            for each  buf_abc-analysis-obj no-lock where
                      not (buf_abc-analysis-obj.abc-id = p-abc-id and
                           buf_abc-analysis-obj.db-num = p-db-num) and
                      buf_abc-analysis-obj.is-def   = true   and
                      buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                      buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code
                      :
                v-exist    = true .
                v-list-anal = string( buf_abc-analysis-obj.abc-id ) + "," .
            end.
            if v-exist then do:
                message "На объекте "
                buf_abc-obj.obj-type
                buf_abc-obj.obj-code
                skip
                "уже есть анализы по умолчанию , их внутренние номера :" skip
                v-list-anal                                              skip
                "Сделать по умолчанию анализ текущий " p-abc-id " ?"
                view-as alert-box question
                buttons yes-no update v-log .
                if v-log then do:
                    for each  buf_abc-analysis-obj exclusive-lock where
                              buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                              buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code :
                      if ( buf_abc-analysis-obj.abc-id = p-abc-id and
                           buf_abc-analysis-obj.db-num = p-db-num ) then
                              buf_abc-analysis-obj.is-def   = true .
                      else buf_abc-analysis-obj.is-def   = false  .
                    end.
                end.
            end.
            else do:
              for each  buf_abc-analysis-obj exclusive-lock where
                        buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                        buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code and
                        buf_abc-analysis-obj.abc-id = p-abc-id and
                        buf_abc-analysis-obj.db-num = p-db-num
                        :
                  buf_abc-analysis-obj.is-def   = true .
              end.
            end.
      end.
  end.
  if p-type = "xyz"  then do:
      define buffer buf_xyz-analysis-obj for ub.xyz-analysis-obj  .
      define buffer buf_xyz-obj          for ub.xyz-analysis-obj  .
      define buffer buf_xyz-analysis     for ub.xyz-analysis      .
      for each buf_xyz-obj no-lock where
               buf_xyz-obj.xyz-id = p-abc-id and
               buf_xyz-obj.db-num = p-db-num :
            v-exist = false .
            v-list-anal = ""    .
            for each  buf_xyz-analysis-obj no-lock where
                      not (buf_xyz-analysis-obj.xyz-id = p-abc-id and
                           buf_xyz-analysis-obj.db-num = p-db-num) and
                      buf_xyz-analysis-obj.is-def   = true   and
                      buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                      buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code
                      :
                v-exist    = true .
                v-list-anal = string( buf_xyz-analysis-obj.xyz-id ) + "," .
            end.
            if v-exist then do:
                message "На объекте "
                buf_xyz-obj.obj-type
                buf_xyz-obj.obj-code
                skip
                "уже есть анализы по умолчанию , их внутренние номера :" skip
                v-list-anal                                              skip
                "Сделать по умолчанию анализ текущий " p-abc-id " ?"
                view-as alert-box question
                buttons yes-no update v-log .
                if v-log then do:
                    for each  buf_xyz-analysis-obj exclusive-lock where
                              buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                              buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code :
                      if ( buf_xyz-analysis-obj.xyz-id = p-abc-id and
                           buf_xyz-analysis-obj.db-num = p-db-num ) then
                              buf_xyz-analysis-obj.is-def   = true .
                      else buf_xyz-analysis-obj.is-def   = false  .
                    end.
                end.
            end.
            else do:
              for each  buf_xyz-analysis-obj exclusive-lock where
                        buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                        buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code and
                        buf_xyz-analysis-obj.xyz-id = p-abc-id and
                        buf_xyz-analysis-obj.db-num = p-db-num
                        :
                  buf_xyz-analysis-obj.is-def   = true .
              end.
            end.
      end.
  end.
end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define stream slog .
on delete of ub.nws-doc-hist override do: end.
do
on error undo, return error return-value
:
  define variable v-password-check-string as character no-undo .
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define variable v-current-action as character no-undo .
  define variable v-current-time   as character no-undo .
  define variable v-start-time     as integer   no-undo .
  define variable v-uniq-key-rec as character no-undo .
  define variable v-ind      as integer   no-undo .
  define variable v-obj-type as character no-undo .
  define variable v-obj-code as integer   no-undo .
  define variable v-passwd   as character no-undo .
  assign
    v-start-time = time
  .
  def frame show-act
    v-current-action         format "x(50)"      no-label skip
    v-current-time           format "x(8)"       label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Удаление объекта"
    .
  view frame show-act.
  run log-information in this-procedure
    (input "check-input-parameters"
    ) .
  run check-input-parameters in this-procedure no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильно заданы входные параметры" skip
      "Пароли " p-pswd-list skip
      view-as alert-box error .
    undo, return error .
  end.
  find first buf_sys-ctrl no-lock .
  if g#news <> true then do:
    if buf_sys-ctrl.db-num <> 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Данная утилита предназначена для работы только в ГБД" ) skip
        view-as alert-box error
      .
      undo, return error .
    end.
    if  p-pswd-list = ""
    and p-check-string-file <> "" then do:
      output stream slog to value(p-check-string-file) .
      put stream slog unformatted "":U .
      output stream slog close .
      do v-ind = 1 to num-entries( p-obj-list, chr(44) ) by 2
      :
        assign
          v-obj-type = entry( v-ind, p-obj-list, chr(44) )
          v-obj-code = integer( entry( v-ind + 1, p-obj-list, chr(44) ) )
        .
        run generate-check-string in this-procedure
          ( input v-obj-type
          , input v-obj-code
          , output v-password-check-string
        ) .
        output stream slog to value(p-check-string-file) append.
        put stream slog unformatted v-password-check-string + chr(10) .
        output stream slog close .
      end.
      message
        "Информация о параметрах запуска сохранена в файле" skip
        "Имя файла" p-check-string-file skip
        "Отправьте файл в службу поддержки пользователей для получения лицензии" skip
        "на запуск программы с указанными параметрами." skip
        "По получению лицензии запустите утилиту еще раз." skip
        view-as alert-box information .
      return .
    end.
    else do:
      define variable v-check-passwd as character no-undo .
      do v-ind = 1 to num-entries( p-obj-list, chr(44) ) by 2
      :
        assign
          v-obj-type = entry( v-ind, p-obj-list, chr(44) )
          v-obj-code = integer( entry( v-ind + 1, p-obj-list, chr(44) ) )
          v-passwd   = entry( integer((v-ind + 1) / 2), p-pswd-list, chr(44) )
        .
        run generate-check-string in this-procedure
          ( input v-obj-type
          , input v-obj-code
          , output v-password-check-string
          ) .
        run adm/pswd-enc.p
          (input  v-password-check-string
          ,output v-check-passwd
          ) no-error .
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке пароля"
            return-value skip
            error-status :get-message(1) skip
            view-as alert-box error .
          undo, return error .
        end.
        if v-passwd <> v-check-passwd then do:
          message
            "Неправильный пароль" skip
            "Параметры запуска программы" v-password-check-string skip
            substitute( "Объект &1 &2", v-obj-type, v-obj-code ) skip
            substitute( "Пароль &1", v-passwd ) skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.
  do v-ind = 1 to num-entries( p-obj-list, chr(44) ) by 2
  :
    assign
      v-obj-type = entry( v-ind, p-obj-list, chr(44) )
      v-obj-code = integer( entry( v-ind + 1, p-obj-list, chr(44) ) )
      frame show-act:title = substitute( "Удаление объекта &1 &2", v-obj-type, v-obj-code )
    .
    run log-information in this-procedure
      (input substitute( "Удаление объекта &1 &2", v-obj-type, v-obj-code )
      ) .
    run log-information in this-procedure
      (input "check-can-delete"
      ) .
    run check-can-delete in this-procedure
        ( input v-obj-type
        , input v-obj-code
      ) no-error .
    if error-status :error then do:
      message
        "Невозможно произвести удаление объекта" skip
        "Удаление объекта может привести к нарушению работы других объектов" skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-check-rest then do:
      run log-information in this-procedure
        (input "utl/delobjck.p"
        ) .
      run utl/delobjck.p
        (input v-obj-type
        ,input v-obj-code
        ) no-error .
      if error-status :error then do:
        message
          "Невозможно провести удаление объекта" skip
          "На объекте существуют товарные остатки или незакрытые документы" skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    run log-information in this-procedure
      (input "check-can-delete"
      ) .
    run check-can-delete in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ) .
    run log-information in this-procedure
      (input "delete-batch-process"
      ) .
    run delete-batchprocess in this-procedure
        (input v-obj-type
        ,input v-obj-code
      ) .
    run log-information in this-procedure
      (input "delete-nws-doc-hist"
      ) .
    run delete-nws-doc-hist in this-procedure
      (input v-obj-type
      ,input v-obj-code
      ) .
  run log-information in this-procedure
    (input "delete-gds-obj"
    ) .
  run delete-gds-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-inkas"
    ) .
  run delete-inkas in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-trn-doc"
    ) .
  run delete-trn-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-price-doc"
    ) .
  run delete-price-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-rvs-doc"
    ) .
  run delete-rvs-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-wth-doc"
    ) .
  run delete-wth-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-icnt-doc"
    ) .
  run delete-icnt-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-chk-doc"
    ) .
  run delete-chk-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-recipe"
    ) .
  run delete-recipe in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-fbr-doc"
    ) .
  run delete-fbr-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-fbr-pln"
    ) .
  run delete-fbr-pln in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-fbr-gds-grp"
    ) .
  run delete-fbr-gds-grp in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-fbr-prn"
    ) .
  run delete-fbr-prn in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-obj-date"
    ) .
  run delete-obj-date in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-ord-doc"
    ) .
  run delete-ord-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-add-doc"
    ) .
  run delete-add-doc in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-shift-obj"
    ) .
  run delete-shift-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-nozzle-pump"
    ) .
  run delete-place-nozzle-pump in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-stk-archive"
    ) .
  run delete-stk-archive in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-tax"
    ) .
  run delete-tax in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-dis-obj"
    ) .
  run delete-dis-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-dis-dc-rule"
    ) .
  run delete-dis-dc-rule in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-dis-card-type"
    ) .
  run delete-dis-card-type in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-dis-rule"
    ) .
  run delete-dis-rule in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-variant-delivery"
    ) .
  run delete-variant-delivery in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-gds-grp-obj"
    ) .
  run delete-gds-grp-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-sum-grp-obj"
    ) .
  run delete-sum-grp-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-scales-gds"
    ) .
  run delete-scales-gds in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
    run log-information in this-procedure
      (input "delete-assortment-matrix"
      ) .
  run delete-assortment-matrix in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "finish-delete-assortment-matrix"
    ) .
  run delete-gds-obj-prop in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "finish-delete-gds-obj-prop"
    ) .
  run log-information in this-procedure
    (input "delete-config"
    ) .
  run delete-config in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-user-obj"
    ) .
  run delete-user-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-action-post-obj"
    ) .
  run delete-action-post-obj in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-clients"
    ) .
  run delete-clients in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ,output v-uniq-key-rec
    ) .
run log-information in this-procedure
    (input "delete-arh-trn-doc-contract"
    ) .
  run delete-arh-trn-doc-contract in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-place-io"
    ) .
  run delete-place-io in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-stop-list"
    ) .
  run delete-stop-list in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-convert-payment"
    ) .
  run convert-payment in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "convert-payment"
    ) .
  run log-information in this-procedure
    (input "delete-ext-classif"
    ) .
  run delete-ext-classif in this-procedure
    (input v-uniq-key-rec
    ,input v-obj-type
    ,input v-obj-code
    ) .
  run log-information in this-procedure
    (input "delete-egais"
    ) .
  run delete-egais in this-procedure
    (input v-obj-type
    ,input v-obj-code
    ) .
  if g#news <> true then do:
   run log-information in this-procedure
     (input "send command"
     ) .
   run nws/cr-route.p
      ( input 'send-cmd':U
       ,input "command":U + chr(1) + "delete-object":U + chr(1) + v-obj-type + chr(1) + string( v-obj-code )
       ,input ?
       ,input "":U
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при маршрутизации команды на удаление объекта &1 &2.", v-obj-type, v-obj-code ) skip
        return-value skip
        error-status :get-message ( 1 )
        view-as alert-box error
      .
      undo, return error .
    end.
  end.
  run log-information in this-procedure
    (input substitute( "finish-delete-object &1 &2", v-obj-type, v-obj-code )
    ) .
  end.
  hide frame show-act.
end.
procedure log-information :
  define input  parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-today as date      no-undo .
    define variable v-time  as integer   no-undo .
    output stream slog to value('del-obj.log') append .
    export stream slog v-obj-type v-obj-code cur-time-string() p-message .
    output stream slog close .
    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ) .
    assign
      v-current-time = string(time - v-start-time, "HH:MM:SS")
      v-current-action = p-message
    .
    display
      v-current-time v-current-action
      with frame show-act .
    process events .
  end.
end procedure.
procedure check-input-parameters :
  define buffer buf_clients  for ub.clients .
  do
  on error undo, return error substitute( "&1 (check-input-parameters). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    define variable v-ind      as integer   no-undo .
    define variable v-obj-type as character no-undo .
    define variable v-obj-code as integer   no-undo .
    do v-ind = 1 to num-entries( p-obj-list, chr(44) ) by 2
    :
      assign
        v-obj-type = entry( v-ind, p-obj-list, chr(44) )
        v-obj-code = integer( entry( v-ind + 1, p-obj-list, chr(44) ) )
      .
      find first buf_clients exclusive-lock
        where buf_clients.obj-type = v-obj-type
          and buf_clients.obj-code = v-obj-code
        no-error .
      if not available buf_clients then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Неизвестный объект" v-obj-type v-obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure delete-route :
  define input parameter p-tbl-name   as character no-undo .
  define input parameter p-tbl-handle as handle    no-undo .
  do
  on error undo, return error
  :
    define buffer buf_route   for ub.route .
    define variable v-key-rec as character no-undo .
    run gen-key-rec ( input  p-tbl-name
                     ,input  p-tbl-handle
                     ,output v-key-rec
                    ) no-error .
    if not error-status :error then do:
      for each buf_route exclusive-lock
        where buf_route.uniq-key-rec = v-key-rec
      on error undo, return error
      :
        delete buf_route .
      end.
    end.
  end.
end procedure.
procedure delete-gds-obj :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_c-gds-obj      for ub.c-gds-obj .
  define buffer buf_c-gds-obj-ref  for ub.c-gds-obj-ref .
  define buffer buf_gds-obj-attr for ub.gds-obj-attr .
  define buffer buf_c-gds-obj-attr for ub.c-gds-obj-attr .
  define buffer buf_bar-code-obj-attr for ub.bar-code-obj-attr .
  define buffer buf_c-bar-code-obj-attr for ub.c-bar-code-obj-attr .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_parts        for ub.parts .
  define buffer buf_parts-obj-attr    for ub.parts-obj-attr .
  define buffer buf_c-parts-obj-attr    for ub.c-parts-obj-attr .
  define buffer buf_fbr-gds-obj  for ub.fbr-gds-obj.
  define buffer buf_c-fbr-gds-obj  for ub.c-fbr-gds-obj.
  define buffer buf_varianty-delivery-gds-obj for ub.varianty-delivery-gds-obj.
  define buffer buf_c-varianty-delivery-gds-obj for ub.c-varianty-delivery-gds-obj.
  define buffer buf_c-gds-hist  for ub.c-gds-hist.
  define buffer buf_s-coeff for ub.s-coeff.
  define buffer buf_c-s-coeff for ub.c-s-coeff.
  define buffer buf_fbr-prn-gds for ub.fbr-prn-gds.
  define buffer buf_c-fbr-prn-gds for ub.fbr-prn-gds.
  define buffer buf_fbr-prn-grp for ub.fbr-prn-grp.
  define buffer buf_c-fbr-prn-grp for ub.fbr-prn-grp.
  define buffer buf_dis-gds-rule for ub.dis-gds-rule .
  define buffer buf_c-dis-gds-rule for ub.c-dis-gds-rule .
  define buffer buf_dis-grp-rule for ub.dis-grp-rule .
  define buffer buf_c-dis-grp-rule for ub.c-dis-grp-rule .
  define buffer buf_dis-dc-rule for ub.dis-dc-rule .
  define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule .
  define buffer buf_dis-dct-rule for ub.dis-dct-rule .
  define buffer buf_c-dis-dct-rule for ub.c-dis-dct-rule .
  define buffer buf_dis-some-rule for ub.dis-some-rule .
  define buffer buf_c-dis-some-rule for ub.c-dis-some-rule .
  on delete of ub.gds-obj-attr override do: end.
  on delete of ub.bar-code-obj-attr override do: end.
  on delete of ub.c-bar-code-obj-attr override do: end.
  on delete of ub.fbr-gds-obj override do: end.
  on delete of ub.c-gds-obj-attr override do: end.
  on delete of ub.c-gds-obj-ref override do: end.
  on delete of ub.c-fbr-gds-obj override do: end.
  on delete of ub.s-coeff override do: end.
  on delete of ub.c-s-coeff override do: end.
  on delete of ub.varianty-delivery-gds-obj override do: end.
  on delete of ub.c-varianty-delivery-gds-obj override do: end.
  on delete of ub.c-gds-hist override do: end.
  on delete of ub.fbr-prn-gds override do: end.
  on delete of ub.c-fbr-prn-gds override do: end.
  on delete of ub.fbr-prn-grp override do: end.
  on delete of ub.c-fbr-prn-grp override do: end.
  on delete of ub.dis-gds-rule override do: end.
  on delete of ub.c-dis-gds-rule override do: end.
  on delete of ub.dis-grp-rule override do: end.
  on delete of ub.c-dis-grp-rule override do: end.
  on delete of ub.dis-dc-rule override do: end.
  on delete of ub.c-dis-dc-rule override do: end.
  on delete of ub.dis-dct-rule override do: end.
  on delete of ub.c-dis-dct-rule override do: end.
  on delete of ub.dis-some-rule override do: end.
  on delete of ub.c-dis-some-rule override do: end.
  on delete of ub.parts-obj-attr override do: end.
  on delete of ub.c-parts-obj-attr override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_gds-obj exclusive-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_gds-obj .
    end.
    for each buf_c-gds-obj exclusive-lock
      where buf_c-gds-obj.obj-type = p-obj-type
        and buf_c-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-gds-obj .
    end.
    for each buf_c-gds-obj-ref exclusive-lock
      where buf_c-gds-obj-ref.obj-type = p-obj-type
        and buf_c-gds-obj-ref.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-gds-obj-ref.
    end.
    for each buf_gds-obj-attr exclusive-lock
      where buf_gds-obj-attr.obj-type = p-obj-type
        and buf_gds-obj-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'gds-obj-attr':U
         ,input (buffer buf_gds-obj-attr:handle)
        ) .
      delete buf_gds-obj-attr .
    end.
    for each buf_c-gds-obj-attr exclusive-lock
      where buf_c-gds-obj-attr.obj-type = p-obj-type
        and buf_c-gds-obj-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-gds-obj-attr':U
         ,input (buffer buf_c-gds-obj-attr:handle)
        ) .
      delete buf_c-gds-obj-attr .
    end.
    for each buf_bar-code-obj-attr exclusive-lock
      where buf_bar-code-obj-attr.obj-type  = p-obj-type
        and buf_bar-code-obj-attr.obj-code  = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'bar-code-obj-attr':U
         ,input (buffer buf_bar-code-obj-attr:handle)
        ) .
      delete buf_bar-code-obj-attr .
    end.
    for each buf_c-bar-code-obj-attr exclusive-lock
      where buf_c-bar-code-obj-attr.obj-type  = p-obj-type
        and buf_c-bar-code-obj-attr.obj-code  = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-bar-code-obj-attr':U
         ,input (buffer buf_c-bar-code-obj-attr:handle)
        ) .
      delete buf_c-bar-code-obj-attr .
    end.
    for each buf_prt-obj exclusive-lock
      where buf_prt-obj.obj-type = p-obj-type
        and buf_prt-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'prt-obj':U
         ,input (buffer buf_prt-obj:handle)
        ) .
      delete buf_prt-obj .
    end.
    for each buf_parts exclusive-lock
      where buf_parts.obj-type = p-obj-type
        and buf_parts.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_parts .
    end.
    for each buf_parts-obj-attr exclusive-lock
      where buf_parts-obj-attr.obj-type = p-obj-type
        and buf_parts-obj-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_parts-obj-attr .
    end.
    for each buf_c-parts-obj-attr exclusive-lock
      where buf_c-parts-obj-attr.obj-type = p-obj-type
        and buf_c-parts-obj-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-parts-obj-attr .
    end.
    for each buf_fbr-gds-obj exclusive-lock
      where buf_fbr-gds-obj.obj-type = p-obj-type
        and buf_fbr-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'fbr-gds-obj':U
         ,input (buffer buf_fbr-gds-obj:handle)
        ) .
      delete buf_fbr-gds-obj .
    end.
    for each buf_c-fbr-gds-obj exclusive-lock
      where buf_c-fbr-gds-obj.obj-type = p-obj-type
        and buf_c-fbr-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-fbr-gds-obj':U
         ,input (buffer buf_c-fbr-gds-obj:handle)
        ) .
      delete buf_c-fbr-gds-obj .
    end.
    for each buf_s-coeff exclusive-lock
      where buf_s-coeff.obj-type = p-obj-type
        and buf_s-coeff.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-s-coeff exclusive-lock
        where buf_c-s-coeff.gds-code = buf_s-coeff.gds-code
          and buf_c-s-coeff.host-code = buf_s-coeff.host-code
          and buf_c-s-coeff.obj-type = p-obj-type
          and buf_c-s-coeff.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'c-s-coeff':U
          ,input (buffer buf_c-s-coeff:handle)
          ) .
        delete buf_c-s-coeff .
      end.
      run delete-route in this-procedure
        ( input 's-coeff':U
         ,input (buffer buf_s-coeff:handle)
        ) .
      delete buf_s-coeff .
    end.
    for each buf_varianty-delivery-gds-obj exclusive-lock
      where buf_varianty-delivery-gds-obj.obj-type = p-obj-type
        and buf_varianty-delivery-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'varianty-delivery-gds-obj':U
         ,input (buffer buf_varianty-delivery-gds-obj:handle)
        ) .
      delete buf_varianty-delivery-gds-obj .
    end.
    for each buf_c-varianty-delivery-gds-obj exclusive-lock
      where buf_c-varianty-delivery-gds-obj.obj-type = p-obj-type
        and buf_c-varianty-delivery-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-varianty-delivery-gds-obj':U
         ,input (buffer buf_c-varianty-delivery-gds-obj:handle)
        ) .
      delete buf_c-varianty-delivery-gds-obj .
    end.
    for each buf_c-gds-hist exclusive-lock
      where buf_c-gds-hist.obj-type = p-obj-type
        and buf_c-gds-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-gds-hist':U
         ,input (buffer buf_c-gds-hist:handle)
        ) .
      delete buf_c-gds-hist .
    end.
    for each buf_fbr-prn-gds exclusive-lock
      where buf_fbr-prn-gds.obj-type = p-obj-type
        and buf_fbr-prn-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'fbr-prn-gds':U
         ,input (buffer buf_fbr-prn-gds:handle)
        ) .
      delete buf_fbr-prn-gds .
    end.
    for each buf_c-fbr-prn-gds exclusive-lock
      where buf_c-fbr-prn-gds.obj-type = p-obj-type
        and buf_c-fbr-prn-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-fbr-prn-gds':U
         ,input (buffer buf_c-fbr-prn-gds:handle)
        ) .
      delete buf_c-fbr-prn-gds .
    end.
    for each buf_fbr-prn-grp exclusive-lock
      where buf_fbr-prn-grp.obj-type = p-obj-type
        and buf_fbr-prn-grp.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'fbr-prn-grp':U
         ,input (buffer buf_fbr-prn-grp:handle)
        ) .
      delete buf_fbr-prn-grp .
    end.
    for each buf_c-fbr-prn-grp exclusive-lock
      where buf_c-fbr-prn-grp.obj-type = p-obj-type
        and buf_c-fbr-prn-grp.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-fbr-prn-grp':U
         ,input (buffer buf_c-fbr-prn-grp:handle)
        ) .
      delete buf_c-fbr-prn-grp .
    end.
    for each buf_dis-gds-rule exclusive-lock
      where buf_dis-gds-rule.obj-type = p-obj-type
        and buf_dis-gds-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'dis-gds-rule':U
         ,input (buffer buf_dis-gds-rule:handle)
        ) .
      delete buf_dis-gds-rule .
    end.
    for each buf_c-dis-gds-rule exclusive-lock
      where buf_c-dis-gds-rule.obj-type = p-obj-type
        and buf_c-dis-gds-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-dis-gds-rule':U
         ,input (buffer buf_c-dis-gds-rule:handle)
        ) .
      delete buf_c-dis-gds-rule .
    end.
  end.
end procedure.
procedure delete-inkas :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define variable v-host-code as integer no-undo .
  define buffer buf_inkas for ub.inkas .
  define buffer buf_inkas-pay for ub.inkas-pay .
  define buffer buf_inkas-pay-desk for ub.inkas-pay-desk .
  define buffer buf_inkas-pay-wth for ub.inkas-pay-wth .
  define buffer buf_sale-doc for ub.sale-doc.
  define buffer buf_c-inkas for ub.c-inkas .
  define buffer buf_c-inkas-pay for ub.c-inkas-pay .
  define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk .
  define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth .
  define buffer buf_c-sale-doc for ub.c-sale-doc.
  define buffer buf_payment for ub.payment .
  define buffer buf_sysconf for ub.sysconf.
  on delete of ub.inkas override do: end.
  on delete of ub.c-inkas override do: end.
  on delete of ub.inkas-pay override do: end.
  on delete of ub.c-inkas-pay override do: end.
  on delete of ub.inkas-pay-desk override do: end.
  on delete of ub.c-inkas-pay-desk override do: end.
  on delete of ub.inkas-pay-wth override do: end.
  on delete of ub.c-inkas-pay-wth override do: end.
  on write of ub.payment override do: end.
  on delete of ub.sale-doc override do: end.
  on delete of ub.c-sale-doc override do: end.
  do
  on error undo, return error return-value
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = v-host-code.
    for each buf_inkas exclusive-lock
      where buf_inkas.obj-type = p-obj-type
        and buf_inkas.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_sale-doc exclusive-lock
        where buf_sale-doc.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_sale-doc .
      end.
      for each buf_c-sale-doc exclusive-lock
        where buf_c-sale-doc.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-sale-doc .
      end.
      for each buf_inkas-pay exclusive-lock
        where buf_inkas-pay.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_inkas-pay .
      end.
      for each buf_inkas-pay-desk exclusive-lock
        where buf_inkas-pay-desk.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_inkas-pay-desk .
      end.
      for each buf_inkas-pay-wth exclusive-lock
        where buf_inkas-pay-wth.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_inkas-pay-wth .
      end.
      for each buf_payment exclusive-lock
        where buf_payment.source-type = 'касс':U AND
              buf_payment.source-ref = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        assign
        buf_payment.source-type = 'платежи':U
        buf_payment.pay-code = buf_sysconf.cash-pay
        buf_payment.PS = substitute("!смена типа платежа/кода оплаты после удаления объекта &1&2", p-obj-type, p-obj-code)
        .
      end.
      for each buf_c-inkas exclusive-lock
        where buf_c-inkas.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas .
      end.
      for each buf_c-inkas-pay exclusive-lock
        where buf_c-inkas-pay.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay .
      end.
      for each buf_c-inkas-pay-desk exclusive-lock
        where buf_c-inkas-pay-desk.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay-desk .
      end.
      for each buf_c-inkas-pay-wth exclusive-lock
        where buf_c-inkas-pay-wth.inkas-code = buf_inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay-wth .
      end.
      run delete-route in this-procedure
        ( input 'inkas':U
         ,input (buffer buf_inkas:handle)
        ) .
      delete buf_inkas .
    end.
    for each buf_c-inkas exclusive-lock
      where buf_c-inkas.obj-type = p-obj-type
        and buf_c-inkas.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-sale-doc exclusive-lock
        where buf_c-sale-doc.inkas-code = buf_c-inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-sale-doc .
      end.
      for each buf_c-inkas-pay exclusive-lock
        where buf_c-inkas-pay.inkas-code = buf_c-inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay .
      end.
      for each buf_c-inkas-pay-desk exclusive-lock
        where buf_c-inkas-pay-desk.inkas-code = buf_c-inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay-desk .
      end.
      for each buf_c-inkas-pay-wth exclusive-lock
        where buf_c-inkas-pay-wth.inkas-code = buf_c-inkas.inkas-code
      on error undo, return error return-value
      :
        delete buf_c-inkas-pay-wth .
      end.
      for each buf_payment exclusive-lock
        where buf_payment.source-type = 'касс':U AND
              buf_payment.source-ref = buf_c-inkas.inkas-code
      on error undo, return error return-value
      :
        assign
        buf_payment.source-type = 'платежи':U
        buf_payment.pay-code = buf_sysconf.cash-pay
        buf_payment.PS = substitute("!смена типа платежа/кода оплаты после удаления объекта &1&2", p-obj-type, p-obj-code)
        .
      end.
      run delete-route in this-procedure
        ( input 'c-inkas':U
         ,input (buffer buf_c-inkas:handle)
        ) .
      delete buf_c-inkas .
    end.
  end.
end procedure.
procedure delete-trn-doc :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_trn-doc       for ub.trn-doc .
  define buffer buf_doc-attr      for ub.doc-attr .
  define buffer buf_doc-line      for ub.doc-line .
  define buffer buf_gds-dtl       for ub.gds-dtl .
  define buffer buf_doc-prts      for ub.doc-prts .
  define buffer buf_doc-pl        for ub.doc-pl .
  define buffer buf_doc-pl-pump   for ub.doc-pl-pump .
  define buffer buf_doc-line-attr for ub.doc-line-attr .
  define buffer buf_c-trn-doc       for ub.c-trn-doc .
  define buffer buf_c-doc-attr      for ub.c-doc-attr .
  define buffer buf_c-doc-line      for ub.c-doc-line .
  define buffer buf_c-gds-dtl       for ub.c-gds-dtl .
  define buffer buf_c-doc-prts      for ub.c-doc-prts .
  define buffer buf_c-doc-pl        for ub.c-doc-pl .
  define buffer buf_c-doc-pl-pump   for ub.c-doc-pl-pump .
  define buffer buf_c-doc-line-attr for ub.c-doc-line-attr .
  define buffer buf_c-inv-line      for ub.c-inv-line .
  define buffer buf_inv-line      for ub.inv-line .
  define buffer buf_doc-fbr-gds   for ub.doc-fbr-gds .
  define buffer buf_c-doc-fbr-gds for ub.c-doc-fbr-gds .
  define buffer buf_arh-trn-doc-contract for ub.arh-trn-doc-contract.
  define buffer buf_payment       for ub.payment.
  on delete of ub.trn-doc  override do: end.
  on delete of ub.c-trn-doc  override do: end.
  on delete of ub.doc-line override do: end.
  do
  on error undo, return error
  :
    for each buf_trn-doc exclusive-lock
      where buf_trn-doc.obj-type = p-obj-type
        and buf_trn-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'trn-doc':U
         ,input (buffer buf_trn-doc:handle)
        ) .
      for each buf_doc-attr exclusive-lock
        where buf_doc-attr.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-attr .
      end.
      for each buf_doc-line exclusive-lock
        where buf_doc-line.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-line .
      end.
      for each buf_gds-dtl exclusive-lock
        where buf_gds-dtl.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_gds-dtl .
      end.
      for each buf_doc-prts exclusive-lock
        where buf_doc-prts.out-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-prts .
      end.
      for each buf_doc-pl exclusive-lock
        where buf_doc-pl.out-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-pl.
      end.
      for each buf_doc-pl-pump exclusive-lock
        where buf_doc-pl-pump.out-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-pl-pump.
      end.
      for each buf_doc-line-attr exclusive-lock
        where buf_doc-line-attr.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-line-attr .
      end.
      for each buf_inv-line exclusive-lock
        where buf_inv-line.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_inv-line .
      end.
      for each buf_doc-fbr-gds exclusive-lock
        where buf_doc-fbr-gds.out-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_doc-fbr-gds.
      end.
      for each buf_arh-trn-doc-contract exclusive-lock
        where buf_arh-trn-doc-contract.doc-code = buf_trn-doc.doc-code
      on error undo, return error
      :
        delete buf_arh-trn-doc-contract.
      end.
      if buf_trn-doc.d-card <> '':U then do:
        for each buf_payment exclusive-lock
          where buf_payment.source-type = 'накл':U AND
                buf_payment.source-ref = buf_trn-doc.doc-code
        on error undo, return error return-value
        :
          assign
          buf_payment.source-type = 'платежи':U
          buf_payment.PS = substitute("!смена типа платежа после удаления объекта &1&2", p-obj-type, p-obj-code)
          .
        end.
      end.
      run delete-ot-archive in this-procedure
        (input buf_trn-doc.doc-code
        ) .
      delete buf_trn-doc .
    end.
    for each buf_c-trn-doc exclusive-lock
      where buf_c-trn-doc.obj-type = p-obj-type
        and buf_c-trn-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-trn-doc':U
         ,input (buffer buf_c-trn-doc:handle)
        ) .
      for each buf_c-doc-attr exclusive-lock
        where buf_c-doc-attr.doc-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_c-doc-attr .
      end.
      for each buf_c-doc-line exclusive-lock
        where buf_c-doc-line.doc-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_c-doc-line .
      end.
      for each buf_c-gds-dtl exclusive-lock
        where buf_c-gds-dtl.doc-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_c-gds-dtl .
      end.
      for each buf_c-doc-prts exclusive-lock
        where buf_c-doc-prts.out-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_c-doc-prts .
      end.
      for each buf_c-doc-pl exclusive-lock
        where buf_c-doc-pl.out-code = buf_c-trn-doc.doc-code
          and buf_c-doc-pl.obj-code = buf_c-trn-doc.obj-code
          and buf_c-doc-pl.obj-type = buf_c-trn-doc.obj-type
      on error undo, return error
      :
        delete buf_c-doc-pl.
      end.
      for each buf_c-doc-pl-pump exclusive-lock
        where buf_c-doc-pl-pump.out-code = buf_c-trn-doc.doc-code
          and buf_c-doc-pl-pump.obj-code = buf_c-trn-doc.obj-code
          and buf_c-doc-pl-pump.obj-type = buf_c-trn-doc.obj-type
      on error undo, return error
      :
        delete buf_c-doc-pl-pump.
      end.
      for each buf_c-doc-line-attr exclusive-lock
        where buf_c-doc-line-attr.doc-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_c-doc-line-attr .
      end.
      for each buf_c-inv-line exclusive-lock
        where buf_c-inv-line.doc-code = buf_c-trn-doc.doc-code
          and buf_c-inv-line.chip-num = buf_c-trn-doc.chip-num
      on error undo, return error
      :
        delete buf_c-inv-line .
      end.
      for each buf_c-doc-fbr-gds exclusive-lock
        where buf_c-doc-fbr-gds.out-code = buf_trn-doc.doc-code
          and buf_c-doc-fbr-gds.obj-code = buf_trn-doc.obj-code
          and buf_c-doc-fbr-gds.obj-type = buf_trn-doc.obj-type
      on error undo, return error
      :
        delete buf_c-doc-fbr-gds.
      end.
      if buf_c-trn-doc.d-card <> '':U then do:
        for each buf_payment exclusive-lock
          where buf_payment.source-type = 'накл':U AND
                buf_payment.source-ref = buf_c-trn-doc.doc-code
        on error undo, return error return-value
        :
          assign
          buf_payment.source-type = 'платежи':U
          buf_payment.PS = substitute("!смена типа платежа после удаления объекта &1&2", p-obj-type, p-obj-code)
          .
        end.
      end.
      for each buf_arh-trn-doc-contract exclusive-lock
        where buf_arh-trn-doc-contract.doc-code = buf_c-trn-doc.doc-code
      on error undo, return error
      :
        delete buf_arh-trn-doc-contract.
      end.
      run delete-ot-archive in this-procedure
        (input buf_c-trn-doc.doc-code
        ) .
      delete buf_c-trn-doc .
    end.
  end.
end procedure.
procedure delete-price-doc :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_price-list for ub.price-list .
  define buffer buf_doc-attr for ub.doc-attr .
  define buffer buf_price-list-attr for ub.price-list-attr .
  define buffer buf_price-all for ub.price-all .
  define buffer buf_c-price-doc for ub.c-price-doc .
  define buffer buf_c-price-list for ub.c-price-list .
  define buffer buf_c-price-list-attr for ub.c-price-list-attr .
  define buffer buf_c-doc-attr for ub.c-doc-attr  .
  on delete of ub.price-doc override do: end.
  do
  on error undo, return error
  :
    for each buf_price-all exclusive-lock
      where buf_price-all.obj-type = p-obj-type
        and buf_price-all.obj-code = p-obj-code
    on error undo, return error
    :
      delete buf_price-all.
    end.
    for each buf_price-doc exclusive-lock
      where buf_price-doc.obj-type = p-obj-type
        and buf_price-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'price-doc':U
         ,input (buffer buf_price-doc:handle)
        ) .
      for each buf_price-list exclusive-lock
        where buf_price-list.doc-num = buf_price-doc.doc-num
      on error undo, return error
      :
        delete buf_price-list .
      end.
      for each buf_price-list-attr exclusive-lock
        where buf_price-list-attr.doc-num = buf_price-doc.doc-num
      on error undo, return error
      :
        delete buf_price-list-attr .
      end.
      for each buf_doc-attr exclusive-lock
        where buf_doc-attr.doc-code = buf_price-doc.doc-num
      on error undo, return error
      :
        delete buf_doc-attr .
      end.
      run delete-ot-archive in this-procedure
        (input buf_price-doc.doc-num
        ) .
      delete buf_price-doc.
    end.
    for each buf_c-price-doc exclusive-lock
      where buf_c-price-doc.obj-type = p-obj-type
        and buf_c-price-doc.obj-code = p-obj-code
    on error undo, return error
    :
      for each buf_c-price-list exclusive-lock
        where buf_c-price-list.doc-num = buf_c-price-doc.doc-num
      on error undo, return error
      :
        delete buf_c-price-list .
      end.
      for each buf_c-price-list-attr exclusive-lock
        where buf_c-price-list-attr.doc-num = buf_c-price-doc.doc-num
      on error undo, return error
      :
        delete buf_c-price-list-attr .
      end.
      for each buf_c-doc-attr exclusive-lock
        where buf_c-doc-attr.doc-code = buf_c-price-doc.doc-num
      on error undo, return error
      :
        delete buf_c-doc-attr .
      end.
      delete buf_c-price-doc.
    end.
  end.
end procedure.
procedure delete-rvs-doc :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_rvs-doc  for ub.rvs-doc .
  define buffer buf_rvs-line for ub.rvs-line .
  define buffer buf_rvs-line-pump for ub.rvs-line-pump .
  on delete of ub.rvs-doc override do: end.
  do
  on error undo, return error
  :
    for each buf_rvs-doc exclusive-lock
      where buf_rvs-doc.obj-type = p-obj-type
        and buf_rvs-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'rvs-doc':U
         ,input (buffer buf_rvs-doc:handle)
        ) .
      for each buf_rvs-line exclusive-lock
        where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
      on error undo, return error
      :
        delete buf_rvs-line .
      end.
      for each buf_rvs-line-pump exclusive-lock
        where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
      on error undo, return error
      :
        delete buf_rvs-line-pump .
      end.
      delete buf_rvs-doc .
    end.
  end.
end procedure.
procedure delete-wth-doc :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_wth-doc   for ub.wth-doc .
  define buffer buf_wth-line  for ub.wth-line .
  define buffer buf_wth-dtl   for ub.wth-dtl .
  define buffer buf_wth-obj   for ub.wth-obj .
  define buffer buf_c-wth-obj   for ub.c-wth-obj .
  define buffer buf_wth-place for ub.wth-place .
  define buffer buf_c-wth-place for ub.c-wth-place .
  define buffer buf_wth-pobj  for ub.wth-pobj .
  define buffer buf_c-wth-pobj  for ub.c-wth-pobj .
  define buffer buf_c-wth-doc   for ub.c-wth-doc .
  define buffer buf_c-wth-line  for ub.c-wth-line .
  define buffer buf_c-wth-dtl   for ub.c-wth-dtl .
  on delete of ub.wth-doc   override do: end.
  on delete of ub.wth-place override do: end.
  on delete of ub.c-wth-place override do: end.
  on delete of ub.wth-line  override do: end.
  on delete of ub.wth-dtl   override do: end.
  on delete of ub.c-wth-doc   override do: end.
  on delete of ub.c-wth-line  override do: end.
  on delete of ub.c-wth-dtl   override do: end.
  do
  on error undo, return error
  :
    for each buf_wth-doc exclusive-lock
      where buf_wth-doc.obj-type = p-obj-type
        and buf_wth-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'wth-doc':U
         ,input (buffer buf_wth-doc:handle)
        ) .
      for each buf_wth-line exclusive-lock
        where buf_wth-line.doc-code = buf_wth-doc.doc-code
      on error undo, return error
      :
        delete buf_wth-line .
      end.
      for each buf_wth-dtl exclusive-lock
        where buf_wth-dtl.doc-code = buf_wth-doc.doc-code
      on error undo, return error
      :
        delete buf_wth-dtl .
      end.
      delete buf_wth-doc .
    end.
    for each buf_c-wth-doc exclusive-lock
      where buf_c-wth-doc.obj-type = p-obj-type
        and buf_c-wth-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-wth-doc':U
         ,input (buffer buf_c-wth-doc:handle)
        ) .
      for each buf_wth-line exclusive-lock
        where buf_wth-line.doc-code = buf_c-wth-doc.doc-code
      on error undo, return error
      :
        delete buf_wth-line .
      end.
      for each buf_wth-dtl exclusive-lock
        where buf_wth-dtl.doc-code = buf_c-wth-doc.doc-code
      on error undo, return error
      :
        delete buf_wth-dtl .
      end.
      delete buf_c-wth-doc .
    end.
    for each buf_wth-place exclusive-lock
      where buf_wth-place.obj-type = p-obj-type
        and buf_wth-place.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'wth-place':U
         ,input (buffer buf_wth-place:handle)
        ) .
      delete buf_wth-place .
    end.
    for each buf_c-wth-place exclusive-lock
      where buf_c-wth-place.obj-type = p-obj-type
        and buf_c-wth-place.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-wth-place':U
         ,input (buffer buf_c-wth-place:handle)
        ) .
      delete buf_c-wth-place .
    end.
    for each buf_wth-obj exclusive-lock
      where buf_wth-obj.obj-type = p-obj-type
        and buf_wth-obj.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'wth-obj':U
         ,input (buffer buf_wth-obj:handle)
        ) .
      delete buf_wth-obj .
    end.
    for each buf_wth-pobj exclusive-lock
      where buf_wth-pobj.obj-type = p-obj-type
        and buf_wth-pobj.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'wth-pobj':U
         ,input (buffer buf_wth-pobj:handle)
        ) .
      delete buf_wth-pobj .
    end.
    for each buf_c-wth-obj exclusive-lock
      where buf_c-wth-obj.obj-type = p-obj-type
        and buf_c-wth-obj.obj-code = p-obj-code
    on error undo, return error
    :
      delete buf_c-wth-obj .
    end.
    for each buf_c-wth-pobj exclusive-lock
      where buf_c-wth-pobj.obj-type = p-obj-type
        and buf_c-wth-pobj.obj-code = p-obj-code
    on error undo, return error
    :
      delete buf_c-wth-pobj .
    end.
  end.
end procedure.
procedure delete-icnt-doc :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_icnt-doc for ub.icnt-doc .
  define buffer buf_icnt-line for ub.icnt-line .
  on delete of ub.icnt-doc override do: end.
  on delete of ub.icnt-line override do: end.
  do
  on error undo, return error
  :
    for each buf_icnt-doc exclusive-lock
      where buf_icnt-doc.obj-type = p-obj-type
        and buf_icnt-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'icnt-doc':U
         ,input (buffer buf_icnt-doc:handle)
        ) .
      for each buf_icnt-line exclusive-lock
        where buf_icnt-line.doc-code = buf_icnt-doc.doc-code
      on error undo, return error
      :
        delete buf_icnt-line .
      end.
      delete buf_icnt-doc .
    end.
  end.
end procedure.
procedure delete-chk-doc :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_chk-doc for ub.chk-doc .
  define buffer buf_chk-gds for ub.chk-gds .
  define buffer buf_chk-pay for ub.chk-pay .
  define buffer buf_chk-discnt for ub.chk-discnt .
  define buffer buf_chk-doc-attr for ub.chk-doc-attr .
  define buffer buf_c-chk-doc for ub.c-chk-doc .
  define buffer buf_c-chk-gds for ub.c-chk-gds .
  define buffer buf_c-chk-pay for ub.c-chk-pay .
  define buffer buf_c-chk-discnt for ub.c-chk-discnt .
  define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr .
  on delete of ub.chk-doc override do: end.
  do
  on error undo, return error
  :
    for each buf_chk-doc exclusive-lock
      where buf_chk-doc.obj-type = p-obj-type
        and buf_chk-doc.obj-code = p-obj-code
    use-index chk-out
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'chk-doc':U
         ,input (buffer buf_chk-doc:handle)
        ) .
      for each buf_chk-gds exclusive-lock
        where buf_chk-gds.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_chk-gds .
      end.
      for each buf_chk-pay exclusive-lock
        where buf_chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_chk-pay .
      end.
      for each buf_chk-discnt exclusive-lock
        where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_chk-discnt .
      end.
      for each buf_chk-doc-attr exclusive-lock
        where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_chk-doc-attr .
      end.
      for each buf_c-chk-gds exclusive-lock
        where buf_c-chk-gds.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_c-chk-gds .
      end.
      for each buf_c-chk-pay exclusive-lock
        where buf_c-chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_c-chk-pay .
      end.
      for each buf_c-chk-discnt exclusive-lock
        where buf_c-chk-discnt.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_c-chk-discnt .
      end.
      for each buf_c-chk-doc-attr exclusive-lock
        where buf_c-chk-doc-attr.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_c-chk-doc-attr .
      end.
      for each buf_c-chk-doc exclusive-lock
        where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        delete buf_c-chk-doc .
      end.
      delete buf_chk-doc .
    end.
  end.
end procedure.
procedure delete-recipe :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_recipe              for ub.recipe.
  define buffer buf_recipe-gds          for ub.recipe-gds.
  define buffer buf_recipe-develop      for ub.recipe-develop.
  define buffer buf_c-recipe            for ub.c-recipe.
  define buffer buf_c-recipe-gds        for ub.c-recipe-gds.
  define buffer buf_c-recipe-develop    for ub.c-recipe-develop.
  on delete of ub.recipe                override do: end.
  on delete of ub.recipe-gds            override do: end.
  on delete of ub.recipe-develop        override do: end.
  on delete of ub.c-recipe              override do: end.
  on delete of ub.c-recipe-gds          override do: end.
  on delete of ub.c-recipe-develop      override do: end.
  do
  on error undo, return error
  :
    for each buf_recipe exclusive-lock
       where buf_recipe.obj-type = p-obj-type
         and buf_recipe.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'recipe':U
         ,input (buffer buf_recipe:handle)
        ) .
      for each buf_recipe-gds exclusive-lock
         where buf_recipe-gds.recipe-code = buf_recipe.recipe-code
      on error undo, return error
      :
        delete buf_recipe-gds .
      end.
      for each buf_recipe-develop exclusive-lock
         where buf_recipe-develop.recipe-code = buf_recipe.recipe-code
      on error undo, return error
      :
        delete buf_recipe-develop .
      end.
      delete buf_recipe .
    end.
    for each buf_c-recipe exclusive-lock
       where buf_c-recipe.obj-type = p-obj-type
         and buf_c-recipe.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-recipe':U
         ,input (buffer buf_c-recipe:handle)
        ) .
      for each buf_c-recipe-gds exclusive-lock
         where buf_c-recipe-gds.recipe-code = buf_c-recipe.recipe-code
      on error undo, return error
      :
        delete buf_c-recipe-gds .
      end.
      for each buf_c-recipe-develop exclusive-lock
         where buf_c-recipe-develop.recipe-code = buf_c-recipe.recipe-code
      on error undo, return error
      :
        delete buf_c-recipe-develop .
      end.
      delete buf_c-recipe .
    end.
  end.
end procedure.
procedure delete-fbr-doc :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_fbr-doc     for ub.fbr-doc .
  define buffer buf_fbr-line    for ub.fbr-line .
  define buffer buf_c-fbr-doc   for ub.c-fbr-doc .
  define buffer buf_c-fbr-line  for ub.c-fbr-line .
  on delete of ub.fbr-doc       override do: end.
  on delete of ub.fbr-line      override do: end.
  on delete of ub.c-fbr-doc     override do: end.
  on delete of ub.c-fbr-line    override do: end.
  do
  on error undo, return error
  :
    for each buf_fbr-doc exclusive-lock
       where buf_fbr-doc.obj-type = p-obj-type
         and buf_fbr-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'fbr-doc':U
         ,input (buffer buf_fbr-doc:handle)
        ) .
      for each buf_fbr-line exclusive-lock
        where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
      on error undo, return error
      :
        delete buf_fbr-line .
      end.
      delete buf_fbr-doc .
    end.
    for each buf_c-fbr-doc exclusive-lock
       where buf_c-fbr-doc.obj-type = p-obj-type
         and buf_c-fbr-doc.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-fbr-doc':U
         ,input (buffer buf_c-fbr-doc:handle)
        ) .
      for each buf_c-fbr-line exclusive-lock
         where buf_c-fbr-line.doc-code = buf_c-fbr-doc.doc-code
      on error undo, return error
      :
        delete buf_c-fbr-line .
      end.
      delete buf_c-fbr-doc .
    end.
  end.
end procedure.
procedure delete-fbr-pln :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_fbr-pln             for ub.fbr-pln .
  define buffer buf_fbr-pln-line        for ub.fbr-pln-line .
  define buffer buf_c-fbr-pln           for ub.fbr-pln .
  define buffer buf_c-fbr-pln-line      for ub.fbr-pln-line .
  on delete of ub.fbr-pln           override do: end.
  on delete of ub.fbr-pln-line      override do: end.
  on delete of ub.c-fbr-pln         override do: end.
  on delete of ub.c-fbr-pln-line    override do: end.
  do
  on error undo, return error
  :
    for each buf_fbr-pln exclusive-lock
       where buf_fbr-pln.obj-type = p-obj-type
         and buf_fbr-pln.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'fbr-pln':U
         ,input (buffer buf_fbr-pln:handle)
        ) .
      for each buf_fbr-pln-line exclusive-lock
         where buf_fbr-pln-line.doc-code = buf_fbr-pln.doc-code
      on error undo, return error
      :
        delete buf_fbr-pln-line .
      end.
      delete buf_fbr-pln .
    end.
    for each buf_c-fbr-pln exclusive-lock
       where buf_c-fbr-pln.obj-type = p-obj-type
         and buf_c-fbr-pln.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-fbr-pln':U
         ,input (buffer buf_c-fbr-pln:handle)
        ) .
      for each buf_c-fbr-pln-line exclusive-lock
         where buf_c-fbr-pln-line.doc-code = buf_c-fbr-pln.doc-code
      on error undo, return error
      :
        delete buf_c-fbr-pln-line .
      end.
      delete buf_c-fbr-pln .
    end.
  end.
end procedure.
procedure delete-fbr-gds-grp :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_fbr-gds-grp  for ub.fbr-gds-grp .
  define buffer buf_fbr-gds-grp-attr  for ub.fbr-gds-grp-attr .
  define buffer buf_c-fbr-gds-grp  for ub.c-fbr-gds-grp .
  define buffer buf_c-fbr-gds-grp-attr  for ub.c-fbr-gds-grp-attr .
  define buffer buf_c-fbr-gds-grp-hist  for ub.c-fbr-gds-grp-hist .
  on delete of ub.fbr-gds-grp override do: end.
  on delete of ub.fbr-gds-grp-attr override do: end.
  on delete of ub.c-fbr-gds-grp override do: end.
  on delete of ub.c-fbr-gds-grp-attr override do: end.
  on delete of ub.c-fbr-gds-grp-hist override do: end.
  do
  on error undo, return error
  :
    for each buf_fbr-gds-grp exclusive-lock
      where buf_fbr-gds-grp.obj-type = p-obj-type
        and buf_fbr-gds-grp.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'fbr-gds-grp':U
         ,input (buffer buf_fbr-gds-grp:handle)
        ) .
      delete buf_fbr-gds-grp .
    end.
    for each buf_c-fbr-gds-grp exclusive-lock
      where buf_c-fbr-gds-grp.obj-type = p-obj-type
        and buf_c-fbr-gds-grp.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-fbr-gds-grp':U
         ,input (buffer buf_c-fbr-gds-grp:handle)
        ) .
      delete buf_c-fbr-gds-grp .
    end.
    for each buf_fbr-gds-grp-attr exclusive-lock
      where buf_fbr-gds-grp-attr.obj-type = p-obj-type
        and buf_fbr-gds-grp-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'fbr-gds-grp-attr':U
         ,input (buffer buf_fbr-gds-grp-attr:handle)
        ) .
      delete buf_fbr-gds-grp-attr .
    end.
    for each buf_c-fbr-gds-grp-attr exclusive-lock
      where buf_c-fbr-gds-grp-attr.obj-type = p-obj-type
        and buf_c-fbr-gds-grp-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-fbr-gds-grp-attr':U
         ,input (buffer buf_c-fbr-gds-grp-attr:handle)
        ) .
      delete buf_c-fbr-gds-grp-attr .
    end.
    for each buf_c-fbr-gds-grp-hist exclusive-lock
      where buf_c-fbr-gds-grp-hist.obj-type = p-obj-type
        and buf_c-fbr-gds-grp-hist.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-fbr-gds-grp-hist':U
         ,input (buffer buf_c-fbr-gds-grp-hist:handle)
        ) .
      delete buf_c-fbr-gds-grp-hist .
    end.
  end.
end procedure.
procedure delete-fbr-prn :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_fbr-prn  for ub.fbr-prn .
  define buffer buf_fbr-prn-grp  for ub.fbr-prn-grp .
  define buffer buf_fbr-prn-gds  for ub.fbr-prn-gds .
  define buffer buf_c-fbr-prn  for ub.fbr-prn .
  define buffer buf_c-fbr-prn-grp  for ub.fbr-prn-grp .
  define buffer buf_c-fbr-prn-gds  for ub.fbr-prn-gds .
  define buffer buf_clients for ub.clients.
  on delete of ub.fbr-prn override do: end.
  on delete of ub.fbr-prn-grp override do: end.
  on delete of ub.fbr-prn-gds override do: end.
  on delete of ub.c-fbr-prn override do: end.
  on delete of ub.c-fbr-prn-grp override do: end.
  on delete of ub.c-fbr-prn-gds override do: end.
  define variable v-db-num like ub.db.db-num no-undo .
  do
  on error undo, return error
  :
    for each buf_fbr-prn exclusive-lock
      where buf_fbr-prn.fbr-obj-type = p-obj-type
        and buf_fbr-prn.fbr-obj-code = p-obj-code
    on error undo, return error
    :
      for each buf_fbr-prn-gds exclusive-lock
        where buf_fbr-prn-gds.db-num = buf_fbr-prn.db-num
         AND  buf_fbr-prn-gds.prn-num = buf_fbr-prn.prn-num
      on error undo, return error
      :
          run delete-route in this-procedure
            ( input 'fbr-prn-gds':U
            ,input (buffer buf_fbr-prn-gds:handle)
            ) .
          delete buf_fbr-prn-gds .
      end.
      for each buf_fbr-prn-grp exclusive-lock
        where buf_fbr-prn-grp.db-num = buf_fbr-prn.db-num
          AND buf_fbr-prn-grp.prn-num = buf_fbr-prn.prn-num
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'fbr-prn-grp':U
          ,input (buffer buf_fbr-prn-grp:handle)
          ) .
        delete buf_fbr-prn-grp .
      end.
      for each buf_c-fbr-prn exclusive-lock
        where buf_c-fbr-prn.fbr-obj-type = p-obj-type
          and buf_c-fbr-prn.fbr-obj-code = p-obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'c-fbr-prn':U
          ,input (buffer buf_c-fbr-prn:handle)
          ) .
      end.
      for each buf_c-fbr-prn-grp exclusive-lock
        where buf_c-fbr-prn-grp.db-num = buf_fbr-prn.db-num
          AND buf_c-fbr-prn-grp.prn-num = buf_fbr-prn.prn-num
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'c-fbr-prn-grp':U
          ,input (buffer buf_c-fbr-prn-grp:handle)
          ) .
        delete buf_c-fbr-prn-grp .
      end.
      for each buf_c-fbr-prn-gds exclusive-lock
        where buf_c-fbr-prn-gds.db-num = buf_fbr-prn.db-num
        AND  buf_c-fbr-prn-gds.prn-num = buf_fbr-prn.prn-num
      on error undo, return error
      :
          run delete-route in this-procedure
            ( input 'c-fbr-prn-gds':U
            ,input (buffer buf_c-fbr-prn-gds:handle)
            ) .
          delete buf_c-fbr-prn-gds .
      end.
      run delete-route in this-procedure
        ( input 'fbr-prn':U
        ,input (buffer buf_fbr-prn:handle)
        ) .
      delete buf_fbr-prn .
    end.
  end.
end procedure.
procedure delete-obj-date :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_obj-date for ub.obj-date .
  on delete of ub.obj-date override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_obj-date exclusive-lock
      where buf_obj-date.obj-type = p-obj-type
        and buf_obj-date.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'obj-date':U
         ,input (buffer buf_obj-date:handle)
        ) .
      delete buf_obj-date .
    end.
  end.
end procedure.
procedure delete-ot-archive :
  define input  parameter p-doc-code as character no-undo .
  define buffer buf_ot-line      for ub.ot-line      .
  define buffer buf_ot-supp-line for ub.ot-supp-line .
  define buffer buf_aht-ot-line  for ub.aht-ot-line  .
  define buffer buf_ot-supp-tot  for ub.ot-supp-tot  .
  define buffer buf_ot-tot       for ub.ot-tot       .
  define buffer buf_aht-ot-tot   for ub.aht-ot-tot   .
  do
  on error undo, return error return-value
  :
    for each buf_ot-line exclusive-lock
      where buf_ot-line.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_ot-line .
    end.
    for each buf_ot-supp-line exclusive-lock
      where buf_ot-supp-line.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_ot-supp-line .
    end.
    for each buf_aht-ot-line exclusive-lock
      where buf_aht-ot-line.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_aht-ot-line .
    end.
    for each buf_ot-supp-tot exclusive-lock
      where buf_ot-supp-tot.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_ot-supp-tot .
    end.
    for each buf_ot-tot exclusive-lock
      where buf_ot-tot.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_ot-tot .
    end.
    for each buf_aht-ot-tot exclusive-lock
      where buf_aht-ot-tot.doc-code = p-doc-code
    on error undo, return error
    :
      delete buf_aht-ot-tot .
    end.
  end.
end procedure.
procedure delete-ord-doc :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_ord-doc      for ub.ord-doc .
  define buffer buf_ord-line     for ub.ord-line .
  define buffer buf_ord-dtl      for ub.ord-dtl .
  define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv .
  define buffer buf_ord-line-rcv for ub.ord-line-rcv .
  define buffer buf_ord-dtl-rcv  for ub.ord-dtl-rcv .
  define buffer buf_ord-doc-attr      for ub.ord-doc-attr .
  define buffer buf_ord-line-attr     for ub.ord-line-attr .
  define buffer buf_ord-dtl-attr      for ub.ord-dtl-attr .
  on delete of ub.ord-doc override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_ord-doc exclusive-lock
      where buf_ord-doc.obj-type = p-obj-type
        and buf_ord-doc.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'ord-doc':U
         ,input (buffer buf_ord-doc:handle)
        ) .
      for each buf_ord-line exclusive-lock
        where buf_ord-line.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-line .
      end.
      for each buf_ord-line-attr exclusive-lock
        where buf_ord-line-attr.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-line-attr .
      end.
      for each buf_ord-dtl exclusive-lock
        where buf_ord-dtl.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-dtl .
      end.
      for each buf_ord-dtl-attr exclusive-lock
        where buf_ord-dtl-attr.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-dtl-attr .
      end.
      for each buf_ord-doc-attr exclusive-lock
        where buf_ord-doc-attr.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-doc-attr .
      end.
      for each buf_ord-doc-rcv exclusive-lock
        where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-doc-rcv .
      end.
      for each buf_ord-line-rcv exclusive-lock
        where buf_ord-line-rcv.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-line-rcv .
      end.
      for each buf_ord-dtl-rcv exclusive-lock
        where buf_ord-dtl-rcv.doc-code = buf_ord-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_ord-dtl-rcv .
      end.
      delete buf_ord-doc .
    end.
  end.
end procedure.
procedure delete-add-doc :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_add-doc       for ub.add-doc      .
  define buffer buf_add-line      for ub.add-line     .
  define buffer buf_add-trn       for ub.add-trn      .
  define buffer buf_add-trn-attr  for ub.add-trn-attr .
  define buffer buf_doc-line-attr for ub.doc-line-attr.
  on delete of ub.add-doc override do: end.
  on delete of ub.add-trn override do: end.
  on delete of ub.doc-line-attr override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_add-doc exclusive-lock
      where buf_add-doc.obj-type = p-obj-type
        and buf_add-doc.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'add-doc':U
         ,input (buffer buf_add-doc:handle)
        ) .
      for each buf_add-line exclusive-lock
        where buf_add-line.doc-code = buf_add-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_add-line .
      end.
      for each buf_doc-line-attr exclusive-lock
        where buf_doc-line-attr.doc-code = buf_add-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_doc-line-attr .
      end.
      for each buf_add-trn-attr exclusive-lock
        where buf_add-trn-attr.doc-code = buf_add-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_add-trn-attr .
      end.
      for each buf_add-trn exclusive-lock
        where buf_add-trn.doc-code = buf_add-doc.doc-code
      on error undo, return error return-value
      :
        delete buf_add-trn .
      end.
      delete buf_add-doc .
    end.
  end.
end procedure.
procedure delete-gds-obj-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_gds-obj-prop   for ub.gds-obj-prop .
  define buffer buf_gds-obj-flag   for ub.gds-obj-flag .
  define buffer buf_c-gds-obj-prop for ub.c-gds-obj-prop .
  do
  on error undo, return error return-value
  :
    for each buf_gds-obj-prop exclusive-lock
      where buf_gds-obj-prop.obj-type = p-obj-type
        and buf_gds-obj-prop.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'gds-obj-prop':U
         ,input (buffer buf_gds-obj-prop:handle)
        ) .
      delete buf_gds-obj-prop .
    end.
    for each buf_gds-obj-flag exclusive-lock
      where buf_gds-obj-flag.obj-type = p-obj-type
        and buf_gds-obj-flag.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_gds-obj-flag .
    end.
    for each buf_c-gds-obj-prop exclusive-lock
      where buf_c-gds-obj-prop.obj-type = p-obj-type
        and buf_c-gds-obj-prop.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-gds-obj-prop .
    end.
  end.
end procedure.
procedure delete-assortment-matrix :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_assortment-matrix for ub.assortment-matrix .
  define buffer buf_c-assortment-matrix for ub.c-assortment-matrix .
  do
  on error undo, return error return-value
  :
    for each buf_assortment-matrix exclusive-lock
      where buf_assortment-matrix.obj-type = p-obj-type
        and buf_assortment-matrix.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'assortment-matrix':U
         ,input (buffer buf_assortment-matrix:handle)
        ) .
      delete buf_assortment-matrix .
    end.
    for each buf_c-assortment-matrix exclusive-lock
      where buf_c-assortment-matrix.obj-type = p-obj-type
        and buf_c-assortment-matrix.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-assortment-matrix .
    end.
  end.
end procedure.
procedure delete-shift-obj :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  define buffer buf_c-sht-hist for ub.c-sht-hist .
  define buffer buf_c-shift-obj for ub.c-shift-obj .
  define buffer buf_shift-cash for ub.shift-cash .
  define buffer buf_shift-staff for ub.shift-staff .
  define buffer buf_c-shift-staff for ub.c-shift-staff .
  on delete of ub.shift-obj   override do: end.
  on delete of ub.c-sht-hist  override do: end.
  on delete of ub.c-shift-obj   override do: end.
  on delete of ub.shift-cash  override do: end.
  on delete of ub.shift-staff override do: end.
  on delete of ub.c-shift-staff override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_shift-obj exclusive-lock
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'shift-obj':U
         ,input (buffer buf_shift-obj:handle)
        ) .
      delete buf_shift-obj .
    end.
    for each buf_c-sht-hist exclusive-lock
      where buf_c-sht-hist.obj-type = p-obj-type
        and buf_c-sht-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-sht-hist':U
         ,input (buffer buf_c-sht-hist:handle)
        ) .
      delete buf_c-sht-hist .
    end.
    for each buf_c-shift-obj exclusive-lock
      where buf_c-shift-obj.obj-type = p-obj-type
        and buf_c-shift-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-shift-obj':U
         ,input (buffer buf_c-shift-obj:handle)
        ) .
      delete buf_c-shift-obj .
    end.
    for each buf_shift-cash exclusive-lock
      where buf_shift-cash.obj-type = p-obj-type
        and buf_shift-cash.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_shift-cash .
    end.
    for each buf_shift-staff exclusive-lock
      where buf_shift-staff.obj-type = p-obj-type
        and buf_shift-staff.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'shift-staff':U
         ,input (buffer buf_shift-staff:handle)
        ) .
      delete buf_shift-staff.
    end.
    for each buf_c-shift-staff exclusive-lock
      where buf_c-shift-staff.obj-type = p-obj-type
        and buf_c-shift-staff.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-shift-staff':U
         ,input (buffer buf_c-shift-staff:handle)
        ) .
      delete buf_c-shift-staff .
    end.
  end.
end procedure.
procedure delete-place-nozzle-pump :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_place          for ub.place .
  define buffer buf_c-place        for ub.c-place .
  define buffer buf_c-plc-hist     for ub.c-plc-hist.
  define buffer buf_nozzle         for ub.nozzle .
  define buffer buf_c-nzl-hist     for ub.c-nzl-hist .
  define buffer buf_c-nozzle       for ub.c-nozzle .
  define buffer buf_pump           for ub.pump .
  define buffer buf_c-pmp-hist     for ub.c-pmp-hist .
  define buffer buf_c-pump         for ub.c-pump .
  define buffer buf_pl-gds         for ub.pl-gds .
  define buffer buf_c-pl-gds-obj   for ub.c-pl-gds-obj .
  define buffer buf_c-pl-gds       for ub.pl-gds .
  define buffer buf_pl-pump        for ub.pl-pump .
  define buffer buf_c-pl-pump      for ub.c-pl-pump .
  define buffer buf_pump-nozzle    for ub.pump-nozzle .
  define buffer buf_c-pump-nozzle  for ub.c-pump-nozzle .
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle .
  define buffer buf_c-pl-pump-nozzle for ub.c-pl-pump-nozzle .
  define buffer buf_pl-gds-pump    for ub.pl-gds-pump .
  define buffer buf_c-pl-gds-pump  for ub.c-pl-gds-pump .
  define buffer buf_pl-level       for ub.pl-level .
  define buffer buf_c-pl-level     for ub.c-pl-level .
  on delete of ub.place          override do: end.
  on delete of ub.c-place        override do: end.
  on delete of ub.c-plc-hist     override do: end.
  on delete of ub.nozzle         override do: end.
  on delete of ub.c-nzl-hist     override do: end.
  on delete of ub.c-nozzle       override do: end.
  on delete of ub.pump           override do: end.
  on delete of ub.c-pump         override do: end.
  on delete of ub.c-pmp-hist     override do: end.
  on delete of ub.pl-gds         override do: end.
  on delete of ub.c-pl-gds       override do: end.
  on delete of ub.pl-pump        override do: end.
  on delete of ub.c-pl-pump      override do: end.
  on delete of ub.pump-nozzle    override do: end.
  on delete of ub.c-pump-nozzle  override do: end.
  on delete of ub.pl-pump-nozzle override do: end.
  on delete of ub.c-pl-pump-nozzle override do: end.
  on delete of ub.pl-gds-pump    override do: end.
  on delete of ub.c-pl-gds-pump  override do: end.
  on delete of ub.pl-level       override do: end.
  on delete of ub.c-pl-level     override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_place exclusive-lock
      where buf_place.obj-type = p-obj-type
        and buf_place.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'place':U
         ,input (buffer buf_place:handle)
        ) .
      delete buf_place .
    end.
    for each buf_c-place exclusive-lock
      where buf_c-place.obj-type = p-obj-type
        and buf_c-place.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-place':U
         ,input (buffer buf_c-place:handle)
        ) .
      delete buf_c-place .
    end.
    for each buf_c-plc-hist exclusive-lock
      where buf_c-plc-hist.obj-type = p-obj-type
        and buf_c-plc-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-plc-hist':U
         ,input (buffer buf_c-plc-hist:handle)
        ) .
      delete buf_c-plc-hist .
    end.
    for each buf_nozzle exclusive-lock
      where buf_nozzle.obj-type = p-obj-type
        and buf_nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-nozzle':U
         ,input (buffer buf_c-nozzle:handle)
        ) .
      delete buf_nozzle .
    end.
    for each buf_c-nzl-hist exclusive-lock
      where buf_c-nzl-hist.obj-type = p-obj-type
        and buf_c-nzl-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-nzl-hist':U
         ,input (buffer buf_c-nzl-hist:handle)
        ) .
      delete buf_c-nzl-hist .
    end.
    for each buf_c-nozzle exclusive-lock
      where buf_c-nozzle.obj-type = p-obj-type
        and buf_c-nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-nozzle':U
         ,input (buffer buf_c-nozzle:handle)
        ) .
      delete buf_c-nozzle .
    end.
    for each buf_pump exclusive-lock
      where buf_pump.obj-type = p-obj-type
        and buf_pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'pump':U
         ,input (buffer buf_pump:handle)
        ) .
      delete buf_pump .
    end.
    for each buf_c-pump exclusive-lock
      where buf_c-pump.obj-type = p-obj-type
        and buf_c-pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-pump':U
         ,input (buffer buf_c-pump:handle)
        ) .
      delete buf_c-pump .
    end.
    for each buf_c-pmp-hist exclusive-lock
      where buf_c-pmp-hist.obj-type = p-obj-type
        and buf_c-pmp-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-pmp-hist':U
         ,input (buffer buf_c-pmp-hist:handle)
        ) .
      delete buf_c-pmp-hist .
    end.
    for each buf_pl-gds exclusive-lock
      where buf_pl-gds.obj-type = p-obj-type
        and buf_pl-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'pl-gds':U
         ,input (buffer buf_pl-gds:handle)
        ) .
      delete buf_pl-gds .
    end.
    for each buf_c-pl-gds-obj exclusive-lock
      where buf_c-pl-gds-obj.obj-type = p-obj-type
        and buf_c-pl-gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_c-pl-gds-obj .
    end.
    for each buf_c-pl-gds exclusive-lock
      where buf_c-pl-gds.obj-type = p-obj-type
        and buf_c-pl-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-pl-gds':U
         ,input (buffer buf_c-pl-gds:handle)
        ) .
      delete buf_c-pl-gds .
    end.
    for each buf_pl-pump exclusive-lock
      where buf_pl-pump.obj-type = p-obj-type
        and buf_pl-pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'pl-pump':U
         ,input (buffer buf_pl-pump:handle)
        ) .
      delete buf_pl-pump .
    end.
    for each buf_c-pl-pump exclusive-lock
      where buf_c-pl-pump.obj-type = p-obj-type
        and buf_c-pl-pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-pl-pump':U
         ,input (buffer buf_c-pl-pump:handle)
        ) .
      delete buf_c-pl-pump .
    end.
    for each buf_pump-nozzle exclusive-lock
      where buf_pump-nozzle.obj-type = p-obj-type
        and buf_pump-nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'pump-nozzle':U
         ,input (buffer buf_pump-nozzle:handle)
        ) .
      delete buf_pump-nozzle .
    end.
    for each buf_c-pump-nozzle exclusive-lock
      where buf_c-pump-nozzle.obj-type = p-obj-type
        and buf_c-pump-nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-pump-nozzle':U
         ,input (buffer buf_c-pump-nozzle:handle)
        ) .
      delete buf_c-pump-nozzle .
    end.
    for each buf_pl-pump-nozzle exclusive-lock
      where buf_pl-pump-nozzle.obj-type = p-obj-type
        and buf_pl-pump-nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'pl-pump-nozzle':U
         ,input (buffer buf_pl-pump-nozzle:handle)
        ) .
      delete buf_pl-pump-nozzle .
    end.
    for each buf_c-pl-pump-nozzle exclusive-lock
      where buf_c-pl-pump-nozzle.obj-type = p-obj-type
        and buf_c-pl-pump-nozzle.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-pl-pump-nozzle':U
         ,input (buffer buf_c-pl-pump-nozzle:handle)
        ) .
      delete buf_c-pl-pump-nozzle .
    end.
    for each buf_pl-gds-pump exclusive-lock
      where buf_pl-gds-pump.obj-type = p-obj-type
        and buf_pl-gds-pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'pl-gds-pump':U
         ,input (buffer buf_pl-gds-pump:handle)
        ) .
      delete buf_pl-gds-pump .
    end.
    for each buf_c-pl-gds-pump exclusive-lock
      where buf_c-pl-gds-pump.obj-type = p-obj-type
        and buf_c-pl-gds-pump.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-pl-gds-pump':U
         ,input (buffer buf_c-pl-gds-pump:handle)
        ) .
      delete buf_c-pl-gds-pump .
    end.
    for each buf_pl-level exclusive-lock
      where buf_pl-level.obj-type = p-obj-type
        and buf_pl-level.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'pl-level':U
         ,input (buffer buf_pl-level:handle)
        ) .
      delete buf_pl-level .
    end.
    for each buf_c-pl-level exclusive-lock
      where buf_c-pl-level.obj-type = p-obj-type
        and buf_c-pl-level.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-pl-level':U
         ,input (buffer buf_c-pl-level:handle)
        ) .
      delete buf_c-pl-level .
    end.
  end.
end procedure.
procedure delete-stk-archive :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_stk-line      for ub.stk-line .
  define buffer buf_stk-supp-line for ub.stk-supp-line .
  define buffer buf_aht-stk-line  for ub.aht-stk-line .
  define buffer buf_stk-supp-tot  for ub.stk-supp-tot .
  define buffer buf_stk-tot       for ub.stk-tot .
  define buffer buf_aht-stk-tot   for ub.aht-stk-tot .
  define buffer buf_aht-stk       for ub.aht-stk .
  do
  on error undo, return error return-value
  :
    for each buf_stk-line exclusive-lock
      where buf_stk-line.obj-type = p-obj-type
        and buf_stk-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_stk-line .
    end.
    for each buf_stk-supp-line exclusive-lock
      where buf_stk-supp-line.obj-type = p-obj-type
        and buf_stk-supp-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_stk-supp-line .
    end.
    for each buf_aht-stk-line exclusive-lock
      where buf_aht-stk-line.obj-type = p-obj-type
        and buf_aht-stk-line.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_aht-stk-line .
    end.
    for each buf_stk-supp-tot exclusive-lock
      where buf_stk-supp-tot.obj-type = p-obj-type
        and buf_stk-supp-tot.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_stk-supp-tot .
    end.
    for each buf_stk-tot exclusive-lock
      where buf_stk-tot.obj-type = p-obj-type
        and buf_stk-tot.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_stk-tot .
    end.
    for each buf_aht-stk-tot exclusive-lock
      where buf_aht-stk-tot.obj-type = p-obj-type
        and buf_aht-stk-tot.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_aht-stk-tot .
    end.
    for each buf_aht-stk exclusive-lock
      where buf_aht-stk.obj-type = p-obj-type
        and buf_aht-stk.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_aht-stk .
    end.
  end.
end procedure.
procedure delete-tax :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_tax-rate-gds     for ub.tax-rate-gds .
  define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp .
  define buffer buf_tax-rate-value   for ub.tax-rate-value .
  define buffer buf_c-tax-hist       for ub.c-tax-hist.
  define buffer buf_c-gds-hist       for ub.c-gds-hist.
  on delete of ub.c-tax-hist       override do: end.
  on delete of ub.tax-rate-gds     override do: end.
  on delete of ub.tax-rate-gds-grp override do: end.
  on delete of ub.tax-rate-value   override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_tax-rate-gds exclusive-lock
      where buf_tax-rate-gds.obj-type = p-obj-type
        and buf_tax-rate-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
    for each buf_c-gds-hist where
            buf_c-gds-hist.gds-code = buf_tax-rate-gds.rate-code
        AND buf_c-gds-hist.subject   = 'tax-rate-gds':U
        AND buf_c-gds-hist.host-code = buf_tax-rate-gds.host-code
        AND buf_c-gds-hist.obj-type  = buf_tax-rate-gds.obj-type
        AND buf_c-gds-hist.obj-code  = buf_tax-rate-gds.obj-code
        AND buf_c-gds-hist.tax-code = buf_tax-rate-gds.tax-code
        :
        delete buf_c-gds-hist.
    end.
      delete buf_tax-rate-gds .
    end.
    for each buf_tax-rate-gds-grp exclusive-lock
      where buf_tax-rate-gds-grp.obj-type = p-obj-type
        and buf_tax-rate-gds-grp.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_tax-rate-gds-grp .
    end.
    for each buf_tax-rate-value exclusive-lock
      where buf_tax-rate-value.obj-type = p-obj-type
        and buf_tax-rate-value.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-tax-hist where
              buf_c-tax-hist.tax-code = buf_tax-rate-value.tax-code
          AND buf_c-tax-hist.rate-code = buf_tax-rate-value.rate-code
          AND buf_c-tax-hist.host-code = buf_tax-rate-value.host-code
          AND buf_c-tax-hist.obj-type  = buf_tax-rate-value.obj-type
          AND buf_c-tax-hist.obj-code = buf_tax-rate-value.obj-code :
        delete buf_c-tax-hist.
      end.
      delete buf_tax-rate-value .
    end.
  end.
end procedure.
procedure delete-dis-obj :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_dis-obj       for ub.dis-obj .
  define buffer buf_c-dis-obj     for ub.c-dis-obj .
  define buffer buf_dis-host      for ub.dis-host.
  define buffer buf_dis-card      for ub.dis-card.
  define buffer buf_c-dc-hist     for ub.c-dc-hist.
  on delete of ub.dis-obj          override do: end.
  on delete of ub.c-dis-obj        override do: end.
  on write  of ub.dis-host         override do: end.
  on write  of ub.dis-card         override do: end.
  on delete  of ub.c-dc-hist       override do: end.
  on write   of ub.c-dc-hist       override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_dis-obj exclusive-lock
      where buf_dis-obj.obj-type = p-obj-type
        and buf_dis-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-dis-obj
          where buf_c-dis-obj.d-card = buf_dis-obj.d-card
            AND buf_c-dis-obj.obj-type = buf_dis-obj.obj-type
            AND buf_c-dis-obj.obj-code = buf_dis-obj.obj-code:
        run delete-route in this-procedure
          ( input 'c-dis-obj':U
          ,input (buffer buf_c-dis-obj:handle)
          ) .
      end.
      for each buf_c-dc-hist
          where buf_c-dc-hist.d-card = buf_dis-obj.d-card
            AND buf_c-dc-hist.chip-num = buf_c-dis-obj.chip-num
            AND buf_c-dc-hist.corr-user-db-num = buf_c-dis-obj.corr-user-db-num
            AND buf_c-dc-hist.host-code = buf_dis-obj.host-code
            AND buf_c-dc-hist.obj-type = buf_dis-obj.obj-type
            AND buf_c-dc-hist.obj-code = buf_dis-obj.obj-code:
        if buf_c-dc-hist.subject = 'dis-obj':U
        and buf_c-dc-hist.source-type = 'касс':U
        then do:
           assign
           buf_c-dc-hist.subject = 'dis-host':U
           buf_c-dc-hist.source-type = 'накл':U
           .
        end.
        else do:
          delete buf_c-dc-hist.
          run delete-route in this-procedure
            ( input 'c-dc-hist':U
            ,input (buffer buf_c-dc-hist:handle)
            ) .
        end.
      end.
      run delete-route in this-procedure
          ( input 'dis-obj':U
          ,input (buffer buf_dis-obj:handle)
          ) .
      delete buf_dis-obj .
    end.
  end.
end procedure.
procedure delete-dis-dc-rule :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_c-dc-hist     for ub.c-dc-hist.
  define buffer buf_clients for ub.clients.
  define buffer buf_dis-card-property for ub.dis-card-property.
  define buffer buf_c-dis-card-property for ub.c-dis-card-property.
  define buffer buf_dis-dc-rule for ub.dis-dc-rule.
  define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.
  on delete  of ub.c-dc-hist       override do: end.
  on delete  of ub.dis-dc-rule   override do: end.
  on delete  of ub.c-dis-dc-rule override do: end.
  define variable v-host-code like ub.sysconf.host-code no-undo .
  define variable ii as integer no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          AND buf_clients.obj-code = p-obj-code.
    assign
    v-host-code = buf_clients.host-code
    .
    for each buf_dis-card-property exclusive-lock
      where buf_dis-card-property.host-code = v-host-code
        and buf_dis-card-property.obj-type = p-obj-type
        and buf_dis-card-property.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-dis-card-property exclusive-lock
        where  buf_c-dis-card-property.d-card = buf_dis-card-property.d-card
          and buf_c-dis-card-property.dt-code = buf_dis-card-property.dt-code
          and buf_c-dis-card-property.node-code = buf_dis-card-property.node-code
          and buf_c-dis-card-property.host-code = buf_dis-card-property.host-code
          and buf_c-dis-card-property.obj-type = p-obj-type
          and buf_c-dis-card-property.obj-code = p-obj-code:
        run delete-route in this-procedure
          ( input 'c-dis-card-property':U
          ,input (buffer buf_c-dis-card-property:handle)
          ) .
        delete buf_c-dis-card-property .
      end.
      for each buf_c-dc-hist
        where buf_c-dc-hist.obj-type = p-obj-type
          AND buf_c-dc-hist.obj-code = p-obj-code
          AND buf_c-dc-hist.d-card = buf_c-dis-card-property.d-card
          AND buf_c-dc-hist.subject = 'dis-card-property':U:
        run delete-route in this-procedure
          ( input 'c-dc-hist':U
          ,input (buffer buf_c-dc-hist:handle)
          ) .
        delete buf_c-dc-hist.
      end.
      run delete-route in this-procedure
        ( input 'dis-card-property':U
        ,input (buffer buf_c-dis-card-property:handle)
        ) .
      delete buf_dis-card-property .
    end.
    for each buf_dis-dc-rule exclusive-lock
      where buf_dis-dc-rule.host-code = v-host-code
        and buf_dis-dc-rule.obj-type = p-obj-type
        and buf_dis-dc-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-dis-dc-rule exclusive-lock
        where  buf_c-dis-dc-rule.d-card = buf_dis-dc-rule.d-card
          and buf_c-dis-dc-rule.pos-type = buf_dis-dc-rule.pos-type
          and buf_c-dis-dc-rule.discnt-role = buf_dis-dc-rule.discnt-role
          and buf_c-dis-dc-rule.nonunique = buf_dis-dc-rule.nonunique
          and buf_c-dis-dc-rule.host-code = buf_dis-dc-rule.host-code
          and buf_c-dis-dc-rule.obj-type = p-obj-type
          and buf_c-dis-dc-rule.obj-code = p-obj-code:
        run delete-route in this-procedure
          ( input 'c-dis-dc-rule':U
          ,input (buffer buf_c-dis-dc-rule:handle)
          ) .
        delete buf_c-dis-dc-rule .
      end.
      for each buf_c-dc-hist
        where buf_c-dc-hist.obj-type = p-obj-type
          AND buf_c-dc-hist.obj-code = p-obj-code
          AND buf_c-dc-hist.d-card = buf_c-dis-dc-rule.d-card
          AND buf_c-dc-hist.subject = 'dis-dc-rule':U:
        run delete-route in this-procedure
          ( input 'c-dc-hist':U
          ,input (buffer buf_c-dc-hist:handle)
          ) .
        delete buf_c-dc-hist.
      end.
      run delete-route in this-procedure
        ( input 'dis-dc-rule':U
        ,input (buffer buf_c-dis-dc-rule:handle)
        ) .
      delete buf_dis-dc-rule .
    end.
  end.
end procedure.
procedure delete-dis-card-type :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_dis-card-type for ub.dis-card-type .
  define buffer buf_dis-card-type-attr for ub.dis-card-type-attr .
  define buffer buf_dis-card-mask for ub.dis-card-mask .
  define buffer buf_dis-dct-rule for ub.dis-dct-rule .
  define buffer buf_c-dis-card-type for ub.c-dis-card-type .
  define buffer buf_c-dis-card-type-attr for ub.c-dis-card-type-attr .
  define buffer buf_c-dis-card-mask for ub.c-dis-card-mask .
  define buffer buf_c-dis-dct-rule for ub.c-dis-dct-rule .
  on delete of ub.dis-card-type override do: end.
  on delete of ub.c-dis-card-type override do: end.
  on delete of ub.dis-card-type-attr override do: end.
  on delete of ub.c-dis-card-type-attr override do: end.
  on delete of ub.dis-card-mask override do: end.
  on delete of ub.c-dis-card-mask override do: end.
  on delete of ub.dis-dct-rule override do: end.
  on delete of ub.c-dis-dct-rule override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_dis-card-type exclusive-lock
      where buf_dis-card-type.obj-type = p-obj-type
        and buf_dis-card-type.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-dis-card-type exclusive-lock
        where buf_c-dis-card-type.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_c-dis-card-type.type = buf_dis-card-type.type
          and buf_c-dis-card-type.host-code = buf_dis-card-type.host-code
          and buf_c-dis-card-type.obj-type = p-obj-type
          and buf_c-dis-card-type.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'c-dis-card-type':U
          ,input (buffer buf_c-dis-card-type:handle)
          ) .
        delete buf_c-dis-card-type .
      end.
      for each buf_dis-card-type-attr exclusive-lock
        where buf_dis-card-type-attr.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_dis-card-type-attr.type = buf_dis-card-type.type
          and buf_dis-card-type-attr.host-code = buf_dis-card-type.host-code
          and buf_dis-card-type-attr.obj-type = p-obj-type
          and buf_dis-card-type-attr.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'dis-card-type-attr':U
          ,input (buffer buf_dis-card-type-attr:handle)
          ) .
        delete buf_dis-card-type-attr .
      end.
      for each buf_c-dis-card-type-attr exclusive-lock
        where buf_c-dis-card-type-attr.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_c-dis-card-type-attr.type = buf_dis-card-type.type
          and buf_c-dis-card-type-attr.host-code = buf_dis-card-type.host-code
          and buf_c-dis-card-type-attr.obj-type = p-obj-type
          and buf_c-dis-card-type-attr.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'c-dis-card-type-attr':U
          ,input (buffer buf_c-dis-card-type-attr:handle)
          ) .
        delete buf_c-dis-card-type-attr .
      end.
      for each buf_dis-card-mask exclusive-lock
        where buf_dis-card-mask.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_dis-card-mask.type = buf_dis-card-type.type
          and buf_dis-card-mask.host-code = buf_dis-card-type.host-code
          and buf_dis-card-mask.obj-type = p-obj-type
          and buf_dis-card-mask.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'dis-card-mask':U
          ,input (buffer buf_dis-card-mask:handle)
          ) .
        delete buf_dis-card-mask .
      end.
      for each buf_c-dis-card-mask exclusive-lock
        where buf_c-dis-card-mask.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_c-dis-card-mask.type = buf_dis-card-type.type
          and buf_c-dis-card-mask.host-code = buf_dis-card-type.host-code
          and buf_c-dis-card-mask.obj-type = p-obj-type
          and buf_c-dis-card-mask.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'c-dis-card-mask':U
          ,input (buffer buf_c-dis-card-mask:handle)
          ) .
        delete buf_c-dis-card-mask .
      end.
      for each buf_dis-dct-rule exclusive-lock
        where buf_dis-dct-rule.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_dis-dct-rule.type = buf_dis-card-type.type
          and buf_dis-dct-rule.host-code = buf_dis-card-type.host-code
          and buf_dis-dct-rule.obj-type = p-obj-type
          and buf_dis-dct-rule.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'dis-dct-rule':U
          ,input (buffer buf_dis-dct-rule:handle)
          ) .
        delete buf_dis-dct-rule .
      end.
      for each buf_c-dis-dct-rule exclusive-lock
        where buf_c-dis-dct-rule.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf_c-dis-dct-rule.type = buf_dis-card-type.type
          and buf_c-dis-dct-rule.host-code = buf_dis-card-type.host-code
          and buf_c-dis-dct-rule.obj-type = p-obj-type
          and buf_c-dis-dct-rule.obj-code = p-obj-code
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'c-dis-dct-rule':U
          ,input (buffer buf_c-dis-dct-rule:handle)
          ) .
        delete buf_c-dis-dct-rule .
      end.
      run delete-route in this-procedure
        ( input 'dis-card-type':U
         ,input (buffer buf_dis-card-type:handle)
        ) .
      delete buf_dis-card-type .
    end.
  end.
end procedure.
procedure delete-dis-rule :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_dis-rule for ub.dis-rule .
  define buffer buf_c-dis-rule for ub.c-dis-rule .
  define buffer buf_clients for ub.clients.
  on delete of ub.dis-rule override do: end.
  on delete of ub.c-dis-rule override do: end.
  define variable v-host-code like ub.sysconf.host-code no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_clients no-lock where
              buf_clients.obj-type = p-obj-type
          AND buf_clients.obj-code = p-obj-code.
    assign
    v-host-code = buf_clients.host-code
    .
    for each buf_dis-rule exclusive-lock
      where buf_dis-rule.host-code = v-host-code
        and buf_dis-rule.obj-type = p-obj-type
        and buf_dis-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-dis-rule exclusive-lock
        where buf_c-dis-rule.rule-num = buf_dis-rule.rule-num
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'c-dis-rule':U
          ,input (buffer buf_c-dis-rule:handle)
          ) .
        delete buf_c-dis-rule .
      end.
      run delete-route in this-procedure
        ( input 'dis-rule':U
         ,input (buffer buf_dis-rule:handle)
        ) .
      delete buf_dis-rule .
    end.
  end.
end procedure.
procedure delete-scales-gds :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_scales-gds for ub.scales-gds .
  define buffer buf_c-scales-gds for ub.scales-gds .
  on delete of ub.scales-gds   override do: end.
  on delete of ub.c-scales-gds override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_scales-gds exclusive-lock
      where buf_scales-gds.obj-type = p-obj-type
        and buf_scales-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'scales-gds':U
         ,input (buffer buf_scales-gds:handle)
        ) .
      delete buf_scales-gds .
    end.
    for each buf_c-scales-gds exclusive-lock
      where buf_c-scales-gds.obj-type = p-obj-type
        and buf_c-scales-gds.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-scales-gds':U
         ,input (buffer buf_c-scales-gds:handle)
        ) .
      delete buf_c-scales-gds .
    end.
  end.
end procedure.
procedure delete-variant-delivery :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_variant-delivery for ub.variant-delivery .
  define buffer buf_c-variant-delivery for ub.c-variant-delivery .
  define buffer buf_var-deliv-gr-per-val for ub.var-deliv-gr-per-val .
  define buffer buf_c-var-deliv-gr-per-val for ub.c-var-deliv-gr-per-val .
  on delete of ub.variant-delivery override do: end.
  on delete of ub.c-variant-delivery override do: end.
  on delete of ub.var-deliv-gr-per-val override do: end.
  on delete of ub.c-var-deliv-gr-per-val override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_variant-delivery exclusive-lock
      where buf_variant-delivery.obj-type = p-obj-type
        and buf_variant-delivery.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-variant-delivery exclusive-lock
        where buf_c-variant-delivery.deliv-type-code = buf_variant-delivery.deliv-type-code
          and buf_c-variant-delivery.deliv-subj-code = buf_variant-delivery.deliv-subj-code
          and buf_c-variant-delivery.obj-type = p-obj-type
          and buf_c-variant-delivery.obj-code = p-obj-code
      on error undo, return error return-value:
        run delete-route in this-procedure
          ( input 'c-variant-delivery':U
          ,input (buffer buf_c-variant-delivery:handle)
          ) .
        delete buf_c-variant-delivery .
      end.
      run delete-route in this-procedure
        ( input 'variant-delivery':U
        ,input (buffer buf_variant-delivery:handle)
        ) .
      delete buf_variant-delivery .
    end.
    for each buf_var-deliv-gr-per-val exclusive-lock
      where buf_var-deliv-gr-per-val.obj-type = p-obj-type
        and buf_var-deliv-gr-per-val.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-var-deliv-gr-per-val exclusive-lock
        where buf_c-var-deliv-gr-per-val.deliv-type-code = buf_var-deliv-gr-per-val.deliv-type-code
          and buf_c-var-deliv-gr-per-val.deliv-subj-code = buf_var-deliv-gr-per-val.deliv-subj-code
          and buf_c-var-deliv-gr-per-val.obj-type = p-obj-type
          and buf_c-var-deliv-gr-per-val.obj-code = p-obj-code
      on error undo, return error return-value:
        run delete-route in this-procedure
          ( input 'c-var-deliv-gr-per-val':U
          ,input (buffer buf_c-var-deliv-gr-per-val:handle)
          ) .
        delete buf_c-var-deliv-gr-per-val .
      end.
      run delete-route in this-procedure
        ( input 'var-deliv-gr-per-val':U
        ,input (buffer buf_var-deliv-gr-per-val:handle)
        ) .
      delete buf_var-deliv-gr-per-val .
    end.
  end.
end procedure.
procedure delete-gds-grp-obj :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_gds-grp-attr for ub.gds-grp-attr .
  define buffer buf_gds-grp-obj for ub.gds-grp-obj .
  define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp .
  define buffer buf_c-gds-grp-attr for ub.c-gds-grp-attr .
  define buffer buf_c-gds-grp-obj for ub.c-gds-grp-obj .
  define buffer buf_c-tax-rate-gds-grp for ub.c-tax-rate-gds-grp .
  define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
  on delete of ub.gds-grp-attr override do: end.
  on delete of ub.gds-grp-obj override do: end.
  on delete of ub.tax-rate-gds-grp override do: end.
  on delete of ub.c-gds-grp-attr override do: end.
  on delete of ub.c-gds-grp-obj override do: end.
  on delete of ub.c-tax-rate-gds-grp override do: end.
  on delete of ub.c-gds-grp-hist override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_gds-grp-attr exclusive-lock
      where buf_gds-grp-attr.obj-type = p-obj-type
        and buf_gds-grp-attr.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-gds-grp-attr exclusive-lock
         WHERE buf_c-gds-grp-attr.node-code = buf_gds-grp-attr.node-code
          AND  buf_c-gds-grp-attr.host-code  = buf_gds-grp-attr.host-code
          AND  buf_c-gds-grp-attr.attr-code  = buf_gds-grp-attr.attr-code
          AND  buf_c-gds-grp-attr.obj-type  = buf_gds-grp-attr.obj-type
          AND  buf_c-gds-grp-attr.obj-code  = buf_gds-grp-attr.obj-code,
         first buf_c-gds-grp-hist exclusive-lock
         WHERE buf_c-gds-grp-hist.node-code = buf_gds-grp-attr.node-code
           AND buf_c-gds-grp-hist.corr-user-db-num  = buf_c-gds-grp-attr.corr-user-db-num
           AND buf_c-gds-grp-hist.chip-num  = buf_c-gds-grp-attr.chip-num
           AND buf_c-gds-grp-hist.attr-code  = buf_gds-grp-attr.attr-code
           AND buf_c-gds-grp-hist.host-code  = buf_gds-grp-attr.host-code
           AND buf_c-gds-grp-hist.obj-type  = buf_gds-grp-attr.obj-type
           AND buf_c-gds-grp-hist.obj-code  = buf_gds-grp-attr.obj-code
           AND buf_c-gds-grp-hist.subject   = 'gds-grp-attr':U
           :
        run delete-route in this-procedure
          ( input 'c-gds-grp-attr':U
          ,input (buffer buf_c-gds-grp-attr:handle)
          ) .
        run delete-route in this-procedure
          ( input 'c-gds-grp-hist':U
          ,input (buffer buf_c-gds-grp-hist:handle)
          ) .
      end.
      run delete-route in this-procedure
        ( input 'gds-grp-attr':U
        ,input (buffer buf_gds-grp-attr:handle)
        ) .
      delete buf_gds-grp-attr .
    end.
    for each buf_gds-grp-obj exclusive-lock
      where buf_gds-grp-obj.obj-type = p-obj-type
        and buf_gds-grp-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-gds-grp-obj exclusive-lock
         WHERE buf_c-gds-grp-obj.node-code = buf_gds-grp-obj.node-code
          AND  buf_c-gds-grp-obj.host-code  = buf_gds-grp-obj.host-code
          AND  buf_c-gds-grp-obj.obj-type  = buf_gds-grp-obj.obj-type
          AND  buf_c-gds-grp-obj.obj-code  = buf_gds-grp-obj.obj-code ,
         first buf_c-gds-grp-hist exclusive-lock
         WHERE buf_c-gds-grp-hist.node-code = buf_gds-grp-obj.node-code
           AND buf_c-gds-grp-hist.corr-user-db-num  = buf_c-gds-grp-obj.corr-user-db-num
           AND buf_c-gds-grp-hist.chip-num  = buf_c-gds-grp-obj.chip-num
           AND buf_c-gds-grp-hist.host-code  = buf_gds-grp-obj.host-code
           AND buf_c-gds-grp-hist.obj-type  = buf_gds-grp-obj.obj-type
           AND buf_c-gds-grp-hist.obj-code  = buf_gds-grp-obj.obj-code
           AND buf_c-gds-grp-hist.subject   = 'gds-grp-obj':U
           :
        run delete-route in this-procedure
          ( input 'c-gds-grp-obj':U
          ,input (buffer buf_c-gds-grp-obj:handle)
          ) .
        run delete-route in this-procedure
          ( input 'c-gds-grp-hist':U
          ,input (buffer buf_c-gds-grp-hist:handle)
          ) .
      end.
      run delete-route in this-procedure
        ( input 'gds-grp-obj':U
        ,input (buffer buf_gds-grp-obj:handle)
        ) .
      delete buf_gds-grp-obj .
    end.
  end.
end procedure.
procedure delete-sum-grp-obj :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_sum-grp-obj for ub.sum-grp-obj .
  define buffer buf_c-sum-grp-obj for ub.c-sum-grp-obj .
  define buffer buf_dis-grp-rule for ub.dis-grp-rule.
  define buffer buf_c-dis-grp-rule for ub.c-dis-grp-rule.
  on delete of ub.sum-grp-obj override do: end.
  on delete of ub.c-sum-grp-obj override do: end.
  on delete of ub.dis-grp-rule override do: end.
  on delete of ub.c-dis-grp-rule override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_sum-grp-obj exclusive-lock
      where buf_sum-grp-obj.obj-type = p-obj-type
        and buf_sum-grp-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'sum-grp-obj':U
        ,input (buffer buf_sum-grp-obj:handle)
        ) .
      delete buf_sum-grp-obj .
    end.
    for each buf_c-sum-grp-obj exclusive-lock
      where buf_c-sum-grp-obj.obj-type = p-obj-type
        and buf_c-sum-grp-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-sum-grp-obj':U
        ,input (buffer buf_c-sum-grp-obj:handle)
        ) .
      delete buf_c-sum-grp-obj .
    end.
    for each buf_c-dis-grp-rule exclusive-lock
      where buf_c-dis-grp-rule.obj-type = p-obj-type
        and buf_c-dis-grp-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'c-dis-grp-rule':U
        ,input (buffer buf_c-dis-grp-rule:handle)
        ) .
      delete buf_c-dis-grp-rule .
    end.
    for each buf_dis-grp-rule exclusive-lock
      where buf_dis-grp-rule.obj-type = p-obj-type
        and buf_dis-grp-rule.obj-code = p-obj-code
    on error undo, return error return-value
    :
      run delete-route in this-procedure
        ( input 'dis-grp-rule':U
        ,input (buffer buf_dis-grp-rule:handle)
        ) .
      delete buf_dis-grp-rule .
    end.
  end.
end procedure.
procedure delete-config :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    on delete of ub.config   override do: end.
    on delete of ub.c-config override do: end.
    define buffer buf_config   for ub.config .
    define buffer buf_c-config for ub.c-config .
    for each buf_config exclusive-lock
      where buf_config.obj-type = p-obj-type
        and buf_config.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-config exclusive-lock
        where buf_c-config.param-code = buf_config.param-code
          and buf_c-config.host-code  = buf_config.host-code
          and buf_c-config.obj-type   = buf_config.obj-type
          and buf_c-config.obj-code   = buf_config.obj-code
          and buf_c-config.beg-date   = buf_config.beg-date
          and buf_c-config.end-date   = buf_config.end-date
          and buf_c-config.db-num     = buf_config.db-num
      on error undo, return error return-value
      :
        delete buf_c-config .
        run delete-route in this-procedure
          ( input 'c-config':U
          , input (buffer buf_c-config:handle)
          ) .
      end.
      delete buf_config .
      run delete-route in this-procedure
        ( input 'config':U
        , input (buffer buf_config:handle)
        ) .
    end.
  end.
end procedure.
procedure delete-user-obj :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_user-obj for ub.user-obj .
  define buffer buf_user-menu-group        for ub.user-menu-group .
  define buffer buf_user-login-action-role for ub.user-login-action-role .
  on delete of ub.user-obj                override do: end.
  on delete of ub.user-menu-group         override do: end.
  on delete of ub.user-login-action-role  override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_user-obj exclusive-lock
      where buf_user-obj.obj-type = p-obj-type
        and buf_user-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_user-obj .
      run delete-route in this-procedure
        ( input 'user-obj':U
        , input (buffer buf_user-obj:handle)
        ) .
    end.
    for each  buf_user-menu-group
        where buf_user-menu-group.db-num   = ub.user-obj.db-num
          and buf_user-menu-group.user-id  = ub.user-obj.user-id
          and buf_user-menu-group.obj-type = ub.user-obj.obj-type
          and buf_user-menu-group.obj-code = ub.user-obj.obj-code
          and buf_user-menu-group.menu-group-context = 'object':U
        exclusive-lock
        :
        delete buf_user-menu-group.
      run delete-route in this-procedure
        ( input 'user-menu-group':U
        , input (buffer buf_user-menu-group:handle)
        ) .
    end.
    for each  buf_user-login-action-role
        where buf_user-login-action-role.db-num  = ub.user-obj.db-num
          and buf_user-login-action-role.user-id = ub.user-obj.user-id
          and buf_user-login-action-role.obj-type = ub.user-obj.obj-type
          and buf_user-login-action-role.obj-code = ub.user-obj.obj-code
          and buf_user-login-action-role.action-role-context = 'object':U
        exclusive-lock
        :
        delete buf_user-login-action-role.
      run delete-route in this-procedure
        ( input 'user-login-action-role':U
        , input (buffer buf_user-login-action-role:handle)
        ) .
    end.
  end.
end procedure.
procedure delete-action-post-obj :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_action-post-obj for ub.action-post-obj .
  on delete of ub.action-post-obj  override do: end.
  do
  on error undo, return error return-value
  :
    for each buf_action-post-obj exclusive-lock
      where buf_action-post-obj.obj-type = p-obj-type
        and buf_action-post-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_action-post-obj .
      run delete-route in this-procedure
        ( input 'action-post-obj':U
        , input (buffer buf_action-post-obj:handle)
        ) .
    end.
  end.
end procedure.
procedure delete-clients :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-uniq-ky-rec as character no-undo .
  define buffer buf_clients      for ub.clients .
  define buffer buf_c-clients    for ub.c-clients .
  define buffer buf_clients-attr for ub.clients-attr .
  define buffer buf_c-clients-attr for ub.c-clients-attr .
  define buffer buf_thbj-attr for ub.thbj-attr .
  define buffer buf_c-thbj-attr for ub.c-thbj-attr .
  define buffer buf_shop         for ub.shop .
  define buffer buf_c-shop       for ub.c-shop .
  define buffer buf_store        for ub.store .
  define buffer buf_c-store        for ub.c-store .
  define buffer buf_cash-desk    for ub.cash-desk .
  define buffer buf_c-cash-desk  for ub.c-cash-desk .
  define buffer buf_cash-desk-attr    for ub.cash-desk-attr .
  define buffer buf_c-cash-desk-attr  for ub.c-cash-desk-attr .
  define buffer buf_cash-pay-attr    for ub.cash-pay-attr .
  define buffer buf_c-cash-pay-attr  for ub.c-cash-pay-attr .
  define buffer buf_dis-cp-rule for ub.dis-cp-rule.
  define buffer buf_c-dis-cp-rule for ub.c-dis-cp-rule.
  define buffer buf_curr-shop    for ub.curr-shop .
  define buffer buf_c-cli-hist   for ub.c-cli-hist.
  define buffer buf_dis-thbj-rule for ub.dis-thbj-rule .
  define buffer buf_c-dis-thbj-rule for ub.c-dis-thbj-rule .
  define buffer buf_cd-clu for ub.cd-clu.
  define buffer buf_c-cd-clu for ub.c-cd-clu.
  define buffer buf_cd-dlu for ub.cd-dlu.
  define buffer buf_c-cd-dlu for ub.c-cd-dlu.
  define buffer buf_cd-grp for ub.cd-grp.
  define buffer buf_c-cd-grp for ub.c-cd-grp.
  define buffer buf_cd-plu for ub.cd-plu.
  define buffer buf_c-cd-plu for ub.c-cd-plu.
  define buffer buf_cd-doc for ub.cd-doc.
  define buffer buf_c-cd-doc for ub.c-cd-doc.
  define buffer buf_cd-doc-line for ub.cd-doc-line.
  define buffer buf_c-cd-doc-line for ub.c-cd-doc-line.
  on delete of ub.clients       override do: end.
  on delete of ub.c-clients     override do: end.
  on delete of ub.clients-attr  override do: end.
  on delete of ub.c-clients-attr  override do: end.
  on delete of ub.thbj-attr  override do: end.
  on delete of ub.c-thbj-attr  override do: end.
  on delete of ub.shop          override do: end.
  on delete of ub.c-shop          override do: end.
  on delete of ub.store         override do: end.
  on delete of ub.c-store         override do: end.
  on delete of ub.cash-desk     override do: end.
  on delete of ub.c-cash-desk   override do: end.
  on delete of ub.cash-desk-attr     override do: end.
  on delete of ub.c-cash-desk-attr   override do: end.
  on delete of ub.cash-pay-attr     override do: end.
  on delete of ub.c-cash-pay-attr   override do: end.
  on delete of ub.dis-cp-rule     override do: end.
  on delete of ub.dis-cp-rule     override do: end.
  on delete of ub.curr-shop     override do: end.
  on delete of ub.c-cli-hist    override do: end.
  on delete of ub.dis-thbj-rule  override do: end.
  on delete of ub.c-dis-thbj-rule override do: end.
  on delete of ub.cd-clu override do: end.
  on delete of ub.c-cd-clu override do: end.
  on delete of ub.cd-dlu override do: end.
  on delete of ub.c-cd-dlu override do: end.
  on delete of ub.cd-grp override do: end.
  on delete of ub.c-cd-grp override do: end.
  on delete of ub.cd-plu override do: end.
  on delete of ub.c-cd-plu override do: end.
  on delete of ub.cd-doc override do: end.
  on delete of ub.c-cd-doc override do: end.
  on delete of ub.cd-doc-line override do: end.
  on delete of ub.c-cd-doc-line override do: end.
  do
  on error undo, return error
  :
    find first buf_clients exclusive-lock
      where buf_clients.obj-type = p-obj-type
        and buf_clients.obj-code = p-obj-code
      .
    run gen-key-rec in this-procedure ( input 'clients':U
                                      ,input (buffer buf_clients:handle)
                                      ,output v-uniq-key-rec).
    if buf_clients.obj-type = 'скл':U then do:
      find buf_store exclusive-lock
        where buf_store.obj-code = buf_clients.obj-code
        .
      run delete-route in this-procedure
        ( input 'store':U
         ,input (buffer buf_store:handle)
        ) .
      for each buf_c-store exclusive-lock
          where buf_c-store.obj-code  = buf_clients.obj-code:
        run delete-route in this-procedure
          ( input 'store':U
          ,input (buffer buf_store:handle)
          ) .
        delete buf_c-store.
      end.
      delete buf_store .
    end.
    if buf_clients.obj-type = 'маг':U then do:
      find buf_shop exclusive-lock
        where buf_shop.obj-code = buf_clients.obj-code
        .
      run delete-route in this-procedure
        ( input 'shop':U
         ,input (buffer buf_shop:handle)
        ) .
      for each buf_c-shop exclusive-lock
          where buf_c-shop.obj-code  = buf_clients.obj-code:
        run delete-route in this-procedure
          ( input 'shop':U
          ,input (buffer buf_shop:handle)
          ) .
        delete buf_c-shop.
      end.
      for each buf_cash-desk exclusive-lock
        where buf_cash-desk.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'cash-desk':U
          ,input (buffer buf_cash-desk:handle)
          ) .
        delete buf_cash-desk .
      end.
      for each buf_c-cash-desk exclusive-lock
        where buf_c-cash-desk.db-num   = buf_clients.db-num
          AND buf_c-cash-desk.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'c-cash-desk':U
          ,input (buffer buf_c-cash-desk:handle)
          ) .
        delete buf_c-cash-desk .
      end.
      for each buf_cash-desk-attr exclusive-lock
        where buf_cash-desk-attr.db-num   = buf_clients.db-num
          AND buf_cash-desk-attr.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'cash-desk-attr':U
          ,input (buffer buf_cash-desk-attr:handle)
          ) .
        delete buf_cash-desk-attr .
      end.
      for each buf_c-cash-desk-attr exclusive-lock
        where buf_c-cash-desk-attr.db-num   = buf_clients.db-num
          AND buf_c-cash-desk-attr.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'c-cash-desk-attr':U
          ,input (buffer buf_c-cash-desk-attr:handle)
          ) .
        delete buf_c-cash-desk-attr .
      end.
      for each buf_cd-clu exclusive-lock
        where buf_cd-clu.obj-type = 'маг':U
          AND buf_cd-clu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'cd-clu':U
          ,input (buffer buf_cd-clu:handle)
          ) .
        delete buf_cd-clu .
      end.
      for each buf_c-cd-clu exclusive-lock
        where buf_c-cd-clu.obj-type = 'маг':U
          AND buf_c-cd-clu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'c-cd-clu':U
          ,input (buffer buf_c-cd-clu:handle)
          ) .
        delete buf_c-cd-clu .
      end.
      for each buf_cd-dlu exclusive-lock
        where buf_cd-dlu.obj-type = 'маг':U
          AND buf_cd-dlu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'cd-dlu':U
          ,input (buffer buf_cd-dlu:handle)
          ) .
        delete buf_cd-dlu .
      end.
      for each buf_c-cd-dlu exclusive-lock
        where buf_c-cd-dlu.obj-type = 'маг':U
          AND buf_c-cd-dlu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'c-cd-dlu':U
          ,input (buffer buf_c-cd-dlu:handle)
          ) .
        delete buf_c-cd-dlu .
      end.
      for each buf_cd-grp exclusive-lock
        where buf_cd-grp.obj-type = 'маг':U
          AND buf_cd-grp.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'cd-grp':U
          ,input (buffer buf_cd-grp:handle)
          ) .
        delete buf_cd-grp .
      end.
      for each buf_c-cd-grp exclusive-lock
        where buf_c-cd-grp.obj-type = 'маг':U
          AND buf_c-cd-grp.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'c-cd-grp':U
          ,input (buffer buf_c-cd-grp:handle)
          ) .
        delete buf_c-cd-grp .
      end.
      for each buf_cd-plu exclusive-lock
        where buf_cd-plu.obj-type = 'маг':U
          AND buf_cd-plu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'cd-plu':U
          ,input (buffer buf_cd-plu:handle)
          ) .
        delete buf_cd-plu .
      end.
      for each buf_c-cd-plu exclusive-lock
        where buf_c-cd-plu.obj-type = 'маг':U
          AND buf_c-cd-plu.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'c-cd-plu':U
          ,input (buffer buf_c-cd-plu:handle)
          ) .
        delete buf_c-cd-plu .
      end.
      for each buf_cd-doc exclusive-lock
        where buf_cd-doc.obj-type = 'маг':U
          AND buf_cd-doc.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'cd-doc':U
          ,input (buffer buf_cd-doc:handle)
          ) .
        delete buf_cd-doc .
      end.
      for each buf_c-cd-doc exclusive-lock
        where buf_c-cd-doc.obj-type = 'маг':U
          AND buf_c-cd-doc.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'c-cd-doc':U
          ,input (buffer buf_c-cd-doc:handle)
          ) .
        delete buf_c-cd-doc .
      end.
      for each buf_cd-doc-line exclusive-lock
        where buf_cd-doc-line.obj-type = 'маг':U
          AND buf_cd-doc-line.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'cd-doc-line':U
          ,input (buffer buf_cd-doc-line:handle)
          ) .
        delete buf_cd-doc-line .
      end.
      for each buf_c-cd-doc-line exclusive-lock
        where buf_c-cd-doc-line.obj-type = 'маг':U
          AND buf_c-cd-doc-line.obj-code = buf_shop.obj-code
      on error undo, return error
      :
        run delete-route in this-procedure
          ( input 'c-cd-doc-line':U
          ,input (buffer buf_c-cd-doc-line:handle)
          ) .
        delete buf_c-cd-doc-line .
      end.
      for each buf_cash-pay-attr exclusive-lock
        where buf_cash-pay-attr.obj-code = buf_shop.obj-code
          AND buf_cash-pay-attr.obj-type = 'маг':U
      on error undo, return error
      :
        for each buf_c-cash-pay-attr exclusive-lock
          where buf_c-cash-pay-attr.cdpay-code = buf_cash-pay-attr.cdpay-code
            AND buf_c-cash-pay-attr.curr-code = buf_cash-pay-attr.curr-code
            AND buf_c-cash-pay-attr.host-code = buf_cash-pay-attr.host-code
            AND buf_c-cash-pay-attr.obj-type = buf_cash-pay-attr.obj-type
            AND buf_c-cash-pay-attr.obj-code = buf_shop.obj-code
        on error undo, return error
        :
          run delete-route in this-procedure
            ( input 'c-cash-pay-attr':U
            ,input (buffer buf_c-cash-pay-attr:handle)
            ) .
          delete buf_c-cash-pay-attr .
        end.
        run delete-route in this-procedure
          ( input 'cash-pay-attr':U
          ,input (buffer buf_cash-pay-attr:handle)
          ) .
        delete buf_cash-pay-attr .
      end.
      for each buf_dis-cp-rule exclusive-lock
        where buf_dis-cp-rule.obj-code = buf_shop.obj-code
          AND buf_dis-cp-rule.obj-type = 'маг':U
      on error undo, return error
      :
        for each buf_c-dis-cp-rule exclusive-lock
          where buf_c-dis-cp-rule.cdpay-code = buf_dis-cp-rule.cdpay-code
            AND buf_c-dis-cp-rule.curr-code = buf_dis-cp-rule.curr-code
            AND buf_c-dis-cp-rule.obj-type = buf_dis-cp-rule.obj-type
            AND buf_c-dis-cp-rule.obj-code = buf_shop.obj-code
        on error undo, return error
        :
          run delete-route in this-procedure
            ( input 'c-dis-cp-rule':U
            ,input (buffer buf_c-dis-cp-rule:handle)
            ) .
          delete buf_c-dis-cp-rule .
        end.
        run delete-route in this-procedure
          ( input 'dis-cp-rule':U
          ,input (buffer buf_dis-cp-rule:handle)
          ) .
        delete buf_dis-cp-rule .
      end.
      delete buf_shop.
    end.
    for each buf_curr-shop exclusive-lock
      where buf_curr-shop.obj-type = p-obj-type
        and buf_curr-shop.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'curr-shop':U
         ,input (buffer buf_curr-shop:handle)
        ) .
      delete buf_curr-shop .
    end.
    for each buf_clients-attr exclusive-lock
      where buf_clients-attr.obj-type = p-obj-type
        and buf_clients-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'clients-attr':U
         ,input (buffer buf_clients-attr:handle)
        ) .
      delete buf_clients-attr .
    end.
    for each buf_c-clients-attr exclusive-lock
      where buf_c-clients-attr.obj-type = p-obj-type
        and buf_c-clients-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-clients-attr':U
         ,input (buffer buf_c-clients-attr:handle)
        ) .
      delete buf_c-clients-attr .
    end.
    for each buf_thbj-attr exclusive-lock
      where buf_thbj-attr.obj-type = p-obj-type
        and buf_thbj-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'thbj-attr':U
         ,input (buffer buf_thbj-attr:handle)
        ) .
      delete buf_thbj-attr .
    end.
    for each buf_c-thbj-attr exclusive-lock
      where buf_c-thbj-attr.obj-type = p-obj-type
        and buf_c-thbj-attr.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-thbj-attr':U
         ,input (buffer buf_c-thbj-attr:handle)
        ) .
      delete buf_c-thbj-attr .
    end.
    for each buf_dis-thbj-rule exclusive-lock
      where buf_dis-thbj-rule.obj-type = p-obj-type
        and buf_dis-thbj-rule.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'dis-thbj-rule':U
         ,input (buffer buf_dis-thbj-rule:handle)
        ) .
      delete buf_dis-thbj-rule .
    end.
    for each buf_c-dis-thbj-rule exclusive-lock
      where buf_c-dis-thbj-rule.obj-type = p-obj-type
        and buf_c-dis-thbj-rule.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-dis-thbj-rule':U
         ,input (buffer buf_c-dis-thbj-rule:handle)
        ) .
      delete buf_c-dis-thbj-rule .
    end.
    for each buf_c-clients exclusive-lock
      where buf_c-clients.obj-type = p-obj-type
        and buf_c-clients.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-clients':U
         ,input (buffer buf_c-clients:handle)
        ) .
      delete buf_c-clients .
    end.
    for each buf_c-cli-hist exclusive-lock
      where buf_c-cli-hist.obj-type = p-obj-type
        and buf_c-cli-hist.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure
        ( input 'c-cli-hist':U
         ,input (buffer buf_c-cli-hist:handle)
        ) .
      delete buf_c-cli-hist .
    end.
    run delete-route in this-procedure
      ( input 'clients':U
       ,input (buffer buf_clients:handle)
      ) .
    delete buf_clients .
  end.
end procedure.
procedure delete-arh-trn-doc-contract:
  define input parameter p-obj-type like ub.clients.obj-type no-undo.
  define input parameter p-obj-code like ub.clients.obj-code no-undo.
  define buffer buf_arh-trn-doc-contract for ub.arh-trn-doc-contract.
  on delete of ub.arh-trn-doc-contract override do:
  end.
  for each buf_arh-trn-doc-contract where buf_arh-trn-doc-contract.obj-type = p-obj-type and
                                          buf_arh-trn-doc-contract.obj-code = p-obj-code exclusive-lock on error undo, return error return-value :
    delete buf_arh-trn-doc-contract.
  end.
end.
procedure delete-place-io :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_place-io for ub.place-io .
  define buffer buf_c-place-io for ub.c-place-io .
  define buffer buf_point-place-rel for ub.point-place-rel .
  define buffer buf_c-point-place-rel for ub.c-point-place-rel .
  define buffer buf_point-point-rel for ub.point-point-rel .
  define buffer buf_c-point-point-rel for ub.c-point-point-rel .
  define buffer buf_point-io for ub.point-io .
  define buffer buf_c-point-io for ub.c-point-io .
  on delete of ub.place-io override do: end.
  on delete of ub.c-place-io override do: end.
  on delete of ub.point-place-rel override do: end.
  on delete of ub.c-point-place-rel override do: end.
  on delete of ub.point-point-rel override do: end.
  on delete of ub.c-point-point-rel override do: end.
  on delete of ub.point-io override do: end.
  on delete of ub.c-point-io override do: end.
  do on error undo, return error :
    for each buf_place-io exclusive-lock
      where buf_place-io.obj-type = p-obj-type
        and buf_place-io.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input 'place-io':U,input (buffer buf_place-io:handle) ) .
      delete buf_place-io .
    end.
  end.
  do on error undo, return error :
    for each buf_c-place-io exclusive-lock
      where buf_c-place-io.obj-type = p-obj-type
        and buf_c-place-io.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input 'c-place-io':U,input (buffer buf_c-place-io:handle) ) .
      delete buf_c-place-io .
    end.
  end.
  do on error undo, return error :
    for each buf_point-place-rel exclusive-lock
      where buf_point-place-rel.obj-type = p-obj-type
        and buf_point-place-rel.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input 'point-place-rel':U,input (buffer buf_point-place-rel:handle) ) .
      delete buf_point-place-rel .
    end.
  end.
  do on error undo, return error :
    for each buf_c-point-place-rel exclusive-lock
      where buf_c-point-place-rel.obj-type = p-obj-type
        and buf_c-point-place-rel.obj-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input 'c-point-place-rel':U,input (buffer buf_c-point-place-rel:handle) ) .
      delete buf_c-point-place-rel .
    end.
  end.
  do on error undo, return error :
    for each  buf_point-io no-lock where
             buf_point-io.cli-type = p-obj-type
         and buf_point-io.cli-code = p-obj-code,
       first buf_point-point-rel exclusive-lock
      where buf_point-point-rel.from-db-num = buf_point-io.db-num
        and buf_point-point-rel.from-point-code = buf_point-io.point-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input 'point-point-rel':U,input (buffer buf_point-point-rel:handle) ) .
      delete buf_point-point-rel .
    end.
    for each  buf_point-io no-lock where
             buf_point-io.cli-type = p-obj-type
         and buf_point-io.cli-code = p-obj-code,
       first buf_point-point-rel exclusive-lock
      where buf_point-point-rel.to-db-num = buf_point-io.db-num
        and buf_point-point-rel.to-point-code = buf_point-io.point-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input 'point-point-rel':U,input (buffer buf_point-point-rel:handle) ) .
      delete buf_point-point-rel .
    end.
  end.
  do on error undo, return error :
    for each  buf_point-io no-lock where
             buf_point-io.cli-type = p-obj-type
         and buf_point-io.cli-code = p-obj-code,
       first buf_c-point-point-rel exclusive-lock
      where buf_c-point-point-rel.from-db-num = buf_point-io.db-num
        and buf_c-point-point-rel.from-point-code = buf_point-io.point-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input 'c-point-point-rel':U,input (buffer buf_c-point-point-rel:handle) ) .
      delete buf_c-point-point-rel .
    end.
  end.
  do on error undo, return error :
    for each  buf_point-io no-lock where
             buf_point-io.cli-type = p-obj-type
         and buf_point-io.cli-code = p-obj-code,
       first buf_c-point-point-rel exclusive-lock
      where buf_c-point-point-rel.to-db-num = buf_point-io.db-num
        and buf_c-point-point-rel.to-point-code = buf_point-io.point-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input 'c-point-point-rel':U,input (buffer buf_c-point-point-rel:handle) ) .
      delete buf_c-point-point-rel .
    end.
  end.
  do on error undo, return error :
    for each buf_point-io exclusive-lock
      where buf_point-io.cli-type = p-obj-type
        and buf_point-io.cli-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input 'point-io':U,input (buffer buf_point-io:handle) ) .
      delete buf_point-io .
    end.
  end.
  do on error undo, return error :
    for each buf_c-point-io exclusive-lock
      where buf_c-point-io.cli-type = p-obj-type
        and buf_c-point-io.cli-code = p-obj-code
    on error undo, return error
    :
      run delete-route in this-procedure  ( input 'c-point-io':U,input (buffer buf_c-point-io:handle) ) .
      delete buf_c-point-io .
    end.
  end.
end procedure.
procedure delete-batchprocess :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer calc-arh-lock_batchprocess for ub.batchprocess .
    run gbl/lock-prc.p
      (input 'btpr':U
      ,input p-obj-code
      ,input 0
      ,input 0
      ,input p-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по товарам"
      ,input true
      ,buffer calc-arh-lock_batchprocess
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по товарам" skip
        "Невозможно удалить объект" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error .
    end.
    define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .
    run gbl/lock-prc.p
      (input 'ahsp':U
      ,input p-obj-code
      ,input 0
      ,input 0
      ,input p-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
      ,input true
      ,buffer calc-supp-arh-lock_batchprocess
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по поставщикам" skip
        "Невозможно удалить объект" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error .
    end.
    define buffer calc-aht-lock_batchprocess for ub.batchprocess .
    run gbl/lock-prc.p
      (input 'ahtb':U
      ,input p-obj-code
      ,input 0
      ,input 0
      ,input p-obj-type
      ,input ""
      ,input ""
      ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
      ,input true
      ,buffer calc-aht-lock_batchprocess
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "В данный момент рассчитывается складской архив по типам приобретения" skip
        "Невозможно удалить объект" skip
        "Объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error .
    end.
    run doclslib-clear-doc-list in this-procedure .
    run doclslib-init-trn-doc in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input ?
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры doclslib-init-trn-doc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run doclslib-init-price-doc in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input ?
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры doclslib-init-price-doc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run doclslib-clear-batch-process in this-procedure
      (input 'arh':U
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clear-batch-process" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run doclslib-clear-batch-process in this-procedure
      (input 'ahsp':U
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clear-batch-process" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure delete-nws-doc-hist :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_nws-doc-hist for ub.nws-doc-hist .
  do
  on error undo, return error return-value
  :
    for each buf_nws-doc-hist exclusive-lock
      where buf_nws-doc-hist.obj-type = p-obj-type
        and buf_nws-doc-hist.obj-code = p-obj-code
    on error undo, return error return-value
    :
      delete buf_nws-doc-hist .
    end.
  end.
end procedure.
procedure delete-stop-list :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define variable v-host-code as integer no-undo .
  define buffer buf_stop-list for ub.stop-list .
  define buffer buf_stop-list-line for ub.stop-list-line .
  define buffer buf_c-stop-list for ub.c-stop-list .
  define buffer buf_c-stop-list-line for ub.c-stop-list-line .
  define buffer buf_sysconf for ub.sysconf.
  on delete of ub.stop-list override do: end.
  on delete of ub.c-stop-list override do: end.
  on delete of ub.stop-list-line override do: end.
  on delete of ub.c-stop-list-line override do: end.
  do
  on error undo, return error return-value
  :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = v-host-code.
    for each buf_stop-list exclusive-lock
      where buf_stop-list.obj-type = p-obj-type
        and buf_stop-list.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_stop-list-line exclusive-lock
        where buf_stop-list-line.classif-type = buf_stop-list.classif-type
        and buf_stop-list-line.stop-list-code = buf_stop-list.stop-list-code
      on error undo, return error return-value
      :
        delete buf_stop-list-line .
      end.
      for each buf_c-stop-list exclusive-lock
        where buf_c-stop-list.classif-type = buf_stop-list.classif-type
        and buf_c-stop-list.stop-list-code = buf_stop-list.stop-list-code
      on error undo, return error return-value
      :
        delete buf_c-stop-list .
      end.
      for each buf_c-stop-list-line exclusive-lock
        where buf_c-stop-list-line.classif-type = buf_stop-list.classif-type
        and buf_c-stop-list-line.stop-list-code = buf_stop-list.stop-list-code
      on error undo, return error return-value
      :
        delete buf_c-stop-list-line .
      end.
      run delete-route in this-procedure
        ( input 'stop-list':U
         ,input (buffer buf_stop-list:handle)
        ) .
      delete buf_stop-list .
    end.
    for each buf_c-stop-list exclusive-lock
      where buf_c-stop-list.obj-type = p-obj-type
        and buf_c-stop-list.obj-code = p-obj-code
    on error undo, return error return-value
    :
      for each buf_c-stop-list-line exclusive-lock
        where buf_c-stop-list-line.classif-type = buf_stop-list.classif-type
        and buf_c-stop-list-line.stop-list-code = buf_c-stop-list.stop-list-code
      on error undo, return error return-value
      :
        delete buf_c-stop-list-line .
      end.
      run delete-route in this-procedure
        ( input 'c-stop-list':U
         ,input (buffer buf_c-stop-list:handle)
        ) .
      delete buf_c-stop-list .
    end.
  end.
end procedure.
procedure convert-payment :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type-code as character no-undo .
define buffer buf_payment for ub.payment.
define buffer buf_sysconf for ub.sysconf.
on write of ub.payment override do: end.
  do
  on error undo, return error
  :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    v-obj-type-code = substitute('&1&2-', p-obj-type, p-obj-code).
    find first buf_sysconf no-lock where
            buf_sysconf.host-code = v-host-code.
    for each buf_payment where
            buf_payment.host-code = v-host-code
        and buf_payment.source-type = 'касс':U
        and buf_payment.source-ref begins v-obj-type-code
      on error undo, return error return-value
      :
        assign
        buf_payment.source-type = '':U
        buf_payment.pay-code = buf_sysconf.cash-pay
        buf_payment.PS = substitute("!смена типа/кода платежа после удаления объекта &1&2", p-obj-type, p-obj-code)
        .
    end.
    for each buf_payment where
            buf_payment.host-code = v-host-code
        and buf_payment.source-type = 'накл':U
        and buf_payment.source-ref begins v-obj-type-code
      on error undo, return error return-value
      :
        assign
        buf_payment.source-type = '':U
        buf_payment.PS = substitute("!смена типа платежа после удаления объекта &1&2", p-obj-type, p-obj-code)
        .
    end.
  end.
end procedure.
procedure delete-ext-classif :
  define input  parameter p-uniq-key-rec as character no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_ext-classif      for ub.ext-classif .
  define buffer buf_c-ext-classif      for ub.c-ext-classif .
  define buffer buf_clients for ub.clients.
  on delete of ub.ext-classif override do: end.
  on delete of ub.c-ext-classif override do: end.
  define variable v-uniq-key-rec as character no-undo .
  define variable v-names as character no-undo .
  define variable v-ii as integer no-undo .
  do
  on error undo, return error return-value
  :
    v-names = 'clients-esys':U .
    do v-ii = 1 to num-entries(v-names):
      for each buf_Ext-classif where
              buf_ext-classif.classif-name = entry(v-ii, v-names)
          and buf_Ext-classif.uniq-key-rec = p-uniq-key-rec
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'ext-classif':U
          ,input (buffer buf_ext-classif:handle)
          ) .
        delete buf_ext-classif .
      end.
      for each buf_c-Ext-classif where
              buf_c-ext-classif.classif-name = entry(v-ii, v-names)
          and buf_c-Ext-classif.uniq-key-rec = p-uniq-key-rec
      on error undo, return error return-value
      :
        run delete-route in this-procedure
          ( input 'c-ext-classif':U
          ,input (buffer buf_c-ext-classif:handle)
          ) .
        delete buf_c-ext-classif .
      end.
    end.
  end.
end procedure.
procedure delete-egais :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_egais-clients for ub.egais-clients.
  do
  on error undo, return error return-value
  :
    for each buf_egais-clients exclusive-lock
      where buf_egais-clients.obj-type = p-obj-type
        and buf_egais-clients.obj-code = p-obj-code
    :
      assign
        buf_egais-clients.obj-type = ''
        buf_egais-clients.obj-code = 0
      .
    end.
  end.
end procedure.
procedure check-can-delete :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_db for ub.db .
    define buffer buf_clients for ub.clients .
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer supp_clients for ub.clients .
    define variable v-return-error as logical   no-undo .
    for each buf_trn-doc no-lock
      where buf_trn-doc.hold-obj-type = p-obj-type
        and buf_trn-doc.hold-obj-code = p-obj-code
        and buf_trn-doc.status_ <> 'факт':U
    on error undo, return error return-value
    :
        assign
          v-return-error = true
        .
        run log-error in this-procedure
          (input substitute("Объект &1 &2, Документ МФ &3"
                  ,buf_trn-doc.obj-type
                  ,buf_trn-doc.obj-code
                  ,buf_trn-doc.doc-code
                  )
          ) .
    end.
    for each buf_db no-lock
    on error undo, return error return-value
    :
      for each buf_clients no-lock
        where buf_clients.db-num = buf_db.db-num
      on error undo, return error return-value
      :
        for each buf_trn-doc no-lock
          where buf_trn-doc.obj-type = buf_clients.obj-type
            and buf_trn-doc.obj-code = buf_clients.obj-code
            and buf_trn-doc.status_ <> 'факт':U
        on error undo, return error return-value
        :
          find first supp_clients no-lock
            where supp_clients.obj-type = buf_trn-doc.obj-type
              and supp_clients.obj-code = buf_trn-doc.obj-code
            no-error .
          if not available supp_clients then do:
            assign
              v-return-error = true
            .
            run log-error in this-procedure
              (input substitute("Объект &1 &2. Документ &3. Неизвестный контрагент"
                     ,buf_clients.obj-type
                     ,buf_clients.obj-code
                     ,buf_trn-doc.doc-code
                     )
              ) .
            next .
          end.
          if supp_clients.db-num <> ?
          and supp_clients.obj-type = p-obj-type
          and supp_clients.obj-code = p-obj-code
          then do:
            assign
              v-return-error = true
            .
            run log-error in this-procedure
              (input substitute("Объект &1 &2, Документ &3"
                     ,buf_clients.obj-type
                     ,buf_clients.obj-code
                     ,buf_trn-doc.doc-code
                     )
              ) .
          end.
        end.
      end.
    end.
    if v-return-error = true then do:
      return error .
    end.
  end.
end procedure.
procedure log-error :
  define input  parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    output stream slog to value('del-obj.err') append .
    export stream slog v-obj-type v-obj-code cur-time-string() p-message .
    output stream slog close .
  end.
end procedure.
procedure generate-check-string :
  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define output parameter p-check-string as character no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    define buffer buf_db       for ub.db .
    find first buf_sys-ctrl no-lock .
    find first buf_db no-lock
      where buf_db.db-num = buf_sys-ctrl.db-num .
    assign
      p-check-string =
        substitute('del-obj,&1,&2,&3,&4,&5':u
          ,p-obj-type
          ,p-obj-code
          ,p-check-rest
          ,cur-time-date()
          ,buf_sys-ctrl.db-num
        )
    .
  end.
end procedure.
