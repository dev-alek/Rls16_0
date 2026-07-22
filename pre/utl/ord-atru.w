DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE TEMP-TABLE tt-gds-obj-prop NO-UNDO LIKE ub.gds-obj-prop.
DEFINE TEMP-TABLE tt-gds-obj-prop-attr NO-UNDO LIKE ub.gds-obj-prop-attr.
DEFINE TEMP-TABLE tt0-gds-obj-prop NO-UNDO LIKE ub.gds-obj-prop.
DEFINE TEMP-TABLE tt0-gds-obj-prop-attr NO-UNDO LIKE ub.gds-obj-prop-attr.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования параметров заказа".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdspoatr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-name in g#attr-lib
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
procedure gdspoatr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-tooltip in g#attr-lib
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
procedure gdspoatr-value :
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-value in g#attr-lib
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
end procedure.
procedure gdspoatr-write :
  define input parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-prop-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-write in g#attr-lib
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
end procedure.
procedure gdspoatr-exist :
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-exist in g#attr-lib
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
end procedure.
procedure gdspoatr-delete :
  define input  parameter p-gds-code like ub.gds-obj-prop-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-prop-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-prop-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-prop-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-delete in g#attr-lib
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
end procedure.
procedure gdspoatr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspoatr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-ind1 :
main-block:
  do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
define input-output parameter p-doc-rec  as recid no-undo.
define input  parameter p-gds-code                   like  ub.gds-obj-prop.gds-code no-undo.
define input  parameter p-obj-type                   like  ub.gds-obj-prop.obj-type no-undo.
define input  parameter p-obj-code                   like  ub.gds-obj-prop.obj-code no-undo.
define input  parameter p-gdop-igt                   like  ub.gds-obj-prop.gdop-igt no-undo.
define input  parameter p-gdop-assort-min            like  ub.gds-obj-prop.gdop-assort-min  no-undo.
define input  parameter p-gdop-min-stock             like  ub.gds-obj-prop.gdop-min-stock   no-undo.
define input  parameter p-grop-level-always-presence like  ub.gds-obj-prop.grop-level-always-presence  no-undo.
define input  parameter p-grop-max-stock             like  ub.gds-obj-prop.grop-max-stock              no-undo.
define input  parameter p-grop-min-order             like  ub.gds-obj-prop.grop-min-order              no-undo.
DEFINE INPUT  PARAMETER TABLE  FOR tt0-gds-obj-prop-attr.
define buffer buf_tt0-gds-obj-prop-attr for tt0-gds-obj-prop-attr.
define buffer bufs_gds-obj-prop for ub.gds-obj-prop.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
run cur-time in this-procedure(output v-date, output v-time).
  find first bufs_gds-obj-prop exclusive-lock where
            bufs_gds-obj-prop.gds-code          = p-gds-code   and
            bufs_gds-obj-prop.obj-type          = p-obj-type   and
            bufs_gds-obj-prop.obj-code          = p-obj-code  no-error .
    if not available bufs_gds-obj-prop then do:
        create bufs_gds-obj-prop.
        assign
            bufs_gds-obj-prop.gds-code           = p-gds-code
            bufs_gds-obj-prop.grop-date-update   = v-date
            bufs_gds-obj-prop.grop-time-update   = v-time
            bufs_gds-obj-prop.grop-db-num-update = v-db-num
            bufs_gds-obj-prop.obj-type           = p-obj-type
            bufs_gds-obj-prop.obj-code           = p-obj-code
        no-error .
        if error-status :error then message "Ошибка при создании записи" error-status :error error-status :get-message(1) .
    end.
if  p-gdop-igt                     <> ? then    bufs_gds-obj-prop.gdop-igt                   = p-gdop-igt.
if  p-gdop-assort-min              <> ? then    bufs_gds-obj-prop.gdop-assort-min            = p-gdop-assort-min.
if  p-gdop-min-stock               <> ? then    bufs_gds-obj-prop.gdop-min-stock             = p-gdop-min-stock  .
if  p-grop-level-always-presence   <> ? then    bufs_gds-obj-prop.grop-level-always-presence = p-grop-level-always-presence.
if  p-grop-max-stock               <> ? then    bufs_gds-obj-prop.grop-max-stock             = p-grop-max-stock           .
if  p-grop-min-order               <> ? then    bufs_gds-obj-prop.grop-min-order             = p-grop-min-order           .
      p-doc-rec = recid(bufs_gds-obj-prop)    .
