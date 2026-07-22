DEFINE BUFFER locked_fin-bank FOR fin-bank.
DEFINE TEMP-TABLE tt-fin-bank NO-UNDO LIKE fin-bank.
DEFINE BUFFER X_clients FOR clients.
DEFINE BUFFER X_sysconf FOR sysconf.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-host-code like ub.fin-bank.host-code no-undo.
define input parameter p-code-bank like ub.fin-bank.code-bank no-undo.
define input-output parameter p-doc-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования банка".
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
define variable v-db-num like ub.db.db-num no-undo.
define variable v-tab-order as character no-undo .
define buffer X_curr_sysconf for ub.sysconf.
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
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-host-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-fin-bank SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-print AT ROW 1 COL 41
     B-hist AT ROW 1 COL 51
     B-Help AT ROW 1 COL 71
     tt-fin-bank.host-code AT ROW 2.5 COL 13 COLON-ALIGNED
          LABEL "Фирма" format 9999999999
          VIEW-AS FILL-IN
          SIZE 12.5 BY 1
     f-host-name AT ROW 2.5 COL 26.38 COLON-ALIGNED NO-LABEL
     tt-fin-bank.code-bank AT ROW 2.5 COL 78.5 COLON-ALIGNED
          LABEL "Код банка"
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     tt-fin-bank.bik AT ROW 3.75 COL 13 COLON-ALIGNED
          LABEL "БИК"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-fin-bank.inn AT ROW 3.75 COL 32 COLON-ALIGNED
          LABEL "INN"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     tt-fin-bank.kpp AT ROW 3.75 COL 62.13 COLON-ALIGNED
          LABEL "KPP"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     tt-fin-bank.cor-acc AT ROW 5.33 COL 13.13 COLON-ALIGNED
          LABEL "№ Корсчета"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     tt-fin-bank.rkc AT ROW 5.38 COL 41 COLON-ALIGNED
          LABEL "РКЦ"
          VIEW-AS FILL-IN
          SIZE 55 BY 1
     tt-fin-bank.bank-name AT ROW 6.75 COL 13 COLON-ALIGNED
          LABEL "Наим. банка"
          VIEW-AS FILL-IN
          SIZE 84 BY 1
     tt-fin-bank.short-name AT ROW 8 COL 13 COLON-ALIGNED
          LABEL "Кратк. назв."
          VIEW-AS FILL-IN
          SIZE 84 BY 1
     tt-fin-bank.licenz AT ROW 9.25 COL 13 COLON-ALIGNED
          LABEL "Лицензия"
          VIEW-AS FILL-IN
          SIZE 50 BY 1
     tt-fin-bank.otdel AT ROW 10.5 COL 13 COLON-ALIGNED
          LABEL "Отделение"
          VIEW-AS FILL-IN
          SIZE 62.88 BY 1
     tt-fin-bank.bank-city AT ROW 11.58 COL 13 COLON-ALIGNED
          LABEL "Город"
          VIEW-AS FILL-IN
          SIZE 13 BY 1
     tt-fin-bank.addres AT ROW 12.75 COL 13 COLON-ALIGNED
          LABEL "Адрес юрид."
          VIEW-AS FILL-IN
          SIZE 78 BY 1
     tt-fin-bank.addres1 AT ROW 14 COL 13 COLON-ALIGNED
          LABEL "Адрес почт."
          VIEW-AS FILL-IN
          SIZE 78 BY 1
     tt-fin-bank.phone AT ROW 15.25 COL 13 COLON-ALIGNED
          LABEL "Телефон"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     tt-fin-bank.fax AT ROW 15.25 COL 55.63 COLON-ALIGNED
          LABEL "Факс"
          VIEW-AS FILL-IN
          SIZE 22 BY 1
     tt-fin-bank.e-mail AT ROW 16.5 COL 13 COLON-ALIGNED
          LABEL "E-mail"
          VIEW-AS FILL-IN
          SIZE 34 BY 1
     tt-fin-bank.cl-bank AT ROW 16.5 COL 61 COLON-ALIGNED
          LABEL "Клиент-Банк" FORMAT "X(25)"
          VIEW-AS COMBO-BOX INNER-LINES 5
          LIST-ITEM-PAIRS "Item 1","Item 1"
          DROP-DOWN-LIST
          SIZE 35.5 BY 1
     tt-fin-bank.okato AT ROW 17.75 COL 13 COLON-ALIGNED
          LABEL "ОКАТО"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-fin-bank.okonx AT ROW 17.75 COL 36 COLON-ALIGNED
          LABEL "OKNH"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-fin-bank.okpo AT ROW 17.75 COL 55.75 COLON-ALIGNED
          LABEL "ОКПО" FORMAT "X(10)"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     tt-fin-bank.PS AT ROW 19 COL 15 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 63.5 BY 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
