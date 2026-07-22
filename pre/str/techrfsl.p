block-level on error undo, throw.
define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter log-file-name    as character no-undo .
define input parameter p-auto           as integer no-undo .
define input parameter v-curr-r-b       as character no-undo .
define input parameter p-close-in-rfsl  as integer no-undo .
define input parameter p-doc-kind       as character no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.
define parameter buffer buf-new_trn-doc for ub.trn-doc.
define variable vss-revision    as character no-undo init "$Revision: 315b966a6a9b, 3487, rls $":U .
define variable vss-author      as character no-undo init "$Author: BelovaMM $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:36 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: techrfsl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/techrfsl.p $":U .
define variable vss-description as character no-undo init "Создание приходного документа техпролива по документу Техпролива, относящемуся к продаже".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-sale-doc-PS returns character( buffer buf_sale-doc for ub.sale-doc):
define variable v-ps as character no-undo .
if available buf_sale-doc then
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , (if buf_sale-doc.chr-office = 'у':U then "УСЛУГИ." else "ТОВАРЫ." )
                    , entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , buf_sale-doc.chk-amount
                    , buf_sale-doc.gds-amount
                    , buf_sale-doc.tot-lines
                    , buf_sale-doc.tot-dtl
                    ).
else  do:
assign
v-PS = substitute('&1&2 &1&3&1Кол-во_чеков &4&1строк_чеков &5&1товаров &6&1признаков &7&1'
                    , chr(4)
                    , '':U
                    , entry (lookup ('es':U, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U )
                    , 0
                    , 0
                    , 0
                    , 0
                    ).
end.
return v-ps.
END FUNCTION.
FUNCTION get-sale-doc-kind returns character (
                                             input p-doc-kind as character
                                           , input p-ext-doc-type as character
                                           , output p-order as integer
                                           , output p-msign as integer
                                           , output p-main as logical
                                           , output p-in-inkas as logical
                                           , output p-dir_ as integer
                                           ):
define variable v-doc-kind as character no-undo.
define variable v-type as character no-undo .
define variable v-value as character no-undo .
CASE p-doc-kind:
  when 'es':U then do:
    assign
    p-order = 100
    p-msign = 1
    p-main = yes
    p-in-inkas = yes
    p-dir_ = 1
    .
    return p-ext-doc-type.
  end.
  when  'rs':U then do:
    assign
    p-order = 200
    p-msign = - 1
    p-main = no
    p-in-inkas = yes
    p-dir_ = - 1
    .
    return p-ext-doc-type.
  end.
  when 'rwo':U then do:
    assign
    p-msign = - 1
    p-main = no
    p-in-inkas = no
    p-order = 300
    p-dir_ = 1
    .
    return 'rwo':U.
  end.
  when 'trf':U then do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = 400
    p-dir_ = 1
    .
    return 'trf':U.
  end.
  when 'swo':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order =  500
   p-dir_ = 1
   .
   return 'swo':U.
 end.
 when 'vir':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 600
   p-dir_ = 1
   .
   return 'vir':U.
 end.
 when 'itr':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = -1
   p-dir_ = -1
   .
  return 'itr':U.
 end.
 when 'ngs':U then do:
   assign
   p-msign = 1
   p-main = no
   p-in-inkas = no
   p-order = 700
   p-dir_ = 1
   .
   return 'ngs':U.
 end.
 when 'rgs':U then do:
   assign
   p-msign = -1
   p-main = no
   p-in-inkas = no
   p-order = 701
   p-dir_ = -1
   .
   return 'rgs':U.
 end.
 otherwise do:
    assign
    p-msign = 1
    p-main = no
    p-in-inkas = no
    p-order = -1.
    return p-ext-doc-type.
  end.
END CASE.
END FUNCTION.
procedure saledoc-create :
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-doc-kind as character no-undo .
define input parameter p-office as character no-undo .
define input parameter p-tpsidoc as logical no-undo .
define input parameter p-alias-type-price as character no-undo .
define input parameter p-price-obj-type as character no-undo .
define input parameter p-price-obj-code as integer no-undo .
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable v-order as integer no-undo.
define variable v-main as logical no-undo .
define variable v-in-inkas as logical no-undo .
define variable v-msign as integer no-undo .
define variable v-dir_ as integer no-undo .
define variable v-trn-doc-code as character no-undo .
define buffer buf_sale-doc for ub.sale-doc.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
   if available buf_trn-doc then do:
     v-trn-doc-code = buf_trn-doc.doc-code.
   end.
   find first buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.doc-kind = p-doc-kind
        and buf_sale-doc.chr-office = p-office
        and (v-trn-doc-code = '' or buf_sale-doc.doc-code = v-trn-doc-code)
        no-error .
   if not available buf_sale-doc  then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.inkas-code = p-inkas-code
      buf_sale-doc.storage =  'trn-doc':U
      buf_sale-doc.host-code = p-host-code
      buf_sale-doc.obj-type = p-obj-type
      buf_sale-doc.obj-code = p-obj-code
      buf_sale-doc.doc-kind  = p-doc-kind
      buf_sale-doc.order = lookup(p-doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) * 100 + (if p-office = 'у':U then 5 else 0)
      buf_sale-doc.chr-office = p-office
      buf_sale-doc.doc-code = v-trn-doc-code
      .
   end.
   if available buf_trn-doc then
   buffer-copy buf_trn-doc
   to buf_sale-doc
   .
  assign
  buf_sale-doc.doc-kind = get-sale-doc-kind (
                                             input p-doc-kind
                                            ,input buf_sale-doc.ext-doc-type
                                            ,output v-order
                                            ,output v-msign
                                            ,output v-main
                                            ,output v-in-inkas
                                            ,output v-dir_).
  assign
  buf_sale-doc.order = v-order + (if p-office = 'у':U then 5 else 0)
  buf_sale-doc.main-doc = v-main
  buf_sale-doc.in-inkas = v-in-inkas
  buf_sale-doc.msign = v-msign
  buf_sale-doc.dir = v-dir_
  buf_sale-doc.fbrsale = lookup(buf_sale-doc.doc-kind, 'es,swo':U) > 0
  buf_sale-doc.main-receipt-type = integer(entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,1,6,96,17,69,17,17':U))
  buf_sale-doc.poss-wro-codes = '':U
  buf_sale-doc.chr-office = p-office
  buf_sale-doc.tpsidoc = p-tpsidoc
  buf_sale-doc.alias-type-price = p-alias-type-price
  buf_sale-doc.price-obj-type = (if p-tpsidoc
                                 then p-price-obj-type
                                 else '':U)
  buf_sale-doc.price-obj-code = (if p-tpsidoc
                                 then p-price-obj-code
                                 else 0)
  .
  assign
  buf_sale-doc.poss-wro-codes = (if (v-order > 0 and buf_sale-doc.doc-kind <> 'vir':U) then entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U) + 1, '0,2,-2,-6;-3;-9;-4,17,1;3':U) else '':U)
  no-error.
