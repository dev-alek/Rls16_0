DEFINE BUFFER locked_layout FOR ub.layout.
DEFINE TEMP-TABLE tt-layout NO-UNDO LIKE ub.layout.
DEFINE TEMP-TABLE tt-layout-elem NO-UNDO LIKE ub.layout-elem
       field is-defined as logical.
DEFINE TEMP-TABLE tt-layout-elem-rule NO-UNDO LIKE ub.layout-elem-rule.
DEFINE TEMP-TABLE tt-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_layout-elem FOR ub.layout-elem.
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER x_ruledict-param FOR ub.ruledict-param.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-layout-id as character no-undo .
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Форма Редактирования Раскладки".
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
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info1 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info1, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info1, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info1 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info1, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info1 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info1, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info1, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info1, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info1, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info1, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info1 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info1 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info1, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info1 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info1 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info1, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info1, v-inform, v-tbl-name ).
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
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-cdm-name RETURNS CHARACTER
  ( input p-mode-id as character) :
define buffer buf_wi-mode for ub.wi-mode.
find first   buf_wi-mode no-lock where
            buf_wi-mode.mode-id = p-mode-id
        and buf_wi-mode.mode-type = 'cd-IBS-TH':U
            no-error.
if available buf_wi-mode then do:
  return buf_wi-mode.mode-name.
end.
RETURN "".
END FUNCTION.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION title-mode RETURNS CHARACTER
  ( INPUT pmode as character ) :
DEFINE VARIABLE ptitle-mode as character no-undo.
CASE ENTRY(1, pmode) :
  when 'ДОБАВЛЕНИЕ':U then ptitle-mode = "ДОБАВЛЕНИЕ".
  when 'ИЗМЕНЕНИЕ':U  then ptitle-mode = "ИЗМЕНЕНИЕ".
  when 'ПРОСМОТР':U  then ptitle-mode = "ПРОСМОТР".
END CASE.
  RETURN ptitle-mode.
END FUNCTION.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-param-value RETURNS CHARACTER
  ( INPUT p-data-type AS CHARACTER
   ,INPUT p-2-data-type AS character
   ,INPUT p-3-data-type AS CHARACTER
   ,INPUT p-p-index AS INTEGER
   ,INPUT p-value-character AS CHARACTER
   ,INPUT p-value-date AS DATE
   ,INPUT p-value-decimal AS DECIMAL
   ,INPUT p-value-integer AS INTEGER
   ,INPUT p-value-logical AS LOGICAL
     ) :
define buffer buf_cash-pay for ub.cash-pay.
define variable v-view-value as character no-undo .
if (p-3-data-type = "LIST"
     or
     p-3-data-type = "SORTED-LIST"
     )
and p-p-index = 0 then return '':U.
if p-2-data-type > '' then do:
  case p-2-data-type:
    when 'cash-pay':U
    or
    when 'cash-pay':U + "_null"
    then do:
      if p-2-data-type = 'cash-pay':U + "_null"
      and p-value-character = substitute("&1,&2", 0, 0) then return "Тип касс. платежа не задан".
      else do:
        find first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = integer(entry(1, p-value-character))
              and buf_cash-pay.curr-code = integer(entry(2, p-value-character)) no-error.
        if available buf_cash-pay then return buf_cash-pay.obj-name.
        else return "!!!Неизвестный тип касс.платежа".
      end.
    end.
    when 'chk-doc':U + "_wth-type_null"
    or when 'chk-doc':U + "_wth-type" then do:
      return entry (lookup (string(p-value-integer),  '2,3,4,5,7':U) + 1, ',' + 'Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ':U).
    end.
    when 'discnt-v-type-manual':U then do:
            return entry (lookup (string(p-value-integer), '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14':U), '?,%,Абс,ФЦ,опция,Бонус,Категория,Флаг,Правило,%-Абс-ФЦ,Сумма,ТПЛ-%,ТПЛ-ФЦ,ТПЛ-абс,Подарок':U).
    end.
    otherwise do:
      if lookup(p-2-data-type, 'gds-discnt-role,subtotal-discnt-role,pay-discnt-role':U) > 0  then do:
         if lookup(p-value-character, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u).
         end.
         if lookup(p-value-character, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'pcnt-tot-kateg,dflt-gds-temp-disc,abs-tot-kateg,pcnt-codes,kateg-codes,free-discnt-flag,pmnt-discnt-flag,kat-gds-grp,temp-disc-pdf,pcnt-kat-pdf,bonus-tot,bonus-all':u) + 1, ',' + '% Скидка на итог,Временная скидка на товар по умолчанию,Abs Скидка на итог,Коды % скидок,Коды категорий,Флаг своб.скидки,Флаг уст. скидки на платеж,Ск-ка на группу товаров для кат.клиентов,Временная через ТПЛ,Категорийная через ТПЛ,Начисление бонусов на сумму чека,Правило-итого бонусов по чеку':u).
         end.
         if lookup(p-value-character, 'simple-pay,qnty-pay':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u).
         end.
         if lookup(p-value-character, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u).
         end.
         if lookup(p-value-character, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u).
         end.
         if lookup(p-value-character, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) + 1, ',' + '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u).
         end.
         if lookup(p-value-character, 'cli-grp-pcnt':u) > 0
         then do:
                      return entry (lookup (p-value-character, 'cli-grp-pcnt':u) + 1, ',' + '% скидка на группу клиентов':u).
         end.
      end.
    end.
  end case.
end.
case p-data-type:
  when 'character':U then do:
    return p-value-character.
  end.
  when 'date':U then do:
    return string(p-value-date, "99/99/9999").
  end.
  when 'decimal':U then do:
    return string(p-value-decimal).
  end.
  when 'integer':U then do:
    return string(p-value-integer).
  end.
  when 'logical':U then do:
    return string(p-value-logical).
  end.
end.
END FUNCTION.
DEFINE VARIABLE v-param-num-list AS CHARACTER NO-UNDO.
define variable v-admin as logical no-undo .
define variable v-is-copy as logical no-undo .
define variable V-IS-DEFAULT as integer no-undo .
define variable GLOG as logical no-undo .
DEFINE BUFFER buf_layout FOR ub.layout.
DEFINE BUFFER FIRST_layout FOR ub.layout.
DEFINE VARIABLE v-gl-call#-id AS INTEGER NO-UNDO init -100000.
FUNCTION get-call#-id RETURNS INTEGER
  ( INPUT p-call-id AS CHARACTER )  FORWARD.
DEFINE BUTTON B-add
     LABEL "<-"
     SIZE 3 BY 1.
DEFINE BUTTON b-br-available
     LABEL "Элементы, доступные для определения"
     SIZE 37 BY 1.
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON B-del
     LABEL "->"
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 11 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE CB-mode-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Режим"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 44 BY 1 NO-UNDO.
DEFINE VARIABLE e-elem-tooltip AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL
     SIZE 37 BY 2 NO-UNDO.
