block-level on error undo, throw.
/*

$Revision: e455fc319afd, 3602, rls $
$Author: ARostovtsev $
$Date: 2023/12/28 12:56:37 $
$Workfile: send-promo.p $
$Archive: str/send-promo.p $

пересылка промоакций на кассу

Автор: Шкляр Елена
Дата создания: 09/20/05
Author: Shklyar Elena
Creation date: 09/20/05

*/
using ibs.th.gbl.storage.*.
using ibs.th.ref.promo.*.
&scoped-define impclass promotion
using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.{&impclass}.
using ibs.th.ref.promo.enum-type-discount .
using ibs.th.ref.promo.enum-promo-status .
using ibs.th.ref.promo.enum-sched-status .
using ibs.th.bge.1crn.subjects.promotion_promoset from propath.
using ibs.th.bge.1crn.subjects.promotion_ps-section from propath.


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter i-obj-code like ub.shop.obj-code no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
DEFINE INPUT PARAMETER selective as integer no-undo.
/*по оплатам выборочно или все!*/
define input parameter pSubs as class ibs.th.ref.promo.promoactionsubs no-undo .
/*список recid cash-pay если selective = yes*/
define input parameter p-log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: e455fc319afd, 3602, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/28 12:56:37 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-promo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-promo.p $":U .
define variable vss-description as character no-undo init "Пересылка промоакций на кассы".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }
{ ref/cp-attr.i }
{ str/cp-isuse.i }
{ bge/ds-promo.i} 
{ ref/gds-attr.i }

DEFINE VARIABLE kassa-rub-code       as integer.
DEFINE VARIABLE ibmnalc              as integer   no-undo .
define variable multicurr            as logical   no-undo .
define variable conf-attr            as character no-undo .
DEFINE VARIABLE conf-par             as character no-undo.                  /* для чтения параметра конфигурации */
DEFINE VARIABLE par-type             as character no-undo.
DEFINE VARIABLE dopi                 as decimal   no-undo.
DEFINE VARIABLE ii                   as integer   no-undo.
define variable v-host-code          like ub.sysconf.host-code no-undo .
define variable v-cp-is-use          as logical   no-undo .
define variable mariapayg            as character no-undo .
define variable mariapayp            as character no-undo .
/*список соответствий по скидкам для кассы мария */
define variable dr-list              as character no-undo .
/*список приоритетов шаблонов правл скидок для скидок по группе товара*/
define variable drcprank             as character no-undo .
define variable v-record             as character no-undo .
define variable v-found-maria-discnt as logical   no-undo .

