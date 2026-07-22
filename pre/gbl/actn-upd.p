block-level on error undo, throw.
define input  parameter parparentproc       as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: 3ac8d1d44d52, 3383, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/31 09:28:12 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: actn-upd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/actn-upd.p $":U .
define variable vss-description as character no-undo init "Проверка и загрузка прав доступа".
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
procedure get-ro_get-read-only :
  define output parameter p-ro-set as logical   no-undo .
  do
  on error  undo, return error substitute( "&1(get-ro_get-read-only). &2&3&4", vss-include-info1, return-value, error-status :get-message( 1 ) )
  on stop   undo, return error substitute( "&1(get-ro_get-read-only). stop", vss-include-info1 )
  on endkey undo, return error substitute( "&1(get-ro_get-read-only). endkey", vss-include-info1 )
  :
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ub':U) ) > 0
    then do:
      assign
        p-ro-set = true
      .
    end.
    else do:
      assign
        p-ro-set = false
      .
    end.
  end.
end procedure.
define temp-table temp-action-group no-undo
  field action-group-code          as integer
  field action-group-id            as character
  field action-group-name          as character
  field action-group-description   as character
  field action-group-configuration as character
  index xpk is primary unique action-group-code
  index xie1 action-group-id
.
define temp-table temp-action-item no-undo
  field action-item-code           as integer
  field action-item-id             as character
  field action-item-context        as character
  field action-item-configuration  as character
  field action-group-code          as integer
  field action-group-id            as character
  field action-item-name           as character
  field action-item-description    as character
  field action-item-encoded        as character
  index xpk is primary unique action-item-code
  index xie1 action-item-id
.
define temp-table temp-action-item-attr no-undo
  field action-item-code           as integer
  field attr-code                  as character
  field attr-value                 as character
  index xpk is primary unique action-item-code
.
  define buffer buf_global-state             for ub.global-state .
  define buffer buf_global-state-attr        for ub.global-state-attr .
  define variable v-action-gbl               as logical no-undo .
define buffer buf_batchprocess for ub.batchprocess .
define variable v-action-head-code as integer   no-undo .
define stream sinp .
do
on error undo, return error return-value
:
  assign
    v-action-head-code = 0
  .
       FIND FIRST buf_global-state
        NO-LOCK
        .
   FIND FIRST buf_global-state-attr
        WHERE buf_global-state-attr.gls-id    = buf_global-state.gls-id
          AND buf_global-state-attr.attr-code = "action-gbl"
        NO-LOCK
        NO-error
        .
        if available (buf_global-state-attr) then v-action-gbl = logical (buf_global-state-attr.attr-value) .
  run check-action-item in this-procedure
    .
