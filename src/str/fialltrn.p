block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fialltrn.p $
$Archive: str/fialltrn.p $

Список накладных Без фин.обязательств Нет по поставке

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 02/06/04 11:58


*/

define input parameter parparentproc as handle    no-undo .
define input parameter par-type      as integer   no-undo .
define input parameter par-host-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fialltrn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fialltrn.p $":U .
define variable vss-description as character no-undo init "Список накладных Без фин.обязательств Нет по поставке".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }

define variable doc-t as character no-undo.
DEFINE VARIABLE loc-ref-list as character no-undo.
define variable v-input-output as character no-undo .
define variable v-list-mode as character no-undo .
def buffer b#clients for clients.
define variable v-host-name as character no-undo .


do
on error undo, return error return-value
:
  { gbl/getcntxt.i get }

  find first b#clients WHERE
        b#clients.obj-code = par-host-code and
        b#clients.obj-type = {&cmp}
        No-LOCK No-ERROR.

  v-host-name = b#clients.obj-name .

  case par-type :
    when 0 then do:
        v-list-mode = {&company} .
    end.
    when 1 then do:
        v-list-mode = "no-gen-incfo":U .
    end.
    when 2 then do:
        v-list-mode = "no-gen-expfo":u .
    end.
    when 3 then do:
        v-list-mode = "no-gen-fo":u .
    end.
    when 4 then do:
        v-list-mode = "no-def":u .   /* без определенных условий */
    end.

    when 11 then do:
        v-list-mode = "yes-gen-incfo":U .
    end.
    when 12 then do:
        v-list-mode = "yes-gen-expfo":u .
    end.
    when 13 then do:
        v-list-mode = "yes-gen-fo":u .
    end.

  end case.


  /* в перспективе v-list-mode = {&company} должно замениться на что-то другое для fin!!*/
  run str/all-docs.w
      (input parparentproc
      ,input par-host-code
      ,input v-cntxt-obj-type
      ,input v-cntxt-obj-code
      ,input v-list-mode
      ,input ? /*parstat*/
      ,input ? /*partype*/
      ,input ? /*parflag*/
      ,input ? /*parinternal*/
      ,input 'b-mark':U /*bttns*/
      ,input '':U /*parext-doc-type*/
      ,input ? /*paris-hold*/
      ,input (if par-type = 0 then recid(b#clients) else ?)
      ,output loc-ref-list
      ) no-error .
end.