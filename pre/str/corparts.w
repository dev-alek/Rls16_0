define input        parameter parparentproc   as   handle                  no-undo.
define input-output parameter pardoc-rec      as   recid                   no-undo.
define input        parameter pardoc-mode     as   character               no-undo.
define input        parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input        parameter paris-hold      as   logical                 no-undo.
define input-output parameter parnext-prev    as   logical                 no-undo.
define input-output parameter line-rec        as   recid                   no-undo.
define input        parameter br-handle       as   handle                  no-undo.
define input        parameter bf-handle       as   handle                  no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
define buffer  t-doc     for ub.trn-doc.
define buffer bf-orig_parts        for ub.parts.
define buffer bf-orig_goods        for ub.goods.
define buffer bf-caus_parts        for ub.parts.
define buffer bf_parts-root        for ub.parts-root.
define buffer bf_doc-line          for ub.doc-line.
define buffer cli-buf              for ub.clients.
define buffer bf_goods             for ub.goods.
define buffer bf-expp_doc-line-sum for ub.doc-line-sum.
define buffer bf-incp_doc-line-sum for ub.doc-line-sum.
define buffer bf_sysconf           for ub.sysconf.
define buffer clients              for ub.clients  .
define buffer pay-type             for ub.pay-type  .
define buffer firm                 for ub.firm  .
define buffer curr-accnt           for ub.curr-accnt  .
define buffer doc-line for ub.doc-line  .
define variable vartot-docold                       like ub.trn-doc.tot-doc                    no-undo.
define variable vartot-rublold                      like ub.trn-doc.tot-rubl                   no-undo.
define variable i-total-doc-line_tot-ovold          like ub.trn-doc.tot-ov                     no-undo.
define variable i-total-doc-line_fact-rublold       like ub.trn-doc.fact-rubl                  no-undo.
define variable i-total-doc-line_fact-baseold       like ub.trn-doc.fact-base                  no-undo.
define variable i-total-doc-line_fact-qntyold       like ub.trn-doc.fact-qnty                  no-undo.
define variable i-total-doc-line_doc-qntyold        like ub.trn-doc.doc-qnty                   no-undo.
define variable i-total-doc-line_cli-qntyold        like ub.trn-doc.cli-qnty                   no-undo.
define variable i-total-parts_fact-baseold          as   decimal                               no-undo.
define variable i-total-parts_fact-rublold          as   decimal                               no-undo.
define variable i-total-parts_fact-qntyold          as   decimal                               no-undo.
define variable varto-exp-rubl                      as   decimal                               no-undo.
define variable varto-exp-base                      as   decimal                               no-undo.
define variable varto-inc-rubl                      as   decimal                               no-undo.
define variable varto-inc-base                      as   decimal                               no-undo.
define variable varprice-base                       like ub.parts.price-base                   no-undo.
define variable varsum-base                         like ub.parts.price-base                   no-undo.
define variable varprice-rubl                       like ub.parts.price-rubl                   no-undo.
define variable varsum-rubl                         like ub.parts.price-rubl                   no-undo.
define variable varprice-cli                        like ub.parts.price-rubl                   no-undo.
define variable varsum-cli                          like ub.parts.price-rubl                   no-undo.
define variable varcli-base-rate                    like ub.parts.cli-base-rate                no-undo.
define variable varvat-type                         like ub.parts.vat-type                     no-undo.
define variable varslt-type                         like ub.parts.slt-type                     no-undo.
define variable varvat-pc                           like ub.parts.vat-pc                       no-undo.
define variable varvat-base                         like ub.parts.price-base                   no-undo.
define variable varsum-vat-base                     like ub.parts.price-base                   no-undo.
define variable varvat-rubl                         like ub.parts.price-rubl                   no-undo.
define variable varsum-vat-rubl                     like ub.parts.price-rubl                   no-undo.
define variable varvat-cli                          like ub.parts.price-rubl                   no-undo.
define variable varsum-vat-cli                      like ub.parts.price-rubl                   no-undo.
define variable varslt-pc                           like ub.parts.slt-pc                       no-undo.
define variable varslt-base                         like ub.parts.price-base                   no-undo.
define variable varsum-slt-base                     like ub.parts.price-base                   no-undo.
define variable varslt-rubl                         like ub.parts.price-rubl                   no-undo.
define variable varsum-slt-rubl                     like ub.parts.price-rubl                   no-undo.
define variable varslt-cli                          like ub.parts.price-rubl                   no-undo.
define variable varsum-slt-cli                      like ub.parts.price-rubl                   no-undo.
define variable varroad-tax-base                    like ub.parts.road-tax-base   initial 0.00 no-undo.
define variable varsum-road-tax-base                like ub.parts.road-tax-base   initial 0.00 no-undo.
define variable varroad-tax-rubl                    like ub.parts.road-tax-rubl   initial 0.00 no-undo.
define variable varsum-road-tax-rubl                like ub.parts.road-tax-rubl   initial 0.00 no-undo.
define variable varroad-tax-cli                     like ub.parts.road-tax-rubl   initial 0.00 no-undo.
define variable varsum-road-tax-cli                 like ub.parts.road-tax-rubl   initial 0.00 no-undo.
define variable vartransport-base                   like ub.parts.transport-base  initial 0.00 no-undo.
define variable varsum-transport-base               like ub.parts.transport-base  initial 0.00 no-undo.
define variable vartransport-rubl                   like ub.parts.transport-rubl  initial 0.00 no-undo.
define variable varsum-transport-rubl               like ub.parts.transport-rubl  initial 0.00 no-undo.
define variable vartransport-cli                    like ub.parts.transport-rubl  initial 0.00 no-undo.
define variable varsum-transport-cli                like ub.parts.transport-rubl  initial 0.00 no-undo.
define variable varother-base                       like ub.parts.other-base      initial 0.00 no-undo.
define variable varsum-other-base                   like ub.parts.other-base      initial 0.00 no-undo.
define variable varother-rubl                       like ub.parts.other-rubl      initial 0.00 no-undo.
define variable varsum-other-rubl                   like ub.parts.other-rubl      initial 0.00 no-undo.
define variable varother-cli                        like ub.parts.other-rubl      initial 0.00 no-undo.
define variable varsum-other-cli                    like ub.parts.other-rubl      initial 0.00 no-undo.
define variable varrdtaxname                        as   character                             no-undo.
define variable varsum-exp-rubl                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varsum-inc-rubl                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varsum-exp-base                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varsum-inc-base                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varvat-exp-rubl                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varvat-inc-rubl                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varvat-exp-base                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varvat-inc-base                     like ub.trn-doc.fact-rubl                  no-undo.
define variable varlog-err                          as   logical                               no-undo.
define variable varcntr-prn-code                    like ub.contract.contract-prn-code         no-undo.
define variable varcntr-name                        like ub.contract.contract-name             no-undo.
define variable varpurch-code                       like ub.parts.purch-code                   no-undo.
define variable varlog                              as   logical                               no-undo.
define variable ref-rec                             as   recid                                 no-undo.
define variable varfile-name                        as   character initial "log-cor.err"       no-undo.
define variable parext-doc-mode                     as   character                             no-undo.
define stream str-err.
define temp-table tt-chs-parts no-undo like ub.parts.
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
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION title-mode RETURNS CHARACTER
  ( INPUT pmode as character ) :
DEFINE VARIABLE ptitle-mode as character no-undo.
CASE ENTRY(1, pmode) :
  when 'ДОБАВЛЕНИЕ':U then ptitle-mode = "ДОБАВЛЕНИЕ".
  when 'ИЗМЕНЕНИЕ':U  then ptitle-mode = "ИЗМЕНЕНИЕ".
  when 'ПРОСМОТР':U  then ptitle-mode = "ПРОСМОТР".
END CASE.
  RETURN ptitle-mode.
END FUNCTION.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      vss-include-info4 skip
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure holdprts-create-parts-supp :
  define input  parameter p-orig-in-code   like ub.parts-supp.orig-in-code   no-undo .
  define input  parameter p-orig-part-code like ub.parts-supp.orig-part-code no-undo .
  define input  parameter p-in-code        like ub.parts-supp.in-code        no-undo .
  define input  parameter p-artic          like ub.parts-supp.artic          no-undo .
  define input  parameter p-prod-type      like ub.parts-supp.prod-type      no-undo .
  define input  parameter p-prod-code      like ub.parts-supp.prod-code      no-undo .
  define input  parameter p-part-code      like ub.parts-supp.part-code      no-undo .
  define variable vss-description as character no-undo init "holdprts-create-parts-supp-01: скопировать атрибут партии".
  define buffer buf_parent_trn-doc  for ub.trn-doc .
  define buffer buf_child_trn-doc   for ub.trn-doc .
  define buffer buf_parts           for ub.parts .
  define buffer buf_parts-supp      for ub.parts-supp .
  define buffer buf_orig_parts-supp for ub.parts-supp .
  define buffer buf_income_trn-doc  for ub.trn-doc .
  define buffer buf_income_doc-line for ub.doc-line .
  define buffer buf_goods           for ub.goods .
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
  do
  on error undo, return error return-value
  :
    find first buf_child_trn-doc no-lock
      where buf_child_trn-doc.doc-code = p-in-code
      no-error .
    if not available buf_child_trn-doc
    then do:
      return substitute("Не найден исходный документ &1", p-in-code) .
    end.
    find first buf_parent_trn-doc no-lock
      where buf_parent_trn-doc.doc-code = buf_child_trn-doc.hold-doc-code-parent
      no-error .
    if not available buf_parent_trn-doc
    then do:
      return substitute("Не найден приходный документ &1", buf_child_trn-doc.hold-doc-code-parent) .
    end.
    find first buf_parts-supp exclusive-lock
      where buf_parts-supp.in-code   = p-in-code
        and buf_parts-supp.artic     = p-artic
        and buf_parts-supp.prod-type = p-prod-type
        and buf_parts-supp.prod-code = p-prod-code
        and buf_parts-supp.part-code = p-part-code
      no-error .
    if available buf_parts-supp
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info19 skip
        "Попытка повторного создания партии атрибутов" skip
        "Документ прихода" p-in-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код партии" p-part-code skip
        "Исходный код партии" p-orig-in-code skip
        "Исходный код документа" p-orig-part-code skip
        view-as alert-box error .
      undo, return error .
    end.
    create buf_parts-supp .
    assign
      buf_parts-supp.in-code   = p-in-code
      buf_parts-supp.artic     = p-artic
      buf_parts-supp.prod-type = p-prod-type
      buf_parts-supp.prod-code = p-prod-code
      buf_parts-supp.part-code = p-part-code
    .
    assign
      buf_parts-supp.orig-in-code   = p-orig-in-code
      buf_parts-supp.orig-part-code = p-orig-part-code
    .
    find first buf_orig_parts-supp share-lock
      where buf_orig_parts-supp.in-code   = p-orig-in-code
        and buf_orig_parts-supp.artic     = p-artic
        and buf_orig_parts-supp.prod-type = p-prod-type
        and buf_orig_parts-supp.prod-code = p-prod-code
        and buf_orig_parts-supp.part-code = p-orig-part-code
      no-error .
    if available buf_orig_parts-supp
    then do:
      buffer-copy buf_orig_parts-supp
      except
        buf_orig_parts-supp.in-code
        buf_orig_parts-supp.artic
        buf_orig_parts-supp.prod-type
        buf_orig_parts-supp.prod-code
        buf_orig_parts-supp.part-code
        buf_orig_parts-supp.orig-in-code
        buf_orig_parts-supp.orig-part-code
      to buf_parts-supp.
    end.
    else do:
      find first buf_parts share-lock
        where buf_parts.obj-type  = buf_parent_trn-doc.obj-type
          and buf_parts.obj-code  = buf_parent_trn-doc.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.in-code   = p-orig-in-code
          and buf_parts.out-code  = buf_parent_trn-doc.doc-code
          and buf_parts.part-code = p-orig-part-code
        no-error .
      if not available buf_parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info19 skip
          "Ошибка задания входных параметров" skip
          "Не найдена исходная партия" skip
          "Исходный документ" p-orig-in-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код партии" p-orig-part-code skip
          view-as alert-box error .
        undo, return error .
      end.
      define variable v-base-rate         as decimal   no-undo .
      define variable v-base-scale        as integer   no-undo .
      define variable v-exch-rate         as decimal   no-undo .
      define variable v-exch-scale        as integer   no-undo .
      define variable v-extended-doc-type as character no-undo .
      define variable v-unit-cli          as character no-undo .
      find first buf_income_trn-doc no-lock
        where buf_income_trn-doc.doc-code = p-orig-in-code
        no-error .
      if available buf_income_trn-doc
      then do:
        find first buf_income_doc-line no-lock
          where buf_income_doc-line.doc-code  = p-orig-in-code
            and buf_income_doc-line.artic     = p-artic
            and buf_income_doc-line.prod-type = p-prod-type
            and buf_income_doc-line.prod-code = p-prod-code
          no-error .
        if not available buf_income_doc-line
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info19 skip
            "Не найдена исходная строка документа прихода" skip
            "Исходный документ" p-orig-in-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код партии" p-orig-part-code skip
            view-as alert-box error .
          undo, return error .
        end.
        assign
          v-base-rate         = buf_income_trn-doc.base-rate
          v-base-scale        = buf_income_trn-doc.base-scale
          v-exch-rate         = buf_income_trn-doc.exch-rate
          v-exch-scale        = buf_income_trn-doc.exch-scale
          v-extended-doc-type = buf_income_trn-doc.ext-doc-type
          v-unit-cli          = buf_income_doc-line.unit-cli
        .
      end.
      else do:
        find first buf_goods no-lock
          where buf_goods.artic     = buf_parts.artic
            and buf_goods.prod-type = buf_parts.prod-type
            and buf_goods.prod-code = buf_parts.prod-code
          .
        assign
          v-base-rate         = buf_parts.price-rubl / buf_parts.price-base
          v-base-scale        = 1
          v-exch-rate         = buf_parts.price-rubl / (buf_parts.price-cli * buf_parts.cli-base-rate)
          v-exch-scale        = 1
          v-extended-doc-type = 'ie':U
          v-unit-cli          = buf_goods.unit-cli
        .
      end.
       if v-base-rate = ? then v-base-rate = 1.
       if v-exch-rate = ? then v-exch-rate = 1.
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
        buf_parts-supp.PS                = buf_parts.PS
        buf_parts-supp.SLT-type          = buf_parts.SLT-type
        buf_parts-supp.VAT-type          = buf_parts.VAT-type
        buf_parts-supp.base-rate         = v-base-rate
        buf_parts-supp.base-scale        = v-base-scale
        buf_parts-supp.cli-qnty          = buf_parts.cli-qnty
        buf_parts-supp.cst-code          = buf_parts.cst-code
        buf_parts-supp.doc-qnty          = buf_parts.qnty
        buf_parts-supp.exch-code         = buf_parts.exch-code
        buf_parts-supp.exch-rate         = v-exch-rate
        buf_parts-supp.exch-scale        = v-exch-scale
        buf_parts-supp.extended-doc-type = v-extended-doc-type
        buf_parts-supp.fact-date         = buf_parts.fact-date
        buf_parts-supp.fact-qnty         = buf_parts.fact-qnty
        buf_parts-supp.last-date         = buf_parts.last-date
        buf_parts-supp.pay-code          = buf_parts.pay-code
        buf_parts-supp.price-cli         = buf_parts.price-cli
        buf_parts-supp.purch-code        = buf_parts.purch-code
        buf_parts-supp.supp-code         = buf_parts.supp-code
        buf_parts-supp.supp-type         = buf_parts.supp-type
        buf_parts-supp.unit-cli          = v-unit-cli
      .
      assign
        buf_parts-supp.vat-pc         = vat-pc-loc
        buf_parts-supp.slt-pc         = slt-pc-loc
        buf_parts-supp.price-base     = price-base-with-tax-loc
        buf_parts-supp.price-rubl     = price-rubl-with-tax-loc
        buf_parts-supp.vat-base       = vat-base-loc
        buf_parts-supp.vat-rubl       = vat-rubl-loc
        buf_parts-supp.slt-base       = slt-base-loc
        buf_parts-supp.slt-rubl       = slt-rubl-loc
        buf_parts-supp.road-tax-base  = road-tax-base-loc
        buf_parts-supp.road-tax-rubl  = road-tax-rubl-loc
        buf_parts-supp.transport-base = transport-base-loc
        buf_parts-supp.transport-rubl = transport-rubl-loc
        buf_parts-supp.other-base     = other-base-loc
        buf_parts-supp.other-rubl     = other-rubl-loc
      .
    end.
  end.
end procedure.
procedure holdprts-get-part-code :
  define input  parameter p-doc-code       as character no-undo .
  define output parameter p-hold-part-code as integer   no-undo .
  define variable vss-description as character no-undo init "holdprts-get-part-code-01: создать уникальный код партии внутри документа".
  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info19 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'hold-part-code':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    assign
      p-hold-part-code = integer(v-attr-value) + 1
    .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input 'hold-part-code':U ,
                       input string(p-hold-part-code) )  .
  end.
end procedure.
procedure holdprts-validate-document :
  define input  parameter p-doc-code as character no-undo .
  define variable vss-description as character no-undo init "holdprts-validate-document-01: проверить правильность документа".
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer parent_trn-doc for ub.trn-doc .
  define buffer buf_parts      for ub.parts .
  define buffer buf_parts-supp for ub.parts-supp .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc exclusive-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info19 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first parent_trn-doc exclusive-lock
      where parent_trn-doc.doc-code = buf_trn-doc.hold-doc-code-parent
      no-error .
    if not available parent_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info19 skip
        "Не найден родительский документ" skip
        "Документ" buf_trn-doc.doc-code skip
        "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_trn-doc.ext-doc-type <> 'ie':U
    then do:
      return .
    end.
    for each buf_parts share-lock
      where buf_parts.out-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      find first buf_parts-supp share-lock
        where buf_parts-supp.in-code   = buf_parts.in-code
          and buf_parts-supp.artic     = buf_parts.artic
          and buf_parts-supp.prod-type = buf_parts.prod-type
          and buf_parts-supp.prod-code = buf_parts.prod-code
          and buf_parts-supp.part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-supp
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info19 skip
          "Не найдена информация о поставщике" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    for each buf_parts-supp share-lock
      where buf_parts-supp.in-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      find first buf_parts share-lock
        where buf_parts.out-code  = buf_parts-supp.in-code
          and buf_parts.obj-type  = buf_trn-doc.obj-type
          and buf_parts.obj-code  = buf_trn-doc.obj-code
          and buf_parts.artic     = buf_parts-supp.artic
          and buf_parts.prod-type = buf_parts-supp.prod-type
          and buf_parts.prod-code = buf_parts-supp.prod-code
          and buf_parts.part-code = buf_parts-supp.part-code
        no-error .
      if not available buf_parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info19 skip
          "Задана информация о поставщике для неизвестной партии" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    for each buf_parts share-lock
      where buf_parts.out-code = buf_trn-doc.hold-doc-code-parent
    on error undo, return error
    :
      if  buf_trn-doc.doc-type = 'при':U
      and buf_parts.qnty = buf_parts.fact-qnty
      then do:
        next.
      end.
      find first buf_parts-supp share-lock
        where buf_parts-supp.orig-in-code   = buf_parts.in-code
          and buf_parts-supp.artic          = buf_parts.artic
          and buf_parts-supp.prod-type      = buf_parts.prod-type
          and buf_parts-supp.prod-code      = buf_parts.prod-code
          and buf_parts-supp.orig-part-code = buf_parts.part-code
        no-error .
      if not available buf_parts-supp
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info19 skip
          "Не найдена информация о поставщике для исходной накладной" skip
          "Документ" buf_trn-doc.doc-code skip
          "Родительский документ" buf_trn-doc.hold-doc-code-parent skip
          "Артикул" buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "Номер партии" buf_parts.part-code skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure holdprts-doc-type :
  define input  parameter p-cat-code as integer   no-undo .
  define input  parameter p-doc-code as character no-undo .
  define output parameter p-is-sale  as logical   no-undo .
  define output parameter p-is-purch as logical   no-undo .
  define variable vss-description as character no-undo init "holdprts-doc-type-01: определение типа документа для межфирменного архива".
  define buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info19 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Тип архива" p-cat-code skip
        view-as alert-box error .
      undo, return error .
    end.
    case p-cat-code :
      when 1
      then do:
        define variable v-is-hold as logical   no-undo .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  buf_trn-doc.doc-code
  ,output v-is-hold
  )  .
        if v-is-hold = true
        then do:
          assign
            p-is-sale  = false
            p-is-purch = false
          .
        end.
        else do:
          case buf_trn-doc.ext-doc-type :
            when 'ie':U or
            when 'ep':U
            then do:
              assign
                p-is-sale  = false
                p-is-purch = true
              .
            end.
            when 'ee':U or
            when 'es':U or
            when 're':U or
            when 'rs':U
            then do:
              assign
                p-is-sale  = true
                p-is-purch = false
              .
            end.
            when 'we':U or
            when 'vt':U or
            when 'vp':U or
            when 'ap':U or
            when 'mp':U or
            when 'pc':U or
            when 'iv':U or
            when 'ev':U or
            when 'io':U or
            when 'eo':U or
            when 'rv':U or
            when 'em':U or
            when 'wm':U or
            when 'im':U
            then do:
              assign
                p-is-sale  = false
                p-is-purch = false
              .
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                vss-include-info19 skip
                "Неизвестный тип документа" skip
                "Документ" buf_trn-doc.doc-code skip
                "Тип документа" buf_trn-doc.ext-doc-type skip
                "Тип архива" p-cat-code skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
      when 2
      then do:
        case buf_trn-doc.ext-doc-type :
          when 'vt':U or
          when 'vp':U
          then do:
            assign
              p-is-sale  = false
              p-is-purch = true
            .
          end.
          otherwise do:
            assign
              p-is-sale  = false
              p-is-purch = false
            .
          end.
        end.
      end.
      when 3
      then do:
        case buf_trn-doc.ext-doc-type :
          when 'we':U
          then do:
            assign
              p-is-sale  = false
              p-is-purch = true
            .
          end.
          otherwise do:
            assign
              p-is-sale  = false
              p-is-purch = false
            .
          end.
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип архивов" skip
          "Документ" buf_trn-doc.doc-code skip
          "Тип документа" buf_trn-doc.ext-doc-type skip
          "Тип архива" p-cat-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure holdprts-purch-values :
  define input  parameter p-doc-code             like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic                like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type            like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code            like ub.doc-line.prod-code no-undo .
  define output parameter p-fact-qnty            as decimal   no-undo .
  define output parameter p-purch-sum-base       as decimal   no-undo .
  define output parameter p-purch-sum-rubl       as decimal   no-undo .
  define output parameter p-purch-VAT-base       as decimal   no-undo .
  define output parameter p-purch-VAT-rubl       as decimal   no-undo .
  define output parameter p-purch-SLT-base       as decimal   no-undo .
  define output parameter p-purch-SLT-rubl       as decimal   no-undo .
  define output parameter p-purch-road-tax-base  as decimal   no-undo .
  define output parameter p-purch-road-tax-rubl  as decimal   no-undo .
  define output parameter p-purch-excise-base    as decimal   no-undo .
  define output parameter p-purch-excise-rubl    as decimal   no-undo .
  define output parameter p-purch-transport-base as decimal   no-undo .
  define output parameter p-purch-transport-rubl as decimal   no-undo .
  define output parameter p-purch-other-base     as decimal   no-undo .
  define output parameter p-purch-other-rubl     as decimal   no-undo .
  define output parameter p-purch-discnt-base    as decimal   no-undo .
  define output parameter p-purch-discnt-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "holdprts-purch-values-01: параметры закупки товара".
  define variable v-price-base     as decimal   no-undo .
  define variable v-price-rubl     as decimal   no-undo .
  define variable v-VAT-base       as decimal   no-undo .
  define variable v-VAT-rubl       as decimal   no-undo .
  define variable v-SLT-base       as decimal   no-undo .
  define variable v-SLT-rubl       as decimal   no-undo .
  define variable v-road-tax-base  as decimal   no-undo .
  define variable v-road-tax-rubl  as decimal   no-undo .
  define variable v-transport-base as decimal   no-undo .
  define variable v-transport-rubl as decimal   no-undo .
  define variable v-other-base     as decimal   no-undo .
  define variable v-other-rubl     as decimal   no-undo .
  define buffer buf_trn-doc        for ub.trn-doc .
  define buffer buf_parts          for ub.parts .
  define buffer buf_parts-supp     for ub.parts-supp .
  define buffer buf_doc-line       for ub.doc-line .
  define buffer buf_income_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info19 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info19 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-fact-qnty            = 0
      p-purch-sum-base       = 0
      p-purch-sum-rubl       = 0
      p-purch-VAT-base       = 0
      p-purch-VAT-rubl       = 0
      p-purch-SLT-base       = 0
      p-purch-SLT-rubl       = 0
      p-purch-road-tax-base  = 0
      p-purch-road-tax-rubl  = 0
      p-purch-excise-base    = 0
      p-purch-excise-rubl    = 0
      p-purch-transport-base = 0
      p-purch-transport-rubl = 0
      p-purch-other-base     = 0
      p-purch-other-rubl     = 0
      p-purch-discnt-base    = 0
      p-purch-discnt-rubl    = 0
    .
    for each buf_parts no-lock
      where buf_parts.out-code  = buf_doc-line.doc-code
        and buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      define variable v-parts-qnty as decimal   no-undo .
      assign
        v-parts-qnty = buf_parts.fact-qnty
                     * ( if lookup(buf_trn-doc.doc-type, 'рас,спи':U ) > 0
                         then -1
                         else 1
                       )
      .
      find first buf_parts-supp no-lock
        where buf_parts-supp.in-code   = buf_parts.in-code
          and buf_parts-supp.artic     = buf_parts.artic
          and buf_parts-supp.prod-type = buf_parts.prod-type
          and buf_parts-supp.prod-code = buf_parts.prod-code
          and buf_parts-supp.part-code = buf_parts.part-code
        no-error .
      if available buf_parts-supp
      then do:
        assign
          v-price-base     = buf_parts-supp.price-base
          v-price-rubl     = buf_parts-supp.price-rubl
          v-VAT-base       = buf_parts-supp.VAT-base
          v-VAT-rubl       = buf_parts-supp.VAT-rubl
          v-SLT-base       = buf_parts-supp.SLT-base
          v-SLT-rubl       = buf_parts-supp.SLT-rubl
          v-road-tax-base  = buf_parts-supp.road-tax-base
          v-road-tax-rubl  = buf_parts-supp.road-tax-rubl
          v-transport-base = buf_parts-supp.transport-base
          v-transport-rubl = buf_parts-supp.transport-rubl
          v-other-base     = buf_parts-supp.other-base
          v-other-rubl     = buf_parts-supp.other-rubl
        .
      end.
      else do:
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
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
          v-price-base     = price-base-with-tax-loc
          v-price-rubl     = price-rubl-with-tax-loc
          v-VAT-base       = vat-base-loc
          v-VAT-rubl       = vat-rubl-loc
          v-SLT-base       = slt-base-loc
          v-SLT-rubl       = slt-rubl-loc
          v-road-tax-base  = road-tax-base-loc
          v-road-tax-rubl  = road-tax-rubl-loc
          v-transport-base = transport-base-loc
          v-transport-rubl = transport-rubl-loc
          v-other-base     = other-base-loc
          v-other-rubl     = other-rubl-loc
        .
      end.
      assign
        p-fact-qnty            = p-fact-qnty            + v-parts-qnty
        p-purch-sum-base       = p-purch-sum-base       + v-price-base     * v-parts-qnty
        p-purch-sum-rubl       = p-purch-sum-rubl       + v-price-rubl     * v-parts-qnty
        p-purch-VAT-base       = p-purch-VAT-base       + v-VAT-base       * v-parts-qnty
        p-purch-VAT-rubl       = p-purch-VAT-rubl       + v-VAT-rubl       * v-parts-qnty
        p-purch-SLT-base       = p-purch-SLT-base       + v-SLT-base       * v-parts-qnty
        p-purch-SLT-rubl       = p-purch-SLT-rubl       + v-SLT-rubl       * v-parts-qnty
        p-purch-road-tax-base  = p-purch-road-tax-base  + v-road-tax-base  * v-parts-qnty
        p-purch-road-tax-rubl  = p-purch-road-tax-rubl  + v-road-tax-rubl  * v-parts-qnty
        p-purch-excise-base    = p-purch-excise-base    + 0
        p-purch-excise-rubl    = p-purch-excise-rubl    + 0
        p-purch-transport-base = p-purch-transport-base + v-transport-base * v-parts-qnty
        p-purch-transport-rubl = p-purch-transport-rubl + v-transport-rubl * v-parts-qnty
        p-purch-other-base     = p-purch-other-base     + v-other-base     * v-parts-qnty
        p-purch-other-rubl     = p-purch-other-rubl     + v-other-rubl     * v-parts-qnty
        p-purch-discnt-base    = p-purch-discnt-base    + 0
        p-purch-discnt-rubl    = p-purch-discnt-rubl    + 0
      .
    end.
  end.
