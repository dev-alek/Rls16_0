DEFINE TEMP-TABLE tt-loc-rule-i-script NO-UNDO LIKE ub.rule-i-script.
DEFINE SHARED TEMP-TABLE tt-rule NO-UNDO LIKE ub.rule
       field level as integer.
DEFINE SHARED TEMP-TABLE tt-rule-i-script NO-UNDO LIKE ub.rule-i-script.
DEFINE SHARED TEMP-TABLE tt-rule-script NO-UNDO LIKE ub.rule-script
       field level as integer
       field gen-order as character
       field upper_rule_id as integer.
DEFINE SHARED TEMP-TABLE tt-ruledict-param NO-UNDO LIKE ub.ruledict-param.
DEFINE BUFFER X_dtruledict FOR ub.ruledict.
DEFINE BUFFER X_prop-script FOR ub.prop-script.
DEFINE BUFFER X_pscript-ruleset FOR ub.pscript-ruleset.
DEFINE BUFFER X_rule-i-script FOR ub.rule-i-script.
DEFINE BUFFER X_ruledict FOR ub.ruledict.
DEFINE BUFFER X_ruleset FOR ub.ruleset.
DEFINE BUFFER Y_prop-script FOR ub.prop-script.
DEFINE BUFFER Y_pscript-ruleset FOR ub.pscript-ruleset.
DEFINE BUFFER Y_ruledict FOR ub.ruledict.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-mode as character no-undo .
DEFINE INPUT PARAMETER p-codex-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-root-rule-id AS INTEGER NO-UNDO.
define input parameter p-upper-rule-id as integer no-undo .
DEFINE INPUT PARAMETER p-rule-id AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-script-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-salience AS INTEGER NO-UNDO.
define input-output parameter p-script-id as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание одного rule-script".
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
FUNCTION real-index returns integer(
                                    input p-source as character
                                   ,input p-target as character
                                   ,input p-starting as integer
                                   ,output p-sub-number as integer
                                   ):
define variable v-dopi as integer no-undo .
define variable v-starting as integer no-undo .
define variable v-subs as character no-undo .
v-starting = p-starting.
_do:
do while true:
  v-dopi = index(p-source, p-target, v-starting).
  if p-target  begins "&":U
  and v-dopi > 0  then do:
    if p-target = "&":U then do:
      v-subs = substring(p-source, v-dopi + 1, 1).
      if v-subs = "&":U
      and length(p-source) > v-dopi + 1
      then do:
        v-starting = v-dopi + 2.
      end.
      else do:
        if v-dopi > 1 then do:
          v-subs = substring(p-source, v-dopi - 1, 1).
          if v-subs = chr(123) then do:
             v-starting = v-dopi + 1.
          end.
          else do:
            leave _do.
          end.
        end.
        else do:
          leave _do.
        end.
      end.
    end.
    else  do:
      if v-dopi > 1 then do:
        v-subs = substring(p-source, v-dopi - 1, 1).
        if v-subs = "&":U
        and length(p-source) > v-dopi + 1
        then do:
          v-starting = v-dopi + 2.
        end.
        else do:
          leave _do.
        end.
      end.
      else do:
        leave _do.
      end.
    end.
  end.
  else leave _do.
end.
assign
p-sub-number = integer(substring(p-source, v-dopi + 1, 1)) no-error .
return v-dopi.
end.
DEFINE BUFFER tt-l_rule-script FOR tt-rule-script.
define buffer bufv_tt-rule-i-script for tt-rule-i-script.
DEFINE TEMP-TABLE tt-widget
FIELD handle_ AS WIDGET-HANDLE
FIELD name_ AS CHARACTER
FIELD script-al AS CHARACTER
FIELD script-nl AS CHARACTER
FIELD num_ AS INTEGER
FIELD ROW_ AS DECIMAL
FIELD COLUMN_ AS DECIMAL
FIELD WIDTH_ AS DECIMAL
FIELD HEIGHT_ AS DECIMAL
FIELD left-top AS DECIMAL
FIELD right-bottom AS DECIMAL
FIELD LENGTH_ AS DECIMAL
FIELD script-type AS CHARACTER
FIELD entry-type AS CHARACTER
FIELD script-value-type AS CHARACTER
FIELD data-type AS CHARACTER
FIELD script-al-fix AS CHARACTER
field dtm-code as integer
field class-dtm-code as integer
field uniq-key-rec as character
INDEX pi IS UNIQUE PRIMARY num_
INDEX ihandle HANDLE_
INDEX irc
ROW_
COLUMN_
.
define temp-table tt-widget-child no-undo
field num_ as integer
field level_ as integer
field position-al as integer
field position-nl as integer
field script-nl as character
field script-al as character
field entry-id AS INTEGER
field param-data-type AS CHARACTER
field param-2-data-type AS CHARACTER
field param-3-data-type AS CHARACTER
field param-label AS CHARACTER
field param-mode AS CHARACTER
field param-name AS CHARACTER
field param-num AS INTEGER
index pi is unique primary
num_ level_ param-num
index p-al
position-al
index p-nl
position-nl
.
DEFINE VARIABLE v-current-row AS DECIMAL NO-UNDO INIT 18.
DEFINE VARIABLE v-current-column AS DECIMAL NO-UNDO INIT 1.
DEFINE TEMP-TABLE tt-complex no-undo
FIELD script-al AS CHARACTER
FIELD script-nl AS CHARACTER
FIELD entry-type AS CHARACTER
FIELD proc-type AS CHARACTER
FIELD script-name AS CHARACTER
FIELD script-type AS CHARACTER
FIELD script-value-type AS CHARACTER
FIELD data-type AS CHARACTER
field dtm-code as integer
field class-dtm-code as integer
FIEld KEY_ AS INTEGER
INDEX pi IS UNIQUE PRIMARY
KEY_.
FUNCTION get-current-column RETURNS DECIMAL
  ( input p-right-bottom AS DECIMAL )  FORWARD.
FUNCTION get-current-row RETURNS DECIMAL
  ( input p-right-bottom AS DECIMAL )  FORWARD.
FUNCTION get-left-top RETURNS DECIMAL
  ( INPUT p-row AS decimal, INPUT p-width AS decimal, INPUT p-column AS decimal, INPUT p-height AS DECIMAL )  FORWARD.
FUNCTION get-right-bottom RETURNS DECIMAL
  ( INPUT p-row AS decimal, INPUT p-width AS decimal, INPUT p-column AS decimal, INPUT p-height AS DECIMAL )  FORWARD.
FUNCTION SUBSTITUTE-value-type RETURNS CHARACTER
  ( INPUT p-value-type AS CHARACTER, buffer buf_tt-widget for tt-widget)  FORWARD.
DEFINE BUTTON b-complex
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.
DEFINE BUTTON b-defvariable
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-operator
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.
DEFINE BUTTON b-parameter
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.
DEFINE BUTTON B-prop-script
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL "&1.Перемещ."
     SIZE 14 BY 1.13.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-variable
     IMAGE-UP FILE "adeicon\ts-up110":U
     IMAGE-DOWN FILE "adeicon\ts-dn110":U
     IMAGE-INSENSITIVE FILE "adeicon\ts-up110":U NO-FOCUS
     LABEL ""
     SIZE 14 BY 1.13.
DEFINE VARIABLE cb-pscript-ruleset AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEM-PAIRS "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 98 BY 1 NO-UNDO.
DEFINE VARIABLE f-complex AS CHARACTER FORMAT "X(12)":U INITIAL "Сложн.выр-ние"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-defvariable AS CHARACTER FORMAT "X(12)":U INITIAL "Декл.перем."
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.
DEFINE VARIABLE F-operator AS CHARACTER FORMAT "X(12)":U INITIAL "Оп-ры, конст-ы"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-parameter AS CHARACTER FORMAT "X(12)":U INITIAL "Параметры"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-prop-script AS CHARACTER FORMAT "X(12)" INITIAL "Св-ва, мет-ды"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.
DEFINE VARIABLE f-variable AS CHARACTER FORMAT "X(12)":U INITIAL "Переменные"
      VIEW-AS TEXT
     SIZE 11 BY .53
     FONT 4 NO-UNDO.
DEFINE VARIABLE RS-language AS CHARACTER INITIAL "ABL"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "ABL", "ABL",
"lan", "lan"
     SIZE 15 BY 1 NO-UNDO.
DEFINE QUERY br-complex FOR
      tt-complex SCROLLING.
DEFINE QUERY br-dtruledict FOR
      X_dtruledict SCROLLING.
DEFINE QUERY br-operator FOR
      Y_ruledict SCROLLING.
DEFINE QUERY br-parameter FOR
      tt-ruledict-param SCROLLING.
DEFINE QUERY br-pscript-ruleset FOR
      X_prop-script,
      X_pscript-ruleset,
      X_ruledict SCROLLING.
DEFINE QUERY br-variable FOR
      bufv_tt-rule-i-script SCROLLING.
DEFINE BROWSE br-complex
  QUERY br-complex DISPLAY
      tt-complex.script-al FORMAT "X(255)" WIDTH 45
tt-complex.script-nl FORMAT "X(255)" WIDTH 45
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 13.8 FIT-LAST-COLUMN.
DEFINE BROWSE br-dtruledict
  QUERY br-dtruledict NO-LOCK DISPLAY
      X_dtruledict.script-nl COLUMN-LABEL "Тип данных" FORMAT "X(255)":U
    WIDTH 20
X_dtruledict.script-al COLUMN-LABEL "Тип данных" FORMAT "X(255)":U
    WIDTH 7
    WITH NO-ROW-MARKERS SEPARATORS SIZE 60 BY 13.8 FIT-LAST-COLUMN.
DEFINE BROWSE br-operator
  QUERY br-operator DISPLAY
      Y_ruledict.script-al FORMAT "X(255)" WIDTH 20 COLUMN-LABEL "Скрипт"
Y_ruledict.script-nl FORMAT "X(255)" WIDTH 20 COLUMN-LABEL "Скрипт"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 60 BY 13.8 FIT-LAST-COLUMN.
DEFINE BROWSE br-parameter
  QUERY br-parameter DISPLAY
      tt-ruledict-param.param-data-type COLUMN-LABEL "Тип" FORMAT "X(16)"
tt-ruledict-param.param-mode COLUMN-LABEL "Мода" FORMAT "X(16)"
tt-ruledict-param.param-name COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
tt-ruledict-param.param-label COLUMN-LABEL "Название" FORMAT "X(255)" WIDTH 60
    WITH NO-ROW-MARKERS SEPARATORS SIZE 58 BY 13.8 FIT-LAST-COLUMN.
DEFINE BROWSE br-pscript-ruleset
  QUERY br-pscript-ruleset DISPLAY
      X_pscript-ruleset.script-name FORMAT "X(255)" WIDTH 45 COLUMN-LABEL "Скрипт"
entry(1, X_prop-script.script-value-type) FORMAT "X(12)" WIDTH 45 COLUMN-LABEL "Тип знач"
(IF num-entries(X_prop-script.script-value-type) > 1
 THEN entry(2, X_prop-script.script-value-type)
 ELSE '':U) FORMAT "X(12)"                           COLUMN-LABEL "Тип объ"
X_ruledict.script-nl FORMAT "X(255)" WIDTH 45 COLUMN-LABEL "Скрипт"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.8 FIT-LAST-COLUMN.
DEFINE BROWSE br-variable
  QUERY br-variable DISPLAY
      bufv_tt-rule-i-script.script-name FORMAT "X(32)" COLUMN-LABEL "Имя переменной"
