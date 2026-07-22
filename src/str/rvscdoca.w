/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр карточки истории изменения сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/12/07
Author: Dmitry Ukhanov
Creation date: 01/12/07

Create: Булгаков Андрей Николаевич
Дата создания: 06/23/05

*/

/* ********************  Preprocessor Definitions  ******************** */
/* Name of First Frame and/or Browse (alphabetically) */
&scop FRAME-NAME  fr-D-doca0
&scop align       colon-aligned
&scop size-type   chars
&scop fill-in     view-as fill-in size-{&size-type}
&scop text        view-as text    size-{&size-type}
&scop view        view-as text

/* ***************************  Definitions  ************************** */
/* Parameters Definitions */
define input        parameter p-parent-proc as widget-handle no-undo.
define input        parameter p-mode        as character     no-undo.
define input-output parameter p-rid         as recid         no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения сверки":U.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ gbl/waitfram.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/setfltnm.i no-button }
{ gbl/fltopend.i defproc }

define variable ParParentProc as widget-handle no-undo.
define variable gds-rec       as recid         no-undo.
define variable doc-rec       as recid         no-undo.
define variable v-ref-rec       as recid         no-undo.

define new shared buffer r-line for ub.c-rvs-line.
define new shared buffer r-pump for ub.c-rvs-line-pump.
define new shared buffer   r-goods    for ub.goods.
define new shared buffer   r-place    for ub.place.

/* ************************  Function Prototypes ********************** */
function deviation-fact returns decimal (
      input p-state-measure-qnty as decimal
    , input p-state-add-qnty     as decimal
    , input p-system-qnty        as decimal
):

    define variable dev-fact-qty as decimal no-undo.

    run get-dev-fact in this-procedure (
          input p-state-measure-qnty
        , input p-state-add-qnty
        , input p-system-qnty
        , output dev-fact-qty
    ).
    return ( dev-fact-qty ).

end function. /* deviation-fact */

function deviation-measure returns decimal (
      input p-state-measure-qnty as decimal
    , input p-state-add-qnty     as decimal
    , input p-system-qnty        as decimal
) :

  define variable dev-meas-qty as decimal no-undo.

    run get-dev-fact in this-procedure (
          input p-state-measure-qnty
        , input p-state-add-qnty
        , input p-system-qnty
        , output dev-meas-qty
    ).
    return ( dev-meas-qty ).
end function. /* deviation-measure */

&scop label-clmn_1-br-line  'Артикул'
&scop form-clmn_1-br-line   'x(16)':U
&scop sort-clmn_1-br-line   r-goods.artic
&scop label-clmn_2-br-line  'Название'
&scop form-clmn_2-br-line   'x(15)':U
&scop sort-clmn_2-br-line   r-goods.gds-name
&scop label-clmn_3-br-line  'Скл.место'
&scop form-clmn_3-br-line   '999999999':U
&scop sort-clmn_3-br-line   r-line.pl-code
&scop label-clmn_4-br-line  'Номер резервуара'
&scop form-clmn_4-br-line   'x(8)':U
&scop sort-clmn_4-br-line   r-place.loc1
&scop label-clmn_5-br-line  'Факт остаток'
&scop form-clmn_5-br-line   '->>,>>>,>>9.<<<':U
&scop sort-clmn_5-br-line   r-line.state-measure-qnty
&scop label-clmn_6-br-line  'Измер. остаток'
&scop form-clmn_6-br-line   '->>,>>>,>>9.<<<':U
&scop sort-clmn_6-br-line   r-line.measure-qnty
&scop label-clmn_7-br-line  'Учет'
&scop form-clmn_7-br-line   '->>,>>>,>>9.<<<':U
&scop sort-clmn_7-br-line   r-line.system-qnty
&scop label-clmn_8-br-line  'Первонач.учет'
&scop form-clmn_8-br-line   '->>,>>>,>>9.<<<':U
&scop sort-clmn_8-br-line   r-line.orig-system-qnty
&scop label-clmn_9-br-line  'Факт в!трубопроводе'
&scop form-clmn_9-br-line   '->>,>>>,>>9.<<<':U
&scop sort-clmn_9-br-line   r-line.state-add-qnty
&scop label-clmn_10-br-line 'Отклонение(факт)'
&scop form-clmn_10-br-line  '->>,>>>,>>>.<<<':U
&scop sort-clmn_10-br-line  deviation-fact( r-line.state-measure-qnty, r-line.state-add-qnty, r-line.system-qnty )
&scop dyn_sort-clmn_10-br-line substitute('dynamic-function(&1deviation-fact&1, &1&2&1, &1&3&1, &1&4&1)', ~{&double-quote~}, r-line.state-measure-qnty, r-line.state-add-qnty, r-line.system-qnty )
&scop label-clmn_11-br-line 'Отклонение(измер)'
&scop form-clmn_11-br-line  '->>,>>>,>>>.<<<':U
&scop sort-clmn_11-br-line  deviation-measure( r-line.state-measure-qnty, r-line.state-add-qnty, r-line.system-qnty )
&scop dyn_sort-clmn_11-br-line  substitute('dynamic-function(&1deviation-measure&1, &1&2&1, &1&3&1, &1&4&1)', ~{&double-quote~}, r-line.state-measure-qnty, r-line.state-add-qnty, r-line.system-qnty )
&scop label-clmn_12-br-line 'Допустимое!отклонение'
&scop form-clmn_12-br-line  '->>,>>>,>>9.<<<':U
&scop sort-clmn_12-br-line  r-line.tolerance
&scop label-clmn_13-br-line 'Факт брутто'
&scop form-clmn_13-br-line  '->>,>>>,>>9.<<<':U
&scop sort-clmn_13-br-line  r-line.state-brutto-qnty
&scop label-clmn_14-br-line 'Измер. брутто'
&scop form-clmn_14-br-line  '->>,>>>,>>9.<<<':U
&scop sort-clmn_14-br-line  r-line.brutto-qnty
&scop label-clmn_15-br-line 'Плотность'
&scop form-clmn_15-br-line  '>9.999':U
&scop sort-clmn_15-br-line  r-line.state-density
&scop label-clmn_16-br-line 'Измер.!пл-ть'
&scop form-clmn_16-br-line  '>9.999':U
&scop sort-clmn_16-br-line  r-line.density
&scop label-clmn_17-br-line 'Факт!(ед. пост.)'
&scop form-clmn_17-br-line  '->>,>>>,>>9.<<<':U
&scop sort-clmn_17-br-line  r-line.state-measure-cli-qnty
&scop label-clmn_18-br-line 'Измер.!(ед. пост.)'
&scop form-clmn_18-br-line  '->>,>>>,>>9.<<<':U
&scop sort-clmn_18-br-line  r-line.measure-cli-qnty
&scop label-clmn_19-br-line 'Учет (ед.пост.)'
&scop form-clmn_19-br-line  '->>,>>>,>>9.<<<':U
&scop sort-clmn_19-br-line  r-line.system-cli-qnty
&scop label-clmn_20-br-line 'Нач.учет(е.п.)'
&scop form-clmn_20-br-line  '->>,>>>,>>9.<<<':U
&scop sort-clmn_20-br-line  r-line.orig-system-cli-qnty
&scop label-clmn_21-br-line 'Факт брутто!(ед.пост.)'
&scop form-clmn_21-br-line  '->>,>>>,>>9.<<<':U
&scop sort-clmn_21-br-line  r-line.state-brutto-cli-qnty
&scop label-clmn_22-br-line 'Измер. брутто! (ед.пост)'
&scop form-clmn_22-br-line  '->>,>>>,>>9.<<<':U
&scop sort-clmn_22-br-line  r-line.brutto-cli-qnty
&scop label-clmn_23-br-line 'Факт оборот'
&scop form-clmn_23-br-line  '->>>,>>>,>>9.999':U
&scop sort-clmn_23-br-line  r-line.state-mh-qnty
&scop label-clmn_24-br-line 'Измер. оборот'
&scop form-clmn_24-br-line  '->>>,>>>,>>9.999':U
&scop sort-clmn_24-br-line  r-line.meas-mh-qnty
&scop label-clmn_25-br-line 'Факт сумма!оборота'
&scop form-clmn_25-br-line  '->>>,>>>,>>9.99':U
&scop sort-clmn_25-br-line  r-line.state-am-qnty
&scop label-clmn_26-br-line 'Измер. сумма!оборота'
&scop form-clmn_26-br-line  '->>>,>>>,>>9.99':U
&scop sort-clmn_26-br-line  r-line.meas-am-qnty
&scop label-clmn_27-br-line 'Факт!кол-во наливов'
&scop form-clmn_27-br-line  '->,>>>,>>9':U
&scop sort-clmn_27-br-line  r-line.state-cf-qnty
&scop label-clmn_28-br-line 'Измер.!кол-во наливов'
&scop form-clmn_28-br-line  '->,>>>,>>9':U
&scop sort-clmn_28-br-line  r-line.meas-cf-qnty
&scop label-clmn_29-br-line 'Факт!общий уровень'
&scop form-clmn_29-br-line  '->>,>>9.999':U
&scop sort-clmn_29-br-line  r-line.state-level-total
&scop label-clmn_30-br-line 'Измер.!общий уровень'
&scop form-clmn_30-br-line  '->>,>>9.999':U
&scop sort-clmn_30-br-line  r-line.level-total
&scop label-clmn_31-br-line 'Факт!уровень топлива'
&scop form-clmn_31-br-line  '->>,>>9.999':U
&scop sort-clmn_31-br-line  r-line.state-level-petrol
&scop label-clmn_32-br-line 'Измер.!уровень топлива'
&scop form-clmn_32-br-line  '->>,>>9.999':U
&scop sort-clmn_32-br-line  r-line.level-petrol
&scop label-clmn_33-br-line 'Факт!уровень воды'
&scop form-clmn_33-br-line  '->>,>>9.999':U
&scop sort-clmn_33-br-line  r-line.state-level-water
&scop label-clmn_34-br-line 'Измер.!уровень воды'
&scop form-clmn_34-br-line  '->>,>>9.999':U
&scop sort-clmn_34-br-line  r-line.level-water
&scop label-clmn_35-br-line 'Температура'
&scop form-clmn_35-br-line  '->>9.999':U
&scop sort-clmn_35-br-line  r-line.state-temperature
&scop label-clmn_36-br-line 'Измер.!темп.'
&scop form-clmn_36-br-line  '->>9.999':U
&scop sort-clmn_36-br-line  r-line.temperature
&scop enabled-clmn-br-line  {&sort-clmn_36-br-line}

