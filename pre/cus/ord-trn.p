block-level on error undo, throw.
define input  parameter parParentProc   as widget-handle no-undo.
define input  parameter tp-rec as recid no-undo .
define input  parameter p-allow-chain-trn-qnty as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: e470dcf1e011, 295, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 01 19:11:38 2015 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-trn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-trn.p $":U .
define variable vss-description as character no-undo init "Формирование накладной из поставки".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: ord-trn.p $ $Revision: e470dcf1e011, 295, rls $".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure create-chain :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-doc-type as character no-undo .
define input  parameter p-rel-doc-code as character no-undo .
define input  parameter p-rel-doc-type as character no-undo .
define input  parameter p-type as character no-undo .
define input  parameter p-ps as character no-undo .
define variable v-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
  find first ub.sys-ctrl no-lock .
  v-db-num = ub.sys-ctrl.db-num .
  find first ub.ord-chain no-lock where
    ub.ord-chain.doc-code     = p-doc-code     and
    ub.ord-chain.doc-type     = p-doc-type     and
    ub.ord-chain.rel-type     = p-type         and
    ub.ord-chain.rel-doc-code = p-rel-doc-code and
    ub.ord-chain.rel-doc-type = p-rel-doc-type   no-error .
  if available ub.ord-chain then return .
  create ub.ord-chain.
  assign
    ub.ord-chain.doc-code     = p-doc-code
    ub.ord-chain.doc-type     = p-doc-type
    ub.ord-chain.ps           = p-ps
    ub.ord-chain.rel-doc-code = p-rel-doc-code
    ub.ord-chain.rel-doc-type = p-rel-doc-type
    ub.ord-chain.rel-id       = next-value( s-ord-ch, ub )
    ub.ord-chain.db-num       = v-db-num
    ub.ord-chain.rel-type     = p-type
    .
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define temp-table tt-trn-doc  no-undo like ub.trn-doc.
define temp-table tt-doc-line no-undo like ub.doc-line.
define temp-table tt2-doc-line      no-undo like lib-trn_ret-line.
define temp-table tt-doc-line-attr no-undo like ub.doc-line-attr.
define temp-table tt-gds-dtl  no-undo like ub.gds-dtl.
define temp-table tt-parts    no-undo like ub.parts.
define buffer ttt_ord-doc-rcv  for ub.ord-doc-rcv.
define buffer ttt_ord-line-rcv for ub.ord-line-rcv.
define buffer ttt_ord-dtl-rcv  for ub.ord-dtl-rcv.
define buffer bf_ord-chain     for ub.ord-chain.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_doc-line      for ub.doc-line.
define buffer bf_ord-rcv-attr  for ub.ord-rcv-attr.
define buffer new_trn-doc  for ub.trn-doc  .
define buffer new_doc-line for ub.doc-line .
define buffer new_gds-dtl  for ub.gds-dtl .
define buffer t_trn-doc  for ub.trn-doc  .
define buffer t_doc-line for ub.doc-line .
define buffer t_gds-dtl  for ub.gds-dtl .
define buffer t_goods    for ub.goods .
define variable kkk  as integer no-undo .
define variable p-q  like ub.ord-dtl-rcv.qnty no-undo .
define variable v-contract-code as integer no-undo .
define variable v-purch-code as integer   no-undo .
define variable v-purch-code-name as character no-undo .
define variable v-host-code as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable v-price-base as decimal   no-undo init 0.
define variable v-price-cli  as decimal   no-undo init 0.
define variable v-price-rubl as decimal   no-undo init 0.
define variable v-cli-qnty   as decimal   no-undo .
define variable v-doc-qnty   as decimal   no-undo .
define variable v-fact-qnty  as decimal   no-undo .
define variable v-out-pay-str as character no-undo .
define variable v-out-pay-type as character no-undo .
define variable g#cash-pay as integer   no-undo .
define variable g#out-pay as integer   no-undo .
define variable v-base-code as integer   no-undo .
define variable v-ps        as character no-undo .
define variable v-Ok       as logical   no-undo .
define variable v-mess as character no-undo .
define variable v-event-code as character no-undo .
define buffer buf_ord-doc for ub.ord-doc .
define buffer buf_sysconf for ub.sysconf  .
find first  ttt_ord-doc-rcv where recid ( ttt_ord-doc-rcv) = tp-rec no-lock no-error .
  if not avail ttt_ord-doc-rcv then return error.
