DEFINE TEMP-TABLE tt-wth-parts NO-UNDO LIKE ub.wth-parts.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter pobj-type  like ub.clients.obj-type no-undo .
define input parameter pobj-code  like ub.clients.obj-code no-undo .
define input parameter par-mode as CHARACTER no-undo.
define input parameter pw-p-code as integer no-undo.
define input parameter pwth-code   as integer no-undo.
define input parameter ppar-code as integer no-undo.
define input parameter pin-code as CHARACTER no-undo.
define input parameter pout-code as CHARACTER no-undo.
define input parameter pser-code as integer no-undo.
define input parameter pdb-num as integer no-undo.
define input parameter pfact-rangefrom as integer no-undo.
define input parameter pfact-rangeto as INTEGER no-undo.
define input parameter ptype as CHARACTER no-undo.
define input-output PARAMETER p-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог добавлени\изменения партии серийных МЦ".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
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
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEF BUFFER LOCKED_wealth FOR ub.wealth.
DEF BUFFER b-wealth FOR ub.wealth.
DEF BUFFER b-goods FOR ub.goods.
DEF BUFFER LOCKED_wth-ser FOR ub.wth-ser.
DEF BUFFER buf_wth-ser FOR ub.wth-ser.
DEF BUFFER locked_wth-par FOR ub.wth-par.
DEF BUFFER locked_wth-parts FOR ub.wth-parts.
DEF BUFFER b-wth-par FOR ub.wth-par.
DEF BUFFER buf_wth-gds FOR ub.wth-gds.
DEF BUFFER buf_wth-doc FOR ub.wth-doc.
DEFINE BUTTON b-choose-last-date
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-last-date"
     SIZE 3 BY .88 TOOLTIP "Годен до".
DEFINE BUTTON b-choose-last-date-po
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-choose-last-date"
     SIZE 3 BY .88 TOOLTIP "Годен до".
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-wth-ser
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L
     SIZE 3.13 BY 1.04
     BGCOLOR 8 FGCOLOR 0 .
DEFINE VARIABLE FILL-IN-2 AS CHARACTER FORMAT "X(256)":U INITIAL "        Диапазон (факт)"
      VIEW-AS TEXT
     SIZE 31 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-3 AS CHARACTER FORMAT "X(256)":U INITIAL "     Диапазон (документ)"
      VIEW-AS TEXT
     SIZE 31.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U INITIAL "       Срок годности"
      VIEW-AS TEXT
     SIZE 30.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-5 AS CHARACTER FORMAT "X(256)":U INITIAL "           Цена"
      VIEW-AS TEXT
     SIZE 31.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "              Серия"
      VIEW-AS TEXT
     SIZE 30.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE fl-artic AS CHARACTER FORMAT "X(16)":U INITIAL "0"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-gds AS CHARACTER FORMAT "X(256)":U
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-maska AS CHARACTER FORMAT "X(256)":U
     LABEL "Маска"
     VIEW-AS FILL-IN
     SIZE 19.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-obj-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название"
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-par-rate AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Коэффициент"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-par-val AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Номинал"
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-ProdCode AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-prodType AS CHARACTER FORMAT "X(256)":U
     LABEL "Производитель"
     VIEW-AS FILL-IN
     SIZE 8.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fl-wth-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Название МЦ"
     VIEW-AS FILL-IN
     SIZE 42 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY 5.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.5 BY 5.25.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 65 BY 5.25.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.5 BY 4.75.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 33.5 BY 4.75.
