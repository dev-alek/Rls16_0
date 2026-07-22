block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER test-number as integer.
DEFINE INPUT PARAMETER my-inkas as char.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-where-phrase as character no-undo .
define input parameter parscales-pref as character no-undo .
define input parameter parpgscales-pref as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: testq00.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/testq00.p $":U .
define variable vss-description as character no-undo init "Компилируемый ран-тайм модуль тестов по чекам".
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
define new global shared variable g#libbcrcn as handle no-undo .
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
define SHARED var ff as decimal.
define SHARED var gg as decimal.
DEFine SHARED VAR accum1 as decimal.
DEFINE VARIABLE bc-buf as char no-undo.
DEFINE VARIABLE b-c like ub.bar-code.b-code no-undo.
DEFINE VARIABLE flag as logical.
DEFINE VARIABLE price-from-check like ub.chk-gds.price-base no-undo .
DEFINE VARIABLE r-bar-code like ub.bar-code.b-code no-undo .
define variable varresult   as character         no-undo.
define variable vartype-bc  as character         no-undo.
define variable varweight   as decimal           no-undo.
DEFINE VARIABLE v-err       as logical           no-undo .
define buffer for-gds for ub.chk-gds.
DEFINE SHARED STREAM PrnLibStream.
define variable v-curr-r-b as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
define query testqi for ub.inkas, ub.chk-doc.
define query testqc for ub.chk-doc.
define variable v-qh as handle no-undo .
define variable glog as logical no-undo .
if my-inkas = "ALL" then do:
  v-qh = query testqi:handle.
end.
else do:
  v-qh = query testqc:handle.
end.
assign
glog = v-qh:query-prepare(p-where-phrase) no-error.
if error-status:error then do:
  message error-status:get-message(1)
  view-as alert-box error .
  undo, return error .
end.
assign
glog = v-qh:query-open( ) no-error .
if error-status:error then do:
  message error-status:get-message(1)
  view-as alert-box error .
  undo, return error .
