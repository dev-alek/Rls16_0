block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-otcst.p $
$Archive: cus/r-otcst.p $

Таможенная оборотка - начало и печать

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/21/06
Author: Bakhtadze Natalya
Creation date: 03/21/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-otcst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-otcst.p $":U .
define variable vss-description as character no-undo init "Таможенная оборотка".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i }
{ gbl/prn-lib.i }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def " " my-handle }

{ cus/r-otcst.i NEW }

/* ширина отчета */
&scop report-width        198
&scop report-width-frame  200
&scop report-width-25     180


define variable v-ind       as integer   no-undo .
define variable v-line      as character no-undo format "X({&report-width})" .
define variable varyear-cst as integer   no-undo format "9999".
DEFINE VARIABLE v-header-name as character no-undo .
DEFINE VARIABLE v-print-time as character no-undo .
DEFINE VARIABLE vardes as character no-undo .
define variable v-line1     as character no-undo format "X({&report-width})" .
define variable v-line2     as character no-undo format "X({&report-width})" .
define variable v-line3     as character no-undo format "X({&report-width})" .
DEFINE VARIABLE  for-ii     as integer no-undo .
DEFINE VARIABLE for-num-place_brutto as character no-undo .


/* определяем символы разделители */
&scop sym format 'x(1)':u label ':':u init ' ':u
{ gbl/vector.i 14 "define variable "  "sym" " " " as character no-undo {&sym} ." }

&scop to-je "--//--"

&scop All-sym14 sym01 sym02 sym03 sym04 sym05 sym06 sym07 sym08 sym09 sym10 sym11 sym12 sym13 sym14
&scop All-sym3  sym01 sym02 sym03


&SCOPED-DEFINE tt-l-1 "Отчет о товарах, помеченных под таможенный режим магазина беспошлинной торговли"
&SCOPED-DEFINE tt-l-2 "и реализованных в магазине беспошлинной торговли ЗАО 'Порт-Альянc' лицензия от 06.09.99 № 52"
&SCOPED-DEFINE tt-l-3 "по состоянию на " + string(x-Date-End + 1, "99/99/9999") + " за период с " + string(x-date-start, "99/99/9999") + " по " + string(x-date-end, "99/99/9999")

&SCOPED-DEFINE tt-lz-1 "                Список ГТД, которые исключены из Отчета, как ГТД,"
&SCOPED-DEFINE tt-lz-2 " по которым остаток по всем наименованиям товаров, помещенных под таможенный "
&SCOPED-DEFINE tt-lz-3 " режим МБТ и реализованных в магазине беспошлинной торговли ЗАО 'Порт-Альянс'"
&SCOPED-DEFINE tt-lz-4 "лицензия от 06.09.99 N 52 по состоянию на " + string(X-date-end + 1, "99/99/9999") + " равен 0"



&SCOPED-DEFINE label1 "  1  "
&SCOPED-DEFINE label2 "  2   "
&SCOPED-DEFINE label3 "                    3"
&SCOPED-DEFINE label4 "     4"
&SCOPED-DEFINE label5 "    5"
&SCOPED-DEFINE label6 "          6"
&SCOPED-DEFINE label7 "      7"
&SCOPED-DEFINE label8 "      8"
&SCOPED-DEFINE label9 "      9"
&SCOPED-DEFINE label10 "     10"
&SCOPED-DEFINE label11 "     11    :         12      "
&SCOPED-DEFINE label13 "     13"
&SCOPED-DEFINE label14 "    14"

&SCOPED-DEFINE labelz1 "  1  "
&SCOPED-DEFINE labelz2 "          2          "


