block-level on error undo, throw.
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
DEFINE temp-table tt-obj no-undo
    field   obj-code    as integer
    field   obj-type    as character
    field   obj-name    as character
    field   host-code   as integer
    INDEX   pi          IS PRIMARY UNIQUE
            obj-type
            obj-code
  .
define input parameter p-date          as date             no-undo.
define input parameter p-ftp-address   as character        no-undo.
define input parameter p-ftp-path      as character        no-undo.
define input parameter p-ftp-target-dir as character        no-undo.
define input parameter p-login         as character        no-undo.
define input parameter p-password      as character        no-undo.
define input parameter p-name          as character        no-undo.
define input parameter p-log-handle    as handle no-undo .
define input parameter table   FOR tt-obj.
define variable vss-revision    as character no-undo init "$Revision: 20b73597f255, 21, test $":U .
define variable vss-author      as character no-undo init "$Author: SKiryxin $":U .
define variable vss-date        as character no-undo init "$Date: Wed Mar 05 15:13:08 2014 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-exp-sl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-exp-sl.p $":U .
define variable vss-description as character no-undo init "Отчет для Nielsen запуск из интерфейса".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable g#auto-pid           as integer   no-undo .
define  shared variable conn-par             as character no-undo .
define  shared variable g#auto-user-id       as character no-undo .
define  shared variable g#auto-user-login    as character no-undo .
define  shared variable g#auto-user-password as character no-undo .
define  shared variable v-socket             as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable auto-window-h     as handle    no-undo .
define  shared variable auto-log-msg-h    as handle    no-undo .
define  shared variable hand-log-msg-h    as handle    no-undo .
define  shared variable log-file-name     as character no-undo initial ? .
define  shared variable add-log-file-name as character no-undo initial ? .
define  shared variable writelogvalue     as character no-undo initial ? .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define stream LogStream .
define variable mNoTime as logical no-undo.
procedure write-to-log-notime :
  define input param i-str as character no-undo .
  mNoTime = yes.
  run write-to-log (i-str).
  mNoTime = no.
end.
procedure write-to-log :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-log). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-log). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-log). endkey", vss-workfile )
  :
    define variable log-res        as logical   no-undo .
    define variable v-jj           as integer   no-undo .
    if    mNoTime
       or writelogvalue eq "AsyncProc"
    then
       p-str = substitute( "&1 (pid: &2) &3&4"   , g#auto-user-id, g#auto-pid,                        p-str, chr(10) ).
    else
       p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) ).
    if auto-log-msg-h <> ? then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ? then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
    assign
      p-str = replace(p-str, (chr(10) + chr(13)), chr(10) )
      p-str = replace(p-str, (chr(13) + chr(10)), chr(10) )
      p-str = replace(p-str, chr(10), (chr(13) + chr(10)) )
    .
    if add-log-file-name <> ? then do:
      do v-jj = 1 to num-entries(add-log-file-name, chr(1)):
        run gbl/fileapnd.p
          ( input entry(v-jj, add-log-file-name, chr(1) )
          ,input p-str
          ,input 20
          ) no-error .
        if error-status:error then do:
          return error return-value .
        end.
      end.
    end.
    if writelogvalue eq "AsyncProc"
    then do:
       p-str = trim(p-str, (chr(13) + chr(10)) )
    .
       Publish "WriteLogAsunc" (p-str,yes).
    end.
    else if writelogvalue <> "yes" then do:
      run gbl/fileapnd.p
        ( input log-file-name
        ,input p-str
        ,input 20
        ) no-error .
      if error-status:error then do:
        return error return-value .
      end.
    end.
  end.
