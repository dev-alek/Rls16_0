block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ptlrtr.p $
$Archive: rep/r-ptlrtr.p $

Реестр на нефтепродукты за период

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Чернова Светлана Александровна
Дата создания1: 02/14/07

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

define buffer frm-clients for ub.clients.


define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-ptlrtr.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-ptlrtr.p $":U .
define variable vss-description as character no-undo initial "Реестр на нефтепродукты за период".

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-pril.i  new }
{ cmp/r-page1.i     }
{ gbl/prn-lib.i     }
{ gbl/cur-time.i    }
{ gbl/clntattr.i    }
{ gbl/waitfram.i    }


/* ширина отчета */
&scop report-width        120
&scop report-width-frame  123
&scop report-width-25     69

define variable v-ind         as integer   no-undo .
define variable v-line        as character no-undo format "X({&report-width})" .
define variable l-ps as character no-undo .
assign
  v-line = fill("-", {&report-width} )
.
define variable v-line1        as character no-undo format "X({&report-width})" .
define variable v-line2        as character no-undo format "X({&report-width})" .
define variable v-line3        as character no-undo format "X({&report-width})" .
assign
  v-line1 = v-line
  v-line2 = v-line
  v-line3 = v-line
.

/* определяем символы разделители */
&scop sym format "x(1)":U label '!':U initial ":":U

define variable sym1  as character no-undo {&sym} .
define variable sym2  as character no-undo {&sym} .
define variable sym3  as character no-undo {&sym} .
define variable sym4  as character no-undo {&sym} .
define variable sym5  as character no-undo {&sym} .
define variable sym6  as character no-undo {&sym} .
define variable sym7  as character no-undo {&sym} .
define variable sym8  as character no-undo {&sym} .
define variable sym9  as character no-undo {&sym} .

run waitfram-show in this-procedure ( {&MyWaitMess} ) .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 45
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


/* выводим заголовок отчета, */
/* который будет печататься только на первой странице */
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-host-name   as character no-undo. /*название фирмы*/
define variable v-obj-name    as character no-undo.  /*АЗС*/
define variable v-header-name as character no-undo.
define variable v-print-time  as character no-undo.
define variable vardate-shift  as   character      no-undo.
define variable vardoc-qnty like ub.doc-line.doc-qnty no-undo.
define variable varcli-qnty like ub.doc-line.cli-qnty no-undo.

define variable str-inv  as character initial "" no-undo .
define variable str-inv1 as character initial "" no-undo .

define buffer buf_doc-attr     for ub.doc-attr.
define buffer buf_trn-doc      for ub.trn-doc .
define buffer buf_doc-line     for ub.doc-line .
define buffer buf_goods        for ub.goods .
define buffer buf_clients      for ub.clients .
define buffer buf_clients-attr for ub.clients-attr .

&scop ttl "                           Р Е Е С Т Р  Н А  Н Е Ф Т Е П Р О Д У К Т Ы  З А  П Е Р И О Д "
assign
  v-header-name = {&ttl}
  v-print-time  = cur-time-string()
  .

&scop format-qnty   format ">>>,>>>,>>9.<<<"

/* определяем фрейм в котором будут выводиться данные */
&scop frm-clmn-01 format "x(8)"
&scop lb-clmn-01  column-label "1"
&scop frm-clmn-02 format "x(14)"
&scop lb-clmn-02  column-label "2"
&scop frm-clmn-03 {&format-qnty}
&scop lb-clmn-03  column-label "3"
&scop frm-clmn-04 {&format-qnty}
&scop lb-clmn-04  column-label "4"
&scop frm-clmn-05 {&format-qnty}
&scop lb-clmn-05  column-label "5"
&scop frm-clmn-06 {&format-qnty}
&scop lb-clmn-06  column-label "6"
&scop frm-clmn-07 {&format-qnty}
&scop lb-clmn-07  column-label "7"
&scop frm-clmn-08 format "x(29)"
&scop lb-clmn-08  column-label "8"

define frame doc-line-frm
  sym1  space(0) vardate-shift           {&frm-clmn-01} {&lb-clmn-01} space(0)
  sym2  space(0) buf_trn-doc.doc-code        {&frm-clmn-02} {&lb-clmn-02} space(0)
  sym3  space(0) buf_doc-line.doc-qnty       {&frm-clmn-03} {&lb-clmn-03} space(0)
  sym4  space(0) vardoc-qnty             {&frm-clmn-04} {&lb-clmn-04} space(0)
  sym5  space(0) buf_doc-line.doc-density    {&frm-clmn-05} {&lb-clmn-05} space(0)
  sym6  space(0) buf_doc-line.cli-qnty       {&frm-clmn-06} {&lb-clmn-06} space(0)
  sym7  space(0) varcli-qnty             {&frm-clmn-07} {&lb-clmn-07} space(0)
  sym8  space(0) l-ps                    {&frm-clmn-08} {&lb-clmn-08} space(0)
  sym9  space(0)
  with width {&report-width-frame}  down stream-io use-text .

