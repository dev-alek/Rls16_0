DEFINE BUFFER buf_tnv-in-turnover-group FOR ub.tnv-in-turnover-group.
DEFINE NEW SHARED BUFFER buf_turnover-group FOR ub.turnover-group.
define input  parameter parParentProc as handle no-undo .
define input  parameter p-bttns    as character no-undo .
define input-output parameter p-rec-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник суммовых групп для ценообразования".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE oio-ADD :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ttg-summa    as decimal   no-undo .
define input  parameter p-use-discnt           as logical   no-undo .
define input  parameter p-discnt-pc            as decimal   no-undo .
define input  parameter p-discnt-method-round  as character no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
define output parameter p-recid as recid no-undo .
  do
  on error undo, return error return-value
  :
find first ub.tnv-in-turnover-group exclusive-lock where
        ub.tnv-in-turnover-group.tog-db-num   = p-db-num  and
        ub.tnv-in-turnover-group.tog-id       = p-id      and
        ub.tnv-in-turnover-group.ttg-summa    = p-ttg-summa
        no-error .
      if not available ub.tnv-in-turnover-group then do:
          create ub.tnv-in-turnover-group.
            assign
                ub.tnv-in-turnover-group.tog-db-num          = p-db-num
                ub.tnv-in-turnover-group.tog-id              = p-id
                ub.tnv-in-turnover-group.ttg-summa           = p-ttg-summa
                ub.tnv-in-turnover-group.use-discnt          = p-use-discnt
                ub.tnv-in-turnover-group.discnt-pc           = p-discnt-pc
                ub.tnv-in-turnover-group.discnt-method-round = p-discnt-method-round
            .
      end.
      assign
        ub.tnv-in-turnover-group.db-num-chg    = p-db-num-usr
        ub.tnv-in-turnover-group.stts          = p-stts
        ub.tnv-in-turnover-group.sys-date      = today
        ub.tnv-in-turnover-group.sys-time      = time
        ub.tnv-in-turnover-group.sys-time-chr  = string ( ub.tnv-in-turnover-group.sys-time,"hh:mm" )
        ub.tnv-in-turnover-group.who           = p-userid
        p-recid = recid ( ub.tnv-in-turnover-group )
      .
  end.
end procedure.
PROCEDURE oio-DEL :
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ttg-summa     as decimal   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
  do
  on error undo, return error return-value
  :
find first ub.tnv-in-turnover-group exclusive-lock where
        ub.tnv-in-turnover-group.tog-db-num   = p-db-num  and
        ub.tnv-in-turnover-group.tog-id       = p-id      and
        ub.tnv-in-turnover-group.ttg-summa = p-ttg-summa
        no-error .
 if not available ub.tnv-in-turnover-group then  return error .
      assign
        ub.tnv-in-turnover-group.db-num-chg    = p-db-num-usr
        ub.tnv-in-turnover-group.stts          = 1
        ub.tnv-in-turnover-group.sys-date      = today
        ub.tnv-in-turnover-group.sys-time      = time
        ub.tnv-in-turnover-group.sys-time-chr  = string(ub.tnv-in-turnover-group.sys-time,"hh:mm")
        ub.tnv-in-turnover-group.who           = p-userid
      .
  end.
end procedure.
PROCEDURE oio-update :
define input  parameter p-recid       as recid no-undo .
define input  parameter p-db-num       as integer   no-undo .
define input  parameter p-id           as integer   no-undo .
define input  parameter p-ttg-summa    as decimal   no-undo .
define input  parameter p-use-discnt           as logical   no-undo .
define input  parameter p-discnt-pc            as decimal   no-undo .
define input  parameter p-discnt-method-round  as character no-undo .
define input  parameter p-stts         as integer   no-undo .
define input  parameter p-db-num-usr   as integer   no-undo .
define input  parameter p-userid       as character no-undo .
  do
  on error undo, return error return-value
  :
