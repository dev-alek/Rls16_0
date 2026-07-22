block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.wth-doc NEW BUFFER Buf-New OLD BUFFER Buf-Old.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Триггер на запись документов МЦ".
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
      p-vss-parameters = substitute('&1|&2|&3'
                          ,Buf-New.doc-code
                          ,Buf-New.ext-doc-type
                          ,Buf-New.status_)
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE vardoc-sum-dtl like ub.wth-dtl.doc-sum no-undo .
DEFINE VARIABLE varfact-sum-dtl like ub.wth-dtl.fact-sum no-undo .
DEFINE VARIABLE varbef-sum-dtl like ub.wth-dtl.bef-sum no-undo .
DEFINE VARIABLE varaft-sum-dtl like ub.wth-dtl.aft-sum no-undo .
DEFINE VARIABLE vardoc-sum-line like ub.wth-line.doc-sum no-undo .
DEFINE VARIABLE varfact-sum-line like ub.wth-line.fact-sum no-undo .
DEFINE VARIABLE varbef-sum-line like ub.wth-line.bef-sum no-undo .
DEFINE VARIABLE varaft-sum-line like ub.wth-line.aft-sum no-undo .
DEFINE VARIABLE varsum-gds-rubl-line  like ub.wth-line.sum-gds-rubl no-undo .
DEFINE VARIABLE varsum-gds-base-line  like ub.wth-line.sum-gds-base no-undo .
DEFINE VARIABLE varsum-gds-rubl-dtl   like ub.wth-dtl.sum-gds-rubl no-undo .
DEFINE VARIABLE varsum-gds-base-dtl   like ub.wth-dtl.sum-gds-base no-undo .
DEFINE VARIABLE varsum-gds-rubl-parts like ub.wth-dtl.sum-gds-rubl no-undo .
DEFINE VARIABLE varsum-gds-base-parts like ub.wth-dtl.sum-gds-base no-undo .
DEFINE VARIABLE varis-dtl as logical no-undo .
DEFINE VARIABLE varis-part as logical no-undo .
DEFINE VARIABLE varinst-sum like ub.chk-pay.tot-sum no-undo .
DEFINE VARIABLE varchk-type like ub.chk-doc.chk-type no-undo .
define buffer check_chk-pay for ub.chk-pay .
define buffer check_chk-doc for ub.chk-doc .
define buffer bufdsum_wealth   for ub.wealth.
define variable var-entry              as character no-undo .
define variable varcli-name            as character no-undo .
define variable var-mes                as character no-undo .
define variable v-old-can-edit-inv-on  as character no-undo .
define variable v-new-can-edit-inv-on  as character no-undo .
define variable l-need-check-inv       as logical   no-undo init false .
define variable num_rec                as integer   no-undo .
define variable start-time             as integer   no-undo .
define variable current-time           as character no-undo .
define variable v-today                as date      no-undo .
define variable v-time                 as integer   no-undo .
define variable current-action         as character no-undo .
define variable v-description-doc-type as character no-undo .
define variable varchk-doc-exist     as logical   no-undo .
define variable v-cmp as character no-undo .
define variable par-talk    as logical      no-undo.
define buffer buf-line    for ub.wth-line .
define buffer buf-dtl     for ub.wth-dtl .
define buffer buf_sysconf for ub.sysconf .
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_out-wth-doc for ub.wth-doc.
assign
  v-description-doc-type = buf-new.doc-type
                         + " " + string(buf-new.inter_, "внут/внеш")
