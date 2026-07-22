&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаленные сверки по объекту

Автор: Шаланин Сергей 
Дата создания: 10/07/16
Author: Shalanin Sergey
Creation date: 10/07/16



*/

define input        parameter parparentproc as handle    no-undo .
define input        parameter pardoc-mode   as character no-undo .
define input        parameter parrvs-type   as character no-undo .
define input        parameter parall-place  as logical   no-undo .
define input-output parameter parrvs-rec    as recid     no-undo .
define input-output parameter p-next-prev as character no-undo .
define input parameter p-call-prog  as handle no-undo .

define variable        varlog            as   logical                    no-undo.

&scop frame-name       d-rvs
&scop browse-name      br-line
&scop browse-name-pump br-pump

/* ***************************  definitions  ************************** */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Удаленные сверки ":U.

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
{ str/placelib.i      }

define buffer c-rvs-doc          for ub.c-rvs-doc.
define buffer cur_shift-obj  for ub.shift-obj.
define buffer prev_shift-obj for ub.shift-obj.
define buffer prev_rvs-doc   for ub.c-rvs-doc.
define buffer prev_icnt-doc  for ub.icnt-doc.

define variable v-ref-rec as recid no-undo .

/* ********************  preprocessor definitions  ******************** */
&scop open-query-{&browse-name} open query {&browse-name} ~
   for each  ub.c-rvs-line no-lock where ~
             ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code ~
             and c-rvs-line.chip-num = c-rvs-doc.chip-num ~
     , first ub.goods        no-lock where ~
             ub.goods.gds-code        = ub.c-rvs-line.gds-code ~
     , first ub.place                where ~
             ub.place.obj-type        = ub.c-rvs-line.obj-type and ~
             ub.place.obj-code        = ub.c-rvs-line.obj-code and ~
             ub.place.pl-code         = ub.c-rvs-line.pl-code  and ~
             ub.place.status_ <>      {&deleted-status}
             

&scop open-query-{&browse-name}-default {&open-query-{&browse-name}}.

&scop open-query-{&browse-name-pump} open query {&browse-name-pump} ~
   for each ub.c-rvs-line-pump no-lock where ~
            ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and ~
            ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and ~
            ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and ~
            ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and ~
            ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and ~
              ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num

&scop open-query-{&browse-name-pump}-default {&open-query-{&browse-name-pump}}.

