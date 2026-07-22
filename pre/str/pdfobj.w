DEFINE BUFFER buf_price-doc FOR ub.price-doc.
DEFINE BUFFER buf_price-doc-forming FOR ub.price-doc-forming.
DEFINE NEW SHARED BUFFER buf_price-list-type FOR ub.price-list-type.
define input  parameter parParentProc as handle no-undo .
define input  parameter p-mode  as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-plt-id as int no-undo .
define input  parameter p-plt-db-num as int no-undo .
define input  parameter p-bttns as character no-undo .
define input-output parameter  p-rec-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список документов назначения цены".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table x_obj-group no-undo like ub.clients  .
define temp-table x_grp-obj-price no-undo like ub.grp-obj-price .
procedure metod-gop-obj :
  do
  on error undo, return error return-value
  :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-gop-id       as integer   no-undo .
define input  parameter p-gop-db-num   as integer   no-undo .
define buffer buf1_clients for ub.clients  .
define buffer buf_db-grp-obj-price   for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price for ub.host-grp-obj-price  .
define buffer buf_obj-grp-obj-price  for ub.obj-grp-obj-price  .
for each  x_obj-group : delete x_obj-group. end.
if p-gop-id = 0 or p-gop-id = ?  then do:
   if p-cntxt-db-num = 0  then do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  )
                and
                buf1_clients.db-num >= 0  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
   else do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  ) and
                 buf1_clients.db-num = p-cntxt-db-num  and
                 buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
end.
else do:
      for each buf_db-grp-obj-price  where
              buf_db-grp-obj-price.gop-id     = p-gop-id and
              buf_db-grp-obj-price.gop-db-num = p-gop-db-num and
              buf_db-grp-obj-price.stts = 0  no-lock :
        for each buf1_clients no-lock where
               (buf1_clients.obj-type = 'маг':U  or
                buf1_clients.obj-type = 'скл':U  ) and
                buf1_clients.db-num = buf_db-grp-obj-price.dgo-db-num  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
      end.
    for each buf_host-grp-obj-price where
            buf_host-grp-obj-price.gop-id     = p-gop-id and
            buf_host-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_host-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
             (buf1_clients.obj-type = 'маг':U  or
              buf1_clients.obj-type = 'скл':U  ) and
              buf1_clients.host-code = buf_host-grp-obj-price.host-code and
              buf1_clients.stts = 0
              :
          find first x_obj-group no-lock  where
                    x_obj-group.obj-code   = buf1_clients.obj-code and
                    x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
    for each buf_obj-grp-obj-price where
            buf_obj-grp-obj-price.gop-id     = p-gop-id and
            buf_obj-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_obj-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
                buf1_clients.obj-type = buf_obj-grp-obj-price.obj-type and
                buf1_clients.obj-code = buf_obj-grp-obj-price.obj-code and
                buf1_clients.stts     = 0
                :
          find first  x_obj-group no-lock  where
                      x_obj-group.obj-code   = buf1_clients.obj-code and
                      x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
end.
end.
end procedure.
procedure metod-obj-in-gop :
define input  parameter p-curr-db-num as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_grp-obj-price for ub.grp-obj-price  .
  do
  on error undo, return error return-value
  :
    empty temp-table x_grp-obj-price.
    for each buf_grp-obj-price where
             buf_grp-obj-price.stts = 0
             no-lock :
               run metod-gop-obj (p-curr-db-num , buf_grp-obj-price.gop-id ,buf_grp-obj-price.gop-db-num) .
               for each x_obj-group where
                        x_obj-group.obj-type = p-obj-type and
                        x_obj-group.obj-code = p-obj-code :
                    create  x_grp-obj-price.
                    buffer-copy buf_grp-obj-price to x_grp-obj-price .
               end.
    end.
  end.
end procedure.
procedure metod-delobj-usr :
define input  parameter p-pdf-id  as integer   no-undo .
define input  parameter p-pdf-db  as integer   no-undo .
define input  parameter p-plt-id  as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
for each buf_price-doc-forming-attr no-lock  where
         buf_price-doc-forming-attr.pdf-id =     p-pdf-id and
         buf_price-doc-forming-attr.pdf-db =     p-pdf-db and
         buf_price-doc-forming-attr.plt-id =     p-plt-id and
         buf_price-doc-forming-attr.plt-db-num = p-plt-db-num and
         buf_price-doc-forming-attr.attr-code begins "obj" :
   for each x_obj-group  where
            x_obj-group.obj-type = substring(buf_price-doc-forming-attr.attr-code,4,3) and
            x_obj-group.obj-code = int(substring(buf_price-doc-forming-attr.attr-code,7,20)) :
     delete x_obj-group.
   end.
end.
  if not can-find (first x_obj-group) then do:
     return "nullobj" .
  end.
end.
end procedure.
procedure metod-obj-pdf :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-pdf-id     like ub.price-doc-forming.pdf-id   no-undo .
define input  parameter p-pdf-db-num like ub.price-doc-forming.pdf-db   no-undo .
define input  parameter p-plt-id     like ub.price-doc-forming.plt-id   no-undo .
define input  parameter p-plt-db-num like ub.price-doc-forming.plt-db-num  no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
  do
  on error undo, return error return-value
  :
 for each  x_obj-group : delete x_obj-group. end.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = p-plt-id and
            buf_price-list-type.plt-db-num = p-plt-db-num no-error .
if error-status :error then return error return-value .
 find first buf_price-doc-forming no-lock where
            buf_price-doc-forming.plt-id     = p-plt-id and
            buf_price-doc-forming.plt-db-num = p-plt-db-num and
            buf_price-doc-forming.pdf-id     = p-pdf-id and
            buf_price-doc-forming.pdf-db     = p-pdf-db-num
            no-error .
if error-status :error then return error return-value .
  run metod-gop-obj in this-procedure (
      p-cntxt-db-num,
      buf_price-list-type.gop-id ,
      buf_price-list-type.gop-db-num
      ) no-error .
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) no-error .
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure price-doc-forming-DELETE :
define input  parameter p-plt-db-num       as integer   no-undo .
define input  parameter p-plt-id           as integer   no-undo .
define input  parameter p-pdf-db-num       as integer   no-undo .
define input  parameter p-pdf-id           as integer   no-undo .
define input  parameter p-db-num-usr       as integer   no-undo .
define input  parameter p-userid           as character no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-value-character as character no-undo .
define variable v-date-close-period as date      no-undo .
define variable v-value-decimal as decimal   no-undo .
define variable v-value-integer as integer   no-undo .
define variable v-value-logical as logical   no-undo .
define variable v-value-type as character no-undo .
define variable v-ask  as logical   no-undo init false .
  do
  on error undo, return error return-value
  :
if p-pdf-db-num <> p-db-num-usr then do:
   message "Нельзя удалять ДНЦ на чужой БД !" view-as alert-box error .
   return .
end.
find first ub.price-doc-forming no-lock  where
        ub.price-doc-forming.pdf-db       = p-pdf-db-num  and
        ub.price-doc-forming.pdf-id       = p-pdf-id      and
        ub.price-doc-forming.plt-db-num   = p-plt-db-num  and
        ub.price-doc-forming.plt-id       = p-plt-id
        no-error .
if  ub.price-doc-forming.STTS = integer('1':U) then do:
   message "ДНЦ уже удален !" view-as alert-box error .
   return .
end.
if  ub.price-doc-forming.STTS = integer('4':U) then do:
   message "ДНЦ в статусе ГОТОВ удалять нельзя !" view-as alert-box error .
   return .
