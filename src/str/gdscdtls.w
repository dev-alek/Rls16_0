/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История изменения детализации строки документа по признакам

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Булгаков Андрей Николаевич
07/13/05


*/

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */
&scop FRAME-NAME  fr-D-gds-dtl-0
&scop BROWSE-NAME br-gds-dtls
&scop f-l         Int2Char,Rec2Char
&scop sch-flt     + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
&scop description 'История изменения строки документа по признакам':U

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter parparentproc as widget-handle no-undo.
define input        parameter p-bttns       as character     no-undo.
define input        parameter p-mode        as character     no-undo. /* м.б.: {&all},obj,doc,gds,one */
define input        parameter p-doc-code    as character     no-undo.
define input        parameter p-artic       as character     no-undo.
define input        parameter p-prod-type   as character     no-undo.
define input        parameter p-prod-code   as integer       no-undo.
define input        parameter p-prt-code    as integer       no-undo.
define input-output parameter p-rid-list    as character     no-undo. /* записи в выборке */

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "История изменения детализации строки документа по признакам":U.

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/showinf.i         }
{ gbl/flt-def.i         }
{ gbl/waitfram.i        }
{ gbl/fltfield.i        }
{ gbl/std-func.i {&f-l} }
{ ref/tmpchgs.i  "new shared" }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/fltopend.i defproc }

define new shared buffer buf_changes  for temp-changes.
define new shared buffer buf_history  for ub.c-gds-dtl.
define            buffer buf_sch_hist for ub.c-gds-dtl.
define            buffer buf_source   for ub.gds-dtl.
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
function mark-string returns character ( buffer loc-buf for ub.c-gds-dtl ) :
  define variable v_mark-sign as character no-undo.
  run get-mark-string in this-procedure ( buffer loc-buf, output v_mark-sign ).
  return ( v_mark-sign ).
end function. /* mark-string */

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

function gds-name returns character ( buffer loc-buf for ub.c-gds-dtl ) :
  define variable v_gds-name as character no-undo.
  run get-goods-name in this-procedure ( buffer loc-buf, output v_gds-name ).
  return ( v_gds-name ).
end function. /* gds-name */

