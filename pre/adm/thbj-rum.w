DEFINE TEMP-TABLE tt-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt0-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt2-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as char no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
define input parameter p-profile-type as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Привязки RUM" .
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
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable v-r-b-code like ub.currency.curr-code no-undo .
define variable v-curr-r-b  as character no-undo .
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info4 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info4, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info4, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info4 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info4, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info4, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info4, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info4, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info4, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info4, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info4 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info4, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info4 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
FUNCTION calldscr returns character ( input p-call-id as character):
define variable v-descr as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo.
define variable v-prop-label as character no-undo .
define variable v-node-label as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-label as character no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-map for ub.prop-map.
run gen-key-fv in this-procedure ( input p-call-id
                                  ,output v-field-list
                                  ,output v-value-list) no-error .
if error-status:error then return p-call-id.
CASE entry(1, p-call-id, chr(3)):
  when 'dis-card-type':U then do:
    v-descr = substitute("Тип ДК: эмитент &1 тип: &2"
                         ,integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ,entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card':U then do:
    v-descr = substitute("ДК: № &1"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card-property':U then do:
    v-dt-code = integer(entry(lookup("dt-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-node-code = integer(entry(lookup("node-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-host-code = integer(entry(lookup("host-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-obj-type = entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3)) .
    v-obj-code = integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    find first buf_prop-ref no-lock where
              buf_prop-ref.dt-code = v-dt-code no-error .
    if available buf_prop-ref then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error .
      v-prop-label = buf_prop-head.prop-label.
      find first buf_prop-map no-lock where
                buf_prop-map.dtm-code = buf_prop-ref.dtm-code
            and buf_prop-map.node-code = v-node-code no-error .
      if available buf_prop-map then do:
        v-label = buf_prop-map.node-label.
      end.
    end.
    v-descr = substitute("ДК: № &1 &2:&3 &4"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ,v-prop-label
                         ,v-label
                         ,get-region(v-host-code, v-obj-type, v-obj-code)
                         ).
  end.
  when 'clients':U then do:
    v-descr = substitute("&1&2"
                         ,entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ,integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ).
  end.
  when 'ext-system':U then do:
    v-descr = substitute("Внешняя система &1"
                         ,integer(entry(lookup("esys-id", v-field-list, chr(3)), v-value-list, chr(3)))
                         ).
  end.
  WHEN 'thbj-attr':U then do:
    if entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum':U
    or entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum_obj':U
    then do:
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'goods':U then do:
        v-descr = "Операции с товарами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'clients':U then do:
        v-descr = "Операции с клиентами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'gds-grp':U then do:
        v-descr = "Операции с группами товаров".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'cli-grp':U then do:
        v-descr = "Операции с группами клиентов".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th':U then do:
        v-descr = "Операции с чеками на POS IBS-TH".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th-mob':U then do:
        v-descr = "Операции с чеками на POS IBS-TH-MOB".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'edoc':U then do:
        v-descr = "Операции в системе электронного документооборота".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'thref':U then do:
        v-descr = "Операции со справочниками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'pdf':U then do:
        v-descr = "Операции с ДНЦ и переоценками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rep':U then do:
        v-descr = "Отчеты".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'ord':U then do:
        v-descr = "Операции с заказами".
      end.
    end.
  end.
  when 'cash-desk':U then do:
    v-descr = substitute("БД &1 Маг &2 Касса № &4 &3"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("cash-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("pos-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'ext-file':U then do:
    v-descr = substitute("БД &1 Файл № &3 (из БД &2)"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("from-db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("file-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
end case.
return v-descr.
end function.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
function check-entry-with-mask returns logical ( input p-element as character, input p-list as character, input p-delimiter as character ) :
  define variable p-entry   as logical   no-undo .
  define variable v-ind as integer   no-undo .
  if p-delimiter = "*":U then do:
    message
      vss-workfile "(check-entry-with-mask)" vss-revision vss-description skip
      substitute('Разделитель не может быть равный "&1"', p-delimiter ) skip
      view-as alert-box error .
    return ? .
  end.
  assign
    p-entry = true
  .
  if lookup( p-element, p-list, p-delimiter ) = 0 then do:
    assign
      p-entry = false
    .
    if num-entries( p-list, "*":U ) > 1 then do:
      block_check-list:
      do v-ind = 1 to num-entries( p-list, p-delimiter )
      :
        if p-element matches entry( v-ind, p-list, p-delimiter ) then do:
          assign
            p-entry = true
          .
          leave block_check-list .
        end.
      end.
    end.
  end.
  return p-entry .
end function .
PROCEDURE thbj-rum_fill-table :
define input  parameter p-profile-type as character no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-silent as logical   no-undo .
define input  parameter p-uniq-key-rec as character no-undo .
DEFINE VARIABLE v-dct-algo-call-id AS CHARACTER NO-UNDO.
define variable v-profile-id-list as character no-undo .
define variable v-call-id-list as character no-undo .
define variable v-once-more-list as character no-undo .
define variable v-current-profile-id as integer no-undo .
define variable v-current-uniq-key-rec as character no-undo .
define variable v-current-once-more as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-obj-fill as logical no-undo .
DEFINE BUFFER buf_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER buf_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER buf2_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_rule-call-param FOR ub.rule-call-param.
fill-block:
do
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:  .
if num-entries (p-mode, chr(4)) > 1 then do:
  assign
  v-obj-fill = (entry(2, p-mode, chr(4) ) = "obj")
  p-mode = entry(1, p-mode, chr(4) )
  .
end.
IF p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
  FOR EACH buf_rp-by-call NO-LOCK WHERE
           buf_rp-by-call.call_id = p-uniq-key-rec
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    find first buf_rule-profile no-lock where
              buf_rule-profile.profile_id = buf_rp-by-call.profile_id no-error.
    if v-obj-fill
    and lookup("obj", buf_rule-profile.short-name) = 0 then next.
    assign
    v-call-id-list = v-call-id-list +  (if v-call-id-list = '' then '' else chr(4))  +  buf_rp-by-call.call_id
    v-profile-id-list = v-profile-id-list + (if v-profile-id-list = '' then '' else chr(44)) + string(buf_rp-by-call.profile_id)
    v-once-more-list = v-once-more-list + (if v-once-more-list = '' then '' else chr(44))  +  string(buf_rp-by-call.once-more)
    .
    if available buf_rule-profile
    and buf_rule-profile.profile-type = 'cmb':U then do:
      do v-ii = 1 to num-entries('dis-card-type,goods,clients,gds-grp,cli-grp,chk-doc_IBS-TH,chk-doc_IBS-TH-MOB,edoc,thref,pdf,rep,ord,cmb,fdoc':U)  :
        v-current-uniq-key-rec = p-uniq-key-rec.
        entry(lookup('cmb':U, p-uniq-key-rec, chr(3)), v-current-uniq-key-rec, chr(3)) = entry(v-ii, 'dis-card-type,goods,clients,gds-grp,cli-grp,chk-doc_IBS-TH,chk-doc_IBS-TH-MOB,edoc,thref,pdf,rep,ord,cmb,fdoc':U).
        for each buf2_rp-by-call no-lock where
                buf2_rp-by-call.call_id = v-current-uniq-key-rec
            and buf2_rp-by-call.parent-profile_id = buf_rp-by-call.profile_id
            and buf2_rp-by-call.parent-once-more = buf_rp-by-call.once-more
            :
          v-current-profile-id = buf_rp-by-call.profile_id.
          assign
          v-call-id-list = v-call-id-list +  chr(4)  +  buf2_rp-by-call.call_id
          v-profile-id-list = v-profile-id-list + chr(44) + string(buf2_rp-by-call.profile_id)
          v-once-more-list = v-once-more-list +  chr(44)  +  string(buf2_rp-by-call.once-more)
          .
        end.
      end.
    end.
  END.
  do v-ii = 1 to num-entries(v-call-id-list, chr(4) )  :
    v-current-uniq-key-rec = entry(v-ii, v-call-id-list, chr(4)).
    v-current-profile-id = integer(entry(v-ii, v-profile-id-list)).
    v-current-once-more = integer(entry(v-ii, v-once-more-list)).
    FOR EACH buf_rp-by-call NO-LOCK WHERE
            buf_rp-by-call.call_id = v-current-uniq-key-rec
      on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
      :
      find first buf_rule-profile no-lock where
                buf_rule-profile.profile_id = buf_rp-by-call.profile_id no-error.
      if v-obj-fill
      and lookup("obj", buf_rule-profile.short-name) = 0 then next.
      find first tt0-rp-by-call where
                tt0-rp-by-call.call_id = buf_rp-by-call.call_id
           and  tt0-rp-by-call.profile_id = buf_rp-by-call.profile_id
           and  tt0-rp-by-call.once-more = buf_rp-by-call.once-more no-error.
      if not available tt0-rp-by-call then do:
    CREATE tt0-rp-by-call.
    BUFFER-COPY buf_rp-by-call TO tt0-rp-by-call.
    end.
    end.
  FOR EACH buf_rule-by-call  NO-LOCK WHERE
              buf_rule-by-call.call_id = v-current-uniq-key-rec
  on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
  :
      find first tt0-rule-by-call where
              tt0-rule-by-call.call_id = buf_rule-by-call.call_id
          and tt0-rule-by-call.codex_id = buf_rule-by-call.codex_id
          and tt0-rule-by-call.ruleset_id = buf_rule-by-call.ruleset_id
          and tt0-rule-by-call.order_id = buf_rule-by-call.order_id no-error.
      if not available tt0-rule-by-call then do:
    CREATE tt0-rule-by-call.
    BUFFER-COPY buf_rule-by-call TO tt0-rule-by-call.
    FOR EACH buf_rule-call-param NO-LOCK WHERE
          buf_rule-call-param.codex_id = tt0-rule-by-call.codex_id
      AND buf_rule-call-param.ruleset_id = tt0-rule-by-call.ruleset_id
      AND buf_rule-call-param.call_id = tt0-rule-by-call.call_id
      AND buf_rule-call-param.order_id = tt0-rule-by-call.order_id
        AND buf_rule-call-param.profile_id = tt0-rule-by-call.profile_id
        AND buf_rule-call-param.once-more = tt0-rule-by-call.once-more
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
      CREATE tt0-rule-call-param.
      BUFFER-COPY buf_rule-call-param TO tt0-rule-call-param.
    END.
      end.
  END.
  end.
END.
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
  FOR EACH buf_rule-profile NO-LOCK WHERE
            buf_rule-profile.profile-type = p-profile-type
       AND buf_rule-profile.IS_dynamic = no
    on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
    :
    run thbj-rum_proc-b-addalgo in this-procedure (  input p-silent
                                           ,input yes
                                           ,input p-uniq-key-rec
                                           ,buffer buf_rule-profile
                                            ) no-error .
    if error-status:error then do:
      undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
  END.
END.
end.
END PROCEDURE.
PROCEDURE thbj-rum_rename-call-id :
define input  parameter p-from-call-id as character no-undo .
define input  parameter p-to-call-id as character no-undo .
fill-block:
do
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:
for each tt0-rp-by-call
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:
  if tt0-rp-by-call.call_id = p-from-call-id then do:
    assign
    tt0-rp-by-call.call_id = p-to-call-id.
  end.
end.
for each tt0-rule-by-call
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:
  if tt0-rule-by-call.call_id = p-from-call-id then do:
    assign
    tt0-rule-by-call.call_id = p-to-call-id.
  end.
end.
for each tt0-rule-call-param
on error  undo fill-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo fill-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo fill-block, return error substitute( "&1. endkey", vss-workfile )
:
  if tt0-rule-call-param.call_id = p-from-call-id then do:
    assign
    tt0-rule-call-param.call_id = p-to-call-id.
  end.
end.
end.
END PROCEDURE.
PROCEDURE thbj-rum_proc-b-addalgo :
define input  parameter p-silent as logical   no-undo .
define input  parameter p-start as logical   no-undo .
define input  parameter p-uniq-key-rec as character no-undo .
DEFINE PARAMETER BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE VARIABLE v-order-id AS INTEGER NO-UNDO.
define variable v-rule-uniq-key-rec as character no-undo .
define variable v-dcta-uniq-key-rec as character no-undo .
define variable v-found-params as logical no-undo .
define variable v-found-can-calc as logical no-undo .
define variable v-disabled as logical no-undo .
define variable glog as logical no-undo .
define variable v-once-more as integer no-undo .
define variable v-main-once-more as integer no-undo .
define variable v-par-val as character no-undo .
define variable v-par-type as character no-undo .
define variable v-rule-profile-uniq-key-rec as character no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-param-form as character no-undo .
define variable v-profile-list  as character no-undo .
define variable v-uniq-key-rec-list as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
DEFINE BUFFER buf_tt0-rp-by-call FOR tt0-rp-by-call.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_rule FOR ub.RULE.
DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict2 for ub.ruledict.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_ruledict-param2 for ub.ruledict-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
define buffer buf3_tt0-rp-by-call for tt0-rp-by-call.
FIND LAST buf_tt0-rp-by-call NO-LOCK WHERE
          buf_tt0-rp-by-call.call_id = p-uniq-key-rec
      AND buf_tt0-rp-by-call.profile_id = buf_rule-profile.profile_id NO-ERROR.
if buf_rule-profile.parent-feature = integer('1':U) then do:
  undo, return error substitute("Подключение данного алгоритма возможно только через комбинированный алгоритм").
end.
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
run  gen-key-fv in this-procedure ( input p-uniq-key-rec
                                   ,output v-field-list
                                   ,output v-value-list).
if lookup("obj-type", v-field-list, chr(3)) > 0 then do:
  assign
  v-obj-type = entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3))
  v-obj-code = integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) )
  .
end.
if lookup(buf_rule-profile.short-name, "obj") = 0
and v-obj-type <> ''
then do:
  undo, return error substitute("Данный алгоритм НЕЛЬЗЯ добавлять в контексте объекта!").
end.
IF AVAILABLE buf_tt0-rp-by-call THEN do:
  v-main-once-more = buf_tt0-rp-by-call.once-more.
  if buf_rule-profile.is_dynamic = no
  then do:
   undo, return error substitute("Алгоритм &1 уже подключен", buf_rule-profile.profile_id).
  end.
  v-disabled = yes.
  for each buf_rule-by-profile no-lock where
         buf_rule-by-profile.profile_id = buf_rule-profile.profile_id,
     first buf_rule no-lock where
          buf_rule.rule_id = buf_rule-by-profile.rule_id:
     v-disabled = v-disabled and (buf_rule.reusable-params = "-":U).
  end.
  if v-disabled then do:
    undo, return error substitute("Алгоритм &1 уже подключен&2" +
                                  "В нем нет ни одного правила, которое можно выполнить повторно"
                                  ,buf_rule-profile.profile_id
                                  ,chr(10)
                                  ).
  end.
  else do:
    if p-silent = no then do:
      MESSAGE
      substitute("Алгоритм уже подключен&1"+
                "Выполнение привязанных к нему правил повторно возможно только при указании соответствущих значений параметров&1" +
                "Все равно подключить алгоритм?"
                , chr(10))
      VIEW-AS ALERT-BOX question buttons YES-NO update glog.
      if not glog then    RETURN ERROR.
    end.
    else do:
      undo, return error substitute("Алгоритм &1 уже подключен&2"+
                                    "Выполнение привязанных к нему правил повторно возможно только при указании соответствущих значений параметров").
    end.
  end.
END.
if buf_rule-profile.param-code <> '':U then do:
  if buf_rule-profile.param-code = 'sys-key' then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-par-val
  ) no-error .
    if error-status:error then do:
      undo, return error
      substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                  "который должен быть включен для работы профайла &3"
                  ,buf_rule-profile.param-code
                  ,chr(10)
                  ,buf_rule-profile.profile_id).
    end.
    if check-entry-with-mask(v-par-val, buf_rule-profile.param-value, chr(4)) = no
    and not (buf_rule-profile.param-code = 'sys-key'
              and
              v-par-val = 'IBS')
    then do:
      undo, return error
      substitute("Значения sys-key=&1,&2" +
                  "что не удовлетворяет условиям работы профайла &3"
                  ,v-par-val
                  ,chr(10)
                  ,buf_rule-profile.profile_id).
    end.
  end.
  else do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  buf_rule-profile.param-code
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-par-val
  ,output v-par-type
  ) no-error .
    if error-status:error then do:
      undo, return error
      substitute("Ошибка при определении значения конфигурационного параметра &1,&2" +
                  "который должен быть включен для работы профайла &3"
                  ,buf_rule-profile.param-code
                  ,chr(10)
                  ,buf_rule-profile.profile_id).
    end.
    if lookup(v-par-val, buf_rule-profile.param-value, chr(4)) = 0
    then do:
      undo, return error
      substitute("Значения конфигурационного параметра &1=&2,&3" +
                  "что не удовлетворяет условиям работы профайла &4"
                  ,buf_rule-profile.param-code
                  ,v-par-val
                  ,chr(10)
                  ,buf_rule-profile.profile_id).
    end.
  end.
end.
v-profile-list = string(buf_rule-profile.profile_id).
v-uniq-key-rec-list = p-uniq-key-rec.
if buf_rule-profile.profile-type = 'cmb':U then do:
  define variable v-once-more-list as character no-undo .
  define variable v-ii as integer no-undo .
  define variable v-current-uniq-key-rec as character no-undo .
  define buffer buf2_rule-profile for ub.rule-profile.
  define buffer buf_profile-by-profile for ub.profile-by-profile.
  for each buf_profile-by-profile no-lock where
          buf_profile-by-profile.profile_id = buf_rule-profile.profile_id,
     first buf2_rule-profile no-lock where
          buf2_rule-profile.profile_id = buf_profile-by-profile.child-profile_id
  on error undo, return error:
    v-profile-list = v-profile-list + chr(44) + string(buf2_rule-profile.profile_id).
    v-current-uniq-key-rec = p-uniq-key-rec.
    entry(lookup('cmb':U, p-uniq-key-rec, chr(3)), v-current-uniq-key-rec, chr(3)) = buf2_rule-profile.profile-type.
    v-uniq-key-rec-list = v-uniq-key-rec-list + chr(4) + v-current-uniq-key-rec.
  end.
end.
for each tt2-rule-call-param:
  delete tt2-rule-call-param.
end.
do v-ii = 1 to num-entries(v-profile-list):
find first buf2_rule-profile no-lock where
          buf2_rule-profile.profile_id = integer(entry(v-ii, v-profile-list)).
FIND LAST buf3_tt0-rp-by-call NO-LOCK WHERE
          buf3_tt0-rp-by-call.call_id = p-uniq-key-rec
      AND buf3_tt0-rp-by-call.profile_id = integer(entry(v-ii, v-profile-list)) NO-ERROR.
if available buf3_tt0-rp-by-call then do:
  v-once-more = buf3_tt0-rp-by-call.once-more.
end.
CREATE buf_tt0-rp-by-call.
BUFFER-COPY buf2_rule-profile TO buf_tt0-rp-by-call
ASSIGN
buf_tt0-rp-by-call.CALL_id = entry(v-ii, v-uniq-key-rec-list, chr(4) )
buf_tt0-rp-by-call.once-more = v-once-more + 1
buf_tt0-rp-by-call.parent-profile_id = (if buf_rule-profile.profile-type = 'cmb':U
                                      and buf2_rule-profile.profile-type <> 'cmb':U
                                      then buf_rule-profile.profile_id else 0)
buf_tt0-rp-by-call.parent-once-more = (if buf_rule-profile.profile-type = 'cmb':U
                                      and buf2_rule-profile.profile-type <> 'cmb':U
                                      then v-main-once-more else 0)
v-once-more-list = v-once-more-list + (if v-once-more-list = '' then '' else chr(44)) + string(buf_tt0-rp-by-call.once-more)
.
if buf2_rule-profile.profile_id = buf_rule-profile.profile_id then do:
  v-main-once-more = buf_tt0-rp-by-call.once-more.
end.
if buf_rule-profile.profile-type = 'cmb':U
and buf2_rule-profile.profile-type <> 'cmb':U then do:
  run  thbj-rum_fill-table in this-procedure ( input buf2_rule-profile.profile-type
                                              ,input 'ИЗМЕНЕНИЕ':U
                                              ,input yes
                                              ,input buf_tt0-rp-by-call.CALL_id ).
end.
_rule-by-profile:
FOR EACH buf_rule-by-profile NO-LOCK WHERE
        buf_rule-by-profile.profile_id = buf_tt0-rp-by-call.profile_id
BY buf_rule-by-profile.profile_id
BY buf_rule-by-profile.codex_id
BY buf_rule-by-profile.ruleset_id
BY buf_rule-by-profile.rp_order_id
ON error undo, return error :
  if buf2_rule-profile.profile-type <> 'cmb':U then do:
 FIND FIRST buf_rule NO-LOCK WHERE
                buf_rule.RULE_id = buf_rule-by-profile.RULE_id NO-ERROR.
 IF NOT AVAILABLE buf_rule THEN DO:
   undo, return error
   SUBSTITUTE("Не найдено правило &1, которое должно быть подключено по алгоритму &2&3" +
                   "кодекс правил &4, свод правил &5"
                   , buf_rule-by-profile.RULE_id
                   , buf_rule-by-profile.profile_id
                   , chr(10)
                   , buf_rule-by-profile.codex_id
                   , buf_rule-by-profile.ruleset_id).
 END.
  FIND LAST buf_tt0-rule-by-call WHERE
            buf_tt0-rule-by-call.codex_id =  buf_rule-by-profile.codex_id
        AND buf_tt0-rule-by-call.ruleset_id = buf_rule-by-profile.ruleset_id
  USE-INDEX imain NO-ERROR.
  IF AVAILABLE buf_tt0-rule-by-call THEN DO:
     v-order-id = buf_tt0-rule-by-call.order_id + 1.
  END.
  ELSE DO:
     v-order-id = 0.
  END.
  CREATE buf_tt0-rule-by-call.
  BUFFER-COPY buf_rule-by-profile TO buf_tt0-rule-by-call
  ASSIGN
  buf_tt0-rule-by-call.order_id = v-order-id
    buf_tt0-rule-by-call.algo-des = substitute("Профайл &1. &2", buf2_rule-profile.profile_id, buf_rule.NAME)
  buf_tt0-rule-by-call.is_dynamic = buf_rule-by-profile.IS_dynamic
  buf_tt0-rule-by-call.can-calc = (IF not buf_tt0-rule-by-call.is_dynamic
                                   or (buf_tt0-rule-by-call.codex_id = 22
                                       and
                                       buf_tt0-rule-by-call.ruleset_id = 1)
                                     THEN yes
                                     ELSE no)
  buf_tt0-rule-by-call.call_id = entry(v-ii, v-uniq-key-rec-list, chr(4) )
  buf_tt0-rule-by-call.once-more = v-once-more + 1
  v-found-can-calc = v-found-can-calc or buf_tt0-rule-by-call.can-calc
  .
  find first buf_ruledict no-lock where
          buf_ruledict.entry-type = 'rule':U
      and  buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
  run gen-key-rec in this-procedure (
                                     input  'rule-profile':U
                                      ,input buffer buf2_rule-profile:handle
                                    ,output v-rule-profile-uniq-key-rec).
  find first buf_ruledict2 no-lock where
          buf_ruledict2.entry-type = 'rule-profile':U
      and  buf_ruledict2.uniq-key-rec = v-rule-profile-uniq-key-rec.
  for each buf_ruledict-param no-lock where
          buf_ruledict-param.entry-id = buf_ruledict.entry-id
  on error undo, return error:
  find first buf_rp-rule-param no-lock where
              buf_rp-rule-param.profile_id = buf2_rule-profile.profile_id
        and buf_rp-rule-param.rule-param-name = buf_ruledict-param.param-name
        and buf_rp-rule-param.codex_id = buf_rule-by-profile.codex_id
        and buf_rp-rule-param.ruleset_id = buf_rule-by-profile.ruleset_id
        and buf_rp-rule-param.rule_id = buf_rule-by-profile.rule_id
        and buf_rp-rule-param.rp_order_id = buf_rule-by-profile.rp_order_id.
    find first buf_ruledict-param2 no-lock where
          buf_ruledict-param2.entry-id = buf_ruledict2.entry-id
      and buf_ruledict-param2.param-name = buf_rp-rule-param.rp-param-name.
    create buf_tt0-rule-call-param.
    assign
    buf_tt0-rule-call-param.codex_id = buf_tt0-rule-by-call.codex_id
    buf_tt0-rule-call-param.ruleset_id = buf_tt0-rule-by-call.ruleset_id
    buf_tt0-rule-call-param.call_id  = buf_tt0-rule-by-call.call_id
    buf_tt0-rule-call-param.order_id = buf_tt0-rule-by-call.order_id
    buf_tt0-rule-call-param.rule_id = buf_rule.rule_id
    buf_tt0-rule-call-param.param-name = buf_ruledict-param.param-name
    buf_tt0-rule-call-param.p-index = 0
    buf_tt0-rule-call-param.param-des = buf_ruledict-param.documentation
    buf_tt0-rule-call-param.param-num = buf_ruledict-param.param-num
    buf_tt0-rule-call-param.param-label = buf_ruledict-param.param-label
    buf_tt0-rule-call-param.param-mode = buf_ruledict-param.param-mode
    buf_tt0-rule-call-param.param-data-type = buf_ruledict-param.param-data-type
    buf_tt0-rule-call-param.param-2-data-type = buf_ruledict-param.param-2-data-type
    buf_tt0-rule-call-param.param-3-data-type = buf_ruledict-param.param-3-data-type
    buf_tt0-rule-call-param.param-value-character = buf_ruledict-param2.init-value-character
    buf_tt0-rule-call-param.param-value-date = buf_ruledict-param2.init-value-date
    buf_tt0-rule-call-param.param-value-decimal = buf_ruledict-param2.init-value-decimal
    buf_tt0-rule-call-param.param-value-integer = buf_ruledict-param2.init-value-integer
    buf_tt0-rule-call-param.param-value-logical = buf_ruledict-param2.init-value-logical
    buf_tt0-rule-call-param.profile_id          = buf_tt0-rule-by-call.profile_id
    buf_tt0-rule-call-param.once-more           = buf_tt0-rule-by-call.once-more
    .
    if buf_ruledict-param.param-2-data-type = "r-b" then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
      buf_tt0-rule-call-param.param-value-character = (if v-curr-r-b = 'rubl':U
                                                       then 'rubl':U
                                                       else 'base':U).
    end.
    assign
    v-found-params = yes.
    create tt2-rule-call-param.
    buffer-copy buf_tt0-rule-call-param to tt2-rule-call-param.
    release tt2-rule-call-param.
  end.
  end.
END.
end.
if v-found-params
and not p-start
and not p-silent
then do:
  if search( substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)) <> ?
  or search( substitute("rul/rcps-&1.r", buf_rule-profile.profile_id)) <> ?
  then do:
    v-param-form = substitute("rul/rcps-&1.w", buf_rule-profile.profile_id).
  end.
  else do:
    v-param-form = "ref/rulercps.w" .
  end.
  if buf_rule-profile.profile-type = 'cmb':U
  and v-param-form = "ref/rulercps.w" then do:
    message
    "Для комбинированных алгоритмов необходимо написать отдельную форму задания параметров!"
    view-as alert-box error .
    return error.
  end.
  if v-obj-type <> ''
  and lookup("obj", buf_rule-profile.short-name) = 0
  then do:
    message
    "Данный алгоритм НЕЛЬЗЯ добавлять в контексте объекта!"
    view-as alert-box error .
    return error.
  end.
  run value(v-param-form) (
                       input parparentproc
                      ,input this-procedure:handle
                      ,input "b-chg":U
                      ,input 'ДОБАВЛЕНИЕ':U
                      ,input 'rp-rule-param':U
                      ,input buf_rule-profile.profile_id
                      ,input v-main-once-more
                      ,input p-uniq-key-rec
                      ,input 0
                      ,input 0
                      ,INPUT 0
                      ,input 0
                      ,INput substitute("алгоритм &1 &2"
                                       , buf_rule-profile.name
                                      , calldscr(p-uniq-key-rec)
                                       )
                      ,input-output table tt2-rule-call-param) no-error.
  if not error-status:error then do:
    for each tt2-rule-call-param
    on error undo, return error:
      find first buf_tt0-rule-call-param where
                buf_tt0-rule-call-param.call_id = tt2-rule-call-param.call_id
            and buf_tt0-rule-call-param.codex_id = tt2-rule-call-param.codex_id
            and buf_tt0-rule-call-param.ruleset_id = tt2-rule-call-param.ruleset_id
            and buf_tt0-rule-call-param.order_id = tt2-rule-call-param.order_id
            and buf_tt0-rule-call-param.param-name = tt2-rule-call-param.param-name
            and buf_tt0-rule-call-param.p-index = tt2-rule-call-param.p-index no-error .
      if not available buf_tt0-rule-call-param
      and (lookup("LIST", tt2-rule-call-param.param-3-data-type) > 0
           or
           lookup("SORTED-LIST", tt2-rule-call-param.param-3-data-type) > 0
           )
      then do:
        create buf_tt0-rule-call-param.
      end.
      buffer-copy tt2-rule-call-param to buf_tt0-rule-call-param.
      delete tt2-rule-call-param.
    end.
  end.
end.
END PROCEDURE.
define variable add-option as character no-undo.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.
DEFINE VARIABLE v-mode AS CHARACTER NO-UNDO EXTENT 3.
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
define variable v-start as logical no-undo .
define variable v-h-name as handle no-undo .
define variable v-is-copy as logical no-undo .
define variable v-orig-uniq-key-rec as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
FUNCTION get-profile-documentation RETURNS CHARACTER
  ( p-profile_id AS INTEGER )  FORWARD.
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( p-profile_id AS INTEGER )  FORWARD.
FUNCTION get-profile-name RETURNS CHARACTER
  ( p-profile_id AS INTEGER )  FORWARD.
DEFINE MENU MENU-B-rule
       MENU-ITEM m_text         LABEL "Текст"
       MENU-ITEM m_graph        LABEL "Граф"          .
DEFINE BUTTON b-addalgo
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-delalgo
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-params
     LABEL "Параметры"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-rule
     LABEL "Правило"
     SIZE 10 BY 1.
DEFINE BUTTON b-rule-on-off
     LABEL "Вкл"
     SIZE 5 BY 1.
DEFINE BUTTON B-ruleset
     LABEL "Т-ка вызова"
     SIZE 14 BY 1.
DEFINE VARIABLE E-rule-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 4.17
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE Rs-algo-profile AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2"
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE rs-algo-types AS INTEGER INITIAL 2
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 1,
"Настраив.", 2
     SIZE 18 BY .77 NO-UNDO.
DEFINE QUERY br-profile FOR
      tt0-rp-by-call SCROLLING.
DEFINE QUERY br-rule-by-call FOR
      tt0-rule-by-call,
      X_rule-profile SCROLLING.
DEFINE BROWSE br-profile
  QUERY br-profile NO-LOCK DISPLAY
      tt0-rp-by-call.profile_id COLUMN-LABEL "Про!файл" FORMAT ">>9":U
get-profile-name ( INPUT tt0-rp-by-call.profile_id) COLUMN-LABEL "Название алгоритма" FORMAT "X(255)"
get-profile-dynamic ( INPUT tt0-rp-by-call.profile_id) COLUMN-LABEL "Отклю!чаемый" FORMAT "+/":U
tt0-rp-by-call.once-more COLUMN-LABEL "№ привязки" FORMAT ">9"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.77
         FONT 4 ROW-HEIGHT-CHARS .67.
DEFINE BROWSE br-rule-by-call
  QUERY br-rule-by-call NO-LOCK DISPLAY
      tt0-rule-by-call.can-calc COLUMN-LABEL "Вкл." FORMAT "+/":U
tt0-rule-by-call.algo-des COLUMN-LABEL "Описание алгоритма/правила" FORMAT "X(255)":U WIDTH 40
tt0-rule-by-call.is_dynamic COLUMN-LABEL "Отклю!чаемое?" FORMAT "+/":U
tt0-rule-by-call.codex_id COLUMN-LABEL "Кодекс!правил" FORMAT ">,>>>,>>9":U
tt0-rule-by-call.ruleset_id COLUMN-LABEL "Набор!правил" FORMAT ">,>>>,>>9":U
tt0-rule-by-call.order_id COLUMN-LABEL "Порядок!вызова" FORMAT ">>9":U WIDTH 9
tt0-rule-by-call.rule_id COLUMN-LABEL "Код!правила" FORMAT ">>>,>>>,>>9":U WIDTH 9
tt0-rule-by-call.profile_id COLUMN-LABEL "Алгоритм" FORMAT ">>9":U WIDTH 8
tt0-rule-by-call.once-more COLUMN-LABEL "№ привязки" FORMAT ">9"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 15.77
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     b-quit AT ROW 1 COL 11.1
     B-Help AT ROW 1 COL 95
     Rs-algo-profile AT ROW 2 COL 1 NO-LABEL WIDGET-ID 2
     rs-algo-types AT ROW 2 COL 22 NO-LABEL
     b-addalgo AT ROW 2 COL 40
     b-delalgo AT ROW 2 COL 50
     b-params AT ROW 2 COL 60 WIDGET-ID 6
     B-rule AT ROW 2 COL 70
     B-ruleset AT ROW 2 COL 80 WIDGET-ID 26
     b-rule-on-off AT ROW 2 COL 94
     br-rule-by-call AT ROW 3 COL 1
     br-profile AT ROW 3 COL 1 WIDGET-ID 100
     E-rule-name AT ROW 18.77 COL 1 NO-LABEL
     SPACE(0.00) SKIP(0.34)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Привязки RUM"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-rule:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-rule:HANDLE.
ASSIGN
       E-rule-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-addalgo IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-ref-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
run ref/rulprofs.w (
                     INPUT parparentproc
                    ,INPUT "b-sel"
                    ,INPUT (p-profile-type + (if parobj-type <> "" then (chr(4) + parobj-type) else ""))
                    ,INPUT-OUTPUT v-ref-list) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
    RETURN NO-apply.
END.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          recid(buf_rule-profile) = INTEGER(v-ref-list) NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN NO-APPLY.
if buf_rule-profile.parent-feature = integer('1':U) then do:
  message
  "Данный алгоритм можно добавлять ТОЛЬКО В СОСТАВЕ КОМБИНИРОВАННЫХ АЛГОРИТМОВ!"
  view-as alert-box error.
  undo, return no-apply.
end.
if lookup(buf_rule-profile.short-name, "obj") = 0
and v-obj-type <> ''
then do:
  message
  "Данный алгоритм НЕЛЬЗЯ добавлять в контексте объекта!"
  view-as alert-box error.
  undo, return no-apply.
end.
  RUN proc-b-addalgo IN THIS-PROCEDURE ( BUFFER buf_rule-profile) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF b-delalgo IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt0-rp-by-call THEN RETURN NO-APPLY.
  run proc-b-delalgo IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  APPLY "value-changed" TO br-rule-by-call.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-params IN FRAME Dialog-Frame
DO:
  CASE Rs-algo-profile:
    when 'rule-by-call':U then do:
      IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
      run ref/rulercps.w (
                             input parparentproc
                            ,input this-procedure:handle
                            ,input '':U
                            ,input 'ПРОСМОТР':U
                            ,input 'rule-call-param':U
                            ,input 0
                            ,input ?
                            ,input tt0-rule-by-call.call_id
                            ,input tt0-rule-by-call.codex_id
                            ,input tt0-rule-by-call.ruleset_id
                            ,input tt0-rule-by-call.order_id
                            ,input tt0-rule-by-call.RULE_id
                            ,INput substitute("Правило &1 &2"
                                             , tt0-rule-by-call.RULE_id
                                             , calldscr(tt0-rule-by-call.call_id)
                                             )
                            ,input-output table tt0-rule-call-param  ) no-error.
     end.
     when 'rp-by-call':U then do:
      IF NOT AVAILABLE tt0-rp-by-call THEN RETURN NO-APPLY.
      define variable v-param-form as character no-undo .
      define buffer buf_rule-profile for ub.rule-profile.
      find first buf_rule-profile no-lock where
                buf_rule-profile.profile_id = tt0-rp-by-call.profile_id.
      assign
      v-param-form = (if buf_rule-profile.custom-param-form > 0
                      then  substitute("rul/rcps-&1.w", buf_rule-profile.profile_id)
                      else "ref/rulercps.w")
      .
      if v-obj-type <> ''
      and lookup("obj", buf_rule-profile.short-name) = 0
      then do:
        define variable v-mode as character no-undo .
        v-mode = 'ПРОСМОТР':U.
      end.
      else do:
        v-mode = p-mode.
      end.
      run value(v-param-form) (
                            input parparentproc
                            ,input this-procedure:handle
                            ,input 'b-chg':U
                            ,input v-mode
                            ,input 'rp-rule-param':U
                            ,input tt0-rp-by-call.profile_id
                            ,input tt0-rp-by-call.once-more
                            ,input tt0-rp-by-call.call_id
                            ,input 0
                            ,input 0
                            ,input ?
                            ,input 0
                            ,INput substitute("Профайл &1 № привязки &2 &3"
                                              ,tt0-rp-by-call.profile
                                              ,tt0-rp-by-call.once-more
                                              ,calldscr(tt0-rp-by-call.call_id)
                                              )
                            ,input-output table tt0-rule-call-param  ) no-error.
     end.
   end case.
END.
ON CHOOSE OF B-rule IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  IF rule-display-option = "" THEN DO:
   run gbl/pop-up.p ( input self:handle, input no) no-error.
  END.
  IF rule-display-option = "" THEN DO:
    RETURN NO-APPLY.
  END.
  RUN proc-display-rule IN THIS-PROCEDURE (
                                             INPUT rule-display-option
                                            ,input tt0-rule-by-call.codex_id
                                            ,input tt0-rule-by-call.ruleset_id
                                            ,input tt0-rule-by-call.call_id
                                            ,input tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
    ASSIGN
    rule-display-option = "".
    RETURN NO-APPLY.
  END.
  ASSIGN
  rule-display-option = "".
END.
ON CHOOSE OF b-rule-on-off IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  IF X_rule-profile.IS_dynamic = NO  THEN DO:
     MESSAGE
     substitute("Данное правило не может быть включено/выключено,&1" +
                "так как принадлежит алгоритму ПО УМОЛЧАНИЮ!"
                , chr(10))
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  END.
  if tt0-rule-by-call.is_dynamic = no then do:
     MESSAGE
     substitute("Данное правило не может быть включено/выключено,&1" +
                "согласно определенной профайлом логике!"
                , chr(10))
     VIEW-AS ALERT-BOX ERROR.
     RETURN NO-APPLY.
  end.
  IF tt0-rule-by-call.can-calc THEN DO:
    MESSAGE
    "Вы уверены, что хотите выключить правило?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
    IF NOT glog THEN RETURN NO-APPLY.
  END.
  ELSE DO:
      MESSAGE
      "Вы уверены, что хотите включить правило?"
      VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE gLOG.
      IF NOT glog THEN RETURN NO-APPLY.
  END.
  ASSIGN
  tt0-rule-by-call.can-calc = NOT (tt0-rule-by-call.can-calc).
  glog = br-rule-by-call:REFRESH() IN FRAME Dialog-Frame.
END.
ON CHOOSE OF B-ruleset IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rec AS RECID NO-UNDO.
define buffer buf_ruleset for ub.ruleset.
  IF NOT AVAILABLe tt0-rule-by-call THEN DO:
      RETURN NO-APPLY.
  END.
  FIND FIRST buf_ruleset NO-LOCK WHERE
            buf_ruleset.codex_id = tt0-rule-by-call.codex_id
        AND buf_ruleset.ruleset_id = tt0-rule-by-call.ruleset_id.
  run rul/ruleset-i.w ( input parparentproc
                       ,input 'ПРОСМОТР':U
                       ,input buf_ruleset.codex_id
                       ,input buf_ruleset.ruleset_id
                       ,input-output v-rec) no-error.
END.
ON VALUE-CHANGED OF br-profile IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE tt0-rp-by-call THEN DO:
     e-rule-name:SCREEN-VALUE = ''.
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = get-profile-documentation(tt0-rp-by-call.profile_id).
  END.
END.
ON VALUE-CHANGED OF br-rule-by-call IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_rule FOR ub.RULE.
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  FIND FIRST buf_rule NO-LOCK WHERE
            buf_rule.RULE_id = tt0-rule-by-call.RULE_id NO-ERROR.
  IF NOT AVAILABLE buf_rule THEN DO:
     e-rule-name:SCREEN-VALUE = SUBSTITUTE("!!!Правило &1 не найдено", tt0-rule-by-call.RULE_Id).
  END.
  ELSE DO:
    e-rule-name:SCREEN-VALUE = buf_rule.name + chr(10) + buf_rule.documentation.
  END.
END.
ON CHOOSE OF MENU-ITEM m_graph
DO:
    IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "graph".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT tt0-rule-by-call.codex_id
                                            ,INPUT tt0-rule-by-call.ruleset_id
                                            ,INPUT tt0-rule-by-call.call_id
                                            ,INPUT tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".
END.
ON CHOOSE OF MENU-ITEM m_text
DO:
  IF NOT AVAILABLE tt0-rule-by-call THEN RETURN NO-APPLY.
  ASSIGN
  rule-display-option = "text".
  RUN proc-display-rule IN THIS-PROCEDURE (  INPUT rule-display-option
                                            ,INPUT tt0-rule-by-call.codex_id
                                            ,INPUT tt0-rule-by-call.ruleset_id
                                            ,INPUT tt0-rule-by-call.call_id
                                            ,INPUT tt0-rule-by-call.order_id
                                            ,INPUT tt0-rule-by-call.rule_id) NO-ERROR.
  ASSIGN
  rule-display-option = "".
END.
ON VALUE-CHANGED OF Rs-algo-profile IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-algo-profile.
  CASE rs-algo-profile:
    WHEN 'rule-by-call':U THEN DO:
      HIDE
      br-profile
      b-addalgo
      b-delalgo
      IN FRAME Dialog-Frame.
      .
      DISPLAY
      rs-algo-types
      br-rule-by-call
      b-rule
      b-ruleset
      b-rule-on-off
      WITH FRAME Dialog-Frame.
      APPLY "VALUE-CHANGED" to br-rule-by-call.
    END.
    WHEN 'rp-by-call':U THEN DO:
      HIDE
      br-rule-by-call
      rs-algo-types
      b-rule
      b-ruleset
      b-rule-on-off
      IN FRAME Dialog-Frame.
      DISPLAY
      br-profile
      b-addalgo
      b-delalgo
      WITH FRAME Dialog-Frame.
      APPLY "VALUE-CHANGED" to br-profile.
    END.
  END CASE.
END.
ON VALUE-CHANGED OF rs-algo-types IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-algo-types.
  OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = p-uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
  APPLY "VALUE-CHANGED" TO br-rule-by-call IN FRAME Dialog-Frame.
END.
ON ROW-DISPLAY OF br-profile IN frame Dialog-Frame
DO:
  IF AVAIL tt0-rp-by-call THEN DO:
    RUN set-row-color IN THIS-PROCEDURE ( INPUT tt0-rp-by-call.parent-profile_id).
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-profile :handle
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
procedure rcpscont_get-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define output parameter p-on-off as logical no-undo .
define buffer buf_tt0-rule-by-call for tt0-rule-by-call.
find first buf_tt0-rule-by-call where
         buf_tt0-rule-by-call.codex_id = p-codex-id
     and buf_tt0-rule-by-call.ruleset_id = p-ruleset-id
     and buf_tt0-rule-by-call.profile_id = p-profile-id
     and buf_tt0-rule-by-call.once-more = p-once-more
     and buf_tt0-rule-by-call.rule_id = p-rule-id
     no-error .
if available buf_tt0-rule-by-call then do:
   p-on-off = buf_tt0-rule-by-call.can-calc.
end.
end procedure.
procedure rcpscont_set-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-on-off as logical no-undo .
define variable v-h as handle no-undo .
define buffer buf_tt0-rule-by-call for tt0-rule-by-call.
v-h = buffer tt0-rule-by-call:handle.
if v-h:table <> ''
and v-h:table <> ? then do:
  find first buf_tt0-rule-by-call where
          buf_tt0-rule-by-call.codex_id = p-codex-id
      and buf_tt0-rule-by-call.ruleset_id = p-ruleset-id
      and buf_tt0-rule-by-call.profile_id = p-profile-id
      and buf_tt0-rule-by-call.once-more = p-once-more
      and buf_tt0-rule-by-call.rule_id = p-rule-id   no-error .
  if not available buf_tt0-rule-by-call then do:
    undo, return error .
  end.
  buf_tt0-rule-by-call.can-calc = p-on-off .
  release buf_tt0-rule-by-call.
end.
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = p-uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  if p-mode <> 'ИЗМЕНЕНИЕ':U
  and p-mode <> 'ДОБАВЛЕНИЕ':U
  AND p-mode <> 'ПРОСМОТР':U
  and p-mode <> 'КОПИРОВАНИЕ':U
  then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова p-mode"
        view-as alert-box ERROR.
        return error.
    end.
  if p-mode = 'КОПИРОВАНИЕ':U then do:
    v-is-copy = yes.
    p-mode = 'ИЗМЕНЕНИЕ':U.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      do transaction
      on error undo, return error
      on stop undo, return error
      :
      run gen-row-keyr in this-procedure (
                                           input  p-uniq-key-rec
                                          ,input  ?
                                          ,input  "ub"
                                          ,input  ?
                                          ,input  EXCLUSIVE-LOCK
                                          ,output v-tbl-row
                                          ,output v-tbl-name
                                          ).
        find first buf_thbj-attr EXclusive-lock where
                 rowid(buf_thbj-attr) = v-tbl-row no-wait no-error.
        if locked buf_thbj-attr then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись занята"
          view-as alert-box error .
          return error.
        end.
        if not available buf_thbj-attr then do:
        end.
      end.
    end.
    else do:
      run gen-row-keyr in this-procedure (
                                           input  p-uniq-key-rec
                                          ,input  ?
                                          ,input  "ub"
                                          ,input  ?
                                          ,input  NO-LOCK
                                          ,output v-tbl-row
                                          ,output v-tbl-name
                                          ).
      find first buf_thbj-attr no-lock where
                rowid(buf_thbj-attr) = v-tbl-row .
    end.
    if not available buf_thbj-attr then do:
      message vss-workfile vss-revision vss-description skip
              "Не найдена запись"
      view-as alert-box error .
    end.
    assign
    v-obj-type = buf_thbj-attr.obj-type
    v-obj-code = buf_thbj-attr.obj-code
    .
  end.
  ELSE DO:
  END.
  if v-is-copy
  or ( not (buf_thbj-attr.obj-type = ''
            and
            buf_thbj-attr.obj-code = 0)
       and buf_thbj-attr.property-value-logical = no
          )
  then do:
    define variable v-field-list as character no-undo .
    define variable v-value-list as character no-undo .
    run gen-key-fv in this-procedure ( input p-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
    assign
    v-orig-uniq-key-rec = p-uniq-key-rec.
    assign
    entry(lookup("obj-type", v-field-list, chr(3)) + 1, v-orig-uniq-key-rec, chr(3)) = ''
    entry(lookup("obj-code", v-field-list, chr(3)) + 1, v-orig-uniq-key-rec, chr(3)) = string(0)
    entry(lookup("upper-prop-code", v-field-list, chr(3)) + 1, v-orig-uniq-key-rec, chr(3)) = 'rum':U
    .
    run thbj-rum_fill-table in this-procedure (
                                               input p-profile-type
                                              ,input p-mode + chr(4) + "obj"
                                              ,input yes
                                              ,input v-orig-uniq-key-rec).
   run thbj-rum_rename-call-id in this-procedure (
                                                   input v-orig-uniq-key-rec
                                                  ,input p-uniq-key-rec
                                                  ) no-error.
  end.
  else do:
  RUN thbj-rum_FILL-table IN THIS-PROCEDURE (
                                              input p-profile-type
                                             ,input p-mode
                                             ,input no
                                             ,input p-uniq-key-rec)
                                             no-error .
  end.
  if error-status:error then do:
    message
    error-status:get-message(1) return-value
    view-as alert-box error .
    undo main-block, return error .
  end.
  OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = p-uniq-key-rec NO-LOCK INDEXED-REPOSITION.
  APPLY "VALUE-CHANGED" to br-profile IN FRAME Dialog-Frame.
  OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = p-uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
  APPLY "value-changed" TO br-rule-by-call IN FRAME Dialog-Frame.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE buttons :
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY Rs-algo-profile rs-algo-types E-rule-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help Rs-algo-profile rs-algo-types b-addalgo b-delalgo
         b-params B-rule B-ruleset b-rule-on-off br-rule-by-call br-profile
         E-rule-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = p-uniq-key-rec NO-LOCK INDEXED-REPOSITION.    OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = p-uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-check-by-mask AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-tooltip AS CHARACTER NO-UNDO.
define variable v-label as character no-undo .
define variable v-tooltip-code as character no-undo .
DEFINE VARIABLE clh AS WIDGET-HANDLE NO-UNDO.
DEFINE VARIABLE ii AS integer NO-UNDO.
ASSIGN
rs-algo-profile:RADIO-BUTTONS IN FRAME Dialog-Frame = "Алгоритмы" + chr(44) +
                                 'rp-by-call':U + chr(44) +
                                "Правила" + chr(44) + 'rule-by-call':U.
rs-algo-profile = 'rp-by-call':U.
ASSIGN
tt0-rule-by-call.algo-des:RESIZABLE IN BROWSE br-rule-by-call = YES .
DO ii = 1 TO br-profile:NUM-COLUMNS IN FRAME Dialog-Frame:
    clh = BROWSE br-profile:get-browse-column(ii).
  IF clh:LABEL BEGINS "Название алгоритма" THEN DO:
      ASSIGN
      clh:RESIZABLE = YES
      clh:width = 72
    v-h-name = clh
      .
    END.
END.
  assign
  b-rule:MENU-MOUSE in frame Dialog-Frame = 1
  .
run thbjattr_tooltip in this-procedure (
                                           input  buf_thbj-attr.upper-prop-code
                                          ,input  buf_thbj-attr.prop-code
                                          ,output v-tooltip
                                          ,output v-label
                                          ,output v-tooltip-code ).
frame Dialog-Frame:title = v-label.
DISPLAY
rs-algo-types
rs-algo-profile
WITH FRAME Dialog-Frame.
ENABLE
B-exit when p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
rs-algo-profile
b-rule
b-ruleset
b-addalgo when p-mode <> 'ПРОСМОТР':U
b-delalgo when p-mode <> 'ПРОСМОТР':U
b-rule-on-off when p-mode <> 'ПРОСМОТР':U
b-params
br-rule-by-call
br-profile
rs-algo-types
e-rule-name
WITH FRAME Dialog-Frame.
if p-mode = 'ПРОСМОТР':U then do:
    HIDE
    b-exit in frame Dialog-Frame.
    assign
    b-quit:label in frame Dialog-Frame = "&Выход"
    b-quit:column in frame Dialog-Frame = 1
    e-rule-name:read-only in frame Dialog-Frame = yes
    .
end.
VIEW FRAME Dialog-Frame.
OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = p-uniq-key-rec NO-LOCK INDEXED-REPOSITION.    OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = p-uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" TO rs-algo-profile.
END PROCEDURE.
PROCEDURE proc-b-addalgo :
DEFINE PARAMETER BUFFER buf_rule-profile FOR ub.rule-profile.
run thbj-rum_proc-b-addalgo in this-procedure (  input no
                                        ,input v-start
                                        ,input p-uniq-key-rec
                                        ,buffer buf_rule-profile
                                        ) no-error .
    if error-status:error then do:
      message
  return-value
  view-as alert-box .
  return.
end.
OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = p-uniq-key-rec NO-LOCK INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" to br-profile IN FRAME Dialog-Frame.
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = p-uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
APPLY "value-changed" TO br-rule-by-call IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-delalgo :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-rule-nums AS INTEGER NO-UNDO.
DEFINE VARIABLE v-profile-id AS INTEGER NO-UNDO.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_tt0-rule-by-call FOR tt0-rule-by-call.
DEFINE BUFFER buf_rule-by-profile FOR ub.rule-by-profile.
DEFINE BUFFER buf_tt0-rp-by-call FOR tt0-rp-by-call.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
IF NOT AVAILABLE tt0-rp-by-call THEN RETURN ERROR.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = tt0-rp-by-call.profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN DO:
   MESSAGE
   substitute("Не найден алгоритм с кодом &1", tt0-rp-by-call.profile_id)
   VIEW-AS ALERT-BOX ERROR.
   RETURN ERROR.
END.
IF buf_rule-profile.IS_dynamic = NO THEN DO:
   MESSAGE
   "Привязку к данному алгоритм НЕЛЬЗЯ удалить!"
   VIEW-AS ALERT-BOX ERROR.
   RETURN ERROR.
END.
if buf_rule-profile.parent-feature = integer('1':U)
or tt0-rp-by-call.parent-profile_id > 0
then do:
  message
  "Данный алгоритм можно удалять ТОЛЬКО В СОСТАВЕ КОМБИНИРОВАННЫХ АЛГОРИТМОВ!"
  view-as alert-box error.
  undo, return no-apply.
end.
MESSAGE
"Вы уверены, что хотите удалить привязку к данному алгоритму?"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN ERROR.
define variable v-ii as integer no-undo .
define variable v-current-uniq-key-rec as character no-undo .
define variable v-current-profile-id as integer no-undo .
define variable v-profile-id-list as character no-undo .
define variable v-call-id-list as character no-undo .
define variable v-once-more-list as character no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
assign
v-call-id-list = p-uniq-key-rec
v-profile-id-list = string(tt0-rp-by-call.profile_id)
v-once-more-list = string(tt0-rp-by-call.once-more)
.
FIND FIRST buf_rule-profile EXCLUSIVE-LOCK WHERE buf_rule-profile.profile_id = tt0-rp-by-call.profile_id.
if buf_rule-profile.profile-type = 'cmb':U then do:
  do v-ii = 1 to num-entries('dis-card-type,goods,clients,gds-grp,cli-grp,chk-doc_IBS-TH,chk-doc_IBS-TH-MOB,edoc,thref,pdf,rep,ord,cmb,fdoc':U):
    v-current-uniq-key-rec = p-uniq-key-rec.
    entry(lookup('cmb':U, p-uniq-key-rec, chr(3)), v-current-uniq-key-rec, chr(3)) = entry(v-ii, 'dis-card-type,goods,clients,gds-grp,cli-grp,chk-doc_IBS-TH,chk-doc_IBS-TH-MOB,edoc,thref,pdf,rep,ord,cmb,fdoc':U).
    for each buf_rp-by-call no-lock where
            buf_rp-by-call.call_id = v-current-uniq-key-rec
        and buf_rp-by-call.parent-profile_id = buf_rule-profile.profile_id
        :
      v-current-profile-id = buf_rp-by-call.profile_id.
      assign
      v-call-id-list = v-call-id-list +  chr(4)  +  v-current-uniq-key-rec
      v-profile-id-list = v-profile-id-list + chr(44) + string(v-current-profile-id)
      v-once-more-list = v-once-more-list +  chr(44)  +  string(buf_rp-by-call.once-more)
      .
    end.
  end.
end.
do v-ii = 1 to num-entries(v-call-id-list, chr(4) ):
  find first tt0-rp-by-call where
            tt0-rp-by-call.call_id = entry(v-ii, v-call-id-list, chr(4) )
        and tt0-rp-by-call.profile_id = integer(entry(v-ii, v-profile-id-list ))
       and tt0-rp-by-call.once-more = integer(entry(v-ii, v-once-more-list )).
  FOR EACH buf_tt0-rule-by-call where
          buf_tt0-rule-by-call.call_id = entry(v-ii, v-call-id-list, chr(4) )
      and   buf_tt0-rule-by-call.profile_id = integer(entry(v-ii, v-profile-id-list))
      and buf_tt0-rule-by-call.once-more = integer(entry(v-ii, v-once-more-list))
  ON error UNDO, RETURN ERROR:
    for each buf_tt0-rule-call-param where
            buf_tt0-rule-call-param.codex_id = buf_tt0-rule-by-call.codex_id
      and buf_tt0-rule-call-param.ruleset_id = buf_tt0-rule-by-call.ruleset_id
      and buf_tt0-rule-call-param.call_id  = buf_tt0-rule-by-call.call_id
      and buf_tt0-rule-call-param.order_id = buf_tt0-rule-by-call.order_id
      ON error UNDO, RETURN ERROR:
      delete buf_tt0-rule-call-param.
    end.
    DELETE buf_tt0-rule-by-call.
  END.
  DELETE tt0-rp-by-call.
end.
OPEN QUERY br-profile FOR EACH tt0-rp-by-call WHERE          tt0-rp-by-call.call_id = p-uniq-key-rec NO-LOCK INDEXED-REPOSITION.
APPLY "VALUE-CHANGED" to br-profile IN FRAME Dialog-Frame.
OPEN QUERY br-rule-by-call FOR EACH tt0-rule-by-call WHERE     tt0-rule-by-call.call_id = p-uniq-key-rec,            FIRST X_rule-profile NO-LOCK WHERE         X_rule-profile.profile_id = tt0-rule-by-call.profile_id   AND (rs-algo-types = 1 or X_rule-profile.is_dynamic = yes)  BY tt0-rule-by-call.codex_id  BY tt0-rule-by-call.ruleset_id  BY tt0-rule-by-call.order_id  INDEXED-REPOSITION.
APPLY "value-changed" TO br-rule-by-call  IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-display-rule :
DEFINE INPUT PARAMETER p-DISPLAY-MODE AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-ruleset-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-order-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
run rul/disprule.p (
                       input p-DISPLAY-MODE
                      ,input p-rule-id
                      ,input p-codex-id
                      ,input p-ruleset-id
                      ,input p-call-id
                      ,input p-order-id
                       ).
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-old-call-id AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-new-call-id AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define variable v-ok as logical no-undo .
define variable choice as integer no-undo .
define variable v-found-new as logical no-undo .
define variable v-logical-value as logical no-undo .
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_tt0-rp-by-call for tt0-rp-by-call.
define buffer buf_rule-profile for ub.rule-profile.
if parobj-code > 0 then do:
  find first buf_tt0-rp-by-call no-error.
  if not available buf_tt0-rp-by-call then do:
    run gbl/d-askw.w (input "Вопрос"
                    ,input  substitute("Вы не определили ни одно профайла&1"+
                          "Предполагается, что должны работать профайлы, определенные в ГЛОБАЛЬНОМ контесте,&1" +
                          "или работа по профайлам ВООБЩЕ не требуется?"
                          , chr(10))
                    ,input "|"
                    ,input "ГЛОБАЛЬНЫЕ ПРОФАЙЛЫ|БЕЗ ПРОФАЙЛОВ|Отменить"
                    ,input "||"
                    ,input 1
                    ,input 3
                    ,output choice).
    if choice = 3
    then do:
        undo, return error ''.
    end.
    if choice = 1 then v-logical-value = no.
    if choice = 2 then v-logical-value = yes.
  end.
  else do:
    v-logical-value = yes.
  end.
end.
else do:
  v-logical-value = yes.
end.
for each buf_rp-by-call where
          buf_rp-by-call.call_id = p-uniq-key-rec,
    first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = buf_rp-by-call.profile_id
      and buf_rule-profile.is_Dynamic = yes
  on ERROR UNDO, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  ON STOP undo, return error '':u:
  find first buf_tt0-rp-by-call where
            buf_tt0-rp-by-call.call_id = buf_rp-by-call.call_id
        and buf_tt0-rp-by-call.profile_id =  buf_rp-by-call.profile_id
        and buf_tt0-rp-by-call.once-more =  buf_rp-by-call.once-more no-error.
  if not available buf_tt0-rp-by-call then do:
     message
     "ВНИМАНИЕ!!!" skip(0)
     "Вы собираетесь удалить профайл(ы)" skip(0)
     "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
     "1. Изменения в работе системы" skip(0)
     "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
     "Это может привести к РАССИНХРОНИЗАЦИИ данных"  skip(0)
     "2. Даже если Вы передумаете и вновь добавите удаленные профайл(ы)," skip(0)
     "данные по изменениям за этот период будут отсутствовать" skip(0)
     "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
     view-as alert-box WARNING buttons yes-no update v-ok.
     if not v-ok then do:
       undo, return .
     end.
  end.
end.
for each tt0-rp-by-call where
          tt0-rp-by-call.call_id = p-uniq-key-rec,
    first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = tt0-rp-by-call.profile_id
      and buf_rule-profile.is_Dynamic = yes
  on ERROR UNDO, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  ON STOP undo, return error '':u:
  find first buf_rp-by-call where
            buf_rp-by-call.call_id = buf_tt0-rp-by-call.call_id
        and buf_rp-by-call.profile_id =  buf_tt0-rp-by-call.profile_id
        and buf_rp-by-call.once-more =  buf_tt0-rp-by-call.once-more no-error.
  if not available buf_rp-by-call then do:
     v-found-new = yes.
     message
     "ВНИМАНИЕ!!!" skip(0)
     "Вы собираетесь добавить профайл(ы)" skip(0)
     "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
     "1. Изменения в работе системы" skip(0)
     "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
     "Это может привести к неполноте данных по некоторым БД и т.д." skip(0)
     "2. Для некоторых профайлов предусмотрено включение/выключение правил профайла в соответствии с их бизнес-логикой," skip(0)
     "несвоевременное включение/выключение любого из этих правил МОЖЕТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
     "3. Неверно выставленные параметры МОГУТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
     "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
     view-as alert-box WARNING buttons yes-no update v-ok.
     if not v-ok then do:
       undo, return .
     end.
  end.
end.
if not v-found-new  then do:
  message
  "ВНИМАНИЕ!!!" skip(0)
  "ПРЕДУПРЕЖДЕНИЕ!!!" skip(0)
  "1. Изменения в работе системы" skip(0)
  "на УБД будут вступать в силу ПОСТЕПЕНЕННО - после получения пакета с данными изменениями по СПН" skip(0)
  "Это может привести к неполноте данных по некоторым БД и т.д." skip(0)
  "2. Для некоторых профайлов предусмотрено включение/выключение правил профайла в соответствии с их бизнес-логикой," skip(0)
  "несвоевременное включение/выключение любого правил из этих МОЖЕТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
  "3. Неверно выставленные параметры МОГУТ ПРИВЕСТИ к непредсказуемой работе алгоритма" skip(0)
  "ПРОДОЛЖИТЬ СОХРАНЕНИЕ              ?"
   view-as alert-box WARNING buttons yes-no update v-ok.
  if not v-ok then do:
    undo, return .
  end.
end.
run rul/thbjrum1.p (
                 input p-mode
                ,input p-profile-type
                ,input p-uniq-key-rec
                ,input 0
                ,input "":U
                ,input 0
                ,input v-logical-value
                ,INPUT TABLE tt0-rp-by-call
                ,INPUT TABLE tt0-rule-by-call
                ,INPUT TABLE tt0-rule-call-param) no-error .
if error-status:error then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if return-value <> '':U then do:
  message
  error-status:get-message(1)
  return-value
  view-as alert-box .
end.
return error.
end.
END PROCEDURE.
PROCEDURE set-row-color :
DEFINE INPUT PARAMETER p-parent-profile-id AS integer NO-UNDO.
if p-parent-profile-id > 0 then do:
  if valid-handle(v-h-name) then
  assign
  v-h-name:BGCOLOR = GRAY_COLOR
    .
end.
else do:
  if valid-handle(v-h-name) then
  assign
  v-h-name:BGCOLOR = ?
    .
end.
END PROCEDURE.
FUNCTION get-profile-documentation RETURNS CHARACTER
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN ''.
RETURN buf_rule-profile.documentation.
END FUNCTION.
FUNCTION get-profile-dynamic RETURNS LOGICAL
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN ?.
RETURN buf_rule-profile.is_dynamic.
END FUNCTION.
FUNCTION get-profile-name RETURNS CHARACTER
  ( p-profile_id AS INTEGER ) :
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
FIND FIRST buf_rule-profile NO-LOCK WHERE
          buf_rule-profile.profile_id = p-profile_id NO-ERROR.
IF NOT AVAILABLE buf_rule-profile THEN RETURN chr(63).
RETURN buf_rule-profile.NAME.
END FUNCTION.
