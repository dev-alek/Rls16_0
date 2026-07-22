block-level on error undo, throw.
define parameter buffer buf_dis-rule for ub.dis-rule .
define input parameter p-sts-mode as logical no-undo .
define input parameter p-silent                       as logical no-undo .
define output parameter p-can                         as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-rul3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dis-rul3.p $":U .
define variable vss-description as character no-undo init "Физическое удаление правила скидок и проверка возможности выключения".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dr-code :
  do
  on error undo, return error
  :
    define input  parameter  p-templ-rl-root     like ub.dis-rule.templ-rl-root     no-undo .
    define output parameter  p-des               like ub.dis-rule.des               no-undo .
    define output parameter  p-discnt-type       like ub.dis-rule.discnt-type       no-undo .
    define output parameter  p-subject-type      like ub.dis-rule.subject-type      no-undo .
    define output parameter  p-value-type        like ub.dis-rule.value-type        no-undo .
    define output parameter  p-level-1           as character no-undo .
    define output parameter  p-level-2           as character no-undo .
    define output parameter  p-global             as integer no-undo .
    define output parameter  p-host               as integer no-undo .
    define output parameter  p-object             as integer no-undo .
    define output parameter  p-output-display as logical   no-undo .
    define output parameter  p-tree           as char  no-undo .
    define output parameter  p-other          as character no-undo .
    define variable v-other as character no-undo .
    define buffer buf_dis-rule for ub.dis-rule .
    define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-templ-rl-root no-error.
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.templ-rl-root = buf_dis-rule.templ-rl-root
        and buf_dis-cfg-rule.pos-type = '':U
        and buf_dis-cfg-rule.table-name = '':U
        and buf_dis-cfg-rule.discnt-role = '':U
        and buf_dis-cfg-rule.self-nonunique = '':U
            no-error.
    if not available buf_Dis-cfg-rule then do:
        undo, return error substitute("неизвестный шаблон скидки &1", p-templ-rl-root ).
    end.
    assign
    p-des = buf_dis-rule.des
    p-discnt-type = buf_dis-rule.discnt-type
    p-subject-type = buf_dis-rule.subject-type
    p-value-type = buf_dis-rule.value-type
    p-global = (if available buf_dis-cfg-rule
                then buf_dis-cfg-rule.has-global
                else 0)
    p-host = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-host
              else 0)
    p-object = (if available buf_dis-cfg-rule
              then buf_dis-cfg-rule.has-obj
              else 0)
    p-output-display = (buf_dis-rule.sts = integer('0':U))
    p-tree = buf_Dis-rule.uniq-field
    p-other = buf_dis-rule.other-inf
    p-level-1 = entry(1, buf_dis-cfg-rule.other-inf, ";":U)
    p-level-2 = (if num-entries(buf_dis-cfg-rule.other-inf, ";":U) > 1
                 then entry(2, buf_dis-cfg-rule.other-inf, ";":U)
                 else '')
    .
  end.
