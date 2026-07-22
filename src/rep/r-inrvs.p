block-level on error undo, throw.
/*

$Revision: 099a383cf864, 290, rls $
$Author: PGridchina $
$Date: Tue Dec 01 19:11:24 2015 +0300 $
$Workfile: r-inrvs.p $
$Archive: rep/r-inrvs.p $

Приходная накладная по топливу

Автор: Уханов Дмитрий Юрьевич
Дата создания: 02/18/09
Author: Dmitry Ukhanov
Creation date: 02/18/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 09/19/05

*/

def var vss-revision    as character no-undo init "$Revision: 099a383cf864, 290, rls $":U .
def var vss-author      as character no-undo init "$Author: PGridchina $":U .
def var vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:24 2015 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: r-inrvs.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/r-inrvs.p $":U .
def var vss-description as character no-undo init "Приходная накладная по топливу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i new }
{ gbl/lastdate.i }
{ str/in-vatp.i def}
{ gbl/cur-time.i }
{ gbl/waitfram.i }

/* параметры отчета */
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-recid              as recid            no-undo.

def stream repstr .

/* ширина отчета */
&scop report-width        195
&scop report-width-frame  197
&scop report-width-25     169

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
define variable varpl-qnty              like ub.doc-line.doc-qnty   no-undo.
define variable varpl-cli-qnty          like ub.doc-line.cli-qnty   no-undo.
define variable varpl-fact-qnty         like ub.doc-line.fact-qnty  no-undo.
define variable varpl-state-qnty        like ub.doc-line.fact-qnty  no-undo.
define variable varpl-acc-prc-cur-cli   like ub.doc-line.price-cli  no-undo.
define variable varpl-acc-sum-cur-cli   like ub.doc-line.price-cli  no-undo.
define variable varpl-sale-prc-cur-base like ub.doc-line.price-base no-undo.
define variable varpl-sale-sum-cur-base like ub.doc-line.price-base no-undo.
define variable varpl-acc-prc-cur-base  like ub.doc-line.price-base no-undo.
define variable varpl-acc-sum-cur-base  like ub.doc-line.price-base no-undo.
define variable varpl-num               like ub.place.pl-code       no-undo.
define variable varcar-num              as   character           no-undo.
define variable varcar-volume           as   character           no-undo.
define variable varpl-acc-sum-cur-cli-doc   like ub.doc-line.price-cli  no-undo.
define variable varpl-sale-sum-cur-base-doc like ub.doc-line.price-base no-undo.
define variable varpl-acc-sum-cur-base-doc  like ub.doc-line.price-base no-undo.
define buffer bef-rvs-doc for ub.rvs-doc.
define buffer aft-rvs-doc for ub.rvs-doc.
define buffer bef-rvs-line for ub.rvs-line.
define buffer aft-rvs-line for ub.rvs-line.


/* определяем символы разделители */
&scop sym format "x(1)":u label '!':u init ":":u

def var sym1          as character no-undo {&sym} .
def var sym2          as character no-undo {&sym} .
def var sym3          as character no-undo {&sym} .
def var sym4          as character no-undo {&sym} .
def var sym5          as character no-undo {&sym} .
def var sym6          as character no-undo {&sym} .
def var sym7          as character no-undo {&sym} .
def var sym8          as character no-undo {&sym} .
def var sym9          as character no-undo {&sym} .
def var sym10         as character no-undo {&sym} .
def var sym11         as character no-undo {&sym} .
def var sym12         as character no-undo {&sym} .
def var sym13         as character no-undo {&sym} .
def var sym14         as character no-undo {&sym} .
def var sym15         as character no-undo {&sym} .
def var sym16         as character no-undo {&sym} .
def var sym17         as character no-undo {&sym} .

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).

run waitfram-show in this-procedure
  (input {&MyWaitMess}
  ) .

{ cmp/open-out.i stream repstr " " 45 }

find first ub.trn-doc no-lock
  where recid(ub.trn-doc) = p-recid no-error.
if not available ub.trn-doc then do:
  message
    vss-workfile vss-revision vss-description skip
    "Документ не найден" skip
    view-as alert-box.
  undo, return error .
end.

