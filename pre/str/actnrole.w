define input  parameter       parparentproc      as widget-handle no-undo .
define input  parameter       p-bttns            as character     no-undo .
define input-output parameter p-context          AS character     no-undo .
define OUTPUT parameter       p-action-role-code as integer       no-undo .
define INPUT-OUTPUT parameter p-rid-list         as character     no-undo .
define INPUT  parameter       p-db-num           as integer       no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник групп прав".
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
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_actntw_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmType       as character
    field itmName       as character
    field itmDesc       as character
    field itmGdsList    as character
    field itmGds        as logical
    field itmGrpList    as character
    field itmGrp        as logical
    field itmSelected   as logical
    field selLeft       as logical
    field selRight      as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
    index tp
        itmType
        itmName
    index sel
        itmSelected
.
define temp-table temp_actntw_itemsSelected no-undo
    field its-key       as integer
    field itm-key       as integer
    field itmExtKey     as character
    field itmGdsList    as character
    field itmGds        as logical
    field itmGrpList    as character
    field itmGrp        as logical
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-actntw2-itm-key    as integer      no-undo.
procedure actntw_clear :
    define buffer buf_temp_actntw_items        for temp_actntw_items.
do
for buf_temp_actntw_items
on error undo, return error
:
    empty temp-table buf_temp_actntw_items.
end.
end procedure.
procedure actntw_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-type as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
define input parameter p-gds       as logical          no-undo.
define input parameter p-grp       as logical          no-undo.
define input parameter p-list      as character        no-undo.
    define buffer buf_temp_actntw_items        for temp_actntw_items.
do
for buf_temp_actntw_items
on error undo, return error
:
    assign
        v-actntw2-itm-key = v-actntw2-itm-key + 1
    .
    create temp_actntw_items.
    assign
        temp_actntw_items.itm-key      = v-actntw2-itm-key
        temp_actntw_items.itmExtKey    = p-ext-key
        temp_actntw_items.itmType      = p-item-type
        temp_actntw_items.itmName      = p-item-name
        temp_actntw_items.itmDesc      = p-item-desc
        temp_actntw_items.itmSelected  = p-selected
        temp_actntw_items.selLeft      = no
        temp_actntw_items.selRight     = no
        temp_actntw_items.itmGds       = p-gds
        temp_actntw_items.itmGrp       = p-grp
        temp_actntw_items.itmGdsList   = IF p-gds THEN p-list ELSE "":U
        temp_actntw_items.itmGrpList   = IF p-grp THEN p-list ELSE "":U
    .
end.
end procedure.
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_onewin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_onewin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-onewin3-itm-key    as integer      no-undo.
procedure onewin_clear :
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    empty temp-table buf_temp_onewin_items.
end.
end procedure.
procedure onewin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    find last buf_temp_onewin_items no-error.
    if available buf_temp_onewin_items then do:
      v-onewin3-itm-key = buf_temp_onewin_items.itm-key.
    end.
    else do:
      v-onewin3-itm-key = 0.
    end.
    assign
        v-onewin3-itm-key = v-onewin3-itm-key + 1
    .
    create buf_temp_onewin_items.
    assign
    buf_temp_onewin_items.itm-key      = v-onewin3-itm-key
    buf_temp_onewin_items.itmExtKey    = p-ext-key
    buf_temp_onewin_items.itmName      = p-item-name
    buf_temp_onewin_items.itmDesc      = p-item-desc
    buf_temp_onewin_items.itmSelected  = p-selected
    .
end.
end procedure.
procedure onewin_create-selection :
define input parameter p-itm-key as integer no-undo .
define input parameter p-itmextkey as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected .
do
on error undo, return error
:
  find last buf_temp_onewin_itemsSelected use-index pi no-error.
  if available buf_temp_onewin_itemsSelected then do:
    v-counter = buf_temp_onewin_itemsSelected.its-key.
  end.
  find first buf_temp_onewin_itemsSelected where
       buf_temp_onewin_itemsSelected.itm-key = p-itm-key no-error.
  if not available buf_temp_onewin_itemsSelected then do:
    create buf_temp_onewin_itemsSelected.
    assign
    buf_temp_onewin_itemsSelected.its-key   = v-counter + 1
    v-counter = v-counter + 1
    buf_temp_onewin_itemsSelected.itm-key   = p-itm-key
    buf_temp_onewin_itemsSelected.itmExtKey = p-itmExtKey
    .
  end.
end.
end procedure.
procedure onewin_check-item :
define input parameter p-ext-key   as character        no-undo.
define output parameter p-exists as logical no-undo .
define buffer buf_temp_onewin_items for temp_onewin_items.
find first buf_temp_onewin_items where
buf_temp_onewin_items.itmExtKey    = p-ext-key no-error.
if available buf_temp_onewin_items then do:
  p-exists = yes.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared stream PrnLibStream.
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream OutStr-html.
define variable v-current-db-num              as integer   no-undo .
define variable v-can-edit-action-role        as logical   no-undo .
define variable v-current-db-num-screen-value as character no-undo .
define variable v-current-context             as character no-undo .
define variable v-on-gbl                      as logical   no-undo.
define variable v-action-role-context         as character no-undo format "x(8)" column-label "Контекст".
define variable v-action-role-item-state      as character no-undo format "x(3)" column-label "Вкл" .
define variable v-action-role-select          as character no-undo format "x(1)" column-label "*" .
DEFINE VARIABLE g#log                         AS LOGICAL   NO-UNDO.
define variable v-ok                          as logical   no-undo .
define temp-table temp_filter-fields no-undo
    field action-role-code as integer
    field record-on        as logical
    index pi is primary unique
    action-role-code
    .
define temp-table temp_actnrole-user no-undo
    field user-id    as character
    field nik        as character
    field lastName   as character
    field firstName  as character
    field secondName as character
    index pi is primary unique
    user-id
    .
define temp-table temp_filter-fields-item no-undo
    field action-item-code as integer
    field record-on        as logical INIT YES
    index pi is primary unique
    action-item-code
    .
FUNCTION get-action-role-context RETURNS CHARACTER
    ( BUFFER buf_action-role FOR action-role )  FORWARD.
FUNCTION get-action-role-item-state RETURNS CHARACTER
    ( BUFFER buf_action-item FOR action-item )  FORWARD.
DEFINE BUTTON b-add
    LABEL "&Добавить"
    SIZE 9 BY 1 TOOLTIP "Добавить группу прав".
DEFINE BUTTON b-chg
    LABEL "&Изменить"
    SIZE 9 BY 1 TOOLTIP "Изменить группу прав".
DEFINE BUTTON b-del
    LABEL "&Удалить"
    SIZE 9 BY 1 TOOLTIP "Удалить группу прав".
DEFINE BUTTON b-filter-item DEFAULT
    LABEL "&ФПоиск"
    SIZE 10 BY 1 TOOLTIP "Поиск с фильтром строки во всех текстовых полях"
    BGCOLOR 8 .
DEFINE BUTTON b-filter-role
    LABEL "Ф&Поиск"
    SIZE 10 BY 1 TOOLTIP "Поиск с фильтрацией строки во всех текстовых полях формы".
DEFINE BUTTON b-help
    LABEL "&Помощь"
    SIZE 10 BY 1
    BGCOLOR 8 .
DEFINE BUTTON b-hist
    LABEL "Печать"
    SIZE 3 BY 1.
DEFINE BUTTON b-mark
    LABEL "&*"
    SIZE 3 BY 1.
DEFINE BUTTON b-print
    LABEL "Печать"
    SIZE 9.63 BY .96.
DEFINE BUTTON b-quit AUTO-END-KEY
    LABEL "&Выход"
    SIZE 10 BY 1
    BGCOLOR 8 .
DEFINE BUTTON b-sel AUTO-GO
    LABEL "Вы&брать"
    SIZE 10 BY 1.
DEFINE BUTTON b-set-current-db
    LABEL "Тек"
    SIZE 5 BY 1 TOOLTIP "Выбрать текущую базу данных".
DEFINE BUTTON b-toggle
    LABEL "&Права"
    SIZE 10 BY 1 TOOLTIP "Изменить список прав, привязанных к группе".
DEFINE BUTTON b-users
    LABEL "&Польз"
    SIZE 9 BY 1 TOOLTIP "Список пользователей с выбранной группой прав".
DEFINE VARIABLE cb-db          AS CHARACTER FORMAT "X(256)":U
    LABEL "БД"
    VIEW-AS COMBO-BOX INNER-LINES 5
    LIST-ITEMS "Item 1"
    DROP-DOWN-LIST
    SIZE 12.63 BY 1 NO-UNDO.
