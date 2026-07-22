block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp_trn-doc no-undo
field line-num as integer
field doc-code as character
field doc-date as date
field ext-doc-type as character
field cli-type as character
field cli-code as integer
field obj-type as character
field obj-code as integer
field wrkr as integer
field agnt as integer
field boss as integer
field creid as character
field ps as character
field host-code as integer
field contract-code as integer
field pay-code   as integer
field reason-code   as integer
field exch-code  as integer
field exch-rate  as decimal
field exch-scale as integer
field vat-type as character
field price-type as character
field cargo-from as character
field stts as character
field hold-obj-type as character
field hold-obj-code as integer
field ship-num as character
field ship-date as date
index pi line-num doc-code .
define temp-table temp_doc-line no-undo
field line-num    as integer
field doc-code    as character
field gds-code    as integer
field artic       as character
field prod-type   as character
field prod-code   as integer
field cli-qnty    as decimal
field doc-qnty    as decimal
field fact-qnty   as decimal
field price-rubl  as decimal
field price-cli   as decimal
field vat-pc      as decimal
field cons-vat-pc as decimal
field refA        as character
field refB        as character
field beforRefB   as character
field alc-code    as character
field alc-type-code as character
field importer-th as character
field line-num-str as character
index pi
doc-code
line-num
gds-code
index qntyIndex
doc-code
gds-code
alc-code
doc-qnty
.
  define temp-table TempTrnDoc no-undo
    field SuppInDocNo   as character
    field stts          as character
    field ext-doc-type  as character
    field doc-date      as date
    field cli-type      as character
    field cli-code      as integer
    field obj-type      as character
    field obj-code      as integer
    field ContractID    as integer
    field ContractNum   as character
    field vat-type      as character
    field tot-transp    as decimal
    field tot-other     as decimal
    field wrkr          as integer
    field agnt          as integer
    field boss          as integer
    field pay-code      as integer
    field discnt-type   as character
    field discnt-pc     as decimal
    field user-id       as character
    field reason-code   as integer
    field ps            as character
    field hold-obj-type as character
    field hold-obj-code as integer
    field ship-num      as character
    field ship-date     as date
    index pi SuppInDocNo .
  define temp-table TempDocLine no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field doc-qnty     as decimal
    field fact-qnty    as decimal
    field price-rubl   as decimal
    field vat-pc       as decimal
    field b-code       as character
    index pi
    SuppInDocNo
    line-num
    gds-code
    .
  define temp-table TempGdsDtl no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field prt-code     as integer
    field b-code       as integer
    field doc-qnty     as decimal
    field price-rubl   as decimal
    index pi
    SuppInDocNo
    line-num
    gds-code
    prt-code
    .
  define temp-table TempParts no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field part-code    as character
    field out-code     as character
    index pi
    SuppInDocNo
    line-num
    gds-code
    part-code
    .
  define temp-table TempDocAttr no-undo
    field SuppInDocNo  as character
    field attr-code    as character
    field attr-value   as character
    index pi
    SuppInDocNo
    attr-code
    .
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  PARAMETER TABLE FOR  temp_trn-doc.
define input  PARAMETER TABLE FOR  temp_doc-line.
define input  PARAMETER TABLE FOR  TempGdsDtl.
define input  PARAMETER TABLE FOR  TempParts.
define input  PARAMETER TABLE FOR  TempDocAttr.
define output parameter p-ok-doc as integer   no-undo .
define output parameter ERROR_ as logical no-undo initial false .
define variable vss-revision    as character no-undo init "$Revision: 288743b2d1c0, 2956, rls $":U .
define variable vss-author      as character no-undo init "$Author: VRukavishnikov $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:40 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: websrv_trn-doc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/websrv_trn-doc.p $":U .
define variable vss-description as character no-undo init "Импорт накладных из временной таблицы".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
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
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-trn-doc  no-undo like ub.trn-doc.
define temp-table tt-doc-line no-undo like ub.doc-line
field cst-code like ub.trn-doc.cst-code
.
define temp-table tt-doc-line-attr no-undo like ub.doc-line-attr.
define temp-table tt-gds-dtl  no-undo like ub.gds-dtl.
define temp-table tt-parts    no-undo like ub.parts.
procedure lib-trn_copy-inqu :
define input parameter pardoc-code    like ub.trn-doc.doc-code    no-undo.
define input parameter pardoc-type    like ub.trn-doc.doc-type    no-undo.
define input parameter parstatus_     like ub.trn-doc.status_     no-undo.
define input parameter parinternal    like ub.trn-doc.internal    no-undo.
define input parameter parcli-type    like ub.trn-doc.cli-type    no-undo.
define input parameter parcli-code    like ub.trn-doc.cli-code    no-undo.
define input parameter pardiscnt-type like ub.trn-doc.discnt-type no-undo.
define input parameter partot-calc    like ub.trn-doc.tot-calc    no-undo.
define input parameter pardiscnt-pc   like ub.trn-doc.discnt-pc   no-undo.
define input parameter paragnt        like ub.trn-doc.agnt        no-undo.
define input parameter parboss        like ub.trn-doc.boss        no-undo.
define input parameter parwrkr        like ub.trn-doc.wrkr        no-undo.
define input parameter parbase-rate   like ub.trn-doc.base-rate   no-undo.
define input parameter parbase-scale  like ub.trn-doc.base-scale  no-undo.
define input parameter parexch-code   like ub.trn-doc.exch-code   no-undo.
define input parameter parvat-type    like ub.trn-doc.vat-type    no-undo.
define input parameter pardstdoc-code     like ub.trn-doc.doc-code    no-undo.
define input parameter parinp-discnt-type as   logical                no-undo.
define input parameter parinp-discnt-pc   like ub.trn-doc.discnt-pc   no-undo.
define input parameter parinp-agnt        like ub.trn-doc.agnt        no-undo.
define input parameter parinp-boss        like ub.trn-doc.boss        no-undo.
define input parameter parinp-wrkr        like ub.trn-doc.wrkr        no-undo.
define input parameter parinp-base-rate   like ub.trn-doc.base-rate   no-undo.
define input parameter parinp-base-scale  like ub.trn-doc.base-scale  no-undo.
define input parameter parcash-pay        like ub.sysconf.cash-pay    no-undo.
define input parameter parglob-base-code  like ub.sysconf.base-code   no-undo.
define input parameter table for tt-doc-line.
define input parameter table for tt-gds-dtl.
define input parameter table for tt-parts.
define input parameter paruse-parts       as   logical                no-undo.
define input parameter parall-qnty        as   logical                no-undo.
define input parameter parfix-price       as   logical                no-undo.
define buffer crt_trn-doc  for ub.trn-doc.
define buffer crt_goods    for ub.goods.
define buffer crt_doc-line for ub.doc-line.
define buffer crt_gds-dtl  for ub.gds-dtl.
define variable end-price    as   logical              no-undo.
define variable real-type    like ub.goods.gds-type    no-undo.
define variable legal-node   like ub.gds-prt.node-code no-undo.
define variable chg-qnty     like ub.gds-dtl.fact-qnty no-undo.
define variable varchg-qnty  like ub.gds-dtl.fact-qnty no-undo.
define variable varfact-qnty like ub.gds-dtl.fact-qnty no-undo.
define variable g-log        as   logical              no-undo.
define variable mem-qnty like chg-qnty no-undo.
define variable dflt-cd as character no-undo .
c-l:
do on error undo, return error return-value :
find first crt_trn-doc where crt_trn-doc.doc-code = pardstdoc-code.
assign
    paruse-parts = false
    .
assign
  end-price = no.
if parinp-discnt-type = yes and
   parinp-discnt-pc   = 0   and
   can-do ('процент,карта,группа,сумма,строка,прайс-лист':U, pardiscnt-type)
   then do:
  assign
    crt_trn-doc.tot-calc    = partot-calc
    crt_trn-doc.discnt-pc   = pardiscnt-pc
    crt_trn-doc.discnt-type = pardiscnt-type.
end.
if parinp-agnt = ? then do:
  assign
    crt_trn-doc.agnt = paragnt.
end.
if parinp-boss = ? then do:
  assign
    crt_trn-doc.boss = parboss.
end.
if parinp-wrkr = ? then do:
  assign
    crt_trn-doc.wrkr = parwrkr.
end.
if parinp-base-rate  = ? then do:
  assign
    crt_trn-doc.base-rate  = parbase-rate.
end.
if parinp-base-scale = ? then do:
  assign
    crt_trn-doc.base-scale = parbase-scale.
end.
find first tt-doc-line where tt-doc-line.doc-code = pardoc-code no-lock no-error.
if available tt-doc-line then do:
  find crt_goods where crt_goods.artic     = tt-doc-line.artic
                   and crt_goods.prod-type = tt-doc-line.prod-type
                   and crt_goods.prod-code = tt-doc-line.prod-code no-lock.
  if crt_goods.gds-type = 'у':U and
     (crt_trn-doc.doc-type <> 'рас':U or crt_trn-doc.internal) then do:
    return error "В данный документ нельзя копировать услуги.".
  end.
  assign
    real-type = crt_goods.gds-type.
  find first crt_doc-line where crt_doc-line.doc-code = crt_trn-doc.doc-code no-lock no-error.
  if available crt_doc-line then do:
    find crt_goods where crt_goods.artic     = crt_doc-line.artic
                     and crt_goods.prod-type = crt_doc-line.prod-type
                     and crt_goods.prod-code = crt_doc-line.prod-code no-lock.
    if crt_goods.gds-type <> real-type then do:
      return error "Услуги и товары не могут быть добавлены в один и тот же документ.".
    end.
  end.
  else do:
    assign
      crt_trn-doc.office = (if real-type = 'у':U then yes else no).
  end.