&scop label-clmn_1-br-line  '*'
&scop sort-clmn_1-br-line   get-mark (buffer ub.c-rvs-line)
&scop label-clmn_2-br-line  'Артикул'
&scop sort-clmn_2-br-line   ub.goods.artic
&scop label-clmn_3-br-line  'Название'
&scop sort-clmn_3-br-line   ub.goods.gds-name
&scop label-clmn_4-br-line  'Скл.место'
&scop sort-clmn_4-br-line   ub.c-rvs-line.pl-code
&scop label-clmn_5-br-line  'Номер резервуара'
&scop sort-clmn_5-br-line   place.loc1
&scop label-clmn_6-br-line  'Факт остаток'
&scop sort-clmn_6-br-line   ub.c-rvs-line.state-measure-qnty
&scop label-clmn_7-br-line  'Измер. остаток'
&scop sort-clmn_7-br-line   ub.c-rvs-line.measure-qnty
&scop label-clmn_8-br-line  'Учет'
&scop sort-clmn_8-br-line   ub.c-rvs-line.system-qnty
&scop label-clmn_9-br-line  'Первонач.учет'
&scop sort-clmn_9-br-line   ub.c-rvs-line.orig-system-qnty
&scop label-clmn_10-br-line 'Факт в!трубопроводе'
&scop sort-clmn_10-br-line  ub.c-rvs-line.state-add-qnty
&scop label-clmn_11-br-line 'Отклонение(факт)'
&scop sort-clmn_11-br-line  deviation-fact(buffer ub.c-rvs-line)
&scop label-clmn_12-br-line 'Отклонение(измер)'
&scop sort-clmn_12-br-line  deviation-measure(buffer ub.c-rvs-line)
&scop label-clmn_13-br-line 'Допустимое!отклонение'
&scop sort-clmn_13-br-line  ub.c-rvs-line.tolerance
&scop label-clmn_14-br-line 'Факт брутто'
&scop sort-clmn_14-br-line  ub.c-rvs-line.state-brutto-qnty
&scop sort-clmn_15-br-line  ub.c-rvs-line.brutto-qnty
&scop sort-clmn_16-br-line  ub.c-rvs-line.state-density
&scop sort-clmn_17-br-line  ub.c-rvs-line.density
&scop sort-clmn_18-br-line  ub.c-rvs-line.state-measure-cli-qnty
&scop sort-clmn_19-br-line  ub.c-rvs-line.measure-cli-qnty
&scop sort-clmn_20-br-line  ub.c-rvs-line.system-cli-qnty
&scop sort-clmn_21-br-line  ub.c-rvs-line.orig-system-cli-qnty
&scop sort-clmn_22-br-line  ub.c-rvs-line.state-brutto-cli-qnty
&scop sort-clmn_23-br-line  ub.c-rvs-line.brutto-cli-qnty
&scop sort-clmn_24-br-line  ub.c-rvs-line.state-mh-qnty
&scop sort-clmn_25-br-line  ub.c-rvs-line.meas-mh-qnty
&scop sort-clmn_26-br-line  ub.c-rvs-line.state-am-qnty
&scop sort-clmn_27-br-line  ub.c-rvs-line.meas-am-qnty
&scop sort-clmn_28-br-line  ub.c-rvs-line.state-cf-qnty
&scop sort-clmn_29-br-line  ub.c-rvs-line.meas-cf-qnty
&scop sort-clmn_30-br-line  ub.c-rvs-line.state-level-total
&scop sort-clmn_31-br-line  ub.c-rvs-line.level-total
&scop sort-clmn_32-br-line  ub.c-rvs-line.state-level-petrol
&scop sort-clmn_33-br-line  ub.c-rvs-line.level-petrol
&scop sort-clmn_34-br-line  ub.c-rvs-line.state-level-water
&scop sort-clmn_35-br-line  ub.c-rvs-line.level-water
&scop sort-clmn_36-br-line  ub.c-rvs-line.state-temperature
&scop sort-clmn_37-br-line  ub.c-rvs-line.temperature
&scop enabled-clmn          {&sort-clmn_37-br-line}

&scop label-clmn_1-br-line-pump 'ТРК'
&scop sort-clmn_1-br-line-pump  ub.c-rvs-line-pump.pump-code
&scop label-clmn_2-br-line-pump 'П'
&scop sort-clmn_2-br-line-pump  ub.c-rvs-line-pump.nozzle-code
&scop sort-clmn_3-br-line-pump  ub.c-rvs-line-pump.state-mh-qnty
&scop sort-clmn_4-br-line-pump  ub.c-rvs-line-pump.meas-mh-qnty
&scop sort-clmn_5-br-line-pump  ub.c-rvs-line-pump.state-am-qnty
&scop sort-clmn_6-br-line-pump  ub.c-rvs-line-pump.meas-am-qnty
&scop sort-clmn_7-br-line-pump  ub.c-rvs-line-pump.state-cf-qnty
&scop sort-clmn_8-br-line-pump  ub.c-rvs-line-pump.meas-cf-qnty
&scop sort-clmn_9-br-line-pump  ub.c-rvs-line-pump.state-mh-cnt
&scop sort-clmn_10-br-line-pump ub.c-rvs-line-pump.meas-mh-cnt
&scop sort-clmn_11-br-line-pump ub.c-rvs-line-pump.state-el-cnt
&scop sort-clmn_12-br-line-pump ub.c-rvs-line-pump.meas-el-cnt
&scop sort-clmn_13-br-line-pump ub.c-rvs-line-pump.state-am-cnt
&scop sort-clmn_14-br-line-pump ub.c-rvs-line-pump.meas-am-cnt
&scop sort-clmn_15-br-line-pump ub.c-rvs-line-pump.state-cf-cnt
&scop sort-clmn_16-br-line-pump ub.c-rvs-line-pump.meas-cf-cnt
&scop sort-clmn_17-br-line-pump ub.c-rvs-line-pump.icnt-code
&scop sort-clmn_18-br-line-pump ub.c-rvs-line-pump.rvs-prev-code
&scop enabled-clmn-pump         {&sort-clmn_18-br-line-pump}