/*PROCEDURE putc-gds.*/
/*разнящийся вывод для разных типов касс*/
procedure putc-16 :
  define parameter buffer buf_cash-desk for ub.cash-desk.
  define input parameter par-cash-num like ub.cash-desk.cash-num no-undo .
  define input parameter p-pos-version like ub.cash-desk.version no-undo .
  define variable v-value              as character no-undo .
  define variable v-type               as character no-undo .
  define variable v-index              as integer   no-undo .
  define variable v-ii                 as integer   no-undo .
  define variable v-jj                 as integer   no-undo .
  define variable v-plu                as character no-undo .
  define variable v-dop                as character no-undo .
  define variable v-dop2               as character no-undo .
  define variable v-cp-attr-code       as character no-undo .
  define variable attr-value           as character no-undo .
  define variable attr-type            as character no-undo .
  define variable v-maria-rule-num     as integer   no-undo .
  define variable v-maria-discnt-value as character no-undo .
  define variable v-skip-fields        as integer   no-undo .
  define variable v-version-dec        as decimal   no-undo .
  define variable v-paymentetc         as character no-undo .
  define buffer BUF_DIS-RULE      for UB.DIS-RULE.
  define buffer buf_dis-cp-rule   for ub.dis-cp-rule.
  define buffer buf_cash-pay-attr for ub.cash-pay-attr.

  define variable v-mode             as character no-undo . /* create/update */
  define variable objImp             as class     {&impclass}                           no-undo.
  define variable v-retfl            as logical   no-undo .
      
  define variable v-i-num            as integer   no-undo .
  define variable v-i-counter        as integer   no-undo .
  define variable v-j-num            as integer   no-undo .
  define variable v-j-counter        as integer   no-undo .
  define variable v-stub             as integer   no-undo .
  define variable vTypePay           as character no-undo.
  define variable vIp                as integer   no-undo.
  

  define variable v-promo-action     as class     ibs.th.ref.promo.promoactionsub       no-undo .
    
  define variable v-storage          as class     ibs.th.gbl.storage.promoactionstorage no-undo .
  define variable v-subs             as class     promoActionSubs                       no-undo .
  define variable v-sub              as class     promoactionsub                        no-undo .
  define variable v-subsCrit         as class     ibs.th.ref.promo.promoGoodsSubs       no-undo .
  define variable v-subCrit          as class     ibs.th.ref.promo.promoGoodsSub        no-undo .
  define variable m-storage          as class     promoactionstorage                    no-undo .

  define variable v-subShed          as class     PromoSchedSub                         no-undo .
  define variable v-subShedWs        as class     promoSchedwSubs                       no-undo .
  define variable v-subShedW         as class     PromoSchedwSub                        no-undo .
  define variable v-subGood          as class     PromoGoodsSub                         no-undo .
  define variable v-subGdCrs         as class     promoGoodsSubs                        no-undo . 
  define variable v-subCardBins      as class     promoGoodsSubs                        no-undo . 
  define variable v-subCardBin       as class     promoGoodsSub                         no-undo .
  define variable v-subGdCr          as class     PromoGoodsSub                         no-undo .
  define variable v-subGoods         as class     promoGoodsSubs                        no-undo .      
  define variable v-subGDCrites      as class     promoCriterionSubs                    no-undo .
  define variable v-subGDCrite       as class     promoCriterionSub                     no-undo .
  define variable v-subGifts         as class     promoGiftSubs                         no-undo .
  define variable v-subGift          as class     promoGiftSub                          no-undo .
  define variable v-subCrGifts       as class     promoGiftSubs                         no-undo .
  define variable v-subCrGift        as class     promoGiftSub                          no-undo .
  define variable v-subPromoSets     as class     promoGoodssubs                        no-undo .
  define variable v-subPromoSet      as class     promoGoodssub                         no-undo .
  define variable v-subPromoSetGoods as class     promoGoodssubs                        no-undo .
  define variable v-subPromoSetGood  as class     promoGoodssub                         no-undo .
   
  define variable v-length        as integer   no-undo .
  define variable v-lengthSh      as integer   no-undo .
  define variable v-lengthGD      as integer   no-undo .
  define variable v-lengthGif     as integer   no-undo .
  define variable v-i             as integer   no-undo .
  define variable v-j             as integer   no-undo .
  define variable v-size          as integer   no-undo .
  define variable v-sizeGif       as integer   no-undo .
  define variable vPricePromoSets as decimal   no-undo.
  define variable v-mess          as character no-undo . 
  define variable v-mess-gks      as character no-undo . 
  define variable vgift           as logical   no-undo.
  define variable vSetGoods       as logical   no-undo.  
  define variable producer-int    as integer   no-undo . 
  define variable change-BL       as integer   no-undo .
  define buffer buf_PromoAction for ub.PromoAction .
  define buffer buf_PromoSched  for ub.promo-schedule .
  define buffer buf_promogoods  for ub.PromoGoods .

  define variable v-attr-emrc as character no-undo .
  define variable v-attr-type as character no-undo .
  do
    on error undo, return error
    :
    if selective = 0 then 
    do:
      if action = "D" then 
      do:        
        FOR EACH ub.PromoAction 
          EXCLUSIVE-LOCK where ub.PromoAction.Status_ <> 3
          :

          v-promo-action = new PromoActionSub(i-obj-code).

          v-promo-action:ID = ub.PromoAction.id .

          m-storage = new ibs.th.gbl.storage.promoactionstorage () . // создать экземпляр, который работает с БД

          m-storage:refreshObj(v-promo-action, i-obj-code) . // прочесть коллекцию акций (все акции)
          v-promo-action:refreshChildObj() . // возвращает
          if ub.PromoAction.typecond = 4 then {str/putc-17d.i} .
          { str/putc-16.i }
        END. /* FOR EACh */
      end.
      else 
      do:
        FOR EACH ub.PromoAction 
          EXCLUSIVE-LOCK where ub.PromoAction.Status_ = 1
          :
          v-promo-action = new PromoActionSub(i-obj-code).

          v-promo-action:ID = ub.PromoAction.id .

          m-storage = new ibs.th.gbl.storage.promoactionstorage () . // создать экземпляр, который работает с БД

          m-storage:refreshObj(v-promo-action, i-obj-code) . // прочесть коллекцию акций (все акции)
          v-promo-action:refreshChildObj() . // возвращает
          if ub.PromoAction.typecond = 4 then {str/putc-17d.i} .
          { str/putc-16.i }
          if ub.PromoAction.typecond = 4 and action = "U":U then 
          do:
            {str/putc-17.i} 
          end.

        END. /* FOR EACh */        
      end.
    end.
    else 
    do:
      DO ii = 1 to pSubs:iCounter:
        pSubs:GetItem(ii).
        v-promo-action = pSubs:promoActionObjCurr .
        if action = "D" then 
        do:
          FIND FIRST ub.PromoAction No-LOCK WHERE
            ub.PromoAction.id = v-promo-action:ID and ub.PromoAction.Status_ <> 3 No-ERROR.
          IF avail ub.PromoAction then
          do:
            m-storage = new ibs.th.gbl.storage.promoactionstorage () . // создать экземпляр, который работает с БД

            m-storage:refreshObj(v-promo-action, i-obj-code) . // прочесть коллекцию акций (все акции)
            v-promo-action:refreshChildObj() . // возвращает
            if ub.PromoAction.typecond = 4 then {str/putc-17d.i} .
          { str/putc-16.i }
          end.

        end.

        else 
        do:
          FIND FIRST ub.PromoAction No-LOCK WHERE
            ub.PromoAction.id = v-promo-action:ID and ub.PromoAction.Status_ = 1 No-ERROR.
          IF avail ub.PromoAction then
          do:
            m-storage = new ibs.th.gbl.storage.promoactionstorage () . // создать экземпляр, который работает с БД

            m-storage:refreshObj(v-promo-action, i-obj-code) . // прочесть коллекцию акций (все акции)
            v-promo-action:refreshChildObj() . // возвращает
            if ub.PromoAction.typecond = 4 then {str/putc-17d.i} .
          { str/putc-16.i }
            if ub.PromoAction.typecond = 4 and action = "U":U then 
            do:
          {str/putc-17.i} 
            end.

          end.  
        end.
      END.
    end.

  end.

