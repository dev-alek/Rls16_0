/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр карточки истории изменения хранения товара на складском месте

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/24/05
Author: Dmitry Ukhanov
Creation date: 06/24/05

*/

/* ***************************  Definitions  ************************** */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME fr-D-pump-8
&scop table      ub.c-pl-gds
&scop size       size-chars
&scop fill-in    view-as fill-in    {&size}
&scop toggle     view-as toggle-box {&size}
&scop combo      view-as combo-box inner-lines 5 list-items "":U, ~{&cmp}, ~{&prs}, ~{&stock}, ~{&shop} {&size}
&scop editor     view-as editor no-word-wrap scrollbar-horizontal scrollbar-vertical {&size} 98.25 by 3.50 format "x(512)":U
&scop align      colon-aligned
&scop color      fgcolor 15 bgcolor 3

/* Parameters Definitions */
define input        parameter p-mode   as character no-undo.
define input-output parameter p-rec-id as recid     no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения хранения товара на складском месте":U.

/* Shared Variable Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define buffer bf_obj   for ub.clients.
define buffer bf_cli   for ub.clients.
define buffer bf_place for ub.place.
define buffer bf_goods for ub.goods.

/* ***********************  Control Definitions  ********************** */
define button   Btn_Exit  label "Вы&ход"  {&size} 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  {&size} 10.00 by 1.00 default auto-go.
define button b-help label "Помо&щь" {&size} 10.00 by 1.00 default.

define variable v-header as character no-undo initial " И Н Ф О Р М А Ц И Я   О   Т О В А Р Е ".
define variable v-label  as character no-undo initial " К О Л И Ч Е С Т В Е Н Н Ы Е   Х А Р А К Т Е Р И С Т И К И ".

