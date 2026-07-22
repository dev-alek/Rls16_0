define input parameter parparentproc as widget-handle no-undo .
define input-output parameter p-price-base as decimal   no-undo .
define input-output parameter p-price-rubl as decimal   no-undo .
define output parameter p-action           as character no-undo .
define input  parameter p-obj-type         as character no-undo .
define input  parameter p-obj-code         as integer   no-undo .
define input  parameter p-artic            as character no-undo .
define input  parameter p-prod-type        as character no-undo .
define input  parameter p-prod-code        as integer   no-undo .
define input  parameter p-supp-type        as character no-undo .
define input  parameter p-supp-code        as integer   no-undo .
define input  parameter p-base-rate        as decimal   no-undo .
define input  parameter p-base-scale       as decimal   no-undo .
define input  parameter p-parts-qnty       as decimal   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Введение учетных цен для партии".
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
define variable v-base-code     as integer   no-undo .
define variable v-currency-rubl as character no-undo .
define variable v-currency-base as character no-undo .
DEFINE BUTTON b-base-from-rubl
     LABEL "abbr_rub_firstshift --> Вал"
     SIZE 14 BY 1 TOOLTIP "Расчет базовой учетной цены (Вал) на основе abbr_rublevoy (abbr_rub_firstshift)".
DEFINE BUTTON b-chg AUTO-GO
     LABEL "&Изменить"
     SIZE 10 BY 1 TOOLTIP "Вручную создать партии (с указанием учетной цены каждой партии)".
DEFINE BUTTON b-curr-rate
     LABEL "Курс ММВБ"
     SIZE 14 BY 1 TOOLTIP "Получить текущий курс ММВБ".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1 TOOLTIP "Создать партию с указанной учетной ценой".
DEFINE BUTTON b-goods
     LABEL "&Товар"
     SIZE 10 BY 1 TOOLTIP "Просмотр карточки товара".
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Помощь".
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1 TOOLTIP "Отказ от создания партий".
DEFINE BUTTON b-rate-from-price
     LABEL "Цены --> Курс"
     SIZE 15 BY 1 TOOLTIP "Вычисление курса на основании текущих учетных цен".
DEFINE BUTTON b-rubl-from-base
     LABEL "Вал --> abbr_rub_firstshift"
     SIZE 14 BY 1 TOOLTIP "Расчет abbr_rublevoy учетной цены (abbr_rub_firstshift) на основе базовой (Вал)".
DEFINE BUTTON b-supp
     LABEL "&Поставщик"
     SIZE 10 BY 1 TOOLTIP "Просмотр карточки поставщика".
DEFINE VARIABLE fi-currency-base AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-currency-base-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-currency-base-3 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-currency-rubl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-currency-rubl-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-currency-rubl-3 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 7.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-formula-1 AS CHARACTER FORMAT "X(256)":U INITIAL "= ----------------"
      VIEW-AS TEXT
     SIZE 19 BY .67 NO-UNDO.
DEFINE VARIABLE fi-formula-2 AS CHARACTER FORMAT "X(256)":U INITIAL "* КУРС"
      VIEW-AS TEXT
     SIZE 7.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-formula-3 AS CHARACTER FORMAT "X(256)":U INITIAL "МАСШТАБ"
      VIEW-AS TEXT
     SIZE 8 BY .67 NO-UNDO.
DEFINE VARIABLE fi-formula-4 AS CHARACTER FORMAT "X(256)":U INITIAL "* МАСШТАБ"
      VIEW-AS TEXT
     SIZE 9.5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-formula-5 AS CHARACTER FORMAT "X(256)":U INITIAL "= -------------------"
      VIEW-AS TEXT
     SIZE 22 BY .67 NO-UNDO.
DEFINE VARIABLE fi-formula-6 AS CHARACTER FORMAT "X(256)":U INITIAL "КУРС"
      VIEW-AS TEXT
     SIZE 5 BY .67 NO-UNDO.
