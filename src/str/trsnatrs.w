/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список атрибутов оснований (причин) создания документа

Автор: Чернова Светлана Александровна
Дата создания: 11/30/06
Author: Svetlana Chernova
Creation date: 11/30/06

create: Булгаков Андрей Николаевич

Заготовка на будущее , атрибутов нет

*/

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */
&scop FRAME-NAME  fr-D-rsnattr-0
&scop BROWSE-NAME br-rattrs
&scop sch-flt     + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
&scop description 'Список атрибутов оснований (причин) создания документа':U

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parParentProc as widget-handle no-undo.
define input parameter p-mode        as character     no-undo.
define input parameter p-code        as integer       no-undo.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Список атрибутов оснований (причин) создания документа":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/waitfram.i }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }

define buffer X_trn-rsn-attr for ub.trn-rsn-attr.

define variable filter-point     as character no-undo initial {&table_trn-rsn-attr}.
define variable filter-point0    as character no-undo initial {&table_trn-rsn-attr}.
define variable filter-label     as character no-undo initial "Атрибуты причин создания документов".
define variable filter-loabel0   as character no-undo initial "Атрибуты причин создания документов".

define variable sort-column-name as character no-undo.
define variable sch-field        as character no-undo.
define variable FoundRec         as recid     no-undo.
define variable v-doc-rec        as recid     no-undo.

/* Definitions for BROWSE {&BROWSE-NAME}                                */
&scop label-clmn_1--tr 'Код атрибута'
&scop form-clmn_1--tr  "x(24)":U
&scop sort-clmn_1--tr  X_trn-rsn-attr.attr-code
&scop label-clmn_2--tr 'Значение'
&scop form-clmn_2--tr  "x(69)":U
&scop sort-clmn_2--tr  X_trn-rsn-attr.attr-value
&scop enabled-clmn--tr {&sort-clmn_2--tr}

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
define button b-help   label "Помо&щь"   size-chars 10.00 by 1.00 default.
define button b-quit    label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-add    label "&Добавить" size-chars 10.00 by 1.00 default.
define button b-chg   label "&Изменить" size-chars 10.00 by 1.00 default.
define button b-lkp   label "&Просмотр" size-chars 10.00 by 1.00 default.
define button b-del label "&Удалить"  size-chars 10.00 by 1.00 default.
define button b-sch label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-History label "Истори&я"  size-chars 10.00 by 1.00 default.

define variable sch-code as character no-undo view-as fill-in size-chars 25.50 by 1.00 format "x(24)":U.
define variable sch-num  as integer   no-undo view-as fill-in size-chars  4.50 by 1.00 format ">>>":U.

/* Query definitions                                                    */
define query {&BROWSE-NAME} for X_trn-rsn-attr scrolling.

/* Browse definitions                                                   */
define browse {&BROWSE-NAME} query {&BROWSE-NAME} display
{&sort-clmn_1--tr} column-label {&label-clmn_1--tr} format {&form-clmn_1--tr}
{&sort-clmn_2--tr} column-label {&label-clmn_2--tr} format {&form-clmn_2--tr}
enable
{&enabled-clmn--tr}
with no-row-markers separators size-chars 98.25 by 17.13.

