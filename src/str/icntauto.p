block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: icntauto.p $
$Archive: str/icntauto.p $

Автоматическое создание инвентаризации счетчиков ТРК по документу сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/13/09
Author: Dmitry Ukhanov
Creation date: 10/13/09

Автор1: Хныкин Павел Андреевич
Дата создания1: 11/22/07

*/

define input parameter parparentproc   as widget-handle no-undo.
define input parameter p-rvs-doc-rowid as rowid         no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: icntauto.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/icntauto.p $":U .
define variable vss-description as character no-undo init "Автоматическое создание инвентаризации счетчиков ТРК по документу сверки".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-rvs.i  }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }

define temp-table tt-icnt-doc   no-undo like ub.icnt-doc.
define temp-table tt-icnt-line  no-undo like ub.icnt-line.

define buffer cur_rvs-doc         for ub.rvs-doc.
define buffer prev_rvs-doc        for ub.rvs-doc.
define buffer cur_shift-obj       for ub.shift-obj.
define buffer prev_shift-obj      for ub.shift-obj.
define buffer cur_rvs-line-pump   for ub.rvs-line-pump.
define buffer prev_rvs-line-pump  for ub.rvs-line-pump.
define buffer prev_icnt-line      for ub.icnt-line.
define buffer buf_icnt-doc        for ub.icnt-doc.
define buffer buf_rvs-line        for ub.rvs-line.
define buffer bf_pl-gds-pump      for ub.pl-gds-pump.

define variable v-log           as logical    no-undo .
define variable v-today         as date       no-undo .
define variable v-recid         as recid      no-undo .
define variable v-meas-el-cnt   as decimal    no-undo .
define variable v-state-el-cnt  as decimal    no-undo .
define variable v-state-mh-cnt  as decimal    no-undo .


function get-overflow return decimal ( input p-val as decimal ) forward.

