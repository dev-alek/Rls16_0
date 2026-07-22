/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список истории изменения сверок

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/11/08
Author: Dmitry Ukhanov
Creation date: 03/11/08

Автор1: Булгаков Андрей Николаевич
Дата создания1: 06/23/05

*/

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */
&scop FRAME-NAME  fr-D-rvs-doc-0
&scop BROWSE-NAME br-rvs-docs

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter parparentproc as widget-handle no-undo.
define input        parameter p-bttns       as character     no-undo.
define input        parameter p-mode        as character     no-undo. /* может быть {&all}, "one" */
define input        parameter p-rvs-code    as character     no-undo.
define input-output parameter p-rid-list    as character     no-undo. /* статьи в выборке */

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Список истории изменения сверок":U.

{ cmp/vssrevis.i                   }
{ cmp/str-glbl.i                   }
{ cmp/showinf.i                    }
{ gbl/flt-def.i                    }
{ gbl/waitfram.i                   }
{ gbl/fltfield.i                   }
{ gbl/std-func.i Int2Char,Rec2Char }
{ cmp/library.i                    }
{ gbl/getcntxt.i def               }
{ gbl/getcntxt.i get               }
{ gbl/fltopend.i defproc           }
{ ref/tmpchgs.i " " " " "with-action" }

define buffer buf_changes  for temp-changes.
define buffer buf_c-rvs-doc  for ub.c-rvs-doc.
define buffer buf_sch_hist for ub.c-rvs-doc.
define buffer buf_source   for ub.c-rvs-doc.

define variable filter-point     as character no-undo.
define variable filter-point0    as character no-undo.
define variable sort-change-name as character no-undo.
define variable sort-column-name as character no-undo.
define variable sch-field        as character no-undo.
define variable FoundRec         as recid     no-undo.
define variable p-act-codes      as character no-undo initial {&hn-actions}.
define variable p-act-names      as character no-undo initial {&hn-actions-full}.
define variable doc-rec          as recid     no-undo.
define variable p-host-code      as integer   no-undo.

assign
  filter-point  = vss-description
  filter-point0 = vss-description
.

/* ************************  Function Prototypes ********************** */
function mark-string returns character ( buffer loc-buf for ub.c-rvs-doc ) :
  define variable v_mark-sign as character no-undo.

  run get-mark-string in this-procedure ( buffer loc-buf, output v_mark-sign ).
  return ( v_mark-sign ).
end function. /* mark-string */

function ShowAction returns character ( input i-act as integer ) :
  define variable v_act as character no-undo.

  run get-action-name in this-procedure ( input i-act, output v_act ).
  return ( v_act ).
end function. /* ShowAction */

function obj-name returns character ( input i-type as character, input i-code as integer ) :
  define variable v_obj-name as character no-undo.

  run get-obj-name in this-procedure ( input i-type, input i-code, output v_obj-name ).
  return ( v_obj-name ).
end function. /* obj-name */