/* ***********************  control definitions  ********************** */
define variable rvs-line-rec      as   recid                no-undo.
define variable rvs-line-pump-rec as   recid                no-undo.
define variable varartic          like ub.doc-line.artic    no-undo initial " ".
define variable ref-list          as   character            no-undo.
define variable l-g#stat          as   character            no-undo.
define variable l-g#type          as   character            no-undo.
define variable l-g#internal      as   logical              no-undo.
define variable varres            as   logical              no-undo initial ?.
define variable varrecid          as   recid                no-undo.
define variable ptoldfilvalue     as   character            no-undo.
define variable ptoldfiltype      as   character            no-undo.
define variable varcur-data       as   logical              no-undo.
define variable varnum            as   integer              no-undo.
define variable varcur-rvs        as   logical              no-undo.
define variable varcur-pump       as   logical              no-undo.
define variable gds-rec           as   recid                no-undo.
define variable notes             as   character            no-undo.
define variable rep-rec           as   recid                no-undo.
define variable lns-cnt           as   integer              no-undo.

define buffer cli-buf          for ub.clients.
define buffer del-rvs-line for ub.c-rvs-line.

define button b-help
     label "Помощь":U
     size 10 by 1.

define button b-exit AUTO-GO
     label "Выход":U
     size 10 by 1.

define button b-mark
     label "&*":U
     size 3 by 1.

DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.

DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.

define button b-lkp
     label "Просмотр":U
     size 10 by 1.

define button b-lkp-pump
     label "Просм ТРК":U
     size 10 by 1.

define button b-history
     label "История":U
     size 10 by 1.

define button b-notes
     label "Прим.":U
     size 10 by 1.


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
     size 14 by 1 no-undo.

define variable boss-name as character format "x(256)":u
      view-as text
     size 14 by 1 no-undo.

define variable wrkr-name as character format "x(256)":u
      view-as text
     size 14 by 1 no-undo.

define variable del-list as character no-undo.

function get-mark return character (buffer local-rvs-line for ub.c-rvs-line ).
   if lookup (string (recid (local-rvs-line)), del-list) > 0 then return "*".
                                                                 else return "".
end function.

function deviation-fact    return decimal (buffer local-rvs-line for ub.c-rvs-line ).
   return (local-rvs-line.state-measure-qnty   + local-rvs-line.state-add-qnty - local-rvs-line.system-qnty).
end function.

function deviation-measure return decimal (buffer local-rvs-line for ub.c-rvs-line ).
   return (local-rvs-line.measure-qnty + local-rvs-line.state-add-qnty - local-rvs-line.system-qnty).
end function.