/* Definitions for BROWSE {&BROWSE-NAME}                                */
&scop label-clmn_1-br-dtl  '*'
&scop form-clmn_1-br-dtl   'x(1)':U
&scop sort-clmn_1-br-dtl   mark-string( buffer buf_history )
&scop label-clmn_2-br-dtl  'Номер накладной'
&scop form-clmn_2-br-dtl   "x(16)":U
&scop sort-clmn_2-br-dtl   buf_history.doc-code
&scop label-clmn_3-br-dtl  'Артикул'
&scop form-clmn_3-br-dtl   "x(16)":U
&scop sort-clmn_3-br-dtl   buf_history.artic
&scop label-clmn_4-br-dtl  'Производитель'
&scop form-clmn_4-br-dtl   "x(13)":U
&scop sort-clmn_4-br-dtl   obj-short( buf_history.prod-type, buf_history.prod-code )
&scop label-clmn_5-br-dtl  'Номенкл. н-р'
&scop form-clmn_5-br-dtl   ">>>>>>>>>9":U
&scop sort-clmn_5-br-dtl   buf_history.prt-code
&scop label-clmn_6-br-dtl  'Объект'
&scop form-clmn_6-br-dtl   "x(13)":U
&scop sort-clmn_6-br-dtl   obj-short( buf_history.obj-type, buf_history.obj-code )
&scop label-clmn_7-br-dtl  'Заявлено'
&scop form-clmn_7-br-dtl   "->>,>>>,>>9.<<<":U
&scop sort-clmn_7-br-dtl   buf_history.doc-qnty
&scop label-clmn_8-br-dtl  'Фактически'
&scop form-clmn_8-br-dtl   "->>,>>>,>>9.<<<":U
&scop sort-clmn_8-br-dtl   buf_history.fact-qnty
&scop label-clmn_9-br-dtl  'Цена ({&abbr_rub})'
&scop form-clmn_9-br-dtl   "->,>>>,>>>,>>>,>>9.999":U
&scop sort-clmn_9-br-dtl   buf_history.price-rubl
&scop label-clmn_10-br-dtl 'Цена (б.в.)'
&scop form-clmn_10-br-dtl  "->>,>>>,>>>,>>9.999":U
&scop sort-clmn_10-br-dtl  buf_history.price-base
&scop label-clmn_11-br-dtl 'Скидка ({&abbr_rub})'
&scop form-clmn_11-br-dtl  "->,>>>,>>>,>>>,>>9.99":U
&scop sort-clmn_11-br-dtl  buf_history.discnt-rubl
&scop label-clmn_12-br-dtl 'Скидка (б.в.)'
&scop form-clmn_12-br-dtl  "->>>,>>>,>>9.99":U
&scop sort-clmn_12-br-dtl  buf_history.discnt-base
&scop label-clmn_13-br-dtl 'С'
&scop form-clmn_13-br-dtl  "+/-":U
&scop sort-clmn_13-br-dtl  buf_history.discnt-type
&scop label-clmn_14-br-dtl 'Процент скидки'
&scop form-clmn_14-br-dtl  "->>>9.99<<%":U
&scop sort-clmn_14-br-dtl  buf_history.discnt-pc
&scop label-clmn_15-br-dtl 'А'
&scop form-clmn_15-br-dtl  "+/-":U
&scop sort-clmn_15-br-dtl  buf_history.ov
&scop label-clmn_16-br-dtl 'Текущ. прод. цена'
&scop form-clmn_16-br-dtl  "->>>,>>>,>>9.99":U
&scop sort-clmn_16-br-dtl  buf_history.cur-base
&scop label-clmn_17-br-dtl 'НДС ({&abbr_rub})'
&scop form-clmn_17-br-dtl  "->,>>>,>>>,>>>,>>9.99":U
&scop sort-clmn_17-br-dtl  buf_history.VAT-rubl
&scop label-clmn_18-br-dtl 'НДС (баз.вал.)'
&scop form-clmn_18-br-dtl  "->,>>>,>>>,>>>,>>9.99":U
&scop sort-clmn_18-br-dtl  buf_history.VAT-base
&scop label-clmn_19-br-dtl 'Наименование объекта'
&scop form-clmn_19-br-dtl  "x(40)":U
&scop sort-clmn_19-br-dtl  obj-name( buf_history.obj-type, buf_history.obj-code )
&scop label-clmn_20-br-dtl 'Наименование производителя'
&scop form-clmn_20-br-dtl  "x(40)":U
&scop sort-clmn_20-br-dtl  obj-name( buf_history.prod-type, buf_history.prod-code )
&scop label-clmn_21-br-dtl 'Наименование товара'
&scop form-clmn_21-br-dtl  "x(48)":U
&scop sort-clmn_21-br-dtl  gds-name( buffer buf_history )
&scop label-clmn_22-br-dtl 'Дата док-та'
&scop form-clmn_22-br-dtl  "99/99/9999":U
&scop sort-clmn_22-br-dtl  buf_history.doc-date
&scop label-clmn_23-br-dtl 'Щепка'
&scop form-clmn_23-br-dtl  "->,>>>,>>>,>>9":U
&scop sort-clmn_23-br-dtl  buf_history.chip-num
&scop enabled-clmn-br-dtl  {&sort-clmn_23-br-dtl}

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
define button b-Exit label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-sch  label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-sel  label "Вы&бор"    size-chars 10.00 by 1.00 default auto-go.

define variable mark-num as integer   no-undo view-as fill-in size-chars  8.00 by 1.00 format "->>>,>>>":U.
define variable sch-doc  as character no-undo view-as fill-in size-chars 16.00 by 1.00 format "x(16)":U.
define variable sch-gds  as character no-undo view-as fill-in size-chars 16.00 by 1.00 format "x(16)":U.
define variable sch-prt  as integer   no-undo view-as fill-in size-chars  5.00 by 1.00 format ">>>>>":U.
define variable sch-num  as integer   no-undo view-as fill-in size-chars  4.50 by 1.00 format ">>>":U.

/* Query definitions                                                    */
define new shared query {&BROWSE-NAME} for buf_history scrolling.

