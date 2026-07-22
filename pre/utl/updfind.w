define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "обновление реквизитов клиентов в незакрытых платежах из договора".
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
define input parameter ParParentProc as handle           no-undo.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable ii as integer   no-undo .
define variable is-edit as logical   no-undo .
define variable v-name as character no-undo .
define variable v-inn  as character no-undo .
define variable v-kpp  as character no-undo .
define buffer buf_contract for contract .
define buffer buf_fin-doc  for fin-doc .
define buffer buf_fin-ob  for fin-ob .
DEFINE TEMP-TABLE tt-fin-ob       NO-UNDO LIKE fin-ob .
DEFINE TEMP-TABLE tt-fin-doc      NO-UNDO LIKE fin-doc .
DEFINE TEMP-TABLE tt-fin-doc-attr NO-UNDO LIKE fin-doc-attr .
DEFINE TEMP-TABLE tt-fin-doc-tax  NO-UNDO LIKE fin-doc-tax .
define temp-table tt0-payment     no-undo like ub.payment.
define variable v-logfile as character no-undo .
assign v-logfile = 'updfind.log' .
  os-delete v-logfile .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    def var log-file-name as char no-undo.
    assign
        log-file-name = v-logfile
    .
    if log-file-name <> "":U
    then do:
        if search( v-logfile ) = ?
        then do:
            output to value( v-logfile ).
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
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-OK AUTO-GO
     LABEL "&Ввод ":L
     SIZE 10 BY 1.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 32.5 BY 5.
DEFINE VARIABLE TOG-inn AS LOGICAL INITIAL no
     LABEL "ИНН"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-kpp AS LOGICAL INITIAL no
     LABEL "КПП"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.
DEFINE VARIABLE TOG-name AS LOGICAL INITIAL no
     LABEL "Наименование"
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-OK AT ROW 1 COL 1
     b-exit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 24.5
     TOG-name AT ROW 3.63 COL 4.63
     TOG-inn AT ROW 4.75 COL 4.63
     TOG-kpp AT ROW 5.83 COL 4.75
     "Обновить:" VIEW-AS TEXT
          SIZE 10 BY 1 AT ROW 2.5 COL 3
          FGCOLOR 4
     RECT-7 AT ROW 2.25 COL 2
     SPACE(0.74) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Обновление реквизитов клиентов в незакрытых платежах из договора".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-OK IN FRAME Dialog-Frame
DO:
  assign
    TOG-name
    TOG-inn
    TOG-kpp
  .
  run proc-OK .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
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
  define variable num-db as integer   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output num-db
  )  .
  if num-db <> 0 then do:
    message  "Данная утилита предназначена для работы только в главной БД"  view-as alert-box.
    return no-apply .
  end.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_updfind_update':U
    ,input  'firm':U
    ,input  v-cntxt-host-code-obj
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output is-edit
    )  .
