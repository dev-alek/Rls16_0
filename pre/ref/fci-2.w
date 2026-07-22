DEFINE BUFFER buf_fin-code FOR ub.fin-code-cel-nazn.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Корректировка справочника в ФИНБлоке цел.назн    ".
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
define input parameter        ref-mode as character no-undo .
define input-output parameter ri       as recid no-undo.
define input parameter par-host-code as integer no-undo .
define variable tcode as character no-undo .
define variable p-fin-code as integer no-undo .
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
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Уровни для сбора аналитики"
      VIEW-AS TEXT
     SIZE 27.2 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 68.8 BY 2.52.
DEFINE QUERY Dialog-Frame FOR
      fin-code-cel-nazn,
      buf_fin-code SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 62.2
     fin-code-cel-nazn.code-value AT ROW 2.43 COL 7 COLON-ALIGNED
          LABEL "Код"
          VIEW-AS FILL-IN
          SIZE 13 BY 1 TOOLTIP "Код спрпавочника"
     fin-code-cel-nazn.descr AT ROW 5.29 COL 1 NO-LABEL
          VIEW-AS FILL-IN
          SIZE 69.8 BY 1
     fin-code-cel-nazn.level-1 AT ROW 7.76 COL 11.2 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     fin-code-cel-nazn.level-2 AT ROW 7.76 COL 35.6 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     fin-code-cel-nazn.level-3 AT ROW 7.76 COL 59 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 4 BY 1
     FILL-IN-1 AT ROW 6.71 COL 20.6 COLON-ALIGNED NO-LABEL
     "Наименование" VIEW-AS TEXT
          SIZE 16 BY .62 AT ROW 4.33 COL 1 WIDGET-ID 2
     RECT-1 AT ROW 6.81 COL 1
     SPACE(2.45) SKIP(0.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Корректировка справочника"
         CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  def var rr as recid no-undo.
  if input ub.fin-code-cel-nazn.code-value = "" then do:
      message "Код  не может быть не задан" view-as alert-box.
      apply "ENTRY":U to ub.fin-code-cel-nazn.code-value.
      return no-apply.
  end.
  if  input ub.fin-code-cel-nazn.descr = ""  then do:
      message "Введите наименование " view-as alert-box WARNING.
      apply "ENTRY":U to ub.fin-code-cel-nazn.descr.
      return no-apply.
  end.
  rr = recid( ub.fin-code-cel-nazn ).
  if ref-mode =  'ДОБАВЛЕНИЕ':U then do:
    if can-find(first ub.fin-code-cel-nazn where ub.fin-code-cel-nazn.code-value = input ub.fin-code-cel-nazn.code-value
                                       AND recid( ub.fin-code-cel-nazn ) <> rr
                                       and ub.fin-code-cel-nazn.host-code = par-host-code
                                         ) then do:
        message "Запись с кодом" input ub.fin-code-cel-nazn.code-value "уже существует!" skip
              "Если ее нет в списке, то она логически удалена."
              view-as alert-box warning.
        apply "ENTRY":U to ub.fin-code-cel-nazn.code-value.
        return no-apply.
    end.
  end.
    if ref-mode <> 'ПРОСМОТР':U then
  assign ub.fin-code-cel-nazn.code-value
         ub.fin-code-cel-nazn.descr
         ub.fin-code-cel-nazn.level-1
         ub.fin-code-cel-nazn.level-2
         ub.fin-code-cel-nazn.level-3
         ri = recid( ub.fin-code-cel-nazn )
  .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
apply "CHOOSE" to b-quit IN FRAME Dialog-Frame .
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
    ri = ? .
  if ref-mode =  'ДОБАВЛЕНИЕ':U then do:
      find current ub.fin-code-cel-nazn  exclusive-lock   no-error.
      if available ub.fin-code-cel-nazn then do:
         delete ub.fin-code-cel-nazn.
      end.
  end.
END.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define buffer buf_file for ub.fin-code-cel-nazn .
procedure current-db :
 do
 on error undo, return error return-value
 :
define input parameter  p-host-code as integer no-undo .
define input parameter  c-host-code as integer no-undo .
define output parameter ret         as logical no-undo .
define buffer current_sysconf for ub.sysconf.
define variable v-current-db as integer no-undo .
find first current_sysconf where current_sysconf.host-code = c-host-code no-lock no-error .
if error-status :error then return error .
   v-current-db = current_sysconf.firm-db-num .
   ret = true .
find first ub.sysconf where ub.sysconf.host-code = p-host-code no-lock no-error .
if not( ub.sysconf.firm-db-num = v-current-db or
        ub.sysconf.firm-db-num = 0 )
  then do:
  ret = false .
  message "Нельзя добавлять запись в  справочнике  для фирмы с не главной БД !!!" view-as alert-box information .
  return .
end.
 end.
end procedure.
procedure ver-db :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter  c-host-code as integer no-undo .
define input parameter  par-ver-db  as integer no-undo .
define input parameter  p-mess as logical no-undo .
define output parameter ret         as logical no-undo .
define buffer current_sysconf for ub.sysconf.
define variable v-current-db as integer no-undo .
find first current_sysconf where current_sysconf.host-code = c-host-code no-lock no-error .
if error-status :error then return error .
   v-current-db = current_sysconf.firm-db-num .
   ret = true .
if not( par-ver-db = v-current-db or
        par-ver-db = 0 )
  then do:
  ret = false .
  if p-mess = true then message "База , на которой мы работаем не является главной базой данных текущей фирмы!!!" view-as alert-box information .
  return .
end.
 end.
end procedure.
procedure fin-code :
 do
 on error undo, return error return-value
 :
  define input  parameter p-host-code as integer no-undo .
  define output parameter p-fin-code  as integer no-undo .
  p-fin-code = next-value(s-fin-code, ub) .
 end.
end procedure.
procedure create-ref-fin-code :
 do
 on error undo, return error return-value
 :
define input parameter p-ver as logical no-undo .
define input parameter p-host-code  as integer   no-undo .
define input parameter p-fin-code   as integer   no-undo .
define input parameter p-code-value as character no-undo .
define input parameter p-descr      as character no-undo .
define input parameter p-status_    as integer   no-undo .
define input parameter p-level-1    as integer   no-undo .
define input parameter p-level-2    as integer   no-undo .
define input parameter p-level-3    as integer   no-undo .
if p-ver then do:
    find first  buf_file no-lock  where buf_file.host-code = p-host-code and
                                        buf_file.fin-code  = p-fin-code no-error .
    if available buf_file then return error .
end.
define variable p-ret as logical no-undo .
run current-db in this-procedure (
    input p-host-code,
    input p-host-code,
    output p-ret ) .
 if p-ret = no then return.
 create ub.fin-code-cel-nazn.
 assign
   ub.fin-code-cel-nazn.host-code  = p-host-code
   ub.fin-code-cel-nazn.fin-code   = p-fin-code
   ub.fin-code-cel-nazn.code-value = p-code-value
   ub.fin-code-cel-nazn.descr      = p-descr
   ub.fin-code-cel-nazn.status_    = p-status_
   ub.fin-code-cel-nazn.level-1    = p-level-1
   ub.fin-code-cel-nazn.level-2    = p-level-2
   ub.fin-code-cel-nazn.level-3    = p-level-3
  no-error .
  if error-status :error then do:
      message vss-include-info1 skip
              error-status :get-message(1)
              view-as alert-box error .
      return error .
  end.
 end.
end procedure.
procedure create-ref-corr-acc :
 do
 on error undo, return error return-value
 :
define input parameter p-ver as logical no-undo .
define input parameter p-host-code  as integer   no-undo .
define input parameter p-fin-code   as integer   no-undo .
define input parameter p-code-value as character no-undo .
define input parameter p-descr      as character no-undo .
define input parameter p-status_    as integer   no-undo .
define input parameter p-level-1    as integer   no-undo .
define input parameter p-level-2    as integer   no-undo .
define input parameter p-level-3    as integer   no-undo .
define input parameter p-acc-type    as integer   no-undo .
define buffer buf_file  for ub.fin-code-cor-acc .
if p-ver then do:
    find first  buf_file no-lock  where buf_file.host-code = p-host-code and
                                        buf_file.fin-code  = p-fin-code no-error .
    if available buf_file then return error .
end.
define variable p-ret as logical no-undo .
run current-db in this-procedure (
    input p-host-code,
    input p-host-code,
    output p-ret ) .
 if p-ret = no then return.
 create ub.fin-code-cor-acc.
 assign
   ub.fin-code-cor-acc.host-code  = p-host-code
   ub.fin-code-cor-acc.fin-code   = p-fin-code
   ub.fin-code-cor-acc.code-value = p-code-value
   ub.fin-code-cor-acc.descr      = p-descr
   ub.fin-code-cor-acc.status_    = p-status_
   ub.fin-code-cor-acc.level-1    = p-level-1
   ub.fin-code-cor-acc.level-2    = p-level-2
   ub.fin-code-cor-acc.level-3    = p-level-3
   ub.fin-code-cor-acc.acc-type   = p-acc-type
  no-error .
  if error-status :error then do:
      message vss-include-info1 skip
              error-status :get-message(1)
              view-as alert-box error .
      return error .
  end.
 end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    if ref-mode =  'ДОБАВЛЕНИЕ':U
        then  do:
            ri = ?.
            run fin-code in this-procedure (input par-host-code , output p-fin-code) .
            tcode = string(p-fin-code) .
            run create-ref-fin-code in this-procedure (
                input no ,
                input par-host-code ,
                input p-fin-code    ,
                input tcode ,
                input ""    ,
                input 0 ,
                input 0 ,
                input 0 ,
                input 0 ).
        end.
        else  do:
         find ub.fin-code-cel-nazn where recid( ub.fin-code-cel-nazn ) = ri no-error .
         if error-status :error then return  error .
         end.
frame Dialog-Frame:title = frame Dialog-Frame:title + "  - " + caps(ref-mode).
b-quit:label = (if  ref-mode = 'ПРОСМОТР':U then "&Выход" else b-quit:label ).
    session:data-entry-return = yes .
     if ref-mode = 'ПРОСМОТР':U then do:
        run myenable_UI in this-procedure.
        WAIT-FOR GO OF FRAME Dialog-Frame FOCUS b-quit.
     end.
     else do:
    run enable_UI in this-procedure.
    if ref-mode = 'ДОБАВЛЕНИЕ':U
        then  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS ub.fin-code-cel-nazn.code-value .
        else  WAIT-FOR GO OF FRAME Dialog-Frame FOCUS ub.fin-code-cel-nazn.descr .
    end.
END.
run disable_UI in this-procedure.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-IN-1
      WITH FRAME Dialog-Frame.
  IF AVAILABLE fin-code-cel-nazn THEN
    DISPLAY fin-code-cel-nazn.code-value fin-code-cel-nazn.descr
          fin-code-cel-nazn.level-1 fin-code-cel-nazn.level-2
          fin-code-cel-nazn.level-3
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-help RECT-1 fin-code-cel-nazn.code-value
         fin-code-cel-nazn.descr fin-code-cel-nazn.level-1
         fin-code-cel-nazn.level-2 fin-code-cel-nazn.level-3 FILL-IN-1
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE myenable_UI :
  IF AVAILABLE ub.fin-code-cel-nazn THEN
    DISPLAY ub.fin-code-cel-nazn.code-value ub.fin-code-cel-nazn.descr FILL-IN-1
          ub.fin-code-cel-nazn.level-1 ub.fin-code-cel-nazn.level-2
          ub.fin-code-cel-nazn.level-3
      WITH FRAME Dialog-Frame.
     enable b-quit b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
