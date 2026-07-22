/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка документа проверки корректности работы АСИ в резервуаре (заведение, редактирование, просмотр)



Create: SlivenkoSA
01/04/24

*/

define input        parameter parparentproc as handle    no-undo .
define input        parameter pardoc-mode   as character no-undo .
define input        parameter par_test-asi-type   as character no-undo .
define input        parameter parall-place  as logical   no-undo .
define input-output parameter par_test-asi-rec    as recid     no-undo .

define variable varlog          as logical   no-undo.

&scop frame-name       d-rvs
&scop browse-name      br-line

/* ***************************  definitions  ************************** */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Обработка документа проверки корректности работы АСИ в резервуаре (заведение, редактирование, просмотр)":U.

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
{ gbl/cur-time.i }
{ str/pokmi-dyn.i }
{ str/calibrationbelt.i }

define stream outstream.

define buffer r-doc             for ub.rvs-doc.
define buffer cur_shift-obj     for ub.shift-obj.
define buffer prev_shift-obj    for ub.shift-obj.
define buffer buf_rvs-line-attr for ub.rvs-line-attr.
define buffer buf_doc-attr      for ub.doc-attr.

define variable v-ref-rec         as recid     no-undo .
define variable ii                as integer   no-undo.
define variable bcol              as handle    extent 37 no-undo.
define variable isMeasurement     as logical   no-undo init no.

/* ********************  preprocessor definitions  ******************** */
&scop open-query-{&browse-name} open query {&browse-name} ~
   for each  ub.rvs-line no-lock where ~
             ub.rvs-line.rvs-code =    r-doc.rvs-code ~
     , first ub.goods        no-lock where ~
             ub.goods.gds-code        = ub.rvs-line.gds-code ~
     , first ub.place                where ~
             ub.place.obj-type        = ub.rvs-line.obj-type and ~
             ub.place.obj-code        = ub.rvs-line.obj-code and ~
             ub.place.pl-code         = ub.rvs-line.pl-code  and ~
             ub.place.status_ <>      {&deleted-status}
             

&scop open-query-{&browse-name}-default {&open-query-{&browse-name}}.


&scop label-clmn_1-br-line  '*'
&scop sort-clmn_1-br-line   get-mark (buffer ub.rvs-line)
&scop label-clmn_2-br-line  'Номер резервуара'
&scop sort-clmn_2-br-line   place.loc1
&scop label-clmn_3-br-line  'Название'
&scop sort-clmn_3-br-line   ub.goods.gds-name
&scop label-clmn_4-br-line  'Скл.место'
&scop sort-clmn_4-br-line   ub.rvs-line.pl-code
&scop label-clmn_5-br-line  'Бар-код'
&scop sort-clmn_5-br-line   ub.goods.gds-code


/* ***********************  control definitions  ********************** */
define variable rvs-line-rec      as recid     no-undo.
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
define buffer calc_r-line  for ub.rvs-line.

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


define button b-chg
  label "Изменить":U
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
  
define button b-commission
  label "Состав комиссии":U
  size 20 by 1.

define menu m-meas
  menu-item m-meas-1 label "Всех резервуаров в документе" accelerator "alt-1"
  menu-item m-meas-3 label "Текущего резервуара"          accelerator "alt-3".


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
define browse {&browse-name} query {&browse-name} no-lock display
  {&sort-clmn_1-br-line}  column-label {&label-clmn_1-br-line}  format "x(1)"
  {&sort-clmn_2-br-line}  column-label {&label-clmn_2-br-line}
  {&sort-clmn_3-br-line}  column-label {&label-clmn_3-br-line}  format "x(256)" width 29
  {&sort-clmn_4-br-line}  column-label {&label-clmn_4-br-line}  FORMAT "9999999999":U width 12
  {&sort-clmn_5-br-line}  column-label {&label-clmn_5-br-line}  FORMAT "9999999999":U width 12
with size 75.25 by 9 separators.


/* ************************  frame definitions  *********************** */
define frame {&frame-name}
  b-exit              at row 1  col 1
  b-notes             at row 1  col 11
  b-history           at row 1  col 39
  b-help              at row 1  col 49
  "Объект:"                         at row 2 col 10
  r-doc.obj-code                    at row 2 col 16   colon-aligned no-label       view-as text size 7    by 1
  r-doc.obj-type                    at row 2 col 23   colon-aligned no-label       view-as text size 7.13 by 1
  ub.clients.obj-name               at row 2 col 33   colon-aligned no-label       view-as text size 40 by 1 fgcolor 4
  r-doc.doc-date                    at row 3 col 40   colon-aligned view-as text
  r-doc.wrkr                        at row 5 col 4.5  colon-aligned format "999999999"  view-as fill-in size 10 by 1
  wrkr-name                         at row 5 col 15   colon-aligned no-label fgcolor 4
  r-wrkr                            at row 5 col 28   no-label
  r-doc.agnt                        at row 6 col 4.5 colon-aligned format "999999999"  view-as fill-in size 10 by 1
  agnt-name                         at row 6 col 15  colon-aligned no-label fgcolor 4
  r-agnt                            at row 6 col 28  no-label
  r-doc.boss                    at row 7 col 4.5   colon-aligned format "999999999"       view-as fill-in size 10 by 1
  boss-name                     at row 7 col 15    colon-aligned no-label                fgcolor 4
  r-boss                        at row 7 col 28    no-label
  b-mark              at row 8  col 1
  b-add               at row 8  col 4
  b-del               at row 8  col 14
  b-meas              at row 8  col 24
  b-lkp               at row 8  col 34
  b-chg               at row 8  col 44
  b-commission        at row 4  col 1
  {&browse-name}      at row 9  col 1
  space(0) skip(0)
  with view-as dialog-box side-labels three-d scrollable keep-tab-order.

/* ***************  runtime attributes and uib settings  ************** */

assign
  frame {&frame-name}:scrollable                                = false
  b-meas             :popup-menu in frame {&frame-name}         = menu m-meas:handle
  b-meas             :menu-mouse                                = 1.


/* ************************  control triggers  ************************ */

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
        find r-doc exclusive-lock where recid (r-doc) = par_test-asi-rec.
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
          par_test-asi-rec = ?.
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


on choose of b-mark in frame {&frame-name} 
  do:
    run local-mark in this-procedure.
    varlog = {&browse-name}:select-next-row ().
    apply "entry" to {&browse-name} in frame {&frame-name}.
  end.