/* выводим заголовок отчета, */
/* который будет печататься только на первой странице */
def var v-host-name   as character no-undo. /*название фирмы*/
def var v-host-city   as character no-undo. /*адрес*/
def var v-obj-name    as character no-undo.  /*АЗС*/
def var v-cli-name    as character no-undo. /*поставщик*/
def var v-cli-city    as character no-undo. /*адрес поставщика*/
def var v-header-name as character no-undo.
def var v-print-time  as character no-undo.
def var v-curr-abbr   as character no-undo.
def var v-bef-rvs     as character no-undo.
def var v-aft-rvs     as character no-undo.
assign
  v-header-name = "П Р И Х О Д Н А Я  Н А К Л А Д Н А Я  П О  Т О П Л И В У  № " + ub.trn-doc.doc-code
  v-print-time  = cur-time-string()
.
/*АЗС*/
find first ub.clients no-lock
  where ub.clients.obj-type = ub.trn-doc.obj-type
    and ub.clients.obj-code = ub.trn-doc.obj-code
  .
assign
  v-obj-name = ub.clients.obj-name
.
/*Поставщик*/
find first ub.clients no-lock
  where ub.clients.obj-type = ub.trn-doc.cli-type
    and ub.clients.obj-code = ub.trn-doc.cli-code
  .
assign
  v-cli-name = ub.clients.obj-name
.

case ub.clients.obj-type :
  when {&cmp} then do:
    find first ub.firm no-lock
      where ub.firm.firm-code = ub.clients.obj-code
      .
    assign
      v-cli-city = ub.firm.city
    .
  end.
  when {&prs} then do:
    find first ub.person no-lock
      where ub.person.psn-code = ub.clients.obj-code
      .
    assign
      v-cli-city = ub.person.city
    .
  end.

end.
/*Своя фирма*/
find first ub.clients no-lock
  where ub.clients.obj-type = {&cmp}
    and ub.clients.obj-code = ub.trn-doc.host-code
  .
assign
  v-host-name = ub.clients.obj-name
.
find first ub.firm no-lock
  where ub.firm.firm-code = ub.clients.obj-code
  .
assign
  v-host-city = ub.firm.city
.
/*Валюта*/
find first ub.currency where ub.currency.curr-code = ub.trn-doc.exch-code no-lock.
ASSIGN v-curr-abbr = ub.currency.curr-abbr.

/*Протокол измерений до слива*/
find first bef-rvs-doc where bef-rvs-doc.out-code = ub.trn-doc.doc-code and
                             bef-rvs-doc.rvs-type = {&rvs-before-doc}    no-lock no-error.
ASSIGN v-bef-rvs = if available bef-rvs-doc then string(bef-rvs-doc.rvs-code) else "сверка не производилась".
/*Протокол измерений после слива*/
find first aft-rvs-doc where aft-rvs-doc.out-code = ub.trn-doc.doc-code and
                             aft-rvs-doc.rvs-type = {&rvs-after-doc}     no-lock no-error.
ASSIGN v-aft-rvs = if available aft-rvs-doc then string(aft-rvs-doc.rvs-code) else "сверка не производилась".
&scop format-qnty   format ">>>,>>9.<<<"
&scop format-sign   format "->,>>>,>>9.99"