&scop label-clmn_1-br-pump  'ТРК'
&scop form-clmn_1-br-pump   '>9':U
&scop sort-clmn_1-br-pump   r-pump.pump-code
&scop label-clmn_2-br-pump  'П'
&scop form-clmn_2-br-pump   '>':U
&scop sort-clmn_2-br-pump   r-pump.nozzle-code
&scop label-clmn_3-br-pump  'Факт оборот'
&scop form-clmn_3-br-pump   '->>>,>>>,>>9.999':U
&scop sort-clmn_3-br-pump   r-pump.state-mh-qnty
&scop label-clmn_4-br-pump  'Измер. оборот'
&scop form-clmn_4-br-pump   '->>>,>>>,>>9.999':U
&scop sort-clmn_4-br-pump   r-pump.meas-mh-qnty
&scop label-clmn_5-br-pump  'Факт сумма!оборота'
&scop form-clmn_5-br-pump   '->>>,>>>,>>9.99':U
&scop sort-clmn_5-br-pump   r-pump.state-am-qnty
&scop label-clmn_6-br-pump  'Измер. сумма!оборота'
&scop form-clmn_6-br-pump   '->>>,>>>,>>9.99':U
&scop sort-clmn_6-br-pump   r-pump.meas-am-qnty
&scop label-clmn_7-br-pump  'Факт!кол-во наливов'
&scop form-clmn_7-br-pump   '->,>>>,>>9':U
&scop sort-clmn_7-br-pump   r-pump.state-cf-qnty
&scop label-clmn_8-br-pump  'Измер.!кол-во наливов'
&scop form-clmn_8-br-pump   '->,>>>,>>9':U
&scop sort-clmn_8-br-pump   r-pump.meas-cf-qnty
&scop label-clmn_9-br-pump  'Показ. механического!счетчика'
&scop form-clmn_9-br-pump   '->,>>>,>>>,>>>,>>9.999':U
&scop sort-clmn_9-br-pump   r-pump.state-mh-cnt
&scop label-clmn_10-br-pump 'Измер. механического! счетчика'
&scop form-clmn_10-br-pump  '->,>>>,>>>,>>>,>>9.999':U
&scop sort-clmn_10-br-pump  r-pump.meas-mh-cnt
&scop label-clmn_11-br-pump 'Показ. электронного!счетчика'
&scop form-clmn_11-br-pump  '->,>>>,>>>,>>>,>>9.999':U
&scop sort-clmn_11-br-pump  r-pump.state-el-cnt
&scop label-clmn_12-br-pump 'Измер. электронного!счетчика'
&scop form-clmn_12-br-pump  '->,>>>,>>>,>>>,>>9.999':U
&scop sort-clmn_12-br-pump  r-pump.meas-el-cnt
&scop label-clmn_13-br-pump 'Сумма по показ.!счетчика'
&scop form-clmn_13-br-pump  '->,>>>,>>>,>>>,>>9.999':U
&scop sort-clmn_13-br-pump  r-pump.state-am-cnt
&scop label-clmn_14-br-pump 'Сумма по измер.!счетчика'
&scop form-clmn_14-br-pump  '->,>>>,>>>,>>>,>>9.999':U
&scop sort-clmn_14-br-pump  r-pump.meas-am-cnt
&scop label-clmn_15-br-pump 'Кол-во наливов!по показ. счетчика'
&scop form-clmn_15-br-pump  '->,>>>,>>>,>>>,>>9':U
&scop sort-clmn_15-br-pump  r-pump.state-cf-cnt
&scop label-clmn_16-br-pump 'Кол-во наливов!по  измер. счетчика'
&scop form-clmn_16-br-pump  '->,>>>,>>>,>>>,>>9':U
&scop sort-clmn_16-br-pump  r-pump.meas-cf-cnt
&scop label-clmn_17-br-pump 'Номер док-та!инвент. счетчика'
&scop form-clmn_17-br-pump  'x(16)':U
&scop sort-clmn_17-br-pump  r-pump.icnt-code
&scop label-clmn_18-br-pump 'Сверка на начало'
&scop form-clmn_18-br-pump  'x(16)':U
&scop sort-clmn_18-br-pump  r-pump.rvs-prev-code
&scop enabled-clmn-br-pump  {&sort-clmn_18-br-pump}

