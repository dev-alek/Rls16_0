DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_dis-card FOR ub.dis-card.
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dtm-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-sum-id AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-dt-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-node-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-emitent-host-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-type AS character NO-UNDO.
DEFINE INPUT PARAMETER p-d-card AS character NO-UNDO.
DEFINE INPUT PARAMETER p-host-code AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-obj-type AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-obj-code AS integer NO-UNDO.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE TEMP-TABLE temp-dis-card-property NO-UNDO LIKE ub.dis-card-property
field rw-option as character
field prop-label as character
field node-label as character
field data-type as character
field range as integer
INDEX attrc is
UNIQUE PRIMARY
prop-label
node-label
dt-code
host-code
obj-type
obj-code
INDEX attrcl is UNIQUE
dt-code
node-code
host-code
obj-type
obj-code
.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR temp-dis-card-property.
DEFINE OUTPUT PARAMETER p-setted AS LOGICAL NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Лимиты EasyFuel".
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
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info3 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info3, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info3, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info3 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info3, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info3, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info3, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info3, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info3, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info3, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION propreft-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function propreft-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION propreft-petrol-to-String returns character(input  p-gds-code as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = substitute("petrol-&1", p-gds-code).
return v-date-str.
END FUNCTION.
FUNCTION propreft-string-to-petrol returns integer(input  p-string as character):
define variable v-gds-code as integer no-undo .
assign
v-gds-code = integer(entry(2, p-string, "-")) no-error.
return v-gds-code.
END FUNCTION.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define stream stmxmlout .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-xml-file-name     as character            no-undo.
define variable v-xml-file-name-path as character            no-undo.
define variable v-log-file-name     as character            no-undo.
define variable v-locked            as logical              no-undo.
define variable v-log-string        as character            no-undo.
define variable v-oper-num          as integer              no-undo.
define variable v-obj-list          as character            no-undo.
DEF VAR strDummy    AS CHAR view-as editor size 50 by 4 NO-UNDO.
DEF VAR intRep      AS INT NO-UNDO.
define variable hEDT             AS HANDLE NO-UNDO.
define variable hCNT             AS HANDLE NO-UNDO.
procedure xml-cd-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name       as character    no-undo.
define input parameter p-xml-file-name-path  as character    no-undo.
define input parameter p-doc-name            as character    no-undo.
define input parameter p-version             as character    no-undo.
define input parameter p-obj-list            as character    no-undo.
define input parameter p-correspondent       as character    no-undo .
define input parameter p-write-header        as logical      no-undo .
define variable OS-time as character no-undo .
define variable id as character no-undo .
define buffer buf_db for ub.db.
output stream stmXMLOut to value( p-xml-file-name-path + "xm1":U ) convert target "1251" append.
put stream stmXMLOut unformatted "<?xml version='1.0' encoding='windows-1251'?>".
assign
OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
.
run bgelib-tag-open in this-procedure (
                                     1
                                    ,p-doc-name
                                    ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", p-xml-file-name, p-obj-list, p-correspondent, OS-time )
                                      ).
if p-write-header then do:
  run bgelib-tag-open(2, "Header","").
  run bgelib-tag-put( 3, "DocumentName", p-doc-name, 1).
  run bgelib-tag-put( 3, "DateFormat", "DD.MM.YYYY":U, 1).
  run bgelib-tag-put( 3, "DocumentVersion", "1.02":U, 1).
  run bgelib-tag-put( 3, "DocumentVersionDate", "09.09.2004":U, 1).
  run bgelib-tag-put( 3, "ExportDate", string(today, "99.99.9999":U), 1).
  run bgelib-tag-put( 3, "ExportTime", string(time, "hh:mm:ss":U), 1).
  run bgelib-tag-put( 3, "objList",             p-obj-list                    , 1).
  find first buf_db where buf_db.db-num = g#db-num no-lock.
  run bgelib-tag-put( 3, "dbEncKey",            buf_db.db-key-enc, 1).
  run bgelib-tag-close( 2, "Header" ).
end.
output stream stmXMLOut close.
end.
end procedure.
procedure xml-cd-write-footer:
do
on error undo, return error
:
define input parameter p-pos-type      like ub.cash-desk.pos-type no-undo .
define input parameter p-xml-file-name as character    no-undo.
define input parameter p-doc-name      as character    no-undo .
define variable v-error-num     as integer           no-undo.
define variable v-md5-signature as character no-undo .
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run bgelib-tag-close( 0, p-doc-name ).
put stream stmXMLOut unformatted skip.
output stream stmXMLOut close.
run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
if v-error-num > 0
then do:
   return error.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-cd-filename :
do
on error undo, return error
:
define input parameter  p-out               as character no-undo .
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-xml-file-name-path   as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-out as character     no-undo.
define variable loc#log as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable v-remote as character no-undo .
assign
p-xml-file-name = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
p-xml-file-name-path = p-out + p-xml-file-name + ".":U
p-log-file-name = p-out + "actions.log"
p-locked = ( search ( p-xml-file-name-path + "lk" ) <> ? )
.
end.
end procedure.
FUNCTION Xml-CD-DatetoString returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
FUNCTION Xml-CD-DateTimetoString returns character (input  p-date as date, p-time as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U) + chr(32) +
             string(p-time, "HH:MM:SS").
return v-date-str.
END FUNCTION.
function string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 4, 2))
                ,integer(substring(p-string, 1, 2))
                ,integer(substring(p-string, 7, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION string-IS0-8601-to-sec returns integer (input p-string-iso-8601 as character ):
define variable v-time as integer no-undo init ?.
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
assign
v-dop1 = entry(1, p-string-iso-8601, chr(32) )
v-dop2 = entry(2, p-string-iso-8601, chr(32) )
no-error .
if error-status:error then return ?.
assign
v-time =  integer(entry(1, v-dop2, ";":U)) * 3600 +
          integer(entry(2, v-dop2, ";":U)) * 60 +
          integer(entry(3, v-dop2, ";":U)) no-error .
return v-time.
END FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-ef no-undo
field d-card as character
field car-reg-number as character label "Госрег. номер"
field car-brand as character  label "Марка трансп. ср-ва"
field ef-format as integer    label "Формат записи на МБ"
field access-key as character
field petrol-code-1 as integer label "Топливо №1"
field petrol-code-2 as integer label "Топливо №2"
field petrol-code-3 as integer label "Топливо №3"
field petrol-code-4 as integer label "Топливо №4"
field init-date-time as character
field petrol-list-1 as character
field petrol-list-2 as character
field issue-code as integer  label "Выдал магазин"
field db-num as integer
field user-id as integer
field issue-date as date     label "Дата Выдачи"
field issue-time as integer
field valid-from as date     label "Действует с"
field valid-date as date     label "Действует по"
field issued-by as character label "Выдал оператор"
field init-operator as character label "Прошивал"
index pi is unique primary
d-card
.
DEFINE TEMP-TABLE temp-ef1 NO-UNDO
field d-card as character
FIELD petrol-code AS INTEGER  format ">>>>>>>>9"  label "Код в IBS TH"
FIELD sum-id AS character
FIELD dt-code AS integer
FIELD dtm-code AS integer
FIELD ef-petrol-code AS INTEGER   label "Код топлива EasyFuel"
FIELD common-limit AS DECIMAL label "Общий лимит"
FIELD unlim-common-limit AS logical label "Общий!лимит!неогран"
FIELD month-limit AS DECIMAL label "Месячный лимит"
FIELD unlim-month-limit AS logical label "Месячн!лимит!неогран"
FIELD day-limit AS DECIMAL label "Дневной лимит"
FIELD unlim-day-limit AS logical label "Дневн!лимит!неогран"
FIELD standard-dose AS DECIMAL label "Cтандартная доза"
FIELD petrol-num AS INTEGER  label "№ топлива на МБ"
FIELD common-expense AS DECIMAL label "Общий расход"
FIELD month-expense AS DECIMAL label "Месячный расход"
FIELD day-expense AS DECIMAL label "Дневной расход"
FIELD last-date AS Date label "Дата посл.измен"
FIELD last-time AS integer
field new_ as logical
INDEX pi IS UNIQUE PRIMARY
d-card
dt-code
INDEX ip petrol-code
index iefp ef-petrol-code
.
DEFINE TEMP-TABLE temp-efh NO-UNDO
field d-card as character
FIELD petrol-code AS INTEGER
FIELD ef-petrol-code AS INTEGER
field seq as integer
field date_ as date
field time_ as integer
field obj-code as integer
field pump-code as integer
field nozzle-code as integer
field cash-desk as integer
field chk-num as integer
field doc-qnty-pl100 as decimal
INDEX pi IS UNIQUE PRIMARY
d-card
petrol-code
INDEX ip petrol-code
.
DEFINE TEMP-TABLE temp-ef2 NO-UNDO
field d-card as character
FIELD month-limit AS DECIMAL
FIELD day-limit AS DECIMAL
FIELD standard-dose AS DECIMAL
FIELD common-limit AS DECIMAL
FIELD purse-num AS INTEGER
INDEX pi IS UNIQUE PRIMARY
d-card purse-num
.
FUNCTION get-ef-petrol-code RETURNS INTEGER
  ( INPUT p-b-code AS INTEGER ) :
DEFINE VARIABLE v-ef-petrol-code AS INTEGER NO-UNDO.
define variable v-key-rec as character no-undo .
DEFINE buffer buf_goods FOR ub.goods.
DEFINE buffer buf_ext-classif FOR ub.ext-classif.
FIND FIRST buf_goods NO-LOCK WHERE
        buf_goods.gds-code = p-b-code .
run gen-key-rec in THIS-PROCEDURE ( INPUT 'goods':U
                                  ,INPUT (buffer buf_goods:HANDLE)
                                    ,OUTPUT v-key-rec).
 FIND FIRST buf_ext-classif NO-LOCK WHERE
            buf_Ext-classif.classif-subject = 'goods':U
         AND buf_Ext-classif.classif-name = 'exp-easyfuel-talon-gds-code':U
      AND buf_ext-classif.uniq-key-rec = v-key-rec NO-ERROR.
 IF AVAILABLE buf_ext-classif THEN DO:
   ASSIGN
   v-ef-petrol-code = buf_ext-classif.key#_one.
 END.
 RETURN v-ef-petrol-code.
END FUNCTION.
FUNCTION get-petrol-gds-code RETURNS INTEGER
  ( INPUT p-ef-petrol-code AS INTEGER ) :
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-key-rec as character no-undo .
DEFINE buffer buf_goods FOR ub.goods.
DEFINE buffer buf_ext-classif FOR ub.ext-classif.
 FIND FIRST buf_ext-classif NO-LOCK WHERE
            buf_Ext-classif.classif-subject = 'goods':U
         AND buf_Ext-classif.classif-name = 'exp-easyfuel-talon-gds-code':U
      AND buf_ext-classif.key#_one = p-ef-petrol-code NO-ERROR.
 IF AVAILABLE buf_ext-classif THEN DO:
   run gen-row-keyr in this-procedure (
                                        input  buf_ext-classif.uniq-key-rec
                                       ,input ?
                                       ,input "ub"
                                       ,input ?
                                       ,input no-lock
                                       ,output v-tbl-row
                                       ,output v-tbl-name) no-error.
   if not error-status:error then do:
     find first buf_goods no-lock where
              rowid(buf_goods) = v-tbl-row.
     return buf_goods.gds-code.
   end.
 END.
 RETURN 0.
END FUNCTION.
procedure fill-main-table :
define input parameter p-d-card as character no-undo .
define parameter buffer buf_dis-card for ub.dis-card.
define buffer buf_temp-dis-card-property for temp-dis-card-property.
define buffer buf_temp-ef for temp-ef.
do
on error undo, return error
:
  for each buf_temp-ef:
    delete buf_temp-ef.
  end.
  create buf_temp-ef.
  buf_temp-ef.ef-format = 1.
  if available buf_dis-card then do:
    buffer-copy buf_dis-card
    except d-card
    to buf_temp-ef
    assign
    buf_temp-ef.d-card = p-d-card
    .
  end.
  else do:
    assign
    buf_temp-ef.d-card = p-d-card.
  end.
 FOR EACH temp-dis-card-property where
       temp-dis-card-property.d-card = p-d-card
    and temp-dis-card-property.dtm-code = 25
    :
   CASE temp-dis-card-property.node-code:
     WHEN 1 THEN DO:
       buf_temp-ef.car-reg-number = temp-dis-card-property.property-value-character.
     END.
     WHEN 2 THEN DO:
        buf_temp-ef.car-brand = temp-dis-card-property.property-value-character.
     END.
     WHEN 3 THEN DO:
       buf_temp-ef.ef-format = temp-dis-card-property.property-value-integer.
       IF ERROR-STATUS:ERROR THEN UNDO, RETURN ERROR.
     END.
     WHEN 4 THEN DO:
       buf_temp-ef.access-key = temp-dis-card-property.property-value-character.
     END.
     WHEN 5 THEN DO:
       buf_temp-ef.petrol-code-1 = temp-dis-card-property.property-value-integer.
     END.
     WHEN 6 THEN DO:
       buf_temp-ef.petrol-code-2 = temp-dis-card-property.property-value-integer.
     END.
     WHEN 7 THEN DO:
        buf_temp-ef.petrol-code-3 = temp-dis-card-property.property-value-integer.
     END.
     WHEN 8 THEN DO:
       buf_temp-ef.petrol-code-4 = temp-dis-card-property.property-value-integer.
     END.
     WHEN 11 THEN DO:
        buf_temp-ef.init-date-time = temp-dis-card-property.property-value-character.
     END.
     WHEN 12 THEN DO:
        buf_temp-ef.init-operator = temp-dis-card-property.property-value-character.
     END.
     WHEN 13 THEN DO:
        buf_temp-ef.issued-by = temp-dis-card-property.property-value-character.
        buf_temp-ef.db-num = integer(entry(1, temp-dis-card-property.property-value-character, "-")).
        buf_temp-ef.user-id = integer(entry(2, temp-dis-card-property.property-value-character, "-")).
     END.
   END CASE.
 END.
 RUN fill-tables IN THIS-PROCEDURE ( INPUT buf_temp-ef.ef-format, buffer buf_temp-ef) NO-ERROR.
end.
end procedure.
PROCEDURE fill-tables :
DEFINE INPUT PARAMETER p-ef-format AS INTEGER NO-UNDO.
define parameter buffer buf_temp-ef for temp-ef.
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
DEFINE VARIABLE v-gds-code AS INTEGER NO-UNDO.
DEFINE BUFFER bufl_temp-dis-card-property FOR temp-dis-card-property.
DEFINE BUFFER buf_temp-dis-card-property FOR temp-dis-card-property.
CASE p-ef-format:
  WHEN 1  THEN DO:
    FOR EACH bufl_temp-dis-card-property NO-LOCK WHERE
            bufl_temp-dis-card-property.d-card = buf_temp-ef.d-card
         AND bufl_temp-dis-card-property.dtm-code = 24:
      FIND FIRST temp-ef1 WHERE
                temp-ef1.d-card = buf_temp-ef.d-card
            and temp-ef1.dt-code = bufl_temp-dis-card-property.dt-code NO-ERROR.
      IF NOT AVAILABLE temp-ef1 THEN do:
         CREATE temp-ef1.
         ASSIGN
         temp-ef1.d-card = buf_temp-ef.d-card
         temp-ef1.sum-id = bufl_temp-dis-card-property.sum-id
         temp-ef1.dt-code = bufl_temp-dis-card-property.dt-code
         temp-ef1.dtm-code = bufl_temp-dis-card-property.dtm-code
         .
         v-gds-code = propreft-string-to-petrol( INPUT bufl_temp-dis-card-property.sum-id).
         ASSIGN
         temp-ef1.petrol-code  = v-gds-CODE
         .
         ASSIGN
         temp-ef1.ef-petrol-code = get-ef-petrol-code ( temp-ef1.petrol-code)
          .
         DO v-ii = 1 TO 4:
           IF temp-ef1.petrol-code = buffer buf_temp-ef:buffer-field( substitute("petrol-code-&1", v-ii)):buffer-value THEN DO:
             temp-ef1.petrol-num = v-ii.
           END.
         END.
      END.
      CASE bufl_temp-dis-card-property.node-code:
        WHEN 1 THEN DO:
            ASSIGN
            temp-ef1.month-limit = bufl_temp-dis-card-property.property-value-decimal
            temp-ef1.unlim-month-limit = (temp-ef1.month-limit = ?)
            .
        END.
        WHEN 2 THEN DO:
            ASSIGN
            temp-ef1.day-limit = bufl_temp-dis-card-property.property-value-decimal
            temp-ef1.unlim-day-limit = (temp-ef1.day-limit = ?)
            .
        END.
        WHEN 3 THEN DO:
            ASSIGN
            temp-ef1.standard-dose = bufl_temp-dis-card-property.property-value-decimal.
        END.
        WHEN 4 THEN DO:
            ASSIGN
            temp-ef1.common-limit = bufl_temp-dis-card-property.property-value-decimal
            temp-ef1.unlim-common-limit = (temp-ef1.common-limit = ?)
            .
        END.
      END CASE.
   END.
  END.
  OTHERWISE DO:
     MESSAGE
     substitute("Формат данныx &1 для МБ в настоящий момент не поддерживается", p-ef-format)
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
  END.
END CASE.
END PROCEDURE.
procedure fill-expenses :
DEFINE INPUT PARAMETER p-ef-format AS INTEGER NO-UNDO.
define parameter buffer buf_temp-ef for temp-ef.
define variable v-cd-petrol-code as character no-undo .
define buffer buf_cd-trans for ub.cd-trans.
define buffer bufe_cd-trans for ub.cd-trans.
define buffer buf_temp-ef1 for temp-ef1.
do
on error undo, return error
:
  for each buf_temp-ef1 where
        buf_temp-ef1.d-card = buf_temp-ef.d-card:
    find last buf_cd-trans no-lock where
            buf_cd-trans.trans-type  = integer('40':U)
        and buf_cd-trans.charkey_one = buf_temp-ef.d-card
        and buf_cd-trans.charkey_two = v-cd-petrol-code use-index ichkdate
          no-error.
    if available buf_cd-trans then do:
      find first bufe_cd-trans no-lock where
            bufe_cd-trans.trans-type  = integer('41':U)
        and bufe_cd-trans.charkey_one = buf_temp-ef.d-card
        and bufe_cd-trans.charkey_two = v-cd-petrol-code
        and bufe_cd-trans.trans-id-chr = buf_cd-trans.trans-id-chr use-index ichkdate no-error .
      if available bufe_cd-trans then do:
        assign
        buf_temp-ef1.common-expense = buf_cd-trans.deckey_one
        buf_temp-ef1.month-expense = buf_cd-trans.deckey_two
        buf_temp-ef1.day-expense = buf_cd-trans.deckey_three
        buf_temp-ef1.last-date = buf_cd-trans.chk-date
        .
      end.
      else do:
        assign
        buf_temp-ef1.last-date = string-to-date(buf_temp-ef.init-date-time)
        .
      end.
    end.
    else do:
      assign
      buf_temp-ef1.last-date = string-to-date(buf_temp-ef.init-date-time)
      .
    end.
  end.
end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrfulnf returns character ( input p-user-id as character):
define variable v-user-name as character no-undo .
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrfulnm in g#library
  (input  p-user-id
  ,output v-user-name
  ) no-error .
if error-status:error
or v-user-name = ""
then do:
  return p-user-id.
end.
else do:
  return v-user-name.
end.
end function.
define variable is-ef-chr as character no-undo .
define variable par-type as character no-undo .
define variable v-init-mode as logical no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
DEFINE VARIABLE v-petrol-code AS INTEGER NO-UNDO EXTENT 4.
FUNCTION get-gds-name RETURNS CHARACTER
  ( INPUT p-gds-code AS INTEGER )  FORWARD.
DEFINE BUTTON b-add-limits
     LABEL "Добавить лимиты"
     SIZE 17 BY 1.
DEFINE BUTTON b-card
     LABEL "Карта"
     SIZE 10 BY 1.
DEFINE BUTTON b-cli
     LABEL "Клиент"
     SIZE 10 BY 1.
DEFINE BUTTON b-del-limits
     LABEL "Удалить лимиты"
     SIZE 17 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-initialize AUTO-GO
     LABEL "Инициализация МБ"
     SIZE 20 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-access-key AS CHARACTER FORMAT "X(8)":U
     LABEL "Ключ доступа"
     VIEW-AS FILL-IN NATIVE
     SIZE 9 BY 1 NO-UNDO.
DEFINE VARIABLE f-car-brand AS CHARACTER FORMAT "X(256)":U
     LABEL "Марка ТС"
     VIEW-AS FILL-IN
     SIZE 40 BY 1.07 NO-UNDO.
DEFINE VARIABLE f-car-reg-number AS CHARACTER FORMAT "X(10)":U
     LABEL "Гос.рег.знак"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE f-init-date-time AS CHARACTER FORMAT "X(19)":U
     LABEL "Дата и время прошивки"
     VIEW-AS FILL-IN NATIVE
     SIZE 20 BY 1 NO-UNDO.
DEFINE VARIABLE f-init-operator-name AS CHARACTER FORMAT "X(20)":U
     LABEL "Инициализировал"
     VIEW-AS FILL-IN NATIVE
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE f-issued-by-name AS CHARACTER FORMAT "X(20)":U
     LABEL "Выдал"
     VIEW-AS FILL-IN NATIVE
     SIZE 19 BY 1 NO-UNDO.
DEFINE VARIABLE l-ef-format AS CHARACTER FORMAT "X(256)":U INITIAL "Формат данных на МБ"
      VIEW-AS TEXT
     SIZE 20 BY .67 NO-UNDO.
DEFINE VARIABLE rs-ef-format AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "1", 1,
"2", 2
     SIZE 7 BY 1 NO-UNDO.
DEFINE QUERY br-ef1 FOR
      temp-ef1 SCROLLING.
DEFINE BROWSE br-ef1
  QUERY br-ef1 DISPLAY
      temp-ef1.petrol-num COLUMN-LABEL "№ топ.!на МБ" format "9"
 temp-ef1.petrol-code COLUMN-LABEL "Код!топлива!(IBS TH)"
 temp-ef1.ef-petrol-code COLUMN-LABEL "Код!топлива!EasyFuel"
 get-gds-name(temp-ef1.petrol-code) COLUMN-LABEL "Название!топлива" FORMAT "X(10)"
 temp-ef1.standard-dose COLUMN-LABEL "Стандартная!доза" FORMAT ">>,>>9"
 temp-ef1.day-limit   COLUMN-LABEL "Дневной!лимит" FORMAT ">,>>>,>>9"
 temp-ef1.unlim-day-limit COLUMN-LABEL  "Дневн!лимит!неогран" label-font 4 view-as toggle-box
 temp-ef1.month-limit COLUMN-LABEL  "Месячный!лимит" FORMAT ">,>>>,>>9"
 temp-ef1.unlim-month-limit COLUMN-LABEL  "Месячн!лимит!неогран" label-font 4 view-as toggle-box
 temp-ef1.common-limit COLUMN-LABEL "Общий!лимит" FORMAT ">,>>>,>>9"
 temp-ef1.unlim-common-limit COLUMN-LABEL  "Общий!лимит!неогран" label-font 4 view-as toggle-box
 ENABLE
 temp-ef1.petrol-num
 temp-ef1.standard-dose
 temp-ef1.day-limit
 temp-ef1.month-limit
 temp-ef1.common-limit
 temp-ef1.unlim-day-limit
 temp-ef1.unlim-month-limit
 temp-ef1.unlim-common-limit
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.8 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-card AT ROW 1 COL 38 WIDGET-ID 36
     b-cli AT ROW 1 COL 48 WIDGET-ID 38
     b-initialize AT ROW 1 COL 58 WIDGET-ID 34
     B-Help AT ROW 1 COL 95
     f-car-brand AT ROW 2.33 COL 14 COLON-ALIGNED
     f-access-key AT ROW 2.33 COL 76 COLON-ALIGNED WIDGET-ID 30 PASSWORD-FIELD
     f-car-reg-number AT ROW 3.93 COL 14 COLON-ALIGNED
     rs-ef-format AT ROW 3.93 COL 48 NO-LABEL WIDGET-ID 22
     f-init-date-time AT ROW 3.93 COL 76.5 COLON-ALIGNED WIDGET-ID 32
     b-add-limits AT ROW 5.27 COL 1 WIDGET-ID 28
     b-del-limits AT ROW 5.27 COL 18 WIDGET-ID 46
     f-issued-by-name AT ROW 5.27 COL 41 COLON-ALIGNED WIDGET-ID 44
     f-init-operator-name AT ROW 5.27 COL 77.5 COLON-ALIGNED WIDGET-ID 42
     br-ef1 AT ROW 6.33 COL 1 WIDGET-ID 100
     l-ef-format AT ROW 3.93 COL 26 COLON-ALIGNED NO-LABEL WIDGET-ID 26
     SPACE(51.09) SKIP(14.59)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Идентификаторы и лимиты EasyFuel"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       f-access-key:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON END-ERROR OF FRAME Dialog-Frame
DO:
  RUN undo-proc IN THIS-PROCEDURE NO-ERROR.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add-limits IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  define VARIABLE v-tbl-row    as rowid     no-undo.
  define variable v-tbl-name   as character no-undo.
  define variable v-sum-id   as character no-undo.
  DEFINE VARIABLE v-gds-code AS INTEGER NO-UNDO.
  define variable v-recid as recid no-undo .
  DEFINE BUFFER buf_goods FOR ub.goods.
  DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
  DEFINE BUFFER buf_temp-ef1 FOR temp-ef1.
  DEFINE BUFFER buf_prop-ref FOR ub.prop-ref.
  run ref/proprefs.w (
                    input parparentproc
                  ,input 'b-sel'
                  ,input "dtm-code"
                  ,input STRING(24)
                  ,input '':U
                  ,input buf_Dis-card-type.uniq-key-rec
                  ,input-output  v-rid-list) no-error.
    find first buf_prop-ref no-lock where
              recid(buf_prop-ref) = integer(v-rid-list) no-error .
    if not available buf_prop-ref then return no-apply.
  FIND FIRST buf_temp-ef1 NO-LOCK WHERE
           buf_temp-ef1.d-card = p-d-card
        and buf_temp-ef1.sum-id = buf_prop-ref.sum-id NO-ERROR.
  IF AVAILABLE buf_temp-ef1 THEN DO:
      MESSAGE
      "Для данного МБ уже определены лимиты на данное топливо"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  CREATE buf_temp-ef1.
  ASSIGN
  buf_temp-ef1.sum-id = buf_prop-ref.sum-id
  buf_temp-ef1.dt-code = buf_prop-ref.dt-code
  buf_temp-ef1.dtm-code = buf_prop-ref.dtm-code
  buf_temp-ef1.new_ = yes
  buf_temp-ef1.d-card = p-d-card
  .
  v-gds-code = propreft-string-to-petrol(buf_prop-ref.sum-id).
  ASSIGN
  buf_temp-ef1.petrol-code = v-gds-code
  .
  ASSIGN
  buf_temp-ef1.ef-petrol-code = get-ef-petrol-code( buf_temp-ef1.petrol-code)
  buf_temp-ef1.petrol-num = 0
  v-recid = recid(buf_temp-ef1)
  .
  OPEN QUERY br-ef1 FOR EACH temp-ef1 BY temp-ef1.petrol-code.
  reposition  br-ef1 to recid v-recid no-error .
  apply "ENTRY" to temp-ef1.petrol-num in browse br-ef1.
END.
ON CHOOSE OF b-card IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-ri AS RECID NO-UNDO.
  IF AVAILABLE X_dis-card THEN DO:
      v-ri = RECID(X_dis-card).
      run ref/dcardi.w ( INPUT parparentproc
                        ,INPUT 'ПРОСМОТР':U
                        ,INPUT X_dis-card.emitent-host-code
                        ,INPUT v-cntxt-host-code-obj
                        ,INPUT v-cntxt-obj-type
                        ,INPUT v-cntxt-obj-code
                        ,INPUT ?
                        ,INPUT-OUTPUT v-ri) NO-ERROR.
     IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF b-cli IN FRAME Dialog-Frame
DO:
  IF AVAILABLE X_clients THEN DO:
      run ref/showcli.p (
       input parParentProc
      ,input X_clients.obj-type
      ,input X_clients.obj-code
      ) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  END.
END.
ON CHOOSE OF b-del-limits IN FRAME Dialog-Frame
DO:
DEFINE BUFFER buf_temp-ef1 FOR temp-ef1.
DEFINE BUFFER del_dis-card-property FOR ub.dis-card-property.
  IF NOT AVAILABLE temp-ef1 THEN RETURN NO-APPLY.
  FIND FIRST buf_temp-ef1 WHERE recid(buf_temp-ef1) = RECID(temp-ef1).
  FIND FIRST del_dis-card-property NO-LOCK WHERE
            DEL_dis-card-property.d-card = buf_temp-ef1.d-card
       AND  DEL_dis-card-property.dt-code = buf_temp-ef1.dt-code
      AND DEL_dis-card-property.host-code = 0
      AND DEL_dis-card-property.obj-type = ""
      AND DEL_dis-card-property.obj-code = 0 NO-ERROR.
  IF AVAILABLE DEL_dis-card-property THEN DO:
      MESSAGE
      "Нельзя удалить существующие лимиты"
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
  END.
  DELETE buf_temp-ef1.
  OPEN QUERY br-ef1 FOR EACH temp-ef1 BY temp-ef1.petrol-code.
  reposition  br-ef1 to ROW 1 no-error .
  apply "ENTRY" to temp-ef1.petrol-num in browse br-ef1.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.
ON CHOOSE OF b-initialize IN FRAME Dialog-Frame
DO:
 ASSIGN
 p-setted = YES
 .
END.
on value-changed of
temp-ef1.unlim-day-limit in browse br-ef1 do:
define variable old-unlim-day-limit as logical no-undo .
define buffer buf_temp-ef1 for temp-ef1.
if not avail temp-ef1 then return no-apply.
assign
old-unlim-day-limit = temp-ef1.unlim-day-limit
.
find first buf_temp-ef1 where
         recid(buf_temp-ef1) = recid(temp-ef1).
case logical(temp-ef1.unlim-day-limit:screen-value in browse br-ef1):
  when yes then do:
    assign
    buf_temp-ef1.day-limit = ?
    buf_temp-ef1.unlim-day-limit = yes
    .
    temp-ef1.day-limit:read-only in browse br-ef1 = yes.
  end.
  when no then do:
    if buf_temp-ef1.day-limit = ? then
    assign
    buf_temp-ef1.day-limit = 0
    .
    buf_temp-ef1.unlim-day-limit = no.
    temp-ef1.day-limit:read-only in browse br-ef1 = no.
  end.
end case.
release buf_temp-ef1.
display
temp-ef1.day-limit
temp-ef1.unlim-day-limit
with browse br-ef1.
end.
on value-changed of
temp-ef1.unlim-month-limit in browse br-ef1 do:
define variable old-unlim-month-limit as logical no-undo .
define buffer buf_temp-ef1 for temp-ef1.
if not avail temp-ef1 then return no-apply.
assign
old-unlim-month-limit = temp-ef1.unlim-month-limit
.
find first buf_temp-ef1 where
         recid(buf_temp-ef1) = recid(temp-ef1).
case logical(temp-ef1.unlim-month-limit:screen-value in browse br-ef1):
  when yes then do:
    assign
    buf_temp-ef1.month-limit = ?
    buf_temp-ef1.unlim-month-limit = yes
    .
    temp-ef1.month-limit:read-only in browse br-ef1 = yes.
  end.
  when no then do:
    if buf_temp-ef1.month-limit = ? then
    assign
    buf_temp-ef1.month-limit = 0
    .
    buf_temp-ef1.unlim-month-limit = no.
    temp-ef1.month-limit:read-only in browse br-ef1 = no.
  end.
end case.
release buf_temp-ef1.
display
temp-ef1.month-limit
temp-ef1.unlim-month-limit
with browse br-ef1.
end.
on value-changed of
temp-ef1.unlim-common-limit in browse br-ef1 do:
define variable old-unlim-common-limit as logical no-undo .
define buffer buf_temp-ef1 for temp-ef1.
if not avail temp-ef1 then return no-apply.
assign
old-unlim-common-limit = temp-ef1.unlim-common-limit
.
find first buf_temp-ef1 where
         recid(buf_temp-ef1) = recid(temp-ef1).
case logical(temp-ef1.unlim-common-limit:screen-value in browse br-ef1):
  when yes then do:
    assign
    buf_temp-ef1.common-limit = ?
    buf_temp-ef1.unlim-common-limit = yes
    .
    temp-ef1.common-limit:read-only in browse br-ef1 = yes.
  end.
  when no then do:
    if buf_temp-ef1.common-limit = ? then
    assign
    buf_temp-ef1.common-limit = 0
    .
    buf_temp-ef1.unlim-month-limit = no.
    temp-ef1.common-limit:read-only in browse br-ef1 = no.
  end.
end case.
release buf_temp-ef1.
display
temp-ef1.common-limit
temp-ef1.unlim-common-limit
with browse br-ef1.
end.
ON LEAVE OF
temp-ef1.petrol-num IN BROWSE br-ef1,
temp-ef1.month-limit in BROWSE br-ef1,
temp-ef1.day-limit in BROWSE br-ef1,
temp-ef1.standard-dose in BROWSE br-ef1,
temp-ef1.common-limit in BROWSE br-ef1 do:
define variable old-petrol-num as integer no-undo .
define variable old-month-limit as decimal no-undo .
define variable old-day-limit as decimal no-undo .
define variable old-standard-dose as decimal no-undo .
define variable old-common-limit as decimal no-undo .
define variable v-petrol-num as integer no-undo .
define buffer buf_temp-ef1 for temp-ef1.
if not avail temp-ef1 then return no-apply.
assign
old-petrol-num = temp-ef1.petrol-num
old-month-limit = temp-ef1.month-limit
old-day-limit = temp-ef1.day-limit
old-standard-dose = temp-ef1.standard-dose
old-common-limit = temp-ef1.common-limit
.
assign
v-petrol-num = integer(temp-ef1.petrol-num:screen-value in browse br-ef1)
.
if v-petrol-num > 4 then do:
  message
  "№ топлива на МБ EasyFuel не может быть больше 4!"
  view-as alert-box error .
  assign
  temp-ef1.petrol-num:screen-value in browse br-ef1 = string(old-petrol-num)
  .
  return no-apply.
end.
find first buf_temp-ef1 where
         buf_temp-ef1.d-card = p-d-card
      and buf_temp-ef1.petrol-num = v-petrol-num
      and v-petrol-num > 0
      and recid(buf_temp-ef1) <> recid(temp-ef1) no-error.
if available buf_temp-ef1 then do:
  message
  "Уже есть такой № топлива на МБ EasyFuel!"
  view-as alert-box error .
  assign
  temp-ef1.petrol-num:screen-value = string(old-petrol-num)
  .
  return no-apply.
end.
if decimal(temp-ef1.month-limit:screen-value in browse br-ef1) > 1000000 then do:
  message
  "Месячный лимит не может превышать 1000000"
  view-as alert-box error.
  assign
  temp-ef1.month-limi:screen-value = string(old-month-limit)
  .
  return no-apply.
end.
if decimal(temp-ef1.day-limit:screen-value in browse br-ef1) > 32000 then do:
  message
  "Дневной лимит не может превышать 32000"
  view-as alert-box error.
  assign
  temp-ef1.day-limit:screen-value = string(old-day-limit)
  .
  return no-apply.
end.
if decimal(temp-ef1.standard-dose:screen-value in browse br-ef1) > 32000 then do:
  message
  "Стандартная доза не может превышать 32000"
  view-as alert-box error.
  assign
  temp-ef1.standard-dose:screen-value = string(old-standard-dose)
  .
  return no-apply.
end.
if decimal(temp-ef1.common-limit:screen-value in browse br-ef1) > 1000000 then do:
  message
  "Общий лимит не может превышать 1000000"
  view-as alert-box error.
  assign
  temp-ef1.common-limi:screen-value = string(old-common-limit)
  .
  return no-apply.
end.
find first buf_temp-ef1 where recid(buf_temp-ef1) = recid(temp-ef1).
assign
buf_temp-ef1.petrol-num = integer(temp-ef1.petrol-num:screen-value in browse br-ef1)
buf_temp-ef1.month-limit = decimal(temp-ef1.month-limit:screen-value in browse br-ef1)
buf_temp-ef1.day-limit = decimal(temp-ef1.day-limit:screen-value in browse br-ef1)
buf_temp-ef1.standard-dose = decimal(temp-ef1.standard-dose:screen-value in browse br-ef1)
buf_temp-ef1.common-limit = decimal(temp-ef1.common-limit:screen-value in browse br-ef1)
.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
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
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
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
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
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
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
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
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
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
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame Dialog-Frame :height)
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
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
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
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
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
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
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
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
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
      v-field-group-handle = frame Dialog-Frame :first-child
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
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
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
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
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
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame Dialog-Frame
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
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
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
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
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
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
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
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-ef1 :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    FIND FIRST buf_Dis-card-type NO-LOCK WHERE
          buf_dis-card-type.emitent-host-code = p-emitent-host-code
      AND   buf_dis-card-type.TYPE = p-type
    AND buf_dis-card-type.host-code = 0
    AND buf_Dis-card-type.obj-type = '':U
    AND buf_Dis-card-type.obj-code = 0 NO-ERROR.
    IF NOT AVAILABLE buf_dis-card-type THEN DO:
      MESSAGE
      "Не определен тип ДК" SKIP
        "Невозможно задать свойство"
        VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
    END.
    IF NOT (buf_Dis-card-type.card-media = integer('5':U)) THEN DO:
      MESSAGE
      "Данное свойство можно задать ТОЛЬКО для карты типа EASY-FUEL"
      VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
 FOR EACH temp-ef1:
    DELETE temp-ef1.
  END.
  FOR EACH temp-ef2:
    DELETE temp-ef2.
  END.
  IF p-mode <> 'ДОБАВЛЕНИЕ':U
  AND p-mode <> 'ИЗМЕНЕНИЕ':U
  AND p-mode <> 'ПРОСМОТР':U
  and p-mode <> 'ПРОСМОТР':U + chr(44) + "init"
  THEN DO:
    MESSAGE
    substitute("Неверное значение параметра p-mode=&1", p-mode)
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN ERROR.
  END.
  assign
  v-init-mode = (if num-entries(p-mode) > 1
                 and entry(2, p-mode) = "init"
                 then yes
                 else no)
  p-mode = entry(1, p-mode)
  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ef'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output is-ef-chr
  ,output par-type
  ) no-error .
  if error-status:error
  or logical(is-ef-chr) = no then do:
    message
    "В Вашей конфигурации нельзя работать с этим свойством ДК," skip
    "так как не включен конфигурационный параметр is-ef"
    view-as alert-box .
    undo, return error .
  end.
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = p-dtm-code.
  find first buf_prop-ref no-lock where
          buf_prop-ref.dtm-code = p-dtm-code
      and buf_prop-ref.dt-code = p-dt-code.
  case p-dtm-code:
    when 25 then do:
    end.
    when 24 then do:
    end.
  end case.
  FIND FIRST X_dis-card NO-LOCK WHERE
            X_dis-card.d-card = p-d-card NO-ERROR.
  IF AVAILABLE X_dis-card THEN DO:
      FIND FIRST X_clients NO-LOCK WHERE
                X_clients.obj-type = X_dis-card.cli-type
           AND X_clients.obj-code = X_dis-card.cli-code NO-ERROR.
  END.
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-car-brand f-access-key f-car-reg-number rs-ef-format
          f-init-date-time f-issued-by-name f-init-operator-name l-ef-format
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit b-card b-cli b-initialize B-Help f-car-brand
         f-access-key f-car-reg-number rs-ef-format f-init-date-time
         b-add-limits b-del-limits br-ef1 l-ef-format
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-ef1 FOR EACH temp-ef1 BY temp-ef1.petrol-code.
END PROCEDURE.
PROCEDURE generate-access-key :
DEFINE output PARAMETER p-access-key AS CHARACTER NO-UNDO.
SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pencrypt in g#library2
  (input  p-d-card
  ,output p-access-key
  )  .
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-h as handle no-undo.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_temp-ef for temp-ef.
find first buf_Dis-card no-lock where
          buf_Dis-card.d-card = p-d-card no-error.