end procedure.
procedure holdprts-sale-values :
  define input  parameter p-doc-code            like ub.doc-line.doc-code  no-undo .
  define input  parameter p-artic               like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type           like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code           like ub.doc-line.prod-code no-undo .
  define output parameter p-fact-qnty           as decimal   no-undo .
  define output parameter p-sale-sum-base       as decimal   no-undo .
  define output parameter p-sale-sum-rubl       as decimal   no-undo .
  define output parameter p-sale-VAT-base       as decimal   no-undo .
  define output parameter p-sale-VAT-rubl       as decimal   no-undo .
  define output parameter p-sale-SLT-base       as decimal   no-undo .
  define output parameter p-sale-SLT-rubl       as decimal   no-undo .
  define output parameter p-sale-road-tax-base  as decimal   no-undo .
  define output parameter p-sale-road-tax-rubl  as decimal   no-undo .
  define output parameter p-sale-excise-base    as decimal   no-undo .
  define output parameter p-sale-excise-rubl    as decimal   no-undo .
  define output parameter p-sale-transport-base as decimal   no-undo .
  define output parameter p-sale-transport-rubl as decimal   no-undo .
  define output parameter p-sale-other-base     as decimal   no-undo .
  define output parameter p-sale-other-rubl     as decimal   no-undo .
  define output parameter p-sale-discnt-base    as decimal   no-undo .
  define output parameter p-sale-discnt-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "holdprts-sale-values-01: параметры продажи товара".
  define variable v-gds-dtl-fact-qnty as decimal   no-undo .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_gds-dtl  for ub.gds-dtl.
  define buffer buf_goods    for ub.goods.
  define buffer buf_trn-doc  for ub.trn-doc.
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
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
    no-error .
    if not available buf_trn-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info19 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info19 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка документа" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
        and buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error
    :
      if buf_trn-doc.doc-type <> 'инв':U
      then do:
        if buf_trn-doc.doc-type = 'при':U
        or buf_trn-doc.doc-type = 'возврат':U
        then do:
          assign
            v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
          .
        end.
        else do:
          assign
            v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
          .
        end.
      end.
      else do:
        assign
          v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
        .
      end.
      if v-gds-dtl-fact-qnty <> 0
      then do:
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
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
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
        assign
          p-fact-qnty           = p-fact-qnty          + v-gds-dtl-fact-qnty
          p-sale-sum-base       = p-sale-sum-base      + price-base-with-tax-sale  * v-gds-dtl-fact-qnty
          p-sale-sum-rubl       = p-sale-sum-rubl      + price-rubl-with-tax-sale  * v-gds-dtl-fact-qnty
          p-sale-vat-base       = p-sale-vat-base      + vat-base-sale             * v-gds-dtl-fact-qnty
          p-sale-vat-rubl       = p-sale-vat-rubl      + vat-rubl-sale             * v-gds-dtl-fact-qnty
          p-sale-slt-base       = p-sale-slt-base      + slt-base-sale             * v-gds-dtl-fact-qnty
          p-sale-slt-rubl       = p-sale-slt-rubl      + slt-rubl-sale             * v-gds-dtl-fact-qnty
          p-sale-road-tax-base  = p-sale-road-tax-base + road-tax-base-sale        * v-gds-dtl-fact-qnty
          p-sale-road-tax-rubl  = p-sale-road-tax-rubl + road-tax-rubl-sale        * v-gds-dtl-fact-qnty
          p-sale-excise-base    = p-sale-excise-base   + excise-base-sale          * v-gds-dtl-fact-qnty
          p-sale-excise-rubl    = p-sale-excise-rubl   + excise-rubl-sale          * v-gds-dtl-fact-qnty
          p-sale-discnt-base    = p-sale-discnt-base   + discnt-base-sale          * v-gds-dtl-fact-qnty
          p-sale-discnt-rubl    = p-sale-discnt-rubl   + discnt-rubl-sale          * v-gds-dtl-fact-qnty
        .
      end.
    end.
    assign
      p-sale-transport-base = 0
      p-sale-transport-rubl = 0
      p-sale-other-base     = 0
      p-sale-other-rubl     = 0
    .
  end.
end procedure.
def var vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
procedure check-contract-code :
define input  parameter parmode           as   character                     no-undo.
define input  parameter parhost-code      like ub.trn-doc.host-code          no-undo.
define input  parameter parcli-type       like ub.trn-doc.cli-type           no-undo.
define input  parameter parcli-code       like ub.trn-doc.cli-code           no-undo.
define input  parameter parframe-value    as   character                     no-undo.
define input  parameter parmenu-handle    as   handle                        no-undo.
define input  parameter parobj-date       as   date                          no-undo.
define input  parameter partype-contract  as   character                     no-undo .
define output parameter parcontract-code  like ub.contract.contract-code     no-undo.
define buffer bf_contract     for ub.contract.
define buffer bf-oth_contract for ub.contract.
define variable varrid-list as character no-undo.
define variable varrecid    as recid     no-undo.
define variable varlog      as logical   no-undo.
define variable var-args    as char      no-undo.
define variable var-ext-doc-type as char     no-undo.
do on error undo, return error return-value :
var-args = parmode.
parmode = entry(1, parmode).
run cntrcode-get-arg-val(var-args, "doc-type", output var-ext-doc-type).
if partype-contract = "" or partype-contract = ? then
   partype-contract = 'при':U .
assign
  parcontract-code = 0
.
if parmode = "input":u
then do:
  if parframe-value = ""
  then do:
    assign
      parcontract-code = 0
    .
  end.
  else do:
    find first bf_contract no-lock
      where bf_contract.host-code         = parhost-code
        and bf_contract.cli-type          = parcli-type
        and bf_contract.cli-code          = parcli-code
        and bf_contract.contract-prn-code = parframe-value
      no-error.
    if available bf_contract
    then do:
      find first bf-oth_contract no-lock
        where bf-oth_contract.host-code          = parhost-code
          and bf-oth_contract.contract-prn-code  = parframe-value
          and bf-oth_contract.cli-type           = parcli-type
          and bf-oth_contract.cli-code           = parcli-code
          and rowid(bf_contract)                 <> rowid(bf-oth_contract)
        no-error .
      if available bf-oth_contract
      then do:
        message
          "На фирме " parhost-code skip
          "у контрагента" parcli-type parcli-code skip
          "имеются два контракта с номером" parframe-value skip
        view-as alert-box .
      end.
      else do:
        assign
          parcontract-code = bf_contract.contract-code
        .
      end.
    end.
  end.
end.
if parmode <> "input":u
or parcontract-code = 0
then do:
  run str/cont-all.w (input parmenu-handle,
                  input parhost-code,
                  input "b-sel",
                  input if var-ext-doc-type = 'ee':U then 'фирма':U else "firm-curr" ,
                  input parcli-type,
                  input parcli-code,
                  input ?,
                  input ?,
                  input "current":u,
                  input partype-contract,
                  input-output varrid-list ) no-error.
  if error-status:error then do:
    message "Ошибка при вызове справочника договоров." skip
            return-value                skip
            error-status:get-message(1) skip
            error-status:get-message(2)
    view-as alert-box error.
    return error.
  end.
  assign
    varrecid = integer(entry(1, varrid-list)).
  find first bf_contract where recid(bf_contract) = varrecid no-lock no-error.
  if available bf_contract then do:
    assign
      parcontract-code = bf_contract.contract-code.
  end.
end.
if parcontract-code <> 0
then do:
  if (bf_contract.status_ = 'зкр':U or
      (bf_contract.contract-date-end <> ? and bf_contract.contract-date-end < parobj-date)) then do:
    if lookup(var-ext-doc-type, 'ep,re,rs,ee') = 0
    then do:
        assign
          varlog = no.
        message "Договор с номером " bf_contract.contract-prn-code " закрыт." skip
        view-as alert-box.
        assign
          parcontract-code = 0
        .
    end.
  end.
  if bf_contract.contract-date-beg > parobj-date then do:
    assign
      varlog = no.
    message "Дата открытия договора " bf_contract.contract-date-beg " . Договор с номером " bf_contract.contract-prn-code " еще не открыт." skip
    view-as alert-box.
    assign
      parcontract-code = 0
    .
  end.
  if parcontract-code <> 0
  then do:
    if bf_contract.cli-type <> parcli-type
    or bf_contract.cli-code <> parcli-code
    then do:
       message "По договору " bf_contract.contract-code
               ( if bf_contract.doc-type =  'при':U
                 then " поставщиком является "
                 else " покупателем является " )
               bf_contract.cli-type " " bf_contract.cli-code " ." skip
               "По документу контрагент " parcli-type " " parcli-code " ." skip
       view-as alert-box error.
       assign
         parcontract-code = 0.
    end.
    if parcontract-code <> ? then do:
      if not ( bf_contract.doc-type =  'при':U or bf_contract.doc-type =  'рас':U ) then do:
        message "Контракт имеет недопустимый тип." view-as alert-box.
        assign
          parcontract-code = 0.
      end.
    end.
  end.
end.
end.
end procedure.
procedure cntrcode-get-arg-val:
    def input param p-args as char no-undo.
    def input param p-key as char no-undo.
    def output param p-val as char no-undo.
    def var i as int no-undo.
    def var nums as int no-undo.
    def var key-val as char no-undo.
    nums = num-entries(p-args).
    do i = 1 to nums:
        key-val = entry(i, p-args).
        if key-val begins (p-key + "=") then do:
            p-val = entry(2, key-val, "=").
            return.
        end.
    end.
    p-val = "".
end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxp-doc-prt         like ub.store.doc-prt         no-undo.
  define variable v-cntxp-price-calc      like ub.store.price-calc      no-undo.
  define variable v-cntxp-inout-price     like ub.store.inout-price     no-undo.
  define variable v-cntxp-unit-cli-perm   like ub.store.unit-cli-perm   no-undo.
  define variable v-cntxp-out-rate        like ub.store.out-rate        no-undo.
  define variable v-cntxp-out-line-discnt like ub.store.out-line-discnt no-undo.
  define variable v-cntxp-in-ov           like ub.store.in-ov           no-undo.
  define variable v-cntxp-in-perm         like ub.store.in-perm         no-undo.
  define variable v-cntxp-no-eq           like ub.store.no-eq           no-undo.
  define variable v-cntxp-rsrv-time       like ub.store.rsrv-time       no-undo.
  define variable v-cntxp-load-time       like ub.store.load-time       no-undo.
  define variable v-cntxp-holidays        like ub.store.holidays        no-undo.
  define variable v-cntxp-in-pay          like ub.store.in-pay          no-undo.
  define variable v-cntxp-out-pay         like ub.store.out-pay         no-undo.
  define variable v-cntxp-ret-pay         like ub.store.ret-pay         no-undo.
  define variable v-cntxp-ret-sup-pay     like ub.store.ret-sup-pay     no-undo.
  define variable v-cntxp-down-pay        like ub.store.down-pay        no-undo.
  define variable v-cntxp-inv-pay         like ub.store.inv-pay         no-undo.
  define variable v-cntxp-chk-pay         like ub.store.chk-pay         no-undo.
  define variable v-cntxp-retail          like ub.sysconf.ord-prt       no-undo.
  define variable v-cntxp-osn-base        like ub.sysconf.osn-base      no-undo.
  define variable v-cntxp-conf-par        as   character                no-undo.
  define variable v-cntxp-par-type        as   character                no-undo.
  define variable v-cntxp-curr-host-code  like ub.store.host-code       no-undo.
  define variable v-cntxp-obj-type        like ub.clients.obj-type      no-undo.
  define variable v-cntxp-obj-code        like ub.clients.obj-code      no-undo.
  define variable v-cntxp-db-num          as integer   no-undo .
  define variable v-cntxp-userid          as character no-undo .
  define variable v-cntxp-level           as character no-undo .
  define variable v-cntxp-db-num-obj      as integer   no-undo .
  define variable v-cntxp-is-admin        as logical   no-undo .
  define buffer bf-cntxp_store for ub.store.
  define buffer bf-cntxp_shop  for ub.shop.
  define buffer bf-cntxp_sysconf for ub.sysconf.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxp-db-num
    ,output v-cntxp-userid
    ,output v-cntxp-level
    ,output v-cntxp-curr-host-code
    ,output v-cntxp-obj-type
    ,output v-cntxp-obj-code
    ,output v-cntxp-db-num-obj
    ,output v-cntxp-is-admin
    ) .
  if (v-cntxp-obj-type = 'маг':U or v-cntxp-obj-type = 'скл':U) and
     v-cntxp-obj-code <> 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  yes
  ,output v-cntxp-conf-par
  ,output v-cntxp-par-type
  ) no-error .
    case v-cntxp-obj-type :
      when 'скл':U then do:
        find first bf-cntxp_store where bf-cntxp_store.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_store.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_store.doc-prt
          v-cntxp-price-calc      = bf-cntxp_store.price-calc
          v-cntxp-inout-price     = bf-cntxp_store.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_store.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_store.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_store.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_store.in-ov
          v-cntxp-in-perm         = bf-cntxp_store.in-perm
          v-cntxp-no-eq           = bf-cntxp_store.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_store.rsrv-time
          v-cntxp-load-time       = bf-cntxp_store.load-time
          v-cntxp-holidays        = bf-cntxp_store.holidays
          v-cntxp-in-pay          = bf-cntxp_store.in-pay
          v-cntxp-out-pay         = bf-cntxp_store.out-pay
          v-cntxp-ret-pay         = bf-cntxp_store.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_store.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_store.down-pay
          v-cntxp-inv-pay         = bf-cntxp_store.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_store.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
      when 'маг':U then do:
        find first bf-cntxp_shop where bf-cntxp_shop.obj-code = v-cntxp-obj-code no-lock.
        find first bf-cntxp_sysconf where bf-cntxp_sysconf.host-code = bf-cntxp_shop.host-code no-lock.
        assign
          v-cntxp-doc-prt         = (v-cntxp-conf-par = "yes") and bf-cntxp_shop.doc-prt
          v-cntxp-price-calc      = bf-cntxp_shop.price-calc
          v-cntxp-inout-price     = bf-cntxp_shop.inout-price
          v-cntxp-unit-cli-perm   = bf-cntxp_shop.unit-cli-perm
          v-cntxp-out-rate        = bf-cntxp_shop.out-rate
          v-cntxp-out-line-discnt = bf-cntxp_shop.out-line-discnt
          v-cntxp-in-ov           = bf-cntxp_shop.in-ov
          v-cntxp-in-perm         = bf-cntxp_shop.in-perm
          v-cntxp-no-eq           = bf-cntxp_shop.no-eq
          v-cntxp-rsrv-time       = bf-cntxp_shop.rsrv-time
          v-cntxp-load-time       = bf-cntxp_shop.load-time
          v-cntxp-holidays        = bf-cntxp_shop.holidays
          v-cntxp-in-pay          = bf-cntxp_shop.in-pay
          v-cntxp-out-pay         = bf-cntxp_shop.out-pay
          v-cntxp-ret-pay         = bf-cntxp_shop.ret-pay
          v-cntxp-ret-sup-pay     = bf-cntxp_shop.ret-sup-pay
          v-cntxp-down-pay        = bf-cntxp_shop.down-pay
          v-cntxp-inv-pay         = bf-cntxp_shop.inv-pay
          v-cntxp-chk-pay         = bf-cntxp_shop.chk-pay
          v-cntxp-retail          = bf-cntxp_sysconf.ord-prt
          v-cntxp-osn-base        = bf-cntxp_sysconf.osn-base
          .
      end.
    end case.
  end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
procedure ver-clients :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-error as logical   no-undo .
define variable v-veto-man-doc as character no-undo .
define variable v-type        as character no-undo .
  do
  on error undo, return error return-value
  :
  p-error = false .
run clntattr-value in this-procedure (
 input p-obj-type ,
 input p-obj-code ,
 input 'veto-man-doc':U     ,
 output v-veto-man-doc ,
 output v-type        ) no-error .
 if error-status :error then message
   error-status :get-message(1) skip
   return-value skip
   "Ошибка clntattr-veto-man-doc"
   view-as alert-box error
 .
  if v-veto-man-doc = 'ALL' then do:
      message "Запрещено создание документа на этого контрагента оператору вручную." view-as alert-box error  .
      p-error = true .
  end.
 end.
end procedure.
define temp-table temp-parts no-undo
  like ub.parts
  field free-qnty as decimal
  field free-cli-qnty as decimal
.
define temp-table tt-old-doc-line-sum no-undo like ub.doc-line-sum.
function disp-unit-base return character (buffer local-parts for bf-orig_parts).
define buffer bf_goods for ub.goods.
find first bf_goods where bf_goods.artic     = local-parts.artic     and
                          bf_goods.prod-type = local-parts.prod-type and
                          bf_goods.prod-code = local-parts.prod-code no-lock.
return bf_goods.unit-base.
end function.
define temp-table tt-del-list no-undo
field rec-id as recid
index rec-id is unique primary rec-id.
define temp-table tt-del-list-op no-undo
field rec-id as recid
index rec-id is unique primary rec-id.
define temp-table tt-cur-parts no-undo like ub.parts.
define temp-table tt-new-parts no-undo like ub.parts.
function get-mark-orig return character (buffer local-parts for bf-orig_parts ).
   find first tt-del-list-op where tt-del-list-op.rec-id = recid( local-parts ) no-error.
   if available tt-del-list-op then do:
     return "*".
   end.
   else do:
     return "".
   end.
end function.
function get-mark return character (buffer local-doc-line for ub.doc-line).
   find first tt-del-list where tt-del-list.rec-id = recid( local-doc-line ) no-error.
   if available tt-del-list then do:
     return "*".
   end.
   else do:
     return "".
   end.
end function.
function fpurch-code return character (buffer local-parts for ub.parts).
    return entry (lookup (string(local-parts.purch-code), '1,2,3,4':U), 'выкуп,консигнация,ответственное хранение,старая консигнация':U).
end.
define query br for bf_doc-line except, bf_goods except, bf-expp_doc-line-sum except, bf-incp_doc-line-sum except
scrolling.
define query br-op for bf-orig_parts except, bf-orig_goods except scrolling.
define query br-cp for bf_parts-root except, bf-caus_parts except scrolling.
define browse br query br no-lock display
  get-mark (buffer bf_doc-line)    column-label '*' format "x(1)"
  bf_doc-line.artic    column-label 'Артикул'
  bf_goods.gds-name    column-label 'Название товара' format "x(20)"
  bf_doc-line.prod-type    column-label 'Тип' format "x(3)"
  bf_doc-line.prod-code    column-label 'Код произ'
  bf-expp_doc-line-sum.fact-qnty    column-label 'Изм. кол-во'
  bf-expp_doc-line-sum.cost-sum-rubl    column-label 'Расход сумма (руб)'
  bf-expp_doc-line-sum.cost-sum-base    column-label 'Расход сумма (вал)'
  bf-incp_doc-line-sum.cost-sum-rubl    column-label 'Приход сумма (руб)'
  bf-incp_doc-line-sum.cost-sum-base   column-label 'Приход сумма (вал)'
  bf-expp_doc-line-sum.cost-vat-rubl   column-label 'Расход НДС (руб)'
  bf-expp_doc-line-sum.cost-vat-base   column-label 'Расход НДС (вал)'
  bf-incp_doc-line-sum.cost-vat-rubl   column-label 'Приход НДС (руб)'
  bf-incp_doc-line-sum.cost-vat-base   column-label 'Приход НДС (вал)'
  bf-expp_doc-line-sum.cost-slt-rubl   column-label 'Расход НП (руб)'
  bf-expp_doc-line-sum.cost-slt-base   column-label 'Расход НП (вал)'
  bf-incp_doc-line-sum.cost-slt-rubl   column-label 'Приход НП (руб)'
  bf-incp_doc-line-sum.cost-slt-base   column-label 'Приход НП (вал)'
  bf-expp_doc-line-sum.cost-road-tax-rubl   column-label ''
  bf-expp_doc-line-sum.cost-road-tax-base   column-label ''
  bf-incp_doc-line-sum.cost-road-tax-rubl   column-label ''
  bf-incp_doc-line-sum.cost-road-tax-base   column-label ''
  bf-expp_doc-line-sum.cost-transport-rubl + bf-expp_doc-line-sum.cost-other-rubl  @ varto-exp-rubl column-label 'Расход трансп. и прочие расходы (руб)'
  bf-expp_doc-line-sum.cost-transport-base + bf-expp_doc-line-sum.cost-other-base  @ varto-exp-base column-label 'Расход трансп. и прочие расходы (вал)'
  bf-incp_doc-line-sum.cost-transport-rubl + bf-incp_doc-line-sum.cost-other-rubl  @ varto-inc-rubl column-label 'Приход трансп. и прочие расходы (руб)'
  bf-incp_doc-line-sum.cost-transport-base + bf-incp_doc-line-sum.cost-other-base  @ varto-inc-base column-label 'Приход трансп. и прочие расходы (вал)'
  enable bf_doc-line.prod-code
  with size 98 by 5 separators.
define browse br-op query br-op no-lock display
  get-mark-orig (buffer bf-orig_parts)  column-label '*' format "x(1)"
  bf-orig_parts.in-code  column-label 'Номер док-та'
  bf-orig_parts.part-code  column-label 'Код партии'
  bf-orig_parts.qnty  column-label 'Количество'
  bf-orig_parts.fact-qnty  column-label 'Факт'
  disp-unit-base (buffer bf-orig_parts)  column-label 'Изм' format "x(3)"
  bf-orig_parts.price-rubl  column-label 'Цена (руб)'
  bf-orig_parts.price-base  column-label 'Цена(баз.вал.)'
  bf-orig_parts.vat-pc  column-label 'НДС'
  bf-orig_parts.slt-pc column-label 'НП'
  bf-orig_parts.road-tax-rubl column-label ''
  bf-orig_parts.road-tax-base column-label ''
  bf-orig_parts.transport-rubl column-label 'Транспортные расходы(руб)'
  bf-orig_parts.transport-base column-label 'Транспортные расходы(баз.вал.)'
  bf-orig_parts.other-rubl column-label 'Прочие расходы(руб)'
  bf-orig_parts.other-base column-label 'Прочие расходы(баз.вал.)'
  fpurch-code (buffer bf-orig_parts) column-label 'Тип приобретения' format "x(20)"
  enable bf-orig_parts.qnty
  with size 98 by 4 separators.
define browse br-cp query br-cp no-lock display
  bf-caus_parts.part-code  column-label 'Код партии'
  bf-caus_parts.qnty  column-label 'Количество'
  bf-caus_parts.fact-qnty  column-label 'Факт'
  disp-unit-base (buffer bf-caus_parts)  column-label 'Изм' format "x(3)"
  bf-caus_parts.price-rubl  column-label 'Цена (руб)'
  bf-caus_parts.price-base  column-label 'Цена(баз.вал.)'
  bf-caus_parts.vat-pc  column-label 'НДС'
  bf-caus_parts.slt-pc  column-label 'НП'
  bf-caus_parts.road-tax-rubl  column-label ''
  bf-caus_parts.road-tax-base column-label ''
  bf-caus_parts.transport-rubl column-label 'Транспортные расходы(руб)'
  bf-caus_parts.transport-base column-label 'Транспортные расходы(баз.вал.)'
  bf-caus_parts.other-rubl column-label 'Прочие расходы(руб)'
  bf-caus_parts.other-base column-label 'Прочие расходы(баз.вал.)'
  fpurch-code (buffer bf-caus_parts) column-label 'Тип приобретения' format "x(20)"
  enable bf-caus_parts.qnty
  with size 98 by 4 separators.
define variable agnt-name as character format "x(256)":u
      view-as text
     size 15.5 by 1 no-undo.
define variable wrkr-name as character format "x(256)":u
      view-as text
     size 15.5 by 1 no-undo.
define variable boss-name as character format "x(256)":u
      view-as text
     size 15.5 by 1 no-undo.
define variable ref-list     as character no-undo.
define variable rsn-name as character no-undo view-as fill-in size 37 by .88 fgcolor 4 format "x(256)":U.
define button b-mark
     label "&*":l
     size 3 by 1.
define button b-mark-op
     label "&*О":l
     size 3 by 1.
define button b-add
     label "&Добавить":l
     size 9 by 1.
define button b-chg
     label "&Изменить":l
     size 9 by 1.
define button b-chgvat
     label "&Заменить НДС":l
     size 13 by 1.
define button b-lkp
     label "&Партии"
     size 8 by 1.
define button b-lkp-op
     label "&Просм ориг":l
     size 15 by 1.
define button b-lkp-cp
     label "Просм поро&жд":l
     size 15 by 1.
define button b-chg-cp
     label "&Изм порожд":l
     size 15 by 1.
define button b-del
     label "&Удалить":l
     size 8 by 1.
define button b-notes
     label "При&меч":l
     size 8 by 1.
define button b-arch
     label "Уч&ет":l
     size 8 by 1.
define button b-cnt
     label "&ДогП":l
     size 8 by 1.
define button b-history
     label "Ис&тория"
     size 8 by 1.
define button b-help
     label "Помо&щь":l
     size 8 by 1.
define button b-exit auto-go
     label "&Выход":l
     size 6 by 1.
define button b-next auto-go
     label "&>>":l
     size 3 by 1.
define button b-prev auto-go
     label "&<<":l
     size 3 by 1.
define button b-sum-doc
     label "&СумДок":l
     size 8 by 1.
define button b-sum-goods
     label "&СумТов":l
     size 8 by 1.
define button b-file
     label "&Файл":l
     size 8 by 1.
define button r-agnt
       image-up          file "btn-down-arrow"
       image-down        file "btn-down-arrow"
       image-insensitive file "btn-down-arrow"
       size 3 by .88.
define rectangle rect-1 size 90 by 3 EDGE-PIXELS 2 GRAPHIC-EDGE bgcolor 8.
define button r-boss    like r-agnt.
define button r-wrkr    like r-agnt.
define button r-acc     like r-agnt.
define button r-clients like r-agnt.
define button r-reas    like r-agnt.
define frame d-doc
  t-doc.cli-code      at row 1    col 17 colon-aligned label "Контра&гент" view-as fill-in size 10 by 1 format ">>>>>>>>9"
  t-doc.cli-type      at row 1    col 28 colon-aligned no-label view-as fill-in size 4 by 1
  r-clients           at row 1    col 35 no-label
  clients.obj-name    at row 1    col 36 colon-aligned no-label view-as fill-in size 35 by 1 fgcolor 4
  b-exit              at row 1    col 1
  b-prev              at row 2    col 1
  b-next              at row 2    col 4
  varcntr-prn-code    at row 1    col 62 colon-aligned label "Договор"
  varcntr-name        at row 1    col 80 colon-aligned no-label format "x(15)"
  b-mark              at row 22.5 col 1
  b-add               at row 22.5 col 4
  b-lkp               at row 22.5 col 13
  b-chg               at row 22.5 col 21
  b-chgvat            at row 22.5 col 30
  b-del               at row 22.5 col 43
  b-file              at row 22.5 col 51
  b-notes             at row 22.5 col 59
  b-arch              at row 22.5 col 67
  b-cnt               at row 22.5 col 75
  b-history               at row 22.5 col 83
  b-help              at row 22.5 col 91
  t-doc.fact-rubl     at row 1.8  col 17 colon-aligned label "Сумма(руб)"
  t-doc.fact-base     at row 2.6  col 17 colon-aligned label "Сумма(вал)"
  varsum-exp-rubl     at row 1.8  col 46 colon-aligned label "Расход(руб)"
  varsum-inc-rubl     at row 1.8  col 75 colon-aligned label "Приход(руб)"
  varsum-exp-base     at row 2.6  col 46 colon-aligned label "Расход(вал)"
  varsum-inc-base     at row 2.6  col 75 colon-aligned label "Приход(вал)"
  varvat-exp-rubl     at row 3.4  col 18 colon-aligned label "Расход НДС (руб)" bgcolor 3 fgcolor 15
  varvat-inc-rubl     at row 3.4  col 62 colon-aligned label "Приход НДС (руб)" bgcolor 3 fgcolor 15
  varvat-exp-base     at row 4.2  col 18 colon-aligned label "Расход НДС (вал)" bgcolor 3 fgcolor 15
  varvat-inc-base     at row 4.2  col 62 colon-aligned label "Приход НДС (вал)" bgcolor 3 fgcolor 15
.
define frame d-doc
  t-doc.wrkr          format "999999999" at row 5.1 col 8  colon-aligned view-as fill-in size 10 by 1
  wrkr-name           at row 5.2 col 18 colon-aligned no-label  fgcolor 4
  r-wrkr              at row 5.2 col 41 no-label
  t-doc.agnt          format "999999999" at row 6 col 8 colon-aligned view-as fill-in size 10 by 1
  agnt-name           at row 6.1 col 18 colon-aligned no-label fgcolor 4
  r-agnt              at row 6.1 col 41 no-label
  t-doc.boss          format "999999999" at row 7 col 8 colon-aligned view-as fill-in size 10 by 1
  boss-name           at row 7 col 18 colon-aligned no-label fgcolor 4
  r-boss              at row 7 col 41 no-label
  t-doc.doc-date      at row 5 col 50 colon-aligned label "&Дата"  view-as fill-in size 9 by 1 fgcolor 4
  t-doc.fact-date     at row 6 col 50 colon-aligned label "&Факт"  view-as fill-in size 9 by 1 fgcolor 4
  t-doc.shift-date    at row 7 col 50 colon-aligned label "&Смена" view-as fill-in size 9 by 1 fgcolor 4
  t-doc.shift-name    at row 7 col 63 colon-aligned label "№"      view-as fill-in size 3 by 1 fgcolor 4
  t-doc.shift-num     at row 7 col 69 colon-aligned label "П"      view-as fill-in size 3 by 1 fgcolor 4
  t-doc.reason-code   at row 5.12 col 64     label "Код основ.(причины)" format ">>>>>>>>>9":U view-as fill-in size 11 by .88
  r-reas              at row 5.12 col 96
  rsn-name            at row 6.12 col 62  no-label
  br      at row 8 col 1
  br-op   at row 13 col 1
  b-mark-op           at row 17.5 col 1
  b-lkp-op            at row 17.5 col 4
  b-lkp-cp            at row 17.5 col 19
  b-chg-cp            at row 17.5 col 34
  br-cp   at row 18.5 col 1
  space(0) skip(0) with view-as dialog-box side-labels three-d scrollable keep-tab-order.