define buffer cli-buf for ub.clients.

/* Local Variable Definitions */
define variable rvs-line-rec     as recid     no-undo.
define variable rvs-pump-rec     as recid     no-undo.
define variable filter-point     as character no-undo initial "":U.
define variable filter-point0    as character no-undo initial "":U.
define variable sort-column-line as character no-undo.
define variable sort-column-pump as character no-undo.

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets */
define button   Btn_Exit  label "Вы&ход"      size-{&size-type} 10.00 BY 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "      size-{&size-type} 10.00 BY 1.00 default auto-go.
define button {&Btn_View} label "&Просмотр"   size-{&size-type} 12.00 by 1.00 default.
define button   Btn_Pump  label "Просм. ТР&К" size-{&size-type} 12.00 by 1.00 default.
define button   Btn_Notes label "При&мечание" size-{&size-type} 12.00 by 1.00 default.
define button {&Btn_Help} label "Помо&щь"     size-{&size-type} 10.00 BY 1.00 default.

define variable agnt-name as character no-undo format "x(256)":U {&text} 14.00 by 1.00.
define variable boss-name as character no-undo format "x(256)":U {&text} 14.00 by 1.00.
define variable wrkr-name as character no-undo format "x(256)":U {&text} 14.00 by 1.00.

define rectangle r-rect-1 edge-pixels 3 graphic-edge no-fill size-{&size-type} 98.25 by 1.50.

define new shared query br-line for r-line, r-goods, r-place scrolling.

define browse br-line query br-line no-lock display
  {&sort-clmn_1-br-line}  column-label {&label-clmn_1-br-line}  format {&form-clmn_1-br-line}
  {&sort-clmn_2-br-line}  column-label {&label-clmn_2-br-line}  format {&form-clmn_2-br-line}
  {&sort-clmn_3-br-line}  column-label {&label-clmn_3-br-line}  format {&form-clmn_3-br-line}
  {&sort-clmn_4-br-line}  column-label {&label-clmn_4-br-line}  format {&form-clmn_4-br-line}
  {&sort-clmn_5-br-line}  column-label {&label-clmn_5-br-line}  format {&form-clmn_5-br-line}
  {&sort-clmn_6-br-line}  column-label {&label-clmn_6-br-line}  format {&form-clmn_6-br-line}
  {&sort-clmn_7-br-line}  column-label {&label-clmn_7-br-line}  format {&form-clmn_7-br-line}
  {&sort-clmn_8-br-line}  column-label {&label-clmn_8-br-line}  format {&form-clmn_8-br-line}
  {&sort-clmn_9-br-line}  column-label {&label-clmn_9-br-line}  format {&form-clmn_9-br-line}
  {&sort-clmn_10-br-line} column-label {&label-clmn_10-br-line} format {&form-clmn_10-br-line}
  {&sort-clmn_11-br-line} column-label {&label-clmn_11-br-line} format {&form-clmn_11-br-line}
  {&sort-clmn_12-br-line} column-label {&label-clmn_12-br-line} format {&form-clmn_12-br-line}
  {&sort-clmn_13-br-line} column-label {&label-clmn_13-br-line} format {&form-clmn_13-br-line}
  {&sort-clmn_14-br-line} column-label {&label-clmn_14-br-line} format {&form-clmn_14-br-line}
  {&sort-clmn_15-br-line} column-label {&label-clmn_15-br-line} format {&form-clmn_15-br-line}
  {&sort-clmn_16-br-line} column-label {&label-clmn_16-br-line} format {&form-clmn_16-br-line}
  {&sort-clmn_17-br-line} column-label {&label-clmn_17-br-line} format {&form-clmn_17-br-line}
  {&sort-clmn_18-br-line} column-label {&label-clmn_18-br-line} format {&form-clmn_18-br-line}
  {&sort-clmn_19-br-line} column-label {&label-clmn_19-br-line} format {&form-clmn_19-br-line}
  {&sort-clmn_20-br-line} column-label {&label-clmn_20-br-line} format {&form-clmn_20-br-line}
  {&sort-clmn_21-br-line} column-label {&label-clmn_21-br-line} format {&form-clmn_21-br-line}
  {&sort-clmn_22-br-line} column-label {&label-clmn_22-br-line} format {&form-clmn_22-br-line}
  {&sort-clmn_23-br-line} column-label {&label-clmn_23-br-line} format {&form-clmn_23-br-line}
  {&sort-clmn_24-br-line} column-label {&label-clmn_24-br-line} format {&form-clmn_24-br-line}
  {&sort-clmn_25-br-line} column-label {&label-clmn_25-br-line} format {&form-clmn_25-br-line}
  {&sort-clmn_26-br-line} column-label {&label-clmn_26-br-line} format {&form-clmn_26-br-line}
  {&sort-clmn_27-br-line} column-label {&label-clmn_27-br-line} format {&form-clmn_27-br-line}
  {&sort-clmn_28-br-line} column-label {&label-clmn_28-br-line} format {&form-clmn_28-br-line}
  {&sort-clmn_29-br-line} column-label {&label-clmn_29-br-line} format {&form-clmn_29-br-line}
  {&sort-clmn_30-br-line} column-label {&label-clmn_30-br-line} format {&form-clmn_30-br-line}
  {&sort-clmn_31-br-line} column-label {&label-clmn_31-br-line} format {&form-clmn_31-br-line}
  {&sort-clmn_32-br-line} column-label {&label-clmn_32-br-line} format {&form-clmn_32-br-line}
  {&sort-clmn_33-br-line} column-label {&label-clmn_33-br-line} format {&form-clmn_33-br-line}
  {&sort-clmn_34-br-line} column-label {&label-clmn_34-br-line} format {&form-clmn_34-br-line}
  {&sort-clmn_35-br-line} column-label {&label-clmn_35-br-line} format {&form-clmn_35-br-line}
  {&sort-clmn_36-br-line} column-label {&label-clmn_36-br-line} format {&form-clmn_36-br-line}
  enable
  {&enabled-clmn-br-line}
