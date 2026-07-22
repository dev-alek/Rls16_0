/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка документа сверки (заведение, редактирование, просмотр)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/06
Author: Dmitry Ukhanov
Creation date: 11/29/06

Create: Суслов Алексей Юрьевич
Дата создания: 09/20/05

*/

define input        parameter parparentproc as handle    no-undo .
define input        parameter pardoc-mode   as character no-undo .
define input        parameter parrvs-type   as character no-undo .
define input        parameter parall-place  as logical   no-undo .
define input-output parameter parrvs-rec    as recid     no-undo .

define variable varlog          as logical   no-undo.

&scop frame-name       d-rvs
&scop browse-name      br-line
&scop browse-name-pump br-pump

/* ***************************  definitions  ************************** */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Обработка документа сверки (заведение, редактирование, просмотр)":U.

{ cmp/vssrevis.i      }
{ cmp/showinf.i       }
{ str/libbcrcn.i      }
{ cmp/str-glbl.i      }
{ cmp/library.i       }
{ gbl/color.i         }
{ gbl/dtm.i           }
{ str/doc-code.i      }
{ gbl/getcntxt.i def  }
{ gbl/getcntxt.i get  }
{ str/lib-rvs.i       }
{ gbl/waitfram.i      }
{ str/rvsttdef.i file }
{ ref/gds-attr.i      }
{ str/is-gas.i        }
{ str/is-sug.i        }
{ str/placelib.i      }
{ gbl/db-attr.i       }
{ gbl/ptrlprop.i def  }

define buffer r-doc             for ub.rvs-doc.
define buffer cur_shift-obj     for ub.shift-obj.
define buffer prev_shift-obj    for ub.shift-obj.
define buffer prev_rvs-doc      for ub.rvs-doc.
define buffer prev_icnt-doc     for ub.icnt-doc.
define buffer buf_rvs-line-attr for ub.rvs-line-attr.
define buffer buf_doc-attr      for ub.doc-attr.

define variable v-ref-rec         as recid     no-undo .
define variable ii                as integer   no-undo.
define variable bcol              as handle    extent 37 no-undo.

/* ********************  preprocessor definitions  ******************** */
&scop open-query-{&browse-name} open query {&browse-name} ~
   for each  ub.rvs-line no-lock where ~
             ub.rvs-line.rvs-code =    r-doc.rvs-code ~
     , first ub.goods        no-lock where ~
             ub.goods.gds-code        = ub.rvs-line.gds-code ~
     , first ub.place                where ~
             ub.place.obj-type        = ub.rvs-line.obj-type and ~
             ub.place.obj-code        = ub.rvs-line.obj-code and ~
             ub.place.pl-code         = ub.rvs-line.pl-code 
             

&scop open-query-{&browse-name}-default {&open-query-{&browse-name}}.

&scop open-query-{&browse-name-pump} open query {&browse-name-pump} ~
   for each ub.rvs-line-pump no-lock where ~
            ub.rvs-line-pump.rvs-code = ub.rvs-line.rvs-code and ~
            ub.rvs-line-pump.obj-type = ub.rvs-line.obj-type and ~
            ub.rvs-line-pump.obj-code = ub.rvs-line.obj-code and ~
            ub.rvs-line-pump.pl-code  = ub.rvs-line.pl-code  and ~
            ub.rvs-line-pump.gds-code = ub.rvs-line.gds-code

&scop open-query-{&browse-name-pump}-default {&open-query-{&browse-name-pump}}.

&scop label-clmn_1-br-line  '*'
&scop sort-clmn_1-br-line   get-mark (buffer ub.rvs-line)
&scop label-clmn_2-br-line  'Артикул'
&scop sort-clmn_2-br-line   ub.goods.artic
&scop label-clmn_3-br-line  'Название'
&scop sort-clmn_3-br-line   ub.goods.gds-name
&scop label-clmn_4-br-line  'Скл.место'
&scop sort-clmn_4-br-line   ub.rvs-line.pl-code
&scop label-clmn_5-br-line  'Номер резервуара'
&scop sort-clmn_5-br-line   place.loc1
&scop label-clmn_6-br-line  'Факт остаток'
&scop sort-clmn_6-br-line   ub.rvs-line.state-measure-qnty
&scop label-clmn_7-br-line  'Измер. остаток'
&scop sort-clmn_7-br-line   ub.rvs-line.measure-qnty
&scop label-clmn_8-br-line  'Учет'
&scop sort-clmn_8-br-line   ub.rvs-line.system-qnty
&scop label-clmn_9-br-line  'Первонач.учет'
&scop sort-clmn_9-br-line   ub.rvs-line.orig-system-qnty
&scop label-clmn_10-br-line 'Факт в!трубопроводе'
&scop sort-clmn_10-br-line  ub.rvs-line.state-add-qnty
&scop label-clmn_11-br-line 'Отклонение(факт)'
&scop sort-clmn_11-br-line  deviation-fact(buffer ub.rvs-line)
&scop label-clmn_12-br-line 'Отклонение(измер)'
&scop sort-clmn_12-br-line  deviation-measure(buffer ub.rvs-line)
&scop label-clmn_13-br-line 'Допустимое!отклонение'
&scop sort-clmn_13-br-line  ub.rvs-line.tolerance
&scop label-clmn_14-br-line 'Факт брутто'
&scop sort-clmn_14-br-line  ub.rvs-line.state-brutto-qnty
&scop sort-clmn_15-br-line  ub.rvs-line.brutto-qnty
&scop sort-clmn_16-br-line  ub.rvs-line.state-density
&scop sort-clmn_17-br-line  ub.rvs-line.density
&scop sort-clmn_18-br-line  ub.rvs-line.state-measure-cli-qnty
&scop sort-clmn_19-br-line  ub.rvs-line.measure-cli-qnty
&scop sort-clmn_20-br-line  ub.rvs-line.system-cli-qnty
&scop sort-clmn_21-br-line  ub.rvs-line.orig-system-cli-qnty
&scop sort-clmn_22-br-line  ub.rvs-line.state-brutto-cli-qnty
&scop sort-clmn_23-br-line  ub.rvs-line.brutto-cli-qnty
&scop sort-clmn_24-br-line  ub.rvs-line.state-mh-qnty
&scop sort-clmn_25-br-line  ub.rvs-line.meas-mh-qnty
&scop sort-clmn_26-br-line  ub.rvs-line.state-am-qnty
&scop sort-clmn_27-br-line  ub.rvs-line.meas-am-qnty
&scop sort-clmn_28-br-line  ub.rvs-line.state-cf-qnty
&scop sort-clmn_29-br-line  ub.rvs-line.meas-cf-qnty
&scop sort-clmn_30-br-line  ub.rvs-line.state-level-total
&scop sort-clmn_31-br-line  ub.rvs-line.level-total
&scop sort-clmn_32-br-line  ub.rvs-line.state-level-petrol
&scop sort-clmn_33-br-line  ub.rvs-line.level-petrol
&scop sort-clmn_34-br-line  ub.rvs-line.state-level-water
&scop sort-clmn_35-br-line  ub.rvs-line.level-water
&scop sort-clmn_36-br-line  ub.rvs-line.state-temperature
&scop sort-clmn_37-br-line  ub.rvs-line.temperature
&scop enabled-clmn          {&sort-clmn_37-br-line}

&scop label-clmn_1-br-line-pump 'ТРК'
&scop sort-clmn_1-br-line-pump  ub.rvs-line-pump.pump-code
&scop label-clmn_2-br-line-pump 'П'
&scop sort-clmn_2-br-line-pump  ub.rvs-line-pump.nozzle-code
&scop sort-clmn_3-br-line-pump  ub.rvs-line-pump.state-mh-qnty
&scop sort-clmn_4-br-line-pump  ub.rvs-line-pump.meas-mh-qnty
&scop sort-clmn_5-br-line-pump  ub.rvs-line-pump.state-am-qnty
&scop sort-clmn_6-br-line-pump  ub.rvs-line-pump.meas-am-qnty
&scop sort-clmn_7-br-line-pump  ub.rvs-line-pump.state-cf-qnty
&scop sort-clmn_8-br-line-pump  ub.rvs-line-pump.meas-cf-qnty
&scop sort-clmn_9-br-line-pump  ub.rvs-line-pump.state-mh-cnt
&scop sort-clmn_10-br-line-pump ub.rvs-line-pump.meas-mh-cnt
&scop sort-clmn_11-br-line-pump ub.rvs-line-pump.state-el-cnt
&scop sort-clmn_12-br-line-pump ub.rvs-line-pump.meas-el-cnt
&scop sort-clmn_13-br-line-pump ub.rvs-line-pump.state-am-cnt
&scop sort-clmn_14-br-line-pump ub.rvs-line-pump.meas-am-cnt
&scop sort-clmn_15-br-line-pump ub.rvs-line-pump.state-cf-cnt
&scop sort-clmn_16-br-line-pump ub.rvs-line-pump.meas-cf-cnt
&scop sort-clmn_17-br-line-pump ub.rvs-line-pump.icnt-code
&scop sort-clmn_18-br-line-pump ub.rvs-line-pump.rvs-prev-code
&scop enabled-clmn-pump         {&sort-clmn_18-br-line-pump}

/* ***********************  control definitions  ********************** */
define variable rvs-line-rec      as recid     no-undo.
define variable rvs-line-pump-rec as recid     no-undo.
define variable varartic          like ub.doc-line.artic no-undo initial " ".
define variable ref-list          as character no-undo.
define variable l-g#stat          as character no-undo.
define variable l-g#type          as character no-undo.
define variable l-g#internal      as logical   no-undo.
define variable varres            as logical   no-undo initial ?.
define variable varrecid          as recid     no-undo.
define variable ptoldfilvalue     as character no-undo.
define variable ptoldfiltype      as character no-undo.
define variable varcur-data       as integer   no-undo.
define variable varnum            as integer   no-undo.
define variable varcur-rvs        as integer   no-undo.
define variable varcur-pump       as logical   no-undo.
define variable gds-rec           as recid     no-undo.
define variable notes             as character no-undo.
define variable rep-rec           as recid     no-undo.
define variable lns-cnt           as integer   no-undo.

define variable v-asi-ip          as character no-undo .
define variable v-asi-port        as character no-undo .
define variable v-asi-type        as character no-undo .
define variable v-attr-type       as character no-undo .

define variable vTimeAutoSkip     as integer  no-undo.

define buffer cli-buf      for ub.clients.
define buffer del-rvs-line for ub.rvs-line.

define button b-help
  label "Помощь":U
  size 10 by 1.

define button b-exit auto-go
  label "Выход":U
  size 10 by 1.

define button b-mark
  label "&*":U
  size 3 by 1.

define button b-add
  label "Добавить":U
  size 10 by 1.

define button b-lkp
  label "Просмотр":U
  size 10 by 1.

define button b-lkp-pump
  label "Просм ТРК":U
  size 10 by 1.


define button b-chg
  label "Изменить":U
  size 10 by 1.

define button b-chg-pump
  label "Изм ТРК":U
  size 10 by 1.

define button b-del
  label "Удалить":U
  size 10 by 1.

define button b-history
  label "История":U
  size 10 by 1.

define button b-notes
  label "Прим.":U
  size 10 by 1.

define button b-meas
  label "Измерение"
  size 10 by 1.

define menu m-add
  menu-item m-add-1  label "Резервуар с его ТРК по товару"                    accelerator "alt-1"
  menu-item m-add-2  label "Все резервуары со всеми ТРК"                      accelerator "alt-2"
  menu-item m-add-3  label "Резервуары по обороту топлива за смену с их ТРК"  accelerator "alt-3".

define menu m-meas
  menu-item m-meas-1 label "Всех резервуаров"        accelerator "alt-1"
  menu-item m-meas-2 label "Всех счетчиков ТРК"      accelerator "alt-2"
  menu-item m-meas-3 label "Текущего резервуара"     accelerator "alt-3"
  menu-item m-meas-4 label "Текущей ТРК"             accelerator "alt-4".


define button r-acc
  image-up          file "btn-down-arrow"
  image-down        file "btn-down-arrow"
  image-insensitive file "btn-down-arrow"
  size 3 by .88.

define button r-agnt     like r-acc.
define button r-boss     like r-acc.
define button r-wrkr     like r-acc.

define variable agnt-name as character format "x(256)":u
  view-as text
  size 11.2 by 1 no-undo.

define variable boss-name as character format "x(256)":u
  view-as text
  size 11.2 by 1 no-undo.

define variable wrkr-name as character format "x(256)":u
  view-as text
  size 11.2 by 1 no-undo.

define variable del-list  as character no-undo.

function get-mark return character (buffer local-rvs-line for ub.rvs-line ).
  if lookup (string (recid (local-rvs-line)), del-list) > 0 then return "*".
  else return "".
end function.

function deviation-fact    return decimal (buffer local-rvs-line for ub.rvs-line ).
  return (local-rvs-line.state-measure-qnty   + local-rvs-line.state-add-qnty - local-rvs-line.system-qnty).
end function.

function deviation-measure return decimal (buffer local-rvs-line for ub.rvs-line ).
  return (local-rvs-line.measure-qnty + local-rvs-line.state-add-qnty - local-rvs-line.system-qnty).
end function.

define query {&browse-name}      for ub.rvs-line, ub.goods, ub.place scrolling.
define query {&browse-name-pump} for ub.rvs-line-pump                scrolling.
define browse {&browse-name} query {&browse-name} no-lock display
  {&sort-clmn_1-br-line}  column-label {&label-clmn_1-br-line}  format "x(1)"
  {&sort-clmn_2-br-line}  column-label {&label-clmn_2-br-line}
      {&sort-clmn_3-br-line}  column-label {&label-clmn_3-br-line}  format "x(15)"
      {&sort-clmn_4-br-line}  column-label {&label-clmn_4-br-line}  FORMAT "99999999999":U
      {&sort-clmn_5-br-line}  column-label {&label-clmn_5-br-line}
      {&sort-clmn_6-br-line}  column-label {&label-clmn_6-br-line}
      {&sort-clmn_7-br-line}  column-label {&label-clmn_7-br-line}
      {&sort-clmn_8-br-line}  column-label {&label-clmn_8-br-line}
      {&sort-clmn_9-br-line}  column-label {&label-clmn_9-br-line}
      {&sort-clmn_10-br-line} column-label {&label-clmn_10-br-line} format "->>,>>>,>>>.<<<"
      {&sort-clmn_11-br-line} column-label {&label-clmn_11-br-line} format "->>,>>>,>>>.<<<"
      {&sort-clmn_12-br-line} column-label {&label-clmn_12-br-line}
      {&sort-clmn_13-br-line} column-label {&label-clmn_13-br-line}
      {&sort-clmn_14-br-line} column-label {&label-clmn_14-br-line}
      {&sort-clmn_15-br-line}
      {&sort-clmn_16-br-line}
      {&sort-clmn_17-br-line}
      {&sort-clmn_18-br-line}
      {&sort-clmn_19-br-line}
      {&sort-clmn_20-br-line}
      {&sort-clmn_21-br-line}
      {&sort-clmn_22-br-line}
      {&sort-clmn_23-br-line}
      {&sort-clmn_24-br-line}
      {&sort-clmn_25-br-line}
      {&sort-clmn_26-br-line}
      {&sort-clmn_27-br-line}
      {&sort-clmn_28-br-line}
      {&sort-clmn_29-br-line}
      {&sort-clmn_30-br-line}
      {&sort-clmn_31-br-line}
      {&sort-clmn_32-br-line} format "->>,>>>,>>>.<<<"
      {&sort-clmn_33-br-line}
      {&sort-clmn_34-br-line}
      {&sort-clmn_35-br-line}
      {&sort-clmn_36-br-line}
      {&sort-clmn_37-br-line}
      enable {&enabled-clmn}
    with size 98.75 by 6 separators.