define query {&browse-name}      for ub.c-rvs-line, ub.goods, ub.place scrolling.
define query {&browse-name-pump} for ub.c-rvs-line-pump                scrolling.
define browse {&browse-name} query {&browse-name} no-lock display
      {&sort-clmn_1-br-line}  column-label {&label-clmn_1-br-line}  format "x(1)"
      {&sort-clmn_2-br-line}  column-label {&label-clmn_2-br-line}
      {&sort-clmn_3-br-line}  column-label {&label-clmn_3-br-line}  format "x(15)"
      {&sort-clmn_4-br-line}  column-label {&label-clmn_4-br-line}
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
B-prev              at row 1 col 30
B-next             at row 1 col 34
b-help              at row 1  col 81
"Объект:"                         at row 2 col 10
c-rvs-doc.obj-code                    at row 2 col 16   colon-aligned no-label       view-as text size 7    by 1
c-rvs-doc.obj-type                    at row 2 col 23   colon-aligned no-label       view-as text size 7.13 by 1
ub.clients.obj-name               at row 2 col 33   colon-aligned no-label       view-as text size 40 by 1 fgcolor 4
c-rvs-doc.out-code                    at row 3 col 20   colon-aligned label "На основе документа" view-as text
c-rvs-doc.doc-date                    at row 3 col 40   colon-aligned view-as text
c-rvs-doc.state-measure-qnty          at row 4 col 38   colon-aligned view-as text
c-rvs-doc.measure-qnty                at row 4 col 63   colon-aligned label "Измер" view-as text
c-rvs-doc.system-qnty                 at row 4 col 85.5                          colon-aligned view-as text
c-rvs-doc.wrkr                        at row 5 col 4.5  colon-aligned format "999999999"  view-as fill-in size 10 by 1
wrkr-name                         at row 5 col 15   colon-aligned no-label fgcolor 4
r-wrkr                            at row 5 col 28   no-label
c-rvs-doc.state-measure-cli-qnty      at row 5 col 50   colon-aligned label "Вес"       view-as text
c-rvs-doc.measure-cli-qnty            at row 5 col 85.5 colon-aligned label "Измер.вес" view-as text
c-rvs-doc.agnt                        at row 6 col 4.5 colon-aligned format "999999999"  view-as fill-in size 10 by 1
agnt-name                         at row 6 col 15  colon-aligned no-label fgcolor 4
r-agnt                            at row 6 col 28  no-label
c-rvs-doc.system-cli-qnty         at row 6 col 50    colon-aligned label "Учет вес"         view-as text
c-rvs-doc.system-cli-avrg-qnty    at row 6 col 85.5  colon-aligned label "Вес по ср.пл-ти"  view-as text
c-rvs-doc.boss                    at row 7 col 4.5   colon-aligned format "999999999"       view-as fill-in size 10 by 1
boss-name                     at row 7 col 15    colon-aligned no-label                fgcolor 4
r-boss                        at row 7 col 28    no-label
c-rvs-doc.state-mh-qnty           at row 7 col 38    colon-aligned label "Оборот"           view-as text format "->,>>>,>>>,>>>.<<<"
c-rvs-doc.state-am-qnty           at row 7 col 63    colon-aligned label "Сумма"            view-as text format "->,>>>,>>>,>>>.<<<"
c-rvs-doc.state-cf-qnty           at row 7 col 85.5  colon-aligned label "Наливы"           view-as text
/*r-doc.state-measure-tc-qnty   at row 8 col  8                  label "Факт(tc)"         view-as text*/
/*r-doc.measure-tc-qnty         at row 8 col 47                  label "Измер(tc)"        view-as text*/
/*r-doc.state-brutto-tc-qnty    at row 9 col  1                  label "Факт брутто(tc)"  view-as text*/
/*r-doc.brutto-tc-qnty          at row 9 col 40                  label "Измер брутто(tc)" view-as text*/
b-mark              at row 8  col 1
b-lkp               at row 8  col 34
{&browse-name}      at row 9  col 1
b-lkp-pump          at row 15 col 1
{&browse-name-pump} at row 16 col 1
space(0) skip(0)
with view-as dialog-box side-labels three-d scrollable keep-tab-order.

/* ***************  runtime attributes and uib settings  ************** */

/*assign                                                                              */
/*  frame {&frame-name}:scrollable                                = false             */
/*  {&browse-name}     :num-locked-columns in frame {&frame-name} = 5                 */
/*  {&browse-name-pump}:num-locked-columns in frame {&frame-name} = 2                 */
/*  b-add              :popup-menu in frame {&frame-name}         = menu m-add:handle */
/*  b-add              :menu-mouse                                = 1                 */
/*  b-meas             :popup-menu in frame {&frame-name}         = menu m-meas:handle*/
/*  b-meas             :menu-mouse                                = 1.                */


/* ************************  control triggers  ************************ */
{ gbl/mv-clmn.i
 &ext-col      = 35
 &frame-name   = "{&frame-name}"
 &browse-name  = "{&browse-name}"
 &table-name   = "ub.c-rvs-line"
 &start-column = 6
}

{ gbl/mv-clmn.i
 &ext-col      = 18
 &frame-name   = "{&frame-name}"
 &browse-name  = "{&browse-name-pump}"
 &table-name   = "ub.c-rvs-line-pump"
 &start-column = 3
}

{ gbl/f2.i {&browse-name} " " " " parparentproc }

{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-mark }

on end-error, stop of frame {&frame-name} do:
  apply "choose" to b-exit in frame {&frame-name}.
  return no-apply.
end.

