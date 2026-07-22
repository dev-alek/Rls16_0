block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trn-vat.p $
$Archive: utl/trn-vat.p $

Изменение ПН закрытой по факту

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

*/

define input parameter parparentproc as handle no-undo.
define input parameter p-mode        as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trn-vat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trn-vat.p $":U .
define variable vss-description as character no-undo init "Изменение ПН закрытой по факту".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }


do
on error undo, return error return-value
:
  define variable v-ok as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_income_update-closed':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    v-ok
  }
  if v-ok <> true
  then do:
    undo, return error return-value .
  end.

define variable loc-ref-list as character no-undo .
run str/all-docs.w
   (  input parparentproc ,
      input v-cntxt-host-code-obj ,
      input v-cntxt-obj-type ,
      input v-cntxt-obj-code ,
      input {&status} ,
      input {&fact}   ,
      input {&income} ,
      input ?  ,
      input no ,
      input "b-sel":u ,
      input {&TDEDT_Pri_Vnesh} ,
      input ( if p-mode = 'hold' then yes else no ) ,
      input ?  ,
      output loc-ref-list
      ).
if num-entries (loc-ref-list) <> 1 then do:
  message "Не выбрана ПН для пересчета" view-as alert-box information  .
  return .
end.

find first ub.trn-doc no-lock where recid(ub.trn-doc) = integer(loc-ref-list) no-error .
if error-status :error then do:
  message "Не найдена ПН для пересчета" view-as alert-box information  .
  return .
end.

define buffer buf_clients for ub.clients  .

find first buf_clients no-lock where
           buf_clients.obj-type = ub.trn-doc.obj-type and
           buf_clients.obj-code = ub.trn-doc.obj-code .

if buf_clients.db-num <> v-cntxt-db-num then do:
   message "Исправлять документ можно только на активной стороне БД №" buf_clients.db-num view-as alert-box information  .
   return .
end.

run utl/upart-ie.w ( input parparentproc , input integer(loc-ref-list) ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "utl/upart-ie.p"
      view-as alert-box error
    .
end.
