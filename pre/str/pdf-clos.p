block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable p-recid       as recid     no-undo     .
define variable p-esc-prd     as logical   no-undo .
define variable p-esc-pra     as logical   no-undo .
define variable p-ecs-type    as character no-undo .
define variable p-ecs-code    as integer   no-undo .
define variable p-action      as character no-undo .
define variable p-trn-doc     as character no-undo .
define variable p-ask-pr      as logical   no-undo .
define variable p-do      as logical   no-undo .
define variable p-auto      as logical   no-undo .
define variable log-file-name                as character      no-undo init "pdf-clos.txt".
define variable o-db-num as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: dac5fd0fa801, 3654, test $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2024/01/25 16:33:07 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pdf-clos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pdf-clos.p $":U .
define variable vss-description as character no-undo init "Закрытие документа назначения цены".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION fnc-base-price RETURN decimal (local-bc      as integer,
                                        local-doc-num as char).
define buffer base-price        for ub.price-list.
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.
  run prc-base-code (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.doc-num = local-doc-num and
       base-price.b-code  = local-base-code and
       base-price.price-type = "" no-error.
  if not available base-price then do:
    run prc-main-code (input local-bc, output local-main-code).
    find  base-price no-lock where
          base-price.doc-num = local-doc-num and
          base-price.b-code  = local-main-code and
          base-price.price-type = "" no-error.
  end.
  if available base-price then
    return (base-price.price-sale).
  else
    return (?).
END FUNCTION.
procedure prc-main-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-main-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code        for ub.bar-code.
define buffer local-goods           for ub.goods.
define buffer main-code             for ub.bar-code.
define buffer main-prt              for ub.gds-prt.
  local-main-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find first  main-prt no-lock where
              main-prt.upper-code = local-goods.prt-root.
  find  main-code no-lock where
        main-code.gds-code  = local-bar-code.gds-code and
        main-code.in-code   = "" and
        main-code.part-code = "" and
        main-code.unit-cli  = local-goods.unit-base and
        main-code.node-code = main-prt.node-code.
  local-main-code = main-code.b-code.
end procedure.
procedure prc-base-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-base-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code for ub.bar-code.
define buffer local-goods    for ub.goods.
define buffer base-code      for ub.bar-code.
  local-base-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find base-code no-lock where
       base-code.gds-code  = local-bar-code.gds-code and
       base-code.node-code = local-bar-code.node-code and
       base-code.in-code   = local-bar-code.in-code and
       base-code.part-code = local-bar-code.part-code and
       base-code.unit-cli  = local-goods.unit-base.
  local-base-code = base-code.b-code.
end procedure.
p-auto  = logical (entry(10,p-parameter,chr(4))) no-error .
  if error-status :error then p-auto = false .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable par-pr-incpc as character no-undo.
define variable par-pr-rndmt as character no-undo.
define variable par-pr-rndbs as character no-undo.
define variable par-pr-clt-q as character no-undo.
define variable par-pr-dpl-q as character no-undo.
define variable par-pr-rdc-q as character no-undo.
define variable par-pr-abs-d as character no-undo.
define variable par-pr-altex as character no-undo.
define variable par-pr-parex as character no-undo.
define variable par-pr-sclex as character no-undo.
define variable par-pr-notls as character no-undo.
define variable par-pr-equ-dq as integer  no-undo.
define variable par-pr-discm as character no-undo .
define variable par-pr-dscnt as character no-undo .
define variable par-pr-print as character no-undo .
define variable par-pr-sigma as character no-undo .
define variable par-pr-goods as character no-undo.
define variable par-pr-nogds as character no-undo.
define variable par-alcohol  as character no-undo.
define variable par-gen-mrgn-ie as character no-undo .
define variable par-gen-mrgn-iv as character no-undo .
define variable par-gen-mrgn-im as character no-undo .
define variable par-pr-nakl-ie  as logical   no-undo .
define variable par-pr-nakl-iv  as logical   no-undo .
define variable par-pr-nakl-im  as logical   no-undo .
define variable par-pr-nogds-long as longchar no-undo .
define temp-table tmp-proof-price no-undo
  field node-code like ub.gds-grp.node-code
  field proof as decimal
  field price as decimal
index pi node-code proof descending .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ggoattr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
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
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info28 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure  chec-par :
define output parameter l-par as logical no-undo .
define input parameter l-host like ub.clients.obj-code no-undo .
define input parameter l-type like ub.clients.obj-type no-undo .
define input parameter l-code like ub.clients.obj-code no-undo .
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol'
  ,input  l-host
  ,input  l-type
  ,input  l-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-alcohol
  ,output par-type
  ) no-error .
 .
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input l-type
  ,input l-code
  ,input 'overval':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'pr-clt-q':U then par-pr-clt-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-dpl-q':U then par-pr-dpl-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-rdc-q':U then par-pr-rdc-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-equ-dq':U then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = 'pr-abs-d':U then par-pr-abs-d = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-altex':U then par-pr-altex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-parex':U then par-pr-parex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sclex':U then par-pr-sclex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-discm':U then par-pr-discm =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-dscnt':U then par-pr-dscnt  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-print':U then par-pr-print  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sigma':U then par-pr-sigma  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-incpc':U then par-pr-incpc  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-rndmt':U then par-pr-rndmt  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-rndbs':U then par-pr-rndbs  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-notls':U then par-pr-notls = string ( thbjattr_thbj-attr.property-value-logical) .
    if v-cntxt-db-num = 0 then do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds0':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods0':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
    else do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplmrgn in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-gen-mrgn-ie
  ,output par-gen-mrgn-iv
  ,output par-gen-mrgn-im
  ) no-error .
   IF error-status :error THEN message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "gbl/gtplmrgn.i"
     view-as alert-box error
   .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplpnakl in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-pr-nakl-ie
  ,output par-pr-nakl-iv
  ,output par-pr-nakl-im
  ) no-error .
   define variable ii as integer   no-undo .
   define variable nn as integer   no-undo .
   define variable v-fullname as character no-undo .
   nn = num-entries ( par-pr-nogds ).
   par-pr-nogds-long = "".
   if par-pr-nogds <> "0" and par-pr-nogds <> ""  then do:
      repeat ii = 1 to nn :
        run grplib-get-full-name  ( input integer(entry(ii,par-pr-nogds)) , output v-fullname ) .
        par-pr-nogds-long = par-pr-nogds-long + v-fullname + chr(4) .
      end.
      par-pr-nogds-long = trim (par-pr-nogds-long,chr(4)) .
   end.
l-par = true .
end procedure.
PROCEDURE cre-pr-list:
define input  parameter bc      like ub.price-list.b-code no-undo.
define input  parameter new-num like ub.price-doc.doc-num no-undo.
define output parameter new-rec as recid             no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer root-gds-prt   for ub.gds-prt.
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define variable cur-rt-base as decimal no-undo .
define variable cur-rt-rubl as decimal no-undo .
define variable p-hostcode as int no-undo .
define variable v-line-num as integer no-undo .
define variable v-skip-del-gds as logical no-undo initial no .
cre-pr:
do on error undo cre-pr, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  run check-use-bar-code ( buf-bar-code.b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo cre-pr, return.
  end.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find first root-gds-prt no-lock where
            root-gds-prt.upper-code = buf-goods.prt-root.
  if root-gds-prt.node-name <> '_Пустая шкала':U and
    buf-bar-code.in-code <> "" then do:
    message
      "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
    v-skip-del-gds = p-auto .
  if buf-goods.stts <> 0 and not v-skip-del-gds then do:
    message
      "Не допускается создавать цены на удаленные товары!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = new-num.
define variable v-ret as logical no-undo .
   run ver-modificator-price-is-null (
          input    buf-goods.artic        ,
          input    buf-goods.prod-type    ,
          input    buf-goods.prod-code    ,
          input    buf-price-doc.obj-type   ,
          input    buf-price-doc.obj-code   ,
          output   v-ret ).
      if v-ret = false then dO:
          message
            "Не допускается создавать цены на модификаторы с нулевой ценой !" skip (2)
            "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
            view-as alert-box error.
          undo cre-pr, return.
        end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
  find first buf-price-list where
            buf-price-list.b-code  = buf-bar-code.b-code and
            buf-price-list.doc-num = new-num  and
            buf-price-list.price-type = ""    no-error .
  if not available buf-price-list then do:
    run calc-price-line-num (input  new-num , output v-line-num) .
    create buf-price-list.
    assign
      buf-price-list.line-num  = v-line-num
      buf-price-list.b-code    = buf-bar-code.b-code
      buf-price-list.doc-num   = buf-price-doc.doc-num
      buf-price-list.prod-type = buf-goods.prod-type
      buf-price-list.prod-code = buf-goods.prod-code
      buf-price-list.artic     = buf-goods.artic
      buf-price-list.obj-type  = buf-price-doc.obj-type
      buf-price-list.obj-code  = buf-price-doc.obj-code
      buf-price-list.vat-pc    = local_vat-pc
      buf-price-list.slt-pc    = local_slt-pc
      buf-price-list.price-prev = cur-pr
      .
    if  buf-gds-prt.upper-code = buf-goods.prt-root and
        buf-bar-code.in-code   = "" and
        buf-bar-code.part-code = "" and
        buf-bar-code.unit-cli  = buf-goods.unit-base then do:
      buf-price-list.main-price = yes.
      if cur-pr <> ? then do:
        run exp-prt (input buf-goods.gds-code,
                    input cur-dn,
                    input new-num,
                    output new-rec) no-error.
        if error-status :error then do:
          message
            "Ошибка вызова процедуры разворота специальных и неосновных цен."
            view-as alert-box error.
          undo cre-pr, return error.
        end.
      end.
    end.
    else do:
      if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
        buf-price-list.d-pcnt = ?.
      end.
      buf-price-list.main-price = no.
    end.
  end.
end.
new-rec = recid (buf-price-list).
END PROCEDURE.
procedure calc-price-line-num :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-num as character no-undo .
define output parameter p-num  as integer no-undo .
define variable v-fact as integer no-undo .
define buffer buf_1_price-list for ub.price-list .
p-num = 1 .
find last  buf_1_price-list no-lock where
           buf_1_price-list.doc-num = p-doc-num use-index line-num no-error .
           if available buf_1_price-list then
                assign
                  v-fact = buf_1_price-list.line-num
                .
v-fact = v-fact + 1.
if v-fact <> ? then if p-num < v-fact then p-num = v-fact .
 end.
end procedure.
PROCEDURE del-pr-list:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define variable l-ov-on as logical no-undo .
del-pr:
do on error undo del-pr, return error:
  find first  buf-price-list no-lock where
              buf-price-list.doc-num    = d-num and
              buf-price-list.b-code     = bc and
              buf-price-list.price-type = "" no-error.
  if not available buf-price-list then
    undo del-pr, return error.
  find  buf-goods no-lock where
        buf-goods.prod-type = buf-price-list.prod-type and
        buf-goods.prod-code = buf-price-list.prod-code and
        buf-goods.artic     = buf-price-list.artic.
  if buf-price-list.main-price then do:
    for each  buf-price-list exclusive-lock where
              buf-price-list.doc-num   = d-num and
              buf-price-list.artic     = buf-goods.artic and
              buf-price-list.prod-type = buf-goods.prod-type and
              buf-price-list.prod-code = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code = buf-price-list.b-code
    on error undo del-pr, return error:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=request:exclusive'
  ,output l-ov-on
  ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака товара на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      if l-ov-on then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=false'
  ,output l-ov-on
  ) no-error .
        if error-status :error then do:
        end.
       end.
      delete buf-price-list.
    end.
  end.
  else do:
    find  buf-bar-code no-lock where
          buf-bar-code.b-code = buf-price-list.b-code.
    if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
      message
        "Нельзя удалить неосновную цену." skip
        "Неосновная цена (скидка) не может быть неопределенной." skip
        "Код:" bc skip
        "Переоценка:" d-num
        view-as alert-box error.
      undo del-pr, return error.
    end.
    find current buf-price-list exclusive-lock no-error .
    delete buf-price-list.
    run calc-base-upd (input buf-bar-code.b-code,
                      input d-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo del-pr, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-base-upd:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer alt-bar-code   for ub.bar-code.
define buffer alt-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
calc-base:
do on error undo calc-base, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  for each  alt-bar-code no-lock where
            alt-bar-code.gds-code  = buf-bar-code.gds-code and
            alt-bar-code.node-code = buf-bar-code.node-code and
            alt-bar-code.part-code = buf-bar-code.part-code and
            alt-bar-code.in-code   = buf-bar-code.in-code and
            alt-bar-code.unit-cli <> buf-goods.unit-base,
      each  alt-price-list where
            alt-price-list.doc-num    = d-num and
            alt-price-list.b-code     = alt-bar-code.b-code and
            alt-price-list.price-type = ""
      on error undo calc-base, return error:
    run calc-pr-alt (input d-num,
                    input alt-bar-code.b-code,
                    input round-method,
                    input round-base) no-error.
    if error-status:error then
      undo calc-base, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-alt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter r-method as character             no-undo.
define input parameter r-base   as decimal              no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-alt:
do on error undo pr-alt, return error:
  if r-method = ? or
     r-base = ? then do:
    message
      "Нельзя удалить основную цену." skip
      "Не задан способ округления для расчета зависящих от нее неосновных цен." skip
      "Код:" bc skip
      "Переоценка:" d-num
      view-as alert-box error.
    undo pr-alt, return error.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  if buf-price-list.d-pcnt = ? then do:
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output pr-rec
  ,output pr-c-b-r
  )  .
    find old-price-list no-lock where
        recid (old-price-list) = pr-rec no-error.
    if available old-price-list and
      old-price-list.b-code = bc then
      buf-price-list.d-pcnt = old-price-list.d-pcnt.
    else
      buf-price-list.d-pcnt = 0.
  end.
   if buf-price-list.d-pcnt = ? then do:
      assign
        buf-price-list.price-sale =   if available old-price-list then old-price-list.price-sale else 0
        buf-price-list.calc-method =  'Не-считать':U + 'Основная':U
        .
  end.
  else do:
      assign
        buf-price-list.price-sale =   fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) *
                                      buf-bar-code.cli-base-rate *
                                      (1 - buf-price-list.d-pcnt / 100)
        buf-price-list.calc-method =  'Основная':U
        .