DEFINE VARIABLE f-elem-label AS CHARACTER FORMAT "X(256)":U
     LABEL "Лейбл"
     VIEW-AS FILL-IN NATIVE
     SIZE 29.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-image-id-down AS CHARACTER FORMAT "X(256)":U
     LABEL "DOWN"
     VIEW-AS FILL-IN NATIVE
     SIZE 31 BY 1 NO-UNDO.
DEFINE VARIABLE f-image-id-insen AS CHARACTER FORMAT "X(256)":U
     LABEL "INSEN"
     VIEW-AS FILL-IN NATIVE
     SIZE 31 BY 1 NO-UNDO.
DEFINE VARIABLE f-image-id-up AS CHARACTER FORMAT "X(256)":U
     LABEL "UP"
     VIEW-AS FILL-IN NATIVE
     SIZE 31 BY 1 NO-UNDO.
DEFINE VARIABLE l-elem-tooltip AS CHARACTER FORMAT "X(256)":U INITIAL "Тултип"
      VIEW-AS TEXT
     SIZE 31 BY .67 NO-UNDO.
DEFINE QUERY BR-available FOR
      tt-layout-elem SCROLLING.
DEFINE QUERY BR-layout-elem-rule FOR
      tt-layout-elem-rule,
      X_rule SCROLLING.
DEFINE QUERY BR-rule-call-params FOR
      tt-rule-call-param SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      tt-layout SCROLLING.
DEFINE BROWSE BR-available
  QUERY BR-available NO-LOCK DISPLAY
      tt-layout-elem.mode-id column-label "Режим"
tt-layout-elem.widget-id column-label "ID Элемента"
tt-layout-elem.des column-label ""
    WITH NO-ROW-MARKERS SEPARATORS SIZE 34 BY 16.27
         TITLE "Элементы, доступные для определения" FIT-LAST-COLUMN.
DEFINE BROWSE BR-layout-elem-rule
  QUERY BR-layout-elem-rule NO-LOCK DISPLAY
      tt-layout-elem-rule.widget-id FORMAT "x(8)":U column-label "Элемент"
tt-layout-elem-rule.is-mandatory = INTEGER('1':U) FORMAT "+/" COLUMN-LABEL "Обяз"
tt-layout-elem-rule.mode-id FORMAT "x(5)":U column-label "Режим"
tt-layout-elem-rule.rule_id FORMAT ">>>>>>>>9":U column-label "Правило"
tt-layout-elem-rule.elem-label FORMAT "X(8)" column-label "Лейбл"
X_rule.name column-label "Функция" FORMAT "X(255)":U width 70
(IF tt-layout-elem-rule.sts = INTEGER('1':U) THEN "+" ELSE "") COLUMN-LABEL "уд" WIDTH 4
    WITH NO-ROW-MARKERS SEPARATORS SIZE 61 BY 11
         TITLE "Функции, определенные для элементов раскладки" FIT-LAST-COLUMN.
DEFINE BROWSE BR-rule-call-params
  QUERY BR-rule-call-params NO-LOCK DISPLAY
      tt-rule-call-param.param-name column-label "Название"
tt-rule-call-param.param-label column-label "Название"
tt-rule-call-param.param-data-type column-label  "Тип!данных"
get-param-value( INPUT tt-rule-call-param.param-data-type
                ,INPUT tt-rule-call-param.param-2-data-type
                ,INPUT tt-rule-call-param.param-3-data-type
                ,INPUT tt-rule-call-param.p-index
                ,INPUT tt-rule-call-param.param-value-character
                ,INPUT tt-rule-call-param.param-value-date
                ,INPUT tt-rule-call-param.param-value-decimal
                ,INPUT tt-rule-call-param.param-value-integer
                ,INPUT tt-rule-call-param.param-value-logical) column-label "Значение"
format "X(255)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 64 BY 5.27
         TITLE "Параметры" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     tt-layout.layout-id AT ROW 1 COL 45 COLON-ALIGNED WIDGET-ID 38 FORMAT "x(48)"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     B-Help AT ROW 1 COL 95
     tt-layout.layout-type AT ROW 2 COL 15 COLON-ALIGNED WIDGET-ID 14 FORMAT "x(20)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 35 BY 1
     tt-layout.is-default AT ROW 2 COL 66 COLON-ALIGNED NO-LABEL WIDGET-ID 108 FORMAT "->>9"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "0",1
          DROP-DOWN-LIST
          SIZE 26.5 BY 1
     tt-layout.device-type AT ROW 3 COL 15 COLON-ALIGNED WIDGET-ID 62
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 35 BY 1
     tt-layout.layout-name AT ROW 4 COL 7 WIDGET-ID 64
          LABEL "Название"
          VIEW-AS FILL-IN
          SIZE 35 BY 1
     tt-layout.des AT ROW 5 COL 15 COLON-ALIGNED WIDGET-ID 110
          LABEL "Описание" FORMAT "X(256)"
          VIEW-AS FILL-IN
          SIZE 81.5 BY 1
     B-chg AT ROW 6 COL 1 WIDGET-ID 68
     b-lkp AT ROW 6 COL 11 WIDGET-ID 98
     CB-mode-id AT ROW 6 COL 30 WIDGET-ID 20
     BR-layout-elem-rule AT ROW 7 COL 1 WIDGET-ID 100
     b-br-available AT ROW 7 COL 62.5 WIDGET-ID 96
     BR-available AT ROW 7 COL 65.5 WIDGET-ID 200
     f-elem-label AT ROW 8 COL 68 COLON-ALIGNED WIDGET-ID 74
     e-elem-tooltip AT ROW 10 COL 62 NO-LABEL WIDGET-ID 76
     B-add AT ROW 10 COL 62.5 WIDGET-ID 66
     B-del AT ROW 11 COL 62.5 WIDGET-ID 70
     f-image-id-up AT ROW 13 COL 66 COLON-ALIGNED WIDGET-ID 78
     f-image-id-down AT ROW 14 COL 66 COLON-ALIGNED WIDGET-ID 82
     f-image-id-insen AT ROW 15 COL 66 COLON-ALIGNED WIDGET-ID 84
     BR-rule-call-params AT ROW 18 COL 1 WIDGET-ID 300
     l-elem-tooltip AT ROW 9 COL 64.5 COLON-ALIGNED NO-LABEL WIDGET-ID 80
     SPACE(2.00) SKIP(13.79)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-br-available:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-quit:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       e-elem-tooltip:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-elem-label:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-image-id-down:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-image-id-insen:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       f-image-id-up:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       l-elem-tooltip:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      RETURN NO-APPLY.
  END.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
  if not available tt-layout-elem then do:
     bell.
     return no-apply.
  end.
  run proc-b-add in this-procedure ( input tt-layout-elem.mode-id
                                    ,input tt-layout-elem.widget-id).