define browse {&browse-name-pump} query {&browse-name-pump} no-lock display
  {&sort-clmn_1-br-line-pump} column-label {&label-clmn_1-br-line-pump}
      {&sort-clmn_2-br-line-pump} column-label {&label-clmn_2-br-line-pump}
      {&sort-clmn_3-br-line-pump}
      {&sort-clmn_4-br-line-pump}
      {&sort-clmn_5-br-line-pump}
      {&sort-clmn_6-br-line-pump}
      {&sort-clmn_7-br-line-pump}
      {&sort-clmn_8-br-line-pump}
      {&sort-clmn_9-br-line-pump}
      {&sort-clmn_10-br-line-pump}
      {&sort-clmn_11-br-line-pump}
      {&sort-clmn_12-br-line-pump}
      {&sort-clmn_13-br-line-pump}
      {&sort-clmn_14-br-line-pump}
      {&sort-clmn_15-br-line-pump}
      {&sort-clmn_16-br-line-pump}
      {&sort-clmn_17-br-line-pump}
      {&sort-clmn_18-br-line-pump}
      enable {&enabled-clmn-pump}
    with size 98.75 by 7 separators.

/* ************************  frame definitions  *********************** */
define frame {&frame-name}
  b-exit              at row 1  col 1
  b-notes             at row 1  col 11
  b-history           at row 1  col 71
  b-help              at row 1  col 81
  "Объект:"                         at row 2 col 10
  r-doc.obj-code                    at row 2 col 16   colon-aligned no-label       view-as text size 7    by 1
  r-doc.obj-type                    at row 2 col 23   colon-aligned no-label       view-as text size 7.13 by 1
  ub.clients.obj-name               at row 2 col 33   colon-aligned no-label       view-as text size 40 by 1 fgcolor 4
  r-doc.out-code                    at row 3 col 20   colon-aligned label "На основе документа" view-as text
  r-doc.doc-date                    at row 3 col 40   colon-aligned view-as text
  r-doc.state-measure-qnty          at row 4 col 38   colon-aligned view-as text FORMAT "->>,>>>,>>9":U
  r-doc.measure-qnty                at row 4 col 63   colon-aligned label "Измер" view-as text FORMAT "->>,>>>,>>9":U
  r-doc.system-qnty                 at row 4 col 85.5 colon-aligned view-as text FORMAT "->>,>>>,>>9":U
  r-doc.wrkr                        at row 5 col 4.5  colon-aligned format "999999999"  view-as fill-in size 10 by 1
  wrkr-name                         at row 5 col 15   colon-aligned no-label fgcolor 4
  r-wrkr                            at row 5 col 28   no-label
  r-doc.state-measure-cli-qnty      at row 5 col 50   colon-aligned label "Масса"       view-as text FORMAT "->>,>>>,>>9.9":U
  r-doc.measure-cli-qnty            at row 5 col 85.5 colon-aligned label "Измер.масса" view-as text FORMAT "->>,>>>,>>9.9":U
  r-doc.agnt                        at row 6 col 4.5 colon-aligned format "999999999"  view-as fill-in size 10 by 1
  agnt-name                         at row 6 col 15  colon-aligned no-label fgcolor 4
  r-agnt                            at row 6 col 28  no-label
  r-doc.system-cli-qnty         at row 6 col 50    colon-aligned label "Учет масса"         view-as text FORMAT "->>,>>>,>>9.9":U
  r-doc.system-cli-avrg-qnty    at row 6 col 85.5  colon-aligned label "Масса по ср.пл-ти"  view-as text FORMAT "->>,>>>,>>9.9":U
  r-doc.boss                    at row 7 col 4.5   colon-aligned format "999999999"       view-as fill-in size 10 by 1
  boss-name                     at row 7 col 15    colon-aligned no-label                fgcolor 4
  r-boss                        at row 7 col 28    no-label
  r-doc.state-mh-qnty           at row 7 col 38    colon-aligned label "Оборот"           view-as text format "->,>>>,>>>,>>>.<<<"
  r-doc.state-am-qnty           at row 7 col 63    colon-aligned label "Сумма"            view-as text format "->,>>>,>>>,>>>.<<<"
  r-doc.state-cf-qnty           at row 7 col 87.5  colon-aligned label "Наливы"           view-as text
  /*r-doc.state-measure-tc-qnty   at row 8 col  8                  label "Факт(tc)"         view-as text*/
  /*r-doc.measure-tc-qnty         at row 8 col 47                  label "Измер(tc)"        view-as text*/
  /*r-doc.state-brutto-tc-qnty    at row 9 col  1                  label "Факт брутто(tc)"  view-as text*/
  /*r-doc.brutto-tc-qnty          at row 9 col 40                  label "Измер брутто(tc)" view-as text*/
  b-mark              at row 8  col 1
  b-add               at row 8  col 4
  b-del               at row 8  col 14
  b-meas              at row 8  col 24
  b-lkp               at row 8  col 34
  b-chg               at row 8  col 44
  {&browse-name}      at row 9  col 1
  b-lkp-pump          at row 15 col 1
  b-chg-pump          at row 15 col 11
  {&browse-name-pump} at row 16 col 1
  space(0) skip(0)
  with view-as dialog-box side-labels three-d scrollable keep-tab-order.

/* ***************  runtime attributes and uib settings  ************** */

assign
  frame {&frame-name}:scrollable                                = false
  {&browse-name}     :num-locked-columns in frame {&frame-name} = 5
  {&browse-name-pump}:num-locked-columns in frame {&frame-name} = 2
  b-add              :popup-menu in frame {&frame-name}         = menu m-add:handle
  b-add              :menu-mouse                                = 1
  b-meas             :popup-menu in frame {&frame-name}         = menu m-meas:handle
  b-meas             :menu-mouse                                = 1.


/* ************************  control triggers  ************************ */
{ gbl/mv-clmn.i
 &ext-col      = 35
 &frame-name   = "{&frame-name}"
 &browse-name  = "{&browse-name}"
 &table-name   = "ub.rvs-line"
 &start-column = 6
}

{ gbl/mv-clmn.i
 &ext-col      = 18
 &frame-name   = "{&frame-name}"
 &browse-name  = "{&browse-name-pump}"
 &table-name   = "ub.rvs-line-pump"
 &start-column = 3
}

{ gbl/f2.i {&browse-name} " " " " parparentproc }

{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-mark }

on end-error, stop of frame {&frame-name} 
  do:
    apply "choose" to b-exit in frame {&frame-name}.
    return no-apply.
  end.

on choose of b-notes in frame {&frame-name}
  do:
    assign 
      notes = r-doc.ps.
    run gbl/notes.w ( input pardoc-mode, input-output notes ).
    if r-doc.ps <> notes then 
    do:
      do on stop undo, return no-apply :
        find r-doc exclusive-lock where recid (r-doc) = parrvs-rec.
        assign 
          r-doc.ps = notes.
      end.
    end.
  end.

on choose of b-history in frame {&frame-name}
  do:
    define variable v-list as character no-undo.

    if available r-doc then 
    do:
      run str/rvscdocs.w ( input        parparentproc,
        input        "":U,
        input        "one":U,
        input        r-doc.rvs-code,
        input-output v-list                  ).
    end.
  end.

on choose of b-exit in frame {&frame-name} /* Вых */
  do:
    if pardoc-mode = {&update}  or
      pardoc-mode = {&add-def} then 
    do:
      if not can-find (first ub.rvs-line where ub.rvs-line.rvs-code = r-doc.rvs-code no-lock) then 
      do:
        varlog = yes.
        message "В документе нет строк, поэтому он удаляется." view-as alert-box
          question buttons ok-cancel update varlog.
        if varlog then 
        do:
          delete r-doc.
          parrvs-rec = ?.
          return.
        end.
        else return no-apply.
      end.
      assign r-doc.wrkr r-doc.agnt r-doc.boss.
    end.
  end.

on mouse-select-dblclick, return of r-doc.agnt in frame {&frame-name} /* Эксп */
  do:
    run local-psn-chk in this-procedure ( input "agnt", input "ret-mouse" ).
    apply "entry" to r-doc.boss in frame {&frame-name}.
    return no-apply.
  end.

on mouse-select-dblclick, return of r-doc.boss in frame {&frame-name} /* Нач */
  do:
    run local-psn-chk in this-procedure ( input "boss", input "ret-mouse" ).
    apply "entry" to b-exit in frame {&frame-name}.
    return no-apply.
  end.

on mouse-select-dblclick, return of r-doc.wrkr in frame {&frame-name} /* Исп */
  do:
    run local-psn-chk in this-procedure ( input "wrkr", input "ret-mouse" ).
    apply "entry" to r-doc.agnt in frame {&frame-name}.
    return no-apply.
  end.

on choose of r-agnt in frame {&frame-name} /* agent */
  do:
    run local-psn-chk in this-procedure ( input "agnt", input "button" ).
    apply "entry" to r-doc.boss in frame {&frame-name}.
    return no-apply.
  end.

on choose of r-boss in frame {&frame-name} /* boss */
  do:
    run local-psn-chk in this-procedure ( input "boss", input "button" ).
    apply "entry" to b-exit in frame {&frame-name}.
    return no-apply.
  end.

on choose of r-wrkr in frame {&frame-name} /* worker */
  do:
    run local-psn-chk in this-procedure ( input "wrkr", input "button" ).
    apply "entry" to r-doc.agnt in frame {&frame-name}.
    return no-apply.
  end.

on leave of r-doc.agnt in frame {&frame-name} /* agent */
  do:
    run local-psn-chk in this-procedure ( input "agnt", input "leave" ).
  end.

on leave of r-doc.boss in frame {&frame-name} /* boss */
  do:
    run local-psn-chk in this-procedure ( input "boss", input "leave" ).
  end.

on leave of r-doc.wrkr in frame {&frame-name} /* worker */
  do:
    run local-psn-chk in this-procedure ( input "wrkr", input "leave" ).
  end.

on return, mouse-select-dblclick of {&browse-name} in frame {&frame-name}
  do:
    if b-chg:sensitive then apply "choose" to b-chg in frame {&frame-name}.
    else apply "choose" to b-lkp in frame {&frame-name}.
  end.

on return, mouse-select-dblclick of {&browse-name-pump} in frame {&frame-name}
  do:
    if b-chg-pump :sensitive then 
    do: 
      apply "choose" to b-chg-pump in frame {&frame-name}. 
    end.
    else 
    do: 
      apply "choose" to b-lkp-pump in frame {&frame-name}. 
    end.
  end.


on choose of b-mark in frame {&frame-name} 
  do:
    run local-mark in this-procedure.
    varlog = {&browse-name}:select-next-row ().
    apply "entry" to {&browse-name} in frame {&frame-name}.
  end.



on choose of b-chg in frame {&frame-name} /* Измен */
  do:

    do on stop undo, return no-apply :
      if not available ub.rvs-line then 
      do:
        message "Неправильный выбор строки.".
        return no-apply.
      end.
      run local-chg in this-procedure no-error.
      if error-status :error then 
      do: 
        return no-apply. 
      end.
      run ui-on in this-procedure .
    end. /* on stop */
  end.

on choose of b-chg-pump in frame {&frame-name} /* Измен ТРК */
  do:
    define buffer buf_goods for ub.goods.

    if not available ub.rvs-line-pump then 
    do:
      message "Неправильный выбор строки.".
      return no-apply.
    end.
    run proc-chg-pump in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
  end.

on choose of b-lkp-pump in frame {&frame-name} /* Просмотр ТРК */
  do:
    run proc-lookup in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
  end.

on choose of b-del in frame {&frame-name} /* Удал */
  do:
    run del-rvs-line in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
    assign 
      rvs-line-rec = rep-rec.
    run ui-on in this-procedure.
  end.

on choose of b-lkp in frame {&frame-name} /* Просм */
  do:
    run proc-lkp in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
  end.

on choose of menu-item m-add-1 in menu m-add 
  do:
    run local-add in this-procedure no-error.
    if error-status :error then 
    do:
      return no-apply.
    end.
    run ui-on in this-procedure no-error.
    if error-status :error then 
    do:
      return no-apply.
    end.
    apply "entry" to b-add in frame {&frame-name}.
    return no-apply.
  end.

on choose of menu-item m-add-2 in menu m-add 
  do:
    run proc_m-add-2 in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
    run ui-on in this-procedure .
  end.

on choose of menu-item m-add-3 in menu m-add 
  do:
    run doc-plsh in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
    run ui-on in this-procedure.
  end.

/* Сверка по всем резервуарам */
on choose of menu-item m-meas-1 in menu m-meas 
  do:
    run proc_m-meas-1 in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
  end.

/* Сверка по всем ТРК */
on choose of menu-item m-meas-2 in menu m-meas 
  do:
    run proc_m-meas-2 in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
  end.

/* Сверка по текущему резервуару */
on choose of menu-item m-meas-3 in menu m-meas 
  do:
    run proc_m-meas-3 in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
  end.
on choose of menu-item m-meas-4 in menu m-meas 
  do:
    run proc_m-meas-4 in this-procedure no-error.
    if error-status :error then 
    do: 
      return no-apply. 
    end.
  end.

