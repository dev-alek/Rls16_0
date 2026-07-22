block-level on error undo, throw.
define input  parameter parparentproc as handle no-undo    .
define input  parameter p-recid       as recid no-undo     .
define input  parameter p-action      as character no-undo .
define input  parameter p-trn-doc     as character no-undo .
define input  parameter p-ask-pr      as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cr-chpdf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/cr-chpdf.p $":U .
define variable vss-description as character no-undo init "Cоздание ДНЦ-детей по Кустовому ТПЛ".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-doc-forming-attr     for ub.price-doc-forming-attr .
define buffer buf_price-doc-forming-gds      for ub.price-doc-forming-gds  .
define buffer buf_price-doc-forming-gds-sum  for ub.price-doc-forming-gds-sum  .
define buffer buf_price-doc-forming-gds-tnv  for ub.price-doc-forming-gds-tnv  .
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer child_price-list-type for ub.price-list-type  .
define buffer bufold_price-doc-forming for ub.price-doc-forming  .
define variable v1-recid as recid no-undo .
define variable v1-cur-rt as decimal   no-undo .
define variable v1-cur-ex as decimal   no-undo .
find first buf_price-doc-forming exclusive-lock where recid ( buf_price-doc-forming) = p-recid no-error .
if error-status :error then return error return-value .
find first buf_price-list-type no-lock where
           buf_price-list-type.stts = integer('0':U) and
           buf_price-list-type.under-type-list = 0 and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num and
           buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id
           no-error .
