DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-parent-handle AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER p-role AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-mode AS CHARACTER NO-UNDO.
define input parameter p-level as CHARACTEr no-undo .
define INPUT-OUTPUT parameter p-db-num like ub.db.db-num no-undo .
define INPUT-OUTPUT parameter p-host-code like ub.sysconf.host-code no-undo .
define INPUT-OUTPUT parameter p-obj-type like ub.clients.obj-type no-undo .
define INPUT-OUTPUT parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER p-title AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-staff-code-label AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-staff-code-format AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-password-option AS integer NO-UNDO.
DEFINE INPUT PARAMETER p-password-label AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-password-format AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER p-notes  AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-staff-code AS integer NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-password AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-date-start AS date NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-date-end AS date NO-UNDO.
DEFINE OUTPUT PARAMETER p-ok AS logical NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование данных по персоналу".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
define variable is-temp as logical no-undo .
define variable glog as logical no-undo .
define variable v-obj-db-num like ub.db.db-num no-undo .
DEFINE VARIABLE v-modified AS LOGICAL NO-UNDO.
define buffer buf_role-db for ub.db.
define buffer buf_role-sysconf for ub.sysconf.
define buffer buf_role-clients for ub.clients.
DEFINE BUTTON B-db
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-host
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE CB-obj-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEMS "","Item 1","Item 2"
     DROP-DOWN-LIST
     SIZE 11 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE E-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 65.5 BY 3.75 NO-UNDO.
DEFINE VARIABLE f-date-end AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE f-date-start AS DATE FORMAT "99/99/9999":U INITIAL ?
     LABEL "Работает с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "№ БД"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE f-host-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Фирма"
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-host-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1
     BGCOLOR 8  NO-UNDO.
