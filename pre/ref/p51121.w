DEFINE BUFFER X_condition-keeping FOR condition-keeping.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type LIKE ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code LIKE ub.clients.obj-code no-undo .
define input parameter mode as char no-undo .
define input parameter goodsname as char no-undo .
define input parameter prodname as char no-undo .
define input parameter prodaddress as char no-undo .
define input parameter goods-unit-base like ub.goods.unit-base.
define input-output parameter destin_ like ub.goods.destin no-undo .
define input-output parameter attrib_ like ub.goods.attrib no-undo .
define input-output parameter user-rule_ like ub.goods.user-rule no-undo .
define input-output parameter sert_ like ub.goods.sert no-undo .
define input-output parameter struct_ like ub.goods.struct no-undo .
define input-output parameter deadline_ like ub.goods.deadline no-undo .
define input-output parameter sort_ like ub.goods.sort no-undo .
define input-output parameter tnved_ like ub.goods.tnved format "x(10)" no-undo .
define input-output parameter unit-cst_ like ub.goods.unit-cst no-undo .
define input-output parameter cst-base-rate_ like ub.goods.cst-base-rate no-undo .
define input-output parameter nationality_ like ub.goods.nationality no-undo .
define input-output parameter normal-wastage_ like ub.goods.normal-wastage no-undo .
define input-output parameter normal-waste_ like ub.goods.normal-waste no-undo .
define input-output parameter cond-keep-code_ like ub.goods.cond-keep-code no-undo .
define input-output parameter proof_ like ub.goods.proof no-undo .
define input-output parameter is-alc_ as logical no-undo .
define input-output parameter is-alc-mark_ as logical no-undo .
define input-output parameter alc-type-inner-code as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка товара - дополнительная информация".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE  SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable rid-tnved as recid no-undo.
define variable custvalue      as char initial ? no-undo.
define variable custtype       as char initial ? no-undo.
define variable alcvalue      as char initial ? no-undo.
define variable alctype       as char initial ? no-undo.
DEFINE VARIABLE old-frame-height AS DECIMAL NO-UNDO.
DEFINE VARIABLE old-rect-height AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-expand AS logical NO-UNDO.
DEFINE VARIABLE v-downed AS character NO-UNDO.
DEFINE VARIABLE sh AS WIDGET-HANDLE NO-UNDO EXTENT 15.
DEFINE VARIABLE v-question-mode AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-start-scales-type AS CHARACTER NO-UNDO.
define variable v-tab-order as character no-undo .
DEFINE BUFFER buf_units FOR ub.units.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "Ввод":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-choose-alc-prod
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83.
DEFINE BUTTON r-cnd-keep
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .83.
DEFINE BUTTON r-cst
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cst"
     SIZE 3 BY .83.
DEFINE BUTTON r-tnved
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-tnved"
     SIZE 3 BY .83.
DEFINE VARIABLE NATIONALITY AS CHARACTER FORMAT "X(20)":U
     LABEL "Статус товара (национальность)"
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEMS "Российский","Иностранный"
     DROP-DOWN-LIST
     SIZE 37.25 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Struct AS CHARACTER
     VIEW-AS EDITOR MAX-CHARS 1000 SCROLLBAR-VERTICAL
     SIZE 85 BY 3.46 NO-UNDO.
DEFINE VARIABLE Attrib AS CHARACTER FORMAT "X(100)":U
     LABEL "Характеристики"
     VIEW-AS FILL-IN
     SIZE 55 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE choose-alc-prod AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Выбор вида алкогольной продукции"
     VIEW-AS FILL-IN
     SIZE 10 BY .79
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE choose-alc-prod-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 44.5 BY .67 NO-UNDO.
DEFINE VARIABLE cond-keep-code AS INTEGER FORMAT ">>9":U INITIAL 0
     LABEL "Код усл. хран."
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 15  NO-UNDO.
DEFINE VARIABLE cond-keep-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 44.5 BY .67 NO-UNDO.
DEFINE VARIABLE CST-BASE-RATE AS DECIMAL FORMAT ">>,>>9.9999999999":U INITIAL 0
     LABEL "Коэффициент"
     VIEW-AS FILL-IN
     SIZE 13.75 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE DeadLine AS INTEGER FORMAT ">>>>>>>9":U INITIAL 0
     LABEL "Срок хранения"
     VIEW-AS FILL-IN
     SIZE 9.75 BY .92
     BGCOLOR 12 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Destin AS CHARACTER FORMAT "X(100)":U
     LABEL "Назначение"
     VIEW-AS FILL-IN
     SIZE 57.63 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE G-Name AS CHARACTER FORMAT "X(100)":U
     LABEL "Название товара"
     VIEW-AS FILL-IN
     SIZE 53 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE g-unit-base AS CHARACTER FORMAT "X(3)":U
     LABEL "Учет.ед.изм"
     VIEW-AS FILL-IN
     SIZE 4.75 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE l-struct AS CHARACTER FORMAT "X(256)":U INITIAL "Состав"
      VIEW-AS TEXT
     SIZE 10 BY .67 NO-UNDO.