case r-method :
  when '9-окончание':U then do:
    if buf-price-list.price-sale < 29 then do:
      if (buf-price-list.price-sale - truncate (buf-price-list.price-sale, 0)) <> 0 then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 1
        .
      end.
    end.
    else do:
      if (buf-price-list.price-sale modulo 10) < 3 then do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if buf-price-list.price-sale < r-base then do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 0.99
      .
    end.
    else do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
    .
  end.
  when 'Произвольно':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale / r-base, 0) * r-base
      .
      if buf-price-list.price-sale = 0 then do:
        assign
          buf-price-list.price-sale = r-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if r-base <> 0 then do:
      if truncate ( buf-price-list.price-sale / r-base, 0 ) <> (buf-price-list.price-sale / r-base) then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale / r-base, 0) * r-base + r-base
        .
      end.
    end.
    if buf-price-list.price-sale = 0 then do:
      assign
        buf-price-list.price-sale = r-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = buf-price-list.price-sale * r-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" r-method skip
      "round-base"   r-base   skip
      "price"        buf-price-list.price-sale             skip
      view-as alert-box error .
  end.
end.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-discnt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-discnt:
do on error undo pr-discnt, return error:
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  buf-price-list.d-pcnt = (1 -
                           buf-price-list.price-sale /
                           fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) /
                           buf-bar-code.cli-base-rate) *
                           100
                           .
end.
END PROCEDURE.
PROCEDURE calc-pr-sub :
define  input  parameter bc             like ub.price-list.b-code no-undo.
define  input  parameter d-num          like ub.price-doc.doc-num no-undo.
define  input  parameter calc-method  as character    no-undo.
define  input  parameter increase-pc  as decimal      no-undo.
define  input  parameter round-method as character    no-undo.
define  input  parameter round-base   as decimal      no-undo.
define  output parameter calc-rec     as recid        no-undo.
define  buffer buf-price-list for ub.price-list.
define  buffer buf-bar-code   for ub.bar-code.
define  buffer buf-goods      for ub.goods.
define  buffer buf-gds-prt    for ub.gds-prt.
define  buffer buf-gds-grp    for ub.gds-grp.
define  buffer buf-price-doc  for ub.price-doc.
calc-sub:
do on error undo calc-sub, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  calc-rec = recid (buf-price-list).
  if buf-price-list.main-price then do:
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code   = buf-price-list.b-code and
              buf-bar-code.unit-cli = buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-list (input  buf-bar-code.b-code,
                        input  buf-price-list.doc-num,
                        input  calc-method,
                        input  increase-pc,
                        input  round-method,
                        input  round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output calc-rec) no-error.
      if error-status :error then
        undo calc-sub, return error.
      calc-rec = recid (buf-price-list).
    end.
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code    = buf-price-list.b-code and
              buf-bar-code.unit-cli <> buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-alt (input buf-price-doc.doc-num,
                      input buf-bar-code.b-code,
                      input round-method,
                      input round-base) no-error.
      if error-status :error then
        undo calc-sub, return error.
    end.
  end.
  else do:
    run calc-base-upd (input buf-bar-code.b-code,
                      input buf-price-doc.doc-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo calc-sub, return error.
  end.
end.
END PROCEDURE.
procedure ver-pr-nogds :
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-par-pr-nogds  as character no-undo .
define output parameter p-not           as logical   no-undo .
define output parameter p-str           as character no-undo .
define buffer buf_goods for ub.goods  .
define variable nn as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-namegrp as character no-undo .
  do
  on error undo, return error return-value
  :
  if p-par-pr-nogds = "1" then do:
     assign
      p-not = true
      p-str = ""
     .
     return .
  end.
  assign
    p-not = false
    p-str = ""
  .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  nn = num-entries(par-pr-nogds-long,chr(4)) .
  repeat ii = 1 to nn:
     v-namegrp = entry(ii , par-pr-nogds-long , chr(4) ) no-error .
     if buf_goods.grp-name  begins v-namegrp  then do:
        assign
          p-not = true
          p-str = substitute ( "Товар &1 &2 &3  может быть включен в ДНЦ из-за исключения запрета по группе : &4"  , buf_goods.artic, buf_goods.gds-name , buf_goods.grp-name , v-namegrp )
        .
        leave .
     end.
  end.
  end.
end procedure.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ver-modificator-price-is-null :
 do
 on error undo, return error return-value
 :
define input parameter p-artic     like ub.goods.artic no-undo.
define input parameter p-prod-type like ub.goods.prod-type no-undo.
define input parameter p-prod-code like ub.goods.prod-code no-undo.
define input parameter p-obj-type  like ub.clients.obj-type no-undo.
define input parameter p-obj-code  like ub.clients.obj-code no-undo.
define output parameter p-ret as logical no-undo .
define variable v-gds-code  like ub.goods.gds-code no-undo .
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
p-ret = true .
find first buf_fbr-gds-obj no-lock where
            buf_fbr-gds-obj.gds-code = v-gds-code and
            buf_fbr-gds-obj.obj-code = p-obj-code and
            buf_fbr-gds-obj.obj-type = p-obj-type use-index pi no-error .
 if available buf_fbr-gds-obj then
              if buf_fbr-gds-obj.is-modificator = true and
                 buf_fbr-gds-obj.is-null-price = true
                 then  p-ret = false .
 end.
end procedure.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure create-price-all :
define input  parameter p-main                   as integer   no-undo .
define input  parameter p-plt-id                 as integer   no-undo .
define input  parameter p-plt-db-num             as integer   no-undo .
define input  parameter p-pdf-id                 as integer   no-undo .
define input  parameter p-pdf-db-num             as integer   no-undo .
define input  parameter p-b-code                 as integer   no-undo .
define input  parameter p-gds-code               as integer   no-undo .
define input  parameter p-type-price             as integer   no-undo .
define input  parameter p-qnty-from              like  ub.price-doc-forming-gds-qnty.ggr-qnty no-undo .
define input  parameter p-qnty-to                like  ub.price-doc-forming-gds-qnty.ggr-qnty no-undo .
define input  parameter p-sum-from               as decimal   no-undo .
define input  parameter p-sum-to                 as decimal   no-undo .
define input  parameter p-turnover-from          as decimal   no-undo .
define input  parameter p-turnover-to            as decimal   no-undo .
define input  parameter p-fact-order-shift-from  as decimal   no-undo .
define input  parameter p-fact-order-shift-to    as decimal   no-undo .
define input  parameter p-fact-order-sys-from    as decimal   no-undo .
define input  parameter p-fact-order-sys-to      as decimal   no-undo .
define input  parameter p-price-sale             as decimal   no-undo .
define buffer b_price-list-type            for ub.price-list-type  .
define buffer b_price-list-type-cash-pay   for ub.price-list-type-cash-pay  .
define buffer b_price-list-type-pay-type   for ub.price-list-type-pay-type  .
define buffer b_price-doc-forming for ub.price-doc-forming .
define variable v-curr-obj-date as date   no-undo .
  do
  on error undo, return error return-value
  :
find first b_price-list-type no-lock where
           b_price-list-type.plt-id     = p-plt-id   and
           b_price-list-type.plt-db-num = p-plt-db-num
           no-error .
            if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute ( "Ошибка: &1 &2 " , error-status :get-message(1) , return-value)).
            end.
find first b_price-doc-forming no-lock where
           b_price-doc-forming.pdf-db     = p-pdf-db-num and
           b_price-doc-forming.pdf-id     = p-pdf-id     and
           b_price-doc-forming.plt-db-num = p-plt-db-num and
           b_price-doc-forming.plt-id     = p-plt-id
           no-error .
            if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute ( "Ошибка: &1 &2 " , error-status :get-message(1) , return-value)).
            end.
  for each x_obj-group:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output v-curr-obj-date
  ) no-error .
            if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute ( "Неправильная дата на объекте: &1 &2  &3 &4" , x_obj-group.obj-type , x_obj-group.obj-code, error-status :get-message(1) , return-value)).
                delete x_obj-group.
                next.
            end.
      if b_price-list-type.main = true  then do:
         if x_obj-group.db-num <> v-cntxt-db-num and  v-cntxt-db-num <> 0 then next .
      end.
      if b_price-list-type.use-cash-pay = 1 then do:
         for each b_price-list-type-cash-pay no-lock where
                  b_price-list-type-cash-pay.plt-id     = p-plt-id   and
                  b_price-list-type-cash-pay.plt-db-num = p-plt-db-num
                  :
                  run proc-mpl-create-price-all in this-procedure (
                   buffer b_price-list-type
                  ,buffer b_price-doc-forming
                  ,input v-curr-obj-date
                  ,input  p-main
                  ,input  p-plt-id
                  ,input  p-plt-db-num
                  ,input  p-pdf-id
                  ,input  p-pdf-db-num
                  ,input  p-b-code
                  ,input  p-gds-code
                  ,input  p-type-price
                  ,input  p-qnty-from
                  ,input  p-qnty-to
                  ,input  p-sum-from
                  ,input  p-sum-to
                  ,input  p-turnover-from
                  ,input  p-turnover-to
                  ,input  p-fact-order-shift-from
                  ,input  p-fact-order-shift-to
                  ,input  p-fact-order-sys-from
                  ,input  p-fact-order-sys-to
                  ,input  p-price-sale
                  ,input  0
                  ,input  b_price-list-type-cash-pay.cdpay-code
                  ,input  b_price-list-type-cash-pay.curr-code
                  ).
         end.
      end.
      if b_price-list-type.use-pay-type = 1 then do:
         for each b_price-list-type-pay-type no-lock where
                  b_price-list-type-pay-type.plt-id     = p-plt-id   and
                  b_price-list-type-pay-type.plt-db-num = p-plt-db-num
                  :
                  run proc-mpl-create-price-all in this-procedure (
                   buffer b_price-list-type
                  ,buffer b_price-doc-forming
                  ,input v-curr-obj-date
                  ,input  p-main
                  ,input  p-plt-id
                  ,input  p-plt-db-num
                  ,input  p-pdf-id
                  ,input  p-pdf-db-num
                  ,input  p-b-code
                  ,input  p-gds-code
                  ,input  p-type-price
                  ,input  p-qnty-from
                  ,input  p-qnty-to
                  ,input  p-sum-from
                  ,input  p-sum-to
                  ,input  p-turnover-from
                  ,input  p-turnover-to
                  ,input  p-fact-order-shift-from
                  ,input  p-fact-order-shift-to
                  ,input  p-fact-order-sys-from
                  ,input  p-fact-order-sys-to
                  ,input  p-price-sale
                  ,input  b_price-list-type-pay-type.pay-code
                  ,input  0
                  ,input  0
                  ).
         end.
      end.
      if b_price-list-type.use-pay-type = 0 and b_price-list-type.use-cash-pay = 0 then do:
                  run proc-mpl-create-price-all in this-procedure (
                   buffer b_price-list-type
                  ,buffer b_price-doc-forming
                  ,input v-curr-obj-date
                  ,input  p-main
                  ,input  p-plt-id
                  ,input  p-plt-db-num
                  ,input  p-pdf-id
                  ,input  p-pdf-db-num
                  ,input  p-b-code
                  ,input  p-gds-code
                  ,input  p-type-price
                  ,input  p-qnty-from
                  ,input  p-qnty-to
                  ,input  p-sum-from
                  ,input  p-sum-to
                  ,input  p-turnover-from
                  ,input  p-turnover-to
                  ,input  p-fact-order-shift-from
                  ,input  p-fact-order-shift-to
                  ,input  p-fact-order-sys-from
                  ,input  p-fact-order-sys-to
                  ,input  p-price-sale
                  ,input  0
                  ,input  0
                  ,input  0
                  ).
      end.
   end.
 end.
end procedure.
procedure create-price-list-mpl :
define input  parameter p-pdf-db-num  as integer   no-undo .
define input  parameter p-pdf-id      as integer   no-undo .
define input  parameter p-plt-db-num  as integer   no-undo .
define input  parameter p-plt-id      as integer   no-undo .
define output parameter p-price-doc-recid as recid no-undo .
define output parameter p-list-recid as character no-undo .
define buffer b_price-list-type   for ub.price-list-type   .
define buffer b_price-doc-forming for ub.price-doc-forming .
define buffer b_price-doc-forming-gds for ub.price-doc-forming-gds .
define buffer b_price-all         for ub.price-all .
define buffer b_price-doc         for ub.price-doc .
define buffer bufnew_price-list   for ub.price-list  .
define variable v-base as logical   no-undo .
define variable p-first-ie as integer   no-undo .
define variable p-first-iv as integer   no-undo .
define variable p-first-im as integer   no-undo .
define variable p-second-ie as integer   no-undo .
define variable p-second-iv as integer   no-undo .
define variable p-second-im as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
p-list-recid = "".
find first b_price-list-type no-lock where
           b_price-list-type.plt-id     = p-plt-id   and
           b_price-list-type.plt-db-num = p-plt-db-num
           no-error .
           if error-status :error then message
             vss-workfile vss-revision vss-description skip
             error-status :get-message(1) skip
             return-value skip
             "price-list-type"
             view-as alert-box error
           .
IF not ( b_price-list-type.main = true  and
         b_price-list-type.create-price-doc = 1  ) then return .
find first b_price-doc-forming no-lock where
           b_price-doc-forming.pdf-db     = p-pdf-db-num and
           b_price-doc-forming.pdf-id     = p-pdf-id     and
           b_price-doc-forming.plt-db-num = p-plt-db-num and
           b_price-doc-forming.plt-id     = p-plt-id
           no-error .
           if error-status :error then message
             vss-workfile vss-revision vss-description skip
             error-status :get-message(1) skip
             return-value skip
             ""
             view-as alert-box error
           .
define variable v-make as logical   no-undo .
v-make = true  .
define buffer buf_trn-doc for ub.trn-doc  .
find first buf_trn-doc no-lock where
           buf_trn-doc.doc-code = b_price-doc-forming.out-code no-error .
if available buf_trn-doc then do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtpl-fs in g#library2
 ( input  parparentproc
  ,input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output p-first-ie
  ,output p-first-iv
  ,output p-first-im
  ,output p-second-ie
  ,output p-second-iv
  ,output p-second-im
  ) no-error .
   define buffer bb_price-doc-forming-attr for ub.price-doc-forming-attr  .
   find first bb_price-doc-forming-attr exclusive-lock where
              bb_price-doc-forming-attr.plt-id       = p-plt-id       and
              bb_price-doc-forming-attr.plt-db-num   = p-plt-db-num   and
              bb_price-doc-forming-attr.pdf-id       = p-pdf-id       and
              bb_price-doc-forming-attr.pdf-db       = p-pdf-db-num   and
              bb_price-doc-forming-attr.attr-code    = 'first-price':U   no-error .
      if available bb_price-doc-forming-attr then do:
          if buf_trn-doc.ext-doc-type = 'ie':U and p-first-ie = 0 then v-make = false .
          if buf_trn-doc.ext-doc-type = 'iv':U and p-first-iv = 0 then v-make = false .
          if buf_trn-doc.ext-doc-type = 'im':U  and p-first-im = 0 then v-make = false .
      end.
      else do:
          if buf_trn-doc.ext-doc-type = 'ie':U and p-second-ie = 0 then v-make = false .
          if buf_trn-doc.ext-doc-type = 'iv':U and p-second-iv = 0 then v-make = false .
          if buf_trn-doc.ext-doc-type = 'im':U  and p-second-im = 0 then v-make = false .
      end.