for each buf_tt0-gds-obj-prop-attr
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if buf_tt0-gds-obj-prop-attr.attr-value <> ?
  and lookup(buf_tt0-gds-obj-prop-attr.attr-code, 'CorrIztDel':u) = 0
  then do:
    run gdspoatr-write in this-procedure (
                                            input p-gds-code
                                            ,input p-obj-type
                                            ,input p-obj-code
                                            ,input buf_tt0-gds-obj-prop-attr.attr-code
                                            ,input buf_tt0-gds-obj-prop-attr.attr-value
                                            ).
  end.
end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable log-file-name as character no-undo init "ord-atru.txt".
DEFINE BUTTON B-1  NO-CONVERT-3D-COLORS
     LABEL "B-1"
     SIZE 3 BY 1.
DEFINE BUTTON B-2
     LABEL "B-2"
     SIZE 3 BY 1.
DEFINE BUTTON B-3
     LABEL "B-3"
     SIZE 3 BY 1.
DEFINE BUTTON B-4
     LABEL "B-4"
     SIZE 3 BY 1.
DEFINE BUTTON B-5
     LABEL "B-5"
     SIZE 3 BY 1.
DEFINE BUTTON B-6
     LABEL "B-6"
     SIZE 3 BY 1.
DEFINE BUTTON B-7
     LABEL "B-7"
     SIZE 3 BY 1.
DEFINE BUTTON B-8
     LABEL "B-8"
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1 TOOLTIP "Прризвести изменения в базе данных"
     BGCOLOR 8 .
DEFINE BUTTON B-gds
     LABEL "Список товаров"
     SIZE 17 BY 1 TOOLTIP "Задания списока товаров"
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-obj
     LABEL "Список О/Ф"
     SIZE 17 BY 1 TOOLTIP "Список объектов и/или фирм"
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1 TOOLTIP "Не проводить изменения"
     BGCOLOR 8 .
DEFINE VARIABLE v-proc AS CHARACTER FORMAT "X(256)":U INITIAL "not-proc"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "","not-proc",
                     "Минимальный заказ равен кванту","min-ord_qvant"
     DROP-DOWN-LIST
     SIZE 61.5 BY 1 TOOLTIP "Назначение параметров заказа особым способом" NO-UNDO.
DEFINE VARIABLE E-6 AS CHARACTER INITIAL "Если на объекте есть АссМатрица, то товары , которым нужно поменять ИЖТ должны быть включены в АссМатрицу до запуска этого интерфейса"
     VIEW-AS EDITOR NO-BOX
     SIZE 21.5 BY 5
     FONT 4 NO-UNDO.
DEFINE VARIABLE F-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Ассортиментный минимум :"
      VIEW-AS TEXT
     SIZE 24.6 BY .67 NO-UNDO.
DEFINE VARIABLE F-6 AS CHARACTER FORMAT "X(256)":U INITIAL "ИЖТ :"
      VIEW-AS TEXT
     SIZE 5.5 BY .67 NO-UNDO.
