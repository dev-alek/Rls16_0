define temp-table procAsunc no-undo
    field procid            as character
    field procval           as character
    field procname          as character
    field proctyperun       as character
    index pi is primary unique
        procid
.
define temp-table procParam no-undo
    field procid                as character
    field paramName             as character
    field numparam              as integer
    field ParamValue            as character
    field ParamType             as character
    field ParamHiden            as logical
    index pi is primary unique
        procid numparam
.
define temp-table SesParam no-undo
    field parCheck          as logical
    field parCode           as character
    field parname           as character
    field parvalue          as character
    field parWaitFile       as character
    index pi is primary unique
        parCode
.
define dataset ds-asuncProc xml-node-name "root" for procAsunc, procParam  , SesParam
data-relation  relver  for procAsunc, procParam relation-fields (procid,procid) nested.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable masynchelper as class ibs.th.file.asynchelperTh no-undo.
define buffer tt-Param  for procparam.
define buffer tt-sespar for SesParam.
define input  parameter parparentproc as handle no-undo.
define input  parameter iProcId as character no-undo.
define input  parameter dataset  for ds-asuncProc bind.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Асинхронные процессы" .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared variable auto-window-h     as handle    no-undo .
define new shared variable auto-log-msg-h    as handle    no-undo .
define new shared variable hand-log-msg-h    as handle    no-undo .
define new shared variable log-file-name     as character no-undo initial ? .
define new shared variable add-log-file-name as character no-undo initial ? .
define new shared variable writelogvalue     as character no-undo initial ? .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream LogStream .
define variable mNoTime as logical no-undo.
procedure write-to-log-notime :
  define input param i-str as character no-undo .
  mNoTime = yes.
  run write-to-log (i-str).
  mNoTime = no.
end.
procedure write-to-log :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-log). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-log). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-log). endkey", vss-workfile )
  :
    define variable log-res        as logical   no-undo .
    define variable v-jj           as integer   no-undo .
    if auto-log-msg-h <> ? then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ? then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
    assign
      p-str = replace(p-str, (chr(10) + chr(13)), chr(10) )
      p-str = replace(p-str, (chr(13) + chr(10)), chr(10) )
      p-str = replace(p-str, chr(10), (chr(13) + chr(10)) )
    .
    if add-log-file-name <> ? then do:
      do v-jj = 1 to num-entries(add-log-file-name, chr(1)):
        run gbl/fileapnd.p
          ( input entry(v-jj, add-log-file-name, chr(1) )
          ,input p-str
          ,input 20
          ) no-error .
        if error-status:error then do:
          return error return-value .
        end.
      end.
    end.
    if writelogvalue eq "AsyncProc"
    then do:
       p-str = trim(p-str, (chr(13) + chr(10)) )
    .
       Publish "WriteLogAsunc" (p-str,yes).
    end.
    else if writelogvalue <> "yes" then do:
      run gbl/fileapnd.p
        ( input log-file-name
        ,input p-str
        ,input 20
        ) no-error .
      if error-status:error then do:
        return error return-value .
      end.
    end.
  end.
end procedure.
procedure write-to-screen :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-screen). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-screen). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-screen). endkey", vss-workfile )
  :
    define variable log-res as logical no-undo.
    if auto-log-msg-h <> ?
    then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ?
    then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
  end.