end.
procedure check-action-item :
  define variable v-action-db-control-number   as character no-undo .
  define variable v-action-file-name           as character no-undo .
  define variable v-action-file-control-number as character no-undo .
  define variable v-sys-key                    as character no-undo .
  define variable v-get-ro_read-only           as logical   no-undo .
  define buffer buf_action-head for ub.action-head .
  do
  on error undo, return error return-value
  :
    run get-action-db-control-number in this-procedure
      (output v-action-db-control-number
      ) .
    run get-action-file-name in this-procedure
      (output v-action-file-name
      ) .
    if v-action-file-name = ""
    or v-action-file-name = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден файл с описание прав" "cmp/actn.enc" skip
        "Работа системы будет продолжена, но возможно некоторые функции системы" skip
        "работать не будут" skip
        view-as alert-box error .
      return .
    end.
    run get-action-file-control-number in this-procedure
      (input  v-action-file-name
      ,output v-action-file-control-number
      ) .
    if v-action-db-control-number <> v-action-file-control-number
    then do:
      assign
        v-get-ro_read-only = false
      .
      run get-ro_get-read-only in this-procedure
        ( output v-get-ro_read-only
        ) .
      if v-get-ro_read-only = false then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
        if v-sys-key = 'ExpertekIBS':U
        then do:
          define variable v-ok as logical   no-undo .
          message
            "Описание прав изменилось" skip
            "Контрольный номер в базе данных" v-action-db-control-number skip
            "Контрольный номер в файле"       v-action-file-control-number skip
            "Путь к файлу" v-action-file-name skip
            "Загрузить в базу данных описание прав?"
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok <> true
          then do:
            return .
          end.
        end.
        do transaction
        on error undo, return error return-value
        :
          run lock-action-head in this-procedure
            (buffer buf_action-head
            ) .
          if buf_action-head.action-head-control-number = v-action-file-control-number
          then do:
                DELETE buf_batchprocess.
            return .
          end.
          run read-action-item in this-procedure
            (input v-action-file-name
            ) .
          run validate-action-item in this-procedure
            no-error .
          if  error-status :error
          then do:
            if v-sys-key = 'ExpertekIBS':U
            then do:
              assign
                v-ok = false
              .
              message
                "При проверке прав были обнаружены ошибки" skip
                "Загрузить в базу данных описание прав?"
                view-as alert-box question buttons yes-no update v-ok .
              if v-ok <> true
              then do:
                  DELETE buf_batchprocess.
                return .
              end.
            end.
            else do:
              message
                vss-workfile vss-revision vss-description skip
                "При проверке прав были обнаружены ошибки" skip
                "Права не были загружены" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
                DELETE buf_batchprocess.
              return .
            end.
          end.
          run clear-action in this-procedure .
          run write-action in this-procedure .
          run update-action-role-item in this-procedure .
          run update-user-login-action-item in this-procedure .
          assign
            buf_action-head.action-head-control-number = v-action-file-control-number
          .
          DELETE buf_batchprocess.
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip(1)
          substitute("Описание прав изменилось") skip
          substitute("До начала работы с данной БД (режим RO) необходимо произвести вход в ОСНОВНУЮ БД!!!") skip
          view-as alert-box error .
        return error .
      end.
    end.
    run waitfram-hide in this-procedure .
  end.
end procedure.
procedure get-action-db-control-number :
  define output parameter p-action-db-control-number as character no-undo .
  define buffer buf_action-head for ub.action-head .
  do
  on error undo, return error return-value
  :
    find first buf_action-head no-lock
      where buf_action-head.action-head-code = v-action-head-code
      no-error .
    if available buf_action-head
    then do:
      assign
        p-action-db-control-number = buf_action-head.action-head-control-number
      .
    end.
    else do:
      assign
        p-action-db-control-number = '':u
      .
    end.
  end.
end procedure.
procedure get-action-file-name :
  define output parameter p-action-file-name as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-action-file-name = search("cmp/actn.enc")
    .
  end.
end procedure.
procedure get-action-file-control-number :
  define input  parameter p-action-file-name           as character no-undo .
  define output parameter p-action-file-control-number as character no-undo .
  define variable v-str-encrypt        as character no-undo .
  do
  on error undo, return error return-value
  :
    SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
    input stream sinp from value(p-action-file-name) .
    import stream sinp UNFORMATTED v-str-encrypt .
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  v-str-encrypt
  ,output p-action-file-control-number
  )  .
    ASSIGN
       p-action-file-control-number = TRIM(p-action-file-control-number, '~" ')
    .
    input stream sinp close .
  end.
end procedure.
procedure lock-action-head :
  define parameter buffer buf_action-head for ub.action-head .
  do
  on error undo, return error return-value
  :
    find first buf_action-head exclusive-lock
      where buf_action-head.action-head-code = v-action-head-code
      no-error .
    if not available buf_action-head
    then do:
      create buf_action-head .
      assign
        buf_action-head.action-head-code           = v-action-head-code
        buf_action-head.action-head-name           = "Системные права"
        buf_action-head.action-head-control-number = ""
      .
    end.
    for each  buf_batchprocess
        where buf_batchprocess.bp_type     = "actn-update":U
          and buf_batchprocess.bp_status   = 'N':U
        exclusive-lock
         :
         DELETE buf_batchprocess.
    END.
    create buf_batchprocess .
    assign
       buf_batchprocess.bp_type        = "actn-update":U
       buf_batchprocess.bp_status      = 'N':U
       buf_batchprocess.batchprocess#  = next-value(s-btpr, ub)
       buf_batchprocess.bp_sysdate     = TODAY
       buf_batchprocess.bp_systime     = string( time, 'hh:mm' )
       buf_batchprocess.bp_systimeint  = TIME
    .
  end.
