block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сохранение документа счетчиков ТРК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/18/07
Author: Bakhtadze Natalya
Creation date: 07/18/07

*/

define input parameter p-mode as character no-undo .
define input parameter p-silent as logical no-undo .
define input-output parameter p-recid as recid no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-ext-doc-type as character no-undo .
define input parameter p-wrkr as integer no-undo .
define input parameter p-agnt as integer no-undo .
define input parameter p-boss as integer no-undo .
define input parameter p-doc-date as date no-undo .
define input parameter p-meas-el-cnt as decimal no-undo .
define input parameter p-state-el-cnt as decimal no-undo .
define input parameter p-state-mh-cnt as decimal no-undo .
define input parameter p-PS as character no-undo .
define input parameter p-creid as character no-undo .
define input parameter p-ptrlcheck as character no-undo .
define temp-table tt-icnt-line no-undo like ub.icnt-line.
DEFINE INPUT PARAMETER TABLE FOR tt-icnt-line.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение документа счетчиков ТРК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ str/doc-code.i }

define variable v-mess as character no-undo .
define variable v-db-num as integer no-undo .
define variable v-ii as integer no-undo .
define buffer buf_icnt-doc for ub.icnt-doc.
define buffer buf_icnt-line for ub.icnt-line.
define buffer buf_rvs-doc for ub.rvs-doc.
define buffer old_icnt-doc for ub.icnt-doc.
define buffer buf_chk-doc for ub.chk-doc.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.