END.
ON CHOOSE OF b-br-available IN FRAME Dialog-Frame
DO:
  run proc-view-br-available in this-procedure no-error.
  if not error-status:error then do:
    hide
    b-br-available
    in frame Dialog-Frame.
  end.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_tt-layout-elem-rule FOR tt-layout-elem-rule.
  DEFINE VARIABLE v-ok AS LOGICAL NO-UNDO.
  define variable v-mode-id as character no-undo .
  define variable v-rule-id as integer no-undo .
  define variable v-recid as recid no-undo .
  IF NOT AVAILABLE tt-layout-elem-rule THEN RETURN NO-APPLY.
  assign
  v-mode-id = tt-layout-elem-rule.mode-id.
  v-rule-id = tt-layout-elem-rule.rule_id
  .
  run adm/layeruli.w ( input parparentproc
                    ,input ('ИЗМЕНЕНИЕ':U + (if v-admin then (chr(44) + "admin") else ''))
                    ,input tt-layout-elem-rule.uniq-key-rec
                    ,input tt-layout.device-type
                    ,input-output table buf_tt-layout-elem-rule
                    ,input-output table tt-rule-call-param
                    ,output v-ok
                    ) no-error.
  run openbr in this-procedure no-error.
  find first buf_tt-layout-elem-rule where
          buf_tt-layout-elem-rule.mode-id = v-mode-id
      and buf_tt-layout-elem-rule.rule_id = v-rule-id.
  v-recid = recid(buf_tt-layout-elem-rule).
  reposition br-layout-elem-rule to recid v-recid no-error.
  apply "entry" to br-layout-elem-rule in frame Dialog-Frame .
  apply "value-changed" to br-layout-elem-rule in frame Dialog-Frame .
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
  if not available tt-layout-elem-rule then do:
     bell.
     return no-apply.
  end.
  run proc-b-del in this-procedure ( input tt-layout-elem-rule.mode-id
                                    ,input tt-layout-elem-rule.widget-id).
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  if not available tt-layout-elem-rule then do:
    bell.
    return no-apply.
  end.
  run proc-layout-elem-rule-i in this-procedure ( buffer tt-layout-elem-rule) no-error.
  if not error-status:error then do:
     hide
     b-lkp
     in frame Dialog-Frame.
  end.
END.
ON VALUE-CHANGED OF BR-layout-elem-rule IN FRAME Dialog-Frame
DO:
  run Openbr3 in this-procedure no-error.
  if f-elem-label:visible in  frame Dialog-Frame then do:
    if available tt-layout-elem-rule then do:
      display
      tt-layout-elem-rule.elem-label @ f-elem-label
      tt-layout-elem-rule.image-id-up @ f-image-id-up
      tt-layout-elem-rule.image-id-down @ f-image-id-down
      tt-layout-elem-rule.image-id-insen @ f-image-id-insen
      with frame Dialog-Frame.
      assign
      e-elem-tooltip:screen-value = tt-layout-elem-rule.elem-tooltip.
    end.
    else do:
      display
      '' @ f-elem-label
      '' @ f-image-id-up
      '' @ f-image-id-down
      '' @ f-image-id-insen
      with frame Dialog-Frame.
      assign
      e-elem-tooltip:screen-value = ''.
    end.
  end.
END.
ON VALUE-CHANGED OF CB-mode-id IN FRAME Dialog-Frame
DO:
  assign
  cb-mode-id.
  run openbr in this-procedure no-error.
  run openbr2 in this-procedure no-error.
  reposition br-layout-elem-rule to row 1 no-error.
  apply "entry" to br-layout-elem-rule in frame Dialog-Frame .
  apply "value-changed" to br-layout-elem-rule in frame Dialog-Frame .
  run process-add-del in this-procedure .
END.
ON VALUE-CHANGED OF tt-layout.device-type IN FRAME Dialog-Frame
DO:
  RUN proc-value-change-device-type IN THIS-PROCEDURE ( INPUT YES) NO-ERROR.
END.
ON VALUE-CHANGED OF tt-layout.layout-type IN FRAME Dialog-Frame
DO:
  RUN proc-value-change-layout-type IN THIS-PROCEDURE ( INPUT YES).
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-available :handle
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if lookup('admin', p-mode) > 0 then do:
    v-admin = yes.
    p-mode = trim(replace(p-mode, 'admin', ''), chr(44)).
  end.
  if lookup(p-mode, 'ДОБАВЛЕНИЕ':U + chr(44) +
                    'КОПИРОВАНИЕ':U + chr(44) +
                    'ИЗМЕНЕНИЕ':U + chr(44) +
                    'ПРОСМОТР':U) = 0 then  do:
    message
    substitute("Неверное значение параметра p-mode = &1", p-mode)
    view-as alert-box error .
    undo main-block, return error .
  end.
  if p-mode = 'КОПИРОВАНИЕ':U then do:
    assign
    v-is-copy = yes
    p-mode = 'ДОБАВЛЕНИЕ':U
    .
  end.
  IF p-mode = 'ДОБАВЛЕНИЕ':U
  THEN DO:
    FIND FIRST FIRST_layout EXCLUSIVE-LOCK WHERE FIRST_layout.layout-id = '_'.
    CREATE tt-layout.
  END.
  if v-is-copy
  or p-mode <> 'ДОБАВЛЕНИЕ':U
  then do:
    if (p-mode = 'ДОБАВЛЕНИЕ':U and v-is-copy)
    then do:
      FIND FIRST LOCKED_layout share-LOCK WHERE
                LOCKED_layout.layout-id = p-layout-id.
      IF locked_layout.is-default = integer('1':U)
      then do:
        if v-admin then do:
                    message
          substitute("Копируемая раскладка является &1&2" +
                    "Новая раскладка тоже должна быть &1?"
                    ,entry (lookup (string(locked_layout.is-default), '0,1,-1':U) + 1, ',' + 'Пользовательская,Шаблон IBS TH,Обязательная':U)
                    ,chr(10))
          view-as alert-box  question buttons yes-no update glog.
          if glog then do:
            v-is-default = integer('1':U).
          end.
          ELSE DO:
            v-is-default = integer('0':U).
          END.
        end.
        else do:
          v-is-default = integer('0':U).
        end.
      end.
    end.
    IF p-mode = 'ИЗМЕНЕНИЕ':U
    THEN DO:
      FIND FIRST LOCKED_layout EXCLUSIVE-LOCK WHERE
                LOCKED_layout.layout-id = p-layout-id.
      if locked_layout.is-default = integer('1':U)
      and not v-admin then do:
               message
        substitute("Нельзя редактировать &1", entry (lookup (string(locked_layout.is-default), '0,1,-1':U) + 1, ',' + 'Пользовательская,Шаблон IBS TH,Обязательная':U))
        view-as alert-box error .
        undo, return error .
      end.
      create tt-layout.
    END.
    IF p-mode = 'ПРОСМОТР':U THEN DO:
        FIND FIRST LOCKED_layout no-LOCK WHERE
                LOCKED_layout.layout-id = p-layout-id no-error .
      create tt-layout.
    END.
    buffer-copy locked_layout to tt-layout.
    if tt-layout.layout-id <> '_' then do:
      if v-is-copy then do:
        tt-layout.is-default = v-is-default.
      end.
      RUN fill-tt IN THIS-PROCEDURE.
      if v-is-copy then do:
        assign
        tt-layout.layout-id = ''
        .
      end.
      run fill-elem in this-procedure .
      if p-mode = 'ДОБАВЛЕНИЕ':U and v-is-copy then do:
        release locked_layout.
      end.
    end.
  end.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE cb_rule-by-set-s_is-used :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define output parameter p-is-used as logical no-undo .
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
for each buf_wi-mode no-lock where
          buf_wi-mode.codex_id = p-codex-id
      and buf_wi-mode.ruleset_id = p-ruleset-id
      and buf_wi-mode.mode-type = 'cd-IBS-TH':U,
   each buf_tt-layout-elem-rule where
       buf_tt-layout-elem-rule.layout-id = tt-layout.layout-id
   and buf_tt-layout-elem-rule.mode-id = buf_wi-mode.mode-id
   and buf_tt-layout-elem-rule.rule_id = p-rule-id
   :
  p-is-used = yes.
  leave.