on choose of b-add in frame {&frame-name}
do :
  define buffer buf_rvs-line for ub.rvs-line .
  define buffer buf_place    for ub.place .
  define buffer buf_pl-gds   for ub.pl-gds .
  
  define variable place-list as character no-undo .
  
  run ref/pl-list.w (
   input parparentproc
  ,input "b-sel,b-mark"
  ,input r-doc.obj-type
  ,input r-doc.obj-code
  ,input {&g___object} + {&delim-par} + "only-np"
  ,input-output place-list).
  
  if place-list = "cancel"
  then do :
    return no-apply .
  end .
  
  do ii = 1 to num-entries(place-list) :
    find first buf_place no-lock where recid(buf_place) = integer(entry(ii, place-list)) .
    find first buf_pl-gds no-lock where
      buf_pl-gds.obj-type = buf_place.obj-type and
      buf_pl-gds.obj-code = buf_place.obj-code and
      buf_pl-gds.pl-code  = buf_place.pl-code  no-error.
    if not available buf_pl-gds then 
    do:
      message substitute("Ошибка при выборке складского места &1. К нему не привязан товар.", buf_place.loc1)
        view-as alert-box .
      next.
    end.
    find first buf_rvs-line no-lock where
      buf_rvs-line.rvs-code = r-doc.rvs-code and
      buf_rvs-line.gds-code = buf_pl-gds.gds-code       and
      buf_rvs-line.pl-code  = buf_pl-gds.pl-code       no-error.
    if available buf_rvs-line then 
    do:
      message "Складское место " buf_place.loc1
        " уже имеется в данном документе проверки корректности работы АСИ в резервуаре." skip
        view-as alert-box.
      next.
    end.
    
    tr:
    do transaction :
      { str/crrvslin.i
          r-doc.obj-type
          r-doc.obj-code
          r-doc.rvs-code
          r-doc.rvs-type
          buf_pl-gds.pl-code
          buf_pl-gds.gds-code
          ?
          "if available cur_shift-obj then cur_shift-obj.shift-date else ?"
          "if available cur_shift-obj then cur_shift-obj.shift-num else ?"
          no-error
      }
      if error-status :error then 
      do:
        message "Ошибка при создании линии. "
          return-value
          view-as alert-box error.
        undo tr, return no-apply.
      end.
      if return-value begins "GAS!"
      or return-value begins "NMS!"
      or return-value begins "VIR!"
      then do :
        message substring(return-value, 5) view-as alert-box .
        undo tr, next .
      end .
    end. /* transaction */
  end .
  
  run ui-on in this-procedure no-error.
  if error-status :error then 
  do:
    return no-apply.
  end.
  apply "entry" to b-add in frame {&frame-name}.
  return no-apply.
                 
end .

on choose of b-commission in frame {&frame-name} /* Состав комиссии */
do:

  do on stop undo, return no-apply :
    run str/test-asi-commission.w (input r-doc.rvs-code,
                                   input pardoc-mode)
                                   .
  end. /* on stop */
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

/* Сверка по всем резервуарам */
on choose of menu-item m-meas-1 in menu m-meas 
do:
  run proc_m-meas-1 in this-procedure no-error.
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

{ gbl/srt-clmn.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "ub.rvs-line"
&ext-col = 5
&start-column  = 1
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
&open-query           = "{&open-query-{&browse-name}} by ~{&sort-clmn_~{&clmn_num~}~} ."
&open-query-otherwise = "{&open-query-{&browse-name}-default}"
&re-move-clmn         = "yes"
&mv-brw-default       = "yes"}


on value-changed of {&browse-name} in frame {&frame-name} 
do:
  
end.

ON ROW-DISPLAY OF {&browse-name} IN FRAME {&frame-name} 
  DO:
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
   
  do ii = 1 to 5:
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
  del-list = "".
  find first ub.clients where ub.clients.obj-type = r-doc.obj-type and
    ub.clients.obj-code = r-doc.obj-code no-lock.
  assign 
    frame {&frame-name}:title = "(" + substring (ub.clients.obj-name, 1, 35) +
       ") :   ДОКУМЕНТ проверки корректности работы АСИ в резервуаре - " + r-doc.status_ + " № " + r-doc.rvs-code + "      - " + pardoc-mode.
  disable all with frame {&frame-name}.
  enable b-exit b-help b-lkp {&browse-name} b-history b-notes b-commission with frame {&frame-name}.
  if r-doc.status_ = {&g___new} and
    (pardoc-mode = {&add-def} or
    pardoc-mode = {&update}        ) then 
  do:
    enable r-doc.wrkr
      r-doc.agnt
      r-doc.boss
      r-wrkr r-agnt r-boss
      b-mark
    with frame {&frame-name}.
    if not isMeasurement then
        enable
          b-add b-del b-chg  b-meas 
        with frame {&frame-name}.
  end.
  

  if available ub.clients then disp ub.clients.obj-name with frame {&frame-name}.
  else disp ? @ ub.clients.obj-name with frame {&frame-name}.
  disp r-doc.obj-code
    r-doc.obj-type
    r-doc.doc-date
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
    message "Удалить строку документа проверки корректности работы АСИ в резервуаре ?   Вы уверены ?"
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
/*    { str/rvsclchd.i "recid( r-doc )"              */
/*                yes                      no-error }*/
  end.

end procedure.


