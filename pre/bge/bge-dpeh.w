define input parameter parparentproc        as handle               no-undo.
define input parameter p-output-type        as integer              no-undo.
define input parameter p-init-doc-type-list as character            no-undo.
define output parameter date_exp_from       as date      INIT ?     no-undo.
define output parameter p-shift-num-from    as integer              no-undo.
define output parameter date_exp_to         as date      INIT ?     no-undo.
define output parameter p-shift-num-to      as integer              no-undo.
define output parameter p-shift-on          as logical              no-undo.
define output parameter p-range             as integer              no-undo.
define output parameter p-host-code         as integer              no-undo.
define output parameter p-obj-list          as character            no-undo.
define output parameter p-doc-type-list     as character            no-undo.
define output parameter p-pay-code          as logical   INIT no    no-undo.
define output parameter p-cst               as logical   INIT no    no-undo.
define output parameter p-parts             as logical   INIT no    no-undo.
define output parameter p-chk-pay-code      as logical   INIT no    no-undo.
define output parameter p-pay-desk          as logical   INIT no    no-undo.
define output parameter p-pay-desk-cards    as logical   INIT no    no-undo.
define output parameter p-deleted           as logical   INIT no    no-undo.
define output parameter p-chk               as logical   INIT no    no-undo.
define output parameter p-doc-rvs           as logical   INIT no    no-undo.
define output parameter p-cancel            as logical   INIT no    no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Выбор параметров для выгрузки документов по сменам.".
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
define  temp-table temp-host no-undo
  field host-code like ub.store.host-code
  index xpk host-code
.
define  temp-table temp-obj no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field host-code like ub.store.host-code
  field db-num    like ub.clients.db-num
  index xpk  obj-type obj-code
  index xie1 host-code
  index xie2 db-num host-code
.
procedure init-temphost:
  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients .
  define buffer buf_db for ub.db .
  define buffer buf_temp-host for temp-host .
  define buffer buf_temp-obj for temp-obj .
  do
  on error undo, return error return-value
  :
    for each buf_store
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_store.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_store.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'скл':U
          and buf_clients.obj-code = buf_store.obj-code
        no-error .
      if not available buf_clients
      then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'скл':U buf_store.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'скл':U
        buf_temp-obj.obj-code  = buf_store.obj-code
        buf_temp-obj.host-code = buf_store.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
    for each buf_shop
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_shop.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_shop.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'маг':U
          and buf_clients.obj-code = buf_shop.obj-code
        no-error .
      if not available buf_clients then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'маг':U buf_shop.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'маг':U
        buf_temp-obj.obj-code  = buf_shop.obj-code
        buf_temp-obj.host-code = buf_shop.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
  end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
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
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
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
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
define variable v-obj-list          as character    no-undo.
define variable v-obj-full-list     as character    no-undo.
define variable v-host-name         as character    no-undo.
define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON bt-sel-doc-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON bt-sel-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.
DEFINE BUTTON Btn_Cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE ed-doc-type AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-VERTICAL NO-BOX
     SIZE 35.75 BY 1.83 NO-UNDO.
DEFINE VARIABLE ed-doc-type-label AS CHARACTER INITIAL "Типы документов"
     VIEW-AS EDITOR NO-BOX
     SIZE 12.5 BY 1.75 NO-UNDO.
DEFINE VARIABLE ed-object AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 35.63 BY 3.38
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE date_from AS DATE FORMAT "99/99/9999":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE date_to AS DATE FORMAT "99/99/9999":U
     LABEL "---    Дата по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.
DEFINE VARIABLE fi-shift-num-from AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Порядок с"
     VIEW-AS FILL-IN
     SIZE 3.5 BY 1 NO-UNDO.
DEFINE VARIABLE fi-shift-num-to AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Порядок по"
     VIEW-AS FILL-IN
     SIZE 3.5 BY 1 NO-UNDO.
DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "глобально", 1,
"по фирме", 2,
"по объектам", 3
     SIZE 13.75 BY 3.25 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.38 BY 4.38.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.25 BY 2.17.
DEFINE VARIABLE tb-chk-pay-code AS LOGICAL INITIAL no
     LABEL "По типу кассовых платежей из чеков"
     VIEW-AS TOGGLE-BOX
     SIZE 38 BY .83 NO-UNDO.
DEFINE VARIABLE tb-cst-code AS LOGICAL INITIAL no
     LABEL "ГТД по строке документа"
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .83 NO-UNDO.
DEFINE VARIABLE tb-deleted AS LOGICAL INITIAL no
     LABEL "удалённые"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-checks AS LOGICAL INITIAL no
     LABEL "Чеки"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY .83 NO-UNDO.
DEFINE VARIABLE tb-exp-doc-rvs AS LOGICAL INITIAL no
     LABEL "Сверки до/после слива"
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .83 NO-UNDO.
DEFINE VARIABLE tb-inkass-pay-code AS LOGICAL INITIAL no
     LABEL "По виду оплаты"
     VIEW-AS TOGGLE-BOX
     SIZE 24.38 BY .83 NO-UNDO.
