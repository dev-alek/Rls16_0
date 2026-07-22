DEFINE INPUT  PARAMETER parparentproc        AS WIDGET-HANDLE        NO-UNDO.
define input  parameter p-init-doc-type-list as character            no-undo.
define output parameter date_exp_from       as date      INIT ?     no-undo.
define output parameter date_exp_to         as date      INIT ?     no-undo.
define output parameter p-range             as integer              no-undo.
define output parameter p-obj-list          as character            no-undo.
define output parameter p-doc-type-list     as character            no-undo.
define output parameter p-cancel            as logical   INIT no    no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для выгрузки ФО".
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
define temp-table userhsts_temp-user-host no-undo
  field host-code as integer
  index xpk is primary unique host-code
  .
procedure userhsts_clear :
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      delete buf_userhsts_temp-user-host .
    end.
  end.
end procedure.
procedure userhsts_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end procedure.
procedure userhsts_append :
  define input  parameter p-host-code as integer   no-undo .
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    find first buf_userhsts_temp-user-host
      where buf_userhsts_temp-user-host.host-code = p-host-code
      no-error .
    if not available buf_userhsts_temp-user-host
    then do:
      create buf_userhsts_temp-user-host .
      assign
        buf_userhsts_temp-user-host.host-code = p-host-code
      .
    end.
  end.
end procedure.
procedure userhsts_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    find first buf_userhsts_temp-user-host
      no-error .
    if not available buf_userhsts_temp-user-host
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end procedure.
procedure userhsts_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userhsts_transfer: Передача списка объектов".
  define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userhsts_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userhsts_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userhsts_temp-user-host
    on error undo, return error return-value
    :
      run userhsts_append in p-callback-handle
        (input  buf_userhsts_temp-user-host.host-code
        ) .
    end.
  end.
end procedure.
procedure userhsts_select-one :
  define input  parameter parparentproc      as widget-handle no-undo .
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-curr-host-code   as integer   no-undo .
  define output parameter p-user-select      as logical   no-undo .
  define output parameter p-select-host-code as character no-undo .
  DEFINE VARIABLE v-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".
  do
  on error undo, return error return-value
  :
    run gbl/userhsts.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-curr-host-code
      ,input  "b-sel"
      ,output p-user-select
      ,output p-select-host-code
      ,OUTPUT v-List-Select-host-code
      ) .
  end.
end procedure.
procedure userhsts_select-many :
  define input  parameter parparentproc      as widget-handle no-undo .
  define input  parameter p-db-num           as integer   no-undo .
  define input  parameter p-user-id          as character no-undo .
  define input  parameter p-curr-host-code   as integer   no-undo .
  define output parameter p-user-select      as logical   no-undo .
  define variable v-select-host-code as integer   no-undo .
  DEFINE VARIABLE v-List-select-host-code AS CHARACTER NO-UNDO INITIAL "".
  do
  on error undo, return error return-value
  :
    run gbl/userhsts.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-curr-host-code
      ,input  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-host-code
      ,OUTPUT v-List-Select-host-code
      ) .
  end.
end procedure.
define variable v-obj-list          as character    no-undo.
define variable v-host-name         as character    no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.
define variable v-ext-fin-doc-type-list as character extent 16 init
[
    "приходный кассовый ордер",                  'пко':U,
    "расходный кассовый ордер",                  'рко':U,
    "приходное платежное поручение",             'ппп':U,
    "расходное платежное поручение",             'рпп':U,
    "приходный АПЗ",                             'апп':U,
    "расходный АПЗ",                             'апр':U
]                                                           no-undo.
define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    field obj-name as character
    index pi is primary unique obj-type obj-code