procedure mode-on :
  /* -----------------------------------------------------------
    purpose:     чтение или создание шапки
  ------------------------------------------------------------- */
  define variable v-shift-date like ub.shift-obj.shift-date no-undo.
  define variable v-shift-num  like ub.shift-obj.shift-num no-undo.
  define variable v-shift-name as character no-undo.
  define variable v-obj-date   as date      no-undo.
  define variable c-value      as character no-undo .
  define variable c-type       as character no-undo .

  define buffer bf_place  for ub.place.
  define buffer bf_r-line for ub.rvs-line.
  define buffer buf_pl-gds   for ub.pl-gds .
  
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
  
  if pardoc-mode = {&add-def} or
    pardoc-mode = {&update} then 
  do:
    find first cur_shift-obj
      where cur_shift-obj.obj-type = v-cntxt-obj-type
      and cur_shift-obj.obj-code = v-cntxt-obj-code
      and cur_shift-obj.status_  = {&sht-current}
      use-index pi no-lock no-error .
  
  end .

  case pardoc-mode :
    when {&add-def} then 
      do:
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
            r-doc.rvs-type  = {&test-asi}
            r-doc.out-code  = ?
            r-doc.creid     = v-cntxt-userid
            r-doc.ps        = "@"
            r-doc.doc-date  = v-obj-date
            .
          if parall-place then
            assign r-doc.is-full = yes.
          
          create buf_doc-attr.
          assign
            buf_doc-attr.doc-code = r-doc.rvs-code
            buf_doc-attr.attr-code = "test-asi-type"
            buf_doc-attr.attr-value = par_test-asi-type
          .  

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
          if parall-place 
          then do:
            run waitfram-show in this-procedure ( input "Создаем строки по резервуарам" ).
            { str/place-sh.i
              r-doc.obj-type
              r-doc.obj-code
              r-doc.rvs-code
              r-doc.rvs-type
              ?
              "if available cur_shift-obj then cur_shift-obj.shift-date else ?"
              "if available cur_shift-obj then cur_shift-obj.shift-num else ?"
              no
              no-error
          }
            if error-status :error then 
            do:
              message "Ошибка при создании линий документа проверки корректности работы АСИ в резервуаре." skip
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
            
            for each tt-meas :
              find first buf_pl-gds no-lock where buf_pl-gds.obj-type = tt-meas.obj-type
                                              and buf_pl-gds.obj-code = tt-meas.obj-code
                                              and buf_pl-gds.pl-code  = tt-meas.pl-code
                                              no-error.
              if not available buf_pl-gds
              then do:
                delete tt-meas .
              end.
              else do :
                &scop proc-name gds-attr-value
                {&run_proc_attr-lib}
                  (input  buf_pl-gds.gds-code
                  ,input  {&attr-fuel-type}
                  ,output c-value
                  ,output c-type)
                no-error.
                if c-value = 'lgas':U
                or c-value = 'metan':U
                or c-value = 'propan':U
                then do :
                  delete tt-meas .
                end .
              end .
            end .
            
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
              run waitfram-hide in this-procedure.
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
              if par_test-asi-type = "test-asi_dens-pump"
              then do :
                for each calc_r-line no-lock where calc_r-line.rvs-code = r-doc.rvs-code :
                  run pomi-calc .
                end .
              end .
            end.
          end.
          assign 
            par_test-asi-rec = recid (r-doc).
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
          find r-doc where recid (r-doc) = par_test-asi-rec no-error.
          if available r-doc then 
          do:
            if r-doc.status_ = {&fact} then 
            do:
              find r-doc where recid (r-doc) = par_test-asi-rec no-lock.
              message "Документ уже закрыт. Изменение невозможно.".
              undo tr, return error.
            end.
            find first buf_doc-attr no-lock where buf_doc-attr.doc-code = r-doc.rvs-code
                                              and buf_doc-attr.attr-code = "test-asi-type"
                                              no-error .
            if not available buf_doc-attr
            or (available buf_doc-attr and not (buf_doc-attr.attr-value > ""))
            then do :
              find r-doc where recid (r-doc) = par_test-asi-rec no-lock.
              message "Неизвестный тип проверки корректности работы АСИ. Изменение невозможно.".
              undo tr, return error.
            end .
            assign par_test-asi-type = buf_doc-attr.attr-value .
            find r-doc where recid (r-doc) = par_test-asi-rec exclusive.
          end.
        end. /* transaction */
      end.
    when {&lookup} then 
      do:
        find r-doc no-lock where recid (r-doc) = par_test-asi-rec.
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
  .
  
  find first buf_goods where buf_goods.gds-code = ub.rvs-line.gds-code no-lock.
  
  run str/test-asi-lin.w
          (input  parparentproc
          ,input  recid(ub.rvs-line)
          ,input  {&update}
          ,input  " # "     + r-doc.rvs-code +
          " товар " + buf_goods.artic     + " " +
          buf_goods.prod-type + " " +
          string(buf_goods.prod-code) +
          " складское место " + string(ub.rvs-line.pl-code)
          ) no-error.
  if error-status :error then 
  do:
    message "Ошибка при редактировании строки проверки корректности работы АСИ в резервуаре." skip
      return-value skip
      error-status:get-message(1)
      view-as alert-box error.
    return error.
  end.

  find r-doc where recid(r-doc) = par_test-asi-rec.
end procedure.

procedure proc_m-meas-3 :
  define buffer meas-place            for ub.place.
  define buffer olddens_rvs-line-attr for ub.rvs-line-attr .
  define variable VErrorFlag as logical no-undo.
  if available ub.rvs-line then 
  do:
    assign 
      rvs-line-rec      = recid(ub.rvs-line)
    .
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
      tt-meas.pl-code  = ub.rvs-line.pl-code
      tt-meas.loc1     = meas-place.loc1
    .
    run waitfram-show in this-procedure ( input ("Делаем сверку по резервуару " + meas-place.loc1) ).
    disable b-add b-chg b-del b-meas b-commission with frame {&frame-name}.
    isMeasurement = yes.
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
      
      if par_test-asi-type = "test-asi_dens-pump"
      then do :
        for first calc_r-line no-lock where rowid(calc_r-line) = rowid(ub.rvs-line) :
          run pomi-calc .
        end .
      end .
      
/*      run waitfram-show in this-procedure ( input "Пересчитывем шапку" ).*/
/*      { str/rvsclcln.i "recid( ub.rvs-line )" no-error }                 */
/*      if error-status :error then                                        */
/*      do:                                                                */
/*        message "Ошибка при пересчете линии." skip                       */
/*          return-value                                                   */
/*          view-as alert-box error.                                       */
/*        undo tr,  retry tr.                                              */
/*      end.                                                               */
/*      { str/rvsclchd.i "recid( r-doc )"                                  */
/*                   no                      no-error }                    */
/*      if error-status :error then                                        */
/*      do:                                                                */
/*        message "Ошибка при пересчете документа." skip                   */
/*          return-value                                                   */
/*          view-as alert-box error.                                       */
/*        undo tr,  retry tr.                                              */
/*      end.                                                               */
    end. /* transaction */
    run waitfram-hide in this-procedure.
    isMeasurement = no.
    run ui-on in this-procedure.
    if VErrorFlag 
      then 
      return error.
  end.
  else message "Неверно выбрана строка" view-as alert-box error.
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
  .
  find first buf_goods where buf_goods.gds-code = ub.rvs-line.gds-code no-lock.
  
  run str/test-asi-lin.w
        (input  parparentproc
        ,input  recid(ub.rvs-line)
        ,input  {&lookup}
        ,input  " # "     + r-doc.rvs-code +
        " товар " + buf_goods.artic     + " " +
        buf_goods.prod-type + " " +
        string(buf_goods.prod-code) +
        " складское место " + string(ub.rvs-line.pl-code)
        ) no-error.
  
  if error-status :error then 
  do:
    message "Ошибка при просмотре строки проверки корректности работы АСИ в резервуаре." skip
      return-value skip
      error-status:get-message(1)
      view-as alert-box error.
    return error.
  end.
  find r-doc where recid(r-doc) = par_test-asi-rec.
  run ui-on in this-procedure .
end procedure.