/* определяем фрейм в котором будут выводиться данные */
define frame doc-line-frm
sym01 space(0) for-ii                  format ">>>>9"            COLUMN-LABEL {&label1}  space(0)
sym02 space(0) tt-cst.cst-code         format "x(6)"             COLUMN-LABEL {&label2}  space(0)
sym03 space(0) tt-cst.name_artic_unit  format "x({&nau-length})" COLUMN-LABEL {&label3}  space(0)
sym04 space(0) tt-cst.nationality      format "X(12)"            COLUMN-LABEL {&label4}  space(0)
sym05 space(0) tt-cst.tnved            format "X(10)"            COLUMN-LABEL {&label5}  space(0)
sym06 space(0) for-num-place_brutto    format "X(21)"            COLUMn-LABEL {&label6}  space(0)
sym07 space(0) tt-cst.qnty-income      format {&format-qnty}     COLUMN-LABEL {&label7}  space(0)
sym08 space(0) tt-cst.qnty-start       format {&format-qnty}     COLUMN-LABEL {&label8}  space(0)
sym09 space(0) tt-cst.qnty-sale        format {&format-qnty}     COLUMN-LABEL {&label9}  space(0)
sym10 space(0) tt-cst.qnty-ext_expence format {&format-qnty}     COLUMN-LABEL {&label10} space(0)
sym11 space(0) vardes                  format "x(28)"            COLUMN-LABEL {&label11} space(0)
sym12 space(0) tt-cst.qnty-rest        format {&format-qnty}     column-label {&label13} space(0)
sym13 space(0) tt-cst.ps               format "x(10)"            column-label {&label14} space(0)
sym14 space(0)
with width {&report-width-frame} down stream-io use-text  NO-BOX .


/* определяем фрейм в котором будут выводиться данные */
define frame zero-frm
sym01 space(0) for-ii                format ">>>>9"            COLUMN-LABEL {&labelz1}  space(0)
sym02 space(0) tt-cst-year.cst-code  format "x(31)"            COLUMN-LABEL {&labelz2}  space(0)
sym03 space(0)
with width {&report-width-frame} down stream-io use-text  NO-BOX .

{ gbl/getcntxt.i get " " my-handle }
run cus/r-otcstr.p (input X-date-start, input X-date-end, v-cntxt-host-code-obj) no-error.
if error-status:error then return error.

assign
v-line = fill("-", {&report-width} )
v-line1 = v-line
v-line2 = v-line
v-line3 = v-line
.

run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


run waitfram-show in this-procedure ({&MyWaitMess} ) .

/* выводим заголовок отчета, */
/* который будет печататься только на первой странице */

assign
v-header-name = {&tt-l-1} + {&new-line} + {&tt-l-2} + {&new-line} + {&tt-l-3}
v-print-time  = cur-time-string().

put stream PrnLibStream unformatted
{&tt-l-1} skip(1)
{&tt-l-2} skip(1)
{&tt-l-3} skip(1)
SPACE(50) v-print-time skip(1).

put stream PrnLibStream unformatted
v-line skip
":     :      :                                         :   Статус   :          :                     :          : Остаток  :Количество: Товары в отношении которых тамож. режим: Остаток  :          :" skip
":  №  :   №  :  Краткое наименование товара, артикул,  :  товаров   :   Код    :   Кол-во мест и     :Количество:на начало :реализова-:маг-на беспошлинной торг.изменен на иной: товаров, :Примечание:" skip
": п/п :  ГТД :           единица измерения             :(российские :  ТНВЭД   :    вес брутто       :   (шт)   :отчетного :   нное   :________________________________________:помещенных:          :" skip
":     :      :                                         :     или    :          :                     :          : периода  :  на дату :  кол-во  :таможенный :       №ГТД      :под тамож.:          :" skip
":     :      :                                         :иностранные):          :                     :          :   (шт)   :отчета(шт):  товара  :   режим   :                 :  режим   :          :" skip
v-line
.

/* определяем header: заголовок, */
/* который будет выводиться на каждой странице */

find first tt-cst-year No-LOCK WHERE
           tt-cst-year.zero = no USE-index i-year No-ERROR.

if avail tt-cst-year then
varyear-cst = tt-cst-year.in-year.

form header
v-line1 at 1 skip
v-header-name format "x(79)" at 1
"Дата:" at 90
v-print-time format "x(20)"
v-line2 at 1
with frame topframe
width {&report-width-frame} page-top no-labels no-box .

view stream PrnLibStream frame topframe .

