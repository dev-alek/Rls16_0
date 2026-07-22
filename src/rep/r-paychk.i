/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разброска товаров по платежам - внутри одного чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&IF "{1}" = "def" &THEN
&endif

&if "{1}" = "defvar" &then

define variable pychk_kk as integer no-undo .  /*текущая позиция в полученном списке товаров*/
define variable pychk_jj as integer no-undo .  /*текущая позиция в полученном списке товаров*/
define variable pychk_jjp as integer no-undo .  /*текущая позиция в полученном списке товаров- бензин*/
define variable pychk_jjo as integer no-undo .  /*текущая позиция в полученном списке товаров - небензин*/
define variable pychk_pay-sum as decimal no-undo .  /*сумма неразбросанного*/
DEFINE VARIABLE pychk_No-EXCH as logical no-undo. /*если все в р у б л я х то курс пересчета 1 к базовой валюте */
DEFINE VARIABLE pychk_No-EXCH-rubl as logical no-undo. /*если r-b- base  и base-code <> 0 то курс пересчета <> 1*/
DEFINE VARIABLE pychk_dop-sump as decimal No-UNDO. /*сумма неразбросанной текущей оплаты*/
DEFINE VARIABLE pychk_dop-sumg as decimal No-UNDO. /*сумма неразбросанного текцщего товара*/
DEFINE VARIABLE pychk_dop-sumk as decimal No-UNDO. /*квант товар-оплата*/
DEFINE VARIABLE pychk_exch as decimal No-UNDO. /*курс платежа*/
DEFINE VARIABLE pychk_exch-rubl as decimal No-UNDO. /*курс платежа*/
define variable pychk_pay-desk like ub.chk-doc.pay-desk no-undo init 0.
DEFINE VARIABLE pychk_classify as logical no-undo  init no.
DEFINE VARIABLE pychk_selectgood as logical no-undo init no.
define variable pychk_rv as integer no-undo .
DEFINE VARIABLE pychk_density AS DECIMAL NO-UNDO.
/*закодировано какие листы печатаем в отчете*/
DEFINE VARIABLE pychk_SHEET2 as logical no-undo.
DEFINE VARIABLE pychk_SHEET3 as logical no-undo.
DEFINE VARIABLE pychk_SHEET4 as logical no-undo.
DEFINE VARIABLE pychk_SHEET8 as logical no-undo.
define variable pychk_doc-code-r as character no-undo .
define variable pychk_doc-code-v as character no-undo .
define variable pychk_doc-code as character no-undo .
define buffer pychk_ret-doc for ub.trn-doc .
define buffer pychk_ras-doc for ub.trn-doc .


&if "{2}" = "" &then
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_dis-card for ub.dis-card.

DEFINE BUFFER b-treal-2 for treal-2.
DEFINE BUFFER b-treal-3 for treal-3.
DEFINE BUFFER b-treal-4 for treal-4.
define buffer buf_t-3 for t-3.
{ rep/real-8cr.i        treal-8 }
define buffer cp-gds-treal-8 for treal-8.
define buffer gds-treal-8 for treal-8.
define buffer cp-treal-8 for treal-8.
define buffer cli-treal-8 for treal-8.
{ rep/real-8cr.i        cp-gds-treal-8 }
{ rep/real-8cr.i        gds-treal-8 }
{ rep/real-8cr.i        cp-treal-8 }
{ rep/real-8cr.i        cli-treal-8 }


&endif


&if "{2}" = "rep" &then

DEFINE BUFFER b-treal-3 for treal-3.

&endif

&if "{2}" = "bge" &then
define variable pychk_pay-card like ub.chk-pay.pay-card no-undo .
DEFINE BUFFER b-treal-2 for treal-2.
DEFINE BUFFER b-treal-3 for treal-3.
DEFINE BUFFER b-treal-4 for treal-4.
DEFINE BUFFER b2-treal-2 for treal-2.
DEFINE BUFFER b2-treal-3 for treal-3.
DEFINE BUFFER b2-treal-4 for treal-4.
DEFINE BUFFER b3-treal-2 for treal-2.
DEFINE BUFFER b3-treal-3 for treal-3.
DEFINE BUFFER b3-treal-4 for treal-4.
define buffer buf_temp-cpa-pcep for temp-cpa-pcep.

&endif

&if "{2}" = "repzak" &then
define variable pychk_without-src-code as logical no-undo .
DEFINE BUFFER b-treal-3 for treal-3.
&endif

&endif

&if "{1}" <> "def" and "{1}" <> "defvar" &then

if first-of(CHK-pay.DOC-CODE) THEN Do:
  assign
  pychk_kk = 0 /*текущая позиция в полученном списке товаров*/
  pychk_jj = 1 /*всего записей temp-chk-gds*/
  pychk_jjp = 0 /*записей топлива*/
  pychk_jjo = 0 /*записей нетоплива*/
  pychk_pay-sum = chk-doc.netto /*сумма неразбросанного*/
  pychk_dop-sumg = 0
  .
&if "{1}" = "bge"  &then
  if p-by-pay-card-prefix  then do:
    find first buf_temp-cpa-pcep no-lock where
              buf_temp-cpa-pcep.cdpay-code = ub.chk-pay.pay-code
          AND buf_temp-cpa-pcep.curr-code = ub.chk-pay.curr-code
          AND ub.chk-pay.pay-card begins buf_temp-cpa-pcep.prefix no-error .
    if available buf_temp-cpa-pcep then
    assign
    pychk_pay-card = buf_temp-cpa-pcep.prefix
    .
    else
    assign
    pychk_pay-card = 'other':U
    .

  end.
  else do:
    assign
    pychk_pay-card = '':U
    .
  end.
