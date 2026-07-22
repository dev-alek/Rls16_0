/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История оснований (причин) создания документа

Автор: Чернова Светлана Александровна
Дата создания: 11/30/06
Author: Svetlana Chernova
Creation date: 11/30/06

create: Булгаков Андрей Николаевич

*/

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */
&scop FRAME-NAME  fr-D-reason-0
&scop BROWSE-NAME br-reasons
&scop f-l         Int2Char,Rec2Char
&scop sch-flt     + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
&scop description 'История оснований (причин) создания документа':U

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter parParentProc as widget-handle no-undo.
define input        parameter p-bttns       as character     no-undo.
define input        parameter p-mode        as character     no-undo. /* может быть {&all}, one */
define input        parameter p-reason-code as integer       no-undo.
define input-output parameter p-rid-list    as character     no-undo. /* статьи в выборке */

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "История оснований (причин) создания документа":U.

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i        }
{ cmp/showinf.i         }
{ gbl/flt-def.i         }
{ gbl/waitfram.i        }
{ gbl/fltfield.i        }
{ gbl/std-func.i {&f-l} }
{ gbl/usrfulnf.i        }
{ ref/tmpchgs.i   " " " " "with-action"      }
{ gbl/fltopend.i defproc }

define buffer buf_changes  for temp-changes.
define buffer buf_c-trn-reason  for ub.c-trn-reason.
define buffer sch_c-trn-reason for ub.c-trn-reason.
define buffer buf_trn-reason   for ub.trn-reason.

define variable filter-point     as character no-undo initial {&table_c-trn-reason}.
define variable filter-point0    as character no-undo initial {&table_c-trn-reason}.
define variable filter-label     as character no-undo initial {&description}.
define variable filter-label0    as character no-undo initial {&description}.
define variable sort-change-name as character no-undo.
define variable sort-column-name as character no-undo.
define variable sch-field        as character no-undo.
define variable FoundRec         as recid     no-undo.
define variable p-act-codes      as character no-undo initial {&hn-actions}.
define variable p-act-names      as character no-undo initial {&hn-actions-full}.
define variable v-doc-rec          as recid     no-undo.

/* ************************  Function Prototypes ********************** */
function mark-string returns character ( buffer loc-buf for ub.c-trn-reason ) :
  define variable v_mark-sign as character no-undo.

  run get-mark-string in this-procedure ( buffer loc-buf, output v_mark-sign ).
  return ( v_mark-sign ).
end function. /* mark-string */

function ShowAction returns character ( input i-act as integer ) :
  define variable v_act as character no-undo.

  run get-action-name in this-procedure ( input i-act, output v_act ).
  return ( v_act ).
end function. /* ShowAction */

function attr-sign returns character ( input i-code as integer ) :
  define variable v_sign as character no-undo.

  run get-attr-sign in this-procedure ( input i-code, output v_sign ).
  return ( v_sign ).
end function. /* attr-sign */

