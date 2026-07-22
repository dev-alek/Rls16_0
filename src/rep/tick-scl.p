block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tick-scl.p $
$Archive: rep/tick-scl.p $

Печать ценников для товаров на весах

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/12/05
Author: Bakhtadze Natalya
Creation date: 09/12/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER bc-rid AS RECID NO-UNDO.
DEFINE INPUT PARAMETER p-db-Num AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER ScaleNum AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER ScaleRid AS CHARacter NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: tick-scl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/tick-scl.p $":U .
define variable vss-description as character no-undo init "Печать ценников для товаров на весах".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i  }

define variable v-user-id as character no-undo .
run get-userid in parparentproc
  ( output v-user-id
  ).

define NEW SHARED STREAM OutStream.

do
on error undo, return error
:

{ rep/new-prn.i new }
define variable Action as char init "SCALES" no-undo.
define variable jj as int no-undo.

define variable how-pcnt-kat as character no-undo .
define variable dflt-cd as character no-undo .
{ str/howpcntk.i p-obj-type p-obj-code how-pcnt-kat dflt-cd no-error }


{ rep/tick-beg.i }

if bc-rid = ? then do:
  if ScaleRid <> "" then  do:
          DO jj = 1 TO NUM-ENTRIES( ScaleRid ):
              FIND ub.scales-gds WHERE recid( ub.scales-gds ) = integer( ENTRY( jj, ScaleRid ) ) NO-LOCK.
              FIND ub.bar-code WHERE ub.bar-code.b-code = ub.scales-gds.b-code NO-LOCK.
              run tick-prn.
          END.
  end.
  else do:
    FOR EACH ub.scales-gds WHERE
              ub.scales-gds.db-num = p-db-Num AND
            ub.scales-gds.scales-num = ScaleNum NO-LOCK:
        FIND ub.bar-code WHERE ub.bar-code.b-code = ub.scales-gds.b-code NO-LOCK.
        run tick-prn.
    END.
  end.
end.
else do:
    FIND ub.bar-code WHERE recid(ub.bar-code) = bc-rid NO-LOCK.
    FIND ub.scales-gds WHERE
          ub.scales-gds.db-num = p-db-Num
    AND  ub.scales-gds.scales-num = ScaleNum
    AND ub.scales-gds.b-code = ub.bar-code.b-code NO-LOCK.
    run tick-prn.
end.

{ rep/tick-end.i }

end. /*doe*/

PROCEDURE tick-prn:
    FIND ub.goods WHERE ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK.
    FIND ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK.
    assign rootnode_code = ub.gds-prt.node-code.
    { rep/ticket.i }
END PROCEDURE.