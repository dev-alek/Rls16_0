block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-bonus1.p $
$Archive: cus/r-bonus1.p $

Начисление и списание бонусов - расчетная часть

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/06
Author: Bakhtadze Natalya
Creation date: 09/21/06

*/

define input parameter parparentproc      as   widget-handle         no-undo .
define input parameter tog-1              as   logical               no-undo .
define input parameter tog-2              as   logical               no-undo .
define input parameter tog-3              as   logical               no-undo .
define input parameter p-schema-code      as   integer               no-undo .
define input parameter p-cdpay-code         as   integer               no-undo .
define input parameter p-curr-code        as   integer               no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-bonus1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-bonus1.p $":U .
define variable vss-description as character no-undo init "Начисление и списание бонусов - расчетная часть".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/r-page1.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i "new shared" }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

DEFINE TEMP-TABLE treal-3 no-undo
FIELD gds-code like ub.goods.gds-code
field line-num as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD price-base as decimal
FIELD qnty1 as decimal
FIELD netto as decimal /*это всегда r-b*/
FIELD ii as integer
FIELD d-card as character
field rec-type as integer
INDEX pi IS UNIQUE PRIMARY
gds-code
cpay-code
curr-code
d-card
INDEX vi
IS UNIQUE
gds-code
price-base
ii
.
{ cus/r-bon1df.i "NEW SHARED" }
{ rep/real3tmp.i bonus }
{ gbl/cur-time.i }

define variable sheets  as integer no-undo.
define variable Line as character no-undo .
run prepare-table in this-procedure .
find first temp-bon1 no-error .
if not available temp-bon1 then do:
  message
  "За выбранный период времени НЕ БЫЛО НАЧИСЛЕНИЙ И СПИСАНИЙ БОНУСОВ," skip
  "либо чеки с бонусами не были включены в продажу за заданный период"
  view-as alert-box .
  return.
end.


run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

FORM HEADER
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW STREAM PrnLibStream FRAME BottomFrame .

FOR EACH sheetf where sheetf.sheet-num > 1:
  delete sheetf.
end.
FIND FIRST sheetf where
            sheetf.sheet-num = 1 No-ERROR.
sheetf.sizes = "".

if tog-1 then DO:
  str2 = 'Оборот карты "Бонус клуб" (Товар)'.
  Put stream PrnLibStream unformatted
  reportNAme skip
  str2 skip
  str1 skip
  str3 SKIP
  Str4 SKIP
  ReportHeader SKIP.
  RUN first-line in this-procedure ( input 1) no-error.
  assign
  sheetf.Excel-Column-Lable =
  "____________" + {&comma-char} +
  "Дата"  + {&comma-char} +
  "Смена"  + {&comma-char} +
  "Чек"  + {&comma-char} +
  "№ карты"  + {&comma-char} +
  "Тип операции"  + {&comma-char} +
  "Товар/ услуга"  + {&comma-char} +
  "Кол-во (шт/л)"  + {&comma-char} +
  "Цена"  + {&comma-char} +
  "Стоимость на ТО"  + {&comma-char} +
  "Оплачено"  + {&comma-char} +
  "Начислено бонусов" + {&comma-char} +
   "Оператор"
   sheetf.sizes =
  "12"  + {&comma-char} +
  "17"  + {&comma-char} +
  "11"  + {&comma-char} +
  "20"  + {&comma-char} +
  "9"  + {&comma-char} +
  "14"  + {&comma-char} +
  "20"  + {&comma-char} +
  "10"  + {&comma-char} +
  "11"  + {&comma-char} +
  "15"  + {&comma-char} +
  "15"  + {&comma-char} +
  "15"  + {&comma-char} +
  "18"
  str2 = " "
  Sheetf.colformat = "2=@;5=@" + {&delim-par} + '':U + {&delim-par} + 'Оборот по товару'
  .
 { cus/r-bon1.i r-bon1-1 }

 PUT STREAM PrnLibStream UNFORMATTED
 {&Header-Text1}.

  run rep/extitle.p ( input 1) no-error.
  run cus/r-bon1-1.p ( input parparentproc
                    ,input p-schema-code
                    ,input p-cdpay-code
                    ,input p-curr-code
                     ) no-error.