{ gbl/srt-clmn.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "ub.rvs-line"
&ext-col = 37
&start-column  = 5
&label-clmn_1  = "{&label-clmn_1-br-line}"
&sort-clmn_1   = "{&sort-clmn_1-br-line}"
&label-clmn_2  = "{&label-clmn_2-br-line}"
&sort-clmn_2   = "{&sort-clmn_2-br-line}"
&label-clmn_3  = "{&label-clmn_3-br-line}"
&sort-clmn_3   = "{&sort-clmn_3-br-line}"
&label-clmn_4  = "{&label-clmn_4-br-line}"
&sort-clmn_4   = "{&sort-clmn_4-br-line}"
&label-clmn_5  = "{&label-clmn_5-br-line}"
&sort-clmn_5   = "{&sort-clmn_5-br-line}"
&label-clmn_6  = "{&label-clmn_6-br-line}"
&sort-clmn_6   = "{&sort-clmn_6-br-line}"
&label-clmn_7  = "{&label-clmn_7-br-line}"
&sort-clmn_7   = "{&sort-clmn_7-br-line}"
&label-clmn_8  = "{&label-clmn_8-br-line}"
&sort-clmn_8   = "{&sort-clmn_8-br-line}"
&label-clmn_9  = "{&label-clmn_9-br-line}"
&sort-clmn_9   = "{&sort-clmn_9-br-line}"
&label-clmn_10 = "{&label-clmn_10-br-line}"
&sort-clmn_10  = "{&sort-clmn_10-br-line}"
&label-clmn_11 = "{&label-clmn_11-br-line}"
&sort-clmn_11  = "{&sort-clmn_11-br-line}"
&label-clmn_12 = "{&label-clmn_12-br-line}"
&sort-clmn_12  = "{&sort-clmn_12-br-line}"
&label-clmn_13 = "{&label-clmn_13-br-line}"
&sort-clmn_13  = "{&sort-clmn_13-br-line}"
&label-clmn_14 = "{&label-clmn_14-br-line}"
&sort-clmn_14  = "{&sort-clmn_14-br-line}"
&sort-clmn_15  = "{&sort-clmn_15-br-line}"
&sort-clmn_16  = "{&sort-clmn_16-br-line}"
&sort-clmn_17  = "{&sort-clmn_17-br-line}"
&sort-clmn_18  = "{&sort-clmn_18-br-line}"
&sort-clmn_19  = "{&sort-clmn_19-br-line}"
&sort-clmn_20  = "{&sort-clmn_20-br-line}"
&sort-clmn_21  = "{&sort-clmn_21-br-line}"
&sort-clmn_22  = "{&sort-clmn_22-br-line}"
&sort-clmn_23  = "{&sort-clmn_23-br-line}"
&sort-clmn_24  = "{&sort-clmn_24-br-line}"
&sort-clmn_25  = "{&sort-clmn_25-br-line}"
&sort-clmn_26  = "{&sort-clmn_26-br-line}"
&sort-clmn_27  = "{&sort-clmn_27-br-line}"
&sort-clmn_28  = "{&sort-clmn_28-br-line}"
&sort-clmn_29  = "{&sort-clmn_29-br-line}"
&sort-clmn_30  = "{&sort-clmn_30-br-line}"
&sort-clmn_31  = "{&sort-clmn_31-br-line}"
&sort-clmn_32  = "{&sort-clmn_32-br-line}"
&sort-clmn_33  = "{&sort-clmn_33-br-line}"
&sort-clmn_34  = "{&sort-clmn_34-br-line}"
&sort-clmn_35  = "{&sort-clmn_35-br-line}"
&sort-clmn_36  = "{&sort-clmn_36-br-line}"
&sort-clmn_37  = "{&sort-clmn_37-br-line}"
&open-query           = "{&open-query-{&browse-name}} by ~{&sort-clmn_~{&clmn_num~}~} ."
&open-query-otherwise = "{&open-query-{&browse-name}-default}"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes"}

{ gbl/srt-clmn.i
&browse-name   = {&browse-name-pump}
&frame-name    = {&frame-name}
&table-name    = "ub.rvs-line-pump"
&ext-col       = 18
&start-column  = 3
&label-clmn_1  = "{&label-clmn_1-br-line-pump}"
&sort-clmn_1   = "{&sort-clmn_1-br-line-pump}"
&label-clmn_2  = "{&label-clmn_2-br-line-pump}"
&sort-clmn_2   = "{&sort-clmn_2-br-line-pump}"
&sort-clmn_3   = "{&sort-clmn_3-br-line-pump}"
&sort-clmn_4   = "{&sort-clmn_4-br-line-pump}"
&sort-clmn_5   = "{&sort-clmn_5-br-line-pump}"
&sort-clmn_6   = "{&sort-clmn_6-br-line-pump}"
&sort-clmn_7   = "{&sort-clmn_7-br-line-pump}"
&sort-clmn_8   = "{&sort-clmn_8-br-line-pump}"
&sort-clmn_9   = "{&sort-clmn_9-br-line-pump}"
&sort-clmn_10  = "{&sort-clmn_10-br-line-pump}"
&sort-clmn_11  = "{&sort-clmn_11-br-line-pump}"
&sort-clmn_12  = "{&sort-clmn_12-br-line-pump}"
&sort-clmn_13  = "{&sort-clmn_13-br-line-pump}"
&sort-clmn_14  = "{&sort-clmn_14-br-line-pump}"
&sort-clmn_15  = "{&sort-clmn_15-br-line-pump}"
&sort-clmn_16  = "{&sort-clmn_16-br-line-pump}"
&sort-clmn_17  = "{&sort-clmn_17-br-line-pump}"
&sort-clmn_18  = "{&sort-clmn_18-br-line-pump}"
&open-query           = "{&open-query-{&browse-name-pump}} by ~{&sort-clmn_~{&clmn_num~}~} ."
&open-query-otherwise = "{&open-query-{&browse-name-pump}-default}"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes"}

on value-changed of {&browse-name} in frame {&frame-name} 
  do:
    if available ub.rvs-line then 
    do:
      run re-open-query-srt-clmn{&browse-name-pump} in this-procedure.
    end.
  end.

ON ROW-DISPLAY OF {&browse-name} IN FRAME {&frame-name} 
  DO:
  define variable vChkColor as log no-undo.
    if avail r-doc and 
       (r-doc.rvs-type  = {&rvs-before-doc} or 
        r-doc.rvs-type  = {&rvs-after-doc}) then 
    do:
       do ii = 1 to 37:
          bcol[ii]:FGcolor  = 7.
       end.  
    end.
    else if available ub.rvs-line then 
    do:
      find first buf_rvs-line-attr no-lock 
        where buf_rvs-line-attr.attr-code = "rvd-on"
        and buf_rvs-line-attr.gds-code = ub.rvs-line.gds-code
        and buf_rvs-line-attr.obj-code = ub.rvs-line.obj-code
        and buf_rvs-line-attr.obj-type = ub.rvs-line.obj-type
        and buf_rvs-line-attr.pl-code  = ub.rvs-line.pl-code
        and buf_rvs-line-attr.rvs-code = ub.rvs-line.rvs-code
        no-error .    
   
      if available buf_rvs-line-attr and 
        buf_rvs-line-attr.attr-value > ""
        then 
      do:
        do ii = 1 to 37:
          bcol[ii]:FGcolor  = 7.
        end.
      end.
      else if avail r-doc then 
      do:
         if can-find(first buf_doc-attr no-lock where 
                     buf_doc-attr.doc-code = r-doc.rvs-code 
                 and buf_doc-attr.attr-code = "rvs-auto" 
                 and buf_doc-attr.attr-value = "Yes") then 
         do:        
            run CheckColorSkip in this-procedure 
                     (r-doc.obj-type,
                      r-doc.obj-code,
                      r-doc.shift-date,
                      r-doc.shift-num,
                      ub.rvs-line.pl-code,
                      ub.rvs-line.gds-code,
                      r-doc.sys-date,
                      r-doc.sys-time-int,
                      output vChkColor).
             if vChkColor then 
                do ii = 1 to 37:
                   bcol[ii]:FGcolor  = 7.
                end.
         end.
      end.        
    end.
  END.

/* ***************************  main block  *************************** */
if valid-handle(active-window) and frame {&frame-name}:parent eq ?
  then frame {&frame-name}:parent = active-window.

on window-close of frame {&frame-name} 
  apply "end-error":u to self.

{ gbl/app_help.i }

main-block:
do on error   undo main-block, leave main-block
  on end-key undo main-block, leave main-block
  on stop    undo main-block, leave main-block:
   
  do ii = 1 to 37:
    bcol[ii] = {&browse-name}:get-browse-column(ii).
  end.

  run mode-on in this-procedure
    no-error.
  if error-status :error then 
  do:
    return error return-value .
  end.
  if pardoc-mode <> {&lookup} then 
  do:
    assign
      rvs-line-rec = ?
      .
  end.
  run ui-on in this-procedure.

  wait-for go of frame {&frame-name} focus b-add.
end.
run disable_ui in this-procedure.


/* **********************  internal procedures  *********************** */

procedure disable_ui :
  hide frame {&frame-name}.
end procedure.

procedure ui-on :
  /* ----------------------------------------------------------------------------------------------------------------------------
    purpose:     включение пользовательского интерфейса в нужном режиме
  --------------------------------------------------------------------------------------------------------------------------------- */
    /* определяем продолжительность пропуска автосверки после приема НП */
  { gbl/ptrlprop.i
     run
     r-doc.obj-type
     r-doc.obj-code
  }
  if not error-status :error then do:
    vTimeAutoSkip = if ptrlprop-autopump-skip-time <> ? then ptrlprop-autopump-skip-time else 0.
  end.
  
  del-list = "".
  find first ub.clients where ub.clients.obj-type = r-doc.obj-type and
    ub.clients.obj-code = r-doc.obj-code no-lock.
  assign 
    frame {&frame-name}:title = "(" + substring (ub.clients.obj-name, 1, 35) +
       ") :   ДОКУМЕНТ СВЕРКИ - " + r-doc.status_ + " № " + r-doc.rvs-code + "      - " + pardoc-mode.
  disable all with frame {&frame-name}.
  enable b-exit b-help b-lkp b-lkp-pump {&browse-name} {&browse-name-pump} b-history b-notes with frame {&frame-name}.
  assign {&enabled-clmn}:read-only in browse {&browse-name} = yes
       {&enabled-clmn-pump}:read-only in browse {&browse-name-pump} = yes.
  if r-doc.status_ = {&g___new} and
    (pardoc-mode = {&add-def} or
    pardoc-mode = {&update}        ) then 
  do:
    enable r-doc.wrkr
      r-doc.agnt
      r-doc.boss
      r-wrkr r-agnt r-boss
      with frame {&frame-name}.
    if r-doc.rvs-type <> {&rvs-shift} and
      not (r-doc.rvs-type = {&rvs-control} and r-doc.is-full = yes) then
      enable b-add b-del b-mark with frame {&frame-name}.
    enable b-meas with frame {&frame-name}.
  end.
  if r-doc.status_ = {&permitted} and
    pardoc-mode = {&update} then 
  do:
    enable b-chg b-chg-pump with frame {&frame-name}.
  end.

  if available ub.clients then disp ub.clients.obj-name with frame {&frame-name}.
  else disp ? @ ub.clients.obj-name with frame {&frame-name}.
  disp r-doc.obj-code
    r-doc.obj-type
    r-doc.doc-date
    r-doc.state-measure-qnty
    r-doc.measure-qnty
    r-doc.system-qnty
    r-doc.state-measure-cli-qnty
    r-doc.measure-cli-qnty
    r-doc.system-cli-qnty
    r-doc.system-cli-avrg-qnty
    r-doc.state-mh-qnty
    r-doc.state-am-qnty
    r-doc.state-cf-qnty
    r-doc.out-code
    /*     r-doc.state-measure-tc-qnty*/
    /*     r-doc.measure-tc-qnty*/
    /*     r-doc.state-brutto-tc-qnty*/
    /*     r-doc.brutto-tc-qnty*/
    with frame {&frame-name}.

  for first ub.user-account-attr no-lock where ub.user-account-attr.user-id = v-cntxt-userid
    and ub.user-account-attr.attr-code = "psn-code"
    :
    if ub.user-account-attr.attr-value <> ""
      and ub.user-account-attr.attr-value <> ?
      and ub.user-account-attr.attr-value <> "0"
      and ub.user-account-attr.attr-value <> "?"
      then 
    do:
      if pardoc-mode = {&add-def}
        then 
      do :
        r-doc.agnt:screen-value in frame {&frame-name} = trim (ub.user-account-attr.attr-value).
        r-doc.wrkr:screen-value in frame {&frame-name} = trim (ub.user-account-attr.attr-value).
        r-doc.boss:screen-value in frame {&frame-name} = trim (ub.user-account-attr.attr-value).
      end.
      if pardoc-mode = {&update}
        then 
      do :
        r-doc.agnt:screen-value in frame {&frame-name} = trim (ub.user-account-attr.attr-value).
      end.
    end. 
  end .    

  { str/psn-chk.i wrkr on r-doc v-ref-rec }
  { str/psn-chk.i agnt on r-doc v-ref-rec }
  { str/psn-chk.i boss on r-doc v-ref-rec }

  {&open-query-{&browse-name}-default}
  if pardoc-mode = {&lookup} then 
  do:
    if rvs-line-rec      <> ? then reposition {&browse-name}      to recid rvs-line-rec      no-error.
  end.
  if pardoc-mode = {&update} then 
  do:
    if not can-find (first ub.rvs-line where ub.rvs-line.rvs-code = r-doc.rvs-code no-lock) then
      apply "entry" to b-add in frame {&frame-name}.
    else 
    do:
      if rvs-line-rec      <> ? then reposition {&browse-name}      to recid rvs-line-rec      no-error.
    end.
  end.
  {&open-query-{&browse-name-pump}-default}
  if rvs-line-pump-rec <> ? then reposition {&browse-name-pump} to recid rvs-line-pump-rec no-error.


  if num-results( "{&browse-name}" ) > 0 then 
  do:
    if {&browse-name}:refresh() then.
  end.
end procedure.

PROCEDURE local-mark:
  if not available ub.rvs-line then 
  do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i ub.rvs-line del-list }
  {&browse-name}:refresh() in frame {&frame-name} .
END PROCEDURE.

procedure del-rvs-line:
  if del-list = "" then 
  do:
    /* удаление 1 строки */
    if not available ub.rvs-line then 
    do:
      message "Неправильный выбор строки.".
      return error.
    end.
    varlog = no.
    message "Удалить строку документа сверки ?   Вы уверены ?"
      view-as alert-box question buttons ok-cancel update varlog.
    if not varlog then return error.
    rvs-line-rec = recid (ub.rvs-line).
    del-list     = string (recid (ub.rvs-line)).
    get next {&browse-name}.
    if available ub.rvs-line then rep-rec = recid (ub.rvs-line).
    else 
    do:
      reposition {&browse-name} to recid rvs-line-rec no-error.
      get prev {&browse-name}.
      rep-rec = recid (ub.rvs-line).
    end.
  end.
  else 
  do:
    /* удаление отмеченных строк */
    varlog = ?.
    message "УДАЛЕНИЕ  ПО  ОТМЕТКАМ  строк документа ?" skip (2)
      "yes - удалить все отмеченные строки" skip
      "no - оставить только отмеченные строки и удалить все остальные" skip (2)
      "cancel - ничего не удалять"
      view-as alert-box question buttons yes-no-cancel update varlog.
    if varlog = ? then return error.
    rep-rec = ?.
  end.
  do transaction on error   undo, return error
    on end-key undo, return error
    on stop    undo, return error :
    for each del-rvs-line where del-rvs-line.rvs-code = r-doc.rvs-code no-lock
      :
      if not varlog and     can-do (del-list, string (recid (del-rvs-line))) then next.
      if     varlog and not can-do (del-list, string (recid (del-rvs-line))) then next.
      assign 
        rvs-line-rec = recid(del-rvs-line).
      find ub.rvs-line where recid (ub.rvs-line) = rvs-line-rec exclusive.
      delete ub.rvs-line.
    end.
    { str/rvsclchd.i "recid( r-doc )"
                yes                      no-error }
  end.

end procedure.


procedure cycle-add :
  define buffer buf_rvs-line for ub.rvs-line.
  define buffer buf_goods    for ub.goods.
  define buffer buf_pl-gds   for ub.pl-gds.
  define buffer buf_place    for ub.place .

  define variable var-pl-code like ub.place.pl-code no-undo.
  define variable v-value     as character no-undo.
  define variable v-value2    as character no-undo.
  define variable v-ok        as logical   no-undo.
  define variable ii          as integer   no-undo .

  assign 
    lns-cnt = 0.
  do while lns-cnt < num-entries( notes ) :
    assign 
      lns-cnt = lns-cnt + 1
      gds-rec = integer( entry( lns-cnt, notes ) ).
    find buf_goods no-lock where recid( buf_goods ) = gds-rec.
    run plgdsfnd in this-procedure (  input yes,
      input r-doc.obj-type,
      input r-doc.obj-code,
      input buf_goods.gds-code,
      output varres,
      output var-pl-code ) no-error.
    if error-status :error then 
    do:
      message "Ошибка при поиске складского места для товара: " skip
        buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code skip
        return-value
        "."
        view-as alert-box error.
      next.
    end.
    if varres <> yes then 
    do:
      message "Товар " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code
        " не резевируется по складским местам на объекте "
        r-doc.obj-type r-doc.obj-code "."
        view-as alert-box error.
      next.
    end.
    find buf_pl-gds no-lock where
      buf_pl-gds.obj-type = r-doc.obj-type and
      buf_pl-gds.obj-code = r-doc.obj-code and
      buf_pl-gds.pl-code  = var-pl-code            no-error.
    if not available buf_pl-gds then 
    do:
      message "Ошибка при выборке складского места для товара: "
        buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code
        view-as alert-box error.
      next.
    end.
    find first buf_rvs-line no-lock where
      buf_rvs-line.rvs-code = r-doc.rvs-code and
      buf_rvs-line.gds-code = buf_goods.gds-code       and
      buf_rvs-line.pl-code  = buf_pl-gds.pl-code       no-error.
    if available buf_rvs-line then 
    do:
      assign 
        varlog = no.
      message "Данный товар: " buf_goods.artic buf_goods.gds-name skip
        " и складское место " buf_pl-gds.pl-code
        "уже имеется в данном документе сверки." skip
        view-as alert-box.
      next.
    end.
    
    run placelib_get-attr  ( input {&place-com-tanks}
      ,input buf_pl-gds.obj-code
      ,input buf_pl-gds.obj-type
      ,input buf_pl-gds.pl-code
      ,output v-value
      ,output v-ok      ) no-error.

    if  v-ok
    and v-value > ""
    then do :
      /*    Сообщающиеся резервуары  */
      find first buf_place no-lock where buf_place.obj-type = buf_pl-gds.obj-type
        and buf_place.obj-code = buf_pl-gds.obj-code
        and buf_place.pl-code = buf_pl-gds.pl-code
        .
      v-value = buf_place.loc1 + "," + v-value .
      do ii = 1 to num-entries(v-value) :
        find first buf_place no-lock where buf_place.obj-type = buf_pl-gds.obj-type
          and buf_place.obj-code = buf_pl-gds.obj-code
          and buf_place.loc1     = entry(ii, v-value)
          and buf_place.status_  = ""
          no-error .
        if available buf_place
          then 
        do :
          run placelib_get-attr  ( input {&place-is-main}
            ,input buf_place.obj-code
            ,input buf_place.obj-type
            ,input buf_place.pl-code
            ,output v-value2
            ,output v-ok      ) no-error.
          
          tr:
          do transaction on error undo, return error return-value :
            { str/crrvslin.i
                r-doc.obj-type
                r-doc.obj-code
                r-doc.rvs-code
                r-doc.rvs-type
                buf_place.pl-code
                buf_pl-gds.gds-code
                "( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? )"
                cur_shift-obj.shift-date
                cur_shift-obj.shift-num
                no-error
            }
            if error-status :error then 
            do:
              message "Ошибка при создании линии."
                return-value
                view-as alert-box error.
              undo tr, return error.
            end.
            
            if v-ok
              and logical(v-value2) /* Главный сообщающийся резервуар */
              then 
            do :
              { str/crrvslnp.i
                  r-doc.obj-type
                  r-doc.obj-code
                  r-doc.rvs-code
                  r-doc.rvs-type
                  buf_place.pl-code
                  buf_pl-gds.gds-code
                  yes
                  "( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? )"
                  cur_shift-obj.shift-date
                  cur_shift-obj.shift-num
                  "( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? )"
                  yes
                  no-error
              }
              if error-status :error then 
              do:
                message "Ошибка при создании строки данных по ТРК. " skip
                  return-value
                  error-status :get-message( 1 )
                  view-as alert-box.
                undo tr, return error.
              end.
            end .
          end. /* transaction */                        
        end .
      end .
    end.
    else 
    do :
      tr:
      do transaction on error undo, return error return-value :
        { str/crrvslin.i
            r-doc.obj-type
            r-doc.obj-code
            r-doc.rvs-code
            r-doc.rvs-type
            buf_pl-gds.pl-code
            buf_pl-gds.gds-code
            "( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? )"
            cur_shift-obj.shift-date
            cur_shift-obj.shift-num
            no-error
        }
        if error-status :error then 
        do:
          message "Ошибка при создании линии."
            return-value
            view-as alert-box error.
          undo tr, return error.
        end.
        /*
        if return-value <> "" then do:
           message return-value view-as alert-box.
        end.
        */
        { str/crrvslnp.i
            r-doc.obj-type
            r-doc.obj-code
            r-doc.rvs-code
            r-doc.rvs-type
            buf_pl-gds.pl-code
            buf_pl-gds.gds-code
            yes
            "( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? )"
            cur_shift-obj.shift-date
            cur_shift-obj.shift-num
            "( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? )"
            yes
            no-error
        }
        if error-status :error then 
        do:
          message "Ошибка при создании строки данных по ТРК. " skip
            return-value
            error-status :get-message( 1 )
            view-as alert-box.
          undo tr, return error.
        end.
      end. /* transaction */
    end .
  end. /* cycle */
end procedure. /* cycle-add */

procedure mode-on :
  /* -----------------------------------------------------------
    purpose:     чтение или создание шапки
  ------------------------------------------------------------- */
  define variable v-shift-date like ub.shift-obj.shift-date no-undo.
  define variable v-shift-num  like ub.shift-obj.shift-num no-undo.
  define variable v-shift-name as character no-undo.
  define variable v-obj-date   as date      no-undo.

  define buffer bf_place  for ub.place.
  define buffer bf_r-line for ub.rvs-line.

  if pardoc-mode = {&add-def} or
    pardoc-mode = {&update} then 
  do:
    find first cur_shift-obj
      where cur_shift-obj.obj-type = v-cntxt-obj-type
      and cur_shift-obj.obj-code = v-cntxt-obj-code
      and cur_shift-obj.status_  = {&sht-current}
      use-index pi no-lock no-error .
    if not available cur_shift-obj then 
    do:
      message "Нет открытой смены на объекте " v-cntxt-obj-type
        v-cntxt-obj-code
        view-as alert-box error.
      return error.
    end.
    /* Ищем последнюю закрытую смену */
    find last prev_shift-obj where prev_shift-obj.obj-type = cur_shift-obj.obj-type and
      prev_shift-obj.obj-code = cur_shift-obj.obj-code and
      prev_shift-obj.status_  = {&sht-closed}         and
      (prev_shift-obj.shift-date < cur_shift-obj.shift-date or
      prev_shift-obj.shift-date = cur_shift-obj.shift-date and
      prev_shift-obj.shift-num  < cur_shift-obj.shift-num) use-index stts no-lock no-error.
    /* Если это не первая смена на объекте, ищем сверку по прошлой смене */
    if available prev_shift-obj then 
    do:
      find last prev_rvs-doc where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type   and
        prev_rvs-doc.obj-code   = prev_shift-obj.obj-code   and
        prev_rvs-doc.shift-date = prev_shift-obj.shift-date and
        prev_rvs-doc.shift-num  = prev_shift-obj.shift-num  and
        prev_rvs-doc.status_    = {&fact}                   and
        prev_rvs-doc.rvs-type   = {&rvs-shift}              no-lock no-error.
    /* Сверки за прошлую смену может и не быть если не торговали бензином */
    end.
    /* Ищем последнюю инвентаризацию счетчиков ТРК */
    /* В случае если ТРК не измеряем его может и не быть */
    find last prev_icnt-doc where
      prev_icnt-doc.obj-type = v-cntxt-obj-type
      and prev_icnt-doc.obj-code = v-cntxt-obj-code
      and prev_icnt-doc.doc-type = {&icnt-doc}
      and prev_icnt-doc.status_  = {&fact} use-index fact-order no-lock no-error.
  end.
  { gbl/conf-rd.i
  "'ptoldfil':u"
  v-cntxt-host-code-obj
  v-cntxt-obj-type
  v-cntxt-obj-code
  "''"
  "''"
  "''"
  no
  ptoldfilvalue
  ptoldfiltype
  no-error
}
  if error-status :error then 
  do:
  end.
  case pardoc-mode :
    when {&add-def} then 
      do:
        if parrvs-type = {&rvs-shift} then 
        do:
          { gbl/curshift.i
         v-cntxt-obj-type
         v-cntxt-obj-code
         v-shift-date
         v-shift-num
         v-shift-name
         no-error
       }

          /* проверяем отсутствие чеков по смене и прочие кассовые запреты */
          run str/deskshft.p (input parparentproc
            ,input no /*p-silent*/
            ,input v-cntxt-obj-type
            ,input v-cntxt-obj-code
            ,input v-shift-date
            ,input v-shift-num
            ,input v-shift-name
            ) no-error.
          if error-status :error then 
          do:
            message
              error-status :get-message (1) skip
              return-value skip
              view-as alert-box error.
            return error.
          end.
        end.
        tr:
        do transaction
          on error undo, return error return-value
          on stop  undo, return error return-value
          on quit  undo, return error return-value
          :
          create r-doc.
          run doc-code in this-procedure
            (input  "main",
            input  v-cntxt-obj-type,
            input  v-cntxt-obj-code,
            input  ?,
            output r-doc.rvs-code ) no-error.
          if error-status :error then 
          do:
            message "Ошибка при генерации номера документа." skip return-value view-as alert-box.
            undo tr, return error.
          end.
          { gbl/curobjdt.i v-cntxt-obj-type v-cntxt-obj-code v-obj-date }
          assign
            r-doc.host-code = v-cntxt-host-code-obj
            r-doc.obj-type  = v-cntxt-obj-type
            r-doc.obj-code  = v-cntxt-obj-code
            r-doc.status_   = {&g___new}
            r-doc.rvs-type  = parrvs-type
            r-doc.out-code  = ?
            r-doc.creid     = v-cntxt-userid
            r-doc.ps        = "@"
            r-doc.doc-date  = v-obj-date
            .
          if parrvs-type = {&rvs-control} and parall-place then
            assign r-doc.is-full = yes.

          /* Следует задать дату смены сразу, чтобы делать выборку баков, задействованных в смене */
          run gbl/factdate.p ( input        r-doc.obj-type
            , input        r-doc.obj-code
            , input-output r-doc.fact-date
            , input-output r-doc.fact-time
            , input-output r-doc.shift-date
            , input-output r-doc.shift-num
            , input-output r-doc.shift-name
            , input        yes
            ) no-error.
          if error-status :error then 
          do:
            message
              "Ошибка при установке даты в документе(rvs-doc)." skip
              view-as alert-box error.
            undo tr, return error.
          end.
          run str/chk-rvs.p (input recid(r-doc)) no-error.
          if error-status :error then 
          do:
            message "Ошибка документа сверки." skip
              return-value         skip
              error-status:get-message(1)
              view-as alert-box error.
            undo tr, return error.
          end.
          if (r-doc.rvs-type = {&rvs-shift} or parall-place) then 
          do:
            run waitfram-show in this-procedure ( input "Создаем строки по резервуарам" ).
            { str/place-sh.i
              r-doc.obj-type
              r-doc.obj-code
              r-doc.rvs-code
              r-doc.rvs-type
              "( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? )"
              cur_shift-obj.shift-date
              cur_shift-obj.shift-num
              no
              no-error
          }
            if error-status :error then 
            do:
              message "Ошибка при создании линий документа сверки." skip
                return-value
                view-as alert-box error.
              run waitfram-hide in this-procedure.
              undo tr, return error.
            end.
            run waitfram-show in this-procedure ( input "Просматриваем измеряемые резервуары" ).
            { str/meas-plc.i
              r-doc.obj-type
              r-doc.obj-code
              tt-meas
              no-error
          }
            if error-status :error then 
            do:
              message "Ошибка при определении резервуаров для измерения."
                return-value
                view-as alert-box error.
              run waitfram-hide in this-procedure.
              undo tr, return error.
            end.
            find first sys-ctrl no-lock.
            run db-attr-value(sys-ctrl.db,"AsiIp",output v-asi-ip,output v-attr-type).
            run db-attr-value(sys-ctrl.db,"AsiPort",output v-asi-port,output v-attr-type).
            run db-attr-value(sys-ctrl.db,"AsiType",output v-asi-type,output v-attr-type).
            if trim(v-asi-ip) <> ''
              and trim(v-asi-port) <> ''
              and trim(v-asi-type) <> ''
              then 
            do :
              case v-asi-type :
                when "1"
                then 
                  do :
                    varcur-data = 2 .
                  end.
                when "2"
                then 
                  do :
                    varcur-data = 3 .
                  end.
              end case .
            end.
            else 
            do :
              if ptoldfilvalue = "yes":u then 
              do:
                run gbl/d-askw.w ( input "Выбор источника данных с информацией по резервуарам и ТРК",
                  "Будем читать текущие данные с резервуаров и ТРК или возьмем данные из файла?",
                  "|^",
                  "Текущие данные|Из файлов|Отмена",
                  "Запускается программа для обращения к датчикам резервуаров и ТРК|Берутся уже сохраненные данные из файла|Ничего не делаем",
                  1,
                  3,
                  output varnum
                  ).
                case varnum:
                  when 3 then 
                    do:
                      return error.
                    end.
                  when 2 then 
                    do:
                      assign
                        varcur-data = 0.
                    end.
                  when 1 then 
                    do:
                      assign
                        varcur-data = 1.
                    end.
                end case.
              end.
              else 
              do:
                assign
                  varcur-data = 1.
              end.
            end.
            if can-find(first tt-meas) then 
            do:
              run waitfram-show  in this-procedure ( input "Делаем сверку по всем резервуарам" ).
              { str/rvsplace.i
                r-doc.obj-type
                r-doc.obj-code
                no
                varcur-data
                yes
                no
                tt-meas-file
                tt-meas
                no-error
             }
              if error-status :error then 
              do:
                message "Ошибка при получении данных с приборов на резервуарах." skip
                  return-value
                  view-as alert-box error.
                run waitfram-hide in this-procedure.
                undo tr, return error.
              end.
              { str/fall-plc.i
                 r-doc.obj-type
                 r-doc.obj-code
                 r-doc.rvs-code
                 yes
                 no-error
             }
              if error-status :error then 
              do:
                message "Ошибка при заполнении данных с приборов на резервуарах." skip
                  return-value
                  view-as alert-box error.
                run waitfram-hide in this-procedure.
                undo tr, return error.
              end.
              for  each bf_r-line where
                bf_r-line.rvs-code = r-doc.rvs-code and
                bf_r-line.obj-type = r-doc.obj-type and
                bf_r-line.obj-code = r-doc.obj-code
                , first bf_place    where
                bf_place.obj-type = bf_r-line.obj-type and
                bf_place.obj-code = bf_r-line.obj-code and
                bf_place.pl-code  = bf_r-line.pl-code and
                bf_place.is-meas  = yes 
                :
                find first rvs-line-attr exclusive-lock
                  where rvs-line-attr.obj-code  = bf_r-line.obj-code
                  and rvs-line-attr.obj-type  = bf_r-line.obj-type
                  and rvs-line-attr.gds-code  = bf_r-line.gds-code
                  and rvs-line-attr.pl-code   = bf_r-line.pl-code
                  and rvs-line-attr.rvs-code  = bf_r-line.rvs-code
                  and rvs-line-attr.attr-code = "input-type-p" no-error.
                if not available rvs-line-attr then 
                do :
                  create rvs-line-attr.
                  assign
                    rvs-line-attr.obj-code  = bf_r-line.obj-code
                    rvs-line-attr.obj-type  = bf_r-line.obj-type
                    rvs-line-attr.gds-code  = bf_r-line.gds-code
                    rvs-line-attr.pl-code   = bf_r-line.pl-code
                    rvs-line-attr.rvs-code  = bf_r-line.rvs-code
                    rvs-line-attr.attr-code = "input-type-p"
                    .
                end.
                if varcur-data > 0 then rvs-line-attr.attr-value = 'а' .
                else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
              
                find first rvs-line-attr exclusive-lock
                  where rvs-line-attr.obj-code  = bf_r-line.obj-code
                  and rvs-line-attr.obj-type  = bf_r-line.obj-type
                  and rvs-line-attr.gds-code  = bf_r-line.gds-code
                  and rvs-line-attr.pl-code   = bf_r-line.pl-code
                  and rvs-line-attr.rvs-code  = bf_r-line.rvs-code
                  and rvs-line-attr.attr-code = "input-type-t" no-error.
                if not available rvs-line-attr then 
                do :
                  create rvs-line-attr.
                  assign
                    rvs-line-attr.obj-code  = bf_r-line.obj-code
                    rvs-line-attr.obj-type  = bf_r-line.obj-type
                    rvs-line-attr.gds-code  = bf_r-line.gds-code
                    rvs-line-attr.pl-code   = bf_r-line.pl-code
                    rvs-line-attr.rvs-code  = bf_r-line.rvs-code
                    rvs-line-attr.attr-code = "input-type-t"
                    .
                end.
                if varcur-data > 0 then rvs-line-attr.attr-value = 'а' .
                else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
              
                find first rvs-line-attr exclusive-lock
                  where rvs-line-attr.obj-code  = bf_r-line.obj-code
                  and rvs-line-attr.obj-type  = bf_r-line.obj-type
                  and rvs-line-attr.gds-code  = bf_r-line.gds-code
                  and rvs-line-attr.pl-code   = bf_r-line.pl-code
                  and rvs-line-attr.rvs-code  = bf_r-line.rvs-code
                  and rvs-line-attr.attr-code = "input-type-l" no-error.
                if not available rvs-line-attr then 
                do :
                  create rvs-line-attr.
                  assign
                    rvs-line-attr.obj-code  = bf_r-line.obj-code
                    rvs-line-attr.obj-type  = bf_r-line.obj-type
                    rvs-line-attr.gds-code  = bf_r-line.gds-code
                    rvs-line-attr.pl-code   = bf_r-line.pl-code
                    rvs-line-attr.rvs-code  = bf_r-line.rvs-code
                    rvs-line-attr.attr-code = "input-type-l"
                    .
                end.
                if varcur-data > 0 then rvs-line-attr.attr-value = 'а' .
                else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
              end.
              release rvs-line-attr no-error .
            end.
            run waitfram-show in this-procedure ( input "Создаем строки по ТРК" ).
            { str/pump-sh.i
              r-doc.obj-type
              r-doc.obj-code
              r-doc.rvs-code
              r-doc.rvs-type
              "( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? )"
              "( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? )"
              cur_shift-obj.shift-date
              cur_shift-obj.shift-num
              yes
              yes
              no-error
          }
            if error-status :error then 
            do:
              message "Ошибка при создании линий ТРК документа сверки." skip
                return-value
                view-as alert-box error.
              run waitfram-hide in this-procedure.
              undo tr, return error.
            end.
            run waitfram-show in this-procedure ( input "Просматриваем измеряемые ТРК" ).
            { str/measpmnz.i
            r-doc.obj-type
            r-doc.obj-code
            tt-pump-nozzle
            no-error
          }
            if error-status :error then 
            do:
              message "Ошибка при определении пистолетов ТРК для измерения."
                return-value
                view-as alert-box error.
              run waitfram-hide in this-procedure.
              undo tr, return error.
            end.
            if can-find( first tt-pump-nozzle ) then 
            do:
              run waitfram-show in this-procedure ( input "Делаем сверку по всем ТРК" ).
              if varcur-data = 1
                or ptoldfilvalue <> "yes":u
                then 
              do :
                { str/rvs-pump.i
                parParentProc
                r-doc.obj-type
                r-doc.obj-code
                r-doc.rvs-code
                yes
                tt-pump-nozzle-file
                tt-pump-nozzle
                no-error
              }
              end.
              else 
              do :
                { str/rvs-pump.i
                parParentProc
                r-doc.obj-type
                r-doc.obj-code
                r-doc.rvs-code
                no
                tt-pump-nozzle-file
                tt-pump-nozzle
                no-error
              }
              end.
              if error-status :error then 
              do:
                message "Ошибка при получении данных с приборов на ТРК." skip
                  return-value
                  view-as alert-box error.
                run waitfram-hide in this-procedure.
                undo tr, return error.
              end.
              if return-value <> "":U then 
              do:
                message return-value view-as alert-box information.
              end.
            end.
            run waitfram-show in this-procedure ( input "Пересчитывем строки и шапку" ).
            { str/rvsclchd.i "recid( r-doc )"
                       yes                      no-error }
            if error-status :error then 
            do:
              message "Ошибка при пересчете документа." skip
                return-value
                view-as alert-box error.
              run waitfram-hide in this-procedure.
              undo tr, return error.
            end.
            run waitfram-hide in this-procedure.
          end.
          assign 
            parrvs-rec = recid (r-doc).
        end. /* transaction */
      end.
    when {&update} then 
      do:
        tr:
        do transaction
          on error undo, return error return-value
          on stop  undo, return error return-value
          on quit  undo, return error return-value
          :
          find r-doc where recid (r-doc) = parrvs-rec no-error.
          if available r-doc then 
          do:
            if r-doc.status_ = {&fact} then 
            do:
              find r-doc where recid (r-doc) = parrvs-rec no-lock.
              message "Документ уже закрыт. Изменение невозможно.".
              undo tr, return error.
            end.
            find r-doc where recid (r-doc) = parrvs-rec exclusive.
          end.
        end. /* transaction */
      end.
    when {&lookup} then 
      do:
        find r-doc no-lock where recid (r-doc) = parrvs-rec.
      end.
  end case. /* pardoc-mode */
  if not available r-doc then 
  do:
    message "Неправильно выбран документ.".
    undo, return error.
  end.
end procedure.

procedure local-psn-chk:
  define input parameter parman    as character no-undo.
  define input parameter paraction as character no-undo.
  if parman = "agnt" and paraction = "ret-mouse" then 
  do:
    { str/psn-chk.i agnt ret-mouse r-doc v-ref-rec }
  end.
  if parman = "agnt" and paraction = "button" then 
  do:
    { str/psn-chk.i agnt button r-doc v-ref-rec }
  end.
  if parman = "agnt" and paraction = "leave" then 
  do:
    { str/psn-chk.i agnt leave r-doc v-ref-rec }
  end.
  if parman = "boss" and paraction = "ret-mouse" then 
  do:
    { str/psn-chk.i boss ret-mouse r-doc v-ref-rec }
  end.
  if parman = "boss" and paraction = "button" then 
  do:
    { str/psn-chk.i boss button r-doc v-ref-rec }
  end.
  if parman = "boss" and paraction = "leave" then 
  do:
    { str/psn-chk.i boss leave r-doc v-ref-rec }
  end.
  if parman = "wrkr" and paraction = "ret-mouse" then 
  do:
    { str/psn-chk.i wrkr ret-mouse r-doc v-ref-rec }
  end.
  if parman = "wrkr" and paraction = "button" then 
  do:
    { str/psn-chk.i wrkr button r-doc v-ref-rec }
  end.
  if parman = "wrkr" and paraction = "leave" then 
  do:
    { str/psn-chk.i wrkr leave r-doc v-ref-rec }
  end.
end procedure.

{ str/plgdsfnd.i parparentproc }

procedure doc-plsh:

  define buffer buf_trn-doc  for ub.trn-doc.
  define buffer buf_doc-pl   for ub.doc-pl.
  define buffer buf_rvs-line for ub.rvs-line.

  for each buf_trn-doc no-lock
    where buf_trn-doc.obj-type   = r-doc.obj-type
    and buf_trn-doc.obj-code   = r-doc.obj-code
    and buf_trn-doc.shift-date = r-doc.shift-date
    and buf_trn-doc.shift-num  = r-doc.shift-num
    on error undo, return error return-value
    :
    for each buf_doc-pl no-lock
      where buf_doc-pl.out-code = buf_trn-doc.doc-code
      on error undo, return error return-value
      :
      find first buf_rvs-line no-lock
        where buf_rvs-line.rvs-code = r-doc.rvs-code
        and buf_rvs-line.obj-type = r-doc.obj-type
        and buf_rvs-line.obj-code = r-doc.obj-code
        and buf_rvs-line.pl-code  = buf_doc-pl.pl-code
        and buf_rvs-line.gds-code = buf_doc-pl.gds-code
        no-error.
      if not available buf_rvs-line then 
      do:
        tr:
        do transaction
          on error undo tr, return error return-value
          :
          { str/crrvslin.i
            r-doc.obj-type
            r-doc.obj-code
            r-doc.rvs-code
            r-doc.rvs-type
            buf_doc-pl.pl-code
            buf_doc-pl.gds-code
            "( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? )"
            cur_shift-obj.shift-date
            cur_shift-obj.shift-num
            no-error
          }
          if error-status :error then 
          do:
            message 'Ошибка при создании линии.' skip
              return-value
              error-status :get-message( 1 )
              view-as alert-box error.
            undo tr, return error.
          end.
          { str/crrvslnp.i
            r-doc.obj-type
            r-doc.obj-code
            r-doc.rvs-code
            r-doc.rvs-type
            buf_doc-pl.pl-code
            buf_doc-pl.gds-code
            yes
            "( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? )"
            cur_shift-obj.shift-date
            cur_shift-obj.shift-num
            "( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? )"
            yes
            no-error
          }
          if error-status :error then 
          do:
            message 'Ошибка при создании строки данных по ТРК.' skip
              return-value
              error-status :get-message(1)
              view-as alert-box.
            undo tr, return error.
          end.
        end.
      end.
    end.
  end.
end procedure.

procedure local-add :
  assign 
    notes = "".
  run str/chs-gds.w
    ( input        parparentproc
    ,input        r-doc.obj-type
    ,input        r-doc.obj-code
    ,input        '':U
    ,input        r-doc.status_
    ,input        "Строка ДС № " + r-doc.rvs-code + " " + r-doc.status_
    ,input        {&all}
    ,input        ?
    ,input        ?
    ,input        r-doc.host-code
    ,input        ?
    ,input-output varartic
    ,output       notes

    ).
  run cycle-add in this-procedure .
end procedure. /* local-add */

procedure local-chg:
  define buffer buf_goods for ub.goods.
  define variable pl-rvd-dens      as logical   no-undo .
  define variable pl-rvd-lvl       as logical   no-undo .
  define variable pl-rvd-temp      as logical   no-undo .
  define variable pl-level-sr-izm  as integer   no-undo .
  define variable pl-temp-sr-izm   as integer   no-undo .
  define variable v-sug-sr-izm-err as logical   no-undo .
  define variable v-value          as character no-undo .
  define variable v-ok             as logical   no-undo .
  define variable v-log            as logical   no-undo .
  
  assign 
    rvs-line-rec      = recid(ub.rvs-line)
    rvs-line-pump-rec = (if available ub.rvs-line-pump then recid(ub.rvs-line-pump) else ?).
  
  run placelib_get-attr  ( input {&place-rvd-dnsty}
    ,input ub.rvs-line.obj-code
    ,input ub.rvs-line.obj-type
    ,input ub.rvs-line.pl-code
    ,output v-value
    ,output v-ok      ) no-error.
  if not v-ok then pl-rvd-dens = no.
  else pl-rvd-dens = logical(v-value) .
  
  run placelib_get-attr  ( input {&place-rvd-lvl}
    ,input ub.rvs-line.obj-code
    ,input ub.rvs-line.obj-type
    ,input ub.rvs-line.pl-code
    ,output v-value
    ,output v-ok      ) no-error.
  if not v-ok then pl-rvd-lvl = no.
  else pl-rvd-lvl = logical(v-value) .
  
  run placelib_get-attr  ( input {&place-rvd-tmp}
    ,input ub.rvs-line.obj-code
    ,input ub.rvs-line.obj-type
    ,input ub.rvs-line.pl-code
    ,output v-value
    ,output v-ok      ) no-error.
  if not v-ok then pl-rvd-temp = no.
  else pl-rvd-temp = logical(v-value) .
  
  case r-doc.rvs-type
    :
    when {&rvs-before-doc}
    or 
    when {&rvs-after-doc}
    then 
      do:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-on-doc_upd-revision':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
      end.
    when {&rvs-shift}
    then 
      do:
        find first ub.place no-lock where
          ub.place.obj-code = ub.rvs-line.obj-code and
          ub.place.obj-type = ub.rvs-line.obj-type and
          ub.place.pl-code  = ub.rvs-line.pl-code
          no-error. 
        if available ub.place then 
        do :
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_rvs-on-doc_upd-revision':U
            {&cntxt-object}
            r-doc.host-code
            r-doc.obj-type
            r-doc.obj-code
            0
            0
            0
            false
            v-log
          }
          if not v-log
            then 
          do :
            if ub.place.is-meas
              and not pl-rvd-dens
              and not pl-rvd-lvl
              and not pl-rvd-temp
              then 
            do :
            end .
            else 
            do :
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_rvs-control_upd-immeas':U
                {&cntxt-object}
                r-doc.host-code
                r-doc.obj-type
                r-doc.obj-code
                0
                0
                0
                false
                v-log
              } 
            end .
          end .
        end .
      end.
    when {&rvs-shift}
    then 
      do:
        find first ub.place no-lock where
          ub.place.obj-code = ub.rvs-line.obj-code and
          ub.place.obj-type = ub.rvs-line.obj-type and
          ub.place.pl-code  = ub.rvs-line.pl-code
          no-error. 
        if available ub.place then 
        do :
          { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_rvs-shift_upd-revision':U
            {&cntxt-object}
            r-doc.host-code
            r-doc.obj-type
            r-doc.obj-code
            0
            0
            0
            false
            v-log
          }
          if not v-log
            then 
          do :
            if ub.place.is-meas
              and not pl-rvd-dens
              and not pl-rvd-lvl
              and not pl-rvd-temp
              then 
            do :
            end.
            else 
            do :
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_rvs-shift_upd-immeas':U
                {&cntxt-object}
                r-doc.host-code
                r-doc.obj-type
                r-doc.obj-code
                0
                0
                0
                false
                v-log
              }
            end.  
          end .    
        end.  
      end.
    when {&rvs-control}
    then 
      do:
        find first ub.place no-lock where
          ub.place.obj-code = ub.rvs-line.obj-code and
          ub.place.obj-type = ub.rvs-line.obj-type and
          ub.place.pl-code  = ub.rvs-line.pl-code
          no-error.
        if available ub.place then 
        do :
          if pl-rvd-dens or pl-rvd-lvl or pl-rvd-temp then 
          do:
            { gbl/chk-actg.i
            v-cntxt-db-num
            v-cntxt-userid
            {&action-head-code-main}
            'actn_rvs-control_upd-revision':U
            {&cntxt-object}
            r-doc.host-code
            r-doc.obj-type
            r-doc.obj-code
            0
            0
            0
            false
            v-log
          }
          end.
          if not v-log
            then 
          do :
            if ub.place.is-meas
              and not pl-rvd-dens
              and not pl-rvd-lvl
              and not pl-rvd-temp
              then 
            do :
            end.
            else 
            do :
              { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_rvs-control_upd-immeas':U
                {&cntxt-object}
                r-doc.host-code
                r-doc.obj-type
                r-doc.obj-code
                0
                0
                0
                false
                v-log
              } 
            end.
          end .
        end.         
      end.
    otherwise 
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип сверки" skip
        "Тип сверки" r-doc.rvs-type skip
        "Код сверки" r-doc.rvs-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .

  if v-log <> yes then 
  do:
    message "Недостаточно прав для редактирования!" view-as alert-box error .
    return no-apply.
  end.
  find first buf_goods where buf_goods.gds-code = ub.rvs-line.gds-code no-lock.

  if not error-status :error 
    and is-gas(buf_goods.gds-code) then 
  do:
   
    run str/rvs-lin-mask.w
      (input  parparentproc
      ,input  recid(ub.rvs-line)
      ,input  {&update}
      ,input  " # "     + r-doc.rvs-code +
      " товар " + buf_goods.artic     + " " +
      buf_goods.prod-type + " " +
      string(buf_goods.prod-code) +
      " складское место " + string(ub.rvs-line.pl-code)
      ) no-error.
   
  end.

  else 
  do:
    
    define variable is-vir as logical no-undo.
    
    run placelib_get-attr(input {&place-virtual}
      ,input rvs-line.obj-code
      ,input rvs-line.obj-type
      ,input rvs-line.pl-code 
      ,output v-value
      ,output v-ok) no-error.

    is-vir = if (v-ok and logical(v-value)) then true else false.
    
    if is-vir then 
    do:
      message "Редактирование строки сверки виртуального резервуара запрещено." view-as alert-box.
    end.
    else 
    do :
      if available buf_goods
        and is-sug(buf_goods.gds-code) then 
      do:
        
        /*        run placelib_get-attr  ( input {&place-SI-temp}                                                                                                                                                                                                           */
        /*                                ,input rvs-line.obj-code                                                                                                                                                                                                          */
        /*                                ,input rvs-line.obj-type                                                                                                                                                                                                          */
        /*                                ,input rvs-line.pl-code                                                                                                                                                                                                           */
        /*                                ,output v-value                                                                                                                                                                                                                   */
        /*                                ,output v-ok      ) no-error.                                                                                                                                                                                                     */
        /*        if v-ok                                                                                                                                                                                                                                                   */
        /*        then pl-temp-sr-izm = integer(v-value) .                                                                                                                                                                                                                  */
        /*        else pl-temp-sr-izm = ? .                                                                                                                                                                                                                                 */
        /*                                                                                                                                                                                                                                                                  */
        /*        run placelib_get-attr  ( input {&place-SI-level}                                                                                                                                                                                                          */
        /*                                ,input rvs-line.obj-code                                                                                                                                                                                                          */
        /*                                ,input rvs-line.obj-type                                                                                                                                                                                                          */
        /*                                ,input rvs-line.pl-code                                                                                                                                                                                                           */
        /*                                ,output v-value                                                                                                                                                                                                                   */
        /*                                ,output v-ok      ) no-error.                                                                                                                                                                                                     */
        /*        if v-ok                                                                                                                                                                                                                                                   */
        /*        then pl-level-sr-izm = integer(v-value) .                                                                                                                                                                                                                 */
        /*        else pl-level-sr-izm = ? .                                                                                                                                                                                                                                */
        /*                                                                                                                                                                                                                                                                  */
        /*        v-sug-sr-izm-err = no .                                                                                                                                                                                                                                   */
        /*                                                                                                                                                                                                                                                                  */
        /*        if pl-rvd-lvl                                                                                                                                                                                                                                             */
        /*        and (pl-level-sr-izm = ? or pl-level-sr-izm = 0)                                                                                                                                                                                                          */
        /*        then do :                                                                                                                                                                                                                                                 */
        /*          v-sug-sr-izm-err = yes .                                                                                                                                                                                                                                */
        /*          message "Для показателя 'уровень' не установлено средство измерения. Обратитесь в службу поддержки для установки средства измерения 'уровень'. Ввод данных по ручным измерениям без указания средства измерения невозможен." view-as alert-box .        */
        /*        end .                                                                                                                                                                                                                                                     */
        /*                                                                                                                                                                                                                                                                  */
        /*        if pl-rvd-temp                                                                                                                                                                                                                                            */
        /*        and (pl-temp-sr-izm = ? or pl-temp-sr-izm = 0)                                                                                                                                                                                                            */
        /*        then do :                                                                                                                                                                                                                                                 */
        /*          v-sug-sr-izm-err = yes .                                                                                                                                                                                                                                */
        /*          message "Для показателя 'температура' не установлено средство измерения. Обратитесь в службу поддержки для установки средства измерения 'температура'. Ввод данных по ручным измерениям без указания средства измерения невозможен." view-as alert-box .*/
        /*        end .                                                                                                                                                                                                                                                     */
        /*                                                                                                                                                                                                                                                                  */
        /*        if not v-sug-sr-izm-err                                                                                                                                                                                                                                   */
        /*        then do :                                                                                                                                                                                                                                                 */
        run str/rvs-lin-sug.w
          (input  parparentproc
          ,input  recid(ub.rvs-line)
          ,input  {&update}
          ,input  " # "     + r-doc.rvs-code +
          " товар " + buf_goods.artic     + " " +
          buf_goods.prod-type + " " +
          string(buf_goods.prod-code) +
          " складское место " + string(ub.rvs-line.pl-code)
          ) no-error.
      /*        end .*/
      end.
      else 
      do:
        run str/rvs-lin.w
          (input  parparentproc
          ,input  recid(ub.rvs-line)
          ,input  {&update}
          ,input  " # "     + r-doc.rvs-code +
          " товар " + buf_goods.artic     + " " +
          buf_goods.prod-type + " " +
          string(buf_goods.prod-code) +
          " складское место " + string(ub.rvs-line.pl-code)
          ) no-error.
      end.
    end.
  end.

  if error-status :error then 
  do:
    message "Ошибка при редактировании строки сверки." skip
      return-value skip
      error-status:get-message(1)
      view-as alert-box error.
    return error.
  end.
  { str/rvsclchd.i "recid( r-doc )"
             no                       no-error }
  if error-status :error then 
  do:
    message "Ошибка при пересчете шапки документа сверки." skip
      return-value skip
      error-status:get-message(1)
      view-as alert-box error.
    return error.
  end.
    if pardoc-mode <> {&lookup} then  
        find r-doc where recid(r-doc) = parrvs-rec.
    else find r-doc where recid(r-doc) = parrvs-rec no-lock.