run fill-main-table in this-procedure ( input p-d-card, buffer buf_dis-card) no-error.
if error-status:error then do:
  undo, return error .
end.
find first buf_temp-ef.
assign
f-car-reg-number = buf_temp-ef.car-reg-number
f-car-brand = buf_temp-ef.car-brand
rs-ef-format = buf_temp-ef.ef-format
f-access-key = buf_temp-ef.access-key
v-petrol-code[1]= buf_temp-ef.petrol-code-1
v-petrol-code[2]= buf_temp-ef.petrol-code-2
v-petrol-code[3]= buf_temp-ef.petrol-code-3
v-petrol-code[4]= buf_temp-ef.petrol-code-4
f-init-date-time =  buf_temp-ef.init-date-time
f-init-operator-name = usrfulnf(buf_temp-ef.init-operator)
f-issued-by-name = usrfulnf(buf_temp-ef.issued-by)
.
IF f-access-key = ""
OR trim(f-access-key, "*") = ""
   THEN DO:
 RUN  generate-access-key IN THIS-PROCEDURE ( OUTPUT f-access-key) NO-ERROR.
 IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE
     "Ошибка при генерации кода доступа"
     VIEW-AS ALERT-BOX ERROR.
     RUN undo-proc IN THIS-PROCEDURE .
     UNDO, RETURN ERROR.
 END.