end.
define variable p-update as logical   no-undo .
define buffer   b_bar-code for ub.bar-code  .
define variable p-recid-str as recid no-undo .
  for each x_obj-group where v-make = true or (x_obj-group.obj-code = v-cntxt-obj-code and x_obj-group.obj-type = v-cntxt-obj-type) no-lock :
      if x_obj-group.db-num <> v-cntxt-db-num and v-cntxt-db-num <> 0 then next .
      run prcreate-new-price-doc in this-procedure
          ( input v-cntxt-db-num ,
            input x_obj-group.obj-type  ,
            input x_obj-group.obj-code   ,
            input p-plt-id      ,
            input p-plt-db-num  ,
            input p-pdf-id      ,
            input p-pdf-db-num  ,
            output p-price-doc-recid
            ) .
        p-list-recid = p-list-recid + string(p-price-doc-recid) + "," .
        find first b_price-doc no-lock where recid(b_price-doc) = p-price-doc-recid no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "3"
          view-as alert-box error
        .
        for each  ub.price-doc-forming-attr exclusive-lock where
                  ub.price-doc-forming-attr.plt-id       = p-plt-id       and
                  ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num   and
                  ub.price-doc-forming-attr.pdf-id       = p-pdf-id       and
                  ub.price-doc-forming-attr.pdf-db       = p-pdf-db-num :
              find first ub.doc-attr exclusive-lock where
                         ub.doc-attr.doc-code  = b_price-doc.doc-num  and
                         ub.doc-attr.attr-code = ub.price-doc-forming-attr.attr-code no-error .
                     if not available ub.doc-attr then create ub.doc-attr.
                     assign
                        ub.doc-attr.doc-code   = b_price-doc.doc-num
                        ub.doc-attr.attr-code  = ub.price-doc-forming-attr.attr-code
                        ub.doc-attr.attr-value = ub.price-doc-forming-attr.attr-value
                     .
        end.
        for each b_price-all exclusive-lock where
           b_price-all.pdf-db     = p-pdf-db-num and
           b_price-all.pdf-id     = p-pdf-id     and
           b_price-all.plt-db-num = p-plt-db-num and
           b_price-all.plt-id     = p-plt-id and
           b_price-all.obj-type   =  x_obj-group.obj-type and
           b_price-all.obj-code   =  x_obj-group.obj-code and
           b_price-all.main-indication <= 1 :
           find first b_price-doc-forming-gds no-lock where
                      b_price-doc-forming-gds.b-code     = b_price-all.b-code and
                      b_price-doc-forming-gds.pdf-db     = p-pdf-db-num and
                      b_price-doc-forming-gds.pdf-id     = p-pdf-id     and
                      b_price-doc-forming-gds.plt-db-num = p-plt-db-num and
                      b_price-doc-forming-gds.plt-id     = p-plt-id
                      no-error .
           find first b_bar-code no-lock where  b_bar-code.b-code = b_price-all.b-code no-error .
           if available b_bar-code then do:
                  run cre-pr-list in this-procedure
                  ( input  b_price-all.b-code
                  , input  b_price-doc.doc-num
                  , output p-recid-str).
                  find first bufnew_price-list exclusive-lock where
                      recid(bufnew_price-list) = p-recid-str no-error .
                      if available bufnew_price-list then do:
                          bufnew_price-list.calc-method =  b_price-doc-forming-gds.calc-method .
                          bufnew_price-list.d-pcnt      =  b_price-doc-forming-gds.d-pcnt.
                          if v-base then assign
                            bufnew_price-list.road-tax   =  b_price-doc-forming-gds.road-tax-base
                            bufnew_price-list.price-sale =  b_price-doc-forming-gds.price-sale-base
                            bufnew_price-list.price-calc =  b_price-doc-forming-gds.price-calc-base
                            bufnew_price-list.price-prev =  b_price-doc-forming-gds.price-prev-base
                          .
                          else assign
                            bufnew_price-list.road-tax   =  b_price-doc-forming-gds.road-tax-rubl
                            bufnew_price-list.price-sale =  b_price-doc-forming-gds.price-sale-rubl
                            bufnew_price-list.price-calc =  b_price-doc-forming-gds.price-calc-rubl
                            bufnew_price-list.price-prev =  b_price-doc-forming-gds.price-prev-rubl
                          .
                      end.
                  if available b_price-doc then do:
                      b_price-all.out-code   =  b_price-doc.doc-num .
                  end.
           end.
        end.
  end.
  p-list-recid = trim (p-list-recid, "," ) .
end.
end procedure.
procedure proc-mpl-create-price-all :
DEFINE PARAMETER BUFFER b_price-list-type FOR ub.price-list-type         .
DEFINE PARAMETER BUFFER b_price-doc-forming FOR ub.price-doc-forming      .
define input  parameter v-curr-obj-date as date   no-undo .
define input  parameter p-main                   as integer   no-undo .
define input  parameter p-plt-id                 as integer   no-undo .
define input  parameter p-plt-db-num             as integer   no-undo .
define input  parameter p-pdf-id                 as integer   no-undo .
define input  parameter p-pdf-db-num             as integer   no-undo .
define input  parameter p-b-code                 as integer   no-undo .
define input  parameter p-gds-code               as integer   no-undo .
define input  parameter p-type-price             as integer   no-undo .
define input  parameter p-qnty-from              like  ub.price-doc-forming-gds-qnty.ggr-qnty no-undo .
define input  parameter p-qnty-to                like  ub.price-doc-forming-gds-qnty.ggr-qnty no-undo .
define input  parameter p-sum-from               as decimal   no-undo .
define input  parameter p-sum-to                 as decimal   no-undo .
define input  parameter p-turnover-from          as decimal   no-undo .
define input  parameter p-turnover-to            as decimal   no-undo .
define input  parameter p-fact-order-shift-from  as decimal   no-undo .
define input  parameter p-fact-order-shift-to    as decimal   no-undo .
define input  parameter p-fact-order-sys-from    as decimal   no-undo .
define input  parameter p-fact-order-sys-to      as decimal   no-undo .
define input  parameter p-price-sale             as decimal   no-undo .
define input  parameter p-pay-code               as integer   no-undo .
define input  parameter p-cdpay-code             as integer   no-undo .
define input  parameter p-curr-pay-code          as integer   no-undo .
  do
  on error undo, return error return-value
  :
         create ub.price-all.
         assign
            ub.price-all.main-indication           = p-main
            ub.price-all.status_                   = if b_price-list-type.main = false then 'акт':U else ""
            ub.price-all.type-price                = p-type-price
            ub.price-all.pal-db-num                = v-cntxt-db-num
            ub.price-all.pal-id                    = next-value ( s-pal , ub )
            ub.price-all.b-code                    = p-b-code
            ub.price-all.gds-code                  = p-gds-code
            ub.price-all.obj-code                  = x_obj-group.obj-code
            ub.price-all.obj-type                  = x_obj-group.obj-TYPE
            ub.price-all.bgr-db-num                = b_price-list-type.bgr-db-num
            ub.price-all.bgr-id                    = b_price-list-type.bgr-id
            ub.price-all.curr-code                 = b_price-list-type.curr-code
            ub.price-all.pdf-id                    = p-pdf-id
            ub.price-all.pdf-db                    = p-pdf-db-num
            ub.price-all.pdf-base-rate             = b_price-doc-forming.base-rate
            ub.price-all.pdf-base-scale            = b_price-doc-forming.base-scale
            ub.price-all.pdf-exch-rate             = b_price-doc-forming.exch-rate
            ub.price-all.pdf-exch-scale            = b_price-doc-forming.exch-scale
            ub.price-all.plt-id                    = p-plt-id
            ub.price-all.plt-db-num                = p-plt-db-num
            ub.price-all.plt-fix-cource-crc-base   = b_price-list-type.fix-cource-crc-base
            ub.price-all.plt-fix-cource-crc-doc    = b_price-list-type.fix-cource-crc-doc
            ub.price-all.plt-priority              = b_price-list-type.priority
            ub.price-all.plt-work-date             = b_price-list-type.work-date
            ub.price-all.qnty-from                 = p-qnty-from
            ub.price-all.qnty-to                   = p-qnty-to
            ub.price-all.sum-from                  = p-sum-from
            ub.price-all.sum-to                    = p-sum-to
            ub.price-all.turnover-from             = p-turnover-from
            ub.price-all.turnover-to               = p-turnover-to
            ub.price-all.tog-db-num                = b_price-list-type.tog-db-num
            ub.price-all.tog-id                    = b_price-list-type.tog-id
            ub.price-all.use-cash-pay              = b_price-list-type.use-cash-pay
            ub.price-all.use-pay-type              = b_price-list-type.use-pay-type
            ub.price-all.price-sale                = p-price-sale
            ub.price-all.start-date                =  if b_price-list-type.main = true then  v-curr-obj-date else b_price-doc-forming.start-date
            ub.price-all.start-shift-date          =  b_price-doc-forming.start-shift-date
            ub.price-all.start-shift-name          =  b_price-doc-forming.start-shift-name
            ub.price-all.start-shift-num           =  b_price-doc-forming.start-shift-num
            ub.price-all.start-sys-date            =  b_price-doc-forming.start-sys-date
            ub.price-all.start-sys-time            =  b_price-doc-forming.start-sys-time
            ub.price-all.end-date                  =  b_price-doc-forming.end-date
            ub.price-all.end-shift-date            =  b_price-doc-forming.end-shift-date
            ub.price-all.end-shift-name            =  b_price-doc-forming.end-shift-name
            ub.price-all.end-shift-num             =  b_price-doc-forming.end-shift-num
            ub.price-all.end-sys-date              =  b_price-doc-forming.end-sys-date
            ub.price-all.end-sys-time              =  b_price-doc-forming.end-sys-time
            ub.price-all.fact-order-shift-from     = p-fact-order-shift-from
            ub.price-all.fact-order-shift-to       = p-fact-order-shift-to
            ub.price-all.fact-order-sys-from       = p-fact-order-sys-from
            ub.price-all.fact-order-sys-to         = p-fact-order-sys-to
            ub.price-all.pay-code      = p-pay-code
            ub.price-all.cdpay-code    = p-cdpay-code
            ub.price-all.curr-pay-code = p-curr-pay-code
            ub.price-all.extra-pcnt            = ?
            ub.price-all.extra-round           = ?
            ub.price-all.work-acc-price        = ?
            no-error .
            if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute ( "Ошибка при создании таблицы цен для товара бар-код &5 на объекте &1 &2 &3 &4" , x_obj-group.obj-type , x_obj-group.obj-code, error-status :get-message(1) , return-value, p-b-code )).
            end.
  end.
end procedure.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable var-pr-r-b as character no-undo .
define variable v-str2 as character no-undo .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
function f-base-code return integer ( p-b-code as integer ).
  define variable main-b-code as integer   no-undo .
  define buffer buf_bar-code for ub.bar-code  .
  find first buf_bar-code no-lock where
            buf_bar-code.b-code = p-b-code no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  ?
  ,output main-b-code
  )  .
  return (main-b-code).
end function.
function fnc-cost-pc return decimal (buffer local-price-list for ub.price-doc-forming-gds ).
  define variable f-cost     as decimal no-undo .
  define variable f-cost-pc  as decimal no-undo .
  define variable v-qnty     as decimal no-undo .
  define variable v-sum      as decimal no-undo .
  define variable fact_price as decimal no-undo .
  find first ub.goods where ub.goods.artic     = local-price-list.artic and
                            ub.goods.prod-type = local-price-list.prod-type and
                            ub.goods.prod-code = local-price-list.prod-code no-lock
                            no-error .
  assign
    v-sum  =  0
    v-qnty =  0
    .
  for each x_obj-group :
      find ub.gds-obj no-lock where
          ub.gds-obj.gds-code = ub.goods.gds-code and
          ub.gds-obj.obj-type = x_obj-group.obj-type and
          ub.gds-obj.obj-code = x_obj-group.obj-code no-error.
      if  available ub.gds-obj then
        if ub.goods.gds-type = 'т':U then
          assign
            v-sum  = v-sum  + ( if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base) * ub.gds-obj.avrg-qnty
            v-qnty =  v-qnty + ub.gds-obj.avrg-qnty
            .
          else  v-sum = ?.
      else v-sum = ?.
  end.
  f-cost = v-sum / v-qnty .
  fact_price = if var-pr-r-b = "rubl" then local-price-list.price-sale-rubl else local-price-list.price-sale-base .
  f-cost-pc = ( round ( fact_price / f-cost , 2 ) -  1 ) * 100.
  return (f-cost-pc).
end function.
function fnc-pr-pc return decimal (buffer local-price-list for ub.price-doc-forming-gds ).
define variable f-pr     as decimal no-undo .
define variable f-pr-pc  as decimal no-undo.
define variable v-qnty as decimal   no-undo .
define variable v-sum as decimal   no-undo .
define variable fact_price as decimal   no-undo .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
 assign
   v-sum  =  0
   v-qnty =  0
   .
for each x_obj-group :
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code  no-error .
if  available ub.gds-obj then do:
  if ub.goods.gds-type = 'т':U then
    assign
      f-pr = (if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl else ub.gds-obj.last-base)
      .
    else f-pr = ?.
end.
else f-pr = ?.
end.
  fact_price = if var-pr-r-b = "rubl" then local-price-list.price-sale-rubl else local-price-list.price-sale-base .
  f-pr-pc = ( round( fact_price / f-pr , 2 ) - 1 ) * 100 .
  return (f-pr-pc).
end function.
function fnc-cost return decimal (buffer local-price-list for ub.price-doc-forming-gds).
define variable f-cost   as decimal no-undo .
find first  x_obj-group.
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code  and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code
     no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-cost = if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      .
    else  f-cost = ?.
else f-cost = ?.
  return ( f-cost ).
end function.
function fnc-pr return decimal (buffer local-price-list for ub.price-doc-forming-gds).
define variable f-pr   as decimal no-undo .
find first x_obj-group .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code
     no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-pr = if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl  else ub.gds-obj.last-base
      .
    else  f-pr = ?.
else f-pr = ?.
   return ( f-pr ).