end.
if  ub.price-doc-forming.STTS = integer('3':U) then do:
find first ub.price-doc-forming exclusive-lock  where
        ub.price-doc-forming.pdf-db       = p-pdf-db-num  and
        ub.price-doc-forming.pdf-id       = p-pdf-id      and
        ub.price-doc-forming.plt-db-num   = p-plt-db-num  and
        ub.price-doc-forming.plt-id       = p-plt-id
        no-error .
 empty temp-table x_obj-group.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id    =  ub.price-doc-forming.plt-id and
            buf_price-list-type.plt-db-num = ub.price-doc-forming.plt-db-num no-error .
  run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf_price-list-type.gop-id , buf_price-list-type.gop-db-num) .
  run metod-delobj-usr (
    ub.price-doc-forming.pdf-id  ,
    ub.price-doc-forming.pdf-db ,
    ub.price-doc-forming.plt-id    ,
    ub.price-doc-forming.plt-db-num
    ).
 for each x_obj-group :
  run adm/shattri.p (
       input "get":U
      ,input x_obj-group.obj-type
      ,input x_obj-group.obj-code
      ,input 'nakl_par':U
      ,input  "date-close-period"
      ,output v-value-character
      ,output v-date-close-period
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  if error-status :error then v-date-close-period = date('').
      if v-date-close-period <> date('') then do:
          if ub.price-doc-forming.sys-date < v-date-close-period
          then do:
            message  substitute(
              "Дата закрытия ДНЦ &1 более ранняя, чем дата закрытия периода &2
              Дата закрытия документа  &3 &2
              Дата закрытия периода    &4 &2
              Объект &5 &6 "
              ,
              ub.price-doc-forming.pdf-id  ,
              chr(10)  ,
              string ( ub.price-doc-forming.sys-date , "99/99/9999" ) ,
              string ( v-date-close-period,   "99/99/9999") ,
                        x_obj-group.obj-type ,
                        x_obj-group.obj-code  ) view-as alert-box information .
              return.
          end.
      end.
  end.
    if available ub.price-doc-forming then do :
          ub.price-doc-forming.stts = integer('1':U) .
          release ub.price-doc-forming.
          find first ub.price-doc-forming no-lock  where
                  ub.price-doc-forming.pdf-db       = p-pdf-db-num  and
                  ub.price-doc-forming.pdf-id       = p-pdf-id      and
                  ub.price-doc-forming.plt-db-num   = p-plt-db-num  and
                  ub.price-doc-forming.plt-id       = p-plt-id
                  no-error .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run a-nwspdf in g#library2
  (input  ub.price-doc-forming.plt-id
  ,input  ub.price-doc-forming.plt-db-num
  ,input  ub.price-doc-forming.pdf-id
  ,input  ub.price-doc-forming.pdf-db
  ,output v-ask
  )  .
          if v-ask then do:
            run str/diallog.w
                    ( input parparentproc
                    , input this-procedure
                    , input 'str/sendpdfr.p':U
                    , input ("D":U + chr(4) +
                            string(ub.price-doc-forming.plt-id) + chr(4)  +
                            string(ub.price-doc-forming.plt-db-num) + chr(4) +
                            string(ub.price-doc-forming.pdf-id) + chr(4)  +
                            string(ub.price-doc-forming.pdf-db)
                            )
                    , input yes
                    , input '':U
                    , input '') no-error .
                    if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "str/sendpdfr.p"
                      view-as alert-box error
                    .
                    end.
          end.
    end.
end.
if  ub.price-doc-forming.STTS = integer('0':U) then do:
find first ub.price-doc-forming exclusive-lock  where
        ub.price-doc-forming.pdf-db       = p-pdf-db-num  and
        ub.price-doc-forming.pdf-id       = p-pdf-id      and
        ub.price-doc-forming.plt-db-num   = p-plt-db-num  and
        ub.price-doc-forming.plt-id       = p-plt-id
        no-error .
    if available ub.price-doc-forming then do :
       delete ub.price-doc-forming.
    end.
end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-obj-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-obj.node-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-min-increase like ub.gds-grp-obj.min-increase  no-undo.
define input parameter p-max-increase like ub.gds-grp-obj.max-increase  no-undo.
define input parameter p-increase-pc like ub.gds-grp-obj.increase-pc  no-undo.
define input parameter p-calc-method like ub.gds-grp-obj.calc-method no-undo .
define input parameter p-round-method like ub.gds-grp-obj.round-method no-undo .
define input parameter p-round-coef like ub.gds-grp-obj.round-coef no-undo .
define input parameter p-cli-type   like ub.clients.obj-type            no-undo.
define input parameter p-cli-code   like ub.clients.obj-code            no-undo.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
    find first buf_gds-grp-obj exclusive-lock
         where buf_gds-grp-obj.node-code  = p-node-code
           and buf_gds-grp-obj.host-code  = p-host-code
           and buf_gds-grp-obj.obj-type   = p-obj-type
           and buf_gds-grp-obj.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-obj
    then do:
        create buf_gds-grp-obj.
        assign
                buf_gds-grp-obj.node-code  = p-node-code
                buf_gds-grp-obj.host-code  = p-host-code
                buf_gds-grp-obj.obj-type   = p-obj-type
                buf_gds-grp-obj.obj-code   = p-obj-code
        .
    end.
    assign
    buf_gds-grp-obj.min-increase = p-min-increase
    buf_gds-grp-obj.max-increase = p-max-increase
    buf_gds-grp-obj.increase-pc = p-increase-pc
    buf_gds-grp-obj.calc-method = p-calc-method
    buf_gds-grp-obj.round-method = p-round-method
    buf_gds-grp-obj.round-coef = p-round-coef
    buf_gds-grp-obj.cli-type   = p-cli-type
    buf_gds-grp-obj.cli-code   = p-cli-code
    .
end.
end procedure.
procedure grp-obj-margin-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-min-value as decimal      no-undo init ?.
define output parameter p-max-value as decimal      no-undo init ?.
define output parameter p-increase-pc as decimal      no-undo init ?.
define output parameter p-round-method as character no-undo init "":U.
define output parameter p-base as decimal no-undo init ?.
define output parameter p-range-margin     as integer      no-undo.
define output parameter p-exists-margin    as logical      no-undo.
define output parameter p-range-increase     as integer      no-undo.
define output parameter p-exists-increase    as logical      no-undo.
define output parameter p-range-rmethod     as integer no-undo .
define output parameter p-exists-rmethod    as logical no-undo .
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-margin-found as logical no-undo .
DEFINE VARIABLE v-increase-found as logical no-undo .
DEFINE VARIABLE v-min-value as decimal      no-undo.
DEFINE VARIABLE v-max-value as decimal      no-undo.
DEFINE VARIABLE v-increase-pc as decimal      no-undo.
define variable v-round-method as character no-undo .
define variable v-base as decimal no-undo .
define variable v-print-code as character no-undo .
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
if p-obj-type <> '' then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description
        skip "Не удалось найти фирму объекта"
        skip p-obj-type p-obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
      view-as alert-box error.
      undo, return error .
  end.
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-min-value    = buf_gds-grp-obj.min-increase
    v-max-value    = buf_gds-grp-obj.max-increase
    v-increase-pc  = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    .
    assign
    p-exists-margin = (if v-min-value <> ? and v-max-value <> ? and p-min-value = ?
                        then yes
                        else p-exists-margin)
    p-range-margin = if p-exists-margin and p-min-value = ?
                      then v-range
                      else p-range-margin
    p-min-value   =  if p-exists-margin and  p-min-value = ?
                      then v-min-value
                      else p-min-value
    p-max-value   =  if p-exists-margin and  p-max-value = ?
                      then v-max-value
                      else p-max-value
    p-exists-increase = (if v-increase-pc <> ? and p-increase-pc = ?
                        then yes
                        else p-exists-increase)
    p-range-increase = if p-exists-increase and p-increase-pc = ?
                      then v-range
                      else p-range-increase
    p-increase-pc = (if p-exists-increase and p-increase-pc = ?
                      then v-increase-pc
                      else p-increase-pc)
    p-exists-rmethod = if v-round-method <> "":U and p-round-method = "":U
                        then yes
                        else p-exists-rmethod
    p-range-rmethod = (if p-exists-rmethod and p-round-method = "":U
                        then v-range
                        else p-range-rmethod)
    p-round-method  = (if p-exists-rmethod and p-round-method = "":U
                        then v-round-method
                        else p-round-method)
    p-base          = (if p-exists-rmethod and p-base = ?
                        then v-base
                        else p-base)
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
procedure grp-obj-income-cli-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-cli-type as character    no-undo init ?.
define output parameter p-cli-code as integer      no-undo init ?.
define output parameter p-range-income-cli     as integer      no-undo.
define output parameter p-exists-income-cli    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-income-cli-found as logical no-undo .
DEFINE VARIABLE v-cli-type-value as char      no-undo.
DEFINE VARIABLE v-cli-code-value as int      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-cli-type-value    = buf_gds-grp-obj.cli-type
    v-cli-code-value    = buf_gds-grp-obj.cli-code
    .
    assign
    p-exists-income-cli = (if v-cli-type-value <> ? and v-cli-code-value <> ? and p-cli-type = ?
                        then yes
                        else p-exists-income-cli)
    p-range-income-cli = if p-exists-income-cli and p-cli-type = ?
                      then v-range
                      else p-range-income-cli
    p-cli-type   =  if p-exists-income-cli and  p-cli-type = ?
                      then v-cli-type-value
                      else p-cli-type
    p-cli-code   =  if p-exists-income-cli and  p-cli-code = ?
                      then v-cli-code-value
                      else p-cli-code
    v-found =  (p-exists-income-cli ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-income-cli  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prcreate-new-price-doc :
do
on error undo, return error return-value
:
define input  parameter p-curr-db-num  as integer   no-undo .
define input  parameter p-obj-type     like ub.price-doc.obj-type no-undo.
define input  parameter p-obj-code     like ub.price-doc.obj-code no-undo.
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db-num   as integer   no-undo .
define output parameter p-price-doc-recid  as recid                no-undo.
define variable v-host-code         like ub.sysconf.host-code        no-undo.
define variable v-obj-current-date  like ub.price-doc.doc-date      no-undo.
define variable v-base-rate    like ub.price-doc-forming.base-rate   no-undo .
define variable v-base-scale   like ub.price-doc-forming.base-scale  no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming.
define buffer buf_price-doc         for ub.price-doc.
find first buf_price-doc-forming no-lock where
           buf_price-doc-forming.pdf-db     = p-pdf-db-num and
           buf_price-doc-forming.pdf-id     = p-pdf-id     and
           buf_price-doc-forming.plt-db-num = p-plt-db-num and
           buf_price-doc-forming.plt-id     = p-plt-id
           no-error .
if not available buf_price-doc-forming and p-plt-id = ? then do:
   run create_new_price-doc-forming
        ( input p-obj-type ,
          input p-obj-code ,
          output p-pdf-db-num ,
          output p-pdf-id ,
          output p-plt-db-num ,
          output p-plt-id
          ).
    find first buf_price-doc-forming no-lock where
              buf_price-doc-forming.pdf-db     = p-pdf-db-num and
              buf_price-doc-forming.pdf-id     = p-pdf-id     and
              buf_price-doc-forming.plt-db-num = p-plt-db-num and
              buf_price-doc-forming.plt-id     = p-plt-id
              no-error .
end.
    create buf_price-doc .
    run doc-code in this-procedure
    (input  "main",
     input  p-obj-type  ,
     input  p-obj-code  ,
     input  ?,
     output buf_price-doc.doc-num) no-error.
    if error-status:error then do:
      message vss-workfile vss-revision vss-description skip
             error-status :get-message(1)
            "Ошибка при генерации номера документа." return-value view-as alert-box error.
      return error.
    end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    v-obj-current-date  = today .
    if not (buf_price-doc-forming.base-rate = 0 or buf_price-doc-forming.base-rate = ?) then do:
        v-base-rate   =  buf_price-doc-forming.base-rate  .
        v-base-scale  =  buf_price-doc-forming.base-scale .
    end.
    else do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  v-obj-current-date
  ,output v-base-rate
  ,output v-base-scale
  )  .
    end.
   assign
    buf_price-doc.base-rate      = v-base-rate
    buf_price-doc.base-scale     = v-base-scale
    buf_price-doc.cr-db-num      = p-curr-db-num
    buf_price-doc.doc-date       = v-obj-current-date
    buf_price-doc.fact-num       = 0
    buf_price-doc.host-code      = v-host-code
    buf_price-doc.is-corr        = false
    buf_price-doc.is-del         = false
    buf_price-doc.obj-code       = p-obj-code
    buf_price-doc.obj-type       = p-obj-type
    buf_price-doc.out-code       = ""
    buf_price-doc.pdf-db         = p-pdf-db-num
    buf_price-doc.pdf-id         = p-pdf-id
    buf_price-doc.plt-db-num     = p-plt-db-num
    buf_price-doc.plt-id         = p-plt-id
    buf_price-doc.PS             = "@ "
    buf_price-doc.rest-base      = 0
    buf_price-doc.rest-last      = 0
    buf_price-doc.rest-qnty      = 0
    buf_price-doc.rest-sale      = 0
    buf_price-doc.sale-base      = 0
    buf_price-doc.status_        = 'новый':U
    .
    buf_price-doc.doc-num-es     = entry(1, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.uid-es         = entry(2, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.doc-date       = date(entry(3, buf_price-doc-forming.des, chr(4))) no-error.
    if buf_price-doc.uid-es = "_" then buf_price-doc.uid-es = "" .
    assign
        p-price-doc-recid = recid ( buf_price-doc )
    .
end.
end procedure.
procedure prcreate-new-price-list :
do
on error undo, return error return-value
:
define input parameter p-price-doc-recid   as recid                    no-undo.
define input parameter p-gds-code          like ub.goods.gds-code         no-undo.
define input parameter p-price-sale        like ub.price-list.price-sale  no-undo.
define output parameter p-update           as logical                  no-undo.
define variable kk as integer no-undo .
define var v-b-code    like ub.bar-code.b-code     no-undo.
define variable p-hostcode as int no-undo .
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define buffer buf_price-doc        for ub.price-doc.
define buffer buf_price-list       for ub.price-list.
define buffer buf_bar-code         for ub.bar-code.
define buffer buf_goods            for ub.goods.
define buffer buf_root_gds-prt     for ub.gds-prt.
define buffer buf_gds-prt          for ub.gds-prt.
find first buf_price-doc no-lock
     where recid( buf_price-doc ) = p-price-doc-recid
.
find first buf_goods no-lock
     where buf_goods.gds-code = p-gds-code
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
if error-status :error
then do:
    message
        "Не найден основной бар-код"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_bar-code no-lock
     where buf_bar-code.b-code = v-b-code
no-error.
if error-status :error
then do:
    message
        "Не найдена запись bar-code"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
        skip "С основным бар-кодом"
        skip string(v-b-code)
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_root_gds-prt no-lock
     where buf_root_gds-prt.upper-code = buf_goods.prt-root
.
if buf_root_gds-prt.node-name <> '_Пустая шкала':U
  and buf_bar-code.in-code <> ""
then do:
    message
        "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
        "Артикул:" buf_goods.artic "Код:" buf_goods.gds-code buf_goods.gds-name
        view-as alert-box error.
    undo, return error.
end.
find first buf_gds-prt no-lock
     where buf_gds-prt.node-code = buf_bar-code.node-code
.
find first buf_price-list
     where buf_price-list.doc-num = buf_price-doc.doc-num
       and buf_price-list.b-code  = v-b-code
no-error.
if available buf_price-list
then do:
    message "Строка с товаром арт." buf_price-list.artic " уже есть в данной переоценке."
       skip "  Цена:   " buf_price-list.price-sale
       skip "Цена будет изменена"
    view-as alert-box warning.
    assign
        p-update = yes
    .
end.
else do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
    kk = kk + 1.
define variable v-main-bar-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-bar-code
  )  .
    create buf_price-list.
    assign
        buf_price-list.line-num    = kk
        buf_price-list.doc-num     = buf_price-doc.doc-num
        buf_price-list.b-code      = buf_bar-code.b-code
        buf_price-list.artic       = buf_goods.artic
        buf_price-list.prod-type   = buf_goods.prod-type
        buf_price-list.prod-code   = buf_goods.prod-code
        buf_price-list.main-price  = (buf_bar-code.b-code = v-main-bar-code )
        buf_price-list.calc-method = 'Отсутствует':U
        buf_price-list.obj-type    = buf_price-doc.obj-type
        buf_price-list.obj-code    = buf_price-doc.obj-code
        buf_price-list.price-sale  = p-price-sale
        buf_price-list.vat-pc      = local_vat-pc
        buf_price-list.slt-pc      = local_slt-pc
        p-update                   = no
    .
end.
end.
end procedure.
procedure create_new_price-doc-forming :
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-plt-db-num as integer   no-undo .
define output parameter p-plt-id     as integer   no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  ?
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output p-plt-id
  ,output p-plt-db-num
  )  .
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = "автосоздание"
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
end procedure.
procedure prcreate-new-price-doc-forming-gds :
define input  parameter p-price-doc-forming-recid as recid  no-undo.
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter par-pr-notls as character no-undo .
define input  parameter par-pr-altex as character no-undo .
define input  parameter par-pr-sclex as character no-undo .
define input  parameter p-line-num    as integer   no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-price-sale  as decimal   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer main_bar-code for ub.bar-code  .
define variable main-b-code as integer   no-undo .
define variable v-sec as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal   no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
find first buf_price-doc-forming no-lock where
           recid(buf_price-doc-forming) = p-price-doc-forming-recid  no-error .
           if error-status :error then return error .
find first buf_goods no-lock where
           buf_goods.gds-code  = p-gds-code no-error .
           if error-status :error then return error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
run check-use-bar-code (main-b-code) no-error .
if error-status :error then return .
run create-line-pdf-mpl-lib (
     input buf_price-doc-forming.plt-db-num
    ,input buf_price-doc-forming.plt-id
    ,input buf_price-doc-forming.pdf-db
    ,input buf_price-doc-forming.pdf-id
    ,input p-line-num
    ,input main-b-code
    ,input buf_goods.artic
    ,input buf_goods.prod-type
    ,input buf_goods.prod-code
    ,input ""
    ,input 0
    ,input p-price-sale
    ,input ""
    ,input 0
   ,input-output v-sec ) no-error .
   if error-status :error  then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "2"
       view-as alert-box error
     .
   end.
define buffer old_price-list for ub.price-list  .
if par-pr-notls = "yes" then do:
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  main-b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
end.
if par-pr-altex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.unit-cli <> buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                     ,input-output v-sec ) no-error .
        end.
    end.
