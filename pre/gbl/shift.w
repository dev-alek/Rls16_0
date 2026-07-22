define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input-output parameter s-date    as date         no-undo.
define input-output parameter e-date    as date         no-undo.
define input-output parameter s-time    as integer      no-undo.
define input-output parameter e-time    as integer      no-undo.
define input-output parameter s-num     as integer      no-undo.
define input-output parameter s-name    as character    no-undo.
define input parameter  p-option        as character    no-undo.
define output parameter p-cancel        as logical      no-undo.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Справоник смен".
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
procedure cmptime :
do
on error undo, return error
:
define output parameter p-difference as decimal      no-undo.
define variable v-srv-time      as decimal           no-undo.
define variable v-cli-time      as decimal           no-undo.
assign
    session :time-source = "ub":U
    v-srv-time = integer(today) + ( time / 86400 )
.
assign
    session :time-source = "LOCAL":U
    v-cli-time = integer(today) + ( time / 86400 )
.
assign
    p-difference = ( v-srv-time - v-cli-time ) * 1440
.
end.
end procedure.
procedure cmptime-time-diff :
do
on error undo, return error
:
define input parameter p-date1          as date         no-undo.
define input parameter p-time1          as integer      no-undo.
define input parameter p-date2          as date         no-undo.
define input parameter p-time2          as integer      no-undo.
define output parameter p-difference    as decimal      no-undo.
    assign
        p-difference = ( integer( p-date2 ) - integer( p-date1 ) + ( ( p-time2 - p-time1 ) / 86400 ) ) * 1440
    .
end.
end procedure.
procedure cmptime-string-to-hms :
do
on error undo, return error
:
define input parameter p-time-string as character    no-undo.
define input parameter p-format      as character    no-undo.
define output parameter p-hour as integer      no-undo.
define output parameter p-min  as integer      no-undo.
define output parameter p-sec  as integer      no-undo.
if p-format <> "hh:mm" and p-format <> "hh:mm:ss"
then do:
    message
      "cmptime.i: Ошибка преобразования строки даты"
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
assign
    p-hour      = integer ( entry( 1, p-time-string, ":" ) )
    p-min       = integer ( entry( 2, p-time-string, ":" ) )
    p-sec       = ( if p-format = "hh:mm:ss"
                    then integer ( entry( 3, p-time-string, ":" ) )
                    else 0
                  )
.
end.
end procedure.
procedure cmptime-hms-to-integer :
do
on error undo, return error
:
define input parameter p-hour   as integer      no-undo.
define input parameter p-min    as integer      no-undo.
define input parameter p-sec    as integer      no-undo.
define output parameter p-time  as integer      no-undo.
    assign
        p-time = p-hour * 3600 + ( p-min * 60 ) + p-sec
    .
end.
end procedure.
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
define variable v-today         as date             no-undo.
define variable v-time          as integer          no-undo.
define variable v-exit-enabled  as logical init no  no-undo.
DEFINE BUFFER bf_shift-obj FOR ub.shift-obj.
DEFINE BUTTON b-exit
     LABEL "&Ввод "
     SIZE 12 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-Help
     LABEL "Помо&щь"
     SIZE 12 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-quit
     LABEL "&Отмена"
     SIZE 12 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE f-date AS DATE FORMAT "99/99/99":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE fi-colon AS CHARACTER FORMAT "X(1)":U INITIAL ":"
      VIEW-AS TEXT
     SIZE 1.6 BY 1.05 NO-UNDO.
DEFINE VARIABLE fi-colon-2 AS CHARACTER FORMAT "X(1)":U INITIAL ":"
      VIEW-AS TEXT
     SIZE 1.6 BY 1.05 NO-UNDO.
DEFINE VARIABLE fi-start-date AS DATE FORMAT "99/99/99":U
     LABEL "Начало смены"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE fi-start-hour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.
