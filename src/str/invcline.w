/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История строк накладных (весовой учет топлива)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 27/10/99
Author: Dmitry Ukhanov
Creation date: 27/10/99

create: Булгаков Андрей Николаевич

*/

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */
&scop FRAME-NAME  fr-D-inv-line-0
&scop BROWSE-NAME br-inv-lines
&scop f-l         Int2Char,Rec2Char
&scop sch-flt     + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
&scop description 'История строк накладных (весовой учет топлива)':U
&scop n-s         "NEW SHARED"

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter parparentproc as widget-handle no-undo.
define input        parameter p-bttns       as character     no-undo.
define input        parameter p-mode        as character     no-undo. /* может быть {&all}, obj, doc, gds, one */
define input        parameter p-obj-type    as character     no-undo.
define input        parameter p-obj-code    as integer       no-undo.
define input        parameter p-doc-code    as character     no-undo.
define input        parameter p-artic       as character     no-undo.
define input        parameter p-prod-type   as character     no-undo.
define input        parameter p-prod-code   as integer       no-undo.
define input-output parameter p-rid-list    as character     no-undo. /* статьи в выборке */

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "История строк накладных (весовой учет топлива)":U.

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/showinf.i         }
{ gbl/flt-def.i         }
{ gbl/waitfram.i        }
{ gbl/fltfield.i        }
{ gbl/std-func.i {&f-l} }
{ ref/tmpchgs.i  {&n-s} }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ gbl/fltopend.i defproc }


define new shared buffer buf_changes  for temp-changes.
define new shared buffer buf_history  for ub.c-inv-line.
define            buffer buf_sch_hist for ub.c-inv-line.
define            buffer buf_source   for ub.inv-line.
define            buffer buf_object   for ub.clients.

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
function mark-string returns character ( buffer loc-buf for ub.c-inv-line ) :
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

function ext-type returns character ( input i-type as character ) :
  define variable v_ext-type as character no-undo.

  run get-ext-type in this-procedure ( input i-type, output v_ext-type ).
  return ( v_ext-type ).
end function. /* ext-type */

function gds-name returns character ( input i-artic     as character,
                                      input i-prod-type as character,
                                      input i-prod-code as integer    ) :
  define variable v_gds-name as character no-undo.

  run get-goods-name in this-procedure ( input i-artic, input i-prod-type, input i-prod-code, output v_gds-name ).
  return ( v_gds-name ).
end function. /* gds-name */

function is-petrol returns logical ( input i-artic     as character,
                                     input i-prod-type as character,
                                     input i-prod-code as integer    ) :
  define variable v_is-petrol as logical no-undo.

  run is-petrolium-goods in this-procedure ( input i-artic, input i-prod-type, input i-prod-code, output v_is-petrol ).
  return ( v_is-petrol ).
end function. /* gds-name */

