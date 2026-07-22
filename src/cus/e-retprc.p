block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-retprc.p $
$Archive: cus/e-retprc.p $

Строки чеков по чекам возврата с ценой, отличной от прайс на момент чека  для ВЗ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-retprc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/e-retprc.p $":U .
define variable vss-description as character no-undo init "Строки чеков по чекам возврата с ценой, отличной от прайс на момент чека ".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ trg/factord.i }
{ gbl/waitfram.i }


&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE SHARED VARIABLE cas-shft as logical no-undo init no.
DEFINE VARIABLE cas-num as integer no-undo.
DEFINE VARIABLE v-b-code like ub.bar-code.b-code no-undo .
DEFINE VARIABLE v-grp-name like ub.goods.grp-name no-undo .
DEFINE VARIABLE v-node-name like ub.gds-prt.f-name no-undo .
DEFINE VARIABLE v-root-name like ub.gds-prt.node-name no-undo .
DEFINE VARIABLE v-artic like ub.goods.artic no-undo .
DEFINE VARIABLE v-prod-type like ub.goods.prod-type no-undo .
DEFINE VARIABLE v-prod-code as character no-undo .
DEFINE VARIABLE v-fact-order like ub.price-list.fact-order no-undo .
DEFINE VARIABLE v-ini-fact-order like ub.price-list.fact-order no-undo .
DEFINE VARIABLE v-start-fact-order like ub.price-list.fact-order no-undo .
DEFINE VARIABLE v-end-fact-order like ub.price-list.fact-order no-undo .
DEFINE VARIABLE v-doc-time like ub.chk-doc.chk-time no-undo .
DEFINE VARIABLE v-price-sale like ub.price-list.price-sale no-undo .
DEFINE VARIABLE v-road-tax like ub.price-list.road-tax no-undo .
DEFINE VARIABLE v-excise like ub.price-list.excise no-undo .
DEFINE VARIABLE v-doc-num like ub.price-list.doc-num no-undo .
DEFINE VARIABLE v-prod-name like ub.clients.obj-name no-undo .
DEFINE VARIABLE v-chk-sum as decimal no-undo .
DEFINE VARIABLE v-price-list-sum as decimal no-undo .
DEFINE VARIABLE v-add as logical no-undo.
DEFINE VARIABLE found as logical init yes no-undo .
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE NotInc as logical no-undo .
define variable g#report-num as integer no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_clients for ub.clients.


define buffer root_gds-prt for ub.gds-prt.
{ rep/e-nobenq.i }


run no-benq(output found).
if NOT found then do:
  run waitfram-hide in this-procedure .
  message {&no-benefits} view-as alert-box.
  return.