/* Definitions for BROWSE {&BROWSE-NAME}                                */
&scop label-clmn_1-br-dtl  '*'
&scop form-clmn_1-br-dtl   'x(1)':U
&scop sort-clmn_1-br-dtl   mark-string(buffer buf_c-rvs-doc )
&scop label-clmn_2-br-dtl  ' Tип '
&scop form-clmn_2-br-dtl   'x(9)':U
&scop sort-clmn_2-br-dtl   substring(buf_c-rvs-doc.rvs-type,1,9)
&scop label-clmn_3-br-dtl  ' '
&scop form-clmn_3-br-dtl   'п/ ':U
&scop sort-clmn_3-br-dtl   buf_c-rvs-doc.is-full
&scop label-clmn_4-br-dtl  'Стат'
&scop form-clmn_4-br-dtl   'x(5)':U
&scop sort-clmn_4-br-dtl   buf_c-rvs-doc.status_
&scop label-clmn_5-br-dtl  'Документ'
&scop form-clmn_5-br-dtl   'x(12)':U
&scop sort-clmn_5-br-dtl   buf_c-rvs-doc.rvs-code
&scop label-clmn_6-br-dtl  'Дата док'
&scop form-clmn_6-br-dtl   '99/99/99':U
&scop sort-clmn_6-br-dtl   buf_c-rvs-doc.doc-date
&scop label-clmn_7-br-dtl  'Дата факт'
&scop form-clmn_7-br-dtl   '99/99/99':U
&scop sort-clmn_7-br-dtl   buf_c-rvs-doc.fact-date
&scop label-clmn_8-br-dtl  'Время факт'
&scop form-clmn_8-br-dtl   'x(8)':U
&scop sort-clmn_8-br-dtl   string(buf_c-rvs-doc.fact-time,'HH:MM:SS':U)
&scop label-clmn_9-br-dtl  'Документ'
&scop form-clmn_9-br-dtl   'x(14)':U
&scop sort-clmn_9-br-dtl   buf_c-rvs-doc.out-code
&scop label-clmn_10-br-dtl 'Смена'
&scop form-clmn_10-br-dtl  'x(5)':U
&scop sort-clmn_10-br-dtl  substring(string(buf_c-rvs-doc.shift-date),1,5)
&scop label-clmn_11-br-dtl '№'
&scop form-clmn_11-br-dtl  'X(2)':U
&scop sort-clmn_11-br-dtl  buf_c-rvs-doc.shift-name
&scop label-clmn_12-br-dtl 'Факт остаток'
&scop form-clmn_12-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_12-br-dtl  buf_c-rvs-doc.state-measure-qnty
&scop label-clmn_13-br-dtl 'Измер. остаток'
&scop form-clmn_13-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_13-br-dtl  buf_c-rvs-doc.measure-qnty
&scop label-clmn_14-br-dtl 'Факт брутто'
&scop form-clmn_14-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_14-br-dtl  buf_c-rvs-doc.state-brutto-qnty
&scop label-clmn_15-br-dtl 'Измер. брутто'
&scop form-clmn_15-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_15-br-dtl  buf_c-rvs-doc.brutto-qnty
&scop label-clmn_16-br-dtl 'Учет'
&scop form-clmn_16-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_16-br-dtl  buf_c-rvs-doc.system-qnty
&scop label-clmn_17-br-dtl 'Учет (ед.пост.)'
&scop form-clmn_17-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_17-br-dtl  buf_c-rvs-doc.system-cli-qnty
&scop label-clmn_18-br-dtl 'Учет по!сред. плотности'
&scop form-clmn_18-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_18-br-dtl  buf_c-rvs-doc.system-cli-avrg-qnty
&scop label-clmn_19-br-dtl 'Измер.!(ед. пост.)'
&scop form-clmn_19-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_19-br-dtl  buf_c-rvs-doc.measure-cli-qnty
&scop label-clmn_20-br-dtl 'Факт!(ед. пост.)'
&scop form-clmn_20-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_20-br-dtl  buf_c-rvs-doc.state-measure-cli-qnty
&scop label-clmn_21-br-dtl 'Измер. брутто! (ед.пост)'
&scop form-clmn_21-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_21-br-dtl  buf_c-rvs-doc.brutto-cli-qnty
&scop label-clmn_22-br-dtl 'Факт брутто!(ед.пост.)'
&scop form-clmn_22-br-dtl  '->>,>>>,>>9.<<<':U
&scop sort-clmn_22-br-dtl  buf_c-rvs-doc.state-brutto-cli-qnty
&scop label-clmn_23-br-dtl 'Измер. оборот'
&scop form-clmn_23-br-dtl  '->>>,>>>,>>9.999':U
&scop sort-clmn_23-br-dtl  buf_c-rvs-doc.meas-mh-qnty
&scop label-clmn_24-br-dtl 'Факт оборот'
&scop form-clmn_24-br-dtl  '->>>,>>>,>>9.999':U
&scop sort-clmn_24-br-dtl  buf_c-rvs-doc.state-mh-qnty
&scop label-clmn_25-br-dtl 'Измер. сумма!оборота'
&scop form-clmn_25-br-dtl  '->>>,>>>,>>9.99':U
&scop sort-clmn_25-br-dtl  buf_c-rvs-doc.meas-am-qnty
&scop label-clmn_26-br-dtl 'Факт сумма!оборота'
&scop form-clmn_26-br-dtl  '->>>,>>>,>>9.99':U
&scop sort-clmn_26-br-dtl  buf_c-rvs-doc.state-am-qnty
&scop label-clmn_27-br-dtl 'Измер.!кол-во наливов'
&scop form-clmn_27-br-dtl  '->,>>>,>>9':U
&scop sort-clmn_27-br-dtl  buf_c-rvs-doc.meas-cf-qnty
&scop label-clmn_28-br-dtl 'Факт!кол-во наливов'
&scop form-clmn_28-br-dtl  '->,>>>,>>9':U
&scop sort-clmn_28-br-dtl  buf_c-rvs-doc.state-cf-qnty
&scop label-clmn_29-br-dtl 'Измер.!уровень топлива'
&scop form-clmn_29-br-dtl  '->>,>>9.999':U
&scop sort-clmn_29-br-dtl  buf_c-rvs-doc.level-petrol
&scop label-clmn_30-br-dtl 'Факт!уровень топлива'
&scop form-clmn_30-br-dtl  '->>,>>9.999':U
&scop sort-clmn_30-br-dtl  buf_c-rvs-doc.state-level-petrol
&scop label-clmn_31-br-dtl 'Измер.!общий уровень'
&scop form-clmn_31-br-dtl  '->>,>>9.999':U
&scop sort-clmn_31-br-dtl  buf_c-rvs-doc.level-total
&scop label-clmn_32-br-dtl 'Факт!общий уровень'
&scop form-clmn_32-br-dtl  '->>,>>9.999':U
&scop sort-clmn_32-br-dtl  buf_c-rvs-doc.state-level-total
&scop label-clmn_33-br-dtl 'Измер.!уровень воды'
&scop form-clmn_33-br-dtl  '->>,>>9.999':U
&scop sort-clmn_33-br-dtl  buf_c-rvs-doc.level-water
&scop label-clmn_34-br-dtl 'Факт!уровень воды'
&scop form-clmn_34-br-dtl  '->>,>>9.999':U
&scop sort-clmn_34-br-dtl  buf_c-rvs-doc.state-level-water
&scop label-clmn_35-br-dtl 'Объект'
&scop form-clmn_35-br-dtl  'x(13)':U
&scop sort-clmn_35-br-dtl  obj-name( buf_c-rvs-doc.obj-type, buf_c-rvs-doc.obj-code )
&scop dyn_sort-clmn_35-br-dtl substitute('dynamic-function(&1obj-name&1, &1&2&1, &1&3&1, &1&4&1)', ~{&double-quote~}, buf_c-rvs-doc.obj-type, buf_c-rvs-doc.obj-code )
&scop label-clmn_36-br-dtl 'Изменил'
&scop form-clmn_36-br-dtl  'x(8)':U
&scop sort-clmn_36-br-dtl  buf_c-rvs-doc.corr-user-name
&scop label-clmn_37-br-dtl 'Дата'
&scop form-clmn_37-br-dtl  '99/99/9999':U
&scop sort-clmn_37-br-dtl  buf_c-rvs-doc.corr-date
&scop label-clmn_38-br-dtl 'Время'
&scop form-clmn_38-br-dtl  'x(5)':U
&scop sort-clmn_38-br-dtl  buf_c-rvs-doc.sys-time
&scop label-clmn_39-br-dtl 'Щепка'
&scop form-clmn_39-br-dtl  '->,>>>,>>>,>>9':U
&scop sort-clmn_39-br-dtl  buf_c-rvs-doc.chip-num
&scop label-clmn_40-br-dtl 'Смена'
&scop form-clmn_40-br-dtl  'x(2)':U
&scop sort-clmn_40-br-dtl  buf_c-rvs-doc.corr-shift-name
&scop label-clmn_41-br-dtl 'Дата смены'
&scop form-clmn_41-br-dtl  '99/99/9999':U
&scop sort-clmn_41-br-dtl  buf_c-rvs-doc.corr-shift-date
&scop label-clmn_42-br-dtl 'Документ'
&scop form-clmn_42-br-dtl  'x(16)':U
&scop sort-clmn_42-br-dtl  buf_c-rvs-doc.corr-doc-code
&scop label-clmn_43-br-dtl 'Имя'
&scop form-clmn_43-br-dtl  'x(8)':U
&scop sort-clmn_43-br-dtl  buf_c-rvs-doc.user-name
&scop label-clmn_44-br-dtl 'БД'
&scop form-clmn_44-br-dtl  '>>>>9':U
&scop sort-clmn_44-br-dtl  buf_c-rvs-doc.user-db-num
&scop enabled-clmn-br-dtl  {&sort-clmn_34-br-dtl}

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
define button   Btn_Exit    label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-lkp   label "&Просмотр" size-chars 10.00 by 1.00 default.
define button b-sch label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-sel label "Вы&бор"    size-chars 10.00 by 1.00 default auto-go.

