/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История оснований (причин) создания документа по объекту

Автор: Чернова Светлана Александровна
Дата создания: 11/30/06
Author: Svetlana Chernova
Creation date: 11/30/06

create: Булгаков Андрей Николаевич

*/

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */
&scop FRAME-NAME  fr-D-rsn-obj-0
&scop BROWSE-NAME br-rsn-objs
&scop f-l         Int2Char,Rec2Char
&scop sch-flt     + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
&scop description 'История оснований (причин) создания документа по объекту':U
&scop n-s         "NEW SHARED"

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter parParentProc  as widget-handle no-undo.
define input        parameter p-bttns        as character     no-undo.
define input        parameter p-mode         as character     no-undo. /* может быть {&all}, obj, one */
define input        parameter p-obj-type     as character     no-undo.
define input        parameter p-obj-code     as integer       no-undo.
define input        parameter p-ext-doc-type as character     no-undo.
define input        parameter p-hold-doc     as logical       no-undo.
define input-output parameter p-rid-list     as character     no-undo. /* статьи в выборке */

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "История оснований (причин) создания документа по объекту":U.

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i }
{ cmp/showinf.i         }
{ gbl/flt-def.i         }
{ gbl/waitfram.i        }
{ gbl/fltfield.i        }
{ gbl/std-func.i {&f-l} }
{ ref/tmpchgs.i   " " " " "with-action"   }
{ gbl/fltopend.i defproc }
{ gbl/usrfulnf.i }

define buffer buf_changes  for temp-changes.
define buffer buf_c-trn-reason-obj  for ub.c-trn-reason-obj.
define buffer sch_c-trn-reason-obj for ub.c-trn-reason-obj.

define variable filter-point     as character no-undo initial {&table_c-trn-reason-obj}.
define variable filter-point0    as character no-undo initial {&table_c-trn-reason-obj}.
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
function mark-string returns character ( buffer loc-buf for ub.c-trn-reason-obj ) :
  define variable v_mark-sign as character no-undo.

  run get-mark-string in this-procedure ( buffer loc-buf, output v_mark-sign ).
  return ( v_mark-sign ).
end function. /* mark-string */

function ShowAction returns character ( input i-act as integer ) :
  define variable v_act as character no-undo.

  run get-action-name in this-procedure ( input i-act, output v_act ).
  return ( v_act ).
end function. /* ShowAction */

function obj-name returns character ( buffer loc-buf for ub.c-trn-reason-obj ) :
  define variable v_obj-name as character no-undo.

  run get-obj-name in this-procedure ( buffer loc-buf, input "name", output v_obj-name ).
  return ( v_obj-name ).
end function. /* obj-name */

function obj-short returns character ( buffer loc-buf for ub.c-trn-reason-obj ) :
  define variable v_obj-name as character no-undo.

  run get-obj-name in this-procedure ( buffer loc-buf, input "code", output v_obj-name ).
  return ( v_obj-name ).
end function. /* obj-short */

function ext-name returns character ( input i-code as character ) :
  define variable v_ext-name as character no-undo.

  run get-ext-name in this-procedure ( input i-code, output v_ext-name ).
  return ( v_ext-name ).
end function. /* ext-name */