/* Definitions for BROWSE {&BROWSE-NAME}                                */
&scop label-clmn_1-br-dtl  '*'
&scop form-clmn_1-br-dtl   'x(1)':U
&scop sort-clmn_1-br-dtl   mark-string( buffer buf_history )
&scop label-clmn_2-br-dtl  'Номер документа'
&scop form-clmn_2-br-dtl   "x(16)":U
&scop sort-clmn_2-br-dtl   buf_history.doc-code
&scop label-clmn_3-br-dtl  'Артикул'
&scop form-clmn_3-br-dtl   "x(16)":U
&scop sort-clmn_3-br-dtl   buf_history.artic
&scop label-clmn_4-br-dtl  'Производитель'
&scop form-clmn_4-br-dtl   "x(13)":U
&scop sort-clmn_4-br-dtl   obj-short( buf_history.prod-type, buf_history.prod-code )
&scop dyn_sort-clmn_4-br-dtl   substitute('dynamic-function(&1obj-short&1, &1&2&1, &1&3&1)', ~{&double-quote~}, buf_history.prod-type, buf_history.prod-code )
&scop label-clmn_5-br-dtl  'Факт кол-во, кг'
&scop form-clmn_5-br-dtl   "->>,>>>,>>9.<<<":U
&scop sort-clmn_5-br-dtl   buf_history.wast-cli-qnty
&scop label-clmn_6-br-dtl  'Итого стало, кг'
&scop form-clmn_6-br-dtl   "->>,>>>,>>9.<<<":U
&scop sort-clmn_6-br-dtl   buf_history.after-cli-qnty
&scop label-clmn_7-br-dtl  'Цена продаж / кг ({&abbr_rub}.)'
&scop form-clmn_7-br-dtl   "->>,>>>,>>>,>>>,>>9.99":U
&scop sort-clmn_7-br-dtl   buf_history.wast-rubl
&scop label-clmn_8-br-dtl  'Учет. цена / кг ({&abbr_rub}.)'
&scop form-clmn_8-br-dtl   "->>,>>>,>>>,>>>,>>9.99":U
&scop sort-clmn_8-br-dtl   buf_history.unus-wast-rubl
&scop label-clmn_9-br-dtl  'Цена продаж / кг (б.в.)'
&scop form-clmn_9-br-dtl   "->>,>>>,>>>,>>>,>>9.99":U
&scop sort-clmn_9-br-dtl   buf_history.wast-base
&scop label-clmn_10-br-dtl 'Учет. цена / кг (б.в.)'
&scop form-clmn_10-br-dtl  "->>,>>>,>>>,>>>,>>9.99":U
&scop sort-clmn_10-br-dtl  buf_history.unus-wast-base
&scop label-clmn_11-br-dtl 'Плотность'
&scop form-clmn_11-br-dtl  ">>9.999":U
&scop sort-clmn_11-br-dtl  buf_history.density
&scop label-clmn_12-br-dtl 'Кол-во до (инв.), кг'
&scop form-clmn_12-br-dtl  "->>,>>>,>>9.<<<":U
&scop sort-clmn_12-br-dtl  buf_history.before-cli-qnty
&scop label-clmn_13-br-dtl 'Название производителя'
&scop form-clmn_13-br-dtl  "x(40)":U
&scop sort-clmn_13-br-dtl  obj-name( buf_history.prod-type, buf_history.prod-code )
&scop dyn_sort-clmn_13-br-dtl  substitute('dynamic-function(&1obj-name&1, &1&2&1, &1&3&1)', ~{&double-quote~}, buf_history.prod-type, buf_history.prod-code )
&scop label-clmn_14-br-dtl 'Название товара'
&scop form-clmn_14-br-dtl  "x(48)":U
&scop sort-clmn_14-br-dtl  gds-name( buf_history.artic, buf_history.prod-type, buf_history.prod-code )
&scop dyn_sort-clmn_14-br-dtl  substitute('dynamic-function(&1gds-name&1, &1&2&1, &1&3&1, &1&4&1)', ~{&double-quote~}, buf_history.artic, buf_history.prod-type, buf_history.prod-code )
&scop label-clmn_15-br-dtl 'Код фирмы'
&scop form-clmn_15-br-dtl  ">>>>>>>>9":U
&scop sort-clmn_15-br-dtl  buf_history.host-code
&scop label-clmn_16-br-dtl 'Расширенный тип документа'
&scop form-clmn_16-br-dtl  "x(25)":U
&scop sort-clmn_16-br-dtl  ext-type( buf_history.ext-doc-type )
&scop dyn_sort-clmn_16-br-dtl  substitute('dynamic-function(&1ext-type&1, &1&2&1)', ~{&double-quote~}, buf_history.ext-doc-type )
&scop label-clmn_17-br-dtl 'Факт ордер'
&scop form-clmn_17-br-dtl  "->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>9.<<<<<<<<<<":U
&scop sort-clmn_17-br-dtl  buf_history.fact-order
&scop label-clmn_18-br-dtl 'Статус'
&scop form-clmn_18-br-dtl  "x(8)":U
&scop sort-clmn_18-br-dtl  buf_history.status_
&scop label-clmn_19-br-dtl 'Объект'
&scop form-clmn_19-br-dtl  "x(13)":U
&scop sort-clmn_19-br-dtl  obj-short( buf_history.obj-type, buf_history.obj-code )
&scop dyn_sort-clmn_19-br-dtl  substitute('dynamic-function(&1obj-short&1, &1&2&1, &1&3&1)', ~{&double-quote~}, buf_history.obj-type, buf_history.obj-code )
&scop label-clmn_20-br-dtl 'Наименование объекта'
&scop form-clmn_20-br-dtl  "x(40)":U
&scop sort-clmn_20-br-dtl  obj-name(  buf_history.obj-type, buf_history.obj-code )
&scop dyn_sort-clmn_20-br-dtl  substitute('dynamic-function(&1obj-name&1, &1&2&1, &1&3&1)', ~{&double-quote~}, buf_history.obj-type, buf_history.obj-code )
&scop label-clmn_21-br-dtl 'Изменил'
&scop form-clmn_21-br-dtl  "x(8)":U
&scop sort-clmn_21-br-dtl  buf_history.corr-user-name
&scop label-clmn_22-br-dtl 'Действие'
&scop form-clmn_22-br-dtl  "x(10)":U
&scop sort-clmn_22-br-dtl  ShowAction( buf_history.action )
&scop dyn_sort-clmn_22-br-dtl  substitute('dynamic-function(&1ShowAction&1, &1&2&1)', ~{&double-quote~}, buf_history.action )
&scop label-clmn_23-br-dtl 'Дата корр.'
&scop form-clmn_23-br-dtl  "99/99/9999":U
&scop sort-clmn_23-br-dtl  buf_history.corr-date
&scop label-clmn_24-br-dtl 'Время'
&scop form-clmn_24-br-dtl  "x(8)":U
&scop sort-clmn_24-br-dtl  STRING( buf_history.corr-time, 'HH:MM:SS':U )
&scop label-clmn_25-br-dtl 'Щепка'
&scop form-clmn_25-br-dtl  "->,>>>,>>>,>>9":U
&scop sort-clmn_25-br-dtl  buf_history.chip-num
&scop label-clmn_26-br-dtl 'БД'
&scop form-clmn_26-br-dtl  ">>>>9":U
&scop sort-clmn_26-br-dtl  buf_history.corr-user-db-num
&scop enabled-clmn-br-dtl  {&sort-clmn_11-br-dtl}

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
define button b-help label "Помо&щь"   size-chars 10.00 by 1.00 default.
define button b-mark label "&*"        size-chars  3.00 by 1.00 default.
define button b-quit label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-sch  label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-sel  label "Вы&бор"    size-chars 10.00 by 1.00 default auto-go.