&endif
 if ub.chk-doc.netto < 0 then do:
        if pychk_doc-code-r <> ub.chk-doc.out-code
        then do:
          find first pychk_ras-doc no-lock
            where pychk_ras-doc.doc-code = ub.chk-doc.out-code
            no-error .
          if not available pychk_ras-doc then do:
            message
              substitute("Отсутствует документ расхода по чеку &1"
                        , ub.chk-doc.doc-code
                        )   skip
              "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
              view-as alert-box error .
            return error .
          end.
          pychk_doc-code-r = pychk_ras-doc.doc-code.
          find first pychk_ret-doc no-lock
            where pychk_ret-doc.doc-code = pychk_ras-doc.out-code
            no-error .
          if not available pychk_ret-doc then do:
            message
              substitute("Отсутствует документ возврата по чеку &1"
                        , ub.chk-doc.doc-code
                        )   skip
              "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
              view-as alert-box error .
            return error .
          end.
          pychk_doc-code-v = pychk_ret-doc.doc-code.
        end.
        assign
          pychk_doc-code = pychk_doc-code-v
        .
      end. /*if ub.chk-doc.netto < 0 then do:*/
      else do:
        assign
          pychk_doc-code = ub.chk-doc.out-code
        .
      end.


  FOR EACH ub.chk-gds No-LOCK WHERE
           ub.chk-gds.doc-code = ub.chk-pay.doc-code
  BY ub.chk-gds.line-num:
  /*не учитваем списание по расходу*/
  pychk_density = 0.
  if ub.chk-gds.write-off-code <> ?
  and ub.chk-gds.write-off-code > 0 then NEXT.
    &if "{1}" <> "rep" and "{1}" <> "repzak" &then
    /*топливо*/
    if chk-gds.pump <> 0 then do:
      /* !!! Плотность надо брать только из документа. Перерассчитывать НЕЛЬЗЯ. Она может измениться !!! */
      find first ub.bar-code no-lock where ub.bar-code.b-code = ub.chk-gds.b-code    no-error.
      find first ub.goods    no-lock where ub.goods.gds-code  = ub.bar-code.gds-code no-error.
      find first ub.doc-line no-lock where
                ub.doc-line.doc-code  = pychk_doc-code and
                ub.doc-line.artic     = ub.goods.artic      and
                ub.doc-line.prod-type = ub.goods.prod-type  and
                ub.doc-line.prod-code = ub.goods.prod-code  no-error.
      assign pychk_density = ( if available ub.doc-line then ub.doc-line.fact-density else 0 ).
      find first temp-chk-gds where
                temp-chk-gds.b-code = chk-gds.b-code
           AND  temp-chk-gds.doc-code = chk-gds.doc-code
&if "{2}" = "pump" &then
           and temp-chk-gds.pump = chk-gds.pump
&endif
&if "{2}" = "pump-nozzle" &then
           and temp-chk-gds.pump = chk-gds.pump
           and temp-chk-gds.nozzle-code = (if chk-gds.nozzle-code = ? then 0 else chk-gds.nozzle-code)