end.
r-l:
for each tt-doc-line where tt-doc-line.doc-code = pardoc-code no-lock on error undo, return error return-value :
  find crt_goods where crt_goods.artic     = tt-doc-line.artic
                   and crt_goods.prod-type = tt-doc-line.prod-type
                   and crt_goods.prod-code = tt-doc-line.prod-code no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclno in g#lib-trn
   (
    input crt_trn-doc.doc-code
   ,input crt_trn-doc.obj-type
   ,input crt_trn-doc.obj-code
   ,input crt_goods.artic
   ,input crt_goods.prod-type
   ,input crt_goods.prod-code
   ,input crt_goods.gds-name
   ,input crt_goods.prt-root
   ,input ?
   ,input ?
   ,input parcash-pay      ) no-error.
  if error-status:error then do:
    undo c-l, return error return-value.
  end.
  if return-value = "next" then do:
    next r-l.
  end.
  find first crt_doc-line where crt_doc-line.doc-code  = crt_trn-doc.doc-code and
                                crt_doc-line.artic     = crt_goods.artic      and
                                crt_doc-line.prod-type = crt_goods.prod-type  and
                                crt_doc-line.prod-code = crt_goods.prod-code .
  for each tt-gds-dtl where tt-gds-dtl.prod-type = tt-doc-line.prod-type and
                            tt-gds-dtl.prod-code = tt-doc-line.prod-code and
                            tt-gds-dtl.artic     = tt-doc-line.artic     and
                            tt-gds-dtl.doc-code  = tt-doc-line.doc-code no-lock
                            break by tt-gds-dtl.artic
                                  by tt-gds-dtl.prod-type
                                  by tt-gds-dtl.prod-code
                            :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_lgl-node in g#lib-trn
  ( input  tt-gds-dtl.artic
   ,input  tt-gds-dtl.prod-type
   ,input  tt-gds-dtl.prod-code
   ,input  tt-gds-dtl.prt-code
   ,input  tt-doc-line.obj-type
   ,input  tt-doc-line.obj-code
   ,output legal-node
  ) no-error .
    if error-status:error then do:
       undo c-l, return error substitute ("&1 &2", return-value, error-status:get-message (1)).
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input crt_trn-doc.obj-code
   ,input crt_trn-doc.obj-type
   ,input crt_trn-doc.doc-code
   ,input crt_goods.artic
   ,input crt_goods.prod-code
   ,input crt_goods.prod-type
   ,input legal-node
   ,input yes
  ) no-error .
     if error-status:error then do:
        return error substitute ("Ошибка при создании признака &1.", return-value) .
     end.
     find first crt_gds-dtl where crt_gds-dtl.doc-code  = crt_trn-doc.doc-code and
                                  crt_gds-dtl.artic     = crt_goods.artic      and
                                  crt_gds-dtl.prod-code = crt_goods.prod-code  and
                                  crt_gds-dtl.prod-type = crt_goods.prod-type  and
                                  crt_gds-dtl.prt-code  = legal-node.
    assign
      crt_gds-dtl.ov             = parfix-price
      crt_gds-dtl.price-base     = tt-gds-dtl.price-base
      crt_gds-dtl.price-rubl     = tt-gds-dtl.price-rubl
      crt_gds-dtl.new-price-sale = tt-gds-dtl.new-price-sale
      .
    if can-do ('процент,карта,группа,сумма,строка,прайс-лист':U, pardiscnt-type) then do:
      assign
        crt_gds-dtl.discnt-base  = tt-gds-dtl.discnt-base
        crt_gds-dtl.discnt-rubl  = tt-gds-dtl.discnt-rubl
        crt_gds-dtl.discnt-pc    = tt-gds-dtl.discnt-pc
        crt_gds-dtl.discnt-type  = tt-gds-dtl.discnt-type.
    end.
    if end-price then do:
      assign
        crt_gds-dtl.ov             = yes
        crt_gds-dtl.price-base     = tt-gds-dtl.price-base - tt-gds-dtl.discnt-base
        crt_gds-dtl.discnt-base    = 0
        crt_gds-dtl.price-rubl     = tt-gds-dtl.price-rubl - tt-gds-dtl.discnt-rubl
        crt_gds-dtl.discnt-rubl    = 0
        crt_gds-dtl.discnt-pc      = 0
        crt_gds-dtl.discnt-type    = yes.
    end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(crt_gds-dtl)
  , input no
  , input ?
  ) no-error.
        if error-status:error then do:
          undo c-l, return error return-value.
        end.
    if (crt_gds-dtl.price-rubl = ? or crt_gds-dtl.price-base = ?) and
       crt_gds-dtl.ov then do:
      undo c-l, return error "При добавлении с фиксацией взятых из документа - источника цен требуется, чтобы ни одна из цен источника не была '?'. Добавляйте с текущими ценами продажи или выберите другой источник.".
    end.
    if paruse-parts then do:
       if first-of (tt-gds-dtl.prod-code) then do:
         for each tt-parts :
           assign
             chg-qnty = tt-parts.fact-qnty
             mem-qnty = chg-qnty.
           assign
           crt_doc-line.doc-qnty  = crt_doc-line.doc-qnty + chg-qnty
           crt_doc-line.fact-qnty = crt_doc-line.doc-qnty.
         end.
         assign
           crt_gds-dtl.doc-qnty   = crt_gds-dtl.doc-qnty  + tt-gds-dtl.fact-qnty
           crt_gds-dtl.fact-qnty  = crt_gds-dtl.doc-qnty.
         assign
           varchg-qnty  = varchg-qnty  + tt-gds-dtl.fact-qnty
           varfact-qnty = varfact-qnty + tt-gds-dtl.fact-qnty.
         if crt_gds-dtl.doc-qnty = 0 then do:
           delete crt_gds-dtl.
         end.
       end.
    end.
    else do:
      assign
        chg-qnty = tt-gds-dtl.fact-qnty
        mem-qnty = chg-qnty.
      assign
        crt_doc-line.doc-qnty  = crt_doc-line.doc-qnty + chg-qnty
        crt_gds-dtl.doc-qnty   = crt_gds-dtl.doc-qnty  + chg-qnty
        crt_gds-dtl.fact-qnty  = crt_gds-dtl.doc-qnty
        crt_doc-line.fact-qnty = crt_doc-line.doc-qnty.
      assign
      varchg-qnty  = varchg-qnty  + chg-qnty
      varfact-qnty = varfact-qnty + tt-gds-dtl.fact-qnty.
      if crt_gds-dtl.doc-qnty = 0 then do:
        delete crt_gds-dtl.
      end.
    end.
  end.
  if crt_doc-line.doc-qnty = 0 then do:
    delete crt_doc-line.
  end.
end.
end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable  ora-icli_ver-stts-client as logical   no-undo  init true .
procedure who-cli-ora :
define input  parameter p-cli-code-ora as integer   no-undo .
define output parameter p-cli-type as character no-undo .
define output parameter p-cli-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
  if length (string(p-cli-code-ora))  <> 9 then do:
     return error substitute ("Не верный формат кода КОНТРАГЕНТА: &1" , p-cli-code-ora ) .
  end.
  if string(p-cli-code-ora) begins "1" or
     string(p-cli-code-ora) begins "2" or
     string(p-cli-code-ora) begins "4" then do:
      p-cli-type = 'орг':U .
      p-cli-code = p-cli-code-ora  .
  end.
  else do:
    if string(p-cli-code-ora) begins "3" then do:
      p-cli-type = 'чел':U .
      p-cli-code = p-cli-code-ora  .
    end.
    else do:
       return error substitute ("Не верный формат кода КОНТРАГЕНТА: &1 ( первый код )" , p-cli-code-ora ) .
    end.
  end.
  define buffer buf_clients for ub.clients  .
  find first buf_clients no-lock where
             buf_clients.obj-type = p-cli-type and
             buf_clients.obj-code = p-cli-code
             no-error .
      if error-status :error then do:
          return error substitute
          ( "Нет такого контрагента: &1 ( &2 &3 )" ,
              p-cli-code-ora ,
              p-cli-type ,
              p-cli-code ) .
      end.
      if ora-icli_ver-stts-client then do:
          if buf_clients.stts > 0 then do:
              return error substitute
              ( "Контрагент: &1 ( &2 &3 ) СТАТУС неактивный !!!" ,
                  p-cli-code-ora ,
                  p-cli-type ,
                  p-cli-code ) .
          end.
      end.
  end.
end procedure.
procedure ora-ver-goods :
define input  parameter p-gds-code as integer   no-undo .
define buffer buf_goods for ub.goods  .
define variable my-message as character no-undo .
  do
  on error undo, return error return-value
  :
        find first buf_goods no-lock where
                   buf_goods.gds-code = p-gds-code no-error .
            if error-status :error then do:
                my-message = substitute("Нет товара с кодом &1" ,  p-gds-code) .
                undo, return error my-message.
            end.
          if buf_goods.stts > 0 then do:
            assign
              my-message =  substitute(" Товара &1 УДАЛЕН" , buf_goods.gds-code  ) .
              undo, return error my-message.
          end.
  end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
