block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sh-contr.p $
$Archive: str/sh-contr.p $

Просмотр карточки договора

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 12/06/04

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sh-contr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sh-contr.p $":U .
define variable vss-description as character no-undo init "Просмотр карточки договора".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }

define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter  ri as recid no-undo .

define variable  p-contract-code as integer   no-undo .
define variable  p-host-code as integer   no-undo .

define new shared buffer   buf_contract for contract.       /* !!!!!!!!!!!! */
define new shared variable br-handle as handle  no-undo .
define new shared variable next-prev as logical no-undo .
define variable g-log as logical   no-undo .

do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:

  { gbl/getcntxt.i get }

  find first buf_contract no-lock
    where recid(buf_contract) = ri
    no-error .
  if error-status :error
  then do:
    return error.
  end.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_fin-contract_lookup':U
    {&cntxt-firm}
    buf_contract.host-code
    '':U
    0
    0
    0
    0
    true
    g-log
  }

  if not g-log then  return .



run str/contr.w
( input   parParentProc ,
  input   buf_contract.host-code   ,
  input  {&lookup}      ,
  input  buf_contract.doc-type ,
  input-output  ri      )
  no-error .
  if error-status :error then return error.

  end .