&endif

           and temp-chk-gds.rec-type = 1 no-error.
      if available temp-chk-gds then do:
        assign
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.doc-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + ub.chk-gds.doc-qnty * pychk_density
        .
      end. /*отмена*/
      else do:
        find first temp-chk-gds use-index ijj where temp-chk-gds.jj_ = pychk_jj no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          pychk_jj = pychk_jj + 1
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          .
        end.
        else do:
          assign
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          pychk_jj = pychk_jj + 1
          .
        end.
        ASSIGN
        temp-chk-gds.doc-code = chk-gds.doc-code
        temp-chk-gds.b-code = chk-gds.b-code
        temp-chk-gds.rec-type = 1
        temp-chk-gds.gds-type = 1
        &if "{2}" = "pump" &then
        temp-chk-gds.pump = chk-gds.pump
        &endif
        &if "{2}" = "pump-nozzle" &then
        temp-chk-gds.pump = chk-gds.pump
        temp-chk-gds.nozzle-code = (if chk-gds.nozzle-code = ? then 0 else chk-gds.nozzle-code)
        &endif
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.doc-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + ub.chk-gds.doc-qnty * pychk_density
        pychk_jjp = pychk_jjp + 1
        temp-chk-gds.jjp_  = pychk_jjp
        temp-chk-gds.jjo_  = 0
        .
      end. /*неотмена*/
    end. /*топливо*/
    else do:
    &endif
    &if "{1}" = "repzak" &then
      if chk-gds.src-code = ?
      or chk-gds.src-code = "":U then do:
        message
        substitute("Обнаружено незаполненное поле ИСХОДНЫЙ КОД в чеке &1, товарная строка &2"
                  , chk-gds.doc-code
                  , chk-gds.line-num)   skip
        "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
        view-as alert-box error .
        return error .
      end.
      find first temp-chk-gds where
                temp-chk-gds.src-code = chk-gds.src-code
           AND  temp-chk-gds.doc-code = chk-gds.doc-code
           and temp-chk-gds.rec-type = 0  no-error.
      IF AVAILABLE TEMP-CHK-GDS THEN DO:
        assign
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.DOC-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + chk-gds.doc-qnty * pychk_density
        temp-chk-gds.sum-change = temp-chk-gds.sum
        .
      end. /*отмена*/
      else do:
        find first temp-chk-gds where temp-chk-gds.jj_ = pychk_jj use-index ijj no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          pychk_jj = pychk_jj + 1
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          .
        end.
        else do:
          assign
          pychk_jj = pychk_jj + 1
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          .
        end.
        ASSIGN
        temp-chk-gds.doc-code = chk-gds.doc-code
        temp-chk-gds.src-code = chk-gds.src-code
        temp-chk-gds.b-code = chk-gds.b-code
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.DOC-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + chk-gds.doc-qnty * pychk_density
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.rec-type = 0
        &if "{2}" = "pump" &then
        temp-chk-gds.pump = 0
        &endif
        &if "{2}" = "pump-nozzle" &then
        temp-chk-gds.pump = 0
        temp-chk-gds.nozzle-code = 0
        &endif

        temp-chk-gds.gds-type =
                                  &if "{1}" = "rep" &then
                                  2
                                  &else
                                  (if entry(1, chk-gds.line-type, {&delim-par}) = {&gds-office} then 3 else 2) /*gds-goods или gds-office*/
                                  &endif
        pychk_jjo = pychk_jjo + 1
        temp-chk-gds.jjp_  = 0
        temp-chk-gds.jjo_  = pychk_jjo
        .
      end. /*неотмена*/
    &else
      find first temp-chk-gds where
                temp-chk-gds.b-code = chk-gds.b-code
           AND  temp-chk-gds.doc-code = chk-gds.doc-code
        &if "{2}" = "pump" &then
           and temp-chk-gds.pump = chk-gds.pump
        &endif
        &if "{2}" = "pump-nozzle" &then
           and temp-chk-gds.pump = chk-gds.pump
           and temp-chk-gds.nozzle-code = (if chk-gds.nozzle-code = ? then 0 else chk-gds.nozzle-code)
        &endif

           and temp-chk-gds.rec-type = 0  no-error.
      IF AVAILABLE TEMP-CHK-GDS THEN DO:
        assign
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.DOC-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + chk-gds.doc-qnty * pychk_density
        temp-chk-gds.sum-change = temp-chk-gds.sum
        .
      end. /*отмена*/
      else do:
        find first temp-chk-gds where temp-chk-gds.jj_ = pychk_jj use-index ijj no-error.
        if not available temp-chk-gds then do:
          create temp-chk-gds.
          assign
          temp-chk-gds.jj_ = pychk_jj
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          pychk_jj = pychk_jj + 1
          .
        end.
        else do:
          assign
          pychk_jj = pychk_jj + 1
          temp-chk-gds.qnty2 = 0
          temp-chk-gds.qnty = 0
          temp-chk-gds.sum = 0
          temp-chk-gds.sum-change = temp-chk-gds.sum
          .
        end.
        ASSIGN
        temp-chk-gds.doc-code = chk-gds.doc-code
        temp-chk-gds.b-code = chk-gds.b-code
        temp-chk-gds.qnty = temp-chk-gds.qnty  + chk-gds.DOC-qnty
        temp-chk-gds.sum  = temp-chk-gds.sum  + chk-gds.doc-qnty * (chk-gds.price-base - chk-gds.discnt + chk-gds.price-service)
        temp-chk-gds.qnty2 = temp-chk-gds.qnty2 + chk-gds.doc-qnty * pychk_density
        temp-chk-gds.sum-change = temp-chk-gds.sum
        temp-chk-gds.rec-type = 0
        &if "{2}" = "pump" &then
        temp-chk-gds.pump = 0
        &endif
        &if "{2}" = "pump-nozzle" &then
        temp-chk-gds.pump = 0
        temp-chk-gds.nozzle-code = 0
        &endif
        temp-chk-gds.gds-type =
                                  &if "{1}" = "rep" &then
                                  2
                                  &else
                                  (if chk-doc.office = {&gds-office} then 3 else 2) /*gds-goods или gds-office*/
                                  &endif
        pychk_jjo = pychk_jjo + 1
        temp-chk-gds.jjp_  = 0
        temp-chk-gds.jjo_  = pychk_jjo
        .
      end. /*неотмена*/
    &endif
    &if "{1}" <> "rep" and "{1}" <> "repzak" &then
    end.  /*нетопливо*/
    &endif
  END. /* FOR EACH chk-gds No-LOCK WHERE */
/*  if not available temp-chk-gds then NEXT _chk-doc.*/
/*
output to ttt3.txt append.
for each temp-chk-gds no-lock where temp-chk-gds.doc-code = chk-doc.doc-code:
 export temp-chk-gds.
end.
put skip(2).
output close.
*/

end. /*if first-of CHK-pay.DOC-CODE*/

FIND FIRST ub.cash-pay No-LOCK WHERE
          ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
          ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
if available ub.cash-pay then do:
  find first temp-chk-pay where
          temp-chk-pay.line-num = chk-pay.line-num
      AND  temp-chk-pay.doc-code = chk-pay.doc-code  no-error.


  find first temp-chk-pay use-index pi where
          temp-chk-pay.line-num = chk-pay.line-num no-error.
  if not available temp-chk-pay then do:
    create temp-chk-pay.
  end.
  buffer-copy chk-pay to temp-chk-pay
  assign
  temp-chk-pay.pet-good = integer(cash-pay.atr64) * 2 + integer(cash-pay.is-cash)
  temp-chk-pay.obj-name = cash-pay.obj-name
  temp-chk-pay.is-cash  = cash-pay.is-cash
  temp-chk-pay.register = cash-pay.register
  .
end.
&scop temp temp-