g#auto = true .
define temp-table tt2-doc-line      no-undo like lib-trn_ret-line.
define temp-table tt2-doc-line-attr no-undo like lib-trn_ret-line-attr.
define temp-table anlz-bc no-undo
field b-c as integer
index pi b-c.
define variable v-end-message as character no-undo .
define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-in-ov as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time  as integer   no-undo .
define variable v-cntxt-load-time  as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-specif as logical   no-undo .
define buffer new_trn-doc  for ub.trn-doc  .
define buffer new_doc-line for ub.doc-line .
define buffer new_gds-dtl  for ub.gds-dtl .
define buffer t_trn-doc  for ub.trn-doc  .
define buffer t_doc-line for ub.doc-line .
define buffer t_gds-dtl  for ub.gds-dtl .
define buffer buf_goods  for ub.goods .
define buffer buf_contract for ub.contract  .
define variable parrec-doc      as recid    no-undo .
define variable parrecalc-price as logical  no-undo init false .
define variable parhandle       as handle   no-undo .
define variable v-root-node     as integer  no-undo .
define variable par-doc-code as character no-undo .
define variable p-type             as character no-undo .
define variable v-stroka-protocol  as character no-undo .
define variable v-protocol-date    as date      no-undo .
define variable v-protocol-time    as integer   no-undo .
define variable v-logical          as logical   no-undo .
define variable n-d as character no-undo .
define variable v-ret-supp as logical   no-undo .
define variable v-doc-type as character no-undo .
define variable v-purch-code-ch as character no-undo .
define variable v-purch-code as integer   no-undo .
define variable v-purch-code-name as character no-undo .
define variable v-discnt-type  as character no-undo .
define variable v-status_     as character no-undo .
define variable v-print-rubl as logical   no-undo .
define variable v-curr-r-b as character no-undo .
define variable vt-host-code as integer   no-undo .
define variable vt-obj-type as character no-undo .
define variable vt-obj-code      as integer   no-undo .
define variable line-rec as recid no-undo .
define buffer bufo_clients for ub.clients  .
define variable  k as integer   no-undo .
define variable v-str-txt as character no-undo .
define variable v-fact-order as decimal   no-undo .
define variable v-plt-id as integer   no-undo .
define variable v-plt-db-num as integer   no-undo .
define variable v-pdf-id as integer   no-undo .
define variable v-pdf-db as integer   no-undo .
define variable v-sale-price-base as decimal   no-undo .
define variable v-sale-price-rubl as decimal   no-undo .
define variable v-road-tax-base as decimal   no-undo .
define variable v-road-tax-rubl as decimal   no-undo .
define variable v-excise-base as decimal   no-undo .
define variable v-excise-rubl as decimal   no-undo .
define variable v-main-b-code as integer   no-undo .
define variable is-tsd as logical no-undo .
define variable is-egais as logical no-undo .
define variable is-unit-error   as logical no-undo .
define variable v-internal      as logical no-undo .
MAIN-BLOCK:
DO
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    run get-db-num in parparentproc (output v-cntxt-db-num ) .
    run get-userid in parparentproc (output v-cntxt-userid ) .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U then v-print-rubl = false .
    else v-print-rubl = true .
p-ok-doc = 0 .
for each  temp_trn-doc :
  run clear-tt .
  find first bufo_clients no-lock where
             bufo_clients.obj-type  = temp_trn-doc.obj-type  and
             bufo_clients.obj-code  = temp_trn-doc.obj-code  no-error .
      if error-status :error then do:
              assign
              v-end-message =  substitute(" Не найден объект &1 &2 " , temp_trn-doc.obj-type , temp_trn-doc.obj-code)
              .
              ERROR_ = true .
              return v-end-message.
      end.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  temp_trn-doc.obj-type
  ,input  temp_trn-doc.obj-code
  ,output temp_trn-doc.host-code
  ) no-error .
      if error-status :error then do:
        assign
            v-end-message =  substitute("Не верно указан объект &1 &2 " ,
            temp_trn-doc.obj-type ,
            temp_trn-doc.obj-code ).
        ERROR_ = true .
        return v-end-message.
      end.
      assign
        vt-host-code          = temp_trn-doc.host-code
        vt-obj-type           = temp_trn-doc.obj-type
        vt-obj-code           = temp_trn-doc.obj-code
        v-cntxt-host-code-obj = temp_trn-doc.host-code
        v-cntxt-obj-code      = temp_trn-doc.obj-code
        v-cntxt-obj-type      = temp_trn-doc.obj-type
        .
        if temp_trn-doc.vat-type = "" or
           temp_trn-doc.vat-type = ? then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
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
      for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'type-vat' then v-value-integer = thbjattr_thbj-attr.property-value-integer.
      end.
          case v-value-integer:
          when 1 or when ? then do:
            assign
              temp_trn-doc.vat-type = 'в т. ч.':U.
          end.
          when 2 then do:
            assign
              temp_trn-doc.vat-type = 'нет':U.
          end.
          when 3 then do:
            assign
              temp_trn-doc.vat-type = 'без':U.
          end.
          otherwise do:
              v-end-message =  substitute(" Не верно задан атрибут 'Тип заведения НДС' (type-vat). &1 &2 &3" , temp_trn-doc.obj-type , temp_trn-doc.obj-code , v-value-integer ) .
              ERROR_ = true .
              return v-end-message.
          end.
          end case.
      end.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  temp_trn-doc.obj-type
  ,input  temp_trn-doc.obj-code
  ,output to-day
  ) no-error .
      if error-status :error then do:
              assign
              v-end-message =  substitute(" Ошибка &1 &2 &3 " , temp_trn-doc.obj-type , temp_trn-doc.obj-code , error-status :get-message(1) )
              .
              ERROR_ = true .
              return v-end-message.
      end.
     if vt-host-code <>   v-cntxt-host-code-obj then do:
                  assign
                  v-end-message =  substitute(" Не верно указан код фирмы: &1 ( по объектам должен быть :&2) " , temp_trn-doc.host-code , v-cntxt-host-code-obj  )
                  .
                  ERROR_ = true .
                  return v-end-message.
     end.
    find first buf_contract no-lock where
               buf_contract.contract-code =  temp_trn-doc.contract-code and
               buf_contract.host-code     =  temp_trn-doc.host-code
               no-error .
   v-specif = false .
   if temp_trn-doc.contract-code  > 0 then do:
      find first  ub.contract-specif no-lock where
                  ub.contract-specif.contract-num = temp_trn-doc.contract-code and
                  ub.contract-specif.host-code    = temp_trn-doc.host-code
                  no-error .
      if available ub.contract-specif then
      assign
        v-specif = true
        temp_trn-doc.vat-type = ub.contract-specif.VAT-type
      .
   end.
   if temp_trn-doc.ext-doc-type = 'ie':U then do:
      if available buf_contract then do:
         if buf_contract.curr-code <> temp_trn-doc.exch-code then do:
                    v-end-message =  substitute("По договору &3   ожидалась валюта &1  пришла &2 " ,
                    buf_contract.curr-code,
                    temp_trn-doc.exch-code,
                    temp_trn-doc.contract-code ) .
                    run pcall-log-file in p-log-handle (input v-end-message) .
                    ERROR_ = true .
                    return v-end-message.
      end.
      end.
   end.
   if not (temp_trn-doc.cli-type = 'орг':U or temp_trn-doc.cli-type = 'чел':U or temp_trn-doc.cli-type = 'скл':U or temp_trn-doc.cli-type = 'маг':U)
   then do:
     run who-cli-ora in this-procedure (
       input  temp_trn-doc.cli-code ,
       output temp_trn-doc.cli-type ,
       output temp_trn-doc.cli-code
       ) no-error .
     if error-status :error then return error return-value .
   end.
  if temp_trn-doc.ext-doc-type <> 'ie':U
  then do:
     temp_trn-doc.exch-code = 0 .
     temp_trn-doc.exch-rate  = 1.
     temp_trn-doc.exch-scale = 1.
  end.
  if temp_trn-doc.ext-doc-type = 'ep':U
  then do:
      find first ub.contract no-lock where ub.contract.contract-code = temp_trn-doc.contract-code
                                       and ub.contract.host-code = temp_trn-doc.host-code
                                       and ub.contract.contract-date-end >= temp_trn-doc.doc-date
                                       and ub.contract.status_ = 'тек':U no-error.
      if not available ub.contract
      then do :
          v-end-message =  "Ошибка. Не найден договор с внутреннем номером " + string(temp_trn-doc.contract-code) + ". Или его срок действия истек"
                            + chr(10) +
                           "Возврат поставщику не может быть оформлен без договора" .
          ERROR_ = true .
          undo, return v-end-message.
      end.
  end.
  if temp_trn-doc.exch-code = ? then do:
      assign
        temp_trn-doc.exch-code = 0
        temp_trn-doc.exch-rate  = 1
        temp_trn-doc.exch-scale = 1
      .
      v-end-message =  substitute("Предупреждение !!! Не верно введена валюта ПОСТВЩИКА код &1 , меняю на национальную " ,              temp_trn-doc.exch-code   ) .
      run pcall-log-file in p-log-handle (input v-end-message) .
  end.
  if temp_trn-doc.exch-rate  = 0 or
     temp_trn-doc.exch-rate  = ? then do:
          assign
            temp_trn-doc.exch-code = 0
            temp_trn-doc.exch-rate  = 1
            temp_trn-doc.exch-scale = 1
          .
      v-end-message =  substitute("Предупреждение !!! Не верно введен курс = &2 валюты ПОСТВЩИКА код &1 , меняю на национальную " ,              temp_trn-doc.exch-code , temp_trn-doc.exch-rate ) .
      run pcall-log-file in p-log-handle (input v-end-message) .
  end.
  if temp_trn-doc.exch-scale  = 0 or
     temp_trn-doc.exch-scale  = ? then do:
          assign
            temp_trn-doc.exch-code = 0
            temp_trn-doc.exch-rate  = 1
            temp_trn-doc.exch-scale = 1
          .
      v-end-message =  substitute("Предупреждение !!! Не верно введен масштаб = &2 валюты ПОСТВЩИКА код &1 , меняю на национальную " ,              temp_trn-doc.exch-code , temp_trn-doc.exch-scale ) .
      run pcall-log-file in p-log-handle (input v-end-message) .
  end.
    find first ub.currency where ub.currency.curr-code = temp_trn-doc.exch-code no-error .
    if error-status :error then do:
              v-end-message =  substitute("Нет валюты с кодом &1  (&2)" ,
              temp_trn-doc.exch-code , error-status :get-message(1)   ) .
            run pcall-log-file in p-log-handle (input v-end-message) .
            ERROR_ = true .
            return v-end-message.
        end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in this-procedure
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
    case temp_trn-doc.ext-doc-type :
      when 'ee':U then do:
       assign
          v-ext-doc-type = 'ee':U
          v-doc-type     = 'рас':U
          v-ret-supp     = false
          v-discnt-type    = 'процент':U
          v-status_        = 'запрос':U
          v-internal       = false
          .
      end.
      when 'ie':U then do:
       assign
          v-ext-doc-type   = 'ie':U
          v-doc-type = 'при':U
          v-ret-supp     = false
          v-status_ = 'накл':U
          v-discnt-type    = ""
          v-internal       = false
          .
      end.
      when 'ep':U then do:
       assign
          v-ext-doc-type   = 'ep':U
          v-doc-type = 'рас':U
          v-ret-supp     = true
          v-status_ = 'накл':U
          v-discnt-type    = 'процент':U
          v-internal       = false
          .
      end.
      when 're':U then do:
       assign
          v-ext-doc-type   = 're':U
          v-doc-type = 'возврат':U
          v-ret-supp     = false
          v-status_ = 'накл':U
          v-discnt-type    = 'процент':U
          v-internal       = false
          .
      end.
      when 'ev':U then do:
       assign
          v-ext-doc-type = 'ev':U
          v-doc-type     = 'рас':U
          v-ret-supp     = false
          v-discnt-type    = 'процент':U
          v-status_        = 'запрос':U
          v-internal       = true
          .
      end.
      otherwise do:
          assign
          v-end-message =  substitute(" Не верный расширенный тип документа &1 &2 &3 &4" , temp_trn-doc.ext-doc-type , temp_trn-doc.obj-type , temp_trn-doc.obj-code , temp_trn-doc.doc-code )
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
          ERROR_ = true .
          return v-end-message.
      end.
    end case.
