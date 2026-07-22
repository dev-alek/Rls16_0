block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-svhr.p $
$Archive: rep/r-svhr.p $

Почасовая статистика розничных продаж по ВЕЛИЧИНЕ СУММ ПРОДАЖ - сбор данных

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/19/05
Author: Bakhtadze Natalya
Creation date: 10/19/05

*/


define input parameter RS-option as character no-undo .
define input parameter byobject as logical no-undo .
define input parameter RETS as logical no-undo .
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .


def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-svhr.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-svhr.p $":U .
def var vss-description as character no-undo init "Почасовая статистика розничных продаж по ВЕЛИЧИНЕ СУММ ПРОДАЖ - сбор данных".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }
{ rep/e-svhrdf.i "SHARED" }
{ gbl/waitfram.i }


DEFINE VARIABLE ii-sec as integer no-undo .
DEFINE VARIABLE  for-sum like ub.chk-doc.netto no-undo .
DEFINE VARIABLE  rest like ub.chk-gds.doc-qnty no-undo .
DEFINE VARIABLE accum-chk-gds as integer no-undo .
DEFINE VARIABLE accum-chk-doc as integer no-undo .
DEFINE VARIABLE accum-chk-pay as integer no-undo .

define buffer for-gds for ub.chk-gds.
define buffer for-pay for ub.chk-pay.
define buffer for-sum-vals for sum-vals.

DEFINE VARIABLE found-similar as logical no-undo .
define variable v-curr-r-b as character no-undo .

DEFINE SHARED temp-table cancells no-undo
field rd as recid
field doc-qnty like ub.chk-gds.doc-qnty
INDEX pi IS PRIMARY rd ASCENDING.
define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.

do
on error undo, return error
:

  { gbl/curr-r-b.i
    v-curr-r-b
  }

  CASE RS-option:
    when "LINE":U then do:
      run process-chk-gds in this-procedure no-error .
    END.
    when "CHECK":U then do:
      run process-chk-doc in this-procedure no-error .
    END.
    when "PAY":U then do:
      run process-chk-pay in this-procedure no-error .
    END.
  END CASE.

end.

procedure process-chk-doc :
define variable v-obj-code like ub.clients.obj-code no-undo .
define buffer tot_grp-h for grp-h.


  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ("Ждите ..." ).
    CASE t-dis-card:
      WHEN NO then do:
        FOR EACH obj-list :
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc:
          FOR EACH ub.chk-doc WHERE
              ub.chk-doc.obj-type = obj-list.obj-type AND
              ub.chk-doc.obj-code = obj-list.obj-code AND
              ub.chk-doc.chk-date >= X-date-start AND
              ub.chk-doc.chk-date <= X-date-end NO-LOCK
          USE-INDEX obj-date :
          if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
          { rep/r-svhr2.i }
          END.
        end.
      END.
      when YES then do:
        FOR EACH obj-list :
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc2:
          FOR EACH ub.chk-doc WHERE
              ub.chk-doc.obj-type = obj-list.obj-type AND
              ub.chk-doc.obj-code = obj-list.obj-code AND
              ub.chk-doc.chk-date >= X-date-start AND
              ub.chk-doc.chk-date <= X-date-end AND
              ub.chk-doc.d-card <> "":U NO-LOCK :
            if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc2.
            if rs-dis-card = 1 then do:
              FIND FIRST ub.dis-card No-LOCK WHERE
                ub.dis-card.d-card = ub.chk-doc.d-card no-error .
                if not available ub.dis-card then next.
                if not can-find(first temp-dis-card-type No-LOCK WHERE
                                      temp-dis-card-type.type = ub.dis-card.type AND
                                      temp-dis-card-type.emitent-host-code = ub.dis-card.emitent-host-code) then next.
            end.
            { rep/r-svhr2.i }
          END.
        END.
      END.
    END.
    run waitfram-hide in this-procedure .
  end.

end procedure. /* process-chk-doc */