procedure proc_m-meas-1:
  define buffer meas-place for ub.place.
  define buffer bf_r-line  for ub.rvs-line.
  
  define variable VErrorFlag as logical no-undo.
  
  assign 
    rvs-line-rec      = (if available ub.rvs-line      then recid(ub.rvs-line)      else ?)
  .
  for each tt-meas:
    delete tt-meas.
  end.
  if can-find( first bf_r-line where bf_r-line.rvs-code = r-doc.rvs-code ) then 
  do:
    isMeasurement = yes.
    disable b-add b-chg b-del b-meas b-commission with frame {&frame-name}.
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
      
      for each bf_r-line no-lock where
               bf_r-line.rvs-code = r-doc.rvs-code,
         first meas-place no-lock where 
               meas-place.obj-type = bf_r-line.obj-type and
               meas-place.obj-code = bf_r-line.obj-code and
               meas-place.pl-code  = bf_r-line.pl-code
        :    
        create tt-meas.
        assign 
          tt-meas.obj-type = bf_r-line.obj-type
          tt-meas.obj-code = bf_r-line.obj-code
          tt-meas.pl-code  = bf_r-line.pl-code
          tt-meas.loc1     = meas-place.loc1    
        .
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
        find first ub.rvs-line where recid(ub.rvs-line) = recid(bf_r-line) exclusive-lock.
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
        
        if par_test-asi-type = "test-asi_dens-pump"
        then do :
          for first calc_r-line no-lock where rowid(calc_r-line) = rowid(ub.rvs-line) :
            run pomi-calc .
          end .
        end .
        
        find first tt-meas exclusive-lock no-error.
        delete tt-meas.
      end.

/*      run waitfram-show in this-procedure ( input "Пересчитывем шапку" ).*/
/*      { str/rvsclchd.i "recid( r-doc )"                                  */
/*                   no                       no-error }                   */
/*      if error-status :error then                                        */
/*      do:                                                                */
/*        message "Ошибка при пересчете документа." skip                   */
/*          return-value                                                   */
/*          view-as alert-box error.                                       */
/*        undo tr, retry tr.                                               */
/*      end.                                                               */
    end. /* transaction */
    isMeasurement = no.
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

procedure pomi-calc:

define variable v-proc as character no-undo.
define variable v-pokmi-dll-version as character no-undo .

define variable v-code            as character no-undo.
define variable ii                as integer   no-undo.

define variable place-ratio-error as decimal no-undo.
define variable dens-prov         as decimal no-undo format "9.9999999999":U.

define variable CalibTable        as character no-undo initial "".
define variable CalibBelt         as character no-undo initial "".
define variable ToolType          as integer no-undo.
define variable LevelToolType          as integer no-undo.
define variable A_LevelMeasurementTool  as decimal no-undo.
define variable DeltaAbs_H              as decimal no-undo.
define variable DeltaAbs_H_Water        as decimal no-undo.
define variable DeltaAbs_R              as decimal no-undo.
define variable DeltaAbs_Tv             as decimal no-undo.
define variable DeltaAbs_Tr             as decimal no-undo.
define variable DeltaOtn_N              as decimal no-undo init 0.05 .
define variable DeltaOtn_K              as decimal no-undo.
define variable A_Reservoir             as decimal no-undo init 0.0000125 .
define variable DeadZone_Reservoir      as decimal no-undo.
define variable DeltaOtn_H              as decimal no-undo.
define variable DeltaOtn_H_Water        as decimal no-undo.
define variable DeltaOtn_R              as decimal no-undo.
define variable ToolAutomationLevel_H   as integer no-undo.
define variable ToolAutomationLevel_H_Water as integer no-undo.
define variable ToolAutomationLevel_R   as integer no-undo.
define variable ToolAutomationLevel_Tv  as integer no-undo.
define variable ToolAutomationLevel_Tr  as integer no-undo.
define variable DeltaAbs_H_CalcType     as integer no-undo.
define variable DeltaAbs_H_Water_CalcType   as integer no-undo.
define variable temp-for-pomi           as integer no-undo.
define variable error-string            as character no-undo.
define variable v-is-meas               as logical no-undo.
define variable v-mm-density            as decimal no-undo.
define variable place-ponton            as logical no-undo .
define variable place-ponton-mass       as decimal no-undo .
define variable place-ponton-height     as decimal no-undo .

define variable DeltaV1                 as decimal no-undo .
define variable DeltaV2                 as decimal no-undo .
define variable WaterDeltaV1            as decimal no-undo .
define variable WaterDeltaV2            as decimal no-undo .

define variable Tv                      as decimal no-undo .
define variable Tr                      as decimal no-undo .
define variable R                       as decimal no-undo .

define variable v-POkMI-result   as character no-undo.
define variable v-value          as character no-undo.
define variable v-ok             as logical no-undo .

define variable place-diameter    as decimal no-undo .
define variable pl-dens-sr-izm    as integer no-undo .
define variable pl-level-sr-izm   as integer no-undo .
define variable pl-temp-sr-izm    as integer no-undo .
define variable place-type        as integer no-undo.
define variable place-SI          as integer no-undo.

define variable vAutomationDegree as integer no-undo extent 3 init [2,1,3].

define buffer buf_sr-izmerenia for sr-izmerenia .
define buffer dens_sr-izmerenia for sr-izmerenia .
define buffer temp_sr-izmerenia for sr-izmerenia .
define buffer level_sr-izmerenia for sr-izmerenia .
define buffer temp-dens_sr-izmerenia for sr-izmerenia .
define buffer buf_place     for ub.place.

define buffer water1_pl-level  for ub.pl-level .
define buffer water2_pl-level  for ub.pl-level .
define buffer total1_pl-level  for ub.pl-level .
define buffer total2_pl-level  for ub.pl-level .
define buffer buf_pl-level-attr for ub.pl-level-attr .

define buffer bf_goods for ub.goods .
define buffer bf_place for ub.place .

define variable vErr as character no-undo .
define variable vWrn as character no-undo .
define variable vDllVersion as character no-undo .

define variable V_total      as decimal no-undo .
define variable V_water      as decimal no-undo .
define variable DeltaV       as decimal no-undo .
define variable Vcy          as decimal no-undo .
define variable Rcy          as decimal no-undo .
define variable V_product    as decimal no-undo .
define variable V            as decimal no-undo .
define variable Rv           as decimal no-undo .
define variable M            as decimal no-undo .
define variable CTL_base_alt as decimal no-undo .
define variable CPL_base_alt as decimal no-undo .
define variable CTPL_base_alt as decimal no-undo .
define variable Fp_base_alt  as decimal no-undo .
define variable CTL_obs_base as decimal no-undo .
define variable CPL_obs_base as decimal no-undo .
define variable CTPL_obs_base as decimal no-undo .
define variable Fp_obs_base  as decimal no-undo .
define variable DeltaOtn_Vcy as decimal no-undo .
define variable DeltaOtn_Vm  as decimal no-undo .
define variable DeltaOtn_M   as decimal no-undo .
define variable VolumetricExpansion as decimal no-undo .

  _trpomi :
    do on error undo, return :
    
    if calc_r-line.density = ? or calc_r-line.density = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите плотность измер.для ПОкМИ"
      view-as alert-box error.
      undo _trpomi, return "need-data" .
    end.
    if calc_r-line.level-total = ? or calc_r-line.level-total = 0 then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите факт. общий уровень"
      view-as alert-box error.
      undo _trpomi, return "need-data" .
    end.
