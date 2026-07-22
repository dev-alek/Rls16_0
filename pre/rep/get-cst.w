define input parameter parparentproc as widget-handle no-undo .
define input-output parameter from-date    as date no-undo .
define input-output parameter to-date    as date no-undo .
define input parameter p-curr-host-code-obj like ub.sysconf.host-code no-undo .
DEFINE INPUT  PARAMETER parobj-type  LIKE clients.obj-type NO-UNDO.
DEFINE OUTPUT PARAMETER parcli-type  LIKE clients.obj-type NO-UNDO.
DEFINE OUTPUT PARAMETER parcli-code  LIKE clients.obj-code NO-UNDO.
DEFINE OUTPUT PARAMETER partnved     AS CHARACTER     format "x(10)"     NO-UNDO.
DEFINE OUTPUT PARAMETER parcst-units AS CHARACTER          NO-UNDO.
DEFINE OUTPUT PARAMETER is-ok        AS LOGICAL INITIAL FALSE NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Окно ввода параметров для таможенных отчетов".
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
DEFINE  SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var ref-list as char no-undo.
def var f-name   as char no-undo.
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-ok AUTO-GO DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON r-clients
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88.
DEFINE BUTTON r-tnved
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-tnved"
     SIZE 3 BY .88.
DEFINE VARIABLE date-b AS DATE FORMAT "99/99/9999":U
     LABEL "&С"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE date-e AS DATE FORMAT "99/99/9999":U
     LABEL "&По"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE varcli-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.75 BY 1 NO-UNDO.
DEFINE VARIABLE varcli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 59.5 BY 1 NO-UNDO.
DEFINE VARIABLE varcli-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Об&ъект"
     VIEW-AS FILL-IN
     SIZE 4.88 BY 1 NO-UNDO.
DEFINE VARIABLE varTnved AS CHARACTER FORMAT "X(256)":U
     LABEL "&Уровень ТНВЕД"
     VIEW-AS FILL-IN
     SIZE 11.25 BY 1 NO-UNDO.
DEFINE VARIABLE vartnved-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 59.13 BY 1 NO-UNDO.
DEFINE VARIABLE varcst-units AS CHARACTER INITIAL "Таможенная"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Таможенная", "Таможенная",
"Ба&зовая", "Базовая"
     SIZE 39.88 BY 1 NO-UNDO.
DEFINE VARIABLE varrstnved AS CHARACTER INITIAL "Корень"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Корень", "Корень",
"&Выборочно", "Выборочно"
     SIZE 28.5 BY 1.04 NO-UNDO.
DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 60.88 BY 3.29.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 62.75 BY 9.96.
DEFINE FRAME get-rep
     b-ok AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 41
     date-b AT ROW 3.17 COL 4 COLON-ALIGNED
     date-e AT ROW 3.17 COL 23.38 COLON-ALIGNED
     varcli-type AT ROW 3.17 COL 44 COLON-ALIGNED
     varcli-code AT ROW 3.17 COL 50.13 COLON-ALIGNED NO-LABEL
     r-clients AT ROW 3.17 COL 59.5
     varcst-units AT ROW 7.04 COL 22 NO-LABEL
     varTnved AT ROW 9.5 COL 3.38
     r-tnved AT ROW 9.5 COL 30.5
     varrstnved AT ROW 9.5 COL 33.75 NO-LABEL
     varcli-name AT ROW 4.79 COL 2.88 NO-LABEL
     vartnved-name AT ROW 11.04 COL 3 NO-LABEL
     "Единица измерения:" VIEW-AS TEXT
          SIZE 18.13 BY 1 AT ROW 7.04 COL 3.38
          BGCOLOR 7
     RECT-3 AT ROW 2.67 COL 1
     RECT-22 AT ROW 9.13 COL 1.88
     SPACE(1.47) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Задайте параметры отчета"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME get-rep:SCROLLABLE       = FALSE.
