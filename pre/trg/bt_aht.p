block-level on error undo, throw.
define input  parameter p-obj-type          as character no-undo .
define input  parameter p-obj-code          as integer   no-undo .
define input  parameter p-last-date         as date      no-undo .
define input  parameter p-check-act         as logical   no-undo .
define input  parameter p-check-act-db-num  as integer   no-undo .
define input  parameter p-check-act-user-id as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Расчет складского архива по типам приобретения".
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
      p-vss-parameters = substitute('&1|&2|&3|&4',p-obj-type,p-obj-code,p-last-date,p-check-act)
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-ro_get-read-only :
  define output parameter p-ro-set as logical   no-undo .
  do
  on error  undo, return error substitute( "&1(get-ro_get-read-only). &2&3&4", vss-include-info3, return-value, error-status :get-message( 1 ) )
  on stop   undo, return error substitute( "&1(get-ro_get-read-only). stop", vss-include-info3 )
  on endkey undo, return error substitute( "&1(get-ro_get-read-only). endkey", vss-include-info3 )
  :
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ub':U) ) > 0
    then do:
      assign
        p-ro-set = true
      .
    end.
    else do:
      assign
        p-ro-set = false
      .
    end.
  end.
end procedure.
define stream slog .
define temp-table doc-list no-undo    field doc-code   like ub.trn-doc.doc-code     field fact-date  like ub.trn-doc.fact-date    field fact-order like ub.trn-doc.fact-order   field obj-type   like ub.trn-doc.obj-type     field obj-code   like ub.trn-doc.obj-code     field is-trn-doc as logical                   field batchprocess_rowid as rowid             index xpk is primary unique doc-code          index xfact obj-type obj-code fact-order   index xdate fact-date  .
define variable v-was-processing as logical   no-undo init false .
define variable v-get-ro_read-only as logical   no-undo .
main-block:
do
on error undo main-block, return error return-value
:
  run get-ro_get-read-only in this-procedure
    (output v-get-ro_read-only
    ) .
  if  p-obj-type = ""
  and p-obj-code = 0
  then do:
    for each ub.db no-lock
    ,each ub.clients no-lock
      where ub.clients.db-num = ub.db.db-num
    on error undo, return error return-value
    :
      run waitfram-show in this-procedure
        (input substitute("Расчет складского архива по типам приобретения. Объект &1 &2"
                         ,ub.clients.obj-type
                         ,ub.clients.obj-code
                         )
        ) .
      run process-object in this-procedure
        (input ub.clients.obj-type
        ,input ub.clients.obj-code
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры process-object" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
      end.
    end.
  end.
  else do:
    find first ub.clients no-lock
      where ub.clients.obj-type = p-obj-type
        and ub.clients.obj-code = p-obj-code
      no-error .
    if not available ub.clients
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный объект" p-obj-type p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run waitfram-show in this-procedure
      (input substitute("Расчет складского архива по типам приобретения. Объект &1 &2"
                        ,ub.clients.obj-type
                        ,ub.clients.obj-code
                        )
      ) .
    run process-object in this-procedure
      (input ub.clients.obj-type
      ,input ub.clients.obj-code
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры process-object" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value .
    end.
  end.
  run waitfram-hide in this-procedure .
  if v-was-processing
  then do:
    return "true":u .
  end.
  else do:
    return "":u .
  end.
end.
procedure process-object :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
  define variable v-aht-calc-char    as character no-undo .
  define variable v-aht-del-char     as character no-undo .
  define variable v-aht-disable-char as character no-undo .
  define variable v-aht-calc         as logical   no-undo .
  define variable v-aht-del          as logical   no-undo .
  define variable v-aht-disable      as logical   no-undo .
  define variable v-aht-recalc-char  as character no-undo .
  define variable v-aht-recalc       as date      no-undo .
  define variable v-attr-type        as character no-undo .
  define buffer buf_batchprocess for ub.batchprocess .
  define buffer calc-aht-lock_batchprocess for ub.batchprocess .
  define buffer stop-aht-restore-lock_btpr for ub.batchprocess .
  define buffer stop-aht-news-lock_btpr    for ub.batchprocess .
  do
  on error undo, return error return-value
  :
    if v-get-ro_read-only = false
    then do:
      run gbl/lock-prc.p
        (input  'ahtb':U
        ,input  p-obj-code
        ,input  0
        ,input  0
        ,input  p-obj-type
        ,input  ""
        ,input  ""
        ,input  "Объект,,, ,,,Расчет складского архива по типам приобретения"
        ,input  false
        ,buffer calc-aht-lock_batchprocess
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при попытке заблокировать ресурс" skip
            "Невозможно произвести расчет складского архива по типам приобретения" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error substitute("&1: Ошибка при попытке заблокировать ресурс &2"
                                       ,vss-workfile
                                       ,error-status :get-message(1)
                                       ).
        end.
        undo, return error "В данный момент рассчитывается складской архив по типам приобретения" .
      end.
    end.
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'aht-calc':U
      ,output v-aht-calc-char
      ,output v-attr-type
      ) .
    assign
      v-aht-calc = (lookup(v-aht-calc-char, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'aht-del':U
      ,output v-aht-del-char
      ,output v-attr-type
      ) .
    assign
      v-aht-del = (lookup(v-aht-del-char, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'aht-disable':U
      ,output v-aht-disable-char
      ,output v-attr-type
      ) .
    assign
      v-aht-disable = (lookup(v-aht-disable-char, 'yes,true') > 0)
    .
    run clntattr-value in this-procedure
      (input  p-obj-type
      ,input  p-obj-code
      ,input  'aht-recalc':U
      ,output v-aht-recalc-char
      ,output v-attr-type
      ) .
    assign
      v-aht-recalc = date(v-aht-recalc-char)
    .
    if v-aht-del  = true
    then do:
      if v-get-ro_read-only = false
      then do:
        for each BatchProcess exclusive-lock
          where BatchProcess.bp_type       = 'aht':U
            and BatchProcess.bp_status     = 'N':U
            and BatchProcess.CharKey_Three = p-obj-type
            and BatchProcess.Key#_One      = p-obj-code
        on error undo, return error return-value
        :
  find first buf_batchprocess exclusive-lock
    where rowid(buf_batchprocess) = rowid(BatchProcess)
    no-error .
  if not available buf_batchprocess then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись пересчета архива" skip
      view-as alert-box error .
    undo, return error .
  end.
  if buf_batchprocess.bp_status <> 'N':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запись пересчета архива имеет статус, отличный от" 'N':U skip
      "BP_Type"       buf_batchprocess.BP_Type       skip
      "BP_Status"     buf_batchprocess.BP_Status     skip
      "Key#_One"      buf_batchprocess.Key#_One      skip
      "Key#_Two"      buf_batchprocess.Key#_Two      skip
      "Key#_Three"    buf_batchprocess.Key#_Three    skip
      "CharKey_One"   buf_batchprocess.CharKey_One   skip
      "CharKey_Two"   buf_batchprocess.CharKey_Two   skip
      "CharKey_Three" buf_batchprocess.CharKey_Three skip
      view-as alert-box error .
    undo, return error .
  end.
    define variable v-btpr_upd-today-4 as date      no-undo.
  define variable v-btpr_upd-time-4  as integer   no-undo.
  run cur-time in this-procedure ( output v-btpr_upd-today-4
                                 , output v-btpr_upd-time-4
                                 ).
  assign
    buf_batchprocess.bp_status         = 'D':U
    buf_batchprocess.bp_execcounttries = buf_batchprocess.bp_execcounttries + 1
    buf_batchprocess.bp_execuser_id    = g#userid
    buf_batchprocess.bp_execsysdate    = v-btpr_upd-today-4
    buf_batchprocess.bp_execsystime    = string(v-btpr_upd-time-4, 'hh:mm')
    buf_batchprocess.bp_execsystimeint = v-btpr_upd-time-4
  .
        end.
      end.
      if v-aht-disable = true
      then do:
        undo, return error substitute("Складской архив по типам приобретения. Объект &1 &2. Расчет архива запрещен"
                          ,p-obj-type
                          ,p-obj-code
                          )
          .
      end.
      else do:
        undo, return error substitute("Складской архив по типам приобретения. Объект &1 &2. Отсутствуют начальные остатки"
                          ,p-obj-type
                          ,p-obj-code
                          )
          .
      end.
    end.
    if v-aht-calc = true
    then do:
      undo, return error substitute("Складской архив по типам приобретения. Объект &1 &2. Архив требует расчета"
                         ,p-obj-type
                         ,p-obj-code
                         )
        .
    end.
    run trg/bt_prc.p
      (input p-obj-type
      ,input p-obj-code
      ,input p-check-act
      ,input p-check-act-db-num
      ,input p-check-act-user-id
      ) no-error .
    if error-status :error
    then do:
      if error-status :get-message(1) <> ""
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при перасчете переоценок" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return error return-value  .
    end.
    if v-aht-recalc <> ?
    then do:
      if p-check-act = true
      then do:
        define variable v-ok as logical   no-undo .
        define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-check-act-db-num
    ,input  p-check-act-user-id
    ,input  0
    ,input  'actn_archive-aht_update':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
        if v-ok <> true
        then do:
          undo, return error substitute("Требуется автоматический перерасчёт складского архива по типам приобретения. Отсутствуют права на расчет складского архива по типам приобретения. &1"
                                       ,return-value
                                       ) .
        end.
      end.
      if v-get-ro_read-only = false
      then do:
        run trg/calcaht.p
          (input p-obj-type
          ,input p-obj-code
          ,input false
          ,input false
          ,input v-aht-recalc
          ,input p-check-act
          ,input p-check-act-db-num
          ,input p-check-act-user-id
          ) no-error .
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при перерасчете складского архива по типам приобретения" skip
              "Объект" p-obj-type p-obj-code skip
              "Дата перерасчета" v-aht-recalc skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
          end.
          undo, return error return-value .
        end.
      end.
      else do:
        undo, return error substitute("Складской архив по типам приобретения. Объект &1 &2. &3"
                          ,p-obj-type
                          ,p-obj-code
                          ,"Требуется перерасчет. Перерасчет невозможно выполнить так как база находится в режиме только на чтение"
                          ) .
      end.
    end.
    for each doc-list
    :
      delete doc-list .
    end.
    for each BatchProcess exclusive-lock
      where BatchProcess.bp_type       = 'aht':U
        and BatchProcess.bp_status     = 'N':U
        and BatchProcess.CharKey_Three = p-obj-type
        and BatchProcess.Key#_One      = p-obj-code
    on error undo, return error return-value
    :
      case batchprocess.charkey_two :
        when 'trn-doc':U
        then do:
          find first ub.trn-doc no-lock
            where ub.trn-doc.doc-code = batchprocess.charkey_one
            no-error .
          if available ub.trn-doc
          then do:
            if  ub.trn-doc.obj-type = p-obj-type
            and ub.trn-doc.obj-code = p-obj-code
            then do:
              find first doc-list
                where doc-list.doc-code = ub.trn-doc.doc-code
                no-error .
              if not available doc-list
              then do:
                create doc-list .
                assign
                  doc-list.batchprocess_rowid = rowid(batchprocess)
                .
                assign
                  doc-list.doc-code   = ub.trn-doc.doc-code
                  doc-list.fact-order = ub.trn-doc.fact-order
                  doc-list.fact-date  = ub.trn-doc.fact-date
                  doc-list.obj-type   = ub.trn-doc.obj-type
                  doc-list.obj-code   = ub.trn-doc.obj-code
                  doc-list.is-trn-doc = true
                .
              end.
            end.
          end.
          else do:
            if v-get-ro_read-only = false
            then do:
  find first buf_batchprocess exclusive-lock
    where rowid(buf_batchprocess) = rowid(BatchProcess)
    no-error .
  if not available buf_batchprocess then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись пересчета архива" skip
      view-as alert-box error .
    undo, return error .
  end.
  if buf_batchprocess.bp_status <> 'N':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запись пересчета архива имеет статус, отличный от" 'N':U skip
      "BP_Type"       buf_batchprocess.BP_Type       skip
      "BP_Status"     buf_batchprocess.BP_Status     skip
      "Key#_One"      buf_batchprocess.Key#_One      skip
      "Key#_Two"      buf_batchprocess.Key#_Two      skip
      "Key#_Three"    buf_batchprocess.Key#_Three    skip
      "CharKey_One"   buf_batchprocess.CharKey_One   skip
      "CharKey_Two"   buf_batchprocess.CharKey_Two   skip
      "CharKey_Three" buf_batchprocess.CharKey_Three skip
      view-as alert-box error .
    undo, return error .
  end.
    define variable v-btpr_upd-today-7 as date      no-undo.
  define variable v-btpr_upd-time-7  as integer   no-undo.
  run cur-time in this-procedure ( output v-btpr_upd-today-7
                                 , output v-btpr_upd-time-7
                                 ).
  assign
    buf_batchprocess.bp_status         = 'D':U
    buf_batchprocess.bp_execcounttries = buf_batchprocess.bp_execcounttries + 1
    buf_batchprocess.bp_execuser_id    = g#userid
    buf_batchprocess.bp_execsysdate    = v-btpr_upd-today-7
    buf_batchprocess.bp_execsystime    = string(v-btpr_upd-time-7, 'hh:mm')
    buf_batchprocess.bp_execsystimeint = v-btpr_upd-time-7
  .
            end.
          end.
        end.
        when 'price-doc':U
        then do:
          find first ub.price-doc no-lock
            where ub.price-doc.doc-num = batchprocess.charkey_one
            no-error .
          if available ub.price-doc
          then do:
            if  ub.price-doc.obj-type = p-obj-type
            and ub.price-doc.obj-code = p-obj-code
            then do:
              find first doc-list
                where doc-list.doc-code = ub.price-doc.doc-num
                no-error .
              if not available doc-list
              then do:
                create doc-list .
                assign
                  doc-list.batchprocess_rowid = rowid(batchprocess)
                .
                assign
                  doc-list.doc-code   = ub.price-doc.doc-num
                  doc-list.fact-order = ub.price-doc.fact-order
                  doc-list.fact-date  = ub.price-doc.fact-date
                  doc-list.obj-type   = ub.price-doc.obj-type
                  doc-list.obj-code   = ub.price-doc.obj-code
                  doc-list.is-trn-doc = false
                .
              end.
            end.
          end.
          else do:
            if v-get-ro_read-only = false
            then do:
  find first buf_batchprocess exclusive-lock
    where rowid(buf_batchprocess) = rowid(BatchProcess)
    no-error .
  if not available buf_batchprocess then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись пересчета архива" skip
      view-as alert-box error .
    undo, return error .
  end.
  if buf_batchprocess.bp_status <> 'N':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запись пересчета архива имеет статус, отличный от" 'N':U skip
      "BP_Type"       buf_batchprocess.BP_Type       skip
      "BP_Status"     buf_batchprocess.BP_Status     skip
      "Key#_One"      buf_batchprocess.Key#_One      skip
      "Key#_Two"      buf_batchprocess.Key#_Two      skip
      "Key#_Three"    buf_batchprocess.Key#_Three    skip
      "CharKey_One"   buf_batchprocess.CharKey_One   skip
      "CharKey_Two"   buf_batchprocess.CharKey_Two   skip
      "CharKey_Three" buf_batchprocess.CharKey_Three skip
      view-as alert-box error .
    undo, return error .
  end.
    define variable v-btpr_upd-today-8 as date      no-undo.
  define variable v-btpr_upd-time-8  as integer   no-undo.
  run cur-time in this-procedure ( output v-btpr_upd-today-8
                                 , output v-btpr_upd-time-8
                                 ).
  assign
    buf_batchprocess.bp_status         = 'D':U
    buf_batchprocess.bp_execcounttries = buf_batchprocess.bp_execcounttries + 1
    buf_batchprocess.bp_execuser_id    = g#userid
    buf_batchprocess.bp_execsysdate    = v-btpr_upd-today-8
    buf_batchprocess.bp_execsystime    = string(v-btpr_upd-time-8, 'hh:mm')
    buf_batchprocess.bp_execsystimeint = v-btpr_upd-time-8
  .
            end.
          end.
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип таблицы" skip
            "charkey_one"  batchprocess.charkey_one skip
            "charkey_two"  batchprocess.charkey_two skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case .
    end.
    if p-last-date <> ?
    then do:
      find first doc-list no-lock
        where doc-list.fact-date <= p-last-date
        no-error .
      if not available doc-list
      then do:
        return .
      end.
    end.
    if p-check-act = true
    then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  p-check-act-db-num
    ,input  p-check-act-user-id
    ,input  0
    ,input  'actn_archive-aht_update':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
      if v-ok <> true
      then do:
        undo, return error substitute("Отсутствуют права на расчет складского архива по типам приобретения. &1"
                                     ,return-value
                                     ) .
      end.
    end.
    if v-get-ro_read-only = true
    then do:
      undo, return error "Имеются нерассчитанные документы. Невозможно произвести расчёт документов в режиме подключения к базе только_на_чтение." .
    end.
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
    for each doc-list
    by doc-list.obj-type
    by doc-list.obj-code
    by doc-list.fact-order
    on error undo, return error return-value
    :
      find first stop-aht-restore-lock_btpr no-lock
        where stop-aht-restore-lock_btpr.bp_type       = 'lock':U + 'rsts':U
          and stop-aht-restore-lock_btpr.bp_status     = 'N':U
          and stop-aht-restore-lock_btpr.Key#_One      = doc-list.obj-code
          and stop-aht-restore-lock_btpr.Key#_Two      = 0
          and stop-aht-restore-lock_btpr.Key#_Three    = 0
          and stop-aht-restore-lock_btpr.CharKey_One   = doc-list.obj-type
          and stop-aht-restore-lock_btpr.CharKey_Two   = ""
          and stop-aht-restore-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-aht-restore-lock_btpr
      then do:
        undo, return error "Процедура восстановления складского архива запросила остановку автоматического расчета складского архива" .
      end.
      find first stop-aht-news-lock_btpr no-lock
        where stop-aht-news-lock_btpr.bp_type       = 'lock':U + 'rstn':U
          and stop-aht-news-lock_btpr.bp_status     = 'N':U
          and stop-aht-news-lock_btpr.Key#_One      = doc-list.obj-code
          and stop-aht-news-lock_btpr.Key#_Two      = 0
          and stop-aht-news-lock_btpr.Key#_Three    = 0
          and stop-aht-news-lock_btpr.CharKey_One   = doc-list.obj-type
          and stop-aht-news-lock_btpr.CharKey_Three = ""
        no-error .
      if available stop-aht-news-lock_btpr
      then do:
        undo, return error "Система новостей запросила остановку автоматического расчета складского архива" .
      end.
      output stream slog to objaht.txt append .
      export stream slog doc-list except doc-list.batchprocess_rowid .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export stream slog string(v-today, "99/99/9999") string(v-time, "hh:mm") .
      output stream slog close .
      assign
        v-was-processing = true
      .
      do transaction
      on error undo, return error return-value
      :
  find first buf_batchprocess exclusive-lock
    where rowid(buf_batchprocess) = doc-list.batchprocess_rowid
    no-error .
  if not available buf_batchprocess then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись пересчета архива" skip
      view-as alert-box error .
    undo, return error .
  end.
  if buf_batchprocess.bp_status <> 'N':U then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запись пересчета архива имеет статус, отличный от" 'N':U skip
      "BP_Type"       buf_batchprocess.BP_Type       skip
      "BP_Status"     buf_batchprocess.BP_Status     skip
      "Key#_One"      buf_batchprocess.Key#_One      skip
      "Key#_Two"      buf_batchprocess.Key#_Two      skip
      "Key#_Three"    buf_batchprocess.Key#_Three    skip
      "CharKey_One"   buf_batchprocess.CharKey_One   skip
      "CharKey_Two"   buf_batchprocess.CharKey_Two   skip
      "CharKey_Three" buf_batchprocess.CharKey_Three skip
      view-as alert-box error .
    undo, return error .
  end.
    define variable v-btpr_upd-today-11 as date      no-undo.
  define variable v-btpr_upd-time-11  as integer   no-undo.
  run cur-time in this-procedure ( output v-btpr_upd-today-11
                                 , output v-btpr_upd-time-11
                                 ).
  assign
    buf_batchprocess.bp_status         = 'D':U
    buf_batchprocess.bp_execcounttries = buf_batchprocess.bp_execcounttries + 1
    buf_batchprocess.bp_execuser_id    = g#userid
    buf_batchprocess.bp_execsysdate    = v-btpr_upd-today-11
    buf_batchprocess.bp_execsystime    = string(v-btpr_upd-time-11, 'hh:mm')
    buf_batchprocess.bp_execsystimeint = v-btpr_upd-time-11
  .
        if doc-list.is-trn-doc
        then do:
          run trg/aht-doc.p
            (input doc-list.doc-code
            ,input ?
            ).
        end.
        else do:
          run trg/aht-prc.p
            (input doc-list.doc-code
            ,input ?
            ).
        end.
      end.
    end.
  end.
end procedure.