end.
{&pageExcel}
if tog-2 then DO:
  page stream PrnLibStream .
  str2 = 'Оборот по обслуживанию (карты "Бонус клуб")'.
  Put stream PrnLibStream unformatted
  reportNAme skip
  str2 skip
  str1 skip
  str3 SKIP
  Str4 SKIP
  ReportHeader SKIP.

  run first-line in this-procedure ( input 2) no-error.
  FInd first Sheetf where
              Sheetf.sheet-num = 2 No-ERROR.
  if not avail sheetf then
  create sheetf.
  assign
  Sheetf.Sheet-num = 2.
   assign
  sheetf.Excel-Column-Lable =
  "Дата"  + {&comma-char} +
  "Смена"  + {&comma-char} +
  "Чек"  + {&comma-char} +
  "№ карты"  + {&comma-char} +
  "Товар/ услуга"  + {&comma-char} +
  "Кол-во (шт/л)"  + {&comma-char} +
  "Цена"  + {&comma-char} +
  "Стоимость на ТО"  + {&comma-char} +
  "Оплачено наличными"  + {&comma-char} +
  "Оплачено бонусами"  + {&comma-char} +
  "Начислено бонусов" + {&comma-char} +
   "Оператор"
   sheetf.sizes =
  "17"  + {&comma-char} +
  "11"  + {&comma-char} +
  "20"  + {&comma-char} +
  "9"  + {&comma-char} +
  "20"  + {&comma-char} +
  "10"  + {&comma-char} +
  "11"  + {&comma-char} +
  "15"  + {&comma-char} +
  "15"  + {&comma-char} +
  "15"  + {&comma-char} +
  "15"  + {&comma-char} +
  "18"
  str2 = " "
  Sheetf.colformat = "1=@;4=@" + {&delim-par} + '':U + {&delim-par} + 'Оборот по обслуживанию'
  .
 { cus/r-bon1.i r-bon1-2 }
 PUT STREAM PrnLibStream UNFORMATTED
{&Header-Text2}.

  run rep/extitle.p ( input 2) .

  run cus/r-bon1-2.p ( input parparentproc
                 , input p-schema-code
                 , input p-cdpay-code
                 , input p-curr-code
                 , input 2
                 ) no-error.

end.

{&pageExcel}
if tog-3 then DO:
    page stream PrnLibStream .
    str2 = 'Оборот по обслуживанию (карты "Бонус клуб")'.
    Put stream PrnLibStream unformatted
    reportNAme skip
    str2 skip
    str1 skip
    str3 SKIP
    Str4 SKIP
    ReportHeader SKIP.
    run first-line in this-procedure ( input 3) no-error.
    FInd first Sheetf where
               Sheetf.sheet-num = 3 No-ERROR.
    if not avail sheetf then
    create sheetf.
    assign
    Sheetf.Sheet-num = 3.
   assign
  sheetf.Excel-Column-Lable =
  "Дата"  + {&comma-char} +
  "Смена"  + {&comma-char} +
  "Чек"  + {&comma-char} +
  "№ карты"  + {&comma-char} +
  "Товар/ услуга"  + {&comma-char} +
  "Кол-во (шт/л)"  + {&comma-char} +
  "Цена"  + {&comma-char} +
  "Стоимость на ТО"  + {&comma-char} +
  "Оплачено наличными"  + {&comma-char} +
  "Оплачено бонусами"  + {&comma-char} +
  "Начислено бонусов" + {&comma-char} +
   "Оператор"
   sheetf.sizes =
  "17"  + {&comma-char} +
  "11"  + {&comma-char} +
  "20"  + {&comma-char} +
  "9"  + {&comma-char} +
  "20"  + {&comma-char} +
  "10"  + {&comma-char} +
  "11"  + {&comma-char} +
  "15"  + {&comma-char} +
  "15"  + {&comma-char} +
  "15"  + {&comma-char} +
  "15"  + {&comma-char} +
  "18"
  str2 = " "
  Sheetf.colformat = "1=@;4=@" + {&delim-par} + '':U + {&delim-par} + 'Оборот по обслуживанию по датам'
  .

 { cus/r-bon1.i r-bon1-3 }
 PUT STREAM PrnLibStream UNFORMATTED
{&Header-Text3}.

  run rep/extitle.p ( input 3) .

  run cus/r-bon1-2.p ( input parparentproc
                 , input p-schema-code
                 , input p-cdpay-code
                 , input p-curr-code
                 , input 3
                 ) no-error.