define buffer buf_sysconf for ub.sysconf  .
find first buf_sysconf where buf_sysconf.host-code = v-cntxt-host-code-obj no-lock no-error .
if error-status :error then do:
          assign
          v-end-message =  substitute(" Не верный расширенный тип документа &1 &2 &3 &4" , temp_trn-doc.ext-doc-type , temp_trn-doc.obj-type , temp_trn-doc.obj-code , temp_trn-doc.doc-code )
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
          undo, return error v-end-message.
end.
assign
  v-cntxt-cash-pay   = buf_sysconf.cash-pay
  v-cntxt-base-code  = buf_sysconf.base-code
  v-cntxt-in-ov      = buf_sysconf.in-ov
  v-cntxt-rsrv-time  = buf_sysconf.rsrv-time
  v-cntxt-load-time  = buf_sysconf.load-time
  v-cntxt-holidays   = buf_sysconf.holidays
  v-cntxp-out-pay    = buf_sysconf.out-pay
.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in this-procedure
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
    run doc-code in this-procedure
      ( input  "main":U,
        input  temp_trn-doc.obj-type,
        input  temp_trn-doc.obj-code,
        input  ? ,
        output n-d ) no-error.
    if error-status:error then do:
      v-end-message =  "Ошибка при генерации номера документа. chip"  + return-value  + error-status :get-message(1) .
      run pcall-log-file in p-log-handle (input v-end-message) .
      ERROR_ = true .
      undo, return v-end-message.
    end.
    create  tt-trn-doc.
    buffer-copy  temp_trn-doc  to    tt-trn-doc
      assign
      tt-trn-doc.status_              = "temp"
      tt-trn-doc.doc-code             = n-d
      tt-trn-doc.doc-date             = temp_trn-doc.doc-date
      tt-trn-doc.doc-type             = v-doc-type
      tt-trn-doc.internal             = v-internal
      tt-trn-doc.cr-db-num            = v-cntxt-db-num
      tt-trn-doc.vat-type             = temp_trn-doc.vat-type
      tt-trn-doc.slt-type             = 'без':U
      tt-trn-doc.office               = false
      tt-trn-doc.fact-num             = 0
      tt-trn-doc.out-code             = temp_trn-doc.doc-code
      tt-trn-doc.PS                   = substitute("&1 &2 &3 &5&4 ", temp_trn-doc.doc-code , string(temp_trn-doc.doc-date, "99/99/9999") , temp_trn-doc.creid ,temp_trn-doc.ps ,chr(10) )
      tt-trn-doc.creid                = temp_trn-doc.creid
      tt-trn-doc.flag_                = false
      tt-trn-doc.ext-doc-type         = v-ext-doc-type
      tt-trn-doc.discnt-type          = v-discnt-type
      tt-trn-doc.ret-supp             = v-ret-supp
      tt-trn-doc.print-rubl           = v-print-rubl
    .
    if tt-trn-doc.hold-obj-type <> "" and tt-trn-doc.hold-obj-type <> ?
    and tt-trn-doc.hold-obj-code <> 0 and tt-trn-doc.hold-obj-code <> ?
    then do :
        assign
            tt-trn-doc.hold-doc-code-child  = "hold":u
            tt-trn-doc.hold-doc-code-parent = "hold":u
        .
    end.
    else do :
        assign
            tt-trn-doc.hold-doc-code-child  = "no-hold":u
            tt-trn-doc.hold-doc-code-parent = "no-hold":u
        .
    end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-trn-doc.obj-type
  ,input  tt-trn-doc.obj-code
  ,output tt-trn-doc.host-code
  )  .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  tt-trn-doc.host-code
  ,input  tt-trn-doc.doc-date
  ,output tt-trn-doc.base-rate
  ,output tt-trn-doc.base-scale
  )  .
    run pcall-log-file in p-log-handle ( input "n-d=" + n-d ) .
    if v-doc-type     = 'рас':U then do:
      if tt-trn-doc.contract-code > 0 then do:
        find first buf_contract no-lock where
                   buf_contract.contract-code = tt-trn-doc.contract-code and
                   buf_contract.host-code     = tt-trn-doc.host-code no-error .
         if error-status :error then do:
            v-end-message =  substitute("Нет договора  фирма:&1 номер:&2  &3 &4" , tt-trn-doc.host-code , tt-trn-doc.contract-code , return-value , error-status :get-message(1)  ) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            undo, return v-end-message.
         end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_purchcon in g#lib-trn3