form with frame doc-line-frm .

find first buf_goods where buf_goods.gds-code = pargds-code no-lock.
/*АЗС*/
for each obj-list :
          parobj-type = obj-list.obj-type .
          parobj-code = obj-list.obj-code .
          find first buf_clients no-lock
            where buf_clients.obj-type = parobj-type
              and buf_clients.obj-code = parobj-code
            .
          assign
            v-obj-name = buf_clients.obj-name
          .
          /*Своя фирма*/

          { gbl/hostcode.i parobj-type parobj-code v-host-code }

          find first frm-clients no-lock
            where frm-clients.obj-type = {&cmp}
              and frm-clients.obj-code = v-host-code
            .
          assign
            v-host-name = frm-clients.obj-name
          .

          put stream PrnLibStream unformatted
            "   Наименование организации " string(v-host-name + fill(" ", 40), "x(40)")  skip
            "   АЗС: "  v-obj-name  skip
            {&ttl} skip
            "   Начало периода " (if pardate-shift <= 2 then string(parstart_date) else string(parstart_date) + ":" + string(parstart_shift_num)) skip
            "   Конец периода  " (if pardate-shift <= 2 then string(parend_date)   else string(parend_date)   + ":" + string(parend_shift_num))   skip
            "   Наименование нефтепродукта " buf_goods.artic " " buf_goods.gds-name skip
            .

          put stream PrnLibStream unformatted
            v-line skip
            STRING("!         ", "X(9)") STRING("!              ", "X(15)") STRING("!            ", "X(13)") STRING("!            ", "X(13)") STRING("!            ", "X(13)") STRING("!            ", "X(13)") STRING("!            !", "X(14)") STRING("                             !", "X(30)")  skip
            STRING("!         ", "X(9)") STRING("!              ", "X(15)") STRING("! Количество ", "X(13)") STRING("!Суммарно от ", "X(13)") STRING("!Плотность по", "X(13)") STRING("! Количество ", "X(13)") STRING("!Суммарно от !", "X(14)") STRING("            № ТТН            !", "X(30)")  skip
            STRING("!  Дата   ", "X(9)") STRING("!    № ТТН     ", "X(15)") STRING("!   по ТТН   ", "X(13)") STRING("!   начала   ", "X(13)") STRING("!    ТТН     ", "X(13)") STRING("!      по    ", "X(13)") STRING("!   начала   !", "X(14)") STRING("         от поставщика       !", "X(30)")  skip
            STRING("!         ", "X(9)") STRING("!              ", "X(15)") STRING("!  в литрах  ", "X(13)") STRING("!  периода   ", "X(13)") STRING("! в г/куб.см ", "X(13)") STRING("!   ТТН в кг ", "X(13)") STRING("!   периода  !", "X(14)") STRING("                             !", "X(30)")  skip
            STRING("!         ", "X(9)") STRING("!              ", "X(15)") STRING("!            ", "X(13)") STRING("!  в литрах  ", "X(13)") STRING("!            ", "X(13)") STRING("!            ", "X(13)") STRING("!    в кг    !", "X(14)") STRING("                             !", "X(30)")  skip
            v-line
            .
          /* определяем header: заголовок, */
          /* который будет выводиться на каждой странице */
          form header
            v-line1 at 1 skip
            v-header-name format "x(50)" at 1
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
          assign vardoc-qnty = 0
                varcli-qnty = 0.
          { rep/q-inptl.i
          &inc-file   = "rep/r-ptlrtr.i"
          &gds-buffer = "buf_goods"
          &add-query  = " and buf_trn-doc.doc-type = {&income} and buf_trn-doc.internal = no"
          }
          /* Выводим завершение отчета */
          /* Место для подписей */
          put stream PrnLibStream
            v-line
            skip(2)
            .
          put stream PrnLibStream unformatted
            "   Начальник АЗС ___________________________ "
            .
end.
/* делаем footer невидимым, чтобы он не напечатался на последней странице */
hide stream PrnLibStream frame bottomframe .
output stream PrnLibStream close.
run waitfram-hide in this-procedure .

/* вывести */
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 7
                                          ).