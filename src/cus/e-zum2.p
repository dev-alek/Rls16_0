block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-zum2.p $
$Archive: cus/e-zum2.p $

Экспорт строк чеков в Excel для ЦУМа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-zum2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/e-zum2.p $":U .
define variable vss-description as character no-undo init "Экспорт строк чеков в Excel для ЦУМа".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def " " my-handle }


&global-define  no-benefits    "Не было никакой выручки  ~
в течение заданного Вами периода времени."
DEFINE VARIABLE Line                as      char    no-undo.
DEFINE VARIABLE date_string     as      char    no-undo.
DEFINE SHARED VARIABLE cas-shft as logical no-undo init no.
DEFINE VARIABLE cas-num as integer no-undo.
DEFINE VARIABLE v-b-code as character no-undo .
DEFINE VARIABLE v-grp-name like ub.goods.grp-name no-undo .
DEFINE VARIABLE v-node-name like ub.gds-prt.f-name no-undo .
DEFINE VARIABLE v-root-name like ub.gds-prt.node-name no-undo .
DEFINE VARIABLE v-artic like ub.goods.artic no-undo .
DEFINE VARIABLE v-prod-type like ub.goods.prod-type no-undo .
DEFINE VARIABLE v-prod-code as character no-undo .
DEFINE VARIABLE found as logical init yes no-undo.
define variable g#log as logical no-undo .
define variable p-XL-delim as character no-undo .
define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.

{ gbl/getcntxt.i get " " my-handle }
{ gbl/getsect.i def }
{ gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'XL-delim'  then tmp-var1   = thbjattr_thbj-attr.property-value-character.
end.
IF tmp-var1 = "" then p-XL-delim = ";".
else p-XL-delim = tmp-var1.


define stream PrnLibStream .

define buffer root_gds-prt for ub.gds-prt.
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
"ЭКСПОРТ строк чеков" skip
space(23) str1 skip(0)
str4 skip(2).
PUT Stream PrnLibStream UNFORMATTED
"ГРУППА ТОВАРОВ"  p-XL-delim
"ГЛАВНЫЙ КОД ТОВАРА" p-XL-delim
"БАР-КОД ПРИЗНАКА" p-XL-delim
"ШКАЛА/ПРИЗНАК" p-XL-delim
"АРТИКУЛ" p-XL-delim
"ТИП ПРОИЗВОДИТЕЛЯ" p-XL-delim
"КОД ПРОИЗВОДИТЕЛЯ" p-XL-delim
"КОЛИЧЕСТВО" p-XL-delim
"СУММА ВЫРУЧКИ" p-XL-delim
"СКИДКА" p-XL-delim
"СУММА ПРОДАЖНЫХ ЦЕН" p-XL-delim
"КОД ПРОДАВЦА" p-XL-delim
SKIP.


FOR EACH obj-list No-LOCK:
_chk-gds:
  FOR EACH buf_chk-doc No-LOCK WHERE
            buf_chk-doc.obj-type = obj-list.obj-type AND
            buf_chk-doc.obj-code = obj-list.obj-code AND
            buf_chk-doc.out-code <> ? AND
            buf_chk-doc.chk-date >= X-date-start AND
            buf_chk-doc.chk-date <= X-date-end,
      EACH buf_chk-gds No-LOCK WHERE
           buf_chk-gds.doc-code = buf_chk-doc.doc-code:
    if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-gds.
    ACCUMULATE buf_chk-gds.doc-code (COUNT).
    /*найдем главный код товара*/
    FIND FIRST buf_bar-code no-LOCK WHERE
               buf_bar-code.b-code = buf_chk-gds.b-code No-ERROR.
    if avail buf_bar-code then do:
      assign
      v-b-code = ?
      .
      { gbl/gdsbcode.i buf_bar-code.gds-code  ? v-b-code no-error }
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
    end.
    if not avail buf_bar-code or v-b-code = ? then do:
      assign
      v-b-code = "?":U
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
    end.
    else do:
      assign
      v-grp-name = "?":U
      v-root-name = "?":U
      .
    end.
    PUT Stream PrnLibStream UNFORMATTED
    v-grp-name  p-XL-delim
    v-b-code p-XL-delim
    buf_chk-gds.b-code p-XL-delim
    (v-root-name + (if v-node-name = "":U then "":U else {&slash-char}) + v-node-name) p-XL-delim
    v-artic p-XL-delim
    v-prod-type p-XL-delim
    v-prod-code p-XL-delim
    buf_chk-gds.doc-qnty p-XL-delim
    buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt) p-XL-delim
    buf_chk-gds.discnt p-XL-delim
    (buf_chk-gds.doc-qnty * buf_chk-gds.price-base) p-XL-delim
    buf_chk-doc.sales-man p-XL-delim
    SKIP.

    IF (ACCUM COUNT buf_chk-gds.doc-code) MODULO 50 = 0 then
    run waitfram-show in this-procedure ("Ждите..." + "Объект " + string(obj-list.obj-code) + " Обработано " +
                  string(ACCUM COUNT buf_chk-gds.doc-code) + " строк чеков").
  END.  /*FOR EACH buf_chk-doc*/

END. /*FOR EACH OBJ-LIST*/


{ cmp/cls-exp.i stream PrnLibStream }

run waitfram-hide in this-procedure .
/*
assign
g#rep-tblname = ""
g#rep-tblrid = -131
g#rep-updflds = "Экспорт строк чеков в Excel|" + str1
.
*/