DEFINE VARIABLE normal-wastage AS DECIMAL FORMAT "->9.99%":U INITIAL 0
     LABEL "Норма ест. убыли"
     VIEW-AS FILL-IN
     SIZE 7.88 BY 1 NO-UNDO.
DEFINE VARIABLE normal-waste AS DECIMAL FORMAT "->9.99%":U INITIAL 0
     LABEL "Норма отходов"
     VIEW-AS FILL-IN
     SIZE 7.88 BY 1 NO-UNDO.
DEFINE VARIABLE P-Address AS CHARACTER FORMAT "X(100)":U
     LABEL "Адрес произв-ля"
     VIEW-AS FILL-IN
     SIZE 53 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE P-Name AS CHARACTER FORMAT "X(100)":U
     LABEL "Прозводитель"
     VIEW-AS FILL-IN
     SIZE 53 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE proof AS DECIMAL FORMAT ">9.99%":U INITIAL 0
     LABEL "Алкоголь"
     VIEW-AS FILL-IN
     SIZE 7.5 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Sert AS CHARACTER FORMAT "X(100)":U
     LABEL "Сертификат"
     VIEW-AS FILL-IN
     SIZE 56.5 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE Sort AS CHARACTER FORMAT "X(30)":U
     LABEL "Сорт/проба"
     VIEW-AS FILL-IN
     SIZE 10.25 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE struct-length AS INTEGER FORMAT ">,>>9":U INITIAL 0
     LABEL "Символов"
      VIEW-AS TEXT
     SIZE 6.5 BY .67
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE TNVED AS CHARACTER FORMAT "x(10)"
     LABEL "Код ТНВЭД"
     VIEW-AS FILL-IN
     SIZE 11.88 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE tnved-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 42.63 BY 1 NO-UNDO.
DEFINE VARIABLE UNIT-CST AS CHARACTER FORMAT "X(3)":U
     LABEL "Тамож.ед.изм"
     VIEW-AS FILL-IN
     SIZE 6.25 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE VARIABLE UserRule AS CHARACTER FORMAT "X(100)":U
     LABEL "Правила экпл-ции"
     VIEW-AS FILL-IN
     SIZE 53.25 BY 1
     BGCOLOR 15 FGCOLOR 0  NO-UNDO.
DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY 3.5
     BGCOLOR 8 FGCOLOR 0 .
DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY 4.83
     BGCOLOR 0 FGCOLOR 0 .
DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY 4.17.
DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97.5 BY 12.46
     BGCOLOR 0 FGCOLOR 0 .
DEFINE VARIABLE is-alc AS LOGICAL INITIAL no
     LABEL "Алкогольная продукция"
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .83 NO-UNDO.
DEFINE VARIABLE is-alc-mark AS LOGICAL INITIAL no
     LABEL "требует маркировки"
     VIEW-AS TOGGLE-BOX
     SIZE 36 BY .83 NO-UNDO.
