block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tick-one.p $
$Archive: rep/tick-one.p $

Печать одного ценника по известному бар-коду

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/98
Author: Dmitry Ukhanov
Creation date: 03/22/98

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER bc-rid AS RECID NO-UNDO.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: tick-one.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/tick-one.p $":U .
def var vss-description as character no-undo init "Печать одного ценника по известному бар-коду".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ rep/new-prn.i new }

define variable v-user-id as character no-undo .
run get-userid in parparentproc
  ( output v-user-id
  ).

define variable how-pcnt-kat as character no-undo .
define variable dflt-cd as character no-undo .
{ str/howpcntk.i p-obj-type p-obj-code how-pcnt-kat dflt-cd no-error }

def NEW SHARED STREAM OutStream.
def var Action as char no-undo.

FIND ub.bar-code WHERE recid(ub.bar-code) = bc-rid NO-LOCK.
FIND ub.goods WHERE ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK.
FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
FIND ub.gds-prt WHERE ub.gds-prt.node-code = ub.bar-code.node-code NO-LOCK.

assign Action = "BCODE".

{ rep/tick-beg.i }
{ rep/ticket.i }
{ rep/tick-end.i }