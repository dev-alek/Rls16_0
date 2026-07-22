define input        parameter parparentproc as handle    no-undo .
define input        parameter pardoc-mode   as character no-undo .
define input        parameter parrvs-type   as character no-undo .
define input        parameter parall-place  as logical   no-undo .
define input-output parameter parrvs-rec    as recid     no-undo .
define input-output parameter p-next-prev as character no-undo .
define input parameter p-call-prog  as handle no-undo .
define variable        varlog            as   logical                    no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Удаленные сверки ":U.
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
define new global shared variable g#libbcrcn as handle no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION determined RETURNS DECIMAL (INPUT parundefine-var AS DECIMAL):
   IF parundefine-var = ? THEN RETURN 0.00.
                          ELSE RETURN parundefine-var.
END FUNCTION.
FUNCTION dtm-char RETURNS CHARACTER (INPUT p-undef-char AS CHARACTER):
   IF p-undef-char = ? THEN do:
     RETURN "?".
   end.
   ELSE do:
     RETURN p-undef-char .
   end.
END FUNCTION.
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define new global shared variable g#lib-rvs as handle no-undo.
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
  define temp-table tt-param no-undo
    field strfrfile as character
    field strasi    as character
    field flddb     as character
    index pi        as primary   unique strfrfile
    index asi strasi.
  define temp-table tt-param-pump no-undo
    field strfrfile as character
    field meaning   as character
    index pi        as primary   unique strfrfile.
  define temp-table tt-meas no-undo like ub.place
    field measure-qnty like ub.rvs-line.measure-qnty
    field brutto-qnty like ub.rvs-line.brutto-qnty
    field measure-cli-qnty like ub.rvs-line.measure-cli-qnty
    field brutto-cli-qnty like ub.rvs-line.brutto-cli-qnty
    field density like ub.rvs-line.density
    field temperature like ub.rvs-line.temperature
    field level-total like ub.rvs-line.level-total
    field level-petrol like ub.rvs-line.level-petrol
    field level-water like ub.rvs-line.level-water
    field temp-layer1 like ub.rvs-line.temp-layer1
    field temp-layer2 like ub.rvs-line.temp-layer2
    field temp-layer3 like ub.rvs-line.temp-layer3
    field measure-tc-qnty like ub.rvs-line.measure-tc-qnty
    field brutto-tc-qnty like ub.rvs-line.brutto-tc-qnty
    field meas-vol-oil   as logical initial no
    field meas-vol-water as logical initial no
    field water-qnty     like ub.rvs-line.measure-qnty
    field vapor-density like ub.rvs-line.density
    field vapor-pressure as decimal format ">>9.9<":U
    field log-brutto as logical
    field temp-not-null as logical
    field t1-not-null as logical
    field t2-not-null as logical
    field t3-not-null as logical
    field is-error    as logical
    index pi        as primary   loc1.
  define temp-table tt-meas-file no-undo like tt-meas.
  define temp-table tt-pump-nozzle no-undo like ub.pump-nozzle
    field gds-code    like ub.goods.gds-code
    field meas-el-cnt like ub.rvs-line-pump.meas-el-cnt
    field meas-am-cnt like ub.rvs-line-pump.meas-am-cnt
    field grade       as   character
    field meas-cf-cnt like ub.rvs-line-pump.meas-cf-cnt.
  define temp-table tt-pump-nozzle-file no-undo like tt-pump-nozzle.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
function is-gas returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'metan':U) no-error.
return result.
end function.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
define buffer c-rvs-doc          for ub.c-rvs-doc.
define buffer cur_shift-obj  for ub.shift-obj.
define buffer prev_shift-obj for ub.shift-obj.
define buffer prev_rvs-doc   for ub.c-rvs-doc.
define buffer prev_icnt-doc  for ub.icnt-doc.
define variable v-ref-rec as recid no-undo .
define variable rvs-line-rec      as   recid                no-undo.
define variable rvs-line-pump-rec as   recid                no-undo.
define variable varartic          like ub.doc-line.artic    no-undo initial " ".
define variable ref-list          as   character            no-undo.
define variable l-g#stat          as   character            no-undo.
define variable l-g#type          as   character            no-undo.
define variable l-g#internal      as   logical              no-undo.
define variable varres            as   logical              no-undo initial ?.
define variable varrecid          as   recid                no-undo.
define variable ptoldfilvalue     as   character            no-undo.
define variable ptoldfiltype      as   character            no-undo.
define variable varcur-data       as   logical              no-undo.
define variable varnum            as   integer              no-undo.
define variable varcur-rvs        as   logical              no-undo.
define variable varcur-pump       as   logical              no-undo.
define variable gds-rec           as   recid                no-undo.
define variable notes             as   character            no-undo.
define variable rep-rec           as   recid                no-undo.
define variable lns-cnt           as   integer              no-undo.
define buffer cli-buf          for ub.clients.
define buffer del-rvs-line for ub.c-rvs-line.
define button b-help
     label "Помощь":U
     size 10 by 1.
define button b-exit AUTO-GO
     label "Выход":U
     size 10 by 1.
define button b-mark
     label "&*":U
     size 3 by 1.
DEFINE BUTTON B-next AUTO-GO
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON B-prev AUTO-GO
     LABEL "&<<"
     SIZE 4 BY 1.
define button b-lkp
     label "Просмотр":U
     size 10 by 1.
define button b-lkp-pump
     label "Просм ТРК":U
     size 10 by 1.
define button b-history
     label "История":U
     size 10 by 1.
define button b-notes
     label "Прим.":U
     size 10 by 1.
define button r-acc
     image-up          file "btn-down-arrow"
     image-down        file "btn-down-arrow"
     image-insensitive file "btn-down-arrow"
     size 3 by .88.
define button r-agnt     like r-acc.
define button r-boss     like r-acc.
define button r-wrkr     like r-acc.
define variable agnt-name as character format "x(256)":u
      view-as text
     size 14 by 1 no-undo.
define variable boss-name as character format "x(256)":u
      view-as text
     size 14 by 1 no-undo.
define variable wrkr-name as character format "x(256)":u
      view-as text
     size 14 by 1 no-undo.
define variable del-list as character no-undo.
function get-mark return character (buffer local-rvs-line for ub.c-rvs-line ).
   if lookup (string (recid (local-rvs-line)), del-list) > 0 then return "*".
                                                                 else return "".
end function.
function deviation-fact    return decimal (buffer local-rvs-line for ub.c-rvs-line ).
   return (local-rvs-line.state-measure-qnty   + local-rvs-line.state-add-qnty - local-rvs-line.system-qnty).