end.
END PROCEDURE.
PROCEDURE check-tt-layout-elem-rule :
define input parameter p-old-layout-type as character no-undo.
define input parameter p-new-layout-type as character no-undo.
define input parameter p-old-device-type as character no-undo.
define input parameter p-new-device-type as character no-undo.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-layout SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY CB-mode-id f-elem-label e-elem-tooltip f-image-id-up f-image-id-down
          f-image-id-insen l-elem-tooltip
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-layout THEN
    DISPLAY tt-layout.layout-id tt-layout.layout-type tt-layout.is-default
          tt-layout.device-type tt-layout.layout-name tt-layout.des
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit tt-layout.layout-id B-Help tt-layout.is-default
         tt-layout.layout-name tt-layout.des B-chg b-lkp CB-mode-id
         BR-layout-elem-rule b-br-available BR-available f-elem-label
         e-elem-tooltip B-add B-del BR-rule-call-params
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-cb-mode-id :
define input parameter p-layout-type as character no-undo.
define variable v-list-items as character no-undo.
define buffer buf_wi-mode for ub.wi-mode.
case p-layout-type:
  when 'th-pos-screen':U then do:
    v-list-items = chr(44).
    assign
    cb-mode-id:list-item-pairs in frame Dialog-Frame = v-list-items.
    for each buf_wi-mode NO-LOCK WHERE buf_wi-mode.mode-type = 'cd-IBS-TH':U
    and buf_wi-mode.mode-id < "_"
    :
      cb-mode-id:add-last ( substitute("&1 (&2)", string(buf_wi-mode.mode-name, "X(32)"), buf_wi-mode.mode-id), buf_wi-mode.mode-id).
    end.
    assign
    cb-mode-id = "".
    display
    cb-mode-id
    with frame Dialog-Frame.
    enable cb-mode-id
    with frame Dialog-Frame.
  end.
  when 'th-pos-keyboard':U then do:
    find first buf_wi-mode NO-LOCK WHERE buf_wi-mode.mode-type = 'cd-IBS-TH':U
    and buf_wi-mode.mode-id = "_".
    cb-mode-id:list-item-pairs in frame Dialog-Frame = substitute("&1,&2"
                                                                   ,string(buf_wi-mode.mode-name, "X(32)")
                                                                   ,buf_wi-mode.mode-id).
   assign
   cb-mode-id = "_".
    display
    cb-mode-id
    with frame Dialog-Frame.
    disable cb-mode-id
    with frame Dialog-Frame.
  end.
end case.
END PROCEDURE.
PROCEDURE fill-elem :
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
if tt-layout.device-type = ''
or tt-layout.layout-type = '' then do:
  undo, return error .
end.
for each buf_tt-layout-elem:
  delete buf_tt-layout-elem.
end.
for each buf_layout-elem no-lock where
        buf_layout-elem.layout-type = tt-layout.layout-type
    and buf_layout-elem.device-type = tt-layout.device-type
    AND buf_layout-elem.elem-type = INTEGER('0':U):
    create buf_tt-layout-elem.
    buffer-copy buf_layout-elem to buf_tt-layout-elem.
end.
for each buf_tt-layout-elem,
      first buf_tt-layout-elem-rule no-lock where
            buf_tt-layout-elem-rule.mode-id = buf_tt-layout-elem.mode-id
         and buf_tt-layout-elem-rule.widget-id = buf_tt-layout-elem.widget-id:
    assign
    buf_tt-layout-elem.is-defined = yes.
end.
END PROCEDURE.
PROCEDURE fill-tt :
define variable v-call#_id as integer no-undo .
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_tt-rule-by-call for tt-rule-by-call.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
for each buf_tt-layout-elem-rule:
  delete buf_tt-layout-elem-rule.
end.
for each buf_layout-elem-rule no-lock where
        buf_layout-elem-rule.layout-id = tt-layout.layout-id:
  find first buf_tt-layout-elem-rule where
           buf_tt-layout-elem-rule.layout-id = (if v-is-copy then '' else buf_layout-elem-rule.layout-id)
       and buf_tt-layout-elem-rule.mode-id = buf_layout-elem-rule.mode-id
       and buf_tt-layout-elem-rule.widget-id = buf_layout-elem-rule.widget-id no-error.
   if not available buf_tt-layout-elem-rule then do:
      create buf_tt-layout-elem-rule.
      buffer-copy buf_layout-elem-rule to buf_tt-layout-elem-rule
      assign
      buf_tt-layout-elem-rule.layout-id = (if v-is-copy then '' else buf_layout-elem-rule.layout-id )
      .
    if v-is-copy then do:
      run gen-key-rec in this-procedure ( input 'layout-elem-rule':U
                                         ,input (buffer buf_tt-layout-elem-rule:handle)
                                         , output buf_tt-layout-elem-rule.uniq-key-rec).
    end.
    if v-is-copy then do:
      v-call#_id = get-call#-id( input buf_tt-layout-elem-rule.uniq-key-rec).
    end.
    for each buf_rule-by-call no-lock where
            buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec:
        create buf_tt-rule-by-call.
        buffer-copy buf_rule-by-call
        except call_id call#_id
        to buf_tt-rule-by-call
        assign
        buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
        buf_tt-rule-by-call.call#_id = (if v-is-copy then v-call#_id else buf_rule-by-call.call#_id)
        .
    end.
    for each buf_rule-call-param no-lock where
            buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec:
        create buf_tt-rule-call-param.
        buffer-copy buf_rule-call-param
        except call_id call#_id
        to buf_tt-rule-call-param
        assign
        buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
        buf_tt-rule-call-param.call#_id = (if v-is-copy then v-call#_id else buf_rule-call-param.call#_id)
        .
    end.
  end.
