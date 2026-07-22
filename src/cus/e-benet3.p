block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-benet3.p $
$Archive: cus/e-benet3.p $

Отчет по процентам скидки реализованного товара

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-benet3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/e-benet3.p $":U .
define variable vss-description as character no-undo init "Отчет по процентам скидки реализованного товара".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ rep/f-fdec.i }
{ gbl/waitfram.i }
{ gbl/prn-lib.i }

&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."

define variable     NotInc          as  log     no-undo.

define variable Line                as      char    no-undo.
define variable date_string     as      char    no-undo.

define var cas-num as integer no-undo.
define SHARED var method as character no-undo.
def SHARED var cas-shft as logical no-undo init no.
define variable found as logical init yes no-undo.
define variable multi-obj as logical no-undo.
define variable dopd as decimal no-undo.
define variable g#report-num as integer no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_clients for ub.clients.

{ rep/e-nobenq.i }

def temp-table benefits no-undo
/*    Field obj-type like chk-doc.obj-type*/
    field obj-code like ub.chk-doc.obj-code
    Field gds-code like ub.goods.gds-code
    Field artic like ub.goods.artic
/*  field gds-name like goods.gds-name*/
    /*% скидки с точностью до целых как обговорено с ПИКАЛОВОЙ*/
    field dcpc as decimal format "->9%"
    field price-base like ub.chk-gds.price-base
    field price-netto like ub.chk-gds.price-base
    field qnty like ub.gds-dtl.fact-qnty
    field discnt    like ub.chk-gds.discnt
    INDEX pi IS PRIMARY obj-code dcpc gds-code price-base
    INDEX i-artic obj-code dcpc artic price-base
    .

FOR EACH benefits:
    delete benefits.
END.
run waitfram-show in this-procedure ("Ждите...").

run no-benqi(OUTPUT Notinc).
FIND obj-list No-LOCK NO-ERROR.

IF NOT AVAIL obj-list then do:
  multi-obj = yes.
end.
FOR EACH obj-list No-LOCK:
_chk-gds:
  FOR EACH buf_chk-doc No-LOCK WHERE
           buf_chk-doc.obj-type = obj-list.obj-type AND
           buf_chk-doc.obj-code = obj-list.obj-code AND
           buf_chk-doc.out-code <> ? AND
           buf_chk-doc.chk-date >= X-date-start AND
           buf_chk-doc.chk-date <= X-date-end,
      EACH buf_chk-gds No-LOCK WHERE
           buf_chk-gds.doc-code = buf_chk-doc.doc-code,
      FIRST buf_bar-code No-LOCK WHERE
            buf_bar-code.b-code = buf_chk-gds.b-code:
    if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds.
    /*списание по расходу не включаем*/
    if buf_chk-gds.write-off-code <> ?
    and buf_chk-gds.write-off-code > 0 then NEXT _chk-gds.
    ACCUMULATE buf_chk-gds.doc-code (COUNT).
    IF (ACCUM COUNT buf_chk-gds.doc-code) MODULO 50 = 0 then
    run waitfram-show in this-procedure ("Ждите..." + "Обработано " +
                   string(ACCUM COUNT buf_chk-gds.doc-code) + " строк чеков").
    IF x-SelectGood = {&g-choice} then do:
      FIND FIRST buf_goods No-LOCK WHERE buf_goods.gds-code = buf_bar-code.gds-code NO-ERROR.
      IF NOT CAN-FIND(first gds-list WHERE
                            gds-list.artic = buf_goods.artic AND
                            gds-list.prod-type  = buf_goods.prod-type AND
                            gds-list.prod-code = buf_goods.prod-code
                            ) then
                            NEXT _chk-gds.
    end.
    dopd = ROUND(buf_chk-gds.discnt / buf_chk-gds.price-base * 100, 0).
    if dopd = 0 then NEXT _chk-gds.
    FIND FIRST benefits WHERE
               benefits.gds-code = buf_bar-code.gds-code AND
               benefits.dcpc = dopd AND
               benefits.price-base = buf_chk-gds.price-base AND
               benefits.obj-code = buf_chk-doc.obj-code No-ERROR.
    IF NOT avail benefits then do:
      FIND FIRST buf_goods NO-LOCK WHERE
                 buf_goods.gds-code = buf_bar-code.gds-code NO-ERROR.
      create benefits.
      assign
      benefits.artic = buf_goods.artic
      benefits.gds-code = buf_bar-code.gds-code
      benefits.dcpc =  dopd
      benefits.price-base = buf_chk-gds.price-base
      benefits.discnt = benefits.dcpc * benefits.price-base / 100
      benefits.price-netto = benefits.price-base - benefits.discnt
/*      benefits.obj-type = buf_chk-doc.obj-type*/
      benefits.obj-code = buf_chk-doc.obj-code
      .
    end.
    assign
    benefits.qnty = benefits.qnty + buf_chk-gds.doc-qnty
    .
  END.  /*FOR EACH CHK-DOC*/