DEFINE FRAME DLGOKCAN
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 95
     G-Name AT ROW 2.46 COL 20 COLON-ALIGNED
     P-Name AT ROW 3.5 COL 20 COLON-ALIGNED
     P-Address AT ROW 4.5 COL 20 COLON-ALIGNED
     TNVED AT ROW 6.5 COL 14.5 COLON-ALIGNED
     tnved-name AT ROW 6.54 COL 31.75 COLON-ALIGNED NO-LABEL
     r-tnved AT ROW 6.63 COL 28.63
     UNIT-CST AT ROW 7.92 COL 17.25 COLON-ALIGNED
     CST-BASE-RATE AT ROW 7.96 COL 42.88 COLON-ALIGNED
     g-unit-base AT ROW 7.96 COL 70.38 COLON-ALIGNED
     r-cst AT ROW 8.04 COL 28.63
     NATIONALITY AT ROW 9.5 COL 36.5 COLON-ALIGNED
     Destin AT ROW 11.42 COL 15.38 COLON-ALIGNED
     Attrib AT ROW 12.67 COL 18 COLON-ALIGNED
     UserRule AT ROW 13.92 COL 19.75 COLON-ALIGNED
     Sert AT ROW 15.17 COL 16.5 COLON-ALIGNED
     Struct AT ROW 16.46 COL 13 NO-LABEL WIDGET-ID 2
     DeadLine AT ROW 19.92 COL 39 COLON-ALIGNED
     Sort AT ROW 19.92 COL 63.38 COLON-ALIGNED
     normal-wastage AT ROW 21.13 COL 22.88 COLON-ALIGNED
     normal-waste AT ROW 21.13 COL 50.13 COLON-ALIGNED
     cond-keep-code AT ROW 22.25 COL 19 COLON-ALIGNED
     r-cnd-keep AT ROW 22.25 COL 27
     proof AT ROW 24.71 COL 87.5 COLON-ALIGNED WIDGET-ID 6
     is-alc AT ROW 24.83 COL 6 WIDGET-ID 12
     is-alc-mark AT ROW 24.83 COL 42.5 WIDGET-ID 16
     r-choose-alc-prod AT ROW 26.08 COL 46.38
     choose-alc-prod AT ROW 26.17 COL 34 COLON-ALIGNED
     struct-length AT ROW 15.42 COL 90 COLON-ALIGNED WIDGET-ID 8
     l-struct AT ROW 16.5 COL 2.5 NO-LABEL WIDGET-ID 4
     cond-keep-name AT ROW 22.25 COL 30 COLON-ALIGNED NO-LABEL
     choose-alc-prod-name AT ROW 26.25 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     "(Комплектность)" VIEW-AS TEXT
          SIZE 11 BY 1 AT ROW 17.5 COL 2
          FONT 4
     "Атрибуты алкогольной продукции" VIEW-AS TEXT
          SIZE 30.75 BY .71 AT ROW 23.54 COL 27 WIDGET-ID 12
     "Таможенные характеристики" VIEW-AS TEXT
          SIZE 25.75 BY .71 AT ROW 5.79 COL 27
          BGCOLOR 3 FGCOLOR 14
     "Таможенные характеристики" VIEW-AS TEXT
          SIZE 25.75 BY .71 AT ROW 5.79 COL 27 WIDGET-ID 12
          BGCOLOR 3 FGCOLOR 14
     RECT-10 AT ROW 2.21 COL 1.5
     RECT-11 AT ROW 6 COL 1.5
     RECT-9 AT ROW 11 COL 1.5
     RECT-12 AT ROW 23.83 COL 1.5 WIDGET-ID 10
     SPACE(0.12) SKIP(0.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 1 "Доп.инфо по карточке товара":L
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.
ASSIGN
       proof:HIDDEN IN FRAME DLGOKCAN           = TRUE.
ASSIGN
       Struct:RETURN-INSERTED IN FRAME DLGOKCAN  = TRUE.
ON CHOOSE OF b-exit IN FRAME DLGOKCAN
DO:
define variable loc#log as log no-undo .
    if mode <> 'ПРОСМОТР':U THEN do:
  ASSIGN
  Struct_ = Struct:screen-value
  .
  if is-alc = true and (choose-alc-prod-name = ? or choose-alc-prod-name = "") then do:
     message
     "Не выбран вид алкогольной продукции"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY.
  end.
assign
Destin    Attrib    UserRule    Sert           DeadLine    Sort    Proof
TNVED UNIT-CST CST-BASE-RATE NATIONALITY normal-wastage normal-waste cond-keep-code.
  if is-alc = true and proof = 0 then do:
     message
     "Не указан % содержания алкоголя"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY.
  end.
assign
  destin_ = Destin
  attrib_ = Attrib
  user-rule_ = UserRule
  sert_ = Sert
  deadline_ = DeadLine
  sort_ = Sort
  proof_ = Proof
  tnved_ = TNVED
  unit-cst_ = UNIT-CST
  cst-base-rate_ = CST-BASE-RATE
  nationality_ = NATIONALITY
  normal-waste_ = normal-waste
  cond-keep-code_ = cond-keep-code
  is-alc_ = is-alc
  is-alc-mark_ = is-alc-mark
  .
  if normal-wastage <> normal-wastage_ then do:
    assign
    normal-wastage_ = normal-wastage
    .
  end.
end.
else
    return "отказ" .
END.
ON CHOOSE OF b-quit IN FRAME DLGOKCAN
DO:
    return "отказ" .
END.
ON LEAVE OF choose-alc-prod IN FRAME DLGOKCAN
DO:
  FIND FIRST ub.alc-type WHERE ub.alc-type.alc-type-code = choose-alc-prod:SCREEN-VALUE NO-LOCK NO-error.
    if not available ub.alc-type then do:
            ASSIGN
                choose-alc-prod = ?
                choose-alc-prod:SCREEN-VALUE = ?.
    end.
    else do:
        DISPLAY ub.alc-type.alc-type-code @ choose-alc-prod with frame DLGOKCAN.
        DISPLAY ub.alc-type.alc-type-name @ choose-alc-prod-name with frame DLGOKCAN.
    end.
         assign
         choose-alc-prod
         choose-alc-prod-name
         alc-type-inner-code = ub.alc-type.alc-type-inner-code
         .
end.
ON LEAVE OF cond-keep-code IN FRAME DLGOKCAN
DO:
    RUN proc-leave-cond-keep-code IN THIS-PROCEDURE (INPUT LASTKEY) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON RETURN OF CST-BASE-RATE IN FRAME DLGOKCAN
DO:
    RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF is-alc IN FRAME DLGOKCAN
DO:
  IF is-alc:checked and alcvalue = "yes" then do:
  if mode <> 'ПРОСМОТР':U and alcvalue = "yes" then
  enable is-alc-mark
         choose-alc-prod
         r-choose-alc-prod
         proof
         choose-alc-prod-name
         with frame DLGOKCAN
  .
  else
  display choose-alc-prod
          r-choose-alc-prod
          is-alc-mark
          proof
          choose-alc-prod-name
          with frame DLGOKCAN
          .
  end.
  else hide
         choose-alc-prod
         r-choose-alc-prod
         is-alc-mark
         proof
         choose-alc-prod-name
         in frame DLGOKCAN
  .
  assign is-alc.
END.
ON VALUE-CHANGED OF is-alc-mark IN FRAME DLGOKCAN
DO:
  assign is-alc-mark.
END.
ON ENTRY OF normal-wastage IN FRAME DLGOKCAN
DO:
  assign
  normal-wastage:private-data = normal-wastage:screen-value.
END.
ON CHOOSE OF r-choose-alc-prod IN FRAME DLGOKCAN
DO:
  run ch-choose-alc-prod in this-procedure .
END.
ON CHOOSE OF r-cnd-keep IN FRAME DLGOKCAN
do:
  RUN proc-b-cond-keep-code IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
end.
ON CHOOSE OF r-cst IN FRAME DLGOKCAN
do:
    run ch-units in this-procedure .
    apply "entry" to UNIT-CST in frame DLGOKCAN.
end.
ON CHOOSE OF r-tnved IN FRAME DLGOKCAN
DO:
  run ch-tnved in this-procedure .
END.
ON VALUE-CHANGED OF Struct IN FRAME DLGOKCAN
DO:
   ASSIGN
  STRUCT-LENGTH = STRUCT:LENGTH.
  DISPLAY STRUCT-LENGTH
  WITH FRAME DLGOKCAN.
END.
ON ANY-PRINTABLE OF struct-length IN FRAME DLGOKCAN
DO:
  ASSIGN
  struct-length = struct:LENGTH.
  DISPLAY
  struct-length
  WITH FRAME DLGOKCAN.
END.
ON RETURN OF TNVED IN FRAME DLGOKCAN
DO:
  FIND FIRST TT-tnved WHERE TT-tnved.tnved = input frame DLGOKCAN tnved no-error.
  if not available TT-tnved then do:
    message "Код ТНВЭД не найден в справочнике." view-as alert-box error.
    display ? @ tnved with frame DLGOKCAN.
    run ch-tnved in this-procedure .
    return no-apply.
  end.
  else
  if length(trim(input frame DLGOKCAN tnved)) <> 10 then do:
     message "Код ТНВЭД привязки к товару должен быть 10-ти символьный." view-as alert-box error.
     display ? @ tnved with frame DLGOKCAN.
     run ch-tnved in this-procedure .
     return no-apply.
   end.
  else
  display TT-tnved.f-name @ tnved-name with frame DLGOKCAN.
END.
ON RETURN OF UNIT-CST IN FRAME DLGOKCAN
DO:
    if not can-FIND( ub.units where ub.units.unit-name = input frame DLGOKCAN UNIT-CST )
       then do:
       UNIT-CST = "?".
       DISPLAY UNIT-CST WITH FRAME DLGOKCAN.
       run ch-units in this-procedure .
    end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DLGOKCAN:PARENT eq ?
THEN FRAME DLGOKCAN:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DLGOKCAN
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
on choose of b-help in frame DLGOKCAN
do:
  apply "help":u to frame DLGOKCAN .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DLGOKCAN:width - 0.3
                fh            = frame DLGOKCAN:first-child
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame DLGOKCAN:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame DLGOKCAN:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame DLGOKCAN.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame DLGOKCAN:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame DLGOKCAN:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
ON WINDOW-CLOSE OF FRAME DLGOKCAN APPLY "END-ERROR":U TO SELF.
assign
G-Name = goodsname
P-Name = prodname
P-Address = prodaddress
g-unit-base = (IF goods-unit-base = "" THEN "?" ELSE goods-unit-base)
Destin = destin_
Attrib = attrib_
UserRule = user-rule_
Sert = sert_
Struct:SCREEN-VALUE = struct_
TNVED = tnved_
DeadLine = deadline_
Sort = sort_
Proof = Proof_
UNIT-CST = unit-cst_
CST-BASE-RATE = cst-base-rate_
NATIONALITY = nationality_
normal-wastage = normal-wastage_
normal-waste = normal-waste_
cond-keep-code = cond-keep-code_
is-alc = is-alc_
is-alc-mark = is-alc-mark_
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    RUN enable_UI in this-procedure .
    if mode = 'ПРОСМОТР':U then do:
      HIDE
      b-quit in frame DLGOKCAN .
      b-exit:label = "Выход " .
    end.
    WAIT-FOR GO OF FRAME DLGOKCAN.
END.
RUN disable_UI.
PROCEDURE ch-choose-alc-prod :
define variable v-rec as char no-undo .
define variable v-ok  as logical no-undo .
run ref/alc-type.w (
          input parparentproc
          , input 'b-sel':U
          , input-output v-rec
          , output v-ok ).
if v-rec = ? then  do:
  apply "entry" to r-choose-alc-prod in frame DLGOKCAN.
  return error.
end.
FIND ub.alc-type WHERE recid (alc-type) = int(v-rec) no-error.
if available ub.alc-type then do:
    DISPLAY ub.alc-type.alc-type-code @ choose-alc-prod with frame DLGOKCAN.
    DISPLAY ub.alc-type.alc-type-name @ choose-alc-prod-name with frame DLGOKCAN.
    assign
        choose-alc-prod
        choose-alc-prod-name
        alc-type-inner-code = ub.alc-type.alc-type-inner-code
    .
end.
END PROCEDURE.
PROCEDURE ch-tnved :
run ref/t-tnved.w (yes, output rid-tnved).
find first tt-tnved where RECID(tt-tnved) = rid-tnved no-lock no-error.
if available tt-tnved then disp tt-tnved.tnved @ tnved
                                tt-tnved.f-name @ tnved-name with frame DLGOKCAN.
END PROCEDURE.
PROCEDURE ch-units :
define variable v-rec as recid no-undo .
run ref/units.w (
            input parparentproc
          , input yes
          , output v-rec ).
if v-rec = ? then  do:
  apply "entry" to r-cst in frame DLGOKCAN.
  return error.
end.
FIND ub.units WHERE recid (ub.units) = v-rec NO-LOCK.
DISPLAY ub.units.unit-name @ UNIT-CST with frame DLGOKCAN.
if input frame DLGOKCAN UNIT-CST = g-unit-base then  do:
  DISPLAY 1 @ CST-BASE-RATE with frame DLGOKCAN.
  DISABLE CST-BASE-RATE with frame DLGOKCAN.
end.
else do:
  ENABLE CST-BASE-RATE with frame DLGOKCAN.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME DLGOKCAN.
END PROCEDURE.
PROCEDURE enable_UI :
define variable v-scales-type as character no-undo .
define variable v-ii as integer no-undo .
v-tab-order = 'b-ezit,b-quit,b-help,g-name,p-name,p-address,tnved,r-tnved,tnved-name,unit-cst,' +
               'r-cst,cst-base-rate,nationality,destin,attrib,userrule,sert,struct,' +
               'deadline,sort,is-alc,proof,is-alc-mark,choose-alc-prod,normal-wastage,normal-waste,cond-keep-code,r-cnd-keep'.
IF goods-unit-base <> '':U THEN DO:
  FIND FIRST buf_units NO-LOCK WHERE
            buf_units.unit-name = goods-unit-base NO-ERROR.
END.
ASSIGN
struct = struct_
.
DISPLAY
TNVED UNIT-CST CST-BASE-RATE r-cst g-unit-base
Destin Attrib UserRule Sert l-struct Struct  DeadLine Sort Proof
UNIT-CST CST-BASE-RATE TNVED
G-Name P-Name P-Address NATIONALITY normal-wastage normal-waste cond-keep-code is-alc is-alc-mark choose-alc-prod
WITH FRAME DLGOKCAN .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-custm'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output custvalue
  ,output custtype
  ) no-error .
