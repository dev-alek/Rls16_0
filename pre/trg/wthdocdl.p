block-level on error undo, throw.
define input  parameter p-doc-code like ub.wth-doc.doc-code no-undo .
define input  parameter parphchip-num      as   integer                      no-undo.
define input  parameter p-file-name-err    as   char                         no-undo.
define output parameter parchip-num        as   integer                      no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Удаление документа матценностей".
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
      p-vss-parameters = substitute('&1':u,p-doc-code)
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info0, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure fact-order-mpl :
  do
  on error undo, return error return-value
  :
define input  parameter p-doc-date as date     no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-fact-order as decimal   no-undo .
define variable v-fact-date            as date    no-undo .
define variable v-fact-time            as integer no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable shift-date as date      no-undo .
define variable shift-num  as integer   no-undo .
define variable shift-name as character no-undo .
define variable max-fact-order as decimal   no-undo .
define buffer buf_global-state for ub.global-state  .
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
  run cur-time in this-procedure
  ( output v-fact-date ,
    output v-fact-time  ).
if p-doc-date = ? then do:
if buf_global-state.pl-use-sys-date-time  = true then do:
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  ?
        ,input  ?
        ,input  false
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
else do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then return error "Неопределена дата на объекте " + return-value .
      if p-doc-date <> ? then do:
      end.
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error substitute(" Ошибка из factdate.p: &1 &2"  , return-value , error-status :get-message(1)   ) .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
end.
else do:
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error "Ошибка factdate.p " + return-value .
      v-fact-date = p-doc-date .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
  end.
end procedure.
DEFINE TEMP-TABLE tt_price-all NO-UNDO LIKE ub.price-all
field sale-qnty as decimal
field sale-sum  as decimal
field sale-tnv  as decimal
field price-sale-base as decimal
field price-sale-rubl as decimal
field road-tax-base   as decimal
field road-tax-rubl   as decimal
field excise-base as decimal
field excise-rubl as decimal
field date-1 as date
field date-2 as date
field shift-1 as int
field shift-2 as int
field time-1 as int
field time-2 as int
field grp-name as char
field interv-name as char
field pay-name as char
field unit-cli as char
index pi
plt-priority DESCENDING
fact-order DESCENDING
qnty-from asc
sum-from asc
turnover-from asc
date-1 DESCENDING
time-1 DESCENDING
date-2 DESCENDING
time-2 DESCENDING
type-price DESCENDING
.
procedure mpl-autoprice :
define input  parameter p-only-b-code as logical   no-undo .
define input  parameter p-cli-type    as character no-undo .
define input  parameter p-cli-code    as integer   no-undo .
define input  parameter p-main-b-code as integer   no-undo .
define input  parameter p-b-code      as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-qnty-doc    as decimal   no-undo .
define input  parameter p-sum-doc     as decimal   no-undo .
define input  parameter p-vid-pay        as character no-undo .
define input  parameter p-cash-pay-type  as character no-undo .
define input  parameter p-fact-order  as decimal   no-undo .
define output parameter p-plt-id          as integer   no-undo .
define output parameter p-plt-db-num      as integer   no-undo .
define output parameter p-pdf-id          as integer   no-undo .
define output parameter p-pdf-db-num      as integer   no-undo .
define output parameter p-sale-price-base as decimal   no-undo .
define output parameter p-sale-price-rubl as decimal   no-undo .
define output parameter p-road-tax-base as decimal   no-undo .
define output parameter p-road-tax-rubl as decimal   no-undo .
define output parameter p-excise-base   as decimal   no-undo .
define output parameter p-excise-rubl   as decimal   no-undo .
define variable v-cli-oborot-ALL as decimal   no-undo .
define buffer buf_buyer-in-buyer-group   for ub.buyer-in-buyer-group  .
define buffer buf_turnover-buyer-main    for ub.turnover-buyer-main  .
define buffer buf1_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf2_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf_price-all              for ub.price-all  .
define buffer buf_goods                  for ub.goods      .
define buffer buf_global-state           for ub.global-state  .
define buffer buf_buyer-group            for ub.buyer-group  .
define buffer buf_turnover-group         for ub.turnover-group  .
define buffer buf_main-code              for ub.bar-code  .
define buffer buf_bar-code               for ub.bar-code  .
define buffer buf_pay-type               for ub.pay-type  .
define buffer buf_cash-pay               for ub.cash-pay  .
define variable to-day          as date      no-undo .
define variable v-base-rate0    as decimal   no-undo .
define variable v-base-scale0   as decimal   no-undo .
define variable v-exch-rate0    as decimal   no-undo .
define variable v-exch-scale0   as decimal   no-undo .
define variable v-base-rate     as decimal   no-undo .
define variable v-base-scale    as decimal   no-undo .
define variable v-exch-rate     as decimal   no-undo .
define variable v-exch-scale    as decimal   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-curr-abbr     as character no-undo .
define variable v-grp-name      as character no-undo .
define variable v-date-1        as date      no-undo .
define variable v-date-2        as date      no-undo .
define variable v-interv        as character no-undo .
define variable v-pay-name      as character no-undo .
define variable v-cli-oborot    as decimal   no-undo .
define variable v-trn-pay-code  as integer   no-undo .
define variable v-cash-pay-curr as integer   no-undo .
define variable v-cash-pay-code as integer   no-undo .
do
on error undo, return error return-value
:
find first buf_main-code no-lock where buf_main-code.b-code = p-main-b-code .
find first buf_goods no-lock where buf_goods.gds-code = buf_main-code.gds-code.
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ).
end.
if p-vid-pay <> "" then do:
   find first buf_pay-type no-lock where  buf_pay-type.obj-code = integer(p-vid-pay) no-error .
   if available buf_pay-type
      then v-trn-pay-code = buf_pay-type.obj-code.
      else v-trn-pay-code =  0.
end.
else v-trn-pay-code = 0 .
if p-cash-pay-type <> "" then do:
   find first buf_cash-pay no-lock where  recid(buf_cash-pay) = integer(p-cash-pay-type) no-error .
   if available buf_pay-type
      then
        assign
          v-cash-pay-curr = buf_cash-pay.curr-code
          v-cash-pay-code = buf_cash-pay.cdpay-code
        .
      else
        assign
          v-cash-pay-curr = 0
          v-cash-pay-code = 0
          .
end.
else
  assign
    v-cash-pay-curr = 0
    v-cash-pay-code = 0
    .
for each tt_price-all  : delete tt_price-all . end.
assign
  p-plt-id             = ?
  p-plt-db-num         = ?
  p-pdf-id             = ?
  p-pdf-db-num         = ?
  p-sale-price-base    = ?
  p-sale-price-rubl    = ?
  v-cli-oborot         = 0
.
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  to-day
  ,output v-base-rate0
  ,output v-base-scale0
  )  .
  v-cli-oborot-ALL  = 0 .
  for each buf_turnover-buyer-main no-lock  where
           buf_turnover-buyer-main.cli-type = p-cli-type  and
           buf_turnover-buyer-main.cli-code = p-cli-code
           :
           v-cli-oborot-ALL = v-cli-oborot-ALL + buf_turnover-buyer-main.sum-doc-rubl-itog .
  end.
for each buf_price-all no-lock where
         buf_price-all.obj-type = p-obj-type and
         buf_price-all.obj-code = p-obj-code and
         buf_price-all.gds-code = buf_goods.gds-code and
         buf_price-all.status_  = 'акт':U  and
       ( p-only-b-code = false   or
       ( buf_price-all.b-code = p-main-b-code or
         buf_price-all.b-code = p-b-code))    and
        ( p-only-b-code = true  or
          buf_price-all.b-code = p-b-code)
          and
          buf_price-all.fact-order-sys-from  <= p-fact-order  and
        ( buf_price-all.fact-order-sys-to = ? or
          buf_price-all.fact-order-sys-to    >= p-fact-order)
        :
         v-interv   = "" .
         v-grp-name = "" .
         v-pay-name = "" .
         if buf_price-all.fact-order = 0  and buf_price-all.plt-priority = 0  then next.
         if buf_price-all.bgr-id > 0 then do:
            find first buf_buyer-group no-lock where
                       buf_buyer-group.bgr-id     = buf_price-all.bgr-id  and
                       buf_buyer-group.bgr-db-num = buf_price-all.bgr-db-num  no-error .
            if available buf_buyer-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
               find first buf_buyer-in-buyer-group no-lock where
                          buf_buyer-in-buyer-group.stts         = 0 and
                          buf_buyer-in-buyer-group.bgr-id       = buf_buyer-group.bgr-id     and
                          buf_buyer-in-buyer-group.bgr-db-num   = buf_buyer-group.bgr-db-num  and
                          buf_buyer-in-buyer-group.bbg-obj-type = p-cli-type and
                          buf_buyer-in-buyer-group.bbg-obj-code = p-cli-code
                          no-error .
                          if not available buf_buyer-in-buyer-group then do:
                             v-grp-name = "".
                             next.
                          end.
                          v-grp-name = buf_buyer-group.name .
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.tog-id > 0 then do:
            find first buf_turnover-group no-lock where
                       buf_turnover-group.tog-id     = buf_price-all.tog-id      and
                       buf_turnover-group.tog-db-num = buf_price-all.tog-db-num  no-error .
            if available buf_turnover-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
                  v-cli-oborot = v-cli-oborot-all  .
                  find first buf1_tnv-in-turnover-group no-lock where
                             buf1_tnv-in-turnover-group.stts       =  0     and
                             buf1_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf1_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf1_tnv-in-turnover-group.ttg-summa  <=  v-cli-oborot no-error .
                  find first buf2_tnv-in-turnover-group no-lock where
                             buf2_tnv-in-turnover-group.stts       =  0     and
                             buf2_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf2_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf2_tnv-in-turnover-group.ttg-summa  >=  v-cli-oborot no-error .
                  if not (available buf1_tnv-in-turnover-group and
                          available buf2_tnv-in-turnover-group ) then do:
                          v-grp-name = "".
                          next .
                  end.
                  v-grp-name = buf_turnover-group.name.
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.plt-fix-cource-crc-base = true then
            assign
              v-base-rate  = buf_price-all.pdf-base-rate
              v-base-scale = buf_price-all.pdf-base-scale
            .
            else
            assign
              v-base-rate  = v-base-rate0
              v-base-scale = v-base-scale0
            .
         if buf_price-all.plt-fix-cource-crc-doc = true then
            assign
              v-exch-rate  = buf_price-all.pdf-exch-rate
              v-exch-scale = buf_price-all.pdf-exch-scale
            .
            else do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_price-all.curr-code
  ,input  to-day
  ,output v-exch-rate0
  ,output v-exch-scale0
  ,output v-curr-abbr
  )  .
            assign
              v-exch-rate  = v-exch-rate0
              v-exch-scale = v-exch-scale0
              .
           end.
           v-date-1 = date ( "" )  .
           if buf_price-all.fact-order-sys-from > 0 then do:
              if buf_price-all.start-sys-date <> ?   then  v-date-1 = buf_price-all.start-sys-date.
              if buf_price-all.start-shift-date <> ? then  v-date-1 = buf_price-all.start-shift-date.
              if buf_price-all.start-date <> ?       then  v-date-1 = buf_price-all.start-date.
           end.
           v-date-2 =  date ( "" )  .
           if buf_price-all.fact-order-sys-to > 0 then do:
              if buf_price-all.end-sys-date <> ?     then  v-date-2 = buf_price-all.end-sys-date.
              if buf_price-all.end-shift-date <> ?   then  v-date-2 = buf_price-all.end-shift-date.
              if buf_price-all.end-date <> ?         then  v-date-2 = buf_price-all.end-date.
           end.
           if buf_price-all.qnty-from <> ? then do :
              if not (
              ( p-qnty-doc  >= buf_price-all.qnty-from and buf_price-all.qnty-to = ? ) or
              ( p-qnty-doc  >= buf_price-all.qnty-from and p-qnty-doc <= buf_price-all.qnty-to and buf_price-all.qnty-to <> ?)
              ) then do:
                     v-interv = "".
                     next.
              end.
              v-interv = "К: " + string(buf_price-all.qnty-from) + " - " + ( if buf_price-all.qnty-to = ? then "и более" else string(buf_price-all.qnty-to)) .
           end.
           if buf_price-all.sum-from <> ? then do :
              if not (
              ( p-sum-doc  >= buf_price-all.sum-from and buf_price-all.sum-to = ? ) or
              ( p-sum-doc  >= buf_price-all.sum-from and p-sum-doc <= buf_price-all.sum-to and buf_price-all.sum-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "C: " +  string(buf_price-all.sum-from) + " - " + ( if buf_price-all.sum-to = ? then "и более" else string(buf_price-all.sum-to)) .
           end.
           if buf_price-all.turnover-from <> ? then do :
              if not (
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and buf_price-all.turnover-to = ? ) or
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and v-cli-oborot-ALL <= buf_price-all.turnover-to and buf_price-all.turnover-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "O: " +  string(buf_price-all.turnover-from) + " - " + ( if buf_price-all.turnover-to = ? then "и более" else string(buf_price-all.turnover-to)) .
           end.
           if buf_price-all.use-pay-type = 1 then do :
              if buf_price-all.pay-code <> v-trn-pay-code then do:
                 v-pay-name = "" .
                 next.
               end.
               v-pay-name = 'Оплата':U +  ":" + string(buf_price-all.pay-code) .
           end.
           if buf_price-all.use-cash-pay = 1 then do :
              if v-cash-pay-code <> 0 and  not ( buf_price-all.curr-pay-code = v-cash-pay-curr and
                                                 buf_price-all.cdpay-code    = v-cash-pay-code ) then do:
                v-pay-name = "" .
                next.
              end.
              v-pay-name = 'Касс.платеж':U + ":" + string(buf_price-all.cdpay-code) + "_" + string(buf_price-all.curr-pay-code).
           end.
          find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
          create tt_price-all .
          buffer-copy buf_price-all to tt_price-all
          assign
            tt_price-all.price-sale-rubl = buf_price-all.price-sale  * v-exch-rate / v-exch-scale
            tt_price-all.road-tax-rubl   = buf_price-all.road-tax    * v-exch-rate / v-exch-scale
            tt_price-all.excise-rubl     = buf_price-all.excise      * v-exch-rate / v-exch-scale
            tt_price-all.price-sale-base = tt_price-all.price-sale-rubl  / v-base-rate * v-base-scale
            tt_price-all.road-tax-base   = tt_price-all.road-tax-rubl    / v-base-rate * v-base-scale
            tt_price-all.excise-base     = tt_price-all.excise-rubl      / v-base-rate * v-base-scale
            tt_price-all.price-sale     = buf_price-all.price-sale
            tt_price-all.road-tax       = buf_price-all.road-tax
            tt_price-all.excise         = buf_price-all.excise
            tt_price-all.pdf-exch-rate   = v-exch-rate
            tt_price-all.pdf-exch-scale  = v-exch-scale
            tt_price-all.pdf-base-rate   = v-base-rate
            tt_price-all.pdf-base-scale  = v-base-scale
            tt_price-all.grp-name        = v-grp-name
            tt_price-all.date-1          = v-date-1
            tt_price-all.shift-1         = buf_price-all.start-shift-num
            tt_price-all.time-1          = buf_price-all.start-sys-time
            tt_price-all.date-2          = v-date-2
            tt_price-all.shift-2         = buf_price-all.end-shift-num
            tt_price-all.time-2          = buf_price-all.end-sys-time
            tt_price-all.interv-name     = v-interv
            tt_price-all.pay-name        = v-pay-name
            tt_price-all.unit-cli        = buf_bar-code.unit-cli
          .
end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = p-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = neos_price-all.price-sale-base
            p-sale-price-rubl  = neos_price-all.price-sale-rubl
            p-road-tax-base    = neos_price-all.road-tax-base
            p-road-tax-rubl    = neos_price-all.road-tax-rubl
            p-excise-base      = neos_price-all.excise-base
            p-excise-rubl      = neos_price-all.excise-rubl
            .
         end.
         else do:
              find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
              if error-status :error    then do:
                message "Не найден бар-код" p-b-code view-as alert-box error .
                return error return-value .
              end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
end.
end procedure.
procedure mpl-tpl-auto :
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-fact-order as decimal   no-undo .
define output parameter p-sale-price as decimal   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ) .
end.
assign
  p-pdf-id      = ?
  p-pdf-db-num  = ?
  p-sale-price  = ?
.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
if error-status :error then return error return-value .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
if error-status :error then return error return-value .
define variable v-main-b-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
define buffer buf_price-all for ub.price-all  .
for each tt_price-all : delete tt_price-all. end.
    for each buf_price-all no-lock where
            buf_price-all.plt-id     = p-plt-id                 and
            buf_price-all.plt-db-num = p-plt-db-num             and
            buf_price-all.obj-type   = p-obj-type               and
            buf_price-all.obj-code   = p-obj-code               and
            buf_price-all.gds-code   = buf_goods.gds-code       and
          ( buf_price-all.b-code = v-main-b-code or
            buf_price-all.b-code = p-b-code)    and
            buf_price-all.status_    = 'акт':U         and
            buf_price-all.fact-order-sys-from  <= p-fact-order  and
          ( buf_price-all.fact-order-sys-to = ? or
            buf_price-all.fact-order-sys-to >=  p-fact-order)
            :
              create tt_price-all .
              buffer-copy buf_price-all to tt_price-all
              assign
                tt_price-all.price-sale  = buf_price-all.price-sale
              .
    end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = v-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = neos_price-all.price-sale
            .
         end.
         else do:
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        if error-status :error    then do:
           message "Не найден бар-код" p-b-code view-as alert-box error .
           return error return-value .
        end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
  end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure wthcattr-sprcli :
define input parameter parparentproc  as widget-handle no-undo.
define input parameter p-mode  as character no-undo.
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  DEFINE VARIABLE v-value as character no-undo .
  define variable v-cli-type as character no-undo .
  define variable v-cli-code as integer no-undo .
  define buffer buf_clients   for ub.clients.
  define variable v_rid as character no-undo.
  define variable ref-rec as recid no-undo .
  do
  on error undo, return error
  :
      v-value = p-value.
   if p-value <> '':U then do:
    assign
    v-cli-type = substring(p-value, 1, 3)
    v-cli-code = integer(substring(p-value, 4))
    no-error.
    if error-status:error then do:
      assign
      v-cli-type = '':U
      v-cli-code = 0
      .
    end.
   end.
   FIND FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = v-cli-type AND
            buf_clients.obj-code = v-cli-code  NO-ERROR.
   IF available(buf_clients) then do:
    run ref/cli-all.w (
                input parparentproc
               ,input if p-mode = 'ИЗМЕНЕНИЕ':U then "b-sel":U else "":U
               ,input v-cli-type
               ,input 'все':U
               ,input 'все':U
               ,input RECID( buf_clients )
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  ELSE if p-mode = 'ИЗМЕНЕНИЕ':U then DO:
    run ref/cli-all.w (
                 input parparentproc
                ,INPUT "b-sel":U
               ,input  v-cli-type
               ,input 'все':U
               ,input 'текущие':U
               ,input ?
               ,input ",,,,,,NO"
               ,input ?
               ,OUTPUT v_rid ).
  END.
  else do:
    message
    if p-value = "":U then 'Атрибут не задан!'
    else substitute('Не найден клиент &1',p-value)
    view-as alert-box warning.
  end.
  IF v_rid <> ? AND v_rid <> "":U THEN DO:
    ASSIGN ref-rec = INT( v_rid ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
    END.
    FIND FIRST buf_clients NO-LOCK WHERE
               RECID( buf_clients ) = ref-rec NO-ERROR.
    IF AVAIL buf_clients THEN DO:
      v-value = buf_clients.obj-type + string(buf_clients.obj-code, ">>>>>>>>9").
    end.
  end.
  if v-value <> p-value then do:
    p-value = v-value.
    p-setted = yes.
  end.
  end.
end procedure.
  define new global shared variable g#wthcalib as handle no-undo.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
def temp-table tt-wthlib-parts no-undo like ub.wth-parts.
Procedure wth-doc-close:
    define input parameter p-rec        as recid     no-undo .
    DEFINE BUFFER cur-wth-parts FOR ub.wth-parts.
  do
  on error undo, return error return-value
  :
    find first cur-wth-parts where recid(cur-wth-parts) = p-rec exclusive-lock no-wait no-error.
    if not available cur-wth-parts then return error substitute("Не найдена партия").
    CASE cur-wth-parts.ext-doc-type:
        WHEN 'ie':U or when 'rf':U or when 'ff':U
        OR WHEN 'fj':U
        THEN DO:
           RUN wth-parts-close(BUFFER cur-wth-parts, 'free-zone':U ).
        END.
        WHEN 'ee':U THEN DO:
            RUN wth-parts-close(BUFFER cur-wth-parts, 'cli-zone':U ).
        END.
        WHEN 'ps':U OR WHEN 'pz':U OR WHEN 'rp':U
          OR WHEN 'ip':U OR WHEN 'pc':U
          OR WHEN 'pj':U
           THEN DO:
            RUN wth-parts-close(BUFFER cur-wth-parts, 'put-zone':U ).
        END.
        WHEN 'df':U OR WHEN 'dp':U OR WHEN 'dc':U THEN DO:
          RUN wth-parts-close(BUFFER cur-wth-parts, 'out-zone':U ).
        end.
        when 'ep':U or when 'ef':U
        OR WHEN 'oj':U or when 'jj':U
        then .
        when 'xc':U then do:
          if cur-wth-parts.type = 'при':U then
               RUN wth-parts-close(BUFFER cur-wth-parts, 'put-zone':U ).
          else RUN wth-parts-close(BUFFER cur-wth-parts, 'cli-zone':U ).
        end.
        OTHERWISE DO:
            RETURN ERROR substitute("Неверный вызов процедуры закрытия: расш. тип = &1"
                                 , cur-wth-parts.ext-doc-type
                                    ).
        END.
    END CASE.
    RELEASE cur-wth-parts.
    END.
END.
PROCEDURE wth-parts-close:
    DEFINE PARAMETER BUFFER bfrom_wth-parts FOR ub.wth-parts.
    DEFINE INPUT PARAMETER p-zone AS CHAR NO-UNDO.
    define variable v-rec as recid.
    if bfrom_wth-parts.stts  = 1 then return.
       run str/wthpartp.p  ( INPUT     'ДОБАВЛЕНИЕ':U,
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     p-zone,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code               ,
                  INPUT     bfrom_wth-parts.price-rubl    ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,
                  INPUT     bfrom_wth-parts.supp-code,
                  INPUT     bfrom_wth-parts.in-obj-type      ,
                  INPUT     bfrom_wth-parts.in-obj-code      ,
                  INPUT     bfrom_wth-parts.ext-doc-type,
                  INPUT     bfrom_wth-parts.gds-code,
                  INPUT     bfrom_wth-parts.stts               ,
                  INPUT     bfrom_wth-parts.beg-dt        ,
                  INPUT     bfrom_wth-parts.end-dt        ,
                  INPUT     bfrom_wth-parts.vat-pc        ,
                  INPUT     bfrom_wth-parts.cli-code,
                  INPUT     bfrom_wth-parts.cli-type,
                  INPUT     bfrom_wth-parts.out-obj-code,
                  INPUT     bfrom_wth-parts.out-obj-type,
                  INPUT     bfrom_wth-parts.sale-obj-code,
                  INPUT     bfrom_wth-parts.sale-obj-type,
                  INPUT     bfrom_wth-parts.out-code ,
                  INPUT  yes,
                  INPUT     '':U ,
                  INPUT-OUTPUT v-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
END.
Procedure wth-doc-razrez:
    define input parameter p-rec as recid NO-UNDO.
    define input parameter p-doc-del AS log NO-UNDO.
    define variable v-mess AS CHAR NO-UNDO.
    define variable p-silent AS LOG INIT NO NO-UNDO.
    DEFINE BUFFER b-wth-parts FOR ub.wth-parts.
    DEFINE BUFFER buf_wth-parts FOR ub.wth-parts.
    DEFINE BUFFER cur-wth-parts FOR ub.wth-parts.
  do
  on error undo, return error return-value
  :
    FIND FIRST cur-wth-parts WHERE recid(cur-wth-parts) = p-rec
                              EXCLUSIVE-LOCK .
    IF AVAILABLE cur-wth-parts THEN DO:
        CASE cur-wth-parts.ext-doc-type:
            WHEN 'ie':U or when 'ip':U or when 'rp':U
            or when 'ff':U or when 'rf':U
            or when 'fj':U or when 'pj':U
            THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, "":U,p-doc-del) .
            END.
            WHEN 'ee':U or when 'ef':U or when 'jj':U
            THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'free-zone':U,p-doc-del) .
            END.
            WHEN 'ep':U or when 'oj':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'put-zone':U,p-doc-del) .
            END.
            WHEN 'pc':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'cli-zone':U,p-doc-del)  .
            END.
            WHEN 'dp':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'put-zone':U,p-doc-del)  .
            END.
            WHEN 'df':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'free-zone':U,p-doc-del)  .
            END.
            WHEN 'dc':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'cli-zone':U,p-doc-del)  .
            END.
            WHEN 'ps':U OR WHEN 'pz':U THEN DO:
                RUN wth-parts-raz(BUFFER cur-wth-parts, 'cli-zone':U,p-doc-del).
            END.
            when 'xc':U then do:
              if cur-wth-parts.type = 'при':U then
                   RUN wth-parts-raz(BUFFER cur-wth-parts, 'cli-zone':U,p-doc-del ).
              else RUN wth-parts-raz(BUFFER cur-wth-parts,  'free-zone':U ,p-doc-del).
            end.
            OTHERWISE DO:
                RETURN ERROR substitute("Неверный вызов процедуры разрезервирования: расш. тип =  :&1&2&3"
                                     , cur-wth-parts.ext-doc-type
                                     , error-status:get-message(1)
                                     , return-value
                                     ).
            END.
        END CASE.
    END.
  END.