END.
ASSIGN
v-h = br-ef1:FIRST-COLUMN IN FRAME Dialog-Frame
.
DO while valid-handle(v-h) :
  if v-h:LABEL = "Название!топлива" then do:
    v-h:RESIZABLE = YES.
    leave.
  end.
  ELSE DO:
    v-h = v-h:NEXT-COLUMN.
  END.
END.
IF p-mode = 'ДОБАВЛЕНИЕ':U THEN DO:
END.
DISPLAY
f-car-brand
f-car-reg-number
rs-ef-format
l-ef-format
f-access-key
f-init-date-time
f-init-operator-name
f-issued-by-name
WITH FRAME Dialog-Frame.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    ASSIGN
    temp-ef1.petrol-num:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.month-limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.day-limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.unlim-common-limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.unlim-month-limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.unlim-day-limit:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.standard-dose:READ-ONLY in BROWSE br-ef1 = YES
    temp-ef1.common-limit:READ-ONLY in BROWSE br-ef1 = YES
    .
END.
if p-dtm-code = 24 then do:
  temp-ef1.petrol-num:READ-ONLY in BROWSE br-ef1 = YES.
end.
ENABLE
B-exit WHEN p-mode <> 'ПРОСМОТР':U
b-quit
B-Help
f-car-reg-number WHEN (p-mode <> 'ПРОСМОТР':U and p-dtm-code = 25)
f-car-brand WHEN (p-mode <> 'ПРОСМОТР':U and p-dtm-code = 25)
b-add-limits WHEN p-mode <> 'ПРОСМОТР':U
b-del-limits WHEN p-mode <> 'ПРОСМОТР':U
br-ef1
b-initialize WHEN (v-init-mode and p-dtm-code = 25)
b-card WHEN AVAILABLE X_dis-card
b-cli WHEN AVAILABLE X_dis-card
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
IF p-mode = 'ПРОСМОТР':U  THEN DO:
  ASSIGN
  b-quit:LABEL = "&Выход"
  b-quit:COLUMN = 1
  .
  HIDE
  b-exit
  IN FRAME Dialog-Frame.