main-block:
do for buf_icnt-doc
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if p-mode = {&add-def} then do:
    if p-doc-type = {&icnt-doc} then do:
      find first buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type =  p-obj-type
          and buf_rvs-doc.obj-code =  p-obj-code
          and buf_rvs-doc.status_  <> {&fact}
          and buf_rvs-doc.rvs-type <> {&rvs-before-doc}
          and buf_rvs-doc.rvs-type <> {&rvs-after-doc}
          and buf_rvs-doc.rvs-type <> {&test-asi}
        no-error.
      if available buf_rvs-doc then do:
        if not( buf_rvs-doc.rvs-type = {&rvs-shift} and buf_rvs-doc.rvs-code = p-PS ) then do:
          v-mess = substitute("Имеется открытый документ сверки под номером &1", buf_rvs-doc.rvs-code).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent = yes then v-mess else '':U).
        end.
      end.
      find first old_icnt-doc no-lock
        where old_icnt-doc.obj-type =  p-obj-type
          and old_icnt-doc.obj-code =  p-obj-code
          and old_icnt-doc.status_  <> {&fact}
        no-error.
      if available old_icnt-doc then do:
        v-mess = substitute( "Уже есть открытый документ инвентаризации счетчиков ТРК под номером &1", old_icnt-doc.doc-code ).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
    end. /*if p-doc-type = {&icnt-doc} then do:*/
    run doc-code in this-procedure
      ( input  "main"
       ,input  p-obj-type
       ,input  p-obj-code
       ,input  ?
       ,output p-doc-code
      ) no-error.
    if error-status:error then do:
      v-mess = substitute( "Ошибка при генерации номера документа&1&2&1&3"
                           ,{&new-line}
                           ,error-status:get-message(1)
                           ,return-value
                         ).
      run err-mess in this-procedure ( input-output v-mess).
      undo main-block, return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_icnt-doc.
    assign
      p-doc-code             = (if p-doc-type = {&icnt-doc}
                                then p-doc-code
                                else substitute("e&1", p-doc-code))
      buf_icnt-doc.doc-code  = p-doc-code
      buf_icnt-doc.obj-type  = p-obj-type
      buf_icnt-doc.obj-code  = p-obj-code
      buf_icnt-doc.host-code = p-host-code
      buf_icnt-doc.doc-type  = p-doc-type
      buf_icnt-doc.ext-doc-type  = p-ext-doc-type
      buf_icnt-doc.status_   = {&g___new}
      buf_icnt-doc.flag_     = no
      buf_icnt-doc.creid     = p-creid
      buf_icnt-doc.PS        = p-ps
      buf_icnt-doc.doc-date  = p-doc-date
      buf_icnt-doc.boss      = p-boss
      buf_icnt-doc.wrkr      = p-wrkr
      buf_icnt-doc.agnt      = p-agnt
      buf_icnt-doc.meas-el-cnt = p-meas-el-cnt
      buf_icnt-doc.state-el-cnt = p-state-el-cnt
      buf_icnt-doc.state-mh-cnt = p-state-mh-cnt
    .
    for each tt-icnt-line
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
       find first buf_icnt-line where
                buf_icnt-line.doc-code = buf_icnt-doc.doc-code
           and  buf_icnt-line.obj-type = buf_icnt-doc.obj-type
           and  buf_icnt-line.obj-code = buf_icnt-doc.obj-code
           and  buf_icnt-line.pump-code = (if tt-icnt-line.pump-code = ? then 0 else tt-icnt-line.pump-code)
           and  buf_icnt-line.nozzle-code = (if tt-icnt-line.nozzle-code = ? then 0 else tt-icnt-line.nozzle-code) no-error .
      if not available buf_icnt-line then do:
        create buf_icnt-line.
      end.
      buffer-copy tt-icnt-line except doc-code
      to buf_icnt-line
      assign
      buf_icnt-line.doc-code = buf_icnt-doc.doc-code
      buf_icnt-line.nozzle-code = (if tt-icnt-line.nozzle-code = ? then 0 else tt-icnt-line.nozzle-code)
      buf_icnt-line.pump-code = (if tt-icnt-line.pump-code = ? then 0 else tt-icnt-line.pump-code)
      .
    end.
    p-recid = recid(buf_icnt-doc).
  end. /*if p-mode = {&add-def} then do:*/
  if p-mode = {&update} then do:
    find first buf_icnt-doc  exclusive-lock where
              recid(buf_icnt-doc) = p-recid .
    if buf_icnt-doc.doc-code <> p-doc-code
    or buf_icnt-doc.obj-type <> p-obj-type
    or buf_icnt-doc.obj-code <> p-obj-code
    or buf_icnt-doc.doc-date <> p-doc-date
    then do:
      assign
      v-mess = substitute("Для уже имеющегося документа счетчиков ТРК нельзя менять номер документа и/или&1" +
                          "объект и/или дату док-та"
                          , {&new-line}).
      run err-mess in this-procedure ( input-output v-mess).
      undo main-block, return error (if p-silent = yes then v-mess else '':U).
    end.
    assign
      buf_icnt-doc.PS        = p-ps
      buf_icnt-doc.boss      = p-boss
      buf_icnt-doc.wrkr      = p-wrkr
      buf_icnt-doc.agnt      = p-agnt
      buf_icnt-doc.meas-el-cnt = p-meas-el-cnt
      buf_icnt-doc.state-el-cnt = p-state-el-cnt
      buf_icnt-doc.state-mh-cnt = p-state-mh-cnt
    .
    for each tt-icnt-line
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      find first buf_icnt-line where
              buf_icnt-line.doc-code = buf_icnt-doc.doc-code
          and  buf_icnt-line.obj-type = buf_icnt-doc.obj-type
          and  buf_icnt-line.obj-code = buf_icnt-doc.obj-code
          and  buf_icnt-line.pump-code = tt-icnt-line.pump-code
          and  buf_icnt-line.nozzle-code = tt-icnt-line.nozzle-code no-error .
      if not available buf_icnt-line then do:
        assign
        v-mess = substitute("Для уже имеющегося документа счетчиков ТРК нельзя добавлять новые строки&1"
                            , {&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      buffer-copy tt-icnt-line
      to buf_icnt-line
      .
    end.
    for each buf_icnt-line
      where buf_icnt-line.doc-code = buf_icnt-doc.doc-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      find first tt-icnt-line
        where tt-icnt-line.doc-code = buf_icnt-doc.doc-code
          and tt-icnt-line.obj-type = buf_icnt-doc.obj-type
          and tt-icnt-line.obj-code = buf_icnt-doc.obj-code
          and tt-icnt-line.pump-code = buf_icnt-line.pump-code
          and tt-icnt-line.nozzle-code = buf_icnt-line.nozzle-code
        no-error .
      if not available tt-icnt-line then do:
        assign
        v-mess = substitute("Для уже имеющегося документа счетчиков ТРК нельзя удалять строки&1", {&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end. /*  if p-mode = {&update} then do:*/
  release buf_icnt-doc no-error.
  if error-status:error then do:
    assign
    v-mess = substitute("Ошибка при сохранении записи:&1&2&1&3", {&new-line}, error-status:get-message(1) , return-value ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
  if p-ptrlcheck <> '':U then do:
    do v-ii = 1 to num-entries(p-ptrlcheck):
      find first buf_chk-doc exclusive-lock
        where buf_chk-doc.doc-code = entry(v-ii, p-ptrlcheck)
      .
      assign
        buf_chk-doc.out-2-code = p-doc-code
      .
    end.
  end.
  return '':U.
end. /*doe*/


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when true then do:
      assign
        p-mess = substitute("Документ счетчиков ТРК &1 &2&3&4&5"
                            ,p-doc-code
                            ,p-obj-type
                            ,p-obj-code
                            ,{&new-line}
                            ,p-mess)
      .
    end.
    when no then do:
      message
        p-mess
        view-as alert-box error .
    end.
  end.
END PROCEDURE.