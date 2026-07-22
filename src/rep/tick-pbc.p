block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tick-pbc.p $
$Archive: rep/tick-pbc.p $

Печать одного ценника по известному бар-коду

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/99
Author: Dmitry Ukhanov
Creation date: 03/22/99

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER prod-bc-rid AS RECID NO-UNDO.
define input parameter p-b-code like ub.bar-code.b-code no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: tick-pbc.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/tick-pbc.p $":U .
def var vss-description as character no-undo init "Печать одного ценника по известному бар-коду".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ rep/new-prn.i new }

define buffer buf_prod-bc for ub.prod-bc.
define NEW SHARED STREAM OutStream.
DEFINE VARIABLE Action as character no-undo.
DEFINE VARIABLE v-bc-type as character no-undo .

define variable v-user-id as character no-undo .
run get-userid in parparentproc
  ( output v-user-id
  ).

find first buf_prod-bc where recid(buf_prod-bc) = prod-bc-rid no-error .
if not available buf_prod-bc or
   buf_prod-bc.b-code <> p-b-code then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра prod-bc-rid" prod-bc-rid skip
  "или параметра p-b-code" p-b-code
  view-as alert-box error .
  return error.
end.

define variable how-pcnt-kat as character no-undo .
define variable dflt-cd as character no-undo .
{ str/howpcntk.i p-obj-type p-obj-code how-pcnt-kat dflt-cd no-error }

FIND ub.bar-code WHERE
     ub.bar-code.b-code = p-b-code NO-LOCK.

FIND ub.goods WHERE
     ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK.

FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
assign rootnode_code = ub.gds-prt.node-code.

FIND ub.gds-prt WHERE ub.gds-prt.node-code = ub.bar-code.node-code NO-LOCK.

assign
Action = "PROD-BC"
v-bc-type = "main":U
v-bc-type = (if ub.bar-code.in-code <> ""
             then "part":U
             else  (if ub.goods.unit-base <> ub.bar-code.unit-cli
                    then "subs"
                    else v-bc-type)
             )
ListProdbc = buf_prod-bc.b-str
.


{ rep/tick-beg.i v-bc-type }
{ rep/ticket.i }
{ rep/tick-end.i }