define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отображение информации о состоянии складских архивов".
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
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-obj-arh no-undo
  field db-num                   as integer format ">9" label "БД"
  field obj-type                 like ub.clients.obj-type
  field obj-code                 like ub.clients.obj-code
  field archive-type             as character label "Архив"
  field sort-code                as integer
  field obj-deleted              as logical   label "У" format "У/ "
  field archive-calc             as logical   format "+/-":U         label 'Не рассчитан оборот'
  field archive-del              as logical   format "+/-":U         label 'Не рассчитан нач.остаток'
  field archive-disable          as logical   format "+/-":U         label 'Расчет архива запрещен'
  field archive-rest             as logical   format "+/-":U         label 'Сбой удал./восст.'
  field archive-bpexist          as logical   format "+/-":U         label 'Имеются задания на расчет'
  field archive-detail-date      as date      format '99/99/9999':u  label 'Подробный'
  field archive-start-date       as date      format '99/99/9999':u  label 'Сжатый'
  field archive-recalc-date      as date      format '99/99/9999':u  label 'Перерасчёт'
  field archive-lock-prc         as logical                          label 'Расчёт'
  field archive-execuser         like ub.batchprocess.bp_execuser_id label 'Пользователь' column-label 'Пользователь'
  field archive-execsysdate      like ub.batchprocess.bp_execsysdate label 'Дата'         column-label 'Дата'
  field archive-execsystime      like ub.batchprocess.bp_execsystime label 'Время'        column-label 'Время'
  field archive-rest-lock-prc    as logical                          label 'Расчёт'
  field archive-rest-execuser    like ub.batchprocess.bp_execuser_id label 'Пользователь' column-label 'Пользователь'
  field archive-rest-execsysdate like ub.batchprocess.bp_execsysdate label 'Дата'         column-label 'Дата'
  field archive-rest-execsystime like ub.batchprocess.bp_execsystime label 'Время'        column-label 'Время'
  index xpk is primary unique obj-type obj-code archive-type
  index ie1 db-num obj-type obj-code archive-type
.
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
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
define variable v-object       as character no-undo format "x(9)"  label "Объект" .
define variable v-archive-type as character no-undo format "x(21)" label "Архив"  .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-filter-db as logical   no-undo .
define variable v-all-db    as character no-undo initial "Все" .
FUNCTION archive-type-name RETURNS CHARACTER
  ( input p-archive-type as character )  FORWARD.
FUNCTION history-description RETURNS CHARACTER
  ( input p-history-type as character )  FORWARD.
DEFINE BUTTON b-calc
     LABEL "Рассчитать"
     SIZE 12 BY 1.
DEFINE BUTTON b-calc-all
     LABEL "Рассчитать Все"
     SIZE 16 BY 1.
DEFINE BUTTON b-excel
     LABEL "E&xcel"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-hist
     LABEL "&История"
     SIZE 10 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.
DEFINE BUTTON b-refresh
     LABEL "Об&новить"
     SIZE 10 BY 1.
DEFINE VARIABLE cb-db AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE fi-calc-execsysdate AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Дата начала проходящего сейчас расчёта архива"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-calc-execsystime AS CHARACTER FORMAT "X(5)":U
     LABEL "Время"
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Время начала проходящего сейчас расчёта архива"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-calc-execuser AS CHARACTER FORMAT "X(8)":U
     LABEL "Польз."
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Пользователь, рассчитывающий архив в данный момент"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-date-time AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 81.88 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-description AS CHARACTER FORMAT "X(40)":U
      VIEW-AS TEXT
     SIZE 46.38 BY .67
     FGCOLOR 12  NO-UNDO.
DEFINE VARIABLE fi-description-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Тип архива:"
      VIEW-AS TEXT
     SIZE 19.13 BY .67 NO-UNDO.
DEFINE VARIABLE fi-description-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус архива:"
      VIEW-AS TEXT
     SIZE 18.75 BY .67 NO-UNDO.
DEFINE VARIABLE fi-description-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Текущее состояние:"
      VIEW-AS TEXT
     SIZE 18.75 BY .67 NO-UNDO.
DEFINE VARIABLE fi-description-4 AS CHARACTER FORMAT "X(256)":U INITIAL "Задания на расчёт:"
      VIEW-AS TEXT
     SIZE 18.75 BY .67 NO-UNDO.
DEFINE VARIABLE fi-description-5 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус объекта:"
      VIEW-AS TEXT
     SIZE 15.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-description-6 AS CHARACTER FORMAT "X(256)":U INITIAL "БД:"
      VIEW-AS TEXT
     SIZE 15.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-detail-date AS DATE FORMAT "99/99/9999":U
     LABEL "Начало подробного"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-label-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Статус архива"
      VIEW-AS TEXT
     SIZE 14 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE fi-label-2 AS CHARACTER FORMAT "X(256)":U INITIAL "Расчёт"
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE fi-label-3 AS CHARACTER FORMAT "X(256)":U INITIAL "Удал./Вост."
      VIEW-AS TEXT
     SIZE 15 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE fi-obj-name AS CHARACTER FORMAT "X(80)":U
      VIEW-AS TEXT
     SIZE 74.75 BY .67 TOOLTIP "Полное название объекта"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-rest-execsysdate AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Дата начала проходящего сейчас расчёта архива"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-rest-execsystime AS CHARACTER FORMAT "X(5)":U
     LABEL "Время"
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Время начала проходящего сейчас расчёта архива"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-rest-execuser AS CHARACTER FORMAT "X(8)":U
     LABEL "Польз."
      VIEW-AS TEXT
     SIZE 11 BY .67 TOOLTIP "Пользователь, рассчитывающий архив в данный момент"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-search AS DECIMAL FORMAT ">>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.5 BY 1 NO-UNDO.