assign
  br:num-locked-columns    in frame d-doc = 5
  br-op:num-locked-columns in frame d-doc = 3
  br-cp:num-locked-columns in frame d-doc = 1
  frame d-doc:scrollable  = false
       .
assign
  r-reas            :tooltip in frame d-doc = "Основание (причина) создания документа. Вызов справочника"
  t-doc.reason-code :tooltip in frame d-doc = "Основание (причина) создания документа. Ввод кода"
  rsn-name          :tooltip in frame d-doc = "Основание (причина) создания документа"
.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-op as INT EXTENT 17 no-undo.
DEF VAR varmvibr-op       as INT no-undo.
DEF VAR varmvjbr-op       as INT no-undo.
DEF VAR varmvkbr-op       as INT no-undo.
DEF VAR varmvlbr-op       as INT no-undo.
DEF VAR move-elementbr-op as INT no-undo.
def var jjbr-op           as int no-undo.
do varmvibr-op = 1 to EXTENT(cur-clmn-numbr-op):
  ASSIGN cur-clmn-numbr-op[varmvibr-op] = varmvibr-op.
END.
RUN start-mv-clmnbr-op.
PROCEDURE start-mv-clmnbr-op:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-op do:
  RUN re-move-clmnbr-op ( 4, 17).
END.
ON ctrl-cursor-left OF BROWSE br-op do:
  RUN re-move-clmnbr-op (17, 4).
