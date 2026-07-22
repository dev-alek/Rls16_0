block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-grphr.p $
$Archive: rep/r-grphr.p $

Почасовая статистика розничных продаж по КОЛИЧЕСТВУ ТОВАРОВ - сбор данных

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/19/05
Author: Bakhtadze Natalya
Creation date: 10/19/05

*/

define input parameter for-h-str as character no-undo .
define input parameter RS-option as integer no-undo .
define input parameter WithGoods as logical no-undo .
define input parameter T-dis-card as logical no-undo .
define input parameter Rs-dis-card as integer no-undo .
define input parameter t-scale as logical no-undo .
define input parameter p-selectGood as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-grphr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-grphr.p $":U .
define variable vss-description as character no-undo init "Почасовая статистика розничных продаж по КОЛИЧЕСТВУ ТОВАРОВ - сбор данных".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/r-page1.i }
{ rep/e-grphdf.i "SHARED" }
{ gbl/waitfram.i }


define SHARED temp-table temp-dis-card-type no-undo like ub.dis-card-type.

DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE for-h as logical no-undo extent 24.
DEFINE VARIABLE ii-sec as integer no-undo .
DEFINE VARIABLE accum-chk-gds as integer no-undo .
DEFINE VARIABLE var-prt-name as character no-undo .
DEFINE VARIABLE var-empty-scale like ub.goods.prt-root no-undo .
DEFINE VARIABLE var-UNIQ as character no-undo .
define variable byobject as logical no-undo .
define variable v-obj-code like ub.clients.obj-code no-undo .
define buffer loc-gds-prt for ub.gds-prt.
define buffer tot_gds-h for gds-h.
define buffer tot_grp-h for grp-h.



if num-entries(for-h-str) <> 24 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверное значение параметра" for-h-str
  view-as alert-box error .
  return error .
end.

run waitfram-show in this-procedure ("Ждите..." ).
do ii = 1 to 24:
  for-h[ii] = (entry(ii, for-h-str) = "yes").
END.

/*определим пустую шкалу*/
{ gbl/emptyscl.i var-empty-scale no-error }
if error-status:error then return error.
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
          FOR EACH ub.chk-doc WHERE
                  ub.chk-doc.obj-type = obj-list.obj-type AND
                  ub.chk-doc.obj-code = obj-list.obj-code AND
                  ub.chk-doc.chk-date >= x-Date-Start AND
                  ub.chk-doc.chk-date <= x-Date-End AND
                  ub.chk-doc.d-card <> "":U NO-LOCK ,
            EACH ub.chk-gds WHERE
                  ub.chk-gds.doc-code = chk-doc.doc-code NO-LOCK ,
            FIRST ub.bar-code WHERE
                  ub.bar-code.b-code = chk-gds.b-code NO-LOCK ,
            FIRST ub.goods WHERE goods.gds-code = ub.bar-code.gds-code NO-LOCK:
            if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
          case p-selectGood:
              when {&g-choice} then do:
                find first gds-list where
                          gds-list.gds-code = ub.bar-code.gds-code no-error .
                if not available gds-list then NEXT.
              end.
              when {&g-grp} then do:
                find first tmp#grp where
                         ub.goods.grp-name begins tmp#grp.grp-name no-error.
                if not avail tmp#grp then NEXT.
              end.
              when {&g-prod} then do:
                FIND FIRST g#cli WHERE
                            g#cli.obj-type = ub.goods.prod-type AND
                            g#cli.obj-code = ub.goods.prod-code NO-LOCK NO-ERROR.
                if not avail g#cli then NEXT.
              end.
            end case.
            { rep/r-grphr.i }
          END.
        END.
      END.
      WHEN 1 then do:
        FOR EACH obj-list:
          If byobject then v-obj-code = obj-list.obj-code.
          else v-obj-code = 0.
          _chk-doc2:
          FOR EACH ub.chk-doc WHERE
                  ub.chk-doc.obj-type = obj-list.obj-type AND
                  ub.chk-doc.obj-code = obj-list.obj-code AND
                  ub.chk-doc.chk-date >= x-Date-Start AND
                  ub.chk-doc.chk-date <= x-Date-End AND
                  ub.chk-doc.d-card <> "":U NO-LOCK ,
            EACH ub.chk-gds WHERE
                  ub.chk-gds.doc-code = chk-doc.doc-code NO-LOCK ,
            FIRST ub.bar-code WHERE
                  ub.bar-code.b-code = ub.chk-gds.b-code NO-LOCK ,
            FIRST ub.goods WHERE ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK:
            if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc2.
            FIND FIRST ub.dis-card No-LOCK WHERE
                      ub.dis-card.d-card = ub.chk-doc.d-card no-error .
                      if not available ub.dis-card then next.
            if not can-find(first temp-dis-card-type No-LOCK WHERE
                                  temp-dis-card-type.type = dis-card.type AND
                                  temp-dis-card-type.emitent-host-code = dis-card.emitent-host-code) then next.
            case p-selectGood:
              when {&g-choice} then do:
                find first gds-list where
                          gds-list.gds-code = ub.bar-code.gds-code no-error .
                if not available gds-list then NEXT.
              end.
              when {&g-grp} then do:
                find first tmp#grp where
                         ub.goods.grp-name begins tmp#grp.grp-name no-error.
                if not avail tmp#grp then NEXT.
              end.
              when {&g-prod} then do:
                FIND FIRST g#cli WHERE
                            g#cli.obj-type = ub.goods.prod-type AND
                            g#cli.obj-code = ub.goods.prod-code NO-LOCK NO-ERROR.
                if not avail g#cli then NEXT.
              end.
            end case.
            { rep/r-grphr.i }
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
              ub.chk-doc.chk-date >= x-Date-Start AND
              ub.chk-doc.chk-date <= x-Date-End NO-LOCK ,
        EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = chk-doc.doc-code NO-LOCK ,
        FIRST ub.bar-code WHERE
              ub.bar-code.b-code = ub.chk-gds.b-code NO-LOCK ,
        FIRST ub.goods WHERE ub.goods.gds-code = ub.bar-code.gds-code NO-LOCK:
        if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc3.
        case p-selectGood:
          when {&g-choice} then do:
            find first gds-list where
                      gds-list.gds-code = ub.bar-code.gds-code no-error .
            if not available gds-list then NEXT.
          end.
          when {&g-grp} then do:
            find first tmp#grp where
                      ub.goods.grp-name begins tmp#grp.grp-name no-error.
            if not avail tmp#grp then NEXT.
          end.
          when {&g-prod} then do:
            FIND FIRST g#cli WHERE
                        g#cli.obj-type = ub.goods.prod-type AND
                        g#cli.obj-code = ub.goods.prod-code NO-LOCK NO-ERROR.
            if not avail g#cli then NEXT.
          end.
        end case.
        { rep/r-grphr.i }
      END.
    END.
  END.
END CASE.
run waitfram-hide in this-procedure .