DEFINE VARIABLE fi-search-description AS CHARACTER FORMAT "X(256)":U INITIAL "Поиск по номеру объекта:"
      VIEW-AS TEXT
     SIZE 25.13 BY .67 NO-UNDO.
DEFINE VARIABLE fi-start-date AS DATE FORMAT "99/99/9999":U
     LABEL "Начало сжатого"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-archive-type AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&Все", 1,
"По &товарам", 2,
"По &поставщикам", 3,
"По типам приоб&ретения", 4
     SIZE 61.25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-bad-archive AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Все", 1,
"Не рассчитанные", 2,
"Рассчитанные", 3,
"Отключенные", 4
     SIZE 78 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-batch-process AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Все", 1,
"С заданиями", 2,
"Без заданий", 3
     SIZE 59 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-deleted AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Текущие&+", 1,
"Все&!", 2,
"Удалённые&-", 3
     SIZE 59 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-process AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL EXPAND
     RADIO-BUTTONS
          "Все", 1,
"Не рассчитываются", 2,
"Рассчитываются", 3
     SIZE 59 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 49 BY 3.75.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.13 BY 3.75.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 23.13 BY 3.75.
DEFINE QUERY BR-obj FOR
      temp-obj-arh SCROLLING.
DEFINE BROWSE BR-obj
  QUERY BR-obj DISPLAY
      temp-obj-arh.db-num format ">>>>9"
      (temp-obj-arh.obj-type + ' ' + string(temp-obj-arh.obj-code)) @ v-object
      temp-obj-arh.obj-deleted
      archive-type-name(temp-obj-arh.archive-type) @ v-archive-type
      temp-obj-arh.archive-detail-date
      temp-obj-arh.archive-start-date
      temp-obj-arh.archive-recalc-date
      temp-obj-arh.archive-calc    format "*/ " column-label "Оборот"
      temp-obj-arh.archive-del     format "*/ " column-label "Остат"
      temp-obj-arh.archive-disable format "*/ " column-label "Запрщ"
      temp-obj-arh.archive-rest    format "*/ " column-label "Восст"
      temp-obj-arh.archive-bpexist format "*/ " column-label "Задания"
      temp-obj-arh.archive-execuser
      temp-obj-arh.archive-execsysdate
      temp-obj-arh.archive-execsystime
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.63 BY 10.71.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-hist AT ROW 1 COL 11
     b-refresh AT ROW 1 COL 21
     b-print AT ROW 1 COL 31
     b-excel AT ROW 1 COL 41
     b-calc AT ROW 1 COL 51
     b-calc-all AT ROW 1 COL 63
     B-Help AT ROW 1 COL 79
     rs-archive-type AT ROW 2.92 COL 21.13 NO-LABEL
     rs-bad-archive AT ROW 3.71 COL 21.13 NO-LABEL
     rs-process AT ROW 4.5 COL 21.13 NO-LABEL
     rs-batch-process AT ROW 5.33 COL 21.13 NO-LABEL
     rs-deleted AT ROW 6.13 COL 21.13 NO-LABEL
     cb-db AT ROW 6.92 COL 19.13 COLON-ALIGNED NO-LABEL
     fi-search AT ROW 6.92 COL 73.5 COLON-ALIGNED NO-LABEL
     BR-obj AT ROW 8.04 COL 1.25
     fi-date-time AT ROW 2.04 COL 1 NO-LABEL
     fi-description-1 AT ROW 2.92 COL 1 NO-LABEL
     fi-description-2 AT ROW 3.71 COL 1 NO-LABEL
     fi-description-3 AT ROW 4.5 COL 1 NO-LABEL
     fi-description-4 AT ROW 5.33 COL 1 NO-LABEL
     fi-description-5 AT ROW 6.13 COL 1 NO-LABEL
     fi-description-6 AT ROW 7.13 COL 1 NO-LABEL
     fi-search-description AT ROW 7.13 COL 47.75 COLON-ALIGNED NO-LABEL
     fi-obj-name AT ROW 18.85 COL 1 NO-LABEL
     fi-label-1 AT ROW 19.42 COL 7.88 COLON-ALIGNED NO-LABEL
     fi-label-2 AT ROW 19.5 COL 55.5 COLON-ALIGNED NO-LABEL
     fi-label-3 AT ROW 19.5 COL 79 COLON-ALIGNED NO-LABEL
     fi-description AT ROW 20.21 COL 2.63 NO-LABEL
     fi-calc-execuser AT ROW 20.5 COL 59.5 COLON-ALIGNED
     fi-rest-execuser AT ROW 20.5 COL 84.5 COLON-ALIGNED
     fi-detail-date AT ROW 21.25 COL 6.5
     fi-calc-execsysdate AT ROW 21.38 COL 59.5 COLON-ALIGNED
     fi-rest-execsysdate AT ROW 21.38 COL 84.5 COLON-ALIGNED
     fi-start-date AT ROW 22.25 COL 9.5
     fi-calc-execsystime AT ROW 22.46 COL 59.5 COLON-ALIGNED
     fi-rest-execsystime AT ROW 22.46 COL 84.5 COLON-ALIGNED
     RECT-1 AT ROW 19.75 COL 1
     RECT-2 AT ROW 19.75 COL 76.5
     RECT-3 AT ROW 19.75 COL 51
     SPACE(25.75) SKIP(0.07)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Складские архивы на объектах"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       BR-obj:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 4.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-calc IN FRAME Dialog-Frame
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
  run calc-archive in this-procedure .
