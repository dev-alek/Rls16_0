block-level on error undo, throw.
define input parameter p-install as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: frcnwsdr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/frcnwsdr.p $":U .
define variable vss-description as character no-undo init "Форсированная передача правил скидок, созданных в процессе upgrade".
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
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
~
run utl/startrun.w ( input this-procedure:handle
                   , input "main-proc"
                   , input "no"
                   , input "Форсированная передача правил скидок, созданных в процессе upgrade").
procedure main-proc :
define input parameter p-handle-callback    as handle    no-undo .
define input parameter p-parameters as character no-undo .
define buffer buf_code-range for ub.code-range.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_c-dis-rule for ub.c-dis-rule.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_dis-cp-rule for ub.dis-cp-rule.
define buffer buf_Dis-card-type for ub.dis-card-type.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_rule-call-param for ub.rule-call-param.
define variable v-start-rule-num as integer no-undo extent 5.
define variable v-end-rule-num as integer no-undo extent 5.
define variable v-stop-run  as logical   no-undo .
define variable v-pause-run as logical   no-undo .
define variable v-error-ind  as integer   no-undo .
define variable v-warn-ind   as integer   no-undo .
define variable kk as integer no-undo .
define variable v-rule-address as integer no-undo .
define variable p-install as logical no-undo .
define variable acc as integer no-undo .
define variable need-acc as integer no-undo .
define variable v-attr-code as character no-undo extent 4.
define variable v-attr-code2 as character no-undo extent 4.
define buffer buf_rep-start for ub.rep.
define buffer buf_rep-end for ub.rep.
define buffer buf_clients for ub.clients.
  main-block:
  do
  on error undo, return error
  :
  assign
  p-install = if entry(1, p-parameters, chr(4)) = "yes" then yes else no
  .
  if not p-install then do:
    message
    "Вы уверены, что хотите запустить пересылку данных по правилам скидок по новостям"
    view-as alert-box question buttons yes-no update loc#log as logical  .
    if not loc#log then return.
  end.
  if valid-handle(p-handle-callback)
  and p-handle-callback :get-signature('callback-set-start-run-time') <> ""
  then do:
    run callback-set-start-run-time in p-handle-callback .
  end.
  do kk = 1 to 4 :
    CASE kk:
      when 1 then do:
        assign
        v-rule-address = 061112030
        .
      end.
      when 2 then do:
        assign
        v-rule-address = 060811070
        .
      end.
      when 3 then do:
        assign
        v-rule-address = 061211050
        .
      end.
      when 4 then do:
        assign
        v-rule-address = 061213060
        .
      end.
     END CASE.
    run read-rule-num in this-procedure (input v-rule-address, 0, output v-start-rule-num[kk], buffer buf_rep-start).
    run read-rule-num in this-procedure (input v-rule-address + 1, 1, output v-end-rule-num[kk],  buffer buf_rep-end).
    assign
    need-acc = need-acc + v-end-rule-num[kk] - v-start-rule-num[kk]
    .
  end.
  do kk = 1 to 4 :
    _buf_dis-rule:
    for each buf_dis-rule no-lock
    :
      if buf_dis-rule.rule-num <= v-start-rule-num[kk]
      OR buf_dis-rule.rule-num >  v-end-rule-num[kk]
      or buf_dis-rule.upper-rule-num > 99999
      then next _buf_dis-rule.
      find first buf_code-range no-lock where
                buf_code-range.range-type = 'drgb':U
           and  buf_code-range.first-code >= buf_Dis-rule.rule-num
           and  buf_code-range.last-code <= buf_Dis-rule.rule-num
           and  buf_code-range.db-num = g#db-num no-error.
      if not available buf_Code-range then next _buf_dis-rule.
      process events.
      if valid-handle(p-handle-callback)
      and p-handle-callback :get-signature('callback-check-stop-run') <> ""
      then do:
        run callback-check-stop-run in p-handle-callback
          (output v-stop-run
          ,output v-pause-run
          ) .
        if v-stop-run = true
        then do:
          define variable v-ok as logical   no-undo .
          message
            "Завершить процесс пересылки?"
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok = true
          then do:
            leave _buf_dis-rule .
          end.
        end.
        if v-pause-run = true
        then do:
          message
            "Нажмите ОК, чтобы продолжить процесс пересылки" skip
            view-as alert-box information .
        end.
      end.
      assign
      acc = acc + 1.
      if valid-handle(p-handle-callback)
      and p-handle-callback :get-signature('callback-display-run') <> ""
      then do:
        run callback-display-run in p-handle-callback
          (input acc
          ,input need-acc - acc
          ,input v-error-ind + v-warn-ind
          ) .
      end.
      run str/callnews.p
          (input 'dis-rule':U
          ,input (buffer buf_dis-rule:handle)
          )  no-error .
      if error-status:error then do:
        run write-log in this-procedure (
                                          input substitute("Ошибка при пересылке по СПН записи правила скидок: " + chr(10) +
                                                          "номер правила &1", buf_dis-rule.rule-num)
                                        ,input p-handle-callback).
        assign
          v-error-ind = v-error-ind + 1
        .
        undo _buf_dis-rule, next  _buf_dis-rule .
      end.
      if (buf_dis-rule.templ-rl-root >= 57
      and buf_dis-rule.templ-rl-root <= 66)
      or  (buf_dis-rule.templ-rl-root >= 69
      and buf_dis-rule.templ-rl-root <= 71)
      then do:
        for each buf_dis-dct-rule no-lock where
                buf_dis-dct-rule.rule-num = buf_dis-rule.rule-num,
            first buf_dis-card-type no-lock where
                buf_dis-card-type.type = buf_dis-dct-rule.type
            and buf_dis-card-type.emitent-host-code = buf_dis-dct-rule.emitent-host-code
         on error undo, next:
            run str/callnews.p
                (input 'dis-dct-rule':U
                ,input (buffer buf_dis-dct-rule:handle)
                )  no-error .
            if error-status:error then do:
              run write-log in this-procedure (
                                                input substitute("Ошибка при пересылке по СПН записи скидки на тип ДК: " + chr(10) +
                                                                "тип ДК &1 эмитент &2 номер правила &3"
                                                                , buf_dis-dct-rule.type
                                                                , buf_dis-dct-rule.emitent-host-code
                                                                , buf_dis-dct-rule.rule-num)
                                              ,input p-handle-callback).
              assign
                v-error-ind = v-error-ind + 1
              .
              undo _buf_dis-rule, next  _buf_dis-rule .
            end.
           for each buf_rule-by-call no-lock where
                   buf_rule-by-call.call_id = buf_dis-card-type.uniq-key-rec,
               each  buf_rule-call-param no-lock where
                  buf_rule-call-param.codex_id = buf_rule-by-call.codex_id
              and  buf_rule-call-param.ruleset_id = buf_rule-by-call.ruleset_id
              and buf_rule-call-param.call_id = buf_rule-by-call.call_id
                 :
             if  (buf_rule-call-param.param-name = "p-rule-num"
                   or
                 buf_rule-call-param.param-name = "p-prev-rule-num")
              and buf_rule-call-param.param-value-int = buf_dis-dct-rule.rule-num then do:
              run str/callnews.p
                  (input 'rule-call-param':U
                  ,input (buffer buf_rule-call-param:handle)
                  )  no-error .
              if error-status:error then do:
                run write-log in this-procedure (
                                                  input substitute("Ошибка при пересылке по СПН записи параметра вызова правла расетча алгоритма по ДК: " + chr(10) +
                                                                  "тип ДК &1 эмитент &2 параметр &3&4место вызова: кодекс &5 набор правил &6 порядок &7"
                                                                  , buf_dis-dct-rule.type
                                                                  , buf_dis-dct-rule.emitent-host-code
                                                                  , buf_rule-call-param.param-name
                                                                  , chr(10)
                                                                  , buf_rule-by-call.codex_id
                                                                  , buf_rule-by-call.ruleset_id
                                                                  , buf_rule-by-call.order_id
                                                                  )
                                                ,input p-handle-callback).
                assign
                  v-error-ind = v-error-ind + 1
                .
                undo _buf_dis-rule, next  _buf_dis-rule .
              end.
             end.
           end.
        end.
      end.
      if g#db-num = 0
      and kk = 1 then do:
        _dis-gds-rule:
        for each buf_dis-gds-rule no-lock where
                buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num:
          run str/callnews.p
              (input 'dis-gds-rule':U
              ,input (buffer buf_dis-gds-rule:handle)
              )  no-error .
          if error-status:error then do:
            run write-log in this-procedure (
                                              input substitute("Ошибка при пересылке по СПН записи скидки товара на объекте: " + chr(10) +
                                                              "товар &1 объект &2&3 номер правила &4"
                                                              , buf_dis-gds-rule.gds-code
                                                              , buf_dis-gds-rule.obj-type
                                                              , buf_dis-gds-rule.obj-code
                                                              , buf_dis-gds-rule.rule-num
                                                              )
                                            ,input p-handle-callback).
            assign
              v-error-ind = v-error-ind + 1
            .
            undo _buf_dis-rule, next  _buf_dis-rule .
          end.
        end.
      end.
      if g#db-num = 0
      and kk = 1 then do:
        _dis-dct-rule:
        for each buf_dis-dct-rule no-lock where
                buf_dis-dct-rule.rule-num = buf_dis-rule.rule-num:
          run str/callnews.p
              (input 'dis-dct-rule':U
              ,input (buffer buf_dis-dct-rule:handle)
              )  no-error .
          if error-status:error then do:
            run write-log in this-procedure (
                                              input substitute("Ошибка при пересылке по СПН записи скидки по типам ДК: " + chr(10) +
                                                              "тип карты &1 эмитент &2 правило скидки &3"
                                                              , buf_dis-dct-rule.type
                                                              , buf_dis-dct-rule.emitent-host-code
                                                              , buf_dis-dct-rule.rule-num
                                                              )
                                            ,input p-handle-callback).
            assign
              v-error-ind = v-error-ind + 1
            .
            undo _buf_dis-rule, next  _buf_dis-rule .
          end.
        end.
      end.
      if g#db-num = 0
      and kk = 3 then do:
        _dis-grp-rule:
        for each buf_dis-grp-rule no-lock where
                buf_dis-grp-rule.rule-num = buf_dis-rule.rule-num:
          run str/callnews.p
              (input 'dis-grp-rule':U
              ,input (buffer buf_dis-grp-rule:handle)
              )  no-error .
          if error-status:error then do:
            run write-log in this-procedure (
                                              input substitute("Ошибка при пересылке по СПН записи скидки по группам: " + chr(10) +
                                                              "классификатор &1 код группы &2 правило скидки &3"
                                                              , buf_dis-grp-rule.classif-type
                                                              , buf_dis-grp-rule.node-code
                                                              , buf_dis-grp-rule.rule-num
                                                              )
                                            ,input p-handle-callback).
            assign
              v-error-ind = v-error-ind + 1
            .
            undo _buf_dis-rule, next  _buf_dis-rule .
          end.
        end.
      end.
      if g#db-num = 0
      and kk = 4 then do:
        _dis-cp-rule:
        for each buf_dis-cp-rule no-lock where
                buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num:
          run str/callnews.p
              (input 'dis-cp-rule':U
              ,input (buffer buf_dis-cp-rule:handle)
              )  no-error .
          if error-status:error then do:
            run write-log in this-procedure (
                                              input substitute("Ошибка при пересылке по СПН записи скидки по типам касс. платежей: " + chr(10) +
                                                              "тип касс платежа &1 код валюты 2 правило скидки &3"
                                                              , buf_dis-cp-rule.cdpay-code
                                                              , buf_dis-cp-rule.curr-code
                                                              , buf_dis-cp-rule.rule-num
                                                              )
                                            ,input p-handle-callback).
            assign
              v-error-ind = v-error-ind + 1
            .
            undo _buf_dis-rule, next  _buf_dis-rule .
          end.
        end.
      end.
      for each buf_c-dis-rule no-lock where
              buf_c-dis-rule.rule-num = buf_dis-rule.rule-num
          AND buf_c-dis-rule.corr-user-db-num   = g#db-num:
        if buf_c-dis-rule.corr-user-name = 'upgrade':U then do:
          run str/callnews.p
              (input 'c-dis-rule':U
              ,input (buffer buf_c-dis-rule:handle)
              )  no-error .
          if error-status:error then do:
            run write-log in this-procedure (
                                              input substitute("Ошибка при пересылке по СПН записи истории правила скидок: " + chr(10) +
                                                              "номер правила &1", buf_dis-rule.rule-num)
                                            ,input p-handle-callback).
            assign
              v-error-ind = v-error-ind + 1
            .
            undo _buf_dis-rule, next  _buf_dis-rule .
          end.
          else do:
          if available buf_rep-start then do:
            buf_rep-start.name1 = string(buf_dis-rule.rule-num).
            .
          end.
          end.
        end.
      end.
    end.
  end.
  FOR EACH buf_rule-call-param NO-LOCK
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if  not (buf_rule-call-param.param-name = "p-rule-num"
          or
        buf_rule-call-param.param-name = "p-prev-rule-num")
    and buf_rule-call-param.param-value-int = buf_dis-dct-rule.rule-num then do:
      run str/callnews.p ( input 'rule-call-param':U
                          ,input buffer buf_rule-call-param:handle).
    end.
  END.
  if valid-handle(p-handle-callback)
  and p-handle-callback :get-signature('callback-display-run') <> ""
  then do:
    run callback-display-run in p-handle-callback
      (input acc
      ,input need-acc - acc
      ,input v-error-ind + v-warn-ind
      ) .
  end.