_main-block:
do
on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first cur_rvs-doc no-lock
    where rowid(cur_rvs-doc) = p-rvs-doc-rowid
  no-error .
  if not available cur_rvs-doc then do:
    undo _main-block , return error "Не найден документ сверки":U.
  end.

  find first cur_shift-obj no-lock
    where cur_shift-obj.obj-type = cur_rvs-doc.obj-type
      and cur_shift-obj.obj-code = cur_rvs-doc.obj-code
      and cur_shift-obj.status_  = {&sht-current}
  no-error.

  if not available cur_shift-obj then do:
    undo _main-block , return error substitute( 'Нет открытой смены на объекте &1 &2'
                                              , cur_rvs-doc.obj-type
                                              , cur_rvs-doc.obj-code
                                              ).
  end.
  find last prev_shift-obj no-lock
    where prev_shift-obj.obj-type   = cur_shift-obj.obj-type
      and prev_shift-obj.obj-code   = cur_shift-obj.obj-code
      and prev_shift-obj.status_    = {&sht-closed}
      and ( prev_shift-obj.shift-date < cur_shift-obj.shift-date
          or
            prev_shift-obj.shift-date = cur_shift-obj.shift-date
          and
            prev_shift-obj.shift-num  < cur_shift-obj.shift-num
          )
    use-index stts no-error.
  if available prev_shift-obj then do:
    find last prev_rvs-doc no-lock
      where prev_rvs-doc.obj-type   = prev_shift-obj.obj-type
        and prev_rvs-doc.obj-code   = prev_shift-obj.obj-code
        and prev_rvs-doc.shift-date = prev_shift-obj.shift-date
        and prev_rvs-doc.shift-num  = prev_shift-obj.shift-num
        and prev_rvs-doc.status_    = {&fact}
        and prev_rvs-doc.rvs-type   = {&rvs-shift}
      no-error.
  end.
  /*
     TODO
       11/22/07 4:09
     Если нет сверок предыдущих что делать???
  */
  { gbl/getcntxt.i get }
  { gbl/curobjdt.i cur_rvs-doc.obj-type cur_rvs-doc.obj-code v-today }

  run clear-temp in this-procedure .

  /* создаем шапку документа */
  create tt-icnt-doc.
  assign
    tt-icnt-doc.doc-code      = "":U
    tt-icnt-doc.obj-type      = cur_rvs-doc.obj-type
    tt-icnt-doc.obj-code      = cur_rvs-doc.obj-code
    tt-icnt-doc.host-code     = cur_rvs-doc.host-code
    tt-icnt-doc.wrkr          = cur_rvs-doc.wrkr
    tt-icnt-doc.agnt          = cur_rvs-doc.agnt
    tt-icnt-doc.boss          = cur_rvs-doc.boss
    tt-icnt-doc.doc-date      = v-today
    tt-icnt-doc.meas-el-cnt   = 0
    tt-icnt-doc.state-el-cnt  = 0
    tt-icnt-doc.state-mh-cnt  = 0
    tt-icnt-doc.PS            = cur_rvs-doc.rvs-code
    tt-icnt-doc.creid         = v-cntxt-userid
  .
  /* создаем строки инвентаризации из переданого документа сверки */
  for each cur_rvs-line-pump exclusive-lock
    where cur_rvs-line-pump.rvs-code = cur_rvs-doc.rvs-code
  on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    find first prev_rvs-line-pump no-lock
      where prev_rvs-line-pump.rvs-code     = prev_rvs-doc.rvs-code
        and prev_rvs-line-pump.obj-type     = prev_rvs-doc.obj-type
        and prev_rvs-line-pump.obj-code     = prev_rvs-doc.obj-code
        and prev_rvs-line-pump.pl-code      = cur_rvs-line-pump.pl-code
        and prev_rvs-line-pump.gds-code     = cur_rvs-line-pump.gds-code
        and prev_rvs-line-pump.pump-code    = cur_rvs-line-pump.pump-code
        and prev_rvs-line-pump.nozzle-code  = cur_rvs-line-pump.nozzle-code
    no-error .

    find first tt-icnt-line no-lock
      where tt-icnt-line.doc-code    = tt-icnt-doc.doc-code
        and tt-icnt-line.obj-code    = tt-icnt-doc.obj-code
        and tt-icnt-line.obj-type    = tt-icnt-doc.obj-type
        and tt-icnt-line.pump-code   = cur_rvs-line-pump.pump-code
        and tt-icnt-line.nozzle-code = cur_rvs-line-pump.nozzle-code
      no-error .

    if not available tt-icnt-line then do:
      create tt-icnt-line.
      assign
        tt-icnt-line.doc-code     = tt-icnt-doc.doc-code
        tt-icnt-line.obj-code     = cur_rvs-line-pump.obj-code
        tt-icnt-line.obj-type     = cur_rvs-line-pump.obj-type
        tt-icnt-line.pl-code      = cur_rvs-line-pump.pl-code
        tt-icnt-line.gds-code     = cur_rvs-line-pump.gds-code
        tt-icnt-line.pump-code    = cur_rvs-line-pump.pump-code
        tt-icnt-line.nozzle-code  = cur_rvs-line-pump.nozzle-code
        tt-icnt-line.state-el-cnt = cur_rvs-line-pump.state-el-cnt
        tt-icnt-line.meas-el-cnt  = cur_rvs-line-pump.meas-el-cnt

        tt-icnt-line.state-mh-cnt = cur_rvs-line-pump.state-mh-cnt
      .
    end.
    
    
      /* если электронный счетчик на текущую сверку меньше, чем показания на предыдущую сверку, то изменяем счетчик */
    if available prev_rvs-line-pump
    and cur_rvs-line-pump.state-el-cnt < prev_rvs-line-pump.state-el-cnt
    then do:
      find first bf_pl-gds-pump no-lock where bf_pl-gds-pump.obj-type = cur_rvs-line-pump.obj-type
                                          and bf_pl-gds-pump.obj-code = cur_rvs-line-pump.obj-code
                                          and bf_pl-gds-pump.gds-code = cur_rvs-line-pump.gds-code
                                          and bf_pl-gds-pump.pl-code  = cur_rvs-line-pump.pl-code
                                          and bf_pl-gds-pump.pump-code = cur_rvs-line-pump.pump-code
                                          no-error.
      if available bf_pl-gds-pump
      and bf_pl-gds-pump.status_ = {&blocked-status}
      then do : end .
      else
      assign
        tt-icnt-line.state-mh-cnt = tt-icnt-line.state-mh-cnt + get-overflow( prev_rvs-line-pump.state-el-cnt )
      .
      assign
        cur_rvs-line-pump.state-mh-cnt  = tt-icnt-line.state-mh-cnt
        cur_rvs-line-pump.state-mh-qnty = cur_rvs-line-pump.state-mh-cnt - prev_rvs-line-pump.state-mh-cnt
        cur_rvs-line-pump.meas-mh-cnt   = cur_rvs-line-pump.state-mh-cnt
        cur_rvs-line-pump.meas-mh-qnty  = cur_rvs-line-pump.state-mh-qnty
      .

      end.
    end.
  for each tt-icnt-line
    where tt-icnt-line.doc-code = tt-icnt-doc.doc-code
      and tt-icnt-line.obj-code = tt-icnt-doc.obj-code
      and tt-icnt-line.obj-type = tt-icnt-doc.obj-type
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    assign
      v-meas-el-cnt  = v-meas-el-cnt  + tt-icnt-line.meas-el-cnt
      v-state-el-cnt = v-state-el-cnt + tt-icnt-line.state-el-cnt
      v-state-mh-cnt = v-state-mh-cnt + tt-icnt-line.state-mh-cnt
    .
  end.

  for each buf_rvs-line no-lock
  on error  undo _main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo _main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    { str/rvsclcln.i
      "recid(buf_rvs-line)"
      no-error
    }
    if error-status :error then do:
      undo _main-block , return error substitute( "Ошибка пересчета количества по резервуарам.&1&2&1&3":U, {&new-line}, return-value, error-status :get-message(1) ).
    end.
  end.
  /* пересчитываем шапку инвентаризации */
  assign
    tt-icnt-doc.meas-el-cnt  = v-meas-el-cnt
    tt-icnt-doc.state-el-cnt = v-state-el-cnt
    tt-icnt-doc.state-mh-cnt = v-state-mh-cnt
  .
  run waitfram-show in this-procedure ( "Создание документа инвентаризации счетчиков ТРК":U ) .
  /* создаем документ инвентаризации счетчиков ТРК  */
  run str/icntdoc1.p
    ( input {&add-def}
     ,input no /*p-silent*/
     ,input-output v-recid
     ,INPUT tt-icnt-doc.doc-code
     ,input tt-icnt-doc.obj-type
     ,input tt-icnt-doc.obj-code
     ,input tt-icnt-doc.host-code
     ,input {&icnt-doc}
     ,input {&TDEICNT_Inv}
     ,input tt-icnt-doc.wrkr
     ,input tt-icnt-doc.agnt
     ,input tt-icnt-doc.boss
     ,input tt-icnt-doc.doc-date
     ,input tt-icnt-doc.meas-el-cnt
     ,input tt-icnt-doc.state-el-cnt
     ,input tt-icnt-doc.state-mh-cnt
     ,input tt-icnt-doc.PS
     ,input tt-icnt-doc.creid
     ,input '':U /*p-ptrlcheck*/
     ,input table tt-icnt-line
    ) no-error.
  if error-status:error then do:
    undo _main-block , return error return-value .
  end.
  find first buf_icnt-doc exclusive-lock
    where recid(buf_icnt-doc) = v-recid
  no-error .
  if not available buf_icnt-doc then do:
    undo _main-block , return error "Не найден документ автоматической инвентаризации":U.
  end.
  assign
    buf_icnt-doc.PS = "@":U
  .
  release buf_icnt-doc .
  run waitfram-show in this-procedure ( "Закрытие документа инвентаризации счетчиков ТРК":U ) .
  run str/icntdoc2.p
    ( input v-recid
     ,input no /*p-silent*/
    ) no-error.
  if error-status:error then do:
    undo _main-block , return error return-value .
  end.
  run clear-temp in this-procedure .
  run waitfram-hide in this-procedure .
end. /* _main-block : */


/* ================================================================================= */
procedure clear-temp :

do
on error undo, return error return-value
:
  for each tt-icnt-doc
  on error undo, return error return-value
  :
    delete tt-icnt-doc .
  end.
  for each tt-icnt-line
  on error undo, return error return-value
  :
    delete tt-icnt-line .
  end.
end.

end procedure. /* clear-temp */

/* ================================================================================= */
function get-overflow return decimal ( input p-val as decimal ).
  define variable v-val       as decimal   no-undo .
  define variable v-overflow  as decimal   no-undo .

  assign
    v-val       = p-val
    v-overflow  = 1
  .
  do while v-val > 1 :
    assign
      v-val       = v-val / 10
      v-overflow  = v-overflow * 10
    .
  end.

  return v-overflow.
end function.