assign
  store-type    = ttt_ord-doc-rcv.obj-type
  store-code    = ttt_ord-doc-rcv.obj-code
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  ttt_ord-doc-rcv.obj-type
  ,input  ttt_ord-doc-rcv.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  ttt_ord-doc-rcv.obj-type
  ,input  ttt_ord-doc-rcv.obj-code
  ,output to-day
  )  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objatext in g#library
  (input  ttt_ord-doc-rcv.obj-type
  ,input  ttt_ord-doc-rcv.obj-code
  ,input  'out-pay=request'
  ,output v-out-pay-str
  ,output v-out-pay-type
  )  .
find first buf_sysconf where buf_sysconf.host-code = v-host-code no-lock.
assign
  g#cash-pay   = buf_sysconf.cash-pay
  v-base-code  = buf_sysconf.base-code
  g#out-pay    = buf_sysconf.out-pay
.
  assign
    g#out-pay  = integer(v-out-pay-str)
  .
  if ttt_ord-doc-rcv.status_ <> 'поставка':U then do:
     message "Нельзя сделать накладную на поставку в статусе " caps(ttt_ord-doc-rcv.status_) view-as alert-box .
     return.
  end.
define variable v-ord-doc-type as character no-undo .
define variable v-pay-code as integer   no-undo .
define variable v-doc-type  as character no-undo .
define variable v-internal  as logical   no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-discnt-type as character no-undo .
define variable v-status_ as character no-undo .
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = ttt_ord-doc-rcv.doc-code no-error .
  if available buf_ord-doc
     then
      assign
        v-contract-code = buf_ord-doc.contract-code
        v-ord-doc-type  = buf_ord-doc.doc-type
        v-pay-code      = buf_ord-doc.pay-code
      .
     else
     assign
       v-contract-code = 0
       v-ord-doc-type  = ""
       v-pay-code      = 0
     .
if ttt_ord-doc-rcv.doc-type = 'out':U then do:
          if v-ord-doc-type  = 'ПО':U then do:
                assign
                  v-doc-type = 'рас':U
                  v-internal = false
                  v-ext-doc-type   = 'ee':U
                  v-discnt-type    = 'процент':U
                  v-status_ = 'запрос':U
                .
          end.
          else do:
                assign
                  v-doc-type = 'при':U
                  v-internal = false
                  v-ext-doc-type   = 'ie':U
                  v-discnt-type    = ""
                  v-status_ = 'накл':U
                .
          end.
    end.
    else do:
        assign
          v-doc-type = 'рас':U
          v-internal = true
          v-ext-doc-type   = 'ev':U
          v-discnt-type    = 'процент':U
          v-status_ = 'накл':U
        .
    end.