DEFINE VARIABLE f-corrcoeff AS DECIMAL FORMAT ">>9.99":U INITIAL 0
     LABEL "Коррект. коэфф. для расчета кол-ва"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-gds-obj-prop SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-gds AT ROW 1 COL 30.6 WIDGET-ID 2
     B-obj AT ROW 1 COL 47.6 WIDGET-ID 4
     B-Help AT ROW 1 COL 65
     tt-gds-obj-prop.gdop-min-stock AT ROW 3 COL 37.6 COLON-ALIGNED FORMAT "->>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-1 AT ROW 3 COL 51 WIDGET-ID 6
     tt-gds-obj-prop.grop-max-stock AT ROW 4.5 COL 37.6 COLON-ALIGNED FORMAT "->>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "ALT-L или 2клика мыши"
     B-2 AT ROW 4.5 COL 51 WIDGET-ID 8
     tt-gds-obj-prop.grop-min-order AT ROW 5.97 COL 37.6 COLON-ALIGNED FORMAT "->>>,>>9.999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "ALT-L или 2клика мыши"
     B-3 AT ROW 5.97 COL 51 WIDGET-ID 10
     tt-gds-obj-prop.grop-level-always-presence AT ROW 7.43 COL 37.6 COLON-ALIGNED FORMAT ">.9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1 TOOLTIP "ALT-L или 2клика мыши"
     B-4 AT ROW 7.43 COL 51 WIDGET-ID 12
     f-corrcoeff AT ROW 8.73 COL 37.6 COLON-ALIGNED WIDGET-ID 52
     B-7 AT ROW 8.73 COL 51 WIDGET-ID 54
     v-proc AT ROW 10.33 COL 1.5 NO-LABEL WIDGET-ID 46
     B-8 AT ROW 10.33 COL 63.5 WIDGET-ID 50
     B-5 AT ROW 11.7 COL 30.4 WIDGET-ID 24
     tt-gds-obj-prop.gdop-assort-min AT ROW 11.7 COL 34.5 NO-LABEL WIDGET-ID 30
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Не менять", ?,
"Да", yes,
"Нет", no
          SIZE 26.5 BY 1.27 TOOLTIP "Да=входит в ассортиментный минимум"
     E-6 AT ROW 13.2 COL 2 NO-LABEL WIDGET-ID 44
     B-6 AT ROW 13.2 COL 30.4 WIDGET-ID 26
     tt-gds-obj-prop.gdop-igt AT ROW 13.2 COL 34.5 NO-LABEL WIDGET-ID 34
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Не менять", ?,
"Item 2", "2":U,
"Item 3", "3":U,
"Item 4", "4":U,
"Item 6", "6":U,
"Item 5", "5":U
          SIZE 32 BY 6.5
     F-5 AT ROW 11.4 COL 1.5 NO-LABEL WIDGET-ID 40
     F-6 AT ROW 11.8 COL 25 NO-LABEL WIDGET-ID 42
     SPACE(38.59) SKIP(8.05)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Замена атрибутов товара на объекте(фирме) для заказов списком".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       E-6:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-1 IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.gdop-min-stock = 0 .
  display tt-gds-obj-prop.gdop-min-stock with frame Dialog-Frame .
  enable  tt-gds-obj-prop.gdop-min-stock with frame Dialog-Frame .
  disable  b-1 with frame Dialog-Frame .
  hide b-1 in frame Dialog-Frame .
END.
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.grop-max-stock = 0 .
  display  tt-gds-obj-prop.grop-max-stock with frame Dialog-Frame .
  enable   tt-gds-obj-prop.grop-max-stock with frame Dialog-Frame .
  disable  b-2 with frame Dialog-Frame .
  hide b-2 in frame Dialog-Frame .
END.
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.grop-min-order = 0 .
  display tt-gds-obj-prop.grop-min-order with frame Dialog-Frame .
  enable  tt-gds-obj-prop.grop-min-order with frame Dialog-Frame .
  disable  b-3 with frame Dialog-Frame .
  hide b-3 in frame Dialog-Frame .
END.
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.grop-level-always-presence = 0 .
  display tt-gds-obj-prop.grop-level-always-presence with frame Dialog-Frame .
  enable  tt-gds-obj-prop.grop-level-always-presence with frame Dialog-Frame .
  disable  b-4 with frame Dialog-Frame .
  hide b-4 in frame Dialog-Frame .
END.
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.gdop-assort-min = yes .
  display tt-gds-obj-prop.gdop-assort-min with frame Dialog-Frame .
  enable  tt-gds-obj-prop.gdop-assort-min with frame Dialog-Frame .
  disable  b-5 with frame Dialog-Frame .
  hide b-5 in frame Dialog-Frame .
END.
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.gdop-igt = 'Пусто':U.
  display tt-gds-obj-prop.gdop-igt with frame Dialog-Frame .
  enable  tt-gds-obj-prop.gdop-igt with frame Dialog-Frame .
  disable  b-6 with frame Dialog-Frame .
  hide b-6 in frame Dialog-Frame .
