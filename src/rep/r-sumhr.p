block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-sumhr.p $
$Archive: rep/r-sumhr.p $

Почасовая статистика розничных продаж по СУММАМ ПРОДАЖ - сбор данных

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/19/05
Author: Bakhtadze Natalya
Creation date: 10/19/05

*/

define input parameter for-h-str as character no-undo .
define input parameter ByObject as logical no-undo .
define input parameter With-Goods as integer no-undo .
define input parameter t-dis-card as logical no-undo .
define input parameter rs-dis-card as integer no-undo .


def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-sumhr.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-sumhr.p $":U .
def var vss-description as character no-undo init "Почасовая статистика розничных продаж по СУММАМ ПРОДАЖ - сбор данных".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }
{ rep/e-sumhdf.i "SHARED" }
{ gbl/waitfram.i }


define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.
DEFINE VARIABLE ii-sec as integer no-undo .
DEFINE VARIABLE accum-chk-doc as integer no-undo .
DEFINE VARIABLE accum-chk-gds as integer no-undo .
DEFINE VARIABLE accum-chk-pay as integer no-undo .
define variable v-curr-r-b as character no-undo .
{ gbl/curr-r-b.i
  v-curr-r-b
}


if num-entries(for-h-str) <> 24 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра" for-h-str
  view-as alert-box error .
  return error .
end.


CASE with-goods:
  WHEN 0 or When 1 then do:
    run process-chk-doc in this-procedure no-error .
  END.
  WHEN 2 or when 3 then do:
    run process-chk-gds in this-procedure no-error .
  END. /* with-goods = 2 or 3*/
  WHEN 4 then do: /*по кодам оплат*/
    run process-chk-pay in this-procedure no-error .
  END. /*when 4 */
END CASE.


procedure process-chk-doc :
define variable v-obj-code like ub.clients.obj-code no-undo .
define buffer tot_grp-h for grp-h.

  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ("Ждите..." ).
    CASE t-dis-card:
      WHEN NO THEN DO:
        FOR EACH obj-list No-LOCK:
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
            _chk-doc:
            for each ub.chk-doc WHERE
                ub.chk-doc.obj-type = obj-list.obj-type AND
                ub.chk-doc.obj-code = obj-list.obj-code AND
                ub.chk-doc.chk-date >= X-date-start AND
                ub.chk-doc.chk-date <= X-date-end NO-LOCK
            USE-INDEX obj-date :
            if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
              { rep/r-sumhr1.i }
          end.
        END.
      END.
      WHEN YES THEN DO:
        FOR EACH obj-list No-LOCK:
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
           _chk-doc2:
           for EACH chk-doc WHERE
                chk-doc.obj-type = obj-list.obj-type AND
                chk-doc.obj-code = obj-list.obj-code AND
                chk-doc.chk-date >= X-date-start AND
                chk-doc.chk-date <= X-date-end AND
                chk-doc.d-card <> "":U NO-LOCK
             :
             if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc2.
          if rs-dis-card = 1 then do:
            FIND FIRST ub.dis-card No-LOCK WHERE
              ub.dis-card.d-card = ub.chk-doc.d-card no-error .
              if not available ub.dis-card then next.
              if not can-find(first temp-dis-card-type No-LOCK WHERE
                                    temp-dis-card-type.type = ub.dis-card.type AND
                                    temp-dis-card-type.emitent-host-code = ub.dis-card.emitent-host-code) then next.
          end.
            { rep/r-sumhr1.i }
          END.
        end.
      END.
    END CASE.
    run waitfram-hide in this-procedure .
  end.

end procedure. /* process-chk-doc */

