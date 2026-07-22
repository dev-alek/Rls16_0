/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории изменения градуировочной таблицы по резервуару на объекте

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/23/06
Author: Dmitry Ukhanov
Creation date: 01/23/06

*/

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */
&scop FRAME-NAME  fr-D-pl-level-0
&scop BROWSE-NAME br-pl-levels
&scop f-l         Int2Char,Rec2Char
&scop sch-flt     + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
&scop description 'Список истории изменения градуировочной таблицы по резервуару на объекте':U

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter parparentproc as widget-handle no-undo.
define input        parameter p-bttns       as character     no-undo.
define input        parameter p-mode        as character     no-undo. /* может быть {&all}, obj, pl, one */
define input        parameter p-obj-type    as character     no-undo.
define input        parameter p-obj-code    as integer       no-undo.
define input        parameter p-pl-code     as integer       no-undo.
define input-output parameter p-rid-list    as character     no-undo. /* статьи в выборке */

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Список истории изменения градуировочной таблицы по резервуару на объекте":U.

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/showinf.i         }
{ gbl/flt-def.i         }
{ gbl/waitfram.i        }
{ gbl/fltfield.i        }
{ gbl/std-func.i {&f-l} }
{ ref/tmpchgs.i  " " }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ gbl/fltopend.i defproc }

define buffer buf_changes  for temp-changes.
define buffer buf_c-pl-level  for ub.c-pl-level.
define buffer sch_c-pl-level for ub.c-pl-level.
define buffer buf_source   for ub.pl-level.
define buffer buf_object   for ub.clients.

define variable filter-point     as character no-undo initial {&description}.
define variable filter-point0    as character no-undo initial {&description}.
define variable sort-change-name as character no-undo.
define variable sort-column-name as character no-undo.
define variable sch-field        as character no-undo.
define variable FoundRec         as recid     no-undo.
define variable p-act-codes      as character no-undo initial {&hn-actions}.
define variable p-act-names      as character no-undo initial {&hn-actions-full}.
define variable doc-rec          as recid     no-undo.
define variable p-host-code      as integer   no-undo.

/* ************************  Function Prototypes ********************** */
function mark-string returns character ( buffer loc-buf for ub.c-pl-level ) :
  define variable v_mark-sign as character no-undo.

  run get-mark-string in this-procedure ( buffer loc-buf, output v_mark-sign ).
  return ( v_mark-sign ).
end function. /* mark-string */

function ShowAction returns character ( input i-act as integer ) :
  define variable v_act as character no-undo.

  run get-action-name in this-procedure ( input i-act, output v_act ).
  return ( v_act ).
end function. /* ShowAction */

function obj-short returns character ( input i-type as character, input i-code as integer ) :
  define variable v_obj-name as character no-undo.

  run get-obj-short-name in this-procedure ( input i-type, input i-code, output v_obj-name ).
  return ( v_obj-name ).
end function. /* obj-short */

function obj-name returns character ( input i-type as character, input i-code as integer ) :
  define variable v_obj-name as character no-undo.

  run get-obj-full-name in this-procedure ( input i-type, input i-code, output v_obj-name ).
  return ( v_obj-name ).
end function. /* obj-name */

function place-name returns character ( buffer loc-buf for ub.c-pl-level ) :
  define variable v_name as character no-undo.

  run get-place-name in this-procedure ( buffer loc-buf, output v_name ) no-error.
  return ( if error-status :error or v_name = ? then "":U else v_name ).
end function. /* place-name */

function place-loc1 returns character ( buffer loc-buf for ub.c-pl-level ) :
  define variable v_loc1 as character no-undo.

  run get-place-loc1 in this-procedure ( buffer loc-buf, output v_loc1 ) no-error.
  return ( if error-status :error or v_loc1 = ? then "":U else v_loc1 ).
end function. /* place-loc1 */