with no-row-markers separators size-{&size-type} 98.25 by 6.00.

define new shared query br-pump for r-pump scrolling.

define browse br-pump query br-pump no-lock display
  {&sort-clmn_1-br-pump}  column-label {&label-clmn_1-br-pump}  format {&form-clmn_1-br-pump}
  {&sort-clmn_2-br-pump}  column-label {&label-clmn_2-br-pump}  format {&form-clmn_2-br-pump}
  {&sort-clmn_3-br-pump}  column-label {&label-clmn_3-br-pump}  format {&form-clmn_3-br-pump}
  {&sort-clmn_4-br-pump}  column-label {&label-clmn_4-br-pump}  format {&form-clmn_4-br-pump}
  {&sort-clmn_5-br-pump}  column-label {&label-clmn_5-br-pump}  format {&form-clmn_5-br-pump}
  {&sort-clmn_6-br-pump}  column-label {&label-clmn_6-br-pump}  format {&form-clmn_6-br-pump}
  {&sort-clmn_7-br-pump}  column-label {&label-clmn_7-br-pump}  format {&form-clmn_7-br-pump}
  {&sort-clmn_8-br-pump}  column-label {&label-clmn_8-br-pump}  format {&form-clmn_8-br-pump}
  {&sort-clmn_9-br-pump}  column-label {&label-clmn_9-br-pump}  format {&form-clmn_9-br-pump}
  {&sort-clmn_10-br-pump} column-label {&label-clmn_10-br-pump} format {&form-clmn_10-br-pump}
  {&sort-clmn_11-br-pump} column-label {&label-clmn_11-br-pump} format {&form-clmn_11-br-pump}
  {&sort-clmn_12-br-pump} column-label {&label-clmn_12-br-pump} format {&form-clmn_12-br-pump}
  {&sort-clmn_13-br-pump} column-label {&label-clmn_13-br-pump} format {&form-clmn_13-br-pump}
  {&sort-clmn_14-br-pump} column-label {&label-clmn_14-br-pump} format {&form-clmn_14-br-pump}
  {&sort-clmn_15-br-pump} column-label {&label-clmn_15-br-pump} format {&form-clmn_15-br-pump}
  {&sort-clmn_16-br-pump} column-label {&label-clmn_16-br-pump} format {&form-clmn_16-br-pump}
  {&sort-clmn_17-br-pump} column-label {&label-clmn_17-br-pump} format {&form-clmn_17-br-pump}
  {&sort-clmn_18-br-pump} column-label {&label-clmn_18-br-pump} format {&form-clmn_18-br-pump}
  enable
  {&enabled-clmn-br-pump}
with no-row-markers separators size-{&size-type} 98.25 by 6.00.

/* ************************ Frame Definitions *********************** */
define frame {&FRAME-NAME}
  "Объект:"                            at row  1.50 col 10.00
  ub.c-rvs-doc.obj-code               at row  1.50 col 16.00 {&align} no-label                       {&text}    10.00 by 1.00
  ub.c-rvs-doc.obj-type               at row  1.50 col 26.00 {&align} no-label                       {&text}     4.13 by 1.00
     ub.clients.obj-name               at row  1.50 col 33.00 {&align} no-label fgcolor 4             {&text}    40.00 by 1.00
  ub.c-rvs-doc.out-code               at row  2.50 col 20.00 {&align}    label "На основе документа" {&view}
  ub.c-rvs-doc.doc-date               at row  2.50 col 41.00 {&align}                                {&view}
  ub.c-rvs-doc.agnt                   at row  5.00 col  4.50 {&align}   format "999999999":U         {&fill-in} 10.00 by 1.00
    agnt-name                          at row  5.00 col 15.00 {&align} no-label fgcolor 4
  ub.c-rvs-doc.wrkr                   at row  4.00 col  4.50 {&align}   format "999999999":U         {&fill-in} 10.00 by 1.00
    wrkr-name                          at row  4.00 col 15.00 {&align} no-label fgcolor 4
  ub.c-rvs-doc.boss                   at row  6.00 col  4.50 {&align}   format "999999999":U         {&fill-in} 10.00 by 1.00
    boss-name                          at row  6.00 col 15.00 {&align} no-label fgcolor 4
  ub.c-rvs-doc.state-measure-qnty     at row  3.25 col 38.00 {&align}    label "Факт"                {&view}
  ub.c-rvs-doc.measure-qnty           at row  3.25 col 62.00 {&align}    label "Измер"               {&view}
  ub.c-rvs-doc.system-qnty            at row  3.25 col 86.00 {&align}                                {&view}
  ub.c-rvs-doc.state-measure-cli-qnty at row  4.00 col 50.00 {&align}    label "Вес"                 {&view}
  ub.c-rvs-doc.measure-cli-qnty       at row  4.00 col 80.00 {&align}    label "Измер.вес"           {&view}
  ub.c-rvs-doc.system-cli-qnty        at row  5.00 col 50.00 {&align}    label "Учет вес"            {&view}
  ub.c-rvs-doc.system-cli-avrg-qnty   at row  5.00 col 80.00 {&align}    label "Вес по ср.пл-ти"     {&view}
  ub.c-rvs-doc.state-mh-qnty          at row  6.00 col 38.00 {&align}    label "Оборот"              {&view}
  ub.c-rvs-doc.state-am-qnty          at row  6.00 col 62.50 {&align}    label "Сумма"               {&view}
  ub.c-rvs-doc.state-cf-qnty          at row  6.00 col 87.75 {&align}    label "Наливы"              {&view}
  ub.c-rvs-doc.state-measure-tc-qnty  at row  7.00 col  1.00             label "tc: Факт"            {&view}
  ub.c-rvs-doc.measure-tc-qnty        at row  7.00 col 25.00             label "Измер"               {&view}
  ub.c-rvs-doc.state-brutto-tc-qnty   at row  7.00 col 46.00             label "Факт брутто"         {&view}
  ub.c-rvs-doc.brutto-tc-qnty         at row  7.00 col 72.00             label "Измер брутто"        {&view}
  br-line                       at row  8.00 col  1.50
  br-pump                       at row 14.00 col  1.50
  r-rect-1                             at row 20.25 col  1.50
    Btn_Exit                           at row 20.50 col  2.50
  {&Btn_View}                          at row 20.50 col 37.00
    Btn_Pump                           at row 20.50 col 50.00
    Btn_Notes                          at row 20.50 col 63.00
    Btn_OK                             at row 20.50 col 76.25
  {&Btn_Help}                          at row 20.50 col 88.75
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     default-button Btn_OK cancel-button Btn_Exit.