DEFINE VARIABLE F-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 56.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-password AS CHARACTER FORMAT "X(10)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE f-staff-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     LABEL "Код персонала"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE fi-screen-pass AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 12 BY .29
     BGCOLOR 15  NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.88
     f-db-num AT ROW 3 COL 13 COLON-ALIGNED
     B-db AT ROW 3 COL 23
     f-host-code AT ROW 4.5 COL 13 COLON-ALIGNED
     B-host AT ROW 4.5 COL 23
     CB-obj-type AT ROW 6 COL 2.5 NO-LABEL
     f-obj-code AT ROW 6 COL 13 COLON-ALIGNED NO-LABEL
     B-obj AT ROW 6 COL 23
     f-staff-code AT ROW 8.5 COL 37 COLON-ALIGNED
     f-password AT ROW 10.5 COL 37 COLON-ALIGNED BLANK
     f-date-start AT ROW 12 COL 37 COLON-ALIGNED
     f-date-end AT ROW 12 COL 54 COLON-ALIGNED
     E-notes AT ROW 14 COL 1.5 NO-LABEL
     F-host-name AT ROW 4.75 COL 24 COLON-ALIGNED NO-LABEL
     F-obj-name AT ROW 6.25 COL 24 COLON-ALIGNED NO-LABEL
     fi-screen-pass AT ROW 10.58 COL 37 COLON-ALIGNED NO-LABEL
     SPACE(33.87) SKIP(7.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       E-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-db-num:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-host-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-obj-code:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-db IN FRAME Dialog-Frame
DO:
  run proc-b-db IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  IF p-mode = 'ПРОСМОТР':U THEN RETURN NO-APPLY.
  run proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  ASSIGN
  p-ok = YES
  p-staff-code = f-staff-code
  p-password = f-password
  p-date-start = f-date-start
  p-date-end = (IF f-date-end:VISIBLE IN FRAME Dialog-Frame THEN f-date-end ELSE p-date-end)
  p-db-num = (if p-db-num <> f-db-num then f-db-num else p-db-num)
  p-host-code = (if p-host-code <> f-host-code then f-host-code else p-host-code)
  p-obj-type = (if p-obj-type <> cb-obj-type then cb-obj-type else p-obj-type)
  p-obj-code = (if p-obj-code <> f-obj-code then f-obj-code else p-obj-code)
  .
END.
ON CHOOSE OF B-host IN FRAME Dialog-Frame
DO:
  run proc-b-host IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-obj IN FRAME Dialog-Frame
DO:
  run proc-b-obj IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON ANY-KEY OF f-password IN FRAME Dialog-Frame
DO:
    assign
    fi-screen-pass :screen-value = fill('*':u, length(f-password :screen-value )).
END.
ON VALUE-CHANGED OF f-password IN FRAME Dialog-Frame
DO:
  assign
    fi-screen-pass :screen-value = fill('*':u, length(f-password :screen-value )).
END.
ON ANY-PRINTABLE OF f-staff-code IN FRAME Dialog-Frame
DO:
  v-modified = YES.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-start in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of f-date-start in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of f-date-start in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of f-date-start in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of f-date-start in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of f-date-start in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date10
    MENU-ITEM m-ed-date10-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date10-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date10-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date10-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-start :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      f-date-start :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date10 :HANDLE
      f-date-start :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle10 as handle no-undo .
  assign
    v-label-handle10 = f-date-start :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle10)
  then do:
    if v-label-handle10 :tooltip = ""
    or v-label-handle10 :tooltip = ?
    then do:
      assign
        v-label-handle10 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date10-1 in menu m-ed-date10 DO:
    apply "ctrl-b":U to f-date-start in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-2 in menu m-ed-date10 DO:
    apply "ctrl-d":U to f-date-start in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-3 in menu m-ed-date10 DO:
    apply "ctrl-e":U to f-date-start in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-4 in menu m-ed-date10 DO:
    apply "ctrl-f":U to f-date-start in frame Dialog-Frame .
  END.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-date-end in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of f-date-end in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of f-date-end in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of f-date-end in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of f-date-end in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of f-date-end in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date12
    MENU-ITEM m-ed-date12-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date12-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date12-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date12-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-date-end :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      f-date-end :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date12 :HANDLE
      f-date-end :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle12 as handle no-undo .
  assign
    v-label-handle12 = f-date-end :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle12)
  then do:
    if v-label-handle12 :tooltip = ""
    or v-label-handle12 :tooltip = ?
    then do:
      assign
        v-label-handle12 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date12-1 in menu m-ed-date12 DO:
    apply "ctrl-b":U to f-date-end in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-2 in menu m-ed-date12 DO:
    apply "ctrl-d":U to f-date-end in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-3 in menu m-ed-date12 DO:
    apply "ctrl-e":U to f-date-end in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-4 in menu m-ed-date12 DO:
    apply "ctrl-f":U to f-date-end in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  IF lookup(p-mode, 'ДОБАВЛЕНИЕ':U + chr(4) +
                    'ИЗМЕНЕНИЕ':U + chr(4) +
                    'ПРОСМОТР':U +  chr(4) +
                    'ДОБАВЛЕНИЕ':U  + chr(44) + 'temp'
                    , chr(4) ) = 0  THEN DO:
      MESSAGE
      "Неверный параметр p-mode" p-mode
      VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR.
  END.
  if p-mode = 'ДОБАВЛЕНИЕ':U + chr(44) + 'temp':U then do:
      assign
      p-mode = 'ДОБАВЛЕНИЕ':U
      is-temp = yes.
  end.
  CASE p-level :
     when 'db':U then do:
       if p-db-num <> ? then do:
        find first buf_role-db no-lock where
                  buf_role-db.db-num = p-db-num no-error .
        if not available buf_role-db then do:
          message
          substitute("&1&2&3&2&4&2Неверный параметр p-db-num &5 - нет такой БД"
                      , vss-workfile
                      , chr(10)
                      , vss-revision
                      , vss-description
                      , p-db-num)
          view-as alert-box error .
          undo, return error .
        end.
       end.
     end.
     when 'firm':U then do:
       if p-host-code <> 0 then do:
        find first buf_role-sysconf no-lock where
                  buf_role-sysconf.host-code = p-host-code no-error .
        if not available buf_role-sysconf then do:
          message
          substitute("&1&2&3&2&4&2Неверный параметр p-host-code &5 - нет такой ФИРМЫВ"
                      , vss-workfile
                      , chr(10)
                      , vss-revision
                      , vss-description
                      , p-host-code)
          view-as alert-box error .
          undo, return error .
        end.
       end.
     end.
     when 'object':U then do:
       if p-obj-type <> "":U
       or p-obj-code <> 0 then do:
        find first buf_role-clients no-lock where
                  buf_role-clients.obj-type = p-obj-type
              and buf_role-clients.obj-code = p-obj-code no-error .
        if not available buf_role-clients then do:
          message
          substitute("&1&2&3&2&4&2Неверный параметр p-obj-type p-obj-code &5&6 - нет такого ОБЪЕКТА"
                      , vss-workfile
                      , chr(10)
                      , vss-revision
                      , vss-description
                      , p-obj-type
                      , p-obj-code
                      )
          view-as alert-box error .
          undo, return error .
        end.
       end.
     end.
  END CASE.
  ASSIGN
  f-staff-code = p-staff-code
  f-password = p-password
  f-date-start = p-date-start
  .
  run Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-db-num f-host-code CB-obj-type f-obj-code f-staff-code f-password
          f-date-start f-date-end E-notes F-host-name F-obj-name fi-screen-pass
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help B-db B-host CB-obj-type B-obj f-staff-code
         f-password f-date-start f-date-end E-notes F-host-name F-obj-name
         fi-screen-pass
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-codes :
DEFINE VARIABLE v-last-staff-code AS INTEGER NO-UNDO.
DEFINE VARIABLE v-work-place AS character NO-UNDO.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  IF f-staff-code:SCREEN-VALUE IN FRAME Dialog-Frame <> '':U AND v-modified THEN do:
      return.
  END.
  CASE p-level:
    WHEN 'db':U THEN DO:
      ASSIGN
      v-work-place = STRING(f-db-num, '99999').
    END.
    WHEN 'firm':U THEN DO:
      ASSIGN
      v-work-place = STRING(f-host-code, '99999').
    END.
    WHEN 'object':U THEN DO:
      ASSIGN
      v-work-place = cb-obj-type +  STRING(f-obj-CODE, '999999999').
    END.
    WHEN 'global':U THEN DO:
      ASSIGN
      v-work-place = '':U.
    END.
  END CASE.
  IF v-work-place = ?
  OR (v-work-place = '':U AND p-level <> 'global':U) THEN DO:
    ASSIGN
    v-work-place = chr(63).
  END.
  ASSIGN
  v-last-staff-code = gbclcode-get-level-last-code ( INPUT p-role
                                  , INPUT p-level
                                  , INPUT v-work-place
                                  , input ?
                                  ) NO-ERROR.
  IF length(STRING(v-last-staff-code + 1)) <= LENGTH(p-staff-code-format) THEN
  display
  v-last-staff-code + 1 @ f-staff-code
  with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE MyEnable :