END.
PROCEDURE re-move-clmnbr-op:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-op = 1 TO EXTENT(cur-clmn-numbr-op):
    if cur-clmn-numbr-op[varmvibr-op] = source-column THEN cur-clmn-numbr-op[varmvibr-op] = -1.
  END.
  if br-op:MOVE-COLUMN(source-column, target-column) IN FRAME d-doc then.
  if source-column > target-column THEN
  DO varmvjbr-op = source-column - 1 to target-column BY -1:
    DO varmvibr-op = 1 TO EXTENT(cur-clmn-numbr-op):
        if cur-clmn-numbr-op[varmvibr-op] = varmvjbr-op THEN DO:
          cur-clmn-numbr-op[varmvibr-op] = cur-clmn-numbr-op[varmvibr-op] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-op = source-column + 1 to target-column:
    DO varmvibr-op = 1 TO EXTENT(cur-clmn-numbr-op):
      if cur-clmn-numbr-op[varmvibr-op] = varmvjbr-op THEN DO:
        cur-clmn-numbr-op[varmvibr-op] = cur-clmn-numbr-op[varmvibr-op] - 1.
      END.
    END.
  END.
  DO varmvibr-op = 1 TO EXTENT(cur-clmn-numbr-op):
    if cur-clmn-numbr-op[varmvibr-op] = -1 THEN cur-clmn-numbr-op[varmvibr-op] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-op:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmvibr-op = 1 TO EXTENT(cur-clmn-numbr-op):
    if cur-clmn-numbr-op[varmvibr-op] = cur-clmn-loc THEN move-elementbr-op = varmvibr-op.
  END.
  RUN re-move-clmnbr-op (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-op:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-op = 4 to EXTENT(cur-clmn-numbr-op):
    RUN re-move-clmnbr-op (cur-clmn-numbr-op[varmvlbr-op], varmvlbr-op).
  END.
  RUN start-mv-clmnbr-op.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-cp as INT EXTENT 15 no-undo.
DEF VAR varmvibr-cp       as INT no-undo.
DEF VAR varmvjbr-cp       as INT no-undo.
DEF VAR varmvkbr-cp       as INT no-undo.
DEF VAR varmvlbr-cp       as INT no-undo.
DEF VAR move-elementbr-cp as INT no-undo.
def var jjbr-cp           as int no-undo.
do varmvibr-cp = 1 to EXTENT(cur-clmn-numbr-cp):
  ASSIGN cur-clmn-numbr-cp[varmvibr-cp] = varmvibr-cp.
END.
RUN start-mv-clmnbr-cp.
PROCEDURE start-mv-clmnbr-cp:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-cp do:
  RUN re-move-clmnbr-cp ( 2, 15).
END.
ON ctrl-cursor-left OF BROWSE br-cp do:
  RUN re-move-clmnbr-cp (15, 2).
END.
PROCEDURE re-move-clmnbr-cp:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-cp = 1 TO EXTENT(cur-clmn-numbr-cp):
    if cur-clmn-numbr-cp[varmvibr-cp] = source-column THEN cur-clmn-numbr-cp[varmvibr-cp] = -1.
  END.
  if br-cp:MOVE-COLUMN(source-column, target-column) IN FRAME d-doc then.
  if source-column > target-column THEN
  DO varmvjbr-cp = source-column - 1 to target-column BY -1:
    DO varmvibr-cp = 1 TO EXTENT(cur-clmn-numbr-cp):
        if cur-clmn-numbr-cp[varmvibr-cp] = varmvjbr-cp THEN DO:
          cur-clmn-numbr-cp[varmvibr-cp] = cur-clmn-numbr-cp[varmvibr-cp] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-cp = source-column + 1 to target-column:
    DO varmvibr-cp = 1 TO EXTENT(cur-clmn-numbr-cp):
      if cur-clmn-numbr-cp[varmvibr-cp] = varmvjbr-cp THEN DO:
        cur-clmn-numbr-cp[varmvibr-cp] = cur-clmn-numbr-cp[varmvibr-cp] - 1.
      END.
    END.
  END.
  DO varmvibr-cp = 1 TO EXTENT(cur-clmn-numbr-cp):
    if cur-clmn-numbr-cp[varmvibr-cp] = -1 THEN cur-clmn-numbr-cp[varmvibr-cp] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-cp:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 2 then do:
    return .
  end.
  DO varmvibr-cp = 1 TO EXTENT(cur-clmn-numbr-cp):
    if cur-clmn-numbr-cp[varmvibr-cp] = cur-clmn-loc THEN move-elementbr-cp = varmvibr-cp.
  END.
  RUN re-move-clmnbr-cp (cur-clmn-loc, 2).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-cp:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-cp = 2 to EXTENT(cur-clmn-numbr-cp):
    RUN re-move-clmnbr-cp (cur-clmn-numbr-cp[varmvlbr-cp], varmvlbr-cp).
  END.
  RUN start-mv-clmnbr-cp.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr as INT EXTENT 26 no-undo.
DEF VAR varmvibr       as INT no-undo.
DEF VAR varmvjbr       as INT no-undo.
DEF VAR varmvkbr       as INT no-undo.
DEF VAR varmvlbr       as INT no-undo.
DEF VAR move-elementbr as INT no-undo.
def var jjbr           as int no-undo.
do varmvibr = 1 to EXTENT(cur-clmn-numbr):
  ASSIGN cur-clmn-numbr[varmvibr] = varmvibr.
END.
RUN start-mv-clmnbr.
PROCEDURE start-mv-clmnbr:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br do:
  RUN re-move-clmnbr ( 3, 26).
END.
ON ctrl-cursor-left OF BROWSE br do:
  RUN re-move-clmnbr (26, 3).
END.
PROCEDURE re-move-clmnbr:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr = 1 TO EXTENT(cur-clmn-numbr):
    if cur-clmn-numbr[varmvibr] = source-column THEN cur-clmn-numbr[varmvibr] = -1.
  END.
  if br:MOVE-COLUMN(source-column, target-column) IN FRAME d-doc then.
  if source-column > target-column THEN
  DO varmvjbr = source-column - 1 to target-column BY -1:
    DO varmvibr = 1 TO EXTENT(cur-clmn-numbr):
        if cur-clmn-numbr[varmvibr] = varmvjbr THEN DO:
          cur-clmn-numbr[varmvibr] = cur-clmn-numbr[varmvibr] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr = source-column + 1 to target-column:
    DO varmvibr = 1 TO EXTENT(cur-clmn-numbr):
      if cur-clmn-numbr[varmvibr] = varmvjbr THEN DO:
        cur-clmn-numbr[varmvibr] = cur-clmn-numbr[varmvibr] - 1.
      END.
    END.
  END.
  DO varmvibr = 1 TO EXTENT(cur-clmn-numbr):
    if cur-clmn-numbr[varmvibr] = -1 THEN cur-clmn-numbr[varmvibr] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 3 then do:
    return .
  end.
  DO varmvibr = 1 TO EXTENT(cur-clmn-numbr):
    if cur-clmn-numbr[varmvibr] = cur-clmn-loc THEN move-elementbr = varmvibr.
  END.
  RUN re-move-clmnbr (cur-clmn-loc, 3).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr = 3 to EXTENT(cur-clmn-numbr):
    RUN re-move-clmnbr (cur-clmn-numbr[varmvlbr], varmvlbr).
  END.
  RUN start-mv-clmnbr.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr   as character no-undo .
def var sort-clmnbr    as handle    no-undo .
def var cur-clmnbr     as handle    no-undo .
def var cur-clmn-locbr as integer   no-undo .
def var re-querybr     as logical   initial no no-undo .
on start-search, ctrl-o of br in frame d-doc do:
   run sort-brbr
     (input (if available bf_doc-line
             then recid(bf_doc-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr :
  define input parameter p-recid as recid no-undo .
  if re-querybr = no then do:
    assign
       cur-clmnbr = br:current-column in frame d-doc
    .
    if sort-clmnbr <> ? then sort-clmnbr:column-fgcolor = 0.
    if cur-clmnbr = sort-clmnbr then do:
      assign
         sort-labelbr = ""
         sort-clmnbr = ?
      .
     end.
     else do:
       assign
         sort-labelbr = cur-clmnbr:label
         sort-clmnbr  = cur-clmnbr
         sort-clmnbr:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr = cur-clmn-locbr + 1
    .
  end.
  case sort-labelbr:
        when '*'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by get-mark (buffer bf_doc-line) .   . END.
        when 'Артикул'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf_doc-line.artic .   . END.
        when 'Название товара'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf_goods.gds-name .   . END.
        when 'Тип'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf_doc-line.prod-type .   . END.
        when 'Код произ'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf_doc-line.prod-code .   . END.
        when 'Изм. кол-во'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.fact-qnty .   . END.
        when 'Расход сумма (руб)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.cost-sum-rubl descending .   . END.
        when 'Расход сумма (вал)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.cost-sum-base descending .   . END.
        when 'Приход сумма (руб)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-incp_doc-line-sum.cost-sum-rubl descending .   . END.
        when 'Приход сумма (вал)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-incp_doc-line-sum.cost-sum-base descending .   . END.
        when 'Расход НДС (руб)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.cost-vat-rubl descending .   . END.
        when 'Расход НДС (вал)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.cost-vat-base descending .   . END.
        when 'Приход НДС (руб)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-incp_doc-line-sum.cost-vat-rubl descending .   . END.
        when 'Приход НДС (вал)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-incp_doc-line-sum.cost-vat-base descending .   . END.
        when 'Расход НП (руб)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.cost-slt-rubl descending .   . END.
        when 'Расход НП (вал)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.cost-slt-base descending .   . END.
        when 'Приход НП (руб)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-incp_doc-line-sum.cost-slt-rubl descending .   . END.
        when 'Приход НП (вал)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-incp_doc-line-sum.cost-slt-base descending .   . END.
        when bf-expp_doc-line-sum.cost-road-tax-rubl:label in browse br  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.cost-road-tax-rubl descending .   . END.
        when bf-expp_doc-line-sum.cost-road-tax-base:label in browse br  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.cost-road-tax-base descending .   . END.
        when bf-incp_doc-line-sum.cost-road-tax-rubl:label in browse br  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-incp_doc-line-sum.cost-road-tax-rubl descending .   . END.
        when bf-incp_doc-line-sum.cost-road-tax-base:label in browse br  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-incp_doc-line-sum.cost-road-tax-base descending .   . END.
        when 'Расход трансп. и прочие расходы (руб)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.cost-transport-rubl + bf-expp_doc-line-sum.cost-other-rubl descending .   . END.
        when 'Расход трансп. и прочие расходы (вал)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-expp_doc-line-sum.cost-transport-base + bf-expp_doc-line-sum.cost-other-base descending .   . END.
        when 'Приход трансп. и прочие расходы (руб)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-incp_doc-line-sum.cost-transport-rubl + bf-incp_doc-line-sum.cost-other-rubl descending .   . END.
        when 'Приход трансп. и прочие расходы (вал)'  then DO:   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U by bf-incp_doc-line-sum.cost-transport-base + bf-incp_doc-line-sum.cost-other-base descending .   . END.
    otherwise do:
      open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U.
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr') then do:
          run mv-brw-defaultbr.
        end.
      if sort-labelbr <> "" then do:
        assign
          cur-clmnbr:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr = ?
      .
    end.
  end case.
    if cur-clmn-locbr <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr') then do:
        run ch-clmnbr in this-procedure (cur-clmn-locbr).
      end.
    end.
  if p-recid <> ? then do:
    reposition br to recid p-recid no-error.
    apply "value-changed" to br in frame d-doc.
  end.
  apply "entry" to br in frame d-doc.
END PROCEDURE.
procedure re-open-query-srt-clmnbr:
if cur-clmnbr = ? then do:
   open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U.
end.
else do:
   assign re-querybr = yes.
   run sort-brbr
     (input (if available bf_doc-line
             then recid(bf_doc-line)
             else ?
            )
     ).
   assign re-querybr = no.
end.
end.
on F9 of browse br anywhere do:
  define buffer bfl_goods for ub.goods.
    if not available bf_doc-line then
    return no-apply.
  find first bfl_goods where bfl_goods.artic     = bf_doc-line.artic     and
                             bfl_goods.prod-type = bf_doc-line.prod-type and
                             bfl_goods.prod-code = bf_doc-line.prod-code no-lock.
  run str/showgds.p ( input parparentproc
                    , input ?
                    , input bfl_goods.gds-code
                    , input 'ПРОСМОТР':U ).
  apply "entry" to br in frame d-doc.
  return no-apply.
end.
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-doc anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-doc. END.
  return no-apply.
end.
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame d-doc anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame d-doc. END.
  return no-apply.
end.
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame d-doc anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame d-doc. END.
  return no-apply.
end.
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame d-doc anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame d-doc. END.
  return no-apply.
end.
ON CHOOSE OF b-next IN FRAME d-doc
DO:
  RUN step-next in this-procedure .
END.
procedure step-next:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case t-doc.doc-type:
  when 'при':U then
    cur-form = if t-doc.internal then 'рас':U else 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then
    cur-form = 'рас':U.
  when 'инв':U then cur-form = 'инв':U.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-next-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это последний документ списка.".
end.
case new_trn-doc.doc-type:
  when 'при':U then
    new-form = if new_trn-doc.internal then 'рас':U else 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then
    new-form = 'рас':U.
  when 'инв':U then new-form = 'инв':U.
end case.
assign
    pardoc-rec   = bf-handle:recid
    parnext-prev = ( cur-form = new-form ) .
end procedure.
ON CHOOSE OF b-prev IN FRAME d-doc
DO:
  run step-prev in this-procedure .
END.
procedure step-prev:
define variable cur-form as char no-undo.
define variable new-form as char no-undo.
define buffer new_trn-doc for ub.trn-doc  .
case t-doc.doc-type:
  when 'при':U then if t-doc.internal then cur-form = 'рас':U. else cur-form = 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then cur-form = 'рас':U.
  when 'инв':U then cur-form = 'инв':U.
end case.
if bf-handle = ? then return .
if valid-handle (br-handle) then do:
  varlog = br-handle:select-prev-row().
  find first new_trn-doc no-lock where  recid( new_trn-doc ) = bf-handle:recid no-error .
  if not varlog then message "Это первый документ списка.".
end.
case new_trn-doc.doc-type :
  when 'при':U then if new_trn-doc.internal then new-form = 'рас':U. else new-form = 'при':U.
  when 'рас':U or when 'возврат':U or when 'спи':U then  new-form = 'рас':U.
  when 'инв':U then new-form = 'инв':U.
end case.
assign
  pardoc-rec   = bf-handle:recid
  parnext-prev = (cur-form = new-form)
.
end procedure.
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.agnt IN FRAME d-doc
DO:
  run local-psn-chk ("agnt", "ret-mouse").
  apply "entry" to t-doc.boss in frame d-doc.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.boss IN FRAME d-doc
DO:
  RUN local-psn-chk ("boss", "ret-mouse").
  apply "entry" to b-exit in frame d-doc.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF t-doc.wrkr IN FRAME d-doc
DO:
  RUN local-psn-chk ("wrkr", "ret-mouse").
  apply "entry" to t-doc.agnt in frame d-doc.
  return no-apply.
END.
ON CHOOSE OF r-agnt IN FRAME d-doc
DO:
  RUN local-psn-chk ("agnt", "button").
  apply "entry" to t-doc.boss in frame d-doc.
  return no-apply.
END.
ON CHOOSE OF r-boss IN FRAME d-doc
DO:
  RUN local-psn-chk ("boss", "button").
  apply "entry" to b-exit in frame d-doc.
  return no-apply.
END.
ON CHOOSE OF r-wrkr IN FRAME d-doc
DO:
  run local-psn-chk ("wrkr", "button").
  apply "entry" to t-doc.agnt in frame d-doc.
  return no-apply.
END.
on leave of t-doc.agnt in frame d-doc  do:
  if not available t-doc then return .
  if input frame d-doc t-doc.agnt <> t-doc.agnt then do:
    run local-psn-chk ("agnt", "leave").
  end.
end.
on leave of t-doc.boss in frame d-doc   do:
  if not available t-doc then return .
  if input frame d-doc t-doc.boss <> t-doc.boss then do:
    run local-psn-chk ("boss", "leave").
  end.
end.
on leave of t-doc.wrkr in frame d-doc  do:
  if not available t-doc then return .
  if input frame d-doc t-doc.wrkr <> t-doc.wrkr then do:
    run local-psn-chk ("wrkr", "leave").
  end.
end.
procedure local-psn-chk :
  define input parameter parman    as character no-undo.
  define input parameter paraction as character no-undo.
  if parman = "agnt" and paraction = "ret-mouse" then do:
  define variable v-ref-rec41   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-doc t-doc.agnt <> ""
       and input frame d-doc t-doc.agnt <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec41 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-doc.
    assign frame d-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt
               ? @ agnt-name with frame d-doc.
  apply "entry" to t-doc.boss
                            in frame d-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-doc.
      return no-apply.
  end.
  if parman = "agnt" and paraction = "button" then do:
  define variable v-ref-rec42   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec42 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec42 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-doc.
    assign frame d-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt
               ? @ agnt-name with frame d-doc.
  apply "entry" to t-doc.boss
                            in frame d-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-doc.
      return no-apply.
  end.
  if parman = "agnt" and paraction = "leave" then do:
  define variable v-ref-rec43   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-doc.
          assign frame d-doc t-doc.agnt.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-doc.
  end.
  if parman = "boss" and paraction = "ret-mouse" then do:
  define variable v-ref-rec44   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-doc t-doc.boss <> ""
       and input frame d-doc t-doc.boss <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec44 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.boss
            cli-buf.obj-name @ boss-name with frame d-doc.
    assign frame d-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss
               ? @ boss-name with frame d-doc.
  apply "entry" to  b-exit in frame d-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-doc.
      return no-apply.
  end.
  if parman = "boss" and paraction = "button" then do:
  define variable v-ref-rec45   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec45 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec45 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.boss
            cli-buf.obj-name @ boss-name with frame d-doc.
    assign frame d-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss
               ? @ boss-name with frame d-doc.
  apply "entry" to  b-exit in frame d-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-doc.
      return no-apply.
  end.
  if parman = "boss" and paraction = "leave" then do:
  define variable v-ref-rec46   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-doc.
          assign frame d-doc t-doc.boss.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-doc.
  end.
  if parman = "wrkr" and paraction = "ret-mouse" then do:
  define variable v-ref-rec47   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-doc t-doc.wrkr <> ""
       and input frame d-doc t-doc.wrkr <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec47 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-doc.
    assign frame d-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr
               ? @ wrkr-name with frame d-doc.
  apply "entry" to t-doc.agnt in frame d-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-doc.
      return no-apply.
  end.
  if parman = "wrkr" and paraction = "button" then do:
  define variable v-ref-rec48   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec48 = ( if available cli-buf then recid( cli-buf ) else ? ).
  ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec48 = integer( ref-list ).
    ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ t-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-doc.
    assign frame d-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr
               ? @ wrkr-name with frame d-doc.
  apply "entry" to t-doc.agnt in frame d-doc.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-doc.
      return no-apply.
  end.
  if parman = "wrkr" and paraction = "leave" then do:
  define variable v-ref-rec49   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-doc.
          assign frame d-doc t-doc.wrkr.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-doc.
  end.
end procedure.
on end-error, stop of frame d-doc do:
  apply "choose" to b-exit in frame d-doc.
  return no-apply.
end.
on choose of b-notes in frame d-doc do:
  run notes-tr in this-procedure.
end.
on choose of b-history   in frame d-doc do:
  run proc-history no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-exit  in frame d-doc
do:
  run proc-exit in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-arch in frame d-doc
do:
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if not varlog then do: return no-apply. end.
  run str/docsuppn.w
    (input  parparentproc
    ,input  recid( t-doc )
    ).
end.
on choose of b-cnt in frame d-doc
do:
define variable vss-include-info51 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_cost':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
  if not varlog then do: return no-apply. end.
  run str/scntdoc.w ( input t-doc.doc-code, input ( v-cntxt-db-num = bf_sysconf.firm-db-num ) ).
end.
on choose of b-add in frame d-doc
do:
define variable varuser-action as character no-undo.
define variable varprinted     as logical   no-undo.
assign
  varlog-err = no.
if search (varfile-name) <> ? then do:
  os-delete varfile-name.
end.
output stream str-err to value(varfile-name).
run local-add in this-procedure no-error.
if error-status :error then do:
  output stream str-err close.
  return no-apply.
end.
output stream str-err close.
if varlog-err = yes then do:
  message "При добавлении товаров были ошибки и замечания. Смотрите файл log-cor.err."
  view-as alert-box error.
  run gbl/prnfilen.w
    (input  "Ошибки и замечания, возникшие при добавлении товаров"
    ,input  0
    ,input  varfile-name
    ,input  7
    ,output varuser-action
    ,output varprinted
    ).
end.
end.
on choose of b-chg in frame d-doc  do:
  run local-chg in this-procedure.
  run ui-on in this-procedure ( input "line":U ).
  apply "entry" to br in frame d-doc .
  reposition br to recid line-rec no-error.
end.
on choose of b-chgvat in frame d-doc  do:
  define variable varuser-action as character no-undo.
  define variable varprinted     as logical   no-undo.
  assign
    varlog-err = no.
  if search ("log-cor.err") <> ? then do:
    os-delete "log-cor.err".
  end.
  output stream str-err to value("log-cor.err").
  run local-chg-vat in this-procedure no-error.
  if error-status :error then do:
    output stream str-err close.
    return no-apply.
  end.
  output stream str-err close.
  if varlog-err = yes then do:
    message "При изменении НДС были ошибки и замечания. Смотрите файл log-cor.err."
    view-as alert-box error.
    run gbl/prnfilen.w
      (input  "Ошибки и замечания, возникшие при изменении НДС"
      ,input  0
      ,input  "log-cor.err"
      ,input  7
      ,output varuser-action
      ,output varprinted
      ).
  end.
  run ui-on in this-procedure ( input "line":U ).
  apply "entry" to br in frame d-doc .
  reposition br to recid line-rec no-error.
end.
on choose of b-file in frame d-doc do:
run str/file-cor.p (input parparentproc, input t-doc.doc-code) no-error.
if error-status:error then do:
  message "Во время обработки файла произошли ошибки или не верно был выбран файл. Файл не был обработан."
          return-value
  view-as alert-box error.
  return no-apply.
end.
run ui-on ("line":u).
apply "entry" to br in frame d-doc .
end.
on choose of b-chg-cp in frame d-doc  do:
define buffer bf_goods for ub.goods.
define variable varhvrdtax as logical no-undo.
define variable varslt-yes as logical no-undo.
define variable varis-ok   as logical no-undo.
define variable varexch-rate  like ub.trn-doc.exch-rate  no-undo.
define variable varexch-scale like ub.trn-doc.exch-scale no-undo.
define variable varabbr-code  as   character             no-undo.
define buffer bf-expp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-incp_trn-doc-sum  for ub.trn-doc-sum.
do transaction on error undo, return no-apply :
if not available bf-caus_parts then do:
  message "Неверный выбор партии." view-as alert-box.
  return no-apply.
end.
run local-recalc in this-procedure ( input "old":U,
                                     input recid( bf_doc-line ) ) no-error.
if error-status :error then do:
  message
    "Ошибка при пересчете строки документа" skip
    return-value skip
    trim(error-status :get-message(1))
    view-as alert-box error.
  undo, return no-apply .
end.
find first bf_goods where bf_goods.artic     = bf-caus_parts.artic     and
                          bf_goods.prod-type = bf-caus_parts.prod-type and
                          bf_goods.prod-code = bf-caus_parts.prod-code no-lock.
assign
  varhvrdtax = hvrdtax ( recid( bf_goods ) ).
find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_chpsltpc in g#lib-trn
(
 input  t-doc.internal
,input  t-doc.doc-type
,input  bf-caus_parts.pay-code
,input  bf_sysconf.cash-pay
,input  bf-caus_parts.slt-type
,input  varslt-yes
,output parext-doc-type
)
.
if bf-caus_parts.slt-type <> 'в т. ч.':U and
   bf-caus_parts.slt-type <> 'нет':U  then do:
  assign
    varslt-yes = no.
end.
for each tt-chs-parts on error undo, return no-apply return-value :
  delete tt-chs-parts.
end.
assign
  varcli-base-rate = bf-caus_parts.cli-base-rate
  varvat-type      = bf-caus_parts.vat-type
  varslt-type      = bf-caus_parts.slt-type.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  bf-caus_parts.exch-code
  ,input  t-doc.exch-date
  ,output varexch-rate
  ,output varexch-scale
  ,output varabbr-code
  )  .
run str/pr-prt.w (
  input  "part":u,
  input  bf_goods.gds-code,
  input  t-doc.cli-type,
  input  t-doc.cli-code,
  input  t-doc.obj-type,
  input  t-doc.obj-code,
  input  bf-caus_parts.in-code,
  input  bf-caus_parts.out-code,
  input  bf-caus_parts.part-code,
  input  t-doc.base-rate,
  input  t-doc.base-scale,
  input  bf-caus_parts.exch-code,
  input  varexch-rate,
  input  varexch-scale,
  input  varslt-yes,
  input  varhvrdtax,
  input  t-doc.contract-code,
  input  table tt-chs-parts,
  output varprice-base,
  output varsum-base,
  output varprice-rubl,
  output varsum-rubl,
  input-output varcli-base-rate,
  input-output varvat-type,
  input-output varslt-type,
  output varprice-cli,
  output varsum-cli,
  output varvat-pc,
  output varvat-base,
  output varsum-vat-base,
  output varvat-rubl,
  output varsum-vat-rubl,
  output varvat-rubl,
  output varsum-vat-rubl,
  output varslt-pc,
  output varslt-base,
  output varsum-slt-base,
  output varslt-rubl,
  output varsum-slt-rubl,
  output varslt-cli,
  output varsum-slt-cli,
  output varroad-tax-base,
  output varsum-road-tax-base,
  output varroad-tax-rubl,
  output varsum-road-tax-rubl,
  output varroad-tax-cli,
  output varsum-road-tax-cli,
  output vartransport-base,
  output varsum-transport-base,
  output vartransport-rubl,
  output varsum-transport-rubl,
  output varother-base,
  output varsum-other-base,
  output varother-rubl,
  output varsum-other-rubl,
  output varpurch-code,
  output varis-ok         ) no-error.
if error-status :error then do:
  message
    "Ошибка при установке цен." skip
    return-value skip
    error-status :get-message( 1 )
    view-as alert-box error.
  undo, return no-apply .
end.
if varis-ok <> yes then do:
  undo, return no-apply .
end.
find current bf-caus_parts exclusive-lock.
assign
  bf-caus_parts.price-rubl     = varprice-rubl
  bf-caus_parts.price-base     = varprice-base
  bf-caus_parts.price-cli      = varprice-cli
  bf-caus_parts.cli-base-rate  = varcli-base-rate
  bf-caus_parts.vat-type       = varvat-type
  bf-caus_parts.slt-type       = varslt-type
  bf-caus_parts.vat-pc         = varvat-pc
  bf-caus_parts.slt-pc         = varslt-pc
  bf-caus_parts.road-tax-rubl  = varroad-tax-rubl
  bf-caus_parts.road-tax-base  = varroad-tax-base
  bf-caus_parts.transport-rubl = vartransport-rubl
  bf-caus_parts.transport-base = vartransport-base
  bf-caus_parts.other-rubl     = varother-rubl
  bf-caus_parts.other-base     = varother-base
  .
if varpurch-code <> ? then do:
  assign
    bf-caus_parts.purch-code = varpurch-code.
end.
end.
run local-recalc in this-procedure ( input "update":U,
                                     input recid( bf_doc-line ) ) no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при пересчете строки документа" skip
    return-value skip
    trim(error-status :get-message(1))
    view-as alert-box error.
  undo, return no-apply .
end.
find first bf-expp_trn-doc-sum where bf-expp_trn-doc-sum.doc-code = t-doc.doc-code       and
                                     bf-expp_trn-doc-sum.sum-type = 'exp':U no-lock no-error.
find first bf-incp_trn-doc-sum where bf-incp_trn-doc-sum.doc-code = t-doc.doc-code      and
                                     bf-incp_trn-doc-sum.sum-type = 'inp':U no-lock no-error.
display
(if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-sum-rubl else ?) @ varsum-exp-rubl
(if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-sum-rubl else ?) @ varsum-inc-rubl
(if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-sum-base else ?) @ varsum-exp-base
(if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-sum-base else ?) @ varsum-inc-base
(if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-vat-rubl else ?) @ varvat-exp-rubl
(if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-vat-rubl else ?) @ varvat-inc-rubl
(if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-vat-base else ?) @ varvat-exp-base
(if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-vat-base else ?) @ varvat-inc-base
with frame d-doc.
display t-doc.fact-base t-doc.fact-rubl with frame d-doc.
display
  bf-expp_doc-line-sum.fact-qnty
  bf-expp_doc-line-sum.cost-sum-rubl
  bf-expp_doc-line-sum.cost-sum-base
  bf-incp_doc-line-sum.cost-sum-rubl
  bf-incp_doc-line-sum.cost-sum-base
  bf-expp_doc-line-sum.cost-vat-rubl
  bf-expp_doc-line-sum.cost-vat-base
  bf-incp_doc-line-sum.cost-vat-rubl
  bf-incp_doc-line-sum.cost-vat-base
  bf-expp_doc-line-sum.cost-slt-rubl
  bf-expp_doc-line-sum.cost-slt-base
  bf-incp_doc-line-sum.cost-slt-rubl
  bf-incp_doc-line-sum.cost-slt-base
  bf-expp_doc-line-sum.cost-road-tax-rubl
  bf-expp_doc-line-sum.cost-road-tax-base
  bf-incp_doc-line-sum.cost-road-tax-rubl
  bf-incp_doc-line-sum.cost-road-tax-base
  bf-expp_doc-line-sum.cost-transport-rubl + bf-expp_doc-line-sum.cost-other-rubl @ varto-exp-rubl
  bf-expp_doc-line-sum.cost-transport-base + bf-expp_doc-line-sum.cost-other-base @ varto-exp-base
  bf-incp_doc-line-sum.cost-transport-rubl + bf-incp_doc-line-sum.cost-other-rubl @ varto-inc-rubl
  bf-incp_doc-line-sum.cost-transport-base + bf-incp_doc-line-sum.cost-other-base @ varto-inc-base
  with browse br.
display bf-caus_parts.price-rubl bf-caus_parts.price-base bf-caus_parts.vat-pc bf-caus_parts.slt-pc
        bf-caus_parts.road-tax-rubl bf-caus_parts.road-tax-base  bf-caus_parts.transport-rubl bf-caus_parts.transport-base
        bf-caus_parts.other-rubl  bf-caus_parts.other-base    with browse br-cp.
end.
define variable vss-include-info53 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-doc anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-doc. END.
  return no-apply.
end.
on choose of b-mark in frame d-doc do:
 run mark-list in this-procedure.
end.
on choose of b-mark-op in frame d-doc do:
 run mark-list-op in this-procedure.
end.
on choose of b-del in frame d-doc do:
  define variable varrep-rec as recid no-undo.
  run local-del in this-procedure ( output varrep-rec ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении партий."  skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    return no-apply.
  end.
  run ui-on in this-procedure ( input "line":U ).
  apply "entry" to br in frame d-doc .
  if varrep-rec <> ? then do:
    reposition br to recid varrep-rec no-error.
  end.
end.
on choose of b-lkp in frame d-doc
do:
  run local-lockup in this-procedure.
end.
on choose of b-lkp-op in frame d-doc
do:
  define buffer bf_doc-line for ub.doc-line.
  define buffer bf_goods    for ub.goods.
  define variable prt-rec as recid no-undo.
  if not available bf-orig_parts then do:
    message "Неправильно выбрана оригинальная партия." view-as alert-box information.
    return no-apply.
  end.
  find first bf_doc-line where bf_doc-line.doc-code  = bf-orig_parts.out-code  and
                              bf_doc-line.artic     = bf-orig_parts.artic     and
                              bf_doc-line.prod-type = bf-orig_parts.prod-type and
                              bf_doc-line.prod-code = bf-orig_parts.prod-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  assign
    prt-rec   = recid( bf-orig_parts )
    .
  run str/parts-f.w
    (input        parparentproc
    ,input        ?
    ,input        'ПРОСМОТР':U
    ,input        bf_doc-line.doc-code
    ,input        bf_goods.gds-code
    ,input        0
    ,input-output prt-rec
    ).
end.
on choose of b-lkp-cp in frame d-doc
do:
  define buffer bf_doc-line for ub.doc-line.
  define buffer bf_goods    for ub.goods.
  define variable prt-rec as recid no-undo.
  if not available bf-caus_parts then do:
    message "Неправильно выбрана порожденная партия." view-as alert-box information.
    return no-apply.
  end.
  find first bf_doc-line where bf_doc-line.doc-code  = bf-caus_parts.out-code  and
                              bf_doc-line.artic     = bf-caus_parts.artic     and
                              bf_doc-line.prod-type = bf-caus_parts.prod-type and
                              bf_doc-line.prod-code = bf-caus_parts.prod-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  assign
    prt-rec   = recid( bf-caus_parts )
    .
  run str/parts-f.w
    (input        parparentproc
    ,input        ?
    ,input        'ПРОСМОТР':U
    ,input        bf_doc-line.doc-code
    ,input        bf_goods.gds-code
    ,input        0
    ,input-output prt-rec
    ).
end.
on value-changed of browse br do:
 open query br-op   for each bf-orig_parts where bf-orig_parts.out-code  = t-doc.doc-code        and                                  bf-orig_parts.obj-type  = t-doc.obj-type        and                                  bf-orig_parts.obj-code  = t-doc.obj-code        and                                  bf-orig_parts.artic     = bf_doc-line.artic     and                                  bf-orig_parts.prod-type = bf_doc-line.prod-type and                                  bf-orig_parts.prod-code = bf_doc-line.prod-code and                                  bf-orig_parts.in-code  <> t-doc.doc-code no-lock,       first bf-orig_goods where bf-orig_goods.artic     = bf-orig_parts.artic     and                                      bf-orig_goods.prod-type = bf-orig_parts.prod-type and                                      bf-orig_goods.prod-code = bf-orig_parts.prod-code no-lock.
 open query br-cp   for each bf_parts-root where bf_parts-root.doc-code       = bf-orig_parts.out-code  and                                     bf_parts-root.orig-in-code   = bf-orig_parts.in-code   and                                     bf_parts-root.orig-gds-code  = bf-orig_goods.gds-code  and                                     bf_parts-root.orig-part-code = bf-orig_parts.part-code no-lock,       first bf-caus_parts where bf-caus_parts.out-code  = bf_parts-root.doc-code  and                                 bf-caus_parts.obj-type  = bf-orig_parts.obj-type  and                                 bf-caus_parts.obj-code  = bf-orig_parts.obj-code  and                                 bf-caus_parts.artic     = bf-orig_parts.artic     and                                 bf-caus_parts.prod-type = bf-orig_parts.prod-type and                                 bf-caus_parts.prod-code = bf-orig_parts.prod-code and                                 bf-caus_parts.in-code   = bf_parts-root.in-code   and                                 bf-caus_parts.part-code = bf_parts-root.part-code.
end.
on value-changed of browse br-op do:
  open query br-cp   for each bf_parts-root where bf_parts-root.doc-code       = bf-orig_parts.out-code  and                                     bf_parts-root.orig-in-code   = bf-orig_parts.in-code   and                                     bf_parts-root.orig-gds-code  = bf-orig_goods.gds-code  and                                     bf_parts-root.orig-part-code = bf-orig_parts.part-code no-lock,       first bf-caus_parts where bf-caus_parts.out-code  = bf_parts-root.doc-code  and                                 bf-caus_parts.obj-type  = bf-orig_parts.obj-type  and                                 bf-caus_parts.obj-code  = bf-orig_parts.obj-code  and                                 bf-caus_parts.artic     = bf-orig_parts.artic     and                                 bf-caus_parts.prod-type = bf-orig_parts.prod-type and                                 bf-caus_parts.prod-code = bf-orig_parts.prod-code and                                 bf-caus_parts.in-code   = bf_parts-root.in-code   and                                 bf-caus_parts.part-code = bf_parts-root.part-code.
end.
on entry of t-doc.cli-code, r-clients in frame d-doc do:
  if t-doc.cli-code <> ? then do:
    assign pardoc-mode = 'ДОБАВЛЕНИЕ':U.
    run UI-on in this-procedure ( input "enable" ).
  end.
end.
on choose of r-clients in frame d-doc
do:
  define buffer bf_clients for ub.clients.
  run ref/cli-all.w (  input parparentproc
                ,  input "b-sel"
                ,  input ?
                ,  input ?
                ,  input ?
                ,  input ?
                ,  input ?
                ,  input ?
                , output ref-list ) .
  if ref-list <> "" then do:
    assign
      ref-rec = integer (ref-list).
    find first bf_clients where recid( bf_clients ) = ref-rec no-lock.
    display bf_clients.obj-code @ t-doc.cli-code
        bf_clients.obj-name @ clients.obj-name
        bf_clients.obj-type @ t-doc.cli-type with frame d-doc.
  end.
  run check-cli in this-procedure no-error.
  if error-status :error then do:
    return no-apply.
  end.
end.
on mouse-select-dblclick, return of t-doc.cli-code, t-doc.cli-type
  in frame d-doc
do:
  run choose-cli in this-procedure no-error.
  if error-status :error then do:
    display ? @ t-doc.cli-type ? @ t-doc.cli-code with frame d-doc.
  end.
  return no-apply.
end.
on leave of t-doc.reason-code in frame d-doc do:
  run check-reason in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on return of t-doc.reason-code in frame d-doc do:
  run check-reason in this-procedure no-error .
  if error-status :error then do: return no-apply. end.
end.
on choose of r-reas in frame d-doc do:
  run select-reason in this-procedure.
end.
if valid-handle(active-window) and frame d-doc:parent eq ?
then frame d-doc:parent = active-window.
on window-close of frame d-doc apply "end-error":u to self.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-doc
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
on choose of b-help in frame d-doc
do:
  apply "help":u to frame d-doc .
end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-doc:width - 0.3
                fh            = frame d-doc:first-child
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
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-doc :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-doc :height-chars)
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
    if frame d-doc :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-doc :height-chars)
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
            frame d-doc :height = v-frame-height
          .
          if frame d-doc :scrollable = true
          then do:
            assign
              frame d-doc :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-doc :scrollable = true
          then do:
            assign
              frame d-doc :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-doc :height = v-frame-height
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
      v-frame-height = frame d-doc :height
      v-frame-virtual-height = frame d-doc :virtual-height
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
      v-field-group-handle = frame d-doc :first-child
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
    do with frame d-doc
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-doc :scrollable = true
      then do:
        assign
          frame d-doc :virtual-height = frame d-doc :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-doc :height = frame d-doc :height + p-change-value
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
        frame d-doc :height = frame d-doc :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-doc :scrollable = true
      then do:
        assign
          frame d-doc :virtual-height = frame d-doc :virtual-height + p-change-value
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
          ,input  string(frame d-doc :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-doc :height)
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
    if frame d-doc :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-doc :width
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
    if frame d-doc :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-doc :width
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
            frame d-doc :width = v-frame-width
          .
          if frame d-doc :scrollable = true
          then do:
            assign
              frame d-doc :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-doc :scrollable = true
          then do:
            assign
              frame d-doc :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-doc :width = v-frame-width
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
      v-frame-width = frame d-doc :width
      v-frame-virtual-width = frame d-doc :virtual-width
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
      v-field-group-handle = frame d-doc :first-child
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
    do with frame d-doc
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-doc :scrollable = true
      then do:
        assign
          frame d-doc :virtual-width = frame d-doc :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-doc :width = v-frame-width + p-change-value
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
        frame d-doc :width = frame d-doc :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-doc :scrollable = true
      then do:
        assign
          frame d-doc :virtual-width = frame d-doc :virtual-width + p-change-value
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
          ,input  string(frame d-doc :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-doc :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-doc
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-doc :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-doc :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-doc :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-doc :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-doc
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
      v-row-delta = v-new-row - frame d-doc :height
      v-col-delta = v-new-col - frame d-doc :width
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
            - frame d-doc :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-doc :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-doc :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-doc :height-chars
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
      v-diasize-current-frame-width  = frame d-doc :width
      v-diasize-current-frame-height = frame d-doc :height
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
    do with frame d-doc
    :
      assign
        v-diasize-orig-frame-height = frame d-doc :height
        v-diasize-orig-frame-width  = frame d-doc :width
        v-diasize-browse-handle     = browse br :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-doc :first-child
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
  ,input  browse br-op :handle
  ) .
run diasize_add_browse in this-procedure
  (input  'width':u
  ,input  browse br-cp :handle
  ) .
run diasize_init in this-procedure .
assign
  parnext-prev = yes.
n-p:
do while parnext-prev :
  assign
    parext-doc-mode =
      ( if num-entries( pardoc-mode, '*':U ) > 1 then entry( 2, pardoc-mode, '*':U ) else '':U )
    pardoc-mode     = entry( 1, pardoc-mode, '*':U )
  .
  if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.
  main-block:
  do on error undo main-block, leave main-block :
    define variable varroad-tax-label as character no-undo.
    run tax-name in this-procedure ( input 'rdt':U, output varroad-tax-label ) no-error.
    if error-status :error then do:
      assign
        parnext-prev = no.
      return error.
    end.
    assign
      bf-expp_doc-line-sum.cost-road-tax-rubl:label in browse br =  "Расход <" + varroad-tax-label + "> (руб)"
      bf-expp_doc-line-sum.cost-road-tax-base:label in browse br =  "Расход <" + varroad-tax-label + "> (вал)"
      bf-incp_doc-line-sum.cost-road-tax-rubl:label in browse br =  "Приход <" + varroad-tax-label + "> (руб)"
      bf-incp_doc-line-sum.cost-road-tax-base:label in browse br =  "Приход <" + varroad-tax-label + "> (вал)"
    .
    assign
      bf-orig_parts.road-tax-rubl:label in browse br-op = varroad-tax-label + "(руб)"
      bf-orig_parts.road-tax-base:label in browse br-op = varroad-tax-label + "(вал)"
      bf-caus_parts.road-tax-rubl:label in browse br-cp = varroad-tax-label + "(руб)"
      bf-caus_parts.road-tax-base:label in browse br-cp = varroad-tax-label + "(вал)"
    .
     run mode-on in this-procedure no-error.
     if error-status :error then do:
       assign
         parnext-prev = no.
       return error.
     end.
     run ui-on in this-procedure ( input "enable":U ) no-error.
     if error-status:error then do:
       assign
         parnext-prev = no.
       return error.
     end.
     find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
     if pardoc-mode = 'ПРОСМОТР':U then do:
       wait-for go of frame d-doc focus b-lkp.
     end.
     else do:
       if pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
         wait-for go of frame d-doc focus t-doc.cli-code.
       end.
       else do:
         wait-for go of frame d-doc focus b-add.
       end.
     end.
  end.
end.
run disable_ui in this-procedure.
procedure disable_ui :
  hide frame d-doc.
end procedure.
procedure ui-on :
  define input parameter fnc as character no-undo.
  define buffer bf-expp_trn-doc-sum  for ub.trn-doc-sum.
  define buffer bf-incp_trn-doc-sum  for ub.trn-doc-sum.
  do on error undo, return error return-value :
    for each tt-del-list-op on error undo, return error return-value :
      delete tt-del-list-op.
    end.
    for each tt-del-list on error undo, return error return-value :
      delete tt-del-list.
    end.
    if fnc = "enable":U then do:
      assign
        bf_doc-line.prod-code:read-only    in browse br    = yes
        bf-orig_parts.qnty:read-only in browse br-op = yes
        bf-caus_parts.qnty:read-only in browse br-cp = yes.
      disable all with frame d-doc.
      enable b-exit b-lkp b-lkp-op b-lkp-cp b-help
             br br-op br-cp
             b-arch b-cnt b-history b-notes
      with frame d-doc.
      if pardoc-mode <> 'ПРОСМОТР':U or pardoc-mode = 'ПРОСМОТР':U and parext-doc-mode = "reason-code" then do:
        enable r-reas t-doc.reason-code with frame d-doc.
      end.
      case pardoc-mode :
        when 'ПРОСМОТР':U then do:
          enable b-prev b-next with frame d-doc.
        end.
        when 'ДОБАВЛЕНИЕ':U then do:
          enable t-doc.cli-code t-doc.cli-type r-clients with frame d-doc.
        end.
        otherwise do:
          enable b-add b-chg b-chgvat b-del b-mark b-file
                 b-mark-op
                 b-chg-cp
                 t-doc.wrkr t-doc.agnt t-doc.boss
                 r-wrkr r-agnt r-boss
          with frame d-doc.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,input  'shift-on=request'
  ,output varlog
  ) no-error .
          if error-status :error then do:
            message
            vss-workfile vss-revision vss-description skip
            "Ошибка при запуске процедуры objat" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
            return error.
          end.
          if not varlog then do:
           hide t-doc.shift-date t-doc.shift-num t-doc.shift-name  in frame d-doc.
          end.
        end.
      end case.
    end.
    find first bf-expp_trn-doc-sum no-lock where
               bf-expp_trn-doc-sum.doc-code = t-doc.doc-code       and
               bf-expp_trn-doc-sum.sum-type = 'exp':U no-error.
    find first bf-incp_trn-doc-sum no-lock where
               bf-incp_trn-doc-sum.doc-code = t-doc.doc-code       and
               bf-incp_trn-doc-sum.sum-type = 'inp':U  no-error.
    display
      ( if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-sum-rubl else ? ) @ varsum-exp-rubl
      ( if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-sum-rubl else ? ) @ varsum-inc-rubl
      ( if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-sum-base else ? ) @ varsum-exp-base
      ( if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-sum-base else ? ) @ varsum-inc-base
      ( if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-vat-rubl else ? ) @ varvat-exp-rubl
      ( if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-vat-rubl else ? ) @ varvat-inc-rubl
      ( if available bf-expp_trn-doc-sum then bf-expp_trn-doc-sum.cost-vat-base else ? ) @ varvat-exp-base
      ( if available bf-incp_trn-doc-sum then bf-incp_trn-doc-sum.cost-vat-base else ? ) @ varvat-inc-base
    with frame d-doc.
    display t-doc.doc-date t-doc.fact-date t-doc.shift-date t-doc.shift-num t-doc.shift-name
            t-doc.fact-rubl
            t-doc.fact-base
            t-doc.cli-type t-doc.cli-code
            varcntr-prn-code
            varcntr-name
    with frame d-doc.
    find first clients where
               clients.obj-type = t-doc.cli-type and
               clients.obj-code = t-doc.cli-code no-error.
    if available clients then do:
      display clients.obj-name with frame d-doc.
    end.
    find ub.trn-reason no-lock where
         ub.trn-reason.reason-code = t-doc.reason-code no-error.
    assign
      rsn-name = ( if available ub.trn-reason then ub.trn-reason.reason-name else "":U )
    .
    display t-doc.reason-code rsn-name with frame d-doc.
    assign
      frame d-doc :title = t-doc.obj-type + " " + string( t-doc.obj-code, ">>>>9":U ) + "  : КОРРЕКЦИЯ " +
      ( if t-doc.ext-doc-type = 'ap':U   then "УЧЕТНЫХ ЦЕН "         else
      ( if t-doc.ext-doc-type = 'mp':U then "ОТРИЦАТЕЛЬНЫХ ПАРТИЙ" else "ТИПА ПРИОБРЕТЕНИЯ" ) ) +
      t-doc.status_ + " " + string( t-doc.flag_, "+/-":U ) + " № " + t-doc.doc-code + "   - ".
    assign frame d-doc :title = frame d-doc :title +
      ( if parext-doc-mode = ""            then title-mode( pardoc-mode ) else ( caps( 'редакт-факт':U ) +
      ( if parext-doc-mode = "reason-code" then " кода основания"         else "":U ) ) ).
    display t-doc.wrkr t-doc.agnt t-doc.boss with frame d-doc.
  define variable v-ref-rec58   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.wrkr with frame d-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-doc t-doc.wrkr
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-doc.
  end.
  else display ? @ t-doc.wrkr ? @ wrkr-name with frame d-doc.
  define variable v-ref-rec59   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.agnt with frame d-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-doc t-doc.agnt
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.agnt cli-buf.obj-name @ agnt-name with frame d-doc.
  end.
  else display ? @ t-doc.agnt ? @ agnt-name with frame d-doc.
  define variable v-ref-rec60   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-doc t-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display t-doc.boss with frame d-doc.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-doc t-doc.boss
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ t-doc.boss cli-buf.obj-name @ boss-name with frame d-doc.
  end.
  else display ? @ t-doc.boss ? @ boss-name with frame d-doc.
    run open-all-browse in this-procedure.
  end.
end procedure.
procedure mark-list:
do on error undo, return error return-value :
if not available bf_doc-line then do:
  message "Неправильный выбор строки.".
  return no-apply.
end.
find first tt-del-list where tt-del-list.rec-id = recid( bf_doc-line ) no-error.
if available tt-del-list then do:
  delete tt-del-list.
end.
else do:
  create tt-del-list.
  assign
    tt-del-list.rec-id = recid( bf_doc-line ).
end.
br:refresh() in frame d-doc.
varlog = br:select-next-row () in frame d-doc.
apply "entry" to br in frame d-doc.
end.
end procedure.
procedure mark-list-op:
do on error undo, return error return-value :
if not available bf-orig_parts then do:
  message "Неправильный выбор строки.".
  return no-apply.
end.
find first tt-del-list-op where tt-del-list-op.rec-id = recid( bf-orig_parts ) no-error.
if available tt-del-list-op then do:
  delete tt-del-list-op.
end.
else do:
  create tt-del-list-op.
  assign
    tt-del-list-op.rec-id = recid( bf-orig_parts ).
end.
br-op:refresh() in frame d-doc.
varlog = br-op:select-next-row () in frame d-doc.
apply "entry" to br-op in frame d-doc.
end.
end procedure.
procedure local-del:
define output parameter parrep-rec as recid no-undo.
define variable vartemp-rec as recid no-undo.
define buffer bf-del_doc-line   for ub.doc-line.
define buffer bf-del-orig_parts for ub.parts.
do on error undo, return error return-value :
find first tt-del-list no-error.
if not available tt-del-list then do:
  if not available bf_doc-line then do:
    message "Неправильный выбор строки.".
    return error.
  end.
  assign
    varlog = no.
  message "Удалить строку из документа? Вы уверены?"
          view-as alert-box question buttons ok-cancel update varlog.
  if not varlog then return error.
  assign
    vartemp-rec =  recid( bf_doc-line ).
  create tt-del-list.
    assign
    tt-del-list.rec-id = recid( bf_doc-line ).
  get next br.
  if available bf_doc-line then do:
    assign
      parrep-rec = recid( bf_doc-line ).
  end.
  else do:
    reposition br to recid vartemp-rec no-error.
    get prev br.
    assign
      parrep-rec = recid( bf_doc-line ).
  end.
end.
else do:
  assign
    varlog = no.
  message "УДАЛИТЬ ВСЕ ОТМЕЧЕННЫЕ строки документа? Вы уверены ?"
  view-as alert-box question buttons ok-cancel update varlog.
  if not varlog then do:
    return error.
  end.
  assign
    parrep-rec = ?.
end.
for each tt-del-list on error undo, return error return-value :
  find first bf-del_doc-line where recid( bf-del_doc-line ) = tt-del-list.rec-id exclusive-lock no-error.
  if not available bf-del_doc-line then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении линии. Не найдена линия для удаления." skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  run local-recalc in this-procedure ( input "old":U,
                                       input recid( bf-del_doc-line ) ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при пересчете строки документа" skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  run trg/rsrv-del.p ( input bf-del_doc-line.doc-code,
                   input bf-del_doc-line.artic,
                   input bf-del_doc-line.prod-type,
                   input bf-del_doc-line.prod-code ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip "Ошибка при разрезервировании по линии документа" skip
      return-value skip trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  run local-recalc in this-procedure ( input "delete":U,
                                       input recid( bf-del_doc-line ) ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при пересчете строки документа" skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  run local-delete in this-procedure ( input recid( bf-del_doc-line ) ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении строки документа." skip
      "Товар " bf-del_doc-line.artic " " bf-del_doc-line.prod-type " " bf-del_doc-line.prod-code skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
end.
end.
end procedure.
define temp-table tt-doc-line no-undo like ub.doc-line.
procedure local-check-gds:
define input parameter parrec-gds as recid no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_parts for ub.parts.
define variable l-inv-on as logical no-undo .
find first bf_goods where recid( bf_goods ) = parrec-gds no-lock.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  bf_goods.artic
  ,input  bf_goods.prod-type
  ,input  bf_goods.prod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка получения признака товара на объекте" skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  if l-inv-on then do:
    assign
      varlog-err = yes.
    put stream str-err unformatted "Артикул : " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " - товар в инвентаризации. Операция невозможна." skip.
    return error.
  end.
  for each tt-doc-line :
    delete tt-doc-line.
  end.
  create tt-doc-line.
  assign
    tt-doc-line.doc-code  = t-doc.doc-code
    tt-doc-line.obj-type  = t-doc.obj-type
    tt-doc-line.obj-code  = t-doc.obj-code
    tt-doc-line.artic     = bf_goods.artic
    tt-doc-line.prod-type = bf_goods.prod-type
    tt-doc-line.prod-code = bf_goods.prod-code.
  bl-inv-on:
  for
 each bf_parts no-lock
        where
            (     bf_parts.prod-type = tt-doc-line.prod-type
              and bf_parts.prod-code = tt-doc-line.prod-code
              and bf_parts.artic     = tt-doc-line.artic
              and bf_parts.obj-type  = tt-doc-line.obj-type
              and bf_parts.obj-code  = tt-doc-line.obj-code
              and bf_parts.rsrv-free = true
              and bf_parts.status_   = false
              and bf_parts.out-code  <> 'free-zone':U
              and bf_parts.out-code  <> t-doc.doc-code
            )
            or
            (     bf_parts.prod-type = tt-doc-line.prod-type
              and bf_parts.prod-code = tt-doc-line.prod-code
              and bf_parts.artic     = tt-doc-line.artic
              and bf_parts.obj-type  = tt-doc-line.obj-type
              and bf_parts.obj-code  = tt-doc-line.obj-code
              and bf_parts.rsrv-free = false
              and bf_parts.status_   = false
              and bf_parts.out-code  <> 'out-zone':U
              and bf_parts.out-code  <> t-doc.doc-code
            )
  on error undo bl-inv-on, return error :
    assign
      varlog-err = yes.
    put stream str-err unformatted "Включить инвентаризацию нельзя - на товарах есть резервы. Товар " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " Документ " bf_parts.out-code skip.
    undo bl-inv-on, return error.
  end.
end procedure.
procedure chk-upd-date:
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
if input frame d-doc t-doc.fact-date > v-today then do:
   message "Дата больше сегодняшней даты на объекте." view-as alert-box error.
   display t-doc.fact-date with frame d-doc.
   return error.
end.
if input frame d-doc t-doc.fact-date < v-today - 7 then do:
   varlog = yes.
   message "Заведенная факт дата отличается более чем на 7 дней от сегодняшней даты на объекте."
           "Отказаться от заведения даты?" view-as alert-box question
           buttons yes-no update varlog.
   if varlog then do:
      display t-doc.fact-date with frame d-doc.
      return error.
   end.
end.
if input frame d-doc t-doc.fact-date <> t-doc.fact-date then do:
define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .
      delete object v-tth no-error.
      run adm/shattri.p (
           input "get":U
          ,input v-cntxt-obj-type
          ,input v-cntxt-obj-code
          ,input 'nakl_par':U
          ,input  "back-date"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-back-date
          ,output v-back-date-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          if error-status :error  then v-back-date = false .
          delete object v-tth no-error.
    if v-back-date <> true then do:
      message "Запрещено работать задним числом !" view-as alert-box information .
      display t-doc.fact-date with frame d-doc.
      return error.
    end.
   assign varlog = no.
   case t-doc.doc-type
   :
     when 'при':U
     then do:
define variable vss-include-info63 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_income_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
     end.
     when 'рас':U
     then do:
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
     end.
     when 'спи':U
     then do:
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_write-off_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
     end.
     when 'возврат':U
     then do:
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
     end.
     when 'инв':U
     then do:
define variable vss-include-info67 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_inventory_add-back-date':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
     end.
     otherwise do:
       message
         vss-workfile vss-revision vss-description skip
         "Неизвестный тип документа" skip
         "Тип документа" t-doc.doc-type skip
         "Код документа" t-doc.doc-code skip
         view-as alert-box error .
       undo, return error return-value .
     end.
   end case .
   if varlog = no then do:
      display t-doc.fact-date with frame d-doc.
      return error.
   end.
   varlog = no.
   message "Вы хотите изменить фактическую дату?" skip
           "Если дату задать как '?' она при закрытии на факт проставится днем закрытия."
   view-as alert-box question buttons yes-no update varlog.
   if not varlog then do:
      display t-doc.fact-date with frame d-doc.
      return error.
   end.
   assign t-doc.fact-time = (24 * 60 * 60).
end.
end procedure.
procedure mode-on :
define buffer bf_clients for ub.clients.
define buffer bf_store   for ub.store.
define variable varrecid as recid no-undo.
define variable varactive-obj as logical no-undo.
do on error undo, return error :
if pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
   RUN add-doc in this-procedure ( output varrecid ) no-error.
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при добавлении документа." skip
       return-value skip
       trim(error-status :get-message(1))
       view-as alert-box error.
     undo, return error .
   end.
end.
else do:
  find first t-doc where recid(t-doc) = pardoc-rec no-lock.
  if available t-doc then do:
    if pardoc-mode = 'ИЗМЕНЕНИЕ':U then do:
      if t-doc.status_ <> 'накл':U then do:
        message "Документ закрыт." skip (1)
                "Редактирование невозможно."
                view-as alert-box error.
        return error.
      end.
      else do:
        find first bf_clients where bf_clients.obj-type = v-cntxt-obj-type and
                                    bf_clients.obj-code = v-cntxt-obj-code no-lock.
        if v-cntxt-db-num <> bf_clients.db-num then do:
          message
            vss-workfile vss-revision vss-description skip
            "Редактирование документа возможно только на активной стороне." skip
            return-value skip
            trim(error-status :get-message(1))
            view-as alert-box error.
          undo, return error .
        end.
      end.
    end.
  end.
  else do:
    message "Неправильный выбор документа.".
    return error.
  end.
end.
end.
end procedure.
procedure add-doc:
define output parameter parrecid as recid no-undo.
define variable vardoc-code   like ub.trn-doc.doc-code    no-undo.
define variable v-today       as date                     no-undo.
do on error undo, return error :
  if not can-find (pay-type where pay-type.obj-code = v-cntxp-inv-pay no-lock) then do:
    message "Не задан код оплаты для инвентаризации в настройках по текущему объекту.".
    return error.
  end.
  run doc-code in this-procedure
  (input  "main",
   input  v-cntxt-obj-type,
   input  v-cntxt-obj-code,
   input  ?,
   output vardoc-code ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при генерации номера документа." skip
      return-value skip
      trim( error-status :get-message( 1 ) )
      view-as alert-box error.
    undo, return error .
  end.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input 1
,input 1
,input ?
,input ?
,input ?
,input v-cntxt-db-num
,input v-cntxt-userid
,input ' '
,input vardoc-code
,input v-today
,input 'инв':U
,input no
,input v-cntxt-host-code-obj
,input no
,input v-cntxt-obj-code
,input v-cntxt-obj-type
,input no
,input v-cntxp-inv-pay
,input '@  '
,input no
,input 'без':U
,input 'накл':U
,input 'в т. ч.':U
,input 'ap':U
,input ?
) no-error
.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при создании документа процедурой crtrndoc" skip
      return-value skip
      trim(error-status :get-message(1))
      view-as alert-box error.
    undo, return error .
  end.
  find t-doc where t-doc.doc-code = vardoc-code.
  assign
    pardoc-rec = recid( t-doc ).
  assign parrecid = recid( t-doc ).
end.
end procedure.
procedure open-all-browse :
  open query br    for each bf_doc-line where bf_doc-line.doc-code = t-doc.doc-code,      first bf_goods no-lock where bf_goods.artic     = bf_doc-line.artic   and                                 bf_goods.prod-type = bf_doc-line.prod-type and                                 bf_goods.prod-code = bf_doc-line.prod-code ,         first bf-expp_doc-line-sum outer-join where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                        bf-expp_doc-line-sum.gds-code = bf_goods.gds-code    and                                        bf-expp_doc-line-sum.sum-type = 'exp':U ,            first bf-incp_doc-line-sum outer-join where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code and                                          bf-incp_doc-line-sum.gds-code = bf_goods.gds-code    and                                          bf-incp_doc-line-sum.sum-type = 'inp':U.
  if line-rec <> ? then do:
    reposition br to recid line-rec no-error.
  end.
  open query br-op   for each bf-orig_parts where bf-orig_parts.out-code  = t-doc.doc-code        and                                  bf-orig_parts.obj-type  = t-doc.obj-type        and                                  bf-orig_parts.obj-code  = t-doc.obj-code        and                                  bf-orig_parts.artic     = bf_doc-line.artic     and                                  bf-orig_parts.prod-type = bf_doc-line.prod-type and                                  bf-orig_parts.prod-code = bf_doc-line.prod-code and                                  bf-orig_parts.in-code  <> t-doc.doc-code no-lock,       first bf-orig_goods where bf-orig_goods.artic     = bf-orig_parts.artic     and                                      bf-orig_goods.prod-type = bf-orig_parts.prod-type and                                      bf-orig_goods.prod-code = bf-orig_parts.prod-code no-lock.
  open query br-cp   for each bf_parts-root where bf_parts-root.doc-code       = bf-orig_parts.out-code  and                                     bf_parts-root.orig-in-code   = bf-orig_parts.in-code   and                                     bf_parts-root.orig-gds-code  = bf-orig_goods.gds-code  and                                     bf_parts-root.orig-part-code = bf-orig_parts.part-code no-lock,       first bf-caus_parts where bf-caus_parts.out-code  = bf_parts-root.doc-code  and                                 bf-caus_parts.obj-type  = bf-orig_parts.obj-type  and                                 bf-caus_parts.obj-code  = bf-orig_parts.obj-code  and                                 bf-caus_parts.artic     = bf-orig_parts.artic     and                                 bf-caus_parts.prod-type = bf-orig_parts.prod-type and                                 bf-caus_parts.prod-code = bf-orig_parts.prod-code and                                 bf-caus_parts.in-code   = bf_parts-root.in-code   and                                 bf-caus_parts.part-code = bf_parts-root.part-code.
end procedure.
procedure local-add:
define variable varartic   like ub.doc-line.artic no-undo.
define variable recid-line as   recid             no-undo.
define variable varmode    as   character         no-undo.
define variable varhvrdtax as   logical           no-undo.
define variable varlog     as   logical           no-undo.
define variable varis-ok   as   logical           no-undo.
define buffer bf_goods      for ub.goods.
define buffer bf-free_parts for ub.parts.
define buffer bf_contract   for ub.contract.
define variable varnum as integer no-undo.
define variable varstay-lns-cnt as integer no-undo.
define variable varnotes as character no-undo.
define variable varlns-cnt as integer no-undo.
do on error undo, return error return-value :
run str/chs-gds.w
  ( input parparentproc,
    input v-cntxt-obj-type,
    input v-cntxt-obj-code,
    input "":u,
    input t-doc.status_,
    input "Строка накладной № " + t-doc.doc-code,
    input ?,
    input ?,
    input ?,
    input v-cntxt-host-code-obj,
    input parext-doc-type,
    input-output varartic,
    output varnotes
    ) .
if varnotes = '' then do: return error. end.
varlns-cnt = 1.
cycle:
do while varlns-cnt <= num-entries (varnotes) on error undo, return error return-value :
gds:
do transaction on error undo, leave :
  find first bf_goods where recid( bf_goods ) = integer( entry( varlns-cnt, varnotes ) ) no-lock.
  assign
    varlns-cnt = varlns-cnt + 1.
  if hvrdtax ( recid( bf_goods ) ) = no then do:
    assign
      varhvrdtax = no.
  end.
  find first bf_doc-line where bf_doc-line.doc-code  = t-doc.doc-code     and
                               bf_doc-line.artic     = bf_goods.artic     and
                               bf_doc-line.prod-type = bf_goods.prod-type and
                               bf_doc-line.prod-code = bf_goods.prod-code no-error.
  if available bf_doc-line then do:
    message "Товар " bf_doc-line.artic " " bf_doc-line.prod-type " " bf_doc-line.prod-code " " bf_goods.gds-name " уже есть в данной накладной." skip
            "Хотите отредактировать его?" view-as alert-box question buttons yes-no update varlog.
    if not varlog then do:
      undo, leave gds.
    end.
    run gbl/d-askw.w
    (input "Смена цен"
    ,input "Товар " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code) + " " + substring(bf_goods.gds-name,1,30)
    ,input "|^"
    ,input "Все|Новые|Отменить"
    ,input "Всем выбранным партиям из свободной зоны|"
         + "Новым выбранным партиям из свободной зоны|"
         + "Прекратить обработку товаров"
    ,input 1
    ,input 3
    ,output varnum
    ).
    case varnum :
      when 1 then do:
        assign
          varmode = "chg_parts":u.
      end.
      when 2 then do:
        assign
          varmode = "chg_new_parts":u.
      end.
      when 3 then do:
        assign
          varlog-err = yes.
        assign
          varstay-lns-cnt = varlns-cnt.
        do while varstay-lns-cnt <= num-entries (varnotes) on error undo, return error return-value :
          find first bf_goods where recid( bf_goods ) = integer( entry( varlns-cnt, varnotes ) ) no-lock.
          assign
            varstay-lns-cnt = varstay-lns-cnt + 1.
          put stream str-err unformatted "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " ,из списка выбранных, не обрабатывался в связи с нажатием кнопки 'Отмена'." skip.
        end.
        undo gds, leave cycle.
      end.
    end case.
  end.
  else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkgdsd in g#lib-trn3
( input recid(t-doc)
 ,input recid(bf_goods)
) no-error.
    if error-status :error then do:
      assign
        varlog-err = yes.
      put stream str-err unformatted return-value.
      undo, leave gds.
    end.
    find first bf-free_parts where bf-free_parts.host-code     = t-doc.host-code       and
                                   bf-free_parts.supp-type     = t-doc.cli-type        and
                                   bf-free_parts.supp-code     = t-doc.cli-code        and
                                   bf-free_parts.status_       = no                    and
                                   bf-free_parts.obj-type      = t-doc.obj-type        and
                                   bf-free_parts.obj-code      = t-doc.obj-code        and
                                   bf-free_parts.rsrv-free     = yes                   and
                                   bf-free_parts.out-code      = 'free-zone':U          and
                                   bf-free_parts.prod-type     = bf_goods.prod-type    and
                                   bf-free_parts.prod-code     = bf_goods.prod-code    and
                                   bf-free_parts.artic         = bf_goods.artic        and
                                   bf-free_parts.contract-code = t-doc.contract-code   no-lock no-error.
    if not available bf-free_parts then do:
      if t-doc.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = t-doc.host-code     and
                                     bf_contract.contract-code = t-doc.contract-code no-lock.
      end.
      assign
        varlog-err = yes.
      put stream str-err unformatted
              "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name "."
              "Объект: " t-doc.obj-type " " t-doc.obj-code
              "Поставщик " t-doc.cli-type " " t-doc.cli-code " " t-doc.cli-name " "
              (if available bf_contract then "Договор " + bf_contract.contract-prn-code else "")
              "Нет товара от поставщика в свободной зоне на объекте."
              "Пропускаем." skip.
      undo, leave gds.
    end.
    run gbl/d-askw.w
    (input "Смена цен"
    ,input "Товар " + bf_goods.artic + " " + bf_goods.prod-type + " " + string(bf_goods.prod-code) + " " + substring(bf_goods.gds-name,1,30)
    ,input "|^"
    ,input "Все|Выбор|Отменить"
    ,input "Всем партиям свободной зоны по поставщику|"
         + "Выбранным партиям из свободной зоны|"
         + "Прекратить обработку товаров"
    ,input 1
    ,input 3
    ,output varnum
    ).
    case varnum :
      when 1 then do:
        assign
          varmode = "all_parts":u.
      end.
      when 2 then do:
        assign
          varmode = "chg_parts":u.
      end.
      when 3 then do:
        assign
          varlog-err = yes.
        assign
          varstay-lns-cnt = varlns-cnt.
        do while varstay-lns-cnt <= num-entries (varnotes) on error undo, return error return-value :
          find first bf_goods where recid( bf_goods ) = integer( entry( varlns-cnt, varnotes ) ) no-lock.
          assign
            varstay-lns-cnt = varstay-lns-cnt + 1.
          put stream str-err unformatted "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name " ,из списка выбранных, не обрабатывался в связи с нажатием кнопки 'Отмена'." skip.
        end.
        undo gds, leave cycle.
      end.
    end case.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_addcorln in g#lib-trn3
( input  recid(t-doc)
 ,input  recid(bf_goods)
 ,output recid-line
) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при добавлении товара " skip
        bf_goods.artic skip
        bf_goods.prod-type skip
        bf_goods.prod-code skip
        " в документ."
        return-value skip
        trim( error-status :get-message( 1 ) )
        view-as alert-box error.
      undo, leave gds.
    end.
    find first bf_doc-line where recid( bf_doc-line ) = recid-line.
  end.
  assign
    bf_doc-line.prt-OK = ?.
  run local-recalc in this-procedure ( input "old":U,
                                       input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при пересчете строки документа" skip
    return-value skip
    trim(error-status :get-message(1))
    view-as alert-box error.
    undo, leave gds.
  end.
  find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
  run update-line in this-procedure (   input varmode
                                      , input recid( bf_doc-line )
                                      , input bf_sysconf.cash-pay
                                      , input ?
                                      , input ?
                                      , input ?
                                      , input ?
                                      )  no-error.
  if error-status :error then do:
    if return-value <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке товара " skip
        bf_doc-line.artic skip
        bf_doc-line.prod-type skip
        bf_doc-line.prod-code skip
        return-value skip
        trim(error-status :get-message(1))
        view-as alert-box error.
    end.
    undo, leave gds.
  end.
  if available bf_doc-line then do:
    run local-recalc in this-procedure ( input "update":U,
                                         input recid( bf_doc-line ) ) no-error.
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при пересчете строки документа" skip
      return-value skip
      trim( error-status :get-message( 1 ) )
      view-as alert-box error.
      undo, leave gds.
    end.
  end.
end.
end.
run ui-on in this-procedure ( input "line" ).
end.
end procedure.
procedure add-doc-inv-line:
define input parameter parrec-goods as recid no-undo.
define output parameter parrecid as recid no-undo.
define variable v-vat-pc        like ub.doc-line.vat-pc      no-undo.
define variable v-slt-pc        like ub.doc-line.slt-pc      no-undo.
define variable v-have-slt-pc   as logical                no-undo.
define variable v-host-code     like ub.sysconf.host-code    no-undo.
define variable varn-c          like ub.gds-prt.node-code no-undo.
define variable l-inv-on        as logical                no-undo.
define buffer bf_goods    for ub.goods.
define buffer bf_doc-line for ub.doc-line.
do on error undo, return error return-value :
find first bf_goods where recid( bf_goods ) = parrec-goods no-lock.
if bf_goods.gds-type = 'у':U then do:
  message
    vss-workfile vss-revision vss-description skip
    "Услуги нельзя добавлять в данный документ" skip
    return-value skip
    trim( error-status :get-message( 1 ) )
    view-as alert-box error.
  undo, return error .
end.
find bf_doc-line where bf_doc-line.artic     = bf_goods.artic
                   and bf_doc-line.prod-type = bf_goods.prod-type
                   and bf_doc-line.prod-code = bf_goods.prod-code
                   and bf_doc-line.doc-code  = t-doc.doc-code no-error.
if not available bf_doc-line then do:
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-vat-pc
  ) no-error .
  find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(bf_goods)
,input  recid(t-doc)
,input  bf_sysconf.cash-pay
,output v-slt-pc
)
.
  define variable v-cons-vat-pc like ub.sysconf.cons-vat-pc no-undo.
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcvat in g#library
  (input  t-doc.host-code
  ,output v-cons-vat-pc
  )  .
  if v-vat-pc = ? then do:
   return error substitute ("Не установлен консигнационный НДС по фирме &1.", t-doc.host-code).
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclin in g#lib-trn
(input t-doc.doc-code
,input bf_goods.artic
,input bf_goods.prod-type
,input bf_goods.prod-code
,input t-doc.obj-type
,input t-doc.obj-code
,input t-doc.status_
,input t-doc.ext-doc-type
,input bf_goods.prt-root
,input v-vat-pc
,input v-slt-pc
,input v-cons-vat-pc
)
.
  find first bf_doc-line where bf_doc-line.doc-code  = t-doc.doc-code     and
                               bf_doc-line.artic     = bf_goods.artic     and
                               bf_doc-line.prod-type = bf_goods.prod-type and
                               bf_doc-line.prod-code = bf_goods.prod-code exclusive-lock.
  assign
    bf_doc-line.price-base     = 0
    bf_doc-line.price-rubl     = 0
    bf_doc-line.road-tax       = 0
    bf_doc-line.transport-base = 0
    bf_doc-line.transport-rubl = 0
    bf_doc-line.other-base     = 0
    bf_doc-line.other-rubl     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  bf_goods.prt-root
  ,output varn-c
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input t-doc.obj-code
   ,input t-doc.obj-type
   ,input t-doc.doc-code
   ,input bf_goods.artic
   ,input bf_goods.prod-code
   ,input bf_goods.prod-type
   ,input varn-c
   ,input yes
  ) no-error .
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка при создании терминального признака по товару:" skip
       bf_goods.artic skip
       bf_goods.prod-type skip
       bf_goods.prod-code skip
       return-value skip
       trim(error-status :get-message(1))
       view-as alert-box error.
     undo, return error .
   end.
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  bf_doc-line.obj-type
  ,input  bf_doc-line.obj-code
  ,input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,input  'inv-on=true'
  ,output l-inv-on
  ) no-error .
   if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       "Ошибка установки атрибута товара на объекте" skip
       "Документ" bf_doc-line.doc-code skip
       "Объект" bf_doc-line.obj-type bf_doc-line.obj-code skip
       "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
       "l-new-inv-on" l-inv-on skip
       view-as alert-box error .
     undo, return error .
   end.