end.
do
on error undo, return error
:
  /*найдем fact-order 1990 года*/
  assign
  Sheetf.ColFOrmat = '5=@;15=@;16=dd/mm/yyyy'
  .
  run day-begin-fact-order in this-procedure(
                                              input  01/01/1990
                                             ,output v-ini-fact-order
                                            ) .

  run waitfram-show in this-procedure ("Ждите...").
  assign
  sheetf.Excel-Column-Lable =
  "ГРУППА ТОВАРОВ"  + {&comma-char} +
  "ГЛАВНЫЙ КОД ТОВАРА"  + {&comma-char} +
  "БАР-КОД ПРИЗНАКА"  + {&comma-char} +
  "ШКАЛА/ПРИЗНАК"  + {&comma-char} +
  "АРТИКУЛ"  + {&comma-char} +
  "ПР-ЛЬ"  + {&comma-char} +
  "НАЗВАНИЕ ПРОИЗВОДИТЕЛЯ"  + {&comma-char} +
  "КОЛИЧЕСТВО"  + {&comma-char} +
  "ЦЕНА В ЧЕКЕ"  + {&comma-char} +
  "ЦЕНА ПО ПРАЙС-ЛИСТУ"  + {&comma-char} +
  "СУММА ПО ЧЕКУ" + {&comma-char} +
  "СУММА С ЦЕНОЙ ПРАЙС-ЛИСТА" + {&comma-char} +
  "РАЗНИЦА (СУММА ПО ЧЕКУ - СУММА С ЦЕНОЙ ПРАЙС-ЛИСТА))" + {&comma-char} +
  "КОД КАССИРА"  + {&comma-char} +
  "НОМЕР ЧЕКА"  + {&comma-char} +
  "ДАТА ЧЕКА"
  sheetf.sizes =
  "256"  + {&comma-char} +
  "16"  + {&comma-char} +
  "15"  + {&comma-char} +
  "256"  + {&comma-char} +
  "16"  + {&comma-char} +
  "12"  + {&comma-char} +
  "40"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "16"  + {&comma-char} +
  "25"  + {&comma-char} +
  "10"
  str1 = string(( if NotInc
                  then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )"
                  else " " ), "X(40)")
  str3 = " "
  .
  run rep/extitle.p (1) .

  FOR EACH obj-list No-LOCK:
    FIND FIRST buf_clients NO-LOCK WHERE
                buf_clients.obj-type = obj-list.obj-type AND
                buf_clients.obj-code = obj-list.obj-code No-ERROR.
    {&PutExcel}
    (IF AVAIL buf_clients
      then buf_clients.obj-name
      else ("Магазин N " + string(obj-list.obj-code))
    )
    SKIP.
  _chk-gds:
    FOR EACH buf_chk-doc No-LOCK WHERE
              buf_chk-doc.obj-type = obj-list.obj-type AND
              buf_chk-doc.obj-code = obj-list.obj-code AND
              buf_chk-doc.out-code <> ? AND
              buf_chk-doc.chk-date >= X-date-start AND
              buf_chk-doc.chk-date <= X-date-end:
      if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds.
      if buf_chk-doc.netto >= 0 then NEXT.
       /*найдем fact-order начала дня чека*/
      run day-begin-fact-order in this-procedure(
                                                  input  buf_chk-doc.chk-date
                                                  ,output v-start-fact-order
                                                ) .
      /*найдем fact-order начала дня следующего за днем чека*/
      run day-begin-fact-order in this-procedure(
                                                  input  (buf_chk-doc.chk-date + 1)
                                                  ,output v-end-fact-order
                                                ) .

      FOR EACH buf_chk-gds No-LOCK WHERE
              buf_chk-gds.doc-code = buf_chk-doc.doc-code,
          FIRST buf_bar-code No-LOCK WHERE
                buf_bar-code.b-code = buf_chk-gds.b-code:
        ACCUMULATE buf_chk-gds.doc-code (COUNT).
        assign
        v-b-code = ?
        .
        { gbl/gdsbcode.i buf_bar-code.gds-code  ? v-b-code no-error }
        /*найдем последний прайс-лист на данный товар*/
        /*сначала просмотрим все переоценки за день, когда выбит чек*/

        assign
        v-doc-time = 0
        v-fact-order = v-start-fact-order
        v-add = yes
        v-found = no
        .
        FOR EACH ub.price-list No-LOCK WHERE
                  ub.price-list.obj-type = obj-list.obj-type AND
                  ub.price-list.obj-code = obj-list.obj-code AND
                  ub.price-list.b-code = v-b-code AND
                  ub.price-list.price-type = "":U AND
                  ub.price-list.fact-order >= v-start-fact-order AND
                  ub.price-list.fact-order < v-end-fact-order use-index fact-close,
            first ub.price-doc No-LOCK where
                  ub.price-doc.doc-num = ub.price-list.doc-num :
          if v-doc-time < buf_chk-doc.chk-time and
             ub.price-doc.fact-time > buf_chk-doc.chk-time and
             v-doc-time <> 0 then do:
            assign
            v-fact-order = ub.price-list.fact-order
            v-add = no
            .
            LEAVE.
          end.
          assign
          v-doc-time = ub.price-doc.fact-time
          v-fact-order = ub.price-list.fact-order
          v-found = yes
          .
        END.
        /*если переоценка была в день чека - fact-order уже нашли и (price-list avail или v-found*/
        if NOT (FOUND and v-doc-time < buf_chk-doc.chk-time) and
            not available ub.price-list then do:
          /*переоценка была раньше чем день чека*/
          /*найдем последний прайс-лист на данный товар*/
          FIND LAST ub.price-list No-LOCK WHERE
                    ub.price-list.obj-type = obj-list.obj-type AND
                    ub.price-list.obj-code = obj-list.obj-code AND
                    ub.price-list.b-code = v-b-code AND
                    ub.price-list.fact-order < v-start-fact-order AND
                    ub.price-list.price-type = "":U use-index fact-close no-error .
          if available ub.price-list then do:
            assign
            v-fact-order = ub.price-list.fact-order
            .
          end.
          else do:
            /*ставим 1990 год*/
            assign
            v-fact-order = v-ini-fact-order
            .
          end.
        end.
        assign
        v-price-sale = ?
        v-fact-order = v-fact-order + (if v-add = no then 0 else 0.0000000001)
        .
        { gbl/bcodeprc.i
          obj-list.obj-type
          obj-list.obj-code
          buf_chk-gds.b-code
          v-b-code
          v-fact-order
          v-doc-num
          v-price-sale
          v-road-tax
          v-excise
          no-error
        }
        if v-price-sale = ? or
          v-price-sale <> buf_chk-gds.price-base then do:

          find first ub.gds-prt No-LOCK WHERE
                    ub.gds-prt.node-code = buf_bar-code.node-code no-error .
          if avail ub.gds-prt then do:
            assign
            v-node-name =  ub.gds-prt.f-name
            .
          end.
          else do:
            assign
            v-node-name ="?":U
            .
          end.

          FIND FIRST buf_goods no-lock where
                    buf_goods.gds-code = buf_bar-code.gds-code No-error.
          if avail buf_goods then do:
            assign
            v-grp-name = buf_goods.grp-name
            v-artic = buf_goods.artic
            v-prod-type = buf_goods.prod-type
            v-prod-code = string(buf_goods.prod-code)
            .
            find first root_gds-prt no-lock where
                      root_gds-prt.upper-code = buf_goods.prt-root no-error .
            if available root_gds-prt then do:
              assign
              v-root-name = root_gds-prt.node-name
              .
            end.
            else do:
              assign
              v-root-name = "?":U
              .
            end.
            find first ub.clients no-lock where
                       ub.clients.obj-type = buf_goods.prod-type AND
                       ub.clients.obj-code = buf_goods.prod-code no-error .
            if avail ub.clients then do:
              assign
              v-prod-name = string(ub.clients.obj-name, "X(40)")
              .
            end.
            else do:
              assign
              v-prod-name = "?":U
              .
            end.
          end.
          else do:
            assign
            v-grp-name = "?":U
            v-root-name = "?":U
            .
          end.
          {&PUTExcel}
          v-grp-name  {&tabulation}
          v-b-code {&tabulation}
          buf_chk-gds.b-code {&tabulation}
          (v-root-name + (if v-node-name = "":U then "":U else {&slash-char}) + v-node-name) {&tabulation}
          v-artic {&tabulation}
          v-prod-type + string(v-prod-code) {&tabulation}
          v-prod-name {&tabulation}
          buf_chk-gds.doc-qnty {&tabulation}
          buf_chk-gds.price-base {&tabulation}
          v-price-sale {&tabulation}
          buf_chk-gds.price-base * ( - buf_chk-gds.doc-qnty ) {&tabulation}
          v-price-sale * ( - buf_chk-gds.doc-qnty ) {&tabulation}
          (buf_chk-gds.price-base * ( - buf_chk-gds.doc-qnty ) - v-price-sale * ( - buf_chk-gds.doc-qnty )) {&tabulation}
          buf_chk-doc.cashier {&tabulation}
          buf_chk-doc.doc-code  {&tabulation}
          /*{&space-char} + string(buf_chk-doc.chk-date, "99/99/9999") + {&space-char}*/
          string(buf_chk-doc.chk-date, "99/99/9999")
          SKIP
          .
          assign
          v-chk-sum = v-chk-sum + buf_chk-gds.price-base * ( - buf_chk-gds.doc-qnty )
          v-price-list-sum = v-price-list-sum +
                             (if v-price-sale <> ?
                              then v-price-sale * ( - buf_chk-gds.doc-qnty )
                              else 0)
          .
        end.
        IF (ACCUM COUNT buf_chk-gds.doc-code) MODULO 50 = 0 then
        run waitfram-show in this-procedure ("Ждите..." + "Объект " + string(obj-list.obj-code) + " Обработано " +
                      string(ACCUM COUNT buf_chk-gds.doc-code) + " строк чеков").
      END. /*FOR EACH CHK-GDS*/
    END.  /*FOR EACH CHK-DOC*/
    {&PUTExcel}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    {&tabulation}
    v-chk-sum {&tabulation}
    v-price-list-sum {&tabulation}
    v-chk-sum - v-price-list-sum {&tabulation}
    {&tabulation}
    {&tabulation}

    SKIP
    .

  END. /*FOR EACH OBJ-LIST*/

  {&CloseExcel}

end.
run get-report-num  in parparentproc (output g#report-num).
run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").
run waitfram-hide in this-procedure .
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -131
g#rep-updflds = "Возврат с ценой, отличной от прайса|" + str1
.
*/