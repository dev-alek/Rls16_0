block-level on error undo, throw.
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
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable v-mess as character no-undo .
define variable v-db-num as integer no-undo .
define variable v-ii as integer no-undo .
define buffer buf_icnt-doc for ub.icnt-doc.
define buffer buf_icnt-line for ub.icnt-line.
define buffer buf_rvs-doc for ub.rvs-doc.
define buffer old_icnt-doc for ub.icnt-doc.
define buffer buf_chk-doc for ub.chk-doc.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
main-block:
do for buf_icnt-doc
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    if p-doc-type = 'инв-сч-трк':U then do:
      find first buf_rvs-doc no-lock
        where buf_rvs-doc.obj-type =  p-obj-type
          and buf_rvs-doc.obj-code =  p-obj-code
          and buf_rvs-doc.status_  <> 'факт':U
          and buf_rvs-doc.rvs-type <> 'перед_док':U
          and buf_rvs-doc.rvs-type <> 'после_док':U
          and buf_rvs-doc.rvs-type <> 'проверка':U
        no-error.
      if available buf_rvs-doc then do:
        if not( buf_rvs-doc.rvs-type = 'смена':U and buf_rvs-doc.rvs-code = p-PS ) then do:
          v-mess = substitute("Имеется открытый документ сверки под номером &1", buf_rvs-doc.rvs-code).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent = yes then v-mess else '':U).
        end.
      end.
      find first old_icnt-doc no-lock
        where old_icnt-doc.obj-type =  p-obj-type
          and old_icnt-doc.obj-code =  p-obj-code
          and old_icnt-doc.status_  <> 'факт':U
        no-error.
      if available old_icnt-doc then do:
        v-mess = substitute( "Уже есть открытый документ инвентаризации счетчиков ТРК под номером &1", old_icnt-doc.doc-code ).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    run doc-code in this-procedure
      ( input  "main"
       ,input  p-obj-type
       ,input  p-obj-code
       ,input  ?
       ,output p-doc-code
      ) no-error.
    if error-status:error then do:
      v-mess = substitute( "Ошибка при генерации номера документа&1&2&1&3"
                           ,chr(10)
                           ,error-status:get-message(1)
                           ,return-value
                         ).
      run err-mess in this-procedure ( input-output v-mess).
      undo main-block, return error (if p-silent = yes then v-mess else '':U).
    end.
    create buf_icnt-doc.
    assign
      p-doc-code             = (if p-doc-type = 'инв-сч-трк':U
                                then p-doc-code
                                else substitute("e&1", p-doc-code))
      buf_icnt-doc.doc-code  = p-doc-code
      buf_icnt-doc.obj-type  = p-obj-type
      buf_icnt-doc.obj-code  = p-obj-code
      buf_icnt-doc.host-code = p-host-code
      buf_icnt-doc.doc-type  = p-doc-type
      buf_icnt-doc.ext-doc-type  = p-ext-doc-type
      buf_icnt-doc.status_   = 'новый':U
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
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
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
                          , chr(10)).
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
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
                            , chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      buffer-copy tt-icnt-line
      to buf_icnt-line
      .
    end.
    for each buf_icnt-line
      where buf_icnt-line.doc-code = buf_icnt-doc.doc-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
        v-mess = substitute("Для уже имеющегося документа счетчиков ТРК нельзя удалять строки&1", chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end.
  release buf_icnt-doc no-error.
  if error-status:error then do:
    assign
    v-mess = substitute("Ошибка при сохранении записи:&1&2&1&3", chr(10), error-status:get-message(1) , return-value ).
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
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when true then do:
      assign
        p-mess = substitute("Документ счетчиков ТРК &1 &2&3&4&5"
                            ,p-doc-code
                            ,p-obj-type
                            ,p-obj-code
                            ,chr(10)
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