end procedure.
procedure read-action-item :
  define input  parameter p-action-file-name as character no-undo .
  define buffer buf_action-head            for ub.action-head .
  define buffer buf_action-item            for ub.action-item .
  define buffer buf_temp-action-group      for temp-action-group .
  define buffer buf_temp-action-item       for temp-action-item .
  define buffer buf_temp-action-item-attr  for temp-action-item-attr .
  define variable v-action-head-control-number as character no-undo .
  define variable v-tag-name                   as character no-undo .
  define variable v-action-group-code          as integer   no-undo .
  define variable v-action-group-id            as character no-undo .
  define variable v-action-group-name          as character no-undo .
  define variable v-action-group-description   as character no-undo .
  define variable v-action-group-configuration as character no-undo .
  define variable v-action-item-code           as integer   no-undo .
  define variable v-action-item-id             as character no-undo .
  define variable v-action-item-context        as character no-undo .
  define variable v-action-item-configuration  as character no-undo .
  define variable v-action-item-name           as character no-undo .
  define variable v-action-item-description    as character no-undo .
  define variable v-action-item-encoded        as character no-undo .
  define variable v-action-item-attr-value     as character no-undo .
  define variable v-str-encrypt        as character no-undo .
  define variable v-str-decrypt        as character no-undo .
  define variable v-cc    as integer      no-undo.
  do
  on error undo, return error return-value
  :
    input stream sinp from value(p-action-file-name) .
    import stream sinp UNFORMATTED v-str-encrypt .
    v-cc = v-cc + 1.
    assign
      v-action-group-code = 0
    .
    read_action_group:
    repeat
    :
      assign
        v-tag-name      = '':u
        v-str-encrypt   = '':U
      .
      import stream sinp UNFORMATTED v-str-encrypt .
      v-cc = v-cc + 1.
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  v-str-encrypt
  ,output v-tag-name
  )  .
      v-tag-name = TRIM( v-tag-name , '~" ').
      if v-tag-name = 'action-group':u
      then do:
        assign
          v-action-group-code          = v-action-group-code + 1
          v-action-group-id            = '':u
          v-action-group-name          = '':u
          v-action-group-description   = '':u
          v-action-group-configuration = '':U
          v-str-encrypt                = '':U
        .
        import stream sinp UNFORMATTED v-str-encrypt .
        v-cc = v-cc + 1.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  v-str-encrypt
  ,output v-str-decrypt
  )  .
        ASSIGN
          v-action-group-id            = TRIM(SUBSTRING(v-str-decrypt, 1  , 11), '~" ')
          v-action-group-name          = TRIM(SUBSTRING(v-str-decrypt, 12 , 25), '~" ')
          v-action-group-description   = TRIM(SUBSTRING(v-str-decrypt, 38 , 40), '~" ')
          v-action-group-configuration = TRIM(SUBSTRING(v-str-decrypt, 79 , 14), '~" ')
        .
        create buf_temp-action-group .
        assign
          buf_temp-action-group.action-group-code          = v-action-group-code
          buf_temp-action-group.action-group-id            = v-action-group-id
          buf_temp-action-group.action-group-name          = v-action-group-name
          buf_temp-action-group.action-group-description   = v-action-group-description
          buf_temp-action-group.action-group-configuration = v-action-group-configuration
        .
      end.
      if v-tag-name = 'action-item':u
      then do:
        leave read_action_group .
      end.
    end.
    assign
      v-action-item-code = 0
    .
    read_action_item:
    repeat
    :
      assign
        v-action-item-code          = v-action-item-code + 1
        v-action-item-id            = '':u
        v-action-item-context       = '':u
        v-action-item-configuration = '':u
        v-action-group-id           = '':u
        v-action-item-name          = '':u
        v-action-item-description   = '':u
        v-action-item-encoded       = '':u
        v-action-item-attr-value    = '':u
        v-str-encrypt               = '':U
      .
      if v-action-item-code modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Чтение описания прав из файла &1"
                           ,v-action-item-code
                           )
          ) .
      end.
      import stream sinp UNFORMATTED v-str-encrypt .
       v-cc = v-cc + 1.
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  v-str-encrypt
  ,output v-str-decrypt
  )  .
      IF length(v-str-decrypt) > 1 then do:
         ASSIGN
            v-action-item-id            = TRIM(SUBSTRING(v-str-decrypt, 1  ,  53), '~" ')
            v-action-item-context       = TRIM(SUBSTRING(v-str-decrypt, 54 ,   8), '~" ')
            v-action-item-configuration = TRIM(SUBSTRING(v-str-decrypt, 63 ,  28), '~" ')
            v-action-group-id           = TRIM(SUBSTRING(v-str-decrypt,  92,   9), '~" ')
            v-action-item-name          = TRIM(SUBSTRING(v-str-decrypt, 102, 130), '~" ')
            v-action-item-description   = TRIM(SUBSTRING(v-str-decrypt, 233, 233), '~" ')
            v-action-item-encoded       = TRIM(SUBSTRING(v-str-decrypt, 436,  10), '~" ')
            v-action-item-attr-value    = TRIM(SUBSTRING(v-str-decrypt, 467,  50), '~" ')
         .
      end.
      else do:
        leave read_action_item.
      end.
      assign
        v-action-item-description = replace(v-action-item-description, "~{&abbr_rubley~}", "рублей")
        v-action-item-description = replace(v-action-item-description, "~{&abbr_rublyam_allshift~}", "РУБЛЯМ")
      .
      if lookup('~{&', v-action-item-description) > 0
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "В правах задан препроцессинг для которого не указан способ обработки" skip
          "Идентификатор права" v-action-item-id skip
          "Имя права" v-action-item-description skip
          view-as alert-box error .
      end.
      find first buf_temp-action-item
        where buf_temp-action-item.action-item-id = v-action-item-id
        no-error .
      if available buf_temp-action-item
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании права" skip
          "Уже создано право с таким же идентификатором" v-action-item-id skip
          "action-item-id"             v-action-item-id             skip
          "action-item-context"        v-action-item-context        skip
          "action-group-configuration" v-action-group-configuration skip
          "action-group-id"            v-action-group-id            skip
          "action-item-name"           v-action-item-name           skip
          "action-item-description"    v-action-item-description    skip
          "action-item-encoded"        v-action-item-encoded        skip
          view-as alert-box error .
      end.
      create buf_temp-action-item .
      assign
        buf_temp-action-item.action-item-code          = v-action-item-code
        buf_temp-action-item.action-item-id            = v-action-item-id
        buf_temp-action-item.action-item-context       = v-action-item-context
        buf_temp-action-item.action-item-configuration = v-action-item-configuration
        buf_temp-action-item.action-group-code         = 0
        buf_temp-action-item.action-group-id           = v-action-group-id
        buf_temp-action-item.action-item-name          = v-action-item-name
        buf_temp-action-item.action-item-description   = v-action-item-description
        buf_temp-action-item.action-item-encoded       = v-action-item-encoded
      .
      if length(v-action-item-attr-value) <> 0 then do :
        find first buf_temp-action-item-attr
          where buf_temp-action-item-attr.action-item-code = v-action-item-code
          no-error.
        if available buf_temp-action-item-attr
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании атрибута Linking"                        skip
            "Уже существует атрибут"        v-action-item-attr-value     skip
            "Для права с идентификатором"   v-action-item-id             skip
            "action-item-context"           v-action-item-context        skip
            "action-group-configuration"    v-action-group-configuration skip
            "action-group-id"               v-action-group-id            skip
            "action-item-name"              v-action-item-name           skip
            "action-item-description"       v-action-item-description    skip
            "action-item-encoded"           v-action-item-encoded        skip
            view-as alert-box error .
        end.
        create buf_temp-action-item-attr .
        assign
          buf_temp-action-item-attr.action-item-code = v-action-item-code
          buf_temp-action-item-attr.attr-code      = "Linking"
          buf_temp-action-item-attr.attr-value     = v-action-item-attr-value
        .
      end.
    end.
    input stream sinp close .
  end.