find first ub.tnv-in-turnover-group exclusive-lock where
        recid(ub.tnv-in-turnover-group) = p-recid
        no-error .
      if not available ub.tnv-in-turnover-group then do:
          create ub.tnv-in-turnover-group.
            assign
                ub.tnv-in-turnover-group.tog-db-num          = p-db-num
                ub.tnv-in-turnover-group.tog-id              = p-id
                ub.tnv-in-turnover-group.ttg-summa           = p-ttg-summa
                ub.tnv-in-turnover-group.use-discnt          = p-use-discnt
                ub.tnv-in-turnover-group.discnt-pc           = p-discnt-pc
                ub.tnv-in-turnover-group.discnt-method-round = p-discnt-method-round
            .
      end.
      assign
        ub.tnv-in-turnover-group.tog-db-num          = p-db-num
        ub.tnv-in-turnover-group.tog-id              = p-id
        ub.tnv-in-turnover-group.ttg-summa           = p-ttg-summa
        ub.tnv-in-turnover-group.use-discnt          = p-use-discnt
        ub.tnv-in-turnover-group.discnt-pc           = p-discnt-pc
        ub.tnv-in-turnover-group.discnt-method-round = p-discnt-method-round
        ub.tnv-in-turnover-group.db-num-chg    = p-db-num-usr
        ub.tnv-in-turnover-group.stts          = p-stts
        ub.tnv-in-turnover-group.sys-date      = today
        ub.tnv-in-turnover-group.sys-time      = time
        ub.tnv-in-turnover-group.sys-time-chr  = string ( ub.tnv-in-turnover-group.sys-time,"hh:mm" )
        ub.tnv-in-turnover-group.who           = p-userid
      .
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define variable v-sec as integer   no-undo .
define variable r-find  as logical   no-undo init false .
define variable find-id as integer   no-undo .
define variable find-db as integer   no-undo .
define variable v-rec-list-cli as character no-undo .
define variable g-log as logical   no-undo .
function mark-string returns character
  ( buffer loc-table for ub.turnover-group, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.
function mark-string-2 returns character
  ( buffer loc-table for ub.tnv-in-turnover-group , input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.
function stts-string-2 returns character
  ( buffer loc-table for ub.tnv-in-turnover-group   ) :
return entry (lookup (string(loc-table.stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U) .
end function.
function stts-string returns character
  ( buffer loc-table for ub.turnover-group   ) :
return entry (lookup (string(loc-table.stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U) .
end function.
DEFINE QUERY external_tables FOR buf_turnover-group.
DEFINE BUTTON B-add
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить группу"
     BGCOLOR 8 .
DEFINE BUTTON B-add-2
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить оборот"
     BGCOLOR 8 .
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить название группы"
     BGCOLOR 8 .
DEFINE BUTTON B-chg-2
     LABEL "Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменить оборот и скидку"
     BGCOLOR 8 .
DEFINE BUTTON b-clients
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL ""
     SIZE 3 BY .83 TOOLTIP "Кто из покупателей входит в группу".
DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить группу"
     BGCOLOR 8 .
DEFINE BUTTON B-del-2
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить оборот"
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-history
     LABEL "История"
     SIZE 10 BY 1 TOOLTIP "История изменения справочника"
     BGCOLOR 8 .
DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить группу"
     BGCOLOR 8 .
DEFINE BUTTON B-mark-2
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить оборот"
     BGCOLOR 8 .
DEFINE BUTTON B-price-type
     LABEL "&ТПЛ"
     SIZE 6 BY 1 TOOLTIP "Список типов ПЛ по группе оборотов".
DEFINE BUTTON B-print
     LABEL "Печать"
     SIZE 10 BY 1 TOOLTIP "Печать справочника"
     BGCOLOR 8 .
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE R-status AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие", 0,
"Все", 2,
"Удаленные", 1
     SIZE 30.5 BY .67 TOOLTIP "Условие отбора записей" NO-UNDO.
DEFINE QUERY BROWSE-1grp FOR
      buf_turnover-group SCROLLING.
DEFINE QUERY BROWSE-2cli FOR
      buf_tnv-in-turnover-group SCROLLING.
DEFINE BROWSE BROWSE-1grp
  QUERY BROWSE-1grp NO-LOCK DISPLAY
      mark-string(buffer buf_turnover-group, p-rec-list) COLUMN-LABEL "*! " FORMAT "x(1)":U
      stts-string(buffer buf_turnover-group) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_turnover-group.tog-id COLUMN-LABEL "Код! " FORMAT ">>9":U
      buf_turnover-group.name COLUMN-LABEL "Название!группы" FORMAT "X(80)":U
      usrfulnf(buf_turnover-group.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(15)":U
      buf_turnover-group.sys-date COLUMN-LABEL "Дата!изм" FORMAT "99/99/99":U
      buf_turnover-group.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_turnover-group.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      buf_turnover-group.tog-db-num COLUMN-LABEL "БДсоз!дания" FORMAT ">>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 48.13 BY 19
         TITLE "Группы оборотов покупателей" FIT-LAST-COLUMN.
DEFINE BROWSE BROWSE-2cli
  QUERY BROWSE-2cli NO-LOCK DISPLAY
      mark-string-2 ( buffer buf_tnv-in-turnover-group, v-rec-list-cli ) COLUMN-LABEL "*! " FORMAT "x(1)":U
      stts-string-2 ( buffer buf_tnv-in-turnover-group ) COLUMN-LABEL "Ста!тус" FORMAT "x(3)":U
      buf_tnv-in-turnover-group.ttg-summa COLUMN-LABEL "Оборот! " FORMAT "->,>>>,>>>,>>>,>>9.99":U
     (IF buf_tnv-in-turnover-group.discnt-pc = 0 THEN "" ELSE string(buf_tnv-in-turnover-group.discnt-pc)) COLUMN-LABEL "Скид-!ка %" FORMAT "x(6)":U
      usrfulnf(buf_tnv-in-turnover-group.who) COLUMN-LABEL "Кто!изменял" FORMAT "X(15)":U
      buf_tnv-in-turnover-group.sys-date COLUMN-LABEL "Дата!изм" FORMAT "99/99/99":U
      buf_tnv-in-turnover-group.sys-time-chr COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_tnv-in-turnover-group.db-num-chg COLUMN-LABEL "БД!изм" FORMAT ">>>>9":U
      buf_tnv-in-turnover-group.tog-id COLUMN-LABEL "Гру!ппа" FORMAT ">>9":U
      buf_tnv-in-turnover-group.tog-db-num FORMAT ">>>>9":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 50.5 BY 19
         TITLE "Обороты в группе" FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-sel AT ROW 1 COL 11
     B-add AT ROW 1 COL 21
     B-chg AT ROW 1 COL 31 WIDGET-ID 2
     B-del AT ROW 1 COL 41
     B-price-type AT ROW 1 COL 51
     B-history AT ROW 1 COL 79.88
     B-Help AT ROW 1 COL 90
     B-print AT ROW 2 COL 90
     R-status AT ROW 2.29 COL 9.63 NO-LABEL
     B-mark-2 AT ROW 2.92 COL 49.75
     B-add-2 AT ROW 2.92 COL 53
     B-chg-2 AT ROW 2.92 COL 63.13
     B-del-2 AT ROW 2.92 COL 73.13
     B-mark AT ROW 3 COL 1.75
     b-clients AT ROW 3 COL 83.5 WIDGET-ID 4
     BROWSE-1grp AT ROW 4 COL 1.38
     BROWSE-2cli AT ROW 4 COL 49.5
     FILL-IN-1 AT ROW 2.25 COL 2 NO-LABEL
     SPACE(90.88) SKIP(20.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Группы оборотов покупателей для ценообразования"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-add IN FRAME Dialog-Frame
DO:
   define variable g#log as logical   no-undo .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ref-mpl_update':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log then return .
define variable v-rec-id as recid no-undo .
  run ref/gr-oupra.w (input parparentproc,input 'ДОБАВЛЕНИЕ':U , input-output v-rec-id) .
  OPEN QUERY BROWSE-1grp FOR EACH buf_turnover-group WHERE ( r-status = 2 OR buf_turnover-group.stts =  r-status ) and ( r-find = no or (buf_turnover-group.tog-db-num = find-db and                   buf_turnover-group.tog-id = find-id )) .
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
END.
ON CHOOSE OF B-add-2 IN FRAME Dialog-Frame
DO:
   define variable g#log as logical   no-undo .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ref-mpl_update':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log then return .
define variable v-rec-id as recid no-undo .
if not available buf_turnover-group then return .
if buf_turnover-group.stts <> 0 then do:
   message "В эту группу добавлять оборот нельзя!" view-as alert-box error .
   return .
end.
if v-cntxt-db-num <> 0 then do :
   if buf_turnover-group.tog-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_turnover-group.tog-db-num ) .
      return .
   end.
end.
  run ref/gr-ouprb.w (
      input parparentproc ,
      input 'ДОБАВЛЕНИЕ':U ,
      input buf_turnover-group.tog-db-num ,
      input buf_turnover-group.tog-id     ,
      input buf_turnover-group.name ,
      input-output v-rec-id ) .
  OPEN QUERY BROWSE-2cli FOR EACH buf_tnv-in-turnover-group OF buf_turnover-group      WHERE ( r-status = 2 OR buf_tnv-in-turnover-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION.
  reposition BROWSE-2cli to recid v-rec-id no-error .
  if available buf_tnv-in-turnover-group then
  run ref/h-grtnv.p (buffer buf_tnv-in-turnover-group , input-output v-sec )  .
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
   define variable g#log as logical   no-undo .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ref-mpl_update':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log then return .
define variable v-rec-id as recid no-undo .
IF NOT AVAILABLE buf_turnover-group THEN DO:
   RETURN.
END.
  if buf_turnover-group.stts <> 0 then do:
     message "Группа удалена"  .
     return .
  end.
if v-cntxt-db-num <> 0 then do :
   if buf_turnover-group.tog-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_turnover-group.tog-db-num ) .
      return .
   end.
end.
  v-rec-id = RECID (buf_turnover-group) .
  run ref/gr-oupra.w (input parparentproc,input 'ИЗМЕНЕНИЕ':U , input-output v-rec-id) .
  OPEN QUERY BROWSE-1grp FOR EACH buf_turnover-group WHERE ( r-status = 2 OR buf_turnover-group.stts =  r-status ) and ( r-find = no or (buf_turnover-group.tog-db-num = find-db and                   buf_turnover-group.tog-id = find-id )) .
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
END.
ON CHOOSE OF B-chg-2 IN FRAME Dialog-Frame
DO:
   define variable g#log as logical   no-undo .
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ref-mpl_update':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log then return .
define variable v-rec-id as recid no-undo .
if not available buf_turnover-group then return .
if v-cntxt-db-num <> 0 then do :
   if buf_turnover-group.tog-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , корректировать ее в текущей БД нельзя !" , buf_turnover-group.tog-db-num ) .
      return .
   end.
end.
if not available buf_tnv-in-turnover-group then return .
v-rec-id = RECID(buf_tnv-in-turnover-group) .
if buf_turnover-group.stts <> 0 then do:
   message "В этой группе изменять оборот нельзя!" view-as alert-box error .
   return .
end.
if buf_tnv-in-turnover-group.stts <> 0 then do:
   message "Оборот удален, изменять оборот нельзя!" view-as alert-box error .
   return .
end.
  run ref/gr-ouprb.w (
      input parparentproc ,
      input 'ИЗМЕНЕНИЕ':U ,
      input buf_turnover-group.tog-db-num ,
      input buf_turnover-group.tog-id     ,
      input buf_turnover-group.name ,
      input-output v-rec-id ) .
  OPEN QUERY BROWSE-2cli FOR EACH buf_tnv-in-turnover-group OF buf_turnover-group      WHERE ( r-status = 2 OR buf_tnv-in-turnover-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION.
  reposition BROWSE-2cli to recid v-rec-id no-error .
  if available buf_tnv-in-turnover-group then
  run ref/h-grtnv.p (buffer buf_tnv-in-turnover-group , input-output v-sec )  .
END.
ON CHOOSE OF b-clients IN FRAME Dialog-Frame
DO:
define buffer next_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define variable v1 as decimal   no-undo .
define variable v2 as decimal   no-undo .
if not available buf_tnv-in-turnover-group then return .
v1 = buf_tnv-in-turnover-group.ttg-summa .
v2 = 999999999999999 .
find first next_tnv-in-turnover-group no-lock where
           next_tnv-in-turnover-group.tog-id     = buf_tnv-in-turnover-group.tog-id and
           next_tnv-in-turnover-group.tog-db-num = buf_tnv-in-turnover-group.tog-db-num and
           next_tnv-in-turnover-group.ttg-summa  > buf_tnv-in-turnover-group.ttg-summa  no-error .
       if available next_tnv-in-turnover-group then  v2 = next_tnv-in-turnover-group.ttg-summa - 1 .
   message "c" v1 "по" v2 view-as alert-box information .
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
   define variable g#log as logical   no-undo .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ref-mpl_update':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log then return .
  if not available buf_turnover-group then return .
  if buf_turnover-group.stts <> 0 then do:
     message "Группа уже удалена"  .
     return .
  end.
  message "Удалять группу " buf_turnover-group.name "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .
  run ref/gr-oudel.p (
      input parparentproc ,
      input buf_turnover-group.tog-db-num ,
      input buf_turnover-group.tog-id      )
      no-error .
 if error-status :error then return no-apply .
 OPEN QUERY BROWSE-1grp FOR EACH buf_turnover-group WHERE ( r-status = 2 OR buf_turnover-group.stts =  r-status ) and ( r-find = no or (buf_turnover-group.tog-db-num = find-db and                   buf_turnover-group.tog-id = find-id )) .
 OPEN QUERY BROWSE-2cli FOR EACH buf_tnv-in-turnover-group OF buf_turnover-group      WHERE ( r-status = 2 OR buf_tnv-in-turnover-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION.
END.
ON CHOOSE OF B-del-2 IN FRAME Dialog-Frame
DO:
   define variable g#log as logical   no-undo .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ref-mpl_update':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log then return .
if not available buf_turnover-group then return .
if v-cntxt-db-num <> 0 then do :
   if buf_turnover-group.tog-db-num <> v-cntxt-db-num then do:
      message substitute(" Группа создана в другой БД (&1) , удалять ее в текущей БД нельзя !" , buf_turnover-group.tog-db-num ) .
      return .
   end.
end.
  if not available buf_tnv-in-turnover-group then return .
  if buf_tnv-in-turnover-group.stts = 1 then return .
  message "Удалять оборот " buf_tnv-in-turnover-group.ttg-summa " из группы " "?"
          view-as alert-box question
          buttons yes-no update v-ok2 as logical.
  if not v-ok2 then return .
        run oio-del (
           input   buf_tnv-in-turnover-group.tog-db-num
          ,input   buf_tnv-in-turnover-group.tog-id
          ,input   buf_tnv-in-turnover-group.ttg-summa
          ,input   v-cntxt-db-num
          ,input   v-cntxt-userid ) .
        run ref/h-grtnv.p (buffer buf_tnv-in-turnover-group , input-output v-sec )  .
   OPEN QUERY BROWSE-2cli FOR EACH buf_tnv-in-turnover-group OF buf_turnover-group      WHERE ( r-status = 2 OR buf_tnv-in-turnover-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION.
END.
ON CHOOSE OF B-history IN FRAME Dialog-Frame
DO:
  if not available buf_turnover-group then return .
  run ref/cgr-tog.w (
      parParentProc ,
      buf_turnover-group.tog-id ,
      buf_turnover-group.tog-db-num ) .
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
    if available buf_turnover-group then do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid12 as character no-undo .
define variable v-num-entry12 as integer   no-undo .
assign
  v-str-recid12 = trim( string( recid( buf_turnover-group ) , "->>>>>>>>>>>9":U ) )
  v-num-entry12 = lookup( v-str-recid12 , p-rec-list )
.
if v-num-entry12 > 0 then do:
  assign
    entry( v-num-entry12, p-rec-list ) = "":U
    p-rec-list = trim( replace( p-rec-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rec-list = p-rec-list + ( if p-rec-list = "":U then "":U else chr(44) ) + v-str-recid12
  .
end.
        g-log = browse-1grp:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          g-log = browse-1grp:select-next-row ().
          apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
      end.
    end.
    apply "display" to browse-1grp in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark-2 IN FRAME Dialog-Frame
DO:
    if available buf_tnv-in-turnover-group then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid14 as character no-undo .
define variable v-num-entry14 as integer   no-undo .
assign
  v-str-recid14 = trim( string( recid( buf_tnv-in-turnover-group ) , "->>>>>>>>>>>9":U ) )
  v-num-entry14 = lookup( v-str-recid14 , v-rec-list-cli )
.
if v-num-entry14 > 0 then do:
  assign
    entry( v-num-entry14, v-rec-list-cli ) = "":U
    v-rec-list-cli = trim( replace( v-rec-list-cli , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    v-rec-list-cli = v-rec-list-cli + ( if v-rec-list-cli = "":U then "":U else chr(44) ) + v-str-recid14
  .
end.
        g-log = browse-2cli:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          g-log = browse-2cli:select-next-row ().
          apply "VALUE-CHANGED" to browse-2cli in frame Dialog-Frame.
      end.
    end.
    apply "entry" to browse-2cli in frame Dialog-Frame.
END.
ON CHOOSE OF B-price-type IN FRAME Dialog-Frame
DO:
  define variable v-recid as character no-undo .
  v-recid = string(RECID (buf_turnover-group )) .
  run ref/typepric.w (
          input parParentProc     ,
          input "mode=tog-id,b-del,b-chg" ,
          input-output v-recid
          ) no-error .
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
if not available buf_turnover-group then return .
  run rep/g-prtnv.p
  ( parParentProc ,
    recid( buf_turnover-group )
  ).
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
    if ( available buf_turnover-group ) AND ( p-rec-list = "" ) then
    p-rec-list = string( recid( buf_turnover-group ) ) .
END.
ON VALUE-CHANGED OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  OPEN QUERY BROWSE-2cli FOR EACH buf_tnv-in-turnover-group OF buf_turnover-group      WHERE ( r-status = 2 OR buf_tnv-in-turnover-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION.
END.
ON VALUE-CHANGED OF R-status IN FRAME Dialog-Frame
DO:
    ASSIGN R-status .
  OPEN QUERY BROWSE-1grp FOR EACH buf_turnover-group WHERE ( r-status = 2 OR buf_turnover-group.stts =  r-status ) and ( r-find = no or (buf_turnover-group.tog-db-num = find-db and                   buf_turnover-group.tog-id = find-id )) .
  OPEN QUERY BROWSE-2cli FOR EACH buf_tnv-in-turnover-group OF buf_turnover-group      WHERE ( r-status = 2 OR buf_tnv-in-turnover-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse browse-1grp :handle
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
run diasize_add_browse in this-procedure
  (input  'HEIGHT':U
  ,input  browse browse-2cli :handle
  ) .
run diasize_init in this-procedure .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   define variable g#log as logical   no-undo .
define variable vss-include-info18 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_ref-mpl_lookup':U
    ,input  'global':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if not g#log then return .
   buf_turnover-group.name:resizable in browse browse-1grp = true .
   buf_turnover-group.name:width  in browse browse-1grp = 20 .
  if p-rec-list <> "" and p-rec-list <> ? then run select_one .
  RUN enable_UI.
  disable
     B-sel      when LOOKUP ("b-sel":U,    p-bttns) = 0
     B-add      when LOOKUP ("b-add":U,    p-bttns) = 0
     B-del      when LOOKUP ("b-del":U,    p-bttns) = 0
     B-add-2    when LOOKUP ("b-add":U,    p-bttns) = 0
     B-del-2    when LOOKUP ("b-del":U,    p-bttns) = 0
     B-chg      when LOOKUP ("b-chg":U,    p-bttns) = 0
     B-chg-2    when LOOKUP ("b-chg":U,    p-bttns) = 0
     B-mark     when LOOKUP ("b-mark":U,   p-bttns) = 0
     B-mark-2   when LOOKUP ("b-mark-2":U, p-bttns) = 0
    with frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY R-status FILL-IN-1
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-sel B-add B-chg B-del B-price-type B-history B-Help B-print
         R-status B-mark-2 B-add-2 B-chg-2 B-del-2 B-mark b-clients BROWSE-1grp
         BROWSE-2cli FILL-IN-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1grp FOR EACH buf_turnover-group WHERE ( r-status = 2 OR buf_turnover-group.stts =  r-status ) and ( r-find = no or (buf_turnover-group.tog-db-num = find-db and                   buf_turnover-group.tog-id = find-id )) .    OPEN QUERY BROWSE-2cli FOR EACH buf_tnv-in-turnover-group OF buf_turnover-group      WHERE ( r-status = 2 OR buf_tnv-in-turnover-group.stts =  r-status )       NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE select_one :
define buffer bufl_turnover-group for ub.turnover-group  .
find first bufl_turnover-group no-lock where recid(bufl_turnover-group) = int(p-rec-list) no-error .
if error-status :error then return .
r-find = true .
find-db = bufl_turnover-group.tog-db-num  .
find-id = bufl_turnover-group.tog-id      .
END PROCEDURE.
