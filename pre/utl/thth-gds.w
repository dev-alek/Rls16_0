DEFINE BUFFER X_ext-classif FOR ub.ext-classif.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER bttns AS character NO-UNDO.
define input parameter p-from-version as character no-undo .
DEFINE INPUT PARAMETER p-list-mode AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rid-list AS character NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Соответствие товаров в разных TH".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info2 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info2, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info2 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info2, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info2 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info2, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info2, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info2, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info2, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info2, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info2 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info2 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info2, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info2 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info2 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable gdsgrp_recids      as character no-undo.
define new shared variable fin-schet-recid    as character no-undo.
define new shared variable v-d-report-handle  as handle    no-undo .
define new shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define new shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define new shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define new shared variable str1   as character  no-undo.
define new shared variable str2   as character  no-undo.
define new shared variable str3   as character  no-undo.
define new shared variable str4   as character  no-undo.
define new shared variable ReportNAme   as character  no-undo.
define new shared variable ReportProc   as character  no-undo.
define new shared variable ReportHeader as character  no-undo.
define new shared variable ReportPageWidth  as integer no-undo.
define new shared variable ReportPageHeight as integer no-undo.
define new shared variable ReportFontNum    as integer no-undo.
define new shared variable my-request as logical  init false no-undo.
define new shared variable v-delim as character no-undo .
define new shared variable v-sdate as character no-undo initial "/":U.
define new shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define new shared variable my-handle  as handle no-undo .
define new shared variable parent-handle  as handle no-undo .
define new shared variable v-show-all-goods as logical  no-undo .
define new shared variable params-only      as logical   no-undo .
define new shared variable params-only-mode as character no-undo .
define new shared variable place-call       as character no-undo .
define new shared variable x-Goods-Editor   as character  no-undo .
define new shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define new shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define new shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define new shared variable x-Shift-End      as integer format ">9":u         no-undo .
define new shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define new shared variable x-SelectGood     as integer                      no-undo .
define new shared variable x-SelectObject   as character                          no-undo .
define new shared variable x-SET_PAY_TYPE   as integer  no-undo .
define new shared variable x-SET_val_TYPE   as integer  no-undo .
define new shared variable x-TOG-Shift      as logical  no-undo .
define new shared variable x-Radio-Task     as integer  no-undo .
define new shared variable x-TOG-Excel      as logical  no-undo .
define new shared variable x-TOG-list-hist  as logical  no-undo .
define new shared variable x-text-1 as character  no-undo .
define new shared variable x-text-2 as character  no-undo .
define new shared variable x-text-3 as character  no-undo .
define new shared variable x-text-4 as character  no-undo .
define new shared variable init-date-start  like x-date-start  no-undo .
define new shared variable init-date-end    like x-date-end    no-undo .
define new shared variable init-date-alone  like x-date-alone  no-undo .
define new shared variable init-shift-alone like x-shift-alone no-undo .
define new shared variable init-shift-start like x-shift-start no-undo .
define new shared variable init-shift-end   like x-shift-end   no-undo .
define new shared variable init-set_pay_type like x-set_pay_type   no-undo .
define new shared variable init-set_val_type like x-set_val_type   no-undo .
define new shared variable ref_date-start    as character   no-undo .
define new shared variable ref_date-end      as character   no-undo .
define new shared variable ref_date-alone    as character   no-undo .
define new shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define new shared variable str-obj-type as character  no-undo.
define new shared variable str-obj-code as character  no-undo.
define new shared variable str-obj-name as character  no-undo.
define new shared variable str-obj      as character  no-undo.
define new shared variable link#        as logical  no-undo init false.
define new shared variable  Verify-Arc-ot      as logical  no-undo init false.
define new shared variable  Verify-Arc-stk     as logical  no-undo init false.
define new shared variable  Verify-Arc-supp    as logical  no-undo init false.
define new shared variable  Verify-Arc-hold    as logical  no-undo init false.
define new shared variable  Verify-Arc-aht     as logical  no-undo init false.
define new shared variable  Verify-send-check  as logical  no-undo init false.
define new shared variable  Verify-Arc-fin     as logical  no-undo init false.
define new shared variable  Verify-Arc-strong  as logical  no-undo init false.
define new shared variable  Show-Crsa         as logical  no-undo init false.
define new shared variable  Show-Cost         as logical  no-undo init false.
define new shared variable  Show-Sale         as logical  no-undo init false.
define new shared variable  Name-Sale-price   as character no-undo .
define new shared variable  Format-Folder     as logical no-undo .
define new shared variable  Print-List-Hist   as logical no-undo init false.
define new shared variable Make-Excel     as logical  no-undo init false.
define new shared variable Make-Excel-com as logical  no-undo init false.
define new shared stream ForExcel.
define new shared variable Use-column   as logical extent 256 no-undo .
define new shared variable right-column as logical extent 256 no-undo .
define new shared temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
  create Sheetf.
  assign
  sheetf.sheet-num = 1.
define variable l-stroka as character no-undo .
define new shared  variable ch#ExcelApplication as com-handle no-undo .
define new shared  variable ch#Workbook         as com-handle no-undo .
define new shared  variable ch#Worksheet        as com-handle no-undo .
define new shared  variable Num#Str#            as integer no-undo.
define new shared  variable Number-List         as integer no-undo init 1.
define new shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
define variable v-del-1 as character no-undo .
if  v-delim = " " or v-delim = ? or v-delim = ""  then do:
    run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
    if error-status :error then do:
      message error-status :error error-status :get-message(1)
              v-delim v-del-1.
        v-delim = ','  .
    end.
end.
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  stream PrnLibStream.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream PrnLibStream to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream PrnLibStream TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table goods-01 no-undo
field gds-code as integer
field src-gds-code as integer
field artic as character
field src-artic as character
field prod-type as character
field prod-code as integer
field src-prod-type as character
field src-prod-code as integer
field prod-name as character
field alpha1 as character
field attrib as character
field calc-method as character
field chk-name as character
field cond-keep-code as integer
field cli-base-rate as decimal
field cst-base-rate as decimal
field deadline as integer
field destin as character
field engl-name as character
field fbr-grp-code as integer
field fbr-grp-name as character
field gds-name as character
field gds-type as character
field grp-code as integer
field src-grp-code as integer
field grp-name as character
field increase-pc as decimal
field label-name as character
field max-rate as decimal
field min-rate as decimal
field ms-base as decimal
field ms-cart as decimal
field nationality as character
field negative-Rest as logical
field prt-root as integer
field prt-root-name as character
field normal-wastage as decimal
field normal-waste as decimal
field okdp as character
field PS as character
field qnty-cart as decimal
field sert as character
field sort as character
field struct as character
field tnved as character
field unit-base as character
field unit-cli as character
field unit-cst as character
field user-rule as character
field wt-base as decimal
field wt-cart as decimal
field attr-15x80 as character
field attr-8x50 as character
field attr-6x50 as character
field gds-obj-price-base as decimal
field gds-obj-price-rubl as decimal
field vat-pc-code as integer
field slt-pc-code as integer
index pi is unique primary
src-gds-code
index iprod
src-prod-type
src-prod-code
.
define NEW SHARED temp-table bar-code-01 no-undo
field b-code as integer
field src-b-code as integer
field gds-code as integer
field src-gds-code as integer
field cli-base-rate as decimal
field node-code as integer
field unit-cli as character
index pi as unique primary
src-b-code
.
define NEW SHARED temp-table prod-bc-01 no-undo
field b-str as character
field b-code as integer
field src-b-code as integer
field bc-on as logical
index pi is unique primary
src-b-code
b-str.
define NEW SHARED temp-table temp-tax-rate no-undo
field rate-code as integer
field src-rate-code as integer
field tax-code as integer
field tax-rate-value as decimal
index pi is unique primary
tax-code rate-code
index isrc src-rate-code
.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thth150-db-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-gds-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-clients':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-goods':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-dis-card':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ ДК"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-label = "Ожидаемое кол-во ДК"     p-type = 'I':U      p-format = "999,999,999"     p-label = "Ожидаемое кол-во ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-shop':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-contract':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-price-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-trn-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thth150-db-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов" .   end.
            when 'thth150-gds-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп товаров" .   end.
            when 'thth150-clients':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие клиентов" .   end.
            when 'thth150-goods':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие товаров" .   end.
            when 'thth150-dis-card':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ ДК"     p-label = "ИМПОРТИРОВАНЫ ДК" .   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-tooltip = "Ожидаемое кол-во ДК"     p-label = "Ожидаемое кол-во ДК" .   end.
            when 'thth150-shop':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие объeктов TH для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH" .   end.
            when 'thth150-contract':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ договора и спецификации для двух систем IBS TH"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации" .   end.
            when 'thth150-price-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ переоценки"     p-label = "ИМПОРТИРОВАНЫ переоценки" .   end.
            when 'thth150-trn-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ приходные накладные"     p-label = "ИМПОРТИРОВАНЫ приходные накладные" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thth150-db-attr-value :
  do
  on error undo, return error
  :
    define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-value     like ub.db-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if avail buf_db-attr then do:
      assign
        p-value =  buf_db-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure thth150-db-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define input parameter p-value     like ub.db-attr.attr-value no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if not available buf_db-attr then do:
      create buf_db-attr .
      assign
        buf_db-attr.db-num    = p-db-num
        buf_db-attr.attr-code = p-code
      .
    end.
    assign
      buf_db-attr.attr-value = p-value
    .
  end.