DEFINE FRAME Dialog-Frame
     "Примечания" VIEW-AS TEXT
          SIZE 10.63 BY 1 AT ROW 19.75 COL 2.5
     SPACE(85.87) SKIP(2.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Банк"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tt-fin-bank.otdel:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run proc-save in this-procedure(yes) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo.
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    run ref/fincbnks.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input "":U
                ,input "one":U
                ,input locked_fin-bank.host-code
                ,input locked_fin-bank.code-bank
                ,input-output v-rid-list
                              )
 .
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
define variable v-log as logical no-undo .
define variable v-cmp as character no-undo .
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
run proc-save in this-procedure (no) no-error.
buffer-compare tt-fin-bank to locked_fin-bank
case-sensitive
save result in v-cmp .
if v-cmp <> "":U then do:
  message
  "Вы изменили запись БАНК, но не сохранили ее" skip
  "сохранить перед печатью?"
  view-as alert-box QUESTION buttons YES-NO update v-log.
end.
run proc-save in this-procedure (v-log) no-error.
    run ref/finbankp.p (
                 INPUT parParentProc
                 ,input locked_fin-bank.host-code
                 ,input locked_fin-bank.code-bank
              ) no-error.
if error-status:error then do:
  return no-apply.
end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
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
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
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
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
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
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if p-mode  <> 'ДОБАВЛЕНИЕ':U
 and p-mode <> 'ИЗМЕНЕНИЕ':U
 and p-mode <> 'ПРОСМОТР':U
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
find first X_curr_sysconf no-lock where
                X_curr_sysconf.host-code = p-curr-host-code.
find first X_sysconf no-lock where
                X_sysconf.host-code = p-host-code.
 if p-mode <> 'ПРОСМОТР':U then do:
    if X_curr_sysconf.host-code <> p-host-code
    or v-db-num <> X_sysconf.firm-db-num
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode и/или p-host-code и/или p-curr-host-code" p-mode p-host-code  p-curr-host-code
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-fin-bank:
        delete tt-fin-bank.
    end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_fin-bank EXclusive-lock where
                   recid(locked_fin-bank) = p-doc-rec no-wait no-error.
      if locked locked_fin-bank then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись БАНК занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_fin-bank no-lock where
                       recid(locked_fin-bank) = p-doc-rec no-error .
      if not avail locked_fin-bank then do:
        find first locked_fin-bank where
                  locKed_fin-bank.host-code = p-host-code
               AND locKed_fin-bank.code-bank = p-code-bank no-error .
      end.
    end.
    if not available locked_fin-bank then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись БАНК"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-fin-bank.
    buffer-copy locked_fin-bank to tt-fin-bank.
   end.
  RUN MYEnable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-fin-bank WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY f-host-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fin-bank THEN
    DISPLAY tt-fin-bank.host-code tt-fin-bank.code-bank tt-fin-bank.bik
          tt-fin-bank.inn tt-fin-bank.kpp tt-fin-bank.cor-acc tt-fin-bank.rkc
          tt-fin-bank.bank-name tt-fin-bank.short-name tt-fin-bank.licenz
          tt-fin-bank.bank-city tt-fin-bank.addres tt-fin-bank.addres1
          tt-fin-bank.phone tt-fin-bank.fax tt-fin-bank.e-mail
          tt-fin-bank.cl-bank tt-fin-bank.okato tt-fin-bank.okonx
          tt-fin-bank.okpo tt-fin-bank.PS
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-print B-hist B-Help tt-fin-bank.bik tt-fin-bank.inn
         tt-fin-bank.kpp tt-fin-bank.cor-acc tt-fin-bank.rkc
         tt-fin-bank.bank-name tt-fin-bank.short-name tt-fin-bank.licenz
         tt-fin-bank.bank-city tt-fin-bank.addres tt-fin-bank.addres1
         tt-fin-bank.phone tt-fin-bank.fax tt-fin-bank.e-mail
         tt-fin-bank.cl-bank tt-fin-bank.okato tt-fin-bank.okonx
         tt-fin-bank.okpo tt-fin-bank.PS
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
assign
v-list-items = "нет системы КЛИЕНТ-БАНК" + chr(44) + '':U.
DO v-ii = 1 TO NUM-ENTRIES('1s':U):
    ASSIGN
    v-list-items = v-list-items + chr(44) +
                   ENTRY(v-ii, '1С':U) + chr(44) +
                   ENTRY(v-ii, '1s':U).
