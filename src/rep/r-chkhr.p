block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-chkhr.p $
$Archive: rep/r-chkhr.p $

Почасовая статистика розничных продаж по КОЛИЧЕСТВУ ПОКУПОК - сбор данных

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/19/05
Author: Bakhtadze Natalya
Creation date: 10/19/05

*/

define input parameter for-h-str as character no-undo .
define input parameter RS-option as integer no-undo .
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-chkhr.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-chkhr.p $":U .
def var vss-description as character no-undo init "Почасовая статистика розничных продаж по КОЛИЧЕСТВУ ПОКУПОК - сбор данных".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/r-page1.i }
{ rep/e-chkhdf.i "SHARED" }
{ gbl/waitfram.i }

define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.

DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE for-h as logical no-undo extent 24.
DEFINE VARIABLE ii-sec as integer no-undo .
DEFINE VARIABLE accum-chk-doc as integer no-undo .
define variable byobject as logical no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define buffer tot_chk-h for chk-h.
define buffer tot_num-h for num-h.


if num-entries(for-h-str) <> 24 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра" for-h-str
  view-as alert-box error .
  return error .
end.


do ii = 1 to 24:
  for-h[ii] = (entry(ii, for-h-str) = "yes").
END.
if rs-option = 2
or rs-option = 3 then do:
  assign
  byobject = yes.
end.

CASE t-dis-card:
  WHEN YES then do:
    CASE rs-dis-card:
      WHEN 0 then do:
        FOR EACH obj-list :
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc:
          for  EACH ub.chk-doc WHERE
            ub.chk-doc.obj-type = obj-list.obj-type AND
            ub.chk-doc.obj-code = obj-list.obj-code AND
            ub.chk-doc.chk-date >= X-date-start AND
            ub.chk-doc.chk-date <= X-date-end AND
            ub.chk-doc.d-card <> "":U NO-LOCK :
            if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
            { rep/r-chkhr.i }
          END.
        END.
      END.
      WHEN 1 then do:
        FOR EACH obj-list :
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc2:
          FOR  EACH ub.chk-doc WHERE
            ub.chk-doc.obj-type = obj-list.obj-type AND
            ub.chk-doc.obj-code = obj-list.obj-code AND
            ub.chk-doc.chk-date >= X-date-start AND
            ub.chk-doc.chk-date <= X-date-end AND
            ub.chk-doc.d-card <> "":U NO-LOCK :
            if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc2.
            FIND FIRST ub.dis-card No-LOCK WHERE
                      ub.dis-card.d-card = ub.chk-doc.d-card no-error .
                      if not available dis-card then next.
            if not can-find(first temp-dis-card-type No-LOCK WHERE
                                  temp-dis-card-type.type = dis-card.type AND
                                  temp-dis-card-type.emitent-host-code = dis-card.emitent-host-code) then next.
            { rep/r-chkhr.i }
          END.
        END.
      END.
    END CASE. /*RS-dis-card*/
  END.
  WHEN NO then do:
    FOR EACH obj-list :
      If byobject then v-obj-code = obj-list.obj-code.
      else v-obj-code = 0.
      _chk-doc3:
      FOR EACH ub.chk-doc WHERE
        ub.chk-doc.obj-type = obj-list.obj-type AND
        ub.chk-doc.obj-code = obj-list.obj-code AND
        ub.chk-doc.chk-date >= X-date-start AND
        ub.chk-doc.chk-date <= X-date-end NO-LOCK :
        if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc3.
        { rep/r-chkhr.i }
      END.
    END.
  END.
END CASE.
run waitfram-hide in this-procedure .