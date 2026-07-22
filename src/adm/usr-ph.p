block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: usr-ph.p $
$Archive: adm/usr-ph.p $

Показать изображение клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/


define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter p-user-id      as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usr-ph.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/usr-ph.p $":U .
define variable vss-description as character no-undo init "Показать изображение клиента".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/ini-lib.i }
{ gbl/getcntxt.i def }

define variable loc#log    as logical   no-undo .
define variable v-can-edit as logical no-undo .

{ gbl/getcntxt.i get }

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_rights_update':U
  {&cntxt-global}
  0
  '':U
  0
  0
  0
  0
  true
  v-can-edit
}

{ ref/viewpict.i usr\ p-user-id v-can-edit }