/* ***************  Runtime Attributes AND UIB Settings  ************** */
assign frame {&FRAME-NAME} :scrollable = no.
assign br-line          :num-locked-columns in frame  {&FRAME-NAME}  = 4
       br-pump          :num-locked-columns in frame  {&FRAME-NAME}  = 2
       {&enabled-clmn-br-line} :read-only          in browse br-line = yes
       {&enabled-clmn-br-pump} :read-only          in browse br-pump = yes.

/* ************************  Control Triggers  ************************ */
on end-error, stop of frame {&FRAME-NAME} do:
  apply "CHOOSE":U to Btn_Exit in frame {&FRAME-NAME}.
  return no-apply.
end.

on choose of Btn_OK in frame {&FRAME-NAME} do: /* Ввод */
  { gbl/stdbtn.i }
  apply "GO":U to frame {&FRAME-NAME}.
end.

on choose of Btn_Exit in frame {&FRAME-NAME} do: /* Выход */
  { gbl/stdbtn.i }
end.

on choose of {&Btn_View} in frame {&FRAME-NAME} do: /* Просмотр */
  { gbl/stdbtn.i }
  if not available r-line then do:
    message "Неправильно выбрана строка сверки." view-as alert-box error.
    return no-apply.
  end.
  run proc-lookup-line in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of Btn_Pump in frame {&FRAME-NAME} do: /* Просмотр ТРК */
  { gbl/stdbtn.i }
  if not available r-pump then do:
    message "Неправильно выбрана строка." view-as alert-box error.
    return no-apply.
  end.
  run proc-lookup-pump in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.

on choose of Btn_Notes in frame {&FRAME-NAME} do:
  define variable v-note as character no-undo.

  { gbl/stdbtn.i }
  assign v-note = ub.c-rvs-doc.PS.
  run gbl/notes.w ( input {&lookup}, input-output v-note ).
end.

on value-changed of br-line in frame {&FRAME-NAME} do:
  if available r-line then do:
    run open-br-pump in this-procedure ( input yes,
                                                input no,
                                                input '':U,
                                                input r-line.pl-code,
                                                input r-line.gds-code ).
  end.
end.

assign ParParentProc = p-parent-proc.

{ gbl/f2.i br-line " " " " ParParentProc }

{ gbl/hot-key.i {&Btn_Help} }
{ gbl/hot-key.i {&Btn_View} }

/* ***************************  Main Block  *************************** */
/* Restore the current-window if it is an icon. Otherwise the dialog box will be hidden */
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.

/* parent the dialog-box to the active-window, if there is no parent. */
if valid-handle( active-window ) and frame {&FRAME-NAME} :parent = ? then frame {&FRAME-NAME} :parent = active-window.

/* add trigger to equate window-close to end-error */
on window-close of frame {&FRAME-NAME} do: apply "END-ERROR":U to self. end.

{ gbl/app_help.i }

{ gbl/mv-clmn.i
    &ext-col      = 36
    &frame-name   = {&FRAME-NAME}
    &browse-name  = br-line
    &table-name   = "r-line"
    &start-column = 5              }