END. /*FOR EACH OBJ-LIST*/

 run waitfram-show in this-procedure ("Ждите... Вывод информации...").
assign
sheetf.Excel-Column-Lable =
"Артикул" + {&comma-char} +
"Количество"  + {&comma-char} +
"Цена исх"  + {&comma-char} +
"Цена со скидкой"  + {&comma-char} +
"Сумма скидки"
sheetf.sizes =
"16" + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"  + {&comma-char} +
"15"
str1 = string(( if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " " ), "X(40)")
str3 = " "
.
/*output stream ForExcel to value( string( session:temp-directory +
                            {&DF_Name} + string( g#report-num ) + ".txt" ) )      .
*/
run rep/extitle.p (1).
FOR EACH benefits NO-LOCK
    BREAK
    BY BENEFITS.OBJ-CODE
    BY BENEFITS.DCPC
    BY BENEFITS.ARTIC
    BY BENEFITS.PRICE-BASE:
    IF FIRST-OF(BENEFITS.OBj-CODE) THEN DO:
      FIND FIRST buf_clients NO-LOCK WHERE
                 buf_clients.obj-type = {&shop} AND
                 buf_clients.obj-code = benefits.obj-code No-ERROR.
      {&PutExcel}
      (IF AVAIL buf_clients
       then buf_clients.obj-name
       else ("Магазин N " + string(benefits.obj-code))
      )
      SKIP.
    END.
    IF FIRST-OF(BENEFITS.dcpc) THEN DO:
      {&PutExcel}
      ("Скидка " + string(BENEFITS.dcpc, "->9%"))
      SKIP.
    END.
    {&PutExcel}
    BENEFITS.artic {&tabulation}
    BENEFITS.qnty  {&tabulation}
    BENEFITS.PRICE-BASE {&tabulation}
    BENEFITS.PRICE-NETTO {&tabulation}
    BENEFITS.DISCNT
    SKIP.
    ACCUMULATE
    BENEFITS.qnty (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc)
    (BENEFITS.qnty * BENEFITS.price-base) (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc)
    (BENEFITS.qnty * BENEFITS.price-netto) (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc)
    (BENEFITS.qnty * BENEFITS.discnt) (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc)
    .
    IF LAST-OF(BENEFITS.dcpc) THEN DO:
      {&PutExcel}
      ("ИТОГО: (" + string(BENEFITS.dcpc, "->9%") + ")") {&tabulation}
      ACCUM TOTAL BY BENEFITS.dcpc BENEFITS.qnty {&tabulation}
      ACCUM TOTAL BY BENEFITS.dcpc (BENEFITS.qnty * BENEFITS.PRICE-BASE) {&tabulation}
      ACCUM TOTAL BY BENEFITS.dcpc (BENEFITS.qnty * BENEFITS.PRICE-NETTo) {&tabulation}
      ACCUM TOTAL BY BENEFITS.dcpc (BENEFITS.qnty * BENEFITS.DISCNT)
      SKIP.
    END.
    IF Multi-obj AND LAST-OF(BENEFITS.OBJ-CODE) THEN DO:
      {&PutExcel}
      ("ИТОГО ПО МАГАЗИНУ " + string(BENEFITS.OBJ-CODE)) {&tabulation}
      ACCUM TOTAL BY BENEFITS.obj-code BENEFITS.qnty {&tabulation}
      ACCUM TOTAL BY BENEFITS.obj-code (BENEFITS.qnty * BENEFITS.PRICE-BASE) {&tabulation}
      ACCUM TOTAL BY BENEFITS.obj-code (BENEFITS.qnty * BENEFITS.PRICE-NETTo) {&tabulation}
      ACCUM TOTAL BY BENEFITS.obj-code (BENEFITS.qnty * BENEFITS.DISCNT)
      SKIP.
    END.
    IF LAST(BENEFITS.OBJ-CODE) THEN DO:
      {&PutExcel}
      "ИТОГО ПО ВСЕМ " {&tabulation}
      ACCUM TOTAL BENEFITS.qnty {&tabulation}
      ACCUM TOTAL (BENEFITS.qnty * BENEFITS.PRICE-BASE) {&tabulation}
      ACCUM TOTAL (BENEFITS.qnty * BENEFITS.PRICE-NETTo) {&tabulation}
      ACCUM TOTAL (BENEFITS.qnty * BENEFITS.DISCNT)
      SKIP.
    END.
END. /*FOR EACH benefits*/
{&CloseExcel}
run get-report-num in my-handle (output g#report-num).
run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").

/*
assign
g#rep-tblname = ""
g#rep-tblrid = -131
g#rep-updflds = "Отчет по процентам скидки реализованного товара|" +
               str1
.
*/
run waitfram-hide in this-procedure .