end.
END.
procedure fbr-saledoc-create :
define input parameter p-inkas-code as character no-undo .
define variable v-pri-prvo-doc-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-fact-qnty like ub.trn-doc.doc-qnty no-undo .
define variable v-pri-prvo-tot-lines like ub.trn-doc.tot-lines no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf2_sale-doc for ub.sale-doc.
define buffer buf2_trn-doc for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-doc for ub.chk-doc.
do
on error undo, return error
:
  for each buf_fbr-doc no-lock where
        buf_fbr-doc.out-code = p-inkas-code:
    for each buf_trn-doc no-lock where
          buf_trn-doc.out-code = buf_fbr-doc.doc-code
    by buf_trn-doc.fact-order
    on error undo, return error:
      if buf_trn-doc.ext-doc-type = 'em':U
      or buf_trn-doc.ext-doc-type = 'im':U
      or buf_trn-doc.ext-doc-type = 'wm':U
      or buf_trn-doc.ext-doc-type = 'ev':U
      or buf_trn-doc.ext-doc-type = 'iv':U
      then do:
        find first buf_sale-doc where
                buf_sale-doc.inkas-code = p-inkas-code
            and buf_sale-doc.doc-code = buf_trn-doc.doc-code
            AND buf_sale-doc.storage  = 'trn-doc':U
                no-error .
        if not available buf_sale-doc then do:
        create buf_sale-doc.                                                                                             buffer-copy buf_trn-doc                                                                                             to buf_sale-doc.                                                                                                assign                                                                                                                  buf_sale-doc.storage  =  'trn-doc':U                                                                          buf_sale-doc.doc-kind = buf_trn-doc.ext-doc-type                                                                buf_sale-doc.order =  - 1                                                                                          buf_sale-doc.main-doc = no                                                                                             buf_sale-doc.in-inkas = no                                                                                         buf_sale-doc.fbrsale = yes                                                                                         buf_sale-doc.msign = 1                                                                                             buf_sale-doc.filled   = buf_sale-doc.fact-qnty <> 0 or buf_sale-doc.tot-lines <> 0                       buf_sale-doc.doc-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf_sale-doc.doc-qnty)                                                          buf_sale-doc.fact-qnty = (if buf_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf_sale-doc.fact-qnty)                                                        buf_sale-doc.inkas-code = p-inkas-code.
        end.
        if buf_trn-doc.ext-doc-type = 'im':U then do:
          assign
          v-pri-prvo-doc-qnty = buf_trn-doc.doc-qnty
          v-pri-prvo-fact-qnty = buf_trn-doc.fact-qnty
          v-pri-prvo-tot-lines = buf_trn-doc.tot-lines
          .
        end.
        for each buf2_trn-doc no-lock where
                buf2_trn-doc.out-code = buf_sale-doc.doc-code:
          find first buf2_sale-doc where
                  buf2_sale-doc.inkas-code = p-inkas-code
              and buf2_sale-doc.doc-code = buf2_trn-doc.doc-code
              AND buf2_sale-doc.storage = 'trn-doc':U no-error .
          if not available buf2_sale-doc then do:
            create buf2_sale-doc.                                                                                             buffer-copy buf2_trn-doc                                                                                             to buf2_sale-doc.                                                                                                assign                                                                                                                  buf2_sale-doc.storage  =  'trn-doc':U                                                                          buf2_sale-doc.doc-kind = buf2_trn-doc.ext-doc-type                                                                buf2_sale-doc.order =  - 1                                                                                          buf2_sale-doc.main-doc = no                                                                                             buf2_sale-doc.in-inkas = no                                                                                         buf2_sale-doc.fbrsale = yes                                                                                         buf2_sale-doc.msign = 1                                                                                             buf2_sale-doc.filled   = buf2_sale-doc.fact-qnty <> 0 or buf2_sale-doc.tot-lines <> 0                       buf2_sale-doc.doc-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                           then ?                                                                                                                  else buf2_sale-doc.doc-qnty)                                                          buf2_sale-doc.fact-qnty = (if buf2_sale-doc.ext-doc-type = 'pc':U                                                          then ?                                                                                                                  else buf2_sale-doc.fact-qnty)                                                        buf2_sale-doc.inkas-code = p-inkas-code.
          end.
        end.
      end.
    end.
    find first buf_sale-doc where
              buf_sale-doc.inkas-code = p-inkas-code
          AND buf_sale-doc.storage = 'fbr-doc':U
          AND buf_sale-doc.doc-code = buf_fbr-doc.doc-code no-error .
    if not available buf_sale-doc then do:
      create buf_sale-doc.
      assign
      buf_sale-doc.storage       =  'fbr-doc':U
      buf_sale-doc.doc-type      = 'производство':U
      buf_sale-doc.doc-code      = buf_fbr-doc.doc-code
      buf_sale-doc.ext-doc-type  = 'производство':U
      buf_sale-doc.doc-kind      = 'производство':U
      buf_sale-doc.obj-type      = buf_fbr-doc.obj-type
      buf_sale-doc.obj-code      = buf_fbr-doc.obj-code
      buf_sale-doc.cli-type      = buf_fbr-doc.obj-type
      buf_sale-doc.cli-code      = buf_fbr-doc.obj-code
      buf_sale-doc.doc-qnty      = v-pri-prvo-doc-qnty
      buf_sale-doc.fact-qnty     = v-pri-prvo-fact-qnty
      buf_sale-doc.tot-lines     = v-pri-prvo-tot-lines
      buf_sale-doc.tot-dtl       = v-pri-prvo-tot-lines
      buf_sale-doc.fbrsale       = yes
      buf_sale-doc.inkas-code    = p-inkas-code
      .
    end.
  end.
