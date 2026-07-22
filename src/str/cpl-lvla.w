/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр карточки истории изменения градуировочной таблицы по резервуару на объекте

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/23/06
Author: Dmitry Ukhanov
Creation date: 01/23/06

*/

/* ***************************  Definitions  ************************** */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME fr-D-pl-level-8
&scop table      ub.c-pl-level
&scop size       size-chars
&scop fill-in    view-as fill-in {&size}
&scop editor     view-as editor no-word-wrap scrollbar-horizontal scrollbar-vertical {&size} 98.25 by 3.50 format "x(512)":U
&scop align      colon-aligned

/* Parameters Definitions */
define input        parameter p-mode   as character no-undo.
define input-output parameter p-rec-id as recid     no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения градуировочной таблицы по резервуару на объекте":U.

/* Shared Variable Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/library.i  }

define variable j_host-code as integer   no-undo.
define variable v_host-name as character no-undo format "x(99)":U.

define buffer bf_cli   for ub.clients.
define buffer bf_place for ub.place.

/* ***********************  Control Definitions  ********************** */
define button   Btn_Exit  label "Вы&ход"  {&size} 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  {&size} 10.00 by 1.00 default auto-go.
define button b-help label "Помо&щь" {&size} 10.00 by 1.00 default.

define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill {&size} 98.25 by 1.50.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  {&table}.pl-code     at row 1.25 col 11.00 {&align} {&fill-in} 10.50 by 1.00    label "Танк"
  bf_place.pl-name     at row 1.25 col 24.00          {&fill-in} 61.50 by 1.00 no-label               fgcolor 4
  {&table}.obj-type    at row 2.50 col 11.00 {&align} {&fill-in}  4.50 by 1.00    label "Объект"
  {&table}.obj-code    at row 2.50 col 18.00          {&fill-in} 10.50 by 1.00 no-label
    bf_cli.obj-name    at row 2.50 col 29.00          {&fill-in} 70.00 by 1.00 no-label               fgcolor 4
  {&table}.pl-level    at row 3.75 col  2.50          {&fill-in} 10.50 by 1.00    label "Уровень, мм"
  {&table}.pl-qnty     at row 5.00 col  5.50          {&fill-in} 13.50 by 1.00    label "Объем, л"
         v_host-name   at row 6.50 col  2.50          {&fill-in} 83.00 by 1.00 no-label               fgcolor 4
  r-rect-0             at row 8.00 col  1.50
    Btn_Exit           at row 8.25 col  2.50
    Btn_OK             at row 8.25 col 78.00
  b-help          at row 8.25 col 88.75
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
    message "Карточка истории градуировочной таблицы не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  find first bf_place no-lock where
             bf_place.obj-type = {&table}.obj-type and
             bf_place.obj-code = {&table}.obj-code and
             bf_place.pl-code  = {&table}.pl-code  no-error.
  find first bf_cli   no-lock where
             bf_cli.obj-type   = {&table}.obj-type and
             bf_cli.obj-code   = {&table}.obj-code no-error.
  { gbl/hostname.i {&table}.obj-type {&table}.obj-code j_host-code v_host-name no-error }
  if error-status :error or v_host-name = ? then do: assign v_host-name = "":U. end.
  assign frame {&FRAME-NAME} :title = substitute(
    'Карточка изменения градуировочной таблицы по резервуару &1 на объекте &2 &3 "&4" -- &5',
    {&table}.pl-code,
    {&table}.obj-type,
    {&table}.obj-code,
    bf_cli.obj-name,
    p-mode ).

  display {&table}.pl-code
          {&table}.obj-type
          {&table}.obj-code
          {&table}.pl-level
          {&table}.pl-qnty
                 v_host-name
  with frame {&FRAME-NAME}.

  if available bf_cli   then do: display bf_cli.obj-name  with frame {&FRAME-NAME}. end.
  if available bf_place then do: display bf_place.pl-name with frame {&FRAME-NAME}. end.

  enable /* {&table}.PS */ Btn_Exit b-help with frame {&FRAME-NAME}.
  /* assign {&table}.PS :read-only in frame {&FRAME-NAME} = yes. */
  if p-mode = {&lookup} then do: hide Btn_OK in frame {&FRAME-NAME}. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.