end.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.
DEFINE VARIABLE v-h AS handle NO-UNDO.
define variable glog as logical no-undo .
ASSIGN
v-h = br-rule-call-params:FIRST-COLUMN IN FRAME Dialog-Frame
.
DO while valid-handle(v-h) :
  if v-h:LABEL = "Значение" then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
assign
frame Dialog-Frame:title = substitute("Ракладка &1 &2 &3"
                                     , (if p-mode = 'ДОБАВЛЕНИЕ':U then '' else tt-layout.layout-id)
                                     , title-mode(p-mode)
                                     ,( if v-admin then  "Режим IBS" else ''))
.
DO v-ii = 1 TO NUM-ENTRIES('0,1,-1':U):
   v-list-items = v-list-items + (if v-ii = 1 THEN '' ELSE chr(44)) +
                 entry(v-ii, 'Пользовательская,Шаблон IBS TH,Обязательная':U) + chr(44) +
                 ENTRY(v-ii, '0,1,-1':U).
END.
ASSIGN
tt-layout.is-default:list-item-pairs IN FRAME Dialog-Frame = v-list-items.
v-list-items = ''.
DO v-ii = 1 TO NUM-ENTRIES('th-pos-screen,th-pos-keyboard':U):
   v-list-items = v-list-items  + (IF v-ii = 1 THEN '' ELSE chr(44)) +
                  ENTRY(v-ii, 'Экран IBS TH POS,Клавиатура IBS TH POS':U) + chr(44) +
                  ENTRY(v-ii, 'th-pos-screen,th-pos-keyboard':U).
END.
ASSIGN
tt-layout.layout-type:LIST-ITEM-PAIRS IN FRAME Dialog-Frame = v-list-items .
assign
X_rule.name:resizable in browse br-layout-elem-rule = yes
tt-layout-elem-rule.rule_id:visible in browse br-layout-elem-rule = (v-admin = yes)
tt-rule-call-param.param-data-type:visible in browse br-rule-call-params = (v-admin = yes)
tt-rule-call-param.param-name:visible in browse br-rule-call-params = (v-admin = yes)
tt-rule-call-param.param-name:resizable in browse br-rule-call-params = yes
tt-rule-call-param.param-label:resizable in browse br-rule-call-params = yes
X_rule.name:resizable in browse br-layout-elem-rule = yes
.
if tt-layout.sts = integer('50':U) then do:
  glog = browse br-layout-elem-rule:move-column( 7, 5).
end.
IF AVAILABLE tt-layout THEN
DISPLAY
tt-layout.layout-type
tt-layout.layout-id WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
tt-layout.layout-name
tt-layout.is-default
WITH FRAME Dialog-Frame .
RUN proc-value-change-layout-type IN THIS-PROCEDURE ( INPUT NO).
IF AVAILABLE tt-layout THEN
DISPLAY
tt-layout.device-type
WITH FRAME Dialog-Frame .
ENABLE
B-exit  when p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
b-lkp
b-chg when p-mode <> 'ПРОСМОТР':U
b-del when p-mode <> 'ПРОСМОТР':U
b-add when p-mode <> 'ПРОСМОТР':U
cb-mode-id
tt-layout.layout-type  when p-mode = 'ДОБАВЛЕНИЕ':U
tt-layout.device-type  when p-mode = 'ДОБАВЛЕНИЕ':U
tt-layout.layout-name when p-mode <> 'ПРОСМОТР':U
tt-layout.is-default when (p-mode <> 'ПРОСМОТР':U and v-admin)
br-available
br-layout-elem-rule
tt-layout.des  when p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame .
if p-mode = 'ПРОСМОТР':U then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
  hide b-exit in frame Dialog-Frame .
end.
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
   HIDE
   tt-layout.layout-id
   IN FRAME Dialog-Frame.
END.
run Openbr in this-procedure.
run Openbr2 in this-procedure.
run proc-view-br-available in this-procedure .
VIEW FRAME Dialog-Frame .
run process-add-del in this-procedure.
END PROCEDURE.
PROCEDURE OpenBr :
OPEN QUERY br-layout-elem-rule
FOR EACH tt-layout-elem-rule NO-LOCK where
tt-layout-elem-rule.layout-id = tt-layout.layout-id
and (cb-mode-id = ''
or tt-layout-elem-rule.mode-id = cb-mode-id),
first X_rule OUTER-JOIN NO-LOCK where X_rule.rule_id = tt-layout-elem-rule.rule_id
INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE Openbr2 :
OPEN QUERY br-available
FOR EACH tt-layout-elem NO-LOCK where
tt-layout-elem.layout-type = tt-layout.layout-type
and
tt-layout-elem.device-type = tt-layout.device-type
and (cb-mode-id = ''
or tt-layout-elem.mode-id = cb-mode-id)
and tt-layout-elem.is-define = no
INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE Openbr3 :
if not available tt-layout-elem-rule then do:
    OPEN QUERY br-rule-call-params
    FOR EACH tt-rule-call-param WHERE false.
end.
else do:
    OPEN QUERY br-rule-call-params
    FOR EACH tt-rule-call-param WHERE
             tt-rule-call-param.rule_id = tt-layout-elem-rule.rule_id
         and tt-rule-call-param.call_id = tt-layout-elem-rule.uniq-key-rec.
end.
END PROCEDURE.
PROCEDURE proc-add-mandatory :
DEFINE input PARAMETER p-layout-type AS CHARACTER NO-UNDO.
DEFINE input PARAMETER p-device-type AS CHARACTER NO-UNDO.
                 DEFINE BUFFER buf_layout FOR ub.layout.
DEFINE BUFFER buf_layout-elem-rule FOR ub.layout-elem-rule.
DEFINE BUFFER buf_wi-mode FOR ub.wi-mode.
DEFINE BUFFER buf_rule FOR ub.RULE.
DEFINE BUFFER buf_rule-call-param FOR ub.rule-call-param.
DEFINE BUFFER buf_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER buf_tt-rule-by-call FOR tt-rule-by-call.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_tt-layout-elem-rule FOR tt-layout-elem-rule.
DEFINE BUFFER buf_tt-layout-elem FOR tt-layout-elem.
if p-device-type = ''
or p-layout-type = '' then do:
  undo, return ''.
