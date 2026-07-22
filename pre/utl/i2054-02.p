block-level on error undo, throw.
define temp-table temp_doc-header no-undo
  field doc-id        as integer
  field action        as character
  field ext-num       as character
  field type          as integer
  field agent-id      as character
  field from-store-id as character
  field to-store-id   as character
  field user_id       as character
  field pprice        as decimal
  field fprice        as decimal
  field pdate         as datetime-tz
  field start-date    as datetime-tz
  field finish-date   as datetime-tz
index doc_header_pi is primary unique
  doc-id
.
define temp-table temp_doc-line no-undo
  field doc-id    as integer
  field pos       as integer
  field action    as character
  field goods-id  as integer
  field store-id  as character
  field bc        as character
  field sn        as character
  field name      as character
  field pcount    as decimal
  field fcount    as decimal
  field pprice    as decimal
  field fprice    as decimal
  field comment   as character
index doc_line_pi is unique primary
  doc-id
  pos
.
define temp-table temp2_doc-line no-undo
  field line-num    as integer
  field doc-code    as character
  field gds-code    as integer
  field artic       as character
  field prod-type   as character
  field prod-code   as integer
  field fact-qnty   as decimal
  field price-rubl  as decimal
  field price-cli   as decimal
  field vat-pc      as decimal
  field cons-vat-pc as decimal
index pi
doc-code
line-num
gds-code
.
define dataset thdoc for temp_doc-header, temp_doc-line.
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  parameter table for  temp_doc-header.
define input  parameter table for  temp_doc-line.
define input  parameter p-doc-id as integer   no-undo .
define output parameter p-ok-doc as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: i2054-02.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/i2054-02.p $":U .
define variable vss-description as character no-undo init "Импорт из внешней системы DKLink документов типа 2".
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
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
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
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type14 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type14
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type14 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type14
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thdl-prc_map-obj :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define output parameter p-code      as integer   no-undo .
  define buffer buf_store   for ub.store.
  define buffer buf_shop    for ub.shop.
  define buffer buf_clients for ub.clients.
do for
  buf_store
, buf_shop
, buf_clients
on error undo, return error return-value
:
  assign
    p-code = ?
  .
  case p-obj-type
  :
    when 'маг':U
    then do:
      find first buf_shop no-lock
        where buf_shop.obj-code = p-obj-code
      no-error .
      if not available buf_shop
      then do:
        return error substitute( "Не найден магазин с кодом:&1":U , p-obj-code ) .
      end.
      assign
        p-code = buf_shop.obj-code
      .
    end.
    when 'скл':U
    then do:
      find first buf_store no-lock
        where buf_store.obj-code = p-obj-code
      no-error .
      if not available buf_store
      then do:
        return error substitute( "Не найден склад с кодом:&1":U , p-obj-code ) .
      end.
      assign
        p-code = 100000 + buf_store.obj-code
      .
    end.
    when 'чел':U
    then do:
      find first buf_clients no-lock
        where buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code
      no-error .
      if not available buf_clients
      then do:
        return error substitute( "Не найден контрагент &1 &2" , p-obj-type, p-obj-code ) .
      end.
      assign
        p-code = buf_clients.obj-code
      .
    end.
    when 'орг':U
    then do:
      find first buf_clients no-lock
        where buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code
      no-error .
      if not available buf_clients
      then do:
        return error substitute( "Не найден контрагент &1 &2" , p-obj-type, p-obj-code ) .
      end.
      assign
        p-code = 1000000000 + buf_clients.obj-code
      .
    end.
    otherwise do:
      return error substitute( "Недопустимый тип контрагента:&1":U , p-obj-type ).
    end.
  end case.
end.
end procedure.
procedure thdl-prc_unmap-store :
  define input  parameter p-code      as integer   no-undo .
  define output parameter p-obj-type  as character no-undo .
  define output parameter p-obj-code  as integer   no-undo .
  define buffer buf_store   for ub.store.
  define buffer buf_shop    for ub.shop.
  define variable v-code as integer   no-undo .
do for
  buf_store
, buf_shop
on error undo, return error return-value
:
  assign
    p-obj-type = ?
    p-obj-code = ?
  .
  if p-code > 100000
  then do :
    assign
      v-code = p-code - 100000
    .
    find first buf_store no-lock
      where buf_store.obj-code = v-code
    no-error .
    if not available buf_store
    then do:
      return .
    end.
    assign
      p-obj-type = 'скл':U
      p-obj-code = buf_store.obj-code
    .
  end.
  else do:
    find first buf_shop no-lock
      where buf_shop.obj-code = p-code
    no-error .
    if not available buf_shop
    then do:
      return .
    end.
    assign
      p-obj-type = 'маг':U
      p-obj-code = buf_shop.obj-code
    .
  end.
end.
end procedure.
procedure thdl-prc_unmap-agent :
  define input  parameter p-code      as integer   no-undo .
  define output parameter p-obj-type  as character no-undo .
  define output parameter p-obj-code  as integer   no-undo .
  define variable v-code as integer   no-undo .
  define buffer buf_clients for ub.clients.
do for
  buf_clients
