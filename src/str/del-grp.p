block-level on error undo, throw.
/*

$Revision: 8151e940e67c, 2842, rls $
$Author: EShklyar $
$Date: Пн ноя 22 19:49:06 2021 +0300 $
$Workfile: del-grp.p $
$Archive: str/del-grp.p $

Простое удаление товаров с кассы из группы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
def input param i-obj-code like ub.clients.obj-code no-undo.
*/


define variable vss-revision    as character no-undo init "$Revision: 8151e940e67c, 2842, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:06 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-grp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/del-grp.p $":U .
define variable vss-description as character no-undo init "Простое удаление товаров с кассы из группы":U.
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }

&SCOPED-DEFINE called del-grp
define variable i-obj-code like ub.clients.obj-code no-undo.
define variable i-grp-code like ub.gds-grp.node-code no-undo.
define variable action as character no-undo init "D".
define variable  ModeType as logical no-undo .
define variable p-batch as logical no-undo .
assign
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
i-grp-code = integer(entry(2, p-parameter, {&delim-par}))
modetype = (if num-entries(p-parameter, {&delim-par} ) > 2
            then logical(entry(3, p-parameter, {&delim-par}))
            else no)
modetype = (if num-entries(p-parameter, {&delim-par} ) > 2
            then logical(entry(3, p-parameter, {&delim-par}))
            else no)
no-error
.
if error-status:error then return error.


  if (valid-handle(parparentproc) <> true)
  or lookup( "mainmenu_getcntxt", parparentproc:internal-entries ) = 0
  then do:
        assign
        v-cntxt-db-num = g#db-num
        v-cntxt-userid = g#userid
        .
  end.
  else do:
    { gbl/getcntxt.i get }
  end.

{ cmp/gds-list.i gds-list def "new shared" }
{ str/sendgood.i }

procedure cb_set-grp-list :
define input parameter p-bh as handle no-undo .
create gds-list.
buffer gds-list:handle:buffer-copy( p-bh).
release gds-list.

end procedure. /* cb_set-gds-list */