end procedure.

procedure proc_m-meas-4 :
   
  define variable VErrorFlag as logical no-undo.
  define buffer meas_pump-nozzle for ub.pump-nozzle.
  apply "entry" to {&browse-name-pump} in frame {&frame-name}.
  if available ub.rvs-line-pump then 
  do:
    find first ub.rvs-line where ub.rvs-line.rvs-code = ub.rvs-line-pump.rvs-code and
      ub.rvs-line.obj-type = ub.rvs-line-pump.obj-type and
      ub.rvs-line.obj-code = ub.rvs-line-pump.obj-code and
      ub.rvs-line.pl-code  = ub.rvs-line-pump.pl-code  and
      ub.rvs-line.gds-code = ub.rvs-line-pump.gds-code no-error.
    assign 
      rvs-line-rec      = (if available ub.rvs-line then recid(ub.rvs-line) else ?)
      rvs-line-pump-rec = recid(ub.rvs-line-pump).
    find first meas_pump-nozzle where meas_pump-nozzle.obj-type    = ub.rvs-line-pump.obj-type    and
      meas_pump-nozzle.obj-code    = ub.rvs-line-pump.obj-code    and
      meas_pump-nozzle.pump-code   = ub.rvs-line-pump.pump-code   and
      meas_pump-nozzle.nozzle-code = ub.rvs-line-pump.nozzle-code no-lock.
    if meas_pump-nozzle.is-meas <> yes then 
    do:
      message "Пистолет " meas_pump-nozzle.nozzle-code " на ТРК " meas_pump-nozzle.pump-code " не измеряется приборами."
        view-as alert-box error.
      return error.
    end.
    run waitfram-show in this-procedure ( input "Просматриваем измеряемые ТРК" ).
    { str/measpmnz.i
        ub.rvs-line-pump.obj-type
        ub.rvs-line-pump.obj-code
        tt-pump-nozzle
        no-error
    }
    if error-status :error then 
    do:
      message "Ошибка при определении пистолетов ТРК для измерения."
        return-value
        view-as alert-box error.
      run waitfram-hide in this-procedure.
      return error.
    end.
    if can-find(first tt-pump-nozzle) then 
    do:
      if ptoldfilvalue = "yes":u then 
      do:
        run gbl/d-askw.w ( input "Выбор источника данных с информацией по ТРК",
          "Будем читать текущие данные с ТРК или возьмем данные из файла?",
          "|^",
          "Текущие данные|Из файлов|Отмена",
          "Запускается программа для обращения к датчикам ТРК|Берутся уже сохраненные данные из файла|Ничего не делаем",
          1,
          3,
          output varnum
          ).
        case varnum:
          when 3 then 
            do:
              /*            undo, return error.*/
              rvs-line-rec = ?.
              rvs-line-pump-rec =?.
            end.
          when 2 then 
            do:
              assign
                varcur-pump = no.
            end.
          when 1 then 
            do:
              assign
                varcur-pump = yes.
            end.
        end case.
      end.
      else 
      do:
        assign
          varcur-pump = yes.
      end.
        
      if varnum ne 3
        then 
      do: 
        run waitfram-show in this-procedure ( input "Делаем сверку по всем ТРК" ).
        tr:
        do transaction
          on error undo tr, retry tr
          :
          if retry then 
          do:
            VErrorFlag = yes.
            leave tr.
          end.
          { str/anls-pmp.i
            parParentProc
            r-doc.obj-type
            r-doc.obj-code
            yes
            tt-pump-nozzle-file
            tt-pump-nozzle
            varcur-pump
            yes
            no
            no-error
          }
          if error-status :error then 
          do:
            message "Ошибка при получении данных с ТРК (anls-pmp)." skip
              error-status :get-message( 1 )                              skip
              return-value
              view-as alert-box error.
            undo tr, retry tr.
          end.
          if return-value <> "":U then 
          do:
            message return-value view-as alert-box information.
          end.
          { str/fill1pmp.i
            "recid( ub.rvs-line-pump )"
            tt-pump-nozzle
            no-error
          }
          if error-status :error then 
          do:
            message
              "Ошибка при сохранении данных в строку счетчиков ТРК." skip
              error-status :get-message( 1 ) skip
              return-value
              view-as alert-box error.
            undo tr, retry tr.
          end.
          run waitfram-show in this-procedure ( input "Пересчитывем строку и шапку" ).
          { str/rvsclcln.i "recid( ub.rvs-line )" no-error }
          if error-status :error then 
          do:
            message
              "Ошибка при пересчете линии." skip
              error-status :get-message( 1 ) skip
              return-value
              view-as alert-box error.
            run waitfram-hide in this-procedure.
            undo tr, retry tr.
          end.

          { str/rvsclchd.i "recid( r-doc )"
                        no                       no-error }
          if error-status :error then 
          do:
            message "Ошибка при пересчете документа." skip
              return-value
              view-as alert-box error.
            run waitfram-hide in this-procedure.
            undo tr, retry tr.
          end.
        end.
      end. /* transaction */
    end.
    else message "Нет ни одного измеряемого счетчика ТРК."
        view-as alert-box information.
    run waitfram-hide in this-procedure.
    run ui-on in this-procedure.
    if VErrorFlag
      then 
      return error.
  end.
  else message "Неверно выбрана строка" view-as alert-box error.