/* Definitions for BROWSE {&BROWSE-NAME}                                */
&scop label-clmn_1-br-dtl  '*'
&scop form-clmn_1-br-dtl   'x(1)':U
&scop sort-clmn_1-br-dtl   mark-string( buffer buf_c-pl-level )
&scop label-clmn_2-br-dtl  'Объект'
&scop form-clmn_2-br-dtl   "x(13)":U
&scop sort-clmn_2-br-dtl   obj-short( buf_c-pl-level.obj-type, buf_c-pl-level.obj-code )
&scop label-clmn_3-br-dtl  'Наименование объекта'
&scop form-clmn_3-br-dtl   "x(40)":U
&scop sort-clmn_3-br-dtl   obj-name(  buf_c-pl-level.obj-type, buf_c-pl-level.obj-code )
&SCOP dyn_sort-clmn_3-br-dtl  substitute('dynamic-function(&1obj-name&1, buf_c-pl-level.obj-type, buf_c-pl-level.obj-code)', ~{&double-quote~})
&scop label-clmn_4-br-dtl  'Резервуар'
&scop form-clmn_4-br-dtl   ">>>>>>>>9":U
&scop sort-clmn_4-br-dtl   buf_c-pl-level.pl-code
&scop label-clmn_5-br-dtl  'Название'
&scop form-clmn_5-br-dtl   "x(40)":U
&scop sort-clmn_5-br-dtl   place-name( buffer buf_c-pl-level )
&scop label-clmn_6-br-dtl  'Код'
&scop form-clmn_6-br-dtl   "x(8)":U
&scop sort-clmn_6-br-dtl   place-loc1( buffer buf_c-pl-level )
&scop label-clmn_7-br-dtl  'Уровень, мм'
&scop form-clmn_7-br-dtl   ">,>>>,>>9":U
&scop sort-clmn_7-br-dtl   buf_c-pl-level.pl-level
&scop label-clmn_8-br-dtl  'Объем, л'
&scop form-clmn_8-br-dtl   "->,>>>,>>9.999":U
&scop sort-clmn_8-br-dtl   buf_c-pl-level.pl-qnty
&scop label-clmn_9-br-dtl  'Изменил'
&scop form-clmn_9-br-dtl   "x(8)":U
&scop sort-clmn_9-br-dtl   buf_c-pl-level.corr-user-name
&scop label-clmn_10-br-dtl 'Дата корр.'
&scop form-clmn_10-br-dtl  "99/99/9999":U
&scop sort-clmn_10-br-dtl  buf_c-pl-level.corr-date
&scop label-clmn_11-br-dtl 'Время'
&scop form-clmn_11-br-dtl  "x(8)":U
&scop sort-clmn_11-br-dtl  STRING( buf_c-pl-level.corr-time, 'HH:MM:SS':U )
&scop label-clmn_12-br-dtl 'Щепка'
&scop form-clmn_12-br-dtl  "->,>>>,>>>,>>9":U
&scop sort-clmn_12-br-dtl  buf_c-pl-level.chip-num
&scop label-clmn_13-br-dtl 'БД'
&scop form-clmn_13-br-dtl  ">>>>9":U
&scop sort-clmn_13-br-dtl  buf_c-pl-level.corr-user-db-num
&scop enabled-clmn-br-dtl  {&sort-clmn_8-br-dtl}

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
define button   b-exit    label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-lkp   label "&Просмотр" size-chars 10.00 by 1.00 default.
define button b-sch label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-sel label "Вы&бор"    size-chars 10.00 by 1.00 default auto-go.

define variable mark-num as integer no-undo view-as fill-in size-chars  8.00 by 1.00 format "->>>,>>>":U.
define variable sch-plc  as integer no-undo view-as fill-in size-chars 10.50 by 1.00 format ">>>>>>>>>":U.
define variable sch-num  as integer no-undo view-as fill-in size-chars  5.00 by 1.00 format ">>>":U.

/* Query definitions                                                    */
define query {&BROWSE-NAME} for buf_c-pl-level scrolling.

define query br-changes for buf_changes scrolling.

