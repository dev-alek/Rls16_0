block-level on error undo, throw.
DEFINE INPUT PARAMETER StartPoint as date no-undo.
DEFINE INPUT PARAMETER EndPoint as date no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-elvd2q.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/e-elvd2q.p $":U .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы для отчета Ведомости по клиентам".
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
define variable v-accum as integer no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-base-code as integer no-undo .
define variable v-pump-code as integer no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table dcards  no-undo
field d-card        like ub.dis-card.d-card
field chk-date      as date
field chk-time      as integer
field obj-type      like ub.chk-doc.obj-type
field obj-code      like ub.chk-doc.obj-code
field pump          as integer
field b-code        as integer
field gds-code      as integer
field cli-type      like ub.chk-doc.cli-type
field cli-code      like ub.chk-doc.cli-code
field cli-name      like ub.clients.obj-name
field price-real    like ub.chk-gds.price-base
field doc-qnty      like ub.chk-gds.doc-qnty
field sum-netto     as decimal
index pi
IS unique PRIMARY
d-card
chk-date
chk-time
gds-code
pump
obj-type
obj-code
price-real
index icli
cli-type
cli-code
index ipet
gds-code
price-real
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
define buffer buf_shop for ub.shop.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_clients for ub.clients.
define buffer buf_bar-code for ub.bar-code.
define buffer card_dcards for dcards.
define buffer pet_dcards for dcards.
define buffer buf_chk-gds for ub.chk-gds.
for each buf_shop no-lock:
  if v-curr-r-b = 'base':U then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  buf_shop.host-code
  ,output v-base-code
  )  .
  end.
  _chk-doc:
  FOR EACH buf_chk-doc NO-LOCK WHERE
          buf_chk-doc.obj-type = 'маг':U
      AND buf_chk-doc.obj-code = buf_shop.obj-code
      AND buf_chk-doc.chk-date >= StartPoint
      AND buf_chk-doc.chk-date <= EndPoint
      AND buf_chk-doc.out-code > '':U
      and buf_chk-doc.d-card > '':U:
    if LOOKUP(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,69,101,106,108,169,196,114,115,116,117,111,112,136,113,101,106,108,208,2,3,4,5,7,43,44':U) > 0 then next _CHk-doc.
    PROCESS EVENTS .
    assign
    v-accum = v-accum + 1.
    if ( v-accum modulo 10 ) = 0  then do:
      run waitfram-show in this-procedure  (
                                        substitute("&1&2 обработано &3"  , 'маг':U, buf_shop.obj-code, v-accum)
                                        ).
    end.
    if buf_chk-doc.cli-type = ?
    or buf_chk-doc.cli-code = ?
    or buf_chk-doc.cli-type = '':U
    or buf_chk-doc.cli-code = 0 then do:
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = buf_chk-doc.d-card no-error .
      if available buf_dis-card then do:
        assign
        v-cli-type = buf_dis-card.cli-type
        v-cli-code = buf_dis-card.cli-code
        .
      end.
    end.
    else do:
      assign
      v-cli-type = buf_chk-doc.cli-type
      v-cli-code = buf_chk-doc.cli-code
      .
    end.
    if not (v-cli-type = p-cli-type
            and
            v-cli-code = p-cli-code) then next _chk-doc.
    find first card_dcards no-lock where
              card_dcards.d-card = buf_chk-doc.d-card
          and card_dcards.chk-date = 01/01/1990
          and card_dcards.chk-time = 0
          and card_dcards.obj-type = '':U
          and card_dcards.obj-code = 0
          and card_dcards.gds-code = 0
          and card_dcards.pump = 0
          no-error.
    if not available card_dcards then do:
      create card_dcards.
      assign
      card_dcards.d-card = buf_chk-doc.d-card
      card_dcards.chk-date = 01/01/1990
      card_dcards.chk-time = 0
      card_dcards.obj-type = '':U
      card_dcards.obj-code = 0
      card_dcards.gds-code = 0
      card_dcards.pump = 0
      card_dcards.cli-type = v-cli-type
      card_dcards.cli-code = v-cli-code
      card_dcards.doc-qnty = 0
      .
    end.
    assign
    card_dcards.doc-qnty = card_dcards.doc-qnty +  buf_chk-doc.doc-qnty
    card_dcards.sum-netto = card_dcards.sum-netto +
                            (if v-curr-r-b = 'rubl':U
                               then buf_chk-doc.netto
                               else (if v-base-code = 0
                                     then buf_chk-doc.netto
                                     else (buf_chk-doc.netto * buf_chk-doc.cash-rate))
                               )
    .
    for each buf_chk-gds no-lock where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code,
           first buf_bar-code no-lock where
            buf_bar-code.b-code = buf_chk-gds.b-code:
      v-pump-code = buf_chk-gds.pump.
      find first dcards no-lock where
                dcards.d-card = buf_chk-doc.d-card
            and dcards.chk-date = buf_chk-doc.chk-date
            and dcards.chk-time = buf_chk-doc.chk-time
            and dcards.obj-type = buf_chk-doc.obj-type
            and dcards.obj-code = buf_chk-doc.obj-code
            and dcards.gds-code = buf_bar-code.b-code
            and dcards.pump     = v-pump-code
            no-error.
      if not available dcards then do:
        create dcards.
        assign
        dcards.d-card = buf_chk-doc.d-card
        dcards.chk-date = buf_chk-doc.chk-date
        dcards.chk-time = buf_chk-doc.chk-time
        dcards.obj-type = buf_chk-doc.obj-type
        dcards.obj-code = buf_chk-doc.obj-code
        dcards.gds-code = buf_bar-code.gds-code
        dcards.pump     = v-pump-code
        dcards.cli-type = v-cli-type
        dcards.cli-code = v-cli-code
        dcards.doc-qnty = 0
        .
      end.
      find first pet_dcards no-lock where
                pet_dcards.d-card = '':U
            and pet_dcards.cli-type = p-cli-type
            and pet_dcards.cli-code = p-cli-code
            and pet_dcards.gds-code = buf_bar-code.gds-code
            and pet_dcards.price-real = round(buf_chk-gds.price-base - buf_chk-gds.discnt, 2) no-error.
      if not available pet_dcards then do:
        create pet_dcards.
        assign
        pet_dcards.d-card = '':U
        pet_dcards.chk-date = 01/01/1990
        pet_dcards.chk-time = 0
        pet_Dcards.pump     = 0
        pet_dcards.cli-type = p-cli-type
        pet_dcards.cli-code = p-cli-code
        pet_dcards.gds-code = buf_bar-code.gds-code
        pet_dcards.price-real = round(buf_chk-gds.price-base - buf_chk-gds.discnt, 2)
        pet_dcards.doc-qnty = 0
        .
      end.
      assign
      dcards.price-real = round(buf_chk-gds.price-base - buf_chk-gds.discnt, 2)
      dcards.doc-qnty = dcards.doc-qnty + buf_chk-gds.doc-qnty
      dcards.sum-netto = dcards.sum-netto + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt) *
                                            (if v-curr-r-b = 'rubl':U
                                              then  1
                                              else (if v-base-code = 0
                                                    then 1
                                                    else buf_chk-doc.cash-rate)
                                              )
      pet_dcards.doc-qnty = pet_dcards.doc-qnty + buf_chk-gds.doc-qnty
      pet_dcards.sum-netto = pet_dcards.sum-netto + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt) *
                                            (if v-curr-r-b = 'rubl':U
                                              then  1
                                              else (if v-base-code = 0
                                                    then 1
                                                    else buf_chk-doc.cash-rate)
                                              )
     .
    end.
  END.
END.
run waitfram-hide in this-procedure .
