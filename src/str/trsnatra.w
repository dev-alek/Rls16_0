/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Карточка атрибута основания (причины) создания документа (добавление, изменение, просмотр)

Автор: Чернова Светлана Александровна
Дата создания: 11/30/06
Author: Svetlana Chernova
Creation date: 11/30/06

create: Булгаков Андрей Николаевич

*/

/* ***************************  Definitions  ************************** */
/* Name of first Frame and/or Browse (alphabetically) */
&scop FRAME-NAME fr-D-pump-8
&scop size       size-chars
&scop fill-in    view-as fill-in {&size}
&scop align      colon-aligned

/* Parameters Definitions */
define input        parameter p-parent-proc as widget-handle no-undo.
define input        parameter p-mode        as character     no-undo.
define input-output parameter p-rec-id      as recid         no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Карточка основания (причины) создания документа (добавление, изменение, просмотр)":U.

/* Shared Variable Definitions */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define shared buffer buf_refer for ub.trn-reason.

/* ***********************  Control Definitions  ********************** */
define button   Btn_Exit    label "Вы&ход"   {&size} 10.00 by 1.00 default auto-end-key.
define button   Btn_OK      label "&Ввод "   {&size} 10.00 by 1.00 default auto-go.
define button   Btn_History label "Истори&я" {&size} 10.00 by 1.00 default.
define button {&Btn_Help}   label "Помо&щь"  {&size} 10.00 by 1.00 default.

define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill {&size} 98.25 by 1.50.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  ub.trn-rsn-attr.attr-code  at row  1.25 col 20.50 {&align} {&fill-in} 25.50 by 1.00 label "&Код"      format "x(24)":U
  ub.trn-rsn-attr.attr-value at row  2.50 col 20.50 {&align} {&fill-in} 67.25 by 1.00 label "&Значение" format "x(80)":U
  r-rect-0            at row  3.75 col  1.50
    Btn_Exit          at row  4.00 col  2.50
    Btn_History       at row  4.00 col 67.75
  {&Btn_Help}         at row  4.00 col 78.00
    Btn_OK            at row  4.00 col 88.75
with view-as dialog-box side-labels no-underline three-d scrollable
     title "":U default-button Btn_Exit cancel-button Btn_Exit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.

/* ************************  Control Triggers  ************************ */
on choose of Btn_OK in frame {&FRAME-NAME} do: /* Ввод */
  { gbl/stdbtn.i }
  if p-mode = {&lookup} then do: return. end.
  if ub.trn-rsn-attr.attr-code  :sensitive in frame {&FRAME-NAME} then do: assign ub.trn-rsn-attr.attr-code.  end.
  if ub.trn-rsn-attr.attr-value :sensitive in frame {&FRAME-NAME} then do: assign ub.trn-rsn-attr.attr-value. end.
  apply "GO":U to frame {&FRAME-NAME}.
end.

on choose of Btn_Exit in frame {&FRAME-NAME} do: /* Выход */
  { gbl/stdbtn.i }
end.

on choose of Btn_History in frame {&FRAME-NAME} do: /* История */
  define variable v-list as character no-undo.

  { gbl/stdbtn.i }
  run str/trscatrs.w (
    input        p-parent-proc,
    input        "":U,
    input        "code",
    input        ub.trn-rsn-attr.reason-code,
    input        "":U,
    input         ?  ,  /*chip-num ? */
    input-output v-list                ).
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
  if not available buf_refer then do:
    message "Карточка основания (причины) создания документа не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  if p-mode <> {&add-def} then do:
    find ub.trn-rsn-attr no-lock where recid( ub.trn-rsn-attr ) = p-rec-id no-error.
    if not available ub.trn-rsn-attr then do:
      message "Карточка атрибута основания (причины) создания документа не найдена!" view-as alert-box error.
      undo Main-Block, leave Main-Block.
    end.
  end.

  enable Btn_Exit Btn_History {&Btn_Help} with frame {&FRAME-NAME}.

  if           p-mode = {&add-def} then do:
    assign frame {&FRAME-NAME} :title = "Карточка атрибута основания (причины) создания документа  -- " + p-mode.
    create ub.trn-rsn-attr.
    assign ub.trn-rsn-attr.reason-code = buf_refer.reason-code.
    assign ub.trn-rsn-attr.attr-code :fgcolor = 0.
    enable ub.trn-rsn-attr.attr-code Btn_OK with frame {&FRAME-NAME}.
    assign p-rec-id = recid( ub.trn-rsn-attr ).
  end. else if p-mode = {&update}  then do:
    find ub.trn-rsn-attr exclusive-lock where recid( ub.trn-rsn-attr ) = p-rec-id.
    assign frame {&FRAME-NAME} :title =
      substitute( 'Карточка атрибута "&1" основания (причины) создания документа  -- &2', ub.trn-rsn-attr.attr-code, p-mode ).
    assign ub.trn-rsn-attr.attr-code :fgcolor = 4.
    enable Btn_OK with frame {&FRAME-NAME}.
  end. else if p-mode = {&lookup}  then do:
    assign frame {&FRAME-NAME} :title =
      substitute( 'Карточка атрибута "&1" основания (причины) создания документа  -- &2', ub.trn-rsn-attr.attr-code, p-mode ).
    assign ub.trn-rsn-attr.attr-code  :fgcolor = 4
           ub.trn-rsn-attr.attr-value :fgcolor = 4.
  end.

  display ub.trn-rsn-attr.attr-code
          ub.trn-rsn-attr.attr-value
  with frame {&FRAME-NAME}.
  if p-mode <> {&lookup} then do: enable ub.trn-rsn-attr.attr-value with frame {&FRAME-NAME}. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.