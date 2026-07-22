block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: arhdate.p $
$Archive: utl/arhdate.p $

Определение даты несоответствия архива и партий

Автор: Чернова Светлана Александровна
Дата создания: 12/05/08
Author: Svetlana Chernova
Creation date: 12/05/08

*/

define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-gds-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: arhdate.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/arhdate.p $":U .
define variable vss-description as character no-undo init "Определение даты несоответствия архива и партий ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/partslib.i }
{ trg/factord.i  }

define buffer buf_goods for ub.goods  .
define variable v-qnty  as decimal   no-undo .

find first buf_goods no-lock where
           buf_goods.gds-code = p-gds-code no-error .
if error-status :error then return error return-value .

define buffer buf_stk-line for ub.stk-line  .
for each ub.stk-line no-lock  where
         ub.stk-line.obj-type  = p-obj-type and
         ub.stk-line.obj-code  = p-obj-code and
         ub.stk-line.artic     = buf_goods.artic     and
         ub.stk-line.prod-type = buf_goods.prod-type and
         ub.stk-line.prod-code = buf_goods.prod-code and
         ub.stk-line.sum-type  = {&arh-cost} and
         ub.stk-line.cat-id    = "##,##"
            by ub.stk-line.fact-order
         :
        find first buf_stk-line no-lock where
         buf_stk-line.obj-type  = p-obj-type and
         buf_stk-line.obj-code  = p-obj-code and
         buf_stk-line.artic     = buf_goods.artic     and
         buf_stk-line.prod-type = buf_goods.prod-type and
         buf_stk-line.prod-code = buf_goods.prod-code and
         buf_stk-line.sum-type  = {&arh-crsa} and
         buf_stk-line.cat-id    = "##,##"   no-error .
         if not available buf_stk-line then do:
             message "Дата для пересчета архива" ub.stk-line.fact-date  view-as alert-box information .
             return .
         end.
         if ub.stk-line.fact-qnty <> buf_stk-line.fact-qnty
         then do:
             message "Дата для пересчета архива" ub.stk-line.fact-date  view-as alert-box information .
             return .
         end.

        run partslib-clear-temp-parts .
        run partslib-init-temp-parts-by-factord
        (    ub.stk-line.obj-type
           , ub.stk-line.obj-code
           , ub.stk-line.artic
           , ub.stk-line.prod-type
           , ub.stk-line.prod-code
           , ub.stk-line.fact-order
           , false
            ) no-error .
            if error-status :error then message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
          v-qnty = 0 .
          for each  temp-parts :
             v-qnty = v-qnty + temp-parts.free-qnty .
          end.
          message  v-qnty ub.stk-line.fact-date  ub.stk-line.fact-qnty.
          if v-qnty <> ub.stk-line.fact-qnty then do:
             message "Дата для пересчета архива" ub.stk-line.fact-date  view-as alert-box information .
             return .
          end.

end.

message 'ok'  view-as alert-box information .