end procedure.

procedure proc-chg-pump :
  define buffer buf_goods for ub.goods.

  assign 
    rvs-line-rec      = ( if available ub.rvs-line then recid( ub.rvs-line ) else ? )
    rvs-line-pump-rec = recid( ub.rvs-line-pump ).
  case r-doc.rvs-type
    :
    when {&rvs-before-doc}
    or 
    when {&rvs-after-doc}
    then 
      do:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-on-doc_upd-revision':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
      end.
    when {&rvs-shift}
    then 
      do:
        find first ub.pump-nozzle no-lock where
          ub.pump-nozzle.obj-code    = ub.rvs-line-pump.obj-code and
          ub.pump-nozzle.obj-type    = ub.rvs-line-pump.obj-type and
          ub.pump-nozzle.pump-code   = ub.rvs-line-pump.pump-code and
          ub.pump-nozzle.nozzle-code = ub.rvs-line-pump.nozzle-code
          no-error. 
        if available ub.pump-nozzle then 
        do :
          if ub.pump-nozzle.is-meas then 
          do :
            { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_rvs-shift_upd-revision-trk':U
                {&cntxt-object}
                r-doc.host-code
                r-doc.obj-type
                r-doc.obj-code
                0
                0
                0
                true
                varlog
              }
          end.
          else 
          do :
            { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_rvs-shift_upd-immeas-trk':U
                {&cntxt-object}
                r-doc.host-code
                r-doc.obj-type
                r-doc.obj-code
                0
                0
                0
                true
                varlog
              }
          end.      
        end.  
      end.
    when {&rvs-control}
    then 
      do:
        find first ub.pump-nozzle no-lock where
          ub.pump-nozzle.obj-code    = ub.rvs-line-pump.obj-code and
          ub.pump-nozzle.obj-type    = ub.rvs-line-pump.obj-type and
          ub.pump-nozzle.pump-code   = ub.rvs-line-pump.pump-code and
          ub.pump-nozzle.nozzle-code = ub.rvs-line-pump.nozzle-code
          no-error. 
        if available ub.pump-nozzle then 
        do :
          if ub.pump-nozzle.is-meas then 
          do :
            { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_rvs-control_upd-revision-trk':U
                {&cntxt-object}
                r-doc.host-code
                r-doc.obj-type
                r-doc.obj-code
                0
                0
                0
                true
                varlog
              }
          end.
          else 
          do :
            { gbl/chk-actg.i
                v-cntxt-db-num
                v-cntxt-userid
                {&action-head-code-main}
                'actn_rvs-control_upd-immeas-trk':U
                {&cntxt-object}
                r-doc.host-code
                r-doc.obj-type
                r-doc.obj-code
                0
                0
                0
                true
                varlog
              } 
          end.
        end.         
      end.
    otherwise 
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип сверки" skip
        "Тип сверки" r-doc.rvs-type skip
        "Код сверки" r-doc.rvs-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
  if varlog <> yes then 
  do: 
    return no-apply. 
  end.
  find first buf_goods no-lock where
    buf_goods.gds-code = ub.rvs-line-pump.gds-code.
  run str/rvs-lnp.w
    (input  parparentproc
    ,input  recid( ub.rvs-line-pump )
    ,input  {&update}
    ,input  " # "               + r-doc.rvs-code                +
    " товар "           + buf_goods.artic                       + " " +
    buf_goods.prod-type                   + " " +
    string( buf_goods.prod-code )         +
    " складское место " + string( ub.rvs-line-pump.pl-code )   +
    " ТРК "             + string( ub.rvs-line-pump.pump-code ) +
    " пистолет "        + string( ub.rvs-line-pump.nozzle-code )
    ) no-error.
  if error-status :error then 
  do:
    message "Ошибка при редактировании данных по ТРК." skip
      return-value skip
      error-status :get-message( 1 )
      view-as alert-box error.
    return error.
  end.
  { str/rvsclchd.i "recid( r-doc )"
               yes                      no-error }
  find first r-doc where recid( r-doc ) = parrvs-rec.
  run ui-on in this-procedure .