DEFINE QUERY Dialog-Frame FOR
      tt-wth-parts SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13 WIDGET-ID 2
     b-quit AT ROW 1 COL 11.13 WIDGET-ID 8
     B-Help AT ROW 1 COL 81 WIDGET-ID 4
     tt-wth-parts.VAT-pc AT ROW 16 COL 48.5 COLON-ALIGNED WIDGET-ID 1118
          LABEL "НДС" FORMAT ">9.9<%"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     fl-artic AT ROW 2.5 COL 18 COLON-ALIGNED WIDGET-ID 46
     fl-gds AT ROW 2.5 COL 52.5 COLON-ALIGNED WIDGET-ID 58
     fl-prodType AT ROW 3.5 COL 18 COLON-ALIGNED WIDGET-ID 54
     fl-maska AT ROW 11 COL 11.5 COLON-ALIGNED WIDGET-ID 252
     fl-ProdCode AT ROW 3.5 COL 27 COLON-ALIGNED NO-LABEL WIDGET-ID 56
     fl-obj-name AT ROW 3.5 COL 52.5 COLON-ALIGNED WIDGET-ID 290
     tt-wth-parts.wth-code AT ROW 4.5 COL 18 COLON-ALIGNED WIDGET-ID 246
          LABEL "Код МЦ"
          VIEW-AS FILL-IN
          SIZE 10.5 BY 1
     fl-wth-name AT ROW 4.5 COL 52.5 COLON-ALIGNED WIDGET-ID 50
     tt-wth-parts.par-code AT ROW 5.5 COL 18 COLON-ALIGNED WIDGET-ID 218
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     fl-par-val AT ROW 5.5 COL 52.5 COLON-ALIGNED WIDGET-ID 52
     fl-par-rate AT ROW 5.5 COL 74 COLON-ALIGNED WIDGET-ID 250
     FILL-IN-2 AT ROW 7.75 COL 65.5 COLON-ALIGNED NO-LABEL WIDGET-ID 260
     tt-wth-parts.ser-code AT ROW 9 COL 11.5 COLON-ALIGNED WIDGET-ID 230
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     B-wth-ser AT ROW 9 COL 20.5 WIDGET-ID 32
     FILL-IN-3 AT ROW 7.75 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 270
     tt-wth-parts.db-num AT ROW 10 COL 11.5 COLON-ALIGNED WIDGET-ID 176
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-wth-parts.fact-rangeFrom AT ROW 9 COL 76.5 COLON-ALIGNED WIDGET-ID 194
          LABEL "С"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-wth-parts.fact-rangeTo AT ROW 10 COL 76.5 COLON-ALIGNED WIDGET-ID 196
          LABEL "По"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-wth-parts.doc-rangeFrom AT ROW 9 COL 43 COLON-ALIGNED WIDGET-ID 262
          LABEL "C"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-wth-parts.doc-rangeTo AT ROW 10 COL 43 COLON-ALIGNED WIDGET-ID 264
          LABEL "По"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     tt-wth-parts.fact-qnty AT ROW 11 COL 76.5 COLON-ALIGNED WIDGET-ID 266
          LABEL "Кол-во"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-wth-parts.qnty-doc AT ROW 11 COL 43 COLON-ALIGNED WIDGET-ID 224
          LABEL "Кол-во"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-wth-parts.beg-dt AT ROW 14 COL 11.5 COLON-ALIGNED WIDGET-ID 168
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     b-choose-last-date AT ROW 14 COL 26 WIDGET-ID 274
     tt-wth-parts.end-dt AT ROW 15 COL 11.5 COLON-ALIGNED WIDGET-ID 182
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     b-choose-last-date-po AT ROW 15 COL 26 WIDGET-ID 276
     tt-wth-parts.price-rubl AT ROW 14 COL 48.5 COLON-ALIGNED WIDGET-ID 222
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     FILL-IN-4 AT ROW 12.75 COL 2.5 NO-LABEL WIDGET-ID 278
     tt-wth-parts.price-base AT ROW 15 COL 48.5 COLON-ALIGNED WIDGET-ID 1116
          VIEW-AS FILL-IN
          SIZE 15 BY 1
     FILL-IN-5 AT ROW 12.75 COL 33 COLON-ALIGNED NO-LABEL WIDGET-ID 286
     FILL-IN-6 AT ROW 7.75 COL 2.5 NO-LABEL WIDGET-ID 1114
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE  WIDGET-ID 100.
DEFINE FRAME Dialog-Frame
     RECT-1 AT ROW 2.25 COL 1.5 WIDGET-ID 254
     RECT-2 AT ROW 7.25 COL 1.5 WIDGET-ID 256
     RECT-3 AT ROW 7.25 COL 34 WIDGET-ID 272
     RECT-4 AT ROW 12.5 COL 1.5 WIDGET-ID 280
     RECT-5 AT ROW 12.5 COL 34 WIDGET-ID 288
     SPACE(31.87) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партии Серийной материальной ценности" WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-wth-ser:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
    run proc-save in this-procedure no-error .
    if error-status:error then return no-apply.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
END.
ON CHOOSE OF B-wth-ser IN FRAME Dialog-Frame
DO:
      v-rid-list = ''.
      run ref/wths-ref.w (
                         input parparentproc
                        ,input "b-sel"
                        ,input p-curr-host-code
                        ,input pobj-type
                        ,input pobj-code
                        ,input 'Номинал МЦ':U
                        ,INPUT pwth-code
                        ,input ppar-code
                        ,input-output v-rid-list) .
      if v-rid-list = "" then return .
      find first locked_wth-ser NO-LOCK WHERE
              recid(locked_wth-ser) = integer(entry(1, v-rid-list)) NO-ERROR.
      if available locked_wth-ser then do:
          ASSIGN tt-wth-parts.ser-code:SCREEN-VALUE = STRING(LOCKED_wth-ser.ser-code)
                 tt-wth-parts.db-num:SCREEN-VALUE = string(LOCKED_wth-ser.db-num)
                 fl-maska:SCREEN-VALUE = LOCKED_wth-ser.maska
                 .
         APPLY 'tab':U TO SELF.
     END.
END.
ON RETURN OF tt-wth-parts.beg-dt IN FRAME Dialog-Frame
DO:
  IF SELF:SCREEN-VALUE = '':U THEN APPLY 'tab':U TO SELF.
  ELSE APPLY "entry":U TO tt-wth-parts.end-dt.
  RETURN NO-APPLY.
END.
ON LEAVE OF tt-wth-parts.doc-rangeFrom IN FRAME Dialog-Frame
DO:
    tt-wth-parts.qnty-doc:SCREEN-VALUE = string(int(tt-wth-parts.doc-rangeto:SCREEN-VALUE) -
       int(tt-wth-parts.doc-rangeFrom:SCREEN-VALUE) + 1).
    tt-wth-parts.fact-rangefrom:SCREEN-VALUE  = tt-wth-parts.doc-rangeFrom:SCREEN-VALUE.
    tt-wth-parts.fact-rangeto:SCREEN-VALUE  = tt-wth-parts.doc-rangeto:SCREEN-VALUE.
    tt-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.
