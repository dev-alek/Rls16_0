/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр карточки истории изменения соответствия резервуар-ТРК-пистолет

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/24/05
Author: Dmitry Ukhanov
Creation date: 06/24/05

*/

/* ***************************  Definitions  ************************** */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME fr-D-pump-8
&scop table      ub.c-pl-pump-nozzle
&scop size       size-chars
&scop fill-in    view-as fill-in {&size}
&scop editor     view-as editor no-word-wrap scrollbar-horizontal scrollbar-vertical {&size} 98.25 by 3.50 format "x(512)":U
&scop align      colon-aligned

/* Parameters Definitions */
define input        parameter p-mode   as character no-undo.
define input-output parameter p-rec-id as recid     no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения соответствия резервуар-ТРК-пистолет":U.

/* Shared Variable Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define buffer bf_cli    for ub.clients.
define buffer bf_place  for ub.place.
define buffer bf_pl-gds for ub.pl-gds.
define buffer bf_goods  for ub.goods.
define buffer bf_pump   for ub.pump.
define buffer bf_nozzle for ub.nozzle.

/* ***********************  Control Definitions  ********************** */
define button   Btn_Exit  label "Вы&ход"  {&size} 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  {&size} 10.00 by 1.00 default auto-go.
define button b-help label "Помо&щь" {&size} 10.00 by 1.00 default.

define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill {&size} 98.25 by 1.50.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  {&table}.pl-code     at row  1.25 col 11.00 {&align} {&fill-in} 10.50 by 1.00    label "Танк"
  bf_place.pl-name     at row  1.25 col 24.00          {&fill-in} 61.50 by 1.00 no-label            fgcolor  4
  {&table}.pump-code   at row  2.50 col 11.00 {&align} {&fill-in}  3.50 by 1.00                     fgcolor  4
    bf_pump.status_    at row  2.50 col 24.00          {&fill-in}  9.50 by 1.00
  {&table}.nozzle-code at row  3.75 col 11.00 {&align} {&fill-in}  4.50 by 1.00    label "Пистолет" fgcolor  4
    bf_nozzle.status_  at row  3.75 col 24.00          {&fill-in}  9.50 by 1.00
  {&table}.obj-type    at row  5.00 col 11.00 {&align} {&fill-in}  4.50 by 1.00    label "Объект"
  {&table}.obj-code    at row  5.00 col 18.00          {&fill-in} 10.50 by 1.00 no-label
    bf_cli.obj-name    at row  5.00 col 29.00          {&fill-in} 70.00 by 1.00 no-label            fgcolor  4
  {&table}.status_     at row  6.25 col 11.00 {&align} {&fill-in}  9.50 by 1.00
  {&table}.PS          at row  7.75 col  1.50          {&editor}                no-label            bgcolor 15
  bf_goods.gds-name    at row 11.75 col 11.00 {&align} {&fill-in} 49.50 by 1.00    label "Топливо"  fgcolor  4
  bf_pl-gds.status_    at row 11.75 col 63.00          {&fill-in}  9.50 by 1.00                     fgcolor  4
  bf_pl-gds.fact-qnty  at row 13.25 col 11.00 {&align} {&fill-in} 16.50 by 1.00    label "Факт"     fgcolor 12
  bf_pl-gds.free-qnty  at row 13.25 col 33.00          {&fill-in} 16.50 by 1.00    label "Свободно" fgcolor 12
  bf_pl-gds.tolerance  at row 13.25 col 63.00          {&fill-in} 13.50 by 1.00                     fgcolor 12
  r-rect-0             at row 14.75 col  1.50
    Btn_Exit           at row 15.00 col  2.50
    Btn_OK             at row 15.00 col 78.00
  b-help          at row 15.00 col 88.75
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
    message "Карточка истории соответствия пистолет-ТРК не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  find first bf_nozzle no-lock where
             bf_nozzle.obj-type    = {&table}.obj-type    and
             bf_nozzle.obj-code    = {&table}.obj-code    and
             bf_nozzle.nozzle-code = {&table}.nozzle-code no-error.
  find first bf_pump no-lock where
             bf_pump.obj-type  = {&table}.obj-type  and
             bf_pump.obj-code  = {&table}.obj-code  and
             bf_pump.pump-code = {&table}.pump-code no-error.
  find first bf_pl-gds no-lock where
             bf_pl-gds.obj-type = {&table}.obj-type and
             bf_pl-gds.obj-code = {&table}.obj-code and
             bf_pl-gds.pl-code  = {&table}.pl-code  no-error.
  find first bf_place no-lock where
             bf_place.obj-type = {&table}.obj-type and
             bf_place.obj-code = {&table}.obj-code and
             bf_place.pl-code  = {&table}.pl-code  no-error.
  find first bf_cli   no-lock where
             bf_cli.obj-type   = {&table}.obj-type and
             bf_cli.obj-code   = {&table}.obj-code no-error.
  assign frame {&FRAME-NAME} :title = substitute(
    'Карточка изменения соответствия резервуар &1 - ТРК &2 - пистолет &3 (объект &4 &5 "&6") -- &7',
    {&table}.pl-code,
    {&table}.pump-code,
    {&table}.nozzle-code,
    {&table}.obj-type,
    {&table}.obj-code,
    bf_cli.obj-name,
    p-mode ).

  display {&table}.pl-code
          {&table}.pump-code
          {&table}.nozzle-code
          {&table}.obj-type
          {&table}.obj-code
          {&table}.status_
          {&table}.PS
  with frame {&FRAME-NAME}.

  if available bf_cli   then do: display bf_cli.obj-name  with frame {&FRAME-NAME}. end.
  if available bf_place then do: display bf_place.pl-name with frame {&FRAME-NAME}. end.

  if available bf_pl-gds then do:
    display bf_pl-gds.status_
            bf_pl-gds.fact-qnty
            bf_pl-gds.free-qnty
            bf_pl-gds.tolerance
    with frame {&FRAME-NAME}.
    find first bf_goods no-lock where bf_goods.gds-code = bf_pl-gds.gds-code no-error.
    if available bf_goods then do:
      display bf_goods.gds-name with frame {&FRAME-NAME}.
    end.
    else do:
      hide    bf_goods.gds-name   in frame {&FRAME-NAME}.
    end.
  end.
  else do:
    hide bf_pl-gds.status_   in frame {&FRAME-NAME}
         bf_pl-gds.fact-qnty in frame {&FRAME-NAME}
         bf_pl-gds.free-qnty in frame {&FRAME-NAME}
         bf_pl-gds.tolerance in frame {&FRAME-NAME}
         bf_goods.gds-name   in frame {&FRAME-NAME}.
  end.

  if available bf_pump   then do: display bf_pump.status_   with frame {&FRAME-NAME}. end.
  if available bf_nozzle then do: display bf_nozzle.status_ with frame {&FRAME-NAME}. end.

  enable {&table}.PS Btn_Exit b-help with frame {&FRAME-NAME}.
  assign {&table}.PS :read-only in frame {&FRAME-NAME} = yes.
  if p-mode = {&lookup} then do: hide Btn_OK in frame {&FRAME-NAME}. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.