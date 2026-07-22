define input parameter p-start-date as date no-undo .
define input parameter p-end-date as date no-undo .
DEFINE output PARAMETER p-prn-doc-code AS CHARACTER NO-UNDO.
DEFINE output PARAMETER p-fin-ext-doc-type AS CHARACTER NO-UNDO.
define output parameter p-pay-date as date no-undo .
define output parameter p-bik as character no-undo .
define output parameter p-bank-name as character no-undo .
define output parameter p-bank-city as character no-undo .
define output parameter p-c-schet as character no-undo .
define output parameter p-r-schet as character no-undo .
define output parameter p-name as character no-undo .
define output parameter p-inn as character no-undo .
define output parameter p-kpp as character no-undo .
DEFINE output PARAMETER p-sum AS decimal NO-UNDO.
DEFINE output PARAMETER p-ps AS character NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ввод данных неучтенного в TH платежа".
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
DEFINE VARIABLE v-tab-order AS CHARACTER NO-UNDO.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE E-ps AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 66 BY 4 NO-UNDO.
DEFINE VARIABLE f-bank-city AS CHARACTER FORMAT "X(20)":U
     LABEL "Город Банка"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1.07 NO-UNDO.
DEFINE VARIABLE f-bank-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Банк"
     VIEW-AS FILL-IN
     SIZE 87.5 BY 1.07 NO-UNDO.
DEFINE VARIABLE f-bik AS CHARACTER FORMAT "X(10)":U
     LABEL "БИК"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE f-c-schet AS CHARACTER FORMAT "X(20)":U
     LABEL "Коррсчет"
     VIEW-AS FILL-IN
     SIZE 31.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-inn AS CHARACTER FORMAT "X(20)":U
     LABEL "INN"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1.07 NO-UNDO.
DEFINE VARIABLE f-kpp AS CHARACTER FORMAT "X(20)":U
     LABEL "kpp"
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1.07 NO-UNDO.
DEFINE VARIABLE f-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Плат/Получ"
     VIEW-AS FILL-IN
     SIZE 74.5 BY 1.07 NO-UNDO.
DEFINE VARIABLE f-pay-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата платежа"
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-prn-doc-code AS CHARACTER FORMAT "X(256)":U
     LABEL "№ платежа"
     VIEW-AS FILL-IN
     SIZE 31 BY 1 NO-UNDO.
