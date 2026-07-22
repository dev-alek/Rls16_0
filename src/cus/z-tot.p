block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: z-tot.p $
$Archive: cus/z-tot.p $

Предпологаемое значение заказа

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter work-mode      as character format "X (1)" no-undo.
define input  parameter xdate-1        as date no-undo .
define input  parameter xdate-2        as date no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: z-tot.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/z-tot.p $":U .
define variable vss-description as character no-undo init "Предпологаемое значение заказа" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ gbl/cur-time.i }
{ cus/df-zakaz.i }
{ gbl/waitfram.i }
{ cmp/r-page1.i  }
my-handle = parparentproc.
{ rep/rep-bt.i  }
define  shared query br-docs for
      shar_ord-line, tmp#zakaz  scrolling.


def  stream  OutStream.
define variable g#log as logical   no-undo .
define variable l-filename as character no-undo .
define variable i as int init 2 no-undo.
define variable T as char       no-undo.
define variable gds-name  like ub.goods.gds-name no-undo.
define variable unit-base like ub.goods.unit-base no-undo.
define variable s-bar-code like ub.bar-code.b-code no-undo .
if work-mode = "M" then do:
                error-status:error = no.
                l-filename = "order.txt" .
                system-dialog get-file  l-filename
                    ask-overwrite
                    save-as
                    create-test-file
                    use-filename
                    update g#log
                    default-extension "txt" .
 if g#log Then
   output stream OutStream to value ( l-filename ) .
   Else  work-mode = "" .
End.

run waitfram-show ("Ждите...").

open query br-docs for each shar_ord-line no-lock where shar_ord-line.doc-code = loc-ord-num ,
each tmp#zakaz where
tmp#zakaz.artic = shar_ord-line.artic and
tmp#zakaz.prod-type = shar_ord-line.prod-type and
tmp#zakaz.prod-code = shar_ord-line.prod-code  .


if work-mode = "E" then do:
      Assign
      chWorkSheet2:Range  ("A1"):Value         = cur-time-print ()
      chWorkSheet2:Columns  ("A"):ColumnWidth  = 10
      chWorkSheet2:Columns  ("A"):NumberFormat = "@"
      chWorkSheet2:Range    ("A2"):Value       = "Артикул"
      chWorkSheet2:Range    ("D1"):Value       = LOC-OBJ-NAME
      chWorkSheet2:Range    ("D1"):Font:Bold   = True
      chWorkSheet2:Columns  ("B"):ColumnWidth  = 50
      chWorkSheet2:Columns  ("B"):NumberFormat = "@"

      chWorkSheet2:Range  ("B2"):Value = "Название товара"
      chWorkSheet2:Range  ("C2"):Value = "Ед.изм."
      chWorkSheet2:Range  ("D2"):Value = "Артикул поставщика"
      chWorkSheet2:Range  ("E2"):Value = "Ед.изм. контрагента"
      chWorkSheet2:Range  ("F2"):Value = "Кол-во приход по контрагенту"
      chWorkSheet2:Range  ("G2"):Value = "Кол-во расход  по контрагенту"
      chWorkSheet2:Range  ("H2"):Value = "Продаж.цены (вал.продаж) расход"
      chWorkSheet2:Range  ("I2"):Value = "Последн.цена контрагента"
      chWorkSheet2:Range  ("J2"):Value = "Кол-во остатки по контрагенту"
      chWorkSheet2:Range  ("K2"):Value = "Темп расхода с " + String (date-1) + " по " + String (date-2)
      chWorkSheet2:Range  ("L2"):Value = "Срок хранения"
      chWorkSheet2:Range  ("M2"):Value = "Мин остаток"
      chWorkSheet2:Range  ("N2"):Value = "Количество в упаковке"
      chWorkSheet2:Range  ("O2"):Value = "ЗАКАЗ кол-во"
      chWorkSheet2:Range  ("P2"):Value = "ЗАКАЗ сумма"
      chWorkSheet2:Range  ("Q2"):Value = "Расход с " + String (date-1) + " по " + String (date-2)
      chWorkSheet2:Range  ("R2"):Value = "Дней без продаж и остатков"
      chWorkSheet2:Range  ("S2"):Value = "Приход / Расход"
      chWorkSheet2:Range  ("T2"):Value = "Остаток на " + String (date-2) +  " по фирме"
      chWorkSheet2:Range  ("U2"):Value = "Приход по фирме"
      chWorkSheet2:Range  ("V2"):Value = "Внешний расход по фирме"
      chWorkSheet2:Range  ("W2"):Value = "Касса по фирме"
      chWorkSheet2:Range  ("X2"):Value = "Тип производителя"
      chWorkSheet2:Range  ("Y2"):Value = "Код производителя"
      chWorkSheet2:Range  ("Z2"):Value = "Наименование производителя"


      chWorkSheet:Range  ("A2"):Value = "Артикул"
      chWorkSheet:Range  ("B2"):Value = "Тип производителя"
      chWorkSheet:Range  ("C2"):Value = "Код производителя"
      chWorkSheet:Range  ("D2"):Value = "Наименование"
      chWorkSheet:Range  ("E2"):Value = "Артикул поставщика"
      chWorkSheet:Range  ("F2"):Value = "Цена поставщика"
      chWorkSheet:Range  ("G2"):Value = "Кол-во"                                        .
      chWorkSheet:Columns  ("A:G"):ColumnWidth = chWorkSheet2:Columns  ("A"):ColumnWidth .
      chWorkSheet:Columns  ("D"):ColumnWidth = chWorkSheet2:Columns  ("B"):ColumnWidth   .
      chWorkSheet:Columns  ("A:G"):NumberFormat = "@"  .

      chWorkSheet2:Columns  ("A:Z"):NumberFormat = "@" .
      chWorkSheet2:Range  ("A2:Z2"):HorizontalAlignment = {&xlGeneral} .
      chWorkSheet2:Range  ("A2:Z2"):VerticalAlignment   = {&xlJustify} .
      chWorkSheet2:Range  ("A2:Z2"):Interior:ColorIndex = 36           .

      chWorkSheet:Range  ("A2:G2"):HorizontalAlignment = {&xlGeneral} .
      chWorkSheet:Range  ("A2:G2"):VerticalAlignment   = {&xlJustify} .
