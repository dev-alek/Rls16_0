block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-msheet.p $
$Archive: rep/r-msheet.p $

Накопительная ведомость

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 04/12/06

*/

/* параметры отчета */
define input parameter parparentproc      as widget-handle      no-undo.
define input parameter pardate-shift      as integer            no-undo.
define input parameter parstart_date      as date               no-undo.
define input parameter parstart_shift_num as integer            no-undo.
define input parameter parend_date        as date               no-undo.
define input parameter parend_shift_num   as integer            no-undo.
define input parameter pargds-code        like ub.goods.gds-code   no-undo.
define input parameter parobj-type        like ub.clients.obj-type no-undo.
define input parameter parobj-code        like ub.clients.obj-code no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-msheet.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-msheet.p $":U .
def var vss-description as character no-undo init "Накопительная ведомость".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i " " repstr }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define variable p-host-code as integer no-undo.
{ gbl/hostcode.i parobj-type parobj-code p-host-code }

define buffer frm-clients  for ub.clients.
define buffer bef-rvs-doc  for ub.rvs-doc.
define buffer aft-rvs-doc  for ub.rvs-doc.
define buffer bef-rvs-line for ub.rvs-line.
define buffer aft-rvs-line for ub.rvs-line.
define buffer buf_goods    for ub.goods .
define buffer buf_clients  for ub.clients .
define buffer buf_trn-doc  for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_doc-pl   for ub.doc-pl .


/* ширина отчета */
&scop report-width        135
&scop report-width-frame  137
&scop report-width-25     100

def var v-ind         as integer   no-undo .
def var v-line        as character no-undo format "X({&report-width})" .
assign
  v-line = fill("-", {&report-width} )
.
def var v-line1        as character no-undo format "X({&report-width})" .
def var v-line2        as character no-undo format "X({&report-width})" .
def var v-line3        as character no-undo format "X({&report-width})" .
assign
  v-line1 = v-line
  v-line2 = v-line
  v-line3 = v-line
.

/* определяем символы разделители */
&scop sym format "x(1)":u label '!':u init ":":u

def var sym1  as character no-undo {&sym} .
def var sym2  as character no-undo {&sym} .
def var sym3  as character no-undo {&sym} .
def var sym4  as character no-undo {&sym} .
def var sym5  as character no-undo {&sym} .
def var sym6  as character no-undo {&sym} .
def var sym7  as character no-undo {&sym} .
def var sym8  as character no-undo {&sym} .
def var sym9  as character no-undo {&sym} .
def var sym10 as character no-undo {&sym} .
def var sym11 as character no-undo {&sym} .
def var sym12 as character no-undo {&sym} .

run waitfram-show in this-procedure ( input {&MyWaitMess} ).

run prn-lib-open-stream in this-procedure ( input parparentproc, input 45, input yes, input no ).

/* выводим заголовок отчета, */
/* который будет печататься только на первой странице */
def var v-host-name   as character no-undo. /*название фирмы*/
def var v-obj-name    as character no-undo.  /*АЗС*/
def var v-header-name as character no-undo.
def var v-print-time  as character no-undo.
define variable vardate-shift  as   character      no-undo.
define variable vardeviationdoc-qnty like ub.doc-line.doc-qnty         no-undo.
define variable vardeviationcli-qnty like ub.doc-line.fact-qnty        no-undo.
define variable vardeviationperc     as decimal format "->>>9.99<"  no-undo.
define variable vardevfactdoc-qnty   like ub.doc-line.doc-qnty         no-undo.
define variable vardevfactcli-qnty   like ub.doc-line.fact-qnty        no-undo.
define variable vardevfactperc       as decimal format "->>>9.99<"  no-undo.
define variable varmeasure-qnty      like ub.rvs-line.measure-qnty     no-undo.
define variable varmeasure-cli-qnty  like ub.rvs-line.measure-cli-qnty no-undo.

&scop ttl "                           Н А К О П И Т Е Л Ь Н А Я  В Е Д О М О С Т Ь "

assign
  v-header-name = {&ttl}
  v-print-time  = cur-time-string()
.
find first buf_goods where buf_goods.gds-code = pargds-code no-lock.
/*АЗС*/
find first buf_clients no-lock
  where buf_clients.obj-type = parobj-type
    and buf_clients.obj-code = parobj-code
  .
assign
  v-obj-name = buf_clients.obj-name
