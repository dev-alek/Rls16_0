block-level on error undo, throw.
define input parameter p-forced as logical no-undo .
define input parameter p-read-only as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Утилита импорта конфигурации настраиваемых полей".
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
procedure check-cl-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_custom-labels for ub.custom-labels .
  do
  on error undo, return error
  :
    find first buf_custom-labels no-lock where
              buf_custom-labels.tbl-name = '':U
          and buf_custom-labels.fld-name = '':U
          and buf_custom-labels.call-type = '':U
          and buf_custom-labels.call-point = '':U  no-error.
    if (not available buf_custom-labels
    or buf_custom-labels.custom-tooltip <> "v15_1.12" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_custom-labels.custom-tooltip, "."))
      v-dopi2 = integer(entry(2, "v15_1.12", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_custom-labels.custom-tooltip, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v15_1.12", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_custom-labels.custom-tooltip, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-cl-version :
define output parameter p-cl-version as character no-undo init ?.
define buffer buf_custom-labels for ub.custom-labels .
do
on error undo, return error
:
  find first buf_custom-labels no-lock where
            buf_custom-labels.tbl-name = '':U
        and buf_custom-labels.fld-name = '':U
        and buf_custom-labels.call-type = '':U
        and buf_custom-labels.call-point = '':U  no-error.
  if available buf_custom-labels then do:
      p-cl-version = buf_custom-labels.custom-tooltip.
  end.
end.
end procedure.
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
define stream imp-stream.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table temp-tables no-undo
field tbl-name as character
field buf-handle as handle
field tbl-handle as handle
index pi is unique primary
tbl-name.
define new shared temp-table temp-command no-undo
field command-name as character
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
command-name
uniq-key-rec
index icommand
command-name
tbl-name
uniq-key-rec
.
define buffer buf_temp-tables for temp-tables.
define variable v-check as logical no-undo .
define variable v-force as logical no-undo .
define variable v-mes   as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-md5-signature as character no-undo .
define new shared temp-table tt-custom-labels no-undo like ub.custom-labels . find first buf_temp-tables where buf_temp-tables.tbl-name = "custom-labels" no-error. if not available buf_temp-tables then do:   create buf_temp-tables.   assign   buf_temp-tables.tbl-name = "custom-labels"    buf_temp-tables.buf-handle = buffer tt-custom-labels:handle    buf_temp-tables.tbl-handle = buf_temp-tables.buf-handle:table-handle   .   release buf_temp-tables. end.
define buffer buf_tt-custom-labels for tt-custom-labels.
run waitfram-show in this-procedure ("Реинициализация конфигурации настраиваемых полей").
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if ( g#db-num > 0 ) then return.
  if not p-forced then do:
    run check-cl-version in this-procedure (output v-check).
  end.
  if v-check
  or p-forced
  then do:
    if v-check
    and p-read-only then do:
      return error substitute("&1 &2 &3&4До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,chr(10)).
    end.
    run gbl/md5.p (
       input  "cmp/fixcstml.txt"
      ,output v-md5-signature
      ) .
    if v-md5-signature <> "8B651E72326B3B3DCED41CB93B3AF2D5" then do:
      message
      substitute("Несовпадение файла эталонных записей по настраиваемым полям (fixcstml.txt) с контрольным числом")
      view-as alert-box error .
      undo, return error .
    end.
    run gbl/filename.p ( input "cmp/fixcstml.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
    if error-status:error then do:
      message
      substitute("Не найден файл эталонных записей по настраиваемым полям (fixcstml.txt)")
      view-as alert-box error .
      undo, return error .
    end.
    run str/diallog.w (
          input ?
        ,input this-procedure
        ,input ('utl/upgimptt.p' + chr(4)  +
                '1' + chr(4) +
                '1' + chr(4) +
                '1' + chr(4) +
                '1')
        ,input v-full-path
        ,input yes
        ,input 'Прервать'
        ,input 'Чтение файла в память') no-error .
    if error-status:error then do:
      message
      substitute("Ошибка при чтении в память файла кофигурации настраиваемых полей (fixcstml.txt)&1&2&1&3"
                   , chr(10)
                   , error-status:get-message(1)
                   , return-value )
      view-as alert-box error .
      undo, return error .
    end.
    if v-check
    or p-forced
    then do:
      find first buf_tt-custom-labels no-lock where
                buf_tt-custom-labels.tbl-name = '':U
            and buf_tt-custom-labels.fld-name = '':U
            and buf_tt-custom-labels.call-type = '':U
            and buf_tt-custom-labels.call-point = '':U  no-error.
      if not available buf_tt-custom-labels
      or buf_tt-custom-labels.custom-tooltip <> "v15_1.12" then do:
        message
        substitute("Версии конфиг. настраив полей в r-кодах и файле конфигурации (fixcmstl.txt) НЕ СОВПАДАЮТ&1" +
                   "в r-кодах - &2&1" +
                   "в файле - &3"
                   , chr(10)
                   , "v15_1.12"
                   , buf_tt-custom-labels.custom-tooltip
                   )
        view-as alert-box error .
        undo, return error .
      end.
    end.
    run add-custom-labels in this-procedure no-error .
    if error-status:error then do:
      run waitfram-hide in this-procedure .
      assign
      v-mes = substitute("Ошибки при инициализации конфигурации настраиваемых полей:&1&2 &3"
                         , chr(10)
                         , error-status:get-message(1)
                         , return-value ).
      if p-forced then do:
        message
        v-mes
        view-as alert-box error .
      end.
      undo, return error v-mes.
    end.
  end.
  for each buf_temp-tables
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-tables.tbl-handle) then do:
      delete object buf_temp-tables.tbl-handle.
     end.
  end.
end.
run waitfram-hide in this-procedure .
procedure add-custom-labels :
define variable v-cmp as logical no-undo .
define variable v-error as logical no-undo .
define buffer buf_tt-custom-labels for tt-custom-labels.
define buffer buf2_tt-custom-labels for tt-custom-labels.
define buffer buf_custom-labels for ub.custom-labels.
define buffer buf2_custom-labels for ub.custom-labels.
main-block:
do
on error undo, return error
:
  _for:
  for each buf_tt-custom-labels
  where buf_tt-custom-labels.language > '':U
  break
  by buf_tt-custom-labels.language
  by buf_tt-custom-labels.call-type
  by buf_tt-custom-labels.call-point
  on error  undo _for, retry _for
  on stop   undo _for, retry _for
  on endkey undo _for, retry _for
  :
    if retry then do:
      v-error = yes.
      leave _for.
    end.
    if first-of(buf_tt-custom-labels.call-point) then do:
      for each buf2_tt-custom-labels where
              buf2_tt-custom-labels.language = buf_tt-custom-labels.language
          and buf2_tt-custom-labels.call-type = buf_tt-custom-labels.call-type
          and buf2_tt-custom-labels.call-point = buf_tt-custom-labels.call-point
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        find first buf_custom-labels exclusive-lock where
                  buf_custom-labels.language = buf2_tt-custom-labels.language
              and buf_custom-labels.call-type = buf2_tt-custom-labels.call-type
              and buf_custom-labels.call-point = buf2_tt-custom-labels.call-point
              and buf_custom-labels.tbl-name = buf2_tt-custom-labels.tbl-name
              and buf_custom-labels.fld-name = buf2_tt-custom-labels.fld-name no-error.
        v-cmp = yes.
        if not available buf_custom-labels then do:
          create buf_custom-labels.
          v-cmp = no.
        end.
        else do:
          buffer-compare
          buf_custom-labels to buf2_tt-custom-labels
          case-sensitive
          save result in v-cmp.
        end.
        if not v-cmp then do:
          buffer-copy buf2_tt-custom-labels to buf_custom-labels.
        end.
      end.
    end.
  end.
  if not v-error  then do:
    _for2:
    for each buf_custom-labels no-lock
    on error  undo _for2, retry _for2
    on stop   undo _for2, retry _for2
    on endkey undo _for2, retry _for2
    :
      if retry then do:
        v-error = yes.
        leave _for2.
      end.
      find first buf2_tt-custom-labels where
                buf2_tt-custom-labels.language = buf_custom-labels.language
            and buf2_tt-custom-labels.call-type = buf_custom-labels.call-type
            and buf2_tt-custom-labels.call-point = buf_custom-labels.call-point
            and buf2_tt-custom-labels.tbl-name = buf_custom-labels.tbl-name
            and buf2_tt-custom-labels.fld-name = buf_custom-labels.fld-name no-error.
      if not available buf2_tt-custom-labels then do:
        find first buf2_custom-labels exclusive-lock where
                  recid(buf2_custom-labels) = recid(buf_custom-labels).
        delete buf2_custom-labels.
      end.
    end.
  end.
  if not v-error then do:
    find first buf_tt-custom-labels where
              buf_tt-custom-labels.language = '':U
          and buf_tt-custom-labels.call-type = '':U
          and buf_tt-custom-labels.call-point = '':U
          and buf_tt-custom-labels.tbl-name = '':U
          and buf_tt-custom-labels.fld-name = '':U no-error .
    find first buf_custom-labels where
              buf_custom-labels.language = '':U
          and buf_custom-labels.call-type = '':U
          and buf_custom-labels.call-point = '':U
          and buf_custom-labels.tbl-name = '':U
          and buf_custom-labels.fld-name = '':U no-error.
    if not available buf_custom-labels then do:
      create buf_custom-labels.
    end.
    buffer-copy buf_tt-custom-labels to buf_custom-labels.
    release buf_tt-custom-labels no-error .
    if error-status:error then do:
      return error substitute("Ошибка при обновлении головной записи конфигурации настраиваемых полей &1&2&3"
                              , error-status:get-message(1)
                              , return-value ).
    end.
  end.
  else do:
     return error substitute("Ошибка при обновлении конфигурации настраиваемых полей &1&2&3"
                             , error-status:get-message(1)
                             , return-value ).
  end.
end.
end procedure.
