block-level on error undo, throw.
/*

$Revision: 18022dc3b171, 1949, rls $
$Author: SSlivenko $
$Date: Fri Jul 26 11:38:58 2019 +0300 $
$Workfile: exclwchk.p $
$Archive: str/exclwchk.p $

Исключения чека МЦ из незакрытой продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/14/08
Author: Bakhtadze Natalya
Creation date: 12/14/08

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-r-b as character no-undo .
define parameter buffer X_chk-doc for ub.chk-doc.
define variable vss-revision    as character no-undo init "$Revision: 18022dc3b171, 1949, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jul 26 11:38:58 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exclwchk.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/exclwchk.p $":U .
define variable vss-description as character no-undo init "Исключения чека МЦ из незакрытой продажи".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/library.i }
{ str/clc-exc.i }
{ gbl/waitfram.i }
/*поскольку сюда попадаем только из продажи то можем звять определение шареной таблицы для ТПСИ док-тов*/
{ str/lib-def.i }
{ str/trdcalib.i }
{ str/inkas-ps.i }
{ str/saledoc.i }
{ str/inc-salf.i }
{ str/lib-trn.i }
{ ref/gds-attr.i }

&glob display-message  run waitfram-show in this-procedure (~{&MY-MESSAGE~} )

&glob display-message-laud  MESSAGE ~{&MY-MESSAGE~}

&glob display-count-message run waitfram-show in this-procedure (input ~{&MY-count-MESSAGE~} )

&glob hide-count-message  run waitfram-hide in this-procedure

define buffer for-doc for ub.chk-doc.
/*вспомогательная*/
define variable temp-qnty like ub.gds-dtl.fact-qnty no-undo .
/*кол-во чеков в продаже*/
define variable chk-amount as integer.
/*кол-во строк чеков в продаже*/
define variable gds-amount as integer.
/*кол-во товаров в продаже расход*/
define variable line-out as integer.
/*кол-во признаков в продаже расход*/
define variable dtl-out as integer.
/*кол-во товаров в продаже возврат*/
define variable line-ret as integer.
/*кол-во признаков в продаже возврат*/
define variable dtl-ret as integer.
/*кол-во нф чеков в продаже*/
define variable nf-chk-amount as integer.
/*кол-во строк нф чеков в продаже*/
define variable nf-gds-amount as integer.
define variable add-nf-amount as integer   no-undo .
define variable add-NF-gds-amount as integer   no-undo .
define variable num_resv as integer no-undo.
/*количество зарезервированных позиций*/
define variable num_resv_res as integer no-undo.
/*количество удачно зарезервированных позиций*/



define variable v-add as logical no-undo .
define variable dtrg as integer no-undo . /*счетчик документов по которым резервируем одну строку временной таблицы*/

define variable v-curr-r-b as character no-undo .

/*общие определения для резервирования в продаже и исключения чеков - */
{ str/salersrv.i def }

define variable v-base-rate like ub.trn-doc.base-rate no-undo .
define variable v-base-scale like ub.trn-doc.base-scale no-undo .


define variable v-host-code like ub.sysconf.host-code no-undo .
define variable p-filter-rus as character no-undo .
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-doc-attr for ub.chk-doc-attr.
define buffer buf_c-chk-doc for ub.c-chk-doc.
define buffer buf_c-chk-gds for ub.c-chk-gds.
define buffer buf_c-chk-pay for ub.c-chk-pay.
define buffer buf_c-chk-doc-attr for ub.c-chk-doc-attr.
define buffer buf_sale-doc for ub.sale-doc.
define buffer tpsi_sale-doc for ub.sale-doc.
define buffer dop_trn-doc for ub.trn-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf0_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.