END.
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  f-corrcoeff = 1 .
  display f-corrcoeff with frame Dialog-Frame .
  enable  f-corrcoeff with frame Dialog-Frame .
  disable  b-7 with frame Dialog-Frame .
  hide b-7 in frame Dialog-Frame .
END.
ON CHOOSE OF B-8 IN FRAME Dialog-Frame
DO:
  v-proc = "min-ord_qvant" .
  display v-proc with frame Dialog-Frame .
  enable  v-proc with frame Dialog-Frame .
  disable  b-8 with frame Dialog-Frame .
  hide b-8 in frame Dialog-Frame .
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-gds IN FRAME Dialog-Frame
DO:
  run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code ) .
END.
ON CHOOSE OF B-obj IN FRAME Dialog-Frame
DO:
define buffer buf_clients for ub.clients  .
define buffer buf_sysconf for ub.sysconf  .
define variable v-list as character no-undo .
define variable v-host-code as integer   no-undo .
define variable v-num as integer no-undo .
define variable ii    as integer no-undo .
for each obj-list :
  delete obj-list.
end.
  if p-mode = 'firm' then do:
      run adm/sconfs.w
        (input  parparentproc
        ,input  'b-sel,b-mark':U
        ,input  no
        ,input  v-cntxt-host-code-obj
        ,output v-host-code
        ,input-output v-list
        ) .
      if v-list = "" then return no-apply .
      assign v-num = num-entries (v-list) .
      do ii = 1 to v-num :
        find first buf_sysconf no-lock where RECID(buf_sysconf) = integer(entry(ii, v-list)) no-error.
        run create_obj-list ('орг':U,buf_sysconf.host-code) .
      end.
  end.
  else do:
  if v-cntxt-db-num = 0 then do:
    run ref/thobjs.w
        ( input parparentproc
        , input this-procedure:handle
        , input "b-mark,b-sel"
        , input 'все':U
        , input ''
        , input ?
        , input ?
        , input-output v-list ) no-error .
    end.
    else do:
    run ref/thobjs.w
        ( input parparentproc
        , input this-procedure:handle
        , input "b-mark,b-sel"
        , input 'все':U
        , input ''
        , input v-cntxt-db-num
        , input ?
        , input-output v-list ) no-error .
  end.
  for each obj-list:
    delete obj-list.
      end.
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj.
  for each buf_userobjs_temp-user-obj:
    run create_obj-list ( buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code) .
  end.
end.
END.
ON MOUSE-SELECT-DBLCLICK OF f-corrcoeff IN FRAME Dialog-Frame
OR ALT-L OF f-corrcoeff IN FRAME Dialog-Frame
DO:
  f-corrcoeff = ? .
  display f-corrcoeff with frame Dialog-Frame .
  disable f-corrcoeff with frame Dialog-Frame .
  enable  b-7 with frame Dialog-Frame .
  display b-7 with frame Dialog-Frame .
END.
ON RIGHT-MOUSE-CLICK OF f-corrcoeff IN FRAME Dialog-Frame
DO:
    assign
    f-corrcoeff = ?
    b-7:visible = true.
    display f-corrcoeff with frame Dialog-Frame.
    disable f-corrcoeff with frame Dialog-Frame.
    disable b-7 with frame Dialog-Frame.
END.
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.gdop-assort-min IN FRAME Dialog-Frame
DO:
  assign
    tt-gds-obj-prop.gdop-assort-min = ?
    b-5:visible = true.
    display tt-gds-obj-prop.gdop-assort-min with frame Dialog-Frame.
    disable tt-gds-obj-prop.gdop-assort-min with frame Dialog-Frame.
    disable b-5 with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF tt-gds-obj-prop.gdop-assort-min IN FRAME Dialog-Frame
OR ALT-L OF tt-gds-obj-prop.gdop-assort-min IN FRAME Dialog-Frame
DO:
  assign tt-gds-obj-prop.gdop-assort-min .
  if tt-gds-obj-prop.gdop-assort-min = ? then do:
    display tt-gds-obj-prop.gdop-assort-min with frame Dialog-Frame .
    disable tt-gds-obj-prop.gdop-assort-min with frame Dialog-Frame .
    enable  b-5 with frame Dialog-Frame .
    display b-5 with frame Dialog-Frame .
  end.
