 define variable vss-revision    as character no-undo init "$Revision$":U .
 define variable vss-author      as character no-undo init "$Author$":U .
 define variable vss-date        as character no-undo init "$Date$":U .
 define variable vss-workfile    as character no-undo init "$Workfile$":U .
 define variable vss-archive     as character no-undo init "$Archive$":U .
 define variable vss-description as character no-undo init "Экспорт текущих остатков, товарных накладных, внешних расходных накладных ".
  define variable v-param-type                as character    no-undo.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input PARAMETER p-mode           AS CHARACTER NO-UNDO.
define input parameter p-db-num-char    as character    no-undo.
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.
define input parameter p-action         as character    no-undo.
define output parameter p-cancel        as logical      no-undo.
define output parameter p-params        as character    no-undo.
  DEFINE BUFFER tt0-rp-by-call FOR rp-by-call.
DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE rule-by-call.
DEFINE TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE rule-call-param.
DEFINE BUFFER X_dis-card-type FOR dis-card-type.
DEFINE BUFFER X_rp-by-call FOR rp-by-call.
DEFINE BUFFER X_rule FOR rule.
DEFINE BUFFER X_rule-by-call FOR rule-by-call.
DEFINE BUFFER X_rule-by-profile FOR rule-by-profile.
DEFINE BUFFER X_rule-profile FOR rule-profile.
   DEFINE variable loghandle AS HANDLE no-undo.
   DEFINE VARIABLE logstring AS CHARACTER no-undo.
   define variable par1 as widget-handle  no-undo.
   define variable par2 as widget-handle  no-undo.
   define variable file-name as char no-undo.
   define variable v-paramdop as char no-undo.
   DEFINE VARIABLE v-param-list AS CHARACTER NO-UNDO.
   define variable st as char no-undo.
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
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-doctype-type-list as character extent 54 init
[
      "приход внешний"                      , 'ie':U          , "ie"
    , "расход внешний"                      , 'ee':U          , "ee"
    , "расход внешний возврат поставщику"   , 'ep':U       , "ep"
    , "расход внешний продажа через кассу"  , 'es':U     , "es"
    , "возврат внешний"                     , 're':U      , "re"
    , "возврат внешний через кассу"         , 'rs':U , "rs"
    , "списание внешнее"                    , 'we':U          , "we"
    , "инвентаризация"                      , 'vt':U                , "vt"
    , "приход перемещение"                  , 'iv':U          , "iv"
    , "расход перемещение"                  , 'ev':U          , "ev"
    , "возврат перемещение"                 , 'rv':U      , "rv"
    , "списание производство"               , 'wm':U           , "wm"
    , "приход производство"                 , 'im':U           , "im"
    , "документ переоценки"                 , 'ot':U           , "ot"
    , "коррекция учетных цен"               , 'ap':U     , "ap"
    , "корректировка отрицательных партий"  , 'mp':U   , "mp"
    , "смена типа приобретения"             , 'pc':U     , "pc"
    , "пересортица"                         , 'vp':U           , "vp"
] no-undo.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-schedule-free no-undo
field free-id as character
field free-task-name as character
field proc-run-name as character
field proc-param-edit-name as character
field conf-param as character
field is-gbd as logical
field is-ubd as logical
field enable-concurrent-0 as logical
field enable-concurrent-db as logical
field other-info as character
field enc-key as character
field is-rum as logical
index pi is unique primary
free-id.
procedure schedule-attr-name :
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
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-obj-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-oss-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-gds-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-doc-type-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-date-list':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-filter':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schedule-filter-2':U then do:     assign     p-label = "Параметры строки расписания"     p-type = 'C':U      p-format = "X(30)"     p-label = "Параметры строки расписания"     p-user-can-edit  = true     p-output-display = true     p-other = ""      .   end.
            when 'schd-free-id':U then do:     assign     p-label = "Идентификатор произвольной задачи"     p-type = 'C':U      p-format = "X(30)"     p-label = "Идентификатор произвольной задачи"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error "Неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure schedule-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-obj-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-oss-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-gds-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-doc-type-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-date-list':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-filter':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schedule-filter-2':U then do:     assign     p-tooltip = "Параметры строки расписания"     p-label = "Параметры строки расписания" .   end.
            when 'schd-free-id':U then do:     assign     p-tooltip = "Идентификатор произвольной задачи"     p-label = "Идентификатор произвольной задачи" .   end.
      otherwise do:
            undo, return error "Неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure schedule-attr-value :