/* Бордюр */
   Assign
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlDiagonalDown}):LineStyle = {&xlNone}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlDiagonalUp}):LineStyle   = {&xlNone}

   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeLeft}):LineStyle  = {&xlContinuous}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeLeft}):Weight     = {&xlThin}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeLeft}):ColorIndex = {&xlAutomatic}

   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeTop}):LineStyle  = {&xlContinuous}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeTop}):Weight     = {&xlThin}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeTop}):ColorIndex = {&xlAutomatic}

   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeBottom}):LineStyle  = {&xlContinuous}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeBottom}):Weight     = {&xlThin}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeBottom}):ColorIndex = {&xlAutomatic}

   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeRight}):LineStyle  = {&xlContinuous}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeRight}):Weight     = {&xlThin}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlEdgeRight}):ColorIndex = {&xlAutomatic}

   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlInsideVertical}):LineStyle  = {&xlContinuous}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlInsideVertical}):Weight     = {&xlThin}
   chWorkSheet2:Range  ("A2:Z2"):Borders ({&xlInsideVertical}):ColorIndex = {&xlAutomatic}.
      end. /*if "E"*/

 DO WHILE available TMP#zakaz :
    GET prev br-docs.
 END.

 assign
    accum-count = 0
    accum-zakaz = 0
    accum-sum-zakaz = 0 .