END.
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.gdop-igt IN FRAME Dialog-Frame
DO:
  assign
    tt-gds-obj-prop.gdop-igt = ?
    b-6:visible = true.
    display tt-gds-obj-prop.gdop-igt with frame Dialog-Frame.
    disable tt-gds-obj-prop.gdop-igt with frame Dialog-Frame.
    disable b-6 with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF tt-gds-obj-prop.gdop-igt IN FRAME Dialog-Frame
OR ALT-L OF tt-gds-obj-prop.gdop-igt IN FRAME Dialog-Frame
DO:
  assign tt-gds-obj-prop.gdop-igt .
  if tt-gds-obj-prop.gdop-igt = ? then do:
    display tt-gds-obj-prop.gdop-igt with frame Dialog-Frame .
    disable tt-gds-obj-prop.gdop-igt with frame Dialog-Frame .
    enable  b-6 with frame Dialog-Frame .
    display b-6 with frame Dialog-Frame .
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-gds-obj-prop.gdop-min-stock IN FRAME Dialog-Frame
OR ALT-L OF tt-gds-obj-prop.gdop-min-stock IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.gdop-min-stock = ? .
  display tt-gds-obj-prop.gdop-min-stock with frame Dialog-Frame .
  disable tt-gds-obj-prop.gdop-min-stock with frame Dialog-Frame .
  enable  b-1 with frame Dialog-Frame .
  display b-1 with frame Dialog-Frame .
END.
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.gdop-min-stock IN FRAME Dialog-Frame
DO:
    assign
    tt-gds-obj-prop.gdop-min-stock = ?
    b-1:visible = true.
    display tt-gds-obj-prop.gdop-min-stock with frame Dialog-Frame.
    disable tt-gds-obj-prop.gdop-min-stock with frame Dialog-Frame.
    disable b-1 with frame Dialog-Frame.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-gds-obj-prop.grop-level-always-presence IN FRAME Dialog-Frame
OR ALT-L OF tt-gds-obj-prop.grop-level-always-presence IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.grop-level-always-presence = ? .
  display tt-gds-obj-prop.grop-level-always-presence with frame Dialog-Frame .
  disable tt-gds-obj-prop.grop-level-always-presence with frame Dialog-Frame .
  enable  b-4 with frame Dialog-Frame .
  display b-4 with frame Dialog-Frame .
END.
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.grop-level-always-presence IN FRAME Dialog-Frame
DO:
    assign
    tt-gds-obj-prop.grop-level-always-presence = ?
    b-4:visible = true.
    display tt-gds-obj-prop.grop-level-always-presence with frame Dialog-Frame.
    disable tt-gds-obj-prop.grop-level-always-presence with frame Dialog-Frame.
    disable b-4 with frame Dialog-Frame.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-gds-obj-prop.grop-max-stock IN FRAME Dialog-Frame
OR ALT-L OF tt-gds-obj-prop.grop-max-stock IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.grop-max-stock = ? .
  display tt-gds-obj-prop.grop-max-stock with frame Dialog-Frame .
  disable tt-gds-obj-prop.grop-max-stock with frame Dialog-Frame .
  enable  b-2 with frame Dialog-Frame .
  display b-2 with frame Dialog-Frame .
END.
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.grop-max-stock IN FRAME Dialog-Frame
DO:
  assign
  tt-gds-obj-prop.grop-max-stock = ?
  b-2:visible = true.
  display tt-gds-obj-prop.grop-max-stock with frame Dialog-Frame.
  disable tt-gds-obj-prop.grop-max-stock with frame Dialog-Frame.
  disable b-2 with frame Dialog-Frame.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-gds-obj-prop.grop-min-order IN FRAME Dialog-Frame
OR ALT-L OF tt-gds-obj-prop.grop-min-order IN FRAME Dialog-Frame
DO:
  tt-gds-obj-prop.grop-min-order = ? .
  display tt-gds-obj-prop.grop-min-order with frame Dialog-Frame .
  disable tt-gds-obj-prop.grop-min-order with frame Dialog-Frame .
  enable  b-3 with frame Dialog-Frame .
  display b-3 with frame Dialog-Frame .
