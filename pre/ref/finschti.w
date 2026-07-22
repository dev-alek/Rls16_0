DEFINE BUFFER locked_fin-schet FOR ub.fin-schet.
DEFINE TEMP-TABLE tt-fin-schet NO-UNDO LIKE ub.fin-schet.
DEFINE BUFFER X_clients FOR ub.clients.
DEFINE BUFFER X_clients-host FOR ub.clients.
DEFINE BUFFER X_currency FOR ub.currency.
DEFINE BUFFER X_fin-bank FOR ub.fin-bank.
DEFINE BUFFER X_schet-clients FOR ub.clients.
DEFINE BUFFER X_sysconf FOR ub.sysconf.
DEFINE INPUT     PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-host-code like ub.fin-schet.host-code no-undo.
define input parameter p-code-schet like ub.fin-schet.code-schet no-undo.
define input parameter p-code-bank like ub.fin-schet.code-bank no-undo .
define input parameter p-cli-type like ub.fin-schet.cli-type no-undo .
define input parameter p-cli-code like ub.fin-schet.cli-code no-undo .
define input parameter p-curr-code like ub.fin-schet.curr-code no-undo .
define input-output parameter p-doc-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Карточка редактирования банковского счета".
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
define variable v-tab-order as character no-undo.
define buffer X_curr_sysconf for ub.sysconf.
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
DEFINE BUTTON B-bank
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 3 BY 1.
DEFINE BUTTON B-currency
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
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-bank-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 68 BY 1 NO-UNDO.
DEFINE VARIABLE f-bik AS CHARACTER FORMAT "X(22)":U
     LABEL "БИК"
     VIEW-AS FILL-IN
     SIZE 14.75 BY 1 NO-UNDO.