/* определяем фрейм в котором будут выводиться данные */
&scop frm-clmn-01 format "x(7)"
&scop lb-clmn-01  column-label "1"
&scop frm-clmn-02 format "x(35)"
&scop lb-clmn-02  column-label "2"
&scop frm-clmn-03 {&format-qnty}
&scop lb-clmn-03  column-label "3"
&scop frm-clmn-04 format ">.9999"
&scop lb-clmn-04  column-label "4"
&scop frm-clmn-05 {&format-qnty}
&scop lb-clmn-05  column-label "5"
&scop frm-clmn-06 {&format-qnty}
&scop lb-clmn-06  column-label "6"
&scop frm-clmn-07 {&format-qnty}
&scop lb-clmn-07  column-label "7"
&scop frm-clmn-08 format "->>,>>9.99"
&scop lb-clmn-08  column-label "8"
&scop frm-clmn-09 {&format-sign}
&scop lb-clmn-09  column-label "9=6*8"
&scop frm-clmn-10 format "->>,>>9.99"
&scop lb-clmn-10  column-label "10"
&scop frm-clmn-11 {&format-sign}
&scop lb-clmn-11  column-label "11=10*6"
&scop frm-clmn-12 format "->>,>>9.99"
&scop lb-clmn-12  column-label "12"
&scop frm-clmn-13 {&format-sign}
&scop lb-clmn-13  column-label "13=12*6"
&scop frm-clmn-14 format " 999999999"
&scop lb-clmn-14  column-label "14"
&scop frm-clmn-15 format "X(8)"
&scop lb-clmn-15  column-label "15"
&scop frm-clmn-16 format "X(11)"
&scop lb-clmn-16  column-label "16"
define frame doc-line-frm
  sym1  space(0) ub.goods.artic             {&frm-clmn-01} {&lb-clmn-01} space(0)
  sym2  space(0) ub.goods.gds-name          {&frm-clmn-02} {&lb-clmn-02} space(0)
  sym3  space(0) varpl-qnty              {&frm-clmn-03} {&lb-clmn-03} space(0)
  sym4  space(0) ub.doc-line.fact-density   {&frm-clmn-04} {&lb-clmn-04} space(0)
  sym5  space(0) varpl-cli-qnty          {&frm-clmn-05} {&lb-clmn-05} space(0)
  sym6  space(0) varpl-fact-qnty         {&frm-clmn-06} {&lb-clmn-06} space(0)
  sym7  space(0) varpl-state-qnty        {&frm-clmn-07} {&lb-clmn-07} space(0)
  sym8  space(0) varpl-acc-prc-cur-cli   {&frm-clmn-08} {&lb-clmn-08} space(0)
  sym9  space(0) varpl-acc-sum-cur-cli   {&frm-clmn-09} {&lb-clmn-09} space(0)
  sym10 space(0) varpl-sale-prc-cur-base {&frm-clmn-10} {&lb-clmn-10} space(0)
  sym11 space(0) varpl-sale-sum-cur-base {&frm-clmn-11} {&lb-clmn-11} space(0)
  sym12 space(0) varpl-acc-prc-cur-base  {&frm-clmn-12} {&lb-clmn-12} space(0)
  sym13 space(0) varpl-acc-sum-cur-base  {&frm-clmn-13} {&lb-clmn-13} space(0)
  sym14 space(0) varpl-num               {&frm-clmn-14} {&lb-clmn-14} space(0)
  sym15 space(0) varcar-num              {&frm-clmn-15} {&lb-clmn-15} space(0)
  sym16 space(0) varcar-volume           {&frm-clmn-16} {&lb-clmn-16} space(0)
  sym17 space(0)
  with width {&report-width-frame}  stream-io use-text .

form with frame doc-line-frm .

    define variable v-oper-name    as character    no-undo.
    { gbl/usrnick.i
        ub.trn-doc.creid
        v-oper-name
    }
put stream repstr unformatted
  string(v-host-name + fill(" ", 40), "x(40)")  v-host-city skip
  "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"  v-print-time skip
  "   Номер смены "  ub.trn-doc.shift-name  "    Дата начала смены "  ub.trn-doc.shift-date skip
  "                                 П Р И Х О Д Н А Я  Н А К Л А Д Н А Я  П О  Т О П Л И В У  № "  ub.trn-doc.doc-code skip
  "   АЗС: "  v-obj-name  "    Оператор: "  v-oper-name skip
  "   Поставщик: "  v-cli-name skip
  "    Адрес поставщика: "  v-cli-city skip
  "   По документу: "  ub.trn-doc.doc-code   " от "  string( if ub.trn-doc.fact-date <> ? then ub.trn-doc.fact-date else ub.trn-doc.doc-date )
  " г.          Валюта: "  v-curr-abbr " Курс: " ub.trn-doc.exch-rate " Шкала: " ub.trn-doc.exch-scale skip
  "   Номер протокол измерений до слива: " v-bef-rvs "      Номер протокола после слива и стабилизации: " v-aft-rvs skip
  .

