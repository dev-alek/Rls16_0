block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chksum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/chksum.p $":U .
define variable vss-description as character no-undo init "Проверить контрольные суммы файлов системы".
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
define temp-table temp-file no-undo
  field file-name      as character
  field check-sum      as character
  field is-error       as logical
  field error-message  as character
  index xpk is primary unique file-name
  index xie is-error
  .
define stream sinp .
define variable v-error-log-file-name as character no-undo initial "chksum.err":u .
define variable v-chk-sum-file      as character no-undo .
define variable v-chk-sum-signature as character no-undo .
define variable v-compile-date      as date      no-undo .
define variable v-file-finished     as logical   no-undo .
define variable v-full-path         as character no-undo .
define variable v-path              as character no-undo .
define variable v-file-name         as character no-undo .
define variable v-file-name-no-ext  as character no-undo .
define variable v-file-name-ext     as character no-undo .
define variable v-check-sum         as character no-undo .
define variable v-key   as character no-undo .
define variable v-value as character no-undo .
do
on error undo, return error return-value
:
  assign
    v-chk-sum-file = search("exe/chksum.txt")
  .
  if v-chk-sum-file = ""
  or v-chk-sum-file = ?
  then do:
    message
      "Не найден файл, содержащий информацию о контрольной сумме файлов" skip
      "Файл" "exe/chksum.txt" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  run gbl/md5.p
    (input  v-chk-sum-file
    ,output v-chk-sum-signature
    ) .
  define variable v-ok as logical   no-undo .
  message
    "Произвести проверку целостности кодов системы" skip
    "Контрольный файл" v-chk-sum-file skip
    "Версия контрольного файла" v-chk-sum-signature skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    undo, return error return-value .
  end.
  input stream sinp from value(v-chk-sum-file) .
  import stream sinp v-key v-value .
  if v-key <> 'CHECK_SUM_VERSION_1_0'
  or v-value <> 'BEGIN'
  then do:
    message
      "Файл" v-chk-sum-file skip
      "Строка 1" skip
      "Неправильная подпись файла" v-key skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  import stream sinp v-key v-value .
  if v-key <> 'COMPILE_DATE'
  then do:
    message
      "Файл" v-chk-sum-file skip
      "Строка 2" skip
      "Должна быть указана дата компиляции" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    v-compile-date = date(v-value)
  .
  assign
    v-file-finished = false
  .
  repeat
  :
    assign
      v-key   = ''
      v-value = ''
    .
    import stream sinp v-key v-value .
    run waitfram-show in this-procedure
      (input substitute("Считывание контрольной суммы файла &1", v-key)
      ) .
    if  v-key = 'CHECK_SUM_VERSION_1_0'
    and v-value = 'END'
    then do:
      assign
        v-file-finished = true
      .
    end.
    else do:
      create temp-file .
      assign
        temp-file.file-name = v-key
        temp-file.check-sum = v-value
        is-error            = false
        error-message       = ""
      .
    end.
  end.
  run waitfram-hide in this-procedure .
  input stream sinp close .
  if v-file-finished = false
  then do:
    message
      "Файл" v-chk-sum-file skip
      "Отсутствует строка завершения файла" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  check_file:
  for each temp-file
  on error undo, return error return-value
  :
    run waitfram-show in this-procedure
      (input substitute("Проверка контрольной суммы файла &1", temp-file.file-name)
      ) .
    assign
      v-check-sum = ''
    .
    run gbl/filename.p
      (input  temp-file.file-name
      ,output v-full-path
      ,output v-path
      ,output v-file-name
      ,output v-file-name-no-ext
      ,output v-file-name-ext
      ) no-error  .
    if error-status :error
    then do:
      assign
        temp-file.is-error      = true
        temp-file.error-message = "Не найден файл"
      .
      next check_file .
    end.
    if v-file-name-ext = "r"
    then do:
      assign
        rcode-info :file-name = v-full-path
        v-check-sum           = string(rcode-info :crc-value)
      .
    end.
    else do:
      run gbl/md5.p
        (input  v-full-path
        ,output v-check-sum
        ) no-error .
      if error-status :error
      then do:
        assign
          temp-file.is-error      = true
          temp-file.error-message = substitute("Ошибка при определении контрольной суммы файла"
                                              + chr(10) + "&1"
                                              + chr(10) + "&2"
                                              ,error-status :get-message(1)
                                              ,return-value
                                              )
        .
        next check_file .
      end.
    end.
    if v-check-sum <> temp-file.check-sum
    then do:
      assign
        temp-file.is-error      = true
        temp-file.error-message = substitute("Несовпадение контрольной суммы"
                                              + chr(10) + "Должна быть сумма &1"
                                              + chr(10) + "Определена сумма &2"
                                              ,temp-file.check-sum
                                              ,v-check-sum
                                              )
      .
    end.
  end.
  run waitfram-hide in this-procedure .
  find first temp-file
    where temp-file.is-error = true
    no-error .
  if available temp-file
  then do:
    output stream sinp to value(v-error-log-file-name) .
    export stream sinp "Проверка целостности кодов системы" .
    export stream sinp "Контрольный файл" v-chk-sum-file .
    export stream sinp "Версия контрольного файла" v-chk-sum-signature .
    export stream sinp "Дата компиляции" string(v-compile-date, '99/99/9999':u) .
    export stream sinp "Дата проверки целостности" string(today, '99/99/9999':u) .
    export stream sinp "Время проверки целостности" string(time, 'HH:MM:SS':u) .
    define variable v-ind as integer   no-undo .
    assign
      v-ind = 0
    .
    for each temp-file
      where temp-file.is-error = true
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      export stream sinp temp-file.file-name temp-file.error-message .
    end.
    export stream sinp "Проверка целостности кодов системы закончена" .
    output stream sinp close .
    message
      "При проверке контрольных сумм файлов обнаружены ошибки" skip
      "Ошибок" v-ind skip
      "Список ошибок выведен в файл" v-error-log-file-name skip
      view-as alert-box error .
    define variable v-user-action as character no-undo .
    define variable v-printed     as logical   no-undo .
    run gbl/prnfilen.w
      (input  "Отчёт о проверке целостности системы"
      ,input  0
      ,input  v-error-log-file-name
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
  end.
  else do:
    message
      "При проверке контрольных сумм файлов ошибок не обнаружено" skip
      view-as alert-box information  .
  end.
end.
