/*block-level on error undo, throw. */
/*

$Revision: 0ec5d11e52eb, 2015, rls $
$Author: EShklyar $
$Date: Wed Sep 18 21:05:06 2019 +0300 $
$Workfile: r-ptlbal.p $
$Archive: rep/r-ptlbal.p $

Оперативный балансовый отчет движения нефтепродуктов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 07/09/09
Author: Dmitry Ukhanov
Creation date: 07/09/09

Author1: Alexey Suslov
Creation date1: 03/27/06

18.09.02 18:27
Суслов

*/

define input parameter parparentproc      as widget-handle no-undo .
define input parameter parobj-type        like ub.trn-doc.obj-type no-undo. /*объект*/
define input parameter parobj-code        like ub.trn-doc.obj-code no-undo.
define input parameter p-tog-shift        as logical            no-undo .
define input parameter parstart_date      as date               no-undo.
define input parameter parstart_shift_num as integer            no-undo.
define input parameter parend_date        as date               no-undo.
define input parameter parend_shift_num   as integer            no-undo.
define input parameter p-tog-weight       as logical            no-undo .
define input parameter p-tog-with-tot-day as logical            no-undo .

def var vss-revision    as character no-undo init "$Revision: 0ec5d11e52eb, 2015, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Wed Sep 18 21:05:06 2019 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-ptlbal.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-ptlbal.p $":U .
def var vss-description as character no-undo init "Оперативный балансовый отчет движения нефтепродуктов".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-page1.i     }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }
{ gbl/lastdate.i    }
{ gbl/cur-time.i    }
{ gbl/waitfram.i }

/* определяем символы разделители */
&scop sym format 'x(1)':u label ':':u init ':':u
{ gbl/vector.i 19 "define variable "  "sym" " " " as character no-undo {&sym} ." }

define variable  pardate-shift      as integer            no-undo. /*2 - по сменным суткам,
                                                                     3 - по сменным суткам с указанием номеров смен*/
if parstart_shift_num <> ?
  and parend_shift_num   <> ?
  and parstart_shift_num <> 0
  and parend_shift_num   <> 0
then do:
  assign
    pardate-shift = 3
  .
end.
else do:
  assign
    pardate-shift = 2
  .
end.

/* ширина отчета */
&scop report-width        211
&scop report-width-frame  213
&scop report-width-25     182

define buffer bef-rvs-doc         for ub.rvs-doc.
define buffer buf_rvs-doc         for ub.rvs-doc .
define buffer bef-rvs-line        for ub.rvs-line.
define buffer buf_rvs-line        for ub.rvs-line .
define buffer start-date-rvs-doc  for ub.rvs-doc.
define buffer end-date-rvs-doc    for ub.rvs-doc.
define buffer start-date-rvs-line for ub.rvs-line.
define buffer end-date-rvs-line   for ub.rvs-line.
define buffer bef-doc-rvs-doc     for ub.rvs-doc.
define buffer aft-doc-rvs-doc     for ub.rvs-doc.
define buffer bef-doc-rvs-line    for ub.rvs-line.
define buffer aft-doc-rvs-line    for ub.rvs-line.
define buffer buf_trn-doc         for ub.trn-doc .
define buffer buf_doc-line        for ub.doc-line .
define buffer buf_doc-pl          for ub.doc-pl .
define buffer buf_goods           for ub.goods .
define buffer buf_clients         for ub.clients .

define variable varhost-code  like ub.trn-doc.host-code     no-undo.
define variable v-host-name   as character               no-undo. /*название фирмы*/
define variable v-obj-name    as character               no-undo. /*АЗС*/
define variable v-header-name as character               no-undo.
define variable v-print-time  as character               no-undo.
define variable v-count       as   integer               no-undo .