end.
if not p-install then do:
  message "Завершилась утилита пересылки правил скидок"
  view-as alert-box .
end.
end procedure.
procedure read-rule-num :
  define input parameter p-repnum as integer no-undo .
  define input parameter p-start-end as integer no-undo .
  define output parameter p-rule-num as integer no-undo .
  define parameter buffer buf_rep for ub.rep.
  do
  on error undo, return error
  :
    find buf_rep
      where buf_rep.rep-num = p-repnum
      no-error
    .
    if not available buf_rep then do:
      assign
      p-rule-num = (if p-start-end = 0 then 0 else current-value(s-drgb-code, ub))
      .
      return .
    end.
    assign
    p-rule-num = integer(buf_rep.name1) no-error.
    if error-status:error then do:
      assign
      p-rule-num = (if p-start-end = 0 then 0 else current-value(s-drgb-code, ub))
      .
      release buf_rep.
    end.
    if p-start-end = 1 then release buf_rep.
  end.
end procedure.
procedure write-log :
  do
  on error undo, return error
  :
    define input parameter p-message   as character no-undo .
    define input parameter p-call-back as handle    no-undo .
    if  valid-handle(p-call-back)
    and lookup('callback-write-to-log', p-call-back :internal-entries) > 0
    and p-call-back <> this-procedure :handle
    then do:
      run callback-write-to-log in p-call-back
        (input p-message
        ) no-error .
    end.
  end.
end procedure.