end.
REPEAT :
  v-qh:GET-NEXT().
  IF v-qh:QUERY-OFF-END THEN LEAVE.
  if chk-doc.chk-type = integer('8':U) then next.
  if lookup(string(chk-doc.chk-type), '2,3,4,5,7':U) > 0  then next.
  if my-inkas = "ALL" then do:
    my-inkas = inkas.inkas-code.
  end.
  run waitfram-show in this-procedure ( input substitute("Ждите - идет обработка -  чек &1",chk-doc.doc-code)).
  CASE test-number:
    WHEN 1 then do:
      FOR EACH ub.chk-gds no-lock where ub.chk-gds.doc-code = ub.CHK-DOC.doc-code :
        flag = no.
        IF chk-gds.b-code = ? or chk-gds.b-code <= 0 THEN FLAG = YES.
        else do:
          assign
          price-from-check = chk-gds.price-base
          bc-buf = string(chk-gds.b-code)
          .
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parparentproc
,input  bc-buf
,input  price-from-check
,input  chk-doc.obj-type
,input  chk-doc.obj-code
,input  yes
,input  no
,input  parscales-pref
,input  parpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer ub.bar-code
,buffer ub.prod-bc
,buffer ub.place
) no-error.
          if error-status:error then do:
            release bar-code.
          end.
          if avail bar-code then do:
            v-err = no.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bar-code.gds-code
  ,input  bar-code.node-code
  ,output r-bar-code
  ) no-error .
            if error-status:error then v-err = yes.
            if v-err then  do:
              assign
              b-c = ?
              flag = yes
              .
            end.
            else do:
              if bar-code.in-code = "":U and bar-code.part-code = "":U then do:
                assign
                b-c = r-bar-code
                .
              end.
              else do:
                v-err = no.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdspcode in g#library
  (input  bar-code.gds-code
  ,input  bar-code.node-code
  ,input  bar-code.in-code
  ,input  bar-code.part-code
  ,output r-bar-code
  ) no-error .
                if error-status:error then v-err = yes.
                assign
                b-c = (if v-err
                       then ?
                       else r-bar-code)
                flag = (if v-err
                       then yes
                       else flag)
                .
              end.
            end.
          end.
          else do:
            assign
            b-c = ?
            flag = yes
            .
          end.
        end.
        if chk-gds.out-code <> chk-doc.out-code then flag = yes.
        if flag then do:
           PUT STREAM PrnLibStream UNFORMATTED
            chk-gds.doc-code FORMAT "X(20)"  space(1)
            CHK-DOC.pay-desk format "99999" space(1)
            CHK-DOC.chk-num format "-99999" space(1)
            if chk-gds.b-code = ? then "?" else string(chk-gds.b-code, "-9999999999") space(1)
            string(chk-gds.out-code <> chk-doc.out-code, "да/нет")
            SKIP
            .
        end.
    end.
    END.
    WHEN 2 then do:
        ff = 0.
        gg = 0.
        flag = no.
        if lookup(string(chk-doc.chk-type), '14,15,16,17,36':U) > 0 then next.
        for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-lock:
            if ub.chk-gds.write-off-code <> ? and ub.chk-gds.write-off-code > 0 then next.
            ff = ff + ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - chk-gds.discnt).
            flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) OR flag.
        end.
         for each ub.chk-pay where ub.chk-pay.doc-code = ub.chk-doc.doc-code no-lock:
            gg = gg +  ub.chk-pay.tot-rubl.
            flag = (ub.chk-pay.out-code <> ub.chk-doc.out-code) OR flag.
        end.
        if abs(ff - gg) > 0.0000000002 or flag then do:
            put stream PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code  format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ff   format "-999,999.9999999999" space(1)
            gg format "-999,999.9999999999" space(1)
            (ff - gg) format "-999,999.9999999999" space(1)
            flag
            skip.
        accum1 = accum1 + (ff - gg) .
        end.
    END.
    WHEN 3 then do:
        ff = 0.
        gg = 0.
        flag = no.
        if lookup(string(ub.chk-doc.chk-type), '14,15,16,17,36':U) > 0 then next.
         for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-lock:
           if ub.chk-gds.write-off-code <> ? and ub.chk-gds.write-off-code > 0 then next.
            ff = ff + ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt).
            flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) or flag.
        end.
         for each ub.chk-pay where ub.chk-pay.doc-code = ub.chk-doc.doc-code no-lock:
            gg = gg +  ub.chk-pay.tot-base.
            flag = (ub.chk-pay.out-code <> ub.chk-doc.out-code) or flag.
        end.
        if abs(ff - gg) > 0.0000000002 or flag then do:
            put stream PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code  format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ff   format "-999,999.9999999999" space(1)
            gg format "-999,999.9999999999" space(1)
            (ff - gg) format "-999,999.9999999999" space(1)
            flag
            skip.
        accum1 = accum1 + (ff - gg) .
        end.
    END.
    WHEN 4 then do:
        ff = 0.
        flag = no.
        for each ub.chk-pay No-LOCK WHERE ub.chk-pay.doc-code = ub.chk-doc.doc-code:
            ff = ff + ub.chk-pay.tot-rubl .
            flag = (ub.chk-pay.out-code <> ub.chk-doc.out-code) or flag.
        end.
        if abs(ff - ub.chk-doc.netto)  > 0.0000000002 or flag then do:
            PUT STREAM PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code  format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ub.chk-doc.netto format "-999,999.9999999999" space(1)
            ff   format "-999,999.9999999999" space(1)
            (ff - ub.chk-doc.netto) format "-999,999.9999999999" space(1)
            flag
            SKIP.
            accum1 = accum1 + (ff - ub.chk-doc.netto).
        end.
    END.
    WHEN 5 then do:
        ff = 0.
        flag = no.
        for each ub.chk-pay NO-LOCK WHERE ub.chk-pay.doc-code = chk-doc.doc-code :
            ff = ff + ub.chk-pay.tot-base .
            flag = (ub.chk-pay.out-code <> chk-doc.out-code) or flag.
        end.
        if abs(ff - chk-doc.netto)  > 0.0000000002 or flag then do:
            PUT STREAM PrnLibStream UNFORMATTED
            chk-doc.doc-code  format "X(20)" space(1)
            chk-doc.pay-desk format "99999" space(1)
            chk-doc.chk-num format "-99999" space(1)
            chk-doc.netto format "-999,999.9999999999" space(1)
            ff   format "-999,999.9999999999" space(1)
            (ff - chk-doc.netto) format "-999,999.9999999999" space(1)
            flag
            SKIP.
            accum1 = accum1 + (ff - chk-doc.netto).
        end.
    END.
    WHEN 6 then do:
        flag = no.
        for each ub.chk-pay NO-LOCK WHERE ub.chk-pay.doc-code = chk-doc.doc-code :
            flag = ub.chk-pay.out-code <> chk-doc.out-code.
            FIND FIRST ub.cash-pay NO-LOCK WHERE
                                ub.cash-pay.cdpay-code = ub.chk-pay.pay-code AND
                                ub.cash-pay.curr-code = ub.chk-pay.curr-code No-ERROR.
            if not avail ub.cash-pay or flag then do:
                PUT STREAM PrnLibStream UNFORMATTED
                ub.chk-doc.doc-code  format "X(20)" space(1)
                ub.chk-doc.pay-desk format "99999" space(1)
                ub.chk-doc.chk-num format "-99999" space(1)
                (if v-curr-r-b = 'base':U
                then ub.chk-pay.tot-base
                else ub.chk-pay.tot-rubl)  format "-999,999.9999999999" space(1)
                (if not avail cash-pay
                then ("+" + fill(" ", 29) + fill(" ", 29) + fill(" ", 25)
                        )
                else (fill(" ", 30) +
                        string(ub.chk-pay.curr-code, "99999") + fill(" ", 24) +
                        string(cash-pay.curr-code, "99999") + fill(" ", 20)
                        )
                )
                " "
                flag
                SKIP.
            end.
        end.
    END.
    WHEN 7 then do:
        assign
        ff = 0
        gg= 0
        flag = no
        .
        for each ub.chk-pay NO-LOCK WHERE ub.chk-pay.doc-code = ub.chk-doc.doc-code :
            assign
            ff = ff + ub.chk-pay.tot-rubl
            gg = gg + ub.chk-pay.tot-base
            flag = (ub.chk-pay.out-code <> ub.chk-doc.out-code) or flag
            .
        end.
        if abs(ff - gg)  > 0.0000000002 or flag then do:
            PUT STREAM PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code  format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ub.chk-doc.netto format "-999,999.9999999999" space(1)
            ff   format "-999,999.9999999999" space(1)
            (ff - gg) format "-999,999.9999999999" space(1)
            flag
            SKIP.
            accum1 = accum1 + (ff - gg) .
        end.
    end.
    WHEN 8 then do:
        assign
        ff = 0
        gg= 0
        flag = no
        .
        for each ub.chk-gds NO-LOCK WHERE ub.chk-gds.doc-code = ub.chk-doc.doc-code :
          if ub.chk-gds.write-off-code <> ?
          and ub.chk-gds.write-off-code > 0 then next.
          assign
          ff = ff + ub.chk-gds.discnt * ub.chk-gds.doc-qnty
          flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) or flag
          .
        end.
        gg = ub.chk-doc.discnt.
        if abs(ff - gg)  > 0.0000000002 or flag then do:
            PUT STREAM PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code  format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ff   format "-999,999.9999999999" space(1)
            gg format "-999,999.9999999999" space(1)
            (ff - gg) format "-999,999.9999999999" space(1)
            flag
            SKIP.
            accum1 = accum1 + (ff - gg) .
        end.
    end.
    WHEN 9 then do:
        if abs(ub.chk-doc.netto - (ub.chk-doc.tot-doc - ub.chk-doc.discnt )
               ) > 0.0000000002  then do:
            put stream PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ub.chk-doc.tot-doc format "-999,999.9999999999" space(1)
            ub.chk-doc.discnt format "-999,999.9999999999" space(1)
            ub.chk-doc.netto format "-999,999.9999999999" space(1)
            ub.chk-doc.tot-doc - ub.chk-doc.discnt  format "-999,999.9999999999" space(1)
            ub.chk-doc.netto - (ub.chk-doc.tot-doc - ub.chk-doc.discnt)  format "-999,999.9999999999" space(1)
           skip.
            accum1 = accum1 +  (ub.chk-doc.netto - (ub.chk-doc.tot-doc - ub.chk-doc.discnt)).
        end.
    END.
    WHEN 10 then do:
        assign
        ff = 0
        flag = no.
        if lookup(string(ub.chk-doc.chk-type), '14,15,16,17,36':U) > 0 then next.
        for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-lock:
            if ub.chk-gds.write-off-code <> ? and ub.chk-gds.write-off-code > 0 then next.
            assign
            flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) or flag
            ff = ff +  ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt) .
        end.
        if abs(ff - ub.chk-doc.netto) > 0.0000000002  or flag then do:
            put stream PrnLibStream UNFORMATTED
            ub.chk-doc.doc-code format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ff format "-999,999.9999999999" space(1)
            ub.chk-doc.netto  format "-999,999.9999999999" space(1)
            (ff - ub.chk-doc.netto)  format "-999,999.9999999999" space(1)
            flag
            skip.
            accum1 = accum1 + (ff - ub.chk-doc.netto).
        end.
    END.
    WHEN 11 then do:
        assign
        ff = 0
        flag = no.
        if lookup(string(ub.chk-doc.chk-type), '14,15,16,17,36':U) > 0 then next.
         for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-lock:
            if ub.chk-gds.write-off-code <> ? and ub.chk-gds.write-off-code > 0 then next.
            assign
            flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) or flag
            ff = ff +  ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt)
            .
        end.
        if abs(ff - (ub.chk-doc.tot-doc - ub.chk-doc.discnt)) > 0.0000000002  or flag then do:
            put stream PrnLibStream  UNFORMATTED
            ub.chk-doc.doc-code format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ub.chk-doc.tot-doc format "-999,999.9999999999" space(1)
            ub.chk-doc.discnt format "-999,999.9999999999" space(1)
            ub.chk-doc.sub-discnt format "-999,999.9999999999" space(1)
            ff format "-999,999.9999999999" space(1)
            ub.chk-doc.tot-doc - ub.chk-doc.discnt  format "-999,999.9999999999" space(1)
            ff - (ub.chk-doc.tot-doc - ub.chk-doc.discnt)  format "-999,999.9999999999" space(1)
            flag
            skip.
            accum1 = accum1 + (ff - (ub.chk-doc.tot-doc - ub.chk-doc.discnt)).
        end.
    END.
    WHEN 12 then do:
        flag = no.
        if ub.chk-doc.netto >= 0 and can-find(FIRST ub.chk-gds where ub.chk-gds.doc-qnty < 0 and
                                                                        ub.chk-gds.doc-code = ub.chk-doc.doc-code) then do:
            for each ub.chk-gds where ub.chk-gds.doc-qnty < 0 AND ub.chk-gds.doc-code = ub.chk-doc.doc-code NO-LOCK:
                flag = ub.chk-gds.out-code <> ub.chk-doc.out-code.
                FIND FIRST for-gds where for-gds.b-code = ub.chk-gds.b-code AND for-gds.doc-qnty > 0
                AND for-gds.doc-code = ub.chk-gds.doc-code NO-LOCK NO-ERROR.
                if avail for-gds and for-gds.price-base <> ub.chk-gds.price-base or flag then do:
                    PUT stream PrnLibStream UNFORMATTED
                    ub.chk-gds.doc-code FORMAT "X(20)"  space(1)
                    ub.chk-doc.pay-desk format "99999" space(1)
                    ub.chk-doc.chk-num format "-99999" space(1)
                    ub.chk-gds.b-code format "-9999999999"
                    ub.chk-gds.price-base format "-999,999,999.999"
                    for-gds.price-base format "-999,999,999.999"
                    (ub.chk-gds.price-base - for-gds.price-base) * ub.chk-gds.doc-qnty format "-999,999.9999999999" space(1)
                    flag
                    skip.
                    accum1 = accum1 +  (ub.chk-gds.price-base - for-gds.price-base) * ub.chk-gds.doc-qnty.
                end.
          end.
        end.
        if ub.chk-doc.netto < 0 and can-find(FIRST ub.chk-gds where ub.chk-gds.doc-qnty > 0 and
                                                                    ub.chk-gds.doc-code = ub.chk-doc.doc-code) then do:
            FOR EACH ub.chk-gds where ub.chk-gds.doc-qnty > 0 AND ub.chk-gds.doc-code = ub.chk-doc.doc-code NO-LOck:
                flag = ub.chk-gds.out-code <> ub.chk-doc.out-code.
                FIND FIRST for-gds where for-gds.b-code = ub.chk-gds.b-code and for-gds.doc-qnty < 0
                AND for-gds.doc-code = ub.chk-gds.doc-code  NO-LOCK NO-ERROR.
                if avail for-gds and for-gds.price-base <> ub.chk-gds.price-base or flag then do:
                    PUT stream PrnLibStream UNFORMATTED
                    ub.chk-gds.doc-code FORMAT "X(20)"  space(1)
                    ub.chk-doc.pay-desk format "99999" space(1)
                    ub.chk-doc.chk-num format "-99999" space(1)
                    ub.chk-gds.b-code format "-9999999999"
                    ub.chk-gds.price-base format "-999,999,999.999"
                    for-gds.price-base format "-999,999,999.999"
                    (ub.chk-gds.price-base - for-gds.price-base) * ub.chk-gds.doc-qnty   format "-999,999.9999999999" space(1)
                    flag
                    skip.
                    accum1 = accum1 +  (ub.chk-gds.price-base - for-gds.price-base) * ub.chk-gds.doc-qnty  .
                end.
            end.
        end.
    END.
    when 13 then do:
        assign
        ff = 0
        flag = no.
        if lookup(string(ub.chk-doc.chk-type), '14,15,16,17,36':U) > 0 then next.
         for each ub.chk-gds where ub.chk-gds.doc-code = ub.chk-doc.doc-code no-lock:
          if ub.chk-gds.write-off-code <> ? and ub.chk-gds.write-off-code <> 0 then do:
            assign
            flag = (ub.chk-gds.out-code <> ub.chk-doc.out-code) or flag
            ff = ff +  ub.chk-gds.doc-qnty * ub.chk-gds.price-base  * (if ub.chk-gds.write-off-code > 0 then 1 else - 1)
            .
          end.
        end.
        if abs(ub.chk-doc.sub-discnt - ff ) > 0.0000000002  or flag then do:
            put stream PrnLibStream  UNFORMATTED
            ub.chk-doc.doc-code format "X(20)" space(1)
            ub.chk-doc.pay-desk format "99999" space(1)
            ub.chk-doc.chk-num format "-99999" space(1)
            ub.chk-doc.sub-discnt format "-999,999.9999999999" space(1)
            ff format "-999,999.9999999999" space(1)
            ub.chk-doc.sub-discnt - ff format "-999,999.9999999999" space(1)
            flag
            skip.
            accum1 = accum1 + (ub.chk-doc.sub-discnt - ff).
        end.
    end.
    when 14 then do:
      assign
      ff = 0
      .
      if lookup(string(ub.chk-doc.chk-type), '14,15,16,17,36':U) > 0
      or ub.chk-doc.chk-type = integer('8':U)
      then next.
      for each ub.chk-discnt no-lock where
              ub.chk-discnt.doc-code = ub.chk-doc.doc-code
          AND ub.chk-discnt.record-type = 2,
          first ub.chk-gds no-lock where
              ub.chk-gds.doc-code = ub.chk-doc.doc-code
          AND ub.chk-gds.line-num = ub.chk-discnt.object-line-num:
        assign
        ff = ff +  ub.chk-discnt.discnt-value-abs
        accum1 = accum1 + ub.chk-discnt.discnt-value-abs
        .
        put stream PrnLibStream  UNFORMATTED
        ub.chk-doc.doc-code   format "X(20)"           space(1)
        ub.chk-doc.chk-date   format "99/99/9999"      space(1)
        ub.chk-doc.out-code   format "X(20)"           space(1)
        ub.chk-doc.pay-desk   format "99999"           space(1)
        ub.chk-doc.chk-num    format "-99999"          space(1)
        ub.chk-gds.line-num   format "-99999"          space(1)
        ub.chk-gds.b-code     format "999999999"       space(1)
        ub.chk-gds.price-base format "-999,999,999.99" space(1)
        ub.chk-gds.doc-qnty   FORMAT "-999,999.99"     space(1)
        ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt) format "-999,999,999.999999999"  space(1)
        ub.chk-discnt.discnt-value-abs format "-999,999,999.999999999"  space(1)
        ub.chk-gds.doc-qnty * (ub.chk-gds.price-base - ub.chk-gds.discnt + ub.chk-discnt.discnt-value-abs) * ub.chk-discnt.discnt-value-pcnt / 100 format "-999,999,999.999999999"
        skip.
      end.
      if ff <> 0 then
      put stream PrnLibStream  UNFORMATTED
      "Итого по чеку"  space(1)
      ff format "-999,999,999.999999999"
      skip(1).
    end.
  END CASE.
  run waitfram-hide in this-procedure .
END.