on error undo, return error return-value
:
  assign
    p-obj-type = ?
    p-obj-code = ?
  .
  if p-code > 1000000000
  then do:
    assign
      v-code = p-code - 1000000000
    .
    find first buf_clients no-lock
      where buf_clients.obj-type = 'орг':U
        and buf_clients.obj-code = v-code
    no-error .
    if not available buf_clients
    then do:
      return .
    end.
    assign
      p-obj-type = 'орг':U
      p-obj-code = buf_clients.obj-code
    .
  end.
  else do:
    find first buf_clients no-lock
      where buf_clients.obj-type = 'чел':U
        and buf_clients.obj-code = p-code
    no-error .
    if not available buf_clients
    then do:
      return .
    end.
    assign
      p-obj-type = 'чел':U
      p-obj-code = buf_clients.obj-code
    .
  end.
end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
define stream sout .
define temp-table tt2-doc-line no-undo like lib-trn_ret-line.
define temp-table anlz-bc no-undo
  field b-c as integer
index pi
  b-c
.
define temp-table tt-goods no-undo
  field gds-code  like ub.goods.gds-code
  field fact-qnty as decimal
index pi is primary unique
  gds-code
.
define variable v-curr-r-b        as character no-undo .
define variable v-print-rubl      as logical   no-undo .
define variable v-i               as integer   no-undo .
define variable v-tot-num         as integer   no-undo .
define variable v-doc-code        as character no-undo .
define variable v-table-name      as character no-undo .
define variable v-ext-doc-type    as character no-undo .
define variable vt-obj-type       as character no-undo .
define variable vt-obj-code       as integer   no-undo .
define variable vt-host-code      as integer   no-undo .
define variable v-obj-type        as character no-undo .
define variable v-obj-code        as integer   no-undo .
define variable v-obj-is-active   as logical   no-undo .
define variable v-end-message     as character no-undo .
define variable v-agent-type      as character no-undo .
define variable v-agent-code      as integer   no-undo .
define variable v-from-obj-type   as character no-undo .
define variable v-from-obj-code   as integer   no-undo .
define variable v-from-host-code  as integer   no-undo .
define variable v-to-obj-type     as character no-undo .
define variable v-to-obj-code     as integer   no-undo .
define variable v-to-host-code    as integer   no-undo .
define variable v-contract-code   as integer   no-undo .
define variable v-vat-type        as character no-undo .
define variable v-specif          as logical   no-undo .
define variable v-exch-code       as integer   no-undo .
define variable v-exch-rate       as integer   no-undo .
define variable v-exch-scale      as integer   no-undo .
define variable v-doc-type        as character no-undo .
define variable v-ret-supp        as logical   no-undo .
define variable v-discnt-type     as character no-undo .
define variable v-status_         as character no-undo .
define variable v-cntxt-cash-pay  as integer   no-undo .
define variable v-cntxt-in-ov     as logical   no-undo .
define variable v-cntxt-base-code as integer   no-undo .
define variable v-cntxt-rsrv-time as integer   no-undo .
define variable v-cntxt-load-time as integer   no-undo .
define variable v-cntxt-holidays  as character no-undo .
define variable n-d               as character no-undo .
define variable v-purch-code-ch   as character no-undo .
define variable v-purch-code      as integer   no-undo .
define variable v-purch-code-name as character no-undo .
define variable parrec-doc        as recid     no-undo .
define variable v-k               as integer   no-undo .
define variable v-comments        as character no-undo .
define variable v-price-cli       as decimal   no-undo .
define variable v-result          as character no-undo .
define variable v-type-bc         as character no-undo .
define variable v-weight          as decimal   no-undo .
define variable v-gds-qnty-p      as decimal   no-undo .
define variable v-gds-qnty-f      as decimal   no-undo .
define variable v-gds-price-p     as decimal   no-undo .
define variable v-gds-price-f     as decimal   no-undo .
define variable v-comment-str     as character no-undo .
define variable v-root-node       as integer   no-undo .
define variable v-agent-id        as integer   no-undo .
define variable v-from-store-id   as integer   no-undo .
define variable v-to-store-id     as integer   no-undo .
define variable v-cli-type        as character no-undo .
define variable v-cli-code        as integer   no-undo .
define variable v-update-ok       as logical   no-undo .
define variable v-err-message     as character no-undo .
define variable v-set-qnty        as decimal   no-undo .
define variable v-price-doc-num   as character no-undo .
define variable v-fprice          as decimal   no-undo .
define variable v-road-tax        as decimal   no-undo .
define variable v-excise          as decimal   no-undo .
define variable v-gds-code        as integer   no-undo .
define variable v-line-rec        as recid     no-undo .
define variable v-scan-filename   as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-tth             as handle    no-undo .
define variable v-param-type      as character no-undo .
define variable v-host-code       as integer   no-undo .
define buffer buf_temp_doc-header for temp_doc-header.
define buffer buf_temp_doc-line   for temp_doc-line.
define buffer buf_temp2_doc-line  for temp2_doc-line.
define buffer buf_trn-doc         for ub.trn-doc.
define buffer t-doc               for ub.trn-doc.
define buffer buf_doc-line        for ub.doc-line.
define buffer buf_ord-doc-rcv     for ub.ord-doc-rcv.
define buffer buf_ord-doc         for ub.ord-doc.
define buffer buf_contract        for ub.contract.
define buffer buf_currency        for ub.currency.
define buffer buf_sysconf         for ub.sysconf.
define buffer new_trn-doc         for ub.trn-doc.
define buffer buf_goods           for ub.goods.
define buffer buf_bar-code        for ub.bar-code .
define buffer buf_prod-bc         for ub.prod-bc .
define buffer buf_place           for ub.place .
define buffer buf_contract-specif for ub.contract-specif.
define buffer buf_gds-obj         for ub.gds-obj.
define buffer buf_gds-dtl         for ub.gds-dtl.
_save-block:
do transaction
on error    undo _save-block , return error return-value
on end-key  undo _save-block , return error return-value
:
  run get-db-num in parparentproc (output v-cntxt-db-num ) .
  run get-userid in parparentproc (output v-cntxt-userid ) .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  assign
    v-print-rubl = (if v-curr-r-b = 'base':U then false else true)
    p-ok-doc     = 0
  .
  find first buf_temp_doc-header
    where buf_temp_doc-header.doc-id = p-doc-id
  no-error .
  if not available buf_temp_doc-header
  then do:
    assign
        v-end-message =  substitute( "&1 - не найден документ с кодом &2.":U
                                    , vss-workfile
                                    , p-doc-id
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  if buf_temp_doc-header.action = 'D':U
  then do:
    assign
      p-ok-doc = 1
    .
    return .
  end.
  run clear-tt in this-procedure .
  assign
    v-to-store-id = integer(buf_temp_doc-header.to-store-id)
  no-error .
  if error-status :error = yes
  then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , chr(10)
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  run thdl-prc_unmap-store in this-procedure ( input v-to-store-id
                                              , output v-to-obj-type
                                              , output v-to-obj-code
                                              ) no-error .
  if error-status :error then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , chr(10)
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  assign
    v-from-store-id = integer(buf_temp_doc-header.from-store-id)
  no-error .
  if error-status :error = yes
  then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , chr(10)
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  run thdl-prc_unmap-store in this-procedure ( input v-from-store-id
                                              , output v-from-obj-type
                                              , output v-from-obj-code
                                              ) no-error .
  if error-status :error then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , chr(10)
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  assign
    v-agent-id = integer(buf_temp_doc-header.agent-id)
  no-error .
  if error-status :error = yes
  then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , chr(10)
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  run thdl-prc_unmap-agent in this-procedure ( input v-agent-id
                                              , output v-agent-type
                                              , output v-agent-code
                                              ) no-error .
  if error-status :error then do:
    assign
        v-end-message =  substitute( "&1&2&3":U
                                    , return-value
                                    , chr(10)
                                    , error-status :get-message(1)
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  case buf_temp_doc-header.type
  :
    when 2
    then do:
      if v-to-obj-type = ?
      or v-to-obj-code = ?
      or v-to-obj-type = ""
      then do:
        assign
          v-end-message = substitute( "Объект задан неверно. cli-type=&1, cli-code=&2"
                                    , v-to-obj-type
                                    , v-to-obj-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-to-obj-type
  ,input  v-to-obj-code
  ,output v-host-code
  ) no-error .
      if error-status :error = yes
      then do:
        assign
          v-end-message = substitute( "Ошибка определения фирмы для объекта. obj-type=&1, obj-code=&2"
                                    , v-to-obj-type
                                    , v-to-obj-code
                                    )
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        undo _save-block, return error v-end-message.
      end.
      assign
        v-ext-doc-type   = 'vt':U
        v-doc-type       = 'инв':U
        v-ret-supp       = false
        v-status_        = 'накл':U
        v-discnt-type    = ""
        v-cli-type     = 'орг':U
        v-cli-code     = v-host-code
        v-obj-type     = v-to-obj-type
        v-obj-code     = v-to-obj-code
      .
    end.
    otherwise do :
      assign
          v-end-message =  substitute( " &1 -  недопустимый тип операции: &2":U
                                      , vss-workfile
                                      , buf_temp_doc-header.type
                                      )
      .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo _save-block, return error v-end-message.
    end.
  end case.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  'active=request'
  ,output v-obj-is-active
  ) no-error .
  if v-obj-is-active <> true
  then do:
    assign
        v-end-message =  substitute( "Документы можно создавать только на активной стороне. Создание документов на объекте &1 &2 невозможно":U
                                    , v-obj-type
                                    , v-obj-code
                                    )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  assign
    vt-obj-type = v-obj-type
    vt-obj-code = v-obj-code
  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-to-host-code
  ) no-error .
  if error-status :error then do:
    assign
        v-end-message =  substitute( "Не верно указан объект &1 &2":U
                                    , v-obj-type
                                    , v-obj-code
                                    ).
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  assign
    v-cntxt-obj-type      = v-obj-type
    v-cntxt-obj-code      = v-obj-code
    v-cntxt-host-code-obj = v-to-host-code
  .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output to-day
  ) no-error .
  if error-status :error then do:
    assign
      v-end-message = substitute( "Ошибка &1 &2 &3 &4"
                                , v-obj-type
                                , v-obj-code
                                , error-status :get-message(1)
                                , return-value
                                )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  find first buf_contract no-lock
    where buf_contract.contract-code = v-agent-code
      and buf_contract.host-code     = v-to-host-code
  no-error .
  if not available buf_contract
  then do:
    assign
      v-contract-code =  0
      v-vat-type      =  'в т. ч.':U
    .
  end.
  else do:
    assign
      v-contract-code = buf_contract.contract-code
    .
  end.
  assign
    v-specif = false
  .
  if v-contract-code > 0 then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-to-host-code,
    INPUT  v-contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-to-host-code
      i-gl-Contract-Code  = v-contract-code
      .