ON WINDOW-CLOSE OF FRAME {&frame-name} 
DO:
  p-next-prev = "QUIT".
  APPLY "END-ERROR":U TO SELF.
END.



on choose of b-notes in frame {&frame-name}
do:
  assign notes = c-rvs-doc.ps.
  run gbl/notes.w ( input pardoc-mode, input-output notes ).
  if c-rvs-doc.ps <> notes then do:
    do on stop undo, return no-apply :
      find c-rvs-doc exclusive-lock where recid (c-rvs-doc) = parrvs-rec.
      assign c-rvs-doc.ps = notes.
    end.
  end.
end.

on choose of b-history in frame {&frame-name}
do:
  define variable v-list as character no-undo.

  if available c-rvs-doc then do:
    run str/rvscdocs.w ( input        parparentproc,
                     input        "":U,
                     input        "one":U,
                     input        c-rvs-doc.rvs-code,
                     input-output v-list                  ).
  end.
end.

on choose of b-exit in frame {&frame-name} /* Вых */
do:
    p-next-prev = "QUIT".

end.

on mouse-select-dblclick, return of c-rvs-doc.agnt in frame {&frame-name} /* Эксп */
do:
  run local-psn-chk in this-procedure ( input "agnt", input "ret-mouse" ).
  apply "entry" to c-rvs-doc.boss in frame {&frame-name}.
  return no-apply.
end.

on mouse-select-dblclick, return of c-rvs-doc.boss in frame {&frame-name} /* Нач */
do:
  run local-psn-chk in this-procedure ( input "boss", input "ret-mouse" ).
  apply "entry" to b-exit in frame {&frame-name}.
  return no-apply.
end.

on mouse-select-dblclick, return of c-rvs-doc.wrkr in frame {&frame-name} /* Исп */
do:
  run local-psn-chk in this-procedure ( input "wrkr", input "ret-mouse" ).
  apply "entry" to c-rvs-doc.agnt in frame {&frame-name}.
  return no-apply.
end.


ON CHOOSE OF B-next IN FRAME {&frame-name} /* >> */
DO:
     run reposition-c-rvs-doc in this-procedure
  (input 'next':U
  ) no-error .

  if error-status:error then return no-apply.

END.


ON CHOOSE OF B-prev IN FRAME {&frame-name} /* << */
DO:
   run reposition-c-rvs-doc in this-procedure
  (input 'prev':U
  ) no-error .
if error-status:error then return no-apply.
END.


on choose of r-agnt in frame {&frame-name} /* agent */
do:
  run local-psn-chk in this-procedure ( input "agnt", input "button" ).
  apply "entry" to c-rvs-doc.boss in frame {&frame-name}.
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
  apply "entry" to c-rvs-doc.agnt in frame {&frame-name}.
  return no-apply.
end.

on leave of c-rvs-doc.agnt in frame {&frame-name} /* agent */
do:
   run local-psn-chk in this-procedure ( input "agnt", input "leave" ).
end.

on leave of c-rvs-doc.boss in frame {&frame-name} /* boss */
do:
   run local-psn-chk in this-procedure ( input "boss", input "leave" ).
end.

on leave of c-rvs-doc.wrkr in frame {&frame-name} /* worker */
do:
   run local-psn-chk in this-procedure ( input "wrkr", input "leave" ).
end.




on choose of b-mark in frame {&frame-name} do:
  run local-mark in this-procedure.
  varlog = {&browse-name}:select-next-row ().
  apply "entry" to {&browse-name} in frame {&frame-name}.
end.




on choose of b-lkp-pump in frame {&frame-name} /* Просмотр ТРК */
do:
  run proc-lookup in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.



on choose of b-lkp in frame {&frame-name} /* Просм */
do:
  run proc-lkp in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.

/*on choose of menu-item m-add-1 in menu m-add do:*/
/*  run local-add in this-procedure no-error.     */
/*  if error-status :error then do:               */
/*    return no-apply.                            */
/*  end.                                          */
/*  run ui-on in this-procedure no-error.         */
/*  if error-status :error then do:               */
/*    return no-apply.                            */
/*  end.                                          */
/*  apply "entry" to b-add in frame {&frame-name}.*/
/*  return no-apply.                              */
/*end.                                            */




