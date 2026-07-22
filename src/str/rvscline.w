/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр записи истории изменения строки сверки

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
define variable vss-description as character no-undo initial "Просмотр записи истории изменения строки сверки":U.

/* Shared Variable Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define buffer buf_goods for ub.goods.

function Show2nd returns logical ( input sys-qty as decimal, input ini-qty as decimal ) :
  return ( sys-qty <> ini-qty and ini-qty <> ? and ini-qty <> 0 ).
end function. /* Show2nd */

/* ***********************  Control Definitions  ********************** */
define button   Btn_Exit  label "Вы&ход"  {&size} 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  {&size} 10.00 by 1.00 default auto-go.
define button {&Btn_Help} label "Помо&щь" {&size} 10.00 by 1.00 default.

define variable v_meas-cli as decimal no-undo initial 0 format "->>,>>>,>>9.<<<":U.
define variable v_meas-qty as decimal no-undo initial 0 format "->>,>>>,>>9.<<<":U.
define variable v_stat-cli as decimal no-undo initial 0 format "->>,>>>,>>9.<<<":U.
define variable v_stat-qty as decimal no-undo initial 0 format "->>,>>>,>>9.<<<":U.

define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill {&size} 98.25 by  1.50.
define rectangle r-rect-1 edge-pixels 2 graphic-edge no-fill {&size} 48.88 by 18.38.
define rectangle r-rect-2 edge-pixels 2 graphic-edge no-fill {&size} 48.88 by 18.38.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  ub.c-rvs-line.system-qnty            at row  1.25 col 28.25 {&align} label "Объем расчетно-книжный" {&fill-in} 19.00 by 0.88 fgcolor  4
  ub.c-rvs-line.system-cli-qnty        at row  1.25 col 73.25 {&align} label "Вес расчетно-книжный"   {&fill-in} 19.00 by 0.88 fgcolor  4
  ub.c-rvs-line.orig-system-qnty       at row  2.25 col 28.25 {&align} label "Первоначально"          {&fill-in} 19.00 by 0.88 fgcolor 12
  ub.c-rvs-line.orig-system-cli-qnty   at row  2.25 col 73.25 {&align} label "Первоначально"          {&fill-in} 19.00 by 0.88 fgcolor 12
  ub.c-rvs-line.measure-qnty           at row  3.75 col 28.25 {&align}                                {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-measure-qnty     at row  3.75 col 73.25 {&align}                                {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.measure-tc-qnty        at row  4.75 col 28.25 {&align}                                {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-measure-tc-qnty  at row  4.75 col 73.25 {&align}                                {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.density                at row  5.75 col 28.25 {&align}                                {&fill-in}  7.00 by 0.88
  ub.c-rvs-line.state-density          at row  5.75 col 73.25 {&align}                                {&fill-in}  7.00 by 0.88
  ub.c-rvs-line.add-qnty               at row  6.75 col 28.25 {&align}                                {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-add-qnty         at row  6.75 col 73.25 {&align}                                {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.brutto-qnty            at row  7.75 col 28.25 {&align}                                {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-brutto-qnty      at row  7.75 col 73.25 {&align}                                {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.brutto-tc-qnty         at row  8.75 col 28.25 {&align}                                {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-brutto-tc-qnty   at row  8.75 col 73.25 {&align}                                {&fill-in} 13.00 by 0.88
  v_meas-qty                      at row  9.75 col 28.25 {&align} label "Измер. вода"            {&fill-in} 13.00 by 0.88
  v_stat-qty                      at row  9.75 col 73.25 {&align} label "Факт вода"              {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.measure-cli-qnty       at row 10.75 col 28.25 {&align} label "Измер. вес"             {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-measure-cli-qnty at row 10.75 col 73.25 {&align} label "Факт вес"               {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.brutto-cli-qnty        at row 11.75 col 28.25 {&align} label "Измер. брутто вес"      {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-brutto-cli-qnty  at row 11.75 col 73.25 {&align} label "Факт брутто вес"        {&fill-in} 13.00 by 0.88
  v_meas-cli                      at row 12.75 col 28.25 {&align} label "Вес воды"               {&fill-in} 13.00 by 0.88
  v_stat-cli                      at row 12.75 col 73.25 {&align} label "Факт вес воды"          {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.level-petrol           at row 13.75 col 28.25 {&align} label "Измер. уровень топлива" {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-level-petrol     at row 13.75 col 73.25 {&align} label "Факт уровень топлива"   {&fill-in} 13.00 by 0.88
with view-as dialog-box side-labels no-underline three-d scrollable
     title "":U default-button Btn_Exit cancel-button Btn_Exit.

define frame {&FRAME-NAME}
  r-rect-2                   at row  3.50 col  1.50
  r-rect-1                   at row  3.50 col 50.75
  ub.c-rvs-line.level-total       at row 14.75 col 28.25 {&align} label "Измер. общий уровень"      {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-level-total at row 14.75 col 73.25 {&align} label "Факт общий уровень"        {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.level-water       at row 15.75 col 28.25 {&align} label "Измер. уровень воды"       {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-level-water at row 15.75 col 73.25 {&align} label "Факт уровень воды"         {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.temperature       at row 16.75 col 28.25 {&align}                                   {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.state-temperature at row 16.75 col 73.25 {&align}                                   {&fill-in} 13.00 by 0.88
  ub.c-rvs-line.temp-layer1       at row 17.75 col  8.63 {&align} label "ИзмT1"                     {&fill-in}  8.00 by 0.88
  ub.c-rvs-line.temp-layer2       at row 17.75 col 24.00 {&align} label "ИзмT2"                     {&fill-in}  8.00 by 0.88
  ub.c-rvs-line.temp-layer3       at row 17.75 col 39.38 {&align} label "ИзмT3"                     {&fill-in}  8.00 by 0.88
  ub.c-rvs-line.state-temp-layer1 at row 17.75 col 54.25 {&align}                                   {&fill-in}  8.00 by 0.88
  ub.c-rvs-line.state-temp-layer2 at row 17.75 col 71.38 {&align}                                   {&fill-in}  8.00 by 0.88
  ub.c-rvs-line.state-temp-layer3 at row 17.75 col 86.88 {&align}                                   {&fill-in}  8.00 by 0.88
  ub.c-rvs-line.meas-mh-qnty      at row 18.75 col 28.25 {&align}                                   {&fill-in} 17.00 by 0.88
  ub.c-rvs-line.state-mh-qnty     at row 18.75 col 73.25 {&align}                                   {&fill-in} 17.00 by 0.88
  ub.c-rvs-line.meas-am-qnty      at row 19.75 col 28.25 {&align}                                   {&fill-in} 17.00 by 0.88
  ub.c-rvs-line.state-am-qnty     at row 19.75 col 73.25 {&align} label "Факт сумма оборота"        {&fill-in} 17.00 by 0.88
  ub.c-rvs-line.meas-cf-qnty      at row 20.75 col 28.25 {&align} label "Измеренное кол-во наливов" {&fill-in} 17.00 by 0.88
  ub.c-rvs-line.state-cf-qnty     at row 20.75 col 73.25 {&align} label "Факт кол-во наливов"       {&fill-in} 17.00 by 0.88
  r-rect-0                   at row 22.00 col  1.50
    Btn_Exit                 at row 22.25 col  2.50
    Btn_OK                   at row 22.25 col 78.00
  {&Btn_Help}                at row 22.25 col 88.75
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

  find ub.c-rvs-line no-lock where recid( ub.c-rvs-line ) = p-rec-id no-error.
  if not available ub.c-rvs-line then do:
    message "Карточка истории строки сверки не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  find first buf_goods no-lock where buf_goods.gds-code = ub.c-rvs-line.gds-code.
  assign frame {&FRAME-NAME} :title = 'Карточка истории изменения строки сверки  # ' + ub.c-rvs-line.rvs-code +
                                      ' товар ' + buf_goods.artic       + ' ':U +
                                                  buf_goods.prod-type   + ' ':U +
                                          string( buf_goods.prod-code ) +
                                      ' складское место ' + string( ub.c-rvs-line.pl-code ) + '  --  ' + p-mode.
  display ub.c-rvs-line.system-qnty
          ub.c-rvs-line.system-cli-qnty
          ub.c-rvs-line.orig-system-qnty
          ub.c-rvs-line.orig-system-cli-qnty
          ub.c-rvs-line.measure-qnty
          ub.c-rvs-line.state-measure-qnty
          ub.c-rvs-line.measure-tc-qnty
          ub.c-rvs-line.state-measure-tc-qnty
          ub.c-rvs-line.density
          ub.c-rvs-line.state-density
          ub.c-rvs-line.add-qnty
          ub.c-rvs-line.state-add-qnty
          ub.c-rvs-line.brutto-qnty
          ub.c-rvs-line.state-brutto-qnty
          ub.c-rvs-line.brutto-tc-qnty
          ub.c-rvs-line.state-brutto-tc-qnty
          ub.c-rvs-line.measure-cli-qnty
          ub.c-rvs-line.state-measure-cli-qnty
          ub.c-rvs-line.brutto-cli-qnty
          ub.c-rvs-line.state-brutto-cli-qnty
          ub.c-rvs-line.level-petrol
          ub.c-rvs-line.state-level-petrol
          ub.c-rvs-line.level-total
          ub.c-rvs-line.state-level-total
          ub.c-rvs-line.temperature
          ub.c-rvs-line.state-temperature
          ub.c-rvs-line.temp-layer1
          ub.c-rvs-line.temp-layer2
          ub.c-rvs-line.temp-layer3
          ub.c-rvs-line.state-temp-layer1
          ub.c-rvs-line.state-temp-layer2
          ub.c-rvs-line.state-temp-layer3
          ub.c-rvs-line.meas-mh-qnty
          ub.c-rvs-line.state-mh-qnty
          ub.c-rvs-line.meas-am-qnty
          ub.c-rvs-line.state-am-qnty
          ub.c-rvs-line.meas-cf-qnty
          ub.c-rvs-line.state-cf-qnty
  with frame {&FRAME-NAME}.
  display ( ub.c-rvs-line.brutto-qnty           - ub.c-rvs-line.measure-qnty           ) @ v_meas-qty
          ( ub.c-rvs-line.brutto-cli-qnty       - ub.c-rvs-line.measure-cli-qnty       ) @ v_meas-cli
          ( ub.c-rvs-line.level-total           - ub.c-rvs-line.level-petrol           ) @ ub.c-rvs-line.level-water
          ( ub.c-rvs-line.state-brutto-qnty     - ub.c-rvs-line.state-measure-qnty     ) @ v_stat-qty
          ( ub.c-rvs-line.state-brutto-cli-qnty - ub.c-rvs-line.state-measure-cli-qnty ) @ v_stat-cli
          ( ub.c-rvs-line.state-level-total     - ub.c-rvs-line.state-level-petrol     ) @ ub.c-rvs-line.state-level-water
  with frame {&FRAME-NAME}.
  if Show2nd( ub.c-rvs-line.system-qnty,     ub.c-rvs-line.orig-system-qnty     ) = yes and
     Show2nd( ub.c-rvs-line.system-cli-qnty, ub.c-rvs-line.orig-system-cli-qnty ) = yes then do:
    assign ub.c-rvs-line.orig-system-cli-qnty :label in frame {&FRAME-NAME} = "":U.
  end.
  if Show2nd( ub.c-rvs-line.system-qnty,     ub.c-rvs-line.orig-system-qnty     ) = yes then do:
    display ub.c-rvs-line.orig-system-qnty     with frame {&FRAME-NAME}.
  end.
  else do:
    hide    ub.c-rvs-line.orig-system-qnty       in frame {&FRAME-NAME}.
  end.
  if Show2nd( ub.c-rvs-line.system-cli-qnty, ub.c-rvs-line.orig-system-cli-qnty ) = yes then do:
    display ub.c-rvs-line.orig-system-cli-qnty with frame {&FRAME-NAME}.
  end.
  else do:
    hide    ub.c-rvs-line.orig-system-cli-qnty   in frame {&FRAME-NAME}.
  end.
  enable Btn_Exit {&Btn_Help} with frame {&FRAME-NAME}.
  if p-mode = {&lookup} then do: hide Btn_OK in frame {&FRAME-NAME}. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.