/* Definitions for BROWSE {&BROWSE-NAME}                                */
&scop label-clmn_1-br-tr  '*'
&scop form-clmn_1-br-tr   'x(1)':U
&scop sort-clmn_1-br-tr   mark-string( buffer buf_c-trn-reason )
&scop label-clmn_2-br-tr  'Код основания'
&scop form-clmn_2-br-tr   "->,>>>,>>>,>>9":U
&scop sort-clmn_2-br-tr   buf_c-trn-reason.reason-code
&scop label-clmn_3-br-tr  'Основание (причина) создания документа'
&scop form-clmn_3-br-tr   "x(78)":U
&scop sort-clmn_3-br-tr   buf_c-trn-reason.reason-name
&scop label-clmn_4-br-tr 'А'
&scop form-clmn_4-br-tr  "x(1)":U
&scop sort-clmn_4-br-tr  attr-sign( buf_c-trn-reason.reason-code )
&scop dyn_sort-clmn_4-br-tr  substitute('dynamic-function(&1attr-sign&1, buf_c-trn-reason.reason-code)', ~{&double-quote~})
&scop label-clmn_5-br-tr  'Примечание'
&scop form-clmn_5-br-tr   "x(95)":U
&scop sort-clmn_5-br-tr   buf_c-trn-reason.PS
&scop label-clmn_6-br-tr  'Изменил'
&scop form-clmn_6-br-tr   "x(8)":U
&scop sort-clmn_6-br-tr   usrfulnf(buf_c-trn-reason.corr-user-name)
&scop dyn_sort-clmn_6-br-tr   substitute('dynamic-function(&1usrfulnf&1, buf_c-trn-reason.corr-user-name)', ~{&double-quote~})
&scop label-clmn_7-br-tr  'Действие'
&scop form-clmn_7-br-tr   "x(10)":U
&scop sort-clmn_7-br-tr   ShowAction( buf_c-trn-reason.action )
&scop dyn_sort-clmn_7-br-tr   substitute('dynamic-function(&1ShowAction&1, buf_c-trn-reason.action)', ~{&double-quote~})
&scop label-clmn_8-br-tr  'Дата корр.'
&scop form-clmn_8-br-tr   "99/99/9999":U
&scop sort-clmn_8-br-tr   buf_c-trn-reason.corr-date
&scop label-clmn_9-br-tr  'Время'
&scop form-clmn_9-br-tr   "x(8)":U
&scop sort-clmn_9-br-tr   STRING( buf_c-trn-reason.corr-time, 'HH:MM:SS':U )
&scop label-clmn_10-br-tr 'Щепка'
&scop form-clmn_10-br-tr  "->,>>>,>>>,>>9":U
&scop sort-clmn_10-br-tr  buf_c-trn-reason.chip-num
&scop label-clmn_11-br-tr 'БД'
&scop form-clmn_11-br-tr  ">>>>9":U
&scop sort-clmn_11-br-tr  buf_c-trn-reason.corr-user-db-num
&scop enabled-clmn-br-tr  {&sort-clmn_5-br-tr}

&scop label-clmn_1-br-chg 'Изменилось'
&scop form-clmn_1-br-chg  'x(15)':U
&scop sort-clmn_1-br-chg  buf_changes.l_name
&scop label-clmn_2-br-chg 'Было'
&scop form-clmn_2-br-chg  'x(48)':U
&scop sort-clmn_2-br-chg  buf_changes.v_old
&scop label-clmn_3-br-chg 'Стало'
&scop form-clmn_3-br-chg  'x(48)':U
&scop sort-clmn_3-br-chg  buf_changes.v_new
&scop enabled-clmn-br-chg {&sort-clmn_1-br-chg}

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
define button b-help   label "Помо&щь"   size-chars 10.00 by 1.00 default.
define button b-mark   label "&*"        size-chars  3.00 by 1.00 default.
define button b-quit   label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-sch    label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-sel    label "Вы&бор"    size-chars 10.00 by 1.00 default auto-go.
define button b-Attr   label "&Атрибуты" size-chars 10.00 by 1.00 default.

define variable mark-num as integer   no-undo view-as fill-in size-chars  8.00 by 1.00 format "->>>,>>>":U.
define variable sch-code as integer   no-undo view-as fill-in size-chars 15.50 by 1.00 format "->,>>>,>>>,>>>":U.
define variable sch-name as character no-undo view-as fill-in size-chars 45.50 by 1.00 format "x(60)":U.
define variable sch-num  as integer   no-undo view-as fill-in size-chars  4.50 by 1.00 format ">>>":U.

/* Query definitions                                                    */
define query {&BROWSE-NAME} for buf_c-trn-reason scrolling.

define query br-changes for buf_changes scrolling.