end.
end procedure.
define variable v-mes as character no-undo .
define variable v-out-pay         as integer   no-undo .
define variable v-out-pay-str     as character no-undo .
define variable v-out-pay-type    as character no-undo .
define variable v-doc-code        like ub.trn-doc.doc-code no-undo .
define variable v-doc-code-chip   like ub.trn-doc.doc-code no-undo .
define variable v-prev-doc-code   like ub.trn-doc.doc-code no-undo .
define variable v-seq             as integer no-undo .
define variable v-seq-max         as integer no-undo .
define variable v-sum-rubl        as decimal no-undo .
define variable v-sum-base        as decimal no-undo .
define variable v-qnty            as decimal no-undo .
define variable v-insalepr        as logical initial ? no-undo.
define variable v-attr-type       as character no-undo .
define variable v-exist           as logical   no-undo .
define variable v-pl-code         as integer no-undo.
define variable v-value           as character no-undo.
define variable v-ok              as logical no-undo.
define variable v-gds-list-diff-place as character no-undo .
define buffer buf_doc-line      for ub.doc-line.
define buffer buf_doc-line-attr for ub.doc-line-attr.
define buffer buf_gds-dtl       for ub.gds-dtl.
define buffer buf_parts         for ub.parts.
define buffer buf_inv-line      for ub.inv-line.
define buffer buf_doc-pl        for ub.doc-pl.
define buffer buf_goods         for ub.goods.
define buffer buf_units         for ub.units.
define buffer in_doc-pl         for ub.doc-pl.
define buffer in_inv-line       for ub.inv-line.
define buffer in_doc-line       for ub.doc-line.
define buffer in_gds-dtl        for ub.gds-dtl.
define buffer buf_sale-doc      for ub.sale-doc.
define buffer buf_pl-gds        for ub.pl-gds.
define temp-table tt-in_trn-doc       no-undo like lib-trn_ret-doc.
define temp-table tt-in_doc-line      no-undo like lib-trn_ret-line.
define temp-table tt-in_doc-line-attr no-undo like lib-trn_ret-line-attr.
define temp-table tt-in_gds-dtl       no-undo like lib-trn_ret-dtl.
define temp-table tt-in_parts         no-undo like lib-trn_ret-parts.
define temp-table temp-tank           no-undo like ub.doc-pl
field doc-seq       as integer
field artic         like ub.goods.artic
field prod-type     like ub.goods.prod-type
field prod-code     like ub.goods.prod-code
field price-base    like ub.doc-line.price-base
field price-rubl    like ub.doc-line.price-rubl
field price-cli     like ub.doc-line.price-cli
field cli-base-rate like ub.doc-line.cli-base-rate
field unit-type     like ub.units.type
index pi is unique primary
doc-seq gds-code
index
iart
artic prod-type prod-code.
define buffer buf_temp-tank  for temp-tank.
define buffer buf2_temp-tank for temp-tank.
_main:
do
on error undo, return error return-value :
  if not available buf_trn-doc then do:
        undo _main, return error substitute("&1 &2 &3&4Отсутствует документ списания техпролива"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,chr(10)).
  end.
  if (buf_trn-doc.ext-doc-type <> 'we':U and buf_trn-doc.ext-doc-type <> 'ee':U)
  or buf_trn-doc.internal <> no
  or buf_trn-doc.status_ <> 'факт':U then do:
    undo _main, return error substitute("&1 &2 &3&4Документ списания техпролива, используемый для создания прихода по техпроливу&4" +
                                          "имеет неправильный расширенный тип &5 или internal &6 или статус &7"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          , buf_trn-doc.ext-doc-type
                                          , buf_trn-doc.internal
                                          , buf_trn-doc.status_
                                          ).
  end.
  find first buf_sale-doc where buf_sale-doc.inkas-code = buf_trn-doc.out-code no-lock no-error.
  for each buf_temp-tank:
    delete buf_temp-tank.
  end.
  v-gds-list-diff-place = "" .
  for each buf_doc-pl no-lock where
          buf_doc-pl.out-code = buf_trn-doc.doc-code
  break
  by buf_doc-pl.gds-code:
    if first-of(buf_doc-pl.gds-code) then do:
      assign
      v-seq = 0.
    end.
    create buf_temp-tank.
    buffer-copy buf_doc-pl
    to buf_temp-tank
    assign
    buf_temp-tank.gds-code = buf_doc-pl.gds-code
    buf_temp-tank.pl-code = buf_doc-pl.pl-code
    v-seq = v-seq + 1
    buf_temp-tank.doc-seq = v-seq
    v-seq-max = (if v-seq > v-seq-max then v-seq else v-seq-max)
    .
    if v-seq > 1
    then do :
      v-gds-list-diff-place = v-gds-list-diff-place + string(buf_doc-pl.gds-code) + "," .
    end .
  end.
  v-gds-list-diff-place = trim(v-gds-list-diff-place, ",") .
  run doc-code in this-procedure
      (input "chip"
      ,input buf_trn-doc.obj-type
      ,input buf_trn-doc.obj-code
      ,input buf_trn-doc.out-code
      ,output v-doc-code ) no-error.
  if error-status:error then do:
    v-mes = substitute("Ошибка при генерации номера прихода по техпроливу для продажи &4:&1&2 &3"
                      , chr(10)
                      , error-status:get-message(1)
                      , return-value
                      , buf_trn-doc.out-code
                      ).
    undo _main, return error v-mes.
  end.
  v-doc-code-chip = v-doc-code.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objatext in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  'out-pay=request'
  ,output v-out-pay-str
  ,output v-out-pay-type
  )  .
  assign
  v-out-pay = integer(v-out-pay-str)
  .
  v-prev-doc-code = v-doc-code.
  _v-seq:
  do v-seq = 1 to v-seq-max:
    if v-seq-max > 1 then do:
      run doc-code in this-procedure
          (input "chip"
          ,input buf_trn-doc.obj-type
          ,input buf_trn-doc.obj-code
          ,input v-prev-doc-code
          ,output v-doc-code-chip ) no-error.
      if error-status:error then do:
        v-mes = substitute("Ошибка при генерации номера прихода &5 по техпроливу для продажи &4:&1&2 &3"
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
                          , buf_trn-doc.out-code
                          , v-seq
                          ).
        undo _main, return error v-mes.
      end.
      assign
      v-prev-doc-code = v-doc-code-chip.
    end.
    for each tt-in_trn-doc:
      delete tt-in_trn-doc.
    end.
    for each tt-in_doc-line:
      delete tt-in_doc-line.
    end.
    for each tt-in_doc-line-attr:
      delete tt-in_doc-line-attr.
    end.
    for each tt-in_gds-dtl:
      delete tt-in_gds-dtl.
    end.
    for each tt-in_parts:
      delete tt-in_parts.
    end.
    create tt-in_trn-doc.
    buffer-copy
    buf_trn-doc except doc-code doc-type status_ ext-doc-type out-code
    to tt-in_trn-doc
    assign
    tt-in_trn-doc.doc-code = v-doc-code-chip
    tt-in_trn-doc.doc-type = 'при':U
    tt-in_trn-doc.ext-doc-type = 'ie':U
    tt-in_trn-doc.out-code = buf_trn-doc.doc-code
    tt-in_trn-doc.pay-code = v-out-pay
    tt-in_trn-doc.status_ = 'накл':U
    tt-in_trn-doc.ps = substitute('по списанию техпролива &1 продажи &2'
                      , buf_trn-doc.doc-code
                      , buf_trn-doc.out-code
                      )
    tt-in_trn-doc.discnt-type = '':U
    tt-in_trn-doc.flag = no
    tt-in_trn-doc.ret-supp  = no
    tt-in_trn-doc.slt-type  = 'без':U
    tt-in_trn-doc.vat-type  = 'в т. ч.':U
    tt-in_trn-doc.purch-code = integer('1':U)
    .
    if available buf_sale-doc then do:
      assign
        tt-in_trn-doc.shift-date = buf_sale-doc.shift-date
        tt-in_trn-doc.shift-num  = buf_sale-doc.shift-num
        tt-in_trn-doc.shift-name = buf_sale-doc.shift-name
        tt-in_trn-doc.fact-date  = buf_sale-doc.fact-date
      .
    end.
    else do:
      assign
        tt-in_trn-doc.shift-date = ?
        tt-in_trn-doc.shift-num = 0
        tt-in_trn-doc.shift-name = ?
      .
    end.
    _doc-line:
    for each buf_doc-line no-lock where
            buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo _main, return error return-value :
      find first buf_goods no-lock where
                buf_goods.artic = buf_Doc-line.artic
          AND buf_goods.prod-type = buf_Doc-line.prod-type
          AND buf_goods.prod-code = buf_Doc-line.prod-code.
      find first buf_units no-lock where
                buf_units.unit-name = buf_goods.unit-base .
      find first  buf_temp-tank where
                 buf_temp-tank.gds-code = buf_goods.gds-code
             AND buf_temp-tank.doc-seq  = v-seq no-error .
      if not available buf_temp-tank then next _doc-line.
      assign
      buf_temp-tank.artic = buf_doc-line.artic
      buf_temp-tank.prod-type = buf_doc-line.prod-type
      buf_temp-tank.prod-code = buf_doc-line.prod-code
      buf_temp-tank.cli-base-rate = buf_temp-tank.fact-qnty / buf_temp-tank.cli-qnty
      buf_temp-tank.unit-type = buf_units.type
      .
      create tt-in_doc-line.
      buffer-copy
      buf_Doc-line except
      buf_doc-line.doc-code
      buf_doc-line.price-cli
      buf_doc-line.price-base
      buf_doc-line.price-rubl
      to tt-in_doc-line
      assign
      tt-in_doc-line.doc-code = v-doc-code-chip
      tt-in_doc-line.unit-cli = buf_goods.unit-cli
      tt-in_doc-line.fact-qnty = buf_temp-tank.fact-qnty
      tt-in_doc-line.doc-qnty = buf_temp-tank.doc-qnty
      .
      assign
      v-qnty       = 0
      v-sum-rubl   = 0
      v-sum-base   = 0
      .
      for each buf_parts no-lock where
              buf_parts.out-code = buf_trn-doc.doc-code
          AND buf_parts.obj-type = buf_trn-doc.obj-type
          AND buf_parts.obj-code = buf_trn-doc.obj-code
          AND buf_parts.artic = buf_doc-line.artic
          AND buf_parts.prod-type = buf_doc-line.prod-type
          AND buf_parts.prod-code = buf_doc-line.prod-code
          AND buf_parts.pl-code = buf_temp-tank.pl-code,
          first buf2_temp-tank where
                buf2_temp-tank.doc-seq = v-seq
            AND buf2_temp-tank.gds-code = buf_temp-tank.gds-code
            AND buf2_temp-tank.pl-code = buf_temp-tank.pl-code
      on error undo _main, return error return-value :
        create tt-in_parts.
        buffer-copy
        buf_parts except buf_parts.out-code
        to tt-in_parts
        assign
        tt-in_parts.out-code = v-doc-code-chip
        tt-in_parts.purch-code = tt-in_trn-doc.purch-code
        tt-in_parts.slt-type  = 'без':U
        tt-in_parts.vat-type  = 'в т. ч.':U.
        if p-doc-kind = 'vir':U then do:
            v-pl-code = ?.
            for each buf_pl-gds no-lock
                where buf_pl-gds.obj-type = buf_trn-doc.obj-type
                and buf_pl-gds.obj-code = buf_trn-doc.obj-code
                and buf_pl-gds.gds-code  = buf2_temp-tank.gds-code:
                run placelib_get-attr  ( input "place-virtual"
                                        ,input buf_trn-doc.obj-code
                                        ,input buf_trn-doc.obj-type
                                        ,input buf_pl-gds.pl-code
                                        ,output v-value
                                        ,output v-ok) no-error.
                if v-ok and logical(v-value) then v-pl-code = buf_pl-gds.pl-code.
            end.
            tt-in_parts.pl-code = v-pl-code.
        end.
        assign
        v-qnty = v-qnty + buf_parts.fact-qnty
        v-sum-rubl = v-sum-rubl + buf_parts.price-rubl * buf_parts.fact-qnty
        v-sum-base = v-sum-base + buf_parts.price-base * buf_parts.fact-qnty
        .
      end.
      assign
      buf_temp-tank.price-rubl = v-sum-rubl / v-qnty
      buf_temp-tank.price-base = v-sum-rubl / v-qnty / buf_trn-doc.base-rate * buf_trn-doc.base-scale
      buf_temp-tank.price-cli = (if v-curr-r-b = 'base':U
                                  then buf_temp-tank.price-base
                                  else buf_temp-tank.price-rubl) * buf_temp-tank.cli-base-rate
      tt-in_doc-line.price-rubl = v-sum-rubl / v-qnty
      tt-in_doc-line.price-base = v-sum-rubl / v-qnty / buf_trn-doc.base-rate * buf_trn-doc.base-scale
      tt-in_doc-line.cli-base-rate = buf_temp-tank.cli-base-rate
      tt-in_doc-line.doc-density = 1 / tt-in_doc-line.cli-base-rate
      tt-in_doc-line.cli-qnty = tt-in_doc-line.doc-density * buf_temp-tank.fact-qnty
      tt-in_doc-line.price-cli = (if v-curr-r-b = 'base':U
                                  then tt-in_doc-line.price-base
                                  else tt-in_doc-line.price-rubl) * tt-in_doc-line.cli-base-rate
      .
    end.
    for each buf_doc-line-attr no-lock where
            buf_doc-line-attr.doc-code = buf_trn-doc.doc-code,
      first  buf_temp-tank where
                 buf_temp-tank.gds-code = buf_goods.gds-code
             AND buf_temp-tank.doc-seq  = v-seq
    on error undo _main, return error return-value :
      create tt-in_doc-line-attr.
      buffer-copy
      buf_doc-line-attr except buf_doc-line-attr.doc-code
      to tt-in_doc-line-attr
      assign
      tt-in_doc-line-attr.doc-code = v-doc-code-chip
      .
    end.
    for each buf_gds-dtl no-lock where
            buf_gds-dtl.doc-code = buf_trn-doc.doc-code,
        first buf_temp-tank where
              buf_temp-tank.artic = buf_gds-dtl.artic
          AND buf_temp-tank.prod-type = buf_gds-dtl.prod-type
          AND buf_temp-tank.prod-code = buf_gds-dtl.prod-code
          AND  buf_temp-tank.doc-seq   = v-seq
    on error undo _main, return error return-value :
      create tt-in_gds-dtl.
      buffer-copy
      buf_gds-dtl except buf_gds-dtl.doc-code
      to tt-in_gds-dtl
      assign
      tt-in_gds-dtl.doc-code = v-doc-code-chip
      tt-in_gds-dtl.price-base = buf_gds-dtl.price-base - buf_gds-dtl.discnt-base
      tt-in_gds-dtl.price-rubl = buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl
      tt-in_gds-dtl.discnt-pc = 0
      tt-in_gds-dtl.discnt-base = 0
      tt-in_gds-dtl.discnt-rubl = 0
      tt-in_gds-dtl.fact-qnty = buf_temp-tank.fact-qnty
      tt-in_gds-dtl.doc-qnty = buf_temp-tank.doc-qnty
      .
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in g#lib-trn
(input ?
,input ?
,input tt-in_trn-doc.base-rate
,input tt-in_trn-doc.base-scale
,input tt-in_trn-doc.cli-code
,input tt-in_trn-doc.cli-type
,input tt-in_trn-doc.cli-name
,input tt-in_trn-doc.cr-db-num
,input g#userid
,input tt-in_trn-doc.discnt-type
,input tt-in_trn-doc.doc-code
,input tt-in_trn-doc.doc-date
,input tt-in_trn-doc.doc-type
,input tt-in_trn-doc.flag
,input tt-in_trn-doc.host-code
,input tt-in_trn-doc.internal
,input tt-in_trn-doc.obj-code
,input tt-in_trn-doc.obj-type
,input tt-in_trn-doc.office
,input tt-in_trn-doc.pay-code
,input tt-in_trn-doc.ps
,input tt-in_trn-doc.ret-supp
,input tt-in_trn-doc.slt-type
,input tt-in_trn-doc.status_
,input tt-in_trn-doc.vat-type
,input tt-in_trn-doc.ext-doc-type
,input tt-in_trn-doc.purch-code
) no-error
.
    if error-status:error then do:
      v-mes = substitute("Ошибка при генерации документа прихода по техпроливу для продажи &4:&1&2 &3"
                        , chr(10)
                        , error-status:get-message(1)
                        , return-value
                        , buf_trn-doc.doc-code
                        ).
      undo _main, return error v-mes.
    end.
    find buf-new_trn-doc where buf-new_trn-doc.doc-code = v-doc-code-chip.
    assign
    buf-new_trn-doc.out-code = buf_trn-doc.doc-code
    buf-new_trn-doc.exch-code = buf_trn-doc.exch-code
    buf-new_trn-doc.exch-rate =  buf_trn-doc.exch-rate
    buf-new_trn-doc.exch-scale = buf_trn-doc.exch-scale
    buf-new_trn-doc.print-rubl = buf_trn-doc.print-rubl
    buf-new_trn-doc.agnt       = buf_trn-doc.agnt
    buf-new_trn-doc.wrkr       = buf_trn-doc.wrkr
    buf-new_trn-doc.boss       = buf_trn-doc.boss
    .
    if available buf_sale-doc then do:
      assign
        buf-new_trn-doc.shift-date = buf_sale-doc.shift-date
        buf-new_trn-doc.shift-num  = buf_sale-doc.shift-num
        buf-new_trn-doc.shift-name = buf_sale-doc.shift-name
        buf-new_trn-doc.fact-date  = buf_sale-doc.fact-date
      .
    end.
    else do:
      assign
        buf-new_trn-doc.shift-date = ?
        buf-new_trn-doc.shift-num = 0
        buf-new_trn-doc.shift-name = ?
      .
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input buf-new_trn-doc.doc-code ,
                       input 'is-auto-trn':U ,
                       input yes ) no-error .
    if p-doc-kind = 'trf':U then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input buf-new_trn-doc.doc-code ,
                       input 'othermoves':U ,
                       input yes ) no-error .
    end.
    run saledoc-create  in this-procedure (
                                            input buf_trn-doc.out-code
                                            ,input buf-new_trn-doc.host-code
                                            ,input buf-new_trn-doc.obj-type
                                            ,input buf-new_trn-doc.obj-code
                                            ,input 'itr':U
                                            ,input 'т':U
                                            ,input no
                                            ,input '':U
                                            ,input '':U
                                            ,input 0
                                            ,buffer buf-new_trn-doc
                                            ) no-error .
    if error-status:error then do:
      undo _main, return error substitute("Ошибка при генерации записи связанного документа для прихода по техпроливу по продаже &4:&1&2 &3"
                        , chr(10)
                        , error-status:get-message(1)
                        , return-value
                        , buf-new_trn-doc.doc-code
                        ).
    end.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_copy-in in g#lib-trn4