end.
assign parrecid = recid( bf_doc-line ).
end.
end procedure.
procedure update-line :
define input parameter parmode         as   character          no-undo.
define input parameter parrec-line     as   recid              no-undo.
define input parameter parcash-pay     as   integer            no-undo.
define input parameter paroldvat-pc    like ub.doc-line.vat-pc no-undo.
define input parameter parvat-pc       like ub.doc-line.vat-pc no-undo.
define input parameter parpurch-list   as   character          no-undo.
define input parameter parchange-price as   logical            no-undo.
define buffer bf_doc-line    for ub.doc-line.
define buffer bf_gds-dtl     for ub.gds-dtl.
define buffer bf_goods       for ub.goods.
define buffer bf_parts       for ub.parts.
define buffer bf-free_parts  for ub.parts.
define buffer bf-orig_parts  for ub.parts.
define buffer bf-caus_parts  for ub.parts.
define buffer bf_parts_root  for ub.parts-root.
define buffer bf2_parts-root for ub.parts-root.
define buffer bf-hv_parts    for ub.parts.
define buffer bf_contract    for ub.contract.
define variable parreccaus-parts     as   recid                  no-undo.
define variable varn-c               like ub.gds-prt.node-code   no-undo.
define variable varfree-qnty         like ub.parts.fact-qnty     no-undo.
define variable vartext              as   character              no-undo.
define variable varis-rsrv           as   logical                no-undo.
define variable l-goods-twounit      as   logical                no-undo.
define variable vargds-dtlrec        as   recid                  no-undo.
define variable varhvrdtax           as   logical                no-undo.
define variable varis-ok             as   logical                no-undo.
define variable varprc-chg-upd-parts as   logical                no-undo.
define variable varno-abs-tax-rubl   like ub.doc-line.price-rubl no-undo.
define variable varslt-rubl          like ub.doc-line.price-rubl no-undo.
define variable varvat-rubl          like ub.doc-line.price-rubl no-undo.
define variable varno-tax-rubl       like ub.doc-line.price-rubl no-undo.
define variable varexch-code         like ub.trn-doc.exch-code   no-undo.
define variable varexch-rate         like ub.trn-doc.exch-rate   no-undo.
define variable varexch-scale        like ub.trn-doc.exch-scale  no-undo.
define variable prt-rec as recid no-undo.
do transaction on error undo, return error return-value :
find first bf_doc-line where recid( bf_doc-line ) = parrec-line.
find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                          bf_goods.prod-type = bf_doc-line.prod-type and
                          bf_goods.prod-code = bf_doc-line.prod-code no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  bf_goods.prt-root
  ,output varn-c
  )  .
assign
  varhvrdtax = hvrdtax ( recid( bf_goods ) ).
find first bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                            bf_gds-dtl.artic     = bf_doc-line.artic     and
                            bf_gds-dtl.prod-code = bf_doc-line.prod-code and
                            bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                            bf_gds-dtl.prt-code  = varn-c .
assign
  vargds-dtlrec = recid( bf_gds-dtl ).
for each tt-cur-parts on error undo, return error return-value :
  delete tt-cur-parts.
end.
for each tt-new-parts on error undo, return error return-value :
  delete tt-new-parts.
end.
for each bf_parts where bf_parts.out-code  =  t-doc.doc-code
                    and bf_parts.obj-type  =  t-doc.obj-type
                    and bf_parts.obj-code  =  t-doc.obj-code
                    and bf_parts.artic     =  bf_doc-line.artic
                    and bf_parts.prod-type =  bf_doc-line.prod-type
                    and bf_parts.prod-code =  bf_doc-line.prod-code
                    and bf_parts.in-code   <> t-doc.doc-code on error undo, return error return-value :
  create tt-cur-parts.
  buffer-copy bf_parts to tt-cur-parts.
end.
case parmode:
 when "chg_parts":u     or
 when "chg_new_parts":u then do:
   run str/parts-l.w
     (input parparentproc
     ,input t-doc.obj-type
     ,input t-doc.obj-code
     ,input bf_goods.gds-code
     ,input bf_doc-line.doc-code
     ,input 'ИЗМЕНЕНИЕ':U
     ,input 'документ':U
        + chr(44) + 'без-резервирования':U
        + chr(44) + 'no-diff-check':U
     ,input 'текущий':U
     ,input 'документ':U
     ,output prt-rec
     ) .
    for each tt-chs-parts on error undo, return error return-value :
      delete tt-chs-parts.
    end.
    doc-parts:
    for each bf_parts where bf_parts.out-code  =  t-doc.doc-code
                        and bf_parts.obj-type  =  t-doc.obj-type
                        and bf_parts.obj-code  =  t-doc.obj-code
                        and bf_parts.artic     =  bf_doc-line.artic
                        and bf_parts.prod-type =  bf_doc-line.prod-type
                        and bf_parts.prod-code =  bf_doc-line.prod-code
                        and bf_parts.in-code  <>  t-doc.doc-code         on error undo, return error return-value :
      if parmode = "chg_new_parts":u then do:
        find first tt-cur-parts where tt-cur-parts.obj-type  = bf_parts.obj-type  and
                                      tt-cur-parts.obj-code  = bf_parts.obj-code  and
                                      tt-cur-parts.artic     = bf_parts.artic     and
                                      tt-cur-parts.prod-type = bf_parts.prod-type and
                                      tt-cur-parts.prod-code = bf_parts.prod-code and
                                      tt-cur-parts.in-code   = bf_parts.in-code   and
                                      tt-cur-parts.out-code  = bf_parts.out-code  and
                                      tt-cur-parts.part-code = bf_parts.part-code no-error.
        if available tt-cur-parts                       and
           tt-cur-parts.fact-qnty <= bf_parts.fact-qnty then do:
          next doc-parts.
        end.
        create tt-chs-parts.
        buffer-copy bf_parts to tt-chs-parts.
        if available tt-cur-parts then do:
          assign
            tt-chs-parts.fact-qnty = - (bf_parts.fact-qnty - tt-cur-parts.fact-qnty).
        end.
        else do:
          assign
            tt-chs-parts.fact-qnty = - tt-chs-parts.fact-qnty.
        end.
      end.
      else do:
        create tt-chs-parts.
        buffer-copy bf_parts to tt-chs-parts.
        assign
          tt-chs-parts.fact-qnty = - tt-chs-parts.fact-qnty.
      end.
    end.
    find first tt-chs-parts no-error.
    if available tt-chs-parts then do:
      run st-exch-rate in this-procedure (output varexch-code,
                                          output varexch-rate,
                                          output varexch-scale,
                                          output varcli-base-rate,
                                          output varvat-type,
                                          output varslt-type).
      run str/pr-prt.w (
      input  "parts":u,
      input  bf_goods.gds-code,
      input  t-doc.cli-type,
      input  t-doc.cli-code,
      input  t-doc.obj-type,
      input  t-doc.obj-code,
      input  ?,
      input  ?,
      input  ?,
      input  t-doc.base-rate,
      input  t-doc.base-scale,
      input  varexch-code,
      input  varexch-rate,
      input  varexch-scale,
      input  ?,
      input  varhvrdtax,
      input  t-doc.contract-code,
      input  table tt-chs-parts,
      output varprice-base,
      output varsum-base,
      output varprice-rubl,
      output varsum-rubl,
      input-output varcli-base-rate,
      input-output varvat-type,
      input-output varslt-type,
      output varprice-cli,
      output varsum-cli,
      output varvat-pc,
      output varvat-base,
      output varsum-vat-base,
      output varvat-rubl,
      output varsum-vat-rubl,
      output varvat-cli,
      output varsum-vat-cli,
      output varslt-pc,
      output varslt-base,
      output varsum-slt-base,
      output varslt-rubl,
      output varsum-slt-rubl,
      output varslt-cli,
      output varsum-slt-cli,
      output varroad-tax-base,
      output varsum-road-tax-base,
      output varroad-tax-rubl,
      output varsum-road-tax-rubl,
      output varroad-tax-cli,
      output varsum-road-tax-cli,
      output vartransport-base,
      output varsum-transport-base,
      output vartransport-rubl,
      output varsum-transport-rubl,
      output varother-base,
      output varsum-other-base,
      output varother-rubl,
      output varsum-other-rubl,
      output varpurch-code,
      output varis-ok) no-error.
      if error-status :error then do:
        message
        "Ошибка при установке цен." skip
        return-value skip
        error-status :get-message( 1 )
        view-as alert-box error.
        undo, return error .
      end.
      if varis-ok <> yes then do:
        undo, return error .
      end.
      assign
        varprc-chg-upd-parts = yes.
    end.
 end.
 when "all_parts":u or
 when "chg_vat":u   then do:
     for each tt-chs-parts on error undo, return error return-value :
     delete tt-chs-parts.
   end.
   fp: for each bf-free_parts where bf-free_parts.host-code     = t-doc.host-code          and                                                               bf-free_parts.supp-type     = t-doc.cli-type           and                                                               bf-free_parts.supp-code     = t-doc.cli-code           and                                                               bf-free_parts.status_       = no                       and                                                               bf-free_parts.obj-type      = t-doc.obj-type           and                                                               bf-free_parts.obj-code      = t-doc.obj-code           and                                                               bf-free_parts.rsrv-free     = yes                      and                                                               bf-free_parts.out-code      = 'free-zone':U             and                                                               bf-free_parts.prod-type     = bf_doc-line.prod-type    and                                                               bf-free_parts.prod-code     = bf_doc-line.prod-code    and                                                               bf-free_parts.artic         = bf_doc-line.artic        and                                                               bf-free_parts.contract-code = t-doc.contract-code      on error undo, return error return-value :
     if parmode = "chg_vat":u then do:
       if lookup (string(bf-free_parts.purch-code), parpurch-list) = 0 then do:
         next fp.
       end.
       if bf-free_parts.vat-pc <> paroldvat-pc then do:
         next fp.
       end.
     end.
     create tt-chs-parts.
     buffer-copy bf-free_parts to tt-chs-parts.
   end.
   find first tt-chs-parts no-error.
   if available tt-chs-parts then do:
     run st-exch-rate in this-procedure
         (output varexch-code,
          output varexch-rate,
          output varexch-scale,
          output varcli-base-rate,
          output varvat-type,
          output varslt-type).
   end.
   if parmode <> "chg_vat":u then do:
     run str/pr-prt.w (
       input  "goods":u,
       input  bf_goods.gds-code,
       input  t-doc.cli-type,
       input  t-doc.cli-code,
       input  t-doc.obj-type,
       input  t-doc.obj-code,
       input  ?,
       input  ?,
       input  ?,
       input  t-doc.base-rate,
       input  t-doc.base-scale,
       input  varexch-code,
       input  varexch-rate,
       input  varexch-scale,
       input  ?,
       input  varhvrdtax,
       input  t-doc.contract-code,
       input  table tt-chs-parts,
       output varprice-base,
       output varsum-base,
       output varprice-rubl,
       output varsum-rubl,
       input-output varcli-base-rate,
       input-output varvat-type,
       input-output varslt-type,
       output varprice-cli,
       output varsum-cli,
       output varvat-pc,
       output varvat-base,
       output varsum-vat-base,
       output varvat-rubl,
       output varsum-vat-rubl,
       output varvat-cli,
       output varsum-vat-cli,
       output varslt-pc,
       output varslt-base,
       output varsum-slt-base,
       output varslt-rubl,
       output varsum-slt-rubl,
       output varslt-cli,
       output varsum-slt-cli,
       output varroad-tax-base,
       output varsum-road-tax-base,
       output varroad-tax-rubl,
       output varsum-road-tax-rubl,
       output varroad-tax-cli,
       output varsum-road-tax-cli,
       output vartransport-base,
       output varsum-transport-base,
       output vartransport-rubl,
       output varsum-transport-rubl,
       output varother-base,
       output varsum-other-base,
       output varother-rubl,
       output varsum-other-rubl,
       output varpurch-code,
       output varis-ok) no-error.
     if error-status :error then do:
       message
         "Ошибка при установке цен." skip
         return-value skip
         error-status :get-message( 1 )
         view-as alert-box error.
       undo, return error return-value.
     end.
     if varis-ok <> yes then do:
       undo, return error return-value.
     end.
   end.
   assign
     varfree-qnty = 0.
   fp: for each bf-free_parts where bf-free_parts.host-code     = t-doc.host-code          and                                                               bf-free_parts.supp-type     = t-doc.cli-type           and                                                               bf-free_parts.supp-code     = t-doc.cli-code           and                                                               bf-free_parts.status_       = no                       and                                                               bf-free_parts.obj-type      = t-doc.obj-type           and                                                               bf-free_parts.obj-code      = t-doc.obj-code           and                                                               bf-free_parts.rsrv-free     = yes                      and                                                               bf-free_parts.out-code      = 'free-zone':U             and                                                               bf-free_parts.prod-type     = bf_doc-line.prod-type    and                                                               bf-free_parts.prod-code     = bf_doc-line.prod-code    and                                                               bf-free_parts.artic         = bf_doc-line.artic        and                                                               bf-free_parts.contract-code = t-doc.contract-code      on error undo, return error return-value :
     if parmode = "chg_vat":u then do:
       if lookup (string(bf-free_parts.purch-code), parpurch-list) = 0 then do:
         next fp.
       end.
       if bf-free_parts.vat-pc <> paroldvat-pc then do:
         next fp.
       end.
     end.
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,input  'twounit=request':u
  ,output l-goods-twounit
  ) no-error .
     assign
       varfree-qnty = - bf-free_parts.fact-qnty.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run part-prc in g#library
  (buffer bf-free_parts
  ,buffer t-doc
  ,input  yes
  ,input  bf-free_parts.in-code
  ,input  bf-free_parts.part-code
  ,input  0
  ,input  l-goods-twounit
  ,input  '':u
  ,input  varfree-qnty
  ,input  true
  ,output vartext
  ,output varis-rsrv
  ) no-error .
     if error-status :error then do:
       message
         vss-workfile vss-revision vss-description skip
         "Ошибка при проверке возможности резервирования партии" skip
         return-value skip
         trim(error-status :get-message(1))
         view-as alert-box error.
       undo, return error .
     end.
     if varis-rsrv <> yes then next.
     run trg/rsrv-dtl.p ( parparentproc,
                      'reserv':U
                + "," + 'rsrv-single-part':U
                + "," + 'rsrv-in-code':U   + "=" + str-encode(bf-free_parts.in-code, "", ",=":u)
                + "," + 'rsrv-part-code':U + "=" + str-encode(bf-free_parts.part-code, "", ",=":u)
                 , buffer bf_gds-dtl, input-output varfree-qnty,
                 input-output bf_doc-line.price-base, input-output bf_doc-line.price-rubl,-1, "") no-error.
     if error-status :error then do:
       message
         "Ошибка при резервировании свободной зоны." skip
         return-value skip
         trim(error-status :get-message(1))
         view-as alert-box error.
       undo, return error .
     end.
   end.
 end.
 otherwise do:
   message
     vss-workfile vss-revision vss-description skip
     "Неверный режим " parmode " вызова процедуры local-update в файле corparts.w." skip
    view-as alert-box error.
   undo, return error .
 end.