end function.
procedure make-fact-order-lib3 :
define input  parameter p-recid as recid no-undo .
define output parameter p-fact-order-sys-from as decimal   no-undo .
define output parameter p-fact-order-sys-to   as decimal   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable v-fact-order           as decimal no-undo .
  do
  on error undo, return error return-value
  :
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming ) = p-recid no-error .
  if error-status :error then return error error-status :get-message(1) .
find first buf_price-list-type  no-lock where
           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
  if error-status :error then return error error-status :get-message(1) .
 if buf_price-doc-forming.have-start-period = 1 then do:
    case buf_price-list-type.work-date :
      when int('1':U)  then
        do :
           run day-begin-fact-order
                ( buf_price-doc-forming.start-date ,
                 output p-fact-order-sys-from ) no-error .
                 if error-status :error then
                 return error substitute ( "Ошибка из day-begin-fact-order &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int('2':U)   then
        do :
          run factord (
             input   buf_price-doc-forming.start-shift-date
            ,input   buf_price-doc-forming.sys-time
            ,input   1
            ,input   buf_price-doc-forming.start-shift-date
            ,input   buf_price-doc-forming.start-shift-num
            ,input   true
            ,output  p-fact-order-sys-from
            ,output  v-shift-end-fact-order
            ,output  v-day-end-fact-order
            ) no-error  .
            if error-status :error then
                 return error substitute ( "Ошибка из factord &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int('3':U)   then
        do :
          run factord (
            input    buf_price-doc-forming.start-sys-date
            ,input   buf_price-doc-forming.start-sys-time
            ,input   (if buf_price-doc-forming.start-sys-time = 0 or buf_price-doc-forming.start-sys-time = ? then 1 else buf_price-doc-forming.start-sys-time )
            ,input   ?
            ,input   ?
            ,input   false
            ,output  p-fact-order-sys-from
            ,output  v-shift-end-fact-order
            ,output  v-day-end-fact-order
            ) no-error .
            if error-status :error then
                 return error substitute ( "Ошибка из factord  - дата сервера &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
    end case.
  end.
 if buf_price-doc-forming.have-end-period = 1 then do:
    case buf_price-list-type.work-date :
      when int('1':U)   then
        do :
           run factord-end-day
              ( buf_price-doc-forming.end-date ,
                output p-fact-order-sys-to ) no-error .
                if error-status :error then
                 return error substitute ( "Ошибка из factord-end-day дата на объекте на конец периода &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int('2':U)   then
        do :
          run factord (
             input   buf_price-doc-forming.end-shift-date
            ,input   buf_price-doc-forming.sys-time
            ,input   1
            ,input   buf_price-doc-forming.end-shift-date
            ,input   buf_price-doc-forming.end-shift-num
            ,input   true
            ,output  v-fact-order
            ,output  p-fact-order-sys-to
            ,output  v-day-end-fact-order
            ) no-error .
            if error-status :error then
              return error substitute ( "Ошибка из factord сменная дата на конец &1 &2" ,
                                        error-status :get-message(1) ,
                                        return-value ).
        end.
      when int('3':U)   then
        do :
          run factord (
             input   buf_price-doc-forming.end-sys-date
            ,input   buf_price-doc-forming.end-sys-time
            ,input   (if buf_price-doc-forming.end-sys-time  = 0 or buf_price-doc-forming.end-sys-time = ? then 1 else buf_price-doc-forming.end-sys-time )
            ,input   ?
            ,input   ?
            ,input   false
            ,output  p-fact-order-sys-to
            ,output  v-shift-end-fact-order
            ,output  v-day-end-fact-order
            ) no-error .
            if error-status :error then
              return error substitute ( "Ошибка из factord  - дата сервера &1 &2" ,
                                        error-status :get-message(1) ,
                                        return-value ).
        end.
    end case.
  end.
  end.
end procedure.
procedure ver-dfc-mpl-lib3 :
define input  parameter p-recid as recid no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
define buffer buf_price-doc-sum  for ub.price-doc-forming-gds-sum  .
define buffer buf_price-doc-forming-gds-tnv  for ub.price-doc-forming-gds-tnv  .
define variable v-fact-order-sys-from   as decimal   no-undo .
define variable v-fact-order-sys-to     as decimal   no-undo .
  do
  on error undo, return error return-value
 :
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming ) = p-recid no-error .
  if error-status :error then return error error-status :get-message(1) .
find first buf_price-list-type  no-lock where
           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
  if error-status :error then return error error-status :get-message(1) .
  if buf_price-list-type.stts = integer('1':U) then do:
     return error substitute(" ТПЛ &1 в статусе УДАЛЕН ! Закрывать с ним новые ДНЦ нельзя !" , buf_price-list-type.name )  .
  end.
  if buf_price-list-type.bgr-id > 0 then do:
      find ub.buyer-group where
            ub.buyer-group.stts       = 0  and
            ub.buyer-group.bgr-db-num = buf_price-list-type.bgr-db-num and
            ub.buyer-group.bgr-id     = buf_price-list-type.bgr-id
            no-lock no-error .
      if not available ub.buyer-group then
      return error substitute(" ТПЛ &1 содержит некорректную группу по покупателям &2(&3) !" , buf_price-list-type.name,buf_price-list-type.bgr-id,buf_price-list-type.bgr-db-num )  .
  end.
  if buf_price-list-type.sgr-id > 0 then do:
      find ub.sum-group where
            ub.sum-group.stts       = 0  and
            ub.sum-group.sgr-db-num = buf_price-list-type.sgr-db-num and
            ub.sum-group.sgr-id     = buf_price-list-type.sgr-id
            no-lock no-error .
      if not available ub.sum-group then
      return error substitute(" ТПЛ &1 содержит некорректную суммовую группу &2(&3) !" , buf_price-list-type.name,buf_price-list-type.sgr-id,buf_price-list-type.sgr-db-num )  .
  end.
  if buf_price-list-type.qgr-id > 0 then do:
      find ub.qnty-group where
           ub.qnty-group.stts       = 0  and
           ub.qnty-group.qgr-db-num = buf_price-list-type.qgr-db-num and
           ub.qnty-group.qgr-id     = buf_price-list-type.qgr-id
           no-lock no-error .
      if not available ub.qnty-group then
      return error substitute(" ТПЛ &1 содержит некорректную количественную группу &2(&3) !" , buf_price-list-type.name,buf_price-list-type.qgr-id,buf_price-list-type.qgr-db-num )  .
  end.
  if buf_price-list-type.tog-id > 0 then do:
      find ub.turnover-group where
           ub.turnover-group.stts       = 0  and
           ub.turnover-group.tog-db-num = buf_price-list-type.tog-db-num and
           ub.turnover-group.tog-id     = buf_price-list-type.tog-id
          no-lock no-error .
      if not available ub.turnover-group then
      return error substitute(" ТПЛ &1 содержит некорректную группу по оборотам &2(&3) !" , buf_price-list-type.name , buf_price-list-type.tog-id , buf_price-list-type.tog-db-num )  .
  end.
  if buf_price-list-type.gop-id > 0 then do:
      find ub.grp-obj-price where
            ub.grp-obj-price.stts       = 0  and
            ub.grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num and
            ub.grp-obj-price.gop-id     = buf_price-list-type.gop-id
            no-lock no-error .
      if not available ub.grp-obj-price then
      return error substitute(" ТПЛ &1 содержит некорректную группу по объектам &2(&3) !" , buf_price-list-type.name,buf_price-list-type.gop-id,buf_price-list-type.gop-db-num )  .
  end.
  if buf_price-list-type.gop-id-for-calc-turnover > 0 then do:
      find ub.grp-obj-price where
            ub.grp-obj-price.stts       = 0  and
            ub.grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num-for-calc-turnover and
            ub.grp-obj-price.gop-id     = buf_price-list-type.gop-id-for-calc-turnover
            no-lock no-error .
      if not available ub.grp-obj-price then
      return error substitute(" ТПЛ &1 содержит некорректную группу по объектам &2(&3) !" , buf_price-list-type.name,buf_price-list-type.gop-id-for-calc-turnover,buf_price-list-type.gop-db-num-for-calc-turnover )  .
  end.
   if buf_price-doc-forming.have-start-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int('1':U)     then
            do :
               if buf_price-doc-forming.start-date = ? then return error "Не задана дата начала действия цен !" .
            end.
          when int('2':U)   then
            do :
                if buf_price-doc-forming.start-shift-date = ? then return error "Не задана сменная дата начала действия цен !" .
                if buf_price-doc-forming.start-shift-num  = ? or
                   buf_price-doc-forming.start-shift-num = 0  then return error "Не задан порядок смены начала действия цен !" .
            end.
          when int('3':U)     then
            do :
                if buf_price-doc-forming.start-sys-date = ? then return error "Не задана дата начала действия цен !" .
                if buf_price-doc-forming.start-sys-time = ? then return error "Не задано время начала действия цен !" .
            end.
      end case.
   end.
   if buf_price-doc-forming.have-end-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int('1':U)     then
            do :
               if buf_price-doc-forming.end-date = ? then return error "Не задана дата окончания действия цен !" .
            end.
          when int('2':U)   then
            do :
                if buf_price-doc-forming.end-shift-date = ? then return error "Не задана сменная дата окончания действия цен !" .
                if buf_price-doc-forming.end-shift-num  = ? or
                   buf_price-doc-forming.end-shift-num = 0  then return error "Не задан порядок смены окончания  действия цен !" .
            end.
          when int('3':U)     then
            do :
                if buf_price-doc-forming.end-sys-date = ? then return error "Не задана дата окончания действия цен !" .
                if buf_price-doc-forming.end-sys-time = ? then return error "Не задано время окончания действия цен !" .
            end.
      end case.
   end.
   if buf_price-doc-forming.have-start-period = integer(true) and
      buf_price-doc-forming.have-end-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int('1':U)     then
            do :
               if buf_price-doc-forming.end-date < buf_price-doc-forming.start-date then return error "Не верно задан интервал дат !" .
            end.
          when int('2':U)   then
            do :
                if buf_price-doc-forming.end-shift-date < buf_price-doc-forming.start-shift-date then return error "Не верно задан интервал дат !" .
                if buf_price-doc-forming.end-shift-date = buf_price-doc-forming.start-shift-date then do:
                   if buf_price-doc-forming.end-shift-num < buf_price-doc-forming.start-shift-num then return error "Не верно задан интервал смен !" .
                end.
            end.
          when int('3':U)     then
            do :
                if buf_price-doc-forming.end-sys-date < buf_price-doc-forming.start-sys-date then return error "Не верно задан интервал дат !" .
                if buf_price-doc-forming.end-sys-date = buf_price-doc-forming.start-sys-date then do:
                   if buf_price-doc-forming.end-sys-time < buf_price-doc-forming.start-sys-time then return error "Не верно задан интервал времени !" .
                end.
            end.
      end case.
   end.
if buf_price-doc-forming.name = "" then return error "Не задано название ДНЦ !" .
if buf_price-list-type.main = false then do:
    run make-fact-order-lib3 in this-procedure
        ( input  p-recid ,
          output v-fact-order-sys-from ,
          output v-fact-order-sys-to   ) .
end.
define variable old-price as decimal   no-undo .
define variable v-kol-rec as integer   no-undo .
define variable v-gds-null-price as character no-undo initial "" .
define variable v-type as character no-undo .
v-kol-rec = 0.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
         buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
         buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
         buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      :
    find first ub.bar-code no-lock where
               ub.bar-code.b-code = buf_price-doc-forming-gds.b-code no-error .
               if error-status :error then return error substitute ("Не найден бар-код &1" ,  buf_price-doc-forming-gds.b-code ) .
    find first ub.goods no-lock where
               ub.goods.artic = buf_price-doc-forming-gds.artic         and
               ub.goods.prod-type = buf_price-doc-forming-gds.prod-type and
               ub.goods.prod-code = buf_price-doc-forming-gds.prod-code no-error .
               if error-status :error then return error substitute ("Не найден товар &1 &2 &3" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
    if ub.bar-code.gds-code <> ub.goods.gds-code then return error substitute ("Бар-код &4 не соответствует товару &1 &2 &3" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.b-code ) .
    run gds-attr-value in this-procedure (input ub.goods.gds-code
                                         ,input 'null-price':U
                                         ,output v-gds-null-price
                                         ,output v-type ) no-error .
    if buf_price-doc-forming-gds.price-sale-doc   = ? or (buf_price-doc-forming-gds.price-sale-doc   = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-doc  ) .
    if buf_price-doc-forming-gds.price-sale-rubl  = ? or (buf_price-doc-forming-gds.price-sale-rubl  = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-rubl ) .
    if buf_price-doc-forming-gds.price-sale-base  = ? or (buf_price-doc-forming-gds.price-sale-base  = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-base ) .
    if buf_price-doc-forming-gds.slt-pc = ? then return error substitute ("НсП по товару &1 &2 &3 не определен" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
    if buf_price-doc-forming-gds.vat-pc = ? then return error substitute ("НДС по товару &1 &2 &3 не определен" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
old-price = ? .
  for each buf_price-doc-forming-gds-qnty no-lock where
           buf_price-doc-forming-gds-qnty.plt-id = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-forming-gds-qnty.pdf-id = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-forming-gds-qnty.pdf-db = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-forming-gds-qnty.b-code = buf_price-doc-forming-gds.b-code
           by buf_price-doc-forming-gds-qnty.ggr-qnty :
           if old-price < buf_price-doc-forming-gds-qnty.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории количество покупки >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds-qnty.ggr-qnty ,old-price , buf_price-doc-forming-gds-qnty.price-sale-doc) .
           end.
           old-price = buf_price-doc-forming-gds-qnty.price-sale-doc .
  end.
old-price = ? .
  for each buf_price-doc-sum no-lock where
           buf_price-doc-sum.plt-id     = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-sum.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-sum.pdf-id     = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-sum.pdf-db     = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-sum.b-code     = buf_price-doc-forming-gds.b-code
           by buf_price-doc-sum.ssg-summa
           :
           if old-price < buf_price-doc-sum.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории сумма покупки >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-sum.ssg-summa , old-price , buf_price-doc-sum.price-sale-doc) .
           end.
           old-price = buf_price-doc-sum.price-sale-doc .
  end.
old-price = ? .
  for each buf_price-doc-forming-gds-tnv no-lock where
           buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-forming-gds-tnv.b-code     = buf_price-doc-forming-gds.b-code
           by buf_price-doc-forming-gds-tnv.ttg-summa :
           if old-price < buf_price-doc-forming-gds-tnv.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории сумма оборота покупателя >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds-tnv.ttg-summa ,old-price , buf_price-doc-forming-gds-tnv.price-sale-doc) .
           end.
           old-price = buf_price-doc-forming-gds-tnv.price-sale-doc .
  end.
  define buffer old_price-doc-forming for ub.price-doc-forming  .
  define buffer old_price-doc-forming-gds for ub.price-doc-forming-gds  .
  define buffer old_price-all for ub.price-all.
  if buf_price-list-type.main = false then do:
     for each old_price-doc-forming no-lock where
              old_price-doc-forming.plt-id     = buf_price-list-type.plt-id     and
              old_price-doc-forming.plt-db-num = buf_price-list-type.plt-db-num and
              old_price-doc-forming.stts       = integer('3':U)  ,
              each old_price-doc-forming-gds no-lock where
                    old_price-doc-forming-gds.plt-id     = buf_price-list-type.plt-id      and
                    old_price-doc-forming-gds.plt-db-num = buf_price-list-type.plt-db-num  and
                    old_price-doc-forming-gds.pdf-id     = old_price-doc-forming.pdf-id    and
                    old_price-doc-forming-gds.pdf-db     = old_price-doc-forming.pdf-db    and
                    old_price-doc-forming-gds.b-code     = buf_price-doc-forming-gds.b-code :
             for each old_price-all no-lock where
                      old_price-all.plt-id     = old_price-doc-forming-gds.plt-id      and
                      old_price-all.plt-db-num = old_price-doc-forming-gds.plt-db-num  and
                      old_price-all.pdf-id     = old_price-doc-forming-gds.pdf-id      and
                      old_price-all.pdf-db     = old_price-doc-forming-gds.pdf-db      and
                      old_price-all.b-code     = old_price-doc-forming-gds.b-code      and
                      old_price-all.fact-order-sys-to   >= v-fact-order-sys-from       and
                      old_price-all.fact-order-sys-from <= v-fact-order-sys-to         :
                     return error substitute ("По товару &1 &2 &3 есть цена &6 в пересекающийся период с таким же приоритетом &7 (ДНЦ &4 &5) " ,
                                               buf_price-doc-forming-gds.artic ,
                                               buf_price-doc-forming-gds.prod-type ,
                                               buf_price-doc-forming-gds.prod-code,
                                               old_price-all.pdf-id ,
                                               old_price-all.pdf-db ,
                                               old_price-doc-forming-gds.price-sale-doc ,
                                               old_price-all.plt-priority
                                               ) .
             end.
     end.
     end.
    assign v-kol-rec = v-kol-rec + 1 .
end.
  run ver-pr-equ-qS in this-procedure
    ( input buf_price-doc-forming.plt-id ,
      input buf_price-doc-forming.plt-db-num,
      input buf_price-doc-forming.pdf-id ,
      input buf_price-doc-forming.pdf-db
      ) no-error .
  if error-status :error then  return error  "Ошибка при удалении строки ДНЦ "   .
if v-kol-rec = 0 then return error "no-records":U.
end.
end procedure.
procedure ver-pr-equ-qS :
define input parameter  p-plt-id      as integer   no-undo .
define input parameter  p-plt-db-num  as integer   no-undo .
define input parameter  p-pdf-id      as integer   no-undo .
define input parameter  p-pdf-db      as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable  l-doc-num2   like ub.price-list.doc-num    no-undo .
define buffer pdf_price-list  for ub.price-doc-forming-gds .
define buffer pp_price-list   for ub.price-doc-forming-gds .
define buffer main_price-list for ub.price-doc-forming-gds .
define buffer alt_price-list  for ub.price-doc-forming-gds .
define buffer buf1-bar-code   for ub.bar-code .
define buffer buf2-bar-code   for ub.bar-code .
define buffer buf_goods for ub.goods  .
define buffer buf2_goods for ub.goods  .
define variable v-num as integer init 0 no-undo .
define variable bbb   as logical no-undo .
define variable l-price-sale like ub.price-list.price-sale no-undo .
define variable l-road-tax   like ub.price-list.road-tax   no-undo .
define variable l-excise     like ub.price-list.excise     no-undo .
define variable l-ok          as logical no-undo .
define variable check-par     as logical no-undo .
define variable main-b-code   as integer no-undo .
define variable par-pr-equ-dq as integer no-undo .
define variable v-price-sale  as decimal no-undo .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'overval':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'pr-equ-dq':U then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
end.
if par-pr-equ-dq = 1 then return .
for each pdf_price-list exclusive-lock where
         pdf_price-list.plt-id     = p-plt-id     and
         pdf_price-list.plt-db-num = p-plt-db-num and
         pdf_price-list.pdf-id     = p-pdf-id     and
         pdf_price-list.pdf-db     = p-pdf-db     by pdf_price-list.line-num
        :
    if not (pdf_price-list.b-code     = f-base-code (pdf_price-list.b-code) ) then next .
    check-par = false .
   find first x_obj-group no-error .
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  pdf_price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
    v-price-sale = l-price-sale .
   for each x_obj-group :
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  pdf_price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
    if v-price-sale <> l-price-sale  then do :
      v-price-sale = l-price-sale.
      leave .
    end.
   end.
   find first x_obj-group no-error .
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  pdf_price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
      if l-doc-num2 <> ? then do :
        if l-price-sale = pdf_price-list.price-sale-doc
        and v-price-sale = pdf_price-list.price-sale-doc
        then do:
             find first buf_goods no-lock where
                        buf_goods.artic     =  pdf_price-list.artic and
                        buf_goods.prod-type =  pdf_price-list.prod-type and
                        buf_goods.prod-code =  pdf_price-list.prod-code no-error .
            check-par = false .
               for each pp_price-list no-lock where
                        pp_price-list.plt-id     = p-plt-id     and
                        pp_price-list.plt-db-num = p-plt-db-num and
                        pp_price-list.pdf-id     = p-pdf-id     and
                        pp_price-list.pdf-db     = p-pdf-db     and
                        pp_price-list.artic      = pdf_price-list.artic and
                        pp_price-list.prod-type  = pdf_price-list.prod-type  and
                        pp_price-list.prod-code  = pdf_price-list.prod-code ,
                     first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli <> buf_goods.unit-base
                    :
                    if  pp_price-list.b-code = f-base-code (pp_price-list.b-code) then next .
                    check-par = true  .
                    leave.
                end.
               for each pp_price-list no-lock where
                        pp_price-list.plt-id     = p-plt-id     and
                        pp_price-list.plt-db-num = p-plt-db-num and
                        pp_price-list.pdf-id     = p-pdf-id     and
                        pp_price-list.pdf-db     = p-pdf-db     and
                        pp_price-list.artic      = pdf_price-list.artic and
                        pp_price-list.prod-type  = pdf_price-list.prod-type  and
                        pp_price-list.prod-code  = pdf_price-list.prod-code and
                        pp_price-list.price-sale-doc <> pdf_price-list.price-sale-doc  ,
                     first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli = buf_goods.unit-base
                    :
                    if  pp_price-list.b-code = f-base-code (pp_price-list.b-code) then next .
                    check-par = true  .
                    leave.
                end.
            if check-par = true then next.
            if par-pr-equ-dq = 2 then do:
                  if  ( v-num <= 2  and check-par = false ) then
                      run gbl/d-askw.w
                        (input "Удалить строку?"
                        ,input      "Предыдущая цена РАВНА цене по закрываемому документу " + chr(10)
                                    + " Объект "  + v-cntxt-obj-type + String(v-cntxt-obj-code)
                                    + " Артикул " + pdf_price-list.artic + " " +  buf_goods.gds-name + chr(10)
                                    + " Бар-код " + string(pdf_price-list.b-code)
                                    + " Цена по предыдущему документу переоценки № " + l-doc-num2 + " = "
                                    + string(pdf_price-list.price-sale-doc) + chr(10)
                                    + " Удалить строку? "
                        ,input "|^"
                        ,input "Да|Нет|Да для всех^confirm|Нет для всех^confirm"
                        ,input "Удалить строку|"
                            + "Не удалять строку|"
                            + "Удалять у всех товаров, цена на которые не изменилась|"
                            + "Не удалять у всех товаров, цена на которые не изменилась"
                        ,input 1
                        ,input 2
                        ,output v-num
                        ).
              end.
              else do:
                v-num = 3 .
              end.
                if v-num = 1 then do:
                  run del-doc-line ( input recid(pdf_price-list)) no-error  .
                                  if error-status :error then do:
                                          message  vss-workfile vss-revision vss-description skip
                                          "Ошибка при удаление строки ДНЦ"
                                          pdf_price-list.b-code skip
                                          error-status :get-message(1) .
                                          return error.
                                  end.
                end.
                if v-num = 3  then do:
                   run del-doc-line ( input recid(pdf_price-list)) no-error  .
                end.
        end.
       end.
end.
  for each main_price-list no-lock where
              main_price-list.plt-id      = p-plt-id and
              main_price-list.plt-db-num  = p-plt-db-num and
              main_price-list.pdf-id      = p-pdf-id and
              main_price-list.pdf-db      = p-pdf-db
              :
              if main_price-list.b-code <> f-base-code (main_price-list.b-code) then next.
                for each pp_price-list no-lock where
                          pp_price-list.plt-id       = main_price-list.plt-id     and
                          pp_price-list.plt-db-num   = main_price-list.plt-db-num and
                          pp_price-list.pdf-id       = main_price-list.pdf-id     and
                          pp_price-list.pdf-db       = main_price-list.pdf-db     and
                          pp_price-list.artic        = main_price-list.artic      and
                          pp_price-list.prod-type    = main_price-list.prod-type  and
                          pp_price-list.prod-code    = main_price-list.prod-code  and
                          pp_price-list.b-code      <> main_price-list.b-code     and
                          pp_price-list.price-sale-doc = main_price-list.price-sale-doc  ,
                    first buf_goods no-lock where
                          buf_goods.artic     =  pp_price-list.artic and
                          buf_goods.prod-type =  pp_price-list.prod-type and
                          buf_goods.prod-code =  pp_price-list.prod-code ,
                    first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli = buf_goods.unit-base
                          :
                          bbb = true .
                          for each alt_price-list no-lock where
                                  alt_price-list.plt-id     = pp_price-list.plt-id     and
                                  alt_price-list.plt-db-num = pp_price-list.plt-db-num and
                                  alt_price-list.pdf-id     = pp_price-list.pdf-id     and
                                  alt_price-list.pdf-db     = pp_price-list.pdf-db     and
                                  alt_price-list.artic      = pp_price-list.artic      and
                                  alt_price-list.prod-type  = pp_price-list.prod-type  and
                                  alt_price-list.b-code     <> main_price-list.b-code  and
                                  alt_price-list.b-code     <> pp_price-list.b-code    and
                                  alt_price-list.prod-code  = pp_price-list.prod-code ,
                            first buf2_goods no-lock where
                                  buf2_goods.artic     =  pp_price-list.artic     and
                                  buf2_goods.prod-type =  pp_price-list.prod-type and
                                  buf2_goods.prod-code =  pp_price-list.prod-code ,
                            first buf2-bar-code no-lock where
                                  buf2-bar-code.b-code   = alt_price-list.b-code and
                                  buf2-bar-code.unit-cli <> buf2_goods.unit-base and
                                  buf2-bar-code.node-code = buf1-bar-code.node-code
                                :
                                bbb = false.
                                leave.
                          end.
                          if bbb = true  then do:
                              run del-doc-line ( input recid (pp_price-list)) no-error  .
                              if error-status :error then do:
                                  message  vss-workfile vss-revision vss-description skip
                                  " Нельзя удалить " pp_price-list.b-code skip
                                  error-status :get-message(1) .
                              end.
                          end.
                end.
  end.
end.
end procedure.
procedure ver-pr-discnS :
define input  parameter p-plt-id        as integer   no-undo .
define input  parameter p-plt-db-num    as integer   no-undo .
define input  parameter p-pdf-id        as integer   no-undo .
define input  parameter p-pdf-db        as integer   no-undo .
define input  parameter p-mode        as character no-undo .
define input  parameter trn-doc-code  like ub.trn-doc.doc-code no-undo .
define output parameter p-err         as logical no-undo .
  do
  on error undo, return error return-value
  :
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
define buffer b_price-doc-forming-gds for ub.price-doc-forming-gds .
define buffer b_trn-doc    for ub.trn-doc .
define buffer b_doc-line   for ub.doc-line .
define buffer bl_goods     for ub.goods .
define buffer bl_gds-grp   for ub.gds-grp .
define buffer bl_bar-code  for ub.bar-code  .
define buffer buf_bar-code for ub.bar-code  .
define variable v-koff            as decimal   no-undo .
define variable t-prc             as decimal   no-undo .
define variable p-prc-min         as decimal   no-undo .
define variable p-prc-max         as decimal   no-undo .
define variable p-increase-pc     as decimal   no-undo .
define variable p-round-method    as character no-undo .
define variable p-base            as decimal   no-undo .
define variable var-pr-r-b        as character no-undo .
define variable tt-price-sale     as decimal   no-undo .
define variable p-node-code       as integer   no-undo .
define variable p-host-code       as integer   no-undo .
define variable p-obj-type        as character no-undo .
define variable p-obj-code        as integer   no-undo .
define variable p-value-margin    as integer   no-undo .
define variable p-type-margin     as logical   no-undo .
define variable p-value-increase  as integer   no-undo .
define variable p-type-increase   as logical   no-undo .
define variable p-value-rmethod   as integer   no-undo .
define variable p-type-rmethod    as logical   no-undo .
define variable l_price           as decimal   no-undo .
define variable l_pricewithvat    as decimal   no-undo .
define variable l_pricewithoutvat as decimal   no-undo .
define variable l_prod-vat        as decimal   no-undo .
define variable fact_price        as decimal   no-undo .
define variable pr-discm          as character no-undo .
define variable pr-gen-margin     as character no-undo .
p-err = false .
define variable cost-base     as decimal  no-undo .
define variable cost-rubl     as decimal  no-undo .
define variable v-price-base  as decimal  no-undo .
define variable v-price-rubl  as decimal  no-undo .
define variable cur-rt-base   as decimal  no-undo .
define variable cur-rt-rubl   as decimal  no-undo .
define variable f-cost as decimal no-undo .
define variable s-cost as decimal no-undo .
define variable f-qnty as decimal no-undo .
define variable s-qnty as decimal no-undo .
define variable p-attr-code    as character no-undo .
define variable p-b-code       as integer   no-undo .
define variable p-attr-value   as character no-undo .
define variable v-ok           as logical   no-undo .
define variable par-type       as character no-undo.
define variable v-main-b-code  as integer   no-undo .
define variable v-vat-pc       as decimal   no-undo .
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
find first x_obj-group .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output p-host-code
  )  .
assign
  p-obj-type   = x_obj-group.obj-type
  p-obj-code   = x_obj-group.obj-code
.
define variable vss-include-info52 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_discount':U
    ,input  'object':U
    ,input  p-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
  if v-ok = true then return .
if trim(par-pr-discm) = "" then return .
if par-pr-discm = 'sale-' then par-pr-discm = 'sale' .
for each  b_price-doc-forming-gds no-lock where
          b_price-doc-forming-gds.plt-id     = p-plt-id      and
          b_price-doc-forming-gds.plt-db-num = p-plt-db-num  and
          b_price-doc-forming-gds.pdf-id     = p-pdf-id      and
          b_price-doc-forming-gds.pdf-db     = p-pdf-db
          :
    find first buf_bar-code no-lock where
               buf_bar-code.b-code  = b_price-doc-forming-gds.b-code
               no-error .
    if available buf_bar-code then v-koff = buf_bar-code.cli-base-rate .
    else v-koff = 1.
    if v-koff = ? or v-koff = 0 then v-koff = 1.
   find first bl_goods no-lock   where
              bl_goods.artic     = b_price-doc-forming-gds.artic     and
              bl_goods.prod-code = b_price-doc-forming-gds.prod-code and
              bl_goods.prod-type = b_price-doc-forming-gds.prod-type
              .
    assign
      p-node-code  = bl_goods.grp-code
    .
    run gds-attr-margin-value
    (
      input   bl_goods.gds-code,
      input   p-obj-type ,
      input   p-obj-code ,
      output  p-prc-min  ,
      output  p-prc-max  ,
      output  p-increase-pc,
      output  p-round-method,
      output  p-base        ,
      output  p-value-margin    ,
      output  p-type-margin     ,
      output  p-value-increase   ,
      output  p-type-increase   ,
      output  p-value-rmethod   ,
      output  p-type-rmethod
      ) .
    if p-type-margin = false  then next.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bl_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
    if  trn-doc-code = ? or trn-doc-code = "" then do:
        if v-main-b-code = b_price-doc-forming-gds.b-code then do :
          case  par-pr-discm :
             when "prod":u then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then  b_price-doc-forming-gds.price-sale-rubl
                                else  b_price-doc-forming-gds.price-sale-base
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then  b_price-doc-forming-gds.price-sale-rubl
                                else  b_price-doc-forming-gds.price-sale-base
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "cost-vat":u then do:
                  run str/mplnovat.p
                     (input 'Учет-НДСS':U,
                      input table x_obj-group ,
                      input b_price-doc-forming-gds.b-code,
                      input b_price-doc-forming-gds.artic,
                      input b_price-doc-forming-gds.prod-type,
                      input b_price-doc-forming-gds.prod-code,
                      input 0 ,
                      input ? ,
                      input b_price-doc-forming-gds.vat-pc ,
                      input b_price-doc-forming-gds.slt-pc ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl
                      ).
                  assign
                    l_price    =  if var-pr-r-b = "rubl" then v-price-rubl else v-price-base
                    fact_price =  if var-pr-r-b = "rubl" then b_price-doc-forming-gds.price-sale-rubl else b_price-doc-forming-gds.price-sale-base
                  .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
            when "cost":u       then do:
              t-prc =  fnc-cost-pc (buffer b_price-doc-forming-gds) .
            end.
            when "sale":u then do:
              t-prc =  fnc-pr-pc   (buffer b_price-doc-forming-gds) .
            end.
          end case.
        end.
        else do:
 case  par-pr-discm :
            when "cost":u
            or when "cost-vat":u
            then do:
              l_price =  fnc-cost (buffer b_price-doc-forming-gds) .
              t-prc = ((b_price-doc-forming-gds.price-sale-rubl / v-koff)  / l_price - 1) * 100.
            end.
            when "sale":u then do:
              l_price =  fnc-pr   (buffer b_price-doc-forming-gds) .
              t-prc = (( b_price-doc-forming-gds.price-sale-rubl / v-koff) /  l_price - 1) * 100.
            end.
              when "prod":u then do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then
                                   b_price-doc-forming-gds.price-sale-rubl  / v-koff
                                else
                                   b_price-doc-forming-gds.price-sale-base  / v-koff
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then
                                   b_price-doc-forming-gds.price-sale-rubl  / v-koff
                                else
                                   b_price-doc-forming-gds.price-sale-base  / v-koff
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
          end case.
        end.
    end.
if  trn-doc-code <> ? and trn-doc-code <> "" then do:
    find first b_trn-doc where b_trn-doc.doc-code = trn-doc-code no-lock no-error .
    if available b_trn-doc then find first b_doc-line where
    b_doc-line.doc-code  = b_trn-doc.doc-code and
    b_doc-line.artic     = bl_goods.artic     and
    b_doc-line.prod-code = bl_goods.prod-code and
    b_doc-line.prod-type = bl_goods.prod-type no-lock no-error .
    if b_trn-doc.ext-doc-type = 'ie':U then   pr-gen-margin = par-gen-mrgn-ie.
    if b_trn-doc.ext-doc-type = 'iv':U then   pr-gen-margin = par-gen-mrgn-iv.
    if b_trn-doc.ext-doc-type = 'im':U  then   pr-gen-margin = par-gen-mrgn-im.
    pr-gen-margin = lc(pr-gen-margin).
      if available b_doc-line then do:
      case  par-pr-discm :
        when "cost":u then do:
                f-qnty = 0.
                find ub.gds-obj no-lock where
                    ub.gds-obj.gds-code = bl_goods.gds-code and
                    ub.gds-obj.obj-type = b_trn-doc.obj-type and
                    ub.gds-obj.obj-code = b_trn-doc.obj-code no-error.
                if  available ub.gds-obj then
                  if bl_goods.gds-type = 'т':U then do:
                          if var-pr-r-b = "rubl" then
                              assign
                                f-cost = if  ub.gds-obj.avrg-rubl = ? then 0 else ub.gds-obj.avrg-rubl
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                          else
                              assign
                                f-cost = if  ub.gds-obj.avrg-base = ? then 0 else ub.gds-obj.avrg-base
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                      end.
                    else  f-cost = ?.
                else f-cost = ?.
           if pr-gen-margin = 'before-margin':U then do:
assign
  price-rubl-with-tax-loc = b_doc-line.price-rubl
  price-base-with-tax-loc = b_doc-line.price-base
.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = b_doc-line.artic     and
                                     in-vatp-goods.prod-type = b_doc-line.prod-type and
                                     in-vatp-goods.prod-code = b_doc-line.prod-code no-lock.
   if (not b_trn-doc.internal and
           b_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b_doc-line.road-tax
          road-tax-rubl-loc = b_doc-line.road-tax * b_trn-doc.base-rate / b_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b_doc-line.road-tax
          road-tax-base-loc = b_doc-line.road-tax / b_trn-doc.base-rate * b_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b_doc-line.transport-base = ? then 0 else b_doc-line.transport-base)
        transport-rubl-loc = (if b_doc-line.transport-rubl = ? then 0 else b_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b_doc-line.other-base     = ? then 0 else b_doc-line.other-base)
        other-rubl-loc     = (if b_doc-line.other-rubl     = ? then 0 else b_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b_doc-line.vat-pc         = ? then 0 else b_doc-line.vat-pc)
        slt-pc-loc         = (if b_doc-line.slt-pc         = ? then 0 else b_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b_doc-line.obj-code  and
                                      in-vatp-parts.artic     = b_doc-line.artic     and
                                      in-vatp-parts.prod-type = b_doc-line.prod-type and
                                      in-vatp-parts.prod-code = b_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        transport-base-loc  = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        other-base-loc      = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        other-rubl-loc      = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b_doc-line.fact-qnty   else 0
        slt-base-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
             if var-pr-r-b = "rubl" then
                 s-cost = price-rubl-with-tax-loc.
               else
                 s-cost = price-base-with-tax-loc.
             s-qnty = b_doc-line.fact-qnty .
           end.
           else do:
             assign
              s-cost = 0
              s-qnty = 0
             .
           end.
           l_price  =  (f-cost * f-qnty + s-cost * s-qnty ) / (f-qnty + s-qnty)  .
        end.
        when "cost-vat":u then do:
             run str/gdsnovat.p ('Уч+накл-НДС':U,
                     b_trn-doc.obj-type,
                     b_trn-doc.obj-code,
                     b_trn-doc.host-code,
                     b_doc-line.artic,
                     b_doc-line.prod-type,
                     b_doc-line.prod-code,
                     0 ,
                     b_doc-line.doc-code,
                     ?,
                     ?,
                     output cost-base   ,
                     output cost-rubl   ,
                     output v-price-base  ,
                     output v-price-rubl  ,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
                     if var-pr-r-b = "rubl"
                        then l_price = v-price-rubl.
                        else l_price = v-price-base.
        end.
        when "sale":u then do:
              l_price = ( if var-pr-r-b = "rubl"
                             then b_doc-line.price-rubl
                             else b_doc-line.price-base ).
        end.
        when "prod":u then do:
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
    end.
   when "prod-vat":u then do:
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
    end.
      end case.
        tt-price-sale = b_price-doc-forming-gds.price-sale-rubl .
        t-prc = (( tt-price-sale /  v-koff ) / l_price - 1) * 100.
   end.
end.
  if  p-prc-max <> ? then do:
    if  t-prc <> ? and ( p-prc-max < t-prc  or p-prc-min > t-prc)
    then do:
      message (if v-main-b-code = b_price-doc-forming-gds.b-code then "По товару :"
          else "По признаку"  )
          b_price-doc-forming-gds.artic
          b_price-doc-forming-gds.prod-type
          b_price-doc-forming-gds.prod-code skip
          "бар-код: " b_price-doc-forming-gds.b-code
           ( if v-koff > 1 then substitute("Упаковка на: &1" , v-koff)
             else "" ) skip
          fnc-pr  (buffer b_price-doc-forming-gds)
          skip
        "Процент торговой наценки вышел за интервал возможных значений !!! " skip
        "Процент не менее :" p-prc-min "%" skip
        "Процент не более :" p-prc-max "%" skip
        "Процент фактический :" t-prc  "%"  skip
        "ДНЦ №: " b_price-doc-forming-gds.pdf-id         skip
        "БД" b_price-doc-forming-gds.pdf-db
          view-as alert-box error .
              p-err = true .
              undo , return error .
    end.
    else do:
       if  t-prc = ? then  do:
          message (if v-main-b-code = b_price-doc-forming-gds.b-code then "По товару :"
          else "По признаку"  )
          b_price-doc-forming-gds.artic
          b_price-doc-forming-gds.prod-type
          b_price-doc-forming-gds.prod-code skip
          "бар-код: " b_price-doc-forming-gds.b-code
           ( if v-koff > 1 then substitute("Упаковка на: &1" , v-koff)
             else "" ) skip
          fnc-pr  (buffer b_price-doc-forming-gds)
          skip
          "Нет базовой цены для расчета процента наценки !" skip
          "Процент торговой наценки вышел за интервал возможных значений !!! " skip
          "Процент не менее :" p-prc-min "%" skip
          "Процент не более :" p-prc-max "%" skip
          "Процент фактический :" t-prc  "%"  skip
          "ДНЦ №_: " b_price-doc-forming-gds.pdf-id         skip
          "БД" b_price-doc-forming-gds.pdf-db
          view-as alert-box error .
          p-err = true .
          undo , return error .
       end.
    end.
  end.
end.
  end.
end procedure.
procedure del-doc-line :
define input  parameter p-recid as recid no-undo .
  do
  on error undo, return error return-value
  :
  find first ub.price-doc-forming-gds exclusive-lock where
       recid ( ub.price-doc-forming-gds ) = p-recid  no-error .
   if available ub.price-doc-forming-gds then do:
      delete ub.price-doc-forming-gds no-error .
   end.
  end.
end procedure.
def var vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info60, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info60 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info60 )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info60, p-b-code ) .
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info60
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    if buf_bar-code.stts = integer('79':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info60
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    return .
  end.
end procedure.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer next_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
define buffer next_price-doc-forming-gds-sum  for ub.price-doc-forming-gds-sum   .
define buffer next_price-doc-forming-gds-tnv  for ub.price-doc-forming-gds-tnv   .
define buffer buf_price-doc-forming-gds-sum   for ub.price-doc-forming-gds-sum   .
define buffer buf_price-doc-forming-gds-tnv   for ub.price-doc-forming-gds-tnv   .
define buffer buf_price-doc-forming-attr      for ub.price-doc-forming-attr  .
assign
  p-recid     = integer (entry(1,p-parameter,chr(4)))
  p-esc-prd   = logical (entry(2,p-parameter,chr(4)))
  p-esc-pra   = logical (entry(3,p-parameter,chr(4)))
  p-ecs-type  =          entry(4,p-parameter,chr(4))
  p-ecs-code  = integer (entry(5,p-parameter,chr(4)))
  p-action    =          entry(6,p-parameter,chr(4))
  p-trn-doc   =          entry(7,p-parameter,chr(4))
  p-ask-pr    = logical (entry(8,p-parameter,chr(4)))
  .
  p-do    = logical (entry(9,p-parameter,chr(4))) no-error .
  if error-status :error then p-do = false .
define buffer buf_price-list-type            for ub.price-list-type  .
define buffer buf_price-doc-forming-gds      for ub.price-doc-forming-gds  .
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
define variable v-fact-order-shift-from       as decimal   no-undo .
define variable v-fact-order-shift-to         as decimal   no-undo .
define variable v-fact-order-sys-from         as decimal   no-undo .
define variable v-fact-order-sys-to           as decimal   no-undo .
define variable v-old-auto                    as logical   no-undo .
define variable overval-err                   as logical   no-undo .
define variable overval-err-str               as character no-undo .
define variable v-base                        as logical   no-undo .
define variable l-ok as logical   no-undo .
define variable v-chk-act-host-code as integer   no-undo .
define variable v-mess as character no-undo .
define variable v-vid-action        as integer no-undo .
define variable v-vid-param         as longchar no-undo .
define variable varoldstatus        as character no-undo .
define variable varshift-date as date      no-undo.
define variable varshift-num  as integer   no-undo.
define variable varshift-name as character no-undo.
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .
find first buf_price-doc-forming exclusive-lock where recid ( buf_price-doc-forming) = p-recid no-error .
if error-status :error then return error error-status :get-message(1) .
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num and
           buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id
           no-error .
if error-status :error then return error error-status :get-message(1) .
run ver-dfc-mpl-lib3 in this-procedure ( recid (buf_price-doc-forming) ) no-error  .
if error-status :error then return error SUBSTITUTE("&1  &2" , return-value , error-status :get-message(1)) .
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Закрытие ДНЦ &1 БД&2", buf_price-doc-forming.pdf-id,buf_price-doc-forming.pdf-db)).
run str/mplnotls.p
    ( parParentProc ,
      buf_price-doc-forming.pdf-id ,
      buf_price-doc-forming.pdf-db ,
      buf_price-doc-forming.plt-id ,
      buf_price-doc-forming.plt-db-num
    ) no-error .
if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute ( "Проверяем, не потеряны ли цены в ДНЦ &1 БД&2&5 &3 &4" , buf_price-doc-forming.pdf-id , buf_price-doc-forming.pdf-db , error-status :get-message(1) , return-value, chr(10) )).
      return  error  return-value .
end.
run dfc-create-date in this-procedure no-error .
if error-status :error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Процедура формирования дат (dfc-create-date) ...&1 &2",error-status :get-message(1),return-value)).
      return error return-value .
end.
run make-fact-order-lib3 in this-procedure
   ( input recid (buf_price-doc-forming) ,
     output v-fact-order-sys-from   ,
     output v-fact-order-sys-to
   ) no-error  .
if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Определение интервала действия (make-fact-order-lib3) ... &1 &2",error-status :get-message(1),return-value)).
    return error return-value .
end.
   run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf_price-list-type.gop-id , buf_price-list-type.gop-db-num) no-error .
   if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Список объектов (metod-gop-obj) ...&1 &2",error-status :get-message(1),return-value)).
      return  error return-value .
   end.
    find first x_obj-group no-error .
    if not available x_obj-group then do:
      run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input "Не найден ни один объект для документа ДНЦ. Проверьте настройки группы ценообразования или, если Вы копировали документ, то убедитесь, что настройки групп ценообразования актуальны.").
       return  error return-value .
    end.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output v-chk-act-host-code
  )  .
    run chec-par in this-procedure (output l-ok , input v-chk-act-host-code, input x_obj-group.obj-type,input x_obj-group.obj-code ) no-error .
    If l-ok <> true or error-status :error
    then do:
        undo, return error return-value .
    end.
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) .
if p-esc-pra = true then do:
   for each x_obj-group  where
            x_obj-group.obj-type = p-ecs-type and
            x_obj-group.obj-code = p-ecs-code  :
   delete x_obj-group.
   end.