DEFINE VARIABLE fi-obj AS CHARACTER FORMAT "X(40)"
     LABEL "Объект"
     VIEW-AS FILL-IN
     SIZE 76 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE fi-price-base AS DECIMAL FORMAT ">>,>>>,>>9.9999999999" INITIAL 0
     LABEL "Цена"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 TOOLTIP "Базовая учетная цена" NO-UNDO.
DEFINE VARIABLE fi-price-rubl AS DECIMAL FORMAT ">>,>>>,>>9.9999999999" INITIAL 0
     LABEL "Цена"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 TOOLTIP "abbr_rublevaya_firstshift учетная цена" NO-UNDO.
DEFINE VARIABLE fi-rate AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "&Курс"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE fi-scale AS DECIMAL FORMAT ">,>>9.99":U INITIAL 0
     LABEL "&Масштаб"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE name AS CHARACTER FORMAT "X(40)"
     LABEL "Товар"
     VIEW-AS FILL-IN
     SIZE 76 BY 1
     FGCOLOR 4 .
DEFINE VARIABLE need-qnty AS DECIMAL FORMAT "->,>>>,>>>,>>9.999":U INITIAL 0
     LABEL "Количество"
     VIEW-AS FILL-IN
     SIZE 19 BY 1 TOOLTIP "Недостающее количество"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rate-mmvb AS DECIMAL FORMAT ">>,>>9.9999":U INITIAL 0
     LABEL "Курс ММВБ"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE scale-mmvb AS DECIMAL FORMAT ">,>>9.99":U INITIAL 0
     LABEL "Масштаб"
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE supp-name AS CHARACTER FORMAT "X(40)"
     LABEL "Поставщик"
     VIEW-AS FILL-IN
     SIZE 76 BY 1
     FGCOLOR 4 .
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 50.5 BY 3.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 50.5 BY 3.27.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 25.5 BY 4.5.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 27 BY 4.5.
DEFINE FRAME DIALOG-1
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-chg AT ROW 1 COL 21
     b-goods AT ROW 1 COL 31
     b-supp AT ROW 1 COL 41
     b-help AT ROW 1 COL 51
     name AT ROW 2.33 COL 7.3
     fi-obj AT ROW 3.53 COL 6.3
     need-qnty AT ROW 4.77 COL 12.3 COLON-ALIGNED
     supp-name AT ROW 5.97 COL 3.3
     b-rate-from-price AT ROW 7.5 COL 51
     b-curr-rate AT ROW 7.5 COL 80
     fi-rate AT ROW 9 COL 50 COLON-ALIGNED
     rate-mmvb AT ROW 9 COL 78 COLON-ALIGNED
     fi-scale AT ROW 10.27 COL 50 COLON-ALIGNED
     scale-mmvb AT ROW 10.27 COL 78 COLON-ALIGNED
     fi-price-rubl AT ROW 13.27 COL 5 AUTO-RETURN
     b-rubl-from-base AT ROW 13.27 COL 44
     fi-price-base AT ROW 16.77 COL 9 COLON-ALIGNED
     b-base-from-rubl AT ROW 16.77 COL 44
     fi-currency-base-2 AT ROW 12.77 COL 68.5 COLON-ALIGNED NO-LABEL
     fi-formula-2 AT ROW 12.77 COL 77.5 COLON-ALIGNED NO-LABEL
     fi-currency-rubl AT ROW 13.5 COL 29.5 COLON-ALIGNED NO-LABEL
     fi-currency-rubl-2 AT ROW 13.5 COL 57.5 COLON-ALIGNED NO-LABEL
     fi-formula-1 AT ROW 13.5 COL 66 COLON-ALIGNED NO-LABEL
     fi-formula-3 AT ROW 14.27 COL 71.5 COLON-ALIGNED NO-LABEL
     fi-currency-rubl-3 AT ROW 16.27 COL 68.5 COLON-ALIGNED NO-LABEL
     fi-formula-4 AT ROW 16.27 COL 77.5 COLON-ALIGNED NO-LABEL
     fi-currency-base AT ROW 17 COL 29.5 COLON-ALIGNED NO-LABEL
     fi-currency-base-3 AT ROW 17 COL 58 COLON-ALIGNED NO-LABEL
     fi-formula-5 AT ROW 17 COL 66 COLON-ALIGNED NO-LABEL
     fi-formula-6 AT ROW 17.77 COL 72.5 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 12.27 COL 41.5
     RECT-2 AT ROW 15.77 COL 41.5
     RECT-3 AT ROW 7.27 COL 41.5
     RECT-4 AT ROW 7.27 COL 68.5
     SPACE(2.37) SKIP(8.72)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Редактирование учётной цены":L
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.
ASSIGN
       b-chg:HIDDEN IN FRAME DIALOG-1           = TRUE.