define new shared query   br-changes   for buf_changes scrolling.

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
  b-Exit     at row  1 col  1
  b-mark     at row  1 col 11
  mark-num   at row  1 col 14 no-label                              fgcolor 4
  b-sel      at row  1 col 21
  b-sch      at row  1 col 31
  b-help     at row  1 col 81
  {&BROWSE-NAME} at row  2.5 col  1.50
  "          ":U at row 16 col  1.62 view-as text size-chars 98.00 by 1.00
  "ПОИСК ПО:"    at row 16 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
  sch-doc        at row 16 col 11.50    label "&док-ту"
  sch-gds        at row 16 col 38.50    label "&артик."
  sch-prt        at row 16 col 65.50    label "&номенкл. н-ру"
  sch-num        at row 16 col 94.75 no-label                              fgcolor 4
  br-changes     at row 17.50 col  1.50
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title {&description}
     default-button b-Exit cancel-button b-Exit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.
assign {&BROWSE-NAME}         :num-locked-columns in frame  {&FRAME-NAME}  = 1
       {&enabled-clmn-br-dtl} :read-only          in browse {&BROWSE-NAME} = yes
       {&enabled-clmn-br-chg} :read-only          in browse   br-changes   = yes.
assign b-mark :tooltip in frame {&FRAME-NAME} = "Поставить/снять отметку записи"
       b-Exit :tooltip in frame {&FRAME-NAME} = "Вернуться в окно вызова"
       b-sch  :tooltip in frame {&FRAME-NAME} = "Установить/снять фильтр"
       b-help :tooltip in frame {&FRAME-NAME} = "Интерактивная помощь в формате *.html"
       b-sel  :tooltip in frame {&FRAME-NAME} = "Выбрать текущую(ие) запись(и)"
       {&BROWSE-NAME} :tooltip in frame {&FRAME-NAME} = "Список действий над детализированными строками накладных"
         br-changes   :tooltip in frame {&FRAME-NAME} = "Список изменений детализации строки накладной"
         sch-doc      :tooltip in frame {&FRAME-NAME} = "Номер документа" {&sch-flt}
         sch-gds      :tooltip in frame {&FRAME-NAME} = "Артикул товара" {&sch-flt}
         sch-prt      :tooltip in frame {&FRAME-NAME} = "Номенклатурный номер" {&sch-flt}
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

on choose of b-Exit in frame {&FRAME-NAME} do: /* Выход */
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

on entry of sch-doc in frame {&FRAME-NAME} do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  assign  sch-gds :screen-value in frame {&FRAME-NAME} = "":U
          sch-prt :screen-value in frame {&FRAME-NAME} = "":U.
  display sch-doc with frame {&FRAME-NAME}.
end.

on entry of sch-gds in frame {&FRAME-NAME} do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  assign  sch-doc :screen-value in frame {&FRAME-NAME} = "":U
          sch-prt :screen-value in frame {&FRAME-NAME} = "":U.
  display sch-gds with frame {&FRAME-NAME}.
end.

on entry of sch-prt in frame {&FRAME-NAME} do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  assign  sch-doc :screen-value in frame {&FRAME-NAME} = "":U
          sch-gds :screen-value in frame {&FRAME-NAME} = "":U.
  display sch-prt with frame {&FRAME-NAME}.
end.