end procedure.
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.
end procedure.
~
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
define variable  v-des               like ub.dis-rule.des               no-undo .
define variable  v-level-1           as character no-undo .
define variable  v-level-2           as character no-undo .
define variable  v-discnt-type       like ub.dis-rule.discnt-type       no-undo .
define variable  v-subject-type      like ub.dis-rule.subject-type      no-undo .
define variable  v-value-type        like ub.dis-rule.value-type        no-undo .
define variable  v-global            as integer no-undo .
define variable  v-host              as integer no-undo .
define variable  v-object            as integer no-undo .
define variable  v-output-display    as logical   no-undo .
define variable  v-tree              as character no-undo .
define variable  v-other             as character no-undo .
define variable  v-entry             as character no-undo .
define variable  ii as integer no-undo .
define variable v-dis-gds-rule-log as logical   no-undo .
define variable v-dis-dc-rule-log as logical   no-undo .
define variable v-dis-dct-rule-log as logical   no-undo .
define variable v-dis-grp-rule-log as logical   no-undo .
define variable v-dis-cp-rule-log as logical   no-undo .
define variable v-dis-some-rule-log as logical   no-undo .
define variable v-dis-thbj-rule-log as logical no-undo .
define variable v-found as logical no-undo .
define variable v-db-num like ub.db.db-num  no-undo .
define variable v-ret-mess as character no-undo .
define buffer buf_clients-obj for ub.clients.
define buffer buf_db for ub.db.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_dis-some-rule for ub.dis-some-rule.
define buffer buf2_dis-rule for ub.dis-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
define buffer buf_Dis-cfg-rule for ub.dis-cfg-rule.
do
on error undo, return error return-value
:
  if buf_dis-rule.rule-num <= 99999
  and not p-sts-mode
  then do:
    run err-mess in this-procedure ( substitute("Нельзя удалять запись ШАБЛОНОВ СКИДОК"), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.
  if buf_dis-rule.upper-rule-num > 99999 then do:
    run err-mess in this-procedure ( substitute("Нельзя удалять или выключать детализированную запись ПРАВИЛА СКИДОК"), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.
  if
  g#db-num <> 0
  and not g#news
  and (buf_dis-rule.host-code = 0
  or   buf_dis-rule.obj-type = "":U
  or   buf_dis-rule.obj-code = 0)
  then do:
    run err-mess in this-procedure ( substitute("Нельзя удалять или выключать глобальную запись ПРАВИЛА СКИДКИ или запись по фирме в УБД:&1" +
                            "номер текущей БД &2"
                             , chr(10)
                             , g#db-num), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "host-code":U).
  end.
  run dr-code  in this-procedure (
      input  buf_dis-rule.templ-rl-root
      ,output v-des
      ,output v-discnt-type
      ,output v-subject-type
      ,output v-value-type
      ,output v-level-1
      ,output v-level-2
      ,output v-global
      ,output v-host
      ,output v-object
      ,output v-output-display
      ,output v-tree
      ,output v-other
                                ) no-error .
  if error-status:error then do:
      run err-mess in this-procedure ( substitute("Неверный номер шаблона для скидки: &1, &2", buf_Dis-rule.templ-rl-root, return-value), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "rule-num":U).
  end.
  do ii = 1 to num-entries(v-other, ";":U):
    assign
    v-entry = entry(ii, v-other, ";")
    .
    assign
    v-dis-gds-rule-log = (v-entry =  'dis-gds-rule':U)
    v-dis-cp-rule-log = (v-entry = 'dis-cp-rule':U)
    v-dis-dc-rule-log = (v-entry = 'dis-dc-rule':U)
    v-dis-dct-rule-log = (v-entry = 'dis-dct-rule':U)
    v-dis-grp-rule-log = (v-entry = 'dis-grp-rule':U)
    v-dis-some-rule-log = (v-entry = 'dis-some-rule':U)
    v-dis-thbj-rule-log = (v-entry = 'dis-thbj-rule':U)
    .
  end.
  if buf_dis-rule.obj-code > 0 then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_dis-rule.obj-type
  ,input  buf_dis-rule.obj-code
  ,output v-db-num
  )  .
    if (v-db-num <> g#db-num and g#db-num > 0) then do:
      run err-mess in this-procedure ( substitute("Нельзя удалять или выключать запись ПРАВИЛА СКИДКИ на объекте в чужой УБД: ~
                              номер текущей БД &1, номер БД для &2&3: &4"
                              , g#db-num
                              , buf_dis-rule.obj-type
                              , buf_dis-rule.obj-code
                              , v-db-num
                              ), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "obj-code":U).
    end.
  end.
  if not p-sts-mode
  then do:
    if buf_dis-rule.obj-code = 0
    and buf_dis-rule.obj-type = "":U then do:
      find first buf_db no-lock where
                buf_db.db-num > 0 no-error.
      if available buf_db then do:
        if buf_dis-rule.sts <> integer('99':U) then do:
          run err-mess in this-procedure ( substitute("Нельзя удалять глобальную запись ПРАВИЛА СКИДКИ в системе с УБД"), output v-ret-mess).
        undo, return error (if p-silent then v-ret-mess else "":U).
      end.
    end.
  end.
  end.
  run waitfram-show in this-procedure ( "Ждите .. Проводится проверка возможности удаления/выключения правила" ).
  if v-dis-thbj-rule-log then do:
    _dis-thbj-rule:
    for each buf_dis-thbj-rule no-lock where
         buf_dis-thbj-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-thbj-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-thbj-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-thbj-rule.pos-type
          and (buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-thbj-rule.time-templ-rl-root
              or
              (buf_dis-rule.is-term = no and lookup("time-rule-num", v-level-2) > 0)
              )
          and buf_Dis-cfg-rule.discnt-role = buf_dis-thbj-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop > integer('0':U):
      assign
      v-found = yes
      .
      leave _dis-thbj-rule.
    end.
    define variable v-can as logical   no-undo .
    define buffer buf_drt-prop for ub.drt-prop.
    if v-found
    then do:
      find first buf_drt-prop no-lock where
      buf_drt-prop.templ-rl-root = buf_dis-rule.templ-rl-root
      and buf_drt-prop.upper-prop-code = "can-update"
      and buf_drt-prop.prop-code = "can" no-error.
      if available buf_drt-prop
      and integer(buf_drt-prop.property-value) > 0 then do:
        if integer(buf_drt-prop.property-value) >= 2 then do:
          v-found = no.
        end.
        if integer(buf_drt-prop.property-value) < 2 then do:
          find first buf_drt-prop no-lock where
          buf_drt-prop.templ-rl-root = buf_dis-rule.templ-rl-root
          and buf_drt-prop.upper-prop-code = "can-update"
          and buf_drt-prop.prop-code = "can-message" no-error.
          if available buf_drt-prop
          and not p-silent
          then do:
            message
            buf_drt-prop.property-value
            view-as alert-box question buttons yes-no update v-can.
            if v-can then do:
              v-found = no.
            end.
          end.
        end.
      end.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя удалять или выключать запись ПРАВИЛА СКИДКИ: &1" +
                              "с ней связана ОБЩАЯ СКИДКА НА ОБЪЕКТЕ: &2&3"
                              , chr(10)
                              , buf_dis-thbj-rule.obj-type
                              , buf_dis-thbj-rule.obj-code
                              )
                               , output v-ret-mess
                              ).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-gds-rule-log then do:
    _dis-gds-rule:
    for each buf_dis-gds-rule no-lock where
         buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-gds-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-gds-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-gds-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-gds-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer('0':U):
      assign
      v-found = yes
      .
      leave _dis-gds-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя удалять или выключать запись ПРАВИЛА СКИДКИ: &1" +
                              "с ней связана СКИДКА ТОВАРА НА ОБЪЕКТЕ: &2&3 товар &4"
                              , chr(10)
                              , buf_dis-gds-rule.obj-type
                              , buf_dis-gds-rule.obj-code
                              , buf_dis-gds-rule.gds-code
                              )
                               , output v-ret-mess
                              ).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-cp-rule-log then do:
    _dis-cp-rule:
    for each buf_dis-cp-rule no-lock where
           buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-cp-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-cp-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-cp-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-cp-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-cp-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer('0':U):
      assign
      v-found = yes
      .
      leave _dis-cp-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме: &1" +
                              "с ней связана СКИДКА ТИПА КАССОВОГО ПЛАТЕЖА: ПЛАТЕЖ &2 ВАЛЮТА &3 тип скидки &4 фирма &5 объект &6&7"
                              , chr(10)
                              , buf_dis-cp-rule.cdpay-code
                              , buf_dis-cp-rule.curr-code
                              , entry (lookup (buf_dis-cp-rule.discnt-role, 'simple-pay,qnty-pay':u) + 1, ',' + 'Скидка при оплате,Скидка на количество при оплате':u)
                              , buf_dis-cp-rule.host-code
                              , buf_dis-cp-rule.obj-type
                              , buf_dis-cp-rule.obj-code
                              )
                              , output v-ret-mess).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-dc-rule-log then do:
    _dis-dc-rule:
    for each buf_dis-dc-rule no-lock where
           buf_dis-dc-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-dc-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-dc-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-dc-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-dc-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-dc-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer('0':U):
      assign
      v-found = yes
      .
      leave _dis-dc-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме: &1" +
                              "с ней связана СКИДКА ДК: ДК &2 тип скидки &3 &4 фирма &5 объект &6&7"
                              , chr(10)
                              , buf_dis-dc-rule.d-card
                              , entry (lookup (buf_dis-dc-rule.discnt-role, 'debet-pay-pcnt-disc,debet-pay-abs-disc,debet-pay-qnty-disc,debet-pay-sum-disc,debet-pay-free-disc,dc-d-pcnt,dc-cash-d-pcnt,credit-pay-pcnt-disc,credit-pay-abs-disc,credit-pay-qnty-disc,credit-pay-sum-disc,credit-pay-free-disc':u) + 1, ',' + '% Скидка при оплате топлива по дебет.ведомости,ABS Скидка при оплате топлива по дебет.ведомости,Скидка на кол-во при оплате топлива по дебет.ведомости,Скидка на сумму при оплате топлива по дебет.ведомости,Своб скидка при оплате топлива по дебет.ведомости,% скидка на товар по ДК,% скидка на итог чека по ДК,% Скидка при оплате топлива по кредит.ведомости,Abs Скидка при оплате топлива по кредит.ведомости,Скидка на кол-во при оплате топлива по кредит.ведомости,Скидка на сумму при оплате топлива по кредит.ведомости,Своб Скидка на сумму при оплате топлива по кредит.ведомости':u)
                              , buf_dis-dc-rule.host-code
                              , buf_dis-dc-rule.obj-type
                              , buf_dis-dc-rule.obj-code
                              )
                              , output v-ret-mess).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-dct-rule-log then do:
    _dis-dct-rule:
    for each buf_dis-dct-rule no-lock where
           buf_dis-dct-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-dct-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-dct-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-dct-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-dct-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-dct-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer('0':U):
      assign
      v-found = yes
      .
      leave _dis-dct-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме: &1" +
                              "с ней связана СКИДКА ТИПА ДК: эмитент &2 тип &3 тип скидки &4 &5 фирма &6 объект &7&8"
                              , chr(10)
                              , buf_dis-dct-rule.emitent-host-code
                              , buf_dis-dct-rule.type
                              , entry (lookup (buf_dis-dct-rule.discnt-role, 'calc-d-pcnt,calc-cash-d-pcnt,calc-categ,dis-tot-flag,def-categ,def-pcnt,def-cash-pcnt':u) + 1, ',' + 'Расчет %скидки ДК на товар,Расчет %скидки ДК на итог,Расчет категории ДК,Участие в итогах по ДК,Категория ДК по умолчанию,% скидки ДК на товар по умолч.,% скидки ДК на итог по умолч.':u)
                              , buf_dis-dct-rule.host-code
                              , buf_dis-dct-rule.obj-type
                              , buf_dis-dct-rule.obj-code
                              )
                              , output v-ret-mess).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end.
  if v-dis-grp-rule-log then do:
    _dis-grp-rule:
    for each buf_dis-grp-rule no-lock where
           buf_dis-grp-rule.rule-num = buf_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-grp-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-grp-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-grp-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-grp-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-grp-rule.discnt-role
          and buf_Dis-cfg-rule.self-nonunique = buf_Dis-grp-rule.classif-type
          and buf_Dis-cfg-rule.link-prop = integer('0':U):
      assign
      v-found = yes
      .
      leave _dis-grp-rule.
    end.
    if v-found then do:
      run waitfram-hide in this-procedure .
      run err-mess in this-procedure ( substitute("Нельзя изменять/добавлять глобальную запись ПРАВИЛА СКИДКИ или запись по фирме: &1" +
                              "с ней связана СКИДКА НА ГРУППУ: группа &2 тип скидки &3 &4 фирма &5 объект &6&7"
                              , chr(10)
                              , buf_dis-grp-rule.node-code
                              , entry (lookup (buf_dis-grp-rule.discnt-role, 'gds-grp-pcnt,gds-grp-pcnt-kat,gds-grp-abs,gds-grp-qnty,gds-grp-sum':u) + 1, ',' + '% скидка на группу товара,% скидка на группу товара для кат.клиентов,Abs скидка на группу товара,% Скидка на группу товара по кол-ву,% Скидка на группу товара на сумму':u)
                              , buf_dis-grp-rule.host-code
                              , buf_dis-grp-rule.obj-type
                              , buf_dis-grp-rule.obj-code
                              )
                              , output v-ret-mess).
      return (if p-silent then v-ret-mess else "":U).
    end.
  end.
  run waitfram-hide in this-procedure .
  if p-sts-mode then do:
     p-can = yes.
     return.
  end.
  for each buf2_dis-rule where
          buf2_dis-rule.upper-rule-num = buf_dis-rule.rule-num
  on error undo, return error :
    if v-dis-gds-rule-log then do:
      for each buf_dis-gds-rule share-lock where
              buf_dis-gds-rule.rule-num = buf2_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-gds-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-gds-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-gds-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-gds-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer('0':U)
      on error undo, return error :
        delete buf_dis-gds-rule.
      end.
    end.
    if v-dis-cp-rule-log then do:
      for each buf_dis-cp-rule share-lock where
              buf_dis-cp-rule.rule-num = buf2_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-cp-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-cp-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-cp-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-cp-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-cp-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer('0':U)
      on error undo, return error :
        delete buf_dis-cp-rule.
      end.
    end.
    if v-dis-dc-rule-log then do:
      for each buf_dis-dc-rule share-lock where
              buf_dis-dc-rule.rule-num = buf2_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-dc-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-dc-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-dc-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-dc-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-dc-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer('0':U)
      on error undo, return error :
        delete buf_dis-dc-rule.
      end.
    end.
    if v-dis-dct-rule-log then do:
      for each buf_dis-dct-rule share-lock where
              buf_dis-dct-rule.rule-num = buf2_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-dct-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-dct-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-dct-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-dct-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-dct-rule.discnt-role
          and buf_Dis-cfg-rule.link-prop = integer('0':U)
      on error undo, return error :
        delete buf_dis-dct-rule.
      end.
    end.
    if v-dis-grp-rule-log then do:
      for each buf_dis-grp-rule share-lock where
              buf_dis-grp-rule.rule-num = buf2_dis-rule.rule-num,
         first buf_dis-cfg-rule no-lock where
              buf_Dis-cfg-rule.table-name = 'dis-grp-rule':U
          and buf_Dis-cfg-rule.templ-rl-root = buf_dis-grp-rule.templ-rl-root
          and buf_Dis-cfg-rule.pos-type = buf_dis-grp-rule.pos-type
          and buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-grp-rule.time-templ-rl-root
          and buf_Dis-cfg-rule.discnt-role = buf_dis-grp-rule.discnt-role
          and buf_Dis-cfg-rule.self-nonunique = buf_Dis-grp-rule.classif-type
          and buf_Dis-cfg-rule.link-prop = integer('0':U)
      on error undo, return error :
        delete buf_dis-grp-rule.
      end.
    end.
    if v-dis-some-rule-log then do:
      for each buf_dis-some-rule share-lock where
              buf_dis-some-rule.rule-num = buf2_dis-rule.rule-num
      on error undo, return error :
        delete buf_dis-some-rule.
      end.
    end.
    delete buf2_dis-rule no-error .
    if error-status:error then do:
      run err-mess in this-procedure ( substitute("Ошибка при удалении ПРАВИЛА СКИДКИ №&1: &2 &3", buf2_dis-rule.rule-num, error-status:get-message(1), return-value  ), output v-ret-mess).
      undo, return error (if p-silent then v-ret-mess else "":U).
    end.
  end.
  for each buf_dis-thbj-rule exclusive-lock where
          buf_dis-thbj-rule.rule-num = buf_dis-rule.rule-num,
  first buf_dis-cfg-rule no-lock where
      buf_Dis-cfg-rule.table-name = 'dis-thbj-rule':U
  and buf_Dis-cfg-rule.templ-rl-root = buf_dis-thbj-rule.templ-rl-root
  and buf_Dis-cfg-rule.pos-type = buf_dis-thbj-rule.pos-type
  and (buf_Dis-cfg-rule.time-templ-rl-root = buf_dis-thbj-rule.time-templ-rl-root
      or (buf_dis-thbj-rule.time-templ-rl-root = 0
          and
          lookup("time-rule-num", v-level-2) > 0))
  and buf_Dis-cfg-rule.discnt-role = buf_dis-thbj-rule.discnt-role
  on error  undo,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    if buf_Dis-cfg-rule.link-prop = integer('0':U)
    then do:
      define buffer buf2_dis-cfg-rule for ub.dis-cfg-rule.
      define buffer buf2_dis-thbj-rule for ub.dis-thbj-rule.
      for each buf2_dis-cfg-rule no-lock where
          buf2_Dis-cfg-rule.table-name = 'dis-thbj-rule':U
      and buf2_Dis-cfg-rule.pos-type = buf_dis-thbj-rule.pos-type
      and buf2_Dis-cfg-rule.discnt-role = buf_dis-thbj-rule.discnt-role
      and buf2_Dis-cfg-rule.link-prop = integer('3':U),
         each buf2_dis-thbj-rule where
             buf2_dis-thbj-rule.templ-rl-root = buf2_dis-cfg-rule.templ-rl-root
         and buf2_dis-thbj-rule.pos-type = buf2_dis-cfg-rule.pos-type
         and buf2_dis-thbj-rule.discnt-role = buf2_dis-cfg-rule.discnt-role
         and buf2_dis-thbj-rule.rule-num = buf_dis-rule.key#_one
      on error  undo,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo, return error substitute( "&1. stop", vss-workfile )
      on endkey undo, return error substitute( "&1. endkey", vss-workfile )
      :
        delete buf2_dis-thbj-rule.
      end.
      delete buf_dis-thbj-rule.
    end.
  end.
  for each buf2_dis-rule where
          buf2_dis-rule.rl-root = buf_dis-rule.rule-num
  on error undo, return error
  on stop undo, return error :
    if buf2_dis-rule.rule-num = buf_dis-rule.rule-num then next.
    delete buf2_dis-rule.
  end.
  delete buf_dis-rule no-error.
  if error-status:error then do:
    run err-mess in this-procedure ( substitute("Ошибка при удалении ПРАВИЛА СКИДКИ №&1: &2 &3", buf_dis-rule.rule-num, error-status:get-message(1), return-value  ), output v-ret-mess).
    undo, return error (if p-silent then v-ret-mess else "":U).
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  CASE p-silent:
    when yes then do:
      p-ret-mess = substitute("ПРАВИЛО СКИДКИ №&1:&2&3", buf_dis-rule.rule-num, chr(10), p-mess).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