end.
if v-cntxt-db-num <> 0 then do:
   for each x_obj-group  :
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output o-db-num
  )  .
    if o-db-num <> v-cntxt-db-num then do:
       delete x_obj-group.
    end.
   end.
end.
for each x_obj-group :
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_order':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  x_obj-group.obj-type
    ,input  x_obj-group.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output l-ok
    )  .
end.
    if l-ok <> true
    then do:
      if error-status :error then return error return-value .
    end.
define variable vss-include-info67 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_preparation':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  x_obj-group.obj-type
    ,input  x_obj-group.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output l-ok
    )  .
end.
    if l-ok <> true
    then do:
      if error-status :error then return error return-value .
    end.
end.
define variable v-errstr as character no-undo .
run dfc-pr-good in this-procedure no-error .
if error-status :error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Проверка состава  ДНЦ...&1 &2",error-status :get-message(1),return-value)).
      return error v-errstr .
end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Создание таблицы поиска цены...")).
define buffer buf_bar-code    for ub.bar-code.
define buffer buf_goods       for ub.goods   .
define buffer buf_gds-prt     for ub.gds-prt  .
define variable v-type-price as integer   no-undo .
for each buf_price-doc-forming-gds no-lock  where
         buf_price-doc-forming-gds.stts       = integer('0':U) and
         buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
         buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
         buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
         buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id :
         find first buf_bar-code no-lock where buf_bar-code.b-code  = buf_price-doc-forming-gds.b-code .
         find first buf_goods    no-lock where buf_goods.gds-code   = buf_bar-code.gds-code .
         find first buf_gds-prt  no-lock where buf_gds-prt.node-code = buf_bar-code.node-code.
         if buf_goods.unit-base = buf_bar-code.unit-cli then do:
             if buf_gds-prt.upper-code = buf_goods.prt-root
               then v-type-price  = integer ('0':U) .
               else v-type-price  = integer ('2':U) .
         end.
         else do:
             if buf_gds-prt.upper-code = buf_goods.prt-root
               then v-type-price  = integer ('1':U) .
               else v-type-price  = integer ('3':U) .
         end.
         if buf_price-list-type.have-rs-qnty-group = 0 and
            buf_price-list-type.have-rs-sum-group  = false and
            buf_price-list-type.have-rs-turn-group = 0
         then do:
                run create-price-all in this-procedure
                  ( input 0
                   ,input buf_price-doc-forming-gds.plt-id
                   ,input buf_price-doc-forming-gds.plt-db-num
                   ,input buf_price-doc-forming-gds.pdf-id
                   ,input buf_price-doc-forming-gds.pdf-db
                   ,input buf_price-doc-forming-gds.b-code
                   ,input buf_bar-code.gds-code
                   ,input v-type-price
                   ,input ?
                   ,input ?
                   ,input ?
                   ,input ?
                   ,input ?
                   ,input ?
                   ,input v-fact-order-shift-from
                   ,input v-fact-order-shift-to
                   ,input v-fact-order-sys-from
                   ,input v-fact-order-sys-to
                   ,input buf_price-doc-forming-gds.price-sale-doc
                ) no-error .
                if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute("Создание ДЭН (create-price-all по ГТПЛ) ...&1 &2",error-status :get-message(1),return-value)).
                return error return-value .
                end.
         end.
         else do:
                  if buf_price-list-type.have-rs-qnty-group = 1 then do:
                        for each buf_price-doc-forming-gds-qnty no-lock  where
                                buf_price-doc-forming-gds-qnty.stts       = integer('0':U) and
                                buf_price-doc-forming-gds-qnty.b-code     = buf_price-doc-forming-gds.b-code and
                                buf_price-doc-forming-gds-qnty.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                buf_price-doc-forming-gds-qnty.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                buf_price-doc-forming-gds-qnty.plt-id     = buf_price-doc-forming-gds.plt-id
                                :
                                find first  next_price-doc-forming-gds-qnty no-lock  where
                                            next_price-doc-forming-gds-qnty.stts       = integer('0':U) and
                                            next_price-doc-forming-gds-qnty.b-code     = buf_price-doc-forming-gds.b-code and
                                            next_price-doc-forming-gds-qnty.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                            next_price-doc-forming-gds-qnty.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                            next_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                            next_price-doc-forming-gds-qnty.plt-id     = buf_price-doc-forming-gds.plt-id and
                                            next_price-doc-forming-gds-qnty.ggr-qnty   > buf_price-doc-forming-gds-qnty.ggr-qnty
                                            use-index pi no-error .
                                run create-price-all in this-procedure
                                    (input 2
                                    ,input buf_price-doc-forming-gds.plt-id
                                    ,input buf_price-doc-forming-gds.plt-db-num
                                    ,input buf_price-doc-forming-gds.pdf-id
                                    ,input buf_price-doc-forming-gds.pdf-db
                                    ,input buf_price-doc-forming-gds.b-code
                                    ,input buf_bar-code.gds-code
                                    ,input v-type-price
                                    ,input buf_price-doc-forming-gds-qnty.ggr-qnty
                                    ,input ( if available next_price-doc-forming-gds-qnty then next_price-doc-forming-gds-qnty.ggr-qnty  else ? )
                                    ,input ?
                                    ,input ?
                                    ,input ?
                                    ,input ?
                                    ,input v-fact-order-shift-from
                                    ,input v-fact-order-shift-to
                                    ,input v-fact-order-sys-from
                                    ,input v-fact-order-sys-to
                                    ,input buf_price-doc-forming-gds-qnty.price-sale-doc
                                  ) no-error .
                                  if error-status :error then do:
                                    run write-log-and-file in p-log-handle (
                                          input 1
                                        , input log-file-name
                                        , input 1
                                        , input substitute("Создание ДЭН (create-price-all ) привязка по количеству ...&1 &2",error-status :get-message(1),return-value)).
                                      return error return-value .
                                  end.
                        end.
                  end.
                  if int ( buf_price-list-type.have-rs-sum-group) = 1 then do:
                       for each buf_price-doc-forming-gds-sum       no-lock  where
                                buf_price-doc-forming-gds-sum.stts       = integer('0':U) and
                                buf_price-doc-forming-gds-sum.b-code     = buf_price-doc-forming-gds.b-code and
                                buf_price-doc-forming-gds-sum.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                buf_price-doc-forming-gds-sum.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                buf_price-doc-forming-gds-sum.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                buf_price-doc-forming-gds-sum.plt-id     = buf_price-doc-forming-gds.plt-id
                                :
                                find first  next_price-doc-forming-gds-sum no-lock  where
                                            next_price-doc-forming-gds-sum.stts       = integer('0':U) and
                                            next_price-doc-forming-gds-sum.b-code     = buf_price-doc-forming-gds.b-code and
                                            next_price-doc-forming-gds-sum.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                            next_price-doc-forming-gds-sum.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                            next_price-doc-forming-gds-sum.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                            next_price-doc-forming-gds-sum.plt-id     = buf_price-doc-forming-gds.plt-id and
                                            next_price-doc-forming-gds-sum.ssg-summa  > buf_price-doc-forming-gds-sum.ssg-summa
                                            use-index pi no-error .
                                run create-price-all in this-procedure
                                    (input 3
                                    ,input buf_price-doc-forming-gds.plt-id
                                    ,input buf_price-doc-forming-gds.plt-db-num
                                    ,input buf_price-doc-forming-gds.pdf-id
                                    ,input buf_price-doc-forming-gds.pdf-db
                                    ,input buf_price-doc-forming-gds.b-code
                                    ,input buf_bar-code.gds-code
                                    ,input v-type-price
                                    ,input ?
                                    ,input ?
                                    ,input buf_price-doc-forming-gds-sum.ssg-summa
                                    ,input ( if available next_price-doc-forming-gds-sum then next_price-doc-forming-gds-sum.ssg-summa  else ? )
                                    ,input ?
                                    ,input ?
                                    ,input v-fact-order-shift-from
                                    ,input v-fact-order-shift-to
                                    ,input v-fact-order-sys-from
                                    ,input v-fact-order-sys-to
                                    ,input buf_price-doc-forming-gds-sum.price-sale-doc
                                  ) no-error .
                                  if error-status :error then do:
                                    run write-log-and-file in p-log-handle (
                                          input 1
                                        , input log-file-name
                                        , input 1
                                        , input substitute("Создание ДЭН (create-price-all ) привязка по сумме ...&1 &2",error-status :get-message(1),return-value)).
                                      return error return-value .
                                  end.
                        end.
                  end.
                  if buf_price-list-type.have-rs-turn-group = 1 then do:
                        for each buf_price-doc-forming-gds-tnv no-lock  where
                                buf_price-doc-forming-gds-tnv.stts       = integer('0':U) and
                                buf_price-doc-forming-gds-tnv.b-code     = buf_price-doc-forming-gds.b-code and
                                buf_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming-gds.plt-id
                                :
                                find first  next_price-doc-forming-gds-tnv no-lock  where
                                            next_price-doc-forming-gds-tnv.stts       = integer('0':U) and
                                            next_price-doc-forming-gds-tnv.b-code     = buf_price-doc-forming-gds.b-code and
                                            next_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming-gds.pdf-db and
                                            next_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming-gds.pdf-id and
                                            next_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
                                            next_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming-gds.plt-id and
                                            next_price-doc-forming-gds-tnv.ttg-summa   > buf_price-doc-forming-gds-tnv.ttg-summa
                                            use-index pi no-error .
                                run create-price-all in this-procedure
                                    (input 4
                                    ,input buf_price-doc-forming-gds.plt-id
                                    ,input buf_price-doc-forming-gds.plt-db-num
                                    ,input buf_price-doc-forming-gds.pdf-id
                                    ,input buf_price-doc-forming-gds.pdf-db
                                    ,input buf_price-doc-forming-gds.b-code
                                    ,input buf_bar-code.gds-code
                                    ,input v-type-price
                                    ,input ?
                                    ,input ?
                                    ,input ?
                                    ,input ?
                                    ,input buf_price-doc-forming-gds-tnv.ttg-summa
                                    ,input ( if available next_price-doc-forming-gds-tnv then next_price-doc-forming-gds-tnv.ttg-summa  else ? )
                                    ,input v-fact-order-shift-from
                                    ,input v-fact-order-shift-to
                                    ,input v-fact-order-sys-from
                                    ,input v-fact-order-sys-to
                                    ,input buf_price-doc-forming-gds-tnv.price-sale-doc
                                      ) no-error .
                                  if error-status :error then do:
                                    run write-log-and-file in p-log-handle (
                                          input 1
                                        , input log-file-name
                                        , input 1
                                        , input substitute("Создание ДЭН (create-price-all ) привязка по обороту ...&1 &2",error-status :get-message(1),return-value)).
                                      return error return-value .
                                  end.
                        end.
                  end.
               end.
  end.