.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON bt-sel-host
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.6 BY 1.03.
DEFINE BUTTON Btn_Cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ed-object AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 37.9 BY 6.27
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE date_from AS DATE FORMAT "99/99/9999":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE date_to AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "глобально", 1,
"по фирмам", 2
     SIZE 13.8 BY 3.27 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.4 BY 7.33.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.27 COL 1.5
     Btn_Cancel AT ROW 1.27 COL 11.5
     b-help AT ROW 1.27 COL 47.5
     date_from AT ROW 2.77 COL 8.5 COLON-ALIGNED
     date_to AT ROW 2.77 COL 25.4 COLON-ALIGNED
     rs-1 AT ROW 5.03 COL 3 NO-LABEL
     ed-object AT ROW 5.27 COL 18.5 NO-LABEL
     bt-sel-host AT ROW 7 COL 15
     RECT-1 AT ROW 4.43 COL 1.9
     SPACE(0.94) SKIP(0.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Диапазон дат для экспорта".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF bt-sel-host IN FRAME Dialog-Frame
DO:
    assign
        rs-1 :screen-value  = "2"
    .
    define buffer buf_user-host for ub.user-host .
    define buffer buf_userhsts_temp-user-host for userhsts_temp-user-host .
    find first buf_user-host no-lock
      where buf_user-host.db-num    = v-cntxt-db-num
        and buf_user-host.user-id   = v-cntxt-userid
        and buf_user-host.host-code = v-cntxt-host-code-obj
      no-error .
    if available buf_user-host
    then do:
      run userhsts_clear in this-procedure .
      run userhsts_append in this-procedure
        (input v-cntxt-host-code-obj
        ) .
    end.
    define variable v-user-select as logical   no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userhsts_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,output v-user-select
  )  .
    if v-user-select <> true
    then do:
      return no-apply .
    end.
    run clear-obj-list in this-procedure .
    for each buf_userhsts_temp-user-host
    :
      run fill-obj-list in this-procedure
        (input buf_userhsts_temp-user-host.host-code
        ) no-error .
      if error-status :error
      then do:
        return no-apply.
      end.
    end.
    assign
        v-obj-list = ""
    .
    for each temp_obj-list:
        assign v-obj-list = v-obj-list + (if v-obj-list <> "" then chr(10) else "" )
                           + temp_obj-list.obj-type + string( temp_obj-list.obj-code ) + chr(32)
                           + temp_obj-list.obj-name
                                    .
    end.
    assign
        ed-object :screen-value = v-obj-list
    .
END.
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame
DO:
    assign
        p-cancel = yes
    .
    apply "window-close" to frame Dialog-Frame.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
    ASSIGN
        date_from
        date_to
        rs-1
        date_exp_from = date_from
        date_exp_to   = date_to
    .
    if date_from > date_to
    then do:
        message
            "Даты интервала заданы неверно. "
            skip " Нижняя дата интервала должна быть меньше верхней."
            skip(1) "Задайте интервал дат правильно или отмените экспорт."
        view-as alert-box information.
        apply "entry" to date_from.
        undo, return no-apply.
    end.
      case rs-1 :screen-value
      :
      when "1"
      then do:
          assign
              p-range = 1
              p-obj-list = ""
          .
      end.
      when "2"
      then do:
          assign
              p-range = 2
          .
          assign
              p-obj-list = ""
          .
          for each temp_obj-list
          :
              assign
                  p-obj-list = p-obj-list
                          + ( if p-obj-list = "" then "" else "," ) + temp_obj-list.obj-type
                          + "," + string( temp_obj-list.obj-code )
              .
          end.
      end.
      end case.
   APPLY "GO" TO FRAME Dialog-Frame.
END.
ON RETURN OF date_from IN FRAME Dialog-Frame
DO:
    APPLY "ENTRY" TO date_to IN FRAME Dialog-Frame.
    RETURN NO-APPLY.
END.
ON RETURN OF date_to IN FRAME Dialog-Frame
DO:
    APPLY "ENTRY" TO btn_OK IN FRAME Dialog-Frame.
    RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF rs-1 IN FRAME Dialog-Frame
DO:
run object-select in this-procedure no-error .
if error-status :error
then do:
    undo, return no-apply.
end.
assign
    rs-1
.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date_from in frame Dialog-Frame
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
on delete-character of date_from in frame Dialog-Frame
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
on ctrl-d of date_from in frame Dialog-Frame
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
on ctrl-b of date_from in frame Dialog-Frame
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
on ctrl-e of date_from in frame Dialog-Frame
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
on ctrl-f of date_from in frame Dialog-Frame
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
  define MENU m-ed-date7
    MENU-ITEM m-ed-date7-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date7-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date7-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date7-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date_from :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date_from :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date7 :HANDLE
      date_from :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle7 as handle no-undo .
  assign
    v-label-handle7 = date_from :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle7)
  then do:
    if v-label-handle7 :tooltip = ""
    or v-label-handle7 :tooltip = ?
    then do:
      assign
        v-label-handle7 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date7-1 in menu m-ed-date7 DO:
    apply "ctrl-b":U to date_from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-2 in menu m-ed-date7 DO:
    apply "ctrl-d":U to date_from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-3 in menu m-ed-date7 DO:
    apply "ctrl-e":U to date_from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date7-4 in menu m-ed-date7 DO:
    apply "ctrl-f":U to date_from in frame Dialog-Frame .
  END.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of date_to in frame Dialog-Frame
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
on delete-character of date_to in frame Dialog-Frame
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
on ctrl-d of date_to in frame Dialog-Frame
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
on ctrl-b of date_to in frame Dialog-Frame
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
on ctrl-e of date_to in frame Dialog-Frame
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
on ctrl-f of date_to in frame Dialog-Frame
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
  define MENU m-ed-date9
    MENU-ITEM m-ed-date9-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date9-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date9-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date9-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date_to :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date_to :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date9 :HANDLE
      date_to :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle9 as handle no-undo .
  assign
    v-label-handle9 = date_to :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle9)
  then do:
    if v-label-handle9 :tooltip = ""
    or v-label-handle9 :tooltip = ?
    then do:
      assign
        v-label-handle9 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date9-1 in menu m-ed-date9 DO:
    apply "ctrl-b":U to date_to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-2 in menu m-ed-date9 DO:
    apply "ctrl-d":U to date_to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-3 in menu m-ed-date9 DO:
    apply "ctrl-e":U to date_to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date9-4 in menu m-ed-date9 DO:
    apply "ctrl-f":U to date_to in frame Dialog-Frame .
  END.
