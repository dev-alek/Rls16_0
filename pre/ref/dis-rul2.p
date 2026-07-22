block-level on error undo, throw.
define parameter buffer bf-dis-rule for ub.dis-rule.
define input parameter p-silent as logical no-undo .
define input parameter p-pos-type as character no-undo .
define input-output parameter par-sts like ub.dis-rule.sts no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dis-rul2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dis-rul2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса правил скидок".
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
DEFINE TEMP-TABLE tt0-term_dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE VARIABLE loc#log as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE varold-sts like ub.dis-rule.sts no-undo .
define variable v-rule-num like ub.dis-rule.rule-num no-undo .
define variable v-mess as character no-undo .
define variable v-recid as recid no-undo .
define variable v-can as logical no-undo .
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
_main:
do
on error undo, return error return-value
:
find current bf-dis-rule exclusive-lock.
if bf-dis-rule.lvl-num > 1
or bf-dis-rule.upper-rule-num > 99999 then do:
  v-mess = substitute("Правило скидки №&1: невозможно изменить статус&2" +
                      "Менять статус можно только для неиспользуемых шаблонов скидок&2"  +
                      "и правил скидок уровня 1"
                      , bf-dis-rule.rule-num
                      ).
  if not p-silent then do:
    message
    v-mess
    view-as alert-box error .
  end.
  undo, return error (if p-silent then v-mess else '':U).
end.
varold-sts = bf-dis-rule.sts.
if par-sts = ? then do:
  CASE varold-sts:
    when integer('0':U) then do:
      assign
      par-sts = integer('1':U).
    end.
    when integer('1':U)
    or
    when integer('2':U)
    then do:
      assign
      par-sts = integer('0':U).
    end.
  END CASE.
end.
CASE par-sts:
  WHEN integer('0':U) then do:
    if integer('0':U) = bf-dis-rule.sts  then do:
      if p-silent then do:
        return ''.
      end.
      else do:
        message "Запись уже имеет статус ИСПОЛЬЗУЕТСЯ!"
        view-as alert-box ERROR.
        par-sts = ?.
        return error.
      end.
    end.
    else do:
      if p-silent then do:
        choice = yes.
      end.
      else  do:
        message
        "Запись не используется - восстановить?"
        view-as alert-box QUestion buttons YEs-no update choice.
      end.
    end.
  end.
  WHEN integer('1':U) then do:
    if integer('1':U) = bf-dis-rule.sts  then do:
      if p-silent then do:
        return ''.
      end.
      else do:
        message "Запись уже имеет статус НЕ ИСПОЛЬЗУЕТСЯ!"
        view-as alert-box ERROR.
        par-sts = ?.
        return error.
      end.
    end.
    else do:
      if p-silent then do:
        choice = yes.
      end.
      else do:
        message
        "Поставить статус НЕ ИСПОЛЬЗУЕТСЯ?" skip(0)
        (if bf-dis-rule.rule-num <= 99999
        then "Все правила скидок данного типа будут удалены!"
        else  '':U)
        view-as alert-box QUestion buttons yes-no update choice.
      end.
    end.
  end.