end.
IF tt-layout.is-default = INTEGER('-1':U)
or p-mode = 'ПРОСМОТР':U
or can-find(first buf_tt-layout-elem-rule where buf_tt-layout-elem-rule.layout-id = tt-layout.layout-id) then do:
  return ''.
end.
FIND FIRST buf_layout SHARE-LOCK WHERE
          buf_layout.layout-type = p-layout-type
      AND buf_layout.device-type = p-device-type
    AND buf_layout.is-default = INTEGER('-1':U) NO-ERROR.
IF AVAILABLe buf_layout THEN DO:
   FOR EACH buf_layout-elem-rule NO-LOCK WHERE
            buf_layout-elem-rule.layout-id = buf_layout.layout-id:
    FIND FIRST buf_wi-mode NO-LOCK WHERE
              buf_wi-mode.mode-type = 'cd-IBS-TH':U
          AND buf_wi-mode.mode-id = buf_layout-elem-rule.mode-id.
     find first buf_rule no-lock where
                buf_rule.rule_id = buf_layout-elem-rule.rule_id.
     find first buf_rule-by-call no-lock where
              buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec.
     CREATE buf_tt-layout-elem-rule.
     BUFFER-COPY
     buf_layout-elem-rule
     EXCEPT layout-id uniq-key-rec
     TO buf_tt-layout-elem-rule
     ASSIGN
     buf_tt-layout-elem-rule.layout-id = tt-layout.layout-id
     buf_tt-layout-elem-rule.is-mandatory = integer('1':U)
     .
     run gen-key-rec in this-procedure ( input 'layout-elem-rule':U
                                         ,input (buffer buf_tt-layout-elem-rule:handle)
                                         ,output buf_tt-layout-elem-rule.uniq-key-rec).
     CREATE buf_tt-rule-by-call.
     BUFFER-copy buf_rule-by-call
     EXCEPT CALL_id  uniq-key-rec TO buf_tt-rule-by-call
     ASSIGN
     buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
     .
     run gen-key-rec in this-procedure ( input 'rule-by-call':U
                                         ,input (buffer buf_tt-rule-by-call:handle)
                                         ,output buf_tt-rule-by-call.uniq-key-rec).
     for each buf_rule-call-param no-lock where
            buf_rule-call-param.call_id = buf_rule-by-call.call_id
         AND buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
         AND buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
         AND buf_rule-call-param.order_id = buf_rule-by-call.order_id:
       create buf_tt-rule-call-param.
       buffer-copy buf_rule-call-param
       EXCEPT CALL_id call#_id
       to buf_tt-rule-call-param
       assign
       buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
       .
     end.
  run openbr in this-procedure.
  run openbr2 in this-procedure.
  reposition br-layout-elem-rule to row 1 no-error.
  apply "entry" to br-layout-elem-rule in frame Dialog-Frame .
END.
END.
END PROCEDURE.
PROCEDURE proc-b-add :
define input parameter p-mode-id as character no-undo.
define input parameter p-widget-id as character no-undo.
define variable v-recid as recid no-undo.
define variable v-recid2 as recid no-undo .
define variable v-rid-list as character no-undo.
define variable glog as logical no-undo.
define variable v-ok as logical no-undo .
define variable v-call#-id as integer no-undo .
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf_rule-by-set for ub.rule-by-set.
define buffer buf_rule for ub.rule.
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt-rule-by-call for tt-rule-by-call.
if tt-layout.layout-type = ""
or tt-layout.device-type = "" then do:
  message
  substitute("Вы не определили тип раскладки и/или тип устройства")
  view-as alert-box error.
  undo, return error.
end.
if not available tt-layout-elem then do:
  message
  "Неопределен элемент для добавления"
  view-as alert-box error.
  undo, return error.
end.
find first buf_wi-mode no-lock where
          buf_wi-mode.mode-type = 'cd-IBS-TH':U
      and buf_wi-mode.mode-id = tt-layout-elem.mode-id no-error.
if not available buf_wi-mode then do:
   message
   substitute("Не найдена запись Режима работы c типом &1 и ID &2"
               , 'cd-IBS-TH':U
               , tt-layout-elem.mode-id)
   view-as alert-box error.
   undo, return error.
end.
run rul/rule-by-set-s.w ( INPUT parparentproc
                  ,INPUT "b-sel":U
                  ,INPUT "wi-mode-available" + (if v-admin then chr(44) + "admin" else '')
                  ,INPUT buf_wi-mode.codex_id
                  ,input buf_wi-mode.ruleset_id
                  ,INPUT 0
                  ,INPUT-OUTPUT v-rid-list) NO-ERROR.
if v-rid-list = '' then do:
  undo, return ''.
end.
find first buf_rule-by-set no-lock where
          recid(buf_rule-by-set) = integer(v-rid-list) .
find first buf_rule no-lock where
           buf_rule.rule_id = buf_rule-by-set.rule_id.
find first buf_ruledict where
          buf_ruledict.entry-type = 'rule':U
      and buf_ruledict.uniq-key-rec = buf_rule.uniq-key-rec.
find first buf_tt-layout-elem-rule where
          buf_tt-layout-elem-rule.layout-id = tt-layout.layout-id
      and buf_tt-layout-elem-rule.mode-id = tt-layout-elem.mode-id
      and buf_tt-layout-elem-rule.widget-id = tt-layout-elem.widget-id
      and buf_tt-layout-elem-rule.rule_id = buf_rule-by-set.rule_id no-error.
if available buf_tt-layout-elem-rule
and not can-find(first ub.ruledict-param  no-lock where ub.ruledict-param.entry-id = buf_ruledict.entry-id)
then do:
  message
  substitute("Вы уже подключали функцию &1?, хотите подключить ее еще раз?")
  view-as alert-box question buttons yes-no  update glog.
  if not glog then undo, return error.
end.
find first buf_tt-layout-elem where
        recid(buf_tt-layout-elem) = recid(tt-layout-elem).
create buf_tt-layout-elem-rule.
assign
buf_tt-layout-elem-rule.layout-id = tt-layout.layout-id
buf_tt-layout-elem-rule.mode-id = tt-layout-elem.mode-id
buf_tt-layout-elem-rule.widget-id = tt-layout-elem.widget-id
buf_tt-layout-elem-rule.rule_id = buf_rule-by-set.rule_id
buf_tt-layout-elem-rule.image-id-down = buf_rule.image-file-name
buf_tt-layout-elem-rule.image-id-up = buf_rule.image-file-name
buf_tt-layout-elem-rule.image-id-insen = buf_rule.image-file-name
buf_tt-layout-elem.is-define = yes
buf_tt-layout-elem-rule.is-mandatory = INTEGER('0':U)
v-recid = recid(buf_tt-layout-elem-rule)
v-recid2 = recid(buf_tt-layout-elem)
.
run gen-key-rec in this-procedure ( input 'layout-elem-rule':U
                                    ,input (buffer buf_tt-layout-elem-rule:handle)
                                    ,output buf_tt-layout-elem-rule.uniq-key-rec).