if custvalue = "yes" and
 can-find(first tt-tnved where tt-tnved.tnved = input frame dlgokcan tnved no-lock) then do:
 find first tt-tnved where tt-tnved.tnved = input frame dlgokcan tnved no-lock.
 display tt-tnved.f-name @ tnved-name with frame dlgokcan.
end.
IF cond-keep-code <> 0
AND cond-keep-code <> ?
THEN DO:
  FIND FIRST X_condition-keeping NO-LOCK WHERE
            X_condition-keeping.cond-keep-code = cond-keep-code NO-ERROR.
  IF AVAILABLE X_condition-keeping THEN DO:
      ASSIGN
      cond-keep-name = X_condition-keeping.cond-keep-name
      .
      DISPLAY
      cond-keep-name
      WITH FRAME DLGOKCAN.
  END.
END.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output alcvalue
  ,output alctype
  ) no-error .
if alcvalue = "yes" then do:
  display is-alc with frame DLGOKCAN.
end.
if choose-alc-prod >= 0 and choose-alc-prod <> ? then do:
  find first ub.alc-type no-lock where ub.alc-type.alc-type-inner-code = alc-type-inner-code no-error.
  if available ub.alc-type then do:
    assign
        choose-alc-prod = integer(ub.alc-type.alc-type-code)
        choose-alc-prod-name = ub.alc-type.alc-type-name
        .
    DISPLAY
    choose-alc-prod
    choose-alc-prod-name with frame DLGOKCAN.
  end.
