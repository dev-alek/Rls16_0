DEFINE TEMP-TABLE tt-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_rp-rule-param FOR ub.rp-rule-param.
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_ruledict-param FOR ub.ruledict-param.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-call-handle as handle no-undo .
DEFINE INPUT PARAMETER bttns AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-list-mode AS CHARACTER NO-UNDO.
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt0-rule-call-param.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание и просмотр параметров вызова правил для профайла 8".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info3 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info3, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info3, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info3 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info3, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info3, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info3, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info3, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info3, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info3, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
FUNCTION calldscr returns character ( input p-call-id as character):
define variable v-descr as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo.
define variable v-prop-label as character no-undo .
define variable v-node-label as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-label as character no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-map for ub.prop-map.
run gen-key-fv in this-procedure ( input p-call-id
                                  ,output v-field-list
                                  ,output v-value-list) no-error .
if error-status:error then return p-call-id.
CASE entry(1, p-call-id, chr(3)):
  when 'dis-card-type':U then do:
    v-descr = substitute("Тип ДК: эмитент &1 тип: &2"
                         ,integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ,entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card':U then do:
    v-descr = substitute("ДК: № &1"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card-property':U then do:
    v-dt-code = integer(entry(lookup("dt-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-node-code = integer(entry(lookup("node-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-host-code = integer(entry(lookup("host-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-obj-type = entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3)) .
    v-obj-code = integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    find first buf_prop-ref no-lock where
              buf_prop-ref.dt-code = v-dt-code no-error .
    if available buf_prop-ref then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error .
      v-prop-label = buf_prop-head.prop-label.
      find first buf_prop-map no-lock where
                buf_prop-map.dtm-code = buf_prop-ref.dtm-code
            and buf_prop-map.node-code = v-node-code no-error .
      if available buf_prop-map then do:
        v-label = buf_prop-map.node-label.
      end.
    end.
    v-descr = substitute("ДК: № &1 &2:&3 &4"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ,v-prop-label
                         ,v-label
                         ,get-region(v-host-code, v-obj-type, v-obj-code)
                         ).
  end.
  when 'clients':U then do:
    v-descr = substitute("&1&2"
                         ,entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ,integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ).
  end.
  when 'ext-system':U then do:
    v-descr = substitute("Внешняя система &1"
                         ,integer(entry(lookup("esys-id", v-field-list, chr(3)), v-value-list, chr(3)))
                         ).
  end.
  WHEN 'thbj-attr':U then do:
    if entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum':U
    or entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum_obj':U
    then do:
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'goods':U then do:
        v-descr = "Операции с товарами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'clients':U then do:
        v-descr = "Операции с клиентами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'gds-grp':U then do:
        v-descr = "Операции с группами товаров".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'cli-grp':U then do:
        v-descr = "Операции с группами клиентов".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th':U then do:
        v-descr = "Операции с чеками на POS IBS-TH".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th-mob':U then do:
        v-descr = "Операции с чеками на POS IBS-TH-MOB".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'edoc':U then do:
        v-descr = "Операции в системе электронного документооборота".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'thref':U then do:
        v-descr = "Операции со справочниками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'pdf':U then do:
        v-descr = "Операции с ДНЦ и переоценками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rep':U then do:
        v-descr = "Отчеты".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'ord':U then do:
        v-descr = "Операции с заказами".
      end.
    end.
  end.
  when 'cash-desk':U then do:
    v-descr = substitute("БД &1 Маг &2 Касса № &4 &3"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("cash-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("pos-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'ext-file':U then do:
    v-descr = substitute("БД &1 Файл № &3 (из БД &2)"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("from-db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("file-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
end case.
return v-descr.
end function.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-ch AS WIDGET-HANDLE NO-UNDO EXTENT 6.
DEFINE VARIABLE v-dflt-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rp-dflt-rec AS RECID NO-UNDO.
DEFINE VARIABLE v-rcps-entry-id AS INTEGER NO-UNDO.
DEFINE VARIABLE v-uniq-key-rec AS character NO-UNDO.
DEFINE VARIABLE rule-display-option AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_Rule-profile FOR ub.rule-profile.
DEFINE BUFFER buf_Ruledict FOR ub.ruledict.
DEFINE BUFFER call_tt-rule-call-param FOR tt-rule-call-param.
define buffer term_tt-rule-call-param for tt-rule-call-param.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION propreft-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function propreft-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION propreft-petrol-to-String returns character(input  p-gds-code as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = substitute("petrol-&1", p-gds-code).
return v-date-str.
END FUNCTION.
FUNCTION propreft-string-to-petrol returns integer(input  p-string as character):
define variable v-gds-code as integer no-undo .
assign
v-gds-code = integer(entry(2, p-string, "-")) no-error.
return v-gds-code.
END FUNCTION.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-running-mode as logical no-undo .
DEFINE BUFFER X_dis-rule FOR ub.dis-rule.
DEFINE BUTTON b-dis-rule
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.07.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp-dis-rule
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Просмотр правила скидки".
DEFINE BUTTON b-lkp-prev-dis-rule
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Просмотр правила скидки".
DEFINE BUTTON b-prev-dis-rule
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.07.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sum-id
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3.5 BY 1.07.
DEFINE VARIABLE E-rules AS CHARACTER INITIAL "Проставлять рассчитанный % скидки в карточку ДК при:"
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31.5 BY 2.4
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-caller-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Доп.метка частичных итогов (с типом Период Дат)"
     VIEW-AS FILL-IN
     SIZE 37.5 BY 1 TOOLTIP "Можно оставить пустой" NO-UNDO.
DEFINE VARIABLE f-dis-rule-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-nd-caller-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Доп.метка среза скидок в след. периоде (с типом Период Дат)"
     VIEW-AS FILL-IN NATIVE
     SIZE 37.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-prev-dis-rule-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 98 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-prev-rule-num AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "Правило зависимости СУММА НАКОПЛЕНИЙ  -> % СКИДКИ по ДК в предыд. периоде"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-rule-num AS INTEGER FORMAT ">>>>>>9":U INITIAL 0
     LABEL "Правило зависимости СУММА НАКОПЛЕНИЙ  -> % СКИДКИ по ДК в текущем периоде"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-sum-id AS CHARACTER FORMAT "X(256)":U
     LABEL "Идентификатор среза скидок в следующем периоде"
     VIEW-AS FILL-IN
     SIZE 31 BY 1 NO-UNDO.
DEFINE VARIABLE l-r-b AS CHARACTER FORMAT "X(256)":U INITIAL "Расчет вести от:"
      VIEW-AS TEXT
     SIZE 22.5 BY .67 NO-UNDO.
DEFINE VARIABLE rs-r-b AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "rubl",
"Item 1", "base"
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE t-is-over AS LOGICAL INITIAL no
     LABEL "Учет перевыпуска карт"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE VARIABLE T-rule-recalc AS LOGICAL INITIAL no
     LABEL "Принудительный пересчет"
     VIEW-AS TOGGLE-BOX
     SIZE 26.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-rule-sale-in AS LOGICAL INITIAL no
     LABEL "Касса,возврат"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE T-rule-sale-out AS LOGICAL INITIAL no
     LABEL "Касса,продажа"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY 1 NO-UNDO.
DEFINE VARIABLE T-rule-trn-in AS LOGICAL INITIAL no
     LABEL "Накладная,возврат"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE T-rule-trn-out AS LOGICAL INITIAL no
     LABEL "Накладная,продажа"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE QUERY BR-rcp FOR
      X_ruledict-param,
      X_rp-rule-param,
      tt-rule-call-param,
      TERM_tt-rule-call-param SCROLLING.
DEFINE BROWSE BR-rcp
  QUERY BR-rcp DISPLAY
      X_rp-rule-param.rp-param-name COLUMN-LABEL "Название пар-ра!профайла" FORMAT "X(20)" width 16
term_tt-rule-call-param.codex_id COLUMN-LABEL "Кодекс"
term_tt-rule-call-param.ruleset_id COLUMN-LABEL "Набор"
term_tt-rule-call-param.order_id  COLUMN-LABEL "Порядок!вызова"
term_tt-rule-call-param.rule_id  COLUMN-LABEL "Правило"
term_tt-rule-call-param.profile_id  COLUMN-LABEL "Профайл"
term_tt-rule-call-param.once-more COLUMN-LABEL "№!Привязки"
(if lookup (term_tt-rule-call-param.param-data-type, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle,handle,blob,clob,class,com-handle,longchar,int64':U) > 0 then entry (lookup (term_tt-rule-call-param.param-data-type, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle,handle,blob,clob,class,com-handle,longchar,int64':U), 'строка,дата,дата-время,дата-время-з,десятичное,целое,пусто,логическое,память,двоичные,номер записи,Номер Записи,ссылка,ссылка,Больш.бин.объект,Больш.стр.объект,Объект,COM-объект,Длинная строка,64Целое':U) else term_tt-rule-call-param.param-data-type) COLUMN-LABEL "Тип пар-ра" FORMAT "X(12)"
term_tt-rule-call-param.param-num COLUMN-LABEL "№!пар-ра" FORMAT ">9"
TERM_tt-rule-call-param.p-index COLUMN-LABEL "Инд!екс" FORMAT ">9"
term_tt-rule-call-param.param-name COLUMN-LABEL "Название пар-ра!правила" FORMAT "X(16)"
term_tt-rule-call-param.param-label COLUMN-LABEL "Название пар-ра" FORMAT "X(255)" WIDTH 30
entry (lookup (term_tt-rule-call-param.param-mode, 'input,output,input-output,buffer,input table,output table,input-output table':u), 'вх,вых,вх-вых,курсор,вх табл,вых табл,вх/вых табл':u) COLUMN-LABEL "Вид!пар-ра"
get-param-value( INPUT term_tt-rule-call-param.param-data-type
                ,INPUT term_tt-rule-call-param.param-2-data-type
                ,INPUT term_tt-rule-call-param.param-3-data-type
                ,INPUT TERM_tt-rule-call-param.p-index
                ,INPUT term_tt-rule-call-param.param-value-character
                ,INPUT term_tt-rule-call-param.param-value-date
                ,INPUT term_tt-rule-call-param.param-value-decimal
                ,INPUT term_tt-rule-call-param.param-value-integer
                ,INPUT term_tt-rule-call-param.param-value-logical) COLUMN-LABEL "Значение" FORMAT "X(255)" WIDTH 26
(IF term_tt-rule-call-param.param-data-type = 'character':U
 THEN term_tt-rule-call-param.param-value-character
 ELSE '':U) COLUMN-LABEL "Значение!(строковое)" FORMAT "X(26)"
(IF term_tt-rule-call-param.param-data-type = 'date':U
THEN STRING(term_tt-rule-call-param.param-value-date, "99/99/9999")
ELSE '':U)    COLUMN-LABEL "Значение!(Дата)" FORMAT "X(10)" WIDTH 12
(IF term_tt-rule-call-param.param-data-type = 'decimal':U
THEN STRING(term_tt-rule-call-param.param-value-decimal)
ELSE '':U) COLUMN-LABEL "Значение!(Десятичное)"   FORMAT "X(16)"
(IF term_tt-rule-call-param.param-data-type = 'integer':U
THEN STRING(term_tt-rule-call-param.param-value-integer)
ELSE '':U) COLUMN-LABEL "Значение!(Целое)" FORMAT "X(10)"
(IF term_tt-rule-call-param.param-data-type = 'logical':U
THEN STRING(term_tt-rule-call-param.param-value-logical, "+/-")
ELSE '':U) COLUMN-LABEL "Значение!(Логическое)" FORMAT "X(2)"
calldscr(tt-rule-call-param.call_id) COLUMN-LABEL  "Точка вызова" FORMAT "X(40)"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 6
         FONT 4 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     rs-r-b AT ROW 2.07 COL 25.5 NO-LABEL WIDGET-ID 106
     t-is-over AT ROW 2.07 COL 41 WIDGET-ID 88
     f-rule-num AT ROW 3.13 COL 75.5 COLON-ALIGNED WIDGET-ID 110
     b-dis-rule AT ROW 3.13 COL 93.5 WIDGET-ID 112
     b-lkp-dis-rule AT ROW 3.13 COL 97 WIDGET-ID 148
     f-prev-rule-num AT ROW 5.27 COL 75.5 COLON-ALIGNED WIDGET-ID 138
     b-prev-dis-rule AT ROW 5.27 COL 94 WIDGET-ID 140
     b-lkp-prev-dis-rule AT ROW 5.27 COL 97 WIDGET-ID 150
     f-caller-id AT ROW 7.4 COL 60 COLON-ALIGNED WIDGET-ID 144
     f-sum-id AT ROW 8.47 COL 60 COLON-ALIGNED WIDGET-ID 114
     b-sum-id AT ROW 8.47 COL 95 WIDGET-ID 116
     f-nd-caller-id AT ROW 9.53 COL 1 WIDGET-ID 146
     E-rules AT ROW 14.6 COL 1 NO-LABEL WIDGET-ID 136
     T-rule-sale-out AT ROW 14.87 COL 33 WIDGET-ID 126
     T-rule-trn-out AT ROW 14.87 COL 51 WIDGET-ID 130
     T-rule-recalc AT ROW 14.87 COL 73 WIDGET-ID 134
     T-rule-sale-in AT ROW 15.87 COL 33 WIDGET-ID 128
     T-rule-trn-in AT ROW 15.87 COL 51 WIDGET-ID 132
     BR-rcp AT ROW 17 COL 1 WIDGET-ID 100
     l-r-b AT ROW 2.07 COL 1.5 NO-LABEL WIDGET-ID 122
     f-dis-rule-name AT ROW 4.2 COL 1 NO-LABEL WIDGET-ID 124
     f-prev-dis-rule-name AT ROW 6.6 COL 1 NO-LABEL WIDGET-ID 142
     SPACE(1.09) SKIP(15.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BR-rcp:HIDDEN  IN FRAME Dialog-Frame                = TRUE.
ASSIGN
       l-r-b:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-dis-rule IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS INTEGER NO-UNDO.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
  run ref/dis-ruls.w (   input  parparentproc
                        ,input 0
                        ,input '':U
                        ,input 0
                        ,input "b-sel,b-add"
                        ,input "upper-rule-num"
                        ,input 63
                        ,input ?
                        ,input 0
                        ,input-output v-sts
                        ,input-OUTPUT v-rid-list) NO-ERROR.
  if v-rid-list <> '':U then do:
    find first buf_dis-rule no-lock where
              recid(buf_dis-rule) = integer(v-rid-list) no-error.
    if not available buf_dis-rule then do:
        MESSAGE substitute("Не найдено правило скидки c recid &1", v-rid-list)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN NO-APPLY.
    end.
    assign
    f-rule-num = buf_dis-rule.rule-num
    .
    DISPLAY
    f-rule-num
    buf_dis-rule.des @ f-dis-rule-name
    WITH FRAME Dialog-Frame.
  end.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE  NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-lkp-dis-rule IN FRAME Dialog-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  IF f-rule-num > 0  THEN
  run ref/show-dr.p ( INPUT parparentproc
                     ,INPUT f-rule-num) NO-ERROR.
END.
ON CHOOSE OF b-lkp-prev-dis-rule IN FRAME Dialog-Frame
DO:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  IF f-prev-rule-num > 0  THEN
  run ref/show-dr.p ( INPUT parparentproc
                     ,INPUT f-prev-rule-num) NO-ERROR.
END.
ON CHOOSE OF b-prev-dis-rule IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-sts AS INTEGER NO-UNDO.
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
  run ref/dis-ruls.w (   input  parparentproc
                        ,input 0
                        ,input '':U
                        ,input 0
                        ,input "b-sel,b-add"
                        ,input "upper-rule-num"
                        ,input 63
                        ,input ?
                        ,input 0
                        ,input-output v-sts
                        ,input-OUTPUT v-rid-list) NO-ERROR.
  if v-rid-list <> '':U then do:
    find first buf_dis-rule no-lock where
              recid(buf_dis-rule) = integer(v-rid-list) no-error.
    if not available buf_dis-rule then do:
        MESSAGE substitute("Не найдено правило скидки c recid &1", v-rid-list)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN NO-APPLY.
    end.
    assign
    f-prev-rule-num = buf_dis-rule.rule-num
    .
    DISPLAY
    f-prev-rule-num
    buf_dis-rule.des @ f-prev-dis-rule-name
    WITH FRAME Dialog-Frame.
  end.
END.
ON CHOOSE OF b-sum-id IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
define buffer buf_prop-ref for ub.prop-ref.
run ref/proprefs.w (   input  parparentproc
                      ,input "b-sel,b-add"
                      ,input "dtm-code"
                      ,input  7
                      ,input '':U
                      ,input '':U
                      ,input-OUTPUT v-rid-list) NO-ERROR.
if v-rid-list = '' then return no-apply.
find first buf_prop-ref no-lock where
          recid(buf_prop-ref) = integer(v-rid-list) no-error.
if not available buf_prop-ref then do:
  MESSAGE
  substitute("Нет среза с recid &1", v-rid-list)
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN NO-APPLY.
end.
f-sum-id = buf_prop-ref.sum-id.
f-nd-caller-id = buf_prop-ref.caller_id.
display
f-sum-id
f-nd-caller-id
with frame Dialog-Frame .
END.
ON VALUE-CHANGED OF t-is-over IN FRAME Dialog-Frame
DO:
   assign
   t-is-over.
END.
ON ROW-DISPLAY OF br-rcp IN frame Dialog-Frame
DO:
  IF AVAIL tt-rule-call-param THEN DO:
    RUN rcps_set-row-color IN THIS-PROCEDURE ( INPUT term_tt-rule-call-param.param-data-type).
  END.
END.
ON f6 anywhere DO:
  ASSIGN
  br-rcp:VISIBLE IN FRAME Dialog-Frame = (NOT br-rcp:VISIBLE IN FRAME Dialog-Frame)
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-rcp :handle
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure rcps_get-profile-id :
define output parameter p-local-profile-id as integer no-undo .
do
on error undo, return error:
p-local-profile-id = p-profile-id.
end.
end procedure.
PROCEDURE rcps_fill-table :
define input parameter p-clear-params as logical no-undo .
if p-clear-params then do:
FOR EACH tt-rule-call-param:
    DELETE tt-rule-call-param.
END.
end.
 FOR EACH tt0-rule-call-param:
   IF p-mode <> 'ДОБАВЛЕНИЕ':U THEN DO:
     IF p-call-id <> '':U and p-call-id <> tt0-rule-call-param.call_id THEN do:
        NEXT.
     end.
     IF p-codex-id <> 0 and p-codex-id <> tt0-rule-call-param.codex_id THEN do:
       NEXT.
     end.
     IF p-ruleset-id <> 0 and p-ruleset-id <> tt0-rule-call-param.ruleset_id THEN do:
       NEXT.
     end.
     IF p-rule-id <> 0 and p-rule-id <> tt0-rule-call-param.RULE_id THEN do:
       NEXT.
     end.
     IF p-order-id <> ? and p-order-id <> tt0-rule-call-param.order_id THEN do:
       NEXT.
     end.
   END.
   if lookup("hidden", tt0-rule-call-param.param-3-data-type) > 0 then do:
     next.
   end.
   IF p-list-mode = 'rp-rule-param':U
   or p-list-mode = 'rp-rule-param':U  + chr(44) + 'все':U
   THEN DO:
      IF p-profile-id <> 0 AND p-profile-id <> tt0-rule-call-param.profile_id THEN do:
        NEXT.
      end.
      IF p-once-more <> ? AND p-once-more <> tt0-rule-call-param.once-more THEN do:
        NEXT.
      end.
   END.
   CREATE tt-rule-call-param.
   BUFFER-COPY tt0-rule-call-param TO tt-rule-call-param.
END.
END PROCEDURE.
procedure rcps_get-value :
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT-output PARAMETER pp-index AS integer NO-UNDO.
DEFINE output parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE output parameter p-value-date AS date NO-UNDO.
DEFINE output parameter p-value-decimal AS decimal NO-UNDO.
DEFINE output parameter p-value-integer AS integer NO-UNDO.
DEFINE output parameter p-value-logical AS logical NO-UNDO.
define variable v-current-index as integer no-undo init -1.
define variable v-start as logical no-undo init yes.
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_term_tt-rule-call-param FOR tt-rule-call-param.
do
on error undo, return error
:
FOR FIRST buf_rp-rule-param WHERE
      buf_rp-rule-param.profile_id = p-profile-id
  AND buf_rp-rule-param.rp-param-name = p-rp-param-name
, each buf_tt-rule-call-param WHERE
   buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
AND buf_tt-rule-call-param.p-index >= pp-index
 ,each buf_term_tt-rule-call-param where
       buf_term_tt-rule-call-param.call_id = buf_tt-rule-call-param.call_id
   and buf_term_tt-rule-call-param.codex_id = buf_tt-rule-call-param.codex_id
   and buf_term_tt-rule-call-param.ruleset_id = buf_tt-rule-call-param.ruleset_id
   and buf_term_tt-rule-call-param.order_id = buf_tt-rule-call-param.order_id
   and buf_term_tt-rule-call-param.param-name = buf_tt-rule-call-param.param-name
   and buf_term_tt-rule-call-param.p-index = buf_tt-rule-call-param.p-index
  by buf_term_tt-rule-call-param.call_id
  by buf_term_tt-rule-call-param.codex_id
  by buf_term_tt-rule-call-param.ruleset_id
  by buf_term_tt-rule-call-param.order_id
  by buf_term_tt-rule-call-param.param-name
  by buf_term_tt-rule-call-param.p-index :
    if v-start
    then do:
      assign
      pp-index = buf_term_tt-rule-call-param.p-index
      p-value-character = buf_term_tt-rule-call-param.param-value-character
      p-value-date      = buf_term_tt-rule-call-param.param-value-date
      p-value-decimal   = buf_term_tt-rule-call-param.param-value-decimal
      p-value-integer   = buf_term_tt-rule-call-param.param-value-integer
      p-value-logical   = buf_term_tt-rule-call-param.param-value-logical
      v-start = no
      .
    end.
    else do:
      if buf_term_tt-rule-call-param.p-index > pp-index then do:
        v-current-index = buf_term_tt-rule-call-param.p-index.
        leave.
      end.
          end.
  end.
  pp-index = v-current-index.
end.
end procedure.
PROCEDURE rcps_proc-b-add :
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-index AS integer NO-UNDO.
define variable v-ind as integer no-undo .
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf0_tt-rule-call-param for tt-rule-call-param.
define buffer buf2_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
FOR FIRST buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf0_tt-rule-call-param WHERE
       buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name:
  LEAVE.
END.
IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  BELL.
  RETURN.
END.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = p-rp-param-name
    and buf_rp-rule-param.profile_id = p-profile-id,
    first buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = buf0_tt-rule-call-param.once-more
    and buf_tt-rule-call-param.p-index = p-index:
  RETURN.
END.
IF lookup("LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  BELL.
  RETURN.
END.
IF buf0_tt-rule-call-param.p-index <> 0 THEN DO:
  BELL.
  RETURN.
END.
find last buf_tt-rule-call-param where
         buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
     and buf_tt-rule-call-param.codex_id = buf0_tt-rule-call-param.codex_id
     and buf_tt-rule-call-param.ruleset_id = buf0_tt-rule-call-param.ruleset_id
     and buf_tt-rule-call-param.order_id = buf0_tt-rule-call-param.order_id
     and buf_tt-rule-call-param.param-name = buf0_tt-rule-call-param.param-name no-error .
if available buf_tt-rule-call-param
and (lookup("LIST", buf_tt-rule-call-param.param-3-data-type) > 0
     or
     lookup("SORTED-LIST", buf_tt-rule-call-param.param-3-data-type) > 0
     )
and buf_tt-rule-call-param.p-index > 0 then do:
  v-ind = buf_tt-rule-call-param.p-index.
end.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = p-rp-param-name
    and buf_rp-rule-param.profile_id = p-profile-id,
    first buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = buf0_tt-rule-call-param.call_id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = buf0_tt-rule-call-param.once-more
    and buf_tt-rule-call-param.p-index = 0
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  create buf2_tt-rule-call-param.
  buffer-copy buf_tt-rule-call-param
  except p-index
  to buf2_tt-rule-call-param
  assign
  buf2_tt-rule-call-param.p-index = v-ind + 1
  .
end.
END PROCEDURE.
PROCEDURE rcps_proc-b-del :
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pp-index AS integer NO-UNDO.
define variable v-ind as integer no-undo .
define variable v-once-more as integer no-undo .
define variable v-call-id as character no-undo .
define buffer buf0_tt-rule-call-param for tt-rule-call-param.
define buffer buf_tt-rule-call-param for tt-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
if pp-index = 0 then do:
  undo, return error substitute("Нельзя удалять корневой параметр &1 (индекс = 0)", p-rp-param-name).
end.
FOR first buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf0_tt-rule-call-param WHERE
       buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
   AND buf0_tt-rule-call-param.p-index = pp-index
   :
  LEAVE.
END.
IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  FOR first buf_rp-rule-param WHERE
            buf_rp-rule-param.profile_id = p-profile-id
        AND buf_rp-rule-param.rp-param-name = p-rp-param-name
      , last buf0_tt-rule-call-param WHERE
        buf0_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    AND buf0_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    AND buf0_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    AND buf0_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    AND buf0_tt-rule-call-param.p-index > pp-index :
    leave.
  end.
  IF NOT AVAILABLE buf0_tt-rule-call-param THEN do:
  return "not-found".
  end.
  else do:
    return ''.
  end.
END.
IF lookup("LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
and lookup("SORTED-LIST", buf0_tt-rule-call-param.param-3-data-type) = 0
THEN DO:
  undo, return error substitute("Можно удалять только параметры типа LIST и SORTED-LIST").
END.
IF lookup("READ-ONLY", buf0_tt-rule-call-param.param-3-data-type) > 0 THEN DO:
  undo, return error substitute("Нельзя удалять  параметры типа READ-ONLY").
END.
for each buf_rp-rule-param where
        buf_rp-rule-param.rp-param-name = buf_rp-rule-param.rp-param-name
    and buf_rp-rule-param.profile_id = buf_rp-rule-param.profile_id,
    each buf_tt-rule-call-param where
        buf_tt-rule-call-param.call_id = p-call-id
    and buf_tt-rule-call-param.profile_id = buf_rp-rule-param.profile_id
    and buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
    and buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf_tt-rule-call-param.once-more = p-once-more
    and buf_tt-rule-call-param.p-index = pp-index
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile ):
    DELETE buf_tt-rule-call-param.
end.
return ''.
END PROCEDURE.
PROCEDURE rcps_proc-save0 :
FOR EACH tt-rule-call-param
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
   find  FIRST tt0-rule-call-param NO-LOCK WHERE
            tt0-rule-call-param.codex_id = tt-rule-call-param.codex_id
       AND  tt0-rule-call-param.ruleset_id = tt-rule-call-param.ruleset_id
       AND tt0-rule-call-param.call_id = tt-rule-call-param.call_id
       AND tt0-rule-call-param.order_id = tt-rule-call-param.order_id
       AND tt0-rule-call-param.param-name = tt-rule-call-param.param-name
       AND tt0-rule-call-param.p-index = tt-rule-call-param.p-index no-error .
   if not available tt0-rule-call-param
   and (lookup("LIST", tt-rule-call-param.param-3-data-type) > 0
        OR
        lookup("SORTED-LIST", tt-rule-call-param.param-3-data-type) > 0
        )
   and tt-rule-call-param.p-index > 0 then do:
     create tt0-rule-call-param.
   end.
   BUFFER-COPY tt-rule-call-param TO tt0-rule-call-param.
END.
FOR EACH tt0-rule-call-param
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
  if tt0-rule-call-param.p-index = 0 then next.
  if lookup("hidden", tt0-rule-call-param.param-3-data-type) > 0 then next.
  find  FIRST tt-rule-call-param NO-LOCK WHERE
          tt-rule-call-param.codex_id = tt0-rule-call-param.codex_id
      AND tt-rule-call-param.ruleset_id = tt0-rule-call-param.ruleset_id
      AND tt-rule-call-param.call_id = tt0-rule-call-param.call_id
      AND tt-rule-call-param.order_id = tt0-rule-call-param.order_id
      AND tt-rule-call-param.param-name = tt0-rule-call-param.param-name
      AND tt-rule-call-param.p-index = tt0-rule-call-param.p-index no-error .
  if not available tt-rule-call-param
  and (lookup("LIST", tt0-rule-call-param.param-3-data-type) > 0
      OR
      lookup("SORTED-LIST", tt0-rule-call-param.param-3-data-type) > 0
      )
  and tt0-rule-call-param.p-index > 0
  then do:
     IF p-call-id <> '':U and p-call-id <> tt0-rule-call-param.call_id THEN do:
        NEXT.
     end.
     IF p-codex-id <> 0 and p-codex-id <> tt0-rule-call-param.codex_id THEN do:
       NEXT.
     end.
     IF p-ruleset-id <> 0 and p-ruleset-id <> tt0-rule-call-param.ruleset_id THEN do:
       NEXT.
     end.
     IF p-rule-id <> 0 and p-rule-id <> tt0-rule-call-param.RULE_id THEN do:
       NEXT.
     end.
     IF p-order-id <> ? and p-order-id <> tt0-rule-call-param.order_id THEN do:
       NEXT.
     end.
    IF p-list-mode = 'rp-rule-param':U
    or p-list-mode = 'rp-rule-param':U  + chr(44) + 'все':U
    THEN DO:
      IF p-profile-id <> 0 AND p-profile-id <> tt0-rule-call-param.profile_id THEN do:
        NEXT.
      end.
      IF p-once-more <> ? AND p-once-more <> tt0-rule-call-param.once-more THEN do:
        NEXT.
      end.
    end.
    delete tt0-rule-call-param.
  end.
end.
END PROCEDURE.
PROCEDURE rcps_set-value :
DEFINE INPUT PARAMETER p-profile-id AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-once-more AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-rp-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pp-index AS integer NO-UNDO.
DEFINE INPUT parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE INPUT parameter p-value-date AS date NO-UNDO.
DEFINE INPUT parameter p-value-decimal AS decimal NO-UNDO.
DEFINE INPUT parameter p-value-integer AS integer NO-UNDO.
DEFINE INPUT parameter p-value-logical AS logical NO-UNDO.
DEFINE VARIABLE v-codex-id AS integer NO-UNDO.
DEFINE VARIABLE v-ruleset-id AS integer NO-UNDO.
DEFINE VARIABLE v-order-id AS integer NO-UNDO.
DEFINE VARIABLE V-param-name AS character NO-UNDO.
define variable v-found as logical no-undo .
DEFINE BUFFER buf_tt-rule-call-param FOR tt-rule-call-param.
DEFINE BUFFER buf_rp-rule-param FOR ub.rp-rule-param.
FOR FIRST buf_rp-rule-param WHERE
          buf_rp-rule-param.profile_id = p-profile-id
      AND buf_rp-rule-param.rp-param-name = p-rp-param-name
    , first buf_tt-rule-call-param WHERE
       buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
   AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
   AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
   AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name:
  ASSIGN
  v-codex-id = buf_tt-rule-call-param.codex_id
  v-ruleset-id = buf_tt-rule-call-param.ruleset_id
  v-order-id = buf_tt-rule-call-param.order_id
  V-PARAM-NAME = buf_tt-rule-call-param.PARAM-NAME
  .
  LEAVE.
END.
CASE p-list-mode:
  WHEN 'rp-rule-param':U THEN DO:
    if pp-index > 0
    then do:
      FOR EACH  buf_rp-rule-param NO-LOCK where
          buf_rp-rule-param.profile_id = p-profile-id
          AND buf_rp-rule-param.rp-param-name = p-rp-param-name
          ,EACH buf_tt-rule-call-param WHERE
              buf_tt-rule-call-param.profile_id = p-profile-id
          AND buf_tt-rule-call-param.once-more = p-once-more
          AND buf_tt-rule-call-param.call_id = p-CALL-id
          AND buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
          AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
          AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
          AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
          AND buf_tt-rule-call-param.p-index = pp-index
      ON error undo, return error :
        v-found = yes.
      end.
    end.
    if not v-found then do:
      run rcps_proc-b-add in this-procedure (
                                               input p-profile-id
                                              ,input p-once-more
                                              ,input p-call-id
                                              ,
                                               input p-rp-param-name
                                              ,input pp-index).
    end.
    FOR EACH  buf_rp-rule-param NO-LOCK where
        buf_rp-rule-param.profile_id = p-profile-id
        AND buf_rp-rule-param.rp-param-name = p-rp-param-name
        ,EACH buf_tt-rule-call-param WHERE
            buf_tt-rule-call-param.profile_id = p-profile-id
        AND buf_tt-rule-call-param.once-more = p-once-more
        AND buf_tt-rule-call-param.call_id = p-CALL-id
        AND buf_tt-rule-call-param.codex_id = buf_rp-rule-param.codex_id
        AND buf_tt-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
        AND buf_tt-rule-call-param.rule_id = buf_rp-rule-param.rule_id
        AND buf_tt-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
        AND buf_tt-rule-call-param.p-index = pp-index
      ON error undo, return error :
      assign
      buf_tt-rule-call-param.param-value-character = p-value-character
      buf_tt-rule-call-param.param-value-date      = p-value-date
      buf_tt-rule-call-param.param-value-decimal   = p-value-decimal
      buf_tt-rule-call-param.param-value-integer   = p-value-integer
      buf_tt-rule-call-param.param-value-logical   = p-value-logical
      .
    END.
  END.
  WHEN 'rule-call-param':U THEN DO:
    FIND FIRST buf_tt-rule-call-param WHERE
        buf_tt-rule-call-param.call_id = p-call-id
    AND buf_tt-rule-call-param.codex_id = v-codex-id
    AND buf_tt-rule-call-param.ruleset_id = v-ruleset-id
    AND buf_tt-rule-call-param.order_id = v-order-id
    AND buf_tt-rule-call-param.param-name = V-PARAM-NAME
    AND buf_tt-rule-call-param.p-index = pp-index.
    assign
    buf_tt-rule-call-param.param-value-character = p-value-character
    buf_tt-rule-call-param.param-value-date      = p-value-date
    buf_tt-rule-call-param.param-value-decimal   = p-value-decimal
    buf_tt-rule-call-param.param-value-integer   = p-value-integer
    buf_tt-rule-call-param.param-value-logical   = p-value-logical
    .
  END.
END CASE.
END PROCEDURE.
procedure rcps_get-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define output parameter p-on-off as logical no-undo .
if valid-handle(p-call-handle)
and lookup("rcpscont_get-rule-on-off", p-call-handle:internal-entries) > 0 then do:
  run rcpscont_get-rule-on-off in p-call-handle (
                                           input p-codex-id
                                          ,input p-ruleset-id
                                          ,input p-rule-id
                                          ,input p-profile-id
                                          ,input p-once-more
                                          ,output p-on-off) no-error.
end.
end procedure.
procedure rcps_set-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-on-off as logical no-undo .
if valid-handle(p-call-handle)
and lookup("rcpscont_get-rule-on-off", p-call-handle:internal-entries) > 0 then do:
  run rcpscont_set-rule-on-off in p-call-handle (
                                           input p-codex-id
                                          ,input p-ruleset-id
                                          ,input p-rule-id
                                          ,input p-profile-id
                                          ,input p-once-more
                                          ,input p-on-off) no-error.
end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE rcps_MyEnable0 :
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ch0 AS widget-handle NO-UNDO.
ASSIGN
term_tt-rule-call-param.param-label:RESIZABLE IN browse br-rcp = YES
X_rp-rule-param.rp-param-name:RESIZABLE IN browse br-rcp = YES
.
ASSIGN
v-ch0 = br-rcp:FIRST-COLUMN IN FRAME Dialog-Frame.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = "Значение!(строковое)" THEN DO:
     v-ch[1] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = "Значение!(Дата)" THEN DO:
     v-ch[2] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = "Значение!(Десятичное)" THEN DO:
     v-ch[3] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = "Значение!(Целое)" THEN DO:
     v-ch[4] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = "Значение!(Логическое)" THEN DO:
     v-ch[5] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = "Точка вызова" THEN DO:
     v-ch[6] = v-ch0.
   END.
   IF v-ch0:LABEL = "Значение" THEN
   v-ch0:RESIZABLE = YES.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
assign
X_rp-rule-param.rp-param-name:resizable in browse br-rcp = yes
term_tt-rule-call-param.param-name:resizable in browse br-rcp = yes
term_tt-rule-call-param.param-label:resizable in browse br-rcp = yes
.
CASE p-list-mode:
  WHEN 'rule-call-param':U THEN DO:
     ASSIGN
     X_rp-rule-param.rp-param-name:VISIBLE IN BROWSE br-rcp = NO
     .
  END.
  WHEN 'rp-rule-param':U
  or
  when 'rp-rule-param':U + chr(44) + 'все':U
  THEN DO:
    assign
    term_tt-rule-call-param.codex_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.ruleset_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.rule_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.order_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.param-name:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.param-num:VISIBLE IN BROWSE br-rcp = NO
    .
  END.
END CASE.
 IF p-call-id <> '':U THEN DO:
   v-ch[6]:VISIBLE = NO.
 END.
  IF p-profile-id <> 0 THEN DO:
   term_tt-rule-call-param.profile_id :VISIBLE IN BROWSE br-rcp= NO.
 END.
  IF p-rule-id <> 0 THEN DO:
   term_tt-rule-call-param.RULE_id :VISIBLE IN BROWSE br-rcp= NO.
 END.
  IF p-once-more <> 0 THEN DO:
   term_tt-rule-call-param.once-more :VISIBLE IN BROWSE br-rcp= NO.
 END.
END PROCEDURE.
PROCEDURE rcps_Openbr :
CASE p-list-mode:
  WHEN 'rp-rule-param':U THEN DO:
      OPEN QUERY br-rcp
      FOR EACH  X_ruledict-param NO-LOCK WHERE X_ruledict-param.entry-id = v-rcps-entry-id
          ,FIRST X_rp-rule-param WHERE
              X_rp-rule-param.profile_id = p-profile-id
          AND X_rp-rule-param.rp-param-name = X_ruledict-param.param-name
        , first tt-rule-call-param WHERE
           tt-rule-call-param.codex_id = X_rp-rule-param.codex_id
       AND tt-rule-call-param.ruleset_id = X_rp-rule-param.ruleset_id
       AND tt-rule-call-param.rule_id = X_rp-rule-param.rule_id
       AND tt-rule-call-param.param-name = X_rp-rule-param.rule-param-name
         ,each term_tt-rule-call-param where
               term_tt-rule-call-param.call_id = tt-rule-call-param.call_id
           and term_tt-rule-call-param.codex_id = tt-rule-call-param.codex_id
           and term_tt-rule-call-param.ruleset_id = tt-rule-call-param.ruleset_id
           and term_tt-rule-call-param.order_id = tt-rule-call-param.order_id
           and term_tt-rule-call-param.param-name = tt-rule-call-param.param-name
      BY tt-rule-call-param.call_id
      BY tt-rule-call-param.codex_id
      BY tt-rule-call-param.ruleset_id
      BY tt-rule-call-param.order_id
      BY tt-rule-call-param.param-num.
  END.
END CASE.
apply "ENTRY" to br-rcp in frame Dialog-Frame .
APPLy "VALUE-CHANGED" to br-rcp.
END PROCEDURE.
PROCEDURE rcps_proc-b-chg PRIVATE :
DEFINE VARIABLE v-rec1 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec2 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec3 AS Rowid NO-UNDO.
DEFINE VARIABLE v-rec4 AS Rowid NO-UNDO.
define variable v-param-data-type as character no-undo .
define variable v-rid-list as character no-undo .
IF NOT AVAILABLE TERM_tt-rule-call-param  THEN DO:
  RETURN ERROR.
END.
ASSIGN
v-rec1 = rowid(X_ruledict-param)
v-rec2 = rowid(X_rp-rule-param)
v-rec3 = Rowid(tt-rule-call-param)
v-rec4 = Rowid(term_tt-rule-call-param)
.
run rcps_openbr in this-procedure .
REPOSITION br-rcp TO Rowid v-rec1, v-rec2,v-rec3, v-rec4 NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  REPOSITION br-rcp TO ROW 1 NO-ERROR.
END.
APPLY "ENTRY" TO br-rcp in frame Dialog-Frame .
APPLY "VALUE-CHANGED" TO br-rcp in frame Dialog-Frame .
END PROCEDURE.
PROCEDURE rcps_set-row-color :
DEFINE INPUT PARAMETER p-data-type AS CHARACTER NO-UNDO.
ASSIGN
v-ch[1]:FGCOLOR = GREY_COLOR
v-ch[1]:BGCOLOR = GREY_Color
v-ch[1]:PFCOLOR = GREY_Color
v-ch[2]:FGCOLOR = GREY_COLOR
v-ch[2]:BGCOLOR = GREY_Color
v-ch[2]:PFCOLOR = GREY_Color
v-ch[3]:FGCOLOR = GREY_COLOR
v-ch[3]:BGCOLOR = GREY_Color
v-ch[3]:PFCOLOR = GREY_Color
v-ch[4]:FGCOLOR = GREY_COLOR
v-ch[4]:BGCOLOR = GREY_Color
v-ch[4]:PFCOLOR = GREY_Color
v-ch[5]:FGCOLOR = GREY_COLOR
v-ch[5]:BGCOLOR = GREY_Color
v-ch[5]:PFCOLOR = GREY_Color
.
CASE entry(1, p-data-type):
     WHEN 'character':U THEN DO:
      ASSIGN
      v-ch[1]:FGCOLOR = BLACK_COLOR
      v-ch[1]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'decimal':U THEN DO:
      ASSIGN
      v-ch[3]:FGCOLOR = BLACK_COLOR
      v-ch[3]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'integer':U THEN DO:
      ASSIGN
      v-ch[4]:FGCOLOR = BLACK_COLOR
      v-ch[4]:BGCOLOR = WHITE_Color.
    END.
    WHEN 'date':U THEN DO:
      ASSIGN
      v-ch[2]:FGCOLOR = BLACK_COLOR
      v-ch[2]:BGCOLOR = WHITE_Color.
     END.
     WHEN 'logical':U THEN DO:
       ASSIGN
       v-ch[5]:FGCOLOR = BLACK_COLOR
       v-ch[5]:BGCOLOR = WHITE_Color.
     END.
END CASE.
END PROCEDURE.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   run gbl/dftempl.p ( input 'rp-rule-param':U
                     , output v-dflt-rec) no-error.
    if error-status:error then dO:
      message
      vss-workfile vss-revision vss-description skip
      "Невозможно найти recid template записи в таблице rp-rule-param"
      view-as alert-box error .
      return error.
    end.
    run gbl/dftempl.p ( input 'ruledict-param':U
                      , output v-rp-dflt-rec) no-error.
     if error-status:error then dO:
       message
       vss-workfile vss-revision vss-description skip
       "Невозможно найти recid template записи в таблице ruledict-param"
       view-as alert-box error .
       return error.
     end.
  IF p-list-mode = 'rp-rule-param':U
  THEN DO:
    FIND FIRST buf_rule-profile NO-LOCK WHERE
              buf_rule-profile.profile_id = p-profile-id.
    run gen-key-rec in this-procedure ( input 'rule-profile':U
                                    ,input buffer buf_rule-profile:handle
                                    ,output v-uniq-key-rec).
    FIND FIRST buf_ruledict NO-LOCK WHERE
              buf_ruledict.entry-type = 'rule-profile':U
       AND  buf_ruledict.uniq-key-rec = v-uniq-key-rec.
    v-rcps-entry-id = buf_ruledict.entry-id.
  END.
  ELSE DO:
     MESSAGE
     substitute("Неверное значение параметра p-list-mode=&1", p-list-mode)
     VIEW-AS alert-box.
  END.
  if p-call-id begins 'schedule':U then do:
    v-running-mode = yes.
  end.
  RUN rcps_fill-table IN THIS-PROCEDURE ( input yes).
  RUN Myenable in THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-r-b t-is-over f-rule-num f-prev-rule-num f-caller-id f-sum-id
          f-nd-caller-id E-rules T-rule-sale-out T-rule-trn-out T-rule-recalc
          T-rule-sale-in T-rule-trn-in l-r-b f-dis-rule-name
          f-prev-dis-rule-name
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help rs-r-b t-is-over f-rule-num b-dis-rule
         b-lkp-dis-rule f-prev-rule-num b-prev-dis-rule b-lkp-prev-dis-rule
         f-caller-id f-sum-id b-sum-id E-rules T-rule-sale-out T-rule-trn-out
         T-rule-recalc T-rule-sale-in T-rule-trn-in BR-rcp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE move-up-down :
define parameter buffer source_tt-rule-call-param for tt-rule-call-param.
define input parameter p-direction as character no-undo.
define input parameter p-rule-id as integer no-undo.
define output parameter p-recid as recid no-undo.
define variable v-source as integer no-undo .
define variable v-target as integer no-undo .
define buffer buf_tt-rule-call-param for tt-rule-call-param.
  if not available source_tt-rule-call-param then do:
    bell.
    return no-apply.
  end.
  assign
  v-source = source_tt-rule-call-param.p-index
  p-recid = recid(source_tt-rule-call-param)
  .
  case p-direction:
    when "down" then do:
      find first buf_tt-rule-call-param where
           buf_tt-rule-call-param.param-name = "p-rule-nums"
       and buf_tt-rule-call-param.rule_id = p-rule-id
       and buf_tt-rule-call-param.p-index > v-source no-error.
    end.
    when "up" then do:
      find last buf_tt-rule-call-param where
           buf_tt-rule-call-param.param-name = "p-rule-nums"
       and buf_tt-rule-call-param.rule_id = p-rule-id
       and buf_tt-rule-call-param.p-index < v-source
       and buf_tt-rule-call-param.p-index > 0
       no-error.
    end.
  end case.
  if not available buf_tt-rule-call-param then do:
    bell.
    return no-apply.
  end.
  assign
  v-target = buf_tt-rule-call-param.p-index.
  do transaction
  on error   undo, return no-apply
  on stop    undo, return no-apply
  on end-key undo, return no-apply:
    assign
    buf_tt-rule-call-param.p-index = -99999.
    release buf_tt-rule-call-param.
    assign
    source_tt-rule-call-param.p-index = v-target.
    find first buf_tt-rule-call-param where
           buf_tt-rule-call-param.param-name = "p-rule-nums"
       and buf_tt-rule-call-param.rule_id = p-rule-id
       and buf_tt-rule-call-param.p-index = -99999.
    assign
    buf_tt-rule-call-param.p-index = v-source.
    release buf_tt-rule-call-param.
    release source_tt-rule-call-param.
  end.
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-list as character no-undo .
define variable glog as logical no-undo .
define variable v-index-id as integer no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-shop-code as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_prev-dis-rule for ub.dis-rule.
run rcps_Myenable0 in this-procedure .
ASSIGN
rs-r-b:RADIO-BUTTONS IN FRAME Dialog-Frame =
'руб.':U + chr(44) + 'rubl':U + chr(44) +
'вал.':U + chr(44) + 'base':U
.
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-is-over"
                                ,INPUT-output v-index-id
                                ,output v-value-character
                                ,output v-value-date
                                ,output v-value-decimal
                                ,output v-value-integer
                                ,output t-is-over
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-r-b"
                                ,INPUT-output v-index-id
                                ,output rs-r-b
                                ,output v-value-date
                                ,output v-value-decimal
                                ,output v-value-integer
                                ,output v-value-logical
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-sum-id"
                                ,INPUT-output v-index-id
                                ,output f-sum-id
                                ,output v-value-date
                                ,output v-value-decimal
                                ,output v-value-integer
                                ,output v-value-logical
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-caller-id"
                                ,INPUT-output v-index-id
                                ,output f-caller-id
                                ,output v-value-date
                                ,output v-value-decimal
                                ,output v-value-integer
                                ,output v-value-logical
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-nd-caller-id"
                                ,INPUT-output v-index-id
                                ,output f-nd-caller-id
                                ,output v-value-date
                                ,output v-value-decimal
                                ,output v-value-integer
                                ,output v-value-logical
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-rule-num"
                                ,INPUT-output v-index-id
                                ,output v-value-character
                                ,output v-value-date
                                ,output v-value-decimal
                                ,output f-rule-num
                                ,output v-value-logical
                                ).
v-index-id = 0.
RUN rcps_get-value IN THIS-PROCEDURE (
                                 INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-prev-rule-num"
                                ,INPUT-output v-index-id
                                ,output v-value-character
                                ,output v-value-date
                                ,output v-value-decimal
                                ,output f-prev-rule-num
                                ,output v-value-logical
                                ).
run rcps_get-rule-on-off in this-procedure ( input 2
                                            ,input 1
                                            ,input 1553
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-sale-out ).
run rcps_get-rule-on-off in this-procedure ( input 2
                                            ,input 2
                                            ,input 1553
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-sale-in ).
run rcps_get-rule-on-off in this-procedure ( input 2
                                            ,input 3
                                            ,input 1553
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-trn-out ).
run rcps_get-rule-on-off in this-procedure ( input 2
                                            ,input 4
                                            ,input 1553
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-trn-in ).
run rcps_get-rule-on-off in this-procedure ( input 2
                                            ,input 5
                                            ,input 1553
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,output t-rule-recalc ).
if f-rule-num > 0 then do:
  find first buf_dis-rule no-lock where
          buf_dis-rule.rule-num = f-rule-num no-error.
end.
if f-prev-rule-num > 0 then do:
  find first buf_prev-dis-rule no-lock where
          buf_prev-dis-rule.rule-num = f-prev-rule-num no-error.
end.
ASSIGN
term_tt-rule-call-param.param-label:RESIZABLE IN browse br-rcp = YES
X_rp-rule-param.rp-param-name:RESIZABLE IN browse br-rcp = YES
.
DEFINE VARIABLE v-ch0 AS widget-handle NO-UNDO.
ASSIGN
v-ch0 = br-rcp:FIRST-COLUMN IN FRAME Dialog-Frame.
REPEAT WHILE valid-handle(v-ch0):
   IF v-ch0:LABEL = "Значение!(строковое)" THEN DO:
     v-ch[1] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = "Значение!(Дата)" THEN DO:
     v-ch[2] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = "Значение!(Десятичное)" THEN DO:
     v-ch[3] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = "Значение!(Целое)" THEN DO:
     v-ch[4] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = "Значение!(Логическое)" THEN DO:
     v-ch[5] = v-ch0.
     v-ch0:VISIBLE = NO.
   END.
   IF v-ch0:LABEL = "Точка вызова" THEN DO:
     v-ch[6] = v-ch0.
   END.
   IF v-ch0:LABEL = "Значение" THEN
   v-ch0:RESIZABLE = YES.
   v-ch0 = v-ch0:NEXT-COLUMN.
END.
assign
X_rp-rule-param.rp-param-name:resizable in browse br-rcp = yes
term_tt-rule-call-param.param-name:resizable in browse br-rcp = yes
term_tt-rule-call-param.param-label:resizable in browse br-rcp = yes
.
CASE p-list-mode:
  WHEN 'rule-call-param':U THEN DO:
     ASSIGN
     X_rp-rule-param.rp-param-name:VISIBLE IN BROWSE br-rcp = NO
     .
  END.
  WHEN 'rp-rule-param':U
  or
  when 'rp-rule-param':U + chr(44) + 'все':U
  THEN DO:
    assign
    term_tt-rule-call-param.codex_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.ruleset_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.rule_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.order_id:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.param-name:VISIBLE IN BROWSE br-rcp = NO
    term_tt-rule-call-param.param-num:VISIBLE IN BROWSE br-rcp = NO
    .
  END.
END CASE.
 IF p-call-id <> '':U THEN DO:
   v-ch[6]:VISIBLE = NO.
 END.
  IF p-profile-id <> 0 THEN DO:
   term_tt-rule-call-param.profile_id :VISIBLE IN BROWSE br-rcp= NO.
 END.
  IF p-rule-id <> 0 THEN DO:
   term_tt-rule-call-param.RULE_id :VISIBLE IN BROWSE br-rcp= NO.
 END.
  IF p-once-more <> 0 THEN DO:
   term_tt-rule-call-param.once-more :VISIBLE IN BROWSE br-rcp= NO.
END.
display
t-is-over
rs-r-b
f-rule-num
f-prev-rule-num
f-sum-id
f-caller-id
f-nd-caller-id
l-r-b
(if available buf_dis-rule then buf_dis-rule.des else "Не найдено правило скидки!!!") @ f-dis-rule-name
(if available buf_prev-dis-rule then buf_prev-dis-rule.des else "Не найдено правило скидки!!!") @ f-prev-dis-rule-name
e-rules
T-rule-recalc
T-rule-sale-in
T-rule-sale-out
T-rule-trn-in
T-rule-trn-out
with frame Dialog-Frame .
VIEW FRAME Dialog-Frame.
e-rules:read-only in frame Dialog-Frame .
ENABLE
rs-r-b WHEN p-mode <> 'ПРОСМОТР':U
b-dis-rule WHEN p-mode <> 'ПРОСМОТР':U
b-prev-dis-rule WHEN p-mode <> 'ПРОСМОТР':U
b-sum-id WHEN p-mode <> 'ПРОСМОТР':U
f-caller-id WHEN p-mode <> 'ПРОСМОТР':U
t-is-over WHEN p-mode <> 'ПРОСМОТР':U
B-exit WHEN p-mode <> 'ПРОСМОТР':U
T-rule-recalc  WHEN p-mode <> 'ПРОСМОТР':U
T-rule-sale-in  WHEN p-mode <> 'ПРОСМОТР':U
T-rule-sale-out  WHEN p-mode <> 'ПРОСМОТР':U
T-rule-trn-in  WHEN p-mode <> 'ПРОСМОТР':U
T-rule-trn-out WHEN p-mode <> 'ПРОСМОТР':U
b-lkp-dis-rule
b-lkp-prev-dis-rule
b-quit
e-rules
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF p-mode = 'ПРОСМОТР':U THEN DO:
   ASSIGN
   b-quit:COLUMN = 1
   b-quit:LABEL = "&Выход".
   HIDE
   b-exit
   IN FRAME Dialog-Frame.
END.
ASSIGN
FRAME Dialog-Frame:TITLE =
substitute("Параметры Интервального Алгоритма зависимости Сумма накоплений -> % скидки на товар с обнул. итогов пересч-м по пред. пер-ду и снижением по 1(профайл &1)", p-profile-id).
END PROCEDURE.
PROCEDURE proc-save :
define buffer buf_prop-ref for ub.prop-ref.
define variable v-ii as integer   no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
v-ii = 0.
assign
frame Dialog-Frame
t-is-over
T-rule-recalc
T-rule-sale-in
T-rule-sale-out
T-rule-trn-in
T-rule-trn-out
f-rule-num
f-prev-rule-num
f-caller-id
f-nd-caller-id
f-sum-id
rs-r-b
.
run cur-time in this-procedure ( output v-today, output v-time).
find first buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = 5
      and buf_prop-ref.caller_id = f-caller-id
      and buf_prop-ref.sum-id >= propreft-date-to-string(v-today)
      no-error.
if not available buf_prop-ref then do:
  message
  substitute("Внимание! В момент начала работы по данному профайлу в БД должен быть срез/итог по ДК за соответствующий период, у которого доп. идентификатор=&1"
             , f-caller-id
             )
  view-as alert-box warning.
end.
run rcps_set-rule-on-off in this-procedure ( input 2
                                           ,input 1
                                           ,input 1553
                                           ,input p-profile-id
                                           ,input p-once-more
                                           ,input t-rule-sale-out).
run rcps_set-rule-on-off in this-procedure ( input 2
                                            ,input 2
                                            ,input 1553
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,input t-rule-sale-in ).
run rcps_set-rule-on-off in this-procedure ( input 2
                                            ,input 3
                                            ,input 1553
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,input t-rule-trn-out ).
run rcps_set-rule-on-off in this-procedure ( input 2
                                            ,input 4
                                            ,input 1553
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,input t-rule-trn-in ).
run rcps_set-rule-on-off in this-procedure ( input 2
                                            ,input 5
                                            ,input 1553
                                            ,input p-profile-id
                                            ,input p-once-more
                                            ,input t-rule-recalc ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-is-over"
                                ,INPUT 0
                                ,INPUT ''
                                ,INPUT ?
                                ,INPUT 0.0
                                ,INPUT 0
                                ,INPUT t-is-over
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-r-b"
                                ,INPUT 0
                                ,INPUT rs-r-b
                                ,INPUT ?
                                ,INPUT 0.0
                                ,INPUT 0
                                ,INPUT no
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-rule-num"
                                ,INPUT 0
                                ,INPUT ''
                                ,INPUT ?
                                ,INPUT 0.0
                                ,INPUT f-rule-num
                                ,INPUT no
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-prev-rule-num"
                                ,INPUT 0
                                ,INPUT f-prev-rule-num
                                ,INPUT ?
                                ,INPUT 0.0
                                ,INPUT 0
                                ,INPUT no
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-sum-id"
                                ,INPUT 0
                                ,INPUT f-sum-id
                                ,INPUT ?
                                ,INPUT 0.0
                                ,INPUT 0
                                ,INPUT no
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-caller-id"
                                ,INPUT 0
                                ,INPUT f-caller-id
                                ,INPUT ?
                                ,INPUT 0.0
                                ,INPUT 0
                                ,INPUT no
                                ).
RUN rcps_set-value IN THIS-PROCEDURE (
                                INPUT p-profile-id
                                ,INPUT p-once-more
                                ,INPUT p-call-id
                                ,INPUT "p-nd-caller-id"
                                ,INPUT 0
                                ,INPUT f-nd-caller-id
                                ,INPUT ?
                                ,INPUT 0.0
                                ,INPUT 0
                                ,INPUT no
                                ).
run rcps_proc-save0 in this-procedure .
END PROCEDURE.