/* Definitions for BROWSE {&BROWSE-NAME}                                */
&scop label-clmn_1-trobj  '*'
&scop form-clmn_1-trobj   'x(1)':U
&scop sort-clmn_1-trobj   mark-string( buffer buf_c-trn-reason-obj )
&scop label-clmn_2-trobj  'Объект'
&scop form-clmn_2-trobj   "x(13)":U
&scop sort-clmn_2-trobj   obj-short( buffer buf_c-trn-reason-obj )
&scop label-clmn_3-trobj  'ТД'
&scop form-clmn_3-trobj   "x(2)":U
&scop sort-clmn_3-trobj   buf_c-trn-reason-obj.ext-doc-type
&scop label-clmn_4-trobj  'М'
&scop form-clmn_4-trobj   "+/ ":U
&scop sort-clmn_4-trobj   buf_c-trn-reason-obj.hold-doc
&scop label-clmn_5-trobj  'Код основания'
&scop form-clmn_5-trobj   "->,>>>,>>>,>>9":U
&scop sort-clmn_5-trobj   buf_c-trn-reason-obj.reason-code
&scop label-clmn_6-trobj  'Наименование объекта'
&scop form-clmn_6-trobj   "x(62)":U
&scop sort-clmn_6-trobj   obj-name( buffer buf_c-trn-reason-obj )
&scop label-clmn_7-trobj  'Расширенный тип документа'
&scop form-clmn_7-trobj   "x(39)":U
&scop sort-clmn_7-trobj   ext-name( buf_c-trn-reason-obj.ext-doc-type )
&scop dyn_sort-clmn_7-trobj  substitute('dynamic-function(&1ext-name&1, buf_c-trn-reason-obj.ext-doc-type)', ~{&double-quote~})
&scop label-clmn_8-trobj  'Изменил'
&scop form-clmn_8-trobj   "x(8)":U
&scop sort-clmn_8-trobj   usrfulnf(buf_c-trn-reason-obj.corr-user-name)
&scop dyn_sort-clmn_8-trobj   substitute('dynamic-function(&1usrfulnf&1, buf_c-trn-reason-obj.corr-user-name)', ~{&double-quote~})
&scop label-clmn_9-trobj  'Действие'
&scop form-clmn_9-trobj   "x(10)":U
&scop sort-clmn_9-trobj   ShowAction( buf_c-trn-reason-obj.action )
&scop dyn_sort-clmn_9-trobj   substitute('dynamic-function(&1ShowAction&1, buf_c-trn-reason-obj.action)', ~{&double-quote~})
&scop label-clmn_10-trobj 'Дата корр.'
&scop form-clmn_10-trobj  "99/99/9999":U
&scop sort-clmn_10-trobj  buf_c-trn-reason-obj.corr-date
&scop label-clmn_11-trobj 'Время'
&scop form-clmn_11-trobj  "x(8)":U
&scop sort-clmn_11-trobj  STRING( buf_c-trn-reason-obj.corr-time, 'HH:MM:SS':U )
&scop label-clmn_12-trobj 'Щепка'
&scop form-clmn_12-trobj  "->,>>>,>>>,>>9":U
&scop sort-clmn_12-trobj  buf_c-trn-reason-obj.chip-num
&scop label-clmn_13-trobj 'БД'
&scop form-clmn_13-trobj  ">>>>9":U
&scop sort-clmn_13-trobj  buf_c-trn-reason-obj.corr-user-db-num
&scop enabled-clmn-trobj  {&sort-clmn_3-trobj}

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
define button   b-quit    label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-sch label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-sel label "Вы&бор"    size-chars 10.00 by 1.00 default auto-go.

define variable mark-num as integer   no-undo view-as fill-in size-chars  8.00 by 1.00 format "->>>,>>>":U.
define variable sch-rsn  as integer   no-undo view-as fill-in size-chars 15.50 by 1.00 format "->,>>>,>>>,>>>":U.
define variable sch-obj  as integer   no-undo view-as fill-in size-chars 10.50 by 1.00 format ">>>>>>>>>":U.
define variable sch-ext  as character no-undo view-as fill-in size-chars  9.50 by 1.00 format "x(8)":U.
define variable sch-num  as integer   no-undo view-as fill-in size-chars  4.50 by 1.00 format ">>>":U.

/* Query definitions                                                    */
define query {&BROWSE-NAME} for buf_c-trn-reason-obj scrolling.

define query br-changes for buf_changes scrolling.