( input parparentproc
 ,input recid(buf-new_trn-doc)
 ,input table tt-in_trn-doc
 ,input table tt-in_doc-line
 ,input table tt-in_doc-line-attr
 ,input table tt-in_gds-dtl
 ,input table tt-in_parts
 ,input no
 ,input no
 ,input yes
 ,input yes
 ,input this-procedure
  ) no-error .
    if error-status:error then do:
      undo _main, return error substitute("Ошибка при заполнении документа прихода по техпроливу по списанию по техпроливу по продаже &1&2" +
                                          "&3&2&4&2"
                                          , buf_trn-doc.out-code
                                          , chr(10)
                                          , error-status:get-message(1)
                                          , return-value ).
    end.
    for each buf_doc-line no-lock where
            buf_doc-line.doc-code = buf_trn-doc.doc-code,
       first  buf_temp-tank where
                 buf_temp-tank.artic = buf_doc-line.artic
             AND buf_temp-tank.prod-type = buf_doc-line.prod-type
             AND buf_temp-tank.prod-code = buf_doc-line.prod-code
             AND buf_temp-tank.doc-seq  = v-seq
    on error undo _main, return error return-value :
      find first in_doc-line where
                in_doc-line.artic = buf_Doc-line.artic
          AND in_doc-line.prod-type = buf_Doc-line.prod-type
          AND in_doc-line.prod-code = buf_Doc-line.prod-code
          AND in_doc-line.doc-code = v-doc-code-chip no-error .
      if available in_doc-line then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  in_doc-line.obj-type
  ,input  in_doc-line.obj-code
  ,input  in_doc-line.artic
  ,input  in_doc-line.prod-type
  ,input  in_doc-line.prod-code
  ,input  'insalepr=request':U
  ,output v-insalepr
  )  .
        if v-insalepr = false
        or (can-do(v-gds-list-diff-place, string(buf_temp-tank.gds-code)) and in_doc-line.fact-qnty = buf_temp-tank.fact-qnty)
        then do:
          assign
            in_doc-line.price-base = buf_temp-tank.price-base
            in_doc-line.price-rubl = buf_temp-tank.price-rubl
          .
        end.
        if in_doc-line.price-rubl = buf_temp-tank.price-rubl
        then do :
          assign
            in_doc-line.cli-qnty = buf_temp-tank.cli-qnty
            in_doc-line.doc-density = in_doc-line.cli-qnty / in_doc-line.fact-qnty
            in_doc-line.fact-density = in_doc-line.doc-density
            in_doc-line.cli-base-rate = 1 / in_doc-line.doc-density
            in_doc-line.price-cli = buf_temp-tank.price-cli
          .
        end .
      end.
    end.
    for each buf_doc-pl no-lock where
          buf_doc-pl.out-code = buf_trn-doc.doc-code,
       first  buf_temp-tank where
                 buf_temp-tank.gds-code = buf_doc-pl.gds-code
             AND buf_temp-tank.pl-code = buf_doc-pl.pl-code
             AND buf_temp-tank.doc-seq  = v-seq
    on error undo _main, return error return-value :
      find first in_doc-pl where
                 in_doc-pl.gds-code = buf_doc-pl.gds-code
             and in_doc-pl.pl-code  = buf_doc-pl.pl-code
             and in_doc-pl.out-code = v-doc-code-chip
             no-error .
      if available in_doc-pl
      then do :
        assign
          in_doc-pl.cli-qnty = buf_temp-tank.cli-qnty
          in_doc-pl.cli-doc-qnty = in_doc-pl.cli-qnty
          in_doc-pl.cli-fact-qnty = in_doc-pl.cli-qnty
        .
      end .
    end .
    for each buf_inv-line no-lock where
            buf_inv-line.doc-code = buf_trn-doc.doc-code,
       first  buf_temp-tank where
                 buf_temp-tank.artic = buf_inv-line.artic
             AND buf_temp-tank.prod-type = buf_inv-line.prod-type
             AND buf_temp-tank.prod-code = buf_inv-line.prod-code
             AND buf_temp-tank.doc-seq  = v-seq
    on error undo _main, return error return-value :
      find first in_inv-line where
                in_inv-line.artic = buf_inv-line.artic
          AND in_inv-line.prod-type = buf_inv-line.prod-type
          AND in_inv-line.prod-code = buf_inv-line.prod-code
          AND in_inv-line.doc-code = v-doc-code-chip no-error .
      if available in_inv-line then do:
        assign
          in_inv-line.wast-cli-qnty = buf_temp-tank.cli-qnty
          in_inv-line.after-cli-qnty = in_inv-line.before-cli-qnty + in_inv-line.wast-cli-qnty
          in_inv-line.wast-rubl = buf_temp-tank.price-cli
          in_inv-line.wast-base = buf_temp-tank.price-cli / buf_trn-doc.base-rate * buf_trn-doc.base-scale
          in_inv-line.unus-wast-rubl = in_inv-line.wast-rubl
          in_inv-line.unus-wast-base = in_inv-line.wast-base
        .
      end .
    end .
    for each buf_gds-dtl no-lock where
            buf_gds-dtl.doc-code = buf_trn-doc.doc-code,
        first buf_temp-tank where
              buf_temp-tank.artic = buf_gds-dtl.artic
          AND buf_temp-tank.prod-type = buf_gds-dtl.prod-type
          AND buf_temp-tank.prod-code = buf_gds-dtl.prod-code
          AND  buf_temp-tank.doc-seq   = v-seq
    on error undo _main, return error return-value :
      find first in_GDS-DTL where
                in_GDS-DTL.artic = buf_gds-dtl.artic
          AND in_GDS-DTL.prod-type = buf_gds-dtl.prod-type
          AND in_gds-dtl.prod-code = buf_gds-dtl.prod-code
          AND in_gds-dtl.prt-code = buf_gds-dtl.prt-code
          AND in_gds-dtl.doc-code = v-doc-code-chip no-error .
      if not available in_gds-dtl then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input buf_gds-dtl.obj-code
   ,input buf_gds-dtl.obj-type
   ,input v-doc-code-chip
   ,input buf_gds-dtl.artic
   ,input buf_gds-dtl.prod-code
   ,input buf_gds-dtl.prod-type
   ,input buf_gds-dtl.prt-code
   ,input no
  )  .
        find first in_gds-dtl where
                  in_gds-dtl.artic = buf_gds-dtl.artic
            AND in_gds-dtl.prod-type = buf_gds-dtl.prod-type
            AND in_gds-dtl.prod-code = buf_gds-dtl.prod-code
            AND in_gds-dtl.prt-code = buf_gds-dtl.prt-code
            AND in_gds-dtl.doc-code = v-doc-code-chip .
        find first in_doc-line where
                  in_doc-line.artic = buf_gds-dtl.artic
            AND in_doc-line.prod-type = buf_gds-dtl.prod-type
            AND in_doc-line.prod-code = buf_gds-dtl.prod-code
            AND in_doc-line.doc-code = v-doc-code-chip .
        assign
        in_gds-dtl.doc-qnty = buf_temp-tank.doc-qnty
        in_gds-dtl.fact-qnty = buf_temp-tank.fact-qnty
        .
      end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  in_gds-dtl.obj-type
  ,input  in_gds-dtl.obj-code
  ,input  in_gds-dtl.artic
  ,input  in_gds-dtl.prod-type
  ,input  in_gds-dtl.prod-code
  ,input  'insalepr=request':U
  ,output v-insalepr
  )  .
      assign
      in_gds-dtl.price-base = if v-insalepr = false
                              then (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
                              else in_doc-line.price-base
      in_gds-dtl.price-rubl = if v-insalepr = false
                              then (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
                              else in_doc-line.price-rubl
      in_gds-dtl.discnt-pc = 0
      in_gds-dtl.discnt-base = 0
      in_gds-dtl.discnt-rubl = 0
      .
    end.
    if v-seq-max > 1
    and v-seq < v-seq-max then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Создана приходная накладная по Техпроливу &1 в статусе &2..."
                           ,v-doc-code-chip
                           ,buf-new_trn-doc.status_
                          )).
    if p-close-in-rfsl = 1 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Согласно настройкам приходная накладная по Техпроливу &1 в статусе &2 закрывается на факт..."
                            ,v-doc-code-chip
                            ,buf-new_trn-doc.status_
                            )).
     run close-trn in this-procedure (
                                      buffer buf-new_trn-doc
                                    ) no-error.
     if error-status:error then do:
       undo _main, return error return-value .
     end.
    end.
  end.
