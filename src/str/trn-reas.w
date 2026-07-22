/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список оснований (причин) создания документа

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06

create: Булгаков Андрей Николаевич
Дата создания: 10/18/05

*/

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */
&scop FRAME-NAME  fr-D-reason-0
&scop BROWSE-NAME br-reas
&scop sch-flt     + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
&scop description 'Список оснований (причин) создания документа':U
&scop msg-hdr     Обоснование (причина) создания документов

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter parParentProc as widget-handle no-undo.
define input        parameter p-mode        as character     no-undo.
define input-output parameter p-code        as integer       no-undo.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Список оснований (причин) создания документа":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }
{ gbl/getcntxt.i def           }
{ gbl/getcntxt.i get           }

define temp-table one-empty-record NO-UNDO
       field somthing as logical
       .

define buffer X_trn-reason for ub.trn-reason.
define buffer buf_trn-rsn-attr      for ub.trn-rsn-attr .

define variable filter-point     as character no-undo initial {&table_trn-reason}.
define variable filter-point0    as character no-undo initial {&table_trn-reason}.
define variable filter-label     as character no-undo initial {&description}.
define variable filter-label0    as character no-undo initial {&description}.
define variable sort-column-name as character no-undo.
define variable sch-field        as character no-undo.
define variable FoundRec         as recid     no-undo.
define variable v-doc-rec          as recid     no-undo.
define variable ref-rec          as recid     no-undo.

/* ************************  Function Prototypes ********************** */
/*
function attr-sign returns character ( input i-code as integer ) :
  define variable v_sign as character no-undo.

  run get-attr-sign in this-procedure ( input i-code, output v_sign ).
  return ( v_sign ).
end function. attr-sign */

/* Definitions for BROWSE {&BROWSE-NAME}                                */
&scop label-clmn_1-tr 'Код основания'
&scop form-clmn_1-tr  "->,>>>,>>>,>>9":U
&scop sort-clmn_1-tr  X_trn-reason.reason-code
&scop label-clmn_2-tr 'Основание (причина) создания документа'
&scop form-clmn_2-tr  "x(79)":U
&scop sort-clmn_2-tr  X_trn-reason.reason-name
&scop label-clmn_3-tr 'А'
&scop form-clmn_3-tr  "+/ ":U
&scop sort-clmn_3-tr  AVAILABLE buf_trn-rsn-attr
&scop label-clmn_4-tr 'Примечание'
&scop form-clmn_4-tr  "x(95)":U
&scop sort-clmn_4-tr  X_trn-reason.PS
&scop enabled-clmn-tr {&sort-clmn_4-tr}

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
define button b-help label "Помо&щь"   size-chars 10.00 by 1.00 default.
define button b-quit label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-add  label "&Добавить" size-chars 10.00 by 1.00 default.
define button b-chg  label "&Изменить" size-chars 10.00 by 1.00 default.
define button b-lkp  label "&Просмотр" size-chars 10.00 by 1.00 default.
define button b-del  label "&Удалить"  size-chars 10.00 by 1.00 default.
define button b-sch  label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-sel  label "Вы&бор"    size-chars 10.00 by 1.00 default auto-go.
define button b-History label "Истори&я"  size-chars 10.00 by 1.00 default.

DEFINE variable tb-deleted AS LOGICAL NO-UNDO label "Показывать удаленные"  view-as TOGGLE-BOX size-chars 22.63 BY .79 .
define variable sch-code as integer   no-undo view-as fill-in size-chars 15.50 by 1.00 format "->,>>>,>>>,>>>":U.
define variable sch-name as character no-undo view-as fill-in size-chars 45.50 by 1.00 format "x(60)":U.
define variable sch-num  as integer   no-undo view-as fill-in size-chars  4.50 by 1.00 format ">>>":U.
define variable PS-notes as character no-undo view-as editor  no-word-wrap scrollbar-vertical scrollbar-horizontal
                                                              size-chars 98.25 by 3.00 format "x(512)":U fgcolor 4.

/* Query definitions                                                    */
define query {&BROWSE-NAME} for X_trn-reason, buf_trn-rsn-attr, one-empty-record scrolling.