DEFINE VARIABLE f-r-schet AS CHARACTER FORMAT "X(20)":U
     LABEL "Расчсчет"
     VIEW-AS FILL-IN
     SIZE 31.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-sum AS DECIMAL FORMAT ">>>,>>>,>>9.99":U INITIAL 0
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 30.5 BY 1 NO-UNDO.
DEFINE VARIABLE S-fin-ext-doc-type AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 31.5 BY 2 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 54.9
     f-prn-doc-code AT ROW 2.5 COL 11 COLON-ALIGNED
     S-fin-ext-doc-type AT ROW 2.5 COL 55 NO-LABEL
     f-bik AT ROW 4.5 COL 5 COLON-ALIGNED
     f-bank-name AT ROW 5.77 COL 5 COLON-ALIGNED
     f-bank-city AT ROW 7 COL 2.5
     f-c-schet AT ROW 8.27 COL 13.5 COLON-ALIGNED
     f-r-schet AT ROW 9.5 COL 13.5 COLON-ALIGNED
     f-name AT ROW 10.77 COL 3.5
     f-inn AT ROW 12 COL 10.5
     f-kpp AT ROW 12 COL 42
     f-pay-date AT ROW 13.27 COL 13.5 COLON-ALIGNED
     f-sum AT ROW 13.27 COL 43.5 COLON-ALIGNED
     E-ps AT ROW 15.67 COL 1 NO-LABEL
     "Примечания:" VIEW-AS TEXT
          SIZE 22.5 BY 1 AT ROW 14.33 COL 2
          FGCOLOR 4
     SPACE(70.99) SKIP(4.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Неучтенный в TH платеж"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  ASSIGN
  f-prn-doc-code
  f-bik
  f-bank-name
  f-bank-city
  f-r-schet
  f-c-schet
  f-name
  f-inn
  f-kpp
  f-pay-date
  f-sum
  S-fin-ext-doc-type
  .
  IF f-prn-doc-code = '':U THEN DO:
    MESSAGE
    "Введите номер платежа!"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  IF s-fin-ext-doc-type = "":U THEN DO:
    MESSAGE
    "Укажите тип платежа"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  IF f-bik = '':U
  and f-bank-name = '':U
  THEN DO:
      MESSAGE
      "Вы должны указать хотя бы один из следующих реквизитов:" SKIP
      "БИК, название банка"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  IF f-inn = '':U
  and f-kpp = '':U
  AND f-name = '':U THEN DO:
      MESSAGE
      "Вы должны указать хотя бы один из следующих реквизитов:" SKIP
      "ИНН, КПП, название Плат/Получ"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  IF f-r-schet = '':U THEN DO:
      MESSAGE
      "Укажите расч. счет"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  IF f-sum = ?
  OR f-sum < 0 THEN DO:
      MESSAGE
      "Укажите сумму платежа"
      VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  if f-pay-date = ? then do:
    MESSAGE
    "Укажите дату платежа"
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  end.
  if f-pay-date < p-start-date
  or f-pay-date > p-end-date then do:
    MESSAGE
    substitute("Дата платежа может быть: &1 - &2 ", p-start-date, p-end-date)
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  end.
  ASSIGN
  p-prn-doc-code = f-prn-doc-code
  p-fin-ext-doc-type = s-fin-ext-doc-type
  p-bik = f-bik
  p-bank-name = f-bank-name
  p-bank-city = f-bank-city
  p-name = f-name
  p-c-schet = f-c-schet
  p-r-schet = f-r-schet
  p-inn = f-inn
  p-kpp = f-kpp
  p-pay-date = f-pay-date
  p-sum = f-sum
  p-ps = e-ps:SCREEN-VALUE
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of f-pay-date in frame Dialog-Frame
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
on delete-character of f-pay-date in frame Dialog-Frame
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
on ctrl-d of f-pay-date in frame Dialog-Frame
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
on ctrl-b of f-pay-date in frame Dialog-Frame
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
on ctrl-e of f-pay-date in frame Dialog-Frame
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
on ctrl-f of f-pay-date in frame Dialog-Frame
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
  define MENU m-ed-date4
    MENU-ITEM m-ed-date4-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date4-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date4-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date4-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if f-pay-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      f-pay-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date4 :HANDLE
      f-pay-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle4 as handle no-undo .
  assign
    v-label-handle4 = f-pay-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle4)
  then do:
    if v-label-handle4 :tooltip = ""
    or v-label-handle4 :tooltip = ?
    then do:
      assign
        v-label-handle4 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date4-1 in menu m-ed-date4 DO:
    apply "ctrl-b":U to f-pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-2 in menu m-ed-date4 DO:
    apply "ctrl-d":U to f-pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-3 in menu m-ed-date4 DO:
    apply "ctrl-e":U to f-pay-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date4-4 in menu m-ed-date4 DO:
    apply "ctrl-f":U to f-pay-date in frame Dialog-Frame .
  END.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN Myenable IN THIS-PROCEDURE.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-prn-doc-code S-fin-ext-doc-type f-bik f-bank-name f-bank-city
          f-c-schet f-r-schet f-name f-inn f-kpp f-pay-date f-sum E-ps
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help f-prn-doc-code S-fin-ext-doc-type f-bik
         f-bank-name f-bank-city f-c-schet f-r-schet f-name f-inn f-kpp
         f-pay-date f-sum E-ps
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE V-ITEM-1 AS CHARACTER NO-UNDO.
DEFINE VARIABLE V-ITEM-2 AS CHARACTER NO-UNDO.
ASSIGN
f-kpp:label in frame Dialog-Frame = "КПП"
f-inn:label in frame Dialog-Frame = "ИНН"
v-tab-order = "f-prn-doc-code,S-fin-ext-doc-type,f-bik,f-bank-name,f-bank-city,f-c-schet," +
              "f-r-schet,f-name,f-inn,f-kpp,f-pay-date,f-sum,e-ps".
V-ITEM-1 = entry (lookup ('ппп':U, 'пко,рко,ппп,рпп,апп,апр,':U), 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,апп,апр':U) + chr(44) +
            'ппп':U .
V-ITEM-2 = entry (lookup ('рпп':U, 'пко,рко,ппп,рпп,апп,апр,':U), 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,апп,апр':U) + chr(44) +
            'рпп':U.
ASSIGN
s-fin-ext-doc-type:LIST-ITEM-PAIRS in frame Dialog-Frame = V-ITEM-1 + chr(44) + V-ITEM-2.
DISPLAY
f-prn-doc-code
S-fin-ext-doc-type
f-bik
f-bank-name
f-bank-city
f-c-schet
f-r-schet
f-name
f-inn
f-kpp
f-sum
WITH FRAME Dialog-Frame.
ENABLE
B-exit
b-quit
B-Help
f-prn-doc-code
S-fin-ext-doc-type
f-bik
f-bank-name
f-bank-city
f-c-schet
f-r-schet
f-name
f-inn
f-kpp
f-pay-date
f-sum
E-PS
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
END PROCEDURE.
