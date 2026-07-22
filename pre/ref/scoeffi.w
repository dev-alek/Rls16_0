DEFINE TEMP-TABLE tree-s-coeff NO-UNDO LIKE ub.s-coeff.
DEFINE TEMP-TABLE tt-s-coeff NO-UNDO LIKE ub.s-coeff.
define input parameter parparentproc as widget-handle no-undo .
define input parameter ref-mode as char no-undo.
define input parameter p-gds-code like ub.s-coeff.gds-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo.
define input parameter p-obj-type like ub.clients.obj-type no-undo.
define input parameter p-obj-code like ub.clients.obj-code no-undo.
DEFINE INPUT-output PARAMETER TABLE FOR tt-s-coeff .
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tree-s-coeff.
define output parameter p-result as character no-undo.
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Карточка значения сезонного коэффициента" .
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
define buffer b-objects for ub.clients.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE s-month AS CHARACTER FORMAT "X(10)":U INITIAL "Январь"
     VIEW-AS COMBO-BOX INNER-LINES 12
     LIST-ITEMS "Январь","Февраль","Март","Апрель","Май","Июнь","Июль","Август","Сентябрь","Октябрь","Ноябрь","Декабрь"
     DROP-DOWN-LIST
     SIZE 13.13 BY 1 NO-UNDO.
DEFINE VARIABLE f-day AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "Начало действия коэффициента"
     VIEW-AS FILL-IN
     SIZE 3.63 BY 1 NO-UNDO.