define variable mark-num as integer   no-undo view-as fill-in size-chars  8.00 by 1.00 format "->>>,>>>":U.
define variable sch-code as character no-undo view-as fill-in size-chars 17.50 by 1.00 format "x(16)":U.
define variable sch-num  as integer   no-undo view-as fill-in size-chars  4.50 by 1.00 format ">>>":U.

/* Query definitions                                                    */
define new shared query {&BROWSE-NAME} for buf_history scrolling.

define new shared query br-changes for buf_changes scrolling.

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
  {&sort-clmn_14-br-dtl} column-label {&label-clmn_14-br-dtl} format {&form-clmn_14-br-dtl}
  {&sort-clmn_15-br-dtl} column-label {&label-clmn_15-br-dtl} format {&form-clmn_15-br-dtl}
  {&sort-clmn_16-br-dtl} column-label {&label-clmn_16-br-dtl} format {&form-clmn_16-br-dtl}
  {&sort-clmn_17-br-dtl} column-label {&label-clmn_17-br-dtl} format {&form-clmn_17-br-dtl}
  {&sort-clmn_18-br-dtl} column-label {&label-clmn_18-br-dtl} format {&form-clmn_18-br-dtl}
  {&sort-clmn_19-br-dtl} column-label {&label-clmn_19-br-dtl} format {&form-clmn_19-br-dtl}
  {&sort-clmn_20-br-dtl} column-label {&label-clmn_20-br-dtl} format {&form-clmn_20-br-dtl}
  {&sort-clmn_21-br-dtl} column-label {&label-clmn_21-br-dtl} format {&form-clmn_21-br-dtl}
  {&sort-clmn_22-br-dtl} column-label {&label-clmn_22-br-dtl} format {&form-clmn_22-br-dtl}
  {&sort-clmn_23-br-dtl} column-label {&label-clmn_23-br-dtl} format {&form-clmn_23-br-dtl}
  {&sort-clmn_24-br-dtl} column-label {&label-clmn_24-br-dtl} format {&form-clmn_24-br-dtl}
  {&sort-clmn_25-br-dtl} column-label {&label-clmn_25-br-dtl} format {&form-clmn_25-br-dtl}
  enable
  {&enabled-clmn-br-dtl}
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
    b-quit    at row  1 col  1
    b-mark    at row  1 col 11
    mark-num  at row  1 col 14  no-label                              fgcolor 4
    b-sel     at row  1 col 21
    b-sch     at row  1 col 31
    b-help    at row  1 col 81
  {&BROWSE-NAME} at row  2.50 col  1.50
  "          ":U at row 16 col  1.62 view-as text size-chars 98.00 by 1.00
  "ПОИСК ПО:"    at row 16 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
  sch-code       at row 16 col 11.50    label "&Артикулу"
  sch-num        at row 16 col 94.75 no-label                              fgcolor 4
  br-changes   at row 17.50 col  1.50
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title {&description}
     default-button b-quit cancel-button b-quit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.
assign {&BROWSE-NAME}         :num-locked-columns in frame  {&FRAME-NAME}  = 1
       {&enabled-clmn-br-dtl} :read-only          in browse {&BROWSE-NAME} = yes
       {&enabled-clmn-br-chg} :read-only          in browse   br-changes   = yes.
assign b-mark    :tooltip in frame {&FRAME-NAME} = "Поставить/снять отметку записи"
       b-quit     :tooltip in frame {&FRAME-NAME} = "Вернуться в окно вызова"
       b-sch  :tooltip in frame {&FRAME-NAME} = "Установить/снять фильтр"
       b-help    :tooltip in frame {&FRAME-NAME} = "Интерактивная помощь в формате *.html"
       b-sel  :tooltip in frame {&FRAME-NAME} = "Выбрать текущую(ие) запись(и)"
       {&BROWSE-NAME} :tooltip in frame {&FRAME-NAME} = "Список действий над строками"
        br-changes   :tooltip in frame {&FRAME-NAME} = "Список изменений строки"
        sch-code     :tooltip in frame {&FRAME-NAME} = "Артикул" {&sch-flt}
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
  if available buf_history then do:
    { gbl/markstrn.i buf_history p-rid-list }
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

on choose of b-quit in frame {&FRAME-NAME} do: /* Выход */
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
  if not available buf_history then do: return no-apply. end.
  if p-rid-list = "":U or b-mark :sensitive = no then do: assign p-rid-list = string( recid( buf_history ) ). end.
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

on entry of sch-code in frame {&FRAME-NAME} do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display sch-code  with frame {&FRAME-NAME}.
end.

on leave of sch-code in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on CTRL-J of sch-code in frame {&FRAME-NAME} do: /* артикул */
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

on return of sch-code in frame {&FRAME-NAME} do: /* артикул */
  {&SetCursorWait}
  assign sch-code.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-code in this-procedure ( input no,  input sch-code ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on mouse-select-dblclick of sch-code in frame {&FRAME-NAME} do: /* артикул */
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
    &ext-col      = 25
    &frame-name   = {&FRAME-NAME}
    &browse-name  = {&BROWSE-NAME}
    &table-name   = "buf_history"
    &start-column = 2              }

