block-level on error undo, throw.
define input  parameter p-obj-type          as character no-undo .
define input  parameter p-obj-code          as integer   no-undo .
define input  parameter p-check-doc         as logical   no-undo .
define input  parameter p-message-on        as logical   no-undo .
define input  parameter p-last-fact-date    as date      no-undo .
define input  parameter p-check-act         as logical   no-undo .
define input  parameter p-check-act-db-num  as integer   no-undo .
define input  parameter p-check-act-user-id as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 4428eb1bbf45, 349, rls $":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 17 17:50:10 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: calcarh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: trg/calcarh.p $":U .
define variable vss-description as character no-undo init "Расчет складского архива по товарам".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4',p-obj-type,p-obj-code,p-message-on,p-check-doc,p-last-fact-date)
    .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream slog .
do
on error undo, return error return-value
:
  define variable v-today as date      no-undo .
  define variable v-action as character no-undo .
  def frame a
    "Объект" p-obj-type no-label p-obj-code no-label skip
    v-action format "x(50)" no-label skip
    with view-as dialog-box side-labels three-d
    title "Расчет складского архива по товарам"
    .
  if not session:batch-mode then
    view frame a .
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
    ,input p-message-on
    ,buffer calc-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    if p-message-on = true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "В данный момент рассчитывается складской архив по товарам" skip
        "Невозможно произвести расчет складского архива по товарам" skip
        view-as alert-box error .
    end.
    undo, return error "Складской архив по товарам рассчитывается" .
  end.
  run log-information in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input "start"
    ) .
  run cb-doclslib-log in this-procedure
    (input substitute("Начало расчёта складского архива по товарам. Проверять документы &1. Сообщения &2. Дата перерасчёта &3"
                     ,p-check-doc
                     ,p-message-on
                     ,string(p-last-fact-date, '99/99/9999':U)
                     )
    ) .
  define variable v-archive-exist as logical no-undo .
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define variable v-arh-del as logical   no-undo .
  run clntattr-value in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,input  'arh-del':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  assign
    v-arh-del = (lookup(v-attr-value, 'yes,true') > 0)
  .
  if v-arh-del = true
  then do:
    if p-message-on = true
    then do:
      run cb-doclslib-log in this-procedure
        (input "На объекте отсутствуют рассчитанные остатки"
        ) .
      message
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "На объекте отсутствуют рассчитанные остатки" skip
        "Расчет складского архива по товарам невозможен" skip
        view-as alert-box error .
    end.
    undo, return error "Отсутствуют остатки" .
  end.
  run clntattr-value in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,input  'arh-detail':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  define variable v-arh-detail-date       as date    no-undo .
  define variable v-arh-detail-fact-order as decimal no-undo .
  assign
    v-arh-detail-date = date(v-attr-value)
  .
  if not session:batch-mode then
  display
    p-obj-type p-obj-code
    with frame a.
  define variable v-last-fact-date  as date    no-undo .
  if p-check-doc = false
  then do:
    if p-last-fact-date = ?
    then do:
      if p-message-on = true
      then do:
        run cb-doclslib-log in this-procedure
          (input "Ошибка задания входных параметров. Не задана дата перерасчёта"
          ) .
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не задана дата перерасчета" skip
          "Складской архив по товарам" skip
          "Объект" p-obj-type p-obj-code skip
          "Проверять наличие документов" p-check-doc skip
          "Выводить сообщение" p-message-on skip
          "Дата перерасчета" p-last-fact-date skip
          view-as alert-box error .
      end.
      undo, return error "Не задана дата перерасчета складского архива" .
    end.
    else do:
      assign
        v-last-fact-date = p-last-fact-date
      .
    end.
  end.
  else do:
    run show-action in this-procedure
      (input "Составление списка документов"
      ) .
    run day-begin-fact-order in this-procedure
      (input  v-arh-detail-date
      ,output v-arh-detail-fact-order
      ).
    run doclslib-check-arh-exist in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  v-arh-detail-fact-order
      ,output v-archive-exist
      ).
    run doclslib-clear-doc-list in this-procedure .
    run doclslib-init-trn-doc in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input v-arh-detail-date
      ) no-error .
    if error-status :error
    then do:
         if p-message-on = true
      then do:
          message
            vss-workfile vss-revision vss-description skip
            "Складской архив по товарам" skip
            "Объект" p-obj-type p-obj-code skip
            "Ошибка при вызове процедуры doclslib-init-trn-doc" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
      undo, return error return-value .
    end.
    run doclslib-init-price-doc in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input v-arh-detail-date
      ) no-error .
    if error-status :error
    then do:
         if p-message-on = true
      then do:
      message
        vss-workfile vss-revision vss-description skip
        "Складской архив по товарам" skip
        "Объект" p-obj-type p-obj-code skip
        "Ошибка при вызове процедуры doclslib-init-price-doc" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
        end.
      undo, return error return-value .
    end.
    if v-archive-exist = true
    then do:
      run doclslib-check-doc-arh-exist in this-procedure
        .
      define variable v-last-fact-date-reason as character no-undo .
      run doclslib-find-last-fact-date in this-procedure
        (output v-last-fact-date
        ,output v-last-fact-date-reason
        ) .
      define variable v-arh-recalc      as character no-undo .
      define variable v-arh-recalc-date as date      no-undo .
      run clntattr-value in this-procedure
        (input  p-obj-type
        ,input  p-obj-code
        ,input  'arh-recalc':U
        ,output v-arh-recalc
        ,output v-attr-type
        ) .
      assign
        v-arh-recalc-date = date(v-arh-recalc)
      .
      if  v-arh-recalc-date <> ?
      then do:
        if v-last-fact-date = ?
        or (v-last-fact-date <> ?
            and
            v-last-fact-date > v-arh-recalc-date
           )
        then do:
          assign
            v-last-fact-date        = v-arh-recalc-date
            v-last-fact-date-reason = "Складской архив по товарам требует перерасчета из-за удаления или закрытия документа задним числом"
          .
        end.
      end.
      if  v-arh-detail-date <> ?
      and v-last-fact-date  <> ?
      and v-last-fact-date  < v-arh-detail-date
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по товарам" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата последнего рассчитанного документа" skip
          "не может быть меньше чем дата начала подробного складского архива по товарам" skip
          "Дата последнего рассчитанного документа" v-last-fact-date skip
          "Дата начала подробного складского архива по товарам" v-arh-detail-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      if p-message-on = true
      then do:
        define variable v-num as integer   no-undo .
        run gbl/d-askw.w
          (input "Вопрос"
          ,input "На объекте уже есть рассчитанный складской архив по товарам" + chr(10)
              + substitute("Объект &1 &2", p-obj-type, p-obj-code) + chr(10)
          ,input "|^"
          ,input "С последней" + (if v-last-fact-date = ? then "^disable" else "") + "|"
              + "С выбранной|Весь архив^confirm|Отмена"
          ,input "Пересчитать складской архив по товарам начиная с даты " +
                  (if v-last-fact-date <> ? then string(v-last-fact-date, '99/99/9999':u)
                                                  + chr(10) + v-last-fact-date-reason
                    else "?"
                  ) + "|"
              + "Выбрать дату и пересчитать складской архив по товарам начиная с выбранной даты" + "|"
              + "Удалить весь складской архив по товарам и рассчитать его на основе документов" + chr(10)
              + (if v-arh-detail-date <> ?
                then "Будут рассмотрены документы с даты " + string(v-arh-detail-date, '99/99/9999')
                else ""
                )
              + "|"
              + "Отказаться от расчета складского архива по товарам"
          ,input 1
          ,input 4
          ,output v-num
          ).
        case v-num :
          when 1
          then do:
            run cb-doclslib-log in this-procedure
              (input substitute("Выбор пользователя 1. Пересчитать с последней даты &1"
                               ,string(v-last-fact-date, '99/99/9999':u)
                               )
              ) .
          end.
          when 2
          then do:
            update-block:
            do while true
            :
              if v-arh-recalc-date <> ?
              then do:
                assign
                  v-today = v-arh-recalc-date
                .
              end.
              else do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-today
  )  .
              end.
              define variable v-string-last-fact-date as character no-undo .
              assign
                v-string-last-fact-date = string(v-today, '99/99/9999':u)
              .
              run gbl/d-prompt.w
                ( 'title=':u + "Введите дату" + '\':u
                + 'text1=':u + "Введите дату, начиная с которой надо рассчитать" + '\':u
                + 'text2=':u + "складской архив по товарам" + '\':u
                + 'type=date\':u
                ,input-output v-string-last-fact-date
                ).
              if return-value = 'false':u
              then do:
                undo, return error return-value .
              end.
              assign
                v-last-fact-date = date(v-string-last-fact-date)
              .
              if  v-last-fact-date = ?
              then do:
                message
                  "Складской архив по товарам" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Вы не задали дату"
                  view-as alert-box information .
                next update-block .
              end.
              if  v-arh-recalc-date <> ?
              and v-last-fact-date   > v-arh-recalc-date
              then do:
                message
                  "Складской архив по товарам" skip
                  "Объект" p-obj-type p-obj-code skip
                  "На объекте требуется перерасчет складского архива по товарам с указанной даты" skip
                  "Введенная дата не может быть больше даты" v-arh-recalc-date skip
                  "Вы ввели дату" v-last-fact-date skip
                  view-as alert-box information .
                next update-block .
              end.
              if  v-arh-detail-date <> ?
              and v-last-fact-date  <> ?
              and v-last-fact-date  < v-arh-detail-date
              then do:
                message
                  "Складской архив по товарам" skip
                  "Объект" p-obj-type p-obj-code skip
                  "Введенная дата не может быть меньше даты" v-arh-detail-date skip
                  "Вы ввели дату" v-last-fact-date skip
                  view-as alert-box information .
                next update-block .
              end.
              leave update-block .
            end.
            run cb-doclslib-log in this-procedure
              (input substitute("Выбор пользователя 2. Пересчитать с даты &1"
                               ,string(v-last-fact-date, '99/99/9999':u)
                               )
              ) .
          end.
          when 3
          then do:
            assign
              v-last-fact-date = v-arh-detail-date
            .
            run cb-doclslib-log in this-procedure
              (input substitute("Выбор пользователя 3. Пересчитать весь архив &1"
                               ,string(v-last-fact-date, '99/99/9999':u)
                               )
              ) .
          end.
          when 4
          then do:
            run cb-doclslib-log in this-procedure
              (input "Выбор пользователя 4. Отказ от расчёта архива"
              ) .
            undo, return error return-value .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              "Складской архив по товарам" skip
              "Объект" p-obj-type p-obj-code skip
              "Неизвестное значение v-num" v-num skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end case .
      end.
    end.
    else do:
      assign
        v-last-fact-date = v-arh-detail-date
      .
    end.
    if v-last-fact-date <> ?
    then do:
      if  p-last-fact-date = ?
      and p-message-on     = true
      then do:
        define variable lok as logical no-undo .
        assign
          lok = false
        .
        message
          "Складской архив по товарам" skip
          "Объект" p-obj-type p-obj-code skip
          "Частичный расчет складского архива по товарам" skip
          "Складской архив по товарам за дату" string(v-last-fact-date, '99/99/9999':u) "и за более поздние даты будет удален" skip
          "и рассчитан на основании документов" skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update lok .
        if lok <> true
        then do:
          undo, return error return-value .
        end.
      end.
    end.
  end.
  run cb-doclslib-log in this-procedure
    (input "Перерасчёт переоценок"
    ) .
  run show-action in this-procedure
    (input "Перерасчет переоценок"
    ) .
  run trg/bt_prc.p
    (input p-obj-type
    ,input p-obj-code
    ,input p-check-act
    ,input p-check-act-db-num
    ,input p-check-act-user-id
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> "" and p-message-on = true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при перасчете переоценок" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
  define variable v-create-chip-num as integer   no-undo .
  run utl/arhiscr.p
    (input  p-obj-type
    ,input  p-obj-code
    ,input  'arh':U
    ,input  'calc-start':U
    ,input  ""
    ,input  ""
    ,input  0
    ,input  ""
    ,input  ""
    ,input  v-last-fact-date
    ,output v-create-chip-num
    ) .
  run cb-doclslib-log in this-procedure
    (input substitute("Начало перерасчёта с даты &1"
                     ,string(v-last-fact-date, '99/99/9999':u)
                     )
    ) .
  define variable v-last-fact-order as decimal no-undo .
  run day-begin-fact-order in this-procedure
    (input  v-last-fact-date
    ,output v-last-fact-order
    ).
  run show-action in this-procedure
    (input "Составление списка документов"
    ) .
  run doclslib-clear-doc-list in this-procedure .
  run doclslib-init-trn-doc in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input v-last-fact-date
    ) no-error .
  if error-status :error
  then do:
       if p-message-on = true
      then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по товарам" skip
      "Объект" p-obj-type p-obj-code skip
      "Ошибка при вызове процедуры doclslib-init-trn-doc" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      end.
    undo, return error return-value .
  end.
  run doclslib-init-price-doc in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input v-last-fact-date
    ) no-error .
  if error-status :error
  then do:
       if p-message-on = true
      then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по товарам" skip
      "Объект" p-obj-type p-obj-code skip
      "Ошибка при вызове процедуры doclslib-init-price-doc" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      end.
    undo, return error return-value .
  end.
  if v-last-fact-date <> ?
  then do:
    run clntattr-write in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input 'arh-recalc':U
      ,input string(v-last-fact-date, '99/99/9999':U)
      ) .
    run cb-doclslib-log in this-procedure
      (input substitute("Устанавливается дата перерасчёта &1"
                      ,string(v-last-fact-date, '99/99/9999':U)
                      )
      ) .
  end.
  else do:
    run clntattr-write in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input 'arh-calc':U
      ,input string(true)
      ) .
    run cb-doclslib-log in this-procedure
      (input substitute("Архив помечается, как требующей расчета")
      ) .
    define variable v-attr-deleted as logical   no-undo .
    run clntattr-delete in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'arh-recalc':U
      ,output v-attr-deleted
      ) .
    if v-attr-deleted = true
    then do:
      run cb-doclslib-log in this-procedure
        (input "Удалена дата перерасчёта"
        ) .
    end.
  end.
  run show-action in this-procedure
    (input "Очистка складского архива по товарам"
    ) .
  run cb-doclslib-log in this-procedure
    (input substitute("Очистка архива по товарам начиная с номера &1"
                     ,v-last-fact-order
                     )
    ) .
  run trg/arhclr.p
    (input p-obj-type
    ,input p-obj-code
    ,input v-last-fact-order
    ,input 0
    ,input ""
    ) no-error .
  if error-status :error
  then do:
       if p-message-on = true
      then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по товарам" skip
      "Объект" p-obj-type p-obj-code skip
      "Ошибка при вызове процедуры clear-archives" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      end.
    undo, return error return-value .
  end.
  run show-action in this-procedure
    (input "Очистка отложенных заданий"
    ) .
  run doclslib-clear-batch-process in this-procedure
    (input 'arh':U
    ) no-error .
  if error-status :error
  then do:
       if p-message-on = true
      then do:
    message
      vss-workfile vss-revision vss-description skip
      "Складской архив по товарам" skip
      "Объект" p-obj-type p-obj-code skip
      "Ошибка при вызове процедуры clear-batch-process" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      end.
    undo, return error return-value .
  end.
  run doclslib-export-doc-list in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input substitute('calcarh_&1_&2_doc_list.txt', p-obj-type, p-obj-code)
    ,input "Расчет складского архива по товарам"
    ) .
  run show-action in this-procedure
    (input "Расчет складского архива по товарам"
    ) .
  run doclslib-calc-arh in this-procedure
    (input this-procedure
    ,input p-obj-type
    ,input p-obj-code
    ,input ?
    ,input true
    ) no-error .
  if error-status :error
  then do:
     if p-message-on = true
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Складской архив по товарам" skip
          "Объект" p-obj-type p-obj-code skip
          "Ошибка при вызове процедуры doclslib-calc-arh" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
    undo, return error return-value .
  end.
  run clntattr-delete in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,input  'arh-calc':U
    ,output v-attr-deleted
    ) .
  if v-attr-deleted = true
  then do:
    run cb-doclslib-log in this-procedure
      (input "Удалён признак необходимости перерасчёта"
      ) .
  end.
  run clntattr-delete in this-procedure
    (input  p-obj-type
    ,input  p-obj-code
    ,input  'arh-recalc':U
    ,output v-attr-deleted
    ) .
  if v-attr-deleted = true
  then do:
    run cb-doclslib-log in this-procedure
      (input "Удалена дата перерасчёта"
      ) .
  end.
  run cb-doclslib-log in this-procedure
    (input substitute("Окончание перерасчёта архива с даты &1"
                     ,string(v-last-fact-date, '99/99/9999':u)
                     )
    ) .
  run show-action in this-procedure
    (input "Расчет складского архива по товарам закончен"
    ) .
  run log-information in this-procedure
    (input p-obj-type
    ,input p-obj-code
    ,input "stop"
    ) .
  run utl/arhiscr.p
    (input  p-obj-type
    ,input  p-obj-code
    ,input  'arh':U
    ,input  'calc-stop':U
    ,input  ""
    ,input  ""
    ,input  0
    ,input  ""
    ,input  ""
    ,input  v-last-fact-date
    ,output v-create-chip-num
    ) .
end.
procedure cb-doclslib-log :
  define input parameter p-message  as character no-undo .
  define variable v-log-file-name as character no-undo .
  assign
    v-log-file-name = substitute("calcarh_&1_&2.txt", p-obj-type, p-obj-code)
  .
  do
  on error undo, return error return-value
  :
    output stream slog to value(v-log-file-name) append .
    export stream slog
      p-obj-type
      p-obj-code
      cur-time-string-sec()
      p-message .
    output stream slog close .
  end.
end procedure.
procedure show-action :
  define input parameter p-message  as character no-undo .
  if session:batch-mode then return.
  do
  on error undo, return error return-value
  :
    assign
      v-action = p-message
    .
    display
      v-action with frame a .
  end.
end procedure.
procedure log-information :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-message  as character no-undo .
  do
  on error undo, return error return-value
  :
    output stream slog to objarh.log append .
    export stream slog
      p-obj-type
      p-obj-code
      cur-time-string()
      p-message .
    output stream slog close .
  end.
end procedure.