end procedure.
procedure write-to-screen :
  define input param p-str as character no-undo .
  do
  on error  undo, return error substitute( "&1 (write-to-screen). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (write-to-screen). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (write-to-screen). endkey", vss-workfile )
  :
    define variable log-res as logical no-undo.
    assign
      p-str = substitute( "&1 (pid: &2) &3 &4&5", g#auto-user-id, g#auto-pid, cur-time-string-sec(), p-str, chr(10) )
    .
    if auto-log-msg-h <> ?
    then do:
      log-res = auto-log-msg-h:move-to-eof( ) .
      log-res = auto-log-msg-h:insert-string( p-str ).
    end.
    if hand-log-msg-h <> ?
    then do:
      log-res = hand-log-msg-h:move-to-eof( ) .
      log-res = hand-log-msg-h:insert-string( p-str ).
    end.
  end.
end procedure.
procedure send-msg-to-email :
  define input  parameter p-subject      as character no-undo .
  define input  parameter p-text-err     as character no-undo .
  define input  parameter p-attach-files as character no-undo .
  do
  on error  undo, return error substitute( "&1 (send-msg-to-email). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (send-msg-to-email). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (send-msg-to-email). endkey", vss-workfile )
  :
    define variable v-tth             as handle    no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    define variable v-param-type      as character no-undo .
    define variable v-email       as character no-undo .
    define variable v-tmp-str     as character no-undo .
    define variable v-tmp1-str    as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    delete object v-tth no-error.
    run adm/shattri.p
      ( input "get":U
       ,input  "":U
       ,input  0
       ,input  'auto-task':U
       ,input  'send-msg-to-email':U
       ,output v-value-character
       ,output v-value-date
       ,output v-value-decimal
       ,output v-value-integer
       ,output v-value-logical
       ,output v-param-type
       ,input-output table-handle v-tth
      ) no-error .
    if not error-status :error  then do:
      assign
        v-tmp-str = v-value-character
      .
    end.
    delete object v-tth no-error.
    assign
      v-tmp-str     = replace(v-tmp-str, (chr(10) + chr(13)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, (chr(13) + chr(10)), chr(44) )
      v-tmp-str     = replace(v-tmp-str, chr(10), chr(44) )
      v-num-entries = num-entries( v-tmp-str, chr(44) )
      v-email       = "":U
    .
    do v-ind = 1 to v-num-entries
    :
      assign
        v-tmp1-str = entry( v-ind, v-tmp-str, chr(44) )
      .
      if trim( v-tmp1-str ) <> "":U then do:
        if v-email = "":U then do:
          assign
            v-email = v-tmp1-str
          .
        end.
        else do:
          assign
            v-email = v-email + chr(44) + v-tmp1-str
          .
        end.
      end.
    end.
    if v-email <> "":U then do:
      run gbl/sendmail.p
        ( input v-email
        , input p-subject
        , input p-text-err
        , input p-attach-files
        ) no-error .
      if error-status :error
        or return-value <> "":U
      then do:
        return error substitute( "&1 (send-msg-to-email). &2", vss-workfile, return-value ) .
      end.
    end.
  end.
end procedure.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE InternetConnectA EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  hInternetSession  as  long.
  define input parameter  lpszServerName    as  char.
  define input parameter  nServerPort       as  long.
  define input parameter  lpszUserName      as  char.
  define input parameter  lpszPassword      as  char.
  define input parameter  dwService         as  long.
  define input parameter  dwFlags           as  long.
  define input parameter  dwContext         as  long.
  define return parameter hInternetConnect  as  long.
END.
PROCEDURE InternetGetLastResponseInfoA EXTERNAL "wininet.dll" PERSISTENT:
  define output parameter lpdwError          as  long.
  define output parameter lpszBuffer         as  char.
  define input-output  parameter lpdwBufferLength   as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE InternetOpenUrlA EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  hInternetSession  as  long.
  define input parameter  lpszUrl           as  char.
  define input parameter  lpszHeaders       as  char.
  define input parameter  dwHeadersLength   as  long.
  define input parameter  dwFlags           as  long.
  define input parameter  dwContext         as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE InternetOpenA EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  sAgent            as  char.
  define input parameter  lAccessType       as  long.
  define input parameter  sProxyName        as  char.
  define input parameter  sProxyBypass      as  char.
  define input parameter  lFlags            as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE InternetReadFile EXTERNAL "wininet.dll" PERSISTENT:
  define input  parameter  hFile            as  long.
  define output parameter  sBuffer          as  char.
  define input  parameter  lNumBytesToRead  as  long.
  define output parameter  lNumOfBytesRead  as  long.
  define return parameter  iResultCode      as  long.
END.
PROCEDURE InternetCloseHandle EXTERNAL "wininet.dll" PERSISTENT:
  define input parameter  hInet             as  long.
  define return parameter iResultCode       as  long.
END.
PROCEDURE FtpFindFirstFileA EXTERNAL "wininet.dll" PERSISTENT :
    define input parameter  hFtpSession as  long.
    define input parameter  lpFileName as char.
    define input parameter  lpFindFileData as memptr.
    define input parameter  dwFlags        as long.
    define input parameter  dwContext      as long.
    define return parameter hSearch as long.
END PROCEDURE.
PROCEDURE InternetFindNextFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hSearch as long.
    define input parameter  lpFindFileData as memptr.
    define return parameter found as long.
END PROCEDURE.
PROCEDURE FtpGetCurrentDirectoryA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession as long.
    define input parameter  lpszCurrentDirectory as long.
    define input-output parameter lpdwCurrentDirectory as long.
    define return parameter iRetCode as long.
END PROCEDURE.
PROCEDURE FtpSetCurrentDirectoryA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession as long.
    define input parameter  lpszDirectory as long.
    define return parameter iRetCode as long.
END PROCEDURE.
PROCEDURE FtpOpenFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession  as long.
    define input parameter  lpszFileName as long.
    define input parameter  dwAccess     as long.
    define input parameter  dwFlags      as long.
    define input parameter  dwContext    as long.
    define return parameter iRetCode as long.
END PROCEDURE.
PROCEDURE FtpPutFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession       as long.
    define input parameter  lpszLocalFile     as long.
    define input parameter  lpszNewRemoteFile as long.
    define input parameter  dwFlags           as long.
    define input parameter  dwContext         as long.
    define return parameter iRetCode          as long.
END PROCEDURE.
PROCEDURE FtpGetFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession          as long.
    define input parameter  lpszRemoteFile       as long.
    define input parameter  lpszNewFile          as long.
    define input parameter  fFailIfExists        as long.
    define input parameter  dwFlagsAndAttributes as long.
    define input parameter  dwFlags              as long.
    define input parameter  dwContext            as long.
    define return parameter iRetCode             as long.
END PROCEDURE.
PROCEDURE FtpDeleteFileA EXTERNAL "wininet.dll" PERSISTENT:
    define input parameter  hFtpSession          as long.
    define input parameter  lpszRemoteFile       as long.
    define return parameter iRetCode             as long.
END PROCEDURE.
PROCEDURE GetLastError external "kernel32.dll" :
  define return parameter dwMessageID as long.
END PROCEDURE.
DEFINE temp-table tt-line no-undo
    field   obj-code    as integer
    field   obj-type    as character
    field   grp-name    as character
    field   grp-code    as integer
    field   prod-name   as character
    field   b-code      as integer
    field   src-code    as character
    field   gds-name    as character
    field   gds-code    as integer
    field   qnty        as decimal
    field   summ        as decimal
    INDEX   pi          IS PRIMARY UNIQUE
            obj-code
            obj-type
            src-code
            b-code.
define stream out-stream.
define stream lst-out.
define stream StreamLog.
define buffer buf_tt-line        for tt-line .
define buffer buf_chk-doc  for ub.chk-doc.
define buffer buf_chk-gds  for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods          for ub.goods .
define buffer buf_producer for ub.clients.
define buffer buf_prod-bc        for ub.prod-bc .
do
on error undo, return error
:
   define variable v-begin-date        as date        no-undo .
   define variable v-end-date          as date        no-undo .
   define variable v-begin-date0       as date        no-undo .
   define variable v-end-date0         as date        no-undo .
   define variable v-par-val           as character   no-undo .
   define variable v-par-type          as character   no-undo .
   define variable v-file-name         as character   no-undo .
   define variable v-file-name-mapping as character   no-undo .
   define variable v-file-name-mapping-new as character   no-undo .
   define variable v-fmt               as character   no-undo .
   define variable v-weekday-today     as integer     no-undo .
   define variable v-b-code            as integer     no-undo .
   define variable v-bar               as character   no-undo .
   define variable v-prod-name         as character   no-undo .
   define variable v-gds-code          as integer     no-undo .
   define variable v-fact-order-start  as decimal     no-undo .
   define variable v-fact-order-end    as decimal     no-undo .
   define variable v-empty-1           as decimal     no-undo .
   define variable v-empty-2           as decimal     no-undo .
   define variable v-gds-name          as character   no-undo .
   define variable v-grp-code          as integer     no-undo .
   define variable v-counter           as integer     no-undo .
   define variable v-label             as character   no-undo .
   define variable v-archive-ok as logical      no-undo.
   define variable v-can-print  as logical      no-undo.
   define variable v-comment    as character    no-undo.
   define variable v-grp-name as character no-undo.
   define frame info
      v-label        label "Этап" format "x(16)" skip
      v-counter      label "Записей" format ">>>,>>>,>>9" skip
      with view-as dialog-box side-labels 1 columns three-d title "Формирование отчета"
   .
   assign
      log-file-name = "Rep_Nielsen.log"
   .
   IF p-date = ?
   THEN DO:
      assign
         v-weekday-today = WEEKDAY(TODAY)
         v-begin-date    = TODAY - v-weekday-today - 5
         v-end-date      = TODAY - v-weekday-today + 1
         v-begin-date0   = v-begin-date
         v-end-date0     = v-end-date
      .
   END.
   ELSE DO:
      assign
         v-weekday-today = WEEKDAY(p-date)
         v-begin-date    = p-date - v-weekday-today - 5
         v-end-date      = p-date - v-weekday-today + 1
         v-end-date0     = v-end-date
         v-begin-date0    = v-begin-date
      .
   END.
   v-file-name-mapping = "mapping".
   output stream out-stream to value(v-file-name-mapping + ".txt") .
   put stream out-stream unformatted
   "Gds-Code"   chr(9)
   "Bar-Code" chr(9)
   "Qnty" chr(10).
    run write-log-and-file in p-log-handle (           input 1                                                               , input log-file-name                                                   , input 1                                                               , input substitute("Создание mapping файла.")).
   for each buf_goods where buf_goods.stts = 0 no-lock:
       for each buf_bar-code where buf_bar-code.gds-code = buf_goods.gds-code
                               and buf_bar-code.part-code = ""
                               and buf_bar-code.in-code = "" no-lock:
           if buf_bar-code.stts_ <> 0 then next.
           for each buf_prod-bc where buf_prod-bc.b-code = buf_bar-code.b-code
                                  and buf_prod-bc.b-str NE string(buf_bar-code.b-code)
                                  and buf_prod-bc.bc-on = yes no-lock:
           put stream out-stream unformatted
                buf_bar-code.gds-code chr(9)
                buf_goods.qnty-cart chr(9)
                buf_prod-bc.b-str chr(10).
           end.
           if buf_bar-code.b-code = buf_bar-code.gds-code then next.
                put stream out-stream unformatted
                    buf_bar-code.gds-code chr(9)
                buf_goods.qnty-cart chr(9)
                    buf_bar-code.b-code     chr(10).
       end.
   end.
      run write-log-and-file in p-log-handle (           input 1                                                               , input log-file-name                                                   , input 1                                                               , input substitute("Mapping файл создан успешно.")).
   output stream out-stream close.
   tt-obj_arh_loop:
   FOR EACH tt-obj exclusive-lock
       BREAK by tt-obj.host-code
   :
            run write-log-and-file in p-log-handle (           input 1                                                               , input log-file-name                                                   , input 1                                                               , input SUBSTITUTE("Проверка и расчет архивов по объекту: &1 &2.", tt-obj.obj-type, tt-obj.obj-code)).
      assign
      v-begin-date = v-begin-date0
      v-end-date   = v-end-date0
      .
      run rep/chk-ahz.p (
         input        tt-obj.obj-type
         , input        tt-obj.obj-code
         , input        yes
         , input        yes
         , input        no
         , input        no
         , input        no
         , input        0
         , input        "":U
         , input-output v-begin-date
         , input-output v-end-date
         , output       v-archive-ok
         , output       v-comment
         , output       v-can-print
      ) no-error .
      if error-status :error
      or v-can-print  = false
      or (v-can-print  = true
      and (v-begin-date = ?
      or v-end-date = ?
      or v-end-date < v-end-date0
      ))
      then do:
                  run write-log-and-file in p-log-handle (           input 1                                                               , input log-file-name                                                   , input 1                                                               , input v-comment).
        error-status :error = no.
        delete tt-obj.
        next tt-obj_arh_loop.
      end.
   END.
   for each tt-obj no-lock
   BREAK by tt-obj.host-code
   :
      IF FIRST-OF (tt-obj.host-code)
      THEN DO:
            ASSIGN
               v-file-name =  p-name
                           + STRING(tt-obj.host-code, "99999")
                           + "_"
                           + SUBSTRING(STRING(YEAR(v-begin-date), "9999"),3,2)
                           + STRING(MONTH(v-begin-date), "99")
                           + STRING(DAY(v-begin-date), "99")
                           + SUBSTRING(STRING(YEAR(v-end-date), "9999"),3,2)
                           + STRING(MONTH(v-end-date), "99")
                           + STRING(DAY(v-end-date), "99")
            v-file-name-mapping-new = p-name
                       + string(tt-obj.host-code, "99999")
                       + "_mapping_"
                       + substring(string(year(v-begin-date), "9999"),3,2)
                       + string(month(v-begin-date), "99")
                       + string(day(v-begin-date), "99")
                       + substring(string(year(v-end-date), "9999"),3,2)
                       + string(month(v-end-date), "99")
                       + string(day(v-end-date), "99").
      END.
            run write-log-and-file in p-log-handle (           input 1                                                               , input log-file-name                                                   , input 1                                                               , input substitute("Выгрузка объект: &1 &2", tt-obj.obj-type, tt-obj.obj-code)).
           os-rename value(v-file-name-mapping + ".txt":U) value(v-file-name-mapping-new + ".txt":U).
           v-file-name-mapping = v-file-name-mapping-new.
      for each buf_chk-doc no-lock
        where buf_chk-doc.obj-type = tt-obj.obj-type
          and buf_chk-doc.obj-code = tt-obj.obj-code
          and buf_chk-doc.chk-date <= v-end-date
          and buf_chk-doc.chk-date >= v-begin-date
          and lookup(string(buf_chk-doc.chk-type), '1,69,14,15,16,36':U + '6,96':U) > 0:
         for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code:
             find first  buf_tt-line
                   where buf_tt-line.obj-code = buf_chk-doc.obj-code
                   and   buf_tt-line.obj-type = buf_chk-doc.obj-type
                   and   buf_tt-line.src-code = buf_chk-gds.src-code
                   and   buf_tt-line.b-code   = buf_chk-gds.b-code no-error.
             if not available buf_tt-line then do:
            CREATE buf_tt-line.
            ASSIGN
                   buf_tt-line.obj-code  = buf_chk-doc.obj-code
                   buf_tt-line.obj-type  = buf_chk-doc.obj-type
                   buf_tt-line.src-code  = buf_chk-gds.src-code
                   buf_tt-line.b-code    = buf_chk-gds.b-code
                   buf_tt-line.summ      = (if (lookup(string(buf_chk-doc.chk-type), '1,69,14,15,16,36':U) > 0) then buf_chk-gds.sum-base else buf_chk-gds.sum-base * (-1))
                   buf_tt-line.qnty      = (if (lookup(string(buf_chk-doc.chk-type), '1,69,14,15,16,36':U) > 0) then buf_chk-gds.doc-qnty else buf_chk-gds.doc-qnty * (-1)).
             end.
             else do:
            assign
                   buf_tt-line.summ = buf_tt-line.summ + (if (lookup(string(buf_chk-doc.chk-type), '1,69,14,15,16,36':U) > 0) then buf_chk-gds.sum-base else buf_chk-gds.sum-base * (-1))
                   buf_tt-line.qnty = buf_tt-line.qnty + (if (lookup(string(buf_chk-doc.chk-type), '1,69,14,15,16,36':U) > 0) then buf_chk-gds.doc-qnty else buf_chk-gds.doc-qnty * (-1)).
             end.
         end.
     end.
      if last-of (tt-obj.host-code) then do:
         output stream out-stream TO VALUE(v-file-name + ".txt") .
            put stream out-stream unformatted
               "ShopCode"     chr(9)
               "GrpName"      chr(9)
               "GrpCode"      chr(9)
               "Manufacture"  chr(9)
               "Src-Code"     chr(9)
               "Code"         chr(9)
               "ProductName"  chr(9)
               "SalesValue"   chr(9)
               "SalesItem"    chr(10).
         for each buf_tt-line break by buf_tt-line.b-code:
            if first-of (buf_tt-line.b-code) then do:
                find first buf_bar-code where buf_bar-code.b-code = buf_tt-line.b-code no-lock no-error.
                find first buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock no-error.
                find first buf_producer where buf_producer.obj-type = buf_goods.prod-type
                                          and buf_producer.obj-code = buf_goods.prod-code no-lock no-error.
               ASSIGN
                v-grp-name = buf_goods.grp-name
                v-grp-code = buf_goods.grp-code
                v-gds-name = buf_goods.gds-name
                v-prod-name = buf_producer.obj-name
                v-gds-code = buf_goods.gds-code no-error.
            end.
            assign
            buf_tt-line.grp-name  = v-grp-name
            buf_tt-line.grp-code  = v-grp-code
            buf_tt-line.gds-name  = v-gds-name
            buf_tt-line.prod-name = v-prod-name
            buf_tt-line.gds-code  = v-gds-code no-error.
            put stream out-stream unformatted
               buf_tt-line.obj-code  chr(9)
               trim(buf_tt-line.grp-name) chr(9)
               buf_tt-line.grp-code  chr(9)
               trim(buf_tt-line.prod-name) chr(9)
               buf_tt-line.gds-code chr(9)
               trim(buf_tt-line.src-code) chr(9)
               trim(buf_tt-line.gds-name) chr(9)
               trim(string(buf_tt-line.summ,"->>>>>>9.99")) chr(9)
               trim(string(buf_tt-line.qnty,"->>>>>>9.999")) chr(10).
         END.
         output stream out-stream close.
         run pack-file in this-procedure (input v-file-name, input v-file-name-mapping-new) no-error.
         if error-status:error
         then do:
                        run write-log-and-file in p-log-handle (           input 1                                                               , input log-file-name                                                   , input 1                                                               , input SUBSTITUTE("Ошибка упаковки:&1", RETURN-VALUE)).
            empty temp-table buf_tt-line.
            error-status :error = no.
         end.
         IF p-ftp-address <> "":U
         THEN DO:
            RUN ftp-send IN THIS-PROCEDURE (INPUT (v-file-name  + ".zip")) NO-ERROR .
            if error-status:error
            then do:
                                    run write-log-and-file in p-log-handle (           input 1                                                               , input log-file-name                                                   , input 1                                                               , input SUBSTITUTE("Ошибка отправки по FTP: &1", RETURN-VALUE)).
            end.
            ELSE DO:
               os-delete value( v-file-name  + ".zip" ) .
            END.
         END.
         empty temp-table buf_tt-line.
      end.
   END.
   os-delete value( STRING(v-file-name-mapping-new + ".txt":U)).
   hide frame info.
      run write-log-and-file in p-log-handle (           input 1                                                               , input log-file-name                                                   , input 1                                                               , input "Выгрузка закончена").
end.
procedure pack-file :
  define input parameter  p-file-name as character  no-undo.
  define input parameter  p-file-name-mapping as character no-undo.
  define variable v-arc             as character no-undo .
  define variable v-txt             as character no-undo .
  define variable v-list-file-name  as character no-undo .
  define variable v-arc-file-name   as character no-undo .
do
on error undo, return error return-value
:
   v-arc-file-name  = p-file-name + ".zip":U.
   v-arc = search( "exe/7za.exe" ).
   if v-arc = ? then do:
      return error("Не найдена программа 7za.exe, невозможно упаковать файлы в архив.").
   end.
   if search( v-arc-file-name ) <> ? then do:
      return error substitute ( "Файл &1 уже существует. Создание архива невозможно." , v-arc-file-name ).
   end.
   run gbl/_tmpfile.p ( "lst":u , ".txt":u , output v-list-file-name ).
   output stream lst-out to value(v-list-file-name).
   put stream lst-out unformatted (p-file-name + ".txt":U) skip.
   put stream lst-out unformatted (p-file-name-mapping + ".txt":U) skip.
   output stream lst-out close.
   assign
      v-txt = substitute( "&1 a -tzip &2 @&3"
                        , v-arc
                        , v-arc-file-name
                        , v-list-file-name).
   os-command silent value ( v-txt ) .
   os-delete value( v-list-file-name ) .
   os-delete value( STRING(p-file-name + ".txt":U )) .
end.
end procedure.
procedure ftp-send :
define input parameter p-file-name as character        no-undo.
define variable v-parameter    as character    no-undo.
do
on error undo, return error
:
        p-ftp-address = trim(trim(replace(p-ftp-address,'ftp:',""),chr(47)),chr(92)).
        v-parameter = p-ftp-address + chr(4) +
                      p-login + chr(4) +
                      p-password + chr(4) +
                      string(134217728) + chr(4) + ''
                       +
                      p-file-name  + chr(4) +
                       p-file-name + chr(4) +
                      string(no) + chr(4) +
                      log-file-name.
        run gbl/ftp-put.p   ( input this-procedure:handle
                          ,input this-procedure:handle
                        , input p-log-handle
                        , input v-parameter
                        ) no-error.
end.
end procedure.
