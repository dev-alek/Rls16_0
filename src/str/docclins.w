/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История изменения строк документов

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

Create: Булгаков Андрей Николаевич


*/

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */

&scop FRAME-NAME  fr-D-doc-line-0
&scop BROWSE-NAME br-doc-lines
&scop f-l         Int2Char,Rec2Char
&scop sch-flt     + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
&scop description 'История изменения строк документов':U
&scop n-s         "NEW SHARED"

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter ParParentProc as widget-handle no-undo.
define input        parameter p-bttns       as character     no-undo.
define input        parameter p-mode        as character     no-undo. /* м.б.: {&all},obj,gds,doc,one */
define input        parameter p-obj-type    as character     no-undo.
define input        parameter p-obj-code    as integer       no-undo.
define input        parameter p-doc-code    as character     no-undo.
define input        parameter p-artic       as character     no-undo.
define input        parameter p-prod-type   as character     no-undo.
define input        parameter p-prod-code   as integer       no-undo.
define input-output parameter p-rid-list    as character     no-undo. /* записи в выборке */
/*
message 'p-bttns    ' p-bttns       skip
        'p-mode     ' p-mode        skip
        'p-obj-type ' p-obj-type    skip
        'p-obj-code ' p-obj-code    skip
        'p-doc-code ' p-doc-code    skip
        'p-artic    ' p-artic       skip
        'p-prod-type' p-prod-type   skip
        'p-prod-code' p-prod-code   skip
        .
  */
/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "История строк документов":U.

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ cmp/showinf.i         }
{ gbl/flt-def.i         }
{ gbl/waitfram.i        }
{ gbl/fltfield.i        }
{ gbl/std-func.i {&f-l} }
{ ref/tmpchgs.i  "NEW SHARED" }
{ gbl/fltopend.i defproc }

define new shared buffer buf_changes  for temp-changes.
define new shared buffer buf_history  for ub.c-doc-line.
define            buffer buf_sch_hist for ub.c-doc-line.
define            buffer buf_source   for ub.doc-line.
define            buffer buf_object   for ub.clients.

define variable varr-b           as character no-undo.
define variable filter-point     as character no-undo initial {&description}.
define variable filter-point0    as character no-undo initial {&description}.
define variable sort-change-name as character no-undo.
define variable sort-column-name as character no-undo.
define variable sch-field        as character no-undo.
define variable FoundRec         as recid     no-undo.
define variable p-act-codes      as character no-undo initial {&hn-actions}.
define variable p-act-names      as character no-undo initial {&hn-actions-full}.
define variable p-host-code      as integer   no-undo.
define variable doc-rec          as recid     no-undo.

/* ************************  Function Prototypes ********************** */
function mark-string returns character ( buffer loc-buf for ub.c-doc-line ) :
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

function gds-name returns character ( buffer loc-buf for ub.c-doc-line ) :
  define variable v_gds-name as character no-undo.

  run get-goods-name in this-procedure ( buffer loc-buf, output v_gds-name ).
  return ( v_gds-name ).
end function. /* gds-name */

function eng-name returns character ( buffer loc-buf for ub.c-doc-line ) :
  define variable v_gds-name as character no-undo.

  run get-gds-eng-name in this-procedure ( buffer loc-buf, output v_gds-name ).
  return ( v_gds-name ).
end function. /* eng-name */

function unit-base returns character ( buffer loc-buf for ub.c-doc-line ) :
  define variable v_unit-base as character no-undo.

  run get-gds-unit-base in this-procedure ( buffer loc-buf, output v_unit-base ).
  return ( v_unit-base ).
end function. /* unit-base */

function sale-price returns decimal ( buffer loc-buf for ub.c-doc-line ) :
  define variable d_price as decimal no-undo.

  run get-sale-price in this-procedure ( buffer loc-buf, output d_price ).
  return ( d_price ).
end function. /* sale-price */

function per-cent returns decimal ( buffer loc-buf for ub.c-doc-line ) :
  define variable d_prc as decimal no-undo.

  run get-per-cent in this-procedure ( buffer loc-buf, output d_prc ).
  return ( d_prc ).
end function. /* per-cent */

function scala returns character ( buffer loc-buf for ub.c-doc-line ) :
  define variable v_scala as character no-undo.

  run get-gds-scale in this-procedure ( buffer loc-buf, output v_scala ).
  return ( v_scala ).
end function. /* scala */

function ext-type returns character ( input i-type as character ) :
  define variable v_ext-type as character no-undo.

  run get-ext-type in this-procedure ( input i-type, output v_ext-type ) no-error.
  return ( if error-status :error or v_ext-type = ? then "":U else v_ext-type ).
end function. /* ext-type */