END.
ON RIGHT-MOUSE-CLICK OF tt-gds-obj-prop.grop-min-order IN FRAME Dialog-Frame
DO:
    assign
    tt-gds-obj-prop.grop-min-order = ?
    b-3:visible = true.
    display tt-gds-obj-prop.grop-min-order with frame Dialog-Frame.
    disable tt-gds-obj-prop.grop-min-order with frame Dialog-Frame.
    disable b-3 with frame Dialog-Frame.
END.
ON MOUSE-SELECT-DBLCLICK OF v-proc IN FRAME Dialog-Frame
OR ALT-L OF v-proc IN FRAME Dialog-Frame
DO:
  v-proc = "not-proc" .
  display  v-proc with frame Dialog-Frame .
  disable  v-proc with frame Dialog-Frame .
  enable  b-8 with frame Dialog-Frame .
  display b-8 with frame Dialog-Frame .
END.
ON RIGHT-MOUSE-CLICK OF v-proc IN FRAME Dialog-Frame
DO:
   assign
    v-proc = ?
    b-8:visible = true.
    display v-proc with frame Dialog-Frame.
    disable v-proc with frame Dialog-Frame.
    disable b-8 with frame Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    b-1:load-image-up("cmp/lock.ico":u) .
    b-1:load-image-down("cmp/lock.ico":u) .
    b-1:load-image-insensitive("cmp/lock.ico":u) .
    b-2:load-image-up("cmp/lock.ico":u) .
    b-2:load-image-down("cmp/lock.ico":u) .
    b-2:load-image-insensitive("cmp/lock.ico":u) .
    b-3:load-image-up("cmp/lock.ico":u) .
    b-3:load-image-down("cmp/lock.ico":u) .
    b-3:load-image-insensitive("cmp/lock.ico":u) .
    b-4:load-image-up("cmp/lock.ico":u) .
    b-4:load-image-down("cmp/lock.ico":u) .
    b-4:load-image-insensitive("cmp/lock.ico":u) .
    b-5:load-image-up("cmp/lock.ico":u) .
    b-5:load-image-down("cmp/lock.ico":u) .
    b-5:load-image-insensitive("cmp/lock.ico":u) .
    b-6:load-image-up("cmp/lock.ico":u) .
    b-6:load-image-down("cmp/lock.ico":u) .
    b-6:load-image-insensitive("cmp/lock.ico":u) .
    b-7:load-image-up("cmp/lock.ico":u) .
    b-7:load-image-down("cmp/lock.ico":u) .
    b-7:load-image-insensitive("cmp/lock.ico":u) .
    b-8:load-image-up("cmp/lock.ico":u) .
    b-8:load-image-down("cmp/lock.ico":u) .
    b-8:load-image-insensitive("cmp/lock.ico":u) .
  run init-proc no-error .
  if error-status :error then return error return-value .
  define variable v-user-name as character no-undo .
  find first tt-gds-obj-prop no-error .
  run enable_ui.
  find first tt-gds-obj-prop no-error .
enable
  b-exit
  b-quit
  b-help