end procedure. /* proc-chg-pump */

procedure proc_m-meas-3 :
  define buffer meas-place            for ub.place.
  define buffer olddens_rvs-line-attr for ub.rvs-line-attr .
  define variable VErrorFlag as logical no-undo.
  apply "entry" to {&browse-name} in frame {&frame-name}.
  if available ub.rvs-line then 
  do:
    assign 
      rvs-line-rec      = recid(ub.rvs-line)
      rvs-line-pump-rec = (if available ub.rvs-line-pump then recid(ub.rvs-line-pump) else ?).
    find meas-place where meas-place.obj-type = ub.rvs-line.obj-type and
      meas-place.obj-code = ub.rvs-line.obj-code and
      meas-place.pl-code  = ub.rvs-line.pl-code  no-lock.
    if meas-place.is-meas <> yes then 
    do:
      message "Резервуар " meas-place.pl-code " не измеряется приборами. "
        view-as alert-box error.
      return error.
    end.
    if meas-place.loc1 = "" or meas-place.loc1 = ? then 
    do:
      message "Не указан локальный код на складском месте " meas-place.pl-code
        view-as alert-box error.
      return error.
    end.
    for each tt-meas:
      delete tt-meas.
    end.
    create tt-meas.
    assign 
      tt-meas.obj-type = ub.rvs-line.obj-type
      tt-meas.obj-code = ub.rvs-line.obj-code
      tt-meas.pl-code  = ub.rvs-line.pl-code.
    run waitfram-show in this-procedure ( input ("Делаем сверку по резервуару " + meas-place.loc1) ).
    tr:
    do transaction on error undo tr, retry tr :
      if retry then 
      do:
        VErrorFlag = yes.
        leave tr.
      end.
      find first sys-ctrl no-lock.
      run db-attr-value(sys-ctrl.db,"AsiIp",output v-asi-ip,output v-attr-type).
      run db-attr-value(sys-ctrl.db,"AsiPort",output v-asi-port,output v-attr-type).
      run db-attr-value(sys-ctrl.db,"AsiType",output v-asi-type,output v-attr-type).
      if trim(v-asi-ip) <> ''
        and trim(v-asi-port) <> ''
        and trim(v-asi-type) <> ''
        then 
      do :
        case v-asi-type :
          when "1"
          then 
            do :
              varcur-rvs = 2 .
            end.
          when "2"
          then 
            do :
              varcur-rvs = 3 .
            end.
        end case .
      end.
      else 
      do :
        if ptoldfilvalue = "yes":u then 
        do:
          run gbl/d-askw.w ( input "Выбор источника данных с информацией по резервуарам",
            "Будем читать текущие данные с резервуаров или возьмем данные из файла?",
            "|^",
            "Текущие данные|Из файлов|Отмена",
            "Запускается программа для обращения к датчикам резервуаров|Берутся уже сохраненные данные из файла|Ничего не делаем",
            1,
            3,
            output varnum
            ).
          case varnum:
            when 3 then 
              do:
                undo tr, leave tr.
              end.
            when 2 then 
              do:
                assign
                  varcur-rvs = 0.
              end.
            when 1 then 
              do:
                assign
                  varcur-rvs = 1.
              end.
          end case.
        end.
        else 
        do:
          assign
            varcur-rvs = 1.
        end.
      end.
      { str/rvsplace.i
         r-doc.obj-type
         r-doc.obj-code
         yes
         varcur-rvs
         yes
         no
         tt-meas-file
         tt-meas
         no-error
      }
      if error-status :error then 
      do:
        message "Ошибка при получении данных с приборов на резервуарах." skip
          return-value
          view-as alert-box error.
        undo tr, retry tr.
      end.
      find current ub.rvs-line exclusive-lock.
      { str/fill1plc.i
          ub.rvs-line.obj-type
          ub.rvs-line.obj-code
          ub.rvs-line.pl-code
          "recid( ub.rvs-line )"
          ub.rvs-line.rvs-prev-code
          tt-meas
          no-error
      }
      if error-status :error then 
      do:
        message "Ошибка при заполнении данных с приборов на резервуарах." skip
          return-value
          view-as alert-box error.
        undo tr, retry tr.
      end.
      find first rvs-line-attr exclusive-lock
        where rvs-line-attr.obj-code  = ub.rvs-line.obj-code
        and rvs-line-attr.obj-type  = ub.rvs-line.obj-type
        and rvs-line-attr.gds-code  = ub.rvs-line.gds-code
        and rvs-line-attr.pl-code   = ub.rvs-line.pl-code
        and rvs-line-attr.rvs-code  = ub.rvs-line.rvs-code
        and rvs-line-attr.attr-code = "input-type-p" no-error.
      if not available rvs-line-attr then 
      do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = ub.rvs-line.obj-code
          rvs-line-attr.obj-type  = ub.rvs-line.obj-type
          rvs-line-attr.gds-code  = ub.rvs-line.gds-code
          rvs-line-attr.pl-code   = ub.rvs-line.pl-code
          rvs-line-attr.rvs-code  = ub.rvs-line.rvs-code
          rvs-line-attr.attr-code = "input-type-p"
          .
      end.
      if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
      else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
      find first olddens_rvs-line-attr no-lock
        where olddens_rvs-line-attr.obj-code  = ub.rvs-line.obj-code
        and olddens_rvs-line-attr.obj-type  = ub.rvs-line.obj-type
        and olddens_rvs-line-attr.gds-code  = ub.rvs-line.gds-code
        and olddens_rvs-line-attr.pl-code   = ub.rvs-line.pl-code
        and olddens_rvs-line-attr.rvs-code  = ub.rvs-line.rvs-code
        and olddens_rvs-line-attr.attr-code = "is-olddens" no-error.
      if available olddens_rvs-line-attr
        and logical(olddens_rvs-line-attr.attr-value)
        then 
      do :
        if rvs-line-attr.attr-value = 'а'
          or rvs-line-attr.attr-value = 'ф'
          then rvs-line-attr.attr-value = 'п' .
      end.       
      release rvs-line-attr no-error .
      
      find first rvs-line-attr exclusive-lock
        where rvs-line-attr.obj-code  = ub.rvs-line.obj-code
        and rvs-line-attr.obj-type  = ub.rvs-line.obj-type
        and rvs-line-attr.gds-code  = ub.rvs-line.gds-code
        and rvs-line-attr.pl-code   = ub.rvs-line.pl-code
        and rvs-line-attr.rvs-code  = ub.rvs-line.rvs-code
        and rvs-line-attr.attr-code = "input-type-t" no-error.
      if not available rvs-line-attr then 
      do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = ub.rvs-line.obj-code
          rvs-line-attr.obj-type  = ub.rvs-line.obj-type
          rvs-line-attr.gds-code  = ub.rvs-line.gds-code
          rvs-line-attr.pl-code   = ub.rvs-line.pl-code
          rvs-line-attr.rvs-code  = ub.rvs-line.rvs-code
          rvs-line-attr.attr-code = "input-type-t"
          .
      end.
      if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
      else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
      if available olddens_rvs-line-attr
        and logical(olddens_rvs-line-attr.attr-value)
        then 
      do :
        if rvs-line-attr.attr-value = 'а'
          or rvs-line-attr.attr-value = 'ф'
          then rvs-line-attr.attr-value = 'п' .
      end.       
      release rvs-line-attr no-error .
      
      find first rvs-line-attr exclusive-lock
        where rvs-line-attr.obj-code  = ub.rvs-line.obj-code
        and rvs-line-attr.obj-type  = ub.rvs-line.obj-type
        and rvs-line-attr.gds-code  = ub.rvs-line.gds-code
        and rvs-line-attr.pl-code   = ub.rvs-line.pl-code
        and rvs-line-attr.rvs-code  = ub.rvs-line.rvs-code
        and rvs-line-attr.attr-code = "input-type-l" no-error.
      if not available rvs-line-attr then 
      do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = ub.rvs-line.obj-code
          rvs-line-attr.obj-type  = ub.rvs-line.obj-type
          rvs-line-attr.gds-code  = ub.rvs-line.gds-code
          rvs-line-attr.pl-code   = ub.rvs-line.pl-code
          rvs-line-attr.rvs-code  = ub.rvs-line.rvs-code
          rvs-line-attr.attr-code = "input-type-l"
          .
      end.
      if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
      else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
      release rvs-line-attr no-error .
      
      run waitfram-show in this-procedure ( input "Пересчитывем шапку" ).
      { str/rvsclcln.i "recid( ub.rvs-line )" no-error }
      if error-status :error then 
      do:
        message "Ошибка при пересчете линии." skip
          return-value
          view-as alert-box error.
        undo tr,  retry tr.
      end.
      { str/rvsclchd.i "recid( r-doc )"
                   no                      no-error }
      if error-status :error then 
      do:
        message "Ошибка при пересчете документа." skip
          return-value
          view-as alert-box error.
        undo tr,  retry tr.
      end.
    end. /* transaction */
    run waitfram-hide in this-procedure.
    run ui-on in this-procedure.
    if VErrorFlag 
      then 
      return error.
  end.
  else message "Неверно выбрана строка" view-as alert-box error.
