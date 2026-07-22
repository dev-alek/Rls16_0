/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр карточки истории изменения ТРК

Автор: Булгаков Андрей Николаевич
Дата создания: 06/24/05
Author: Andrew Bulgakoff
Creation date: 06/24/05

*/

/* ***************************  Definitions  ************************** */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME fr-D-pump-8
&scop table      ub.c-pump
&scop size       size-chars
&scop fill-in    view-as fill-in {&size}
&scop editor     view-as editor no-word-wrap scrollbar-horizontal scrollbar-vertical {&size}
&scop align      colon-aligned

/* Parameters Definitions */
define input        parameter p-mode   as character no-undo.
define input-output parameter p-rec-id as recid     no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения ТРК":U.

/* Shared Variable Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define buffer buf_cli for ub.clients.

/* ***********************  Control Definitions  ********************** */
define button   Btn_Exit  label "Вы&ход"  {&size} 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  {&size} 10.00 by 1.00 default auto-go.
define button b-help label "Помо&щь" {&size} 10.00 by 1.00 default.

define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill {&size} 98.25 by 1.50.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  {&table}.pump-code at row  1.25 col 11.00 {&align} {&fill-in}  3.50 by 1.00                   fgcolor  4
  {&table}.obj-type  at row  2.50 col 11.00 {&align} {&fill-in}  4.50 by 1.00    label "Объект"
  {&table}.obj-code  at row  2.50 col 18.00          {&fill-in} 10.50 by 1.00 no-label
  buf_cli.obj-name   at row  2.50 col 29.00          {&fill-in} 70.00 by 1.00 no-label          fgcolor  4
  {&table}.status_   at row  3.75 col 11.00 {&align} {&fill-in}  9.50 by 1.00
  {&table}.PS        at row  5.25 col  1.50          {&editor}  98.25 by 3.50 no-label          bgcolor 15
  r-rect-0           at row  9.25 col  1.50
    Btn_Exit         at row  9.50 col  2.50
    Btn_OK           at row  9.50 col 78.00
  b-help        at row  9.50 col 88.75
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
    message "Карточка истории ТРК не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  find buf_cli no-lock where
       buf_cli.obj-type = {&table}.obj-type and
       buf_cli.obj-code = {&table}.obj-code no-error.
  assign frame {&FRAME-NAME} :title = "Карточка изменения ТРК " +
    substitute( '"&1" (объект &2 &3 "&4") -- &5',
                {&table}.pump-code, {&table}.obj-type, {&table}.obj-code, buf_cli.obj-name, p-mode ).
  display {&table}.pump-code
          {&table}.obj-type
          {&table}.obj-code
          buf_cli.obj-name
          {&table}.status_
          {&table}.PS
  with frame {&FRAME-NAME}.
  enable {&table}.PS Btn_Exit b-help with frame {&FRAME-NAME}.
  assign {&table}.PS :read-only in frame {&FRAME-NAME} = yes.
  if p-mode = {&lookup} then do: hide Btn_OK in frame {&FRAME-NAME}. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.