DEFINE VARIABLE item-EDITOR    AS CHARACTER
    VIEW-AS EDITOR SCROLLBAR-VERTICAL
    SIZE 58 BY 1.58 TOOLTIP "описание права"
    FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE role-editor    AS CHARACTER
    VIEW-AS EDITOR SCROLLBAR-VERTICAL
    SIZE 39.63 BY 1.58 TOOLTIP "Описание группы"
    FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE v-filter-item  AS CHARACTER FORMAT "X(256)":U
    VIEW-AS FILL-IN
    SIZE 20.75 BY 1 NO-UNDO.
DEFINE VARIABLE v-filter-role  AS CHARACTER FORMAT "X(40)":U
    VIEW-AS FILL-IN
    SIZE 25 BY 1
    FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE rs-scope       AS INTEGER
    VIEW-AS RADIO-SET HORIZONTAL
    RADIO-BUTTONS
    "Все", 1,
    "Без привязки", 2,
    "Фирма", 3,
    "Объект", 4
    SIZE 40.63 BY .75
    FGCOLOR 4 NO-UNDO.
DEFINE VARIABLE tb-filter-item AS LOGICAL   INITIAL no
    LABEL ""
    VIEW-AS TOGGLE-BOX
    SIZE 2.63 BY .79 TOOLTIP "Снятие поиска с фильтром" NO-UNDO.
DEFINE VARIABLE tb-filter-role AS LOGICAL   INITIAL no
    LABEL ""
    VIEW-AS TOGGLE-BOX
    SIZE 2.63 BY .79 TOOLTIP "Временно отключить фильтрацию" NO-UNDO.
DEFINE QUERY browse-action-item FOR
    action-item,
    temp_filter-fields-item,
    action-group,
    action-role-item SCROLLING.
DEFINE QUERY browse-action-role FOR
    action-role,
    temp_filter-fields SCROLLING.
DEFINE BROWSE browse-action-item
    QUERY browse-action-item DISPLAY
    action-group.action-group-name format "X(14)" column-label "Тема"
    action-item.action-item-name format "X(58)"
    action-item.action-item-id column-label "Идентификатор"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 58 BY 16.75.
DEFINE BROWSE browse-action-role
    QUERY browse-action-role DISPLAY
    mark-string(recid(action-role), p-rid-list) @ v-action-role-select
    get-action-role-context(BUFFER action-role) @ v-action-role-context COLUMN-LABEL "Привязка" format "x(12)"
    action-role.db-num column-label "БД"
    action-role.action-role-name COLUMN-LABEL "Название группы прав"
    action-role.action-role-description
    WITH NO-ROW-MARKERS SEPARATORS SIZE 39.63 BY 16.75 ROW-HEIGHT-CHARS .53.
DEFINE FRAME Dialog-Frame
    b-quit AT ROW 1 COL 1
    b-sel AT ROW 1 COL 11 WIDGET-ID 16
    cb-db AT ROW 1 COL 68.63 COLON-ALIGNED WIDGET-ID 2
    b-set-current-db AT ROW 1 COL 83 WIDGET-ID 4
    b-help AT ROW 1 COL 89.63
    rs-scope AT ROW 1.25 COL 23.63 NO-LABEL WIDGET-ID 42
    b-print AT ROW 1.96 COL 90 WIDGET-ID 70
    b-mark AT ROW 2 COL 1 WIDGET-ID 14
    b-add AT ROW 2 COL 4 WIDGET-ID 6
    b-chg AT ROW 2 COL 13 WIDGET-ID 10
    b-del AT ROW 2 COL 22 WIDGET-ID 8
    b-toggle AT ROW 2 COL 31 WIDGET-ID 12
    b-users AT ROW 2 COL 41 WIDGET-ID 48
    b-hist AT ROW 2 COL 87 WIDGET-ID 74
    b-filter-role AT ROW 3 COL 1 WIDGET-ID 24
    v-filter-role AT ROW 3 COL 10 COLON-ALIGNED NO-LABEL WIDGET-ID 28 NO-TAB-STOP
    tb-filter-role AT ROW 3 COL 38 WIDGET-ID 52
    b-filter-item AT ROW 3 COL 63.63 WIDGET-ID 64 NO-TAB-STOP
    v-filter-item AT ROW 3 COL 71.75 COLON-ALIGNED NO-LABEL WIDGET-ID 66
    tb-filter-item AT ROW 3 COL 95.63 WIDGET-ID 68
    browse-action-role AT ROW 4.25 COL 1 WIDGET-ID 200
    browse-action-item AT ROW 4.25 COL 41.63 WIDGET-ID 300
    role-editor AT ROW 21.25 COL 1 NO-LABEL WIDGET-ID 20
    item-EDITOR AT ROW 21.25 COL 41.63 NO-LABEL WIDGET-ID 22
    SPACE(0.00) SKIP(0.27)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
    TITLE "Группы прав"
    DEFAULT-BUTTON b-quit CANCEL-BUTTON b-quit WIDGET-ID 100.
ASSIGN
    FRAME Dialog-Frame:SCROLLABLE = FALSE
    FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
    b-set-current-db:HIDDEN IN FRAME Dialog-Frame = TRUE.
ASSIGN
    cb-db:HIDDEN IN FRAME Dialog-Frame = TRUE.
ASSIGN
    item-EDITOR:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    role-editor:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    v-filter-item:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ASSIGN
    v-filter-role:READ-ONLY IN FRAME Dialog-Frame = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
    DO:
        DEFINE VARIABLE v-recid AS RECID NO-UNDO.
        run str/actnrold.w ( INPUT parparentproc
            , INPUT FALSE
            , INPUT-OUTPUT v-recid
            ) NO-ERROR.
        IF ERROR-STATUS:ERROR THEN
        DO:
            MESSAGE RETURN-VALUE SKIP
                ERROR-STATUS:GET-MESSAGE(1)
                VIEW-AS ALERT-BOX.
            UNDO, RETURN NO-APPLY.
        END.
        run assign-filter-mark-role in this-procedure ( input v-filter-role ) .
        RUN enable_UI.
        RUN post_enable_UI.
        run set-brw-pos in this-procedure ( input v-recid ).
        run refresh-query-action-item in this-procedure .
    END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
    DO:
        DEFINE VARIABLE v-recid AS RECID   NO-UNDO.
        define variable v-ok    as logical no-undo.
        IF AVAILABLE action-role THEN
        DO:
            ASSIGN
                v-recid = RECID(action-role)
                .
            run str/actnrold.w ( INPUT parparentproc
                , INPUT TRUE
                , INPUT-OUTPUT v-recid
                ) NO-ERROR.
            IF ERROR-STATUS:ERROR THEN
            DO:
                MESSAGE RETURN-VALUE SKIP
                    ERROR-STATUS:GET-MESSAGE(1)
                    VIEW-AS ALERT-BOX.
                UNDO, RETURN NO-APPLY.
            END.
            v-ok = browse-action-role:refresh( )  in frame Dialog-Frame.
        END.
    END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
    DO:
        IF AVAILABLE action-role THEN
        DO:
            RUN delete-action-role IN THIS-PROCEDURE.
            run enable_UI IN THIS-PROCEDURE .
            RUN post_enable_UI IN THIS-PROCEDURE.
        END.
    END.
ON CHOOSE OF b-filter-item IN FRAME Dialog-Frame
    DO:
        define variable v-new-filter as character no-undo.
        define variable v-accepted   as logical   no-undo.
        run gbl/twowinf.w (
            input v-filter-item
            , output v-new-filter
            , output v-accepted
            ).
        if v-accepted = yes
            then
        do:
            assign
                v-filter-item = v-new-filter
                .
            if v-filter-item = "":U
                then
            do:
                assign
                    tb-filter-item            = no
                    tb-filter-item :sensitive = no
                    .
            end.
            else
            do:
                assign
                    tb-filter-item            = yes
                    tb-filter-item :sensitive = yes
                    .
            end.
            display
                v-filter-item
                tb-filter-item
                with frame Dialog-Frame.
            run assign-filter-mark-item IN THIS-PROCEDURE
                ( input v-filter-item
                ) .
            RUN refresh-query-action-item .
            apply "entry":U to browse-action-role.
            apply "VALUE-CHANGED":U to browse-action-role.
        end.
    END.
ON CHOOSE OF b-filter-role IN FRAME Dialog-Frame
    DO:
        define variable v-new-filter as character no-undo.
        define variable v-accepted   as logical   no-undo.
        run gbl/twowinf.w (
            input v-filter-role
            , output v-new-filter
            , output v-accepted
            ).
        if v-accepted = yes
            then
        do:
            assign
                v-filter-role = v-new-filter
                .
            if v-filter-role = "":U
                then
            do:
                assign
                    tb-filter-role            = no
                    tb-filter-role :sensitive = no
                    .
            end.
            else
            do:
                assign
                    tb-filter-role            = yes
                    tb-filter-role :sensitive = yes
                    .
            end.
        end.