end.
if par-pr-sclex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num    = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.in-code  = "" and
                      buf_bar-code.unit-cli = buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                    ,input-output v-sec ) no-error .
        end.
    end.
end.
end.
end procedure.
procedure copy_new_price-doc-forming :
define input  parameter       p-recid      as recid no-undo .
define input-output parameter p-plt-db-num as integer   no-undo .
define input-output parameter p-plt-id     as integer   no-undo .
define output parameter       p-pdf-db-num as integer   no-undo .
define output parameter       p-pdf-id     as integer   no-undo .
define buffer buf_price-list-type        for ub.price-list-type  .
define buffer buf_price-doc-forming      for ub.price-doc-forming .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr .
define buffer buf_price-doc-forming-gds  for ub.price-doc-forming-gds .
define buffer buf_pd-forming-gds-attr    for ub.price-doc-forming-gdsattr .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
define variable v-name as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-db-num = p-plt-db-num and
           buf_price-list-type.plt-id     = p-plt-id no-error .
if error-status :error then return error "Не найден ТПЛ".
if buf_price-list-type.stts <> 0 then return error "ТПЛ удален" .
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming )  = p-recid no-error .
    if available buf_price-doc-forming then do :
        assign
          v-base-rate  = buf_price-doc-forming.base-rate
          v-base-scale = buf_price-doc-forming.base-scale
          v-name       =  substitute("Скопировано с ДНЦ &1 &2",  buf_price-doc-forming.pdf-id , trim(buf_price-doc-forming.name)  )
        .
    end.
    else do:
        assign
          v-base-rate  = 1
          v-base-scale = 1
          v-name       = "Автосоздание"
        .
    end.
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = v-name
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
  if not available buf_price-doc-forming then return .
for each buf_price-doc-forming-attr no-lock where
         buf_price-doc-forming-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-attr.
    buffer-copy buf_price-doc-forming-attr to ub.price-doc-forming-attr
    assign
      ub.price-doc-forming-attr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-attr.plt-id      = p-plt-id
      ub.price-doc-forming-attr.pdf-db     = p-pdf-db-num
      ub.price-doc-forming-attr.pdf-id      = p-pdf-id
      .
end.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-gds.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-gds.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-gds.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gds.
    buffer-copy buf_price-doc-forming-gds to ub.price-doc-forming-gds
    assign
      ub.price-doc-forming-gds.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gds.plt-id      = p-plt-id
      ub.price-doc-forming-gds.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gds.pdf-id      = p-pdf-id
    .
end.
for each buf_pd-forming-gds-attr no-lock where
         buf_pd-forming-gds-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_pd-forming-gds-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_pd-forming-gds-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_pd-forming-gds-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gdsattr.
    buffer-copy buf_pd-forming-gds-attr to ub.price-doc-forming-gdsattr
    assign
      ub.price-doc-forming-gdsattr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gdsattr.plt-id      = p-plt-id
      ub.price-doc-forming-gdsattr.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gdsattr.pdf-id      = p-pdf-id
    .