/* Definitions for BROWSE {&BROWSE-NAME}                                */
&scop label-clmn_1-br-dtl  '*'
&scop form-clmn_1-br-dtl   'x(1)':U
&scop sort-clmn_1-br-dtl   mark-string( buffer buf_history )
&scop label-clmn_2-br-dtl  'Накладная'
&scop form-clmn_2-br-dtl   "x(16)":U
&scop sort-clmn_2-br-dtl   buf_history.doc-code
&scop label-clmn_3-br-dtl  'П/П'
&scop form-clmn_3-br-dtl   "->>>9":U
&scop sort-clmn_3-br-dtl   buf_history.line-num
&scop label-clmn_4-br-dtl  'Ш'
&scop form-clmn_4-br-dtl   "+/-":U
&scop sort-clmn_4-br-dtl   buf_history.prt-OK
&scop label-clmn_5-br-dtl  'Артикул'
&scop form-clmn_5-br-dtl   "x(16)":U
&scop sort-clmn_5-br-dtl   buf_history.artic
&scop label-clmn_6-br-dtl  'Наименование товара'
&scop form-clmn_6-br-dtl   "x(30)":U
&scop sort-clmn_6-br-dtl   gds-name( buffer buf_history )
&scop label-clmn_7-br-dtl  'По ТТН'
&scop form-clmn_7-br-dtl   "->>,>>>,>>9.<<<":U
&scop sort-clmn_7-br-dtl   buf_history.cli-qnty
&scop label-clmn_8-br-dtl  'Изм'
&scop form-clmn_8-br-dtl   "x(3)":U
&scop sort-clmn_8-br-dtl   buf_history.unit-cli
&scop label-clmn_9-br-dtl  'Цена поставщ. (вал)'
&scop form-clmn_9-br-dtl   "->>,>>>,>>>,>>9.999":U
&scop sort-clmn_9-br-dtl   buf_history.price-cli
&scop label-clmn_10-br-dtl 'Сумма пост.'
&scop form-clmn_10-br-dtl  "->>,>>>,>>>,>>>,>>9.99":U
&scop sort-clmn_10-br-dtl  ( buf_history.cli-qnty * buf_history.price-cli )
&scop label-clmn_11-br-dtl 'По документу (заявл.)'
&scop form-clmn_11-br-dtl  "->,>>>,>>>,>>>,>>9.999":U
&scop sort-clmn_11-br-dtl  buf_history.doc-qnty
&scop label-clmn_12-br-dtl 'Фактически'
&scop form-clmn_12-br-dtl  "->,>>>,>>>,>>>,>>9.999":U
&scop sort-clmn_12-br-dtl  buf_history.fact-qnty
&scop label-clmn_13-br-dtl 'Изм'
&scop form-clmn_13-br-dtl  "x(3)":U
&scop sort-clmn_13-br-dtl  unit-base( buffer buf_history )
&scop label-clmn_14-br-dtl 'Цена учет(прод.)'
&scop form-clmn_14-br-dtl  "->,>>>,>>>,>>>,>>9.99":U
&scop sort-clmn_14-br-dtl  ( if varr-b = 'rubl':U then buf_history.price-rubl else buf_history.price-base )
&scop label-clmn_15-br-dtl 'Цена продажи'
&scop form-clmn_15-br-dtl  "->,>>>,>>>,>>>,>>9.99":U
&scop sort-clmn_15-br-dtl  sale-price( buffer buf_history )
&scop label-clmn_16-br-dtl '%'
&scop form-clmn_16-br-dtl  "->>>,>>9.<<":U
&scop sort-clmn_16-br-dtl  per-cent( buffer buf_history )
&scop label-clmn_17-br-dtl 'Шкала'
&scop form-clmn_17-br-dtl  "x(10)":U
&scop sort-clmn_17-br-dtl  scala( buffer buf_history )
&scop label-clmn_18-br-dtl 'НДС'
&scop form-clmn_18-br-dtl  "->9.9<%":U
&scop sort-clmn_18-br-dtl  buf_history.VAT-pc
&scop label-clmn_19-br-dtl 'Наименование англ.'
&scop form-clmn_19-br-dtl  "x(40)":U
&scop sort-clmn_19-br-dtl  eng-name( buffer buf_history )
&scop label-clmn_20-br-dtl 'Кол-во мест'
&scop form-clmn_20-br-dtl  "->>>,>>9.99":U
&scop sort-clmn_20-br-dtl  buf_history.num-place
&scop label-clmn_21-br-dtl 'Вес брутто'
&scop form-clmn_21-br-dtl  "->>>,>>9.999":U
&scop sort-clmn_21-br-dtl  buf_history.wt-brutto
&scop label-clmn_22-br-dtl 'Производитель'
&scop form-clmn_22-br-dtl  "x(13)":U
&scop sort-clmn_22-br-dtl  obj-short( buf_history.prod-type, buf_history.prod-code )
&scop label-clmn_23-br-dtl 'Наименование производителя'
&scop form-clmn_23-br-dtl  "x(40)":U
&scop sort-clmn_23-br-dtl  obj-name( buf_history.prod-type, buf_history.prod-code )
&scop label-clmn_24-br-dtl 'Объект'
&scop form-clmn_24-br-dtl  "x(13)":U
&scop sort-clmn_24-br-dtl  obj-short( buf_history.obj-type, buf_history.obj-code )
&scop label-clmn_25-br-dtl 'Наименование объекта'
&scop form-clmn_25-br-dtl  "x(40)":U
&scop sort-clmn_25-br-dtl  obj-name( buf_history.obj-type, buf_history.obj-code )
&scop label-clmn_26-br-dtl 'НП'
&scop form-clmn_26-br-dtl  "->9.9<%":U
&scop sort-clmn_26-br-dtl  buf_history.SLT-pc
&scop label-clmn_27-br-dtl 'НДС конс'
&scop form-clmn_27-br-dtl  "->9.9<%":U
&scop sort-clmn_27-br-dtl  buf_history.cons-vat-pc
&scop label-clmn_28-br-dtl 'НП конс'
&scop form-clmn_28-br-dtl  "->9.9<%":U
&scop sort-clmn_28-br-dtl  buf_history.cons-slt-pc
&scop label-clmn_29-br-dtl 'Корень'
&scop form-clmn_29-br-dtl  "->>>>>>>>9":U
&scop sort-clmn_29-br-dtl  buf_history.prt-root
&scop label-clmn_30-br-dtl 'Коэффициент'
&scop form-clmn_30-br-dtl  "->>,>>9.<<<<":U
&scop sort-clmn_30-br-dtl  buf_history.cli-base-rate
&scop label-clmn_31-br-dtl 'Статус'
&scop form-clmn_31-br-dtl  "x(8)":U
&scop sort-clmn_31-br-dtl  buf_history.status_
&scop label-clmn_32-br-dtl 'Акциз'
&scop form-clmn_32-br-dtl  "->,>>>,>>>,>>9.99":U
&scop sort-clmn_32-br-dtl  buf_history.excise
&scop label-clmn_33-br-dtl 'Дорожный налог'
&scop form-clmn_33-br-dtl  "->,>>>,>>>,>>9.99":U
&scop sort-clmn_33-br-dtl  buf_history.road-tax
&scop label-clmn_34-br-dtl 'Трансп.расх.(б.в)'
&scop form-clmn_34-br-dtl  "->,>>>,>>9.99":U
&scop sort-clmn_34-br-dtl  buf_history.transport-base
&scop label-clmn_35-br-dtl 'Трансп.расх.({&abbr_rub})'
&scop form-clmn_35-br-dtl  "->,>>>,>>9.99":U
&scop sort-clmn_35-br-dtl  buf_history.transport-rubl
&scop label-clmn_36-br-dtl 'Прочие (б.в)'
&scop form-clmn_36-br-dtl  "->,>>>,>>9.99":U
&scop sort-clmn_36-br-dtl  buf_history.other-base
&scop label-clmn_37-br-dtl 'Прочие ({&abbr_rub})'
&scop form-clmn_37-br-dtl  "->,>>>,>>9.99":U
&scop sort-clmn_37-br-dtl  buf_history.other-rubl
&scop label-clmn_38-br-dtl 'Температура'
&scop form-clmn_38-br-dtl  "->>,>>9.99":U
&scop sort-clmn_38-br-dtl  buf_history.temperature
&scop label-clmn_39-br-dtl 'Плотность'
&scop form-clmn_39-br-dtl  ">>9.9999999999":U
&scop sort-clmn_39-br-dtl  buf_history.doc-density
&scop label-clmn_40-br-dtl 'Расширенный тип документа'
&scop form-clmn_40-br-dtl  "x(25)":U
&scop sort-clmn_40-br-dtl  ext-type( buf_history.ext-doc-type )
&scop label-clmn_41-br-dtl 'Щепка'
&scop form-clmn_41-br-dtl  "->,>>>,>>>,>>9":U
&scop sort-clmn_41-br-dtl  buf_history.chip-num
&scop enabled-clmn-br-dtl  {&sort-clmn_41-br-dtl}

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
define button b-help   label "Помо&щь"    size-chars  10    by 1.00 default.
define button b-mark   label "&*"         size-chars  3     by 1.00 default.
define button b-quit   label "Вы&ход"     size-chars  10    by 1.00 default auto-end-key.
define button b-Dtls   label "При&знаки"  size-chars  10 by 1.00 default.
define button b-sch    label "&Фильтр"    size-chars  10 by 1.00 default.
define button b-sel    label "Вы&бор"     size-chars  10 by 1.00 default auto-go.
define button b-petrol label "Топли&во"       size-chars  10 by 1.00 default .