end.
for each bf_parts where bf_parts.out-code      =  t-doc.doc-code
                    and bf_parts.obj-type      =  t-doc.obj-type
                    and bf_parts.obj-code      =  t-doc.obj-code
                    and bf_parts.artic         =  bf_doc-line.artic
                    and bf_parts.prod-type     =  bf_doc-line.prod-type
                    and bf_parts.prod-code     =  bf_doc-line.prod-code
                    and bf_parts.contract-code =  t-doc.contract-code
                    and bf_parts.in-code       <> t-doc.doc-code
                    on error undo, return error return-value :
  create tt-new-parts.
  buffer-copy bf_parts to tt-new-parts.
end.
for each tt-new-parts on error undo, return error return-value :
  find first bf-orig_parts where bf-orig_parts.obj-type   = tt-new-parts.obj-type
                             and bf-orig_parts.obj-code   = tt-new-parts.obj-code
                             and bf-orig_parts.artic      = tt-new-parts.artic
                             and bf-orig_parts.prod-type  = tt-new-parts.prod-type
                             and bf-orig_parts.prod-code  = tt-new-parts.prod-code
                             and bf-orig_parts.in-code    = tt-new-parts.in-code
                             and bf-orig_parts.out-code   = tt-new-parts.out-code
                             and bf-orig_parts.part-code  = tt-new-parts.part-code .
  find first tt-cur-parts where tt-cur-parts.obj-type   = tt-new-parts.obj-type
                            and tt-cur-parts.obj-code   = tt-new-parts.obj-code
                            and tt-cur-parts.artic      = tt-new-parts.artic
                            and tt-cur-parts.prod-type  = tt-new-parts.prod-type
                            and tt-cur-parts.prod-code  = tt-new-parts.prod-code
                            and tt-cur-parts.in-code    = tt-new-parts.in-code
                            and tt-cur-parts.out-code   = tt-new-parts.out-code
                            and tt-cur-parts.part-code  = tt-new-parts.part-code no-error.
  if not available tt-cur-parts then do:
    if parmode = "chg_vat":u then do:
      if parchange-price = yes then do:                  assign                                             varno-abs-tax-rubl = (bf-orig_parts.price-rubl - bf-orig_parts.road-tax-rubl - bf-orig_parts.other-rubl - bf-orig_parts.transport-rubl)                    varslt-rubl        = varno-abs-tax-rubl * bf-orig_parts.slt-pc / (100 + bf-orig_parts.slt-pc)                                varvat-rubl        = (varno-abs-tax-rubl - varslt-rubl) * bf-orig_parts.vat-pc / (100 + bf-orig_parts.vat-pc)                    varno-tax-rubl     = varno-abs-tax-rubl - varslt-rubl - varvat-rubl                  .                  assign                    varprice-rubl      = varno-tax-rubl +                                         varno-tax-rubl * parvat-pc / 100 +                                         (varno-tax-rubl + varno-tax-rubl * parvat-pc / 100) * bf-orig_parts.slt-pc / 100 +                                         bf-orig_parts.road-tax-rubl +                                         bf-orig_parts.transport-rubl +                                         bf-orig_parts.other-rubl                    varprice-base      = varprice-rubl * bf-orig_parts.price-base / bf-orig_parts.price-rubl                    varprice-cli       = varprice-rubl * bf-orig_parts.price-cli  / bf-orig_parts.price-cli.                end.                else do:                  assign                    varprice-base     = bf-orig_parts.price-base                    varprice-rubl     = bf-orig_parts.price-rubl                    varprice-cli      = bf-orig_parts.price-cli                   .                end.                assign                  varvat-pc         = parvat-pc                  varslt-pc         = bf-orig_parts.slt-pc                  varroad-tax-base  = bf-orig_parts.road-tax-base                   varroad-tax-rubl  = bf-orig_parts.road-tax-rubl                   vartransport-base = bf-orig_parts.transport-base                  vartransport-rubl = bf-orig_parts.transport-rubl                  varother-base     = bf-orig_parts.other-base                     varother-rubl     = bf-orig_parts.other-rubl                  .
    end.
    run change-price in this-procedure (
        buffer bf-orig_parts,
        input  - tt-new-parts.fact-qnty,
        input  varexch-code,
        input  varcli-base-rate,
        input  varvat-type,
        input  varslt-type,
        input  varprice-cli,
        input  varprice-base,
        input  varprice-rubl,
        input  varvat-pc,
        input  varslt-pc,
        input  varroad-tax-base,
        input  varroad-tax-rubl,
        input  vartransport-base,
        input  vartransport-rubl,
        input  varother-base,
        input  varother-rubl,
        input  parcash-pay,
        input  t-doc.internal,
        input  t-doc.doc-type,
        input  parext-doc-type,
        input  yes,
        input  ?,
        input  varpurch-code,
        output parreccaus-parts ) no-error.
     if error-status :error then do:
       message
         "Ошибка при вызове процедуры копирования партии с кодом " bf-orig_parts.part-code skip
         "порожденную документом " bf-orig_parts.in-code skip
         "по товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
         return-value skip
         view-as alert-box error.
       undo, return error .
     end.
  end.
  else do:
    if tt-new-parts.fact-qnty <> tt-cur-parts.fact-qnty then do:
      if tt-new-parts.fact-qnty < tt-cur-parts.fact-qnty then do:
        if parmode = "chg_vat":u then do:
          if parchange-price = yes then do:                  assign                                             varno-abs-tax-rubl = (bf-orig_parts.price-rubl - bf-orig_parts.road-tax-rubl - bf-orig_parts.other-rubl - bf-orig_parts.transport-rubl)                    varslt-rubl        = varno-abs-tax-rubl * bf-orig_parts.slt-pc / (100 + bf-orig_parts.slt-pc)                                varvat-rubl        = (varno-abs-tax-rubl - varslt-rubl) * bf-orig_parts.vat-pc / (100 + bf-orig_parts.vat-pc)                    varno-tax-rubl     = varno-abs-tax-rubl - varslt-rubl - varvat-rubl                  .                  assign                    varprice-rubl      = varno-tax-rubl +                                         varno-tax-rubl * parvat-pc / 100 +                                         (varno-tax-rubl + varno-tax-rubl * parvat-pc / 100) * bf-orig_parts.slt-pc / 100 +                                         bf-orig_parts.road-tax-rubl +                                         bf-orig_parts.transport-rubl +                                         bf-orig_parts.other-rubl                    varprice-base      = varprice-rubl * bf-orig_parts.price-base / bf-orig_parts.price-rubl                    varprice-cli       = varprice-rubl * bf-orig_parts.price-cli  / bf-orig_parts.price-cli.                end.                else do:                  assign                    varprice-base     = bf-orig_parts.price-base                    varprice-rubl     = bf-orig_parts.price-rubl                    varprice-cli      = bf-orig_parts.price-cli                   .                end.                assign                  varvat-pc         = parvat-pc                  varslt-pc         = bf-orig_parts.slt-pc                  varroad-tax-base  = bf-orig_parts.road-tax-base                   varroad-tax-rubl  = bf-orig_parts.road-tax-rubl                   vartransport-base = bf-orig_parts.transport-base                  vartransport-rubl = bf-orig_parts.transport-rubl                  varother-base     = bf-orig_parts.other-base                     varother-rubl     = bf-orig_parts.other-rubl                  .
        end.
        run change-price in this-procedure (
            buffer bf-orig_parts,
            input tt-cur-parts.fact-qnty - tt-new-parts.fact-qnty,
            input varexch-code,
            input varcli-base-rate,
            input varvat-type,
            input varslt-type,
            input varprice-cli,
            input varprice-base,
            input varprice-rubl,
            input varvat-pc,
            input varslt-pc,
            input varroad-tax-base,
            input varroad-tax-rubl,
            input vartransport-base,
            input vartransport-rubl,
            input varother-base,
            input varother-rubl,
            input parcash-pay,
            input t-doc.internal,
            input t-doc.doc-type,
            input parext-doc-type,
            input yes,
            input ?,
            input varpurch-code,
            output parreccaus-parts ) no-error.
        if error-status :error then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры копирования партии с кодом " bf-orig_parts.part-code skip
            "порожденную документом " bf-orig_parts.in-code skip
            "по товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
            return-value skip
            trim(error-status :get-message(1))
            view-as alert-box error.
          undo, return error .
        end.
      end.
      else do:
        find first bf_parts-root where bf_parts-root.doc-code       = bf-orig_parts.out-code
                                   and bf_parts-root.orig-in-code   = bf-orig_parts.in-code
                                   and bf_parts-root.orig-gds-code  = bf_goods.gds-code
                                   and bf_parts-root.orig-part-code = bf-orig_parts.part-code.
        find first bf2_parts-root where bf2_parts-root.doc-code       = bf-orig_parts.out-code
                                    and bf2_parts-root.orig-in-code   = bf-orig_parts.in-code
                                    and bf2_parts-root.orig-gds-code  = bf_goods.gds-code
                                    and bf2_parts-root.orig-part-code = bf-orig_parts.part-code
                                    and recid( bf2_parts-root ) <> recid( bf_parts-root ) no-error.
        if available bf2_parts-root then do:
          message
            "Вы уменьшили количество c " tt-cur-parts.fact-qnty " на " tt-new-parts.fact-qnty " по партии с кодом " bf-orig_parts.part-code skip
            "порожденную документом " bf-orig_parts.in-code skip
            "по товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
            "Для нее существует несколько порожденных партий." skip
            "Уменьшение количества недопустимо. Удалите эту партию из документа, а затем создайте с нужным количеством." skip
          view-as alert-box.
          undo, return error .
        end.
        else do:
          find first bf-caus_parts where bf-caus_parts.obj-type   = bf_doc-line.obj-type
                                     and bf-caus_parts.obj-code   = bf_doc-line.obj-code
                                     and bf-caus_parts.artic      = bf_doc-line.artic
                                     and bf-caus_parts.prod-type  = bf_doc-line.prod-type
                                     and bf-caus_parts.prod-code  = bf_doc-line.prod-code
                                     and bf-caus_parts.in-code    = bf_doc-line.doc-code
                                     and bf-caus_parts.out-code   = bf_doc-line.doc-code
                                     and bf-caus_parts.part-code  = bf_parts-root.part-code.
          assign bf-caus_parts.qnty      = - tt-new-parts.fact-qnty
                 bf-caus_parts.fact-qnty = - tt-new-parts.fact-qnty.
        end.
      end.
    end.
    if varprc-chg-upd-parts then do:
      if parmode = "chg_parts":u then do:
        for each bf_parts-root where bf_parts-root.doc-code       = bf-orig_parts.out-code
                                 and bf_parts-root.orig-in-code   = bf-orig_parts.in-code
                                 and bf_parts-root.orig-gds-code  = bf_goods.gds-code
                                 and bf_parts-root.orig-part-code = bf-orig_parts.part-code on error undo, return error return-value :
          find first bf-caus_parts where bf-caus_parts.obj-type   = bf_doc-line.obj-type
                                     and bf-caus_parts.obj-code   = bf_doc-line.obj-code
                                     and bf-caus_parts.artic      = bf_doc-line.artic
                                     and bf-caus_parts.prod-type  = bf_doc-line.prod-type
                                     and bf-caus_parts.prod-code  = bf_doc-line.prod-code
                                     and bf-caus_parts.in-code    = bf_doc-line.doc-code
                                     and bf-caus_parts.out-code   = bf_doc-line.doc-code
                                     and bf-caus_parts.part-code  = bf_parts-root.part-code.
          run change-price in this-procedure (
            buffer bf-orig_parts,
            input  0,
            input  varexch-code,
            input  varcli-base-rate,
            input  varvat-type,
            input  varslt-type,
            input  varprice-cli,
            input  varprice-base,
            input  varprice-rubl,
            input  varvat-pc,
            input  varslt-pc,
            input  varroad-tax-base,
            input  varroad-tax-rubl,
            input  vartransport-base,
            input  vartransport-rubl,
            input  varother-base,
            input  varother-rubl,
            input  parcash-pay,
            input  t-doc.internal,
            input  t-doc.doc-type,
            input  parext-doc-type,
            input  no,
            input  recid( bf-caus_parts ),
            input  varpurch-code,
            output parreccaus-parts ) no-error.
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при смене цены в партии " bf-caus_parts.part-code skip
              "порожденную документом " bf-caus_parts.in-code skip
              "по товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code skip
              return-value skip
             trim(error-status :get-message(1))
             view-as alert-box error.
            undo, return error .
          end.
        end.
      end.
    end.
  end.
end.
for each tt-cur-parts on error undo, return error return-value :
  find first tt-new-parts where tt-new-parts.obj-type  = tt-cur-parts.obj-type
                            and tt-new-parts.obj-code  = tt-cur-parts.obj-code
                            and tt-new-parts.artic     = tt-cur-parts.artic
                            and tt-new-parts.prod-type = tt-cur-parts.prod-type
                            and tt-new-parts.prod-code = tt-cur-parts.prod-code
                            and tt-new-parts.in-code   = tt-cur-parts.in-code
                            and tt-new-parts.out-code  = tt-cur-parts.out-code
                            and tt-new-parts.part-code = tt-cur-parts.part-code  no-error.
  if not available tt-new-parts then do:
    for each bf_parts-root where bf_parts-root.doc-code       = tt-cur-parts.out-code
                             and bf_parts-root.orig-in-code   = tt-cur-parts.in-code
                             and bf_parts-root.orig-gds-code  = bf_goods.gds-code
                             and bf_parts-root.orig-part-code = tt-cur-parts.part-code on error undo, return error return-value :
      find first bf-caus_parts where bf-caus_parts.obj-type   = bf_doc-line.obj-type
                                 and bf-caus_parts.obj-code   = bf_doc-line.obj-code
                                 and bf-caus_parts.artic      = bf_doc-line.artic
                                 and bf-caus_parts.prod-type  = bf_doc-line.prod-type
                                 and bf-caus_parts.prod-code  = bf_doc-line.prod-code
                                 and bf-caus_parts.in-code    = bf_doc-line.doc-code
                                 and bf-caus_parts.out-code   = bf_doc-line.doc-code
                                 and bf-caus_parts.part-code  = bf_parts-root.part-code.
      delete bf-caus_parts.
      delete bf_parts-root.
    end.
  end.
end.
find first bf-hv_parts where bf-hv_parts.out-code  = bf_doc-line.doc-code  and
                             bf-hv_parts.obj-type  = t-doc.obj-type        and
                             bf-hv_parts.obj-code  = t-doc.obj-code        and
                             bf-hv_parts.artic     = bf_doc-line.artic     and
                             bf-hv_parts.prod-type = bf_doc-line.prod-type and
                             bf-hv_parts.prod-code = bf_doc-line.prod-code no-error.