end procedure.
procedure filter-configuration-action-group :
  define buffer buf_temp-action-group for temp-action-group .
  define variable v-configuration-list           as character no-undo .
  define variable v-configuration-item           as character no-undo .
  define variable v-num-items-configuration-list as integer   no-undo .
  define variable v-ind                          as integer   no-undo .
  define variable v-enable-item                  as logical   no-undo .
  define variable v-check-enable-item            as logical   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_temp-action-group
    on error undo, return error return-value
    :
      assign
        v-configuration-list = buf_temp-action-group.action-group-configuration
      .
      if v-configuration-list = '':u
      then do:
        assign
          v-enable-item = true
        .
      end.
      else do:
        assign
          v-enable-item = false
        .
        assign
          v-num-items-configuration-list = num-entries(v-configuration-list)
        .
        check_block :
        do v-ind = 1 to v-num-items-configuration-list
        :
          assign
            v-configuration-item = entry(v-ind, v-configuration-list)
          .
          run value(v-configuration-item) in parparentproc
            (output v-check-enable-item
            ) .
          if v-check-enable-item = true
          then do:
            assign
              v-enable-item = true
            .
            leave check_block .
          end.
        end.
      end.
      if v-enable-item <> true
      then do:
        delete buf_temp-action-group .
      end.
    end.
  end.