end function.
function deviation-measure return decimal (buffer local-rvs-line for ub.c-rvs-line ).
   return (local-rvs-line.measure-qnty + local-rvs-line.state-add-qnty - local-rvs-line.system-qnty).
end function.
define query br-line      for ub.c-rvs-line, ub.goods, ub.place scrolling.
define query br-pump for ub.c-rvs-line-pump                scrolling.
define browse br-line query br-line no-lock display
      get-mark (buffer ub.c-rvs-line)  column-label '*'  format "x(1)"
      ub.goods.artic  column-label 'Артикул'
      ub.goods.gds-name  column-label 'Название'  format "x(15)"
      ub.c-rvs-line.pl-code  column-label 'Скл.место'
      place.loc1  column-label 'Номер резервуара'
      ub.c-rvs-line.state-measure-qnty  column-label 'Факт остаток'
      ub.c-rvs-line.measure-qnty  column-label 'Измер. остаток'
      ub.c-rvs-line.system-qnty  column-label 'Учет'
      ub.c-rvs-line.orig-system-qnty  column-label 'Первонач.учет'
      ub.c-rvs-line.state-add-qnty column-label 'Факт в!трубопроводе' format "->>,>>>,>>>.<<<"
      deviation-fact(buffer ub.c-rvs-line) column-label 'Отклонение(факт)' format "->>,>>>,>>>.<<<"
      deviation-measure(buffer ub.c-rvs-line) column-label 'Отклонение(измер)'
      ub.c-rvs-line.tolerance column-label 'Допустимое!отклонение'
      ub.c-rvs-line.state-brutto-qnty column-label 'Факт брутто'
      ub.c-rvs-line.brutto-qnty
      ub.c-rvs-line.state-density
      ub.c-rvs-line.density
      ub.c-rvs-line.state-measure-cli-qnty
      ub.c-rvs-line.measure-cli-qnty
      ub.c-rvs-line.system-cli-qnty
      ub.c-rvs-line.orig-system-cli-qnty
      ub.c-rvs-line.state-brutto-cli-qnty
      ub.c-rvs-line.brutto-cli-qnty
      ub.c-rvs-line.state-mh-qnty
      ub.c-rvs-line.meas-mh-qnty
      ub.c-rvs-line.state-am-qnty
      ub.c-rvs-line.meas-am-qnty
      ub.c-rvs-line.state-cf-qnty
      ub.c-rvs-line.meas-cf-qnty
      ub.c-rvs-line.state-level-total
      ub.c-rvs-line.level-total
      ub.c-rvs-line.state-level-petrol format "->>,>>>,>>>.<<<"
      ub.c-rvs-line.level-petrol
      ub.c-rvs-line.state-level-water
      ub.c-rvs-line.level-water
      ub.c-rvs-line.state-temperature
      ub.c-rvs-line.temperature
      enable ub.c-rvs-line.temperature
    with size 98.75 by 6 separators.
define browse br-pump query br-pump no-lock display
      ub.c-rvs-line-pump.pump-code column-label 'ТРК'
      ub.c-rvs-line-pump.nozzle-code column-label 'П'
      ub.c-rvs-line-pump.state-mh-qnty
      ub.c-rvs-line-pump.meas-mh-qnty
      ub.c-rvs-line-pump.state-am-qnty
      ub.c-rvs-line-pump.meas-am-qnty
      ub.c-rvs-line-pump.state-cf-qnty
      ub.c-rvs-line-pump.meas-cf-qnty
      ub.c-rvs-line-pump.state-mh-cnt
      ub.c-rvs-line-pump.meas-mh-cnt
      ub.c-rvs-line-pump.state-el-cnt
      ub.c-rvs-line-pump.meas-el-cnt
      ub.c-rvs-line-pump.state-am-cnt
      ub.c-rvs-line-pump.meas-am-cnt
      ub.c-rvs-line-pump.state-cf-cnt
      ub.c-rvs-line-pump.meas-cf-cnt
      ub.c-rvs-line-pump.icnt-code
      ub.c-rvs-line-pump.rvs-prev-code
      enable ub.c-rvs-line-pump.rvs-prev-code
    with size 98.75 by 7 separators.
define frame d-rvs
b-exit              at row 1  col 1
b-notes             at row 1  col 11
b-history           at row 1  col 71
B-prev              at row 1 col 30
B-next             at row 1 col 34
b-help              at row 1  col 81
"Объект:"                         at row 2 col 10
c-rvs-doc.obj-code                    at row 2 col 16   colon-aligned no-label       view-as text size 7    by 1
c-rvs-doc.obj-type                    at row 2 col 23   colon-aligned no-label       view-as text size 7.13 by 1
ub.clients.obj-name               at row 2 col 33   colon-aligned no-label       view-as text size 40 by 1 fgcolor 4
c-rvs-doc.out-code                    at row 3 col 20   colon-aligned label "На основе документа" view-as text
c-rvs-doc.doc-date                    at row 3 col 40   colon-aligned view-as text
c-rvs-doc.state-measure-qnty          at row 4 col 38   colon-aligned view-as text
c-rvs-doc.measure-qnty                at row 4 col 63   colon-aligned label "Измер" view-as text
c-rvs-doc.system-qnty                 at row 4 col 85.5                          colon-aligned view-as text
c-rvs-doc.wrkr                        at row 5 col 4.5  colon-aligned format "999999999"  view-as fill-in size 10 by 1
wrkr-name                         at row 5 col 15   colon-aligned no-label fgcolor 4
r-wrkr                            at row 5 col 28   no-label
c-rvs-doc.state-measure-cli-qnty      at row 5 col 50   colon-aligned label "Вес"       view-as text
c-rvs-doc.measure-cli-qnty            at row 5 col 85.5 colon-aligned label "Измер.вес" view-as text
c-rvs-doc.agnt                        at row 6 col 4.5 colon-aligned format "999999999"  view-as fill-in size 10 by 1
agnt-name                         at row 6 col 15  colon-aligned no-label fgcolor 4
r-agnt                            at row 6 col 28  no-label
c-rvs-doc.system-cli-qnty         at row 6 col 50    colon-aligned label "Учет вес"         view-as text
c-rvs-doc.system-cli-avrg-qnty    at row 6 col 85.5  colon-aligned label "Вес по ср.пл-ти"  view-as text
c-rvs-doc.boss                    at row 7 col 4.5   colon-aligned format "999999999"       view-as fill-in size 10 by 1
boss-name                     at row 7 col 15    colon-aligned no-label                fgcolor 4
r-boss                        at row 7 col 28    no-label
c-rvs-doc.state-mh-qnty           at row 7 col 38    colon-aligned label "Оборот"           view-as text format "->,>>>,>>>,>>>.<<<"
c-rvs-doc.state-am-qnty           at row 7 col 63    colon-aligned label "Сумма"            view-as text format "->,>>>,>>>,>>>.<<<"
c-rvs-doc.state-cf-qnty           at row 7 col 85.5  colon-aligned label "Наливы"           view-as text
b-mark              at row 8  col 1
b-lkp               at row 8  col 34
br-line      at row 9  col 1
b-lkp-pump          at row 15 col 1
br-pump at row 16 col 1
space(0) skip(0)
with view-as dialog-box side-labels three-d scrollable keep-tab-order.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-line as INT EXTENT 35 no-undo.
DEF VAR varmvibr-line       as INT no-undo.
DEF VAR varmvjbr-line       as INT no-undo.
DEF VAR varmvkbr-line       as INT no-undo.
DEF VAR varmvlbr-line       as INT no-undo.
DEF VAR move-elementbr-line as INT no-undo.
def var jjbr-line           as int no-undo.
do varmvibr-line = 1 to EXTENT(cur-clmn-numbr-line):
  ASSIGN cur-clmn-numbr-line[varmvibr-line] = varmvibr-line.