{ gbl/srt-clmn.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "ub.c-rvs-line"
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
&table-name    = "ub.c-rvs-line-pump"
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

on value-changed of {&browse-name} in frame {&frame-name} do:
  if available ub.c-rvs-line then do:
    run re-open-query-srt-clmn{&browse-name-pump} in this-procedure.
  end.
end.


/* ***************************  main block  *************************** */
/*if valid-handle(active-window) and frame {&frame-name}:parent eq ?*/
/*then frame {&frame-name}:parent = active-window.                  */


IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

p-next-prev = "":U.
    
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block
   on stop    undo main-block, leave main-block:
       
  p-next-prev = "QUIT".
   run mode-on in this-procedure
     no-error.
   if error-status :error then do:
     return error return-value .
   end.

   run ui-on in this-procedure.

end.
WAIT-FOR GO OF FRAME {&FRAME-NAME}.
run disable_ui in this-procedure.


/* **********************  internal procedures  *********************** */

procedure disable_ui :
  hide frame {&frame-name}.
end procedure.

procedure ui-on :
/* ----------------------------------------------------------------------------------------------------------------------------
  purpose:     включение пользовательского интерфейса в нужном режиме
--------------------------------------------------------------------------------------------------------------------------------- */
del-list = "".
find first ub.clients where ub.clients.obj-type = c-rvs-doc.obj-type and
                   ub.clients.obj-code = c-rvs-doc.obj-code no-lock.
assign frame {&frame-name}:title = "(" + substring (ub.clients.obj-name, 1, 35) +
       ") :   ДОКУМЕНТ СВЕРКИ - " + c-rvs-doc.status_ + " № " + c-rvs-doc.rvs-code + "      - " + pardoc-mode.
disable all with frame {&frame-name}.
enable b-exit b-help b-lkp b-lkp-pump B-prev B-next {&browse-name} {&browse-name-pump} b-history b-notes with frame {&frame-name}.
assign {&enabled-clmn}:read-only in browse {&browse-name} = yes
       {&enabled-clmn-pump}:read-only in browse {&browse-name-pump} = yes.


if available ub.clients then disp ub.clients.obj-name with frame {&frame-name}.
else disp ? @ ub.clients.obj-name with frame {&frame-name}.
disp c-rvs-doc.obj-code
     c-rvs-doc.obj-type
     c-rvs-doc.doc-date
     c-rvs-doc.state-measure-qnty
     c-rvs-doc.measure-qnty
     c-rvs-doc.system-qnty
     c-rvs-doc.state-measure-cli-qnty
    c-rvs-doc.measure-cli-qnty
    c-rvs-doc.system-cli-qnty
    c-rvs-doc.system-cli-avrg-qnty
     c-rvs-doc.state-mh-qnty
     c-rvs-doc.state-am-qnty
    c-rvs-doc.state-cf-qnty
    c-rvs-doc.out-code
/*     r-doc.state-measure-tc-qnty*/
/*     r-doc.measure-tc-qnty*/
/*     r-doc.state-brutto-tc-qnty*/
/*     r-doc.brutto-tc-qnty*/
     with frame {&frame-name}.

/*{ str/psn-chk.i wrkr on c-rvs-doc v-ref-rec }*/
/*{ str/psn-chk.i agnt on c-rvs-doc v-ref-rec }*/
/*{ str/psn-chk.i boss on c-rvs-doc v-ref-rec }*/

{&open-query-{&browse-name}-default}
if pardoc-mode = {&lookup} then do:
  if rvs-line-rec      <> ? then reposition {&browse-name}      to recid rvs-line-rec      no-error.
end.

{&open-query-{&browse-name-pump}-default}
if rvs-line-pump-rec <> ? then reposition {&browse-name-pump} to recid rvs-line-pump-rec no-error.

 VIEW FRAME {&frame-name}.
end procedure.



PROCEDURE local-mark:
  if not available ub.c-rvs-line then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i ub.c-rvs-line del-list }
  {&browse-name}:refresh() in frame {&frame-name} .
END PROCEDURE.