ON RETURN OF tt-wth-parts.doc-rangeFrom IN FRAME Dialog-Frame
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.
END.
ON LEAVE OF tt-wth-parts.doc-rangeTo IN FRAME Dialog-Frame
DO:
    tt-wth-parts.qnty-doc:SCREEN-VALUE = string(int(tt-wth-parts.doc-rangeto:SCREEN-VALUE) -
       int(tt-wth-parts.doc-rangeFrom:SCREEN-VALUE) + 1).
    tt-wth-parts.fact-rangefrom:SCREEN-VALUE  = tt-wth-parts.doc-rangeFrom:SCREEN-VALUE.
    tt-wth-parts.fact-rangeto:SCREEN-VALUE  = tt-wth-parts.doc-rangeto:SCREEN-VALUE.
    tt-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.
ON RETURN OF tt-wth-parts.doc-rangeTo IN FRAME Dialog-Frame
DO:
  APPLY "tab":U TO SELF.
  RETURN NO-APPLY.
END.
ON RETURN OF tt-wth-parts.end-dt IN FRAME Dialog-Frame
DO:
  IF SELF:SCREEN-VALUE = '':U THEN APPLY 'tab':U TO SELF.
  ELSE APPLY "entry":U TO tt-wth-parts.price-rubl.
  RETURN NO-APPLY.
END.
ON LEAVE OF tt-wth-parts.fact-rangeFrom IN FRAME Dialog-Frame
DO:
   tt-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-wth-parts.fact-rangeto:SCREEN-VALUE) -
   int(tt-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.
ON RETURN OF tt-wth-parts.fact-rangeFrom IN FRAME Dialog-Frame
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.
END.
ON LEAVE OF tt-wth-parts.fact-rangeTo IN FRAME Dialog-Frame
DO:
    tt-wth-parts.fact-qnty:SCREEN-VALUE = string(int(tt-wth-parts.fact-rangeto:SCREEN-VALUE) -
       int(tt-wth-parts.fact-rangeFrom:SCREEN-VALUE) + 1).
END.
ON RETURN OF tt-wth-parts.fact-rangeTo IN FRAME Dialog-Frame
DO:
    APPLY "tab":U TO SELF.
    RETURN NO-APPLY.
END.
ON LEAVE OF tt-wth-parts.price-rubl IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-base-rate AS DEC.
DEFINE VARIABLE v-base-scale AS DEC.
ASSIGN FRAME Dialog-Frame tt-wth-parts.price-rubl.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  p-curr-host-code
  ,input  buf_wth-doc.DOC-DATE
  ,output v-base-rate
  ,output v-base-scale
  ) no-error .
  tt-wth-parts.price-base = dec(tt-wth-parts.price-rubl) / v-base-rate.
  DISPLAY tt-wth-parts.price-base WITH FRAME dialog-frame.
END.
ON RETURN OF tt-wth-parts.price-rubl IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-base-rate AS DEC.
DEFINE VARIABLE v-base-scale AS DEC.
ASSIGN FRAME Dialog-Frame tt-wth-parts.price-rubl.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  p-curr-host-code
  ,input  buf_wth-doc.DOC-DATE
  ,output v-base-rate
  ,output v-base-scale
  ) no-error .
  tt-wth-parts.price-base = dec(tt-wth-parts.price-rubl) / v-base-rate.
  DISPLAY tt-wth-parts.price-base WITH FRAME dialog-frame.
   APPLY 'tab':U TO SELF.
  RETURN NO-APPLY.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-wth-parts.beg-dt in frame Dialog-Frame
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
on delete-character of tt-wth-parts.beg-dt in frame Dialog-Frame
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
on ctrl-d of tt-wth-parts.beg-dt in frame Dialog-Frame
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
on ctrl-b of tt-wth-parts.beg-dt in frame Dialog-Frame
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
on ctrl-e of tt-wth-parts.beg-dt in frame Dialog-Frame
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
on ctrl-f of tt-wth-parts.beg-dt in frame Dialog-Frame
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
      v-description = 'Годен до &1 (для партии товара, включительно)'
    .
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
  define MENU m-ed-date24
    MENU-ITEM m-ed-date24-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date24-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date24-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date24-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if tt-wth-parts.beg-dt :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-wth-parts.beg-dt :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date24 :HANDLE
      tt-wth-parts.beg-dt :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle24 as handle no-undo .
  assign
    v-label-handle24 = tt-wth-parts.beg-dt :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle24)
  then do:
    if v-label-handle24 :tooltip = ""
    or v-label-handle24 :tooltip = ?
    then do:
      assign
        v-label-handle24 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date24-1 in menu m-ed-date24 DO:
    apply "ctrl-b":U to tt-wth-parts.beg-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-2 in menu m-ed-date24 DO:
    apply "ctrl-d":U to tt-wth-parts.beg-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-3 in menu m-ed-date24 DO:
    apply "ctrl-e":U to tt-wth-parts.beg-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date24-4 in menu m-ed-date24 DO:
    apply "ctrl-f":U to tt-wth-parts.beg-dt in frame Dialog-Frame .
  END.