( input tt-trn-doc.host-code
, input tt-trn-doc.contract-code
, output v-purch-code-ch
, output v-purch-code-name
) .
          v-purch-code = integer (v-purch-code-ch) .
      end.
      else do:
            if lookup (string(buf_sysconf.purch-code), '1,2,3':U) = 0 then do:
               v-end-message =   substitute("Неверный код типа приобретения по умолчанию &1 _sysconf " ,buf_sysconf.purch-code ) .
               run pcall-log-file in p-log-handle ( input v-end-message ) .
               ERROR_ = true .
               undo, return v-end-message.
            end.
            v-purch-code = buf_sysconf.purch-code .
      end.
      if lookup (string(buf_sysconf.purch-code), '1,2,3':U) = 0 then do:
               v-end-message =  "Неверный код типа приобретения по умолчанию. _sysconf".
               run pcall-log-file in p-log-handle ( input v-end-message ) .
               ERROR_ = true .
               undo, return v-end-message.
      end.
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
,input buf_sysconf.purch-code
) no-error
.
      .
    if error-status :error then do:
        v-end-message =  substitute("Ошибка при создании шапки документа  &1 &2 &3" , temp_trn-doc.doc-code , return-value , error-status :get-message(1)  ) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        ERROR_ = true .
        undo, return v-end-message.
    end.
    find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
    if not available new_trn-doc then do:
      v-end-message = substitute(" Ошибка &1  &2" , error-status :get-message(1)  , return-value) .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      ERROR_ = true .
      undo, return v-end-message.
    end.
    assign
        new_trn-doc.contract-code  = tt-trn-doc.contract-code
        new_trn-doc.exch-rate  = tt-trn-doc.exch-rate
        new_trn-doc.exch-scale = tt-trn-doc.exch-scale
        new_trn-doc.exch-date  = to-day
        new_trn-doc.exch-code  = tt-trn-doc.exch-code
        new_trn-doc.reason-code = tt-trn-doc.reason-code
        new_trn-doc.status_    = v-status_
        new_trn-doc.flag_      = false
        new_trn-doc.print-rubl = v-print-rubl
        new_trn-doc.agnt  = tt-trn-doc.agnt
        new_trn-doc.boss  = tt-trn-doc.boss
        new_trn-doc.wrkr  = tt-trn-doc.wrkr
        new_trn-doc.hold-obj-type = tt-trn-doc.hold-obj-type
        new_trn-doc.hold-obj-code = tt-trn-doc.hold-obj-code
        parrec-doc = recid (new_trn-doc)
    .
    if new_trn-doc.hold-obj-type <> "" and new_trn-doc.hold-obj-type <> ?
    and new_trn-doc.hold-obj-code <> 0 and new_trn-doc.hold-obj-code <> ?
    then do :
        assign
            new_trn-doc.hold-doc-code-child  = "hold":u
            new_trn-doc.hold-doc-code-parent = "hold":u
        .
    end.
    else do :
        assign
            new_trn-doc.hold-doc-code-child  = "no-hold":u
            new_trn-doc.hold-doc-code-parent = "no-hold":u
        .
    end.
  if (new_trn-doc.ext-doc-type = 'ie':U or new_trn-doc.ext-doc-type = 'ee':U or new_trn-doc.ext-doc-type = 'ep':U)
    then
  do:
    find first ub.shift-obj no-lock
      where ub.shift-obj.obj-type = new_trn-doc.obj-type
      and ub.shift-obj.obj-code = new_trn-doc.obj-code
      and ub.shift-obj.status_  = 'тек':U
      no-error .
    if available ub.shift-obj then
    do:
      assign
        new_trn-doc.shift-num  = ub.shift-obj.shift-num
        new_trn-doc.shift-name = ub.shift-obj.shift-name
        new_trn-doc.shift-date = ub.shift-obj.shift-date
        .
    end.
  end.
  k = 0 .
  for each  temp_doc-line  no-lock  where
            temp_doc-line.doc-code = temp_trn-doc.doc-code by temp_doc-line.line-num :
      find first buf_goods where buf_goods.gds-code  = temp_doc-line.gds-code
                                 no-lock no-error .
      if error-status :error then do:
          v-end-message = substitute("Ошибка: нет товара &1 &2 &3 " , temp_doc-line.gds-code , error-status :get-message(1)  , return-value) .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          ERROR_ = true .
          next .
      end.
      temp_doc-line.artic     = buf_goods.artic .
      temp_doc-line.prod-type = buf_goods.prod-type .
      temp_doc-line.prod-code = buf_goods.prod-code .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  tt-trn-doc.obj-type
  ,input  tt-trn-doc.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,buffer ub.gds-obj
  ) no-error .
  if temp_trn-doc.ext-doc-type <> 'ie':U then do:
     temp_doc-line.price-cli  = temp_doc-line.price-rubl .
  end.
  v-str-txt = "" .
      if not available ub.gds-obj then do:
        find first ub.gds-obj no-lock where
              ub.gds-obj.obj-type = tt-trn-doc.obj-type and
              ub.gds-obj.obj-code = tt-trn-doc.obj-code and
              ub.gds-obj.gds-code = buf_goods.gds-code no-error .
              if not available ub.gds-obj then do:
                  v-end-message =  substitute("Товар &1 &2 &3  &4 &5" ,
                                    buf_goods.gds-code,
                                    buf_goods.artic,
                                    buf_goods.gds-name,
                                    error-status :get-message(1) ,
                                    return-value  ) .
                  run pcall-log-file in p-log-handle (input v-end-message) .
                  ERROR_ = true .
              end.
      end.
      if ub.gds-obj.inv-on = true then do:
            v-end-message =  substitute("Товар &1 &2 &3  находится в инвентаризации. Прием документов невозможен." ,
                              buf_goods.gds-code ,
                              buf_goods.artic ,
                              buf_goods.gds-name
                              ) .
            run pcall-log-file in p-log-handle (input v-end-message) .
            ERROR_ = true .
      end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  temp_doc-line.artic
  ,input  temp_doc-line.prod-type
  ,input  temp_doc-line.prod-code
  ,output v-root-node
  )  .
        k = k + 1  .
        find first tt2-doc-line where
          tt2-doc-line.artic = temp_doc-line.artic and
          tt2-doc-line.prod-code = temp_doc-line.prod-code and
          tt2-doc-line.prod-type = temp_doc-line.prod-type no-error.
        if not available (tt2-doc-line)
        then do:
          create tt2-doc-line .
          BUFFER-COPY temp_doc-line  to tt2-doc-line
            assign
              tt2-doc-line.cli-qnty       = temp_doc-line.fact-qnty
              tt2-doc-line.doc-qnty       = temp_doc-line.fact-qnty
              tt2-doc-line.fact-qnty      = temp_doc-line.fact-qnty
              tt2-doc-line.price-cli      = temp_doc-line.price-cli
              tt2-doc-line.price-rubl     = tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale
              tt2-doc-line.price-base     = tt2-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
              tt2-doc-line.doc-code       = n-d
              tt2-doc-line.status_        = "temp"
              tt2-doc-line.ext-doc-type   = v-ext-doc-type
              tt2-doc-line.slt-pc         = 0
              tt2-doc-line.cli-base-rate  = 1
              tt2-doc-line.line-num       = next-value (s-line-num, ub)
              tt2-doc-line.prt-root       = buf_goods.prt-root
              tt2-doc-line.unit-cli       = buf_goods.unit-base
              tt2-doc-line.doc-density    = 1 / tt2-doc-line.cli-base-rate
              tt2-doc-line.fact-density   = 1 / tt2-doc-line.cli-base-rate
              tt2-doc-line.obj-code       = tt-trn-doc.obj-code
              tt2-doc-line.obj-type       = tt-trn-doc.obj-type
              .
        end.
        else do:
          assign
            tt2-doc-line.cli-qnty       = tt2-doc-line.cli-qnty + temp_doc-line.fact-qnty
            tt2-doc-line.price-cli      = (tt2-doc-line.price-cli * tt2-doc-line.doc-qnty + temp_doc-line.price-cli * if not is-tsd then temp_doc-line.fact-qnty else temp_doc-line.doc-qnty)
                                        / (tt2-doc-line.doc-qnty + if not is-tsd then temp_doc-line.fact-qnty else temp_doc-line.doc-qnty)
            tt2-doc-line.doc-qnty       = tt2-doc-line.doc-qnty + if not is-tsd then temp_doc-line.fact-qnty else temp_doc-line.doc-qnty
            tt2-doc-line.fact-qnty      = tt2-doc-line.fact-qnty + temp_doc-line.fact-qnty
            tt2-doc-line.price-rubl     = tt2-doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale
            tt2-doc-line.price-base     = tt2-doc-line.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
            .
      end.
        find first TempGdsDtl where TempGdsDtl.SuppInDocNo = temp_trn-doc.doc-code
                                and TempGdsDtl.gds-code    = temp_doc-line.gds-code
                                and TempGdsDtl.line-num    = temp_doc-line.line-num
                                no-error.
        if not available TempGdsDtl then do :
            find first tt-gds-dtl where
              tt-gds-dtl.artic = temp_doc-line.artic and
              tt-gds-dtl.prod-code = temp_doc-line.prod-code and
              tt-gds-dtl.prod-type = temp_doc-line.prod-type no-error.
            if not available (tt-gds-dtl) then do:
            create tt-gds-dtl.
            BUFFER-COPY tt2-doc-line  to tt-gds-dtl
              assign
                tt-gds-dtl.doc-qnty  = if not is-tsd then temp_doc-line.fact-qnty else temp_doc-line.doc-qnty
                tt-gds-dtl.fact-qnty = temp_doc-line.fact-qnty
                tt-gds-dtl.prt-code  = v-root-node
                tt-gds-dtl.ov = yes
              .
            end.
            else do:
            BUFFER-COPY tt2-doc-line  to tt-gds-dtl
              assign
                tt-gds-dtl.prt-code  = v-root-node
                tt-gds-dtl.ov = yes
              .
            end.
        end.
        else do :
            for each TempGdsDtl where TempGdsDtl.SuppInDocNo = temp_trn-doc.doc-code
                                and TempGdsDtl.gds-code    = temp_doc-line.gds-code
                                and TempGdsDtl.line-num    = temp_doc-line.line-num :
                create tt-gds-dtl.
                BUFFER-COPY tt2-doc-line  to tt-gds-dtl
                  assign
                    tt-gds-dtl.doc-qnty  = TempGdsDtl.doc-qnty
                    tt-gds-dtl.fact-qnty = TempGdsDtl.doc-qnty
                    tt-gds-dtl.prt-code  = TempGdsDtl.prt-code
                    tt-gds-dtl.price-rubl = TempGdsDtl.price-rubl
                    tt-gds-dtl.ov = yes
                  .
            end.
        end.
  end.
  def var jj as int no-undo.
  for each tt2-doc-line :
    jj = 0.
    for each temp_doc-line no-lock where temp_doc-line.artic = tt2-doc-line.artic
              and temp_doc-line.prod-code = tt2-doc-line.prod-code
              and temp_doc-line.prod-type = tt2-doc-line.prod-type:
      jj = jj + 1.
      find first TempParts where TempParts.SuppInDocNo = temp_trn-doc.doc-code
                             and TempParts.gds-code    = temp_doc-line.gds-code
                             and TempParts.line-num    = temp_doc-line.line-num
                             no-error .
      create tt-parts.
      buffer-copy tt2-doc-line except tt2-doc-line.status_ to tt-parts .
        assign
          tt-parts.prod-type      = tt2-doc-line.prod-type
          tt-parts.prod-code      = tt2-doc-line.prod-code
          tt-parts.artic          = tt2-doc-line.artic
          tt-parts.in-code        = new_trn-doc.doc-code
          tt-parts.out-code       = if available TempParts then TempParts.out-code else new_trn-doc.doc-code
          tt-parts.price-cli      = temp_doc-line.price-cli
          tt-parts.price-rubl     = temp_doc-line.price-cli  * new_trn-doc.exch-rate / new_trn-doc.exch-scale
          tt-parts.price-base     = tt-parts.price-rubl / new_trn-doc.base-rate * new_trn-doc.base-scale
          tt-parts.qnty           = temp_doc-line.fact-qnty
          tt-parts.obj-type       = new_trn-doc.obj-type
          tt-parts.obj-code       = new_trn-doc.obj-code
          tt-parts.fact-date      = new_trn-doc.fact-date
          tt-parts.fact-num       = new_trn-doc.fact-num
          tt-parts.VAT-pc         = tt2-doc-line.vat-pc
          tt-parts.part-code      = if available TempParts then TempParts.part-code else string (jj)
          tt-parts.PS             = ""
          tt-parts.pay-code       = new_trn-doc.pay-code
          tt-parts.status_        = no
          tt-parts.fact-qnty      = temp_doc-line.fact-qnty
          tt-parts.supp-type      = new_trn-doc.cli-type
          tt-parts.supp-code      = new_trn-doc.cli-code
          tt-parts.rsrv-free      = ?
          tt-parts.doc-type       = new_trn-doc.doc-type
          tt-parts.cli-qnty       = tt2-doc-line.fact-qnty
          tt-parts.pl-code        = ?
          tt-parts.VAT-type       = temp_trn-doc.vat-type
          tt-parts.exch-code      = 0
          tt-parts.cli-base-rate  = 1
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
          if error-status:error then do :
              v-end-message = substitute(" Ошибка &1 &2 " , error-status :get-message(1)  , return-value) .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              ERROR_ = true .
          end.
          if v-ext-doc-type = 'ie':U then do:
            run unitqnty1 (
              input tt2-doc-line.unit-cli,
              input "",
              input "",
              input 0,
              input "",
              input tt2-doc-line.doc-qnty)
              no-error.
            if error-status:error then
            do:
              v-str-txt = "Товар - " + string (tt2-doc-line.artic) + ": " +  return-value.
              run pcall-log-file in p-log-handle (input v-str-txt) .
              is-unit-error  = true.
              new_trn-doc.ps = new_trn-doc.ps + chr(10) + v-str-txt.
              delete tt2-doc-line.
            end.
            if available tt2-doc-line then do:
              run unitqnty1 (
                input tt2-doc-line.unit-cli,
                input "",
                input "",
                input 0,
                input "",
                input tt2-doc-line.fact-qnty)
                no-error.
              if error-status:error then
              do:
                v-str-txt = "Товар - " + string (tt2-doc-line.artic) + ": " +  return-value.
                run pcall-log-file in p-log-handle (input v-str-txt) .
                is-unit-error  = true.
                new_trn-doc.ps = new_trn-doc.ps + chr(10) + v-str-txt.
                delete tt2-doc-line.
              end.
            end.
          end.
    end.
  end.
  if is-unit-error then do:
    run pcall-log-file in p-log-handle (input "Не все товары попали в накладную") .
  end.
  case v-ext-doc-type :
      when  'ie':U
      or when 'iv':U
      then do:
           if v-specif
           then do:
              for each tt-parts          :
                 find first buf_goods no-lock  where
                       tt-parts.artic     = buf_goods.artic    and
                       tt-parts.prod-type = buf_goods.prod-type  and
                       tt-parts.prod-code = buf_goods.prod-code
                       no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_ckcntspc in g#lib-trn3