end procedure.
procedure thth150-db-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if  available buf_db-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure thth150-db-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.db-attr.db-num     no-undo .
    define input parameter p-code     like ub.db-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_db-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_db-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure thth150-db-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-news = no.   end.
            when 'thth150-gds-grp':U then do:     assign     p-news = no.   end.
            when 'thth150-clients':U then do:     assign     p-news = no.   end.
            when 'thth150-goods':U then do:     assign     p-news = no.   end.
            when 'thth150-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth150-shop':U then do:     assign     p-news = no.   end.
            when 'thth150-contract':U then do:     assign     p-news = no.   end.
            when 'thth150-price-doc':U then do:     assign     p-news = no.   end.
            when 'thth150-trn-doc':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thth14-db-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'thth14-cli-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-gds-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-clients':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-goods':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-dis-card':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ ДК"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-qnty-dis-card':U then do:     assign     p-label = "Ожидаемое кол-во ДК"     p-type = 'I':U      p-format = "999,999,999"     p-label = "Ожидаемое кол-во ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-shop':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-contract':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-price-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-trn-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thth14-db-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'thth14-cli-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов" .   end.
            when 'thth14-gds-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп товаров" .   end.
            when 'thth14-clients':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие клиентов" .   end.
            when 'thth14-goods':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие товаров" .   end.
            when 'thth14-dis-card':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ ДК"     p-label = "ИМПОРТИРОВАНЫ ДК" .   end.
            when 'thth14-qnty-dis-card':U then do:     assign     p-tooltip = "Ожидаемое кол-во ДК"     p-label = "Ожидаемое кол-во ДК" .   end.
            when 'thth14-shop':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие объeктов TH для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH" .   end.
            when 'thth14-contract':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ договора и спецификации для двух систем IBS TH"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации" .   end.
            when 'thth14-price-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ переоценки"     p-label = "ИМПОРТИРОВАНЫ переоценки" .   end.
            when 'thth14-trn-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ приходные накладные"     p-label = "ИМПОРТИРОВАНЫ приходные накладные" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thth14-db-attr-value :
  do
  on error undo, return error
  :
    define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-value     like ub.db-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth14-db-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if avail buf_db-attr then do:
      assign
        p-value =  buf_db-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure thth14-db-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define input parameter p-value     like ub.db-attr.attr-value no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth14-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if not available buf_db-attr then do:
      create buf_db-attr .
      assign
        buf_db-attr.db-num    = p-db-num
        buf_db-attr.attr-code = p-code
      .
    end.
    assign
      buf_db-attr.attr-value = p-value
    .
  end.
end procedure.
procedure thth14-db-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth14-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if  available buf_db-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure thth14-db-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.db-attr.db-num     no-undo .
    define input parameter p-code     like ub.db-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth14-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_db-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_db-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure thth14-db-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'thth14-cli-grp':U then do:     assign     p-news = no.   end.
            when 'thth14-gds-grp':U then do:     assign     p-news = no.   end.
            when 'thth14-clients':U then do:     assign     p-news = no.   end.
            when 'thth14-goods':U then do:     assign     p-news = no.   end.
            when 'thth14-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth14-qnty-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth14-shop':U then do:     assign     p-news = no.   end.
            when 'thth14-contract':U then do:     assign     p-news = no.   end.
            when 'thth14-price-doc':U then do:     assign     p-news = no.   end.
            when 'thth14-trn-doc':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table temp-bind no-undo