put stream repstr unformatted
  v-line skip
  STRING("!       ", "X(8)") STRING("!                                   ", "X(36)") STRING("!        ", "X(9)") STRING("! Плот ", "X(7)") STRING("!        ", "X(9)") STRING("! Фактич.", "X(9)") STRING("!Фактич. ", "X(9)") STRING("!  Учетная ", "X(11)") STRING("!  Сумма по   ", "X(14)") STRING("! Розничная", "X(11)") STRING("!  Сумма по   ", "X(14)") STRING("!  Учетная ", "X(11)") STRING("!  Сумма по   ", "X(14)") STRING("!          ", "X(11)") STRING("! Гос    ", "X(9)") STRING("!           !", "X(13)") skip
  STRING("!       ", "X(8)") STRING("!                                   ", "X(36)") STRING("!Объем по", "X(9)") STRING("!ность ", "X(7)") STRING("!Кол-во  ", "X(9)") STRING("! кол-во ", "X(9)") STRING("!объем по", "X(9)") STRING("!    цена  ", "X(11)") STRING("!  учет. цене ", "X(14)") STRING("!   цена в ", "X(11)") STRING("!  розн. цене ", "X(14)") STRING("!   цена в ", "X(11)") STRING("!  учет. цене ", "X(14)") STRING("!  Номер   ", "X(11)") STRING("! номер  ", "X(9)") STRING("!   Объем   !", "X(13)") skip
  STRING("!Артикул", "X(8)") STRING("!            Наименование           ", "X(36)") STRING("!ТТН в л.", "X(9)") STRING("!поТТН ", "X(7)") STRING("! по ТТН ", "X(9)") STRING("! принят.", "X(9)") STRING("!счетчику", "X(9)") STRING("!  в валюте", "X(11)") STRING("!  в валюте   ", "X(14)") STRING("!  базовой ", "X(11)") STRING("!  в базовой  ", "X(14)") STRING("!  базовой ", "X(11)") STRING("!  в базовой  ", "X(14)") STRING("!резервуара", "X(11)") STRING("! авто   ", "X(9)") STRING("!  цистерны !", "X(13)") skip
  STRING("!       ", "X(8)") STRING("!                                   ", "X(36)") STRING("!        ", "X(9)") STRING("! куб  ", "X(7)") STRING("!  в кг  ", "X(9)") STRING("!топлива ", "X(9)") STRING("!в литрах", "X(9)") STRING("! накладной", "X(11)") STRING("!  накладной  ", "X(14)") STRING("!   валюте ", "X(11)") STRING("!   валюте    ", "X(14)") STRING("!   валюте ", "X(11)") STRING("!   валюте    ", "X(14)") STRING("!          ", "X(11)") STRING("!цистерны", "X(9)") STRING("!           !", "X(13)") skip
  STRING("!       ", "X(8)") STRING("!                                   ", "X(36)") STRING("!        ", "X(9)") STRING("! см   ", "X(7)") STRING("!        ", "X(9)") STRING("!в литрах", "X(9)") STRING("!        ", "X(9)") STRING("!          ", "X(11)") STRING("!             ", "X(14)") STRING("!          ", "X(11)") STRING("!             ", "X(14)") STRING("!          ", "X(11)") STRING("!             ", "X(14)") STRING("!          ", "X(11)") STRING("!        ", "X(9)") STRING("!           !", "X(13)") skip
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


for each ub.doc-line
  where ub.doc-line.doc-code = ub.trn-doc.doc-code no-lock,
  first ub.goods where ub.goods.artic     = ub.doc-line.artic     and
                    ub.goods.prod-type = ub.doc-line.prod-type and
                    ub.goods.prod-code = ub.doc-line.prod-code no-lock,
  each ub.parts where ub.parts.out-code  = ub.doc-line.doc-code  and
                   ub.parts.obj-type  = ub.doc-line.obj-type  and
                   ub.parts.obj-code  = ub.doc-line.obj-code  and
                   ub.parts.artic     = ub.doc-line.artic     and
                   ub.parts.prod-type = ub.doc-line.prod-type and
                   ub.parts.prod-code = ub.doc-line.prod-code no-lock
 break by ub.parts.artic
       by ub.parts.prod-type
       by ub.parts.prod-code
       by ub.parts.pl-code
