block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: calladdc.p $
$Archive: str/calladdc.p $

Процедура запуска режимов Список допрасходов

Автор: Чернова Светлана Александровна
Дата создания: 06/18/07
Author: Svetlana Chernova
Creation date: 06/18/07

*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-mode as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: calladdc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/calladdc.p $":U .
define variable vss-description as character no-undo init "Процедура запуска режимов Список допрасходов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable bttns          as character   no-undo .
define variable par-mode       as character   no-undo .
define variable pardoc-rec     as recid no-undo.
define variable par-host-code  like ub.clients.obj-code no-undo.
define variable p-obj-code     like ub.clients.obj-code no-undo.
define variable p-obj-type     like ub.clients.obj-type no-undo.
define variable p-doc-type     as character no-undo .
define variable p-status_      as character no-undo .
define variable p-char         as character no-undo .
define variable rid-list       as character no-undo . /* список recid'ов выбранных */


case p-mode :
  when "1"  then do:
    assign
      par-mode      = "status"
      p-status_     = {&g___new}
      bttns         = "b-add,b-chg,b-del"
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "4"  then do:
    assign
      par-mode      = "status"
      p-status_     = {&add-close}
      bttns         = ""
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "2"  then do:
    assign
      par-mode      = "status"
      p-status_     = {&fact}
      bttns         = ""
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "3"  then do:
    assign
      par-mode      = {&obj}
      p-status_     = {&all}
      bttns         = "b-add,b-chg,b-del"
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "11"  then do:
    assign
      par-mode      = "status-firm"
      p-status_     = {&g___new}
      bttns         = "b-add,b-chg,b-del"
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "14"  then do:
    assign
      par-mode      = "status-firm"
      p-status_     = {&add-close}
      bttns         = ""
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.
  when "12"  then do:
    assign
      par-mode      = "status-firm"
      p-status_     = {&fact}
      bttns         = ""
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.

  when "13"  then do:
    assign
      par-mode      = "firm"
      p-status_     = {&all}
      bttns         = "b-add,b-chg,b-del"
      par-host-code = v-cntxt-host-code-obj
      p-obj-code    = v-cntxt-obj-code
      p-obj-type    = v-cntxt-obj-type
    .
  end.

end case.

run str/add-docs.w (
   input ParParentProc
  ,input bttns
  ,input par-mode
  ,input pardoc-rec
  ,input par-host-code
  ,input p-obj-code
  ,input p-obj-type
  ,input p-doc-type
  ,input p-status_
  ,input p-char
  ,output  rid-list
  ) no-error .
  if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  end.