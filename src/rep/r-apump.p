block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-apump.p $
$Archive: rep/r-apump.p $

Журнал Инвентаризации показаний счетчиков ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/30/09
Author: Dmitry Ukhanov
Creation date: 01/30/09

Автор1: Суслов Алексей Юрьевич
Дата создания1: 03/27/06


*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-recid as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-apump.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-apump.p $":U .
define variable vss-description as character no-undo init "Журнал Инвентаризации показаний счетчиков ТРК".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-page1.i new }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }
{ gbl/cur-time.i    }
{ gbl/waitfram.i }

/* ширина отчета */
&scop report2-width        75
&scop report-width        105
&scop report-width-frame  106
&scop report-width-25     95



define variable v-ind         as integer   no-undo .
define variable n-pump        as integer   no-undo .
define variable v-line        as character no-undo format "X({&report-width})" .
define variable l-line        as character no-undo format "X({&report2-width})" .

define buffer buf_icnt-doc  for ub.icnt-doc.
define buffer buf_icnt-line for ub.icnt-line.
define buffer buf_goods     for ub.goods.
define buffer buf_clients for ub.clients .

assign
  v-line = fill("-", {&report-width} )
  l-line = fill("-", {&report2-width} )
.
define variable v-line1        as character no-undo format "X({&report-width})" .
define variable v-line2        as character no-undo format "X({&report-width})" .
define variable l-line1        as character no-undo format "X({&report2-width})" .
define variable l-line2        as character no-undo format "X({&report2-width})" .

assign
  v-line1 = v-line
  v-line2 = v-line
  l-line1 = v-line
  l-line2 = v-line

.

/* определяем символы разделители */
&scop sym format "x(1)":u  init ":":u

define variable sym1          as character no-undo {&sym} .
define variable sym2          as character no-undo {&sym} .
define variable sym3          as character no-undo {&sym} .
define variable sym4          as character no-undo {&sym} .
define variable sym5          as character no-undo {&sym} .
define variable sym6          as character no-undo {&sym} .
define variable sym7          as character no-undo {&sym} .
define variable sym8          as character no-undo {&sym} .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CP_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).


find first buf_icnt-doc no-lock
  where recid(buf_icnt-doc) = p-recid no-error.

if not available buf_icnt-doc then do:
 message
    vss-workfile vss-revision vss-description skip
    "Документ не найден" skip
    view-as alert-box.
  undo, return error .
end.
if buf_icnt-doc.doc-type <> {&icnt-doc} then do:
 message
    vss-workfile vss-revision vss-description skip
    substitute("Документ &1 не может быть напечатан по данной форме", buf_icnt-doc.doc-code) skip
    view-as alert-box.
  undo, return error .
end.


run waitfram-show in this-procedure ( {&MyWaitMess} ) .
/* выводим заголовок отчета, */
/* который будет печататься только на первой странице */

define variable v-obj-name as character no-undo .
define variable v-header-name as character no-undo .
define variable v-print-time  as character no-undo .
define variable v-host-name   as character no-undo. /*название фирмы*/
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer frm-clients for ub.clients.

assign
  v-header-name = substitute(" N док-та &1", buf_icnt-doc.doc-code)
  v-print-time  = cur-time-string()
.

find first buf_clients no-lock
  where buf_clients.obj-type = buf_icnt-doc.obj-type
    and buf_clients.obj-code = buf_icnt-doc.obj-code
  .
assign
  v-obj-name = buf_clients.obj-name
.

{ gbl/hostcode.i buf_icnt-doc.obj-type buf_icnt-doc.obj-code v-host-code }

find first frm-clients no-lock
  where frm-clients.obj-type = {&cmp}
    and frm-clients.obj-code = v-host-code
  .
assign
  v-host-name = frm-clients.obj-name
.

/* журнал */
put stream PrnLibStream unformatted
  string(v-host-name + fill(" ", 40), "x(40)")  skip
  string(v-obj-name + fill(" ", 40), "x(40)")  skip
  v-print-time skip
  "                                         Ж У Р Н А Л" skip
  "                              инвентаризации показаний счетчиков ТРК" skip
  skip(2)
  "Смена № " + string(buf_icnt-doc.shift-name) + " от " + string(buf_icnt-doc.shift-date,"99/99/9999") skip
  "Дата и время снятия показаний " + v-print-time skip
  string( if buf_icnt-doc.fact-date <> ? then buf_icnt-doc.fact-date else buf_icnt-doc.doc-date ) skip
  buf_icnt-doc.doc-code  + " дата " + string( if buf_icnt-doc.fact-date <> ? then buf_icnt-doc.fact-date else buf_icnt-doc.doc-date ) skip
  .

put stream PrnLibStream unformatted
  v-line skip
  "! № !                                   !      Код       !   Показание   !  Показание   !               !" skip
  "!ТРК! Наименование продукта             !    продукта    ! механического ! электронного !    Дельта     !" skip
  "!   !                                   !                !   счетчика    !  счетчика    !               !" skip
  v-line skip
  "! 1 !               2                   !        3       !        4      !      5       !       6       !" skip
  v-line /* skip */
.

