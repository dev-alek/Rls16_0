block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-kar3.p $
$Archive: cus/e-kar3.p $

Отчет по процентам скидки чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/09/05
Author: Bakhtadze Natalya
Creation date: 10/09/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-kar3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/e-kar3.p $":U .
define variable vss-description as character no-undo init "Отчет по процентам скидки реализованного товара".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def " " my-handle }
{ gbl/prn-lib.i }

&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."

define variable     NotInc          as  log     no-undo.

define variable Line                as      char    no-undo.
define variable date_string     as      char    no-undo.


define var cas-num as integer no-undo.
define SHARED var method as character no-undo.
define variable v-dopd as decimal no-undo .
def SHARED var cas-shft as logical no-undo init no.

define variable found as logical init yes no-undo.
define variable multi-obj as logical no-undo.
define variable g#log as logical no-undo .

define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define variable p-XL-delim as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_clients for ub.clients.


{ gbl/getcntxt.i get " " my-handle }
{ gbl/getsect.i def }

{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.

{ rep/e-nobenq.i }
define temp-table benefits no-undo
/*    Field obj-type like chk-doc.obj-type*/
    field obj-code like ub.chk-doc.obj-code
    /*% скидки с точностью до целых */
    field dcpc as decimal format "->9%"
    field tot-doc like ub.inkas.tot-doc
    field netto like ub.inkas.netto
    field num-chk like ub.inkas.num-chk
    field discnt    like ub.inkas.discnt
    INDEX pi IS PRIMARY obj-code dcpc
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
           buf_chk-doc.chk-date <= X-date-end:
    if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds.
    ACCUMULATE buf_chk-doc.doc-code (COUNT).
    IF (ACCUM COUNT buf_chk-doc.doc-code) MODULO 50 = 0 then
    run waitfram-show in this-procedure ("Ждите..." + "Обработано " +
                   string(ACCUM COUNT buf_chk-doc.doc-code) + " чеков").
    if lookup(string(buf_chk-doc.chk-type), {&no-docum-receipt-codes}) > 0 then next _chk-gds.
    v-dopd = (if buf_chk-doc.tot-doc = 0
              then 100
              else ROUND(buf_chk-doc.discnt / buf_chk-doc.tot-doc * 100, 0)).
    FIND FIRST benefits WHERE
               benefits.dcpc = v-dopd  No-ERROR.
    IF NOT avail benefits then do:
      create benefits.
      assign
      benefits.dcpc =  v-dopd
      benefits.tot-doc = buf_chk-doc.tot-doc
      benefits.discnt = buf_chk-doc.discnt
      benefits.netto = buf_chk-doc.netto
/*      benefits.obj-type = buf_chk-doc.obj-type*/
      benefits.obj-code = buf_chk-doc.obj-code
      .
    end.
    assign
    benefits.num-chk = benefits.num-chk + 1
    .
  END.  /*FOR EACH CHK-DOC*/

END. /*FOR EACH OBJ-LIST*/

run waitfram-hide in this-procedure .

{ cmp/open-exp.i stream PrnLibStream }
PUT stream PrnLibStream UNFORMATTED
space(20)
"Отчет по процентам скидки чеков" skip
 space(23) str1 skip(0)
 space(20) ( if NotInc then "( сформирован НЕ ПО ВСЕМ ЧЕКАМ )" else " " ) format "x(40)" skip.
PUT Stream PrnLibStream UNFORMATTED
"Число чеков" p-XL-delim
"Сумма брутто" p-XL-delim
"Сумма нетто" p-XL-delim
"Сумма скидки"
SKIP.

FOR EACH benefits NO-LOCK
    BREAK
    BY BENEFITS.OBJ-CODE
    BY BENEFITS.DCPC:
    IF FIRST-OF(BENEFITS.OBj-CODE) THEN DO:
      FIND FIRST buf_clients NO-LOCK WHERE
                 buf_clients.obj-type = {&shop} AND
                 buf_clients.obj-code = benefits.obj-code No-ERROR.
      PUT Stream PrnLibStream UNFORMATTED
      (IF AVAIL buf_clients
       then buf_clients.obj-name
       else ("Магазин N " + string(benefits.obj-code))
      )
      SKIP.
    END.
    IF FIRST-OF(BENEFITS.dcpc) THEN DO:
      PUT Stream PrnLibStream UNFORMATTED
      ("Скидка " + string(BENEFITS.dcpc, "->9%"))
      SKIP.
    END.
    PUT Stream PrnLibStream UNFORMATTED
    BENEFITS.num-chk  p-XL-delim
    BENEFITS.tot-doc p-XL-delim
    BENEFITS.NETTO p-XL-delim
    BENEFITS.DISCNT
    SKIP.
    ACCUMULATE
    BENEFITS.num-chk (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc)
    BENEFITS.tot-doc (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc)
    BENEFITS.netto (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc)
    BENEFITS.discnt (TOTAL BY BENEFITS.obj-code By BENEFITS.dcpc)
    .
    IF LAST-OF(BENEFITS.dcpc) THEN DO:
      PUT Stream PrnLibStream UNFORMATTED
      ("ИТОГО: (" + string(BENEFITS.dcpc, "->9%") + ")") p-XL-delim
      ACCUM TOTAL BY BENEFITS.dcpc BENEFITS.num-chk p-XL-delim
      ACCUM TOTAL BY BENEFITS.dcpc BENEFITS.tot-doc p-XL-delim
      ACCUM TOTAL BY BENEFITS.dcpc BENEFITS.NETTo p-XL-delim
      ACCUM TOTAL BY BENEFITS.dcpc BENEFITS.DISCNT
      SKIP.
    END.
    IF Multi-obj AND LAST-OF(BENEFITS.OBJ-CODE) THEN DO:
      PUT Stream PrnLibStream UNFORMATTED
      ("ИТОГО ПО МАГАЗИНУ " + string(BENEFITS.OBJ-CODE)) p-XL-delim
      ACCUM TOTAL BY BENEFITS.obj-code BENEFITS.num-chk p-XL-delim
      ACCUM TOTAL BY BENEFITS.obj-code BENEFITS.tot-doc p-XL-delim
      ACCUM TOTAL BY BENEFITS.obj-code BENEFITS.NETTo p-XL-delim
      ACCUM TOTAL BY BENEFITS.obj-code BENEFITS.DISCNT
      SKIP.
    END.
    IF LAST(BENEFITS.OBJ-CODE) THEN DO:
      PUT Stream PrnLibStream UNFORMATTED
      "ИТОГО ПО ВСЕМ " p-XL-delim
      ACCUM TOTAL BENEFITS.num-chk p-XL-delim
      ACCUM TOTAL BENEFITS.tot-doc p-XL-delim
      ACCUM TOTAL BENEFITS.NETTo p-XL-delim
      ACCUM TOTAL BENEFITS.DISCNT
      SKIP.
    END.
END. /*FOR EACH benefits*/
{ cmp/cls-exp.i stream PrnLibStream }
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -131
g#rep-updflds = "Отчет по процентам скидки чеков|" +
               str1
.
*/
run waitfram-hide in this-procedure .