end procedure.
procedure filter-configuration-action-item :
  define buffer buf_temp-action-item for temp-action-item .
  define buffer buf_temp-action-item-attr for temp-action-item-attr .
  define variable v-configuration-list           as character no-undo .
  define variable v-configuration-item           as character no-undo .
  define variable v-num-items-configuration-list as integer   no-undo .
  define variable v-ind                          as integer   no-undo .
  define variable v-enable-item                  as logical   no-undo .
  define variable v-check-enable-item            as logical   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_temp-action-item
    on error undo, return error return-value
    :
      assign
        v-configuration-list = buf_temp-action-item.action-item-configuration
      .
      if v-configuration-list = '':u
      then do:
        assign
          v-enable-item = true
        .
      end.
      else do:
        assign
          v-enable-item = false
        .
        assign
          v-num-items-configuration-list = num-entries(v-configuration-list)
        .
        check_block :
        do v-ind = 1 to v-num-items-configuration-list
        :
          assign
            v-configuration-item = entry(v-ind, v-configuration-list)
          .
          run value(v-configuration-item) in parparentproc
            (output v-check-enable-item
            ) .
          if v-check-enable-item = true
          then do:
            assign
              v-enable-item = true
            .
            leave check_block .
          end.
        end.
      end.
      if v-enable-item <> true
      then do:
        find first buf_temp-action-item-attr exclusive-lock
          where buf_temp-action-item-attr.action-item-code = buf_temp-action-item.action-item-code
          no-error.
        if available buf_temp-action-item-attr then do :
          delete buf_temp-action-item-attr .
        end.
        delete buf_temp-action-item .
      end.
    end.
  end.
end procedure.
procedure validate-action-item :
  do
  on error undo, return error return-value
  :
  end.
end procedure.
procedure export-action-item :
  define buffer buf_action-group for ub.action-group .
  define buffer buf_action-item  for ub.action-item .
  do
  on error undo, return error return-value
  :
    output to value('actn-export.txt':u) .
    for each buf_action-group
    on error undo, return error return-value
    :
      export "action-group" .
      export buf_action-group .
    end.
    for each buf_action-item
    on error undo, return error return-value
    :
      export "action-item" .
      export buf_action-item .
    end.
    output close .
  end.