END.
CASE rs-ef-format:
  WHEN 1  THEN DO:
     OPEN QUERY br-ef1 FOR EACH temp-ef1 BY temp-ef1.petrol-code.
    define buffer buf_temp-ef1 for temp-ef1 .
    if p-dtm-code = 24 then do:
      find first buf_temp-ef1 where
                buf_temp-ef1.d-card = p-d-card
            and buf_temp-ef1.dt-code = p-dt-code.
      reposition br-ef1 to recid recid(buf_temp-ef1) no-error.
      apply "ENTRY" to br-ef1.
      case p-node-code:
        when 1 then do:
          apply "ENTRY" to temp-ef1.month-limit in browse br-ef1.
        end.
        when 2 then do:
          apply "ENTRY" to temp-ef1.day-limit in browse br-ef1.
        end.
        when 3 then do:
          apply "ENTRY" to temp-ef1.standard-dose in browse br-ef1.
        end.
        when 4 then do:
          apply "ENTRY" to temp-ef1.common-limit in browse br-ef1.
        end.
        otherwise do:
          apply "ENTRY" to br-ef1.
        end.
      end case.
    end.
    apply "value-changed" to temp-ef1.unlim-day-limit in browse br-ef1.
    apply "value-changed" to temp-ef1.unlim-month-limit in browse br-ef1.
    apply "value-changed" to temp-ef1.unlim-common-limit in browse br-ef1.
  END.