define variable n-d as character no-undo .
  run doc-code in this-procedure
    (input  "main":u,
     input  store-type,
     input  store-code,
     input  ?,
     output n-d ) no-error.
  if error-status:error then do:
    message "Ошибка при генерации номера документа." view-as alert-box.
    return error.
  end.
  define variable v-type-vat as character no-undo .
  v-type-vat =  entry(2,ttt_ord-doc-rcv.sub-par,chr(4)) no-error .
  if v-type-vat = "" or v-type-vat = ? then v-type-vat = 'в т. ч.':U .
  create  tt-trn-doc.
  buffer-copy  ttt_ord-doc-rcv  to    tt-trn-doc
    assign
     tt-trn-doc.pay-code   = if  ( v-pay-code = ? OR v-pay-code = 0  ) then g#out-pay
                                                                       else v-pay-code
     tt-trn-doc.status_    = "temp"
     tt-trn-doc.doc-code   = n-d
     tt-trn-doc.doc-type   = v-doc-type
     tt-trn-doc.internal   = v-internal
     tt-trn-doc.cr-db-num  = g#db-num
     tt-trn-doc.vat-type   = v-type-vat
     tt-trn-doc.slt-type   = 'без':U
     tt-trn-doc.office     = false
     tt-trn-doc.fact-num   = 0
     tt-trn-doc.PS         = "Сформирована по Поставке № " +  ttt_ord-doc-rcv.rcv-code +
                             (if ttt_ord-doc-rcv.doc-code <> "" then " Заказ № " +  ttt_ord-doc-rcv.doc-code  Else "" )
     tt-trn-doc.creid      = g#userid
     tt-trn-doc.flag_      = false
     tt-trn-doc.ext-doc-type   = v-ext-doc-type
     tt-trn-doc.discnt-type    = v-discnt-type
     tt-trn-doc.ret-supp       = false
     tt-trn-doc.contract-code = v-contract-code
     .
     if ttt_ord-doc-rcv.doc-type = 'in':U then do:
     assign tt-trn-doc.obj-code = ttt_ord-doc-rcv.cli-code
            tt-trn-doc.obj-type = ttt_ord-doc-rcv.cli-type
            tt-trn-doc.cli-code = ttt_ord-doc-rcv.obj-code
            tt-trn-doc.cli-type = ttt_ord-doc-rcv.obj-type
            .
     end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  tt-trn-doc.doc-date
  ,output tt-trn-doc.base-rate
  ,output tt-trn-doc.base-scale
  ) no-error .
   if v-contract-code > 0 then do:
    define variable v-purch-code-ch as character no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_purchcon in g#lib-trn3
( input v-host-code
, input v-contract-code
, output v-purch-code-ch
, output v-purch-code-name
) .
    v-purch-code = integer (v-purch-code-ch) .
   end.
   else do:
      if lookup (string(buf_sysconf.purch-code), '1,2,3':U) = 0 then do:
          message "Неверный код типа приобретения по умолчанию. " skip
                  "Допустимые типы: "
          view-as alert-box error.
          return error.
      end.
      v-purch-code = buf_sysconf.purch-code .
   end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input tt-trn-doc.acc-date