with frame Dialog-Frame.
  case p-mode:
  when  'firm' then do:
     b-obj:label = "Список фирм" .
     assign frame Dialog-Frame:title =  "Замена атрибутов товара на фирме для заказов списком" .
     hide
      tt-gds-obj-prop.grop-max-stock b-2
      b-5 f-5 tt-gds-obj-prop.gdop-assort-min
     e-6 b-6 b-7 f-6 tt-gds-obj-prop.gdop-igt f-corrcoeff
      in frame Dialog-Frame .
  end.
  when  'obj' then do:
     b-obj:label = "Список объектов" .
     assign frame Dialog-Frame:title =  "Замена атрибутов товара на объекте для заказов списком" .
     hide
      b-5 f-5 tt-gds-obj-prop.gdop-assort-min
      e-6 b-6 f-6 tt-gds-obj-prop.gdop-igt
      in frame Dialog-Frame .
  end.
  when  'izt' then do:
     b-obj:label = "Список объектов" .
     assign frame Dialog-Frame:title =  "Замена атрибутов товара на объекте по  Ассортиментной политики" .
    tt-gds-obj-prop.gdop-igt:RADIO-BUTTONS  = substitute("&1,&2,&3,&3,&4,&4,&5,&5,&6,&6,&7,&7",
      "Не менять" , ? ,
      'Новинка':U ,
      'Основная группа':U ,
      'Нештатный':U ,
      'На вывод из ассортимента':U ,
      'Пусто':U
      ) .
    view frame Dialog-Frame.
     hide
      tt-gds-obj-prop.grop-max-stock b-2
      tt-gds-obj-prop.gdop-min-stock b-1
      tt-gds-obj-prop.grop-min-order b-3
      tt-gds-obj-prop.grop-level-always-presence b-4
     v-proc b-8 f-corrcoeff b-7
      in frame Dialog-Frame .
  end.
 end case.
  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS tt-gds-obj-prop.gdop-min-stock.
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-gds-obj-prop NO-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY f-corrcoeff v-proc E-6 F-5 F-6
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-gds-obj-prop THEN
    DISPLAY tt-gds-obj-prop.gdop-min-stock tt-gds-obj-prop.grop-max-stock
          tt-gds-obj-prop.grop-min-order
          tt-gds-obj-prop.grop-level-always-presence
          tt-gds-obj-prop.gdop-assort-min tt-gds-obj-prop.gdop-igt
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-gds B-obj B-Help B-1 B-2 B-3 B-4 B-7 B-8 B-5 B-6
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-proc :
define variable v-ii as integer no-undo .
for each tt-gds-obj-prop :
  delete tt-gds-obj-prop.
end.
 create  tt-gds-obj-prop.
    assign
      tt-gds-obj-prop.gdop-min-stock             = ?
      tt-gds-obj-prop.grop-level-always-presence = ?
      tt-gds-obj-prop.grop-max-stock             = ?
      tt-gds-obj-prop.grop-min-order             = ?
      tt-gds-obj-prop.gdop-assort-min            = ?
      tt-gds-obj-prop.gdop-igt                   = ?
f-corrcoeff                                = ?
      v-proc = "not-proc"
     .
do v-ii = 1 to num-entries('corrcoeff-po,CorrIztDel':u):
  find first tt-gds-obj-prop-attr where
            tt-gds-obj-prop-attr.attr-code = entry(v-ii, 'corrcoeff-po,CorrIztDel':u) no-error.
  if not available tt-gds-obj-prop-attr then do:
    create tt-gds-obj-prop-attr.
    assign
    tt-gds-obj-prop-attr.attr-code = entry(v-ii, 'corrcoeff-po,CorrIztDel':u)
    .
  end.
end.
END PROCEDURE.
PROCEDURE proc-save :
assign frame Dialog-Frame  tt-gds-obj-prop.gdop-min-stock .
assign frame Dialog-Frame  tt-gds-obj-prop.gdop-igt .
assign frame Dialog-Frame  tt-gds-obj-prop.gdop-assort-min .
assign frame Dialog-Frame  tt-gds-obj-prop.grop-level-always-presence .
assign frame Dialog-Frame  tt-gds-obj-prop.grop-max-stock  .
assign frame Dialog-Frame  tt-gds-obj-prop.grop-min-order .
assign frame Dialog-Frame  f-corrcoeff .
assign frame Dialog-Frame  v-proc .
    if not can-find ( first obj-list ) then do:
  message
  "Не задан список объектов/фирм"
  view-as alert-box error .
      return error.
    end.
    if not can-find ( first gds-list ) then do:
  message
  "Не задан список товаров"
  view-as alert-box error .
      return error.
    end.
    if  tt-gds-obj-prop.gdop-min-stock             = ? and
        tt-gds-obj-prop.gdop-igt                   = ? and
        tt-gds-obj-prop.gdop-assort-min            = ? and
        tt-gds-obj-prop.grop-level-always-presence = ? and
        tt-gds-obj-prop.grop-max-stock             = ? and
        tt-gds-obj-prop.grop-min-order             = ? and
    f-corrcoeff                                = ? and
        v-proc = "not-proc"
        then do:
  message
  "Не заданы значения для изменений"
  view-as alert-box error .
      return error.
    end.
for each tt-gds-obj-prop-attr:
  case tt-gds-obj-prop-attr.attr-code:
    when 'corrcoeff-po':U then do:
      assign
      tt-gds-obj-prop-attr.attr-value = string(f-corrcoeff).
    end.
  end.