define buffer buf_clients for ub.clients.
ASSIGN
 fi-screen-pass:WIDTH-CHARS IN FRAME Dialog-Frame = f-password:WIDTH-CHARS IN FRAME Dialog-Frame - 0.5
 fi-screen-pass:HEIGHT-CHARS IN FRAME Dialog-Frame = f-password:HEIGHT-CHARS IN FRAME Dialog-Frame - 0.6
 fi-screen-pass:row IN FRAME Dialog-Frame = f-password:row IN FRAME Dialog-Frame + 0.20
 fi-screen-pass:COL IN FRAME Dialog-Frame = f-password:col IN FRAME Dialog-Frame + 0.25
 .
ASSIGN
v-tab-order = "b-exit,b-quit,b-help,b-db,b-host,b-obj,f-staff-code,f-password,f-date-start,f-date-end"
FRAME Dialog-Frame:TITLE = p-title
f-staff-code:LABEL = p-staff-code-label
f-staff-code:format = p-staff-code-format
f-password:LABEL = p-password-label
f-password:format = p-password-format
e-notes:SCREEN-VALUE = p-notes
f-date-start = p-date-start
f-date-end = p-date-end
.
if p-level = 'object':U
and  available buf_role-clients then do:
  assign
  v-obj-db-num = buf_role-clients.db-num.
end.
DISPLAY
f-staff-code
f-password WHEN p-password-option > 0
f-date-start
f-date-end WHEN p-date-end <> 12/31/9999
WITH FRAME Dialog-Frame.
IF p-notes = '':U THEN DO:
    HIDE
    E-notes
    IN FRAME Dialog-Frame.
END.
ENABLE
B-exit
b-quit
B-Help
b-db WHEN (p-mode = 'ДОБАВЛЕНИЕ':U AND p-level = 'db':U and v-cntxt-db-num = 0)
b-host WHEN (p-mode <> 'ДОБАВЛЕНИЕ':U AND p-level = 'firm':U and v-cntxt-db-num = 0)
b-obj WHEN (p-mode <> 'ДОБАВЛЕНИЕ':U AND p-level = 'object':U and
            (v-cntxt-db-num = 0 or v-cntxt-db-num = v-obj-db-num))
