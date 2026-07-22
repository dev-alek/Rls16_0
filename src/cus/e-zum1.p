block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-zum1.p $
$Archive: cus/e-zum1.p $

Экспорт чеков в Excel для ЦУМа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-zum1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/e-zum1.p $":U .
define variable vss-description as character no-undo init "Экспорт чеков в Excel для ЦУМа".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def " " my-handle }


&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."
define variable Line                as      char    no-undo.
define variable date_string     as      char    no-undo.
def SHARED var cas-shft as logical no-undo init no.
define var cas-num as integer no-undo.
define variable g#log as logical no-undo .

define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.

{ gbl/getcntxt.i get " " my-handle }

{ gbl/getsect.i def }
{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.


define variable found as logical init yes no-undo.
{ rep/e-nobenq.i }


run no-benq(output found).
if NOT found then do:
  run waitfram-hide in this-procedure .
  message {&no-benefits} view-as alert-box.
  return.
end.

{ cmp/open-exp.i stream PrnLibStream}
run waitfram-show in this-procedure ("Ждите...").
PUT stream PrnLibStream UNFORMATTED
space(20)
"ЭКСПОРТ чеков" skip
space(23) str1 skip(0)
str4 skip(2).
PUT Stream PrnLibStream UNFORMATTED
"ТИП_ЧЕКА"  p-XL-delim
"НОМЕР_ЧЕКА" p-XL-delim
"СЕКЦИЯ" p-XL-delim
"КАССА" p-XL-delim
"N_Z-ОТЧЕТА" p-XL-delim
"N_ЧЕКА_НА_КАССЕ" p-XL-delim
"ДАТА" p-XL-delim
"ВРЕМЯ" p-XL-delim
"СУММА_ОПЛАТ" p-XL-delim
"ТОВАРНАЯ_СУММА" p-XL-delim
"ОБЩАЯ_СКИДКА" p-XL-delim
"СИКДКА_НА_ИТОГ" p-XL-delim
"КАССИР" p-XL-delim
"ПРОДАВЕЦ" p-XL-delim
"ДИСКОНТНАЯ_КАРТА" p-XL-delim
"ОТЧЕТ_О_ПРОДАЖЕ" p-XL-delim
SKIP.


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
    PUT Stream PrnLibStream UNFORMATTED
    buf_chk-doc.office   p-XL-delim
    buf_chk-doc.doc-code p-XL-delim
    buf_chk-doc.obj-code p-XL-delim
    buf_chk-doc.pay-desk p-XL-delim
    (if num-entries(buf_chk-doc.doc-code, {&slash-char}) = 5
    then entry(2, buf_chk-doc.doc-code, {&slash-char})
    else "?") p-XL-delim
    buf_chk-doc.chk-num p-XL-delim
    buf_chk-doc.chk-date format "99/99/9999" p-XL-delim
    string(buf_chk-doc.chk-time, "HH:MM") p-XL-delim
    buf_chk-doc.netto p-XL-delim
    buf_chk-doc.tot-doc p-XL-delim
    buf_chk-doc.discnt  p-XL-delim
    buf_chk-doc.sub-discnt p-XL-delim
    buf_chk-doc.cashier p-XL-delim
    buf_chk-doc.sales-man p-XL-delim
    buf_chk-doc.d-card p-XL-delim
    buf_chk-doc.out-code p-XL-delim
    SKIP.

    IF (ACCUM COUNT buf_chk-doc.doc-code) MODULO 50 = 0 then
    run waitfram-show in this-procedure ("Ждите..." + "Объект " + string(obj-list.obj-code) + " Обработано " +
                  string(ACCUM COUNT buf_chk-doc.doc-code) + " чеков").
  END.  /*FOR EACH buf_chk-doc*/

END. /*FOR EACH OBJ-LIST*/


{ cmp/cls-exp.i stream PrnLibStream}

run waitfram-hide in this-procedure .
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -131
g#rep-updflds = "Экспорт чеков в Excel|" + str1
.
*/