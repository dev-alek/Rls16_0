block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bgepych2.p $
$Archive: bge/bgepych2.p $

Разброс чеков по документу продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
/*может быть {&TDEDT_Ras_Vnesh_Kass}  {&TDEDT_Vozvrat_Vnesh_Kass} или "":U*/
define input parameter p-by-pay-desk as logical no-undo .
define input parameter p-by-pay-card-prefix as logical no-undo .

define input parameter p-petrol as logical no-undo .
define input parameter p-goods as logical no-undo .
define input parameter p-services as logical no-undo .
/*для определени того это расходная часть или возвратная*/

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: bgepych2.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: bge/bgepych2.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "$Разброс чеков по документу продажи $":U.
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/lib-trn.i }
{ rep/cpapcep.i shared }
{ rep/rl-2df-2.i SHARED }
{ rep/rl-3df-2.i SHARED }
{ rep/rl-4df-2.i SHARED }
{ rep/r-pychk0.i defalgo }


DEFINE VARIABLE v-line-num as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_Inkas for ub.inkas.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
{ rep/r-pychk2.i def }
{ gbl/curr-r-b.i
  v-curr-r-b
}

do
on error undo, return error
:

  find first buf_inkas no-lock where
             buf_inkas.inkas-code = p-inkas-code.

  { gbl/basecode.i buf_inkas.host-code v-base-code }
  for each treal-2:
    delete treal-2.
  end.
  for each treal-3:
    delete treal-3.
  end.
  for each treal-4:
    delete treal-4.
  end.
  /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
  run rep/rpychk0.p ( input "bgepych2"
                      ,input buf_inkas.obj-type
                      ,input buf_inkas.obj-code
                      ,input ? /*p-date-from*/
                      ,input ? /*p-date-to*/
                      ,input ? /*p-shift-date-from*/
                      ,input ? /*p-shift-date-to*/
                      ,input ? /*p-shift-num-start*/
                      ,input ? /*p-shift-num-end*/
                      ,input buf_inkas.inkas-code /*p-inkas-code*/
                      ) no-error.
  if error-status:error then
    return error return-value.
 _chk-doc:
 FOR EACH ub.chk-doc No-LOCK WHERE
          ub.chk-doc.obj-type = buf_inkas.obj-type AND
          ub.chk-doc.obj-code = buf_inkas.obj-code AND
          ub.chk-doc.out-code = p-inkas-code:
    case p-ext-doc-type:
      when {&TDEDT_Ras_Vnesh_Kass} then do:
        if ub.chk-doc.netto < 0 then do:
          NEXT _chk-doc.
        end.
      end.
      when {&TDEDT_Vozvrat_Vnesh_Kass} then do:
        if ub.chk-doc.netto >= 0 then do:
          NEXT _chk-doc.
        end.
      end.
      when "":U then do:
      end.
    END CASE.
    if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
    if p-by-pay-desk then do:
      assign
      v-pay-desk = ub.chk-doc.pay-desk
      .
    end.
    else do:
      assign
      v-pay-desk = 0
      .
    end.
    for each buf_chk-gds-pay no-lock where
            buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
        and buf_chk-gds-pay.algo-num = {&current-algo-1},
        first buf_bar-code no-lock where
            buf_bar-code.b-code = buf_chk-gds-pay.b-code,
        first buf_cash-pay no-lock where
            buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code
        and buf_cash-pay.curr-code = buf_chk-gds-pay.curr-code:
      if p-by-pay-card-prefix  then do:
        find first buf_temp-cpa-pcep no-lock where
                  buf_temp-cpa-pcep.cdpay-code = buf_chk-gds-pay.pay-code
              AND buf_temp-cpa-pcep.curr-code = buf_chk-gds-pay.curr-code
              AND buf_chk-gds-pay.pay-card begins buf_temp-cpa-pcep.prefix no-error .
        if available buf_temp-cpa-pcep then
        assign
        v-pay-card = buf_temp-cpa-pcep.prefix
        .
        else
        assign
        v-pay-card = 'other':U
        .

      end.
      else do:
        assign
        v-pay-card = '':U
        .
      end.
      { rep/r-pychk2.i " " }
    end. /*for each buf_chk-gds-pay*/

end. /* FOR EACH ub.chk-doc No-LOCK WHERE*/
end. /*doe*/