define rectangle r-rect-0 edge-pixels  3 graphic-edge no-fill size-chars 98.25 by 1.50.
define rectangle r-rect-1 edge-pixels 18 graphic-edge no-fill size-chars 98.25 by 1.50.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
r-rect-0     at row  1.25 col  1.50
b-quit     at row  1.50 col  2.50
b-add     at row  1.50 col 20.25
b-chg    at row  1.50 col 30.50
b-lkp    at row  1.50 col 40.75
b-del  at row  1.50 col 51.00
b-History  at row  1.50 col 68.25
b-sch  at row  1.50 col 78.50
b-help    at row  1.50 col 88.75
{&BROWSE-NAME} at row  3.00 col  1.50
r-rect-1     at row 20.25 col  1.50
"          ":U at row 20.50 col  1.62 view-as text size-chars 98.00 by 1.00
"ПОИСК ПО:"    at row 20.50 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
sch-code       at row 20.50 col 11.50    label "&Коду"
sch-num        at row 20.50 col 94.75 no-label                              fgcolor 4
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
title {&description}
default-button b-quit cancel-button b-quit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.
assign {&enabled-clmn--tr} :read-only in browse {&BROWSE-NAME} = yes.
assign   b-quit     :tooltip in frame {&FRAME-NAME} = "Вернуться в окно вызова"
       b-sch  :tooltip in frame {&FRAME-NAME} = "Установить/снять фильтр"
       b-help    :tooltip in frame {&FRAME-NAME} = "Интерактивная помощь в формате *.html"
       b-add     :tooltip in frame {&FRAME-NAME} = "Добавить новую запись"
       b-chg    :tooltip in frame {&FRAME-NAME} = "Изменить текущую запись"
       b-lkp    :tooltip in frame {&FRAME-NAME} = "Просмотреть текущую запись"
       b-del  :tooltip in frame {&FRAME-NAME} = "Удалить текущую запись"
         b-History  :tooltip in frame {&FRAME-NAME} = "История атрибутов основания (причины) создания документа"
       {&BROWSE-NAME} :tooltip in frame {&FRAME-NAME} = "Список атрибутов оснований (причин) создания документа"
         sch-code     :tooltip in frame {&FRAME-NAME} = "Код основания (причины)" {&sch-flt}
         sch-num      :tooltip in frame {&FRAME-NAME} = "Количество найденных записей".

/* ************************  Control Triggers  ************************ */
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
  if not available X_trn-rsn-attr then do:
    message "Неправильно выбрана строка." view-as alert-box error.
    return no-apply.
  end.
  run str/trscatrs.w (
                    input        parParentProc
                   ,input        "":U
                   ,input        "code"
                   ,input        X_trn-rsn-attr.reason-code
                   ,input        "":U
                   ,input        ?  /* p-chip-num ? */
                   ,input-output v-list                 ).
  apply "ENTRY":U to {&BROWSE-NAME} in frame {&FRAME-NAME    }.
end.

on choose of b-add in frame {&FRAME-NAME} do: /* Добавить */
  { gbl/stdbtn.i }
  run str/trsnatra.w ( input parParentProc
                     , input {&add-def}
                     , input-output v-doc-rec ).
  run OpenBr in this-procedure ( input yes, input no, input '':U ).
end.