GET next br-docs.
DO WHILE available tmp#zakaz :
    assign
    accum-count     = accum-count     +   1
    accum-zakaz     = accum-zakaz     +   tmp#zakaz.qnty
    accum-sum-zakaz = accum-sum-zakaz +   tmp#zakaz.sum.
    if work-mode = "M" then do :
        FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = tmp#zakaz.prod-type AND
                                                                    ub.goods.prod-code = tmp#zakaz.prod-code AND
                                                                    ub.goods.artic = tmp#zakaz.artic   NO-ERROR.
        FIND FIRST ub.bar-code No-LOCK WHERE ub.goods.gds-code  = ub.bar-code.gds-code no-error .
       { gbl/gdsbcode.i ub.goods.gds-code ? s-bar-code }

       PUT stream  OutStream
                   s-bar-code
                   ","
                   trim  ( string ( tmp#zakaz.qnty , ">>>>>>>>>>9.<<<" ))
                   skip.
    End.
    if work-mode = "E" then do:
        FIND FIRST ub.currency NO-LOCK WHERE ub.currency.curr-code = tmp#zakaz.last-curr-code
        No-ERROR.
        FIND FIRST ub.clients NO-LOCK WHERE ub.clients.obj-type = tmp#zakaz.prod-type AND
                                         ub.clients.obj-code = tmp#zakaz.prod-code
        No-ERROR.
        FIND FIRST ub.goods No-LOCK WHERE ub.goods.prod-type = tmp#zakaz.prod-type AND
                                       ub.goods.prod-code = tmp#zakaz.prod-code AND
                                       ub.goods.artic     = tmp#zakaz.artic
                                      NO-ERROR.
        IF AVAILable ub.goods then
            assign
            gds-name = ub.goods.gds-name
            unit-base = ub.goods.unit-base.
        else
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "Ошибка поиска товара"
          tmp#zakaz.prod-type
          tmp#zakaz.prod-code
          tmp#zakaz.artic
          view-as alert-box error
        .


        Assign
        I = I + 1
        T = STRING (I)
        chWorkSheet2:Range  ("A" + T):Value = tmp#zakaz.artic
        chWorkSheet2:Range  ("B" + T):Value = gds-name
        chWorkSheet2:Range  ("C" + T):Value = unit-base
        chWorkSheet2:Range  ("E" + T):Value = tmp#zakaz.unit-cli
        chWorkSheet2:Range  ("F" + T):Value = tmp#zakaz.in-qnty
        chWorkSheet2:Range  ("G" + T):Value = tmp#zakaz.out-qnty
        chWorkSheet2:Range  ("H" + T):Value = tmp#zakaz.out-sum
        chWorkSheet2:Range  ("I" + T):Value = tmp#zakaz.price-cli
        chWorkSheet2:Range  ("J" + T):Value = tmp#zakaz.supp-qnty
        chWorkSheet2:Range  ("K" + T):Value = tmp#zakaz.Temp-rash
        chWorkSheet2:Range  ("L" + T):Value = tmp#zakaz.deadline
        chWorkSheet2:Range  ("M" + T):Value = tmp#zakaz.min-stock
        chWorkSheet2:Range  ("N" + T):Value = if available ub.goods then  ub.goods.qnty-cart else 0
        chWorkSheet2:Range  ("O" + T):Value = tmp#zakaz.qnty
        chWorkSheet2:Range  ("P" + T):Value = tmp#zakaz.sum
        chWorkSheet2:Range  ("Q" + T):Value = tmp#zakaz.qnty-sale
        chWorkSheet2:Range  ("R" + T):Value = tmp#zakaz.zero-day
        chWorkSheet2:Range  ("S" + T):Value = tmp#zakaz.in-qnty / tmp#zakaz.out-qnty
        chWorkSheet2:Range  ("T" + T):Value = tmp#zakaz.qnty-stk
        chWorkSheet2:Range  ("U" + T):Value = tmp#zakaz.qnty-prih
        chWorkSheet2:Range  ("V" + T):Value = tmp#zakaz.qnty-rash
        chWorkSheet2:Range  ("W" + T):Value = tmp#zakaz.qnty-kassa
        chWorkSheet2:Range  ("X" + T):Value = tmp#zakaz.prod-type
        chWorkSheet2:Range  ("Y" + T):Value = tmp#zakaz.prod-code
        chWorkSheet2:Range  ("Z" + T):Value =  ( if available ub.clients then ub.clients.obj-name else "")

       /*=======================================================================*/
        chWorkSheet:Range  ("A" + T):Value  = tmp#zakaz.artic
        chWorkSheet:Range  ("B" + T):Value  = tmp#zakaz.prod-type
        chWorkSheet:Range  ("C" + T):Value  = tmp#zakaz.prod-code
        chWorkSheet:Range  ("D" + T):Value  = gds-name
        chWorkSheet:Range  ("E" + T):Value  = tmp#zakaz.cli-art
        chWorkSheet:Range  ("F" + T):Value  = tmp#zakaz.price-cli
        chWorkSheet:Range  ("G" + T):Value  = tmp#zakaz.qnty    .
       End.
       GET next br-docs.
End.

if work-mode = "M" then do :
   Output stream OutStream close.
End.

 run waitfram-hide.