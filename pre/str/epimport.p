block-level on error undo, throw.
define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-handle      as handle no-undo .
define input  parameter p-ext-doc-type as character no-undo .
DEFINE TEMP-TABLE x_parts NO-UNDO LIKE ub.parts.
define input parameter table for x_parts .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: epimport.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/epimport.p $":U .
define variable vss-description as character no-undo init "Создание Возврата поставщику, списания и внутреннего расхода  по списку партий".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_parts for x_parts  .
define temp-table temp-cli no-undo like ub.clients .
define temp-table temp-vat no-undo
  field vat-type as character
  index pi vat-type
.
define temp-table tt2-doc-line      no-undo like lib-trn_ret-line.
define variable i as integer   no-undo .
define variable i-err as integer   no-undo .
define variable v-spis as character no-undo .
define variable v-trn-doc as character no-undo .
define buffer buf_trn-doc for ub.trn-doc  .
define buffer new_trn-doc for ub.trn-doc  .
define variable v-cntxt-cash-pay as integer   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-doc-type as character no-undo .
define variable v-discnt-type as character no-undo .
define variable v-ret-supp     as logical   no-undo .
define variable v-internal as logical   no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer   no-undo .
define variable v-cli-name as character no-undo .
define variable v-b-code as integer   no-undo .
if p-ext-doc-type = 'ev':U
 then do:
  run cb_choice-obj in p-handle (
        output v-cli-type ,
        output v-cli-code ,
        output v-cli-name  )
        no-error .
        if error-status :error then do:
            message
            return-value
            error-status :get-message(1)
            view-as alert-box error .
           return .
        end.
  end.
case p-ext-doc-type:
when  'ep':U  then do:
   assign
      v-ext-doc-type = p-ext-doc-type
      v-doc-type     = 'рас':U
      v-discnt-type  = 'процент':U
      v-ret-supp     = true
      v-internal     = false
   .
end.
when  'ev':U  then do:
   assign
      v-ext-doc-type = p-ext-doc-type
      v-doc-type     = 'рас':U
      v-discnt-type  = 'процент':U
      v-ret-supp     = false
      v-internal     = true
   .
end.
when  'iv':U  then do:
   assign
      v-ext-doc-type = p-ext-doc-type
      v-doc-type     = 'при':U
      v-discnt-type  = 'процент':U
      v-ret-supp     = false
      v-internal     = true
   .
end.
when  'we':U  then do:
   assign
      v-ext-doc-type = p-ext-doc-type
      v-doc-type     = 'спи':U
      v-discnt-type  = 'процент':U
      v-ret-supp     = false
      v-internal     = false
   .
end.
otherwise do:
  message "Не верный расширенный тип"  p-ext-doc-type  view-as alert-box information .
end.
end case.
run create-tt in this-procedure .
i = 0 .
i-err = 0 .
v-spis = "" .
if p-ext-doc-type = 'ev':U  then do:
 for each temp-vat :
    i = i + 1 .
    run create-trn-2 in this-procedure (input  temp-vat.vat-type, output v-trn-doc ) no-error .
    find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = v-trn-doc no-error .
        if not available buf_trn-doc then do:
           i-err = i-err + 1 .
        end.
        else do:
           v-spis =  v-spis + buf_trn-doc.doc-code + ",".
        end.
 end.
end.
else do:
for each temp-cli :
 for each temp-vat :
    i = i + 1 .
    run create-trn in this-procedure (temp-cli.obj-type,temp-cli.obj-code, temp-vat.vat-type, output v-trn-doc ) no-error .
    find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = v-trn-doc no-error .
        if not available buf_trn-doc then do:
           i-err = i-err + 1 .
        end.
        else do:
           v-spis =  v-spis + buf_trn-doc.doc-code + ",".
        end.
 end.
 end.
end.
return substitute("Создано &1 , Ошибок &2 , Накладные: &3" , i, i-err , v-spis ) .
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
procedure create-tt :
define buffer buf_clients for ub.clients  .
  do
  on error undo, return error return-value
  :