( input tt-parts.host-code
 ,input tt-parts.contract-code
 ,input buf_goods.gds-code
 ,input tt-parts.price-cli
 ,input tt-parts.VAT-type
 ,input tt-parts.VAT-pc
) no-error .
                 if error-status :error then do:
                   v-end-message = substitute("Ошибка  &1 &2 " , error-status :get-message(1)  , return-value ) .
                   run pcall-log-file in p-log-handle ( input v-end-message ) .
                   ERROR_ = true .
                   next.
                 end.
             end.
          end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_copy-in in g#lib-trn4
( input this-procedure
 ,input recid(new_trn-doc)
 ,input table tt-trn-doc
 ,input table tt2-doc-line
 ,input table tt-doc-line-attr
 ,input table tt-gds-dtl
 ,input table tt-parts
 ,input no
 ,input no
 ,input no
 ,input yes
 ,input this-procedure
  ) no-error .
          if error-status:error then do :
              v-end-message = substitute(" Ошибка &1 &2 " , error-status :get-message(1)  , return-value) .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              ERROR_ = true .
              return v-end-message.
          end.
          find current new_trn-doc exclusive-lock .
              new_trn-doc.tot-cli =  new_trn-doc.tot-calc.
      end.
      when 'ee':U
      or when 'ep':U
      or when 'ev':U
      or when 're':U    then do:
          if v-ext-doc-type = 'ep':U and v-specif
          then do :
              for each tt-parts          :
                 find first buf_goods no-lock  where
                       tt-parts.artic     = buf_goods.artic    and
                       tt-parts.prod-type = buf_goods.prod-type  and
                       tt-parts.prod-code = buf_goods.prod-code
                       no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_ckcntspc in g#lib-trn3