DEFINE VARIABLE tb-parts AS LOGICAL INITIAL no
     LABEL "По партиям"
     VIEW-AS TOGGLE-BOX
     SIZE 26.38 BY .83 NO-UNDO.
DEFINE VARIABLE tb-pay-desk AS LOGICAL INITIAL no
     LABEL "По кассе"
     VIEW-AS TOGGLE-BOX
     SIZE 12.25 BY .83 NO-UNDO.
DEFINE VARIABLE tb-pay-desk-cards AS LOGICAL INITIAL no
     LABEL "По префиксам карт"
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY .83 NO-UNDO.
DEFINE VARIABLE tb-supp AS LOGICAL INITIAL no
     LABEL "Остатки по поставщикам"
     VIEW-AS TOGGLE-BOX
     SIZE 26.88 BY .83 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     Btn_Cancel AT ROW 1.25 COL 11.5
     b-help AT ROW 1.25 COL 47
     date_from AT ROW 3 COL 9.5 COLON-ALIGNED
     date_to AT ROW 3 COL 42.5 COLON-ALIGNED
     fi-shift-num-from AT ROW 4.25 COL 18 COLON-ALIGNED
     fi-shift-num-to AT ROW 4.25 COL 51 COLON-ALIGNED
     tb-supp AT ROW 6.63 COL 10
     ed-object AT ROW 7.04 COL 20.38 NO-LABEL
     rs-1 AT ROW 7.13 COL 2.63 NO-LABEL
     bt-sel-obj AT ROW 9.29 COL 16.63
     ed-doc-type AT ROW 11.25 COL 16.38 NO-LABEL
     bt-sel-doc-type AT ROW 11.29 COL 52.88
     ed-doc-type-label AT ROW 11.33 COL 2.63 NO-LABEL
     tb-inkass-pay-code AT ROW 13.54 COL 2.13
     tb-deleted AT ROW 13.58 COL 36.13
     tb-cst-code AT ROW 14.33 COL 2.13
     tb-exp-checks AT ROW 14.33 COL 36.13 WIDGET-ID 2
     tb-exp-doc-rvs AT ROW 15.08 COL 36.13
     tb-parts AT ROW 15.08 COL 2.13
     tb-chk-pay-code AT ROW 15.83 COL 2.13
     tb-pay-desk AT ROW 16.75 COL 5.13
     tb-pay-desk-cards AT ROW 17.58 COL 5.13
     RECT-2 AT ROW 11.13 COL 1.63
     RECT-1 AT ROW 6.5 COL 1.5
     SPACE(1.36) SKIP(7.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Диапазон дат для экспорта".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       ed-doc-type:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       ed-doc-type-label:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       tb-supp:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF bt-sel-doc-type IN FRAME Dialog-Frame
DO:
    define variable v-cancel     as logical           no-undo.
    define variable v-oper-num   as integer           no-undo.
    run bge/bgeseltp.w (
          input "trn-doc":U
        , input p-init-doc-type-list
        , output p-doc-type-list
        , output v-cancel
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка выбора типов операций."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-cancel = yes
    then do:
        assign
            p-doc-type-list = p-init-doc-type-list
        .
    end.
    else do:
        assign
            p-init-doc-type-list    = p-doc-type-list
        .
        if p-doc-type-list = "":U
        then do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = "Все"
            .
        end.
        else do:
            assign
                ed-doc-type :screen-value in frame Dialog-Frame = "":U
            .
            do v-oper-num = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
            :
                if lookup( entry( v-oper-num, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), p-init-doc-type-list ) <> 0
                then do:
                    assign
                        ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                    + entry( v-oper-num, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) + chr(10)
                    .
                end.
            end.
        end.
    end.
END.
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame
DO:
    define variable v-shift-on    as logical      no-undo.
    define variable v-object-available as logical   no-undo .
    assign
        rs-1 :screen-value  = "3"
    .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usobjava in g#library2
  (input  v-cntxt-db-num
  ,input  0
  ,input  v-cntxt-userid
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-object-available
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usobjava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.
    if v-object-available = true
    then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_append in this-procedure
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  )  .
    end.
    define variable v-user-select as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
    if v-user-select <> true
    then do:
      message
        "Объект не выбран"
        view-as alert-box information .
      return no-apply .
    end.
    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
    for each  temp_obj-list.
      delete temp_obj-list.
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      create temp_obj-list.
      assign
        temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
        temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
      .
    end.
    assign
        v-obj-list      = "":U
        v-obj-full-list = "":U
    .
    for each temp_obj-list
    :
        assign
            v-obj-list      = v-obj-list
                            + ( if v-obj-list <> "":U then ", " else "":U )
                            + substitute( "&1&2", temp_obj-list.obj-type, temp_obj-list.obj-code )
            v-obj-full-list = v-obj-full-list
                            + ( if v-obj-full-list <> "":U then ", " else "":U )
                            + substitute( "&1,&2", temp_obj-list.obj-type, temp_obj-list.obj-code )
        .
    end.
    assign
        ed-object :screen-value = v-obj-list
    .
    run get-shift-on in this-procedure (
          input 3
        , input v-obj-full-list
        , output v-shift-on
    ).
    if v-shift-on = ?
    then do:
        message
                 "Неверно выбраны объекты. Все выбранные объекты"
            skip "должны быть либо сменными, либо не сменными."
        view-as alert-box information.
        assign
            date_from :label = "Дата с"
        .
        hide
            fi-shift-num-from
            fi-shift-num-to
        .
    end.
    else do:
        if v-shift-on = yes
        then do:
            assign
                date_from :label = "Смена с"
            .
            view
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
        else do:
            assign
                date_from :label = "Дата с"
            .
            hide
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
    end.
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
        tb-inkass-pay-code
        tb-cst-code
        tb-parts
        tb-deleted
        tb-supp
        rs-1
        tb-chk-pay-code
        tb-pay-desk
        tb-pay-desk-cards
        tb-exp-checks
        tb-exp-doc-rvs
        fi-shift-num-from
        fi-shift-num-to
    .
    assign
        date_exp_from       = date_from
        date_exp_to         = date_to
        p-shift-num-from    = fi-shift-num-from
        p-shift-num-to      = fi-shift-num-to
        p-chk               = tb-exp-checks
        p-doc-rvs           = tb-exp-doc-rvs
    .
    if p-output-type = 0
    then do:
      case rs-1 :screen-value
      :
      when "1"
      then do:
          assign
              p-range = 1
              p-obj-list = "":U
          .
      end.
      when "2"
      then do:
          assign
              p-range = 2
              p-obj-list = "":U
          .
      end.
      when "3"
      then do:
          assign
              p-range = 3
          .
          assign
              p-obj-list = "":U
          .
          for each temp_obj-list
          :
              assign
                  p-obj-list = p-obj-list
                          + ( if p-obj-list = "":U then "":U else ",":U ) + temp_obj-list.obj-type
                          + ",":U + string( temp_obj-list.obj-code )
              .
          end.
      end.
      end case.
    end.
    if p-output-type = 2
    then do:
        assign
            p-cst = tb-supp
        .
    end.
    if p-output-type = 1
    or p-output-type = 3
    or p-output-type = 4
    or p-output-type = 5
    then do:
        if p-output-type = 1
        then do:
            assign
                p-pay-code     = tb-inkass-pay-code
                p-cst          = tb-cst-code
                p-parts        = tb-parts
                p-deleted      = tb-deleted
                p-chk-pay-code = tb-chk-pay-code
                p-pay-desk     = tb-pay-desk
                p-pay-desk-cards = tb-pay-desk-cards
            .
        end.
        case rs-1 :screen-value
        :
        when "1"
        then do:
            assign
                p-range = 1
                p-obj-list = "":U
            .
        end.
        when "2"
        then do:
            assign
                p-range = 2
                p-host-code = v-cntxt-host-code-obj
                p-obj-list = "":U
            .
        end.
        when "3"
        then do:
            assign
                p-range = 3
            .
            assign
                p-obj-list = "":U
            .
            for each temp_obj-list
            :
                assign
                    p-obj-list = p-obj-list
                            + ( if p-obj-list = "":U then "":U else ",":U )
                            + substitute( "&1,&2", temp_obj-list.obj-type, temp_obj-list.obj-code )
                .
            end.
        end.
        end case.
    end.
    define variable v-data-are-valid        as logical      no-undo.
    define variable v-reason                as character    no-undo.
    define variable v-err-widget-handle     as handle       no-undo.
    run check-data in this-procedure (
          input date_exp_from
        , input date_exp_to
        , input p-shift-num-from
        , input p-shift-num-to
        , input tb-inkass-pay-code
        , input tb-cst-code
        , input tb-parts
        , input tb-deleted
        , input tb-supp
        , input tb-chk-pay-code
        , input tb-pay-desk
        , input tb-pay-desk-cards
        , input p-range
        , input p-obj-list
        , output v-data-are-valid
        , output v-reason
        , output v-err-widget-handle
        , output p-shift-on
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка проверки данных."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    if v-data-are-valid = no
    then do:
        message
            "Выгрузка по введённым данным невозможна."
            skip v-reason
            skip (1)
            skip "Исправьте данные и повторите ввод."
        view-as alert-box error
        title "Ошибка введённых данных".
        if valid-handle( v-err-widget-handle )
        then do:
            apply "entry" to v-err-widget-handle.
        end.
        undo, return no-apply.
    end.
    run write-parameters in this-procedure (
          input date_from
        , input date_to
        , input fi-shift-num-from
        , input fi-shift-num-to
        , input rs-1
        , input p-host-code
        , input p-obj-list
        , input p-init-doc-type-list
        , input p-pay-code
        , input p-cst
        , input p-parts
        , input p-chk-pay-code
        , input p-pay-desk
        , input p-pay-desk-cards
        , input p-deleted
        , input p-chk
        , input p-doc-rvs
    ).
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
ON VALUE-CHANGED OF tb-chk-pay-code IN FRAME Dialog-Frame
DO:
    assign
        tb-chk-pay-code
    .
    run manage-tb-chk-pay-code in this-procedure.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date10
    MENU-ITEM m-ed-date10-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date10-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date10-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date10-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date_from :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date_from :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date10 :HANDLE
      date_from :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle10 as handle no-undo .
  assign
    v-label-handle10 = date_from :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle10)
  then do:
    if v-label-handle10 :tooltip = ""
    or v-label-handle10 :tooltip = ?
    then do:
      assign
        v-label-handle10 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date10-1 in menu m-ed-date10 DO:
    apply "ctrl-b":U to date_from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-2 in menu m-ed-date10 DO:
    apply "ctrl-d":U to date_from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-3 in menu m-ed-date10 DO:
    apply "ctrl-e":U to date_from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date10-4 in menu m-ed-date10 DO:
    apply "ctrl-f":U to date_from in frame Dialog-Frame .
  END.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define MENU m-ed-date12
    MENU-ITEM m-ed-date12-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date12-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date12-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date12-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if date_to :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      date_to :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date12 :HANDLE
      date_to :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle12 as handle no-undo .
  assign
    v-label-handle12 = date_to :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle12)
  then do:
    if v-label-handle12 :tooltip = ""
    or v-label-handle12 :tooltip = ?
    then do:
      assign
        v-label-handle12 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date12-1 in menu m-ed-date12 DO:
    apply "ctrl-b":U to date_to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-2 in menu m-ed-date12 DO:
    apply "ctrl-d":U to date_to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-3 in menu m-ed-date12 DO:
    apply "ctrl-e":U to date_to in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date12-4 in menu m-ed-date12 DO:
    apply "ctrl-f":U to date_to in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run init-fields in this-procedure .
    RUN enable_UI.
    run init-manage-fields in this-procedure .
    WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE assign-date :
define input parameter p-parameter-number   as integer          no-undo.
define input parameter p-parameter-list     as character        no-undo.
define input parameter p-default-value      as date             no-undo.
define output parameter p-parameter-value   as date             no-undo.
do
on error undo, return error
:
    if num-entries( p-parameter-list ) >= p-parameter-number
    then do:
        assign
            p-parameter-value   = date( entry( p-parameter-number, p-parameter-list ) )
        no-error.
        if error-status :error
        then do:
            assign
                p-parameter-value = p-default-value
            .
        end.
    end.
    else do:
        assign
            p-parameter-value = p-default-value
        .
    end.
end.
END PROCEDURE.
PROCEDURE assign-integer :
define input parameter p-parameter-number   as integer          no-undo.
define input parameter p-parameter-list     as character        no-undo.
define input parameter p-default-value      as integer          no-undo.
define output parameter p-parameter-value   as integer          no-undo.
do
on error undo, return error
:
    if num-entries( p-parameter-list ) >= p-parameter-number
    then do:
        assign
            p-parameter-value   = integer( entry( p-parameter-number, p-parameter-list ) )
        no-error.
        if error-status :error
        then do:
            assign
                p-parameter-value = p-default-value
            .
        end.
    end.
    else do:
        assign
            p-parameter-value = p-default-value
        .
    end.
end.
END PROCEDURE.
PROCEDURE assign-logical :
define input parameter p-parameter-number   as integer          no-undo.
define input parameter p-parameter-list     as character        no-undo.
define input parameter p-default-value      as logical          no-undo.
define output parameter p-parameter-value   as logical          no-undo.
do
on error undo, return error
:
    if num-entries( p-parameter-list ) >= p-parameter-number
    then do:
        assign
            p-parameter-value   = ( entry( p-parameter-number, p-parameter-list ) = "yes" )
        .
    end.
    else do:
        assign
            p-parameter-value = p-default-value
        .
    end.
end.
END PROCEDURE.
PROCEDURE check-data :
define input parameter p-date_from          as date             no-undo.
define input parameter p-date_to            as date             no-undo.
define input parameter p-shift-num-from     as integer          no-undo.
define input parameter p-shift-num-to       as integer          no-undo.
define input parameter p-tb-inkass-pay-code as logical          no-undo.
define input parameter p-tb-cst-code        as logical          no-undo.
define input parameter p-tb-parts           as logical          no-undo.
define input parameter p-tb-deleted         as logical          no-undo.
define input parameter p-tb-supp            as logical          no-undo.
define input parameter p-tb-chk-pay-code    as logical          no-undo.
define input parameter p-tb-pay-desk        as logical          no-undo.
define input parameter p-tb-pay-desk-cards  as logical          no-undo.
define input parameter p-range              as integer          no-undo.
define input parameter p-obj-list           as character        no-undo.
define output parameter p-data-are-valid    as logical          no-undo.
define output parameter p-reason            as character        no-undo.
define output parameter p-err-widget-handle as handle           no-undo.
define output parameter p-shift-on          as logical          no-undo.
    define variable v-shift-on    as logical      no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    assign
        p-data-are-valid = yes
    .
    if p-date_from > p-date_to
    and p-output-type <> 4
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3":U
                                    , chr(10)
                                    , "Даты интервала заданы неверно. "
                                    , "Нижняя дата интервала должна быть меньше верхней."
                                    )
            p-err-widget-handle = date_from :handle
        .
        undo, return no-apply.
    end.
    if p-range < 1
    or p-range > 3
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3":U
                                    , chr(10)
                                    , p-reason
                                    , "Неверно выбраны объекты для выгрузки."
                                    )
            p-err-widget-handle = rs-1 :handle
        .
        undo, return no-apply.
    end.
    run get-shift-on in this-procedure (
          input p-range
        , input p-obj-list
        , output v-shift-on
    ).
    if v-shift-on = ?
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3&1&4":U
                                    , chr(10)
                                    , p-reason
                                    , "Неверно выбраны объекты. Все выбранные объекты"
                                    , "должны быть либо сменными, либо не сменными."
                                    )
            p-err-widget-handle = rs-1 :handle
        .
    end.
    else do:
        assign
            p-shift-on = v-shift-on
        .
    end.
    if p-shift-on = yes
    and p-shift-num-from = 0
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3&1&4":U
                                    , chr(10)
                                    , p-reason
                                    , "Введите номер смены с..."
                                    )
            p-err-widget-handle = fi-shift-num-from :handle
        .
    end.
    if p-shift-on = yes
    and p-shift-num-to = 0
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3&1&4":U
                                    , chr(10)
                                    , p-reason
                                    , "Введите номер смены по..."
                                    )
            p-err-widget-handle = fi-shift-num-to :handle
        .
    end.
    if p-shift-on = yes
    and p-date_from = p-date_to
    and p-shift-num-from > p-shift-num-to
    then do:
        assign
            p-data-are-valid = no
            p-reason         = substitute( "&2&1&3&1&4":U
                                    , chr(10)
                                    , p-reason
                                    , "Неверно введены номера смен."
                                    )
            p-err-widget-handle = fi-shift-num-from :handle
        .
    end.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY date_from date_to ed-object rs-1 ed-doc-type ed-doc-type-label
          tb-inkass-pay-code tb-deleted tb-cst-code tb-exp-checks tb-parts
          tb-chk-pay-code tb-pay-desk tb-pay-desk-cards tb-exp-doc-rvs
      WITH FRAME Dialog-Frame.
  ENABLE RECT-2 RECT-1 Btn_OK Btn_Cancel b-help date_from date_to
         fi-shift-num-from fi-shift-num-to rs-1 bt-sel-obj ed-doc-type
         bt-sel-doc-type tb-inkass-pay-code tb-deleted tb-cst-code
         tb-exp-checks tb-parts tb-chk-pay-code tb-pay-desk tb-pay-desk-cards
         tb-exp-doc-rvs
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE get-host-name :
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.
define buffer buf_clients   for clients.
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
PROCEDURE get-shift-on :
define input parameter p-range          as integer          no-undo.
define input parameter p-obj-list       as character        no-undo.
define output parameter p-shift-on      as logical          no-undo.
    define variable v-shift-obj-on      as logical      no-undo.
    define variable v-obj-counter       as integer      no-undo.
    define variable v-obj-type          as character    no-undo.
    define variable v-obj-code          as integer      no-undo.