if p-ext-doc-type = 'iv':U then do:
for each x_parts where
     not (x_parts.obj-type = v-cntxt-obj-type and
         x_parts.obj-code = v-cntxt-obj-code )
                 break by x_parts.obj-type
                       by x_parts.obj-code
                      :
   if first-of ( x_parts.obj-code ) then do:
      find first buf_clients no-lock where
                 buf_clients.db-num    <> ? and
                 buf_clients.obj-type  = x_parts.obj-type and
                 buf_clients.obj-code  = x_parts.obj-code no-error .
      if available buf_clients then do:
          create temp-cli.
          buffer-copy buf_clients to temp-cli.
      end.
   end.
end.
end.
else do:
for each x_parts break by x_parts.supp-type
                       by x_parts.supp-code
                      :
   if first-of ( x_parts.supp-code ) then do:
      find first buf_clients no-lock where
                 buf_clients.db-num    = ? and
                 buf_clients.obj-type  = x_parts.supp-type and
                 buf_clients.obj-code  = x_parts.supp-code no-error .
      if available buf_clients then do:
          create temp-cli.
          buffer-copy buf_clients to temp-cli.
      end.
   end.
end.
end.
for each x_parts
    break by x_parts.vat-type
    :
   if first-of ( x_parts.vat-type) then do:
      create temp-vat.
       assign
          temp-vat.vat-type = x_parts.vat-type
          .
   end.
end.
  end.
end procedure.
procedure create-trn :
define input  parameter p-cli-type as character no-undo .
define input  parameter p-cli-code as integer   no-undo .
define input  parameter p-vat-type as character no-undo .
define output parameter v-num-doc as character no-undo .
define buffer buf_sysconf for ub.sysconf  .
define buffer buf_clients for ub.clients  .
define variable  v-fact-qnty  as decimal   no-undo .
define variable  v-cli-qnty   as decimal   no-undo .
define variable  v-root-node  as integer   no-undo .
  do
  on error undo, return error return-value
  :
run clear-tt.
find first buf_clients no-lock where
           buf_clients.obj-type  = p-cli-type and
           buf_clients.obj-code  = p-cli-code no-error .