procedure process-chk-gds :
define variable v-obj-code like ub.clients.obj-code no-undo .
define buffer tot_grp-h for grp-h.
define buffer tot_gds-h for gds-h.

  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ("Ждите..." ).
    CASE t-dis-card:
      when no then do:
        FOR EACH obj-list NO-LOCK:
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc3:
          for EACH ub.chk-doc WHERE
                ub.chk-doc.obj-type = obj-list.obj-type AND
                ub.chk-doc.obj-code = obj-list.obj-code AND
                ub.chk-doc.chk-date >= X-date-start AND
                ub.chk-doc.chk-date <= X-date-end NO-LOCK
            USE-INDEX obj-date ,
            EACH ub.chk-gds WHERE ub.chk-gds.doc-code = ub.chk-doc.doc-code NO-LOCK
            USE-INDEX doc,
            FIRST ub.bar-code WHERE ub.bar-code.b-code = ub.chk-gds.b-code NO-LOCK ,
            FIRST ub.goods WHERE ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK:
            if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc3.
            { rep/r-sumhr2.i }
          END.
        end.
      end.
      when yes then do:
        FOR EACH obj-list NO-LOCK:
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc4:
          for EACH chk-doc WHERE
                chk-doc.obj-type = obj-list.obj-type AND
                chk-doc.obj-code = obj-list.obj-code AND
                chk-doc.chk-date >= X-date-start AND
                chk-doc.chk-date <= X-date-end AND
                chk-doc.d-card <> "":U NO-LOCK,
            EACH chk-gds WHERE chk-gds.doc-code = chk-doc.doc-code NO-LOCK
            USE-INDEX doc,
            FIRST bar-code WHERE bar-code.b-code = chk-gds.b-code NO-LOCK ,
            FIRST goods WHERE goods.gds-code = bar-code.gds-code NO-LOCK:
            if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc4.
            if rs-dis-card = 1 then do:
              FIND FIRST ub.dis-card No-LOCK WHERE
                ub.dis-card.d-card = ub.chk-doc.d-card no-error .
                if not available ub.dis-card then next.
                if not can-find(first temp-dis-card-type No-LOCK WHERE
                                      temp-dis-card-type.type = ub.dis-card.type AND
                                      temp-dis-card-type.emitent-host-code = ub.dis-card.emitent-host-code) then next.
            end.
            { rep/r-sumhr2.i }
          end.
        END.
      end.
    END.
    run waitfram-hide in this-procedure .
  end.

end procedure. /* process-chk-gds */


procedure process-chk-pay :
define variable v-obj-code like ub.clients.obj-code no-undo .
define buffer tot_grp-h for grp-h.
  do
  on error undo, return error
  :
    run waitfram-show in this-procedure ("Ждите..." ).
    CASE t-dis-card:
      when no then do:
        FOR EACH obj-list No-LOCK:
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
            _chk-doc5:
            for  EACH ub.chk-doc WHERE
                  ub.chk-doc.obj-type = obj-list.obj-type AND
                  ub.chk-doc.obj-code = obj-list.obj-code AND
                  ub.chk-doc.chk-date >= X-date-start AND
                  ub.chk-doc.chk-date <= X-date-end NO-LOCK
              USE-INDEX obj-date ,
              EACH ub.chk-pay NO-LOCK WHERE
                    ub.chk-pay.doc-code = ub.chk-doc.doc-code
              :
            if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc5.
            { rep/r-sumhr3.i }
          end.
        END.
      end.
      when yes then do:
        FOR EACH obj-list No-LOCK:
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc6:
          for EACH ub.chk-doc WHERE
                ub.chk-doc.obj-type = obj-list.obj-type AND
                ub.chk-doc.obj-code = obj-list.obj-code AND
                ub.chk-doc.chk-date >= X-date-start AND
                ub.chk-doc.chk-date <= X-date-end AND
                ub.chk-doc.d-card <> "" No-LOCK ,
            EACH ub.chk-pay NO-LOCK WHERE
                  ub.chk-pay.doc-code = ub.chk-doc.doc-code :
                      if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc6.
            if rs-dis-card = 1 then do:
              FIND FIRST ub.dis-card No-LOCK WHERE
                ub.dis-card.d-card = ub.chk-doc.d-card no-error .
                if not available ub.dis-card then next.
                if not can-find(first temp-dis-card-type No-LOCK WHERE
                                      temp-dis-card-type.type = ub.dis-card.type AND
                                      temp-dis-card-type.emitent-host-code = ub.dis-card.emitent-host-code) then next.
            end.

            { rep/r-sumhr3.i }
          end.
        END.
      end.
    end.
    run waitfram-hide in this-procedure .
  end.

end procedure. /* process-chk-pay */