run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
ASSIGN
    date_from = v-today
    date_to   = v-today
.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" v-cntxt-host-code-obj
          skip "Имя фирмы будет отображаться как '" + 'орг':U + string( v-cntxt-host-code-obj ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box warning.
        assign
            v-host-name = 'орг':U + string( v-cntxt-host-code-obj )
        .
    end.
  RUN enable_UI.
   run init-fields in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE clear-obj-list :
  define buffer buf_temp_obj-list for temp_obj-list .
  do
  on error undo, return error return-value
  :
    for each buf_temp_obj-list
    on error undo, return error return-value
    :
      delete buf_temp_obj-list .
    end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY date_from date_to rs-1 ed-object
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 Btn_OK Btn_Cancel b-help date_from date_to rs-1 bt-sel-host
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-obj-list :
  define input  parameter p-host-code as integer   no-undo .
  do
  on error undo, return error
  :
    define buffer buf_clients for ub.clients.
    find first buf_clients no-lock
      where buf_clients.obj-type = 'орг':U
        and buf_clients.obj-code = p-host-code
      no-error .
    if not available buf_clients
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена фирма с кодом" p-host-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    create temp_obj-list.
    assign
      temp_obj-list.obj-type = buf_clients.obj-type
      temp_obj-list.obj-code = buf_clients.obj-code
      temp_obj-list.obj-name = buf_clients.obj-name
    .
  end.
END PROCEDURE.
PROCEDURE get-host-name :
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.
define buffer buf_clients   for ub.clients.
    find first buf_clients no-lock
         where buf_clients.obj-type = 'орг':U
           and buf_clients.obj-code = v-cntxt-host-code-obj
    no-error.
    if not available buf_clients
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось найти текущую фирму"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    else do:
        assign
            p-host-name = buf_clients.obj-name
        .
    end.
end.
END PROCEDURE.
PROCEDURE init-fields :
do
on error undo, return error
:
  define variable v-oper-num     as integer           no-undo.
  define buffer buf_user-host for ub.user-host.
  find first buf_user-host no-lock
    where buf_user-host.db-num    = v-cntxt-db-num
      and buf_user-host.user-id   = v-cntxt-userid
      and buf_user-host.host-code = v-cntxt-host-code-obj
    no-error .
  if available buf_user-host
  then do:
      run clear-obj-list in this-procedure .
      run fill-obj-list in this-procedure
        (input  buf_user-host.host-code
        ) no-error .
  end.
   assign
        p-doc-type-list = p-init-doc-type-list
    .
    assign
        rs-1 :screen-value in frame dialog-frame = "2"
        ed-object :screen-value in frame Dialog-frame = 'орг':U + string( v-cntxt-host-code-obj ) + " " + v-host-name
    .
    assign
        rs-1
    .
    display rs-1
    with frame Dialog-Frame
    .
    END.
    END PROCEDURE.
PROCEDURE object-select :
do
on error undo, return error
:
case rs-1 :screen-value in frame Dialog-frame
:
    when "1"
    then do:
        assign
            ed-object :screen-value = ""
        .
    end.
    when "2"
    then do:
        for each temp_obj-list
        :
            delete temp_obj-list.
        end.
        create temp_obj-list.
        assign
            temp_obj-list.obj-type  = 'орг':U
            temp_obj-list.obj-code  = v-cntxt-host-code-obj
            ed-object :screen-value = temp_obj-list.obj-type + string(temp_obj-list.obj-code) + chr(32) + "(":U + v-host-name + ")":U
        .
    end.
end case.
end.
END PROCEDURE.