( input tt-parts.host-code
 ,input tt-parts.contract-code
 ,input buf_goods.gds-code
 ,input tt-parts.price-cli
 ,input tt-parts.VAT-type
 ,input tt-parts.VAT-pc
) no-error .
                 if error-status :error then do:
                   v-end-message = substitute("Ошибка  &1 &2 " , error-status :get-message(1)  , return-value ) .
                   run pcall-log-file in p-log-handle ( input v-end-message ) .
                   ERROR_ = true .
                   next.
                 end.
              end.
          end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-ret in g#lib-trn
  (
    input this-procedure
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
  , input new_trn-doc.discnt-pc
  , input new_trn-doc.agnt
  , input new_trn-doc.boss
  , input new_trn-doc.wrkr
  , input new_trn-doc.base-rate
  , input new_trn-doc.base-scale
  , input v-cntxt-cash-pay
  , input v-cntxt-base-code
  , input-output table tt2-doc-line
  , input-output table tt-gds-dtl
  , input-output table tt-parts
  , input no
  , input yes
  , input yes
  , input yes
  ) no-error.
            if error-status:error then do :
                v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
                ERROR_ = true .
                undo, return v-end-message.
            end.
            if (v-ext-doc-type = 'ee':U)
            and temp_trn-doc.stts <> 'запрос':U
            then do:
                run clos-trn in this-procedure (new_trn-doc.doc-code) no-error .
                if error-status:error then do :
                   v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
                   run pcall-log-file in p-log-handle ( input v-end-message ) .
                   undo, return error v-end-message.
                end.
                if is-unit-error then do:
                  new_trn-doc.flag_ = false.
                end.
                run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
                if error-status:error then do :
                   v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
                   run pcall-log-file in p-log-handle ( input v-end-message ) .
                   undo, return error v-end-message.
                end.
            end.
          assign
            new_trn-doc.PS  = trim(new_trn-doc.PS) + " " + v-str-txt .
      end.
   end case.
  if new_trn-doc.vat-type = "" or new_trn-doc.vat-type = ? or
     new_trn-doc.slt-type = "" or new_trn-doc.slt-type = ? then do:
        v-end-message = substitute(" Не настроено значение тип НДС или тип НсП !!! АРМ Администратор/Глобальные параметры/ &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
  end.
   run add-nn (new_trn-doc.doc-code , temp_trn-doc.doc-code ) no-error .
    if error-status:error then do :
        v-end-message = substitute(" Ошибка записи атрибута документа &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
    end.
   if temp_trn-doc.cargo-from <> ""
   then do:
    find first ub.doc-attr exclusive-lock where
             ub.doc-attr.doc-code = new_trn-doc.doc-code and
             ub.doc-attr.attr-code = 'Shipper':U no-error .
    if not available ub.doc-attr then create ub.doc-attr.
    assign
      ub.doc-attr.doc-code = new_trn-doc.doc-code
      ub.doc-attr.attr-code = 'Shipper':U
      ub.doc-attr.attr-value = temp_trn-doc.cargo-from
    .
  end.
  for each TempDocAttr where TempDocAttr.SuppInDocNo = temp_trn-doc.doc-code :
      find first ub.doc-attr exclusive-lock where
             ub.doc-attr.doc-code = new_trn-doc.doc-code and
             ub.doc-attr.attr-code = TempDocAttr.attr-code no-error .
      if not available ub.doc-attr then create ub.doc-attr.
      assign
          ub.doc-attr.doc-code = new_trn-doc.doc-code
          ub.doc-attr.attr-code = TempDocAttr.attr-code
          ub.doc-attr.attr-value = TempDocAttr.attr-value
      .
  end.
   run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
    if error-status:error then do :
        v-end-message = substitute(" Ошибка при закрытиии документа &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        ERROR_ = true .
        if temp_trn-doc.stts = 'запрос':U or new_trn-doc.status_ = 'запрос':U
        then do :
            new_trn-doc.flag_ = false .
        end.
        return v-end-message.
    end.
    if new_trn-doc.ext-doc-type = 're':U    then do:
        v-end-message = substitute("Закрытиии внешнего возврата &1 на статус РАЗР " , new_trn-doc.doc-code) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка при закрытиии внешнего возврата на статус РАЗР &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = 'запрос':U or new_trn-doc.status_ = 'запрос':U
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
        end.
        v-end-message = substitute("Закрытиии внешнего возврата &1 на статус ФАКТ ", new_trn-doc.doc-code ) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка при закрытиии внешнего возврата на статус ФАКТ &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = 'запрос':U or new_trn-doc.status_ = 'запрос':U
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
        end.
    end.
    if new_trn-doc.ext-doc-type = 'ev':U
    and (temp_trn-doc.stts = "накл" or temp_trn-doc.stts = "разр" or temp_trn-doc.stts = "факт")
    then do :
        v-end-message = substitute("Закрытие документа &1 на статус НАКЛ- ", new_trn-doc.doc-code ) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка при закрытии документа на статус НАКЛ-.  &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = 'запрос':U or new_trn-doc.status_ = 'запрос':U
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
        end.
        v-end-message = substitute("Закрытие документа &1 на статус НАКЛ+ ", new_trn-doc.doc-code ) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка при закрытии документа на статус НАКЛ+.  &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = 'запрос':U or new_trn-doc.status_ = 'запрос':U
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
        end.
    end.
    if (temp_trn-doc.stts = "разр" and new_trn-doc.ext-doc-type <> 'ie':U)
    or ((new_trn-doc.ext-doc-type = 'ee':U
         or new_trn-doc.ext-doc-type = 'ep':U
         or new_trn-doc.ext-doc-type = 'ev':U
         )
    and temp_trn-doc.stts = "факт")
    then do :
        v-end-message = substitute("Закрытие документа &1 на статус РАЗР ", new_trn-doc.doc-code ) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
        if error-status:error then do :
            v-end-message = substitute(" Ошибка при закрытии документа на статус РАЗР.  &1 &2" , error-status :get-message(1)  , return-value) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = 'запрос':U or new_trn-doc.status_ = 'запрос':U
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
        end.
    end.
    if temp_trn-doc.stts = "факт"
    then do :
        if new_trn-doc.contract-code = ? or new_trn-doc.contract-code = 0 and new_trn-doc.ext-doc-type = 'ie':U
        then do :
            v-end-message =  "Ошибка при закрытиии документа. Нет номера договора" .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            ERROR_ = true .
            if temp_trn-doc.stts = 'запрос':U or new_trn-doc.status_ = 'запрос':U
            then do :
                new_trn-doc.flag_ = false .
            end.
            return v-end-message.
        end.
        else do :
            if new_trn-doc.fact-date = ? then new_trn-doc.fact-date = to-day .
            if new_trn-doc.ext-doc-type = 'ev':U then new_trn-doc.fact-date = ? .
            v-end-message = substitute("Закрытие документа &1 на статус ФАКТ ", new_trn-doc.doc-code ) .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
            if error-status:error then do :
                assign new_trn-doc.fact-date = ? no-error .
                v-end-message = substitute(" Ошибка при закрытиии документа &1 &2" , error-status :get-message(1)  , return-value) .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                ERROR_ = true .
                if temp_trn-doc.stts = 'запрос':U or new_trn-doc.status_ = 'запрос':U
                then do :
                    new_trn-doc.flag_ = false .
                end.
                return v-end-message.
            end.
        end.
    end.
    if temp_trn-doc.stts = 'запрос':U or new_trn-doc.status_ = 'запрос':U
    then do :
        new_trn-doc.flag_ = false .
    end.
    assign
        v-end-message =  string(temp_trn-doc.obj-type) + string(temp_trn-doc.obj-code)
                    + chr(9) + "Документ:" + string(new_trn-doc.doc-code) + " / " + string(temp_trn-doc.doc-code) + chr(9) + string( k ) + " товаров"
                    .
     run pcall-log-file in p-log-handle (input v-end-message) .
     p-ok-doc = p-ok-doc + 1.
end.
end.
procedure clos-trn :
  do
  on error undo, return error return-value
  :
define input parameter p-trn-code as character no-undo .
define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv      as logical no-undo .
assign
  varmode         = '<закрытие документа>':U
  varstatus       = 'запрос':U
  varflag         = true
  varcopystatus   = 'новый':U
  varcopyflag     = false
  varcheck-return = true
  varchg-inv      = true
  .
for each tt2-doc-line where is-tsd and doc-code = p-trn-code no-lock:
  run unitqnty1 (
      input tt2-doc-line.unit-cli,
      input "",
      input "",
      input 0,
      input "",
      input tt2-doc-line.doc-qnty)
  no-error.
  if error-status:error then do:
    run pcall-log-file in p-log-handle (input return-value) .
    is-unit-error  = true.
  end.
  run unitqnty1 (
      input tt2-doc-line.unit-cli,
      input "",
      input "",
      input 0,
      input "",
      input tt2-doc-line.fact-qnty)
  no-error.
  if error-status:error then do:
    run pcall-log-file in p-log-handle (input return-value) .
    is-unit-error  = true.
  end.
end.
if is-unit-error then do:
  run pcall-log-file in p-log-handle (input "Невозможно перевести накладную в статус накл") .
  return.
end.
run str/trn-graf.p
  ( input  p-trn-code ,
    input  v-cntxt-db-num ,
    input  varmode ,
    output varstatus ,
    output varflag ,
    output varcopystatus ,
    output varcopyflag
  ) no-error .
    if error-status:error then do :
        v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
    end.
run str/trn-stat.p (
    input  parparentproc ,
    input  this-procedure ,
    input  varmode,
    input  p-trn-code,
    input  varcheck-return,
    input  v-cntxt-db-num,
    input  v-cntxt-in-ov,
    input  v-cntxt-rsrv-time,
    input  v-cntxt-load-time,
    input  v-cntxt-holidays,
    input  NO,
    output varchg-inv,
    output table gds-list)
    no-error.
    if error-status:error then do :
        v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
    end.
  end.
    for each ub.doc-line exclusive-lock where new_trn-doc.doc-code = ub.doc-line.doc-code:
      find first buf_goods where ub.doc-line.artic = buf_goods.artic and
        ub.doc-line.prod-type = buf_goods.prod-type  and
        ub.doc-line.prod-code = buf_goods.prod-code
        no-lock no-error .
      find first ub.gds-dtl exclusive-lock where ub.gds-dtl.doc-code = ub.doc-line.doc-code and
        ub.gds-dtl.artic = buf_goods.artic and
        ub.gds-dtl.prod-type = buf_goods.prod-type  and
        ub.gds-dtl.prod-code = buf_goods.prod-code.
      find first temp_doc-line where temp_doc-line.gds-code = buf_goods.gds-code.
      ub.gds-dtl.doc-qnty  = temp_doc-line.doc-qnty.
      ub.gds-dtl.fact-qnty = temp_doc-line.fact-qnty.
      ub.doc-line.fact-qnty = temp_doc-line.fact-qnty.
      ub.doc-line.doc-qnty = temp_doc-line.doc-qnty.
      ub.doc-line.cli-qnty = temp_doc-line.fact-qnty.
    end.
end procedure.
procedure clos-trn2 :
define input parameter p-trn-code as character no-undo .
  do
  on error undo, return error return-value
  :
define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .
run str/trn-stat.p (
    input  parparentproc ,
    input  this-procedure ,
    input  '<закрытие документа>':U ,
    input  p-trn-code,
    input  false  ,
    input  v-cntxt-db-num,
    input  false ,
    input  v-cntxt-rsrv-time,
    input  v-cntxt-load-time,
    input  v-cntxt-holidays,
    input  false ,
    output varchg-inv ,
    output table gds-list)
    no-error.
    if error-status:error then do :
        v-end-message = substitute(" Ошибка &1 &2" , error-status :get-message(1)  , return-value) .
        return error v-end-message.
    end.
  end.
end procedure.
procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo .
define output parameter p-cntxt-userid                as character no-undo .
define output parameter p-cntxt-level                 as character no-undo .
define output parameter p-cntxt-host-code-obj         as integer   no-undo .
define output parameter p-cntxt-obj-type              as character no-undo .
define output parameter p-cntxt-obj-code              as integer   no-undo .
define output parameter p-cntxt-db-num-obj            as integer   no-undo .
define output parameter p-cntxt-is-admin              as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  vt-obj-type
  ,input  vt-obj-code
  ,output p-cntxt-db-num-obj
  )  .
  assign
    p-cntxt-db-num          =  v-cntxt-db-num
    p-cntxt-userid          =  v-cntxt-userid
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  vt-obj-type
    p-cntxt-obj-code        =  vt-obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .
  end.
 end procedure.
 procedure get-report-num :
  define output parameter p-report-num as integer no-undo .
   do
   on error undo, return error return-value
   :
    assign
      p-report-num = 1
    .
   end.
 end procedure.
procedure clear-tt :
  do
  on error undo, return error return-value
  :
   for each tt-trn-doc:
    delete tt-trn-doc.
   end.
    for each tt2-doc-line :
        delete tt2-doc-line .
    end.
    for each tt-doc-line :
        delete tt-doc-line .
    end.
    for each tt-gds-dtl :
        delete tt-gds-dtl .
    end.
    for each tt-parts:
        delete tt-parts .
    end.
    for each lib-trn_ret-doc :
      delete lib-trn_ret-doc.
    end.
    for each lib-trn_ret-line :
      delete lib-trn_ret-line      .
    end.
    for each lib-trn_ret-line-attr :
      delete lib-trn_ret-line.
    end.
    for each lib-trn_ret-dtl :
      delete lib-trn_ret-dtl.
    end.
    for each lib-trn_ret-parts :
      delete lib-trn_ret-parts .
    end.
 end.
end procedure.
procedure add-nn :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-doc-out as character no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.doc-attr exclusive-lock where
             ub.doc-attr.doc-code = p-doc-code and
             ub.doc-attr.attr-code = 'nids':U no-error .
    if not available ub.doc-attr then create ub.doc-attr.
    assign
      ub.doc-attr.doc-code = p-doc-code
      ub.doc-attr.attr-code = 'nids':U
      ub.doc-attr.attr-value = p-doc-out
    .
  end.
end procedure.
procedure calc-cost-price :
define input  parameter p-doc-code as character no-undo .
define buffer cur-doc-line  for ub.doc-line.
define buffer cur-goods     for ub.goods.
define buffer cur-gds-dtl   for ub.gds-dtl.
define buffer t-doc         for ub.trn-doc  .
define variable varnew-price like ub.doc-line.price-base no-undo.
  do
  on error undo, return error return-value
  :
  v-end-message = substitute("Просчет учетной цены для расходной накладной &1" , p-doc-code) .
  run pcall-log-file in p-log-handle ( input v-end-message ) .
  find first t-doc no-lock where t-doc.doc-code = p-doc-code .
   for each  cur-doc-line where cur-doc-line.doc-code   = t-doc.doc-code         ,
       first cur-goods    where cur-goods.artic         = cur-doc-line.artic     and
                                cur-goods.prod-type     = cur-doc-line.prod-type and
                                cur-goods.prod-code     = cur-doc-line.prod-code no-lock,
       each  cur-gds-dtl  where cur-gds-dtl.doc-code    = cur-doc-line.doc-code  and
                                cur-gds-dtl.artic       = cur-doc-line.artic     and
                                cur-gds-dtl.prod-type   = cur-doc-line.prod-type and
                                cur-gds-dtl.prod-code   = cur-doc-line.prod-code no-lock :
       assign
         line-rec = recid(cur-doc-line)
       .
assign
  price-rubl-with-tax-loc = cur-doc-line.price-rubl
  price-base-with-tax-loc = cur-doc-line.price-base
.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = t-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = cur-doc-line.artic     and
                                     in-vatp-goods.prod-type = cur-doc-line.prod-type and
                                     in-vatp-goods.prod-code = cur-doc-line.prod-code no-lock.
   if (not t-doc.internal and
           t-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = cur-doc-line.road-tax
          road-tax-rubl-loc = cur-doc-line.road-tax * t-doc.base-rate / t-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = cur-doc-line.road-tax
          road-tax-base-loc = cur-doc-line.road-tax / t-doc.base-rate * t-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if cur-doc-line.transport-base = ? then 0 else cur-doc-line.transport-base)
        transport-rubl-loc = (if cur-doc-line.transport-rubl = ? then 0 else cur-doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if cur-doc-line.other-base     = ? then 0 else cur-doc-line.other-base)
        other-rubl-loc     = (if cur-doc-line.other-rubl     = ? then 0 else cur-doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if cur-doc-line.vat-pc         = ? then 0 else cur-doc-line.vat-pc)
        slt-pc-loc         = (if cur-doc-line.slt-pc         = ? then 0 else cur-doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = cur-doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = cur-doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = cur-doc-line.obj-code  and
                                      in-vatp-parts.artic     = cur-doc-line.artic     and
                                      in-vatp-parts.prod-type = cur-doc-line.prod-type and
                                      in-vatp-parts.prod-code = cur-doc-line.prod-code
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
        road-tax-base-loc   = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
        transport-base-loc  = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
        transport-rubl-loc  = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
        other-base-loc      = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
        other-rubl-loc      = if cur-doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / cur-doc-line.fact-qnty  else 0
                                        vat-base-loc        = if cur-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / cur-doc-line.fact-qnty   else 0
        slt-base-loc        = if cur-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / cur-doc-line.fact-qnty   else 0
                vat-rubl-loc        = if cur-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / cur-doc-line.fact-qnty   else 0
        slt-rubl-loc        = if cur-doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / cur-doc-line.fact-qnty   else 0
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
    assign
      varnew-price = (if t-doc.print-rubl then price-rubl-with-tax-loc
                                          else price-base-with-tax-loc ) .
       run str/out-add.p ( this-procedure ,
                      recid (t-doc),
                      recid (cur-doc-line),
                      recid (cur-gds-dtl),
                      recid (cur-goods),
                      "update-sale-price",
                      string(varnew-price)) no-error.
       if error-status :error then do:
        v-end-message = substitute(" Ошибка при вызове программы out-add &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
       end.
   end.
    if not is-tsd then do:
      run gbl/calc-trn.p (  this-procedure , recid(new_trn-doc)) no-error .
      if error-status :error then do:
        v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value) .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
      end.
    end.
  end.
end procedure.
procedure cb_cloce-quest-neg :
define output parameter p-is-negostmess as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-is-negostmess = false .
  end.
end procedure.
procedure unitqnty1 :
  define input parameter  p-unit-name        like ub.units.unit-name no-undo .
  define input parameter  p-artic            like ub.goods.artic     no-undo .
  define input parameter  p-prod-type        like ub.goods.prod-type no-undo .
  define input parameter  p-prod-code        like ub.goods.prod-code no-undo .
  define input parameter  p-unit-description as character            no-undo .
  define input parameter  p-qnty             as decimal              no-undo .
  define buffer buf_units for ub.units .
  define buffer buf_goods for ub.goods .
  define variable v-artic as character no-undo .
  define variable v-msg   as character no-undo .
  if p-unit-description = ''
  or p-unit-description = ?
  then do:
    assign
      p-unit-description = "Единица измерения "
    .
  end.
  if  p-unit-name <> ''
  and p-unit-name <> ?
  then do:
    find first buf_units no-lock
      where buf_units.unit-name = p-unit-name
      no-error .
    if not available buf_units
    then do:
      v-msg =
        "Не найдена единица измерения " + chr(10) +
        "p-unit-name" +   p-unit-name + chr(10) +
        "p-artic" +       p-artic +  chr(10) +
        "p-prod-type" +   p-prod-type + chr(10) +
        "p-proc-code" +   string (p-prod-code) + chr(10) +
        "p-qnty" +        string (p-qnty) + chr(10)
         .
      undo, return v-msg .
    end.
  end.
  else do:
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      no-error .
    if not available buf_goods
    then do:
      v-msg =
        "Не найден товар" + chr(10) +
        "p-unit-name" +   p-unit-name + chr(10) +
        "p-artic" +       p-artic +  chr(10) +
        "p-prod-type" +   p-prod-type + chr(10) +
        "p-proc-code" +   string (p-prod-code) + chr(10) +
        "p-qnty" +        string (p-qnty) + chr(10)
        .
      undo, return v-msg .
    end.
    find first buf_units no-lock
      where buf_units.unit-name = buf_goods.unit-base
      no-error .
    if not available buf_units
    then do:
      v-msg =
        "Не найдена единица измерения " + chr(10) +
        "p-unit-name" +   p-unit-name + chr(10) +
        "p-artic" +       p-artic +  chr(10) +
        "p-prod-type" +   p-prod-type + chr(10) +
        "p-proc-code" +   string (p-prod-code) + chr(10) +
        "p-qnty" +        string (p-qnty) + chr(10)
        .
      undo, return v-msg .
    end.
    assign
      v-artic = "Артикул " + string(p-artic) + " " + string(p-prod-type)
              + " " + string(p-prod-code)
      p-unit-description = "Базовая единица измерения"
    .
  end.
  if lookup('шту':U, buf_units.type) > 0
  or lookup('сер':U, buf_units.type) > 0
  then do:
    if p-qnty <> truncate(p-qnty, 0)
    then do:
      v-msg =
        "Для штучного и серийного товаров резервируемое количество должно быть целым" + chr(10) +
        v-artic + chr(10) +
        p-unit-description + buf_units.unit-name + chr(10) +
        "Запрошено количество " + string (p-qnty) + chr(10).
      undo, return v-msg .
    end.
  end.
end procedure.
