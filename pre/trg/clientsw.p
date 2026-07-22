block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.clients  OLD old-clients.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись клиента".
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
    assign
      p-vss-parameters = substitute('&1|&2', ub.clients.obj-type, ub.clients.obj-code)
    .
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
procedure cli-grplib-get-full-name :
   define input parameter  p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_upper_cli-grp for ub.cli-grp.
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-code = p-node-code
    no-error.
    if not available buf_cli-grp
    then do:
        undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_cli-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_cli-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_cli-grp.upper-code
        .
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-upper-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "cli-grplib-get-full-name: Не найдена группа клиентов с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure cgrplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_cli-grp       for ub.cli-grp.
do
on error undo, return error
:
  find first buf_cli-grp no-lock
      where buf_cli-grp.upper-code = 0
  no-error .
  if not available buf_cli-grp
  then do:
      undo, return error substitute("Не найдена корневая группа клиентов (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_cli-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_cli-grp no-lock where
              buf_cli-grp.node-name = v-entry
          and buf_cli-grp.upper-code = v-upper-code
          no-error.
    if not available buf_cli-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_cli-grp.node-code.
      v-upper-code = buf_cli-grp.node-code.
    end.
  end.
end.
end .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
procedure clientsh_write-clients-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-cli-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-cli-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.
  do
  on error undo, return error
  :
    if g#news then do:
      define variable v-send as integer no-undo .
      define variable v-subject as character no-undo .
      case old-clients.obj-type:
        when 'орг':U then v-subject =  'firm':U.
        when 'чел':U then v-subject =  'person':U.
        when 'маг':U then v-subject =  'shop':U.
        when 'скл':U then v-subject =  'store':U.
      end case.
      v-send = integer('0':U).
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  v-subject
  ,input  0
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  0
  ,input  0
  ,input  'nws-to-hist'
  ,output v-send
  ) no-error .
      if v-send < 0 then return.
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-clients.
    buffer-copy old-clients to buf_c-clients
    assign
    buf_c-clients.obj-code           = ub.clients.obj-code
    buf_c-clients.obj-type           = ub.clients.obj-type
    buf_c-clients.chip-num           = next-value (s-cli-chip, ub)
    buf_c-clients.corr-time          = v-time
    buf_c-clients.corr-user-db-num   = g#db-num
    buf_c-clients.corr-user-name     = (if g#news then (chr(4) +  'СПН':U) else g#userid)
    buf_c-clients.corr-date          = v-date
    .
    create buf_c-cli-hist.
    buffer-copy buf_c-clients to buf_c-cli-hist
    assign
    buf_c-cli-hist.action =  (if p-new-record
                              then integer('1':U)
                              else integer('2':U))
    buf_c-cli-hist.subject = 'clients':U
    buf_c-cli-hist.host-code = (if ub.clients.obj-type = 'орг':U
                                and
                                can-find(first ub.sysconf no-lock where
                                                  ub.sysconf.host-code = ub.clients.obj-code)
                                then ub.clients.obj-code
                                else 0)
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = p-source-type
    buf_c-cli-hist.source-ref = p-source-ref
    .
    release buf_c-clients no-error .
    if error-status:error then do:
      undo , return error return-value .
    end.
    release buf_c-cli-hist no-error .
    if error-status:error then do:
      undo , return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-is-this-db-code returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'u'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code no-error .
if available buf_code-range then return yes.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and  buf_code-range.stts = 'a'
      and buf_code-range.first-code <= p-code
      no-error .
 if available buf_code-range then return yes.
end.
find first buf_code-range no-lock where
          buf_code-range.db-num = p-db-num
    and  buf_code-range.range-type = p-range-type
    and  buf_code-range.stts = 'f'
    and buf_code-range.first-code <= p-code
    and buf_code-range.last-code >= p-code
    no-error .
if available buf_code-range then return yes.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-code-short returns logical ( input p-db-num as integer
                                                    ,input p-range-type as character
                                                    ,input p-code as integer):
define variable v-seq-val as integer no-undo .
define buffer buf_code-range for ub.code-range.
CASE p-range-type:
  when 'pngb':U then do:
    v-seq-val = current-value(s-pngb-code, ub).
  end.
  when 'fmgb':U then do:
    v-seq-val = current-value(s-fmgb-code, ub).
  end.
END CASE.
if p-code <= v-seq-val then do:
  find first buf_code-range no-lock where
            buf_code-range.db-num = p-db-num
      and  buf_code-range.range-type = p-range-type
      and buf_code-range.first-code <= p-code
      and buf_code-range.last-code >= p-code no-error .
  if available buf_code-range then return yes.
end.
return no.
END FUNCTION.
FUNCTION gbclcode-is-this-db-role returns integer ( input p-role as character
                                                    ,input p-db-num as integer
                                                    ,input p-staff-code as integer
                                                    ,input p-date as date
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
      and buf_staff.staff-code = p-staff-code
      and buf_staff.date-end >= p-date use-index pi  no-error .
if available buf_staff then do:
  return buf_staff.psn-code.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-this-db-first-role returns integer ( input p-role as character
                                                          ,input p-db-num as integer
                                                          ,input p-date as date
                                                              ):
define buffer buf_staff for ub.staff.
define buffer buf2_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each  buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.db-num = p-db-num,
first buf2_staff no-lock where
      buf2_staff.role = p-role
  and buf2_staff.role-level = 'db':U
  and buf2_staff.staff-code = buf_staff.staff-code
  and buf2_staff.date-start <= p-date
  and buf2_staff.date-end >= p-date
by buf_staff.staff-code
by date-start descending:
  return buf_staff.staff-code.
end.
end FUNCTION.
FUNCTION gbclcode-get-db-role returns integer ( input p-role as character
                                               ,input p-db-num as integer
                                               ,input p-psn-code as integer
                                               ,input p-date as date
                                               ,output p-c-password as character
                                                     ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
find first buf_staff no-lock where
          buf_staff.role = p-role
      and buf_staff.role-level = 'db':U
      and buf_staff.db-num = p-db-num
     and buf_staff.date-end >= p-date
     and buf_staff.psn-code = p-psn-code use-index irole-psn no-error .
if available buf_staff
then do:
  assign
  p-c-password = buf_staff.password.
  return buf_staff.staff-code.
end.
p-c-password = ''.
return 0.
end FUNCTION.
FUNCTION gbclcode-is-psn-role returns integer (
                                              input p-role as character
                                              ,input p-psn-code as integer
                                              ,input p-date as date
                                                  ):
define buffer buf_staff for ub.staff.
if p-date = ? then do:
  p-date = today .
end.
for each buf_staff no-lock where
          buf_staff.psn-code = p-psn-code
     and  buf_staff.role = p-role
by buf_staff.role-level
by buf_staff.date-start
     :
  if  buf_staff.date-start <= p-date and
  buf_staff.date-end >= p-date  then do:
    return buf_staff.staff-code.
  end.
end.
return 0.
end FUNCTION.
FUNCTION gbclcode-get-role-name returns character ( input p-role as character):
define variable v-role-name as character no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
no-error .
return v-role-name.
END.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION gbclcode-get-position returns character ( input p-role as character
                                                  ,input p-role-level as character
                                                  ,input p-work-place as character
                                                  ,input p-staff-code as integer
                                                             ):
define variable v-role-name as character no-undo .
define variable v-role-level as character no-undo .
define variable v-staff-code as integer no-undo .
assign
v-role-name = entry (lookup (p-role, 'C,S':U) + 1, ',':U + 'Кассир,Продавец':U)
v-role-level = substitute("&1 &2", entry (lookup (p-role-level, 'global,db,firm,object':U) + 1, ',':U + 'Глобально,БД,Фирма,Объект':U) , p-work-place)
v-staff-code = p-staff-code
no-error .
return substitute("&1, &2, Код &3"
                ,v-role-name
                ,v-role-level
                ,(if p-staff-code = 0 then chr(63) else string(p-staff-code))).
END.
FUNCTION gbclcode-get-work-place returns character (
                                                input p-role as character
                                               ,input p-role-level as character
                                               ,input p-db-num as integer
                                               ,input p-host-code as integer
                                               ,input p-obj-type as character
                                               ,input p-obj-code as integer
                                               ) :
define variable v-work-place as character no-undo .
define variable v-obj-type as character no-undo .
  case p-role-level:
    when 'db':U then do:
      v-work-place = string(p-db-num, "99999").
    end.
    when 'firm':U then do:
      v-work-place = string(p-host-code, "99999").
    end.
    when 'object':U then do:
      assign
      v-work-place = p-obj-type + string(p-obj-code, "999999999")
      .
    end.
  END CASE.
  return v-work-place.
END FUNCTION.
FUNCTION gbclcode-get-level-last-code returns integer (
                                                        input p-role as character
                                                      , input p-role-level as character
                                                      , input p-work-place as character
                                                      , input p-date-start as date
                                                      ):
DEFINE VARIABLE v-today as date no-undo .
define buffer buf_staff for ub.staff.
if p-work-place = chr(63) then return ?.
if p-date-start = ? then do:
  v-today = today .
end.
else do:
  v-today = p-date-start.
end.
find last buf_staff no-lock where
          buf_staff.role = p-role
     and  buf_staff.role-level = p-role-level
     and  buf_staff.work-place = p-work-place
     and  buf_staff.date-start <= v-today + 1
     and  buf_staff.date-end >= v-today + 1
     use-index pi  no-error .
if available buf_staff
then return buf_staff.staff-code.
return 0.
end FUNCTION.
define variable g-name         as char      format "x(30)" no-undo .
DEFINE VARIABLE conf-par       as character no-undo .
DEFINE VARIABLE par-type       as character no-undo .
DEFINE VARIABLE v-l-chr        as character no-undo .
define variable v-date         as date      no-undo.
define variable v-time         as integer   no-undo.
define variable v-seller-code  as integer   no-undo .
define variable v-cashier-code as integer   no-undo .
define variable v-password     as character no-undo .
define variable v-trg-param    as character no-undo .
assign
    v-trg-param          = ub.clients.trg-param
    ub.clients.trg-param = '':U
    .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_person   for ub.person.
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_shop     for ub.shop.
define buffer buf_store    for ub.store.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if not new(ub.clients) then
    do:
        if ub.clients.obj-type <> old-clients.obj-type
            or ub.clients.obj-code <> old-clients.obj-code then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Нельзя поменять тип или код клиента" skip
                "ub.clients.obj-type" ub.clients.obj-type skip
                "ub.clients.obj-code" ub.clients.obj-code skip
                "old-clients.obj-type" old-clients.obj-type skip
                "old-clients.obj-code" old-clients.obj-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    else
    do:
        if  ub.clients.obj-type <> 'скл':U
            and ub.clients.obj-type <> 'маг':U
            and ub.clients.obj-type <> 'орг':U
            and ub.clients.obj-type <> 'чел':U
            then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Неизвестный тип клиента" skip
                "ub.clients.obj-type" ub.clients.obj-type skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        if ub.clients.obj-code = ? then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не задан код клиента" skip
                "ub.clients.obj-code" ub.clients.obj-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        if ub.clients.obj-code = 0 then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не задан код клиента" skip
                "ub.clients.obj-code" ub.clients.obj-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    if ub.clients.obj-type = 'скл':U
        or ub.clients.obj-type = 'маг':U
        then
    do:
        find first ub.db no-lock
            where ub.db.db-num = ub.clients.db-num
            no-error .
        if not available ub.db then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Неправильная ссылка на базу данных" skip
                "Клиент" ub.clients.obj-type ub.clients.obj-code skip
                "База данных" ub.clients.db-num skip
                view-as alert-box error .
            undo, return error .
        end.
        if new(ub.clients)
            then
        do:
            define variable v-attr-arh-disable-chr   as character no-undo .
            define variable v-attr-arh-disable-type  as character no-undo .
            define variable v-attr-arh-disable       as logical   no-undo .
            define variable v-attr-ahsp-disable-chr  as character no-undo .
            define variable v-attr-ahsp-disable-type as character no-undo .
            define variable v-attr-ahsp-disable      as logical   no-undo .
            define variable v-attr-aht-disable-chr   as character no-undo .
            define variable v-attr-aht-disable-type  as character no-undo .
            define variable v-attr-aht-disable       as logical   no-undo .
            run db-attr-value in this-procedure
                (input  ub.clients.db-num
                ,input  'arh-disable':U
                ,output v-attr-arh-disable-chr
                ,output v-attr-arh-disable-type
                ) .
            assign
                v-attr-arh-disable = lookup(v-attr-arh-disable-chr, 'yes,true':u) > 0
                .
            if v-attr-arh-disable = true
                then
            do:
                run trg/ahobjdis.p
                    (input  'arh':U
                    ,input  ub.clients.obj-type
                    ,input  ub.clients.obj-code
                    ,input  true
                    ) .
            end.
            run db-attr-value in this-procedure
                (input  ub.clients.db-num
                ,input  'ahsp-disable':U
                ,output v-attr-ahsp-disable-chr
                ,output v-attr-ahsp-disable-type
                ) .
            assign
                v-attr-ahsp-disable = lookup(v-attr-arh-disable-chr, 'yes,true':u) > 0
                .
            if v-attr-ahsp-disable = true
                then
            do:
                run trg/ahobjdis.p
                    (input  'ahsp':U
                    ,input  ub.clients.obj-type
                    ,input  ub.clients.obj-code
                    ,input  true
                    ) .
            end.
            run db-attr-value in this-procedure
                (input  ub.clients.db-num
                ,input  'ahsp-disable':U
                ,output v-attr-aht-disable-chr
                ,output v-attr-aht-disable-type
                ) .
            assign
                v-attr-aht-disable = lookup(v-attr-arh-disable-chr, 'yes,true':u) > 0
                .
            if v-attr-aht-disable = true
                then
            do:
                run trg/ahobjdis.p
                    (input  'aht':U
                    ,input  ub.clients.obj-type
                    ,input  ub.clients.obj-code
                    ,input  true
                    ) .
            end.
        end.
        if not new(ub.clients) then
        do:
            if ub.clients.obj-type = 'маг':U then
            do:
                find first buf_shop no-lock where
                    buf_shop.obj-code = ub.clients.obj-code .
                find first buf_sysconf no-lock where
                    buf_sysconf.host-code = buf_shop.host-code.
            end.
            else
            do:
                find first buf_store no-lock where
                    buf_store.obj-code = ub.clients.obj-code .
                find first buf_sysconf no-lock where
                    buf_sysconf.host-code = buf_store.host-code.
            end.
            if buf_sysconf.firm-db-num <> 0 AND
                ub.clients.db-num <> 0 then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Главная БД фирмы не совпадает с БД, к которой относится объект" skip
                    view-as alert-box error .
                undo main-block, return error.
            end.
        end.
        if not new(ub.clients) then
        do:
            if ub.clients.db-num <> old-clients.db-num then
            do:
                run trg/objchk.p
                    (input ub.clients.obj-type
                    ,input ub.clients.obj-code
                    ,input "check-open":u
                    ) no-error .
                if error-status :error then
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Нельзя переносить объект из одной удаленной БД в другую удаленную" skip
                        "Не прошла проверка отсутствия открытых документов" skip
                        "Клиент" ub.clients.obj-type ub.clients.obj-code skip
                        "Новая база данных" ub.clients.db-num skip
                        "Старая база данных" old-clients.db-num skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                    undo, return error .
                end.
            end.
        end.
    end.
    else
    do:
        if ub.clients.db-num <> ? then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Клиент не может принадлежать какой либо базе данных" skip
                "Поле база данных должно иметь неопределенное значение" skip
                "Клиент" ub.clients.obj-type ub.clients.obj-code skip
                "База данных" ub.clients.db-num skip
                view-as alert-box error .
            undo, return error .
        end.
    end.
    if ub.clients.grp-code = ? then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Должна быть задана группа клиентов" skip
            "Клиент" ub.clients.obj-type ub.clients.obj-code skip
            view-as alert-box error .
        undo, return error .
    end.
    find first ub.cli-grp no-lock
        where ub.cli-grp.node-code = clients.grp-code
        no-error .
    if not available ub.cli-grp then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Неизвестная группа клиентов" skip
            "Клиент" ub.clients.obj-type ub.clients.obj-code skip
            "Группа клиентов" clients.grp-code skip
            view-as alert-box error .
        undo, return error .
    end.
    if new(ub.clients)
        or (old-clients.grp-code <> clients.grp-code) or clients.grp-name = "" then
    do:
        assign
            g-name = ""
            .
        run cli-grplib-get-full-name in this-procedure
            (input        clients.grp-code
            ,output g-name
            ).
        assign
            clients.grp-name = g-name
            .
    end.
    buffer-compare ub.clients
        to old-clients
        case-sensitive
        save result in v-l-chr .
    if
        not g#news and
        not (ub.clients.obj-type = 'маг':U or ub.clients.obj-type = 'скл':U) then
    do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable send-ref as logical no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'send-ref'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
  send-ref = (IF error-status:error or conf-par <> "yes" then no else yes).
        if send-ref then
        do:
            if not new(ub.clients) then
            do:
                if lookup("obj-name", v-l-chr) > 0 then
                do:
                    for each buf_dis-card no-lock where
                        buf_dis-card.cli-type = ub.clients.obj-type
                        AND buf_dis-card.cli-code = ub.clients.obj-code :
                        run trg/nu_dcard.p (
                            input  buf_dis-card.d-card
                            ,input  buf_dis-card.emitent-host-code
                            ,input  "":U
                            ,input  0
                            ,input  "U":U
                            ).
                    end.
                end.
            end.
        end.
        If ub.clients.obj-type = 'чел':U then
        do:
            if old-clients.obj-name <> ub.clients.obj-name then
            do:
                assign
                    v-seller-code = gbclcode-get-db-role (
                                                  input 'S':U
                                                 ,input g#db-num
                                                 ,input ub.clients.obj-code
                                                 ,input ?
                                                 ,output v-password
                                                    ) no-error .
                if v-seller-code > 0 then
                do:
                    run trg/nu_slr.p (
                        input  v-seller-code
                        ,input ub.clients.obj-code
                        ,input 0
                        ,input  "":U
                        ,input  0
                        ,input  "U":U
                        ,input v-password
                        ).
                end.
                assign
                    v-cashier-code = gbclcode-get-db-role (
                                                   input 'C':U
                                                  ,input g#db-num
                                                  ,input ub.clients.obj-code
                                                  ,input ?
                                                  ,output v-password
                                                    ) no-error .
                if v-cashier-code > 0 then
                do:
                    run trg/nu_cshr.p (
                        input  v-cashier-code
                        ,input ub.clients.obj-code
                        ,input 0
                        ,input  "":U
                        ,input  0
                        ,input  "U":U
                        ,input v-password
                        ).
                end.
            end.
        end.
    end.
    if lookup('no-hist':U, v-trg-param) = 0 then
    do:
        if
            g#news
            or  (v-l-chr <> "":U
            and lookup(v-l-chr, "sup-gds,sup-cons,sup-serv,buy-gds,buy-cons,buy-serv,is-prod":U) = 0
            ) then
        do:
            run clientsh_write-clients-trigger in this-procedure  (
                input new(ub.clients)
                ,input (if g#news
                then 'db':U
                else (if g#esys
                then 'esys':U
                else "":U)
                )
                ,input  (if g#news
                then string(g#news-source-db)
                else (if g#esys
                then string(g#esys-source-esys)
                else "":U)
                )
                ) no-error .
            if error-status:error then undo main-block, return error return-value.
        end.
    end.
    if lookup('no-callnews':U, v-trg-param) = 0 then
    do:
        run str/callnews.p
            (input 'clients':U
            ,input (buffer ub.clients:handle)
            ) no-error .
        if error-status:error then
        do:
            undo main-block, return error return-value .
        end.
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input  ( if new(ub.clients) then 'cliadd':U else 'cliupdate':U )
  ,input  buffer old-clients:handle
  ,input  buffer ub.clients:handle
  ,input ''
  ,input ''
  ) no-error .
    if error-status:error
        then
    do:
        if not g#news then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры rum-runa.i" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
        end.
        undo main-block,  return error return-value .
    end.
    if not g#news and g#db-num = 0 then
    do:
        if ub.clients.turnover-buyer =  true  and  old-clients.turnover-buyer = false then
        do:
            run ref/calcturn.p (ub.clients.obj-type, ub.clients.obj-code) no-error .
        end.
        if ub.clients.turnover-buyer =  false and  old-clients.turnover-buyer = true  then
        do:
            run ref/delturn.p ( ub.clients.obj-type, ub.clients.obj-code ) no-error .
        end.
    end.
    if g#oxml = yes
        then
    do:
        run str/calloxml.p (
            input 'update':U
            , input 'clients':U
            , input ( buffer ub.clients:handle )
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
    if new(ub.clients) then
    do:
        run trg/userlog.p (
            input 'create':U
            , input 'clients':U
            , input ( buffer ub.clients :handle )
            , input ?
            , input ""
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
    else
    do:
        run trg/userlog.p (
            input 'update':U
            , input 'clients':U
            , input ( buffer ub.clients :handle )
            , input ?
            , input ""
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
end.