/* Browse definitions                                                   */
define browse {&BROWSE-NAME} query {&BROWSE-NAME} display
  {&sort-clmn_1-br-tr}  column-label {&label-clmn_1-br-tr}  format {&form-clmn_1-br-tr}
  {&sort-clmn_2-br-tr}  column-label {&label-clmn_2-br-tr}  format {&form-clmn_2-br-tr}
  {&sort-clmn_3-br-tr}  column-label {&label-clmn_3-br-tr}  format {&form-clmn_3-br-tr}
  {&sort-clmn_4-br-tr}  column-label {&label-clmn_4-br-tr}  format {&form-clmn_4-br-tr}
  {&sort-clmn_5-br-tr}  column-label {&label-clmn_5-br-tr}  format {&form-clmn_5-br-tr}
  {&sort-clmn_6-br-tr}  column-label {&label-clmn_6-br-tr}  format {&form-clmn_6-br-tr}
  {&sort-clmn_7-br-tr}  column-label {&label-clmn_7-br-tr}  format {&form-clmn_7-br-tr}
  {&sort-clmn_8-br-tr}  column-label {&label-clmn_8-br-tr}  format {&form-clmn_8-br-tr}
  {&sort-clmn_9-br-tr}  column-label {&label-clmn_9-br-tr}  format {&form-clmn_9-br-tr}
  {&sort-clmn_10-br-tr} column-label {&label-clmn_10-br-tr} format {&form-clmn_10-br-tr}
  {&sort-clmn_11-br-tr} column-label {&label-clmn_11-br-tr} format {&form-clmn_11-br-tr}
  usrfulnf ( buf_c-trn-reason.corr-user-name ) column-label "Кто изменил!ФИО" format "x(15)"
  enable
  {&enabled-clmn-br-tr}
with no-row-markers separators size-chars 98.25 by 13.13.

define browse br-changes query br-changes display
  {&sort-clmn_1-br-chg}  column-label {&label-clmn_1-br-chg}  format {&form-clmn_1-br-chg}
  {&sort-clmn_2-br-chg}  column-label {&label-clmn_2-br-chg}  format {&form-clmn_2-br-chg}
  {&sort-clmn_3-br-chg}  column-label {&label-clmn_3-br-chg}  format {&form-clmn_3-br-chg}
  enable
  {&enabled-clmn-br-chg}
with no-row-markers separators size-chars 98.25 by 4.75.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
b-quit       at row  1 col 1
b-mark       at row  1 col 11
mark-num     at row  1 col 21 no-label                              fgcolor 4
b-sel        at row  1 col 31
b-Attr       at row  1 col 41
b-sch        at row  1 col 51
b-help       at row  1 col 91
  {&BROWSE-NAME} at row  3.00 col  1.50
  "          ":U at row 16.50 col  1.62 view-as text size-chars 98.00 by 1.00
  "ПОИСК ПО:"    at row 16.50 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
  sch-code       at row 16.50 col 11.50    label "&Коду"
  sch-name       at row 16.50 col 36.00    label "П&ричине"
  sch-num        at row 16.50 col 94.75 no-label                              fgcolor 4
    br-changes   at row 18.00 col  1.50
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title {&description}
     default-button b-quit cancel-button b-quit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.
assign {&BROWSE-NAME}         :num-locked-columns in frame  {&FRAME-NAME}  = 1
       {&enabled-clmn-br-tr} :read-only          in browse {&BROWSE-NAME} = yes
       {&enabled-clmn-br-chg} :read-only          in browse   br-changes   = yes.
assign b-mark    :tooltip in frame {&FRAME-NAME} = "Поставить/снять отметку записи"
         b-quit     :tooltip in frame {&FRAME-NAME} = "Вернуться в окно вызова"
       b-sch  :tooltip in frame {&FRAME-NAME} = "Установить/снять фильтр"
       b-help    :tooltip in frame {&FRAME-NAME} = "Интерактивная помощь в формате *.html"
       b-sel  :tooltip in frame {&FRAME-NAME} = "Выбрать текущую(ие) запись(и)"
         b-Attr     :tooltip in frame {&FRAME-NAME} = "История атрибутов основания (причины)"
       {&BROWSE-NAME} :tooltip in frame {&FRAME-NAME} = "Список действий над причинами"
         br-changes   :tooltip in frame {&FRAME-NAME} = "Список изменений причины"
         sch-code     :tooltip in frame {&FRAME-NAME} = "Код основания (причины)" {&sch-flt}
         sch-name     :tooltip in frame {&FRAME-NAME} = "Основание (причина) создания документа" {&sch-flt}
         sch-num      :tooltip in frame {&FRAME-NAME} = "Количество найденных записей"
         mark-num     :tooltip in frame {&FRAME-NAME} = "Отмеченные записи".