DEFINE VARIABLE fi-start-min AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.
DEFINE VARIABLE l-loc-hour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.
DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.
DEFINE VARIABLE rs-name AS CHARACTER FORMAT "X(2)":U INITIAL "0"
     LABEL "Номер смены"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE rs-num AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Порядок смены"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE FRAME d-shift
     b-exit AT ROW 1.29 COL 2.2
     b-quit AT ROW 1.29 COL 14.6
     b-Help AT ROW 1.29 COL 27.8
     fi-start-date AT ROW 3.19 COL 16 COLON-ALIGNED
     fi-start-hour AT ROW 3.19 COL 29 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     fi-start-min AT ROW 3.19 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     f-date AT ROW 5.19 COL 16 COLON-ALIGNED
     l-loc-hour AT ROW 5.19 COL 29 COLON-ALIGNED NO-LABEL
     l-loc-min AT ROW 5.19 COL 34 COLON-ALIGNED NO-LABEL
     rs-num AT ROW 7 COL 16.4 COLON-ALIGNED
     rs-name AT ROW 9 COL 16.4 COLON-ALIGNED
     fi-colon-2 AT ROW 3.19 COL 32.2 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     fi-colon AT ROW 5.19 COL 32.2 COLON-ALIGNED NO-LABEL
     SPACE(4.00) SKIP(4.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Номер и дата смены".
ASSIGN
       FRAME d-shift:SCROLLABLE       = FALSE
       FRAME d-shift:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME d-shift
DO:
    if v-exit-enabled = no
    then do:
        undo, return no-apply.
    end.
    APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME d-shift
DO:
  define variable cur-day           as date      no-undo .
  define variable cur-time          as integer   no-undo .
  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .
  define variable v-param-type      as character  no-undo .
  define variable v-difftime        as integer   no-undo initial 0.
  define variable v-diffdate        as integer   no-undo initial 0.
  run cur-time in this-procedure
    ( output cur-day
    , output cur-time
    ).
  assign
    s-date = input frame d-shift f-date
    s-num  = input frame d-shift rs-num
    s-name = left-trim(input frame d-shift rs-name, "0")
  .
  run cmptime-hms-to-integer in this-procedure
    ( input l-loc-hour
    , input l-loc-min
    , input 0
    , output s-time
    ).
  run cmptime-hms-to-integer(
    input fi-start-hour,
    input fi-start-min,
    input 0,
    output e-time
  ).
  if s-date >= cur-day
    and p-option = 'time-only':U
  then do:
    run adm/shattri.p
      ( input  "get":U
      , input  p-curr-obj-type
      , input  p-curr-obj-code
      , input  'obj-date':U
      , input  'difftime':U
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output v-param-type
      , input-output table-handle v-tth
      ) no-error .
    if not error-status :error
      and v-value-integer <> ?
    then do:
      assign
        v-difftime = v-value-integer
        no-error.
      if error-status :error
        or v-difftime < 0
      then do:
        delete object v-tth no-error.
        message
          "Неверно задан параметр difftime: " v-difftime skip
          "Параметр может принимать целые значения > 0." skip
          view-as alert-box error.
        return no-apply .
      end.
      else do:
        assign
          v-diffdate = truncate( v-difftime / 86400, 0 )
        .
        if s-date > cur-day + v-diffdate
          or ( s-date = cur-day + v-diffdate
               and s-time > cur-time + v-difftime * 60
             )
        then do:
          delete object v-tth no-error.
          message
            substitute( "Максимально возможное время закрытия смены: &1 &2"
                       , string( cur-day + v-diffdate, "99/99/9999":U )
                       , string( cur-time + v-difftime * 60, "HH:MM":U )
                      ) skip
            substitute( "Объект: &1 &2", p-curr-obj-type, p-curr-obj-code ) skip
            view-as alert-box error .
          return no-apply .
        end.
      end.
    end.
    delete object v-tth no-error.
  end.
  assign
    v-exit-enabled = yes
    p-cancel       = no
  .
  apply "window-close" to frame d-shift .
END.
ON CHOOSE OF b-quit IN FRAME d-shift
DO:
    assign
        v-exit-enabled  = yes
        p-cancel        = yes
    .
    apply "WINDOW-CLOSE" TO FRAME d-shift .
END.
ON LEAVE OF f-date IN FRAME d-shift
DO:
  if f-date <> input frame d-shift f-date then do:
    find last bf_shift-obj where bf_shift-obj.obj-type   = p-curr-obj-type and
                                 bf_shift-obj.obj-code   = p-curr-obj-code and
                                 bf_shift-obj.shift-date = INPUT FRAME d-shift f-date          use-index pi no-lock no-error.
    if not available bf_shift-obj then do:
      assign
        rs-num = 1.
    end.
    else do:
      assign
        rs-num = bf_shift-obj.shift-num + 1.
    end.
    assign
      rs-name = string (rs-num).
    display rs-num rs-name with frame d-shift.
    assign frame d-shift
      f-date.
  end.
END.
ON CURSOR-DOWN OF fi-start-hour IN FRAME d-shift
DO:
  assign  frame d-shift fi-start-hour .
  fi-start-hour = fi-start-hour -  1.
  if fi-start-hour < 0 then return no-apply.
  display fi-start-hour with frame d-shift.
END.
ON CURSOR-UP OF fi-start-hour IN FRAME d-shift
DO:
  assign  frame d-shift fi-start-hour .
  fi-start-hour = fi-start-hour +  1.
  if fi-start-hour > 23 then return no-apply.
  display fi-start-hour with frame d-shift.
END.
ON LEAVE OF fi-start-hour IN FRAME d-shift
DO:
  assign frame d-shift fi-start-hour .
   if fi-start-hour > 23 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if fi-start-hour < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF fi-start-min IN FRAME d-shift
DO:
  assign  frame d-shift fi-start-min .
  fi-start-min = fi-start-min -  1.
  if fi-start-min < 0 then return no-apply.
  display fi-start-min with frame d-shift.
END.
ON CURSOR-UP OF fi-start-min IN FRAME d-shift
DO:
   assign  frame d-shift fi-start-min .
  fi-start-min = fi-start-min +  1.
  if fi-start-min > 59 then return no-apply.
  display fi-start-min with frame d-shift.
END.
ON LEAVE OF fi-start-min IN FRAME d-shift
DO:
    assign frame d-shift fi-start-min .
   if fi-start-min > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-hour IN FRAME d-shift
DO:
  assign  frame d-shift l-loc-hour .
  l-loc-hour = l-loc-hour -  1.
  if l-loc-hour < 0 then return no-apply.
  display l-loc-hour with frame d-shift.
END.
ON CURSOR-UP OF l-loc-hour IN FRAME d-shift
DO:
  assign  frame d-shift l-loc-hour .
  l-loc-hour = l-loc-hour +  1.
  if l-loc-hour > 23 then return no-apply.
  display l-loc-hour with frame d-shift.
END.
ON LEAVE OF l-loc-hour IN FRAME d-shift
DO:
  assign frame d-shift l-loc-hour .
   if l-loc-hour > 23 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if l-loc-hour < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-min IN FRAME d-shift
DO:
  assign  frame d-shift l-loc-min .
  l-loc-min = l-loc-min -  1.
  if l-loc-min < 0 then return no-apply.
  display l-loc-min with frame d-shift.
END.
ON CURSOR-UP OF l-loc-min IN FRAME d-shift
DO:
   assign  frame d-shift l-loc-min .
  l-loc-min = l-loc-min +  1.
  if l-loc-min > 59 then return no-apply.
  display l-loc-min with frame d-shift.
END.
ON LEAVE OF l-loc-min IN FRAME d-shift
DO:
    assign frame d-shift l-loc-min .
   if l-loc-min > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-shift:PARENT eq ?
THEN FRAME d-shift:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-shift
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
on choose of b-help in frame d-shift
do:
  apply "help":u to frame d-shift .
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
                v-frame-width = frame d-shift:width - 0.3
                fh            = frame d-shift:first-child
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    if s-date = ? or s-time = ? or s-num = 0 then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output f-date
  )  .
        assign
            fi-start-date   = date("")
            f-date :label   = "Дата"
            rs-num = 1
            l-loc-hour      = integer (entry(1,string(v-time,"hh:mm"),":"))
            l-loc-min       = integer (entry(2,string(v-time,"hh:mm"),":"))
        .
        find last bf_shift-obj where bf_shift-obj.obj-type   = p-curr-obj-type and
                                     bf_shift-obj.obj-code   = p-curr-obj-code and
                                     bf_shift-obj.shift-date = f-date          use-index pi no-lock no-error.
        if not available bf_shift-obj then do:
          assign
            rs-num = 1.
        end.
        else do:
          assign
            rs-num = bf_shift-obj.shift-num + 1.
        end.
        assign
          rs-name = string (rs-num).
    end.
    else do:
        assign
            rs-num  = s-num
            rs-name = s-name.
        case p-option :
          when 'edit-time':U then do:
            assign
                fi-start-date :label    = "Начало смены"
                fi-start-date           = s-date
                fi-start-hour           = integer (entry(1,string(s-time,"hh:mm"),":"))
                fi-start-min            = integer (entry(2,string(s-time,"hh:mm"),":"))
                f-date :label           = "Конец смены"
                f-date                  = e-date
                l-loc-hour              = integer (entry(1,string(e-time,"hh:mm"),":"))
                l-loc-min               = integer (entry(2,string(e-time,"hh:mm"),":"))
            .
          end.
          when 'time-only':U then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output f-date
  )  .
            assign
              fi-start-date :label    = "Начало смены"
                fi-start-date           = s-date
              f-date :label           = "Конец смены"
              l-loc-hour              = integer (entry(1,string(v-time,"hh:mm"),":"))
              l-loc-min               = integer (entry(2,string(v-time,"hh:mm"),":"))
            .
          end.
          when 'open-planned':U then do:
            assign
                fi-start-date   = date("")
              f-date :label   = "Дата"
              f-date          = s-date
              f-date :sensitive = no
              l-loc-hour      = integer (entry(1,string(s-time,"hh:mm"),":"))
              l-loc-min       = integer (entry(2,string(s-time,"hh:mm"),":"))
            .
          end.
          otherwise do:
            assign
                fi-start-date   = date("")
              f-date :label   = "Дата"
              f-date          = s-date
              l-loc-hour      = integer (entry(1,string(s-time,"hh:mm"),":"))
              l-loc-min       = integer (entry(2,string(s-time,"hh:mm"),":"))
            .
          end.
        end case.
    end.
    RUN enable_UI.
    if p-option = 'no-time'
    then do:
        assign
            l-loc-hour :visible = no
            l-loc-min  :visible = no
            fi-colon   :visible = no
        .
    end.
    if p-option = 'time-only'
    then do:
        assign
            f-date :sensitive = no
            rs-name :sensitive = no
        .
    end.
    if s-date <> ? then do:
      disable f-date with FRAME d-shift.
    end.
    if s-num <> ? then do:
      disable rs-num with FRAME d-shift.
    end.
    IF p-option <> "open-planned" THEN DO:
      ENABLE rs-name WITH FRAME d-shift.
    END.
    if p-option = 'edit-time'
    then do:
        disable rs-name with FRAME d-shift.
    end.
    else do:
        assign
            fi-colon-2    :visible = no
            fi-start-hour :visible = no
            fi-start-min  :visible = no
        .
    end.
  WAIT-FOR GO OF FRAME d-shift.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-shift.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY fi-start-date fi-start-hour fi-start-min f-date l-loc-hour l-loc-min
          rs-num rs-name fi-colon-2 fi-colon
      WITH FRAME d-shift.
  ENABLE b-exit b-quit b-Help fi-start-hour fi-start-min f-date l-loc-hour
         l-loc-min fi-colon-2 fi-colon
      WITH FRAME d-shift.
  VIEW FRAME d-shift.
END PROCEDURE.