,input tt-trn-doc.bge-date
,input tt-trn-doc.base-rate
,input tt-trn-doc.base-scale
,input tt-trn-doc.cli-code
,input tt-trn-doc.cli-type
,input tt-trn-doc.cli-name
,input tt-trn-doc.cr-db-num
,input tt-trn-doc.creid
,input tt-trn-doc.discnt-type
,input tt-trn-doc.doc-code
,input tt-trn-doc.doc-date
,input tt-trn-doc.doc-type
,input tt-trn-doc.flag_
,input tt-trn-doc.host-code
,input tt-trn-doc.internal
,input tt-trn-doc.obj-code
,input tt-trn-doc.obj-type
,input tt-trn-doc.office
,input tt-trn-doc.pay-code
,input tt-trn-doc.ps
,input tt-trn-doc.ret-supp
,input tt-trn-doc.slt-type
,input tt-trn-doc.status_
,input tt-trn-doc.vat-type
,input tt-trn-doc.ext-doc-type
,input v-purch-code
) no-error
.
    .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "str/crtrndoc.i"
      view-as alert-box error
    .
  find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
  if not available new_trn-doc then do:
     message error-status :get-message(1) .
     return.
  end.
  define variable v-print-rubl as logical   no-undo .
  define variable v-curr-r-b as character no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  if v-curr-r-b = 'base':U then v-print-rubl = false .
  else v-print-rubl = true .
  find first bf_ord-rcv-attr no-lock
    where bf_ord-rcv-attr.doc-code = ttt_ord-doc-rcv.doc-code
    and bf_ord-rcv-attr.rcv-code = ttt_ord-doc-rcv.rcv-code
    and bf_ord-rcv-attr.attr-code = 'nids':U
    no-error.
  if available bf_ord-rcv-attr then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input new_trn-doc.doc-code ,
                       input 'nids':U ,
                       input bf_ord-rcv-attr.attr-value ) no-error .
  end.
  find first bf_ord-rcv-attr no-lock
    where bf_ord-rcv-attr.doc-code = ttt_ord-doc-rcv.doc-code
    and bf_ord-rcv-attr.rcv-code = ttt_ord-doc-rcv.rcv-code
    and bf_ord-rcv-attr.attr-code = 'dids':U
    no-error.
  if available bf_ord-rcv-attr then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input new_trn-doc.doc-code ,
                       input 'dids':U ,
                       input bf_ord-rcv-attr.attr-value ) no-error .
  end.
  find first bf_ord-rcv-attr no-lock
    where bf_ord-rcv-attr.doc-code = ttt_ord-doc-rcv.doc-code
    and bf_ord-rcv-attr.rcv-code = ttt_ord-doc-rcv.rcv-code
    and bf_ord-rcv-attr.attr-code = 'invoiceNumber':U
    no-error.
  if available bf_ord-rcv-attr then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input new_trn-doc.doc-code ,
                       input 'nsf':U ,
                       input bf_ord-rcv-attr.attr-value ) no-error .
  end.
  find first bf_ord-rcv-attr no-lock
    where bf_ord-rcv-attr.doc-code = ttt_ord-doc-rcv.doc-code
    and bf_ord-rcv-attr.rcv-code = ttt_ord-doc-rcv.rcv-code
    and bf_ord-rcv-attr.attr-code = 'invoiceDate':U
    no-error.
  if available bf_ord-rcv-attr then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input new_trn-doc.doc-code ,
                       input 'dsf':U ,
                       input bf_ord-rcv-attr.attr-value ) no-error .
  end.
  assign
  new_trn-doc.contract-code  = v-contract-code
  new_trn-doc.exch-rate  = tt-trn-doc.exch-rate
  new_trn-doc.exch-scale = tt-trn-doc.exch-scale
  new_trn-doc.exch-date  = to-day
  new_trn-doc.exch-code  = tt-trn-doc.exch-code
  new_trn-doc.status_    = v-status_
  new_trn-doc.hold-doc-code-child   = "no-hold"
  new_trn-doc.hold-doc-code-parent  = "no-hold"
  new_trn-doc.print-rubl = v-print-rubl
  new_trn-doc.whole-send-news = ttt_ord-doc-rcv.whole-send-news
   .
  for each  ttt_ord-line-rcv no-lock where   ttt_ord-line-rcv.doc-code = ttt_ord-doc-rcv.doc-code and
                                             ttt_ord-line-rcv.rcv-code = ttt_ord-doc-rcv.rcv-code
                                             by ttt_ord-line-rcv.line-num
                                             :
      find first t_goods where t_goods.artic     = ttt_ord-line-rcv.artic and
                               t_goods.prod-type = ttt_ord-line-rcv.prod-type and
                               t_goods.prod-code = ttt_ord-line-rcv.prod-code no-lock no-error .
      if error-status :error then do:
         message error-status :get-message(1) .
         next.
      end.
      if ttt_ord-line-rcv.qnty = 0 then do:
          v-ps = v-ps + substitute(" Кол-во=0 артикул:&1," , t_goods.artic ) .
          next.
      end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  tt-trn-doc.obj-type
  ,input  tt-trn-doc.obj-code
  ,input  ttt_ord-line-rcv.artic
  ,input  ttt_ord-line-rcv.prod-type
  ,input  ttt_ord-line-rcv.prod-code
  ,buffer ub.gds-obj
  ) no-error .
  if error-status :error then
  message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "gbl/gdsobjcr.i"
    view-as alert-box error
  .
  find first ub.gds-obj no-lock where
        ub.gds-obj.obj-type  = tt-trn-doc.obj-type   and
        ub.gds-obj.obj-code  = tt-trn-doc.obj-code   and
        ub.gds-obj.artic     = ttt_ord-line-rcv.artic     and
        ub.gds-obj.prod-type = ttt_ord-line-rcv.prod-type and
        ub.gds-obj.prod-code = ttt_ord-line-rcv.prod-code .
        v-event-code = tt-trn-doc.ext-doc-type .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  t_goods.gds-code
  ,input  tt-trn-doc.obj-type
  ,input  tt-trn-doc.obj-code
  ,input  false
  ,output v-Ok
  ,output v-mess
  ) no-error.
       if v-Ok = false then do:
          v-ps = v-ps + v-mess.
          next.
       end.
    if  ttt_ord-line-rcv.price-rubl  = 0 or ttt_ord-line-rcv.price-rubl  = ? then do:
        assign
         v-price-base  =  ub.gds-obj.last-base
         v-price-rubl  =  ub.gds-obj.last-rubl
        .
    end.
    else do:
        assign
         v-price-base  =   ttt_ord-line-rcv.price-base
         v-price-cli   =   ttt_ord-line-rcv.price-cli
         v-price-rubl  =   ttt_ord-line-rcv.price-rubl
        .
    end.
    assign
      v-cli-qnty  = 0
      v-doc-qnty  = 0
      v-fact-qnty = 0
    .
    if  p-allow-chain-trn-qnty then do:
       for each bf_ord-chain
          where bf_ord-chain.doc-code = ttt_ord-doc-rcv.rcv-code
            and bf_ord-chain.doc-type = "rcv":U
            no-lock :
            find first bf_trn-doc
                 where bf_trn-doc.doc-code = bf_ord-chain.rel-doc-code
            no-error.
            if available bf_trn-doc then do:
              find first bf_doc-line
                   where bf_doc-line.artic     = ttt_ord-line-rcv.artic
                     and bf_doc-line.prod-code = ttt_ord-line-rcv.prod-code
                     and bf_doc-line.prod-type = ttt_ord-line-rcv.prod-type
                     and bf_doc-line.doc-code  = bf_trn-doc.doc-code
                     no-error.
              if available bf_doc-line then do:
                 assign
                   v-cli-qnty    = v-cli-qnty   + bf_doc-line.cli-qnty
                   v-doc-qnty    = v-doc-qnty   + bf_doc-line.doc-qnty
                   v-fact-qnty   = v-fact-qnty  + bf_doc-line.fact-qnty
                 .
              end.
            end.
       end.
    end.
      create  tt-doc-line  .
        assign
          tt-doc-line.doc-code       = n-d
          tt-doc-line.status_        = "temp"
          tt-doc-line.obj-code       = tt-trn-doc.obj-code
          tt-doc-line.obj-type       = tt-trn-doc.obj-type
          tt-doc-line.slt-pc         = ttt_ord-line-rcv.slt-pc
          tt-doc-line.vat-pc         = ttt_ord-line-rcv.vat-pc
          tt-doc-line.cli-base-rate  = ttt_ord-line-rcv.cli-base-rate
          tt-doc-line.cli-qnty       = if v-cli-qnty  >= ttt_ord-line-rcv.cli-qnty  then 0 else ( ttt_ord-line-rcv.cli-qnty - v-cli-qnty )
          tt-doc-line.doc-qnty       = if v-doc-qnty  >= ttt_ord-line-rcv.qnty      then 0 else ( ttt_ord-line-rcv.qnty     - v-doc-qnty )
          tt-doc-line.fact-qnty      = if v-fact-qnty >= ttt_ord-line-rcv.qnty      then 0 else ( ttt_ord-line-rcv.qnty     - v-fact-qnty )
          tt-doc-line.excise         = ttt_ord-line-rcv.excise
          tt-doc-line.ext-doc-type   = v-ext-doc-type
          tt-doc-line.line-num       = next-value (s-line-num, ub)
          tt-doc-line.other-base     = ttt_ord-line-rcv.other-base
          tt-doc-line.other-rubl     = ttt_ord-line-rcv.other-rubl
          tt-doc-line.price-base     = v-price-base
          tt-doc-line.price-cli      = v-price-cli
          tt-doc-line.price-rubl     = v-price-rubl
          tt-doc-line.artic          = ttt_ord-line-rcv.artic
          tt-doc-line.prod-code      = ttt_ord-line-rcv.prod-code
          tt-doc-line.prod-type      = ttt_ord-line-rcv.prod-type
          tt-doc-line.prt-root       = t_goods.prt-root
          tt-doc-line.road-tax       = ttt_ord-line-rcv.road-tax
          tt-doc-line.transport-base = ttt_ord-line-rcv.transport-base
          tt-doc-line.transport-rubl = ttt_ord-line-rcv.transport-rubl
          tt-doc-line.unit-cli       = ttt_ord-line-rcv.unit-cli
          tt-doc-line.doc-density     = 1 / tt-doc-line.cli-base-rate
          tt-doc-line.fact-density    = 1 / tt-doc-line.cli-base-rate
          .
          create  tt2-doc-line .
          BUFFER-COPY tt-doc-line to tt2-doc-line.