/* ************************  Control Triggers  ************************ */
on delete-character of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  if b-mark :sensitive in frame {&FRAME-NAME} then do: apply "CHOOSE":U to b-mark in frame {&FRAME-NAME}. end.
end.

on insert-mode of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  if           b-mark   :sensitive in frame {&FRAME-NAME} then do:
    apply "CHOOSE":U to b-mark     in frame {&FRAME-NAME}.
  end. else if b-sel :sensitive in frame {&FRAME-NAME} then do:
    apply "CHOOSE":U to b-sel   in frame {&FRAME-NAME}.
  end.
end.

on choose of b-mark in frame {&FRAME-NAME} do: /* * */
  if available buf_c-trn-reason then do:
    { gbl/markstrn.i buf_c-trn-reason p-rid-list }
    {&BROWSE-NAME} :refresh( ) in frame {&FRAME-NAME}.
    if last-event :function <> "MOUSE-SELECT-DBLCLICK" then do:
      {&BROWSE-NAME} :select-next-row( ) in frame {&FRAME-NAME}.
    end.
    apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
    if num-entries( p-rid-list ) = 0 then do:
       hide
       mark-num   in frame {&FRAME-NAME}.
    end.
    else do:
      display
      num-entries( p-rid-list ) @ mark-num
      with frame {&FRAME-NAME}.
    end.
  END.
  apply "ENTRY":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.

on choose of b-quit in frame {&FRAME-NAME} do: /* Выход */
  run gbl/markqwa.p ( input b-mark :sensitive, input p-rid-list ) no-error.
  if error-status :error then do:
    return no-apply.
  end.
end.

on choose of b-sch in frame {&FRAME-NAME} do: /* Фильтр */
  {&SetCursorWait}
  run proc-filter in this-procedure no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on choose of b-sel in frame {&FRAME-NAME} do: /* Выбор */
  if not available buf_c-trn-reason then do:
    return no-apply.
  end.
  if p-rid-list = "":U or b-mark :sensitive = no then do:
    assign p-rid-list = string( recid( buf_c-trn-reason ) ).
  end.
end.

on choose of b-Attr in frame {&FRAME-NAME} do: /* Атрибуты */
  define variable v-list as character no-undo.

  { gbl/stdbtn.i }
  run str/trscatrs.w
    ( input        parParentProc,
      input        "":U,
      input        "code",
      input        buf_c-trn-reason.reason-code,
      input        "":U,
      input        buf_c-trn-reason.chip-num,
      input-output v-list                   ).
end.

on return                of {&BROWSE-NAME} in frame {&FRAME-NAME} or
   mouse-select-dblclick of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  if           b-mark   :sensitive in frame {&FRAME-NAME} then do:
      apply "CHOOSE":U to b-mark   in frame {&FRAME-NAME}.
  end.
  else IF b-sel :sensitive in frame {&FRAME-NAME} then do:
      apply "CHOOSE":U to b-sel in frame {&FRAME-NAME}.
  end.
end.

on value-changed of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  run proc-view-changes in this-procedure no-error.
end.

on entry of sch-code in frame {&FRAME-NAME} do:
  assign sch-name :screen-value in frame {&FRAME-NAME} = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display
  sch-code
  with frame {&FRAME-NAME}.
end.

on entry of sch-name in frame {&FRAME-NAME} do:
  assign sch-code :screen-value in frame {&FRAME-NAME} = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display
  sch-name
  with frame {&FRAME-NAME}.
end.

on leave of sch-code in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide
  sch-num
  in frame {&FRAME-NAME}.
end.

on leave of sch-name in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide
  sch-num
  in frame {&FRAME-NAME}.
end.

