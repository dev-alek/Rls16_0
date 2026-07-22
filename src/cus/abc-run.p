block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: abc-run.p $
$Archive: cus/abc-run.p $

Проставление данных из АВС в заказ при расчете

Автор: Чернова Светлана Александровна
Дата создания: 03/30/06
Author: Svetlana Chernova
Creation date: 03/30/06

*/

define input  parameter parparentproc as handle no-undo .
define output parameter p-recid   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: abc-run.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/abc-run.p $":U .
define variable vss-description as character no-undo init "Проставление данных из АВС в заказ при расчете".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cus/df-zakaz.i  }
{ gbl/waitfram.i  }
{ cmp/library.i   }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define buffer   buf_old_tmp-sale for ub.tmp-sale      .
define buffer   buf_tmp-sale     for ub.tmp-sale      .
define buffer   buf_tmp-sale-gds for ub.tmp-sale-gds  .
define buffer   buf_tmp-sale-dtl for ub.tmp-sale-dtl  .
define buffer   buf_goods        for ub.goods         .
define buffer   b2_abc-analysis       for ub.abc-analysis .
define buffer   b2_abc-analysis-goods for ub.abc-analysis-goods .

define variable v-new            as integer no-undo   .
define variable v-max            as integer no-undo   .
define variable v-list-recid as character no-undo .
define variable v-ii as integer   no-undo .

run ref/abcanal.w
( input   parparentproc  ,
  input  "b-mark,b-sel" ,
  output  v-list-recid  )
  .
 p-recid = v-list-recid  .
if num-entries( v-list-recid ) < 1 then do:
   message
   "Не выбран ни один анализ !"
   view-as alert-box information .
   p-recid = ? .
   return.
end.

if num-entries( v-list-recid ) > 2 then do:
   message
   "Выбрать надо было 2 анализа !"
   view-as alert-box information .
   p-recid = ? .
   return.
end.



define variable loc-tmp-code as character no-undo .

    run waitfram-show in this-procedure  ("Ждите...") .
    /* очистим */
    for each tmp#zakaz :
    assign
       tmp#zakaz.add-cli-qnty    = 0
       tmp#zakaz.add-qnty        = 0
       tmp#zakaz.temp-rash       = 0
       tmp#zakaz.cancel-cli-qnty = 0
       tmp#zakaz.cancel-qnty     = 0
    .
    end.

      find first  b2_abc-analysis no-lock where recid( b2_abc-analysis ) = int(entry(2,v-list-recid)) no-error .
      find first  ub.abc-analysis no-lock where recid( ub.abc-analysis ) = int(entry(1,v-list-recid)) no-error .
      if available ub.abc-analysis then do:
           for each tmp#zakaz :
              find first ub.abc-analysis-goods no-lock where
                         ub.abc-analysis-goods.abc-id = ub.abc-analysis.abc-id and
                         ub.abc-analysis-goods.db-num = ub.abc-analysis.db-num and
                         ub.abc-analysis-goods.gds-code = tmp#zakaz.gds-code no-error .
              if available ub.abc-analysis-goods then do:
                  assign
                    tmp#zakaz.add-cli-qnty    =   ASC(ub.abc-analysis-goods.abcg-abc)         /* ABC1 */
                    tmp#zakaz.add-qnty        =   ub.abc-analysis-goods.rating                /* райтинг1 */
                    tmp#zakaz.temp-rash       =   ub.abc-analysis-goods.abcg-temp-sale-goods  /* темп продаж */
                  .
              end.
              find first b2_abc-analysis-goods no-lock where
                         b2_abc-analysis-goods.abc-id = b2_abc-analysis.abc-id and
                         b2_abc-analysis-goods.db-num = b2_abc-analysis.db-num and
                         b2_abc-analysis-goods.gds-code = tmp#zakaz.gds-code no-error .
              if available b2_abc-analysis-goods then do:
                  assign
                      tmp#zakaz.cancel-cli-qnty =   ASC(b2_abc-analysis-goods.abcg-abc)  /* ABC2 */
                      tmp#zakaz.cancel-qnty     =   b2_abc-analysis-goods.rating         /* райтинг2 */
                  .
              end.

          end.
    end.
run waitfram-hide in this-procedure .