do
on error undo, return error
:
    assign
        p-shift-on = ?
    .
    case p-range
    :
        when 1
        then do:
            run init-temphost.
            check-shift-on-all-obj:
            for each temp-obj
            :
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  temp-obj.obj-type
  ,input  temp-obj.obj-code
  ,input  'shift-on=request'
  ,output v-shift-obj-on
  ) no-error .
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description
                        skip "Ошибка при определении типа сменный/не-сменный для объекта"
                        skip "Объект" temp-obj.obj-type temp-obj.obj-code
                        skip "Атрибут" 'shift-on=request':U
                        skip error-status :get-message(1)
                        skip return-value
                    view-as alert-box error .
                    undo, return error .
                end.
                if p-shift-on = ?
                then do:
                    assign
                        p-shift-on = v-shift-obj-on
                    .
                end.
                else do:
                    if p-shift-on <> v-shift-obj-on
                    then do:
                        assign
                            p-shift-on = ?
                        .
                        leave check-shift-on-all-obj.
                    end.
                end.
            end.
        end.
        when 2
        then do:
            run init-temphost.
            check-shift-on-all-obj:
            for each temp-obj
            where temp-obj.host-code = v-cntxt-host-code-obj
            :
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  temp-obj.obj-type
  ,input  temp-obj.obj-code
  ,input  'shift-on=request'
  ,output v-shift-obj-on
  ) no-error .
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description
                        skip "Ошибка при определении типа сменный/не-сменный для объекта"
                        skip "Объект" temp-obj.obj-type temp-obj.obj-code
                        skip "Атрибут" 'shift-on=request':U
                        skip error-status :get-message(1)
                        skip return-value
                    view-as alert-box error .
                    undo, return error .
                end.
                if p-shift-on = ?
                then do:
                    assign
                        p-shift-on = v-shift-obj-on
                    .
                end.
                else do:
                    if p-shift-on <> v-shift-obj-on
                    then do:
                        assign
                            p-shift-on = ?
                        .
                        leave check-shift-on-all-obj.
                    end.
                end.
            end.
        end.
        when 3
        then do:
            check-shift-on-all-obj:
            do
            v-obj-counter = 1 to num-entries( p-obj-list ) / 2
            on error undo, return error
            :
                assign
                    v-obj-type = trim( entry( v-obj-counter * 2 - 1, p-obj-list ) )
                    v-obj-code = integer( entry( v-obj-counter * 2    , p-obj-list ) )
                .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,input  'shift-on=request'
  ,output v-shift-obj-on
  ) no-error .
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description
                        skip "Ошибка при определении типа сменный/не-сменный для объекта"
                        skip "Объект" v-obj-type v-obj-code
                        skip "Атрибут" 'shift-on=request':U
                        skip error-status :get-message(1)
                        skip return-value
                    view-as alert-box error .
                    undo, return error .
                end.
                if p-shift-on = ?
                then do:
                    assign
                        p-shift-on = v-shift-obj-on
                    .
                end.
                else do:
                    if p-shift-on <> v-shift-obj-on
                    then do:
                        assign
                            p-shift-on = ?
                        .
                        leave check-shift-on-all-obj.
                    end.
                end.
            end.
        end.
    end case.
