block-level on error undo, throw.
/*

$Revision: db18bf2a7a81, 3297, rls $
$Author: EShklyar $
$Date: 2023/03/29 08:48:06 $
$Workfile: send-bcpromo.p $
$Archive: str/send-bcpromo.p $

пересылка ШК промоакций на кассу

Автор: Шкляр Елена
Дата создания: 09/20/05
Author: Shklyar Elena
Creation date: 09/20/05

*/
using ibs.th.gbl.storage.*.
using Progress.Lang.*.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter i-obj-code like ub.shop.obj-code no-undo.
DEFINE INPUT PARAMETER action as char no-undo.
DEFINE INPUT PARAMETER selective as integer no-undo.
/*по оплатам выборочно или все!*/
define input parameter pRow as character no-undo .
/*список recid cash-pay если selective = yes*/
define input parameter p-log-file-name as character no-undo .
define input-output parameter p-view-log as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: db18bf2a7a81, 3297, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/03/29 08:48:06 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-bcpromo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-bcpromo.p $":U .
define variable vss-description as character no-undo init "Пересылка ШК промоакций на кассы".
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
define variable v-attr-emrc          as character no-undo .
define variable v-attr-type          as character no-undo .

/*PROCEDURE putc-gds.*/
/*разнящийся вывод для разных типов касс*/
procedure putc-17 :
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

  define variable v-mode          as character no-undo . /* create/update */
  define variable v-retfl         as logical   no-undo .
      
  define variable v-i-num         as integer   no-undo .
  define variable v-i-counter     as integer   no-undo .
  define variable v-j-num         as integer   no-undo .
  define variable v-j-counter     as integer   no-undo .
  define variable v-stub          as integer   no-undo .
  define variable vTypePay        as character no-undo.
  define variable vIp             as integer   no-undo.
  
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
  define variable v-timebeg       as integer   no-undo .
  define variable v-timeend       as integer   no-undo .
  define variable v-hh            as integer   no-undo .
  define variable v-mm            as integer   no-undo .
  define variable v-promo-summ    as decimal   no-undo .
  define variable v-method        as integer   no-undo .
  define variable typecond        as integer   no-undo .
  define variable schedule-type   as integer   no-undo .
   
  define variable v-rid-list      as recid     no-undo . 
  define variable vgift           as logical   no-undo.
  define variable vSetGoods       as logical   no-undo.   
  define buffer buf_PromoAction for ub.PromoAction .
  define buffer buf_PromoSched  for ub.promo-schedule .
  define buffer buf_promogoods  for ub.PromoGoods .
  define variable producer-int as integer no-undo .
   
  do
    on error undo, return error
    :
    if pRow = "" then 
    do:
      if action = "D" then 
      do:
        FOR EACH ub.PromoAttr EXCLUSIVE-LOCK 
          :
          {str/putc-17ddd.i} .
        END. /* FOR EACh */
      end.

    end.
    else 
    do:
      DO ii = 1 to num-entries (pRow):
        v-rid-list = integer(entry(ii,pRow)) .
        FIND FIRST ub.PromoAttr No-LOCK where recid(ub.PromoAttr) = v-rid-list No-ERROR.
        IF available ub.PromoAttr then
        do:
               {str/putc-17ddd.i} .   
        end.
      END.
    end.

  end.

end procedure. /* putc-17 */


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/

{ str/cd-cycl17.i }

/*PROCEDURE SENDING.*/

{ str/cd-send17.i }

assign
  log-file-name = p-log-file-name
  .

{ gbl/hostcode.i {&shop} i-obj-code v-host-code }
/*if action = "D" and not g#esys and not g#news                     */
/*   then                                                           */
/*do:                                                               */
/*   message                                                        */
/*      "Вы действительно хотите удалить с кассы записи промоакций?"*/
/*      view-as alert-box QUESTION buttons YES-NO update glog.      */
/*   if not glog then return.                                       */
/*end.                                                              */
if action = 'D':U then 
do:
  assign
    v-cp-is-use = no.
end.
if action <> 'D':U then 
do:

end.


RUN SENDING no-error.
if error-status:error then 
do:
  run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute( "!!!Ошибки при отсылке ШК промоакций на кассы  маг&1:&2&3 &4"
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