END.
RUN start-mv-clmnbr-line.
PROCEDURE start-mv-clmnbr-line:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-line do:
  RUN re-move-clmnbr-line ( 6, 35).
END.
ON ctrl-cursor-left OF BROWSE br-line do:
  RUN re-move-clmnbr-line (35, 6).
END.
PROCEDURE re-move-clmnbr-line:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
    if cur-clmn-numbr-line[varmvibr-line] = source-column THEN cur-clmn-numbr-line[varmvibr-line] = -1.
  END.
  if br-line:MOVE-COLUMN(source-column, target-column) IN FRAME d-rvs then.
  if source-column > target-column THEN
  DO varmvjbr-line = source-column - 1 to target-column BY -1:
    DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
        if cur-clmn-numbr-line[varmvibr-line] = varmvjbr-line THEN DO:
          cur-clmn-numbr-line[varmvibr-line] = cur-clmn-numbr-line[varmvibr-line] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-line = source-column + 1 to target-column:
    DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
      if cur-clmn-numbr-line[varmvibr-line] = varmvjbr-line THEN DO:
        cur-clmn-numbr-line[varmvibr-line] = cur-clmn-numbr-line[varmvibr-line] - 1.
      END.
    END.
  END.
  DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
    if cur-clmn-numbr-line[varmvibr-line] = -1 THEN cur-clmn-numbr-line[varmvibr-line] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-line:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 6 then do:
    return .
  end.
  DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
    if cur-clmn-numbr-line[varmvibr-line] = cur-clmn-loc THEN move-elementbr-line = varmvibr-line.
  END.
  RUN re-move-clmnbr-line (cur-clmn-loc, 6).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-line:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-line = 6 to EXTENT(cur-clmn-numbr-line):
    RUN re-move-clmnbr-line (cur-clmn-numbr-line[varmvlbr-line], varmvlbr-line).
  END.
  RUN start-mv-clmnbr-line.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-pump as INT EXTENT 18 no-undo.
DEF VAR varmvibr-pump       as INT no-undo.
DEF VAR varmvjbr-pump       as INT no-undo.
DEF VAR varmvkbr-pump       as INT no-undo.
DEF VAR varmvlbr-pump       as INT no-undo.
DEF VAR move-elementbr-pump as INT no-undo.
def var jjbr-pump           as int no-undo.
do varmvibr-pump = 1 to EXTENT(cur-clmn-numbr-pump):
  ASSIGN cur-clmn-numbr-pump[varmvibr-pump] = varmvibr-pump.
END.
RUN start-mv-clmnbr-pump.
PROCEDURE start-mv-clmnbr-pump:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-pump do:
  RUN re-move-clmnbr-pump ( 3, 18).
END.
ON ctrl-cursor-left OF BROWSE br-pump do:
  RUN re-move-clmnbr-pump (18, 3).
END.
PROCEDURE re-move-clmnbr-pump:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-pump = 1 TO EXTENT(cur-clmn-numbr-pump):
    if cur-clmn-numbr-pump[varmvibr-pump] = source-column THEN cur-clmn-numbr-pump[varmvibr-pump] = -1.
  END.
  if br-pump:MOVE-COLUMN(source-column, target-column) IN FRAME d-rvs then.
  if source-column > target-column THEN
  DO varmvjbr-pump = source-column - 1 to target-column BY -1:
    DO varmvibr-pump = 1 TO EXTENT(cur-clmn-numbr-pump):
        if cur-clmn-numbr-pump[varmvibr-pump] = varmvjbr-pump THEN DO:
          cur-clmn-numbr-pump[varmvibr-pump] = cur-clmn-numbr-pump[varmvibr-pump] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-pump = source-column + 1 to target-column:
    DO varmvibr-pump = 1 TO EXTENT(cur-clmn-numbr-pump):
      if cur-clmn-numbr-pump[varmvibr-pump] = varmvjbr-pump THEN DO:
        cur-clmn-numbr-pump[varmvibr-pump] = cur-clmn-numbr-pump[varmvibr-pump] - 1.
      END.
    END.
  END.
  DO varmvibr-pump = 1 TO EXTENT(cur-clmn-numbr-pump):
    if cur-clmn-numbr-pump[varmvibr-pump] = -1 THEN cur-clmn-numbr-pump[varmvibr-pump] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-pump:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 3 then do:
    return .
  end.
  DO varmvibr-pump = 1 TO EXTENT(cur-clmn-numbr-pump):
    if cur-clmn-numbr-pump[varmvibr-pump] = cur-clmn-loc THEN move-elementbr-pump = varmvibr-pump.
  END.
  RUN re-move-clmnbr-pump (cur-clmn-loc, 3).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-pump:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-pump = 3 to EXTENT(cur-clmn-numbr-pump):
    RUN re-move-clmnbr-pump (cur-clmn-numbr-pump[varmvlbr-pump], varmvlbr-pump).
  END.
  RUN start-mv-clmnbr-pump.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame d-rvs anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-line in frame d-rvs.
  return no-apply.
end.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F3 of frame d-rvs anywhere do:
  if b-lkp :sensitive then DO: apply "CHOOSE":U to b-lkp in frame d-rvs. END.
  return no-apply.
end.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame d-rvs anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame d-rvs. END.
  return no-apply.
