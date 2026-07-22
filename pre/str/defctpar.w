DEFINE BUFFER Buf_bar-code FOR ub.bar-code.
DEFINE BUFFER Buf_goods FOR ub.goods.
DEFINE TEMP-TABLE x_parts NO-UNDO LIKE ub.parts.
define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-handle      as handle no-undo .
define input  parameter p-obj-type    like ub.clients.obj-type no-undo.
define input  parameter p-obj-code    like ub.shop.obj-code no-undo.
define input  parameter p-mode        as character no-undo .
define input  parameter p-obj as integer   no-undo .
define output parameter table for x_parts .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Управление  Фальсифицированными и бракованными партиями товаров".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure godendo-date-to-offset :
  define input  parameter p-today  as date      no-undo .
  define input  parameter p-date   as date      no-undo .
  define output parameter p-offset as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-date  = ?
    or p-today = ?
    then do:
      assign
        p-offset = ?
      .
    end.
    else do:
      assign
        p-offset = p-date - p-today + 1
      .
    end.
  end.
end procedure.
procedure godendo-offset-to-date :
  define input  parameter p-today  as date      no-undo .
  define input  parameter p-offset as integer   no-undo .
  define output parameter p-date   as date      no-undo .
  do
  on error undo, return error return-value
  :
    if p-today  = ?
    or p-offset = ?
    then do:
      assign
        p-date = ?
      .
    end.
    else do:
      assign
        p-date = p-offset + p-today - 1
      .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  new shared  temp-table bb-list no-undo like ub.goods
  field b-code as integer
  field b-str  as character
  field f-name like ub.gds-prt.f-name
  field bc-cli-base-rate like ub.bar-code.cli-base-rate
  field bc-cr-db-num     like ub.bar-code.cr-db-num
  field in-code       like ub.bar-code.in-code
  field node-code     like ub.bar-code.node-code
  field part-code     like ub.bar-code.part-code
  field stts_         like ub.bar-code.stts_
  field bc-unit-cli      like ub.bar-code.unit-cli
  field bc-on-type    like ub.prod-bc.bc-on-type
  field bc-on         like ub.prod-bc.bc-on
  field pbc-cr-db-num     like ub.prod-bc.cr-db-num
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field loc-ean as logical
  index pi  is primary unique b-code b-str
  index art artic prod-type prod-code
  index code gds-code
  index oi order-num
  index ibc-on-type bc-on-type
  index iprt
  gds-code
  node-code
  part-code
  in-code
  unit-cli
  b-str
  index iprt2
  gds-code
  node-code
  unit-cli
  part-code
  in-code
  b-str
  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   new shared   temp-table bb-list-hist no-undo
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
def var vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable rid-list as character no-undo .
define variable filter-point as character no-undo init "Специальный список партий" .
define variable filter-point0 as character no-undo init "СпецСписок_партий_" .
define variable sort-column-name as character no-undo .
define variable v-srok as integer   no-undo .
define variable v-srok-date as date no-undo .
define variable v-today as date      no-undo .
define variable v-time as integer   no-undo .
define variable doc-rec as recid no-undo .
define variable g-log as logical   no-undo .
define variable v-tth     as handle no-undo .
define temp-table temp-parts no-undo like ub.parts.
define variable v-host-code as integer   no-undo .
define variable gds-rec                     as recid no-undo.
define variable vf-obj-name as character no-undo .
define variable vf-cli-name as character no-undo .
define temp-table temp-obj no-undo
field obj-type as character
field obj-code as integer
index pi
obj-type
obj-code
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
  DEFINE TEMP-TABLE xx_parts NO-UNDO LIKE ub.parts.
FUNCTION f-obj-name RETURN CHARACTER
( input p-recid as recid ).
define buffer bf_parts for x_parts  .
  find first  bf_parts no-lock where recid(bf_parts) = p-recid no-error .
  if not available bf_parts then RETURN "".
  find first  ub.clients no-lock where
              ub.clients.obj-code = bf_parts.obj-code and
              ub.clients.obj-type = bf_parts.obj-type no-error .
              if not available ub.clients then RETURN "".
  return ub.clients.obj-name .
END FUNCTION.
FUNCTION f-cli-name RETURN CHARACTER
( input p-recid as recid ).
define buffer bf_parts for x_parts  .
  find first  bf_parts no-lock where recid (bf_parts) = p-recid no-error .
  if not available bf_parts then RETURN "" .
  find first  ub.clients no-lock where
              ub.clients.obj-code = bf_parts.supp-code and
              ub.clients.obj-type = bf_parts.supp-type no-error .
              if not available ub.clients then RETURN "".
  return ub.clients.obj-name .
END FUNCTION.
DEFINE MENU POPUP-MENU-b-make-add
       MENU-ITEM m_pri          LABEL "По списку ПН"
       MENU-ITEM m_goods        LABEL "По списку товаров"
       MENU-ITEM m_b-code       LABEL "По списку кодов"
       MENU-ITEM m_serii        LABEL "По номеру серии".
DEFINE MENU POPUP-MENU-b-make-add-2
       MENU-ITEM m_pri-2        LABEL "По списку ПН"
       MENU-ITEM m_goods-2      LABEL "По списку товаров"
       MENU-ITEM m_b-code-2     LABEL "По списку кодов"
       MENU-ITEM m_serii-2      LABEL "По номеру серии2".
DEFINE MENU POPUP-MENU-b-make-trn
       MENU-ITEM m_ep           LABEL "Возврат поставщику"
       MENU-ITEM m_we           LABEL "Списание"
       MENU-ITEM m_ev           LABEL "Внутренний расход"
       MENU-ITEM m_iv           LABEL "Внутренний приход (запрос)".
DEFINE BUTTON b-add
     IMAGE-UP FILE "cmp/add.bmp":U
     IMAGE-DOWN FILE "cmp/add.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/add.bmp":U
     LABEL "&+"
     SIZE 2.88 BY .92 TOOLTIP "Добавить в список (Alt+)"
     BGCOLOR 8 .
DEFINE BUTTON b-add-2
     LABEL ".   Добавить"
     SIZE 12.75 BY 1 TOOLTIP "Добавить в список (Alt+)"
     BGCOLOR 8 .
DEFINE BUTTON b-Cancel AUTO-END-KEY
     LABEL "Вы&ход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-clear
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить из текущего списка"
     BGCOLOR 8 .
DEFINE BUTTON b-del
     IMAGE-UP FILE "cmp/deleterec.bmp":U
     IMAGE-DOWN FILE "cmp/deleterec.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/deleterec.bmp":U
     LABEL "&-"
     SIZE 2.88 BY .92 TOOLTIP "Удалить из списка (Alt-)"
     BGCOLOR 8 .