end.
END PROCEDURE.
PROCEDURE init-fields :
    define variable v-today         as date         no-undo.
    define variable v-time          as integer      no-undo.
    define variable v-obj-counter   as integer      no-undo.
    define variable v-doc-type-list as character    no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run read-parameters in this-procedure (
          input v-today
        , input v-cntxt-host-code-obj
        , output date_from
        , output date_to
        , output fi-shift-num-from
        , output fi-shift-num-to
        , output rs-1
        , output p-host-code
        , output p-obj-list
        , output v-doc-type-list
        , output tb-inkass-pay-code
        , output tb-cst-code
        , output tb-parts
        , output tb-chk-pay-code
        , output tb-pay-desk
        , output tb-pay-desk-cards
        , output tb-deleted
        , output tb-exp-checks
        , output tb-exp-doc-rvs
    ).
    if p-init-doc-type-list = "":U
    then do:
        assign
            p-init-doc-type-list = v-doc-type-list
        .
    end.
    case rs-1
    :
        when 1
        then do:
            assign
                ed-object = "":U
            .
        end.
        when 2
        then do:
            assign
                ed-object = string( p-host-code )
            .
        end.
        when 3
        then do:
            assign
                ed-object = "":U
            .
            do
            v-obj-counter = 1 to num-entries( p-obj-list ) / 2
            :
                create temp_obj-list.
                assign
                    temp_obj-list.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
                    temp_obj-list.obj-code = integer( entry( v-obj-counter * 2    , p-obj-list ) )
                    ed-object              = substitute( "&1&2&3&4"
                                                , ed-object
                                                , ( if ed-object = "":U then "":U else ",":U )
                                                , temp_obj-list.obj-type
                                                , temp_obj-list.obj-code  )
                .
            end.
        end.
    end case.
    run get-host-name in this-procedure (
        output v-host-name
    ) no-error .
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
        view-as alert-box warning.
        assign
            v-host-name = 'орг':U + string( v-cntxt-host-code-obj )
        .
    end.