END.
PROCEDURE wth-parts-raz:
    DEFINE PARAMETER BUFFER bfrom_wth-parts FOR ub.wth-parts.
    DEFINE INPUT PARAMETER p-zone AS CHAR NO-UNDO.
    DEFINE INPUT PARAMETER p-doc-del AS log NO-UNDO.
    define variable v-mes as char no-undo.
    define variable v-rec as recid no-undo.
    DEFINE BUFFER buf_wth-parts FOR ub.wth-parts.
  do
  on error undo, return error return-value
  :
    v-mes = substitute('Код серии: &1-&2 Диапазон &3-&4'
                                   ,bfrom_wth-parts.ser-code
                                   ,bfrom_wth-parts.db-num
                                   ,bfrom_wth-parts.doc-rangeFrom
                                   ,bfrom_wth-parts.doc-rangeTo).
    IF lookup(bfrom_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) > 0 THEN DO:
        RETURN ERROR substitute("Нельзя удалять партии МЦ из зоны :&1&2&3&4&5"
                             , error-status:get-message(1)
                             , bfrom_wth-parts.out-code
                             , return-value
                             ,chr(10)
                             ,v-mes
                             ).
    END.
    v-rec = recid(bfrom_wth-parts).
    CASE bfrom_wth-parts.ext-doc-type:
        WHEN 'ie':U  or when 'fj':U or when  'pj':U THEN DO:
            delete bfrom_wth-parts NO-ERROR.
            if error-status:error then do:
              return error substitute("Ошибка при удалении записи партии МЦ:&1&2&3&2&4"
                                   , error-status:get-message(1)
                                   , chr(10)
                                   , return-value
                                   ,v-mes
                                   ).
            END.
        END.
        when 'rp':U or when 'rf':U then do:
          if p-doc-del then do:
            delete bfrom_wth-parts NO-ERROR.
            if error-status:error then do:
              return error substitute("Ошибка при удалении записи партии МЦ:&1&2&3&2&4"
                                   , error-status:get-message(1)
                                   , chr(10)
                                   , return-value
                                   ,v-mes
                                   ).
            END.
          end.
          else   RETURN ERROR 'Нельзя удалять партии документа внутреннего возврата.'  .
        end.
        when 'ip':U or when 'ff':U then do:
          if p-doc-del then do:
            delete bfrom_wth-parts NO-ERROR.
            if error-status:error then do:
              return error substitute("Ошибка при удалении записи партии МЦ:&1&2&3&2&4"
                                   , error-status:get-message(1)
                                   , chr(10)
                                   , return-value
                                   ,v-mes
                                   ).
            END.
          end.
          else do:
            run str/wthpartp.p  ( INPUT     'ИЗМЕНЕНИЕ':U,
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     bfrom_wth-parts.out-code,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo   ,
                  INPUT     bfrom_wth-parts.doc-RangeFrom ,
                  INPUT     bfrom_wth-parts.doc-rangeTo  ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code ,
                  INPUT     bfrom_wth-parts.price-rubl    ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,
                  INPUT     bfrom_wth-parts.supp-code,
                  INPUT     bfrom_wth-parts.in-obj-type      ,
                  INPUT     bfrom_wth-parts.in-obj-code      ,
                  INPUT     bfrom_wth-parts.ext-doc-type,
                  INPUT     bfrom_wth-parts.gds-code,
                  INPUT     1            ,
                  INPUT     bfrom_wth-parts.beg-dt        ,
                  INPUT     bfrom_wth-parts.end-dt        ,
                  INPUT     bfrom_wth-parts.vat-pc        ,
                  INPUT     bfrom_wth-parts.cli-code,
                  INPUT     bfrom_wth-parts.cli-type,
                  INPUT     bfrom_wth-parts.out-obj-code,
                  INPUT     bfrom_wth-parts.out-obj-type,
                  INPUT     bfrom_wth-parts.sale-obj-code,
                  INPUT     bfrom_wth-parts.sale-obj-type,
                  INPUT     bfrom_wth-parts.doc-code ,
                  INPUT  yes,
                  INPUT     bfrom_wth-parts.type ,
                  INPUT-OUTPUT v-rec
                  ) no-error.
             if error-status:error then undo, return error return-value + chr(10) + error-status:get-message(1) .
          end.
        end.
        OTHERWISE DO:
         run str/wthpartp.p  ( INPUT     'ИЗМЕНЕНИЕ':U,
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     p-zone,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo   ,
                  INPUT     bfrom_wth-parts.Fact-RangeFrom ,
                  INPUT     bfrom_wth-parts.fact-rangeTo  ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code ,
                  INPUT     bfrom_wth-parts.price-rubl    ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,
                  INPUT     bfrom_wth-parts.supp-code,
                  INPUT     bfrom_wth-parts.in-obj-type      ,
                  INPUT     bfrom_wth-parts.in-obj-code      ,
                  INPUT     bfrom_wth-parts.ext-doc-type,
                  INPUT     bfrom_wth-parts.gds-code,
                  INPUT     bfrom_wth-parts.stts             ,
                  INPUT     bfrom_wth-parts.beg-dt        ,
                  INPUT     bfrom_wth-parts.end-dt        ,
                  INPUT     bfrom_wth-parts.vat-pc        ,
                  INPUT     bfrom_wth-parts.cli-code,
                  INPUT     bfrom_wth-parts.cli-type,
                  INPUT     bfrom_wth-parts.out-obj-code,
                  INPUT     bfrom_wth-parts.out-obj-type,
                  INPUT     bfrom_wth-parts.sale-obj-code,
                  INPUT     bfrom_wth-parts.sale-obj-type,
                  INPUT     bfrom_wth-parts.doc-code ,
                  INPUT  yes,
                  INPUT      "":U ,
                  INPUT-OUTPUT v-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + chr(10) + error-status:get-message(1) .
        END.
    END CASE.
  END.
END.
procedure wth-parts-rezerv:
    define input parameter        p-param            as logical no-undo.
    define input parameter        p-fact-rangeFrom   LIKE ub.wth-parts.Fact-RangeFrom no-undo .
    define input parameter        p-fact-RangeTo     LIKE ub.wth-parts.Fact-RangeTo no-undo   .
    define input parameter        p-beg-dt           LIKE ub.wth-parts.beg-dt no-undo .
    define input parameter        p-end-dt           LIKE ub.wth-parts.end-dt no-undo .
    define input parameter        p-ser-code         LIKE ub.wth-parts.ser-code no-undo.
    define input parameter        p-db-num           LIKE ub.wth-parts.db-num no-undo .
    define input parameter        p-price-rubl       LIKE ub.wth-parts.price-rubl no-undo .
    define input parameter        p-price-base       LIKE ub.wth-parts.price-base no-undo .
    define input parameter        p-vat-pc           LIKE ub.wth-parts.vat-pc no-undo .
    define input parameter        p-host-code        LIKE ub.wth-parts.host-code no-undo .
    define input parameter        p-obj-type         LIKE ub.wth-parts.obj-type no-undo .
    define input parameter        p-obj-code         LIKE ub.wth-parts.obj-code no-undo .
    define input parameter        p-w-p-code         LIKE ub.wth-parts.w-p-code no-undo .
    define input parameter        p-wth-code         LIKE ub.wth-parts.wth-code no-undo .
    define input parameter        p-par-code         LIKE ub.wth-parts.par-code no-undo .
    define input parameter        p-in-code          LIKE ub.wth-parts.in-code no-undo .
    define input parameter        p-doc-code         LIKE ub.wth-parts.out-code no-undo .
    define input parameter        p-cli-type         LIKE ub.wth-parts.cli-type no-undo .
    define input parameter        p-cli-code         LIKE ub.wth-parts.cli-code no-undo .
    define input parameter        p-ext-doc-type     LIKE ub.wth-parts.ext-doc-type no-undo .
    define input parameter        p-gds-code         LIKE ub.wth-parts.gds-code no-undo .
    define input parameter        p-type             LIKE ub.wth-parts.type no-undo .
    define input-output parameter p-rec        as recid     no-undo .
  define buffer bfrom_wth-parts   for ub.wth-parts.
  define buffer bufr_wth-doc      for ub.wth-doc.
  define variable v-rec    as recid        no-undo.
  define variable v-recDop as recid        no-undo.
  define variable v-zone   as character    no-undo.
  DEFINE variable v-beg-dt           LIKE ub.wth-parts.beg-dt no-undo .
  define VARIABLE v-end-dt           LIKE ub.wth-parts.end-dt no-undo .
  define variable v-price-rubl       LIKE ub.wth-parts.price-rubl no-undo .
  define variable v-price-base       LIKE ub.wth-parts.price-base no-undo .
  define variable v-vat-pc           LIKE ub.wth-parts.vat-pc no-undo .
  define variable v-mpl-date         as date      no-undo.
  empty temp-table tt-wthlib-parts.
main-block:
do  transaction
on error  undo main-block, return error return-value + chr(32) + error-status:get-message(1)
on stop   undo main-block, return error
on endkey undo main-block, return error
:
FIND FIRST bufr_wth-doc WHERE bufr_wth-doc.doc-code = p-doc-code NO-LOCK NO-ERROR.
IF NOT AVAILABLE bufr_wth-doc THEN RETURN ERROR SUBSTITUTE('Не найден документ МЦ с номером &1',p-doc-code).
  if lookup(p-ext-doc-type,'ie,ip,rp,fj,pj,ff,rf':U) > 0
        then do:
     run str/wthpartp.p  ( INPUT 'ДОБАВЛЕНИЕ':U,
                  INPUT  p-obj-type,
                  INPUT  p-obj-code,
                  INPUT  p-w-p-code,
                  INPUT  p-wth-code,
                  INPUT  p-par-code,
                  INPUT  p-in-code,
                  INPUT  p-doc-code,
                  INPUT  p-ser-code,
                  INPUT  p-db-num  ,
                  INPUT  p-Fact-RangeFrom ,
                  INPUT  p-fact-rangeTo  ,
                  INPUT  p-Fact-RangeFrom ,
                  INPUT  p-fact-rangeTo ,
                  INPUT  p-host-code     ,
                  INPUT  0   ,
                  INPUT  p-price-rubl    ,
                  INPUT  p-price-base    ,
                  INPUT  '':U,
                  INPUT  0,
                  INPUT  p-obj-type      ,
                  INPUT  p-obj-code      ,
                  INPUT  p-ext-doc-type,
                  INPUT  p-gds-code,
                  INPUT  0           ,
                  INPUT  p-beg-dt        ,
                  INPUT  p-end-dt        ,
                  INPUT  p-vat-pc      ,
                  INPUT  0,
                  INPUT  '':U,
                  INPUT  0,
                  INPUT  '':U,
                  INPUT  0,
                  INPUT  '':U,
                  INPUT  p-doc-code,
                  INPUT  yes,
                  INPUT p-type,
                  INPUT-OUTPUT p-rec
                  ) no-error.
                if error-status:error then undo main-block, return error return-value + error-status:get-message(1) .
  end.
  else do:
    if p-rec <> ? then do:
      find first bfrom_wth-parts exclusive-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      if  available bfrom_wth-parts
        and bfrom_wth-parts.wth-code = p-wth-code
        and bfrom_wth-parts.par-code = p-par-code
        and bfrom_wth-parts.ser-code = p-ser-code
        and lookup(bfrom_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) > 0
      then.
      else if  available bfrom_wth-parts and lookup(bfrom_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0
      then return error substitute('Резервирование из партии (Код серии: &1-&2 Диапазон &3-&4) невозможно, т.к. партия уже входит в состав документа'
                                   ,bfrom_wth-parts.ser-code
                                   ,bfrom_wth-parts.db-num
                                   ,bfrom_wth-parts.doc-rangeFrom
                                   ,bfrom_wth-parts.doc-rangeTo).
      else if  available bfrom_wth-parts then undo, return error 'Партия указанная для резервирования не соответсвует указанным параметрам!'.
      if available bfrom_wth-parts
         and bfrom_wth-parts.doc-rangeFrom > p-fact-rangeFrom
         or bfrom_wth-parts.doc-rangeTo   < p-fact-rangeTo
      then undo, return error substitute('Нельзя увеличивать границы диапазона.&1Диапазон партии &2-&3.&1Диапазон резервирования &4-&5'
                                         ,chr(10)
                                         ,bfrom_wth-parts.doc-rangeFrom
                                         ,bfrom_wth-parts.doc-rangeTo
                                         ,p-fact-rangeFrom
                                         ,p-fact-rangeTo).
    end.
    else do:
      if p-ext-doc-type = 'pz':U or (p-ext-doc-type = 'xc':U and p-type = 'при':U )then do:
        for first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = 'cli-zone':U
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and bfrom_wth-parts.cli-code = p-cli-code
                              and bfrom_wth-parts.cli-type = p-cli-type
                              and (IF p-in-code > '':U then bfrom_wth-parts.in-code = p-in-code else true)
                              use-index  wth-idnt:
                              p-rec = recid(bfrom_wth-parts).
         end.
        If p-rec = ? and p-in-code > '' then do:
           for first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = 'cli-zone':U
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and bfrom_wth-parts.cli-code = p-cli-code
                              and bfrom_wth-parts.cli-type = p-cli-type
                              use-index  wth-idnt:
                              p-rec = recid(bfrom_wth-parts).
              end.
        end.
              if p-rec <> ? then  find first bfrom_wth-parts no-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      end.
      else if p-ext-doc-type = 'pc':U or p-ext-doc-type = 'ps':U or p-ext-doc-type = 'dc':U then do:
        for first bfrom_wth-parts no-lock where bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = 'cli-zone':U
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and (IF p-in-code > '':U then bfrom_wth-parts.in-code = p-in-code else true)
                              use-index wth-idnt:
                              p-rec = recid(bfrom_wth-parts).
         end.
        If p-rec = ? and p-in-code > '' then do:
         for first bfrom_wth-parts no-lock where bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = 'cli-zone':U
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              :
                              p-rec = recid(bfrom_wth-parts).
         end.
        end.
        if p-rec <> ? then  find first bfrom_wth-parts no-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      end.
      else do:
        CASE p-ext-doc-type:
                WHEN 'ee':U or when 'xc':U or WHEN 'ef':U
                or when 'jj':U THEN DO:
                    v-zone = 'free-zone':U.
                END.
                WHEN 'ep':U or when 'oj':U THEN DO:
                    v-zone = 'put-zone':U.
                END.
                WHEN 'df':U THEN DO:
                    v-zone = 'free-zone':U.
                END.
                WHEN 'dp':U  THEN DO:
                    v-zone = 'put-zone':U.
                END.
                WHEN 'pc':U OR WHEN 'ps':U OR WHEN 'pz':U OR WHEN 'dc':U THEN DO:
                    v-zone = 'cli-zone':U.
                END.
                OTHERWISE DO:
                    RETURN ERROR substitute("Неверный вызов процедуры резервирования: расш. тип = &1"
                                         , p-ext-doc-type
                                            ).
                END.
        END CASE.
        find first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.obj-code = p-obj-code
                              and bfrom_wth-parts.obj-type = p-obj-type
                              and bfrom_wth-parts.w-p-code = p-w-p-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = v-zone
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              and (IF p-in-code > '':U then bfrom_wth-parts.in-code = p-in-code else true)
                              no-error.
       If not available bfrom_wth-parts and p-in-code > '' then do:
               find first bfrom_wth-parts no-lock where
                                  bfrom_wth-parts.wth-code = p-wth-code
                              and bfrom_wth-parts.obj-code = p-obj-code
                              and bfrom_wth-parts.obj-type = p-obj-type
                              and bfrom_wth-parts.w-p-code = p-w-p-code
                              and bfrom_wth-parts.par-code = p-par-code
                              and bfrom_wth-parts.ser-code = p-ser-code
                              and bfrom_wth-parts.db-num = p-db-num
                              and bfrom_wth-parts.out-code = v-zone
                              and bfrom_wth-parts.fact-rangeFrom <= p-fact-rangeFrom
                              and bfrom_wth-parts.fact-rangeTo >= p-fact-rangeTo
                              and bfrom_wth-parts.stts = 0
                              no-error.
       end.
      end.
    end.
    if not available bfrom_wth-parts then do:
         if g#news then do:
          return error 'forged':U.
         end.
         else
          undo, return error substitute("Не найдена партия МЦ для резервирования &1Код МЦ &2&1Код номинала &3&1Код серии &4&1Диапазон с &5 по &6&1
                                        ",chr(10),p-wth-code,p-par-code,p-ser-code,p-fact-rangeFrom,
                                        p-fact-rangeTo).
    end.
    p-rec = recid(bfrom_wth-parts).
    find current bfrom_wth-parts exclusive-lock.
    create tt-wthlib-parts.
    buffer-copy bfrom_wth-parts to tt-wthlib-parts.
        ASSIGN v-beg-dt = if p-param then p-beg-dt else bfrom_wth-parts.beg-dt
               v-end-dt = if p-param then p-end-dt else bfrom_wth-parts.end-dt
               v-vat-pc = if p-param then p-vat-pc else bfrom_wth-parts.vat-pc
               v-price-rubl = if p-param then p-price-rubl else bfrom_wth-parts.price-rubl
               v-price-base = if p-param then p-price-base else bfrom_wth-parts.price-base  .
    IF  not g#news and (p-ext-doc-type = 'ee':U or p-ext-doc-type = 'xc':U)  THEN DO:
        IF v-beg-dt = ? AND v-end-dt = ? THEN DO:
            RUN init_prtdate ( INPUT p-obj-type
                                              ,INPUT p-obj-code
                                              ,INPUT p-ser-code
                                              ,INPUT p-db-num
                                              ,INPUT bufr_wth-doc.doc-date
                                              ,OUTPUT v-beg-dt
                                              ,OUTPUT v-end-dt ) NO-ERROR.
            if error-status:error then undo, return error return-value + error-status:get-message(1) .
        END.
        IF v-price-rubl = 0 AND v-price-base = 0 THEN DO:
          run set-wthmpl-date ( bufr_wth-doc.doc-code
                             ,bufr_wth-doc.doc-date
                             , v-beg-dt
                             , output v-mpl-date) no-error.
            RUN INIT_prtprice (
                          p-host-code
                        , p-obj-type
                        , p-obj-code
                        , p-cli-type
                        , p-cli-code
                        , p-wth-code
                        , p-gds-code
                        , p-par-code
                        , v-mpl-date
                        , OUTPUT  v-vat-pc
                        , OUTPUT  v-price-rubl
                        , OUTPUT  v-price-base
                ) NO-ERROR.
          if error-status:error then undo, return error return-value + error-status:get-message(1) .
        END.
    END.
      run str/wthpartp.p  ( INPUT     'ИЗМЕНЕНИЕ':U,
                  INPUT     p-obj-type,
                  INPUT     p-obj-code,
                  INPUT     p-w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     p-doc-code,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code               ,
                  INPUT     v-price-rubl ,
                  INPUT     v-price-base  ,
                  INPUT     bfrom_wth-parts.supp-type,
                  INPUT     bfrom_wth-parts.supp-code,
                  INPUT     bfrom_wth-parts.in-obj-type      ,
                  INPUT     bfrom_wth-parts.in-obj-code      ,
                  INPUT     p-ext-doc-type,
                  INPUT     bfrom_wth-parts.gds-code,
                  INPUT     0              ,
                  INPUT     v-beg-dt    ,
                  INPUT     v-end-dt   ,
                  INPUT     v-vat-pc    ,
                  INPUT     bfrom_wth-parts.cli-code,
                  INPUT     bfrom_wth-parts.cli-type,
                  INPUT     bfrom_wth-parts.out-obj-code,
                  INPUT     bfrom_wth-parts.out-obj-type,
                  INPUT     bfrom_wth-parts.sale-obj-code,
                  INPUT     bfrom_wth-parts.sale-obj-type,
                  INPUT     bfrom_wth-parts.doc-code,
                  INPUT     yes,
                  INPUT     p-type,
                  INPUT-OUTPUT p-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    if tt-wthlib-parts.fact-rangeFrom <> p-fact-rangeFrom then do:
    run str/wthpartp.p ( INPUT     'ДОБАВЛЕНИЕ':U,
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,
                  INPUT     tt-wthlib-parts.supp-code,
                  INPUT     tt-wthlib-parts.in-obj-type      ,
                  INPUT     tt-wthlib-parts.in-obj-code      ,
                  INPUT     tt-wthlib-parts.ext-doc-type,
                  INPUT     tt-wthlib-parts.gds-code,
                  INPUT     tt-wthlib-parts.stts               ,
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,
                  INPUT     tt-wthlib-parts.cli-type,
                  INPUT     tt-wthlib-parts.out-obj-code,
                  INPUT     tt-wthlib-parts.out-obj-type,
                  INPUT     tt-wthlib-parts.sale-obj-code,
                  INPUT     tt-wthlib-parts.sale-obj-type,
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT  yes,
                  INPUT    tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    end.
    if tt-wthlib-parts.fact-rangeTo <> p-fact-rangeTo then do:
            run str/wthpartp.p    ( INPUT 'ДОБАВЛЕНИЕ':U,
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,
                  INPUT     tt-wthlib-parts.supp-code,
                  INPUT     tt-wthlib-parts.in-obj-type      ,
                  INPUT     tt-wthlib-parts.in-obj-code      ,
                  INPUT     tt-wthlib-parts.ext-doc-type,
                  INPUT     tt-wthlib-parts.gds-code,
                  INPUT     tt-wthlib-parts.stts               ,
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,
                  INPUT     tt-wthlib-parts.cli-type,
                  INPUT     tt-wthlib-parts.out-obj-code,
                  INPUT     tt-wthlib-parts.out-obj-type,
                  INPUT     tt-wthlib-parts.sale-obj-code,
                  INPUT     tt-wthlib-parts.sale-obj-type,
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT     yes,
                  INPUT     tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.
      if error-status:error then undo, return error return-value + error-status:get-message(1) .
    end.
  end.
end.
end procedure.
procedure wth-parts-inter-edit:
  define input parameter        p-fact-rangeFrom   LIKE ub.wth-parts.Fact-RangeFrom no-undo .
  define input parameter        p-fact-RangeTo     LIKE ub.wth-parts.Fact-RangeTo no-undo   .
  define input-output parameter p-rec        as recid     no-undo .
  define buffer bfrom_wth-parts   for ub.wth-parts.
  define variable v-recDop as recid        no-undo.
  do on error undo, return error:
      find first bfrom_wth-parts exclusive-lock where
                recid(bfrom_wth-parts) = p-rec no-error.
      if not available bfrom_wth-parts then return error
        substitute('Не найдена партия (recid &1)', p-rec).
      if p-fact-rangeFrom < bfrom_wth-parts.doc-rangeFrom or
         p-fact-rangeTo > bfrom_wth-parts.doc-rangeTo then do:
         return error 'Нельзя увеличивать границы диапазона.'.
      end.
      empty temp-table tt-wthlib-parts.
      create tt-wthlib-parts.
      buffer-copy bfrom_wth-parts to tt-wthlib-parts.
      run str/wthpartp.p  ( INPUT     'ИЗМЕНЕНИЕ':U,
                  INPUT     bfrom_wth-parts.obj-type,
                  INPUT     bfrom_wth-parts.obj-code,
                  INPUT     bfrom_wth-parts.w-p-code,
                  INPUT     bfrom_wth-parts.wth-code,
                  INPUT     bfrom_wth-parts.par-code,
                  INPUT     bfrom_wth-parts.in-code ,
                  INPUT     bfrom_wth-parts.doc-code,
                  INPUT     bfrom_wth-parts.ser-code,
                  INPUT     bfrom_wth-parts.db-num  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo  ,
                  INPUT     p-Fact-RangeFrom ,
                  INPUT     p-fact-rangeTo ,
                  INPUT     bfrom_wth-parts.host-code     ,
                  INPUT     bfrom_wth-parts.contract-code               ,
                  INPUT     bfrom_wth-parts.price-rubl  ,
                  INPUT     bfrom_wth-parts.price-base    ,
                  INPUT     bfrom_wth-parts.supp-type,
                  INPUT     bfrom_wth-parts.supp-code,
                  INPUT     bfrom_wth-parts.in-obj-type      ,
                  INPUT     bfrom_wth-parts.in-obj-code      ,
                  INPUT     bfrom_wth-parts.ext-doc-type,
                  INPUT     bfrom_wth-parts.gds-code,
                  INPUT     0              ,
                  INPUT     bfrom_wth-parts.beg-dt      ,
                  INPUT     bfrom_wth-parts.end-dt      ,
                  INPUT     bfrom_wth-parts.vat-pc      ,
                  INPUT     bfrom_wth-parts.cli-code,
                  INPUT     bfrom_wth-parts.cli-type,
                  INPUT     bfrom_wth-parts.out-obj-code,
                  INPUT     bfrom_wth-parts.out-obj-type,
                  INPUT     bfrom_wth-parts.sale-obj-code,
                  INPUT     bfrom_wth-parts.sale-obj-type,
                  INPUT     bfrom_wth-parts.doc-code,
                  INPUT     yes,
                  INPUT     bfrom_wth-parts.type,
                  INPUT-OUTPUT p-rec
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    if tt-wthlib-parts.fact-rangeFrom <> p-fact-rangeFrom then do:
    run str/wthpartp.p ( INPUT     'ДОБАВЛЕНИЕ':U,
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1  ,
                  INPUT     tt-wthlib-parts.Fact-RangeFrom ,
                  INPUT     p-fact-rangeFrom - 1,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,
                  INPUT     tt-wthlib-parts.supp-code,
                  INPUT     tt-wthlib-parts.in-obj-type      ,
                  INPUT     tt-wthlib-parts.in-obj-code      ,
                  INPUT     tt-wthlib-parts.ext-doc-type,
                  INPUT     tt-wthlib-parts.gds-code,
                  INPUT     1             ,
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,
                  INPUT     tt-wthlib-parts.cli-type,
                  INPUT     tt-wthlib-parts.out-obj-code,
                  INPUT     tt-wthlib-parts.out-obj-type,
                  INPUT     tt-wthlib-parts.sale-obj-code,
                  INPUT     tt-wthlib-parts.sale-obj-type,
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT  yes,
                  INPUT    tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.
    if error-status:error then undo, return error return-value + error-status:get-message(1) .
    end.
    if tt-wthlib-parts.fact-rangeTo <> p-fact-rangeTo then do:
            run str/wthpartp.p    ( INPUT 'ДОБАВЛЕНИЕ':U,
                  INPUT     tt-wthlib-parts.obj-type,
                  INPUT     tt-wthlib-parts.obj-code,
                  INPUT     tt-wthlib-parts.w-p-code,
                  INPUT     tt-wthlib-parts.wth-code,
                  INPUT     tt-wthlib-parts.par-code,
                  INPUT     tt-wthlib-parts.in-code ,
                  INPUT     tt-wthlib-parts.out-code,
                  INPUT     tt-wthlib-parts.ser-code,
                  INPUT     tt-wthlib-parts.db-num  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo  ,
                  INPUT     p-fact-rangeTo + 1 ,
                  INPUT     tt-wthlib-parts.fact-rangeTo,
                  INPUT     tt-wthlib-parts.host-code     ,
                  INPUT     tt-wthlib-parts.contract-code               ,
                  INPUT     tt-wthlib-parts.price-rubl    ,
                  INPUT     tt-wthlib-parts.price-base    ,
                  INPUT     tt-wthlib-parts.supp-type,
                  INPUT     tt-wthlib-parts.supp-code,
                  INPUT     tt-wthlib-parts.in-obj-type      ,
                  INPUT     tt-wthlib-parts.in-obj-code      ,
                  INPUT     tt-wthlib-parts.ext-doc-type,
                  INPUT     tt-wthlib-parts.gds-code,
                  INPUT     1             ,
                  INPUT     tt-wthlib-parts.beg-dt        ,
                  INPUT     tt-wthlib-parts.end-dt        ,
                  INPUT     tt-wthlib-parts.vat-pc        ,
                  INPUT     tt-wthlib-parts.cli-code,
                  INPUT     tt-wthlib-parts.cli-type,
                  INPUT     tt-wthlib-parts.out-obj-code,
                  INPUT     tt-wthlib-parts.out-obj-type,
                  INPUT     tt-wthlib-parts.sale-obj-code,
                  INPUT     tt-wthlib-parts.sale-obj-type,
                  INPUT     tt-wthlib-parts.doc-code,
                  INPUT     yes,
                  INPUT     tt-wthlib-parts.type,
                  INPUT-OUTPUT v-recDop
                  ) no-error.
      if error-status:error then undo, return error return-value + error-status:get-message(1) .
      end.
  end.
end procedure.
PROCEDURE INIT_prtdate:
    define input parameter        p-obj-type         LIKE ub.wth-parts.obj-type no-undo .
    define input parameter        p-obj-code         LIKE ub.wth-parts.obj-code no-undo .
    define input parameter        p-ser-code         LIKE ub.wth-parts.ser-code no-undo.
    define input parameter        p-db-num           LIKE ub.wth-parts.db-num no-undo .
    define input parameter        p-date                AS DATE no-undo .
    DEFINE OUTPUT PARAMETER p-beg-dt AS DATE NO-UNDO.
    DEFINE OUTPUT PARAMETER p-end-dt AS DATE NO-UNDO.
    DEFINE BUFFER buf_wth-ser FOR ub.wth-ser.
    DEFINE VARIABLE v-rangeRule AS INT NO-UNDO.
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-param-type as character no-undo .
    FIND FIRST buf_wth-ser NO-LOCK
        WHERE buf_wth-ser.ser-code = p-ser-code
        AND buf_wth-ser.db-num = p-db-num.
    IF buf_wth-ser.chk-bdt = 2 THEN DO:
        p-beg-dt = buf_wth-ser.beg-dt.
    END.
    IF buf_wth-ser.chk-edt = 2 THEN DO:
        p-end-dt = buf_wth-ser.end-dt.
    END.
    IF buf_wth-ser.chk-bdt = 0 AND buf_wth-ser.chk-edt = 0 THEN DO:
        run adm/shattri.p (
            input "get":U
            ,input  p-obj-type
            ,input  p-obj-code
            ,input  'wthdoc_obj':U
            ,input  'rangerule':U
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error .
        IF not error-status:error  then do:
            v-rangeRule =  v-value-integer.
        END.
        CASE v-rangeRule:
        WHEN 1 THEN DO:
            IF MONTH(p-date) < 11 THEN ASSIGN p-beg-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 1,YEAR(p-date)))
                                              p-end-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 2,YEAR(p-date))) - 1.
            ELSE IF MONTH(p-date) = 11 THEN ASSIGN p-beg-dt = DATE(substitute('01/12/&1',YEAR(p-date)))
                                              p-end-dt = DATE(substitute('31/12/&1',YEAR(p-date) + 1)).
            ELSE IF MONTH(p-date) = 12 THEN ASSIGN p-beg-dt = DATE(substitute('01/01/&1',YEAR(p-date) + 1))
                                              p-end-dt = DATE(substitute('31/01/&1',YEAR(p-date) + 1)).
        END.
        when 2 then do:
          IF MONTH(p-date) = 12 THEN ASSIGN p-beg-dt = DATE(substitute('&1/12/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('31/12/&1',YEAR(p-date))).
          else ASSIGN p-beg-dt = DATE(substitute('&3/&1/&2',MONTH(p-date),YEAR(p-date),day(p-date)))
                      p-end-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 1,YEAR(p-date))) - 1
                     .
        end.
        WHEN 3 THEN DO:
            IF MONTH(p-date) < 10 THEN ASSIGN p-beg-dt = DATE(substitute('&1/&2/&3',day(p-date),MONTH(p-date),YEAR(p-date)))
                                              p-end-dt = DATE(substitute('01/&1/&2',MONTH(p-date) + 3,YEAR(p-date))) - 1.
            else if MONTH(p-date) = 10 THEN ASSIGN p-beg-dt = DATE(substitute('&1/10/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('31/12/&1',YEAR(p-date))).
            else if MONTH(p-date) = 11 THEN ASSIGN p-beg-dt = DATE(substitute('&1/11/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('31/01/&1',YEAR(p-date) + 1)).
            else if MONTH(p-date) = 12 THEN ASSIGN p-beg-dt = DATE(substitute('&1/12/&2',day(p-date),YEAR(p-date)))
                                            p-end-dt = DATE(substitute('01/03/&1',YEAR(p-date) + 1)) - 1.
        END.
        when 4 then do:
             p-beg-dt = p-date.
             p-end-dt = date(substitute('31/12/&1',YEAR(p-date))).
        end.
        END CASE.
    END.
END.
PROCEDURE INIT_prtprice:
define input parameter        p-host-code        LIKE ub.wth-parts.obj-type no-undo .
define input parameter        p-obj-type         LIKE ub.wth-parts.obj-type no-undo .
define input parameter        p-obj-code         LIKE ub.wth-parts.obj-code no-undo .
define input parameter        p-cli-type         LIKE ub.wth-parts.cli-type no-undo .
define input parameter        p-cli-code         LIKE ub.wth-parts.cli-code no-undo .
define input parameter        p-wth-code         LIKE ub.wth-parts.ser-code no-undo.
define input parameter        p-gds-code         LIKE ub.wth-parts.gds-code no-undo .
define input parameter        p-par-code         LIKE ub.wth-parts.par-code no-undo .
define input parameter        p-date                AS DATE no-undo .
DEFINE OUTPUT PARAMETER p-vat-pc LIKE ub.wth-parts.vat-pc NO-UNDO.
DEFINE OUTPUT PARAMETER p-price-rubl LIKE ub.wth-parts.price-rubl NO-UNDO.
DEFINE OUTPUT PARAMETER p-price-base LIKE ub.wth-parts.price-base NO-UNDO.
DEFINE BUFFER b-cash-pay FOR ub.cash-pay.
DEFINE BUFFER b-wth-par FOR ub.wth-par.
DEF VAR v-cash-type-pay AS CHAR no-undo.
define variable p-plt-id AS INT no-undo.
define variable  p-plt-db-num   AS INT no-undo.
define variable  p-pdf-id  AS INT no-undo.
define variable  p-pdf-db-num AS INT no-undo.
define variable  p-sale-price-base AS DEC no-undo.
define variable  p-sale-price-rubl AS DEC no-undo.
define variable  p-road-tax-base AS DEC no-undo.
define variable  p-road-tax-rubl AS DEC no-undo.
define variable  p-excise-base AS DEC no-undo.
define variable  p-excise-rubl AS DEC no-undo.
define variable  p-fact-order  AS DEC no-undo.
do on error undo, return error return-value :
  FIND FIRST b-wth-par NO-LOCK WHERE b-wth-par.par-code = p-par-code
                                  AND b-wth-par.wth-code = p-wth-code NO-ERROR.
  IF NOT AVAILABLE b-wth-par THEN RETURN ERROR SUBSTITUTE("Не наден номинал с кодом &1",p-par-code).
  FIND FIRST b-cash-pay WHERE b-cash-pay.wth-code = p-wth-code NO-LOCK NO-ERROR.
  IF AVAILABLE b-cash-pay THEN v-cash-type-pay = STRING(recid(b-cash-pay)).
  ELSE v-cash-type-pay = ?.
  run fact-order-mpl (
      INPUT p-date ,
      INPUT p-obj-type ,
      INPUT p-obj-code ,
      OUTPUT p-fact-order
      ) no-error .
  if error-status:error then do:
    message   return-value skip error-status:get-message(1)
    skip  'Получение цены из множественного прайс-листа отклонено.'
    view-as alert-box.
    return.
  end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output p-vat-pc
  ) no-error .
  run mpl-autoprice in this-procedure
    ( input    false
      ,input   p-cli-type
      ,input   p-cli-code
      ,input   p-gds-code
      ,input   p-gds-code
      ,input   p-obj-type
      ,input   p-obj-code
      ,input   0
      ,input   0
      ,input   ""
      ,input   v-cash-type-pay
      ,input   p-fact-order
      ,output  p-plt-id
      ,output  p-plt-db-num
      ,output  p-pdf-id
      ,output  p-pdf-db-num
      ,output  p-sale-price-base
      ,output  p-sale-price-rubl
      ,output  p-road-tax-base
      ,output  p-road-tax-rubl
      ,output  p-excise-base
      ,output  p-excise-rubl
      ) no-error .
  if error-status:error then do:
    message   return-value skip error-status:get-message(1) view-as alert-box.
    return.
  end.
  p-price-rubl = p-sale-price-rubl * b-wth-par.par-val.
  p-price-base = p-sale-price-base * b-wth-par.par-val.
end.
END.
procedure  set-wthmpl-date:
define input parameter p-doc-code like ub.wth-doc.doc-code no-undo.
define input parameter p-doc-date like ub.wth-doc.doc-date no-undo.
define input parameter p-beg-dt   like ub.wth-parts.beg-dt no-undo.
define output parameter p-date    like ub.wth-doc.doc-date no-undo.
define variable v-atrValue      as character no-undo .
define variable v-atrDsf      as CHARACTER no-undo .
define variable v-atrType     as character no-undo .
do on error undo, return error return-value :
if valid-handle( g#wthcalib ) <> yes then do:       run str/wthcalib.p persistent no-error.       if error-status :error or valid-handle( g#wthcalib ) <> yes then do:         message "Error starting wthcalib.p"    skip( 0 )                 g#wthcalib                     skip( 0 )                 g#wthcalib   :type             skip( 0 )                 g#wthcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run wthcalib_wthat-val in g#wthcalib (  input p-doc-code ,
                        input 'wthdsf':U ,
                       output v-atrValue ,
                       output v-atrType )  .
  p-date = date(v-atrValue) no-error.
  if p-date = ? then p-date = p-beg-dt no-error.
  if p-date = ? then p-date = p-doc-date.
end.
end procedure.
define temp-table tt-parts-cli    no-undo like ub.arh-wth-cli
 .
define temp-table tt-parts-cli-tot    no-undo like ub.arh-wth-cli-tot
 .
define temp-table tt-parts-cli-doc no-undo like ub.arh-wth-cli-doc
.
define temp-table tt-parts-tot    no-undo like ub.arh-wth-tot.
define temp-table tt-parts-wp     no-undo like ub.arh-wth-w-p.
define buffer buf-prev_arh-wth-cli   for ub.arh-wth-cli.
define buffer buf-arh-wth-cli        for ub.arh-wth-cli.
define buffer buf-recalc-cli         for ub.arh-wth-cli.
define buffer buf-prev_arh-wth-cli-doc   for ub.arh-wth-cli-doc.
define buffer buf-arh-wth-cli-doc    for ub.arh-wth-cli-doc.
define buffer buf-recalc-cli-doc     for ub.arh-wth-cli-doc.
define buffer buf-prev_arh-wth-tot   for ub.arh-wth-tot.
define buffer buf-arh-wth-tot        for ub.arh-wth-tot.
define buffer buf-recalc-tot         for ub.arh-wth-tot.
define buffer buf-prev_arh-wth-wp    for ub.arh-wth-w-p.
define buffer buf-arh-wth-wp         for ub.arh-wth-w-p.
define buffer buf-recalc-wp          for ub.arh-wth-w-p.
define buffer buf-arh_wth-doc        for ub.wth-doc.
define buffer buf-prev_arh-wth-cli-tot   for ub.arh-wth-cli-tot.
define buffer buf-arh-wth-cli-tot        for ub.arh-wth-cli-tot.
define buffer buf-recalc-cli-tot         for ub.arh-wth-cli-tot.
procedure wth-arh-mode:
  define input  parameter parext-doc-type like ub.wth-doc.ext-doc-type no-undo.
  define input  parameter pardoc-code like ub.wth-doc.doc-code no-undo.
  define output parameter parinc-exp      as   integer                 no-undo.
  define buffer buf_wth-parts   for ub.wth-parts.
  case parext-doc-type:
    when 'ee':U
    or when 'pc':U
    or when 'ps':U
    or when 'pz':U
    or when 'dc':U
    or when 'xc':U
    then do:
      if can-find(first buf_wth-parts where buf_wth-parts.out-code = pardoc-code)
      then parinc-exp = 1.
      else parinc-exp = 0.
    end.
  end case.
end procedure.
 procedure wth-arh-calctt-loc:
  define input parameter pardoc-code as char no-undo.
  define input parameter par-lock as log no-undo.
  define var vararh-mode as int no-undo.
  define buffer buf_wth-parts   for ub.wth-parts.
  define variable v-cli-type    as character    no-undo.
  define variable v-cli-code    as integer      no-undo.
  define variable v-zone        as character    no-undo.
  do on error undo, return error substitute ("Создание архивов по документу &4 &1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2),pardoc-code) :
  find first buf-arh_wth-doc where buf-arh_wth-doc.doc-code = pardoc-code no-lock no-error.
  if not available buf-arh_wth-doc then do:
    return error substitute ("Не найден документ МЦ с номером &1.", pardoc-code).
  end.
  run wth-arh-mode(input buf-arh_wth-doc.ext-doc-type
          ,input buf-arh_wth-doc.doc-code
          ,output vararh-mode).
  empty temp-table tt-parts-cli.
  empty temp-table tt-parts-cli-tot.
  empty temp-table tt-parts-wp.
  empty temp-table tt-parts-cli-doc.
  empty temp-table tt-parts-tot   .
  for each buf_wth-parts no-lock where
           buf_wth-parts.out-code = pardoc-code
       and buf_wth-parts.stts = 0 :
   if  not g#news
       or (g#news and  g#db-num  = 0)
   then do:
      find first tt-parts-tot where
                tt-parts-tot.wth-code = buf_wth-parts.wth-code
            and tt-parts-tot.par-code = buf_wth-parts.par-code
            and tt-parts-tot.obj-type = buf_wth-parts.obj-type
            and tt-parts-tot.obj-code = buf_wth-parts.obj-code
            and tt-parts-tot.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
            no-error.
      if not available tt-parts-tot then do:
        create tt-parts-tot.
        assign tt-parts-tot.wth-code = buf_wth-parts.wth-code
              tt-parts-tot.par-code = buf_wth-parts.par-code
              tt-parts-tot.gds-code = buf_wth-parts.gds-code
              tt-parts-tot.w-p-code = buf_wth-parts.w-p-code
              tt-parts-tot.obj-type = buf_wth-parts.obj-type
              tt-parts-tot.obj-code = buf_wth-parts.obj-code
              tt-parts-tot.ext-doc-type = buf_wth-parts.ext-doc-type
              tt-parts-tot.doc-code = buf_wth-parts.out-code
              tt-parts-tot.host-code = buf_wth-parts.host-code
              tt-parts-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
      if buf-arh_wth-doc.doc-type = 'при':U or (buf-arh_wth-doc.doc-type = 'обмен':U and  buf_wth-parts.type = 'при':U) or  buf_wth-parts.type = 'возврат':U then      assign tt-parts-tot.in-qnty     = tt-parts-tot.in-qnty     + buf_wth-parts.fact-qnty            tt-parts-tot.in-sum-rubl = tt-parts-tot.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl           tt-parts-tot.in-sum-base = tt-parts-tot.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .    else   assign tt-parts-tot.out-qnty  = tt-parts-tot.out-qnty + buf_wth-parts.fact-qnty                               tt-parts-tot.out-sum-rubl = tt-parts-tot.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl            tt-parts-tot.out-sum-base = tt-parts-tot.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .
      if lookup(buf-arh_wth-doc.ext-doc-type,'ie,ff,rf':U) > 0
      or (buf-arh_wth-doc.ext-doc-type = 'xc':U  and buf_wth-parts.type = 'рас':U)
      or lookup (buf-arh_wth-doc.ext-doc-type,'ee,ef,df':u) > 0 then
      v-zone = 'free-zone':U.
      else if lookup(buf-arh_wth-doc.ext-doc-type,'ip,pc,ps,pz,rp':u) > 0
      or (buf-arh_wth-doc.ext-doc-type = 'xc':U  and buf_wth-parts.type = 'при':U)
      or lookup (buf-arh_wth-doc.ext-doc-type,'ep,dp':u) > 0 then
      v-zone = 'put-zone':U.
      if v-zone = 'free-zone':U or  v-zone = 'put-zone':U then do:
        find first tt-parts-wp where
                  tt-parts-wp.obj-type = buf_wth-parts.obj-type
              and tt-parts-wp.obj-code = buf_wth-parts.obj-code
              and tt-parts-wp.w-p-code = buf_wth-parts.w-p-code
              and tt-parts-wp.wth-code = buf_wth-parts.wth-code
              and tt-parts-wp.par-code = buf_wth-parts.par-code
              and tt-parts-wp.out-code = v-zone
              no-error.
        if not available tt-parts-wp then do:
          create tt-parts-wp.
          assign tt-parts-wp.wth-code = buf_wth-parts.wth-code
                tt-parts-wp.par-code = buf_wth-parts.par-code
                tt-parts-wp.gds-code = buf_wth-parts.gds-code
                tt-parts-wp.w-p-code = buf_wth-parts.w-p-code
                tt-parts-wp.obj-type = buf_wth-parts.obj-type
                tt-parts-wp.obj-code = buf_wth-parts.obj-code
                tt-parts-wp.out-code = v-zone
                tt-parts-wp.ext-doc-type = buf_wth-parts.ext-doc-type
                tt-parts-wp.doc-code = buf_wth-parts.out-code
                tt-parts-wp.host-code = buf_wth-parts.host-code
          .
        end.
        if buf-arh_wth-doc.doc-type = 'при':U or (buf-arh_wth-doc.doc-type = 'обмен':U and  buf_wth-parts.type = 'при':U) then
    assign tt-parts-wp.in-qnty     = tt-parts-wp.in-qnty     + buf_wth-parts.fact-qnty
           tt-parts-wp.in-sum-rubl = tt-parts-wp.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-wp.in-sum-base = tt-parts-wp.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .
    else   assign tt-parts-wp.out-qnty  = tt-parts-wp.out-qnty + buf_wth-parts.fact-qnty
           tt-parts-wp.out-sum-rubl = tt-parts-wp.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-wp.out-sum-base = tt-parts-wp.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .
      end.
    end.
    if vararh-mode = 1 then do:
      if buf_wth-parts.in-code = 'фальшивый':U then
      assign v-cli-type = '':U
             v-cli-code = 0.
      else assign v-cli-type = buf_wth-parts.cli-type
             v-cli-code = buf_wth-parts.cli-code.
      find first tt-parts-cli where
                tt-parts-cli.wth-code = buf_wth-parts.wth-code
            and tt-parts-cli.par-code = buf_wth-parts.par-code
            and tt-parts-cli.ser-code = buf_wth-parts.ser-code
            and tt-parts-cli.db-num   = buf_wth-parts.db-num
            and tt-parts-cli.cli-type = v-cli-type
            and tt-parts-cli.cli-code = v-cli-code
            and tt-parts-cli.obj-type = buf_wth-parts.obj-type
            and tt-parts-cli.obj-code = buf_wth-parts.obj-code
            and tt-parts-cli.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-cli.gds-code = buf_wth-parts.gds-code
            and tt-parts-cli.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
            no-error.
      if not available tt-parts-cli then do:
        create tt-parts-cli.
        assign tt-parts-cli.wth-code = buf_wth-parts.wth-code
              tt-parts-cli.par-code = buf_wth-parts.par-code
              tt-parts-cli.ser-code = buf_wth-parts.ser-code
              tt-parts-cli.db-num   = buf_wth-parts.db-num
              tt-parts-cli.cli-type = v-cli-type
              tt-parts-cli.cli-code = v-cli-code
              tt-parts-cli.obj-type = buf_wth-parts.obj-type
              tt-parts-cli.obj-code = buf_wth-parts.obj-code
              tt-parts-cli.doc-code  = buf_wth-parts.out-code
              tt-parts-cli.ext-doc-type = buf_wth-parts.ext-doc-type
              tt-parts-cli.gds-code = buf_wth-parts.gds-code
              tt-parts-cli.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
    if buf-arh_wth-doc.doc-type = 'при':U
    or buf-arh_wth-doc.doc-type = 'возврат':U
    or (buf-arh_wth-doc.doc-type = 'обмен':U and buf_wth-parts.type = 'при':U)
    then
    assign tt-parts-cli.in-qnty     = tt-parts-cli.in-qnty     + buf_wth-parts.fact-qnty
           tt-parts-cli.in-sum-rubl = tt-parts-cli.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-cli.in-sum-base = tt-parts-cli.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .
    else   assign tt-parts-cli.out-qnty  = tt-parts-cli.out-qnty + buf_wth-parts.fact-qnty
           tt-parts-cli.out-sum-rubl = tt-parts-cli.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-cli.out-sum-base = tt-parts-cli.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .
      find first tt-parts-cli-doc where
                tt-parts-cli-doc.wth-code = buf_wth-parts.wth-code
            and tt-parts-cli-doc.par-code = buf_wth-parts.par-code
            and tt-parts-cli-doc.cli-type = v-cli-type
            and tt-parts-cli-doc.cli-code = v-cli-code
            and tt-parts-cli-doc.host-code = buf_wth-parts.host-code
            and tt-parts-cli-doc.contract-code = buf_wth-parts.contract-code
            and tt-parts-cli-doc.gds-code = buf_wth-parts.gds-code
            and tt-parts-cli-doc.obj-type = buf_wth-parts.obj-type
            and tt-parts-cli-doc.obj-code = buf_wth-parts.obj-code
            and tt-parts-cli-doc.w-p-code = buf_wth-parts.w-p-code
            and tt-parts-cli-doc.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-cli-doc.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
            no-error.
      if not available tt-parts-cli-doc then do:
        create tt-parts-cli-doc.
        buffer-copy buf_wth-parts using wth-code
                                        par-code
                                        host-code
                                        contract-code
                                        gds-code
                                        obj-type
                                        obj-code
                                        w-p-code
                                        ext-doc-type
                    to tt-parts-cli-doc.
        assign tt-parts-cli-doc.doc-code = buf_wth-parts.out-code
               tt-parts-cli-doc.cli-code = v-cli-code
               tt-parts-cli-doc.cli-type = v-cli-type
               tt-parts-cli-doc.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
      if buf-arh_wth-doc.doc-type = 'при':U
      or buf-arh_wth-doc.doc-type = 'возврат':U
      or (buf-arh_wth-doc.doc-type = 'обмен':U and buf_wth-parts.type = 'при':U )
      then
    assign tt-parts-cli-doc.in-qnty     = tt-parts-cli-doc.in-qnty     + buf_wth-parts.fact-qnty
           tt-parts-cli-doc.in-sum-rubl = tt-parts-cli-doc.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-cli-doc.in-sum-base = tt-parts-cli-doc.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .
    else   assign tt-parts-cli-doc.out-qnty  = tt-parts-cli-doc.out-qnty + buf_wth-parts.fact-qnty
           tt-parts-cli-doc.out-sum-rubl = tt-parts-cli-doc.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
           tt-parts-cli-doc.out-sum-base = tt-parts-cli-doc.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .
      find first tt-parts-cli-tot where
                tt-parts-cli-tot.cli-type = v-cli-type
            and tt-parts-cli-tot.cli-code = v-cli-code
            and tt-parts-cli-tot.obj-type = buf_wth-parts.obj-type
            and tt-parts-cli-tot.obj-code = buf_wth-parts.obj-code
            and tt-parts-cli-tot.ext-doc-type = buf_wth-parts.ext-doc-type
            and tt-parts-cli-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
      no-error.
      if not available tt-parts-cli-tot then do:
        create tt-parts-cli-tot.
        assign tt-parts-cli-tot.cli-type = v-cli-type
              tt-parts-cli-tot.cli-code  = v-cli-code
              tt-parts-cli-tot.obj-type  = buf_wth-parts.obj-type
              tt-parts-cli-tot.obj-code  = buf_wth-parts.obj-code
              tt-parts-cli-tot.doc-code  = buf_wth-parts.out-code
              tt-parts-cli-tot.host-code = buf_wth-parts.host-code
              tt-parts-cli-tot.ext-doc-type = buf_wth-parts.ext-doc-type
              tt-parts-cli-tot.sum-type = if buf_wth-parts.type > '' then buf_wth-parts.type else buf-arh_wth-doc.doc-type
        .
      end.
      if buf-arh_wth-doc.doc-type = 'при':U
      or buf-arh_wth-doc.doc-type = 'возврат':U
      or (buf-arh_wth-doc.doc-type = 'обмен':U and buf_wth-parts.type = 'при':U )
      then
      assign tt-parts-cli-tot.in-qnty     = tt-parts-cli-tot.in-qnty     + buf_wth-parts.fact-qnty
            tt-parts-cli-tot.in-sum-rubl = tt-parts-cli-tot.in-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
            tt-parts-cli-tot.in-sum-base = tt-parts-cli-tot.in-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base .
      else   assign tt-parts-cli-tot.out-qnty = tt-parts-cli-tot.out-qnty  + buf_wth-parts.fact-qnty
            tt-parts-cli-tot.out-sum-rubl = tt-parts-cli-tot.out-sum-rubl + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
            tt-parts-cli-tot.out-sum-base = tt-parts-cli-tot.out-sum-base + buf_wth-parts.fact-qnty * buf_wth-parts.price-base  .
    end.
  end.
  if par-lock then do:
    for each tt-parts-tot:
      find last   buf-arh-wth-tot exclusive-lock  where
                  buf-arh-wth-tot.wth-code =  tt-parts-tot.wth-code
              and buf-arh-wth-tot.par-code =  tt-parts-tot.par-code
              and buf-arh-wth-tot.obj-type = tt-parts-tot.obj-type
              and buf-arh-wth-tot.obj-code = tt-parts-tot.obj-code
              and buf-arh-wth-tot.ext-doc-type = tt-parts-tot.ext-doc-type
              and buf-arh-wth-tot.sum-type = tt-parts-tot.sum-type     no-error.
      if not available buf-arh-wth-tot then do:
        create buf-arh-wth-tot.
        buffer-copy tt-parts-tot using
                    wth-code
                    par-code
                    gds-code
                    obj-type
                    obj-code
                    w-p-code
                    sum-type
                    ext-doc-type
        to buf-arh-wth-tot.
      end.
    end.
    for each tt-parts-wp:
      find last   buf-arh-wth-wp exclusive-lock  where
                  buf-arh-wth-wp.wth-code =  tt-parts-wp.wth-code
              and buf-arh-wth-wp.par-code =  tt-parts-wp.par-code
              and buf-arh-wth-wp.obj-type = tt-parts-wp.obj-type
              and buf-arh-wth-wp.obj-code = tt-parts-wp.obj-code
              and buf-arh-wth-wp.w-p-code = tt-parts-wp.w-p-code
              and buf-arh-wth-wp.out-code = tt-parts-wp.out-code     no-error.
      if not available buf-arh-wth-wp then do:
        create buf-arh-wth-wp.
        buffer-copy tt-parts-wp using
                    wth-code
                    par-code
                    gds-code
                    obj-type
                    obj-code
                    w-p-code
                    doc-code
                    out-code
                    ext-doc-type
        to buf-arh-wth-wp.
      end.
    end.
    for each tt-parts-cli:
      find last  buf-arh-wth-cli exclusive-lock where
                 buf-arh-wth-cli.wth-code =  tt-parts-cli.wth-code
            and  buf-arh-wth-cli.par-code =  tt-parts-cli.par-code
            and  buf-arh-wth-cli.ser-code =  tt-parts-cli.ser-code
            and  buf-arh-wth-cli.db-num   =  tt-parts-cli.db-num
            and  buf-arh-wth-cli.cli-type =  tt-parts-cli.cli-type
            and  buf-arh-wth-cli.cli-code =  tt-parts-cli.cli-code
            and  buf-arh-wth-cli.obj-type =  tt-parts-cli.obj-type
            and  buf-arh-wth-cli.obj-code =  tt-parts-cli.obj-code
            and  buf-arh-wth-cli.sum-type = tt-parts-cli.sum-type
            and  buf-arh-wth-cli.ext-doc-type =  tt-parts-cli.ext-doc-type
            and  buf-arh-wth-cli.gds-code =  tt-parts-cli.gds-code
             no-error.
      if not available buf-arh-wth-cli then do:
        create buf-arh-wth-cli.
        buffer-copy tt-parts-cli using wth-code
                                       sum-type
                                       par-code
                                       ser-code
                                       db-num
                                       cli-type
                                       cli-code
                                       obj-type
                                       obj-code
                                       ext-doc-type
                                       gds-code to buf-arh-wth-cli.
      end.
    end.
    for each tt-parts-cli-doc:
      find last buf-arh-wth-cli-doc exclusive-lock  where
                 buf-arh-wth-cli-doc.wth-code = tt-parts-cli-doc.wth-code
            and  buf-arh-wth-cli-doc.par-code = tt-parts-cli-doc.par-code
            and  buf-arh-wth-cli-doc.cli-type = tt-parts-cli-doc.cli-type
            and  buf-arh-wth-cli-doc.cli-code = tt-parts-cli-doc.cli-code
            and  buf-arh-wth-cli-doc.host-code     = tt-parts-cli-doc.host-code
            and  buf-arh-wth-cli-doc.contract-code = tt-parts-cli-doc.contract-code
            and  buf-arh-wth-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
            and  buf-arh-wth-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
            and  buf-arh-wth-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
            and  buf-arh-wth-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
            and  buf-arh-wth-cli-doc.sum-type      = tt-parts-cli-doc.sum-type
            and  buf-arh-wth-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
            no-error.
      if not available buf-arh-wth-cli-doc then do:
        create buf-arh-wth-cli-doc.
        buffer-copy tt-parts-cli-doc using
                    wth-code
                    par-code
                    cli-type
                    cli-code
                    host-code
                    contract-code
                    gds-code
                    obj-type
                    obj-code
                    w-p-code
                    ext-doc-type
                    sum-type
                    to buf-arh-wth-cli-doc.
      end.
    end.
    for each tt-parts-cli-tot:
      find last  buf-arh-wth-cli-tot exclusive-lock where
                 buf-arh-wth-cli-tot.cli-type =  tt-parts-cli-tot.cli-type
            and  buf-arh-wth-cli-tot.cli-code =  tt-parts-cli-tot.cli-code
            and  buf-arh-wth-cli-tot.obj-type =  tt-parts-cli-tot.obj-type
            and  buf-arh-wth-cli-tot.obj-code =  tt-parts-cli-tot.obj-code
            and  buf-arh-wth-cli-tot.sum-type = tt-parts-cli-tot.sum-type
            and  buf-arh-wth-cli-tot.ext-doc-type =  tt-parts-cli-tot.ext-doc-type
      no-error.
      if not available buf-arh-wth-cli-tot then do:
        create buf-arh-wth-cli-tot.
        buffer-copy tt-parts-cli-tot using cli-type sum-type cli-code obj-type obj-code ext-doc-type host-code to buf-arh-wth-cli-tot.
      end.
    end.
  end.
  end.
 end procedure.
 procedure wth-arhdoc-close:
 define input parameter pardoc-code as char no-undo.
 define variable vararh-mode  as integer      no-undo.
  do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  find first buf-arh_wth-doc where buf-arh_wth-doc.doc-code = pardoc-code no-lock no-error.
  if not available buf-arh_wth-doc then do:
    return error substitute ("Не найден документ МЦ с номером &1.", pardoc-code).
  end.
  run wth-arh-mode(input buf-arh_wth-doc.ext-doc-type
          ,input buf-arh_wth-doc.doc-code
          ,output vararh-mode).
  if buf-arh_wth-doc.status_ <> 'факт':U then do:
    return error substitute ("Документ МЦ с номером &1 не в статусе факт. Создание архивов невозможно.", pardoc-code).
  end.
  if buf-arh_wth-doc.fact-order = 0 or
    buf-arh_wth-doc.fact-order = ? then do:
    return error substitute ("В документе МЦ с номером &1 не проставлен fact-order.", buf-arh_wth-doc.doc-code).
  end.
  if  not g#news
       or (g#news and  g#db-num  = 0)
  then do:
    for each  tt-parts-tot on error undo, return error:
        find last  buf-prev_arh-wth-tot where buf-prev_arh-wth-tot.wth-code =  tt-parts-tot.wth-code
                                          and buf-prev_arh-wth-tot.par-code =  tt-parts-tot.par-code
                                          and buf-prev_arh-wth-tot.obj-type = tt-parts-tot.obj-type
                                          and buf-prev_arh-wth-tot.obj-code = tt-parts-tot.obj-code
                                          and buf-prev_arh-wth-tot.ext-doc-type = tt-parts-tot.ext-doc-type
                                          and buf-prev_arh-wth-tot.sum-type = tt-parts-tot.sum-type
                                          and buf-prev_arh-wth-tot.fact-order < buf-arh_wth-doc.fact-order
                                          no-error.
        if available buf-prev_arh-wth-tot and buf-prev_arh-wth-tot.fact-order = 0 then do:
            find first buf-arh-wth-tot where recid(buf-arh-wth-tot) = recid(buf-prev_arh-wth-tot) exclusive-lock.
        end.
        else do:
          create buf-arh-wth-tot.
          buffer-copy tt-parts-tot to buf-arh-wth-tot .
        end.
        assign  buf-arh-wth-tot.doc-code = buf-arh_wth-doc.doc-code
                buf-arh-wth-tot.fact-order = buf-arh_wth-doc.fact-order
                buf-arh-wth-tot.in-qnty     = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.in-qnty  else 0)    + tt-parts-tot.in-qnty
                buf-arh-wth-tot.in-sum-rubl = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.in-sum-rubl else 0) + tt-parts-tot.in-sum-rubl
                buf-arh-wth-tot.in-sum-base = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.in-sum-base else 0) + tt-parts-tot.in-sum-base
                buf-arh-wth-tot.out-qnty    = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.out-qnty else 0)    + tt-parts-tot.out-qnty
                buf-arh-wth-tot.out-sum-rubl = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.out-sum-rubl else 0) + tt-parts-tot.out-sum-rubl
                buf-arh-wth-tot.out-sum-base = (if available buf-prev_arh-wth-tot then buf-prev_arh-wth-tot.out-sum-base else 0) + tt-parts-tot.out-sum-base
                .
        for each buf-recalc-tot where buf-recalc-tot.fact-order > buf-arh_wth-doc.fact-order
              and buf-recalc-tot.wth-code = tt-parts-tot.wth-code
              and buf-recalc-tot.par-code = tt-parts-tot.par-code
              and buf-recalc-tot.obj-type = tt-parts-tot.obj-type
              and buf-recalc-tot.obj-code = tt-parts-tot.obj-code
              and buf-recalc-tot.ext-doc-type = tt-parts-tot.ext-doc-type
              and buf-recalc-tot.sum-type = tt-parts-tot.sum-type
              on error undo, return error :
              assign buf-recalc-tot.out-qnty    = buf-recalc-tot.out-qnty     + tt-parts-tot.out-qnty
                    buf-recalc-tot.out-sum-rubl = buf-recalc-tot.out-sum-rubl + tt-parts-tot.out-sum-rubl
                    buf-recalc-tot.out-sum-base = buf-recalc-tot.out-sum-base + tt-parts-tot.out-sum-base
                    buf-recalc-tot.in-qnty      = buf-recalc-tot.in-qnty    + tt-parts-tot.in-qnty
                    buf-recalc-tot.in-sum-rubl = buf-recalc-tot.in-sum-rubl + tt-parts-tot.in-sum-rubl
                    buf-recalc-tot.in-sum-base = buf-recalc-tot.in-sum-base + tt-parts-tot.in-sum-base
                    .
        end.
     end.
     for each  tt-parts-wp on error undo, return error:
        find last  buf-prev_arh-wth-wp where buf-prev_arh-wth-wp.wth-code  = tt-parts-wp.wth-code
                                          and buf-prev_arh-wth-wp.par-code = tt-parts-wp.par-code
                                          and buf-prev_arh-wth-wp.obj-type = tt-parts-wp.obj-type
                                          and buf-prev_arh-wth-wp.obj-code = tt-parts-wp.obj-code
                                          and buf-prev_arh-wth-wp.out-code = tt-parts-wp.out-code
                                          and buf-prev_arh-wth-wp.w-p-code = tt-parts-wp.w-p-code
                                          and buf-prev_arh-wth-wp.fact-order < buf-arh_wth-doc.fact-order
                                          no-error.
        if available buf-prev_arh-wth-wp and buf-prev_arh-wth-wp.fact-order = 0 then do:
            find first buf-arh-wth-wp where recid(buf-arh-wth-wp) = recid(buf-prev_arh-wth-wp) exclusive-lock.
        end.
        else do:
          create buf-arh-wth-wp.
          buffer-copy tt-parts-wp to buf-arh-wth-wp .
        end.
        assign  buf-arh-wth-wp.doc-code = buf-arh_wth-doc.doc-code
                buf-arh-wth-wp.fact-order = buf-arh_wth-doc.fact-order
                buf-arh-wth-wp.ext-doc-type = buf-arh_wth-doc.ext-doc-type
                buf-arh-wth-wp.in-qnty     = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.in-qnty  else 0)    + tt-parts-wp.in-qnty
                buf-arh-wth-wp.in-sum-rubl = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.in-sum-rubl else 0) + tt-parts-wp.in-sum-rubl
                buf-arh-wth-wp.in-sum-base = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.in-sum-base else 0) + tt-parts-wp.in-sum-base
                buf-arh-wth-wp.out-qnty    = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.out-qnty else 0)    + tt-parts-wp.out-qnty
                buf-arh-wth-wp.out-sum-rubl = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.out-sum-rubl else 0) + tt-parts-wp.out-sum-rubl
                buf-arh-wth-wp.out-sum-base = (if available buf-prev_arh-wth-wp then buf-prev_arh-wth-wp.out-sum-base else 0) + tt-parts-wp.out-sum-base
                .
        for each buf-recalc-wp where buf-recalc-wp.fact-order > buf-arh_wth-doc.fact-order
              and buf-recalc-wp.wth-code = tt-parts-wp.wth-code
              and buf-recalc-wp.par-code = tt-parts-wp.par-code
              and buf-recalc-wp.obj-type = tt-parts-wp.obj-type
              and buf-recalc-wp.obj-code = tt-parts-wp.obj-code
              and buf-recalc-wp.out-code = tt-parts-wp.out-code
              and buf-recalc-wp.w-p-code = tt-parts-wp.w-p-code
              and buf-recalc-wp.sum-type = tt-parts-wp.sum-type
              on error undo, return error :
              assign buf-recalc-wp.out-qnty    = buf-recalc-wp.out-qnty     + tt-parts-wp.out-qnty
                    buf-recalc-wp.out-sum-rubl = buf-recalc-wp.out-sum-rubl + tt-parts-wp.out-sum-rubl
                    buf-recalc-wp.out-sum-base = buf-recalc-wp.out-sum-base + tt-parts-wp.out-sum-base
                    buf-recalc-wp.in-qnty      = buf-recalc-wp.in-qnty    + tt-parts-wp.in-qnty
                    buf-recalc-wp.in-sum-rubl = buf-recalc-wp.in-sum-rubl + tt-parts-wp.in-sum-rubl
                    buf-recalc-wp.in-sum-base = buf-recalc-wp.in-sum-base + tt-parts-wp.in-sum-base
                    .
        end.
     end.
  end.
  if vararh-mode = 1 then do:
    for each  tt-parts-cli on error undo, return error:
      find last  buf-prev_arh-wth-cli where  buf-prev_arh-wth-cli.wth-code =  tt-parts-cli.wth-code
                                        and  buf-prev_arh-wth-cli.par-code =  tt-parts-cli.par-code
                                        and  buf-prev_arh-wth-cli.ser-code =  tt-parts-cli.ser-code
                                        and  buf-prev_arh-wth-cli.db-num   =  tt-parts-cli.db-num
                                        and  buf-prev_arh-wth-cli.cli-type =  tt-parts-cli.cli-type
                                        and  buf-prev_arh-wth-cli.cli-code =  tt-parts-cli.cli-code
                                        and  buf-prev_arh-wth-cli.obj-type =  tt-parts-cli.obj-type
                                        and  buf-prev_arh-wth-cli.obj-code =  tt-parts-cli.obj-code
                                        and  buf-prev_arh-wth-cli.ext-doc-type =  tt-parts-cli.ext-doc-type
                                        and  buf-prev_arh-wth-cli.gds-code =  tt-parts-cli.gds-code
                                        and  buf-prev_arh-wth-cli.sum-type = tt-parts-cli.sum-type
                                        and  buf-prev_arh-wth-cli.fact-order < buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-prev_arh-wth-cli and buf-prev_arh-wth-cli.fact-order = 0 then do:
          find first buf-arh-wth-cli where recid(buf-arh-wth-cli) = recid(buf-prev_arh-wth-cli) exclusive-lock.
      end.
      else do:
        create buf-arh-wth-cli.
        buffer-copy tt-parts-cli to buf-arh-wth-cli .
      end.
      assign  buf-arh-wth-cli.doc-code   = buf-arh_wth-doc.doc-code
              buf-arh-wth-cli.fact-order = buf-arh_wth-doc.fact-order
      .
      if available buf-prev_arh-wth-cli then do:
        assign buf-arh-wth-cli.out-qnty =  buf-prev_arh-wth-cli.out-qnty  + tt-parts-cli.out-qnty
               buf-arh-wth-cli.out-sum-rubl = buf-prev_arh-wth-cli.out-sum-rubl + tt-parts-cli.out-sum-rubl
               buf-arh-wth-cli.out-sum-base = buf-prev_arh-wth-cli.out-sum-base + tt-parts-cli.out-sum-base
               buf-arh-wth-cli.in-qnty = buf-prev_arh-wth-cli.in-qnty + tt-parts-cli.in-qnty
               buf-arh-wth-cli.in-sum-rubl = buf-prev_arh-wth-cli.in-sum-rubl + tt-parts-cli.in-sum-rubl
               buf-arh-wth-cli.in-sum-base = buf-prev_arh-wth-cli.in-sum-base + tt-parts-cli.in-sum-base
               .
      end.
      else do:
        assign buf-arh-wth-cli.out-qnty =  tt-parts-cli.out-qnty
               buf-arh-wth-cli.out-sum-rubl = tt-parts-cli.out-sum-rubl
               buf-arh-wth-cli.out-sum-base = tt-parts-cli.out-sum-base
               buf-arh-wth-cli.in-qnty =  tt-parts-cli.in-qnty
               buf-arh-wth-cli.in-sum-rubl =  tt-parts-cli.in-sum-rubl
               buf-arh-wth-cli.in-sum-base =  tt-parts-cli.in-sum-base
               .
      end.
      for each buf-recalc-cli where buf-recalc-cli.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-cli.wth-code = tt-parts-cli.wth-code
            and buf-recalc-cli.par-code = tt-parts-cli.par-code
            and buf-recalc-cli.ser-code = tt-parts-cli.ser-code
            and buf-recalc-cli.db-num   = tt-parts-cli.db-num
            and buf-recalc-cli.cli-type = tt-parts-cli.cli-type
            and buf-recalc-cli.cli-code = tt-parts-cli.cli-code
            and buf-recalc-cli.obj-type = tt-parts-cli.obj-type
            and buf-recalc-cli.obj-code = tt-parts-cli.obj-code
            and buf-recalc-cli.ext-doc-type = tt-parts-cli.ext-doc-type
            and buf-recalc-cli.sum-type = tt-parts-cli.sum-type
            and buf-recalc-cli.gds-code = tt-parts-cli.gds-code
            on error undo, return error:
            assign buf-recalc-cli.out-qnty     = buf-recalc-cli.out-qnty + tt-parts-cli.out-qnty
                  buf-recalc-cli.out-sum-rubl = buf-recalc-cli.out-sum-rubl + tt-parts-cli.out-sum-rubl
                  buf-recalc-cli.out-sum-base = buf-recalc-cli.out-sum-base + tt-parts-cli.out-sum-base
                  buf-recalc-cli.in-qnty       = buf-recalc-cli.in-qnty + tt-parts-cli.in-qnty
                  buf-recalc-cli.in-sum-rubl  = buf-recalc-cli.in-sum-rubl + tt-parts-cli.in-sum-rubl
                  buf-recalc-cli.in-sum-base  = buf-recalc-cli.in-sum-base + tt-parts-cli.in-sum-base
              .
      end.
    end.
    for each  tt-parts-cli-doc on error undo, return error:
      find last buf-prev_arh-wth-cli-doc where buf-prev_arh-wth-cli-doc.wth-code =  tt-parts-cli-doc.wth-code
                                        and  buf-prev_arh-wth-cli-doc.par-code = tt-parts-cli-doc.par-code
                                        and  buf-prev_arh-wth-cli-doc.cli-type = tt-parts-cli-doc.cli-type
                                        and  buf-prev_arh-wth-cli-doc.cli-code = tt-parts-cli-doc.cli-code
                                        and  buf-prev_arh-wth-cli-doc.host-code     = tt-parts-cli-doc.host-code
                                        and  buf-prev_arh-wth-cli-doc.contract-code = tt-parts-cli-doc.contract-code
                                        and  buf-prev_arh-wth-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
                                        and  buf-prev_arh-wth-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
                                        and  buf-prev_arh-wth-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
                                        and  buf-prev_arh-wth-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
                                        and  buf-prev_arh-wth-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
                                        and  buf-prev_arh-wth-cli-doc.sum-type = tt-parts-cli-doc.sum-type
                                        and  buf-prev_arh-wth-cli-doc.fact-order < buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-prev_arh-wth-cli-doc and buf-prev_arh-wth-cli-doc.fact-order = 0 then do:
          find first buf-arh-wth-cli-doc where recid(buf-arh-wth-cli-doc) = recid(buf-prev_arh-wth-cli-doc) exclusive-lock.
      end.
      else do:
        create buf-arh-wth-cli-doc.
        buffer-copy tt-parts-cli-doc to buf-arh-wth-cli-doc .
      end.
      assign  buf-arh-wth-cli-doc.doc-code = buf-arh_wth-doc.doc-code
              buf-arh-wth-cli-doc.fact-order = buf-arh_wth-doc.fact-order
      .
      if available buf-prev_arh-wth-cli-doc then
        assign buf-arh-wth-cli-doc.out-qnty = buf-prev_arh-wth-cli-doc.out-qnty + tt-parts-cli-doc.out-qnty
               buf-arh-wth-cli-doc.out-sum-rubl = buf-prev_arh-wth-cli-doc.out-sum-rubl + tt-parts-cli-doc.out-sum-rubl
               buf-arh-wth-cli-doc.out-sum-base = buf-prev_arh-wth-cli-doc.out-sum-base + tt-parts-cli-doc.out-sum-base
               buf-arh-wth-cli-doc.in-qnty = buf-prev_arh-wth-cli-doc.in-qnty + tt-parts-cli-doc.in-qnty
               buf-arh-wth-cli-doc.in-sum-rubl = buf-prev_arh-wth-cli-doc.in-sum-rubl + tt-parts-cli-doc.in-sum-rubl
               buf-arh-wth-cli-doc.in-sum-base = buf-prev_arh-wth-cli-doc.in-sum-base + tt-parts-cli-doc.in-sum-base
               .
      else  assign buf-arh-wth-cli-doc.out-qnty =  tt-parts-cli-doc.out-qnty
               buf-arh-wth-cli-doc.out-sum-rubl =  tt-parts-cli-doc.out-sum-rubl
               buf-arh-wth-cli-doc.out-sum-base =  tt-parts-cli-doc.out-sum-base
               buf-arh-wth-cli-doc.in-qnty =  tt-parts-cli-doc.in-qnty
               buf-arh-wth-cli-doc.in-sum-rubl =  tt-parts-cli-doc.in-sum-rubl
               buf-arh-wth-cli-doc.in-sum-base =  tt-parts-cli-doc.in-sum-base
               .
      for each  buf-recalc-cli-doc where buf-recalc-cli-doc.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-cli-doc.wth-code = tt-parts-cli-doc.wth-code
            and buf-recalc-cli-doc.par-code = tt-parts-cli-doc.par-code
            and buf-recalc-cli-doc.cli-type = tt-parts-cli-doc.cli-type
            and buf-recalc-cli-doc.cli-code = tt-parts-cli-doc.cli-code
            and buf-recalc-cli-doc.host-code     = tt-parts-cli-doc.host-code
            and buf-recalc-cli-doc.contract-code = tt-parts-cli-doc.contract-code
            and buf-recalc-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
            and buf-recalc-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
            and buf-recalc-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
            and buf-recalc-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
            and buf-recalc-cli-doc.sum-type      = tt-parts-cli-doc.sum-type
            and buf-recalc-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
            on error undo, return error:
            assign buf-recalc-cli-doc.out-qnty     = buf-recalc-cli-doc.out-qnty + tt-parts-cli-doc.out-qnty
                  buf-recalc-cli-doc.out-sum-rubl = buf-recalc-cli-doc.out-sum-rubl + tt-parts-cli-doc.out-sum-rubl
                  buf-recalc-cli-doc.out-sum-base = buf-recalc-cli-doc.out-sum-base + tt-parts-cli-doc.out-sum-base
                  buf-recalc-cli-doc.in-qnty       = buf-recalc-cli-doc.in-qnty + tt-parts-cli-doc.in-qnty
                  buf-recalc-cli-doc.in-sum-rubl = buf-recalc-cli-doc.in-sum-rubl + tt-parts-cli-doc.in-sum-rubl
                  buf-recalc-cli-doc.in-sum-base = buf-recalc-cli-doc.in-sum-base + tt-parts-cli-doc.in-sum-base
                  .
      end.
    end.
    for each  tt-parts-cli-tot on error undo, return error:
      find last  buf-prev_arh-wth-cli-tot where buf-prev_arh-wth-cli-tot.cli-type =  tt-parts-cli-tot.cli-type
                                        and  buf-prev_arh-wth-cli-tot.cli-code =  tt-parts-cli-tot.cli-code
                                        and  buf-prev_arh-wth-cli-tot.obj-type =  tt-parts-cli-tot.obj-type
                                        and  buf-prev_arh-wth-cli-tot.obj-code =  tt-parts-cli-tot.obj-code
                                        and  buf-prev_arh-wth-cli-tot.ext-doc-type =  tt-parts-cli-tot.ext-doc-type
                                        and  buf-prev_arh-wth-cli-tot.sum-type     = tt-parts-cli-tot.sum-type
                                        and  buf-prev_arh-wth-cli-tot.fact-order < buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-prev_arh-wth-cli-tot and buf-prev_arh-wth-cli-tot.fact-order = 0 then do:
          find first buf-arh-wth-cli-tot where recid(buf-arh-wth-cli-tot) = recid(buf-prev_arh-wth-cli-tot) exclusive-lock.
      end.
      else do:
        create buf-arh-wth-cli-tot.
        buffer-copy tt-parts-cli-tot to buf-arh-wth-cli-tot .
      end.
      assign  buf-arh-wth-cli-tot.doc-code   = buf-arh_wth-doc.doc-code
              buf-arh-wth-cli-tot.fact-order = buf-arh_wth-doc.fact-order
      .
      if available buf-prev_arh-wth-cli-tot then
        assign buf-arh-wth-cli-tot.out-qnty = buf-prev_arh-wth-cli-tot.out-qnty + tt-parts-cli-tot.out-qnty
               buf-arh-wth-cli-tot.out-sum-rubl = buf-prev_arh-wth-cli-tot.out-sum-rubl + tt-parts-cli-tot.out-sum-rubl
               buf-arh-wth-cli-tot.out-sum-base = buf-prev_arh-wth-cli-tot.out-sum-base + tt-parts-cli-tot.out-sum-base
               buf-arh-wth-cli-tot.in-qnty = buf-prev_arh-wth-cli-tot.in-qnty + tt-parts-cli-tot.in-qnty
               buf-arh-wth-cli-tot.in-sum-rubl = buf-prev_arh-wth-cli-tot.in-sum-rubl + tt-parts-cli-tot.in-sum-rubl
               buf-arh-wth-cli-tot.in-sum-base = buf-prev_arh-wth-cli-tot.in-sum-base + tt-parts-cli-tot.in-sum-base
               .
      else  assign buf-arh-wth-cli-tot.out-qnty =  tt-parts-cli-tot.out-qnty
               buf-arh-wth-cli-tot.out-sum-rubl =  tt-parts-cli-tot.out-sum-rubl
               buf-arh-wth-cli-tot.out-sum-base =  tt-parts-cli-tot.out-sum-base
               buf-arh-wth-cli-tot.in-qnty =  tt-parts-cli-tot.in-qnty
               buf-arh-wth-cli-tot.in-sum-rubl =  tt-parts-cli-tot.in-sum-rubl
               buf-arh-wth-cli-tot.in-sum-base =  tt-parts-cli-tot.in-sum-base
               .
      for each buf-recalc-cli-tot where buf-recalc-cli-tot.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-cli-tot.cli-type = tt-parts-cli-tot.cli-type
            and buf-recalc-cli-tot.cli-code = tt-parts-cli-tot.cli-code
            and buf-recalc-cli-tot.obj-type = tt-parts-cli-tot.obj-type
            and buf-recalc-cli-tot.obj-code = tt-parts-cli-tot.obj-code
            and buf-recalc-cli-tot.ext-doc-type = tt-parts-cli-tot.ext-doc-type
            and buf-recalc-cli-tot.sum-type     = tt-parts-cli-tot.sum-type
            on error undo, return error
            :
            assign buf-recalc-cli-tot.out-qnty     = buf-recalc-cli-tot.out-qnty + tt-parts-cli-tot.out-qnty
                  buf-recalc-cli-tot.out-sum-rubl = buf-recalc-cli-tot.out-sum-rubl + tt-parts-cli-tot.out-sum-rubl
                  buf-recalc-cli-tot.out-sum-base = buf-recalc-cli-tot.out-sum-base + tt-parts-cli-tot.out-sum-base
                  buf-recalc-cli-tot.in-qnty       = buf-recalc-cli-tot.in-qnty + tt-parts-cli-tot.in-qnty
                  buf-recalc-cli-tot.in-sum-rubl = buf-recalc-cli-tot.in-sum-rubl + tt-parts-cli-tot.in-sum-rubl
                  buf-recalc-cli-tot.in-sum-base = buf-recalc-cli-tot.in-sum-base + tt-parts-cli-tot.in-sum-base
                  .
      end.
    end.
  end.
  end.
 end.
