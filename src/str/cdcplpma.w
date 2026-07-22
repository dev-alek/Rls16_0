/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр карточки истории изменения количества по строке документа из складского места БЕНЗИН

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Булгаков Андрей Николаевич
: 07/13/05

*/

/* ***************************  Definitions  ************************** */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME fr-D-trn-attr-8
&scop table      ub.c-doc-pl-pump
&scop size       size-chars
&scop fill-in    view-as fill-in {&size}
&scop text       view-as text    {&size}
&scop combo      view-as combo-box inner-lines 5 list-items "":U, ~{&cmp}, ~{&prs}, ~{&stock}, ~{&shop} {&size}
&scop editor     view-as editor no-word-wrap scrollbar-horizontal scrollbar-vertical {&size}
&scop align      colon-aligned
&scop color      fgcolor 15 bgcolor 3
&scop q-ty       "->>>,>>>,>>>,>>>,>>9.999":U

/* Parameters Definitions */
define input        parameter p-mode   as character no-undo.
define input-output parameter p-rec-id as recid     no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения количества по строке документа из складского места":U.

/* Shared Variable Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define buffer buf_clients  for ub.clients.
define buffer buf_object   for ub.clients.
define buffer buf_goods    for ub.goods.
define buffer buf_place    for ub.place.

/* ***********************  Control Definitions  ********************** */
define button   Btn_Exit  label "Вы&ход"  {&size} 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  {&size} 10.00 by 1.00 default auto-go.
define button b-help label "Помо&щь" {&size} 10.00 by 1.00 default.

define variable v-header as character no-undo initial " И Н Ф О Р М А Ц И Я   О   Т О В А Р Е ".
define variable v-label  as character no-undo initial " К О Л И Ч Е С Т В Е Н Н Ы Е   Х А Р А К Т Е Р И С Т И К И ".

define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill {&size} 98.25 by 1.50.
define rectangle r-rect-1 edge-pixels 2 graphic-edge no-fill {&size} 98.25 by 4.50.
define rectangle r-rect-2 edge-pixels 2 graphic-edge no-fill {&size} 98.25 by 2.25.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  {&table}.obj-type    at row  1.25 col 16.50 {&align} {&combo}    6.00 by 1.00    label "Объект"
  {&table}.obj-code    at row  1.25 col 25.00          {&fill-in} 10.50 by 1.00 no-label
  buf_object.obj-name  at row  1.25 col 36.00          {&fill-in} 63.50 by 1.00 no-label                   format "x(80)":U  fgcolor  4
  {&table}.pl-code     at row  2.50 col 16.50 {&align} {&fill-in} 17.50 by 1.00    label "Складское место"
  buf_place.pl-name    at row  2.50 col 36.00          {&fill-in} 63.50 by 1.00 no-label                   format "x(80)":U  fgcolor  4
  {&table}.pump-code   at row  3.75 col 16.50 {&align} {&fill-in}  3.50 by 1.00    label "ТРК"             format ">9":U
  {&table}.out-code    at row  3.75 col 60.50 {&align} {&fill-in} 17.50 by 1.00    label "Документ"        format "x(16)":U  fgcolor  4
  r-rect-1             at row  5.50 col  1.50
  v-header             at row  5.00 col 29.00          {&fill-in} 40.25 by 1.00 no-label                   format "x(40)":U  {&color}
  {&table}.gds-code    at row  6.00 col 16.50 {&align} {&fill-in} 10.50 by 1.00    label "Код"
  buf_goods.artic      at row  7.25 col 16.50 {&align} {&fill-in} 17.50 by 1.00    label "Артикул"         format "x(16)":U
  buf_goods.gds-name   at row  7.25 col 36.00          {&fill-in} 63.50 by 1.00 no-label                   format "x(80)":U  fgcolor  4
  buf_goods.prod-type  at row  8.50 col 16.50 {&align} {&combo}    6.00 by 1.00    label "Производитель"
  buf_goods.prod-code  at row  8.50 col 25.00          {&fill-in} 10.50 by 1.00 no-label
  buf_clients.obj-name at row  8.50 col 36.00          {&fill-in} 63.50 by 1.00 no-label                   format "x(80)":U  fgcolor  4
  r-rect-2             at row 10.75 col  1.50
  v-label              at row 10.25 col 19.00          {&fill-in} 60.25 by 1.00 no-label                   format "x(60)":U  {&color}
  buf_goods.unit-base  at row 11.50 col  2.50          {&fill-in}  4.00 by 1.00 no-label                   format "x(3)":U   fgcolor  4
  {&table}.doc-qnty    at row 11.50 col 16.50 {&align} {&fill-in} 25.50 by 1.00    label "Заявлено"        format {&q-ty}    fgcolor 12
  {&table}.fact-qnty   at row 11.50 col 60.50 {&align} {&fill-in} 25.50 by 1.00    label "Фактически"      format {&q-ty}    fgcolor 12
  r-rect-0             at row 13.25 col  1.50
    Btn_Exit           at row 13.50 col  2.50
    Btn_OK             at row 13.50 col 78.00
  b-help          at row 13.50 col 88.75
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
    message
      "Карточка истории изменения количества по строке документа по складскому месту и ТРК не найдена."
    view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  assign frame {&FRAME-NAME} :title =
     substitute( 'Карточка изменения количества (товар &1) по документу "&2" (складское место &3, ТРК &4) -- &5',
                 {&table}.gds-code, {&table}.out-code, {&table}.pl-code, {&table}.pump-code, p-mode ).
  display {&table}.obj-type
          {&table}.obj-code
          {&table}.pl-code
          {&table}.pump-code
          {&table}.out-code
          {&table}.gds-code
          {&table}.doc-qnty
          {&table}.fact-qnty
          v-label
          v-header
  with frame {&FRAME-NAME}.

  find first buf_object no-lock where
             buf_object.obj-type = {&table}.obj-type and
             buf_object.obj-code = {&table}.obj-code no-error.
  if available buf_object then do: display buf_object.obj-name with frame {&FRAME-NAME}. end.

  find first buf_goods no-lock where
             buf_goods.gds-code = {&table}.gds-code no-error.
  if available buf_goods then do:
    display buf_goods.artic
            buf_goods.prod-type
            buf_goods.prod-code
            buf_goods.gds-name
            buf_goods.unit-base
    with frame {&FRAME-NAME}.

    find first buf_clients no-lock where
               buf_clients.obj-type = buf_goods.prod-type and
               buf_clients.obj-code = buf_goods.prod-code no-error.
    if available buf_clients then do: display buf_clients.obj-name with frame {&FRAME-NAME}. end.
  end. /* if available buf_goods */

  find first buf_place no-lock where
             buf_place.obj-type = {&table}.obj-type and
             buf_place.obj-code = {&table}.obj-code and
             buf_place.pl-code  = {&table}.pl-code  no-error.
  if available buf_place then do: display buf_place.pl-name with frame {&FRAME-NAME}. end.

  enable Btn_Exit b-help with frame {&FRAME-NAME}.
  if p-mode = {&lookup} then do: hide Btn_OK in frame {&FRAME-NAME}. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.