define variable v-pl-recid as recid no-undo .
define variable v-list-recid as character no-undo .
define variable vv as integer   no-undo .
define variable i  as integer   no-undo .
define variable v-stat-mode as character no-undo .
define buffer buf_price-doc for ub.price-doc  .
define buffer ch_price-list-type for ub.price-list-type  .
 overval-err = false .
 overval-err-str = "" .
if buf_price-list-type.create-price-doc = integer(true) then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Создание переоценок ...")).
end.
for each buf_price-doc no-lock  where
         buf_price-doc.pdf-db     = buf_price-doc-forming.pdf-db and
         buf_price-doc.pdf-id     = buf_price-doc-forming.pdf-id and
         buf_price-doc.plt-db-num = buf_price-doc-forming.plt-db-num and
         buf_price-doc.plt-id     = buf_price-doc-forming.plt-id :
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute("уже Готова переоценка &1 в статусе &2 ",buf_price-doc.doc-num,buf_price-doc.status_)).
end.
  run metod-gop-obj in this-procedure ( v-cntxt-db-num, buf_price-list-type.gop-id , buf_price-list-type.gop-db-num) no-error .
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("список объектов ...&1 &2   текущая БД:&3    gop-id:&4   gop-db-num:&5",error-status :get-message(1),return-value,v-cntxt-db-num, buf_price-list-type.gop-id , buf_price-list-type.gop-db-num)).
        return error return-value .
  end.
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) .
if p-esc-prd = true then do:
   for each x_obj-group  where
            x_obj-group.obj-type = p-ecs-type and
            x_obj-group.obj-code = p-ecs-code  :
   delete x_obj-group.
   end.