end procedure.
procedure clear-action :
  define buffer buf_action-group for ub.action-group .
  define buffer buf_action-item  for ub.action-item .
  define buffer buf_action-item-attr for ub.action-item-attr .
  do
  on error undo, return error return-value
  :
    define variable v-ind as integer   no-undo .
    assign
      v-ind = 0
    .
    for each buf_action-group exclusive-lock
      where buf_action-group.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Удаление групп прав &1"
                          ,v-ind
                          )
          ) .
      end.
      delete buf_action-group .
    end.
    assign
      v-ind = 0
    .
    for each buf_action-item exclusive-lock
      where buf_action-item.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Удаление прав &1"
                          ,v-ind
                          )
          ) .
      end.
      delete buf_action-item .
    end.
    assign
      v-ind = 0
    .
    for each buf_action-item-attr exclusive-lock
      where buf_action-item-attr.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Удаление атрибутов прав &1"
                          ,v-ind
                          )
          ) .
      end.
      delete buf_action-item-attr .
    end.
  end.
end procedure.
procedure write-action :
  define buffer buf_temp-action-group      for temp-action-group .
  define buffer buf_action-group           for ub.action-group .
  define buffer buf_temp-action-item       for temp-action-item .
  define buffer buf_action-item            for ub.action-item .
  define buffer buf_temp-action-item-attr  for temp-action-item-attr .
  define buffer buf_action-item-attr       for ub.action-item-attr .
  define variable v-ind as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .
    for each buf_temp-action-group
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Создание групп прав &1"
                          ,v-ind
                          )
          ) .
      end.
      create buf_action-group .
      assign
        buf_action-group.action-head-code         = v-action-head-code
        buf_action-group.action-group-code        = buf_temp-action-group.action-group-code
        buf_action-group.action-group-id          = buf_temp-action-group.action-group-id
        buf_action-group.action-group-name        = buf_temp-action-group.action-group-name
        buf_action-group.action-group-description = buf_temp-action-group.action-group-description
      .
    end.
    for each buf_temp-action-item
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Создание новых прав &1"
                          ,v-ind
                          )
          ) .
      end.
      create buf_action-item .
      assign
        buf_action-item.action-head-code           = v-action-head-code
        buf_action-item.action-item-code           = buf_temp-action-item.action-item-code
        buf_action-item.action-item-id             = buf_temp-action-item.action-item-id
        buf_action-item.action-item-context        = buf_temp-action-item.action-item-context
        buf_action-item.action-group-code          = buf_temp-action-item.action-group-code
        buf_action-item.action-group-id            = buf_temp-action-item.action-group-id
        buf_action-item.action-item-name           = buf_temp-action-item.action-item-name
        buf_action-item.action-item-description    = buf_temp-action-item.action-item-description
        buf_action-item.action-item-encoded        = buf_temp-action-item.action-item-encoded
      .
    end.
    for each buf_temp-action-item-attr
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Обновление прав. Создание атрибутов новых прав &1"
                          ,v-ind
                          )
          ) .
      end.
      create buf_action-item-attr .
      assign
        buf_action-item-attr.action-head-code = v-action-head-code
        buf_action-item-attr.action-item-code = buf_temp-action-item-attr.action-item-code
        buf_action-item-attr.attr-code        = buf_temp-action-item-attr.attr-code
        buf_action-item-attr.attr-value       = buf_temp-action-item-attr.attr-value
      .
    end.
  end.