if error-status :error then return error return-value .
define variable v-pdf-id     as integer   no-undo .
define variable v-pdf-db as integer   no-undo .
run waitfram-show in this-procedure ("Создание подчиненных ДНЦ ...") .
for each child_price-list-type exclusive-lock where
         child_price-list-type.stts = integer('0':U) and
         child_price-list-type.under-type-list = 1 and
         child_price-list-type.plt-main-db-num = buf_price-doc-forming.plt-db-num and
         child_price-list-type.plt-main-id     = buf_price-doc-forming.plt-id :
         run waitfram-show in this-procedure ("Создание подчиненных ДНЦ " + string( child_price-list-type.plt-id) + " БД:" + string ( child_price-list-type.plt-db-num)) .
         assign
          v-pdf-id = next-value ( s-pdf , ub)
          v-pdf-db = v-cntxt-db-num
         .
         create ub.price-doc-forming .
         buffer-copy buf_price-doc-forming to ub.price-doc-forming
         assign
            ub.price-doc-forming.plt-id       = child_price-list-type.plt-id
            ub.price-doc-forming.plt-db-num   = child_price-list-type.plt-db-num
            ub.price-doc-forming.pdf-id       = v-pdf-id
            ub.price-doc-forming.pdf-db       = v-pdf-db
            ub.price-doc-forming.stts         = integer('0':U)
            ub.price-doc-forming.sys-date     = today
            ub.price-doc-forming.sys-time     = time
            ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
            ub.price-doc-forming.who          = v-cntxt-userid
            ub.price-doc-forming.des          = "Подчиненный"
            ub.price-doc-forming.main-pdf-id  =  buf_price-doc-forming.pdf-id
            ub.price-doc-forming.main-pdf-db  =  buf_price-doc-forming.pdf-db
         .
         for each buf_price-doc-forming-attr     no-lock   where
                  buf_price-doc-forming-attr.plt-id     = buf_price-doc-forming.plt-id and
                  buf_price-doc-forming-attr.plt-db-num = buf_price-doc-forming.plt-db-num and
                  buf_price-doc-forming-attr.pdf-id     = buf_price-doc-forming.pdf-id and
                  buf_price-doc-forming-attr.pdf-db = buf_price-doc-forming.pdf-db :
                  create ub.price-doc-forming-attr.
                  buffer-copy buf_price-doc-forming-attr to ub.price-doc-forming-attr
                  assign
                    ub.price-doc-forming-attr.plt-id       = child_price-list-type.plt-id
                    ub.price-doc-forming-attr.plt-db-num   = child_price-list-type.plt-db-num
                    ub.price-doc-forming-attr.pdf-id       = v-pdf-id
                    ub.price-doc-forming-attr.pdf-db       = v-pdf-db
                  .
         end.
         for each buf_price-doc-forming-gds      no-lock   where
                  buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
                  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
                  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
                  buf_price-doc-forming-gds.pdf-db = buf_price-doc-forming.pdf-db :
                  create ub.price-doc-forming-gds.
                  buffer-copy buf_price-doc-forming-gds to ub.price-doc-forming-gds
                  assign
                    ub.price-doc-forming-gds.plt-id           = child_price-list-type.plt-id
                    ub.price-doc-forming-gds.plt-db-num       = child_price-list-type.plt-db-num
                    ub.price-doc-forming-gds.pdf-id           = v-pdf-id
                    ub.price-doc-forming-gds.pdf-db           = v-pdf-db
                    ub.price-doc-forming-gds.price-calc-doc   = buf_price-doc-forming-gds.price-sale-doc
                    ub.price-doc-forming-gds.price-calc-rubl  = buf_price-doc-forming-gds.price-sale-rubl
                    ub.price-doc-forming-gds.price-calc-base  = buf_price-doc-forming-gds.price-sale-base
                  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-mpl in g#library2
  (input  child_price-list-type.gop-id
  ,input  child_price-list-type.gop-db-num
  ,input  ub.price-doc-forming-gds.b-code
  ,input  0
  ,input  0
  ,output v1-recid
  ,output ub.price-doc-forming-gds.price-prev-doc
  ,output v1-cur-rt
  ,output v1-cur-ex
  ) no-error .
                find first bufold_price-doc-forming where  recid(bufold_price-doc-forming) = v1-recid no-lock no-error .
                ub.price-doc-forming-gds.prev-doc-code = if available bufold_price-doc-forming
                then (string(bufold_price-doc-forming.pdf-id) + " БД" + string(bufold_price-doc-forming.pdf-db))
                else "" .
                  run new-price in this-procedure (
                       input child_price-list-type.calc-increase-pc
                      ,input child_price-list-type.calc-round-method
                      ,input child_price-list-type.calc-round-base
                      ,input buf_price-doc-forming-gds.price-sale-doc
                      ,input buf_price-doc-forming-gds.price-sale-rubl
                      ,input buf_price-doc-forming-gds.price-sale-base
                      ,output ub.price-doc-forming-gds.price-sale-doc
                      ,output ub.price-doc-forming-gds.price-sale-rubl
                      ,output ub.price-doc-forming-gds.price-sale-base
                      ) .
         end.
         for each buf_price-doc-forming-gds-sum  no-lock where
                  buf_price-doc-forming-gds-sum.plt-id     = buf_price-doc-forming.plt-id and
                  buf_price-doc-forming-gds-sum.plt-db-num = buf_price-doc-forming.plt-db-num and
                  buf_price-doc-forming-gds-sum.pdf-id     = buf_price-doc-forming.pdf-id and
                  buf_price-doc-forming-gds-sum.pdf-db = buf_price-doc-forming.pdf-db :
                  create ub.price-doc-forming-gds-sum.
                  buffer-copy buf_price-doc-forming-gds-sum to ub.price-doc-forming-gds-sum
                  assign
                    ub.price-doc-forming-gds-sum.plt-id           = child_price-list-type.plt-id
                    ub.price-doc-forming-gds-sum.plt-db-num       = child_price-list-type.plt-db-num
                    ub.price-doc-forming-gds-sum.pdf-id           = v-pdf-id
                    ub.price-doc-forming-gds-sum.pdf-db           = v-pdf-db
                    ub.price-doc-forming-gds-sum.price-calc-doc   = buf_price-doc-forming-gds-sum.price-sale-doc
                    ub.price-doc-forming-gds-sum.price-calc-rubl  = buf_price-doc-forming-gds-sum.price-sale-rubl
                    ub.price-doc-forming-gds-sum.price-calc-base  = buf_price-doc-forming-gds-sum.price-sale-base
                  .
                  run new-price in this-procedure (
                       input child_price-list-type.calc-increase-pc
                      ,input child_price-list-type.calc-round-method
                      ,input child_price-list-type.calc-round-base
                      ,input buf_price-doc-forming-gds-sum.price-sale-doc
                      ,input buf_price-doc-forming-gds-sum.price-sale-rubl
                      ,input buf_price-doc-forming-gds-sum.price-sale-base
                      ,output ub.price-doc-forming-gds-sum.price-sale-doc
                      ,output ub.price-doc-forming-gds-sum.price-sale-rubl
                      ,output ub.price-doc-forming-gds-sum.price-sale-base
                      ) .
         end.
         for each buf_price-doc-forming-gds-tnv  no-lock  where
                  buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming.plt-id and
                  buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming.plt-db-num and
                  buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming.pdf-id and
                  buf_price-doc-forming-gds-tnv.pdf-db = buf_price-doc-forming.pdf-db :
                  create ub.price-doc-forming-gds-tnv.
                  buffer-copy buf_price-doc-forming-gds-tnv to ub.price-doc-forming-gds-tnv
                  assign
                    ub.price-doc-forming-gds-tnv.plt-id           = child_price-list-type.plt-id
                    ub.price-doc-forming-gds-tnv.plt-db-num       = child_price-list-type.plt-db-num
                    ub.price-doc-forming-gds-tnv.pdf-id           = v-pdf-id
                    ub.price-doc-forming-gds-tnv.pdf-db           = v-pdf-db
                    ub.price-doc-forming-gds-tnv.price-calc-doc   = buf_price-doc-forming-gds-tnv.price-sale-doc
                    ub.price-doc-forming-gds-tnv.price-calc-rubl  = buf_price-doc-forming-gds-tnv.price-sale-rubl
                    ub.price-doc-forming-gds-tnv.price-calc-base  = buf_price-doc-forming-gds-tnv.price-sale-base
                  .
                  run new-price in this-procedure (
                       input child_price-list-type.calc-increase-pc
                      ,input child_price-list-type.calc-round-method
                      ,input child_price-list-type.calc-round-base
                      ,input buf_price-doc-forming-gds-tnv.price-sale-doc
                      ,input buf_price-doc-forming-gds-tnv.price-sale-rubl
                      ,input buf_price-doc-forming-gds-tnv.price-sale-base
                      ,output ub.price-doc-forming-gds-tnv.price-sale-doc
                      ,output ub.price-doc-forming-gds-tnv.price-sale-rubl
                      ,output ub.price-doc-forming-gds-tnv.price-sale-base
                      ) .
         end.
         for each buf_price-doc-forming-gds-qnty no-lock  where
                  buf_price-doc-forming-gds-qnty.plt-id     = buf_price-doc-forming.plt-id and
                  buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming.plt-db-num and
                  buf_price-doc-forming-gds-qnty.pdf-id     = buf_price-doc-forming.pdf-id and
                  buf_price-doc-forming-gds-qnty.pdf-db     = buf_price-doc-forming.pdf-db :
                  create ub.price-doc-forming-gds-qnty.
                  buffer-copy buf_price-doc-forming-gds-qnty to ub.price-doc-forming-gds-qnty
                  assign
                    ub.price-doc-forming-gds-qnty.plt-id           = child_price-list-type.plt-id
                    ub.price-doc-forming-gds-qnty.plt-db-num       = child_price-list-type.plt-db-num
                    ub.price-doc-forming-gds-qnty.pdf-id           = v-pdf-id
                    ub.price-doc-forming-gds-qnty.pdf-db           = v-pdf-db
                    ub.price-doc-forming-gds-qnty.price-calc-doc   = buf_price-doc-forming-gds-qnty.price-sale-doc
                    ub.price-doc-forming-gds-qnty.price-calc-rubl  = buf_price-doc-forming-gds-qnty.price-sale-rubl
                    ub.price-doc-forming-gds-qnty.price-calc-base  = buf_price-doc-forming-gds-qnty.price-sale-base
                  .
                  run new-price in this-procedure (
                       input child_price-list-type.calc-increase-pc
                      ,input child_price-list-type.calc-round-method
                      ,input child_price-list-type.calc-round-base
                      ,input buf_price-doc-forming-gds-qnty.price-sale-doc
                      ,input buf_price-doc-forming-gds-qnty.price-sale-rubl
                      ,input buf_price-doc-forming-gds-qnty.price-sale-base
                      ,output ub.price-doc-forming-gds-qnty.price-sale-doc
                      ,output ub.price-doc-forming-gds-qnty.price-sale-rubl
                      ,output ub.price-doc-forming-gds-qnty.price-sale-base
                      ) .
         end.
          if child_price-list-type.under-hand-corr = 0 then do:
    run str/diallog.w
        (parparentproc
        , this-procedure
        , 'str/pdf-clos.p':U
        , ( string(recid(ub.price-doc-forming)) + chr(4) +
           'no' + chr(4) +
           'no' + chr(4) +
           '?' + chr(4) +
           '?' + chr(4) +
           string(p-action) + chr(4) +
           p-trn-doc + chr(4) +
           string(p-ask-pr)  )
        , yes
        , '':U
        , 'Закрытие ДНЦ') no-error .
         end.