.
/*Своя фирма*/
find first frm-clients no-lock
  where frm-clients.obj-type = {&cmp}
    and frm-clients.obj-code = p-host-code
  .
assign
  v-host-name = frm-clients.obj-name
.
&scop format-qnty   format "->>,>>>,>>9.<<<"

/* определяем фрейм в котором будут выводиться данные */
&scop frm-clmn-01 format "X(5)"
&scop lb-clmn-01  column-label "1"
&scop frm-clmn-02 format "99/99/99"
&scop lb-clmn-02  column-label "2"
&scop frm-clmn-03 format "x(14)"
&scop lb-clmn-03  column-label "3"
&scop frm-clmn-04 {&format-qnty}
&scop lb-clmn-04  column-label "4"
&scop frm-clmn-05 {&format-qnty}
&scop lb-clmn-05  column-label "5"
&scop frm-clmn-06 {&format-qnty}
&scop lb-clmn-06  column-label "6"
&scop frm-clmn-07 {&format-qnty}
&scop lb-clmn-07  column-label "7"
&scop frm-clmn-08 format "->>>,>>>9.99<"
&scop lb-clmn-08  column-label "8"
&scop frm-clmn-09 {&format-qnty}
&scop lb-clmn-09  column-label "9"
&scop frm-clmn-10 {&format-qnty}
&scop lb-clmn-10  column-label "10"
&scop frm-clmn-11 format "->>>,>>>9.99<"
&scop lb-clmn-11  column-label "11"

define frame doc-line-frm
  sym1  space(0) buf_trn-doc.shift-name   {&frm-clmn-01} {&lb-clmn-01} space(0)
  sym2  space(0) buf_trn-doc.shift-date   {&frm-clmn-02} {&lb-clmn-02} space(0)
  sym3  space(0) buf_trn-doc.doc-code     {&frm-clmn-03} {&lb-clmn-03} space(0)
  sym4  space(0) buf_doc-line.doc-qnty    {&frm-clmn-04} {&lb-clmn-04} space(0)
  sym5  space(0) buf_doc-line.cli-qnty    {&frm-clmn-05} {&lb-clmn-05} space(0)
  sym6  space(0) vardeviationdoc-qnty    {&frm-clmn-06} {&lb-clmn-06} space(0)
  sym7  space(0) vardeviationcli-qnty    {&frm-clmn-07} {&lb-clmn-07} space(0)
  sym8  space(0) vardeviationperc        {&frm-clmn-08} {&lb-clmn-08} space(0)
  sym9  space(0) vardevfactdoc-qnty      {&frm-clmn-09} {&lb-clmn-09} space(0)
  sym10 space(0) vardevfactcli-qnty      {&frm-clmn-10} {&lb-clmn-10} space(0)
  sym11 space(0) vardevfactperc          {&frm-clmn-11} {&lb-clmn-11} space(0)
  sym12 space(0)
  with width {&report-width-frame}  down stream-io use-text .

form with frame doc-line-frm .

put stream repstr unformatted
  "   Наименование организации " string(v-host-name + fill(" ", 40), "x(40)")  skip
  "   АЗС: "  v-obj-name  skip
  {&ttl} skip
  "   Начало периода " (if pardate-shift <= 2 then string(parstart_date) else string(parstart_date) + ":" + string(parstart_shift_num)) skip
  "   Конец периода  " (if pardate-shift <= 2 then string(parend_date)   else string(parend_date)   + ":" + string(parend_shift_num))   skip
  "   Наименование нефтепродукта " buf_goods.artic " " buf_goods.gds-name skip
  .