end procedure.
procedure update-action-role-item :
  define variable v-current-db-num as integer   no-undo .
  define buffer buf_action-role-item         for ub.action-role-item .
  define buffer buf_action-item              for ub.action-item .
  define buffer buf_action-role-item-gds     for ub.action-role-item-gds .
  define buffer buf_action-role-item-gds-grp for ub.action-role-item-gds-grp .
  do
  on error undo, return error return-value
  :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
    for each buf_action-role-item exclusive-lock
      where buf_action-role-item.db-num           = v-current-db-num
        and buf_action-role-item.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      find first buf_action-item no-lock
        where buf_action-item.action-head-code = buf_action-role-item.action-head-code
          and buf_action-item.action-item-id   = buf_action-role-item.action-item-id
        no-error .
      if available buf_action-item
      then do:
        assign
          buf_action-role-item.action-item-code = buf_action-item.action-item-code
        .
        FOR EACH  buf_action-role-item-gds
            where buf_action-role-item-gds.action-head-code       = buf_action-role-item.action-head-code
              and buf_action-role-item-gds.action-role-code       = buf_action-role-item.action-role-code
              and buf_action-role-item-gds.action-role-item-code  = buf_action-role-item.action-role-item-code
              and buf_action-role-item-gds.action-item-id         = buf_action-role-item.action-item-id
            exclusive-lock
            :
            assign
               buf_action-role-item-gds.action-item-code = buf_action-item.action-item-code
            .
        END.
      end.
      else do:
        FOR EACH  buf_action-role-item-gds
            where buf_action-role-item-gds.action-head-code       = buf_action-role-item.action-head-code
              and buf_action-role-item-gds.action-role-code       = buf_action-role-item.action-role-code
              and buf_action-role-item-gds.action-role-item-code  = buf_action-role-item.action-role-item-code
              and buf_action-role-item-gds.action-item-id         = buf_action-role-item.action-item-id
            exclusive-lock
            :
            assign
               buf_action-role-item-gds.action-item-code = 0
            .
        END.
        assign
          buf_action-role-item.action-item-code = 0
        .
      end.
    end.
    if v-current-db-num <> 0 and v-action-gbl then do:
       disable triggers for load of buf_action-role-item .
       v-current-db-num = 0 .
       for each buf_action-role-item exclusive-lock
      where buf_action-role-item.db-num           = v-current-db-num
        and buf_action-role-item.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      find first buf_action-item no-lock
        where buf_action-item.action-head-code = buf_action-role-item.action-head-code
          and buf_action-item.action-item-id   = buf_action-role-item.action-item-id
        no-error .
      if available buf_action-item
      then do:
        assign
          buf_action-role-item.action-item-code = buf_action-item.action-item-code
        .
        FOR EACH  buf_action-role-item-gds
            where buf_action-role-item-gds.action-head-code       = buf_action-role-item.action-head-code
              and buf_action-role-item-gds.action-role-code       = buf_action-role-item.action-role-code
              and buf_action-role-item-gds.action-role-item-code  = buf_action-role-item.action-role-item-code
              and buf_action-role-item-gds.action-item-id         = buf_action-role-item.action-item-id
            exclusive-lock
            :
            assign
               buf_action-role-item-gds.action-item-code = buf_action-item.action-item-code
            .
        END.
      end.
      else do:
        FOR EACH  buf_action-role-item-gds
            where buf_action-role-item-gds.action-head-code       = buf_action-role-item.action-head-code
              and buf_action-role-item-gds.action-role-code       = buf_action-role-item.action-role-code
              and buf_action-role-item-gds.action-role-item-code  = buf_action-role-item.action-role-item-code
              and buf_action-role-item-gds.action-item-id         = buf_action-role-item.action-item-id
            exclusive-lock
            :
            assign
               buf_action-role-item-gds.action-item-code = 0
            .
        END.
        assign
          buf_action-role-item.action-item-code = 0
        .
      end.
    end.
    end.
  end.
end procedure.
procedure update-user-login-action-item :
  define variable v-current-db-num as integer   no-undo .
  define buffer buf_user-login-action-item for ub.user-login-action-item.
  define buffer buf_action-item      for ub.action-item .
  do
  on error undo, return error return-value
  :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-current-db-num
  )  .
    for each buf_user-login-action-item exclusive-lock
      where buf_user-login-action-item.db-num           = v-current-db-num
        and buf_user-login-action-item.action-head-code = v-action-head-code
    on error undo, return error return-value
    :
      find first buf_action-item no-lock
        where buf_action-item.action-head-code = buf_user-login-action-item.action-head-code
          and buf_action-item.action-item-id   = buf_user-login-action-item.action-item-id
        no-error .
      if available buf_action-item
      then do:
        assign
          buf_user-login-action-item.action-item-code = buf_action-item.action-item-code
        .
      end.
      else do:
        assign
          buf_user-login-action-item.action-item-code = 0
        .
      end.
    end.
  end.
end procedure.