end procedure. /* putc-16 */


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/

{ str/cd-cycl16.i }

/*PROCEDURE SENDING.*/

{ str/cd-send16.i }

assign
  log-file-name = p-log-file-name
  .

{ gbl/hostcode.i {&shop} i-obj-code v-host-code }
if action = "D" and not g#esys and not g#news and selective <> 1
  then 
do:
  message
    "Вы действительно хотите удалить с кассы записи промоакций?"
    view-as alert-box QUESTION buttons YES-NO update glog.
  if not glog then return.
end.
if action = 'D':U then 
do:
  assign
    v-cp-is-use = no.
end.
if action <> 'D':U then 
do:
/*  run adm/shattri.p (                                       */
/*      input "get":U                                         */
/*      ,input  {&shop}                                       */
/*      ,input  i-obj-code                                    */
/*      ,input  {&attr-cd-inf-send}                           */
/*      ,input  {&attr-cd-inf-send_cp-is-use} /*p-param-code*/*/
/*      ,output v-value-character                             */
/*      ,output v-value-date                                  */
/*      ,output v-value-decimal                               */
/*      ,output v-value-integer                               */
/*      ,output v-value-logical                               */
/*      ,output v-param-type                                  */
/*      ,INPUT-OUTPUT table-handle v-tth                      */
/*      ) no-error .                                          */
/*  IF not error-status:error                                 */
/*  then do:                                                  */
/*    v-cp-is-use = v-value-logical.                          */
/*    delete object v-tth.                                    */
/*  end.                                                      */
/*  else do:                                                  */
/*    delete object v-tth.                                    */
/*    return error return-value .                             */
/*  end.                                                      */
end.


RUN SENDING no-error.
if error-status:error then 
do:
  run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute( "!!!Ошибки при отсылке промоакций на кассы  маг&1:&2&3 &4"
    , i-obj-code
    , {&new-line}
    , error-status:get-message(1)
    , return-value
    )
    ).

  assign
    v-view-log = yes
    .
end.
run write-log-and-file in p-log-handle (
  input 1
  , input log-file-name
  , input 1
  , input substitute("Сформированы файлы для касс объекта &1&2", {&shop}, i-obj-code)
  ).