define input        parameter parparentproc as widget-handle no-undo .
define input        parameter p-mode        as character     no-undo .
define input-output parameter parrec-id     as recid         no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Обработка документа инвентаризации счетчиков ТРК (заведение, редактирование, просмотр)":U .
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
define new global shared variable g#libbcrcn as handle no-undo .
define variable varlog as logical no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
  define new global shared variable g#lib-rvs as handle no-undo.
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define buffer i-doc for ub.icnt-doc.
define buffer   cli-buf     for ub.clients.
define variable gds-rec         as   recid               no-undo .
define variable v-curr-obj-type like ub.clients.obj-type no-undo .
define variable v-curr-obj-code like ub.clients.obj-code no-undo .
define variable icnt-line-rec as recid no-undo.
define variable l-g#stat      as   character                  no-undo.
define variable l-g#type      as   character                  no-undo.
define variable l-g#internal  as   logical                    no-undo.
define variable vardelta      like i-doc.state-el-cnt no-undo.
define variable vardelta-line like ub.icnt-line.state-el-cnt  no-undo.
define variable ref-list      as   character                  no-undo.
FUNCTION func-delta RETURN DECIMAL (buffer bf_i-line for ub.icnt-line).
   return (bf_i-line.state-el-cnt - bf_i-line.state-mh-cnt).
END FUNCTION.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 7 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Вых":L
     SIZE 7 BY 1.
DEFINE BUTTON b-notes
     LABEL "При&м":L
     SIZE 7 BY 1.
DEFINE BUTTON b-read
     LABEL "Перечитать данные c ТРК"
     SIZE 24 BY 1.
DEFINE BUTTON r-acc
     IMAGE-UP          FILE "btn-down-arrow"
     IMAGE-DOWN        FILE "btn-down-arrow"
     IMAGE-INSENSITIVE FILE "btn-down-arrow"
     SIZE 3 BY .88.
DEFINE BUTTON r-agnt     LIKE r-acc.
DEFINE BUTTON r-boss     LIKE r-acc.
DEFINE BUTTON r-wrkr     LIKE r-acc.
DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE boss-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 14 BY 1 NO-UNDO.
DEFINE QUERY br-line FOR ub.icnt-line, ub.goods SCROLLING.
DEFINE BROWSE br-line QUERY br-line NO-LOCK DISPLAY
      ub.icnt-line.pump-code                 COLUMN-LABEL 'ТРК'
      ub.icnt-line.nozzle-code                 COLUMN-LABEL 'Пис!то!лет'
      goods.artic                 COLUMN-LABEL 'Артикул'
      ub.icnt-line.state-el-cnt                 COLUMN-LABEL 'Показания!электронного!счетчика'
      ub.icnt-line.state-mh-cnt                 COLUMN-LABEL 'Показания!механического!счетчика' format "->>>,>>>,>>9.999"
      func-delta (buffer ub.icnt-line) @ vardelta-line COLUMN-LABEL 'Разница'
      ub.icnt-line.meas-el-cnt                 COLUMN-LABEL 'Измерение!электронного!счетчика'
      goods.gds-name                 COLUMN-LABEL 'Название товара'
      ub.icnt-line.pl-code                 COLUMN-LABEL 'Резервуар'
      ENABLE ub.icnt-line.state-el-cnt ub.icnt-line.state-mh-cnt
    WITH SIZE 98 BY 12 separators.
