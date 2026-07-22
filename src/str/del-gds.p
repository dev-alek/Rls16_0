block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: 2014/01/27 14:27:46 $
$Workfile: del-gds.p $
$Archive: str/del-gds.p $

Простое удаление товаров с кассы

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


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: 2014/01/27 14:27:46 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: del-gds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/del-gds.p $":U .
define variable vss-description as character no-undo init "Простое удаление товаров с кассы":U.
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }

&SCOPED-DEFINE called del-gds
define variable i-obj-code like ub.clients.obj-code no-undo.
define variable action as character no-undo init "D".
define variable  ModeType as logical no-undo .
assign
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
modetype = (if num-entries(p-parameter, {&delim-par} ) > 1
            then logical(entry(2, p-parameter, {&delim-par}))
            else no)
no-error
.
if error-status:error then return error.
if modetype <> ? then do:
{ gbl/getcntxt.i get }
end.
{ cmp/gds-list.i gds-list def "new shared" }
{ str/sendgood.i }

procedure cb_set-gds-list :
define input parameter p-bh as handle no-undo .
create gds-list.
buffer gds-list:handle:buffer-copy( p-bh).
release gds-list.

end procedure. /* cb_set-gds-list */