ON GO OF FRAME DIALOG-1
DO:
  define variable v-ok as logical   no-undo .
  if p-action = '':U
  then do:
    assign
      p-action = 'exit':U
    .
  end.
  if p-action = 'exit':U
  then do:
    if  fi-price-base :sensitive
    then do:
      if input frame DIALOG-1 fi-price-base = ?
      then do:
        message
          substitute("Не задана цена (&1)"
                    ,fi-currency-base :screen-value
                    ) skip
          view-as alert-box error .
        apply 'entry':u to fi-price-base .
        return no-apply .
      end.
      if input frame DIALOG-1 fi-price-base = 0
      then do:
        assign
          v-ok = false
        .
        message
          substitute("Задана нулевая цена (&1)"
                    ,fi-currency-base :screen-value
                    ) skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          apply 'entry':u to fi-price-base .
          return no-apply .
        end.
      end.
    end.
    if fi-price-rubl :sensitive
    then do:
      if input frame DIALOG-1 fi-price-rubl = ?
      then do:
        message
          substitute("Не задана учетная цена (&1)"
                    ,fi-currency-rubl :screen-value
                    ) skip
          view-as alert-box error .
        apply 'entry':u to fi-price-rubl .
        return no-apply .
      end.
      if input frame DIALOG-1 fi-price-rubl = 0
      then do:
        assign
          v-ok = false
        .
        message
          substitute("Учетная цена (&1) равна нулю"
                    ,fi-currency-rubl :screen-value
                    ) skip
          "Партия будет сохранена с нулевой учётной ценой." skip
          "Продолжить?" skip
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          apply 'entry':u to fi-price-rubl .
          return no-apply .
        end.
      end.
    end.
    assign
      p-price-base = input frame DIALOG-1 fi-price-base
      p-price-rubl = input frame DIALOG-1 fi-price-rubl
    .
    if v-base-code = 0
    then do:
      assign
        p-price-base = p-price-rubl
      .
    end.
  end.
END.
ON CHOOSE OF b-base-from-rubl IN FRAME DIALOG-1
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
  run calc-base-from-rubl .
END.
ON CHOOSE OF b-chg IN FRAME DIALOG-1
DO:
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
  assign
    p-action = "chg"
  .
END.
ON CHOOSE OF b-curr-rate IN FRAME DIALOG-1
DO:
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
  define variable v-host-code  as integer no-undo .
  define variable v-exch-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  v-today
  ,output v-exch-rate
  ,output v-exch-scale
  ) no-error .
  assign
    fi-rate  :screen-value  = string(v-exch-rate
                                 , fi-rate :format)
    fi-scale :screen-value  = string(v-exch-scale
                                 , fi-scale :format)
  .
END.
ON CHOOSE OF b-exit IN FRAME DIALOG-1
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
  assign
    p-action = "exit"
  .
END.
ON CHOOSE OF b-goods IN FRAME DIALOG-1
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
  if available ub.goods
  then do:
    run str/showgds.p
      (input parparentproc
      ,input ?
      ,input ub.goods.gds-code
      ,input 'ПРОСМОТР':U
      ).
  end.
END.
ON CHOOSE OF b-quit IN FRAME DIALOG-1
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
  assign
    p-action = "quit"
  .
