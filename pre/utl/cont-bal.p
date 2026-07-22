block-level on error undo, throw.
define input parameter parParentProc as handle           no-undo.
define variable vss-revision    as character no-undo init "$Revision: 026c675a5513, 352, rls $":u .
define variable vss-author      as character no-undo init "$Author: EShklyar $":u .
define variable vss-date        as character no-undo init "$Date: Thu Dec 17 17:50:47 2015 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: cont-bal.p $":u .
define variable vss-archive     as character no-undo init "$Archive: utl/cont-bal.p $":u .
define variable vss-description as character no-undo init "утилита Пересчет баланса ФО и платежей к договору" .
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
  define variable v-choice as integer   no-undo .
  define variable doc-list as character no-undo .
  define variable v-num    as integer   no-undo .
  define variable ii as integer   no-undo .
  define variable Counter1 as integer   no-undo .
  define buffer buf_contract for contract .
  define buffer buf_clients for clients .
  define buffer buf_fin-ob for fin-ob .
  define buffer buf_fin-doc for fin-doc .
  run gbl/d-askw.w (input "Расчет баланса",
                input ("Пересчет баланса ФО и платежей к договору:"  ),
                input "|",
                input ("По договору|" +  "По контрагенту|" + "Все|" + "Выход"),
                input "|||",
                input 1,
                input 4,
                output v-choice).
  if v-choice <> 4 then do:
    os-delete 'cont-bal.log' .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    def var log-file-name as char no-undo.
    assign
        log-file-name = 'cont-bal.log'
    .
    if log-file-name <> "":U
    then do:
        if search( 'cont-bal.log' ) = ?
        then do:
            output to value( 'cont-bal.log' ).
            output close.
        end.
    end.
    DEF STREAM stm-log.
    PROCEDURE writelog:
    DEF INPUT PARAMETER p-file-name AS CHAR     NO-UNDO.
    DEF INPUT PARAMETER p-log-level AS INTEGER  NO-UNDO.
    DEF INPUT PARAMETER p-log-string  AS CHAR     NO-UNDO.
    if p-file-name <> ""
    then do:
    OUTPUT STREAM stm-log TO VALUE(p-file-name) APPEND.
        PUT STREAM stm-log UNFORMATTED chr(10).
        PUT STREAM stm-log UNFORMATTED (IF (p-log-level = 0 OR p-log-string = "&DLine"
                                        OR p-log-string = "&Line") THEN "" ELSE
                                        cur-time-string-sec() + " ").
        PUT STREAM stm-log UNFORMATTED
                (IF p-log-string = "&Line" THEN FILL("-", 80)
                ELSE IF p-log-string = "&DLine" THEN FILL("=", 80)
                ELSE fill(" ", p-log-level * 2) + p-log-string).
    OUTPUT STREAM stm-log CLOSE.
    end.
    END PROCEDURE.
    assign  Counter1 = 0 .
define variable v-account as integer init 0 no-undo .
define variable v-account-lavel as character no-undo .
define variable v-button-stop as logical no-undo .
define variable v-kol-spice as integer no-undo .
define variable v-kol-spice2 as integer no-undo .
define variable v-kol-spice3 as integer no-undo .
DEFINE VARIABLE StopProcessing AS LOGICAL NO-UNDO.
DEFINE BUTTON StopBtn AUTO-END-KEY
     LABEL "Стоп"
     SIZE 10 BY 1.
DEFINE VARIABLE RecordsDone AS INTEGER FORMAT ">,>>>,>>>,>>9":U INITIAL 0
     LABEL "Обработано записей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE RecordsString AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString2 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE RecordsString3 AS CHARACTER FORMAT "X(60)"
      VIEW-AS TEXT
     SIZE 53.25 BY .67
     FGCOLOR 1  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.13 BY 4.46.