/* Browse definitions                                                   */
define browse {&BROWSE-NAME} query {&BROWSE-NAME} display
{&sort-clmn_1-tr} column-label {&label-clmn_1-tr} format {&form-clmn_1-tr}
{&sort-clmn_2-tr} column-label {&label-clmn_2-tr} format {&form-clmn_2-tr}
{&sort-clmn_3-tr} column-label {&label-clmn_3-tr} format {&form-clmn_3-tr}
{&sort-clmn_4-tr} column-label {&label-clmn_4-tr} format {&form-clmn_4-tr}
enable
{&enabled-clmn-tr}
with no-row-markers separators size-chars 98.25 by 15.13.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
b-quit   at row  1 col  1
b-sel    at row  1 col 11
b-add    at row  1 col 21
b-lkp    at row  1 col 31
b-chg    at row  1 col 41
b-del    at row  1 col 51
b-History  at row  1 col 61
b-sch      at row  1 col 71
b-help     at row  1 col 91
tb-deleted at row  1.1 col 62
{&BROWSE-NAME} at row  3.00 col  1.50
"          ":U at row 18.50 col  1.62 view-as text size-chars 98.00 by 1.00
"ПОИСК ПО:"    at row 18.50 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
sch-code       at row 18.50 col 11.50    label "&Коду"
sch-name       at row 18.50 col 36.00    label "П&ричине"
sch-num        at row 18.50 col 94.75 no-label                              fgcolor 4
PS-notes       at row 20.00 col  1.50 no-label                              fgcolor 4 bgcolor  8
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
title {&description}
default-button b-quit cancel-button b-quit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.
assign {&enabled-clmn-tr} :read-only in browse {&BROWSE-NAME} = yes.
assign   b-quit     :tooltip in frame {&FRAME-NAME} = "Вернуться в окно вызова"
       b-sch  :tooltip in frame {&FRAME-NAME} = "Установить/снять фильтр"
       b-help    :tooltip in frame {&FRAME-NAME} = "Интерактивная помощь в формате *.html"
       b-add     :tooltip in frame {&FRAME-NAME} = "Добавить новую запись"
       b-chg    :tooltip in frame {&FRAME-NAME} = "Изменить текущую запись"
       b-lkp    :tooltip in frame {&FRAME-NAME} = "Просмотреть текущую запись"
       b-del  :tooltip in frame {&FRAME-NAME} = "Удалить текущую запись"
       b-sel  :tooltip in frame {&FRAME-NAME} = "Выбрать текущую запись"
         b-History  :tooltip in frame {&FRAME-NAME} = "История основания (причины)"
       {&BROWSE-NAME} :tooltip in frame {&FRAME-NAME} = "Список оснований (причин) создания документа"
         PS-notes     :tooltip in frame {&FRAME-NAME} = "Примечание к основанию (причине) создания документа"
         sch-code     :tooltip in frame {&FRAME-NAME} = "Код основания (причины)" {&sch-flt}
         sch-name     :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа" {&sch-flt}
         sch-num      :tooltip in frame {&FRAME-NAME} = "Количество найденных записей".

/* ************************  Control Triggers  ************************ */
on insert-mode of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  if b-sel :sensitive in frame {&FRAME-NAME} then do:
    apply "CHOOSE":U to b-sel in frame {&FRAME-NAME}.
  end.
end.

on choose of b-sch in frame {&FRAME-NAME} do: /* Фильтр */
  { gbl/stdbtn.i }
  {&SetCursorWait}
  run proc-filter in this-procedure no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on choose of b-History in frame {&FRAME-NAME} do: /* История */
  define variable v-list as character no-undo.

  { gbl/stdbtn.i }
  if not available X_trn-reason then do:
    message
    "Неправильно выбрана строка."
    view-as alert-box error.
    return no-apply.
  end.
  run str/trncrsns.w ( input parParentProc
                     , input "":U
                     , input "one"
                     , input X_trn-reason.reason-code
                     , input-output v-list ).
  apply "ENTRY":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.