/* определяем footer: нижнюю часть страницы, */
/* которая будет выводиться на каждой странице */
form header
v-line skip
"ГТД  за " varyear-cst "год "
"Стр." at {&report-width-25} string( page-number(PrnLibStream), ">>>9" )
"Продолжение на следующей странице " at 30 skip
with frame bottomframe
width {&report-width-frame} page-bottom no-labels no-box .

view stream PrnLibStream frame bottomframe .


form with frame doc-line-frm .
/*Место для тела*/

/*главный цикл*/

for each tt-cst-year No-LOCK WHERE
         tt-cst-year.zero = no,
    each tt-cst No-LOCK WHERE
         tt-cst.cst-code = tt-cst-year.cst-code
    break
    by tt-cst-year.in-year
    by tt-cst-year.cst-code
    by tt-cst.artic
    by tt-cst.prod-type
    by tt-cst.prod-code:

  if first-of(tt-cst-year.in-year) then do:
    if tt-cst-year.in-year <> ? then
    varyear-cst = tt-cst-year.in-year.
    if not first(tt-cst-year.in-year) then
    DOWN 1 stream PrnLibStream
    with FRAME doc-line-frm.
    DISPLAY stream PrnLibStream
    "ГТД" @ for-ii
    "за"  @ tt-cst.cst-code
    (string(tt-cst-year.in-year) + {&space-char} + "год") @ tt-cst.name_artic_unit
    with frame doc-line-frm.
    DOWN 2 stream PrnLibStream
    with FRAME doc-line-frm.


  end.
  if first-of(tt-cst-year.cst-code) then do:
    if not first(tt-cst-year.cst-code) and
       not first-of(tt-cst-year.in-year) then
    DOWN 1 stream PrnLibStream
    with FRAME doc-line-frm.

    DISPLAY stream PrnLibStream
    "ГТД" @ for-ii
    "N"  @ tt-cst.cst-code
    tt-cst-year.cst-code @ tt-cst.name_artic_unit
    with frame doc-line-frm.
    DOWN 2 stream PrnLibStream
    with FRAME doc-line-frm.
  end.

  for-ii = for-ii + 1.

  find first tt-cst-ext No-LOCK WHERE
            tt-cst-ext.cst-code = tt-cst.cst-code AND
            tt-cst-ext.artic = tt-cst.artic AND
            tt-cst-ext.prod-type = tt-cst.prod-type AND
            tt-cst-ext.prod-code = tt-cst.prod-code No-ERROR.


  DISPLAY stream PrnLibStream
  {&all-sym14}
  for-ii
  {&to-je} @ tt-cst.cst-code
  tt-cst.name_artic_unit
  tt-cst.nationality
  tt-cst.tnved
  string(tt-cst.num-place, {&format-qnty}) + {&space-char} + string(tt-cst.brutto, {&format-brutto})
  @ for-num-place_brutto
  tt-cst.qnty-income
  tt-cst.qnty-start
  (- tt-cst.qnty-sale) @ tt-cst.qnty-sale
  ( - tt-cst.qnty-ext_expence) @ tt-cst.qnty-ext_expence
  (if avail tt-cst-ext
   then (string(tt-cst-ext.qnty, {&format-qnty}) + {&space-char} + tt-cst-ext.des)
   else "") @ vardes
  tt-cst.qnty-rest
  tt-cst.PS
  with frame doc-line-frm.
  DOWN stream PrnLibStream
  with FRAME doc-line-frm.

  REPEAT while avail tt-cst-ext:
    find next tt-cst-ext No-LOCK WHERE
              tt-cst-ext.cst-code = tt-cst.cst-code AND
              tt-cst-ext.artic = tt-cst.artic AND
              tt-cst-ext.prod-type = tt-cst.prod-type AND
              tt-cst-ext.prod-code = tt-cst.prod-code No-ERROR.
    if avail tt-cst-ext then do:
      DISPLAY stream PrnLibStream
      {&all-sym14}
      tt-cst-ext.des @ vardes
      with frame doc-line-frm.
      DOWN stream PrnLibStream
      with FRAME doc-line-frm.
    end.
  END.