{ gbl/srt-clmd.i
    &ext-col              = 36
    &frame-name           = {&FRAME-NAME}
    &browse-name          = br-line
    &table-name           = "r-line"
    &start-column         = 5
    &label-clmn_1         = "{&label-clmn_1-br-line}"
    &sort-clmn_1          = "{&sort-clmn_1-br-line}"
    &label-clmn_2         = "{&label-clmn_2-br-line}"
    &sort-clmn_2          = "{&sort-clmn_2-br-line}"
    &label-clmn_3         = "{&label-clmn_3-br-line}"
    &sort-clmn_3          = "{&sort-clmn_3-br-line}"
    &label-clmn_4         = "{&label-clmn_4-br-line}"
    &sort-clmn_4          = "{&sort-clmn_4-br-line}"
    &label-clmn_5         = "{&label-clmn_5-br-line}"
    &sort-clmn_5          = "{&sort-clmn_5-br-line}"
    &label-clmn_6         = "{&label-clmn_6-br-line}"
    &sort-clmn_6          = "{&sort-clmn_6-br-line}"
    &label-clmn_7         = "{&label-clmn_7-br-line}"
    &sort-clmn_7          = "{&sort-clmn_7-br-line}"
    &label-clmn_8         = "{&label-clmn_8-br-line}"
    &sort-clmn_8          = "{&sort-clmn_8-br-line}"
    &label-clmn_9         = "{&label-clmn_9-br-line}"
    &sort-clmn_9          = "{&sort-clmn_9-br-line}"
    &label-clmn_10        = "{&label-clmn_10-br-line}"
    &sort-clmn_10         = "{&sort-clmn_10-br-line}"
    &dyn_sort-clmn_10     = "{&dyn_sort-clmn_10-br-line}"
    &label-clmn_11        = "{&label-clmn_11-br-line}"
    &sort-clmn_11         = "{&sort-clmn_11-br-line}"
    &dyn_sort-clmn_11     = "{&dyn_sort-clmn_11-br-line}"
    &label-clmn_12        = "{&label-clmn_12-br-line}"
    &sort-clmn_12         = "{&sort-clmn_12-br-line}"
    &label-clmn_13        = "{&label-clmn_13-br-line}"
    &sort-clmn_13         = "{&sort-clmn_13-br-line}"
    &label-clmn_14        = "{&label-clmn_14-br-line}"
    &sort-clmn_14         = "{&sort-clmn_14-br-line}"
    &label-clmn_15        = "{&label-clmn_15-br-line}"
    &sort-clmn_15         = "{&sort-clmn_15-br-line}"
    &label-clmn_16        = "{&label-clmn_16-br-line}"
    &sort-clmn_16         = "{&sort-clmn_16-br-line}"
    &label-clmn_17        = "{&label-clmn_17-br-line}"
    &sort-clmn_17         = "{&sort-clmn_17-br-line}"
    &label-clmn_18        = "{&label-clmn_18-br-line}"
    &sort-clmn_18         = "{&sort-clmn_18-br-line}"
    &label-clmn_19        = "{&label-clmn_19-br-line}"
    &sort-clmn_19         = "{&sort-clmn_19-br-line}"
    &label-clmn_20        = "{&label-clmn_20-br-line}"
    &sort-clmn_20         = "{&sort-clmn_20-br-line}"
    &label-clmn_21        = "{&label-clmn_21-br-line}"
    &sort-clmn_21         = "{&sort-clmn_21-br-line}"
    &label-clmn_22        = "{&label-clmn_22-br-line}"
    &sort-clmn_22         = "{&sort-clmn_22-br-line}"
    &label-clmn_23        = "{&label-clmn_23-br-line}"
    &sort-clmn_23         = "{&sort-clmn_23-br-line}"
    &label-clmn_24        = "{&label-clmn_24-br-line}"
    &sort-clmn_24         = "{&sort-clmn_24-br-line}"
    &label-clmn_25        = "{&label-clmn_25-br-line}"
    &sort-clmn_25         = "{&sort-clmn_25-br-line}"
    &label-clmn_26        = "{&label-clmn_26-br-line}"
    &sort-clmn_26         = "{&sort-clmn_26-br-line}"
    &label-clmn_27        = "{&label-clmn_27-br-line}"
    &sort-clmn_27         = "{&sort-clmn_27-br-line}"
    &label-clmn_28        = "{&label-clmn_28-br-line}"
    &sort-clmn_28         = "{&sort-clmn_28-br-line}"
    &label-clmn_29        = "{&label-clmn_29-br-line}"
    &sort-clmn_29         = "{&sort-clmn_29-br-line}"
    &label-clmn_30        = "{&label-clmn_30-br-line}"
    &sort-clmn_30         = "{&sort-clmn_30-br-line}"
    &label-clmn_31        = "{&label-clmn_31-br-line}"
    &sort-clmn_31         = "{&sort-clmn_31-br-line}"
    &label-clmn_32        = "{&label-clmn_32-br-line}"
    &sort-clmn_32         = "{&sort-clmn_32-br-line}"
    &label-clmn_33        = "{&label-clmn_33-br-line}"
    &sort-clmn_33         = "{&sort-clmn_33-br-line}"
    &label-clmn_34        = "{&label-clmn_34-br-line}"
    &sort-clmn_34         = "{&sort-clmn_34-br-line}"
    &label-clmn_35        = "{&label-clmn_35-br-line}"
    &sort-clmn_35         = "{&sort-clmn_35-br-line}"
    &label-clmn_36        = "{&label-clmn_36-br-line}"
    &sort-clmn_36         = "{&sort-clmn_36-br-line}"
    &open-query           = "run open-br-line in this-procedure ( input yes, input no, input '':U )."
    &open-query-otherwise = "run open-br-line in this-procedure ( input yes, input no, input '':U )."
    &re-move-clmn         = "no"
    &mv-brw-default       = "yes"
    &sort-column-name     = sort-column-line
    }

{ gbl/mv-clmn.i
    &ext-col      = 18
    &frame-name   = {&FRAME-NAME}
    &browse-name  = br-pump
    &table-name   = "r-pump"
    &start-column = 3              }

{ gbl/srt-clmd.i
    &ext-col              = 18
    &frame-name           = {&FRAME-NAME}
    &browse-name          = br-pump
    &table-name           = "r-pump"
    &start-column         = 3
    &label-clmn_1         = "{&label-clmn_1-br-pump}"
    &sort-clmn_1          = "{&sort-clmn_1-br-pump}"
    &label-clmn_2         = "{&label-clmn_2-br-pump}"
    &sort-clmn_2          = "{&sort-clmn_2-br-pump}"
    &label-clmn_3         = "{&label-clmn_3-br-pump}"
    &sort-clmn_3          = "{&sort-clmn_3-br-pump}"
    &label-clmn_4         = "{&label-clmn_4-br-pump}"
    &sort-clmn_4          = "{&sort-clmn_4-br-pump}"
    &label-clmn_5         = "{&label-clmn_5-br-pump}"
    &sort-clmn_5          = "{&sort-clmn_5-br-pump}"
    &label-clmn_6         = "{&label-clmn_6-br-pump}"
    &sort-clmn_6          = "{&sort-clmn_6-br-pump}"
    &label-clmn_7         = "{&label-clmn_7-br-pump}"
    &sort-clmn_7          = "{&sort-clmn_7-br-pump}"
    &label-clmn_8         = "{&label-clmn_8-br-pump}"
    &sort-clmn_8          = "{&sort-clmn_8-br-pump}"
    &label-clmn_9         = "{&label-clmn_9-br-pump}"
    &sort-clmn_9          = "{&sort-clmn_9-br-pump}"
    &label-clmn_10        = "{&label-clmn_10-br-pump}"
    &sort-clmn_10         = "{&sort-clmn_10-br-pump}"
    &label-clmn_11        = "{&label-clmn_11-br-pump}"
    &sort-clmn_11         = "{&sort-clmn_11-br-pump}"
    &label-clmn_12        = "{&label-clmn_12-br-pump}"
    &sort-clmn_12         = "{&sort-clmn_12-br-pump}"
    &label-clmn_13        = "{&label-clmn_13-br-pump}"
    &sort-clmn_13         = "{&sort-clmn_13-br-pump}"
    &label-clmn_14        = "{&label-clmn_14-br-pump}"
    &sort-clmn_14         = "{&sort-clmn_14-br-pump}"
    &label-clmn_15        = "{&label-clmn_15-br-pump}"
    &sort-clmn_15         = "{&sort-clmn_15-br-pump}"
    &label-clmn_16        = "{&label-clmn_16-br-pump}"
    &sort-clmn_16         = "{&sort-clmn_16-br-pump}"
    &label-clmn_17        = "{&label-clmn_17-br-pump}"
    &sort-clmn_17         = "{&sort-clmn_17-br-pump}"
    &label-clmn_18        = "{&label-clmn_18-br-pump}"
    &sort-clmn_18         = "{&sort-clmn_18-br-pump}"
    &open-query           = " ~
                             run open-br-pump in this-procedure ( input yes, ~
                                                                         input no, ~
                                                                         input '':U, ~
                                                                         input r-line.pl-code, ~
                                                                         input r-line.gds-code ). ~
                            "
    &open-query-otherwise = " ~
                             run open-br-pump in this-procedure ( input yes, ~
                                                                         input no, ~
                                                                         input '':U, ~
                                                                         input r-line.pl-code, ~
                                                                         input r-line.gds-code ). ~
                            "
    &re-move-clmn         = "no"
    &mv-brw-default       = "yes"
    &sort-column-name     = sort-column-line
      }