define variable vardate-shift                as character            no-undo.
define variable varpl-code                   like ub.doc-pl.pl-code     no-undo.
define variable vargoods-name                as character            no-undo.
define variable varrest_start_measure        like ub.doc-line.fact-qnty no-undo.
define variable varrest_start_book           like ub.doc-line.fact-qnty no-undo.
define variable varwayb                      like ub.doc-line.fact-qnty no-undo.
define variable varwayb_measure              like ub.doc-line.fact-qnty no-undo.
define variable varwayb_fact                 like ub.doc-line.fact-qnty no-undo.
define variable varwayb_difference           like ub.doc-line.fact-qnty no-undo.
define variable varexp_kass                  like ub.doc-line.fact-qnty no-undo.
define variable varwrite-off                 like ub.doc-line.fact-qnty no-undo.
define variable varinvent                    like ub.doc-line.fact-qnty no-undo.
define variable varexp_gross                 like ub.doc-line.fact-qnty no-undo.
define variable varret_supp                  like ub.doc-line.fact-qnty no-undo.
define variable varanother                   like ub.doc-line.fact-qnty no-undo.
define variable varrest_end_measure          like ub.doc-line.fact-qnty no-undo.
define variable varrest_end_book             like ub.doc-line.fact-qnty no-undo.
define variable varrest_end_balans           like ub.doc-line.fact-qnty no-undo.
define variable varrev                       like ub.doc-line.fact-qnty no-undo.

DEFINE TEMP-TABLE tt-rev-day NO-UNDO
FIELD shift-date          like ub.trn-doc.shift-date
FIELD gds-code            like ub.goods.gds-code
FIELD pl-code             LIKE varpl-code
FIELD goods-name          LIKE vargoods-name
FIELD rest_start_measure  LIKE varrest_start_measure
FIELD rest_start_book     LIKE varrest_start_book
FIELD wayb                LIKE varwayb
FIELD wayb_measure        LIKE varwayb_measure
FIELD wayb_fact           LIKE varwayb_fact
FIELD wayb_difference     LIKE varwayb_difference
FIELD exp_kass            LIKE varexp_kass
FIELD write-off           LIKE varwrite-off
FIELD invent              LIKE varinvent
FIELD exp_gross           LIKE varexp_gross
FIELD ret_supp            LIKE varret_supp
FIELD another             LIKE varanother
FIELD rest_end_measure    LIKE varrest_end_measure
FIELD rest_end_book       LIKE varrest_end_book
FIELD rest_end_balans     LIKE varrest_end_balans
INDEX pi AS UNIQUE PRIMARY shift-date pl-code gds-code.

DEFINE TEMP-TABLE tt-rev-gds NO-UNDO
FIELD gds-code            like ub.goods.gds-code
FIELD pl-code             LIKE varpl-code
FIELD goods-name          LIKE vargoods-name
FIELD rest_start_measure  LIKE varrest_start_measure
FIELD rest_start_book     LIKE varrest_start_book
FIELD wayb                LIKE varwayb
FIELD wayb_measure        LIKE varwayb_measure
FIELD wayb_fact           LIKE varwayb_fact
FIELD wayb_difference     LIKE varwayb_difference
FIELD exp_kass            LIKE varexp_kass
FIELD write-off           LIKE varwrite-off
FIELD invent              LIKE varinvent
FIELD exp_gross           LIKE varexp_gross
FIELD ret_supp            LIKE varret_supp
FIELD another             LIKE varanother
FIELD rest_end_measure    LIKE varrest_end_measure
FIELD rest_end_book       LIKE varrest_end_book
FIELD rest_end_balans     LIKE varrest_end_balans
INDEX pi AS UNIQUE PRIMARY pl-code gds-code.

define variable bef-rvs-doc-rec        as recid no-undo.
define variable rvs-doc-rec            as recid no-undo.
define variable start-date-rvs-doc-rec as recid no-undo.
define variable end-date-rvs-doc-rec   as recid no-undo.
define variable start-date-doc-rec     as recid no-undo.
define variable end-date-doc-rec       as recid no-undo.

define variable v-line        as character no-undo format "X({&report-width})" .
define variable v-line1        as character no-undo format "X({&report-width})" .
define variable v-line2        as character no-undo format "X({&report-width})" .
assign
  v-line = fill("-", {&report-width} )
  v-line1 = v-line
  v-line2 = v-line
.

{ str/chkdtsft.i }

if not can-find(first gds-list) then do:
  message
    "Не заданы товары для формирования оперативного баланса."
    view-as alert-box error.
  return.
end.

run prn-lib-open-stream  in this-procedure
  ( input parParentProc
  , input 45
  , input yes /*p-is-stream*/
  , input no /*p-append*/
  ).

run waitfram-show in this-procedure ( {&MyWaitMess} ) .
/* выводим заголовок отчета, */
/* который будет печататься только на первой странице */