DEFINE BUTTON b-del-2
     LABEL ".   Удалить"
     SIZE 12 BY 1 TOOLTIP "Удалить из списка (Alt-)"
     BGCOLOR 8 .
DEFINE BUTTON b-del-mark
     LABEL "&="
     SIZE 3 BY 1 TOOLTIP "Снять все отметки в списке"
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&H"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-impotr-www
     IMAGE-UP FILE "cmp/www.bmp":U
     LABEL "&I"
     SIZE 6.5 BY 1 TOOLTIP "Импортировать из Excel ( Alt+I ) подготовленный файл программой ФАЛЬСИФИКАТ"
     BGCOLOR 8 .
DEFINE BUTTON b-make-add
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавление в список партии свободной зоны"
     BGCOLOR 8 .
DEFINE BUTTON b-make-trn
     LABEL "ГенНакл"
     SIZE 10 BY 1 TOOLTIP "Сделать по выделенным партия накладную"
     BGCOLOR 8 .
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1 TOOLTIP "Отметить записи в списке"
     BGCOLOR 8 .
DEFINE BUTTON b-mark-all
     LABEL "&+"
     SIZE 3 BY 1 TOOLTIP "Отметить ВСЕ записи в списке"
     BGCOLOR 8 .
DEFINE BUTTON b-print
     LABEL "П"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-report
     LABEL "Отчет"
     SIZE 10 BY 1 TOOLTIP "Отчеты"
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "&Ф"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по:"
      VIEW-AS TEXT
     SIZE 9.5 BY .67 NO-UNDO.
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Объект:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67 NO-UNDO.
DEFINE VARIABLE mark-num AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-sort-pole AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1 NO-UNDO.
DEFINE VARIABLE R-obj AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "текущий", 0,
"все", 1
     SIZE 16 BY 1 TOOLTIP "Партии по всем объектам или по текущему"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE R-sort AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "серии", 2,
"артикулу", 3,
"наименованию", 4
     SIZE 39.38 BY 1 TOOLTIP "Поиск по СЕРИИ (№ партии), артикулу или наименованию"
     FGCOLOR 4  NO-UNDO.