find first buf_sysconf where buf_sysconf.host-code = v-cntxt-host-code-obj no-lock no-error .
if error-status :error then return error .
    v-cntxt-cash-pay  = buf_sysconf.cash-pay.
    v-cntxt-base-code = buf_sysconf.base-code.
    run doc-code in this-procedure
      ( input  "main":U         ,
        input  v-cntxt-obj-type ,
        input  v-cntxt-obj-code ,
        input  ?                ,
        output v-num-doc ) no-error .
    create tt-trn-doc.
    assign
      tt-trn-doc.cli-code      = buf_clients.obj-code
      tt-trn-doc.cli-type      = buf_clients.obj-type
      tt-trn-doc.cli-name      = buf_clients.obj-name
      tt-trn-doc.cr-db-num     = v-cntxt-db-num
      tt-trn-doc.creid         = v-cntxt-userid
      tt-trn-doc.discnt-type   = v-discnt-type
      tt-trn-doc.doc-code      = v-num-doc
      tt-trn-doc.office        = false
      tt-trn-doc.pay-code      = v-cntxp-out-pay
      tt-trn-doc.doc-date      = today
      tt-trn-doc.doc-type      = v-doc-type
      tt-trn-doc.flag_         = false
      tt-trn-doc.internal      = v-internal
      tt-trn-doc.obj-code      = v-cntxt-obj-code
      tt-trn-doc.obj-type      = v-cntxt-obj-type
      tt-trn-doc.ps            = "ФиБ"
      tt-trn-doc.ret-supp      = v-ret-supp
      tt-trn-doc.slt-type      = 'без':U
      tt-trn-doc.status_       = ( if v-ext-doc-type = 'iv':U then 'запрос':U else 'накл':U )
      tt-trn-doc.vat-type      = p-vat-type
      tt-trn-doc.ext-doc-type  = v-ext-doc-type
      tt-trn-doc.purch-code    = buf_sysconf.purch-code
    .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U
        then tt-trn-doc.print-rubl = false .
        else tt-trn-doc.print-rubl = true .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-trn-doc.obj-type
  ,input  tt-trn-doc.obj-code
  ,output tt-trn-doc.host-code
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  tt-trn-doc.host-code
  ,input  tt-trn-doc.doc-date
  ,output tt-trn-doc.base-rate
  ,output tt-trn-doc.base-scale
  )  .
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
,input tt-trn-doc.purch-code
) no-error
.
      .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       ""
       view-as alert-box error
     .
     if p-ext-doc-type = 'iv':U then do:
        for each buf_parts where
                  buf_parts.obj-code  = p-cli-code and
                  buf_parts.obj-type  = p-cli-type and
                  buf_parts.vat-type  = p-vat-type :
          create tt-parts.
          buffer-copy buf_parts to tt-parts
          assign
            tt-parts.out-code = v-num-doc
            tt-parts.obj-type = tt-trn-doc.obj-type
            tt-parts.obj-code = tt-trn-doc.obj-code
            tt-parts.supp-type = tt-trn-doc.cli-type
            tt-parts.supp-code = tt-trn-doc.cli-code
          .
        end.
     end.
     else do:
        for each buf_parts where
                  buf_parts.supp-code = p-cli-code and
                  buf_parts.supp-type = p-cli-type and
                  buf_parts.vat-type  = p-vat-type :
          create tt-parts.
          buffer-copy buf_parts to tt-parts
          assign
            tt-parts.out-code = v-num-doc
          .
          end.
     end.
     for each tt-parts :
         find first tt2-doc-line where
                    tt2-doc-line.doc-code  =  v-num-doc and
                    tt2-doc-line.artic     =  tt-parts.artic and
                    tt2-doc-line.prod-type =  tt-parts.prod-type and
                    tt2-doc-line.prod-code =  tt-parts.prod-code no-error .
         if not available tt2-doc-line then do:
            create tt2-doc-line.
            v-fact-qnty = 0.
            v-cli-qnty  = 0.
         end.
         else do:
            v-fact-qnty = tt2-doc-line.fact-qnty.
            v-cli-qnty  = tt2-doc-line.cli-qnty.
         end.
         buffer-copy tt-parts except status_ to tt2-doc-line
         assign
             tt2-doc-line.doc-code  = v-num-doc
             tt2-doc-line.doc-qnty   = tt-parts.fact-qnty + v-fact-qnty
             tt2-doc-line.fact-qnty  = tt-parts.fact-qnty + v-fact-qnty
             tt2-doc-line.cli-qnty   = tt-parts.cli-qnty  + v-cli-qnty
         .
         find first tt-doc-line where
                    tt-doc-line.doc-code  =  v-num-doc and
                    tt-doc-line.artic     =  tt-parts.artic and
                    tt-doc-line.prod-type =  tt-parts.prod-type and
                    tt-doc-line.prod-code =  tt-parts.prod-code no-error .
         if not available tt2-doc-line then do:
            create tt-doc-line.
         end.
     end.
     for each  tt2-doc-line where
                    tt2-doc-line.doc-code  =  v-num-doc :
         find first tt-gds-dtl where
                    tt-gds-dtl.doc-code  =  v-num-doc and
                    tt-gds-dtl.artic     =  tt2-doc-line.artic and
                    tt-gds-dtl.prod-type =  tt2-doc-line.prod-type and
                    tt-gds-dtl.prod-code =  tt2-doc-line.prod-code no-error .
         if not available tt-gds-dtl then do:
            create tt-gds-dtl.
         end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  tt2-doc-line.artic
  ,input  tt2-doc-line.prod-type
  ,input  tt2-doc-line.prod-code
  ,output v-root-node
  )  .
         buffer-copy tt2-doc-line to tt-gds-dtl
         assign
            tt-gds-dtl.doc-code  = v-num-doc
            tt-gds-dtl.prt-code  = v-root-node
         .
     end.
    find first new_trn-doc where new_trn-doc.doc-code = tt-trn-doc.doc-code  exclusive-lock no-error .
    if  available new_trn-doc then do:
    assign
        new_trn-doc.print-rubl = tt-trn-doc.print-rubl
        new_trn-doc.hold-doc-code-child  = "no-hold":u
        new_trn-doc.hold-doc-code-parent = "no-hold":u
        .
      if p-ext-doc-type = 'ev':U  then do:
      assign
          new_trn-doc.cli-type = v-cli-type
          new_trn-doc.cli-code = v-cli-code
          new_trn-doc.cli-name = v-cli-name
          .
        end.
      end.
      if p-ext-doc-type = 'iv':U  then do:
      for each tt2-doc-line :
        create tt-doc-line.
        buffer-copy tt2-doc-line to tt-doc-line
        assign
          tt-doc-line.doc-code = tt-trn-doc.doc-code
        .
      end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run lib-trn_copy-inqu (
    input tt-trn-doc.doc-code
  , input tt-trn-doc.doc-type
  , input tt-trn-doc.status_
  , input tt-trn-doc.internal
  , input tt-trn-doc.cli-type
  , input tt-trn-doc.cli-code
  , input tt-trn-doc.discnt-type
  , input tt-trn-doc.tot-calc
  , input tt-trn-doc.discnt-pc
  , input tt-trn-doc.agnt
  , input tt-trn-doc.boss
  , input tt-trn-doc.wrkr
  , input tt-trn-doc.base-rate
  , input tt-trn-doc.base-scale
  , input tt-trn-doc.exch-code
  , input tt-trn-doc.vat-type
  , input tt-trn-doc.doc-code
  , input no
  , input tt-trn-doc.discnt-pc
  , input tt-trn-doc.agnt
  , input tt-trn-doc.boss
  , input tt-trn-doc.wrkr
  , input tt-trn-doc.base-rate
  , input tt-trn-doc.base-scale
  , input v-cntxt-cash-pay
  , input v-cntxt-base-code
  , input table tt-doc-line
  , input table tt-gds-dtl
  , input table tt-parts
  , input yes
  , input yes
  , input no
  ) no-error.
        if not error-status :error  then do:
          for each tt-parts :
          find first ub.goods no-lock where
                     ub.goods.artic      = tt-parts.artic and
                     ub.goods.prod-type  = tt-parts.prod-type and
                     ub.goods.prod-code  = tt-parts.prod-code no-error .
          find first ub.parts no-lock where
                     ub.parts.artic      = tt-parts.artic and
                     ub.parts.prod-type  = tt-parts.prod-type and
                     ub.parts.prod-code  = tt-parts.prod-code and
                     ub.parts.part-code  = tt-parts.part-code and
                     ub.parts.in-code    = tt-parts.in-code .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer ub.parts
  ,output v-b-code
  ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
          end.
          create ub.doc-prts.
          buffer-copy tt-parts to ub.doc-prts
            assign
              ub.doc-prts.out-code = tt-trn-doc.doc-code
              ub.doc-prts.b-code   = v-b-code
              ub.doc-prts.gds-code  = ub.goods.gds-code
              ub.doc-prts.defect    = logical('yes':U)
          .
         end.
      end.
      end.
      else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-ret in g#lib-trn
  (
    input parparentproc
  , input tt-trn-doc.doc-code
  , input tt-trn-doc.doc-type
  , input tt-trn-doc.status_
  , input tt-trn-doc.internal
  , input tt-trn-doc.cli-type
  , input tt-trn-doc.cli-code
  , input tt-trn-doc.discnt-type
  , input tt-trn-doc.tot-calc
  , input tt-trn-doc.discnt-pc
  , input tt-trn-doc.agnt
  , input tt-trn-doc.boss
  , input tt-trn-doc.wrkr
  , input tt-trn-doc.base-rate
  , input tt-trn-doc.base-scale
  , input tt-trn-doc.exch-code
  , input tt-trn-doc.vat-type
  , input tt-trn-doc.doc-code
  , input no
  , input tt-trn-doc.discnt-pc
  , input tt-trn-doc.agnt
  , input tt-trn-doc.boss
  , input tt-trn-doc.wrkr
  , input tt-trn-doc.base-rate
  , input tt-trn-doc.base-scale
  , input v-cntxt-cash-pay
  , input v-cntxt-base-code
  , input-output table tt2-doc-line
  , input-output table tt-gds-dtl
  , input-output table tt-parts
  , input yes
  , input yes
  , input yes
  , input yes
  ) no-error.
      end.
   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "str/copy-ret.i"
     view-as alert-box error
   .
   if p-ext-doc-type = 'ep':U  then do:
      run str/ep-corrp.p (input parparentproc , input v-num-doc ) no-error .
   end.
   else do:
      run gbl/calc-trn.p (input parparentproc, input recid (new_trn-doc) ) no-error.
   end.
  end.