end.
ENABLE
TNVED when mode <> 'ПРОСМОТР':U and custvalue = "yes"
CST-BASE-RATE when mode <> 'ПРОСМОТР':U and custvalue = "yes"
UNIT-CST when mode <> 'ПРОСМОТР':U and custvalue = "yes"
r-cst when mode <> 'ПРОСМОТР':U and custvalue = "yes"
r-tnved when mode <> 'ПРОСМОТР':U and custvalue = "yes"
Destin when mode <> 'ПРОСМОТР':U
Attrib when mode <> 'ПРОСМОТР':U
UserRule when mode <> 'ПРОСМОТР':U
Sert when mode <> 'ПРОСМОТР':U
Struct
r-cnd-keep when mode <> 'ПРОСМОТР':U
cond-keep-code WHEN mode <> 'ПРОСМОТР':U
is-alc WHEN mode <> 'ПРОСМОТР':U and alcvalue = "yes"
is-alc-mark WHEN mode <> 'ПРОСМОТР':U and alcvalue = "yes"
choose-alc-prod when mode <> 'ПРОСМОТР':U and alcvalue = "yes"
DeadLine when mode <> 'ПРОСМОТР':U
Sort when mode <> 'ПРОСМОТР':U
Proof when mode <> 'ПРОСМОТР':U
Nationality when mode <> 'ПРОСМОТР':U  and custvalue = "yes"
normal-wastage when mode <> 'ПРОСМОТР':U
normal-waste when mode <> 'ПРОСМОТР':U
b-help b-exit b-quit
WITH FRAME DLGOKCAN .
apply "VALUE-CHANGED":U to is-alc.
IF mode = 'ПРОСМОТР':U THEN DO:
  struct:READ-ONLY IN FRAME DLGOKCAN = YES.