end.
if v-cntxt-db-num <> 0 or p-action = "cost-price-act" then do:
   for each x_obj-group  :
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output o-db-num
  )  .
    if o-db-num <> v-cntxt-db-num then do:
       delete x_obj-group.
    end.
   end.
end.
if buf_price-list-type.main = true then do:
  run create-price-list-mpl in this-procedure
  (   input  buf_price-doc-forming.pdf-db ,
      input  buf_price-doc-forming.pdf-id ,
      input  buf_price-doc-forming.plt-db-num ,
      input  buf_price-doc-forming.plt-id ,
      output v-pl-recid ,
      output v-list-recid
      ) no-error .
      if error-status :error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("create-price-list-mpl ...&1 &2   ",error-status :get-message(1),return-value)).
          return error return-value .
      end.
      vv = num-entries (v-list-recid).
      repeat i = 1 to vv :
        find first buf_price-doc no-lock where recid(buf_price-doc) = integer ( entry (i,v-list-recid)) no-error .
        if available buf_price-doc then do:
            case p-action :
              when 'факт':U then do:
                  v-stat-mode = "close-act"   .
                  if v-cntxt-db-num = 0  then do:
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output o-db-num
  )  .
                        if o-db-num <> 0 then do:
                          v-stat-mode = "close"       .
                        end.
                  end.
              end.
              when "cost-price-act"  then do:
                  v-stat-mode = "act"   .
              end.
              otherwise do:
                  v-stat-mode = "close"       .
              end.
            end case.
            find first buf_price-doc exclusive-lock where recid(buf_price-doc) = integer ( entry (i,v-list-recid) ) no-error .
            assign
              buf_price-doc.out-code  = buf_price-doc-forming.out-code
            .
            if trim(buf_price-doc-forming.name,"@") <> "" then
                    buf_price-doc.PS  =  trim ( buf_price-doc-forming.name,"@" ) .
            varoldstatus = buf_price-doc.status_.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
            run str/pr-stat.p
              ( input parParentProc
              , input p-log-handle
              , input v-stat-mode
              , input buf_price-doc.doc-num
              , input buf_price-doc.out-code
              , input p-ask-pr
              , input p-do
              ) no-error .
              if error-status :error then do:
                 v-mess = substitute("Ошибка закрытия переоценки N &3...&1 &2   ",error-status :get-message(1),return-value, buf_price-doc.doc-num).
                  run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input v-mess ).
                overval-err = true .
                overval-err-str = overval-err-str + return-value + " №" + buf_price-doc.doc-num + " " .
                if available (buf_price-doc)
                then do:
                  v-vid-action = 57 .
                  v-vid-param = "Initiator=" + v-initiator + chr(4) +
                                "SHOP_NUM=" + string(buf_price-doc.obj-code) + chr(4) +
                                "DocNum=" + string(buf_price-doc.doc-num) + chr(4) +
                                "DocType=" + "Переоценка" + chr(4) +
                                "FactDate=" + (if string(buf_price-doc.fact-date) = ? then '' else string(buf_price-doc.fact-date)) + chr(4) +
                                "ShiftNum=" + (if string(buf_price-doc.shift-num) = ? then '' else string(buf_price-doc.shift-num)) + chr(4) +
                                "ShiftDate=" + (if string(buf_price-doc.shift-date) = ? then '' else string(buf_price-doc.shift-date)) + chr(4) +
                                "ShiftNumCurr=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + chr(4) +
                                "ShiftDateCurr=" + (if string(varshift-date) = ? then '' else string(varshift-date)) + chr(4) +
                                "StatusOld=" + varoldstatus + chr(4) +
                                "StatusNew=" + string(buf_price-doc.status_) + chr(4) +
                                "RESULT=1" + chr(4) +
                                "Description=" + v-mess.
                  run trg/userlog.p (
                        input 'update_err':U
                      , input 'price-doc':U
                      , input ( buffer buf_price-doc :handle )
                      , input v-vid-action
                      , input v-vid-param
                  ) no-error.
                end.
                return error return-value + chr(10) + v-mess .
              end.
              find current buf_price-doc no-lock no-error .
              if available buf_price-doc then do:
                  run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input substitute("Готова переоценка &1 в статусе &2 ",buf_price-doc.doc-num,buf_price-doc.status_)).
                  v-vid-action = 57 .
                  v-vid-param = "Initiator=" + v-initiator + chr(4) +
                                "SHOP_NUM=" + string(buf_price-doc.obj-code) + chr(4) +
                                "DocNum=" + string(buf_price-doc.doc-num) + chr(4) +
                                "DocType=" + "Переоценка" + chr(4) +
                                "FactDate=" + (if string(buf_price-doc.fact-date) = ? then '' else string(buf_price-doc.fact-date)) + chr(4) +
                                "SHIFT_NUM_DOC=" + (if string(buf_price-doc.shift-num) = ? then '' else string(buf_price-doc.shift-num)) + (if string(buf_price-doc.shift-date) = ? then '' else string(buf_price-doc.shift-date, "99999999")) + chr(4) +
                                "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + chr(4) +
                                "StatusOld=" + varoldstatus + chr(4) +
                                "StatusNew=" + string(buf_price-doc.status_) + chr(4) +
                                "RESULT=" + chr(4) +
                                "Description=" no-error.
                  find last ub.c-price-doc no-lock where ub.c-price-doc.doc-num = buf_price-doc.doc-num no-error.
                  if available (ub.c-price-doc)
                  then do:
                    run trg/userlog.p (
                          input 'update':U
                        , input 'c-price-doc':U
                        , input ( buffer ub.c-price-doc :handle )
                        , input v-vid-action
                        , input v-vid-param
                    ) no-error.
                  end.
              end.
        end.
      end.
      if overval-err = false then do:
          run str/pdfdisca.p (
              input parParentProc,
              input recid(buf_price-doc-forming),
              input p-log-handle ,
              input log-file-name
              ) no-error.
              if error-status :error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute("Ошибка формирования автоматических ДНЦ в момент закрытия  ДНЦ ГТПЛ  &1 &2 ",error-status :get-message(1),return-value )).
                undo, return error return-value .
              end.
              for each buf_price-doc no-lock where
                       buf_price-doc.pdf-id  = buf_price-doc-forming.pdf-id and
                       buf_price-doc.pdf-db  = buf_price-doc-forming.pdf-db and
                       buf_price-doc.plt-id  = buf_price-doc-forming.plt-id and
                       buf_price-doc.plt-db  = buf_price-doc-forming.plt-db and
                       buf_price-doc.status_ = 'акт':U
              :
                  run str/pdfdiscl.p ( Parparentproc , buf_price-doc.doc-num ) no-error .
                  if error-status :error then do:
                      if return-value = 'no-records'  then do:
                      message
                        error-status :get-message(1) skip
                        "Нет ни одной записи!"
                        view-as alert-box error
                      .
                      undo, return error "Ошибка при закрытиии порожденных ДНЦ. Нет записей ." .
                      end.
                      else do:
                      message
                        vss-workfile vss-revision vss-description skip
                        error-status :get-message(1) skip
                        return-value skip
                        "pdfdiscl"
                        view-as alert-box error
                      .
                      undo, return error "Ошибка при закрытиии порожденных ДНЦ." + return-value .
                      end.
                  end.
              end.
      end.