DEFINE FRAME d-icnt
b-exit                            AT ROW 1 COL 1
i-doc.obj-code            AT ROW 1.5 COL 16  COLON-ALIGNED LABEL "Объект" VIEW-AS TEXT SIZE 7 BY 1
i-doc.obj-type            AT ROW 1.5 COL 23  COLON-ALIGNED NO-LABEL       VIEW-AS TEXT SIZE 7.13 BY 1
ub.clients.obj-name                  AT ROW 1.5 COL 33  COLON-ALIGNED NO-LABEL       VIEW-AS TEXT SIZE 40 BY 1 fgcolor 4
i-doc.fact-date           AT ROW 2.5 COL 40  COLON-ALIGNED
i-doc.shift-date          AT ROW 2.5 COL 58  COLON-ALIGNED LABEL "Смена"
i-doc.shift-num           AT ROW 2.5 COL 70  COLON-ALIGNED LABEL "П"
i-doc.shift-name         AT ROW 2.5 COL 80  COLON-ALIGNED LABEL "№"
i-doc.agnt                FORMAT "999999999"      AT ROW 5   COL 4.5 COLON-ALIGNED VIEW-AS FILL-IN SIZE 10 BY 1
agnt-name                         AT ROW 5   COL 15  COLON-ALIGNED NO-LABEL fgcolor 4
r-agnt                            AT ROW 5   COL 28  NO-LABEL
i-doc.wrkr                FORMAT "999999999"      AT ROW 4   COL 4.5 COLON-ALIGNED VIEW-AS FILL-IN SIZE 10 BY 1
wrkr-name                         AT ROW 4   COL 15  COLON-ALIGNED NO-LABEL fgcolor 4
r-wrkr                            AT ROW 4   COL 28  NO-LABEL
i-doc.boss                FORMAT "999999999"      AT ROW 6   COL 4.5 COLON-ALIGNED VIEW-AS FILL-IN SIZE 10 BY 1
boss-name                         AT ROW 6   COL 15  COLON-ALIGNED NO-LABEL fgcolor 4
r-boss                            AT ROW 6   COL 28  NO-LABEL
i-doc.state-el-cnt        LABEL "Показания электронных счетчиков" AT ROW 4   COL 75  COLON-ALIGNED VIEW-AS TEXT
i-doc.state-mh-cnt        LABEL "Показания механических счетчиков" AT ROW 5   COL 75  COLON-ALIGNED VIEW-AS TEXT
vardelta                          LABEL "Разница" AT ROW 6   COL 75  COLON-ALIGNED VIEW-AS TEXT
i-doc.meas-el-cnt         LABEL "Измерения электронных счетчиков" AT ROW 7   COL 75  COLON-ALIGNED VIEW-AS TEXT
br-line AT ROW 8 COL 1
b-read   AT ROW 20 COL 4
b-notes  AT ROW 20 COL 28
b-help   AT ROW 20 COL 35
SPACE(0) SKIP(0)
WITH VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D SCROLLABLE KEEP-TAB-ORDER.
ASSIGN
  FRAME d-icnt:SCROLLABLE                           = FALSE
  br-line:NUM-LOCKED-COLUMNS IN FRAME d-icnt = 3.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-line as INT EXTENT 9 no-undo.
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
  RUN re-move-clmnbr-line ( 4, 9).
END.
ON ctrl-cursor-left OF BROWSE br-line do:
  RUN re-move-clmnbr-line (9, 4).