/*    if calc_r-line.level-water = ? then do :     */
/*      message                                    */
/*        "Заполнены не все поля, необходимые" skip*/
/*        "для работы библиотеки ПОкМИ"        skip*/
/*        "Введите факт. уровень воды"             */
/*      view-as alert-box error.                   */
/*      undo _trpomi, return "need-data" .         */
/*    end.                                         */
    if calc_r-line.temperature = ?
    then do :
      message
        "Заполнены не все поля, необходимые" skip
        "для работы библиотеки ПОкМИ"        skip
        "Введите температуру"
      view-as alert-box error.
      undo _trpomi, return "need-data" .
    end.
    
    /*данные по резервуару для ПОкМИ*/
    do ii = 1 to num-entries({&list-place-attr},','):
      v-code = entry(ii,{&list-place-attr}) .
      run placelib_get-attr  ( input v-code
                              ,input calc_r-line.obj-code
                              ,input calc_r-line.obj-type
                              ,input calc_r-line.pl-code
                              ,output v-value
                              ,output v-ok      ) no-error.
      case v-code :
        when {&place-type} then do :
          if v-ok then place-type = integer(v-value) .
        end.
        when {&place-SI} then do :
          if v-ok then place-si = integer(v-value) .
        end.
        when {&place-diameter} then do :
          if v-ok then place-diameter = decimal(v-value) .
        end.
/*        when {&place-ratio-error} then do :                  */
/*          if v-ok then place-ratio-error = decimal(v-value) .*/
/*        end.                                                 */
        when {&place-dens-prov} then do :
          if v-ok then dens-prov = decimal(v-value) .
        end.
/*        when {&place-temp-coef} then do :              */
/*          if v-ok then A_Reservoir = decimal(v-value) .*/
/*        end.                                           */
        when {&place-dead-high} then do :
          if v-ok then DeadZone_Reservoir = decimal(v-value) .
        end.
        when {&place-ponton} then do :
          if v-ok then place-ponton = logical(v-value) .
        end.
        when {&place-ponton-mass} then do :
          if v-ok then place-ponton-mass = decimal(v-value) .
        end.
        when {&place-ponton-height} then do :
          if v-ok then place-ponton-height = decimal(v-value) .
        end.
      end case.
    end.
    /*..........................................*/

    /*градуировочная таблица резервуара для ПОкМИ*/