end.
END PROCEDURE.
PROCEDURE init-manage-fields :
    define variable v-shift-on    as logical      no-undo.
    define variable v-oper-num     as integer           no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    if p-output-type = 0
    or p-output-type = 2
    or p-output-type = 3
    or p-output-type = 5
    then do:
        disable ed-doc-type.
        hide
            bt-sel-doc-type
            tb-inkass-pay-code
            tb-cst-code
            tb-parts
            tb-chk-pay-code
            tb-pay-desk
            tb-pay-desk-cards
            tb-deleted
        .
        if p-output-type <> 3
        then do:
            hide
                RECT-1
                rs-1
                bt-sel-obj
                ed-object
            .
        end.
    end.
    if p-output-type = 2
    then do:
        view tb-supp in frame Dialog-Frame .
        enable tb-supp with frame Dialog-Frame .
    end.
    if p-output-type = 4
    or p-output-type = 5
    then do:
        hide
            tb-supp
            bt-sel-doc-type
            tb-inkass-pay-code
            tb-cst-code
            tb-parts
            tb-chk-pay-code
            tb-pay-desk
            tb-pay-desk-cards
            tb-deleted
            RECT-2
            ed-doc-type
            ed-doc-type-label
        .
        if p-output-type = 4
        then do:
            hide
                date_to
            .
        end.
        if p-output-type = 5
        then do:
            view
                RECT-1
                rs-1
                bt-sel-obj
                ed-object
            .
            assign
                frame Dialog-Frame :title = "Выбор объектов для экспорта"
            .
        end.
    end.
    run manage-tb-chk-pay-code in this-procedure.
    assign
        p-doc-type-list = p-init-doc-type-list
    .
    if p-init-doc-type-list <> ?
    and p-init-doc-type-list <> "":U
    then do:
        do v-oper-num = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
        :
            if lookup( entry( v-oper-num, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U ), p-init-doc-type-list ) <> 0
            then do:
                assign
                    ed-doc-type :screen-value in frame Dialog-Frame = ed-doc-type :screen-value in frame Dialog-Frame
                                                + entry( v-oper-num, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U ) + chr(10)
                .
            end.
        end.
    end.
    else do:
        assign
            ed-doc-type :screen-value = chr(10) + "    Все"
        .
    end.
    define variable v-obj-list    as character    no-undo.
    for each temp_obj-list
    :
        assign
            v-obj-list = substitute( "&1&2&3,&4"
                                        , v-obj-list
                                        , ( if v-obj-list = "":U then "":U else "," )
                                        , temp_obj-list.obj-type
                                        , temp_obj-list.obj-code
                                    )
        .
    end.
    run get-shift-on in this-procedure (
          input rs-1
        , input v-obj-list
        , output v-shift-on
    ).
    if v-shift-on = ?
    then do:
        message
                 "Неверно выбраны объекты. Все выбранные объекты"
            skip "должны быть либо сменными, либо не сменными."
        view-as alert-box information.
        hide
            fi-shift-num-from
            fi-shift-num-to
        .
    end.
    else do:
        if v-shift-on = yes
        then do:
            assign
                date_from :label = "Смена с"
            .
            view
                fi-shift-num-from
                fi-shift-num-to
            .
            display
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
        else do:
            assign
                date_from :label = "Дата с"
            .
            hide
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE manage-tb-chk-pay-code :
do
on error undo, return error
:
    if tb-chk-pay-code = yes
    then do:
        assign
            tb-pay-desk :sensitive in frame Dialog-Frame = yes
            tb-pay-desk-cards :sensitive in frame Dialog-Frame = yes
        .
    end.
    else do:
        assign
            tb-pay-desk :sensitive in frame Dialog-Frame = no
            tb-pay-desk-cards :sensitive in frame Dialog-Frame = no
        .
    end.