define variable mark-num as integer   no-undo view-as fill-in size-chars  8.00 by 1.00 format "->>>,>>>":U.
define variable sch-doc  as character no-undo view-as fill-in size-chars 16.00 by 1.00 format "x(16)":U.
define variable sch-gds  as character no-undo view-as fill-in size-chars 16.00 by 1.00 format "x(16)":U.
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
  {&sort-clmn_24-br-dtl} column-label {&label-clmn_24-br-dtl} format {&form-clmn_24-br-dtl}
  {&sort-clmn_25-br-dtl} column-label {&label-clmn_25-br-dtl} format {&form-clmn_25-br-dtl}
  {&sort-clmn_26-br-dtl} column-label {&label-clmn_26-br-dtl} format {&form-clmn_26-br-dtl}
  {&sort-clmn_27-br-dtl} column-label {&label-clmn_27-br-dtl} format {&form-clmn_27-br-dtl}
  {&sort-clmn_28-br-dtl} column-label {&label-clmn_28-br-dtl} format {&form-clmn_28-br-dtl}
  {&sort-clmn_29-br-dtl} column-label {&label-clmn_29-br-dtl} format {&form-clmn_29-br-dtl}
  {&sort-clmn_30-br-dtl} column-label {&label-clmn_30-br-dtl} format {&form-clmn_30-br-dtl}
  {&sort-clmn_31-br-dtl} column-label {&label-clmn_31-br-dtl} format {&form-clmn_31-br-dtl}
  {&sort-clmn_32-br-dtl} column-label {&label-clmn_32-br-dtl} format {&form-clmn_32-br-dtl}
  {&sort-clmn_33-br-dtl} column-label {&label-clmn_33-br-dtl} format {&form-clmn_33-br-dtl}
  {&sort-clmn_34-br-dtl} column-label {&label-clmn_34-br-dtl} format {&form-clmn_34-br-dtl}
  {&sort-clmn_35-br-dtl} column-label {&label-clmn_35-br-dtl} format {&form-clmn_35-br-dtl}
  {&sort-clmn_36-br-dtl} column-label {&label-clmn_36-br-dtl} format {&form-clmn_36-br-dtl}
  {&sort-clmn_37-br-dtl} column-label {&label-clmn_37-br-dtl} format {&form-clmn_37-br-dtl}
  {&sort-clmn_38-br-dtl} column-label {&label-clmn_38-br-dtl} format {&form-clmn_38-br-dtl}
  {&sort-clmn_39-br-dtl} column-label {&label-clmn_39-br-dtl} format {&form-clmn_39-br-dtl}
  {&sort-clmn_40-br-dtl} column-label {&label-clmn_40-br-dtl} format {&form-clmn_40-br-dtl}
  {&sort-clmn_41-br-dtl} column-label {&label-clmn_41-br-dtl} format {&form-clmn_41-br-dtl}
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
    b-quit     at row  1 col  1
    b-mark     at row  1 col 11
    mark-num   at row  1 col 14 no-label                               fgcolor 4
    b-sel      at row  1 col 21
    b-Dtls     at row  1 col 71
    b-help     at row  1 col 91
    b-petrol   at row  2 col 81
    b-sch      at row  2 col 91

    {&BROWSE-NAME} at row  3.00 col  1.50
    "          ":U at row 16.5 col  1.62 view-as text size-chars 98.00 by 1.00
    "ПОИСК ПО:"    at row 16.5 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
    sch-doc        at row 16.5 col 12.50    label "&документу"
    sch-gds        at row 16.5 col 42.50    label "&артикулу"
    sch-num        at row 16.5 col 94.75 no-label                              fgcolor 4
    br-changes     at row 17.50 col  1.50
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
         b-Dtls     :tooltip in frame {&FRAME-NAME} = "Признаки текущего товара"
       b-sel  :tooltip in frame {&FRAME-NAME} = "Выбрать текущую(ие) запись(и)"
       {&BROWSE-NAME} :tooltip in frame {&FRAME-NAME} = "Список действий над строками накладных"
         br-changes   :tooltip in frame {&FRAME-NAME} = "Список изменений строки накладной"
         sch-doc      :tooltip in frame {&FRAME-NAME} = "Номер накладной" {&sch-flt}
         sch-gds      :tooltip in frame {&FRAME-NAME} = "Артикул товара" {&sch-flt}
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