END.
ON CHOOSE OF b-calc-all IN FRAME Dialog-Frame
DO:
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
  define variable v-ok as logical   no-undo .
  if available temp-obj-arh
  then do:
    message
      "Рассчитать архив для всех показанных объектов" skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return no-apply .
    end.
    run calc-all-temp-obj-arh in this-procedure
      no-error .
    if error-status :error
    then do:
      message
        "Ошибка при расчете архива" skip
        "Объект" temp-obj-arh.obj-type temp-obj-arh.obj-code skip
        "Складской архив" archive-type-name(temp-obj-arh.archive-type) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return no-apply .
    end.
    else do:
      message
        "Рассчет архивов закончен" skip
        view-as alert-box information .
    end.
  end.
  run openbr in this-procedure
    (input true
    ).
END.
ON CHOOSE OF b-excel IN FRAME Dialog-Frame
DO:
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
  run print-all-to-excel in this-procedure .
END.
ON CHOOSE OF b-hist IN FRAME Dialog-Frame
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
  run display-history in this-procedure .
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run print-temp-obj-arh in this-procedure .
END.
ON CHOOSE OF b-refresh IN FRAME Dialog-Frame
DO:
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run openbr in this-procedure
    (input true
    ).
END.
ON DEFAULT-ACTION OF BR-obj IN FRAME Dialog-Frame
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  run display-history in this-procedure .
END.
ON VALUE-CHANGED OF BR-obj IN FRAME Dialog-Frame
DO:
  run proc-display-fields in this-procedure .
END.
ON VALUE-CHANGED OF cb-db IN FRAME Dialog-Frame
DO:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
    cb-db
    .
  run openbr in this-procedure
    (input false
    ) .
END.
ON RETURN OF fi-search IN FRAME Dialog-Frame
DO:
  define variable v-curr-rowid as rowid     no-undo .
  if available temp-obj-arh
  then do:
    assign
      v-curr-rowid = rowid(temp-obj-arh)
    .
    if fi-search <> input frame Dialog-Frame fi-search
    then do:
      assign
        fi-search
        .
      run ah-infov_get-first in this-procedure .
      if available temp-obj-arh
      and temp-obj-arh.obj-code = fi-search
      then do:
        assign
          v-curr-rowid = rowid(temp-obj-arh)
        .
        reposition BR-obj to rowid v-curr-rowid no-error .
        if error-status :error
        then do:
          reposition BR-obj to row 1 .
        end.
        return no-apply .
      end.
    end.
    define variable v-get-first-count as integer   no-undo .
    assign
      v-get-first-count = 0
    .
    do while true
    :
      run ah-infov_get-next in this-procedure .
      if available temp-obj-arh
      then do:
        if temp-obj-arh.obj-code = fi-search
        then do:
          assign
            v-curr-rowid = rowid(temp-obj-arh)
          .
          reposition BR-obj to rowid v-curr-rowid no-error .
          if error-status :error
          then do:
            reposition BR-obj to row 1 .
          end.
          return no-apply .
        end.
      end.
      else do:
        if v-get-first-count = 0
        then do:
          run ah-infov_get-first in this-procedure .
          assign
            v-get-first-count = v-get-first-count + 1
          .
        end.
        else do:
          leave .
        end.
      end.
    end.
  end.
END.
ON VALUE-CHANGED OF rs-archive-type IN FRAME Dialog-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
    rs-archive-type
    .
  run openbr in this-procedure
    (input false
    ) .
END.
ON VALUE-CHANGED OF rs-bad-archive IN FRAME Dialog-Frame
DO:
define variable vss-include-info13 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
    rs-bad-archive
    .
  run openbr in this-procedure
    (input false
    ) .
END.
ON VALUE-CHANGED OF rs-batch-process IN FRAME Dialog-Frame
DO:
define variable vss-include-info14 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
    rs-batch-process
    .
  run openbr in this-procedure
    (input false
    ) .
END.
ON VALUE-CHANGED OF rs-deleted IN FRAME Dialog-Frame
DO:
define variable vss-include-info15 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
    rs-deleted
    .
  run openbr in this-procedure
    (input false
    ) .
END.
ON VALUE-CHANGED OF rs-process IN FRAME Dialog-Frame
DO:
define variable vss-include-info16 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
    rs-process
    .
  run openbr in this-procedure
    (input false
    ) .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BR-obj :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-obj as INT EXTENT 26 no-undo.
DEF VAR varmvibr-obj       as INT no-undo.
DEF VAR varmvjbr-obj       as INT no-undo.
DEF VAR varmvkbr-obj       as INT no-undo.
DEF VAR varmvlbr-obj       as INT no-undo.
DEF VAR move-elementbr-obj as INT no-undo.
def var jjbr-obj           as int no-undo.
do varmvibr-obj = 1 to EXTENT(cur-clmn-numbr-obj):
  ASSIGN cur-clmn-numbr-obj[varmvibr-obj] = varmvibr-obj.
END.
RUN start-mv-clmnbr-obj.
PROCEDURE start-mv-clmnbr-obj:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-obj do:
  RUN re-move-clmnbr-obj ( 4, 26).
END.
ON ctrl-cursor-left OF BROWSE br-obj do:
  RUN re-move-clmnbr-obj (26, 4).