END.
APPLY "VALUE-CHANGED" TO STRUCT.
END PROCEDURE.
PROCEDURE proc-b-cond-keep-code :
define variable v-rid-list as character no-undo.
define variable v-sts as integer no-undo.
define variable v-cond-keep-code like ub.condition-keeping.cond-keep-code no-undo.
DEFINE BUFFER buf_condition-keeping FOR ub.condition-keeping.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
assign
v-cond-keep-code = FRAME DLGOKCAN cond-keep-code
cond-keep-code
v-sts = INTEGER('0':U)
    .
IF available X_condition-keeping THEN v-rid-list = string(RECID(X_condition-keeping)) .
run ref/cndkeeps.w (
                INPUT parParentProc
               ,input p-curr-obj-type
               ,input p-curr-obj-code
               ,input "b-sel":U
               ,input 'все':U
               ,input-output v-sts
               ,input-output v-rid-list).
    if v-rid-list <> "":U then do:
        FIND FIRST buf_condition-keeping WHERE
             recid( buf_condition-keeping ) = integer(v-rid-list) NO-LOCK .
        FIND FIRST X_condition-keeping WHERE
        RECID(X_condition-keeping) = RECID(buf_condition-keeping).
        assign
        cond-keep-code = buf_condition-keeping.cond-keep-code
        cond-keep-name = buf_condition-keeping.cond-keep-name
               .
        DISPLAY
        cond-keep-code
        cond-keep-name
        with frame DLGOKCAN .
        RETURN.
    end.
    IF v-cond-keep-code = ? THEN DO:
       ASSIGN
       cond-keep-code = v-cond-keep-code
       cond-keep-name = "":U
       .
       RELEASE X_condition-keeping.
       DISPLAY
       cond-keep-code
       cond-keep-name
       with frame DLGOKCAN .
    END.