end procedure.

procedure proc-lookup:
  define buffer buf_goods for ub.goods.
  if not available ub.rvs-line-pump then 
  do:
    message "Неправильный выбор строки.".
    return error.
  end.
  assign 
    rvs-line-rec      = (if available ub.rvs-line then recid(ub.rvs-line) else ?)
    rvs-line-pump-rec = recid(ub.rvs-line-pump).
  case r-doc.rvs-type
    :
    when {&rvs-before-doc}
    or 
    when {&rvs-after-doc}
    then 
      do:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-on-doc_lookup':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
      end.
    when {&rvs-shift}
    then 
      do:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-shift_lookup':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
      end.
    when {&rvs-control}
    then 
      do:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-control_lookup':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
      end.
    otherwise 
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип сверки" skip
        "Тип сверки" r-doc.rvs-type skip
        "Код сверки" r-doc.rvs-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
  if varlog <> yes then 
  do: 
    return error. 
  end.
  find first buf_goods where buf_goods.gds-code = ub.rvs-line-pump.gds-code no-lock.
  run str/rvs-lnp.w
    (input  parparentproc
    ,input  recid(ub.rvs-line-pump)
    ,input  {&lookup}
    ,input  " # "     + r-doc.rvs-code +
    " товар " + buf_goods.artic     + " " +
    buf_goods.prod-type + " " +
    string(buf_goods.prod-code) +
    " складское место " + string(ub.rvs-line-pump.pl-code) +
    " ТРК " + string(ub.rvs-line-pump.pump-code) +
    " пистолет " + string(ub.rvs-line-pump.nozzle-code)
    ) no-error.
  if error-status :error then 
  do:
    message "Ошибка при просмотре данных по ТРК." skip
      return-value skip
      error-status:get-message(1)
      view-as alert-box error.
    return error.
  end.
    if pardoc-mode = {&lookup} then
        find r-doc where recid(r-doc) = parrvs-rec no-lock.
    else find r-doc where recid(r-doc) = parrvs-rec .
end procedure.

procedure proc-lkp:
  define buffer buf_goods for ub.goods.
  if not available ub.rvs-line then 
  do:
    message "Неправильный выбор строки.".
    return error.
  end.
  assign 
    rvs-line-rec      = recid(ub.rvs-line)
    rvs-line-pump-rec = (if available ub.rvs-line-pump then recid(ub.rvs-line-pump) else ?).
  case r-doc.rvs-type
    :
    when {&rvs-before-doc}
    or 
    when {&rvs-after-doc}
    then 
      do:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-on-doc_lookup':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
      end.
    when {&rvs-shift}
    then 
      do:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-shift_lookup':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
      end.
    when {&rvs-control}
    then 
      do:
        { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-control_lookup':U
        {&cntxt-object}
        r-doc.host-code
        r-doc.obj-type
        r-doc.obj-code
        0
        0
        0
        true
        varlog
      }
      end.
    otherwise 
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип сверки" skip
        "Тип сверки" r-doc.rvs-type skip
        "Код сверки" r-doc.rvs-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
  if varlog <> yes then 
  do: 
    return error. 
  end.
  find first buf_goods where buf_goods.gds-code = ub.rvs-line.gds-code no-lock.

  if not error-status :error 
    and is-gas(buf_goods.gds-code) then 
  do:
   
    run str/rvs-lin-mask.w
      (input  parparentproc
      ,input  recid(ub.rvs-line)
      ,input  {&lookup}
      ,input  " # "     + r-doc.rvs-code +
      " товар " + buf_goods.artic     + " " +
      buf_goods.prod-type + " " +
      string(buf_goods.prod-code) +
      " складское место " + string(ub.rvs-line.pl-code)
      ) no-error.
   
  end.
  else
    if not error-status :error 
      and is-sug(buf_goods.gds-code) then 
    do:
   
      run str/rvs-lin-sug.w
        (input  parparentproc
        ,input  recid(ub.rvs-line)
        ,input  {&lookup}
        ,input  " # "     + r-doc.rvs-code +
        " товар " + buf_goods.artic     + " " +
        buf_goods.prod-type + " " +
        string(buf_goods.prod-code) +
        " складское место " + string(ub.rvs-line.pl-code)
        ) no-error.
   
    end.
    else 
    do:

      run str/rvs-lin.w
        (input  parparentproc
        ,input  recid(ub.rvs-line)
        ,input  {&lookup}
        ,input  " # "     + r-doc.rvs-code +
        " товар " + buf_goods.artic     + " " +
        buf_goods.prod-type + " " +
        string(buf_goods.prod-code) +
        " складское место " + string(ub.rvs-line.pl-code)
        ) no-error.
  
    end.
  
  if error-status :error then 
  do:
    message "Ошибка при просмотре строки сверки." skip
      return-value skip
      error-status:get-message(1)
      view-as alert-box error.
    return error.
  end.
  if pardoc-mode = {&lookup} then
  find r-doc where recid(r-doc) = parrvs-rec no-lock.
  else find r-doc where recid(r-doc) = parrvs-rec.
  run ui-on in this-procedure .
end procedure.

procedure proc_m-add-2 :
  run waitfram-show in this-procedure ( input "Создаем строки по резервуарам" ).
  tr:
  do transaction on error undo, return error
    on stop  undo, return error
    on quit  undo, return error :
    { str/place-sh.i
       r-doc.obj-type
       r-doc.obj-code
       r-doc.rvs-code
       r-doc.rvs-type
       "( if available prev_rvs-doc then prev_rvs-doc.rvs-code else ? )"
       cur_shift-obj.shift-date
       cur_shift-obj.shift-num
       no
       no-error
   }
    if error-status :error then 
    do:
      message "Ошибка при создании линий документа сверки." skip
        return-value
        view-as alert-box error.
      run waitfram-hide in this-procedure.
      undo tr, return error.
    end.
    run waitfram-show in this-procedure ( input "Создаем строки по ТРК" ).
    { str/pump-sh.i
       r-doc.obj-type
       r-doc.obj-code
       r-doc.rvs-code
       r-doc.rvs-type
       "( if available prev_rvs-doc  then prev_rvs-doc.rvs-code  else ? )"
       "( if available prev_icnt-doc then prev_icnt-doc.doc-code else ? )"
       cur_shift-obj.shift-date
       cur_shift-obj.shift-num
       yes
       yes
       no-error
   }
    if error-status :error then 
    do:
      message "Ошибка при создании линий ТРК документа сверки." skip
        return-value
        view-as alert-box error.
      run waitfram-hide in this-procedure.
      undo tr, return error.
    end.
  end. /* transaction */
  run waitfram-hide in this-procedure.