end procedure.
procedure create-trn-2 :
define input  parameter p-vat-type as character no-undo .
define output parameter v-num-doc as character no-undo .
define buffer buf_sysconf for ub.sysconf  .
define variable  v-fact-qnty  as decimal   no-undo .
define variable  v-cli-qnty   as decimal   no-undo .
define variable  v-root-node  as integer   no-undo .
  do
  on error undo, return error return-value
  :
run clear-tt.
find first buf_sysconf where buf_sysconf.host-code = v-cntxt-host-code-obj no-lock no-error .
if error-status :error then return error .
    v-cntxt-cash-pay  = buf_sysconf.cash-pay.
    v-cntxt-base-code = buf_sysconf.base-code.
    run doc-code in this-procedure
      ( input  "main":U         ,
        input  v-cntxt-obj-type ,
        input  v-cntxt-obj-code ,
        input  ?                ,
        output v-num-doc ) no-error .
    create tt-trn-doc.
    assign
      tt-trn-doc.cli-code      = v-cli-code
      tt-trn-doc.cli-type      = v-cli-type
      tt-trn-doc.cli-name      = v-cli-name
      tt-trn-doc.cr-db-num     = v-cntxt-db-num
      tt-trn-doc.creid         = v-cntxt-userid
      tt-trn-doc.discnt-type   = v-discnt-type
      tt-trn-doc.doc-code      = v-num-doc
      tt-trn-doc.office        = false
      tt-trn-doc.pay-code      = v-cntxp-out-pay
      tt-trn-doc.doc-date      = today
      tt-trn-doc.doc-type      = v-doc-type
      tt-trn-doc.flag_         = false
      tt-trn-doc.internal      = v-internal
      tt-trn-doc.obj-code      = v-cntxt-obj-code
      tt-trn-doc.obj-type      = v-cntxt-obj-type
      tt-trn-doc.ps            = "ФиБ"
      tt-trn-doc.ret-supp      = v-ret-supp
      tt-trn-doc.slt-type      = 'без':U
      tt-trn-doc.status_       = 'накл':U
      tt-trn-doc.vat-type      = p-vat-type
      tt-trn-doc.ext-doc-type  = v-ext-doc-type
      tt-trn-doc.purch-code    = buf_sysconf.purch-code
    .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U
        then tt-trn-doc.print-rubl = false .
        else tt-trn-doc.print-rubl = true .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-trn-doc.obj-type
  ,input  tt-trn-doc.obj-code
  ,output tt-trn-doc.host-code
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  tt-trn-doc.host-code
  ,input  tt-trn-doc.doc-date
  ,output tt-trn-doc.base-rate
  ,output tt-trn-doc.base-scale
  )  .
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
,input tt-trn-doc.purch-code
) no-error
.
      .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       ""
       view-as alert-box error
     .
    for each buf_parts where
             buf_parts.vat-type  = p-vat-type :
      create tt-parts.
      buffer-copy buf_parts to tt-parts
      assign
        tt-parts.out-code = v-num-doc
      .
      end.
     for each tt-parts :
         find first tt2-doc-line where
                    tt2-doc-line.doc-code  =  v-num-doc and
                    tt2-doc-line.artic     =  tt-parts.artic and
                    tt2-doc-line.prod-type =  tt-parts.prod-type and
                    tt2-doc-line.prod-code =  tt-parts.prod-code no-error .
         if not available tt2-doc-line then do:
            create tt2-doc-line.
            v-fact-qnty = 0.
            v-cli-qnty  = 0.
         end.
         else do:
            v-fact-qnty = tt2-doc-line.fact-qnty.
            v-cli-qnty  = tt2-doc-line.cli-qnty.
         end.
         buffer-copy tt-parts except status_ to tt2-doc-line
         assign
             tt2-doc-line.doc-code  = v-num-doc
             tt2-doc-line.doc-qnty   = tt-parts.fact-qnty + v-fact-qnty
             tt2-doc-line.fact-qnty  = tt-parts.fact-qnty + v-fact-qnty
             tt2-doc-line.cli-qnty   = tt-parts.cli-qnty  + v-cli-qnty
         .
         find first tt-doc-line where
                    tt-doc-line.doc-code  =  v-num-doc and
                    tt-doc-line.artic     =  tt-parts.artic and
                    tt-doc-line.prod-type =  tt-parts.prod-type and
                    tt-doc-line.prod-code =  tt-parts.prod-code no-error .
         if not available tt2-doc-line then do:
            create tt-doc-line.
         end.
     end.
     for each  tt2-doc-line where
                    tt2-doc-line.doc-code  =  v-num-doc :
         find first tt-gds-dtl where
                    tt-gds-dtl.doc-code  =  v-num-doc and
                    tt-gds-dtl.artic     =  tt2-doc-line.artic and
                    tt-gds-dtl.prod-type =  tt2-doc-line.prod-type and
                    tt-gds-dtl.prod-code =  tt2-doc-line.prod-code no-error .
         if not available tt-gds-dtl then do:
            create tt-gds-dtl.
         end.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  tt2-doc-line.artic
  ,input  tt2-doc-line.prod-type
  ,input  tt2-doc-line.prod-code
  ,output v-root-node
  )  .
         buffer-copy tt2-doc-line to tt-gds-dtl
         assign
            tt-gds-dtl.doc-code  = v-num-doc
            tt-gds-dtl.prt-code  = v-root-node
         .
     end.
    find first new_trn-doc where new_trn-doc.doc-code = tt-trn-doc.doc-code  exclusive-lock no-error .
    if  available new_trn-doc then do:
    assign
        new_trn-doc.print-rubl = tt-trn-doc.print-rubl
        new_trn-doc.hold-doc-code-child  = "no-hold":u
        new_trn-doc.hold-doc-code-parent = "no-hold":u
        .
      assign
          new_trn-doc.cli-type = v-cli-type
          new_trn-doc.cli-code = v-cli-code
          new_trn-doc.cli-name = v-cli-name
          .
        end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_copy-ret in g#lib-trn
  (
    input parparentproc
  , input tt-trn-doc.doc-code
  , input tt-trn-doc.doc-type
  , input tt-trn-doc.status_
  , input tt-trn-doc.internal
  , input tt-trn-doc.cli-type
  , input tt-trn-doc.cli-code
  , input tt-trn-doc.discnt-type
  , input tt-trn-doc.tot-calc
  , input tt-trn-doc.discnt-pc
  , input tt-trn-doc.agnt
  , input tt-trn-doc.boss
  , input tt-trn-doc.wrkr
  , input tt-trn-doc.base-rate
  , input tt-trn-doc.base-scale
  , input tt-trn-doc.exch-code
  , input tt-trn-doc.vat-type
  , input tt-trn-doc.doc-code
  , input no
  , input tt-trn-doc.discnt-pc
  , input tt-trn-doc.agnt
  , input tt-trn-doc.boss
  , input tt-trn-doc.wrkr
  , input tt-trn-doc.base-rate
  , input tt-trn-doc.base-scale
  , input v-cntxt-cash-pay
  , input v-cntxt-base-code
  , input-output table tt2-doc-line
  , input-output table tt-gds-dtl
  , input-output table tt-parts
  , input yes
  , input yes
  , input yes
  , input yes
  ) no-error.
   if error-status :error then message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "str/copy-ret.i"
     view-as alert-box error
   .
   run gbl/calc-trn.p (input parparentproc, input recid (new_trn-doc) ) no-error.
  end.
end procedure.