/* Browse definitions                                                   */
define browse {&BROWSE-NAME} query {&BROWSE-NAME} display
  {&sort-clmn_1-br-dtl}  column-label {&label-clmn_1-br-dtl}  format {&form-clmn_1-br-dtl}
  {&sort-clmn_2-br-dtl}  column-label {&label-clmn_2-br-dtl}  format {&form-clmn_2-br-dtl}
  {&sort-clmn_3-br-dtl}  column-label {&label-clmn_3-br-dtl}  format {&form-clmn_3-br-dtl}
  {&sort-clmn_4-br-dtl}  column-label {&label-clmn_4-br-dtl}  format {&form-clmn_4-br-dtl}
  {&sort-clmn_5-br-dtl}  column-label {&label-clmn_5-br-dtl}  format {&form-clmn_5-br-dtl}
  {&sort-clmn_6-br-dtl}  column-label {&label-clmn_6-br-dtl}  format {&form-clmn_6-br-dtl}
  {&sort-clmn_7-br-dtl}  column-label {&label-clmn_7-br-dtl}  format {&form-clmn_7-br-dtl}
  {&sort-clmn_8-br-dtl}  column-label {&label-clmn_8-br-dtl}  format {&form-clmn_8-br-dtl}
  {&sort-clmn_9-br-dtl}  column-label {&label-clmn_9-br-dtl}  format {&form-clmn_9-br-dtl}
  {&sort-clmn_10-br-dtl} column-label {&label-clmn_10-br-dtl} format {&form-clmn_10-br-dtl}
  {&sort-clmn_11-br-dtl} column-label {&label-clmn_11-br-dtl} format {&form-clmn_11-br-dtl}
  {&sort-clmn_12-br-dtl} column-label {&label-clmn_12-br-dtl} format {&form-clmn_12-br-dtl}
  {&sort-clmn_13-br-dtl} column-label {&label-clmn_13-br-dtl} format {&form-clmn_13-br-dtl}
  enable
  {&enabled-clmn-br-dtl}
with no-row-markers separators size-chars 98.25 by 9.38.

define browse br-changes query br-changes display
  {&sort-clmn_1-br-chg}  column-label {&label-clmn_1-br-chg}  format {&form-clmn_1-br-chg}
  {&sort-clmn_2-br-chg}  column-label {&label-clmn_2-br-chg}  format {&form-clmn_2-br-chg}
  {&sort-clmn_3-br-chg}  column-label {&label-clmn_3-br-chg}  format {&form-clmn_3-br-chg}
  enable
  {&enabled-clmn-br-chg}
with no-row-markers separators size-chars 98.25 by 9.38.

define rectangle r-rect-0 edge-pixels  3 graphic-edge no-fill size-chars 98.25 by 1.50.
define rectangle r-rect-1 edge-pixels 18 graphic-edge no-fill size-chars 98.25 by 1.50.

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
    r-rect-0     at row  1.25 col  1.50
    b-exit     at row  1.50 col  2.50
  b-mark    at row  1.50 col 12.50
    mark-num     at row  1.50 col 15.75 no-label                              fgcolor 4
  b-sel  at row  1.50 col 24.00
  b-lkp    at row  1.50 col 44.75
  b-sch  at row  1.50 col 68.50
  b-help    at row  1.50 col 88.75
  {&BROWSE-NAME} at row  3.00 col  1.50
    r-rect-1     at row 12.50 col  1.50
  "          ":U at row 12.75 col  1.62 view-as text size-chars 98.00 by 1.00
  "ПОИСК ПО:"    at row 12.75 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
  sch-plc        at row 12.75 col 11.50    label "&Резервуару"
  sch-num        at row 12.75 col 94.25 no-label                              fgcolor 4
    br-changes   at row 14.25 col  1.50
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title {&description}
     default-button b-exit cancel-button b-exit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.
assign {&BROWSE-NAME}         :num-locked-columns in frame  {&FRAME-NAME}  = 1
       {&enabled-clmn-br-dtl} :read-only          in browse {&BROWSE-NAME} = yes
       {&enabled-clmn-br-chg} :read-only          in browse   br-changes   = yes.