end.
on end-error, stop of frame d-rvs do:
  apply "choose" to b-exit in frame d-rvs.
  return no-apply.
end.
ON WINDOW-CLOSE OF FRAME d-rvs
DO:
  p-next-prev = "QUIT".
  APPLY "END-ERROR":U TO SELF.
END.
on choose of b-notes in frame d-rvs
do:
  assign notes = c-rvs-doc.ps.
  run gbl/notes.w ( input pardoc-mode, input-output notes ).
  if c-rvs-doc.ps <> notes then do:
    do on stop undo, return no-apply :
      find c-rvs-doc exclusive-lock where recid (c-rvs-doc) = parrvs-rec.
      assign c-rvs-doc.ps = notes.
    end.
  end.
end.
on choose of b-history in frame d-rvs
do:
  define variable v-list as character no-undo.
  if available c-rvs-doc then do:
    run str/rvscdocs.w ( input        parparentproc,
                     input        "":U,
                     input        "one":U,
                     input        c-rvs-doc.rvs-code,
                     input-output v-list                  ).
  end.
end.
on choose of b-exit in frame d-rvs
do:
    p-next-prev = "QUIT".
end.
on mouse-select-dblclick, return of c-rvs-doc.agnt in frame d-rvs
do:
  run local-psn-chk in this-procedure ( input "agnt", input "ret-mouse" ).
  apply "entry" to c-rvs-doc.boss in frame d-rvs.
  return no-apply.
end.
on mouse-select-dblclick, return of c-rvs-doc.boss in frame d-rvs
do:
  run local-psn-chk in this-procedure ( input "boss", input "ret-mouse" ).
  apply "entry" to b-exit in frame d-rvs.
  return no-apply.
end.
on mouse-select-dblclick, return of c-rvs-doc.wrkr in frame d-rvs
do:
  run local-psn-chk in this-procedure ( input "wrkr", input "ret-mouse" ).
  apply "entry" to c-rvs-doc.agnt in frame d-rvs.
  return no-apply.
end.
ON CHOOSE OF B-next IN FRAME d-rvs
DO:
     run reposition-c-rvs-doc in this-procedure
  (input 'next':U
  ) no-error .
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-prev IN FRAME d-rvs
DO:
   run reposition-c-rvs-doc in this-procedure
  (input 'prev':U
  ) no-error .
if error-status:error then return no-apply.
END.
on choose of r-agnt in frame d-rvs
do:
  run local-psn-chk in this-procedure ( input "agnt", input "button" ).
  apply "entry" to c-rvs-doc.boss in frame d-rvs.
  return no-apply.
end.
on choose of r-boss in frame d-rvs
do:
   run local-psn-chk in this-procedure ( input "boss", input "button" ).
  apply "entry" to b-exit in frame d-rvs.
  return no-apply.
end.
on choose of r-wrkr in frame d-rvs
do:
  run local-psn-chk in this-procedure ( input "wrkr", input "button" ).
  apply "entry" to c-rvs-doc.agnt in frame d-rvs.
  return no-apply.
end.
on leave of c-rvs-doc.agnt in frame d-rvs
do:
   run local-psn-chk in this-procedure ( input "agnt", input "leave" ).
end.
on leave of c-rvs-doc.boss in frame d-rvs
do:
   run local-psn-chk in this-procedure ( input "boss", input "leave" ).
end.
on leave of c-rvs-doc.wrkr in frame d-rvs
do:
   run local-psn-chk in this-procedure ( input "wrkr", input "leave" ).
end.
on choose of b-mark in frame d-rvs do:
  run local-mark in this-procedure.
  varlog = br-line:select-next-row ().
  apply "entry" to br-line in frame d-rvs.
end.
on choose of b-lkp-pump in frame d-rvs
do:
  run proc-lookup in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
on choose of b-lkp in frame d-rvs
do:
  run proc-lkp in this-procedure no-error.
  if error-status :error then do: return no-apply. end.
