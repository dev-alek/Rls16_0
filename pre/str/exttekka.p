block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exttekka.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/exttekka.p $":U .
define variable vss-description as character no-undo init "Вывод на кассу МАРИЯ".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alienini-getkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define output parameter o-value as char.
define variable EntryPointer as integer no-undo.
define variable mem1 as memptr no-undo.
define variable mem2 as memptr no-undo.
define variable mem1size as integer no-undo.
define variable mem2size as integer no-undo.
define variable ii       as integer    no-undo.
define variable cbReturnSize  as integer    no-undo.
assign
set-size(mem1)  = 4000
mem1size = 4000.
if i-key = "" then EntryPointer = 0.
else do:
  assign
  set-size(mem2) = 128
  mem2size = 128
  EntryPointer = get-pointer-value(mem2)
  put-string(mem2, 1) = i-key.
end.
run getprivateprofilestringA
                              (i-section,
                               EntryPointer,
                               "",
                               get-pointer-value(mem1),
                               input mem1size,
                               i-filename,
                               output cbReturnSize).
do ii = 1 to cbReturnSize:
  o-value = if (get-byte(mem1, ii) = 0 and ii ne cbReturnSize)
               then o-value + ","
               else o-value + chr(get-byte(mem1, ii)).
end.
  set-size(mem1) = 0.
  set-size(mem2) = 0.
end procedure.
procedure alienini-putkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define input parameter i-value as char.
define variable cbReturnSize as integer.
run writeprivateprofilestringA
                               (i-section,
                                i-key,
                                i-value,
                                i-filename,
                                output cbReturnSize ).
end procedure.
PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS LONG.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG.
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS LONG.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS LONG.
END PROCEDURE.
PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS LONG.
END PROCEDURE.
define  temp-table temp-tekka-tsk no-undo
field filename      as character
field obj-num       as integer
field obj-name      as character
field num-records   as integer
field max-records   as integer
field min-plu       as integer
field max-plu       as integer
field num-fields    as integer
field task-num      as character
field by-record     as logical
field send-get      as character
field cash-num      as integer
field cash-num-char as character
field port-num      as character
field way           as character
field is-script     as logical
field pswd          as character
field waiting-sek   as integer
field other-info    as character
field order-num     as integer
field secondary     as integer
field shift-fields  as integer
field binary        as logical
field range         as integer
index pi is unique primary
filename
range
index lpi
filename
min-plu
index gpi
filename
max-plu
index iorder
order-num
.
define  temp-table temp-tekka-schema no-undo
field obj-num as integer
field obj-name as character
field field-num as integer
field field-name as character
field num-records as integer
field size_ as integer
field host as character
field progress-type as character
field custom-type as character
field start-pos as integer
field end-pos as integer
field bin-group as character
index pi is unique primary
host obj-num field-num
.
define temp-table temp-tekka-record no-undo
field obj-num as integer
field plu as integer
field body as character
field shift as integer
index pi is unique primary obj-num plu.
FUNCTION tekka-is-closed-shift-journal returns integer ( input p-journal-num as integer ):
define variable v-is-closed-shift-journal as integer no-undo .
assign
v-is-closed-shift-journal = (if lookup( string( p-journal-num), '30,31,32,33':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '43':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '17':U) > 0 then 1 else 0)
.
return v-is-closed-shift-journal.
END FUNCTION.
FUNCTION tekka-is-first-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-first-journal as logical no-undo .
assign
v-is-first-journal = (p-journal-num =  integer(entry(1, '30,31,32,33':U)))
                  or (p-journal-num = integer(entry(1, '26,27,28,29':U)))
                  or (p-journal-num =  integer(entry(1, '17':U)))
                  or (p-journal-num = integer(entry(1, '16':U)))
.
return v-is-first-journal.
END FUNCTION.
FUNCTION tekka-is-petrol-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-petrol-journal as logical no-undo .
assign
v-is-petrol-journal = lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0.
return v-is-petrol-journal.
END FUNCTION.
FUNCTION tekka-get-max-journal-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489
                    else 2340).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-get-max-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489 * num-entries('30,31,32,33':U)
                    else 2340 * num-entries('17':U)).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-num-recs returns integer( input p-journal-num as integer
                                        ,input p-rec-no as integer):
define variable v-num-recs as integer no-undo .
if tekka-is-petrol-journal (p-journal-num) then do:
  if tekka-is-closed-shift-journal(p-journal-num) = 1 then do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '30,31,32,33':U))) * 1489 + p-rec-no
    .
  end.
  else do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '26,27,28,29':U)) ) * 1489 + p-rec-no
    .
  end.
end.
else do:
  if lookup(string(p-journal-num), '16,17':U) > 0 then do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '17':U))) * 2340 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '16':U)) ) * 2340 + p-rec-no
      .
    end.
  end.
  else do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '43':U))) * 2978 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '42':U)) ) * 2978 + p-rec-no
      .
    end.
  end.
end.
return v-num-recs.
END FUNCTION.
FUNCTION tekka-get-obj-num returns integer( input p-num-recs as decimal
                                           ,input p-is-petrol as logical
                                           ,input p-is-current as logical
                                           ,output p-rec-no as decimal
                                           ):
define variable v-obj-num0 as integer no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-num2 as integer no-undo .
define variable p-num-recs2 as integer no-undo .
define variable p-rec-no2 as integer no-undo .
if p-is-petrol then do:
  assign
  v-obj-num0 = trunc(p-num-recs / 1489, 0)
  .
  if p-is-current and num-entries('26,27,28,29':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '26,27,28,29':U))
  p-rec-no = p-num-recs modulo 1489
  .
  if not p-is-current and num-entries('30,31,32,33':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '30,31,32,33':U))
  p-rec-no = p-num-recs modulo 1489
  .