{ gbl/srt-clmd.i
    &ext-col              = 25
    &frame-name           = {&FRAME-NAME}
    &browse-name          = {&BROWSE-NAME}
    &table-name           = "buf_history"
    &start-column         = 2
    &label-clmn_1         = "{&label-clmn_1-br-dtl}"
    &sort-clmn_1          = "{&sort-clmn_1-br-dtl}"
    &label-clmn_2         = "{&label-clmn_2-br-dtl}"
    &sort-clmn_2          = "{&sort-clmn_2-br-dtl}"
    &label-clmn_3         = "{&label-clmn_3-br-dtl}"
    &sort-clmn_3          = "{&sort-clmn_3-br-dtl}"
    &label-clmn_4         = "{&label-clmn_4-br-dtl}"
    &sort-clmn_4          = "{&sort-clmn_4-br-dtl}"
    &dyn_sort-clmn_4      = "{&dyn_sort-clmn_4-br-dtl}"
    &label-clmn_5         = "{&label-clmn_5-br-dtl}"
    &sort-clmn_5          = "{&sort-clmn_5-br-dtl}"
    &label-clmn_6         = "{&label-clmn_6-br-dtl}"
    &sort-clmn_6          = "{&sort-clmn_6-br-dtl}"
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
    &dyn_sort-clmn_13     = "{&dyn_sort-clmn_13-br-dtl}"
    &label-clmn_14        = "{&label-clmn_14-br-dtl}"
    &sort-clmn_14         = "{&sort-clmn_14-br-dtl}"
    &dyn_sort-clmn_14     = "{&dyn_sort-clmn_14-br-dtl}"
    &label-clmn_15        = "{&label-clmn_15-br-dtl}"
    &sort-clmn_15         = "{&sort-clmn_15-br-dtl}"
    &label-clmn_16        = "{&label-clmn_16-br-dtl}"
    &sort-clmn_16         = "{&sort-clmn_16-br-dtl}"
    &dyn_sort-clmn_16     = "{&dyn_sort-clmn_16-br-dtl}"
    &label-clmn_17        = "{&label-clmn_17-br-dtl}"
    &sort-clmn_17         = "{&sort-clmn_17-br-dtl}"
    &label-clmn_18        = "{&label-clmn_18-br-dtl}"
    &sort-clmn_18         = "{&sort-clmn_18-br-dtl}"
    &label-clmn_19        = "{&label-clmn_19-br-dtl}"
    &sort-clmn_19         = "{&sort-clmn_19-br-dtl}"
    &dyn_sort-clmn_19     = "{&dyn_sort-clmn_19-br-dtl}"
    &label-clmn_20        = "{&label-clmn_20-br-dtl}"
    &sort-clmn_20         = "{&sort-clmn_20-br-dtl}"
    &dyn_sort-clmn_20     = "{&dyn_sort-clmn_20-br-dtl}"
    &label-clmn_21        = "{&label-clmn_21-br-dtl}"
    &sort-clmn_21         = "{&sort-clmn_21-br-dtl}"
    &label-clmn_22        = "{&label-clmn_22-br-dtl}"
    &sort-clmn_22         = "{&sort-clmn_22-br-dtl}"
    &dyn_sort-clmn_22     = "{&dyn_sort-clmn_22-br-dtl}"
    &label-clmn_23        = "{&label-clmn_23-br-dtl}"
    &sort-clmn_23         = "{&sort-clmn_23-br-dtl}"
    &label-clmn_24        = "{&label-clmn_24-br-dtl}"
    &sort-clmn_24         = "{&sort-clmn_24-br-dtl}"
    &label-clmn_25        = "{&label-clmn_25-br-dtl}"
    &sort-clmn_25         = "{&sort-clmn_25-br-dtl}"
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

{ gbl/srt-clmd.i
    &ext-col              = 3
    &frame-name           = {&FRAME-NAME}
    &browse-name          = br-changes
    &table-name           = "buf_changes"
    &start-column         = 1
    &label-clmn_1         = "{&label-clmn_1-br-chg}"
    &sort-clmn_1          = "{&sort-clmn_1-br-chg}"
    &label-clmn_2         = "{&label-clmn_2-br-chg}"
    &sort-clmn_2          = "{&sort-clmn_2-br-chg}"
    &label-clmn_3         = "{&label-clmn_3-br-chg}"
    &sort-clmn_3          = "{&sort-clmn_3-br-chg}"
    &open-query           = "run OpenChanges in this-procedure ( input yes, input no, input '':U )."
    &open-query-otherwise = "run OpenChanges in this-procedure ( input yes, input no, input '':U )."
    &sort-column-name     = "sort-change-name"
    &re-move-clmn         = "no"
    &mv-brw-default       = "yes"                                                                    }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
   p-host-code = v-cntxt-host-code-obj.

  if lookup( p-mode, '{&bef-all},obj,doc,gds,one':U ) = 0 then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
  end. /* p-mode */
  if p-mode = 'obj':U or
     p-mode = 'gds':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.obj-type = p-obj-type and
               buf_sch_hist.obj-code = p-obj-code no-error.
    if not available buf_sch_hist then do:
      message
              'Нет истории по - '
              '"' + p-obj-type + '"' p-obj-code '.'
      view-as alert-box information.
    end.
  end. /* p-mode = 'obj':U */
  if p-mode = 'doc':U then do:
    find first buf_sch_hist no-lock where buf_sch_hist.doc-code = p-doc-code no-error.
    if not available buf_sch_hist then do:
      message
              'Нет истории по' p-doc-code
      view-as alert-box information.
    end.
  end. /* p-mode = 'doc':U */
  if p-mode = 'gds':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.obj-type  = p-obj-type  and
               buf_sch_hist.obj-code  = p-obj-code  and
               buf_sch_hist.artic     = p-artic     and
               buf_sch_hist.prod-type = p-prod-type and
               buf_sch_hist.prod-code = p-prod-code no-error.
    if not available buf_sch_hist then do:
      message
              'Нет истории по:'
              p-artic ', ' p-prod-type ' и ' p-prod-code '.'
      view-as alert-box information.
    end.
  end. /* p-mode = 'gds':U */
  if p-mode = 'one':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.doc-code  = p-doc-code  and
               buf_sch_hist.artic     = p-artic     and
               buf_sch_hist.prod-type = p-prod-type and
               buf_sch_hist.prod-code = p-prod-code no-error.
    if not available buf_sch_hist then do:
      message
              'Нет истории по :'
              p-artic ', ' p-prod-type ' и ' p-prod-code '.'
      view-as alert-box information .
    end.
  end. /* p-mode = 'one':U */
  if p-rid-list <> "":U then do:
    find first buf_sch_hist no-lock where recid( buf_sch_hist ) = integer( entry( 1, p-rid-list ) ) no-error.
    if not available buf_sch_hist then do:

    end.
    else do:
      assign doc-rec = recid( buf_sch_hist ).
    end.
  end.

  /* display sch-code sch-num mark-num br-changes with frame {&FRAME-NAME}. */
  enable  b-mark   when lookup( "b-mark":U,   p-bttns ) > 0 or p-bttns = "*"
          b-sel when lookup( "b-sel":U, p-bttns ) > 0 or p-bttns = "*"
          b-sch b-help b-quit {&BROWSE-NAME} br-changes sch-code
  with frame {&FRAME-NAME}.
  {&SetCursorWait}
  run OpenBr in this-procedure ( input yes, input no, input '':U ).
  hide mark-num in frame {&FRAME-NAME}.
  hide  sch-num in frame {&FRAME-NAME}.
  if p-rid-list <> "":U then do: reposition {&BROWSE-NAME} to recid doc-rec no-error. end.
  {&BROWSE-NAME} :set-repositioned-row( 5, "CONDITIONAL" ).
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

  define variable p-proc-hand as handle no-undo.

  {&SetCursorWait}
  run WaitFram-Show in this-procedure ( input "Ждите..." ).
  assign title0 = "История" + {&space-char}.
  assign p-proc-hand = this-procedure :handle.

  case sort-column-name :
    when "":U then do: assign sort-column-phrase = "":U. end.
    otherwise      do: assign sort-column-phrase = "by " + sort-column-name. end.
  end case. /* sort-column-name */

  &scop flt-open-open-query         open query {&BROWSE-NAME} for each buf_history
  &scop flt-open-dyn_open-query     for each buf_history
  &scop flt-open-query-handle       query {&BROWSE-NAME}:handle
  &scop flt-open-open-query-tail
  &scop flt-open-query-was-opened   l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point         filter-point
  &scop flt-open-set-filter-name    set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition
  &scop flt-open-query              p-open-query
  &scop flt-open-table-name         buf_history
  &scop flt-open-search-option      no-lock
  &scop flt-open-find-next          p-find-next
  &scop flt-open-find-recid         doc-rec
  &scop flt-open-find-condition     p-find-condition
  &scop flt-open-find-buffer-name   buf_history
  &scop flt-open-waitfram           yes

  define variable l-open-query as logical no-undo.

  assign filter-point = filter-point0 + " - " + p-mode.

  case p-mode :
    when {&all}  then do:
      {&SetCursorWait}
      assign frame {&FRAME-NAME} :title = title0 + "топливных строк (весовой учет)".
      { gbl/fltopend.i
          &where-cond = " yes "
          &dyn_where-cond = " substitute('&1', yes)"
          &use-ind    = "  "
          &by         = "  "  }
/*        &where-cond = " ~
                          is-petrol( buf_history.artic, ~
                                     buf_history.prod-type, ~
                                     buf_history.prod-code ) ~
                        " */
    end. /* {&all} */
    when 'obj':U then do:
      {&SetCursorWait}
      find first buf_object no-lock where
                 buf_object.obj-type = p-obj-type and
                 buf_object.obj-code = p-obj-code no-error.
      assign frame {&FRAME-NAME} :title = title0 +
        substitute( 'топливных строк (весовой учет) по объекту "&1"', trim( substring( buf_object.obj-name, 1, 40 ) ) ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_history.obj-type = p-obj-type and ~
                          buf_history.obj-code = p-obj-code ~
                        "
          &dyn_where-cond = " substitute('buf_history.obj-type = &1&2&1 and buf_history.obj-code = &3', ~{&double-quote~}, p-obj-type, p-obj-code )"
          &use-ind    = "  "
          &by         = "  "                                    }
/*        &where-cond = " ~
                          is-petrol( buf_history.artic, ~
                                     buf_history.prod-type, ~
                                     buf_history.prod-code ) and ~
                          buf_history.obj-type = p-obj-type  and ~
                          buf_history.obj-code = p-obj-code ~
                        " */
    end. /* 'obj':U */
    when 'doc':U then do:
      {&SetCursorWait}
      assign frame {&FRAME-NAME} :title = title0 +
        substitute( 'топливных строк (весовой учет) по документу "&1"', p-doc-code ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_history.doc-code = p-doc-code ~
                        "
          &dyn_where-cond = " substitute('buf_history.doc-code = &1&2&1', ~{&double-quote~}, p-doc-code )"
          &use-ind    = "  "
          &by         = "  "                                }
/*        &where-cond = " ~
                          is-petrol( buf_history.artic, ~
                                     buf_history.prod-type, ~
                                     buf_history.prod-code ) and ~
                          buf_history.doc-code = p-doc-code ~
                        " */
    end. /* 'doc':U */
    when 'gds':U then do:
      {&SetCursorWait}
      find first buf_object no-lock where
                 buf_object.obj-type = p-obj-type and
                 buf_object.obj-code = p-obj-code no-error.
      assign frame {&FRAME-NAME} :title = title0 +
        substitute( 'строк (весовой учет) топлива &1 (&2 &3) по объекту "&4"',
                    p-artic, p-prod-type, p-prod-code, trim( substring( buf_object.obj-name, 1, 30 ) ) ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_history.obj-type  = p-obj-type  and ~
                          buf_history.obj-code  = p-obj-code  and ~
                          buf_history.artic     = p-artic     and ~
                          buf_history.prod-type = p-prod-type and ~
                          buf_history.prod-code = p-prod-code ~
                        "
          &dyn_where-cond = " substitute('~
                          buf_history.obj-type  = &1&2&1  and ~
                          buf_history.obj-code  = &3  and ~
                          buf_history.artic     = &1&4&1  and ~
                          buf_history.prod-type = &1&5&1  and ~
                          buf_history.prod-code = &6' ~
                          , ~{&double-quote~}, p-obj-type, p-obj-code, p-artic, p-prod-type, p-prod-code )"
          &use-ind    = "  "
          &by         = "  "                                      }