&SCOPED-DEFINE tt-l "                               О П Е Р А Т И В Н Ы Й  Б А Л А Н С О В Ы Й  О Т Ч Е Т  Д В И Ж Е Н И Я  Н Е Ф Т Е П Р О Д У К Т О В"

assign
  v-header-name = {&tt-l}
  v-print-time  = cur-time-string()
.
/*АЗС*/
find first buf_clients no-lock
  where buf_clients.obj-type = parobj-type
    and buf_clients.obj-code = parobj-code
  no-error.
assign
  v-obj-name = buf_clients.obj-name
.
{ gbl/hostcode.i parobj-type parobj-code varhost-code}
/*Своя фирма*/
find first buf_clients no-lock
  where buf_clients.obj-type = {&cmp}
    and buf_clients.obj-code = varhost-code
  no-error.
assign
  v-host-name = buf_clients.obj-name
.

put stream PrnLibStream unformatted
  "   Наименование организации " string(v-host-name + fill(" ", 70), "x(70)") skip(1)
  "   АЗС " v-obj-name skip(1)
  {&tt-l} skip(1)
  SPACE(50) (if p-tog-weight = true then "В КИЛОГРАММАХ" else "В ЛИТРАХ" ) skip(1).

if pardate-shift < 3 then
   put stream PrnLibStream unformatted  "                          Начало периода " parstart_date "                   Конец периода " parend_date skip(1).
else
   put stream PrnLibStream unformatted  " Начало периода (номер смены и дата ее начала) " string(parstart_shift_num) + ":":U + string(parstart_date) " Конец периода (номер смены и дата ее начала) " string(parend_shift_num) + ":":U + string(parend_date) skip(1).