if not available bf-hv_parts then do:
  run local-recalc in this-procedure ( input "delete":U,
                                       input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при пересчете строки документа" skip
      return-value skip
      trim( error-status :get-message( 1 ) )
      view-as alert-box error.
    undo, return error .
  end.
  run local-delete in this-procedure ( input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    undo, return error return-value.
  end.
  if available bf_gds-dtl then do:
    delete bf_gds-dtl.
  end.
end.
if available bf_doc-line then do:
  run check-line in this-procedure ( input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    message "Ошибка при проверке линии товара " bf_doc-line.artic " " bf_doc-line.prod-type " " bf_doc-line.prod-code " ." skip
            return-value skip
            error-status :get-message( 1 )
    view-as alert-box error.
    undo, return error.
  end.
  find first bf_gds-dtl where recid( bf_gds-dtl ) = vargds-dtlrec.
  assign
    bf_doc-line.price-cli  = 0
    bf_doc-line.price-base = 0
    bf_doc-line.price-rubl = 0
    bf_doc-line.cli-qnty   = 0
    bf_doc-line.fact-qnty  = 0
    bf_doc-line.doc-qnty   = 0
    bf_gds-dtl.doc-qnty    = 0
    bf_gds-dtl.fact-qnty   = 0
  .
end.
end.
end procedure.
define variable varoldfact-qnty-exp           like ub.doc-line-sum.fact-qnty           no-undo.
define variable varoldcost-sum-base-exp       like ub.doc-line-sum.cost-sum-base       no-undo.
define variable varoldcost-sum-rubl-exp       like ub.doc-line-sum.cost-sum-rubl       no-undo.
define variable varoldcost-vat-base-exp       like ub.doc-line-sum.cost-vat-base       no-undo.
define variable varoldcost-vat-rubl-exp       like ub.doc-line-sum.cost-vat-rubl       no-undo.
define variable varoldcost-slt-base-exp       like ub.doc-line-sum.cost-slt-base       no-undo.
define variable varoldcost-slt-rubl-exp       like ub.doc-line-sum.cost-slt-rubl       no-undo.
define variable varoldcost-road-tax-base-exp  like ub.doc-line-sum.cost-road-tax-base  no-undo.
define variable varoldcost-road-tax-rubl-exp  like ub.doc-line-sum.cost-road-tax-rubl  no-undo.
define variable varoldcost-excise-base-exp    like ub.doc-line-sum.cost-excise-base    no-undo.
define variable varoldcost-excise-rubl-exp    like ub.doc-line-sum.cost-excise-rubl    no-undo.
define variable varoldcost-transport-base-exp like ub.doc-line-sum.cost-transport-base no-undo.
define variable varoldcost-transport-rubl-exp like ub.doc-line-sum.cost-transport-rubl no-undo.
define variable varoldcost-other-base-exp     like ub.doc-line-sum.cost-other-base     no-undo.
define variable varoldcost-other-rubl-exp     like ub.doc-line-sum.cost-other-rubl     no-undo.
define variable varoldfact-qnty-inp           like ub.doc-line-sum.fact-qnty           no-undo.
define variable varoldcost-sum-base-inp       like ub.doc-line-sum.cost-sum-base       no-undo.
define variable varoldcost-sum-rubl-inp       like ub.doc-line-sum.cost-sum-rubl       no-undo.
define variable varoldcost-vat-base-inp       like ub.doc-line-sum.cost-vat-base       no-undo.
define variable varoldcost-vat-rubl-inp       like ub.doc-line-sum.cost-vat-rubl       no-undo.
define variable varoldcost-slt-base-inp       like ub.doc-line-sum.cost-slt-base       no-undo.
define variable varoldcost-slt-rubl-inp       like ub.doc-line-sum.cost-slt-rubl       no-undo.
define variable varoldcost-road-tax-base-inp  like ub.doc-line-sum.cost-road-tax-base  no-undo.
define variable varoldcost-road-tax-rubl-inp  like ub.doc-line-sum.cost-road-tax-rubl  no-undo.
define variable varoldcost-excise-base-inp    like ub.doc-line-sum.cost-excise-base    no-undo.
define variable varoldcost-excise-rubl-inp    like ub.doc-line-sum.cost-excise-rubl    no-undo.
define variable varoldcost-transport-base-inp like ub.doc-line-sum.cost-transport-base no-undo.
define variable varoldcost-transport-rubl-inp like ub.doc-line-sum.cost-transport-rubl no-undo.
define variable varoldcost-other-base-inp     like ub.doc-line-sum.cost-other-base     no-undo.
define variable varoldcost-other-rubl-inp     like ub.doc-line-sum.cost-other-rubl     no-undo.
procedure local-recalc :
define input parameter parmode as character no-undo.
define input parameter parrec-line as recid no-undo.
define variable p-value as character no-undo.
define variable p-type  as character no-undo.
define buffer bf_goods         for ub.goods.
define buffer bf_parts         for ub.parts.
define buffer bf-expp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-incp_trn-doc-sum  for ub.trn-doc-sum.
define buffer bf-expp_doc-line-sum for ub.doc-line-sum.
define buffer bf-incp_doc-line-sum for ub.doc-line-sum.
do on error undo, return error return-value :
find first bf_doc-line where recid( bf_doc-line ) = parrec-line.
find first bf_goods    where bf_goods.artic     = bf_doc-line.artic     and
                             bf_goods.prod-type = bf_doc-line.prod-type and
                             bf_goods.prod-code = bf_doc-line.prod-code no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclcinv in g#lib-trn2
(
input        parmode,
input        parrec-line,
input        t-doc.doc-code,
input-output vartot-docold,
input-output vartot-rublold,
input-output i-total-doc-line_tot-ovold,
input-output i-total-doc-line_fact-rublold,
input-output i-total-doc-line_fact-baseold,
input-output i-total-doc-line_fact-qntyold,
input-output i-total-doc-line_doc-qntyold,
input-output i-total-doc-line_cli-qntyold,
input-output i-total-parts_fact-baseold,
input-output i-total-parts_fact-rublold,
input-output i-total-parts_fact-qntyold
) no-error.
if error-status :error then do:
    message
    "Ошибка при обсчете линии по товару " bf_doc-line.artic " " bf_doc-line.prod-type " " bf_doc-line.prod-code skip
    view-as alert-box error.
  undo, return no-apply .
end.
if parmode <> "delete" then do:
  find first bf-expp_doc-line-sum where bf-expp_doc-line-sum.doc-code = bf_doc-line.doc-code
                                    and bf-expp_doc-line-sum.gds-code = bf_goods.gds-code
                                    and bf-expp_doc-line-sum.sum-type = 'exp':U exclusive-lock no-error.
  if not available bf-expp_doc-line-sum then do:
    create bf-expp_doc-line-sum.
    assign
      bf-expp_doc-line-sum.doc-code     = t-doc.doc-code
      bf-expp_doc-line-sum.ext-doc-type = t-doc.ext-doc-type
      bf-expp_doc-line-sum.obj-type     = t-doc.obj-type
      bf-expp_doc-line-sum.obj-code     = t-doc.obj-code
      bf-expp_doc-line-sum.gds-code     = bf_goods.gds-code
      bf-expp_doc-line-sum.sum-type     = 'exp':U
    .
  end.
  find first bf-incp_doc-line-sum where bf-incp_doc-line-sum.doc-code = bf_doc-line.doc-code
                                    and bf-incp_doc-line-sum.gds-code = bf_goods.gds-code
                                    and bf-incp_doc-line-sum.sum-type = 'inp':U exclusive-lock no-error.
  if not available bf-incp_doc-line-sum then do:
    create bf-incp_doc-line-sum.
    assign
      bf-incp_doc-line-sum.doc-code     = t-doc.doc-code
      bf-incp_doc-line-sum.ext-doc-type = t-doc.ext-doc-type
      bf-incp_doc-line-sum.obj-type     = t-doc.obj-type
      bf-incp_doc-line-sum.obj-code     = t-doc.obj-code
      bf-incp_doc-line-sum.gds-code     = bf_goods.gds-code
      bf-incp_doc-line-sum.sum-type     = 'inp':U
    .
  end.
end.
if parmode <> "old":u then do:
  if parmode <> "delete" then do:
    assign
      bf-expp_doc-line-sum.fact-qnty           = 0
      bf-expp_doc-line-sum.cost-sum-base       = 0
      bf-expp_doc-line-sum.cost-sum-rubl       = 0
      bf-expp_doc-line-sum.cost-vat-base       = 0
      bf-expp_doc-line-sum.cost-vat-rubl       = 0
      bf-expp_doc-line-sum.cost-slt-base       = 0
      bf-expp_doc-line-sum.cost-slt-rubl       = 0
      bf-expp_doc-line-sum.cost-road-tax-base  = 0
      bf-expp_doc-line-sum.cost-road-tax-rubl  = 0
      bf-expp_doc-line-sum.cost-excise-base    = 0
      bf-expp_doc-line-sum.cost-excise-rubl    = 0
      bf-expp_doc-line-sum.cost-transport-base = 0
      bf-expp_doc-line-sum.cost-transport-rubl = 0
      bf-expp_doc-line-sum.cost-other-base     = 0
      bf-expp_doc-line-sum.cost-other-rubl     = 0
      bf-incp_doc-line-sum.fact-qnty           = 0
      bf-incp_doc-line-sum.cost-sum-base       = 0
      bf-incp_doc-line-sum.cost-sum-rubl       = 0
      bf-incp_doc-line-sum.cost-vat-base       = 0
      bf-incp_doc-line-sum.cost-vat-rubl       = 0
      bf-incp_doc-line-sum.cost-slt-base       = 0
      bf-incp_doc-line-sum.cost-slt-rubl       = 0
      bf-incp_doc-line-sum.cost-road-tax-base  = 0
      bf-incp_doc-line-sum.cost-road-tax-rubl  = 0
      bf-incp_doc-line-sum.cost-excise-base    = 0
      bf-incp_doc-line-sum.cost-excise-rubl    = 0
      bf-incp_doc-line-sum.cost-transport-base = 0
      bf-incp_doc-line-sum.cost-transport-rubl = 0
      bf-incp_doc-line-sum.cost-other-base     = 0
      bf-incp_doc-line-sum.cost-other-rubl     = 0
    .
    for each bf_parts where bf_parts.out-code  = t-doc.doc-code     and
                            bf_parts.obj-type  = t-doc.obj-type     and
                            bf_parts.obj-code  = t-doc.obj-code     and
                            bf_parts.artic     = bf_goods.artic     and
                            bf_parts.prod-type = bf_goods.prod-type and
                            bf_parts.prod-code = bf_goods.prod-code on error undo, return error return-value :
      for each tt-clcparts :
        delete tt-clcparts.
      end.
      create tt-clcparts.
      buffer-copy bf_parts to tt-clcparts.
      run clcprtsl_calc-parts in this-procedure
         (input recid( tt-clcparts ),
          input no,
          input no,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?,
          input ?
         ).
      find first tt-allsum where tt-allsum.sum-type = 'основная_сумма':U.
      if bf_parts.in-code <> bf_parts.out-code then do:
         assign
           bf-expp_doc-line-sum.fact-qnty           = bf-expp_doc-line-sum.fact-qnty            - tt-allsum.fact-qnty
           bf-expp_doc-line-sum.cost-sum-base       = bf-expp_doc-line-sum.cost-sum-base        - tt-allsum.sum-dsc-base-acc
           bf-expp_doc-line-sum.cost-sum-rubl       = bf-expp_doc-line-sum.cost-sum-rubl        - tt-allsum.sum-dsc-rubl-acc
           bf-expp_doc-line-sum.cost-vat-base       = bf-expp_doc-line-sum.cost-vat-base        - tt-allsum.vat-base-acc
           bf-expp_doc-line-sum.cost-vat-rubl       = bf-expp_doc-line-sum.cost-vat-rubl        - tt-allsum.vat-rubl-acc
           bf-expp_doc-line-sum.cost-slt-base       = bf-expp_doc-line-sum.cost-slt-base        - tt-allsum.slt-base-acc
           bf-expp_doc-line-sum.cost-slt-rubl       = bf-expp_doc-line-sum.cost-slt-rubl        - tt-allsum.slt-rubl-acc
           bf-expp_doc-line-sum.cost-road-tax-base  = bf-expp_doc-line-sum.cost-road-tax-base   - tt-allsum.road-tax-base-acc
           bf-expp_doc-line-sum.cost-road-tax-rubl  = bf-expp_doc-line-sum.cost-road-tax-rubl   - tt-allsum.road-tax-rubl-acc
           bf-expp_doc-line-sum.cost-excise-base    = bf-expp_doc-line-sum.cost-excise-base     - tt-allsum.excise-base-acc
           bf-expp_doc-line-sum.cost-excise-rubl    = bf-expp_doc-line-sum.cost-excise-rubl     - tt-allsum.excise-rubl-acc
           bf-expp_doc-line-sum.cost-transport-base = bf-expp_doc-line-sum.cost-transport-base  - tt-allsum.transport-base-acc
           bf-expp_doc-line-sum.cost-transport-rubl = bf-expp_doc-line-sum.cost-transport-rubl  - tt-allsum.transport-rubl-acc
           bf-expp_doc-line-sum.cost-other-base     = bf-expp_doc-line-sum.cost-other-base      - tt-allsum.other-base-acc
           bf-expp_doc-line-sum.cost-other-rubl     = bf-expp_doc-line-sum.cost-other-rubl      - tt-allsum.other-rubl-acc
         .
      end.
      else do:
         assign
           bf-incp_doc-line-sum.fact-qnty           = bf-incp_doc-line-sum.fact-qnty            + tt-allsum.fact-qnty
           bf-incp_doc-line-sum.cost-sum-base       = bf-incp_doc-line-sum.cost-sum-base        + tt-allsum.sum-dsc-base-acc
           bf-incp_doc-line-sum.cost-sum-rubl       = bf-incp_doc-line-sum.cost-sum-rubl        + tt-allsum.sum-dsc-rubl-acc
           bf-incp_doc-line-sum.cost-vat-base       = bf-incp_doc-line-sum.cost-vat-base        + tt-allsum.vat-base-acc
           bf-incp_doc-line-sum.cost-vat-rubl       = bf-incp_doc-line-sum.cost-vat-rubl        + tt-allsum.vat-rubl-acc
           bf-incp_doc-line-sum.cost-slt-base       = bf-incp_doc-line-sum.cost-slt-base        + tt-allsum.slt-base-acc
           bf-incp_doc-line-sum.cost-slt-rubl       = bf-incp_doc-line-sum.cost-slt-rubl        + tt-allsum.slt-rubl-acc
           bf-incp_doc-line-sum.cost-road-tax-base  = bf-incp_doc-line-sum.cost-road-tax-base   + tt-allsum.road-tax-base-acc
           bf-incp_doc-line-sum.cost-road-tax-rubl  = bf-incp_doc-line-sum.cost-road-tax-rubl   + tt-allsum.road-tax-rubl-acc
           bf-incp_doc-line-sum.cost-excise-base    = bf-incp_doc-line-sum.cost-excise-base     + tt-allsum.excise-base-acc
           bf-incp_doc-line-sum.cost-excise-rubl    = bf-incp_doc-line-sum.cost-excise-rubl     + tt-allsum.excise-rubl-acc
           bf-incp_doc-line-sum.cost-transport-base = bf-incp_doc-line-sum.cost-transport-base  + tt-allsum.transport-base-acc
           bf-incp_doc-line-sum.cost-transport-rubl = bf-incp_doc-line-sum.cost-transport-rubl  + tt-allsum.transport-rubl-acc
           bf-incp_doc-line-sum.cost-other-base     = bf-incp_doc-line-sum.cost-other-base      + tt-allsum.other-base-acc
           bf-incp_doc-line-sum.cost-other-rubl     = bf-incp_doc-line-sum.cost-other-rubl      + tt-allsum.other-rubl-acc
         .
      end.
    end.
  end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input t-doc.doc-code ,
                        input 'addsum':U ,
                       output p-value ,
                       output p-type )  .
  if lookup( 'exp':U, p-value ) = 0 then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'addsum':U ,
                       input ( p-value + min( p-value, ',' ) + 'exp':U ) )  .
  end.
  find first bf-expp_trn-doc-sum where bf-expp_trn-doc-sum.doc-code = t-doc.doc-code       and
                                       bf-expp_trn-doc-sum.sum-type = 'exp':U exclusive-lock no-error.
  if not available bf-expp_trn-doc-sum then do:
    create bf-expp_trn-doc-sum.
    assign
      bf-expp_trn-doc-sum.doc-code     = t-doc.doc-code
      bf-expp_trn-doc-sum.ext-doc-type = t-doc.ext-doc-type
      bf-expp_trn-doc-sum.obj-type     = t-doc.obj-type
      bf-expp_trn-doc-sum.obj-code     = t-doc.obj-code
      bf-expp_trn-doc-sum.sum-type     = 'exp':U.
  end.
  if lookup( 'inp':U, p-value ) = 0 then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input t-doc.doc-code ,
                       input 'addsum':U ,
                       input ( p-value + min( p-value, ',' ) + 'inp':U ) )  .
  end.
  find first bf-incp_trn-doc-sum where bf-incp_trn-doc-sum.doc-code = t-doc.doc-code      and
                                       bf-incp_trn-doc-sum.sum-type = 'inp':U exclusive-lock no-error.
  if not available bf-incp_trn-doc-sum then do:
    create bf-incp_trn-doc-sum.
    assign
      bf-incp_trn-doc-sum.doc-code     = t-doc.doc-code
      bf-incp_trn-doc-sum.ext-doc-type = t-doc.ext-doc-type
      bf-incp_trn-doc-sum.obj-type     = t-doc.obj-type
      bf-incp_trn-doc-sum.obj-code     = t-doc.obj-code
      bf-incp_trn-doc-sum.sum-type     = 'inp':U.
  end.
  assign
    bf-expp_trn-doc-sum.fact-qnty           = bf-expp_trn-doc-sum.fact-qnty           +  (if parmode <> "delete" then bf-expp_doc-line-sum.fact-qnty           else 0) - varoldfact-qnty-exp
    bf-expp_trn-doc-sum.cost-sum-base       = bf-expp_trn-doc-sum.cost-sum-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-sum-base       else 0) - varoldcost-sum-base-exp
    bf-expp_trn-doc-sum.cost-sum-rubl       = bf-expp_trn-doc-sum.cost-sum-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-sum-rubl       else 0) - varoldcost-sum-rubl-exp
    bf-expp_trn-doc-sum.cost-vat-base       = bf-expp_trn-doc-sum.cost-vat-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-vat-base       else 0) - varoldcost-vat-base-exp
    bf-expp_trn-doc-sum.cost-vat-rubl       = bf-expp_trn-doc-sum.cost-vat-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-vat-rubl       else 0) - varoldcost-vat-rubl-exp
    bf-expp_trn-doc-sum.cost-slt-base       = bf-expp_trn-doc-sum.cost-slt-base       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-slt-base       else 0) - varoldcost-slt-base-exp
    bf-expp_trn-doc-sum.cost-slt-rubl       = bf-expp_trn-doc-sum.cost-slt-rubl       +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-slt-rubl       else 0) - varoldcost-slt-rubl-exp
    bf-expp_trn-doc-sum.cost-road-tax-base  = bf-expp_trn-doc-sum.cost-road-tax-base  +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-road-tax-base  else 0) - varoldcost-road-tax-base-exp
    bf-expp_trn-doc-sum.cost-road-tax-rubl  = bf-expp_trn-doc-sum.cost-road-tax-rubl  +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-road-tax-rubl  else 0) - varoldcost-road-tax-rubl-exp
    bf-expp_trn-doc-sum.cost-excise-base    = bf-expp_trn-doc-sum.cost-excise-base    +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-excise-base    else 0) - varoldcost-excise-base-exp
    bf-expp_trn-doc-sum.cost-excise-rubl    = bf-expp_trn-doc-sum.cost-excise-rubl    +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-excise-rubl    else 0) - varoldcost-excise-rubl-exp
    bf-expp_trn-doc-sum.cost-transport-base = bf-expp_trn-doc-sum.cost-transport-base +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-transport-base else 0) - varoldcost-transport-base-exp
    bf-expp_trn-doc-sum.cost-transport-rubl = bf-expp_trn-doc-sum.cost-transport-rubl +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-transport-rubl else 0) - varoldcost-transport-rubl-exp
    bf-expp_trn-doc-sum.cost-other-base     = bf-expp_trn-doc-sum.cost-other-base     +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-other-base     else 0) - varoldcost-other-base-exp
    bf-expp_trn-doc-sum.cost-other-rubl     = bf-expp_trn-doc-sum.cost-other-rubl     +  (if parmode <> "delete" then bf-expp_doc-line-sum.cost-other-rubl     else 0) - varoldcost-other-rubl-exp
    bf-incp_trn-doc-sum.fact-qnty           = bf-incp_trn-doc-sum.fact-qnty           +  (if parmode <> "delete" then bf-incp_doc-line-sum.fact-qnty           else 0) - varoldfact-qnty-inp
    bf-incp_trn-doc-sum.cost-sum-base       = bf-incp_trn-doc-sum.cost-sum-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-sum-base       else 0) - varoldcost-sum-base-inp
    bf-incp_trn-doc-sum.cost-sum-rubl       = bf-incp_trn-doc-sum.cost-sum-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-sum-rubl       else 0) - varoldcost-sum-rubl-inp
    bf-incp_trn-doc-sum.cost-vat-base       = bf-incp_trn-doc-sum.cost-vat-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-vat-base       else 0) - varoldcost-vat-base-inp
    bf-incp_trn-doc-sum.cost-vat-rubl       = bf-incp_trn-doc-sum.cost-vat-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-vat-rubl       else 0) - varoldcost-vat-rubl-inp
    bf-incp_trn-doc-sum.cost-slt-base       = bf-incp_trn-doc-sum.cost-slt-base       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-slt-base       else 0) - varoldcost-slt-base-inp
    bf-incp_trn-doc-sum.cost-slt-rubl       = bf-incp_trn-doc-sum.cost-slt-rubl       +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-slt-rubl       else 0) - varoldcost-slt-rubl-inp
    bf-incp_trn-doc-sum.cost-road-tax-base  = bf-incp_trn-doc-sum.cost-road-tax-base  +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-road-tax-base  else 0) - varoldcost-road-tax-base-inp
    bf-incp_trn-doc-sum.cost-road-tax-rubl  = bf-incp_trn-doc-sum.cost-road-tax-rubl  +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-road-tax-rubl  else 0) - varoldcost-road-tax-rubl-inp
    bf-incp_trn-doc-sum.cost-excise-base    = bf-incp_trn-doc-sum.cost-excise-base    +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-excise-base    else 0) - varoldcost-excise-base-inp
    bf-incp_trn-doc-sum.cost-excise-rubl    = bf-incp_trn-doc-sum.cost-excise-rubl    +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-excise-rubl    else 0) - varoldcost-excise-rubl-inp
    bf-incp_trn-doc-sum.cost-transport-base = bf-incp_trn-doc-sum.cost-transport-base +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-transport-base else 0) - varoldcost-transport-base-inp
    bf-incp_trn-doc-sum.cost-transport-rubl = bf-incp_trn-doc-sum.cost-transport-rubl +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-transport-rubl else 0) - varoldcost-transport-rubl-inp
    bf-incp_trn-doc-sum.cost-other-base     = bf-incp_trn-doc-sum.cost-other-base     +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-other-base     else 0) - varoldcost-other-base-inp
    bf-incp_trn-doc-sum.cost-other-rubl     = bf-incp_trn-doc-sum.cost-other-rubl     +  (if parmode <> "delete" then bf-incp_doc-line-sum.cost-other-rubl     else 0) - varoldcost-other-rubl-inp
  .
end.
else do:
  assign
    varoldfact-qnty-exp            =   bf-expp_doc-line-sum.fact-qnty
    varoldcost-sum-base-exp        =   bf-expp_doc-line-sum.cost-sum-base
    varoldcost-sum-rubl-exp        =   bf-expp_doc-line-sum.cost-sum-rubl
    varoldcost-vat-base-exp        =   bf-expp_doc-line-sum.cost-vat-base
    varoldcost-vat-rubl-exp        =   bf-expp_doc-line-sum.cost-vat-rubl
    varoldcost-slt-base-exp        =   bf-expp_doc-line-sum.cost-slt-base
    varoldcost-slt-rubl-exp        =   bf-expp_doc-line-sum.cost-slt-rubl
    varoldcost-road-tax-base-exp   =   bf-expp_doc-line-sum.cost-road-tax-base
    varoldcost-road-tax-rubl-exp   =   bf-expp_doc-line-sum.cost-road-tax-rubl
    varoldcost-excise-base-exp     =   bf-expp_doc-line-sum.cost-excise-base
    varoldcost-excise-rubl-exp     =   bf-expp_doc-line-sum.cost-excise-rubl
    varoldcost-transport-base-exp  =   bf-expp_doc-line-sum.cost-transport-base
    varoldcost-transport-rubl-exp  =   bf-expp_doc-line-sum.cost-transport-rubl
    varoldcost-other-base-exp      =   bf-expp_doc-line-sum.cost-other-base
    varoldcost-other-rubl-exp      =   bf-expp_doc-line-sum.cost-other-rubl
    varoldfact-qnty-inp            =   bf-incp_doc-line-sum.fact-qnty
    varoldcost-sum-base-inp        =   bf-incp_doc-line-sum.cost-sum-base
    varoldcost-sum-rubl-inp        =   bf-incp_doc-line-sum.cost-sum-rubl
    varoldcost-vat-base-inp        =   bf-incp_doc-line-sum.cost-vat-base
    varoldcost-vat-rubl-inp        =   bf-incp_doc-line-sum.cost-vat-rubl
    varoldcost-slt-base-inp        =   bf-incp_doc-line-sum.cost-slt-base
    varoldcost-slt-rubl-inp        =   bf-incp_doc-line-sum.cost-slt-rubl
    varoldcost-road-tax-base-inp   =   bf-incp_doc-line-sum.cost-road-tax-base
    varoldcost-road-tax-rubl-inp   =   bf-incp_doc-line-sum.cost-road-tax-rubl
    varoldcost-excise-base-inp     =   bf-incp_doc-line-sum.cost-excise-base
    varoldcost-excise-rubl-inp     =   bf-incp_doc-line-sum.cost-excise-rubl
    varoldcost-transport-base-inp  =   bf-incp_doc-line-sum.cost-transport-base
    varoldcost-transport-rubl-inp  =   bf-incp_doc-line-sum.cost-transport-rubl
    varoldcost-other-base-inp      =   bf-incp_doc-line-sum.cost-other-base
    varoldcost-other-rubl-inp      =   bf-incp_doc-line-sum.cost-other-rubl
  .
end.
end.
end procedure.
procedure local-delete :
define input parameter parrec-line as recid no-undo.
define buffer bf_doc-line for ub.doc-line.
define variable l-inv-on as logical no-undo.
do on error undo, return error return-value :
find first bf_doc-line where recid( bf_doc-line ) = parrec-line.
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  bf_doc-line.obj-type
  ,input  bf_doc-line.obj-code
  ,input  bf_doc-line.artic
  ,input  bf_doc-line.prod-type
  ,input  bf_doc-line.prod-code
  ,input  'inv-on=false'
  ,output l-inv-on
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка установки атрибута товара на объекте" skip
    "Документ" bf_doc-line.doc-code skip
    "Объект" bf_doc-line.obj-type bf_doc-line.obj-code skip
    "Артикул" bf_doc-line.artic bf_doc-line.prod-type bf_doc-line.prod-code skip
    "l-inv-on" l-inv-on skip
    view-as alert-box error .
  undo, return error .
end.
delete bf_doc-line.
end.
end procedure.
procedure local-chg:
define buffer bf_goods for ub.goods.
define variable varhvrdtax        as   logical                  no-undo.
define variable varis-ok as logical no-undo.
define variable varlog as logical no-undo.
define variable varmode as character no-undo.
if not available bf_doc-line then do:
  message "Неправильный выбор строки.".
  return no-apply.
end.
do transaction on error undo, return no-apply :
run local-recalc in this-procedure ( input "old":U,
                                     input recid( bf_doc-line ) ) no-error.
if error-status :error then do:
  undo, return error "Ошибка при пересчете строки документа".
end.
find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                          bf_goods.prod-type = bf_doc-line.prod-type and
                          bf_goods.prod-code = bf_doc-line.prod-code no-lock.
assign
  varhvrdtax = hvrdtax ( recid( bf_goods ) ).
assign
  varlog = ?.
message
"Товар " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name
"Вы можете поменять цены по: " skip
" - всем выбранным партиям из свободной зоны (YES) " skip
" - новым выбранным партиям из свободной зоны (NO) "
view-as alert-box question buttons yes-no update varlog.
if varlog = yes then do:
  assign
    varmode = "chg_parts":u.
end.
else do:
  varmode = "chg_new_parts":u.
end.
find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
run update-line in this-procedure
(  input varmode
 , input recid( bf_doc-line )
 , input bf_sysconf.cash-pay
 , input ?
 , input ?
 , input ?
 , input ?
) no-error.
if error-status :error then do:
  undo, return error "Ошибка при редактировании линии документа по товару " + bf_doc-line.artic + " " + bf_doc-line.prod-type + " " + string(bf_doc-line.prod-code).
end.
if available bf_doc-line then do:
  run local-recalc in this-procedure ( input "update":U,
                                       input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    undo, return error "Ошибка при пересчете строки документа".
  end.
end.
end.
end procedure.
procedure local-lockup:
define buffer bf_goods for ub.goods.
define variable prt-rec as recid no-undo.
if available bf_doc-line then do:
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
   run str/parts-l.w
     (input parparentproc
     ,input t-doc.obj-type
     ,input t-doc.obj-code
     ,input bf_goods.gds-code
     ,input bf_doc-line.doc-code
     ,input 'ПРОСМОТР':U
     ,input 'документ':U
     ,input 'текущий':U
     ,input 'документ':U
     ,output prt-rec
     ) .
end.
end procedure.
procedure change-price :
  define parameter buffer buf-orig_parts for  ub.parts .
  define input  parameter  parqnty             like ub.parts.fact-qnty      no-undo.
  define input  parameter  parexch-code        like ub.parts.exch-code      no-undo.
  define input  parameter  parcli-base-rate    like ub.parts.cli-base-rate  no-undo.
  define input  parameter  parvat-type         like ub.parts.vat-type       no-undo.
  define input  parameter  parslt-type         like ub.parts.slt-type       no-undo.
  define input  parameter  parprice-cli        like ub.parts.price-cli      no-undo.
  define input  parameter  parprice-base       like ub.parts.price-base     no-undo.
  define input  parameter  parprice-rubl       like ub.parts.price-rubl     no-undo.
  define input  parameter  parvat-pc           like ub.parts.vat-pc         no-undo.
  define input  parameter  parslt-pc           like ub.parts.slt-pc         no-undo.
  define input  parameter  parroad-tax-base    like ub.parts.road-tax-base  no-undo.
  define input  parameter  parroad-tax-rubl    like ub.parts.road-tax-rubl  no-undo.
  define input  parameter  partransport-base   like ub.parts.transport-base no-undo.
  define input  parameter  partransport-rubl   like ub.parts.transport-rubl no-undo.
  define input  parameter  parother-base       like ub.parts.other-base     no-undo.
  define input  parameter  parother-rubl       like ub.parts.other-rubl     no-undo.
  define input  parameter  parcash-pay         like ub.parts.pay-code       no-undo.
  define input  parameter  parinternal         like ub.trn-doc.internal     no-undo.
  define input  parameter  pardoc-type         like ub.trn-doc.doc-type     no-undo.
  define input  parameter  parext-doc-type     like ub.trn-doc.ext-doc-type no-undo.
  define input  parameter  parcreate-new-parts as   logical                 no-undo.
  define input  parameter  parrecid-caus-parts as   recid                   no-undo.
  define input  parameter  parpurch-code       like ub.parts.purch-code     no-undo.
  define output parameter  parrec-parts        as   recid                   no-undo.
  define buffer buf-caus_parts for ub.parts.
  define buffer buf_units      for ub.units.
  define buffer buf-have_parts for ub.parts.
  define variable varnew-slt-type as character no-undo.
  define variable varpart-code like ub.parts.part-code no-undo.
  define variable varslt-yes as logical no-undo.
  define buffer buf_goods      for ub.goods.
  define buffer buf_parts-root for ub.parts-root.
  do on error undo, return error return-value :
    find first buf_goods           no-lock where
               buf_goods.artic     = buf-orig_parts.artic
           and buf_goods.prod-type = buf-orig_parts.prod-type
           and buf_goods.prod-code = buf-orig_parts.prod-code .
    find buf_units where buf_units.unit-name = buf_goods.unit-base no-lock.
    if (parroad-tax-base <> 0 and
        parroad-tax-base <> ?     ) or
       (parroad-tax-rubl <> 0 and
        parroad-tax-rubl <> ?     )
       then do:
       if hvrdtax ( recid( buf_goods ) ) = no then do:
         message
           vss-workfile vss-revision vss-description skip
           "Для товара " buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
           " недопустима установка дополнительной компоненты отличной от 0." skip
         view-as alert-box error.
         undo, return error .
       end.
    end.
    if parcreate-new-parts then do:
      if lookup('сер':U, buf_units.type) > 0 then do:
        find first buf-have_parts where buf-have_parts.obj-type  = buf-orig_parts.obj-type  and
                                        buf-have_parts.obj-code  = buf-orig_parts.obj-code  and
                                        buf-have_parts.artic     = buf-orig_parts.artic     and
                                        buf-have_parts.prod-type = buf-orig_parts.prod-type and
                                        buf-have_parts.prod-code = buf-orig_parts.prod-code and
                                        buf-have_parts.in-code   = buf-orig_parts.out-code  and
                                        buf-have_parts.out-code  = buf-orig_parts.out-code  and
                                        buf-have_parts.part-code = buf-orig_parts.part-code no-lock no-error.
        if available buf-have_parts then do:
          message "Товар " buf_goods.artic " " buf_goods.prod-type " " buf_goods.prod-code " " buf_goods.gds-name " - серийный." skip
                  "Делаем коррекцию учетной цены по партии с кодом " buf-orig_parts.part-code "." skip
                  "Но в документе уже есть порожденная партия этого товара с таким кодом либо в данном процессе должны породиться две партии с таким кодом."
          view-as alert-box error.
          undo, return error return-value.
        end.
        else do:
          assign
            varpart-code = buf-orig_parts.part-code.
        end.
      end.
      else do:
        run holdprts-get-part-code in this-procedure (  input buf-orig_parts.out-code
                                                     , output varpart-code
                                                      ) no-error .
        if error-status :error then dO:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при получении кода партии." skip
            return-value skip
            trim(error-status :get-message(1)) skip
            view-as alert-box error.
          undo, return error return-value.
        end.
      end.
      create buf-caus_parts .
      buffer-copy buf-orig_parts
      except in-code rsrv-free status_ qnty fact-qnty real-qnty cli-qnty price-rubl price-base
             vat-pc slt-pc road-tax-rubl road-tax-base transport-rubl transport-base other-rubl
             other-base part-code exch-code cli-base-rate price-cli vat-type slt-type to buf-caus_parts.
      assign
        buf-caus_parts.in-code        = buf-caus_parts.out-code
        buf-caus_parts.part-code      = varpart-code
        buf-caus_parts.rsrv-free      = ?
        buf-caus_parts.status_        = no
        buf-caus_parts.qnty           = parqnty
        buf-caus_parts.fact-qnty      = parqnty
        buf-caus_parts.real-qnty      = 0
        buf-caus_parts.cli-base-rate  = parcli-base-rate
        buf-caus_parts.vat-type       = parvat-type
        buf-caus_parts.slt-type       = parslt-type
        buf-caus_parts.cli-qnty       = parqnty / parcli-base-rate
        buf-caus_parts.exch-code      = parexch-code
      .
      find first buf_parts-root where
                 buf_parts-root.doc-code       = buf-caus_parts.out-code
           and   buf_parts-root.in-code        = buf-caus_parts.in-code
           and   buf_parts-root.gds-code       = buf_goods.gds-code
           and   buf_parts-root.part-code      = buf-caus_parts.part-code
           and   buf_parts-root.orig-in-code   = buf-orig_parts.in-code
           and   buf_parts-root.orig-gds-code  = buf_goods.gds-code
           and   buf_parts-root.orig-part-code = buf-orig_parts.part-code no-error .
      if not available buf_parts-root then do:
        create buf_parts-root.
        assign
          buf_parts-root.doc-code       = buf-caus_parts.out-code
          buf_parts-root.in-code        = buf-caus_parts.in-code
          buf_parts-root.gds-code       = buf_goods.gds-code
          buf_parts-root.part-code      = buf-caus_parts.part-code
          buf_parts-root.orig-in-code   = buf-orig_parts.in-code
          buf_parts-root.orig-gds-code  = buf_goods.gds-code
          buf_parts-root.orig-part-code = buf-orig_parts.part-code
        .
      end.
    end.
    else do:
      find first buf-caus_parts where recid( buf-caus_parts ) = parrecid-caus-parts.
    end.
    assign
      buf-caus_parts.price-rubl     = parprice-rubl
      buf-caus_parts.price-base     = parprice-base
      buf-caus_parts.price-cli      = parprice-cli
      buf-caus_parts.vat-pc         = parvat-pc
      buf-caus_parts.slt-pc         = parslt-pc
      buf-caus_parts.road-tax-rubl  = parroad-tax-rubl
      buf-caus_parts.road-tax-base  = parroad-tax-base
      buf-caus_parts.transport-rubl = partransport-rubl
      buf-caus_parts.transport-base = partransport-base
      buf-caus_parts.other-rubl     = parother-rubl
      buf-caus_parts.other-base     = parother-base
    .
    if parslt-pc <> 0 then do:
      if buf-caus_parts.slt-type <> 'в т. ч.':U and
         buf-caus_parts.slt-type <> 'нет':U  then do:
        assign
          buf-caus_parts.slt-type = 'в т. ч.':U .
      end.
    end.
    if parpurch-code <> ? then do:
      assign
        buf-caus_parts.purch-code = parpurch-code.
    end.
  end.
end procedure.
procedure check-cli :
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer bf_contract for ub.contract.
define buffer bf_currency for ub.currency.
define variable varexch-rate  like ub.trn-doc.exch-rate  no-undo.
define variable varexch-scale like ub.trn-doc.exch-scale no-undo.
define variable varcurr-abbr  as   character             no-undo.
define variable varcontract-code like ub.contract.contract-code no-undo.
define variable varbase-code like ub.sysconf.base-code no-undo.
do on error undo, return error return-value :
if input frame d-doc t-doc.cli-type = ? or input frame d-doc t-doc.cli-type = "" then do:
  if can-find (clients where clients.obj-code = input frame d-doc t-doc.cli-code
                         and clients.obj-type = 'орг':U no-lock) then do:
    display 'орг':U @ t-doc.cli-type with frame d-doc.
  end.
  else do:
    display 'чел':U @ t-doc.cli-type with frame d-doc.
  end.
end.
find clients where clients.obj-code = input frame d-doc t-doc.cli-code
               and clients.obj-type = input frame d-doc t-doc.cli-type no-error.
if not available clients then do:
  if input frame d-doc t-doc.cli-code <> ? and input t-doc.cli-type <> ? then
  message "Неправильный код или тип контрагента.".
  apply "entry" to t-doc.cli-code in frame d-doc.
  return error.
end.
display clients.obj-type @ t-doc.cli-type with frame d-doc.
if clients.obj-type = 'скл':U or
   clients.obj-type = 'маг':U  then do:
  release clients no-error.
  message "Выберите организацию или человека.".
  apply "entry" to t-doc.cli-code in frame d-doc.
  return error.
end.
define variable v-err as logical   no-undo .
  run ver-clients  ( clients.obj-type , clients.obj-code , output v-err ) .
  if  v-err then do:
    apply "entry" to t-doc.cli-code in frame d-doc.
    return error.
  end.
assign
  t-doc.cli-code = input frame d-doc t-doc.cli-code
  t-doc.cli-type = input frame d-doc t-doc.cli-type.
display clients.obj-name with frame d-doc.
assign
  pardoc-mode = 'ИЗМЕНЕНИЕ':U.
find first bf_contract where bf_contract.host-code = t-doc.host-code                          and
                             bf_contract.cli-type  = input frame d-doc t-doc.cli-type and
                             bf_contract.cli-code  = input frame d-doc t-doc.cli-code and
                             bf_contract.status_   = 'тек':U                         no-lock no-error.
if not available bf_contract then do:
  assign
    t-doc.contract-code  = 0
    varcntr-prn-code     = ""
    varcntr-name         = "БЕЗ ДОГОВОРА"
    .
end.
else do:
  run check-contract-code in this-procedure (input  "choose":u,
                                             input  t-doc.host-code,
                                             input  input frame d-doc t-doc.cli-type,
                                             input  input frame d-doc t-doc.cli-code,
                                             input  ?,
                                             input  parparentproc,
                                             input  t-doc.doc-date,
                                             input  "" ,
                                             output varcontract-code) no-error.
  if error-status :error    or
     varcontract-code = ?  or
     varcontract-code = 0  then do:
    message "Вы не выбрали договор. Вы хотите редактировать партии свободной зоны по приходам без договора?"
    view-as alert-box question buttons yes-no update varlog.
    if varlog = no then do:
      apply "entry" to t-doc.cli-code in frame d-doc.
      return error.
    end.
    else do:
      assign
        t-doc.contract-code = 0
        varcntr-prn-code    = ""
        varcntr-name        = "БЕЗ ДОГОВОРА"
      .
    end.
  end.
  else do:
    find first bf_contract where bf_contract.host-code     = t-doc.host-code  and
                                 bf_contract.contract-code = varcontract-code no-lock.
    find first bf_currency where bf_currency.curr-code = bf_contract.curr-code no-lock no-error.
    if not available bf_currency then do:
      message "В договоре указана валюта " bf_contract.curr-code "." skip
              "Но этой валюты нет в справочнике валют."
      view-as alert-box error.
      apply "entry" to t-doc.cli-code in frame d-doc.
      return error.
    end.
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  bf_currency.curr-code
  ,input  t-doc.exch-date
  ,output varexch-rate
  ,output varexch-scale
  ,output varcurr-abbr
  ) no-error .
    if error-status :error then do:
      message "Ошибка при поиске курса валюты поставки по договору." skip
              return-value skip
              error-status :get-message( 1 ) skip
              error-status :get-message( 2 )
      view-as alert-box error.
      return error.
    end.
    assign
      t-doc.contract-code = varcontract-code
      t-doc.exch-code     = bf_contract.curr-code
      t-doc.exch-rate     = varexch-rate
      t-doc.exch-scale    = varexch-scale
      varcntr-prn-code    = bf_contract.contract-prn-code
      varcntr-name        = bf_contract.contract-name
    .
  end.