field src-gds-code  as integer
field src-artic     as character
field src-prod-type as character
field src-prod-code as integer
field src-gds-name  as character
field src-unit-base as character
field src-stts as integer
field src-b-code as integer
field src-grp-name as character
field src-prod-name as character
field has-bind  as integer
field bind-producer as character initial " "
field bind-producer-name as character initial " "
field bind-artic as character initial " "
field bind-name as character initial " "
field bind-unit-base as character initial " "
field old-v151 as integer
field trg-gds-code as integer
field trg-artic     as character
field trg-prod-type as character
field trg-prod-code as integer
field trg-gds-name  as character
field trg-unit-base as character
field trg-stts as integer
field trg-b-code as integer
field trg-grp-name as character
field trg-prod-name as character
field old-v151-producer as character initial " "
field old-v151-artic as character initial " "
field old-v151-name as character initial " "
field old-v151-unit-base as character initial " "
field old-v151-stts as character initial " "
field old-v151-grp as character  initial " "
field old-v151-pbc as character initial " "
field correct-bind as character index pi is unique primary
src-gds-code
trg-gds-code
index pi15
trg-gds-code
index icor
correct-bind
.
define new shared temp-table temp-prod-bc
field src-gds-code as integer
field src-root-code as integer
field src-b-code as integer
field src-unit-base as character
field src-unit-cli as character
field src-cli-base-rate as decimal
field src-b-str as character
field src-bc-on as logical
field old-gds-code as integer
field old-root-code as integer
field old-b-code as integer
field old-unit-base as character
field old-unit-cli as character
field old-cli-base-rate as decimal
field old-b-str as character
field old-bc-on as logical
field trg-gds-code as integer
field trg-root-code as integer
field trg-b-code as integer
field trg-unit-base as character
field trg-unit-cli as character
field trg-cli-base-rate as decimal
field trg-b-str as character
field trg-bc-on as logical
field v151-gds-code as integer
field v151-root-code as integer
field v151-b-code as integer
field v151-unit-base as character
field v151-unit-cli as character
field v151-cli-base-rate as decimal
field v151-b-str as character
field v151-bc-on as logical
field old-v151-bind as character
field old-v151-gds as character
field old-v151-unit-cli as character
field old-v151-cli-base-rate as character
field old-v151-bc-on as character
field correct-pbc-bind as character
index pi is unique primary
v151-gds-code
v151-b-code
v151-b-str
old-gds-code
old-b-code
old-b-str
index pisrc
src-gds-code
src-b-code
src-b-str
index pitrg
trg-gds-code
trg-b-code
trg-b-str
index pi15
v151-gds-code
v151-b-code
v151-b-str
index pi14
old-gds-code
old-b-code
old-b-str
index icor
correct-pbc-bind
.
define variable g#report-num as integer no-undo .
procedure OpenForExcel :
   define variable v-ch#ExcelApplication as com-handle no-undo .
   define variable v-ch#Workbook         as com-handle no-undo .
   define variable v-ch#Worksheet        as com-handle no-undo .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txt":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".frm":U ) .
   os-delete value( string( session:temp-directory ) +
                              "rpt" + string( g#report-num ) + ".txl":U ) .
   if Make-Excel
   then do:
      output stream ForExcel to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) + ".txt":U ) ) .
      assign
         v-excel-file = string( session:temp-directory + "rpt" + string( g#report-num ) )
         number-list = 1
      .
      if make-excel-com
      then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
         create "Excel.Application" ch#excelApplication connect no-error.
         if error-status:error
         then do :
        create "Excel.Application" ch#excelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
         end.
         assign
            num#str#  = 0.
            v-ch#excelApplication  = ch#excelApplication.
            v-ch#excelApplication:Interactive = false.
            v-ch#excelApplication:ScreenUpdating = false.
            v-ch#excelApplication:Visible = false.
            ch#Workbook  = v-ch#excelApplication:Workbooks:add ().
            ch#WorkSheet = v-ch#excelApplication:Sheets:Item (1).
            v-ch#Worksheet = ch#WorkSheet.
            v-ch#Worksheet:Range ("A1"):Font:Bold = true.
            v-ch#Worksheet:Range ("A1"):Font:Size = 14.
            v-ch#Worksheet:Range ("A1"):HorizontalAlignment = -4131.
            v-ch#Worksheet:Range ("A1"):VerticalAlignment   = -4160
         no-error .
         if error-status:error
         then do:
            Make-Excel-com = false .
            Make-Excel = false .
            output Stream  ForExcel close.
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".txt":U ) .
            os-delete value( string( session:temp-directory ) +
                           "rpt" + string( g#report-num ) + ".frm":U ) .
            return.
         end.
      end.
   end.
end.
procedure CloseForExcel :
   define variable ii as integer no-undo .
   define variable vsheet-num as integer no-undo.
   if Make-Excel
   then  do:
      output Stream  ForExcel close.
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".txt":U ) .
      os-delete value( string( session:temp-directory ) +
                             "rpt" + string( g#report-num ) + ".frm":U ) .
      define buffer buf_sheetf for sheetf.
      find last buf_sheetf no-error .
      if available buf_sheetf
      then
         vsheet-num = buf_sheetf.sheet-num.
      if vsheet-num > 1
      then do:
         do ii = 2 to vsheet-num:
            os-delete value( string( session:temp-directory ) +
                                  "rpt" + string( g#report-num ) + ".":U  + string(ii)) .
         end.
      end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#WorkSheet) then
RELEASE OBJECT ch#WorkSheet no-error.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#Workbook) then
RELEASE OBJECT ch#Workbook no-error.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#ExcelApplication) then
RELEASE OBJECT ch#ExcelApplication no-error.
   end.
end.
define variable sort-column-name as character no-undo.
define variable filter-point     as character NO-UNDO INIT "thth-gds".
define variable filter-label     as character NO-UNDO INIT "Соответствие товаров в разных TH".
define variable filter-point0     as character NO-UNDO INIT "thth-gds".
define variable filter-label0     as character NO-UNDO INIT "Соответствие товаров в разных TH".
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-doc-rec as recid no-undo .
DEFINE VARIABLE copy-option AS CHARACTER NO-UNDO.
define variable v-closed as character no-undo .
define variable v-type as character no-undo .
define variable v-attr-code as character no-undo .
define variable print-option as character no-undo .
define variable v-classif-name as character no-undo .
define variable v-cli-classif-name as character no-undo .
FUNCTION get-gds RETURNS LOGICAL ( INPUT p-uniq-key-rec AS character
    ,OUTPUT p-artic AS CHARACTER
    ,OUTPUT p-prodtypecode AS CHARACTER
    ,OUTPUT p-gds-name AS CHARACTER )  FORWARD.
DEFINE MENU MENU-b-copy
       MENU-ITEM m_one          LABEL "Текущий"
       MENU-ITEM m_list         LABEL "Отмеченные (только без соответствия)"
       MENU-ITEM m_all          LABEL "ВСЕ (только без соответствия)".
DEFINE MENU MENU-b-print
       MENU-ITEM m_print-list   LABEL "Список соответствий"
       MENU-ITEM m_print-report LABEL "Детализированный отчет (ТОЛЬКО EXCEL)".
DEFINE BUTTON b-close
     LABEL "Закр"
     SIZE 8 BY 1.
DEFINE BUTTON b-convert
     LABEL "Конвертация списка БАР-КОД~;ЦЕНА"
     SIZE 37 BY 1.
DEFINE BUTTON b-copy
     LABEL "Копировать из"
     SIZE 20 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-imp
     LABEL "Получ.соответствие"
     SIZE 20 BY 1 TOOLTIP "Получение соответствия данных по товарам системы TH".
DEFINE BUTTON b-imp-2
     LABEL "Подбор без проверки на производителя"
     SIZE 16.5 BY 1 TOOLTIP "Получение соответствия данных по товарам системы TH".
DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-print
     LABEL "&Печать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.
DEFINE BUTTON b-tie
     LABEL "Связать"
     SIZE 10 BY 1.
DEFINE BUTTON b-untie
     LABEL "Развязать"
     SIZE 10 BY 1.
DEFINE VARIABLE f-gds-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Назв.в БД"
     VIEW-AS FILL-IN
     SIZE 75 BY .93 NO-UNDO.
DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 6 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sch-old-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Поиск по коду"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE sch-self-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Поиск по коду v16.0"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE rs-key#_three AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", -1,
"В работе", 0,
"Сведенные ранее", 2,
"Были уже до upgrade", 1
     SIZE 59 BY 1 NO-UNDO.
DEFINE QUERY br-goods FOR X_ext-classif SCROLLING.
DEFINE BROWSE br-goods
  QUERY br-goods NO-LOCK DISPLAY
      mark-string(recid(X_ext-classif), v-rid-list) COLUMN-LABEL "" FORMAT "X(1)"
(X_ext-classif.KEY#_three  = 1) COLUMN-LABEL "До upg" FORMAT "+/"
(IF X_ext-classif.uniq-key-rec BEGINS 'goods':U
 THEN string(integer(entry(2, X_ext-classif.uniq-key-rec, chr(3))), ">>>>>>>>9")
ELSE ''
    ) COLUMN-LABEL "КОД ТОВАРА!v16.0" FORMAT "X(9)"
X_ext-classif.KEY#_one  COLUMN-LABEL "КОД ТОВАРА!" FORMAT ">>>>>>>>9"
X_ext-classif.charkey_one COLUMN-LABEL "Артикул!ТОВАРА" FORMAT "X(16)"
(X_ext-classif.charkey_two + string(X_ext-classif.KEY#_two))  COLUMN-LABEL "ПРОЗВ-ЛЬ ТОВАРА!" FORMAT "X(12)"
X_ext-classif.charkey_three COLUMN-LABEL "Название ТОВАРА в БД|Ед.изм" FORMAT "X(60)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 18.4 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11 WIDGET-ID 4
     B-sel AT ROW 1 COL 21 WIDGET-ID 6
     b-tie AT ROW 1 COL 31 WIDGET-ID 20
     b-copy AT ROW 1 COL 41 WIDGET-ID 22
     b-imp AT ROW 1 COL 61 WIDGET-ID 18
     b-close AT ROW 1 COL 81 WIDGET-ID 26
     b-sch AT ROW 1 COL 89 WIDGET-ID 12
     b-print AT ROW 1 COL 92 WIDGET-ID 10
     B-Help AT ROW 1 COL 95
     rs-key#_three AT ROW 2 COL 1.5 NO-LABEL WIDGET-ID 30
     b-convert AT ROW 2 COL 61 WIDGET-ID 42
     b-imp-2 AT ROW 2 COL 81 WIDGET-ID 28
     sch-old-code AT ROW 3 COL 28 COLON-ALIGNED WIDGET-ID 36
     b-untie AT ROW 3 COL 42.5 WIDGET-ID 40
     sch-self-code AT ROW 3 COL 75 COLON-ALIGNED WIDGET-ID 38
     br-goods AT ROW 4 COL 1 WIDGET-ID 100
     f-gds-name AT ROW 22.33 COL 8 WIDGET-ID 24
     mark-num AT ROW 1 COL 12.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     SPACE(79.30) SKIP(21.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-copy:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-copy:HANDLE.
ASSIGN
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-b-print:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-close IN FRAME Dialog-Frame
DO:
  RUN proc-close IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN UNDO, RETURN NO-APPLY.
END.
ON CHOOSE OF b-convert IN FRAME Dialog-Frame
DO:
  RUN proc-convert-mob-scan IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-copy IN FRAME Dialog-Frame
DO:
  if copy-option = "":U then do:
    run gbl/pop-up.p ( input self :handle, input no ) no-error.
    if error-status :error then do: return no-apply. end.
  end.
  if copy-option = "":U then do:
      return no-apply.
  end.
  RUN proc-copy IN THIS-PROCEDURE ( INPUT copy-option) NO-ERROR.
  copy-option = ''.
  APPLY "entry" TO br-goods.
END.
ON CHOOSE OF b-imp IN FRAME Dialog-Frame
DO:
  RUN proc-imp IN THIS-PROCEDURE ( INPUT 1) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-imp-2 IN FRAME Dialog-Frame
DO:
  RUN proc-imp IN THIS-PROCEDURE ( INPUT 2) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
  define variable loc#log as logical no-undo .
  if available X_ext-classif then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid32 as character no-undo .
define variable v-num-entry32 as integer   no-undo .
assign
  v-str-recid32 = trim( string( recid( X_ext-classif ) , "->>>>>>>>>>>9":U ) )
  v-num-entry32 = lookup( v-str-recid32 , v-rid-list )
.
if v-num-entry32 > 0 then do:
  assign
    entry( v-num-entry32, v-rid-list ) = "":U
    v-rid-list = trim( replace( v-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else chr(44) ) + v-str-recid32
  .
end.
    loc#log = br-goods:refresh() .
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = br-goods:select-next-row ().
        apply "VALUE-CHANGED" to br-goods in frame Dialog-Frame.
    end.
    if num-entries( v-rid-list ) = 0
    then
        hide mark-num in frame Dialog-Frame.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame Dialog-Frame.
  end.
  apply "entry" to br-goods in frame Dialog-Frame.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
  if print-option = '':U then do:
    run gbl/pop-up.p ( input self:handle, input no) no-error.
  end.
  if print-option = '':U then return no-apply.
  CASE Print-OPTION:
    WHEN "REPORT" THEN DO:
      RUN PROC-REPORT IN THIS-PROCEDURE NO-ERROR.
    END.
    WHEN "LIST" THEN DO:
      run proc-b-print in this-procedure no-error.
    END.
  END CASE.
  print-option = "".
  APPLY "ENTRY" to br-goods.
  return no-apply.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
  run proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available X_ext-classif ) then do:
    if  ( v-rid-list = "" ) or b-mark:sensitive = no
    then
    v-rid-list = string( recid( X_ext-classif ) ) .
  end.
END.
ON CHOOSE OF b-tie IN FRAME Dialog-Frame
DO:
  if not available X_ext-classif then return no-apply.
  RUN proc-b-tie IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-untie IN FRAME Dialog-Frame
DO:
  if not available X_ext-classif then return no-apply.
  RUN proc-b-untie IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF br-goods IN FRAME Dialog-Frame
DO:
 DEFINE VARIABLE v-gds-name AS CHARACTER NO-UNDO.
 DEFINE VARIABLE v-artic AS CHARACTER NO-UNDO.
 DEFINE VARIABLE v-prodtypecode AS CHARACTER NO-UNDO.
 DEFINE VARIABLE glog AS logical NO-UNDO.
 IF AVAILABLE X_ext-classif
 and X_ext-classif.uniq-key-rec <> ''
 THEN DO:
    glog = get-gds (INPUT X_ext-classif.uniq-key-rec, OUTPUT v-artic, OUTPUT v-prodtypecode, OUTPUT v-gds-name ) .
  END.
  ELSE DO:
     v-gds-name = ''.
  END.
  f-gds-name:SCREEN-VALUE = v-gds-name.
END.
ON CHOOSE OF MENU-ITEM m_all
DO:
  ASSIGN
  copy-option = "all".
  APPLY "CHOOSE" TO b-copy IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_list
DO:
  IF v-rid-list = '' THEN do:
     MESSAGE
     "Нет выбранных записей"
     VIEW-AS ALERT-BOX .
     RETURN NO-APPLY.
  END.
  ASSIGN
  copy-option = "list".
  APPLY "choose" TO b-copy IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_one
DO:
  IF NOT AVAILABLE X_ext-classif THEN RETURN NO-APPLY.
  ASSIGN
  copy-option = "one".
  APPLY "CHOOSE" TO b-copy IN FRAME Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_print-list
DO:
  assign
  print-option = 'LIST':U.
  APPLY "CHOOSE" to b-print  in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m_print-report
DO:
  assign
  print-option = 'report':U.
  APPLY "CHOOSE" to b-print  in frame Dialog-Frame.
END.
ON VALUE-CHANGED OF rs-key#_three IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-key#_three .
  if available X_ext-classif then v-doc-rec = recid(X_ext-classif).
  run openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U) no-error.
  reposition br-goods to recid(v-doc-rec) no-error.
  APPLy 'ENTRY' to br-goods .
  APPLY "VALUE-CHANGED" to br-goods.
END.
ON RETURN OF sch-old-code IN FRAME Dialog-Frame
DO:
  run proc-find-old-code in this-procedure ( input no, input frame Dialog-Frame sch-old-code) no-error.
  if error-status:error then return no-apply.
END.
ON RETURN OF sch-self-code IN FRAME Dialog-Frame
DO:
  run proc-find-self-code in this-procedure ( input no, input frame Dialog-Frame sch-self-code) no-error.
  if error-status:error then return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-goods :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-P, CTRL-З of frame Dialog-Frame anywhere do:
  if b-print :sensitive then DO: apply "CHOOSE":U to b-print in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-sel :sensitive then DO: apply "CHOOSE":U to b-sel in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
ON ROW-DISPLAY OF br-goods IN frame Dialog-Frame
DO:
  IF AVAIL X_ext-classif THEN DO:
    RUN set-row-color.
  END.
END.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  if available X_ext-classif then v-doc-rec = recid(X_ext-classif). run openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U) no-error. reposition br-goods to recid(v-doc-rec) no-error. APPLy 'ENTRY' to br-goods .
    apply "VALUE-CHANGED" to br-goods.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  v-rid-list = p-rid-list.
  case p-from-version:
    when 'v15_0000':U then do:
      v-classif-name = 'th-th150_goods':U.
      v-cli-classif-name = 'th-th150_clients':U.
      v-attr-code = 'thth150-goods':U.
      run thth150-db-attr-value in this-procedure ( input g#db-num
                                                ,input v-attr-code
                                                ,output v-closed
                                                ,output v-type) .
    end.
    when 'v14_0':U then do:
      v-classif-name = 'th-th14_goods':U.
      v-cli-classif-name = 'th-th14_clients':U.
      v-attr-code = 'thth14-goods':U.
      run thth14-db-attr-value in this-procedure ( input g#db-num
                                                ,input v-attr-code
                                                ,output v-closed
                                                ,output v-type) .
    end.
    otherwise do:
      message
      substitute("Неверное значение параметра p-from-version=&1", p-from-version)
      view-as alert-box error .
      undo main-block, return error .
    end.
  end case.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-key#_three sch-old-code sch-self-code f-gds-name mark-num
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel b-tie b-copy b-imp b-close b-sch b-print B-Help
         rs-key#_three b-convert b-imp-2 sch-old-code b-untie sch-self-code
         br-goods f-gds-name mark-num
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-goods FOR EACH X_ext-classif NO-LOCK OUTER-JOIN INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-prod-h as handle no-undo .
v-prod-h = br-goods:FIRST-COLUMN IN FRAME Dialog-Frame.
DO while valid-handle(v-prod-h) :
  if v-prod-h:LABEL = "ПРОЗВ-ЛЬ ТОВАРА!" then do:
    leave.
  end.
  ELSE DO:
    v-prod-h = v-prod-h:NEXT-COLUMN.
  END.
END.
assign
b-copy:label in frame Dialog-Frame = substitute("&1 &2"
                                                  , b-copy:label in frame Dialog-Frame
                                                  , p-from-version)
b-imp:tooltip in frame Dialog-Frame = substitute("&1 &2"
                                                  , b-imp:tooltip in frame Dialog-Frame
                                                  , p-from-version)
b-imp-2:tooltip in frame Dialog-Frame = substitute("&1 &2"
                                                  , b-imp-2:tooltip in frame Dialog-Frame
                                                  , p-from-version)
f-gds-name:label in frame Dialog-Frame = substitute("&1 &2"
                                                  , f-gds-name:label in frame Dialog-Frame
                                                  , p-from-version)
sch-old-code:label in frame Dialog-Frame = substitute("&1 &2"
                                                  , sch-old-code:label in frame Dialog-Frame
                                                  , p-from-version)
X_ext-classif.KEY#_one:LABEL  in browse br-goods = substitute("&1 &2"
                                                            , X_ext-classif.KEY#_one:LABEL  in browse br-goods
                                                            ,p-from-version)
X_ext-classif.charkey_one:LABEL  in browse br-goods = substitute("&1 &2"
                                                            , X_ext-classif.charKEY_one:LABEL  in browse br-goods
                                                            ,p-from-version)
X_ext-classif.charkey_three:LABEL  in browse br-goods = substitute("&1 &2"
                                                            , X_ext-classif.charKEY_three:LABEL  in browse br-goods
                                                            ,p-from-version)
v-prod-h:label  = substitute("&1 &2"
                                    , v-prod-h:label
                                    , p-from-version)
.
assign
b-copy:menu-mouse in frame Dialog-Frame = 1
b-print:menu-mouse in frame Dialog-Frame = 1
rs-key#_three = 0
X_ext-classif.charkey_three:resizable in browse br-goods = yes
.
display
rs-key#_three
with frame Dialog-Frame .
ENABLE
b-quit
b-print
b-mark
b-imp when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)
b-tie when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)
b-untie when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no)
b-close when (v-cntxt-db-num = 0 and lookup("b-add", bttns) > 0 and not transaction and logical(v-closed) = no )
b-convert when v-cntxt-db-num = 0
b-sch
B-Help
br-goods
rs-key#_three
sch-old-code
sch-self-code
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
hide
b-imp-2
in frame Dialog-Frame .
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
APPLy "entry" to br-goods.
APPLY "VALUE-CHANGED" to br-goods.
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
filter-point = filter-point0 + p-list-mode .
title0 = "Соответствие товаров в разных системах TH".
ASSIGN
frame Dialog-Frame:title = substitute("&1", title0)
filter-label = SUBSTITUTE("&1"
                          , frame Dialog-Frame:title
                          )
.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-44  as logical   no-undo .
define variable  l-filter-open-44    as logical   .
define variable  flt-rec-44       as recid     no-undo .
define variable  filter-name-44      as character no-undo .
define variable  where-phrase-44     as character no-undo .
define variable  sort-phrase-44      as character no-undo .
define variable  where-phrase-rus-44 as character no-undo .
define variable  sort-phrase-rus-44  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-44
  ,output filter-name-44
  ,output where-phrase-44
  ,output sort-phrase-44
  ,output where-phrase-rus-44
  ,output sort-phrase-rus-44
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-44
      ) no-error .
  assign
    l-filter-open-44 = false
  .
  if flt-rec-44 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-44 as character no-undo .
    define variable  parameter-3-44 as character no-undo .
    define variable  parameter-4-44 as character no-undo .
    define variable  parameter-5-44 as character no-undo .
    define variable  parameter-6-44 as character no-undo .
    define variable  parameter-7-44 as character no-undo .
      assign
      parameter-3-44 =
                              "FOR EACH X_ext-classif no-lock"
      parameter-4-44 =
        (
          if (" X_ext-classif.classif-subject = 'goods':U                         and X_ext-classif.classif-name = v-classif-name                         AND X_ext-classif.db-num = - 1                         and (rs-key#_three = -1  or X_ext-classif.key#_three = rs-key#_three)                         " + " " + where-phrase-44) <> ""
          then  substitute('X_ext-classif.classif-subject = &1&2&1                         and X_ext-classif.classif-name = &1&3&1                         AND X_ext-classif.db-num = - 1                        and (&4 = -1  or X_ext-classif.key#_three = &4)                         ', chr(34), 'goods':U, v-classif-name, rs-key#_three) + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "")
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_ext-classif.charkey_three "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " INDEXED-REPOSITION  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-44 =
          (" X_ext-classif.classif-subject = 'goods':U                         and X_ext-classif.classif-name = v-classif-name                         AND X_ext-classif.db-num = - 1                         and (rs-key#_three = -1  or X_ext-classif.key#_three = rs-key#_three)                         " + " " + where-phrase-44 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input QUERY br-goods:handle
                          ,input parameter-3-44
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ,input parameter-6-44
                          ,input parameter-7-44
                          )
      .
      assign
        l-filter-open-44 = true
      .
    end.
    if l-filter-open-44 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-44 = false then do:
    OPEN QUERY br-goods FOR EACH X_ext-classif no-lock
      where  X_ext-classif.classif-subject = 'goods':U                         and X_ext-classif.classif-name = v-classif-name                         AND X_ext-classif.db-num = - 1                         and (rs-key#_three = -1  or X_ext-classif.key#_three = rs-key#_three)
       BY X_ext-classif.charkey_three
      INDEXED-REPOSITION
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-doc-rec = recid( X_ext-classif )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if QUERY br-goods:handle:get-buffer-handle(1) = (buffer X_ext-classif:handle) then do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-4-44 =
        "where ":u +  substitute('X_ext-classif.classif-subject = &1&2&1                         and X_ext-classif.classif-name = &1&3&1                         AND X_ext-classif.db-num = - 1                        and (&4 = -1  or X_ext-classif.key#_three = &4)                         ', chr(34), 'goods':U, v-classif-name, rs-key#_three) + " ":u + where-phrase-44 + " ":u + p-find-condition + " " + ""
      parameter-5-44 = "  "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-goods:handle
                          ,input rowid(X_ext-classif)
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input (buffer X_ext-classif:handle)
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ) no-error.
      .
      assign
        v-doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-44 = (if p-find-next then "true":u else "false":u )
      parameter-3-44 =  "FOR EACH X_ext-classif no-lock"
      parameter-4-44 =
        (
          if (" X_ext-classif.classif-subject = 'goods':U                         and X_ext-classif.classif-name = v-classif-name                         AND X_ext-classif.db-num = - 1                         and (rs-key#_three = -1  or X_ext-classif.key#_three = rs-key#_three)                         " + " " + where-phrase-44) <> ""
          then  substitute('X_ext-classif.classif-subject = &1&2&1                         and X_ext-classif.classif-name = &1&3&1                         AND X_ext-classif.db-num = - 1                        and (&4 = -1  or X_ext-classif.key#_three = &4)                         ', chr(34), 'goods':U, v-classif-name, rs-key#_three) + " " + where-phrase-44
          else "true"
        )
      parameter-5-44 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-44 = if sort-phrase-44 = ''
                           then
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + " BY X_ext-classif.charkey_three "
        )
                           else
        (
        " " + "  " +
          " " + sort-column-phrase +
        " " + sort-phrase-44
        )
      parameter-7-44 =
        " INDEXED-REPOSITION  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input QUERY br-goods:handle
                          ,input logical(parameter-2-44)
                          ,input no-lock
                          ,input parameter-3-44
                          ,input parameter-4-44
                          ,input parameter-5-44
                          ,input parameter-6-44
                          ,input parameter-7-44
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
if not p-open-query and v-doc-rec <> ? then
REPOSITION br-goods to recid v-doc-rec No-ERROR.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-goods:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO br-goods in frame Dialog-Frame.
APPLY "ENTRY" TO br-goods.
END PROCEDURE.
PROCEDURE proc-b-print :
DEFINE VARIABLE date_string              as   character no-undo .
DEFINE VARIABLE Line                     as   character no-undo .
DEFINE VARIABLE for-time                 as   character no-undo .
DEFINE VARIABLE accum-count              as   integer   no-undo .
DEFINE VARIABLE accum-count2             as   integer   no-undo .
define variable v-rid                    as   recid no-undo .
define variable v-self-gds-code as character no-undo .
define variable v-self-gds-name as character no-undo .
define variable v-self-artic as character no-undo .
define variable v-self-prodtypecode as character no-undo .
define variable v-alien-prodtypecode as character no-undo .
define variable glog as logical no-undo .
define variable v-old-good as logical no-undo .
DEFINE FRAME list1
v-self-gds-code COLUMN-LABEL "Код ТОВАРА!v16.0" FORMAT "X(9)"
v-self-artic COLUMN-LABEL "Артикул ТОВАРА!v16.0" FORMAT "X(16)"
v-self-prodtypecode COLUMN-LABEL "Произв-ль ТОВАРА!v16.0" FORMAT "X(12)"
v-self-gds-name COLUMN-LABEL "НАЗВАНИЕ ТОВАРА!v16.0" FORMAT "X(60)"
v-old-good COLUMN-LABEL "До upg" FORMAT "+/-"
X_ext-classif.key#_one COLUMN-LABEL "Код ТОВАРА!старой версии" FORMAT ">>>>>>>>9"
X_ext-classif.charkey_one COLUMN-LABEL "Артикул ТОВАРА!старой версии" FORMAT "X(16)"
v-alien-prodtypecode COLUMN-LABEL "Произв-ль ТОВАРА!старой версии" FORMAT "X(12)"
X_ext-classif.charkey_three COLUMN-LABEL "Название ТОВАРА|Ед.изм!старой версии" FORMAT "X(60)"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 75 PAGE-NUMBER(PrnLibStream) AT 85 FORMAT ">>9" SKIP
Line format "X(198)" AT 1
with width 232 down stream-io use-text    .
Line = fill("-", 198).
date_string = cur-time-print() .
run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input 43
                                            ,input yes
                                            ,input no
                                            ).
PUT  STREAM PrnLibStream
SPACE(25) ( frame Dialog-Frame:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line format "X(198)" AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width 232 PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .
v-rid = recid(X_ext-classif).
FORM with FRAME List1.
run waitfram-show in this-procedure ( input "Ждите...").
DO WHILE available X_ext-classif :
   GET prev br-goods.
END.
GET next br-goods.
DO WHILE available X_ext-classif :
  if X_ext-classif.uniq-key-rec BEGINS 'goods':U then do:
    glog = get-gds(X_ext-classif.uniq-key-rec, output v-self-artic, output v-self-prodtypecode, output v-self-gds-name).
  end.
  if not glog then do:
    assign
    v-self-artic = ''
    v-self-prodtypecode = ''
    v-self-gds-name = ''
  v-self-gds-code = ''
    .
  end.
  Display STREAM PrnLibStream
  (if X_ext-classif.uniq-key-rec BEGINS 'goods':U
  then entry(2, X_ext-classif.uniq-key-rec, chr(3))
  else '') @ v-self-gds-code
  (X_ext-classif.key#_three = 1) @ v-old-good
  v-self-artic
  v-self-prodtypecode
  v-self-gds-name
  X_ext-classif.key#_one
  X_ext-classif.charkey_one
  (X_ext-classif.charkey_two + string(X_ext-classif.key#_two)) @ v-alien-prodtypecode
  X_ext-classif.charkey_three
  with FRAME List1.
  DOWN STREAM PrnLibStream
  1
  with FRAME List1.
  assign
  accum-count = accum-count + 1
  .
  if X_ext-classif.uniq-key-rec <> '' then do:
    accum-count2 = accum-count2 + 1.
  end.
  GET next br-goods.
END.
UNDERLINE  STREAM PrnLibStream
v-self-gds-code
X_ext-classif.key#_one
with FRAME List1.
DISPLAY STREAM PrnLibStream
accum-count2 @ v-self-gds-code
accum-count @ X_ext-classif.key#_one
with frame List1.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME List1.
output  STREAM PrnLibStream CLOSE.
reposition br-goods to recid v-rid no-error .
apply "ENTRY" to br-goods in frame Dialog-Frame .
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).
END PROCEDURE.
PROCEDURE proc-b-sch :
define variable v-ri as recid no-undo .
assign
v-ri = (if avail X_ext-classif then recid(X_ext-classif) else ?)
.
assign
tbl = 'ext-classif':U
join-tbl = 'X_ext-classif'
fld = ""
lab = ""
spr = ""
dim = '0'
.
run fltfield-add in this-procedure('key#_one', substitute('Код товара &1', p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_two', substitute('Тип Производителя товара &1', p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('key#_two', substitute('Код Производителя товара &1', p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_one', substitute("Артикул товара &1", p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('charkey_three', substitute('Название товара|Ед.изм!&1', p-from-version), '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('uniq-key-rec', 'Уникальный ключ записи в БД v16.0', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
DO on stop undo, leave:
    run gbl/filter.w ( INPUT parparentproc
                 ,INPUT filter-point + chr(4) + filter-label
                 ,INPUT tbl
                 ,INPUT join-tbl
                 ,INPUT fld
                 ,INput lab
                 ,INPUT spr
                 ,INPUT  dim).
    run OpenBr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
    if v-ri <> ? then do:
      reposition br-goods to recid v-ri no-error.
    end.
    APPLY "ENTRY" to br-goods in frame Dialog-Frame .
    APPLY "VALUE-CHANGED" to br-goods.
END .
END PROCEDURE.
PROCEDURE proc-b-tie :
define variable v-rid-list as character no-undo .
define variable glog as logical no-undo .
define variable v-rec as recid no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-clients-uniq-key-rec as character no-undo .
define variable v-recid as recid  no-undo .
define variable v-ok as logical no-undo .
define variable v-old-uniq-key-rec as character no-undo .
define buffer buf_goods for ub.goods.
define buffer clients_ext-classif for ub.ext-classif.
define buffer buf_clients for ub.clients.
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
if X_ext-classif.uniq-key-rec <> ''
and X_ext-classif.key#_three = 1
then do:
  message
  "Данное соответствие установлено в процессе upgrade - ТОВАР ССЫЛАЕТСЯ САМ НА СЕБЯ - перепривязать НЕВОЗМОЖНО"
  view-as alert-box error .
  undo, return error .
end.
if X_ext-classif.uniq-key-rec <> ''
and X_ext-classif.key#_three = 2
then do:
  message
  "Данное соответствие установлено в процессе сведения объектов РАНЕЕ - перепривязать НЕВОЗМОЖНО"
  view-as alert-box error .
  undo, return error .
end.
if X_ext-classif.uniq-key-rec <> '' then do:
  v-old-uniq-key-rec = X_ext-classif.uniq-key-rec.
  message
  substitute("Уже есть соответствие  между данными товара &1 в БД v16.0 и этим же товаром в БД &3&2" +
            "Вы УВЕРЕНЫ, что хотите их изменить?"
            , entry(2, X_ext-classif.uniq-key-rec, chr(3))
            , chr(10)
            , p-from-version)
  view-as alert-box question buttons yes-no update glog.
  if not glog then return no-apply.
  find first buf_goods no-lock where
          buf_goods.gds-code = integer(entry(2, X_ext-classif.uniq-key-rec, chr(3)))   .
  v-rid-list = string(recid(buf_goods)).
end.
find first clients_ext-classif share-lock where
          clients_ext-classif.classif-subject  = 'clients':U
      and  clients_ext-classif.classif-name  = v-cli-classif-name
      and clients_ext-classif.db-num = -1
      and clients_ext-classif.charkey_one = X_ext-classif.charkey_two
      and clients_ext-classif.key#_one = X_ext-classif.key#_two     no-error .
if not available clients_ext-classif then do:
  message
  substitute("Не НАЙДЕНА запись соответствия для производителя  &1&2 товара с кодом &3 в БД &5&4" +
            "Связать НЕВОЗМОЖНО"
            ,X_ext-classif.charkey_two
            ,X_ext-classif.key#_two
            ,X_ext-classif.key#_one
            ,chr(10)
            , p-from-version
            )
  view-as alert-box error .
  undo, return error .
end.
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT clients_ext-classif.uniq-key-rec
                                    ,input ?
                                    ,INPUT "ub"
                                    ,INPUT ?
                                    ,INPUT NO-LOCK
                                    ,OUTPUT v-rowid
                                    ,OUTPUT v-tbl-name) no-error.
if error-status:error then do:
  message
  substitute("Ошибка при определении записи соответствия для производителя  &1&2 товара с кодом &3 в БД &5&4" +
            "Связать НЕВОЗМОЖНО"
            ,X_ext-classif.charkey_two
            ,X_ext-classif.key#_two
            ,X_ext-classif.key#_one
            ,chr(10)
            , p-from-version
            )
  view-as alert-box error .
  undo, return error .
end.
find first buf_clients no-lock where rowid(buf_clients) = v-rowid.
run ref/gds-ref.p (
                 input parparentproc
                ,input "b-sel,b-add"
                ,input ?
                ,input 'Производитель':U
                ,input ?
                ,input (if available buf_goods then recid(buf_goods) else ?)
                ,input ?
                ,input buf_clients.obj-type
                ,input buf_clients.obj-code
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input ?
                ,output v-rID-list).
if v-rid-list = '':U then return no-apply.
find first buf_goods where recid (buf_goods) = integer (v-rid-list) no-lock no-error.
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к БД TH &4&1&2&1&3"
             , chr(10)
             , error-status:get-message(1)
             , return-value
             , p-from-version)
  view-as alert-box error .
  return error .
end.
run str/diallog.w ( input parparentproc
          , input this-procedure
          , input 'cmp/ththgdse.p':U
          , input (string(buf_goods.gds-code) + chr(4) +
                   string(X_ext-classif.key#_one) + chr(4) +
                   p-from-version
                   )
          , input no
          , input ''
          , input 'Связывание данных по товарам') no-error .
if connected ("src") then do:
  disconnect src.
end.
find first buf_ext-classif no-lock where
          recid(buf_ext-classif) = recid(X_ext-classif).
if X_ext-classif.uniq-key-rec <> v-old-uniq-key-rec then do:
  assign
  v-recid = recid(X_ext-classif).
  run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
  reposition  br-goods to recid v-recid no-error.
  APPLY "entry" to br-goods in frame Dialog-Frame .
  apply "value-changed" to br-goods.
end.
END PROCEDURE.
PROCEDURE proc-b-untie :
define variable glog as logical no-undo .
define variable v-recid as recid no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
DEFINE buffer buf_goods for ub.goods.
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
FIND FIRST buf_ext-classif EXCLUSIVE-LOCK WHERE
          recid(buf_ext-classif) = RECID(X_ext-classif) .
IF buf_ext-classif.uniq-key-rec = '' THEN DO:
   MESSAGE
   substitute("товаром с кодом &1 (&2 &3 &4) в &5 версии НЕ ИМЕЕТ СООТВЕТСТВИЯ ТОВАРУ 16.0 версии&6" +
              "Нечего отвязывать!!!"
              ,buf_ext-classif.key#_one
              ,buf_ext-classif.charkey_one
              ,(buf_ext-classif.charkey_two + STRING(buf_ext-classif.key#_two))
              ,buf_ext-classif.charkey_three
              ,p-from-version
              ,chr(10)
               )
  VIEW-AS ALERT-BOX warning.
  return "return".
END.
if buf_ext-classif.key#_three <> 0 then do:  message
  "Данный товар был уже сведен ранее/или до upgrade" skip
  "Удалить соответствие невозможно "
  view-as alert-box error .
  undo, return error.
end.
run gen-row-keyr in this-procedure (
  input  buf_ext-classif.uniq-key-rec
  ,input  ?
  ,input  "ub"
  ,input  ?
  ,input  no-lock
  ,output v-tbl-row
  ,output v-tbl-name   ).
find first buf_goods no-lock where
          rowid(buf_goods) = v-tbl-row.
MESSAGE
substitute("Вы уверены, что хотите удалить соответствие между &5" +
           "товаром с кодом &1 (&2 &3 &4) в старой версии&5" +
           "товаром с кодом &6 (&7 &8 &9) в 16.0 версии&5"  +
           "?????"
           ,buf_ext-classif.key#_one
           ,buf_ext-classif.charkey_one
           ,(buf_ext-classif.charkey_two + STRING(buf_ext-classif.key#_two))
            ,buf_ext-classif.charkey_three
             ,chr(10)
            ,buf_goods.gds-code
            ,buf_goods.artic
            ,buf_goods.prod-type + STRING(buf_goods.prod-code)
            ,buf_goods.gds-name + chr(4) + buf_goods.unit-base
             )
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN RETURN 'return'.
assign
buf_ext-classif.uniq-key-rec = ''.
v-recid = recid(buf_ext-classif).
run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
reposition  br-goods to recid v-recid no-error.
APPLY "entry" to br-goods in frame Dialog-Frame .
apply "value-changed" to br-goods.
END PROCEDURE.
PROCEDURE proc-close :
define variable v-loc-closed as character no-undo .
define variable glog as logical no-undo .
define buffer buf_ext-classif for ub.ext-classif.
case p-from-version:
  when 'v15_0000':U then do:
    run thth150-db-attr-value in this-procedure ( input g#db-num
                                              ,input v-attr-code
                                              ,output v-loc-closed
                                              ,output v-type) .
  end.
  when 'v14_0':U then do:
    run thth14-db-attr-value in this-procedure ( input g#db-num
                                              ,input v-attr-code
                                              ,output v-loc-closed
                                              ,output v-type) .
  end.
end case.
if logical(v-loc-closed) then do:
  message
  "Уже завершен этап УСТАНОВКИ СООТВЕТСТВИЯ ДАННЫХ ПО ТОВАРАМ в разных системах IBS TH"
  view-as alert-box error .
  undo, return error .
end.
message
"Вы уверены, что Вы полностью установили СООТВЕТСТВИЕ ДАННЫХ ПО ТОВАРАМ в разных системах IBS TH?"
view-as alert-box question buttons yes-no update glog.
if not glog then undo, return .
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'goods':U
      and buf_ext-classif.classif-name = v-classif-name
      AND buf_ext-classif.db-num = - 1
      and buf_ext-classif.uniq-key-rec = ''
      no-error.
if available buf_ext-classif then do:
  message
  substitute("ИМЕЕТСЯ запись по товару в БД &1, которой не соответствует ни один ТОВАР БД v16.0", p-from-version) skip
  "Закрытие этапа НЕВОЗМОЖНО"
  view-as alert-box error .
  undo, return error .
end.
main-block:
do transaction:
  for each buf_ext-classif where
          buf_ext-classif.classif-subject = 'goods':U
      and buf_ext-classif.classif-name = v-classif-name
      AND buf_ext-classif.db-num = - 1
      AND buf_ext-classif.key#_three = 0
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
    buf_ext-classif.key#_three = 2
    .
  end.
  case p-from-version:
    when 'v15_0000':U then do:
      run thth150-db-attr-write in this-procedure (
                                                input g#db-num
                                                ,input v-attr-code
                                                ,input string(yes)).
    end.
    when 'v14_0':U then do:
      run thth14-db-attr-write in this-procedure (
                                                input g#db-num
                                                ,input v-attr-code
                                                ,input string(yes)).
    end.
  end case.
end.
v-loc-closed = ''.
case p-from-version:
  when 'v15_0000':U then do:
    run thth150-db-attr-value in this-procedure ( input g#db-num
                                              ,input v-attr-code
                                              ,output v-loc-closed
                                              ,output v-type) .
  end.
  when 'v14_0':U then do:
    run thth14-db-attr-value in this-procedure ( input g#db-num
                                              ,input v-attr-code
                                              ,output v-loc-closed
                                              ,output v-type) .
  end.
end case.
if logical(v-loc-closed) = yes then do:
  disable
  b-close
  with frame Dialog-Frame .
  if available X_ext-classif then v-doc-rec = recid(X_ext-classif).
  run openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U) no-error.
  reposition br-goods to recid(v-doc-rec) no-error. APPLy 'ENTRY' to br-goods .
end.
END PROCEDURE.
PROCEDURE proc-convert-mob-scan :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к БД TH &4&1&2&1&3"
             , chr(10)
             , error-status:get-message(1)
             , return-value
             , p-from-version)
  view-as alert-box error .
  return error .
end.
run str/diallog.w ( input parparentproc
          , input this-procedure
          , input 'cmp/ththgdsc.p':U
          , input p-from-version
          , input no
          , input ''
          , input substitute('Конвертация файла БАР-КОД;ЦЕНА с кодами из &1', p-from-version)) no-error .
if connected ("src") then do:
  disconnect src.
end.
END PROCEDURE.
PROCEDURE proc-copy :
DEFINE INPUT PARAMETER p-copy-option AS CHARACTER NO-UNDO.
define variable v-ok as logical no-undo .
define variable v-recid as recid no-undo .
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к БД TH &4&1&2&1&3"
             , chr(10)
             , error-status:get-message(1)
             , return-value
             , p-from-version
             )
  view-as alert-box error .
  return error .
end.
run str/diallog.w ( input parparentproc
          , input this-procedure
          , input 'cmp/ththgdst.p':U
          , input (p-copy-option + chr(4) +
                  (if p-copy-option = 'one'
                  then string(X_ext-classif.key#_one)
                  else '') + chr(4) +
                  (if p-copy-option = 'list'
                  then v-rid-list
                  else '') + chr(4) +
                  p-from-version)
          , input yes
          , input ''
          , input substitute('Копирование данных по товарам из БД &1 во временную таблицу', p-from-version)) no-error .
if connected ("src") then do:
  disconnect src.
end.
if can-find (first goods-01) then do:
  run str/diallog.w ( input parparentproc
            , input this-procedure
            , input 'cmp/ththgdss.p':U
            , input p-from-version
            , input no
            , input ''
            , input 'Сохранение данных по товарам в БД v16.0') no-error .
end.
else do:
  message
  "Нет записей во временной таблице - НЕЧЕГО СОХРАНЯТЬ"
  view-as alert-box .
end.
assign
v-recid = recid(X_ext-classif).
run Openbr in this-procedure ( INPUT YES, INPUT NO, INPUT '':U).
reposition  br-goods to recid v-recid no-error.
APPLY "entry" to br-goods in frame Dialog-Frame .
apply "value-changed" to br-goods.
END PROCEDURE.
PROCEDURE proc-find-old-code :
define input parameter p-next as logical no-undo.
define input parameter p-old-code AS INTEGER no-undo.
DEFINE VARIABLE v-old-code AS CHARACTER NO-UNDO.
assign
sch-self-code = 0
.
display
0 @ sch-self-code
with frame Dialog-Frame.
assign
v-old-code = string(p-old-code).
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute(" and X_ext-classif.key#_one = &1 "
      , v-old-code)
    ).
apply "entry":u to sch-old-code in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-find-self-code :
define input parameter p-next as logical no-undo.
define input parameter p-self-code AS INTEGER no-undo.
assign
sch-old-code = 0
.
display
0 @ sch-old-code
with frame Dialog-Frame.
run OpenBr in this-procedure
    (input false
    ,input p-next
    ,input substitute(" and X_ext-classif.uniq-key-rec = &1&2&3&4&1 "
                      , chr(34)
                      , 'goods':U
                      , chr(3)
                      , p-self-code)
    ).
END PROCEDURE.
PROCEDURE proc-imp :
DEFINE INPUT PARAMETER p-imp-version AS INTEGER NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
CASE p-imp-version:
    WHEN 1 THEN DO:
        FIND FIRST buf_ext-classif NO-LOCK WHERE
                buf_ext-classif.classif-subject = 'goods':U
            and buf_ext-classif.classif-name = v-classif-name
            AND buf_ext-classif.db-num = - 1
            and buf_ext-classif.key#_three = 0
            NO-ERROR.
        IF NOT AVAILABLE buf_ext-classif THEN DO:
          MESSAGE
          substitute("Вы действительно хотите получить соответствие данных по товарам системы TH &1?", p-from-version)
           VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
          IF NOT glog  THEN RETURN NO-APPLY.
        END.
        ELSE DO:
          MESSAGE
          substitute("У Вас уже есть закачанные соответствия по товарам системы TH &1", p-from-version) SKIP
          "Повторный импорт УНИЧТОЖИТ ВСЕ СООТВЕТСТВИЕ УСТАНОВЛЕННЫЕ ПОСЛЕ upgrade" SKIP
          substitute("Вы действительно хотите вкачать соответствия по товарам системы TH &1?", p-from-version)
           VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
          IF NOT glog  THEN RETURN NO-APPLY.
        END.
    END.
    WHEN 2 THEN DO:
        FIND FIRST buf_ext-classif NO-LOCK WHERE
                buf_ext-classif.classif-subject = 'goods':U
            and buf_ext-classif.classif-name = v-classif-name
            AND buf_ext-classif.db-num = - 1
            and buf_ext-classif.key#_three = 0
            NO-ERROR.
        IF NOT AVAILABLE buf_ext-classif THEN DO:
            MESSAGE
            "Сначала надо получить соответствия!!!"
            VIEW-AS ALERT-BOX ERROR.
            UNDO, RETURN ERROR.
        END.
        MESSAGE
        "А ВЫ НАЖИМАЛИ КНОПКУ <ПОЛУЧИТЬ СООТВЕТСТВИЯ>?"
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
        IF NOT glog  THEN RETURN.
    END.
END CASE.
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к БД TH &4&1&2&1&3"
             , chr(10)
             , error-status:get-message(1)
             , return-value
             , p-from-version
             )
  view-as alert-box error .
  return error .
end.
run str/diallog.w ( input parparentproc
          , input this-procedure
          , input 'cmp/ththgdsi.p':U
          , input string(p-imp-version) + chr(4) + p-from-version
          , input no
          , input ''
          , input substitute('Закачка соответствий по товарам БД &1', p-from-version)) no-error .
if connected ("src") then do:
  disconnect src.
end.
RUN Openbr IN THIS-PROCEDURE ( INPUT YES, INPUT NO, INPUT '':U).
APPLY "entry" TO br-goods in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-report :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
message
substitute("Просматривать УДАЛЕННЫЕ товары &1?", p-from-version)
view-as alert-box question buttons yes-no update glog.
run cmp/upg-conn.p ( input "connect"
                    ,input p-from-version
                    ,output v-ok) no-error.
if not v-ok then do:
  message
  substitute("Ошибка при подключении к БД TH &4&1&2&1&3"
             , chr(10)
             , error-status:get-message(1)
             , return-value
             , p-from-version
             )
  view-as alert-box error .
  return error .
end.
run str/diallog.w ( input parparentproc
          , input this-procedure
          , input 'cmp/ththgdsr.p':U
          , input string(glog)
          , input no
          , input ''
          , input substitute('Детальный отчет по имеющимся и отсутствующим  соответствиям по товарам БД &1 и v16.0', p-from-version)) no-error .
if connected ("src") then do:
  disconnect src.
end.
define variable ii-excel as integer no-undo .
define variable ii-page as integer no-undo init 1.
define variable v-correct-bind as character no-undo .
define variable v-report-name as character no-undo .
define buffer buf1_sheetf for sheetf.
define buffer buf_sheetf for sheetf.
define buffer buf_temp-bind for temp-bind.
make-excel = yes.
run get-report-num in parparentproc ( output g#report-num).
run prn-lib-get-report-name  in this-procedure (
                                                  input parParentProc
                                                  ,output v-report-name
                                                ).
run OpenForExcel in this-procedure  .
assign
sheetf.Excel-Column-Lable = substitute("Проблемы,&1 Код товара/ДопБК,v16.0 Код товара,&1 Артикул,v16.0 Артикул,"
                                       , p-from-version)
                            +
                            substitute("&1 Пр-ль,v16.0 Пр-ль,&1 Название,v16.0 Название,&1 ед.изм,v16.0 ед.изм,"
                                       , p-from-version)
                            +
                            substitute("&1Статус,v16.0Статус,&1Группа,v16.0Группа,&1Назв.Пр-ля,v16.0Назв.пр-ля,тип строки"
                                       , p-from-version)
sheetf.colformat = "1=@;2=0;3=0;4=@;5=@;6=@;7=@;8=@;9=@;10=@;11=@;12=@;13=@;14=@;15=@;16=@;17=@;18=@"
sheetf.sizes = "12,13,9,16,16,12,12,48,48,3,3,4,4,45,45,45,45,3"
sheetf.Bas-File = "exe/ththgdsr.bas"
.
my-handle = parparentproc.
run waitfram-show in this-procedure ("Ждите..." ).
assign
Reportname = substitute("Подробный отчет о проблемах в соответствиях товаров &1 и v16.0", p-from-version)
Reportheader = substitute("Удаленные товары - &1", (if glog then "Включены" else "не включены"))
str1 = "Расшифровка для строк товаров (<голубые> строки: -1 -  запись соответствия не заполнена; 0 - нет записи соответствия; А - проблемы с артикулом, Н - проблемы с названием; Г - проблемы с группой; П - проблемы с производителем, У - проблемы со статусом; И - проблемы с осн.ед.изм; Д - проблемы с ДопБК "
str2 = substitute("    если данные в таблице соответствия отличаются от данныъ в БД &1 на текущий момент: а - отличается артикул; п - отличается производитель; н - отличается название; и- отличается ед.изм", p-from-version)
str3 = "Расшифровка для строк ДопБК (<белые> строки: '-' -  не найден ДопБК; Т - проблема с товаром (например, ДопБК привязан к товару, который  НЕСВЯЗАН с его товаром); У - проблемы с ВКл/ВЫКЛ; И - проблемы с ед.изм; К - проблемы с коэфф"
.
run rep/extitle.p ( input 1).
sheetf.Bas-Params = string(Sheetf.Excel-Row-Heder  ) .
run waitfram-show in this-procedure ("Ждите..." ).
find first buf1_sheetf no-lock where
          buf1_sheetf.sheet-num = 1 or buf1_sheetf.sheet-num = 0.
v-correct-bind = fill( chr(32), 13) .
for each temp-bind where
        temp-bind.correct-bind > v-correct-bind
by temp-bind.src-gds-code:
  if Make-Excel then  put   stream ForExcel unformatted
  temp-bind.correct-bind CHR(9)
  temp-bind.src-gds-code CHR(9)
  temp-bind.trg-gds-code CHR(9)
  temp-bind.src-artic    CHR(9)
  temp-bind.trg-artic    CHR(9)
  (temp-bind.src-prod-type + string(temp-bind.src-prod-code))  CHR(9)
  (temp-bind.trg-prod-type + string(temp-bind.trg-prod-code))  CHR(9)
  temp-bind.src-gds-name CHR(9)
  temp-bind.trg-gds-name CHR(9)
  temp-bind.src-unit-base CHR(9)
  temp-bind.trg-unit-base CHR(9)
  entry (lookup (string(temp-bind.src-stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U)  CHR(9)
  entry (lookup (string(temp-bind.trg-stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U) CHR(9)
  temp-bind.src-grp-name CHR(9)
  temp-bind.trg-grp-name CHR(9)
  temp-bind.src-prod-name CHR(9)
  temp-bind.trg-prod-name CHR(9)
  "gds"
  skip
  .
  ii-excel = ii-excel + 1.
  for each temp-prod-bc where
          (temp-prod-bc.src-gds-code > 0
          and temp-prod-bc.old-gds-code = temp-bind.src-gds-code)
    or  (temp-prod-bc.src-gds-code   = 0
         and temp-prod-bc.v151-gds-code > 0
       and temp-prod-bc.v151-gds-code = temp-bind.trg-gds-code)
          :
    if temp-prod-bc.v151-gds-code <> 0
    and temp-prod-bc.v151-gds-code <> temp-bind.trg-gds-code
    and temp-prod-bc.src-gds-code <> 0
    then do:
      find first buf_temp-bind where
                buf_temp-bind.trg-gds-code = temp-prod-bc.v151-gds-code no-error.
    end.
    else do:
      release buf_temp-bind.
    end.
    if Make-Excel then  put   stream ForExcel unformatted
    temp-prod-bc.correct-pbc-bind CHR(9)
    temp-prod-bc.src-b-str CHR(9)
    temp-prod-bc.v151-gds-code CHR(9)
    CHR(9)
    (if available buf_temp-bind then buf_temp-bind.trg-artic else '') CHR(9)
    CHR(9)
    (if available buf_temp-bind then (buf_temp-bind.trg-prod-type + string(buf_temp-bind.trg-prod-code)) else '') CHR(9)
    CHR(9)
    (if available buf_temp-bind then buf_temp-bind.trg-gds-name else '') CHR(9)
    CHR(9)
    (if available buf_temp-bind then buf_temp-bind.trg-unit-base else '') CHR(9)
    CHR(9)
    (if available buf_temp-bind then entry (lookup (string(buf_temp-bind.trg-stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U) else '') CHR(9)
    CHR(9)
    (if available buf_temp-bind then buf_temp-bind.trg-grp-name else '')  CHR(9)
    CHR(9)
    (if available buf_temp-bind then buf_temp-bind.trg-prod-name else '') CHR(9)
    "pbc"
    skip
    .
    ii-excel = ii-excel + 1.
  end.
  if ii-excel > 32000 then do:                                                               if   Make-Excel Then  do:   Output stream ForExcel close.   assign   number-list = number-list + 1   .   os-delete value( v-excel-file + ".":U + string(number-list)).   Output Stream ForExcel to value( v-excel-file + ".":U + string(number-list ) ) . end.                                                                          find first buf_sheetf where                                                                     buf_sheetf.sheet-num = ii-page + 1 no-error.                                if not available buf_sheetf then do:                                                    create buf_sheetf.                                                                  end.                                                                                  buffer-copy buf1_sheetf except sheet-num                                              to buf_sheetf                                                                         assign                                                                                buf_sheetf.sheet-num = ii-page + 1                                                    .                                                                                     run rep/extitle.p (ii-page + 1) .                                                         find first buf_sheetf where                                                                     buf_sheetf.sheet-num = ii-page + 1.                                         buf_sheetf.Bas-Params = string(buf_Sheetf.Excel-Row-Heder  ) .                            assign                                                                                ii-page = ii-page + 1                                                                 ii-excel = 0                                                                          .                                                                                   end.
end.
if Make-Excel then output stream ForExcel close.
run waitfram-hide in this-procedure .
find first buf_sheetf where
         buf_sheetf.sheet-num = 1.
assign
buf_sheetf.file-name = v-report-name
.
release buf_sheetf.
run rep/runexcel.p ( input (v-report-name + ".txt")) no-error.
END PROCEDURE.
PROCEDURE set-row-color :
DEF VAR iFGColor AS INTEGER NO-UNDO.
DEF VAR iBGColor AS INTEGER NO-UNDO.
  IF X_ext-classif.uniq-key-rec = "":U THEN DO:
      ASSIGN
        iFGColor = WHITE_COLOR
        iBGColor = RED_COLOR
      .
    end.
    ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
    end.
    ASSIGN
     X_ext-classif.charkey_three:FGCOLOR  in BROWSE br-goods = iFGColor
     X_ext-classif.charkey_three:BGCOLOR  in BROWSE br-goods = iBGColor
    .
END PROCEDURE.
FUNCTION get-gds RETURNS LOGICAL ( INPUT p-uniq-key-rec AS character
    ,OUTPUT p-artic AS CHARACTER
    ,OUTPUT p-prodtypecode AS CHARACTER
    ,OUTPUT p-gds-name AS CHARACTER ) :
DEFINE VARIABLE v-rowid AS ROWID NO-UNDO.
DEFINE VARIABLE v-tbl-name AS character NO-UNDO.
DEFINE BUFFER buf_goods FOR ub.goods.
RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT p-uniq-key-rec
                                    ,input ?
                                    ,INPUT "ub"
                                    ,INPUT ?
                                    ,INPUT NO-LOCK
                                    ,OUTPUT v-rowid
                                    ,OUTPUT v-tbl-name) no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1)
    error-status :get-message(2)
  view-as alert-box error.
  undo, return error.
end.
IF v-rowid = ? THEN RETURN no.
FIND FIRST buf_goods NO-LOCK WHERE ROWID(buf_goods) = v-rowid.
IF AVAILABLE buf_goods THEN DO:
    ASSIGN
    p-artic = buf_goods.artic
    p-prodtypecode = buf_goods.prod-type + STRING(buf_goods.prod-code)
    p-gds-name = buf_goods.gds-name.
    RETURN yes.
END.
RETURN NO.
END FUNCTION.