on choose of b-choose-last-date in frame Dialog-Frame
do:
  run sel-date in this-procedure
    (input tt-wth-parts.beg-dt :handle
    ,input "Годен до &1 (для партии товара)"
    ) .
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of tt-wth-parts.end-dt in frame Dialog-Frame
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
on delete-character of tt-wth-parts.end-dt in frame Dialog-Frame
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
on ctrl-d of tt-wth-parts.end-dt in frame Dialog-Frame
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
on ctrl-b of tt-wth-parts.end-dt in frame Dialog-Frame
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
on ctrl-e of tt-wth-parts.end-dt in frame Dialog-Frame
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
on ctrl-f of tt-wth-parts.end-dt in frame Dialog-Frame
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
      v-description = 'Годен до &1 (для партии товара, включительно)'
    .
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
  define MENU m-ed-date26
    MENU-ITEM m-ed-date26-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date26-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date26-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date26-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if tt-wth-parts.end-dt :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      tt-wth-parts.end-dt :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date26 :HANDLE
      tt-wth-parts.end-dt :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle26 as handle no-undo .
  assign
    v-label-handle26 = tt-wth-parts.end-dt :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle26)
  then do:
    if v-label-handle26 :tooltip = ""
    or v-label-handle26 :tooltip = ?
    then do:
      assign
        v-label-handle26 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date26-1 in menu m-ed-date26 DO:
    apply "ctrl-b":U to tt-wth-parts.end-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-2 in menu m-ed-date26 DO:
    apply "ctrl-d":U to tt-wth-parts.end-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-3 in menu m-ed-date26 DO:
    apply "ctrl-e":U to tt-wth-parts.end-dt in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date26-4 in menu m-ed-date26 DO:
    apply "ctrl-f":U to tt-wth-parts.end-dt in frame Dialog-Frame .
  END.