v-call#-id = get-call#-id ( input buf_tt-layout-elem-rule.uniq-key-rec).
CREATE buf_tt-rule-by-call.
ASSIGN
buf_tt-rule-by-call.profile_id = 0
buf_tt-rule-by-call.codex_id = buf_wi-mode.codex_id
buf_tt-rule-by-call.ruleset_id = buf_wi-mode.ruleset_id
buf_tt-rule-by-call.rule_id = buf_rule.rule_id
buf_tt-rule-by-call.order_id = 0
buf_tt-rule-by-call.algo-des = buf_rule.NAME
buf_tt-rule-by-call.is_dynamic = yes
buf_tt-rule-by-call.can-calc = yes
buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec
buf_tt-rule-by-call.call#_id = v-call#-id
buf_tt-rule-by-call.once-more = 1
buf_tt-rule-by-call.can-run = yes
.
 run gen-key-rec in this-procedure ( input 'rule-by-call':U
                                     ,input (buffer buf_tt-rule-by-call:handle)
                                     ,output buf_tt-rule-by-call.uniq-key-rec).
for each buf_ruledict-param no-lock where
        buf_ruledict-param.entry-i = buf_ruledict.entry-id:
  create buf_tt-rule-call-param.
  buffer-copy buf_ruledict-param
  to buf_tt-rule-call-param
  assign
  buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
  buf_tt-rule-call-param.call#_id = v-call#-id
  buf_tt-rule-call-param.codex_id = buf_wi-mode.codex_id
  buf_tt-rule-call-param.ruleset_id = buf_wi-mode.ruleset_id
  buf_tt-rule-call-param.rule_id = buf_rule.rule_id
  buf_tt-rule-call-param.order_id = 0
  buf_tt-rule-call-param.profile_id = 0
  buf_tt-rule-call-param.once-more = 1
  .
end.
run adm/layeruli.w ( input parparentproc
                    ,input ('ДОБАВЛЕНИЕ':U + (if v-admin then (chr(44) + "admin") else ''))
                    ,input buf_tt-layout-elem-rule.uniq-key-rec
                    ,input tt-layout.device-type
                    ,input-output table buf_tt-layout-elem-rule
                    ,input-output table tt-rule-call-param
                    ,output v-ok
                    ) no-error.
if error-status:error
or not v-ok
then do:
  find first buf_tt-layout-elem-rule where
            recid(buf_tt-layout-elem-rule) = v-recid no-error.
  if available buf_tt-layout-elem-rule then do:
    for each buf_tt-rule-call-param where
           buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec
       and buf_tt-rule-call-param.codex_id = buf_wi-mode.codex_id
       and buf_tt-rule-call-param.ruleset_id = buf_wi-mode.ruleset_id
       and buf_tt-rule-call-param.order_id = 0:
      delete buf_tt-rule-call-param.
    end.
    delete buf_tt-layout-elem-rule.
  end.
  find first buf_tt-layout-elem where
             recid(buf_tt-layout-elem) = v-recid2 no-error.
  if available buf_tt-layout-elem then do:
     buf_tt-layout-elem.is-define = no.
  end.
  run openbr in this-procedure.
  run openbr2 in this-procedure.
  reposition br-layout-elem-rule to row 1 no-error.
  apply "entry" to br-layout-elem-rule in frame Dialog-Frame .
end.
else do:
    run openbr in this-procedure.
    run openbr2 in this-procedure.
    reposition br-layout-elem-rule to recid v-recid no-error.
    apply "entry" to br-layout-elem-rule in frame Dialog-Frame .
    apply "value-changed" to br-layout-elem-rule in frame Dialog-Frame .
    run process-add-del in this-procedure .
end.
run proc-view-br-available in this-procedure .
END PROCEDURE.
PROCEDURE proc-b-del :
define input parameter p-mode-id as character no-undo.
define input parameter p-widget-id as character no-undo.
define variable glog as logical no-undo.
define variable v-recid as recid no-undo.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
define buffer buf_tt-layout-elem for tt-layout-elem.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt-rule-by-call for tt-rule-by-call.
message
"Вы действительно хотите удалить привязку к этой функции?"
view-as alert-box question button yes-no update glog.
if not glog then do:
  undo, return error.
end.
find first buf_tt-layout-elem-rule where
recid(buf_tt-layout-elem-rule) = recid(tt-layout-elem-rule).
IF buf_tt-layout-elem-rule.is-mandatory =INTEGER('1':U) THEN DO:
   MESSAGE
   "Нельзя удалять обязательный элемент раскладки!"
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN ERROR.
END.
glog = br-layout-elem-rule:select-next-row() in frame Dialog-Frame.
if not glog then glog = br-layout-elem-rule:select-prev-row().
if glog then v-recid = recid(tt-layout-elem-rule).
find first buf_tt-rule-by-call where
         buf_tt-rule-by-call.call_id = buf_tt-layout-elem-rule.uniq-key-rec.
for each buf_tt-rule-call-param where
    buf_tt-rule-call-param.call_id = buf_tt-layout-elem-rule.uniq-key-rec:
  delete buf_tt-rule-call-param.
end.
FIND FIRST buf_tt-layout-elem WHERE
           buf_tt-layout-elem.layout-type = tt-layout.layout-type
    AND    buf_tt-layout-elem.device-type = tt-layout.device-type
    AND    buf_tt-layout-elem.mode-id = buf_tt-layout-elem-rule.mode-id
    AND    buf_tt-layout-elem.widget-id = buf_tt-layout-elem-rule.WIDGET-ID NO-ERROR.
IF AVAILABLE buf_tt-layout-elem THEN DO:
    buf_tt-layout-elem.is-DEFINe = NO.