p-q = 0 .
kkk = 0 .
     kkk = 0 .
     for each   ttt_ord-dtl-rcv where
                ttt_ord-doc-rcv.rcv-code   = ttt_ord-dtl-rcv.rcv-code   and
                ttt_ord-doc-rcv.doc-code   = ttt_ord-dtl-rcv.doc-code   and
                ttt_ord-line-rcv.artic     = ttt_ord-dtl-rcv.artic      and
                ttt_ord-line-rcv.prod-code = ttt_ord-dtl-rcv.prod-code  and
                ttt_ord-line-rcv.prod-type = ttt_ord-dtl-rcv.prod-type  :
      kkk = kkk + 1 .
      create tt-gds-dtl .
      buffer-copy  tt-doc-line to  tt-gds-dtl.
      assign
        tt-gds-dtl.fact-qnty =  ttt_ord-dtl-rcv.qnty
        tt-gds-dtl.doc-qnty  =  ttt_ord-dtl-rcv.qnty
        tt-gds-dtl.prt-code  =  ttt_ord-dtl-rcv.node-code
        p-q = ttt_ord-dtl-rcv.qnty
      .
     end.
     if kkk = 0 then do:
          create tt-gds-dtl.
          buffer-copy  tt-doc-line  to  tt-gds-dtl.
          assign
            tt-gds-dtl.prt-code  =  tt-doc-line.prt-root
            p-q = tt-doc-line.doc-qnty
          .
      end.
      if p-q <> tt-doc-line.doc-qnty then
         message "В поставке :"  ttt_ord-doc-rcv.rcv-code skip
                 "по товару :"
                 tt-doc-line.artic
                 tt-doc-line.prod-type
                 tt-doc-line.prod-code
                "По признакам разнесено только :"  p-q skip
                "Надо разнести еще :" ( tt-doc-line.doc-qnty  -  p-q ) skip
                "Исправьте данные по признакам в накладной " view-as alert-box .
