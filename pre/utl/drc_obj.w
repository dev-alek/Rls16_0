DEFINE TEMP-TABLE temp-clients NO-UNDO LIKE ub.clients.
DEFINE TEMP-TABLE temp-dis-rule NO-UNDO LIKE ub.dis-rule
       field old-des as character.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter p-list-mode as character no-undo .
define input parameter p-rule-num as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура копирования скидок типа 22 в тип 8".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-rule.des               no-undo .
    define output parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
    define output parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
    define output parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
    define output parameter  p-level-1           as character no-undo .
    define output parameter  p-level-2           as character no-undo .
    define output parameter  p-global             as integer no-undo .
    define output parameter  p-host               as integer no-undo .
    define output parameter  p-object             as integer no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-other as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-templ-rl-root no-error.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный шаблон скидки &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-rule.des
    p-discnt-type = buf_dis-rule.discnt-type
    p-subject-type = buf_dis-rule.subject-type
    p-value-type = buf_dis-rule.value-type
    p-global = (if available buf_dis-cfg-rule
                then buf_dis-cfg-rule.has-global
                else 0)
    p-host = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-host
              else 0)
    p-object = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-obj
              else 0)
    p-output-display = (buf_dis-rule.sts = integer('0':U))
    p-tree = buf_Dis-rule.uniq-field
    p-other = buf_dis-rule.other-inf
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    .
  end.