/*        &where-cond = " ~
                          is-petrol( buf_history.artic, ~
                                     buf_history.prod-type, ~
                                     buf_history.prod-code )  and ~
                          buf_history.obj-type  = p-obj-type  and ~
                          buf_history.obj-code  = p-obj-code  and ~
                          buf_history.artic     = p-artic     and ~
                          buf_history.prod-type = p-prod-type and ~
                          buf_history.prod-code = p-prod-code ~
                        " */
    end. /* 'gds':U */
    when 'one':U then do:
      {&SetCursorWait}
      assign frame {&FRAME-NAME} :title = title0 +
        substitute( 'строки (весовой учет) топлива &1 (&2 &3) по документу "&4"',
                    p-artic, p-prod-type, p-prod-code, p-doc-code ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_history.doc-code  = p-doc-code  and ~
                          buf_history.artic     = p-artic     and ~
                          buf_history.prod-type = p-prod-type and ~
                          buf_history.prod-code = p-prod-code ~
                        "
          &dyn_where-cond = " substitute('~
                          buf_history.doc-code  = &1&2&1 and ~
                          buf_history.artic     = &1&3&1 and ~
                          buf_history.prod-type = &1&4&1 and ~
                          buf_history.prod-code = &5' ~
                          , ~{&double-quote~}, p-doc-code, p-artic, p-prod-type, p-prod-code) "
          &use-ind    = "  "
          &by         = "  "                                      }