procedure mode-on :
/* -----------------------------------------------------------
  purpose:     чтение или создание шапки
------------------------------------------------------------- */
define variable v-shift-date like ub.shift-obj.shift-date no-undo.
define variable v-shift-num  like ub.shift-obj.shift-num  no-undo.
define variable v-shift-name as   character               no-undo.
define variable v-obj-date   as   date                    no-undo.


/*{ gbl/conf-rd.i                */
/*  "'ptoldfil':u"               */
/*  v-cntxt-host-code-obj        */
/*  v-cntxt-obj-type             */
/*  v-cntxt-obj-code             */
/*  "''"                         */
/*  "''"                         */
/*  "''"                         */
/*  no                           */
/*  ptoldfilvalue                */
/*  ptoldfiltype                 */
/*  no-error                     */
/*}                              */
/*if error-status :error then do:*/
/*end.                           */

    if pardoc-mode  =   {&lookup} then
    do:
        find c-rvs-doc no-lock where recid (c-rvs-doc) = parrvs-rec and c-rvs-doc.action = integer({&hn-delete}).
    end.
  
if not available c-rvs-doc then do:
  message "Неправильно выбран документ.".
  undo, return error.
end.
end procedure.

procedure local-psn-chk:
define input parameter parman    as character no-undo.
define input parameter paraction as character no-undo.
if parman = "agnt" and paraction = "ret-mouse" then do:
   { str/psn-chk.i agnt ret-mouse c-rvs-doc v-ref-rec }
end.
if parman = "agnt" and paraction = "button" then do:
   { str/psn-chk.i agnt button c-rvs-doc v-ref-rec }
end.
if parman = "agnt" and paraction = "leave" then do:
   { str/psn-chk.i agnt leave c-rvs-doc v-ref-rec }
end.
if parman = "boss" and paraction = "ret-mouse" then do:
   { str/psn-chk.i boss ret-mouse c-rvs-doc v-ref-rec }
end.
if parman = "boss" and paraction = "button" then do:
   { str/psn-chk.i boss button c-rvs-doc v-ref-rec }
end.
if parman = "boss" and paraction = "leave" then do:
   { str/psn-chk.i boss leave c-rvs-doc v-ref-rec }
end.
if parman = "wrkr" and paraction = "ret-mouse" then do:
   { str/psn-chk.i wrkr ret-mouse c-rvs-doc v-ref-rec }
end.
if parman = "wrkr" and paraction = "button" then do:
   { str/psn-chk.i wrkr button c-rvs-doc v-ref-rec }
end.
if parman = "wrkr" and paraction = "leave" then do:
   { str/psn-chk.i wrkr leave c-rvs-doc v-ref-rec }
end.
end procedure.

{ str/plgdsfnd.i parparentproc }






PROCEDURE reposition-c-rvs-doc :
define input parameter p-direction as character no-undo .
define variable  v-new-c-rvs-doc-recid as recid no-undo .

do
on error undo, return error
:
  /*
  Возможные значения v-direction
  first,last,prev,next
  */

  if valid-handle(p-call-prog)
  then do:
    run reposition-c-rvs-doc in p-call-prog
      (input  p-direction
      ,output v-new-c-rvs-doc-recid
      ).

    if v-new-c-rvs-doc-recid <> ?
    then do:
      define buffer buf_c-rvs-doc for ub.c-rvs-doc .
      find first buf_c-rvs-doc no-lock
        where recid(buf_c-rvs-doc) = v-new-c-rvs-doc-recid
        no-error .
      assign
      parrvs-rec = v-new-c-rvs-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов сверки." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.
END PROCEDURE.






procedure proc-lookup:
define buffer buf_goods for ub.goods.
if not available ub.c-rvs-line-pump then do:
  message "Неправильный выбор строки.".
  return error.
end.
assign rvs-line-rec      = (if available ub.c-rvs-line then recid(ub.c-rvs-line) else ?)
       rvs-line-pump-rec = recid(ub.c-rvs-line-pump).
  case c-rvs-doc.rvs-type
  :
    when {&rvs-before-doc}
    or when {&rvs-after-doc}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-on-doc_lookup':U
        {&cntxt-object}
        c-rvs-doc.host-code
        c-rvs-doc.obj-type
       c-rvs-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&rvs-shift}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-shift_lookup':U
        {&cntxt-object}
        c-rvs-doc.host-code
        c-rvs-doc.obj-type
       c-rvs-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&rvs-control}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-control_lookup':U
        {&cntxt-object}
        c-rvs-doc.host-code
        c-rvs-doc.obj-type
        c-rvs-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип сверки" skip
        "Тип сверки" c-rvs-doc.rvs-type skip
        "Код сверки" c-rvs-doc.rvs-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
