define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проведение upgrade".
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
define variable log-exit as logical no-undo .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-start AUTO-GO DEFAULT
     LABEL "&Запуск"
     SIZE 10 BY 1.
DEFINE BUTTON b-unblock DEFAULT
     LABEL "&Разблокировка пользователей"
     SIZE 30 BY 1.
DEFINE VARIABLE bp-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 11 BY .67 NO-UNDO.
DEFINE VARIABLE bp-step AS INTEGER FORMAT "9":U INITIAL 0
     LABEL "Шаг"
      VIEW-AS TEXT
     SIZE 2 BY .67 NO-UNDO.
DEFINE VARIABLE bp-time AS CHARACTER FORMAT "X(5)":U
     LABEL "Время"
      VIEW-AS TEXT
     SIZE 6 BY .67 NO-UNDO.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 33.13 BY 3.58.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 33.13 BY 1.75.
DEFINE FRAME upg-btpr
     b-quit AT ROW 1.17 COL 2
     b-help AT ROW 1.17 COL 12
     b-start AT ROW 2.96 COL 4.38
     b-unblock AT ROW 6.54 COL 3.38
     bp-date AT ROW 3 COL 21 COLON-ALIGNED
     bp-time AT ROW 4 COL 21 COLON-ALIGNED
     bp-step AT ROW 5.08 COL 21 COLON-ALIGNED
     RECT-5 AT ROW 6.13 COL 2.25
     RECT-4 AT ROW 2.54 COL 2.25
     SPACE(1.24) SKIP(2.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Запуск Upgrade"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME upg-btpr:SCROLLABLE       = FALSE.
ON WINDOW-CLOSE OF FRAME upg-btpr
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-quit IN FRAME upg-btpr
DO:
  assign
    log-exit = true
  .
END.
ON CHOOSE OF b-start IN FRAME upg-btpr
DO:
  define buffer buf_BatchProcess for ub.BatchProcess .
  define variable v-curr-date as date    no-undo .
  define variable v-curr-time as integer no-undo .
  define variable v-date      as date    no-undo .
  define variable v-time      as integer no-undo .
  run cur-time in this-procedure
    ( output v-curr-date
      ,output v-curr-time
    ) no-error.
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip
      "Ошибка при определении текущей даты!"
      view-as alert-box error.
    return no-apply.
  end.
  assign
    v-date = v-curr-date
    v-time = v-curr-time
  .
  do while true
  on error undo, return no-apply
  :
    run adm/d-ed-d-t.w ( input-output v-date
                    ,input-output v-time
                  ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при редактировании даты!"
        view-as alert-box error.
      return no-apply.
    end.
    if v-date = ?
      or v-time = ?
    then do:
      message "Время запуска не изменено!"
        view-as alert-box information.
      return no-apply.
    end.
    if v-date > v-curr-date
      or ( v-date = v-curr-date
            and v-time >= v-curr-time
          )
    then do:
      assign
        v-curr-date = v-date
        v-curr-time = v-time
      .
      leave.
    end.
    else do:
      message vss-workfile vss-revision vss-description skip(1)
        "Время запуска не может быть меньше текущего!"
        view-as alert-box error.
    end.
  end.
  run upg/upg-edbp.p
    ( input "upg":U
     ,input 1
     ,input 0
     ,input "Run":U
     ,input "":U
     ,input v-curr-date
     ,input v-curr-time
    ) no-error .
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip(1)
      "Ошибка при записи времени запуска Upgrade!"
      view-as alert-box error.
  end.
  else do:
    message 'Команда на запуск Upgrade отправлена' skip
      "и должна быть обработана в течении минуты." skip
      view-as alert-box information.
  end.
END.
ON CHOOSE OF b-unblock IN FRAME upg-btpr
DO:
  define buffer buf_BatchProcess for ub.BatchProcess .
  define variable v-curr-date as date    no-undo .
  define variable v-curr-time as integer no-undo .
  define variable v-log       as logical no-undo .
  message
    "Вы действительно хотите разблокировать пользователей и прекратить Upgrade?"
    view-as alert-box question buttons yes-no update v-log.
  if v-log = false then do:
    return no-apply.
  end.
  run cur-time in this-procedure
    ( output v-curr-date
     ,output v-curr-time
    ) no-error.
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip
      "Ошибка при определении текущей даты!"
      view-as alert-box error.
    return no-apply.
  end.
  run upg/upg-clbp.p no-error .
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip
      "Ошибка при удалении записей о времени запуска Upgrade !"
      view-as alert-box error.
    return no-apply.
  end.
  run upg/upg-edbp.p
    ( input "upg":U
     ,input 0
     ,input 0
     ,input "Run":U
     ,input "":U
     ,input v-curr-date
     ,input v-curr-time
    ) no-error .
  if error-status :error then do:
    message vss-workfile vss-revision vss-description skip(1)
      "Ошибка при записи времени запуска Upgrade!"
      view-as alert-box error.
  end.
  else do:
    message 'Команда отправлена' skip
      "и должна быть обработана в течении минуты." skip
      view-as alert-box information.
  end.
END.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame upg-btpr
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
on choose of b-help in frame upg-btpr
do:
  apply "help":u to frame upg-btpr .
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
                v-frame-width = frame upg-btpr:width - 0.3
                fh            = frame upg-btpr:first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME upg-btpr:PARENT eq ?
THEN FRAME upg-btpr:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  define buffer buf_BatchProcess for BatchProcess .
  define variable v-curr-date as date    no-undo .
  define variable v-curr-time as integer no-undo .
  assign
    log-exit = false
  .
  RUN enable_UI.
  do while not log-exit
  on error undo, return error
  :
    run cur-time in this-procedure
      ( output v-curr-date
       ,output v-curr-time
      ) no-error.
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущей даты!"
        view-as alert-box error.
      next.
    end.
    find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Type     = 'autoupg':U
        and buf_BatchProcess.Key#_One    = 0
        and buf_BatchProcess.CharKey_One = "upg":U
      no-error
    .
    if available buf_BatchProcess then do:
      if buf_BatchProcess.Key#_Three = 1 then do:
        enable b-unblock with frame upg-btpr.
      end.
      assign
        bp-date = buf_BatchProcess.BP_ExecSysDate
        bp-time = buf_BatchProcess.BP_ExecSysTime
        bp-step = buf_BatchProcess.Key#_Three
      .
      if buf_BatchProcess.BP_ExecSysDate < v-curr-date
        or ( buf_BatchProcess.BP_ExecSysDate = v-curr-date
             and buf_BatchProcess.BP_ExecSysTimeInt < v-curr-time
           )
      then do:
        disable b-start with frame upg-btpr.
      end.
    end.
    else do:
      assign
        bp-date = ?
        bp-time = ?
        bp-step = ?
      .
    end.
    display
      bp-date
      bp-time
      bp-step
      with frame upg-btpr
    .
    wait-for
      go of frame upg-btpr
      or close of this-procedure
      or choose of b-start in frame upg-btpr
      or choose of b-unblock in frame upg-btpr
      focus frame upg-btpr
      pause 1
    .
  end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME upg-btpr.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY bp-date bp-time bp-step
      WITH FRAME upg-btpr.
  ENABLE RECT-5 RECT-4 b-quit b-help b-start b-unblock
      WITH FRAME upg-btpr.
END PROCEDURE.