assign b-mark    :tooltip in frame {&FRAME-NAME} = "Поставить/снять отметку записи"
         b-exit     :tooltip in frame {&FRAME-NAME} = "Вернуться в окно вызова"
       b-sch  :tooltip in frame {&FRAME-NAME} = "Установить/снять фильтр"
       b-help    :tooltip in frame {&FRAME-NAME} = "Интерактивная помощь в формате *.html"
       b-lkp    :tooltip in frame {&FRAME-NAME} = "Просмотреть текущую запись"
       b-sel  :tooltip in frame {&FRAME-NAME} = "Выбрать текущую(ие) запись(и)"
       {&BROWSE-NAME} :tooltip in frame {&FRAME-NAME} = "Список действий над градуировочной таблицей"
         br-changes   :tooltip in frame {&FRAME-NAME} = "Список изменений градуировочной таблицы"
         sch-plc      :tooltip in frame {&FRAME-NAME} = "Код резервуара" {&sch-flt}
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
  if available buf_c-pl-level then do:
    { gbl/markstrn.i buf_c-pl-level p-rid-list }
    {&BROWSE-NAME} :refresh( ) in frame {&FRAME-NAME}.
    if last-event :function <> "MOUSE-SELECT-DBLCLICK" then do:
      {&BROWSE-NAME} :select-next-row( ) in frame {&FRAME-NAME}.
    end.
    apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
    if num-entries( p-rid-list ) = 0 then do: hide                                mark-num   in frame {&FRAME-NAME}. end.
                                     else do: display num-entries( p-rid-list ) @ mark-num with frame {&FRAME-NAME}. end.
  END.
  apply "ENTRY":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.

on choose of b-exit in frame {&FRAME-NAME} do: /* Выход */
  run gbl/markqwa.p ( input b-mark :sensitive, input p-rid-list ) no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of b-sch in frame {&FRAME-NAME} do: /* Фильтр */
  {&SetCursorWait}
  run proc-filter in this-procedure no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on choose of b-sel in frame {&FRAME-NAME} do: /* Выбор */
  if not available buf_c-pl-level then do: return no-apply. end.
  if p-rid-list = "":U or b-mark :sensitive = no then do: assign p-rid-list = string( recid( buf_c-pl-level ) ). end.
end.

on choose of b-lkp in frame {&FRAME-NAME} do: /* Просмотр */
  define buffer buf_doc for ub.c-pl-level.

  { gbl/stdbtn.i }
  if not available buf_c-pl-level then do:
    message "Неправильно выбрана запись." view-as alert-box error.
    return no-apply.
  end.
  else do:
    assign doc-rec = recid( buf_c-pl-level ).
  end.
  find first buf_doc no-lock where
             buf_doc.obj-type  = buf_c-pl-level.obj-type and
             buf_doc.obj-code  = buf_c-pl-level.obj-code and
             buf_doc.pl-code   = buf_c-pl-level.pl-code  and
             buf_doc.chip-num <> buf_c-pl-level.chip-num and
             recid( buf_doc ) <> recid( buf_c-pl-level ) no-error.
  if not available buf_doc then do:
    message 'Данная запись истории пуста, т.к. соответствует СОЗДАНИЮ записи "ГРАДУИРОВОЧНАЯ ТАБЛИЦА ПО РЕЗЕРВУАРУ".' skip
            'Просмотр невозможен!'
    view-as alert-box.
    return no-apply.
  end.

  run str/cpl-lvla.w ( input {&lookup}, input-output doc-rec ).
  reposition {&BROWSE-NAME} to recid doc-rec no-error.
  if error-status :error then do: reposition {&BROWSE-NAME} to row 1 no-error. end.
  apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.