procedure process-chk-gds :
define variable v-obj-code like ub.clients.obj-code no-undo .
define buffer tot_grp-h for grp-h.


  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ("Ждите ..." ).
    CASE t-dis-card:
      WHEN NO then do:
        FOR EACH obj-list :
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc3:
          FOR EACH ub.chk-doc WHERE
                ub.chk-doc.obj-type = obj-list.obj-type AND
                ub.chk-doc.obj-code = obj-list.obj-code AND
                ub.chk-doc.chk-date >= X-date-start AND
                ub.chk-doc.chk-date <= X-date-end  NO-LOCK
            USE-INDEX obj-date ,
            EACH ub.chk-gds WHERE
                ub.chk-gds.doc-code = ub.chk-doc.doc-code NO-LOCK
            USE-INDEX doc,
            FIRST ub.bar-code WHERE
                  ub.bar-code.b-code = ub.chk-gds.b-code NO-LOCK ,
            FIRST ub.goods WHERE
                  ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK:
          if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc3.
          { rep/r-svhr1.i }
          end.
        END. /*FOR EACH */
      end.
      when yes then do:
        FOR EACH obj-list :
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc4:
          FOR EACH ub.chk-doc WHERE
                ub.chk-doc.obj-type = obj-list.obj-type AND
                ub.chk-doc.obj-code = obj-list.obj-code AND
                ub.chk-doc.chk-date >= X-date-start AND
                ub.chk-doc.chk-date <= X-date-end  AND
                ub.chk-doc.d-card <> "":U NO-LOCK ,
            EACH ub.chk-gds WHERE
                ub.chk-gds.doc-code = chk-doc.doc-code NO-LOCK
            USE-INDEX doc,
            FIRST ub.bar-code WHERE
                  ub.bar-code.b-code = ub.chk-gds.b-code NO-LOCK ,
            FIRST ub.goods WHERE
                  ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK:
            if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc4.
            if rs-dis-card = 1 then do:
              FIND FIRST ub.dis-card No-LOCK WHERE
                ub.dis-card.d-card = ub.chk-doc.d-card no-error .
                if not available ub.dis-card then next.
                if not can-find(first temp-dis-card-type No-LOCK WHERE
                                      temp-dis-card-type.type = ub.dis-card.type AND
                                      temp-dis-card-type.emitent-host-code = ub.dis-card.emitent-host-code) then next.
            end.
            { rep/r-svhr1.i }
          END.
        END. /*FOR EACH */
      end.
    END CASE.
    run waitfram-hide in this-procedure .
  end.

end procedure. /* process-chk-gds */

procedure process-chk-pay :
define variable v-obj-code like ub.clients.obj-code no-undo .
define buffer tot_grp-h for grp-h.

  do
  on error undo, return error
  :
    CASE t-dis-card:
      WHEN NO then do:
        FOR EACH obj-list:
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc5:
          FOR  EACH ub.chk-doc WHERE
                ub.chk-doc.obj-type = obj-list.obj-type AND
                ub.chk-doc.obj-code = obj-list.obj-code AND
                ub.chk-doc.chk-date >= X-date-start AND
                ub.chk-doc.chk-date <= X-date-end  NO-LOCK
            USE-INDEX obj-date ,
            EACH ub.chk-pay WHERE
                ub.chk-pay.doc-code = ub.chk-doc.doc-code NO-LOCK:
           if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc5.
          { rep/r-svhr3.i }
          END.
        END. /*FOR EACH */
      end.
      WHEN YES then do:
        FOR EACH obj-list :
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc6:
           FOR EACH ub.chk-doc WHERE
                ub.chk-doc.obj-type = obj-list.obj-type AND
                ub.chk-doc.obj-code = obj-list.obj-code AND
                ub.chk-doc.chk-date >= X-date-start AND
                ub.chk-doc.chk-date <= X-date-end AND
                ub.chk-doc.d-card <> "":U NO-LOCK,
            EACH ub.chk-pay WHERE
                ub.chk-pay.doc-code = ub.chk-doc.doc-code NO-LOCK:
            if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc6.
            if rs-dis-card = 1 then do:
              FIND FIRST ub.dis-card No-LOCK WHERE
                ub.dis-card.d-card = ub.chk-doc.d-card no-error .
                if not available ub.dis-card then next.
                if not can-find(first temp-dis-card-type No-LOCK WHERE
                                      temp-dis-card-type.type = ub.dis-card.type AND
                                      temp-dis-card-type.emitent-host-code = ub.dis-card.emitent-host-code) then next.
            end.
            { rep/r-svhr3.i }
          END.
        END. /*FOR EACH */
      END.
    END CASE.
  end.

end procedure. /* process-chk-pay */