/* определяем header: заголовок, */
/* который будет выводиться на каждой странице */
form header
  v-header-name format "x(50)" at 1
  "Дата:" at 60
  v-print-time format "x(20)"
  "стр." + string( page-number(PrnLibStream), ">>>9" )  at {&report-width-25}
  with frame topframe
  width {&report-width-frame} page-top  no-labels   no-box stream-io use-text.
 view stream PrnLibStream frame topframe .

  form header
    v-line1 at 1 skip
    "! 1 !               2                   !        3       !       4       !      5       !       6       !"  at 1
    v-line2 at 1
    with frame top2frame
    width {&report-width-frame} page-top no-labels  no-box stream-io use-text.
   view stream PrnLibStream frame top2frame .

/* определяем footer: нижнюю часть страницы, */
/* которая будет выводиться на каждой странице */
form header
  v-line at 1 skip
  "Продолжение на следующей странице" at 30 skip
  with frame bottomframe
  width {&report-width-frame} page-bottom no-labels no-box stream-io use-text.
view stream PrnLibStream frame bottomframe .


define variable v-bar-code  like ub.bar-code.b-code no-undo  .
define variable v-column-4  as decimal no-undo   format "->>,>>>,>>9.99" .
define variable v-column-5  as decimal no-undo   format "->>,>>>,>>9.99" .
define variable v-column-6  as decimal no-undo   format "->>>,>>>,>>9.99" .

/* определяем фрейм в котором будут выводиться данные */
define frame icnt-line-frm
sym1  no-label space(0)  n-pump         format ">>9"   no-label space(0)
sym2  no-label space(0) buf_goods.gds-name  format "x(35)" no-label  space(0)
sym3  no-label space(4) v-bar-code   no-label  space(3)
sym4  no-label space(1) v-column-4   no-label space(0)
sym5  no-label space(0) v-column-5   no-label space(0)
sym6  no-label space(0) v-column-6   no-label space(0)
sym7  no-label space(0)
with width {&report-width-frame}  down stream-io use-text  no-labels no-box.

/* view stream PrnLibStream frame icnt-line-frm  . */
for each buf_icnt-line no-lock
  where buf_icnt-line.doc-code = buf_icnt-doc.doc-code with frame icnt-line-frm :
    find first buf_goods no-lock  where buf_goods.gds-code     = buf_icnt-line.gds-code no-error .
    { gbl/gdsbcode.i buf_icnt-line.gds-code ? v-bar-code  }


  /* считаем количество обработанных строк */
  assign
    v-ind = v-ind + 1

  .
  run waitfram-show in this-procedure ("Печать документа. Обработано строк: " + string(v-ind) ) .
      n-pump      = buf_icnt-line.pump-code .
      v-column-4  = buf_icnt-line.state-mh-cnt .
      v-column-5  = buf_icnt-line.state-el-cnt . /* электронный счетчик */
      v-column-6  = buf_icnt-line.state-el-cnt - buf_icnt-line.state-mh-cnt. /* дельта */

    display stream PrnLibStream
    frame icnt-line-frm
      sym1  n-pump
      sym2  buf_goods.gds-name
      sym3
      v-bar-code
      sym4
      v-column-4
      sym5
      v-column-5
      sym6
      v-column-6
      sym7
      .
     down stream PrnLibStream  .
End.

hide frame bottomframe .
hide frame top2frame .
hide frame input-frm .
hide frame icnt-line-frm .
/* Выводим завершение отчета */
/* Место для подписей */

    put stream PrnLibStream  v-line  skip  .
    put stream PrnLibStream   skip(2)  .
    run on-same-page in this-procedure (input 14) .
    put stream PrnLibStream unformatted
      "Инвентаризационная комиссия в составе:" SKIP(2)
      "Председатель комиссии__________________________________ подпись _______________________________ " skip(2)
      "Члены комиссии_________________________________________ подпись _______________________________ " skip(2)
      "_______________________________________________________ подпись _______________________________ " skip(2)
      "_______________________________________________________ подпись _______________________________ " skip(2)
      .


/* делаем footer невидимым, чтобы он не напечатался на последней странице */
hide stream PrnLibStream frame bottomframe .

output stream PrnLibStream close.
run waitfram-hide in this-procedure .

/* вывести */
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 4
                                          ).

procedure on-same-page :
  /* позволяет перейти к следующей странице (если это необходимо)  */
  /* необходимо применять, перед выводом блок из нескольких строк, */
  /* который должен быть размещен в предлах одной страницы         */
  define input parameter p-line-number as integer no-undo .

  if p-line-number > page-size( PrnLibStream ) then do:
    /* запрошенное количество строк - превышает размер страницы */
    /* не переходим на следующую страницу */
    return .
  end.

  if line-counter( PrnLibStream ) + p-line-number > page-size( PrnLibStream ) then do:
    page stream PrnLibStream .
  end.

end procedure. /* on-same-page */

procedure next-page :
  page stream PrnLibStream .
end procedure. /* next-page */

procedure clear-column-vars :
  assign
   /*  v-bar-code  = 0 */
    v-column-4  = 0
    v-column-5  = 0
    v-column-6  = 0
  .
end procedure. /* clear-column-vars */