/* Browse definitions                                                   */
define browse {&BROWSE-NAME} query {&BROWSE-NAME} display
  {&sort-clmn_1-trobj}  column-label {&label-clmn_1-trobj}  format {&form-clmn_1-trobj}
  {&sort-clmn_2-trobj}  column-label {&label-clmn_2-trobj}  format {&form-clmn_2-trobj}
  {&sort-clmn_3-trobj}  column-label {&label-clmn_3-trobj}  format {&form-clmn_3-trobj}
  {&sort-clmn_4-trobj}  column-label {&label-clmn_4-trobj}  format {&form-clmn_4-trobj}
  {&sort-clmn_5-trobj}  column-label {&label-clmn_5-trobj}  format {&form-clmn_5-trobj}
  {&sort-clmn_6-trobj}  column-label {&label-clmn_6-trobj}  format {&form-clmn_6-trobj}
  {&sort-clmn_7-trobj}  column-label {&label-clmn_7-trobj}  format {&form-clmn_7-trobj}
  {&sort-clmn_8-trobj}  column-label {&label-clmn_8-trobj}  format {&form-clmn_8-trobj}
  {&sort-clmn_9-trobj}  column-label {&label-clmn_9-trobj}  format {&form-clmn_9-trobj}
  {&sort-clmn_10-trobj} column-label {&label-clmn_10-trobj} format {&form-clmn_10-trobj}
  {&sort-clmn_11-trobj} column-label {&label-clmn_11-trobj} format {&form-clmn_11-trobj}
  {&sort-clmn_12-trobj} column-label {&label-clmn_12-trobj} format {&form-clmn_12-trobj}
  {&sort-clmn_13-trobj} column-label {&label-clmn_13-trobj} format {&form-clmn_13-trobj}
  enable
  {&enabled-clmn-trobj}
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
      b-quit       at row  1 col  1
      b-mark       at row  1 col 11
      mark-num     at row  1 col 14 no-label                              fgcolor 4
      b-sel        at row  1 col 21
      b-sch        at row  1 col 31
      b-help       at row  1 col 81
      {&BROWSE-NAME} at row  3.00 col  1.50
      "          ":U at row 16.50 col  1.62 view-as text size-chars 98.00 by 1.00
      "ПОИСК ПО:"    at row 16.50 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
      sch-rsn        at row 16.50 col 11.50    label "&Коду"
      sch-obj        at row 16.50 col 36.00    label "&Объекту"
      sch-ext        at row 16.50 col 58.50    label "&Типу"
      sch-num        at row 16.50 col 94.75 no-label                              fgcolor 4
      br-changes    at row 18.00 col  1.50
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title {&description}
     default-button b-quit cancel-button b-quit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.
assign {&BROWSE-NAME}         :num-locked-columns in frame  {&FRAME-NAME}  = 1
       {&enabled-clmn-trobj} :read-only          in browse {&BROWSE-NAME} = yes
       {&enabled-clmn-br-chg} :read-only          in browse   br-changes   = yes.
assign b-mark    :tooltip in frame {&FRAME-NAME} = "Поставить/снять отметку записи"
         b-quit     :tooltip in frame {&FRAME-NAME} = "Вернуться в окно вызова"
       b-sch  :tooltip in frame {&FRAME-NAME} = "Установить/снять фильтр"
       b-help    :tooltip in frame {&FRAME-NAME} = "Интерактивная помощь в формате *.html"
       b-sel  :tooltip in frame {&FRAME-NAME} = "Выбрать текущую(ие) запись(и)"
       {&BROWSE-NAME} :tooltip in frame {&FRAME-NAME} = "Список действий над кодами оснований (причин)"
         br-changes   :tooltip in frame {&FRAME-NAME} = "Список изменений кода основания (причины)"
         sch-rsn      :tooltip in frame {&FRAME-NAME} = "Код основания (причины)" {&sch-flt}
         sch-obj      :tooltip in frame {&FRAME-NAME} = "Код объекта" {&sch-flt}
         sch-ext      :tooltip in frame {&FRAME-NAME} = "Расширенный тип документа" {&sch-flt}
         sch-num      :tooltip in frame {&FRAME-NAME} = "Количество найденных записей"
         mark-num     :tooltip in frame {&FRAME-NAME} = "Отмеченные записи".

/* ************************  Control Triggers  ************************ */
on delete-character of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  if b-mark :sensitive in frame {&FRAME-NAME} then do:
    apply "CHOOSE":U to b-mark in frame {&FRAME-NAME}.
  end.
end.

on insert-mode of {&BROWSE-NAME} in frame {&FRAME-NAME} do:
  if           b-mark   :sensitive in frame {&FRAME-NAME} then do:
    apply "CHOOSE":U to b-mark     in frame {&FRAME-NAME}.
  end.
  else if b-sel :sensitive in frame {&FRAME-NAME} then do:
    apply "CHOOSE":U to b-sel   in frame {&FRAME-NAME}.
  end.
end.

on choose of b-mark in frame {&FRAME-NAME} do: /* * */
  if available buf_c-trn-reason-obj then do:
    { gbl/markstrn.i buf_c-trn-reason-obj p-rid-list }
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
  if error-status :error then do: return no-apply. end.
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
  if not available buf_c-trn-reason-obj then do:
    return no-apply.
  end.
  if p-rid-list = "":U or b-mark :sensitive = no then do:
    assign p-rid-list = string( recid( buf_c-trn-reason-obj ) ).
  end.
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