on return                of {&BROWSE-NAME} in frame {&FRAME-NAME} or
   mouse-select-dblclick of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  if           b-mark   :sensitive in frame {&FRAME-NAME} then do:
      apply "CHOOSE":U to b-mark   in frame {&FRAME-NAME}.
  end. else IF b-sel :sensitive in frame {&FRAME-NAME} then do:
      apply "CHOOSE":U to b-sel in frame {&FRAME-NAME}.
  end.
end.

on value-changed of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  run proc-view-changes in this-procedure no-error.
end.

on entry of sch-plc  in frame {&FRAME-NAME} do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display sch-plc with frame {&FRAME-NAME}.
end.

on leave of sch-plc  in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec  = ?
           sch-field = "":U
           sch-num   = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on CTRL-J of sch-plc  in frame {&FRAME-NAME} do: /* резервуару */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-plc  <> sch-plc  then do:
    assign sch-plc.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-plc  in this-procedure ( input yes, input sch-plc  ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on return of sch-plc  in frame {&FRAME-NAME} do: /* резервуару */
  {&SetCursorWait}
  assign sch-plc.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-plc  in this-procedure ( input no,  input sch-plc  ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on mouse-select-dblclick of sch-plc  in frame {&FRAME-NAME} do: /* резервуару */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-plc  <> sch-plc  then do:
    assign sch-plc.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-plc  in this-procedure ( input yes, input sch-plc  ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

{ gbl/hot-key.i b-help   }
{ gbl/hot-key.i b-mark   }
{ gbl/hot-key.i b-lkp   }
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
    &ext-col      = 13
    &frame-name   = {&FRAME-NAME}
    &browse-name  = {&BROWSE-NAME}
    &table-name   = "buf_c-pl-level"
    &start-column = 2              }

{ gbl/srt-clmd.i
    &ext-col              = 13
    &frame-name           = {&FRAME-NAME}
    &browse-name          = {&BROWSE-NAME}
    &table-name           = "buf_c-pl-level"
    &start-column         = 2
    &label-clmn_2         = "{&label-clmn_2-br-dtl}"
    &sort-clmn_2          = "{&sort-clmn_2-br-dtl}"
    &label-clmn_3         = "{&label-clmn_3-br-dtl}"
    &sort-clmn_3          = "{&sort-clmn_3-br-dtl}"
    &dyn_sort-clmn_3      = "{&dyn_sort-clmn_3-br-dtl}"
    &label-clmn_4         = "{&label-clmn_4-br-dtl}"
    &sort-clmn_4          = "{&sort-clmn_4-br-dtl}"
    &label-clmn_7         = "{&label-clmn_7-br-dtl}"
    &sort-clmn_7          = "{&sort-clmn_7-br-dtl}"
    &label-clmn_8         = "{&label-clmn_8-br-dtl}"
    &sort-clmn_8          = "{&sort-clmn_8-br-dtl}"
    &label-clmn_9         = "{&label-clmn_9-br-dtl}"
    &sort-clmn_9          = "{&sort-clmn_9-br-dtl}"
    &label-clmn_10        = "{&label-clmn_10-br-dtl}"
    &sort-clmn_10         = "{&sort-clmn_10-br-dtl}"
    &label-clmn_11        = "{&label-clmn_11-br-dtl}"
    &sort-clmn_11         = "{&sort-clmn_11-br-dtl}"
    &label-clmn_12        = "{&label-clmn_12-br-dtl}"
    &sort-clmn_12         = "{&sort-clmn_12-br-dtl}"
    &label-clmn_13        = "{&label-clmn_13-br-dtl}"
    &sort-clmn_13         = "{&sort-clmn_13-br-dtl}"
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
   p-host-code = v-cntxt-host-code-obj .

  if lookup( p-mode, '{&bef-all},obj,pl,one':U ) = 0 then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    return.
  end. /* p-mode */
  if p-mode = 'obj':U or
     p-mode = 'one':U then do:
    find first buf_source no-lock where
               buf_source.obj-type = p-obj-type and
               buf_source.obj-code = p-obj-code no-error.
    if not available buf_source then do:
      message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
              'Неверное значение параметров вызова: p-obj-type и p-obj-code - '
              '"' + p-obj-type + '"' p-obj-code '.'
      view-as alert-box error.
      return.
    end.
  end. /* p-mode = 'obj':U */
  if p-mode = 'pl':U  or
     p-mode = 'one':U then do:
    find first buf_source no-lock where
               buf_source.pl-code = p-pl-code no-error.
    if not available buf_source then do:
      message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
              'Неверное значение параметра вызова p-pl-code:' p-pl-code '.'
      view-as alert-box error.
      return.
    end.
  end. /* p-mode = 'pl':U */
  if p-mode = 'one':U then do:
    find first buf_source no-lock where
               buf_source.obj-type = p-obj-type and
               buf_source.obj-code = p-obj-code and
               buf_source.pl-code  = p-pl-code  no-error.
    if not available buf_source then do:
      message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
              'Неверное значение параметров вызова: p-obj-type, p-obj-code и p-pl-code - '
              '"' + p-obj-type + '"' p-obj-code 'и' p-pl-code '.'
      view-as alert-box error.
      return.
    end.
  end. /* p-mode = 'one':U */
  if p-rid-list <> "":U then do:
    find first sch_c-pl-level no-lock where recid( sch_c-pl-level ) = integer( entry( 1, p-rid-list ) ) no-error.
    if not available sch_c-pl-level then do:
      message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
              'Неверное значение параметра вызова p-rid-list: "' + p-rid-list + '".'
      view-as alert-box error.
      return error.
    end.
    else do:
      assign doc-rec = recid( sch_c-pl-level ).
    end.
  end.

  /* display sch-plc sch-num mark-num br-changes with frame {&FRAME-NAME}. */
  enable  b-mark   when lookup( "b-mark":U,   p-bttns ) > 0 or p-bttns = "*"
          b-sel when lookup( "b-sel":U, p-bttns ) > 0 or p-bttns = "*"
          b-sch b-help b-exit b-lkp {&BROWSE-NAME} br-changes sch-plc
  with frame {&FRAME-NAME}.
  {&SetCursorWait}
  run OpenBr in this-procedure ( input yes, input no, input '':U ).
  hide mark-num in frame {&FRAME-NAME}.
  hide  sch-num in frame {&FRAME-NAME}.
  if p-rid-list <> "":U then do: reposition {&BROWSE-NAME} to recid doc-rec no-error. end.
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
  define variable p-proc-hand        as handle    no-undo.
  define variable l-open-query       as logical   no-undo.

  assign title0 = "Список истории изменения" + {&space-char}.


  case sort-column-name :
    when "":U then do: assign sort-column-phrase = "":U. end.
    otherwise      do: assign sort-column-phrase = "by " + sort-column-name. end.
  end case. /* sort-column-name */


  &scop flt-open-open-query         open query {&BROWSE-NAME} for each buf_c-pl-level
  &scop flt-open-dyn_open-query     for each buf_c-pl-level
  &scop flt-open-query-handle       query {&BROWSE-NAME}:handle
  &scop flt-open-open-query-tail
  &scop flt-open-query-was-opened   l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point         filter-point
  &scop flt-open-set-filter-name    set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition
  &scop flt-open-query              p-open-query
  &scop flt-open-table-name         buf_c-pl-level
  &scop flt-open-search-option      no-lock
  &scop flt-open-find-next          p-find-next
  &scop flt-open-find-recid         doc-rec
  &scop flt-open-find-condition     p-find-condition
  &scop flt-open-find-buffer-name   buf_c-pl-level
  &scop flt-open-waitfram           yes

  assign filter-point = filter-point0 + " - " + p-mode.

  case p-mode :
    when {&all}  then do:
        assign frame {&FRAME-NAME} :title = title0 + "градуировочной таблицы".
      { gbl/fltopend.i
          &where-cond = " yes "
          &use-ind    = "  "
          &by         = "  "    }
    end. /* {&all} */
    when 'obj':U then do:
      {&SetCursorWait}
      find first buf_object no-lock where
                 buf_object.obj-type = p-obj-type and
                 buf_object.obj-code = p-obj-code no-error.
      assign frame {&FRAME-NAME} :title = title0 + substitute( 'градуировочной таблицы по объекту &1"',
                                                               trim( substring( buf_object.obj-name, 1, 40 ) ) ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_c-pl-level.obj-type = p-obj-type and ~
                          buf_c-pl-level.obj-code = p-obj-code ~
                        "
          &dyn_where-cond = " substitute(' buf_c-pl-level.obj-type = &1&2&1 and ~
                          buf_c-pl-level.obj-code = &3 ', ~{&double-quote~}, p-obj-type, p-obj-code) "

          &use-ind    = "  "
          &by         = "  "                                    }
    end. /* 'obj':U */
    when 'pl':U  then do:
        find first buf_source no-lock where
                 buf_source.pl-code = p-pl-code no-error.
      assign frame {&FRAME-NAME} :title = title0 +
        substitute( 'градуировочной таблицы по резервуару &1', buf_source.pl-code ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_c-pl-level.pl-code = p-pl-code ~
                        "
          &dyn_where-cond = " substitute(' buf_c-pl-level.pl-code = &1', p-pl-code ) "

          &use-ind    = "  "
          &by         = "  "                              }
    end. /* 'pl':U */
    when 'one':U then do:
        find first buf_object no-lock where
                 buf_object.obj-type = p-obj-type and
                 buf_object.obj-code = p-obj-code no-error.
      find first buf_source no-lock where
                 buf_source.obj-type = p-obj-type and
                 buf_source.obj-code = p-obj-code and
                 buf_source.pl-code  = p-pl-code  no-error.
      assign frame {&FRAME-NAME} :title = title0 +
        substitute( 'градуировочной таблицы по резервуару &1 на объекте "&2"',
                    buf_source.pl-code,
                    trim( substring( buf_object.obj-name, 1, 30 ) ) ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_c-pl-level.obj-type = p-obj-type and ~
                          buf_c-pl-level.obj-code = p-obj-code and ~
                          buf_c-pl-level.pl-code  = p-pl-code ~
                        "
          &dyn_where-cond = " substitute(' buf_c-pl-level.obj-type = &1&2&1 and ~
                          buf_c-pl-level.obj-code = &3 and ~
                          buf_c-pl-level.pl-code  = &4' , ~{&double-quote~}, p-obj-type, p-obj-code, p-pl-code) "

          &use-ind    = "  "
          &by         = "  "                                    }
    end. /* 'one':U */
  end case. /* p-mode */

  if p-open-query <> yes then do:
    reposition {&BROWSE-NAME} to recid doc-rec no-error.
  end.
  if not p-open-query and v-fltopend-rowid[1] <> ? then
  query {&BROWSE-NAME}:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
  apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.

end procedure. /* OpenBr */

procedure proc-filter :
  &scop  common     input-output fld, input-output lab, input-output spr, input-output dim
  &scop  object     obj-type{&delim-flt}obj-code
  &scop  hn         corr-user-
  &scop  cli        'obj-type{&delim-flt}obj-code'

  assign tbl      = 'c-pl-level'
         join-tbl = 'buf_c-pl-level'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.

  {&SetCursorWait}
  run fltfield-add in this-procedure ( input 'pl-code',     input 'Код резервуара', input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'obj-type',    input 'Тип объекта',    input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'obj-code',    input 'Код объекта',    input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input  {&cli},        input 'Объект',         input 'cli':U, {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'pl-level',    input 'Уровень, мм',    input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'pl-qnty',     input 'Объем, л',       input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'chip-num',    input 'Щепка',          input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input '{&hn}db-num', input 'БД',             input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input '{&hn}name',   input 'Имя',            input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-date',   input 'Дата корр.',     input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-time',   input 'Время',          input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'action',      input 'Действие',       input '':U,    {&common} ) no-error.

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
    run gbl/filter.w ( input parparentproc,
                   input filter-point,
                   input tbl,
                   input join-tbl,
                   input fld,
                   input lab,
                   input spr,
                   input dim            ).
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
    {&SetCursorNo}
  end. /* Filter-Block */
end procedure. /* proc-filter */

procedure proc-view-changes :
  for each temp-changes :
    delete temp-changes.
  end.
  if not available buf_c-pl-level then do:
    run OpenChanges in this-procedure .
    return.
  end.

&scop fields-name-list  "pl-code,obj-type,obj-code,pl-level,pl-qnty"
define variable v-label-param as character no-undo .

v-label-param =
  "pl-code" + {&delim-par} + "Резервуар" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "pl-level" + {&delim-par} + "Уровень мм" + {&delim-par} + "" + {&delim-flf}
 + "pl-qnty" + {&delim-par} + "Объем л" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  buffer buf_c-pl-level:handle
                                            ,input  {&table_pl-level}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

  run OpenChanges in this-procedure .
end procedure. /* proc-view-changes */

procedure OpenChanges :
open query br-changes for each buf_changes no-lock.
end procedure. /* OpenChanges */

{ gbl/setfltnm.i }

procedure proc-find-plc :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer no-undo.

  {&SetCursorWait}
  run OpenBr in this-procedure ( input no, input p-next, input substitute( " and buf_c-pl-level.pl-code = &1 ", p-code ) ).
  if doc-rec <> ? then do:
    if FoundRec = ? then do: assign FoundRec = doc-rec. end.
    if FoundRec = doc-rec then do: assign sch-num = 0. end.
    assign  sch-num = sch-num + 1.
    display sch-num with frame {&FRAME-NAME}.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num in frame {&FRAME-NAME}.
  end.
  apply "ENTRY":U to sch-plc in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-plc */

procedure get-mark-string :
  define        parameter buffer loc-buf for ub.c-pl-level.
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

procedure get-obj-short-name :
  define  input parameter p-type as character no-undo.
  define  input parameter p-code as integer   no-undo.
  define output parameter p-name as character no-undo.

  assign p-name = ( if p-type = ? or p-code = ? then "":U else ( p-type + " ":U + Int2Char( p-code ) ) ).
end procedure. /* get-obj-short-name */

procedure get-obj-full-name :
  define  input parameter p-type as character no-undo.
  define  input parameter p-code as integer   no-undo.
  define output parameter p-name as character no-undo.

  define buffer buf_clients for ub.clients.

  find buf_clients no-lock where
       buf_clients.obj-type = p-type and
       buf_clients.obj-code = p-code no-error.
  if available buf_clients then do:
    assign p-name = buf_clients.obj-name.
  end.
  else do:
    assign p-name = ( if p-type = ? or p-code = ? then "":U else ( p-type + " ":U + Int2Char( p-code ) ) ).
  end.
end procedure. /* get-obj-full-name */

procedure get-place-name :
  define        parameter buffer buf_loc for ub.c-pl-level.
  define output parameter        p-name  as  character no-undo.

  define buffer buf_place for ub.place.

  find first buf_place no-lock where
             buf_place.obj-type = buf_loc.obj-type and
             buf_place.obj-code = buf_loc.obj-code and
             buf_place.pl-code  = buf_loc.pl-code  no-error.
  assign p-name = ( if available buf_place then buf_place.pl-name else "":U ).
end procedure. /* get-place-name */

procedure get-place-loc1 :
  define        parameter buffer buf_loc for ub.c-pl-level.
  define output parameter        p-loc1  as  character no-undo.

  define buffer buf_place for ub.place.

  find first buf_place no-lock where
             buf_place.obj-type = buf_loc.obj-type and
             buf_place.obj-code = buf_loc.obj-code and
             buf_place.pl-code  = buf_loc.pl-code  no-error.
  assign p-loc1 = ( if available buf_place then buf_place.loc1 else "":U ).
end procedure. /* get-place-loc1 */