end.
for each tt2-doc-line :
    create tt-parts.
    BUFFER-COPY tt2-doc-line except  tt2-doc-line.status_  TO tt-parts   .
      assign
        tt-parts.prod-type      = tt2-doc-line.prod-type
        tt-parts.prod-code      = tt2-doc-line.prod-code
        tt-parts.artic          = tt2-doc-line.artic
        tt-parts.in-code        = new_trn-doc.doc-code
        tt-parts.out-code       = new_trn-doc.doc-code
        tt-parts.price-base     = tt2-doc-line.price-cli / new_trn-doc.base-rate * new_trn-doc.base-scale
        tt-parts.price-rubl     = tt2-doc-line.price-cli
        tt-parts.qnty           = tt2-doc-line.doc-qnty
        tt-parts.obj-type       = new_trn-doc.obj-type
        tt-parts.obj-code       = new_trn-doc.obj-code
        tt-parts.fact-date      = new_trn-doc.fact-date
        tt-parts.fact-num       = new_trn-doc.fact-num
        tt-parts.VAT-pc         = tt2-doc-line.vat-pc
        tt-parts.part-code      = ""
        tt-parts.PS             = "Партия создана по заказу"
        tt-parts.pay-code       = new_trn-doc.pay-code
        tt-parts.status_        = no
        tt-parts.fact-qnty      = tt2-doc-line.fact-qnty
        tt-parts.supp-type      = new_trn-doc.cli-type
        tt-parts.supp-code      = new_trn-doc.cli-code
        tt-parts.rsrv-free      = ?
        tt-parts.doc-type       = new_trn-doc.doc-type
        tt-parts.cli-qnty       = tt2-doc-line.cli-qnty
        tt-parts.pl-code        = 0
        tt-parts.VAT-type       = new_trn-doc.vat-type
        tt-parts.exch-code      = 0
        tt-parts.price-cli      = tt2-doc-line.price-cli
        tt-parts.cli-base-rate  = tt2-doc-line.cli-base-rate
        tt-parts.SLT-pc         = 0
        tt-parts.host-code      = new_trn-doc.host-code
        tt-parts.is-supp        = yes
        tt-parts.SLT-type       = 'без':U
        tt-parts.cst-code       = ""
        tt-parts.last-date      = ?
        tt-parts.road-tax-base  = 0
        tt-parts.road-tax-rubl  = 0
        tt-parts.transport-base = 0
        tt-parts.transport-rubl = 0
        tt-parts.other-base     = 0
        tt-parts.other-rubl     = 0
        tt-parts.purch-code     = new_trn-doc.purch-code
        tt-parts.contract-code  = new_trn-doc.contract-code
      no-error.