define variable mark-num as integer   no-undo view-as fill-in size-chars  8.00 by 1.00 format "->>>,>>>":U.
define variable sch-code as character no-undo view-as fill-in size-chars 17.50 by 1.00 format "x(16)":U.
define variable sch-date as date      no-undo view-as fill-in size-chars 11.50 by 1.00 format "99/99/9999":U.
define variable sch-fact as date      no-undo view-as fill-in size-chars 11.50 by 1.00 format "99/99/9999":U.
define variable sch-num  as integer   no-undo view-as fill-in size-chars  5.00 by 1.00 format ">>>":U.

/* Query definitions                                                    */
define query {&BROWSE-NAME} for buf_c-rvs-doc scrolling.

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
  {&sort-clmn_42-br-dtl} column-label {&label-clmn_42-br-dtl} format {&form-clmn_42-br-dtl}
  {&sort-clmn_43-br-dtl} column-label {&label-clmn_43-br-dtl} format {&form-clmn_43-br-dtl}
  {&sort-clmn_44-br-dtl} column-label {&label-clmn_44-br-dtl} format {&form-clmn_44-br-dtl}
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
    Btn_Exit     at row  1.50 col  2.50
  b-mark    at row  1.50 col 12.50
    mark-num     at row  1.50 col 15.75 no-label                        fgcolor 4
  b-sel  at row  1.50 col 24.00
  b-lkp    at row  1.50 col 44.75
  b-sch  at row  1.50 col 68.50
  b-help    at row  1.50 col 88.75
  {&BROWSE-NAME} at row  3.00 col  1.50
    r-rect-1     at row 12.50 col  1.50
  "          ":U at row 12.75 col  1.62 view-as text size-chars 98 by 1
  "ПОИСК ПО:"    at row 12.75 col  2.00 view-as text size-chars  9 by 1 bgcolor 3 fgcolor 15
  sch-code       at row 12.75 col 11.50    label "&Док-ту"
  sch-date       at row 12.75 col 39.50    label "&Дате"
  sch-fact       at row 12.75 col 59.50    label "&Факт"
  sch-num        at row 12.75 col 94.25 no-label                        fgcolor 4
    br-changes   at row 14.25 col  1.50
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title vss-description
     default-button Btn_Exit cancel-button Btn_Exit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.
assign {&BROWSE-NAME}         :num-locked-columns in frame  {&FRAME-NAME}  = 4
       {&enabled-clmn-br-dtl} :read-only          in browse {&BROWSE-NAME} = yes
       {&enabled-clmn-br-chg} :read-only          in browse   br-changes   = yes.
assign b-mark    :tooltip in frame {&FRAME-NAME} = "Поставить/снять отметку записи"
         Btn_Exit     :tooltip in frame {&FRAME-NAME} = "Вернуться в окно вызова"
       b-sch  :tooltip in frame {&FRAME-NAME} = "Установить/снять фильтр"
       b-help    :tooltip in frame {&FRAME-NAME} = "Интерактивная помощь в формате *.html"
       b-lkp    :tooltip in frame {&FRAME-NAME} = "Просмотреть текущую запись"
       b-sel  :tooltip in frame {&FRAME-NAME} = "Выбрать текущую(ие) запись(и)"
       {&BROWSE-NAME} :tooltip in frame {&FRAME-NAME} = "Список действий над сверками"
         br-changes   :tooltip in frame {&FRAME-NAME} = "Список изменений в сверке"
         sch-code     :tooltip in frame {&FRAME-NAME} = "Уникальный номер сверки для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
         sch-date     :tooltip in frame {&FRAME-NAME} = "Дата сверки для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
         sch-fact     :tooltip in frame {&FRAME-NAME} = "Дата факт сверки для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
         sch-num      :tooltip in frame {&FRAME-NAME} = "Количество найденных записей"
         mark-num     :tooltip in frame {&FRAME-NAME} = "Отмеченные записи".