END.
    FIND FIRST buf_contract-specif
           NO-LOCK
           WHERE
               buf_contract-specif.Host-code    = i-gl-Host-Code
           AND buf_contract-specif.Contract-num = i-gl-Contract-Code
           NO-ERROR
           .
      if available buf_contract-specif
      then do:
        assign
          v-specif = true
          v-vat-type = buf_contract-specif.VAT-type
        .
      end.
  end.
  assign
    v-exch-code   = 0
    v-exch-rate   = 1
    v-exch-scale  = 1
  .
  find first buf_currency no-lock
    where buf_currency.curr-code = v-exch-code
  no-error .
  if error-status :error then do:
    assign
      v-end-message =  substitute( "Нет валюты с кодом &1  (&2)"
                                , v-exch-code
                                , error-status :get-message(1)
                                )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
  end.
  if v-ext-doc-type = 'ie':U
  then do:
    if buf_contract.curr-code <> v-exch-code
    then do:
      v-end-message =  substitute( "По договору &3   ожидалась валюта &1  пришла &2 "
                                  , buf_contract.curr-code
                                  , v-exch-code
                                  , v-contract-code
                                  ) .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo _save-block, return error v-end-message.
    end.
  end.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  find first buf_sysconf no-lock
    where buf_sysconf.host-code = v-cntxt-host-code-obj
  no-error .
  if error-status :error
  then do:
    assign
      v-end-message =  substitute( "Не найдены системные настройки: &1":U
                                  , v-cntxt-host-code-obj
                                  )
    .
    run pcall-log-file in p-log-handle (input v-end-message) .
    undo _save-block, return error v-end-message.
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if buf_temp_doc-header.ext-num = ""
  then do :
    run doc-code in this-procedure ( input "main":U
                                    , input v-obj-type
                                    , input v-obj-code
                                    , input ?
                                    , output n-d
                                    ) no-error.
    if error-status:error then do:
      assign
        v-end-message =  "Ошибка при генерации номера документа. chip "  + return-value  + error-status :get-message(1)
      .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo _save-block, return error v-end-message.
    end.
    create  tt-trn-doc.
    assign
      tt-trn-doc.obj-type             = v-obj-type
      tt-trn-doc.obj-code             = v-obj-code
      tt-trn-doc.cli-type             = v-cli-type
      tt-trn-doc.cli-code             = v-cli-code
      tt-trn-doc.pay-code             = v-cntxp-out-pay
      tt-trn-doc.status_              = "temp"
      tt-trn-doc.doc-code             = n-d
      tt-trn-doc.doc-date             = to-day
      tt-trn-doc.doc-type             = v-doc-type
      tt-trn-doc.internal             = false
      tt-trn-doc.cr-db-num            = v-cntxt-db-num
      tt-trn-doc.vat-type             = v-vat-type
      tt-trn-doc.slt-type             = 'без':U
      tt-trn-doc.office               = false
      tt-trn-doc.fact-num             = 0
      tt-trn-doc.out-code             = ''
      tt-trn-doc.PS                   = ''
      tt-trn-doc.creid                = v-cntxt-userid
      tt-trn-doc.flag_                = false
      tt-trn-doc.ext-doc-type         = v-ext-doc-type
      tt-trn-doc.discnt-type          = v-discnt-type
      tt-trn-doc.ret-supp             = v-ret-supp
      tt-trn-doc.print-rubl           = v-print-rubl
      tt-trn-doc.hold-doc-code-child  = "no-hold":u
      tt-trn-doc.hold-doc-code-parent = "no-hold":u
      tt-trn-doc.exch-rate            = v-exch-rate
      tt-trn-doc.exch-scale           = v-exch-scale
      tt-trn-doc.contract-code        = v-contract-code
    .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tt-trn-doc.obj-type
  ,input  tt-trn-doc.obj-code
  ,output tt-trn-doc.host-code
  ) no-error .
    if error-status:error then do:
      assign
        v-end-message =  substitute( "&1&2&3"
                                    , return-value
                                    , chr(10)
                                    , error-status :get-message(1)
                                    )
      .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo _save-block, return error v-end-message.
    end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  tt-trn-doc.host-code
  ,input  tt-trn-doc.doc-date
  ,output tt-trn-doc.base-rate
  ,output tt-trn-doc.base-scale
  ) no-error .
    if error-status:error then do:
      assign
        v-end-message =  substitute( "&1&2&3"
                                    , return-value
                                    , chr(10)
                                    , error-status :get-message(1)
                                    )
      .
      run pcall-log-file in p-log-handle (input v-end-message) .
      undo _save-block, return error v-end-message.
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
    if error-status :error then do:
      assign
        v-end-message =  substitute( "Ошибка при создании шапки документа  &1 &2 &3"
                                  , buf_temp_doc-header.doc-id
                                  , return-value
                                  , error-status :get-message(1)
                                  )
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.
    find first new_trn-doc where new_trn-doc.doc-code = n-d  exclusive-lock no-error .
    if not available new_trn-doc
    then do:
      assign
        v-end-message = substitute(" Ошибка &1" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.
    assign
        new_trn-doc.contract-code         = tt-trn-doc.contract-code
        new_trn-doc.exch-rate             = tt-trn-doc.exch-rate
        new_trn-doc.exch-scale            = tt-trn-doc.exch-scale
        new_trn-doc.exch-date             = to-day
        new_trn-doc.exch-code             = tt-trn-doc.exch-code
        new_trn-doc.status_               = v-status_
        new_trn-doc.flag_                 = ( if v-ext-doc-type = 'ee':U then true else false )
        new_trn-doc.print-rubl            = v-print-rubl
        new_trn-doc.hold-doc-code-child   = "no-hold":u
        new_trn-doc.hold-doc-code-parent  = "no-hold":u
        new_trn-doc.agnt                  = tt-trn-doc.agnt
        new_trn-doc.boss                  = tt-trn-doc.boss
        new_trn-doc.wrkr                  = tt-trn-doc.wrkr
        new_trn-doc.rcv-code              = "not_delete"
        parrec-doc                        = recid (new_trn-doc)
        v-k = 0
    .
    run add-nn1 (new_trn-doc.doc-code  ) no-error .
    if error-status:error then do :
        assign
          v-end-message = substitute(" Ошибка записи атрибута документа &1_ &2" , error-status :get-message(1)  , return-value)
        .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo _save-block, return error v-end-message.
    end.
    run gbl/_tmpfile.p ( input "inv"
                       , input "txt"
                       , output v-scan-filename
                       ) no-error .
    if error-status :error = yes
    then do:
      assign
        v-end-message = substitute(" Ошибка gbl/_tmpfile.p &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.
    for each buf_temp_doc-line
      where buf_temp_doc-line.doc-id = buf_temp_doc-header.doc-id
    break by buf_temp_doc-line.goods-id
    :
      if first-of(buf_temp_doc-line.goods-id)
      then do:
        assign
          v-gds-qnty-p  = 0.0
          v-gds-qnty-f  = 0.0
          v-gds-price-p = 0.0
          v-gds-price-f = 0.0
        .
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_temp_doc-line.goods-id
        no-error .
        if not available buf_goods
        then do:
          assign
            v-end-message = substitute( "Ошибка: нет товара &1 &2 &3 "
                                      , buf_temp_doc-line.goods-id
                                      , error-status :get-message(1)
                                      , return-value
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.
      end.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  this-procedure
,input  buf_temp_doc-line.bc
,input  0
,input  ''
,input  0
,input  no
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output v-result
,output v-type-bc
,output v-weight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
      if error-status :error
      then do:
        assign
          v-end-message = substitute( "Ошибка при поиске бар-кода &1&2&3&2&4"
                                    , buf_temp_doc-line.bc
                                    , chr(10)
                                    , error-status :get-message(1)
                                    , return-value
                                    )
        .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo _save-block, return error v-end-message .
      end.
      if not available buf_bar-code
      then do:
        assign
          v-end-message = substitute( "Не найден бар-код &1"
                                    , buf_temp_doc-line.bc
                                    )
        .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo _save-block, return error v-end-message .
      end.
      if buf_bar-code.gds-code <> buf_goods.gds-code
      then do:
        assign
          v-end-message = substitute( "Найденый бар-код &1 не соотвествует товару с кодом &2 (соотвествует &3)"
                                    , buf_temp_doc-line.bc
                                    , buf_goods.gds-code
                                    , buf_bar-code.gds-code
                                    )
        .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo _save-block, return error v-end-message .
      end.
      assign
        v-fprice = buf_temp_doc-line.fprice
        v-gds-qnty-p  = v-gds-qnty-p  + buf_bar-code.cli-base-rate * buf_temp_doc-line.pcount
        v-gds-qnty-f  = v-gds-qnty-f  + buf_bar-code.cli-base-rate * buf_temp_doc-line.fcount
        v-gds-price-p = v-gds-price-p + buf_bar-code.cli-base-rate * buf_temp_doc-line.pprice
        v-gds-price-f = v-gds-price-f + buf_bar-code.cli-base-rate * v-fprice
        v-comment-str = v-comment-str + buf_temp_doc-line.comment + chr(10)
      .
      if last-of(buf_temp_doc-line.goods-id)
      then do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  tt-trn-doc.obj-type
  ,input  tt-trn-doc.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error = yes
        then do:
          assign
            v-end-message = substitute( "Ошибка заведения товара на объекте: &1&2&3"
                                      , return-value
                                      , chr(10)
                                      , error-status :get-message(1)
                                      )
          .
          undo _save-block, return error v-end-message .
        end.
        if not available buf_gds-obj then do:
          find first buf_gds-obj no-lock
            where buf_gds-obj.obj-type = tt-trn-doc.obj-type
              and buf_gds-obj.obj-code = tt-trn-doc.obj-code
              and buf_gds-obj.gds-code = buf_goods.gds-code
          no-error .
          if not available buf_gds-obj then do:
            assign
              v-end-message =  substitute( "Товар &1 &2 &3  &4 &5"
                                        , buf_goods.gds-code
                                        , buf_goods.artic
                                        , buf_goods.gds-name
                                        , error-status :get-message(1)
                                        , return-value
                                        )
            .
            run pcall-log-file in p-log-handle (input v-end-message) .
            undo _save-block, return error v-end-message .
          end.
        end.
        if buf_gds-obj.fact-qnty <> v-gds-qnty-p
        then do:
          assign
            v-end-message = substitute( "Фактическое количество на объекте &1 &2 : &3 не совпадает с количеством присланным из ВС: &4. "
                                      , new_trn-doc.obj-type
                                      , new_trn-doc.obj-code
                                      , buf_gds-obj.fact-qnty
                                      , v-gds-qnty-p
                                      )
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
        end.
        create anlz-bc .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output anlz-bc.b-c
  ) no-error .
        if error-status :error
        then do:
          assign
            v-end-message = substitute("anlz-bc &1 &2 &3 &4"
                                      , buf_goods.gds-code
                                      , anlz-bc.b-c
                                      , return-value
                                      , error-status :get-message(1)
                                      )
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
          undo _save-block, return error v-end-message .
        end.
        run str/use-list.p ( input this-procedure
                           , input-output v-line-rec
                           , input recid(new_trn-doc)
                           , input false
                           , input (buffer anlz-bc:handle)
                           ) no-error .
        if error-status :error then do:
          assign
            v-end-message = substitute("Ошибка1 &1 &2" , error-status :get-message(1)  , return-value)
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message .
        end.
        output stream sout to value (v-scan-filename) append.
        put stream sout unformatted buf_goods.gds-code "," v-gds-qnty-f chr(10).
        output stream sout close.
        assign
          v-comment-str = trim( v-comment-str , chr(10))
        .
      end.
    end.
    if new_trn-doc.wrkr = ?
    then do:
      run adm/shattri.p ( input "get":U
                        , input  new_trn-doc.obj-type
                        , input  new_trn-doc.obj-code
                        , input  'rt-trn-doc':U
                        , input  'wrkr':U
                        , output v-value-character
                        , output v-value-date
                        , output v-value-decimal
                        , output v-value-integer
                        , output v-value-logical
                        , output v-param-type
                        , input-output table-handle v-tth
                        ) no-error .
      delete object v-tth.
      if  v-value-integer <> ?
      then do:
        assign
          new_trn-doc.wrkr = v-value-integer
        .
      end.
    end.
    if new_trn-doc.agnt = ?
    then do:
      run adm/shattri.p ( input "get":U
                        , input  new_trn-doc.obj-type
                        , input  new_trn-doc.obj-code
                        , input  'rt-trn-doc':U
                        , input  'agnt':U
                        , output v-value-character
                        , output v-value-date
                        , output v-value-decimal
                        , output v-value-integer
                        , output v-value-logical
                        , output v-param-type
                        , input-output table-handle v-tth
                        ) no-error .
      delete object v-tth.
      if  v-value-integer <> ?
      then do:
        assign
          new_trn-doc.agnt = v-value-integer
        .
      end.
    end.
    if new_trn-doc.boss = ?
    then do:
      run adm/shattri.p ( input "get":U
                        , input  new_trn-doc.obj-type
                        , input  new_trn-doc.obj-code
                        , input  'rt-trn-doc':U
                        , input  'boss':U
                        , output v-value-character
                        , output v-value-date
                        , output v-value-decimal
                        , output v-value-integer
                        , output v-value-logical
                        , output v-param-type
                        , input-output table-handle v-tth
                        ) no-error .
      delete object v-tth.
      if  v-value-integer <> ?
      then do:
        assign
          new_trn-doc.boss = v-value-integer
        .
      end.
    end.
    run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
    if error-status:error
    then do :
      assign
        v-end-message = substitute(" Ошибка2 &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message .
    end.
    run clos-trn2 in this-procedure (new_trn-doc.doc-code) no-error .
    if error-status:error
    then do :
      assign
        v-end-message = substitute(" Ошибка2 &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message .
    end.
    run str/scan.p ( input this-procedure , input no , input parrec-doc , input v-scan-filename + chr(4) + string(this-procedure) ) no-error .
    if error-status:error then do :
      assign
        v-end-message = substitute(" Ошибка str/scan.p &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.
    run gbl/del-file.p ( input v-scan-filename ) no-error .
    if error-status :error = yes
    then do:
      assign
        v-end-message = substitute(" Ошибка gbl/del-file.p &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.
    assign
      new_trn-doc.PS =  new_trn-doc.PS +
                        chr(10) +
                        substitute("Документ сформирован из документа ВС. Документ № &1" ,buf_temp_doc-header.doc-id ) +
                        chr(10) +
                        v-comment-str
    .
    run gbl/calc-trn.p (  this-procedure , recid(new_trn-doc)) no-error .
    if error-status :error
    then do:
      assign
        v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value)
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message .
    end.
    assign
      v-k = v-k + 1
    .
  end.
  else do:
    assign
      v-tot-num = num-entries(buf_temp_doc-header.ext-num , ";":u)
    .
    if v-tot-num <> 3
    then do:
      assign
        v-end-message = substitute( "Неправильный формат внешнего кода документа: &1 &2"
                                  , buf_temp_doc-header.doc-id
                                  , buf_temp_doc-header.ext-num
                                  )
      .
      run pcall-log-file in p-log-handle ( input v-end-message ) .
      undo _save-block, return error v-end-message.
    end.
    assign
      v-doc-code      = entry( 1 , buf_temp_doc-header.ext-num , ";":u)
      v-table-name    = entry( 2 , buf_temp_doc-header.ext-num , ";":u)
      v-ext-doc-type  = entry( 3 , buf_temp_doc-header.ext-num , ";":u)
    .
    case v-table-name
    :
      when 'trn-doc':U
      then do:
        find first buf_trn-doc exclusive-lock
          where buf_trn-doc.doc-code = v-doc-code
        no-error .
        if not available buf_trn-doc
        then do :
          assign
            v-end-message = substitute( "Не найден документ с кодом: &1"
                                      , v-doc-code
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.
        if buf_trn-doc.status_ = 'факт':U
        then do:
          assign
            v-end-message = substitute( "Документ &1 в статусе &2, редактирование невозможно."
                                      , v-doc-code
                                      , 'факт':U
                                      )
          .
          run pcall-log-file in p-log-handle ( input v-end-message ) .
          undo _save-block, return error v-end-message.
        end.
        case v-ext-doc-type
        :
          when 'vt':U
          then do:
            if buf_trn-doc.status_ <> 'разрешен':U
            then do:
              assign
                v-end-message = substitute( "Документ &1 в статусе &2, редактирование невозможно."
                                          , buf_trn-doc.doc-code
                                          , buf_trn-doc.status_
                                          )
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            assign
              parrec-doc = recid(buf_trn-doc)
            .
            empty temp-table tt-goods.
            for each buf_temp_doc-line
              where buf_temp_doc-line.doc-id = buf_temp_doc-header.doc-id
            break by buf_temp_doc-line.goods-id
            :
              if first-of(buf_temp_doc-line.goods-id)
              then do:
                assign
                  v-gds-qnty-p  = 0.0
                  v-gds-qnty-f  = 0.0
                  v-gds-price-p = 0.0
                  v-gds-price-f = 0.0
                .
                find first buf_goods no-lock
                  where buf_goods.gds-code = buf_temp_doc-line.goods-id
                no-error .
                if not available buf_goods
                then do:
                  assign
                    v-end-message = substitute( "Ошибка: нет товара &1 &2 &3 "
                                              , buf_temp_doc-line.goods-id
                                              , error-status :get-message(1)
                                              , return-value
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message.
                end.
              end.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  this-procedure
,input  buf_temp_doc-line.bc
,input  0
,input  ''
,input  0
,input  no
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output v-result
,output v-type-bc
,output v-weight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
              if error-status :error
              then do:
                assign
                  v-end-message = substitute( "Ошибка при поиске бар-кода &1&2&3&2&4"
                                            , buf_temp_doc-line.bc
                                            , chr(10)
                                            , error-status :get-message(1)
                                            , return-value
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message .
              end.
              if not available buf_bar-code
              then do:
                assign
                  v-end-message = substitute( "Не найден бар-код &1"
                                            , buf_temp_doc-line.bc
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message .
              end.
              if buf_bar-code.gds-code <> buf_goods.gds-code
              then do:
                assign
                  v-end-message = substitute( "Найденый бар-код &1 не соотвествует товару с кодом &2 (соотвествует &3)"
                                            , buf_temp_doc-line.bc
                                            , buf_goods.gds-code
                                            , buf_bar-code.gds-code
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message .
              end.
              assign
                v-fprice = buf_temp_doc-line.fprice
                v-gds-qnty-p  = v-gds-qnty-p  + buf_bar-code.cli-base-rate * buf_temp_doc-line.pcount
                v-gds-qnty-f  = v-gds-qnty-f  + buf_bar-code.cli-base-rate * buf_temp_doc-line.fcount
                v-gds-price-p = v-gds-price-p + buf_bar-code.cli-base-rate * buf_temp_doc-line.pprice
                v-gds-price-f = v-gds-price-f + buf_bar-code.cli-base-rate * v-fprice
                v-comment-str = v-comment-str + buf_temp_doc-line.comment + chr(10)
              .
              if last-of(buf_temp_doc-line.goods-id)
              then do:
                find first buf_doc-line no-lock
                  where buf_doc-line.doc-code   = buf_trn-doc.doc-code
                    and buf_doc-line.artic      = buf_goods.artic
                    and buf_doc-line.prod-type  = buf_goods.prod-type
                    and buf_doc-line.prod-code  = buf_goods.prod-code
                no-error .
                if not available buf_doc-line
                then do:
                  assign
                    v-end-message = substitute( "В документе &1 отсутствует строка по товару &2 &3 &4 - &5."
                                              , buf_trn-doc.doc-code
                                              , buf_goods.artic
                                              , buf_goods.prod-type
                                              , buf_goods.prod-code
                                              , buf_goods.gds-name
                                              )
                  .
                  run pcall-log-file in p-log-handle ( input v-end-message ) .
                  undo _save-block, return error v-end-message .
                end.
                find first tt-goods
                  where tt-goods.gds-code = buf_goods.gds-code
                no-error .
                if not available tt-goods
                then do:
                  create tt-goods.
                  assign
                    tt-goods.gds-code   = buf_goods.gds-code
                    tt-goods.fact-qnty  = v-gds-qnty-f
                  .
                end.
              end.
            end.
            for each buf_doc-line no-lock
              where buf_doc-line.doc-code = buf_trn-doc.doc-code
            :
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output v-gds-code
  ) no-error .
              if error-status :error = yes
              then do:
                assign
                  v-end-message = substitute( "gbl/gds-code.i ошибка поиска кода товара : &1 &2"
                                            , return-value
                                            , error-status :get-message(1)
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message .
              end.
              find first tt-goods
                where tt-goods.gds-code = v-gds-code
              no-error .
              if not available tt-goods
              then do:
                assign
                  v-end-message = substitute( "В импортируемом документе отсутствует информация по товару &1 &2 &3."
                                            , buf_doc-line.artic
                                            , buf_doc-line.prod-type
                                            , buf_doc-line.prod-code
                                            )
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message .
              end.
            end.
            if buf_trn-doc.status_ = 'накл':U
            then do:
              run clos-trn2 in this-procedure (buf_trn-doc.doc-code) no-error .
              if error-status:error
              then do :
                assign
                  v-end-message = substitute(" Ошибка2 &1 &2" , error-status :get-message(1)  , return-value)
                .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo _save-block, return error v-end-message .
              end.
            end.
            run gbl/_tmpfile.p ( input "inv"
                               , input "txt"
                               , output v-scan-filename
                               ) no-error .
            if error-status :error = yes
            then do:
              assign
                v-end-message = substitute(" Ошибка gbl/_tmpfile.p &1 &2" , error-status :get-message(1)  , return-value)
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            output stream sout to value (v-scan-filename).
            for each tt-goods
            :
              put stream sout unformatted tt-goods.gds-code "," tt-goods.fact-qnty chr(10).
            end.
            output stream sout close.
            run str/scan.p ( input this-procedure , input no , input parrec-doc , input v-scan-filename + chr(4) + string(this-procedure) ) no-error .
            if error-status:error then do :
              assign
                v-end-message = substitute(" Ошибка str/scan.p &1 &2" , error-status :get-message(1)  , return-value)
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            run gbl/del-file.p ( input v-scan-filename ) no-error .
            if error-status :error = yes
            then do:
              assign
                v-end-message = substitute(" Ошибка gbl/del-file.p &1 &2" , error-status :get-message(1)  , return-value)
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message.
            end.
            empty temp-table tt-goods.
            assign
              buf_trn-doc.ps =  buf_trn-doc.ps +
                                chr(10) +
                                substitute("Документ сформирован из документа ВС. Документ № &1" ,buf_temp_doc-header.doc-id ) +
                                chr(10) +
                                v-comment-str
            .
            if buf_trn-doc.wrkr = ?
            then do:
              run adm/shattri.p ( input "get":U
                                , input  buf_trn-doc.obj-type
                                , input  buf_trn-doc.obj-code
                                , input  'rt-trn-doc':U
                                , input  'wrkr':U
                                , output v-value-character
                                , output v-value-date
                                , output v-value-decimal
                                , output v-value-integer
                                , output v-value-logical
                                , output v-param-type
                                , input-output table-handle v-tth
                                ) no-error .
              delete object v-tth.
              if  v-value-integer <> ?
              then do:
                assign
                  buf_trn-doc.wrkr = v-value-integer
                .
              end.
            end.
            if buf_trn-doc.agnt = ?
            then do:
              run adm/shattri.p ( input "get":U
                                , input  buf_trn-doc.obj-type
                                , input  buf_trn-doc.obj-code
                                , input  'rt-trn-doc':U
                                , input  'agnt':U
                                , output v-value-character
                                , output v-value-date
                                , output v-value-decimal
                                , output v-value-integer
                                , output v-value-logical
                                , output v-param-type
                                , input-output table-handle v-tth
                                ) no-error .
              delete object v-tth.
              if  v-value-integer <> ?
              then do:
                assign
                  buf_trn-doc.agnt = v-value-integer
                .
              end.
            end.
            if buf_trn-doc.boss = ?
            then do:
              run adm/shattri.p ( input "get":U
                                , input  buf_trn-doc.obj-type
                                , input  buf_trn-doc.obj-code
                                , input  'rt-trn-doc':U
                                , input  'boss':U
                                , output v-value-character
                                , output v-value-date
                                , output v-value-decimal
                                , output v-value-integer
                                , output v-value-logical
                                , output v-param-type
                                , input-output table-handle v-tth
                                ) no-error .
              delete object v-tth.
              if  v-value-integer <> ?
              then do:
                assign
                  buf_trn-doc.boss = v-value-integer
                .
              end.
            end.
            run gbl/calc-trn.p ( input this-procedure
                               , input parrec-doc
                               ) no-error .
            if error-status :error
            then do:
              assign
                v-end-message = substitute(" Ошибка пересчета шапки &1 &2" , error-status :get-message(1)  , return-value)
              .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo _save-block, return error v-end-message .
            end.
            assign
              v-k = v-k + 1
            .
          end.
          otherwise do:
            assign
              v-end-message = substitute( "Документ &1 имеет недопустимый расширеный тип: &2"
                                        , v-doc-code
                                        , v-ext-doc-type
                                        )
            .
            run pcall-log-file in p-log-handle ( input v-end-message ) .
            undo _save-block, return error v-end-message.
          end.
        end case.
      end.
      otherwise do:
        assign
          v-end-message = substitute( "Документ &1 имеет недопустимый расширеный тип: &2"
                                    , v-doc-code
                                    , v-ext-doc-type
                                    )
        .
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo _save-block, return error v-end-message.
      end.
    end case.
  end.
  assign
    p-ok-doc = p-ok-doc + v-k
  .
  run clear-tt in this-procedure .
end.
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
    empty temp-table tt-goods.
 end.
end procedure.
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
define variable varchg-inv as logical no-undo .
assign
  varmode         = '<закрытие документа>':U
  varstatus       = 'запрос':U
  varflag         = true
  varcopystatus   = 'новый':U
  varcopyflag     = false
  varcheck-return = true
  varchg-inv      = true
  .
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
        run pcall-log-file in p-log-handle ( input v-end-message ) .
        undo, return error v-end-message.
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure add-nn1 :
  define input  parameter p-doc-code as character no-undo .
do
on error undo, return error return-value
:
  find first ub.doc-attr exclusive-lock
    where ub.doc-attr.doc-code = p-doc-code
      and ub.doc-attr.attr-code = 'clcasol':U
  no-error .
  if not available ub.doc-attr then create ub.doc-attr.
  assign
    ub.doc-attr.doc-code = p-doc-code
    ub.doc-attr.attr-code = 'clcasol':U
    ub.doc-attr.attr-value =  "yes"
  .
end.
end procedure.
procedure cb_is-silent :
define output parameter p-silent as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-silent = true .
  end.
end procedure.