on CTRL-J of sch-code in frame {&FRAME-NAME} do: /* код */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-code <> sch-code then do:
    assign sch-code.
    assign FoundRec = ?
           sch-num  = 0.
    hide
    sch-num
    in frame {&FRAME-NAME}.
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
  hide
  sch-num
  in frame {&FRAME-NAME}.
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
    hide
    sch-num
    in frame {&FRAME-NAME}.
  end.
  run proc-find-code in this-procedure ( input yes, input sch-code ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on CTRL-J of sch-name in frame {&FRAME-NAME} do: /* название */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-name <> sch-name then do:
    assign sch-name.
    assign FoundRec = ?
           sch-num  = 0.
    hide
    sch-num
    in frame {&FRAME-NAME}.
  end.
  run proc-find-name in this-procedure ( input yes, input sch-name ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on return of sch-name in frame {&FRAME-NAME} do: /* название */
  {&SetCursorWait}
  assign sch-name.
  assign FoundRec = ?
         sch-num  = 0.
  hide
  sch-num
  in frame {&FRAME-NAME}.
  run proc-find-name in this-procedure ( input no,  input sch-name ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on mouse-select-dblclick of sch-name in frame {&FRAME-NAME} do: /* название */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-name <> sch-name then do:
    assign sch-name.
    assign FoundRec = ?
           sch-num  = 0.
    hide
    sch-num
    in frame {&FRAME-NAME}.
  end.
  run proc-find-name in this-procedure ( input yes, input sch-name ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

{ gbl/hot-key.i b-help   }
{ gbl/hot-key.i b-mark   }
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
    &ext-col      = 11
    &frame-name   = {&FRAME-NAME}
    &browse-name  = {&BROWSE-NAME}
    &table-name   = "buf_c-trn-reason"
    &start-column = 2              }

{ gbl/srt-clmd.i
    &ext-col              = 11
    &frame-name           = {&FRAME-NAME}
    &browse-name          = {&BROWSE-NAME}
    &table-name           = "buf_c-trn-reason"
    &start-column         = 2
    &label-clmn_2         = "{&label-clmn_2-br-tr}"
    &sort-clmn_2          = "{&sort-clmn_2-br-tr}"
    &label-clmn_3         = "{&label-clmn_3-br-tr}"
    &sort-clmn_3          = "{&sort-clmn_3-br-tr}"
    &label-clmn_4         = "{&label-clmn_4-br-tr}"
    &sort-clmn_4          = "{&sort-clmn_4-br-tr}"
    &dyn_sort-clmn_4      = "{&dyn_sort-clmn_4-br-tr}"
    &label-clmn_5         = "{&label-clmn_5-br-tr}"
    &sort-clmn_5          = "{&sort-clmn_5-br-tr}"
    &label-clmn_6         = "{&label-clmn_6-br-tr}"
    &sort-clmn_6          = "{&sort-clmn_6-br-tr}"
    &dyn_sort-clmn_6      = "{&dyn_sort-clmn_6-br-tr}"
    &label-clmn_7         = "{&label-clmn_7-br-tr}"
    &sort-clmn_7          = "{&sort-clmn_7-br-tr}"
    &dyn_sort-clmn_7      = "{&dyn_sort-clmn_7-br-tr}"
    &label-clmn_8         = "{&label-clmn_8-br-tr}"
    &sort-clmn_8          = "{&sort-clmn_8-br-tr}"
    &label-clmn_9         = "{&label-clmn_9-br-tr}"
    &sort-clmn_9          = "{&sort-clmn_9-br-tr}"
    &label-clmn_10        = "{&label-clmn_10-br-tr}"
    &sort-clmn_10         = "{&sort-clmn_10-br-tr}"
    &label-clmn_11        = "{&label-clmn_11-br-tr}"
    &sort-clmn_11         = "{&sort-clmn_11-br-tr}"
    &open-query           = "run OpenBr in this-procedure ( input yes, input no, input '':U )."
    &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U )."
    &sort-column-name     = "sort-column-name"
    &re-move-clmn         = "no"
    &mv-brw-default       = "yes"                                                               }

{ gbl/mv-clmn.i
    &ext-col      = 3
    &frame-name   = {&FRAME-NAME}
    &browse-name  = br-changes
    &table-name   = "buf_changes"
    &start-column = 1              }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  if lookup( p-mode, '{&bef-all},one':U ) = 0 then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    return.
  end. /* p-mode */
  if p-mode = 'one':U then do:
    find first sch_c-trn-reason no-lock where
               sch_c-trn-reason.reason-code = p-reason-code no-error.
    if not available sch_c-trn-reason then do:

    end.
  end. /* p-mode = 'one':U */
  if p-rid-list <> "":U then do:
    find first sch_c-trn-reason no-lock where
        recid( sch_c-trn-reason ) = integer( entry( 1, p-rid-list ) ) no-error.
    if not available sch_c-trn-reason then do:

    end.
    else do:
      assign v-doc-rec = recid( sch_c-trn-reason ).
    end.
  end.

  enable  b-mark   when lookup( "b-mark":U,   p-bttns ) > 0 or p-bttns = "*"
          b-sel when lookup( "b-sel":U, p-bttns ) > 0 or p-bttns = "*"
          b-sch b-help b-quit  b-Attr {&BROWSE-NAME} br-changes sch-code sch-name
  with frame {&FRAME-NAME}.

  if not can-find (first ub.c-trn-rsn-attr where
                         ub.c-trn-rsn-attr.reason-code  =  buf_c-trn-reason.reason-code no-lock )
      then disable b-attr with frame {&frame-name} .

  {&SetCursorWait}
  run OpenBr in this-procedure ( input yes, input no, input '':U ).
  hide
  mark-num
  in frame {&FRAME-NAME}.
  hide
  sch-num
  in frame {&FRAME-NAME}.
  if p-rid-list <> "":U then do:
    reposition {&BROWSE-NAME} to recid v-doc-rec no-error.
  end.
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
define variable title0             as character no-undo.
define variable sort-column-phrase as character no-undo.
define variable l-open-query       as logical   no-undo.


case sort-column-name :
  when "":U then do:
    assign sort-column-phrase = "":U.
  end.
  otherwise      do:
    assign sort-column-phrase = "by " + sort-column-name.
  end.
end case. /* sort-column-name */

&scop flt-open-open-query         open query {&BROWSE-NAME} for each buf_c-trn-reason
&scop flt-open-dyn_open-query     for each buf_c-trn-reason
&scop flt-open-query-handle       query {&BROWSE-NAME}:handle
&scop flt-open-open-query-tail
&scop flt-open-query-was-opened   l-query-was-opened
&scop flt-open-sort-column-phrase sort-column-phrase
&scop flt-open-call-point         filter-point
&scop flt-open-set-filter-name    set-filter-name
&scop flt-open-indexed-reposition indexed-reposition
&scop flt-open-query              p-open-query
&scop flt-open-table-name         buf_c-trn-reason
&scop flt-open-search-option      no-lock
&scop flt-open-find-next          p-find-next
&scop flt-open-find-recid         v-doc-rec
&scop flt-open-find-condition     p-find-condition
&scop flt-open-find-buffer-def    buf_c-trn-reason
&scop flt-open-waitfram           yes

assign
filter-point = substitute('&1 - &2', filter-point0,  p-mode)
filter-label = substitute('&1 - &2', filter-label0,  p-mode)
.

case p-mode :
  when {&all}  then do:
    assign
    frame {&FRAME-NAME} :title = "История оснований (причин) создания документа".
    { gbl/fltopend.i
        &where-cond = " yes "
        &use-ind    = "  "
        &by         = "  "  }
  end. /* {&all} */
  when 'one':U then do:
    find first buf_trn-reason no-lock where
                buf_trn-reason.reason-code = p-reason-code no-error.
    assign frame {&FRAME-NAME} :title =
      substitute( 'История основания (причины) "&1" создания документа',
                  ( if available buf_trn-reason then buf_trn-reason.reason-name else Int2Char( p-reason-code ) ) ).
    { gbl/fltopend.i
        &where-cond = " buf_c-trn-reason.reason-code = p-reason-code  "
        &dyn_where-cond = " substitute('buf_c-trn-reason.reason-code = &1', p-reason-code ) "
        &use-ind    = "  "
        &by         = "  "                                      }
  end. /* 'one':U */
end case. /* p-mode */
if p-open-query <> yes and v-doc-rec <> ? then
reposition {&BROWSE-NAME} to recid v-doc-rec no-error.
apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end procedure. /* OpenBr */

procedure proc-filter :
  &scop common-params input '':U, input-output fld, input-output lab, input-output spr, input-output dim
  assign tbl      = 'c-trn-reason'
         join-tbl = 'buf_c-trn-reason'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.

  {&SetCursorWait}
  run fltfield-add in this-procedure ( input 'reason-code', input 'Код причины',         {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'reason-name', input 'Основание (причина)', {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'PS',          input 'Примечание',          {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'chip-num',    input 'Щепка',               {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-db-num', input 'Номер БД',            {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-name',   input 'Имя',                 {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-date',   input 'Дата коррекции',      {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-time',   input 'Время в секундах',    {&common-params} ) no-error.
  run fltfield-add in this-procedure ( input 'action',      input 'Описание действия',   {&common-params} ) no-error.

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
    assign mark-num = 0
           sch-num  = 0.
    hide   mark-num in frame {&FRAME-NAME}.
    hide   sch-num  in frame {&FRAME-NAME}.
    {&SetCursorWait}
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
    assign b-sch :tooltip in frame {&FRAME-NAME} = "Установить/снять фильтр".
    {&SetCursorNo}
  end. /* Filter-Block */
end procedure. /* proc-filter */

procedure proc-view-changes :
for each temp-changes :
  delete temp-changes.
end.
if not available buf_c-trn-reason then do:
  run OpenChanges in this-procedure .
  return.
end.

&scop fields-name-list "host-code,ext-doc-type,hold-doc,reason-code"
define variable v-label-param as character no-undo .

v-label-param =
   "reason-code" + {&delim-par} + "Код причины" + {&delim-par} + "" + {&delim-flf}
 + "reason-name" + {&delim-par} + "Основание" + {&delim-par} + "" + {&delim-flf}
 + "PS" + {&delim-par} + "Примечание" + {&delim-par}.
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-trn-reason.action = integer({&hn-create}))
                                            ,input  (buf_c-trn-reason.action = integer({&hn-delete}))
                                            ,input  buffer  buf_c-trn-reason:handle
                                            ,input  {&table_c-trn-reason}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


run OpenChanges in this-procedure .

end procedure. /* proc-view-changes */

procedure OpenChanges :
open query br-changes for each buf_changes.
end procedure. /* OpenChanges */

{ gbl/setfltnm.i }


procedure get-mark-string :
  define        parameter buffer loc-buf for ub.c-trn-reason.
  define output parameter        p-sign  as  character no-undo.

  assign p-sign = ( if lookup( Rec2Char( recid( loc-buf ) ), p-rid-list ) > 0 then chr( 42 ) else chr( 32 ) ).
end procedure. /* get-mark-string */

procedure get-action-name :
  define  input parameter p-code as integer   no-undo.
  define output parameter p-name as character no-undo.

  define variable v_code  as character no-undo.
  define variable j_entry as integer   no-undo.

  if p-code = ? or p-code = 0 then do: assign p-name = "":U. end.
  assign v_code  = Int2Char( p-code ).
  assign j_entry = lookup(   v_code, p-act-codes ).
  assign p-name  = ( if j_entry = 0 then "":U else entry( j_entry, p-act-names ) ).
end procedure. /* get-action-name */

procedure get-attr-sign :
  define  input parameter p-code as integer   no-undo.
  define output parameter p-attr as character no-undo.

  define buffer buf_attr for ub.c-trn-rsn-attr.

  do on error   undo, leave
     on end-key undo, leave :
    find first buf_attr no-lock where
               buf_attr.reason-code = p-code no-error.
    assign p-attr = ( if available buf_attr then "+":U else " ":U ).
  end. /* on error */
end procedure. /* get-attr-sign */

procedure proc-find-code :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer no-undo.

  {&SetCursorWait}
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_c-trn-reason.reason-code = &1 ", p-code ) ).
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

procedure proc-find-name :
  define input parameter p-next as logical   no-undo.
  define input parameter p-name as character no-undo.

  {&SetCursorWait}
  assign p-name = replace( p-name, {&double-quote}, {&double-quote} + {&double-quote} )
         p-name = replace( p-name, {&single-quote}, {&single-quote} + {&single-quote} )
         p-name = {&double-quote} + p-name + {&double-quote}.
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_c-trn-reason.reason-name begins &1 ", p-name ) ).
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
  apply "ENTRY":U to sch-name in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-code */