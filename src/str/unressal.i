/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура снятия резервов с товаров в продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/07/05
Author: Bakhtadze Natalya
Creation date: 10/07/05

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE UNRESERV:
define input parameter p-is-tpsi-obj  as logical no-undo .
define parameter buffer buf_Inkas for ub.inkas.
DEFINE VARIABLE vat-value like ub.doc-line.vat-pc no-undo .
DEFINE VARIABLE slt-value like ub.doc-line.slt-pc no-undo .
define variable v-is-dish as character no-undo .
define variable v-run-tpsi-line as logical no-undo .
define variable v-run-tpsi      as logical no-undo .
define variable ser-good        as logical no-undo . /*серийный ли товар*/
define variable v-msg-on as logical   no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
assign
num_rec = 0
num_rec_res = 0
num_resv = 0
num_resv_res = 0
r-artic =      "":U
r-prod-type = "":U
r-prod-code = 0
r-prt-code = 0
.
for each tt0-info:
  delete tt0-info.
end.
if rdoc-line = -1 then do:
  assign
  v-msg-on = yes
  rdoc-line = ?.
end.
_buf_sale-doc:
for each buf_sale-doc where
       buf_sale-doc.inkas-code = buf_inkas.inkas-code
   and buf_sale-doc.order > 0
by buf_sale-doc.order:
  if buf_sale-doc.doc-kind = {&sale-add-return-write-off} then NEXT _BUF_sale-doc.
  if r-or-v <> ?
  and buf_sale-doc.doc-kind <> r-or-v then NEXT _BUF_sale-doc.
  FIND FIRST buf_trn-doc WHERE buf_trn-doc.doc-code = buf_sale-doc.doc-code .
&scop sale-doc-kind buf_sale-doc.doc-kind
&scop my-message  substitute("Снятие резервов. &1.", ~{&sale-doc-name~})
{&display-message}.
  _doc-line:
  FOR EACH ub.doc-line WHERE
            ub.doc-line.doc-code = buf_sale-doc.doc-code EXCLUSIVE-LOCK,
    FIRST ub.goods WHERE
          ub.goods.artic = ub.doc-line.artic AND
          ub.goods.prod-type = ub.doc-line.prod-type AND
          ub.goods.prod-code = ub.doc-line.prod-code NO-LOCK :
      if buf_sale-doc.doc-kind = {&TDEDT_ras_vnesh_kass} then do:
        IF ub.doc-line.doc-qnty = 0 and not p-is-tpsi-obj then NEXT _doc-line.
        IF NOT (rdoc-line = ?) then do:
          if NOT recid(ub.doc-line) = rdoc-line THEN NEXT _doc-line.
          assign
          r-artic = ub.doc-line.artic
          r-prod-type = ub.doc-line.prod-type
          r-prod-code = ub.doc-line.prod-code
          .
        end.
      end.
      else do:
        IF ub.doc-line.doc-qnty = 0 then NEXT _doc-line.
        IF NOT (rdoc-line = ?)
        AND NOT recid(ub.doc-line) = rdoc-line THEN NEXT _doc-line.
     end.
      { gbl/pftxvalg.i ub.goods.gds-code {&vat-tax-code} buf_inkas.shift-date buf_inkas.host-code buf_inkas.obj-type buf_inkas.obj-code vat-value no-error}
      { gbl/pftxvalg.i ub.goods.gds-code {&slt-tax-code} buf_inkas.shift-date buf_inkas.host-code buf_inkas.obj-type buf_inkas.obj-code slt-value no-error}

      assign
      ub.doc-line.vat-pc = vat-value
      ub.doc-line.slt-pc = slt-value
      .
      IF CAN-FIND(FIRST ub.doc-pl No-LOCK WHERE
                        ub.doc-pl.out-code = ub.doc-line.doc-code AND
                        ub.doc-pl.gds-code = ub.goods.gds-code)
      then do:
          FIND FIRST ub.gds-prt NO-LOCK WHERE
                      ub.gds-prt.upper-code = ub.goods.prt-root NO-ERROR.
          cashplace = yes.
      end.
      else cashplace = no.
      IF NOT cashplace then do:
          IF CAN-FIND(FIRST ub.doc-prts No-LOCK WHERE
                            ub.doc-prts.out-code = ub.doc-line.doc-code AND
                            ub.doc-prts.gds-code = ub.goods.gds-code)
          then do:
              FIND FIRST ub.gds-prt NO-LOCK WHERE
                          ub.gds-prt.upper-code = ub.goods.prt-root NO-ERROR.
              cashparts = yes.
          end.
          else cashparts = no.
      end.
      else cashparts = no.
      FIND FIRST ub.units WHERE
                  ub.units.unit-name = ub.goods.unit-base NO-LOCK .
      if LOOKUP( {&serial}, ub.units.type ) > 0 then  do:
          assign
          ser-good = yes.
      end.
      else do:
          ser-good = no.
      end.
      IF CAN-FIND(FIRST ub.doc-fbr-gds No-LOCK WHERE
                        ub.doc-fbr-gds.out-code = ub.doc-line.doc-code AND
                        ub.doc-fbr-gds.gds-code = ub.goods.gds-code)
      then do:
        { gbl/fgdsobjt.i ub.doc-line.obj-type ub.doc-line.obj-code ub.goods.gds-code "'is-dish=request'" v-is-dish }
        if not error-status:error
        then assign
        cashfbr = integer(v-is-dish) > 0
        no-error .
      end.
      else cashfbr = no.