DEFINE FRAME InfoFrame
     StopBtn AT ROW 4.25 COL 21.75
     RecordsString AT ROW 1.21 COL 2 NO-LABEL
     RecordsString2 AT ROW 1.96 COL 2 NO-LABEL
     RecordsString3 AT ROW 2.58 COL 2 NO-LABEL
     RecordsDone AT ROW 3.42 COL 24.88 COLON-ALIGNED
     RECT-1 AT ROW 1 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Процесс"
         DEFAULT-BUTTON StopBtn CANCEL-BUTTON StopBtn.
define variable mFrameView      as logical   no-undo init yes.
  define variable mFramHandle as handle no-undo.
  mFramHandle = frame InfoFrame:handle.
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramHandle:visible), "frameRepError").
  end.
  mFrameView = not session:batch-mode and mFramHandle:visible.
  if mFrameView
  then do:
    ASSIGN
       FRAME InfoFrame:HIDDEN                           = TRUE
       StopBtn:sensitive IN FRAME InfoFrame             = TRUE.
  end.
ON CHOOSE OF StopBtn IN FRAME InfoFrame
DO:
  IF not StopProcessing THEN
    Message "Вы действительно хотите прервать" SKIP
            "процесс проверки?" view-as alert-box QUESTION BUTTONS yes-no
              UPDATE StopProcessing.
  IF StopProcessing THEN do:
     if mFrameView
     then do:
        HIDE FRAME InfoFrame.
     end.
  End.