/*    for last pl-level no-lock                                                                                                */
/*        where pl-level.pl-code  = calc_r-line.pl-code                                                                        */
/*          and pl-level.obj-code = calc_r-line.obj-code                                                                       */
/*          and pl-level.obj-type = calc_r-line.obj-type by pl-level.pl-level                                                  */
/*          :                                                                                                                  */
/*          CalibTable = Substitute("&1=&2","1",(pl-level.pl-qnty / (pl-level.pl-level))) .                                    */
/*    end.                                                                                                                     */
/*    for each  pl-level no-lock                                                                                               */
/*        where pl-level.pl-code  = calc_r-line.pl-code                                                                        */
/*          and pl-level.obj-code = calc_r-line.obj-code                                                                       */
/*          and pl-level.obj-type = calc_r-line.obj-type by pl-level.pl-level                                                  */
/*          :                                                                                                                  */
/*          if CalibTable = "" then CalibTable = Substitute("&1=&2",(pl-level.pl-level ),pl-level.pl-qnty ) .                  */
/*                            else CalibTable = CalibTable + ";" + Substitute("&1=&2",(pl-level.pl-level ),pl-level.pl-qnty ) .*/
/*    end.                                                                                                                     */
/*                                                                                                                             */
/*    CalibTable = CalibTable + ";" + fill({&space-char},(2048 - length(CalibTable))).                                         */
    
    if calc_r-line.level-water > 0
    then do :
      find last water1_pl-level no-lock where water1_pl-level.pl-code  = calc_r-line.pl-code
                                          and water1_pl-level.obj-code = calc_r-line.obj-code
                                          and water1_pl-level.obj-type = calc_r-line.obj-type
                                          and water1_pl-level.pl-level <= calc_r-line.level-water
                                          no-error .
      if available water1_pl-level
      then do :
        WaterDeltaV1 = ? .
        for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water1_pl-level.pl-code
                                              and buf_pl-level-attr.obj-code = water1_pl-level.obj-code
                                              and buf_pl-level-attr.obj-type = water1_pl-level.obj-type
                                              and buf_pl-level-attr.pl-level = water1_pl-level.pl-level
                                              and buf_pl-level-attr.attr-code = "deltaV"
                                              :      
          WaterDeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
        end .
      end .
      if available water1_pl-level 
      and water1_pl-level.pl-level <> calc_r-line.level-water
      then do :
        find first water2_pl-level no-lock where water2_pl-level.pl-code  = calc_r-line.pl-code
                                             and water2_pl-level.obj-code = calc_r-line.obj-code
                                             and water2_pl-level.obj-type = calc_r-line.obj-type
                                             and water2_pl-level.pl-level >= calc_r-line.level-water
                                             no-error .
        if available water2_pl-level
        then do :
          WaterDeltaV2 = ? .
          for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = water2_pl-level.pl-code
                                                and buf_pl-level-attr.obj-code = water2_pl-level.obj-code
                                                and buf_pl-level-attr.obj-type = water2_pl-level.obj-type
                                                and buf_pl-level-attr.pl-level = water2_pl-level.pl-level
                                                and buf_pl-level-attr.attr-code = "deltaV"
                                                :      
            WaterDeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
          end .
        end .
      end .
    end .  
    find last total1_pl-level no-lock where total1_pl-level.pl-code  = calc_r-line.pl-code
                                        and total1_pl-level.obj-code = calc_r-line.obj-code
                                        and total1_pl-level.obj-type = calc_r-line.obj-type
                                        and total1_pl-level.pl-level <= calc_r-line.level-total
                                        no-error . 
    if not available total1_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = calc_r-line.gds-code no-error .
      find first bf_place no-lock where bf_place.pl-code = calc_r-line.pl-code no-error .
      message 
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return "need-data" .
    end .
    
    DeltaOtn_K = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "tarir-delta"
                                          :      
      DeltaOtn_K = decimal(buf_pl-level-attr.attr-value) . 
    end .   
    if DeltaOtn_K = ? then DeltaOtn_K = 0.25 .  
    
    DeltaV1 = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total1_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total1_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total1_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total1_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :      
      DeltaV1 = decimal(buf_pl-level-attr.attr-value) no-error . 
    end . 
                                
    find first total2_pl-level no-lock where total2_pl-level.pl-code  = calc_r-line.pl-code
                                        and total2_pl-level.obj-code = calc_r-line.obj-code
                                        and total2_pl-level.obj-type = calc_r-line.obj-type
                                        and total2_pl-level.pl-level > calc_r-line.level-total
                                        no-error .   
    if not available total2_pl-level
    then do :
      find first bf_goods no-lock where bf_goods.gds-code = calc_r-line.gds-code no-error .
      find first bf_place no-lock where bf_place.pl-code = calc_r-line.pl-code no-error .
      message 
        substitute( 'Для резервуара &1 (&2 &3) не заполнена градуировочная таблица. Запуск ПОкМИ невозможен.'
                   ,(if available bf_place then bf_place.loc1 else "?")
                   ,(if available bf_goods then string(bf_goods.gds-code) else "?")
                   ,(if available bf_goods then bf_goods.gds-name else "?") )
      view-as alert-box .
      undo _trpomi, return "need-data" .
    end .     
    
    DeltaV2 = ? .                                    
    for first buf_pl-level-attr no-lock where buf_pl-level-attr.pl-code  = total2_pl-level.pl-code
                                          and buf_pl-level-attr.obj-code = total2_pl-level.obj-code
                                          and buf_pl-level-attr.obj-type = total2_pl-level.obj-type
                                          and buf_pl-level-attr.pl-level = total2_pl-level.pl-level
                                          and buf_pl-level-attr.attr-code = "deltaV"
                                          :      
      DeltaV2 = decimal(buf_pl-level-attr.attr-value) no-error . 
    end . 
                                   
    if available water1_pl-level
    then do :
      CalibTable = Substitute("&1=&2", water1_pl-level.pl-level, (water1_pl-level.pl-qnty / 1000)) + (if WaterDeltaV1 > 0 then ("=" + trim(string(WaterDeltaV1, ">>9.9999"))) else "") + {&new-line} .
    end . 
    if available water2_pl-level
    then do :
      CalibTable = CalibTable + Substitute("&1=&2", water2_pl-level.pl-level, (water2_pl-level.pl-qnty / 1000)) + (if WaterDeltaV2 > 0 then ("=" + trim(string(WaterDeltaV2, ">>9.9999"))) else "") + {&new-line} .
    end .  
    CalibTable = CalibTable + Substitute("&1=&2", total1_pl-level.pl-level, (total1_pl-level.pl-qnty / 1000)) + (if DeltaV1 > 0 then ("=" + trim(string(DeltaV1, ">>9.9999"))) else "") + {&new-line} . 
    CalibTable = CalibTable + Substitute("&1=&2", total2_pl-level.pl-level, (total2_pl-level.pl-qnty / 1000)) + (if DeltaV2 > 0 then ("=" + trim(string(DeltaV2, ">>9.9999"))) else "") .
        
    CalibBelt = getCalibrationBelt(
        calc_r-line.obj-type, 
        calc_r-line.obj-code,
        calc_r-line.pl-code,
        calc_r-line.state-level-total,
        if calc_r-line.state-level-water <> ? then calc_r-line.state-level-water else 0
    ).
    
    /*..........................................*/

    /*данные по средству измерения резервуара для ПОкМИ*/

    if place-si = 0
    or place-si = ?
    then do :
      message
        substitute ("Для складского места &1 не заданно средство измерения",calc_r-line.pl-code)
      view-as alert-box error.
      undo _trpomi, return "need-data" .
    end.
    else do :
      find first buf_sr-izmerenia no-lock where buf_sr-izmerenia.node-code = place-si no-error.
      if not available buf_sr-izmerenia then do :
        message
        "Ошибка работы с библиотекой ПОкМИ"
        substitute( 'Не найдено средство измерения с кодом &1', place-si ) skip
        view-as alert-box error.
        undo _trpomi, return "need-data" .
      end.
      else do :
        assign
          ToolType               = buf_sr-izmerenia.sr-type-id
          A_LevelMeasurementTool = buf_sr-izmerenia.sr-temp-line
          ToolAutomationLevel_H  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
          ToolAutomationLevel_H_Water = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
          DeltaAbs_H             = buf_sr-izmerenia.sr-abs-err-neft-water
          DeltaAbs_H_Water       = buf_sr-izmerenia.sr-abs-err-water
          ToolAutomationLevel_R  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
          DeltaAbs_R             = buf_sr-izmerenia.sr-abs-err-dens
          ToolAutomationLevel_Tv = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
          DeltaAbs_Tv            = buf_sr-izmerenia.sr-abs-err-temp-vol
          ToolAutomationLevel_Tr = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
          DeltaAbs_Tr            = buf_sr-izmerenia.sr-abs-err-temp-dens
          DeltaOtn_N             = 0.05
          DeltaOtn_H             = buf_sr-izmerenia.sr-relative-err-neft-water
          DeltaOtn_H_Water       = buf_sr-izmerenia.sr-relative-err-water
          DeltaOtn_R             = buf_sr-izmerenia.sr-relative-err-dens
          DeltaAbs_H_CalcType    = buf_sr-izmerenia.sr-type-level-measuring + 1
          DeltaAbs_H_Water_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
        .
      end.
    end.
    
    assign      
      LevelToolType = buf_sr-izmerenia.sr-type-level-measuring 
      ToolAutomationLevel_H  = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
      ToolAutomationLevel_H_Water = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
      DeltaAbs_H_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
      DeltaAbs_H_Water_CalcType = buf_sr-izmerenia.sr-type-level-measuring + 1
      ToolAutomationLevel_Tv = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
      ToolAutomationLevel_Tr = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
      ToolAutomationLevel_R = vAutomationDegree[buf_sr-izmerenia.sr-type-izm + 1]
    .
    
    if DeltaAbs_H       = ? then DeltaAbs_H = 0 .
    if DeltaAbs_H_Water = ? then DeltaAbs_H_Water = 0 .
    if DeltaAbs_R       = ? then DeltaAbs_R = 0 .
    if DeltaAbs_Tv      = ? then DeltaAbs_Tv = 0 .
    if DeltaAbs_Tr      = ? then DeltaAbs_Tr = 0 .
    if DeltaOtn_N       = ? then DeltaOtn_N = 0 .
    if DeltaOtn_H       = ? then DeltaOtn_H = 0 .
    if DeltaOtn_H_Water = ? then DeltaOtn_H_Water = 0 .
    if DeltaOtn_R       = ? then DeltaOtn_R = 0 .
    if LevelToolType    = ? then LevelToolType = 0 .
    if ToolType         = ? then ToolType = 0 .
    if A_LevelMeasurementTool      = ? then A_LevelMeasurementTool = 0 .
    if ToolAutomationLevel_Tr      = ? then ToolAutomationLevel_Tr =0.
    if ToolAutomationLevel_H       = ? then ToolAutomationLevel_H = 0.
    if ToolAutomationLevel_H_Water = ? then ToolAutomationLevel_H_Water = 0.
    if ToolAutomationLevel_Tv      = ? then ToolAutomationLevel_Tv = 0.
    if ToolAutomationLevel_R       = ? then ToolAutomationLevel_R = 0.
    if DeltaAbs_H_CalcType         = ? then DeltaAbs_H_CalcType = 0.
    if DeltaAbs_H_Water_CalcType   = ? then DeltaAbs_H_Water_CalcType = 0.
    
    if calc_r-line.state-level-water = 0
    then do :
      ToolAutomationLevel_H_Water = 3 .
      DeltaAbs_H_Water_CalcType = 1 .
      DeltaAbs_H_Water = 0 .
      DeltaOtn_H_Water = 0 .
    end .
    
    /*..........................................*/
    
    if LevelToolType > 0
    then do :
      MM57
        (input calc_r-line.level-total * 10,
         input LevelToolType,
         output DeltaAbs_H,
         output vErr,
         output vWrn,
         output vDllVersion)
      .  
      OUTPUT stream outstream to value ("pomi.log") append.
      PUT STREAM outstream unformatted
                  "    " SKIP
                  "    " SKIP
                  cur-time-string()           FORMAT "x(16)"    SKIP
                  'Процедура             "CMethodOfMetering57"'       SKIP
                  'Версия dll: '            vDllVersion   skip
                  'CODE_PL                = ' calc_r-line.pl-code                           SKIP
                  'H                      = ' calc_r-line.level-total * 10                  SKIP
                  'ToolType               = ' LevelToolType                                      SKIP
                      SKIP SKIP 
      .
      output stream outstream close.
        
      if trim(vErr) > "" then do :
        output stream outstream to value ("pomi.log")  append.
        put stream outstream vErr format "X(1024)" skip.
        output stream outstream close.
        message substitute('Ошибка работы библиотеки ПОкМИ &1', vErr) view-as alert-box .
        undo _trpomi, return "pomi-error" .
      end.
      else do :
        OUTPUT stream outstream to value ("pomi.log")  append.
        PUT STREAM outstream unformatted
            "DeltaAbs_H = " DeltaAbs_H  SKIP
        .
        OUTPUT stream outstream close.
      end .
    end .
    /*..........................................*/

    { gbl/ptrlprop.i
      run
      calc_r-line.obj-type
      calc_r-line.obj-code
    }
    if not error-status :error then do:
      if ptrlprop-temp-for-pomi = 1 then temp-for-pomi = 15 .
                                    else temp-for-pomi = 20 .
    end.
    
    assign
      Tr = calc_r-line.temperature
      Tv = calc_r-line.temperature
      R = ( calc_r-line.density * 1000 )
    .
    
    /*метод применяемый к данному типу резервуара и */
    find first buf_place no-lock
         where buf_place.obj-code = calc_r-line.obj-code
           and buf_place.obj-type = calc_r-line.obj-type
           and buf_place.pl-code  = calc_r-line.pl-code no-error.
    if place-type = 1 then do :
      v-proc = "CMethodOfMetering13" .
      MM13
        (input 0.0, /*(if place-ponton then place-ponton-mass else 0.0)*/
         input 0.0, /*(if place-ponton then dens-prov * 1000 else 0.0)*/
         input 0.0,
         input 0.0, /*(if place-ponton then place-ponton-height else 0.0)*/
         input calc_r-line.level-total * 10,
         input (if calc_r-line.level-water <> ? then calc_r-line.level-water * 10 else 0.0),
         input CalibTable,
         input CalibBelt,
         input 0.0, /* P0 */
         input 0.0, /* PV */
         input Tv,
         input Tr,
         input R,
         input temp-for-pomi,
         input ToolType,
         input DeltaOtn_K,
         input DeadZone_Reservoir,
         input A_Reservoir,
         input A_LevelMeasurementTool,
         input ToolAutomationLevel_H,
         input ToolAutomationLevel_H_Water,
         input ToolAutomationLevel_R,
         input ToolAutomationLevel_Tv,
         input ToolAutomationLevel_Tr,
         input DeltaAbs_H_CalcType,
         input DeltaAbs_H_Water_CalcType,
         input DeltaAbs_H,
         input DeltaAbs_H_Water,
         input DeltaAbs_R,
         input DeltaAbs_Tv,
         input DeltaAbs_Tr,
         input DeltaOtn_N,
         input 1, /* Round_M */
         input 2, /* Round_T */
         input 2, /* Round_R */
         
         output V_total,
         output V_water,
         output DeltaV,
         output V_product,
         output Vcy,
         output Rcy,
         output V,
         output CTL_base_alt,
         output CPL_base_alt,
         output CTPL_base_alt,
         output Fp_base_alt,
         output CTL_obs_base,
         output CPL_obs_base,
         output CTPL_obs_base,
         output Fp_obs_base,
         output Rv,
         output DeltaOtn_Vcy,
         output DeltaOtn_Vm,
         output M,
         output DeltaOtn_M,
         output VolumetricExpansion,
         
         output vErr,
         output vWrn,
         output vDllVersion)
      no-error .
    end.
    else do :
      v-proc = "CMethodOfMetering6" .
      MM6
        (input calc_r-line.level-total * 10,
         input (if calc_r-line.level-water <> ? then calc_r-line.level-water * 10 else 0.0),
         input CalibTable,
         input CalibBelt,
         input 0.0, /* P0 */
         input Tv,
         input Tr,
         input R,
         input temp-for-pomi,
         input ToolType,
         input DeltaOtn_K,
         input DeadZone_Reservoir,
         input A_Reservoir,
         input A_LevelMeasurementTool,
         input ToolAutomationLevel_H,
         input ToolAutomationLevel_H_Water,
         input ToolAutomationLevel_R,
         input ToolAutomationLevel_Tv,
         input ToolAutomationLevel_Tr,
         input DeltaAbs_H_CalcType,
         input DeltaAbs_H_Water_CalcType,
         input DeltaAbs_H,
         input DeltaAbs_H_Water,
         input DeltaAbs_R,
         input DeltaAbs_Tv,
         input DeltaAbs_Tr,
         input DeltaOtn_N,
         input 1, /* Round_M */
         input 2, /* Round_T */
         input 2, /* Round_R */
         
         output V_total,
         output V_water,
         output DeltaV,
         output V_product,
         output Vcy,
         output Rcy,
         output V,
         output CTL_base_alt,
         output CPL_base_alt,
         output CTPL_base_alt,
         output Fp_base_alt,
         output CTL_obs_base,
         output CPL_obs_base,
         output CTPL_obs_base,
         output Fp_obs_base,
         output Rv,
         output DeltaOtn_Vcy,
         output DeltaOtn_Vm,
         output M,
         output DeltaOtn_M,
         output VolumetricExpansion,
         
         output vErr,
         output vWrn,
         output vDllVersion)
      no-error .
    end.
    /*..............................................*/

    OUTPUT stream outstream to value ("pomi.log") append.
    PUT STREAM outstream unformatted
      "    " SKIP
      "    " SKIP
      cur-time-string()           FORMAT "x(16)"    SKIP
      'Процедура   "'              v-proc       '"'               FORMAT "x(128)"   SKIP
      'Версия dll: '              vDllVersion                           SKIP
      'CODE_PL                     = ' calc_r-line.pl-code                      SKIP
      'H                           = ' calc_r-line.level-total * 10 SKIP
      'H_water                     = ' (if calc_r-line.level-water <> ? then calc_r-line.level-water * 10 else 0.0) SKIP
      'CalibrationTable            = ' CalibTable                    SKIP
      'CalibrationBelt             = ' CalibBelt                    SKIP
      'ToolAutomationLevel_H       = ' ToolAutomationLevel_H     SKIP
      'ToolAutomationLevel_H_Water = ' ToolAutomationLevel_H_Water    SKIP
      'ToolAutomationLevel_R       = ' ToolAutomationLevel_R     SKIP
      'ToolAutomationLevel_Tv      = ' ToolAutomationLevel_Tv    SKIP
      'ToolAutomationLevel_Tr      = ' ToolAutomationLevel_Tr    SKIP
      'DeltaAbs_H_CalcType         = ' DeltaAbs_H_CalcType       SKIP
      'DeltaAbs_H_Water_CalcType   = ' DeltaAbs_H_Water_CalcType SKIP
      'Tv                          = ' round(Tv, 2)              SKIP
      'Tr                          = ' round(Tr, 2)              SKIP
      'R                           = ' round(R, 2)               SKIP
      'Tcy                         = ' temp-for-pomi                       SKIP
      'ToolType                    = ' ToolType                            SKIP
      'DeadZone_Reservoir          = ' DeadZone_Reservoir                  SKIP
      'DeltaOtn_K                  = ' DeltaOtn_K                          SKIP
      'A_Reservoir                 = ' A_Reservoir                         SKIP
      'A_LevelMeasurementTool      = ' A_LevelMeasurementTool              skip
      'DeltaAbs_H                  = ' DeltaAbs_H                          SKIP
      'DeltaAbs_H_Water            = ' DeltaAbs_H_Water                    SKIP
      'DeltaAbs_R                  = ' DeltaAbs_R                          SKIP
      'DeltaAbs_Tv                 = ' DeltaAbs_Tv                         SKIP
      'DeltaAbs_Tr                 = ' DeltaAbs_Tr                         SKIP
      'DeltaOtn_N                  = ' DeltaOtn_N                          SKIP
      'Round_M                     = ' 1                                   SKIP
      'Round_T                     = ' 2                                   SKIP
      'Round_R                     = ' 2                                   SKIP
    .
      
    if place-type = 1
    and place-ponton
    then do :
      put stream outstream unformatted
        "Rprov                  = " 0.0 skip
        "Mpokr                  = " 0.0 skip
        "Vdisp                  = " 0.0 skip
        "CoverFloatingHeight    = " 0.0 skip
      .
    end.
      
    output stream outstream close.
      
    if trim(vErr) > "" then do :
      error-string = substitute("~nРезервуар: &1.~n", if avail buf_place then buf_place.loc1 else "") 
                   + replace(vErr,";0x","~n0x") .
      output stream outstream to value ("pomi.log")  append.
      put stream outstream error-string format "X(1024)" skip.
      output stream outstream close.
      message
      substitute('Ошибка работы библиотеки ПОкМИ. &1',error-string)
      view-as alert-box error.
      undo _trpomi, return "pomi-error" .
    end.
    else do :
      
      find first rvs-line-attr exclusive-lock
            where rvs-line-attr.obj-code  = calc_r-line.obj-code
              and rvs-line-attr.obj-type  = calc_r-line.obj-type
              and rvs-line-attr.gds-code  = calc_r-line.gds-code
              and rvs-line-attr.pl-code   = calc_r-line.pl-code
              and rvs-line-attr.rvs-code  = calc_r-line.rvs-code
              and rvs-line-attr.attr-code = "asi-pomi-density" no-error.
      if available rvs-line-attr then do :
        rvs-line-attr.attr-value = string(Rcy / 1000) .
      end.
      else do :
        create rvs-line-attr.
        assign
          rvs-line-attr.obj-code  = calc_r-line.obj-code
          rvs-line-attr.obj-type  = calc_r-line.obj-type
          rvs-line-attr.gds-code  = calc_r-line.gds-code
          rvs-line-attr.pl-code   = calc_r-line.pl-code
          rvs-line-attr.rvs-code  = calc_r-line.rvs-code
          rvs-line-attr.attr-code = "asi-pomi-density"
          rvs-line-attr.attr-value = string(Rcy / 1000)
        .
      end.
      
      assign
        v-POkMI-result =
          "V_total             = " + string(V_total)       + {&new-line} +
          "V_water             = " + string(V_water)       + {&new-line} +
          "DeltaV              = " + string(DeltaV)         + {&new-line} +
          "Vcy                 = " + string(Vcy)           + {&new-line} +
          "Rcy                 = " + string(Rcy)            + {&new-line} +
          "V_product           = " + string(V_product)      + {&new-line} +
          "V                   = " + string(V)              + {&new-line} + 
          "Rv                  = " + string(Rv)               + {&new-line} +
          "M                   = " + string(M)                 + {&new-line} +
          "CTL_base_alt        = " + string(CTL_base_alt)  + {&new-line} +
          "CPL_base_alt        = " + string(CPL_base_alt)  + {&new-line} +
          "CTPL_base_alt       = " + string(CTPL_base_alt)  + {&new-line} +
          "Fp_base_alt         = " + string(Fp_base_alt)   + {&new-line} +
          "CTL_obs_base        = " + string(CTL_obs_base)  + {&new-line} +
          "CPL_obs_base        = " + string(CPL_obs_base)  + {&new-line} +
          "CTPL_obs_base       = " + string(CTPL_obs_base)  + {&new-line} +
          "Fp_obs_base         = " + string(Fp_obs_base)   + {&new-line} +
          "DeltaOtn_Vcy        = " + string(DeltaOtn_Vcy)  + {&new-line} +
          "DeltaOtn_Vm         = " + string(DeltaOtn_Vm)   + {&new-line} +
          "DeltaOtn_M          = " + string(DeltaOtn_M)       + {&new-line} +
          "VolumetricExpansion = " + string(VolumetricExpansion) + {&new-line} +
          "Warnings            = " + vWrn
      .
      OUTPUT stream outstream to value ("pomi.log")  append.
      PUT STREAM outstream unformatted v-POkMI-result skip .
      OUTPUT stream outstream close.
      
    end.
  end.

end procedure .