do
on error undo, return error return-value
:
define input parameter  p-cre-db-num as integer    no-undo.
define input parameter  p-task-type  as character  no-undo.
define input parameter  p-task-num   as integer    no-undo.
define input parameter  p-code       as character  no-undo.
define output parameter p-value      as character  no-undo.
define output parameter p-type       as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_schedule-attr for ub.schedule-attr.
    run schedule-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    if p-code begins ('schd-free-id':U + chr(4))
    and entry(2, p-code, chr(4)) = '':U then do:
      find first buf_schedule-attr no-lock
          where buf_schedule-attr.cre-db-num = p-cre-db-num
            and buf_schedule-attr.task-type  = p-task-type
            and buf_schedule-attr.task-num   = p-task-num
            and buf_schedule-attr.attr-code  begins p-code
      no-error .
    end.
    else do:
      find first buf_schedule-attr no-lock
          where buf_schedule-attr.cre-db-num = p-cre-db-num
            and buf_schedule-attr.task-type  = p-task-type
            and buf_schedule-attr.task-num   = p-task-num
            and buf_schedule-attr.attr-code  = p-code
      no-error .
    end.
    if available buf_schedule-attr
    then do:
        assign
            p-value = buf_schedule-attr.attr-value
        .
    end.
    else do:
      if p-code begins ('schd-free-id':U + chr(4) ) then do:
         run schedule-attr-get-free-props in this-procedure (input entry(2, p-code, chr(4)), output p-value).
      end.
      else do:
        assign
            p-value = if p-type = 'L':U then "no":U else ""
        .
      end.
    end.