.
define frame a
  buf-new.doc-code                           label "Документ" skip
  v-description-doc-type                     label "Тип документа" skip
  current-action         format "x(40)"      no-label skip
  num_rec                format ">>>>>>>9"   label "Обработано МЦ" skip
  buf-line.wth-code                          label "Текущий код МЦ" skip
  current-time           format "x(8)"       label "Время" skip
  with view-as dialog-box side-labels three-d
  title "Обработка документа"
  .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if available buf-old
  then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run wthdat in g#library
  (input  buf-old.doc-type
  ,input   (NOT buf-new.exter_)
  ,input  buf-old.status_
  ,input  'can-change-status-inv-on=request'
  ,output v-old-can-edit-inv-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно запросить признак документа МЦ (buf-old)" skip
        "Документ" buf-new.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  else do:
    assign
      v-old-can-edit-inv-on = "true":u
    .
  end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run wthdat in g#library
  (input  buf-new.doc-type
  ,input   (NOT buf-new.exter_)
  ,input  buf-new.status_
  ,input  'can-change-status-inv-on=request'
  ,output v-new-can-edit-inv-on
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно запросить признак документа МЦ (wth-doc)" skip
      "Документ" buf-new.doc-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  if not g#news
  then do:
    if v-new-can-edit-inv-on <> "true":u
    or v-old-can-edit-inv-on <> "true":u
    or buf-new.status_ = 'факт':U
    or (buf-new.doc-type    = 'инв':U
        and buf-new.status_ = 'разрешен':U
        )
    then do:
      assign
        l-need-check-inv = true
      .
    end.
    if not new buf-new
    and buf-old.doc-type = 'инв':U
    and buf-old.status_  = 'разрешен':U
    then do:
      assign
        l-need-check-inv = false
      .
    end.
  end.
  if buf-new.auto-fill
  then do:
    find first buf_sysconf no-lock
      where buf_sysconf.host-code = buf-new.host-code
      no-error .
    if not available buf_sysconf
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестная фирма для документа МЦ (wth-doc)" skip
        "Документ" buf-new.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if  buf-new.cli-type = buf_sysconf.sale-type
    and buf-new.cli-code = buf_sysconf.sale-code
    then do:
      assign
        varchk-doc-exist = no
      .
    end.
    else do:
      assign
        varchk-doc-exist = yes
      .
    end.
  end.
  if buf-new.borned
  then do:
    assign
      varchk-doc-exist = no
    .
  end.
  if not g#news  or buf-new.user-db-num = ?
  then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdburt in g#library
  (output buf-new.user-db-num
  ,output buf-new.user-name
  ,output buf-new.sys-date
  ,output buf-new.sys-time
  ,output buf-new.sys-time-int
  )  .
    if g#news then buf-new.user-name  =  (chr(4) +  'СПН':U).
  end.
  if  buf-new.creid = '' and g#news then buf-new.creid = (chr(4) +  'СПН':U).
  else if  buf-new.creid = '' then
  buf-new.creid = g#userid .
 if (not g#news and buf-new.status_ = 'факт':U) or (g#news and  g#db-num = 0)
  then do:
      run trg/lock-wth.p
        (input buf-new.doc-code
        ,input l-need-check-inv
        ,input buf-new.fact-order
        ,input (buf-new.status_ = 'факт':U)
        ,input g#news
        ) no-error .
      if error-status :error
      then do:
        message
          "Не удалось наложить блокировку на все товары принадлежащие документу" skip
          "Документ" buf-new.doc-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box information .
        undo main-block, return error .
      end.
  end.
  if g#news   and buf-new.status_ = 'факт':U
  then do:
    run str/stkotwth.p
      (input recid( buf-new )
      ,input no
      ,input yes
      ,input 0) no-error .
    if error-status :error
    then do:
      MESSAGE
      vss-workfile vss-revision SKIP vss-description   SKIP
      "Ошибка при установке остатков МЦ на объекте!"   SKIP
      ERROR-STATUS:GET-MESSAGE( 1 ) SKIP RETURN-VALUE SKIP
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    END.
    if buf-new.is-back-date then do:
          run cur-time in this-procedure ( output v-today, output v-time).
          FOR EACH buf-line NO-LOCK WHERE
          buf-line.doc-code = buf-new.doc-code ON ERROR UNDO Main-Block, RETURN ERROR :
            run str/reclcwtl.p
              (input buf-new.obj-type
              ,input buf-new.obj-code
              ,input buf-new.fact-ord - 0.0000000001
              ,input buf-line.wth-code
              ,input no
              ,input 'close':U
              ,input buf-new.doc-code
              ,input buf-new.fact-date
              ,input g#db-num
              ,input g#userid
              ,input v-today
              ,input v-time
              ,input string(v-time, "HH:MM:SS")
              ) no-error .
            if error-status :error then do:
              MESSAGE substitute("&1 &2 &3&4" +
                                    "Ошибка при пересчете остатков при закрытии док-та МЦ &5 задним числом&4"  +
                                    "&6&4&7"
                                    ,vss-workfile
                                    ,vss-revision
                                    ,vss-description
                                    ,chr(10)
                                    ,error-status :get-message(1)
                                    , return-value )  VIEW-AS ALERT-BOX ERROR.
              UNDO Main-Block, RETURN ERROR var-mes.
            end.
          end.
    end.
  END.
  ELSE if not g#news and buf-new.status_ = 'факт':U
  then DO:
    run cur-time in this-procedure ( output v-today
                                  , output start-time
                                  ).
    assign
      current-action = "Обработка шапки документа."
    .
    run show-action in this-procedure
      (input "Обработка шапки документа."
      ).
      run gbl/chk-date.p
        (input buf-new.obj-type
        ,input buf-new.obj-code
        ,input buf-new.fact-date
        ,input buf-new.fact-time
        ,input buf-new.shift-date
        ,input buf-new.shift-num
        ,input yes
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при установке дат, времен, смен в документе (wth-doc)." skip
          "Документ МЦ" buf-new.doc-code skip
          "fact-date"  buf-new.fact-date  skip
          "fact-time"  buf-new.fact-time  skip
          "shift-date" buf-new.shift-date skip
          "shift-num"  buf-new.shift-num  skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return error.
      end.
      CASE buf-new.doc-type:
        when 'инв':U
        then do:
          run trg/wth-inv2.p (
                input no,
                input buf-new.doc-code,
                input buf-new.host-code,
                input buf-new.obj-type,
                input buf-new.obj-code,
                input buf-new.operator,
                input buf-new.deliver,
                input buf-new.receiver,
                input buf-new.inv-prs4,
                input buf-new.inv-prs5,
                input buf-new.auto-fill,
                input yes,
                input yes,
                output varcli-name ) no-error.
        end.
        otherwise do:
          run trg/wth-inc2.p (
                input no,
                input buf-new.doc-code,
                input buf-new.host-code,
                input buf-new.obj-type,
                input buf-new.obj-code,
                input buf-new.cli-type,
                input buf-new.cli-code,
                input buf-new.operator,
                input buf-new.deliver,
                input buf-new.receiver,
                input buf-new.doc-type,
                input buf-new.auto-fill,
                input buf-new.exter_,
                input buf-new.inter_,
                input buf-new.source-ref,
                input buf-new.source-type,
                input buf-new.borned,
                input yes,
                input buf-new.ext-doc-type  ,
                output varcli-name) no-error.
        end.
      END CASE.
      if error-status:error
      then do:
         var-entry = return-value.
         UNDO Main-Block, RETURN ERROR var-entry.
      end.
    if  buf-new.doc-type <> 'обмен':U
    then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
vardoc-sum-dtl = 0
varfact-sum-dtl = 0
varbef-sum-dtl = 0
varaft-sum-dtl = 0
vardoc-sum-line = 0
varfact-sum-line = 0
varbef-sum-line = 0
varaft-sum-line = 0
varinst-sum = 0
varsum-gds-rubl-line = 0
varsum-gds-base-line = 0
varsum-gds-rubl-dtl = 0
varsum-gds-base-dtl = 0
varsum-gds-rubl-parts = 0
varsum-gds-base-parts = 0
.
FOR EACH buf-line No-LOCK WHERE
         buf-line.doc-code = buf-new.doc-code:
  assign
  vardoc-sum-dtl = 0
  varfact-sum-dtl = 0
  varbef-sum-dtl = 0
  varaft-sum-dtl = 0
  varsum-gds-rubl-dtl = 0
  varsum-gds-base-dtl = 0
  varis-dtl = no
  .
  FOR EACH buf-dtl No-LOCK WHERE
           buf-dtl.doc-code = buf-line.doc-code AND
           buf-dtl.wth-code = buf-line.wth-code AND
           buf-dtl.w-p-code = buf-line.w-p-code:
    assign
    varis-dtl = yes
    vardoc-sum-dtl = vardoc-sum-dtl + buf-dtl.doc-sum
    varfact-sum-dtl = varfact-sum-dtl + buf-dtl.fact-sum
    varbef-sum-dtl = varbef-sum-dtl + buf-dtl.bef-sum
    varaft-sum-dtl = varaft-sum-dtl + buf-dtl.aft-sum
    varsum-gds-rubl-dtl = varsum-gds-rubl-dtl + buf-dtl.sum-gds-rubl
    varsum-gds-base-dtl = varsum-gds-base-dtl + buf-dtl.sum-gds-base
    .
    assign varsum-gds-rubl-parts = 0
    varsum-gds-base-parts = 0
    varis-part = no.
    for each buf_wth-parts no-lock where
      buf_wth-parts.w-p-code = buf-dtl.w-p-code and
      buf_wth-parts.wth-code = buf-dtl.wth-code and
      buf_wth-parts.par-code = buf-dtl.par-code and
      buf_wth-parts.out-code = buf-dtl.doc-code and
      buf_wth-parts.stts = 0 :
      assign
      varis-part = yes
      varsum-gds-rubl-parts = varsum-gds-rubl-parts + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
      varsum-gds-base-parts = varsum-gds-base-parts + buf_wth-parts.fact-qnty * buf_wth-parts.price-base
      .
    end.
    if varis-part or can-find(first bufdsum_wealth where bufdsum_wealth.wth-code = buf-dtl.wth-code and bufdsum_wealth.is-ser = 1 no-lock  ) then do:
      if varsum-gds-rubl-parts <> buf-dtl.sum-gds-rubl then do:
        var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                  "Код МЦ" +  chr(32) +  string(buf-dtl.wth-code) + chr(10) +
                  "Код МХ" + chr(32) + string(buf-dtl.w-p-code) + chr(10) +
                  "Код номинала" + chr(32) + string(buf-dtl.par-code) + chr(10) +
                  "Сумма по связанным товарам в рублях по партиям не равна сумме по номиналу" + chr(10) + chr(10) +
                  "Сумма по связанным товарам в рублях   по партиям=" + string(varsum-gds-rubl-parts) + chr(32) +
                  "Сумма по связанным товарам в рублях   по номиналу=" + string(buf-dtl.sum-gds-rubl).
        if par-talk then
        message var-mes
        view-as alert-box error .
         undo main-block,  return error var-mes.
      end.
      if varsum-gds-base-parts <> buf-dtl.sum-gds-base then do:
        var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                  "Код МЦ" +  chr(32) +  string(buf-dtl.wth-code) + chr(10) +
                  "Код МХ" + chr(32) + string(buf-dtl.w-p-code) + chr(10) +
                  "Код номинала" + chr(32) + string(buf-dtl.par-code) + chr(10) +
                  "Сумма по связанным товарам в базовой валюте по партиям не равна сумме по номиналу" + chr(32) +  chr(10) +
                  "Сумма по связанным товарам в базовой валюте по партиям=" + string(varsum-gds-base-parts) + chr(32) +
                  "Сумма по связанным товарам в базовой валюте по номиналу=" + string(buf-dtl.sum-gds-base).
        if par-talk then
        message var-mes
        view-as alert-box error .
         undo main-block,  return error var-mes.
      end.
    end.
  END.
  if varis-dtl then do:
    if vardoc-sum-dtl <> buf-line.doc-sum then do:
      var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf-line.w-p-code) + chr(10) +
                "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                "Сумма по документу по номиналам=" + string(vardoc-sum-dtl) + chr(32) +
                "Сумма по документу по строке=" + string(buf-line.doc-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
       undo main-block,  return error var-mes.
    end.
    if buf-new.status_ = 'факт':U then do:
      if varfact-sum-dtl <> buf-line.fact-sum then do:
        var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                  "Код МЦ" +  chr(32) +  string(buf-line.wth-code) + chr(10) +
                  "Код МХ" + chr(32) + string(buf-line.w-p-code) + chr(10) +
                  "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                  (if buf-new.doc-type = 'инв':U
                  then
                  string(
                  "Сумма расхождений по номиналам=" + string(varfact-sum-dtl) + chr(32) +
                  "Сумма расхождений по строке=" + string(buf-line.fact-sum)
                  )
                  else
                  string(
                  "Сумма факт по номиналам=" + string(varfact-sum-dtl) + chr(32) +
                  "Сумма факт по строке=" + string(buf-line.fact-sum))
                  ).
        if par-talk then
        message var-mes
        view-as alert-box error .
         undo main-block,  return error var-mes.
      end.
    end.
    if varbef-sum-dtl <> buf-line.bef-sum then do:
      var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf-line.w-p-code) + chr(10) +
                "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                "Сумма план по номиналам=" + string(varbef-sum-dtl) + chr(32) +
                "Сумма план по строке=" + string(buf-line.bef-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
       undo main-block,  return error var-mes.
    end.
    if buf-new.doc-type = 'инв':U then do:
      if buf-new.status_ = 'факт':U then do:
        if varaft-sum-dtl <> buf-line.aft-sum then do:
          var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                    "Код МЦ" +  chr(32) +  string(buf-line.wth-code) + chr(10) +
                    "Код МХ" + chr(32) + string(buf-line.w-p-code) + chr(10) +
                    "Сумма по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                    "Сумма факт по номиналам=" + string(varaft-sum-dtl) + chr(32) +
                    "Сумма факт по строке=" + string(buf-line.aft-sum).
          if par-talk then
          message var-mes
          view-as alert-box error .
           undo main-block,  return error var-mes.
        end.
      end.
    end.
    if varsum-gds-rubl-dtl <> buf-line.sum-gds-rubl then do:
      var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf-line.w-p-code) + chr(10) +
                "Сумма по связанным товарам в рублях  по номиналам не равна сумме по строке" + chr(32) + chr(10) +
                "Сумма по связанным товарам в рублях  по номиналам=" + string(varsum-gds-rubl-dtl) + chr(32) +
                "Сумма по связанным товарам в рублях  по строке=" + string(buf-line.sum-gds-rubl).
      if par-talk then
      message var-mes
      view-as alert-box error .
       undo main-block,  return error var-mes.
    end.
    if varsum-gds-base-dtl <> buf-line.sum-gds-base then do:
      var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                "Код МЦ" +  chr(32) +  string(buf-line.wth-code) + chr(10) +
                "Код МХ" + chr(32) + string(buf-line.w-p-code) + chr(10) +
                "Сумма по связанным товарам в базовой валюте по номиналам не равна сумме по строке" + chr(32) +  chr(10) +
                "Сумма по связанным товарам в базовой валюте по номиналам=" + string(varsum-gds-base-dtl) + chr(32) +
                "Сумма по связанным товарам в базовой валюте по строке=" + string(buf-line.sum-gds-base).
      if par-talk then
      message var-mes
      view-as alert-box error .
       undo main-block,  return error var-mes.
    end.
  end .
  assign
  vardoc-sum-line = vardoc-sum-line + buf-line.doc-sum
  varfact-sum-line = varfact-sum-line + buf-line.fact-sum
  varbef-sum-line = varbef-sum-line + buf-line.bef-sum
  varaft-sum-line = varaft-sum-line + buf-line.aft-sum
  varsum-gds-rubl-line = varsum-gds-rubl-line + buf-line.sum-gds-rubl
  varsum-gds-base-line = varsum-gds-base-line + buf-line.sum-gds-base
  .
END.
if vardoc-sum-line <> buf-new.doc-sum then do:
  var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
            "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
            "Сумма по документу по строкам=" + string(vardoc-sum-line) + chr(32) +
            "Сумма по документу по шапке=" + string(buf-new.doc-sum).
  if par-talk then
  message var-mes
  view-as alert-box error .
   undo main-block,  return error var-mes.
end.
if buf-new.status_ = 'факт':U then do:
  if varfact-sum-line <> buf-new.fact-sum then do:
    var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
              "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
              (if buf-new.doc-type = 'инв':U
              then
                string(
                "Сумма расхождений по строкам=" + string(varfact-sum-line) + chr(32) +
                "Сумма расхождений по шапке=" + string(buf-new.fact-sum)
                )
              else
              string(
              "Сумма факт по строкам=" + string(varfact-sum-line) + chr(32) +
              "Сумма факт по шапке=" + string(buf-new.fact-sum))
              ).
    if par-talk then
    message var-mes
    view-as alert-box error .
     undo main-block,  return error var-mes.
  end.
end.
if varbef-sum-line <> buf-new.bef-sum then do:
  var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
            "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
            "Сумма план по строкам=" + string(varbef-sum-line) + chr(32) +
            "Сумма план по шапке=" + string(buf-new.bef-sum).
  if par-talk then
  message var-mes
  view-as alert-box error .
   undo main-block,  return error var-mes.
end.
if buf-new.doc-type = 'инв':U then do:
  if varaft-sum-line <> buf-new.aft-sum then do:
    var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
              "Сумма по строкам не равна сумме по шапке" + chr(32) + chr(10) +
              "Сумма факт по строкам=" + string(varaft-sum-line) + chr(32) +
              "Сумма факт по шапке=" + string(buf-new.aft-sum).
    if par-talk then
    message var-mes
    view-as alert-box error .
     undo main-block,  return error var-mes.
  end.
end.
if varsum-gds-rubl-line <> buf-new.sum-gds-rubl then do:
  var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
            "Сумма по связанным товарам в рублях  по строкам не равна сумме по шапке" + chr(32) + chr(10) +
            "Сумма по связанным товарам в рублях  по строкам=" + string(varsum-gds-rubl-line) + chr(32) +
            "Сумма по связанным товарам в рублях  по шапке=" + string(buf-new.sum-gds-rubl).
  if par-talk then
  message var-mes   varsum-gds-rubl-line  buf-new.sum-gds-rubl
  view-as alert-box error .
   undo main-block,  return error var-mes.
end.
if varsum-gds-base-line <> buf-new.sum-gds-base then do:
  var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
            "Сумма по связанным товарам в базовой валюте по строкам не равна сумме по шапке" + chr(32) +   chr(10) +
            "Сумма по связанным товарам в базовой валюте по строкам=" + string(varsum-gds-base-line) + chr(32) +
            "Сумма по связанным товарам в базовой валюте по шапке=" + string(buf-new.sum-gds-base).
  if par-talk then
  message var-mes
  view-as alert-box error .
   undo main-block,  return error var-mes.
end.
if buf-new.auto-fill and varchk-doc-exist then do:
  for each check_chk-doc WHERE
           check_chk-doc.out-code = buf-new.doc-code AND
           check_chk-doc.obj-type = buf-new.obj-type AND
           check_chk-doc.obj-code = buf-new.obj-code,
      EACH check_chk-pay No-LOCK WHERE
           check_chk-pay.doc-code = check_chk-doc.doc-code:
    varinst-sum = varinst-sum + check_chk-pay.tot-sum.
    varchk-type = check_chk-doc.chk-type.
  end.
  if buf-new.doc-type = 'рас':U then do:
    assign
    varinst-sum = - varinst-sum
    .
  end.
  if buf-new.doc-type = 'инв':U then do:
    if string(varchk-type) = '4':U then dO:
    end.
    else do:
      if varinst-sum <> buf-new.aft-sum then do:
        var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                  "Сумма по строкам чеков МЦ не равна сумме факт по шапке" + chr(32) + chr(10) +
                  "Сумма по строкам чеков МЦ=" + string(varinst-sum) + chr(32) +
                  "Сумма факт по шапке=" + string(buf-new.aft-sum).
        if par-talk then
        message var-mes
        view-as alert-box error .
         undo main-block,  return error var-mes.
      end.
    end.
  end.
  else do:
    if varinst-sum <> buf-new.doc-sum then do:
      var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                "Сумма по строкам чеков МЦ не равна сумме документа по шапке" + chr(32) + chr(10) +
                "Сумма по строкам чеков МЦ=" + string(varinst-sum) + chr(32) +
                "Сумма документа по шапке=" + string(buf-new.doc-sum).
        if par-talk then
        message var-mes
        view-as alert-box error .
         undo main-block,  return error var-mes.
    end.
    if varinst-sum <> buf-new.fact-sum
    and buf-new.doc-type <> 'декл':U
    then do:
      var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                "Сумма по строкам чеков МЦ не равна сумме факт по шапке" + chr(32) + chr(10) +
                "Сумма по строкам чеков МЦ=" + string(varinst-sum) + chr(32) +
                "Сумма факт по шапке=" + string(buf-new.fact-sum).
      if par-talk then
      message var-mes
      view-as alert-box error .
       undo main-block,  return error var-mes.
    end.
    if buf-new.doc-type = 'декл':U
    and buf-new.fact-sum <> 0 then do:
      var-mes = "Документ МЦ" + chr(32) + buf-new.doc-code + chr(10) +
                "Тип" + chr(32) + buf-new.doc-type +
                "Сумма факт по шапке <> 0" .
      if par-talk then
      message var-mes
      view-as alert-box error .
       undo main-block,  return error var-mes.
    end.
  end.
end.
    end.
    assign
      current-action = "Обработка строк МЦ."
    .
    view frame a.
    for each buf-line exclusive-lock
      where buf-line.doc-code = buf-new.doc-code
    on error undo main-block, return error
    on end-key undo main-block, return error
    :
      if buf-old.status_ <> buf-new.status_
      then do:
        run process-line in this-procedure no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при обработке строк МЦ" skip
            "Документ" buf-new.doc-code skip
            "Код МЦ" buf-line.wth-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo main-block, return error .
        end.
      end.
    end.
    assign current-action = "Обработка партий МЦ."    .
    view frame a.
    if buf-old.status_ <> buf-new.status_
    then for each buf_wth-parts exclusive-lock
      where buf_wth-parts.out-code = buf-new.doc-code
    on error undo main-block, return error 'Oшибка обработки партий МЦ'
    on end-key undo main-block, return error 'Oшибка обработки партий МЦ'
    :
      assign buf_wth-parts.fact-date = buf-new.fact-date
             buf_wth-parts.fact-order = buf-new.fact-order
             buf_wth-parts.fact-num = buf-new.fact-num.
      validate buf_wth-parts no-error.
    end.
  END.
    if  g#news
    and  g#db-num = 0
    and buf-new.status_ = 'факт':U
    and buf-old.status_ <> buf-new.status_
    and ((buf-new.obj-type = buf-new.cli-type and
        buf-new.obj-code = buf-new.cli-code and
        buf-new.inter_ = yes) or
       lookup(buf-new.ext-doc-type,'ep,ip,ff,fj,ii,ei,pj,ef':U) > 0 )
    then do:
      run str/wth-out.p (buffer buf-new, buffer buf_out-wth-doc) no-error.
      if error-status:error then do:
                message
            vss-workfile vss-revision vss-description skip
            "Ошибка при создании связанного документа" skip
            "Документ" buf-new.doc-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        UNDO Main-Block, RETURN ERROR var-mes.
      end.
    end.
    def    variable v-dstnws                as logical init YES no-undo.
    define variable v-value-character       as character no-undo .
    define variable v-value-date            as date      no-undo .
    define variable v-value-decimal         as decimal   no-undo .
    define variable v-value-integer         as integer   no-undo .
    define variable v-value-logical         as logical   no-undo .
    define variable v-param-type            as character no-undo .
    if lookup(buf-new.ext-doc-type,'ep,ip,pj,rp,dp,oj':U) > 0 and g#db-num = 0 and buf-new.status_ = 'факт':U then do:
            run adm/shattri.p ( input "get":U
                          , input ""
                          , input 0
                          , input 'attr-wthrep':U
                          , input  ""
                          , output v-value-character
                          , output v-value-date
                          , output v-value-decimal
                          , output v-value-integer
                          , output v-value-logical
                          , output v-param-type
                          , INPUT-OUTPUT TABLE thbjattr_thbj-attr
                          ) no-error .
        for first thbjattr_thbj-attr
              where thbjattr_thbj-attr.obj-code  = 0
                and thbjattr_thbj-attr.obj-type  = ""
                and thbjattr_thbj-attr.prop-code = 'docdstnws':U
                and thbjattr_thbj-attr.upper-prop-code = 'attr-wthrep':U
              no-lock:
            assign
            v-dstnws = not thbjattr_thbj-attr.property-value-logical.
        end.
    end.
    if  (buf-new.status_ = 'факт':U
    or   buf-new.exter_ = no )
    and  (lookup(buf-new.ext-doc-type,'ep,ip,pj,rp,dp,oj':U) = 0 or ( lookup(buf-new.ext-doc-type,'ep,ip,pj,rp,dp,oj':U) > 0 and v-dstnws))
    then do:
      run show-action in this-procedure
        (input "Отправка документа в новости"
        ).
      run str/callnews.p
        ( INPUT "wth-doc"
         ,INPUT (buffer Buf-New:handle)
        ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      THEN DO:
        MESSAGE
        vss-workfile vss-revision vss-description                    SKIP
        "Невозможно маршрутизировать wth-doc для отправки в новости" SKIP
        ERROR-STATUS:GET-MESSAGE( 1 ) SKIP RETURN-VALUE             SKIP
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
    END.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'wth-doc':U
        , input ( buffer ub.wth-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
END.
 procedure process-line :
  do
  on error undo, return error
  :
    assign
      num_rec   = num_rec + 1
    .
    if num_rec mod 10 = 0 then do:
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      assign
        current-time = string(v-time - start-time, "HH:MM:SS")
      .
      display
        num_rec buf-line.wth-code current-time current-action
        with frame a.
      process events .
    end.
    assign
    buf-line.ext-doc-type = buf-new.ext-doc-type
    buf-line.status_  = buf-new.status_
    buf-line.fact-order = buf-new.fact-order
    buf-line.fact-date  = buf-new.fact-date
    .
  end.
end procedure.
procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .
    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    assign
      current-time = string(v-time - start-time, "HH:MM:SS")
      current-action = p-action
    .
    display
      current-time current-action
      with frame a.
    process events .
  end.
end procedure.