:
  /*Текущая продажная цена по партиям ест-но равна текущей продажной партии в строке*/
  if first-of(ub.parts.prod-code) then do:
     /*Атрибуты линии*/
     find first ub.doc-attr where ub.doc-attr.doc-code  = ub.doc-line.doc-code and
                                  ub.doc-attr.attr-code = {&trdcattr-car-num} no-lock no-error.
     ASSIGN
     varcar-num    = if available ub.doc-attr then ub.doc-attr.attr-value else "".
     find first ub.doc-line-attr where ub.doc-line-attr.doc-code  = ub.doc-line.doc-code and
                                    ub.doc-line-attr.gds-code  = ub.goods.gds-code    and
                                    ub.doc-line-attr.attr-code = "car-vol" no-lock no-error.
     ASSIGN
     varcar-volume = if available ub.doc-line-attr then ub.doc-line-attr.attr-value else "".
     for each ub.gds-dtl where ub.gds-dtl.doc-code  = ub.doc-line.doc-code  and
                            ub.gds-dtl.artic     = ub.doc-line.artic     and
                            ub.gds-dtl.prod-type = ub.doc-line.prod-type and
                            ub.gds-dtl.prod-code = ub.doc-line.prod-code no-lock :
        accumulate ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty (total)
                   ub.gds-dtl.fact-qnty (total).
     end.
     ASSIGN varpl-sale-prc-cur-base = (accum total ub.gds-dtl.cur-base * ub.gds-dtl.fact-qnty) / (accum total ub.gds-dtl.fact-qnty).
  end.
  /* считаем количество обработанных строк */
  assign
    v-ind = v-ind + 1
  .
  process events .

  run waitfram-show in this-procedure
    (input "Печать приходной накладной. Обработано строк: " + string(v-ind)
    ) .
  /*Получим НДС из in-vatp.i*/
  { str/in-vatp.i calc-parts ub.parts. ub.trn-doc. g}
  ACCUMULATE slt-base-loc * ub.parts.fact-qnty (TOTAL)
             vat-base-loc * ub.parts.fact-qnty (TOTAL).

  ACCUMULATE
  ub.parts.qnty                           (TOTAL BY ub.parts.pl-code)
  ub.parts.cli-qnty                       (TOTAL BY ub.parts.pl-code)
  ub.parts.fact-qnty                      (TOTAL BY ub.parts.pl-code)
  .


  if last-of(ub.parts.pl-code) then do:
     if available bef-rvs-doc and
        available aft-rvs-doc then do:
        find first bef-rvs-line where bef-rvs-line.rvs-code = bef-rvs-doc.rvs-code and
                                      bef-rvs-line.obj-type = bef-rvs-doc.obj-type and
                                      bef-rvs-line.obj-code = bef-rvs-doc.obj-code and
                                      bef-rvs-line.pl-code  = ub.parts.pl-code        and
                                      bef-rvs-line.gds-code = ub.goods.gds-code       no-lock.
        find first aft-rvs-line where aft-rvs-line.rvs-code = aft-rvs-doc.rvs-code and
                                      aft-rvs-line.obj-type = aft-rvs-doc.obj-type and
                                      aft-rvs-line.obj-code = aft-rvs-doc.obj-code and
                                      aft-rvs-line.pl-code  = ub.parts.pl-code        and
                                      aft-rvs-line.gds-code = ub.goods.gds-code       no-lock.
     end.
     ASSIGN
       varpl-qnty              = (ACCUM TOTAL BY ub.parts.pl-code ub.parts.qnty)
       varpl-cli-qnty          = (ACCUM TOTAL BY ub.parts.pl-code ub.parts.cli-qnty)
       varpl-fact-qnty         = (ACCUM TOTAL BY ub.parts.pl-code ub.parts.fact-qnty)
       varpl-state-qnty        = (if available bef-rvs-doc and available aft-rvs-doc then aft-rvs-line.state-measure-qnty - bef-rvs-line.state-measure-qnty else ?)
       varpl-acc-prc-cur-cli   = ub.doc-line.price-rubl / ub.trn-doc.exch-rate * ub.trn-doc.exch-scale
       varpl-acc-sum-cur-cli   = varpl-acc-prc-cur-cli   * varpl-fact-qnty
       varpl-sale-sum-cur-base = varpl-sale-prc-cur-base * varpl-fact-qnty
       varpl-acc-prc-cur-base  = ub.doc-line.price-base
       varpl-acc-sum-cur-base  = varpl-acc-prc-cur-base * varpl-fact-qnty
       varpl-num               = ub.parts.pl-code.
   /*Для подведения итогов*/
   ASSIGN
    varpl-acc-sum-cur-cli-doc   = varpl-acc-prc-cur-cli   * varpl-qnty
    varpl-sale-sum-cur-base-doc = varpl-sale-prc-cur-base * varpl-qnty
    varpl-acc-sum-cur-base-doc  = varpl-acc-prc-cur-base  * varpl-qnty.
   ACCUMULATE varpl-acc-sum-cur-cli        (TOTAL)
              varpl-sale-sum-cur-base      (TOTAL)
              varpl-acc-sum-cur-base       (TOTAL)
              varpl-acc-sum-cur-cli-doc    (TOTAL)
              varpl-sale-sum-cur-base-doc  (TOTAL)
              varpl-acc-sum-cur-base-doc   (TOTAL).

    display stream repstr
      sym1  ub.goods.artic
      sym2  ub.goods.gds-name
      sym3  varpl-qnty
      sym4  ub.doc-line.fact-density
      sym5  varpl-cli-qnty
      sym6  varpl-state-qnty
      sym7  varpl-fact-qnty
      sym8  varpl-acc-prc-cur-cli
      sym9  varpl-acc-sum-cur-cli
      sym10 varpl-sale-prc-cur-base
      sym11 varpl-sale-sum-cur-base
      sym12 varpl-acc-prc-cur-base
      sym13 varpl-acc-sum-cur-base
      sym14 varpl-num
      sym15 varcar-num
      sym16 varcar-volume
      sym17
      with frame doc-line-frm 0 down.
      down stream repstr 1 with frame doc-line-frm.
  end.