END CASE.
ASSIGN
FRAME Dialog-Frame:TITLE = SUBSTITUTE("&1 для &2 ",  FRAME Dialog-Frame:TITLE, p-d-card).
END PROCEDURE.
PROCEDURE proc-save :
DEFINE BUFFER buf_prop-map FOR ub.prop-map.
DEFINE BUFFER bufl_prop-head FOR ub.prop-head.
DEFINE BUFFER buf_temp-ef1 FOR temp-ef1.
DEFINE BUFFER buf_temp-dis-card-property FOR temp-dis-card-property.
if p-dtm-code = 25 then do:
  ASSIGN
  FRAME Dialog-Frame
  f-car-brand
  f-car-reg-number
  rs-ef-format
  .
end.
FOR EACH buf_temp-ef1:
  FOR FIRST bufl_prop-head no-lock WHERE
            bufl_prop-head.dtm-code = 24,
        EACH buf_prop-map NO-LOCK WHERE
            buf_prop-map.dtm-code = bufl_prop-head.dtm-code
         and buf_prop-map.node-code > 0:
   IF buf_temp-ef1.month-limit = 0
   OR buf_temp-ef1.day-limit = 0
   OR buf_temp-ef1.standard-dose = 0
   or buf_temp-ef1.common-limit = 0
   THEN DO:
     MESSAGE
     substitute("Не заполнены лимиты для топлива с кодом &1", buf_temp-ef1.petrol-code)
     VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN ERROR.
   END.
   if buf_temp-ef1.petrol-num > 0 then do:
     if get-ef-petrol-code(buf_temp-ef1.petrol-code) = 0 then do:
      MESSAGE
      substitute("Неопределен код топлива EASYFUEL для кода топлива IBS TH &1", buf_temp-ef1.petrol-code)
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
     end.
   end.
  end.
