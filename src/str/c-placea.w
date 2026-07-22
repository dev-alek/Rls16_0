/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр карточки истории изменения складского места

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/24/05
Author: Dmitry Ukhanov
Creation date: 06/24/05

*/

/* ***************************  Definitions  ************************** */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME  fr-D-place-8
&scop table       ub.c-place
&scop size        size-chars
&scop fill-in     view-as fill-in    {&size}
&scop toggle      view-as toggle-box {&size}
&scop editor      view-as editor no-word-wrap scrollbar-horizontal scrollbar-vertical {&size}
&scop align       colon-aligned
&scop add-qty-lbl "Дополнительное кол-во(в трубопроводе)"
&scop max-qty-lbl "Максимальное количество"

/* Parameters Definitions */
define input        parameter p-mode   as character no-undo.
define input-output parameter p-rec-id as recid     no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения складского места":U.

/* Shared Variable Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

/* ***********************  Control Definitions  ********************** */
define button   Btn_Exit  label "Вы&ход"  {&size} 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  {&size} 10.00 by 1.00 default auto-go.
define button b-help label "Помо&щь" {&size} 10.00 by 1.00 default.

define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill {&size} 98.25 by 1.50.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  {&table}.pl-code  at row  1.25 col  9.50 {&align} {&fill-in} 10.50 by 1.00                         fgcolor  4
  {&table}.pl-name  at row  1.25 col 39.50 {&align} {&fill-in} 58.00 by 1.00                         fgcolor  4
  {&table}.loc1     at row  2.50 col  9.50 {&align} {&fill-in} 11.63 by 1.00
  {&table}.loc2     at row  3.75 col  9.50 {&align} {&fill-in} 11.63 by 1.00
  {&table}.loc3     at row  5.00 col  9.50 {&align} {&fill-in} 11.63 by 1.00
  {&table}.loc4     at row  6.25 col  9.50 {&align} {&fill-in} 11.63 by 1.00
  {&table}.add-qnty at row  7.75 col 39.50 {&align} {&fill-in} 11.63 by 1.00    label {&add-qty-lbl} fgcolor 12
  {&table}.max-qnty at row  9.00 col 39.50 {&align} {&fill-in} 11.63 by 1.00    label {&max-qty-lbl} fgcolor 12
  {&table}.is-meas  at row 10.25 col  2.50          {&toggle}  23.50 by 1.00
  {&table}.PS       at row 11.75 col  1.50          {&editor}  98.25 by 3.50 no-label                bgcolor 15
  r-rect-0          at row 15.75 col  1.50
    Btn_Exit        at row 16.00 col  2.50
    Btn_OK          at row 16.00 col 78.00
  b-help       at row 16.00 col 88.75
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

{ gbl/hot-key.i b-help }

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

  find {&table} no-lock where recid( {&table} ) = p-rec-id no-error.
  if not available {&table} then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Карточка истории складского места не найдена!"
    view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  assign frame {&FRAME-NAME} :title = "Карточка изменения складского места " +
    substitute( '"&1" (объект "&2" &3) -- &4', {&table}.pl-name, {&table}.obj-type, {&table}.obj-code, p-mode ).
  display {&table}.pl-code
          {&table}.pl-name
          {&table}.loc1
          {&table}.loc2
          {&table}.loc3
          {&table}.loc4
          {&table}.is-meas
          {&table}.add-qnty
          {&table}.max-qnty
          {&table}.PS
  with frame {&FRAME-NAME}.
  enable {&table}.PS Btn_Exit b-help with frame {&FRAME-NAME}.
  assign {&table}.PS :read-only in frame {&FRAME-NAME} = yes.
  if p-mode = {&lookup} then do: hide Btn_OK in frame {&FRAME-NAME}. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.