ON CHOOSE OF b-ok IN FRAME get-rep
DO:
    assign frame get-rep
        date-b
        date-e
        vartnved
        varcli-type
        varcli-code
        varcst-units
        .
    if date-e < date-b then
        do:
            message "Дата начала периода не может быть больше даты окончания!" view-as alert-box ERROR.
            APPLY "ENTRY" TO date-b IN FRAME get-rep.
            return no-apply.
        end.
    IF varTnved <> "Всё" THEN DO:
      find first tt-tnved where tt-tnved.tnved = vartnved no-error.
      if not available tt-tnved then do:
            message "Неверный код ТНВЭД" view-as alert-box ERROR.
            APPLY "ENTRY" TO vartnved IN FRAME get-rep.
            return no-apply.
      end.
    END.
    IF parobj-type <> "all" then do:
       RUN check-cli no-error.
       IF error-status:error then return no-apply.
    end.
   assign
   from-date    = date-b
   to-date      = date-e
   parcli-type  = varcli-type
   parcli-code  = varcli-code
   partnved     = vartnved
   parcst-units = varcst-units
   is-ok        = yes no-error.
END.
ON return OF date-b IN FRAME get-rep
DO:
  apply "entry" to date-e in frame get-rep.
  return no-apply.
END.
ON RETURN OF date-e IN FRAME get-rep
DO:
    APPLY "ENTRY" TO varcli-type IN FRAME get-rep.
    RETURN NO-APPLY.
END.
ON CHOOSE OF r-clients IN FRAME get-rep
DO:
  RUN chs-cli no-error.
  if error-status:error then return no-apply.
  run check-cli no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF r-tnved IN FRAME get-rep
DO:
  RUN ch-tnved.
END.
ON MOUSE-SELECT-DBLCLICK OF varcli-code IN FRAME get-rep
DO:
  RUN check-cli no-error.
  IF error-status:error then do:
     RUN chs-cli no-error.
     IF error-status:error then return no-apply.
     RUN check-cli no-error.
  END.
  if not error-status:error then
     apply "entry" to varcst-units in frame get-rep.
  return no-apply.
END.
ON RETURN OF varcli-code IN FRAME get-rep
DO:
  RUN check-cli no-error.
  IF error-status:error then do:
     RUN chs-cli no-error.
     IF error-status:error then return no-apply.
     RUN check-cli no-error.
  END.
  if not error-status:error then
     apply "entry" to varcst-units in frame get-rep.
  return no-apply.
END.
ON MOUSE-SELECT-DBLCLICK OF varcli-type IN FRAME get-rep
DO:
  RUN check-cli no-error.
  IF error-status:error then do:
     RUN chs-cli no-error.
     IF error-status:error then return no-apply.
     RUN check-cli no-error.
  END.
  apply "entry" to varcst-units in frame get-rep.
  return no-apply.
END.
ON RETURN OF varcli-type IN FRAME get-rep
DO:
  RUN check-cli no-error.
  IF error-status:error then do:
     RUN chs-cli no-error.
     IF error-status:error then return no-apply.
     RUN check-cli no-error.
  END.
  apply "entry" to varcst-units in frame get-rep.
  return no-apply.
END.
ON return OF varcst-units IN FRAME get-rep
DO:
  apply "entry" to varrstnved in frame get-rep.
  return no-apply.
END.
ON return OF varrstnved IN FRAME get-rep
DO:
  if input frame get-rep varrstnved = "корень" then
      apply "entry" to b-ok in frame get-rep.
  else
      apply "entry" to vartnved in frame get-rep.
  return no-apply.
END.
ON VALUE-CHANGED OF varrstnved IN FRAME get-rep
DO:
  RUN st-tnved.
END.
ON RETURN OF varTnved IN FRAME get-rep
DO:
    find first tt-tnved where tt-tnved.tnved = input frame get-rep vartnved no-error.
    if not available tt-tnved then do:
       message "Неверный код ТНВЭД." view-as alert-box error.
       RUN ch-tnved no-error.
    end.
    display tt-tnved.f-name @ vartnved-name with frame get-rep.
    apply "entry" to b-ok in frame get-rep.
    return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME get-rep:PARENT eq ?
THEN FRAME get-rep:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame get-rep
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
on choose of b-help in frame get-rep
do:
  apply "help":u to frame get-rep .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame get-rep:width - 0.3
                fh            = frame get-rep:first-child
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
ON WINDOW-CLOSE OF FRAME get-rep APPLY "END-ERROR":U TO SELF.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if from-date = ? OR to-date = ?
  then do:
        define variable v-today as date      no-undo.
        define variable v-time  as integer   no-undo.
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        assign
            from-date = date( month( v-today ), 01, year( v-today ) )
            to-date   = v-today
        .
  end.
  assign
      date-b = from-date
      date-e = to-date
      .
  RUN enable_UI.
  if parobj-type = "all" then do:
     disable varcli-type varcli-code r-clients with frame get-rep.
     hide varcli-type varcli-code r-clients in frame get-rep.
  end.
  RUN st-tnved.
  WAIT-FOR GO OF FRAME get-rep FOCUS date-b.