end.

put stream repstr
  v-line  skip
  .
hide frame input-frm .
put stream repstr
  skip
  "   П О  Ф А К Т У:                                                               П О  Т Т Н :" skip
  "   Итого в валюте накладной по учетной цене " (ACCUM TOTAL varpl-acc-sum-cur-cli)    format ">>,>>>,>>9.99" "                           Итого в валюте накладной по учетной цене" (ACCUM TOTAL varpl-acc-sum-cur-cli-doc)   format ">>,>>>,>>9.99" skip
  "   Итого в базовой валюте по учетной цене   " (ACCUM TOTAL varpl-acc-sum-cur-base)   format ">>,>>>,>>9.99" "                           Итого в базовой валюте по учетной цене  " (ACCUM TOTAL varpl-acc-sum-cur-base-doc)  format ">>,>>>,>>9.99" skip
  "   Итого в базовой валюте по розничной цене " (ACCUM TOTAL varpl-sale-sum-cur-base)  format ">>,>>>,>>9.99" "                           Итого в базовой валюте по розничной цене" (ACCUM TOTAL varpl-sale-sum-cur-base-doc) format ">>,>>>,>>9.99" skip
  "   В том числе в базовой валюте по учетной цене:" skip
  "          НДС                                " (ACCUM TOTAL vat-base-loc * ub.parts.fact-qnty) format ">>,>>>,>>9.99" skip
  "          Без НДС                            " (ACCUM TOTAL varpl-acc-sum-cur-base) - (ACCUM TOTAL vat-base-loc * ub.parts.fact-qnty) format ">>,>>>,>>9.99" skip
  "          НсП                                " (ACCUM TOTAL slt-base-loc * ub.parts.fact-qnty) format ">>,>>>,>>9.99" skip
  "          ГСМ                                "
  .

/* Выводим завершение отчета */
/* Место для подписей */
put stream repstr
  skip(2)
  .
put stream repstr unformatted
  "   Топливо сдал ___________________________                                          Топливо принял _________________________ "
  .

/* делаем footer невидимым, чтобы он не напечатался на последней странице */
hide stream repstr frame bottomframe .
output stream repstr close.
run waitfram-hide in this-procedure .

/* вывести */
{ rep/q-print.i 8}