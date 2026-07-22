/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр записи истории изменения строки сверки ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/28/07
Author: Dmitry Ukhanov
Creation date: 06/28/07

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/24/05
Author: Dmitry Ukhanov
Creation date: 06/24/05

*/

/* ***************************  Definitions  ************************** */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME  fr-D-rvs-line-8
&scop size        size-chars
&scop fill-in     view-as fill-in {&size}
&scop align       colon-aligned

/* Parameters Definitions */
define input        parameter p-mode   as character no-undo.
define input-output parameter p-rec-id as recid     no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo initial "Просмотр записи истории изменения строки сверки ТРК":U.

/* Shared Variable Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define buffer buf_goods for ub.goods.

/* ***********************  Control Definitions  ********************** */
define button   Btn_Exit  label "Вы&ход"  {&size} 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  {&size} 10.00 by 1.00 default auto-go.
define button {&Btn_Help} label "Помо&щь" {&size} 10.00 by 1.00 default.

define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill {&size} 98.25 by 1.50.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  ub.c-rvs-line-pump.meas-el-cnt   at row  1.25 col 25.25 {&align} label "Измер. электр. счетчика"  {&fill-in} 23.00 by 1.00
  ub.c-rvs-line-pump.state-el-cnt  at row  1.25 col 74.75 {&align} label "Показ. электр. счетчика"  {&fill-in} 23.00 by 1.00
  ub.c-rvs-line-pump.meas-am-cnt   at row  2.50 col 25.25 {&align} label "Сумма по измер."          {&fill-in} 23.00 by 1.00
  ub.c-rvs-line-pump.state-am-cnt  at row  2.50 col 74.75 {&align} label "Сумма по показ."          {&fill-in} 23.00 by 1.00
  ub.c-rvs-line-pump.meas-cf-cnt   at row  3.75 col 25.25 {&align} label "Кол-во наливов по измер." {&fill-in} 19.00 by 1.00
  ub.c-rvs-line-pump.state-cf-cnt  at row  3.75 col 74.75 {&align} label "Кол-во наливов по показ." {&fill-in} 19.00 by 1.00
  ub.c-rvs-line-pump.meas-mh-cnt   at row  5.00 col 25.25 {&align} label "Измер. мех. счетчика"     {&fill-in} 23.00 by 1.00
  ub.c-rvs-line-pump.state-mh-cnt  at row  5.00 col 74.75 {&align} label "Показ. мех. счетчика"     {&fill-in} 23.00 by 1.00
  ub.c-rvs-line-pump.meas-mh-qnty  at row  6.25 col 25.25 {&align} label "Измер. оборот"            {&fill-in} 17.00 by 1.00
  ub.c-rvs-line-pump.state-mh-qnty at row  6.25 col 74.75 {&align}                                  {&fill-in} 17.00 by 1.00
  ub.c-rvs-line-pump.meas-am-qnty  at row  7.50 col 25.25 {&align} label "Измер. сумма оборота"     {&fill-in} 16.00 by 1.00
  ub.c-rvs-line-pump.state-am-qnty at row  7.50 col 74.75 {&align}                                  {&fill-in} 16.00 by 1.00
  ub.c-rvs-line-pump.meas-cf-qnty  at row  8.75 col 25.25 {&align} label "Измер. кол-во наливов"    {&fill-in} 11.00 by 1.00
  ub.c-rvs-line-pump.state-cf-qnty at row  8.75 col 74.75 {&align} label "Факт кол-во наливов"      {&fill-in} 11.00 by 1.00
  r-rect-0               at row 10.25 col  1.50
    Btn_Exit             at row 10.50 col  2.50
    Btn_OK               at row 10.50 col 78.00
  {&Btn_Help}            at row 10.50 col 88.75
with view-as dialog-box side-labels no-underline three-d scrollable
     title "":U default-button Btn_Exit cancel-button Btn_Exit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.

/* ************************  Control Triggers  ************************ */
on choose of Btn_OK in frame {&FRAME-NAME} do: /* Ввод */
  { gbl/stdbtn.i }
  apply "GO":U to frame {&FRAME-NAME}.
end.

on choose of Btn_Exit in frame {&FRAME-NAME} do: /* Выход */
  { gbl/stdbtn.i }
end.

{ gbl/hot-key.i {&Btn_Help} }

/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent. */
if valid-handle( active-window ) and frame {&FRAME-NAME} :parent = ? then frame {&FRAME-NAME} :parent = active-window.

/* Restore the current-window if it is an icon. Otherwise the dialog box will be hidden */
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR */
on window-close of frame {&FRAME-NAME} do: apply "END-ERROR":U to self. end.

{ gbl/app_help.i }

Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  if p-mode <> {&lookup} then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    undo Main-Block, return error.
  end.

  find ub.c-rvs-line-pump no-lock where recid( ub.c-rvs-line-pump ) = p-rec-id no-error.
  if not available ub.c-rvs-line-pump then do:
    message "Карточка истории строки сверки не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  find first buf_goods no-lock where buf_goods.gds-code = ub.c-rvs-line-pump.gds-code.
  assign frame {&FRAME-NAME} :title = 'Карточка истории изменения строки сверки  # '  + ub.c-rvs-line-pump.rvs-code +
                                      ' товар '      + buf_goods.artic                + ' ':U             +
                                                               buf_goods.prod-type    + ' ':U             +
                                                       string( buf_goods.prod-code  ) +
                                      ' скл. место ' + string( ub.c-rvs-line-pump.pl-code     ) +
                                      ' ТРК '        + string( ub.c-rvs-line-pump.pump-code   ) +
                                      ' пистолет '   + string( ub.c-rvs-line-pump.nozzle-code ) + '  --  '          + p-mode.
  display ub.c-rvs-line-pump.meas-el-cnt  ub.c-rvs-line-pump.state-el-cnt
          ub.c-rvs-line-pump.meas-am-cnt  ub.c-rvs-line-pump.state-am-cnt
          ub.c-rvs-line-pump.meas-cf-cnt  ub.c-rvs-line-pump.state-cf-cnt
          ub.c-rvs-line-pump.meas-mh-cnt  ub.c-rvs-line-pump.state-mh-cnt
          ub.c-rvs-line-pump.meas-mh-qnty ub.c-rvs-line-pump.state-mh-qnty
          ub.c-rvs-line-pump.meas-am-qnty ub.c-rvs-line-pump.state-am-qnty
          ub.c-rvs-line-pump.meas-cf-qnty ub.c-rvs-line-pump.state-cf-qnty
  with frame {&FRAME-NAME}.
  enable Btn_Exit {&Btn_Help} with frame {&FRAME-NAME}.
  if p-mode = {&lookup} then do: hide Btn_OK in frame {&FRAME-NAME}. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.