END.
PROCEDURE re-move-clmnbr-obj:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-obj = 1 TO EXTENT(cur-clmn-numbr-obj):
    if cur-clmn-numbr-obj[varmvibr-obj] = source-column THEN cur-clmn-numbr-obj[varmvibr-obj] = -1.
  END.
  if br-obj:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-obj = source-column - 1 to target-column BY -1:
    DO varmvibr-obj = 1 TO EXTENT(cur-clmn-numbr-obj):
        if cur-clmn-numbr-obj[varmvibr-obj] = varmvjbr-obj THEN DO:
          cur-clmn-numbr-obj[varmvibr-obj] = cur-clmn-numbr-obj[varmvibr-obj] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-obj = source-column + 1 to target-column:
    DO varmvibr-obj = 1 TO EXTENT(cur-clmn-numbr-obj):
      if cur-clmn-numbr-obj[varmvibr-obj] = varmvjbr-obj THEN DO:
        cur-clmn-numbr-obj[varmvibr-obj] = cur-clmn-numbr-obj[varmvibr-obj] - 1.
      END.
    END.
  END.
  DO varmvibr-obj = 1 TO EXTENT(cur-clmn-numbr-obj):
    if cur-clmn-numbr-obj[varmvibr-obj] = -1 THEN cur-clmn-numbr-obj[varmvibr-obj] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-obj:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmvibr-obj = 1 TO EXTENT(cur-clmn-numbr-obj):
    if cur-clmn-numbr-obj[varmvibr-obj] = cur-clmn-loc THEN move-elementbr-obj = varmvibr-obj.
  END.
  RUN re-move-clmnbr-obj (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-obj:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-obj = 4 to EXTENT(cur-clmn-numbr-obj):
    RUN re-move-clmnbr-obj (cur-clmn-numbr-obj[varmvlbr-obj], varmvlbr-obj).
  END.
  RUN start-mv-clmnbr-obj.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  BR-obj :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-ok as logical   no-undo .
define variable vss-include-info23 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_archive_lookup':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output v-ok
    )  .
end.
  if v-ok <> true then do:
    undo, return error .
  end.
  RUN enable_UI in this-procedure .
  run setup-initial-values in this-procedure .
  Run OpenBr in this-procedure
    (input true
    ).
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE ah-infov_archive-type-name-proc :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-type-name as character no-undo .
  case p-archive-type
  :
    when 'arh':U
    then do:
      assign
        p-archive-type-name = "по товарам"
      .
    end.
    when 'ahsp':U
    then do:
      assign
        p-archive-type-name = "по поставщикам"
      .
    end.
    when 'aht':U
    then do:
      assign
        p-archive-type-name = "по типам приобретения"
      .
    end.
    otherwise do:
      assign
        p-archive-type-name = p-archive-type
      .
    end.
  end case .
END PROCEDURE.
PROCEDURE ah-infov_get-current :
  define output parameter p-available                as logical   no-undo .
  define output parameter p-db-num                   as integer   no-undo .
  define output parameter p-obj-type                 as character no-undo .
  define output parameter p-obj-code                 as integer   no-undo .
  define output parameter p-archive-type             as character no-undo .
  define output parameter p-obj-deleted              as logical   no-undo .
  define output parameter p-archive-calc             as logical   no-undo .
  define output parameter p-archive-del              as logical   no-undo .
  define output parameter p-archive-disable          as logical   no-undo .
  define output parameter p-archive-rest             as logical   no-undo .
  define output parameter p-archive-bpexist          as logical   no-undo .
  define output parameter p-archive-detail-date      as date      no-undo .
  define output parameter p-archive-start-date       as date      no-undo .
  define output parameter p-archive-recalc-date      as date      no-undo .
  define output parameter p-archive-lock-prc         as logical   no-undo .
  define output parameter p-archive-execuser         as character no-undo .
  define output parameter p-archive-execsysdate      as date      no-undo .
  define output parameter p-archive-execsystime      as character no-undo .
  define output parameter p-archive-rest-lock-prc    as logical   no-undo .
  define output parameter p-archive-rest-execuser    as character no-undo .
  define output parameter p-archive-rest-execsysdate as date      no-undo .
  define output parameter p-archive-rest-execsystime as character no-undo .
  if available temp-obj-arh
  then do:
    assign
      p-available                = true
      p-db-num                   = temp-obj-arh.db-num
      p-obj-type                 = temp-obj-arh.obj-type
      p-obj-code                 = temp-obj-arh.obj-code
      p-archive-type             = temp-obj-arh.archive-type
      p-archive-calc             = temp-obj-arh.archive-calc
      p-archive-del              = temp-obj-arh.archive-del
      p-archive-disable          = temp-obj-arh.archive-disable
      p-archive-rest             = temp-obj-arh.archive-rest
      p-archive-bpexist          = temp-obj-arh.archive-bpexist
      p-archive-detail-date      = temp-obj-arh.archive-detail-date
      p-archive-start-date       = temp-obj-arh.archive-start-date
      p-archive-recalc-date      = temp-obj-arh.archive-recalc-date
      p-archive-lock-prc         = temp-obj-arh.archive-lock-prc
      p-archive-execuser         = temp-obj-arh.archive-execuser
      p-archive-execsysdate      = temp-obj-arh.archive-execsysdate
      p-archive-execsystime      = temp-obj-arh.archive-execsystime
      p-archive-rest-lock-prc    = temp-obj-arh.archive-rest-lock-prc
      p-archive-rest-execuser    = temp-obj-arh.archive-rest-execuser
      p-archive-rest-execsysdate = temp-obj-arh.archive-rest-execsysdate
      p-archive-rest-execsystime = temp-obj-arh.archive-rest-execsystime
    .
  end.
  else do:
    assign
      p-available = false
    .
  end.