end.
run waitfram-hide in this-procedure  .
procedure new-price :
define input  parameter  p-increase-pc      as decimal   no-undo .
define input  parameter  p-round-method     as character no-undo .
define input  parameter  p-round-base       as decimal   no-undo .
define input  parameter  p-price-calc-doc   as decimal   no-undo .
define input  parameter  p-price-calc-rubl  as decimal   no-undo .
define input  parameter  p-price-calc-base  as decimal   no-undo .
define output parameter  p-price-sale-doc   as decimal   no-undo .
define output parameter  p-price-sale-rubl  as decimal   no-undo .
define output parameter  p-price-sale-base  as decimal   no-undo .
  do
  on error undo, return error return-value
  :
   p-price-sale-doc   = p-price-calc-doc  * ( 1 + ( p-increase-pc / 100 )) .
   p-price-sale-rubl  = p-price-calc-rubl * ( 1 + ( p-increase-pc / 100 )) .
   p-price-sale-base  = p-price-calc-base * ( 1 + ( p-increase-pc / 100 )) .
case p-round-method :
  when '9-окончание':U then do:
    if p-price-sale-doc < 29 then do:
      if (p-price-sale-doc - truncate (p-price-sale-doc, 0)) <> 0 then do:
        assign
          p-price-sale-doc = truncate (p-price-sale-doc, 0) + 1
        .
      end.
    end.
    else do:
      if (p-price-sale-doc modulo 10) < 3 then do:
        assign
          p-price-sale-doc = (p-price-sale-doc - (p-price-sale-doc modulo 100))
              + ( truncate (((p-price-sale-doc modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          p-price-sale-doc = (p-price-sale-doc - (p-price-sale-doc modulo 100))
              + ( truncate (((p-price-sale-doc modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        p-price-sale-doc = round (p-price-sale-doc, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if p-price-sale-doc < p-round-base then do:
      assign
        p-price-sale-doc = truncate (p-price-sale-doc, 0) + 0.99
      .
    end.
    else do:
      assign
        p-price-sale-doc = truncate (p-price-sale-doc / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      p-price-sale-doc = round (p-price-sale-doc, 0)
    .
  end.
  when 'Произвольно':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-doc = round (p-price-sale-doc / p-round-base, 0) * p-round-base
      .
      if p-price-sale-doc = 0 then do:
        assign
          p-price-sale-doc = p-round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if p-round-base <> 0 then do:
      if truncate ( p-price-sale-doc / p-round-base, 0 ) <> (p-price-sale-doc / p-round-base) then do:
        assign
          p-price-sale-doc = truncate (p-price-sale-doc / p-round-base, 0) * p-round-base + p-round-base
        .
      end.
    end.
    if p-price-sale-doc = 0 then do:
      assign
        p-price-sale-doc = p-round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-doc = p-price-sale-doc * p-round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" p-round-method skip
      "round-base"   p-round-base   skip
      "price"        p-price-sale-doc             skip
      view-as alert-box error .
  end.
end.
case p-round-method :
  when '9-окончание':U then do:
    if p-price-sale-rubl < 29 then do:
      if (p-price-sale-rubl - truncate (p-price-sale-rubl, 0)) <> 0 then do:
        assign
          p-price-sale-rubl = truncate (p-price-sale-rubl, 0) + 1
        .
      end.
    end.
    else do:
      if (p-price-sale-rubl modulo 10) < 3 then do:
        assign
          p-price-sale-rubl = (p-price-sale-rubl - (p-price-sale-rubl modulo 100))
              + ( truncate (((p-price-sale-rubl modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          p-price-sale-rubl = (p-price-sale-rubl - (p-price-sale-rubl modulo 100))
              + ( truncate (((p-price-sale-rubl modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        p-price-sale-rubl = round (p-price-sale-rubl, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if p-price-sale-rubl < p-round-base then do:
      assign
        p-price-sale-rubl = truncate (p-price-sale-rubl, 0) + 0.99
      .
    end.
    else do:
      assign
        p-price-sale-rubl = truncate (p-price-sale-rubl / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      p-price-sale-rubl = round (p-price-sale-rubl, 0)
    .
  end.
  when 'Произвольно':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-rubl = round (p-price-sale-rubl / p-round-base, 0) * p-round-base
      .
      if p-price-sale-rubl = 0 then do:
        assign
          p-price-sale-rubl = p-round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if p-round-base <> 0 then do:
      if truncate ( p-price-sale-rubl / p-round-base, 0 ) <> (p-price-sale-rubl / p-round-base) then do:
        assign
          p-price-sale-rubl = truncate (p-price-sale-rubl / p-round-base, 0) * p-round-base + p-round-base
        .
      end.
    end.
    if p-price-sale-rubl = 0 then do:
      assign
        p-price-sale-rubl = p-round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-rubl = p-price-sale-rubl * p-round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" p-round-method skip
      "round-base"   p-round-base   skip
      "price"        p-price-sale-rubl             skip
      view-as alert-box error .
  end.
end.
case p-round-method :
  when '9-окончание':U then do:
    if p-price-sale-base < 29 then do:
      if (p-price-sale-base - truncate (p-price-sale-base, 0)) <> 0 then do:
        assign
          p-price-sale-base = truncate (p-price-sale-base, 0) + 1
        .
      end.
    end.
    else do:
      if (p-price-sale-base modulo 10) < 3 then do:
        assign
          p-price-sale-base = (p-price-sale-base - (p-price-sale-base modulo 100))
              + ( truncate (((p-price-sale-base modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          p-price-sale-base = (p-price-sale-base - (p-price-sale-base modulo 100))
              + ( truncate (((p-price-sale-base modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        p-price-sale-base = round (p-price-sale-base, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if p-price-sale-base < p-round-base then do:
      assign
        p-price-sale-base = truncate (p-price-sale-base, 0) + 0.99
      .
    end.
    else do:
      assign
        p-price-sale-base = truncate (p-price-sale-base / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      p-price-sale-base = round (p-price-sale-base, 0)
    .
  end.
  when 'Произвольно':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-base = round (p-price-sale-base / p-round-base, 0) * p-round-base
      .
      if p-price-sale-base = 0 then do:
        assign
          p-price-sale-base = p-round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if p-round-base <> 0 then do:
      if truncate ( p-price-sale-base / p-round-base, 0 ) <> (p-price-sale-base / p-round-base) then do:
        assign
          p-price-sale-base = truncate (p-price-sale-base / p-round-base, 0) * p-round-base + p-round-base
        .
      end.
    end.
    if p-price-sale-base = 0 then do:
      assign
        p-price-sale-base = p-round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-base = p-price-sale-base * p-round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" p-round-method skip
      "round-base"   p-round-base   skip
      "price"        p-price-sale-base             skip
      view-as alert-box error .
  end.
end.
  end.
end procedure.