END PROCEDURE.
PROCEDURE proc-leave-cond-keep-code :
DEFINE INPUT PARAMETER p-lastkey AS integer NO-UNDO.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-cond-keep-code like ub.condition-keeping.cond-keep-code no-undo.
DEFINE BUFFER buf_condition-keeping FOR ub.condition-keeping.
ASSIGN
v-cond-keep-code = FRAME DLGOKCAN cond-keep-code
cond-keep-code.
FIND FIRST buf_condition-keeping WHERE
 buf_condition-keeping.cond-keep-code = cond-keep-code NO-LOCK NO-error.
if not available buf_condition-keeping then do:
    IF v-cond-keep-code <> ? THEN DO:
        MESSAGE
        "Нет условий хранения с кодом" cond-keep-code
        VIEW-AS ALERT-BOX ERROR.
        IF LASTKEY = KEYCODE("return") THEN DO:
            RUN proc-b-cond-keep-code IN THIS-PROCEDURE NO-error.
            RETURN NO-APPLY.
        END.
        ELSE DO:
            assign
            cond-keep-code = v-cond-keep-code.
        END.
    END.
    ELSE DO:
      IF p-LASTKEY = KEYCODE("return") THEN DO:
            MESSAGE
         "Нет условий хранения с кодом" cond-keep-code
         VIEW-AS ALERT-BOX ERROR.
      END.
    END.
    ASSIGN
    cond-keep-code = ?
    cond-keep-name = "":U
    .
    display
    cond-keep-code
    cond-keep-name
    with frame DLGOKCAN.
    IF p-LASTKEY = KEYCODE("return") THEN DO:
      RUN proc-b-cond-keep-code IN THIS-PROCEDURE NO-error.
      IF ERROR-STATUS:ERROR THEN RETURN error.
    END.
end.
else do:
  FIND FIRST X_condition-keeping NO-LOCK WHERE
            recid(X_condition-keeping) = RECID(buf_condition-keeping).
  assign
  cond-keep-name = buf_condition-keeping.cond-keep-name
  .
    display
    cond-keep-name
    cond-keep-code
    with frame DLGOKCAN.
    .
END.
END PROCEDURE.