END.
delete buf_tt-layout-elem-rule.
delete buf_tt-rule-by-call.
run openbr in this-procedure.
run openbr2 in this-procedure.
reposition br-layout-elem-rule to recid v-recid no-error.
apply "entry" to br-layout-elem-rule in frame Dialog-Frame .
apply "value-changed" to br-layout-elem-rule in frame Dialog-Frame .
run process-add-del in this-procedure .
END PROCEDURE.
PROCEDURE proc-layout-elem-rule-i :
define parameter buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
assign
f-elem-label = buf_tt-layout-elem-rule.elem-label
f-image-id-up = buf_tt-layout-elem-rule.image-id-up
f-image-id-down = buf_tt-layout-elem-rule.image-id-down
f-image-id-insen = buf_tt-layout-elem-rule.image-id-insen
.
hide
br-available in frame Dialog-Frame
b-add
b-del
in frame Dialog-Frame.
disable
b-add
b-del
with frame Dialog-Frame.
display
f-elem-label
e-elem-tooltip
l-elem-tooltip
f-image-id-up
f-image-id-down
f-image-id-insen
with frame Dialog-Frame.
e-elem-tooltip:screen-value in frame Dialog-Frame = buf_tt-layout-elem-rule.elem-tooltip.
display
b-br-available
with frame Dialog-Frame.
enable
b-br-available
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    RETURN.
END.
v-rec = recid(locked_layout).
ASSIGN
FRAME Dialog-Frame
tt-layout.layout-type
tt-layout.layout-id
tt-layout.device-type
tt-layout.layout-name
tt-layout.is-default
tt-layout.des
.
run adm/layout1.p ( INPUT (p-mode + (if v-admin then (chr(44) + "admin") else ''))
                ,INPUT NO
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-layout.layout-id
                ,INPUT tt-layout.layout-type
                ,INPUT tt-layout.device-type
                ,INPUT tt-layout.layout-name
                ,INPUT tt-layout.is-default
                ,input tt-layout.des
                ,input table tt-rule-by-call
                ,input table tt-layout-elem-rule
                ,input table tt-rule-call-param
                ) no-error.
if error-status:error then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
p-rec = v-rec.
END PROCEDURE.
PROCEDURE proc-value-change-device-type :
DEFINE INPUT PARAMETER p-option AS LOGICAL NO-UNDO.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
IF p-option THEN DO:
  find first buf_tt-layout-elem-rule no-error.
  if available buf_tt-layout-elem-rule then do:
    message
    substitute("Вы уже определили функции для элементов раскладки,&1" +
                "поэтому сменить тип устройства невозможно.&1" +
              "Для смены типа устройства сначала удалите все определения или определите новую раскладку"
              , chr(10))
    view-as alert-box error.
    display
    tt-layout.device-type
    with frame Dialog-Frame.
    return no-apply.
  end.
END.
assign
tt-layout.device-type.
run proc-add-mandatory IN THIS-PROCEDURE ( INPUT tt-layout.layout-type
                                          ,INPUT tt-layout.device-type).
run fill-elem in this-procedure .
run openbr in this-procedure.
run openbr2 in this-procedure.
reposition br-layout-elem-rule to row 1 no-error.
apply "entry" to br-layout-elem-rule in frame Dialog-Frame .
apply "value-changed" to br-layout-elem-rule in frame Dialog-Frame .
run process-add-del in this-procedure .
END PROCEDURE.
PROCEDURE proc-value-change-layout-type :
DEFINE INPUT PARAMETER p-option AS LOGICAL NO-UNDO.
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
IF p-option THEN DO:
    find first buf_tt-layout-elem-rule no-error.
    if available buf_tt-layout-elem-rule then do:
      message
      substitute("Вы уже определили функции для элементов раскладки,&1" +
                  "поэтому сменить тип раскладки невозможно.&1" +
                 "Для смены типа раскладки сначала удалите все определения или определите новую раскладку")
      view-as alert-box error.
      display
      tt-layout.layout-type
      with frame Dialog-Frame.
      return no-apply.
    end.
END.
assign
tt-layout.layout-type.
CASE tt-layout.layout-type:
  WHEN 'th-pos-keyboard':U  THEN DO:
      ASSIGN
      tt-layout.device-type:LIST-ITEMS = 'IBM-50':U.
      tt-layout-elem-rule.mode-id:visible in browse br-layout-elem-rule = no.
      tt-layout-elem.mode-id:visible in browse br-available = no.
  END.
  WHEN 'th-pos-screen':U  THEN DO:
      ASSIGN
      tt-layout.device-type:LIST-ITEMS = 'Screen,TouchScreen':U.
      tt-layout-elem-rule.mode-id:visible in browse br-layout-elem-rule = yes.
      tt-layout-elem.mode-id:visible in browse br-available = yes.
  END.
END CASE.
run fill-cb-mode-id in this-procedure ( input tt-layout.layout-type).
run proc-add-mandatory IN THIS-PROCEDURE ( INPUT tt-layout.layout-type
                                          ,INPUT tt-layout.device-type).
run fill-elem in this-procedure .
run openbr in this-procedure.
run openbr2 in this-procedure.
reposition br-layout-elem-rule to row 1 no-error.
apply "entry" to br-layout-elem-rule in frame Dialog-Frame .
apply "value-changed" to br-layout-elem-rule in frame Dialog-Frame .
run process-add-del in this-procedure .
END PROCEDURE.
PROCEDURE proc-view-br-available :
hide
f-elem-label in frame Dialog-Frame
l-elem-tooltip
e-elem-tooltip
f-image-id-up
f-image-id-down
f-image-id-insen
in frame Dialog-Frame.
display
b-lkp
with frame Dialog-Frame.
enable
b-lkp
with frame Dialog-Frame.
enable
br-available
b-add when p-mode <> 'ПРОСМОТР':U
b-del when p-mode <> 'ПРОСМОТР':U
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE process-add-del :
define buffer buf_tt-layout-elem-rule for tt-layout-elem-rule.
find first buf_tt-layout-elem-rule  no-error.
if available buf_tt-layout-elem-rule then do:
  disable
  tt-layout.layout-type
  tt-layout.device-type
  tt-layout.is-default
  with frame Dialog-Frame.
end.
else do:
  if p-mode <> 'ПРОСМОТР':U then do:
    enable
    tt-layout.layout-type
    tt-layout.device-type
    tt-layout.is-default WHEN (v-admin and p-mode <> 'ПРОСМОТР':U)
    with frame Dialog-Frame.
  end.
end.
END PROCEDURE.
FUNCTION get-call#-id RETURNS INTEGER
  ( INPUT p-call-id AS CHARACTER ) :
DEFINE VARIABLE v-call#-id AS INTEGER NO-UNDO.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_c-rule-by-call for ub.c-rule-by-call .
find first buf_rule-by-call no-lock where
          buf_rule-by-call.call_id = p-call-id no-error .
if available buf_rule-by-call then do:
  v-call#-id = buf_rule-by-call.call#_id.
  return v-call#-id.
end.
find first buf_c-rule-by-call no-lock where
          buf_c-rule-by-call.call_id = p-call-id no-error .
if available buf_c-rule-by-call then do:
  v-call#-id = buf_c-rule-by-call.call#_id.
  return v-call#-id.
end.
IF v-call#-id = 0 THEN DO:
   assign
   v-call#-id = v-gl-call#-id - 1
   v-gl-call#-id = v-gl-call#-id - 1
   .
END.
RETURN v-call#-id.
END FUNCTION.
