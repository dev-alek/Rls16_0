block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: perereazmas.p $
$Archive: utl/perereazmas.p $

Перереразмазка допрасходов и отсылка их по новостям

Автор: Чернова Светлана Александровна
Дата создания: 08/10/09
Author: Svetlana Chernova
Creation date: 08/10/09

*/

define input parameter parparentproc as handle no-undo .
define input parameter p-doc-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: perereazmas.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/perereazmas.p $":U .
define variable vss-description as character no-undo init "Перереразмазка допрасходов и отсылка их по новостям".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }

DEFINE TEMP-TABLE x_parts LIKE ub.parts.

run waitfram-show ("Восстановление документа...." ) .
define buffer bf_trn-doc for ub.trn-doc  .
find first bf_trn-doc no-lock where bf_trn-doc.doc-code = p-doc-code no-error .
define variable v-sum as decimal   no-undo .
define variable v-sum1 as decimal   no-undo .
define variable v-sum2 as decimal   no-undo .
/* Прочистка=============================================================================================================*/



    find first ub.add-trn no-lock where
              ub.add-trn.trn-doc-code = bf_trn-doc.doc-code no-error .
    find first ub.add-doc no-lock where
              ub.add-doc.doc-code = ub.add-trn.doc-code no-error .
    for each ub.doc-line-attr exclusive-lock where
            ub.doc-line-attr.doc-code  = bf_trn-doc.doc-code and
            ub.doc-line-attr.attr-code = {&lineattr-new_other-ras}  :
        delete ub.doc-line-attr.
    end.
    for each ub.doc-line-attr exclusive-lock where
            ub.doc-line-attr.doc-code  = bf_trn-doc.doc-code and
            ub.doc-line-attr.attr-code = {&lineattr-old_other-ras}  :
        delete ub.doc-line-attr.
    end.
    for each ub.doc-line-attr exclusive-lock where
            ub.doc-line-attr.doc-code  = bf_trn-doc.doc-code and
            ub.doc-line-attr.attr-code = {&lineattr-add-line-cli}  :
        delete ub.doc-line-attr.
    end.

     for each ub.doc-line exclusive-lock where
              ub.doc-line.doc-code  = bf_trn-doc.doc-code
              :
              ub.doc-line.other-rubl = 0.
              ub.doc-line.other-base = 0.
              ub.doc-line.transport-rubl = 0.
              ub.doc-line.transport-base = 0.
              v-sum  = ( ub.doc-line.price-cli  * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale ) / ub.doc-line.cli-base-rate .
              if bf_trn-doc.vat-type = {&no-VAT} then do:
                 v-sum1 = v-sum +  v-sum * ub.doc-line.vat-pc / 100 .
              end.
              else do:
                 v-sum1 = v-sum .
              end.

              if bf_trn-doc.slt-type = {&no-VAT} then do:
                 v-sum2 = v-sum1 +  v-sum1 * ub.doc-line.slt-pc / 100 .
              end.
              else do:
                 v-sum2 = v-sum1 .
              end.


              ub.doc-line.price-rubl = v-sum2 .
              ub.doc-line.price-base = ub.doc-line.price-rubl / bf_trn-doc.base-rate * bf_trn-doc.base-scale .

        for each ub.parts exclusive-lock where
                  ub.parts.artic     = ub.doc-line.artic  and
                  ub.parts.prod-type     = ub.doc-line.prod-type and
                  ub.parts.prod-code     = ub.doc-line.prod-code  and
                  ub.parts.out-code       = bf_trn-doc.doc-code
                  :
                  ub.parts.price-rubl = ub.doc-line.price-rubl.
                  ub.parts.price-base = ub.doc-line.price-base.
                  ub.parts.other-rubl = 0.
                  ub.parts.other-base = 0.
                  ub.parts.transport-rubl = 0.
                  ub.parts.transport-base = 0.

        end.
     end.

     for each ub.parts-add exclusive-lock where
              ub.parts-add.in-code  = bf_trn-doc.doc-code :
         delete ub.parts-add .
     end.
     find first bf_trn-doc exclusive-lock where bf_trn-doc.doc-code = p-doc-code no-error .
     bf_trn-doc.tot-other  = 0.
     bf_trn-doc.tot-transp = 0.

     run gbl/calc-trn.p (input parparentproc, input recid(bf_trn-doc)) no-error.

   /* размазывание ===================================================================================================*/
   run waitfram-show ("Переразмазыване Дополнительных расходов...." ) .
   /*
      run str/add-exp.p (input parparentproc,
                      input bf_trn-doc.doc-code ,
                      input bf_trn-doc.tot-other  * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale,
                      input bf_trn-doc.tot-transp * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) no-error.
      if error-status :error
      then do:
        run waitfram-hide in this-procedure no-error.
        undo, return error substitute ( "Ошибка при установке дополнительных расходов &1 &2.", return-value , error-status :get-message(1) ).
      end.
     */
      if available ub.add-doc then do:
        run str/addsuper.p
          (input parparentproc,
                input ub.add-doc.doc-code
              ) no-error.
        if error-status :error
        then do:
          run waitfram-hide in this-procedure no-error.
          undo, return error substitute ( "Ошибка при размазывании дополнительных расходов в учетной цене &1 Документ ДопРасхода &2 ПН &3 .",  return-value ,ub.add-doc.doc-code , bf_trn-doc.doc-code ).
        end.
      end.


 /* Корректировка задним числом */
 run waitfram-show ("Корректировка задним числом ...." ) .
 for each ub.parts no-lock where
    ub.parts.out-code = bf_trn-doc.doc-code :
    create x_parts.
    buffer-copy ub.parts to x_parts .
 end.

    run utl/trnfactb.p
        ( input parParentProc ,
          input bf_trn-doc.doc-code ,
          input table x_parts ) no-error .

          if error-status :error then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute ( "Ошибка при utl/trnfactb.p &1 &2",  return-value , error-status :get-message(1)  ).
          end.


run waitfram-hide in this-procedure no-error.