END.
ON CHOOSE OF b-rate-from-price IN FRAME DIALOG-1
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
  run calc-rate-from-price .
END.
ON CHOOSE OF b-rubl-from-base IN FRAME DIALOG-1
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
  run calc-rubl-from-base .
END.
ON CHOOSE OF b-supp IN FRAME DIALOG-1
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
  run ref/showcli.p
    (input parparentproc
    ,input p-supp-type
    ,input p-supp-code
    ).
END.
ON RETURN OF fi-price-base IN FRAME DIALOG-1
DO:
  run calc-rubl-from-base.
  apply "choose":u to b-exit in frame DIALOG-1.
  return no-apply.
END.
ON RETURN OF fi-price-rubl IN FRAME DIALOG-1
DO:
  run calc-base-from-rubl.
  apply "choose":u to b-exit in frame DIALOG-1.
  return no-apply.
END.
ON RETURN OF fi-rate IN FRAME DIALOG-1
DO:
  define variable v-curr-r-b as character no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  if v-curr-r-b = 'base':U
  then do:
    run calc-rubl-from-base.
    apply "entry":u to b-exit in frame DIALOG-1.
    return no-apply.
  end.
  else do:
    run calc-base-from-rubl.
    apply "entry":u to b-exit in frame DIALOG-1.
    return no-apply.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DIALOG-1:PARENT eq ?