END PROCEDURE.
PROCEDURE ah-infov_get-description :
  define output parameter p-archive-description as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        p-archive-description = fi-date-time :screen-value
      .
    end.
  end.
END PROCEDURE.
PROCEDURE ah-infov_get-first :
  apply "home":u to browse BR-obj .
END PROCEDURE.
PROCEDURE ah-infov_get-last :
  apply "end":u to browse BR-obj .
END PROCEDURE.
PROCEDURE ah-infov_get-next :
  get next BR-obj .
END PROCEDURE.
PROCEDURE ah-infov_get-prev :
  get prev BR-obj .
END PROCEDURE.
PROCEDURE ah-infov_history-description :
  define input  parameter p-history-type        as character no-undo .
  define output parameter p-history-description as character no-undo .
  do
  on error undo, return error return-value
  :
    case p-history-type
    :
      when 'calc-start':U
      then do:
        assign
          p-history-description = "расчёт-начало"
        .
      end.
      when 'calc-stop':U
      then do:
        assign
          p-history-description = "расчёт-окончание"
        .
      end.
      when 'set-calc':U
      then do:
        assign
          p-history-description = "пометить-нерассчитанные"
        .
      end.
      when 'set-del':U
      then do:
        assign
          p-history-description = "пометить-удалённые"
        .
      end.
      when 'set-disable':U
      then do:
        assign
          p-history-description = "пометить-запретить"
        .
      end.
      when 'clear-disable':U
      then do:
        assign
          p-history-description = "пометить-разрешить"
        .
      end.
      when 'set-recalc':U
      then do:
        assign
          p-history-description = "пометить-перерассчитать"
        .
      end.
      when 'init-start':U
      then do:
        assign
          p-history-description = "инициализация-начало"
        .
      end.
      when 'init-stop':U
      then do:
        assign
          p-history-description = "инициализация-окончание"
        .
      end.
      when 'delall-start':U
      then do:
        assign
          p-history-description = "удаление-начало"
        .
      end.
      when 'delall-stop':U
      then do:
        assign
          p-history-description = "удаление-окончание"
        .
      end.
      when 'deldet-start':U
      then do:
        assign
          p-history-description = "сжатие-начало"
        .
      end.
      when 'deldet-stop':U
      then do:
        assign
          p-history-description = "сжатие-окончание"
        .
      end.
      when 'rstfil-start':U
      then do:
        assign
          p-history-description = "восстановление-начало"
        .
      end.
      when 'rstfil-stop':U
      then do:
        assign
          p-history-description = "восстановление-окончание"
        .
      end.
      when 'rstdoc-start':U
      then do:
        assign
          p-history-description = "расчет-назад-начало"
        .
      end.
      when 'rstdoc-stop':U
      then do:
        assign
          p-history-description = "расчет-назад-окончание"
        .
      end.
      when 'ren-gds-code':U
      then do:
        assign
          p-history-description = "код-товара-переименование"
        .
      end.
      otherwise do:
        assign
          p-history-description = p-history-type
        .
      end.
    end case .
  end.
END PROCEDURE.
PROCEDURE ah-infov_is-available :
  define output parameter p-temp-obj-arh-available as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-temp-obj-arh-available = available temp-obj-arh
    .
  end.
END PROCEDURE.
PROCEDURE ah-infov_reposition-to-current :
  define variable v-curr-rowid as rowid     no-undo .
  do
  on error undo, return error return-value
  :
    if available temp-obj-arh
    then do:
      assign
        v-curr-rowid = rowid(temp-obj-arh)
      .
      reposition BR-obj to rowid v-curr-rowid no-error .
      if error-status :error
      then do:
        reposition BR-obj to row 1 .
      end.
    end.
    else do:
      reposition BR-obj to row 1 .
    end.
  end.