end procedure.
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.
end procedure.
~
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
~
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discfgru-check :
define input parameter p-table-name as character no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
define output parameter p-disnct-role as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error return-value
  :
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.table-name = p-table-name
        and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and (p-time-templ-rl-root = ? or  buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = p-pos-type no-error.
    if not available buf_dis-cfg-rule
    or p-pos-type = "":U
    then do:
       return error substitute("Для места использования типа &1 не определен тип скидки с шаблоном &2 &3"
                               ,entry (lookup (p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                               , p-templ-rl-root
                               , (if p-time-templ-rl-root = ?
                                  then '':U
                                  else substitute("с расписанием типа &1", p-time-templ-rl-root)
                                  )
                               ).
    end.
    assign
    p-disnct-role = buf_dis-cfg-rule.discnt-role
    .
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure disgdsru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule
  then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disgdsru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disgdsru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disgdsru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u).
end function.
procedure disgdsru-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type       like ub.dis-gds-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-gds-rule.obj-code   no-undo .
    define input parameter p-gds-code       like ub.dis-gds-rule.gds-code   no-undo .
    define input parameter p-pos-type       like ub.dis-gds-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-gds-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-gds-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-gds-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-gds-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-gds-rule.nonunique   no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer lock_dis-gds-rule for ub.dis-gds-rule .
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-gds-rule':U
                                         ,input p-templ-rl-root
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не может быть по шаблону &7 и расписанию &8"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type8 as character no-undo .
define variable v-value-date8 as date no-undo .
define variable v-value-decimal8 as decimal no-undo .
define variable v-value-integer8 as INTEGER no-undo .
define variable v-value-logical8 AS LOGICAL no-undo .
define variable v-tth8 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date8
    ,output v-value-decimal8
    ,output v-value-integer8
    ,output v-value-logical8
    ,output v-param-type8
    ,INPUT-OUTPUT table-handle v-tth8
    )  .
delete object v-tth8 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не найдено правило скидки &7"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6правило скидки &7 - некорневое"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    and not ( (p-obj-type = 'маг':U or p-obj-type = 'скл':U )
             and
             (buf_dis-rule.obj-type = 'орг':U or buf_dis-rule.obj-type = ""))
     then do:
      undo, return error (substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ) +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к товару для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-objregion( buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-objregion( p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-gds-rule exclusive-lock where
               buf_dis-gds-rule.gds-code  = p-gds-code
           AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
           AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
           AND buf_dis-gds-rule.pos-type  = p-pos-type
           AND buf_dis-gds-rule.discnt-role = p-discnt-role
           and buf_dis-gds-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-gds-rule then do:
      find first buf_dis-gds-rule exclusive-lock where
                buf_dis-gds-rule.gds-code  = p-gds-code
            AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
            AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
            AND buf_dis-gds-rule.pos-type  = p-pos-type
            AND buf_dis-gds-rule.discnt-role = p-discnt-role
            no-error .
      if available buf_Dis-gds-rule then do:
        if p-nonunique = ''
        and available buf_dis-gds-rule
        then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует (детализ. &3)"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                   , p-nonunique
                                  ).
        end.
        if available buf_dis-gds-rule
        and buf_dis-gds-rule.nonunique = ''
        and p-nonunique <> ''then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                  ).
        end.
      end.
      create buf_dis-gds-rule .
      assign
      buf_dis-gds-rule.gds-code  = p-gds-code
      buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
      buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
      buf_dis-gds-rule.pos-type = p-pos-type
      buf_dis-gds-rule.discnt-role = v-discnt-role
      buf_dis-gds-rule.rule-num = p-rule-num
      buf_dis-gds-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-gds-rule.rule-num = p-rule-num
    buf_dis-gds-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-gds-rule.templ-rl-root = p-templ-rl-root
    buf_dis-gds-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
PROCEDURE cmp-disgdsru-write :
do
on error undo, return error
:
  define input parameter p-gds-code like ub.dis-gds-rule.gds-code   no-undo .
  define input parameter p-obj-type like ub.dis-gds-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-gds-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-gds-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-gds-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-gds-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-gds-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-gds-rule.nonunique no-undo .
  define variable v-rule-label          as character no-undo .
  define buffer buf_tt0-dis-gds-rule for ub.dis-gds-rule .
  define buffer buf_dis-rule     for ub.dis-rule.
  run disgdsru-name in this-procedure (
                                      input  p-templ-rl-root
                                      ,output v-rule-label
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_tt0-dis-gds-rule exclusive-lock where
              buf_tt0-dis-gds-rule.gds-code  = p-gds-code
          AND buf_tt0-dis-gds-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-gds-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-gds-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-gds-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-gds-rule then do:
    create buf_tt0-dis-gds-rule .
    assign
    buf_tt0-dis-gds-rule.gds-code  = p-gds-code
    buf_tt0-dis-gds-rule.obj-type  = p-obj-type
    buf_tt0-dis-gds-rule.obj-code  = p-obj-code
    buf_tt0-dis-gds-rule.pos-type  = p-pos-type
    buf_tt0-dis-gds-rule.nonunique = p-nonunique
    buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rule-num = p-rule-num
  buf_tt0-dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-gds-rule.nonunique = p-nonunique
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rl-root = buf_Dis-rule.rl-root
  no-error.
  release buf_tt0-dis-gds-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
end.
END PROCEDURE.
DEFINE VARIABLE v-templ-rl-root AS INTEGER NO-UNDO.
define temp-table tt-dis-rule no-undo like ub.dis-rule.
define temp-table tt0-term_dis-rule no-undo like ub.dis-rule.
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-term-value-type   like ub.dis-rule.value-type        no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-global         as integer no-undo .
define variable  v-host           as integer no-undo .
define variable  v-object         as integer no-undo .
define variable  v-tree              as character no-undo .
define variable  v-other          as character no-undo .
define variable level as integer no-undo .
define variable v-start-level as integer   no-undo .
DEFINE VARIABLE lookup-option AS CHARACTER NO-UNDO.
define buffer loc_dis-rule for ub.dis-rule.
define buffer loc_clients for ub.clients.
DEFINE BUTTON B-dis-rule-add
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-dis-rule-del
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.
DEFINE BUTTON B-objects-add
     LABEL "Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON B-objects-delete
     LABEL "Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-run
     LABEL "&КОПИРОВАТЬ"
     SIZE 30 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE cb-pos-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Место примен."
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 20.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-old-des AS CHARACTER FORMAT "X(256)":U
     LABEL "Ориг.опис-е"
     VIEW-AS FILL-IN NATIVE
     SIZE 85 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE T-dis-gds-rule AS LOGICAL INITIAL no
     LABEL "Копировать привязку скидки на товар"
     VIEW-AS TOGGLE-BOX
     SIZE 40 BY 1 NO-UNDO.
DEFINE QUERY BR-dis-rule FOR
      temp-dis-rule SCROLLING.
DEFINE QUERY BR-objects FOR
      temp-clients SCROLLING.
DEFINE BROWSE BR-dis-rule
  QUERY BR-dis-rule NO-LOCK DISPLAY
      temp-dis-rule.des FORMAT "X(255)":U WIDTH 60
      temp-dis-rule.rule-num FORMAT ">>>>>>>>9":U
      temp-dis-rule.templ-rl-root FORMAT ">,>>>,>>9":U
      temp-dis-rule.obj-type FORMAT "X(3)":U
      temp-dis-rule.obj-code FORMAT ">>>>>>>>9":U
  ENABLE
      temp-dis-rule.des
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 7.77
         TITLE "Правила скидок, с которых копируем (ОПИСАНИЯ МОЖНО ПОМЕНЯТЬ!!!)" FIT-LAST-COLUMN.
DEFINE BROWSE BR-objects
  QUERY BR-objects NO-LOCK DISPLAY
      temp-clients.obj-type FORMAT "X(3)":U
      temp-clients.obj-code COLUMN-LABEL "Код" FORMAT ">>>>>>>>9":U
      temp-clients.obj-name COLUMN-LABEL "Название" FORMAT "X(40)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 9
         TITLE "Объекты, на которые копируем" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     T-dis-gds-rule AT ROW 1 COL 24 WIDGET-ID 6
     B-Help AT ROW 1 COL 95
     cb-pos-type AT ROW 2.07 COL 76 COLON-ALIGNED WIDGET-ID 18
     B-dis-rule-add AT ROW 3 COL 1 WIDGET-ID 2
     B-dis-rule-del AT ROW 3 COL 11 WIDGET-ID 8
     b-lkp AT ROW 3 COL 21 WIDGET-ID 22
     B-run AT ROW 3 COL 31 WIDGET-ID 14
     BR-dis-rule AT ROW 4 COL 1 WIDGET-ID 100
     f-old-des AT ROW 12 COL 1 WIDGET-ID 20
     B-objects-add AT ROW 13 COL 1 WIDGET-ID 4
     B-objects-delete AT ROW 13 COL 11 WIDGET-ID 10
     BR-objects AT ROW 14 COL 1 WIDGET-ID 200
     SPACE(0.69) SKIP(0.22)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Копирование скидок".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-dis-rule-add IN FRAME Dialog-Frame
DO:
  RUN proc-b-dis-rule-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-dis-rule-del IN FRAME Dialog-Frame
DO:
  RUN proc-b-dis-rule-del IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  IF NOT AVAILABLE temp-dis-rule THEN DO:
    BELL.
    RETURN NO-APPLY.
  END.
  run ref/show-dr.p ( input parparentproc
                    ,INPUT temp-dis-rule.rule-num) NO-ERROR.
END.
ON CHOOSE OF B-objects-add IN FRAME Dialog-Frame
DO:
    RUN proc-b-objects-add IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-objects-delete IN FRAME Dialog-Frame
DO:
    RUN proc-b-objects-delete IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-run IN FRAME Dialog-Frame
DO:
    ASSIGN
    t-dis-gds-rule
    cb-pos-type
    .
    if lookup(cb-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U) = 0
    then do:
      message
      "Не заполнено место применения скидок"
      view-as alert-box error .
      undo, return no-apply.
    end.
    RUN proc-b-run IN THIS-PROCEDURE NO-ERROR.
END.
ON VALUE-CHANGED OF BR-dis-rule IN FRAME Dialog-Frame
DO:
  IF AVAILABLE temp-dis-rule THEN DO:
      DISPLAY
      temp-dis-rule.old-des @ f-old-des
      WITH FRAME Dialog-Frame.
  END.
  ELSE DO:
      DISPLAY
      '' @ f-old-des
      WITH FRAME Dialog-Frame.
  END.
END.
ON leave OF temp-dis-rule.des IN BROWSE br-dis-rule
DO:
   IF AVAILABLE temp-dis-rule  THEN DO:
       DEFINE BUFFER buf_temp-dis-rule FOR temp-dis-rule.
       FIND FIRST buf_temp-dis-rule WHERE
                RECID(buf_temp-dis-rule) = RECID(temp-dis-rule).
       ASSIGN
       buf_temp-dis-rule.des = temp-dis-rule.des:SCREEN-VALUE IN BROWSE br-dis-rule.
       OPEN QUERY BR-dis-rule FOR EACH temp-dis-rule NO-LOCK INDEXED-REPOSITION.
       REPOSITION br-dis-rule TO RECID RECID(buf_temp-dis-rule).
       APPLY "entry" to BROWSE br-dis-rule.
   END.
END.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame Dialog-Frame anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-dis-rule-add :sensitive then DO: apply "CHOOSE":U to b-dis-rule-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-dis-rule-del :sensitive then DO: apply "CHOOSE":U to b-dis-rule-del in frame Dialog-Frame. END.
  return no-apply.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BR-dis-rule :handle
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
  assign
    v-start-level = 2
  .
  assign
    level = v-start-level
  .
  repeat while program-name(level) <> ?:
    if program-name(level) = this-procedure:file-name then do:
      message
      "Вы уже находитесь в режиме копирования скидок"
      view-as alert-box error .
      undo, return error .
    end.
    assign
    level = level + 1
    .
  end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if lookup(p-list-mode, "template" + chr(44) +
                          "rule-num" + chr(44) +
                          'объект':U) = 0 then do:
    message
    substitute("Неверное значение параметра вызова p-list-mode = &1", p-list-mode)
    view-as alert-box error .
    undo main-block, return error .
  end.
  case p-list-mode:
     when "template" then do:
       v-templ-rl-root = p-rule-num.
     end.
     when "rule-num" then do:
       find first loc_dis-rule no-lock where
                  loc_dis-rule.rule-num = p-rule-num no-error.
       if not available loc_dis-rule then do:
          message
          substitute("Неверное значение параметра вызова p-rule-num = &1", p-rule-num)
          view-as alert-box error .
          undo main-block, return error .
       end.
      if loc_dis-rule.sts <> integer('0':U) then do:
                message
        substitute("Правило &1 находится в статусе &2, поэтому не может быть скопировано на другие объекты!"
                  , loc_dis-rule.rule-num
                  , entry (lookup (string(loc_dis-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
        view-as alert-box error .
        undo main-block, return error .
      end.
       create temp-dis-rule.
       buffer-copy loc_dis-rule to temp-dis-rule
       assign
       temp-dis-rule.old-des = loc_dis-rule.des
       .
       release temp-dis-rule.
     end.
     when 'объект':U then do:
       find first loc_clients no-lock where
                  loc_clients.obj-type = p-obj-type
               and loc_clients.obj-code = p-obj-code no-error.
       if not available loc_clients then do:
          message
          substitute("Неверное значение параметра вызова p-obj-type = &1 и/или p-obj-code = &2", p-obj-type, p-obj-code)
          view-as alert-box error .
          undo main-block, return error .
       end.
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
  DISPLAY T-dis-gds-rule cb-pos-type f-old-des
      WITH FRAME Dialog-Frame.
  ENABLE b-quit T-dis-gds-rule B-Help cb-pos-type B-dis-rule-add
         B-dis-rule-del b-lkp B-run BR-dis-rule B-objects-add
         B-objects-delete BR-objects
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BR-dis-rule FOR EACH temp-dis-rule NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BR-objects FOR EACH temp-clients NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
define variable v-jj as integer no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
DO v-ii = 1 TO NUM-ENTRIES('IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U):
  if p-list-mode = "template" then do:
    find first buf_dis-cfg-rule no-lock where
              buf_dis-cfg-rule.templ-rl-root =  p-rule-num
          and buf_dis-cfg-rule.pos-type =  ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U)
              no-error.
    if not available buf_dis-cfg-rule then next.
  end.
  if p-list-mode = "rule-num" then do:
    find first temp-dis-rule.
    find first buf_dis-cfg-rule no-lock where
              buf_dis-cfg-rule.templ-rl-root = temp-dis-rule.templ-rl-root
          and buf_dis-cfg-rule.pos-type =  ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,MARIA,-,bo':U)
              no-error.
    if not available buf_dis-cfg-rule then next.
  end.
  v-jj = v-jj + 1.
  ASSIGN
  v-list-items = v-list-items + (IF v-jj > 1 THEN  chr(44) ELSE "":U) +
                  ENTRY(v-ii, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U) + chr(44) +
                  ENTRY(v-ii, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U).
END.
assign
cb-pos-type:list-item-pairs in frame Dialog-Frame = v-list-items
temp-dis-rule.des:RESIZABLE IN BROWSE br-dis-rule = YES
.
DISPLAY
T-dis-gds-rule
WITH FRAME Dialog-Frame.
ENABLE
b-quit
T-dis-gds-rule
B-run
B-Help
B-dis-rule-add
B-dis-rule-del
cb-pos-type
BR-dis-rule
B-objects-add
B-objects-delete
b-lkp
BR-objects
WITH FRAME Dialog-Frame.
case p-list-mode:
  when 'объект':U then do:
    assign
    frame Dialog-Frame:title = substitute("Копирование скидок, действующих на &1&2 на другие объекты по списку"
                                           , p-obj-type
                                           , p-obj-code).
  end.
  when "rule-num" then do:
    assign
    frame Dialog-Frame:title = substitute("Копирование скидки &1 на другие объекты по списку"
                                           , p-rule-num
                                           ).
  end.
  when "template" then do:
    assign
    frame Dialog-Frame:title = substitute("Копирование скидок  по шаблону &1 на другие объекты по списку"
                                           , p-rule-num
                                           ).
  end.
end case.
VIEW FRAME Dialog-Frame.
if p-list-mode = "template" then do:
  find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root =  p-rule-num
        and buf_dis-cfg-rule.table-name =  'dis-gds-rule':U
            no-error.
  if not available buf_dis-cfg-rule then do:
    hide
    t-dis-gds-rule
    in frame Dialog-Frame .
  end.
end.
if p-list-mode = "rule-num" then do:
  find first temp-dis-rule.
  find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = temp-dis-rule.templ-rl-root
         and buf_dis-cfg-rule.table-name =  'dis-gds-rule':U
            no-error.
  if not available buf_dis-cfg-rule then do:
    hide
    t-dis-gds-rule
    in frame Dialog-Frame .
  end.
end.
OPEN QUERY BR-dis-rule FOR EACH temp-dis-rule NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BR-objects FOR EACH temp-clients NO-LOCK INDEXED-REPOSITION.
APPLY "ENTRY" TO br-dis-rule.
APPLY "value-changed" TO br-dis-rule.
END PROCEDURE.
PROCEDURE proc-b-dis-rule-add :
DEFINE VARIABLE v-sts AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rid-list as character NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-host-code as integer no-undo .
DEFINE BUFFER buf_dis-rule FOR ub.dis-rule.
DEFINE BUFFER buf_temp-dis-rule FOR temp-dis-rule.
if p-list-mode = 'объект':U then do:
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
  run ref/dis-ruls.w (
                input parparentproc
              , input v-host-code
              , input p-obj-type
              , input p-obj-code
              , input "b-sel,b-mark":U
              , input 'объект':U
              , input 0
              , input -1
              , input 0
              , input-output v-sts
              , input-output v-rid-list ) no-error .
end.
if p-list-mode = "template" then do:
  run ref/dis-ruls.w (
              input parparentproc
              ,input v-cntxt-host-code-obj
              ,input v-cntxt-obj-type
              ,input v-cntxt-obj-code
              ,input "b-sel,b-mark":U
              ,input "upper-rule-num":U
              ,input v-templ-rl-root
              ,input -1
              ,input 0
              ,input-output v-sts
              ,input-output v-rid-list ) no-error .
end.
IF ERROR-STATUS:ERROR OR v-rid-list = '' THEN UNDO, RETURN ERROR.
_do:
DO v-ii = 1 TO NUM-ENTRIES(v-rid-list):
   FIND FIRST buf_dis-rule NO-LOCK WHERE
            RECID(buf_dis-rule) = INTEGER(ENTRY(v-ii, v-rid-list)) NO-ERROR.
   IF AVAILABLE buf_dis-rule THEN DO:
     if not (buf_dis-rule.obj-type = 'скл':U
             or
             buf_dis-rule.obj-type = 'маг':U) then do:
       message
       substitute("Правило &1 не привязано к объекту, поэтому не может быть скопировано на другие объекты!", buf_dis-rule.rule-num)
       view-as alert-box error .
       next _do.
     end.
    if buf_dis-rule.sts <> integer('0':U) then do:
              message
       substitute("Правило &1 находится в статусе &2, поэтому не может быть скопировано на другие объекты!"
                , buf_dis-rule.rule-num
                , entry (lookup (string(buf_dis-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))
       view-as alert-box error .
       next _do.
     end.
     FIND FIRST buf_temp-dis-rule NO-LOCK WHERE
                  buf_temp-dis-rule.rule-num = buf_dis-rule.rule-num NO-ERROR.
      IF NOT AVAILABLE buf_temp-dis-rule THEN DO:
          CREATE buf_temp-dis-rule.
          BUFFER-COPY buf_dis-rule TO buf_temp-dis-rule
          ASSIGN
          buf_temp-dis-rule.old-des = buf_dis-rule.des
              .
    END.
  END.
END.
OPEN QUERY BR-dis-rule FOR EACH temp-dis-rule NO-LOCK INDEXED-REPOSITION.
APPLY "ENTRY" TO br-dis-rule IN FRAME Dialog-Frame.
APPLY "value-changed" TO br-dis-rule.
END PROCEDURE.
PROCEDURE proc-b-dis-rule-del :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_temp-dis-rule FOR temp-dis-rule.
IF NOT AVAILABLE temp-dis-rule THEN RETURN .
MESSAGE
"Вы действительно хотите удалить правило скидки из списка??"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN UNDO, RETURN.
FIND FIRST buf_temp-dis-rule WHERE
           recid(buf_temp-dis-rule) = RECID(temp-dis-rule) .
DELETE buf_temp-dis-rule.
OPEN QUERY BR-dis-rule FOR EACH temp-dis-rule NO-LOCK INDEXED-REPOSITION.
APPLY "ENTRY" TO br-dis-rule IN FRAME Dialog-Frame.
APPLY "value-changed" TO br-dis-rule.
END PROCEDURE.
PROCEDURE proc-b-objects-add :
DEFINE VARIABLE v-rid-list as character NO-UNDO.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-user-select as logical   no-undo .
DEFINE BUFFER buf_temp-clients FOR temp-clients.
define buffer buf_clients for ub.clients.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_clear in this-procedure  .
for each buf_temp-clients:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_append in this-procedure
  (input  buf_temp-clients.obj-type
  ,input  buf_temp-clients.obj-code
  )  .
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
if v-user-select <> true
then do:
  message
    "Объекты не выбраны"
    view-as alert-box information .
  return NO-APPLY .
end.
define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
for each buf_userobjs_temp-user-obj
on error undo, return no-apply
:
  find first buf_temp-clients  where
             buf_temp-clients.obj-type = buf_userobjs_temp-user-obj.obj-type
         and buf_temp-clients.obj-code = buf_userobjs_temp-user-obj.obj-code no-error.
  if not available buf_temp-clients then do:
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
           and buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code .
    create buf_temp-clients.
    buffer-copy buf_clients to buf_temp-clients.
  end.
end.
OPEN QUERY BR-objects FOR EACH temp-clients NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE proc-b-objects-delete :
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
DEFINE BUFFER buf_temp-clients FOR temp-clients.
IF NOT AVAILABLE temp-clients THEN RETURN .
MESSAGE
"Вы действительно хотите удалить объект из списка??"
VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
IF NOT glog THEN UNDO, RETURN.
FIND FIRST buf_temp-clients WHERE
           recid(buf_temp-clients) = RECID(temp-clients) .
DELETE buf_temp-clients.
OPEN QUERY BR-objects FOR EACH temp-clients NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE proc-b-run :
DEFINE VARIABLE v-parameter AS CHARACTER NO-UNDO.
define  BUFFER buf_temp-dis-rule FOR temp-dis-rule.
define  BUFFER buf_temp-clients FOR temp-clients.
FIND FIRST buf_temp-dis-rule NO-ERROR.
IF NOT AVAILABLE buf_temp-dis-rule THEN DO:
  MESSAGE
  "Не выбрано ни одного правила скидки-оригинала для копирования"
   VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN.
END.
FIND FIRST buf_temp-clients NO-ERROR.
IF NOT AVAILABLE buf_temp-clients THEN DO:
  MESSAGE
  "Не выбрано ни одного объекта-назначения для копирования"
   VIEW-AS ALERT-BOX ERROR.
  UNDO, RETURN.
END.
ASSIGN
v-parameter = STRING(t-dis-gds-rule) + chr(4) +
              cb-pos-type
              .
run str/diallog.w ( input parparentproc
            , input this-procedure
            , input ('proc-copy':U + chr(4) +
                    "1" + chr(4) +
                    "0" + chr(4) +
                    "1" + chr(4) +
                    "1" + chr(4) +
                    "yes")
            , input v-parameter
            , input NO
            , input 'Прервать'
            , input 'Копирование скидок') no-error .
END PROCEDURE.
PROCEDURE proc-copy :
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character        no-undo.
DEFINE VARIABLE V-DIS-GDS-RULE   AS LOGICAL   NO-UNDO.
define variable v-cd-type        as character no-undo .
define variable LOG-FILE-NAME    as character no-undo .
define variable v-dr-ii          as integer   no-undo .
define variable v-dr-ii-ok       as integer   no-undo .
define variable v-dgr-ii         as integer   no-undo .
define variable v-dgr-ii-ok      as integer   no-undo .
define variable v-loc-dgr-ii     as integer   no-undo .
define variable v-loc-dgr-ii-ok  as integer   no-undo .
define variable v-rule-num-count as integer   no-undo .
define variable v-rule-num       as integer   no-undo .
define variable v-upper-rule-num as integer   no-undo .
define variable v-err-cnt        as integer   no-undo init 0 .
define variable v-recid as recid     no-undo .
define variable glog    as logical   no-undo .
define variable dflt-cd as character no-undo .
define variable v-add-upd as logical no-undo .
define variable v-do-it   as logical no-undo init yes .
define buffer buf_temp-dis-rule for temp-dis-rule .
define buffer buf_temp-clients  for temp-clients .
define buffer term_dis-rule     for ub.dis-rule .
define buffer trg_dis-rule      for ub.dis-rule .
define buffer src_dis-rule      for ub.dis-rule .
define buffer src_dis-gds-rule  for ub.dis-gds-rule .
define buffer buf_dis-cfg-rule  for ub.dis-cfg-rule .
define buffer buf_dis-rule      for ub.dis-rule .
define buffer buf_tt0           for tt0-term_dis-rule .
define buffer src_dis-gds-rule-attr for ub.dis-gds-rule-attr .
define buffer trg_dis-gds-rule-attr for ub.dis-gds-rule-attr .
if num-entries(p-parameter, chr(4)) <> 2
then do:
  MESSAGE substitute("Неверное количество ENTRY в составном параметре - &1, должно быть 2"
                             , num-entries(p-parameter, chr(4)))
  VIEW-AS ALERT-BOX ERROR
  .
  RETURN error.
end.
ASSIGN
V-DIS-GDS-RULE = LOGICAL(ENTRY(1, P-PARAMETER, chr(4) ))
v-cd-type = entry(2, p-parameter, chr(4) )
.
LOG-file-name = substitute("&1.txt", entry(1, this-procedure:file-name, ".")).
log-file-name = entry( num-entries(log-file-name, chr(47)), log-file-name, chr(47)).
for each tt0-term_dis-rule:
  delete tt0-term_dis-rule.
end.
for each tt-dis-rule:
  delete tt-dis-rule.
end.
create tt0-term_dis-rule.
_temp-dis-rule:
for each buf_temp-dis-rule:
  if buf_temp-dis-rule.sts <> integer('0':U) then do:
               run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Нельзя копировать правило в статусе &1", entry (lookup (string(buf_temp-dis-rule.sts), '0,1,2,99,98':U), 'исп,не-исп,детализ,удаление,запр.удал':U))                                       ).
     assign
       v-dr-ii = v-dr-ii + 1
       v-err-cnt = v-err-cnt + 1 .
  end.
  run disrules-fill-properties in this-procedure ( input buf_temp-dis-rule.templ-rl-root).
  FIND FIRST buf_dis-cfg-rule NO-LOCK where
            buf_dis-cfg-rule.table-name = 'dis-gds-rule':U
        and buf_dis-cfg-rule.templ-rl-root = buf_temp-dis-rule.templ-rl-root
        and buf_dis-cfg-rule.time-templ-rl-root = buf_temp-dis-rule.time-templ-rl-root
        and buf_dis-cfg-rule.pos-type = v-cd-type
        no-error
         .
  _temp-clients:
  for each buf_temp-clients :
    if not (v-cd-type = 'bo':U or v-cd-type = '-':U) and
       not buf_temp-clients.obj-type = 'орг':U
    then do:
      if buf_temp-clients.obj-type = 'скл':U then do:
                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Нельзя скопировать правила скидки на объект &1&2"                                      , buf_temp-clients.obj-type                                     , buf_temp-clients.obj-code                                     )                                       ).
        assign
          v-dr-ii = v-dr-ii + 1
          v-err-cnt = v-err-cnt + 1 .
        next _temp-clients.
      end.
      dflt-cd = ''.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type20 as character no-undo .
define variable v-value-date20 as date no-undo .
define variable v-value-decimal20 as decimal no-undo .
define variable v-value-integer20 as INTEGER no-undo .
define variable v-value-logical20 AS LOGICAL no-undo .
define variable v-tth20 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  buf_temp-clients.obj-type
    ,input  buf_temp-clients.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date20
    ,output v-value-decimal20
    ,output v-value-integer20
    ,output v-value-logical20
    ,output v-param-type20
    ,INPUT-OUTPUT table-handle v-tth20
    )  .
delete object v-tth20 no-error.
      if dflt-cd <> v-cd-type then do:
                run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Нельзя скопировать правила скидки на объект &1&2&3" +                                     "На нем работает POS типа &4"                                     , buf_temp-clients.obj-type                                     , buf_temp-clients.obj-code                                     , chr(10)                                     , dflt-cd)                                       ).
        assign
          v-dr-ii = v-dr-ii + 1
          v-err-cnt = v-err-cnt + 1 .
        next _temp-clients.
      end.
    end.
    for each tt-dis-rule:
      delete tt-dis-rule.
    end.
    create tt-dis-rule.
    assign
    tt-dis-rule.des = buf_temp-dis-rule.des
    tt-dis-rule.host-code          = ( if buf_temp-clients.host-code = ? then buf_temp-clients.obj-code  else buf_temp-clients.host-code )
    tt-dis-rule.obj-type           = ( if buf_temp-clients.host-code = ? then buf_temp-dis-rule.obj-type else buf_temp-clients.obj-type )
    tt-dis-rule.obj-code           = ( if buf_temp-clients.host-code = ? then buf_temp-dis-rule.obj-code else buf_temp-clients.obj-code )
    tt-dis-rule.discnt-type        = buf_temp-dis-rule.discnt-type
    tt-dis-rule.discnt-value       = buf_temp-dis-rule.discnt-value
    tt-dis-rule.time-rule-num      = buf_temp-dis-rule.time-rule-num
    tt-dis-rule.time-templ-rl-root = buf_temp-dis-rule.time-templ-rl-root
    tt-dis-rule.tot-sum            = buf_temp-dis-rule.tot-sum
    tt-dis-rule.sts                = buf_temp-dis-rule.sts
    tt-dis-rule.doc-qnty           = buf_temp-dis-rule.doc-qnty
    .
    find first buf_dis-rule no-lock where
              buf_dis-rule.discnt-type        = tt-dis-rule.discnt-type
          and buf_dis-rule.discnt-value       = tt-dis-rule.discnt-value
          and buf_dis-rule.time-rule-num      = tt-dis-rule.time-rule-num
          and buf_dis-rule.time-templ-rl-root = tt-dis-rule.time-templ-rl-root
          and buf_dis-rule.tot-sum            = tt-dis-rule.tot-sum
          and buf_dis-rule.sts                = tt-dis-rule.sts
          and buf_dis-rule.doc-qnty           = tt-dis-rule.doc-qnty
          and buf_dis-rule.host-code = tt-dis-rule.host-code
          and buf_dis-rule.obj-type = tt-dis-rule.obj-type
          and buf_dis-rule.obj-code = tt-dis-rule.obj-code
          and buf_dis-rule.templ-rl-root = buf_temp-dis-rule.templ-rl-root
          and buf_dis-rule.root = yes no-error.
    if available buf_dis-rule then do:
      assign
        v-add-upd = false
        v-upper-rule-num = buf_dis-rule.rule-num
        v-recid = recid(buf_dis-rule)
      .
    end.
    else do:
      v-add-upd = true .
    end.
    buffer-copy buf_temp-dis-rule
    except des
    host-code
    obj-type
    obj-code
    to tt-dis-rule .
    for each tt0-term_dis-rule:
        delete tt0-term_dis-rule .
    end.
    v-rule-num-count = 0 .
    for each term_dis-rule no-lock
    where term_dis-rule.upper-rule-num = buf_temp-dis-rule.rule-num :
        v-rule-num-count = v-rule-num-count + 1.
        create tt0-term_dis-rule.
        buffer-copy term_dis-rule
        except host-code obj-type obj-code
        rule-num upper-rule-num rl-root
        to tt0-term_dis-rule
        assign
        tt0-term_dis-rule.host-code      = buf_temp-clients.host-code
        tt0-term_dis-rule.obj-type       = buf_temp-clients.obj-type
        tt0-term_dis-rule.obj-code       = buf_temp-clients.obj-code
        tt0-term_dis-rule.rule-num       = v-rule-num-count
        tt0-term_dis-rule.upper-rule-num = (if v-add-upd then buf_temp-dis-rule.templ-rl-root else v-upper-rule-num)
        tt0-term_dis-rule.rl-root        = buf_temp-dis-rule.templ-rl-root
        .
        release tt0-term_dis-rule.
    end.
    if not v-add-upd then do:
      find first tt0-term_dis-rule no-lock no-error .
      find first buf_dis-rule no-lock where
              buf_dis-rule.host-code      = tt0-term_dis-rule.host-code
          and buf_dis-rule.obj-type       = tt0-term_dis-rule.obj-type
          and buf_dis-rule.obj-code       = tt0-term_dis-rule.obj-code
          and buf_dis-rule.templ-rl-root  = tt0-term_dis-rule.templ-rl-root
          and buf_dis-rule.root           = false
          and buf_dis-rule.upper-rule-num = tt0-term_dis-rule.upper-rule-num
      no-error.
      if avail buf_dis-rule then do:
          assign
            tt0-term_dis-rule.rule-num = buf_dis-rule.rule-num
          .
      end.
      else do:
         run gen-b-code in this-procedure ( input 'drgb':U, output v-rule-num) no-error .
         if error-status:error then do:
                            run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Не удалось скопировать правило скидки &1 (gen-b-code) на &2&3&4&5&4&6"                                             , buf_temp-dis-rule.rule-num                                             , buf_temp-clients.obj-type                                             , buf_temp-clients.obj-code                                              , chr(10)                                             , error-status:get-message(1)                                              , return-value )                                       ).
              assign
                v-dr-ii = v-dr-ii + 1
                v-err-cnt = v-err-cnt + 1 .
              next _temp-clients.
         end.
         find first buf_tt0 no-lock no-error.
         if avail buf_tt0 then do:
             create buf_dis-rule.
             buffer-copy buf_tt0
             except rule-num
             to buf_dis-rule
             assign
             buf_dis-rule.rule-num = v-rule-num
             buf_tt0.rule-num = v-rule-num
             .
         end.
         else do:
            v-do-it = false .
         end.
      end.
    end.
    find first buf_tt0 no-lock no-error.
    if avail buf_tt0 and buf_tt0.time-templ-rl-root > 0 then do:
      assign
        tt-dis-rule.time-rule-num = buf_tt0.time-rule-num
      .
    end.
    v-dr-ii = v-dr-ii + 1.
    if v-do-it then do:
        run ref/dis-rul1.p (
        input (if v-add-upd then ? else v-upper-rule-num)
        ,input v-cd-type
        ,input buf_temp-dis-rule.templ-rl-root
        ,input buf_temp-dis-rule.templ-rl-root
        ,input buf_temp-dis-rule.des
        ,input tt-dis-rule.dis-kat
        ,input tt-dis-rule.discnt-type
        ,input tt-dis-rule.doc-qnty
        ,input tt-dis-rule.tot-sum
        ,input tt-dis-rule.charkey_one
        ,input tt-dis-rule.charkey_two
        ,input tt-dis-rule.charkey_three
        ,input tt-dis-rule.deckey_one
        ,input tt-dis-rule.deckey_two
        ,input tt-dis-rule.deckey_three
        ,input tt-dis-rule.key#_one
        ,input tt-dis-rule.key#_two
        ,input tt-dis-rule.key#_three
        ,input tt-dis-rule.subject-type
        ,input tt-dis-rule.time-templ-rl-root
        ,input (if tt-dis-rule.time-templ-rl-root = 0 then 0 else tt-dis-rule.time-rule-num)
        ,input tt-dis-rule.upper-rule-num
        ,input tt-dis-rule.value-type
        ,input tt-dis-rule.host-code
        ,INPUT tt-dis-rule.obj-type
        ,INPUT tt-dis-rule.obj-code
        ,INPUT tt-dis-rule.discnt-value
        ,input table tt0-term_dis-rule
        ,input-output v-recid
        ,input (if v-add-upd then 'ДОБАВЛЕНИЕ':U else 'ИЗМЕНЕНИЕ':U)
        ,input yes
        ) NO-ERROR.
        if error-status:error then do:
                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Не удалось скопировать правило скидки &1 на &2&3&4&5&4&6"                                         , buf_temp-dis-rule.rule-num                                         , buf_temp-clients.obj-type                                         , buf_temp-clients.obj-code                                          , chr(10)                                         , error-status:get-message(1)                                          , return-value )                                       ).
          assign
            v-dr-ii = v-dr-ii + 1
            v-err-cnt = v-err-cnt + 1
          .
          next _temp-clients.
        end.
    end.
    assign
      v-do-it = true
      v-dr-ii-ok = v-dr-ii-ok + 1
    .
    if v-dis-gds-rule then do:
        assign
          v-loc-dgr-ii = 0
          v-loc-dgr-ii-ok = 0
        .
        find first trg_dis-rule no-lock
        where recid(trg_dis-rule) = v-recid no-error.
        if available buf_dis-cfg-rule then do:
            for each src_dis-gds-rule no-lock
            where src_dis-gds-rule.obj-type = ( if buf_temp-clients.host-code = ? then 'орг':U                      else buf_temp-dis-rule.obj-type )
              and src_dis-gds-rule.obj-code = ( if buf_temp-clients.host-code = ? then buf_temp-dis-rule.host-code else buf_temp-dis-rule.obj-code )
              and src_dis-gds-rule.rule-num = buf_temp-dis-rule.rule-num
              and src_dis-gds-rule.pos-type = v-cd-type :
                assign
                  v-dgr-ii = v-dgr-ii + 1
                  v-loc-dgr-ii = v-loc-dgr-ii + 1
                .
                if buf_temp-clients.host-code = ? then do:
                    run cmp-disgdsru-write in this-procedure (
                                                         input src_dis-gds-rule.gds-code
                                                        ,input 'орг':U
                                                        ,input trg_dis-rule.host-code
                                                        ,input v-cd-type
                                                        ,input trg_dis-rule.templ-rl-root
                                                        ,input src_dis-gds-rule.time-templ-rl-root
                                                        ,input buf_dis-cfg-rule.discnt-role
                                                        ,input trg_dis-rule.rule-num
                                                        ,input src_dis-gds-rule.nonunique
                                                       )  no-error.
                end.
                else do:
                run disgdsru-write in this-procedure ( input buf_temp-clients.obj-type
                                                      ,input buf_temp-clients.obj-code
                                                      ,input src_dis-gds-rule.gds-code
                                                      ,input v-cd-type
                                                      ,input buf_dis-cfg-rule.discnt-role
                                                      ,input trg_dis-rule.templ-rl-root
                                                      ,input src_dis-gds-rule.time-templ-rl-root
                                                      ,input trg_dis-rule.rule-num
                                                      ,input src_dis-gds-rule.nonunique
                )  no-error.
                end.
                if error-status :error then do:
                    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Не удалось привязать правило скидки &1 к товару с кодом &2 на &3&4&5&6&5&7"                         , trg_dis-rule.rule-num                         , src_dis-gds-rule.gds-code                         , buf_temp-clients.obj-type                         , buf_temp-clients.obj-code                          , chr(10)                         , error-status:get-message(1)                          , return-value )                                       ) .
                    assign
                      v-dr-ii = v-dr-ii + 1
                      v-err-cnt = v-err-cnt + 1
                    .
                end.
                else do:
                    if buf_dis-cfg-rule.discnt-role = 'bonus-qnty' and
                       buf_dis-cfg-rule.nonunique   = 'bar-code.b-code'
                    then do:
                        for each src_dis-gds-rule-attr no-lock
                        where src_dis-gds-rule-attr.gds-code    = src_dis-gds-rule.gds-code
                          and src_dis-gds-rule-attr.obj-type    = src_dis-gds-rule.obj-type
                          and src_dis-gds-rule-attr.obj-code    = src_dis-gds-rule.obj-code
                          and src_dis-gds-rule-attr.pos-type    = v-cd-type
                          and src_dis-gds-rule-attr.discnt-role = buf_dis-cfg-rule.discnt-role
                          and src_dis-gds-rule-attr.nonunique   = src_dis-gds-rule.nonunique
                        :
                            find first trg_dis-gds-rule-attr exclusive-lock
                            where trg_dis-gds-rule-attr.gds-code    = src_dis-gds-rule.gds-code
                              and trg_dis-gds-rule-attr.obj-type    = ( if buf_temp-clients.host-code = ? then 'орг':U                 else buf_temp-clients.obj-type )
                              and trg_dis-gds-rule-attr.obj-code    = ( if buf_temp-clients.host-code = ? then trg_dis-rule.host-code else buf_temp-clients.obj-code )
                              and trg_dis-gds-rule-attr.pos-type    = v-cd-type
                              and trg_dis-gds-rule-attr.discnt-role = buf_dis-cfg-rule.discnt-role
                              and trg_dis-gds-rule-attr.nonunique   = src_dis-gds-rule.nonunique
                              and trg_dis-gds-rule-attr.attr-value  = src_dis-gds-rule-attr.attr-value
                            no-error.
                            if not avail trg_dis-gds-rule-attr then do:
                                create trg_dis-gds-rule-attr .
                                buffer-copy src_dis-gds-rule-attr
                                except obj-type obj-code
                                to trg_dis-gds-rule-attr
                                assign
                                  trg_dis-gds-rule-attr.obj-type = ( if buf_temp-clients.host-code = ? then 'орг':U                 else buf_temp-clients.obj-type )
                                  trg_dis-gds-rule-attr.obj-code = ( if buf_temp-clients.host-code = ? then trg_dis-rule.host-code else buf_temp-clients.obj-code )
                                .
                            end.
                        end.
                    end.
                    assign
                      v-dgr-ii-ok = v-dgr-ii-ok + 1
                      v-loc-dgr-ii-ok = v-loc-dgr-ii-ok + 1
                    .
                end.
            end.
        end.
    end.
    if v-dis-gds-rule then do:
            run write-counter in p-log-handle (input substitute("Пр. скидок: OK &1 из &2, привязки: OK &3 из &4", v-dr-ii-ok, v-dr-ii, v-dgr-ii-ok, v-dgr-ii)) .
    end.
    else do:
            run write-counter in p-log-handle (input substitute("Пр. скидок: OK &1 из &2", v-dr-ii-ok, v-dr-ii)) .
    end.
  end.
  if v-dis-gds-rule  then do:
        run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("привязки Правила &1: OK &2 из &3", buf_temp-dis-rule.rule-num, v-loc-dgr-ii, v-loc-dgr-ii-ok)                                       ).
  end.
  end.
if v-dis-gds-rule then do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Пр. скидок: OK &1 из &2, привязки: OK &3 из &4", v-dr-ii-ok, v-dr-ii, v-dgr-ii-ok, v-dgr-ii)                                       ).
end.
else do:
    run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Пр. скидок: OK &1 из &2", v-dr-ii-ok, v-dr-ii)                                       ).
end.
run write-log-and-file in p-log-handle (           input 1         , input log-file-name         , input 1         , input substitute("Копирование закончено")                                       ).
run write-counter in p-log-handle (input substitute("Пр. скидок: OK &1 из &2", v-dr-ii-ok, v-dr-ii)).
if v-err-cnt > 0 then do:
    return error.
end.
END PROCEDURE.