define buffer buf_pl-gds for ub.pl-gds  .
define variable is-petrolium as logical   no-undo .
define variable is-pieces    as logical   no-undo .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input tt-parts.artic
  ,  input tt-parts.prod-type
  ,  input tt-parts.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
if is-petrolium then do:
 find first t_goods where t_goods.artic     = tt-parts.artic and
                          t_goods.prod-type = tt-parts.prod-type and
                          t_goods.prod-code = tt-parts.prod-code no-lock no-error .
find first buf_pl-gds no-lock where
      buf_pl-gds.obj-code =  tt-parts.obj-code and
      buf_pl-gds.obj-type =  tt-parts.obj-type and
      buf_pl-gds.gds-code =  t_goods.gds-code no-error .
     if available buf_pl-gds then do:
       assign
        tt-parts.pl-code   = buf_pl-gds.pl-code
        tt-parts.part-code = string(buf_pl-gds.pl-code)
       .
     end.
end.
end.
if ttt_ord-doc-rcv.doc-type = 'out':U and v-ord-doc-type <> 'ПО':U  then do:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_copy-in in g#lib-trn4
( input parParentProc
 ,input recid(new_trn-doc)
 ,input table tt-trn-doc
 ,input table tt2-doc-line
 ,input table tt-doc-line-attr
 ,input table tt-gds-dtl
 ,input table tt-parts
 ,input yes
 ,input yes
 ,input no
 ,input yes
 ,input this-procedure
  ) no-error .
    if error-status:error then do :
        message "Не удалось добавить товар в приходную накладную !"
          skip "Ошибка из copy-in.i "
          skip error-status :get-message(1)
          skip return-value
        view-as alert-box error buttons ok.
        return error.
    end.
end.
if ttt_ord-doc-rcv.doc-type = 'in':U or v-ord-doc-type = 'ПО':U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-ret in g#lib-trn
  (
    input parParentProc
  , input new_trn-doc.doc-code
  , input new_trn-doc.doc-type
  , input new_trn-doc.status_
  , input new_trn-doc.internal
  , input new_trn-doc.cli-type
  , input new_trn-doc.cli-code
  , input new_trn-doc.discnt-type
  , input new_trn-doc.tot-calc
  , input new_trn-doc.discnt-pc
  , input new_trn-doc.agnt
  , input new_trn-doc.boss
  , input new_trn-doc.wrkr
  , input new_trn-doc.base-rate
  , input new_trn-doc.base-scale
  , input new_trn-doc.exch-code
  , input new_trn-doc.vat-type
  , input new_trn-doc.doc-code
  , input no
  , input ?
  , input ?
  , input ?
  , input ?
  , input ?
  , input ?
  , input g#cash-pay
  , input v-base-code
  , input-output table tt2-doc-line
  , input-output table tt-gds-dtl
  , input-output table tt-parts
  , input no
  , input yes
  , input ( if v-ord-doc-type = 'ПО':U then true else false )
  , input yes
  ) no-error.
  if error-status:error then do :
      message "Не удалось добавить товар во внутреннюю расходную накладную !"
      skip "Ошибка из copy-ret.i "
      skip error-status :get-message(1)
      skip return-value
      view-as alert-box error buttons ok.
      return error.
  end.
  run gbl/calc-trn.p ( input parparentproc, input recid(new_trn-doc)) no-error.
end.
if LENGTH(new_trn-doc.Ps) < 31900 then do:
   new_trn-doc.Ps = new_trn-doc.Ps + chr(10) + V-ps.
end.
run create-chain in this-procedure
  ( ttt_ord-doc-rcv.rcv-code
  ,'rcv'
  ,new_trn-doc.doc-code
  ,'trn'
  ,''
  ,''
  ) .