END.
RUN disable_UI.
PROCEDURE ch-tnved :
  DEFINE VARIABLE rid-tnved AS RECID NO-UNDO.
  run ref/t-tnved.w (no, output rid-tnved).
  find first tt-tnved where RECID(tt-tnved) = rid-tnved no-lock no-error.
  if available tt-tnved then disp tt-tnved.tnved  @ vartnved
                                  tt-tnved.f-name @ vartnved-name with frame get-rep.
END PROCEDURE.
PROCEDURE check-cli :
find clients where clients.obj-code = input frame get-rep varcli-code
               and clients.obj-type = input frame get-rep varcli-type no-error.
if not available clients then do:
  if input frame get-rep varcli-code <> ? and
     input frame get-rep varcli-type <> ? then
    message "Неправильный код или тип контрагента." view-as alert-box error.
  apply "entry" to varcli-code in frame get-rep.
  return error.
end.
disp clients.obj-type @ varcli-type with frame get-rep.
if parobj-type = "" or
  clients.obj-type = parobj-type then do:
  if clients.obj-type = 'скл':U then do:
      find store where store.obj-code = clients.obj-code no-lock.
      if store.host-code <> p-curr-host-code-obj then do:
        release clients no-error.
        message "Выбран склад другой фирмы."  view-as alert-box error.
        apply "entry" to varcli-code in frame get-rep.
        return error.
      end.
  end.
  else if clients.obj-type = 'маг':U then do:
      find shop where shop.obj-code = clients.obj-code no-lock.
      if shop.host-code <> p-curr-host-code-obj then do:
        release clients no-error.
        message "Выбран магазин другой фирмы." view-as alert-box error.
        apply "entry" to varcli-code in frame get-rep.
        return error.
      end.
  end.
  else do:
        message "Выберите внутренний склад или магазин." view-as alert-box error.
        apply "entry" to varcli-code in frame get-rep.
        return error.
  end.
end.
else do:
  release clients no-error.
  message "Отчет по внутренним " (if parobj-type = 'маг':U then "магазинам." else "складам.")
          "Выберите внутренний " (if parobj-type = 'маг':U then "магазин." else "склад.") view-as alert-box error.
  apply "entry" to varcli-code in frame get-rep.
  return error.
end.
varcli-code = input frame get-rep varcli-code.
varcli-type = input frame get-rep varcli-type.
disp clients.obj-name @ varcli-name with frame get-rep.
release clients.
END PROCEDURE.
PROCEDURE chs-cli :
define variable v-ref-rec as recid no-undo .
  run ref/cli-all.w ( parparentproc
                 , "b-sel"
                 , parobj-type
                 , ?
                 , ?
                 , ?
                 , ?
                 , ?
                 , output ref-list) .
  if ref-list <> "" then do:
    v-ref-rec = integer (ref-list).
    find clients where recid ( clients ) = v-ref-rec no-lock.
    disp clients.obj-code @ varcli-code
         clients.obj-name @ varcli-name
         clients.obj-type @ varcli-type with frame get-rep.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME get-rep.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY date-b date-e varcli-type varcli-code varcst-units varTnved varrstnved
          varcli-name vartnved-name
      WITH FRAME get-rep.
  ENABLE b-ok RECT-3 RECT-22 b-quit b-help date-b date-e varcli-type
         varcli-code r-clients varcst-units varrstnved
      WITH FRAME get-rep.
END PROCEDURE.
PROCEDURE st-tnved :
  case input frame get-rep varrstnved:
    when "Корень" then do:
      DISPLAY "Всё" @ vartnved
              ""    @ vartnved-name WITH FRAME get-rep.
      DISABLE vartnved r-tnved WITH FRAME get-rep.
    end.
    otherwise do:
      DISPLAY "?" @ vartnved WITH FRAME get-rep.
      ENABLE vartnved r-tnved WITH FRAME get-rep.
      APPLY "ENTRY" TO r-tnved.
      RETURN NO-APPLY.
    end.
  end case.
END PROCEDURE.