end.
  if is-edit = false then return no-apply .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY TOG-name TOG-inn TOG-kpp
      WITH FRAME Dialog-Frame.
  ENABLE b-OK RECT-7 b-exit B-Help TOG-name TOG-inn TOG-kpp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-OK :
  do on error undo, return error return-value :
    define variable Counter1 as integer   no-undo .
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
assign v-account = ( if integer( 5 ) = 0 then 100 else integer( 5 ) ).
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
    for each buf_fin-doc no-lock
      where  buf_fin-doc.host-code    = v-cntxt-host-code-obj
        and  buf_fin-doc.status_      = 'новый':U
      :
      find first buf_contract no-lock
        where buf_contract.host-code     = buf_fin-doc.host-code
          and buf_contract.contract-code = buf_fin-doc.contract-code
      no-error .
      if not available buf_contract then next.
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
      run writelog ( v-logfile, 0, string(Counter1,">>>9") + " Проверка фин. документа вн. номер " + string(buf_fin-doc.fin-doc-code) + " по договору вн.номер "  + string(buf_fin-doc.contract-code)) .
      assign
        Counter1 = Counter1 + 1
        is-edit  = no
      .
      if available tt-fin-doc then delete tt-fin-doc .
      for each tt-fin-doc-tax :   delete tt-fin-doc-tax .  end.
      for each tt-fin-doc-attr :  delete tt-fin-doc-attr . end.
      buffer-copy buf_fin-doc to tt-fin-doc .
      if tt-fin-doc.payer-code =  buf_contract.host-code and tt-fin-doc.payer-type = 'орг':U then do:
        if TOG-name then do:
          if tt-fin-doc.payer-name <> buf_contract.own-name then do:
            run writelog ( v-logfile, 0, "    Изменение наименования плательщика. " + tt-fin-doc.payer-name + " -> " + buf_contract.own-name ) .
            assign is-edit = yes  tt-fin-doc.payer-name = buf_contract.own-name .
          end.
        end.
        if TOG-inn then do:
          if tt-fin-doc.payer-inn <> buf_contract.own-inn then do:
            run writelog ( v-logfile, 0, "    Изменение ИНН плательщика. " + tt-fin-doc.payer-inn + " -> " + buf_contract.own-inn ) .
            assign is-edit = yes  tt-fin-doc.payer-inn = buf_contract.own-inn .
          end.
        end.
        if TOG-kpp then do:
          if tt-fin-doc.payer-kpp <> buf_contract.own-kpp then do:
            run writelog ( v-logfile, 0, "    Изменение КПП плательщика. " + tt-fin-doc.payer-kpp + " -> " + buf_contract.own-kpp ) .
            assign is-edit = yes  tt-fin-doc.payer-kpp = buf_contract.own-kpp .
          end.
        end.
        if tt-fin-doc.receiver-code =  buf_contract.cli-code and tt-fin-doc.receiver-type =  buf_contract.cli-type then do:
          assign  v-name = buf_contract.cli-name    v-inn  = buf_contract.cli-inn   v-kpp  = buf_contract.cli-kpp .
        end.
        else do:
          if tt-fin-doc.receiver-code =  buf_contract.posr-code and tt-fin-doc.receiver-type =  buf_contract.posr-type then do:
            assign  v-name = buf_contract.posr-name    v-inn  = buf_contract.posr-inn   v-kpp  = buf_contract.posr-kpp .
          end.
          else do:
            if tt-fin-doc.receiver-code =  buf_contract.agnt-code and tt-fin-doc.receiver-type =  buf_contract.agnt-type then do:
              assign  v-name = buf_contract.agnt-name    v-inn  = buf_contract.agnt-inn   v-kpp  = buf_contract.agnt-kpp .
            end.
          end.
        end.
        if TOG-name then do:
          if tt-fin-doc.receiver-name <> v-name then do:
            run writelog ( v-logfile, 0, "    Изменение наименования получателя. " + tt-fin-doc.receiver-name + " -> " + v-name ) .
            assign is-edit = yes   tt-fin-doc.receiver-name = v-name  .
          end.
        end.
        if TOG-inn then do:
          if tt-fin-doc.receiver-inn <> v-inn then do:
            run writelog ( v-logfile, 0, "    Изменение ИНН получателя. " + tt-fin-doc.receiver-inn + " -> " + v-inn ) .
            assign is-edit = yes   tt-fin-doc.receiver-inn = v-inn .
          end.
        end.
        if TOG-kpp then do:
          if tt-fin-doc.receiver-kpp <> v-kpp then do:
            run writelog ( v-logfile, 0, "    Изменение КПП получателя. " + tt-fin-doc.receiver-kpp + " -> " + v-kpp ) .
            assign is-edit = yes   tt-fin-doc.receiver-kpp = v-kpp .
          end.
        end.
      end.
      else do:
        if TOG-name then do:
          if tt-fin-doc.receiver-name <> buf_contract.own-name then do:
            run writelog ( v-logfile, 0, "    Изменение наименования получателя . " + tt-fin-doc.receiver-name + " -> " + buf_contract.own-name ) .
            assign is-edit = yes  tt-fin-doc.receiver-name = buf_contract.own-name .
          end.
        end.
        if TOG-inn then do:
          if tt-fin-doc.receiver-inn <> buf_contract.own-inn then do:
            run writelog ( v-logfile, 0, "    Изменение ИНН получателя . " + tt-fin-doc.receiver-inn + " -> " + buf_contract.own-inn ) .
            assign is-edit = yes  tt-fin-doc.receiver-inn = buf_contract.own-inn .
          end.
        end.
        if TOG-kpp then do:
          if tt-fin-doc.receiver-kpp <> buf_contract.own-kpp then do:
            run writelog ( v-logfile, 0, "    Изменение КПП получателя . " + tt-fin-doc.receiver-kpp + " -> " + buf_contract.own-kpp ) .
            assign is-edit = yes  tt-fin-doc.receiver-kpp = buf_contract.own-kpp .
          end.
        end.
        if tt-fin-doc.payer-code =  buf_contract.cli-code and tt-fin-doc.payer-type =  buf_contract.cli-type then do:
          assign  v-name = buf_contract.cli-name    v-inn  = buf_contract.cli-inn   v-kpp  = buf_contract.cli-kpp .
        end.
        else do:
          if tt-fin-doc.payer-code =  buf_contract.posr-code and tt-fin-doc.payer-type =  buf_contract.posr-type then do:
            assign  v-name = buf_contract.posr-name    v-inn  = buf_contract.posr-inn   v-kpp  = buf_contract.posr-kpp .
          end.
          else do:
            if tt-fin-doc.payer-code =  buf_contract.agnt-code and tt-fin-doc.payer-type =  buf_contract.agnt-type then do:
              assign  v-name = buf_contract.agnt-name    v-inn  = buf_contract.agnt-inn   v-kpp  = buf_contract.agnt-kpp .
            end.
          end.
        end.
        if TOG-name then do:
          if tt-fin-doc.payer-name <> v-name then do:
            run writelog ( v-logfile, 0, "    Изменение наименования плательщика. " + tt-fin-doc.payer-name + " -> " + v-name ) .
            assign is-edit = yes   tt-fin-doc.payer-name = v-name  .
          end.
        end.
        if TOG-inn then do:
          if tt-fin-doc.payer-inn <> v-inn then do:
            run writelog ( v-logfile, 0, "    Изменение ИНН плательщика. " + tt-fin-doc.payer-inn + " -> " + v-inn ) .
            assign is-edit = yes   tt-fin-doc.payer-inn = v-inn .
          end.
        end.
        if TOG-kpp then do:
          if tt-fin-doc.payer-kpp <> v-kpp then do:
            run writelog ( v-logfile, 0, "    Изменение КПП плательщика. " + tt-fin-doc.payer-kpp + " -> " + v-kpp ) .
            assign is-edit = yes   tt-fin-doc.payer-kpp = v-kpp .
          end.
        end.
      end.
      if is-edit = yes then do:
        define variable p-doc-rec as recid no-undo.
        for each fin-doc-tax no-lock where fin-doc-tax.host-code = v-cntxt-host-code-obj and fin-doc-tax.fin-doc-code = buf_fin-doc.fin-doc-code :
          buffer-copy fin-doc-tax to tt-fin-doc-tax .
        end.
        for each fin-doc-attr no-lock where fin-doc-attr.host-code = v-cntxt-host-code-obj and fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code :
          buffer-copy fin-doc-attr to tt-fin-doc-attr .
        end.
        assign p-doc-rec = recid (buf_fin-doc) .
        run writelog ( v-logfile, 0, "     " ) .
        tt-fin-doc.doc-author = "fin-ob".
        run ref/findoc0.p (
            input-output p-doc-rec
           ,input 'ИЗМЕНЕНИЕ':U
           ,input yes
           ,input tt-fin-doc.host-code            ,input tt-fin-doc.fin-doc-code         ,input tt-fin-doc.an-uchet-code        ,input tt-fin-doc.an-uchet-value       ,input tt-fin-doc.base-rate            ,input tt-fin-doc.base-scale           ,input tt-fin-doc.cel-nazn-code        ,input tt-fin-doc.cel-nazn-value       ,input tt-fin-doc.contract-code        ,input tt-fin-doc.contract-curr        ,input tt-fin-doc.contract-rate        ,input tt-fin-doc.contract-scale       ,input tt-fin-doc.cor-acc              ,input tt-fin-doc.cor-acc-value        ,input tt-fin-doc.cor-acc1             ,input tt-fin-doc.cor-acc1-value       ,input tt-fin-doc.curr-code            ,input tt-fin-doc.doc-date             ,input tt-fin-doc.shift-date           ,input tt-fin-doc.shift-num            ,input tt-fin-doc.shift-name           ,input tt-fin-doc.enclosure            ,input tt-fin-doc.exch-rate            ,input tt-fin-doc.exch-scale           ,input tt-fin-doc.f104                 ,input tt-fin-doc.f105                 ,input tt-fin-doc.f106                 ,input tt-fin-doc.f107                 ,input tt-fin-doc.f108                 ,input tt-fin-doc.f109                 ,input tt-fin-doc.f110                 ,input tt-fin-doc.f22                  ,input tt-fin-doc.f23                  ,input tt-fin-doc.fact-date            ,input tt-fin-doc.fin-doc-type         ,input tt-fin-doc.fin-ext-doc-type     ,input tt-fin-doc.in-doc-code          ,input tt-fin-doc.in-host-code         ,input tt-fin-doc.including            ,input tt-fin-doc.nazn-pl              ,input tt-fin-doc.naznach-plat         ,input tt-fin-doc.ocher-pl             ,input tt-fin-doc.out-doc-code         ,input tt-fin-doc.out-host-code        ,input tt-fin-doc.pay-date             ,input tt-fin-doc.payer-bank-name      ,input tt-fin-doc.payer-bank-city      ,input tt-fin-doc.payer-bik            ,input tt-fin-doc.payer-c-schet        ,input tt-fin-doc.payer-code           ,input tt-fin-doc.payer-code-schet     ,input tt-fin-doc.payer-dop1           ,input tt-fin-doc.payer-dop2           ,input tt-fin-doc.payer-inn            ,input tt-fin-doc.payer-kpp            ,input tt-fin-doc.payer-name           ,input tt-fin-doc.payer-okpo           ,input tt-fin-doc.payer-passport      ,input tt-fin-doc.payer-r-schet        ,input tt-fin-doc.payer-type           ,input tt-fin-doc.perm-date            ,input tt-fin-doc.prn-doc-code         ,input tt-fin-doc.PS                   ,input tt-fin-doc.receiver-bank-name   ,input tt-fin-doc.receiver-bank-city   ,input tt-fin-doc.receiver-bik         ,input tt-fin-doc.receiver-c-schet     ,input tt-fin-doc.receiver-code        ,input tt-fin-doc.receiver-code-schet  ,input tt-fin-doc.receiver-dop1        ,input tt-fin-doc.receiver-dop2        ,input tt-fin-doc.receiver-inn         ,input tt-fin-doc.receiver-kpp         ,input tt-fin-doc.receiver-name        ,input tt-fin-doc.receiver-okpo        ,input tt-fin-doc.receiver-passport    ,input tt-fin-doc.receiver-r-schet     ,input tt-fin-doc.receiver-type        ,input tt-fin-doc.srok-pl              ,input tt-fin-doc.stat-pl              ,input tt-fin-doc.str-podr-code        ,input tt-fin-doc.str-podr-type        ,input tt-fin-doc.str-podr-name        ,input tt-fin-doc.sum-base             ,input tt-fin-doc.sum-doc              ,input tt-fin-doc.sum-rubl             ,input tt-fin-doc.sum-contr            ,input tt-fin-doc.trn-doc-code         ,input tt-fin-doc.vid-opl              ,input tt-fin-doc.vid-plat
           ,input tt-fin-doc.con-sum-rubl         ,input tt-fin-doc.con-sum-base         ,input tt-fin-doc.con-sum-doc          ,input tt-fin-doc.con-sum-contr        ,input tt-fin-doc.con-stat             ,input tt-fin-doc.payer-sign1                ,input tt-fin-doc.payer-sign2                ,input tt-fin-doc.payer-sign3                ,input tt-fin-doc.payer-sign4                ,input tt-fin-doc.receiver-sign1                ,input tt-fin-doc.receiver-sign2                ,input tt-fin-doc.receiver-sign3                ,input tt-fin-doc.receiver-sign4                ,input tt-fin-doc.obj-type                   ,input tt-fin-doc.obj-code                   ,input tt-fin-doc.doc-author                 ,input tt-fin-doc.fact-author                ,input tt-fin-doc.CashBookId
           ,input table tt-fin-doc-tax
           ,input table tt-fin-doc-attr
           ,input no
           ,input table tt0-payment
         ) no-error .
       if error-status:error then do:
         run writelog ( v-logfile, 0, substitute( "&1&2&3", return-value, chr(10), error-status :get-message (1)) ) .
       end.
      end.
    end.
    if TOG-name then do:
      for each buf_fin-ob no-lock  where  buf_fin-ob.host-code = v-cntxt-host-code-obj
        :
        find first buf_contract no-lock where buf_contract.host-code = buf_fin-ob.host-code and buf_contract.contract-code = buf_fin-ob.contract-code no-error .
        if not available buf_contract then next.
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
        run writelog ( v-logfile, 0, string(Counter1,">>>9") + " Проверка фин. обязательства вн. номер " + string(buf_fin-ob.doc-code) + " по договору вн.номер "  + string(buf_fin-ob.contract-code)) .
        assign
          Counter1 = Counter1 + 1
          is-edit  = no
        .
        buffer-copy buf_fin-ob to tt-fin-ob .
        if tt-fin-ob.payer-code =  buf_contract.host-code and tt-fin-ob.payer-type = 'орг':U then do:
          if TOG-name then do:
            if tt-fin-ob.payer-name <> buf_contract.own-name then do:
              run writelog ( v-logfile, 0, "    Изменение наименования плательщика. " + tt-fin-ob.payer-name + " -> " + buf_contract.own-name ) .
              assign is-edit = yes  tt-fin-ob.payer-name = buf_contract.own-name .
            end.
          end.
          if tt-fin-ob.receiver-code =  buf_contract.cli-code and tt-fin-ob.receiver-type =  buf_contract.cli-type then assign  v-name = buf_contract.cli-name .
          else do:
            if tt-fin-ob.receiver-code =  buf_contract.posr-code and tt-fin-ob.receiver-type =  buf_contract.posr-type then assign  v-name = buf_contract.posr-name .
            else do:
              if tt-fin-ob.receiver-code =  buf_contract.agnt-code and tt-fin-ob.receiver-type =  buf_contract.agnt-type then assign  v-name = buf_contract.agnt-name .
            end.
          end.
          if TOG-name then do:
            if tt-fin-ob.receiver-name <> v-name then do:
              run writelog ( v-logfile, 0, "    Изменение наименования получателя. " + tt-fin-ob.receiver-name + " -> " + v-name ) .
              assign is-edit = yes   tt-fin-ob.receiver-name = v-name  .
            end.
          end.
        end.
        else do:
          if TOG-name then do:
            if tt-fin-ob.receiver-name <> buf_contract.own-name then do:
              run writelog ( v-logfile, 0, "    Изменение наименования получателя . " + tt-fin-ob.receiver-name + " -> " + buf_contract.own-name ) .
              assign is-edit = yes  tt-fin-ob.receiver-name = buf_contract.own-name .
            end.
          end.
          if tt-fin-ob.payer-code =  buf_contract.cli-code and tt-fin-ob.payer-type =  buf_contract.cli-type then  assign  v-name = buf_contract.cli-name .
          else do:
            if tt-fin-ob.payer-code =  buf_contract.posr-code and tt-fin-ob.payer-type =  buf_contract.posr-type then  assign  v-name = buf_contract.posr-name .
            else do:
              if tt-fin-ob.payer-code =  buf_contract.agnt-code and tt-fin-ob.payer-type =  buf_contract.agnt-type then  assign  v-name = buf_contract.agnt-name .
            end.
          end.
          if TOG-name then do:
            if tt-fin-ob.payer-name <> v-name then do:
              run writelog ( v-logfile, 0, "    Изменение наименования плательщика. " + tt-fin-ob.payer-name + " -> " + v-name ) .
              assign is-edit = yes   tt-fin-ob.payer-name = v-name  .
            end.
          end.
        end.
        if is-edit = yes then do:
          find first fin-ob exclusive-lock where recid(fin-ob) = recid(buf_fin-ob) .
          assign
            fin-ob.payer-name    = tt-fin-ob.payer-name
            fin-ob.receiver-name = tt-fin-ob.receiver-name
          .
        end.
      end.
    end.
if mFrameView
then do:
   HIDE FRAME InfoFrame.
end.
    define variable s-list as character no-undo .
    run gbl/prnfilen.w ( input  "Результат работы утилиты", input  0, input v-logfile, input  7, output s-list, output is-edit ).
  end.
end procedure.