end.
if clients.obj-type = 'орг':U then do:
  find firm where firm.firm-code = clients.obj-code no-lock.
  find clients where clients.obj-type = 'чел':U
                        and clients.obj-code = firm.tobj-code no-lock no-error.
  if available clients then
    display clients.obj-code @ t-doc.boss
            clients.obj-name @ boss-name with frame d-doc.
end.
release clients.
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  t-doc.obj-type
  ,input  t-doc.obj-code
  ,output v-today
  )  .
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  t-doc.host-code
  ,output varbase-code
  )  .
find last curr-accnt where curr-accnt.curr-code  = varbase-code
                       and curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
if not available curr-accnt then do:
   message "На дату" v-today "неизвестен курс базовой валюты." SKIP
   view-as alert-box error.
   return error.
end.
else do:
  assign
    t-doc.base-rate  = curr-accnt.exch-rate
    t-doc.base-scale = curr-accnt.exch-scale.
end.
assign
  t-doc.exch-date     = v-today
  t-doc.print-rubl    = yes.
run UI-on in this-procedure ( input "enable" ).
if b-add :sensitive = yes then apply "entry" to b-add in frame d-doc.
end.
end procedure.
procedure choose-cli:
define variable varfirm-code like firm.firm-code no-undo.
define buffer bf_clients for ub.clients.
do on error undo, return error return-value :
run check-cli in this-procedure no-error.
if error-status :error then do:
  run ref/cli-all.w (parparentproc
                , "b-sel"
                , 'орг':U
                , ?
                , ?
                , ?
                , ?
                , ?
                , output ref-list) .
  if ref-list <> "" then do:
    ref-rec = integer (ref-list).
    find first bf_clients where recid( bf_clients ) = ref-rec no-lock.
    display bf_clients.obj-code @ t-doc.cli-code
            bf_clients.obj-name @ clients.obj-name with frame d-doc.
    display bf_clients.obj-type @ t-doc.cli-type   with frame d-doc.
  end.
  run check-cli in this-procedure no-error.
  if error-status :error then do:
    return error return-value.
  end.
end.
end.
end procedure.
procedure check-line :
define input parameter parrec-line as recid no-undo.
define buffer bf_doc-line   for ub.doc-line.
define buffer bf_goods      for ub.goods.
define buffer bf_parts-root for ub.parts-root.
define buffer bf_parts      for ub.parts.
define buffer bf-cr_parts   for ub.parts.
define variable varqnty    as decimal no-undo.
define variable varcr-qnty as decimal no-undo.
do on error undo, return error return-value :
find first bf_doc-line where recid( bf_doc-line ) = parrec-line no-error.
if not available bf_doc-line then do:
  return error substitute ("Не найдена строка документа в процедуре check-line.").
end.
find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                          bf_goods.prod-type = bf_doc-line.prod-type and
                          bf_goods.prod-code = bf_doc-line.prod-code no-lock.
for each bf_parts where bf_parts.out-code      = t-doc.doc-code
                    and bf_parts.obj-type      = t-doc.obj-type
                    and bf_parts.obj-code      = t-doc.obj-code
                    and bf_parts.artic         = bf_doc-line.artic
                    and bf_parts.prod-type     = bf_doc-line.prod-type
                    and bf_parts.prod-code     = bf_doc-line.prod-code
                    and bf_parts.in-code      <> t-doc.doc-code         on error undo, return error return-value :
  assign
    varqnty = varqnty + bf_parts.fact-qnty.
  for each bf_parts-root where bf_parts-root.doc-code       = bf_parts.out-code
                           and bf_parts-root.orig-in-code   = bf_parts.in-code
                           and bf_parts-root.orig-gds-code  = bf_goods.gds-code
                           and bf_parts-root.orig-part-code = bf_parts.part-code on error undo, return error return-value :
    find first bf-cr_parts where bf-cr_parts.obj-type  = t-doc.obj-type
                             and bf-cr_parts.obj-code  = t-doc.obj-code
                             and bf-cr_parts.artic     = bf_doc-line.artic
                             and bf-cr_parts.prod-type = bf_doc-line.prod-type
                             and bf-cr_parts.prod-code = bf_doc-line.prod-code
                             and bf-cr_parts.in-code   = bf_parts-root.in-code
                             and bf-cr_parts.out-code  = bf_parts-root.doc-code
                             and bf-cr_parts.part-code = bf_parts-root.part-code .
    assign
      varcr-qnty = varcr-qnty + bf-cr_parts.fact-qnty.
  end.
end.
if varqnty <> - varcr-qnty then do:
  return error substitute ("Критическая ошибка. Кол-во по взятым партиям из свободной зоны &1. Количество по созданым партиям &2.", varqnty, varcr-qnty).
end.
for each bf_parts-root where bf_parts-root.doc-code = t-doc.doc-code on error undo, return error return-value :
  find first bf_goods where bf_goods.gds-code = bf_parts-root.gds-code.
  find first bf_parts where bf_parts.obj-type  = t-doc.obj-type
                        and bf_parts.obj-code  = t-doc.obj-code
                        and bf_parts.artic     = bf_goods.artic
                        and bf_parts.prod-type = bf_goods.prod-type
                        and bf_parts.prod-code = bf_goods.prod-code
                        and bf_parts.in-code   = bf_parts-root.orig-in-code
                        and bf_parts.part-code = bf_parts-root.orig-part-code no-error.
  if not available bf_parts then do:
    return error substitute ("Критическая ошибка. Есть запись parts-root c ссылкой на родительскую партию. Партия: Объект &1 &2. Товар &3 &4 &5. Порожд. док-т. &6. Код партии &7.",
                            t-doc.obj-type,
                            t-doc.obj-code,
                            bf_goods.artic,
                            bf_goods.prod-type,
                            bf_goods.prod-code,
                            bf_parts-root.orig-in-code,
                            bf_parts-root.orig-part-code
                           ).
  end.
  find first bf-cr_parts where bf-cr_parts.obj-type  = t-doc.obj-type
                           and bf-cr_parts.obj-code  = t-doc.obj-code
                           and bf-cr_parts.artic     = bf_goods.artic
                           and bf-cr_parts.prod-type = bf_goods.prod-type
                           and bf-cr_parts.prod-code = bf_goods.prod-code
                           and bf-cr_parts.in-code   = bf_parts-root.in-code
                           and bf-cr_parts.out-code  = bf_parts-root.doc-code
                           and bf-cr_parts.part-code = bf_parts-root.part-code no-error.
  if not available bf-cr_parts then do:
    return error substitute ("Критическая ошибка. Есть запись parts-root c ссылкой на дочернюю партию. Партия: Объект &1 &2. Товар &3 &4 &5. Порожд. док-т. &6. Док-т &7. Код партии &8.",
                            t-doc.obj-type,
                            t-doc.obj-code,
                            bf_goods.artic,
                            bf_goods.prod-type,
                            bf_goods.prod-code,
                            bf_parts-root.in-code,
                            bf_parts-root.doc-code,
                            bf_parts-root.part-code
                           ).
  end.
end.
for each bf-cr_parts where bf-cr_parts.out-code  = t-doc.out-code
                       and bf-cr_parts.obj-type  = t-doc.obj-type
                       and bf-cr_parts.obj-code  = t-doc.obj-code
                       and bf-cr_parts.artic     = bf_doc-line.artic
                       and bf-cr_parts.prod-type = bf_doc-line.prod-type
                       and bf-cr_parts.prod-code = bf_doc-line.prod-code on error undo, return error return-value :
  find first bf_parts-root where bf_parts-root.doc-code  = bf-cr_parts.out-code
                             and bf_parts-root.in-code   = bf-cr_parts.out-code
                             and bf_parts-root.gds-code  = bf_goods.gds-code
                             and bf_parts-root.part-code = bf-cr_parts.part-code no-error.
  if not available bf_parts-root then do:
    return error substitute ("Критическая ошибка. Не найден parts-root для партии. Объект &1 &2. Товар &3 &4 &5. Код партии &6.",
                             bf-cr_parts.obj-type,
                             bf-cr_parts.obj-code,
                             bf-cr_parts.artic,
                             bf-cr_parts.prod-type,
                             bf-cr_parts.prod-code,
                             bf-cr_parts.part-code).
  end.
end.
end.
end procedure.
procedure local-chg-vat :
define variable varlog           as   logical            no-undo.
define variable varvat-pc        like ub.doc-line.vat-pc no-undo.
define variable varpurch-list    as   character          no-undo.
define variable varoldvat-pc     like ub.doc-line.vat-pc no-undo.
define variable varchange-price  as   logical            no-undo.
define variable varis-ok         as   logical            no-undo.
define variable varartic         like ub.goods.artic     no-undo.
define variable recid-line       as   recid              no-undo.
define variable varcount         as   integer            no-undo.
define variable vartime          as   integer            no-undo.
define variable varoutput-string as   character          no-undo.
define variable varnotes as character no-undo.
define variable varlns-cnt as integer no-undo.
define buffer bf_goods      for ub.goods.
define buffer bf-free_parts for ub.parts.
assign
  vartime = time.
do on error undo, return error return-value :
message "Вы хотите поменять НДС по всем партиям свободной зоны для списка товаров?" skip
        view-as alert-box question button yes-no update varlog.
if varlog <> yes then do:
  return.
end.
run str/chg-vat.w (output varoldvat-pc,
               output varvat-pc,
               output varpurch-list,
               output varchange-price,
               output varis-ok)     no-error.
if error-status :error then do:
  if return-value <> "" then do:
    message "Ошибка при установке процента НДС." skip
            return-value skip
    view-as alert-box error.
    return error.
  end.
end.
if varis-ok <> yes then do:
  return error.
end.
run str/chs-gds.w
  ( input parparentproc,
    input v-cntxt-obj-type,
    input v-cntxt-obj-code,
    input "":u,
    input t-doc.status_,
    input "Строка накладной № " + t-doc.doc-code,
    input ?,
    input ?,
    input ?,
    input v-cntxt-host-code-obj,
    input parext-doc-type,
    input-output varartic,
    output varnotes).
if varnotes = '' then return.
varlns-cnt = 1.
do while varlns-cnt <= num-entries (varnotes) on error undo, return error return-value :
gds:
do transaction on error undo, leave :
  find first bf_goods where recid( bf_goods ) = integer( entry( varlns-cnt, varnotes ) ) no-lock.
  varlns-cnt = varlns-cnt + 1.
  find first bf_doc-line where bf_doc-line.doc-code  = t-doc.doc-code     and
                               bf_doc-line.artic     = bf_goods.artic     and
                               bf_doc-line.prod-type = bf_goods.prod-type and
                               bf_doc-line.prod-code = bf_goods.prod-code no-error.
  if available bf_doc-line then do:
    message "Товар " bf_doc-line.artic " " bf_doc-line.prod-type " " bf_doc-line.prod-code " " bf_goods.gds-name " уже есть в данной накладной." skip
            "Хотите отредактировать его?" view-as alert-box question buttons yes-no update varlog.
    if not varlog then do:
      undo, leave gds.
    end.
  end.
  else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkgdsd in g#lib-trn3
( input recid(t-doc)
 ,input recid(bf_goods)
) no-error.
    if error-status :error then do:
      put stream str-err unformatted return-value.
      undo, leave gds.
    end.
    find first bf-free_parts where bf-free_parts.host-code     = t-doc.host-code       and
                                   bf-free_parts.supp-type     = t-doc.cli-type        and
                                   bf-free_parts.supp-code     = t-doc.cli-code        and
                                   bf-free_parts.status_       = no                    and
                                   bf-free_parts.obj-type      = t-doc.obj-type        and
                                   bf-free_parts.obj-code      = t-doc.obj-code        and
                                   bf-free_parts.rsrv-free     = yes                   and
                                   bf-free_parts.out-code      = 'free-zone':U          and
                                   bf-free_parts.prod-type     = bf_goods.prod-type    and
                                   bf-free_parts.prod-code     = bf_goods.prod-code    and
                                   bf-free_parts.artic         = bf_goods.artic        and
                                   bf-free_parts.contract-code = t-doc.contract-code   and
                                   lookup(string(bf-free_parts.purch-code), varpurch-list) > 0 no-lock no-error.
    if not available bf-free_parts then do:
      assign
        varlog-err = yes.
      put stream str-err unformatted
              "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name "."
              "Объект: " t-doc.obj-type " " t-doc.obj-code skip
              "Поставщик " t-doc.cli-type " " t-doc.cli-code " " t-doc.cli-name skip
              "Нет товара от поставщика по заданым типам приобретения в свободной зоне на объекте." skip
              "Пропускаем." skip.
      undo, leave gds.
    end.
    run add-doc-inv-line in this-procedure ( input recid( bf_goods ), output recid-line ) no-error.
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при добавлении товара " skip
        bf_goods.artic skip
        bf_goods.prod-type skip
        bf_goods.prod-code skip
        " в документ."
        return-value skip
        trim(error-status :get-message(1))
        view-as alert-box error.
      undo, leave gds.
    end.
    find first bf_doc-line where recid( bf_doc-line ) = recid-line.
  end.
  assign
    bf_doc-line.prt-OK = ?.
  run local-recalc in this-procedure ( input "old":U,
                                       input recid( bf_doc-line ) ) no-error.
  if error-status :error then do:
    message
    vss-workfile vss-revision vss-description skip
    "Ошибка при пересчете строки документа" skip
    return-value skip
    trim( error-status :get-message( 1 ) )
    view-as alert-box error.
    undo, leave gds.
  end.
  assign
    varcount = varcount + 1.
  run waitfram-join in this-procedure (substitute("Коррекция НДС в партиях свободной зоны. Обрабатываем товар: &1 &2 &3 &4.", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name),
                                       substitute("Всего обработано товаров: &1.", varcount),
                                       substitute("Время: &1.", string(TIME - vartime, "hh:mm:ss")),
                                       output varoutput-string).
  run waitfram-show in this-procedure (varoutput-string).
  find first bf_sysconf where bf_sysconf.host-code = t-doc.host-code no-lock.
  run update-line in this-procedure (   input "chg_vat":u
                                      , input recid( bf_doc-line )
                                      , input bf_sysconf.cash-pay
                                      , input varoldvat-pc
                                      , input varvat-pc
                                      , input varpurch-list
                                      , input varchange-price
                                      )  no-error.
  if error-status :error then do:
    if return-value <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при обработке товара " skip
        bf_doc-line.artic skip
        bf_doc-line.prod-type skip
        bf_doc-line.prod-code skip
        return-value skip
        trim(error-status :get-message(1))
        view-as alert-box error.
    end.
    undo, leave gds.
  end.
  if available bf_doc-line then do:
    run local-recalc in this-procedure ( input "update":U,
                                         input recid( bf_doc-line ) ) no-error.
    if error-status :error then do:
      message
      vss-workfile vss-revision vss-description skip
      "Ошибка при пересчете строки документа" skip
      return-value skip
      trim( error-status :get-message( 1 ) )
      view-as alert-box error.
      undo, leave gds.
    end.
  end.
end.
end.
run waitfram-hide in this-procedure.
end.
end procedure.
procedure notes-tr:
define variable notes as character no-undo.
assign
  notes = t-doc.PS.
run gbl/d-prompt.w (
    'title=Примечание\'
  + 'type=editor\'
  + 'fillin_width=96\'
  + 'fillin_height=15\'
  + (if pardoc-mode = 'ПРОСМОТР':U then 'readonly=yes\' else '':U)
  , input-output notes).
if pardoc-mode <> 'ПРОСМОТР':U then do:
  if return-value = 'false':u
  then do:
    return .
  end.
  if t-doc.PS <> notes then do:
    do transaction on error undo, return error return-value :
      find t-doc where recid( t-doc ) = pardoc-rec exclusive-lock.
      assign
        t-doc.PS = notes.
    end.
  end.
end.
end procedure.
procedure proc-exit:
parnext-prev = ?.
if pardoc-mode = 'ИЗМЕНЕНИЕ':U or pardoc-mode = 'ДОБАВЛЕНИЕ':U then do:
  if not can-find (first doc-line where doc-line.doc-code = t-doc.doc-code no-lock) then do:
    varlog = yes.
    message "В документе нет строк, поэтому он удаляется." view-as alert-box
      question buttons OK-Cancel update varlog.
    if varlog then do:
      delete t-doc.
      assign pardoc-rec = ?.
      return.
    end.
    else return error.
  end.
  assign frame d-doc t-doc.wrkr t-doc.agnt t-doc.boss .
end.
end procedure.
procedure st-exch-rate:
  define output parameter parexch-code     like ub.trn-doc.exch-code   no-undo.
  define output parameter parexch-rate     like ub.trn-doc.exch-rate   no-undo.
  define output parameter parexch-scale    like ub.trn-doc.exch-scale  no-undo.
  define output parameter parcli-base-rate like ub.parts.cli-base-rate no-undo.
  define output parameter parvat-type      like ub.parts.vat-type      no-undo.
  define output parameter parslt-type      like ub.parts.slt-type      no-undo.
  define variable varcurr-abbr as character no-undo.
  define buffer bf_contract for ub.contract.
  do
  on error undo, return error return-value
  :
    find first tt-chs-parts.
    assign
      parcli-base-rate = tt-chs-parts.cli-base-rate
      parexch-code     = tt-chs-parts.exch-code
      parvat-type      = tt-chs-parts.vat-type
      parslt-type      = tt-chs-parts.slt-type .
    for each tt-chs-parts on error undo, return error return-value :
      if t-doc.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = t-doc.host-code     and
                                    bf_contract.contract-code = t-doc.contract-code no-lock.
        if tt-chs-parts.exch-code <> bf_contract.curr-code then do:
          message "Критическая ошибка." skip
                  "Договору " bf_contract.contract-prn-code " задан в валюте с кодом " bf_contract.curr-code " ." skip
                  "Выбрана партия из свободной зоны: ПН " tt-chs-parts.in-code " Код партии " tt-chs-parts.part-code " Товар " tt-chs-parts.artic tt-chs-parts.prod-type tt-chs-parts.prod-code " в валюте с кодом " tt-chs-parts.exch-code " ."
          view-as alert-box error.
          return error.
        end.
      end.
      else do:
        if tt-chs-parts.exch-code <> parexch-code then do:
          assign
            parexch-code = ?.
        end.
      end.
      if tt-chs-parts.vat-type =  'без':U and
        tt-chs-parts.vat-pc   <> 0              then do:
        message "Критическая ошибка в партии: " skip
                "Объект: " tt-chs-parts.obj-type " " tt-chs-parts.obj-code " " skip
                "Товар: " tt-chs-parts.artic " " tt-chs-parts.prod-type " " tt-chs-parts.prod-code skip
                "ПН: " tt-chs-parts.in-code skip
                "Код партии: " tt-chs-parts.part-code skip
                "Тип НДС в партии имеет тип " tt-chs-parts.vat-type " , а процент НДС в партии установлен " tt-chs-parts.vat-pc " ." skip
        view-as alert-box error.
        return error.
      end.
      if tt-chs-parts.slt-type =  'без':U and
        tt-chs-parts.slt-pc   <> 0              then do:
        message "Критическая ошибка в партии: " skip
                "Объект: " tt-chs-parts.obj-type " " tt-chs-parts.obj-code " " skip
                "Товар: " tt-chs-parts.artic " " tt-chs-parts.prod-type " " tt-chs-parts.prod-code skip
                "ПН: " tt-chs-parts.in-code skip
                "Код партии: " tt-chs-parts.part-code skip
                "Тип НП в партии имеет тип " tt-chs-parts.slt-type " , а процент НП в партии установлен " tt-chs-parts.slt-pc " ." skip
        view-as alert-box error.
        return error.
      end.
      if tt-chs-parts.cli-base-rate <> parcli-base-rate then do:
        assign
          parcli-base-rate = 1.
      end.
    end.
    assign
      parvat-type = ?
      parslt-type = ?.
    if parcli-base-rate = 1 then do:
      for each tt-chs-parts on error undo, return error return-value :
        assign
          tt-chs-parts.price-cli     = tt-chs-parts.price-cli / tt-chs-parts.cli-base-rate
          tt-chs-parts.cli-base-rate = 1
        .
      end.
    end.
    if parexch-code = ? then do:
      for each tt-chs-parts on error undo, return error return-value :
        assign
          tt-chs-parts.exch-code = 1
          tt-chs-parts.price-cli = tt-chs-parts.price-rubl * tt-chs-parts.cli-base-rate
        .
      end.
      assign
        parexch-code = 1.
    end.
    if parvat-type = ? then do:
      for each tt-chs-parts where tt-chs-parts.vat-type <> 'в т. ч.':U on error undo, return error return-value :
        for each tt-clcparts on error undo, return error return-value :
          delete tt-clcparts.
        end.
        for each tt-allsum on error undo, return error return-value :
          delete tt-allsum.
        end.
        create tt-clcparts.
        buffer-copy tt-chs-parts to tt-clcparts.
        run clcprtsl_calc-parts in this-procedure
            (input recid( tt-clcparts ),
            input no,
            input no,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input "":u,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0).
        find first tt-allsum where tt-allsum.sum-type = 'основная_сумма':U.
        assign
          tt-chs-parts.vat-type  = 'в т. ч.':U
          tt-chs-parts.price-cli = tt-chs-parts.price-cli + tt-allsum.vat-cli-acc
        .
      end.
      assign
        parvat-type = 'в т. ч.':U.
    end.
    if parslt-type = ? then do:
      for each tt-chs-parts where tt-chs-parts.slt-type <> 'в т. ч.':U on error undo, return error return-value :
        for each tt-clcparts on error undo, return error return-value :
          delete tt-clcparts.
        end.
        for each tt-allsum on error undo, return error return-value :
          delete tt-allsum.
        end.
        create tt-clcparts.
        buffer-copy tt-chs-parts to tt-clcparts.
        run clcprtsl_calc-parts in this-procedure
            (input recid( tt-clcparts ),
            input no,
            input no,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input "":u,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0,
            input 0).
        find first tt-allsum where tt-allsum.sum-type = 'основная_сумма':U.
        assign
          tt-chs-parts.slt-type  = 'в т. ч.':U
          tt-chs-parts.price-cli = tt-chs-parts.price-cli + tt-allsum.slt-cli-acc
        .
      end.
      assign
        parslt-type = 'в т. ч.':U.
    end.
    if t-doc.contract-code = 0 then do:
      if parexch-code <> 0 then do:
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  parexch-code
  ,input  t-doc.exch-date
  ,output parexch-rate
  ,output parexch-scale
  ,output varcurr-abbr
  )  .
      end.
      else do:
        assign
          parexch-rate  = 1
          parexch-scale = 1
        .
      end.
    end.
    else do:
      assign
        parexch-rate  = t-doc.exch-rate
        parexch-scale = t-doc.exch-scale
      .
    end.
  end.
end procedure.
procedure proc-history :
  define variable loc-ref-list as character no-undo.
  define variable loc-doc-save as recid     no-undo.
  define variable loc-mode     as character no-undo.
  define variable loc#stat     as character no-undo.
  define variable loc#type     as character no-undo.
  define variable loc#internal as logical   no-undo.
  do
  on error undo, return error return-value
  :
    if not available t-doc then do:
      message "Неправильный выбор документа." view-as alert-box.
      return error.
    end.
    assign
      pardoc-rec = recid( t-doc )
    .
define variable vss-include-info79 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_c-documents_all':U
    ,input  'object':U
    ,input  t-doc.host-code
    ,input  t-doc.obj-type
    ,input  t-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    if varlog <> yes then do: return no-apply. end.
    run str/calldocs.w ( input  parparentproc,
                     input  loc-mode,
                     input  loc#stat,
                     input  loc#type,
                     input  ?,
                     input  loc#internal,
                     input  "":U,
                     input  t-doc.ext-doc-type,
                     input  ?,
                     input  recid(t-doc),
                     input t-doc.obj-type,
                     input t-doc.obj-code,
                     output loc-ref-list ).
    apply "ENTRY":U to br in frame d-doc.
  end.
end procedure.
procedure check-reason :
  define variable j_rsn-code like ub.trn-reason.reason-code no-undo.
  assign j_rsn-code = ( input frame d-doc t-doc.reason-code ).
  find first ub.trn-reason no-lock where
             ub.trn-reason.reason-code = j_rsn-code no-error.
  if not available ub.trn-reason then do:
    if j_rsn-code <> ? and j_rsn-code <> 0 then do:
      message "Неверно указано основание (причина) создания документа." view-as alert-box error.
    end.
    assign  rsn-name = "".
    display rsn-name with frame d-doc.
    if j_rsn-code = ? or j_rsn-code = 0 then do:
      assign t-doc.reason-code = 0.
      return.
    end.
    else do:
      return error.
    end.
  end.
  assign  rsn-name = ub.trn-reason.reason-name.
  display rsn-name with frame d-doc.
  assign  frame d-doc t-doc.reason-code.
end procedure.
procedure select-reason :
  define variable j-rsn-code like ub.trn-reason.reason-code no-undo.
  assign j-rsn-code = ( input frame d-doc t-doc.reason-code ).
  run str/trn-reas.w ( input ParParentProc, input 'выбор':U, input-output j-rsn-code ).
  find first ub.trn-reason no-lock where ub.trn-reason.reason-code = j-rsn-code no-error.
  if available ub.trn-reason then do:
    assign  rsn-name          = ub.trn-reason.reason-name
            t-doc.reason-code = ub.trn-reason.reason-code.
    display t-doc.reason-code rsn-name with frame d-doc.
  end.
end procedure.