END.
assign
tt-fin-bank.okonx:label in frame Dialog-Frame = "ОКОНХ"
tt-fin-bank.inn:label  in frame Dialog-Frame  = "ИНН"
tt-fin-bank.kpp:label  in frame Dialog-Frame  = "КПП"
tt-fin-bank.cl-bank:list-item-pairs in frame Dialog-Frame = v-list-items
.
find first X_clients no-lock where
            X_clients.obj-type = 'орг':U
        AND X_clients.obj-code = p-host-code.
  DISPLAY
  X_clients.obj-name @  f-host-name
   WITH FRAME Dialog-Frame.
case p-mode:
  when 'ДОБАВЛЕНИЕ':U then do:
    DISPLAY
    p-host-code @ tt-fin-bank.host-code
    ? @ tt-fin-bank.code-bank
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    DISPLAY
    tt-fin-bank.bank-city
    tt-fin-bank.host-code
    tt-fin-bank.code-bank
    tt-fin-bank.addres
    tt-fin-bank.addres1
    tt-fin-bank.bank-name
    tt-fin-bank.bik
    tt-fin-bank.cor-acc
    tt-fin-bank.e-mail
    tt-fin-bank.fax
    tt-fin-bank.inn
    tt-fin-bank.kpp
    tt-fin-bank.licenz
    tt-fin-bank.okato
    tt-fin-bank.okonx
    tt-fin-bank.okpo
    tt-fin-bank.phone
    tt-fin-bank.PS
    tt-fin-bank.rkc
    tt-fin-bank.short-name
    tt-fin-bank.cl-bank
    WITH FRAME Dialog-Frame.
  end.
END CASE.
if p-mode = 'ПРОСМОТР':U then do:
assign
b-quit:label = "&Выход"
.
hide
b-exit in frame Dialog-Frame.
end.
ENABLE
b-quit
B-exit when p-mode <> 'ПРОСМОТР':U
b-print when p-mode <> 'ДОБАВЛЕНИЕ':U
b-hist when p-mode <> 'ДОБАВЛЕНИЕ':U
B-Help
tt-fin-bank.bank-name when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.bik when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.addres when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.addres1 when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.cor-acc when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.rkc     when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.e-mail when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.fax    when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.inn    when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.kpp    when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.licenz when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.okato when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.okonx when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.okpo  when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.phone  when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.short-name when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.bank-city when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.PS when p-mode <> 'ПРОСМОТР':U
tt-fin-bank.cl-bank when p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
define input parameter p-save as logical no-undo .
if p-mode = 'ПРОСМОТР':U then do:
    return error.
end.
if not available tt-fin-bank then do:
    create tt-fin-bank.
end.
assign
tt-fin-bank.addres frame Dialog-Frame
tt-fin-bank.bank-city
tt-fin-bank.addres1
tt-fin-bank.bank-name
tt-fin-bank.bik
tt-fin-bank.cor-acc
tt-fin-bank.e-mail
tt-fin-bank.fax
tt-fin-bank.inn
tt-fin-bank.kpp
tt-fin-bank.licenz
tt-fin-bank.okato
tt-fin-bank.okonx
tt-fin-bank.okpo
tt-fin-bank.phone
tt-fin-bank.PS
tt-fin-bank.rkc
tt-fin-bank.short-name
tt-fin-bank.cl-bank
.
if not p-save then return .
run ref/finbank1.p (
input-output p-doc-rec
,input p-mode
,input no
,input "bik"
,input "":U
,input p-host-code
,input p-code-bank
,input tt-fin-bank.addres
,input tt-fin-bank.bank-city
,input tt-fin-bank.addres1
,input tt-fin-bank.bank-name
,input tt-fin-bank.bik
,input tt-fin-bank.cor-acc
,input tt-fin-bank.e-mail
,input tt-fin-bank.fax
,input tt-fin-bank.inn
,input tt-fin-bank.kpp
,input tt-fin-bank.licenz
,input tt-fin-bank.okato
,input tt-fin-bank.okonx
,input tt-fin-bank.okpo
,input tt-fin-bank.otdel
,input tt-fin-bank.phone
,input tt-fin-bank.PS
,input tt-fin-bank.rkc
,input tt-fin-bank.short-name
,input tt-fin-bank.cl-bank
)
no-error.
if error-status:error then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
END PROCEDURE.