on leave of sch-doc in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on leave of sch-gds in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on leave of sch-prt in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on CTRL-J of sch-doc in frame {&FRAME-NAME} do: /* номер документа */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-doc <> sch-doc then do:
    assign sch-doc.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-doc in this-procedure ( input yes, input sch-doc ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on return of sch-doc in frame {&FRAME-NAME} do: /* номер документа */
  {&SetCursorWait}
  assign sch-doc.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-doc in this-procedure ( input no,  input sch-doc ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on mouse-select-dblclick of sch-doc in frame {&FRAME-NAME} do: /* номер документа */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-doc <> sch-doc then do:
    assign sch-doc.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-doc in this-procedure ( input yes, input sch-doc ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on CTRL-J of sch-gds in frame {&FRAME-NAME} do: /* артикулу товара */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-gds <> sch-gds then do:
    assign sch-gds.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-gds in this-procedure ( input yes, input sch-gds ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on return of sch-gds in frame {&FRAME-NAME} do: /* артикулу товара */
  {&SetCursorWait}
  assign sch-gds.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-gds in this-procedure ( input no,  input sch-gds ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on mouse-select-dblclick of sch-gds in frame {&FRAME-NAME} do: /* артикулу товара */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-gds <> sch-gds then do:
    assign sch-gds.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-gds in this-procedure ( input yes, input sch-gds ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on CTRL-J of sch-prt in frame {&FRAME-NAME} do: /* номенклатурному номеру */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-prt <> sch-prt then do:
    assign sch-prt.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-prt in this-procedure ( input yes, input sch-prt ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on return of sch-prt in frame {&FRAME-NAME} do: /* номенклатурному номеру */
  {&SetCursorWait}
  assign sch-prt.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-prt in this-procedure ( input no,  input sch-prt ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on mouse-select-dblclick of sch-prt in frame {&FRAME-NAME} do: /* номенклатурному номеру */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-prt <> sch-prt then do:
    assign sch-prt.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-prt in this-procedure ( input yes, input sch-prt ) no-error.
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

      {&sort-clmn_2-br-dtl}:visible in browse {&browse-name} = false .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :

  p-host-code = v-cntxt-host-code-obj .
  if lookup( p-mode, '{&bef-all},obj,doc,gds,one':U ) = 0 then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    return.
  end. /* p-mode */
  if p-mode = 'obj':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.obj-type = p-prod-type and
               buf_sch_hist.obj-code = p-prod-code no-error.
    if not available buf_sch_hist then do:
    end.
  end. /* p-mode = 'obj':U */
  if p-mode = 'doc':U or
     p-mode = 'gds':U or
     p-mode = 'one':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.doc-code = p-doc-code no-error.
    if not available buf_sch_hist then do:
    end.
  end. /* p-mode = 'doc':U */
  if p-mode = 'gds':U or
     p-mode = 'one':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.doc-code  = p-doc-code  and
               buf_sch_hist.artic     = p-artic     and
               buf_sch_hist.prod-type = p-prod-type and
               buf_sch_hist.prod-code = p-prod-code no-error.
    if not available buf_sch_hist then do:
    end.
  end. /* p-mode = 'gds':U */
  if p-mode = 'one':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.doc-code  = p-doc-code  and
               buf_sch_hist.artic     = p-artic     and
               buf_sch_hist.prod-type = p-prod-type and
               buf_sch_hist.prod-code = p-prod-code and
               buf_sch_hist.prt-code  = p-prt-code  no-error.
    if not available buf_sch_hist then do:
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

  /* display sch-doc sch-gds sch-prt sch-num mark-num br-changes {&BROWSE-NAME} with frame {&FRAME-NAME}. */
  enable  b-mark   when lookup( "b-mark":U,   p-bttns ) > 0 or p-bttns = "*"
          b-sel when lookup( "b-sel":U, p-bttns ) > 0 or p-bttns = "*"
          b-sch b-help b-Exit  {&BROWSE-NAME}
            br-changes    sch-doc   sch-gds    sch-prt
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

  &scop flt-open-open-query         open query {&BROWSE-NAME} for each buf_history
  &scop flt-open-dyn_open-query  FOR EACH buf_history
  &scop flt-open-query-handle query {&BROWSE-NAME}:handle
  &scop flt-open-find-buffer-name  buf_history
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
  &scop flt-open-find-buffer-def    define buffer buf_history for ub.c-gds-dtl.
  &scop flt-open-waitfram           yes

  define variable l-open-query as logical no-undo.

  assign filter-point = filter-point0 + " - " + p-mode.

      {&SetCursorWait}
      assign frame {&FRAME-NAME} :title = title0 +
        substitute( 'детализации строки (артикул: &1, произв.: &2 &3) документа &4 по признакам',
                    p-artic, p-prod-type, p-prod-code, p-doc-code ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_history.doc-code  = p-doc-code  and ~
                          buf_history.artic     = p-artic     and ~
                          buf_history.prod-type = p-prod-type and ~
                          buf_history.prod-code = p-prod-code ~
                        "
          &dyn_where-cond =
                         "  substitute ( ' ~
                          buf_history.doc-code &1&2&1  =  and ~
                          buf_history.artic    &1&3&1  =  and ~
                          buf_history.prod-type &1&4&1 =  and ~
                          buf_history.prod-code  &5    =  ' ~
                          , ~{&double-quote~} ~
                          , p-doc-code        ~
                          , p-artic           ~
                          , p-prod-type       ~
                          , p-prod-code )     ~
                        "

          &use-ind    = "  "
          &by         = "  "                                      }
  {&SetCursorWait}
  if p-open-query <> yes then do: reposition {&BROWSE-NAME} to recid doc-rec no-error. end.
  run WaitFram-Hide in this-procedure.
  apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  apply "ENTRY":U         to {&BROWSE-NAME} in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* OpenBr */

procedure proc-filter :
  &scop  common     input-output fld, input-output lab, input-output spr, input-output dim
  &scop  cli        obj-type{&delim-flt}obj-code
  &scop  prod       prod-type{&delim-flt}prod-code

  assign tbl      = 'c-gds-dtl'
         join-tbl = 'buf_history'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.

  {&SetCursorWait}
  run fltfield-add in this-procedure ( input 'doc-code',    input 'Номер накладной',      input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'artic',       input 'Артикул',              input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'prod-type',   input 'Тип производителя',    input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'prod-code',   input 'Код производителя',    input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input '{&prod}',     input 'Производитель',        input 'cli':U, {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'prt-code',    input 'Номенклатурный номер', input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'obj-type',    input 'Тип объекта',          input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'obj-code',    input 'Код объекта',          input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input '{&cli}',      input 'Объект',               input 'cli':U, {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'fact-qnty',   input 'Факт количество',      input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'doc-qnty',    input 'Кол-во по документу',  input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'price-rubl',  input 'Цена ({&abbr_rub})',   input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'price-base',  input 'Цена (б.в.)',          input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'discnt-rubl', input 'Скидка ({&abbr_rub})', input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'discnt-base', input 'Скидка (б.в.)',        input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'VAT-rubl',    input 'НДС ({&abbr_rub})',    input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'VAT-base',    input 'НДС (б.в.)',           input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'discnt-pc',   input 'Скидка',               input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'discnt-type', input 'Процент',              input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'ov',          input 'Переоценка',           input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'cur-base',    input 'Прод. цена',           input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'doc-date',    input 'Дата',                 input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'chip-num',    input 'Щепка',                input '':U,    {&common} ) no-error.

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
  define buffer new_hist for ub.c-gds-dtl .
  define buffer buf_srch for ub.gds-dtl .

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
             new_hist.prt-code  = buf_history.prt-code  and
             new_hist.chip-num  > buf_history.chip-num  no-error.
  if not available new_hist then do:
    find first buf_srch no-lock where
               buf_srch.doc-code  = buf_history.doc-code  and
               buf_srch.artic     = buf_history.artic     and
               buf_srch.prod-type = buf_history.prod-type and
               buf_srch.prod-code = buf_history.prod-code and
               buf_srch.prt-code  = buf_history.prt-code  no-error.
    if not available buf_srch then do: return error. end.
    buffer-compare buf_srch to buf_history save result in v-chg-fields.
  end.
  else do:
    buffer-compare new_hist
            except chip-num VAT-rubl VAT-base doc-date
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
      &scop field-label "Тип производит."
      {&disp-field}
      &scop field-name  prod-code
      &scop field-label "Код производит."
      {&disp-field}
      &scop field-name  artic
      &scop field-label "Артикул"
      {&disp-field}
      &scop field-name  obj-type
      &scop field-label "Тип объекта"
      {&disp-field}
      &scop field-name  obj-code
      &scop field-label "Код объекта"
      {&disp-field}
      &scop field-name  prt-code
      &scop field-label "Номенклатур.н-р"
      {&disp-field}
      &scop field-name  fact-qnty
      &scop field-label "Факт количество"
      {&disp-field}
      &scop field-name  doc-qnty
      &scop field-label "Кол-во по док."
      {&disp-field}
      &scop field-name  doc-code
      &scop field-label "Номер накладной"
      {&disp-field}
      &scop field-name  price-rubl
      &scop field-label "Цена ({&abbr_rub})"
      {&disp-field}
      &scop field-name  price-base
      &scop field-label "Цена (баз.вал.)"
      {&disp-field}
      &scop field-name  discnt-rubl
      &scop field-label "Скидка ({&abbr_rub})"
      {&disp-field}
      &scop field-name  discnt-base
      &scop field-label "Скидка (б.в.)"
      {&disp-field}
      &scop field-name  discnt-pc
      &scop field-label "Скидка"
      {&disp-field}
      &scop field-name  discnt-type
      &scop field-label "Процент"
      {&disp-field}
      &scop field-name  ov
      &scop field-label "Переоценка"
      {&disp-field}
      &scop field-name  cur-base
      &scop field-label "Прод. цена"
      {&disp-field}
    end case. /* entry */
  end. /* jj */
  run OpenChanges in this-procedure ( input yes, input no, input '':U ).
end procedure. /* proc-view-changes */

procedure OpenChanges :
  define input parameter p-open-query     as logical   no-undo.
  define input parameter p-find-next      as logical   no-undo.
  define input parameter p-find-condition as character no-undo.

  {&SetCursorWait}
  /* run WaitFram-Show in this-procedure ( input "Ждите..." ). */

  {&SetCursorWait}
  open query br-changes for each buf_changes .
  {&SetCursorWait}
  if p-open-query <> yes then do: reposition {&BROWSE-NAME} to recid doc-rec no-error. end.
  run WaitFram-Hide in this-procedure.
  {&SetCursorNo}
end procedure. /* OpenChanges */

{ gbl/setfltnm.i }

procedure proc-find-doc :
  define input parameter p-next as logical   no-undo.
  define input parameter p-code as character no-undo.

  {&SetCursorWait}
  assign p-code = replace( p-code, {&double-quote}, {&double-quote} + {&double-quote} )
         p-code = replace( p-code, {&single-quote}, {&single-quote} + {&single-quote} )
         p-code = {&double-quote} + p-code + {&double-quote}.
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_history.doc-code begins &1 ", p-code ) ).
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
  apply "ENTRY":U to sch-doc in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-doc */

procedure proc-find-gds :
  define input parameter p-next  as logical   no-undo.
  define input parameter p-artic as character no-undo.

  {&SetCursorWait}
  assign p-artic = replace( p-artic, {&double-quote}, {&double-quote} + {&double-quote} )
         p-artic = replace( p-artic, {&single-quote}, {&single-quote} + {&single-quote} )
         p-artic = {&double-quote} + p-artic + {&double-quote}.
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_history.artic begins &1 ", p-artic ) ).
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
  apply "ENTRY":U to sch-gds in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-gds */

procedure proc-find-prt :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer no-undo.

  {&SetCursorWait}
  run OpenBr in this-procedure ( input no, input p-next, input substitute( " and buf_history.prt-code = &1 ", p-code ) ).
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
  apply "ENTRY":U to sch-prt in frame {&FRAME-NAME}.
  {&SetCursorNo}
end procedure. /* proc-find-prt */

procedure get-mark-string :
  define        parameter buffer loc-buf for ub.c-gds-dtl.
  define output parameter        p-sign  as  character no-undo.

  assign p-sign = ( if lookup( Rec2Char( recid( loc-buf ) ), p-rid-list ) > 0 then chr( 42 ) else chr( 32 ) ).
end procedure. /* get-mark-string */

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
  assign p-name = ( if available buf_clients then buf_clients.obj-name else "":U ).
end procedure. /* get-obj-full-name */

procedure get-goods-name :
  define        parameter buffer loc-buf for ub.c-gds-dtl.
  define output parameter        p-name  as  character no-undo.

  define buffer buf_goods for ub.goods.

  find first buf_goods no-lock where
             buf_goods.artic     = loc-buf.artic     and
             buf_goods.prod-type = loc-buf.prod-type and
             buf_goods.prod-code = loc-buf.prod-code no-error.
  assign p-name = ( if available buf_goods then buf_goods.gds-name else "":U ).
end procedure. /* get-goods-name */