on delete-character of {&BROWSE-NAME} in frame {&FRAME-NAME}
do:
  if b-mark :sensitive in frame {&FRAME-NAME}
  then do:
    apply "CHOOSE":U to b-mark in frame {&FRAME-NAME} .
  end.
end.

on insert-mode of {&BROWSE-NAME} in frame {&FRAME-NAME}
do:
  if b-mark   :sensitive in frame {&FRAME-NAME}
  then do:
    apply "CHOOSE":U to b-mark   in frame {&FRAME-NAME} .
  end.
  else
  if b-sel :sensitive in frame {&FRAME-NAME}
  then do:
    apply "CHOOSE":U to b-sel in frame {&FRAME-NAME} .
  end.
end.

on choose of b-mark in frame {&FRAME-NAME} do: /* * */
  { gbl/stdbtn.i }
  if available buf_c-rvs-doc
  then do:
    { gbl/markstrn.i buf_c-rvs-doc p-rid-list }
    {&BROWSE-NAME} :refresh( ) in frame {&FRAME-NAME} .
    if last-event :function <> "MOUSE-SELECT-DBLCLICK"
    then do:
      {&BROWSE-NAME} :select-next-row( ) in frame {&FRAME-NAME} .
    end.
    apply "VALUE-CHANGED":U to {&BROWSE-NAME} in frame {&FRAME-NAME} .
    if num-entries( p-rid-list ) = 0
    then do:
      hide                                mark-num   in frame {&FRAME-NAME} .
    end.
    else do:
      display num-entries( p-rid-list ) @ mark-num with frame {&FRAME-NAME} .
    end.
  END.
  apply "ENTRY":U to {&BROWSE-NAME} in frame {&FRAME-NAME}.
end.

on choose of Btn_Exit in frame {&FRAME-NAME} /* Выход */
do:
  { gbl/stdbtn.i }
  run gbl/markqwa.p
    ( input b-mark :sensitive
    , input p-rid-list
    ) no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
end.

on choose of b-sch in frame {&FRAME-NAME} /* Фильтр */
do:
  { gbl/stdbtn.i }
  {&SetCursorWait}
  run proc-filter in this-procedure no-error .
  {&SetCursorNo}
  if error-status :error
  then do:
    return no-apply .
  end.
end.

on choose of b-sel in frame {&FRAME-NAME} /* Выбор */
do:
  { gbl/stdbtn.i }
  if not available buf_c-rvs-doc
  then do:
    return no-apply .
  end.
  apply "GO":U to frame {&FRAME-NAME} .
end.

on go of frame {&FRAME-NAME}
do:
  if not available buf_c-rvs-doc
  then do:
    return no-apply .
  end.
  if p-rid-list             = "":U or
     b-mark :sensitive = no
  then do:
    assign
      p-rid-list = string( recid( buf_c-rvs-doc ) )
    .
  end.
end.

on choose of b-lkp in frame {&FRAME-NAME} do: /* Просмотр */
  define buffer buf_doc for ub.c-rvs-doc.

  { gbl/stdbtn.i }
  if not available buf_c-rvs-doc then do:
    message "Неправильно выбрана сверка." view-as alert-box error.
    return no-apply.
  end.
  else do:
    assign doc-rec = recid( buf_c-rvs-doc ).
  end.
  find first buf_doc no-lock where
             buf_doc.rvs-code  = buf_c-rvs-doc.rvs-code  and
             buf_doc.chip-num <> buf_c-rvs-doc.chip-num  and
             recid( buf_doc ) <> recid( buf_c-rvs-doc )  no-error.
  if not available buf_doc then do:
    message 'Данная запись истории пуста, т.к. соответствует СОЗДАНИЮ записи сверка.' skip
            'Просмотр невозможен!'
    view-as alert-box.
    return no-apply.
  end.

  run str/rvscdoca.w ( input parparentproc, input {&lookup}, input-output doc-rec ).
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

on entry of sch-code in frame {&FRAME-NAME} do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  assign  sch-date :screen-value in frame {&FRAME-NAME} = ?
          sch-fact :screen-value in frame {&FRAME-NAME} = ?.
  display sch-code  with frame {&FRAME-NAME}.
end.

on entry of sch-date in frame {&FRAME-NAME} do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  assign  sch-code :screen-value in frame {&FRAME-NAME} = "":U
          sch-fact :screen-value in frame {&FRAME-NAME} = ?.
  display sch-date  with frame {&FRAME-NAME}.
end.

on entry of sch-fact in frame {&FRAME-NAME} do:
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  assign  sch-code :screen-value in frame {&FRAME-NAME} = "":U
          sch-date :screen-value in frame {&FRAME-NAME} = ?.
  display sch-fact  with frame {&FRAME-NAME}.
end.

on leave of sch-code in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on leave of sch-date in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on leave of sch-fact in frame {&FRAME-NAME} do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame {&FRAME-NAME}.
end.

on CTRL-J of sch-code in frame {&FRAME-NAME} do: /* коду */
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