end procedure.

procedure proc_m-meas-1:
  define buffer bf_place  for ub.place.
  define buffer bf_r-line for ub.rvs-line.
  
  define variable VErrorFlag as logical no-undo.
  
  assign 
    rvs-line-rec      = (if available ub.rvs-line      then recid(ub.rvs-line)      else ?)
    rvs-line-pump-rec = (if available ub.rvs-line-pump then recid(ub.rvs-line-pump) else ?).
  run waitfram-show in this-procedure ( input "Просматриваем измеряемые резервуары" ).
  { str/meas-plc.i
      r-doc.obj-type
      r-doc.obj-code
      tt-meas
      no-error
  }
  if error-status :error then 
  do:
    message "Ошибка при определении резервуаров для измерения."
      return-value
      view-as alert-box error.
    run waitfram-hide in this-procedure.
    return error.
  end.
  if can-find( first tt-meas ) then 
  do:
    run waitfram-show in this-procedure ( input "Делаем сверку по всем резервуарам" ).
    tr:
    do transaction on error undo tr, retry tr :
      if retry then 
      do:
        VErrorFlag = yes.
        leave tr.
      end.
      find first sys-ctrl no-lock.
      run db-attr-value(sys-ctrl.db,"AsiIp",output v-asi-ip,output v-attr-type).
      run db-attr-value(sys-ctrl.db,"AsiPort",output v-asi-port,output v-attr-type).
      run db-attr-value(sys-ctrl.db,"AsiType",output v-asi-type,output v-attr-type).
      if trim(v-asi-ip) <> ''
        and trim(v-asi-port) <> ''
        and trim(v-asi-type) <> ''
        then 
      do :
        case v-asi-type :
          when "1"
          then 
            do :
              varcur-rvs = 2 .
            end.
          when "2"
          then 
            do :
              varcur-rvs = 3 .
            end.
        end case .
      end.
      else 
      do :
        if ptoldfilvalue = "yes":u then 
        do:
          run gbl/d-askw.w ( input "Выбор источника данных с информацией по резервуарам",
            "Будем читать текущие данные с резервуаров или возьмем данные из файла?",
            "|^",
            "Текущие данные|Из файлов|Отмена",
            "Запускается программа для обращения к датчикам резервуаров|Берутся уже сохраненные данные из файла|Ничего не делаем",
            1,
            3,
            output varnum
            ).
          case varnum:
            when 3 then 
              do:
                undo tr, leave tr.
              end.
            when 2 then 
              do:
                assign
                  varcur-rvs = 0.
              end.
            when 1 then 
              do:
                assign
                  varcur-rvs = 1.
              end.
          end case.
        end.
        else 
        do:
          assign
            varcur-rvs = 1.
        end.
      end.
      { str/rvsplace.i
          r-doc.obj-type
          r-doc.obj-code
          no
          varcur-rvs
          yes
          no
          tt-meas-file
          tt-meas
          no-error
      }
      if error-status :error then 
      do:
        message "Ошибка при получении данных с приборов на резервуарах." skip
          return-value
          view-as alert-box error.
        undo tr, retry tr.
      end.
      { str/fall-plc.i
          r-doc.obj-type
          r-doc.obj-code
          r-doc.rvs-code
          yes
          no-error
      }
      if error-status :error then 
      do:
        message "Ошибка при заполнении данных с приборов на резервуарах." skip
          return-value
          view-as alert-box error.
        undo tr, retry tr.
      end.
      for  each bf_r-line where
        bf_r-line.rvs-code = r-doc.rvs-code and
        bf_r-line.obj-type = r-doc.obj-type and
        bf_r-line.obj-code = r-doc.obj-code
        , first bf_place    where
        bf_place.obj-type = bf_r-line.obj-type and
        bf_place.obj-code = bf_r-line.obj-code and
        bf_place.pl-code  = bf_r-line.pl-code and
        bf_place.is-meas  = yes 
        :
        find first rvs-line-attr exclusive-lock
          where rvs-line-attr.obj-code  = bf_r-line.obj-code
          and rvs-line-attr.obj-type  = bf_r-line.obj-type
          and rvs-line-attr.gds-code  = bf_r-line.gds-code
          and rvs-line-attr.pl-code   = bf_r-line.pl-code
          and rvs-line-attr.rvs-code  = bf_r-line.rvs-code
          and rvs-line-attr.attr-code = "input-type-p" no-error.
        if not available rvs-line-attr then 
        do :
          create rvs-line-attr.
          assign
            rvs-line-attr.obj-code  = bf_r-line.obj-code
            rvs-line-attr.obj-type  = bf_r-line.obj-type
            rvs-line-attr.gds-code  = bf_r-line.gds-code
            rvs-line-attr.pl-code   = bf_r-line.pl-code
            rvs-line-attr.rvs-code  = bf_r-line.rvs-code
            rvs-line-attr.attr-code = "input-type-p"
            .
        end.
        if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
        else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
        
        find first rvs-line-attr exclusive-lock
          where rvs-line-attr.obj-code  = bf_r-line.obj-code
          and rvs-line-attr.obj-type  = bf_r-line.obj-type
          and rvs-line-attr.gds-code  = bf_r-line.gds-code
          and rvs-line-attr.pl-code   = bf_r-line.pl-code
          and rvs-line-attr.rvs-code  = bf_r-line.rvs-code
          and rvs-line-attr.attr-code = "input-type-t" no-error.
        if not available rvs-line-attr then 
        do :
          create rvs-line-attr.
          assign
            rvs-line-attr.obj-code  = bf_r-line.obj-code
            rvs-line-attr.obj-type  = bf_r-line.obj-type
            rvs-line-attr.gds-code  = bf_r-line.gds-code
            rvs-line-attr.pl-code   = bf_r-line.pl-code
            rvs-line-attr.rvs-code  = bf_r-line.rvs-code
            rvs-line-attr.attr-code = "input-type-t"
            .
        end.
        if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
        else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
        
        find first rvs-line-attr exclusive-lock
          where rvs-line-attr.obj-code  = bf_r-line.obj-code
          and rvs-line-attr.obj-type  = bf_r-line.obj-type
          and rvs-line-attr.gds-code  = bf_r-line.gds-code
          and rvs-line-attr.pl-code   = bf_r-line.pl-code
          and rvs-line-attr.rvs-code  = bf_r-line.rvs-code
          and rvs-line-attr.attr-code = "input-type-l" no-error.
        if not available rvs-line-attr then 
        do :
          create rvs-line-attr.
          assign
            rvs-line-attr.obj-code  = bf_r-line.obj-code
            rvs-line-attr.obj-type  = bf_r-line.obj-type
            rvs-line-attr.gds-code  = bf_r-line.gds-code
            rvs-line-attr.pl-code   = bf_r-line.pl-code
            rvs-line-attr.rvs-code  = bf_r-line.rvs-code
            rvs-line-attr.attr-code = "input-type-l"
            .
        end.
        if varcur-rvs > 0 then rvs-line-attr.attr-value = 'а' .
        else if ptoldfilvalue = "yes":u then rvs-line-attr.attr-value = 'ф' .
      end.
      release rvs-line-attr no-error .
      run waitfram-show in this-procedure ( input "Пересчитывем шапку" ).
      { str/rvsclchd.i "recid( r-doc )"
                   no                       no-error }
      if error-status :error then 
      do:
        message "Ошибка при пересчете документа." skip
          return-value
          view-as alert-box error.
        undo tr, retry tr.
      end.
    end. /* transaction */
  end.
  else 
  do: 
    message "Нет ни одного измеряемого резервуара." view-as alert-box. 
  end.
  run waitfram-hide in this-procedure.
  run ui-on in this-procedure .
  if VErrorFlag
    then
    return error.
end procedure.

procedure proc_m-meas-2 :
   
  define variable VErrorFlag as logical no-undo.
  assign 
    rvs-line-rec      = (if available ub.rvs-line      then recid(ub.rvs-line)      else ?)
    rvs-line-pump-rec = (if available ub.rvs-line-pump then recid(ub.rvs-line-pump) else ?).
  run waitfram-show in this-procedure ( input "Просматриваем измеряемые ТРК" ).
  { str/measpmnz.i
      ub.rvs-line-pump.obj-type
      ub.rvs-line-pump.obj-code
      tt-pump-nozzle
      no-error
  }
  if error-status :error then 
  do:
    message "Ошибка при определении пистолетов ТРК для измерения."
      return-value
      view-as alert-box error.
    run waitfram-hide in this-procedure.
    return error.
  end.
  if can-find(first tt-pump-nozzle) then 
  do:
    run waitfram-show in this-procedure ( input "Делаем сверку по всем ТРК" ).
    tr:
    do transaction on error undo tr, retry tr :
      if retry then 
      do:
        VErrorFlag = yes.
        leave tr.
      end.
      if ptoldfilvalue = "yes":u then 
      do:
        run gbl/d-askw.w ( input "Выбор источника данных с информацией по ТРК",
          "Будем читать текущие данные с ТРК или возьмем данные из файла?",
          "|^",
          "Текущие данные|Из файлов|Отмена",
          "Запускается программа для обращения к датчикам ТРК|Берутся уже сохраненные данные из файла|Ничего не делаем",
          1,
          3,
          output varnum
          ).
        case varnum:
          when 3 then 
            do:
              undo, leave tr.
            end.
          when 2 then 
            do:
              assign
                varcur-pump = no.
            end.
          when 1 then 
            do:
              assign
                varcur-pump = yes.
            end.
        end case.
      end.
      else 
      do:
        assign
          varcur-pump = yes.
      end.
      { str/rvs-pump.i
        parParentProc
        r-doc.obj-type
        r-doc.obj-code
        r-doc.rvs-code
        varcur-pump
        tt-pump-nozzle-file
        tt-pump-nozzle
        no-error
      }
      if error-status :error then 
      do:
        message "Ошибка при получении данных с приборов на ТРК и записи их в строки." skip
          return-value
          view-as alert-box error.
        undo tr, retry tr.
      end.
      if return-value <> "":U then 
      do:
        message return-value view-as alert-box information.
      end.

      run waitfram-show in this-procedure ( input "Пересчитывем строки и шапку" ).
      { str/rvsclchd.i "recid( r-doc )"
                   yes                      no-error }
      if error-status :error then 
      do:
        message "Ошибка при пересчете документа." skip
          return-value
          view-as alert-box error.
        undo tr, retry tr.
      end.
    end. /* transaction */
  end.
  else 
  do:
    message "Нет ни одного измеряемого счетчика ТРК." view-as alert-box information.
  end.
  run waitfram-hide in this-procedure.
  run ui-on in this-procedure.
  if VErrorFlag
    then 
    return error.
end procedure. /* proc_m-meas-2 */

/* определение, попадает ли сверка в период слива */
procedure CheckColorSkip:
   define input parameter p-obj-type as character no-undo.
   define input parameter p-obj-code as integer no-undo. 
   define input parameter p-shift-date as date no-undo.
   define input parameter p-shift-num as integer no-undo.
   define input parameter p-pl-code as integer no-undo.
   define input parameter p-gds-code as integer no-undo.
   define input parameter p-sys-date     as date      no-undo.
   define input parameter p-sys-time-int as integer   no-undo.
   define output parameter vNeedSkip     as logical   no-undo.
      
   define buffer buf_rvs-doc for ub.rvs-doc.
   define buffer buf_rvs-line for ub.rvs-line.
   define buffer buf_rvs-doc_end for ub.rvs-doc. 
   define buffer buf_doc-line-attr  for ub.doc-line-attr.
   define buffer buf_doc-line-attr1 for ub.doc-line-attr.
   
   define variable vBegTime as datetime no-undo.
   define variable vEndTime as datetime no-undo. 
   
   vNeedSkip = no.
   
   /* отбираем все сверки до */
   rvsdoc:            
   for each buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type   = p-obj-type
          and buf_rvs-doc.obj-code   = p-obj-code
          and buf_rvs-doc.shift-date = p-shift-date
          and buf_rvs-doc.shift-num  = p-shift-num
          and buf_rvs-doc.status_    = {&fact}
          and buf_rvs-doc.rvs-type  = {&rvs-before-doc}
        ,first buf_rvs-line no-lock
        where buf_rvs-line.rvs-code   = buf_rvs-doc.rvs-code
          and buf_rvs-line.obj-type   = buf_rvs-doc.obj-type
          and buf_rvs-line.obj-code   = buf_rvs-doc.obj-code
          and buf_rvs-line.pl-code    = p-pl-code
          and buf_rvs-line.gds-code   = p-gds-code:
             
      /* ищем сверку после */       
      find first  buf_rvs-doc_end no-lock 
           where buf_rvs-doc_end.rvs-type = {&rvs-after-doc}
          and buf_rvs-doc_end.out-code =  buf_rvs-doc.out-code
          no-error.
      if not avail buf_rvs-doc_end then next  rvsdoc.    
      
      /* ищем атрибуты накладной с временем начала и окончания слива */ 
      find first buf_doc-line-attr no-lock where 
                 buf_doc-line-attr.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr.attr-code begins "date-start"
         no-error.
      find first buf_doc-line-attr1 no-lock where 
                 buf_doc-line-attr1.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr1.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr1.attr-code begins "time-start"
         no-error.       
      if available buf_doc-line-attr and 
         available buf_doc-line-attr1 
      then  vBegTime = datetime(date(buf_doc-line-attr.attr-value), (int(buf_doc-line-attr1.attr-value) * 1000 )).
      else  vBegTime = datetime(buf_rvs-doc.sys-date, (buf_rvs-doc.sys-time-int * 1000 )).
         
      find first buf_doc-line-attr no-lock where 
                 buf_doc-line-attr.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr.attr-code begins "date-end"
         no-error.
      find first buf_doc-line-attr1 no-lock where 
                 buf_doc-line-attr1.doc-code = buf_rvs-doc.out-code
             and buf_doc-line-attr1.gds-code = buf_rvs-line.gds-code
             and buf_doc-line-attr1.attr-code begins "time-end"
         no-error.       
      if available buf_doc-line-attr and 
         available buf_doc-line-attr1 
      then  vEndTime = datetime(date(buf_doc-line-attr.attr-value), ((int(buf_doc-line-attr1.attr-value) + vTimeAutoSkip * 60) * 1000 )).  
      else  vEndTime = datetime(buf_rvs-doc_end.sys-date, ((buf_rvs-doc_end.sys-time-int + vTimeAutoSkip * 60) * 1000 )).        
      
      if vBegTime <= datetime(p-sys-date, (p-sys-time-int * 1000 )) 
         and vEndTime >= datetime(p-sys-date, (p-sys-time-int * 1000 )) then 
      do:
         vNeedSkip = yes.
         leave rvsdoc.
      end.          
   end.          
   
end procedure. /* CheckColorSkip */
