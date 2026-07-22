DEFINE BUFFER locked_rule-profile FOR ub.rule-profile.
DEFINE BUFFER locked_ruledict FOR ub.ruledict.
DEFINE TEMP-TABLE tt-rule-profile NO-UNDO LIKE ub.rule-profile.
DEFINE NEW SHARED TEMP-TABLE tt-ruledict-param NO-UNDO LIKE ub.ruledict-param.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-profile-id AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-rec AS RECID NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка rule-profile".
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
DEFINE VARIABLE v-param-num-list AS CHARACTER NO-UNDO.
DEFINE BUFFER FIRST_rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_rule-profile FOR ub.rule-profile.
DEFINE BUTTON b-action-item-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.33.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-params
     LABEL "Параметры"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE e-param-value AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 46.5 BY 2.13 NO-UNDO.
DEFINE VARIABLE f-action-item-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 81 BY .67 NO-UNDO.
DEFINE VARIABLE T-parent-feature AS LOGICAL INITIAL no
     LABEL "Только в составе комб.профайла"
     VIEW-AS TOGGLE-BOX
     SIZE 32 BY 1.33 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-rule-profile SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-params AT ROW 1 COL 41 WIDGET-ID 30
     B-Help AT ROW 1 COL 95
     T-parent-feature AT ROW 2.33 COL 66 WIDGET-ID 64
     tt-rule-profile.profile_id AT ROW 2.57 COL 14 COLON-ALIGNED WIDGET-ID 4
          LABEL "Профайл"
          VIEW-AS FILL-IN NATIVE
          SIZE 10 BY 1
     tt-rule-profile.short-name AT ROW 2.57 COL 48.5 COLON-ALIGNED WIDGET-ID 36
          LABEL "Псевдоним"
          VIEW-AS FILL-IN NATIVE
          SIZE 11 BY 1
     tt-rule-profile.profile-type AT ROW 4.2 COL 14 COLON-ALIGNED WIDGET-ID 14
          LABEL "Тип" FORMAT "x(32)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEMS "Item 1"
          DROP-DOWN-LIST
          SIZE 34 BY 1
     tt-rule-profile.is_dynamic AT ROW 4.2 COL 50.5 HELP
          "" NO-LABEL WIDGET-ID 60
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Редактир", yes,
"Нередактир", no,
"Условно", ?
          SIZE 48.5 BY 1
     tt-rule-profile.param-code AT ROW 5.27 COL 48.5 COLON-ALIGNED WIDGET-ID 32
          LABEL "Конф.параметр, необходимый для включения"
          VIEW-AS FILL-IN NATIVE
          SIZE 9 BY 1
     tt-rule-profile.param-value AT ROW 6.33 COL 48.5 COLON-ALIGNED WIDGET-ID 34
          LABEL "Значение параметра"
          VIEW-AS FILL-IN NATIVE
          SIZE 46.5 BY 1
     e-param-value AT ROW 7.4 COL 50.5 NO-LABEL WIDGET-ID 66
     tt-rule-profile.action-item-id AT ROW 9.53 COL 48.5 COLON-ALIGNED WIDGET-ID 38
          LABEL "Идентификатор права" FORMAT "X(55)"
          VIEW-AS FILL-IN NATIVE
          SIZE 35.5 BY 1
     b-action-item-id AT ROW 9.53 COL 87 WIDGET-ID 50
     tt-rule-profile.action-item-context AT ROW 11.67 COL 50.5 NO-LABEL WIDGET-ID 42
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U,
"Item 2", "2":U,
"Item 3", "3":U
          SIZE 34.5 BY 1.07
     tt-rule-profile.custom-param-form AT ROW 12.73 COL 2.5 NO-LABEL WIDGET-ID 54
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", 1,
"Item 2", 2
          SIZE 68 BY 1
     tt-rule-profile.reusable-params AT ROW 13.8 COL 49 COLON-ALIGNED WIDGET-ID 58
          LABEL "Повторно используемо" FORMAT "x(20)"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     tt-rule-profile.name AT ROW 15.13 COL 1 NO-LABEL WIDGET-ID 8
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 1.7
     tt-rule-profile.documentation AT ROW 17 COL 1 NO-LABEL WIDGET-ID 16
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 98 BY 3.27
     f-action-item-name AT ROW 10.87 COL 15 COLON-ALIGNED NO-LABEL WIDGET-ID 52
     "Название" VIEW-AS TEXT
          SIZE 14.5 BY .77 AT ROW 10.87 COL 1 WIDGET-ID 10
     SPACE(83.99) SKIP(8.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       e-param-value:RETURN-INSERTED IN FRAME Dialog-Frame  = TRUE.
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
ON CHOOSE OF b-action-item-id IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_action-item FOR ub.action-item.
FIND FIRST buf_action-item NO-LOCK WHERE
         buf_action-item.action-head-code = tt-rule-profile.action-head-code
     AND buf_action-item.action-item-id = tt-rule-profile.action-item-id
    AND buf_action-item.action-item-context = tt-rule-profile.action-item-context NO-ERROR.
  IF AVAILABLE buf_action-item  THEN DO:
      v-rid-list = STRING(RECID(buf_action-item)).
  END.
  run adm/actnitem.w ( INPUT parparentproc
                      ,INPUT "b-sel"
                      ,INPUT-OUTPUT v-rid-list) NO-ERROR.
  IF v-rid-list <> '' THEN DO:
    FIND FIRST buf_action-item NO-LOCK WHERE
              recid(buf_action-item) = integer(v-rid-list) NO-ERROR.
    IF AVAILABLE buf_action-item THEN DO:
        ASSIGN
        tt-rule-profile.action-head-code = buf_action-item.action-head-code
        tt-rule-profile.action-item-id = buf_action-item.action-item-id
        tt-rule-profile.action-item-context = buf_action-item.action-item-context
        .
        DISPLAY
        tt-rule-profile.action-item-id
        tt-rule-profile.action-item-context
        buf_action-item.action-item-name @ f-action-item-name
        WITH FRAME Dialog-Frame.
    END.
  END.
  ELSE DO:
    BELL.
  END.
END.
ON CHOOSE OF b-params IN FRAME Dialog-Frame
DO:
  RUN proc-b-params IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
      UNDO, RETURN NO-APPLY.
  END.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
    FIND FIRST first_rule-profile EXCLUSIVE-LOCK.
    CREATE tt-rule-profile.
    ASSIGN
    tt-rule-profile.action-head-code = 0
    .
  END.
  else do:
    IF p-mode = 'ИЗМЕНЕНИЕ':U THEN DO:
      FIND FIRST LOCKED_rule-profile EXCLUSIVE-LOCK WHERE
                LOCKED_rule-profile.profile_id = p-profile-id .
    END.
    IF p-mode = 'ПРОСМОТР':U THEN DO:
        FIND FIRST LOCKED_rule-profile no-LOCK WHERE
                  LOCKED_rule-profile.profile_id = p-profile-id  NO-ERROR.
    END.
    create tt-rule-profile.
    buffer-copy locked_rule-profile to tt-rule-profile.
  end.
  RUN fill-table  IN THIS-PROCEDURE.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-rule-profile SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY T-parent-feature e-param-value f-action-item-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-rule-profile THEN
    DISPLAY tt-rule-profile.profile_id tt-rule-profile.short-name
          tt-rule-profile.profile-type tt-rule-profile.is_dynamic
          tt-rule-profile.param-code tt-rule-profile.param-value
          tt-rule-profile.action-item-id tt-rule-profile.action-item-context
          tt-rule-profile.custom-param-form tt-rule-profile.reusable-params
          tt-rule-profile.name tt-rule-profile.documentation
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-params B-Help T-parent-feature
         tt-rule-profile.profile_id tt-rule-profile.short-name
         tt-rule-profile.profile-type tt-rule-profile.is_dynamic
         tt-rule-profile.param-code e-param-value
         tt-rule-profile.action-item-id b-action-item-id
         tt-rule-profile.action-item-context tt-rule-profile.custom-param-form
         tt-rule-profile.reusable-params tt-rule-profile.name
         tt-rule-profile.documentation f-action-item-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-table :
DEFINE BUFFER buf_tt-ruledict-param FOR tt-ruledict-param.
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
DEFINE VARIABLE v-uniq-key-rec AS CHARACTER NO-UNDO.
FOR EACH tt-ruledict-param:
  DELETE tt-ruledict-param.
END.
CASE p-mode:
  WHEN 'ДОБАВЛЕНИЕ':U THEN DO:
  END.
  WHEN 'ИЗМЕНЕНИЕ':U THEN DO:
    run gen-key-rec in this-procedure (
                                        input 'rule-profile':U
                                        ,input  buffer locked_rule-profile:handle
                                        ,output v-uniq-key-rec
                                        ).
    FIND FIRST locked_ruledict EXCLUSIVE-LOCK WHERE
              locked_ruledict.ENTRY-type = 'rule-profile':U
        AND locked_ruledict.uniq-key-rec = v-uniq-key-rec NO-ERROR.
    FOR EACH buf_ruledict-param NO-LOCK WHERE
          buf_ruledict-param.entry-id = locked_ruledict.ENTRY-id:
      CREATE buf_tt-ruledict-param.
      BUFFER-COPY buf_ruledict-param TO buf_tt-ruledict-param.
    END.
  END.
  WHEN 'ПРОСМОТР':U THEN DO:
      run gen-key-rec in this-procedure (
                                          input 'rule-profile':U
                                          ,input  buffer locked_rule-profile:handle
                                          ,output v-uniq-key-rec
                                          ).
      FIND FIRST locked_ruledict no-LOCK WHERE
                locked_ruledict.ENTRY-type = 'rule-profile':U
          AND locked_ruledict.uniq-key-rec = v-uniq-key-rec NO-ERROR.
      FOR EACH buf_ruledict-param NO-LOCK WHERE
            buf_ruledict-param.entry-id = locked_ruledict.ENTRY-id:
        CREATE buf_tt-ruledict-param.
        BUFFER-COPY buf_ruledict-param TO buf_tt-ruledict-param.
      END.
  END.
END CASE.
END PROCEDURE.
PROCEDURE fill-tt-ruledict-param :
DEFINE INPUT PARAMETER p-bh AS HANDLE NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
FOR EACH tt-ruledict-param
ON error  UNDO, RETURN ERROR
ON stop  UNDO, RETURN ERROR:
  ASSIGN
  glog = p-bh:BUFFER-CREATE() NO-ERROR.
  IF NOT glog THEN DO:
     UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  END.
  ASSIGN
  glog = p-bh:BUFFER-Copy( BUFFER tt-ruledict-param:HANDLE) NO-ERROR.
  IF NOT glog THEN DO:
     UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  END.
END.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE BUFFER buf_action-item FOR ub.action-item.
IF tt-rule-profile.action-item-id <> '' THEN DO:
  FIND FIRST buf_action-item NO-LOCK WHERE
             buf_action-item.action-head-code = tt-rule-profile.action-head-code
         AND buf_action-item.action-item-id = tt-rule-profile.action-item-id
        AND buf_action-item.action-item-context = tt-rule-profile.action-item-context NO-ERROR.
END.
ASSIGN
tt-rule-profile.profile-type:LIST-ITEMS IN FRAME Dialog-Frame = 'dis-card-type,goods,clients,gds-grp,cli-grp,chk-doc_IBS-TH,chk-doc_IBS-TH-MOB,edoc,thref,pdf,rep,ord,cmb,fdoc':U
e-param-value:SCREEN-VALUE = replace(tt-rule-profile.param-value, chr(4), chr(10))
tt-rule-profile.action-item-context:RADIO-BUTTONS in FRAME Dialog-Frame =
'global':U + chr(44) + 'global':U + chr(44) +
'firm':U + chr(44) + 'firm':U +  chr(44) +
'object':U + chr(44) + 'object':U
tt-rule-profile.custom-param-form:RADIO-BUTTONS in FRAME Dialog-Frame =
"Станд. форма для ввода параметров" + chr(44) + "0" + chr(44) +
"Спец. форма для ввода параметров" + chr(44) + "1"
.
t-parent-feature = (if tt-rule-profile.parent-feature = integer('1':U)
                    then  yes
                    else no ).
IF AVAILABLE tt-rule-profile THEN
DISPLAY
t-parent-feature
tt-rule-profile.profile-type
tt-rule-profile.profile_id
tt-rule-profile.name
tt-rule-profile.is_dynamic
tt-rule-profile.param-code
tt-rule-profile.param-value
tt-rule-profile.short-name
tt-rule-profile.documentation
tt-rule-profile.action-item-context
tt-rule-profile.action-item-id
tt-rule-profile.custom-param-form
tt-rule-profile.reusable-param
WITH FRAME Dialog-Frame .
IF available buf_action-item THEN DO:
  DISPLAY
  buf_action-item.action-item-name @ f-action-item-name
  WITH FRAME Dialog-Frame .
END.
ELSE DO:
  IF p-mode = 'ПРОСМОТР':U THEN
  HIDE
  tt-rule-profile.action-item-context
  tt-rule-profile.action-item-id
  f-action-item-name
  b-action-item-id
  IN FRAME Dialog-Frame.
END.
ENABLE
B-exit  when p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
b-params WHEN p-mode <> 'ДОБАВЛЕНИЕ':U
t-parent-feature when p-mode <> 'ПРОСМОТР':U
tt-rule-profile.profile-type  when p-mode <> 'ПРОСМОТР':U
tt-rule-profile.profile_id when p-mode = 'ДОБАВЛЕНИЕ':U
tt-rule-profile.name      when p-mode <> 'ПРОСМОТР':U
tt-rule-profile.short-name when p-mode <> 'ПРОСМОТР':U
tt-rule-profile.is_dynamic when p-mode <> 'ПРОСМОТР':U
tt-rule-profile.documentation
tt-rule-profile.param-code when p-mode <> 'ПРОСМОТР':U
tt-rule-profile.action-item-context when p-mode <> 'ПРОСМОТР':U
tt-rule-profile.action-item-id when p-mode <> 'ПРОСМОТР':U
b-action-item-id when p-mode <> 'ПРОСМОТР':U
tt-rule-profile.custom-param-form when p-mode <> 'ПРОСМОТР':U
tt-rule-profile.reusable-param when p-mode <> 'ПРОСМОТР':U
e-param-value
WITH FRAME Dialog-Frame .
if p-mode = 'ПРОСМОТР':U then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  tt-rule-profile.NAME:READ-ONLY = YES
  tt-rule-profile.documentation:READ-ONLY = YES
  e-param-value:READ-ONLY = YES
  .
  hide
  b-exit
  tt-rule-profile.reusable-param
  in frame Dialog-Frame .
end.
VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-params :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-return-value as character no-undo .
DEFINE BUFFER buf_tt-ruledict-param FOR tt-ruledict-param.
IF p-mode = 'ПРОСМОТР':U THEN DO:
  FIND FIRST buf_tt-ruledict-param NO-ERROR.
  IF NOT AVAILABLE buf_tt-ruledict-param THEN DO:
    MESSAGE
    "У этого профайла нет параметров"
    VIEW-AS ALERT-BOX.
    RETURN.
  END.
END.
ELSE DO:
  v-param-num-list = '':U.
END.
run rul/ruledict-param-s.w ( INPUT parparentproc
                            ,input this-procedure:handle
                            ,INPUT (IF p-mode = 'ИЗМЕНЕНИЕ':U
                                    OR p-mode = 'ДОБАВЛЕНИЕ':U
                                    THEN "b-add"
                                    ELSE "":U)
                            ,INPUT (if p-mode = 'ПРОСМОТР':U
                                    then "entry-id"
                                    else 'ИЗМЕНЕНИЕ':U)
                            ,INPUT (if p-mode = 'ИЗМЕНЕНИЕ':U
                                    or p-mode = 'ПРОСМОТР':U
                                    then locked_ruledict.entry-id
                                    else 0)
                            ,input 'rule-profile':U
                            ,INPUT-OUTPUT v-rid-list) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
   message error-status:get-message(1) view-as alert-box .
   UNDO, RETURN ERROR.
END.
v-return-value = return-value .
if (p-mode = 'ИЗМЕНЕНИЕ':U
or p-mode = 'ДОБАВЛЕНИЕ':U)
and v-return-value <> "quit" then do:
  FOR EACH tt-ruledict-param:
    IF LOOKUP(string(tt-ruledict-param.param-num), v-param-num-list) = 0 THEN DO:
        DELETE tt-ruledict-param.
    END.
  END.
end.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rec AS recID  NO-UNDO.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    RETURN.
END.
v-rec = p-rec.
ASSIGN
FRAME Dialog-Frame
t-parent-feature
tt-rule-profile.profile-type
tt-rule-profile.profile_id
tt-rule-profile.NAME
tt-rule-profile.is_dynamic
tt-rule-profile.param-code
tt-rule-profile.param-value = replace(e-param-value:SCREEN-VALUE, chr(10), chr(4))
tt-rule-profile.short-name
tt-rule-profile.action-item-context
tt-rule-profile.action-item-id
tt-rule-profile.custom-param-form
tt-rule-profile.reusable-params
tt-rule-profile.parent-feature = (if t-parent-feature
                                  then integer('1':U)
                                  else integer('0':U))
.
run rul/rule-profile1.p ( INPUT p-mode
                ,INPUT NO
                ,INPUT-OUTPUT v-rec
                ,INPUT tt-rule-profile.profile_id
                ,INPUT tt-rule-profile.profile-type
                ,INPUT tt-rule-profile.name
                ,INPUT tt-rule-profile.is_dynamic
                ,INPUT tt-rule-profile.documentation:screen-value
                ,INPUT tt-rule-profile.param-code
                ,INPUT tt-rule-profile.param-value
                ,INPUT tt-rule-profile.short-name
                ,INPUT tt-rule-profile.action-head-code
                ,INPUT tt-rule-profile.action-item-id
                ,INPUT tt-rule-profile.action-item-context
                ,INPUT tt-rule-profile.custom-param-form
                ,input tt-rule-profile.reusable-params
                ,input tt-rule-profile.parent-feature
                ,input table tt-ruledict-param
                ) no-error.
if error-status:error then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE save-tt-ruledict-param :
DEFINE INPUT PARAMETER p-bh AS HANDLE NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
FIND FIRST tt-ruledict-param WHERE
           tt-ruledict-param.param-num = p-bh::param-num NO-ERROR.
IF NOT AVAILABLE tt-ruledict-param THEN DO:
   CREATE tt-ruledict-param.
END.
ASSIGN
glog = BUFFER tt-ruledict-param:handle:BUFFER-Copy( p-bh) NO-ERROR.
IF NOT glog THEN DO:
  UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
END.
v-param-num-list = v-param-num-list + chr(44) + STRING( tt-ruledict-param.param-num).
END PROCEDURE.