f-staff-code WHEN p-mode = 'ДОБАВЛЕНИЕ':U
f-password  WHEN (p-mode <> 'ПРОСМОТР':U AND p-password-option > 0)
f-date-start WHEN p-mode = 'ДОБАВЛЕНИЕ':U
f-date-end WHEN (p-mode = 'ИЗМЕНЕНИЕ':U AND p-date-end <> 12/31/9999)
e-notes WHEN p-notes <> '':U
WITH FRAME Dialog-Frame.
IF p-mode = 'ПРОСМОТР':U THEN DO:
    ASSIGN
    b-quit:LABEL = "&Выход".
    HIDE b-exit
    IN FRAME Dialog-Frame.
END.
if p-level = 'db':U then do:
  assign
  f-db-num = p-db-num.
  display
  f-db-num
  with frame Dialog-Frame .
end.
else do:
  hide
  b-db
  f-db-num
  in frame Dialog-Frame .
end.
if p-date-end = 12/31/9999 then do:
   hide
   f-date-end
   in frame Dialog-Frame .
end.
if p-level = 'firm':U then do:
  assign
  f-host-code = p-host-code.
  find first buf_clients no-lock where
            buf_clients.obj-type = 'орг':U
        and buf_clients.obj-code = p-host-code.
  f-host-name = buf_clients.obj-name.
  display
  f-host-code
  f-host-name
  with frame Dialog-Frame .
end.
else do:
  hide
  b-host
  f-host-code
  f-host-name
  in frame Dialog-Frame .
end.
if p-level = 'object':U then do:
  assign
  CB-obj-type = p-obj-type
  f-obj-code = p-obj-code
  f-obj-name = buf_role-clients.obj-name.
  display
  f-obj-name
  f-obj-code
  CB-obj-type
  with frame Dialog-Frame .
end.
else do:
  hide
  b-obj
  cb-obj-type
  f-obj-code
  f-obj-name
  in frame Dialog-Frame .
end.
run fill-codes IN THIS-PROCEDURE NO-ERROR.
if p-role = 'C':U
then do :
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
  if not glog
  then do :
    disable
      b-db
      b-host
      b-obj
      CB-obj-type
      f-date-start
      f-date-end
    with frame Dialog-Frame .
  end.
end .
VIEW FRAME Dialog-Frame.
APPLY "TAB" TO b-help.
END PROCEDURE.
PROCEDURE proc-b-db :
define variable v-ri as recid no-undo .
define buffer buf_db  for ub.db.
  do
  on error undo, return error
  :
  run adm/dbs.w (
             input parparentproc
           , INPUT 'ПРОСМОТР':U
           , output v-ri).
  if v-ri <> ?
  then do:
    find buf_db where recid (buf_db) = v-ri .
    assign
    f-db-num = buf_db.db-num
    .
    DISPLAY
    f-db-num
    WITH FRAME Dialog-Frame.
  END.
end.
run fill-codes IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.
PROCEDURE proc-b-host :
define VARIABLE v-host-code LIKE ub.sysconf.host-code no-undo .
define variable v-rid-list as character no-undo .
define buffer buf_clients  for ub.clients.
  do
  on error undo, return error
  :
        run adm/sconfs.w (
              input parParentProc
            , input "b-sel":U
            , input no
            , input v-cntxt-host-code-obj
            , output v-host-code
            , input-output v-rid-list
        ) no-error.
      IF v-rid-list = '':U THEN RETURN NO-APPLY.
      FIND FIRST buf_clients NO-LOCK WHERE
                 buf_clients.obj-code = v-host-code
              AND buf_clients.obj-type = 'орг':U NO-ERROR.
      if not available buf_clients then do:
           return error.
      end.
      assign
      f-host-CODE = v-host-code
      f-host-name = buf_clients.obj-name
      .
      DISPLAY
      f-host-code
      f-host-name
      WITH FRAME Dialog-Frame.
  end.
run fill-codes IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.
PROCEDURE proc-b-obj :
define variable v-rid-list as character no-undo .
define buffer buf_clients  for ub.clients.
  do
  on error undo, return error
  :
       run ref/cli-all.w (
                 INPUT parparentproc
                ,INPUT "b-sel"
                ,INPUT 'объект':U
                ,INPUT 'все':U
                ,INPUT 'текущие':U
                ,INPUT ?
                ,INPUT ",,,,,,NO,,"
                ,INPUT "lock-cli-type"
                ,output v-rid-list ) NO-ERROR.
     IF v-rid-list = '':U THEN RETURN error.
      FIND FIRST buf_clients NO-LOCK WHERE
          RECID( buf_clients) = INTEGER( v-rid-list ) NO-ERROR.
      if not available buf_clients then do:
           return error.
      end.
      assign
      f-obj-CODE = buf_clients.obj-code
      CB-obj-type = buf_clients.obj-type
      f-obj-name = buf_clients.obj-name
      .
      DISPLAY
      f-obj-code
      cb-obj-type
      f-obj-name
      WITH FRAME Dialog-Frame.
  end.