END.
assign v-account = ( if integer( 1 ) = 0 then 100 else integer( 1 ) ).
  if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("ON mFrameView=" + string(mFrameView), "frameRepError").
  end.
  if not session:batch-mode then
  do:
    VIEW FRAME InfoFrame.
    mFrameView = true.
  end.
   v-button-stop = false .
      if mFrameView
      then do:
      if v-button-stop then view STOPBTN in frame InfoFrame.
                       else Hide STOPBTN in frame InfoFrame.
      end.
    case v-choice :
      when 1 then do:
        run str/cont-all.w (input ParParentProc, input v-cntxt-host-code-obj, input "b-sel,b-mark", input 'все':U, input ?,
                  input ?, input ?, input ?, input "current":u, input "all":u, input-output doc-list).
        if doc-list <> "" then do:
          assign v-num = num-entries(doc-list) .
          do ii = 1 to v-num:
            find first buf_contract no-lock where RECID(buf_contract) = int (doc-list) no-error .
            if available buf_contract then do:
              run CalcContr in this-procedure  .
            end.
          end.
        end.
      end.
      when 2 then do:
        run ref/cli-all.w ( parParentProc, "b-sel,b-mark", 'орг':U, 'все':U, 'текущие':U, ?, ",,,,,,NO,,":u, ?, output doc-list ) .
        if doc-list <> "" then do:
          assign v-num = num-entries(doc-list) .
          do ii = 1 to v-num:
            find first buf_clients no-lock where RECID(buf_clients) = integer(entry(ii, doc-list)) no-error.
            run writelog ( "cont-bal.log", 0, "Контрагент: " + buf_clients.obj-name ) .
            for each buf_contract no-lock
              where buf_contract.cli-type = buf_clients.obj-type
                and buf_contract.cli-code = buf_clients.obj-code
                and buf_contract.db-num   = v-cntxt-db-num
              :
              run CalcContr in this-procedure  .
            end.
          end.
        end.
      end.
      when 3 then do:
        for each buf_contract no-lock
          where buf_contract.db-num   = v-cntxt-db-num :
          run CalcContr in this-procedure  .
        end.
      end.
    end.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
    define variable g#log as logical   no-undo .
    define variable s-list as character no-undo .
    run gbl/prnfilen.w ( input  "Результат работы утилиты", input  0, input  'cont-bal.log', input 7, output s-list, output g#log ).
  end.
procedure CalcContr :
  do on error undo, return error return-value :
    assign Counter1 = Counter1 + 1.
IF ( Counter1 modulo v-account = 0 )  then DO:
          if  log-manager:logfile-name ne ?
          then DO:
              log-manager:write-message("DISP mFrameView=" + string(mFrameView), "frameRepError").
          end.
           if mFrameView
           then do:
            DISPLAY
              Counter1 @ RecordsDone
              WITH FRAME InfoFrame.
           end.
End.
   if v-button-stop then  DO:
         if mFrameView
         then
            PROCESS EVENTS.
         IF StopProcessing THEN DO:
         RETURN error.
         End.
   end.
    define variable fin-ob-sum       as decimal   no-undo .
    define variable fin-ob-sum-rubl  as decimal   no-undo .
    define variable fin-ob-sum-base  as decimal   no-undo .
    define variable fin-doc-sum      as decimal   no-undo .
    define variable fin-doc-sum-rubl as decimal   no-undo .
    define variable fin-doc-sum-base as decimal   no-undo .
    assign
      fin-ob-sum       = 0
      fin-ob-sum-rubl  = 0
      fin-ob-sum-base  = 0
      fin-doc-sum      = 0
      fin-doc-sum-rubl = 0
      fin-doc-sum-base = 0
    .
    for each buf_fin-ob no-lock
      where buf_fin-ob.host-code     = buf_contract.host-code
        and buf_fin-ob.contract-code = buf_contract.contract-code
        and buf_fin-ob.status_       = 'факт':U
      :
      assign
        fin-ob-sum      = fin-ob-sum      + buf_fin-ob.sum-contract
        fin-ob-sum-rubl = fin-ob-sum-rubl + buf_fin-ob.sum-rubl
        fin-ob-sum-base = fin-ob-sum-base + buf_fin-ob.sum-base
      .
    end.
    for each buf_fin-doc no-lock
      where buf_fin-doc.host-code     = buf_contract.host-code
        and buf_fin-doc.contract-code = buf_contract.contract-code
        and buf_fin-doc.status_       = 'факт':U
      :
      if buf_fin-doc.fin-doc-type = 'ппп':U or buf_fin-doc.fin-doc-type = 'пко':U or buf_fin-doc.fin-doc-type = 'апп':U  then do:
        assign
          fin-doc-sum      = fin-doc-sum      + buf_fin-doc.sum-contr
          fin-doc-sum-rubl = fin-doc-sum-rubl + buf_fin-doc.sum-rubl
          fin-doc-sum-base = fin-doc-sum-base + buf_fin-doc.sum-base
        .
      end.
      else do:
        assign
          fin-doc-sum      = fin-doc-sum      - buf_fin-doc.sum-contr
          fin-doc-sum-rubl = fin-doc-sum-rubl - buf_fin-doc.sum-rubl
          fin-doc-sum-base = fin-doc-sum-base - buf_fin-doc.sum-base
        .
      end.
    end.
    if buf_contract.doc-type = 'при':U then do:
      assign
        fin-doc-sum      = - fin-doc-sum
        fin-doc-sum-rubl = - fin-doc-sum-rubl
        fin-doc-sum-base = - fin-doc-sum-base
      .
    end.
    find first contract exclusive-lock where recid(contract) = recid(buf_contract) .
    assign
      contract.balance-fo        = fin-ob-sum
      contract.balance-plat      = fin-doc-sum
      contract.balance-fo-rubl   = fin-ob-sum-rubl
      contract.balance-plat-rubl = fin-doc-sum-rubl
      contract.balance-fo-base   = fin-ob-sum-base
      contract.balance-plat-base = fin-doc-sum-base
    .
    if v-choice = 3 then find first buf_clients no-lock where buf_clients.obj-type = buf_contract.cli-type and buf_clients.obj-code = buf_contract.cli-code  no-error.
    if available buf_clients then run writelog ( "cont-bal.log", 0, string("Контрагент: " + buf_clients.obj-type + string(buf_clients.obj-code) + " Договор (вн. №): " + string(buf_contract.contract-code) + " Баланс ФО: " + string(contract.balance-fo) + " Баланс плат.: " + string(contract.balance-plat)) ) .
  end.
end procedure.