end.
FOR EACH buf_temp-ef1:
    FOR FIRST bufl_prop-head no-lock WHERE
            bufl_prop-head.dtm-code = 24,
        EACH buf_prop-map NO-LOCK WHERE
            buf_prop-map.dtm-code = bufl_prop-head.dtm-code
         and buf_prop-map.node-code > 0:
   FIND FIRST buf_temp-dis-card-property WHERE
            buf_temp-dis-card-property.d-card =  p-d-card
       AND buf_temp-dis-card-property.dt-code = buf_temp-ef1.dt-code
       AND buf_temp-dis-card-property.host-code = p-host-code
       AND buf_temp-dis-card-property.obj-type = p-obj-type
       AND buf_temp-dis-card-property.obj-code = p-obj-code
       AND buf_temp-dis-card-property.obj-code = p-obj-code
       AND buf_temp-dis-card-property.node-code = buf_prop-map.node-code NO-ERROR.
   IF NOT AVAILABLE buf_temp-dis-card-property THEN DO:
      CREATE buf_temp-dis-card-property.
      ASSIGN
      buf_temp-dis-card-property.d-card =  p-d-card
      buf_temp-dis-card-property.dt-code = buf_temp-ef1.dt-code
      buf_temp-dis-card-property.dtm-code = buf_temp-ef1.dtm-code
      buf_temp-dis-card-property.sum-id = buf_temp-ef1.sum-id
      buf_temp-dis-card-property.host-code = p-host-code
      buf_temp-dis-card-property.obj-type = p-obj-type
      buf_temp-dis-card-property.obj-code = p-obj-code
      buf_temp-dis-card-property.obj-code = p-obj-code
      buf_temp-dis-card-property.node-code = buf_prop-map.node-code
      buf_temp-dis-card-property.node-label = buf_prop-map.node-label
      buf_temp-dis-card-property.prop-label = bufl_prop-head.prop-label
      buf_temp-dis-card-property.data-type = entry(1, buf_prop-map.node-value-type)
      .
   END.
   IF VALID-HANDLE(BUFFER buf_temp-dis-card-property:BUFFER-FIELD(SUBSTITUTE("property-value-&1", entry(1, buf_prop-map.node-value-type))))
   AND VALID-HANDLE(BUFFER buf_temp-ef1:BUFFER-FIELD(buf_prop-map.node-name)) THEN DO:
       ASSIGN
       BUFFER buf_temp-dis-card-property:BUFFER-FIELD(SUBSTITUTE("property-value-&1", entry(1, buf_prop-map.node-value-type))):BUFFER-VALUE =
       BUFFER buf_temp-ef1:BUFFER-FIELD(buf_prop-map.node-name):BUFFER-VALUE.
   END.
   ELSE DO:
       MESSAGE
       SUBSTITUTE("Не могу сохранить поле temp-ef1.&1 в поле temp-dis-card-property.&1"
                  ,buf_prop-map.node-label)
       VIEW-AS ALERT-BOX ERROR.
       UNDO, RETURN ERROR.
   END.
    END.
