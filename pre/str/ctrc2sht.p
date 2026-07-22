block-level on error undo, throw.
define  shared temp-table tt-susp-chk no-undo like ub.susp-chk .
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-rvs-doc-rec as recid         no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Добавление сменной сверки на основе контрольной":U .
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
  define new global shared variable g#lib-rvs as handle no-undo.
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable rec-rvs-shift as recid         no-undo .
define variable p-db-num      as integer       no-undo .
define variable p-userid      as character     no-undo .
define variable v-obj-date    as date          no-undo .
define variable r-line-shift  as recid         no-undo .
define variable r-pump-shift  as recid         no-undo .
define variable v-rvs-code    as character     no-undo .
define variable v-attr-value  as character no-undo .
define variable v-attr-type   as character no-undo .
define buffer buf_doc-attr for ub.doc-attr.
define buffer bf_rvs-doc          for ub.rvs-doc .
define buffer bf_rvs-line         for ub.rvs-line .
define buffer bf_rvs-line-pump    for ub.rvs-line-pump .
define buffer ctrl_rvs-doc        for ub.rvs-doc .
define buffer ctrl_rvs-line       for ub.rvs-line .
define buffer ctrl_rvs-line-pump  for ub.rvs-line-pump .
define buffer shift_rvs-doc       for ub.rvs-doc .
define buffer shift_rvs-line      for ub.rvs-line .
define buffer shift_rvs-line-pump for ub.rvs-line-pump .
define buffer bf_icnt-doc         for ub.icnt-doc .
define buffer bf_place            for ub.place .
define buffer bf_place-error      for ub.place .
define buffer bf_pl-gds           for ub.pl-gds .
define buffer bf_pl-pump-nozzle   for ub.pl-pump-nozzle .
define buffer buf_ctrl-rvs-line-attr   for ub.rvs-line-attr .
define buffer buf_shift-rvs-line-attr   for ub.rvs-line-attr .
define temp-table tt_pl-gds no-undo
  field pl-code  like ub.pl-gds.pl-code
  field gds-code like ub.pl-gds.gds-code
.
define temp-table tt_pmp-nzzl no-undo
  field pl-code     like ub.pl-pump-nozzle.pl-code
  field pump-code   like ub.pl-pump-nozzle.pump-code
  field nozzle-code like ub.pl-pump-nozzle.nozzle-code
.
  find first ctrl_rvs-doc no-lock where
      recid( ctrl_rvs-doc ) = p-rvs-doc-rec no-error .
  if not available ctrl_rvs-doc then do:
    run waitfram-hide in this-procedure .
    return error 'ОШИБКА! Не найден документ контрольной сверки.' .
  end.
  if can-find (first buf_doc-attr
               where ctrl_rvs-doc.rvs-code = buf_doc-attr.doc-code
                 and buf_doc-attr.attr-code = "rvs-auto"
                 and buf_doc-attr.attr-value = "Yes") then do:
 return error substitute( 'Нельзя создать сменную сверку по автоматической!'
                           ) .
      end.
  run str/deskshft.p
    ( input parparentproc
    , input no
    , input ctrl_rvs-doc.obj-type
    , input ctrl_rvs-doc.obj-code
    , input ctrl_rvs-doc.shift-date
    , input ctrl_rvs-doc.shift-num
    , input ctrl_rvs-doc.shift-name
    ) no-error .
  if error-status :error then do:
    return error substitute( '&1&2&3'
                           , error-status :get-message( 1 )
                           , chr(10)
                           , return-value ) .
  end.