END CASE.
if choice then do:
  if bf-dis-rule.sts = integer('0':U)
  and bf-dis-rule.rule-num <= 99999
  then do:
      for each BUF_dis-rule where
              buf_dis-rule.upper-rule-num = bf-dis-rule.rule-num:
        v-rule-num = buf_dis-rule.rule-num.
        run ref/dis-rul3.p (
                        buffer buf_dis-rule
                       ,input no
                       ,input p-silent
                       ,output v-can
                       ) no-error .
      if error-status:error
      or not v-can
      then do:
          v-mess = substitute("Ошибка при удалении ПРАВИЛА СКИДОК №&1&2&3&2&4"
                              , buf_dis-rule.rule-num
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value ).
        if not p-silent then do:
          message
          v-mess
          view-as alert-box error .
        end.
          undo _main, return error (if p-silent then v-mess else '':U).
        end.
    end.
  end.
  else do:
    CASE par-sts:
      when integer('1':U) then do:
        run ref/dis-rul3.p (
                       buffer bf-dis-rule
                      ,input yes
                      ,input yes
                      ,output v-can
                      ) no-error.
      end.
      when integer('0':U) then do:
        v-recid = recid(bf-dis-rule).
        v-can = yes.
        if p-pos-type = ''
        or p-pos-type = ? then do:
          run ref/dcr-pos.p (
                             input 'ИЗМЕНЕНИЕ':U
                            ,input p-silent
                            ,input bf-dis-rule.templ-rl-root
                            ,input bf-dis-rule.host-code
                            ,input bf-dis-rule.obj-type
                            ,input bf-dis-rule.obj-code
                            ,input par-sts
                            ,input bf-dis-rule.rule-num
                            ,output p-pos-type) no-error.
          if error-status:error then do:
            v-mess = substitute("Ошибка при определении места действия ПРАВИЛА СКИДОК №&1&2&3&2&4"
                                    , v-rule-num
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value ).
            if not p-silent then do:
              message
              v-mess
              view-as alert-box error .
            end.
            undo _main, return error (if p-silent then v-mess else '':U).
          end.
        end.
        run ref/dis-rul1.p (
                       input bf-dis-rule.rule-num
                      ,input p-pos-type
                      ,input bf-dis-rule.templ-rl-root
                      ,input bf-dis-rule.templ-rl-root
                      ,input bf-dis-rule.des
                      ,input bf-dis-rule.dis-kat
                      ,input bf-dis-rule.discnt-type
                      ,input bf-dis-rule.doc-qnty
                      ,input bf-dis-rule.tot-sum
                      ,input bf-dis-rule.charkey_one
                      ,input bf-dis-rule.charkey_two
                      ,input bf-dis-rule.charkey_three
                      ,input bf-dis-rule.deckey_one
                      ,input bf-dis-rule.deckey_two
                      ,input bf-dis-rule.deckey_three
                      ,input bf-dis-rule.key#_one
                      ,input bf-dis-rule.key#_two
                      ,input bf-dis-rule.key#_three
                      ,input bf-dis-rule.subject-type
                      ,input bf-dis-rule.TIME-TEMPL-RL-ROOT
                      ,input bf-dis-rule.time-rule-num
                      ,input bf-dis-rule.upper-rule-num
                      ,input bf-dis-rule.value-type
                      ,input bf-dis-rule.host-code
                      ,INPUT bf-dis-rule.obj-type
                      ,INPUT bf-dis-rule.obj-code
                      ,INPUT bf-dis-rule.discnt-value
                      ,input table tt0-term_dis-rule
                      ,input-output v-recid
                      ,input 'ИЗМЕНЕНИЕ':U + chr(4) + 'sts'
                      ,input yes
                      ) no-error.
      end.
    END CASE.
    if error-status:error
    or not v-can
    then do:
      v-mess = substitute("ПРАВИЛО СКИДОК №&1 не может быть выключено/выключено &2&3&2&4"
                            , bf-dis-rule.rule-num
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value ).
     if not p-silent then do:
        message
        v-mess
        view-as alert-box error .
      end.
      undo _main, return error (if p-silent then v-mess else '':U).
    end.
  end.
  assign
  bf-dis-rule.sts = par-sts.
  v-rule-num = bf-dis-rule.rule-num.
  release bf-dis-rule no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранении записи ПРАВИЛА СКИДОК №&1&2&3&2&4"
                             , v-rule-num
                             , chr(10)
                             , error-status:get-message(1)
                             , return-value ).
    if not p-silent then do:
      message
      v-mess
      view-as alert-box error .
    end.
    undo _main, return error (if p-silent then v-mess else '':U).
  end.
  if par-sts = integer('1':U) then do:
    for each buf_dis-thbj-rule exclusive-lock where
            buf_dis-thbj-rule.rule-num = v-rule-num
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      delete buf_dis-thbj-rule.
    end.
  end.
end.
par-sts = ?.
end.