END.
if p-dtm-code = 25 then do:
  FOR EACH buf_prop-map NO-LOCK WHERE
          buf_prop-map.dtm-code = p-dtm-code
      and buf_prop-map.node-code > 0:
    FIND FIRST temp-dis-card-property WHERE
              temp-dis-card-property.d-card = p-d-card
        AND   temp-dis-card-property.dt-code = p-dt-code
        AND   temp-dis-card-property.node-code = buf_prop-map.node-code
        AND   temp-dis-card-property.host-code = p-host-code
        AND   temp-dis-card-property.obj-type = p-obj-type
        AND   temp-dis-card-property.obj-code = p-obj-code NO-ERROR.
    IF NOT AVAILABLE temp-dis-card-property THEN DO:
      CREATE temp-dis-card-property.
      ASSIGN
      temp-dis-card-property.d-card = p-d-card
      temp-dis-card-property.dt-code = p-dt-code
      temp-dis-card-property.dtm-code = p-dtm-code
      temp-dis-card-property.sum-id = p-sum-id
      temp-dis-card-property.node-code = buf_prop-map.node-code
      temp-dis-card-property.host-code = p-host-code
      temp-dis-card-property.obj-type = p-obj-type
      temp-dis-card-property.obj-code = p-obj-code
      temp-dis-card-property.prop-label = buf_prop-head.prop-label
      temp-dis-card-property.node-label = buf_prop-map.node-label
      temp-dis-card-property.data-type = entry(1, buf_prop-map.node-value-type)
      .
    END.
  END.
  FOR EACH temp-dis-card-property
    where temp-dis-card-property.d-card = p-d-card
  and temp-dis-card-property.dtm-code = p-dtm-code
  and temp-dis-card-property.dt-code = p-dt-code
    :
    CASE temp-dis-card-property.node-code:
      WHEN 1 THEN DO:
        temp-dis-card-property.property-value-character = f-car-reg-number.
      END.
      WHEN 2 THEN DO:
        temp-dis-card-property.property-value-character = f-car-brand.
      END.
      WHEN 3 THEN DO:
        temp-dis-card-property.property-value-integer = rs-ef-format.
      END.
      WHEN 4 THEN DO:
        temp-dis-card-property.property-value-character = f-access-key.
      END.
      WHEN 11 THEN DO:
      END.
      WHEN 13 THEN DO:
        temp-dis-card-property.property-value-character = v-cntxt-userid.
      END.
      WHEN 5 THEN DO:
        FIND FIRST buf_temp-ef1 NO-LOCK WHERE
                      buf_temp-ef1.d-card = p-d-card
                  and buf_temp-ef1.petrol-num = 1 NO-ERROR.
        IF AVAILABLE buf_temp-ef1 THEN DO:
          temp-dis-card-property.property-value-integer = buf_temp-ef1.petrol-code.
        END.
      END.
    WHEN 6 THEN DO:
      FIND FIRST buf_temp-ef1 NO-LOCK WHERE
                    buf_temp-ef1.d-card = p-d-card
                and buf_temp-ef1.petrol-num = 2 NO-ERROR.
      IF AVAILABLE buf_temp-ef1 THEN DO:
        temp-dis-card-property.property-value-integer = buf_temp-ef1.petrol-code.
      END.
    END.
    WHEN 7 THEN DO:
      FIND FIRST buf_temp-ef1 NO-LOCK WHERE
                  buf_temp-ef1.d-card = p-d-card
               and  buf_temp-ef1.petrol-num = 3 NO-ERROR.
      IF AVAILABLE buf_temp-ef1 THEN DO:
        temp-dis-card-property.property-value-integer = buf_temp-ef1.petrol-code.
      END.
    END.
    WHEN 8 THEN DO:
      FIND FIRST buf_temp-ef1 NO-LOCK WHERE
                buf_temp-ef1.d-card = p-d-card
               and buf_temp-ef1.petrol-num = 4 NO-ERROR.
      IF AVAILABLE buf_temp-ef1 THEN DO:
        temp-dis-card-property.property-value-integer = buf_temp-ef1.petrol-code.
      END.
    END.
    END CASE.
  END.
end.
ASSIGN
p-setted = YES
.
END PROCEDURE.
PROCEDURE undo-proc :
DEFINE BUFFER buf_temp-ef1 FOR temp-ef1.
DEFINE BUFFER buf_temp-dis-card-property FOR temp-dis-card-property.
FOR EACH buf_temp-ef1 WHERE
       buf_temp-ef1.d-card = p-d-card
    and buf_temp-ef1.NEW_ = YES,
    EACH buf_temp-dis-card-property WHERE
        buf_temp-dis-card-property.dt-code = buf_temp-ef1.dt-code:
   DELETE buf_temp-dis-card-property.
END.
END PROCEDURE.
FUNCTION get-gds-name RETURNS CHARACTER
  ( INPUT p-gds-code AS INTEGER ) :
DEFINE buffer buf_goods FOR ub.goods.
FIND FIRST buf_goods NO-LOCK WHERE
            buf_goods.gds-code = p-gds-code NO-ERROR.
IF AVAILABLE buf_goods THEN do:
  IF buf_goods.chk-name <> '' THEN RETURN buf_goods.chk-name.
  RETURN buf_goods.gds-name.
END.
RETURN "!!НЕИЗВЕСТНЫЙ ТОВАР".
END FUNCTION.