if last-of(chk-pay.doc-code) then do:
/*
  output to tttp.txt.
  for each temp-chk-pay:
    export temp-chk-pay.
  end.
  output close.
  output to jj.txt append.
*/

  for each temp-chk-pay where
          temp-chk-pay.doc-code = chk-pay.doc-code
  by temp-chk-pay.pet-good descending
  by temp-chk-pay.line-num:
    assign
    pychk_dop-sump = (if v-curr-r-b = {&r-b-rubl} then {&temp}chk-pay.tot-rubl else {&temp}chk-pay.tot-base)
    pychk_exch = if pychk_No-exch then 1 else {&temp}chk-pay.tot-rubl / {&temp}chk-pay.tot-base
    pychk_exch-rubl = if pychk_No-exch-rubl then 1 else {&temp}chk-pay.tot-rubl / {&temp}chk-pay.tot-base
    .
    _repeat:
    REPEAT WHILE  abs(pychk_dop-sump) > 0 :
      if pychk_dop-sumg = 0 then do:
        assign
        pychk_kk = pychk_kk + 1
        .
        if pychk_kk >= pychk_jj then LEAVE _repeat.
        if pychk_kk <= pychk_jjp then
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = chk-doc.doc-code
            AND  temp-chk-gds.jjp_ = pychk_kk no-error .
        else
        find first temp-chk-gds where
                  temp-chk-gds.doc-code = chk-doc.doc-code
            AND  temp-chk-gds.jjo_ = pychk_kk - pychk_jjp no-error .
        if not available temp-chk-gds or temp-chk-gds.sum = 0 then do:
          NEXT _repeat.
        end.
        assign
        pychk_dop-sumg = temp-chk-gds.sum
        .
        /*
        if available temp-chk-gds then
        put unformatted "find pychk_kk=" pychk_kk  " " temp-chk-gds.b-code " " temp-chk-gds.pychk_jjp_ " " temp-chk-gds.pychk_jjo_ skip.
        else put unformatted "not find pychk_kk=" pychk_kk skip.
        */
      end. /*if pychk_dop-sumg = 0 then do:*/
      /*
      put unformatted "pay-code=" {&temp}chk-pay.pay-code " " temp-chk-gds.b-code skip  "pychk_pay-sum=" pychk_pay-sum "  pychk_dop-sump=" pychk_dop-sump " pychk_dop-sumg=" pychk_dop-sumg
      skip.
      */
      assign
      pychk_dop-sumk = min(abs(pychk_dop-sumg), abs(pychk_dop-sump))  * (if pychk_dop-sump > 0 then 1 else -1 ) /*квант*/
      pychk_pay-sum = pychk_pay-sum - pychk_dop-sumk
      pychk_dop-sump = pychk_dop-sump - pychk_dop-sumk
      pychk_dop-sumg = pychk_dop-sumg - pychk_dop-sumk
      .
      /*
      put unformatted "pychk_pay-sum=" pychk_pay-sum "  pychk_dop-sump=" pychk_dop-sump " pychk_dop-sumg=" pychk_dop-sumg " pychk_dop-sumk=" pychk_dop-sumk skip.
      */
            /*--------------------------------------родим запись таблицы----------------------------------*/
      FIND FIRST ub.bar-code No-LOCK WHERE
                ub.bar-code.b-code =  temp-chk-gds.b-code No-ERROR.
      IF NOT AVAIL ub.bar-code then NEXT _repeat.
    &if "{1}" = "rep" &then
      if x-SelectGood  = {&g-choice} then do:
        find first gds-list no-lock where
                gds-list.gds-code = ub.bar-code.gds-code no-error .
      end.
      if x-SelectGood  = {&g-all}
      or available gds-list then do:
    &endif
    &if "{1}" = "repzak" &then
        if yes then do:
    &endif

      CASE temp-chk-gds.gds-type:
    &if "{1}" <> "rep"  and "{1}" <> "repzak" &then
        WHEN 1 /*{&petrolium}*/  then do:
          if pychk_sheet2 then do:
    &if "{1}" = "bge"  &then
    /*если есть разброска по префикс то в этом месте собираем для префикса*/
            if p-by-pay-card-prefix
            and pychk_pay-card <> "other"
            then do:
              FIND FIRST b2-treal-2 No-LOCK WHERE
                        b2-treal-2.gds-code = ub.bar-code.gds-code AND
                        b2-treal-2.cpay-code = {&temp}chk-pay.pay-code AND
                        b2-treal-2.curr-code = {&temp}chk-pay.curr-code AND
                        b2-treal-2.is-pay = yes
                        AND b2-treal-2.pay-desk = pychk_pay-desk
                        AND b2-treal-2.prefix = pychk_pay-card
   &if "{2}" = "pump"  &then
                   AND b2-treal-2.pump = temp-chk-gds.pump
   &endif
   &if "{2}" = "pump-nozzle"  &then
                   AND b2-treal-2.pump = temp-chk-gds.pump
                   AND b2-treal-2.nozzle-code = temp-chk-gds.nozzle-code
    &endif

                        No-ERROR.
              IF NOT AVAIL  b2-treal-2 then do:
                FIND last b3-treal-2 No-LOCK WHERE
                          b3-treal-2.gds-code = ub.bar-code.gds-code use-index vi No-ERROR.
                run create-b2-treal-2 in this-procedure (
                                INPUT ub.bar-code.gds-code,
                                INPUT {&temp}chk-pay.pay-code,
                                INPUT {&temp}chk-pay.curr-code,
                                INPUT 0,
                                INPUT 0,
                                INPUT 0,
                                INPUT {&temp}chk-pay.obj-name,
                                INPUT yes,
                                INPUT (if avail b3-treal-2
                                      then b3-treal-2.ii + 1
                                      else 1)
                                ,INPUT  pychk_pay-desk
                                ,INPUT pychk_pay-card
    &if "{2}" = "pump"  &then
                                ,input temp-chk-gds.pump
    &endif
    &if "{2}" = "pump-nozzle"  &then
                                ,input temp-chk-gds.pump
                                ,input temp-chk-gds.nozzle-code
    &endif

                                ) no-error.
              END.
              assign
              b2-treal-2.netto = b2-treal-2.netto + pychk_dop-sumk / pychk_exch
              b2-treal-2.qnty1 = b2-treal-2.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              b2-treal-2.qnty2 = b2-treal-2.qnty2 + temp-chk-gds.qnty2 * ( pychk_dop-sumk / temp-chk-gds.sum )
              b2-treal-2.netto-rubl = b2-treal-2.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
            end.
    &endif
            FIND FIRST treal-2 No-LOCK WHERE
                      treal-2.gds-code = ub.bar-code.gds-code AND
                      treal-2.cpay-code = {&temp}chk-pay.pay-code AND
                      treal-2.curr-code = {&temp}chk-pay.curr-code AND
                      treal-2.is-pay = yes
    &if "{1}" = "bge"  &then
                      AND treal-2.pay-desk = pychk_pay-desk
    &if "{3}" = "pay-card" &then
                      AND treal-2.prefix = {&temp}chk-pay.pay-card
    &else
                      AND treal-2.prefix = ''
    &endif
    &if "{2}" = "pump" &then
                      AND treal-2.pump = temp-chk-gds.pump
    &endif

    &if "{2}" = "pump-nozzle" &then
                      AND treal-2.pump = temp-chk-gds.pump
                      AND treal-2.nozzle-code = temp-chk-gds.nozzle-code
    &endif

    &endif
                      No-ERROR.
            IF NOT AVAIL treal-2 then do:
              FIND last b-treal-2 No-LOCK WHERE
                        b-treal-2.gds-code = ub.bar-code.gds-code use-index vi No-ERROR.
              run create-treal-2 in this-procedure (
                              INPUT ub.bar-code.gds-code,
                              INPUT {&temp}chk-pay.pay-code,
                              INPUT {&temp}chk-pay.curr-code,
                              INPUT 0,
                              INPUT 0,
                              INPUT 0,
                              INPUT {&temp}chk-pay.obj-name,
                              INPUT yes,
                              INPUT (if avail b-treal-2
                                    then b-treal-2.ii + 1
                                    else 1)
    &if "{1}" = "bge"  &then
                              , INPUT  pychk_pay-desk
    &if "{3}" = "pay-card" &then
                              ,INPUT {&temp}chk-pay.pay-card
    &else
                              ,INPUT '':U
    &endif
    &if "{2}" = "pump"  &then
                              ,input temp-chk-gds.pump
    &endif
    &if "{2}" = "pump-nozzle"  &then
                              ,input temp-chk-gds.pump
                              ,input temp-chk-gds.nozzle-code
    &endif

    &endif
                              ) no-error.
            END.
            assign
            treal-2.netto = treal-2.netto + pychk_dop-sumk / pychk_exch
            treal-2.qnty1 = treal-2.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
            treal-2.qnty2 = treal-2.qnty2 + temp-chk-gds.qnty2 * ( pychk_dop-sumk / temp-chk-gds.sum )
    &if "{1}" = "bge" &then
            treal-2.netto-rubl = treal-2.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
    &endif
            .
          end.
          &if "{1}" = "" &then
          if pychk_sheet8
          and ub.chk-doc.d-card <> '':U
          then do:
            if temp-chk-pay.register > 0 then do:
              if ub.chk-doc.cli-type = ?
              or ub.chk-doc.cli-code = ?
              or ub.chk-doc.cli-type = '':U
              or ub.chk-doc.cli-code = 0 then do:
                find first buf_dis-card no-lock where
                          buf_dis-card.d-card = ub.chk-doc.d-card no-error .
                if available buf_dis-card then do:
                  assign
                  v-cli-type = buf_dis-card.cli-type
                  v-cli-code = buf_dis-card.cli-code
                  .
                end.
              end.
              else do:
                assign
                v-cli-type = ub.chk-doc.cli-type
                v-cli-code = ub.chk-doc.cli-code
                .
              end.
              FIND FIRST treal-8 No-LOCK WHERE
                        treal-8.gds-code = ub.bar-code.gds-code
                    AND treal-8.cpay-code = 0
                    AND treal-8.curr-code = 0
                    AND treal-8.cli-type = v-cli-type
                    AND treal-8.cli-code = v-cli-code  No-ERROR.
              IF NOT AVAIL treal-8 then do:
                run create-treal-8 in this-procedure (
                                  INPUT ub.bar-code.gds-code
                                ,INPUT 0
                                ,INPUT 0
                                ,INPUT v-cli-type
                                ,INPUT v-cli-code
                                ,INPUT 0
                                ,input 0
                                ) no-error.
              END.
              assign
              treal-8.netto = treal-8.netto + pychk_dop-sumk / pychk_exch
              treal-8.qnty1 = treal-8.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              treal-8.netto-rubl = treal-8.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
              FIND FIRST cp-gds-treal-8 No-LOCK WHERE
                        cp-gds-treal-8.gds-code = ub.bar-code.gds-code
                    AND cp-gds-treal-8.cpay-code = {&temp}chk-pay.pay-code
                    AND cp-gds-treal-8.curr-code = {&temp}chk-pay.curr-code
                    AND cp-gds-treal-8.cli-type = '':U
                    AND cp-gds-treal-8.cli-code = 0  No-ERROR.
              if not available cp-gds-treal-8 then do:
                run create-cp-gds-treal-8 in this-procedure (
                                  INPUT ub.bar-code.gds-code
                                ,INPUT {&temp}chk-pay.pay-code
                                ,INPUT {&temp}chk-pay.curr-code
                                ,INPUT '':U
                                ,INPUT 0
                                ,INPUT 0
                                ,input 0
                                ) no-error.
              end.
              assign
              cp-gds-treal-8.netto = cp-gds-treal-8.netto + pychk_dop-sumk / pychk_exch
              cp-gds-treal-8.qnty1 = cp-gds-treal-8.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              cp-gds-treal-8.netto-rubl = cp-gds-treal-8.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
              FIND FIRST gds-treal-8 No-LOCK WHERE
                        gds-treal-8.gds-code = ub.bar-code.gds-code
                    AND gds-treal-8.cpay-code = 0
                    AND gds-treal-8.curr-code = 0
                    AND gds-treal-8.cli-type = '':U
                    AND gds-treal-8.cli-code = 0  No-ERROR.
              if not available gds-treal-8 then do:
                run create-gds-treal-8 in this-procedure (
                                  INPUT ub.bar-code.gds-code
                                ,INPUT 0
                                ,INPUT 0
                                ,INPUT '':U
                                ,INPUT 0
                                ,INPUT 0
                                ,input 0
                                ) no-error.
              end.
              assign
              gds-treal-8.netto = gds-treal-8.netto + pychk_dop-sumk / pychk_exch
              gds-treal-8.qnty1 = gds-treal-8.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              gds-treal-8.netto-rubl = gds-treal-8.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
              FIND FIRST cp-treal-8 No-LOCK WHERE
                        cp-treal-8.gds-code = 0
                    AND cp-treal-8.cpay-code = {&temp}chk-pay.pay-code
                    AND cp-treal-8.curr-code = {&temp}chk-pay.curr-code
                    AND cp-treal-8.cli-type = '':U
                    AND cp-treal-8.cli-code = 0  No-ERROR.
              if not available cp-treal-8 then do:
                run create-cp-treal-8 in this-procedure (
                                  INPUT 0
                                ,INPUT {&temp}chk-pay.pay-code
                                ,INPUT {&temp}chk-pay.curr-code
                                ,INPUT '':U
                                ,INPUT 0
                                ,INPUT 0
                                ,input 0
                                ) no-error.
              end.
              assign
              cp-treal-8.netto = cp-treal-8.netto + pychk_dop-sumk / pychk_exch
              cp-treal-8.qnty1 = cp-treal-8.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              cp-treal-8.netto-rubl = cp-treal-8.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
              FIND FIRST cli-treal-8 No-LOCK WHERE
                        cli-treal-8.gds-code = 0
                    AND cli-treal-8.cpay-code = 0
                    AND cli-treal-8.curr-code = 0
                    AND cli-treal-8.cli-type = v-cli-type
                    AND cli-treal-8.cli-code = v-cli-code  No-ERROR.
              if not available cli-treal-8 then do:
                run create-cli-treal-8 in this-procedure (
                                  INPUT 0
                                ,INPUT 0
                                ,INPUT 0
                                ,INPUT v-cli-type
                                ,INPUT v-cli-code
                                ,INPUT 0
                                ,input 0
                                ) no-error.
              end.
              assign
              cli-treal-8.netto = cli-treal-8.netto + pychk_dop-sumk / pychk_exch
              cli-treal-8.qnty1 = cli-treal-8.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              cli-treal-8.netto-rubl = cli-treal-8.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
            end. /*if available temp-cash-pay-attr then do:*/
          end. /*if sheet8*/
          &Endif


        END.
    &endif
    &if "{1}" = "bge"  or "{1}" = "rep" or "{1}" = "repzak" &then
    /*при экспорте - по каждому товару а не по группе*/
        WHEN 2 /*{&gds-goods}*/  then do:
                if pychk_sheet3 then do:
            FIND FIRST ub.goods No-LOCK WHERE
                        ub.goods.gds-code = ub.bar-code.gds-code No-ERROR.
            IF NOT AVAIL ub.goods then NEXT _repeat.
    &if "{1}" = "repzak" &then
            FIND FIRST treal-3 No-LOCK WHERE
                      treal-3.gds-code = ub.goods.gds-code AND
                      treal-3.is-out   = (chk-doc.chk-type = integer({&rcpt-sale})) AND
                      (
                      p-without-src-code = yes
                      or
                      treal-3.src-code = temp-chk-gds.src-code) AND
                      treal-3.is-pay = {&temp}chk-pay.is-cash
                      No-ERROR.
            IF NOT AVAIL treal-3 then do:
              FIND last b-treal-3 No-LOCK WHERE
                        b-treal-3.gds-code = ub.goods.gds-code use-index vi No-ERROR.
              run create-g-treal-3 in this-procedure (
                            INPUT ub.goods.gds-code,
                            INPUT (chk-doc.chk-type = integer({&rcpt-sale})),
                            INPUT  (if p-without-src-code then "":U else temp-chk-gds.src-code),
                            INPUT 0,
                            INPUT 0,
                            INPUT {&temp}chk-pay.obj-name,
                            input {&temp}chk-pay.is-cash,
                            INPUT (if avail b-treal-3
                                    then b-treal-3.ii + 1
                                    else 1)
                                  ) no-error.
            END.
    &else
    &if "{1}" = "bge"  &then
    /*если есть разброска по чекам и префикс участвует в выгрузке то здесь собираем по префиксу*/
            if p-by-pay-card-prefix
            and pychk_pay-card <> "other"
            then do:
              FIND FIRST b2-treal-3 No-LOCK WHERE
                        b2-treal-3.gds-code = ub.goods.gds-code AND
                        b2-treal-3.cpay-code = {&temp}chk-pay.pay-code AND
                        b2-treal-3.curr-code = {&temp}chk-pay.curr-code
                        AND b2-treal-3.pay-desk = pychk_pay-desk
                        AND b2-treal-3.prefix = pychk_pay-card
                        No-ERROR.
              IF NOT AVAIL b2-treal-3 then do:
                FIND last b3-treal-3 No-LOCK WHERE
                          b3-treal-3.gds-code = ub.goods.gds-code use-index vi No-ERROR.
                run create-g-b2-treal-3 in this-procedure (
                              INPUT ub.goods.gds-code,
                              INPUT {&temp}chk-pay.pay-code,
                              INPUT {&temp}chk-pay.curr-code,
                              INPUT 0,
                              INPUT 0,
                              INPUT {&temp}chk-pay.obj-name,
                              INPUT yes,
                              INPUT (if avail b-treal-3
                                      then b3-treal-3.ii + 1
                                      else 1)
                            , INPUT  pychk_pay-desk
                            , INPUT  pychk_pay-card
                                    ) no-error.
              END.
              assign
              b2-treal-3.netto = b2-treal-3.netto + pychk_dop-sumk / pychk_exch
              b2-treal-3.qnty1 = b2-treal-3.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              b2-treal-3.netto-rubl = b2-treal-3.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
            end.
    &endif
            FIND FIRST treal-3 No-LOCK WHERE
                      treal-3.gds-code = ub.goods.gds-code AND
                      treal-3.cpay-code = {&temp}chk-pay.pay-code AND
                      treal-3.curr-code = {&temp}chk-pay.curr-code
    &if "{1}" = "bge"  &then
                      AND treal-3.pay-desk = pychk_pay-desk
    &if "{3}" = "pay-card" &then
                      AND treal-3.prefix = {&temp}chk-pay.pay-card
    &else
                      AND treal-3.prefix = '':U
    &Endif
    &endif
    &if "{1}" = "rep"  &then
                      AND treal-3.rv = pychk_rv
    &endif
                      No-ERROR.
            IF NOT AVAIL treal-3 then do:
              FIND last b-treal-3 No-LOCK WHERE
                        b-treal-3.gds-code = ub.goods.gds-code use-index vi No-ERROR.
              run create-g-treal-3  in this-procedure (
                            INPUT ub.goods.gds-code,
                            INPUT {&temp}chk-pay.pay-code,
                            INPUT {&temp}chk-pay.curr-code,
              &if "{1}" = "rep"  &then
                            INPUT pychk_rv,
              &endif
                            INPUT 0,
                            INPUT 0,
                            INPUT {&temp}chk-pay.obj-name,
                            INPUT yes,
                            INPUT (if avail b-treal-3
                                    then b-treal-3.ii + 1
                                    else 1)
    &if "{1}" = "bge"  &then
                          , INPUT  pychk_pay-desk
    &if "{3}" = "pay-card" &then
                          , INPUT  {&temp}chk-pay.pay-card
    &else
                          , INPUT  '':U
    &Endif
    &Endif
                                  ) no-error.

            END.
    &endif /*не repzak*/

            assign
            treal-3.netto = treal-3.netto + pychk_dop-sumk / pychk_exch
            treal-3.qnty1 = treal-3.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
            treal-3.netto-rubl = treal-3.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
    &if "{1}" = "repzak" &then
            treal-3.rest-qnty = treal-3.qnty1
    &endif
    &if "{1}" = "rep" &then
    /*если это запись в первый раз обрабатывается в текущей продаже то обнулим поля сумм для однйо продажи*/
            treal-3.netto-inkas = (if treal-3.inkas-code <> buf_inkas.inkas-code
                                  then 0
                                  else treal-3.netto-inkas)
            treal-3.netto-rubl-inkas = (if treal-3.inkas-code <> buf_inkas.inkas-code
                                        then 0
                                        else treal-3.netto-rubl-inkas)
            treal-3.vat-pc      = if treal-3.inkas-code <> buf_inkas.inkas-code
                                  then -1
                                  else treal-3.vat-pc
            treal-3.inkas-code        = if treal-3.inkas-code <> buf_inkas.inkas-code
                                        then buf_inkas.inkas-code
                                        else treal-3.inkas-code
            treal-3.netto-inkas = treal-3.netto-inkas + pychk_dop-sumk / pychk_exch
            treal-3.netto-rubl-inkas = treal-3.netto-rubl-inkas + pychk_dop-sumk * pychk_exch-rubl
    &endif
            .
          END.
        END.
    &else
        WHEN 2 /*{&gds-goods}*/ then do:
          if pychk_sheet3 then do:
            FIND FIRST ub.goods No-LOCK WHERE
                        ub.goods.gds-code = ub.bar-code.gds-code No-ERROR.
            IF NOT AVAIL ub.goods then NEXT _repeat.
            if pychk_classify then do:
              if pychk_selectgood then do:
                FIND FIRST buf_t-3 where
                          ub.goods.grp-name begins buf_t-3.serv-name No-ERROR.
                if not avail buf_t-3 then next _repeat .
              end.
            end.
            else dO:
              FIND FIRST t-3 where
                        ub.goods.grp-name begins t-3.serv-name No-ERROR.
              if not avail t-3 then next _repeat .
            end.
            if avail t-3  then do:
              FIND FIRST treal-3 No-LOCK WHERE
                        treal-3.grp-code = t-3.grp-code-sheet AND
                        treal-3.cpay-code = {&temp}chk-pay.pay-code AND
                        treal-3.curr-code = {&temp}chk-pay.curr-code
                        No-ERROR.
              IF NOT AVAIL treal-3 then do:
                FIND last b-treal-3 No-LOCK WHERE
                          b-treal-3.grp-code-sheet = t-3.grp-code-sheet use-index vi No-ERROR.
                run create-treal-3 in this-procedure (
                              INPUT t-3.grp-code-sheet,
                              INPUT {&temp}chk-pay.pay-code,
                              INPUT {&temp}chk-pay.curr-code,
                              INPUT 0,
                              INPUT 0,
                              INPUT {&temp}chk-pay.obj-name,
                              INPUT yes,
                              INPUT (if avail b-treal-3
                                    then b-treal-3.ii + 1
                                      else 1)
                                    ) no-error.
              END.
              assign
              treal-3.netto = treal-3.netto + pychk_dop-sumk / pychk_exch
              treal-3.qnty1 = treal-3.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              .
            end. /*if avail t-3*/
          END.
        END.
    &endif
    &if "{1}" <> "rep"  and "{1}" <> "repzak" &then
        WHEN 3 /*{&gds-office}*/ then do:
          if pychk_sheet4 then do:
    &if "{1}" = "bge" &then
    /*если есть выгрузка по префикса и это префикс участвующий в выгрузкн */
            if p-by-pay-card-prefix
            and pychk_pay-card <> "other"
            then do:
              FIND FIRST b2-treal-4 No-LOCK WHERE
                        b2-treal-4.gds-code = ub.bar-code.gds-code AND
                        b2-treal-4.cpay-code = {&temp}chk-pay.pay-code AND
                        b2-treal-4.curr-code = {&temp}chk-pay.curr-code AND
                        b2-treal-4.is-pay = yes
                        AND b2-treal-4.pay-desk = pychk_pay-desk
                        AND b2-treal-4.prefix = pychk_pay-card
                        No-ERROR.
              IF NOT AVAIL b2-treal-4 then do:
                FIND last b3-treal-4 No-LOCK WHERE
                          b3-treal-4.gds-code = ub.bar-code.gds-code use-index vi No-ERROR.
                run create-b2-treal-4 in this-procedure (
                                INPUT ub.bar-code.gds-code,
                                INPUT {&temp}chk-pay.pay-code,
                                INPUT {&temp}chk-pay.curr-code,
                                INPUT 0,
                                INPUT 0,
                                INPUT {&temp}chk-pay.obj-name,
                                INPUT yes,
                                INPUT (if avail b3-treal-4
                                      then b3-treal-4.ii + 1
                                      else 1)
                                , INPUT  pychk_pay-desk
                                , INPUT pychk_pay-card
                                ) no-error.
              END.
              assign
              b2-treal-4.netto = b2-treal-4.netto + pychk_dop-sumk / pychk_exch
              b2-treal-4.qnty1 = b2-treal-4.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
              b2-treal-4.netto-rubl = b2-treal-4.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
              .
            end.
    &endif
            FIND FIRST treal-4 No-LOCK WHERE
                      treal-4.gds-code = ub.bar-code.gds-code AND
                      treal-4.cpay-code = {&temp}chk-pay.pay-code AND
                      treal-4.curr-code = {&temp}chk-pay.curr-code AND
                      treal-4.is-pay = yes
    &if "{1}" = "bge" &then
                      AND treal-4.pay-desk = pychk_pay-desk
    &if "{3}" = "pay-card" &then
                      AND treal-4.prefix = {&temp}chk-pay.pay-card
    &else
                      AND treal-4.prefix = '':U
    &endif
    &endif
                      No-ERROR.
            IF NOT AVAIL treal-4 then do:
              FIND last b-treal-4 No-LOCK WHERE
                        b-treal-4.gds-code = ub.bar-code.gds-code use-index vi No-ERROR.
              run create-treal-4  in this-procedure (
                              INPUT ub.bar-code.gds-code,
                              INPUT {&temp}chk-pay.pay-code,
                              INPUT {&temp}chk-pay.curr-code,
                              INPUT 0,
                              INPUT 0,
                              INPUT {&temp}chk-pay.obj-name,
                              INPUT yes,
                              INPUT (if avail b-treal-4
                                    then b-treal-4.ii + 1
                                    else 1)
    &if "{1}" = "bge" &then
                              , INPUT  pychk_pay-desk
    &if "{3}" = "pay-card" &then
                              , INPUT {&temp}chk-pay.pay-card
    &else
                              , INPUT '':U
    &endif
    &endif
                              ) no-error.
            END.
            assign
            treal-4.netto = treal-4.netto + pychk_dop-sumk / pychk_exch
            treal-4.qnty1 = treal-4.qnty1 + temp-chk-gds.qnty * (pychk_dop-sumk / temp-chk-gds.sum)
    &if "{1}" = "bge" &then
            treal-4.netto-rubl = treal-4.netto-rubl + pychk_dop-sumk * pychk_exch-rubl
    &endif
            .
            END.
        END.
    &endif
      END CASE.
    &if "{1}" = "rep" or "{1}" = "repzak" &then
        end.
    &Endif


      /*--------------------записали в нужную таблицу квант товар-оплата--------------------------*/
      /*если покрылась вся сумма перейдем к следующему товару*/
      if pychk_dop-sumg <= 0 then do:
        assign
        pychk_kk = pychk_kk + 1.
        if pychk_kk >= pychk_jj then LEAVE _repeat.

        if pychk_kk <= pychk_jjp then do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = chk-doc.doc-code
              AND  temp-chk-gds.jjp_ = pychk_kk no-error .
        end.
        else do:
          find first temp-chk-gds where
                    temp-chk-gds.doc-code = chk-doc.doc-code
              AND  temp-chk-gds.jjo_ = pychk_kk - pychk_jjp no-error .
          if not available temp-chk-gds then do:
            /*
            put unformatted "niz not find pychk_kk=" pychk_kk skip.
            */
            LEAVE _repeat.
          end.
        end.
        pychk_dop-sumg = temp-chk-gds.sum.
        /*
        if available temp-chk-gds then
        put unformatted "niz find pychk_kk=" pychk_kk " "   temp-chk-gds.b-code " " temp-chk-gds.pychk_jjp_ " " temp-chk-gds.pychk_jjo_ skip.
        */
        pychk_dop-sumg = temp-chk-gds.sum.
        /*
        put unformatted "miz pychk_dop-sumg=" pychk_dop-sumg skip.
        */
      end. /*if pychk_dop-sumg <= 0 then do:*/

    END. /*REPEAT - раскидывание одной оплаты*/
  end. /*for each temp-chk-pay where
         temp-chk-pay.doc-code = chk-pay.doc-code*/
output close.
end. /*if last-of chk-pay.doc-code*/
/*
if last-of(chk-pay.doc-code) then do:
  output to treal3.txt append.
  for each treal-3 no-lock :
  export treal-3.
  end.
  put chk-doc.doc-code skip(2).
  output close.
  output to treal2.txt append.
  for each treal-2 no-lock :
  export treal-2.
  end.
  put chk-doc.doc-code skip(2).
  output close.
end.
*/


&ENDIF /* "{1}" <> "def" */



/* $Workfile$   E n d */