put stream PrnLibStream unformatted
  v-line skip
  STRING(":           ", "X(12)") STRING(":           ", "X(12)") STRING(":         ", "X(12)") STRING(":          ", "X(12)") STRING(": Остаток  ", "X(11)") STRING(":           ", "X(12)") STRING("   Внешний  ", "X(12)") STRING(" приход     ", "X(12)") STRING("           ", "X(11)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(":          ", "X(11)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(":        :", "X(10)") skip
  STRING(":   Номер   ", "X(12)") STRING(":  № резер- ", "X(12)") STRING(":   Вид   ", "X(12)") STRING(": Остаток  ", "X(12)") STRING(":на начало ", "X(11)") STRING(":___________", "X(12)") STRING("____________", "X(12)") STRING("____________", "X(12)") STRING("___________", "X(11)") STRING(": Расход   ", "X(12)") STRING(":          ", "X(12)") STRING(":          ", "X(11)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(":Остаток на", "X(12)") STRING(":Остаток на", "X(12)") STRING(": Баланс :", "X(10)") skip
  STRING(":   смены   ", "X(12)") STRING(":    вуара  ", "X(12)") STRING(":  нефте  ", "X(12)") STRING(":на начало ", "X(12)") STRING(":расчетно- ", "X(11)") STRING(":           ", "X(12)") STRING(":    По     ", "X(12)") STRING(":           ", "X(12)") STRING(":Отклонение", "X(11)") STRING(":по данным ", "X(12)") STRING(": Списание ", "X(12)") STRING(": Инвентари", "X(11)") STRING(": Расход   ", "X(12)") STRING(": Возврат  ", "X(12)") STRING(":Остальное ", "X(12)") STRING(":  конец   ", "X(12)") STRING(":  конец   ", "X(12)") STRING(":+излишки:", "X(10)") skip
  STRING(": и дата ее ", "X(12)") STRING(":           ", "X(12)") STRING(": продукта", "X(12)") STRING(":   факт   ", "X(12)") STRING(": книжный  ", "X(11)") STRING(": По ТТН    ", "X(12)") STRING(":измер-ию в ", "X(12)") STRING(":По факту   ", "X(12)") STRING(":от принят.", "X(11)") STRING(": с касс   ", "X(12)") STRING(":          ", "X(12)") STRING(":  зация   ", "X(11)") STRING(": внешний  ", "X(12)") STRING(":поставщику", "X(12)") STRING(":          ", "X(12)") STRING(":фактически", "X(12)") STRING(":расчетно- ", "X(12)") STRING(":-недост.:", "X(10)") skip
  STRING(":  начала   ", "X(12)") STRING(":           ", "X(12)") STRING(":         ", "X(12)") STRING(":          ", "X(12)") STRING(":          ", "X(11)") STRING(":           ", "X(12)") STRING(":резервуаре ", "X(12)") STRING(":           ", "X(12)") STRING(":количества", "X(11)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(":          ", "X(11)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(":          ", "X(12)") STRING(": книжный  ", "X(12)") STRING(":        :", "X(10)") skip
  v-line
  .

/* определяем header: заголовок, */
/* который будет выводиться на каждой странице */
form header
  v-line1 at 1 skip
  /*v-header-name format "x(50)" at 1 */
    "Дата:" at 60
    v-print-time format "x(20)"
    "Стр." at {&report-width-25} string( page-number(PrnLibStream), ">>>9" )  skip
  v-line2 at 1 skip
  with frame topframe
  width {&report-width-frame} page-top no-labels no-box .
view stream PrnLibStream frame topframe .

/* определяем footer: нижнюю часть страницы, */
/* которая будет выводиться на каждой странице */
form header
  v-line skip
  "Продолжение на следующей странице " at 30 skip
  with frame bottomframe
  width {&report-width-frame} page-bottom no-labels no-box .
view stream PrnLibStream frame bottomframe .

for each sheetf
  where sheetf.sheet-num > 1
:
  delete sheetf .
end.
find first sheetf
  where sheetf.sheet-num = 1
  no-error.
assign
  sheetf.sizes = "":u
.

assign
  Sheetf.MergeCellsH = "6:9"
  Sheetf.MergeCellsV = "1=1:2/2=1:2/3=1:2/4=1:2/5=1:2/10=1:2/11=1:2/12=1:2/13=1:2/14=1:2/15=1:2/16=1:2/17=1:2/18=1:2"
  Sheetf.Sizes       = "10,11,6,11,11,10,11,10,8,11,11,11,11,11,11,11,11,11"
  Sheetf.Excel-Column-Lable = "Номер смены и дата ее начала"       + {&comma-char} +
                              "N резервуара"                       + {&comma-char} +
                              "Вид нефтепродукта"                  + {&comma-char} +
                              "Остаток на начало ФАКТ"             + {&comma-char} +
                              "Остаток на начало РАСЧЕТНО-КНИЖНЫЙ" + {&comma-char} +
                              "Внешний приход"                     + {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                              "Расход по данным с касс"            + {&comma-char} +
                              "Списание"                           + {&comma-char} +
                              "Инвентаризация"                     + {&comma-char} +
                              "Расход внешний"                     + {&comma-char} +
                              "Возврат поставщику"                 + {&comma-char} +
                              "Остальное"                          + {&comma-char} +
                              "Остаток на конец ФАКТ"              + {&comma-char} +
                              "Остаток на конец РАСЧЕТНО-КНИЖНЫЙ"  + {&comma-char} +
                              "Баланс +излишки -недостача"         + {&new-line}   +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                              "По ТТН"                             + {&comma-char} +
                              "По измерению в резервуаре"          + {&comma-char} +
                              "По факту"                           + {&comma-char} +
                              "Отклонение от принятого количества" + {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&comma-char} +
                                                                     {&new-line}   +
                               '="1"'                              + {&comma-char} +
                               '="2"'                              + {&comma-char} +
                               '="3"'                              + {&comma-char} +
                               '="4"'                              + {&comma-char} +
                               '="5"'                              + {&comma-char} +
                               '="6"'                              + {&comma-char} +
                               '="7"'                              + {&comma-char} +
                               '="8"'                              + {&comma-char} +
                               '="9=6-7"'                          + {&comma-char} +
                               '="10"'                             + {&comma-char} +
                               '="11"'                             + {&comma-char} +
                               '="12"'                             + {&comma-char} +
                               '="13"'                             + {&comma-char} +
                               '="14"'                             + {&comma-char} +
                               '="15"'                             + {&comma-char} +
                               '="16"'                             + {&comma-char} +
                               '="17"'                             + {&comma-char} +
                               '="18=16-17"'
.

run rep/extitle.p  ( input 1 ) no-error.

&scop format-qnty "->,>>>,>>9.<<<"

&scop frm-clmn-01 format "x(11)"
&scop lb-clmn-01  column-label "1":C10
&scop frm-clmn-02 format "99999999999"
&scop lb-clmn-02  column-label "2":C8
&scop frm-clmn-03 format "x(10)"
&scop lb-clmn-03  column-label "3":C11
&scop frm-clmn-04 format {&format-qnty}
&scop lb-clmn-04  column-label "4":C9
&scop frm-clmn-05 format {&format-qnty}
&scop lb-clmn-05  column-label "5":C9
&scop frm-clmn-06 format {&format-qnty}
&scop lb-clmn-06  column-label "6":C9
&scop frm-clmn-07 format {&format-qnty}
&scop lb-clmn-07  column-label "7":C9
&scop frm-clmn-08 format {&format-qnty}
&scop lb-clmn-08  column-label "8":C9
&scop frm-clmn-09 format "->,>>9.<<<"
&scop lb-clmn-09  column-label "9=6-7":C10
&scop frm-clmn-10 format {&format-qnty}
&scop lb-clmn-10  column-label "10":C9
&scop frm-clmn-11 format {&format-qnty}
&scop lb-clmn-11  column-label "11":C9
&scop frm-clmn-12 format "->>>>,>>9.<<<"
&scop lb-clmn-12  column-label "12":C9
&scop frm-clmn-13 format {&format-qnty}
&scop lb-clmn-13  column-label "13":C9
&scop frm-clmn-14 format {&format-qnty}
&scop lb-clmn-14  column-label "14":C9
&scop frm-clmn-15 format {&format-qnty}
&scop lb-clmn-15  column-label "15":C9
&scop frm-clmn-16 format {&format-qnty}
&scop lb-clmn-16  column-label "16":C9
&scop frm-clmn-17 format {&format-qnty}
&scop lb-clmn-17  column-label "17":C9
&scop frm-clmn-18 format "->>,>>9.<<<"
&scop lb-clmn-18  column-label "18=16-17":C8

/* определяем фрейм в котором будут выводиться данные */
define frame doc-line-frm
  sym01 space(0) vardate-shift         {&frm-clmn-01} {&lb-clmn-01} space(0)
  sym02 space(0) varpl-code            {&frm-clmn-02} {&lb-clmn-02} space(0)
  sym03 space(0) vargoods-name         {&frm-clmn-03} {&lb-clmn-03} space(0)
  sym04 space(0) varrest_start_measure {&frm-clmn-04} {&lb-clmn-04} space(0)
  sym05 space(0) varrest_start_book    {&frm-clmn-05} {&lb-clmn-05} space(0)
  sym06 space(0) varwayb               {&frm-clmn-06} {&lb-clmn-06} space(0)
  sym07 space(0) varwayb_measure       {&frm-clmn-07} {&lb-clmn-07} space(0)
  sym08 space(0) varwayb_fact          {&frm-clmn-08} {&lb-clmn-08} space(0)
  sym09 space(0) varwayb_difference    {&frm-clmn-09} {&lb-clmn-09} space(0)
  sym10 space(0) varexp_kass           {&frm-clmn-10} {&lb-clmn-10} space(0)
  sym11 space(0) varwrite-off          {&frm-clmn-11} {&lb-clmn-11} space(0)
  sym12 space(0) varinvent             {&frm-clmn-12} {&lb-clmn-12} space(0)
  sym13 space(0) varexp_gross          {&frm-clmn-13} {&lb-clmn-13} space(0)
  sym14 space(0) varret_supp           {&frm-clmn-14} {&lb-clmn-14} space(0)
  sym15 space(0) varanother            {&frm-clmn-15} {&lb-clmn-15} space(0)
  sym16 space(0) varrest_end_measure   {&frm-clmn-16} {&lb-clmn-16} space(0)
  sym17 space(0) varrest_end_book      {&frm-clmn-17} {&lb-clmn-17} space(0)
  sym18 space(0) varrest_end_balans    {&frm-clmn-18} {&lb-clmn-18} space(0)
  sym19 space(0)
  with width {&report-width-frame} down stream-io use-text .
form with frame doc-line-frm .

 { rep/q-inptl.i
   &add-query       = " "
   &inc-file        = "rep/r-ptlbal.i"
   &gds-buffer      = "buf_goods"
   &include-query   = " each gds-list, first buf_goods where buf_goods.artic      = gds-list.artic  and buf_goods.prod-type  = gds-list.prod-type and buf_goods.prod-code  = gds-list.prod-code no-lock, "
   &include-query2  = ", each buf_doc-pl where buf_doc-pl.out-code = buf_trn-doc.doc-code and buf_doc-pl.gds-code = buf_goods.gds-code and buf_doc-pl.obj-type = buf_trn-doc.obj-type and buf_doc-pl.obj-code = buf_trn-doc.obj-code "
   &break-by        = " BREAK BY buf_trn-doc.shift-date BY buf_trn-doc.shift-num BY buf_doc-pl.pl-code BY buf_doc-pl.gds-code "
   &no-1            = "yes"
   &no-4            = "yes"
 }

put stream PrnLibStream
  v-line  skip
  .
/* делаем footer невидимым, чтобы он не напечатался на последней странице */
hide stream PrnLibStream frame bottomframe .

assign
  v-count = 4
.
for each  tt-rev-gds :
  assign
    v-count = v-count + 1
  .
end.

if line-counter( PrnLibstream ) + v-count > page-size( PrnLibstream ) then do:
  page stream PrnLibstream .
end.


/* итоговая строка по отчету */
assign
  vardate-shift = "За период"
.
display stream PrnLibStream
  vardate-shift
  with frame doc-line-frm.
{&PutExcel}
vardate-shift
.

for each  tt-rev-gds :
  display stream PrnLibStream
    sym01
    sym02 tt-rev-gds.pl-code            @ varpl-code
    sym03 tt-rev-gds.goods-name         @ vargoods-name
    sym04 tt-rev-gds.rest_start_measure @ varrest_start_measure
    sym05 tt-rev-gds.rest_start_book    @ varrest_start_book
    sym06 tt-rev-gds.wayb               @ varwayb
    sym07 tt-rev-gds.wayb_measure       @ varwayb_measure
    sym08 tt-rev-gds.wayb_fact          @ varwayb_fact
    sym09 tt-rev-gds.wayb_difference    @ varwayb_difference
    sym10 tt-rev-gds.exp_kass           @ varexp_kass
    sym11 tt-rev-gds.write-off          @ varwrite-off
    sym12 tt-rev-gds.invent             @ varinvent
    sym13 tt-rev-gds.exp_gross          @ varexp_gross
    sym14 tt-rev-gds.ret_supp           @ varret_supp
    sym15 tt-rev-gds.another            @ varanother
    sym16 tt-rev-gds.rest_end_measure   @ varrest_end_measure
    sym17 tt-rev-gds.rest_end_book      @ varrest_end_book
    sym18 tt-rev-gds.rest_end_balans    @ varrest_end_balans
    sym19
    with frame doc-line-frm.
  down stream PrnLibStream with frame doc-line-frm.

  {&PutExcel}
  {&tabulation}
  tt-rev-gds.pl-code            {&tabulation}
  tt-rev-gds.goods-name         {&tabulation}
  tt-rev-gds.rest_start_measure {&tabulation}
  tt-rev-gds.rest_start_book    {&tabulation}
  tt-rev-gds.wayb               {&tabulation}
  tt-rev-gds.wayb_measure       {&tabulation}
  tt-rev-gds.wayb_fact          {&tabulation}
  tt-rev-gds.wayb_difference    {&tabulation}
  tt-rev-gds.exp_kass           {&tabulation}
  tt-rev-gds.write-off          {&tabulation}
  tt-rev-gds.invent             {&tabulation}
  tt-rev-gds.exp_gross          {&tabulation}
  tt-rev-gds.ret_supp           {&tabulation}
  tt-rev-gds.another            {&tabulation}
  tt-rev-gds.rest_end_measure   {&tabulation}
  tt-rev-gds.rest_end_book      {&tabulation}
  tt-rev-gds.rest_end_balans    {&new-line}
  .
end.

put stream PrnLibStream
  v-line  skip
  .

hide frame input-frm .
/* Выводим завершение отчета */
/* Место для подписей */
put stream PrnLibStream
  skip(2)
  .
put stream PrnLibStream unformatted
  "   Управляющий АЗС___________________________"
  .

output stream PrnLibStream close.
run waitfram-hide in this-procedure .

{&closeExcel}

/* вывести */
run prn-lib-prn-file in this-procedure
  ( input parParentProc
  , input 8
  ).