procedure wth-arhdoc-delete:
 define input parameter pardoc-code as char no-undo.
  do on error undo, return error substitute ("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
  find first buf-arh_wth-doc where buf-arh_wth-doc.doc-code = pardoc-code no-lock no-error.
  if not available buf-arh_wth-doc then do:
    return error substitute ("Не найден документ МЦ с номером &1.", pardoc-code).
  end.
  if buf-arh_wth-doc.status_ <> 'факт':U then do:
    return error substitute ("Документ МЦ с номером &1 не в статусе факт. Создание архивов невозможно.", pardoc-code).
  end.
  if buf-arh_wth-doc.fact-order = 0 or
    buf-arh_wth-doc.fact-order = ? then do:
    return error substitute ("В документе МЦ с номером &1 не проставлен fact-order.", buf-arh_wth-doc.doc-code).
  end.
  run wth-arh-calctt-loc(input buf-arh_wth-doc.doc-code
                        ,input no) no-error.
  if error-status:error then  return error return-value + error-status:get-message(1).
  for each  tt-parts-tot on error undo, return error return-value:
      find first  buf-arh-wth-tot where buf-arh-wth-tot.wth-code =  tt-parts-tot.wth-code
                                        and buf-arh-wth-tot.par-code =  tt-parts-tot.par-code
                                        and buf-arh-wth-tot.obj-type = tt-parts-tot.obj-type
                                        and buf-arh-wth-tot.obj-code = tt-parts-tot.obj-code
                                        and buf-arh-wth-tot.ext-doc-type = tt-parts-tot.ext-doc-type
                                        and buf-arh-wth-tot.sum-type = tt-parts-tot.sum-type
                                        and buf-arh-wth-tot.fact-order = buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-arh-wth-tot then do:
          delete buf-arh-wth-tot.
      end.
      for each buf-recalc-tot where buf-recalc-tot.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-tot.wth-code = tt-parts-tot.wth-code
            and buf-recalc-tot.par-code = tt-parts-tot.par-code
            and buf-recalc-tot.obj-type = tt-parts-tot.obj-type
            and buf-recalc-tot.obj-code = tt-parts-tot.obj-code
            and buf-recalc-tot.ext-doc-type = tt-parts-tot.ext-doc-type
            and buf-recalc-tot.sum-type = tt-parts-tot.sum-type
             :
            assign buf-recalc-tot.out-qnty     = buf-recalc-tot.out-qnty - tt-parts-tot.out-qnty
                  buf-recalc-tot.out-sum-rubl = buf-recalc-tot.out-sum-rubl - tt-parts-tot.out-sum-rubl
                  buf-recalc-tot.out-sum-base = buf-recalc-tot.out-sum-base - tt-parts-tot.out-sum-base
                  buf-recalc-tot.in-qnty       = buf-recalc-tot.in-qnty - tt-parts-tot.in-qnty
                  buf-recalc-tot.in-sum-rubl = buf-recalc-tot.in-sum-rubl - tt-parts-tot.in-sum-rubl
                  buf-recalc-tot.in-sum-base = buf-recalc-tot.in-sum-base - tt-parts-tot.in-sum-base
                  .
      end.
  end.
  for each  tt-parts-wp on error undo, return error return-value:
      find first  buf-arh-wth-wp where buf-arh-wth-wp.wth-code =  tt-parts-wp.wth-code
                                        and buf-arh-wth-wp.par-code =  tt-parts-wp.par-code
                                        and buf-arh-wth-wp.obj-type = tt-parts-wp.obj-type
                                        and buf-arh-wth-wp.obj-code = tt-parts-wp.obj-code
                                        and buf-arh-wth-wp.out-code = tt-parts-wp.out-code
                                        and buf-arh-wth-wp.w-p-code = tt-parts-wp.w-p-code
                                        and buf-arh-wth-wp.sum-type = tt-parts-wp.sum-type
                                        and buf-arh-wth-wp.fact-order = buf-arh_wth-doc.fact-order
                                        no-error.
      if available buf-arh-wth-wp then do:
          delete buf-arh-wth-wp.
      end.
      for each buf-recalc-wp where buf-recalc-wp.fact-order > buf-arh_wth-doc.fact-order
            and buf-recalc-wp.wth-code = tt-parts-wp.wth-code
            and buf-recalc-wp.par-code = tt-parts-wp.par-code
            and buf-recalc-wp.obj-type = tt-parts-wp.obj-type
            and buf-recalc-wp.obj-code = tt-parts-wp.obj-code
            and buf-recalc-wp.out-code = tt-parts-wp.out-code
            and buf-recalc-wp.w-p-code = tt-parts-wp.w-p-code
            and buf-recalc-wp.sum-type = tt-parts-wp.sum-type
             :
            assign buf-recalc-wp.out-qnty     = buf-recalc-wp.out-qnty - tt-parts-wp.out-qnty
                  buf-recalc-wp.out-sum-rubl = buf-recalc-wp.out-sum-rubl - tt-parts-wp.out-sum-rubl
                  buf-recalc-wp.out-sum-base = buf-recalc-wp.out-sum-base - tt-parts-wp.out-sum-base
                  buf-recalc-wp.in-qnty       = buf-recalc-wp.in-qnty - tt-parts-wp.in-qnty
                  buf-recalc-wp.in-sum-rubl = buf-recalc-wp.in-sum-rubl - tt-parts-wp.in-sum-rubl
                  buf-recalc-wp.in-sum-base = buf-recalc-wp.in-sum-base - tt-parts-wp.in-sum-base
                  .
      end.
  end.
  for each  tt-parts-cli:
    find last  buf-arh-wth-cli where  buf-arh-wth-cli.wth-code =  tt-parts-cli.wth-code
                                      and  buf-arh-wth-cli.par-code =  tt-parts-cli.par-code
                                      and  buf-arh-wth-cli.cli-type =  tt-parts-cli.cli-type
                                      and  buf-arh-wth-cli.ser-code =  tt-parts-cli.ser-code
                                      and  buf-arh-wth-cli.db-num   =  tt-parts-cli.db-num
                                      and  buf-arh-wth-cli.cli-code =  tt-parts-cli.cli-code
                                      and  buf-arh-wth-cli.obj-type =  tt-parts-cli.obj-type
                                      and  buf-arh-wth-cli.obj-code =  tt-parts-cli.obj-code
                                      and  buf-arh-wth-cli.ext-doc-type =  tt-parts-cli.ext-doc-type
                                      and buf-arh-wth-cli.sum-type = tt-parts-cli.sum-type
                                      and  buf-arh-wth-cli.gds-code =  tt-parts-cli.gds-code
                                      and  buf-arh-wth-cli.fact-order = buf-arh_wth-doc.fact-order
                                      no-error.
    if available buf-arh-wth-cli then do:
        delete buf-arh-wth-cli.
    end.
    for each buf-recalc-cli where buf-recalc-cli.fact-order > buf-arh_wth-doc.fact-order
          and buf-recalc-cli.wth-code = tt-parts-cli.wth-code
          and buf-recalc-cli.par-code = tt-parts-cli.par-code
          and buf-recalc-cli.ser-code = tt-parts-cli.ser-code
          and buf-recalc-cli.db-num   = tt-parts-cli.db-num
          and buf-recalc-cli.cli-type = tt-parts-cli.cli-type
          and buf-recalc-cli.cli-code = tt-parts-cli.cli-code
          and buf-recalc-cli.obj-type = tt-parts-cli.obj-type
          and buf-recalc-cli.obj-code = tt-parts-cli.obj-code
          and buf-recalc-cli.ext-doc-type = tt-parts-cli.ext-doc-type
          and buf-recalc-cli.sum-type = tt-parts-cli.sum-type
          and buf-recalc-cli.gds-code = tt-parts-cli.gds-code:
          assign buf-recalc-cli.out-qnty     = buf-recalc-cli.out-qnty - tt-parts-cli.out-qnty
                buf-recalc-cli.out-sum-rubl = buf-recalc-cli.out-sum-rubl - tt-parts-cli.out-sum-rubl
                buf-recalc-cli.out-sum-base = buf-recalc-cli.out-sum-base - tt-parts-cli.out-sum-base
                buf-recalc-cli.in-qnty       = buf-recalc-cli.in-qnty - tt-parts-cli.in-qnty
                buf-recalc-cli.in-sum-rubl = buf-recalc-cli.in-sum-rubl - tt-parts-cli.in-sum-rubl
                buf-recalc-cli.in-sum-base = buf-recalc-cli.in-sum-base - tt-parts-cli.in-sum-base
                .
    end.
  end.
  for each  tt-parts-cli-doc:
    find last  buf-arh-wth-cli-doc where  buf-arh-wth-cli-doc.wth-code =  tt-parts-cli-doc.wth-code
                                      and  buf-arh-wth-cli-doc.par-code = tt-parts-cli-doc.par-code
                                      and  buf-arh-wth-cli-doc.cli-type = tt-parts-cli-doc.cli-type
                                      and  buf-arh-wth-cli-doc.cli-code = tt-parts-cli-doc.cli-code
                                      and  buf-arh-wth-cli-doc.host-code     = tt-parts-cli-doc.host-code
                                      and  buf-arh-wth-cli-doc.contract-code = tt-parts-cli-doc.contract-code
                                      and  buf-arh-wth-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
                                      and  buf-arh-wth-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
                                      and  buf-arh-wth-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
                                      and  buf-arh-wth-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
                                      and  buf-arh-wth-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type
                                      and buf-arh-wth-cli-doc.sum-type = tt-parts-cli-doc.sum-type
                                      and  buf-arh-wth-cli-doc.fact-order < buf-arh_wth-doc.fact-order
                                      no-error.
    if available  buf-arh-wth-cli-doc then do:
      delete buf-arh-wth-cli-doc.
    end.
    for each  buf-recalc-cli-doc where buf-recalc-cli-doc.fact-order > buf-arh_wth-doc.fact-order
          and buf-recalc-cli-doc.wth-code = tt-parts-cli-doc.wth-code
          and buf-recalc-cli-doc.par-code = tt-parts-cli-doc.par-code
          and buf-recalc-cli-doc.cli-type = tt-parts-cli-doc.cli-type
          and buf-recalc-cli-doc.cli-code = tt-parts-cli-doc.cli-code
          and buf-recalc-cli-doc.host-code     = tt-parts-cli-doc.host-code
          and buf-recalc-cli-doc.contract-code = tt-parts-cli-doc.contract-code
          and buf-recalc-cli-doc.gds-code      = tt-parts-cli-doc.gds-code
          and buf-recalc-cli-doc.obj-type      = tt-parts-cli-doc.obj-type
          and buf-recalc-cli-doc.obj-code      = tt-parts-cli-doc.obj-code
          and buf-recalc-cli-doc.w-p-code      = tt-parts-cli-doc.w-p-code
          and buf-recalc-cli-doc.sum-type      = tt-parts-cli-doc.sum-type
          and buf-recalc-cli-doc.ext-doc-type  = tt-parts-cli-doc.ext-doc-type:
          assign buf-recalc-cli-doc.out-qnty     = buf-recalc-cli-doc.out-qnty - tt-parts-cli-doc.out-qnty
                buf-recalc-cli-doc.out-sum-rubl = buf-recalc-cli-doc.out-sum-rubl - tt-parts-cli-doc.out-sum-rubl
                buf-recalc-cli-doc.out-sum-base = buf-recalc-cli-doc.out-sum-base - tt-parts-cli-doc.out-sum-base
                buf-recalc-cli-doc.in-qnty       = buf-recalc-cli-doc.in-qnty - tt-parts-cli-doc.in-qnty
                buf-recalc-cli-doc.in-sum-rubl  = buf-recalc-cli-doc.in-sum-rubl - tt-parts-cli-doc.in-sum-rubl
                buf-recalc-cli-doc.in-sum-base  = buf-recalc-cli-doc.in-sum-base - tt-parts-cli-doc.in-sum-base
                .
    end.
  end.
  for each  tt-parts-cli-tot:
    find last  buf-arh-wth-cli-tot where   buf-arh-wth-cli-tot.cli-type =  tt-parts-cli-tot.cli-type
                                      and  buf-arh-wth-cli-tot.cli-code =  tt-parts-cli-tot.cli-code
                                      and  buf-arh-wth-cli-tot.obj-type =  tt-parts-cli-tot.obj-type
                                      and  buf-arh-wth-cli-tot.obj-code =  tt-parts-cli-tot.obj-code
                                      and  buf-arh-wth-cli-tot.ext-doc-type =  tt-parts-cli-tot.ext-doc-type
                                      and  buf-arh-wth-cli-tot.sum-type = tt-parts-cli-tot.sum-type
                                      and  buf-arh-wth-cli-tot.fact-order = buf-arh_wth-doc.fact-order
                                      no-error.
    if available buf-arh-wth-cli-tot then do:
        delete buf-arh-wth-cli-tot.
    end.
    for each buf-recalc-cli-tot where buf-recalc-cli-tot.fact-order > buf-arh_wth-doc.fact-order
          and buf-recalc-cli-tot.cli-type = tt-parts-cli-tot.cli-type
          and buf-recalc-cli-tot.cli-code = tt-parts-cli-tot.cli-code
          and buf-recalc-cli-tot.obj-type = tt-parts-cli-tot.obj-type
          and buf-recalc-cli-tot.obj-code = tt-parts-cli-tot.obj-code
          and buf-recalc-cli-tot.sum-type = tt-parts-cli-tot.sum-type
          and buf-recalc-cli-tot.ext-doc-type = tt-parts-cli-tot.ext-doc-type
          :
          assign buf-recalc-cli-tot.out-qnty     = buf-recalc-cli-tot.out-qnty - tt-parts-cli-tot.out-qnty
                buf-recalc-cli-tot.out-sum-rubl = buf-recalc-cli-tot.out-sum-rubl - tt-parts-cli-tot.out-sum-rubl
                buf-recalc-cli-tot.out-sum-base = buf-recalc-cli-tot.out-sum-base - tt-parts-cli-tot.out-sum-base
                buf-recalc-cli-tot.in-qnty       = buf-recalc-cli-tot.in-qnty - tt-parts-cli-tot.in-qnty
                buf-recalc-cli-tot.in-sum-rubl = buf-recalc-cli-tot.in-sum-rubl - tt-parts-cli-tot.in-sum-rubl
                buf-recalc-cli-tot.in-sum-base = buf-recalc-cli-tot.in-sum-base - tt-parts-cli-tot.in-sum-base
                .
    end.
  end.
end.
end procedure.
define buffer buf_wth-doc     for ub.wth-doc .
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_out-doc for ub.wth-doc.
define variable v-db-doc        as integer      no-undo.
define variable v-db-out-doc    as integer      no-undo.
main-block: do  transaction
on error  undo main-block, return error substitute( "&1 &2 &3&4&5&6&7", vss-workfile,vss-revision,vss-description,chr(10), return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  define variable l-shift-on      as logical   no-undo .
  define variable varobj-date     as date                      no-undo.
  define variable varshift-date   like ub.shift-obj.shift-date no-undo.
  define variable varshift-num    like ub.shift-obj.shift-num  no-undo.
  define variable varshift-name as character no-undo.
  find first buf_wth-doc exclusive-lock
    where buf_wth-doc.doc-code = p-doc-code
    no-error .
  if not available buf_wth-doc then do:
    undo, return error substitute("&1 &3 &4",
                          "Ошибка задания входных параметров."  ,
                          "Документ МЦ"  ,
                          p-doc-code).
  end.
  if not g#news then do:
    if buf_wth-doc.doc-type = 'рас':U and not buf_wth-doc.exter_ then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,output v-db-doc
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_wth-doc.cli-type
  ,input  buf_wth-doc.cli-code
  ,output v-db-out-doc
  )  .
        if v-db-doc <> v-db-out-doc then do:
        undo, return error   substitute("Документ создан для объектов  с разными номерам БД.&4Номер БД документа &5&4Номер БД порожденного документа  &6",
                       vss-workfile,
                       vss-revision,
                       vss-description,
                       chr(10),
                       v-db-doc,
                       v-db-out-doc)
           .
        end.
    end.
    find first buf_out-doc no-lock where
            buf_out-doc.source-ref = buf_wth-doc.doc-code
        and buf_out-doc.source-type = 'док.МЦ':U
        and buf_out-doc.borned no-error.
    if available buf_out-doc then do:
      if buf_out-doc.status_ <> 'факт':U then do:
        undo, return error substitute('Нельзя удалять связанный документ не в статусе &1.&2Номер документа &3',
                                      'факт':U,
                                      chr(10),
                                      buf_out-doc.doc-code
                                      ).
      end.
      run trg/wthdocdl.p ( buf_out-doc.doc-code
                          ,input parphchip-num
                          ,input p-file-name-err
                          ,output parchip-num
                          ) no-error.
        if error-status:error then do:
              undo, return error return-value.
        end.
        parphchip-num =  parchip-num .
    end.
  end.
  if not g#news or (g#news and  g#db-num  = 0)  then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,output varobj-date
  ) no-error .
    if error-status :error
    or varobj-date = ?
    then do:
      undo, return error   "Нет текущей даты на объекте продажи".
    end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
    if l-shift-on then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_wth-doc.obj-type
  ,input  buf_wth-doc.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
      if error-status :error then do:
        undo, return error   "Ошибка при поиске текущей смены на объекте " .
      end.
    end.
    else do:
      assign
        varshift-date = ?
        varshift-num  = ?.
    end.
    run trg/lock-wth.p
      (input p-doc-code
      ,input yes
      ,input buf_wth-doc.fact-order
      ,input (buf_wth-doc.status_ = 'факт':U)
      ,input g#news
      ) no-error .
    if error-status :error
    then do:
      message
        "Не удалось наложить блокировку на все товары принадлежащие документу" skip
        "Документ" buf_wth-doc.doc-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box information .
      undo , return error .
    end.
  end.
    assign
      buf_wth-doc.is-del = true
    .
    if not g#news then do:
      run hstc-wth-doc in this-procedure
        (input recid(buf_wth-doc)
        ,input varobj-date
        ,input varshift-date
        ,input varshift-num
        ,input varshift-name
        ,input g#userid
        ,input buf_wth-doc.source-ref
        ,input parphchip-num
        ,output parchip-num
        ) .
    end.
  if not g#news or (g#news and  g#db-num  = 0)  then do:
    define buffer buf_chk-doc for ub.chk-doc.
    define buffer buf_chk-pay for  ub.chk-pay.
    define buffer buf_c-chk-doc for  ub.c-chk-doc.
    define buffer buf_c-chk-pay for  ub.c-chk-pay.
    for each buf_chk-doc exclusive-lock
      where buf_chk-doc.out-code = buf_wth-doc.doc-code
        and BUF_chk-doc.obj-type = buf_wth-doc.obj-type
        and buf_chk-doc.obj-code = buf_wth-doc.obj-code
    on error undo, return error
    :
    if  lookup(string(buf_chk-doc.chk-type),'2,3,4,5,7':U )  = 0 then next.
      for each buf_chk-pay
        where buf_chk-pay.doc-code = buf_chk-doc.doc-code
      on error undo, return error
      :
        assign
          buf_chk-pay.out-code = ?
        .
        if g#news then do:
          delete buf_chk-pay.
        end.
      end.
      for each buf_c-chk-doc
        where buf_c-chk-doc.doc-code = buf_c-chk-doc.doc-code
      on error undo, return error
      :
        assign
          buf_c-chk-doc.out-code = ?
        .
        if g#news then do:
          delete buf_c-chk-doc.
        end.
      end.
      for each buf_c-chk-pay
        where buf_c-chk-pay.doc-code = buf_c-chk-doc.doc-code
      on error undo, return error
      :
        assign
          buf_c-chk-pay.out-code = ?
        .
        if g#news then do:
          delete buf_c-chk-pay.
        end.
      end.
      assign
        buf_chk-doc.out-code = ?
      .
      if g#news then do:
        delete buf_chk-doc.
      end.
    end.
    run wth-arhdoc-delete in this-procedure ( buf_wth-doc.doc-code
                            )  no-error.
    if error-status :error
    then do:
      undo Main-Block, return error return-value .
    end.
  end.
  if buf_wth-doc.status_ = 'факт':U
  and (not g#news or (g#news and  g#db-num  = 0))
  then do:
        run str/chkwthd.p
          ( input p-doc-code
          , p-file-name-err
           ) no-error .
        if error-status :error
        then do:
          undo Main-Block, return error return-value .
        end.
  end.
  for each buf_wth-parts exclusive-lock
    where buf_wth-parts.doc-code = buf_wth-doc.doc-code
    on error undo Main-Block, return error return-value:
    if lookup(buf_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) > 0 then delete buf_wth-parts.
  end.
  for each buf_wth-parts where buf_wth-parts.out-code = buf_wth-doc.doc-code
    on error undo Main-Block, return error return-value:
         run wth-doc-razrez in this-procedure
          (INPUT RECID(buf_wth-parts),
           input yes
          ).
  end.
      define variable v-obj-type   as character no-undo .
      define variable v-obj-code   as integer   no-undo .
      define variable v-fact-order as decimal   no-undo .
      define variable v-doc-code     like ub.wth-doc.doc-code no-undo .
      define variable v-fact-date    like ub.wth-doc.fact-date     no-undo .
      define variable v-user-db-num  like ub.wth-doc.user-db-num   no-undo .
      define variable v-user-name    like ub.wth-doc.user-name     no-undo .
      define variable v-sys-date     like ub.wth-doc.sys-date      no-undo .
      define variable v-sys-time-int like ub.wth-doc.sys-time-int  no-undo .
      define variable v-sys-time     like ub.wth-doc.sys-time      no-undo .
      assign
        v-obj-type   = buf_wth-doc.obj-type
        v-obj-code   = buf_wth-doc.obj-code
        v-fact-order = buf_wth-doc.fact-order
        v-doc-code   = buf_wth-doc.doc-code
        v-fact-date  = buf_wth-doc.fact-date
        v-user-db-num = buf_wth-doc.user-db-num
        v-user-name   = buf_wth-doc.user-name
        v-sys-date   = buf_wth-doc.sys-date
        v-sys-time   = buf_wth-doc.sys-time
        v-sys-time-int   = buf_wth-doc.sys-time-int
      .
      delete buf_wth-doc .
   if not g#news or (g#news and  g#db-num  = 0)  then do:
      run str/reclcwtf.p
        (input v-obj-type
        ,input v-obj-code
        ,input v-fact-order
        ,input no
        ,input 'delete':U
        ,input v-doc-code
        ,input v-fact-date
        ,input v-user-db-num
        ,input v-user-name
        ,input v-sys-date
        ,input v-sys-time-int
        ,input v-sys-time
        ) .
    end.
  end.
procedure hstc-wth-doc :
  define input parameter parrec-wth-doc as   recid                 no-undo.
  define input parameter parobj-date    as   date                    no-undo.
  define input parameter parshift-date  like ub.shift-obj.shift-date no-undo.
  define input parameter parshift-num   like ub.shift-obj.shift-num  no-undo.
  define input parameter parshift-name  like ub.shift-obj.shift-name no-undo.
  define input parameter paruserid      as   character               no-undo.
  define input parameter parout-code    like ub.wth-doc.source-ref   no-undo.
  define input  parameter parphchip-num      as   integer                      no-undo.
  define output parameter parchip-num        as   integer                      no-undo.
  define buffer hstc_wth-doc          for ub.wth-doc.
  define buffer hstc_wth-line         for ub.wth-line.
  define buffer hstc_wth-dtl          for ub.wth-dtl.
  define buffer hstc_wth-parts        for ub.wth-parts.
  define buffer hstc_c-wth-doc        for ub.c-wth-doc.
  define buffer hstc_c-wth-line       for ub.c-wth-line.
  define buffer hstc_c-wth-dtl        for ub.c-wth-dtl.
  define buffer hstc_c-wth-parts      for ub.c-wth-parts.
  define buffer hstc_inkas-pay-wth    for ub.inkas-pay-wth.
  define buffer hstc_c-inkas-pay-wth  for ub.c-inkas-pay-wth.
  do
  on error undo, return error return-value
  :
    find first hstc_wth-doc
      where recid (hstc_wth-doc) = parrec-wth-doc
      .
    create hstc_c-wth-doc .
    buffer-copy hstc_wth-doc to hstc_c-wth-doc .
    assign
      hstc_c-wth-doc.chip-num        = (if parphchip-num <> ?
                                       then parphchip-num
                                       else next-value(s-corr-chip, ub))
      hstc_c-wth-doc.corr-inkas-code = buf_wth-doc.source-ref
      hstc_c-wth-doc.corr-date       = parobj-date
      hstc_c-wth-doc.corr-shift-date = parshift-date
      hstc_c-wth-doc.corr-shift-num  = parshift-num
      hstc_c-wth-doc.corr-shift-name  = parshift-name
      hstc_c-wth-doc.corr-user-name        = paruserid
      hstc_c-wth-doc.corr-user-db-num = g#db-num
    .
    for each hstc_wth-line
      where hstc_wth-line.doc-code = hstc_wth-doc.doc-code
    on error undo, return error
    :
      create hstc_c-wth-line.
      buffer-copy hstc_wth-line to hstc_c-wth-line.
      assign
      hstc_c-wth-line.corr-user-db-num = hstc_c-wth-doc.corr-user-db-num
      hstc_c-wth-line.chip-num = hstc_c-wth-doc.chip-num
      .
    end.
    for each hstc_wth-dtl
      where hstc_wth-dtl.doc-code = hstc_wth-doc.doc-code
    on error undo, return error
    :
      create hstc_c-wth-dtl.
      buffer-copy hstc_wth-dtl to hstc_c-wth-dtl.
      assign
      hstc_c-wth-dtl.corr-user-db-num = hstc_c-wth-doc.corr-user-db-num
      hstc_c-wth-dtl.chip-num = hstc_c-wth-doc.chip-num
      .
    end.
    for each hstc_wth-parts
      where hstc_wth-parts.out-code = hstc_wth-doc.doc-code
    on error undo, return error
    :
      create hstc_c-wth-parts.
      buffer-copy hstc_wth-parts to hstc_c-wth-parts.
      assign
      hstc_c-wth-parts.corr-user-db-num = hstc_c-wth-doc.corr-user-db-num
      hstc_c-wth-parts.chip-num = hstc_c-wth-doc.chip-num
      .
    end.
    for each hstc_inkas-pay-wth where
            hstc_inkas-pay-wth.inkas-code = hstc_wth-doc.doc-code
    on error undo, return error
            :
      create hstc_c-inkas-pay-wth.
      buffer-copy hstc_inkas-pay-wth to hstc_c-inkas-pay-wth.
      assign
        hstc_c-inkas-pay-wth.chip-num = hstc_c-wth-doc.chip-num
        hstc_c-inkas-pay-wth.corr-user-db-num = hstc_c-wth-doc.corr-user-db-num
        .
    end.
    assign
    parchip-num = hstc_c-wth-doc.chip-num
    .
  end.
end procedure.
