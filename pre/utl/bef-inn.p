block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bef-inn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/bef-inn.p $":U .
define variable vss-description as character no-undo init "Проверка И Н Н перед включением inn-uniq = 2".
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
define variable v-correct as logical no-undo .
define variable ii as integer no-undo .
define variable v-firm-code as integer no-undo .
define variable v-psn-code as integer no-undo .
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.
define buffer buf_clients for ub.clients.
define temp-table temp-inn no-undo
field inn as character
field cli-list as character
field num-rec as integer
field inn-ok-prs as logical
field inn-ok-cmp as logical
index pi is unique primary
inn
.
define stream PrnLibStream.
output stream PRnLibStream to no-inn.txt .
output stream PRnLibStream close .
output stream PRnLibStream to no-uniq.txt.
output stream PRnLibStream close .
output stream PRnLibStream to no-corr-prs.txt append.
output stream PRnLibStream close .
output stream PRnLibStream to no-corr-cmp.txt append.
output stream PRnLibStream close .
_person:
for each buf_person no-lock:
  ii = ii + 1.
  if ii modulo 20 = 0 then do:
    run waitfram-show in this-procedure ( substitute("Чтение из БД - записей &1 ...", ii )).
  end.
  if buf_person.inn = '':u then do:
    find first buf_clients no-lock where
              buf_clients.obj-type = 'чел':U
          and buf_clients.obj-code = buf_person.psn-code .
    if not (buf_clients.sup-gds
            or
            buf_clients.sup-cons
            or
            buf_clients.sup-serv) then next _person.
    output stream PRnLibStream to no-inn.txt append.
    put stream PRnLibStream unformatted
    'чел':U chr(32) buf_person.psn-code chr(32) buf_clients.obj-name skip.
    output stream PRnLibStream close.
    next  _person.
  end.
  find first temp-inn where
            temp-inn.inn = buf_person.inn no-error.
  if not available temp-inn then do:
    create temp-inn.
    assign
    temp-inn.inn = buf_person.inn
    temp-inn.cli-list = temp-inn.cli-list + (if temp-inn.cli-list = '':u then '':U else  chr(32)) + 'чел':U + string(buf_person.psn-code)
    temp-inn.num-rec = temp-inn.num-rec + 1
    .
  end.
  else do:
    assign
    temp-inn.cli-list = temp-inn.cli-list + (if temp-inn.cli-list = '':u then '':U else chr(32)) + 'чел':U + string(buf_person.psn-code)
    temp-inn.num-rec = temp-inn.num-rec + 1
    .
  end.
  release temp-inn.
end.
_firm:
for each buf_firm no-lock:
  ii = ii + 1.
  if ii modulo 20 = 0 then do:
    run waitfram-show in this-procedure ( substitute("Чтение из БД - записей &1 ...", ii )).
  end.
  if buf_firm.inn = '':u then do:
    find first buf_clients no-lock where
              buf_clients.obj-type = 'орг':U
          and buf_clients.obj-code = buf_firm.firm-code .
    if not (buf_clients.sup-gds
            or
            buf_clients.sup-cons
            or
            buf_clients.sup-serv) then next _firm.
    output stream PRnLibStream to no-inn.txt append.
    put stream PRnLibStream unformatted
    'орг':U chr(32) buf_firm.firm-code chr(32) buf_clients.obj-name skip.
    output stream PRnLibStream close.
    next  _firm.
  end.
  find first temp-inn where
            temp-inn.inn = buf_firm.inn no-error.
  if not available temp-inn then do:
    create temp-inn.
    assign
    temp-inn.inn = buf_firm.inn
    temp-inn.cli-list = temp-inn.cli-list + (if temp-inn.cli-list = '':u then '':U else chr(32)) + 'орг':U + string(buf_firm.firm-code)
    temp-inn.num-rec = temp-inn.num-rec + 1
    .
  end.
  else do:
    assign
    temp-inn.cli-list = temp-inn.cli-list + (if temp-inn.cli-list = '':u then '':U else chr(32)) + 'орг':U + string(buf_firm.firm-code)
    temp-inn.num-rec = temp-inn.num-rec + 1
    .
  end.
  release temp-inn.
end.
ii = 0.
for each temp-inn:
  ii = ii + 1.
  if ii modulo 20 = 0 then do:
    run waitfram-show in this-procedure ( substitute("Проверка - записей &1...", ii )).
  end.
  if temp-inn.num-rec > 1 then do:
    output stream PRnLibStream to no-uniq.txt append.
    put stream PRnLibStream unformatted
    temp-inn.inn skip
    temp-inn.cli-list skip(2).
    output stream PRnLibStream close.
  end.
  if temp-inn.num-rec = 1 then do:
    if index(temp-inn.cli-list, 'орг':U) > 0 then do:
      assign
      v-firm-code = integer(replace(temp-inn.cli-list, 'орг':U, '':U)).
      find first buf_firm no-lock where buf_firm.firm-code = v-firm-code.
      temp-inn.inn-ok-prs = yes.
      run gbl/keyinn.p (
                    input  temp-inn.inn
                    ,input  'орг':U
                    ,input  buf_firm.firm-code
                    ,input  buf_firm.is-pboul
                    ,output v-correct ) no-error.
      if error-status:error
      or not v-correct then do:
        temp-inn.inn-ok-cmp = v-correct.
      end.
    end.
    if index(temp-inn.cli-list, 'чел':U) > 0 then do:
      assign
      v-psn-code = integer(replace(temp-inn.cli-list, 'чел':U, '':U)).
      find first buf_person no-lock where buf_person.psn-code = v-psn-code.
      temp-inn.inn-ok-cmp = yes.
      run gbl/keyinn.p (
                    input  temp-inn.inn
                    ,input  'чел':U
                    ,input  buf_person.psn-code
                    ,input  buf_person.is-pboul
                    ,output v-correct ) no-error.
      if error-status:error
      or not v-correct then do:
        temp-inn.inn-ok-prs = v-correct.
      end.
    end.
    if not temp-inn.inn-ok-prs then do:
      output stream PRnLibStream to no-corr-prs.txt append.
      put stream PRnLibStream unformatted
      temp-inn.inn skip
      temp-inn.cli-list skip(2).
      output stream PRnLibStream close.
    end.
    if not temp-inn.inn-ok-cmp then do:
      output stream PRnLibStream to no-corr-cmp.txt append.
      put stream PRnLibStream unformatted
      temp-inn.inn skip
      temp-inn.cli-list skip(2).
      output stream PRnLibStream  close.
    end.
  end.
end.
message
"Результаты ищите в файлах" skip(0)
"no-inn.txt - клиенты-поставщики без ИНН" skip(0)
"no-uniq.txt - клиенты с нарушением уникальности ИНН" skip(0)
"no-corr-prs.txt - физлица с неверным ИНН" skip(0)
"no-corr-cmp.txt - организации с неверным ИНН" skip(0)
view-as alert-box .