bufv_tt-rule-i-script.script-TYPE FORMAT "X(20)" COLUMN-LABEL "Тип переменной"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 52 BY 13.8 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-complex AT ROW 2.57 COL 57 WIDGET-ID 40
     b-quit AT ROW 1 COL 11
     RS-language AT ROW 1 COL 30 NO-LABEL WIDGET-ID 2
     B-Help AT ROW 1 COL 54.9
     cb-pscript-ruleset AT ROW 4 COL 1 NO-LABEL WIDGET-ID 46
     br-variable AT ROW 4 COL 1 WIDGET-ID 400
     br-parameter AT ROW 4 COL 1 WIDGET-ID 500
     br-operator AT ROW 4 COL 1 WIDGET-ID 200
     br-dtruledict AT ROW 4 COL 1 WIDGET-ID 300
     br-complex AT ROW 4 COL 1 WIDGET-ID 600
     br-pscript-ruleset AT ROW 5 COL 1 WIDGET-ID 100
     b-defvariable AT ROW 2.57 COL 71 WIDGET-ID 22
     B-operator AT ROW 2.57 COL 15 WIDGET-ID 16
     b-parameter AT ROW 2.57 COL 43 WIDGET-ID 34
     B-prop-script AT ROW 2.57 COL 1 WIDGET-ID 14
     b-variable AT ROW 2.57 COL 29 WIDGET-ID 28
     f-prop-script AT ROW 2.93 COL 2.5 NO-LABEL WIDGET-ID 18
     F-operator AT ROW 2.93 COL 16.5 NO-LABEL WIDGET-ID 20
     f-variable AT ROW 2.93 COL 30.5 NO-LABEL WIDGET-ID 26
     f-parameter AT ROW 2.93 COL 44.5 NO-LABEL WIDGET-ID 36
     f-complex AT ROW 2.93 COL 58.5 NO-LABEL WIDGET-ID 42
     f-defvariable AT ROW 2.93 COL 72.5 NO-LABEL WIDGET-ID 24
     SPACE(15.59) SKIP(19.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit DROP-TARGET.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON END-ERROR OF FRAME Dialog-Frame
DO:
  RUN proc-undo IN THIS-PROCEDURE NO-ERROR.
END.
ON ENDKEY OF FRAME Dialog-Frame
DO:
RUN proc-undo IN THIS-PROCEDURE NO-ERROR.
END.
ON GO OF FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-complex IN FRAME Dialog-Frame
DO:
run proc-init-b-complex in this-procedure .
END.
ON CHOOSE OF b-defvariable IN FRAME Dialog-Frame
DO:
run proc-init-b-defvariable in this-procedure .
END.
ON CHOOSE OF B-operator IN FRAME Dialog-Frame
DO:
run proc-init-b-operator in this-procedure .
END.
ON CHOOSE OF b-parameter IN FRAME Dialog-Frame
DO:
run proc-init-b-parameter in this-procedure .
END.
ON CHOOSE OF B-prop-script IN FRAME Dialog-Frame
DO:
   run proc-init-b-prop-script in this-procedure .
END.
ON CHOOSE OF b-variable IN FRAME Dialog-Frame
DO:
run proc-init-b-variable in this-procedure .
END.
ON DEFAULT-ACTION OF br-complex IN FRAME Dialog-Frame
DO:
    IF AVAILABLE tt-complex THEN DO:
      RUN create-tt-complex IN THIS-PROCEDURE ( rs-language
                                              ,BUFFER tt-complex
                                              ) NO-ERROR.
    END.
END.
ON DEFAULT-ACTION OF br-dtruledict IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_dtruledict THEN DO:
    RUN create-datatype IN THIS-PROCEDURE ( INPUT rs-language
                                            ,BUFFER X_dtruledict) NO-ERROR.
    if error-status:error then do:
      apply "End-error" to frame Dialog-Frame  .
    end.
  END.
END.
ON DEFAULT-ACTION OF br-operator IN FRAME Dialog-Frame
DO:
  IF AVAILABLE Y_ruledict THEN DO:
    RUN create-operator IN THIS-PROCEDURE ( INPUT rs-language
                                            ,BUFFER Y_ruledict) NO-ERROR.
  END.
END.
ON DEFAULT-ACTION OF br-parameter IN FRAME Dialog-Frame
DO:
    IF AVAILABLE tt-ruledict-param THEN DO:
      RUN create-parameter IN THIS-PROCEDURE ( rs-language
                                              ,BUFFER tt-ruledict-param)
                                               NO-ERROR.
    END.
END.
ON DEFAULT-ACTION OF br-pscript-ruleset IN FRAME Dialog-Frame
DO:
    IF AVAILABLE X_prop-script THEN DO:
      RUN create-prop-script IN THIS-PROCEDURE ( rs-language
                                              ,BUFFER X_prop-script
                                              ,BUFFER X_ruledict) NO-ERROR.
    END.
END.
ON DEFAULT-ACTION OF br-variable IN FRAME Dialog-Frame
DO:
    IF AVAILABLE bufv_tt-rule-i-script THEN DO:
      RUN create-variable IN THIS-PROCEDURE ( INPUT rs-language
                                              ,BUFFER bufv_tt-rule-i-script
                                              ) NO-ERROR.
    END.
END.
ON VALUE-CHANGED OF cb-pscript-ruleset IN FRAME Dialog-Frame
DO:
  ASSIGN cb-pscript-ruleset.
  OPEN QUERY br-pscript-ruleset FOR EACH X_prop-script NO-LOCK where        X_prop-script.dtm-code = integer(cb-pscript-ruleset),            FIRST X_pscript-ruleset NO-LOCK WHERE      X_pscript-ruleset.codex_id = p-codex-id     AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)     AND  X_prop-script.language = X_pscript-ruleset.LANGUAGE     AND  X_prop-script.script-name = X_pscript-ruleset.script-name     AND  X_prop-script.revis_id = X_pscript-ruleset.revis_id,            FIRST X_ruledict NO-LOCK WHERE      X_ruledict.ENTRY-TYPE = 'prop-script':U AND  X_ruledict.uniq-key-rec = X_prop-script.uniq-key-rec.
END.
ON VALUE-CHANGED OF RS-language IN FRAME Dialog-Frame
DO:
  ASSIGN
  rs-language.
  RUN proc-vc-language IN THIS-PROCEDURE ( INPUT rs-language).
END.
ON DELETE-CHARACTER anywhere
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  DEFINE BUFFER buf_tt-widget FOR tt-widget.
  MESSAGE
  "Удалить все выделенные куски?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog  THEN RETURN NO-APPLY.
  FOR EACH buf_tt-widget
  ON error undo, return no-apply
  :
     IF buf_tt-widget.HANDLE:SELECTED THEN DO:
         RUN proc-delete IN THIS-PROCEDURE ( BUFFER buf_tt-widget).
     END.
  END.
END.
ON mouse-menu-click anywhere
DO:
  DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
  DEFINE BUFFER buf_tt-widget FOR tt-widget.
  MESSAGE
  "Сгруппировать все выделенные куски?"
  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
  IF NOT glog  THEN RETURN NO-APPLY.
  RUN proc-mouse-menu-click IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse br-complex :handle
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-mode <> 'ДОБАВЛЕНИЕ':U
  and p-mode <> 'ИЗМЕНЕНИЕ':U then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметра p-mode" p-mode
    view-as alert-box error .
    undo, return error .
  end.
  RUN fill-tables IN THIS-PROCEDURE no-error.
  if error-status:error then do:
    undo, return error return-value .
  end.
  RUN Myenable in this-procedure no-error  .
  if error-status:error then do:
    undo, return error return-value .
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
FOR EACH tt-widget:
  IF VALID-HANDLE(tt-widget.HANDLE_) THEN DO:
    DELETE WIDGET tt-widget.HANDLE_.
  END.
  DELETE tt-widget.
END.
PROCEDURE check-script-type-cond :
DEFINE output PARAMETER p-script-al AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE variable v-script-al AS CHARACTER NO-UNDO.
DEFINE variable v-script-al-subs AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-widget FOR tt-widget.
FOR EACH buf_tt-widget
BY buf_tt-widget.right-bottom
    :
   ASSIGN
   p-script-al = substitute("&1 &2"
                            ,p-script-al
                            ,buf_tt-widget.script-al)
   v-script-al = substitute("&1 &2"
                              ,v-script-al
                              ,SUBSTITUTE-value-type (buf_tt-widget.script-value-type, buffer buf_tt-widget)
                                )
   p-script-nl = substitute("&1 &2"
                              ,p-script-nl
                              ,buf_tt-widget.script-nl
                              ).
   .
   message buf_tt-widget.script-al skip
   v-script-al
    view-as alert-box .
END.
MESSAGE p-script-al SKIP "from check-script-type-cond"
skip v-script-al
VIEW-AS ALERT-BOX.
define variable v-sub-number as integer no-undo .
IF real-INDEX(p-script-al, "&", 1, output v-sub-number) > 0  THEN DO:
  MESSAGE
  "Подставлены не все параметры!"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
run rul/check-expr-by-query.p ( INPUT v-script-al
                               ,OUTPUT glog) NO-ERROR.
IF NOT glog THEN DO:
  MESSAGE
  "Выражение сформулировано неверно!"
  VIEW-AS ALERT-BOX ERROR.
  RETURN ERROR.
END.
END PROCEDURE.
PROCEDURE check-script-type-cons :
DEFINE output PARAMETER p-script-al AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-first AS LOGICAL NO-UNDO INIT YES.
DEFINE VARIABLE v-is-void AS LOGICAL NO-UNDO INIT YES.
DEFINE variable v-script-al AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-widget FOR tt-widget.
FOR EACH buf_tt-widget
BY buf_tt-widget.right-bottom
    :
   IF buf_tt-widget.script-value-type = 'void':U THEN DO:
      IF NOT v-first THEN DO:
        MESSAGE
        "В одной строке может быть только один скрипт типа" 'void':U
        VIEW-AS alert-box ERROR.
        undo, RETURN ERROR.
      END.
      v-is-void = YES.
   END.
   v-first = NO.
   ASSIGN
   p-script-al = substitute("&1 &2"
                              ,p-script-al
                              ,buf_tt-widget.script-al)
   p-script-nl = substitute("&1 &2"
                              ,p-script-nl
                              ,buf_tt-widget.script-nl
                              )
   v-script-al = substitute("&1 &2"
                              ,p-script-al
                              ,(IF buf_tt-widget.entry-type = 'prop-script':U
                                THEN SUBSTITUTE-value-type (buf_tt-widget.script-value-type, buffer buf_tt-widget)
                                ELSE buf_tt-widget.script-al))
   .
END.
MESSAGE p-script-al "from check-script-type-cons" VIEW-AS ALERT-BOX.
define variable v-sub-number as integer no-undo .
IF real-INDEX(p-script-al, "&", 1, output v-sub-number) > 0  THEN DO:
  MESSAGE
  "Подставлены не все параметры!"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
IF NOT v-is-void  THEN DO:
    run rul/check-expr-by-query.p ( INPUT v-script-al
                                   ,OUTPUT glog) NO-ERROR.
    IF NOT glog THEN DO:
      MESSAGE
      "Выражение сформулировано неверно!"
      VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR.
    END.