on choose of b-petrol in frame {&FRAME-NAME} do:
  define variable v-list as character no-undo.
  { gbl/stdbtn.i }
  if not available buf_history then do:
    return no-apply.
  end.
  run str/invcline.w
  ( input ParParentProc,           /* parparentproc */
    input '':U,                    /* p-bttns       */
    input 'gds':U,                 /* p-mode        */
    input buf_history.obj-type ,   /* p-obj-type    */
    input buf_history.obj-code ,   /* p-obj-code    */
    input buf_history.doc-code ,   /* p-doc-code    */
    input buf_history.artic    ,   /* p-artic       */
    input buf_history.prod-type,   /* p-prod-type   */
    input buf_history.prod-code,   /* p-prod-code   */
    input-output v-list            /* p-rid-list    */
  ) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      ""
      view-as alert-box error
    .
end.




on choose of b-Dtls in frame {&FRAME-NAME} do: /* Признаки */
  define variable v-list as character no-undo.

  { gbl/stdbtn.i }
  if not available buf_history then do:
    message "Неправильно выбрана строка." view-as alert-box error.
    return no-apply.
  end.
  run str/gdscdtls.w ( input        ParParentProc,
                   input        '':U,
                   input        'gds':U,
                   input        buf_history.doc-code,
                   input        buf_history.artic,
                   input        buf_history.prod-type,
                   input        buf_history.prod-code,
                   input        ?,
                   input-output v-list                 ).
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
  assign  sch-gds :screen-value in frame {&FRAME-NAME} = "":U.
  display sch-doc with frame {&FRAME-NAME}.