/* Now enable the interface AND wait for the exit condition. */
/* (NOTE: handle ERROR AND END-KEY so cleanup code will always fire. */
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  if p-mode <> {&lookup} then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    undo Main-Block, return error.
  end.
  find ub.c-rvs-doc no-lock where recid( ub.c-rvs-doc ) = p-rid no-error.
  if not available ub.c-rvs-doc then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Не найдена КАРТОЧКА ИСТОРИИ СВЕРКИ."
    view-as alert-box error.
    undo Main-Block, return error.
  end.

  find ub.clients no-lock where
       ub.clients.obj-type = ub.c-rvs-doc.obj-type and
       ub.clients.obj-code = ub.c-rvs-doc.obj-code no-error.
  assign frame {&FRAME-NAME} :title =
    ( if available ub.clients then substring( ub.clients.obj-name, 1, 35 ) else (
      ub.c-rvs-doc.obj-type + " ":U + string( ub.c-rvs-doc.obj-code ) ) ) +
    ":   КАРТОЧКА ИСТОРИИ ИЗМЕНЕНИЯ ДОКУМЕНТА СВЕРКИ - " +
      ub.c-rvs-doc.status_  + " № " + ub.c-rvs-doc.rvs-code + "      - " + p-mode.
  if available ub.clients then do:
    display     ub.clients.obj-name with frame {&FRAME-NAME}.
  end.
  else do:
    display ? @ ub.clients.obj-name with frame {&FRAME-NAME}.
  end.

  disable all with frame {&FRAME-NAME}.
  assign {&enabled-clmn-br-line} :read-only in browse br-line = yes
         {&enabled-clmn-br-pump} :read-only in browse br-pump = yes.

  display ub.c-rvs-doc.obj-code
          ub.c-rvs-doc.obj-type
          ub.c-rvs-doc.doc-date
          ub.c-rvs-doc.state-measure-qnty
          ub.c-rvs-doc.measure-qnty
          ub.c-rvs-doc.system-qnty
          ub.c-rvs-doc.state-measure-cli-qnty
          ub.c-rvs-doc.measure-cli-qnty
          ub.c-rvs-doc.system-cli-qnty
          ub.c-rvs-doc.system-cli-avrg-qnty
          ub.c-rvs-doc.state-mh-qnty
          ub.c-rvs-doc.state-am-qnty
          ub.c-rvs-doc.state-cf-qnty
          ub.c-rvs-doc.out-code
          ub.c-rvs-doc.state-measure-tc-qnty
          ub.c-rvs-doc.measure-tc-qnty
          ub.c-rvs-doc.state-brutto-tc-qnty
          ub.c-rvs-doc.brutto-tc-qnty
  with frame {&FRAME-NAME}.

  enable Btn_Exit {&Btn_Help} {&Btn_View} Btn_Pump Btn_Notes br-line br-pump with frame {&FRAME-NAME}.
  if p-mode = {&lookup} then do: hide Btn_OK in frame {&FRAME-NAME}. end.

  { str/psn-chk.i wrkr on ub.c-rvs-doc  v-ref-rec}
  { str/psn-chk.i agnt on ub.c-rvs-doc  v-ref-rec}
  { str/psn-chk.i boss on ub.c-rvs-doc  v-ref-rec}

  run open-br-line in this-procedure ( input yes, input no, input '':U ).
  apply "VALUE-CHANGED":U to br-line in frame {&FRAME-NAME}.
  if num-results( "br-line" ) > 0 then do: if br-line :refresh( ) then. end.

  wait-for go of frame {&FRAME-NAME}.
end. /* Main-Block */
hide frame {&FRAME-NAME} no-pause.

/* **********************  Internal Procedures  *********************** */
procedure open-br-line :
  define input parameter p-open-query     as logical   no-undo.
  define input parameter p-find-next      as logical   no-undo.
  define input parameter p-find-condition as character no-undo.

  define variable l-query-was-opened as logical   no-undo.
  define variable sort-column-phrase as character no-undo.

  define variable p-proc-hand as handle    no-undo.
  define variable p-rvs-code  as character no-undo.
  define variable p-chip-num  as integer   no-undo.

  /* {&SetCursorWait} */
  /* run WaitFram-Show in this-procedure ( input "Ждите..." ). */
  assign p-rvs-code  = ub.c-rvs-doc.rvs-code
         p-chip-num  = ub.c-rvs-doc.chip-num
         p-proc-hand = this-procedure :handle.

  case sort-column-line :
    when "":U then do: assign sort-column-phrase = "":U. end.
    otherwise      do: assign sort-column-phrase = "by " + sort-column-line. end.
  end case. /* sort-column-name */

  &scop flt-open-open-query         open query br-line for each r-line no-lock
  &scop flt-open-dyn_open-query     for each r-line no-lock
  &scop flt-open-query-handle       query br-line:handle
  &scop flt-open-open-query-tail    , first r-goods     no-lock where r-goods.gds-code = r-line.gds-code ~
                                    , first r-place     no-lock where r-place.obj-type = r-line.obj-type and ~
                                                                      r-place.obj-code = r-line.obj-code and ~
                                                                      r-place.pl-code  = r-line.pl-code
  &scop flt-open-query-was-opened   l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point         filter-point
  &scop flt-open-set-filter-name    set-filter-name
  &scop flt-open-indexed-reposition /* indexed-reposition */
  &scop flt-open-query              p-open-query
  &scop flt-open-table-name         r-line
  &scop flt-open-search-option      no-lock
  &scop flt-open-find-next          p-find-next
  &scop flt-open-find-recid         doc-rec
  &scop flt-open-find-condition     p-find-condition
  &scop flt-open-find-buffer-name   r-line
  &scop flt-open-waitfram           yes

  define variable l-open-query as logical no-undo.

  /* {&SetCursorWait} */
  find ub.clients no-lock where
       ub.clients.obj-type = ub.c-rvs-doc.obj-type and
       ub.clients.obj-code = ub.c-rvs-doc.obj-code no-error.
  assign frame {&FRAME-NAME} :title = ( if available ub.clients then substring( ub.clients.obj-name, 1, 35 )
                                        else ( ub.c-rvs-doc.obj-type + " ":U + string( ub.c-rvs-doc.obj-code ) ) ) +
     ":   КАРТОЧКА ИСТОРИИ ИЗМЕНЕНИЯ ДОКУМЕНТА СВЕРКИ - " + ub.c-rvs-doc.status_  + " № " + ub.c-rvs-doc.rvs-code +
     "      - " + p-mode.
  { gbl/fltopend.i
      &where-cond = " ~
                      r-line.rvs-code = p-rvs-code and ~
                      r-line.chip-num = p-chip-num ~
                    "
      &dyn_where-cond = " substitute('r-line.rvs-code = &1&2&1 and r-line.chip-num = &3', ~{&double-quote~}, p-rvs-code, p-chip-num )"
      &use-ind    = "  "
      &by         = "  "                                   }
  /* {&SetCursorWait} */
  if p-open-query <> yes then do: reposition br-line to recid doc-rec no-error. end.
  /* run WaitFram-Hide in this-procedure. */
  apply "VALUE-CHANGED":U to br-line in frame {&FRAME-NAME}.
  apply "ENTRY":U         to br-line in frame {&FRAME-NAME}.
  /* {&SetCursorNo} */