&scop sale-doc-kind buf_sale-doc.doc-kind
      rsrv-title = substitute("Снятие резервов. &1. Строк ", {&sale-doc-name}).
      run RSRV-line(
                    input buf_sale-doc.dir,  /*расход или возврат или тепрол*/
                    input no, /*призводство ресторана*/
                    input no, /*резервирование чужих на своем объекте - только во время закрыти расхода*/
                    input no, /*p-auto-fbr-on*/
&if "{1}" = "sale" &then
                    input no, /*rest-dish*/
                    input "":U, /*p-fbr-income-doc-code*/
&endif
                    input p-is-tpsi-obj,
                    input no,  /*p-rest-tpsi здесь не важно при снятии*/
                    input no, /*снятие*/
                    input ub.goods.gds-code,
                    input (if avail ub.gds-prt then ub.gds-prt.node-code else ?),
                    output v-run-tpsi-line,
                    buffer ub.doc-line,
                    buffer buf_trn-doc,
                    buffer buf_sale-doc
                    ) no-error.
      if error-status:error then do:
        if rdoc-line <> ?
        or v-msg-on
        then do:
          {&hide-count-message}.
          return error substitute("Ошибка при снятии резервов товаров:&1&2 &3"
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
        end.
        else next.
      end.
      assign
      ub.doc-line.price-base = cost-base
      ub.doc-line.price-rubl = cost-rubl .
      assign
      v-run-tpsi = v-run-tpsi-line or v-run-tpsi.
  END. /*for each doc-line*/
  if buf_sale-doc.doc-kind = {&TDEDT_Ras_Vnesh_kass} then do:
    {&hide-count-message}.
    if p-is-tpsi-obj
    and v-run-tpsi
    then do:
  &scop my-message  "Ждите... Идет снятие резервов ЧУЖИХ товаров"
  {&display-message}.
      run str/tpsirsrv.p (
                      input parparentproc
                      ,input p-parent-handle
                      ,input p-log-handle
                      ,input p-auto
                      ,input v-curr-r-b
                      ,input buf_inkas.inkas-code
                      ,input buf_trn-doc.host-code
                      ,input buf_trn-doc.obj-type
                      ,input buf_trn-doc.obj-code
                      ,input r-artic
                      ,input r-prod-type
                      ,input r-prod-code
                      ,input r-prt-code
                      ,input no
                      /*title окна резервирования*/
                      ,input "Снятие резеров ЧУЖИХ товаров. Расход. Строк " /*p-title*/
                      /*это продолжение счетчика начатого в salersrv.i*/
                      ,input-output num_rec_res
                      /*это счетчик попыток резервирования только ЧУЖИХ ТОВАРОВ*/
                      ,output num_rec_other
                      /*это счетчик УДАЧНЫХ попыток резервирования только ЧУЖИХ ТОВАРОВ*/
                      ,output num_rec_other_res
                      /*здесь только документ расхода продажи  - ведь возварт мы обратно не возвращаем*/
                      ,buffer buf_trn-doc
                    ) no-error .
      if error-status:error then do:
        {&hide-count-message}.
        if rdoc-line <> ? then do:
        return error substitute("Ошибка при снятии резервов ЧУЖИХ товаров:&1&2 &3"
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value ).
        end.
      end.
      {&hide-count-message}.
    end.
  end.
  assign
  num_resv = num_resv + num_rec
  num_resv_res = num_resv_res + num_rec_res
  num_rec = 0
  num_rec_res = 0
  .
  {&hide-count-message}.
  release buf_trn-doc.
end. /*for each buf_sale-doc*/
&if "{1}" = "sale" &then
if num_resv = 0 then.
/*
message
"Не найдено товара для снятия резервов".
*/
else do:
  if num_resv_res = num_resv and  num_resv > 0 and r-qnty = ? then do:
&scop my-message "Снятие резервов прошло успешно"
{&display-message-laud}.
  end.


  else do:
    if r-qnty = ? then do:
&scop my-message  substitute("Из &1 позиций для снятия резервов,&2" + ~
                        "успешно сняты резервы с &3"                 ~
                        , num_resv                                   ~
                        , {&new-line}                                ~
                        , num_resv_res)
{&display-message-laud}.

    end.
  end.
end.
&endif

&if "{1}" = "purgsale" &then
if num_resv_res = num_resv and  num_resv > 0 and r-qnty = ? then
return.
else
return error.
&endif

END PROCEDURE.

/* $Workfile$ e n d */