do
on error undo, return error return-value
:

  FIND FIRST ub.inkas WHERE ub.inkas.inkas-code = X_chk-doc.out-code NO-LOCK NO-ERROR.
  if not avail ub.inkas then do:
      message
      substitute("Ошибка! Чек &1 привязан к отсутствующему отчету о продаже!", X_chk-doc.doc-code)
      view-as alert-box ERROR.
      return error.
  end.

  { gbl/hostcode.i inkas.obj-type inkas.obj-code v-host-code }

    run get-inkas-ps in this-procedure (
                                        buffer inkas
                                      , output chk-amount
                                      , output gds-amount
                                      , output line-out
                                      , output dtl-out
                                      , output line-ret
                                      , output dtl-ret
                                      , output nf-chk-amount
                                      , output nf-gds-amount
                                      , output p-filter-rus
                                      ).
  FIND FIRST buf0_trn-doc exclusive-lock WHERE
           buf0_trn-doc.doc-code = X_chk-doc.out-code no-wait NO-ERROR.
  if not avail buf0_trn-doc then do:
      message
      substitute("Не найдена или не занята накладная &1!", X_chk-doc.out-code)  view-as alert-box ERROR.
      undo, return error.
  end.
  { gbl/curr-r-b.i
    v-curr-r-b
  }

  for each buf_sale-doc where
          buf_Sale-doc.inkas-code = inkas.inkas-code
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    buf_sale-doc.chk-doc-code = '':U.
  end.
  /*снятие резервов*/
  f-del:
  DO on ERROR undo, return error
  on STOP undo, return error :
  run waitfram-show in this-procedure ( substitute("Освобождаю чек МЦ &1...", X_chk-doc.doc-code)).

  FOR  EACH buf_chk-pay WHERE
            buf_chk-pay.doc-code = X_chk-doc.doc-code
  BREAK
  BY buf_chk-pay.doc-code
  BY buf_chk-pay.pay-code
  BY buf_chk-pay.curr-code
  on ERROR undo, return error error-status:get-message(1):
    find first buf_inkas-pay-wth where
              buf_inkas-pay-wth.inkas-code = X_chk-doc.out-code
          and buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
          and buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
          and buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
          and buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
          and buf_inkas-pay-wth.pay-desk = X_chk-doc.pay-desk
          and buf_inkas-pay-wth.cashier = X_chk-doc.cashier
          and buf_inkas-pay-wth.chk-type = X_chk-doc.chk-type no-error.
    if not available  buf_inkas-pay-wth then do:
      create buf_inkas-pay-wth.
      assign
      buf_inkas-pay-wth.inkas-code = X_chk-doc.out-code
      buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
      buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
      buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
      buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
      buf_inkas-pay-wth.pay-desk = X_chk-doc.pay-desk
      buf_inkas-pay-wth.cashier = X_chk-doc.cashier
      buf_inkas-pay-wth.chk-type = X_chk-doc.chk-type
      buf_inkas-pay-wth.par-val = buf_chk-pay.par-val
      .
    end.
    assign
    buf_inkas-pay-wth.tot-sum = buf_inkas-pay-wth.tot-sum - buf_chk-pay.tot-sum
    buf_inkas-pay-wth.tot-base = buf_inkas-pay-wth.tot-base - buf_chk-pay.tot-base
    buf_inkas-pay-wth.tot-rubl = buf_inkas-pay-wth.tot-rubl - buf_chk-pay.tot-rubl
    buf_inkas-pay-wth.doc-qnty = buf_inkas-pay-wth.doc-qnty - buf_chk-pay.doc-qnty
    buf_inkas-pay-wth.tot-lines = buf_inkas-pay-wth.tot-lines - 1
    .
    if buf_inkas-pay-wth.tot-sum = 0 then delete buf_inkas-pay-wth.
    buf_chk-pay.out-code = ? .
  end.  /*конец обработки оплат*/
  FOR EACH buf_chk-doc-attr where buf_chk-doc-attr.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
  :
      buf_chk-doc-attr.out-code = ?.
  END.
  /*история*/
  for each buf_c-chk-doc where
          buf_c-chk-doc.doc-code = X_chk-doc.doc-code
   on error undo, return error error-status:get-message(1) :
    assign
    buf_c-chk-doc.out-code = ?
    .
  end.
  for each buf_c-chk-pay where
          buf_c-chk-pay.doc-code = X_chk-doc.doc-code
   on error undo, return error error-status:get-message(1)
          :
    assign
    buf_c-chk-pay.out-code = ?
    .
  end.
  for each buf_c-chk-doc-attr where
          buf_c-chk-doc-attr.doc-code = X_chk-doc.doc-code
  on error undo, return error error-status:get-message(1)
          :
    assign
    buf_c-chk-doc-attr.out-code = ?
    .
  end.
  run waitfram-show in this-procedure ( substitute("Пересчитываю общие суммы по накладным после исключения чека &1...", X_chk-doc.doc-code)).
  assign
  inkas.num-chk = inkas.num-chk  - 1
  inkas.num-chk-nf = inkas.num-chk-nf - 1
  .
  assign
  inkas.PS = set-inkas-ps(input inkas.ps
                        , input chk-amount
                        , input gds-amount
                        , input line-out
                        , input dtl-out
                        , input line-ret
                        , input dtl-ret
                        , input inkas.num-chk
                        , input inkas.num-chk-nf
                        , input p-filter-rus
                        )
  .
  X_chk-doc.out-code = ? .
  run waitfram-hide in this-procedure .
END. /*DO TRANSACTION*/
end.