run fill-codes IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.
PROCEDURE proc-save :
define variable psw-buf as character no-undo .
DEFINE BUFFER buf_clients for ub.clients.
DEFINE BUFFER buf_db     FOR ub.db.
DEFINE BUFFER buf_sysconf     FOR ub.sysconf.
ASSIGN FRAME Dialog-Frame
f-db-num when (f-db-num:visible in frame Dialog-Frame
               and p-mode <> 'ПРОСМОТР':U)
f-host-code when (f-host-code:visible in frame Dialog-Frame
               and p-mode <> 'ПРОСМОТР':U)
CB-obj-type when (cb-obj-type:visible in frame Dialog-Frame
               and p-mode <> 'ПРОСМОТР':U)
f-obj-code when (f-obj-code:visible in frame Dialog-Frame
               and p-mode <> 'ПРОСМОТР':U)
f-staff-code
f-date-start WHEN f-date-start:SENSITIVE IN FRAME Dialog-Frame
f-date-end   WHEN (f-date-end:visible IN FRAME Dialog-Frame
                  and
                  f-date-end:SENSITIVE IN FRAME Dialog-Frame)
.
if f-date-start:sensitive IN FRAME Dialog-Frame
and f-date-end:SENSITIVE IN FRAME Dialog-Frame then do:
  if f-date-end < f-date-start then do:
    message
    "Дата начала работы в данной поли должна быть не больше  даты конца работы в данной роли!"
    view-as alert-box error .
    apply "ENTRY" to f-date-end.
    return error.
  end.
end.
IF f-password:VISIBLE IN FRAME Dialog-Frame THEN DO:
    ASSIGN
    f-password.
    if f-password = '' or f-password = ? then do:
        message
        "Пароль НЕ заполнен!"
        view-as alert-box ERROR .
        apply "ENTRY":U to f-password IN frame Dialog-Frame.
        return error.
    end.
    if integer(f-password) < 1000 or integer(f-password) > 32767 then do:
        message
        "Пароль должен быть от 1000 до 32767!"
        view-as alert-box ERROR .
        apply "ENTRY":U to f-password IN frame Dialog-Frame.
        return error.
    end.
    if p-password-option > 1
    or f-password <> '':U
    then do:
      run ref/per-pswd.w ( output psw-buf ) .
      if f-password <> psw-buf then do:
        message
        "Пароль НЕ подтвержден!"
        view-as alert-box ERROR .
        apply "ENTRY":U to f-password IN frame Dialog-Frame.
        return error.
      end.
   end.
END.
CASE p-level:
    WHEN 'db':U THEN DO:
       FIND FIRST buf_db NO-LOCK WHERE
               buf_db.db-num = f-db-num NO-ERROR.
       IF NOT AVAILABLE buf_db THEN DO:
          MESSAGE
          "Неверный номер БД"
          VIEW-AS ALERT-BOX.
          UNDO, RETURN ERROR.
       END.
    END.
    WHEN 'firm':U THEN DO:
        find FIRST buf_sysconf NO-LOCK WHERE
            buf_sysconf.host-code = f-host-code  NO-ERROR.
        IF NOT AVAILABLE buf_sysconf THEN DO:
            MESSAGE
            "Неверный номер фирмы"
            VIEW-AS ALERT-BOX.
            UNDO, RETURN ERROR.
        END.
    END.
    WHEN 'object':U THEN DO:
        find FIRST buf_clients NO-LOCK WHERE
            buf_clients.obj-type = cb-obj-type
        AND buf_clients.obj-code = f-obj-code NO-ERROR.
        IF NOT AVAILABLE buf_clients THEN DO:
            MESSAGE
            "Неверный номер объекта"
            VIEW-AS ALERT-BOX.
            UNDO, RETURN ERROR.
        END.
        IF NOT (buf_clients.obj-type = 'маг':U
                OR
                buf_clients.obj-type = 'скл':U)
                THEN DO:
            message
            "Неверный тип объекта"
            VIEW-AS ALERT-BOX.
            UNDO, RETURN ERROR.
        END.
    END.
END CASE.
END PROCEDURE.