THEN FRAME DIALOG-1:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME DIALOG-1 APPLY "END-ERROR":U TO SELF.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DIALOG-1
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
on choose of b-help in frame DIALOG-1
do:
  apply "help":u to frame DIALOG-1 .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame DIALOG-1:width - 0.3
                fh            = frame DIALOG-1:first-child
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
DO
ON ERROR   UNDO MAIN-BLOCK, RETURN ERROR
ON END-KEY UNDO MAIN-BLOCK, RETURN ERROR
ON STOP    UNDO MAIN-BLOCK, RETURN ERROR
:
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
  find first ub.goods no-lock
    where ub.goods.artic     = p-artic
      and ub.goods.prod-type = p-prod-type
      and ub.goods.prod-code = p-prod-code
    no-error .
  if not available goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден товар" skip
      "Артикул" p-artic p-prod-code p-prod-type skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  find first clients no-lock
    where clients.obj-type = p-supp-type
      and clients.obj-code = p-supp-code
    no-error .
  if not available clients
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден контрагент" skip
      "Контрагент" p-supp-type p-supp-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  define buffer buf_obj_clients for ub.clients .
  find first buf_obj_clients no-lock
    where buf_obj_clients.obj-type = p-obj-type
      and buf_obj_clients.obj-code = p-obj-code
      no-error .
  if not available buf_obj_clients
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден объект" skip
      "Контрагент" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  assign
    name      = substitute("&1 &2 &3 &4"
                     ,goods.artic
                     ,goods.prod-type
                     ,goods.prod-code
                     ,goods.gds-name
                     )
    fi-obj    = substitute("&1 &2 &3"
                     ,p-obj-type
                     ,p-obj-code
                     ,buf_obj_clients.obj-name
                     )
    supp-name = substitute("&1 &2 &3"
                      ,p-supp-type
                      ,p-supp-code
                      ,clients.obj-name
                      )
    need-qnty = p-parts-qnty
  .
  assign
    fi-price-base = p-price-base
    fi-price-rubl = p-price-rubl
  .
  define variable v-host-code  as integer no-undo .
  define variable v-exch-rate  like ub.curr-accnt.exch-rate no-undo .
  define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
  run cur-time in this-procedure
    (output  v-today
    ,output  v-time
    ).
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  v-today
  ,output v-exch-rate
  ,output v-exch-scale
  ) no-error .
  assign
    rate-mmvb  = v-exch-rate
    scale-mmvb = v-exch-scale
  .
  if  p-base-rate > 0
  and p-base-scale > 0
  then do:
    assign
      fi-rate  = p-base-rate
      fi-scale = p-base-scale
    .
  end.
  else do:
    assign
      fi-rate  = v-exch-rate
      fi-scale = v-exch-scale
    .
  end.
  define buffer buf_currency for ub.currency .
  find first buf_currency no-lock
    where buf_currency.curr-code = v-base-code
    no-error .
  if available buf_currency
  then do:
    assign
      v-currency-base = buf_currency.curr-abbr
    .
  end.
  else do:
    assign
      v-currency-base = "ВАЛ"
    .
  end.
  find first buf_currency no-lock
    where buf_currency.curr-code = 0
    .
  assign
    v-currency-rubl = buf_currency.curr-abbr
  .
  assign
    fi-currency-base   = v-currency-base
    fi-currency-base-2 = v-currency-base
    fi-currency-base-3 = v-currency-base
    fi-currency-rubl   = v-currency-rubl
    fi-currency-rubl-2 = v-currency-rubl
    fi-currency-rubl-3 = v-currency-rubl
    b-rubl-from-base :label =  v-currency-base + " --> " + v-currency-rubl
    b-base-from-rubl :label =  v-currency-rubl + " --> " + v-currency-base
  .
  if fi-price-rubl > 0
  and fi-scale >0
  and fi-price-base > 0
  then do:
    assign
      fi-rate = fi-price-rubl * fi-scale / fi-price-base
    .
  end.
  assign
  b-base-from-rubl:LABEL in frame DIALOG-1 = "Руб --> Вал"
  b-base-from-rubl:TOOLTIP in frame DIALOG-1  = "Расчет базовой учетной цены (Вал) на основе рублевой (Руб)"
  b-rubl-from-base:label in frame DIALOG-1  = "Вал --> Руб"
  b-rubl-from-base:TOOLTIP in frame DIALOG-1 = "Расчет рублевой учетной цены (Руб) на основе базовой (Вал)"
  fi-price-rubl:TOOLTIP in frame DIALOG-1  = "Рублевая учетная цена"
  .
  RUN enable_UI.
  if v-base-code = 0
  then do:
    assign
      fi-price-base      :sensitive = false
      fi-scale           :sensitive = false
      fi-rate            :sensitive = false
      b-curr-rate        :sensitive = false
      b-rate-from-price  :sensitive = false
      b-base-from-rubl   :sensitive = false
      b-rubl-from-base   :sensitive = false
      rate-mmvb          :sensitive = false
      scale-mmvb         :sensitive = false
      fi-currency-base   :sensitive = false
      fi-currency-base-2 :sensitive = false
      fi-currency-base-3 :sensitive = false
      fi-currency-rubl-2 :sensitive = false
      fi-currency-rubl-3 :sensitive = false
      rect-1             :sensitive = false
      rect-2             :sensitive = false
      fi-formula-1       :sensitive = false
      fi-formula-2       :sensitive = false
      fi-formula-3       :sensitive = false
      fi-formula-4       :sensitive = false
      fi-formula-5       :sensitive = false
      fi-formula-6       :sensitive = false
    .
    assign
      fi-price-base      :visible = false
      fi-scale           :visible = false
      fi-rate            :visible = false
      b-curr-rate        :visible = false
      b-rate-from-price  :visible = false
      b-base-from-rubl   :visible = false
      b-rubl-from-base   :visible = false
      rate-mmvb          :visible = false
      scale-mmvb         :visible = false
      fi-currency-base   :visible = false
      fi-currency-base-2 :visible = false
      fi-currency-base-3 :visible = false
      fi-currency-rubl-2 :visible = false
      fi-currency-rubl-3 :visible = false
      rect-1             :visible = false
      rect-2             :visible = false
      fi-formula-1       :visible = false
      fi-formula-2       :visible = false
      fi-formula-3       :visible = false
      fi-formula-4       :visible = false
      fi-formula-5       :visible = false
      fi-formula-6       :visible = false
    .
  end.
  if fi-price-base :sensitive
  then do:
    define variable v-curr-r-b as character no-undo .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U
    then do:
      apply "entry":u to fi-price-base in frame DIALOG-1.
    end.
    else do:
      apply "entry":u to fi-price-rubl in frame DIALOG-1.
    end.
  end.
  else do:
    apply "entry":u to fi-price-rubl in frame DIALOG-1.
  end.
  WAIT-FOR GO OF FRAME DIALOG-1.