Main-Block:
do on error undo Main-Block, return error return-value :
  run waitfram-show in this-procedure ( input 'Создание документа сменной сверки' ) .
  assign
  p-db-num  = v-cntxt-db-num
  p-userid  = v-cntxt-userid
  .
  if ctrl_rvs-doc.rvs-type <> 'контроль':U  then do:
    run waitfram-hide in this-procedure .
    return error substitute( 'Сверка должна иметь тип "&1", а не "&2".'
                           , 'контроль':U
                           , ctrl_rvs-doc.rvs-type ) .
  end.
  if ctrl_rvs-doc.is-full <> yes  then do:
    run waitfram-hide in this-procedure .
    return error 'Контрольная сверка должна быть ПОЛНОЙ.' .
  end.
  if ctrl_rvs-doc.status_ <> 'факт':U then do:
    run waitfram-hide in this-procedure .
    return error substitute( 'Cверка должна быть закрыта на "&1".'
                           , 'факт':U ) .
  end.
  find first bf_rvs-doc no-lock where
             bf_rvs-doc.obj-type =  ctrl_rvs-doc.obj-type and
             bf_rvs-doc.obj-code =  ctrl_rvs-doc.obj-code and
             bf_rvs-doc.status_  <> 'факт':U               and
           ( bf_rvs-doc.rvs-type =  'смена':U          or
             bf_rvs-doc.rvs-type =  'контроль':U )      no-error .
  if available bf_rvs-doc then do:
    run waitfram-hide in this-procedure .
    return error substitute( 'Имеется не закрытый документ сверки "&1".'
                           , bf_rvs-doc.rvs-code ) .
  end.
  find first bf_rvs-doc no-lock where
             bf_rvs-doc.obj-type   = ctrl_rvs-doc.obj-type   and
             bf_rvs-doc.obj-code   = ctrl_rvs-doc.obj-code   and
             bf_rvs-doc.shift-date = ctrl_rvs-doc.shift-date and
             bf_rvs-doc.shift-num  = ctrl_rvs-doc.shift-num  and
             bf_rvs-doc.status_    = 'факт':U                 and
             bf_rvs-doc.fact-order > ctrl_rvs-doc.fact-order and
           ( bf_rvs-doc.rvs-type   = 'смена':U            or
             bf_rvs-doc.rvs-type   = 'контроль':U )        no-error .
  if available bf_rvs-doc then do:
                find first buf_doc-attr where  bf_rvs-doc.rvs-code = buf_doc-attr.doc-code and buf_doc-attr.attr-code = "rvs-auto" and buf_doc-attr.attr-value = "Yes" no-error.
      if not available buf_doc-attr then do:
    run waitfram-hide in this-procedure .
    return error substitute( 'Имеется более поздний документ сверки "&1" &2.'
                           , bf_rvs-doc.rvs-code
                           , bf_rvs-doc.rvs-type ) .
  end.
  end.
  find first bf_icnt-doc no-lock where
             bf_icnt-doc.obj-type  = ctrl_rvs-doc.obj-type and
             bf_icnt-doc.obj-code  = ctrl_rvs-doc.obj-code and
             bf_icnt-doc.status_  <> 'факт':U               no-error .
  if available bf_icnt-doc then do:
    run waitfram-hide in this-procedure .
    return error substitute( 'Имеется не закрытый документ инвентаризации счетчиков ТРК "&1".'
                           , bf_icnt-doc.doc-code ) .
  end.
  for each bf_place  no-lock where
           bf_place.obj-type = ctrl_rvs-doc.obj-type and
           bf_place.obj-code = ctrl_rvs-doc.obj-code and
           bf_place.status_  = ""
    , each bf_pl-gds no-lock where
           bf_pl-gds.obj-type = bf_place.obj-type and
           bf_pl-gds.obj-code = bf_place.obj-code and
           bf_pl-gds.pl-code  = bf_place.pl-code
  :
    if trim( bf_place.loc1 ) = '':U or
             bf_place.loc1   = ?
    then do:
      return error substitute( 'В измеряемом резервуаре &1 задан неверный локальный номер "&2".'
                             , bf_place.pl-code
                             , bf_place.loc1 ) .
    end.
    find first bf_place-error no-lock where
               bf_place-error.obj-type =  bf_place.obj-type and
               bf_place-error.obj-code =  bf_place.obj-code and
               bf_place-error.is-meas  =  yes               and
               bf_place-error.loc1     =  bf_place.loc1     and
               bf_place-error.status_  =  ""                and
        recid( bf_place-error )        <> recid( bf_place ) no-error .
    if available bf_place-error then do:
      return error substitute( 'В измеряемом резервуаре &1 задан локальный номер &2, установленный также в резервуаре &3.'
                             , bf_place.pl-code
                             , bf_place.loc1
                             , bf_place-error.pl-code ) .
    end.
    find first tt_pl-gds where
               tt_pl-gds.pl-code  = bf_pl-gds.pl-code  and
               tt_pl-gds.gds-code = bf_pl-gds.gds-code no-error .
    if available tt_pl-gds then do:
      next .
    end.
    else do:
      create tt_pl-gds.
      assign
             tt_pl-gds.pl-code  = bf_pl-gds.pl-code
             tt_pl-gds.gds-code = bf_pl-gds.gds-code
      .
    end.
  end.
  for each bf_pl-pump-nozzle no-lock where
           bf_pl-pump-nozzle.obj-type = ctrl_rvs-doc.obj-type and
           bf_pl-pump-nozzle.obj-code = ctrl_rvs-doc.obj-code
    , each bf_pl-gds no-lock where
           bf_pl-gds.obj-type = bf_pl-pump-nozzle.obj-type and
           bf_pl-gds.obj-code = bf_pl-pump-nozzle.obj-code and
           bf_pl-gds.pl-code  = bf_pl-pump-nozzle.pl-code
  :
    find first tt_pl-gds where
               tt_pl-gds.pl-code  = bf_pl-gds.pl-code  and
               tt_pl-gds.gds-code = bf_pl-gds.gds-code no-error .
    if not available tt_pl-gds then do:
      return error substitute( 'Ошибка. Не найден резервуар &3 для ТРК &1, пистолет &2 (топливо &4).'
                             , bf_pl-pump-nozzle.pump-code
                             , bf_pl-pump-nozzle.nozzle-code
                             , bf_pl-gds.pl-code
                             , bf_pl-gds.gds-code ) .
    end.
    find first tt_pmp-nzzl where
               tt_pmp-nzzl.pl-code     = bf_pl-gds.pl-code             and
               tt_pmp-nzzl.pump-code   = bf_pl-pump-nozzle.pump-code   and
               tt_pmp-nzzl.nozzle-code = bf_pl-pump-nozzle.nozzle-code no-error .
    if available tt_pmp-nzzl then do:
      next .
    end.
    else do:
      create tt_pmp-nzzl.
      assign
             tt_pmp-nzzl.pl-code     = bf_pl-gds.pl-code
             tt_pmp-nzzl.pump-code   = bf_pl-pump-nozzle.pump-code
             tt_pmp-nzzl.nozzle-code = bf_pl-pump-nozzle.nozzle-code
      .
    end.
  end.
  trans-create:
  do on error undo Main-Block, return error return-value :
    find first ctrl_rvs-doc exclusive-lock where
        recid( ctrl_rvs-doc ) = p-rvs-doc-rec .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  ctrl_rvs-doc.obj-type
  ,input  ctrl_rvs-doc.obj-code
  ,output v-obj-date
  )  .
    do on error undo, return error return-value :
      create shift_rvs-doc .
      assign
        rec-rvs-shift = recid( shift_rvs-doc )
      .
      buffer-copy  ctrl_rvs-doc
           except  ctrl_rvs-doc.system-qnty
                   ctrl_rvs-doc.system-cli-qnty
                   ctrl_rvs-doc.status_
                   ctrl_rvs-doc.rvs-type
                   ctrl_rvs-doc.rvs-code
                   ctrl_rvs-doc.out-code
                   ctrl_rvs-doc.creid
                   ctrl_rvs-doc.doc-date
                   ctrl_rvs-doc.fact-order
                   ctrl_rvs-doc.is-full
               to shift_rvs-doc
           assign shift_rvs-doc.system-qnty     = 0.0
                  shift_rvs-doc.system-cli-qnty = 0.0
                  shift_rvs-doc.status_         = 'новый':U
                  shift_rvs-doc.rvs-type        = 'смена':U
                  shift_rvs-doc.out-code        = ?
                  shift_rvs-doc.creid           = p-userid
                  shift_rvs-doc.doc-date        = v-obj-date
                  shift_rvs-doc.is-full         = no
                  shift_rvs-doc.ps              = "Создана на основе контрольной сверки № " + ctrl_rvs-doc.rvs-code + "."
      .
      run doc-code in this-procedure
        (  input "main"
        ,  input ctrl_rvs-doc.obj-type
        ,  input ctrl_rvs-doc.obj-code
        ,  input ?
        , output v-rvs-code
        ) no-error .
      if error-status :error then do:
        run waitfram-hide in this-procedure .
        undo Main-Block, return error substitute( 'Ошибка при генерации номера документа.&1&2'
                                                , chr(10)
                                                , return-value ) .
      end.
      assign
        shift_rvs-doc.rvs-code = v-rvs-code
      .
      run gbl/factdate.p
        ( input        shift_rvs-doc.obj-type
        , input        shift_rvs-doc.obj-code
        , input-output shift_rvs-doc.fact-date
        , input-output shift_rvs-doc.fact-time
        , input-output shift_rvs-doc.shift-date
        , input-output shift_rvs-doc.shift-num
        , input-output shift_rvs-doc.shift-name
        , input        no
        ) no-error .
      if error-status :error then do:
        run waitfram-hide in this-procedure .
        undo Main-Block, return error 'Ошибка при установке даты в документе (rvs-doc).' .
      end.
      run gbl/chk-date.p
        ( input shift_rvs-doc.obj-type
        , input shift_rvs-doc.obj-code
        , input shift_rvs-doc.fact-date
        , input shift_rvs-doc.fact-time
        , input shift_rvs-doc.shift-date
        , input shift_rvs-doc.shift-num
        , input no
        ) no-error .
      if error-status :error then do:
        run waitfram-hide in this-procedure .
        undo Main-Block, return error substitute( 'Ошибка при проверке корректности дат. &1&2&3'
                                                , error-status :get-message( 1 )
                                                , chr(10)
                                                , return-value ) .
      end.
      run str/chk-rvs.p ( input recid( shift_rvs-doc ) ) no-error .
      if error-status :error then do:
        run waitfram-hide in this-procedure .
        undo Main-Block, return error substitute( 'Ошибка документа сверки. &1&2&3'
                                                , return-value
                                                , chr(10)
                                                , error-status :get-message( 1 ) ) .
      end.
      for each tt_pl-gds
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      :
        run gds-attr-value in this-procedure
          ( input  tt_pl-gds.gds-code
          , input  'ptrl-without-rvs':U
          , output v-attr-value
          , output v-attr-type
          ) .
        if v-attr-value <> "yes":U then do:
          find first bf_rvs-line no-lock
            where bf_rvs-line.rvs-code = ctrl_rvs-doc.rvs-code
              and bf_rvs-line.obj-type = ctrl_rvs-doc.obj-type
              and bf_rvs-line.obj-code = ctrl_rvs-doc.obj-code
              and bf_rvs-line.pl-code  = tt_pl-gds.pl-code
              and bf_rvs-line.gds-code = tt_pl-gds.gds-code
            no-error .
        if not available bf_rvs-line then do:
          undo Main-Block, return error substitute( 'Ошибка. На объекте &1 &2 появилось новое место хранения &3'
                                                  + '(товар &4), которого нет в сверке "&5".'
                                                  , ctrl_rvs-doc.obj-type
                                                  , ctrl_rvs-doc.obj-code
                                                  , tt_pl-gds.pl-code
                                                  , tt_pl-gds.gds-code
                                                  , ctrl_rvs-doc.rvs-code ) .
        end.
        end.
      end.
      for each bf_rvs-line no-lock
        where bf_rvs-line.rvs-code = ctrl_rvs-doc.rvs-code
          and bf_rvs-line.obj-type = ctrl_rvs-doc.obj-type
          and bf_rvs-line.obj-code = ctrl_rvs-doc.obj-code
      on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      :
        find first tt_pl-gds
          where tt_pl-gds.pl-code  = bf_rvs-line.pl-code
            and tt_pl-gds.gds-code = bf_rvs-line.gds-code
          no-error .
        if not available tt_pl-gds then do:
          undo Main-Block, return error substitute( 'Ошибка. На объекте &1 &2 исчезло место хранения &3'
                                                  + '(товар &4), которое есть в сверке "&5".'
                                                  , bf_rvs-line.obj-type
                                                  , bf_rvs-line.obj-code
                                                  , bf_rvs-line.pl-code
                                                  , bf_rvs-line.gds-code
                                                  , bf_rvs-line.rvs-code ) .
        end.
        find first ctrl_rvs-line exclusive-lock
          where recid( ctrl_rvs-line ) = recid( bf_rvs-line ) .
        create shift_rvs-line .
        assign
          r-line-shift = recid( shift_rvs-line )
        .
        buffer-copy  ctrl_rvs-line
             except  ctrl_rvs-line.system-qnty
                     ctrl_rvs-line.system-cli-qnty
                     ctrl_rvs-line.orig-system-qnty
                     ctrl_rvs-line.orig-system-cli-qnty
                     ctrl_rvs-line.rvs-code
                 to shift_rvs-line
             assign shift_rvs-line.system-qnty          = 0.0
                    shift_rvs-line.system-cli-qnty      = 0.0
                    shift_rvs-line.orig-system-qnty     = 0.0
                    shift_rvs-line.orig-system-cli-qnty = 0.0
                    shift_rvs-line.rvs-code             = shift_rvs-doc.rvs-code
        .
        for each tt_pmp-nzzl
          ,each tt_pl-gds
            where tt_pl-gds.pl-code = tt_pmp-nzzl.pl-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
        :
          run gds-attr-value in this-procedure
            ( input  tt_pl-gds.gds-code
            , input  'ptrl-without-rvs':U
            , output v-attr-value
            , output v-attr-type
            ) .
          if v-attr-value <> "yes" then do:
            find first bf_rvs-line-pump no-lock
              where bf_rvs-line-pump.rvs-code    = ctrl_rvs-doc.rvs-code
                and bf_rvs-line-pump.obj-type    = ctrl_rvs-doc.obj-type
                and bf_rvs-line-pump.obj-code    = ctrl_rvs-doc.obj-code
                and bf_rvs-line-pump.pl-code     = tt_pl-gds.pl-code
                and bf_rvs-line-pump.gds-code    = tt_pl-gds.gds-code
                and bf_rvs-line-pump.pump-code   = tt_pmp-nzzl.pump-code
                and bf_rvs-line-pump.nozzle-code = tt_pmp-nzzl.nozzle-code
              no-error .
          if not available bf_rvs-line-pump then do:
            undo Main-Block, return error substitute( 'Ошибка. На объекте &1 &2 появилась новая связка ТРК &3 '
                                                    + 'ПИСТОЛЕТ &4, которой нет в сверке "&5".'
                                                    , ctrl_rvs-doc.obj-type
                                                    , ctrl_rvs-doc.obj-code
                                                    , tt_pmp-nzzl.pump-code
                                                    , tt_pmp-nzzl.nozzle-code
                                                    , ctrl_rvs-doc.rvs-code   ) .
          end.
          end.
        end.
        for each bf_rvs-line-pump no-lock
          where bf_rvs-line-pump.rvs-code = ctrl_rvs-line.rvs-code
            and bf_rvs-line-pump.obj-type = ctrl_rvs-line.obj-type
            and bf_rvs-line-pump.obj-code = ctrl_rvs-line.obj-code
            and bf_rvs-line-pump.pl-code  = ctrl_rvs-line.pl-code
            and bf_rvs-line-pump.gds-code = ctrl_rvs-line.gds-code
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
        :
          find first tt_pmp-nzzl
            where tt_pmp-nzzl.pl-code     = bf_rvs-line-pump.pl-code
              and tt_pmp-nzzl.pump-code   = bf_rvs-line-pump.pump-code
              and tt_pmp-nzzl.nozzle-code = bf_rvs-line-pump.nozzle-code
            no-error .
          if not available tt_pmp-nzzl then do:
            undo Main-Block, return error substitute( 'Ошибка. На объекте &1 &2 исчезла связка ТРК &3 '
                                                    + 'ПИСТОЛЕТ &4, которая есть в сверке "&5".'
                                                    , bf_rvs-line-pump.obj-type
                                                    , bf_rvs-line-pump.obj-code
                                                    , bf_rvs-line-pump.pump-code
                                                    , bf_rvs-line-pump.nozzle-code
                                                    , bf_rvs-line-pump.rvs-code    ) .
          end.
          find first ctrl_rvs-line-pump exclusive-lock
            where recid( ctrl_rvs-line-pump ) = recid( bf_rvs-line-pump ) .
          create shift_rvs-line-pump .
          assign
            r-pump-shift = recid( shift_rvs-line-pump )
          .
          buffer-copy  ctrl_rvs-line-pump
               except  ctrl_rvs-line-pump.rvs-code
                   to shift_rvs-line-pump
               assign shift_rvs-line-pump.rvs-code = shift_rvs-doc.rvs-code
          .
          find first ctrl_rvs-line-pump        no-lock where
              recid( ctrl_rvs-line-pump ) = recid( bf_rvs-line-pump ) .
        end.
        find first ctrl_rvs-line        no-lock where
            recid( ctrl_rvs-line ) = recid( bf_rvs-line ) .
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "mask" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "delta-mass-qnty" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "izmer-density" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "input-type-p" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "input-type-t" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "input-type-l" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "twice-place-data" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "vol-pf-sug" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "state-vol-pf-sug" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "dens-pf-sug" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "state-dens-pf-sug" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "pressure-sug" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "state-pressure-sug" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "temp-izm-vol" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "measure-water-qnty" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "pokmi-water-qnty" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
          find first buf_ctrl-rvs-line-attr where buf_ctrl-rvs-line-attr.obj-code = ctrl_rvs-line.obj-code
                                              and buf_ctrl-rvs-line-attr.obj-type = ctrl_rvs-line.obj-type
                                              and buf_ctrl-rvs-line-attr.gds-code = ctrl_rvs-line.gds-code
                                              and buf_ctrl-rvs-line-attr.pl-code = ctrl_rvs-line.pl-code
                                              and buf_ctrl-rvs-line-attr.rvs-code = ctrl_rvs-line.rvs-code
                                              and buf_ctrl-rvs-line-attr.attr-code = "POkMI-result" no-lock no-error.
          if available (buf_ctrl-rvs-line-attr) then do:
              create buf_shift-rvs-line-attr.
              assign
                  buf_shift-rvs-line-attr.obj-code = buf_ctrl-rvs-line-attr.obj-code
                  buf_shift-rvs-line-attr.obj-type = buf_ctrl-rvs-line-attr.obj-type
                  buf_shift-rvs-line-attr.gds-code = buf_ctrl-rvs-line-attr.gds-code
                  buf_shift-rvs-line-attr.pl-code = buf_ctrl-rvs-line-attr.pl-code
                  buf_shift-rvs-line-attr.rvs-code = shift_rvs-doc.rvs-code
                  buf_shift-rvs-line-attr.attr-code = buf_ctrl-rvs-line-attr.attr-code
                  buf_shift-rvs-line-attr.attr-value = buf_ctrl-rvs-line-attr.attr-value.
          end.
      end.
    end.
    find first ctrl_rvs-doc        no-lock where
        recid( ctrl_rvs-doc ) = p-rvs-doc-rec .
  end.
  trans-close:
  do on error undo Main-Block, return error return-value :
    run waitfram-show in this-procedure ( input 'Закрываем документ сверки' ) .
    find first  ctrl_rvs-doc exclusive-lock where
        recid(  ctrl_rvs-doc ) = p-rvs-doc-rec .
    find first shift_rvs-doc exclusive-lock where
        recid( shift_rvs-doc ) = rec-rvs-shift .
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclose in g#lib-rvs ( input parparentproc ,
                      input recid( shift_rvs-doc ) ,
                      input yes ) no-error .
    if error-status :error then do:
      run waitfram-hide in this-procedure .
      undo Main-Block, return error substitute( 'Ошибка при закрытии документа сверки "&1" (закрытие).&2&3&2&4'
                                              , shift_rvs-doc.rvs-code
                                              , chr(10)
                                              , error-status :get-message( 1 )
                                              , return-value ) .
    end.
    find first shift_rvs-doc        no-lock where
        recid( shift_rvs-doc ) = rec-rvs-shift .
    find first  ctrl_rvs-doc        no-lock where
        recid(  ctrl_rvs-doc ) = p-rvs-doc-rec .
  end.
  do on error undo Main-Block, return error return-value :
    run waitfram-show in this-procedure ( input 'Закрываем документ на факт' ) .
    find first  ctrl_rvs-doc exclusive-lock where
        recid(  ctrl_rvs-doc ) = p-rvs-doc-rec .
    find first shift_rvs-doc exclusive-lock where
        recid( shift_rvs-doc ) = rec-rvs-shift .
    find first bf_rvs-line no-lock where
               bf_rvs-line.rvs-code           = shift_rvs-doc.rvs-code and
               bf_rvs-line.obj-type           = shift_rvs-doc.obj-type and
               bf_rvs-line.obj-code           = shift_rvs-doc.obj-code and
               bf_rvs-line.state-measure-qnty = ?                      no-error .
    define variable is-vir as logical no-undo.
    define variable v-value as character no-undo.
    define variable v-ok as logical no-undo.
    run placelib_get-attr(input "place-virtual"
                         ,input bf_rvs-line.obj-code
                         ,input bf_rvs-line.obj-type
                         ,input bf_rvs-line.pl-code
                         ,output v-value
                         ,output v-ok) no-error.
    is-vir = if (v-ok and logical(v-value)) then true else false.
    if available bf_rvs-line and not is-gas(bf_rvs-line.gds-code) and not is-vir then do:
      run waitfram-hide in this-procedure .
      undo Main-Block, return error substitute( 'Не заданы фактические остатки по товару &1.'
                                              , bf_rvs-line.gds-code ) .
    end.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_rvsclose in g#lib-rvs ( input parparentproc ,
                      input recid( shift_rvs-doc ) ,
                      input yes ) no-error .
    if error-status :error then do:
      run waitfram-hide in this-procedure .
      undo Main-Block, return error substitute( 'Ошибка при закрытии сверки "&1" на &2.&3&4&3&5'
                                              , shift_rvs-doc.rvs-code
                                              , 'факт':U
                                              , chr(10)
                                              , error-status :get-message( 1 )
                                              , return-value ) .
    end.
    find first shift_rvs-doc        no-lock where
        recid( shift_rvs-doc ) = rec-rvs-shift .
    release shift_rvs-doc .
    find first  ctrl_rvs-doc        no-lock where
        recid(  ctrl_rvs-doc ) = p-rvs-doc-rec .
  end.
  run waitfram-hide in this-procedure .
end.