DEFINE QUERY BROWSE-2 FOR
      x_parts,
      Buf_goods,
      Buf_bar-code SCROLLING.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 NO-LOCK DISPLAY
      mark-string(recid( x_parts), rid-list) COLUMN-LABEL '*'  FORMAT "X(1)":U
      x_parts.artic COLUMN-LABEL 'Артикул! '  FORMAT "X(16)":U
      x_parts.part-code COLUMN-LABEL 'Серия!№ партии'  FORMAT "X(20)":U
      Buf_bar-code.b-code COLUMN-LABEL 'Бар-код!партии'  FORMAT "999999999":U
      Buf_goods.gds-name COLUMN-LABEL 'Наименование!товара'  FORMAT "X(40)":U
      f-obj-name(recid( x_parts))   @ vf-obj-name  COLUMN-LABEL 'Объект!Название'  FORMAT "X(20)":U
      x_parts.fact-date COLUMN-LABEL 'Дата ПН! '  FORMAT "99/99/9999":U
      x_parts.fact-qnty COLUMN-LABEL 'Остатки!количество'  FORMAT "->>,>>>,>>9.999":U
      x_parts.in-code COLUMN-LABEL '№ ПН! '  FORMAT "X(14)":U
      x_parts.last-date COLUMN-LABEL 'Последний срок!реализации'  FORMAT "99/99/9999":U
      x_parts.dop COLUMN-LABEL 'Цена!Производителя'  FORMAT "x(13)":U
      x_parts.defect COLUMN-LABEL 'ФиБ! '  FORMAT "9":U
      x_parts.price-cli COLUMN-LABEL 'Цена!(вал.пост)'  FORMAT "->>,>>>,>>>,>>9.999":U
      x_parts.price-rubl COLUMN-LABEL 'Цена уч!руб'  FORMAT "->>,>>>,>>9.99":U
      x_parts.obj-type COLUMN-LABEL 'Объект!тип'  FORMAT "X(3)":U
      x_parts.obj-code COLUMN-LABEL 'Объект!код'  FORMAT "99999":U
      x_parts.vat-type COLUMN-LABEL 'Тип!НДС'  FORMAT "X(6)":U
      x_parts.vat-pc COLUMN-LABEL '%!НДС'  FORMAT ">>9.99":U
      f-cli-name(recid( x_parts))   @ vf-cli-name  COLUMN-LABEL 'Контрагент!Название'  FORMAT "X(30)":U
      enable x_parts.artic
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.25 BY 17.54 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     BROWSE-2 AT ROW 4.75 COL 1.25 WIDGET-ID 200
     b-Cancel AT ROW 1 COL 1
     b-add-2 AT ROW 1 COL 11.13 WIDGET-ID 48
     b-add AT ROW 1.04 COL 11.63 WIDGET-ID 10
     b-del-2 AT ROW 1 COL 24 WIDGET-ID 50
     b-del AT ROW 1 COL 24 WIDGET-ID 12
     b-impotr-www AT ROW 1 COL 36 WIDGET-ID 16
     b-make-trn AT ROW 1 COL 42.63 WIDGET-ID 8
     b-report AT ROW 1 COL 52.63 WIDGET-ID 40
     b-make-add AT ROW 1 COL 62.75 WIDGET-ID 24
     b-clear AT ROW 1 COL 73 WIDGET-ID 20
     b-sch AT ROW 1 COL 90.5 WIDGET-ID 4
     b-print AT ROW 1 COL 92.5 WIDGET-ID 2
     b-help AT ROW 1 COL 94.5
     R-sort AT ROW 2.13 COL 11.25 NO-LABEL WIDGET-ID 30
     v-sort-pole AT ROW 2.13 COL 48.63 COLON-ALIGNED NO-LABEL WIDGET-ID 38
     R-obj AT ROW 2.25 COL 81 NO-LABEL WIDGET-ID 42
     b-mark AT ROW 3.71 COL 1.75 WIDGET-ID 14
     b-mark-all AT ROW 3.71 COL 4.88 WIDGET-ID 28
     FILL-IN-1 AT ROW 2.25 COL 2 NO-LABEL WIDGET-ID 36
     b-del-mark AT ROW 3.71 COL 7.88 WIDGET-ID 26
     FILL-IN-2 AT ROW 2.38 COL 73.13 NO-LABEL WIDGET-ID 46
     mark-num AT ROW 4 COL 9.5 COLON-ALIGNED NO-LABEL WIDGET-ID 18
     SPACE(82.37) SKIP(17.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Управление списком партий"
         CANCEL-BUTTON b-Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-make-add:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-make-add:HANDLE.
ASSIGN
       b-make-trn:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-make-trn:HANDLE.
ASSIGN
       b-report:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-make-add-2:HANDLE.
ASSIGN
       BROWSE-2:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
define variable i as integer   no-undo .
define variable ii as integer   no-undo .
define buffer buf_parts for ub.parts  .
empty temp-table temp-parts.
run str/defctpar.w
( parparentproc ,
  this-procedure,
  v-cntxt-obj-type,
  v-cntxt-obj-code,
  "add-new-fib" ,
  p-obj,
  output TABLE temp-parts)
  no-error .
run waitfram-show in this-procedure ("Отметка ФиБ на партиях") .
  for each temp-parts :
      find first x_parts no-lock  where
            x_parts.obj-code   = temp-parts.obj-code and
            x_parts.obj-type   = temp-parts.obj-type  and
            x_parts.artic      = temp-parts.artic  and
            x_parts.prod-type  = temp-parts.prod-type  and
            x_parts.prod-code  = temp-parts.prod-code  and
            x_parts.out-code   = temp-parts.out-code  and
            x_parts.in-code    = temp-parts.in-code  and
            x_parts.part-code  = temp-parts.part-code  no-error .
       if not available x_parts then do:
           i = i + 1 .
           ii = ii + 1 .
           create x_parts.
           buffer-copy temp-parts to x_parts
              assign
                 x_parts.defect = logical('yes':U)
           .
            run save-proc in this-procedure
            ( buffer x_parts ) .
       end.
  end.
  run waitfram-hide in this-procedure .
  run OpenBr in this-procedure (yes, no, '':U).
  if r-obj = 1 then do:
     message substitute ( "Добавлено &1 партий в список ФиБ партий по всем объектам " , i , ii ) view-as alert-box .
  end.
  else do:
     message substitute ( "Добавлено &1 партий в список ФиБ партий по текущему объекту " , i , ii ) view-as alert-box .
  end.
END.
ON CHOOSE OF b-add-2 IN FRAME Dialog-Frame
DO:
  apply "CHOOSE" to b-add IN FRAME Dialog-Frame .
END.
ON CHOOSE OF b-clear IN FRAME Dialog-Frame
DO:
define variable br-handle as handle no-undo .
define variable g#log as logical   no-undo .
define variable v-doc-rec as recid no-undo .
  find current x_parts no-error    .
  if not available x_parts then return .
  delete x_parts.
  br-handle = BROWSE-2:handle in frame Dialog-Frame .
  if valid-handle (br-handle) then do:
    g#log = br-handle:select-next-row().
    if not g#log then g#log = br-handle:select-prev-row().
    v-doc-rec = recid (x_parts) .
  end.
   run OpenBr in this-procedure (yes, no, '':U).
   apply "VALUE-CHANGED" to BROWSE-2 in frame Dialog-Frame.
   reposition BROWSE-2 to recid v-doc-rec no-error.
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable i as integer   no-undo .
define buffer buf_x_parts for x_parts  .
define buffer buf_parts for ub.parts  .
if num-entries ( rid-list ) = 0  then do:
  find current x_parts no-error    .
  if not available x_parts then return .
  assign
    x_parts.defect = false
  .
      run save-proc in this-procedure
      ( buffer x_parts ) .
    delete x_parts no-error .
end.
else do:
  do i = 1 to num-entries(rid-list) :
  find first buf_x_parts where recid(buf_x_parts) = int(entry(i,rid-list)) no-error.
  if not available buf_x_parts then next .
  assign
    buf_x_parts.defect = false
  .
      run save-proc in this-procedure
      ( buffer buf_x_parts ) .
      for each   buf_parts exclusive-lock  where
                  buf_parts.artic      = buf_x_parts.artic      and
                  buf_parts.prod-type  = buf_x_parts.prod-type  and
                  buf_parts.prod-code  = buf_x_parts.prod-code  and
                  buf_parts.part-code  = buf_x_parts.part-code  and
                  buf_parts.out-code   = 'free-zone':U           and
                  buf_parts.defect = logical('yes':U)
                  :
            buf_parts.defect = false   .
        end.
    delete buf_x_parts no-error .
  end.
  rid-list = "".
end.
run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF b-del-2 IN FRAME Dialog-Frame
DO:
  apply "CHOOSE" to b-del IN FRAME Dialog-Frame .
END.
ON CHOOSE OF b-del-mark IN FRAME Dialog-Frame
DO:
rid-list = "".
g-log = BROWSE-2:refresh() .
apply "entry" to BROWSE-2 in frame Dialog-Frame.
END.
ON CHOOSE OF b-impotr-www IN FRAME Dialog-Frame
DO:
define variable i as integer   no-undo .
define variable ii as integer   no-undo .
define buffer buf_parts for ub.parts  .
empty temp-table temp-parts.
run str/imp-fib.w
( parparentproc  ,
  this-procedure ,
  output TABLE temp-parts )
  no-error .
find first temp-parts no-error .
if not available temp-parts then return .
run waitfram-show in this-procedure ("Отметка ФиБ на партиях") .
  for each temp-parts :
      find first x_parts no-lock  where
            x_parts.obj-code   = temp-parts.obj-code and
            x_parts.obj-type   = temp-parts.obj-type  and
            x_parts.artic      = temp-parts.artic  and
            x_parts.prod-type  = temp-parts.prod-type  and
            x_parts.prod-code  = temp-parts.prod-code  and
            x_parts.out-code   = temp-parts.out-code  and
            x_parts.in-code    = temp-parts.in-code  and
            x_parts.part-code  = temp-parts.part-code  no-error .
       if not available x_parts then do:
           i = i + 1 .
           ii = ii + 1 .
           create x_parts.
           buffer-copy temp-parts to x_parts
              assign
                 x_parts.whole-send-news = int('yes':U)
           .
            run save-proc in this-procedure
            ( buffer x_parts ) .
       end.
  end.
  run waitfram-hide in this-procedure .
  run OpenBr in this-procedure (yes, no, '':U).
  if r-obj = 1 then do:
     message substitute ( "Добавлено &1 партий в список ФиБ партий по всем объектам " , i , ii ) view-as alert-box .
  end.
  else do:
     message substitute ( "Добавлено &1 партий в список ФиБ партий по текущему объекту " , i , ii ) view-as alert-box .
  end.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
      if available x_parts then do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid19 as character no-undo .
define variable v-num-entry19 as integer   no-undo .
assign
  v-str-recid19 = trim( string( recid( x_parts ) , "->>>>>>>>>>>9":U ) )
  v-num-entry19 = lookup( v-str-recid19 , rid-list )
.
if v-num-entry19 > 0 then do:
  assign
    entry( v-num-entry19, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid19
  .
end.
        g-log = BROWSE-2:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = BROWSE-2:select-next-row ().
            apply "VALUE-CHANGED" to BROWSE-2 in frame Dialog-Frame.
        end.
        if num-entries( rid-list ) = 0
        then
            hide mark-num in frame Dialog-Frame.
        else do:
            end.
    end.
    apply "entry" to BROWSE-2 in frame Dialog-Frame.
END.
ON CHOOSE OF b-mark-all IN FRAME Dialog-Frame
DO:
       for each x_parts :
          if length (rid-list) >= 31000 then leave.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid21 as character no-undo .
define variable v-num-entry21 as integer   no-undo .
assign
  v-str-recid21 = trim( string( recid( x_parts ) , "->>>>>>>>>>>9":U ) )
  v-num-entry21 = lookup( v-str-recid21 , rid-list )
.
if v-num-entry21 > 0 then do:
  assign
    entry( v-num-entry21, rid-list ) = "":U
    rid-list = trim( replace( rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    rid-list = rid-list + ( if rid-list = "":U then "":U else chr(44) ) + v-str-recid21
  .
end.
       end.
        g-log = BROWSE-2:refresh() .
        if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            g-log = BROWSE-2:select-next-row ().
            apply "VALUE-CHANGED" to BROWSE-2 in frame Dialog-Frame.
        end.
END.
ON CHOOSE OF b-report IN FRAME Dialog-Frame
DO:
 case p-mode :
  when "srok" then do:
    run rep/g-sroki.p (parparentproc) .
  end.
  when "defect" then do:
    run rep/g-defect.p (parparentproc) .
  end.
 end case.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF MENU-ITEM m_b-code
DO:
define buffer doc_parts for ub.parts  .
run str/bb-list.w (
                   input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input '').
 for each bb-list :
        for each temp-obj,
            each doc_parts no-lock where
                 doc_parts.in-code    = bb-list.in-code and
                 doc_parts.part-code  = bb-list.part-code and
                 doc_parts.obj-type   = temp-obj.obj-type and
                 doc_parts.obj-code   = temp-obj.obj-code and
                 doc_parts.artic      = bb-list.artic and
                 doc_parts.prod-type  = bb-list.prod-type and
                 doc_parts.prod-code  = bb-list.prod-code and
                 doc_parts.out-code   = 'free-zone':U
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .
            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
 end.
 run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF MENU-ITEM m_b-code-2
DO:
define buffer doc_parts for ub.parts  .
run str/bb-list.w (
                   input parparentproc
                  ,input p-obj-type
                  ,input p-obj-code
                  ,input '').
 for each bb-list :
       for each temp-obj ,
           each doc_parts no-lock where
                 doc_parts.in-code    = bb-list.in-code and
                 doc_parts.part-code  = bb-list.part-code and
                 doc_parts.obj-type   = temp-obj.obj-type and
                 doc_parts.obj-code   = temp-obj.obj-code and
                 doc_parts.artic      = bb-list.artic and
                 doc_parts.prod-type  = bb-list.prod-type and
                 doc_parts.prod-code  = bb-list.prod-code and
                 doc_parts.out-code   = 'free-zone':U
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .
            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
 end.
 run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF MENU-ITEM m_ep
DO:
  run make-xx-part .
  run str/epimport.p
  ( parparentproc ,
    this-procedure,
    'ep':U,
    input TABLE xx_parts
    ) no-error .
    if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "от str/epimport.p"
         view-as alert-box error
       .
    end.
  message return-value view-as alert-box information .
  run ini-proc.
  run my_enable.
  run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF MENU-ITEM m_ev
DO:
  run make-xx-part .
  run str/epimport.p
  ( parparentproc ,
    this-procedure,
    'ev':U,
    input TABLE xx_parts
    ) no-error .
    if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "от str/epimport.p"
         view-as alert-box error
       .
    end.
  if return-value <> "" then do:
     message return-value view-as alert-box information .
  end.
  run ini-proc.
  run my_enable.
  run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF MENU-ITEM m_goods
DO:
define buffer doc_parts for ub.parts  .
run str/gds-list.w ( input parparentproc , input v-host-code, input p-obj-type, input p-obj-code ).
for each gds-list :
       for each temp-obj,
           each doc_parts no-lock where
                 doc_parts.obj-type   = temp-obj.obj-type and
                 doc_parts.obj-code   = temp-obj.obj-code and
                 doc_parts.artic      = gds-list.artic and
                 doc_parts.prod-type  = gds-list.prod-type and
                 doc_parts.prod-code  = gds-list.prod-code and
                 doc_parts.out-code   = 'free-zone':U
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .
            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
end.
run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF MENU-ITEM m_goods-2
DO:
define buffer doc_parts for ub.parts  .
run str/gds-list.w ( input parparentproc , input v-host-code, input p-obj-type, input p-obj-code ).
for each gds-list :
        for each temp-obj,
            each doc_parts no-lock where
                 doc_parts.obj-type   = temp-obj.obj-type and
                 doc_parts.obj-code   = temp-obj.obj-code and
                 doc_parts.artic      = gds-list.artic and
                 doc_parts.prod-type  = gds-list.prod-type and
                 doc_parts.prod-code  = gds-list.prod-code and
                 doc_parts.out-code   = 'free-zone':U
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .
            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
end.
run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF MENU-ITEM m_iv
DO:
  run make-xx-part .
  run str/epimport.p
  ( parparentproc ,
    this-procedure,
    'iv':U,
    input TABLE xx_parts
    ) no-error .
    if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "от str/epimport.p"
         view-as alert-box error
       .
    end.
  if return-value <> "" then do:
     message return-value view-as alert-box information .
  end.
run ini-proc.
run my_enable.
run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF MENU-ITEM m_pri
DO:
  define variable loc-ref-list as character no-undo .
  run str/all-docs.w
 ( input  parparentproc
  ,input   v-host-code
  ,input   p-obj-type
  ,input   p-obj-code
  ,input  "status-all":U
  ,input  'факт':U
  ,input  'при':U
  ,input  ?
  ,input  no
  ,input  "b-mark,b-sel":U
  ,input  'ie':U
  ,input  false
  ,input  ?
  ,output loc-ref-list
  ).
if loc-ref-list = ?  or loc-ref-list = '' then return.
define buffer buf_trn-doc for ub.trn-doc  .
define buffer doc_parts for ub.parts  .
define buffer buf_doc-line for ub.doc-line  .
define variable i as integer   no-undo .
do i = 1 to num-entries(loc-ref-list) :
  for each buf_trn-doc no-lock where recid (buf_trn-doc) = int(entry(i,loc-ref-list)) :
      for each buf_doc-line no-lock where
               buf_doc-line.doc-code = buf_trn-doc.doc-code
        :
        for each doc_parts no-lock where
                 doc_parts.in-code    = buf_trn-doc.doc-code and
                 doc_parts.obj-type   = buf_trn-doc.obj-type and
                 doc_parts.obj-code   = buf_trn-doc.obj-code and
                 doc_parts.artic      = buf_doc-line.artic and
                 doc_parts.prod-type  = buf_doc-line.prod-type and
                 doc_parts.prod-code  = buf_doc-line.prod-code and
                 doc_parts.out-code   = 'free-zone':U
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .
            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
      end.
  end.
end.
run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF MENU-ITEM m_pri-2
DO:
  define variable loc-ref-list as character no-undo .
  run str/all-docs.w
 ( input  parparentproc
  ,input   v-host-code
  ,input   p-obj-type
  ,input   p-obj-code
  ,input  "status-all":U
  ,input  'факт':U
  ,input  'при':U
  ,input  ?
  ,input  no
  ,input  "b-mark,b-sel":U
  ,input  'ie':U
  ,input  false
  ,input  ?
  ,output loc-ref-list
  ).
if loc-ref-list = ?  or loc-ref-list = '' then return.
define buffer buf_trn-doc for ub.trn-doc  .
define buffer doc_parts for ub.parts  .
define buffer buf_doc-line for ub.doc-line  .
define variable i as integer   no-undo .
do i = 1 to num-entries(loc-ref-list) :
  for each buf_trn-doc no-lock where recid (buf_trn-doc) = int(entry(i,loc-ref-list)) :
      for each buf_doc-line no-lock where
               buf_doc-line.doc-code = buf_trn-doc.doc-code
        :
        for each doc_parts no-lock where
                 doc_parts.in-code    = buf_trn-doc.doc-code and
                 doc_parts.obj-type   = buf_trn-doc.obj-type and
                 doc_parts.obj-code   = buf_trn-doc.obj-code and
                 doc_parts.artic      = buf_doc-line.artic and
                 doc_parts.prod-type  = buf_doc-line.prod-type and
                 doc_parts.prod-code  = buf_doc-line.prod-code and
                 doc_parts.out-code   = 'free-zone':U
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .
            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
      end.
  end.
end.
run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF MENU-ITEM m_serii
DO:
define variable v-parts-code as character no-undo .
define buffer doc_parts for ub.parts  .
      run gbl/d-prompt.w
        ( 'title=':U + "Введите номер серии партии" + '\':U
        + 'type=character':U
        ,input-output v-parts-code
        ).
      if return-value = 'false':U
      then do:
        return .
      end.
  if v-parts-code = "" then do:
     message "Нельзя вводить пустое значение серии" view-as alert-box information .
     return .
  end.
   run waitfram-show in this-procedure ( substitute("Поиск товаров по серии  &1" ,v-parts-code )) .
      for each temp-obj,
         each doc_parts no-lock where
                 doc_parts.part-code  = v-parts-code and
                 doc_parts.obj-code   = temp-obj.obj-code and
                 doc_parts.obj-type   = temp-obj.obj-type and
                 doc_parts.out-code   = 'free-zone':U
        :
        find first x_parts no-lock where
                x_parts.part-code= doc_parts.part-code     and
                x_parts.in-code  = doc_parts.in-code       and
                x_parts.obj-type = doc_parts.obj-type      and
                x_parts.obj-code = doc_parts.obj-code      and
                x_parts.artic    = doc_parts.artic         and
                x_parts.prod-type= doc_parts.prod-type     and
                x_parts.prod-code= doc_parts.prod-code     and
                x_parts.out-code = doc_parts.out-code     no-error .
            if not available x_parts then  do:
                create x_parts.
                buffer-copy doc_parts to x_parts.
            end.
         end.
     run waitfram-hide.
run OpenBr in this-procedure (yes, no, '':U).
END.
ON CHOOSE OF MENU-ITEM m_we
DO:
  run make-xx-part .
  run str/epimport.p
  ( parparentproc ,
    this-procedure,
    'we':U,
    input TABLE xx_parts
    ) no-error .
    if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         error-status :get-message(1) skip
         return-value skip
         "от str/epimport.p"
         view-as alert-box error
       .
    end.
  message return-value view-as alert-box information .
  run ini-proc.
  run my_enable.
  run OpenBr in this-procedure (yes, no, '':U).
END.
ON VALUE-CHANGED OF R-obj IN FRAME Dialog-Frame
DO:
END.
ON VALUE-CHANGED OF R-sort IN FRAME Dialog-Frame
DO:
  assign r-sort.
END.
ON LEAVE OF v-sort-pole IN FRAME Dialog-Frame
DO:
END.
ON RETURN OF v-sort-pole IN FRAME Dialog-Frame
DO:
 assign r-sort v-sort-pole.
  case r-sort:
  when 1 then do:
     run proc-find-b-code in this-procedure(no, v-sort-pole) no-error.
  end.
  when 2 then do:
     run proc-find-part-code in this-procedure(no, v-sort-pole) no-error.
  end.
  when 3 then do:
     run proc-find-artic in this-procedure(no, v-sort-pole) no-error.
  end.
  when 4 then do:
     run proc-find-name in this-procedure(no, v-sort-pole) no-error.
  end.
  end case.
  return no-apply.
END.
ON CTRL-J  OF v-sort-pole IN FRAME Dialog-Frame
do:
 assign r-sort v-sort-pole .
  case r-sort:
  when 1 then do:
    run proc-find-b-code in this-procedure(yes, v-sort-pole) no-error.
  end.
  when 2 then do:
    run proc-find-part-code in this-procedure(yes, v-sort-pole) no-error.
  end.
  when 3 then do:
    run proc-find-artic in this-procedure(yes, v-sort-pole) no-error.
  end.
  when 4 then do:
    run proc-find-name in this-procedure(yes, v-sort-pole) no-error.
  end.
  end case.
  if error-status:error then return no-apply.
end.
b-make-trn:menu-mouse = 1.
b-make-add:menu-mouse = 1.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  run OpenBr in this-procedure (yes, no, '':U).
    apply "VALUE-CHANGED" to BROWSE-2.
end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  run gds-rec-proc.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to BROWSE-2 in frame Dialog-Frame.
  return no-apply.
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BROWSE-2 :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
def var sort-labelBROWSE-2   as character no-undo .
def var sort-clmnBROWSE-2    as handle    no-undo .
def var cur-clmnBROWSE-2     as handle    no-undo .
def var cur-clmn-locBROWSE-2 as integer   no-undo .
def var re-queryBROWSE-2     as logical   initial no no-undo .
on start-search, ctrl-o of BROWSE-2 in frame Dialog-Frame do:
   run sort-brBROWSE-2
     (input (if available x_parts
             then recid(x_parts)
             else ?
            )
     ).
end.
PROCEDURE sort-brBROWSE-2 :
  define input parameter p-recid as recid no-undo .
  if re-queryBROWSE-2 = no then do:
    assign
       cur-clmnBROWSE-2 = BROWSE-2:current-column in frame Dialog-Frame
    .
    if sort-clmnBROWSE-2 <> ? then sort-clmnBROWSE-2:column-fgcolor = 0.
    if cur-clmnBROWSE-2 = sort-clmnBROWSE-2 then do:
      assign
         sort-labelBROWSE-2 = ""
         sort-clmnBROWSE-2 = ?
      .
     end.
     else do:
       assign
         sort-labelBROWSE-2 = cur-clmnBROWSE-2:label
         sort-clmnBROWSE-2  = cur-clmnBROWSE-2
         sort-clmnBROWSE-2:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locBROWSE-2 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = BROWSE-2:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnBROWSE-2 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locBROWSE-2 = cur-clmn-locBROWSE-2 + 1
    .
  end.
  case sort-labelBROWSE-2:
        when '*'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1mark-string&1, recid(x_parts), &1&2&1)', chr(34), rid-list)     .     run OpenBr (yes, no, '':U).   . END.
        when 'Артикул! '  then DO:    assign       sort-column-name = "x_parts.artic"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Серия!№ партии'  then DO:    assign       sort-column-name = "x_parts.part-code"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Бар-код!партии'  then DO:    assign       sort-column-name = "Buf_bar-code.b-code"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Наименование!товара'  then DO:    assign       sort-column-name = "Buf_goods.gds-name"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Дата ПН! '  then DO:    assign       sort-column-name = "x_parts.fact-date"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Остатки!количество'  then DO:    assign       sort-column-name = "x_parts.fact-qnty"     .     run OpenBr (yes, no, '':U).   . END.
        when '№ ПН! '  then DO:    assign       sort-column-name = "x_parts.in-code"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Последний срок!реализации'  then DO:    assign       sort-column-name = "x_parts.last-date"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Цена!Производителя'  then DO:    assign       sort-column-name = "x_parts.dop"     .     run OpenBr (yes, no, '':U).   . END.
        when 'ФиБ! '  then DO:    assign       sort-column-name = "x_parts.defect"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Цена!(вал.пост)'  then DO:    assign       sort-column-name = "x_parts.price-cli"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Цена уч!руб'  then DO:    assign       sort-column-name = "x_parts.price-rubl"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Объект!тип'  then DO:    assign       sort-column-name = "x_parts.obj-type"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Объект!код'  then DO:    assign       sort-column-name = "x_parts.obj-code"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Тип!НДС'  then DO:    assign       sort-column-name = "x_parts.vat-type"     .     run OpenBr (yes, no, '':U).   . END.
        when '%!НДС'  then DO:    assign       sort-column-name = "x_parts.vat-pc"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Объект!Название'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1f-obj-name&1, recid(x_parts))', chr(34))     .     run OpenBr (yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run OpenBr (yes, no, '':U).
      if sort-labelBROWSE-2 <> "" then do:
        assign
          cur-clmnBROWSE-2:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locBROWSE-2 = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition BROWSE-2 to recid p-recid no-error.
    apply "value-changed" to BROWSE-2 in frame Dialog-Frame.
  end.
  apply "entry" to BROWSE-2 in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnBROWSE-2:
if cur-clmnBROWSE-2 = ? then do:
   run OpenBr (yes, no, '':U).
end.
else do:
   assign re-queryBROWSE-2 = yes.
   run sort-brBROWSE-2
     (input (if available x_parts
             then recid(x_parts)
             else ?
            )
     ).
   assign re-queryBROWSE-2 = no.
end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run ini-proc.
  run my_enable.
  run OpenBR in this-procedure (yes, no, '':U).
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE cb_choice-obj :
define output parameter p-obj-type as character no-undo .
define output parameter p-obj-code as integer   no-undo .
define output parameter p-obj-name as character no-undo .
define buffer Post-clients for ub.clients  .
define variable rid-list as character no-undo .
define variable v-hostcode as integer   no-undo .
  run ref/cli-all.w ( input parParentProc, input "b-sel", 'объект':U , ?, ?, ?, ?, ?, output  rid-list ) no-error .
  if num-entries (rid-list) < 1 then return error return-value .
  find first post-clients no-lock  where recid (post-clients) = integer(rid-list)  no-error.
  if available post-clients then do:
      assign
          p-obj-code = Post-clients.obj-code
          p-obj-type = Post-clients.obj-type
          p-obj-name = post-clients.obj-name
      .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-hostcode
  )  .
        if v-hostcode <> v-cntxt-host-code-obj then do:
            assign
                p-obj-code = ?
                p-obj-type = ?
                p-obj-name = ?
            .
          return error "Не верно выбран объект для перемещения, он должен быть той же фирмы " .
        end.
    end.
    else do:
          assign
              p-obj-code = ?
              p-obj-type = ?
              p-obj-name = ?
        .
        return error  "Не верно выбран объект" .
    end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY R-sort v-sort-pole R-obj FILL-IN-1 FILL-IN-2 mark-num
      WITH FRAME Dialog-Frame.
  ENABLE BROWSE-2 b-Cancel b-add-2 b-add b-del-2 b-del b-impotr-www b-make-trn
         b-report b-make-add b-clear b-sch b-print b-help R-sort v-sort-pole
         R-obj b-mark b-mark-all FILL-IN-1 b-del-mark FILL-IN-2 mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH x_parts NO-LOCK,              EACH Buf_goods OF x_parts NO-LOCK,              EACH Buf_bar-code WHERE            Buf_bar-code.gds-code  = Buf_goods.gds-code and            Buf_bar-code.in-code   = x_parts.in-code and            Buf_bar-code.part-code = x_parts.part-code            NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE gds-rec-proc :
  gds-rec = recid (buf_goods) no-error .
END PROCEDURE.
PROCEDURE ini-proc :
define variable v-today as date      no-undo .
define variable v-time as integer   no-undo .
define variable v-value-character  as character no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
define variable v-value-logical    as logical   no-undo .
define variable v-value-type       as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-pharm as character no-undo .
define variable var-type as character no-undo .
rid-list = "".
  r-obj = p-obj.
  display r-obj with frame Dialog-Frame .
empty temp-table temp-obj.
if r-obj = 1 then do:
for each ub.clients no-lock where ub.clients.host-code <> 0 and ub.clients.host-code <> ? :
  RUN clntattr-value IN THIS-PROCEDURE
    (INPUT ub.clients.obj-type,
     INPUT ub.clients.obj-code,
     input 'pharm':U,
     OUTPUT v-pharm,
     OUTPUT var-type).
  IF v-pharm = "yes":u THEN DO:
    create temp-obj.
    assign
      temp-obj.obj-code = ub.clients.obj-code
      temp-obj.obj-type = ub.clients.obj-type
    .
  end.
end.
end.
else do:
    create temp-obj.
    assign
      temp-obj.obj-code = p-obj-code
      temp-obj.obj-type = p-obj-type
    .
end.
x_parts.artic:read-only in browse BROWSE-2 = true .
x_parts.artic:resizable in browse BROWSE-2   = true .
x_parts.part-code:resizable in browse BROWSE-2   = true .
buf_goods.gds-name:resizable in browse BROWSE-2   = true .
buf_goods.gds-name:width in browse BROWSE-2       = 20 .
vf-obj-name:resizable in browse BROWSE-2   = true .
vf-obj-name:width in browse BROWSE-2       = 14 .
vf-cli-name:resizable in browse BROWSE-2   = true .
vf-cli-name:width in browse BROWSE-2       = 25 .
  empty temp-table thbjattr_thbj-attr .
 v-srok = 0.
 case p-mode :
 when "defect" then do:
    if R-obj = 1  then do:
       frame Dialog-Frame:TITLE = substitute("ВСЕ Фальсифицированные и бракованные партии ") .
    end.
    else do:
       frame Dialog-Frame:TITLE = substitute("Фальсифицированные и бракованные партии на объекте &1&2",p-obj-type,p-obj-code) .
    end.
    run make-defect in this-procedure .
  end.
 when "add-new-fib" then do:
     if R-obj = 1  then do:
        frame Dialog-Frame:TITLE = substitute("Создание  списка парий  по всем объектам") .
     end.
     else do:
        frame Dialog-Frame:TITLE = substitute("Создание  списка парий   на объекте  &1&2",p-obj-type,p-obj-code) .
     end.
     run make-new in this-procedure .
  end.
  when "srok" then do:
    run adm/shattri.p (
       input "get":U
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input 'Ass-obj':U
      ,input 'crit-srokgod':U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-srok
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        run godendo-offset-to-date in this-procedure (
              input  v-today
            , input  v-srok
            , output v-srok-date
        ).
        if R-obj = 1  then do:
           frame Dialog-Frame:TITLE = substitute ("Товары с истекающим сроком годности до &1 ", string (v-srok-date,"99/99/9999" )).
        end.
        else do:
           frame Dialog-Frame:TITLE = substitute ("Товары с истекающим сроком годности до &3 на объекте &1&2", p-obj-type, p-obj-code, string (v-srok-date,"99/99/9999" )).
        end.
        run make-srok in this-procedure .
     end.
  end case.
END PROCEDURE.
PROCEDURE make-defect :
empty temp-table x_parts.
define buffer buf_parts for ub.parts  .
for each temp-obj,
   each buf_parts no-lock where
           buf_parts.obj-type = temp-obj.obj-type and
           buf_parts.obj-code = temp-obj.obj-code and
           buf_parts.defect = logical('yes':U) and
           buf_parts.out-code = 'free-zone':U :
      create x_parts.
      buffer-copy buf_parts to x_parts.
  end.
END PROCEDURE.
PROCEDURE make-new :
empty temp-table x_parts.
define buffer buf_parts for ub.parts  .
END PROCEDURE.
PROCEDURE make-srok :
empty temp-table x_parts.
define buffer buf_parts for ub.parts  .
 for each temp-obj,
     each buf_parts no-lock where
           buf_parts.obj-type = temp-obj.obj-type and
           buf_parts.obj-code = temp-obj.obj-code and
           buf_parts.last-date <= v-srok-date and
           buf_parts.out-code = 'free-zone':U :
      create x_parts.
      buffer-copy buf_parts to x_parts.
  end.
END PROCEDURE.
PROCEDURE my_enable :
  display FILL-IN-1 FILL-IN-2 WITH FRAME Dialog-Frame.
  ENABLE b-Cancel b-mark b-add b-add-2 b-del b-del-2 b-impotr-www b-make-trn  b-sch
         b-print b-help BROWSE-2 b-mark-all b-del-mark
         r-sort v-sort-pole b-report
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
 case p-mode :
 when "defect" then do:
  hide b-clear b-make-add in frame Dialog-Frame .
  end.
 when "add-new-fib" then do:
     hide b-del b-del-2 b-add b-add-2 b-make-trn b-impotr-www b-mark b-mark-all  b-del-mark b-sch b-print b-report  in frame Dialog-Frame .
     enable b-clear b-make-add with frame Dialog-Frame .
  end.
  when "srok" then do:
    hide b-del b-del-2 b-add b-add-2 b-make-trn b-impotr-www b-mark b-del-mark b-mark-all b-clear b-make-add   in frame Dialog-Frame .
  end.
  end case.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable v-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
define variable l-open-query as logical   no-undo .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-30  as logical   no-undo .
define variable  l-filter-open-30    as logical   .
define variable  flt-rec-30       as recid     no-undo .
define variable  filter-name-30      as character no-undo .
define variable  where-phrase-30     as character no-undo .
define variable  sort-phrase-30      as character no-undo .
define variable  where-phrase-rus-30 as character no-undo .
define variable  sort-phrase-rus-30  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-30
  ,output filter-name-30
  ,output where-phrase-30
  ,output sort-phrase-30
  ,output where-phrase-rus-30
  ,output sort-phrase-rus-30
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-30
      ) no-error .
  assign
    l-filter-open-30 = false
  .
  if flt-rec-30 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-30 as character no-undo .
    define variable  parameter-3-30 as character no-undo .
    define variable  parameter-4-30 as character no-undo .
    define variable  parameter-5-30 as character no-undo .
    define variable  parameter-6-30 as character no-undo .
    define variable  parameter-7-30 as character no-undo .
      assign
      parameter-3-30 =
                              "FOR EACH x_parts"
      parameter-4-30 =
        (
          if (" true = true  " + " " + where-phrase-30) <> ""
          then " true = true  " + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + substitute(', EACH Buf_goods OF x_parts NO-LOCK,   EACH Buf_bar-code WHERE   BUF_bar-code.gds-code  = BUF_goods.gds-code and    BUF_bar-code.in-code   = x_parts.in-code and    BUF_bar-code.part-code = x_parts.part-code     ' , chr(34)  ))
      parameter-6-30 = if sort-phrase-30 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-30
        )
      parameter-7-30 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-30 =
          (" true = true  " + " " + where-phrase-30 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-2:handle
                          ,input parameter-3-30
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ,input parameter-6-30
                          ,input parameter-7-30
                          )
      .
      assign
        l-filter-open-30 = true
      .
    end.
    if l-filter-open-30 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-30 = false then do:
    OPEN QUERY BROWSE-2 FOR EACH x_parts no-lock
      where  true = true
    , EACH Buf_goods OF x_parts NO-LOCK,   EACH Buf_bar-code WHERE   Buf_bar-code.gds-code  = Buf_goods.gds-code and    Buf_bar-code.in-code   = x_parts.in-code and    Buf_bar-code.part-code = x_parts.part-code
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( x_parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-2:handle:get-buffer-handle(1) = (buffer x_parts:handle) then do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-4-30 =
        "where ":u + " true = true  " + " ":u + where-phrase-30 + " ":u + p-find-condition + " " + ""
      parameter-5-30 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-2:handle
                          ,input rowid(x_parts)
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input (buffer x_parts:handle)
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-30 = (if p-find-next then "true":u else "false":u )
      parameter-3-30 =  "FOR EACH x_parts"
      parameter-4-30 =
        (
          if (" true = true  " + " " + where-phrase-30) <> ""
          then " true = true  " + " " + where-phrase-30
          else "true"
        )
      parameter-5-30 = (" " + "" + " " + substitute(', EACH Buf_goods OF x_parts NO-LOCK,   EACH Buf_bar-code WHERE   BUF_bar-code.gds-code  = BUF_goods.gds-code and    BUF_bar-code.in-code   = x_parts.in-code and    BUF_bar-code.part-code = x_parts.part-code     ' , chr(34)  ) + " " + p-find-condition)
      parameter-6-30 = if sort-phrase-30 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-30
        )
      parameter-7-30 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-2:handle
                          ,input logical(parameter-2-30)
                          ,input no-lock
                          ,input parameter-3-30
                          ,input parameter-4-30
                          ,input parameter-5-30
                          ,input parameter-6-30
                          ,input parameter-7-30
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
if not p-open-query then do:
 reposition BROWSE-2  to recid doc-rec no-error.
 end.
if not p-open-query and v-fltopend-rowid[1] <> ? then do:
   query BROWSE-2:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
end.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'parts'
  join-tbl = 'x_parts'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
  run fltfield-add in this-procedure('in-code', 'Номер ПН', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('part-code', 'Номер/Серия партии', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
    run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-type*supp-code', 'Поставщик', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('prod-type*prod-code', 'Производитель', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('qnty', 'Кол.док.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-qnty', 'Факт.кол.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', 'Дата', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pay-code', 'Код Оплаты', 'pay',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('whole-send-news', 'ФиБ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-base', 'Цена (вал)', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-rubl', 'Цена (руб)', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-cli', 'Цена пост. (вал)', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('exch-code', 'Валюта пост.', 'curr',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('dop', 'Цена производителя', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cst-code', 'ГТД', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('last-date', 'Срок годности', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('vat-type', 'Тип НДС', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('vat-pc', '% НДС', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('contract-code', 'Договор', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pl-code', 'Место хранения', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run OpenBr in this-procedure (yes, no, '':U).
END.
END PROCEDURE.
PROCEDURE proc-find-artic :
define input parameter par-next as logical no-undo.
define input parameter p-var    as char no-undo.
  doc-rec = ? .
  if par-next = true
  then find next   x_parts no-lock where  x_parts.artic = p-var no-error  .
  else find first  x_parts no-lock where  x_parts.artic = p-var no-error  .
  if available x_parts then doc-rec = recid(x_parts) .
  reposition BROWSE-2 to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to BROWSE-2 in frame Dialog-Frame.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.
END PROCEDURE.
PROCEDURE proc-find-b-code :
define input parameter par-next as logical no-undo.
define input parameter p-var    as char no-undo.
define variable v-var1 as integer   no-undo .
v-var1 = int (p-var) no-error .
run OpenBr in this-procedure ( false  , par-next,  substitute(" and buf_bar-code.b-code = &1 " , v-var1 )) .
apply "VALUE-CHANGED" to BROWSE-2 in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-find-name :
define input parameter par-next as logical no-undo.
define input parameter p-var    as character no-undo.
  doc-rec = ? .
  if par-next = true
  then find next
      x_parts no-lock where can-find
      ( first buf_goods no-lock  where
            buf_goods.artic     = x_parts.artic and
            buf_goods.prod-type = x_parts.prod-type and
            buf_goods.prod-code = x_parts.prod-code and
            buf_goods.gds-name begins p-var )
            no-error  .
  else find first
      x_parts no-lock where can-find (
      first buf_goods no-lock  where
            buf_goods.artic     = x_parts.artic and
            buf_goods.prod-type = x_parts.prod-type and
            buf_goods.prod-code = x_parts.prod-code and
            buf_goods.gds-name begins p-var )
            no-error  .
  if available x_parts then doc-rec = recid(x_parts) .
  reposition BROWSE-2 to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to BROWSE-2 in frame Dialog-Frame.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.
END PROCEDURE.
PROCEDURE proc-find-part-code :
define input parameter par-next as logical no-undo.
define input parameter p-var    as char no-undo.
  doc-rec = ? .
  if par-next = true
  then find next   x_parts no-lock where  x_parts.part-code = p-var no-error  .
  else find first  x_parts no-lock where  x_parts.part-code = p-var no-error  .
  if available x_parts then doc-rec = recid(x_parts) .
  reposition BROWSE-2 to recid doc-rec no-error .
  if not error-status :error then apply "VALUE-CHANGED" to BROWSE-2 in frame Dialog-Frame.
  else do:
       message " Запись не найдена " view-as alert-box information .
  end.
END PROCEDURE.
PROCEDURE save-proc :
DEFINE PARAMETER BUFFER bf_parts for x_parts.
define buffer buf_parts for ub.parts  .
if p-mode = "defect" or true  then do:
find first  buf_parts exclusive-lock where
            buf_parts.obj-code   = bf_parts.obj-code and
            buf_parts.obj-type   = bf_parts.obj-type  and
            buf_parts.artic      = bf_parts.artic  and
            buf_parts.prod-type  = bf_parts.prod-type  and
            buf_parts.prod-code  = bf_parts.prod-code  and
            buf_parts.out-code   = bf_parts.out-code  and
            buf_parts.in-code    = bf_parts.in-code  and
            buf_parts.part-code  = bf_parts.part-code  no-error .
  if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      return error return-value .
  end.
  if buf_parts.defect <> bf_parts.defect then do:
     buf_parts.defect = bf_parts.defect .
  end.
end.
END PROCEDURE.
PROCEDURE make-xx-part :
empty temp-table xx_parts.
  if num-entries ( rid-list ) = 0  then do:
     for each x_parts :
        create xx_parts.
        buffer-copy x_parts to  xx_parts.
     end.
  end.
  else do:
     for each x_parts :
       if lookup ( string(recid(x_parts)) , rid-list ) > 0 then do:
          create xx_parts .
          buffer-copy x_parts to  xx_parts .
       end.
     end.
  end.
END PROCEDURE.