END.
PROCEDURE re-move-clmnbr-line:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
    if cur-clmn-numbr-line[varmvibr-line] = source-column THEN cur-clmn-numbr-line[varmvibr-line] = -1.
  END.
  if br-line:MOVE-COLUMN(source-column, target-column) IN FRAME d-icnt then.
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
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmvibr-line = 1 TO EXTENT(cur-clmn-numbr-line):
    if cur-clmn-numbr-line[varmvibr-line] = cur-clmn-loc THEN move-elementbr-line = varmvibr-line.
  END.
  RUN re-move-clmnbr-line (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-line:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-line = 4 to EXTENT(cur-clmn-numbr-line):
    RUN re-move-clmnbr-line (cur-clmn-numbr-line[varmvlbr-line], varmvlbr-line).
  END.
  RUN start-mv-clmnbr-line.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame d-icnt anywhere do:
  if not available ub.goods then
    return no-apply.
  gds-rec = recid (ub.goods).
  run ref/gds-form.w ( input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to br-line in frame d-icnt.
  return no-apply.
end.
on end-error, stop of frame d-icnt do:
  apply "choose" to b-exit in frame d-icnt.
  return no-apply.
end.
ON choose OF b-notes IN FRAME d-icnt
DO:
define variable v-notes as character no-undo .
v-notes = i-doc.PS.
run gbl/notes.w ( input p-mode, input-output v-notes ).
if i-doc.PS <> v-notes then do:
  do on stop undo, return no-apply:
    find i-doc where recid (i-doc) = parrec-id exclusive.
    i-doc.PS = v-notes.
  end.
end.
END.
ON CHOOSE OF b-exit IN FRAME d-icnt
DO:
if p-mode = 'ИЗМЕНЕНИЕ':U  OR
   p-mode = 'ДОБАВЛЕНИЕ':U then do:
  if not can-find (first ub.icnt-line where ub.icnt-line.doc-code = i-doc.doc-code no-lock) then do:
    varlog = yes.
    message "В документе нет строк, поэтому он удаляется." view-as alert-box
      question buttons OK-Cancel update varlog.
    if varlog then do:
      delete i-doc.
      assign parrec-id = ?.
      return.
    end.
    else return no-apply.
  end.
  assign i-doc.wrkr i-doc.agnt i-doc.boss.
end.
END.
ON MOUSE-SELECT-DBLCLICK, return OF i-doc.agnt IN FRAME d-icnt
DO:
  RUN local-psn-chk ("agnt", "ret-mouse").
  apply "entry" to i-doc.boss in frame d-icnt.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF i-doc.boss IN FRAME d-icnt
DO:
  RUN local-psn-chk ("boss", "ret-mouse").
  apply "entry" to b-exit in frame d-icnt.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK, return OF i-doc.wrkr IN FRAME d-icnt
DO:
  RUN local-psn-chk ("wrkr", "ret-mouse").
  apply "entry" to i-doc.agnt in frame d-icnt.
  return no-apply.
END.
ON CHOOSE OF r-agnt IN FRAME d-icnt
DO:
  RUN local-psn-chk ("agnt", "button").
  apply "entry" to i-doc.boss in frame d-icnt.
  return no-apply.
END.
ON CHOOSE OF r-boss IN FRAME d-icnt
DO:
   RUN local-psn-chk ("boss", "button").
  apply "entry" to b-exit in frame d-icnt.
  return no-apply.
END.
ON CHOOSE OF r-wrkr IN FRAME d-icnt
DO:
  RUN local-psn-chk ("wrkr", "button").
  apply "entry" to i-doc.agnt in frame d-icnt.
  return no-apply.
END.
ON leave OF i-doc.agnt IN FRAME d-icnt
DO:
   RUN local-psn-chk ("agnt", "leave").
END.
ON leave OF i-doc.boss IN FRAME d-icnt
DO:
   RUN local-psn-chk ("boss", "leave").
END.
ON leave OF i-doc.wrkr IN FRAME d-icnt
DO:
   RUN local-psn-chk ("wrkr", "leave").
END.
ON CHOOSE OF b-read IN FRAME d-icnt
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
   RUN read-pump NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
message
  vss-workfile vss-revision vss-description skip
  "Ошибка при чтении счетчиков ТРК" skip
  "-----------Cистемная ошибка------------" skip
  return-value skip
  "------Ошибка исполнения программы------" skip
  trim(error-status :get-message(1)) +
  trim(error-status :get-message(2)) +
  trim(error-status :get-message(3)) +
  trim(error-status :get-message(4)) +
  trim(error-status :get-message(5)) skip
  view-as alert-box error .
   END.
   RUN UI-on.
END.
ON LEAVE OF ub.icnt-line.state-mh-cnt IN BROWSE br-line DO:
if ub.icnt-line.state-mh-cnt <> DECIMAL(ub.icnt-line.state-mh-cnt:SCREEN-VALUE IN BROWSE br-line) then do transaction:
   find current ub.icnt-line exclusive-lock.
   ASSIGN ub.icnt-line.state-mh-cnt = DECIMAL(ub.icnt-line.state-mh-cnt:SCREEN-VALUE IN BROWSE br-line).
   DISPLAY func-delta (buffer ub.icnt-line) @ vardelta-line with browse br-line.
   RUN recalc-icnt.
end.
RUN display-value.
END.
ON LEAVE OF ub.icnt-line.state-el-cnt IN BROWSE br-line DO:
if ub.icnt-line.state-el-cnt <> DECIMAL(ub.icnt-line.state-el-cnt:SCREEN-VALUE IN BROWSE br-line) then do transaction:
  find current ub.icnt-line exclusive-lock.
  ASSIGN ub.icnt-line.state-el-cnt = DECIMAL(ub.icnt-line.state-el-cnt:SCREEN-VALUE IN BROWSE br-line).
  DISPLAY func-delta (buffer ub.icnt-line) @ vardelta-line with browse br-line.
  RUN recalc-icnt.
end.
RUN display-value.
END.
def var sort-labelbr-line   as character no-undo .
def var sort-clmnbr-line    as handle    no-undo .
def var cur-clmnbr-line     as handle    no-undo .
def var cur-clmn-locbr-line as integer   no-undo .
def var re-querybr-line     as logical   initial no no-undo .
on start-search, ctrl-o of br-line in frame d-icnt do:
   run sort-brbr-line
     (input (if available ub.icnt-line
             then recid(ub.icnt-line)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-line :
  define input parameter p-recid as recid no-undo .
  if re-querybr-line = no then do:
    assign
       cur-clmnbr-line = br-line:current-column in frame d-icnt
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
        when 'ТРК'  then DO:   OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK BY ub.icnt-line.pump-code .   . END.
        when 'Пис!то!лет'  then DO:   OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK BY ub.icnt-line.nozzle-code .   . END.
        when 'Артикул'  then DO:   OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK BY goods.artic .   . END.
        when 'Показания!электронного!счетчика'  then DO:   OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK BY ub.icnt-line.state-el-cnt .   . END.
        when 'Показания!механического!счетчика'  then DO:   OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK BY ub.icnt-line.state-mh-cnt .   . END.
        when 'Разница'  then DO:   OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK BY func-delta (buffer ub.icnt-line) .   . END.
        when 'Измерение!электронного!счетчика'  then DO:   OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK BY ub.icnt-line.meas-el-cnt .   . END.
        when 'Название товара'  then DO:   OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK BY goods.gds-name .   . END.
        when 'Резервуар'  then DO:   OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK BY ub.icnt-line.pl-code .   . END.
    otherwise do:
      OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK.
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
    apply "value-changed" to br-line in frame d-icnt.
  end.
  apply "entry" to br-line in frame d-icnt.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-line:
if cur-clmnbr-line = ? then do:
   OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK.
end.
else do:
   assign re-querybr-line = yes.
   run sort-brbr-line
     (input (if available ub.icnt-line
             then recid(ub.icnt-line)
             else ?
            )
     ).
   assign re-querybr-line = no.
end.
end.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-icnt:PARENT eq ?
THEN FRAME d-icnt:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-icnt APPLY "END-ERROR":U TO SELF.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-icnt
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
on choose of b-help in frame d-icnt
do:
  apply "help":u to frame d-icnt .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-icnt:width - 0.3
                fh            = frame d-icnt:first-child
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-icnt :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-icnt :height-chars)
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
    if frame d-icnt :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-icnt :height-chars)
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
            frame d-icnt :height = v-frame-height
          .
          if frame d-icnt :scrollable = true
          then do:
            assign
              frame d-icnt :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-icnt :scrollable = true
          then do:
            assign
              frame d-icnt :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-icnt :height = v-frame-height
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
      v-frame-height = frame d-icnt :height
      v-frame-virtual-height = frame d-icnt :virtual-height
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
      v-field-group-handle = frame d-icnt :first-child
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
    do with frame d-icnt
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-icnt :scrollable = true
      then do:
        assign
          frame d-icnt :virtual-height = frame d-icnt :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-icnt :height = frame d-icnt :height + p-change-value
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
        frame d-icnt :height = frame d-icnt :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-icnt :scrollable = true
      then do:
        assign
          frame d-icnt :virtual-height = frame d-icnt :virtual-height + p-change-value
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
          ,input  string(frame d-icnt :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-icnt :height)
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
    if frame d-icnt :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-icnt :width
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
    if frame d-icnt :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-icnt :width
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
            frame d-icnt :width = v-frame-width
          .
          if frame d-icnt :scrollable = true
          then do:
            assign
              frame d-icnt :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-icnt :scrollable = true
          then do:
            assign
              frame d-icnt :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-icnt :width = v-frame-width
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
      v-frame-width = frame d-icnt :width
      v-frame-virtual-width = frame d-icnt :virtual-width
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
      v-field-group-handle = frame d-icnt :first-child
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
    do with frame d-icnt
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-icnt :scrollable = true
      then do:
        assign
          frame d-icnt :virtual-width = frame d-icnt :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-icnt :width = v-frame-width + p-change-value
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
        frame d-icnt :width = frame d-icnt :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-icnt :scrollable = true
      then do:
        assign
          frame d-icnt :virtual-width = frame d-icnt :virtual-width + p-change-value
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
          ,input  string(frame d-icnt :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-icnt :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-icnt
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-icnt :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-icnt :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-icnt :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-icnt :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-icnt
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
      v-row-delta = v-new-row - frame d-icnt :height
      v-col-delta = v-new-col - frame d-icnt :width
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
            - frame d-icnt :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-icnt :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-icnt :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-icnt :height-chars
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
      v-diasize-current-frame-width  = frame d-icnt :width
      v-diasize-current-frame-height = frame d-icnt :height
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
    do with frame d-icnt
    :
      assign
        v-diasize-orig-frame-height = frame d-icnt :height
        v-diasize-orig-frame-width  = frame d-icnt :width
        v-diasize-browse-handle     = browse br-line :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-icnt :first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   run mode-on no-error.
   if error-status:error then return error.
   if p-mode <> 'ПРОСМОТР':U then icnt-line-rec = ?.
   run UI-on.
   WAIT-FOR GO OF FRAME d-icnt focus b-read.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-icnt.
END PROCEDURE.
PROCEDURE UI-on :
find ub.clients where ub.clients.obj-type = i-doc.obj-type and
                   ub.clients.obj-code = i-doc.obj-code no-lock.
ASSIGN frame d-icnt:title = "(" + substring (clients.obj-name, 1, 35) +
       ") :   ДОКУМЕНТ ИНВЕНТАРИЗАЦИИ СЧЕТЧИКОВ ТРК - " + i-doc.status_ + " № " + i-doc.doc-code + "      - " + p-mode.
disable all with frame d-icnt.
enable b-exit b-help  br-line b-notes with frame d-icnt.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_icnt-doc_upd-el-cnt':U
    ,input  'object':U
    ,input  clients.host-code
    ,input  clients.obj-type
    ,input  clients.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output varlog
    )  .
end.
if not varlog then do:
    ASSIGN ub.icnt-line.state-el-cnt:READ-ONLY in browse br-line = YES.
end.
if p-mode = 'ПРОСМОТР':U then do:
   ASSIGN
     ub.icnt-line.state-el-cnt:READ-ONLY in browse br-line = YES
     ub.icnt-line.state-mh-cnt:READ-ONLY in browse br-line = YES.
end.
if i-doc.status_ = 'новый':U and
   (p-mode = 'ДОБАВЛЕНИЕ':U or
    p-mode = 'ИЗМЕНЕНИЕ':U        ) then do:
      enable i-doc.wrkr
             i-doc.agnt
             i-doc.boss
             r-wrkr r-agnt r-boss
             b-read
             with frame d-icnt.
end.
disp i-doc.obj-code
     i-doc.obj-type
     with frame d-icnt.
run display-value.
  define variable v-ref-rec12   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display i-doc.wrkr with frame d-icnt.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-icnt i-doc.wrkr
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-icnt.
  end.
  else display ? @ i-doc.wrkr ? @ wrkr-name with frame d-icnt.
  define variable v-ref-rec13   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display i-doc.agnt with frame d-icnt.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-icnt i-doc.agnt
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.agnt cli-buf.obj-name @ agnt-name with frame d-icnt.
  end.
  else display ? @ i-doc.agnt ? @ agnt-name with frame d-icnt.
  define variable v-ref-rec14   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display i-doc.boss with frame d-icnt.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-icnt i-doc.boss
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.boss cli-buf.obj-name @ boss-name with frame d-icnt.
  end.
  else display ? @ i-doc.boss ? @ boss-name with frame d-icnt.
OPEN QUERY br-line                                                    FOR EACH ub.icnt-line WHERE ub.icnt-line.doc-code = i-doc.doc-code NO-LOCK,                                 FIRST ub.goods OUTER-JOIN WHERE goods.gds-code        = ub.icnt-line.gds-code NO-LOCK.
if p-mode = 'ПРОСМОТР':U then do:
  if icnt-line-rec <> ? then reposition br-line to recid icnt-line-rec no-error.
  apply "entry" to br-line in frame d-icnt.
end.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    apply "entry" to br-line in frame d-icnt.
end.
if num-results("br-line") > 0 then do:
   if br-line:refresh() then.
end.
END PROCEDURE.
PROCEDURE mode-on :
define variable v-today as date      no-undo.
define buffer bf_pump-nozzle    for ub.pump-nozzle.
define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer bf_pl-gds         for ub.pl-gds.
case p-mode :
  when 'ДОБАВЛЕНИЕ':U then do:
    tr:
    do transaction on error undo tr, return error return-value
                   on stop  undo tr, return error return-value
                   on quit  undo tr, return error return-value :
       run waitfram-show in this-procedure ("Создаем документ.").
       create i-doc.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-today
  )  .
       run doc-code in this-procedure
        (input  "main",
         input  v-curr-obj-type,
         input  v-curr-obj-code,
         input  ?,
         output i-doc.doc-code) no-error.
       if error-status:error then do:
         message "Ошибка при генерации номера документа." skip
                 return-value
         view-as alert-box error.
         return error.
       end.
       assign
        i-doc.host-code = v-cntxt-host-code-obj
        i-doc.obj-type  = v-cntxt-obj-type
        i-doc.obj-code  = v-cntxt-obj-code
        i-doc.status_   = 'новый':U
        i-doc.flag_     = no
        i-doc.creid     = v-cntxt-userid
        i-doc.PS        = "@"
        i-doc.doc-date  = v-today
        parrec-id = recid (i-doc)
       .
       for each bf_pump-nozzle where bf_pump-nozzle.obj-type = i-doc.obj-type and
                                     bf_pump-nozzle.obj-code = i-doc.obj-code and
                                     bf_pump-nozzle.is-meas  = yes                    no-lock
                                     on error undo tr, return error return-value
                                     :
           find first bf_pl-pump-nozzle where bf_pl-pump-nozzle.obj-type    = bf_pump-nozzle.obj-type    and
                                              bf_pl-pump-nozzle.obj-code    = bf_pump-nozzle.obj-code    and
                                              bf_pl-pump-nozzle.pump-code   = bf_pump-nozzle.pump-code   and
                                              bf_pl-pump-nozzle.nozzle-code = bf_pump-nozzle.nozzle-code no-lock no-error.
           if available bf_pl-pump-nozzle then do:
              find first bf_pl-gds where bf_pl-gds.obj-type  = bf_pl-pump-nozzle.obj-type and
                                         bf_pl-gds.obj-code  = bf_pl-pump-nozzle.obj-code and
                                         bf_pl-gds.pl-code   = bf_pl-pump-nozzle.pl-code  no-lock no-error.
           end.
           create ub.icnt-line.
           assign ub.icnt-line.doc-code     = i-doc.doc-code
                  ub.icnt-line.obj-type     = i-doc.obj-type
                  ub.icnt-line.obj-code     = i-doc.obj-code
                  ub.icnt-line.pump-code    = bf_pump-nozzle.pump-code
                  ub.icnt-line.nozzle-code  = bf_pump-nozzle.nozzle-code
                  ub.icnt-line.pl-code      = (if available bf_pl-pump-nozzle then bf_pl-pump-nozzle.pl-code else ?)
                  ub.icnt-line.gds-code     = (if available bf_pl-gds         then bf_pl-gds.gds-code        else ?)
                  ub.icnt-line.meas-el-cnt  = ?
                  ub.icnt-line.state-el-cnt = ?
                  ub.icnt-line.state-mh-cnt = ?
                  .
       end.
       find first ub.icnt-line no-error.
       if available ub.icnt-line then do:
         run waitfram-show in this-procedure ("Считываем данные со счетчиков ТРК.").
         run read-pump no-error.
         if error-status:error then do:
           run waitfram-hide in this-procedure .
message
  vss-workfile vss-revision vss-description skip
  "Ошибка при чтении счетчиков ТРК" skip
  "-----------Cистемная ошибка------------" skip
  return-value skip
  "------Ошибка исполнения программы------" skip
  trim(error-status :get-message(1)) +
  trim(error-status :get-message(2)) +
  trim(error-status :get-message(3)) +
  trim(error-status :get-message(4)) +
  trim(error-status :get-message(5)) skip
  view-as alert-box error .
           undo tr, return error.
         END.
         run waitfram-hide in this-procedure .
       end.
    end.
  end.
  when 'ИЗМЕНЕНИЕ':U then do:
    tr:
    do transaction on error undo tr, return error
                   on stop  undo tr, return error
                   on quit  undo tr, return error :
       find i-doc where recid (i-doc) = parrec-id no-error.
       if available i-doc then do:
         if i-doc.status_ = 'факт':U then do:
           find i-doc where recid (i-doc) = parrec-id no-lock.
           message "Документ уже закрыт. Изменение невозможно.".
           undo, return error.
         end.
         find i-doc where recid (i-doc) = parrec-id exclusive.
       end.
    end.
  end.
  when 'ПРОСМОТР':U then do:
     find i-doc where recid (i-doc) = parrec-id no-lock no-error.
  end.
end.
if not available i-doc then do:
  message "Неправильно выбран документ.".
  undo, return error.
end.
display i-doc.fact-date
        i-doc.shift-date
        i-doc.shift-num
        i-doc.shift-name           with frame d-icnt.
END PROCEDURE.
PROCEDURE local-psn-chk:
DEFINE INPUT PARAMETER parMan    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER parAction AS CHARACTER NO-UNDO.
IF parMan = "agnt" AND parAction = "ret-mouse" THEN DO:
  define variable v-ref-rec16   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-icnt i-doc.agnt <> ""
       and input frame d-icnt i-doc.agnt <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec16
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec16 = integer( ref-list ).
    find cli-buf where recid (cli-buf) =
       v-ref-rec16
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ i-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-icnt.
    assign frame d-icnt i-doc.agnt.
  end.
  else display ? @ i-doc.agnt
               ? @ agnt-name with frame d-icnt.
  apply "entry" to i-doc.boss
                            in frame d-icnt.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.agnt cli-buf.obj-name @ agnt-name with frame d-icnt.
  end.
  else display ? @ i-doc.agnt ? @ agnt-name with frame d-icnt.
      return no-apply.
END.
IF parMan = "agnt" AND parAction = "button" THEN DO:
  define variable v-ref-rec17   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec17 = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec17
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec17 = integer( ref-list ).
    find cli-buf where recid (cli-buf) =
       v-ref-rec17
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ i-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-icnt.
    assign frame d-icnt i-doc.agnt.
  end.
  else display ? @ i-doc.agnt
               ? @ agnt-name with frame d-icnt.
  apply "entry" to i-doc.boss
                            in frame d-icnt.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.agnt cli-buf.obj-name @ agnt-name with frame d-icnt.
  end.
  else display ? @ i-doc.agnt ? @ agnt-name with frame d-icnt.
      return no-apply.
END.
IF parMan = "agnt" AND parAction = "leave" THEN DO:
  define variable v-ref-rec18   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.agnt cli-buf.obj-name @ agnt-name with frame d-icnt.
          assign frame d-icnt i-doc.agnt.
  end.
  else display ? @ i-doc.agnt ? @ agnt-name with frame d-icnt.
END.
IF parMan = "boss" AND parAction = "ret-mouse" THEN DO:
  define variable v-ref-rec19   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-icnt i-doc.boss <> ""
       and input frame d-icnt i-doc.boss <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec19
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec19 = integer( ref-list ).
    find cli-buf where recid (cli-buf) =
       v-ref-rec19
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ i-doc.boss
            cli-buf.obj-name @ boss-name with frame d-icnt.
    assign frame d-icnt i-doc.boss.
  end.
  else display ? @ i-doc.boss
               ? @ boss-name with frame d-icnt.
  apply "entry" to  b-exit in frame d-icnt.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.boss cli-buf.obj-name @ boss-name with frame d-icnt.
  end.
  else display ? @ i-doc.boss ? @ boss-name with frame d-icnt.
      return no-apply.
END.
IF parMan = "boss" AND parAction = "button" THEN DO:
  define variable v-ref-rec20   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec20 = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec20
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec20 = integer( ref-list ).
    find cli-buf where recid (cli-buf) =
       v-ref-rec20
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ i-doc.boss
            cli-buf.obj-name @ boss-name with frame d-icnt.
    assign frame d-icnt i-doc.boss.
  end.
  else display ? @ i-doc.boss
               ? @ boss-name with frame d-icnt.
  apply "entry" to  b-exit in frame d-icnt.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.boss cli-buf.obj-name @ boss-name with frame d-icnt.
  end.
  else display ? @ i-doc.boss ? @ boss-name with frame d-icnt.
      return no-apply.
END.
IF parMan = "boss" AND parAction = "leave" THEN DO:
  define variable v-ref-rec21   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.boss cli-buf.obj-name @ boss-name with frame d-icnt.
          assign frame d-icnt i-doc.boss.
  end.
  else display ? @ i-doc.boss ? @ boss-name with frame d-icnt.
END.
IF parMan = "wrkr" AND parAction = "ret-mouse" THEN DO:
  define variable v-ref-rec22   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-icnt i-doc.wrkr <> ""
       and input frame d-icnt i-doc.wrkr <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec22
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec22 = integer( ref-list ).
    find cli-buf where recid (cli-buf) =
       v-ref-rec22
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ i-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-icnt.
    assign frame d-icnt i-doc.wrkr.
  end.
  else display ? @ i-doc.wrkr
               ? @ wrkr-name with frame d-icnt.
  apply "entry" to i-doc.agnt in frame d-icnt.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-icnt.
  end.
  else display ? @ i-doc.wrkr ? @ wrkr-name with frame d-icnt.
      return no-apply.
END.
IF parMan = "wrkr" AND parAction = "button" THEN DO:
  define variable v-ref-rec23   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec23 = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec23
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec23 = integer( ref-list ).
    find cli-buf where recid (cli-buf) =
       v-ref-rec23
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ i-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-icnt.
    assign frame d-icnt i-doc.wrkr.
  end.
  else display ? @ i-doc.wrkr
               ? @ wrkr-name with frame d-icnt.
  apply "entry" to i-doc.agnt in frame d-icnt.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-icnt.
  end.
  else display ? @ i-doc.wrkr ? @ wrkr-name with frame d-icnt.
      return no-apply.
END.
IF parMan = "wrkr" AND parAction = "leave" THEN DO:
  define variable v-ref-rec24   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-icnt i-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ i-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-icnt.
          assign frame d-icnt i-doc.wrkr.
  end.
  else display ? @ i-doc.wrkr ? @ wrkr-name with frame d-icnt.
END.
END PROCEDURE.
PROCEDURE read-pump:
define buffer bf_icnt-line for ub.icnt-line.
define variable varcur-pump as logical no-undo.
define variable varnum      as integer no-undo.
define variable ptoldfilvalue as character no-undo.
define variable ptoldfiltype  as character no-undo.
for each tt-pump-nozzle:
    delete tt-pump-nozzle.
end.
for each bf_icnt-line where bf_icnt-line.doc-code = i-doc.doc-code:
    create tt-pump-nozzle.
    assign tt-pump-nozzle.obj-type    = bf_icnt-line.obj-type
           tt-pump-nozzle.obj-code    = bf_icnt-line.obj-code
           tt-pump-nozzle.pump-code   = bf_icnt-line.pump-code
           tt-pump-nozzle.nozzle-code = bf_icnt-line.nozzle-code
           tt-pump-nozzle.gds-code    = bf_icnt-line.gds-code.
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'ptoldfil':u
  ,input  i-doc.host-code
  ,input  i-doc.obj-type
  ,input  i-doc.obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output ptoldfilvalue
  ,output ptoldfiltype
  ) no-error .