define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill {&size} 98.25 by 1.50.
define rectangle r-rect-1 edge-pixels 2 graphic-edge no-fill {&size} 98.25 by 4.50.
define rectangle r-rect-2 edge-pixels 2 graphic-edge no-fill {&size} 98.25 by 3.75.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  {&table}.pl-code     at row  1.25 col 18.00 {&align} {&fill-in} 10.50 by 1.00    label "Складское место"
  bf_place.pl-name     at row  1.25 col 31.00          {&fill-in} 68.50 by 1.00 no-label format "x(80)":U   fgcolor  4
  {&table}.obj-type    at row  2.50 col 18.00 {&align} {&combo}    6.00 by 1.00    label "Объект"
  {&table}.obj-code    at row  2.50 col 26.50          {&fill-in} 10.50 by 1.00 no-label
    bf_obj.obj-name    at row  2.50 col 37.50          {&fill-in} 62.00 by 1.00 no-label format "x(80)":U   fgcolor  4
  r-rect-1             at row  4.50 col  1.50
  v-header             at row  4.00 col 29.00          {&fill-in} 40.25 by 1.00 no-label format "x(40)":U   {&color}
  {&table}.gds-code    at row  5.00 col 18.00 {&align} {&fill-in} 10.50 by 1.00    label "Код"              fgcolor  4
  bf_goods.artic       at row  5.00 col 38.50          {&fill-in} 17.50 by 1.00    label "Артикул"
  bf_goods.prod-type   at row  6.25 col 18.00 {&align} {&combo}    6.00 by 1.00    label "Производитель"
  bf_goods.prod-code   at row  6.25 col 26.50          {&fill-in} 10.50 by 1.00 no-label
    bf_cli.obj-name    at row  6.25 col 37.50          {&fill-in} 62.00 by 1.00 no-label format "x(80)":U   fgcolor  4
  bf_goods.gds-name    at row  7.50 col 18.00 {&align} {&fill-in} 61.50 by 1.00    label "Название"         fgcolor  4
  r-rect-2             at row  8.92 col  1.50
  v-label              at row  8.58 col 19.00          {&fill-in} 60.25 by 1.00 no-label format "x(60)":U   {&color}
  {&table}.fact-qnty   at row 10.00 col 18.00 {&align} {&fill-in} 16.50 by 1.00    label "Факт"             fgcolor 12
  {&table}.free-qnty   at row 10.00 col 37.50          {&fill-in} 16.50 by 1.00    label "Свободно"         fgcolor 12
  {&table}.tolerance   at row 10.00 col 58.00          {&fill-in} 13.50 by 1.00                             fgcolor 12
  {&table}.cli-qnty    at row 11.25 col 18.00 {&align} {&fill-in} 16.50 by 1.00                             fgcolor 12
  {&table}.max-qnty    at row 11.25 col 56.00          {&fill-in} 16.50 by 1.00                             fgcolor 12
  "СВЕРКА:"            at row 13.25 col 11.50                                                               {&color}
  {&table}.rvs-on      at row 13.25 col 20.50          {&toggle}  16.50 by 1.00    label "включена"
  {&table}.rvs-code    at row 13.25 col 40.50          {&fill-in} 17.50 by 1.00    label "номер"
  {&table}.status_     at row 14.75 col 18.00 {&align} {&fill-in}  9.50 by 1.00
  {&table}.PS          at row 16.25 col  1.50          {&editor}                no-label                    bgcolor 15
    r-rect-0           at row 20.25 col  1.50
    Btn_Exit           at row 20.50 col  2.50
    Btn_OK             at row 20.50 col 78.00
  b-help          at row 20.50 col 88.75
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
    message "Карточка истории хранения товара на складском месте не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  find first bf_goods no-lock where bf_goods.gds-code = {&table}.gds-code no-error.
  find first bf_place no-lock where
             bf_place.obj-type = {&table}.obj-type and
             bf_place.obj-code = {&table}.obj-code and
             bf_place.pl-code  = {&table}.pl-code  no-error.
  find first bf_obj   no-lock where
             bf_obj.obj-type   = {&table}.obj-type and
             bf_obj.obj-code   = {&table}.obj-code no-error.
  find first bf_cli   no-lock where
             bf_cli.obj-type   = bf_goods.prod-type and
             bf_cli.obj-code   = bf_goods.prod-code no-error.
  assign frame {&FRAME-NAME} :title = substitute(
    'Карточка изменения хранения товара &1 "&2" на складском месте &3 "&4" (объект &5 &6 "&7") -- &8',
    {&table}.gds-code,
    bf_goods.gds-name,
    {&table}.pl-code,
    bf_place.pl-name,
    {&table}.obj-type,
    {&table}.obj-code,
    bf_obj.obj-name,
    p-mode ).

  display {&table}.pl-code
          {&table}.gds-code
          {&table}.obj-type  when {&table}.obj-type <> ?
          {&table}.obj-code
          {&table}.status_
          {&table}.fact-qnty
          {&table}.free-qnty
          {&table}.tolerance
          {&table}.cli-qnty
          {&table}.max-qnty
          {&table}.rvs-on
          {&table}.rvs-code  when {&table}.rvs-on = yes and {&table}.rvs-code <> ?
          {&table}.PS
          v-header
          v-label
  with frame {&FRAME-NAME}.

  if {&table}.rvs-on <> yes then do: hide {&table}.rvs-code in frame {&FRAME-NAME}. end.

  if available bf_goods then do:
    display bf_goods.artic
            bf_goods.prod-type when bf_goods.prod-type <> ?
            bf_goods.prod-code
            bf_goods.gds-name
    with frame {&FRAME-NAME}.
  end.
  if available bf_cli   then do: display bf_cli.obj-name  with frame {&FRAME-NAME}. end.
  if available bf_obj   then do: display bf_obj.obj-name  with frame {&FRAME-NAME}. end.
  if available bf_place then do: display bf_place.pl-name with frame {&FRAME-NAME}. end.

  enable {&table}.PS Btn_Exit b-help with frame {&FRAME-NAME}.
  assign {&table}.PS :read-only in frame {&FRAME-NAME} = yes.
  if p-mode = {&lookup} then do: hide Btn_OK in frame {&FRAME-NAME}. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.