end.
{&closeExcel}
HIDE STREAM PrnLibStream FRAME BottomFrame .

Output stream PrnLibStream close.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).


procedure first-line :
define input parameter  vartog as integer no-undo .
PUT STREAM PrnLibStream UNFORMATTED skip.
End procedure.


procedure prepare-table :
define variable kk as integer no-undo .
DEFINE VARIABLE JJ as integer No-UNDO. /*текущая позиция в полученном списке товаров*/
DEFINE VARIABLE JJP as integer No-UNDO. /*текущая позиция в полученном списке товаров*/
DEFINE VARIABLE JJO as integer No-UNDO. /*текущая позиция в полученном списке товаров*/
DEFINE VARIABLE pay-sum as decimal No-UNDO. /*сумма неразбросанного*/
DEFINE VARIABLE dop-sump as decimal No-UNDO. /*сумма неразбросанной текущей оплаты*/
DEFINE VARIABLE dop-sumg as decimal No-UNDO. /*сумма неразбросанного текцщего товара*/
DEFINE VARIABLE dop-sumk as decimal No-UNDO. /*квант товар-оплата*/
DEFINE VARIABLE v-line-num as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-curr-code like ub.currency.curr-code no-undo init ?.
define variable v-one-curr-code as logical no-undo .
define variable v-host-code as integer no-undo .

