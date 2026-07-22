block-level on error undo, throw.
using ibs.th.str.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
define input  parameter parparentproc   as   widget-handle       no-undo.
define input  parameter parparenthandle as   handle              no-undo.
define input  parameter parmode         as   character           no-undo.
define input  parameter pardoc-code     like ub.trn-doc.doc-code no-undo.
define input  parameter parcheck-return as   logical             no-undo.
define input  parameter pardb-num       like ub.db.db-num        no-undo.
define input  parameter parin-ov        as   logical             no-undo.
define input  parameter parrsrv-time    as   integer             no-undo.
define input  parameter parload-time    as   integer             no-undo.
define input  parameter parholidays     as   character           no-undo.
define input  parameter parmessage      as   logical             no-undo.
define output parameter parchg-inv      as   logical             no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Изменение статуса складского документа":U .
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
    assign
      p-vss-parameters = substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5':u,parparentproc,parmode,pardoc-code,parcheck-return,pardb-num),substitute('&1|&2|&3|&4|&5':u,parin-ov,parrsrv-time,parload-time,parholidays,parmessage) )
    .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define temp-table tt-allsum-line      no-undo
field sum-type           as   character
field fact-qnty          like ub.doc-line.fact-qnty
field cli-qnty           like ub.doc-line.cli-qnty
field sum-dsc-base-doc   like ub.doc-line.price-base
field sum-dsc-rubl-doc   like ub.doc-line.price-base
field dsc-base-doc       like ub.doc-line.price-base
field dsc-rubl-doc       like ub.doc-line.price-base
field vat-base-doc       like ub.doc-line.price-base
field vat-rubl-doc       like ub.doc-line.price-base
field vat-base-buyer-doc like ub.doc-line.price-base
field vat-rubl-buyer-doc like ub.doc-line.price-base
field slt-base-doc       like ub.doc-line.price-base
field slt-rubl-doc       like ub.doc-line.price-base
field road-tax-base-doc  like ub.doc-line.price-base
field road-tax-rubl-doc  like ub.doc-line.price-base
field excise-base-doc    like ub.doc-line.price-base
field excise-rubl-doc    like ub.doc-line.price-base
field sum-dsc-base-acc   like ub.doc-line.price-base
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field sum-dsc-cli-acc    like ub.doc-line.price-cli
field dsc-base-acc       like ub.doc-line.price-base
field dsc-rubl-acc       like ub.doc-line.price-base
field dsc-cli-acc        like ub.doc-line.price-cli
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field vat-cli-acc        like ub.doc-line.price-cli
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field slt-cli-acc        like ub.doc-line.price-cli
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field road-tax-cli-acc   like ub.doc-line.price-cli
field excise-base-acc    like ub.doc-line.price-base
field excise-rubl-acc    like ub.doc-line.price-base
field excise-cli-acc     like ub.doc-line.price-cli
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field transport-cli-acc  like ub.doc-line.price-cli
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
field other-cli-acc      like ub.doc-line.price-cli
field sum-dsc-base-cur   like ub.doc-line.price-base
field sum-dsc-rubl-cur   like ub.doc-line.price-base
field dsc-base-cur       like ub.doc-line.price-base
field dsc-rubl-cur       like ub.doc-line.price-base
field vat-base-cur       like ub.doc-line.price-base
field vat-rubl-cur       like ub.doc-line.price-base
field vat-base-buyer-cur like ub.doc-line.price-base
field vat-rubl-buyer-cur like ub.doc-line.price-base
field slt-base-cur       like ub.doc-line.price-base
field slt-rubl-cur       like ub.doc-line.price-base
field road-tax-base-cur  like ub.doc-line.price-base
field road-tax-rubl-cur  like ub.doc-line.price-base
field excise-base-cur    like ub.doc-line.price-base
field excise-rubl-cur    like ub.doc-line.price-base
index sum-type is primary unique sum-type.
.
define temp-table tt-allsum no-undo
field sum-type           as   character
field fact-qnty             as decimal
field cli-qnty              as decimal
field sum-dsc-base-doc      as decimal
field sum-dsc-rubl-doc      as decimal
field dsc-base-doc          as decimal
field dsc-rubl-doc          as decimal
field vat-base-doc          as decimal
field vat-rubl-doc          as decimal
field vat-base-buyer-doc    as decimal
field vat-rubl-buyer-doc    as decimal
field slt-base-doc          as decimal
field slt-rubl-doc          as decimal
field road-tax-base-doc     as decimal
field road-tax-rubl-doc     as decimal
field excise-base-doc       as decimal
field excise-rubl-doc       as decimal
field sum-dsc-base-acc      as decimal
field sum-dsc-rubl-acc      as decimal
field sum-dsc-cli-acc       as decimal
field dsc-base-acc          as decimal
field dsc-rubl-acc          as decimal
field dsc-cli-acc           as decimal
field vat-base-acc          as decimal
field vat-rubl-acc          as decimal
field vat-cli-acc           as decimal
field slt-base-acc          as decimal
field slt-rubl-acc          as decimal
field slt-cli-acc           as decimal
field road-tax-base-acc     as decimal
field road-tax-rubl-acc     as decimal
field road-tax-cli-acc      as decimal
field excise-base-acc       as decimal
field excise-rubl-acc       as decimal
field excise-cli-acc        as decimal
field transport-base-acc    as decimal
field transport-rubl-acc    as decimal
field transport-cli-acc     as decimal
field other-base-acc        as decimal
field other-rubl-acc        as decimal
field other-cli-acc         as decimal
field sum-dsc-base-cur      as decimal
field sum-dsc-rubl-cur      as decimal
field dsc-base-cur          as decimal
field dsc-rubl-cur          as decimal
field vat-base-cur          as decimal
field vat-rubl-cur          as decimal
field vat-base-buyer-cur    as decimal
field vat-rubl-buyer-cur    as decimal
field slt-base-cur          as decimal
field slt-rubl-cur          as decimal
field road-tax-base-cur     as decimal
field road-tax-rubl-cur     as decimal
field excise-base-cur       as decimal
field excise-rubl-cur       as decimal
index sum-type is primary unique sum-type.
define temp-table tt-clcparts no-undo like ub.parts
field part-cur-base like ub.gds-dtl.price-base
field part-cur-road-tax like ub.gds-dtl.price-base
field part-cur-excise like ub.gds-dtl.price-base
.
define variable v-calcbypart as log no-undo.
procedure clcprtsl_calc-parts :
define input parameter parrec-parts        as   recid                   no-undo.
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcurroad-tax      like ub.doc-line.road-tax    no-undo.
define input parameter parcurexcise        like ub.doc-line.excise      no-undo.
define input parameter parcurvat-pc        like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define variable parartic        like ub.parts.artic         no-undo.
define variable parprod-type    like ub.parts.prod-type     no-undo.
define variable parprod-code    like ub.parts.prod-code     no-undo.
define variable pardoc-type     like ub.parts.doc-type      no-undo.
define variable pardoc-code     like ub.parts.out-code      no-undo.
define variable parobj-type     like ub.parts.obj-type      no-undo.
define variable parobj-code     like ub.parts.obj-code      no-undo.
define variable parprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable pardiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable pardiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable pardoc-qnty     like ub.parts.qnty          no-undo.
define variable parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable parcurartic        like ub.parts.artic         no-undo.
define variable parcurprod-type    like ub.parts.prod-type     no-undo.
define variable parcurprod-code    like ub.parts.prod-code     no-undo.
define variable parcurdoc-type     like ub.parts.doc-type      no-undo.
define variable parcurdoc-code     like ub.parts.out-code      no-undo.
define variable parcurobj-type     like ub.parts.obj-type      no-undo.
define variable parcurobj-code     like ub.parts.obj-code      no-undo.
define variable parcurprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parcurprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable parcurdiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable parcurdiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parcurfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcurcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable parcurdoc-qnty     like ub.parts.qnty          no-undo.
define variable parcurbase-rate    like ub.trn-doc.base-rate   no-undo.
define variable parcurbase-scale   like ub.trn-doc.base-scale  no-undo.
define variable parcurext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define buffer bf_tt-allsum     for tt-allsum.
define buffer bfs_tt-allsum    for tt-allsum.
define buffer bfpc_tt-allsum   for tt-allsum.
define buffer bfspc_tt-allsum  for tt-allsum.
define buffer bfacc_tt-allsum  for tt-allsum.
define buffer bfsacc_tt-allsum for tt-allsum.
define buffer cl_tt-clcparts   for tt-clcparts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_sysconf       for ub.sysconf.
    define buffer   in-vatp-trn-doccl  for ub.trn-doc .
    define buffer   in-vatp-partscl    for ub.parts   .
    define buffer   in-vatp-doccl      for ub.trn-doc .
    define buffer   in-vatp-goodscl    for ub.goods   .
    define buffer   in-vatp-sysconfcl  for ub.sysconf .
    define buffer   in-vatp_doc-attrcl for ub.doc-attr.
    define variable in-vatp-have-vat-sltcl       as   logical initial yes    no-undo.
    define variable vat-pc-loccl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbcl                  as   character              no-undo.
    define variable slt-pc-loccl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-ratecl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loccl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loccl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loccl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loccl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loccl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loccl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loccl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loccl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loccl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loccl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loccl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loccl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loccl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loccl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loccl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loccl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdcl             as   character              no-undo.
    define variable varinvatp-typecl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecl like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcl for ub.gds-dtl.
    define buffer out-vatp_partscl       for ub.parts.
    define buffer out-vatp_sysconfcl     for ub.sysconf.
    define buffer out-vatp_doc-linecl    for ub.doc-line.
    define buffer out-vatp_goodscl       for ub.goods.
    define buffer out-vatp_trn-doccl     for ub.trn-doc.
    define buffer out-vatp_doc-attrcl    for ub.doc-attr.
    define variable varprice-base-conscl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecl         as   character                           no-undo.
    define variable varfrm-cnsvcl              as   character                           no-undo.
    define variable varroot-nodecl             as   integer                             no-undo.
    define variable varempty-scalecl           as   logical                             no-undo.
    define variable varis-cons-parts-havecl    as   logical                             no-undo.
    define variable varsum-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcl        as   logical                             no-undo.
    define variable varcurclprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurclprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococl  for ub.trn-doc .
    define buffer   in-vatp-partsocl    for ub.parts   .
    define buffer   in-vatp-dococl      for ub.trn-doc .
    define buffer   in-vatp-goodsocl    for ub.goods   .
    define buffer   in-vatp-sysconfocl  for ub.sysconf .
    define buffer   in-vatp_doc-attrocl for ub.doc-attr.
    define variable in-vatp-have-vat-sltocl       as   logical initial yes    no-undo.
    define variable vat-pc-lococl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocl                  as   character              no-undo.
    define variable slt-pc-lococl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocl              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococl  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocl             as   character              no-undo.
    define variable varinvatp-typeocl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecur    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecur    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecur like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecur like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercur              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercur              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecur            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecur            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecur            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecur            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcur     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcur for ub.gds-dtl.
    define buffer out-vatp_partscur       for ub.parts.
    define buffer out-vatp_sysconfcur     for ub.sysconf.
    define buffer out-vatp_doc-linecur    for ub.doc-line.
    define buffer out-vatp_goodscur       for ub.goods.
    define buffer out-vatp_trn-doccur     for ub.trn-doc.
    define buffer out-vatp_doc-attrcur    for ub.doc-attr.
    define variable varprice-base-conscur      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscur      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecur         as   character                           no-undo.
    define variable varfrm-cnsvcur              as   character                           no-undo.
    define variable varroot-nodecur             as   integer                             no-undo.
    define variable varempty-scalecur           as   logical                             no-undo.
    define variable varis-cons-parts-havecur    as   logical                             no-undo.
    define variable varsum-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcur        as   logical                             no-undo.
    define variable varcurcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcur               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcur    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococur  for ub.trn-doc .
    define buffer   in-vatp-partsocur    for ub.parts   .
    define buffer   in-vatp-dococur      for ub.trn-doc .
    define buffer   in-vatp-goodsocur    for ub.goods   .
    define buffer   in-vatp-sysconfocur  for ub.sysconf .
    define buffer   in-vatp_doc-attrocur for ub.doc-attr.
    define variable in-vatp-have-vat-sltocur       as   logical initial yes    no-undo.
    define variable vat-pc-lococur                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocur                  as   character              no-undo.
    define variable slt-pc-lococur                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocur              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococur    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococur    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococur     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococur like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococur like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococur  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococur               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococur               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococur           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococur         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococur         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococur          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococur             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococur             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococur              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococur          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocur             as   character              no-undo.
    define variable varinvatp-typeocur             as   character              no-undo.
do on error undo, return error return-value :
find first cl_tt-clcparts where recid(cl_tt-clcparts) = parrec-parts no-lock.
for each bf_tt-allsum on error undo, return error return-value :
  delete bf_tt-allsum.
end.
assign
  price-rubl-with-tax-loccl = cl_tt-clcparts.price-rubl
  price-base-with-tax-loccl = cl_tt-clcparts.price-base
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbcl
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltcl = yes.
  end.
  else do:
    find first in-vatp_doc-attrcl no-lock
      where in-vatp_doc-attrcl.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrcl then do:
      assign
        in-vatp-have-vat-sltcl = yes.
    end.
    else do:
         in-vatp-have-vat-sltcl = no.
    end.
  end.
  assign
   price-cli-with-tax-loccl = cl_tt-clcparts.price-cli
   cli-base-ratecl          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-loccl  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-loccl  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-loccl = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-loccl = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-loccl     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-loccl     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-loccl         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-loccl         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
    ASSIGN   slt-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
  assign
    exch-rate-cli-loccl = (cl_tt-clcparts.price-rubl - transport-rubl-loccl - other-rubl-loccl - road-tax-rubl-loccl - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-loccl else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-loccl else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-loccl        = slt-rubl-loccl       / exch-rate-cli-loccl
    vat-cli-loccl        = vat-rubl-loccl       / exch-rate-cli-loccl
    road-tax-cli-loccl   = road-tax-rubl-loccl  / exch-rate-cli-loccl
    transport-cli-loccl  = 0
    other-cli-loccl      = 0
  .
ASSIGN
          price-base-without-tax-loccl = price-base-with-tax-loccl - vat-base-loccl - slt-base-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))
    price-rubl-without-tax-loccl = price-rubl-with-tax-loccl - vat-rubl-loccl - slt-rubl-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))
.
if paris-doc then do:
  assign
    parartic     = cl_tt-clcparts.artic
    parprod-type = cl_tt-clcparts.prod-type
    parprod-code = cl_tt-clcparts.prod-code
    pardoc-type  = cl_tt-clcparts.doc-type
    pardoc-code  = cl_tt-clcparts.out-code
    parobj-type  = cl_tt-clcparts.obj-type
    parobj-code  = cl_tt-clcparts.obj-code.
if parext-doc-type = 'ot':U or
   parext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcl = yes.
end.
else do:
  find first out-vatp_doc-attrcl no-lock
    where out-vatp_doc-attrcl.doc-code  = pardoc-code
      and out-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcl then do:
    assign
      out-vatp-have-vat-sltcl = yes.
  end.
  else do:
     out-vatp-have-vat-sltcl = no.
  end.
end.
find first out-vatp_goodscl where out-vatp_goodscl.artic     = parartic     and
                                   out-vatp_goodscl.prod-type = parprod-type and
                                   out-vatp_goodscl.prod-code = parprod-code no-lock.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,output varroot-nodecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parartic parprod-type parprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecl
  ,input  'empty-scale=request'
  ,output varempty-scalecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parartic parprod-type parprod-code skip
    "Признак" varroot-nodecl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcl
  )  .
if varoutvprbcl = "base":u then do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax / parbase-rate * parbase-scale)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   / parbase-rate * parbase-scale)
  .
end.
if varoutvprbcl = "rubl":u then do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * parbase-rate / parbase-scale)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * parbase-rate / parbase-scale) .
end.
assign
  varis-cons-parts-havecl =  no.
assign
  varfact-qntycl       = 0
  varcons-qntycl       = 0
  varprice-base-conscl = 0
  varprice-rubl-conscl = 0.
find first out-vatp_doc-linecl where
           out-vatp_doc-linecl.doc-code   = pardoc-code
       and out-vatp_doc-linecl.artic      = parartic
       and out-vatp_doc-linecl.prod-type  = parprod-type
       and out-vatp_doc-linecl.prod-code  = parprod-code no-lock no-error.
if available out-vatp_doc-linecl           and
  (out-vatp_doc-linecl.status_ = 'запрос':U or out-vatp_goodscl.gds-type = 'у':U) then do:
  assign
    varfact-qntycl = out-vatp_doc-linecl.fact-qnty.
end.
else do:
  for each out-vatp_partscl where out-vatp_partscl.out-code   = pardoc-code
                               and out-vatp_partscl.obj-type   = parobj-type
                               and out-vatp_partscl.obj-code   = parobj-code
                               and out-vatp_partscl.artic      = parartic
                               and out-vatp_partscl.prod-type  = parprod-type
                               and out-vatp_partscl.prod-code  = parprod-code no-lock :
    if out-vatp_partscl.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococl = out-vatp_partscl.price-rubl
  price-base-with-tax-lococl = out-vatp_partscl.price-base
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocl
  )  .
  if out-vatp_partscl.out-code = 'free-zone':U     or
     out-vatp_partscl.out-code = 'out-zone':U   or
     out-vatp_partscl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocl = yes.
  end.
  else do:
    find first in-vatp_doc-attrocl no-lock
      where in-vatp_doc-attrocl.doc-code  = out-vatp_partscl.out-code
        and in-vatp_doc-attrocl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocl then do:
      assign
        in-vatp-have-vat-sltocl = yes.
    end.
    else do:
         in-vatp-have-vat-sltocl = no.
    end.
  end.
  assign
   price-cli-with-tax-lococl = out-vatp_partscl.price-cli
   cli-base-rateocl          = out-vatp_partscl.cli-base-rate.
  ASSIGN   road-tax-base-lococl  = (if out-vatp_partscl.road-tax-base  = ? then 0 else out-vatp_partscl.road-tax-base)
           road-tax-rubl-lococl  = (if out-vatp_partscl.road-tax-rubl  = ? then 0 else out-vatp_partscl.road-tax-rubl).
  ASSIGN  transport-base-lococl = (if out-vatp_partscl.transport-base = ? then 0 else out-vatp_partscl.transport-base)
          transport-rubl-lococl = (if out-vatp_partscl.transport-rubl = ? then 0 else out-vatp_partscl.transport-rubl)
          other-base-lococl     = (if out-vatp_partscl.other-base     = ? then 0 else out-vatp_partscl.other-base)
          other-rubl-lococl     = (if out-vatp_partscl.other-rubl     = ? then 0 else out-vatp_partscl.other-rubl)
          vat-pc-lococl         = (if out-vatp_partscl.vat-pc         = ? then 0 else out-vatp_partscl.vat-pc)
          slt-pc-lococl         = (if out-vatp_partscl.slt-pc         = ? then 0 else out-vatp_partscl.slt-pc).
          ASSIGN   slt-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
    ASSIGN   slt-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
  assign
    exch-rate-cli-lococl = (out-vatp_partscl.price-rubl - transport-rubl-lococl - other-rubl-lococl - road-tax-rubl-lococl - (if out-vatp_partscl.vat-type <> 'в т. ч.':U then vat-rubl-lococl else 0) - (if out-vatp_partscl.slt-type <> 'в т. ч.':U then slt-rubl-lococl else 0)) / out-vatp_partscl.price-cli .
  assign
    slt-cli-lococl        = slt-rubl-lococl       / exch-rate-cli-lococl
    vat-cli-lococl        = vat-rubl-lococl       / exch-rate-cli-lococl
    road-tax-cli-lococl   = road-tax-rubl-lococl  / exch-rate-cli-lococl
    transport-cli-lococl  = 0
    other-cli-lococl      = 0
  .
ASSIGN
          price-base-without-tax-lococl = price-base-with-tax-lococl - vat-base-lococl - slt-base-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))
    price-rubl-without-tax-lococl = price-rubl-with-tax-lococl - vat-rubl-lococl - slt-rubl-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))
.
      assign
        varprice-base-conscl = varprice-base-conscl + (price-base-with-tax-lococl - (if road-tax-base-lococl = ? then 0 else road-tax-base-lococl))* out-vatp_partscl.fact-qnty
        varprice-rubl-conscl = varprice-rubl-conscl + (price-rubl-with-tax-lococl - (if road-tax-rubl-lococl = ? then 0 else road-tax-rubl-lococl))* out-vatp_partscl.fact-qnty.
      assign
        varis-cons-parts-havecl = yes
        varcons-qntycl          = varcons-qntycl + out-vatp_partscl.fact-qnty.
    end.
    assign
      varfact-qntycl = varfact-qntycl + out-vatp_partscl.fact-qnty.
  end.
end.
assign
  varprice-base-conscl = varprice-base-conscl / varcons-qntycl
  varprice-rubl-conscl = varprice-rubl-conscl / varcons-qntycl.
if varprice-base-conscl = ? then do:
  assign
    varprice-base-conscl = 0.
end.
if varprice-rubl-conscl = ? then do:
  assign
    varprice-rubl-conscl = 0.
end.
assign
  varsum-base-factovpcl     = 0
  varslt-base-factovpcl     = 0
  varvat-base-factovpcl     = 0
  varvatcons-base-factovpcl = 0
  vardsc-base-factovpcl     = 0
  varsum-base-docovpcl      = 0
  varslt-base-docovpcl      = 0
  varvat-base-docovpcl      = 0
  varvatcons-base-docovpcl  = 0
  vardsc-base-docovpcl      = 0
  varsum-rubl-factovpcl     = 0
  varslt-rubl-factovpcl     = 0
  varvat-rubl-factovpcl     = 0
  varvatcons-rubl-factovpcl = 0
  vardsc-rubl-factovpcl     = 0
  varsum-rubl-docovpcl      = 0
  varslt-rubl-docovpcl      = 0
  varvat-rubl-docovpcl      = 0
  varvatcons-rubl-docovpcl  = 0
  vardsc-rubl-docovpcl      = 0.
assign
  varis-one-gds-dtlcl = no.
find first out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                     out-vatp_gds-dtlcl.artic     = parartic     and
                                     out-vatp_gds-dtlcl.prod-type = parprod-type and
                                     out-vatp_gds-dtlcl.prod-code = parprod-code no-lock no-error.
if available out-vatp_gds-dtlcl then do:
  find first buf_out-vatp_gds-dtlcl where buf_out-vatp_gds-dtlcl.doc-code  =  pardoc-code                and
                                           buf_out-vatp_gds-dtlcl.artic     =  parartic                   and
                                           buf_out-vatp_gds-dtlcl.prod-type =  parprod-type               and
                                           buf_out-vatp_gds-dtlcl.prod-code =  parprod-code               and
                                           recid(buf_out-vatp_gds-dtlcl)    <> recid(out-vatp_gds-dtlcl) no-lock no-error.
  if not available buf_out-vatp_gds-dtlcl then do:
    assign
      varis-one-gds-dtlcl = yes.
  end.
  if varoutvprbcl = "base":u then do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
  end.
  else do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
  end.
  if varempty-scalecl    = yes or
     varis-one-gds-dtlcl = yes   then do:
    assign
                price-base-with-tax-salecl    = (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)
        slt-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-base-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-base-salecl            = out-vatp_gds-dtlcl.discnt-base
                price-rubl-with-tax-salecl    = (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)
        slt-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-rubl-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-rubl-salecl            = out-vatp_gds-dtlcl.discnt-rubl
        .
    if pardoc-type = 'инв':U then do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
    else do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl ) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                       out-vatp_gds-dtlcl.artic     = parartic     and
                                       out-vatp_gds-dtlcl.prod-type = parprod-type and
                                       out-vatp_gds-dtlcl.prod-code = parprod-code no-lock :
      if varoutvprbcl = "base":u then do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
      end.
      else do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
      end.
      assign
             varsum-base-factovpcl = varsum-base-factovpcl + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-base-factovpcl = varslt-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-base-factovpcl = varvat-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-base-factovpcl = varvatcons-base-factovpcl + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-factovpcl = vardsc-base-factovpcl + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.fact-qnty
       varsum-base-docovpcl  = varsum-base-docovpcl  + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-base-docovpcl  = varslt-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-base-docovpcl  = varvat-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-base-docovpcl  = varvatcons-base-docovpcl  + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-docovpcl  = vardsc-base-docovpcl  + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.doc-qnty
      .
      assign
             varsum-rubl-factovpcl = varsum-rubl-factovpcl + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-rubl-factovpcl = varslt-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-rubl-factovpcl = varvat-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-rubl-factovpcl = varvatcons-rubl-factovpcl + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-factovpcl = vardsc-rubl-factovpcl + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.fact-qnty
       varsum-rubl-docovpcl  = varsum-rubl-docovpcl  + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-rubl-docovpcl  = varslt-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-rubl-docovpcl  = varvat-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-rubl-docovpcl  = varvatcons-rubl-docovpcl  + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-docovpcl  = vardsc-rubl-docovpcl  + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.doc-qnty   .
    end.
    if pardoc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-docovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-docovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-docovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-docovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-docovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-docovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-docovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-docovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-docovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-docovpcl / varfact-qntycl.
    end.
    else do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-factovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-factovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-factovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-factovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-factovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-factovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-factovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-factovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-factovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-factovpcl / varfact-qntycl.
    end.
  end.
end.
assign
  price-base-without-tax-salecl = price-base-with-tax-salecl - vat-base-salecl - slt-base-salecl - road-tax-base-salecl
  price-rubl-without-tax-salecl = price-rubl-with-tax-salecl - vat-rubl-salecl - slt-rubl-salecl - road-tax-rubl-salecl.
end.
if paris-cur then do:
  assign
    parcurartic      = cl_tt-clcparts.artic
    parcurprod-type  = cl_tt-clcparts.prod-type
    parcurprod-code  = cl_tt-clcparts.prod-code
    parcurdoc-type   = cl_tt-clcparts.doc-type
    parcurdoc-code   = cl_tt-clcparts.out-code
    parcurobj-type   = cl_tt-clcparts.obj-type
    parcurobj-code   = cl_tt-clcparts.obj-code.
  if parr-b = "base" then do:
    assign
      parcurprice-base = parcur-base
      parcurprice-rubl = parcur-base * parbase-rate / parbase-scale.
  end.
  else do:
    assign
      parcurprice-base = parcur-base / parbase-rate * parbase-scale
      parcurprice-rubl = parcur-base.
  end.
  assign
    parcurbase-rate   = parbase-rate
    parcurbase-scale  = parbase-scale
    parcurdiscnt-base = 0
    parcurdiscnt-rubl = 0
    parcurfact-qnty   = cl_tt-clcparts.fact-qnty
    parcurcli-qnty    = cl_tt-clcparts.cli-qnty
    parcurdoc-qnty    = cl_tt-clcparts.qnty.
if parcurext-doc-type = 'ot':U or
   parcurext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcur = yes.
end.
else do:
  find first out-vatp_doc-attrcur no-lock
    where out-vatp_doc-attrcur.doc-code  = parcurdoc-code
      and out-vatp_doc-attrcur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcur then do:
    assign
      out-vatp-have-vat-sltcur = yes.
  end.
  else do:
     out-vatp-have-vat-sltcur = no.
  end.
end.
find first out-vatp_goodscur where out-vatp_goodscur.artic     = parcurartic     and
                                   out-vatp_goodscur.prod-type = parcurprod-type and
                                   out-vatp_goodscur.prod-code = parcurprod-code no-lock.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parcurartic
  ,input  parcurprod-type
  ,input  parcurprod-code
  ,output varroot-nodecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecur
  ,input  'empty-scale=request'
  ,output varempty-scalecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    "Признак" varroot-nodecur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcur
  )  .
if varoutvprbcur = "base":u then do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax / parcurbase-rate * parcurbase-scale)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   / parcurbase-rate * parcurbase-scale)
  .
end.
if varoutvprbcur = "rubl":u then do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * parcurbase-rate / parcurbase-scale)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * parcurbase-rate / parcurbase-scale) .
end.
assign
  varis-cons-parts-havecur =  no.
assign
  varfact-qntycur       = 0
  varcons-qntycur       = 0
  varprice-base-conscur = 0
  varprice-rubl-conscur = 0.
if cl_tt-clcparts.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococur = cl_tt-clcparts.price-rubl
  price-base-with-tax-lococur = cl_tt-clcparts.price-base
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocur
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocur = yes.
  end.
  else do:
    find first in-vatp_doc-attrocur no-lock
      where in-vatp_doc-attrocur.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrocur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocur then do:
      assign
        in-vatp-have-vat-sltocur = yes.
    end.
    else do:
         in-vatp-have-vat-sltocur = no.
    end.
  end.
  assign
   price-cli-with-tax-lococur = cl_tt-clcparts.price-cli
   cli-base-rateocur          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-lococur  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-lococur  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-lococur = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-lococur = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-lococur     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-lococur     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-lococur         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-lococur         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
    ASSIGN   slt-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
  assign
    exch-rate-cli-lococur = (cl_tt-clcparts.price-rubl - transport-rubl-lococur - other-rubl-lococur - road-tax-rubl-lococur - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-lococur else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-lococur else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-lococur        = slt-rubl-lococur       / exch-rate-cli-lococur
    vat-cli-lococur        = vat-rubl-lococur       / exch-rate-cli-lococur
    road-tax-cli-lococur   = road-tax-rubl-lococur  / exch-rate-cli-lococur
    transport-cli-lococur  = 0
    other-cli-lococur      = 0
  .
ASSIGN
          price-base-without-tax-lococur = price-base-with-tax-lococur - vat-base-lococur - slt-base-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))
    price-rubl-without-tax-lococur = price-rubl-with-tax-lococur - vat-rubl-lococur - slt-rubl-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))
.
  assign
    varprice-base-conscur    = varprice-base-conscur + (price-base-with-tax-lococur - (if road-tax-base-lococur = ? then 0 else road-tax-base-lococur))* cl_tt-clcparts.fact-qnty
    varprice-rubl-conscur    = varprice-rubl-conscur + (price-rubl-with-tax-lococur - (if road-tax-rubl-lococur = ? then 0 else road-tax-rubl-lococur))* cl_tt-clcparts.fact-qnty
    varis-cons-parts-havecur = yes
    varcons-qntycur          = varcons-qntycur + cl_tt-clcparts.fact-qnty.
end.
assign
  varfact-qntycur = cl_tt-clcparts.fact-qnty.
assign
  varprice-base-conscur = varprice-base-conscur / varcons-qntycur
  varprice-rubl-conscur = varprice-rubl-conscur / varcons-qntycur.
if varprice-base-conscur = ? then do:
  assign
    varprice-base-conscur = 0.
end.
if varprice-rubl-conscur = ? then do:
  assign
    varprice-rubl-conscur = 0.
end.
assign
    slt-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-base-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-base-salecur            = parcurdiscnt-base
  price-base-with-tax-salecur    = (parcurprice-base - parcurdiscnt-base)
    slt-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-rubl-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-rubl-salecur            = parcurdiscnt-rubl
  price-rubl-with-tax-salecur    = (parcurprice-rubl - parcurdiscnt-rubl)
  .
if parcurdoc-type = 'инв':U then do:
  assign
    varfact-qntycur = parcurdoc-qnty.
end.
else do:
  assign
    varfact-qntycur = parcurfact-qnty.
end.
if varis-cons-parts-havecur = no then do:
  assign
        vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
        vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc).
end.
else do:
  if parcurdoc-type = 'инв':U then do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
  else do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-base-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-rubl-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
end.
assign
price-base-without-tax-salecur = price-base-with-tax-salecur - vat-base-salecur - slt-base-salecur - road-tax-base-salecur
price-rubl-without-tax-salecur = price-rubl-with-tax-salecur - vat-rubl-salecur - slt-rubl-salecur - road-tax-rubl-salecur.
end.
create bf_tt-allsum.
assign
  bf_tt-allsum.sum-type = 'основная_сумма':U.
