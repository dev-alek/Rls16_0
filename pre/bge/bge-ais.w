define input parameter parparentproc as widget-handle no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Экспорт данных в АИС 'Движение н/п в ТПС'".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define stream ExpStream .
define stream LogStream .
define temp-table t-obj-list no-undo
  field obj-type  as character
  field obj-code  as integer
  field host-code as integer
  index pi is unique primary obj-type obj-code
  index firm host-code
.
define temp-table t-goods no-undo
  field obj-type        as character
  field obj-code        as integer
  field artic           as character
  field prod-type       as character
  field prod-code       as integer
  field b-code          as integer
  field gds-name        as character
  field SalesVolCounter as decimal
  field SalesVolume     as decimal
  field SalesWeight     as decimal
  field OrderQnty       as decimal
  index pi is unique obj-type obj-code artic prod-type prod-code
  index goods artic prod-type prod-code
.
define temp-table t-goods-tank no-undo
  field obj-type        as character
  field obj-code        as integer
  field artic           as character
  field prod-type       as character
  field prod-code       as integer
  field TankNum         as character
  field StkTank         as decimal
  index pi obj-type obj-code artic prod-type prod-code TankNum
  index goods artic prod-type prod-code
  index tank TankNum
.
define variable v-exp-file-name    as character no-undo .
define variable v-log-file-name    as character no-undo .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-obj DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 2.5 BY 1.08.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE e-obj-list AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 15.75 BY 3.42 NO-UNDO.
DEFINE VARIABLE DateOrder AS DATE FORMAT "99/99/9999":U
     LABEL "прогноза продаж"
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.
DEFINE VARIABLE DateSales AS DATE FORMAT "99/99/9999":U
     LABEL "объема продаж"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE SelObj AS CHARACTER INITIAL "Глобально"
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Глобально", "Глобально",
"По фирме", "По фирме",
"Выборочно", "Выборочно"
     SIZE 13.25 BY 2.17 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 35.25 BY 4.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 35.25 BY 4.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     b-quit AT ROW 1.17 COL 12
     b-help AT ROW 1.17 COL 27
     DateSales AT ROW 4 COL 20 COLON-ALIGNED
     e-obj-list AT ROW 6.79 COL 20.63 NO-LABEL
     SelObj AT ROW 7.96 COL 3.5 NO-LABEL
     b-obj AT ROW 9.25 COL 17.38
     DateOrder AT ROW 5.29 COL 20 COLON-ALIGNED
     "Дата выгрузки:" VIEW-AS TEXT
          SIZE 15.75 BY .83 AT ROW 2.79 COL 3
     "Выбор объектов:" VIEW-AS TEXT
          SIZE 17.25 BY .83 AT ROW 6.79 COL 3
     RECT-1 AT ROW 2.46 COL 2
     RECT-2 AT ROW 6.46 COL 2
     SPACE(1.12) SKIP(0.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт данных для АИС ТПС"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       e-obj-list:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  assign
    DateSales
    DateOrder
  .
  if DateSales = ? then do:
    message
      substitute( "Не задана дата выгрузки" )
      view-as alert-box error
    .
    apply "entry" to DateSales in frame Dialog-Frame .
    return no-apply.
  end.
  if SelObj = 'Выборочно' then do:
    find first t-obj-list no-lock
      no-error
    .
    if not available t-obj-list then do:
      message
        substitute( "Не задано ни одного объекта." )
        view-as alert-box error
      .
      apply "entry" to SelObj in frame Dialog-Frame .
      return no-apply.
    end.
  end.
  run exp-ais in this-procedure .
END.
ON CHOOSE OF b-obj IN FRAME Dialog-Frame
DO:
  define variable v-user-select as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
  if v-user-select = true
  then do:
    for each t-obj-list
    on error undo, return no-apply
    :
      delete t-obj-list .
    end.
    assign
      e-obj-list    = "":U
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      create t-obj-list .
      assign
        t-obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
        t-obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
        e-obj-list = e-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
      .
    end.
    display
      e-obj-list
      with frame Dialog-Frame
    .
  end.
END.
ON LEAVE OF DateSales IN FRAME Dialog-Frame
DO:
  assign     DateSales   no-error .   if error-status :error then do:     message       error-status :get-message (1)       view-as alert-box error     .     return no-apply .   end.   assign     DateOrder = DateSales + 2   .   display     DateOrder     with frame Dialog-Frame   .
END.
ON RETURN OF DateSales IN FRAME Dialog-Frame
DO:
  assign     DateSales   no-error .   if error-status :error then do:     message       error-status :get-message (1)       view-as alert-box error     .     return no-apply .   end.   assign     DateOrder = DateSales + 2   .   display     DateOrder     with frame Dialog-Frame   .
  apply "entry" to SelObj in frame Dialog-Frame .
  return no-apply.
END.
ON RETURN OF SelObj IN FRAME Dialog-Frame
DO:
  apply "choose" to b-exit in frame Dialog-Frame .
END.
ON VALUE-CHANGED OF SelObj IN FRAME Dialog-Frame
DO:
  define buffer buf_db      for ub.db  .
  define buffer buf_clients for ub.clients .
  define variable v-object-available as logical   no-undo .
  assign
    SelObj
  .
  for each t-obj-list
  on error undo, return no-apply
  :
    delete t-obj-list .
  end.
  assign
    e-obj-list = "":U
  .
  case SelObj :
    when "Выборочно" then do:
      enable b-obj with frame Dialog-Frame .
    end.
    when "По фирме" then do:
      disable b-obj with frame Dialog-Frame .
      for each buf_clients no-lock
        where buf_clients.host-code = v-cntxt-host-code-obj
      on error undo, return no-apply
      :
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-object-available
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры gbl/usobjava.i" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return no-apply .
        end.
        if v-object-available = true
        then do:
          create t-obj-list .
          assign
            t-obj-list.obj-type = buf_clients.obj-type
            t-obj-list.obj-code = buf_clients.obj-code
            e-obj-list = e-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
          .
        end.
      end.
    end.
    when "Глобально" then do:
      disable b-obj with frame Dialog-Frame .
      for each buf_db no-lock
      on error undo, return no-apply
      :
        for each buf_clients no-lock
          where buf_clients.db-num = buf_db.db-num
        on error undo, return no-apply
        :
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  buf_clients.obj-type
  ,input  buf_clients.obj-code
  ,output v-object-available
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при вызове процедуры gbl/usobjava.i" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return no-apply .
          end.
          if v-object-available = true
          then do:
            create t-obj-list .
            assign
              t-obj-list.obj-type = buf_clients.obj-type
              t-obj-list.obj-code = buf_clients.obj-code
              e-obj-list = e-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
            .
          end.
        end.
      end.
    end.
  end case.
  display
    e-obj-list
    with frame Dialog-Frame
  .
END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of DateSales in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of DateSales in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of DateSales in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of DateSales in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of DateSales in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of DateSales in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date10
    MENU-ITEM m-ed-date10-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date10-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date10-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date10-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if DateSales :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      DateSales :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date10 :HANDLE
      DateSales :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle10 as handle no-undo .
  assign
    v-label-handle10 = DateSales :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle10)
  then do:
    if v-label-handle10 :tooltip = ""
    or v-label-handle10 :tooltip = ?
    then do:
      assign
        v-label-handle10 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date10-1 in menu m-ed-date10 DO:
    apply "ctrl-b":U to DateSales in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-2 in menu m-ed-date10 DO:
    apply "ctrl-d":U to DateSales in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-3 in menu m-ed-date10 DO:
    apply "ctrl-e":U to DateSales in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-4 in menu m-ed-date10 DO:
    apply "ctrl-f":U to DateSales in frame Dialog-Frame .
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN enable_UI.
  apply "value-changed" to SelObj in frame Dialog-Frame .
  apply "entry" to DateSales in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY DateSales SelObj DateOrder
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help RECT-1 RECT-2 DateSales e-obj-list SelObj
         DateOrder
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE exp-ais :
do
  on error undo, return error
  :
    define buffer buf_sys-ctrl      for ub.sys-ctrl .
    define buffer buf_rvs-doc       for ub.rvs-doc .
    define buffer prev_rvs-doc      for ub.rvs-doc .
    define buffer buf_rvs-line      for ub.rvs-line .
    define buffer buf_rvs-line-pump for ub.rvs-line-pump .
    define buffer buf_goods         for ub.goods .
    define buffer buf_trn-doc       for ub.trn-doc .
    define buffer buf_doc-line      for ub.doc-line .
    define buffer buf_place         for ub.place .
    define buffer buf_ord-doc       for ub.ord-doc .
    define buffer buf_ord-line      for ub.ord-line .
    define variable v-curr-db          as integer   no-undo .
    define variable v-delim            as character no-undo .
    define variable v-str-obj-list     as character no-undo .
    define variable v-attr-type        as character no-undo .
    define variable v-attr-delivery    as character no-undo .
    define variable v-attr-notdelivery as character no-undo .
    define variable v-coeff            as decimal   no-undo .
    define variable v-obj              as character no-undo .
    define variable v-action           as character no-undo .
    define variable v-cnt              as integer   no-undo .
    def frame inf
      v-obj    label "Объект" format "x(11)" skip
      v-action label "":U format "x(40)" skip
      v-cnt    label "Записей"
      with view-as dialog-box side-labels 1 columns three-d title "** Разбор пакета".
    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db = buf_sys-ctrl.db-num
    .
    assign
      v-exp-file-name = ".":U + chr(92) + "ais.xml":U
      v-log-file-name = ".":U + chr(92) + "ais.log":U
    .
    output stream ExpStream to value( v-exp-file-name ) .
    output stream LogStream to value( v-log-file-name ) append.
    assign
      file-info :file-name = v-exp-file-name
      v-exp-file-name = file-info :full-pathname
      file-info :file-name = v-log-file-name
      v-log-file-name = file-info :full-pathname
    .
    output stream LogStream close .
    put stream ExpStream unformatted
      space(0) '<?xml version="1.0" encoding="windows-1251"?>':U skip
      space(0) '<root>':U skip
      space(2) '<Header>':U skip
      space(4) '<Manifest>':U skip
      space(6) '<Name>':U v-exp-file-name '</Name>':U skip
      space(6) '<Version> 14.1':U replace( vss-revision + vss-date, '$':U, ' ':U ) '</Version>':U skip
      space(6) '</Manifest>':U skip
      space(2) '</Header>':U skip
      space(2) '<Options>':U skip
      space(4) '<ExportDate>':U cur-time-date() '</ExportDate>':U skip
      space(4) '<ExportTime>':U string( time, 'HH:MM:SS' ) '</ExportTime>':U skip
      space(4) '<DbNum>':U v-curr-db '</DbNum>':U skip
      space(4) '<DateSales>':U string( DateSales, "99/99/9999" ) '</DateSales>':U skip
      space(4) '<DateOrder>':U string( DateOrder, "99/99/9999" ) '</DateOrder>':U skip
      space(4) '<ObjList>':U
    .
    run write-to-log( 'Экспорт данных для АИС ТПС' ) .
    run write-to-log( substitute( 'Версия 14.1 &1', replace( vss-revision + vss-date, '$':U, ' ':U ) )  ) .
    run write-to-log( substitute( 'Начало выгрузки: &1', cur-time-string-sec() ) ) .
    run write-to-log( substitute( 'Текущая БД: &1', v-curr-db ) ) .
    run write-to-log( substitute( 'Дата объема продаж: &1', string( DateSales, "99/99/9999" ) ) ) .
    run write-to-log( substitute( 'Дата прогноза продаж: &1', string( DateOrder, "99/99/9999" ) ) ) .
    assign
      v-delim = '':U
    .
    for each t-obj-list
    on error undo, return error
    :
      assign
        v-str-obj-list = v-str-obj-list + substitute( "&1&2 &3", v-delim, t-obj-list.obj-type, t-obj-list.obj-code )
      .
      if v-delim = '':U then do:
        assign
          v-delim = ',':U
        .
      end.
    end.
    run write-to-log( substitute( 'Объекты (&1): &2', SelObj, v-str-obj-list ) ).
    assign
      v-delim = '':U
    .
    for each t-obj-list
    on error undo, return error
    :
      find first buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type = t-obj-list.obj-type
          and buf_rvs-doc.obj-code = t-obj-list.obj-code
          and buf_rvs-doc.shift-date = DateSales
          and buf_rvs-doc.rvs-type = 'смена':U
        no-error
      .
      if not available buf_rvs-doc then do:
        run write-to-log( substitute( "На объекте &1 &2 нет сменных сверок за дату &3. Расчет по этому объекту невозможен."
                                      ,t-obj-list.obj-type
                                      ,t-obj-list.obj-code
                                      ,DateSales
                                     )
                        ) .
        delete t-obj-list.
      end.
      else do:
        find first buf_rvs-doc no-lock
          where buf_rvs-doc.obj-type = t-obj-list.obj-type
            and buf_rvs-doc.obj-code = t-obj-list.obj-code
            and buf_rvs-doc.shift-date = DateSales
            and buf_rvs-doc.rvs-type = 'смена':U
            and buf_rvs-doc.status_ <> 'факт':U
          no-error
        .
        if available buf_rvs-doc then do:
          run write-to-log( substitute( "На объекте &1 &2 есть незакрытая сверка. Расчет по этому объекту невозможен."
                                        ,t-obj-list.obj-type
                                        ,t-obj-list.obj-code
                                      )
                          ) .
          delete t-obj-list.
        end.
        else do:
          put stream ExpStream unformatted
            v-delim t-obj-list.obj-type ',' t-obj-list.obj-code
          .
          if v-delim = '':U then do:
            assign
              v-delim = ',':U
            .
          end.
        end.
      end.
    end.
    put stream ExpStream unformatted
      '</ObjList>':U skip
      space(2) '</Options>':U skip
      space(2) '<Body>':U skip
    .
    view frame inf.
    for each t-obj-list no-lock
    on error undo, return error
    :
      assign
        v-obj = t-obj-list.obj-type + " ":U + string( t-obj-list.obj-code )
      .
      run clntattr-value( input t-obj-list.obj-type
                         ,input t-obj-list.obj-code
                         ,input 'delivery':U
                         ,output v-attr-delivery
                         ,output v-attr-type
                        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( 'Ошибка при чтении атрибута атрибута "Временной интервал возможности доставки" для объекта &1 &2'
                                      ,t-obj-list.obj-type
                                      ,t-obj-list.obj-code
                                    )
                          + chr(10)
                          + return-value + chr(10)
                          + error-status :get-message ( error-status :num-messages ) + chr(10)
                        ) .
      end.
      else do:
        if v-attr-delivery = "":U then do:
          run write-to-log( substitute( 'Для объекта &1 &2 не задан временной интервал возможности доставки'
                                        ,t-obj-list.obj-type
                                        ,t-obj-list.obj-code
                                       )
                          ) .
        end.
      end.
      run clntattr-value( input t-obj-list.obj-type
                         ,input t-obj-list.obj-code
                         ,input 'notdelivery':U
                         ,output v-attr-notdelivery
                         ,output v-attr-type
                        ) no-error.
      if error-status :error then do:
        run write-to-log( substitute( 'Ошибка при чтении атрибута атрибута "Временной интервал, запрещенный к доставке" для объекта &1 &2'
                                      ,t-obj-list.obj-type
                                      ,t-obj-list.obj-code
                                    )
                          + chr(10)
                          + return-value + chr(10)
                          + error-status :get-message ( error-status :num-messages ) + chr(10)
                        ) .
      end.
      else do:
        if v-attr-notdelivery = "":U then do:
          run write-to-log( substitute( 'Для объекта &1 &2 не задан временной интервал, запрещенный к доставке'
                                        ,t-obj-list.obj-type
                                        ,t-obj-list.obj-code
                                       )
                          ) .
        end.
      end.
      put stream ExpStream unformatted
        space(4) '<ObjInfo>':U skip
        space(6) '<ObjType>':U t-obj-list.obj-type '</ObjType>':U skip
        space(6) '<ObjCode>':U t-obj-list.obj-code '</ObjCode>':U skip
        space(6) '<TimeDelivery>':U v-attr-delivery '</TimeDelivery>':U skip
        space(6) '<TimeNotDelivery>':U v-attr-notdelivery '</TimeNotDelivery>':U skip
        space(4) '</ObjInfo>':U skip
      .
      find first buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type = t-obj-list.obj-type
          and buf_rvs-doc.obj-code = t-obj-list.obj-code
          and buf_rvs-doc.shift-date = DateSales
          and buf_rvs-doc.rvs-type = 'смена':U
      .
      for each buf_rvs-line-pump no-lock
        where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
      on error undo, return error
      :
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_rvs-line-pump.gds-code
        .
        find first t-goods
          where t-goods.obj-type  = buf_rvs-line-pump.obj-type
            and t-goods.obj-code  = buf_rvs-line-pump.obj-code
            and t-goods.artic     = buf_goods.artic
            and t-goods.prod-type = buf_goods.prod-type
            and t-goods.prod-code = buf_goods.prod-code
          no-error
        .
        if not available t-goods then do:
          create t-goods .
          assign
            t-goods.obj-type  = buf_rvs-line-pump.obj-type
            t-goods.obj-code  = buf_rvs-line-pump.obj-code
            t-goods.artic     = buf_goods.artic
            t-goods.prod-type = buf_goods.prod-type
            t-goods.prod-code = buf_goods.prod-code
            t-goods.gds-name  = buf_goods.gds-name
          .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output t-goods.b-code
  )  .
          assign
            v-action = "Расчет объема продаж"
            v-cnt    = 0
          .
          for each buf_trn-doc no-lock
            where buf_trn-doc.obj-type     = buf_rvs-doc.obj-type
              and buf_trn-doc.obj-code     = buf_rvs-doc.obj-code
              and buf_trn-doc.shift-date   = DateSales
          on error undo, return error
          :
            if buf_trn-doc.status_ = 'факт':U
              and ( buf_trn-doc.ext-doc-type = 'es':U
                    or buf_trn-doc.ext-doc-type = 'ee':U
                    or buf_trn-doc.ext-doc-type = 'rs':U
                    or buf_trn-doc.ext-doc-type = 're':U
                  )
            then do:
              if buf_trn-doc.ext-doc-type = 'rs':U
                 or buf_trn-doc.ext-doc-type = 're':U
              then do:
                assign
                  v-coeff = -1
                .
              end.
              else do:
                assign
                  v-coeff = 1
                .
              end.
              for each buf_doc-line no-lock
                where buf_doc-line.doc-code  = buf_trn-doc.doc-code
                  and buf_doc-line.prod-type = buf_goods.prod-type
                  and buf_doc-line.prod-code = buf_goods.prod-code
                  and buf_doc-line.artic     = buf_goods.artic
              on error undo, return error
              :
                assign
                  t-goods.SalesVolume = t-goods.SalesVolume + v-coeff * buf_doc-line.fact-qnty
                  t-goods.SalesWeight = t-goods.SalesVolume * buf_doc-line.fact-density
                .
                assign
                  v-cnt = v-cnt + 1
                .
                display
                  v-obj
                  v-action
                  v-cnt
                  with frame inf .
              end.
            end.
          end.
          assign
            v-action = "Просмотр заказов"
            v-cnt    = 0
          .
          for each buf_ord-doc no-lock
            where buf_ord-doc.obj-type   = buf_rvs-doc.obj-type
              and buf_ord-doc.obj-code   = buf_rvs-doc.obj-code
              and buf_ord-doc.ship-date  = DateOrder
              and buf_ord-doc.doc-type   = 'ОФ':U
              and buf_ord-doc.status_   <> 'новый':U
              and buf_ord-doc.status_   <> 'отказ':U
            ,each buf_ord-line no-lock
            where buf_ord-line.doc-code  = buf_ord-doc.doc-code
              and buf_ord-line.artic     = buf_goods.artic
              and buf_ord-line.prod-type = buf_goods.prod-type
              and buf_ord-line.prod-code = buf_goods.prod-code
          on error undo, return error
          :
            assign
              t-goods.OrderQnty = t-goods.OrderQnty + buf_ord-line.qnty
            .
            assign
              v-cnt = v-cnt + 1
            .
            display
              v-obj
              v-action
              v-cnt
              with frame inf .
          end.
          if v-cnt = 0 then do:
            run write-to-log( substitute( 'На объекте &1 &2 нет ни одной заявки на &3 по товару &4 &5 &6'
                                          ,t-obj-list.obj-type
                                          ,t-obj-list.obj-code
                                          ,string( DateOrder, "99/99/9999":U )
                                          ,buf_goods.artic
                                          ,buf_goods.prod-type
                                          ,buf_goods.prod-code
                                        )
                            ) .
          end.
          assign
            v-action = "Сбор информации по танкам"
            v-cnt    = 0
          .
          for each buf_rvs-line no-lock
            where buf_rvs-line.gds-code = buf_goods.gds-code
              and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
          on error undo, return error
          :
            find first buf_place no-lock
              where buf_place.obj-type = buf_rvs-line.obj-type
                and buf_place.obj-code = buf_rvs-line.obj-code
                and buf_place.pl-code  = buf_rvs-line.pl-code
            .
            create t-goods-tank .
            assign
              t-goods-tank.obj-type  = buf_rvs-line-pump.obj-type
              t-goods-tank.obj-code  = buf_rvs-line-pump.obj-code
              t-goods-tank.artic     = buf_goods.artic
              t-goods-tank.prod-type = buf_goods.prod-type
              t-goods-tank.prod-code = buf_goods.prod-code
              t-goods-tank.TankNum   = buf_place.loc1
              t-goods-tank.StkTank   = buf_rvs-line.state-measure-qnty
            .
            assign
              v-cnt = v-cnt + 1
            .
            display
              v-obj
              v-action
              v-cnt
              with frame inf .
          end.
        end.
        assign
          t-goods.SalesVolCounter = t-goods.SalesVolCounter + buf_rvs-line-pump.state-el-cnt
        .
      end.
      find first prev_rvs-doc no-lock
        where prev_rvs-doc.obj-type = t-obj-list.obj-type
          and prev_rvs-doc.obj-code = t-obj-list.obj-code
          and prev_rvs-doc.shift-date < DateSales
          and prev_rvs-doc.rvs-type = 'смена':U
        no-error
      .
      for each buf_rvs-line-pump no-lock
        where buf_rvs-line-pump.rvs-code = prev_rvs-doc.rvs-code
      on error undo, return error
      :
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_rvs-line-pump.gds-code
        .
        find first t-goods
          where t-goods.obj-type  = buf_rvs-line-pump.obj-type
            and t-goods.obj-code  = buf_rvs-line-pump.obj-code
            and t-goods.artic     = buf_goods.artic
            and t-goods.prod-type = buf_goods.prod-type
            and t-goods.prod-code = buf_goods.prod-code
          no-error
        .
        if available t-goods then do:
          assign
            t-goods.SalesVolCounter = t-goods.SalesVolCounter - buf_rvs-line-pump.state-el-cnt
          .
        end.
      end.
      assign
        v-action = "Вывод информации в файл"
        v-cnt    = ?
      .
      display
        v-obj
        v-action
        v-cnt
        with frame inf .
      for each t-goods no-lock
      on error undo, return error
      :
        put stream ExpStream unformatted
          space(4) '<Good>':U skip
          space(6) '<ObjType>':U t-goods.obj-type '</ObjType>':U skip
          space(6) '<ObjCode>':U t-goods.obj-code '</ObjCode>':U skip
          space(6) '<Artic>':U t-goods.artic '</Artic>':U skip
          space(6) '<ProdType>':U t-goods.prod-type '</ProdType>':U skip
          space(6) '<ProdCode>':U t-goods.prod-code '</ProdCode>':U skip
          space(6) '<BarCode>':U t-goods.b-code '</BarCode>':U skip
          space(6) '<GdsName>':U t-goods.gds-name '</GdsName>':U skip
          space(6) '<SalesVolCounter>':U t-goods.SalesVolCounter '</SalesVolCounter>':U skip
          space(6) '<SalesVolume>':U t-goods.SalesVolume '</SalesVolume>':U skip
          space(6) '<SalesWeight>':U t-goods.SalesWeight '</SalesWeight>':U skip
          space(6) '<OrderQty>':U t-goods.OrderQnty '</OrderQty>':U skip
          space(4) '</Good>':U skip
        .
        for each t-goods-tank no-lock
          where t-goods-tank.obj-type  = t-goods.obj-type
            and t-goods-tank.obj-code  = t-goods.obj-code
            and t-goods-tank.artic     = t-goods.artic
            and t-goods-tank.prod-type = t-goods.prod-type
            and t-goods-tank.prod-code = t-goods.prod-code
        on error undo, return error
        :
          put stream ExpStream unformatted
            space(4) '<Tank>':U skip
            space(6) '<ObjType>':U t-goods-tank.obj-type '</ObjType>':U skip
            space(6) '<ObjCode>':U t-goods-tank.obj-code '</ObjCode>':U skip
            space(6) '<Artic>':U t-goods-tank.artic '</Artic>':U skip
            space(6) '<ProdType>':U t-goods-tank.prod-type '</ProdType>':U skip
            space(6) '<ProdCode>':U t-goods-tank.prod-code '</ProdCode>':U skip
            space(6) '<TankNum>':U t-goods-tank.TankNum '</TankNum>':U skip
            space(6) '<StkTank>':U t-goods-tank.StkTank '</StkTank>':U skip
            space(4) '</Tank>':U skip
          .
        end.
      end.
    end.
    hide frame inf .
    put stream ExpStream unformatted
      space(2) '</Body>':U skip
      space(0) '</root>':U skip
    .
    run write-to-log( substitute( 'Окончание выгрузки: &1', cur-time-string-sec() ) ) .
    output stream ExpStream close.
    message
      "Отчет выведен в файл" v-exp-file-name skip
      "Создан log файл" v-log-file-name
      view-as alert-box information.
  end.
  return .
END PROCEDURE.
PROCEDURE write-to-log :
define input parameter v-message as character no-undo .
  do
  on error undo, return error
  :
    output stream LogStream to value( v-log-file-name ) append.
    put stream LogStream unformatted
      cur-time-string-sec() chr(32) v-cntxt-userid chr(32) chr(32) v-message skip
    .
    output stream LogStream close.
  end.
  return .
END PROCEDURE.