/*        &where-cond = " ~
                          is-petrol( buf_history.artic, ~
                                     buf_history.prod-type, ~
                                     buf_history.prod-code )  and ~
                          buf_history.doc-code  = p-doc-code  and ~
                          buf_history.artic     = p-artic     and ~
                          buf_history.prod-type = p-prod-type and ~
                          buf_history.prod-code = p-prod-code ~
                        " */
    end. /* 'one':U */
  end case. /* p-mode */
  {&SetCursorWait}
  if p-open-query <> yes then do: reposition {&BROWSE-NAME} to recid doc-rec no-error. end.
  run WaitFram-Hide in this-procedure.
  apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* OpenBr */

procedure proc-filter :
  &scop  cli        obj-type{&delim-flt}obj-code
  &scop  prd        prod-type{&delim-flt}prod-code

  assign tbl      = 'c-inv-line'
         join-tbl = 'buf_history'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.

  {&SetCursorWait}
  run fltfield-add in this-procedure ( input 'doc-code',         input 'Номер документа',                 input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'artic',            input 'Артикул',                         input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'prod-type',        input 'Тип производителя',               input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'prod-code',        input 'Код производителя',               input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input '{&prd}',           input 'Производитель',                   input 'cli':U, input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'wast-cli-qnty',    input 'Факт количество',                 input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'wast-rubl',        input 'Цена продаж / кг ({&abbr_rub}.)', input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'unus-wast-rubl',   input 'Учет. цена / кг ({&abbr_rub}.)',  input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'wast-base',        input 'Цена продаж / кг (б.в.)',         input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'unus-wast-base',   input 'Учет. цена / кг (б.в.)',          input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'after-cli-qnty',   input 'Итого стало / кг',                input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'before-cli-qnty',  input 'Количество до инвентаризации',    input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'density',          input 'Плотность',                       input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'host-code',        input 'Код фирмы',                       input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'ext-doc-type',     input 'Расширенный тип документа',       input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'fact-order',       input 'Факт ордер',                      input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'status_',          input 'Статус',                          input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'obj-type',         input 'Тип объекта',                     input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'obj-code',         input 'Код объекта',                     input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input '{&cli}',           input 'Объект',                          input 'cli':U, input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'chip-num',         input 'Щепка',                           input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-db-num', input 'Номер БД',                        input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-name',   input 'Имя',                             input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'corr-date',        input 'Дата коррекции',                  input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'corr-time',        input 'Время в секундах',                input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.
  run fltfield-add in this-procedure ( input 'action',           input 'Описание действия',               input '':U,    input-output fld, input-output lab, input-output spr, input-output dim ) no-error.

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
    assign b-sch :tooltip in frame {&FRAME-NAME} = "Установить/снять фильтр".
    {&SetCursorNo}
  end. /* Filter-Block */
end procedure. /* proc-filter */

procedure proc-view-changes :
  define buffer new_hist for ub.c-inv-line.
  define buffer buf_srch for ub.inv-line.

  define variable v-chg-fields as character no-undo.
  define variable v-old-fields as character no-undo.
  define variable v-new-fields as character no-undo.
  define variable jj           as integer   no-undo.

  for each temp-changes :
    delete temp-changes.
  end.
  if not available buf_history then do:
    run OpenChanges in this-procedure ( input yes, input no, input '':U ).
    return.
  end.
  find first new_hist no-lock where
             new_hist.doc-code  = buf_history.doc-code  and
             new_hist.artic     = buf_history.artic     and
             new_hist.prod-type = buf_history.prod-type and
             new_hist.prod-code = buf_history.prod-code and
             new_hist.chip-num  > buf_history.chip-num  no-error.
  if not available new_hist then do:
    find buf_srch no-lock where
         buf_srch.doc-code  = buf_history.doc-code  and
         buf_srch.artic     = buf_history.artic     and
         buf_srch.prod-type = buf_history.prod-type and
         buf_srch.prod-code = buf_history.prod-code no-error.
    if not available buf_srch then do: return error. end.
    buffer-compare buf_srch to buf_history save result in v-chg-fields.
  end.
  else do:
    buffer-compare new_hist    except chip-num corr-date corr-time corr-user-name corr-user-db-num action
                to buf_history save result in v-chg-fields.
  end.

  &scop disp-field ~
  when "~{&field-name~}":U then do: ~
    create temp-changes. ~
    assign temp-changes.f_name = "~{&field-name~}":U ~
           temp-changes.l_name = ~{&field-label~} ~
           temp-changes.v_old  = string( buf_history.~{&field-name~} ) ~
           temp-changes.v_new  = ( if available new_hist then string( new_hist.~{&field-name~} ) ~
                                                         else string( buf_srch.~{&field-name~} ) ). ~
  end. /* ~{&field-name~} */

  do jj = 1 to num-entries( v-chg-fields ) :
    case entry( jj, v-chg-fields ) :
      &scop field-name  prod-type
      &scop field-label "Тип произв."
      {&disp-field}
      &scop field-name  prod-code
      &scop field-label "Код произв."
      {&disp-field}
      &scop field-name  artic
      &scop field-label "Артикул"
      {&disp-field}
      &scop field-name  doc-code
      &scop field-label "Номер документа"
      {&disp-field}
      &scop field-name  before-cli-qnty
      &scop field-label "Кол-во до инв."
      {&disp-field}
      &scop field-name  wast-base
      &scop field-label "Учет (б.в.)"
      {&disp-field}
      &scop field-name  wast-rubl
      &scop field-label "Учет ({&abbr_rub}.)"
      {&disp-field}
      &scop field-name  unus-wast-base
      &scop field-label "Учет (б.в.)"
      {&disp-field}
      &scop field-name  unus-wast-rubl
      &scop field-label "Учет ({&abbr_rub}.)"
      {&disp-field}
      &scop field-name  after-cli-qnty
      &scop field-label "Кол-во итого"
      {&disp-field}
      &scop field-name  wast-cli-qnty
      &scop field-label "Факт кол-во"
      {&disp-field}
      &scop field-name  obj-type
      &scop field-label "Тип объекта"
      {&disp-field}
      &scop field-name  obj-code
      &scop field-label "Код объекта"
      {&disp-field}
      &scop field-name  status_
      &scop field-label "Статус"
      {&disp-field}
      &scop field-name  fact-order
      &scop field-label "Факт ордер"
      {&disp-field}
      &scop field-name  host-code
      &scop field-label "Своя фирма"
      {&disp-field}
      &scop field-name  ext-doc-type
      &scop field-label "Расширенный тип"
      {&disp-field}
      &scop field-name  density
      &scop field-label "Плотность"
      {&disp-field}
    end case. /* entry */
  end. /* jj */
  run OpenChanges in this-procedure ( input yes, input no, input '':U ).
end procedure. /* proc-view-changes */

procedure OpenChanges :
  define input parameter p-open-query     as logical   no-undo.
  define input parameter p-find-next      as logical   no-undo.
  define input parameter p-find-condition as character no-undo.

  define variable l-query-was-opened as logical   no-undo.
  define variable sort-change-phrase as character no-undo.
  define variable l-open-query       as logical   no-undo.
  define variable p-proc-hand        as handle    no-undo.

  &scop flt-open-open-query         open query br-changes for each buf_changes
  &scop flt-open-dyn_open-query     for each buf_changes
  &scop flt-open-query-handle       query br-changes:handle
  &scop flt-open-open-query-tail
  &scop flt-open-query-was-opened   l-query-was-opened
  &scop flt-open-sort-column-phrase sort-change-phrase
  &scop flt-open-call-point         c-point
  &scop flt-open-set-filter-name    set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition
  &scop flt-open-query              p-open-query
  &scop flt-open-table-name         buf_changes
  &scop flt-open-search-option      no-lock
  &scop flt-open-find-next          p-find-next
  &scop flt-open-find-recid         doc-rec
  &scop flt-open-find-condition     p-find-condition
  &scop flt-open-find-buffer-name   buf_changes
  &scop flt-open-waitfram           yes

  {&SetCursorWait}
  /* run WaitFram-Show in this-procedure ( input "Ждите..." ). */
  ASSIGN p-proc-hand = this-procedure :handle.

  case sort-change-name :
    when "":U then do: assign sort-change-phrase = "":U. end.
    otherwise      do: assign sort-change-phrase = "by " + sort-change-name. end.
  end case. /* sort-change-name */

  {&SetCursorWait}
  { gbl/fltopend.i
      &where-cond = " yes "
      &dyn_where-cond = " substitute('&1', yes)"
      &use-ind    = "  "
      &by         = "  "    }
  {&SetCursorWait}
  if p-open-query <> yes then do: reposition {&BROWSE-NAME} to recid doc-rec no-error. end.
  run WaitFram-Hide in this-procedure.
  {&SetCursorNo}
end procedure. /* OpenChanges */

{ gbl/setfltnm.i }

procedure get-mark-string :
  define        parameter buffer loc-buf for ub.c-inv-line.
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

procedure proc-find-code :
  define input parameter p-next as logical   no-undo.
  define input parameter p-code as character no-undo.

  {&SetCursorWait}
  ASSIGN p-code = REPLACE( p-code, {&double-quote}, {&double-quote} + {&double-quote} )
         p-code = REPLACE( p-code, {&single-quote}, {&single-quote} + {&single-quote} )
         p-code = {&double-quote} + p-code + {&double-quote}.
  run OpenBr in this-procedure ( input no, input p-next, input substitute( " and buf_history.artic begins &1 ", p-code ) ).
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
  apply "ENTRY":U to sch-code in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-code */

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

procedure get-ext-type :
  define  input parameter p-type as character no-undo.
  define output parameter p-name as character no-undo.

  define variable jndex as integer no-undo.

  assign jndex  = lookup( p-type, {&TDEDT_List} ).
  assign p-name = ( if jndex = 0 then "":U else entry( jndex, {&TDEDT_List-full} ) ).
end procedure. /* get-ext-type */

procedure get-goods-name :
  define  input parameter p-artic     as character no-undo.
  define  input parameter p-prod-type as character no-undo.
  define  input parameter p-prod-code as integer   no-undo.
  define output parameter p-gds-name  as character no-undo.

  define buffer buf_goods for ub.goods.

  find first buf_goods no-lock where
             buf_goods.artic     = p-artic     and
             buf_goods.prod-type = p-prod-type and
             buf_goods.prod-code = p-prod-code no-error.
  assign p-gds-name = ( if available buf_goods then buf_goods.gds-name else "":U ).
end procedure. /* get-goods-name */

procedure is-petrolium-goods :
  define  input parameter p-artic     as character no-undo.
  define  input parameter p-prod-type as character no-undo.
  define  input parameter p-prod-code as integer   no-undo.
  define output parameter p-is-petrol as logical   no-undo initial no.

  define variable v_is-petrol as logical no-undo initial no.
  define variable v_is-pieces as logical no-undo initial no.

  define buffer buf_goods for ub.goods.
  define buffer buf_units for ub.units.

  find first buf_goods no-lock where
             buf_goods.artic     = p-artic     and
             buf_goods.prod-type = p-prod-type and
             buf_goods.prod-code = p-prod-code no-error.
  if not available buf_goods then do: return. end.
  find first buf_units no-lock where buf_units.unit-name = buf_goods.unit-base no-error.
  if not available buf_units then do: return. end.
  assign v_is-petrol = ( if lookup( {&petrolium}, buf_units.type ) > 0 then yes else no ).
  if lookup( {&pieces}, buf_units.type ) = 0 then do:
    if v_is-petrol = yes and lookup( {&divisional}, buf_units.type ) = 0 then do: return. end.
    assign v_is-pieces = no.
  end.
  else do:
    assign v_is-pieces = yes.
  end.
  assign p-is-petrol = ( ( v_is-petrol = yes ) and ( v_is-pieces = no ) ).
end procedure. /* is-petrolium-goods */