end.
end procedure.
def var vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info27, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info27 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info27 )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info27, p-b-code ) .
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info27
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    if buf_bar-code.stts = integer('79':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info27
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    return .
  end.
end procedure.
define variable v-rec-list-cli as character no-undo .
define variable g-log          as logical   no-undo .
define variable br-handle      as handle no-undo.
define variable buffer-handle  as handle no-undo.
define variable next-prev      as logical no-undo .
define variable v-rec-list     as character no-undo .
define variable ref-rec        as recid no-undo.
define variable loc_gop-db-num as integer no-undo.
define variable loc_gop-id     as integer no-undo.
define variable var-paket      as logical   no-undo init false .
define variable filter-point as character no-undo init  "pdf-list" .
define variable filter-label  as character no-undo init "Список ДНЦ" .
define variable sort-column-name as character no-undo.
define variable v-title-0 as character no-undo .
define variable v-flt-rec           as character no-undo .
define variable v-filter-name       as character no-undo .
define variable v-where-phrase      as character no-undo .
define variable v-sort-phrase       as character no-undo .
define variable v-where-phrase-rus  as character no-undo .
define variable v-sort-phrase-rus   as character no-undo .
function mark-string returns character
  ( buffer loc-table for ub.price-doc-forming, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.
function stts-string returns character
  ( buffer loc-table for ub.price-doc-forming   ) :
 case loc-table.stts :
    when 0 then return 'новый':U .
    when 1 then return 'удал':U .
    when 3 then return 'факт':U .
    when 4 then return 'готов':U .
 end case.
end function.
function activ-pr returns character
  ( buffer loc-table for ub.price-doc-forming  ) :
define buffer buf_price-all for ub.price-all  .
define buffer buf2_price-all for ub.price-all  .
  find first buf_price-all no-lock where
             buf_price-all.pdf-db = loc-table.pdf-db  and
             buf_price-all.pdf-id = loc-table.pdf-id  and
             buf_price-all.plt-db-num = loc-table.plt-db-num and
             buf_price-all.plt-id     = loc-table.plt-id and
             buf_price-all.status_    = 'акт':U
             no-error .
   if available buf_price-all then do:
            find first buf2_price-all no-lock where
                      buf2_price-all.pdf-db = loc-table.pdf-db  and
                      buf2_price-all.pdf-id = loc-table.pdf-id  and
                      buf2_price-all.plt-db-num = loc-table.plt-db-num and
                      buf2_price-all.plt-id     = loc-table.plt-id and
                      buf2_price-all.status_    <> 'акт':U
                      no-error .
             if available buf2_price-all then return "не все" .
             else return "все +" .
      end.
   else do:
      return "".
   end.
end function.
DEFINE QUERY external_tables FOR buf_price-list-type.
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить новый ДНЦ"
     BGCOLOR 8 .
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Вы&ход"
     SIZE 10 BY 1 TOOLTIP "Выход из режима"
     BGCOLOR 8 .
DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменение ДНЦ"
     BGCOLOR 8 .
DEFINE BUTTON B-close
     LABEL "&Закрыть"
     SIZE 10 BY 1 TOOLTIP "Закрыть ДНЦ"
     BGCOLOR 8 .
DEFINE BUTTON B-copy
     LABEL ". Скопировать"
     SIZE 15 BY 1 TOOLTIP "Скопировать ДНЦ на другие ТПЛ"
     BGCOLOR 8 .
DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить ДНЦ"
     BGCOLOR 8 .
DEFINE BUTTON B-del-pr
     LABEL "Удалить цены"
     SIZE 15 BY 1 TOOLTIP "Удаление цен по ДНЦ не главного ТПЛ"
     BGCOLOR 8 .
DEFINE BUTTON B-ftpl
     LABEL "_  по &ТПЛ"
     SIZE 10 BY 1 TOOLTIP "Фильтр по ТПЛ"
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 2.88 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-history
     LABEL "История"
     SIZE 3 BY 1 TOOLTIP "История изменения документа"
     BGCOLOR 8 .
DEFINE BUTTON B-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр ДНЦ"
     BGCOLOR 8 .
DEFINE BUTTON b-lkp-pd
     LABEL "&Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр переоценки".
DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить строки"
     BGCOLOR 8 .
DEFINE BUTTON B-price-doc
     LABEL "Перео&ценки"
     SIZE 13 BY 1 TOOLTIP "Список переоценок по ДНЦ"
     BGCOLOR 8 .
DEFINE BUTTON B-print
     LABEL "Печать"
     SIZE 2.5 BY 1 TOOLTIP "Печать ДНЦ"
     BGCOLOR 8 .
DEFINE BUTTON B-print-pr
     IMAGE-UP FILE "cmp/b-print.bmp":U
     TOOLTIP "Печать переоценки"
     SIZE 3 BY 1 .
DEFINE BUTTON B-sch
     LABEL "&Фильт"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1 TOOLTIP "Выбрать ДНЦ"
     BGCOLOR 8 .
DEFINE BUTTON i-copy
     IMAGE-UP FILE "cmp/btn-copy.bmp":U
     IMAGE-DOWN FILE "cmp/btn-copy.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-copy.bmp":U
     LABEL "Button 1"
     SIZE 3 BY .75.
DEFINE BUTTON i-schTPL
     IMAGE-UP FILE "cmp/b-sch.bmp":U
     IMAGE-DOWN FILE "cmp/b-sch.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-sch.bmp":U
     LABEL ""
     SIZE 2.88 BY .92.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус:"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "№ ДНЦ:"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc-pdf-id AS INTEGER FORMAT ">>>>>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по коду документа НЦ" NO-UNDO.
DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Кто изменял"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE R-status AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Новые", 0,
"Все", 2,
"Закрытые", 3,
"Готовые", 4,
"Удаленные", 1
     SIZE 45 BY .67 TOOLTIP "Условие отбора записей" NO-UNDO.
DEFINE VARIABLE T-paket AS LOGICAL INITIAL no
     LABEL "пакетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY .83 NO-UNDO.
DEFINE QUERY BROWSE-1grp FOR
      buf_price-doc-forming,
      buf_price-list-type,
      x_grp-obj-price SCROLLING.
DEFINE QUERY BROWSE-2-pr FOR
      buf_price-doc SCROLLING.
DEFINE BROWSE BROWSE-1grp
  QUERY BROWSE-1grp NO-LOCK DISPLAY
      mark-string ( buffer buf_price-doc-forming, p-rec-list ) COLUMN-LABEL "*! " FORMAT "x(1)":U
      buf_price-list-type.priority              COLUMN-LABEL "Прио-!ритет" FORMAT ">>>>9":U
      stts-string ( buffer buf_price-doc-forming )             COLUMN-LABEL "Ста-!тус" FORMAT "x(4)":U
      activ-pr ( buffer buf_price-doc-forming ) COLUMN-LABEL "Есть акт!цены"            FORMAT "x(8)":U
      buf_price-doc-forming.pdf-id   COLUMN-LABEL "Код ДНЦ! " FORMAT ">>>>>>>>>9":U
      buf_price-doc-forming.sys-date         COLUMN-LABEL "Дата!изм"  FORMAT "99/99/99":U
      buf_price-doc-forming.sys-time-chr     COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_price-doc-forming.name   COLUMN-LABEL "Название документа! " FORMAT "X(100)":U WIDTH 30
      buf_price-list-type.plt-id   COLUMN-LABEL "Код!типа" FORMAT ">>>>>9":U
      buf_price-list-type.main     COLUMN-LABEL "Г! " FORMAT "+/ ":U
      buf_price-list-type.name               COLUMN-LABEL "Тип прайс-листа! " FORMAT "X(100)":U WIDTH 30
      buf_price-doc-forming.db-num-chg       COLUMN-LABEL "БД!изм"    FORMAT ">>>>9":U
      buf_price-doc-forming.pdf-db           COLUMN-LABEL "БД!док" FORMAT ">>>>9":U
      buf_price-list-type.plt-db-num         COLUMN-LABEL "БД!ТПЛ" FORMAT ">>>>9":U
      buf_price-doc-forming.out-code         COLUMN-LABEL "№!накл" FORMAT "X(16)":U
      buf_price-doc-forming.start-date         COLUMN-LABEL "Дата объекта!c"  FORMAT "99/99/99":U
      buf_price-doc-forming.end-date           COLUMN-LABEL "Дата объекта!по"  FORMAT "99/99/99":U
      buf_price-doc-forming.start-sys-date         COLUMN-LABEL "Дата sys!c"  FORMAT "99/99/99":U
      string(buf_price-doc-forming.start-sys-time,"hh:mm:ss")         COLUMN-LABEL "Время sys!c"  FORMAT "x(8)":U
      buf_price-doc-forming.end-sys-date           COLUMN-LABEL "Дата sys!по"  FORMAT "99/99/99":U
      string(buf_price-doc-forming.end-sys-time,"hh:mm:ss")           COLUMN-LABEL "Время sys!по"  FORMAT "x(8)":U
      buf_price-doc-forming.start-shift-date         COLUMN-LABEL "Дата смены!c"  FORMAT "99/99/99":U
      buf_price-doc-forming.start-shift-num          COLUMN-LABEL "№ смены!c"
      buf_price-doc-forming.end-shift-date           COLUMN-LABEL "Дата смены!по"  FORMAT "99/99/99":U
      buf_price-doc-forming.end-shift-num            COLUMN-LABEL "№ смены!по"
  ENABLE
      buf_price-doc-forming.name
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.63 BY 11.5 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.
DEFINE BROWSE BROWSE-2-pr
  QUERY BROWSE-2-pr NO-LOCK DISPLAY
      buf_price-doc.status_ COLUMN-LABEL "Статус"
      buf_price-doc.doc-num format "x(16)"
      buf_price-doc.doc-date  column-label "Дата"
      buf_price-doc.fact-date COLUMN-LABEL "Факт"
      (trim (buf_price-doc.obj-type) + " " + string (buf_price-doc.obj-code, ">>>>9")) COLUMN-LABEL "Объект" FORMAT "x(9)"
      buf_price-doc.rest-qnty column-label "Кол-во"
      buf_price-doc.sale-base COLUMN-LABEL "Сумма "
      buf_price-doc.rest-sale COLUMN-LABEL "Было "
      buf_price-doc.out-code  COLUMN-LABEL "Накладная"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.5 BY 5.5 ROW-HEIGHT-CHARS .58.
DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14.25
     B-add AT ROW 1 COL 24.25
     B-lkp AT ROW 1 COL 34.25
     B-chg AT ROW 1 COL 44.25
     B-del AT ROW 1 COL 54.25
     B-close AT ROW 1 COL 64.25
     B-ftpl AT ROW 1 COL 74.25 WIDGET-ID 8
     B-sch AT ROW 1 COL 88.5 WIDGET-ID 6
     B-print AT ROW 1 COL 91.5
     B-history AT ROW 1 COL 94
     B-Help AT ROW 1 COL 97
     i-schTPL AT ROW 1.04 COL 74.25 WIDGET-ID 12 NO-TAB-STOP
     B-price-doc AT ROW 2 COL 1
     B-del-pr AT ROW 2 COL 14.13
     B-copy AT ROW 2 COL 29.25 WIDGET-ID 14
     i-copy AT ROW 2.08 COL 29.38 WIDGET-ID 16 NO-TAB-STOP
     loc-pdf-id AT ROW 2.83 COL 83 COLON-ALIGNED NO-LABEL
     R-status AT ROW 3.25 COL 10.63 NO-LABEL
     T-paket AT ROW 3.96 COL 82.13 WIDGET-ID 4
     BROWSE-1grp AT ROW 4.75 COL 1.38
     b-lkp-pd AT ROW 16.38 COL 12.38
     B-print-pr AT ROW 16.38 COL 22.5 WIDGET-ID 18
     BROWSE-2-pr AT ROW 17.5 COL 1.5
     FILL-IN-6 AT ROW 3.04 COL 78.5 NO-LABEL
     FILL-IN-1 AT ROW 3.21 COL 1.88 NO-LABEL
     v-user-name AT ROW 16.5 COL 82 COLON-ALIGNED WIDGET-ID 2
     "ПЕРЕОЦЕНКИ" VIEW-AS TEXT
          SIZE 10.5 BY .67 AT ROW 16.5 COL 1.5
          FGCOLOR 4
     SPACE(88.38) SKIP(5.96)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список документов назначения цены на объекте"
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
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pdf_update':U
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
  define variable v-recid as character no-undo .
  define buffer buf1_price-list-type for ub.price-list-type  .
  define variable v-only-main as logical   no-undo .
  define variable v-plt-id     as integer   no-undo .
  define variable v-plt-db-num as integer   no-undo .
  next-prev = false .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run glstmain in g#library
  (output v-only-main
  )  .
  if v-only-main = false then do:
      run ref/l-tppr.p
        ( input parParentProc,
          input p-obj-type ,
          input p-obj-code ,
          input "b-sel" ,
          output v-recid
          ).
      find first buf1_price-list-type no-lock where recid(buf1_price-list-type) = int(v-recid) no-error .
  end.
  else do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  parParentProc
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  no
  ,output v-plt-id
  ,output v-plt-db-num
  ) no-error .
     find first buf1_price-list-type no-lock where
                buf1_price-list-type.plt-id = v-plt-id and
                buf1_price-list-type.plt-db-num = v-plt-db-num
                no-error .
  end.
  if available buf1_price-list-type then do:
      if buf1_price-list-type.stts <> integer('0':U) then do:
         message "ДНЦ можно создать только с текущим типом прайс-листов !" view-as alert-box information  .
         return .
      end.
      if buf1_price-list-type.under-type-list <> 0 then do:
         message "Нельзя выбирать подчиненный прайс-лист !" view-as alert-box information  .
         return .
      end.
      if buf1_price-list-type.gop-id = 0 then do:
         message "Этот тип прайс-листа действует на ВСЕ объекты системы ."
                 "Вы действительно хотите создать одинаковые цены на ВСЕХ объектах ? " view-as alert-box question
                 buttons yes-no
                 update v-okk as logical
                 .
         if v-okk = false then return .
      end.
      run str/df-price.w
        ( input parparentproc,
          input 'ДОБАВЛЕНИЕ':U ,
          input buf1_price-list-type.plt-id,
          input buf1_price-list-type.plt-db-num ,
          input ? ,
          output v-rec-list ,
          input-output v-rec-id ,
          input-output br-handle ,
          input-output buffer-handle ,
          input-output next-prev
          ) .
      run openbr in this-procedure .
      reposition BROWSE-1grp to recid v-rec-id no-error .
      apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
    end.
    else do:
      message "Не выбран ТПЛ !!!" view-as alert-box .
      return no-apply .
    end.
END.
ON CHOOSE OF B-chg IN FRAME Dialog-Frame
DO:
   define variable g#log as logical   no-undo .
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pdf_update':U
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
  next-prev = false .
  if not available buf_price-doc-forming then return .
  if buf_price-doc-forming.stts <> integer('0':U) then do:
   message "Закрытые или удаленные ДНЦ корректировать нельзя! "
         view-as alert-box information .
   return .
   end.
  define variable v-rec-id as recid no-undo .
  define variable v-recid as character no-undo .
  if available buf_price-doc-forming then do:
      v-rec-id = recid (buf_price-doc-forming) .
      run str/df-price.w
      ( input parparentproc,
        input 'ИЗМЕНЕНИЕ':U ,
        input buf_price-doc-forming.plt-id,
        input buf_price-doc-forming.plt-db-num ,
        input ? ,
        output v-rec-list ,
        input-output v-rec-id ,
        input-output br-handle ,
        input-output buffer-handle ,
        input-output next-prev
        ) .
      run openbr in this-procedure .
      reposition BROWSE-1grp to recid v-rec-id no-error .
      apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
    end.
END.
ON CHOOSE OF B-close IN FRAME Dialog-Frame
DO:
   define variable g#log as logical   no-undo .
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pdf_close':U
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
define variable v-mode as character no-undo .
define variable v-ask-pr as logical   no-undo .
 if var-paket = false then do:
  if not available buf_price-doc-forming then return .
  if buf_price-doc-forming.stts <> integer('0':U) then do:
   message "Закрытые или удаленные ДНЦ закрывать нельзя! "
            view-as alert-box information .
   return .
   end.
  v-rec-id = recid(buf_price-doc-forming) .
  if buf_price-list-type.main = true  then do:
     run str/pdf-cask.w ( input parparentproc , input recid( buf_price-doc-forming ) , output v-mode , output v-ask-pr ) .
     if v-mode = "" or  v-ask-pr = ? then return no-apply.
  end.
  else do:
  message "Закрывать ДНЦ" buf_price-doc-forming.pdf-id "?"
      view-as alert-box question
      buttons yes-no
      update var-ok as logical
      .
  if var-ok =  false then return .
  end.
    run str/diallog.w
        ( parparentproc
        , this-procedure
        , 'str/pdf-clos.p':U + chr(4) + '1' + chr(4) + '0' + chr(4) + '1'
        , ( string(v-rec-id) + chr(4) +
           'no' + chr(4) +
           'no' + chr(4) +
           '?'  + chr(4) +
           '?'  + chr(4) +
           string(v-mode) + chr(4) +
           '?' + chr(4) +
           string(v-ask-pr)  )
         , yes
         , '':U
         , 'Закрытие ДНЦ') no-error .
    if error-status :error then
    message
      error-status :get-message(1) skip
      return-value skip
      "Ошибка закрытия ДНЦ"
      view-as alert-box error
    .
  end.
  else do:
      define variable nn as integer   no-undo .
      define variable v-recid as recid no-undo .
      define buffer cl_price-doc-forming for ub.price-doc-forming  .
      define buffer cl_price-list-type for ub.price-list-type  .
      define variable i as integer   no-undo .
      nn = num-entries(p-rec-list) .
          if nn = 0 then do:
              message "Не выбрано ни одной строки для закрытия! "  view-as alert-box information .
              return .
          end.
          message substitute("Закрыть &1 отмеченных ДНЦ ?  " , nn)
            view-as alert-box question
            buttons yes-no
            update v-ok as logical.
          if v-ok then do:
            repeat i = 1 to nn :
                v-recid = int(entry( i , p-rec-list )) .
                find first cl_price-doc-forming no-lock where
                    recid(cl_price-doc-forming) = v-recid no-error .
                    if available cl_price-doc-forming then do:
                        find first cl_price-list-type no-lock where
                                  cl_price-list-type.plt-id = cl_price-doc-forming.plt-id and
                                  cl_price-list-type.plt-db-num = cl_price-doc-forming.plt-db-num
                                  no-error .
                             if cl_price-doc-forming.stts <> integer('0':U)   then do:
                                message substitute("ДНЦ &1 закрыть уже нельзя !" , cl_price-doc-forming.pdf-id) view-as alert-box information .
                              end.
                              else do:
                                  if cl_price-list-type.main = true  then do:
                                      if v-mode = "" or  v-ask-pr = ? then
                                      run str/pdf-cask.w ( input parparentproc , input recid(cl_price-doc-forming ) , output v-mode , output v-ask-pr ) .
                                          if v-mode = "" or  v-ask-pr = ? then do:
                                              next.
                                          end.
                                  end.
                                    run str/diallog.w
                                        (parparentproc
                                        , this-procedure
                                        , 'str/pdf-clos.p':U + chr(4) + '1' + chr(4) + '0' + chr(4) + '1'
                                        , ( string(recid(cl_price-doc-forming )) + chr(4) +
                                          'no' + chr(4) +
                                          'no' + chr(4) +
                                          '?' + chr(4) +
                                          '?' + chr(4) +
                                          string(v-mode) + chr(4) +
                                          '?' + chr(4) +
                                          string(v-ask-pr)  )
                                        , yes
                                        , '':U
                                        , 'Закрытие ДНЦ') no-error .
                                        if error-status :error then message
                                          error-status :get-message(1) skip
                                          return-value skip
                                          "Ошибка при закрытии ДНЦ"
                                          view-as alert-box error
                                        .
                          end.
                    end.
            end.
          end.
  end.
  run openbr in this-procedure .
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
END.
ON CHOOSE OF B-copy IN FRAME Dialog-Frame
DO:
  define variable g#log as logical   no-undo .
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pdf_update':U
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
define variable v-plt-db-num as integer   no-undo .
define variable v-plt-id     as integer   no-undo .
define variable v-pdf-db-num as integer   no-undo .
define variable v-pdf-id     as integer   no-undo .
define variable v-ok1 as integer   no-undo .
if not available buf_price-doc-forming then return.
v-rec-id = recid (buf_price-doc-forming) .
  message "Копировать ДНЦ №" buf_price-doc-forming.pdf-id skip
          "БД:"              buf_price-doc-forming.pdf-db skip
          "на другой ТПЛ ?"                               skip(2)
  "При копировании из текущего ДНЦ в новый ДНЦ перенесутся все баркоды с ценами КАК ЕСТЬ, " skip
  "При этом не проверяются НИ КАКИЕ настройки !!! " skip
  "(ни проверка наличия спец цен (шкал,партий и другой единицы измерения), ни проверка наличия свободной зоны, "
  " ни ограничения нового ТПЛ)"
  view-as alert-box question
  button yes-no
  update v-ok as logical .
  if not v-ok then return .
define variable v-spis-recid as character no-undo .
define variable i as integer   no-undo .
define variable v-kol as integer   no-undo .
define buffer bufc_price-list-type for ub.price-list-type  .
v-spis-recid = "" .
run ref/typepric.w (
    input parParentProc     ,
    input "mode=all,b-mark,b-sel,title=ВЫБИРИТЕ Типы Прайс-листов для копирования endtitle" ,
    input-output v-spis-recid
    ) no-error .
    v-kol = num-entries(v-spis-recid).
    v-ok1 = 0.
    repeat i = 1 to v-kol :
       find first bufc_price-list-type no-lock  where recid(bufc_price-list-type) = int(entry(i,v-spis-recid)) no-error .
       if bufc_price-list-type.stts <> 0 then next.
       v-plt-db-num = bufc_price-list-type.plt-db-num .
       v-plt-id     = bufc_price-list-type.plt-id     .
       run copy_new_price-doc-forming (
           input v-rec-id  ,
           input-output v-plt-db-num  ,
           input-output v-plt-id      ,
           output v-pdf-db-num  ,
           output v-pdf-id
           ) no-error .
           if not error-status :error then do:
              v-ok1 = v-ok1 + 1 .
           end.
    end.
  run openbr in this-procedure .
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
  message substitute ( "Создано &1 копий ДНЦ" , v-ok1 ) view-as alert-box information .
END.
ON CHOOSE OF B-del IN FRAME Dialog-Frame
DO:
if not available buf_price-doc-forming then return .
   define variable g#log as logical   no-undo .
   if buf_price-doc-forming.stts = integer('3':U) then do:
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pdf_delete-fact':U
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
   end.
   else do:
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pdf_delete':U
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
  end.
  if not g#log then return .
if var-paket = false  then do:
  if not available buf_price-doc-forming then return .
  if buf_price-list-type.main = true  and
     buf_price-doc-forming.stts = integer('3':U)
     then do:
      message "ДНЦ :" buf_price-doc-forming.name skip
              "№" buf_price-doc-forming.pdf-id
              "главного типа  - удалять нельзя !!!"
              view-as alert-box error
              title "Внимание !" .
              return.
  end.
  message "Удалять ДНЦ : " buf_price-doc-forming.name skip
          "№" buf_price-doc-forming.pdf-id "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .
  run price-doc-forming-delete (
      buf_price-doc-forming.plt-db-num ,
      buf_price-doc-forming.plt-id     ,
      buf_price-doc-forming.pdf-db     ,
      buf_price-doc-forming.pdf-id     ,
      v-cntxt-db-num                   ,
      v-cntxt-userid                   )
      no-error .
 end.
 else do:
 define variable nn as integer   no-undo .
 define variable v-recid as recid no-undo .
 define buffer del_price-doc-forming for ub.price-doc-forming  .
 define buffer del_price-list-type for ub.price-list-type  .
 define variable i as integer   no-undo .
 nn = num-entries(p-rec-list) .
    if nn = 0 then do:
        message "Не выбрано ни одной строки для удаления! "  view-as alert-box information .
        return .
    end.
    message substitute("Удалить &1 отмеченных ДНЦ ?  " , nn)
      view-as alert-box question
      buttons yes-no
      update v-ok as logical.
    if v-ok then do:
       repeat i = 1 to nn :
          v-recid = int(entry( i , p-rec-list )) .
          find first del_price-doc-forming no-lock where
               recid(del_price-doc-forming) = v-recid no-error .
               if available del_price-doc-forming then do:
                  find first del_price-list-type no-lock where
                             del_price-list-type.plt-id = del_price-doc-forming.plt-id and
                             del_price-list-type.plt-db-num = del_price-doc-forming.plt-db-num
                             no-error .
                    if  del_price-list-type.main = true  and
                        del_price-doc-forming.stts = integer('3':U)   then do:
                          message substitute("Удалять ДНЦ &1 нельзя !" , del_price-doc-forming.pdf-id) view-as alert-box information .
                        end.
                        else do:
                        run price-doc-forming-delete (
                            del_price-doc-forming.plt-db-num ,
                            del_price-doc-forming.plt-id     ,
                            del_price-doc-forming.pdf-db     ,
                            del_price-doc-forming.pdf-id     ,
                            v-cntxt-db-num                   ,
                            v-cntxt-userid                   )
                            no-error .
                    end.
               end.
       end.
    end.
 end.
 p-rec-list = "" .
 if error-status :error then return no-apply .
 run openbr in this-procedure .
END.
ON CHOOSE OF B-del-pr IN FRAME Dialog-Frame
DO:
define variable v-rec-id as recid no-undo .
if not available buf_price-doc-forming then return.
  message "Удалить цены по прайс-листу ?"
  view-as alert-box question
  button yes-no
  update v-ok as logical .
  if v-ok then do:
        v-rec-id = recid (buf_price-doc-forming) .
        for each ub.price-all exclusive-lock where
                ub.price-all.pdf-db        = buf_price-doc-forming.pdf-db      and
                ub.price-all.pdf-id        = buf_price-doc-forming.pdf-id      and
                ub.price-all.plt-db-num    = buf_price-doc-forming.plt-db-num  and
                ub.price-all.plt-id        = buf_price-doc-forming.plt-id
                :
                delete ub.price-all.
        end.
        run openbr in this-procedure .
        reposition BROWSE-1grp to recid v-rec-id no-error .
        apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
  end.
END.
ON CHOOSE OF B-ftpl IN FRAME Dialog-Frame
DO:
  run ini-flt-tpl in this-procedure .
  apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
END.
ON CHOOSE OF B-history IN FRAME Dialog-Frame
DO:
  if not available buf_price-doc-forming then return .
  run ref/cpr-form.w ( parParentProc ,
        buf_price-doc-forming.plt-id    ,
        buf_price-doc-forming.plt-db-num ,
        buf_price-doc-forming.pdf-id    ,
        buf_price-doc-forming.pdf-db      ).
END.
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame
DO:
   define variable g#log as logical   no-undo .
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_pdf_lookup':U
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
if not available buf_price-doc-forming then return .
define variable v-rec-id as recid no-undo .
define variable v-recid as character no-undo .
  assign
    v-rec-id      = recid (buf_price-doc-forming)
    next-prev     = yes
    br-handle     = BROWSE-1grp:handle
    buffer-handle = buffer buf_price-doc-forming :handle .
    .
  do while next-prev = yes :
      if not available buf_price-doc-forming then do:
        message "Неправильно выбран документ ДНЦ." view-as alert-box error.
        return no-apply.
      end.
      run str/df-price.w
        ( input parparentproc,
          input 'ПРОСМОТР':U ,
          input buf_price-doc-forming.plt-id ,
          input buf_price-doc-forming.plt-db-num ,
          input ? ,
          output v-rec-list  ,
          input-output v-rec-id  ,
          input-output br-handle ,
          input-output buffer-handle ,
          input-output next-prev
          ) .
  end.
  run openbr in this-procedure .
  reposition browse-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
END.
ON CHOOSE OF b-lkp-pd IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE g#log AS LOGICAL NO-UNDO.
DEFINE VARIABLE v-doc-rec AS recid NO-UNDO.
if not available buf_price-doc then return .
v-doc-rec = recid(buf_price-doc) .
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_lookup':U
    ,input  'object':U
    ,input  buf_price-doc.host-code
    ,input  buf_price-doc.obj-type
    ,input  buf_price-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
if g#log <> yes then return no-apply.
run str/pr-lkp.p ( input parParentProc    ,
                   input v-doc-rec
                   ) .
reposition BROWSE-2-pr to recid v-doc-rec no-error.
apply "entry" to BROWSE-2-pr in frame Dialog-Frame.
END.
ON CHOOSE OF B-mark IN FRAME Dialog-Frame
DO:
    if available buf_price-doc-forming then do:
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid39 as character no-undo .
define variable v-num-entry39 as integer   no-undo .
assign
  v-str-recid39 = trim( string( recid( buf_price-doc-forming ) , "->>>>>>>>>>>9":U ) )
  v-num-entry39 = lookup( v-str-recid39 , p-rec-list )
.
if v-num-entry39 > 0 then do:
  assign
    entry( v-num-entry39, p-rec-list ) = "":U
    p-rec-list = trim( replace( p-rec-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    p-rec-list = p-rec-list + ( if p-rec-list = "":U then "":U else chr(44) ) + v-str-recid39
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
ON CHOOSE OF B-price-doc IN FRAME Dialog-Frame
DO:
  define variable loc-ref-list as character no-undo .
  define variable p-list-mode as character no-undo .
  define variable v-rec-id as recid no-undo .
  p-list-mode = "pricedocforming":U .
  if not available buf_price-doc-forming then return .
  v-rec-id = recid(buf_price-doc-forming) .
  run str/pr-docs.w
    (input parparentproc
    ,input "b-mark":U
    ,input p-list-mode
    ,input ""
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input string( v-rec-id )
    ,output loc-ref-list
    ) .
  run openbr in this-procedure .
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame Dialog-Frame.
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
  run rep/g-dfc.p
     ( parParentProc,
       recid(buf_price-doc-forming)
       ).
END.
ON CHOOSE OF B-print-pr IN FRAME Dialog-Frame
DO:
define variable g#log as logical   no-undo .
  if not available buf_price-doc then do:
    return no-apply.
  end.
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_print':U
    ,input  'object':U
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
  if g#log <> yes then return no-apply.
  run rep/pr-dprn.w ( parParentProc , recid(buf_price-doc)).
  apply "entry" to BROWSE-2-pr.
END.
ON CHOOSE OF B-sch IN FRAME Dialog-Frame
DO:
  run init-flt in this-procedure no-error.
END.
ON CHOOSE OF B-sel IN FRAME Dialog-Frame
DO:
  if ( available buf_price-doc-forming ) AND ( p-rec-list = "" ) THEN
                  p-rec-list = string( recid ( buf_price-doc-forming )) .
END.
ON MOUSE-SELECT-DBLCLICK OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  apply  "CHOOSE":U to b-lkp.
END.
ON ROW-DISPLAY OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  if available buf_price-doc-forming then do:
     if buf_price-list-type.ban-discnt > 0 then do:
        run color-all ( 5 ) .
     end.
     else do:
       run color-all ( ? ) .
     end.
  end.
END.
ON VALUE-CHANGED OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  OPEN QUERY BROWSE-2-pr FOR EACH buf_price-doc NO-LOCK WHERE       buf_price-doc.pdf-id = buf_price-doc-forming.pdf-id AND       buf_price-doc.pdf-db = buf_price-doc-forming.pdf-db AND       buf_price-doc.plt-id = buf_price-doc-forming.plt-id AND       buf_price-doc.plt-db-num = buf_price-doc-forming.plt-db-num INDEXED-REPOSITION.
  if available buf_price-doc-forming then do:
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  buf_price-doc-forming.who
  ,output v-user-name
  )  .
  end.
  display  v-user-name with frame Dialog-Frame .
END.
ON CHOOSE OF i-copy IN FRAME Dialog-Frame
DO:
  APPLY "choose" TO B-copy.
END.
ON CHOOSE OF i-schTPL IN FRAME Dialog-Frame
DO:
  APPLY "choose" TO B-ftpl.
END.
ON LEAVE OF loc-pdf-id IN FRAME Dialog-Frame
DO:
END.
ON CTRL-J OF loc-pdf-id IN FRAME Dialog-Frame
DO:
  assign loc-pdf-id .
  run seach-pdf-id in this-procedure ( loc-pdf-id , true  ) no-error .
  if error-status:error then return no-apply.
END.
ON RETURN OF loc-pdf-id IN FRAME Dialog-Frame
DO:
assign loc-pdf-id no-error .
  if error-status:error then return no-apply.
  run seach-pdf-id in this-procedure ( loc-pdf-id , false  ) no-error .
  return no-apply.
END.
ON VALUE-CHANGED OF R-status IN FRAME Dialog-Frame
DO:
  ASSIGN R-status .
  run openbr in this-procedure .
END.
ON VALUE-CHANGED OF T-paket IN FRAME Dialog-Frame
DO:
   assign T-paket .
   var-paket = t-paket .
   if T-paket then do:
      enable  b-close b-del b-mark with frame Dialog-Frame .
      disable b-add b-chg b-copy i-copy with frame Dialog-Frame .
   end.
   else do:
      if LOOKUP ("b-add":U,    p-bttns) <> 0 then
         enable  b-add b-copy i-copy with frame Dialog-Frame .
      if LOOKUP ("b-chg":U,    p-bttns) <> 0 then
         enable  b-chg with frame Dialog-Frame .
      if LOOKUP ("b-mark":U,    p-bttns) = 0 then
         disable  b-mark with frame Dialog-Frame .
   end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-1grp :handle
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
  (input  'width':u
  ,input  browse BROWSE-2-pr:handle
  ) .
run diasize_init in this-procedure .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  run openbr in this-procedure .
    apply "VALUE-CHANGED" to BROWSE-1grp.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  buf_price-list-type.name:resizable in browse BROWSE-1grp   = true .
  buf_price-doc-forming.name:resizable in browse BROWSE-1grp   = true .
  buf_price-doc-forming.name:read-only in browse BROWSE-1grp   = true .
  frame Dialog-Frame:TITLE = ( if p-mode = "pl-type":U  then ("ДНЦ по ТИПУ прайс-листа № " + string( p-plt-id) + " БД " + string( p-plt-db-num))
                                                        else "Документы назначения цены" ) +
                                                        " Объект "  + p-obj-type + string(p-obj-code)
                                                         .
  v-title-0 = frame Dialog-Frame:TITLE .
  R-status = 2.
  run init-proc in this-procedure .
  run my_en in this-procedure .
  apply "VALUE-CHANGED" to BROWSE-1grp IN FRAME Dialog-Frame .
  disable
     B-sel      when LOOKUP ("b-sel":U,    p-bttns) = 0
     B-add      when LOOKUP ("b-add":U,    p-bttns) = 0
     b-copy     when LOOKUP ("b-add":U,    p-bttns) = 0
     i-copy     when LOOKUP ("b-add":U,    p-bttns) = 0
     B-chg      when LOOKUP ("b-chg":U,    p-bttns) = 0
     B-del      when LOOKUP ("b-del":U,    p-bttns) = 0
     B-del-pr   when LOOKUP ("b-del":U,    p-bttns) = 0
     B-mark     when LOOKUP ("b-mark":U,   p-bttns) = 0
    with frame Dialog-Frame .
  hide B-del-pr in frame Dialog-Frame .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_ui in this-procedure .
PROCEDURE color-all :
define input  parameter p-color as integer   no-undo .
  buf_price-doc-forming.pdf-id:fgcolor  in browse BROWSE-1grp =  p-color.
  buf_price-doc-forming.name:fgcolor    in browse BROWSE-1grp =  p-color.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY loc-pdf-id R-status T-paket FILL-IN-6 FILL-IN-1 v-user-name
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-mark B-sel B-add B-lkp B-chg B-del B-close B-ftpl B-sch
         B-print B-history B-Help i-schTPL B-price-doc B-del-pr B-copy i-copy
         loc-pdf-id R-status T-paket BROWSE-1grp b-lkp-pd B-print-pr
         BROWSE-2-pr FILL-IN-6 FILL-IN-1 v-user-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1grp FOR     EACH buf_price-doc-forming WHERE     ( r-status = 2 OR buf_price-doc-forming.stts =  r-status ) AND     ( p-mode <> "pl-type" OR (buf_price-doc-forming.plt-id = p-plt-id AND buf_price-doc-forming.plt-db-num = p-plt-db-num))     USE-INDEX spis ,            FIRST buf_price-list-type  WHERE           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id AND           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num ,            FIRST x_grp-obj-price WHERE           x_grp-obj-price.gop-id    = buf_price-list-type.gop-id   AND           x_grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num .    OPEN QUERY BROWSE-2-pr FOR EACH buf_price-doc NO-LOCK WHERE       buf_price-doc.pdf-id = buf_price-doc-forming.pdf-id AND       buf_price-doc.pdf-db = buf_price-doc-forming.pdf-db AND       buf_price-doc.plt-id = buf_price-doc-forming.plt-id AND       buf_price-doc.plt-db-num = buf_price-doc-forming.plt-db-num INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE ini-flt-tpl :
define variable v-point as character no-undo .
define variable v-label as character no-undo .
  assign
  tbl = "price-list-type"
  join-tbl = "buf_price-list-type"
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  v-point = "tpl-pdf-obj"
  v-label = "Типы прайс-листов"
  .
  run fltfield-add in this-procedure('main'        , 'Главный тип (ГТПЛ)',    '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('only-gbd'    , 'Автопереоценки', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('priority'    , 'Приоритет ТПЛ',  '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('ban-discnt'  , 'Шаблон Скидки',  '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('gop-db-num*gop-id'  , 'Группа объектов ценообразования','gop', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('name'        , 'Название ТПЛ',   '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('stts'        , 'Статус',         '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-date'    , 'Дата изменения', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-time'    , 'Время изменения', 'time', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('who'         , 'Кто', 'usr', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO  ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc,
  INPUT v-point + chr(4) + v-label + chr(4) + "yes",
  INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run gbl/flt-get.p
      (input v-point
      ,output v-flt-rec
      ,output v-filter-name
      ,output v-where-phrase
      ,output v-sort-phrase
      ,output v-where-phrase-rus
      ,output v-sort-phrase-rus
      ).
  B-ftpl:tooltip in frame Dialog-Frame  = v-filter-name .
  if v-flt-rec = ? then do:
     i-schTPL:LOAD-IMAGE ("cmp/b-sch.bmp") .
     v-filter-name  = 'Фильтр по ТПЛ не установлен' .
  end.
  else do:
     i-schTPL:LOAD-IMAGE ("cmp/b-sche.bmp") .
  end.
  B-ftpl:tooltip in frame Dialog-Frame  = v-filter-name .
  i-schTPL:tooltip in frame Dialog-Frame  = v-filter-name .
  run openbr in this-procedure .
END.
END PROCEDURE.
PROCEDURE init-flt :
  assign
  tbl = "price-doc-forming"
  join-tbl = "buf_price-doc-forming"
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
  run fltfield-add in this-procedure('pdf-id', '№ ДНЦ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pdf-db', 'БД создания ДНЦ', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('plt-id', '№ ТПЛ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('plt-db-num', 'БД создания ТПЛ', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('name', 'Название ДНЦ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-code', 'Накладная', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('stts', 'Статус', '',  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('des', 'Описание', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-date', 'Дата конца', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-shift-date', 'Сменная дата конца', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-shift-name', 'Номер конца смены', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-shift-num', '№ смены конца', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-sys-date', 'Системная дата конца', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('end-sys-time', 'Системное время конца', 'time', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('have-end-period', 'Есть конец периода', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('have-start-period', 'Есть начало периода', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('main-pdf-db', 'БД главного ДНЦ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('main-pdf-id', '№ главного ДНЦ', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-date', 'Дата начала', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-shift-date', 'Сменная дата начала', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-shift-name', 'Номер начала смены', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-shift-num', '№ смены начала', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-sys-date' , 'Системная дата начала', '', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('start-sys-time' , 'Системное время начала', 'time', input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-date', 'Дата изменения', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('sys-time', 'Время изменения', 'time',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('db-num-chg', 'БД изменения', '',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('who' , 'Правил', 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w (
  INPUT parparentproc,
  INPUT filter-point + chr(4) + filter-label + chr(4) + "yes",
  INPUT tbl,
  INPUT join-tbl,
  INPUT fld,
  INPUT lab,
  INPUT spr,
  INPUT dim ).
  run openbr in this-procedure .
END.
END PROCEDURE.
PROCEDURE init-proc :
run metod-obj-in-gop in this-procedure (
    v-cntxt-db-num ,
    p-obj-type    ,
    p-obj-code
    ).
END PROCEDURE.
PROCEDURE my_en :
  DISPLAY loc-pdf-id R-status T-paket FILL-IN-6 FILL-IN-1 v-user-name
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-mark B-sel B-add B-lkp B-chg B-del B-close B-sch B-ftpl  B-print B-print-pr
         B-history B-Help B-price-doc B-del-pr loc-pdf-id R-status T-paket
         BROWSE-1grp b-lkp-pd BROWSE-2-pr FILL-IN-6 FILL-IN-1 v-user-name i-schTPL
         b-copy i-copy
      WITH FRAME Dialog-Frame.
  DISPLAY i-schTPL   WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
   run openbr  in this-procedure .
END PROCEDURE.
PROCEDURE openbr :
define variable p-open-query       as logical no-undo init true .
define variable l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .
define variable p-find-next      as logical   no-undo .
define variable p-find-condition as character no-undo .
define variable sort-column-phrase as character no-undo .
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
define variable title0 as character no-undo init "Список ДНЦ" .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-47  as logical   no-undo .
define variable  l-filter-open-47    as logical   .
define variable  flt-rec-47       as recid     no-undo .
define variable  filter-name-47      as character no-undo .
define variable  where-phrase-47     as character no-undo .
define variable  sort-phrase-47      as character no-undo .
define variable  where-phrase-rus-47 as character no-undo .
define variable  sort-phrase-rus-47  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-47
  ,output filter-name-47
  ,output where-phrase-47
  ,output sort-phrase-47
  ,output where-phrase-rus-47
  ,output sort-phrase-rus-47
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-47
      ) no-error .
  assign
    l-filter-open-47 = false
  .
  if flt-rec-47 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-47 as character no-undo .
    define variable  parameter-3-47 as character no-undo .
    define variable  parameter-4-47 as character no-undo .
    define variable  parameter-5-47 as character no-undo .
    define variable  parameter-6-47 as character no-undo .
    define variable  parameter-7-47 as character no-undo .
      assign
      parameter-3-47 =
                              "FOR EACH buf_price-doc-forming"
      parameter-4-47 =
        (
          if ("( r-status = 2 OR buf_price-doc-forming.stts =  r-status ) and                  ( p-mode <> 'pl-type' OR                  ( buf_price-doc-forming.plt-id = p-plt-id AND buf_price-doc-forming.plt-db-num = p-plt-db-num )) " + " " + where-phrase-47) <> ""
          then  substitute('( &1 = 2 OR buf_price-doc-forming.stts =  &1 ) and                        ( &5&2&5 <> &5pl-type&5 OR                     ( buf_price-doc-forming.plt-id = &3 AND                        buf_price-doc-forming.plt-db-num = &4 )) ' ,                       r-status, p-mode, p-plt-id, p-plt-db-num , chr(34) )  + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + " " + " " + substitute(' , FIRST buf_price-list-type  WHERE        buf_price-list-type.plt-id = buf_price-doc-forming.plt-id AND       buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num &1  , FIRST x_grp-obj-price WHERE        x_grp-obj-price.gop-id     = buf_price-list-type.gop-id   AND       x_grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num  &2' ,       v-where-phrase , v-sort-phrase ))
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-47 =
          ("( r-status = 2 OR buf_price-doc-forming.stts =  r-status ) and                  ( p-mode <> 'pl-type' OR                  ( buf_price-doc-forming.plt-id = p-plt-id AND buf_price-doc-forming.plt-db-num = p-plt-db-num )) " + " " + where-phrase-47 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-1grp:handle
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
                          )
      .
      assign
        l-filter-open-47 = true
      .
    end.
    if l-filter-open-47 = false then do:
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
  if l-filter-open-47 = false then do:
    OPEN QUERY BROWSE-1grp FOR EACH buf_price-doc-forming no-lock
      where ( r-status = 2 OR buf_price-doc-forming.stts =  r-status ) and                  ( p-mode <> 'pl-type' OR                  ( buf_price-doc-forming.plt-id = p-plt-id AND buf_price-doc-forming.plt-db-num = p-plt-db-num ))
    , FIRST buf_price-list-type  WHERE       buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id AND         buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num , FIRST x_grp-obj-price WHERE        x_grp-obj-price.gop-id     = buf_price-list-type.gop-id   AND       x_grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_price-doc-forming )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-1grp:handle:get-buffer-handle(1) = (buffer buf_price-doc-forming:handle) then do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-4-47 =
        "where ":u +  substitute('( &1 = 2 OR buf_price-doc-forming.stts =  &1 ) and                        ( &5&2&5 <> &5pl-type&5 OR                     ( buf_price-doc-forming.plt-id = &3 AND                        buf_price-doc-forming.plt-db-num = &4 )) ' ,                       r-status, p-mode, p-plt-id, p-plt-db-num , chr(34) )  + " ":u + where-phrase-47 + " ":u + p-find-condition + " " + " "
      parameter-5-47 = ""
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-1grp:handle
                          ,input rowid(buf_price-doc-forming)
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input (buffer buf_price-doc-forming:handle)
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-47 = (if p-find-next then "true":u else "false":u )
      parameter-3-47 =  "FOR EACH buf_price-doc-forming"
      parameter-4-47 =
        (
          if ("( r-status = 2 OR buf_price-doc-forming.stts =  r-status ) and                  ( p-mode <> 'pl-type' OR                  ( buf_price-doc-forming.plt-id = p-plt-id AND buf_price-doc-forming.plt-db-num = p-plt-db-num )) " + " " + where-phrase-47) <> ""
          then  substitute('( &1 = 2 OR buf_price-doc-forming.stts =  &1 ) and                        ( &5&2&5 <> &5pl-type&5 OR                     ( buf_price-doc-forming.plt-id = &3 AND                        buf_price-doc-forming.plt-db-num = &4 )) ' ,                       r-status, p-mode, p-plt-id, p-plt-db-num , chr(34) )  + " " + where-phrase-47
          else "true"
        )
      parameter-5-47 = (" " + " " + " " + substitute(' , FIRST buf_price-list-type  WHERE        buf_price-list-type.plt-id = buf_price-doc-forming.plt-id AND       buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num &1  , FIRST x_grp-obj-price WHERE        x_grp-obj-price.gop-id     = buf_price-list-type.gop-id   AND       x_grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num  &2' ,       v-where-phrase , v-sort-phrase ) + " " + p-find-condition)
      parameter-6-47 = if sort-phrase-47 = ''
                           then
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "" +
          " " + sort-column-phrase +
        " " + sort-phrase-47
        )
      parameter-7-47 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-1grp:handle
                          ,input logical(parameter-2-47)
                          ,input no-lock
                          ,input parameter-3-47
                          ,input parameter-4-47
                          ,input parameter-5-47
                          ,input parameter-6-47
                          ,input parameter-7-47
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
APPLY "VALUE-CHANGED" TO BROWSE-1grp in frame Dialog-Frame.
APPLY "ENTRY" TO BROWSE-1grp.
OPEN QUERY BROWSE-2-pr FOR EACH buf_price-doc NO-LOCK WHERE       buf_price-doc.pdf-id = buf_price-doc-forming.pdf-id AND       buf_price-doc.pdf-db = buf_price-doc-forming.pdf-db AND       buf_price-doc.plt-id = buf_price-doc-forming.plt-id AND       buf_price-doc.plt-db-num = buf_price-doc-forming.plt-db-num INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE seach-pdf-id :
define input  parameter p-id as INTEGER no-undo .
define input  parameter p-next as logical   no-undo .
if p-next = true then do:
   find next buf_price-doc-forming no-lock where
      buf_price-doc-forming.pdf-id     = p-id no-error .
      if not available buf_price-doc-forming then do:
        message "Еще запись не найдена ! " view-as alert-box information .
        return .
      end.
end.
else do:
  find first buf_price-doc-forming no-lock where
             buf_price-doc-forming.pdf-id     = p-id
 no-error .
              if not available buf_price-doc-forming then do:
                message "Запись не найдена !" view-as alert-box information .
                return .
              end.
end.
reposition BROWSE-1grp to rowid rowid(buf_price-doc-forming) no-error .
apply "value-changed" to BROWSE-1grp in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE set-filter-name :
  define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = v-title-0  + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
        frame Dialog-Frame:title = v-title-0 .
      .
    end.
  end.
END PROCEDURE.
