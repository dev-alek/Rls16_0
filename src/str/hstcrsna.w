/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр карточки истории изменения основания (причины) создания документа по фирме

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06

create: Булгаков Андрей Николаевич
Дата создания: 06/24/05

*/

/* ***************************  Definitions  ************************** */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME fr-D-pump-8
&scop size       size-chars
&scop fill-in    view-as fill-in    {&size}
&scop toggle     view-as toggle-box {&size}
&scop align      colon-aligned

/* Parameters Definitions */
define input        parameter p-parent-proc as widget-handle no-undo.
define input        parameter p-mode        as character     no-undo.
define input-output parameter p-rec-id      as recid         no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения основания (причины) создания документа по фирме":U.

/* Shared Variable Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define buffer buf_cli for ub.clients.
define buffer buf_rsn for ub.trn-reason.

/* ***********************  Control Definitions  ********************** */
define button   Btn_Exit  label "Вы&ход"  {&size} 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  {&size} 10.00 by 1.00 default auto-go.
define button b-help label "Помо&щь" {&size} 10.00 by 1.00 default.

define variable v-ext-doc-name as character no-undo format "x(256)":U label "Расширенный тип документа".

define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill {&size} 98.25 by 1.50.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  ub.c-trn-reason-host.host-code   at row 1.25 col  3.00 {&fill-in} 10.00 by 1.00    label "Фирма"   format ">>>>>>>>>":U
  buf_cli.obj-name     at row 1.25 col 20.25 {&fill-in} 79.50 by 1.00 no-label fgcolor 4 format "x(256)":U
  v-ext-doc-name       at row 2.50 col  3.00 {&fill-in} 69.75 by 1.00          fgcolor 4
  ub.c-trn-reason-host.hold-doc    at row 3.75 col  3.00 {&toggle}  96.50 by 1.00
  ub.c-trn-reason-host.reason-code at row 5.00 col  3.00 {&fill-in} 11.50 by 1.00    label "Причина" format ">>>>>>>>>>":U
  buf_rsn.reason-name  at row 5.00 col 24.25 {&fill-in} 75.50 by 1.00 no-label fgcolor 4 format "x(256)":U
  r-rect-0             at row 6.50 col  1.50
    Btn_Exit           at row 6.75 col  2.50
    Btn_OK             at row 6.75 col 78.00
  b-help          at row 6.75 col 88.75
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
  {&SetCursorWait}
  if p-mode <> {&lookup} then do:
    {&SetCursorNo}
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    undo Main-Block, return error.
  end.

  find ub.c-trn-reason-host no-lock where recid( ub.c-trn-reason-host ) = p-rec-id no-error.
  if not available ub.c-trn-reason-host then do:
    {&SetCursorNo}
    message "Карточка истории не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  find first buf_cli no-lock where
             buf_cli.obj-type = {&cmp}             and
             buf_cli.obj-code = ub.c-trn-reason-host.host-code no-error.
  assign v-ext-doc-name = entry( lookup( ub.c-trn-reason-host.ext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ).
  find first buf_rsn no-lock where
             buf_rsn.reason-code = ub.c-trn-reason-host.reason-code no-error.
  assign frame {&FRAME-NAME} :title = "Код основания (причины) создания документа по умолчанию на объекте".
  display ub.c-trn-reason-host.host-code
          buf_cli.obj-name
          v-ext-doc-name
          ub.c-trn-reason-host.hold-doc
          ub.c-trn-reason-host.reason-code
          buf_rsn.reason-name
  with frame {&FRAME-NAME}.
  enable Btn_Exit b-help with frame {&FRAME-NAME}.
  if p-mode = {&lookup} then do: hide Btn_OK in frame {&FRAME-NAME}. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.