end.
end procedure.
procedure schedule-attr-write :
do
on error undo, return error
:
define input parameter p-cre-db-num  as integer   no-undo.
define input parameter p-task-type   as character no-undo.
define input parameter p-task-num    as integer   no-undo.
define input parameter p-code        as character no-undo.
define input parameter p-value       as character no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_schedule-attr for ub.schedule-attr .
    run schedule-attr-name in this-procedure (
          input  p-code
        , output v-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_schedule-attr exclusive-lock
         where buf_schedule-attr.cre-db-num = p-cre-db-num
           and buf_schedule-attr.task-type  = p-task-type
           and buf_schedule-attr.task-num   = p-task-num
           and buf_schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_schedule-attr
    then do:
        create buf_schedule-attr.
        assign
          buf_schedule-attr.cre-db-num = p-cre-db-num
          buf_schedule-attr.task-type  = p-task-type
          buf_schedule-attr.task-num   = p-task-num
          buf_schedule-attr.attr-code  = p-code
          buf_schedule-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_schedule-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure schedule-attr-delete :
do
on error undo, return error
:
define input  parameter p-cre-db-num  as integer   no-undo.
define input  parameter p-task-type   as character no-undo.
define input  parameter p-task-num    as integer   no-undo.
define input  parameter p-code        as character no-undo.
define output parameter p-deleted     as logical   no-undo.
    define buffer buf_schedule-attr for ub.schedule-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run schedule-attr-name in this-procedure (
          input p-code
        , output v-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_schedule-attr exclusive-lock
         where buf_schedule-attr.cre-db-num = p-cre-db-num
           and buf_schedule-attr.task-type  = p-task-type
           and buf_schedule-attr.task-num   = p-task-num
           and buf_schedule-attr.attr-code  = p-code
    no-error.
    if not available buf_schedule-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
        delete buf_schedule-attr.
        assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure schedule-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    if index(p-code, chr(4)) > 0 then do:
      p-code = entry(1, p-code, chr(4)).
    end.
    case p-code :
            when 'schedule-param-list':U then do:     assign     p-news = false.   end.
            when 'schedule-obj-list':U then do:     assign     p-news = false.   end.
            when 'schedule-oss-list':U then do:     assign     p-news = false.   end.
            when 'schedule-gds-list':U then do:     assign     p-news = false.   end.
            when 'schedule-doc-type-list':U then do:     assign     p-news = false.   end.
            when 'schedule-date-list':U then do:     assign     p-news = false.   end.
            when 'schedule-filter':U then do:     assign     p-news = false.   end.
            when 'schedule-filter-2':U then do:     assign     p-news = false.   end.
            when 'schd-free-id':U then do:     assign     p-news = false.   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки расписания" + " " + p-code .
      end.
    end.
end.
end procedure.
procedure schedule-attr-extract-logical :
do
on error undo, return error
:
define input  parameter p-parameter-number   as integer      no-undo.
define input  parameter p-parameter-list     as character    no-undo.
define output parameter p-parameter-value   as logical      no-undo.
    if num-entries( p-parameter-list ) > p-parameter-number - 1
    then do:
        assign
            p-parameter-value   = ( entry( p-parameter-number, p-parameter-list ) = "yes" )
        .
    end.
    else do:
        assign
            p-parameter-value   = no
        .
    end.
end.
end procedure.
procedure schedule-attr-get-free-id :
do
on error undo, return error return-value
:
  define input  parameter p-cre-db-num  as integer   no-undo.
  define input  parameter p-task-type   as character no-undo.
  define input  parameter p-task-num    as integer   no-undo.
  define output parameter p-free-id     as character no-undo.
  define buffer buf_schedule-attr for ub.schedule-attr.
  find first buf_schedule-attr no-lock
      where buf_schedule-attr.cre-db-num = p-cre-db-num
        and buf_schedule-attr.task-type  = p-task-type
        and buf_schedule-attr.task-num   = p-task-num
        and buf_schedule-attr.attr-code  begins  ('schd-free-id':U + chr(4))
  no-error .
  if available buf_schedule-attr then
  assign
  p-free-id = entry(2, buf_schedule-attr.attr-code, chr(4))
  no-error
  .
end.
end procedure.
procedure schedule-attr-get-free-props :
  define input parameter p-free-id as character no-undo .
  define output parameter p-value as character no-undo .
  define buffer buf_temp-schedule-free for temp-schedule-free.
  do
  on error undo, return error return-value
  :
    find first buf_temp-schedule-free no-lock no-error .
    if not available buf_temp-schedule-free then do:
      run schedule-attr-fill-free-props in this-procedure .
    end.
    find first buf_temp-schedule-free where
            buf_temp-schedule-free.free-id = p-free-id no-error.
    if available buf_temp-schedule-free then do:
      assign
      p-value = buf_temp-schedule-free.free-task-name       + chr(4) +
                buf_temp-schedule-free.proc-run-name        + chr(4) +
                buf_temp-schedule-free.proc-param-edit-name + chr(4) +
                buf_temp-schedule-free.conf-param           + chr(4) +
                string(buf_temp-schedule-free.is-gbd)       + chr(4) +
                string(buf_temp-schedule-free.is-ubd)       + chr(4) +
                string(buf_temp-schedule-free.enable-concurrent-0) + chr(4) +
                string(buf_temp-schedule-free.enable-concurrent-db) + chr(4) +
                buf_temp-schedule-free.other-info
      .
    end.
    else do:
     if p-free-id <> '':U then return error substitute("&1 &2 &3&4Неопределены процедуры для работы с произвольной задачей по расписанию&4" +
                           "id произвольной задачи - &5"
                           ,vss-workfile
                           ,vss-revision
                           ,vss-description
                           ,chr(10)
                           ,p-free-id).
    end.
  end.
end procedure.
procedure schedule-attr-is-rum-free-id :
define input parameter p-free-id as character no-undo .
define output parameter p-is-rum as logical no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free.
do
on error undo, return error
:
    find first buf_temp-schedule-free no-lock no-error .
    if not available buf_temp-schedule-free then do:
      run schedule-attr-fill-free-props in this-procedure .
    end.
    find first buf_temp-schedule-free where
            buf_temp-schedule-free.free-id = p-free-id no-error.
    if available buf_temp-schedule-free
    and buf_temp-schedule-free.is-rum
    then do:
      p-is-rum = yes.
    end.
end.
end procedure.
procedure schedule-attr-fill-free-props :
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define buffer buf_temp-schedule-free for temp-schedule-free.
define variable v-answer as logical no-undo .
  do
  on error undo, return error substitute("&1 &2 &3&4&5&4"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,chr(10)
                                        ,error-status:get-message(1) )
  :
    run gbl/filename.p (
                    input 'cmp/shd-free.d'
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) .
    input from value(v-full-path).
    repeat :
      create buf_temp-schedule-free.
      import buf_temp-schedule-free.
    END.
    input close.
    _ff:
    for each buf_temp-schedule-free :
      if buf_temp-schedule-free.free-id = '':U then do:
         delete buf_temp-schedule-free.
         next _ff.
       end.
       run schedule-attr-check-enc in this-procedure (
                                                    input  buf_temp-schedule-free.free-id
                                                   ,input  (buf_temp-schedule-free.proc-run-name +
                                                            buf_temp-schedule-free.proc-param-edit-name +
                                                            buf_temp-schedule-free.conf-param +
                                                            string(buf_temp-schedule-free.is-gbd) +
                                                            string(buf_temp-schedule-free.is-ubd) +
                                                            string(buf_temp-schedule-free.enable-concurrent-0) +
                                                            string(buf_temp-schedule-free.enable-concurrent-db) +
                                                            string(buf_temp-schedule-free.other-info)
                                                            )
                                                    ,input  buf_temp-schedule-free.enc-key
                                                    ,output v-answer    ) no-error .
       if error-status:error
       or not v-answer then delete buf_temp-schedule-free.
     end.
  end.
end procedure.
Function schedule-attr-reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.
procedure schedule-attr-check-enc.
  define input  parameter p-free-id   as character no-undo .
  define input  parameter p-value     as character no-undo .
  define input  parameter p-enc-value as character no-undo .
  define output parameter p-answer    as logical   no-undo .
  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .
  assign
  tmp = schedule-attr-reverse (trim (p-free-id)) + schedule-attr-reverse (trim (p-value)) .
  .
  run schedule-attr-pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.
end.
procedure schedule-attr-conf-enc.
  define input  parameter p-free-id   as character no-undo .
  define input  parameter p-value     as character no-undo .
  define output parameter p-enc-value as character no-undo .
  define variable tmp         as character no-undo .
  assign
    tmp = schedule-attr-reverse (trim (p-free-id)) + schedule-attr-reverse (trim (p-value))
  .
  run schedule-attr-pswd-enc in this-procedure
    ( input tmp
     ,output p-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure schedule-attr-pswd-enc :
  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
  DEFINE STREAM v-s1.
  define buffer buf_schedule for ub.schedule.
  define buffer buf_schedule-attr for ub.schedule-attr.
  define buffer buf_trn-doc for ub.trn-doc.
  define buffer buf_c-trn-doc for ub.c-trn-doc.
  define buffer buf_gds-dtl for gds-dtl.
  define buffer buf_gds-prt for gds-prt.
  DEFINE TEMP-TABLE imptable
     FIELD obj-type LIKE trn-doc.obj-type
     FIELD obj-code LIKE trn-doc.obj-code
     FIELD st AS CHARACTER FORMAT "x(76)".
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.
DEFINE BUTTON B-file-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.
DEFINE BUTTON B-file-3
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.
DEFINE BUTTON B-file-4
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.
DEFINE BUTTON B-file-5
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.
DEFINE BUTTON B-file-6
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.
DEFINE BUTTON B-file-9
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE fnkassir AS CHARACTER FORMAT "X(256)":U
     LABEL "Выгрузка кассиров"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.
DEFINE VARIABLE e-mail AS CHARACTER FORMAT "X(256)":U
     LABEL "e-mail"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.
DEFINE VARIABLE fnperesort AS CHARACTER FORMAT "X(256)":U
     LABEL "Выгрузка док. пересортицы"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.
DEFINE VARIABLE fnprih AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл приход внешний"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.
DEFINE VARIABLE fnrasvn AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл расход внутренний"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.
DEFINE VARIABLE fnrasvne AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл расход внешний"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.
DEFINE VARIABLE fnsoot AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл соответствий"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.
DEFINE VARIABLE fnudal AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл удал. накл. рас. вн."
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.
DEFINE VARIABLE peresort AS LOGICAL INITIAL no
     LABEL "Выгрузка док. пересортицы"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.
DEFINE VARIABLE prihod AS LOGICAL INITIAL no
     LABEL "Выгрузка для прихода внешнего"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.
DEFINE VARIABLE rasvn AS LOGICAL INITIAL no
     LABEL "Выгрузка для расхода внутреннего"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.
DEFINE VARIABLE rasvne AS LOGICAL INITIAL no
     LABEL "Выгрузка для расхода внешнего"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.
DEFINE VARIABLE staff AS LOGICAL INITIAL no
     LABEL "Выгрузка кассиров"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.
DEFINE VARIABLE udal AS LOGICAL INITIAL no
     LABEL "Выгрузка для удаленных накладных"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     staff AT ROW 1.75 COL 30 WIDGET-ID 50
     fnkassir   AT ROW 3        COL 64.5    RIGHT-ALIGNED WIDGET-ID 72
     B-file-6 AT ROW 3 COL 63 WIDGET-ID 58
     peresort AT ROW 4.5 COL 30 WIDGET-ID 52
     fnperesort AT ROW 5.75     COL 64.5    RIGHT-ALIGNED WIDGET-ID 70
     B-file-9 AT ROW 5.75 COL 63 WIDGET-ID 66
     rasvn AT ROW 7.5 COL 30 WIDGET-ID 74
     fnrasvn    AT ROW 8.75     COL 64.5    RIGHT-ALIGNED WIDGET-ID 40
     B-file AT ROW 8.75 COL 63 WIDGET-ID 20
     udal AT ROW 10.5 COL 30 WIDGET-ID 76
     fnudal     AT ROW 11.75    COL 64.5    RIGHT-ALIGNED WIDGET-ID 34
     B-file-2 AT ROW 11.75 COL 63 WIDGET-ID 32
     prihod AT ROW 13.5 COL 30 WIDGET-ID 78
     fnprih     AT ROW 14.75    COL 64.5    RIGHT-ALIGNED WIDGET-ID 38
     B-file-3 AT ROW 14.75 COL 63 WIDGET-ID 36
     rasvne     AT ROW 16.5     COL 30      WIDGET-ID 86
     fnrasvne   AT ROW 17.75    COL 64.5    RIGHT-ALIGNED WIDGET-ID 84
     B-file-5   AT ROW 17.75    COL 63      WIDGET-ID 82
     fnsoot     AT ROW 20.75    COL 64.5    RIGHT-ALIGNED WIDGET-ID 46
     B-file-4   AT ROW 20.75    COL 63      WIDGET-ID 48
     e-mail     AT ROW 22.5     COL 64.5    RIGHT-ALIGNED WIDGET-ID 80
     Btn_OK     AT ROW 24.5     COL 10
     Btn_Cancel AT ROW 24.5     COL 48
     SPACE(3.92) SKIP(1.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт текущих товарных остатков"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:
    DEF VAR ll_commit1 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file1 as char no-undo.
    SYSTEM-DIALOG GET-FILE v_os-file1
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        save-as
        use-filename
        update ll_commit1
        default-extension "txt"
        .
    IF ll_commit1 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file1 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnrasvn = ( IF SEARCH( v_os-file1 ) = ? THEN   v_os-file1  ELSE SEARCH( v_os-file1 ) ).
    DISP fnrasvn WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF B-file-2 IN FRAME Dialog-Frame
DO:
    DEF VAR ll_commit2 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file2 as char no-undo.
    SYSTEM-DIALOG GET-FILE v_os-file2
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        save-as
        use-filename
        update ll_commit2
        default-extension "txt"
        .
    IF ll_commit2 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file2 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnudal = ( IF SEARCH( v_os-file2 ) = ? THEN  v_os-file2 ELSE SEARCH( v_os-file2 ) ).
       DISP fnudal WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF B-file-3 IN FRAME Dialog-Frame
DO:
    DEF VAR ll_commit3 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file3 as char no-undo.
    SYSTEM-DIALOG GET-FILE v_os-file3
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        save-as
        use-filename
        update ll_commit3
        default-extension "txt"
        .
    IF ll_commit3 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file3 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnprih = ( IF SEARCH( v_os-file3 ) = ? THEN  v_os-file3  ELSE SEARCH( v_os-file3 ) ).
      DISP fnprih WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF B-file-4 IN FRAME Dialog-Frame
DO:
    DEF VAR ll_commit4 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file4 as char no-undo.
    SYSTEM-DIALOG GET-FILE v_os-file4
        TITLE "Выберите файл соответствий"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        ask-overwrite
        use-filename
        update ll_commit4
        default-extension "txt"
        .
    IF ll_commit4 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file4 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnsoot = ( IF SEARCH( v_os-file4 ) = ? THEN  v_os-file4  ELSE SEARCH( v_os-file4 ) ).
      DISP fnsoot WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF B-file-5 IN FRAME Dialog-Frame
DO:
    DEF VAR ll_commit5 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file5 as char no-undo.
    SYSTEM-DIALOG GET-FILE v_os-file5
        TITLE "Выберите файл соответствий"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        ask-overwrite
        use-filename
        update ll_commit5
        default-extension "txt"
        .
    IF ll_commit5 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file5 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnrasvne = ( IF SEARCH( v_os-file5 ) = ? THEN  v_os-file5  ELSE SEARCH( v_os-file5 ) ).
      DISP fnrasvne WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF B-file-6 IN FRAME Dialog-Frame
DO:
    DEF VAR ll_commit6 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file6 as char no-undo.
    SYSTEM-DIALOG GET-FILE v_os-file6
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        save-as
        use-filename
        update ll_commit6
        default-extension "txt"
        .
    IF ll_commit6 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file6 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnkassir = ( IF SEARCH( v_os-file6 ) = ? THEN   v_os-file6  ELSE SEARCH( v_os-file6 ) ).
    DISP fnkassir WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF B-file-9 IN FRAME Dialog-Frame
DO:
    DEF VAR ll_commit9 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file9 as char no-undo.
    SYSTEM-DIALOG GET-FILE v_os-file9
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        save-as
        use-filename
        update ll_commit9
        default-extension "txt"
        .
    IF ll_commit9 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file9 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnperesort = ( IF SEARCH( v_os-file9 ) = ? THEN   v_os-file9  ELSE SEARCH( v_os-file9 ) ).
    DISP fnperesort WITH FRAME Dialog-Frame.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    define variable v-obj-list as character no-undo .
   ASSIGN
    staff
    peresort
    prihod
    rasvn
    rasvne
    udal
    fnsoot
    fnkassir
    fnperesort
    fnprih
    fnrasvn
    fnrasvne
    fnudal
    e-mail.
    if (staff = true and fnkassir = "") or (peresort = true and fnperesort = "")
    or (prihod = true and fnprih = "") or (rasvn = true and fnrasvn = "")  or (udal = true and fnudal = "")
    then
    do:
    message "Необходимо ввести путь для выгрузок по флагам".
    return no-apply.
    end.
    if (staff    = false and trim(fnkassir)   <> "")  then assign fnkassir   = "".
    if (peresort = false and trim(fnperesort) <> "")  then assign fnperesort = "".
    if (prihod   = false and trim(fnprih)     <> "")  then assign fnprih     = "".
    if (rasvn    = false and trim(fnrasvn)    <> "")  then assign fnrasvn    = "".
    if (udal     = false and trim(fnudal)     <> "")  then assign fnudal     = "".
    if (rasvne   = false and trim(fnrasvne)   <> "")  then assign fnrasvne   = "".
   IF trim(fnsoot) = "" THEN
    DO:
        MESSAGE "Необходимо ввести путь для файла соответствий".
        return no-apply.
    END.
        ELSE
        DO:
    MESSAGE "Сохранить настройки?"
       VIEW-AS ALERT-BOX QUESTION
    BUTTONS yes-no UPDATE continue-ok AS LOGICAL.
    IF continue-ok THEN DO:
       v-param-list = (fnrasvn + "!" + fnudal + "!" + fnprih + "!" + fnsoot + "!" + fnkassir + "!" + fnperesort + "!" + e-mail + "!" + fnrasvne ).
     run attach-attr-to-schedule-line in this-procedure (
                                                         INPUT v-param-list
    ) .
    Message "Настройки сохранены" VIEW-AS ALERT-BOX QUESTION.
    END.
    else
    return no-apply.
    END.
END.
ON LEAVE OF fnkassir IN FRAME Dialog-Frame
DO:
    ASSIGN fnkassir.
    IF SEARCH( fnkassir ) <> ? AND SEARCH( fnkassir ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnkassir = FILE-INFO:FULL-PATHNAME.
        DISP fnkassir WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO fnkassir IN FRAME Dialog-Frame.
END.
ON LEAVE OF fnperesort IN FRAME Dialog-Frame
DO:
    ASSIGN fnperesort.
    IF SEARCH( fnperesort ) <> ? AND SEARCH( fnperesort ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = fnperesort.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnperesort = FILE-INFO:FULL-PATHNAME.
        DISP fnperesort WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO fnperesort IN FRAME Dialog-Frame.
END.
ON LEAVE OF fnprih IN FRAME Dialog-Frame
DO:
    ASSIGN fnprih.
    IF SEARCH( fnprih ) <> ? AND SEARCH( fnprih ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME =fnprih.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnprih = FILE-INFO:FULL-PATHNAME.
        DISP fnprih WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO fnprih IN FRAME Dialog-Frame.
END.
ON LEAVE OF fnrasvn IN FRAME Dialog-Frame
DO:
    ASSIGN fnrasvn.
    IF SEARCH( fnrasvn ) <> ? AND SEARCH( fnrasvn ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = fnrasvn.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnrasvn = FILE-INFO:FULL-PATHNAME.
        DISP fnrasvn WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO fnrasvn IN FRAME Dialog-Frame.
END.
ON LEAVE OF fnrasvne IN FRAME Dialog-Frame
DO:
    ASSIGN fnrasvne.
    IF SEARCH( fnrasvne ) <> ? AND SEARCH( fnrasvne ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = fnrasvne.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnrasvne = FILE-INFO:FULL-PATHNAME.
        DISP fnrasvne WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO fnrasvne IN FRAME Dialog-Frame.
END.
ON LEAVE OF fnudal IN FRAME Dialog-Frame
DO:
    ASSIGN fnudal.
    IF SEARCH( fnudal ) <> ? AND SEARCH( fnudal ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = fnudal.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnudal = FILE-INFO:FULL-PATHNAME.
        DISP fnudal WITH FRAME Dialog-Frame.
    END.
    APPLY "TAB":U TO fnudal IN FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF peresort IN FRAME Dialog-Frame
DO:
   assign peresort.
   disable fnperesort b-file-9 WITH FRAME Dialog-Frame.
   enable fnperesort   when peresort = true
          b-file-9     when peresort = true
   WITH FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF prihod IN FRAME Dialog-Frame
DO:
    assign prihod.
    disable fnprih b-file-3 WITH FRAME Dialog-Frame.
    enable fnprih   when prihod = true
           b-file-3 when prihod = true
    WITH FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF rasvn IN FRAME Dialog-Frame
DO:
    assign rasvn.
    disable fnrasvn b-file WITH FRAME Dialog-Frame.
    enable fnrasvn   when rasvn = true
          b-file when rasvn = true
    WITH FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF rasvne IN FRAME Dialog-Frame
DO:
    assign rasvne.
    disable fnrasvne B-file-5 WITH FRAME Dialog-Frame.
    enable fnrasvne when rasvne = true
           B-file-5 when rasvne = true
    WITH FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF staff IN FRAME Dialog-Frame
DO:
   assign staff.
   disable fnkassir b-file-6 WITH FRAME Dialog-Frame.
   enable fnkassir   when staff = true
          b-file-6 when staff = true
   WITH FRAME Dialog-Frame.
  END.
ON VALUE-CHANGED OF udal IN FRAME Dialog-Frame
DO:
   assign udal.
   disable fnudal b-file-2 WITH FRAME Dialog-Frame.
   enable fnudal   when udal = true
          b-file-2 when udal = true
   WITH FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  run getschedule.
  run my-enable .
   WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
procedure getschedule:
    run schedule-attr-value in this-procedure (
          input integer(p-db-num-char)
        , input p-task-type
        , input p-task-num
        , input 'schedule-param-list':U
        , output v-param-list
        , output v-param-type
    ) no-error.
       if v-param-list <> "" then
        do:
     assign fnrasvn    = entry ( 1 , v-param-list , "!" )
            fnudal     = entry ( 2 , v-param-list , "!" )
            fnprih     = entry ( 3 , v-param-list , "!" )
            fnsoot     = entry ( 4 , v-param-list , "!" )
            fnkassir   = entry ( 5 , v-param-list , "!" )
            fnperesort = entry ( 6 , v-param-list , "!" )
            e-mail     = entry ( 7 , v-param-list , "!" )
            fnrasvne   = entry ( 8 , v-param-list , "!" ).
        end.
            if fnrasvn    <> "" then  rasvn = true.
            if fnudal     <> "" then  udal = true.
            if fnprih     <> "" then  prihod = true.
            if fnkassir   <> "" then  staff = true.
            if fnperesort <> "" then  peresort = true.
            if fnrasvne   <> "" then  rasvne = true.
        disp rasvn udal prihod staff peresort rasvne fnrasvne fnrasvn fnudal fnprih fnsoot fnkassir fnperesort e-mail WITH FRAME Dialog-Frame.
end.
PROCEDURE attach-attr-to-schedule-line :
DEFINE INPUT PARAMETER p-param-list AS CHARACTER NO-UNDO.
define buffer buf_schedule      for schedule.
define buffer buf_schedule-attr for schedule-attr.
define buffer lock-batchprocess for ub.batchprocess.
       run gbl/lock-prc.p
          (input 'schd':U
          ,input 'exp-sale':U
          ,input 0
          ,input 0
          ,input '':U
          ,input ""
          ,input ""
          ,input (
                  "выгрузки для kan3"
                )
          ,input yes
          ,buffer lock-batchprocess
          ) no-error .
      FIND FIRST buf_schedule-attr NO-LOCK WHERE
                 buf_schedule-attr.task-type   = p-task-type
             and buf_schedule-attr.cre-db-num = INTEGER(p-db-num-char)
             and buf_schedule-attr.attr-code = ('schd-free-id':U + chr(4) + 'kan3') NO-ERROR.
      IF AVAILABLE  buf_schedule-attr
          AND buf_schedule-attr.task-num <> p-task-num
          AND buf_schedule-attr.task-num <> - 1
          and p-task-num <> - 1
          THEN DO:
        MESSAGE
        substitute("Уже есть расписание выгрузки для kan3 для БД &1&2" +
                   "номер расписания &3"
                   ,buf_schedule-attr.cre-db-num
                   ,chr(10)
                   ,buf_schedule-attr.task-num)
        VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
      END.
      find first buf_schedule no-lock
           where buf_schedule.task-type   = p-task-type
             and buf_schedule.cre-db-num  = INTEGER(p-db-num-char)
             and buf_schedule.task-num    = p-task-num
      no-error.
      if not available buf_schedule
      and (  p-task-type   <> 'autofree':U
          or p-db-num-char <> p-db-num-char
          or p-task-num    <> -1 )
      then do:
          message
            vss-workfile vss-revision vss-description
            skip "Не найдена строка расписания."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
          view-as alert-box error.
          undo, return error .
      end.
    run schedule-attr-write in this-procedure (
          input INTEGER(p-db-num-char)
        , input p-task-type
        , input p-task-num
        , input 'schedule-param-list':U
        , input p-param-list
    ).
 END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY staff fnkassir peresort fnperesort rasvn fnrasvn udal fnudal prihod
          fnprih fnsoot fnrasvne rasvne
      WITH FRAME Dialog-Frame.
  ENABLE staff peresort rasvn udal prihod fnsoot B-file-4 Btn_OK Btn_Cancel e-mail fnrasvne fnrasvn rasvne
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE my-enable :
  disable fnkassir
         B-file-6
         fnperesort
         B-file-9
         fnrasvn
         B-file
         fnudal
         B-file-2
         fnprih
         B-file-3
         fnrasvne
         B-file-5
     WITH FRAME Dialog-Frame.
  ENABLE fnkassir when staff = true
         B-file-6 when staff = true
         fnperesort when peresort = true
         B-file-9 when peresort = true
         fnrasvn when rasvn = true
         B-file when rasvn = true
         fnudal when udal = true
         B-file-2 when udal = true
         fnprih when prihod = true
         B-file-3 when prihod =true
         fnrasvne when rasvne = true
         B-file-5 when rasvne = true
        WITH FRAME Dialog-Frame.
end procedure.
PROCEDURE proc-save :
END PROCEDURE.