on choose of b-chg in frame {&FRAME-NAME} do: /* Изменить */
  { gbl/stdbtn.i }
  if not available X_trn-rsn-attr then do:
    message "Неправильно выбрана строка." view-as alert-box error.
    return no-apply.
  end.
  assign v-doc-rec = recid( X_trn-rsn-attr ).
  run str/trsnatra.w ( input parParentProc
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
  if not available X_trn-rsn-attr then do:
    message "Неправильно выбрана строка." view-as alert-box error.
    return no-apply.
  end.
  assign v-doc-rec = recid( X_trn-rsn-attr ).
  run str/trsnatra.w ( input parParentProc
                     , input {&lookup}
                     , input-output v-doc-rec ).
  apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.

on choose of b-del in frame {&FRAME-NAME} do: /* Удалить */
  { gbl/stdbtn.i }
  if not available X_trn-rsn-attr then do:
    message "Неправильно выбрана строка." view-as alert-box error.
    return no-apply.
  end.
  assign v-doc-rec = recid( X_trn-rsn-attr ).
  run proc-delete in this-procedure no-error.
  if not error-status :error then do:
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
  end.
end.

on entry of sch-code in frame {&FRAME-NAME} do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display
  sch-code
  with frame {&FRAME-NAME}.
end.

on leave of sch-code in frame {&FRAME-NAME} do:
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
  if error-status :error then do:
    return no-apply.
  end.
end.

on return of sch-code in frame {&FRAME-NAME} do: /* код */
  {&SetCursorWait}
  assign sch-code.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-code in this-procedure ( input no,  input sch-code ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
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
  if error-status :error then do:
    return no-apply.
  end.
end.

{ gbl/hot-key.i b-help   }
{ gbl/hot-key.i b-add    }
{ gbl/hot-key.i b-chg   }
{ gbl/hot-key.i b-lkp   }
{ gbl/hot-key.i b-del }

/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent. */
if valid-handle( active-window ) and frame {&FRAME-NAME} :parent = ? then frame {&FRAME-NAME} :parent = active-window.

/* Restore the current-window if it is an icon. Otherwise the dialog box will be hidden */
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR */
on window-close of frame {&FRAME-NAME} do: apply "END-ERROR":U to self. end.

{ gbl/app_help.i }

{ gbl/mv-clmn.i
    &ext-col      = 2
    &frame-name   = {&FRAME-NAME}
    &browse-name  = {&BROWSE-NAME}
    &table-name   = "X_trn-rsn-attr"
    &start-column = 1              }

{ gbl/srt-clmd.i
    &ext-col              = 2
    &frame-name           = {&FRAME-NAME}
    &browse-name          = {&BROWSE-NAME}
    &table-name           = "X_trn-rsn-attr"
    &start-column         = 1
    &label-clmn_1         = "{&label-clmn_1--tr}"
    &sort-clmn_1          = "{&sort-clmn_1--tr}"
    &label-clmn_2         = "{&label-clmn_2--tr}"
    &sort-clmn_2          = "{&sort-clmn_2--tr}"
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
  enable b-sch b-help b-History b-quit b-lkp {&BROWSE-NAME} sch-code with frame {&FRAME-NAME}.
  if p-mode <> {&lookup} then do:
    enable
    b-add
    b-chg
    b-del
    with frame {&FRAME-NAME}.
  end.
  run OpenBr in this-procedure ( input yes, input no, input '':U ).
  hide sch-num in frame {&FRAME-NAME}.
  {&BROWSE-NAME} :set-repositioned-row( 5, "CONDITIONAL":U ).
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

define buffer X_trn-reason for ub.trn-reason.

assign p-proc-hand = this-procedure :handle.

case sort-column-name :
  when "":U                   then do:
    assign sort-column-phrase = "":U.
  end.
  when "X_trn-rsn-attr.attr-code"  then do:
    assign sort-column-phrase = "by substring( X_trn-rsn-attr.reason-name, 1, 24 )".
  end.
  when "X_trn-rsn-attr.attr-value" then do:
    assign sort-column-phrase = "by substring( X_trn-rsn-attr.PS,          1, 69 )".
  end.
  otherwise                        do:
    assign sort-column-phrase = "by " + sort-column-name.
  end.
end case. /* sort-column-name */

&scop flt-open-open-query         open query br-rattrs for each X_trn-rsn-attr
&scop flt-open-dyn_open-query     each X_trn-rsn-attr
&scop flt-open-query-handle       query br-rattrs:handle
&scop flt-open-open-query-tail
&scop flt-open-query-was-opened   l-query-was-opened
&scop flt-open-sort-column-phrase sort-column-phrase
&scop flt-open-call-point         filter-point
&scop flt-open-set-filter-name    set-filter-name
&scop flt-open-indexed-reposition indexed-reposition
&scop flt-open-query              p-open-query
&scop flt-open-table-name         X_trn-rsn-attr
&scop flt-open-search-option      no-lock
&scop flt-open-find-next          p-find-next
&scop flt-open-find-recid         v-doc-rec
&scop flt-open-find-condition     p-find-condition
&scop flt-open-find-buffer-name   X_trn-rsn-attr
&scop flt-open-waitfram           yes

find X_trn-reason no-lock where
      X_trn-reason.reason-code = p-code no-error.
assign
frame {&FRAME-NAME} :title = substitute( "&1 &2"
                                       ,  {&description}
                                       ,(if available X_trn-reason
                                       then X_trn-reason.reason-name
                                       else "":U )
                                      )
                                      .
{ gbl/fltopend.i
    &where-cond = " yes  "
    &use-ind    = "  "
    &by         = "  "  }
if p-open-query <> yes and v-doc-rec <> ? then
reposition br-rattrs to recid v-doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-rattrs:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.

apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end procedure. /* OpenBr */

procedure proc-filter :
  assign tbl      = 'trn-rsn-attr'
         join-tbl = 'X_trn-rsn-attr'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.

  {&SetCursorWait}
  &scop common-params input '':U, input-output fld, input-output lab, input-output spr, input-output dim
  run fltfield-add in this-procedure ( input 'attr-code',  input 'Код причины',         {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'attr-value', input 'Основание (причина)', {&common-params} ) no-error.

  if num-entries( fld ) <> num-entries( lab ) or num-entries( lab ) <> integer( dim ) or
     num-entries( fld ) <> num-entries( spr ) or num-entries( spr ) <> integer( dim ) or
     num-entries( lab ) <> num-entries( spr ) or num-entries( fld ) <> integer( dim ) then do:
    {&SetCursorNo}
    message "Неверная настройка на фильтры!" view-as alert-box error.
    return no-apply.
  end.

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
  define input parameter p-next as logical   no-undo.
  define input parameter p-code as character no-undo.

  {&SetCursorWait}
  assign p-code = replace( p-code, {&double-quote}, {&double-quote} + {&double-quote} )
         p-code = replace( p-code, {&single-quote}, {&single-quote} + {&single-quote} )
         p-code = {&double-quote} + p-code + {&double-quote}.
  run OpenBr in this-procedure ( input no, input p-next, input substitute( " and X_trn-rsn-attr.attr-code = &1 ", p-code ) ).
  if v-doc-rec <> ? then do:
    if FoundRec = ? then do: assign FoundRec = v-doc-rec. end.
    if FoundRec = v-doc-rec then do: assign sch-num = 0. end.
    assign  sch-num = sch-num + 1.
    display sch-num with frame {&FRAME-NAME}.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num in frame {&FRAME-NAME}.
  end.
  apply "ENTRY":U to sch-code in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-code */

procedure proc-delete :
  define variable l_log as logical no-undo.
  define buffer buf_trn-rsn-attr for ub.trn-rsn-attr.

  do on error   undo, leave
     on end-key undo, leave :

    find first buf_trn-rsn-attr no-lock where recid( buf_trn-rsn-attr ) = v-doc-rec no-error.
    if not available buf_trn-rsn-attr then do:
      message "Запись не найдена." view-as alert-box error.
      undo, return error.
    end.


    Erase-Block:
    do on error   undo Erase-Block, leave Erase-Block
       on end-key undo Erase-Block, leave Erase-Block :
      find first buf_trn-rsn-attr exclusive-lock where recid( buf_trn-rsn-attr ) = v-doc-rec.
      delete buf_trn-rsn-attr.
    end. /* Erase-Block */

    get prev {&BROWSE-NAME} no-lock.
    if not available X_trn-rsn-attr then do: get prev {&BROWSE-NAME} no-lock. end.
    if not available X_trn-rsn-attr then do: get next {&BROWSE-NAME} no-lock. end.
    if not available X_trn-rsn-attr then do: get next {&BROWSE-NAME} no-lock. end.
    assign v-doc-rec = ( if available X_trn-rsn-attr then recid( X_trn-rsn-attr ) else ? ).

    reposition {&BROWSE-NAME} to recid v-doc-rec no-error.
    if error-status :error then do: reposition {&BROWSE-NAME} to row 1 no-error. end.
    apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
    apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  end. /* on error */
end procedure. /* proc-delete */