on entry of sch-rsn in frame {&FRAME-NAME} do:
  assign sch-ext :screen-value in frame {&FRAME-NAME} = "":U
         sch-obj :screen-value in frame {&FRAME-NAME} = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display
  sch-rsn with frame {&FRAME-NAME}.
end.

on entry of sch-obj in frame {&FRAME-NAME} do:
  assign sch-ext :screen-value in frame {&FRAME-NAME} = "":U
         sch-rsn :screen-value in frame {&FRAME-NAME} = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display
  sch-obj with frame {&FRAME-NAME}.
end.

on entry of sch-ext in frame {&FRAME-NAME} do:
  assign sch-rsn :screen-value in frame {&FRAME-NAME} = "":U
         sch-obj :screen-value in frame {&FRAME-NAME} = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display
  sch-ext with frame {&FRAME-NAME}.
end.

on leave of sch-rsn in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on leave of sch-obj in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num
  in frame {&FRAME-NAME}.
end.

on leave of sch-ext in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num
  in frame {&FRAME-NAME}.
end.

on CTRL-J of sch-rsn in frame {&FRAME-NAME} do: /* код основания */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-rsn <> sch-rsn then do:
    assign sch-rsn.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-rsn in this-procedure ( input yes, input sch-rsn ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on return of sch-rsn in frame {&FRAME-NAME} do: /* код основания */
  {&SetCursorWait}
  assign sch-rsn.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-rsn in this-procedure ( input no,  input sch-rsn ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on mouse-select-dblclick of sch-rsn in frame {&FRAME-NAME} do: /* код основания */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-rsn <> sch-rsn then do:
    assign sch-rsn.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-rsn in this-procedure ( input yes, input sch-rsn ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on CTRL-J of sch-obj in frame {&FRAME-NAME} do: /* код объекта */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-obj <> sch-obj then do:
    assign sch-obj.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-obj in this-procedure ( input yes, input sch-obj ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on return of sch-obj in frame {&FRAME-NAME} do: /* код объекта */
  {&SetCursorWait}
  assign sch-obj.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-obj in this-procedure ( input no,  input sch-obj ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on mouse-select-dblclick of sch-obj in frame {&FRAME-NAME} do: /* код объекта */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-obj <> sch-obj then do:
    assign sch-obj.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-obj in this-procedure ( input yes, input sch-obj ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on CTRL-J of sch-ext in frame {&FRAME-NAME} do: /* название */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-ext <> sch-ext then do:
    assign sch-ext.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-ext in this-procedure ( input yes, input sch-ext ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on return of sch-ext in frame {&FRAME-NAME} do: /* название */
  {&SetCursorWait}
  assign sch-ext.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-ext in this-procedure ( input no,  input sch-ext ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
     return no-apply.
   end.
end.

on mouse-select-dblclick of sch-ext in frame {&FRAME-NAME} do: /* название */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-ext <> sch-ext then do:
    assign sch-ext.
    assign FoundRec = ?
           sch-num  = 0.
    hide
    sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-ext in this-procedure ( input yes, input sch-ext ) no-error.
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
    &ext-col      = 13
    &frame-name   = {&FRAME-NAME}
    &browse-name  = {&BROWSE-NAME}
    &table-name   = "buf_c-trn-reason-obj"
    &start-column = 2              }

{ gbl/srt-clmd.i
    &ext-col              = 13
    &frame-name           = {&FRAME-NAME}
    &browse-name          = {&BROWSE-NAME}
    &table-name           = "buf_c-trn-reason-obj"
    &start-column         = 2
    &label-clmn_2         = "{&label-clmn_2-trobj}"
    &sort-clmn_2          = "{&sort-clmn_2-trobj}"
    &label-clmn_3         = "{&label-clmn_3-trobj}"
    &sort-clmn_3          = "{&sort-clmn_3-trobj}"
    &label-clmn_4         = "{&label-clmn_4-trobj}"
    &sort-clmn_4          = "{&sort-clmn_4-trobj}"
    &label-clmn_5         = "{&label-clmn_5-trobj}"
    &sort-clmn_5          = "{&sort-clmn_5-trobj}"
    &label-clmn_7         = "{&label-clmn_7-trobj}"
    &sort-clmn_7          = "{&sort-clmn_7-trobj}"
    &dyn_sort-clmn_7      = "{&dyn_sort-clmn_7-trobj}"
    &label-clmn_8         = "{&label-clmn_8-trobj}"
    &sort-clmn_8          = "{&sort-clmn_8-trobj}"
    &dyn_sort-clmn_8      = "{&dyn_sort-clmn_8-trobj}"
    &label-clmn_9         = "{&label-clmn_9-trobj}"
    &sort-clmn_9          = "{&sort-clmn_9-trobj}"
    &dyn_sort-clmn_9      = "{&dyn_sort-clmn_9-trobj}"
    &label-clmn_10        = "{&label-clmn_10-trobj}"
    &sort-clmn_10         = "{&sort-clmn_10-trobj}"
    &label-clmn_11        = "{&label-clmn_11-trobj}"
    &sort-clmn_11         = "{&sort-clmn_11-trobj}"
    &label-clmn_12        = "{&label-clmn_12-trobj}"
    &sort-clmn_12         = "{&sort-clmn_12-trobj}"
    &label-clmn_13        = "{&label-clmn_13-trobj}"
    &sort-clmn_13         = "{&sort-clmn_13-trobj}"
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
  if lookup( p-mode, '{&bef-all},obj,one':U ) = 0 then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    return.
  end. /* p-mode */
  if p-mode = 'obj':U
  then do:
    find first sch_c-trn-reason-obj no-lock where
               sch_c-trn-reason-obj.obj-type = p-obj-type and
               sch_c-trn-reason-obj.obj-code = p-obj-code no-error.
    if not available sch_c-trn-reason-obj then do:

    end.
  end. /* p-mode = 'obj':U */
  if p-mode = 'one':U then do:
    find first sch_c-trn-reason-obj no-lock where
               sch_c-trn-reason-obj.obj-type     = p-obj-type     and
               sch_c-trn-reason-obj.obj-code     = p-obj-code     and
               sch_c-trn-reason-obj.ext-doc-type = p-ext-doc-type and
               sch_c-trn-reason-obj.hold-doc     = p-hold-doc     no-error.
    if not available sch_c-trn-reason-obj then do:
    end.
  end. /* p-mode = 'one':U */
  if p-rid-list <> "":U then do:
    find first sch_c-trn-reason-obj no-lock where
        recid( sch_c-trn-reason-obj ) = integer( entry( 1, p-rid-list ) ) no-error.
    if not available sch_c-trn-reason-obj then do:
    end.
    else do:
      assign v-doc-rec = recid( sch_c-trn-reason-obj ).
    end.
  end.

  enable
  b-mark   when lookup( "b-mark":U,   p-bttns ) > 0 or p-bttns = "*"
  b-sel when lookup( "b-sel":U, p-bttns ) > 0 or p-bttns = "*"
  b-sch b-help b-quit  {&BROWSE-NAME} br-changes sch-rsn sch-obj sch-ext
  with frame {&FRAME-NAME}.
  {&SetCursorWait}
  run OpenBr in this-procedure ( input yes, input no, input '':U ).
  hide mark-num in frame {&FRAME-NAME}.
  hide  sch-num in frame {&FRAME-NAME}.
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
define variable sort-column-phrase as character no-undo.
define variable l-open-query       as logical   no-undo.

case sort-column-name :
  when "obj-short( buffer buf_c-trn-reason-obj )" then do:
    assign sort-column-phrase = "by buf_c-trn-reason-obj.obj-type by buf_c-trn-reason-obj.obj-code".
  end.
  when "":U then do:
    assign sort-column-phrase = "":U.
  end.
  otherwise      do:
    assign sort-column-phrase = "by " + sort-column-name.
  end.
end case. /* sort-column-name */

&scop flt-open-open-query         open query {&BROWSE-NAME} for each buf_c-trn-reason-obj
&scop flt-open-dyn_open-query     for each buf_c-trn-reason-obj
&scop flt-open-query-handle        query {&BROWSE-NAME}:handle
&scop flt-open-open-query-tail
&scop flt-open-query-was-opened   l-query-was-opened
&scop flt-open-sort-column-phrase sort-column-phrase
&scop flt-open-call-point         filter-point
&scop flt-open-set-filter-name    set-filter-name
&scop flt-open-indexed-reposition indexed-reposition
&scop flt-open-query              p-open-query
&scop flt-open-table-name         buf_c-trn-reason-obj
&scop flt-open-search-option      no-lock
&scop flt-open-find-next          p-find-next
&scop flt-open-find-recid         v-doc-rec
&scop flt-open-find-condition     p-find-condition
&scop flt-open-find-buffer-name   buf_c-trn-reason-obj
&scop flt-open-waitfram           yes

assign
filter-point = substitute('&1 - &2', filter-point0, p-mode)
filter-label = substitute('&1 - &2', filter-label0, p-mode)
.

case p-mode :
  when {&all}  then do:
    assign frame {&FRAME-NAME} :title = "История оснований (причин) создания документов по объектам".
    { gbl/fltopend.i
        &where-cond = " yes ~
                      "
        &use-ind    = "  "
        &by         = "  "  }
  end. /* {&all} */
  when 'obj':U then do:
    assign frame {&FRAME-NAME} :title =
      substitute( 'История основания (причины) создания документов по объекту &1 &2', p-obj-type, p-obj-code ).
    { gbl/fltopend.i
        &where-cond = " buf_c-trn-reason-obj.obj-type = p-obj-type and ~
                        buf_c-trn-reason-obj.obj-code = p-obj-code "
        &dyn_where-cond = " substitute('buf_c-trn-reason-obj.obj-type = &1&2&1 and ~
                        buf_c-trn-reason-obj.obj-code = &3 ', ~{&double-quote~}, p-obj-type, p-obj-code) "
        &use-ind    = "  "
        &by         = "  "                                    }
  end. /* 'obj':U */
  when 'one':U then do:
    assign frame {&FRAME-NAME} :title =
      substitute( 'История основания (причины) создания документа "&1" &2по объекту &3 &4',
                  entry( lookup( p-ext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ),
                  ( if p-hold-doc = yes then "(межфирменные перемещения) " else "":U ),
                  p-obj-type,
                  p-obj-code ).
    { gbl/fltopend.i
        &where-cond = " buf_c-trn-reason-obj.obj-type     = p-obj-type     and ~
                        buf_c-trn-reason-obj.obj-code     = p-obj-code     and ~
                        buf_c-trn-reason-obj.ext-doc-type = p-ext-doc-type and ~
                        buf_c-trn-reason-obj.hold-doc     = p-hold-doc    "
        &dyn_where-cond = " substitute('buf_c-trn-reason-obj.obj-type     = &1&2&1     and ~
                        buf_c-trn-reason-obj.obj-code     = &3    and ~
                        buf_c-trn-reason-obj.ext-doc-type = &1&4&1 and ~
                        buf_c-trn-reason-obj.hold-doc     = &5 ', ~{&double-quote~}, p-obj-type, p-obj-code, p-ext-doc-type, p-hold-doc ) "
        &use-ind    = "  "
        &by         = "  "                                            }
  end. /* 'one':U */
end case. /* p-mode */
if p-open-query <> yes and v-doc-rec <> ? then
reposition {&BROWSE-NAME} to recid v-doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query {&BROWSE-NAME}:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end procedure. /* OpenBr */

procedure proc-filter :
  &scop obj    'obj-type{&delim-flt}obj-code'
  &scop common input-output fld, input-output lab, input-output spr, input-output dim
  assign tbl      = 'c-trn-reason-obj'
         join-tbl = 'buf_c-trn-reason-obj'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.

  {&SetCursorWait}
  run fltfield-add in this-procedure ( input 'obj-type',     input 'Тип объекта',    input '':U,  {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'obj-code',     input 'Код объекта',    input '':U,  {&common} ) no-error.
  run fltfield-add in this-procedure ( input {&obj},         input 'Объект',         input 'cli', {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'ext-doc-type', input 'Расширенн. тип', input '':U,  {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'hold-doc',     input 'Межфирменный',   input '':U,  {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'reason-code',  input 'Код причины',    input '':U,  {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'chip-num',     input 'Щепка',          input '':U,  {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-db-num',  input 'Номер БД',       input '':U,  {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-name',    input 'Имя',            input '':U,  {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-date',    input 'Дата коррекции', input '':U,  {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-time',    input 'Время в сек.',   input '':U,  {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'action',       input 'Действие',       input '':U,  {&common} ) no-error.


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
    {&SetCursorNo}
  end. /* Filter-Block */
end procedure. /* proc-filter */

procedure proc-view-changes :
for each temp-changes :
  delete temp-changes.
end.
if not available buf_c-trn-reason-obj then do:
  run OpenChanges in this-procedure .
  return.
end.
&scop fields-name-list "obj-tye,obj-code,host-code,ext-doc-type,hold-doc,reason-code"

define variable v-label-param as character no-undo .


v-label-param =
  "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "ext-doc-type" + {&delim-par} + "Расш.тип док-та" + {&delim-par} + "" + {&delim-flf}
 + "hold-doc" + {&delim-par} + "Межфирменный." + {&delim-par} + "" + {&delim-flf}
 + "reason-code" + {&delim-par} + "Код основания" + {&delim-par}.
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-trn-reason-obj.action = integer({&hn-create}))
                                            ,input  (buf_c-trn-reason-obj.action = integer({&hn-delete}))
                                            ,input  buffer  buf_c-trn-reason-obj:handle
                                            ,input  {&table_c-trn-reason-obj}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).


run OpenChanges in this-procedure .
end procedure. /* proc-view-changes */

procedure OpenChanges :
open query br-changes for each buf_changes.
end procedure. /* OpenChanges */


{ gbl/setfltnm.i }

procedure get-mark-string :
  define        parameter buffer loc-buf for ub.c-trn-reason-obj.
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

procedure get-obj-name :
  define        parameter buffer loc-buf for ub.c-trn-reason-obj.
  define  input parameter        p-mode  as  character no-undo.
  define output parameter        p-name  as  character no-undo.

  define buffer buf_cli for ub.clients.

  if p-mode = "name" then do:
    find first buf_cli no-lock where
               buf_cli.obj-type = loc-buf.obj-type and
               buf_cli.obj-code = loc-buf.obj-code no-error.
    assign p-name = ( if available buf_cli then buf_cli.obj-name else "":U ).
  end.               else do:
    assign p-name = loc-buf.obj-type + " ":U + Int2Char( loc-buf.obj-code ).
  end.
end procedure. /* get-obj-name */

procedure get-ext-name :
  define  input parameter p-code as character no-undo.
  define output parameter p-name as character no-undo.

  define variable v_code  as character no-undo.
  define variable j_entry as integer   no-undo.

  assign j_entry = lookup( p-code, {&TDEDT_List} ).
  assign p-name  = ( if j_entry > 0 then entry( j_entry, {&TDEDT_List-full} ) else "":U ).
end procedure. /* get-ext-name */

procedure proc-find-rsn :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer no-undo.

  {&SetCursorWait}
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_c-trn-reason-obj.reason-code = &1 ", p-code ) ).
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
    hide
    sch-num
    in frame {&FRAME-NAME}.
  end.
  apply "ENTRY":U to sch-rsn in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-rsn */

procedure proc-find-obj :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer no-undo.

  {&SetCursorWait}
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_c-trn-reason-obj.obj-code = &1 ", p-code ) ).
  if v-doc-rec <> ? then do:
    if FoundRec = ? then do: assign FoundRec = v-doc-rec. end.
    if FoundRec = v-doc-rec then do: assign sch-num = 0. end.
    assign  sch-num = sch-num + 1.
    display
    sch-num with frame {&FRAME-NAME}.
  end.
  else do:
    assign  sch-num = 0.
    hide
    sch-num
    in frame {&FRAME-NAME}.
  end.
  apply "ENTRY":U to sch-obj in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-obj */

procedure proc-find-ext :
  define input parameter p-next as logical   no-undo.
  define input parameter p-name as character no-undo.

  {&SetCursorWait}
  assign p-name = replace( p-name, {&double-quote}, {&double-quote} + {&double-quote} )
         p-name = replace( p-name, {&single-quote}, {&single-quote} + {&single-quote} )
         p-name = {&double-quote} + p-name + {&double-quote}.
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_c-trn-reason-obj.ext-doc-type = &1 ", p-name ) ).
  if v-doc-rec <> ? then do:
    if FoundRec = ? then do: assign FoundRec = v-doc-rec. end.
    if FoundRec = v-doc-rec then do: assign sch-num = 0. end.
    assign  sch-num = sch-num + 1.
    display
    sch-num with frame {&FRAME-NAME}.
  end.
  else do:
    assign  sch-num = 0.
    hide
    sch-num in frame {&FRAME-NAME}.
  end.
  apply "ENTRY":U to sch-ext in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-ext */