end.

on entry of sch-gds in frame {&FRAME-NAME} do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  assign  sch-doc :screen-value in frame {&FRAME-NAME} = "":U.
  display sch-gds with frame {&FRAME-NAME}.
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


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  { gbl/curr-r-b.i varr-b }
  if lookup( p-mode, '{&bef-all},obj,gds,doc,one':U ) = 0 then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    return.
  end. /* p-mode */

  if p-mode = 'obj':U or
     p-mode = 'gds':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.obj-type = p-prod-type and
               buf_sch_hist.obj-code = p-prod-code no-error.
    if not available buf_sch_hist then do:

    end.
  end. /* p-mode = 'obj':U */
  if p-mode = 'gds':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.obj-type  = p-obj-type  and
               buf_sch_hist.obj-code  = p-obj-code  and
               buf_sch_hist.artic     = p-artic     and
               buf_sch_hist.prod-type = p-prod-type and
               buf_sch_hist.prod-code = p-prod-code no-error.
    if not available buf_sch_hist then do:

    end.
  end. /* p-mode = 'gds':U */
  if p-mode = 'doc':U or
     p-mode = 'one':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.doc-code = p-doc-code no-error.
    if not available buf_sch_hist then do:

    end.
  end. /* p-mode = 'doc':U */
  if p-mode = 'one':U then do:
    find first buf_sch_hist no-lock where
               buf_sch_hist.doc-code  = p-doc-code  and
               buf_sch_hist.artic     = p-artic     and
               buf_sch_hist.prod-type = p-prod-type and
               buf_sch_hist.prod-code = p-prod-code no-error.
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

  /* display sch-doc sch-gds sch-num mark-num br-changes {&BROWSE-NAME} with frame {&FRAME-NAME}. */
  define buffer buf_goods for ub.goods .


  enable  b-mark when lookup( "b-mark":U, p-bttns ) > 0 or p-bttns = "*"
          b-sel  when lookup( "b-sel":U,  p-bttns ) > 0 or p-bttns = "*"
          b-sch b-help b-quit  sch-doc    sch-gds
          b-Dtls {&BROWSE-NAME} br-changes
          b-petrol
  with frame {&FRAME-NAME}.

      if not can-find ( first ub.c-gds-dtl no-lock where
                              ub.c-gds-dtl.doc-code  = p-doc-code
                              ) then
         disable b-Dtls with frame {&frame-name} .





      if not can-find ( first ub.c-inv-line no-lock where
                              ub.c-inv-line.doc-code  = p-doc-code
                              ) then
         disable b-Petrol with frame {&frame-name} .

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
  &scop flt-open-dyn_open-query     FOR EACH buf_history
  &scop flt-open-query-handle       query {&BROWSE-NAME}:handle
  &scop flt-open-find-buffer-name   buf_history
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
  &scop flt-open-find-buffer-def    define buffer buf_history for ub.c-doc-line.
  &scop flt-open-waitfram           yes

  define variable l-open-query as logical no-undo.

  assign filter-point = filter-point0 + " - " + p-mode.

  case p-mode :
    when {&all}  then do:
      {&SetCursorWait}
      assign frame {&FRAME-NAME} :title = title0 + "строк документов".
      { gbl/fltopend.i
          &where-cond = " true "
          &dyn_where-cond = " 'true' "
          &use-ind    = "  "
          &by         = "  "  }
    end. /* {&all} */
    when 'obj':U then do:
      {&SetCursorWait}
      assign frame {&FRAME-NAME} :title = title0 +
        substitute( 'строк документов по объекту &1 &2 "&3"',
                    p-obj-type, p-obj-code, obj-name( p-obj-type, p-obj-code ) ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_history.obj-type = p-obj-type and ~
                          buf_history.obj-code = p-obj-code ~
                        "
          &dyn_where-cond = " ~
                          substitute( '  ~
                          buf_history.obj-type = &1&2&1 and ~
                          buf_history.obj-code = &3 ' ~
                          , ~{&double-quote~} ~
                          , p-obj-type    ~
                          , p-obj-code )  ~
                        "

          &use-ind    = "  "
          &by         = "  "
          }
    end. /* 'obj':U */
    when 'gds':U then do:
      {&SetCursorWait}
      assign frame {&FRAME-NAME} :title = title0 +
        substitute( 'строк (артикул: &1, произв.: &2 &3) документов по объекту &4 &5 "&6"',
                    p-prod-type, p-prod-code, obj-name( p-prod-type, p-prod-code ),
                    p-obj-type,  p-obj-code,  obj-name( p-obj-type,  p-obj-code  ) ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_history.obj-type  = p-obj-type  and ~
                          buf_history.obj-code  = p-obj-code  and ~
                          buf_history.artic     = p-artic     and ~
                          buf_history.prod-type = p-prod-type and ~
                          buf_history.prod-code = p-prod-code ~
                        "
          &dyn_where-cond = " ~
                          substitute( '  ~
                          buf_history.obj-type = &1&2&1 and ~
                          buf_history.obj-code = &3  ~
                          buf_history.artic     = &1&4&1 and ~
                          buf_history.prod-type = &1&5&1 and ~
                          buf_history.prod-code = &6 ' ~
                          , ~{&double-quote~} ~
                          , p-obj-type    ~
                          , p-obj-code  ~
                          , p-artic     ~
                          , p-prod-type ~
                          , p-prod-code ~
                          )  ~
                        "

          &use-ind    = "  "
          &by         = "  "                                      }
    end. /* 'gds':U */
    when 'doc':U then do:
      {&SetCursorWait}
      assign frame {&FRAME-NAME} :title = title0 + substitute( 'строк документа "&1"', p-doc-code ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_history.doc-code = p-doc-code ~
                        "
          &dyn_where-cond = " ~
                          substitute( '  uf_history.doc-code = &1&2&1 ' ~
                          , ~{&double-quote~} ~
                          , p-doc-code    ~
                          )  ~
                        "

          &use-ind    = "  "
          &by         = "  "                                    }
    end. /* 'doc':U */
    when 'one':U then do:
      {&SetCursorWait}
      assign frame {&FRAME-NAME} :title = title0 +
        substitute( 'строки (артикул: &1, произв.: &2 &3) документа &4', p-artic, p-prod-type, p-prod-code, p-doc-code ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_history.doc-code  = p-doc-code  and ~
                          buf_history.artic     = p-artic     and ~
                          buf_history.prod-type = p-prod-type and ~
                          buf_history.prod-code = p-prod-code ~
                        "
          &dyn_where-cond = " ~
                          substitute( ' ~
                          buf_history.doc-code  = &1&2&1 and ~
                          buf_history.artic     = &1&3&1 and ~
                          buf_history.prod-type = &1&4&1 and ~
                          buf_history.prod-code = &5 ' ~
                          , ~{&double-quote~} ~
                          , p-doc-code  ~
                          , p-artic     ~
                          , p-prod-type ~
                          , p-prod-code ~
                          )  ~
                        "
          &use-ind    = "  "
          &by         = "  "                                      }
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
  &scop  common     input-output fld, input-output lab, input-output spr, input-output dim
  &scop  cli        obj-type{&delim-flt}obj-code
  &scop  prod       prod-type{&delim-flt}prod-code

  assign tbl      = 'c-doc-line'
         join-tbl = 'buf_history'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.

  {&SetCursorWait}
  run fltfield-add in this-procedure ( input 'fact-qnty',      input 'Факт кол-во',          input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'price-rubl',     input 'Цена ({&abbr_rub})',   input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'price-base',     input 'Цена (баз.вал)',       input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'price-cli',      input 'Цена пост. (вал)',     input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'unit-cli',       input 'Ед.изм.пост-ка',       input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'cli-qnty',       input 'По ТТН',               input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'doc-qnty',       input 'Кол-во по док-ту',     input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'obj-type',       input 'Тип объекта',          input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'obj-code',       input 'Код объекта учета',    input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input '{&cli}',         input 'Объект',               input 'cli':U, {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'prod-type',      input 'Тип производителя',    input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'prod-code',      input 'Код производителя',    input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input '{&prod}',        input 'Производитель',        input 'cli':U, {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'artic',          input 'Артикул',              input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'doc-code',       input 'Номер',                input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'cli-base-rate',  input 'Коэффициент',          input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'prt-root',       input 'root',                 input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'prt-OK',         input 'Шкала',                input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'VAT-pc',         input 'НДС',                  input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'status_',        input 'Статус',               input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'SLT-pc',         input 'Налог с продаж',       input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'line-num',       input 'Номер',                input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'wt-brutto',      input 'Вес брутто',           input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'num-place',      input 'Количество мест',      input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'road-tax',       input 'Дорожный налог',       input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'excise',         input 'Акциз',                input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'doc-density',    input 'Плотность',            input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'temperature',    input 'Температура',          input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'transport-base', input 'Трансп.(б.в.)',        input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'transport-rubl', input 'Трансп.({&abbr_rub})', input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'other-base',     input 'Прочие (б.в.)',        input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'other-rubl',     input 'Прочие ({&abbr_rub})', input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'ext-doc-type',   input 'Расш.тип',             input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'fact-order',     input 'Факт-ордер',           input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'chip-num',       input 'Щепка',                input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'cons-vat-pc',    input 'НДС конс',             input '':U,    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'cons-slt-pc',    input 'НП конс',              input '':U,    {&common} ) no-error.

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
    run gbl/filter.w ( input ParParentProc,
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
  define buffer new_hist for ub.c-doc-line.
  define buffer buf_srch for ub.doc-line.

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
    find first buf_srch no-lock where
               buf_srch.doc-code  = buf_history.doc-code  and
               buf_srch.artic     = buf_history.artic     and
               buf_srch.prod-type = buf_history.prod-type and
               buf_srch.prod-code = buf_history.prod-code no-error.
    if not available buf_srch then do: return error. end.
    buffer-compare buf_srch                 to buf_history save result in v-chg-fields.
  end.
  else do:
    buffer-compare new_hist except chip-num to buf_history save result in v-chg-fields.
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
      &scop field-name  cli-qnty
      &scop field-label "По ТТН"
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
      &scop field-name  price-cli
      &scop field-label "Цена пост.(б.в)"
      {&disp-field}
      &scop field-name  unit-cli
      &scop field-label "Ед.изм.пост-ка"
      {&disp-field}
      &scop field-name  cli-base-rate
      &scop field-label "Коэффициент"
      {&disp-field}
      &scop field-name  prt-root
      &scop field-label "Корень"
      {&disp-field}
      &scop field-name  prt-OK
      &scop field-label "Шкала"
      {&disp-field}
      &scop field-name  VAT-pc
      &scop field-label "НДС"
      {&disp-field}
      &scop field-name  status_
      &scop field-label "Статус"
      {&disp-field}
      &scop field-name  SLT-pc
      &scop field-label "Налог с продаж"
      {&disp-field}
      &scop field-name  line-num
      &scop field-label "Номер"
      {&disp-field}
      &scop field-name  wt-brutto
      &scop field-label "Вес брутто"
      {&disp-field}
      &scop field-name  num-place
      &scop field-label "Кол-во мест"
      {&disp-field}
      &scop field-name  road-tax
      &scop field-label "Дор. налог"
      {&disp-field}
      &scop field-name  excise
      &scop field-label "Акциз"
      {&disp-field}
      &scop field-name  doc-density
      &scop field-label "Плотность"
      {&disp-field}
      &scop field-name  temperature
      &scop field-label "Температура"
      {&disp-field}
      &scop field-name  transport-base
      &scop field-label "Трансп.(б.в.)"
      {&disp-field}
      &scop field-name  transport-rubl
      &scop field-label "Трансп.({&abbr_rub})"
      {&disp-field}
      &scop field-name  other-base
      &scop field-label "Прочие (б.в.)"
      {&disp-field}
      &scop field-name  other-rubl
      &scop field-label "Прочие ({&abbr_rub})"
      {&disp-field}
      &scop field-name  ext-doc-type
      &scop field-label "Расш.тип"
      {&disp-field}
      &scop field-name  fact-order
      &scop field-label "Факт-ордер"
      {&disp-field}
      &scop field-name  cons-vat-pc
      &scop field-label "НДС конс"
      {&disp-field}
      &scop field-name  cons-slt-pc
      &scop field-label "НП конс"
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


  {&SetCursorWait}
  /* run WaitFram-Show in this-procedure ( input "Ждите..." ). */
  ASSIGN p-proc-hand = this-procedure :handle.

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

procedure get-mark-string :
  define        parameter buffer loc-buf for ub.c-doc-line.
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
  define        parameter buffer loc-buf for ub.c-doc-line.
  define output parameter        p-name  as  character no-undo.

  define buffer buf_goods for ub.goods.

  find first buf_goods no-lock where
             buf_goods.artic     = loc-buf.artic     and
             buf_goods.prod-type = loc-buf.prod-type and
             buf_goods.prod-code = loc-buf.prod-code no-error.
  assign p-name = ( if available buf_goods then buf_goods.gds-name else "":U ).
end procedure. /* get-goods-name */

procedure get-gds-eng-name :
  define        parameter buffer loc-buf for ub.c-doc-line.
  define output parameter        p-name  as  character no-undo.

  define buffer buf_goods for ub.goods.

  find first buf_goods no-lock where
             buf_goods.artic     = loc-buf.artic     and
             buf_goods.prod-type = loc-buf.prod-type and
             buf_goods.prod-code = loc-buf.prod-code no-error.
  assign p-name = ( if available buf_goods then buf_goods.engl-name else "":U ).
end procedure. /* get-gds-eng-name */

procedure get-gds-unit-base :
  define        parameter buffer loc-buf for ub.c-doc-line.
  define output parameter        p-name  as  character no-undo.

  define buffer buf_goods for ub.goods.

  find first buf_goods no-lock where
             buf_goods.artic     = loc-buf.artic     and
             buf_goods.prod-type = loc-buf.prod-type and
             buf_goods.prod-code = loc-buf.prod-code no-error.
  assign p-name = ( if available buf_goods then buf_goods.unit-base else "":U ).
end procedure. /* get-gds-unit-base */

procedure get-sale-price :
  define        parameter buffer loc-buf for ub.c-doc-line.
  define output parameter        p-price as  decimal no-undo initial 0.

  define buffer buf_gds-dtl for ub.c-gds-dtl.

  for each buf_gds-dtl no-lock where
           buf_gds-dtl.chip-num  = loc-buf.chip-num  and
           buf_gds-dtl.doc-code  = loc-buf.doc-code  and
           buf_gds-dtl.artic     = loc-buf.artic     and
           buf_gds-dtl.prod-type = loc-buf.prod-type and
           buf_gds-dtl.prod-code = loc-buf.prod-code :
    assign p-price = p-price + ( if varr-b = "rubl":U then buf_gds-dtl.price-rubl else buf_gds-dtl.price-base ).
  end. /* for each buf_gds-dtl */
end procedure. /* get-sale-price */

procedure get-per-cent :
  define        parameter buffer loc-buf for ub.c-doc-line.
  define output parameter        p-prc   as  decimal no-undo initial 0.

  define variable d_price as decimal no-undo initial 0.

  assign d_price = ( if varr-b = 'rubl':U then loc-buf.price-rubl else loc-buf.price-base )
         p-prc   = ( sale-price( buffer buf_history ) - d_price ) * 100 / d_price.
end procedure. /* get-per-cent */

procedure get-gds-scale :
  define        parameter buffer loc-buf for ub.c-doc-line.
  define output parameter        p-scale as  character no-undo.

  define buffer buf_goods   for ub.goods.
  define buffer buf_gds-prt for ub.gds-prt.
  define buffer buf_gds-dtl for ub.c-gds-dtl.

  find first buf_goods no-lock where
             buf_goods.artic     = loc-buf.artic     and
             buf_goods.prod-type = loc-buf.prod-type and
             buf_goods.prod-code = loc-buf.prod-code no-error.
  if available buf_goods then do:
    find first buf_gds-prt no-lock where
               buf_gds-prt.upper-code = buf_goods.prt-root no-error.
    if available buf_gds-prt then do:
      assign p-scale = ( if buf_gds-prt.node-name = {&empty-scale} then '-' else
                       ( if can-find( first buf_gds-dtl no-lock where
                                            buf_gds-dtl.doc-code  = loc-buf.doc-code      and
                                            buf_gds-dtl.artic     = loc-buf.artic         and
                                            buf_gds-dtl.prod-type = loc-buf.prod-type     and
                                            buf_gds-dtl.prod-code = loc-buf.prod-code     and
                                            buf_gds-dtl.prt-code  = buf_gds-prt.node-code and
                                            buf_gds-dtl.chip-num  = loc-buf.chip-num )
                         then '--------------------' else buf_gds-prt.node-name ) ).
    end. /* if available buf_gds-prt */
  end. /* if available buf_goods */
end procedure. /* get-gds-scale */

procedure get-ext-type :
  define  input parameter p-type as character no-undo.
  define output parameter p-name as character no-undo.

  define variable jndex as integer no-undo.

  assign jndex  = lookup( p-type, {&TDEDT_List} ).
  assign p-name = ( if jndex = 0 then "":U else entry( jndex, {&TDEDT_List-full} ) ).
end procedure. /* get-ext-type */