define buffer buf_temp-bon1 for temp-bon1.
define buffer buf_inkas for ub.inkas.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-discnt for ub.chk-discnt .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_temp-bon1-gds for temp-bon1-gds.
define buffer obj-grp-op_temp-bon1 for temp-bon1. /*gds-code = 0*/
define buffer obj-grp_temp-bon1 for temp-bon1. /*gds-code = 0 op-code = 0*/
define buffer obj-op_temp-bon1 for temp-bon1. /*gds-code = 0 item-name = '':U */
define buffer obj_temp-bon1 for temp-bon1. /*gds-code = 0 op-code = 0 item-name = '':U*/
define buffer buf0_chk-pay for ub.chk-pay.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_cash-pay for ub.cash-pay.
DEFINE BUFFER buf_treal-3 for treal-3.
define buffer b3-treal-3 for treal-3.

  do
  on error undo, return error return-value
  :

    for each treal-3:
      delete treal-3.
    end.
    for each temp-bon1:
      delete temp-bon1.
    end.

    { gbl/curr-r-b.i v-curr-r-b }

    /*начисление бонусов*/
    for each obj-list no-lock,
       each buf_inkas no-lock where
          buf_inkas.obj-type = obj-list.obj-type
      and buf_inkas.obj-code = obj-list.obj-code
      and buf_inkas.shift-date >= X-date-start
      and buf_inkas.shift-date <= X-date-end:
       _discnt:
      for each buf_chk-discnt no-lock where
            buf_chk-discnt.obj-type = obj-list.obj-type
        and buf_chk-discnt.obj-code = obj-list.obj-code
        and buf_chk-discnt.out-code = buf_inkas.inkas-code
        and buf_chk-discnt.record-type = 5,
        first buf_chk-doc no-lock where
              buf_chk-doc.doc-code = buf_chk-discnt.doc-code:
         /*бонусы уже размазаны потоварно*/
        if p-schema-code > 0
        and buf_chk-discnt.discnt-type <> p-schema-code then next _discnt.
        create buf_temp-bon1.
        assign
        buf_temp-bon1.obj-type = obj-list.obj-type
        buf_temp-bon1.obj-code = obj-list.obj-code
        buf_temp-bon1.chk-date = buf_chk-doc.chk-date
        buf_temp-bon1.chk-time = buf_chk-doc.chk-time
        buf_temp-bon1.doc-code = buf_chk-doc.doc-code
        buf_temp-bon1.line-num = buf_chk-discnt.line-num
        buf_temp-bon1.discnt-id = buf_chk-discnt.discnt-id
        buf_temp-bon1.object-line-num = buf_chk-discnt.object-line-num
        buf_temp-bon1.shift-date = buf_chk-doc.shift-date
        buf_temp-bon1.shift-num = buf_chk-doc.shift-num
        buf_temp-bon1.d-card = buf_chk-discnt.d-card
        buf_temp-bon1.op-code = 2 /*начисление*/
        buf_temp-bon1.discnt-value-abs = buf_chk-discnt.discnt-value-abs
        buf_temp-bon1.cashier-psn-code = buf_chk-doc.cashier-psn-code
        buf_temp-bon1.level = 0
        .
        find first buf_chk-gds no-lock where
                  buf_chk-gds.doc-code = buf_chk-discnt.doc-code
              and buf_chk-gds.line-num = buf_chk-discnt.object-line-num no-error.
        if available buf_chk-gds then do:
          assign
          buf_temp-bon1.item-type =(if buf_chk-gds.pump > 0 then 1 else 2)
          buf_temp-bon1.src-qnty = buf_chk-gds.src-qnty
          buf_temp-bon1.src-price = buf_chk-gds.src-price
          buf_temp-bon1.src-sum  = buf_chk-gds.src-price * buf_chk-gds.src-qnty
          buf_temp-bon1.pay-sum  = (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty
          .
        end. /*if available buf_chk-gds then do:*/
        else do:
          assign
          buf_temp-bon1.src-qnty = buf_chk-discnt.object-qnty
          buf_temp-bon1.pay-sum = buf_chk-discnt.object-sum
          buf_temp-bon1.src-sum = buf_chk-discnt.object-sum
          buf_temp-bon1.src-price = buf_chk-discnt.object-sum / buf_chk-gds.src-qnty
          .
        end.
        find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds.b-code no-error.
        if available buf_bar-code then do:
          assign
          buf_temp-bon1.gds-code = buf_bar-code.gds-code.
          if buf_temp-bon1.item-type = 1 then do:
            find first buf_temp-bon1-gds no-lock where
                    buf_temp-bon1-gds.gds-code = buf_temp-bon1.gds-code no-error.
            if not available buf_temp-bon1-gds then do:
              find first buf_goods no-lock where
                        buf_goods.gds-code = buf_temp-bon1.gds-code no-error.
              create buf_temp-bon1-gds.
              assign
              buf_temp-bon1-gds.gds-code = buf_temp-bon1.gds-code
              buf_temp-bon1-gds.gds-name = (if available buf_goods
                                             then buf_goods.gds-name
                                             else substitute("Неизвестное топливо &1", buf_temp-bon1.gds-code))
              buf_temp-bon1.item-name = buf_temp-bon1-gds.gds-name
              .
            end. /*if not avaialble buf_temp-bon1-gds then do*/
            else do:
              assign
              buf_temp-bon1.item-name = buf_temp-bon1-gds.gds-name
              .
            end.
          end . /*if buf_temp-bon1.item-type = 2 then do:*/
        end. /*if available buf_bar-code then do:*/
        if buf_temp-bon1.item-type = 2 then do:
          assign
          buf_temp-bon1.item-name = "Соп. товары"
          .
        end. /*        if buf_temp-bon1.item-type = 1 then do:*/
        find first obj-grp-op_temp-bon1 where
                  obj-grp-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
              and obj-grp-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
              and obj-grp-op_temp-bon1.item-name = buf_temp-bon1.item-name
              and obj-grp-op_temp-bon1.item-type = buf_temp-bon1.item-type
              and obj-grp-op_temp-bon1.gds-code = -1
              and obj-grp-op_temp-bon1.op-code = buf_temp-bon1.op-code no-error.
        if not available obj-grp-op_temp-bon1  then do:
          create obj-grp-op_temp-bon1 .
          assign
          obj-grp-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
          obj-grp-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
          obj-grp-op_temp-bon1.item-name = buf_temp-bon1.item-name
          obj-grp-op_temp-bon1.item-type = buf_temp-bon1.item-type
          obj-grp-op_temp-bon1.gds-code = -1
          obj-grp-op_temp-bon1.op-code = buf_temp-bon1.op-code
          obj-grp-op_temp-bon1.level = 2
          .
        end.
        assign
        obj-grp-op_temp-bon1.src-qnty = obj-grp-op_temp-bon1.src-qnty + buf_chk-discnt.object-qnty
        obj-grp-op_temp-bon1.pay-sum = obj-grp-op_temp-bon1.pay-sum + buf_chk-discnt.object-sum
        obj-grp-op_temp-bon1.src-sum = obj-grp-op_temp-bon1.src-sum + buf_chk-discnt.object-sum
        obj-grp-op_temp-bon1.discnt-value-abs = obj-grp-op_temp-bon1.discnt-value-abs + buf_chk-discnt.discnt-value-abs
        .

        find first obj-grp_temp-bon1 where
                  obj-grp_temp-bon1.obj-type = buf_temp-bon1.obj-type
              and obj-grp_temp-bon1.obj-code = buf_temp-bon1.obj-code
              and obj-grp_temp-bon1.item-name = buf_temp-bon1.item-name
              and obj-grp_temp-bon1.item-type = buf_temp-bon1.item-type
              and obj-grp_temp-bon1.gds-code = -1
              and obj-grp_temp-bon1.op-code = 0 no-error.
        if not available obj-grp_temp-bon1  then do:
          create obj-grp_temp-bon1 .
          assign
          obj-grp_temp-bon1.obj-type = buf_temp-bon1.obj-type
          obj-grp_temp-bon1.obj-code = buf_temp-bon1.obj-code
          obj-grp_temp-bon1.item-name = buf_temp-bon1.item-name
          obj-grp_temp-bon1.item-type = buf_temp-bon1.item-type
          obj-grp_temp-bon1.gds-code = -1
          obj-grp_temp-bon1.op-code = 0
          obj-grp_temp-bon1.level = 3
          .
        end.
        assign
        obj-grp_temp-bon1.src-qnty = obj-grp_temp-bon1.src-qnty + buf_chk-discnt.object-qnty
        obj-grp_temp-bon1.pay-sum = obj-grp_temp-bon1.pay-sum + buf_chk-discnt.object-sum
        obj-grp_temp-bon1.src-sum = obj-grp_temp-bon1.src-sum + buf_chk-discnt.object-sum
        obj-grp_temp-bon1.discnt-value-abs = obj-grp_temp-bon1.discnt-value-abs + buf_chk-discnt.discnt-value-abs
        .

        find first obj-op_temp-bon1 where
                  obj-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
              and obj-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
              and obj-op_temp-bon1.item-type = 0
              and obj-op_temp-bon1.item-name = '':U
              and obj-op_temp-bon1.gds-code = -1
              and obj-op_temp-bon1.op-code = buf_temp-bon1.op-code no-error.
        if not available obj-op_temp-bon1  then do:
          create obj-op_temp-bon1 .
          assign
          obj-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
          obj-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
          obj-op_temp-bon1.item-name = '':U
          obj-op_temp-bon1.item-type = 0
          obj-op_temp-bon1.gds-code = -1
          obj-op_temp-bon1.op-code = buf_temp-bon1.op-code
          obj-op_temp-bon1.level = 4
          .
        end.
        assign
        obj-op_temp-bon1.src-qnty = obj-op_temp-bon1.src-qnty + buf_chk-discnt.object-qnty
        obj-op_temp-bon1.pay-sum = obj-op_temp-bon1.pay-sum + buf_chk-discnt.object-sum
        obj-op_temp-bon1.src-sum = obj-op_temp-bon1.src-sum + buf_chk-discnt.discnt-value-abs
        .
        find first obj_temp-bon1 where
                  obj_temp-bon1.obj-type = buf_temp-bon1.obj-type
              and obj_temp-bon1.obj-code = buf_temp-bon1.obj-code
              and obj_temp-bon1.item-name = '':U
              and obj_temp-bon1.item-type = 0
              and obj_temp-bon1.gds-code = -1
              and obj_temp-bon1.op-code = 0 no-error.
        if not available obj_temp-bon1  then do:
          create obj_temp-bon1 .
          assign
          obj_temp-bon1.obj-type = buf_temp-bon1.obj-type
          obj_temp-bon1.obj-code = buf_temp-bon1.obj-code
          obj_temp-bon1.item-name = '':U
          obj_temp-bon1.item-type = 0
          obj_temp-bon1.gds-code = -1
          obj_temp-bon1.op-code = 0
          obj_temp-bon1.level = 5
          .
        end.
        assign
        obj_temp-bon1.src-qnty = obj_temp-bon1.src-qnty + buf_chk-discnt.object-qnty
        obj_temp-bon1.pay-sum = obj_temp-bon1.pay-sum + buf_chk-discnt.object-sum
        obj_temp-bon1.src-sum = obj_temp-bon1.src-sum + buf_chk-discnt.object-sum
        obj_temp-bon1.discnt-value-abs = obj_temp-bon1.discnt-value-abs + buf_chk-discnt.discnt-value-abs
        .
      end. /*for each buf_chk-discnt no-lock where*/
      /*добавим недостающие*/
    end. /*for each obj-list*/
    /*списание  бонусов*/
    for each obj-list no-lock:
      for each buf_inkas no-lock where
          buf_inkas.obj-type = obj-list.obj-type
      and buf_inkas.obj-code = obj-list.obj-code
      and buf_inkas.shift-date >= X-date-start
      and buf_inkas.shift-date <= X-date-end:
        _chk-doc:
        for each buf0_chk-pay no-lock where
                buf0_chk-pay.out-code = buf_inkas.inkas-code
            and buf0_chk-pay.pay-code = p-cdpay-code
            and buf0_chk-pay.curr-code = p-curr-code,
          first buf_chk-doc no-lock where
              buf_chk-doc.doc-code = buf0_chk-pay.doc-code:
          for EACH buf_chk-pay NO-LOCK WHERE
                 buf_chk-pay.doc-code = buf_chk-doc.doc-code
          BREAK
          BY buf_CHK-pay.DOC-CODE
          BY buf_CHK-pay.LINE-NUM:
            if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
            { cus/r-paybon.i  }
            if last-of(buf_chk-pay.doc-code) then do:
               define variable v-gds-ii as integer no-undo .
               v-gds-ii = 0.
                for each buf_treal-3:
                if (buf_treal-3.cpay-code = p-cdpay-code
                and buf_treal-3.curr-code = p-curr-code) then do:
                  create buf_temp-bon1.
                  assign
                  buf_temp-bon1.obj-type = obj-list.obj-type
                  buf_temp-bon1.obj-code = obj-list.obj-code
                  buf_temp-bon1.chk-date = buf_chk-doc.chk-date
                  buf_temp-bon1.chk-time = buf_chk-doc.chk-time
                  buf_temp-bon1.doc-code = buf_chk-doc.doc-code
                  buf_temp-bon1.line-num = buf_treal-3.line-num
                  buf_temp-bon1.discnt-id = v-gds-ii
                  v-gds-ii = v-gds-ii + 1
                  buf_temp-bon1.object-line-num = buf_treal-3.ii
                  buf_temp-bon1.shift-date = buf_chk-doc.shift-date
                  buf_temp-bon1.shift-num = buf_chk-doc.shift-num
                  buf_temp-bon1.d-card = buf_treal-3.d-card
                  buf_temp-bon1.op-code = 1 /*списание*/
                  buf_temp-bon1.discnt-value-abs = 0
                  buf_temp-bon1.cashier-psn-code = buf_chk-doc.cashier-psn-code
                  buf_temp-bon1.level = 0
                  buf_temp-bon1.item-type = buf_treal-3.rec-type
                  buf_temp-bon1.src-qnty = buf_treal-3.qnty1
                  buf_temp-bon1.src-price = buf_treal-3.price-base
                  buf_temp-bon1.pay-sum  = buf_treal-3.netto
                  buf_temp-bon1.gds-code = buf_treal-3.gds-code
                  buf_temp-bon1.src-sum  = buf_temp-bon1.src-qnty * buf_temp-bon1.src-price
                  .
                  if buf_temp-bon1.item-type = 1 then do:
                    find first buf_temp-bon1-gds no-lock where
                            buf_temp-bon1-gds.gds-code = buf_temp-bon1.gds-code no-error.
                    if not available buf_temp-bon1-gds then do:
                      find first buf_goods no-lock where
                                buf_goods.gds-code = buf_temp-bon1.gds-code no-error.
                      create buf_temp-bon1-gds.
                      assign
                      buf_temp-bon1-gds.gds-code = buf_temp-bon1.gds-code
                      buf_temp-bon1-gds.gds-name = (if available buf_goods
                                                    then buf_goods.gds-name
                                                    else substitute("Неизвестное топливо &1", buf_temp-bon1.gds-code))
                      buf_temp-bon1.item-name = buf_temp-bon1-gds.gds-name
                      .
                    end. /*if not avaialble buf_temp-bon1-gds then do*/
                    else do:
                      assign
                      buf_temp-bon1.item-name = buf_temp-bon1-gds.gds-name
                      .
                    end.
                  end . /*if buf_temp-bon1.item-type = 1 then do:*/
                  if buf_temp-bon1.item-type = 2 then do:
                    assign
                    buf_temp-bon1.item-name = "Соп. товары"
                    .
                  end. /*        if buf_temp-bon1.item-type = 1 then do:*/
                  find first obj-grp-op_temp-bon1 where
                            obj-grp-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
                        and obj-grp-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
                        and obj-grp-op_temp-bon1.item-name = buf_temp-bon1.item-name
                        and obj-grp-op_temp-bon1.item-type = buf_temp-bon1.item-type
                        and obj-grp-op_temp-bon1.gds-code = -1
                        and obj-grp-op_temp-bon1.op-code = buf_temp-bon1.op-code no-error.
                  if not available obj-grp-op_temp-bon1  then do:
                    create obj-grp-op_temp-bon1 .
                    assign
                    obj-grp-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
                    obj-grp-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
                    obj-grp-op_temp-bon1.item-name = buf_temp-bon1.item-name
                    obj-grp-op_temp-bon1.item-type = buf_temp-bon1.item-type
                    obj-grp-op_temp-bon1.gds-code = -1
                    obj-grp-op_temp-bon1.op-code = buf_temp-bon1.op-code
                    obj-grp-op_temp-bon1.level = 2
                  .
                end.
                  assign
                  obj-grp-op_temp-bon1.src-qnty = obj-grp-op_temp-bon1.src-qnty + buf_temp-bon1.src-qnty
                  obj-grp-op_temp-bon1.pay-sum = obj-grp-op_temp-bon1.pay-sum + buf_temp-bon1.pay-sum
                  obj-grp-op_temp-bon1.src-sum = obj-grp-op_temp-bon1.src-sum + buf_temp-bon1.src-sum
                  .

                  find first obj-grp_temp-bon1 where
                            obj-grp_temp-bon1.obj-type = buf_temp-bon1.obj-type
                        and obj-grp_temp-bon1.obj-code = buf_temp-bon1.obj-code
                        and obj-grp_temp-bon1.item-name = buf_temp-bon1.item-name
                        and obj-grp_temp-bon1.item-type = buf_temp-bon1.item-type
                        and obj-grp_temp-bon1.gds-code = -1
                        and obj-grp_temp-bon1.op-code = 0 no-error.
                  if not available obj-grp_temp-bon1  then do:
                    create obj-grp_temp-bon1 .
                    assign
                    obj-grp_temp-bon1.obj-type = buf_temp-bon1.obj-type
                    obj-grp_temp-bon1.obj-code = buf_temp-bon1.obj-code
                    obj-grp_temp-bon1.item-name = buf_temp-bon1.item-name
                    obj-grp_temp-bon1.item-type = buf_temp-bon1.item-type
                    obj-grp_temp-bon1.gds-code = -1
                    obj-grp_temp-bon1.op-code = 0
                    obj-grp_temp-bon1.level = 3
                    .
                  end.
                  assign
                  obj-grp_temp-bon1.src-qnty = obj-grp_temp-bon1.src-qnty + buf_temp-bon1.src-qnty
                  obj-grp_temp-bon1.pay-sum = obj-grp_temp-bon1.pay-sum + buf_temp-bon1.pay-sum
                  obj-grp_temp-bon1.src-sum = obj-grp_temp-bon1.src-sum + buf_temp-bon1.src-sum
                  .

                  find first obj-op_temp-bon1 where
                            obj-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
                        and obj-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
                        and obj-op_temp-bon1.item-type = 0
                        and obj-op_temp-bon1.item-name = '':U
                        and obj-op_temp-bon1.gds-code = -1
                        and obj-op_temp-bon1.op-code = buf_temp-bon1.op-code no-error.
                  if not available obj-op_temp-bon1  then do:
                    create obj-op_temp-bon1 .
                    assign
                    obj-op_temp-bon1.obj-type = buf_temp-bon1.obj-type
                    obj-op_temp-bon1.obj-code = buf_temp-bon1.obj-code
                    obj-op_temp-bon1.item-name = '':U
                    obj-op_temp-bon1.item-type = 0
                    obj-op_temp-bon1.gds-code = -1
                    obj-op_temp-bon1.op-code = buf_temp-bon1.op-code
                    obj-op_temp-bon1.level = 4
                    .
                  end.
                  assign
                  obj-op_temp-bon1.src-qnty = obj-op_temp-bon1.src-qnty + buf_temp-bon1.src-qnty
                  obj-op_temp-bon1.pay-sum = obj-op_temp-bon1.pay-sum + buf_temp-bon1.pay-sum
                  obj-op_temp-bon1.src-sum = obj-op_temp-bon1.src-sum + buf_temp-bon1.src-sum
                  .
                  find first obj_temp-bon1 where
                            obj_temp-bon1.obj-type = buf_temp-bon1.obj-type
                        and obj_temp-bon1.obj-code = buf_temp-bon1.obj-code
                        and obj_temp-bon1.item-name = '':U
                        and obj_temp-bon1.item-type = 0
                        and obj_temp-bon1.gds-code = -1
                        and obj_temp-bon1.op-code = 0 no-error.
                  if not available obj_temp-bon1  then do:
                    create obj_temp-bon1 .
                    assign
                    obj_temp-bon1.obj-type = buf_temp-bon1.obj-type
                    obj_temp-bon1.obj-code = buf_temp-bon1.obj-code
                    obj_temp-bon1.item-name = '':U
                    obj_temp-bon1.item-type = 0
                    obj_temp-bon1.gds-code = -1
                    obj_temp-bon1.op-code = 0
                    obj_temp-bon1.level = 5
                    .
                  end.
                  assign
                  obj_temp-bon1.src-qnty = obj_temp-bon1.src-qnty + buf_temp-bon1.src-qnty
                  obj_temp-bon1.pay-sum = obj_temp-bon1.pay-sum + buf_temp-bon1.pay-sum
                  obj_temp-bon1.src-sum = obj_temp-bon1.src-sum + buf_temp-bon1.src-sum
                  .
                end. /*if (buf_chk-pay.pay-code = p-cdpay-code*/
                end. /*for each buf_treal-3:*/
            end. /*if last-of buf_chk-pay.doc-code*/
          end. /*for EACH ub.chk-pay NO-LOCK WHERE*/
        end. /*for each buf_chk-pay no-lock where*/
      end. /*for each buf_inkas no-lock where*/
    end. /*for each obj-list no-lock,*/
  end. /*doe*/
  /*
  output to jj.txt.

  for each temp-bon1:
  export temp-bon1.
  end.
  output close.
  */



end procedure. /* prepare-table */