if session :set-wait-state( "compiler" ) then.
        run assign-filter-mark-role IN THIS-PROCEDURE
            ( input v-filter-role
            ) .
        run enable_UI IN THIS-PROCEDURE .
        RUN post_enable_UI IN THIS-PROCEDURE.
        apply "VALUE-CHANGED":U to browse-action-role.
if session :set-wait-state( "" ) then.
    END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
    DO:
        define variable rid-list as character no-undo.
        run ref/cactnrole.w (
            INPUT parparentproc
            , INPUT "":U
            , INPUT "one":U
            , OUTPUT  rid-list
            , INPUT ub.action-role.db-num
            , INPUT ub.action-role.action-head-code
            , INPUT ub.action-role.action-role-code
            , input "":U
            ).
    END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
    DO:
        DEFINE VARIABLE v-log AS LOGICAL NO-UNDO .
        IF NOT AVAILABLE action-role THEN RETURN NO-APPLY.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid9 as character no-undo .
define variable v-num-entry9 as integer   no-undo .
assign
  v-str-recid9 = trim( string( recid( action-role ) , "->>>>>>>>>>>9":U ) )
  v-num-entry9 = lookup( v-str-recid9 , p-rid-list )
.
if v-num-entry9 > 0 then do:
  assign
    entry( v-num-entry9, p-rid-list ) = "":U
    p-rid-list = trim( replace( p-rid-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rid-list = p-rid-list + ( if p-rid-list = "":U then "":U else chr(44) ) + v-str-recid9
  .
end.
        v-log = browse-action-role:refresh() IN FRAME Dialog-Frame.
        IF last-event:function <> "MOUSE-SELECT-DBLCLICK" THEN
        DO:
            g#log = browse-action-role:select-next-row ().
            APPLY "ITERATION-CHANGED" TO browse-action-role IN FRAME Dialog-Frame.
        END.
        APPLY "ENTRY" TO browse-action-role IN FRAME Dialog-Frame.
    END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
    DO:
        def var v-prn-ff as char no-undo.
        v-prn-ff = session:temp-directory + "rpt" +  "actnrole.html".
        run waitfram-show in this-procedure ( input "Ждите...").
        output stream OutStr-html to value(v-prn-ff) convert target 'UTF-8'.
        put stream outstr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px;  
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 5px;
                   ~}
          
              </style>
               </head>
                    <body>
                  <table orientation="landscape" name="Группы прав" fit_to_page="true" > 
                    <thead> 
                   <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                <tr class="set_columns">                       
                <td style="width:250px"></td>
                        
                       <td style="width:250px"></td>
                        <td style="width:250px"></td>
                            
        
                 </tr>
        <tr>
            <td colspan="2" style="front-weight: bold; text-align: center;">Список групп прав</td>
        </tr>
        </thead>

        <tbody>
        <tr>
        <th>Привязка</th>
        <th>Наименование</th>
       
        </tr>'  ).
        get first browse-action-role.
        do while available action-role:
            for each  action-role-item no-lock
                where action-role-item.db-num           = action-role.db-num
                and action-role-item.action-head-code = action-role.action-head-code
                and action-role-item.action-role-code = action-role.action-role-code:
                put stream OutStr-html unformatted
                    substitute(
                    '<tr style="height: 50px;">
                  <td text_wrap="true"> &1 </td>
                   <td text_wrap="true"> &2 </td> 
                   </tr> ',
                    get-action-role-context(BUFFER action-role),
                    action-role.action-role-name
                    ).
            end.
            get next browse-action-role.
        end.
        put stream OutStr-html unformatted
            substitute('
            </table>'
            ,chr(123), chr(125)).
        put stream OutStr-html unformatted
            substitute(
            '  <table orientation="landscape" name="Списки прав" fit_to_page="true"> 
                    <thead> 
                   <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                <tr class="set_columns">                       
                <td style="width:250px"></td>
                        
                       <td style="width:250px"></td>
                        <td style="width:250px"></td>
                        <td style="width:250px"></td>  
                        <td style="width:250px"></td>              
       
                 </tr>
        <tr>
            <td colspan="4" style="front-weight: bold; text-align: center;">Список прав</td>
        </tr>
        </thead>

        <tbody>
        <tr>
        <th>Привязка</th>
        <th>Название группы прав</th>
        <th>Тема</th>
        <th>Имя права</th>
        </tr>').
        get first browse-action-role.
        do while available action-role:
            for each  action-role-item no-lock
                where action-role-item.db-num           = action-role.db-num
                and action-role-item.action-head-code = action-role.action-head-code
                and action-role-item.action-role-code = action-role.action-role-code
                ,
                FIRST action-item  where action-role-item.action-item-code = action-item.action-item-code
                NO-LOCK
                ,
                FIRST temp_filter-fields-item
                WHERE temp_filter-fields-item.action-item-code = action-item.action-item-code
                and (    temp_filter-fields-item.record-on = YES
                or tb-filter-item = no
                )
                NO-LOCK
                ,
                FIRST action-group  where action-group.action-head-code  = action-item.action-head-code
                and action-group.action-group-id = action-item.action-group-id no-lock
                :
                put stream OutStr-html unformatted
                    substitute(
                    '<tr style="height: 50px;">
                  <td text_wrap="true"> &1 </td>
                   <td text_wrap="true"> &2 </td>
                   <td text_wrap="true"> &3 </td>
                   <td text_wrap="true"> &4 </td>
                   </tr>
                    
                    ',
                    get-action-role-context(BUFFER action-role),
                    action-role.action-role-name,
                    action-group.action-group-name,
                    action-item.action-item-name
                    ).
            end.
            get next browse-action-role.
        end.
        run waitfram-hide in this-procedure.
                  put stream outstr-html unformatted
                    substitute(
                    '</tbody>
      </body>
      </html>',chr(123), chr(125)
                    ).
        output stream OutStr-html close.
        run prn-lib-reportviewer-report-name in this-procedure (
            input parParentProc
            ,input v-prn-ff
            ).
    end.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
    DO:
        assign
            p-rid-list         = ""
            p-action-role-code = ?
            .
    END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
    DO:
        define variable v-ind         as integer no-undo .
        define variable v-num-entries as integer no-undo .
        if not avail action-role then return no-apply.
        if p-rid-list = "" then
        do:
            p-rid-list = string (recid (action-role)).
        end.
        ASSIGN
            p-action-role-code = action-role.action-role-code
            .
    END.
ON CHOOSE OF b-set-current-db IN FRAME Dialog-Frame
    DO:
        assign
            v-current-db-num    = v-cntxt-db-num
            cb-db :screen-value = v-current-db-num-screen-value
            .
        run can-edit-action-role
            (input  v-current-db-num
            ,output v-can-edit-action-role
            ) .
        run enable_UI IN THIS-PROCEDURE .
        RUN post_enable_UI IN THIS-PROCEDURE.
    END.
ON CHOOSE OF b-toggle IN FRAME Dialog-Frame
    DO:
        IF AVAILABLE action-role THEN
        DO:
            run change-items in this-procedure
                ( input action-role.action-head-code
                , input action-role.db-num
                , input action-role.action-role-code
                , input action-role.action-role-context
                ) no-error.
            if error-status :error
                then
            do:
                message
                    vss-workfile vss-revision vss-description
                    skip(1)
                    skip
                    "Ошибка изменения списка прав"
                    skip return-value
                    skip trim( error-status :get-message( 1 ) )
                    trim( error-status :get-message( 2 ) )
                    trim( error-status :get-message( 3 ) )
                    view-as alert-box error.
                undo, return no-apply.
            end.
            run refresh-query-action-item in this-procedure .
            APPLY "ENTRY" TO browse-action-item IN FRAME Dialog-Frame.
        end.
    END.
ON CHOOSE OF b-users IN FRAME Dialog-Frame
    DO:
        if available action-role
            then
        do:
            run show-users-for-role in this-procedure (
                input action-role.db-num
                , input action-role.action-head-code
                , input action-role.action-role-code
                , input action-role.action-role-name
                ).
        end.
    END.
ON VALUE-CHANGED OF browse-action-item IN FRAME Dialog-Frame
    DO:
        if available action-item then
        do:
            assign
                item-editor = action-item.action-item-description
                .
        end.
        else
        do:
            assign
                item-editor = "":U
                .
        end.
        display
            item-editor
            with frame Dialog-Frame.
    END.
ON MOUSE-SELECT-DBLCLICK OF browse-action-role IN FRAME Dialog-Frame
    DO:
        if (lookup  ( "b-add" , p-bttns) > 0 ) then
        do:
            apply "CHOOSE" to b-chg.
        end.
        else
        do:
            apply "CHOOSE" to b-mark.
        end.
    END.
ON VALUE-CHANGED OF browse-action-role IN FRAME Dialog-Frame
    DO:
        run refresh-query-action-item in this-procedure .
        if available action-role then
        do:
            assign
                role-editor = action-role.action-role-description
                .
            if available action-item then
            do:
                assign
                    item-editor = action-item.action-item-description
                    .
            end.
            else
            do:
                assign
                    item-editor = "":U
                    .
            end.
            display
                item-editor
                with frame Dialog-Frame.
        end.
        else
        do:
            assign
                role-editor = "":U
                .
        end.
        display
            role-editor
            with frame Dialog-Frame.
    END.
ON VALUE-CHANGED OF cb-db IN FRAME Dialog-Frame
    DO:
        assign
            cb-db
            .
        assign
            v-current-db-num = integer(entry(1, cb-db, ' ':U))
            .
        run can-edit-action-role
            (input  v-current-db-num
            ,output v-can-edit-action-role
            ) .
        run enable_UI IN THIS-PROCEDURE .
        RUN post_enable_UI IN THIS-PROCEDURE.
        apply 'entry':U to browse browse-action-role .
    END.
ON VALUE-CHANGED OF rs-scope IN FRAME Dialog-Frame
    DO:
        assign
            rs-scope
            .
        assign
            p-context = entry( rs-scope, substitute( "&1,&2,&3,&4",'All', 'global':U, 'firm':U, 'object':U ) )
            .
        run enable_UI IN THIS-PROCEDURE .
        RUN post_enable_UI IN THIS-PROCEDURE.
        apply 'entry':U to browse browse-action-role .
    END.
ON VALUE-CHANGED OF tb-filter-item IN FRAME Dialog-Frame
    DO:
        assign
            tb-filter-item
            .
        RUN refresh-query-action-item .
        apply "entry":U to browse-action-item.
    END.
ON VALUE-CHANGED OF tb-filter-role IN FRAME Dialog-Frame
    DO:
        assign
            tb-filter-role
            .
        RUN enable_UI.
        RUN post_enable_UI IN THIS-PROCEDURE.
    END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
    THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_actn-lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
IF NOT v-ok then
do:
    message
        "У вас нет прав для просмотра справочника прав"
        view-as alert-box information.
    return.
end.
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
        v-diasize-browse-handle     = browse browse-action-item :handle
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
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame Dialog-Frame anywhere do:
  if b-quit :sensitive then DO: apply "CHOOSE":U to b-quit in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  run refresh-query-action-role in this-procedure .
   run refresh-query-action-item in this-procedure .
    apply "VALUE-CHANGED" to browse-action-item.
end.
define variable vss-include-info18 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run actn-gbl in g#library2
    ( output v-on-gbl
    ) no-error .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
    ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
if p-db-num = 0 then do:
    assign
        v-current-db-num = v-cntxt-db-num
        .
  end.
  else v-current-db-num = p-db-num .
  if v-on-gbl then v-current-db-num = 0.
    run can-edit-action-role
        (input  v-current-db-num
        ,output v-can-edit-action-role
        ) .
    run fill-db-num-list in this-procedure .
    run assign-filter-mark-role IN THIS-PROCEDURE ( input v-filter-role ) .
    run init-filter-item  IN THIS-procedure.
    RUN enable_UI.
    RUN post_enable_UI.
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE add-gds-grp :
    define input parameter p-gds-list as character        no-undo.
    define buffer buf_action-role-item-gds-grp for ub.action-role-item-gds-grp .
    define variable v-count as integer no-undo.
    do
        on error undo, return error
        :
        FOR EACH  buf_action-role-item-gds-grp
            where buf_action-role-item-gds-grp.db-num           = action-role-item.db-num
            AND buf_action-role-item-gds-grp.action-head-code = action-role-item.action-head-code
            AND buf_action-role-item-gds-grp.action-role-code = action-role-item.action-role-code
            AND buf_action-role-item-gds-grp.action-item-code = action-role-item.action-item-code
            exclusive-lock
            :
            IF LOOKUP(STRING(buf_action-role-item-gds-grp.gds-grp-code), p-Gds-List, chr(4)) = 0
                THEN
            DO:
                DELETE buf_action-role-item-gds-grp.
            END.
        END.
        DO v-count = 1 TO NUM-ENTRIES(p-Gds-List, chr(4))
            on error undo, next
            :
            FIND   FIRST buf_action-role-item-gds-grp
                where buf_action-role-item-gds-grp.db-num               = action-role-item.db-num
                AND buf_action-role-item-gds-grp.action-head-code     = action-role-item.action-head-code
                AND buf_action-role-item-gds-grp.action-role-code = action-role-item.action-role-code
                AND buf_action-role-item-gds-grp.action-item-code         = action-role-item.action-item-code
                AND buf_action-role-item-gds-grp.gds-grp-code             = INTEGER(ENTRY(v-count, p-Gds-List, chr(4)))
                no-lock
                no-error
                .
            IF NOT AVAILABLE buf_action-role-item-gds-grp THEN
            DO:
                CREATE buf_action-role-item-gds-grp.
                ASSIGN
                    buf_action-role-item-gds-grp.db-num                = action-role-item.db-num
                    buf_action-role-item-gds-grp.action-head-code      = action-role-item.action-head-code
                    buf_action-role-item-gds-grp.action-role-code      = action-role-item.action-role-code
                    buf_action-role-item-gds-grp.action-item-code      = action-role-item.action-item-code
                    buf_action-role-item-gds-grp.action-role-item-code = action-role-item.action-role-item-code
                    buf_action-role-item-gds-grp.action-item-id        = action-role-item.action-item-id
                    buf_action-role-item-gds-grp.gds-grp-code          = INTEGER(ENTRY(v-count, p-Gds-List, chr(4)))
                    .
            END.
        END.
    end.
END PROCEDURE.
PROCEDURE add-goods :
    define input parameter p-gds-list as character        no-undo.
    define buffer buf_action-role-item-gds for ub.action-role-item-gds .
    define variable v-count as integer no-undo.
    do
        on error undo, return error
        :
        FOR EACH  buf_action-role-item-gds
            where buf_action-role-item-gds.db-num           = action-role-item.db-num
            AND buf_action-role-item-gds.action-head-code = action-role-item.action-head-code
            AND buf_action-role-item-gds.action-role-code = action-role-item.action-role-code
            AND buf_action-role-item-gds.action-item-code = action-role-item.action-item-code
            exclusive-lock
            :
            IF LOOKUP(STRING(buf_action-role-item-gds.gds-code), p-Gds-List, chr(4)) = 0
                THEN
            DO:
                DELETE buf_action-role-item-gds.
            END.
        END.
        DO v-count = 1 TO NUM-ENTRIES(p-Gds-List, chr(4))
            on error undo, next
            :
            FIND FIRST buf_action-role-item-gds
                where buf_action-role-item-gds.db-num            = action-role-item.db-num
                AND buf_action-role-item-gds.action-head-code = action-role-item.action-head-code
                AND buf_action-role-item-gds.action-role-code = action-role-item.action-role-code
                AND buf_action-role-item-gds.action-item-code = action-role-item.action-item-code
                AND buf_action-role-item-gds.gds-code         = INTEGER(ENTRY(v-count, p-Gds-List, chr(4)))
                no-lock
                no-error
                .
            IF NOT AVAILABLE buf_action-role-item-gds THEN
            DO:
                CREATE buf_action-role-item-gds.
                ASSIGN
                    buf_action-role-item-gds.db-num                = action-role-item.db-num
                    buf_action-role-item-gds.action-head-code      = action-role-item.action-head-code
                    buf_action-role-item-gds.action-role-code      = action-role-item.action-role-code
                    buf_action-role-item-gds.action-item-code      = action-role-item.action-item-code
                    buf_action-role-item-gds.action-role-item-code = action-role-item.action-role-item-code
                    buf_action-role-item-gds.action-item-id        = action-role-item.action-item-id
                    buf_action-role-item-gds.gds-code              = INTEGER(ENTRY(v-count, p-Gds-List, chr(4)))
                    .
            END.
        END.
    end.
END PROCEDURE.
PROCEDURE assign-filter-mark-item :
    define input parameter p-name-filter    as character        no-undo.
    define buffer buf_temp_filter-fields-item for temp_filter-fields-item .
    define buffer buf_action-item             for action-item .
    do
        on error undo, return error
        :
        for each buf_action-item no-lock
            :
            find first buf_temp_filter-fields-item
                where buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                no-error.
            if not available buf_temp_filter-fields-item
                then
            do:
                create buf_temp_filter-fields-item.
                assign
                    buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                    buf_temp_filter-fields-item.record-on        = no
                    .
            end.
            if ( p-name-filter = "":U )
                or index( buf_action-item.action-item-name, p-name-filter ) <> 0
                or index( buf_action-item.action-item-description, p-name-filter ) <> 0
                or index( buf_action-item.action-item-id, p-name-filter ) <> 0
                then
            do:
                assign
                    buf_temp_filter-fields-item.record-on = yes
                    .
            end.
            else
            do:
                assign
                    buf_temp_filter-fields-item.record-on = no
                    .
            end.
        end.
    end.
END PROCEDURE.
PROCEDURE assign-filter-mark-role :
    define input parameter p-name-filter    as character        no-undo.
    define buffer buf_action-role        for action-role .
    define buffer buf_temp_filter-fields for temp_filter-fields .
    do
        on error undo, return error
        :
        for each buf_action-role no-lock
            where buf_action-role.db-num              = v-current-db-num
            and   buf_action-role.action-head-code    = 0
            :
            find first buf_temp_filter-fields
                where buf_temp_filter-fields.action-role-code = buf_action-role.action-role-code
                no-error.
            if not available buf_temp_filter-fields
                then
            do:
                create buf_temp_filter-fields.
                assign
                    buf_temp_filter-fields.action-role-code = buf_action-role.action-role-code
                    buf_temp_filter-fields.record-on        = no
                    .
            end.
            if ( p-name-filter = "":U )
                OR index(buf_action-role.action-role-name , p-name-filter ) <> 0
                or index(buf_action-role.action-role-description , p-name-filter ) <> 0
                then
            do:
                assign
                    buf_temp_filter-fields.record-on = yes
                    .
            end.
            else
            do:
                assign
                    buf_temp_filter-fields.record-on = no
                    .
            end.
        end.
    end.
END PROCEDURE.
PROCEDURE can-edit-action-role :
    define input  parameter p-db-num   as integer   no-undo .
    define output parameter p-can-edit as logical   no-undo .
    define buffer buf_db for ub.db .
    do
        on error undo, return error return-value
        :
        find first buf_db no-lock
            where buf_db.db-num = v-current-db-num
            no-error .
        if not available buf_db
            then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Внутренняя ошибка" skip
                "Неизвестный номер БД" v-current-db-num skip
                view-as alert-box error .
            undo, return error return-value .
        end.
        assign
            p-can-edit = (v-current-db-num = v-cntxt-db-num
                    or
                    buf_db.db-key = '':U
                   )
            .
    end.
END PROCEDURE.
PROCEDURE change-items :
    define input parameter p-action-head-code    as integer          no-undo.
    define input parameter p-db-num              as integer          no-undo.
    define input parameter p-action-role-code    as integer          no-undo.
    define input parameter p-action-role-context as character        no-undo.
    DEFINE VARIABLE v-accepted              AS LOGICAL NO-UNDO.
    define variable v-changed               as logical no-undo.
    define variable v-action-item-code      as integer no-undo.
    define variable v-action-role-item-code as integer no-undo .
    define variable v-count                 as integer no-undo .
    define buffer buf_action-item              for ub.action-item .
    define buffer buf_action-role-item         for ub.action-role-item .
    define buffer buf_action-group             for ub.action-group .
    define buffer buf_action-role-item-gds     for ub.action-role-item-gds .
    define buffer buf_action-role-item-gds-grp for ub.action-role-item-gds-grp .
    do for buf_action-item
        , buf_action-role-item
        on error undo, return error
        :
        run actntw_clear in this-procedure.
        each-item_:
        for each  buf_action-item
            where buf_action-item.action-head-code      = p-action-head-code
            and buf_action-item.action-item-context   = p-action-role-context
            no-lock
            on error undo, return error
            :
            find first buf_action-group no-lock
                where buf_action-group.action-head-code  = buf_action-item.action-head-code
                and buf_action-group.action-group-code = buf_action-item.action-group-code
                OR  buf_action-group.action-head-code  = buf_action-item.action-head-code
                and buf_action-group.action-group-id   = buf_action-item.action-group-id
                no-error
                .
            IF NOT AVAILABLE buf_action-group THEN
            DO:
                next each-item_.
            END.
            find first buf_action-role-item no-lock
                where buf_action-role-item.db-num           = p-db-num
                and buf_action-role-item.action-head-code = p-action-head-code
                and buf_action-role-item.action-role-code = p-action-role-code
                and buf_action-role-item.action-item-code = buf_action-item.action-item-code
                no-error
                .
            define variable v-list as character no-undo.
            IF available buf_action-role-item
                THEN
            DO:
                IF ( buf_action-item.action-group-id = "gds":U )
                    THEN
                DO:
                    assign
                        v-list = "":U
                        .
                    FOR EACH  buf_action-role-item-gds
                        where buf_action-role-item-gds.db-num            = p-db-num
                        AND buf_action-role-item-gds.action-head-code = p-action-head-code
                        AND buf_action-role-item-gds.action-role-code = p-action-role-code
                        AND buf_action-role-item-gds.action-item-code = buf_action-item.action-item-code
                        no-lock
                        :
                        assign
                            v-list = IF v-list = "":U THEN STRING(buf_action-role-item-gds.gds-code)
                                          ELSE v-list + chr(4) + STRING(buf_action-role-item-gds.gds-code)
                            .
                    END.
                END.
                IF ( buf_action-item.action-group-id = "gds-grp":U )
                    THEN
                DO:
                    assign
                        v-list = "":U
                        .
                    FOR EACH  buf_action-role-item-gds-grp
                        where buf_action-role-item-gds-grp.db-num           = p-db-num
                        AND buf_action-role-item-gds-grp.action-head-code = p-action-head-code
                        AND buf_action-role-item-gds-grp.action-role-code = p-action-role-code
                        AND buf_action-role-item-gds-grp.action-item-code = buf_action-item.action-item-code
                        no-lock
                        :
                        assign
                            v-list = IF v-list = "":U THEN STRING(buf_action-role-item-gds-grp.gds-grp-code)
                                          ELSE v-list + chr(4) + STRING(buf_action-role-item-gds-grp.gds-grp-code)
                            .
                    END.
                END.
            END.
            run actntw_add-item in this-procedure
                ( input buf_action-item.action-item-code
                , input buf_action-group.action-group-name
                , input buf_action-item.action-item-name
                , input SUBSTITUTE('Тема "&2" &1', string( buf_action-item.action-item-description  ), buf_action-group.action-group-name)
                , input ( available buf_action-role-item )
                , INPUT ( buf_action-item.action-group-id = "gds":U )
                , INPUT ( buf_action-item.action-group-id = "gds-grp":U ) OR ( buf_action-item.action-group-id = "gds":U )
                , INPUT v-list
                ) .
        end.
        run str/actntw.w
            ( input parparentproc
            , input 1
            , input "Добавление прав в группу"
            , input "":U
            , input "&Тест"
            , input  table temp_actntw_items
            , input  p-action-head-code
            , input  p-action-role-code
            , output table temp_actntw_itemsSelected
            , output v-changed
            , output v-accepted
            ) .
        IF NOT v-accepted
            THEN
        DO:
            RETURN.
        END.
if session :set-wait-state( "compiler" ) then.
        IF v-changed then
        do:
            for each  buf_action-item
              where buf_action-item.action-head-code      = p-action-head-code
              and buf_action-item.action-item-context   = p-action-role-context
              no-lock
              on error undo, return error
              :
              for each  buf_action-role-item
                  where buf_action-role-item.db-num            = p-db-num
                  and buf_action-role-item.action-head-code = p-action-head-code
                  and buf_action-role-item.action-role-code = p-action-role-code
                  and buf_action-role-item.action-item-code = buf_action-item.action-item-code
                  exclusive-lock
                  on error undo, return error
                  :
                  find first temp_actntw_itemsSelected
                      where temp_actntw_itemsSelected.itmExtKey = string( buf_action-role-item.action-item-code  )
                      no-error.
                  if not available temp_actntw_itemsSelected
                      then
                  do:
                      delete buf_action-role-item.
                  end.
              end.
            end.
            for each temp_actntw_itemsSelected
                :
                assign
                    v-action-item-code = integer( temp_actntw_itemsSelected.itmExtKey )
         no-error.
                if error-status :error
                    then
                do:
                    message
                        vss-workfile vss-revision vss-description
                        skip(1)
                        skip
                        "Ошибка передачи первичного ключа из двухоконного интерфейса."
                        skip return-value
                        skip trim( error-status :get-message( 1 ) )
                        trim( error-status :get-message( 2 ) )
                        trim( error-status :get-message( 3 ) )
                        view-as alert-box error.
                    undo, return error.
                end.
                find first buf_action-role-item
                    where buf_action-role-item.db-num           = p-db-num
                    and buf_action-role-item.action-head-code = p-action-head-code
                    and buf_action-role-item.action-role-code = p-action-role-code
                    and buf_action-role-item.action-item-code = v-action-item-code
                    exclusive-lock
                    no-error
                    .
                if not available buf_action-role-item
                    then
                do:
                    find first buf_action-item share-lock
                        where buf_action-item.action-head-code = p-action-head-code
                        and buf_action-item.action-item-code = v-action-item-code
                        no-error.
                    if error-status :error
                        then
                    do:
                        message
                            vss-workfile vss-revision vss-description
                            skip(1)
                            skip
                            "Ошибка поиска прав в системе."
                            skip return-value
                            skip trim( error-status :get-message( 1 ) )
                            trim( error-status :get-message( 2 ) )
                            trim( error-status :get-message( 3 ) )
                            view-as alert-box error.
                        undo, return error.
                    end.
                    assign
                        v-action-role-item-code = NEXT-VALUE(s-action-role-item)
                        .
                    create buf_action-role-item.
                    assign
                        buf_action-role-item.db-num                = p-db-num
                        buf_action-role-item.action-head-code      = p-action-head-code
                        buf_action-role-item.action-role-code      = p-action-role-code
                        buf_action-role-item.action-item-code      = v-action-item-code
                        buf_action-role-item.action-item-id        = buf_action-item.action-item-id
                        buf_action-role-item.action-role-item-code = v-action-role-item-code
                        .
                end.
                IF temp_actntw_itemsSelected.itmGds
                    THEN
                DO:
                    FOR EACH  buf_action-role-item-gds
                        where buf_action-role-item-gds.db-num           = buf_action-role-item.db-num
                        AND buf_action-role-item-gds.action-head-code = buf_action-role-item.action-head-code
                        AND buf_action-role-item-gds.action-role-code = buf_action-role-item.action-role-code
                        AND buf_action-role-item-gds.action-item-code = buf_action-role-item.action-item-code
                        exclusive-lock
                        :
                        IF LOOKUP(STRING(buf_action-role-item-gds.gds-code), temp_actntw_itemsSelected.itmGdsList, chr(4)) = 0
                            THEN
                        DO:
                            DELETE buf_action-role-item-gds.
                        END.
                    END.
                    DO v-count = 1 TO NUM-ENTRIES(temp_actntw_itemsSelected.itmGdsList, chr(4))
                        on error undo, next
                        :
                        FIND FIRST buf_action-role-item-gds
                            where buf_action-role-item-gds.db-num           = buf_action-role-item.db-num
                            AND buf_action-role-item-gds.action-head-code = buf_action-role-item.action-head-code
                            AND buf_action-role-item-gds.action-role-code = buf_action-role-item.action-role-code
                            AND buf_action-role-item-gds.action-item-code = buf_action-role-item.action-item-code
                            AND buf_action-role-item-gds.gds-code         = INTEGER(ENTRY(v-count, temp_actntw_itemsSelected.itmGdsList, chr(4)))
                            no-lock
                            no-error
                            .
                        IF NOT AVAILABLE buf_action-role-item-gds THEN
                        DO:
                            CREATE buf_action-role-item-gds.
                            ASSIGN
                                buf_action-role-item-gds.db-num                = buf_action-role-item.db-num
                                buf_action-role-item-gds.action-head-code      = buf_action-role-item.action-head-code
                                buf_action-role-item-gds.action-role-code      = buf_action-role-item.action-role-code
                                buf_action-role-item-gds.action-item-code      = buf_action-role-item.action-item-code
                                buf_action-role-item-gds.action-role-item-code = buf_action-role-item.action-role-item-code
                                buf_action-role-item-gds.action-item-id        = buf_action-role-item.action-item-id
                                buf_action-role-item-gds.gds-code              = INTEGER(ENTRY(v-count, temp_actntw_itemsSelected.itmGdsList, chr(4)))
                                .
                        END.
                    END.
                END.
                IF temp_actntw_itemsSelected.itmGrp
                    THEN
                DO:
                    FOR EACH  buf_action-role-item-gds-grp
                        where buf_action-role-item-gds-grp.db-num           = buf_action-role-item.db-num
                        AND buf_action-role-item-gds-grp.action-head-code = buf_action-role-item.action-head-code
                        AND buf_action-role-item-gds-grp.action-role-code = buf_action-role-item.action-role-code
                        AND buf_action-role-item-gds-grp.action-item-code = buf_action-role-item.action-item-code
                        exclusive-lock
                        :
                        IF LOOKUP(STRING(buf_action-role-item-gds-grp.gds-grp-code), temp_actntw_itemsSelected.itmGrpList, chr(4)) = 0
                            THEN
                        DO:
                            DELETE buf_action-role-item-gds-grp.
                        END.
                    END.
                    DO v-count = 1 TO NUM-ENTRIES(temp_actntw_itemsSelected.itmGrpList, chr(4))
                        on error undo, next
                        :
                        FIND FIRST buf_action-role-item-gds-grp
                            where buf_action-role-item-gds-grp.db-num           = buf_action-role-item.db-num
                            AND buf_action-role-item-gds-grp.action-head-code = buf_action-role-item.action-head-code
                            AND buf_action-role-item-gds-grp.action-role-code = buf_action-role-item.action-role-code
                            AND buf_action-role-item-gds-grp.action-item-code = buf_action-role-item.action-item-code
                            AND buf_action-role-item-gds-grp.gds-grp-code         = INTEGER(ENTRY(v-count, temp_actntw_itemsSelected.itmGrpList, chr(4)))
                            no-lock
                            no-error
                            .
                        IF NOT AVAILABLE buf_action-role-item-gds-grp THEN
                        DO:
                            CREATE buf_action-role-item-gds-grp.
                            ASSIGN
                                buf_action-role-item-gds-grp.db-num                = buf_action-role-item.db-num
                                buf_action-role-item-gds-grp.action-head-code      = buf_action-role-item.action-head-code
                                buf_action-role-item-gds-grp.action-role-code      = buf_action-role-item.action-role-code
                                buf_action-role-item-gds-grp.action-item-code      = buf_action-role-item.action-item-code
                                buf_action-role-item-gds-grp.action-role-item-code = buf_action-role-item.action-role-item-code
                                buf_action-role-item-gds-grp.action-item-id        = buf_action-role-item.action-item-id
                                buf_action-role-item-gds-grp.gds-grp-code          = INTEGER(ENTRY(v-count, temp_actntw_itemsSelected.itmGrpList, chr(4)))
                                .
                        END.
                    END.
                END.
            end.
        end.
if session :set-wait-state( "" ) then.
    end.
END PROCEDURE.
PROCEDURE delete-action-role :
    define buffer buf_user-login-action-role for user-login-action-role.
    define buffer buf_action-role-item       for action-role-item.
    define buffer buf_action-role            for action-role.
    do
        on error undo, return error return-value
        :
        MESSAGE SUBSTITUTE('Удалить группу прав "&1"?', action-role.action-role-name )
            VIEW-AS ALERT-BOX QUESTION
            BUTTONS YES-NO
            UPDATE v-yes AS LOGICAL.
        IF NOT v-yes THEN RETURN ERROR.
        IF NOT CAN-FIND (FIRST buf_action-role-item
            WHERE buf_action-role-item.db-num           = action-role.db-num
            AND buf_action-role-item.action-head-code = action-role.action-head-code
            AND buf_action-role-item.action-role-code = action-role.action-role-code
            no-lock) THEN
        DO:
            FOR EACH buf_user-login-action-role WHERE buf_user-login-action-role.db-num           = action-role.db-num
                AND buf_user-login-action-role.action-head-code = action-role.action-head-code
                AND buf_user-login-action-role.action-role-code = action-role.action-role-code
                EXCLUSIVE-LOCK
                :
                DELETE buf_user-login-action-role.
            END.
        END.
        else
        do:
            IF CAN-FIND( FIRST buf_user-login-action-role WHERE buf_user-login-action-role.db-num           = action-role.db-num
                AND buf_user-login-action-role.action-head-code = action-role.action-head-code
                AND buf_user-login-action-role.action-role-code = action-role.action-role-code
                NO-LoCK) THEN
            DO:
                message
                    "В группе прав присутствуют права и группа выдана пользователям."
                    skip
                    "Удалить группу нельзя"
                    view-as alert-box information.
                RETURN.
            END.
        end.
        FOR EACH buf_action-role-item WHERE buf_action-role-item.db-num           = action-role.db-num
            AND buf_action-role-item.action-head-code = action-role.action-head-code
            AND buf_action-role-item.action-role-code = action-role.action-role-code
            EXCLUSIVE-LOCK
            :
            DELETE buf_action-role-item.
        END.
        find first buf_action-role
            where recid(buf_action-role) = recid(action-role)
            exclusive-lock
            .
        delete buf_action-role.
    end.
END PROCEDURE.
PROCEDURE disable_UI :
    HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
    DISPLAY rs-scope v-filter-role tb-filter-role v-filter-item tb-filter-item
        role-editor item-EDITOR
        WITH FRAME Dialog-Frame.
    ENABLE b-quit b-sel b-help rs-scope b-print b-mark b-add b-chg b-del b-toggle
        b-users b-hist b-filter-role v-filter-role b-filter-item v-filter-item
        browse-action-role browse-action-item role-editor item-EDITOR
        WITH FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    RUN refresh-query-action-item .    RUN refresh-query-action-role IN THIS-PROCEDURE .
END PROCEDURE.
PROCEDURE fill-db-num-list :
    define buffer buf_db for ub.db .
    define variable v-db-num-list as character no-undo .
    do
        on error undo, return error return-value
        :
        assign
            v-db-num-list = '':U
            .
        for each buf_db
            where (v-cntxt-db-num = 0
            or buf_db.db-num = v-cntxt-db-num
            )
            on error undo, return error return-value
            :
            assign
                v-db-num-list = v-db-num-list
                      + (if v-db-num-list <> '':U then ',':U else '':U)
                      + string(buf_db.db-num) + ' ':U + replace(string(buf_db.db-name), ',':U, '':U)
                .
            if buf_db.db-num = v-cntxt-db-num
                then
            do:
                assign
                    v-current-db-num-screen-value = string(buf_db.db-num) + ' ':U + replace(string(buf_db.db-name), ',':U, '':U)
                    .
            end.
        end.
        do with frame Dialog-Frame
            :
            assign
                cb-db :list-items   = v-db-num-list
                cb-db :screen-value = v-current-db-num-screen-value
                .
        end.
    end.
END PROCEDURE.
PROCEDURE local-open-query-action-item :
    do
        with frame Dialog-Frame
        on error undo, return error return-value
        :
        if available action-role
            then
        do:
            IF tb-filter-item
                THEN
            DO:
                assign
                    v-filter-item :bgcolor = RED_COLOR
                    .
            END.
            ELSE
            DO:
                assign
                    v-filter-item :bgcolor = GREY_COLOR
                    .
            END.
            open query browse-action-item
                for each action-item
                where action-item.action-head-code = 0
                and action-item.action-item-context = action-role.action-role-context
                NO-LOCK
                ,
                FIRST temp_filter-fields-item
                WHERE temp_filter-fields-item.action-item-code = action-item.action-item-code
                and (    temp_filter-fields-item.record-on = YES
                or tb-filter-item = no
                )
                NO-LOCK
                ,
                FIRST action-group
                where action-group.action-head-code  = action-item.action-head-code
                and action-group.action-group-id = action-item.action-group-id
                NO-LOCK
                ,
                first action-role-item no-lock
                where action-role-item.db-num           = action-role.db-num
                and action-role-item.action-head-code = action-role.action-head-code
                and action-role-item.action-role-code = action-role.action-role-code
                and action-role-item.action-item-code = action-item.action-item-code
                BY action-item.action-head-code
                by action-group.action-group-name
                BY action-item.action-item-context
                BY action-item.action-group-id
                BY action-item.action-item-name
                indexed-reposition .
        end.
        else
        do:
            open query browse-action-item
                for each action-item
                where action-item.action-head-code = 0
                and action-item.action-item-context = '':U
                no-lock ,
                FIRST temp_filter-fields-item
                WHERE temp_filter-fields-item.action-item-code = action-item.action-item-code
                and temp_filter-fields-item.record-on = YES
                NO-LOCK
                ,
                FIRST action-group
                where action-group.action-head-code  = action-item.action-head-code
                and action-group.action-group-code = action-item.action-group-code
                no-lock,
                first action-role-item no-lock
                where action-role-item.db-num           = action-role.db-num
                and action-role-item.action-head-code = action-role.action-head-code
                and action-role-item.action-role-code = action-role.action-role-code
                and action-role-item.action-item-code = action-item.action-item-code
                indexed-reposition .
        end.
    end.
END PROCEDURE.
PROCEDURE local-open-query-action-role :
  define variable v-num-db    as integer      no-undo.
    do
        with frame Dialog-Frame
        on error undo, return error return-value
        :
        IF tb-filter-role
            THEN
        DO:
            assign
                v-filter-role :bgcolor = RED_COLOR
                .
        END.
        ELSE
        DO:
            assign
                v-filter-role :bgcolor = GREY_COLOR
                .
        END.
        v-num-db = if v-on-gbl then 0
                   else v-current-db-num
        .
        case p-context:
            WHEN 'global':U OR
            WHEN 'firm':U   OR
            WHEN 'object':U THEN
                DO:
                    open query browse-action-role
                        for each  action-role no-lock
                        where action-role.db-num            = v-num-db
                        and action-role.action-head-code    = 0
                        and action-role.action-role-context = p-context
                        , first temp_filter-fields
                        where temp_filter-fields.action-role-code  = action-role.action-role-code
                        and (     temp_filter-fields.record-on     = yes
                        or tb-filter-role = no
                        )
                        by action-role.action-role-name
                        indexed-reposition .
                END.
            OTHERWISE
            DO:
                open query browse-action-role
                    for each action-role no-lock
                    where action-role.db-num                = v-num-db
                    and action-role.action-head-code        = 0
                    , first temp_filter-fields
                    where temp_filter-fields.action-role-code = action-role.action-role-code
                    and (     temp_filter-fields.record-on    = yes
                    or tb-filter-role = no
                    )
                    by action-role.action-role-context
                    by action-role.action-role-name
                    indexed-reposition .
            END.
        END.
    end.
END PROCEDURE.
PROCEDURE post_enable_UI :
    DISABLE
        b-quit
        b-sel
        b-help
        b-mark
        b-add
        b-chg
        b-del
        rs-scope
        b-toggle
        browse-action-role browse-action-item
        WITH FRAME Dialog-Frame.
    ENABLE
        b-quit
        b-sel
        WHEN  (lookup  ( "b-sel" , p-bttns) > 0 )
        b-help
        b-mark
        WHEN  (lookup  ( "b-mark" , p-bttns) > 0 )
        b-add
        WHEN  (lookup  ( "b-add" , p-bttns) > 0 )
        b-chg
        WHEN  (lookup  ( "b-add" , p-bttns) > 0 )
        b-del
        WHEN  (lookup  ( "b-add" , p-bttns) > 0 )
        rs-scope
        WHEN  (lookup  ( "rs-scope" , p-bttns) > 0 )
        b-toggle
        WHEN  (lookup  ( "b-add" , p-bttns) > 0 )
        browse-action-role browse-action-item
        WITH FRAME Dialog-Frame.
define variable vss-include-info19 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_actn-update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  FALSE
    ,output v-ok
    )  .
end.
    if v-ok = FALSE or
      (v-on-gbl and v-cntxt-db-num <> 0)
        then
    do:
        disable
            b-add
            b-chg
            b-del
            b-toggle
            WITH FRAME Dialog-Frame.
    end.
    VIEW FRAME Dialog-Frame.
    RUN refresh-query-action-item .    RUN refresh-query-action-role IN THIS-PROCEDURE .
END PROCEDURE.
PROCEDURE procedure-get-action-role-context :
    define input  parameter p-action-context as character no-undo .
    define output parameter p-action-name    as character no-undo .
    do
        on error undo, return error return-value
        :
        case p-action-context
            :
            when 'global':U
            then
                do:
                    assign
                        p-action-name = "Без привязки"
                        .
                end.
            when 'firm':U
            then
                do:
                    assign
                        p-action-name = "фирма"
                        .
                end.
            when 'object':U
            then
                do:
                    assign
                        p-action-name = "объект"
                        .
                end.
            otherwise
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Незвестное значение контекста" skip
                    "p-action-context" p-action-context skip
                    view-as alert-box error .
            end.
        end case .
    end.
END PROCEDURE.
PROCEDURE procedure-get-action-role-item-state :
    define input  parameter p-action-item-code       as integer   no-undo .
    define output parameter p-action-role-item-state as character no-undo .
    define buffer buf_action-role-item for ub.action-role-item .
    do
        on error undo, return error return-value
        :
        if available action-role
            then
        do:
            find first buf_action-role-item no-lock
                where buf_action-role-item.db-num           = action-role.db-num
                and buf_action-role-item.action-head-code = action-role.action-head-code
                and buf_action-role-item.action-role-code = action-role.action-role-code
                and buf_action-role-item.action-item-code = p-action-item-code
                no-error .
            if available buf_action-role-item
                then
            do:
                assign
                    p-action-role-item-state = '*':U
                    .
            end.
            else
            do:
                assign
                    p-action-role-item-state = '':U
                    .
            end.
        end.
    end.
END PROCEDURE.
PROCEDURE refresh-query-action-item :
    do
        on error undo, return error return-value
        :
        run local-open-query-action-item in this-procedure .
        if available action-item then
        do:
            assign
                item-editor = action-item.action-item-description
                .
            display
                item-editor
                with frame Dialog-Frame.
        end.
    end.
END PROCEDURE.
PROCEDURE refresh-query-action-role :
    do
        on error undo, return error return-value
        :
        run local-open-query-action-role in this-procedure .
        if available action-role then
        do:
            assign
                role-editor = action-role.action-role-description
                .
            display
                role-editor
                with frame Dialog-Frame.
        end.
        run refresh-query-action-item in this-procedure .
    end.
END PROCEDURE.
PROCEDURE set-brw-pos :
    define input parameter p-recid        as integer no-undo.
    do
        on error undo, return error return-value
        :
        if p-recid <> ? then
        do:
            reposition browse-action-role to recid p-recid.
        end.
    end.
END PROCEDURE.
PROCEDURE show-users-for-role :
    define input parameter p-db-num             as integer          no-undo.
    define input parameter p-action-head-code   as integer          no-undo.
    define input parameter p-action-role-code   as integer          no-undo.
    define input parameter p-action-role-name   as character        no-undo.
    define variable v-accepted    as logical   no-undo.
    define variable v-cur-ext-key as character no-undo.
    define buffer buf_user-login-action-role for user-login-action-role.
    define buffer buf_temp_actnrole-user     for temp_actnrole-user.
    define buffer buf_user-account           for user-account.
    define buffer buf_user-login             for user-login.
    do
        for buf_user-login-action-role
        , buf_temp_actnrole-user
        , buf_user-account
        , buf_user-login
        on error undo, return error
        :
        run onewin_clear in this-procedure.
        empty temp-table buf_temp_actnrole-user.
        for each buf_user-login-action-role no-lock
            where buf_user-login-action-role.db-num              = p-db-num
            and buf_user-login-action-role.action-head-code    = p-action-head-code
            and buf_user-login-action-role.action-role-code    = p-action-role-code
            use-index ie03
            on error undo, return error
            :
            find first buf_temp_actnrole-user
                where buf_temp_actnrole-user.user-id = buf_user-login-action-role.user-id
                no-error.
            if not available buf_temp_actnrole-user
                then
            do:
                create buf_temp_actnrole-user.
                assign
                    buf_temp_actnrole-user.user-id = buf_user-login-action-role.user-id
                    .
                find first buf_user-account no-lock
                    where buf_user-account.user-id = buf_user-login-action-role.user-id
                    .
                assign
                    buf_temp_actnrole-user.nik        = buf_user-account.nik
                    buf_temp_actnrole-user.lastName   = buf_user-account.last-name
                    buf_temp_actnrole-user.firstName  = buf_user-account.first-name
                    buf_temp_actnrole-user.secondName = buf_user-account.second-name
                    .
            end.
        end.
        for each buf_temp_actnrole-user
            on error undo, return error
            :
            run onewin_add-item in this-procedure (
                input buf_temp_actnrole-user.user-id
                , input ( if buf_temp_actnrole-user.nik = "":U then buf_temp_actnrole-user.lastName else buf_temp_actnrole-user.nik )
                , input substitute( "&1 &2 &3", buf_temp_actnrole-user.lastName, buf_temp_actnrole-user.firstName, buf_temp_actnrole-user.secondName )
                , input no
                ).
        end.
        run gbl/onewin.w (
            input parparentproc
            , input 0
            , input substitute( "Список пользователей для группы прав < &1 >", p-action-role-name )
            , input "":U
            , input "&Тест"
            , input table temp_onewin_items
            , output table temp_onewin_itemsSelected
            , output v-cur-ext-key
            , output v-accepted
            ).
    end.
END PROCEDURE.
PROCEDURE show-users-for-role-item :
    define input parameter p-db-num             as integer          no-undo.
    define input parameter p-action-head-code   as integer          no-undo.
    define input parameter p-action-item-code   as integer          no-undo.
    define input parameter p-action-item-name   as character        no-undo.
    define variable v-accepted    as logical   no-undo.
    define variable v-cur-ext-key as character no-undo.
    define buffer buf_action-role-item       for action-role-item.
    define buffer buf_user-login-action-role for user-login-action-role.
    define buffer buf_temp_actnrole-user     for temp_actnrole-user.
    define buffer buf_user-account           for user-account.
    define buffer buf_user-login             for user-login.
    do
        for buf_action-role-item
        , buf_user-login-action-role
        , buf_temp_actnrole-user
        , buf_user-account
        , buf_user-login
        on error undo, return error
        :
        run onewin_clear in this-procedure.
        empty temp-table buf_temp_actnrole-user.
        for each buf_action-role-item no-lock
            where buf_action-role-item.db-num           = p-db-num
            and buf_action-role-item.action-head-code = p-action-head-code
            and buf_action-role-item.action-item-code = p-action-item-code
            on error undo, return error
            :
            for each buf_user-login-action-role no-lock
                where buf_user-login-action-role.db-num              = buf_action-role-item.db-num
                and buf_user-login-action-role.action-head-code    = buf_action-role-item.action-head-code
                and buf_user-login-action-role.action-role-code    = buf_action-role-item.action-role-code
                use-index ie03
                on error undo, return error
                :
                find first buf_temp_actnrole-user
                    where buf_temp_actnrole-user.user-id = buf_user-login-action-role.user-id
                    no-error.
                if not available buf_temp_actnrole-user
                    then
                do:
                    create buf_temp_actnrole-user.
                    assign
                        buf_temp_actnrole-user.user-id = buf_user-login-action-role.user-id
                        .
                    find first buf_user-account no-lock
                        where buf_user-account.user-id = buf_user-login-action-role.user-id
                        .
                    assign
                        buf_temp_actnrole-user.nik        = buf_user-account.nik
                        buf_temp_actnrole-user.lastName   = buf_user-account.last-name
                        buf_temp_actnrole-user.firstName  = buf_user-account.first-name
                        buf_temp_actnrole-user.secondName = buf_user-account.second-name
                        .
                end.
            end.
        end.
        for each buf_temp_actnrole-user
            on error undo, return error
            :
            run onewin_add-item in this-procedure (
                input buf_temp_actnrole-user.user-id
                , input ( if buf_temp_actnrole-user.nik = "":U
                then buf_temp_actnrole-user.lastName else buf_temp_actnrole-user.nik )
                , input substitute( "&1 &2 &3 (&4)"
                , buf_temp_actnrole-user.lastName
                , buf_temp_actnrole-user.firstName
                , buf_temp_actnrole-user.secondName
                , buf_temp_actnrole-user.user-id )
                , input no
                ).
        end.
        run gbl/onewin.w (
            input parparentproc
            , input 0
            , input substitute( "Список пользователей для права < &1 >", p-action-item-name )
            , input "":U
            , input "&Тест"
            , input table temp_onewin_items
            , output table temp_onewin_itemsSelected
            , output v-cur-ext-key
            , output v-accepted
            ).
    end.
END PROCEDURE.
procedure init-filter-item :
    do
        on error undo, return error
        :
        define buffer buf_action-item             for action-item .
        define buffer buf_temp_filter-fields-item for temp_filter-fields-item .
        for each buf_action-item no-lock
            :
            find first buf_temp_filter-fields-item
                where buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                no-error.
            if not available buf_temp_filter-fields-item
                then
            do:
                create buf_temp_filter-fields-item.
                assign
                    buf_temp_filter-fields-item.action-item-code = buf_action-item.action-item-code
                    buf_temp_filter-fields-item.record-on        = no
                    .
            end.
        END.
    end.
end procedure.
FUNCTION get-action-role-context RETURNS CHARACTER
    ( BUFFER buf_action-role FOR action-role ) :
    define variable v-return-value as character no-undo .
    run procedure-get-action-role-context in this-procedure
        (input  buf_action-role.action-role-context
        ,output v-return-value
        ) .
    return v-return-value .
END FUNCTION.
FUNCTION get-action-role-item-state RETURNS CHARACTER
    ( BUFFER buf_action-item FOR action-item ) :
    define variable v-return-value as character no-undo .
    run procedure-get-action-role-item-state in this-procedure
        (input  buf_action-item.action-item-code
        ,output v-return-value
        ) .
    return v-return-value .
END FUNCTION.