DEFINE VARIABLE f-cli-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE VARIABLE f-curr-abbr AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE f-host-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-fin-schet,
      X_schet-clients SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-print AT ROW 1 COL 89
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     tt-fin-schet.host-code AT ROW 2.5 COL 13 COLON-ALIGNED
          LABEL "Фирма" FORMAT ">>>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 12 BY 1
     f-host-name AT ROW 2.5 COL 25.25 COLON-ALIGNED NO-LABEL
     tt-fin-schet.code-schet AT ROW 2.5 COL 78.5 COLON-ALIGNED
          LABEL "Код счета"
          VIEW-AS FILL-IN
          SIZE 8 BY 1
     f-cli-name AT ROW 4 COL 46.13 COLON-ALIGNED NO-LABEL
     tt-fin-schet.cli-code AT ROW 4.04 COL 28.5 COLON-ALIGNED NO-LABEL FORMAT ">>>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     B-cli AT ROW 4.08 COL 44.38
     tt-fin-schet.cli-type AT ROW 4.13 COL 17.63 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", "1":U
          SIZE 12.25 BY .96
     tt-fin-schet.code-bank AT ROW 6.08 COL 13 COLON-ALIGNED
          LABEL "Банк"
          VIEW-AS FILL-IN
          SIZE 9 BY 1
     B-bank AT ROW 6.08 COL 25.25
     f-bank-name AT ROW 6.08 COL 28 COLON-ALIGNED NO-LABEL
     f-bik AT ROW 7.33 COL 28 COLON-ALIGNED
     tt-fin-schet.c-schet AT ROW 9.54 COL 13 COLON-ALIGNED
          LABEL "Корр.счет"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-fin-schet.curr-code AT ROW 9.54 COL 53.13 COLON-ALIGNED
          LABEL "Код валюты"
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     B-currency AT ROW 9.54 COL 59.88
     f-curr-abbr AT ROW 9.54 COL 62.75 COLON-ALIGNED NO-LABEL
     tt-fin-schet.r-schet AT ROW 10.79 COL 13 COLON-ALIGNED
          LABEL "Расч. счет"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-fin-schet.dop1 AT ROW 12 COL 43.5 COLON-ALIGNED
          LABEL "Дополн. к названию держателя счета"
          VIEW-AS FILL-IN
          SIZE 30 BY 1
     tt-fin-schet.dop2 AT ROW 13.25 COL 43.5 COLON-ALIGNED
          LABEL "Дополн. к названию банка"
          VIEW-AS FILL-IN
          SIZE 30 BY 1
     tt-fin-schet.PS AT ROW 15 COL 13 NO-LABEL
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 63.5 BY 4
     "Держатель счета" VIEW-AS TEXT
          SIZE 15.13 BY .92 AT ROW 4.17 COL 1.75
     "Примечания" VIEW-AS TEXT
          SIZE 10.63 BY 1 AT ROW 15.13 COL 2
     SPACE(86.36) SKIP(3.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Банковский счет"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-bank IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo.
define variable ref-rec as recid no-undo.
define variable v-status_ like ub.fin-bank.status_ no-undo init 'тек':U.
define buffer buf_fin-bank for ub.fin-bank.
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
if available X_fin-bank then do:
    assign
     v-rid-list = string(recid(X_fin-bank))
     .
end.
run ref/finbanks.w (input parParentProc
              , input p-curr-host-code
              , input "b-sel":U
              , input 'фирма':U
              , input p-host-code
              , input-output v-status_
              , input-output v-rid-list).
    if v-rid-list = "" then   do:
      return no-apply.
     end.
    ref-rec = integer( v-rid-list ).
    FIND FIRST buf_fin-bank WHERE
             recid (buf_fin-bank) = ref-rec NO-LOCK .
    if buf_fin-bank.status_ <> 'тек':U then do:
      message
      "Статус выбранного Вами банка" buf_fin-bank.status_ " - нельзя работать с таким банком"
      view-as alert-box error .
      return no-apply.
    end.
    FIND FIRST X_fin-bank WHERE recid (X_fin-bank) = ref-rec NO-LOCK .
    assign
    tt-fin-schet.code-bank =  X_fin-bank.code-bank
    tt-fin-schet.c-schet = X_fin-bank.cor-acc
    f-bank-name = X_fin-bank.bank-name
     f-bik = X_fin-bank.bik
    .
    display
      tt-fin-schet.code-bank
      f-bank-name
      f-bik
      tt-fin-schet.c-schet
    with frame Dialog-Frame.
END.
ON CHOOSE OF B-cli IN FRAME Dialog-Frame
DO:
define variable ref-list as character no-undo.
define variable ref-rec as recid no-undo.
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
  run ref/cli-all.w (  parParentProc
                  , "b-sel"
                  , tt-fin-schet.cli-type
                  , ?
                  , ?
                  , ?
                  , ?
                  , "without-obj":U
                  , output ref-list) .
    if ref-list = "" then   do:
      return no-apply.
     end.
    ref-rec = integer( ref-list ).
    FIND FIRST X_schet-clients WHERE recid (X_schet-clients) = ref-rec NO-LOCK .
    if NOT (X_schet-clients.obj-type = 'орг':U
            or
            X_schet-clients.obj-type = 'чел':U ) then do:
      message
      "Выберите контрагента типа" 'орг':U "или" 'чел':U
      view-as alert-box error .
      return no-apply.
    end.
    assign
    tt-fin-schet.cli-type =  X_schet-clients.obj-type
    tt-fin-schet.cli-code = X_schet-clients.obj-code
    f-cli-name            =  X_schet-clients.obj-name
    .
    display
      tt-fin-schet.cli-type
      tt-fin-schet.cli-code
      f-cli-name
    with frame Dialog-Frame.
END.
ON CHOOSE OF B-currency IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo.
define variable ref-rec as recid no-undo.
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
if available X_currency then ref-rec = recid(X_currency).
    run ref/currency.w (parparentproc, "b-sel", input-output ref-rec ).
    if ref-rec = ? then do:
        return no-apply.
    end.
    FIND FIRST X_currency WHERE recid (X_currency) = ref-rec NO-LOCK .
    assign
    tt-fin-schet.curr-code =  X_currency.curr-code
    f-curr-abbr = X_currency.curr-abbr
    .
    display
      tt-fin-schet.curr-code
      f-curr-abbr
    with frame Dialog-Frame.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run proc-save in this-procedure (yes) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run ref/fincscts.w
                (
                 input parParentProc
                ,input p-curr-host-code
                ,input "":U
                ,input "one":U
                ,input locked_fin-schet.host-code
                ,input locked_fin-schet.cli-type
                ,input locked_fin-schet.cli-code
                ,input locked_fin-schet.curr-code
                ,input locked_fin-schet.code-bank
                ,input locked_fin-schet.code-schet
                ,input-output v-rid-list
                              )
 .
END.
ON CHOOSE OF B-print IN FRAME Dialog-Frame
DO:
define variable v-log as logical no-undo .
define variable v-cmp as character no-undo .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
buffer-compare tt-fin-schet to locked_fin-schet
case-sensitive
save result in v-cmp .
if v-cmp <> "":U then do:
  message
  "Вы изменили БАНКОВСКИЙ СЧЕТ, но не сохранили его" skip
  "сохранить перед печатью?"
  view-as alert-box QUESTION buttons YES-NO update v-log.
end.
run proc-save in this-procedure (v-log) no-error.
    run ref/finschtp.p (
                 INPUT parParentProc
                 ,input locked_fin-schet.host-code
                 ,input locked_fin-schet.code-schet
              ) no-error.
if error-status:error then do:
  return no-apply.
end.
END.
ON LEAVE OF tt-fin-schet.cli-code IN FRAME Dialog-Frame
DO:
  if   input frame Dialog-Frame tt-fin-schet.cli-code <> 0
  and input frame Dialog-Frame tt-fin-schet.cli-code <> ?
  then do:
    run check-cli in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.
END.
ON VALUE-CHANGED OF tt-fin-schet.cli-type IN FRAME Dialog-Frame
DO:
  assign
  tt-fin-schet.cli-type.
  if   input frame Dialog-Frame tt-fin-schet.cli-code <> 0
  and input frame Dialog-Frame tt-fin-schet.cli-code <> ?
  then do:
    run check-cli in this-procedure no-error.
    if error-status:error then do:
       return no-apply.
    end.
  end.
END.
ON LEAVE OF tt-fin-schet.code-bank IN FRAME Dialog-Frame
DO:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if input frame Dialog-Frame tt-fin-schet.code-bank <> ?
  AND input frame Dialog-Frame tt-fin-schet.code-bank <> 0
  then do:
    find first X_fin-bank no-lock where
                          X_fin-bank.host-code = p-host-code
                  AND X_fin-bank.code-bank = input frame Dialog-Frame tt-fin-schet.code-bank no-error.
      if not available X_fin-bank then do:
          display
          0 @ tt-fin-schet.code-bank
          ? @ f-bank-name
          "":U @ tt-fin-schet.c-schet
          with frame Dialog-Frame .
          APPLY "CHOOSE" to b-bank.
          return no-apply.
      end.
      assign
      tt-fin-schet.code-bank = X_fin-bank.code-bank
      tt-fin-schet.c-schet = X_fin-bank.cor-acc
      f-bank-name =   X_fin-bank.bank-name
.
      display
      tt-fin-schet.code-bank
      tt-fin-schet.c-schet
      f-bank-name
      with frame Dialog-Frame.
  end.
END.
ON LEAVE OF tt-fin-schet.curr-code IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame tt-fin-schet.curr-code <> ? then do:
    find first X_currency no-lock where
                    X_currency.curr-code = input frame Dialog-Frame tt-fin-schet.curr-code no-error.
      if not available X_currency then do:
          display
          ? @ tt-fin-schet.curr-code
          chr(63) @ f-curr-abbr
          with frame Dialog-Frame.
          APPLY "ENTRY" to tt-fin-schet.curr-code.
          return no-apply.
      end.
      assign
          tt-fin-schet.curr-code = X_currency.curr-code
          .
      display
        X_currency.curr-abbr @ f-curr-abbr
        tt-fin-schet.curr-code
        with frame Dialog-Frame.
   end.
END.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
find first X_sysconf no-lock where
                X_sysconf.host-code = p-host-code.
find first X_curr_sysconf no-lock where
                X_curr_sysconf.host-code = p-curr-host-code.
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
  for each tt-fin-schet:
        delete tt-fin-schet.
    end.
  if p-mode = 'ИЗМЕНЕНИЕ':U
  or p-mode = 'ПРОСМОТР':U then do:
    if p-mode = 'ИЗМЕНЕНИЕ':U then do:
      find first locked_fin-schet EXclusive-lock where
                   recid(locked_fin-schet) = p-doc-rec no-wait no-error.
      if locked locked_fin-schet then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись БАНКОВСКОГО СЧЕТА занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    else do:
      find first locked_fin-schet no-lock where
                       recid(locked_fin-schet) = p-doc-rec no-error .
      if not avail locked_fin-schet then do:
        find first locked_fin-schet no-lock where
                   locked_fin-schet.host-code = p-host-code
               AND locked_fin-schet.code-schet = p-code-schet no-error .
      end.
    end.
    if not available locked_fin-schet then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись БАНК"
      view-as alert-box error .
      undo, return error.
    end.
    create tt-fin-schet.
    buffer-copy locked_fin-schet to tt-fin-schet.
   end.
   else do:
          create tt-fin-schet.
          assign
          tt-fin-schet.host-code = p-host-code
          tt-fin-schet.cli-type = 'орг':U
          tt-fin-schet.code-bank = p-code-bank
          tt-fin-schet.cli-type = (if p-cli-type <> "":U
                                   then p-cli-type
                                   else 'орг':U)
          tt-fin-schet.cli-code = (if p-cli-code <> 0
                                   then p-cli-code
                                   else 0)
          tt-fin-schet.curr-code = (if p-curr-code <> ?
                                    then p-curr-code
                                    else 0)
          .
   end.
  RUN MYEnable no-error .
  if error-status:error then do:
    undo, return error.
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-cli :
define buffer buf_clients for ub.clients.
  find first X_schet-clients no-lock where
            X_schet-clients.obj-type = tt-fin-schet.cli-type
        AND X_schet-clients.obj-code = input frame Dialog-Frame tt-fin-schet.cli-code no-error.
    if not available X_schet-clients then do:
        display
        ? @ tt-fin-schet.cli-code
        chr(63) @ f-cli-name
        with frame Dialog-Frame.
        apply "entry" to tt-fin-schet.cli-code in frame Dialog-Frame.
        return error.
    end.
    assign
    tt-fin-schet.cli-code = X_schet-clients.obj-code
    .
    display
    X_schet-clients.obj-name @ f-cli-name
    tt-fin-schet.cli-code
    with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-host-name f-cli-name f-bank-name f-bik f-curr-abbr
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-fin-schet THEN
    DISPLAY tt-fin-schet.host-code tt-fin-schet.code-schet tt-fin-schet.cli-code
          tt-fin-schet.cli-type tt-fin-schet.code-bank tt-fin-schet.c-schet
          tt-fin-schet.curr-code tt-fin-schet.r-schet tt-fin-schet.dop1
          tt-fin-schet.dop2 tt-fin-schet.PS
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-print B-hist B-Help f-cli-name tt-fin-schet.cli-code
         B-cli tt-fin-schet.cli-type tt-fin-schet.code-bank B-bank
         tt-fin-schet.curr-code B-currency f-curr-abbr tt-fin-schet.r-schet
         tt-fin-schet.dop1 tt-fin-schet.dop2 tt-fin-schet.PS
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
assign
tt-fin-schet.cli-type:radio-buttons in frame Dialog-Frame = "Орг" + chr(44) + 'орг':U + chr(44) +
                                      "Чел" + chr(44) + 'чел':U
v-tab-order = "B-exit,b-quit,b-print,b-hist,b-help,cli-type,cli-code,b-cli," +                    "code-bank,B-bank,r-schet,curr-code,B-currency,PS"
.
find first X_clients-host no-lock where
            X_clients-host.obj-type = 'орг':U
        AND X_clients-host.obj-code = p-host-code.
if p-mode <> 'ДОБАВЛЕНИЕ':U
or not (p-cli-type = "":U and p-cli-code = 0)
then do:
  find first X_schet-clients no-lock where
              X_schet-clients.obj-type = tt-fin-schet.cli-type
          AND X_schet-clients.obj-code = tt-fin-schet.cli-code no-error .
  if not available X_schet-clients then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден клиент для счета" p-cli-type p-cli-code
    view-as alert-box .
    return error .
  end.
end.
if p-mode <> 'ДОБАВЛЕНИЕ':U
or not (p-code-bank = 0)
then do:
  find first X_fin-bank no-lock where
              X_fin-bank.host-code = tt-fin-schet.host-code
          AND X_fin-bank.code-bank = tt-fin-schet.code-bank no-error .
  if not available X_fin-bank then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найден банк для счета" p-code-bank "фирма" p-host-code
    view-as alert-box .
    return error .
  end.
end.
if p-mode <> 'ДОБАВЛЕНИЕ':U
or not (p-curr-code = ?)
then do:
  find first X_currency no-lock where
              X_currency.curr-code = tt-fin-schet.curr-code no-error .
  if not available X_currency then do:
    message
    vss-workfile vss-revision vss-description skip
    "Не найдена валюта" p-curr-code p-curr-code
    view-as alert-box .
    return error .
  end.
end.
  DISPLAY
  X_clients-host.obj-name @  f-host-name
   WITH FRAME Dialog-Frame.
case p-mode:
  when 'ДОБАВЛЕНИЕ':U then do:
    DISPLAY
    p-host-code @ tt-fin-schet.host-code
    ? @ tt-fin-schet.code-schet
    tt-fin-schet.code-bank
    tt-fin-schet.cli-type
    tt-fin-schet.cli-code
    tt-fin-schet.curr-code
    tt-fin-schet.dop1
    tt-fin-schet.dop2
    (if avail X_schet-clients
    then X_schet-clients.obj-name
    else "":U)  @ f-cli-name
    (if available X_fin-bank
    then X_fin-bank.bank-name
    else "":U)  @ f-bank-name
    (if available X_fin-bank
    then X_fin-bank.bik
    else "":U) @ f-bik
    (if available X_currency
    then X_currency.curr-abbr
    else "":U) @ f-curr-abbr
    WITH FRAME Dialog-Frame.
  end.
  otherwise do:
    DISPLAY
    tt-fin-schet.host-code
    tt-fin-schet.code-schet
    tt-fin-schet.code-bank
    tt-fin-schet.cli-type
    tt-fin-schet.cli-code
    tt-fin-schet.dop1
    tt-fin-schet.dop2
    X_schet-clients.obj-name @ f-cli-name
    X_fin-bank.bank-name @ f-bank-name
    X_fin-bank.bik @ f-bik
    X_currency.curr-abbr @ f-curr-abbr
    tt-fin-schet.curr-code
    tt-fin-schet.c-schet
    tt-fin-schet.r-schet
    tt-fin-schet.PS
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
b-cli when p-mode = 'ДОБАВЛЕНИЕ':U and (p-cli-type = "":U and p-cli-code = 0)
b-currency when (p-mode = 'ИЗМЕНЕНИЕ':U
                or
                 (p-mode = 'ДОБАВЛЕНИЕ':U and p-curr-code = 0)
                 )
b-bank when (p-mode = 'ИЗМЕНЕНИЕ':U
             or
            (p-mode = 'ДОБАВЛЕНИЕ':U and p-code-bank = 0)
            )
B-Help
tt-fin-schet.cli-code when p-mode = 'ДОБАВЛЕНИЕ':U and (p-cli-type = "":U and p-cli-code = 0)
tt-fin-schet.cli-type when p-mode = 'ДОБАВЛЕНИЕ':U and (p-cli-type = "":U and p-cli-code = 0)
tt-fin-schet.curr-code when (p-mode = 'ИЗМЕНЕНИЕ':U
                            or
                            (p-mode = 'ДОБАВЛЕНИЕ':U and p-curr-code = 0)
                            )
tt-fin-schet.r-schet when p-mode <> 'ПРОСМОТР':U
tt-fin-schet.PS when p-mode <> 'ПРОСМОТР':U
tt-fin-schet.code-bank when p-mode <> 'ПРОСМОТР':U
tt-fin-schet.dop1  when p-mode <> 'ПРОСМОТР':U
tt-fin-schet.dop2  when p-mode <> 'ПРОСМОТР':U
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
define input parameter p-save as logical no-undo .
if p-mode = 'ПРОСМОТР':U then do:
    return error.
end.
if not available tt-fin-schet then do:
    create tt-fin-schet.
end.
if not available X_schet-clients then do:
    message
    "Вы не выбрали держателя счета"
    view-as alert-box error.
    return error.
end.
if not available X_fin-bank then do:
    message
    "Вы не выбрали банк"
    view-as alert-box error.
    return error.
end.
if not available X_currency then do:
    message
    "Вы не выбрали валюту счета"
    view-as alert-box error.
    return error.
end.
assign
tt-fin-schet.c-schet frame Dialog-Frame
tt-fin-schet.cli-type
tt-fin-schet.cli-code
tt-fin-schet.code-bank
tt-fin-schet.curr-code
tt-fin-schet.dop1
tt-fin-schet.dop2
tt-fin-schet.r-schet
tt-fin-schet.PS
.
if not p-save then return.
 run ref/finscht1.p (
input-output p-doc-rec
,input p-mode
,input no
,input "r-schet"
,input p-host-code
,input p-code-schet
,input tt-fin-schet.c-schet
,input tt-fin-schet.cli-type
,input tt-fin-schet.cli-code
,input tt-fin-schet.code-bank
,input tt-fin-schet.curr-code
,INPUT tt-fin-schet.dop1
,INPUT tt-fin-schet.dop2
,input tt-fin-schet.r-schet
,input tt-fin-schet.PS
)
no-error.
if error-status:error then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