on choose of b-choose-last-date-po in frame Dialog-Frame
do:
  run sel-date in this-procedure
    (input tt-wth-parts.end-dt :handle
    ,input "Годен до &1 (для партии товара)"
    ) .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF lookup(par-mode, 'ДОБАВЛЕНИЕ':U + chr(44) +
                      'ИЗМЕНЕНИЕ':U + chr(44) +
                      'ПРОСМОТР':U) = 0 THEN DO:
    MESSAGE
    "Неверное значение параметра par-mode" par-mode
    VIEW-AS ALERT-BOX ERROR.
    UNDO main-block, RETURN ERROR.
  END.
  if lookup(pout-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0 and (par-mode = 'ДОБАВЛЕНИЕ':U or par-mode = 'ИЗМЕНЕНИЕ':U ) then do:
    find first buf_wth-doc exclusive-lock where
            buf_wth-doc.doc-code = pout-code no-error .
    if NOT available buf_wth-doc then do:
      message substitute('Не найден документ МЦ с номером &1',pout-code) view-as alert-box error.
      return.
    END.
  end.
  IF par-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
       IF par-mode = 'ПРОСМОТР':U THEN DO:
       FIND FIRST LOCKED_wth-parts NO-LOCK WHERE
          recid(LOCKED_wth-parts) = p-rec
          NO-ERROR.
     END.
     ELSE DO:
         FIND FIRST LOCKED_wth-parts exclusive-LOCK WHERE
          recid(LOCKED_wth-parts) = p-rec
            NO-ERROR.
     END.
     IF NOT AVAILABLE LOCKED_wth-parts THEN DO:
        MESSAGE pin-code SKIP pout-code SKIP pfact-rangefrom SKIP pfact-rangeto SKIP
        SUBSTITUTE("Не найдена партия с кодом &1 для МЦ с  кодом &2", ppar-code, pwth-code)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
     END.
  end.
  FIND FIRST LOCKED_wealth No-LOCK WHERE
            LOCKED_wealth.wth-code = if par-mode = 'ДОБАВЛЕНИЕ':U then pwth-code else LOCKED_wth-parts.wth-code  NO-ERROR.
  IF NOT AVAILABLE LOCKED_wealth THEN DO:
      message vss-workfile vss-revision vss-description skip
      "Не найдена материальная ценность с кодом " pwth-code
      view-as alert-box error.
      return error.
  END.
  FIND FIRST LOCKED_wth-par NO-LOCK WHERE
            LOCKED_wth-par.wth-code = (if par-mode = 'ДОБАВЛЕНИЕ':U then pwth-code  else LOCKED_wth-parts.wth-code)
       AND  LOCKED_wth-par.par-code = (if par-mode = 'ДОБАВЛЕНИЕ':U then ppar-code else LOCKED_wth-parts.par-code)
 NO-ERROR.
  IF NOT AVAILABLE LOCKED_wth-par THEN DO:
      message vss-workfile vss-revision vss-description skip
      "Не найдена материальная ценность с кодом " ppar-code
      view-as alert-box error.
      return error.
  END.
  IF par-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    if buf_wth-doc.doc-type = 'при':U and not buf_wth-doc.exter_ then do:
      message substitute('Режим добавления для документов внутреннего прихода запрещен!')
      view-as alert-box error.
      return error.
    end.
    CREATE tt-wth-parts.
      IF pwth-code <> 0  THEN do:
        tt-wth-parts.wth-code = LOCKED_wealth.wth-code.
          IF ppar-code <> 0  THEN do:
            tt-wth-parts.par-code = LOCKED_wth-par.par-code.
          END.
      END.
  END.
  ELSE DO:
    FIND FIRST LOCKED_wth-ser NO-LOCK WHERE
                LOCKED_wth-ser.ser-code = LOCKED_wth-parts.ser-code
           AND  LOCKED_wth-ser.db-num = LOCKED_wth-parts.db-num          NO-ERROR.
    IF NOT AVAILABLE LOCKED_wth-ser THEN DO:
        MESSAGE
        SUBSTITUTE("Не найдена серия с кодом &1-&2", LOCKED_wth-parts.ser-code,  LOCKED_wth-parts.db-num)
        VIEW-AS ALERT-BOX ERROR.
        UNDO main-block, RETURN ERROR.
    END.
    CREATE tt-wth-parts.
    BUFFER-COPY LOCKED_wth-parts TO tt-wth-parts.
  END.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN Myenable IN THIS-PROCEDURE NO-ERROR.
  RUN disp-fl.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE disp-fl :
define variable v-vat-pc as decimal no-undo.
define variable v-beg-dt as date    no-undo.
define variable v-end-dt as date    no-undo.
define variable v-mpl-date as date    no-undo.
define variable v-price-rubl       LIKE ub.wth-parts.price-rubl no-undo .
define variable v-price-base       LIKE ub.wth-parts.price-base no-undo .
DEF BUFFER b-cash-pay FOR ub.cash-pay.
DEF BUFFER b-clients  FOR ub.clients.
    fill-in-6:SCREEN-VALUE IN FRAME Dialog-Frame = "            Серия".
    fill-in-2:SCREEN-VALUE IN FRAME Dialog-Frame = "         Диапазон (факт)".
    fill-in-3:SCREEN-VALUE IN FRAME Dialog-Frame = "        Диапазон (док)".
    fill-in-4:SCREEN-VALUE IN FRAME Dialog-Frame = "        Срок годности".
    fill-in-5:SCREEN-VALUE IN FRAME Dialog-Frame = "           Цена".
  IF AVAILABLE locked_wth-parts THEN DO WITH FRAME Dialog-Frame:
      DISP
      locked_wealth.wth-name @ fl-wth-name
      LOCKED_wth-par.par-val @ fl-par-val
      LOCKED_wth-par.par-rate @ fl-par-rate
      LOCKED_wth-ser.maska @ fl-maska.
      FIND FIRST b-goods WHERE b-goods.gds-code = locked_wth-parts.gds-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-goods THEN do:
                                DISP b-goods.artic     @ fl-artic
                                     b-goods.prod-type @ fl-prodType
                                     b-goods.prod-code @ fl-prodCode
                                     b-goods.gds-name  @ fl-gds.
        FIND FIRST b-clients WHERE b-clients.obj-type = b-goods.prod-type AND
             b-clients.obj-code = b-goods.prod-code NO-LOCK NO-ERROR.
        IF AVAILABLE b-clients THEN DISP b-clients.obj-name @ fl-obj-name.
      END.
      ELSE   ASSIGN fl-artic:SCREEN-VALUE = '?':U
             fl-prodType:SCREEN-VALUE = '?':U
             fl-prodCode:SCREEN-VALUE = '?':U
             fl-gds:SCREEN-VALUE = '?':U.
      if available buf_wth-doc
      and (buf_wth-doc.ext-doc-type = 'ee':U or  (buf_wth-doc.doc-type = 'обмен':U and ptype = 'рас':U))
      and par-mode = 'ИЗМЕНЕНИЕ':U and
      tt-wth-parts.beg-dt = ? AND tt-wth-parts.end-dt = ? THEN DO:
            RUN init_prtdate ( INPUT buf_wth-doc.obj-type
                              ,INPUT buf_wth-doc.obj-code
                              ,INPUT locked_wth-ser.ser-code
                              ,INPUT locked_wth-ser.db-num
                              ,INPUT buf_wth-doc.doc-date
                              ,OUTPUT v-beg-dt
                              ,OUTPUT v-end-dt ) NO-ERROR.
            if error-status:error then do:
             message return-value skip
              error-status:get-message(1)
             view-as alert-box error .
            end.
            else do:
              disp  v-beg-dt @ tt-wth-parts.beg-dt
                    v-end-dt @ tt-wth-parts.end-dt
              with frame Dialog-Frame.
            end.
      END.
      if available buf_wth-doc
      and (buf_wth-doc.ext-doc-type = 'ee':U or  (buf_wth-doc.doc-type = 'обмен':U and ptype = 'рас':U))
      and par-mode = 'ИЗМЕНЕНИЕ':U and
      (tt-wth-parts.price-rubl = 0 or tt-wth-parts.price-rubl = ? ) then do:
              v-beg-dt = date(tt-wth-parts.beg-dt:screen-value) no-error.
              run set-wthmpl-date ( buf_wth-doc.doc-code
                            ,buf_wth-doc.doc-date
                            , v-beg-dt
                            , output v-mpl-date) no-error.
                  RUN INIT_prtprice (
                          buf_wth-doc.host-code
                        , buf_wth-doc.obj-type
                        , buf_wth-doc.obj-code
                        , buf_wth-doc.cli-type
                        , buf_wth-doc.cli-code
                        , locked_wth-parts.wth-code
                        , locked_wth-parts.gds-code
                        , locked_wth-parts.par-code
                        , v-mpl-date
                        , OUTPUT  v-vat-pc
                        , OUTPUT  v-price-rubl
                        , OUTPUT  v-price-base
                ) NO-ERROR.
          if error-status:error then undo, return error return-value + error-status:get-message(1) .
         tt-wth-parts.vat-pc:screen-value = string(v-vat-pc).
         tt-wth-parts.price-rubl:screen-value = string(v-price-rubl).
         apply 'leave':U to tt-wth-parts.price-rubl.
       end.
  END.
  ELSE DO:
      FIND FIRST b-wealth WHERE b-wealth.wth-code = pwth-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wealth THEN fl-wth-name:SCREEN-VALUE = b-wealth.wth-name.
      ELSE fl-wth-name:SCREEN-VALUE = '?':U.
      FIND FIRST b-wth-par WHERE b-wth-par.wth-code =  pwth-code AND b-wth-par.par-code = ppar-code NO-LOCK NO-ERROR.
      IF AVAILABLE b-wth-par THEN do: fl-par-val:SCREEN-VALUE = string(b-wth-par.par-val).
                                      fl-par-rate:SCREEN-VALUE = string(b-wth-par.par-rate).
      END.
      ELSE do:
          fl-par-val:SCREEN-VALUE = '?':U.
          fl-par-rate:SCREEN-VALUE = '0':U.
      END.
      find first buf_wth-gds no-lock where
              buf_wth-gds.wth-code = pwth-code   no-error .
      if available buf_wth-gds then do:
          FIND FIRST b-goods WHERE b-goods.gds-code = buf_wth-gds.gds-code NO-LOCK NO-ERROR.
          IF AVAILABLE b-goods THEN DO:  fl-artic:SCREEN-VALUE = b-goods.artic .
                                         fl-prodType:SCREEN-VALUE = string(b-goods.prod-type).
                                         fl-prodCode:SCREEN-VALUE = string(b-goods.prod-code).
                                         fl-gds:SCREEN-VALUE = b-goods.gds-name .
             FIND FIRST b-clients WHERE b-clients.obj-type = b-goods.prod-type AND
                  b-clients.obj-code = b-goods.prod-code NO-LOCK NO-ERROR.
             IF AVAILABLE b-clients THEN fl-obj-name:SCREEN-VALUE = b-clients.obj-name.
          END.
          ELSE   ASSIGN fl-artic:SCREEN-VALUE = '?':U
                 fl-prodType:SCREEN-VALUE = '?':U
                 fl-prodCode:SCREEN-VALUE = '?':U
                 fl-gds:SCREEN-VALUE = '?':U.
      end.
      if par-mode = 'ДОБАВЛЕНИЕ':U and not available LOCKED_wth-ser then do:
        find buf_wth-ser where buf_wth-ser.wth-code = pwth-code
                           and buf_wth-ser.wth-code = ppar-code
                           and  buf_wth-ser.stts = 0 no-lock no-error.
        if available buf_wth-ser then do:
          find first locked_wth-ser no-LOCK WHERE
              recid(locked_wth-ser) = recid(buf_wth-ser) NO-ERROR.
          if available locked_wth-ser then do:
            ASSIGN tt-wth-parts.ser-code:SCREEN-VALUE = STRING(LOCKED_wth-ser.ser-code)
                 tt-wth-parts.db-num:SCREEN-VALUE = string(LOCKED_wth-ser.db-num)
                 fl-maska:SCREEN-VALUE = LOCKED_wth-ser.maska
                 .
          end.
        end.
      end.
  END.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-wth-parts SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY fl-artic fl-gds fl-prodType fl-maska fl-ProdCode fl-obj-name
          fl-wth-name fl-par-val fl-par-rate FILL-IN-2 FILL-IN-3 FILL-IN-4
          FILL-IN-5 FILL-IN-6
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-wth-parts THEN
    DISPLAY tt-wth-parts.VAT-pc tt-wth-parts.wth-code tt-wth-parts.par-code
          tt-wth-parts.ser-code tt-wth-parts.db-num tt-wth-parts.fact-rangeFrom
          tt-wth-parts.fact-rangeTo tt-wth-parts.doc-rangeFrom
          tt-wth-parts.doc-rangeTo tt-wth-parts.fact-qnty tt-wth-parts.qnty-doc
          tt-wth-parts.beg-dt tt-wth-parts.end-dt tt-wth-parts.price-rubl
          tt-wth-parts.price-base
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help fl-artic fl-gds fl-prodType fl-maska fl-ProdCode
         fl-obj-name tt-wth-parts.wth-code fl-wth-name tt-wth-parts.par-code
         fl-par-val fl-par-rate tt-wth-parts.ser-code B-wth-ser
         tt-wth-parts.db-num tt-wth-parts.fact-rangeFrom
         tt-wth-parts.fact-rangeTo tt-wth-parts.doc-rangeFrom
         tt-wth-parts.doc-rangeTo tt-wth-parts.fact-qnty tt-wth-parts.qnty-doc
         tt-wth-parts.beg-dt b-choose-last-date tt-wth-parts.end-dt
         b-choose-last-date-po tt-wth-parts.price-rubl tt-wth-parts.price-base
         RECT-1 RECT-2 RECT-3 RECT-4 RECT-5
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
ENABLE
B-exit WHEN par-mode <> 'ПРОСМОТР':U
b-quit
B-Help
WITH FRAME Dialog-Frame.
IF par-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    ENABLE
    b-wth-ser
    tt-wth-parts.doc-rangeFrom
    tt-wth-parts.doc-rangeTo
    WITH FRAME Dialog-Frame.
END.
DISPLAY
   tt-wth-parts.VAT-pc tt-wth-parts.wth-code tt-wth-parts.par-code tt-wth-parts.ser-code tt-wth-parts.db-num tt-wth-parts.fact-rangeFrom tt-wth-parts.fact-rangeTo tt-wth-parts.doc-rangeFrom tt-wth-parts.doc-rangeTo tt-wth-parts.fact-qnty tt-wth-parts.qnty-doc tt-wth-parts.beg-dt tt-wth-parts.end-dt tt-wth-parts.price-rubl tt-wth-parts.price-base
WITH FRAME Dialog-Frame  .
IF par-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
    ENABLE
        tt-wth-parts.fact-rangeFrom WHEN (buf_wth-doc.doc-type = 'при':U and not buf_wth-doc.exter_)
        tt-wth-parts.fact-rangeTo   WHEN (buf_wth-doc.doc-type = 'при':U and not buf_wth-doc.exter_)
        tt-wth-parts.doc-rangeFrom  WHEN not (buf_wth-doc.doc-type = 'при':U and not buf_wth-doc.exter_)
        tt-wth-parts.doc-rangeTo    WHEN not (buf_wth-doc.doc-type = 'при':U and not buf_wth-doc.exter_)
 WITH FRAME Dialog-Frame.
END.
if (par-mode = 'ИЗМЕНЕНИЕ':U or par-mode = 'ДОБАВЛЕНИЕ':U) and
   (buf_wth-doc.ext-doc-type = 'ee':U or
    (buf_wth-doc.ext-doc-type = 'xc':U    and ptype = 'рас':U))
    then do:
      enable
        tt-wth-parts.price-rubl
      WITH FRAME Dialog-Frame.
     if locked_wth-ser.chk-bdt <> 0 then do:
        disable
          tt-wth-parts.beg-dt
          b-choose-last-date
          WITH FRAME Dialog-Frame.
      end.
      else do:
        enable
          tt-wth-parts.beg-dt
          b-choose-last-date
          WITH FRAME Dialog-Frame.
      end.
      if locked_wth-ser.chk-edt <> 0 then do:
        disable
          tt-wth-parts.end-dt
          b-choose-last-date-po
          WITH FRAME Dialog-Frame.
      end.
      else do:
        enable
          tt-wth-parts.end-dt
          b-choose-last-date-po
          WITH FRAME Dialog-Frame.
      end.
end.
if tt-wth-parts.stts = 1 and par-mode = 'ПРОСМОТР':U then do:
  tt-wth-parts.fact-rangeFrom:screen-value = '?'.
  tt-wth-parts.fact-rangeTo:screen-value = '?'.
  tt-wth-parts.fact-qnty:screen-value = '0'.
end.
IF par-mode = 'ПРОСМОТР':U THEN DO:
  HIDE
  b-exit IN FRAME Dialog-Frame
  .
  ASSIGN
  b-quit:COLUMN = 1
  b-quit:LABEL = "&Выход".
END.
VIEW FRAME Dialog-Frame.
frame Dialog-Frame:title = substitute("&1 &2"
                                     ,frame Dialog-Frame:title
                                     ,par-mode
                                     ).
APPLY 'entry':U TO b-wth-ser.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-EndDate AS date NO-UNDO.
DEFINE VARIABLE v-BegDate AS date NO-UNDO.
IF par-mode = 'ПРОСМОТР':U THEN UNDO, RETURN.
assign
FRAME Dialog-Frame tt-wth-parts.VAT-pc tt-wth-parts.wth-code tt-wth-parts.par-code tt-wth-parts.ser-code tt-wth-parts.db-num tt-wth-parts.fact-rangeFrom tt-wth-parts.fact-rangeTo tt-wth-parts.doc-rangeFrom tt-wth-parts.doc-rangeTo tt-wth-parts.fact-qnty tt-wth-parts.qnty-doc tt-wth-parts.beg-dt tt-wth-parts.end-dt tt-wth-parts.price-rubl tt-wth-parts.price-base.
if  par-mode = 'ИЗМЕНЕНИЕ':U then v-rec = recid(locked_wth-parts).
do transaction on error undo, return error
               on stop  undo, return error
               on quit  undo, return error :
  if buf_wth-doc.ext-doc-type = 'ee':U or
    (buf_wth-doc.ext-doc-type = 'xc':U    and ptype = 'рас':U)
    and available locked_wth-ser
   then do:
    if locked_wth-ser.chk-bdt = 2 and locked_wth-ser.beg-dt <> ? then v-BegDate = locked_wth-ser.beg-dt.
    else  v-BegDate = tt-wth-parts.beg-dt.
    if locked_wth-ser.chk-edt = 2 and locked_wth-ser.end-dt <> ? then v-EndDate = locked_wth-ser.end-dt.
    else  v-EndDate = tt-wth-parts.end-dt.
    if (v-BegDate = ? and not locked_wth-ser.chk-bdt = 1)  or (v-EndDate = ? and not locked_wth-ser.chk-edt = 1)  then do:
        message 'Не указан срок действия партии' view-as alert-box error.
        apply 'entry':U to tt-wth-parts.beg-dt.
        return error.
    end.
    if not (v-BegDate = ? or v-EndDate = ?) and v-BegDate > v-EndDate  then do:
        message 'Неверно указан срок действия партии' view-as alert-box error.
        apply 'entry':U to tt-wth-parts.beg-dt.
        return error.
    end.
    if tt-wth-parts.price-rubl = 0 OR  tt-wth-parts.price-rubl = ? then do:
        message 'Не указана цена!.' view-as alert-box error.
        apply 'entry':U to tt-wth-parts.price-rubl.
        return error.
    end.
  end.
  if buf_wth-doc.doc-type = 'при':U and buf_wth-doc.exter_ = no then do:
    run wth-parts-inter-edit in this-procedure ( INPUT tt-wth-parts.fact-rangeFrom ,
                                                 INPUT tt-wth-parts.fact-rangeTo  ,
                                                 INPUT-OUTPUT v-rec
                                                )  no-error.
    if error-status:error then do:
        MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
        apply 'entry':U to tt-wth-parts.fact-rangeFrom.
        undo, return error.
    end.
  end.
  else if lookup(buf_wth-doc.ext-doc-type,'ie,ip,rp,fj,pj,ff,rf':U) > 0   then do:
          run str/wthpartp.p    ( INPUT    par-mode,
                    INPUT     buf_wth-doc.obj-type,
                    INPUT     buf_wth-doc.obj-code,
                    INPUT     pw-p-code,
                    INPUT     tt-wth-parts.wth-code,
                    INPUT     tt-wth-parts.par-code,
                    INPUT     tt-wth-parts.in-code ,
                    INPUT     buf_wth-doc.doc-code,
                    INPUT     tt-wth-parts.ser-code,
                    INPUT     tt-wth-parts.db-num  ,
                    INPUT     tt-wth-parts.fact-rangeFrom ,
                    INPUT     tt-wth-parts.fact-rangeTo  ,
                    INPUT     tt-wth-parts.doc-rangeFrom ,
                    INPUT     tt-wth-parts.doc-rangeTo,
                    INPUT     buf_wth-doc.host-code     ,
                    INPUT     buf_wth-doc.contract-code  ,
                    INPUT     tt-wth-parts.price-rubl    ,
                    INPUT     tt-wth-parts.price-base    ,
                    INPUT     tt-wth-parts.supp-type,
                    INPUT     tt-wth-parts.supp-code,
                    INPUT     tt-wth-parts.in-obj-type ,
                    INPUT     tt-wth-parts.in-obj-code ,
                    INPUT     buf_wth-doc.ext-doc-type,
                    INPUT     b-goods.gds-code,
                    INPUT     tt-wth-parts.stts  ,
                    INPUT     tt-wth-parts.beg-dt  ,
                    INPUT     tt-wth-parts.end-dt  ,
                    INPUT     tt-wth-parts.vat-pc  ,
                    INPUT     tt-wth-parts.cli-code,
                    INPUT     tt-wth-parts.cli-type,
                    INPUT     tt-wth-parts.out-obj-code,
                    INPUT     tt-wth-parts.out-obj-type,
                    INPUT     tt-wth-parts.sale-obj-code,
                    INPUT     tt-wth-parts.sale-obj-type,
                    INPUT     buf_wth-doc.doc-code,
                    INPUT     no,
                    INPUT     ptype,
                    INPUT-OUTPUT v-rec
                    ) no-error.
      if error-status:error then DO:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
        undo , return error.
      end.
  end.
  else do:
    if LOCKED_wth-parts.out-code = pout-code then do:
      run  wth-doc-razrez ( input RECID(LOCKED_wth-parts),
                            input no) no-error.
      if error-status:error then DO:
        MESSAGE RETURN-VALUE + chr(10) + error-status:get-message(1) VIEW-AS ALERT-BOX ERROR.
        undo, return error.
      end.
      v-rec = ?.
    end.
    RUN wth-parts-rezerv ( yes
                         ,tt-wth-parts.fact-rangeFrom
                        , tt-wth-parts.fact-RangeTo
                        , tt-wth-parts.beg-dt
                        , tt-wth-parts.end-dt
                        , tt-wth-parts.ser-code
                        , tt-wth-parts.db-num
                        , tt-wth-parts.price-rubl
                        , tt-wth-parts.price-base
                        , tt-wth-parts.vat-pc
                        , p-curr-host-code
                        , pobj-type
                        , pobj-code
                        , pw-p-code
                        , pwth-code
                        , ppar-code
                        , pin-code
                        , pout-code
                        , tt-wth-parts.cli-type
                        , tt-wth-parts.cli-code
                        , buf_wth-doc.ext-doc-type
                        , b-goods.gds-code
                        , ptype
                        , INPUT-OUTPUT v-rec
                        ) no-error .
    if error-status:error then do:
        MESSAGE RETURN-VALUE VIEW-AS ALERT-BOX ERROR.
        undo, return error.
    end.
  end.
end.
p-rec = v-rec.
END PROCEDURE.