DEFINE VARIABLE for-obj-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 37.88 BY 1 NO-UNDO.
DEFINE VARIABLE host-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 51.5 BY 1 NO-UNDO.
DEFINE VARIABLE var-region AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 24 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-region
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 72 BY 6.46.
DEFINE QUERY Dialog-Frame FOR
      tt-s-coeff SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 41
     tt-s-coeff.coeff-value AT ROW 2.17 COL 10.38 COLON-ALIGNED
          LABEL "Значение" FORMAT ">9.999%"
          VIEW-AS FILL-IN
          SIZE 14.25 BY 1
     tt-s-coeff.s-date AT ROW 2.25 COL 57.38 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 10.75 BY 1
     s-month AT ROW 3.33 COL 41.63 COLON-ALIGNED NO-LABEL
     f-day AT ROW 3.38 COL 36 COLON-ALIGNED
     var-region AT ROW 5.5 COL 19.38 COLON-ALIGNED NO-LABEL
     host-name AT ROW 7.08 COL 19 COLON-ALIGNED NO-LABEL
     tt-s-coeff.host-code AT ROW 7.13 COL 1.88 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 5.88 BY 1
     tt-s-coeff.obj-type AT ROW 9.54 COL 1.63 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 6.13 BY 1
     tt-s-coeff.obj-code AT ROW 9.54 COL 8.75 COLON-ALIGNED NO-LABEL
           VIEW-AS TEXT
          SIZE 10.63 BY 1
     for-obj-name AT ROW 9.58 COL 20.75 COLON-ALIGNED NO-LABEL
     RECT-region AT ROW 4.83 COL 2.13
     "Область действия:" VIEW-AS TEXT
          SIZE 16.63 BY 1 AT ROW 5.5 COL 3.38
          FGCOLOR 4
     SPACE(55.98) SKIP(5.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод значения сезонного коэффициента"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       tt-s-coeff.s-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       s-month:PRIVATE-DATA IN FRAME Dialog-Frame     =
                "1,2,3,4,5,6,7,8,9,10,11,12".
ON GO OF FRAME Dialog-Frame
DO:
 define variable v-dop-date as date no-undo .
 DEFINE VARIABLE v-today as date no-undo .
 DEFINE VARIABLE v-time as integer no-undo .
 assign
 frame Dialog-Frame s-month
 f-day.
 assign
 v-dop-date = date(integer(entry(lookup(s-month, s-month:list-items), s-month:private-data)), f-day, 1996)
 no-error .
 if error-status:error then do:
  message
  "Неверно выбрана дата"
  view-as alert-box error .
  return no-apply.
 end.
 find first tree-s-coeff no-lock where
            tree-s-coeff.gds-code = p-gds-code
        AND tree-s-coeff.host-code = p-host-code
        AND tree-s-coeff.obj-type = p-obj-type
        AND tree-s-coeff.obj-code = p-obj-code
        AND tree-s-coeff.s-date = v-dop-date
        No-ERROR.
  if available tree-s-coeff then do:
    message
    "Уже задано значение сезонного коэффициента"
    "товар" tree-s-coeff.gds-code skip
    "фирма" tree-s-coeff.host-code "объект" tree-s-coeff.obj-type tree-s-coeff.obj-code
    "дата" string(string(DAY(tree-s-coeff.s-date)) + chr(47) + string(Month(tree-s-coeff.s-date)))
    view-as alert-box  error .
    return no-apply.
  end.
  if input frame Dialog-Frame tt-s-coeff.coeff-value = 100 then do:
    message
    "Сезонный коэффициент не может равняться 100"
    view-as alert-box error .
    return no-apply.
  end.
  run cur-time in this-procedure(output v-today, output v-time).
  create tree-s-coeff.
  assign
  tree-s-coeff.gds-code = p-gds-code
  tree-s-coeff.coeff-value = input frame Dialog-Frame tt-s-coeff.coeff-value
  tree-s-coeff.host-code = input frame Dialog-Frame tt-s-coeff.host-code
  tree-s-coeff.obj-type = input frame Dialog-Frame tt-s-coeff.obj-type
  tree-s-coeff.obj-code = input frame Dialog-Frame tt-s-coeff.obj-code
  tree-s-coeff.s-date = V-DOP-DATE
  tree-s-coeff.creid = g#userid
  tree-s-coeff.credate = v-today
  .
  find first tt-s-coeff no-lock where
               tt-s-coeff.gds-code = p-gds-code
          AND tt-s-coeff.s-date = tree-s-coeff.s-date no-error.
    if not available tt-s-coeff then do:
    create tt-s-coeff.
    assign
    tt-s-coeff.gds-code = p-gds-code
    tt-s-coeff.coeff-value = input frame Dialog-Frame tt-s-coeff.coeff-value
    tt-s-coeff.host-code = input frame Dialog-Frame tt-s-coeff.host-code
    tt-s-coeff.obj-type = input frame Dialog-Frame tt-s-coeff.obj-type
    tt-s-coeff.obj-code = input frame Dialog-Frame tt-s-coeff.obj-code
    tt-s-coeff.s-date = v-dop-date
    tt-s-coeff.creid = g#userid
    tt-s-coeff.credate = v-today
    .
    assign
    p-result = string(recid(tt-s-coeff))
    .
    end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if ref-mode <> 'ДОБАВЛЕНИЕ':U then do:
        message vss-workfile vss-revision vss-description skip
                    "Неверный параметр вызова ref-mode"
        view-as alert-box ERROR.
        return error.
    end.
    if (p-host-code = 0 and
           (p-obj-type <> "":U or p-obj-code <> 0)) OR
           (p-obj-type = "":U and p-obj-code <> 0) or
           (p-obj-type <> "" and  p-obj-code = 0)
            then do:
            message vss-workfile vss-revision vss-description skip
                        "Неверный параметр вызова p-host-code и/или p-obj-type и/или p-obj-code"
            view-as alert-box ERROR.
            return error.
    end.
    var-region = "Глобально".
    if p-host-code <> 0 then do:
        find first ub.clients No-LOCK WHERE
                ub.clients.obj-type = 'орг':U and
                ub.clients.obj-code = p-host-code No-ERROR.
        var-region = "Фирма: ".
    end.
    if p-obj-code <> 0 then do:
        find first b-objects No-LOCK WHERE
                b-objects.obj-type = p-obj-type and
                b-objects.obj-code = p-obj-code No-ERROR.
            var-region = "Объект: ".
    end.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-s-coeff SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY s-month f-day var-region host-name for-obj-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-s-coeff THEN
    DISPLAY tt-s-coeff.coeff-value tt-s-coeff.host-code tt-s-coeff.obj-type
          tt-s-coeff.obj-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-help tt-s-coeff.coeff-value s-month f-day var-region
         host-name tt-s-coeff.host-code tt-s-coeff.obj-type tt-s-coeff.obj-code
         for-obj-name RECT-region
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE Myenable :
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
assign
s-month = entry(1, s-month:list-items in frame Dialog-Frame)
.
  ENABLE
  B-exit
  B-quit
  B-help
  tt-s-coeff.coeff-value
  s-month
  f-day
  WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  run cur-time in this-procedure(output v-today, output v-time).
  DISPLAY
  s-month
  var-region
  0 @ tt-s-coeff.coeff-value
  1 @ f-day
  WITH FRAME Dialog-Frame.
  if p-host-code > 0 then
     DISPLAY
     p-host-code @ tt-s-coeff.host-code
     (if avail ub.clients then ub.clients.obj-name else "":U) @ host-name
    WITH FRAME Dialog-Frame.
    if p-obj-code <> 0 then do:
      DISPLAY
      p-obj-type @ tt-s-coeff.obj-type
      p-obj-code @ tt-s-coeff.obj-code
      (if avail b-objects then b-objects.obj-name else "":U) @ for-obj-name
       WITH FRAME Dialog-Frame.
 end.
END PROCEDURE.