END.
RUN disable_UI.
PROCEDURE calc-base-from-rubl :
  run validate-not-zero
    (input 'scale':u
    ).
  if return-value = 'false':u
  then do:
    return 'false':u .
  end.
  do with frame DIALOG-1:
    assign
      fi-price-base :screen-value = string(input fi-price-rubl * input fi-scale / input fi-rate)
    .
  end.
END PROCEDURE.
PROCEDURE calc-rate-from-price :
  run validate-not-zero
    (input 'price-base':u
    ).
  if return-value = 'false':u
  then do:
    return 'false':u .
  end.
  do with frame DIALOG-1:
    assign
      fi-rate :screen-value = string( input fi-price-rubl * input fi-scale / input fi-price-base)
    .
  end.
END PROCEDURE.
PROCEDURE calc-rubl-from-base :
  run validate-not-zero
    (input 'scale':u
    ).
  if return-value = 'false':u
  then do:
    return 'false':u .
  end.
  do with frame DIALOG-1:
    assign
      fi-price-rubl :screen-value = string(input fi-price-base * input fi-rate  / input fi-scale)
    .
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY name fi-obj need-qnty supp-name fi-rate rate-mmvb fi-scale scale-mmvb
          fi-price-rubl fi-price-base fi-currency-base-2 fi-formula-2
          fi-currency-rubl fi-currency-rubl-2 fi-formula-1 fi-formula-3
          fi-currency-rubl-3 fi-formula-4 fi-currency-base fi-currency-base-3
          fi-formula-5 fi-formula-6
      WITH FRAME DIALOG-1.
  ENABLE b-exit b-quit b-goods b-supp b-help RECT-1 RECT-2 RECT-3 RECT-4
         b-rate-from-price b-curr-rate fi-rate fi-scale fi-price-rubl
         b-rubl-from-base fi-price-base b-base-from-rubl fi-currency-base-2
         fi-formula-2 fi-currency-rubl fi-currency-rubl-2 fi-formula-1
         fi-formula-3 fi-currency-rubl-3 fi-formula-4 fi-currency-base
         fi-currency-base-3 fi-formula-5 fi-formula-6
      WITH FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE validate-not-zero :
  define input parameter p-need-check as character no-undo .
  do with frame DIALOG-1 :
    case p-need-check
    :
      when 'rate':u
      then do:
        if input fi-rate = 0
        or input fi-rate = ?
        then do:
          message
            "Задайте" fi-rate:label
            view-as alert-box .
          apply "entry":u to fi-rate.
          return 'false':u .
        end.
      end.
      when 'price-base':u
      then do:
        if input fi-price-base = 0
        or input fi-price-base = ?
        then do:
          message
            "Задайте базовую учетную цену"
            view-as alert-box .
          apply "entry":u to fi-price-base.
          return 'false':u .
        end.
      end.
      when 'price-rubl':u
      then do:
        if input fi-price-rubl = 0
        or input fi-price-rubl = ?
        then do:
          message
            "Задайте учетную цену в рублях"
            view-as alert-box .
          apply "entry":u to fi-price-rubl.
          return 'false':u .
        end.
      end.
      when 'scale':u
      then do:
        if input fi-scale = 0
        or input fi-scale = ?
        then do:
          message
            "Задайте базовую учетную цену"
            view-as alert-box .
          apply 'entry':u to fi-scale.
          return 'false':u .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Процедура validate-not-zero. Неизвестный параметр " skip
          "p-need-check" p-need-check skip
          view-as alert-box error .
        undo, return error .
      end.
    end case.
  end.
END PROCEDURE.