end.
END PROCEDURE.
PROCEDURE object-select :
    define variable v-shift-on    as logical      no-undo.
    define variable v-obj-list    as character    no-undo.
do
with frame Dialog-Frame
on error undo, return error
:
    case rs-1 :screen-value in frame Dialog-frame
    :
        when "1"
        then do:
            assign
                ed-object :screen-value = "":U
            .
        end.
        when "2"
        then do:
            assign
                ed-object :screen-value = v-host-name
            .
        end.
        when "3"
        then do:
            for each temp_obj-list
            :
                delete temp_obj-list.
            end.
            create temp_obj-list.
            assign
                temp_obj-list.obj-type = v-cntxt-obj-type
                temp_obj-list.obj-code = v-cntxt-obj-code
                ed-object :screen-value = substitute( "&1&2", v-cntxt-obj-type, v-cntxt-obj-code )
                v-obj-list = substitute( "&1,&2", v-cntxt-obj-type, v-cntxt-obj-code )
            .
        end.
    end case.
    run get-shift-on in this-procedure (
          input integer( rs-1 :screen-value )
        , input v-obj-list
        , output v-shift-on
    ).
    if v-shift-on = ?
    then do:
        message
                 "Неверно выбраны объекты. Все выбранные объекты"
            skip "должны быть либо сменными, либо не сменными."
        view-as alert-box information.
        hide
            fi-shift-num-from
            fi-shift-num-to
        .
    end.
    else do:
        if v-shift-on = yes
        then do:
            assign
                date_from :label = "Смена с"
            .
            view
                fi-shift-num-from
                fi-shift-num-to
            .
            display
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
        else do:
            assign
                date_from :label = "Дата с"
            .
            hide
                fi-shift-num-from
                fi-shift-num-to
            .
        end.
    end.