END PROCEDURE.
PROCEDURE calc-all-temp-obj-arh :
  define buffer buf_temp-obj-arh for temp-obj-arh .
  do
  on error undo, return error return-value
  :
    define variable v-curr-rowid as rowid no-undo .
    assign
      v-curr-rowid = rowid(temp-obj-arh)
    .
    run ah-infov_get-first in this-procedure .
    do while true
    :
      define variable v-available                as logical   no-undo .
      define variable v-db-num                   as integer   no-undo .
      define variable v-obj-type                 as character no-undo .
      define variable v-obj-code                 as integer   no-undo .
      define variable v-archive-type             as character no-undo .
      define variable v-deleted                  as logical   no-undo .
      define variable v-archive-calc             as logical   no-undo .
      define variable v-archive-del              as logical   no-undo .
      define variable v-archive-disable          as logical   no-undo .
      define variable v-archive-rest             as logical   no-undo .
      define variable v-archive-bpexist          as logical   no-undo .
      define variable v-archive-detail-date      as date      no-undo .
      define variable v-archive-start-date       as date      no-undo .
      define variable v-archive-lock-prc         as logical   no-undo .
      define variable v-archive-execuser         as character no-undo .
      define variable v-archive-execsysdate      as date      no-undo .
      define variable v-archive-execsystime      as character no-undo .
      define variable v-archive-rest-lock-prc    as logical   no-undo .
      define variable v-archive-rest-execuser    as character no-undo .
      define variable v-archive-rest-execsysdate as date      no-undo .
      define variable v-archive-rest-execsystime as character no-undo .
      define variable v-archive-date-recalc      as date      no-undo .
      run ah-infov_get-current in this-procedure
        (output v-available
        ,output v-db-num
        ,output v-obj-type
        ,output v-obj-code
        ,output v-archive-type
        ,output v-deleted
        ,output v-archive-calc
        ,output v-archive-del
        ,output v-archive-disable
        ,output v-archive-rest
        ,output v-archive-bpexist
        ,output v-archive-detail-date
        ,output v-archive-start-date
        ,output v-archive-date-recalc
        ,output v-archive-lock-prc
        ,output v-archive-execuser
        ,output v-archive-execsysdate
        ,output v-archive-execsystime
        ,output v-archive-rest-lock-prc
        ,output v-archive-rest-execuser
        ,output v-archive-rest-execsysdate
        ,output v-archive-rest-execsystime
        ) .
      if v-available <> true
      then do:
        leave .
      end.
      run calc-temp-obj-arh in this-procedure
        (input  v-obj-type
        ,input  v-obj-code
        ,input  v-archive-type
        ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      run ah-infov_get-next in this-procedure .
    end.
    reposition BR-obj to rowid v-curr-rowid no-error .
    if error-status :error
    then do:
      reposition BR-obj to row 1 .
    end.
  end.
END PROCEDURE.
PROCEDURE calc-archive :
  if available temp-obj-arh
  then do:
    define variable v-ok as logical   no-undo .
    message
      "Объект" temp-obj-arh.obj-type temp-obj-arh.obj-code skip
      "Рассчитать складской архив" archive-type-name(temp-obj-arh.archive-type) skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return .
    end.
    run calc-temp-obj-arh in this-procedure
      (input  temp-obj-arh.obj-type
      ,input  temp-obj-arh.obj-code
      ,input  temp-obj-arh.archive-type
      ) no-error .
    if error-status :error
    then do:
      message
        "Объект" temp-obj-arh.obj-type temp-obj-arh.obj-code skip
        "Складской архив" archive-type-name(temp-obj-arh.archive-type) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    else do:
      message
        "Объект" temp-obj-arh.obj-type temp-obj-arh.obj-code skip
        "Рассчет складского архива" archive-type-name(temp-obj-arh.archive-type) "закончен" skip
        view-as alert-box information .
    end.
  end.
  run openbr in this-procedure
    (input true
    ).
END PROCEDURE.
PROCEDURE calc-temp-obj-arh :
  define input  parameter p-obj-type     as character no-undo .
  define input  parameter p-obj-code     as integer   no-undo .
  define input  parameter p-archive-type as character no-undo .
  do
  on error undo, return error return-value
  :
    case p-archive-type
    :
      when 'arh':U
      then do:
        run trg/bt_arh.p
          (input p-obj-type
          ,input p-obj-code
          ,input ?
          ,input true
          ,input v-cntxt-db-num
          ,input v-cntxt-userid
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.
      end.
      when 'ahsp':U
      then do:
        run trg/bt_ahsp.p
          (input p-obj-type
          ,input p-obj-code
          ,input ?
          ,input true
          ,input v-cntxt-db-num
          ,input v-cntxt-userid
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.
      end.
      when 'aht':U
      then do:
        run trg/bt_aht.p
          (input p-obj-type
          ,input p-obj-code
          ,input ?
          ,input true
          ,input v-cntxt-db-num
          ,input v-cntxt-userid
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.
      end.
    end case .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-history :
  define variable v-curr-rowid as rowid     no-undo .
  if available temp-obj-arh
  then do:
    run utl/histarhv.w
      (input this-procedure :handle
      ) .
    if available temp-obj-arh
    then do:
      assign
        v-curr-rowid = rowid(temp-obj-arh)
      .
      reposition BR-obj to rowid v-curr-rowid no-error .
      if error-status :error
      then do:
        reposition BR-obj to row 1 .
      end.
    end.
    else do:
      reposition BR-obj to row 1 .
    end.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-archive-type rs-bad-archive rs-process rs-batch-process rs-deleted
          cb-db fi-search fi-date-time fi-description-1 fi-description-2
          fi-description-3 fi-description-4 fi-description-5 fi-description-6
          fi-search-description fi-obj-name fi-label-1 fi-label-2 fi-label-3
          fi-description fi-calc-execuser fi-rest-execuser fi-detail-date
          fi-calc-execsysdate fi-rest-execsysdate fi-start-date
          fi-calc-execsystime fi-rest-execsystime
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-hist b-refresh b-print b-excel b-calc b-calc-all B-Help
         RECT-1 RECT-2 RECT-3 rs-archive-type rs-bad-archive rs-process
         rs-batch-process rs-deleted cb-db fi-search BR-obj fi-date-time
         fi-description-1 fi-description-2 fi-description-3 fi-description-4
         fi-description-5 fi-description-6 fi-search-description fi-obj-name
         fi-label-1 fi-label-2 fi-label-3 fi-description fi-calc-execuser
         fi-rest-execuser fi-detail-date fi-start-date
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE OpenBr :
  define input  parameter p-refresh-query as logical   no-undo .
  define variable v-cur-obj-type     as character no-undo .
  define variable v-cur-obj-code     as integer   no-undo .
  define variable v-cur-archive-type as character no-undo .
  do
  on error undo, return error return-value
  :
    if available temp-obj-arh
    then do:
      assign
        v-cur-obj-type     = temp-obj-arh.obj-type
        v-cur-obj-code     = temp-obj-arh.obj-code
        v-cur-archive-type = temp-obj-arh.archive-type
      .
    end.
    if p-refresh-query = true
    then do:
      do with frame Dialog-Frame:
        assign
          fi-date-time :screen-value = "*** запрос информации ***"
        .
      end.
      run cur-time in this-procedure
        (output v-today
        ,output v-time
        ).
      run utl/ah-info.p
        (output table temp-obj-arh
        ).
      assign
        frame Dialog-Frame :title = "Архивы на объектах: Состояние на " + string( v-today, "99/99/9999" ) + chr(32) + string( v-time, "HH:MM:SS" ).
      .
      do with frame Dialog-Frame:
        assign
          fi-date-time :screen-value = "Состояние на" + chr(32) + string( v-today, "99/99/9999" ) + chr(32) + string( v-time, "HH:MM:SS" )
        .
      end.
    end.
    open query br-obj for each temp-obj-arh no-lock
      where ( rs-archive-type = 1
              or
              ( rs-archive-type = 2
                and
                temp-obj-arh.archive-type = 'arh':U
              )
              or
              ( rs-archive-type = 3
                and
                temp-obj-arh.archive-type = 'ahsp':U
              )
              or
              ( rs-archive-type = 4
                and
                temp-obj-arh.archive-type = 'aht':U
              )
            )
        and ( rs-bad-archive = 1
              or
              ( rs-bad-archive = 2
                and
                ( temp-obj-arh.archive-calc = true
                  or
                  temp-obj-arh.archive-del  = true
                  or
                  temp-obj-arh.archive-rest = true
                )
                and
                temp-obj-arh.archive-disable <> true
              )
              or
              ( rs-bad-archive = 3
                and
                ( temp-obj-arh.archive-calc <> true
                  and
                  temp-obj-arh.archive-del  <> true
                  and
                  temp-obj-arh.archive-rest <> true
                )
              )
              or
              ( rs-bad-archive = 4
                and
                ( temp-obj-arh.archive-calc = true
                  or
                  temp-obj-arh.archive-del  = true
                  or
                  temp-obj-arh.archive-rest = true
                )
                and
                temp-obj-arh.archive-disable = true
              )
            )
        and ( rs-batch-process = 1
              or
              ( rs-batch-process = 2
                and
                ( temp-obj-arh.archive-bpexist = true
                  or
                  temp-obj-arh.archive-recalc-date <> ?
                )
              )
              or
              ( rs-batch-process = 3
                and
                ( temp-obj-arh.archive-bpexist = false
                  and
                  temp-obj-arh.archive-recalc-date = ?
                )
              )
            )
        and ( ( rs-deleted = 1
                and
                temp-obj-arh.obj-deleted <> true
              )
              or
              rs-deleted = 2
              or
              ( rs-deleted = 3
                and
                temp-obj-arh.obj-deleted = true
              )
            )
        and ( rs-process = 1
              or
              ( rs-process = 2
                and
                temp-obj-arh.archive-lock-prc <> true
              )
              or
              ( rs-process = 3
                and
                temp-obj-arh.archive-lock-prc = true
              )
            )
        and ( v-filter-db <> true
              or
              ( v-filter-db = true
                and
                ( cb-db = v-all-db
                  or
                  ( cb-db <> v-all-db
                    and
                    temp-obj-arh.db-num = integer(cb-db)
                  )
                )
              )
            )
      by temp-obj-arh.db-num
      by temp-obj-arh.obj-type
      by temp-obj-arh.obj-code
      by temp-obj-arh.sort-code
      .
    define buffer buf_temp-obj-arh for temp-obj-arh .
    find first buf_temp-obj-arh
      where buf_temp-obj-arh.obj-type     = v-cur-obj-type
        and buf_temp-obj-arh.obj-code     = v-cur-obj-code
        and buf_temp-obj-arh.archive-type = v-cur-archive-type
      no-error .
    if available buf_temp-obj-arh
    then do:
      reposition br-obj to recid recid(buf_temp-obj-arh) no-error .
      if error-status :error
      then do:
        reposition br-obj to row 1 .
      end.
    end.
    run proc-display-fields in this-procedure .
    APPLY "ENTRY" TO BR-obj.
  end.
END PROCEDURE.
PROCEDURE print-all-to-excel :
  define variable v-curr-rowid as rowid no-undo .
  assign
    v-curr-rowid = rowid(temp-obj-arh)
  .
  run utl/ahinfxls.p
    (input this-procedure :handle
    ) .
  reposition BR-obj to rowid v-curr-rowid no-error .
  if error-status :error
  then do:
    reposition BR-obj to row 1 .
  end.
END PROCEDURE.
PROCEDURE print-temp-obj-arh :
  define variable v-curr-rowid as rowid no-undo .
  assign
    v-curr-rowid = rowid(temp-obj-arh)
  .
  if available temp-obj-arh
  then do:
    run utl/ahinfprn.p
      (input parparentproc
      ,input this-procedure :handle
      ) .
  end.
  reposition BR-obj to rowid v-curr-rowid no-error .
  if error-status :error
  then do:
    reposition BR-obj to row 1 .
  end.
END PROCEDURE.
PROCEDURE Proc-display-fields :
  define buffer buf_clients for ub.clients .
  if available temp-obj-arh
  then do:
    find first buf_clients no-lock
      where buf_clients.obj-type = temp-obj-arh.obj-type
        and buf_clients.obj-code = temp-obj-arh.obj-code
      no-error .
    if available buf_clients
    then do:
      assign
        fi-obj-name = substitute("&1 &2  &3  &4"
                     ,temp-obj-arh.obj-type
                     ,temp-obj-arh.obj-code
                     ,buf_clients.obj-name
                     ,archive-type-name(temp-obj-arh.archive-type)
                     )
      .
    end.
    else do:
      assign
        fi-obj-name = substitute("&1 &2  &3  &4"
                     ,temp-obj-arh.obj-type
                     ,temp-obj-arh.obj-code
                     ,""
                     ,archive-type-name(temp-obj-arh.archive-type)
                     )
      .
    end.
    do with frame Dialog-Frame:
      assign
        fi-description             = ""
        fi-detail-date      = ?
        fi-start-date       = ?
        fi-calc-execuser         = ""
        fi-calc-execsysdate      = ?
        fi-calc-execsystime      = ""
        fi-rest-execuser    = ""
        fi-rest-execsysdate = ?
        fi-rest-execsystime = ""
      .
      assign
        fi-description   = (if temp-obj-arh.archive-disable = true
                            then "Расчет архива отключен"
                            else (if temp-obj-arh.archive-del = true
                                  then (if temp-obj-arh.archive-lock-prc = true
                                        then "Расчёт начальных остатков"
                                        else "Не рассчитаны начальные остатки"
                                       )
                                  else (if temp-obj-arh.archive-calc = true
                                        then (if temp-obj-arh.archive-lock-prc = true
                                              then "Расчёт оборотов"
                                              else "Не рассчитаны обороты"
                                              )
                                        else (if temp-obj-arh.archive-rest = true
                                              then (if temp-obj-arh.archive-lock-prc = true
                                                    then "Удаление/восстановление"
                                                    else "Сбой удаления восстановления"
                                                    )
                                              else (if temp-obj-arh.archive-recalc-date <> ?
                                                    then (if temp-obj-arh.archive-calc = true
                                                          then substitute("Перерасчет с даты &1"
                                                                         ,string(temp-obj-arh.archive-recalc-date, '99/99/9999':u)
                                                                         )
                                                          else substitute("Требуется перерасчет с даты &1"
                                                                         ,string(temp-obj-arh.archive-recalc-date, '99/99/9999':u)
                                                                         )
                                                         )
                                                    else (if temp-obj-arh.archive-bpexist = true
                                                          then (if temp-obj-arh.archive-calc = true
                                                                then "Обработка заданий на расчет архива"
                                                                else "Имеются задания на расчет архива"
                                                              )
                                                          else ""
                                                         )
                                                   )
                                             )
                                       )
                                 )
                           )
        fi-detail-date   = temp-obj-arh.archive-detail-date
        fi-start-date    = temp-obj-arh.archive-start-date
      .
      if temp-obj-arh.archive-lock-prc = true
      then do:
        assign
          fi-calc-execuser    = temp-obj-arh.archive-execuser
          fi-calc-execsysdate = temp-obj-arh.archive-execsysdate
          fi-calc-execsystime = temp-obj-arh.archive-execsystime
        .
      end.
      if temp-obj-arh.archive-rest-lock-prc = true
      then do:
        assign
          fi-rest-execuser    = temp-obj-arh.archive-rest-execuser
          fi-rest-execsysdate = temp-obj-arh.archive-rest-execsysdate
          fi-rest-execsystime = temp-obj-arh.archive-rest-execsystime
        .
      end.
    end.
    display
      fi-obj-name
      fi-description
      fi-detail-date
      fi-start-date
      fi-calc-execuser
      fi-calc-execsysdate
      fi-calc-execsystime
      fi-rest-execuser
      fi-rest-execsysdate
      fi-rest-execsystime
      with frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE setup-initial-values :
  define buffer buf_sys-ctrl for ub.sys-ctrl .
  define buffer buf_db       for ub.db .
  do with frame Dialog-Frame:
    assign
      rs-archive-type  = 1
      rs-bad-archive   = 1
      rs-batch-process = 1
      rs-deleted       = 1
      rs-process       = 1
    .
    display
      rs-archive-type
      rs-bad-archive
      rs-batch-process
      rs-deleted
      rs-process
      with frame Dialog-Frame .
    find buf_sys-ctrl .
    if buf_sys-ctrl.db-num = 0
    then do:
      assign
        v-filter-db = true
      .
    end.
    else do:
      assign
        v-filter-db = false
      .
    end.
    if v-filter-db = true
    then do:
      define variable v-db-list as character no-undo .
      assign
        v-db-list = v-all-db
      .
      for each buf_db no-lock
        by buf_db.db-num
      on error undo, return error return-value
      :
        assign
          v-db-list = v-db-list
                    + (if v-db-list <> '':u then ',':u else '':u)
                    + string(buf_db.db-num)
        .
      end.
      assign
        cb-db :list-items = v-db-list
      .
      assign
        cb-db = v-all-db
      .
      display
        cb-db
        with frame Dialog-Frame .
      enable
        cb-db
        with frame Dialog-Frame .
    end.
    else do:
      disable
        cb-db
        with frame Dialog-Frame .
    end.
  end.
END PROCEDURE.
FUNCTION archive-type-name RETURNS CHARACTER
  ( input p-archive-type as character ) :
  define variable v-archive-type-name as character no-undo .
  run ah-infov_archive-type-name-proc in this-procedure
    (input  p-archive-type
    ,output v-archive-type-name
    ) .
  return v-archive-type-name .
END FUNCTION.
FUNCTION history-description RETURNS CHARACTER
  ( input p-history-type as character ) :
  define variable v-history-description as character no-undo .
  run ah-infov_history-description in this-procedure
    (input  p-history-type
    ,output v-history-description
    ) .
  return v-history-description .
END FUNCTION.