on choose of b-sel in frame {&FRAME-NAME} do: /* Выбор */
  { gbl/stdbtn.i }
  if not available X_trn-reason then do:
    return no-apply.
  end.
  assign p-code = X_trn-reason.reason-code.
end.

on choose of b-add in frame {&FRAME-NAME} do: /* Добавить */
  { gbl/stdbtn.i }
  run str/trn-rsna.w ( input parParentProc
                     , input {&add-def}
                     , input-output v-doc-rec ) no-error.
  if not error-status :error
  and v-doc-rec <> ? then do:
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
  end.
end.

on choose of b-chg in frame {&FRAME-NAME} do: /* Изменить */
  { gbl/stdbtn.i }
  if not available X_trn-reason then do:
    message
    "Неправильно выбрана строка."
    view-as alert-box error.
    return no-apply.
  end.
  else do:
    assign v-doc-rec = recid( X_trn-reason ).
  end.
  run str/trn-rsna.w ( input parParentProc
                     , input {&update}
                     , input-output v-doc-rec ).
  reposition {&BROWSE-NAME} to recid v-doc-rec no-error.
  if error-status :error then do:
    reposition {&BROWSE-NAME} to row 1 no-error.
  end.
  apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.

on choose of b-lkp in frame {&FRAME-NAME} do: /* Просмотр */
  { gbl/stdbtn.i }
  if not available X_trn-reason then do:
    message
    "Неправильно выбрана строка." view-as alert-box error.
    return no-apply.
  end.
  else do:
    assign v-doc-rec = recid( X_trn-reason ).
  end.
  run str/trn-rsna.w ( input parParentProc
                     , input {&lookup}
                     , input-output v-doc-rec ).
  apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.

on choose of b-del in frame {&FRAME-NAME} do: /* Удалить */
  { gbl/stdbtn.i }
  if not available X_trn-reason then do:
    message
    "Неправильно выбрана строка."
    view-as alert-box error.
    return no-apply.
  end.
  else do:
    assign v-doc-rec = recid( X_trn-reason ).
  end.
  run proc-delete in this-procedure no-error.
  if not error-status :error then do:
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
  end.
end.

on return                of {&BROWSE-NAME} in frame {&FRAME-NAME} or
   mouse-select-dblclick of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  if b-sel :sensitive in frame {&FRAME-NAME} then do:
    apply "CHOOSE":U to b-sel in frame {&FRAME-NAME}.
  end.
end.

on value-changed of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  assign
  PS-notes = ( if available X_trn-reason then X_trn-reason.PS else "":U ).
  display
  PS-notes
  with frame {&FRAME-NAME}.
end.

on leave of PS-notes in frame {&FRAME-NAME} do:
  define variable v-nota_bene as character no-undo.

  define buffer PS_doc for ub.trn-reason.

  assign v-nota_bene = ( input frame {&FRAME-NAME} PS-notes ).
  if available X_trn-reason then
  do on error undo, return no-apply :
    find PS_doc exclusive-lock where
       recid( PS_doc ) = recid( X_trn-reason ).
    if PS_doc.PS <> v-nota_bene then do:
      assign PS_doc.PS = v-nota_bene.
    end.
    find PS_doc        no-lock where
         recid( PS_doc ) = recid( X_trn-reason ).
  end.
  else do:
    assign
    PS-notes :screen-value in frame {&FRAME-NAME} = "":U.
  end.
end.

on entry of sch-code in frame {&FRAME-NAME} do:
  assign sch-name :screen-value in frame {&FRAME-NAME} = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display sch-code  with frame {&FRAME-NAME}.
end.

on entry of sch-name in frame {&FRAME-NAME} do:
  assign sch-code :screen-value in frame {&FRAME-NAME} = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display sch-name  with frame {&FRAME-NAME}.
end.