end procedure.
procedure send-msg-to-email :
  define input  parameter p-subject      as character no-undo .
  define input  parameter p-text-err     as character no-undo .
  define input  parameter p-attach-files as character no-undo .
  do
  on error  undo, return error substitute( "&1 (send-msg-to-email). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-msg-to-email). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-msg-to-email). endkey", vss-workfile )
  :
    define variable v-tth             as handle    no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-param-type      as character no-undo .
    define variable v-email       as character no-undo .
    define variable v-tmp-str     as character no-undo .
    define variable v-tmp1-str    as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    delete object v-tth no-error.
    run adm/shattri.p
      ( input "get":U
       ,input  "":U
       ,input  0
       ,input  'auto-task':U
       ,input  'send-msg-to-email':U
       ,output v-value-character
       ,output v-value-date
       ,output v-value-decimal
       ,output v-value-integer
       ,output v-value-logical
       ,output v-param-type
       ,input-output table-handle v-tth
      ) no-error .
    if not error-status :error  then do:
      assign
        v-tmp-str = v-value-character
      .
    end.
    delete object v-tth no-error.
    assign
      v-tmp-str     = replace(v-tmp-str, (chr(10) + chr(13)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, (chr(13) + chr(10)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, chr(10), chr(44) )
      v-num-entries = num-entries( v-tmp-str, chr(44) )
      v-email       = "":U
    .
    do v-ind = 1 to v-num-entries
    :
      assign
        v-tmp1-str = entry( v-ind, v-tmp-str, chr(44) )
      .
      if trim( v-tmp1-str ) <> "":U then do:
        if v-email = "":U then do:
          assign
            v-email = v-tmp1-str
          .
        end.
        else do:
          assign
            v-email = v-email + chr(44) + v-tmp1-str
          .
        end.
      end.
    end.
    if v-email <> "":U then do:
      run gbl/sendmail.p
        ( input v-email
        , input p-subject
        , input p-text-err
        , input p-attach-files
        ) no-error .
      if error-status :error
        or return-value <> "":U
      then do:
        return error substitute( "&1 (send-msg-to-email). &2", vss-workfile, return-value ) .
      end.
    end.
  end.
end procedure.
define variable mLableText as character no-undo.
define variable mStartTime as datetime-tz no-undo init ?.
procedure addtask:
   define input  parameter ITask as character no-undo.
   define input  parameter iProc as character no-undo.
   define input  parameter iParam as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   if mStartTime ne ?
   then
      mAsyncHelper:AddTask (ITask,iProc,iParam,mStartTime).
   else
      mAsyncHelper:AddTask (ITask,iProc,iParam).
   unsubscribe "PutFileLogAsunc".
end.
procedure addTaskTime:
   define input  parameter ITask      as character no-undo.
   define input  parameter iProc      as character no-undo.
   define input  parameter iParam     as character no-undo.
   define input  parameter iStartTime as datetime-tz no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   mAsyncHelper:AddTask (ITask,iProc,iParam,iStartTime).
   unsubscribe "PutFileLogAsunc".
end.
procedure waitproc:
   define input  parameter itext  as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   run ibs\th\file\waithelper.p (mAsyncHelper,?,1,itext + " " + mLableText).
   unsubscribe "PutFileLogAsunc".
end.
procedure waitProcLable:
   define input  parameter itext  as character no-undo.
   mLableText = itext.
end.
procedure waitProcShed:
   define input  parameter iSched as character no-undo.
   define input  parameter itext  as character no-undo.
   subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
   run ibs\th\file\waithelper.p (mAsyncHelper,iSched,1,itext).
   unsubscribe "PutFileLogAsunc".
end.
procedure WriteLogAsync:
   define input  parameter iFile as character no-undo.
   define variable vText as character no-undo.
   define variable vFile as longchar  no-undo.
   define variable vfileName as character no-undo.
   define variable vi as int64 no-undo.
   define variable vStr  as character no-undo.
   vfileName = mAsyncHelper:objExists(iFile,"f").
   if vfileName ne ?
   then do:
      copy-lob from file vfileName to vFile no-error.
      if error-status:error
      then do:
         run write-to-log (substitute ("Не удалось прочесть файл &1",iFile)).
      end.
      else do:
          vFile = replace (vFile,chr(13) + chr(10),chr(10)).
          do vi = 1 to num-entries(vFile,chr(10)) - 1:
            run write-to-log-notime (entry(vi, vFile,chr(10))).
         end.
      end.
   end.
   else do:
       assign
           vtext = substitute ("Процедура обработки данных не завершена. &1",ifile).
       run write-to-log (vtext).
   end.
end.
define button Btn_Cancel auto-end-key
     label "Выход"
     size 15 by 1.13
     bgcolor 8 .
define button Btn_OK
     label "Выполнить"
     size 15 by 1.13
     bgcolor 8 .
define query BROWSE-2 for
      tt-Param scrolling.
define query BROWSE-3 for
      tt-sespar scrolling.
define browse BROWSE-2
  query BROWSE-2 no-lock display
      tt-Param.paramName column-label "Параметр" format "x(30)":U
      tt-Param.ParamValue column-label "Значение" format "x(60)":U width 55.63
      ENABLE
      tt-Param.ParamValue
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90 BY 10.75 FIT-LAST-COLUMN.
define browse BROWSE-3
  query BROWSE-3 no-lock display
      tt-sespar.parCheck  column-label "" format "yes/no":U width 4
            view-as toggle-box
      tt-sespar.parname column-label "Параметр" format "x(30)":U width 14.5
      tt-sespar.parvalue  column-label "Ключ запуска" format "x(200)":U width 44.63
  ENABLE
      tt-sespar.parCheck  tt-sespar.parvalue
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90 BY 9 FIT-LAST-COLUMN.
define frame Dialog-Frame
     Btn_Cancel at row 1.25 col 2
     Btn_OK at row 1.25 col 18
     BROWSE-2 at row 3 col 2 widget-id 200
     BROWSE-3 at row 15.25 col 2 widget-id 300
     "Добавить параметры" view-as text
          size 33 by .67 tooltip "Добавить параметры" at row 14.25 col 3.5 widget-id 8
     space(52.87) skip(9.99)
    with view-as dialog-box keep-tab-order
         side-labels no-underline three-d  scrollable
         title "Запуск сессии"
         default-button Btn_OK cancel-button Btn_Cancel widget-id 100.
assign
       frame Dialog-Frame:SCROLLABLE       = false
       frame Dialog-Frame:HIDDEN           = true.
on window-close of frame Dialog-Frame
do:
  apply "END-ERROR":U to self.
end.
on leave of tt-Param.ParamValue in browse BROWSE-2  do:
 tt-Param.ParamValue = tt-Param.ParamValue:screen-value in browse BROWSE-2  no-error .
end.
on leave of tt-sespar.parCheck in browse BROWSE-3  do:
 tt-sespar.parCheck = logical (tt-sespar.parCheck:screen-value in browse BROWSE-3 ) no-error .
end.
on choose of Btn_OK in frame Dialog-Frame
  do:
    define buffer tt-Param for procparam.
    define buffer tt-sespar for SesParam.
    define buffer tt-procAsunc for procAsunc.
    define variable vParams      as character no-undo.
    define variable vwaitfile    as character no-undo.
    define variable vParamSession as character no-undo.
    find first tt-procAsunc where tt-procAsunc.procid eq iProcid no-lock.
    for each tt-sespar where tt-sespar.parCheck
    no-lock:
       vparamSession = vparamSession + " " + tt-sespar.parvalue.
       if tt-sespar.parWaitFile ne "" and tt-sespar.parWaitFile ne ?
       then
          vwaitfile = vwaitfile +  "," + tt-sespar.parWaitFile.
    end.
    vwaitfile = trim(vwaitfile,",").
    vParams = fill(chr(4),25).
    for each tt-Param where tt-Param.procid eq tt-procAsunc.procid
    no-lock:
       if tt-Param.ParamValue eq "#paramSession#"
       then
           tt-Param.ParamValue = vparamSession.
       else if tt-Param.ParamValue eq "#waitfile#"
       then
           tt-Param.ParamValue = vwaitfile.
       else if tt-Param.ParamValue eq "#SaveFile#"
       then
           tt-Param.ParamValue = "yes".
       else
       if     tt-Param.ParamType ne ""
          and tt-Param.ParamType ne ?
       then do:
          if tt-Param.ParamType begins "int"
          then
             int(tt-Param.ParamValue) no-error.
          else if tt-Param.ParamType begins "dec"
          then
             dec(tt-Param.ParamValue) no-error.
          else if tt-Param.ParamType begins "log"
          then
             logical(tt-Param.ParamValue) no-error.
          else if tt-Param.ParamType begins "date"
          then
             date(tt-Param.ParamValue) no-error.
          if error-status:error
          then do:
             message tt-Param.paramName skip
                     "должен быть типа " tt-Param.paramtype skip
                     error-status:get-message (1)
             view-as alert-box.
             return no-apply.
          end.
       end.
       entry(tt-Param.numparam,vParams,chr(4)) = tt-Param.ParamValue.
    end.
    vParams = right-trim(vParams,chr(4)).
    subscribe "PutFileLogAsunc" anywhere run-procedure "WriteLogAsync".
    mAsyncHelper = new ibs.th.file.AsyncHelperth().
    mAsyncHelper:mProcPublish   = this-procedure.
    mAsyncHelper:setCurrentUserPasswd().
    mAsyncHelper:MyBachMode     = session:batch-mode.
    mAsyncHelper:SaveFile       = yes.
    mAsyncHelper:paramSession   = vparamSession.
    mAsyncHelper:WaitFile = vwaitfile.
    if tt-procAsunc.proctyperun eq "diallog"
    then do:
       run str/diallog.w ( parparentproc
              , this-procedure
              , tt-procAsunc.procval
              , vParams
              , no
              , '':U
              , tt-procAsunc.procname) no-error .
    end.
    else do:
       mAsyncHelper:AsyncProc(tt-procAsunc.procval, vParams,1).
    end.
    run ibs\th\file\waithelper.p (mAsyncHelper,?, 1,tt-procAsunc.procname).
    os-command no-wait value (mAsyncHelper:getlog(?)).
    message "Результаты выполнения находятся в " mAsyncHelper:SaveArh()
    view-as alert-box.
    delete object mAsyncHelper.
    unsubscribe "PutFileLogAsunc".
  end.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
then frame Dialog-Frame:PARENT = active-window.
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
  run enable_UI.
  wait-for go of frame Dialog-Frame.
end.
run disable_UI.
procedure disable_UI :
  hide frame Dialog-Frame.
end procedure.
procedure enable_UI :
  enable Btn_Cancel Btn_OK BROWSE-2 BROWSE-3
      with frame Dialog-Frame.
  view frame Dialog-Frame.
  OPEN QUERY BROWSE-2 FOR EACH tt-Param where tt-Param.procid eq iProcId and tt-Param.paramhiden ne yes NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-3 FOR EACH tt-sespar NO-LOCK INDEXED-REPOSITION.
end procedure.