end.
def var sort-labelbr-line   as character no-undo .
def var sort-clmnbr-line    as handle    no-undo .
def var cur-clmnbr-line     as handle    no-undo .
def var cur-clmn-locbr-line as integer   no-undo .
def var re-querybr-line     as logical   initial no no-undo .
on start-search, ctrl-o of br-line in frame d-rvs do:
   run sort-brbr-line
     (input (if available ub.c-rvs-line
             then recid(ub.c-rvs-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-line :
  define input parameter p-recid as recid no-undo .
  if re-querybr-line = no then do:
    assign
       cur-clmnbr-line = br-line:current-column in frame d-rvs
    .
    if sort-clmnbr-line <> ? then sort-clmnbr-line:column-fgcolor = 0.
    if cur-clmnbr-line = sort-clmnbr-line then do:
      assign
         sort-labelbr-line = ""
         sort-clmnbr-line = ?
      .
     end.
     else do:
       assign
         sort-labelbr-line = cur-clmnbr-line:label
         sort-clmnbr-line  = cur-clmnbr-line
         sort-clmnbr-line:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-line = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-line:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-line then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-line = cur-clmn-locbr-line + 1
    .
  end.
  case sort-labelbr-line:
        when '*'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by get-mark (buffer ub.c-rvs-line) .   . END.
        when 'Артикул'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.goods.artic .   . END.
        when 'Название'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.goods.gds-name .   . END.
        when 'Скл.место'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.pl-code .   . END.
        when 'Номер резервуара'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by place.loc1 .   . END.
        when 'Факт остаток'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-measure-qnty .   . END.
        when 'Измер. остаток'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.measure-qnty .   . END.
        when 'Учет'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.system-qnty .   . END.
        when 'Первонач.учет'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.orig-system-qnty .   . END.
        when 'Факт в!трубопроводе'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-add-qnty .   . END.
        when 'Отклонение(факт)'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by deviation-fact(buffer ub.c-rvs-line) .   . END.
        when 'Отклонение(измер)'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by deviation-measure(buffer ub.c-rvs-line) .   . END.
        when 'Допустимое!отклонение'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.tolerance .   . END.
        when 'Факт брутто'  then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-brutto-qnty .   . END.
        when ub.c-rvs-line.brutto-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.brutto-qnty .   . END.
        when ub.c-rvs-line.state-density:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-density .   . END.
        when ub.c-rvs-line.density:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.density .   . END.
        when ub.c-rvs-line.state-measure-cli-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-measure-cli-qnty .   . END.
        when ub.c-rvs-line.measure-cli-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.measure-cli-qnty .   . END.
        when ub.c-rvs-line.system-cli-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.system-cli-qnty .   . END.
        when ub.c-rvs-line.orig-system-cli-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.orig-system-cli-qnty .   . END.
        when ub.c-rvs-line.state-brutto-cli-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-brutto-cli-qnty .   . END.
        when ub.c-rvs-line.brutto-cli-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.brutto-cli-qnty .   . END.
        when ub.c-rvs-line.state-mh-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-mh-qnty .   . END.
        when ub.c-rvs-line.meas-mh-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.meas-mh-qnty .   . END.
        when ub.c-rvs-line.state-am-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-am-qnty .   . END.
        when ub.c-rvs-line.meas-am-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.meas-am-qnty .   . END.
        when ub.c-rvs-line.state-cf-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-cf-qnty .   . END.
        when ub.c-rvs-line.meas-cf-qnty:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.meas-cf-qnty .   . END.
        when ub.c-rvs-line.state-level-total:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-level-total .   . END.
        when ub.c-rvs-line.level-total:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.level-total .   . END.
        when ub.c-rvs-line.state-level-petrol:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-level-petrol .   . END.
        when ub.c-rvs-line.level-petrol:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.level-petrol .   . END.
        when ub.c-rvs-line.state-level-water:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-level-water .   . END.
        when ub.c-rvs-line.level-water:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.level-water .   . END.
        when ub.c-rvs-line.state-temperature:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.state-temperature .   . END.
        when ub.c-rvs-line.temperature:label in browse br-line then DO:   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U by ub.c-rvs-line.temperature .   . END.
    otherwise do:
      open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U.
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-line') then do:
          run mv-brw-defaultbr-line.
        end.
      if sort-labelbr-line <> "" then do:
        assign
          cur-clmnbr-line:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-line = ?
      .
    end.
  end case.
    if cur-clmn-locbr-line <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-line') then do:
        run ch-clmnbr-line in this-procedure (cur-clmn-locbr-line).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-line to recid p-recid no-error.
    apply "value-changed" to br-line in frame d-rvs.
  end.
  apply "entry" to br-line in frame d-rvs.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-line:
if cur-clmnbr-line = ? then do:
   open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U.
end.
else do:
   assign re-querybr-line = yes.
   run sort-brbr-line
     (input (if available ub.c-rvs-line
             then recid(ub.c-rvs-line)
             else ?
            )
     ).
   assign re-querybr-line = no.
end.
end.
def var sort-labelbr-pump   as character no-undo .
def var sort-clmnbr-pump    as handle    no-undo .
def var cur-clmnbr-pump     as handle    no-undo .
def var cur-clmn-locbr-pump as integer   no-undo .
def var re-querybr-pump     as logical   initial no no-undo .
on start-search, ctrl-o of br-pump in frame d-rvs do:
   run sort-brbr-pump
     (input (if available ub.c-rvs-line-pump
             then recid(ub.c-rvs-line-pump)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-pump :
  define input parameter p-recid as recid no-undo .
  if re-querybr-pump = no then do:
    assign
       cur-clmnbr-pump = br-pump:current-column in frame d-rvs
    .
    if sort-clmnbr-pump <> ? then sort-clmnbr-pump:column-fgcolor = 0.
    if cur-clmnbr-pump = sort-clmnbr-pump then do:
      assign
         sort-labelbr-pump = ""
         sort-clmnbr-pump = ?
      .
     end.
     else do:
       assign
         sort-labelbr-pump = cur-clmnbr-pump:label
         sort-clmnbr-pump  = cur-clmnbr-pump
         sort-clmnbr-pump:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-pump = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-pump:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-pump then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-pump = cur-clmn-locbr-pump + 1
    .
  end.
  case sort-labelbr-pump:
        when 'ТРК'  then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.pump-code .   . END.
        when 'П'  then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.nozzle-code .   . END.
        when ub.c-rvs-line-pump.state-mh-qnty:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.state-mh-qnty .   . END.
        when ub.c-rvs-line-pump.meas-mh-qnty:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.meas-mh-qnty .   . END.
        when ub.c-rvs-line-pump.state-am-qnty:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.state-am-qnty .   . END.
        when ub.c-rvs-line-pump.meas-am-qnty:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.meas-am-qnty .   . END.
        when ub.c-rvs-line-pump.state-cf-qnty:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.state-cf-qnty .   . END.
        when ub.c-rvs-line-pump.meas-cf-qnty:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.meas-cf-qnty .   . END.
        when ub.c-rvs-line-pump.state-mh-cnt:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.state-mh-cnt .   . END.
        when ub.c-rvs-line-pump.meas-mh-cnt:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.meas-mh-cnt .   . END.
        when ub.c-rvs-line-pump.state-el-cnt:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.state-el-cnt .   . END.
        when ub.c-rvs-line-pump.meas-el-cnt:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.meas-el-cnt .   . END.
        when ub.c-rvs-line-pump.state-am-cnt:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.state-am-cnt .   . END.
        when ub.c-rvs-line-pump.meas-am-cnt:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.meas-am-cnt .   . END.
        when ub.c-rvs-line-pump.state-cf-cnt:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.state-cf-cnt .   . END.
        when ub.c-rvs-line-pump.meas-cf-cnt:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.meas-cf-cnt .   . END.
        when ub.c-rvs-line-pump.icnt-code:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.icnt-code .   . END.
        when ub.c-rvs-line-pump.rvs-prev-code:label in browse br-pump then DO:   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num by ub.c-rvs-line-pump.rvs-prev-code .   . END.
    otherwise do:
      open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num.
        if can-do( this-procedure:internal-entries, 'mv-brw-defaultbr-pump') then do:
          run mv-brw-defaultbr-pump.
        end.
      if sort-labelbr-pump <> "" then do:
        assign
          cur-clmnbr-pump:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-pump = ?
      .
    end.
  end case.
    if cur-clmn-locbr-pump <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-pump') then do:
        run ch-clmnbr-pump in this-procedure (cur-clmn-locbr-pump).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-pump to recid p-recid no-error.
    apply "value-changed" to br-pump in frame d-rvs.
  end.
  apply "entry" to br-pump in frame d-rvs.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-pump:
if cur-clmnbr-pump = ? then do:
   open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num.
end.
else do:
   assign re-querybr-pump = yes.
   run sort-brbr-pump
     (input (if available ub.c-rvs-line-pump
             then recid(ub.c-rvs-line-pump)
             else ?
            )
     ).
   assign re-querybr-pump = no.
end.
end.
on value-changed of br-line in frame d-rvs do:
  if available ub.c-rvs-line then do:
    run re-open-query-srt-clmnbr-pump in this-procedure.
  end.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-rvs:PARENT eq ?
THEN FRAME d-rvs:PARENT = ACTIVE-WINDOW.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-rvs
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
on choose of b-help in frame d-rvs
do:
  apply "help":u to frame d-rvs .
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
                v-frame-width = frame d-rvs:width - 0.3
                fh            = frame d-rvs:first-child
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
    if frame d-rvs :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-rvs :height-chars)
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
    if frame d-rvs :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-rvs :height-chars)
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
            frame d-rvs :height = v-frame-height
          .
          if frame d-rvs :scrollable = true
          then do:
            assign
              frame d-rvs :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-rvs :scrollable = true
          then do:
            assign
              frame d-rvs :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-rvs :height = v-frame-height
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
      v-frame-height = frame d-rvs :height
      v-frame-virtual-height = frame d-rvs :virtual-height
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
      v-field-group-handle = frame d-rvs :first-child
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
    do with frame d-rvs
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-rvs :scrollable = true
      then do:
        assign
          frame d-rvs :virtual-height = frame d-rvs :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-rvs :height = frame d-rvs :height + p-change-value
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
        frame d-rvs :height = frame d-rvs :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-rvs :scrollable = true
      then do:
        assign
          frame d-rvs :virtual-height = frame d-rvs :virtual-height + p-change-value
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
          ,input  string(frame d-rvs :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-rvs :height)
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
    if frame d-rvs :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-rvs :width
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
    if frame d-rvs :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-rvs :width
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
            frame d-rvs :width = v-frame-width
          .
          if frame d-rvs :scrollable = true
          then do:
            assign
              frame d-rvs :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-rvs :scrollable = true
          then do:
            assign
              frame d-rvs :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-rvs :width = v-frame-width
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
      v-frame-width = frame d-rvs :width
      v-frame-virtual-width = frame d-rvs :virtual-width
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
      v-field-group-handle = frame d-rvs :first-child
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
    do with frame d-rvs
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-rvs :scrollable = true
      then do:
        assign
          frame d-rvs :virtual-width = frame d-rvs :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-rvs :width = v-frame-width + p-change-value
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
        frame d-rvs :width = frame d-rvs :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-rvs :scrollable = true
      then do:
        assign
          frame d-rvs :virtual-width = frame d-rvs :virtual-width + p-change-value
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
          ,input  string(frame d-rvs :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-rvs :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-rvs
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-rvs :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-rvs :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-rvs :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-rvs :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-rvs
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
      v-row-delta = v-new-row - frame d-rvs :height
      v-col-delta = v-new-col - frame d-rvs :width
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
            - frame d-rvs :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-rvs :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-rvs :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-rvs :height-chars
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
      v-diasize-current-frame-width  = frame d-rvs :width
      v-diasize-current-frame-height = frame d-rvs :height
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
    do with frame d-rvs
    :
      assign
        v-diasize-orig-frame-height = frame d-rvs :height
        v-diasize-orig-frame-width  = frame d-rvs :width
        v-diasize-browse-handle     = browse br-line :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-rvs :first-child
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
p-next-prev = "":U.
main-block:
do on error   undo main-block, leave main-block
   on end-key undo main-block, leave main-block
   on stop    undo main-block, leave main-block:
  p-next-prev = "QUIT".
   run mode-on in this-procedure
     no-error.
   if error-status :error then do:
     return error return-value .
   end.
   run ui-on in this-procedure.
end.
WAIT-FOR GO OF FRAME d-rvs.
run disable_ui in this-procedure.
procedure disable_ui :
  hide frame d-rvs.
end procedure.
procedure ui-on :
del-list = "".
find first ub.clients where ub.clients.obj-type = c-rvs-doc.obj-type and
                   ub.clients.obj-code = c-rvs-doc.obj-code no-lock.
assign frame d-rvs:title = "(" + substring (ub.clients.obj-name, 1, 35) +
       ") :   ДОКУМЕНТ СВЕРКИ - " + c-rvs-doc.status_ + " № " + c-rvs-doc.rvs-code + "      - " + pardoc-mode.
disable all with frame d-rvs.
enable b-exit b-help b-lkp b-lkp-pump B-prev B-next br-line br-pump b-history b-notes with frame d-rvs.
assign ub.c-rvs-line.temperature:read-only in browse br-line = yes
       ub.c-rvs-line-pump.rvs-prev-code:read-only in browse br-pump = yes.
if available ub.clients then disp ub.clients.obj-name with frame d-rvs.
else disp ? @ ub.clients.obj-name with frame d-rvs.
disp c-rvs-doc.obj-code
     c-rvs-doc.obj-type
     c-rvs-doc.doc-date
     c-rvs-doc.state-measure-qnty
     c-rvs-doc.measure-qnty
     c-rvs-doc.system-qnty
     c-rvs-doc.state-measure-cli-qnty
    c-rvs-doc.measure-cli-qnty
    c-rvs-doc.system-cli-qnty
    c-rvs-doc.system-cli-avrg-qnty
     c-rvs-doc.state-mh-qnty
     c-rvs-doc.state-am-qnty
    c-rvs-doc.state-cf-qnty
    c-rvs-doc.out-code
     with frame d-rvs.
open query br-line    for each  ub.c-rvs-line no-lock where              ub.c-rvs-line.rvs-code =    c-rvs-doc.rvs-code              and c-rvs-line.chip-num = c-rvs-doc.chip-num      , first ub.goods        no-lock where              ub.goods.gds-code        = ub.c-rvs-line.gds-code      , first ub.place                where              ub.place.obj-type        = ub.c-rvs-line.obj-type and              ub.place.obj-code        = ub.c-rvs-line.obj-code and              ub.place.pl-code         = ub.c-rvs-line.pl-code  and              ub.place.status_ <>      'удал':U.
if pardoc-mode = 'ПРОСМОТР':U then do:
  if rvs-line-rec      <> ? then reposition br-line      to recid rvs-line-rec      no-error.
end.
open query br-pump    for each ub.c-rvs-line-pump no-lock where             ub.c-rvs-line-pump.rvs-code = ub.c-rvs-line.rvs-code and             ub.c-rvs-line-pump.obj-type = ub.c-rvs-line.obj-type and             ub.c-rvs-line-pump.obj-code = ub.c-rvs-line.obj-code and             ub.c-rvs-line-pump.pl-code  = ub.c-rvs-line.pl-code  and             ub.c-rvs-line-pump.gds-code = ub.c-rvs-line.gds-code and               ub.c-rvs-line-pump.chip-num = ub.c-rvs-line.chip-num.
if rvs-line-pump-rec <> ? then reposition br-pump to recid rvs-line-pump-rec no-error.
 VIEW FRAME d-rvs.
end procedure.
PROCEDURE local-mark:
  if not available ub.c-rvs-line then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid16 as character no-undo .
define variable v-num-entry16 as integer   no-undo .
assign
  v-str-recid16 = trim( string( recid( ub.c-rvs-line ) , "->>>>>>>>>>>9":U ) )
  v-num-entry16 = lookup( v-str-recid16 , del-list )
.
if v-num-entry16 > 0 then do:
  assign
    entry( v-num-entry16, del-list ) = "":U
    del-list = trim( replace( del-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    del-list = del-list + ( if del-list = "":U then "":U else chr(44) ) + v-str-recid16
  .
end.
  br-line:refresh() in frame d-rvs .
END PROCEDURE.
procedure mode-on :
define variable v-shift-date like ub.shift-obj.shift-date no-undo.
define variable v-shift-num  like ub.shift-obj.shift-num  no-undo.
define variable v-shift-name as   character               no-undo.
define variable v-obj-date   as   date                    no-undo.
    if pardoc-mode  =   'ПРОСМОТР':U then
    do:
        find c-rvs-doc no-lock where recid (c-rvs-doc) = parrvs-rec and c-rvs-doc.action = integer('99':U).
    end.
if not available c-rvs-doc then do:
  message "Неправильно выбран документ.".
  undo, return error.
end.
end procedure.
procedure local-psn-chk:
define input parameter parman    as character no-undo.
define input parameter paraction as character no-undo.
if parman = "agnt" and paraction = "ret-mouse" then do:
  define variable v-ref-rec17   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-rvs c-rvs-doc.agnt <> ""
       and input frame d-rvs c-rvs-doc.agnt <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec17 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ c-rvs-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-rvs.
    assign frame d-rvs c-rvs-doc.agnt.
  end.
  else display ? @ c-rvs-doc.agnt
               ? @ agnt-name with frame d-rvs.
  apply "entry" to c-rvs-doc.boss
                            in frame d-rvs.
if available cli-buf then do:
      display cli-buf.obj-code @ c-rvs-doc.agnt cli-buf.obj-name @ agnt-name with frame d-rvs.
  end.
  else display ? @ c-rvs-doc.agnt ? @ agnt-name with frame d-rvs.
      return no-apply.
end.
if parman = "agnt" and paraction = "button" then do:
  define variable v-ref-rec18   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec18 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec18 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ c-rvs-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-rvs.
    assign frame d-rvs c-rvs-doc.agnt.
  end.
  else display ? @ c-rvs-doc.agnt
               ? @ agnt-name with frame d-rvs.
  apply "entry" to c-rvs-doc.boss
                            in frame d-rvs.
if available cli-buf then do:
      display cli-buf.obj-code @ c-rvs-doc.agnt cli-buf.obj-name @ agnt-name with frame d-rvs.
  end.
  else display ? @ c-rvs-doc.agnt ? @ agnt-name with frame d-rvs.
      return no-apply.
end.
if parman = "agnt" and paraction = "leave" then do:
  define variable v-ref-rec19   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ c-rvs-doc.agnt cli-buf.obj-name @ agnt-name with frame d-rvs.
          assign frame d-rvs c-rvs-doc.agnt.
  end.
  else display ? @ c-rvs-doc.agnt ? @ agnt-name with frame d-rvs.
end.
if parman = "boss" and paraction = "ret-mouse" then do:
  define variable v-ref-rec20   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-rvs c-rvs-doc.boss <> ""
       and input frame d-rvs c-rvs-doc.boss <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec20 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ c-rvs-doc.boss
            cli-buf.obj-name @ boss-name with frame d-rvs.
    assign frame d-rvs c-rvs-doc.boss.
  end.
  else display ? @ c-rvs-doc.boss
               ? @ boss-name with frame d-rvs.
  apply "entry" to  b-exit in frame d-rvs.
if available cli-buf then do:
      display cli-buf.obj-code @ c-rvs-doc.boss cli-buf.obj-name @ boss-name with frame d-rvs.
  end.
  else display ? @ c-rvs-doc.boss ? @ boss-name with frame d-rvs.
      return no-apply.
end.
if parman = "boss" and paraction = "button" then do:
  define variable v-ref-rec21   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec21 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec21 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ c-rvs-doc.boss
            cli-buf.obj-name @ boss-name with frame d-rvs.
    assign frame d-rvs c-rvs-doc.boss.
  end.
  else display ? @ c-rvs-doc.boss
               ? @ boss-name with frame d-rvs.
  apply "entry" to  b-exit in frame d-rvs.
if available cli-buf then do:
      display cli-buf.obj-code @ c-rvs-doc.boss cli-buf.obj-name @ boss-name with frame d-rvs.
  end.
  else display ? @ c-rvs-doc.boss ? @ boss-name with frame d-rvs.
      return no-apply.
end.
if parman = "boss" and paraction = "leave" then do:
  define variable v-ref-rec22   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ c-rvs-doc.boss cli-buf.obj-name @ boss-name with frame d-rvs.
          assign frame d-rvs c-rvs-doc.boss.
  end.
  else display ? @ c-rvs-doc.boss ? @ boss-name with frame d-rvs.
end.
if parman = "wrkr" and paraction = "ret-mouse" then do:
  define variable v-ref-rec23   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-rvs c-rvs-doc.wrkr <> ""
       and input frame d-rvs c-rvs-doc.wrkr <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec23 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ c-rvs-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-rvs.
    assign frame d-rvs c-rvs-doc.wrkr.
  end.
  else display ? @ c-rvs-doc.wrkr
               ? @ wrkr-name with frame d-rvs.
  apply "entry" to c-rvs-doc.agnt in frame d-rvs.
if available cli-buf then do:
      display cli-buf.obj-code @ c-rvs-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-rvs.
  end.
  else display ? @ c-rvs-doc.wrkr ? @ wrkr-name with frame d-rvs.
      return no-apply.
end.
if parman = "wrkr" and paraction = "button" then do:
  define variable v-ref-rec24   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec24 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec24 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ c-rvs-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-rvs.
    assign frame d-rvs c-rvs-doc.wrkr.
  end.
  else display ? @ c-rvs-doc.wrkr
               ? @ wrkr-name with frame d-rvs.
  apply "entry" to c-rvs-doc.agnt in frame d-rvs.
if available cli-buf then do:
      display cli-buf.obj-code @ c-rvs-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-rvs.
  end.
  else display ? @ c-rvs-doc.wrkr ? @ wrkr-name with frame d-rvs.
      return no-apply.
end.
if parman = "wrkr" and paraction = "leave" then do:
  define variable v-ref-rec25   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-rvs c-rvs-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ c-rvs-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-rvs.
          assign frame d-rvs c-rvs-doc.wrkr.
  end.
  else display ? @ c-rvs-doc.wrkr ? @ wrkr-name with frame d-rvs.
end.
end procedure.
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
PROCEDURE reposition-c-rvs-doc :
define input parameter p-direction as character no-undo .
define variable  v-new-c-rvs-doc-recid as recid no-undo .
do
on error undo, return error
:
  if valid-handle(p-call-prog)
  then do:
    run reposition-c-rvs-doc in p-call-prog
      (input  p-direction
      ,output v-new-c-rvs-doc-recid
      ).
    if v-new-c-rvs-doc-recid <> ?
    then do:
      define buffer buf_c-rvs-doc for ub.c-rvs-doc .
      find first buf_c-rvs-doc no-lock
        where recid(buf_c-rvs-doc) = v-new-c-rvs-doc-recid
        no-error .
      assign
      parrvs-rec = v-new-c-rvs-doc-recid
      p-next-prev = '':U
      .
    end.
  end.
  else do:
    message "Список документов сверки." view-as alert-box INFORMATION .
    return no-apply.
  end.
  END.
END PROCEDURE.
procedure proc-lookup:
define buffer buf_goods for ub.goods.
if not available ub.c-rvs-line-pump then do:
  message "Неправильный выбор строки.".
  return error.
end.
assign rvs-line-rec      = (if available ub.c-rvs-line then recid(ub.c-rvs-line) else ?)
       rvs-line-pump-rec = recid(ub.c-rvs-line-pump).
  case c-rvs-doc.rvs-type
  :
    when 'перед_док':U
    or when 'после_док':U
    then do:
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_lookup':U
    ,input  'object':U
    ,input  c-rvs-doc.host-code
    ,input  c-rvs-doc.obj-type
    ,input  c-rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    end.
    when 'смена':U
    then do:
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-shift_lookup':U
    ,input  'object':U
    ,input  c-rvs-doc.host-code
    ,input  c-rvs-doc.obj-type
    ,input  c-rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    end.
    when 'контроль':U
    then do:
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_lookup':U
    ,input  'object':U
    ,input  c-rvs-doc.host-code
    ,input  c-rvs-doc.obj-type
    ,input  c-rvs-doc.obj-code
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
        "Неизвестный тип сверки" skip
        "Тип сверки" c-rvs-doc.rvs-type skip
        "Код сверки" c-rvs-doc.rvs-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
if varlog <> yes then do: return error. end.
find first buf_goods where buf_goods.gds-code = ub.c-rvs-line-pump.gds-code no-lock.
run str/rvs-lnp-c.w
  (input  parparentproc
  ,input  recid(c-rvs-line-pump)
  ,input  'ПРОСМОТР':U
  ,input  " # "     + c-rvs-doc.rvs-code +
          " товар " + buf_goods.artic     + " " +
                      buf_goods.prod-type + " " +
                      string(buf_goods.prod-code) +
          " складское место " + string(ub.c-rvs-line-pump.pl-code) +
          " ТРК " + string(ub.c-rvs-line-pump.pump-code) +
          " пистолет " + string(ub.c-rvs-line-pump.nozzle-code)
  ) no-error.
if error-status :error then do:
   message "Ошибка при просмотре данных по ТРК." skip
           return-value skip
           error-status:get-message(1)
   view-as alert-box error.
   return error.
end.
find c-rvs-doc where recid(c-rvs-doc) = parrvs-rec.
end procedure.
procedure proc-lkp:
define buffer buf_goods for ub.goods.
if not available ub.c-rvs-line then do:
  message "Неправильный выбор строки.".
  return error.
end.
assign rvs-line-rec = recid(ub.c-rvs-line)
       rvs-line-pump-rec = (if available ub.c-rvs-line-pump then recid(ub.c-rvs-line-pump) else ?).
  case c-rvs-doc.rvs-type
  :
    when 'перед_док':U
    or when 'после_док':U
    then do:
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-on-doc_lookup':U
    ,input  'object':U
    ,input  c-rvs-doc.host-code
    ,input  c-rvs-doc.obj-type
    ,input  c-rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    end.
    when 'смена':U
    then do:
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-shift_lookup':U
    ,input  'object':U
    ,input  c-rvs-doc.host-code
    ,input  c-rvs-doc.obj-type
    ,input  c-rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    end.
    when 'контроль':U
    then do:
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_rvs-control_lookup':U
    ,input  'object':U
    ,input  c-rvs-doc.host-code
    ,input  c-rvs-doc.obj-type
    ,input  c-rvs-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output varlog
    )  .
end.
    end.
    when 'проверка':U
    then do:
      varlog = yes .
    end .
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Неизвестный тип сверки" skip
        "Тип сверки" c-rvs-doc.rvs-type skip
        "Код сверки" c-rvs-doc.rvs-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end case .
if varlog <> yes then do: return error. end.
find first buf_goods where buf_goods.gds-code = ub.c-rvs-line.gds-code no-lock.
if not error-status :error
   and is-gas(buf_goods.gds-code) then do:
    run str/rvs-lin-mask-c.w
      (input  parparentproc
      ,input  recid(c-rvs-line)
      ,input  'ПРОСМОТР':U
      ,input  " # "     + c-rvs-doc.rvs-code +
              " товар " + buf_goods.artic     + " " +
                          buf_goods.prod-type + " " +
                          string(buf_goods.prod-code) +
              " складское место " + string(ub.c-rvs-line.pl-code)
      ) no-error.
end.
else do:
run str/rvs-lin-c.w
  (input  parparentproc
  ,input  recid(c-rvs-line)
  ,input  'ПРОСМОТР':U
  ,input  " # "     + c-rvs-doc.rvs-code +
          " товар " + buf_goods.artic     + " " +
                      buf_goods.prod-type + " " +
                      string(buf_goods.prod-code) +
          " складское место " + string(ub.c-rvs-line.pl-code)
  ) no-error.
end.
if error-status :error then do:
   message "Ошибка при просмотре строки сверки." skip
           return-value skip
           error-status:get-message(1)
   view-as alert-box error.
   return error.
end.
find c-rvs-doc where recid(c-rvs-doc) = parrvs-rec.
run ui-on in this-procedure .
end procedure.