end procedure. /* open-br-line */

procedure open-br-pump :
  define input parameter p-open-query     as logical   no-undo.
  define input parameter p-find-next      as logical   no-undo.
  define input parameter p-find-condition as character no-undo.
  define input parameter p-pl-code        as integer   no-undo.
  define input parameter p-gds-code       as integer   no-undo.

  define variable l-query-was-opened as logical   no-undo.
  define variable sort-column-phrase as character no-undo.

  define variable p-proc-hand as handle    no-undo.
  define variable p-rvs-code  as character no-undo.
  define variable p-chip-num  as integer   no-undo.
  define variable p-obj-type  as character no-undo.
  define variable p-obj-code  as integer   no-undo.

  assign p-rvs-code  = ub.c-rvs-doc.rvs-code
         p-chip-num  = ub.c-rvs-doc.chip-num
         p-obj-type  = ub.c-rvs-doc.obj-type
         p-obj-code  = ub.c-rvs-doc.obj-code
         p-proc-hand = this-procedure :handle.

  case sort-column-pump :
    when "":U then do: assign sort-column-phrase = "":U. end.
    otherwise      do: assign sort-column-phrase = "by " + sort-column-pump. end.
  end case. /* sort-column-name */

  &scop flt-open-open-query         open query br-pump for each r-pump
  &scop flt-open-dyn_open-query     for each r-pump
  &scop flt-open-query-handle       query br-pump:handle
  &scop flt-open-open-query-tail
  &scop flt-open-query-was-opened   l-query-was-opened
  &scop flt-open-sort-column-phrase sort-column-phrase
  &scop flt-open-call-point         filter-point0
  &scop flt-open-set-filter-name    set-filter-name
  &scop flt-open-indexed-reposition indexed-reposition
  &scop flt-open-query              p-open-query
  &scop flt-open-table-name         r-pump
  &scop flt-open-search-option      no-lock
  &scop flt-open-find-next          p-find-next
  &scop flt-open-find-recid         doc-rec
  &scop flt-open-find-condition     p-find-condition
  &scop flt-open-find-buffer-name   r-pump
  &scop flt-open-waitfram           yes

  define variable l-open-query as logical no-undo.

  { gbl/fltopend.i
      &where-cond = " ~
                      r-pump.rvs-code = p-rvs-code and ~
                      r-pump.chip-num = p-chip-num and ~
                      r-pump.obj-type = p-obj-type and ~
                      r-pump.obj-code = p-obj-code and ~
                      r-pump.pl-code  = p-pl-code  and ~
                      r-pump.gds-code = p-gds-code ~
                    "
      &dyn_where-cond = " substitute('~
                      r-pump.rvs-code = &1&2&1 and ~
                      r-pump.chip-num = &3 and ~
                      r-pump.obj-type = &1&4&1 and ~
                      r-pump.obj-code = &5 and ~
                      r-pump.pl-code  = &6 and ~
                      r-pump.gds-code = &7', ~{&double-quote~}, p-rvs-code, p-chip-num, p-obj-type, p-obj-code, p-pl-code, p-gds-code) ~
                    "
      &use-ind    = "  "
      &by         = "  "                                       }
  if p-open-query <> yes then do: reposition br-pump to recid doc-rec no-error. end.
  apply "VALUE-CHANGED":U to br-pump in frame {&FRAME-NAME}.
  /* apply "ENTRY":U         to br-pump in frame {&FRAME-NAME}. */
end procedure. /* open-br-pump */

procedure get-dev-fact :
    define input parameter p-state-measure-qnty as decimal          no-undo.
    define input parameter p-state-add-qnty     as decimal          no-undo.
    define input parameter p-system-qnty        as decimal          no-undo.
    define output parameter p-qty               as decimal          no-undo.

  assign p-qty = p-state-measure-qnty + p-state-add-qnty - p-system-qnty.
end procedure. /* get-dev-fact */

procedure get-dev-meas :
  define        parameter buffer loc-buf for ub.c-rvs-line.
  define output parameter        p-qty   as  decimal no-undo.

  assign p-qty = loc-buf.measure-qnty + loc-buf.state-add-qnty - loc-buf.system-qnty.
end procedure. /* get-dev-meas */

procedure proc-lookup-pump :
  define buffer buf_goods for ub.goods.

  if not available r-pump then do:
    message "Неправильный выбор строки." view-as alert-box error.
    return error.
  end.
  assign rvs-line-rec = ( if available r-line then recid( r-line ) else ? )
         rvs-pump-rec = recid( r-pump ).
  find first buf_goods where buf_goods.gds-code = r-pump.gds-code no-lock.
  run str/rvscpump.w ( input {&lookup}, input-output rvs-pump-rec ).
  find ub.c-rvs-doc where recid( ub.c-rvs-doc ) = p-rid.
end procedure. /* proc-lookup-pump */

procedure proc-lookup-line :
  define buffer buf_goods for ub.goods.

  if not available r-line then do:
    message "Неправильный выбор строки." view-as alert-box error.
    return error.
  end.
  assign rvs-line-rec = recid( r-line )
         rvs-pump-rec = ( if available r-pump then recid( r-pump ) else ? ).
  find first buf_goods no-lock where buf_goods.gds-code = r-line.gds-code.
  run str/rvscline.w ( input {&lookup}, input-output rvs-line-rec ).
  find ub.c-rvs-doc no-lock where recid( ub.c-rvs-doc ) = p-rid.
end procedure. /* proc-lookup-line */