end.
if overval-err = true then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка закрытия переоценки  &3...&1 &2   ",error-status :get-message(1),return-value, overval-err-str)).
    return error overval-err-str .
end.
else do:
    assign
      buf_price-doc-forming.stts = integer('3':U)
    .
     release buf_price-doc-forming no-error .
     find first buf_price-doc-forming exclusive-lock where recid ( buf_price-doc-forming ) = p-recid no-error .
    define variable v-ask  as logical   no-undo init false .
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run a-nwspdf in g#library2
  (input  buf_price-doc-forming.plt-id
  ,input  buf_price-doc-forming.plt-db-num
  ,input  buf_price-doc-forming.pdf-id
  ,input  buf_price-doc-forming.pdf-db
  ,output v-ask
  )  .
    if v-ask then do:
      run str/diallog.w
              ( input parparentproc
              , input p-log-handle
              , input 'str/sendpdfr.p':U
              , input ("U":U + chr(4) +
                      string(buf_price-doc-forming.plt-id) + chr(4)  +
                      string(buf_price-doc-forming.plt-db-num) + chr(4) +
                      string(buf_price-doc-forming.pdf-id) + chr(4)  +
                      string(buf_price-doc-forming.pdf-db)
                      )
              , input yes
              , input '':U
              , input '') no-error .
    end.
 end.
   if  can-find ( first ch_price-list-type no-lock where
                        ch_price-list-type.stts            = integer('0':U) and
                        ch_price-list-type.plt-main-id     = buf_price-list-type.plt-id and
                        ch_price-list-type.plt-main-db-num = buf_price-list-type.plt-db-num ) then do:
        run str/cr-chpdf.p
            ( parparentproc ,
              p-recid ,
              p-action ,
              p-trn-doc ,
              p-ask-pr  ) no-error .
              if error-status :error then do:
                  run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input substitute("Создание и закрытие подчиненных ДНЦ ...&1 &2   ",error-status :get-message(1),return-value)).
              end.
   end.
procedure exp-prt :
define input  param g-code  like ub.goods.gds-code    no-undo.
define input  param old-num like ub.price-doc.doc-num no-undo.
define input  param new-num like ub.price-doc.doc-num no-undo.
define output param new-rec as recid               no-undo.
end procedure.
procedure dfc-create-date :
define variable v-shift-date as date      no-undo .
define variable v-shift-num  as integer   no-undo .
define variable v-shift-name as character no-undo .
define variable v-obj-date   as date      no-undo .
define variable l-shift-on as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-obj-date
  ) no-error .
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("curobjdt: &1 &2 объект &3&4  " , error-status :get-message(1),return-value,v-cntxt-obj-type, v-cntxt-obj-code )).
  end.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  'shift-on=request':U
  ,output l-shift-on
  ) no-error .
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("objat: &1 &2 объект &3&4" , error-status :get-message(1),return-value,v-cntxt-obj-type, v-cntxt-obj-code )).
  end.
if l-shift-on then do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name
  ) no-error .
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("curshift: &1 &2 объект &3&4" , error-status :get-message(1),return-value,v-cntxt-obj-type, v-cntxt-obj-code )).
  end.
end.
   if buf_price-doc-forming.have-start-period = integer( false ) then do:
      case buf_price-list-type.work-date :
          when int('1':U)     then
            do :
               buf_price-doc-forming.start-date = v-obj-date .
            end.
          when int('2':U)   then
            do :
                 assign
                    buf_price-doc-forming.start-shift-date  = v-shift-date
                    buf_price-doc-forming.start-shift-num   = v-shift-num
                    buf_price-doc-forming.start-shift-name  = v-shift-name
                    .
            end.
          when int('3':U)     then
            do :
                buf_price-doc-forming.start-sys-date = today .
            end.
      end case.
      buf_price-doc-forming.start-sys-time = time .
   end.
  end.
end procedure.
procedure dfc-pr-good :
  do
  on error undo, return error return-value
  :
    define variable v-type-goods as integer   no-undo .
    define variable i as integer   no-undo .
    define variable is-petrolium as logical   no-undo .
    define variable is-pieces    as logical   no-undo .
    define variable v-next as logical   no-undo .
    if par-pr-goods = "" or num-entries (par-pr-goods,".") <> 2 then v-type-goods = integer('1':U) .
    repeat i = 1 to 8 :
      if par-pr-goods begins string(i) + "."  then  do:
        v-type-goods = i .
        leave.
      end.
    end.
  v-errstr = "" .
      for each buf_price-doc-forming-gds  where
               buf_price-doc-forming-gds.pdf-id = buf_price-doc-forming.pdf-id and
               buf_price-doc-forming-gds.pdf-db = buf_price-doc-forming.pdf-db and
               buf_price-doc-forming-gds.plt-id = buf_price-doc-forming.plt-id and
               buf_price-doc-forming-gds.plt-db = buf_price-doc-forming.plt-db
      :
        find first buf_goods no-lock
          where buf_goods.artic     = buf_price-doc-forming-gds.artic
            and buf_goods.prod-type = buf_price-doc-forming-gds.prod-type
            and buf_goods.prod-code = buf_price-doc-forming-gds.prod-code
          no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) .
  if g#esys
  then do :
    v-next = true .
  end.
  else do :
    run ver-pr-nogds ( input  buf_goods.gds-code , input par-pr-nogds, output v-next , output v-errstr ) .
  end.
  if not v-next then do:
    case string(v-type-goods) :
    when '8':U       then do:
      v-errstr = "Запрет на включение в переоценку товаров, услуг и топлива." .
            return error v-errstr .
    end.
    when '2':U     then do:
        if buf_goods.gds-type = 'т':U  and is-petrolium = false  then do:
          v-errstr = substitute("Запрет на добавление товаров в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type ) .
            return error v-errstr .
        end.
    end.
    when '3':U    then do:
        if is-petrolium then do:
           v-errstr = substitute("Запрет на добавление топлива в переоценку. " , buf_goods.artic, buf_goods.gds-name ) .
            return error v-errstr .
        end.
    end.
    when '4':U      then do:
        if buf_goods.gds-type = 'у':U then do:
           v-errstr = substitute("Запрет на добавление услуг в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type ) .
            return error v-errstr .
        end.
    end.
    when '5':U  then do:
        if buf_goods.gds-type = 'т':U and is-petrolium = false  then do:
           v-errstr = substitute("Запрет на добавление товаров и услуг в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type , buf_goods.unit-base ) .
            return error v-errstr .
        end.
        if buf_goods.gds-type = 'у':U then do:
           v-errstr = substitute("Запрет на добавление товаров и услуг в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type ) .
            return error v-errstr .
        end.
    end.
    when '6':U  then do:
        if buf_goods.gds-type <> 'у':U  then do:
           v-errstr = substitute("Запрет на добавление топлива и товара в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type, buf_goods.unit-base ) .
            return error v-errstr .
        end.
    end.
    when '7':U then do:
        if buf_goods.gds-type = 'т':U and is-petrolium = true   then do:
          v-errstr = substitute("Запрет на добавление услуг и топлива в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.unit-base ) .
            return error v-errstr .
        end.
        if buf_goods.gds-type = 'у':U then do:
           v-errstr = substitute("Запрет на добавление услуг и топлива в переоценку. " , buf_goods.artic, buf_goods.gds-name, buf_goods.gds-type ) .
            return error v-errstr .
        end.
    end.
  end case.
  end.
end.
  end.
end procedure.