put stream repstr unformatted
  v-line skip
   STRING("!     ", "X(6)") STRING("!        ", "X(9)") STRING("!              ", "X(15)") STRING("!            ", "X(13)") STRING("             ", "X(13)") STRING("!  Отклонение", "X(13)") STRING(" принятого   ", "X(13)") STRING("!            ", "X(13)") STRING("!  Отклонение", "X(13)") STRING(" принятого   ", "X(13)") STRING("!            !", "X(14)") skip
   STRING("!Номер", "X(6)") STRING("!  Дата  ", "X(9)") STRING("!              ", "X(15)") STRING("!  Поступило ", "X(13)") STRING("по ТТН       ", "X(13)") STRING("!          по", "X(13)") STRING(" приборам    ", "X(13)") STRING("!Погрешность ", "X(13)") STRING("!          по", "X(13)") STRING(" факту       ", "X(13)") STRING("!Погрешность !", "X(14)") skip
   STRING("!смены", "X(6)") STRING("! начала ", "X(9)") STRING("!    № ТТН     ", "X(15)") STRING("!____________", "X(13)") STRING("_____________", "X(13)") STRING("!____________", "X(13)") STRING("_____________", "X(13)") STRING("!     в %    ", "X(13)") STRING("!____________", "X(13)") STRING("_____________", "X(13)") STRING("!     в %    !", "X(14)") skip
   STRING("!     ", "X(6)") STRING("! смены  ", "X(9)") STRING("!              ", "X(15)") STRING("!      в     ", "X(13)") STRING("!     в      ", "X(13)") STRING("!      в     ", "X(13)") STRING("!      в     ", "X(13)") STRING("!            ", "X(13)") STRING("!      в     ", "X(13)") STRING("!      в     ", "X(13)") STRING("!            !", "X(14)") skip
   STRING("!     ", "X(6)") STRING("!        ", "X(9)") STRING("!              ", "X(15)") STRING("!   литрах   ", "X(13)") STRING("!килограммах ", "X(13)") STRING("!    литрах  ", "X(13)") STRING("! килограммах", "X(13)") STRING("!            ", "X(13)") STRING("!    литрах  ", "X(13)") STRING("! килограммах", "X(13)") STRING("!            !", "X(14)") skip
  v-line
  .
/* определяем header: заголовок, */
/* который будет выводиться на каждой странице */
form header
  v-line1 at 1 skip
  v-header-name format "x(50)" at 1
    "Дата:" at 60
    v-print-time format "x(20)"
    "Стр." at {&report-width-25} string( page-number(repstr), ">>>9" )  skip
  v-line2 at 1 skip
  with frame topframe
  width {&report-width-frame} page-top no-labels no-box .
view stream repstr frame topframe .

/* определяем footer: нижнюю часть страницы, */
/* которая будет выводиться на каждой странице */
form header
  v-line skip
  "Продолжение на следующей странице " at 30 skip
  with frame bottomframe
  width {&report-width-frame} page-bottom no-labels no-box .
view stream repstr frame bottomframe .
{ rep/q-inptl.i
 &inc-file = "rep/r-msheet.i"
 &gds-buffer = "buf_goods"
 &add-query  = " and buf_trn-doc.doc-type = {&income} and buf_trn-doc.internal = no"
}
/* Выводим завершение отчета */
/* Место для подписей */
put stream repstr
  v-line
  skip(2)
  .
display stream repstr
sym1  space(0)
sym2  space(0)
sym3  space(0) "Итого"                                                              @ buf_trn-doc.doc-code
sym4  space(0) (ACCUM TOTAL buf_doc-line.doc-qnty)                                      @ buf_doc-line.doc-qnty
sym5  space(0) (ACCUM TOTAL buf_doc-line.cli-qnty)                                      @ buf_doc-line.cli-qnty
sym6  space(0) (ACCUM TOTAL vardeviationdoc-qnty)                                   @ vardeviationdoc-qnty
sym7  space(0) (ACCUM TOTAL vardeviationcli-qnty)                                   @ vardeviationcli-qnty
sym8  space(0) (ACCUM TOTAL vardeviationdoc-qnty) / (ACCUM TOTAL buf_doc-line.doc-qnty) @ vardeviationperc
sym9  space(0) (ACCUM TOTAL vardevfactdoc-qnty)                                     @ vardevfactdoc-qnty
sym10 space(0) (ACCUM TOTAL vardevfactcli-qnty)                                     @ vardevfactcli-qnty
sym11 space(0) (ACCUM TOTAL vardevfactdoc-qnty)   / (ACCUM TOTAL buf_doc-line.doc-qnty) @  vardevfactperc
sym12 space(0)
with frame doc-line-frm .
down stream repstr 1 with frame doc-line-frm.
put stream repstr unformatted
  "   Начальник АЗС ___________________________ "
  .

/* делаем footer невидимым, чтобы он не напечатался на последней странице */
hide stream repstr frame bottomframe .
output stream repstr close.
run waitfram-hide in this-procedure.

/* вывести */
run prn-lib-prn-file in this-procedure ( input parparentproc, input 7 ).