on return of sch-code in frame {&FRAME-NAME} do: /* коду */
  {&SetCursorWait}
  assign sch-code.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-code in this-procedure ( input no,  input sch-code ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on mouse-select-dblclick of sch-code in frame {&FRAME-NAME} do: /* коду */
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

on CTRL-J of sch-date in frame {&FRAME-NAME} do: /* дате */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-date <> sch-date then do:
    assign sch-date.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-date in this-procedure ( input yes, input sch-date ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on return of sch-date in frame {&FRAME-NAME} do: /* дате */
  {&SetCursorWait}
  assign sch-date.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-date in this-procedure ( input no,  input sch-date ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on mouse-select-dblclick of sch-date in frame {&FRAME-NAME} do: /* дате */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-date <> sch-date then do:
    assign sch-date.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-date in this-procedure ( input yes, input sch-date ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on CTRL-J of sch-fact in frame {&FRAME-NAME} do: /* факт */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-fact <> sch-fact then do:
    assign sch-fact.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-fact in this-procedure ( input yes, input sch-fact ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on return of sch-fact in frame {&FRAME-NAME} do: /* факт */
  {&SetCursorWait}
  assign sch-fact.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame {&FRAME-NAME}.
  run proc-find-fact in this-procedure ( input no,  input sch-fact ) no-error.
  {&SetCursorNo}
  if error-status :error then do: return no-apply. end.
end.

on mouse-select-dblclick of sch-fact in frame {&FRAME-NAME} do: /* факт */
  {&SetCursorWait}
  if input frame {&FRAME-NAME} sch-fact <> sch-fact then do:
    assign sch-fact.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame {&FRAME-NAME}.
  end.
  run proc-find-fact in this-procedure ( input yes, input sch-fact ) no-error.
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
    &ext-col      = 44
    &frame-name   = {&FRAME-NAME}
    &browse-name  = {&BROWSE-NAME}
    &table-name   = "buf_c-rvs-doc"
    &start-column = 5              }

{ gbl/srt-clmd.i
    &ext-col              = 44
    &frame-name           = {&FRAME-NAME}
    &browse-name          = {&BROWSE-NAME}
    &table-name           = "buf_c-rvs-doc"
    &start-column         = 5
    &label-clmn_1         = "{&label-clmn_1-br-dtl}"
    &sort-clmn_1          = "{&sort-clmn_1-br-dtl}"
    &label-clmn_2         = "{&label-clmn_2-br-dtl}"
    &sort-clmn_2          = "{&sort-clmn_2-br-dtl}"
    &label-clmn_3         = "{&label-clmn_3-br-dtl}"
    &sort-clmn_3          = "{&sort-clmn_3-br-dtl}"
    &label-clmn_4         = "{&label-clmn_4-br-dtl}"
    &sort-clmn_4          = "{&sort-clmn_4-br-dtl}"
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
    &label-clmn_14        = "{&label-clmn_14-br-dtl}"
    &sort-clmn_14         = "{&sort-clmn_14-br-dtl}"
    &label-clmn_15        = "{&label-clmn_15-br-dtl}"
    &sort-clmn_15         = "{&sort-clmn_15-br-dtl}"
    &label-clmn_16        = "{&label-clmn_16-br-dtl}"
    &sort-clmn_16         = "{&sort-clmn_16-br-dtl}"
    &label-clmn_17        = "{&label-clmn_17-br-dtl}"
    &sort-clmn_17         = "{&sort-clmn_17-br-dtl}"
    &label-clmn_18        = "{&label-clmn_18-br-dtl}"
    &sort-clmn_18         = "{&sort-clmn_18-br-dtl}"
    &label-clmn_19        = "{&label-clmn_19-br-dtl}"
    &sort-clmn_19         = "{&sort-clmn_19-br-dtl}"
    &label-clmn_20        = "{&label-clmn_20-br-dtl}"
    &sort-clmn_20         = "{&sort-clmn_20-br-dtl}"
    &label-clmn_21        = "{&label-clmn_21-br-dtl}"
    &sort-clmn_21         = "{&sort-clmn_21-br-dtl}"
    &label-clmn_22        = "{&label-clmn_22-br-dtl}"
    &sort-clmn_22         = "{&sort-clmn_22-br-dtl}"
    &label-clmn_23        = "{&label-clmn_23-br-dtl}"
    &sort-clmn_23         = "{&sort-clmn_23-br-dtl}"
    &label-clmn_24        = "{&label-clmn_24-br-dtl}"
    &sort-clmn_24         = "{&sort-clmn_24-br-dtl}"
    &label-clmn_25        = "{&label-clmn_25-br-dtl}"
    &sort-clmn_25         = "{&sort-clmn_25-br-dtl}"
    &label-clmn_26        = "{&label-clmn_26-br-dtl}"
    &sort-clmn_26         = "{&sort-clmn_26-br-dtl}"
    &label-clmn_27        = "{&label-clmn_27-br-dtl}"
    &sort-clmn_27         = "{&sort-clmn_27-br-dtl}"
    &label-clmn_28        = "{&label-clmn_28-br-dtl}"
    &sort-clmn_28         = "{&sort-clmn_28-br-dtl}"
    &label-clmn_29        = "{&label-clmn_29-br-dtl}"
    &sort-clmn_29         = "{&sort-clmn_29-br-dtl}"
    &label-clmn_30        = "{&label-clmn_30-br-dtl}"
    &sort-clmn_30         = "{&sort-clmn_30-br-dtl}"
    &label-clmn_31        = "{&label-clmn_31-br-dtl}"
    &sort-clmn_31         = "{&sort-clmn_31-br-dtl}"
    &label-clmn_32        = "{&label-clmn_32-br-dtl}"
    &sort-clmn_32         = "{&sort-clmn_32-br-dtl}"
    &label-clmn_33        = "{&label-clmn_33-br-dtl}"
    &sort-clmn_33         = "{&sort-clmn_33-br-dtl}"
    &label-clmn_34        = "{&label-clmn_34-br-dtl}"
    &sort-clmn_34         = "{&sort-clmn_34-br-dtl}"
    &label-clmn_35        = "{&label-clmn_35-br-dtl}"
    &sort-clmn_35         = "{&sort-clmn_35-br-dtl}"
    &dyn_sort-clmn_35     = "{&dyn_sort-clmn_35-br-dtl}"
    &label-clmn_36        = "{&label-clmn_36-br-dtl}"
    &sort-clmn_36         = "{&sort-clmn_36-br-dtl}"
    &label-clmn_37        = "{&label-clmn_37-br-dtl}"
    &sort-clmn_37         = "{&sort-clmn_37-br-dtl}"
    &label-clmn_38        = "{&label-clmn_38-br-dtl}"
    &sort-clmn_38         = "{&sort-clmn_38-br-dtl}"
    &label-clmn_39        = "{&label-clmn_39-br-dtl}"
    &sort-clmn_39         = "{&sort-clmn_39-br-dtl}"
    &label-clmn_40        = "{&label-clmn_40-br-dtl}"
    &sort-clmn_40         = "{&sort-clmn_40-br-dtl}"
    &label-clmn_41        = "{&label-clmn_41-br-dtl}"
    &sort-clmn_41         = "{&sort-clmn_41-br-dtl}"
    &label-clmn_42        = "{&label-clmn_42-br-dtl}"
    &sort-clmn_42         = "{&sort-clmn_42-br-dtl}"
    &label-clmn_43        = "{&label-clmn_43-br-dtl}"
    &sort-clmn_43         = "{&sort-clmn_43-br-dtl}"
    &label-clmn_44        = "{&label-clmn_44-br-dtl}"
    &sort-clmn_44         = "{&sort-clmn_44-br-dtl}"
    &open-query           = "run OpenBr in this-procedure ( input yes, input no, input '':U )."
    &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U )."
    &sort-column-name     = "sort-column-name"
    &re-move-clmn         = "no"
    &mv-brw-default       = "yes"                                                               }

{ gbl/ed_date.i sch-date }
{ gbl/ed_date.i sch-fact }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
   p-host-code = v-cntxt-host-code-obj.

  if lookup( p-mode, '{&bef-all},one':U ) = 0 then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    return.
  end. /* p-mode */
  if p-mode = 'one':U then do:
    find first buf_source no-lock where buf_source.rvs-code = p-rvs-code no-error.
    if not available buf_source then do:
      message vss-workfile SKIP vss-revision SKIP vss-date SKIP( 1 ) vss-description SKIP( 1 )
              'Неверное значение параметра вызова p-rvs-code: "' + p-rvs-code + '"'
      view-as alert-box error.
      return.
    end.
  end. /* p-mode = 'one':U */
  if p-rid-list <> "":U then do:
    find first buf_sch_hist no-lock where recid( buf_sch_hist ) = integer( entry( 1, p-rid-list ) ) no-error.
    if not available buf_sch_hist then do:
      message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
              'Неверное значение параметра вызова p-rid-list: "' + p-rid-list + '".'
      view-as alert-box error.
      return error.
    end.
    else do:
      assign doc-rec = recid( buf_sch_hist ).
    end.
  end.

  /* display sch-code sch-date sch-fact sch-num mark-num br-changes with frame {&FRAME-NAME}. */
  enable  b-mark   when lookup( "b-mark":U,   p-bttns ) > 0 or p-bttns = "*"
          b-sel when lookup( "b-sel":U, p-bttns ) > 0 or p-bttns = "*"
          b-sch b-help Btn_Exit b-lkp {&BROWSE-NAME} br-changes sch-code sch-date sch-fact
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
  assign title0 = "Список истории изменения" + {&space-char}.
  assign p-proc-hand = this-procedure :handle.

  case sort-column-name :
    when "":U then do: assign sort-column-phrase = "":U. end.
    otherwise      do: assign sort-column-phrase = "by " + sort-column-name. end.
  end case. /* sort-column-name */

  &scop flt-open-open-query         open query {&BROWSE-NAME} for each buf_c-rvs-doc
  &scop flt-open-dyn_open-query     for each buf_c-rvs-doc no-lock
  &scop flt-open-query-handle       query br-rvs-docs :handle
  &scop flt-open-open-query-tail
  &scop flt-open-query-was-opened   l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point         filter-point
  &scop flt-open-set-filter-name    set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition
  &scop flt-open-query              p-open-query
  &scop flt-open-table-name         buf_c-rvs-doc
  &scop flt-open-search-option      no-lock
  &scop flt-open-find-next          p-find-next
  &scop flt-open-find-recid         doc-rec
  &scop flt-open-find-condition     p-find-condition
  &scop flt-open-find-buffer-name   buf_c-rvs-doc
  &scop flt-open-waitfram           yes

  define variable l-open-query as logical no-undo.

  assign filter-point = filter-point0 + " - " + p-mode.

  case p-mode :
    when {&all}  then do:
      {&SetCursorWait}
      assign frame {&FRAME-NAME} :title = title0 + "сверок".
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_c-rvs-doc.host-code = p-host-code ~
                        "
          &dyn_where-cond = " substitute('buf_c-rvs-doc.host-code = &1', p-host-code )"
          &use-ind    = "  "
          &by         = "  "                                   }
    end. /* {&all} */
    when 'one':U then do:
      {&SetCursorWait}
      find first buf_source no-lock where buf_source.rvs-code = p-rvs-code no-error.
      assign frame {&FRAME-NAME} :title = title0 + substitute( 'сверки "&1"', buf_source.rvs-code ).
      { gbl/fltopend.i
          &where-cond = " ~
                          buf_c-rvs-doc.rvs-code = p-rvs-code ~
                        "
          &dyn_where-cond = " substitute('buf_c-rvs-doc.rvs-code = &1&2&1', ~{&double-quote~}, p-rvs-code )"
          &use-ind    = "  "
          &by         = "  "                                   }

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
  &scop  object     obj-type{&delim-flt}obj-code

  assign tbl      = 'c-rvs-doc'
         join-tbl = 'buf_c-rvs-doc'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.

  {&SetCursorWait}
  run fltfield-add in this-procedure ( input 'rvs-code',               input 'Документ',                                input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'obj-type',               input 'Тип объекта',                             input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'obj-code',               input 'Код объекта',                             input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input '{&object}',              input 'Объект',                                  input 'cli',  {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'status_',                input 'Статус',                                  input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'rvs-type',               input 'Тип',                                     input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'out-code',               input 'Номер out',                               input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'fact-order',             input 'факт-ордер',                              input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'wrkr',                   input 'Кладовщик',                               input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'agnt',                   input 'Исполнитель',                             input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'boss',                   input 'Менеджер',                                input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'shift-num',              input 'Порядок смены',                           input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'shift-name',             input 'Номер смены',                             input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'shift-date',             input 'Дата смены',                              input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'fact-date',              input 'Дата факт',                               input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'fact-time',              input 'Время факт',                              input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'creid',                  input 'Оператор',                                input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'doc-date',               input 'Дата док',                                input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'host-code',              input 'Своя фирма',                              input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'ps',                     input 'Примечание',                              input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'brutto-qnty',            input 'Измер. брутто',                           input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-brutto-qnty',      input 'Факт брутто',                             input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'measure-qnty',           input 'Измер. остаток',                          input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-measure-qnty',     input 'Факт остаток',                            input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'level-total',            input 'Измер. общий уровень в резервуаре',       input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'level-water',            input 'Измер. уровень воды в резервуаре',        input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'level-petrol',           input 'Измер. уровень топлива в резервуаре',     input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-level-total',      input 'Факт общий уровень в резервуаре',         input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-level-water',      input 'Факт уровень воды в резервуаре',          input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-level-petrol',     input 'Факт уровень топлива в резервуаре',       input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'system-qnty',            input 'Учет',                                    input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'system-cli-qnty',        input 'Учет (ед.пост.)',                         input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'brutto-cli-qnty',        input 'Измер. брутто (ед.пост)',                 input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'add-qnty',               input 'Кол-во в трубопроводе',                   input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'system-cli-avrg-qnty',   input 'Учет по средней плотности',               input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-brutto-cli-qnty',  input 'Факт брутто (ед.пост)',                   input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'measure-cli-qnty',       input 'Измер. (ед. пост.)',                      input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'meas-am-qnty',           input 'Измеренная сумма оборота',                input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-am-qnty',          input 'Факт сумма оборота за смену',             input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'meas-cf-qnty',           input 'Измеренное кол-во наливов за смену',      input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-cf-qnty',          input 'Факт кол-во наливов за смену',            input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-measure-cli-qnty', input 'Факт (ед.пост.)',                         input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'is-full',                input 'Полный',                                  input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-add-qnty',         input 'Факт в трубопроводе',                     input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'meas-mh-qnty',           input 'Измеренный оборот',                       input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-mh-qnty',          input 'Факт оборот',                             input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'brutto-tc-qnty',         input 'Измер. брутто(tc)',                       input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-brutto-tc-qnty',   input 'Факт брутто(tc)',                         input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'measure-tc-qnty',        input 'Измер. остаток(tc)',                      input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'state-measure-tc-qnty',  input 'Факт остаток(tc)',                        input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-doc-code',          input 'Номер',                                   input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-date',              input 'Дата последней коррекции',                input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-shift-date',        input 'Дата смены удаления',                     input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-shift-num',         input 'Порядок смены удаления',                  input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-shift-name',        input 'Номер смены удаления',                    input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-name',         input 'Изменил',                                 input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'is-corr',                input 'Документ корректировался в статусе факт', input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'is-del',                 input 'Документ удаляется в статусе факт',       input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'user-db-num',            input 'Номер БД',                                input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'user-name',              input 'Имя',                                     input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'sys-date',               input 'Дата',                                    input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'sys-time',               input 'Время',                                   input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'sys-time-int',           input 'Время в секундах',                        input '':U,   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'chip-num',               input 'Щепка',                                   input '':U,   {&common} ) no-error.

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
  define buffer new_hist for ub.c-rvs-doc.
  define buffer buf_srch for ub.rvs-doc.

  define variable v-chg-fields as character no-undo.
  define variable v-old-fields as character no-undo.
  define variable v-new-fields as character no-undo.
  define variable jj           as integer   no-undo.

  for each temp-changes :
    delete temp-changes.
  end.
  if not available buf_c-rvs-doc then do:
    open query br-changes for each buf_changes .
    return.
  end.
  run proc-full-temp-changes in this-procedure
    ( input (buf_c-rvs-doc.action = {&bef-hn-create} )
     ,input (buf_c-rvs-doc.action = {&bef-hn-delete} )
     ,input (buffer buf_c-rvs-doc:handle)
     ,input {&table_c-rvs-doc}
     ,input "~
rvs-code,obj-type,obj-code,status_,rvs-type,out-code,fact-order,wrkr,agnt,boss,shift-num,~
shift-name,shift-date,fact-date,fact-time,creid,doc-date,host-code,PS,brutto-qnty,state-brutto-qnty,measure-qnty,state-measure-qnty,level-total,level-water,~
level-petrol,state-level-total,state-level-water,state-level-petrol,system-qnty,system-cli-qnty,brutto-cli-qnty,add-qnty,system-cli-avrg-qnty,~
state-brutto-cli-qnty,measure-cli-qnty,meas-am-qnty,state-am-qnty,meas-cf-qnty,state-cf-qnty,state-measure-cli-qnty,is-full,state-add-qnty,~
meas-mh-qnty,state-mh-qnty,brutto-tc-qnty,state-brutto-tc-qnty,measure-tc-qnty,state-measure-tc-qnty,corr-doc-code,corr-date,corr-shift-date,~
corr-shift-num,corr-shift-name,corr-user-name,is-corr,is-del,user-db-num,user-name,sys-date,sys-time~
":U
     ,input "~
":U
    ) no-error.
/*Документ,Тип объекта,Код объекта,Статус,Тип,Номер out,факт-ордер,Кладовщикк,Исполнитель,Менеджер,Порядок смены,Номер смены,~*/
/*Дата смены,Дата факт,Время,Оператор,Дата,Своя фирма,Примечание,Измер. брутто,Факт брутто,Измер. остаток,Факт остаток,ур. общ. в рез.~*/
/*уровень воды,уровень топлива,Факт общ. уров.,Факт уров. воды,Факт уров.топл.,Учет,Учет (ед.пост.),Изм.брутто(пос),в трубопроводе,Учет п/ср.пл-ти,~*/
/*Факт бр. (пост),Измер. (пост.),Изм. сумма обор,оборот за смену,Изм. налив/см.,Факт налив/см.,Факт (ед.пост.),Полный,Факт в трубопр.,Измер. оборот,~*/
/*Факт оборот,Измер.брутто tc,Факт брутто(tc),Измер. ост.(tc),Факт остат.(tc),Номер,посл. коррекция,Дата см. удал.,Порядок смены удаления,~*/
/*Номер смены удаления,Изменил,корректир. факт,удаление факт,Номер БД,Имя,Дата,Время~*/

  open query br-changes for each buf_changes .
end procedure. /* proc-view-changes */

{ gbl/setfltnm.i }

procedure get-mark-string :
  define        parameter buffer loc-buf for ub.c-rvs-doc.
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
  assign p-code = replace( p-code, {&double-quote}, {&double-quote} + {&double-quote} )
         p-code = replace( p-code, {&single-quote}, {&single-quote} + {&single-quote} )
         p-code = {&double-quote} + p-code + {&double-quote}.
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_c-rvs-doc.rvs-code begins &1 ", p-code ) ).
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

procedure proc-find-date :
  define input parameter p-next as logical no-undo.
  define input parameter p-date as date    no-undo.

  define variable v_date as character no-undo.
  define variable v_dlmt as character no-undo.

  assign v_dlmt = substring( string( p-date ), 3, 1 ).
  assign v_date = string( day( p-date ), "99":U   ) + v_dlmt
                  + string( month( p-date ), "99":U   ) + v_dlmt
                  + string( year( p-date ), "9999":U ).
  run OpenBr in this-procedure
    ( input no
     ,input p-next
     ,input substitute( " and buf_c-rvs-doc.doc-date = &1 ", v_date )
    ).
  if doc-rec <> ? and doc-rec <> 0 then do:
    if FoundRec = ? then do: assign FoundRec = doc-rec. end.
    if FoundRec = doc-rec then do: assign sch-num = 0. end.
    assign  sch-num = sch-num + 1.
    display sch-num with frame {&FRAME-NAME}.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num   in frame {&FRAME-NAME}.
  end.
  apply "ENTRY":U to sch-date in frame {&FRAME-NAME}.
end procedure. /* proc-find-date */

procedure proc-find-fact :
  define input parameter p-next as logical no-undo.
  define input parameter p-date as date    no-undo.

  define variable v_date as character no-undo.
  define variable v_dlmt as character no-undo.

  assign v_dlmt = substring( string( p-date ), 3, 1 ).
  assign v_date = string( day( p-date ), "99":U   ) + v_dlmt
                  + string( month( p-date ), "99":U   ) + v_dlmt
                  + string( year( p-date ), "9999":U ).
  run OpenBr in this-procedure
    ( input no
     ,input p-next
     ,input substitute( " and buf_c-rvs-doc.fact-date = &1 ", v_date )
    ).
  if doc-rec <> ? and doc-rec <> 0 then do:
    if FoundRec = ? then do: assign FoundRec = doc-rec. end.
    if FoundRec = doc-rec then do: assign sch-num = 0. end.
    assign  sch-num = sch-num + 1.
    display sch-num with frame {&FRAME-NAME}.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num   in frame {&FRAME-NAME}.
  end.
  apply "ENTRY":U to sch-fact in frame {&FRAME-NAME}.
end procedure. /* proc-find-fact */

procedure get-obj-name :
  define  input parameter p-type as character no-undo.
  define  input parameter p-code as integer   no-undo.
  define output parameter p-name as character no-undo.

  assign p-name = ( if p-type = ? or p-code = ? then "":U else ( p-type + " ":U + Int2Char( p-code ) ) ).
end procedure. /* get-obj-name */