end.
message
"Проводить изменения в БД ?"
           view-as alert-box question
           buttons yes-no update varlog as logical.
    if varlog = false then return error .
run str/diallog.w ( input parparentproc
            , input this-procedure
            , input ('process-list':U + chr(4) +
                    "1" + chr(4) +
                    "0" + chr(4) +
                    "1" + chr(4) +
                    "1" + chr(4) +
                    "yes")
            , input ''
            , input no
            , input 'Прервать'
            , input "Сохранение изменений по списку товаров") no-error .
END PROCEDURE.
PROCEDURE process-list :
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable v-ii as integer no-undo .
define variable v-ii-ok as integer no-undo .
define variable p-recid as recid no-undo.
define variable v-ok as logical no-undo.
define variable v-mes as character no-undo.
define buffer buf_goods for ub.goods  .
for each obj-list :
run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input substitute("&1&2", obj-list.obj-type, obj-list.obj-code)).
    for each gds-list :
        v-ii = v-ii + 1.
        run check-actg in this-procedure (
           input gds-list.grp-code
          ,input gds-list.gds-code
          ,input obj-list.obj-code
          ,input obj-list.obj-type
          ,output v-ok
          ,output v-mes
        ) no-error.
        if v-ok = true then do :
            CASE v-proc:
                WHEN "min-ord_qvant" THEN DO:
                find first buf_goods no-lock where
                          buf_goods.gds-code = gds-list.gds-code
                          no-error .
                    if not error-status :error  and
                      buf_goods.qnty-cart <> 0   and
                      buf_goods.qnty-cart <> ?
                      then do:
                    tt-gds-obj-prop.grop-min-order = buf_goods.qnty-cart.
                    end.
                END.
                OTHERWISE DO:
                END.
            END CASE.
            run gds-ind1 in this-procedure
                        (input-output p-recid
                        ,input gds-list.gds-code
                        ,input obj-list.obj-type
                        ,input obj-list.obj-code
                        ,input tt-gds-obj-prop.gdop-igt
                        ,input tt-gds-obj-prop.gdop-assort-min
                        ,input tt-gds-obj-prop.gdop-min-stock
                        ,input tt-gds-obj-prop.grop-level-always-presence
                        ,input tt-gds-obj-prop.grop-max-stock
                        ,input tt-gds-obj-prop.grop-min-order
                        ,input TABLE tt-gds-obj-prop-attr
                        ) no-error .
            if not error-status:error then do:
              v-ii-ok = v-ii-ok + 1.
            end.
        end.
        else do :
                    run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input v-mes).
        end.
    end.
end.
case p-mode:
  when 'firm' then do:
        run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input substitute("Обработано записей атрибутов товаров на фирме: &1, из них удачно: &2", v-ii, v-ii-ok)).
  end.
  when 'obj' then do:
        run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input substitute("Обработано записей атрибутов товаров на объекте: &1, из них удачно: &2", v-ii, v-ii-ok)).
  end.
  when 'izt' then do:
        run write-log-and-file in p-log-handle (             input 1           , input log-file-name           , input 1           , input substitute("Обработано записей индикаторов товаров на объекте: &1, из них удачно: &2", v-ii, v-ii-ok)).
    end.
end case.
END PROCEDURE.
procedure check-actg :
define input parameter p-grp-code as integer no-undo.
define input parameter p-gds-code as integer no-undo.
define input parameter p-obj-code as integer no-undo.
define input parameter p-obj-type as character no-undo.
define output parameter p-ok as logical no-undo.
define output parameter p-mes as character no-undo.
define variable glog as logical no-undo.
do
on error undo, return error
:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_reference_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  p-grp-code
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
    if glog then do:
      assign
        p-ok = true.
    end.
    else do :
      find first gds-grp no-lock
           where gds-grp.node-code = p-grp-code no-error.
      p-mes = substitute("товар с кодом &1, &2&3: У вас отсутствует глобальное право на изменение товара в привязке к группе товаров &4"
                   , p-gds-code
                   , p-obj-type
                   , p-obj-code
                   , (string(gds-grp.node-code) + " " + gds-grp.node-name)
                    ).
    end.
end.
end procedure.