end.
procedure close-trn :
define parameter buffer buf_trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return    as   logical             no-undo.
define variable varchg-inv         as   logical             no-undo.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  varmode         = '<закрытие документа на факт>':U
  varcheck-return = true
  varchg-inv      = true
  .
  run gbl/calc-trn.p ( input parparentproc
                  ,input  recid(buf_trn-doc)).
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
assign
v-cntxt-obj-type = buf_trn-doc.obj-type
v-cntxt-obj-code = buf_trn-doc.obj-code
v-cntxt-host-code-obj = buf_trn-doc.host-code
v-cntxt-db-num-obj = g#db-num
v-cntxt-db-num = g#db-num
v-cntxt-userid = g#userid
.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
buf_trn-doc.tot-cli = buf_trn-doc.tot-calc.
run str/trn-stat.p (
     input  parparentproc
    ,input  this-procedure:handle
    ,input  varmode
    ,input  buf_trn-doc.doc-code
    ,input  varcheck-return
    ,input  g#db-num
    ,input  v-cntxp-in-ov
    ,input  v-cntxp-rsrv-time
    ,input  v-cntxp-load-time
    ,input  v-cntxp-holidays
    ,input  NO
    ,output varchg-inv
    ,output table gds-list)    no-error.
if error-status:error then do:
  undo main-block, return error substitute("Ошибка при принудительном закрытии документа прихода по техпроливу по списанию по техпроливу по продаже &1&2" +
                                      "&3&2&4&2"
                                      , buf_trn-doc.doc-code
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value ).
  end.
end.
end procedure.