assign
  bf_tt-allsum.fact-qnty          =  cl_tt-clcparts.fact-qnty
  bf_tt-allsum.cli-qnty           =  cl_tt-clcparts.cli-qnty
  bf_tt-allsum.sum-dsc-base-doc   =  (if price-base-with-tax-salecl  = ? then 0 else price-base-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-doc   =  (if price-rubl-with-tax-salecl  = ? then 0 else price-rubl-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-doc       =  (if discnt-base-salecl          = ? then 0 else discnt-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-doc       =  (if discnt-rubl-salecl          = ? then 0 else discnt-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-doc       =  (if slt-base-salecl             = ? then 0 else slt-base-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-doc       =  (if slt-rubl-salecl             = ? then 0 else slt-rubl-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-doc =  (if vat-base-buyercl            = ? then 0 else vat-base-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-doc =  (if vat-rubl-buyercl            = ? then 0 else vat-rubl-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-doc  =  (if road-tax-base-salecl        = ? then 0 else road-tax-base-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-doc  =  (if road-tax-rubl-salecl        = ? then 0 else road-tax-rubl-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-doc    =  (if excise-base-salecl          = ? then 0 else excise-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-doc    =  (if excise-rubl-salecl          = ? then 0 else excise-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-base-cur   =  (if price-base-with-tax-salecur = ? then 0 else price-base-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-cur   =  (if price-rubl-with-tax-salecur = ? then 0 else price-rubl-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-cur       =  (if discnt-base-salecur         = ? then 0 else discnt-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-cur       =  (if discnt-rubl-salecur         = ? then 0 else discnt-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-cur       =  (if slt-base-salecur            = ? then 0 else slt-base-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-cur       =  (if slt-rubl-salecur            = ? then 0 else slt-rubl-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-cur =  (if vat-base-buyercur           = ? then 0 else vat-base-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-cur =  (if vat-rubl-buyercur           = ? then 0 else vat-rubl-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-cur  =  (if road-tax-base-salecur       = ? then 0 else road-tax-base-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-cur  =  (if road-tax-rubl-salecur       = ? then 0 else road-tax-rubl-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-cur    =  (if excise-base-salecur         = ? then 0 else excise-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-cur    =  (if excise-rubl-salecur         = ? then 0 else excise-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  .
if cl_tt-clcparts.purch-code = integer('2':U) then do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl  - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl  - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
else do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
if bf_tt-allsum.vat-base-doc = ? then bf_tt-allsum.vat-base-doc = 0.
if bf_tt-allsum.vat-rubl-doc = ? then bf_tt-allsum.vat-rubl-doc = 0.
assign
  bf_tt-allsum.sum-dsc-base-acc     = (if price-base-with-tax-loccl    = ? then 0 else price-base-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-acc     = (if price-rubl-with-tax-loccl    = ? then 0 else price-rubl-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-cli-acc      = (if (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl = ? then 0
                                        else
                                          (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-acc         = 0
  bf_tt-allsum.dsc-rubl-acc         = 0
  bf_tt-allsum.dsc-cli-acc          = 0
  bf_tt-allsum.vat-base-acc         = (if vat-base-loccl      = ? then 0 else vat-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-acc         = (if vat-rubl-loccl      = ? then 0 else vat-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-cli-acc          = (if vat-cli-loccl / cli-base-ratecl      = ? then 0 else vat-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-acc         = (if slt-base-loccl      = ? then 0 else slt-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-acc         = (if slt-rubl-loccl      = ? then 0 else slt-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-cli-acc          = (if slt-cli-loccl / cli-base-ratecl      = ? then 0 else slt-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-acc    = (if road-tax-base-loccl = ? then 0 else road-tax-base-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-acc    = (if road-tax-rubl-loccl = ? then 0 else road-tax-rubl-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-cli-acc     = (if road-tax-cli-loccl / cli-base-ratecl = ? then 0 else road-tax-cli-loccl / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-acc      = 0
  bf_tt-allsum.excise-rubl-acc      = 0
  bf_tt-allsum.excise-cli-acc       = 0
  bf_tt-allsum.transport-base-acc   = (if transport-base-loccl   = ? then 0 else transport-base-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-rubl-acc   = (if transport-rubl-loccl   = ? then 0 else transport-rubl-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-cli-acc    = (if transport-cli-loccl / cli-base-ratecl   = ? then 0 else transport-cli-loccl / cli-base-ratecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-base-acc       = (if other-base-loccl       = ? then 0 else other-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-rubl-acc       = (if other-rubl-loccl       = ? then 0 else other-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-cli-acc        = (if other-cli-loccl / cli-base-ratecl       = ? then 0 else other-cli-loccl     / cli-base-ratecl  * cl_tt-clcparts.fact-qnty).
create bfs_tt-allsum.
assign
  bfs_tt-allsum.sum-type = 'основная_сумма_со_знаком':U.
if pardoc-type = 'инв':U or
   pardoc-type = 'при':U    or
   pardoc-type = 'возврат':U    then do:
   buffer-copy bf_tt-allsum except bf_tt-allsum.sum-type to bfs_tt-allsum.
end.
else do:
  assign
    bfs_tt-allsum.fact-qnty           =  - bf_tt-allsum.fact-qnty
    bfs_tt-allsum.cli-qnty            =  - bf_tt-allsum.cli-qnty
    bfs_tt-allsum.sum-dsc-base-doc    =  - bf_tt-allsum.sum-dsc-base-doc
    bfs_tt-allsum.sum-dsc-rubl-doc    =  - bf_tt-allsum.sum-dsc-rubl-doc
    bfs_tt-allsum.dsc-base-doc        =  - bf_tt-allsum.dsc-base-doc
    bfs_tt-allsum.dsc-rubl-doc        =  - bf_tt-allsum.dsc-rubl-doc
    bfs_tt-allsum.vat-base-doc        =  - bf_tt-allsum.vat-base-doc
    bfs_tt-allsum.vat-rubl-doc        =  - bf_tt-allsum.vat-rubl-doc
    bfs_tt-allsum.vat-base-buyer-doc  =  - bf_tt-allsum.vat-base-buyer-doc
    bfs_tt-allsum.vat-rubl-buyer-doc  =  - bf_tt-allsum.vat-rubl-buyer-doc
    bfs_tt-allsum.slt-base-doc        =  - bf_tt-allsum.slt-base-doc
    bfs_tt-allsum.slt-rubl-doc        =  - bf_tt-allsum.slt-rubl-doc
    bfs_tt-allsum.road-tax-base-doc   =  - bf_tt-allsum.road-tax-base-doc
    bfs_tt-allsum.road-tax-rubl-doc   =  - bf_tt-allsum.road-tax-rubl-doc
    bfs_tt-allsum.excise-base-doc     =  - bf_tt-allsum.excise-base-doc
    bfs_tt-allsum.excise-rubl-doc     =  - bf_tt-allsum.excise-rubl-doc
    bfs_tt-allsum.sum-dsc-base-cur    =  - bf_tt-allsum.sum-dsc-base-cur
    bfs_tt-allsum.sum-dsc-rubl-cur    =  - bf_tt-allsum.sum-dsc-rubl-cur
    bfs_tt-allsum.dsc-base-cur        =  - bf_tt-allsum.dsc-base-cur
    bfs_tt-allsum.dsc-rubl-cur        =  - bf_tt-allsum.dsc-rubl-cur
    bfs_tt-allsum.vat-base-cur        =  - bf_tt-allsum.vat-base-cur
    bfs_tt-allsum.vat-rubl-cur        =  - bf_tt-allsum.vat-rubl-cur
    bfs_tt-allsum.vat-base-buyer-cur  =  - bf_tt-allsum.vat-base-buyer-cur
    bfs_tt-allsum.vat-rubl-buyer-cur  =  - bf_tt-allsum.vat-rubl-buyer-cur
    bfs_tt-allsum.slt-base-cur        =  - bf_tt-allsum.slt-base-cur
    bfs_tt-allsum.slt-rubl-cur        =  - bf_tt-allsum.slt-rubl-cur
    bfs_tt-allsum.road-tax-base-cur   =  - bf_tt-allsum.road-tax-base-cur
    bfs_tt-allsum.road-tax-rubl-cur   =  - bf_tt-allsum.road-tax-rubl-cur
    bfs_tt-allsum.excise-base-cur     =  - bf_tt-allsum.excise-base-cur
    bfs_tt-allsum.excise-rubl-cur     =  - bf_tt-allsum.excise-rubl-cur
    bfs_tt-allsum.sum-dsc-base-acc    =  - bf_tt-allsum.sum-dsc-base-acc
    bfs_tt-allsum.sum-dsc-rubl-acc    =  - bf_tt-allsum.sum-dsc-rubl-acc
    bfs_tt-allsum.sum-dsc-cli-acc     =  - bf_tt-allsum.sum-dsc-cli-acc
    bfs_tt-allsum.dsc-base-acc        =  - bf_tt-allsum.dsc-base-acc
    bfs_tt-allsum.dsc-rubl-acc        =  - bf_tt-allsum.dsc-rubl-acc
    bfs_tt-allsum.dsc-cli-acc         =  - bf_tt-allsum.dsc-cli-acc
    bfs_tt-allsum.vat-base-acc        =  - bf_tt-allsum.vat-base-acc
    bfs_tt-allsum.vat-rubl-acc        =  - bf_tt-allsum.vat-rubl-acc
    bfs_tt-allsum.vat-cli-acc         =  - bf_tt-allsum.vat-cli-acc
    bfs_tt-allsum.slt-base-acc        =  - bf_tt-allsum.slt-base-acc
    bfs_tt-allsum.slt-rubl-acc        =  - bf_tt-allsum.slt-rubl-acc
    bfs_tt-allsum.slt-cli-acc         =  - bf_tt-allsum.slt-cli-acc
    bfs_tt-allsum.road-tax-base-acc   =  - bf_tt-allsum.road-tax-base-acc
    bfs_tt-allsum.road-tax-rubl-acc   =  - bf_tt-allsum.road-tax-rubl-acc
    bfs_tt-allsum.road-tax-cli-acc    =  - bf_tt-allsum.road-tax-cli-acc
    bfs_tt-allsum.excise-base-acc     =  - bf_tt-allsum.excise-base-acc
    bfs_tt-allsum.excise-rubl-acc     =  - bf_tt-allsum.excise-rubl-acc
    bfs_tt-allsum.excise-cli-acc      =  - bf_tt-allsum.excise-cli-acc
    bfs_tt-allsum.transport-base-acc  =  - bf_tt-allsum.transport-base-acc
    bfs_tt-allsum.transport-rubl-acc  =  - bf_tt-allsum.transport-rubl-acc
    bfs_tt-allsum.transport-cli-acc   =  - bf_tt-allsum.transport-cli-acc
    bfs_tt-allsum.other-base-acc      =  - bf_tt-allsum.other-base-acc
    bfs_tt-allsum.other-rubl-acc      =  - bf_tt-allsum.other-rubl-acc
    bfs_tt-allsum.other-cli-acc       =  - bf_tt-allsum.other-cli-acc.
end.
create bfpc_tt-allsum.
create bfspc_tt-allsum.
case cl_tt-clcparts.purch-code :
when 1           then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_выкупу':U
    bfspc_tt-allsum.sum-type = 'сумма_по_выкупу_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 4    then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_старой_консигнации':U
    bfspc_tt-allsum.sum-type = 'сумма_по_старой_консигнации_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 3 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_ответственному_хранению':U
    bfspc_tt-allsum.sum-type = 'сумма_по_ответственному_хранению_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 2 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_консигнации_выгода':U
    bfspc_tt-allsum.sum-type = 'сумма_по_консигнации_выгода_со_знаком':U.
  assign
    bfpc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfpc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfpc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-doc    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-doc    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-doc        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-doc        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-doc        = bf_tt-allsum.vat-base-doc
    bfpc_tt-allsum.vat-rubl-doc        = bf_tt-allsum.vat-rubl-doc
    bfpc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-buyer-doc  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-buyer-doc  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-doc        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-doc        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-doc   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-doc   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-doc
    bfpc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-doc
    bfpc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-cur    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-cur    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-cur        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-cur        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-cur        = bf_tt-allsum.vat-base-cur
    bfpc_tt-allsum.vat-rubl-cur        = bf_tt-allsum.vat-rubl-cur
    bfpc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-buyer-cur  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-buyer-cur  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-cur        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-cur        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-cur   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-cur   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-cur
    bfpc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-cur
    bfpc_tt-allsum.sum-dsc-base-acc    = 0
    bfpc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfpc_tt-allsum.sum-dsc-cli-acc     = 0
    bfpc_tt-allsum.dsc-base-acc        = 0
    bfpc_tt-allsum.dsc-rubl-acc        = 0
    bfpc_tt-allsum.dsc-cli-acc         = 0
    bfpc_tt-allsum.vat-base-acc        = 0
    bfpc_tt-allsum.vat-rubl-acc        = 0
    bfpc_tt-allsum.vat-cli-acc         = 0
    bfpc_tt-allsum.slt-base-acc        = 0
    bfpc_tt-allsum.slt-rubl-acc        = 0
    bfpc_tt-allsum.slt-cli-acc         = 0
    bfpc_tt-allsum.road-tax-base-acc   = 0
    bfpc_tt-allsum.road-tax-rubl-acc   = 0
    bfpc_tt-allsum.road-tax-cli-acc    = 0
    bfpc_tt-allsum.excise-base-acc     = 0
    bfpc_tt-allsum.excise-rubl-acc     = 0
    bfpc_tt-allsum.excise-cli-acc      = 0
    bfpc_tt-allsum.transport-base-acc  = 0
    bfpc_tt-allsum.transport-rubl-acc  = 0
    bfpc_tt-allsum.transport-cli-acc   = 0
    bfpc_tt-allsum.other-base-acc      = 0
    bfpc_tt-allsum.other-rubl-acc      = 0
    bfpc_tt-allsum.other-cli-acc       = 0
    .
  assign
    bfspc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfspc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfspc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-doc    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-doc    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-doc        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-doc        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-doc        = bfs_tt-allsum.vat-base-doc
    bfspc_tt-allsum.vat-rubl-doc        = bfs_tt-allsum.vat-rubl-doc
    bfspc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-buyer-doc  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-buyer-doc  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-doc        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-doc        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-doc   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-doc   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-doc
    bfspc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-doc
    bfspc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-cur    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-cur    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-cur        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-cur        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-cur        = bfs_tt-allsum.vat-base-cur
    bfspc_tt-allsum.vat-rubl-cur        = bfs_tt-allsum.vat-rubl-cur
    bfspc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-buyer-cur  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-buyer-cur  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-cur        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-cur        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-cur   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-cur   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-cur
    bfspc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-cur
    bfspc_tt-allsum.sum-dsc-base-acc    = 0
    bfspc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfspc_tt-allsum.sum-dsc-cli-acc     = 0
    bfspc_tt-allsum.dsc-base-acc        = 0
    bfspc_tt-allsum.dsc-rubl-acc        = 0
    bfspc_tt-allsum.dsc-cli-acc         = 0
    bfspc_tt-allsum.vat-base-acc        = 0
    bfspc_tt-allsum.vat-rubl-acc        = 0
    bfspc_tt-allsum.vat-cli-acc         = 0
    bfspc_tt-allsum.slt-base-acc        = 0
    bfspc_tt-allsum.slt-rubl-acc        = 0
    bfspc_tt-allsum.slt-cli-acc         = 0
    bfspc_tt-allsum.road-tax-base-acc   = 0
    bfspc_tt-allsum.road-tax-rubl-acc   = 0
    bfspc_tt-allsum.road-tax-cli-acc    = 0
    bfspc_tt-allsum.excise-base-acc     = 0
    bfspc_tt-allsum.excise-rubl-acc     = 0
    bfspc_tt-allsum.excise-cli-acc      = 0
    bfspc_tt-allsum.transport-base-acc  = 0
    bfspc_tt-allsum.transport-rubl-acc  = 0
    bfspc_tt-allsum.transport-cli-acc   = 0
    bfspc_tt-allsum.other-base-acc      = 0
    bfspc_tt-allsum.other-rubl-acc      = 0
    bfspc_tt-allsum.other-cli-acc       = 0
    .
  create bfacc_tt-allsum.
  assign
    bfacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка':U.
  create bfsacc_tt-allsum.
  assign
    bfsacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка_со_знаком':U.
  assign
    bfacc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfacc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfacc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-doc        = 0
    bfacc_tt-allsum.vat-rubl-doc        = 0
    bfacc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-cur        = 0
    bfacc_tt-allsum.vat-rubl-cur        = 0
    bfacc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-acc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-acc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.sum-dsc-cli-acc     = bf_tt-allsum.sum-dsc-cli-acc
    bfacc_tt-allsum.dsc-base-acc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-acc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.dsc-cli-acc         = bf_tt-allsum.dsc-cli-acc
    bfacc_tt-allsum.vat-base-acc        = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-acc        = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.vat-cli-acc         = bf_tt-allsum.vat-cli-acc
    bfacc_tt-allsum.slt-base-acc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-acc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.slt-cli-acc         = bf_tt-allsum.slt-cli-acc
    bfacc_tt-allsum.excise-base-acc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-acc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.excise-cli-acc      = bf_tt-allsum.excise-cli-acc
    bfacc_tt-allsum.road-tax-base-acc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-acc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.road-tax-cli-acc    = bf_tt-allsum.road-tax-cli-acc
    bfacc_tt-allsum.transport-base-acc  = bf_tt-allsum.transport-base-acc
    bfacc_tt-allsum.transport-rubl-acc  = bf_tt-allsum.transport-rubl-acc
    bfacc_tt-allsum.transport-cli-acc   = bf_tt-allsum.transport-cli-acc
    bfacc_tt-allsum.other-base-acc      = bf_tt-allsum.other-base-acc
    bfacc_tt-allsum.other-rubl-acc      = bf_tt-allsum.other-rubl-acc
    bfacc_tt-allsum.other-cli-acc       = bf_tt-allsum.other-cli-acc
    .
  assign
    bfsacc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfsacc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfsacc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-doc        = 0
    bfsacc_tt-allsum.vat-rubl-doc        = 0
    bfsacc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-cur        = 0
    bfsacc_tt-allsum.vat-rubl-cur        = 0
    bfsacc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-acc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-acc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.sum-dsc-cli-acc     = bfs_tt-allsum.sum-dsc-cli-acc
    bfsacc_tt-allsum.dsc-base-acc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-acc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.dsc-cli-acc         = bfs_tt-allsum.dsc-cli-acc
    bfsacc_tt-allsum.vat-base-acc        = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-acc        = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.vat-cli-acc         = bfs_tt-allsum.vat-cli-acc
    bfsacc_tt-allsum.slt-base-acc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-acc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.slt-cli-acc         = bfs_tt-allsum.slt-cli-acc
    bfsacc_tt-allsum.excise-base-acc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-acc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.excise-cli-acc      = bfs_tt-allsum.excise-cli-acc
    bfsacc_tt-allsum.road-tax-base-acc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-acc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.road-tax-cli-acc    = bfs_tt-allsum.road-tax-cli-acc
    bfsacc_tt-allsum.transport-base-acc  = bfs_tt-allsum.transport-base-acc
    bfsacc_tt-allsum.transport-rubl-acc  = bfs_tt-allsum.transport-rubl-acc
    bfsacc_tt-allsum.transport-cli-acc   = bfs_tt-allsum.transport-cli-acc
    bfsacc_tt-allsum.other-base-acc      = bfs_tt-allsum.other-base-acc
    bfsacc_tt-allsum.other-rubl-acc      = bfs_tt-allsum.other-rubl-acc
    bfsacc_tt-allsum.other-cli-acc       = bfs_tt-allsum.other-cli-acc
    .
end.
otherwise do:
  return error substitute ("Неизвестный тип приобретения &1 по партии с кодом &2 по документу &3, порожденную документом &4 по товару &5 &6 &7.",
                           cl_tt-clcparts.purch-code,
                           cl_tt-clcparts.part-code,
                           cl_tt-clcparts.out-code,
                           cl_tt-clcparts.in-code,
                           cl_tt-clcparts.artic,
                           cl_tt-clcparts.prod-type,
                           cl_tt-clcparts.prod-code).
end.
end case.
end.
end procedure.
procedure clcprtsl_calc-line :
define input  parameter parrec-line as recid no-undo.
define variable v-tax-date         as   date                     no-undo.
define variable v-vat-pc           like ub.doc-line.vat-pc       no-undo.
define variable varr-b             as   character                no-undo.
define variable varr-btype         as   character                no-undo.
define variable varcur-base        like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax    like ub.doc-line.road-tax     no-undo.
define variable varcur-excise      like ub.doc-line.excise       no-undo.
define variable varcur-vat-pc      like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc      like ub.doc-line.slt-pc       no-undo.
define variable varcur-fact-qnty   like ub.gds-dtl.fact-qnty     no-undo.
define variable varb-code          like ub.bar-code.b-code       no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
define variable varlastcur-base        like ub.gds-dtl.price-base no-undo.
define variable varlastcur-road-tax    like ub.gds-dtl.price-base no-undo.
define variable varlastcur-excise      like ub.gds-dtl.price-base     no-undo.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable v-varsum           as decimal                  no-undo.
define variable varprice-salef as decimal   no-undo .
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf_doc-line            for ub.doc-line.
define buffer bf_gds-dtl             for ub.gds-dtl.
define buffer bf_goods               for ub.goods.
define buffer bf_parts               for ub.parts.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf_tt-allsum-line      for tt-allsum-line.
define buffer bfs_tt-allsum-line     for tt-allsum-line.
define buffer bfo_tt-allsum-line     for tt-allsum-line.
define buffer bfos_tt-allsum-line    for tt-allsum-line.
define buffer buf_parts        for ub.parts.
v-calcbypart = no.
do on error undo, return error return-value :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
  find first bf_doc-line where recid (bf_doc-line) = parrec-line no-lock.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  if bf_trn-doc.fact-date <> ?        then do:
    assign v-tax-date = bf_trn-doc.fact-date.
  end.
  else do:
    assign v-tax-date = ?.
  end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  v-tax-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
  if error-status :error
  or v-vat-pc = ? then do:
     return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  if bf_goods.gds-type = 'у':U or
     bf_trn-doc.status_ = 'запрос':U then do:
    for each bf_tt-allsum-line
    on error undo, return error return-value
     :
      delete bf_tt-allsum-line.
    end.
    create bf_tt-allsum-line.
    assign
     bf_tt-allsum-line.sum-type = 'основная_сумма':U.
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code no-lock on error undo, return error return-value :
      assign
        bf_tt-allsum-line.fact-qnty            =  bf_tt-allsum-line.fact-qnty        + bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-doc     =  bf_tt-allsum-line.sum-dsc-base-doc + (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-doc     =  bf_tt-allsum-line.sum-dsc-rubl-doc + (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-base-doc         =  bf_tt-allsum-line.dsc-base-doc     + bf_gds-dtl.discnt-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-rubl-doc         =  bf_tt-allsum-line.dsc-rubl-doc     + bf_gds-dtl.discnt-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-cur     =  bf_tt-allsum-line.sum-dsc-base-cur + (if varr-b = "base" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base / bf_trn-doc.exch-rate * bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-cur     =  bf_tt-allsum-line.sum-dsc-rubl-cur + (if varr-b = "rubl" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-acc     =  bf_tt-allsum-line.sum-dsc-base-acc + bf_doc-line.price-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-acc     =  bf_tt-allsum-line.sum-dsc-rubl-acc + bf_doc-line.price-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-cli-acc      =  ?
        bf_tt-allsum-line.vat-base-acc         =  bf_tt-allsum-line.vat-base-acc     + bf_doc-line.price-base * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-rubl-acc         =  bf_tt-allsum-line.vat-rubl-acc     + bf_doc-line.price-rubl * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-cli-acc          =  ?
        .
    end.
    assign
      bf_tt-allsum-line.cli-qnty             =  ?
      bf_tt-allsum-line.slt-base-doc         =  bf_tt-allsum-line.sum-dsc-base-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-doc         =  bf_tt-allsum-line.sum-dsc-rubl-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-base-doc - bf_tt-allsum-line.slt-base-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-rubl-doc - bf_tt-allsum-line.slt-rubl-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-doc    =  0
      bf_tt-allsum-line.road-tax-rubl-doc    =  0
      bf_tt-allsum-line.excise-base-doc      =  0
      bf_tt-allsum-line.excise-rubl-doc      =  0
      bf_tt-allsum-line.vat-base-doc         =  bf_tt-allsum-line.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-doc         =  bf_tt-allsum-line.vat-rubl-buyer-doc
      bf_tt-allsum-line.dsc-base-cur         =  0
      bf_tt-allsum-line.dsc-rubl-cur         =  0
      bf_tt-allsum-line.slt-base-cur         =  bf_tt-allsum-line.sum-dsc-base-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-cur         =  bf_tt-allsum-line.sum-dsc-rubl-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-base-cur - bf_tt-allsum-line.slt-base-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-rubl-cur - bf_tt-allsum-line.slt-rubl-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-cur    =  0
      bf_tt-allsum-line.road-tax-rubl-cur    =  0
      bf_tt-allsum-line.excise-base-cur      =  0
      bf_tt-allsum-line.excise-rubl-cur      =  0
      bf_tt-allsum-line.vat-base-cur         =  bf_tt-allsum-line.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-cur         =  bf_tt-allsum-line.vat-rubl-buyer-cur
      bf_tt-allsum-line.dsc-base-acc         =  0
      bf_tt-allsum-line.dsc-rubl-acc         =  0
      bf_tt-allsum-line.dsc-cli-acc          =  0
      bf_tt-allsum-line.slt-base-acc         =  0
      bf_tt-allsum-line.slt-rubl-acc         =  0
      bf_tt-allsum-line.slt-cli-acc          =  0
      bf_tt-allsum-line.road-tax-base-acc    =  0
      bf_tt-allsum-line.road-tax-rubl-acc    =  0
      bf_tt-allsum-line.road-tax-cli-acc     =  0
      bf_tt-allsum-line.excise-base-acc      =  0
      bf_tt-allsum-line.excise-rubl-acc      =  0
      bf_tt-allsum-line.excise-cli-acc       =  0
      bf_tt-allsum-line.transport-base-acc   =  0
      bf_tt-allsum-line.transport-rubl-acc   =  0
      bf_tt-allsum-line.transport-cli-acc    =  0
      bf_tt-allsum-line.other-base-acc       =  0
      bf_tt-allsum-line.other-rubl-acc       =  0
      bf_tt-allsum-line.other-cli-acc        =  0
      .
    create bfs_tt-allsum-line.
    assign
    bfs_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U.
    if bf_trn-doc.doc-type = 'инв':U or
       bf_trn-doc.doc-type = 'при':U    or
       bf_trn-doc.doc-type = 'возврат':U    then do:
       buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfs_tt-allsum-line.
    end.
    else do:
      assign
        bfs_tt-allsum-line.fact-qnty           =  - bf_tt-allsum-line.fact-qnty
        bfs_tt-allsum-line.cli-qnty            =  - bf_tt-allsum-line.cli-qnty
        bfs_tt-allsum-line.sum-dsc-base-doc    =  - bf_tt-allsum-line.sum-dsc-base-doc
        bfs_tt-allsum-line.sum-dsc-rubl-doc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc
        bfs_tt-allsum-line.dsc-base-doc        =  - bf_tt-allsum-line.dsc-base-doc
        bfs_tt-allsum-line.dsc-rubl-doc        =  - bf_tt-allsum-line.dsc-rubl-doc
        bfs_tt-allsum-line.vat-base-doc        =  - bf_tt-allsum-line.vat-base-doc
        bfs_tt-allsum-line.vat-rubl-doc        =  - bf_tt-allsum-line.vat-rubl-doc
        bfs_tt-allsum-line.vat-base-buyer-doc  =  - bf_tt-allsum-line.vat-base-buyer-doc
        bfs_tt-allsum-line.vat-rubl-buyer-doc  =  - bf_tt-allsum-line.vat-rubl-buyer-doc
        bfs_tt-allsum-line.slt-base-doc        =  - bf_tt-allsum-line.slt-base-doc
        bfs_tt-allsum-line.slt-rubl-doc        =  - bf_tt-allsum-line.slt-rubl-doc
        bfs_tt-allsum-line.road-tax-base-doc   =  - bf_tt-allsum-line.road-tax-base-doc
        bfs_tt-allsum-line.road-tax-rubl-doc   =  - bf_tt-allsum-line.road-tax-rubl-doc
        bfs_tt-allsum-line.excise-base-doc     =  - bf_tt-allsum-line.excise-base-doc
        bfs_tt-allsum-line.excise-rubl-doc     =  - bf_tt-allsum-line.excise-rubl-doc
        bfs_tt-allsum-line.sum-dsc-base-cur    =  - bf_tt-allsum-line.sum-dsc-base-cur
        bfs_tt-allsum-line.sum-dsc-rubl-cur    =  - bf_tt-allsum-line.sum-dsc-rubl-cur
        bfs_tt-allsum-line.dsc-base-cur        =  - bf_tt-allsum-line.dsc-base-cur
        bfs_tt-allsum-line.dsc-rubl-cur        =  - bf_tt-allsum-line.dsc-rubl-cur
        bfs_tt-allsum-line.vat-base-cur        =  - bf_tt-allsum-line.vat-base-cur
        bfs_tt-allsum-line.vat-rubl-cur        =  - bf_tt-allsum-line.vat-rubl-cur
        bfs_tt-allsum-line.vat-base-buyer-cur  =  - bf_tt-allsum-line.vat-base-buyer-cur
        bfs_tt-allsum-line.vat-rubl-buyer-cur  =  - bf_tt-allsum-line.vat-rubl-buyer-cur
        bfs_tt-allsum-line.slt-base-cur        =  - bf_tt-allsum-line.slt-base-cur
        bfs_tt-allsum-line.slt-rubl-cur        =  - bf_tt-allsum-line.slt-rubl-cur
        bfs_tt-allsum-line.road-tax-base-cur   =  - bf_tt-allsum-line.road-tax-base-cur
        bfs_tt-allsum-line.road-tax-rubl-cur   =  - bf_tt-allsum-line.road-tax-rubl-cur
        bfs_tt-allsum-line.excise-base-cur     =  - bf_tt-allsum-line.excise-base-cur
        bfs_tt-allsum-line.excise-rubl-cur     =  - bf_tt-allsum-line.excise-rubl-cur
        bfs_tt-allsum-line.sum-dsc-base-acc    =  - bf_tt-allsum-line.sum-dsc-base-acc
        bfs_tt-allsum-line.sum-dsc-rubl-acc    =  - bf_tt-allsum-line.sum-dsc-rubl-acc
        bfs_tt-allsum-line.sum-dsc-cli-acc     =  - bf_tt-allsum-line.sum-dsc-cli-acc
        bfs_tt-allsum-line.dsc-base-acc        =  - bf_tt-allsum-line.dsc-base-acc
        bfs_tt-allsum-line.dsc-rubl-acc        =  - bf_tt-allsum-line.dsc-rubl-acc
        bfs_tt-allsum-line.dsc-cli-acc         =  - bf_tt-allsum-line.dsc-cli-acc
        bfs_tt-allsum-line.vat-base-acc        =  - bf_tt-allsum-line.vat-base-acc
        bfs_tt-allsum-line.vat-rubl-acc        =  - bf_tt-allsum-line.vat-rubl-acc
        bfs_tt-allsum-line.vat-cli-acc         =  - bf_tt-allsum-line.vat-cli-acc
        bfs_tt-allsum-line.slt-base-acc        =  - bf_tt-allsum-line.slt-base-acc
        bfs_tt-allsum-line.slt-rubl-acc        =  - bf_tt-allsum-line.slt-rubl-acc
        bfs_tt-allsum-line.slt-cli-acc         =  - bf_tt-allsum-line.slt-cli-acc
        bfs_tt-allsum-line.road-tax-base-acc   =  - bf_tt-allsum-line.road-tax-base-acc
        bfs_tt-allsum-line.road-tax-rubl-acc   =  - bf_tt-allsum-line.road-tax-rubl-acc
        bfs_tt-allsum-line.road-tax-cli-acc    =  - bf_tt-allsum-line.road-tax-cli-acc
        bfs_tt-allsum-line.excise-base-acc     =  - bf_tt-allsum-line.excise-base-acc
        bfs_tt-allsum-line.excise-rubl-acc     =  - bf_tt-allsum-line.excise-rubl-acc
        bfs_tt-allsum-line.excise-cli-acc      =  - bf_tt-allsum-line.excise-cli-acc
        bfs_tt-allsum-line.transport-base-acc  =  - bf_tt-allsum-line.transport-base-acc
        bfs_tt-allsum-line.transport-rubl-acc  =  - bf_tt-allsum-line.transport-rubl-acc
        bfs_tt-allsum-line.transport-cli-acc   =  - bf_tt-allsum-line.transport-cli-acc
        bfs_tt-allsum-line.other-base-acc      =  - bf_tt-allsum-line.other-base-acc
        bfs_tt-allsum-line.other-rubl-acc      =  - bf_tt-allsum-line.other-rubl-acc
        bfs_tt-allsum-line.other-cli-acc       =  - bf_tt-allsum-line.other-cli-acc
        .
    end.
    create bfo_tt-allsum-line.
    assign
      bfo_tt-allsum-line.sum-type = 'сумма_по_услуге':U.
    buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfo_tt-allsum-line.
    create bfos_tt-allsum-line.
    assign
      bfos_tt-allsum-line.sum-type = 'сумма_по_услуге_со_знаком':U.
    buffer-copy bfs_tt-allsum-line except bfs_tt-allsum-line.sum-type to bfos_tt-allsum-line.
  end.
  else do:
    assign
      varlastcur-base      = 0
      varlastcur-road-tax  = 0
      varlastcur-excise    = 0
      varcur-base          = 0
      varcur-road-tax      = 0
      varcur-excise        = 0
      varcur-vat-pc        = 0
      varcur-slt-pc        = 0
      varcur-fact-qnty     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output varb-code
  )  .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0
        varcur-slt-pc = 0
      .
    end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-vat-pc
  ) no-error .
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    v-calcbypart = no.
    if bf_doc-line.whole-send-news = integer('1':U)   then
    v-calcbypart = yes.
    else do:
    for each bf_gds-dtl no-lock
      where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
        and bf_gds-dtl.artic     = bf_doc-line.artic
        and bf_gds-dtl.prod-type = bf_doc-line.prod-type
        and bf_gds-dtl.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varb-code
  ) no-error .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  )  .
          if varprice-sale = ?
          then do:
            assign
              varprice-sale = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
            varlastcur-base     = varprice-sale
            varlastcur-road-tax = varroad-tax
            varlastcur-excise   = varexcise
            varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
            varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
            varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
            varcur-fact-qnty    = varcur-fact-qnty + bf_gds-dtl.fact-qnty
          .
      end.
    end.
    if varcur-fact-qnty = 0 then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base      / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
        varcur-excise    = varcur-excise    / varcur-fact-qnty
      .
    end.
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
    assign
      varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
    if varcur-cons-vat-pc = ? then do:
      return error substitute ("Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code).
    end.
    define buffer buf_tt-clcparts for tt-clcparts .
    for each buf_tt-clcparts
    on error undo, return error return-value
    :
      delete buf_tt-clcparts.
    end.
    for each bf_parts no-lock
      where bf_parts.out-code  = bf_doc-line.doc-code
        and bf_parts.obj-type  = bf_doc-line.obj-type
        and bf_parts.obj-code  = bf_doc-line.obj-code
        and bf_parts.artic     = bf_doc-line.artic
        and bf_parts.prod-type = bf_doc-line.prod-type
        and bf_parts.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
      create buf_tt-clcparts .
      buffer-copy bf_parts to buf_tt-clcparts .
      if v-calcbypart = yes   then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer bf_parts
  ,output v-b-pcode
  ) no-error .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_parts.obj-type
  ,input  bf_parts.obj-code
  ,input  v-b-pcode
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-salef
  ,output varroad-tax
  ,output varexcise
  ) no-error .
          if varprice-sale = ?
          then do:
            assign
              varprice-salef = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
          part-cur-base  = varprice-salef
          part-cur-road-tax  = varroad-tax
          part-cur-excise = varexcise.
      end.
    end.
    run clcprtsl_calc-ttable in this-procedure
      (input yes,
       input yes,
       input bf_doc-line.road-tax,
       input bf_doc-line.excise,
       input bf_doc-line.vat-pc,
       input bf_doc-line.cons-vat-pc,
       input bf_doc-line.slt-pc,
       input bf_trn-doc.base-rate,
       input bf_trn-doc.base-scale,
       input varr-b,
       input varcur-base,
       input varcur-road-tax,
       input varcur-excise,
       input varcur-vat-pc,
       input varcur-cons-vat-pc,
       input varcur-slt-pc
       ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clcprtsl_calc-ttable." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
end.
end.
procedure clcprtsl_calc-ttable :
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcur-road-tax     like ub.doc-line.road-tax    no-undo.
define input parameter parcur-excise       like ub.doc-line.excise      no-undo.
define input parameter parcur-vat-pc       like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define buffer bf_tt-allsum      for tt-allsum.
define buffer bf_tt-clcparts    for tt-clcparts.
define buffer bf_tt-allsum-line for tt-allsum-line.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
do on error undo, return error return-value :
for each bf_tt-allsum-line
on error undo, return error return-value
 :
  delete bf_tt-allsum-line.
end.
for each bf_tt-allsum
on error undo, return error return-value
:
  delete bf_tt-allsum.
end.
for each bf_tt-clcparts
on error undo, return error return-value
:
if v-calcbypart then do:
          assign
          parcur-base =   bf_tt-clcparts.part-cur-base
          parcur-road-tax = bf_tt-clcparts.part-cur-road-tax
          parcur-excise =   bf_tt-clcparts.part-cur-excise
          .
end.
   run clcprtsl_calc-parts in this-procedure (
     input recid(bf_tt-clcparts),
     input paris-doc,
     input paris-cur,
     input parroad-tax,
     input parexcise,
     input parvat-pc,
     input parcons-vat-pc,
     input parslt-pc,
     input parbase-rate,
     input parbase-scale,
     input parr-b,
     input parcur-base,
     input parcur-road-tax,
     input parcur-excise,
     input parcur-vat-pc,
     input parcurcons-vat-pc,
     input parcurslt-pc
     ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info2 skip
      "Ошибка при обсчете партии" skip
      "Документ партии " bf_tt-clcparts.out-code skip
      "Товар" bf_tt-clcparts.artic bf_tt-clcparts.prod-type bf_tt-clcparts.prod-code skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error .
    undo, return error .
  end.
  for each bf_tt-allsum on error undo, return error return-value :
    find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type no-error.
    if not available bf_tt-allsum-line then do:
      create bf_tt-allsum-line.
      assign
        bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type.
    end.
    assign
      bf_tt-allsum-line.fact-qnty              = bf_tt-allsum-line.fact-qnty            + bf_tt-allsum.fact-qnty
      bf_tt-allsum-line.cli-qnty               = bf_tt-allsum-line.cli-qnty             + bf_tt-allsum.cli-qnty
      bf_tt-allsum-line.sum-dsc-base-doc       = bf_tt-allsum-line.sum-dsc-base-doc     + bf_tt-allsum.sum-dsc-base-doc
      bf_tt-allsum-line.sum-dsc-rubl-doc       = bf_tt-allsum-line.sum-dsc-rubl-doc     + bf_tt-allsum.sum-dsc-rubl-doc
      bf_tt-allsum-line.dsc-base-doc           = bf_tt-allsum-line.dsc-base-doc         + bf_tt-allsum.dsc-base-doc
      bf_tt-allsum-line.dsc-rubl-doc           = bf_tt-allsum-line.dsc-rubl-doc         + bf_tt-allsum.dsc-rubl-doc
      bf_tt-allsum-line.vat-base-doc           = bf_tt-allsum-line.vat-base-doc         + bf_tt-allsum.vat-base-doc
      bf_tt-allsum-line.vat-rubl-doc           = bf_tt-allsum-line.vat-rubl-doc         + bf_tt-allsum.vat-rubl-doc
      bf_tt-allsum-line.vat-base-buyer-doc     = bf_tt-allsum-line.vat-base-buyer-doc   + bf_tt-allsum.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-buyer-doc     = bf_tt-allsum-line.vat-rubl-buyer-doc   + bf_tt-allsum.vat-rubl-buyer-doc
      bf_tt-allsum-line.slt-base-doc           = bf_tt-allsum-line.slt-base-doc         + bf_tt-allsum.slt-base-doc
      bf_tt-allsum-line.slt-rubl-doc           = bf_tt-allsum-line.slt-rubl-doc         + bf_tt-allsum.slt-rubl-doc
      bf_tt-allsum-line.road-tax-base-doc      = bf_tt-allsum-line.road-tax-base-doc    + bf_tt-allsum.road-tax-base-doc
      bf_tt-allsum-line.road-tax-rubl-doc      = bf_tt-allsum-line.road-tax-rubl-doc    + bf_tt-allsum.road-tax-rubl-doc
      bf_tt-allsum-line.excise-base-doc        = bf_tt-allsum-line.excise-base-doc      + bf_tt-allsum.excise-base-doc
      bf_tt-allsum-line.excise-rubl-doc        = bf_tt-allsum-line.excise-rubl-doc      + bf_tt-allsum.excise-rubl-doc
      bf_tt-allsum-line.sum-dsc-base-cur       = bf_tt-allsum-line.sum-dsc-base-cur     + bf_tt-allsum.sum-dsc-base-cur
      bf_tt-allsum-line.sum-dsc-rubl-cur       = bf_tt-allsum-line.sum-dsc-rubl-cur     + bf_tt-allsum.sum-dsc-rubl-cur
      bf_tt-allsum-line.dsc-base-cur           = bf_tt-allsum-line.dsc-base-cur         + bf_tt-allsum.dsc-base-cur
      bf_tt-allsum-line.dsc-rubl-cur           = bf_tt-allsum-line.dsc-rubl-cur         + bf_tt-allsum.dsc-rubl-cur
      bf_tt-allsum-line.vat-base-cur           = bf_tt-allsum-line.vat-base-cur         + bf_tt-allsum.vat-base-cur
      bf_tt-allsum-line.vat-rubl-cur           = bf_tt-allsum-line.vat-rubl-cur         + bf_tt-allsum.vat-rubl-cur
      bf_tt-allsum-line.vat-base-buyer-cur     = bf_tt-allsum-line.vat-base-buyer-cur   + bf_tt-allsum.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-buyer-cur     = bf_tt-allsum-line.vat-rubl-buyer-cur   + bf_tt-allsum.vat-rubl-buyer-cur
      bf_tt-allsum-line.slt-base-cur           = bf_tt-allsum-line.slt-base-cur         + bf_tt-allsum.slt-base-cur
      bf_tt-allsum-line.slt-rubl-cur           = bf_tt-allsum-line.slt-rubl-cur         + bf_tt-allsum.slt-rubl-cur
      bf_tt-allsum-line.road-tax-base-cur      = bf_tt-allsum-line.road-tax-base-cur    + bf_tt-allsum.road-tax-base-cur
      bf_tt-allsum-line.road-tax-rubl-cur      = bf_tt-allsum-line.road-tax-rubl-cur    + bf_tt-allsum.road-tax-rubl-cur
      bf_tt-allsum-line.excise-base-cur        = bf_tt-allsum-line.excise-base-cur      + bf_tt-allsum.excise-base-cur
      bf_tt-allsum-line.excise-rubl-cur        = bf_tt-allsum-line.excise-rubl-cur      + bf_tt-allsum.excise-rubl-cur
      bf_tt-allsum-line.sum-dsc-base-acc       = bf_tt-allsum-line.sum-dsc-base-acc     + bf_tt-allsum.sum-dsc-base-acc
      bf_tt-allsum-line.sum-dsc-rubl-acc       = bf_tt-allsum-line.sum-dsc-rubl-acc     + bf_tt-allsum.sum-dsc-rubl-acc
      bf_tt-allsum-line.sum-dsc-cli-acc        = bf_tt-allsum-line.sum-dsc-cli-acc      + bf_tt-allsum.sum-dsc-cli-acc
      bf_tt-allsum-line.dsc-base-acc           = bf_tt-allsum-line.dsc-base-acc         + bf_tt-allsum.dsc-base-acc
      bf_tt-allsum-line.dsc-rubl-acc           = bf_tt-allsum-line.dsc-rubl-acc         + bf_tt-allsum.dsc-rubl-acc
      bf_tt-allsum-line.dsc-cli-acc            = bf_tt-allsum-line.dsc-cli-acc          + bf_tt-allsum.dsc-cli-acc
      bf_tt-allsum-line.vat-base-acc           = bf_tt-allsum-line.vat-base-acc         + bf_tt-allsum.vat-base-acc
      bf_tt-allsum-line.vat-rubl-acc           = bf_tt-allsum-line.vat-rubl-acc         + bf_tt-allsum.vat-rubl-acc
      bf_tt-allsum-line.vat-cli-acc            = bf_tt-allsum-line.vat-cli-acc          + bf_tt-allsum.vat-cli-acc
      bf_tt-allsum-line.slt-base-acc           = bf_tt-allsum-line.slt-base-acc         + bf_tt-allsum.slt-base-acc
      bf_tt-allsum-line.slt-rubl-acc           = bf_tt-allsum-line.slt-rubl-acc         + bf_tt-allsum.slt-rubl-acc
      bf_tt-allsum-line.slt-cli-acc            = bf_tt-allsum-line.slt-cli-acc          + bf_tt-allsum.slt-cli-acc
      bf_tt-allsum-line.road-tax-base-acc      = bf_tt-allsum-line.road-tax-base-acc    + bf_tt-allsum.road-tax-base-acc
      bf_tt-allsum-line.road-tax-rubl-acc      = bf_tt-allsum-line.road-tax-rubl-acc    + bf_tt-allsum.road-tax-rubl-acc
      bf_tt-allsum-line.road-tax-cli-acc       = bf_tt-allsum-line.road-tax-cli-acc     + bf_tt-allsum.road-tax-cli-acc
      bf_tt-allsum-line.excise-base-acc        = bf_tt-allsum-line.excise-base-acc      + bf_tt-allsum.excise-base-acc
      bf_tt-allsum-line.excise-rubl-acc        = bf_tt-allsum-line.excise-rubl-acc      + bf_tt-allsum.excise-rubl-acc
      bf_tt-allsum-line.excise-cli-acc         = bf_tt-allsum-line.excise-cli-acc       + bf_tt-allsum.excise-cli-acc
      bf_tt-allsum-line.transport-base-acc     = bf_tt-allsum-line.transport-base-acc   + bf_tt-allsum.transport-base-acc
      bf_tt-allsum-line.transport-rubl-acc     = bf_tt-allsum-line.transport-rubl-acc   + bf_tt-allsum.transport-rubl-acc
      bf_tt-allsum-line.transport-cli-acc      = bf_tt-allsum-line.transport-cli-acc    + bf_tt-allsum.transport-cli-acc
      bf_tt-allsum-line.other-base-acc         = bf_tt-allsum-line.other-base-acc       + bf_tt-allsum.other-base-acc
      bf_tt-allsum-line.other-rubl-acc         = bf_tt-allsum-line.other-rubl-acc       + bf_tt-allsum.other-rubl-acc
      bf_tt-allsum-line.other-cli-acc          = bf_tt-allsum-line.other-cli-acc        + bf_tt-allsum.other-cli-acc
      .
  end.
end.
end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
procedure plgdsfnd :
  define input  parameter p-chk-and-chs    as logical               no-undo .
  define input  parameter p-obj-type       like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code       like ub.gds-obj.obj-code no-undo .
  define input  parameter p-gds-code       like ub.goods.gds-code   no-undo .
  define output parameter p-reserv-pl-code as   logical             no-undo .
  define output parameter p-pl-code        like ub.pl-gds.pl-code   no-undo .
  define buffer buf_goods         for ub.goods .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_second_pl-gds for ub.pl-gds .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods
  then do:
    return error "Не найден товар. Первичный бар-код " + string( p-gds-code ) .
  end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'place-rsrv=request'
  ,output p-reserv-pl-code
  ) no-error .
  if error-status :error
  then do:
    return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.
  if p-reserv-pl-code = no
  then do:
    return .
  end.
  if p-chk-and-chs <> yes
  then do:
    return .
  end.
  find first buf_pl-gds no-lock where
             buf_pl-gds.obj-type = p-obj-type and
             buf_pl-gds.obj-code = p-obj-code and
             buf_pl-gds.gds-code = p-gds-code no-error .
  if not available buf_pl-gds
  then do:
    return error "К товару не привязано ни одного места хранения" .
  end.
  find first buf_second_pl-gds no-lock where
             buf_second_pl-gds.obj-type  = p-obj-type          and
             buf_second_pl-gds.obj-code  = p-obj-code          and
             buf_second_pl-gds.gds-code  = p-gds-code          and
             recid( buf_second_pl-gds ) <> recid( buf_pl-gds ) no-error .
  if not available buf_second_pl-gds
  then do:
    assign
      p-pl-code = buf_pl-gds.pl-code
    .
  end.
  else do:
    if not valid-handle( parparentproc )
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
    run str/plgdssel.p
      (
         input parparentproc
      ,  input p-obj-type
      ,  input p-obj-code
      ,  input p-gds-code
      , output p-pl-code
      ) no-error .
    if error-status :error
    then do:
      return error substitute( 'Ошибка при вызове программы &1&2&3&2&4&2'
                             , 'plgdssel.p':U
                             , chr(10)
                             , error-status :get-message( 1 )
                             , return-value
                             ) .
    end.
    if p-pl-code = ? or
       p-pl-code = 0
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info21 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info21 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info21 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
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
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info21 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
define temp-table tt-doc-line-sum     no-undo like ub.doc-line-sum.
define temp-table tt-old-doc-line-sum no-undo like tt-doc-line-sum.
define temp-table tt-wast-line        no-undo
  field obj-type            like ub.doc-line.obj-type
  field obj-code            like ub.doc-line.obj-code
  field status_             like ub.doc-line.status_
  field artic               like ub.doc-line.artic
  field prod-type           like ub.doc-line.prod-type
  field prod-code           like ub.doc-line.prod-code
  field fact-order          like ub.doc-line.fact-order
  field prev-inv-fact-order like ub.doc-line.fact-order
  index prev-inv-fact-order      prev-inv-fact-order.
  define new global shared variable g#lib-rwds as handle no-undo.
define new global shared variable g#libtfarh as handle no-undo .
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
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
  define new global shared variable g#lib-rvs as handle no-undo.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info30, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info30, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
def var vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
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
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
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
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
def var vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info36 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info36, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info36, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info36, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info36, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info36 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info36, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info36 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info36, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info36, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info36, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info36, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info36, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info36, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info36 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info36 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info36, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info36, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info36, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info36 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info36 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info36, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info36, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
def var vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
def var vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function getattrUtdex returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
function getattrUtd returns char
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
function setattrUtd returns logical
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
function GetAttrUtdlinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
function GetAttrUtdlines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
function setattrUtdlines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
function GetAttrUtdMarkingLinesEx returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
function GetAttrUtdMarkingLines returns char
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
function setattrUtdMarkingLines returns logical
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info40 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
function GetCodeIdent return character
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
function GetTegCod return character
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
function getlevelByCodId return int
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
function getLevelMotpBycodid return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByLevelMotp return character
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
function getQntyUTDByDM return decimal
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
function getMRC4 return decimal
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
function getMRCByDM return decimal
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
function MoveDate return Date
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
function addGs2Mark return character
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
def var vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function AddUtdErrForTab returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         run gen-key-rec (input iTab,
                          input  iObj,
                          output vRecKey).
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
function AddUtdErr returns logical
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
function ClearUtdErrTypeCode returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
function ClearUtdErr returns logical
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
function GetMesError returns character
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
function GetTextErrorType returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
function GetTypeError returns integer
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
function GetTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
function GetErrForUtdStr returns character
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
function GetErrJsonForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetErrJsonForUtdReturn returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
function GetCodeTextError returns character
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
function GetErrTxtForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
function GetErrForUtd returns character
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
function GetErrComText returns longchar
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
function CheckTypeForMarkLineType returns logical
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
   run gen-key-rec (input "utd-marking-lines",
                    input  iObj,
                    output vRecKey-markLine).
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
function CheckErrForMarkLineType returns logical
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
function CheckErrForMarkLine returns logical
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
function CheckErrForLineTypeCode returns logical
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
function getErrForLineType returns character
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         run gen-key-rec (input "utd-lines",
                          input  iObj,
                          output vRecKey-line).
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
function CheckErrForLineType returns logical
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
function CheckErrForLine returns logical
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
function CheckErrForUtd returns logical
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
function CheckMarkUtd-28rel return logical
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-return
  field db-num as integer
  field doc-id as integer
  field mark like marking.mark
index docid db-num doc-id.
define temp-table tt-prts
  field rec-id-line as recid
  field rec-id as recid
  field doc-code as character
index docid doc-code rec-id.
function  canUtdReturn returns logical
(input idoc-code as character ):
   define variable Vflag as logical no-undo.
   find first trn-doc where trn-doc.doc-code     eq idoc-code
                        and trn-doc.ext-doc-type eq 'ee':U
   no-lock no-error.
   find first utd where utd.doc-code eq trn-doc.doc-code
                    and utd.EDocType eq objSrv:Env:Utd:EDocType:returns:KeyIntDB no-lock no-error.
   if         available trn-doc
      and not available utd
   then
      Vflag = yes.
   return Vflag.
end.
define variable mySeqUtd as int64 no-undo init ?.
procedure MySeqForUtd:
   define input  parameter iTable       as character no-undo.
   define input  parameter iseqnamehist as character no-undo.
   define input  parameter idb-name     as character no-undo.
   define output parameter Oseq         as int64 no-undo.
   if iTable begins "utd"
   then do:
      if myseqUtd eq ?
      then
         myseqUtd = dynamic-next-value(iseqnamehist,idb-name).
      Oseq = myseqUtd.
   end.
   else
      Oseq = ?.
   return.
end.
function  crUtdReturn returns logical
(input idoc-code as character ):
   define buffer trn-doc               for ub.trn-doc.
   define buffer doc-line              for ub.doc-line.
   define buffer parts                 for ub.parts.
   define buffer buf_parts             for ub.parts.
   define buffer goods                 for ub.goods.
   define buffer marking-lines         for ub.marking-lines.
   define buffer marking               for ub.marking.
   define buffer utd                   for ub.utd.
   define buffer Buf_utd               for ub.utd.
   define buffer utd-lines             for ub.utd-lines.
   define buffer Buf_utd-lines         for ub.utd-lines.
   define buffer utd-marking-lines     for ub.utd-marking-lines.
   define buffer Buf_utd-marking-lines for ub.utd-marking-lines.
   define variable vi as integer no-undo.
   define variable vFlag as logical no-undo.
   define variable vdb-num as integer no-undo.
   define variable vdoc-id as integer no-undo.
   define variable vvalue  as character no-undo.
   define variable vType   as character no-undo.
   define variable vUTDReturn as logical no-undo.
   for each  tt-prts:
      delete  tt-prts.
   end.
   find first trn-doc where trn-doc.doc-code     eq idoc-code
                        and trn-doc.ext-doc-type eq 'ee':U
   no-lock no-error.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input trn-doc.doc-code ,
                        input 'edo-return':U ,
                       output vvalue ,
                       output vType ) no-error .
   vUTDReturn = logical(vvalue) no-error.
   if not vUTDReturn
   then
      return no.
   find first utd where utd.doc-code eq trn-doc.doc-code
                    and utd.EDocType eq objSrv:Env:Utd:EDocType:returns:KeyIntDB no-lock no-error.
   if         available trn-doc
      and not available utd
   then do:
      for each doc-line where doc-line.doc-code eq trn-doc.doc-code no-lock,
         each parts where parts.out-code  = doc-line.doc-code
                       and parts.obj-type  = doc-line.obj-type
                       and parts.obj-code  = doc-line.obj-code
                       and parts.artic     = doc-line.artic
                       and parts.prod-type = doc-line.prod-type
                       and parts.prod-code = doc-line.prod-code
      no-lock:
         define variable v-rowid    as rowid no-undo.
         define variable v-tbl-name as character no-undo.
         find first gen-attr where gen-attr.table-name = 'parts':U
                               and gen-attr.p-key      =  "parts"                + chr(3) +
 parts.obj-type           + chr(3) +
 string(parts.obj-code)   + chr(3) +
 parts.artic              + chr(3) +
 parts.prod-type          + chr(3) +
 string(parts.prod-code)  + chr(3) +
 parts.In-code            + chr(3) +
 parts.Out-code           + chr(3) +
 parts.part-Code          + chr(3) +
 string(parts.prt-code)
                               and gen-attr.attr-code  = "in-part-key"
         no-lock no-error.
         if available gen-attr
         then do:
            run gen-row-keyr in this-procedure (
                                           input  gen-attr.attr-value
                                           ,input ?
                                           ,input  "ub"
                                           ,input  ?
                                           ,input  no-lock
                                           ,output v-rowid
                                           ,output v-tbl-name ) .
            find first buf_parts where rowid(buf_parts) eq v-rowid no-lock no-error.
         end.
         create tt-prts.
         assign
            tt-prts.rec-id-line = recid(doc-line)
            tt-prts.rec-id   = recid(parts)
            tt-prts.doc-code = if available  buf_parts then buf_parts.in-code  else ""
         .
         release  buf_parts.
      end.
      subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
      do trans:
         block-part:
         for each tt-prts,
            first doc-line where recid(doc-line) eq tt-prts.rec-id-line no-lock,
            first parts where recid(parts) eq tt-prts.rec-id no-lock
         break by  tt-prts.doc-code by tt-prts.rec-id-line:
            find first goods where goods.artic eq parts.artic
                               and goods.prod-type eq parts.prod-type
                               and goods.prod-code eq parts.prod-code
            no-lock no-error.
            if not available goods
            then do:
               message "Не найден товар по поcтавщику " parts.prod-type  parts.prod-code " с аркиклом "  parts.artic
                  view-as alert-box.
               next block-part.
            end.
            else do:
               if first-of(tt-prts.doc-code)
               then do:
                  if    not  available buf_utd
                        or trn-doc.reason-code ne 23
                  then do:
                     if tt-prts.doc-code <> "" then
                     find first utd where utd.doc-code eq tt-prts.doc-code no-lock no-error.
                     if tt-prts.doc-code <> ""
                        and available utd
                     then do:
                        MySeqUtd = ?.
                        vFlag = yes.
                        create buf_utd.
                        buffer-copy utd  except Timestamp
                                                RevocationStatus
                                                RecipientResponseStatus
                                                ReceiptStatus
                                                ModifyTime
                                                ModifyDate
                                                LoadTime
                                                LoadDate
                                                EDocType
                                                DocumentExt
                                                db-num
                                                doc-id
                                                AdditInfo
                                                doc-code
                                                sts
                        to buf_utd
                        assign
                           buf_utd.parentDocumentExt     = utd.DocumentExt
                           buf_utd.parentOrganizationExt = utd.OrganizationExt
                           buf_utd.doc-code              = trn-doc.doc-code
                           buf_utd.EDocType              = objSrv:Env:Utd:EDocType:returns:KeyIntDB
                           buf_utd.DocumentDate    = today
                           buf_utd.DocumentNumber  = "Возврат № " + trn-doc.doc-code + (if trn-doc.reason-code ne 23 then " по УПД № " + utd.DocumentNumber + " за " + string(utd.DocumentDate,"99/99/9999") else "")
                           buf_utd.Direction       = "Inbound"
                        .
                        validate buf_utd.
                        define variable mTypeUtd as character no-undo.
                        if   trn-doc.reason-code eq 23
                        then assign
                          buf_utd.PackageId = ""
                          mTypeUtd = "СЧФДОП"
                        .
                        else if trn-doc.reason-code eq 25
                        then
                           mTypeUtd = "ДОП".
                        else
                           mTypeUtd = "".
                        if   mTypeUtd ne ""
                        then
                           setattrutd (buf_utd.db-num,buf_utd.doc-id,"TypeUTD",mTypeUtd).
                        buf_utd.sts             = ObjSrv:Env:Utd:Sts:th:newstatus:KeyIntDB.
                        Buf_utd.sts-edi               = if utd.AmendmentRequested
                                                        then ObjSrv:Env:Utd:Sts:edi:AvailAdjustment:KeyIntDB
                                                        else ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB.
                        assign
                           vdb-num = Buf_utd.db-num
                           vdoc-id = Buf_utd.doc-id
                           vi      = 0
                        .
                     end.
                     else do:
                        MySeqUtd = ?.
                        vFlag = yes.
                        create buf_utd.
                        assign
                           buf_utd.contract-code   = parts.contract-code
                           buf_utd.doc-code        = trn-doc.doc-code
                           buf_utd.DocumentDate    = today
                           buf_utd.DocumentNumber  = "Возврат № " + trn-doc.doc-code + " по накладной " + parts.in-code
                           buf_utd.EDocType        = objSrv:Env:Utd:EDocType:returns:KeyIntDB
                           buf_utd.host-code       = parts.host-code
                           buf_utd.obj-type        = parts.obj-type
                           buf_utd.obj-code        = parts.obj-code
                           buf_utd.cli-type        = trn-doc.cli-type
                           buf_utd.cli-code        = trn-doc.cli-code
                        .
                        validate buf_utd.
                        if   trn-doc.reason-code eq 23
                        then assign
                           buf_utd.PackageId = ""
                           mTypeUtd = "СЧФДОП"
                        .
                        else if trn-doc.reason-code eq 25
                        then
                           mTypeUtd = "ДОП".
                        else
                           mTypeUtd = "".
                        if   mTypeUtd ne ""
                        then
                           setattrutd (buf_utd.db-num,buf_utd.doc-id,"TypeUTD",mTypeUtd).
                        buf_utd.sts             = ObjSrv:Env:Utd:Sts:th:newstatus:KeyIntDB.
                        Buf_utd.sts-edi         = ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB.
                        assign
                           vdb-num = Buf_utd.db-num
                           vdoc-id = Buf_utd.doc-id
                           vi      = 0
                        .
                     end.
                  end.
               end.
               if first-of(tt-prts.rec-id-line)
               then do:
                  find first gds-dtl where gds-dtl.doc-code  = doc-line.doc-code
                                       and gds-dtl.artic     = doc-line.artic
                                       and gds-dtl.prod-code = doc-line.prod-code
                                       and gds-dtl.prod-type = doc-line.prod-type
                  no-lock no-error.
                  create buf_utd-lines.
                  assign
                     vi                      = vi + 1
                     buf_utd-lines.Article   = parts.artic
                     buf_utd-lines.db-num    = buf_utd.db-num
                     buf_utd-lines.doc-id    = buf_utd.doc-id
                     buf_utd-lines.LineNum   = vi
                     buf_utd-lines.gds-code     = goods.gds-code
                     buf_utd-lines.ProductCode  = goods.gds-name
                     buf_utd-lines.Quantity     = if available gds-dtl then gds-dtl.fact-qnty  else doc-line.fact-qnty
                     buf_utd-lines.TaxRate      = doc-line.VAT-pc
                     buf_utd-lines.Total        = (if available gds-dtl then gds-dtl.price-rubl else doc-line.price-rubl) * buf_utd-lines.Quantity
                     buf_utd-lines.UnitCode     = goods.unit-base
                     buf_utd-lines.Vat          = buf_utd-lines.Total * buf_utd-lines.TaxRate / (100 + buf_utd-lines.TaxRate)
                     buf_utd-lines.TotalWithVatExcluded = buf_utd-lines.Total  - buf_utd-lines.Vat
                     buf_utd-lines.Price                = buf_utd-lines.TotalWithVatExcluded / buf_utd-lines.Quantity
                  .
               end.
               else do:
                  find first buf_utd-lines where buf_utd-lines.db-num    = buf_utd.db-num
                                             and buf_utd-lines.doc-id    = buf_utd.doc-id
                                             and buf_utd-lines.LineNum   = vi
                  no-lock.
               end.
               for each marking-lines where marking-lines.gds-code   = goods.gds-code
                                        and marking-lines.obj-type   = parts.obj-type
                                        and marking-lines.obj-code   = parts.obj-code
                                        and marking-lines.in-code    = parts.in-code
                                        and marking-lines.out-code   = parts.out-code
                                        and marking-lines.part-code  = parts.part-code
                                        and marking-lines.doc-level  = 1
               no-lock:
                  create buf_utd-marking-lines.
                  assign
                     buf_utd-marking-lines.db-num     = buf_utd.db-num
                     buf_utd-marking-lines.doc-id     = buf_utd.doc-id
                     buf_utd-marking-lines.site       = "-"
                     buf_utd-marking-lines.doc-level  = marking-lines.doc-level
                     buf_utd-marking-lines.gds-code   = goods.gds-code
                     buf_utd-marking-lines.LineNum    = buf_utd-lines.LineNum
                     buf_utd-marking-lines.mark       = marking-lines.mark
                     buf_utd-marking-lines.sts        = marking-lines.sts
                  .
                  if buf_utd-marking-lines.doc-level eq 1
                  then
                     AddUtdErr(buf_utd.db-num,buf_utd.doc-id,buffer buf_utd-marking-lines:handle,"return","Mark",marking-lines.mark + chr(4) + buf_utd-lines.ProductCode).
                  release buf_utd-marking-lines.
               end.
               if last-of(tt-prts.rec-id-line)
               then do:
                  release buf_utd-lines.
               end.
               if last-of(tt-prts.doc-code)
               then do:
                  buf_utd.Total = 0.
                  buf_utd.Vat   = 0.
                  for each buf_utd-lines where buf_utd-lines.db-num eq buf_utd.db-num
                                        and buf_utd-lines.doc-id eq buf_utd.doc-id
                  no-lock:
                     buf_utd.Total = buf_utd.Total + buf_utd-lines.Total.
                     buf_utd.Vat   = buf_utd.Vat   + buf_utd-lines.Vat.
                  end.
                  if trn-doc.reason-code ne 23
                  then
                     release buf_utd.
               end.
            end.
         end.
      end.
      release buf_utd.
      unsubscribe "getNextseq".
      for each buf_utd where buf_utd.doc-code eq trn-doc.doc-code
                         and buf_utd.EDocType eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
      exclusive-lock:
         if    buf_utd.CounteragentId  eq ?
            or buf_utd.CounteragentId  eq ""
            or buf_utd.OrganizationExt eq ?
            or buf_utd.OrganizationExt eq ""
         then
            buf_utd.sts             = ObjSrv:Env:Utd:Sts:th:RequireFilling:KeyIntDB.
         else
            buf_utd.sts             = ObjSrv:Env:Utd:Sts:th:SignatureRequired:KeyIntDB.
      end.
   end.
   for each  tt-prts:
      delete  tt-prts.
   end.
   return vFlag.
end.
define variable vss-include-info43 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_fbr-history no-undo like ub.fbr-history .
define variable v-fbrhist-history-level     as integer      no-undo.
define variable v-fbrhist-upper-obj-type    as character    no-undo.
define variable v-fbrhist-upper-obj-code    as integer      no-undo.
define variable v-fbrhist-upper-code        as integer      no-undo.
define variable v-fbrhist-current-obj-type  as character    no-undo.
define variable v-fbrhist-current-obj-code  as integer      no-undo.
define variable v-fbrhist-current-code      as integer      no-undo.
define variable v-fbrhist-saved-obj-type    as character    no-undo.
define variable v-fbrhist-saved-obj-code    as integer      no-undo.
define variable v-fbrhist-saved-code        as integer      no-undo.
procedure fbrhist-write :
define input parameter p-userid                 as character        no-undo.
define input parameter p-obj-type               as character        no-undo.
define input parameter p-obj-code               as integer          no-undo.
define input parameter p-hst-type               as character        no-undo.
define input parameter p-hst-level              as integer          no-undo.
define input parameter p-procedure-name         as character        no-undo.
define input parameter p-procedure-parameters   as character        no-undo.
define input parameter p-doc-code               as character        no-undo.
define input parameter p-doc-type               as character        no-undo.
define input parameter p-status_                as character        no-undo.
define input parameter p-is-free                as logical          no-undo.
define input parameter p-recipe-code            as character        no-undo.
define input parameter p-recipe-type            as character        no-undo.
define input parameter p-gds-code               as integer          no-undo.
define input parameter p-trn-type               as character        no-undo.
define input parameter p-qnty                   as decimal          no-undo.
define input parameter p-PS                     as character        no-undo.
define input parameter p-is-error               as logical          no-undo.
    define variable v-today                         as date         no-undo.
    define variable v-obj-date                      as date         no-undo.
    define variable v-time                          as integer      no-undo.
    define variable v-host-code                     as integer      no-undo.
    define variable v-db-num                        as integer      no-undo.
    define buffer buf_temp_fbr-history       for temp_fbr-history.
    define buffer buf_upper_temp_fbr-history for temp_fbr-history.
do
for buf_temp_fbr-history
  , buf_upper_temp_fbr-history
on error undo, return error
:
    if v-fbrhist-history-level = 0
    or v-fbrhist-history-level < p-hst-level
    then do:
        undo, return .
    end.
    if v-fbrhist-upper-code <> 0
    then do:
        find first buf_upper_temp_fbr-history no-lock
             where buf_upper_temp_fbr-history.obj-type = v-fbrhist-upper-obj-type
               and buf_upper_temp_fbr-history.obj-code = v-fbrhist-upper-obj-code
               and buf_upper_temp_fbr-history.hst-code = v-fbrhist-upper-code
        no-error.
    end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-date
  )  .
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
    create buf_temp_fbr-history.
    assign
        buf_temp_fbr-history.obj-type                = p-obj-type
        buf_temp_fbr-history.obj-code                = p-obj-code
        buf_temp_fbr-history.hst-code                = next-value( s-fbr-num, ub)
        buf_temp_fbr-history.hst-type                = p-hst-type
        buf_temp_fbr-history.hst-level               = p-hst-level
        buf_temp_fbr-history.hst-upper-code          = v-fbrhist-upper-code
        buf_temp_fbr-history.procedure-name          = p-procedure-name
        buf_temp_fbr-history.procedure-parameters    = p-procedure-parameters
        buf_temp_fbr-history.doc-code                = p-doc-code
        buf_temp_fbr-history.doc-type                = p-doc-type
        buf_temp_fbr-history.status_                 = p-status_
        buf_temp_fbr-history.is-free                 = p-is-free
        buf_temp_fbr-history.recipe-code             = p-recipe-code
        buf_temp_fbr-history.recipe-type             = p-recipe-type
        buf_temp_fbr-history.gds-code                = p-gds-code
        buf_temp_fbr-history.trn-type                = p-trn-type
        buf_temp_fbr-history.qnty                    = p-qnty
        buf_temp_fbr-history.PS                      = p-ps
        buf_temp_fbr-history.is-error                = p-is-error
        buf_temp_fbr-history.db-num                  = v-db-num
        buf_temp_fbr-history.user-name               = p-userid
        buf_temp_fbr-history.sys-date                = v-today
        buf_temp_fbr-history.sys-time-int            = v-time
        buf_temp_fbr-history.sys-time                = string( v-time, "HH:MM:SS" )
        buf_temp_fbr-history.obj-date                = v-obj-date
        buf_temp_fbr-history.host-code               = v-host-code
    .
    assign
        v-fbrhist-current-obj-type                   = p-obj-type
        v-fbrhist-current-obj-code                   = p-obj-code
        v-fbrhist-current-code                       = buf_temp_fbr-history.hst-code
    .
    if available buf_upper_temp_fbr-history
    then do:
        assign
            buf_temp_fbr-history.hst-node-path = buf_temp_fbr-history.hst-node-path
                    + chr(2)  + string( buf_temp_fbr-history.obj-type )
                                            + "-":U + string( buf_temp_fbr-history.obj-code )
                                            + "-":U + string( buf_temp_fbr-history.hst-code )
        .
    end.
    else do:
        assign
            buf_temp_fbr-history.hst-node-path = string( buf_temp_fbr-history.obj-type )
                               + "-":U + string( buf_temp_fbr-history.obj-code )
                               + "-":U + string( buf_temp_fbr-history.hst-code )
        .
    end.
end.
end procedure.
procedure fbrhist-read-conf :
do
on error undo, return error
:
   define variable v-value-character as character  no-undo .
   define variable v-value-date      as date       no-undo .
   define variable v-value-decimal   as decimal    no-undo .
   define variable v-value-logical   as logical    no-undo .
   define variable v-tth             as handle     no-undo .
   define variable v-param-type            as character no-undo .
   run adm/shattri.p ( input "get":U
                     , input  '':u
                     , input  0
                     , input  'fbrattr':U
                     , input  'fbrhstlv':U
                     , output v-value-character
                     , output v-value-date
                     , output v-value-decimal
                     , output v-fbrhist-history-level
                     , output v-value-logical
                     , output v-param-type
                     , input-output table-handle v-tth
                     ) no-error .
   if error-status :error then do:
      assign
         v-fbrhist-history-level = 0
      .
   end.
end.
end procedure.
procedure fbrhist-table-to-base :
    define buffer buf_fbr-history       for ub.fbr-history.
    define buffer buf_temp_fbr-history  for temp_fbr-history.
do
for buf_fbr-history
  , buf_temp_fbr-history
on error undo, return error
:
    for each buf_temp_fbr-history
    on error undo, return error
    :
        create buf_fbr-history.
        buffer-copy buf_temp_fbr-history to buf_fbr-history.
    end.
end.
end procedure.
procedure fbrhist-init :
    define buffer buf_temp_fbr-history      for temp_fbr-history.
do
for buf_temp_fbr-history
on error undo, return error
:
    for each buf_temp_fbr-history
    :
        delete buf_temp_fbr-history.
    end.
    assign
        v-fbrhist-upper-obj-type    = ""
        v-fbrhist-upper-obj-code    = 0
        v-fbrhist-upper-code        = 0
        v-fbrhist-current-obj-type  = ""
        v-fbrhist-current-obj-code  = 0
        v-fbrhist-current-code      = 0
        v-fbrhist-saved-obj-type    = ""
        v-fbrhist-saved-obj-code    = 0
        v-fbrhist-saved-code        = 0
    .
end.
end procedure.
procedure fbrhist-set-upper-code :
do
on error undo, return error
:
    assign
        v-fbrhist-upper-obj-type    = v-fbrhist-current-obj-type
        v-fbrhist-upper-obj-code    = v-fbrhist-current-obj-code
        v-fbrhist-upper-code        = v-fbrhist-current-code
    .
end.
end procedure.
procedure fbrhist-save-current-code :
do
on error undo, return error
:
    assign
        v-fbrhist-saved-obj-type    = v-fbrhist-current-obj-type
        v-fbrhist-saved-obj-code    = v-fbrhist-current-obj-code
        v-fbrhist-saved-code        = v-fbrhist-current-code
    .
end.
end procedure.
procedure fbrhist-set-upper-from-saved-code :
do
on error undo, return error
:
    assign
        v-fbrhist-upper-obj-type    = v-fbrhist-saved-obj-type
        v-fbrhist-upper-obj-code    = v-fbrhist-saved-obj-code
        v-fbrhist-upper-code        = v-fbrhist-saved-code
    .
end.
end procedure.
procedure fbrhist-set-zero-upper-code :
do
on error undo, return error
:
    assign
        v-fbrhist-upper-obj-type    = ""
        v-fbrhist-upper-obj-code    = 0
        v-fbrhist-upper-code        = 0
    .
end.
end procedure.
define temp-table tt-fbr-line no-undo
  field num as integer
  field gds-code as integer
  field gds-name as character
  field qnty as decimal
  field ingr-qnty as decimal
  field recipe-code like ub.recipe.recipe-code
  field recipe-type like ub.recipe.recipe-type
  field ingr-gds-code as integer
  field unit as character
  field mark-weight as decimal
  field weighed as logical
.
define temp-table tt-utd like ub.utd
  field stts        as character
  field stts-edi    as character
  field cli-name    as character
  field EDoTypeName as character
  field ModifyTime_ as character
  field orig-code   as character
  field GrayZone    as logical
  field obj-name    as character
  field is-initial  as character
  field scan-qnty   as decimal
  field free-qnty   as decimal
  .
define temp-table tt-sert-utd
  field doc-id like ub.utd.doc-id
  field db-num like ub.utd.db-num
  field DocumentDate like ub.utd.DocumentDate
  field DocumentNumber like ub.utd.DocumentNumber
  field cli-code as integer
  field cli-type as character
  index pi  db-num doc-id
  .
define temp-table tt-utd-lines-filtr no-undo
    field db-num  as integer
    field doc-id  as integer
    field linenum as integer
    field bar-code as character
    index pi  db-num doc-id LineNum
    index bar-code bar-code db-num doc-id LineNum
.
define temp-table tt-utd-lines like ub.utd-lines
  field qnty-scan as decimal
  field qnty-mark as integer
  field stts      as character
  field gds-name  as character
  field TaxRate_  as character
  field fact-qnty as decimal
  field free-qnty as decimal
  field sts_err   as logical
  field DelivCodeMis   as logical
  field UnitCli   as character
  field UnitCliQnty as decimal
  field isMarking   as logical
  field isArtic     as logical
  field isWeight    as logical
  field isVarWeight as logical
  field isSelect    as logical
  field markType    as character
  field PieceTTH    as character
  field PieceFact   as character
  index pi  db-num doc-id LineNum
  index gds-code gds-code
  index sts stts sts
  .
define temp-table tt-marking-lines no-undo like ub.marking-lines
  field mark-parent like ub.marking.mark-parent
  field stts        as character
  field sts-utd     as integer
  field stts-utd    as character
  field unit        as character
  field unit-ext    as character
  field site        as character
  field box-qnty    as decimal
  field gds-name    as character
  field db-num      as integer
  field doc-id      as integer
  field LineNum     as integer
  field GrayZone    as logical
  field isMark      as logical
  field isWeight    as logical
  field marking-string as character
  field old-sts     as integer
  field weight      as character
  index pi  doc-level   sts
  index pi2 mark-parent sts
  index pi3 unit-ext
  index pi4 mark obj-type obj-code gds-code in-code out-code part-code prt-code
  index part gds-code obj-type obj-code in-code out-code part-code prt-code
  index gds-code gds-code
  index obj obj-code obj-type
  .
define temp-table tt-mark-line like ub.marking-lines
  field date_    as date
  field doc-type as character
  field type     as integer
  field doc-id   as integer
  field db-num   as integer
  field EdocType as integer
  index pi mark out-code doc-type .
define temp-table tt-marking like ub.marking
  .
define temp-table tt-utd-marking-lines like ub.utd-marking-lines
  .
define temp-table tt-inv-marking no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty          as decimal
  field qnty-scan     as decimal
  field qnty-confirm  as integer
  field qnty-scan-not as integer
  field qnty-not      as integer
  index pi gds-code
  .
define temp-table tt-tech-mark no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty-fact     as integer
  field qnty-doc      as integer
  field doc-code      as character
  field line-num      as integer
  index pi as UNIQUE doc-code line-num gds-code
  .
define temp-table tt-utd-err like ub.utd-err
  field descr as character
  field gds-code as integer
  field LineNum  as integer
  field type     as integer
  .
def var vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function CheckMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.
function CheckNotMarkUtd return logical
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
function CheckMarkUtdLine return logical
 (input idb-num  as integer,
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
         end.
      end.
   end.
   return vMarking or vArtic.
end.
function getMarkUtdLine return logical
 (input  idb-num  as integer,
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.
function CheckMarking return logical
 (input idb-num as integer,
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:
         for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.
      end.
   end.
   return vCrErr.
end.
function CheckMarkForType return logical
 (input idb-num   as integer,
  input idoc-id   as integer):
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
      for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else do:
         end.
      end.
   end.
end.
function WeighedProd return logical
   ( input p-gds-code as integer) :
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
           if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'weighed-gds':U,
               output v-par-val,
               output v-par-type
            ).
   return logical(v-par-val).
end.
function WghProdVariable return logical
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
        ( p-gds-code,
          'weighed-gds':U,
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
            ( p-gds-code,
              'mark-type':U,
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.
function MarkWeight return decimal
   ( input p-mark as character) :
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   vMarkWeight = 0.
   if p-mark <> "" and p-mark <> ?
   then do:
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).
   end.
   return vMarkWeight.
end.
define output parameter table for gds-list.
define buffer bf_trn-doc      for ub.trn-doc.
define buffer bf2_trn-doc     for ub.trn-doc.
define buffer exp_trn-doc     for ub.trn-doc.
define buffer in_trn-doc      for ub.trn-doc.
define buffer bf_goods        for ub.goods.
define buffer bf_doc-line     for ub.doc-line.
define buffer bf2_doc-line    for ub.doc-line.
define buffer in_doc-line     for ub.doc-line.
define buffer bf_inv-line     for ub.inv-line.
define buffer bf_clients      for ub.clients.
define buffer bf_pay-type     for ub.pay-type.
define buffer bf_doc-pl       for ub.doc-pl.
define buffer bf_gds-dtl      for ub.gds-dtl.
define buffer bf_currency     for ub.currency.
define buffer bf_parts        for ub.parts.
define buffer bf-cst_parts    for ub.parts.
define buffer bf_gds-prt      for ub.gds-prt.
define buffer bf_dis-card     for ub.dis-card.
define buffer bf_rvs-doc      for ub.rvs-doc.
define buffer bf_rvs-line     for ub.rvs-line.
define buffer bf_store        for ub.store.
define buffer bf_contract     for ub.contract.
define buffer buf_contract-attr for ub.contract-attr.
define buffer ret-doc         for ub.trn-doc.
define buffer old-line        for ub.doc-line.
define buffer ret-dtl         for ub.gds-dtl.
define buffer old-doc         for ub.trn-doc.
define buffer exp-dtl         for ub.gds-dtl.
define buffer c-in            for ub.trn-doc.
define buffer bf-cnt_parts    for ub.parts.
define buffer bf_fin-ob-trn   for ub.fin-ob-trn.
define buffer bf_doc-line-attr  for ub.doc-line-attr.
define buffer buf_doc-attr      for ub.doc-attr.
define buffer buf_cash-pay      for ub.cash-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer bf_utd            for ub.utd.
define buffer bf_utd-l          for ub.utd-lines.
define buffer sep_auto-tank-attr  for ub.auto-tank-attr.
define variable inv-shipvalue                as   logical                     no-undo.
define variable par-gen-mrgn-ie              as   character                   no-undo.
define variable par-gen-mrgn-iv              as   character                   no-undo.
define variable par-gen-mrgn-im              as   character                   no-undo.
define variable par-gen-mrgn-ie-parts        as   character                   no-undo.
define variable par-gen-mrgn-iv-parts        as   character                   no-undo.
define variable par-gen-mrgn-im-parts        as   character                   no-undo.
define variable is-add-charg                 as   character                   no-undo .
define variable varrnd-znk                   as   character initial ?         no-undo.
define variable varrnd-type                  as   character initial ?         no-undo.
define variable clsreserv-pl-code            as   logical                     no-undo.
define variable clspl-code                   like ub.place.pl-code            no-undo.
define variable fact-ok                      as   logical initial yes         no-undo.
define variable varstatus                    like ub.trn-doc.status_          no-undo.
define variable varflag                      like ub.trn-doc.flag_            no-undo.
define variable varoldstatus                 like ub.trn-doc.status_          no-undo.
define variable varoldflag                   like ub.trn-doc.flag_            no-undo.
define variable varcopystatus                like ub.trn-doc.status_          no-undo.
define variable varcopyflag                  like ub.trn-doc.flag_            no-undo.
define variable is-ok                        as   logical                     no-undo.
define variable is-no                        as   logical                     no-undo.
define variable varis-petrol                 as   logical                     no-undo.
define variable varis-pieces                 as   logical                     no-undo.
define variable is-custmvalue                as   character                   no-undo.
define variable is-custmtype                 as   character                   no-undo.
define variable v-today                      as   date                        no-undo.
define variable v-user-action                as   character                   no-undo.
define variable v-printed                    as   logical                     no-undo.
define variable varfact-order                like ub.trn-doc.fact-order       no-undo.
define variable varznak                      as   integer initial -1          no-undo.
define variable varchk-prs                   as   logical                     no-undo.
define variable varchk-prs-type              as   character                   no-undo.
define variable varmy-obj                    as   logical                     no-undo.
define variable varlns-cnt                   as   integer                     no-undo.
define variable lns-cnt                      as   integer                     no-undo.
define variable line-rec                     as   recid                       no-undo.
define variable varnocurbas                  as   character                   no-undo.
define variable varnocurbas-type             as   character                   no-undo.
define variable varprt-b-code                like ub.bar-code.b-code          no-undo.
define variable vardoc-num                   like ub.price-list.doc-num       no-undo.
define variable varprice-sale                like ub.price-list.price-sale    no-undo.
define variable varroad-tax                  like ub.price-list.road-tax      no-undo.
define variable varexcise                    like ub.price-list.excise        no-undo.
define variable varlog                       as   logical                     no-undo.
define variable varcount                     as   integer                     no-undo.
define variable vartime                      as   integer                     no-undo.
define variable l-in-ov                      as   logical                     no-undo.
define variable varcontract                  as   logical                     no-undo.
define variable varcontract-type             as   character                   no-undo.
define variable is-recalc                    as   logical                     no-undo.
define variable varcontract-code             like ub.contract.contract-code   no-undo.
define variable varr-b                       as   character                   no-undo.
define variable varobj-shift-date            as   date                        no-undo.
define variable varobj-shift-num             as   integer                     no-undo.
define variable varobj-shift-name            as   character                   no-undo.
define variable varhold-doc                  as   logical                     no-undo.
define variable vartpsi                      as   character                   no-undo.
define variable vartpsi-type                 as   character                   no-undo.
define variable is-fin                       as   character                   no-undo.
define variable parcontract-code             as   character                   no-undo.
define variable parcontract-type             as   character                   no-undo.
define variable p-status                     as   date                        no-undo .
define variable varminus-parts               as   logical                     no-undo .
define variable varminus-parts-type          as   character                   no-undo.
define variable varerr                       as   logical                     no-undo.
define variable v-mess                       as character                     no-undo .
define variable conf-attr                    as   character                   no-undo.
define variable conf-par                     as   character                   no-undo.
define variable vartechproliv                as   logical                     no-undo.
define variable ii                           as   integer                     no-undo.
define variable v-entry                      as   character                   no-undo.
define variable v-doc-kind                   as   character                   no-undo.
define variable v-obj-type                   as   character                   no-undo.
define variable v-obj-code                   as   integer                     no-undo.
define variable v-tth             as handle no-undo .
define variable v-tth-contr       as handle no-undo .
define variable v-kol-doc as integer   no-undo .
define variable v-is-add-doc as logical   no-undo init false  .
define variable v-reasonm as logical   no-undo init false .
define variable v-reasonme as character no-undo .
define variable v-reasons-for-return as character no-undo .
define variable v-attr-mandat-wayb  as character no-undo .
define variable v-attr-dop-info  as character no-undo .
define variable v-is-ord-doc as logical   no-undo init false .
define variable v-event-code as character no-undo .
define variable v-is-hold as logical   no-undo .
define variable v-is-negostmess as logical   no-undo .
define variable v-curr-db-num like ub.db.db-num no-undo .
define variable v-curr-userid as character no-undo .
define variable varprice-check               as   decimal                     no-undo.
define variable v-not_ver-spec               as   logical                     no-undo.
define variable varvat-type                  as   character                   no-undo.
define variable var-host-code                like ub.trn-doc.contract-code    no-undo.
define variable varinv-prs     as character no-undo.
define variable varinv-prstype as character no-undo.
define variable v-attr-value   as character no-undo.
define variable v-attr-type    as character no-undo.
define variable v-is-foreign-producer as logical no-undo.
define variable p-cons        as integer no-undo .
define variable v-iskp              as logical no-undo .
define variable v-kpsecs       as character no-undo.
define variable v-needsavesec  as logical no-undo.
define variable v-vid-action        as integer no-undo .
define variable v-vid-param         as longchar no-undo .
define variable v-initiator  as character no-undo.
case true:
  when g#auto then v-initiator = "Auto".
  when g#news then v-initiator = "Nws".
  when g#esys then v-initiator = "Esys".
  otherwise v-initiator = "User".
end case.
define temp-table tt-trn no-undo like ub.trn-doc.
define variable res        as character no-undo .
define variable infoSectionsTotal as class InfoSectionsTotal no-undo.
define variable vsdSubsObj as class vsdsubs no-undo.
define variable vsdSubCurr as class vsdsub no-undo.
define variable vsdSts as class vsdstatustype no-undo.
define variable vsdStr as class vsdtostorage no-undo.
define variable keyrecObj as class keyrec no-undo.
define variable v-error-attr  as character no-undo .
define variable is-fuel          as   character            no-undo.
def var isFuel as logical no-undo init false.
define variable parisfueltype    as   character            no-undo.
define variable v-valuetype    as   character            no-undo.
define variable v-value        as   character            no-undo.
define variable v-show-str       as character no-undo .
define variable v-add-nat-gas    as logical no-undo .
define variable var-is-auto-trn  as logical no-undo .
define variable v-return-qnty    as decimal no-undo .
define variable varvalue                    as   character              no-undo.
define variable vartype                     as   character              no-undo.
define variable stfactplvalue as character no-undo.
define variable stfactpltype as character no-undo.
define variable varupd-fact-qnty       as logical      no-undo initial yes .
define variable varrevision            as logical      no-undo initial no  .
define variable varpercrev             as decimal      no-undo initial ?   .
define variable varauto-tank           as logical      no-undo initial no  .
define variable varpercauto            as decimal      no-undo initial ?   .
define variable varinv                 as logical      no-undo initial no  .
define variable varpercinv             as decimal      no-undo initial ?   .
define variable varinv-set             as logical      no-undo initial no  .
define variable v-mercury-value as character no-undo .
define variable v-mercury-type  as character no-undo .
define variable v-mercury-prod as logical init false.
define variable keypart as character init false.
define variable v-close as logical.
define variable v-expense-return as logical no-undo init false .
define temp-table tt-no-marking-gds no-undo
  field artic as character label "Артикул"
  field gds-name as character label "Имя"
  field qnty as character label "Кол-во"
.
define stream str-err.
  vartime = time.
do transaction
on error undo, return error return-value
:
  v-show-str = substitute ( '&1 документа "&2"',
    (if parmode = '<открытие документа>':U then "Открытие" else "Закрытие"),
    pardoc-code
  ) .
  run waitfram-show in this-procedure ( v-show-str ) no-error.
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-error.
  if not available bf_trn-doc
  then do:
    run waitfram-hide in this-procedure no-error.
    return error substitute( 'Не найден документ с номером "&1".', pardoc-code ).
  end.
  if bf_trn-doc.status_ = 'факт':U
  or bf_trn-doc.status_ = 'готов':U
  or bf_trn-doc.status_ = 'отказ':U
  then do:
    run waitfram-hide in this-procedure no-error.
    return error substitute( 'Документ "&1" в статусе "&2". Операции с ним невозможны.'
                          , bf_trn-doc.doc-code
                          , bf_trn-doc.status_ ).
  end.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
if valid-handle(parparentproc)
  and lookup( "get-db-num":U, parparentproc:internal-entries ) > 0
  and lookup( "get-userid":U, parparentproc:internal-entries ) > 0
then do:
  run get-db-num in parparentproc
    ( output v-curr-db-num
    ) .
  run get-userid in parparentproc
    ( output v-curr-userid
    ) .
end.
else do:
  assign
    v-curr-db-num = ibs.th.gbl.gbl-var:g#db-num
    v-curr-userid = ibs.th.gbl.gbl-var:g#userid
  .
end.
assign
  varoldstatus = bf_trn-doc.status_
  varoldflag = bf_trn-doc.flag_
  .
define variable v-trn-doc-code as character no-undo .
v-trn-doc-code = replace( bf_trn-doc.doc-code, "*", "$" ) .
if search( v-trn-doc-code + ".err" ) <> ?
then do:
  os-delete value( v-trn-doc-code + ".err" ).
 if bf_trn-doc.ext-doc-type = 'vt':U
 then do:
    os-delete value(v-trn-doc-code + "-чеки.err").
  end.
end.
var-is-auto-trn = false.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'is-auto-trn':U ,
                       output v-value ,
                       output v-valuetype ) no-error .
assign
  var-is-auto-trn = yes when v-value = "yes".
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplmrgn in g#library2
  (input  parparentproc
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output par-gen-mrgn-ie
  ,output par-gen-mrgn-iv
  ,output par-gen-mrgn-im
  ) no-error .
   if error-status :error then do:
      run waitfram-hide in this-procedure no-error.
      return error substitute( 'На объекте &1 &2  не определен ГТПЛ для автопереоценок.'
                                ,bf_trn-doc.obj-type
                                ,bf_trn-doc.obj-code
                              ).
   end.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partmrgn in g#library2
  (input  parparentproc
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output par-gen-mrgn-ie-parts
  ,output par-gen-mrgn-iv-parts
  ,output par-gen-mrgn-im-parts
  ) no-error .
   if error-status :error then do:
      run waitfram-hide in this-procedure no-error.
      return error substitute( 'На объекте &1 &2  не определен ГТПЛ для автопереоценок.'
                                ,bf_trn-doc.obj-type
                                ,bf_trn-doc.obj-code
                              ).
   end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
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
    if thbjattr_thbj-attr.prop-code = 'nocurbas':U  then varnocurbas = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'rnd-znk':U   then varrnd-znk = string(thbjattr_thbj-attr.property-value-integer) .
    if thbjattr_thbj-attr.prop-code = 'chk-prs':U   then varchk-prs     = thbjattr_thbj-attr.property-value-logical .
end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'is-fuel':U ,
                       output is-fuel ,
                       output parisfueltype ) no-error .
assign
  isFuel = yes when is-fuel = "yes".
if not isFuel then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'is-lgas':U ,
                       output is-fuel ,
                       output parisfueltype ) no-error .
  assign
    isFuel = yes when is-fuel = "yes".
end.
if not isFuel
then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'is-lgas-corr':U ,
                       output is-fuel ,
                       output parisfueltype ) no-error .
  assign
    isFuel = yes when is-fuel = "yes".
end.
v-reasonme  = "".
v-attr-mandat-wayb = "".
v-attr-dop-info = "".
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input bf_trn-doc.obj-type
  ,input bf_trn-doc.obj-Code
  ,input 'nakl_par':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
find first bf_doc-line no-lock where bf_doc-line.doc-code = bf_trn-doc.doc-code no-error.
if error-status :error
then do:
  undo, return error error-status:get-message(1).
end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_doc-line.artic
  ,  input bf_doc-line.prod-type
  ,  input bf_doc-line.prod-code
  , output varis-petrol
  , output varis-pieces
  ) no-error.
if error-status :error
then do:
  undo, return error return-value.
end.
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'minusprt':U  then varminus-parts = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'reasonm':U   then v-reasonm      = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'reasonme':U  then v-reasonme     = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'inv-ship':U  then inv-shipvalue  = thbjattr_thbj-attr.property-value-logical .
    if thbjattr_thbj-attr.prop-code = 'reasons-for-return':U  then v-reasons-for-return     = thbjattr_thbj-attr.property-value-character .
    if bf_trn-doc.ext-doc-type = 'ie':U
    then do:
      if isFuel
      then do:
        if thbjattr_thbj-attr.prop-code = 'attr-PN' then v-attr-mandat-wayb =  thbjattr_thbj-attr.property-value-character .
      end.
      else do:
        if thbjattr_thbj-attr.prop-code = 'attr-mandatory-gds-in-wayb' then v-attr-mandat-wayb =  thbjattr_thbj-attr.property-value-character .
      end.
    end.
    if not (varis-petrol and
      not varis-pieces)
    then do:
      case bf_trn-doc.ext-doc-type:
      when 'ep':U then
        if thbjattr_thbj-attr.prop-code = 'attr-mandatory-gds-ret-wayb' then v-attr-mandat-wayb =  thbjattr_thbj-attr.property-value-character .
      when 'ee':U then
        if thbjattr_thbj-attr.prop-code = 'attr-mandatory-gds-exp-wayb' then v-attr-mandat-wayb =  thbjattr_thbj-attr.property-value-character .
      end case.
    end.
end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input bf_trn-doc.obj-type
  ,input bf_trn-doc.obj-Code
  ,input 'petrol':U
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
  if thbjattr_thbj-attr.prop-code = 'dop-info':U then v-attr-dop-info = thbjattr_thbj-attr.property-value-character .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-addch'
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-add-charg
  ,output par-type
  ) no-error .
if is-add-charg <> 'yes' then is-add-charg = 'no' .
run str/my-obj.p (input bf_trn-doc.obj-type, input bf_trn-doc.obj-code, input pardb-num, output varmy-obj).
run waitfram-show in this-procedure ( input substitute( 'Определяем статус для установки в документе "&1".'
                                                      , pardoc-code ) ) no-error.
run str/trn-graf.p ( input bf_trn-doc.doc-code,
                 input pardb-num,
                 input parmode,
                output varstatus,
                output varflag,
                output varcopystatus,
                output varcopyflag ) no-error.
if error-status :error
then do:
   run waitfram-hide in this-procedure no-error.
   return error return-value.
end.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  bf_trn-doc.doc-code
  ,output varhold-doc
  )  .
if varhold-doc = true then do:
  assign
    varcount = 0.
  for each bf_doc-line
    where bf_doc-line.doc-code = bf_trn-doc.doc-code
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure (substitute ("Проверка документа на наличие топливного товара. Проверено строк: &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss"))) no-error.
    assign
      varcount = varcount + 1
    .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_doc-line.artic
  ,  input bf_doc-line.prod-type
  ,  input bf_doc-line.prod-code
  , output varis-petrol
  , output varis-pieces
  ) no-error.
    if error-status :error then do:
      undo, return error return-value.
    end.
    if varis-petrol = true
      and varis-pieces = false
    then do:
      undo, return error substitute("Топливный товар нельзя использовать в межфирменном перемещении! Артикул : &1" , bf_doc-line.artic ).
    end.
  end.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'stfactpl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output stfactplvalue
  ,output stfactpltype
  ) no-error .
if stfactplvalue <> ""  then
do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_chkqtpl in g#lib-calc
  (  input stfactplvalue
  , output varupd-fact-qnty
  , output varrevision
  , output varpercrev
  , output varauto-tank
  , output varpercauto
  , output varinv
  , output varpercinv
  , output varinv-set
  ) no-error .
  if error-status :error then
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Разборе строки параметра stfactpl" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    return error .
  end.
end.
for first buf_doc-attr no-lock where buf_doc-attr.doc-code = bf_trn-doc.doc-code
                                 and buf_doc-attr.attr-code = 'is-return':U
:
  if logical(buf_doc-attr.attr-value) then v-expense-return = yes .
end .
if varstatus = 'факт':U
and (bf_trn-doc.ext-doc-type = 'ie':U
  or bf_trn-doc.ext-doc-type = 'iv':U
  or bf_trn-doc.ext-doc-type = 'rv':U
    )
then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'mercuri':u
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-mercury-value
  ,output v-mercury-type
  ) no-error .
  if  not error-status :error
  and lookup(v-mercury-value, 'th':u) > 0
  then do:
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input bf_trn-doc.obj-type
  ,input bf_trn-doc.obj-code
  ,input 'mercur':U
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
      case thbjattr_thbj-attr.prop-code :
        when "close" then v-close = thbjattr_thbj-attr.property-value-logical.
      end case.
    end.
    vsdSts = new vsdstatustype ().
    vsdSubsObj = new vsdsubs ().
    vsdStr = new vsdtostorage ().
    keyrecObj = new keyrec ().
    for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code:
      if bf_parts.fact-qnty <= 0 then next .
      find first bf_goods where
        bf_goods.artic = bf_parts.artic and
        bf_goods.prod-type = bf_parts.prod-type and
        bf_goods.prod-code = bf_parts.prod-code no-error.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  bf_goods.gds-code
  ,input  'mercur_FGIS=request':u
  ,output v-mercury-prod
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Код товара" bf_goods.gds-code skip
          'mercur_FGIS=request':u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if  bf_trn-doc.fact-date  <> ?
      and bf_trn-doc.shift-date <> ?
      and bf_trn-doc.shift-num  <> ?
      and bf_trn-doc.shift-name <> ?
      then do:
       run corr-date in this-procedure
          ( input bf_trn-doc.obj-type
          , input bf_trn-doc.obj-code
          , input bf_trn-doc.fact-date
          , input bf_trn-doc.shift-date
          , input bf_trn-doc.shift-num
          , input bf_trn-doc.shift-name
          ).
      end.
      keyrecObj:GenKeyRec('parts':U, buffer bf_parts:handle, output keypart).
      vsdsubsObj = vsdStr:getVSDsubs(input "part-key", input keypart).
      if not (vsdSubsObj:iCounter = 0)
      then do:
          vsdSubsObj:GetItem(1).
        end.
      if (vsdSubsObj:iCounter = 0 or vsdSubsObj:VsdObjCurr:UUID = "")
      and v-mercury-prod
      and not var-is-auto-trn
      then do:
        varlog = false.
        if v-close = true
        then do:
          if parmessage then do:
            message   "В документе " bf_trn-doc.doc-code skip
                      "На объекте  " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                      "По товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
                      "Подконтрольного ФГИС Меркурий не заведен ВСД."
                      "Продолжить закрытие документа?"
                      view-as alert-box buttons yes-no update varlog.
            if varlog <> yes
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error.
            end.
          end.
        end.
        else do:
          message   "В документе " bf_trn-doc.doc-code skip
                    "На объекте  " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                    "По товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
                    "Подконтрольного ФГИС Меркурий не заведен ВСД."
                    view-as alert-box error.
          run waitfram-hide in this-procedure no-error.
          undo, return error.
        end.
      end.
      do ii = 1 to vsdSubsObj:GetItem(ii):
        vsdSubCurr = vsdSubsObj:VsdObjCurr.
        vsdSubCurr:FactDatetime = now.
        vsdStr:updateDB(input vsdSubCurr ).
      end.
    end.
    delete object vsdSts .
    delete object vsdSubsObj .
    delete object vsdStr .
    delete object keyrecObj .
  end.
end.
if ((varstatus = 'накл':U and varflag) or varstatus = 'факт':U) and varauto-tank = true and stfactplvalue <> ""
then do:
  define variable v-dec as decimal no-undo .
  v-kpsecs = "" .
  for each bf_doc-line-attr where bf_doc-line-attr.doc-code = bf_trn-doc.doc-code
                              and bf_doc-line-attr.attr-code = "n"
                              break by bf_doc-line-attr.gds-code :
    def var infoSectionObj as class InfoSection no-undo.
    infoSectionsTotal = new InfoSectionsTotal().
    infoSectionsTotal:Initialization(bf_trn-doc.doc-code, bf_doc-line-attr.gds-code).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'car-num':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    if v-attr-value > ""
    then do :
      find first sep_auto-tank-attr no-lock where sep_auto-tank-attr.auto-num = v-attr-value
                                              and sep_auto-tank-attr.attr-code = "auto-sep"
                                              no-error.
      if available sep_auto-tank-attr
      and logical(sep_auto-tank-attr.attr-value)
      then do :
        infoSectionsTotal:IsSGDKK = yes .
      end .
    end .
    find first bf_goods no-lock where bf_goods.gds-code = bf_doc-line-attr.gds-code.
    find first bf_doc-line no-lock where
                               bf_doc-line.doc-code = bf_trn-doc.doc-code
                           and bf_goods.artic= bf_doc-line.artic
                           and bf_goods.prod-code = bf_doc-line.prod-code
                           and bf_goods.prod-type = bf_doc-line.prod-type no-error.
    run gds-attr-value in this-procedure
      (  input bf_doc-line-attr.gds-code
        ,input 'fuel-type':U
        ,output v-attr-value
        ,output v-attr-type
       ) .
    if v-attr-value = "lgas" then
    do:
      infoSectionObj = infoSectionsTotal:GetInfoSectionProp(1).
      infoSectionObj:FactKgQnty = bf_doc-line.fact-qnty * bf_doc-line.fact-density.
      infoSectionObj:FactQnty = bf_doc-line.fact-qnty.
      infoSectionObj:FactDensity = bf_doc-line.fact-density.
      infoSectionsTotal:SaveDB().
    end.
    else do:
        if absolute (infoSectionsTotal:DocQntyTotal - bf_doc-line.doc-qnty) > 1
        or absolute (infoSectionsTotal:DocDensityAvg - bf_doc-line.doc-density) > 1
        or absolute (infoSectionsTotal:CliQntyTotal - bf_doc-line.cli-qnty) > 1
        then do:
          v-mess = substitute("Кол-во по линии накладной не совпадает с общим кол-вом по доп. инфо! Артикул : &2.&1По линии накладной:&1    по ТТН - &3&1    плотность - &4&1    по накл. - &5&1По доп. инфо:&1    по ТТН - &6&1    плотность - &7&1    по накл. - &8",
                                          chr(10),
                                          bf_doc-line.artic,
                                          bf_doc-line.doc-qnty,
                                          bf_doc-line.doc-density,
                                          bf_doc-line.cli-qnty,
                                          infoSectionsTotal:DocQntyTotal,
                                          infoSectionsTotal:DocDensityAvg,
                                          infoSectionsTotal:CliQntyTotal
                                          ).
          delete object infoSectionsTotal.
          undo, return error v-mess.
        end.
        if varstatus = 'факт':U then do:
          if (infoSectionsTotal:FactQntyTotal = ? or infoSectionsTotal:FactKgQntyTotal = ? ) or (absolute (infoSectionsTotal:FactQntyTotal - bf_doc-line.fact-qnty) > 1
           or absolute (infoSectionsTotal:FactKgQntyTotal - bf_doc-line.fact-density * bf_doc-line.fact-qnty) > 1)
          then do:
            v-mess = substitute("Кол-во по линии накладной не совпадает с общим кол-вом по доп. инфо! Артикул : &2.&1По линии накладной:&1    факт. кол-во - &3&1    Факт. кол-во, вес - &4&1По доп. инфо:&1    факт. кол-во - &5&1    Факт. кол-во, вес - &6",
                                            chr(10),
                                            bf_doc-line.artic,
                                            bf_doc-line.fact-qnty,
                                            bf_doc-line.fact-density * bf_doc-line.fact-qnty,
                                            infoSectionsTotal:FactQntyTotal,
                                            infoSectionsTotal:FactKgQntyTotal
                                            ).
            delete object infoSectionsTotal.
            undo, return error v-mess.
          end.
        end.
        v-iskp = no .
        v-needsavesec = no .
        do ii = 1 to infoSectionsTotal:SectionNum :
          infoSectionObj = infoSectionsTotal:GetInfoSectionProp(ii).
          if varstatus = 'факт':U
          then do :
            if infoSectionObj:IsKP
            then do :
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-curr-db-num
    ,input  v-curr-userid
    ,input  0
    ,input  'actn_income_petrol-сommission':U
    ,input  'object':U
    ,input  bf_trn-doc.host-code
    ,input  bf_trn-doc.obj-type
    ,input  bf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
              if not varlog
              then do:
                undo, return error substitute( 'По секциям включен комиссионный прием нефтепродукта. Отсутствует право.').
              end.
            end .
            if infoSectionsTotal:IsSGDKK
            then do :
            end .
            else do :
              if not infoSectionObj:KPnoMeas
              then do :
                v-dec = decimal(infoSectionObj:TankWeight) no-error .
                if error-status:error
                or v-dec = 0
                then do :
                  v-mess = "Не произведён расчёт измеренной массы НП (" + string(infoSectionsTotal:GdsCode) + ") в секции АЦ (" + infoSectionObj:SectionName + "). Закрытие документа невозможно".
                  delete object infoSectionsTotal .
                  undo, return error v-mess.
                end .
              end .
            end .
          end .
          else do :
            if first-of(bf_doc-line-attr.gds-code)
            then do :
              if infoSectionsTotal:IsSGDKK
              then do :
                if infoSectionObj:alarm-SGDKK
                then do :
                  v-kpsecs = v-kpsecs + infoSectionObj:SectionName + " (" + bf_goods.gds-name + "), " .
                  if not infoSectionObj:IsKP
                  then do :
                    infoSectionObj:IsKP = yes .
                    v-needsavesec = yes .
                  end .
                end .
                else do :
                  if infoSectionObj:IsKP
                  then do :
                    infoSectionObj:IsKP = no .
                    v-needsavesec = yes .
                  end .
                end .
              end .
              else do :
                if infoSectionObj:KPnoMeas
                then do :
                  v-kpsecs = v-kpsecs + infoSectionObj:SectionName + " (" + bf_goods.gds-name + "), " .
                  if not infoSectionObj:IsKP
                  then do :
                    infoSectionObj:IsKP = yes .
                    v-needsavesec = yes .
                  end .
                end .
                else do :
                    infoSectionObj:IsKP = no .
                    infoSectionObj:TankWeight = 0 .
                    v-needsavesec = yes .
                end .
              end .
            end .
          end .
          if not v-iskp
          and not infoSectionsTotal:IsSGDKK
          then do:
            v-iskp = infoSectionObj:IsKP.
          end.
        end.
        if v-needsavesec
        then do :
          infoSectionsTotal:SaveDB().
        end .
        delete object infoSectionsTotal.
      end.
  end.
  v-kpsecs = trim(v-kpsecs, ", ") .
  if v-kpsecs > ""
  then do :
    message "Для секций " v-kpsecs " установлен признак «Комиссионный прием НП». После перевода накладной в статус «накл+» продолжение работы с секциями с комиссионным приемом НП будет доступно только пользователю с правами комиссионной приемки." skip
            "Вы уверены, что хотите закрыть накладную?"
    view-as alert-box question buttons yes-no update varlog .
    if not varlog
    then do :
      undo, return .
    end .
  end .
end.
if  varstatus = 'факт':U
and bf_trn-doc.doc-type = 'рас':U
and bf_trn-doc.internal = false
and bf_trn-doc.is-flora = true
then do:
   run ie-date in this-procedure.
end.
assign varlns-cnt = 0 .
run waitfram-show in this-procedure ( input substitute( "Переход документа в статус &1&2."
                                                      , varstatus
                                                      , ( if varstatus = 'факт':U then ''  else
                                                         (if varflag   = yes     then "+" else "-" ) ) ) ).
  case parmode:
    when '<закрытие документа>':U  or
    when '<закрытие документа на факт>':U
    then do:
      if not( bf_trn-doc.status_ = 'запрос':U  )
      then do :
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_resv-inqv in g#lib-trn3
(input  bf_trn-doc.doc-code,
 output is-no
)
.
          if is-no = false
          then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_delnabor in g#lib-trn3
( input parparentproc ,
  input bf_trn-doc.doc-code
) no-error
.
              if error-status :error
              then do:
                  undo, return error substitute( 'Ошибка при удалении наборов в документе  "&1" .', bf_trn-doc.doc-code ).
              end.
          end.
      end.
  define variable v-kol-e as integer   no-undo .
  v-kol-e = 0.
  if  bf_trn-doc.status_ = 'накл':U and bf_trn-doc.flag_ = false
  then do :
  varerr = false .
  for each bf_doc-line no-lock where
            bf_doc-line.doc-code =  bf_trn-doc.doc-code
            :
       v-kol-e = v-kol-e + 1.
       if g#auto <> yes and not g#esys then do:
         run verify-assort-pol
         ( bf_doc-line.artic ,
           bf_doc-line.prod-type ,
           bf_doc-line.prod-code ) no-error .
            if error-status :error
            then do:
              assign
                varerr = true .
            end.
       end.
  end.
  if v-kol-e = 0 then do:
    run waitfram-hide in this-procedure no-error.
    return error substitute( 'Документ &1 пуст !' ,  bf_trn-doc.doc-code ).
  end.
  if varerr = true
  then do:
    run gbl/prnfilen.w
      (input  "Ошибки по соответствию товаров в накладной и Ассортиментной политике"
      ,input  0
      ,input  replace(bf_trn-doc.doc-code, "*", "$") + ".err"
      ,input  7
      ,output v-user-action
      ,output v-printed
      ).
    run waitfram-hide in this-procedure no-error.
    return error substitute( 'Ошибки по соответствию товаров в накладной и Ассортиментной политике. ' +
                             'Смотри файл "&1.err"'
                            , replace( bf_trn-doc.doc-code, "*", "$" ) ).
  end.
  end.
  assign
     vartechproliv = no.
  if bf_trn-doc.obj-type = 'маг':U then do:
     run adm/shattri.p (
               input "get":U
              ,input  bf_trn-doc.obj-type
              ,input  bf_trn-doc.obj-code
              ,input  'autosale':U
              ,input  'sale-add':U
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output par-type
              ,input-output table-handle v-tth
              ) no-error .
     if error-status:error then do:
        if valid-object(v-tth) then delete object v-tth.
        undo, return error return-value + error-status :get-message(1) .
     end.
     if valid-object(v-tth) then delete object v-tth.
     _ii:
     do ii = 1 to num-entries(v-value-character, ';':U):
        assign
            v-entry    =  ENTRY(ii, v-value-character, ';':U)
            v-doc-kind = ENTRY(1, v-entry)
            v-obj-type = entry (2, v-entry)
            v-obj-code = integer(entry (3, v-entry))
        .
        if v-doc-kind = 'trf':U and
           bf_trn-doc.cli-type = v-obj-type      and
           bf_trn-doc.cli-code = v-obj-code
        then do:
          vartechproliv = yes.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bf_trn-doc.doc-code ,
                       input 'techpass':U ,
                       input yes ) no-error .
        end.
        if v-doc-kind = 'ngs':U and
           bf_trn-doc.cli-type = v-obj-type      and
           bf_trn-doc.cli-code = v-obj-code
        then do:
          v-add-nat-gas = true.
        end.
      end.
      _cpa:
      for each buf_cash-pay-attr where buf_cash-pay-attr.attr-code = "dop-doc" no-lock:
        v-value-character = buf_cash-pay-attr.attr-value.
        case entry(1, v-value-character, ','):
          when 'swo':U then do:
            if entry(2, v-value-character, ',') = bf_trn-doc.cli-type and integer (entry(3, v-value-character, ',')) = bf_trn-doc.cli-code
            then do:
              vartechproliv = yes.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bf_trn-doc.doc-code ,
                       input 'techpass':U ,
                       input yes ) no-error .
              leave _cpa.
            end.
          end.
          when 'trf':U then do:
            if entry(2, v-value-character, ',') = bf_trn-doc.cli-type and integer (entry(3, v-value-character, ',')) = bf_trn-doc.cli-code
            then do:
              vartechproliv = yes.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bf_trn-doc.doc-code ,
                       input 'techpass':U ,
                       input yes ) no-error .
              leave _cpa.
            end.
          end.
        end case.
      end.
  end.
  if not var-is-auto-trn and not v-add-nat-gas and not vartechproliv and v-attr-mandat-wayb <> "" and not bf_trn-doc.doc-code matches "*=*" then do:
      v-error-attr = "" .
      if not can-find (first buf_doc-attr no-lock where buf_doc-attr.doc-code = pardoc-code
        and lookup (buf_doc-attr.attr-code, v-attr-mandat-wayb) > 0)
      then v-error-attr = "empty".
      if bf_trn-doc.VAT-rubl = 0
      then do:
         if
             (num-entries (v-attr-mandat-wayb) = 2 and lookup ('nsf':U, v-attr-mandat-wayb) > 0 and lookup ('dsf':U, v-attr-mandat-wayb) > 0)
          or (num-entries (v-attr-mandat-wayb) = 1 and lookup ('nsf':U, v-attr-mandat-wayb) > 0 or lookup ('dsf':U, v-attr-mandat-wayb) > 0)
          then v-error-attr = "".
      end.
      for each buf_doc-attr no-lock where buf_doc-attr.doc-code = pardoc-code
        and lookup (buf_doc-attr.attr-code, v-attr-mandat-wayb) > 0
        and not lookup (buf_doc-attr.attr-code, 'nsf':U + "," + 'dsf':U) > 0
        and buf_doc-attr.attr-value = "":
        v-error-attr = v-error-attr + ", " + buf_doc-attr.attr-code .
      end.
      for each buf_doc-attr no-lock where
        bf_trn-doc.VAT-rubl > 0
        and buf_doc-attr.doc-code = pardoc-code
        and lookup (buf_doc-attr.attr-code, v-attr-mandat-wayb) > 0
        and lookup (buf_doc-attr.attr-code, 'nsf':U + "," + 'dsf':U) > 0
        and buf_doc-attr.attr-value = "":
        v-error-attr = v-error-attr + ", " + buf_doc-attr.attr-code .
      end.
      if v-error-attr <> "" then do:
        run waitfram-hide in this-procedure no-error.
        undo, return error "Не все атрибуты накладной заполнены.".
      end.
  end.
  v-error-attr = "".
  if not var-is-auto-trn and not vartechproliv and isFuel and bf_trn-doc.ext-doc-type = 'ie':U
  then do:
    do ii = 1 to num-entries (v-attr-dop-info):
      find first buf_doc-attr no-lock
        where buf_doc-attr.doc-code = pardoc-code
          and buf_doc-attr.attr-code = entry (ii, v-attr-dop-info) no-error.
      if not available (buf_doc-attr) or (available (buf_doc-attr) and
        (buf_doc-attr.attr-value = ""
        or buf_doc-attr.attr-value = "" or buf_doc-attr.attr-value = ? or buf_doc-attr.attr-value = "?")
        )
      then do:
        v-error-attr = v-error-attr + ", " + entry (ii, v-attr-dop-info).
      end.
    end.
    if v-error-attr <> "" then do:
      run waitfram-hide in this-procedure no-error.
      undo, return error "Не все обязательные поля по доп. информации накладной заполнены".
    end.
  end.
  if bf_trn-doc.status_ <> 'запрос':U  then do:
    define variable v-reasonm-type-n as character no-undo.
    if v-reasonm and
             lookup( bf_trn-doc.ext-doc-type ,v-reasonme) = 0 and
             lookup( bf_trn-doc.ext-doc-type ,'es,em,wm,im,ot,rs,mp,pc':U) = 0
    then do:
      if bf_trn-doc.reason-code = 0 or bf_trn-doc.reason-code = ? then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error "Не задано поле ПРИЧИНА СОЗДАНИЯ ДОКУМЕНТА.".
      end.
    end.
    if lookup( string(bf_trn-doc.reason-code), v-reasons-for-return) > 0
    and bf_trn-doc.ext-doc-type = 'ee':U
    and not v-expense-return
    then do :
      find first in_trn-doc no-lock where in_trn-doc.doc-code = bf_trn-doc.out-code no-error .
      if not available in_trn-doc
      then do :
        run waitfram-hide in this-procedure no-error.
        undo, return error "Не задано поле Источник.".
      end.
      else do :
        if in_trn-doc.cli-type <> bf_trn-doc.cli-type
        or in_trn-doc.cli-code <> bf_trn-doc.cli-code
        then do :
          run waitfram-hide in this-procedure no-error.
          undo, return error ("Поставщик не совпадает с поставщиком из источника (ПН " + in_trn-doc.doc-code + ").").
        end.
        for each bf_doc-line no-lock where bf_doc-line.doc-code = bf_trn-doc.doc-code,
        first ub.goods no-lock where  ub.goods.artic      = bf_doc-line.artic
                                  and ub.goods.prod-type  = bf_doc-line.prod-type
                                  and ub.goods.prod-code  = bf_doc-line.prod-code :
          find first in_doc-line no-lock where in_doc-line.doc-code   = in_trn-doc.doc-code
                                           and in_doc-line.artic      = bf_doc-line.artic
                                           and in_doc-line.prod-type  = bf_doc-line.prod-type
                                           and in_doc-line.prod-code  = bf_doc-line.prod-code
                                           no-error.
          if not available in_doc-line
          then do :
            run waitfram-hide in this-procedure no-error.
            undo, return error ("Товара с кодом " + string(ub.goods.gds-code) + " " + ub.goods.gds-name + " нет в документе-источнике (ПН " + in_trn-doc.doc-code + ").") .
          end.
          else do :
            find first bf_gds-dtl no-lock where bf_gds-dtl.doc-code   = bf_doc-line.doc-code
                                            and bf_gds-dtl.artic      = bf_doc-line.artic
                                            and bf_gds-dtl.prod-type  = bf_doc-line.prod-type
                                            and bf_gds-dtl.prod-code  = bf_doc-line.prod-code
                                            no-error .
            if not available bf_gds-dtl
            then do :
              run waitfram-hide in this-procedure no-error.
              undo, return error ("Отсутствет детализация по товару с кодом " + string(ub.goods.gds-code) + " " + ub.goods.gds-name ) .
            end.
            if in_doc-line.price-rubl <> bf_gds-dtl.price-rubl
            or in_doc-line.price-base <> bf_gds-dtl.price-base
            then do :
              run waitfram-hide in this-procedure no-error.
              undo, return error ("У товара с кодом " + string(ub.goods.gds-code) + " " + ub.goods.gds-name + " цена не совпадает с ценой в документе-источнике (ПН " + in_trn-doc.doc-code + ").") .
            end.
            if in_doc-line.fact-qnty < bf_doc-line.fact-qnty
            then do :
              run waitfram-hide in this-procedure no-error.
              undo, return error ("У товара с кодом " + string(ub.goods.gds-code) + " " + ub.goods.gds-name + " количество превышает количество в документе-источнике (ПН " + in_trn-doc.doc-code + ").") .
            end.
            assign v-return-qnty = 0 .
            for each bf2_trn-doc no-lock where bf2_trn-doc.out-code = bf_trn-doc.out-code
                                           and bf2_trn-doc.status_  = 'факт':U :
              if lookup( string(bf2_trn-doc.reason-code), v-reasons-for-return) > 0
              then do :
                for each bf2_doc-line no-lock where bf2_doc-line.doc-code   = bf2_trn-doc.doc-code
                                                and bf2_doc-line.artic      = bf_doc-line.artic
                                                and bf2_doc-line.prod-type  = bf_doc-line.prod-type
                                                and bf2_doc-line.prod-code  = bf_doc-line.prod-code :
                  assign v-return-qnty = v-return-qnty + bf2_doc-line.fact-qnty .
                end.
              end.
            end.
            if in_doc-line.fact-qnty < (bf_doc-line.fact-qnty + v-return-qnty)
            then do :
              run waitfram-hide in this-procedure no-error.
              undo, return error ("Товар с кодом " + string(ub.goods.gds-code) + " " + ub.goods.gds-name + chr(10) +
                                  "Общее количество уже возвращенного товара по ПН " + in_trn-doc.doc-code + ":  " + string(v-return-qnty) + chr(10) +
                                  "Количество в ПН:  " + string(in_doc-line.fact-qnty) + chr(10) +
                                  "Максимальное количество, которое можно указать для возврата:  " + string(in_doc-line.fact-qnty - v-return-qnty) + chr(10) +
                                  "Вы указали:  " + string(bf_doc-line.fact-qnty)
                                   ) .
            end.
          end.
        end.
      end.
    end.
  end.
  define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
  if bf_trn-doc.ext-doc-type = 'ie':U
  then do :
    find first ub.contract no-lock where ub.contract.contract-code = bf_trn-doc.contract-code
                                     and ub.contract.host-code = bf_trn-doc.host-code
                                     no-error .
    find first ub.utd no-lock where ub.utd.doc-code = bf_trn-doc.doc-code no-error .
    if available ub.contract
    and not available ub.utd
    then do :
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code).
      find first buf_contract-attr no-lock where buf_contract-attr.host-code = ub.contract.host-code
                                                 and buf_contract-attr.contract-code = ub.contract.contract-code
                                                 and buf_contract-attr.attr-code = "contract-edi"
                                                 no-error .
      if EDOParSec:IsEdo
      and available buf_contract-attr
      and logical(buf_contract-attr.attr-value) = true
      then do :
        run waitfram-hide in this-procedure no-error.
        undo, return error ("Договор " + ub.contract.contract-name + " рассчитан на поставки через ЭДО. Ручной приход по нему невозможен!") .
      end .
    end .
    for first doc-attr no-lock where doc-attr.doc-code  = bf_trn-doc.doc-code
                                 and doc-attr.attr-code = 'is-lgas':U
                                 :
      if logical(doc-attr.attr-value)
      then do :
        define variable v-trn-reas-sug as logical no-undo .
        define variable v-trn-reas-sug-type as character no-undo .
        delete object v-tth no-error.
        run adm/shattri.p (
             input "get":U
            ,input bf_trn-doc.obj-type
            ,input bf_trn-doc.obj-code
            ,input 'petrol':U
            ,input  "trn-reas-sug"
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-trn-reas-sug
            ,output v-trn-reas-sug-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error .
        if error-status :error  then v-trn-reas-sug = true .
        delete object v-tth no-error.
        if v-trn-reas-sug
        and (bf_trn-doc.reason-code = 0 or bf_trn-doc.reason-code = ?)
        then do :
          run waitfram-hide in this-procedure no-error.
          undo, return error "Не задано поле по этапу приема СУГ - укажите финальный или не финальный слив газовоза".
        end .
      end .
    end .
  end .
  if bf_trn-doc.status_ <> 'запрос':U                           and
        not (bf_trn-doc.status_  = 'накл':U   and
              bf_trn-doc.doc-type = 'возврат':U and
              bf_trn-doc.internal)                                  and
        not (
              bf_trn-doc.status_ = 'накл':U                          and
              (bf_trn-doc.ext-doc-type = 're':U or
              bf_trn-doc.ext-doc-type = 'ie':U       ) and
              varhold-doc = yes
              )
  then do:
     if varchk-prs and not (bf_trn-doc.status_ = 'накл':U and varflag = true)
     then do:
        define buffer buf_sale-doc for ub.sale-doc.
        if bf_trn-doc.ext-doc-type = 'ie':U then do:
            find first buf_sale-doc no-lock where
                      buf_sale-doc.doc-code = bf_trn-doc.doc-code no-error.
        end.
        if not available buf_sale-doc
          or (available buf_sale-doc and buf_sale-doc.doc-kind <> 'itr':U)
        then do:
           find first bf_clients where bf_clients.obj-type = 'чел':U          and
                                       bf_clients.obj-code = bf_trn-doc.boss no-lock no-error.
           if not available bf_clients
           then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "Не указан или неправильный менеджер.".
           end.
           find first bf_clients where bf_clients.obj-type = 'чел':U          and
                                        bf_clients.obj-code = bf_trn-doc.agnt no-lock no-error.
           if not available bf_clients
           then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "Не указан или неправильный исполнитель.".
           end.
        end.
     end.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-fin'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-fin
  ,output par-type
  ) no-error .
  if is-fin = "yes" or
     bf_trn-doc.ext-doc-type = 'ee':U or
     bf_trn-doc.ext-doc-type = 'ie':U
  then do:
     run adm/shattri.p (
         input "get":U
        ,input  bf_trn-doc.obj-type
        ,input  bf_trn-doc.obj-code
        ,input  'contr-in':U
        ,input  (if bf_trn-doc.ext-doc-type = 'ee':U then "contr-in-expense" else "contr-in-income")
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output varcontract
        ,output v-value-character
        ,input-output table-handle v-tth-contr
        ) no-error  .
     if error-status:error then do:
        if valid-object(v-tth-contr) then delete object v-tth-contr.
        undo, return error return-value + error-status :get-message(1) .
     end.
     if valid-object(v-tth-contr) then delete object v-tth-contr.
  end.
     if bf_trn-doc.ext-doc-type = 'ie':U and
        bf_trn-doc.status_      = 'накл':U            and
        (bf_trn-doc.flag_ = no and varhold-doc = no or bf_trn-doc.flag_ = yes and varhold-doc = yes) and
        varcontract   = yes and
        vartechproliv = no
        and not isFuel
        and not bf_trn-doc.doc-code matches "*=*"
      then do:
        if is-fin = "yes":u
        then do:
            if (bf_trn-doc.contract-code = 0 or bf_trn-doc.contract-code = ?)
            then do:
              run waitfram-hide in this-procedure .
              undo, return error "Не указан номер договора. В Настройках для Накладных в разрезе ВЗАИМОРАСЧЕТОВ установлена Обязательная ссылка на договор в приходной накладной.".
            end.
        end.
        else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'ndog':U ,
                       output parcontract-code ,
                       output parcontract-type ) no-error .
          if error-status :error
          then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error return-value.
          end.
          if (parcontract-code = "" or parcontract-code = ?)
          then do:
            run waitfram-hide in this-procedure .
            undo, return error "Не указан номер договора. В Настройках для Накладных в разрезе ВЗАИМОРАСЧЕТОВ установлена Обязательная ссылка на договор в приходной накладной.".
          end.
        end.
      end.
      if bf_trn-doc.ext-doc-type = 'ee':U and
        bf_trn-doc.status_      = 'накл':U            and
        varhold-doc             = no                 and
        varcontract             = yes
      then do:
        if is-fin = "yes":u
        then do:
            if (bf_trn-doc.contract-code = 0 or bf_trn-doc.contract-code = ?)
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "Не указан номер договора для РН.".
            end.
        end.
      end.
      if bf_trn-doc.status_ <> 'запрос':U
      then do:
        find first bf_pay-type where bf_pay-type.obj-code = bf_trn-doc.pay-code no-lock no-error.
        if not available bf_pay-type
        then do:
          run waitfram-hide in this-procedure no-error.
          undo, return error "Не указан или неправильный вид оплаты.".
        end.
      end.
      if bf_trn-doc.doc-type <> 'инв':U
      then do:
        for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value:
          if varstatus          = 'факт':U            and
            bf_doc-line.doc-qnty <> bf_doc-line.fact-qnty
          then do:
            fact-ok = no.
          end.
        end.
      end.
      if bf_trn-doc.ext-doc-type = 'vt':U and varstatus = 'факт':U
      then do:
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'inv-global':U
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
            if thbjattr_thbj-attr.prop-code = 'inv-prs'  then varinv-prs = string( thbjattr_thbj-attr.property-value-integer).
        end.
        if integer(varinv-prs) <> 0 then do :
          if integer(varinv-prs) = bf_trn-doc.reason-code then do:
            for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value:
              if bf_doc-line.fact-qnty <> 0
              then do:
                message
                  "Инвентаризация используется в качестве документа пересортицы" skip
                  "Для товара с артикулом" bf_doc-line.artic "разница не равна 0" skip
                  "Документ не может быть закрыт до статуса" 'факт':U skip
                view-as alert-box error.
                undo,return error.
              end.
            end.
          end.
          else do :
            assign
              varlog = no
            .
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-curr-db-num
    ,input  v-curr-userid
    ,input  0
    ,input  'actn_inventory_fact_not-peresort':U
    ,input  'object':U
    ,input  bf_trn-doc.host-code
    ,input  bf_trn-doc.obj-type
    ,input  bf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
            if varlog <> yes
            then do:
              undo, return error.
            end.
          end.
        end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-inv-introduce':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
        def var v-minus as logical no-undo.
        run adm/shattri.p (
           input "get":U
          ,input bf_trn-doc.obj-type
          ,input bf_trn-doc.obj-code
          ,input 'inv-obj':U
          ,input  "minus"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-minus
          ,output v-attr-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
        if not v-minus
        then do:
          for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code
            and bf_doc-line.doc-qnty < 0 on error undo, return error return-value:
            find first bf_goods where bf_goods.artic = bf_doc-line.artic
              and bf_goods.prod-type = bf_doc-line.prod-type
              and bf_goods.prod-code = bf_doc-line.prod-code no-lock.
            assign
              varerr = true.
            output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
            put    stream str-err unformatted substitute ("Товар &1 &2 имеет отрицательное фактическое кол-во: было &3, стало &4", bf_goods.artic, bf_goods.gds-name, (bf_doc-line.doc-qnty - bf_doc-line.fact-qnty), bf_doc-line.doc-qnty) skip.
            output stream str-err close.
          end.
        end.
        if varerr
        then do:
          if g#auto <> yes then do:
            run gbl/prnfilen.w
              (input  "Ошибкa. Имеются товары с отрицательным фактическим кол-вом"
              ,input  0
              ,input  replace(bf_trn-doc.doc-code, "*", "$") + ".err"
              ,input  7
              ,output v-user-action
              ,output v-printed
              ).
          end.
          return error substitute( 'Ошибкa. Имеются товары с отрицательным фактическим кол-вом' +
                                  'Смотри файл "&1.err"'
                                , replace( bf_trn-doc.doc-code, "*", "$" ) ).
        end.
        if not error-status:error and v-attr-value = "yes" then do:
          find first bf_utd where bf_utd.doc-code = bf_trn-doc.doc-code no-error.
          if available bf_utd
          then do:
            bf_utd.sts = objSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB.
            for each bf_utd-l no-lock where bf_utd-l.db-num = bf_utd.db-num
              and bf_utd-l.doc-id = bf_utd.doc-id
              :
              find first bf_goods no-lock where bf_goods.gds-code = bf_utd-l.gds-code no-error.
              if not available (bf_goods)
              then do:
                message
                "По документу" bf_trn-doc.doc-code skip
                "На объекте " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                "В документе первоначального ввода неизвестный товар " bf_utd-l.gds-code
                view-as alert-box information .
                  run waitfram-hide in this-procedure no-error.
                  undo, return error.
              end.
              find first bf_doc-line no-lock where
                               bf_doc-line.doc-code = bf_trn-doc.doc-code
                           and bf_goods.artic= bf_doc-line.artic
                           and bf_goods.prod-code = bf_doc-line.prod-code
                           and bf_goods.prod-type = bf_doc-line.prod-type no-error.
              if not available (bf_doc-line)
              then do:
                message
                "По документу" bf_trn-doc.doc-code skip
                "На объекте " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                "В инвентаризации отсутсвует линия из первоначального ввода с товаром " bf_utd-l.gds-code
                view-as alert-box information .
                  run waitfram-hide in this-procedure no-error.
                  undo, return error.
              end.
              create ub.utd-lines-attr.
                ub.utd-lines-attr.doc-id = bf_utd-l.doc-id.
                ub.utd-lines-attr.db-num = bf_utd-l.db-num.
                ub.utd-lines-attr.LineNum = bf_utd-l.LineNum.
                ub.utd-lines-attr.attr-code = "NoMarking".
                ub.utd-lines-attr.attr-value = string (bf_doc-line.doc-qnty - bf_utd-l.Quantity).
                if bf_doc-line.doc-qnty - bf_utd-l.Quantity > 0
                then do:
                  create tt-no-marking-gds.
                  tt-no-marking-gds.artic = bf_goods.artic.
                  tt-no-marking-gds.qnty = ub.utd-lines-attr.attr-value.
                  tt-no-marking-gds.gds-name = bf_goods.gds-name.
                end.
              create ub.utd-lines-attr.
              ub.utd-lines-attr.doc-id = bf_utd-l.doc-id.
              ub.utd-lines-attr.db-num = bf_utd-l.db-num.
              ub.utd-lines-attr.LineNum = bf_utd-l.LineNum.
              ub.utd-lines-attr.attr-code = "utd-fact-qnty".
              ub.utd-lines-attr.attr-value = string (bf_doc-line.doc-qnty).
              if bf_doc-line.doc-qnty - bf_utd-l.Quantity < 0 and not g#news
              then do:
                message
                "По документу" bf_trn-doc.doc-code skip
                "На объекте " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                "Товар " bf_goods.gds-code skip
                bf_goods.gds-name skip
                substitute ("Кол-во марок &1 больше кол-ва товара &2.", bf_utd-l.Quantity,  bf_doc-line.doc-qnty)
                view-as alert-box information .
                  run waitfram-hide in this-procedure no-error.
                  undo, return error.
              end.
            end.
            define variable v-not-accept as logical no-undo.
            find first tt-no-marking-gds no-lock where integer (tt-no-marking-gds.qnty) > 0 no-error.
            if not g#news and available (tt-no-marking-gds)
              then run str/inv-br1.w (input table tt-no-marking-gds, output v-not-accept).
            if v-not-accept
              then undo, return.
          end.
        end.
        for each ub.marking-attr where (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan") and ub.marking-attr.attr-value = bf_trn-doc.doc-code:
          delete ub.marking-attr.
        end.
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_chkprdtl in g#lib-trn2
(input bf_trn-doc.doc-code
) no-error.
      if error-status :error then do:
         undo, return error return-value  .
      end.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-today
  )  .
      run waitfram-show in this-procedure ( input substitute( "Локирование товаров при закрытии документа. Время: &1"
                                                            , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
      run trg/lock-gds.p
        (input bf_trn-doc.doc-code
        ,input no
        ,input no
        ,input 0
        ,input 0
        ,input false
        ,input false
        ) no-error .
      if error-status :error
      then do:
        run waitfram-hide in this-procedure no-error.
        undo, return error .
      end.
      case bf_trn-doc.ext-doc-type:
      when 'ie':U
      then do:
        if varhold-doc
        then do:
          run hold-check no-error.
          if error-status :error
          then do:
            return error return-value.
          end.
        end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'tpsi'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output vartpsi
  ,output vartpsi-type
  )  .
        if vartpsi = "yes":u and varhold-doc = no
        then do:
          for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code,
            first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                                bf_goods.prod-type = bf_doc-line.prod-type and
                                bf_goods.prod-code = bf_doc-line.prod-code on error undo, return error return-value :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_igdstpsi in g#lib-trn3
(input bf_goods.gds-code
,input bf_trn-doc.obj-type
,input bf_trn-doc.obj-code
) no-error.
            if error-status :error
            then do:
              return error return-value.
            end.
          end.
        end.
        if bf_trn-doc.status_ = 'накл':U and bf_trn-doc.flag_ = yes  or
          parmode = '<закрытие документа на факт>':U
        then do:
          find first bf-cnt_parts where bf-cnt_parts.out-code      = bf_trn-doc.doc-code and
                                        bf-cnt_parts.contract-code > 0                   and
                                        bf-cnt_parts.fact-qnty    <> 0                   no-lock no-error.
          if available bf-cnt_parts
          then do:
          v-not_ver-spec = false .
          run need-ver-spec ( output v-not_ver-spec ) no-error .
            assign
              varerr = no.
            bf_parts_cycle:
            for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code and
                                    bf_parts.fact-qnty <> 0                 no-lock on error undo, return error return-value :
              if bf_parts.contract-code = 0 then next.
              find first bf_goods where bf_goods.artic     = bf_parts.artic     and
                                        bf_goods.prod-type = bf_parts.prod-type and
                                        bf_goods.prod-code = bf_parts.prod-code no-lock.
assign
  price-rubl-with-tax-loc = bf_parts.price-rubl
  price-base-with-tax-loc = bf_parts.price-base
.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if bf_parts.out-code = 'free-zone':U     or
     bf_parts.out-code = 'out-zone':U   or
     bf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = bf_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = bf_parts.price-cli
   cli-base-rate          = bf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if bf_parts.road-tax-base  = ? then 0 else bf_parts.road-tax-base)
           road-tax-rubl-loc  = (if bf_parts.road-tax-rubl  = ? then 0 else bf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if bf_parts.transport-base = ? then 0 else bf_parts.transport-base)
          transport-rubl-loc = (if bf_parts.transport-rubl = ? then 0 else bf_parts.transport-rubl)
          other-base-loc     = (if bf_parts.other-base     = ? then 0 else bf_parts.other-base)
          other-rubl-loc     = (if bf_parts.other-rubl     = ? then 0 else bf_parts.other-rubl)
          vat-pc-loc         = (if bf_parts.vat-pc         = ? then 0 else bf_parts.vat-pc)
          slt-pc-loc         = (if bf_parts.slt-pc         = ? then 0 else bf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (bf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if bf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if bf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / bf_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
              assign
                varprice-check = (price-cli-with-tax-loc + road-tax-cli-loc
                                  + (if bf_parts.vat-type <> 'в т. ч.':U then vat-cli-loc else 0)
                                  + (if bf_parts.slt-type <> 'в т. ч.':U then slt-cli-loc else 0) ) / bf_parts.cli-base-rate.
              assign
              var-host-code = bf_parts.host-code
              .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_ckcntspc in g#lib-trn3
( input var-host-code
 ,input bf_parts.contract-code
 ,input bf_goods.gds-code
 ,input varprice-check
 ,input bf_parts.VAT-type
 ,input bf_parts.VAT-pc
) no-error .
              if error-status :error
              then do:
                assign
                  varerr = yes.
                output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
                put    stream str-err unformatted return-value skip.
                output stream str-err close.
                next bf_parts_cycle.
              end.
            end.
            if varerr = yes
            then do:
              if v-not_ver-spec = false then do:
              if g#auto <> yes and not g#esys then do:
                run gbl/prnfilen.w
                  (input  "Ошибки по соответствию товаров в накладной и спецификации к договору"
                  ,input  0
                  ,input  replace(bf_trn-doc.doc-code, "*", "$") + ".err"
                  ,input  7
                  ,output v-user-action
                  ,output v-printed
                  ).
              end.
              return error substitute( 'Есть ошибки по соответствию товаров в накладной и спецификации к договору. ' +
                                      'Смотри файл "&1.err"'
                                    , replace( bf_trn-doc.doc-code, "*", "$" ) ).
              end.
            end.
         end.
        end.
        if not bf_trn-doc.flag_ and
          bf_trn-doc.status_ = 'накл':U
        then do:
          if bf_trn-doc.tot-cli = ?
          then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error "Не указана сумма в валюте поставщика.".
          end.
          if inv-shipvalue = true and not varhold-doc
          then do:
              if (bf_trn-doc.inv-num = ? or bf_trn-doc.ship-date = ? or bf_trn-doc.ship-num = ?)
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error "Не указан инвойс или отгрузка.".
              end.
          end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-custm':u
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-custmvalue
  ,output is-custmtype
  )  .
          if is-custmvalue = "yes"
          then do:
            find first bf-cst_parts where bf-cst_parts.out-code = bf_trn-doc.doc-code and
                                          bf-cst_parts.cst-code = ""                  or
                                          bf-cst_parts.out-code = bf_trn-doc.doc-code and
                                          bf-cst_parts.cst-code = ?                   no-error.
            if available bf-cst_parts
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( 'В документе "&1" есть партия товара &2 &3 &4 с кодом &5, '
                                            + 'имеющая некорректный номер ГТД: "&6".'
                                            , bf-cst_parts.out-code
                                            , bf-cst_parts.artic
                                            , bf-cst_parts.prod-type
                                            , bf-cst_parts.prod-code
                                            , bf-cst_parts.part-code
                                            , bf-cst_parts.cst-code ).
            end.
          end.
        end.
        if varstatus          =  'факт':U   and
          bf_trn-doc.status_ =  'накл':U   and
          not varmy-obj
        then do:
          run waitfram-hide in this-procedure no-error.
          undo, return error "Закрыть накладную по ФАКТУ можно только для объекта своей базы данных или пассивного объекта.".
        end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'is-lgas':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
        if not v-attr-value = "yes"
        then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'is-lgas-corr':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
        end.
        if v-attr-value = "yes"
        then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input bf_trn-doc.doc-code ,
                        input 'trdcattr-date-start':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
          if v-attr-value = "" or v-attr-value = ? or error-status:error
          then do:
            find first bf_rvs-doc exclusive-lock
              where bf_rvs-doc.rvs-type = 'перед_док':U
                and bf_rvs-doc.out-code = bf_trn-doc.doc-code
              no-error .
            for first bf_rvs-line no-lock
              where bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code
                and bf_rvs-line.obj-type = bf_rvs-doc.obj-type
                and bf_rvs-line.obj-code = bf_rvs-doc.obj-code
                by bf_rvs-line.real-date
                by bf_rvs-line.real-time:
              if bf_rvs-line.real-date <> ?
              then do:
                v-attr-value = string (bf_rvs-line.real-date).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bf_trn-doc.doc-code ,
                       input 'trdcattr-date-start':U ,
                       input v-attr-value ) no-error .
                v-attr-value = string (bf_rvs-line.real-time, "HH:MM").
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bf_trn-doc.doc-code ,
                       input 'time-start':U ,
                       input v-attr-value ) no-error .
              end.
            end.
            find first bf_rvs-doc exclusive-lock
              where bf_rvs-doc.rvs-type = 'после_док':U
                and bf_rvs-doc.out-code = bf_trn-doc.doc-code
              no-error .
            for last bf_rvs-line no-lock
              where bf_rvs-line.rvs-code = bf_rvs-doc.rvs-code
                and bf_rvs-line.obj-type = bf_rvs-doc.obj-type
                and bf_rvs-line.obj-code = bf_rvs-doc.obj-code
                by bf_rvs-line.real-date
                by bf_rvs-line.real-time:
              if bf_rvs-line.real-date <> ?
              then do:
                v-attr-value = string (bf_rvs-line.real-date).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bf_trn-doc.doc-code ,
                       input 'trdcattr-date-end':U ,
                       input v-attr-value ) no-error .
                v-attr-value = string (bf_rvs-line.real-time, "HH:MM").
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input bf_trn-doc.doc-code ,
                       input 'time-end':U ,
                       input v-attr-value ) no-error .
              end.
            end.
          end.
        end.
        if bf_trn-doc.status_ <> 'запрос':U
        then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chklinst in g#lib-trn3
(input  this-procedure:handle
,input  bf_trn-doc.doc-code
,input  varstatus
,output fact-ok
) no-error.
            if error-status :error
            then do:
              return error return-value.
            end.
          if round (bf_trn-doc.tot-cli,  (if varrnd-znk = ? then 2 else integer(varrnd-znk) ) ) <>
            round (bf_trn-doc.tot-calc, (if varrnd-znk = ? then 2 else integer(varrnd-znk) ) )
          then do:
            find first bf_currency where bf_currency.curr-code = bf_trn-doc.exch-code no-lock.
            run waitfram-hide in this-procedure no-error.
            undo, return error "Неправильно указана сумма в валюте поставщика, или ошибка при заполнении накладной !" + chr(10) +
                              substitute( "Сумма по накладной : &1 &2."
                                        , string( round( bf_trn-doc.tot-cli,  if varrnd-znk = ? then 2 else integer( varrnd-znk ) ) )
                                        , bf_currency.curr-abbr ) + chr(10) +
                              substitute( "Сумма по всем строкам : &1 &2."
                                        , string( round( bf_trn-doc.tot-calc, if varrnd-znk = ? then 2 else integer( varrnd-znk ) ) )
                                        , bf_currency.curr-abbr ) + chr(10) +
                              "Эти суммы должны совпадать !"
                              .
          end.
        end.
        if varstatus           = 'факт':U and
          bf_trn-doc.obj-type = 'маг':U and
          can-find (first ub.scales no-lock where ub.scales.db-num = g#db-num)
        then do:
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_add-scal in g#lib-trn3
(input parparentproc
,input bf_trn-doc.obj-type
,input bf_trn-doc.obj-code
,input bf_trn-doc.doc-code
,input bf_trn-doc.doc-type
,input this-procedure
) no-error.
          if error-status :error
          then do:
            undo, return error return-value .
          end.
        end.
        if varstatus = 'факт':U then do :
            run adm/shattri.p (
                input "get":U
                ,input bf_trn-doc.obj-type
                ,input bf_trn-doc.obj-code
                ,input 'nakl_par':U
                ,input  "gtd-to-imp-prod"
                ,output v-value-character
                ,output v-value-date
                ,output v-value-decimal
                ,output v-value-integer
                ,output v-value-logical
                ,output par-type
                ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
                ) no-error .
            if not error-status :error and v-value-logical = true then do :
              for each bf_doc-line no-lock
                 where bf_doc-line.obj-code = bf_trn-doc.obj-code
                   and bf_doc-line.obj-type = bf_trn-doc.obj-type
                   and bf_doc-line.doc-code = bf_trn-doc.doc-code
                   :
                   run clntattr-value in this-procedure ( input bf_doc-line.prod-type, input bf_doc-line.prod-code, input 'foreign-producer':U, output v-attr-value, output v-attr-type ) .
                   assign v-is-foreign-producer = logical( v-attr-value ) .
                   if v-is-foreign-producer = true then do :
                      find first bf-cst_parts
                            where bf-cst_parts.obj-type  = bf_trn-doc.obj-type   and
                                  bf-cst_parts.obj-code  = bf_trn-doc.obj-code   and
                                  bf-cst_parts.prod-type = bf_doc-line.prod-type and
                                  bf-cst_parts.prod-code = bf_doc-line.prod-code and
                                  bf-cst_parts.artic     = bf_doc-line.artic     and
                                  bf-cst_parts.out-code  = bf_trn-doc.doc-code   no-lock no-error.
                      if available bf-cst_parts and ( bf-cst_parts.cst-code = "" or bf-cst_parts.cst-code = ? )
                      then do :
                        undo, return error substitute ("Закрытие накладной по ФАКТУ невозможно. Для товара &1 &2 &3 не указан номер ГТД."  ,
                                                        bf_doc-line.artic     ,
                                                        bf_doc-line.prod-type ,
                                                        bf_doc-line.prod-code ) .
                      end.
                   end.
              end.
            end.
            run adm/shattri.p (
                input "get":U
                ,input bf_trn-doc.obj-type
                ,input bf_trn-doc.obj-code
                ,input 'nakl_par':U
                ,input  "exc-max-qnty"
                ,output v-value-character
                ,output v-value-date
                ,output v-value-decimal
                ,output v-value-integer
                ,output v-value-logical
                ,output par-type
                ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
                ) no-error .
            if not error-status :error and v-value-logical = true then do :
              for each bf_doc-line no-lock
                 where bf_doc-line.obj-code = bf_trn-doc.obj-code
                   and bf_doc-line.obj-type = bf_trn-doc.obj-type
                   and bf_doc-line.doc-code = bf_trn-doc.doc-code
                   :
                   find first gds-obj no-lock
                        where gds-obj.obj-type  = bf_trn-doc.obj-type
                          and gds-obj.obj-code  = bf_trn-doc.obj-code
                          and gds-obj.artic     = bf_doc-line.artic
                          and gds-obj.prod-type = bf_doc-line.prod-type
                          and gds-obj.prod-code = bf_doc-line.prod-code no-error .
                   if available gds-obj then do :
                      find first gds-obj-prop no-lock
                            where gds-obj-prop.obj-type = gds-obj.obj-type
                              and gds-obj-prop.obj-code = gds-obj.obj-code
                              and gds-obj-prop.gds-code = gds-obj.gds-code no-error .
                      if available gds-obj-prop and gds-obj-prop.grop-max-stock <> ?
                                                and gds-obj-prop.grop-max-stock <> 0 then do :
                        if gds-obj-prop.grop-max-stock < gds-obj.fact-qnty + bf_doc-line.cli-qnty then do :
                            undo, return error substitute ("Закрытие накладной по ФАКТУ невозможно.Для товара &1 &2 &3 будет превышен максимальный остаток на объекте."  ,
                                                            bf_doc-line.artic     ,
                                                            bf_doc-line.prod-type ,
                                                            bf_doc-line.prod-code ) .
                        end.
                      end.
                   end.
               end.
            end.
        end.
        if is-add-charg = 'yes' then do:
              for each ub.add-trn no-lock where
                        ub.add-trn.trn-doc-code = bf_trn-doc.doc-code ,
                        first ub.add-doc no-lock where
                              ub.add-doc.doc-code = ub.add-trn.doc-code
                        :
                        if not  ( bf_trn-doc.base-rate  = ub.add-doc.base-rate  and
                                  bf_trn-doc.base-scale = ub.add-doc.base-scale ) then do:
                            run waitfram-hide in this-procedure no-error.
                            undo, return error substitute ( "Курс базовой валюты ПН &2 должен совпадать с курсом ДопРасха &1 .", ub.add-doc.doc-code ,bf_trn-doc.doc-code ).
                        end.
              end.
        end.
        if varstatus = 'факт':U
        then do:
          if bf_trn-doc.tot-other  <> 0 or
             bf_trn-doc.tot-transp <> 0
          then do:
            define variable v-not-calc as logical   no-undo .
               v-not-calc = false .
            if is-add-charg = 'yes' then do:
              find first ub.add-trn no-lock where
                         ub.add-trn.trn-doc-code = bf_trn-doc.doc-code no-error .
              find first ub.add-doc no-lock where
                         ub.add-doc.doc-code = ub.add-trn.doc-code no-error .
              if available ub.add-doc then do:
                v-not-calc = true .
              end.
            end.
            if v-not-calc = false then do:
                run waitfram-show in this-procedure ( input substitute( "Расчет транспортных и прочих расходов. Время: &1"
                                                    , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run str/add-exp.p (input parparentproc,
                                input bf_trn-doc.doc-code ,
                                input bf_trn-doc.tot-other  * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale,
                                input bf_trn-doc.tot-transp * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute ( "Ошибка при установке дополнительных расходов &1 &2.", return-value ).
                end.
            end.
          end.
          if is-add-charg = 'yes' then do:
             find first ub.add-trn no-lock where
                        ub.add-trn.trn-doc-code = bf_trn-doc.doc-code no-error .
             if available ub.add-trn then do:
             find first ub.add-doc no-lock where
                        ub.add-doc.doc-code = ub.add-trn.doc-code no-error .
             if not available ub.add-doc then do:
                  if parmessage = yes
                  then do:
                    assign
                      varlog = no.
                    message
                    "На документ" bf_trn-doc.doc-code skip
                    "На объекте " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                    "Нет документа дополнительных расходов."
                    view-as alert-box information .
                      run waitfram-hide in this-procedure no-error.
                      undo, return error.
                  end.
                  else do:
                      run waitfram-hide in this-procedure no-error.
                      undo, return error "Нет документа дополнительных расходов.".
                  end.
             end.
             end.
             find first ub.add-doc no-lock where
                        ub.add-doc.doc-code = ub.add-trn.doc-code no-error .
             if not available ub.add-doc then do:
                  if parmessage = yes
                  then do:
                    assign
                      varlog = no.
                    message
                    "На документ" bf_trn-doc.doc-code skip
                    "На объекте " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                    "Не создан документ дополнительных расходов."
                    "Продолжить закрытие документа?"
                    view-as alert-box buttons yes-no update varlog.
                    if varlog <> yes
                    then do:
                      run waitfram-hide in this-procedure no-error.
                      undo, return error.
                    end.
                  end.
             end.
             else do:
                if ub.add-doc.status_ <> 'закрыт':U
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute ( "Не закрыт документ дополнительного расхода &1 для ПН &2.", ub.add-doc.doc-code ,bf_trn-doc.doc-code ).
                end.
                v-is-add-doc = false .
                run many-add-docs in parparenthandle (output v-is-add-doc) no-error .
                if error-status :error then v-is-add-doc = false .
                if v-is-add-doc <> true  then do:
                    v-kol-doc = 0 .
                    for each ub.add-trn no-lock where
                             ub.add-trn.doc-code = ub.add-doc.doc-code :
                        v-kol-doc = v-kol-doc + 1 .
                    end.
                    if v-kol-doc = 1 then do:
                        run str/add-exp.p (input parparentproc,
                                        input bf_trn-doc.doc-code ,
                                        input bf_trn-doc.tot-other  * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale,
                                        input bf_trn-doc.tot-transp * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) no-error.
                        if error-status :error
                        then do:
                          run waitfram-hide in this-procedure no-error.
                          undo, return error substitute ( "Ошибка при установке дополнительных расходов &1 &2.", return-value , error-status :get-message(1) ).
                        end.
                        run str/addsuper.p
                          (input parparentproc,
                                input ub.add-doc.doc-code
                              ) no-error.
                        if error-status :error
                        then do:
                          run waitfram-hide in this-procedure no-error.
                          undo, return error substitute ( "Ошибка при размазывании дополнительных расходов в учетной цене &1 Документ ДопРасхода &2 ПН &3 .",  return-value ,ub.add-doc.doc-code , bf_trn-doc.doc-code ).
                        end.
                        run str/addclos.p
                            ( input Parparentproc,
                              recid(ub.add-doc)
                            ) no-error .
                        if error-status :error
                        then do:
                          run waitfram-hide in this-procedure no-error.
                          undo, return error substitute ( "Ошибка при закрытии ДопРасхода &1 &2.", return-value , ub.add-doc.doc-code).
                        end.
                    end.
                    else do:
                        run waitfram-hide in this-procedure no-error.
                        undo, return error  "К одному документу ДопРасхода привязано несколько ПН . Закрыть Приходные накладные можно только из интерфейса Документов ДопРасходав" .
                    end.
                end.
                else do:
                end.
             end.
          end.
          run waitfram-show in this-procedure ( input substitute( "Установка фактической даты в документе. Время: &1"
                                                                , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
          run ie-date in this-procedure no-error.
          if error-status :error
          then do:
            return error return-value.
          end.
          run waitfram-show in this-procedure
            ( input substitute( "Закрытие документа сверки '&1'. Время: &2.", 'перед_док':U, string( time - vartime, "hh:mm:ss":U ) )
            ) no-error.
          run close-rvs in this-procedure
            ( input bf_trn-doc.doc-code
             ,input 'перед_док':U
             ,input bf_trn-doc.fact-date
             ,input bf_trn-doc.fact-time
             ,input bf_trn-doc.shift-date
             ,input bf_trn-doc.shift-num
             ,input bf_trn-doc.shift-name
            ) no-error .
          if error-status :error then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error return-value.
          end.
          run waitfram-show in this-procedure ( input substitute( "Резервирование товаров по складским местам. Время &1."
                                                                , string(time - vartime, "hh:mm:ss") ) ) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_rsrplgds in g#lib-trn3
(input bf_trn-doc.doc-code
) .
          run waitfram-hide in this-procedure no-error.
          run str/in-pr.p ( input parparentproc, input recid( bf_trn-doc ), input "cost-price":U ) no-error.
          if error-status :error
          then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error return-value.
          end.
          if ( par-gen-mrgn-ie = 'before-margin':U and bf_trn-doc.ext-doc-type = 'ie':U ) or
             ( par-gen-mrgn-iv = 'before-margin':U and bf_trn-doc.ext-doc-type =  'iv':U )
          then do:
            run str/in-pr.p ( input parparentproc, input recid( bf_trn-doc ), input "before-margin" ) no-error .
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( 'Ошибка при создании автоматической переоценки. Документ "&1". '
                                          + 'Тип переоценки: &2 &3 &4.'
                                          , bf_trn-doc.doc-code
                                          , 'before-margin':U
                                          , return-value
                                          , bf_trn-doc.ext-doc-type ).
            end.
          end.
          if varnocurbas <> "yes"
          then do:
            assign
              varcount = 0.
            for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_trn-doc.doc-code on error undo, return error return-value :
              run waitfram-show in this-procedure ( input substitute( "Установка продажных цен в признаках документа. "
                                                                    + "Обработано признаков: &1. Время &2."
                                                                    , varcount
                                                                    , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
              assign
              varcount = varcount + 1.
              find first bf_goods where bf_goods.artic     = bf_gds-dtl.artic     and
                                        bf_goods.prod-type = bf_gds-dtl.prod-type and
                                        bf_goods.prod-code = bf_gds-dtl.prod-code no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varprt-b-code
  ) no-error .
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error substitute( 'Ошибка при определении бар-кода признака. Документ "&1". Товар &2 &3 &4. '
                                            + 'Код признака &5. &7'
                                            , bf_trn-doc.doc-code
                                            , bf_goods.artic
                                            , bf_goods.prod-type
                                            , bf_goods.prod-code
                                            , bf_gds-dtl.prt-code
                                            , return-value ).
              end.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varprt-b-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ) no-error .
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error substitute( 'Ошибка &1 при определении цены бар-кода. Документ "&2". Объект &3 &4. '
                                            + 'Товар &5 &6 &7. Бар-код &8.'
                                            , return-value
                                            , bf_trn-doc.doc-code
                                            , bf_trn-doc.obj-type
                                            , bf_trn-doc.obj-code
                                            , bf_goods.artic
                                            , bf_goods.prod-type
                                            , bf_goods.prod-code
                                            , varprt-b-code ).
              end.
              if varprice-sale = 0 or
                varprice-sale = ?
              then do:
                run gds-attr-value in this-procedure (input bf_goods.gds-code
                                         ,input 'null-price':U
                                         ,output v-attr-value
                                         ,output v-attr-type ) no-error.
                if (varnocurbas = "no"       or
                  varnocurbas = "no_today") and bf_trn-doc.fact-date = v-today and not logical(v-attr-value)
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( 'Не задана текущая продажная цена. Закрытие документа отменяется. '
                                              + 'Документ "&1". Объект &2 &3. Товар &4 &5 &6. Бар-код &7.'
                                              , bf_trn-doc.doc-code
                                              , bf_trn-doc.obj-type
                                              , bf_trn-doc.obj-code
                                              , bf_goods.artic
                                              , bf_goods.prod-type
                                              , bf_goods.prod-code
                                              , varprt-b-code ).
                end.
                else do:
                  if parmessage = yes
                  then do:
                    assign
                      varlog = no.
                    message
                    "В документе " bf_trn-doc.doc-code skip
                    "На объекте  " bf_trn-doc.obj-type " " bf_trn-doc.obj-code skip
                    "По товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
                    "Не задана продажная цена."
                    "Продолжить закрытие документа?"
                    view-as alert-box buttons yes-no update varlog.
                    if varlog <> yes
                    then do:
                      run waitfram-hide in this-procedure no-error.
                      undo, return error.
                    end.
                  end.
                end.
              end.
            end.
          end.
          assign
            bf_trn-doc.status_ = varstatus
            bf_trn-doc.flag_   = fact-ok
          .
          run cus/rcvsttr.p  ( input parparentproc, input recid(bf_trn-doc) ) no-error .
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error substitute( "Ошибка при обработке заказа: &1.", return-value ).
              end.
        end.
        else do:
          if bf_trn-doc.status_ = 'запрос':U and
            bf_trn-doc.flag_
          then do:
            run waitfram-show in this-procedure ( input substitute( "Генерация приходной накладной из запроса. Время: &1"
                                                                  , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
            create c-in.
            run doc-code in this-procedure
            (input  "chip",
            input  bf_trn-doc.obj-type,
            input  bf_trn-doc.obj-code,
            input  bf_trn-doc.doc-code,
            output c-in.doc-code  ) no-error.
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибка при генерации номера документа &1.", return-value ).
            end.
            buffer-copy bf_trn-doc
            except doc-code      out-code
                  acc-date      creid
                  discnt-type   discnt-pc
                  tot-calc      discnt-rubl
                  tot-lines     doc-qnty
                  fact-base     fact-rubl
                  fact-num      fact-qnty
                  cli-qnty
                  fact-date     ov
                  tot-doc       tot-fact
                  tot-ov        tot-rubl
                  tot-sale      VAT-base
                  VAT-rubl
            to c-in.
            assign
              c-in.doc-type  = 'при':U
              c-in.internal  = no
              c-in.office    = no
              c-in.status_   = varcopystatus
              c-in.flag_     = varcopyflag
              c-in.doc-date  = v-today
              c-in.ord-num   = bf_trn-doc.doc-code
              c-in.VAT-type  = bf_trn-doc.vat-type
              c-in.SLT-type  = bf_trn-doc.slt-type
              c-in.PS = "@  ПН получена из запроса : " + bf_trn-doc.doc-code + chr (10) +
                            "Для расчета итогов по документу нажмите Измен.".
            run waitfram-show in this-procedure ( input substitute( "Заполнение данных перед копированием в документ. "
                                                + "Время: &1"
                                                , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
            run fill-tt (input bf_trn-doc.doc-code) no-error.
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "Ошибка при копировании данных в накладную.".
            end.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_copy-in in g#lib-trn4
( input parparentproc
 ,input recid(c-in)
 ,input table lib-trn_ret-doc
 ,input table lib-trn_ret-line
 ,input table lib-trn_ret-line-attr
 ,input table lib-trn_ret-dtl
 ,input table lib-trn_ret-parts
 ,input yes
 ,input yes
 ,input no
 ,input yes
 ,input this-procedure
  ) no-error .
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "Ошибка при копировании данных в накладную.".
            end.
            if not can-find (first bf_doc-line where bf_doc-line.doc-code = c-in.doc-code no-lock)
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error "На основании запроса уже созданы приходные накладные. Копирование отменяется.".
            end.
          end.
          if bf_trn-doc.status_ = 'накл':U and
            bf_trn-doc.flag_   = yes
          then do:
            assign
              varcount = 0.
            for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error :
              find first bf_goods where bf_goods.artic     = bf_doc-line.artic
                                    and bf_goods.prod-code = bf_doc-line.prod-code
                                    and bf_goods.prod-type = bf_doc-line.prod-type no-lock .
              run waitfram-show in this-procedure ( input substitute( "Проверка цен в признаках документа. "
                                                                    + "Проверено признаков: &1. Время &2."
                                                                    , varcount
                                                                    , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
              assign
                varcount = varcount + 1.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) no-error.
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error return-value.
              end.
              if varis-petrol     and
                  not varis-pieces
              then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_lnfactqt in g#lib-calc
(
 input parparentproc
,input recid(bf_doc-line)
,input yes
,input bf_trn-doc.status_
,input bf_trn-doc.flag_       )
no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
                run gbl/calc-trn.p (input parparentproc, input recid(bf_trn-doc) ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
              end.
            end.
          end.
          assign
            bf_trn-doc.status_  = varstatus
            bf_trn-doc.flag_    = varflag.
        end.
        run fill-mol .
      end.
      when 'ee':U     or
      when 'ep':U  or
      when 'ev':U     or
      when 'we':U     or
      when 're':U or
      when 'rv':U or
      when 'iv':U     or
      when 'eo':U    or
      when 'io':U
      then do:
        if ( bf_trn-doc.ext-doc-type = 'ee':U    or
            bf_trn-doc.ext-doc-type = 'ep':U or
            bf_trn-doc.ext-doc-type = 're':U ) and
          varhold-doc
        then do:
          run hold-check.
        end.
        if bf_trn-doc.ext-doc-type = 'ee':U and  bf_trn-doc.contract-code > 0 and ( parmode = '<закрытие документа>':U or parmode = '<закрытие документа на факт>':U) then do:
          find first bf_contract where bf_contract.contract-code = bf_trn-doc.contract-code and bf_contract.host-code = bf_trn-doc.host-code
          and bf_contract.usl-opl <> 'Не определено' or bf_contract.usl-opl <> 'Предоплата' or bf_contract.usl-opl <> 'Предоплата'
          no-error .
          if not available bf_contract then do:
          find first bf_fin-ob-trn where bf_fin-ob-trn.trn-doc-code = bf_trn-doc.doc-code and (bf_fin-ob-trn.sum-rubl = bf_trn-doc.tot-fact or bf_fin-ob-trn.sum-rubl = (bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl)) no-error.
            if not available bf_fin-ob-trn then do:
              run str/limcontr.p ( input bf_trn-doc.host-code, input bf_trn-doc.contract-code, input 0, input bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl, input bf_trn-doc.tot-fact ) no-error .
              if error-status :error then return error return-value .
            end.
          end.
          end.
        if (bf_trn-doc.status_ = 'накл':U and bf_trn-doc.flag_ = yes  or
          parmode = '<закрытие документа на факт>':U)
          and (bf_trn-doc.contract-code <> 0  and bf_trn-doc.ext-doc-type <> 'ep':U )
        then do:
          v-not_ver-spec = false .
          run need-ver-spec ( output v-not_ver-spec ) no-error .
            assign
              varerr = no.
            bf_doc-line_cycle:
            for each bf_doc-line no-lock
               where bf_doc-line.doc-code   = bf_trn-doc.doc-code
                 and bf_doc-line.fact-qnty  <> 0
               :
              for each bf_gds-dtl no-lock
                where bf_gds-dtl.prod-type  = bf_doc-line.prod-type
                  and bf_gds-dtl.prod-code  = bf_doc-line.prod-code
                  and bf_gds-dtl.artic      = bf_doc-line.artic
                  and bf_gds-dtl.doc-code   = bf_doc-line.doc-code
              :
                find first bf_goods where bf_goods.artic     = bf_gds-dtl.artic     and
                                          bf_goods.prod-type = bf_gds-dtl.prod-type and
                                          bf_goods.prod-code = bf_gds-dtl.prod-code no-lock.
if bf_trn-doc.ext-doc-type = 'ot':U or
   bf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = bf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = bf_doc-line.artic     and
                                   out-vatp_goods.prod-type = bf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = bf_doc-line.prod-code no-lock.
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * 1)
    excise-base-sale      =  (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
    excise-base-sale      =  (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   / bf_trn-doc.base-rate * bf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if bf_doc-line.road-tax = ? then 0 else bf_doc-line.road-tax * bf_trn-doc.base-rate / bf_trn-doc.base-scale)
    excise-rubl-sale      = (if bf_doc-line.excise   = ? then 0 else bf_doc-line.excise   * bf_trn-doc.base-rate / bf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = bf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = bf_doc-line.artic
       and out-vatp_doc-line.prod-type  = bf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = bf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = bf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = bf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = bf_trn-doc.obj-code
                               and out-vatp_parts.artic      = bf_doc-line.artic
                               and out-vatp_parts.prod-type  = bf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = bf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
  discnt-base-sale            = bf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
  discnt-rubl-sale            = bf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl)
  .
if bf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = bf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = bf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc).
end.
else do:
  if bf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-base - bf_gds-dtl.discnt-base                - road-tax-base-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - varprice-base-cons) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * bf_doc-line.cons-vat-pc / (100 + bf_doc-line.cons-vat-pc) * bf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * bf_doc-line.SLT-pc / (100 + bf_doc-line.SLT-pc) - varprice-rubl-cons) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc) * bf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
                assign
                  varprice-check = price-rubl-with-tax-sale
                  .
                if ( bf_trn-doc.vat-type <> "" and bf_trn-doc.vat-type <> ? )
                then do :
                  varvat-type = substitute("&1,&2", bf_trn-doc.vat-type, bf_trn-doc.doc-code).
                end.
                else do :
                  varvat-type = substitute("&1,&2", 'в т. ч.':U, bf_trn-doc.doc-code).
                end.
                assign
                  var-host-code = bf_trn-doc.host-code
                .
                if not v-expense-return
                then do :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_ckcntspc in g#lib-trn3
( input var-host-code
 ,input bf_trn-doc.contract-code
 ,input bf_goods.gds-code
 ,input varprice-check
 ,input varvat-type
 ,input bf_doc-line.VAT-pc
) no-error .
                  if error-status :error
                  then do:
                    assign
                      varerr = yes.
                    output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
                    put    stream str-err unformatted return-value skip.
                    output stream str-err close.
                    next bf_doc-line_cycle.
                  end.
                end .
              end.
            end.
            if varerr = yes
            then do:
              if v-not_ver-spec = false then do:
              if g#auto <> yes and not g#esys then do:
                run gbl/prnfilen.w
                  (input  "Ошибки по соответствию товаров в накладной и спецификации к договору"
                  ,input  0
                  ,input  replace(bf_trn-doc.doc-code, "*", "$") + ".err"
                  ,input  7
                  ,output v-user-action
                  ,output v-printed
                  ).
              end.
              return error substitute( 'Есть ошибки по соответствию товаров в накладной и спецификации к договору. ' +
                                      'Смотри файл "&1.err"'
                                    , replace( bf_trn-doc.doc-code, "*", "$" ) ).
              end.
            end.
        end.
        if bf_trn-doc.ext-doc-type = 'ee':U
        and lookup( string(bf_trn-doc.reason-code), v-reasons-for-return) = 0
        and not v-expense-return
        then do:
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-curr-db-num
    ,input  v-curr-userid
    ,input  0
    ,input  'actn_expense_chkslpr':U
    ,input  'object':U
    ,input  bf_trn-doc.host-code
    ,input  bf_trn-doc.obj-type
    ,input  bf_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
          if varlog <> yes
          then do:
            for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkslpr in g#lib-trn3
(input bf_doc-line.doc-code
,input bf_doc-line.artic
,input bf_doc-line.prod-type
,input bf_doc-line.prod-code
) no-error.
              if error-status :error
              then do:
                assign
                  varerr = yes.
                output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
                put    stream str-err unformatted return-value skip.
                output stream str-err close.
              end.
            end.
          end.
          if varerr = yes
          then do:
            if g#auto <> yes
            then do:
              run gbl/prnfilen.w
                (  input "Ошибки по товарам, у которых цена реализации ниже цены в учетных ценах."
                ,  input 0
                ,  input replace( bf_trn-doc.doc-code, "*", "$" ) + ".err"
                ,  input 7
                , output v-user-action
                , output v-printed
                ).
            end.
            return error substitute( 'Есть ошибки по товарам, у которых цена реализации ниже цены в учетных ценах. '
                                  + 'Смотри файл "&1.err"'
                                  , replace( bf_trn-doc.doc-code, "*", "$" ) ).
          end.
        end.
        if not bf_trn-doc.flag_                and
          (bf_trn-doc.status_ = 'накл':U       or
            bf_trn-doc.status_ = 'запрос':U )
        then do:
          run waitfram-show in this-procedure ( input substitute( "Расчет шапки документа. Время: &1"
                                                                , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
          run gbl/calc-trn.p (input parparentproc, input recid( bf_trn-doc ) ) no-error.
          if error-status :error
          then do:
            run waitfram-hide in this-procedure no-error.
            undo, return error substitute( 'Ошибка при расчете документа "&1"', bf_trn-doc.doc-code ).
          end.
          if parcheck-return
          then do:
            if bf_trn-doc.doc-type = 'возврат':U  and
              bf_trn-doc.status_ <> 'запрос':U and
              bf_trn-doc.out-code <> ?
            then do:
              assign
                varlns-cnt = 0.
              for each bf_gds-dtl
                where bf_gds-dtl.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
                run waitfram-show in this-procedure ( input substitute( "Проверка суммарного возврата. "
                                                                      + "Проверено признаков: &1. Время &2."
                                                                      , varlns-cnt
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                assign
                  varlns-cnt = varlns-cnt + 1.
                run waitfram-show in this-procedure ( input "Проверка суммарного возврата...   Строка : " + string( varlns-cnt ) ).
                for each ret-doc
                  where ret-doc.out-code = bf_trn-doc.out-code
                    and ret-doc.status_ <> 'запрос':U no-lock,
                  each ret-dtl where ret-dtl.doc-code  = ret-doc.doc-code and
                                    ret-dtl.artic     = bf_gds-dtl.artic and
                                    ret-dtl.prod-code = bf_gds-dtl.prod-code and
                                    ret-dtl.prod-type = bf_gds-dtl.prod-type and
                                    ret-dtl.prt-code  = bf_gds-dtl.prt-code no-lock on error undo, return error return-value :
                    accumulate ret-dtl.fact-qnty (total).
                end.
                find exp-dtl where exp-dtl.doc-code  = bf_trn-doc.out-code  and
                                  exp-dtl.artic     = bf_gds-dtl.artic     and
                                  exp-dtl.prod-code = bf_gds-dtl.prod-code and
                                  exp-dtl.prod-type = bf_gds-dtl.prod-type and
                                  exp-dtl.prt-code  = bf_gds-dtl.prt-code no-error.
                if  available exp-dtl
                and (accum total ret-dtl.fact-qnty) > exp-dtl.doc-qnty
                then do:
                  find bf_goods where bf_goods.artic     = bf_gds-dtl.artic
                                  and bf_goods.prod-code = bf_gds-dtl.prod-code
                                  and bf_goods.prod-type = bf_gds-dtl.prod-type no-lock.
                  find bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code no-lock.
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Артикул : &1 &2 Признак : &3 Количество : &4 &5 не может быть возвращено, "
                                              + "т.к. общее количество по всем возвратным накладным тогда станет: &6 &5 - "
                                              + "больше, чем было количество в расходной накладной : &7 &5 ."
                                              , bf_goods.artic
                                              , bf_goods.gds-name
                                              , bf_gds-prt.node-name
                                              , bf_gds-dtl.fact-qnty
                                              , bf_goods.unit-base
                                              , ( accum total ret-dtl.fact-qnty )
                                              , exp-dtl.doc-qnty ).
                end.
              end.
            end.
          end.
          if can-do ('рас,спи':U, bf_trn-doc.doc-type)
          then do:
            assign
              varcount = 0.
            for each bf_doc-line
              where bf_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
              run waitfram-show in this-procedure ( input substitute( "Проверка переоценки по новому приходу. "
                                                                    + "Проверено строк: &1. Время &2."
                                                                    , varlns-cnt
                                                                    , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
              assign
                varcount = varcount + 1.
              find first bf_goods no-lock
                where bf_goods.prod-type = bf_doc-line.prod-type
                  and bf_goods.prod-code = bf_doc-line.prod-code
                  and bf_goods.artic     = bf_doc-line.artic.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  bf_doc-line.obj-type
  ,input  bf_doc-line.obj-code
  ,input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,input  'in-ov=request'
  ,output l-in-ov
  ) no-error .
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                return error substitute( "Ошибка получения признака товара на объекте &1.", return-value ).
              end.
              if  bf_trn-doc.status_ <> 'запрос':U
              and l-in-ov
              and parin-ov
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error substitute( "Артикул : &1 &2 По товару был новый приход. Требуется переоценка. "
                                            + "Закрытие невозможно. &3&4 "
                                            , bf_doc-line.artic
                                            , bf_goods.gds-name
                                            , bf_doc-line.obj-type
                                            , bf_doc-line.obj-code
                                            ).
              end.
            end.
          end.
          if bf_trn-doc.doc-type = 'рас':U and
            bf_trn-doc.status_  = 'накл':U
          then do:
            bf_trn-doc.rsrv-date = v-today + parrsrv-time.
          end.
          if bf_trn-doc.internal              and
            bf_trn-doc.doc-type = 'рас':U and
            bf_trn-doc.status_  = 'накл':U
          then do:
            if bf_trn-doc.obj-type = 'скл':U then
              bf_trn-doc.rsrv-date = v-today + parload-time.
            do while can-do (parholidays, string (weekday (bf_trn-doc.rsrv-date) ) ) :
              bf_trn-doc.rsrv-date = bf_trn-doc.rsrv-date + 1.
            end.
            if substr (bf_trn-doc.PS, 1, 1) = "@" then bf_trn-doc.PS = bf_trn-doc.PS + "          Время отгрузки :   9 час 00 мин".
          end.
          if ( bf_trn-doc.ext-doc-type = 'ee':U or
               bf_trn-doc.ext-doc-type = 'ep':U
              )
          and parmode = '<закрытие документа на факт>':U and bf_trn-doc.status_ = 'накл':U then do:
              run ie-date in this-procedure.
          end.
          assign
            bf_trn-doc.status_ = varstatus
            bf_trn-doc.flag_   = varflag.
            if     bf_trn-doc.status_ eq 'факт':U
                   and bf_trn-doc.flag_
            then do:
               crUtdReturn(bf_trn-doc.doc-code).
            end.
           if bf_trn-doc.ext-doc-type = 'iv':U and
              bf_trn-doc.status_      = 'запрос':U and
              bf_trn-doc.flag_        = true then do:
              define variable v-obj-is-active as logical   no-undo .
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  bf_trn-doc.cli-type
  ,input  bf_trn-doc.cli-code
  ,input  'active=request'
  ,output v-obj-is-active
  ) no-error .
                if v-obj-is-active = true then do:
                     run cus/ord-mrz.p ( parparentproc , recid(bf_trn-doc)) no-error .
                end.
           end.
           if varstatus = 'факт':U then do:
              if (bf_trn-doc.ext-doc-type = 're':U OR
                  bf_trn-doc.ext-doc-type = 'ee':U) and
                (bf_trn-doc.d-card       <> "" and
                bf_trn-doc.d-card       <> ?)
              then do:
                find first bf_dis-card where bf_dis-card.d-card = bf_trn-doc.d-card no-lock no-error.
                if available bf_dis-card
                then do:
                  run waitfram-show in this-procedure ( input substitute( "Обновление информации о дисконтной карте. "
                                                                        + "Время: &1"
                                                                        , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                  run str/saledc.p ( INPUT parparentproc
                              ,input ?
                              ,input ?
                              ,input 'trn-doc-close':U
                              ,input ?
                              ,input ""
                              ,input 0
                              ,input 0
                              ,input 0
                              ,INPUT pardb-num
                              ,INPUT bf_trn-doc.doc-code
                              ,input bf_trn-doc.doc-date
                              ,input bf_trn-doc.fact-date
                              ,input ?
                              ,input 1
                              ,input (if bf_trn-doc.ext-doc-type = 're':U
                                      then -1
                                      else  1)
                              ,input yes
                              ) no-error .
                  if error-status :error
                  then do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error substitute("Ошибка при проведении платежа по дисконтной карте.&1&2&1&3"
                                                  , chr(10)
                                                  , error-status:get-message(1)
                                                  , return-value ).
                  end.
                end.
                else do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Не найдена дисконтная карта &1 по документу.", bf_trn-doc.d-card ).
                end.
              end.
           end.
        end.
        else do:
          case bf_trn-doc.status_ :
            when 'запрос':U
            then do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_resv-inqv in g#lib-trn3
(input  bf_trn-doc.doc-code,
 output is-no
)
.
              if is-no = true
              then do:
                run waitfram-show in this-procedure ( input substitute( "Резервирование по запросу. Время: &1"
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                v-is-ord-doc = false .
                run cloce-ord in parparenthandle (output v-is-ord-doc) no-error .
                if error-status :error then v-is-ord-doc = false .
                v-is-negostmess = true .
                run cb_cloce-quest-neg in parparenthandle (output v-is-negostmess) no-error .
                if error-status :error then v-is-negostmess = true .
                if v-is-ord-doc then
                   run str/rv-out.p ( input parparentproc, input this-procedure , input bf_trn-doc.doc-code , yes, v-is-negostmess ) no-error.
                else
                   run str/rv-out.p ( input parparentproc, input this-procedure , input bf_trn-doc.doc-code , no , v-is-negostmess ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error  substitute("Ошибка из процедуры резервирования по запросу rv-out.p &1 &2" , return-value ,  error-status :get-message(1) ) .
                end.
                run waitfram-show in this-procedure ( input substitute( "Пересчет шапки документа. Время: &1"
                                                    , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run gbl/calc-trn.p ( input parparentproc, input recid( bf_trn-doc ) ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при расчете документа &1 &2 &3.", bf_trn-doc.doc-code , return-value , error-status :get-message(1) ).
                end.
              end.
              else do:
                run waitfram-show in this-procedure ( input substitute( "Создание накладной по запросу. Время: &1"
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run str/fl-out.p ( input parparentproc, input bf_trn-doc.doc-code ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error "Ошибка из процедуры создания запроса по нетоварным позициям fl-out.p." + return-value + error-status :get-message(1)  .
                end.
                run waitfram-hide in this-procedure no-error.
              end.
            end.
            when 'накл':U or
            when 'разрешен':U
            then do:
              if bf_trn-doc.doc-type <> 'при':U and bf_trn-doc.status_ = 'накл':U
              then do:
                run waitfram-show in this-procedure ( input substitute( "Пересчет шапки документа. Время: &1"
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run gbl/calc-trn.p ( input parparentproc, input recid( bf_trn-doc ) ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при расчете документа &1 &2 &3.", bf_trn-doc.doc-code , return-value , error-status :get-message(1) ).
                end.
                if bf_trn-doc.ext-doc-type = 'eo':U then do :
                    run ie-date in this-procedure.
                end.
                assign bf_trn-doc.status_ = varstatus.
                if bf_trn-doc.doc-type = 'рас':U
                then do:
                  if bf_trn-doc.obj-type = 'скл':U
                  then do:
                    assign
                        bf_trn-doc.rsrv-date = v-today + parload-time
                    .
                  end.
                  do while can-do( parholidays, string( weekday( bf_trn-doc.rsrv-date ) ) ) :
                    assign
                      bf_trn-doc.rsrv-date = bf_trn-doc.rsrv-date + 1.
                  end.
                  find bf_clients where bf_clients.obj-type = bf_trn-doc.obj-type
                                  and bf_clients.obj-code = bf_trn-doc.obj-code no-lock.
                  if substr (bf_trn-doc.PS, 1, 1) = "@"
                  then do:
                    if substr (bf_clients.PS, 1, 1) = "@"
                    then do:
                      bf_trn-doc.PS = "  Курс : " + string (bf_trn-doc.base-rate) + "    " + substr (bf_clients.PS, 2).
                    end.
                    else do:
                      assign
                        bf_trn-doc.PS = bf_trn-doc.PS + "          Время отгрузки :   9 час 00 мин".
                    end.
                  end.
                end.
              end.
              else do:
              if bf_trn-doc.status_ = 'разрешен':U or
                  (bf_trn-doc.doc-type = 'при':U  and
                  bf_trn-doc.status_  = 'накл':U    and
                  bf_trn-doc.doc-type <> 'инв':U)
              then do:
                assign
                  varcount = 0.
                for each  bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code
                  on error undo, return error return-value :
                  find first bf_goods where bf_goods.artic     = bf_doc-line.artic
                                        and bf_goods.prod-code = bf_doc-line.prod-code
                                        and bf_goods.prod-type = bf_doc-line.prod-type no-lock.
                  run waitfram-show in this-procedure ( input substitute( "Проверка количеств в строках документа. "
                                                                        + "Проверено строк: &1. Время &2."
                                                                        , varcount
                                                                        , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                  assign
                    varcount = varcount + 1.
                  if bf_doc-line.doc-qnty <> bf_doc-line.fact-qnty
                  then do:
                    fact-ok = no.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) no-error.
                    if error-status :error
                    then do:
                      undo, return error return-value.
                    end.
                    if varis-petrol     and
                      not varis-pieces
                    then do:
                      if round(bf_doc-line.doc-qnty, 1) < round(bf_doc-line.fact-qnty, 1)
                      then do:
                        undo, return error substitute("Артикул : &1 &2 Количество по строке накладной: &3 &4 Фактическое количество по строке: &5 &6. Фактическое количество не может быть быть больше !" ,
                                                bf_doc-line.artic,
                                                bf_goods.gds-name,
                                                bf_doc-line.doc-qnty,
                                                bf_goods.unit-base,
                                                bf_doc-line.fact-qnty,
                                                bf_goods.unit-base).
                      end.
                    end.
                    else do:
                      if bf_doc-line.doc-qnty < bf_doc-line.fact-qnty
                      then do:
                        run waitfram-hide in this-procedure no-error.
                        undo, return error substitute( "Артикул : &1 &2 Количество по строке накладной: &3 &4 "
                                                    + "Фактическое количество по строке: &5 &4. "
                                                    + "Фактическое количество не может быть больше !"
                                                    , bf_doc-line.artic
                                                    , bf_goods.gds-name
                                                    , bf_doc-line.doc-qnty
                                                    , bf_goods.unit-base
                                                    , bf_doc-line.fact-qnty ).
                      end.
                    end.
                  end.
                end.
                run str/raspdelv.p (input parparentproc, input bf_trn-doc.doc-code) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при размазывании наценки &1.", bf_trn-doc.doc-code ).
                end.
                run waitfram-show in this-procedure ( input substitute( "Пересчет шапки документа. Время: &1"
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run gbl/calc-trn.p ( input parparentproc, input recid( bf_trn-doc ) ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при расчете документа &1.", bf_trn-doc.doc-code ).
                end.
                run str/fltransp.p (input parparentproc, input bf_trn-doc.doc-code  ) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при включении доставки (транспортные расходы) в цену &1."
                                              , bf_trn-doc.doc-code ).
                end.
                if varstatus           = 'факт':U
                and bf_trn-doc.internal
                and bf_trn-doc.doc-type = 'при':U
                and bf_trn-doc.obj-type = 'маг':U
                and can-find (first ub.scales-grp no-lock)
                then do:
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_add-scal in g#lib-trn3
(input parparentproc
,input bf_trn-doc.obj-type
,input bf_trn-doc.obj-code
,input bf_trn-doc.doc-code
,input bf_trn-doc.doc-type
,input this-procedure
) no-error.
                  if error-status :error
                  then do:
                    undo, return error return-value.
                  end.
                end.
                run waitfram-show in this-procedure ( input substitute( "Проверка и установка фактической даты в документе. "
                                                                      + "Время: &1"
                                                                      , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                if (bf_trn-doc.fact-date <> ? or bf_trn-doc.shift-date <> ?)
                then do:
                  if not
                    (bf_trn-doc.ext-doc-type = 'ee':U          or
                      bf_trn-doc.ext-doc-type = 'ep':U       or
                      bf_trn-doc.ext-doc-type = 're':U      or
                      bf_trn-doc.ext-doc-type = 'rs':U or
                      bf_trn-doc.ext-doc-type = 'we':U          or
                      bf_trn-doc.ext-doc-type = 'io':U           )
                  then do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error substitute( "Для расширенного типа документа &1 недопустима установка фактической даты."
                                                , bf_trn-doc.ext-doc-type ).
                  end.
                end.
                run ie-date in this-procedure.
                if (bf_trn-doc.ext-doc-type = 're':U OR
                    bf_trn-doc.ext-doc-type = 'ee':U) and
                  (bf_trn-doc.d-card       <> "" and
                  bf_trn-doc.d-card       <> ?)
                then do:
                  find first bf_dis-card where bf_dis-card.d-card = bf_trn-doc.d-card no-lock no-error.
                  if available bf_dis-card
                  then do:
                    run waitfram-show in this-procedure ( input substitute( "Обновление информации о дисконтной карте. "
                                                                          + "Время: &1"
                                                                          , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                    run str/saledc.p ( INPUT parparentproc
                                ,input ?
                                ,input ?
                                ,input 'trn-doc-close':U
                                ,input ?
                                ,input ""
                                ,input 0
                                ,input 0
                                ,input 0
                                ,INPUT pardb-num
                                ,INPUT bf_trn-doc.doc-code
                                ,input bf_trn-doc.doc-date
                                ,input bf_trn-doc.fact-date
                                ,input ?
                                ,input 1
                                ,input (if bf_trn-doc.ext-doc-type = 're':U
                                        then -1
                                        else  1)
                                ,input yes
                                ) no-error .
                    if error-status :error
                    then do:
                      run waitfram-hide in this-procedure no-error.
                      undo, return error substitute("Ошибка при проведении платежа по дисконтной карте.&1&2&1&3"
                                                    , chr(10)
                                                    , error-status:get-message(1)
                                                    , return-value ).
                    end.
                  end.
                  else do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error substitute( "Не найдена дисконтная карта &1 по документу.", bf_trn-doc.d-card ).
                  end.
                end.
                if varstatus = 'факт':U then do:
                  run waitfram-show in this-procedure
                    ( input substitute( "Закрытие документа сверки '&1'. Время: &2.", 'перед_док':U, string( time - vartime, "hh:mm:ss":U ) )
                    ) no-error.
                  run close-rvs in this-procedure
                    ( input bf_trn-doc.doc-code
                     ,input 'перед_док':U
                     ,input bf_trn-doc.fact-date
                     ,input bf_trn-doc.fact-time
                     ,input bf_trn-doc.shift-date
                     ,input bf_trn-doc.shift-num
                     ,input bf_trn-doc.shift-name
                    ) no-error .
                  if error-status :error then do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error return-value.
                  end.
                  run waitfram-hide in this-procedure no-error.
                end.
                run str/in-pr.p ( parparentproc, recid (bf_trn-doc) , "cost-price") no-error .
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при создании автоматической переоценки. Документ &1 Тип переоценки 'cost-price2' &2 &3.",
                                                bf_trn-doc.doc-code,
                                                return-value,
                                                bf_trn-doc.ext-doc-type).
                end.
                if ( par-gen-mrgn-ie = 'before-margin':U and bf_trn-doc.ext-doc-type = 'ie':U )  or
                   ( par-gen-mrgn-iv = 'before-margin':U and bf_trn-doc.ext-doc-type =  'iv':U ) then do:
                  run str/in-pr.p (parparentproc, recid (bf_trn-doc) , "before-margin" ) no-error .
                  if error-status :error
                  then do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error substitute( "Ошибка при создании автоматической переоценки. Документ &1 Тип переоценки:: &2 &3 &4 .",
                                                  bf_trn-doc.doc-code,
                                                  'before-margin':U,
                                                  return-value,
                                                  bf_trn-doc.ext-doc-type).
                  end.
                end.
                if varstatus               = 'факт':U            and
                  bf_trn-doc.ext-doc-type = 'ee':U
                then do:
                  run waitfram-show in this-procedure (substitute( "Формирование документа смены типа приобретения. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                  run str/parts-pc.p (
                      input parparentproc
                    , input bf_trn-doc.doc-code
                    , input 3
                    , input 1
                    , input 'факт':U
                    , input bf_trn-doc.fact-date
                    , input bf_trn-doc.fact-time
                    , input bf_trn-doc.shift-date
                    , input bf_trn-doc.shift-num
                    , input bf_trn-doc.shift-name
                    ) no-error .
                  if error-status :error
                  then do:
                    run waitfram-hide in this-procedure no-error.
                    undo, return error return-value.
                  end.
                end.
                assign
                  bf_trn-doc.status_ = varstatus
                  bf_trn-doc.flag_   = fact-ok
                .
                if     bf_trn-doc.status_ eq 'факт':U
                   and bf_trn-doc.flag_
                then do:
                   crUtdReturn(bf_trn-doc.doc-code).
                end.
                run cus/rcvsttr.p  ( parparentproc , recid(bf_trn-doc) ) no-error .
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error substitute( "Ошибка при обработке заказа: &1.", return-value ).
                end.
              end.
              end.
            end.
            otherwise do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибочный статус &1 для закрытия.", bf_trn-doc.status_).
            end.
          end case.
        end.
        if bf_trn-doc.ext-doc-type = 'ep':U
        or bf_trn-doc.ext-doc-type = 'ee':U
        or bf_trn-doc.ext-doc-type = 'we':U
        then do :
          run fill-mol .
        end .
      end.
      when 'vt':U              or
      when 'ap':U   or
      when 'pc':U   or
      when 'mp':U or
      when 'vp':U
      then do:
        if bf_trn-doc.ext-doc-type = 'vt':U
        then do:
          if bf_trn-doc.status_ = 'накл':U
          then do:
              if bf_trn-doc.flag_ = no
              then do:
                assign
                  bf_trn-doc.flag_   = varflag
                  bf_trn-doc.status_ = varstatus.
              end.
              else do:
                run waitfram-show in this-procedure (substitute( "Заполнение документа инвентаризации. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_filinvon in g#lib-trn2
(input  bf_trn-doc.doc-code,
 input  bf_trn-doc.status_,
 input  bf_trn-doc.flag_,
 input  yes,
 input  this-procedure,
 output parchg-inv,
 output table gds-list
) no-error
.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
                assign
                  bf_trn-doc.flag_   = varflag
                  bf_trn-doc.status_ = varstatus
                .
              end.
          end.
          else do:
            if bf_trn-doc.status_ = 'разрешен':U
            then do:
                run waitfram-show in this-procedure (substitute( "Заполнение и закрытие документа инвентаризации на факт. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
                run inv-fact ( input  recid(bf_trn-doc),
                              input  bf_trn-doc.status_,
                              input  bf_trn-doc.flag_,
                              output varflag) no-error .
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
                assign
                bf_trn-doc.flag_   = varflag
                bf_trn-doc.status_ = varstatus.
            end.
            else do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибочный статус &1 для закрытия.", bf_trn-doc.status_).
            end.
          end.
          run fill-mol .
        end.
        else do:
          if bf_trn-doc.ext-doc-type = 'ap':U   or
            bf_trn-doc.ext-doc-type = 'mp':U or
            bf_trn-doc.ext-doc-type = 'vp':U
          then do:
            if bf_trn-doc.status_ = 'накл':U and
              bf_trn-doc.flag_   = no
            then do:
              run waitfram-show in this-procedure (substitute( "Заполнение документа инвентаризации. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_filinvon in g#lib-trn2
(input  bf_trn-doc.doc-code,
 input  bf_trn-doc.status_,
 input  bf_trn-doc.flag_,
 input  yes,
 input  this-procedure,
 output parchg-inv,
 output table gds-list
) no-error
.
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error return-value.
              end.
              run waitfram-show in this-procedure (substitute( "Пересчет шапки документа инвентаризации. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_calc-inv in g#lib-trn
(
input recid(bf_trn-doc),
input this-procedure
)
no-error.
              if error-status :error
              then do:
                run waitfram-hide in this-procedure no-error.
                undo, return error return-value.
              end.
              if bf_trn-doc.fact-date  <> ? or
                  bf_trn-doc.shift-date <> ? then do:
                run gbl/chk-date.p
                  ( input bf_trn-doc.obj-type
                  , input bf_trn-doc.obj-code
                  , input bf_trn-doc.fact-date
                  , input bf_trn-doc.fact-time
                  , input bf_trn-doc.shift-date
                  , input bf_trn-doc.shift-num
                  , yes).
                run corr-date in this-procedure
                    ( input bf_trn-doc.obj-type
                    , input bf_trn-doc.obj-code
                    , input bf_trn-doc.fact-date
                    , input bf_trn-doc.shift-date
                    , input bf_trn-doc.shift-num
                    , input bf_trn-doc.shift-name
                  ).
                if bf_trn-doc.fact-date < v-today then do:
                  assign
                    bf_trn-doc.is-back-date = yes.
                end.
                else do:
                  if bf_trn-doc.shift-date <> ? then do:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varobj-shift-date
  ,output varobj-shift-num
  ,output varobj-shift-name
  )  .
                    if not (bf_trn-doc.shift-date = varobj-shift-date and
                            bf_trn-doc.shift-num  = varobj-shift-num  )   then do:
                      assign
                        bf_trn-doc.is-back-date = yes.
                    end.
                  end.
                end.
              end.
              else do:
                run ver-inv-date-close (bf_trn-doc.doc-code , v-today ) no-error .
                if error-status :error then do:
                  undo, return error  substitute(" Ошибка при установке даты закрытия в документе Инвентаризации &1" , return-value   ) .
                end.
                run gbl/factdate.p (input        bf_trn-doc.obj-type,
                                input        bf_trn-doc.obj-code,
                                input-output bf_trn-doc.fact-date,
                                input-output bf_trn-doc.fact-time,
                                input-output bf_trn-doc.shift-date,
                                input-output bf_trn-doc.shift-num,
                                input-output bf_trn-doc.shift-name,
                                input        yes) no-error.
                if error-status :error then do:
                  undo, return error substitute(" Ошибка при установке даты в документе(trn-doc) &1 &2" , return-value , error-status :get-message(1)  ) .
                end.
              end.
              assign
                bf_trn-doc.flag_   = varflag
                bf_trn-doc.status_ = varstatus.
            end.
            else do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибочный статус-флаг &1-&2 для закрытия.", bf_trn-doc.status_, bf_trn-doc.flag_).
            end.
          end.
          else do:
            run waitfram-hide in this-procedure no-error.
            undo, return error substitute( "Некорректный тип-расширенный_тип-статус-флаг &1-&2-&3-&4 документа &5.", bf_trn-doc.doc-type, bf_trn-doc.ext-doc-type, bf_trn-doc.status_, bf_trn-doc.flag_, bf_trn-doc.doc-code).
          end.
        end.
        if bf_trn-doc.status_ = 'факт':U
        then do:
            run ver-inv-date-close (bf_trn-doc.doc-code , v-today ) no-error .
            if error-status :error then do:
              undo, return error  substitute(" Ошибка при установке даты закрытия в документе Инвентаризации: &2&1" , return-value , chr(10)   ) .
            end.
        end.
      end.
      when 'em':U           or
      when 'im':U           or
      when 'es':U     or
      when 'rs':U
      then do:
      end.
      otherwise do:
        run waitfram-hide in this-procedure no-error.
        undo, return error substitute( "Неизвестный расширенный тип документа &1.",bf_trn-doc.ext-doc-type).
      end.
      end case.
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#libtfarh) <> true) then do:   run str/libtfarh.p persistent no-error .   if error-status :error or (valid-handle(g#libtfarh) <> true) then do:     message       "Error starting libtfarh.p" skip       g#libtfarh skip       g#libtfarh :type skip       g#libtfarh :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libtfarh_st-fo in g#libtfarh
(input  bf_trn-doc.doc-code
) .
      if bf_trn-doc.status_ = 'факт':U
      then do:
        define buffer buf_parts for ub.parts  .
        if bf_trn-doc.ext-doc-type = 'we':U
        or bf_trn-doc.ext-doc-type = 'vt':U
        then do:
          define buffer buf_doc-line for ub.doc-line  .
          define buffer buf_doc-line-attr for ub.doc-line-attr  .
          define buffer buf_goods for ub.goods .
          define variable v-gtin-qnty as character no-undo .
          define variable v-gtin as character no-undo .
          EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code).
          LK_RECEIPT_ :
          for each buf_doc-line no-lock where buf_doc-line.doc-code = bf_trn-doc.doc-code,
          first buf_goods no-lock  where buf_goods.artic = buf_doc-line.artic
                                     and buf_goods.prod-code = buf_doc-line.prod-code
                                     and buf_goods.prod-type = buf_doc-line.prod-type
          :
            if bf_trn-doc.ext-doc-type = 'vt':U
            and buf_doc-line.fact-qnty >= 0
            then next LK_RECEIPT_ .
            v-gtin-qnty = "" .
            RUN gds-attr-value (
                                INPUT buf_goods.gds-code,
                                INPUT 'mark-type':U,
                                OUTPUT varvalue,
                                OUTPUT vartype
                                ).
            if varvalue = "antiseptic" then next LK_RECEIPT_ .
            if varvalue > ""
            and EDOParSec:GetIsArticForType(varvalue)
            then do:
              for each buf_parts no-lock where buf_parts.out-code = buf_doc-line.doc-code
                                           and buf_parts.obj-type = buf_doc-line.obj-type
                                           and buf_parts.obj-code = buf_doc-line.obj-code
                                           and buf_parts.artic = buf_doc-line.artic
                                           and buf_parts.prod-type = buf_doc-line.prod-type
                                           and buf_parts.prod-code = buf_doc-line.prod-code
              :
                if num-entries(buf_parts.part-code, "_") = 2
                then do :
                  v-gtin = entry(1, buf_parts.part-code, "_") .
                  if length(v-gtin) = 8
                  or length(v-gtin) = 12
                  or length(v-gtin) = 13
                  or length(v-gtin) = 14
                  then do :
                    v-gtin-qnty = v-gtin-qnty + v-gtin + "=" + string(integer(abs(buf_parts.qnty))) + ";" .
                  end .
                end .
              end .
            end .
            v-gtin-qnty = trim(v-gtin-qnty, ";") .
            if v-gtin-qnty > ""
            then do :
              find first buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = buf_doc-line.doc-code
                                                            and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                                            and buf_doc-line-attr.attr-code = "GTIN-qnty"
                                                            no-error .
              if not available buf_doc-line-attr
              then do :
                create buf_doc-line-attr .
                assign
                  buf_doc-line-attr.doc-code = buf_doc-line.doc-code
                  buf_doc-line-attr.gds-code = buf_goods.gds-code
                  buf_doc-line-attr.attr-code = "GTIN-qnty"
                .
              end .
              buf_doc-line-attr.attr-value = v-gtin-qnty .
            end .
          end .
        end .
        release bf_trn-doc.
        find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
        for each buf_parts no-lock where
                buf_parts.out-code = bf_trn-doc.doc-code and
                buf_parts.obj-type = bf_trn-doc.obj-type and
                buf_parts.obj-code = bf_trn-doc.obj-code :
          if buf_parts.status_ <> true then do:
            message  'Нарушена целостность документа ! Проверьте свободную , расходную зону и партии документа'  view-as alert-box error .
            undo, return error "Документ закрыть нельзя. Требуется проверка" .
          end.
        end.
        run waitfram-show in this-procedure (substitute( "Локирование товаров при закрытии документа. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
        run trg/lock-gds.p
          (input bf_trn-doc.doc-code
          ,input no
          ,input no
          ,input 0
          ,input 0
          ,input false
          ,input false
          ) no-error .
        if error-status :error
        then do:
          run waitfram-hide in this-procedure no-error.
          undo, return error .
        end.
        if bf_trn-doc.is-back-date = yes
        then do:
          if search ("add-doc.err") <> ?
          then do:
            os-delete "add-doc.err".
          end.
          assign varcount  = 0 .
          for each bf_doc-line
            where bf_doc-line.doc-code = bf_trn-doc.doc-code
          on error undo, return error
          :
            run waitfram-show in this-procedure (substitute( "Проверка возможности добавления линии документа. Проверено признаков: &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss") ) ) no-error.
            assign
              varcount = varcount + 1.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_chkaddln in g#lib-trn
  (
    input v-curr-db-num
  , input v-curr-userid
  , input bf_trn-doc.obj-type
  , input bf_trn-doc.obj-code
  , input bf_doc-line.artic
  , input bf_doc-line.prod-type
  , input bf_doc-line.prod-code
  , input bf_doc-line.doc-code
  , input bf_trn-doc.fact-order
  , input bf_trn-doc.doc-type
  , input bf_trn-doc.ext-doc-type
  , input bf_trn-doc.shift-date
  , input bf_trn-doc.shift-num
  , input bf_doc-line.fact-qnty
  , input 'add-doc.err'
  ) no-error.
            if error-status :error
            then do:
              if search ("add-doc.err") <> ?
              then do:
                run gbl/prnfilen.w
                  (input  "Ошибка при проверке возможности добавления линии в документ прошедшей датой"
                  ,input  0
                  ,input  "add-doc.err"
                  ,input  7
                  ,output v-user-action
                  ,output v-printed
                  ).
              end.
              run waitfram-hide in this-procedure no-error.
              undo, return error "Ошибка при проверке возможности добавления линии в документ прошедшей датой.".
            end.
          end.
        end.
        run waitfram-show in this-procedure
          ( input substitute( "Закрытие документа сверки '&1'. Время: &2.", 'после_док':U, string( time - vartime, "hh:mm:ss":U ) )
          ) no-error.
        run close-rvs in this-procedure
          ( input bf_trn-doc.doc-code
           ,input 'после_док':U
           ,input bf_trn-doc.fact-date
           ,input bf_trn-doc.fact-time
           ,input bf_trn-doc.shift-date
           ,input bf_trn-doc.shift-num
           ,input bf_trn-doc.shift-name
          ) no-error .
        if error-status :error then do:
          run waitfram-hide in this-procedure no-error.
          undo, return error return-value.
        end.
        if bf_trn-doc.ext-doc-type = 'ie':U or
          bf_trn-doc.ext-doc-type = 'iv':U
        then do:
          if ( par-gen-mrgn-ie = 'after-margin':U and bf_trn-doc.ext-doc-type = 'ie':U ) or
             ( par-gen-mrgn-iv = 'after-margin':U and bf_trn-doc.ext-doc-type = 'iv':U )
          then do:
            run str/in-pr.p ( parparentproc, recid (bf_trn-doc) , "after-margin" ) no-error .
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибка при создании автоматической переоценки. Документ &1. Тип переоценки 'after-margin' &2 &3 .",
                                            bf_trn-doc.doc-code,
                                            return-value,
                                            bf_trn-doc.ext-doc-type) .
            end.
          end.
        end.
        if bf_trn-doc.ext-doc-type = 'ie':U     or
          bf_trn-doc.ext-doc-type = 're':U or
          bf_trn-doc.ext-doc-type = 'iv':U     or
          bf_trn-doc.ext-doc-type = 'rv':U
        then do:
          if varminus-parts = yes
          then do:
            run waitfram-show in this-procedure (substitute( "Формирование документа автоматической компенсации отрицательных партий. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
            run str/deadprts.p ( bf_trn-doc.doc-code, parparentproc) no-error.
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error return-value.
            end.
            run waitfram-show in this-procedure (substitute( "Формирование документа смены типа приобретения. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
            run str/parts-pc.p (
                input parparentproc
              , input bf_trn-doc.doc-code
              , input 3
              , input 1
              , input 'факт':U
              , input bf_trn-doc.fact-date
              , input bf_trn-doc.fact-time
              , input bf_trn-doc.shift-date
              , input bf_trn-doc.shift-num
              , input bf_trn-doc.shift-name
              ) no-error .
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error return-value.
            end.
          end.
        end.
        run waitfram-show in this-procedure (substitute( "Формирование оборотов покупателей. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
        run ref/calctur3.p ( input bf_trn-doc.doc-code) no-error .
        run str/vtrecalc.p ( input parparentproc , input recid (bf_trn-doc)) no-error .
        if error-status :error then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error return-value.
        end.
        if bf_trn-doc.ext-doc-type = 'ie':U  then do:
        run cus/edocsord.p (  input parParentProc
                            , input recid(bf_trn-doc)
                            , input 'trn-doc':U
                            , input yes
                            ) no-error  .
            if error-status :error
            then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Ошибка при обработке заказа: &1.", return-value ).
            end.
        end.
        if bf_trn-doc.ext-doc-type = 'ie':U
        or bf_trn-doc.ext-doc-type = 'iv':U
        then do:
          define buffer buf_recipe-gds for ub.recipe-gds .
          define buffer buf_recipe for ub.recipe .
          define buffer buf_marking-lines for ub.marking-lines .
          define buffer buf_marking for ub.marking .
          define variable v-production-only as logical no-undo .
          define variable v-num-recipes as integer no-undo .
          define variable v-0-recipes-gds-list as character no-undo .
          define variable v-many-recipes-gds-list as character no-undo .
          define variable v-recipe-code like ub.recipe.recipe-code .
          define variable v-ingr-gds-code as integer no-undo .
          define variable v-koef-qnty as decimal no-undo .
          define variable v-isweighed as logical no-undo .
          EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(bf_trn-doc.obj-type, bf_trn-doc.obj-code).
          doc-line_ :
          for each bf_doc-line no-lock where bf_doc-line.doc-code = bf_trn-doc.doc-code,
          first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic
                                   and bf_goods.prod-type = bf_doc-line.prod-type
                                   and bf_goods.prod-code = bf_doc-line.prod-code
          :
            if bf_doc-line.fact-qnty <= 0 then next doc-line_ .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  bf_goods.gds-code
  ,input  'production-only=request':u
  ,output v-production-only
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении атрибута товара" skip
                "Код товара" bf_goods.gds-code skip
                'production-only=request':u skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            if v-production-only
            then do :
              assign v-num-recipes = 0 .
              for each buf_recipe-gds no-lock where buf_recipe-gds.artic     = bf_goods.artic
                                                and buf_recipe-gds.prod-type = bf_goods.prod-type
                                                and buf_recipe-gds.prod-code = bf_goods.prod-code,
              each buf_recipe no-lock where buf_recipe.recipe-code = buf_recipe-gds.recipe-code
                                        and buf_recipe.recipe-type = 'альтернатива':U
                                        and buf_recipe.stts       <> 2
              :
                assign
                  v-num-recipes   = v-num-recipes + 1
                  v-recipe-code   = buf_recipe.recipe-code
                  v-ingr-gds-code = buf_recipe.gds-code
                  v-koef-qnty     = buf_recipe-gds.qnty
                .
              end .
              if v-num-recipes = 0
              then do :
                assign v-0-recipes-gds-list = v-0-recipes-gds-list + string(bf_goods.gds-code) + " " + bf_goods.gds-name + ", " .
              end .
              else
              if v-num-recipes <> 1
              then do :
                assign v-many-recipes-gds-list = v-many-recipes-gds-list + string(bf_goods.gds-code) + " " + bf_goods.gds-name + ", " .
              end .
              else do :
                create tt-fbr-line .
                assign
                  tt-fbr-line.gds-code = bf_goods.gds-code
                  tt-fbr-line.gds-name = bf_goods.gds-name
                  tt-fbr-line.qnty     = bf_doc-line.fact-qnty * v-koef-qnty
                  tt-fbr-line.recipe-code = v-recipe-code
                  tt-fbr-line.recipe-type = 'альтернатива':U
                  tt-fbr-line.ingr-gds-code = v-ingr-gds-code
                .
                v-isweighed = WghProdVariable(bf_trn-doc.obj-type, bf_trn-doc.obj-code, bf_goods.gds-code) .
                RUN gds-attr-value (
                                    INPUT bf_goods.gds-code,
                                    INPUT 'mark-type':U,
                                    OUTPUT varvalue,
                                    OUTPUT vartype
                                    ).
                if (varvalue > ""
                and EDOParSec:GetIsEdoForType(varvalue))
                or v-isweighed
                then do:
                  mark-lines_ :
                  for each buf_marking-lines no-lock where buf_marking-lines.out-code   = bf_doc-line.doc-code
                                                       and buf_marking-lines.gds-code   = bf_goods.gds-code
                  :
                    for first buf_marking no-lock where buf_marking.mark begins buf_marking-lines.mark :
                      if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
                      and not(index(bf_trn-doc.doc-code, "=") > 0 and buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB)
                      then
                        next mark-lines_
                      .
                    end .
                    create tt-marking-lines .
                    assign
                      tt-marking-lines.mark = buf_marking-lines.mark
                      tt-marking-lines.gds-code = bf_goods.gds-code
                      tt-marking-lines.gds-name = bf_goods.gds-name
                      tt-marking-lines.obj-type = bf_trn-doc.obj-type
                      tt-marking-lines.obj-code = bf_trn-doc.obj-code
                      tt-marking-lines.doc-level = buf_marking-lines.doc-level
                    .
                    for first buf_marking exclusive-lock where buf_marking.mark begins buf_marking-lines.mark :
                      assign
                        buf_marking.sts = objSrv:Env:Marking:Sts:Mark:Reserved:KeyIntDB
                      .
                    end .
                  end .
                end .
              end .
            end .
          end .
          assign
            v-0-recipes-gds-list = trim(v-0-recipes-gds-list, ", ")
            v-many-recipes-gds-list = trim(v-many-recipes-gds-list, ", ")
          .
          if v-0-recipes-gds-list > ""
          then do :
            message "Для товаров " + v-0-recipes-gds-list + " отсутствует рецепт «Альтернатива». Обратитесь в офис для создания рецепта, после чего создайте документ производства вручную"
            view-as alert-box .
          end .
          if v-many-recipes-gds-list > ""
          then do :
            message "Для товаров " + v-many-recipes-gds-list + " найдено более одного рецепта «Альтернатива», поэтому автоматический выбор рецепта невозможен, товар не добавлен. Создайте документ производства с этим товаром вручную. Обратитесь в офис для корректировки рецептов"
            view-as alert-box .
          end .
          find first tt-fbr-line no-error .
          if available tt-fbr-line
          then do :
            run waitfram-show in this-procedure (input "Ждите... Идёт создание и закрытие документа производства").
            run str/cr-fbr-doc-mark.p ( input parparentproc
                                      , input this-procedure
                                      , input table tt-fbr-line by-reference
                                      , input table tt-marking-lines by-reference
                                      ) .
            run waitfram-hide in this-procedure .
          end .
        end .
      end.
    end.
    when '<открытие документа>':U
    then do:
      run str/trn-open.p
      ( input parparentproc
      , input parmode
      , input pardoc-code
      , input parcheck-return
      , input pardb-num
      , input parin-ov
      , input parrsrv-time
      , input parload-time
      , input parholidays
      , input parmessage
      )  no-error .
      if error-status :error
      then do:
        undo, return error return-value  .
      end.
    end.
    when '<резервирование по документу>':U
    then do:
      if bf_trn-doc.ext-doc-type = 'vt':U
      then do:
        case bf_trn-doc.status_:
          when 'накл':U
          then do:
            case bf_trn-doc.flag_:
              when yes
              then do:
                run inv-nakl-reserv in this-procedure no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
              end.
              otherwise do:
                run waitfram-hide in this-procedure no-error.
                undo, return error substitute( "Ошибочный статус-флаг &1-&2 для резервирования.", bf_trn-doc.status_, bf_trn-doc.flag_ ).
              end.
            end case.
          end.
          when 'разрешен':U
          then do:
            if varstatus = 'факт':U then do:
              run waitfram-hide in this-procedure no-error.
              undo, return error substitute( "Данная операция не может закрывать документ до статуса &1.", varstatus ).
            end.
            if bf_trn-doc.flag_ = false then do:
                run waitfram-show in this-procedure (substitute( "Заполнение документа инвентаризации. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_filinvon in g#lib-trn2
(input  bf_trn-doc.doc-code,
 input  bf_trn-doc.status_,
 input  bf_trn-doc.flag_,
 input  yes,
 input  this-procedure,
 output parchg-inv,
 output table gds-list
)
.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_calc-inv in g#lib-trn
(
input recid(bf_trn-doc),
input this-procedure
)
no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
                run str/clcsumga.p (input bf_trn-doc.doc-code) no-error.
                if error-status :error
                then do:
                  run waitfram-hide in this-procedure no-error.
                  undo, return error return-value.
                end.
            end.
            assign
              bf_trn-doc.flag_   = varflag
              bf_trn-doc.status_ = varstatus
            .
          end.
          otherwise do:
            run waitfram-hide in this-procedure no-error.
            undo, return error substitute( "Ошибочный статус-флаг &1-&2 для резервирования.", bf_trn-doc.status_, bf_trn-doc.flag_ ).
          end.
        end case.
      end.
      else do:
        run waitfram-hide in this-procedure no-error.
        undo, return error substitute( "Неверная операция: резервирование-переход по статусам для документа &1 с расширенным типом &2 .", bf_trn-doc.doc-code, bf_trn-doc.ext-doc-type).
      end.
    end.
    otherwise do:
      run waitfram-hide in this-procedure no-error.
      undo, return error substitute( "Неизвестный режим &1 обработки документа.", parmode).
    end.
  end case.
run waitfram-hide in this-procedure.
for each tt-trn: delete tt-trn. end.
        define variable v-sum like ub.fin-ob-trn.sum-rubl no-undo .
        if bf_trn-doc.ext-doc-type = 'ee':U or bf_trn-doc.ext-doc-type = 're':U and bf_trn-doc.contract-code <> 0 and bf_trn-doc.contract-code <> ? then do:
                p-cons = 0.
            find first bf_contract no-lock where bf_contract.contract-code = bf_trn-doc.contract-code no-error .
              if available bf_contract then do:
                if  bf_contract.usl-opl <> 'Не определено' then do:
                define variable v-fo-gen as integer no-undo.
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'fin-global':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
                    for each thbjattr_thbj-attr exclusive-lock:
                        if thbjattr_thbj-attr.prop-code = 'fo-gen':U  then v-fo-gen = thbjattr_thbj-attr.property-value-integer .
                    end.
                    if ((varstatus = 'накл':U and bf_trn-doc.flag_ = yes and (v-fo-gen = 3 or v-fo-gen = 2 )) or (varstatus = 'разрешен':U and (v-fo-gen = 4 or v-fo-gen = 5) ) or (varstatus = 'факт':U and v-fo-gen > 1 )) or ((bf_contract.usl-opl = 'Предоплата' or bf_contract.usl-opl = 'Предоплата(%)') and varstatus = 'разрешен':U) then do:
                                  for each bf_fin-ob-trn where bf_fin-ob-trn.trn-doc-code = bf_trn-doc.doc-code exclusive-lock:
                                    v-sum = v-sum + bf_fin-ob-trn.sum-rubl .
                                  end.
                                  if (abs (v-sum) <> bf_trn-doc.tot-fact and abs (v-sum) <> (bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl)) or (bf_contract.usl-opl = 'Предоплата' or bf_contract.usl-opl = 'Предоплата(%)') and (varstatus = 'разрешен':U or (varstatus = 'факт':U and v-fo-gen > 1 )) then do:
                        if bf_contract.usl-opl = 'Предоплата' or bf_contract.usl-opl = 'Предоплата(%)' then p-cons = 1.
                        if bf_contract.usl-opl = 'По факту поставки покупателю'  then p-cons = 2.
                        if bf_contract.usl-opl = 'Отсрочка платежа по поставке'  then p-cons = 3.
                        if bf_trn-doc.ext-doc-type = 'ee':U then do:
                         if bf_contract.usl-opl <> 'Предоплата' and bf_contract.usl-opl <> 'Предоплата(%)' then do:
                             find first bf_fin-ob-trn where bf_fin-ob-trn.trn-doc-code = bf_trn-doc.doc-code and v-sum > (bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl) no-error.
                                if not available bf_fin-ob-trn then do:
                                    run str/limcontr.p ( input bf_trn-doc.host-code, input bf_trn-doc.contract-code, input 0, input bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl - v-sum, input bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl - v-sum ) no-error .
                                    if error-status :error then return error return-value .
                                end.
                          end.
                         if (bf_contract.usl-opl = 'Предоплата' or bf_contract.usl-opl = 'Предоплата(%)') and varstatus = 'разрешен':U then do:
                                    run str/limcontr.p ( input bf_trn-doc.host-code, input bf_trn-doc.contract-code, input 0, input 0, input  bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl ) no-error .
                                    if error-status :error then return error return-value .
                         end.
                         if (bf_contract.usl-opl = 'Предоплата' or bf_contract.usl-opl = 'Предоплата(%)') and (varstatus = 'факт':U and v-fo-gen > 1 ) then do:
                           if abs (v-sum) <> bf_trn-doc.tot-fact and abs (v-sum) <> (bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl) then do:
                             if (bf_trn-doc.fact-qnty <> bf_trn-doc.doc-qnty) or v-sum = 0 then do:
                                find first bf_fin-ob-trn where bf_fin-ob-trn.trn-doc-code = bf_trn-doc.doc-code and v-sum > (bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl) no-error.
                                if not available bf_fin-ob-trn then do:
                                      run str/limcontr.p ( input bf_trn-doc.host-code, input bf_trn-doc.contract-code, input 0, input bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl, input bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl ) no-error .
                                      if error-status :error then return error return-value .
                                end.
                             end.
                           end.
                         end.
                        end.
                        if abs (v-sum) <> (bf_trn-doc.tot-fact - bf_trn-doc.discnt-rubl) and abs (v-sum) <> (bf_trn-doc.tot-sale - bf_trn-doc.discnt-rubl) then do:
                        BUFFER-COPY bf_trn-doc to tt-trn.
                      run str/genbfotr.p (
                          input parParentProc ,
                          input bf_contract.host-code ,
                          input bf_trn-doc.doc-date  ,
                          input ? ,
                          input p-cons ,
                          input 1 ,
                          input table tt-trn ,
                          input-output res ,
                          input 2,
                          input yes
                          ) no-error .
                     end.
                     end.
                     end.
      end.
    end.
  end.
  find first bf_clients no-lock where bf_clients.obj-type = 'чел':U and  bf_clients.obj-code = bf_trn-doc.boss no-error.
  find last ub.c-trn-doc no-lock where ub.c-trn-doc.doc-code = bf_trn-doc.doc-code and ub.c-trn-doc.corr-user-db-num = v-curr-db-num no-error.
  if available bf_trn-doc
  then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varobj-shift-date
  ,output varobj-shift-num
  ,output varobj-shift-name
  ) no-error .
    v-vid-action = 57 .
    v-vid-param = "Initiator=" + v-initiator + chr(4) +
                  "ResponsiblePerson=" + (if available (bf_clients) then bf_clients.obj-name else "") + chr(4) +
                  "SHOP_NUM=" + string(bf_trn-doc.obj-code) + chr(4) +
                  "Contractor=" + bf_trn-doc.cli-name + chr(4) +
                  "DocNum=" + string(bf_trn-doc.doc-code) + chr(4) +
                  "FactDate=" + (if string(bf_trn-doc.fact-date) = ? then '' else string(bf_trn-doc.fact-date)) + chr(4) +
                  "DocType=" + string(bf_trn-doc.doc-type) + chr(4) +
                  "SHIFT_NUM_DOC=" + (if string(bf_trn-doc.shift-num) = ? then '' else string(bf_trn-doc.shift-num)) + (if string(bf_trn-doc.shift-date) = ? then '' else string(bf_trn-doc.shift-date, "99999999")) + chr(4) +
                  "SHIFT_NUM=" + (if string(varobj-shift-num) = ? then '' else string(varobj-shift-num)) + (if string(varobj-shift-date) = ? then '' else string(varobj-shift-date, "99999999")) + chr(4) +
                  "StatusOld=" + varoldstatus + (if varoldflag then "+" else "-" ) + chr(4) +
                  "StatusNew=" + string(bf_trn-doc.status_) + (if bf_trn-doc.flag then "+" else "-" ) + chr(4) +
                  "RESULT=0" + chr(4) +
                  "Description=" no-error.
    if available (ub.c-trn-doc)
      then
      run trg/userlog.p (
            input 'update':U
          , input 'c-trn-doc':U
          , input ( buffer ub.c-trn-doc :handle )
          , input v-vid-action
          , input v-vid-param
      ) no-error.
      else
      run trg/userlog.p (
          input 'update':U
        , input 'trn-doc':U
        , input ( buffer bf_trn-doc :handle )
        , input v-vid-action
        , input v-vid-param
      ) no-error.
  end.
end.
procedure inv-fact :
define input  parameter par-if-rec-doc  as recid no-undo.
define input  parameter par-if-status   like ub.trn-doc.status_ no-undo.
define input  parameter par-if-flag     like ub.trn-doc.flag_   no-undo.
define output parameter par-if-flag-out as logical              no-undo.
define buffer if_sysconf    for ub.sysconf.
define buffer if_trn-doc    for ub.trn-doc.
define buffer if_curr-accnt for ub.curr-accnt.
define buffer if_doc-line   for ub.doc-line.
define buffer if_goods      for ub.goods.
define variable if_cnt-lns       as   integer              no-undo.
define variable varinvclcspvalue as   character            no-undo.
define variable varinvclcsptype  as   character            no-undo.
define variable parwtvalue       as   character            no-undo.
define variable parasvalue       as   character            no-undo.
define variable parwttype        as   character            no-undo.
define variable parastype        as   character            no-undo.
define variable var-if-cur-qnty  like ub.doc-line.doc-qnty no-undo.
define variable var-if-chg-inv   as   logical              no-undo.
do on error undo, return error return-value :
  assign par-if-flag-out = yes.
  find first if_trn-doc where recid(if_trn-doc) = par-if-rec-doc.
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input if_trn-doc.obj-type
  ,input if_trn-doc.obj-code
  ,input 'inv-obj':U
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
      if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
  end.
  find first if_sysconf where if_sysconf.host-code = if_trn-doc.host-code.
  find last if_curr-accnt where if_curr-accnt.curr-code = if_sysconf.base-code
                            and if_curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
  if not available if_curr-accnt
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error "На дату " + string(v-today) + " неизвестен курс базовой валюты.".
  end.
  assign
    if_trn-doc.base-rate  = if_curr-accnt.exch-rate
    if_trn-doc.base-scale = if_curr-accnt.exch-scale.
  run waitfram-show in this-procedure (substitute( "Локирование товаров при закрытии документа. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
  run trg/lock-gds.p
    (input if_trn-doc.doc-code
    ,input no
    ,input no
    ,input 0
    ,input 0
    ,input false
    ,input false
    ) no-error .
  if error-status :error
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error .
  end.
  if par-if-status = 'разрешен':U and
     par-if-flag   = no
  then do:
     define variable varchg-inv as logical no-undo.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_filinvon in g#lib-trn2
(input  if_trn-doc.doc-code,
 input  if_trn-doc.status_,
 input  if_trn-doc.flag_,
 input  yes,
 input  this-procedure:handle,
 output varchg-inv,
 output table gds-list
) no-error
.
     if error-status :error
     then do:
       run waitfram-hide in this-procedure no-error.
       undo, return error return-value.
     end.
  end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input if_trn-doc.doc-code ,
                        input 'clcaswt':U ,
                       output parwtvalue ,
                       output parwttype ) no-error .
  if error-status :error
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error return-value.
  end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input if_trn-doc.doc-code ,
                        input 'clcasol':U ,
                       output parasvalue ,
                       output parastype ) no-error .
  if error-status :error
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error return-value.
  end.
  run waitfram-show in this-procedure (substitute( "Пересчет сумм документа по закрытию на факт. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_rcallfct in g#lib-rwds ( input              if_trn-doc.doc-code ,
                       input              parwtvalue = 'no' ,
                       input              parasvalue = 'no' ,
                       input              this-procedure :handle ,
                       input-output table tt-wast-line ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
  if error-status :error
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Ошибка при вызове lib-rwds_rcallfct: &1.", return-value ).
  end.
  assign
    varcount = 0.
  for each if_doc-line
    where if_doc-line.doc-code = if_trn-doc.doc-code
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure (substitute( "Обрабатываем строки при закрытии. Обработано строк: &1. Время &2.", varcount, string(time - vartime, "hh:mm:ss") ) ) no-error.
    assign
      varcount = varcount + 1.
    find first if_goods no-lock
      where if_goods.artic     = if_doc-line.artic
        and if_goods.prod-type = if_doc-line.prod-type
        and if_goods.prod-code = if_doc-line.prod-code  .
    if if_doc-line.fact-qnty <> 0
    or if_doc-line.prt-ok
    then do:
      par-if-flag-out = no.
      accumulate if_doc-line.prt-ok (count).
    end.
    assign
      if_cnt-lns = if_cnt-lns + 1.
    if if_cnt-lns modulo 10 = 0
    then do:
      run waitfram-show in this-procedure ("Обработано строк : " + string (if_cnt-lns) ).
    end.
  end.
  if substr (if_trn-doc.PS, 1, 1) = "@"
  then do:
    assign
      if_trn-doc.PS = if_trn-doc.PS + " Всего строк по инвентаризации : " + string (if_cnt-lns, ">>>>>>9") +
                       chr (10) + "Из них закрыто с коррекцией : " + string ( (accum count if_doc-line.prt-ok), ">>>>>>9")
    .
  end.
  run waitfram-show in this-procedure (substitute( "Пересчет шапки документа. Время: &1", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_calc-inv in g#lib-trn
(
input recid(if_trn-doc),
input this-procedure
)
no-error.
  if error-status :error
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error return-value.
  end.
  run ie-date in this-procedure.
end.
end procedure.
procedure corr-date:
define input parameter parobj-type    like ub.trn-doc.obj-type   no-undo.
define input parameter parobj-code    like ub.trn-doc.obj-code   no-undo.
define input parameter parfact-date   like ub.trn-doc.fact-date  no-undo.
define input parameter parshift-date  like ub.trn-doc.shift-date no-undo.
define input parameter parshift-num   like ub.trn-doc.shift-num  no-undo.
define input parameter parshift-name  like ub.trn-doc.shift-name no-undo.
define variable l-shift-on as logical no-undo .
define buffer bf_shift-obj for ub.shift-obj.
do on error undo, return error return-value :
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
if l-shift-on = yes
then do:
  find first bf_shift-obj where bf_shift-obj.obj-type   = parobj-type   and
                                bf_shift-obj.obj-code   = parobj-code   and
                                bf_shift-obj.shift-date = parshift-date and
                                bf_shift-obj.shift-num  = parshift-num  no-lock no-error.
  if not available bf_shift-obj
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Нет смены &1 &2 на объекте &3 &4.", parshift-date, parshift-name + string(parshift-num), parobj-type, parobj-code).
  end.
  if bf_shift-obj.status_ <> 'зкр':U  and
     bf_shift-obj.status_ <> 'тек':U
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Смена &1 &2 на объекте &3 &4 имеет статус &5. Оформлять документы можно только в смене со статусом &6 или &7.",
                              bf_shift-obj.shift-date,
                              bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                              bf_shift-obj.obj-type,
                              bf_shift-obj.obj-code,
                              bf_shift-obj.status_,
                              'зкр':U,
                              'тек':U).
  end.
  if parfact-date < bf_shift-obj.open-date
  then do:
    run waitfram-hide in this-procedure no-error.
    undo, return error substitute( "Фактическая дата документа должна быть больше либо равна дате открытия смены. Фактическая дата: &1. Дата открытия смены &2 &3 на объекте &4 &5: &6.",
                             parfact-date,
                             bf_shift-obj.shift-date,
                             bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                             bf_shift-obj.obj-type,
                             bf_shift-obj.obj-code,
                             bf_shift-obj.open-date).
  end.
  if bf_shift-obj.status_ = 'зкр':U
  then do:
    if parfact-date > bf_shift-obj.close-date
    then do:
      run waitfram-hide in this-procedure no-error.
      undo, return error substitute( "Фактическая дата документа должна быть меньше либо равна дате закрытия смены. Фактическая дата: &1. Дата закрытия смены &2 &3 на объекте &4 &5: &6.",
                               parfact-date,
                               bf_shift-obj.shift-date,
                               bf_shift-obj.shift-name + string(bf_shift-obj.shift-num),
                               bf_shift-obj.obj-type,
                               bf_shift-obj.obj-code,
                               bf_shift-obj.close-date).
    end.
  end.
end.
end.
end procedure.
procedure fill-tt :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_doc-line      for ub.doc-line.
define buffer bf_doc-line-attr for ub.doc-line-attr.
define buffer bf_gds-dtl       for ub.gds-dtl.
define buffer bf_parts         for ub.parts.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock.
for each lib-trn_ret-doc on error undo, return error return-value :
  delete lib-trn_ret-doc.
end.
create lib-trn_ret-doc.
buffer-copy bf_trn-doc to lib-trn_ret-doc.
for each lib-trn_ret-line on error undo, return error return-value :
  delete lib-trn_ret-line.
end.
for each bf_doc-line where bf_doc-line.doc-code = bf_trn-doc.doc-code no-lock on error undo, return error return-value :
  create lib-trn_ret-line.
  buffer-copy bf_doc-line to lib-trn_ret-line.
  assign
    lib-trn_ret-line.cst-code = bf_trn-doc.cst-code.
end.
for each lib-trn_ret-line-attr on error undo, return error return-value :
  delete lib-trn_ret-line-attr.
end.
for each bf_doc-line-attr where bf_doc-line-attr.doc-code = bf_trn-doc.doc-code no-lock
  on error undo, return error return-value :
  create lib-trn_ret-line-attr.
  buffer-copy bf_doc-line-attr to lib-trn_ret-line-attr.
end.
for each lib-trn_ret-dtl on error undo, return error return-value :
  delete lib-trn_ret-dtl.
end.
for each bf_gds-dtl where bf_gds-dtl.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
  create lib-trn_ret-dtl.
  buffer-copy bf_gds-dtl to lib-trn_ret-dtl.
end.
for each lib-trn_ret-parts on error undo, return error return-value :
  delete lib-trn_ret-parts.
end.
for each bf_parts where bf_parts.out-code = bf_trn-doc.doc-code on error undo, return error return-value :
  create lib-trn_ret-parts.
  buffer-copy bf_parts to lib-trn_ret-parts.
end.
end.
end procedure.
procedure ie-date:
  do
  on error undo, return error substitute("&1 &2" , return-value , error-status :get-message(1) )
  :
    if bf_trn-doc.fact-date  <> ?
      or bf_trn-doc.shift-date <> ?
    then do:
     if bf_trn-doc.fact-time = 0 or bf_trn-doc.fact-time = ? then
        bf_trn-doc.fact-time = time.
      if bf_trn-doc.fact-date = ?
      and (bf_trn-doc.ext-doc-type = 'eo':U
        or bf_trn-doc.ext-doc-type = 'ie':U
        or bf_trn-doc.ext-doc-type = 'iv':U)
      then do :
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output bf_trn-doc.fact-date
  )  .
      end.
      if g#esys and bf_trn-doc.fact-date = ?
        then do:
          bf_trn-doc.fact-date = now.
          return.
        end.
      run gbl/chk-date.p
          ( input bf_trn-doc.obj-type
          , input bf_trn-doc.obj-code
          , input bf_trn-doc.fact-date
          , input bf_trn-doc.fact-time
          , input bf_trn-doc.shift-date
          , input bf_trn-doc.shift-num
          , yes).
      run corr-date in this-procedure
          ( input bf_trn-doc.obj-type
          , input bf_trn-doc.obj-code
          , input bf_trn-doc.fact-date
          , input bf_trn-doc.shift-date
          , input bf_trn-doc.shift-num
          , input bf_trn-doc.shift-name
          ).
      if bf_trn-doc.fact-date < v-today then do:
        assign
          bf_trn-doc.is-back-date = yes
        .
      end.
      else do:
        if bf_trn-doc.shift-date <> ? then do:
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varobj-shift-date
  ,output varobj-shift-num
  ,output varobj-shift-name
  )  .
          if not ( bf_trn-doc.shift-date = varobj-shift-date
                   and bf_trn-doc.shift-num  = varobj-shift-num
                 )
          then do:
            assign
              bf_trn-doc.is-back-date = yes
            .
          end.
        end.
      end.
    end.
    else do:
      run gbl/factdate.p
        ( input        bf_trn-doc.obj-type
         ,input        bf_trn-doc.obj-code
         ,input-output bf_trn-doc.fact-date
         ,input-output bf_trn-doc.fact-time
         ,input-output bf_trn-doc.shift-date
         ,input-output bf_trn-doc.shift-num
         ,input-output bf_trn-doc.shift-name
         ,input        NOT(g#auto OR g#oxml OR g#esys OR g#news)
        ).
        run str/chk-back.p
          (input bf_trn-doc.doc-code
          ,input bf_trn-doc.fact-date
          ) no-error .
          if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
          .
          return error return-value .
          end.
    end.
  end.
end procedure.
procedure inv-nakl-reserv :
  do on error undo, return error return-value :
    run waitfram-show in this-procedure ( input substitute( "Заполнение документа инвентаризации. Время: &1"
                                                          , string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_filinvon in g#lib-trn2
(input  bf_trn-doc.doc-code,
 input  bf_trn-doc.status_,
 input  bf_trn-doc.flag_,
 input  yes,
 input  this-procedure,
 output parchg-inv,
 output table gds-list
)
.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_calc-inv in g#lib-trn
(
input recid(bf_trn-doc),
input this-procedure
)
.
    run str/clcsumga.p (input bf_trn-doc.doc-code).
    assign
      bf_trn-doc.flag_   = varflag
      bf_trn-doc.status_ = varstatus.
  end.
end procedure.
procedure hold-check:
define buffer bf-src_doc-line for ub.doc-line.
define buffer bf-src_goods    for ub.goods.
define buffer bf-src_units    for ub.units.
define buffer bf-src_gds-dtl  for ub.gds-dtl.
define buffer bf-src_parts    for ub.parts.
do on error undo, return error return-value :
  for each bf-src_doc-line where bf-src_doc-line.doc-code = bf_trn-doc.doc-code on error undo, return error return-value :
    find first bf-src_goods where bf-src_goods.artic     = bf-src_doc-line.artic     and
                                  bf-src_goods.prod-type = bf-src_doc-line.prod-type and
                                  bf-src_goods.prod-code = bf-src_doc-line.prod-code no-lock.
    find first bf-src_units where bf-src_units.unit-name = bf-src_goods.unit-base no-lock.
    if lookup('2ед':U, bf-src_units.type) <> 0
    then do:
      undo, return error substitute( "В документе межфирменного перемещения не допускается товар с двумя единицами измерения. Товар: &1 &2 &3", bf-src_goods.artic, bf-src_goods.prod-type, bf-src_goods.prod-code).
    end.
    if lookup('сер':U, bf-src_units.type) <> 0
    then do:
      undo, return error substitute( "В документе межфирменного перемещения не допускается серийный товар. Товар: &1 &2 &3",bf-src_goods.artic, bf-src_goods.prod-type, bf-src_goods.prod-code).
    end.
    if bf-src_doc-line.fact-qnty > bf-src_doc-line.doc-qnty
    then do:
      undo, return error substitute( "Фактическое количество по строке &1 не может быть больше документарного &2. Товар: &3 &4 &5", bf-src_doc-line.fact-qnty, bf-src_doc-line.doc-qnty, bf-src_goods.artic, bf-src_goods.prod-type, bf-src_goods.prod-code).
    end.
  end.
  for each bf-src_gds-dtl where bf-src_gds-dtl.doc-code = bf_trn-doc.doc-code on error undo, return error return-value:
    find first bf_gds-dtl where bf_gds-dtl.doc-code  = bf-src_gds-dtl.doc-code  and
                                bf_gds-dtl.artic     = bf-src_gds-dtl.artic     and
                                bf_gds-dtl.prod-type = bf-src_gds-dtl.prod-type and
                                bf_gds-dtl.prod-code = bf-src_gds-dtl.prod-code and
                                recid(bf_gds-dtl)    <> recid(bf-src_gds-dtl)   no-error.
    if available bf_gds-dtl
    then do:
      undo, return error substitute( "В документе межфирменного перемещения не допускается чтобы в одном документе товар шел по нескольким признакам. Товар: &1 &2 &3", bf_gds-dtl.artic, bf_gds-dtl.prod-type, bf_gds-dtl.prod-code).
    end.
    if bf-src_gds-dtl.fact-qnty > bf-src_gds-dtl.doc-qnty
    then do:
      undo, return error substitute( "Фактическое количество по признаку &1 не может быть больше документарного &2. Товар: &3 &4 &5", bf-src_gds-dtl.fact-qnty, bf-src_gds-dtl.doc-qnty, bf-src_goods.artic, bf-src_goods.prod-type, bf-src_goods.prod-code).
    end.
  end.
  for each bf-src_parts where bf-src_parts.out-code = bf_trn-doc.doc-code on error undo, return error return-value:
    if bf-src_parts.fact-qnty > bf-src_parts.qnty
    then do:
      undo, return error substitute( "Фактическое количество по партии &1 не может быть больше документарного &2. Товар: &3 &4 &5", bf-src_parts.fact-qnty, bf-src_parts.qnty, bf-src_goods.artic, bf-src_goods.prod-type, bf-src_goods.prod-code).
    end.
  end.
end.
end procedure.
procedure close-rvs :
  define input  parameter p-trn-doc-code like ub.trn-doc.doc-code   no-undo.
  define input  parameter p-rvs-type     like ub.rvs-doc.rvs-type   no-undo.
  define input  parameter p-fact-date    like ub.trn-doc.fact-date  no-undo.
  define input  parameter p-fact-time    like ub.trn-doc.fact-time  no-undo.
  define input  parameter p-shift-date   like ub.trn-doc.shift-date no-undo.
  define input  parameter p-shift-num    like ub.trn-doc.shift-num  no-undo.
  define input  parameter p-shift-name   like ub.trn-doc.shift-name no-undo.
  do
  on error  undo, return error substitute( "&1 (close-rvs). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (close-rvs). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (close-rvs). endkey", vss-workfile )
  :
    define buffer buf_rvs-doc for ub.rvs-doc .
    for each buf_rvs-doc
      where buf_rvs-doc.rvs-type = p-rvs-type
        and buf_rvs-doc.out-code = p-trn-doc-code
    :
      run str/rvs-stat.p
        ( input parparentproc
         ,input recid(buf_rvs-doc)
         ,input "unfroze":U
        ) no-error.
      if error-status :error then do:
        undo, return error substitute( "Ошибка при изменении статуса &1.", return-value ).
      end.
      assign
        buf_rvs-doc.fact-date  = p-fact-date
        buf_rvs-doc.fact-time  = p-fact-time
        buf_rvs-doc.shift-date = p-shift-date
        buf_rvs-doc.shift-num  = p-shift-num
        buf_rvs-doc.shift-name = p-shift-name
      .
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclose in g#lib-rvs ( input parparentproc ,
                      input recid(buf_rvs-doc) ,
                      input no ) no-error .
      if error-status :error then do:
        undo, return error  substitute( "Ошибка при закрытии документа сверки: &1 &2.", buf_rvs-doc.rvs-code, return-value ).
      end.
      release buf_rvs-doc no-error .
      if error-status :error then do:
        undo, return error  substitute( "Ошибка при закрытии документа сверки: &1 &2.", buf_rvs-doc.rvs-code, return-value ).
      end.
    end.
  end.
end procedure.
procedure verify-assort-pol :
define input  parameter p-artic     as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
define variable v-min-ass-exist  as logical   no-undo init false .
define variable var-ok-assort-pol as logical   no-undo .
define variable var-mess-assort-pol as character no-undo .
define buffer buf_goods for ub.goods  .
  do
  on error undo, return error return-value
  :
  find first buf_goods no-lock where
            buf_goods.artic     = p-artic    and
            buf_goods.prod-type = p-prod-type and
            buf_goods.prod-code = p-prod-code  .
    if lookup (bf_trn-doc.ext-doc-type,
              'ee':U + "," +
              'ev':U ) <> 0  and
              ((bf_trn-doc.status_ = 'накл':U and bf_trn-doc.flag_ = false  ) )
      then do:
      var-ok-assort-pol = true .
      if not (bf_trn-doc.cli-type = 'орг':U or bf_trn-doc.cli-type = 'чел':U) then do:
         v-event-code = substitute("cli_&1-" , bf_trn-doc.ext-doc-type ) .
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_goods.gds-code
  ,input  bf_trn-doc.cli-type
  ,input  bf_trn-doc.cli-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
        end.
        else do:
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  bf_trn-doc.doc-code
  ,output v-is-hold
  )  .
         if v-is-hold then do:
            v-event-code = substitute("cli_mf_&1-" ,bf_trn-doc.ext-doc-type ) .
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_goods.gds-code
  ,input  bf_trn-doc.hold-obj-type
  ,input  bf_trn-doc.hold-obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
         end.
         end.
       if var-ok-assort-pol = false then do:
            varerr = true .
            output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
            put    stream str-err unformatted var-mess-assort-pol skip.
            output stream str-err close.
       end.
    end.
    if lookup (bf_trn-doc.ext-doc-type,
              'vt':U + "," +
              'vp':U + "," +
              'we':U + "," +
              'wm':U + ","  +
              'es':U + ","+
              're':U + "," +
              'ep':U + ","  +
              'pc':U + ","  +
              'mp':U + ","  +
              'ap':U   + "," +
              'rv':U  + "," +
              'eo':U  + "," +
              'io':U ) = 0  and
              ((bf_trn-doc.status_ = 'накл':U    and bf_trn-doc.flag_ = false  ))
    then do:
      var-ok-assort-pol = true .
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  bf_trn-doc.doc-code
  ,output v-is-hold
  )  .
         if v-is-hold then do:
            v-event-code = substitute("mf_&1-" ,bf_trn-doc.ext-doc-type ) .
         end.
         else do:
            v-event-code = substitute("&1-" ,bf_trn-doc.ext-doc-type ) .
         end.
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run goassizt in g#library2
  (input  v-event-code
  ,input  buf_goods.gds-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  false
  ,output var-ok-assort-pol
  ,output var-mess-assort-pol
  ) .
       if var-ok-assort-pol = false then do:
            varerr = true .
            output stream str-err to value( replace( bf_trn-doc.doc-code, "*", "$" ) + ".err" ) append.
            put    stream str-err unformatted var-mess-assort-pol skip.
            output stream str-err close.
       end.
    end.
  end.
end procedure.
procedure ver-inv-date-close :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-date as date          no-undo .
define variable v-date as date      no-undo .
  do
  on error undo, return error return-value
  :
  find first ub.doc-attr exclusive-lock where
             ub.doc-attr.doc-code = p-doc-code and
             ub.doc-attr.attr-code = 'dateinv':U no-error .
   if available ub.doc-attr then do:
      v-date =  date (ub.doc-attr.attr-value) .
      if  v-date <  p-date then do:
          return error substitute("Предполагаемая дата закрытия инвентаризации &1 уже просрочена ! Инвентаризацию &2 закрыть нельзя." , string(v-date , "99/99/9999") , p-doc-code ) .
      end.
      if  v-date >  p-date then do:
          return error substitute("Предполагаемая дата закрытия инвентаризации &1 еще не настала ! Инвентаризацию &2 закрыть нельзя." , string(v-date , "99/99/9999") , p-doc-code ) .
      end.
   end.
  end.
end procedure.
procedure fill-mol:
  find first ub.user-account no-lock where ub.user-account.user-id = v-curr-userid.
  if ub.user-account.psn-code <> 0 and ub.user-account.psn-code <> ?
    then
  do:
    if bf_trn-doc.agnt = ? then do:
      bf_trn-doc.agnt = ub.user-account.psn-code.
    end.
    if bf_trn-doc.wrkr = ?
    then do:
      bf_trn-doc.wrkr = ub.user-account.psn-code.
    end.
    bf_trn-doc.boss = ub.user-account.psn-code.
  end.
  release ub.user-account.
end procedure.
procedure need-ver-spec :
define output parameter v-is-nover as logical   no-undo .
define variable v-uh as handle no-undo .
  do
  on error undo, return error return-value
  :
  assign
  v-uh = this-procedure:instantiating-procedure
  v-is-nover = false
  .
  if v-uh:persistent then return .
  do while valid-handle(v-uh):
    if v-uh:persistent then return .
    if lookup("cb_close-without-verify", v-uh:internal-entries) > 0 then do:
      run cb_close-without-verify in v-uh ( output v-is-nover ) no-error.
      leave.
    end.
    v-uh = v-uh:instantiating-procedure.
  end.
  end.
end procedure.