END.
END PROCEDURE.
PROCEDURE create-datatype :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE parameter BUFFER buf_ruledict FOR ub.ruledict.
DEFINE variable v-ok AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-variable-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-al AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-format AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-check-name AS CHARACTER NO-UNDO.
define variable v-tbl-row as row no-undo .
define variable v-tbl-name as character no-undo .
DEFINE BUFFER buf_tt-widget FOR tt-widget.
DEFINE BUFFER buf_tt-rule-i-script FOR tt-rule-i-script.
define buffer buf_prop-script for ub.prop-script.
FIND FIRST buf_tt-widget NO-LOCK NO-ERROR .
IF AVAILABLE buf_tt-widget
or p-script-type = 'GOTO':U
THEN DO:
  MESSAGE
  "Определение переменной можно поместить только в пустой скрипт типа CONS"
  VIEW-AS ALERT-BOX.
  UNDO, RETURN ERROR.
END.
v-format = "X(32)".
run gbl/d-character.w (
      INPUT ?
    , INPUT (
      'title=':u + substitute("Декларирование переменной типа &1", buf_ruledict.script-nl) + '\':u
    + 'text1=':u + "Введите имя переменной" + '\':u
    + 'foemta=' + v-format + '\':u
    + 'fillin_row=3\':u
    + 'fillin_col=4\':u
    + 'fillin_width=20\':u
    + 'fillin_height=1\':u
    + 'readonly=' + 'no':u + '\':u)
    , input-output v-variable-name
    , output v-ok
        ).
    if not v-ok then return error.
ASSIGN
v-check-name = TRIM(v-variable-name, "abcdefghijklmnopqrstuvwxyz1234567890-").
IF v-check-name <> '':U
OR lookup(substring(v-variable-name, 1, 1), "0123456789") > 0  THEN DO:
  MESSAGE
  "Имя переменной может содержать только латинские буквы, цифры, символ '-' и начинаться с буквы"
  VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
IF LENGTH(v-variable-name) > 32  THEN DO:
    MESSAGE
    "Имя переменной не может быть длиннее 32 символов"
    VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
FIND FIRST buf_tt-rule-i-script NO-LOCK WHERE
          buf_tt-rule-i-script.i-script-type = 'variable':U
     AND  buf_tt-rule-i-script.i-script-name = v-variable-name NO-ERROR.
IF AVAILABLE buf_tt-rule-i-script THEN DO:
    MESSAGE
    "Уже есть переменная с  таким именем"
    VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN ERROR.
END.
if lookup(buf_ruledict.script-al, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle,handle,blob,clob,class,com-handle,longchar,int64':U) = 0  then do:
  RUN gen-row-keyr IN THIS-PROCEDURE
    ( input  buf_ruledict.uniq-key-rec
     ,input ?
     ,input "ub":U
     ,input ?
     ,input no-lock
     ,output v-tbl-row
     ,output  v-tbl-name
    ) NO-ERROR.
  if error-status:error then do:
    message
    substitute("Не найден Тип данных &1 (класс)", buf_ruledict.script-al)
    view-as alert-box error .
    undo, return error .
  end.
  if v-tbl-name <> 'prop-script':U then do:
    message
    substitute("Тип данных &1 в словаре не привязан к классу", buf_ruledict.script-al)
    view-as alert-box error .
    undo, return error .
  end.
  find first buf_prop-script no-lock where
            rowid(buf_prop-script) = v-tbl-row.
end.
ASSIGN
v-script-al = substitute("define variable &1 as &2 &3 no-undo"
                         , v-variable-name
                         , (if lookup(buf_ruledict.script-al, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle,handle,blob,clob,class,com-handle,longchar,int64':U) > 0
                            then '':U
                            else "class")
                         , (if lookup(buf_ruledict.script-al, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle,handle,blob,clob,class,com-handle,longchar,int64':U) > 0
                            then buf_ruledict.script-al
                            else buf_prop-script.script-head)
                         )
v-script-nl = substitute("Декларируем переменную &1 тип &2"
                         , v-variable-name
                         , buf_ruledict.script-nl).
RUN create-widget IN THIS-PROCEDURE (
                                      input (if available buf_prop-script
                                             then buf_prop-script.dtm-code
                                             else 0)
                                     ,input (if available buf_prop-script
                                             then buf_prop-script.class-dtm-code
                                             else 0)
                                     ,INPUT p-language
                                     ,INPUT v-variable-name
                                     ,INPUT v-script-al
                                     ,INPUT v-script-nl
                                     ,INPUT buf_ruledict.entry-type
                                     ,INPUT 'variable':U
                                     ,INPUT 'void':U
                                     ,INPUT (if lookup(buf_ruledict.script-al, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle,handle,blob,clob,class,com-handle,longchar,int64':U) > 0
                                          then buf_ruledict.script-al
                                          else buf_ruledict.script-al)
                                     ,input '':U
                                     ,input '':U
                                     ) NO-ERROR.
IF ERROR-STATUS:ERROR THEN DO:
  UNDO, RETURN ERROR.
END.
END PROCEDURE.
PROCEDURE create-operator :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE parameter BUFFER buf_ruledict FOR ub.ruledict.
DEFINE VARIABLE v-script-al AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-format AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-character AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-longchar AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-date AS date NO-UNDO.
DEFINE VARIABLE v-decimal AS decimal NO-UNDO.
DEFINE VARIABLE v-integer AS integer NO-UNDO.
DEFINE VARIABLE v-logical AS logical NO-UNDO.
DEFINE VARIABLE v-ok AS logical NO-UNDO.
IF buf_ruledict.ENTRY-TYPE = 'datatype':U
THEN DO:
  CASE buf_ruledict.script-al:
    WHEN 'character':U THEN DO:
       run gbl/d-character.w (
                               INPUT ?
                              ,INPUT '':U
                              ,input-output v-character
                              ,output v-ok
                               ) NO-ERROR.
       IF ERROR-STATUS:ERROR
       OR NOT v-ok THEN undo, RETURN error.
       ASSIGN
       v-script-al = substitute('"&1"', v-character)
       v-script-nl = substitute('"&1"', v-character)
       .
    END.
    WHEN 'longchar':U THEN DO:
       run gbl/d-longchar.w (
                               INPUT ?
                              ,INPUT '':U
                              ,input-output v-longchar
                              ,output v-ok
                               ) NO-ERROR.
       IF ERROR-STATUS:ERROR
       OR NOT v-ok THEN undo, RETURN error.
       ASSIGN
       v-script-al = substitute('"&1"', v-longchar)
       v-script-nl = substitute('"&1"', v-longchar)
       v-longchar = '':U
       .
    END.
    WHEN 'date':U THEN DO:
        v-format = "99/99/9999".
      run gbl/d-inpday.w
        (input ?
        ,input "Календарь"
        ,input ""
        ,input ""
        ,input-output v-date
        ,output v-ok
        ) NO-ERROR.
      IF ERROR-STATUS:ERROR
      OR NOT v-ok THEN undo, RETURN error.
      ASSIGN
      v-script-al = substitute('&1', string(v-date, "99/99/9999"))
      v-script-nl = substitute('&1', string(v-date, "99/99/9999"))
      .
    END.
    WHEN 'decimal':U THEN DO:
        v-format = "->>>,>>>,>>9.999".
        run gbl/d-decimal.w (
                                INPUT ?
                               ,INPUT ('format=' + v-format + '\':u
                                       )
                                 , input-output v-decimal
                                 , output v-ok
                                     ) NO-ERROR.
        IF ERROR-STATUS:ERROR
        OR NOT v-ok THEN undo, RETURN error.
        ASSIGN
        v-script-al = substitute('&1', string(v-decimal))
        v-script-nl = substitute('&1', string(v-decimal))
        .
    END.
    WHEN 'integer':U THEN DO:
        v-format = "->>>,>>>,>>9".
        run gbl/d-integer.w (
                                INPUT ?
                               ,INPUT ('format=' + v-format + '\':u
                                         )
                                 , input-output v-integer
                                 , output v-ok
                                     ) NO-ERROR.
        ASSIGN
        v-script-al = substitute('&1', string(v-integer))
        v-script-nl = substitute('&1', string(v-integer))
        .
    END.
    WHEN 'logical':U THEN DO:
        v-format = "+/".
        run gbl/d-logical.w (
                                INPUT ?
                               ,INPUT ('format=' + v-format + '\':u
                                 )
                                 , input-output v-logical
                                 , output v-ok
                                     ) NO-ERROR.
        ASSIGN
        v-script-al = substitute('&1', string(v-logical))
        v-script-nl = substitute('&1', string(v-logical))
        .
    END.
  END CASE.
  message v-script-al view-as alert-box .
END.
ELSE DO:
  ASSIGN
  v-script-nl = buf_ruledict.script-nl
  v-script-al = buf_ruledict.script-al
  .
END.
RUN create-widget IN THIS-PROCEDURE ( INPUT 0
                                     ,input 0
                                     ,INPUT p-language
                                     ,INPUT v-script-al
                                     ,INPUT v-script-al
                                     ,INPUT v-script-nl
                                     ,INPUT (IF buf_ruledict.entry-type = 'control':U
                                             or buf_ruledict.entry-type = 'operator':U
                                             THEN buf_ruledict.entry-type
                                             ELSE '':U)
                                     ,INPUT '':U
                                     ,INPUT '':u
                                     ,INPUT (IF buf_ruledict.entry-type = 'datatype':U
                                             THEN buf_ruledict.script-al
                                             ELSE '':U)
                                     ,input '':U
                                     ,input buf_ruledict.uniq-key-rec
                                                 ).
END PROCEDURE.
PROCEDURE create-parameter :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE parameter BUFFER buf_tt-ruledict-param FOR tt-ruledict-param.
RUN create-widget IN THIS-PROCEDURE ( INPUT 0
                                     ,INPUT 0
                                     ,INPUT p-language
                                     ,INPUT buf_tt-ruledict-param.param-name
                                     ,INPUT buf_tt-ruledict-param.param-name
                                     ,INPUT buf_tt-ruledict-param.param-label
                                     ,INPUT 'parameter':U
                                     ,INPUT '':U
                                     ,INPUT buf_tt-ruledict-param.param-data-type
                                     ,INPUT buf_tt-ruledict-param.param-data-type
                                     ,input '':U
                                     ,input '':U
                                         ).
END PROCEDURE.
PROCEDURE create-prop-script :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE parameter BUFFER buf_prop-script FOR ub.prop-script.
DEFINE parameter BUFFER buf_ruledict FOR ub.ruledict.
DEFINE VARIABLE v-object-type AS CHARACTER NO-UNDO.
IF LOOKUP(buf_prop-script.proc-type, 'class,data-member,property,method,constructor,destructor':u) > 0  THEN DO:
  v-object-type = trim(entry(2, buf_prop-script.script-body, chr(32)), ".").
  v-object-type = ENTRY(NUM-ENTRIES(v-object-type, "."), v-object-type, ".").
END.
ELSE DO:
  v-object-type = buf_prop-script.script-value-type.
END.
RUN create-widget IN THIS-PROCEDURE ( INPUT buf_prop-script.dtm-code
                                     ,INPUT buf_prop-script.class-dtm-code
                                     ,INPUT p-language
                                     ,INPUT buf_prop-script.script-name
                                     ,INPUT buf_prop-script.script-name
                                     ,INPUT buf_ruledict.script-nl
                                     ,INPUT 'prop-script':U
                                     ,INPUT buf_prop-script.script-type
                                     ,INPUT buf_prop-script.script-value-type
                                     ,INPUT v-object-type
                                     ,input buf_prop-script.proc-type
                                     ,input buf_prop-script.uniq-key-rec
                                     ).
END PROCEDURE.
PROCEDURE create-rule-i-script :
DEFINE INPUT PARAMETER p-dtm-code AS INTEGER NO-UNDO.
define input parameter p-class-dtm-code as integer no-undo .
DEFINE INPUT PARAMETER p-i-script-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-i-script-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-type AS CHARACTER NO-UNDO.
define input parameter p-subsid as logical no-undo .
DEFINE VARIABLE v-sub-object AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-script FOR ub.prop-script.
DEFINE BUFFER buf_tt-loc-rule-i-script FOR tt-loc-rule-i-script.
do
on error undo, return error
:
  IF p-i-script-type = 'variable':U
  and not p-subsid
  THEN DO:
      find first buf_tt-loc-rule-i-script where
                buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
            and buf_tt-loc-rule-i-script.script-name = p-script-name no-error.
        if not available buf_tt-loc-rule-i-script then do:
          if lookup(p-script-type, 'character,date,datetime,datetime-tz,decimal,integer,void,logical,memptr,raw,recid,rowid,widget-handle,handle,blob,clob,class,com-handle,longchar,int64':U) = 0 then do:
            find first buf_prop-script no-lock where
                    buf_prop-script.language = 'ABL'
                and buf_prop-script.script-name = p-script-type
                and buf_prop-script.dtm-code = p-dtm-code
                and buf_prop-script.proc-type = 'class':U no-error.
            if not available buf_prop-script then do:
              message
              substitute("Не найден класс типа &1", p-script-type)
              view-as alert-box error .
              undo, return error .
            end.
          end.
          create buf_tt-loc-rule-i-script.
          assign
          buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
          buf_tt-loc-rule-i-script.i-script-type = p-i-script-type
          buf_tt-loc-rule-i-script.i-script-name = p-I-script-name
          buf_tt-loc-rule-i-script.script-type = p-script-type
          buf_tt-loc-rule-i-script.script-name = p-script-name
          buf_tt-loc-rule-i-script.dtm-code = (if available buf_prop-script
                                               then buf_prop-script.dtm-code
                                               else 0)
          buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
          buf_tt-loc-rule-i-script.revis_id = (if available buf_prop-script
                                               then buf_prop-script.revis_id
                                               else 0)
          buf_tt-loc-rule-i-script.script_id = p-script-id
          .
        end.
  END.
  ELSE DO:
    if p-subsid = no then do:
      find first buf_prop-script no-lock where
                buf_prop-script.dtm-code = p-dtm-code
            and buf_prop-script.class-dtm-code = p-class-dtm-code
            and buf_prop-script.language = 'ABL'
            and buf_prop-script.script-name = p-script-name no-error.
      if not available buf_prop-script then do:
        message
        "not available buf_prop-script"
        p-script-name p-dtm-code  ("l" + p-script-type + "@") p-i-script-type
        view-as alert-box .
        UNDO, RETURN ERROR.
      end.
      find first buf_tt-loc-rule-i-script where
              buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
          and buf_tt-loc-rule-i-script.i-script-name = p-i-script-name
          AND buf_tt-loc-rule-i-script.script_id = p-script-id no-error.
      if not available buf_tt-loc-rule-i-script then do:
        create buf_tt-loc-rule-i-script.
        assign
        buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
        buf_tt-loc-rule-i-script.i-script-type = p-i-script-type
        buf_tt-loc-rule-i-script.i-script-name = p-i-script-name
        buf_tt-loc-rule-i-script.script-type = p-script-type
        buf_tt-loc-rule-i-script.script-name = p-script-name
        buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
        buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
        buf_tt-loc-rule-i-script.revis_id = buf_prop-script.revis_id
        buf_tt-loc-rule-i-script.script_id = p-script-id
        .
      end.
      v-sub-object = entry(1, p-script-name, '@').
      if p-dtm-code > 0
      AND lookup(buf_prop-script.proc-type, 'class,data-member,property,method,constructor,destructor':u) = 0  then do:
        if buf_prop-script.script-type = 'create':U
        or buf_prop-script.script-type = 'find':U
        or buf_prop-script.script-type = 'get':U
        or buf_prop-script.script-type = 'set':U
        then do:
          assign
          v-sub-object   = substring(v-sub-object, index(v-sub-object,'_':U) + 1)
          .
          find first buf_tt-loc-rule-i-script where
                    buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
                and buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
                and buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
                and buf_tt-loc-rule-i-script.i-script-type = 'define_b':U
                and buf_tt-loc-rule-i-script.script-name = ('buf_':U + v-sub-object )
                AND buf_tt-loc-rule-i-script.script_id = p-script-id no-error.
          if not available buf_tt-loc-rule-i-script then do:
            create buf_tt-loc-rule-i-script.
            assign
            buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
            buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
            buf_tt-loc-rule-i-script.dtm-code = p-class-dtm-code
            buf_tt-loc-rule-i-script.i-script-type = 'define_b':U
            buf_tt-loc-rule-i-script.i-script-name = 'buf_':U + v-sub-object
            buf_tt-loc-rule-i-script.script-type = 'define_b':U
            buf_tt-loc-rule-i-script.script-name = 'buf_':U + v-sub-object
            buf_tt-loc-rule-i-script.revis_id = buf_prop-script.revis_id
            buf_tt-loc-rule-i-script.script_id = p-script-id
            .
            create buf_tt-loc-rule-i-script.
            assign
            buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
            buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
            buf_tt-loc-rule-i-script.dtm-code = p-class-dtm-code
            buf_tt-loc-rule-i-script.i-script-type = 'define_tt':U
            buf_tt-loc-rule-i-script.i-script-name = 'buft_':U + v-sub-object
            buf_tt-loc-rule-i-script.script-type = 'define_tt':U
            buf_tt-loc-rule-i-script.script-name = 'buft_':U + v-sub-object
            buf_tt-loc-rule-i-script.script_id = p-script-id
            .
          end.
          find first buf_tt-loc-rule-i-script where
                    buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
                and buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
                and buf_tt-loc-rule-i-script.dtm-code = p-class-dtm-code
                and buf_tt-loc-rule-i-script.i-script-type = 'define_h'
                and buf_tt-loc-rule-i-script.script-name = ('vh_':U + v-sub-object)
                AND buf_tt-loc-rule-i-script.script_id = p-script-id no-error.
          if not available buf_tt-loc-rule-i-script then do:
            create buf_tt-loc-rule-i-script.
            assign
            buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
            buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
            buf_tt-loc-rule-i-script.dtm-code = p-class-dtm-code
            buf_tt-loc-rule-i-script.i-script-type = 'define_h':U
            buf_tt-loc-rule-i-script.i-script-name = 'vh_':U + v-sub-object
            buf_tt-loc-rule-i-script.script-type = 'define_h':U
            buf_tt-loc-rule-i-script.script-name = 'vh_':U + v-sub-object
            buf_tt-loc-rule-i-script.revis_id = buf_prop-script.revis_id
            buf_tt-loc-rule-i-script.script_id = p-script-id
            .
          end.
        end.
        v-sub-object = entry(1, p-script-name, '@').
        if buf_prop-script.script-type = 'create':U
        or buf_prop-script.script-type = 'set':U
        then do:
          assign
          v-sub-object   = substring(v-sub-object, index(v-sub-object,'_':U) + 1)
          .
          find first buf_tt-loc-rule-i-script where
                    buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
                and buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
                and buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
                and buf_tt-loc-rule-i-script.i-script-type = 'hist-nws'
                and buf_tt-loc-rule-i-script.script-name = ('hist-nws_':U + v-sub-object)
                AND buf_tt-loc-rule-i-script.script_id = p-script-id no-error.
          if not available buf_tt-loc-rule-i-script then do:
            create buf_tt-loc-rule-i-script.
            assign
            buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
            buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
            buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
            buf_tt-loc-rule-i-script.i-script-type = 'hist-nws'
            buf_tt-loc-rule-i-script.i-script-name = 'hist-nws_':U + v-sub-object
            buf_tt-loc-rule-i-script.script-type = 'hist-nws'
            buf_tt-loc-rule-i-script.script-name = 'hist-nws_':U + v-sub-object
            buf_tt-loc-rule-i-script.revis_id = buf_prop-script.revis_id
            buf_tt-loc-rule-i-script.script_id = p-script-id
            .
          end.
        end.
      end.
    end.
    else do:
      define variable v-tbl-row as rowid no-undo .
      define variable v-tbl-name as character no-undo .
      run gen-row-keyr in this-procedure
        ( input  p-i-script-name
         ,input ?
         ,input "ub"
         ,input ?
         ,input no-lock
         ,output v-tbl-row
         ,output v-tbl-name
        ).
      find first buf_prop-script where
              rowid(buf_prop-script) = v-tbl-row.
      find first buf_tt-loc-rule-i-script where
              buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
          and buf_tt-loc-rule-i-script.i-script-name = buf_prop-script.script-foot
          AND buf_tt-loc-rule-i-script.script_id = p-script-id no-error.
      if not available buf_tt-loc-rule-i-script then do:
        create buf_tt-loc-rule-i-script.
        assign
        buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
        buf_tt-loc-rule-i-script.i-script-type = 'ifunction':U
        buf_tt-loc-rule-i-script.i-script-name = buf_prop-script.script-foot
        buf_tt-loc-rule-i-script.script-type = '':U
        buf_tt-loc-rule-i-script.script-name = replace(buf_prop-script.script-foot
                                                     , "&" + substitute("&1", p-script-type)
                                                     , p-script-name)
        buf_tt-loc-rule-i-script.dtm-code = p-dtm-code
        buf_tt-loc-rule-i-script.class-dtm-code = p-class-dtm-code
        buf_tt-loc-rule-i-script.revis_id = buf_prop-script.revis_id
        buf_tt-loc-rule-i-script.script_id = p-script-id
        .
      end.
      else do:
        assign
        buf_tt-loc-rule-i-script.script-type = '':U
        buf_tt-loc-rule-i-script.script-name = replace(buf_tt-loc-rule-i-script.script-name
                                                     , "&" + substitute("&1", p-script-type)
                                                     , p-script-name)
        .
      end.
    end.
  END.
end.
END PROCEDURE.
PROCEDURE create-tt-complex :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE PARAMETER BUFFER buf_tt-complex FOR tt-complex.
DEFINE VARIABLE v-object-type AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_prop-script FOR ub.prop-script.
IF LOOKUP(buf_tt-complex.proc-type, 'class,data-member,property,method,constructor,destructor':u) > 0  THEN DO:
  FIND FIRST buf_prop-script NO-LOCK WHERE
            buf_prop-script.dtm-code = buf_tt-complex.class-dtm-code
      AND   buf_prop-script.script-name = buf_tt-complex.script-name.
END.
ELSE DO:
  v-object-type = buf_tt-complex.script-value-type.
END.
RUN create-widget IN THIS-PROCEDURE ( INPUT buf_tt-complex.dtm-code
                                     ,INPUT buf_tt-complex.class-dtm-code
                                     ,INPUT p-language
                                     ,INPUT buf_tt-complex.script-name
                                     ,INPUT buf_tt-complex.script-al
                                     ,INPUT buf_tt-complex.script-nl
                                     ,INPUT buf_tt-complex.entry-type
                                     ,INPUT buf_tt-complex.script-type
                                     ,INPUT buf_tt-complex.script-value-type
                                     ,INPUT v-object-type
                                     ,input buf_tt-complex.proc-type
                                     ,input '':U
                                     ).
END PROCEDURE.
PROCEDURE create-variable :
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE parameter BUFFER buf_tt-loc-rule-i-script FOR tt-rule-i-script.
RUN create-widget IN THIS-PROCEDURE ( INPUT buf_tt-loc-rule-i-script.dtm-code
                                     ,INPUT buf_tt-loc-rule-i-script.class-dtm-code
                                     ,INPUT p-language
                                     ,INPUT buf_tt-loc-rule-i-script.i-script-name
                                     ,INPUT buf_tt-loc-rule-i-script.script-name
                                     ,INPUT buf_tt-loc-rule-i-script.script-name
                                     ,INPUT '':U
                                     ,INPUT 'variable':U
                                     ,INPUT buf_tt-loc-rule-i-script.script-type
                                     ,INPUT buf_tt-loc-rule-i-script.script-type
                                     ,input '':U
                                     ,input '':U
                                     ).
END PROCEDURE.
PROCEDURE create-widget :
DEFINE INPUT PARAMETER p-dtm-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-class-dtm-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-language AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-al AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-nl AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-entry-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-script-value-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-DATA-type AS CHARACTER NO-UNDO.
define input parameter p-proc-type as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .
DEFINE VARIABLE v-len AS INTEGER NO-UNDO.
DEFINE VARIABLE v-color AS INTEGER NO-UNDO.
DEFINE VARIABLE v-widget-num AS INTEGER NO-UNDO.
DEFINE VARIABLE v-ano-script-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ano-script-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-index-al AS INTEGER NO-UNDO.
DEFINE VARIABLE v-index-nl AS INTEGER NO-UNDO.
DEFINE VARIABLE v-in-script AS logical NO-UNDO.
DEFINE VARIABLE v-level AS INTEGER NO-UNDO.
define variable glog as logical no-undo .
define variable v-sub-number as integer no-undo .
define variable v-main-sub-number as integer no-undo .
DEFINE BUFFER buf_tt-widget FOR tt-widget.
DEFINE BUFFER last_tt-widget FOR tt-widget.
DEFINE BUFFER buf_tt-widget-child FOR tt-widget-child.
RUN debug-proc( INPUT "kk.txt").
FOR EACH buf_tt-widget:
  IF buf_tt-widget.HANDLE_:SELECTED = YES
  and buf_tt-widget.script-type = 'variable':U
  and lookup(p-proc-type, 'class,data-member,property,method,constructor,destructor':u) > 0
  and (buf_tt-widget.data-type = p-data-type
        or
        buf_tt-widget.class-dtm-code = p-class-dtm-code)
  then do:
    message
    substitute("Использовать объект &1 в скрипте?", buf_tt-widget.script-al)
    view-as alert-box question buttons yes-no update glog.
    if not glog then next.
    entry(1, p-script-al, ':') = buf_tt-widget.script-al.
    entry(1, p-script-nl, ':') = buf_tt-widget.script-nl.
    RUN proc-delete IN THIS-PROCEDURE ( BUFFER buf_tt-widget).
    leave.
  end.
END.
FOR EACH buf_tt-widget:
  IF buf_tt-widget.HANDLE_:SELECTED = YES
  AND real-index(buf_tt-widget.script-al, "&", 1, output v-sub-number) > 0  THEN DO:
     v-index-al = real-index(buf_tt-widget.script-al, "&", 1, v-main-sub-number).
     v-index-nl = real-index(buf_tt-widget.script-nl, "&", 1, v-sub-number).
     FIND FIRST buf_tt-widget-child WHERE
                buf_tt-widget-child.num_ = buf_tt-widget.num_
           AND  buf_tt-widget-child.position-al = v-index-al NO-ERROR.
     IF NOT AVAILABLE buf_tt-widget-child THEN UNDO, RETURN ERROR.
     IF right-trim(buf_tt-widget-child.param-data-type, chr(44)) <> trim(p-data-type, chr(44))
     AND right-trim(buf_tt-widget-child.param-data-type, chr(44)) <> trim(entry(1, p-data-type, chr(44)))
     and not (p-data-type = "-" and buf_tt-widget-child.param-data-type = 'void':U)
     THEN DO:
        MESSAGE
        substitute("Вставляемый скрипт &1 имеет тип данных <&2>&3" +
                   "А параметр &4 - имеет тип данных <&5>&3" +
                   "Продолжить?"
                   ,p-script-al
                   ,p-data-type
                   ,chr(10)
                   ,buf_tt-widget-child.param-name
                   ,buf_tt-widget-child.param-data-type)
        VIEW-AS ALERT-BOX question buttons yes-no update glog.
        if not glog then next.
     END.
     v-level = buf_tt-widget-child.level_ + 1.
     v-widget-num = buf_tt-widget.num_.
     ASSIGN
     buf_tt-widget-child.script-al = p-script-al
     buf_tt-widget-child.script-nl = p-script-nl
     buf_tt-widget.script-al = substring(buf_tt-widget.script-al, 1, v-index-al - 1) +
                               p-script-al +
                               substring(buf_tt-widget.script-al, v-index-al + 2)
     buf_tt-widget.script-nl = substring(buf_tt-widget.script-nl, 1, v-index-nl - 1) +
                               p-script-nl +
                                  substring(buf_tt-widget.script-nl, v-index-nl + 2).
    FOR EACH buf_tt-widget-child WHERE
            buf_tt-widget-child.num_ = buf_tt-widget.num_:
       ASSIGN
       buf_tt-widget-child.position-al = (IF buf_tt-widget-child.position-al > v-index-al
                                          THEN buf_tt-widget-child.position-al + LENGTH(p-script-al) - 2
                                          ELSE   buf_tt-widget-child.position-al)
       buf_tt-widget-child.position-nl = (IF buf_tt-widget-child.position-nl > v-index-nl
                                          THEN buf_tt-widget-child.position-nl + LENGTH(p-script-nl) - 2
                                          ELSE   buf_tt-widget-child.position-nl)
       .
    END.
    run create-widget-child in this-procedure ( buffer buf_tt-widget
                                              ,INPUT v-level
                                              ,INPUT v-index-al
                                              ,INPUT v-index-nl
                                              ,INPUT p-entry-type
                                              ,INPUT p-script-al
                                              ,input p-script-type
                                              ,output v-sub-number
                                              ).
    if buf_tt-widget.script-type = 'get-ifunction':U
    and v-main-sub-number > 0 then do:
      RUN CREATE-rule-i-script IN THIS-PROCEDURE  ( INPUT buf_tt-widget.dtm-code
                                                  ,input buf_tt-widget.class-dtm-code
                                                  ,INPUT buf_tt-widget.uniq-key-rec
                                                  ,INPUT p-script-type
                                                  ,INPUT p-script-al
                                                  ,INPUT string(v-main-sub-number)
                                                  ,input yes  ) NO-ERROR.
      IF error-status:error tHEN DO:
        UNDO, return ERROR.
      END.
    end.
    ASSIGN
    v-in-script = YES.
    leave.
  END.
END.
IF v-in-script = NO  THEN DO:
  CASE p-entry-type:
    WHEN 'prop-script':U THEN DO:
      v-len = 45.
      v-color = BLUE_COLOR.
    END.
    WHEN 'operator':U THEN DO:
      v-len = 5.
      v-color = BROWN_COLOR.
    END.
    WHEN 'constant':U THEN DO:
        v-len = 5.
        v-color = BROWN_COLOR.
    END.
    WHEN 'datatype':U THEN DO:
      v-len = 40.
      v-color = DARK_GREEn_COLOR.
    END.
    WHEN '-':U THEN DO:
        v-len = 60.
        v-color = BLACK_COLOR.
    END.
    WHEN '':U THEN DO:
      ASSIGN
      v-len = length(p-script-al)
      v-color = BLACK_COLOR
      .
    END.
  END CASE.
  FIND LAST buf_tt-widget NO-ERROR.
  V-WIDGET-NUM = (IF AVAILABLE BUF_TT-widget
                    THEN BUF_TT-WIDGET.NUM_
                    ELSE 0) + 1.
  FIND LAST LAST_tt-widget USE-INDEX irc NO-ERROR.
  IF AVAILABLE LAST_tt-widget THEN DO:
    ASSIGN
    v-current-row = get-current-row(last_tt-widget.right-bottom)
    v-current-column = get-current-column(last_tt-widget.right-bottom)
    .
  END.
  else do:
    ASSIGN
    v-current-row = 18
    v-current-column = 1
    .
  end.
  IF MINIMUM(length(p-script-nl), v-len) + v-current-column + 1 > 98 THEN DO:
    ASSIGN
    v-current-row = v-current-row + 1
    v-current-column = 1
    .
  END.
  CREATE buf_tt-widget.
  assign
  buf_tt-widget.num_ = v-widget-num
  buf_tt-widget.NAME_ = "n" + STRING(buf_tt-widget.num_)
  buf_tt-widget.entry-type = p-entry-type
  buf_tt-widget.script-type = p-script-type
  buf_tt-widget.script-value-type = p-script-value-type
  buf_tt-widget.data-type = p-data-type
  buf_tt-widget.script-nl = p-script-nl
  buf_tt-widget.script-al = p-script-al
  buf_tt-widget.ROW_ = v-current-row
  buf_tt-widget.column_ = v-current-column
  buf_tt-widget.WIDTH_ = MINIMUM(length(buf_tt-widget.script-nl), v-len)
  buf_tt-widget.WIDTH_ = (IF buf_tt-widget.width_ < 5
                          THEN 5
                          ELSE buf_tt-widget.WIDTH_)
  buf_tt-widget.dtm-code = p-dtm-code
  buf_tt-widget.class-dtm-code = p-class-dtm-code
  buf_tt-widget.uniq-key-rec = p-uniq-key-rec
  .
  if real-index(buf_tt-widget.script-nl, "&", 1, v-sub-number) > 0 then do:
     run create-widget-child in this-procedure ( buffer buf_tt-widget
                                                ,INPUT 1
                                                ,INPUT 0
                                                ,INPUT 0
                                                ,INPUT p-entry-type
                                                ,INPUT p-script-name
                                                ,input p-script-type
                                                ,output v-sub-number
                                                ) NO-ERROR.
  end.
end.
else do:
end.
FIND FIRST buf_tt-widget WHERE
        buf_tt-widget.num_ = v-widget-num.
IF VALID-HANDLE(buf_tt-widget.HANDLE) THEN
assign
buf_tt-widget.handle_:SCREEN-VALUE = (IF p-language = "ABL"
                                        THEN buf_tt-widget.script-al
                                        ELSE buf_tt-widget.script-nl)
  .
RUN debug-proc( INPUT "jj.txt").
ASSIGN
buf_tt-widget.length_ = maximum(LENGTH(buf_tt-widget.script-nl), LENGTH(buf_tt-widget.script-al))
buf_tt-widget.right-bottom = get-right-bottom(buf_tt-widget.ROW_
                                             ,buf_tt-widget.width_
                                             ,buf_tt-widget.COLUMN_
                                             ,buf_tt-widget.HEIGHT_)
buf_tt-widget.left-top = get-left-top(buf_tt-widget.ROW_
                                             ,buf_tt-widget.width_
                                             ,buf_tt-widget.COLUMN_
                                             ,buf_tt-widget.HEIGHT_)
v-current-row = get-current-row(buf_tt-widget.right-bottom)
v-current-column = get-current-column(buf_tt-widget.right-bottom)
.
if not v-in-script then do:
  create EDITOR buf_tt-widget.HANDLE_
  assign
  frame = frame Dialog-Frame:handle
  row = buf_tt-widget.ROW_
  column = buf_tt-widget.COLUMN_
  NAME = buf_tt-widget.NAME_
  scrollbar-vertical = yes
  height-chars = 1
  width-chars = buf_tt-widget.width_
  sensitive = yes
  visible = true
  movable = true
  READ-ONLY = YES
  RESIZABLE = YES
  selectable = YES
  FGCOLOR = v-color
  SCREEN-VALUE = (IF p-language = "ABL"
                  THEN buf_tt-widget.script-al
                  ELSE buf_tt-widget.script-nl)
  FONT = 4
  triggers:
    on END-RESIZE
      persistent run do-not-resize .
    on END-MOVE
      persistent run proc-end-move .
  end triggers.
END.
IF lookup(p-entry-type, 'constant':U + chr(44) +
                        'operator':U + chr(44) +
                        'control':U + chr(44) +
                        'parameter':U + chr(44) +
                        "-" + chr(44) +
                        "":U) = 0 THEN DO:
    ASSIGN
    v-ano-script-name = p-script-name
    v-ano-script-type = p-DATA-type
    .
    RUN CREATE-rule-i-script IN THIS-PROCEDURE  ( INPUT p-dtm-code
                                                 ,input p-class-dtm-code
                                                 ,INPUT p-script-al
                                                 ,INPUT p-script-type
                                                 ,INPUT v-ano-script-name
                                                 ,INPUT v-ano-script-type
                                                 ,input no
                                                 ) NO-ERROR.
    IF error-status:error tHEN DO:
       UNDO, return ERROR.
    END.
END.
END PROCEDURE.
PROCEDURE create-widget-child :
DEFINE PARAMETER BUFFER buf_tt-widget FOR tt-widget.
DEFINE INPUT PARAMETER p-level AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-position-al AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-position-nl AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-entry-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-script-name AS character NO-UNDO.
define input parameter p-script-type as character no-undo .
define output parameter p-sub-number as integer no-undo .
DEFINE BUFFER buf_tt-widget-child FOR tt-widget-child.
DEFINE BUFFER buf_ruledict FOR ub.ruledict.
DEFINE BUFFER buf_ruledict-param FOR ub.ruledict-param.
IF p-entry-type = '-'
OR p-entry-type = 'parameter':U
OR p-entry-TYPE = '':U THEN RETURN.
FIND FIRST buf_ruledict NO-LOCK WHERE
          buf_Ruledict.entry-type = p-entry-type
       AND buf_ruledict.script-al = p-script-name NO-ERROR.
IF not available buf_Ruledict THEN DO:
   UNDO, RETURN ERROR.
END.
FOR EACH buf_tt-widget-child WHERE
       buf_tt-widget-child.num_ = buf_tt-widget.num_
    AND buf_tt-widget-child.level_= p-level:
  DELETE buf_tt-widget-child.
END.
FOR EACH buf_ruledict-param NO-LOCK WHERE
        buf_ruledict-param.entry-id = buf_ruledict.entry-id
    and buf_ruledict-param.param-num > 0:
  CREATE buf_tt-widget-child.
  ASSIGN
  buf_tt-widget-child.num_ = buf_tt-widget.num_
  buf_tt-widget-child.level_ = p-level
  buf_tt-widget-child.param-data-type = buf_ruledict-param.param-data-type
  buf_tt-widget-child.param-2-data-type = buf_ruledict-param.param-2-data-type
  buf_tt-widget-child.param-3-data-type = buf_ruledict-param.param-3-data-type
  buf_tt-widget-child.param-label = buf_ruledict-param.param-label
  buf_tt-widget-child.param-mode = buf_ruledict-param.param-mode
  buf_tt-widget-child.param-name = buf_ruledict-param.param-name
  buf_tt-widget-child.param-num = buf_ruledict-param.param-num
  buf_tt-widget-child.script-nl = '':U
  buf_tt-widget-child.script-al = '':U
  buf_tt-widget-child.entry-id = buf_ruledict-param.entry-id
  buf_tt-widget.script-al-fix = buf_ruledict.script-al
  .
  define variable v-al as integer no-undo .
  define variable v-nl as integer no-undo .
  define variable v-sub-number-al as integer no-undo .
  define variable v-sub-number-nl as integer no-undo .
  ASSIGN
  v-al = real-INDEX(buf_tt-widget.script-al, ("&" + STRING(buf_tt-widget-child.param-num)), 1, output v-sub-number-al)
                                                                        + (IF p-level = 1 THEN 0 ELSE (p-position-al - 1))
  v-nl = real-INDEX(buf_ruledict.script-nl, ("&" + STRING(buf_tt-widget-child.param-num)), 1, output v-sub-number-nl)
                                                                       + (IF p-level = 1 THEN 0 ELSE (p-position-nl - 1))
  .
  if v-sub-number-al > 0
  and p-script-type = 'get-ifunction':U
  then do:
    p-sub-number = v-sub-number-al.
  end.
  assign
  buf_tt-widget-child.position-al = v-al
  buf_tt-widget-child.position-nl = v-nl
  .
END.
END PROCEDURE.
PROCEDURE debug-proc :
DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-widget FOR tt-widget.
DEFINE BUFFER buf_tt-widget-child FOR tt-widget-child.
OUTPUT TO VALUE(p-file-name).
FOR EACH buf_tt-widget-child:
    EXPORT buf_tt-widget-child.
END.
FOR EACH buf_tt-widget:
    EXPORT buf_tt-widget EXCEPT HANDLE_.
END.
OUTPUT close.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE do-not-resize :
DEFINE BUFFER buf_tt-widget for tt-widget.
FIND FIRST buf_tt-widget NO-LOCK WHERE
          buf_tt-widget.HANDLE_ = SELF.
ASSIGN
SELF:HEIGHT = 1.5
SELF:WIDTH = MINIMUM(length(SELF:SCREEN-VALUE), 45)
buf_tt-widget.WIDTH_ = SELF:WIDTH
.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RS-language cb-pscript-ruleset f-prop-script F-operator f-variable
          f-parameter f-complex f-defvariable
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-complex b-quit RS-language B-Help cb-pscript-ruleset
         br-variable br-parameter br-operator br-dtruledict br-complex
         br-pscript-ruleset b-defvariable B-operator b-parameter B-prop-script
         b-variable f-prop-script F-operator f-variable f-parameter f-complex
         f-defvariable
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-complex FOR EACH tt-complex.    OPEN QUERY br-dtruledict FOR EACH X_dtruledict NO-LOCK WHERE X_dtruledict.entry-type = 'datatype':U INDEXED-REPOSITION .    OPEN QUERY br-operator FOR EACH Y_ruledict NO-LOCK WHERE      (Y_ruledict.ENTRY-TYPE = 'operator':U       OR       Y_ruledict.ENTRY-TYPE = 'constant':U       OR       Y_ruledict.ENTRY-TYPE = 'datatype':U       OR       Y_ruledict.ENTRY-TYPE = 'control':U       ) .    OPEN QUERY br-parameter FOR EACH tt-ruledict-param.    OPEN QUERY br-pscript-ruleset FOR EACH X_prop-script NO-LOCK where        X_prop-script.dtm-code = integer(cb-pscript-ruleset),            FIRST X_pscript-ruleset NO-LOCK WHERE      X_pscript-ruleset.codex_id = p-codex-id     AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)     AND  X_prop-script.language = X_pscript-ruleset.LANGUAGE     AND  X_prop-script.script-name = X_pscript-ruleset.script-name     AND  X_prop-script.revis_id = X_pscript-ruleset.revis_id,            FIRST X_ruledict NO-LOCK WHERE      X_ruledict.ENTRY-TYPE = 'prop-script':U AND  X_ruledict.uniq-key-rec = X_prop-script.uniq-key-rec.    OPEN QUERY br-variable FOR EACH bufv_tt-rule-i-script NO-LOCK WHERE bufv_tt-rule-i-script.root_rule_id = p-root-rule-id  AND bufv_tt-rule-i-script.i-script-type = 'variable':U INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE fill-tables :
DEFINE BUFFER buf_tt-loc-rule-i-script FOR tt-loc-rule-i-script.
DEFINE BUFFER buf_tt-rule-i-script FOR tt-rule-i-script.
  FOR EACH buf_tt-loc-rule-i-script:
    delete buf_tt-loc-rule-i-script.
  END.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    FOR EACH buf_tt-rule-i-script NO-LOCK WHERE
              buf_tt-rule-i-script.root_rule_id = p-rule-id
         AND  buf_tt-rule-i-script.script_id = p-script-id:
        CREATE buf_tt-loc-rule-i-script.
        BUFFER-COPY buf_tt-rule-i-script TO buf_tt-loc-rule-i-script.
    END.
    FIND FIRST tt-rule-script WHERE
           tt-rule-script.script_id = p-script-id
        and tt-rule-script.language = "ABL".
    FIND FIRST tt-l_rule-script WHERE
           tt-l_rule-script.script_id = p-script-id
           and tt-l_rule-script.language = "rus" .
    FIND FIRST tt-rule WHERE
              tt-rule.RULE_id = p-rule-id.
  end.
  else do:
    FIND FIRST tt-rule WHERE
                  tt-rule.RULE_id = p-rule-id.
    CREATE tt-rule-script.
     ASSIGN
     tt-rule-script.script_id = 0
     tt-rule-script.RULE_id = p-rule-id
     tt-rule-script.root_RULE_id = p-root-rule-id
     tt-rule-script.salience = p-salience
     tt-rule-script.script-type = p-script-type
     tt-rule-script.LANGUAGE = "ABL".
     RELEASE tt-rule-script.
     FIND FIRST tt-rule-script WHERE
              tt-rule-script.script_id = 0
          AND tt-rule-script.LANGUAGE = "ABL".
     CREATE tt-l_rule-script.
     ASSIGN
     tt-l_rule-script.script_id = 0
     tt-l_rule-script.RULE_id = p-rule-id
     tt-l_rule-script.root_RULE_id = p-root-rule-id
     tt-l_rule-script.salience = p-salience
     tt-l_rule-script.script-type = p-script-type
     tt-l_rule-script.LANGUAGE = "rus".
     RELEASE tt-l_rule-script.
     FIND FIRST tt-l_rule-script WHERE
              tt-l_rule-script.script_id = 0
         AND tt-l_rule-script.LANGUAGE = "rus".
  end.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-dtm-label AS CHARACTER no-undo.
DEFINE BUFFER buf_prop-ruleset FOR ub.prop-ruleset.
DEFINE BUFFER buf_prop-head FOR ub.prop-head.
assign
cb-pscript-ruleset:DELIMITER in FRAME Dialog-Frame = "|"
cb-pscript-ruleset:list-item-pairs = "|":U
.
_prop-ruleset:
FOR EACH buf_prop-ruleset NO-LOCK WHERE
        buf_prop-ruleset.codex_id = p-codex-id
BREAK BY buf_prop-ruleset.dtm-code:
   IF first-of(buf_prop-ruleset.dtm-CODE) THEN DO:
     FIND FIRST buf_prop-head NO-LOCK WHERE
                buf_prop-head.dtm-code = buf_prop-ruleset.dtm-code NO-ERROR.
     IF NOT AVAILABLE buf_prop-head THEN DO:
        NEXT _prop-ruleset.
     END.
     v-dtm-label = replace(buf_prop-head.prop-label, "|", chr(32)).
     cb-pscript-ruleset:ADD-LAST(v-dtm-label, string(buf_prop-ruleset.dtm-code)) IN FRAME Dialog-Frame.
   END.
END.
ASSIGN
cb-pscript-ruleset = "0"
rs-language:radio-buttons in frame Dialog-Frame = "ABL" + chr(44) + "ABL" + chr(44) +
                                                   "rus" + chr(44) + "rus"
X_pscript-ruleset.script-name:RESIZABLE IN BROWSE br-pscript-ruleset =  yes
X_ruledict.script-nl:RESIZABLE IN BROWSE br-pscript-ruleset =  yes
Y_ruledict.script-al:RESIZABLE IN BROWSE br-operator =  yes
Y_ruledict.script-nl:RESIZABLE IN BROWSE br-operator =  yes
tt-complex.script-al:RESIZABLE IN BROWSE br-complex =  yes
tt-complex.script-nl:RESIZABLE IN BROWSE br-complex =  yes
FRAME Dialog-Frame:TITLE = SUBSTITUTE("Скрипт типа &1, номер вышестояшего правила &2, номер корневого правила &3"
                                       , p-script-type
                                       ,p-upper-rule-id
                                       ,p-root-rule-id).
.
DISPLAY
RS-language
b-prop-script
b-operator
b-defvariable WHEn p-script-type <> 'COND':U
b-variable
b-parameter
b-complex
f-prop-script
f-operator
f-defvariable WHEn p-script-type <> 'COND':U
f-variable
f-parameter
f-complex
CB-PSCRIPT-RULESET
WITH FRAME Dialog-Frame.
ENABLE
B-exit
b-quit
RS-language
B-Help
cb-pscript-ruleset
br-operator
br-pscript-ruleset
b-prop-script
b-operator
b-variable
b-parameter
b-complex
b-defvariable WHEn p-script-type <> 'COND':U
br-dtruledict WHEn p-script-type <> 'COND':U
br-variable
br-parameter
br-complex
WITH FRAME Dialog-Frame.
APPLY "VALUE-CHANGED" TO rs-language.
APPLY "VALUE-CHANGED" TO cb-pscript-ruleset.
VIEW FRAME Dialog-Frame.
OPEN QUERY br-complex FOR EACH tt-complex.    OPEN QUERY br-dtruledict FOR EACH X_dtruledict NO-LOCK WHERE X_dtruledict.entry-type = 'datatype':U INDEXED-REPOSITION .    OPEN QUERY br-operator FOR EACH Y_ruledict NO-LOCK WHERE      (Y_ruledict.ENTRY-TYPE = 'operator':U       OR       Y_ruledict.ENTRY-TYPE = 'constant':U       OR       Y_ruledict.ENTRY-TYPE = 'datatype':U       OR       Y_ruledict.ENTRY-TYPE = 'control':U       ) .    OPEN QUERY br-parameter FOR EACH tt-ruledict-param.    OPEN QUERY br-pscript-ruleset FOR EACH X_prop-script NO-LOCK where        X_prop-script.dtm-code = integer(cb-pscript-ruleset),            FIRST X_pscript-ruleset NO-LOCK WHERE      X_pscript-ruleset.codex_id = p-codex-id     AND X_pscript-ruleset.dtm-code = integer(cb-pscript-ruleset)     AND  X_prop-script.language = X_pscript-ruleset.LANGUAGE     AND  X_prop-script.script-name = X_pscript-ruleset.script-name     AND  X_prop-script.revis_id = X_pscript-ruleset.revis_id,            FIRST X_ruledict NO-LOCK WHERE      X_ruledict.ENTRY-TYPE = 'prop-script':U AND  X_ruledict.uniq-key-rec = X_prop-script.uniq-key-rec.    OPEN QUERY br-variable FOR EACH bufv_tt-rule-i-script NO-LOCK WHERE bufv_tt-rule-i-script.root_rule_id = p-root-rule-id  AND bufv_tt-rule-i-script.i-script-type = 'variable':U INDEXED-REPOSITION.
APPLY "CHOOSE" TO b-prop-script.
IF p-script-type = 'COND':U THEN DO:
  HIDE
  br-dtruledict
  f-defvariable
  b-defvariable
  IN FRAME Dialog-Frame.
END.
END PROCEDURE.
PROCEDURE proc-delete :
DEFINE PARAMETER BUFFER buf_tt-widget FOR tt-widget.
define buffer buf_tt-complex for tt-complex.
define buffer buf_tt-widget-child for tt-widget-child.
if buf_tt-widget.entry-type = '-' then do:
  for each buf_tt-complex where buf_tt-complex.script-al = buf_tt-widget.script-al:
    delete buf_tt-complex.
  end.
  OPEN QUERY br-complex FOR EACH tt-complex.
end.
FOR EACH buf_tt-widget-child WHERE
        buf_tt-widget-child.num_ = buf_tt-widget.num_:
  DELETE buf_tt-widget-child.
END.
DELETE WIDGET buf_tt-widget.HANDLE_.
DELETE buf_tt-widget.
END PROCEDURE.
PROCEDURE proc-end-move :
DEFINE BUFFER buf_tt-widget for tt-widget.
FIND FIRST buf_tt-widget NO-LOCK WHERE
          buf_tt-widget.HANDLE_ = SELF.
ASSIGN
SELF:ROW = ROUND(SELF:ROW, 0)
SELF:column = ROUND(SELF:column, 0)
buf_tt-widget.row_ = SELF:ROW
buf_tt-widget.column_ = SELF:column.
buf_tt-widget.right-bottom = get-right-bottom ( INPUT buf_tt-widget.row_
                                              ,INPUT buf_tt-widget.width_
                                              ,INPUT buf_tt-widget.column_
                                              ,INPUT buf_tt-widget.height_).
END PROCEDURE.
PROCEDURE proc-init-b-complex :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-complex:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 f-complex:fgcolor = 1   .
 b-prop-script:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-operator:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-defvariable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-parameter:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-variable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-prop-script:fgcolor = ?
 f-operator:fgcolor = ?
 f-defvariable:fgcolor = ?
 f-parameter:fgcolor = ?
 f-variable:fgcolor = ?
 br-operator:VISIBLE IN FRAME Dialog-Frame = NO
 br-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = NO.
 cb-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = NO.
 br-dtruledict:VISIBLE IN FRAME Dialog-Frame = NO.
 br-variable:VISIBLE IN FRAME Dialog-Frame  = NO.
 br-parameter:VISIBLE IN FRAME Dialog-Frame  = NO.
 br-complex:VISIBLE IN FRAME Dialog-Frame  = YES.
 glog = br-complex:MOVE-TO-TOP().
end.
END PROCEDURE.
PROCEDURE proc-init-b-defvariable :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-defvariable:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 f-defvariable:fgcolor = 1   .
 b-prop-script:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-operator:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-variable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-parameter:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-complex:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-prop-script:fgcolor = ?
 f-operator:fgcolor = ?
 f-variable:fgcolor = ?
 f-parameter:fgcolor = ?
 f-complex:fgcolor = ?
 br-operator:VISIBLE IN FRAME Dialog-Frame = NO
 br-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = NO.
 cb-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = NO.
 br-dtruledict:VISIBLE IN FRAME Dialog-Frame =YES.
 br-variable:VISIBLE IN FRAME Dialog-Frame =NO.
 br-parameter:VISIBLE IN FRAME Dialog-Frame =NO.
 br-complex:VISIBLE IN FRAME Dialog-Frame =NO.
 glog = br-dtruledict:MOVE-TO-TOP().
end.
END PROCEDURE.
PROCEDURE proc-init-b-operator :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-operator:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 F-operator:fgcolor = 1   .
 b-prop-script:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-defvariable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-variable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-parameter:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-complex:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-prop-script:fgcolor = ?
 f-defvariable:fgcolor = ?
 f-variable:fgcolor = ?
 f-parameter:fgcolor = ?
 f-complex:fgcolor = ?
 br-operator:VISIBLE IN FRAME Dialog-Frame = YES
 br-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = NO.
 cb-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = NO.
 br-dtruledict:VISIBLE IN FRAME Dialog-Frame = NO.
 br-variable:VISIBLE IN FRAME Dialog-Frame = NO.
 br-parameter:VISIBLE IN FRAME Dialog-Frame = NO.
 br-complex:VISIBLE IN FRAME Dialog-Frame = NO.
 glog = browse br-operator:MOVE-TO-TOP().
end.
END PROCEDURE.
PROCEDURE proc-init-b-parameter :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-parameter:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 f-parameter:fgcolor = 1   .
 b-prop-script:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-operator:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-defvariable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-variable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-complex:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-prop-script:fgcolor = ?
 f-operator:fgcolor = ?
 f-defvariable:fgcolor = ?
 f-variable:fgcolor = ?
 f-complex:fgcolor = ?
 br-operator:VISIBLE IN FRAME Dialog-Frame = NO
 br-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = NO.
 cb-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = NO.
 br-dtruledict:VISIBLE IN FRAME Dialog-Frame = NO.
 br-variable:VISIBLE IN FRAME Dialog-Frame  = NO.
 br-parameter:VISIBLE IN FRAME Dialog-Frame  = YES.
 br-complex:VISIBLE IN FRAME Dialog-Frame  = no.
 glog = br-variable:MOVE-TO-TOP().
end.
END PROCEDURE.
PROCEDURE proc-init-b-prop-script :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-prop-script:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 F-prop-script:fgcolor = 1   .
 b-operator:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-defvariable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-variable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-parameter:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-complex:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-operator:fgcolor = ?
 f-defvariable:fgcolor = ?
 f-variable:fgcolor = ?
 f-parameter:fgcolor = ?
 f-complex:fgcolor = ?
 br-operator:VISIBLE IN FRAME Dialog-Frame = NO
 br-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = YES.
 cb-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = yes.
 br-dtruledict:VISIBLE IN FRAME Dialog-Frame = NO.
 br-variable:VISIBLE IN FRAME Dialog-Frame = NO.
 br-parameter:VISIBLE IN FRAME Dialog-Frame = NO.
 br-complex:VISIBLE IN FRAME Dialog-Frame = NO.
 glog = browse br-pscript-ruleset:MOVE-TO-TOP().
end.
END PROCEDURE.
PROCEDURE proc-init-b-variable :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DO on error undo, return error return-value:
 b-variable:LOAD-IMAGE-UP("adeicon\ts-up110":U)           in frame Dialog-Frame .
 f-variable:fgcolor = 1   .
 b-prop-script:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-operator:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-defvariable:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-parameter:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 b-complex:LOAD-IMAGE-Up("adeicon\ts-dn110":U)      in frame Dialog-Frame .
 ASSIGN
 f-prop-script:fgcolor = ?
 f-operator:fgcolor = ?
 f-defvariable:fgcolor = ?
 f-parameter:fgcolor = ?
 f-complex:fgcolor = ?
 br-operator:VISIBLE IN FRAME Dialog-Frame = NO
 br-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = NO.
 cb-pscript-ruleset:VISIBLE IN FRAME Dialog-Frame = NO.
 br-dtruledict:VISIBLE IN FRAME Dialog-Frame = NO.
 br-variable:VISIBLE IN FRAME Dialog-Frame  = yes.
 br-parameter:VISIBLE IN FRAME Dialog-Frame  = NO.
 br-complex:VISIBLE IN FRAME Dialog-Frame  = NO.
 glog = br-variable:MOVE-TO-TOP().
end.
END PROCEDURE.
PROCEDURE proc-mouse-menu-click :
DEFINE VARIABLE v-script-al AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-entry-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-proc-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-value-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-data-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-class-dtm-code AS integer NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-includes-operator as logical no-undo .
DEFINE BUFFER buf_tt-widget FOR tt-widget.
DEFINE BUFFER buf_tt-complex FOR tt-complex.
DEFINE BUFFER buf2_tt-complex FOR tt-complex.
 ASSIGN
 v-script-al = "("
 v-script-nl = "("
 .
  FOR EACH buf_tt-widget
  BY buf_tt-widget.right-bottom
  ON error undo, return no-apply
  :
     IF buf_tt-widget.HANDLE:SELECTED THEN DO:
        if not v-includes-operator
        and  buf_tt-widget.entry-type = 'operator':U then do:
          v-includes-operator = yes.
        end.
        ASSIGN
        v-script-al = v-script-al + chr(32) + buf_tt-widget.script-al
        v-script-nl = v-script-nl + chr(32) + buf_tt-widget.script-nl
        v-ii = v-ii + 1
        .
        IF v-ii = 1 THEN DO:
          ASSIGN
          v-entry-type = '-':U
          v-script-type = 'variable':U
          v-script-value-type = buf_tt-widget.script-value-type
          v-data-type = buf_tt-widget.DATA-TYPE
          v-dtm-code = buf_tt-widget.dtm-code
          v-class-dtm-code = buf_tt-widget.class-dtm-code
          .
        END.
        ELSE DO:
            ASSIGN
            v-entry-type = '-':U
            v-script-name  = '':U
            v-script-type = 'variable':U
            v-proc-type = '':U
            v-script-value-type = '-':U
            v-data-type = '-':U
            v-dtm-code = 0
            v-class-dtm-code = 0
            .
        END.
       DELETE WIDGET buf_tt-widget.HANDLE_.
       DELETE buf_tt-widget.
     END.
  END.
  ASSIGN
  v-script-al = v-script-al + " )"
  v-script-nl = v-script-nl + " )"
  .
  if not v-includes-operator then do:
    ASSIGN
    v-script-al = left-trim(v-script-al, "(")
    v-script-nl = left-trim(v-script-nl, "(")
    v-script-al = right-trim(v-script-al, ")")
    v-script-nl = right-trim(v-script-nl, ")")
    .
  end.
  RUN create-widget IN THIS-PROCEDURE ( INPUT v-dtm-code
                                   ,input v-class-dtm-code
                                  ,INPUT rs-language
                                  ,input v-script-al
                                  ,INPUT v-script-al
                                  ,INPUT v-script-nl
                                  ,INPUT v-entry-type
                                  ,INPUT v-script-type
                                  ,input v-script-value-type
                                  ,INPUT v-data-type
                                  ,input v-proc-type
                                  ,input '':U
                                  ).
  FIND last buf2_tt-complex NO-ERROR.
  CREATE buf_tt-complex.
  ASSIGN
  buf_tt-complex.script-al = v-script-al
  buf_tt-complex.script-nl = v-script-nl
  buf_tt-complex.key_ = ( IF AVAILABLE buf2_tt-complex
                           THEN buf2_tt-complex.KEY_ + 1
                           ELSE 1)
  buf_tt-complex.entry-type = v-entry-type
  buf_tt-complex.script-name = v-script-name
  buf_tt-complex.proc-type = v-proc-type
  buf_tt-complex.script-type = v-script-type
  buf_tt-complex.script-value-type = v-script-value-type
  buf_tt-complex.data-type = v-data-type
  buf_tt-complex.dtm-code = v-dtm-code
  buf_tt-complex.class-dtm-code = v-class-dtm-code
  .
OPEN QUERY br-complex FOR EACH tt-complex.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-script-al AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-nl AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-script-id AS integer NO-UNDO.
DEFINE VARIABLE v-rule-id AS INTEGER NO-UNDO.
DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
DEFINE BUFFER buf_tt-rule-i-script FOR tt-rule-i-script.
DEFINE BUFFER buf_tt-loc-rule-i-script FOR tt-loc-rule-i-script.
IF p-script-type = 'COND':U
or p-script-type = 'CYCLE-COND':U
THEN DO:
  RUN check-script-type-cond IN THIS-PROCEDURE ( OUTPUT v-script-al
                                           ,OUTPUT v-script-nl) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN ERROR.
END.
if p-script-type = 'CONS':U
or p-script-type = 'GOTO':U
then do:
    RUN check-script-type-cons IN THIS-PROCEDURE ( OUTPUT v-script-al
                                                 ,OUTPUT v-script-nl) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN RETURN ERROR.
end.
MESSAGE v-script-al SKIP v-script-nl VIEW-AS ALERT-BOX.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  for each buf_tt-loc-rule-i-script where
  on error undo, return error :
    find first buf_tt-rule-i-script where
              buf_tt-rule-i-script.root_rule_id = buf_tt-loc-rule-i-script.root_rule_id
         and  buf_tt-rule-i-script.script_id = buf_tt-loc-rule-i-script.script_id
         and  buf_tt-rule-i-script.i-script-name = buf_tt-loc-rule-i-script.i-script-name no-error.
    if not available buf_tt-rule-i-script then do:
      create buf_tt-rule-i-script.
    end.
    buffer-copy buf_tt-loc-rule-i-script to buf_tt-rule-i-script.
  end.
  for each buf_tt-rule-i-script where
          buf_tt-rule-i-script.root_rule_id = p-rule-id
      and buf_tt-rule-i-script.script_id = p-script-id
  on error undo, return error :
    find first buf_tt-loc-rule-i-script where
              buf_tt-loc-rule-i-script.root_rule_id = buf_tt-rule-i-script.root_rule_id
         and  buf_tt-loc-rule-i-script.script_id = buf_tt-rule-i-script.script_id
         and  buf_tt-loc-rule-i-script.i-script-name = buf_tt-rule-i-script.i-script-name no-error.
    if not available buf_tt-loc-rule-i-script then do:
       delete buf_tt-rule-i-script.
    end.
  end.
  assign
  tt-rule-script.script = v-script-al
  tt-l_rule-script.script = v-script-nl.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  ASSIGN
  v-script-id = NEXT-VALUE(s-rule-script-id, ub)
  tt-rule-script.script_id = v-script-id
  tt-rule-script.script = v-script-al
  tt-l_rule-script.script_id = v-script-id
  tt-l_rule-script.script = v-script-nl
 .
  RELEASE tt-rule-script.
  RELEASE tt-l_rule-script.
  for each buf_tt-loc-rule-i-script where
          buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id:
  end.
  for each buf_tt-loc-rule-i-script where
          buf_tt-loc-rule-i-script.root_rule_id = p-root-rule-id
      and buf_tt-loc-rule-i-script.script_id = 0
  on error undo, return error :
    create buf_tt-rule-i-script.
    buffer-copy buf_tt-loc-rule-i-script
    except script_id
    to buf_tt-rule-i-script
    assign
    buf_tt-rule-i-script.script_id = v-script-id
    .
  end.
  p-script-id = v-script-id.
end.
END PROCEDURE.
PROCEDURE proc-undo :
DEFINE BUFFER buf_tt-rule-script FOR tt-rule-script.
CASE p-mode:
  WHEN 'ДОБАВЛЕНИЕ':U THEN DO:
    FOR EACH buf_tt-rule-script WHERE
            buf_tt-rule-script.rule_id = p-rule-id
        and buf_tt-rule-script.script_id = 0:
      DELETE buf_tt-rule-script.
    END.
  END.
END CASE.
END PROCEDURE.
PROCEDURE proc-vc-language :
DEFINE INPUT PARAMETER  p-language AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_tt-widget FOR tt-widget.
ASSIGN
X_pscript-ruleset.script-name:VISIBLE IN BROWSE br-pscript-ruleset =  (p-language = "ABL")
Y_ruledict.script-al:VISIBLE IN BROWSE br-operator =  (p-language = "ABL")
tt-ruledict-param.param-name:VISIBLE IN BROWSE br-parameter =  (p-language = "ABL")
X_dtruledict.script-al:VISIBLE IN BROWSE br-dtruledict =  (p-language = "ABL")
tt-complex.script-al:VISIBLE IN BROWSE br-complex =  (p-language = "ABL")
.
FOR EACH buf_tt-widget NO-LOCK:
   ASSIGN
   buf_tt-widget.HANDLE_:SCREEN-VALUE = (IF p-language = "ABL"
                                         THEN buf_tt-widget.script-al
                                         ELSE buf_tt-widget.script-nl).
END.
END PROCEDURE.
FUNCTION get-current-column RETURNS DECIMAL
  ( input p-right-bottom AS DECIMAL ) :
DEFINE VARIABLE v-c-r AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-c-c AS DECIMAL NO-UNDO.
ASSIGN
v-c-r = TRUNCATE(p-right-bottom / 98, 0) + 1
v-c-c = p-right-bottom - (v-c-r - 1 ) * 98 + 1.
IF v-c-c > 98 THEN DO:
   v-c-r = v-c-r + 1.
   v-c-c = 1.
END.
RETURN v-c-c.
END FUNCTION.
FUNCTION get-current-row RETURNS DECIMAL
  ( input p-right-bottom AS DECIMAL ) :
DEFINE VARIABLE v-c-r AS DECIMAL NO-UNDO.
DEFINE VARIABLE v-c-c AS DECIMAL NO-UNDO.
ASSIGN
v-c-r = TRUNCATE(p-right-bottom / 98, 0) + 1
v-c-c = p-right-bottom - (v-c-r - 1) * 98 + 1.
IF v-c-c > 98 THEN DO:
   v-c-r = v-c-r + 1.
   v-c-c = 1.
END.
RETURN v-c-r.
END FUNCTION.
FUNCTION get-left-top RETURNS DECIMAL
  ( INPUT p-row AS decimal, INPUT p-width AS decimal, INPUT p-column AS decimal, INPUT p-height AS DECIMAL ) :
RETURN (( p-row - 1.0) * 98.0 + p-column).
END FUNCTION.
FUNCTION get-right-bottom RETURNS DECIMAL
  ( INPUT p-row AS decimal, INPUT p-width AS decimal, INPUT p-column AS decimal, INPUT p-height AS DECIMAL ) :
RETURN ( ( p-row - 1.0)  * 98.0 + p-width + p-column ).
END FUNCTION.
FUNCTION SUBSTITUTE-value-type RETURNS CHARACTER
  ( INPUT p-value-type AS CHARACTER, buffer buf_tt-widget for tt-widget) :
define buffer buf_ruledict for ub.ruledict.
define buffer buf_ruledict-param for ub.ruledict-param.
   if buf_tt-widget.entry-type = 'prop-script':U
   or buf_tt-widget.entry-type = 'parameter':U then do:
   end.
   else do:
      if buf_tt-widget.script-type = 'variable':U then do:
        p-value-type = buf_tt-widget.script-value-type.
      end.
      else do:
        if buf_tt-widget.entry-type = 'operator':U then do:
          find first buf_ruledict no-lock where
                    buf_ruledict.entry-type = 'operator':U
                and buf_ruledict.script-al = buf_tt-widget.script-al-fix no-error .
          if available buf_ruledict then do:
              find first buf_ruledict-param no-lock where
                        buf_ruledict-param.entry-id = buf_ruledict.entry-id
                    and buf_ruledict-param.param-num = 0 no-error .
              if available buf_ruledict-param then do:
                p-value-type = buf_ruledict-param.param-data-type.
              end.
              else do:
                return buf_tt-widget.script-al.
              end.
          end.
          else do:
            return buf_tt-widget.script-al.
          end.
        end.
      end.
   end.
CASE entry(1,p-value-type):
    WHEN 'character':U THEN RETURN '""':U.
    WHEN 'integer':U THEN RETURN '0':U.
    WHEN 'decimal':U THEN RETURN '0.0':U.
    WHEN 'date':U THEN RETURN '?':U.
    WHEN 'logical':U THEN RETURN 'no':U.
    WHEN 'void':U THEN RETURN '(no = no)':U.
END CASE.
RETURN buf_tt-widget.script-al.
END FUNCTION.