end.
else do:
  assign
  p-num-recs2 = (p-num-recs - trunc(p-num-recs, 0)) * 10000
  p-num-recs = trunc(p-num-recs, 0)
  v-obj-num0 = trunc(p-num-recs / 2340, 0)
  v-obj-num2 = trunc(p-num-recs2 / 2978, 0)
  .
  if p-is-current and num-entries('16':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '16':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if not p-is-current and num-entries('17':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '17':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if p-is-current and num-entries('42':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '42':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  if not p-is-current and num-entries('43':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '43':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  assign
  p-rec-no = p-rec-no + p-rec-no2 / 10000
  .
end.
if v-obj-num = 0 then v-obj-num = 100.
return v-obj-num.
END FUNCTION.
FUNCTION tekka-get-next-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '17':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
   if p-is-ptrl then
   return integer(entry(1, '26,27,28,29':U)).
   if not p-is-ptrl then
   return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
FUNCTION tekka-get-next-current-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical ):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '26,27,28,29':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
  if p-is-ptrl then
  return integer(entry(1, '26,27,28,29':U)).
  if not p-is-ptrl then
  return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
procedure tekkatsk-verify-schema :
define input parameter p-obj-list as character no-undo .
define input parameter p-dir-path as character no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-name as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-size_ as integer no-undo .
define variable v-value as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable ii-ibs as integer no-undo .
define variable ii-tekka as integer no-undo .
define variable v-result as character no-undo .
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer buf2_temp-tekka-schema for temp-tekka-schema.
  do
  on error undo, return error
  :
     for each buf_temp-tekka-schema:
       delete buf_temp-tekka-schema.
     end.
     input from value('tekkasch.d').
     repeat :
       create buf_temp-tekka-schema.
       import buf_temp-tekka-schema.
       assign
       buf_temp-tekka-schema.host = 'IBS'
       ii = ii + 1.
       .
     end.
     input close.
     ii-ibs = ii.
      _ii:
      do ii = 1 to 256:
        if p-obj-list = "ALL"
        or lookup(string(ii), p-obj-list) > 0 then do:
          assign
          v-obj-num = 0
          v-obj-name = ''
          v-num-records = 0
          v-size_ = 0
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'oname'
                                                  ,output v-value) no-error .
          if v-value = ? then next _ii.
          assign
          v-obj-num = ii
          v-obj-name = v-value
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'size'
                                                  ,output v-value) no-error .
          assign
          v-num-records = integer(v-value) no-error  .
          if error-status:error
          or v-num-records = 0 then next _ii.
          run alienini-getkey in this-procedure (
                                                   input  (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input 'obj' + string(ii, '999')
                                                  ,input 'f000'
                                                  ,output v-value) no-error .
          assign
          v-size_ = integer(v-value) no-error  .
          if error-status:error
          or v-size_ = 0 then next _ii.
          _jj:
          do jj = 1 to 256:
            run alienini-getkey in this-procedure (
                                                     input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999')
                                                    ,input 'f' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value = ? then next _ii.
            create buf_temp-tekka-schema.
            assign
            buf_temp-tekka-schema.host = 'tekka'
            buf_temp-tekka-schema.obj-num = v-obj-num
            buf_temp-tekka-schema.obj-name = v-obj-name
            buf_temp-tekka-schema.num-records = v-num-records
            buf_temp-tekka-schema.size_ = v-size_
            buf_temp-tekka-schema.field-num = jj
            buf_temp-tekka-schema.custom-type = entry(1, entry(2, v-value, '#'), ':')
            buf_temp-tekka-schema.bin-group = (if num-entries(entry(2, v-value, '#'), ':') > 1
                                               then entry(2, entry(2, v-value, '#'), ':')
                                               else '':U)
            buf_temp-tekka-schema.start-pos = integer(entry(1, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.end-pos = integer(entry(2, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.progress-type = entry( LOOKUP(buf_temp-tekka-schema.custom-type, 'Sx,B,BF,BN,UI,UL,FL,SL,VL':U)
                                                        , 'C,I,I,I,D,D,D,D,D':U)
            no-error
            .
            if error-status:error then do:
              delete buf_temp-tekka-schema.
              next _jj.
            end.
            run alienini-getkey in this-procedure (
                                                    input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999') + 'name'
                                                    ,input 'n' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value <> ? then
            buf_temp-tekka-schema.field-name = v-value.
          end.
        end.
      end.
      ii-tekka = ii - 1.
     if p-obj-list <> 'ALL' then do:
      if ii-tekka <> ii-ibs then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS &1 объектов&1по даным OLE-сервера &2"
                                , ii-ibs
                                , ii-tekka).
      end.
     end.
     for each buf_temp-tekka-schema where
            buf_temp-tekka-schema.host = 'tekka':
       find first buf2_temp-tekka-schema where
                 buf2_temp-tekka-schema.obj-num = buf_temp-tekka-schema.obj-num
             AND buf2_temp-tekka-schema.host = 'ibs'
             AND buf2_temp-tekka-schema.field-num = buf_temp-tekka-schema.field-num no-error .
       if not available buf2_temp-tekka-schema then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS нет поля &1 для объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
       buffer-compare buf_temp-tekka-schema
       to buf2_temp-tekka-schema
       save result in v-result.
       if v-result <> '':U then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS для поля &1 объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
     end.
  end.
end procedure.
FUNCTION set-Sx returns character (input p-string as character):
return p-string.
END FUNCTION.
FUNCTION get-Sx returns character (input p-string  as character):
return p-string.
END FUNCTION.
FUNCTION set-B returns character (input p-string  as character):
return chr(integer(p-string)).
END FUNCTION.
FUNCTION get-B returns character (input p-string  as character):
return string(asc(p-string)).
END FUNCTION.
FUNCTION set-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
do ii = 1 to 8:
  put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable ii as integer no-undo .
v-dopi = asc(p-string).
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
return v-dops.
END FUNCTION.
FUNCTION set-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-grp-nums as integer no-undo .
define variable v-dopi2 as integer no-undo .
v-grp-nums = num-entries(p-bin-group).
do jj = 0 to v-grp-nums - 1:
  v-dopi2 = integer(substring(p-string, jj + 1, 3)).
  do ii = 1 to 8:
    put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
  end.
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable v-grp-nums as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
v-dopi = asc(p-string).
v-grp-nums = num-entries(p-bin-group).
do jj = 1 to v-grp-nums:
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
end.
return v-dops.
END FUNCTION.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define temp-table tt-shift-info no-undo
field is-current as logical
field is-petrol as logical
field num-recs-petrol as decimal
field num-recs-petrol-prev as decimal
field num-recs as decimal
field num-recs-prev as decimal
field jour-no as decimal
field rec-no as decimal
field z-count as integer
field chk-date as date
field info-from as character
field order as integer
field was-open as logical
field is-close as logical
field is-last-closed as logical
field tekka-date-chr as character
field tekka-time-chr as character
field shift-open-date-chr as character
field shift-open-time-chr as character
field shift-close-date-chr as character
field shift-close-time-chr as character
index pi is primary
info-from
is-petrol
z-count
chk-date
index pi2
info-from
is-petrol
z-count
is-current
index iorder
order
.
define variable ii               as integer   no-undo .
define variable jj               as integer   no-undo .
define variable tempfile-tsk     as character no-undo .
define variable loc#log          as logical   no-undo .
define variable res              as character no-undo .
define variable p-param          as character no-undo .
define variable v-dir-path       as character no-undo .
define variable v-temp-dir       as character no-undo .
define variable err-file         as character no-undo .
define variable ss               as character no-undo .
define variable v-field-value    as character no-undo .
define variable v-field-value-ibm866  as character no-undo .
define variable v-obj-list       as character no-undo .
define variable ch#TekkaApplication as com-handle no-undo .
define variable v-dopi as integer no-undo .
define variable v-error          as character no-undo .
define variable v-next-obj-num as integer no-undo .
define variable v-if-next-obj-num as integer no-undo .
define variable rv as integer no-undo .
define variable v-return-value as character no-undo .
define variable v-is-spool-request as logical no-undo .
define variable v-closed-shift-num as integer no-undo .
define variable v-closed-shift-info as character no-undo .
define variable v-date-time-info as character no-undo .
define variable v-num-recs-info as character no-undo .
define variable v-petrol-exist as logical no-undo .
define variable v-record-shift as integer no-undo .
define variable v-string as character no-undo .
define stream for-task .
define stream TekkaStream .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer sec_temp-tekka-tsk for temp-tekka-tsk.
do
on error undo, return error return-value
:
  assign
    p-param = session :parameter
  .
  if num-entries(p-param) <> 4 then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный вызов процедуры обмена информацией с ЭККА МАРИЯ в дополнительной сессии PROGRESS" skip
      "Неверное количество параметров" num-entries(p-param) skip
      "Параметры" p-param skip
      view-as alert-box error.
    run write-err in this-procedure ( input "Ошибка параметров") .
     quit .
  end.
  assign
  v-dir-path     = trim(entry(1, p-param), chr(34))
  err-file       = entry(2, p-param)
  tempfile-tsk   = entry(3, p-param)
  v-temp-dir     = trim(entry(4, p-param), chr(34))
  .
  define variable v-full-path        as character no-undo .
  define variable v-path             as character no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-file-name-no-ext as character no-undo .
  define variable v-file-name-ext    as character no-undo .
  assign
    file-info:file-name = v-temp-dir
  .
  if not (file-info:file-type <> ?
    and index( file-info:file-type, "D":U ) <> 0)
  then do:
    run Write-err in this-procedure ( input "Неизвестное имя директории обмена") .
    quit.
  end.
  run make-temp-tekka-tsk in this-procedure ( output v-obj-list) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при чтении параметров коммуникации из файла" skip
      "Файл параметров коммуникации" tempfile-tsk skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    run Write-err in this-procedure ( input "Неверные данные в файле параметров коммуникации") .
    quit.
  end.
  run waitfram-show in this-procedure ( input "Ждите! Идет обмен информацией...").
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#TekkaApplication) then
RELEASE OBJECT ch#TekkaApplication no-error.
  CREATE "AddIn.TAddIn" ch#TekkaApplication no-error.
  if error-status:error then DO:
    run  ClearTekka in this-procedure .
    run  write-err in this-procedure ( input "Ошибка при вызове OLE-сервера") .
    quit.
  End.
  res = ch#TekkaApplication:SetDataPath(v-dir-path).
  if res <> '0' then do:
    run  ClearTekka in this-procedure .
    run  write-err in this-procedure (input substitute("Неверная директория OLE-сервера &1 или другая ошибка(код ошибки &2)"
                                            , v-dir-path
                                            , res)) .
    quit.
  end.
      _tasks:
  for each temp-tekka-tsk
  break
  by temp-tekka-tsk.order-num
  by temp-tekka-tsk.range
  by temp-tekka-tsk.obj-num
  :
    if temp-tekka-tsk.filename = '':u
    and temp-tekka-tsk.send-get <> 'task':U then next.
    case temp-tekka-tsk.send-get:
      when 'send':U then do:
        if temp-tekka-tsk.by-record then do:
          v-record-shift = temp-tekka-tsk.min-plu - 1.
        end.
        else do:
          v-record-shift = 0.
        end.
        if not temp-tekka-tsk.filename begins '-' then do:
          if v-full-path <> '':U
          and last-of( temp-tekka-tsk.range)
          then do:
            OS-delete value(v-full-path).
          end.
          run gbl/filename.p (
             input  temp-tekka-tsk.filename
            ,output v-full-path
            ,output v-path
            ,output v-file-name
            ,output v-file-name-no-ext
            ,output v-file-name-ext
            ) .
          v-dopi = ch#TekkaApplication:hook().
          if not temp-tekka-tsk.by-record then do:
            res = ch#TekkaApplication:CreateObj(temp-tekka-tsk.obj-num, 0).
            if res <> '1' then do:
              run write-err in this-procedure ( input substitute("Ошибка при попытке создать объект &1 в памяти", temp-tekka-tsk.obj-num)) .
              quit.
            end.
          end.
          input stream TekkaStream from value(temp-tekka-tsk.filename) .
          repeat :
            create temp-tekka-record.
            assign
            temp-tekka-record.obj-num = temp-tekka-tsk.obj-num
            temp-tekka-record.plu = ?
            .
            import stream TekkaStream unformatted ss .
            if temp-tekka-tsk.num-fields <> num-entries(ss, chr(4) ) then do:
            end.
            ii = integer(entry(1, ss, chr(3))).
            assign
            temp-tekka-record.plu = ii
            temp-tekka-record.body = (if num-entries(ss, chr(3)) > 1
                                      then entry(2, ss, chr(3)) else '':U)
            .
          end.
          input stream TekkaStream close.
          for each buf_temp-tekka-tsk where
                  buf_temp-tekka-tsk.obj-num = temp-tekka-tsk.obj-num:
            buf_temp-tekka-tsk.filename = '-' + buf_temp-tekka-tsk.filename.
          end.
        end.
        if temp-tekka-tsk.by-record then do:
          res = ch#TekkaApplication:CreateObjN(temp-tekka-tsk.obj-num
                                        ,(temp-tekka-tsk.max-plu - temp-tekka-tsk.min-plu + 1 )
                                        ,temp-tekka-tsk.min-plu - 1 ).
          if res <> '1' then do:
            run write-err in this-procedure ( input substitute("Ошибка при попытке создать объект &1 в памяти", temp-tekka-tsk.obj-num)) .
            quit.
          end.
        end.
        if temp-tekka-tsk.binary then do:
          if temp-tekka-tsk.shift-fields <> 0 then do:
            v-dopi = ch#TekkaApplication:StartGetObj(string(temp-tekka-tsk.obj-num)
                                            ,temp-tekka-tsk.cash-num-char
                                            ,temp-tekka-tsk.port-num
                                            ,temp-tekka-tsk.way
                                            ,temp-tekka-tsk.pswd  ).
            run waiting in this-procedure ( input temp-tekka-tsk.obj-name, input temp-tekka-tsk.waiting-sek) no-error.
            if error-status:error then do:
              run write-err in this-procedure ( input error-status:get-message(1) ) .
              quit.
            end.
            if return-value <> '':u then do:
              run write-err in this-procedure ( input return-value  ) .
              quit.
            end.
              if temp-tekka-tsk.shift-fields < 0 then
              temp-tekka-tsk.shift-fields = 0.
            end.
          end.
        _record:
        for each temp-tekka-record where
                 temp-tekka-record.obj-num = temp-tekka-tsk.obj-num
             and temp-tekka-record.plu >= temp-tekka-tsk.min-plu
             and temp-tekka-record.plu <= temp-tekka-tsk.max-plu
        by
        temp-tekka-record.plu:
          if temp-tekka-record.plu = ? then do:
            delete temp-tekka-record.
            next _record.
          end.
          if temp-tekka-record.body = '':U then do:
            v-error = ch#TekkaApplication:SetFIeld(temp-tekka-record.plu , 1, '':U).
            if v-error <> '1' then do:
              run write-err in this-procedure ( input substitute("Устанавливаемое поле в объекте не существует: " +
                                                                  "очищаемое поле 1 запись &2 объект &3&4"
                                                                  , chr(10)
                                                                  , temp-tekka-record.plu
                                                                  , temp-tekka-tsk.obj-num
                                                                  , ("|" + v-error + "|")
                                                                  )
                                            ) .
              quit.
            end.
          end.
          else do:
            _jj:
            do jj = 1 to temp-tekka-tsk.num-fields:
                .
              v-field-value = entry(jj, temp-tekka-record.body, chr(4)) .
              if v-field-value = chr(63) then do:
                next _jj.
              end.
              v-error = ch#TekkaApplication:SetFIeld(temp-tekka-record.plu, jj  +  temp-tekka-tsk.shift-fields, v-field-value).
              if v-error <> '1' then do:
                run write-err in this-procedure ( input substitute("Устанавливаемое поле в объекте не существует: " +
                                                                    "поле &2 запись &3 объект &4: &5"
                                                                    , chr(10)
                                                                    , jj + temp-tekka-tsk.shift-fields
                                                                    , temp-tekka-record.plu
                                                                    , temp-tekka-tsk.obj-num
                                                                    , v-error
                                                                    )
                                              ) .
                quit.
              end.
            END.
          end.
          delete temp-tekka-record.
        end.
        if temp-tekka-tsk.by-record then do:
          res = ch#TekkaApplication:StartPutObj(temp-tekka-tsk.cash-num-char
                                          ,temp-tekka-tsk.port-num
                                          ,temp-tekka-tsk.way
                                          ,temp-tekka-tsk.pswd  ).
        end.
        else do:
          res = ch#TekkaApplication:StartPutObj(temp-tekka-tsk.cash-num-char
                                          ,temp-tekka-tsk.port-num
                                          ,temp-tekka-tsk.way
                                          ,temp-tekka-tsk.pswd  ).
        end.
        run waiting in this-procedure ( input temp-tekka-tsk.obj-name, input temp-tekka-tsk.waiting-sek) no-error.
        if error-status:error then do:
          run write-err in this-procedure ( input error-status:get-message(1) ) .
          quit.
        end.
        if return-value <> '':u then do:
          run write-err in this-procedure ( input return-value  ) .
          quit.
        end.
      end.
      when 'get':U then do:
        for each temp-tekka-record:
          delete temp-tekka-record.
        end.
        v-dopi = ch#TekkaApplication:hook().
        if not temp-tekka-tsk.by-record then do:
          ch#TekkaApplication:CreateObj(temp-tekka-tsk.obj-num, 0).
          res = ch#TekkaApplication:CreateObj(temp-tekka-tsk.obj-num, 0).
          if res <> '1' then do:
            run write-err in this-procedure ( input substitute("Ошибка при попытке создать объект &1 в памяти", temp-tekka-tsk.obj-num)) .
            quit.
          end.
        end.
        else do:
          if not v-is-spool-request
          and lookup(string(temp-tekka-tsk.obj-num), '26,27,28,29,30,31,32,33,16,17,42,43':U) > 0 then do:
            assign
            v-is-spool-request = yes
            .
            v-petrol-exist = tekka-is-petrol-journal (input temp-tekka-tsk.obj-num).
          end.
          if v-is-spool-request
          and v-next-obj-num = 0
          and tekka-is-first-journal(temp-tekka-tsk.obj-num)
          and tekka-is-closed-shift-journal(temp-tekka-tsk.obj-num) > 0 then do:
            v-next-obj-num = 0.
            v-if-next-obj-num = 0.
          end.
          if v-next-obj-num > 0
          and temp-tekka-tsk.obj-num <> v-next-obj-num then do:
            next _tasks.
          end.
          v-next-obj-num = 0.
          if v-is-spool-request = yes
          and temp-tekka-tsk.other-info <> '':U
          and tekka-is-first-journal(temp-tekka-tsk.obj-num) = yes
          then do:
            v-return-value = ''.
            run get-spool-optimize in this-procedure ( buffer temp-tekka-tsk, v-petrol-exist ) no-error .
            if not error-status:error then do:
              v-return-value = return-value.
              if v-date-time-info <> '':U then do:
                output stream TekkaStream to value(temp-tekka-tsk.filename).
                put stream TekkaStream unformatted
                temp-tekka-tsk.obj-num chr(3)
                -1 chr(3)
                "tekka-date-time=" v-date-time-info '=' temp-tekka-tsk.cash-num
                skip.
                output stream TekkaStream  close.
              end.
              do rv = 1 to num-entries(v-return-value):
                if entry(rv, v-return-value) begins 'next-object=' then do:
                  assign
                  v-next-obj-num = integer(entry(2, entry(rv, v-return-value), '=')).
                  next _tasks.
                end.
                if entry(rv, v-return-value) begins 'if-read-0-then-next-object=' then do:
                  assign
                  v-if-next-obj-num = integer(entry(2, entry(rv, v-return-value), '=')).
                end.
                if entry(rv, v-return-value) begins 'close-shift=' then do:
                  output stream TekkaStream to value(temp-tekka-tsk.filename) append.
                  put stream TekkaStream unformatted
                  temp-tekka-tsk.obj-num chr(3)
                  0 chr(3)
                  entry(rv, v-return-value)
                  (if integer(left-trim(entry(rv, v-return-value), 'close-shift=')) = v-closed-shift-num
                   then (chr(4) + v-closed-shift-info)
                   else '':U)
                  skip.
                  output stream TekkaStream  close.
                end.
                if entry(rv, v-return-value) = 'next' then do:
                  next _tasks.
                end.
                if entry(rv, v-return-value) begins "min-plu=" then do:
                  temp-tekka-tsk.min-plu = integer(entry(2, entry(rv, v-return-value), '=':U)).
                  if temp-tekka-tsk.secondary > 0 then do:
                    find first sec_temp-tekka-tsk where
                              sec_temp-tekka-tsk.obj-num = temp-tekka-tsk.secondary no-error .
                    if available sec_temp-tekka-tsk then do:
                      assign
                      sec_temp-tekka-tsk.min-plu =  10000 * (decimal(entry(2, entry(rv, v-return-value), '=':U)) -
                                                    temp-tekka-tsk.min-plu)
                      .
                    end.
                  end.
                end.
              end.
            end.
          end.
        end.
        v-dopi = ch#TekkaApplication:StartGetObj(string(temp-tekka-tsk.obj-num)
                                        ,temp-tekka-tsk.cash-num-char
                                        ,temp-tekka-tsk.port-num
                                        ,temp-tekka-tsk.way
                                        ,temp-tekka-tsk.pswd  ).
        run waiting in this-procedure ( input temp-tekka-tsk.obj-name, input temp-tekka-tsk.waiting-sek) no-error.
        if error-status:error then do:
          run write-err in this-procedure ( input error-status:get-message(1) ) .
          quit.
        end.
        if return-value <> '':u then do:
          run write-err in this-procedure ( input return-value  ) .
          quit.
        end.
        if temp-tekka-tsk.by-record then do:
          if temp-tekka-tsk.num-records = 0
          or temp-tekka-tsk.num-records = ? then  do:
            temp-tekka-tsk.num-records = ch#TekkaApplication:GetRecordsCount().
          end.
          if temp-tekka-tsk.max-plu = ? then do:
            assign
            temp-tekka-tsk.max-plu = temp-tekka-tsk.num-records.
          end.
          if temp-tekka-tsk.min-plu = ? then do:
            assign
            temp-tekka-tsk.min-plu = 0.
          end.
          if temp-tekka-tsk.num-records = 0 then do:
            if v-if-next-obj-num > 0 then do:
              assign
              v-next-obj-num = v-if-next-obj-num
              v-if-next-obj-num  = 0
              .
            end.
            v-next-obj-num = tekka-get-next-obj-num ( input temp-tekka-tsk.obj-num, input v-petrol-exist).
            NEXT _tasks.
          end.
          if temp-tekka-tsk.min-plu > temp-tekka-tsk.num-records
          and v-is-spool-request = yes
          and temp-tekka-tsk.num-records < tekka-get-max-journal-record-num  ( input temp-tekka-tsk.obj-num)
          then do:
            v-next-obj-num = tekka-get-next-obj-num ( input temp-tekka-tsk.obj-num, input v-petrol-exist).
            NEXT _tasks.
          end.
          output stream TekkaStream to value(temp-tekka-tsk.filename) append.
          if temp-tekka-tsk.num-fields = 0
          or temp-tekka-tsk.num-fields = ? then do:
            temp-tekka-tsk.num-fields = ch#TekkaApplication:GetFieldsCount().
          end.
          do ii = max(1, temp-tekka-tsk.min-plu) to minimum(temp-tekka-tsk.num-records, temp-tekka-tsk.max-plu):
            do jj = 1 to temp-tekka-tsk.num-fields:
              v-field-value = ch#TekkaApplication:GetField(ii, jj).
              if jj = 1 then
              put stream TekkaStream unformatted
              temp-tekka-tsk.obj-num chr(3)
              ii chr(3).
              put stream TekkaStream unformatted
              v-field-value chr(4) .
            end.
            put stream TekkaStream unformatted skip.
          END.
          output stream TekkaStream  close.
          if temp-tekka-tsk.num-records < tekka-get-max-journal-record-num  ( input temp-tekka-tsk.obj-num)
          and temp-tekka-tsk.secondary = 0
          then do:
            assign
            v-next-obj-num = tekka-get-next-obj-num ( input temp-tekka-tsk.obj-num, input v-petrol-exist).
          end.
        end.
        else do:
          v-error = ch#TekkaApplication:SaveXml(temp-tekka-tsk.filename).
          if v-error <> '0' then do:
            run write-err in this-procedure ( input v-error ).
            quit.
          end.
        end.
      end.
      when 'task':U then do:
        v-string = substitute("select &1 from &2 where &3"
                              ,temp-tekka-tsk.obj-name
                              ,temp-tekka-tsk.cash-num-char
                              ,temp-tekka-tsk.other-info).
        v-error = ch#TekkaApplication:AddTask( v-string).
        if v-error <> "Ошибок нет." then do:
          run write-err in this-procedure ( input v-error ).
          quit.
        end.
      end.
    END CASE.
  END.
  if v-full-path <> '':U
  then do:
    OS-delete value(v-full-path).
  end.
  run ClearTekka in this-procedure .
  PROCESS EVENTS.
  run waitfram-hide in this-procedure .
  run write-err in this-procedure ( input chr(10)) .
  quit.
  procedure ClearTekka :
    do
    on error undo, return error
    :
      run waitfram-hide in this-procedure .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if valid-handle(ch#TekkaApplication) then
RELEASE OBJECT ch#TekkaApplication no-error.
      PROCESS EVENTS.
    end.
  end procedure.
  procedure write-err :
    do
    on error undo, return error
    :
      define input parameter p-is-err as character no-undo .
      run gbl/bat-err.p (
         input err-file
        ,input (if p-is-err <> "":U then p-is-err else "")
        ).
    end.
  end.
end.
procedure make-temp-tekka-tsk :
define output parameter p-obj-list as character no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-tekka-tsk for temp-tekka-tsk .
    for each buf_temp-tekka-tsk
    on error undo, return error
    :
      delete buf_temp-tekka-tsk .
    end.
    input stream for-task from value( tempfile-tsk ) .
    repeat
    :
      create buf_temp-tekka-tsk .
      import stream for-task buf_temp-tekka-tsk .
      assign
      p-obj-list = p-obj-list + chr(44) + string(buf_temp-tekka-tsk.obj-num).
    end.
    input stream for-task close.
    OS-delete value( tempfile-tsk ).
    p-obj-list = trim(p-obj-list, chr(44)).
  end.
end procedure.
procedure waiting :
define input parameter p-mess as character no-undo .
define input parameter p-waiting as integer no-undo .
define variable v-exec-time as integer no-undo .
define variable v-answer as character no-undo .
define variable v-start-time as int64     no-undo .
assign
v-start-time = etime
.
_do:
do while true:
  assign
  v-exec-time = (etime - v-start-time) / 1000
  .
  run waitfram-show in this-procedure ( input substitute("&1 Время ожидания &2"
                                      , p-mess
                                      , string(v-exec-time, "HH:MM:SS")))
  .
  v-answer = ch#TekkaApplication:GetStatus().
  if v-answer = 'work' then next _do.
  else leave _do.
  if v-exec-time >= p-waiting then do:
    return substitute("Превышено время ожидания: &1 ЭККА не ответила").
  end.
end.
if v-answer = 'done' then return '':U.
v-error = ch#TekkaApplication:GetError().
if v-error = "Ошибок нет." then do:
  return "Ошибок нет." .
end.
else do:
return v-error.
end.
end procedure.
procedure get-spool-optimize:
define parameter buffer buf_temp-tekka-tsk for temp-tekka-tsk.
define input parameter p-petrol-exist as logical no-undo .
define variable vvv as character no-undo .
define variable v-date as date no-undo .
define variable v-date-p as date no-undo .
define variable v-z-count as integer no-undo init 0.
define variable v-z-count-p as integer no-undo init 0.
define variable v-num-recs as decimal no-undo .
define variable v-num-recs-p as decimal no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-is-petrol-journal as logical no-undo .
define variable v-is-closed-journal as integer no-undo .
define variable ii as integer no-undo .
define variable kk as integer no-undo .
define variable v-page-len as integer no-undo .
define variable v-page-len-p as integer no-undo .
define variable v-jour-no as integer no-undo .
define variable v-jour-no-p as integer no-undo .
define variable v-line-num as decimal no-undo .
define variable v-line-num-p as decimal no-undo .
define variable v-field-z-count as integer no-undo .
define variable v-field-z-count-p as integer no-undo .
define variable v-field-date as integer no-undo .
define variable v-field-date-p as integer no-undo .
define variable v-cd-num-recs as integer no-undo .
define variable v-prev-cd-num-recs as integer no-undo .
define variable v-cd-date as date no-undo .
define variable v-cd-date-chr as character no-undo .
define variable v-dopi as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-year as integer no-undo .
define variable v-cd-z-count-orig as integer no-undo .
define variable v-cd-z-count as integer no-undo .
define variable v-cd-z-close as logical no-undo .
define variable v-prev-cd-z-count-orig as integer no-undo .
define variable v-prev-cd-z-count as integer no-undo .
define variable v-prev-cd-z-close as logical no-undo .
define variable v-obj-num as integer no-undo .
define variable v-to-read-obj-num as integer no-undo .
define variable v-to-read-num-recs as decimal no-undo .
define variable v-return-value as character no-undo .
define variable v-get-closed-shift-info as logical no-undo .
define buffer buf_tt-shift-info for tt-shift-info.
define buffer bufm_tt-shift-info for tt-shift-info.
  do
  on error undo, return error return-value
  :
    if p-petrol-exist then do:
      assign
      v-is-petrol-journal = tekka-is-petrol-journal(buf_temp-tekka-tsk.obj-num)
      .
      assign
      v-is-closed-journal = tekka-is-closed-shift-journal(buf_temp-tekka-tsk.obj-num)
      .
      assign
      v-date-p =  date( integer(entry(2, entry(4, buf_temp-tekka-tsk.other-info, chr(32)), '-':U))
                    ,integer(entry(3, entry(4, buf_temp-tekka-tsk.other-info, chr(32)), '-':U))
                    ,integer(entry(1, entry(4, buf_temp-tekka-tsk.other-info, chr(32)), '-':U))
                    )
      v-z-count-p = integer(entry(5, buf_temp-tekka-tsk.other-info, chr(32) ))
      v-z-count-p = (if v-z-count-p = ? then 0 else v-z-count-p)
      v-num-recs-p = integer(entry(6, buf_temp-tekka-tsk.other-info, chr(32) ))
      v-num-recs-p = (if v-num-recs-p = ? then 0 else v-num-recs-p)
      .
    end.
    assign
    v-date =  date( integer(entry(2, entry(1, buf_temp-tekka-tsk.other-info, chr(32)), '-':U))
                  ,integer(entry(3, entry(1, buf_temp-tekka-tsk.other-info, chr(32)), '-':U))
                  ,integer(entry(1, entry(1, buf_temp-tekka-tsk.other-info, chr(32)), '-':U))
                  )
    v-z-count = integer(entry(2, buf_temp-tekka-tsk.other-info, chr(32) ))
    v-z-count = (if v-z-count = ? then 0 else v-z-count)
    v-num-recs = decimal(entry(3, buf_temp-tekka-tsk.other-info, chr(32) ))
    v-num-recs = (if v-num-recs = ? then 0 else v-num-recs)
    no-error .
    if error-status:error then return .
    if p-petrol-exist then do:
      assign
      v-page-len-p = 1489
      v-jour-no-p = truncate (v-num-recs-p / 1489, 0)
      v-line-num-p = v-num-recs-p MODULO 1489
      v-field-z-count-p = 5
      v-field-date-p  =  8
      .
    end.
    assign
    v-page-len = 2978
    v-jour-no = truncate (v-num-recs / 2340, 0)
    v-line-num = v-num-recs MODULO 2340
    v-field-z-count = 1
    v-field-date  = (6 + 0)
    .
    do ii = 1 to  (IF p-PETROL-exist THEN 2 ELSE 1):
      find first buf_tt-shift-info where
                buf_tt-shift-info.info-from = 'IBS'
            and buf_tt-shift-info.is-petrol = (if ii = 1 and p-petrol-exist then yes else no)
            and buf_tt-shift-info.chk-date = (if ii = 1 and p-petrol-exist then v-date-p else v-date)
            and buf_tt-shift-info.z-count = (if ii = 1 and p-petrol-exist then v-z-count-p else v-z-count)  no-error.
      if not available buf_tt-shift-info then do:
        create buf_tt-shift-info.
        assign
        buf_tt-shift-info.info-from = 'IBS'
        buf_tt-shift-info.is-petrol = (if ii = 1 and p-petrol-exist then yes else no)
        buf_tt-shift-info.chk-date = (if buf_tt-shift-info.is-petrol
                                      then v-date-p
                                      else v-date)
        buf_tt-shift-info.num-recs = (if buf_tt-shift-info.is-petrol
                                      then v-num-recs-p
                                      else v-num-recs)
        buf_tt-shift-info.z-count = (if buf_tt-shift-info.is-petrol
                                     then v-z-count-p
                                     else v-z-count)
        buf_tt-shift-info.jour-no = (if buf_tt-shift-info.is-petrol
                                     then v-jour-no-p
                                     else v-jour-no)
        buf_tt-shift-info.rec-no = (if buf_tt-shift-info.is-petrol
                                    then v-line-num-p
                                    else v-line-num)
        buf_tt-shift-info.order = ii
        buf_tt-shift-info.is-current = ?
        buf_tt-shift-info.is-close = ?
        .
      end.
    end.
    v-dopi = ch#TekkaApplication:StartGetObj(string(0)
                                    ,buf_temp-tekka-tsk.cash-num-char
                                    ,buf_temp-tekka-tsk.port-num
                                    ,buf_temp-tekka-tsk.way
                                    ,buf_temp-tekka-tsk.pswd  ).
    run waiting in this-procedure ( input buf_temp-tekka-tsk.obj-name, input buf_temp-tekka-tsk.waiting-sek) no-error.
    if error-status:error then do:
      run write-err in this-procedure ( input error-status:get-message(1) ) .
      quit.
    end.
    if return-value <> '':u then do:
      run write-err in this-procedure ( input return-value  ) .
      quit.
    end.
    vvv = ch#TekkaApplication:GetInfo().
    v-error = ch#TekkaApplication:GetError().
    if v-error <> "Ошибок нет." then do:
      run write-err in this-procedure ( input v-error).
      quit.
    end.
    assign
    v-prev-cd-z-count = integer(entry(1, vvv, chr(32) ))
    v-prev-cd-z-close = (integer(entry(3, vvv, chr(32) )) = 1)
    v-cd-z-count = integer(entry(2, vvv, chr(32) ))
    v-cd-z-close = (integer(entry(4, vvv, chr(32) )) = 1)
    no-error .
    if error-status:error then do:
      run write-err in this-procedure ( input substitute("Получены неверные данные о состоянии смен на кассе &1", buf_temp-tekka-tsk.cash-num)).
      quit.
    end.
    assign
    v-prev-cd-z-count-orig = v-prev-cd-z-count
    v-prev-cd-z-count = (if v-prev-cd-z-count = 0 then 100 else v-prev-cd-z-count)
    v-cd-z-count-orig = v-cd-z-count
    v-cd-z-count  = (if v-cd-z-count = 0 then 100 else v-cd-z-count)
    .
    assign
    v-closed-shift-num =  v-prev-cd-z-count
    .
    do ii = 1 to (if p-petrol-exist then 2 else 1):
      if v-prev-cd-z-count-orig > 0 then do:
        find first bufm_tt-shift-info where
                  bufm_tt-shift-info.info-from = 'maria'
              and bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
              and bufm_tt-shift-info.is-current = no no-error.
        if available bufm_tt-shift-info then do:
          if bufm_tt-shift-info.z-count = v-prev-cd-z-count then do:
          end.
          else do:
            assign
            bufm_tt-shift-info.is-close = yes.
            create bufm_tt-shift-info.
            assign
            bufm_tt-shift-info.info-from = 'MARIA'
            bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
            bufm_tt-shift-info.is-current = no
            bufm_tt-shift-info.z-count = v-prev-cd-z-count
            bufm_tt-shift-info.is-close = yes
            bufm_tt-shift-info.was-open = yes
            .
          end.
        end.
        else do:
            create bufm_tt-shift-info.
            assign
            bufm_tt-shift-info.info-from = 'MARIA'
            bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
            bufm_tt-shift-info.is-current = no
            bufm_tt-shift-info.z-count = v-prev-cd-z-count
            bufm_tt-shift-info.is-close = yes
            bufm_tt-shift-info.was-open = yes
            .
        end.
      end.
      if v-cd-z-count-orig > 0 then do:
        find first bufm_tt-shift-info where
                  bufm_tt-shift-info.info-from = 'maria'
              and bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
              and bufm_tt-shift-info.is-current = yes no-error.
        if available bufm_tt-shift-info then  do:
          assign
          bufm_tt-shift-info.was-open = (not v-cd-z-close)
          .
          if bufm_tt-shift-info.z-count <> v-cd-z-count then do:
            assign
            bufm_tt-shift-info.is-close = yes
            bufm_tt-shift-info.was-open = yes
            .
            create bufm_tt-shift-info.
            assign
            bufm_tt-shift-info.info-from = 'MARIA'
            bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
            bufm_tt-shift-info.is-current = yes
            bufm_tt-shift-info.z-count = v-cd-z-count
            bufm_tt-shift-info.was-open = (not v-cd-z-close)
            .
          end.
        end.
        else do:
          create bufm_tt-shift-info.
          assign
          bufm_tt-shift-info.info-from = 'MARIA'
          bufm_tt-shift-info.is-petrol = (ii = 1 and p-petrol-exist)
          bufm_tt-shift-info.is-current = yes
          bufm_tt-shift-info.z-count = v-cd-z-count
          bufm_tt-shift-info.was-open = (not v-cd-z-close)
          .
        end.
      end.
    end.
    for each buf_tt-shift-info where
              buf_tt-shift-info.info-from = 'IBS'
          and buf_tt-shift-info.is-petrol = v-is-petrol-journal
    by buf_tt-shift-info.order:
      v-get-closed-shift-info = no.
      for each bufm_tt-shift-info where
            bufm_tt-shift-info.info-from = 'maria'
        and bufm_tt-shift-info.is-petrol = v-is-petrol-journal
        and bufm_tt-shift-info.z-count = buf_tt-shift-info.z-count
      by bufm_tt-shift-info.order:
        if bufm_tt-shift-info.is-close
        and bufm_tt-shift-info.z-count = v-closed-shift-num
        then do:
          if bufm_tt-shift-info.shift-open-date-chr = "" then do:
            v-get-closed-shift-info = yes.
            run get-closed-shift-info in this-procedure ( buffer buf_temp-tekka-tsk
                                                        , buffer bufm_tt-shift-info
                                                        , output v-closed-shift-info
                                                        , output v-date-time-info
                                                        , output v-num-recs-info
                                                        ) no-error .
          end.
          else do:
            v-get-closed-shift-info = yes.
            assign
            v-closed-shift-info = bufm_tt-shift-info.shift-open-date-chr + chr(4) +
                                  bufm_tt-shift-info.shift-open-time-chr + chr(4) +
                                  bufm_tt-shift-info.shift-close-date-chr + chr(4) +
                                  bufm_tt-shift-info.shift-close-time-chr
            v-date-time-info    =  bufm_tt-shift-info.tekka-date-chr + chr(4) +
                                   bufm_tt-shift-info.tekka-time-chr
            .
          end.
          assign
          v-return-value = v-return-value + chr(44) +
                          substitute("close-shift=&1", bufm_tt-shift-info.z-count).
          assign
          buf_tt-shift-info.is-current = no
          buf_tt-shift-info.is-close = yes
          .
        end.
        if bufm_tt-shift-info.is-current
        and bufm_tt-shift-info.z-count = v-cd-z-count then do:
          assign
          buf_tt-shift-info.is-current = yes
          buf_tt-shift-info.is-close = no
          .
          if v-is-closed-journal > 0
          then do:
            assign
            v-return-value = v-return-value + chr(44) + 'next-object=' +
                            string(tekka-get-next-obj-num ( input buf_temp-tekka-tsk.obj-num, input v-petrol-exist)).
            return v-return-value.
          end.
        end.
      end.
      if not v-get-closed-shift-info then do:
        run get-closed-shift-info in this-procedure ( buffer buf_temp-tekka-tsk
                                                    , buffer bufm_tt-shift-info
                                                    , output v-closed-shift-info
                                                    , output v-date-time-info
                                                    , output v-num-recs-info
                                                    ) no-error .
        assign
        v-return-value = v-return-value + chr(44) +
                        substitute("close-shift=&1", v-prev-cd-z-count).
      end.
      if buf_tt-shift-info.is-close = (v-is-closed-journal > 0) then do:
        assign
        v-num-recs = (if buf_tt-shift-info.num-recs = 0.0 then 0.0 else (buf_tt-shift-info.num-recs + 1.0001))
        v-obj-num = buf_temp-tekka-tsk.obj-num.
        assign
        v-to-read-obj-num =  tekka-get-obj-num ( input v-num-recs
                                                ,input v-is-petrol-journal
                                                ,input (v-is-closed-journal = 0)
                                                ,output v-to-read-num-recs).
        if buf_temp-tekka-tsk.obj-num <> v-to-read-obj-num then do:
          assign
          v-return-value = v-return-value + chr(44) + "next".
        end.
        assign
        v-return-value = v-return-value + chr(44) + substitute("min-plu=&1", v-to-read-num-recs).
        return v-return-value.
      end.
    end.
    return v-return-value .
  end.
END PROCEDURE.
procedure get-closed-shift-info  :
define parameter buffer buf_temp-tekka-tsk for temp-tekka-tsk.
define parameter buffer bufm_tt-shift-info  for tt-shift-info.
define output parameter p-closed-shift-info as character no-undo .
define output parameter p-date-time-info as character no-undo .
define output parameter p-num-recs-info as character no-undo .
define variable v-dopi as character no-undo .
define variable jj as integer no-undo .
define variable kk as integer no-undo .
define variable v-field-value as character no-undo .
  do
  on error undo, return error return-value
  :
    v-dopi = ch#TekkaApplication:StartGetObj (
                                     string(15)
                                    ,buf_temp-tekka-tsk.cash-num-char
                                    ,buf_temp-tekka-tsk.port-num
                                    ,buf_temp-tekka-tsk.way
                                    ,buf_temp-tekka-tsk.pswd  ).
    run waiting in this-procedure ( input buf_temp-tekka-tsk.obj-name, input buf_temp-tekka-tsk.waiting-sek) no-error.
    if error-status:error then do:
      run write-err in this-procedure ( input error-status:get-message(1) ) .
      quit.
    end.
    if return-value <> '':u then do:
      run write-err in this-procedure ( input return-value  ) .
      quit.
    end.
    if not available bufm_tt-shift-info then do:
      do jj =  3  to (3 + 4  - 1):
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-closed-shift-info = p-closed-shift-info + (if jj = 3
                                                    then '':U
                                                    else chr(4) ) + v-field-value
        .
      end.
      do jj =  1  to 2:
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-date-time-info = p-date-time-info + (if jj = 1
                                                    then '':U
                                                    else chr(4) ) + v-field-value
        .
      end.
      do jj =  8  to (8 +  - 1):
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-num-recs-info = p-num-recs-info + (if jj = 8
                                                    then '':U
                                                    else chr(4) ) + v-field-value
        .
      end.
    end.
    else do:
      kk = buffer bufm_tt-shift-info:buffer-field("shift-open-date-chr"):position.
      do jj =  3  to  (3 +  4 - 1):
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-closed-shift-info = p-closed-shift-info + (if jj = 3
                                                    then '':U
                                                    else chr(4) ) + v-field-value
        buffer bufm_tt-shift-info:buffer-field(kk + jj - 3 - 1):buffer-value = v-field-value
        .
      end.
      kk = buffer bufm_tt-shift-info:buffer-field("tekka-date-chr"):position.
      do jj =  1  to 2:
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-date-time-info = p-date-time-info + (if jj = 1
                                                    then '':U
                                                    else chr(4) ) + v-field-value
        buffer bufm_tt-shift-info:buffer-field(kk + jj - 1 - 1):buffer-value = v-field-value
        .
      end.
      kk = buffer bufm_tt-shift-info:buffer-field("num-recs-petrol"):position.
      do jj =  8  to (8 + 4 - 1):
        v-field-value = ch#TekkaApplication:GetField(1, jj).
        assign
        p-num-recs-info = p-num-recs-info + (if jj = 8
                                                    then '':U
                                                    else chr(4) ) + v-field-value
        buffer bufm_tt-shift-info:buffer-field(kk + jj - 8 - 1):buffer-value = v-field-value
        .
      end.
   end.
  end.
end procedure.