on leave of sch-code in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on leave of sch-name in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on CTRL-J of sch-code in frame {&FRAME-NAME} do: /* код */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-code <> sch-code then do:
    assign sch-code.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-code in this-procedure ( input yes, input sch-code ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on return of sch-code in frame {&FRAME-NAME} do: /* код */
  {&SetCursorWait}
  assign sch-code.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-code in this-procedure ( input no,  input sch-code ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on mouse-select-dblclick of sch-code in frame {&FRAME-NAME} do: /* код */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-code <> sch-code then do:
    assign sch-code.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-code in this-procedure ( input yes, input sch-code ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on CTRL-J of sch-name in frame {&FRAME-NAME} do: /* название */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-name <> sch-name then do:
    assign sch-name.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-name in this-procedure ( input yes, input sch-name ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on return of sch-name in frame {&FRAME-NAME} do: /* название */
  {&SetCursorWait}
  assign sch-name.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-name in this-procedure ( input no,  input sch-name ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on mouse-select-dblclick of sch-name in frame {&FRAME-NAME} do: /* название */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-name <> sch-name then do:
    assign sch-name.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-name in this-procedure ( input yes, input sch-name ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on value-changed of tb-deleted DO:
    assign tb-deleted.
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
END.

on value-changed of {&BROWSE-NAME} DO:
    run my-enable in this-procedure.
END.

{ gbl/hot-key.i b-help   }
{ gbl/hot-key.i b-add    }
{ gbl/hot-key.i b-chg   }
{ gbl/hot-key.i b-lkp   }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }

/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent. */
if valid-handle( active-window ) and frame {&FRAME-NAME} :parent = ? then frame {&FRAME-NAME} :parent = active-window.

/* Restore the current-window if it is an icon. Otherwise the dialog box will be hidden */
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR */
on window-close of frame {&FRAME-NAME} do: apply "END-ERROR":U to self. end.

{ gbl/app_help.i }

{ gbl/mv-clmn.i
    &ext-col      = 4
    &frame-name   = {&FRAME-NAME}
    &browse-name  = {&BROWSE-NAME}
    &table-name   = "X_trn-reason"
    &start-column = 1              }

{ gbl/srt-clmd.i
    &ext-col              = 4
    &frame-name           = {&FRAME-NAME}
    &browse-name          = {&BROWSE-NAME}
    &table-name           = "X_trn-reason"
    &start-column         = 1
    &label-clmn_1         = "{&label-clmn_1-tr}"
    &sort-clmn_1          = "{&sort-clmn_1-tr}"
    &label-clmn_2         = "{&label-clmn_2-tr}"
    &sort-clmn_2          = "{&sort-clmn_2-tr}"
    &sort-clmn_4          = "{&sort-clmn_4-tr}"
    &label-clmn_4         = "{&label-clmn_4-tr}"
    &open-query           = "run OpenBr in this-procedure ( input yes, input no, input '':U )."
    &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U )."
    &sort-column-name     = "sort-column-name"
    &re-move-clmn         = "no"
    &mv-brw-default       = "yes"                                                               }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  {&SetCursorWait}

  create one-empty-record. /* создаем любую таблицу с ровно одной записью в ней */

  display   PS-notes     with frame {&FRAME-NAME}.
  enable  b-sch  b-help b-History b-quit b-lkp
          tb-deleted
          {&BROWSE-NAME}   sch-code  sch-name    PS-notes
  with frame {&FRAME-NAME}.
  if p-mode = {&reference} then do:
    if v-cntxt-db-num = 0 then do:
      enable
      b-add b-chg b-del
      with frame {&FRAME-NAME}.
    end.
    else do:
      disable
      b-add b-chg b-del tb-deleted
      with frame {&FRAME-NAME}.
    end.
    disable
    b-sel with frame {&FRAME-NAME}.
  end.
  else if p-mode = {&choose} then do:
    enable
    b-sel with frame {&FRAME-NAME}.
    disable
    b-add b-chg b-del tb-deleted
    with frame {&FRAME-NAME}.
  end.
  find first X_trn-reason no-lock where
             X_trn-reason.reason-code = p-code no-error.
  assign
  ref-rec = ( if available X_trn-reason then recid( X_trn-reason ) else ? ).
  run OpenBr in this-procedure ( input yes, input no, input '':U ).
  RUN my-enable IN THIS-PROCEDURE .
  hide sch-num in frame {&FRAME-NAME}.
  {&BROWSE-NAME} :set-repositioned-row( 5, "CONDITIONAL":U ).
  if ref-rec <> ? then do:
    reposition {&BROWSE-NAME} to recid ref-rec no-error.
    if error-status :error then do: reposition {&BROWSE-NAME} to row 1 no-error. end.
                           else do: assign v-doc-rec = ref-rec. end.
  end.
  {&SetCursorNo}

  wait-for go of frame {&FRAME-NAME}.
end.
hide frame {&FRAME-NAME} no-pause.

/* **********************  Internal Procedures  *********************** */
procedure OpenBr :
  define input parameter p-open-query     as logical   no-undo.
  define input parameter p-find-next      as logical   no-undo.
  define input parameter p-find-condition as character no-undo.

  define variable l-query-was-opened as logical   no-undo.
  define variable sort-column-phrase as character no-undo.
  define variable p-proc-hand        as handle    no-undo.
  define variable l-open-query       as logical   no-undo.

  assign
   p-proc-hand = this-procedure :handle
  .


  case sort-column-name :
    when "":U                    then do:
      assign sort-column-phrase = "":U.
    end.
    when "X_trn-reason.reason-name" then do:
      assign sort-column-phrase = "by substring( X_trn-reason.reason-name, 1, 79 )".
    end.
    when "X_trn-reason.PS"          then do:
      assign sort-column-phrase = "by substring( X_trn-reason.PS,          1, 95 )".
    end.
    otherwise                         do:
      assign sort-column-phrase = "by " + sort-column-name.
    end.
  end case. /* sort-column-name */

  &scop flt-open-open-query         open query {&BROWSE-NAME} for each X_trn-reason no-lock
  &scop flt-open-dyn_open-query     for each X_trn-reason
  &scop flt-open-query-handle       query {&BROWSE-NAME}:handle
  &scop flt-open-query-was-opened   l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point         filter-point
  &scop flt-open-set-filter-name    set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition
  &scop flt-open-query              p-open-query
  &scop flt-open-table-name         X_trn-reason
  &scop flt-open-search-option      no-lock
  &scop flt-open-find-next          p-find-next
  &scop flt-open-find-recid         v-doc-rec
  &scop flt-open-find-condition     p-find-condition
  &scop flt-open-find-buffer-def    X_trn-reason
  &scop flt-open-waitfram           yes
  &scop flt-open-open-query-tail     , first buf_trn-rsn-attr outer-join of X_trn-reason no-lock, first one-empty-record no-lock WHERE YES AND ((NOT AVAILABLE buf_trn-rsn-attr) OR (tb-deleted = TRUE))
  &scop flt-open-dyn_open-query-tail    SUBSTITUTE(', first buf_trn-rsn-attr outer-join of X_trn-reason no-lock, first one-empty-record no-lock WHERE YES AND ((NOT AVAILABLE buf_trn-rsn-attr) OR (&1 = TRUE))', tb-deleted)

  assign
  frame {&FRAME-NAME} :title = substitute("&1 &2", {&description}, p-mode).
  { gbl/fltopend.i
      &where-cond = " YES "
      &use-ind    = "  "
      &by         = "  "  }

if p-open-query <> yes and v-doc-rec <> ? then
reposition {&BROWSE-NAME} to recid v-doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query {&BROWSE-NAME}:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end procedure. /* OpenBr */

procedure proc-filter :
  assign tbl      = 'trn-reason'
         join-tbl = 'X_trn-reason'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.

  {&SetCursorWait}
  &scop common-params input '':U, input-output fld, input-output lab, input-output spr, input-output dim
  run fltfield-add in this-procedure ( input 'reason-code', input 'Код причины',         {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'reason-name', input 'Основание (причина)', {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'PS',          input 'Примечание',          {&common-params} ) no-error.

  Filter-Block:
  do on error   undo Filter-Block, leave Filter-Block
     on end-key undo Filter-Block, leave Filter-Block :
    run gbl/filter.w ( input parParentProc
                   ,input filter-point + {&delim-par} + filter-label
                   ,input tbl
                   ,input join-tbl
                   ,input fld
                   ,input lab
                   ,input spr
                   ,input dim            ).
    if return-value = {&flt-undo-value} then do:
      apply "ENTRY":U to browse {&BROWSE-NAME}.
      return no-apply.
    end.
    assign sch-num = 0.
    hide   sch-num in frame {&FRAME-NAME}.
    {&SetCursorWait}
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
    {&SetCursorNo}
  end. /* Filter-Block */
end procedure. /* proc-filter */

{ gbl/setfltnm.i }

procedure proc-find-code :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer no-undo.

  {&SetCursorWait}
  run OpenBr in this-procedure ( input no, input p-next, input substitute( ' AND X_trn-reason.reason-code = &1 ', p-code ) ).
  if v-doc-rec <> ? then do:
    if FoundRec = ? then do:
      assign FoundRec = v-doc-rec.
    end.
    if FoundRec = v-doc-rec then do:
      assign sch-num = 0.
    end.
    assign  sch-num = sch-num + 1.
    display
    sch-num with frame {&FRAME-NAME}.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num
    in frame {&FRAME-NAME}.
  end.
  apply "ENTRY":U to sch-code in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-code */

procedure proc-find-name :
  define input parameter p-next as logical   no-undo.
  define input parameter p-name as character no-undo.

  assign p-name = replace( p-name, {&double-quote}, {&double-quote} + {&double-quote} )
         p-name = replace( p-name, {&single-quote}, {&single-quote} + {&single-quote} )
         p-name = {&double-quote} + p-name + {&double-quote}.
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( ' AND X_trn-reason.reason-name begins &1 ', p-name ) ).
  if v-doc-rec <> ? then do:
    if FoundRec = ? then do:
      assign FoundRec = v-doc-rec.
    end.
    if FoundRec = v-doc-rec then do:
      assign sch-num = 0.
    end.
    assign  sch-num = sch-num + 1.
    display sch-num
    with frame {&FRAME-NAME}.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num
    in frame {&FRAME-NAME}.
  end.
  apply "ENTRY":U to sch-name in frame {&frame-name}.
end procedure. /* proc-find-name */

procedure proc-delete :
  define variable l_log as logical no-undo.

  run ref/trn-rsn1.p
    ( input-output v-doc-rec
    , input {&deletion}
    , input false /* p-silent */
    , input "":U
    , input "":U
    , input "":U
    ) no-error.
  if error-status:error then do:
    message
      substitute("Ошибка при удалении основания (причины)") skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  get prev {&BROWSE-NAME} no-lock.
  if not available X_trn-reason then do:
    get prev {&BROWSE-NAME} no-lock.
  end.
  if not available X_trn-reason then do:
    get next {&BROWSE-NAME} no-lock.
  end.
  assign
    v-doc-rec = ( if available X_trn-reason then recid( X_trn-reason ) else ? )
  .

  reposition {&BROWSE-NAME} to recid v-doc-rec no-error.
  if error-status :error then do:
    reposition {&BROWSE-NAME} to row 1 no-error.
  end.
  apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.

end procedure. /* proc-delete */

procedure get-attr-sign :
  define  input parameter p-code as integer   no-undo.
  define output parameter p-attr as character no-undo.

  define buffer buf_attr for ub.trn-rsn-attr.

  do on error   undo, leave
     on end-key undo, leave :
    find first buf_attr no-lock where
               buf_attr.reason-code = p-code no-error.
    assign p-attr = ( if available buf_attr then "+":U else " ":U ).
  end. /* on error */
end procedure. /* get-attr-sign */

/*==========================================================================*/
procedure my-enable :

do
on error undo, return error
:
   define buffer buf_trn-rsn-attr      for ub.trn-rsn-attr .
   IF CAN-FIND(first buf_trn-rsn-attr
               where buf_trn-rsn-attr.reason-code = X_trn-reason.reason-code
                 and buf_trn-rsn-attr.attr-code   = "del":U
            no-lock)
   THEN DO:
      disable
         b-chg b-del
      with frame {&FRAME-NAME}.
   END.
   ELSE DO:
     if   p-mode = {&reference}
     AND  v-cntxt-db-num = 0 then do:
      enable
         b-chg b-del
      with frame {&FRAME-NAME}.
      END.
   END.

end. /* do on error */
end procedure. /* my-enable */