end.
END PROCEDURE.
PROCEDURE read-parameters :
define input parameter p-cur-date           as date             no-undo.
define input parameter p-default-host-code  as integer          no-undo.
define output parameter p-date-from         as date             no-undo.
define output parameter p-date-to           as date             no-undo.
define output parameter p-shift-num-from    as integer          no-undo.
define output parameter p-shift-num-to      as integer          no-undo.
define output parameter p-range             as integer          no-undo.
define output parameter p-host-code         as integer          no-undo.
define output parameter p-obj-list          as character        no-undo.
define output parameter p-doc-type-list     as character        no-undo.
define output parameter p-pay-code          as logical          no-undo.
define output parameter p-cst               as logical          no-undo.
define output parameter p-parts             as logical          no-undo.
define output parameter p-chk-pay-code      as logical          no-undo.
define output parameter p-pay-desk          as logical          no-undo.
define output parameter p-pay-desk-cards    as logical          no-undo.
define output parameter p-deleted           as logical          no-undo.
define output parameter p-chk               as logical          no-undo.
define output parameter p-doc-rvs           as logical          no-undo.
    define variable v-parameters-string as character    no-undo.
    define variable v-temp-date         as date         no-undo.
    define variable v-temp-integer      as integer      no-undo.
    define variable v-temp-logical      as logical      no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