end. /*for each tt-cst-year*/



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
"   ___________________________________      ___________________________________                 " skip
"             Руководитель                                 Подпись                         Печать" SKIP
.

/* делаем footer невидимым, чтобы он не напечатался на последней странице */
hide stream PrnLibStream frame bottomframe .
output stream PrnLibStream close.

run waitfram-show in this-procedure ("Вывод списка ГТД, исключенных из отчета").

run prn-lib-open-stream  in this-procedure (
                                             input my-handle
                                            ,input 45
                                            ,input yes /*p-is-stream*/
                                            ,input yes /*p-append*/
                                            ).


assign
v-header-name = {&tt-lz-1} + {&new-line} + {&tt-lz-2} + {&new-line} + {&tt-lz-3}
.

put stream PrnLibStream unformatted
{&tt-lz-1} skip(1)
{&tt-lz-2} skip(1)
{&tt-lz-3} skip(1)
{&tt-lz-4} skip(1)
SPACE(50) v-print-time skip(1).

put stream PrnLibStream unformatted
v-line skip
":     :                     :" skip
":  №  :       № ГТД         :" skip
": п/п :                     :" skip
":     :                     :" skip
v-line
.

/* определяем header: заголовок, */
/* который будет выводиться на каждой странице */

find first tt-cst-year No-LOCK WHERE
           tt-cst-year.zero = yes USE-index i-year No-ERROR.

if avail tt-cst-year then
varyear-cst = tt-cst-year.in-year.
else
varyear-cst = ?.

form header
v-line1 at 1 skip
v-header-name format "x(55)" at 1
"Дата:" at 90
v-print-time format "x(20)"
v-line2 at 1
with frame topframez
width {&report-width-frame} page-top no-labels no-box .

view stream PrnLibStream frame topframez .

/* определяем footer: нижнюю часть страницы, */
/* которая будет выводиться на каждой странице */
form header
v-line skip
"ГТД за " varyear-cst "год "
"Стр." at {&report-width-25} string( page-number(PrnLibStream), ">>>9" )
"Продолжение на следующей странице " at 30 skip
with frame bottomframez
width {&report-width-frame} page-bottom no-labels no-box .

view stream PrnLibStream frame bottomframez .


form with frame zero-frm .
/*Место для тела*/

/*главный цикл zero*/

for-ii = 0.
FOR EACH tt-cst-year where
         tt-cst-year.zero = yes
    BREAK
    BY tt-cst-year.in-year:
  IF first-of(tt-cst-year.in-year) then do:
    if tt-cst-year.in-year <> ? then
    varyear-cst = tt-cst-year.in-year.
    if not first(tt-cst-year.in-year) then
    DOWN 1 stream PrnLibStream
    with FRAME zero-frm.
    DISPLAY stream PrnLibStream
    "ГТД" @ for-ii
    ("за " + string(tt-cst-year.in-year, "9999") + {&space-char} + "год") @ tt-cst-year.cst-code
    with frame zero-frm.
    DOWN 2 stream PrnLibStream
    with FRAME zero-frm.
  end.
  for-ii = for-ii + 1.
  display stream PrnLibStream
  for-ii
  tt-cst-year.cst-code
  with frame zero-frm.
  DOWN stream PrnLibStream
  with FRAME zero-frm.
END.

put stream PrnLibStream
v-line  skip
.

hide frame input-frmz .
/* Выводим завершение отчета */
/* Место для подписей */
put stream PrnLibStream
skip(2)
.

put stream PrnLibStream unformatted
"   ___________________________________      ___________________________________                 " skip
"             Руководитель                                 Подпись                         Печать"
.

/* делаем footer невидимым, чтобы он не напечатался на последней странице */
hide stream PrnLibStream frame bottomframez .
output stream PrnLibStream close.

run waitfram-hide in this-procedure .

/* вывести */
run prn-lib-prn-file in this-procedure (
                                          input my-handle
                                          ,input 8
                                          ).