if varlog <> yes then do: return error. end.
find first buf_goods where buf_goods.gds-code = ub.c-rvs-line-pump.gds-code no-lock.
run str/rvs-lnp-c.w
  (input  parparentproc
  ,input  recid(c-rvs-line-pump)
  ,input  {&lookup}
  ,input  " # "     + c-rvs-doc.rvs-code +
          " товар " + buf_goods.artic     + " " +
                      buf_goods.prod-type + " " +
                      string(buf_goods.prod-code) +
          " складское место " + string(ub.c-rvs-line-pump.pl-code) +
          " ТРК " + string(ub.c-rvs-line-pump.pump-code) +
          " пистолет " + string(ub.c-rvs-line-pump.nozzle-code)
  ) no-error.
if error-status :error then do:
   message "Ошибка при просмотре данных по ТРК." skip
           return-value skip
           error-status:get-message(1)
   view-as alert-box error.
   return error.
end.
find c-rvs-doc where recid(c-rvs-doc) = parrvs-rec.
end procedure.



procedure proc-lkp:
define buffer buf_goods for ub.goods.
if not available ub.c-rvs-line then do:
  message "Неправильный выбор строки.".
  return error.
end.
assign rvs-line-rec = recid(ub.c-rvs-line)
       rvs-line-pump-rec = (if available ub.c-rvs-line-pump then recid(ub.c-rvs-line-pump) else ?).
  case c-rvs-doc.rvs-type
  :
    when {&rvs-before-doc}
    or when {&rvs-after-doc}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-on-doc_lookup':U
        {&cntxt-object}
        c-rvs-doc.host-code
        c-rvs-doc.obj-type
        c-rvs-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&rvs-shift}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-shift_lookup':U
        {&cntxt-object}
        c-rvs-doc.host-code
        c-rvs-doc.obj-type
        c-rvs-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&rvs-control}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_rvs-control_lookup':U
        {&cntxt-object}
        c-rvs-doc.host-code
       c-rvs-doc.obj-type
       c-rvs-doc.obj-code
        0
        0
        0
        true
        varlog
      }
    end.
    when {&test-asi}
    then do:
      varlog = yes .
    end .
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип сверки" skip
        "Тип сверки" c-rvs-doc.rvs-type skip
        "Код сверки" c-rvs-doc.rvs-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
if varlog <> yes then do: return error. end.
find first buf_goods where buf_goods.gds-code = ub.c-rvs-line.gds-code no-lock.

if not error-status :error 
   and is-gas(buf_goods.gds-code) then do:
   
    run str/rvs-lin-mask-c.w
      (input  parparentproc
      ,input  recid(c-rvs-line)
      ,input  {&lookup}
      ,input  " # "     + c-rvs-doc.rvs-code +
              " товар " + buf_goods.artic     + " " +
                          buf_goods.prod-type + " " +
                          string(buf_goods.prod-code) +
              " складское место " + string(ub.c-rvs-line.pl-code)
      ) no-error.
   
end.

else do:

run str/rvs-lin-c.w
  (input  parparentproc
  ,input  recid(c-rvs-line)
  ,input  {&lookup}
  ,input  " # "     + c-rvs-doc.rvs-code +
          " товар " + buf_goods.artic     + " " +
                      buf_goods.prod-type + " " +
                      string(buf_goods.prod-code) +
          " складское место " + string(ub.c-rvs-line.pl-code)
  ) no-error.
  
end.
  
if error-status :error then do:
   message "Ошибка при просмотре строки сверки." skip
           return-value skip
           error-status:get-message(1)
   view-as alert-box error.
   return error.
end.
find c-rvs-doc where recid(c-rvs-doc) = parrvs-rec.
run ui-on in this-procedure .
end procedure.