do
for buf_usr-flt
on error undo, return error
:
    assign
        p-date-from         = p-cur-date
        p-date-to           = p-cur-date
        p-shift-num-from    = 1
        p-shift-num-to      = 1
        p-range             = 2
        p-host-code         = p-default-host-code
        p-pay-code          = no
        p-cst               = no
        p-parts             = no
        p-chk-pay-code      = no
        p-pay-desk          = no
        p-pay-desk-cards    = no
        p-deleted           = no
        p-chk               = no
        p-doc-rvs           = no
    .
    assign
        p-obj-list          = "":U
        p-doc-type-list     = "":U
    .
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-parameters":U
    no-error.
    if available buf_usr-flt
    then do:
        assign
            v-parameters-string = buf_usr-flt.Naim
        .
        run assign-date    in this-procedure ( input 1 , input v-parameters-string, input p-cur-date            , output p-date-from        ).
        run assign-date    in this-procedure ( input 2 , input v-parameters-string, input p-cur-date            , output p-date-to          ).
        run assign-integer in this-procedure ( input 3 , input v-parameters-string, input 1                     , output p-shift-num-from   ).
        run assign-integer in this-procedure ( input 4 , input v-parameters-string, input 1                     , output p-shift-num-to     ).
        run assign-integer in this-procedure ( input 5 , input v-parameters-string, input 2                     , output p-range            ).
        run assign-integer in this-procedure ( input 6 , input v-parameters-string, input p-default-host-code   , output p-host-code        ).
        run assign-logical in this-procedure ( input 7 , input v-parameters-string, input no                    , output p-pay-code         ).
        run assign-logical in this-procedure ( input 8 , input v-parameters-string, input no                    , output p-cst              ).
        run assign-logical in this-procedure ( input 9 , input v-parameters-string, input no                    , output p-parts            ).
        run assign-logical in this-procedure ( input 10, input v-parameters-string, input no                    , output p-chk-pay-code     ).
        run assign-logical in this-procedure ( input 11, input v-parameters-string, input no                    , output p-pay-desk         ).
        run assign-logical in this-procedure ( input 12, input v-parameters-string, input no                    , output p-pay-desk-cards   ).
        run assign-logical in this-procedure ( input 13, input v-parameters-string, input no                    , output p-deleted          ).
        run assign-logical in this-procedure ( input 14, input v-parameters-string, input no                    , output p-chk              ).
        run assign-logical in this-procedure ( input 15, input v-parameters-string, input no                    , output p-doc-rvs          ).
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-obj-list":U
    no-error.
    if available buf_usr-flt
    then do:
        assign
            p-obj-list = buf_usr-flt.Naim
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-doc-type-list":U
    no-error.
    if available buf_usr-flt
    then do:
        assign
            p-doc-type-list = buf_usr-flt.Naim
        .
    end.
end.
END PROCEDURE.
PROCEDURE write-parameters :
define input parameter p-date-from         as date             no-undo.
define input parameter p-date-to           as date             no-undo.
define input parameter p-shift-num-from    as integer          no-undo.
define input parameter p-shift-num-to      as integer          no-undo.
define input parameter p-range             as integer          no-undo.
define input parameter p-host-code         as integer          no-undo.
define input parameter p-obj-list          as character        no-undo.
define input parameter p-doc-type-list     as character        no-undo.
define input parameter p-pay-code          as logical          no-undo.
define input parameter p-cst               as logical          no-undo.
define input parameter p-parts             as logical          no-undo.
define input parameter p-chk-pay-code      as logical          no-undo.
define input parameter p-pay-desk          as logical          no-undo.
define input parameter p-pay-desk-cards    as logical          no-undo.
define input parameter p-deleted           as logical          no-undo.
define input parameter p-chk               as logical          no-undo.
define input parameter p-doc-rvs           as logical          no-undo.
    define variable v-parameters-string as character    no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.
do
for buf_usr-flt
on error undo, return error
:
    assign
        v-parameters-string = substitute( "&1,&2,&3,&4,&5,&6,&7,&8"
                                        , p-date-from
                                        , p-date-to
                                        , p-shift-num-from
                                        , p-shift-num-to
                                        , p-range
                                        , p-host-code
                                        , p-pay-code
                                        , p-cst )
    .
    assign
        v-parameters-string = substitute( "&1,&2,&3,&4,&5,&6,&7,&8"
                                        , v-parameters-string
                                        , p-parts
                                        , p-chk-pay-code
                                        , p-pay-desk
                                        , p-pay-desk-cards
                                        , p-deleted
                                        , p-chk
                                        , p-doc-rvs     )
    .
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-parameters":U
    no-error.
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name  = v-cntxt-userid
            buf_usr-flt.call-point = "bge-input-dialog-parameters":U
        .
    end.
    assign
        buf_usr-flt.Naim = v-parameters-string
    .
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-obj-list":U
    no-error.
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name  = v-cntxt-userid
            buf_usr-flt.call-point = "bge-input-dialog-obj-list":U
        .
    end.
    assign
        buf_usr-flt.Naim = p-obj-list
    .
    find first buf_usr-flt exclusive-lock
         where buf_usr-flt.user-name  = v-cntxt-userid
           and buf_usr-flt.call-point = "bge-input-dialog-doc-type-list":U
    no-error.
    if not available buf_usr-flt
    then do:
        create buf_usr-flt.
        assign
            buf_usr-flt.user-name  = v-cntxt-userid
            buf_usr-flt.call-point = "bge-input-dialog-doc-type-list":U
        .
    end.
    assign
        buf_usr-flt.Naim = p-doc-type-list
    .
end.
END PROCEDURE.