if ptoldfilvalue = "yes":u then do:
  run gbl/d-askw.w ("Выбор источника данных с информацией по ТРК",
                "Будем читать текущие данные с ТРК или возьмем данные из файла?",
                "|^",
                "Текущие данные|Из файлов|Отмена",
                "Запускается программа для обращения к датчикам ТРК|Берутся уже сохраненные данные из файла|Ничего не делаем",
                1,
                3,
                output varnum
                ).
  case varnum:
  when 3 then do:
    undo, return error.
  end.
  when 2 then do:
    assign
      varcur-pump = no.
  end.
  when 1 then do:
    assign
      varcur-pump = yes.
  end.
  end case.
end.
else do:
  assign
    varcur-pump = yes.
end.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_anls-pmp in g#lib-rvs ( input              parparentproc ,
                      input              i-doc.obj-type ,
                      input              i-doc.obj-code ,
                      input              yes ,
                      input-output table tt-pump-nozzle-file ,
                      input-output table tt-pump-nozzle ,
                      input              varcur-pump ,
                      input              yes ,
                      input              no) no-error .
if error-status :error then do:
   return error return-value.
end.
if return-value <> "":U then do:
  message
    substitute("&1", return-value ) skip
    view-as alert-box information .
end.
do transaction on error undo, return error :
  for each bf_icnt-line where bf_icnt-line.doc-code = i-doc.doc-code:
      find first tt-pump-nozzle where tt-pump-nozzle.obj-type    = bf_icnt-line.obj-type    and
                                      tt-pump-nozzle.obj-code    = bf_icnt-line.obj-code    and
                                      tt-pump-nozzle.pump-code   = bf_icnt-line.pump-code   and
                                      tt-pump-nozzle.nozzle-code = bf_icnt-line.nozzle-code.
      assign bf_icnt-line.meas-el-cnt  = tt-pump-nozzle.meas-el-cnt
             bf_icnt-line.state-el-cnt = bf_icnt-line.meas-el-cnt.
  end.
  RUN recalc-icnt.
end.
END PROCEDURE.
PROCEDURE recalc-icnt:
define buffer bf_icnt-line for ub.icnt-line.
for each bf_icnt-line where bf_icnt-line.doc-code = i-doc.doc-code:
    accumulate bf_icnt-line.meas-el-cnt  (total)
               bf_icnt-line.state-el-cnt (total)
               bf_icnt-line.state-mh-cnt (total).
end.
assign i-doc.meas-el-cnt  = (accum total bf_icnt-line.meas-el-cnt)
       i-doc.state-el-cnt = (accum total bf_icnt-line.state-el-cnt)
       i-doc.state-mh-cnt = (accum total bf_icnt-line.state-mh-cnt).
END PROCEDURE.
procedure display-value:
display
     i-doc.state-el-cnt
     i-doc.state-mh-cnt
     i-doc.state-el-cnt - i-doc.state-mh-cnt @ vardelta
     i-doc.meas-el-cnt
     with frame d-icnt.
end procedure.
