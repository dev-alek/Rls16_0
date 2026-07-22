block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.cli-grp OLD oldb.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись группы клиентов".
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
      p-vss-parameters = substitute('&1|&2|&3',ub.cli-grp.node-code,ub.cli-grp.upper-code,ub.cli-grp.node-name)
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
procedure clientsh_write-clients-proc  :
define parameter buffer buf_clients for ub.clients .
define input parameter p-source-type like ub.c-cli-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-cli-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-cli-hist for ub.c-cli-hist.
define buffer buf_c-clients for ub.c-clients.
  do
  on error undo, return error
  :
    if not available buf_clients then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определен контрагент" skip
        view-as alert-box error .
      undo, return error .
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      define variable v-subject as character no-undo .
      case buf_clients.obj-type:
        when 'орг':U then v-subject =  'firm':U.
        when 'чел':U then v-subject =  'person':U.
        when 'маг':U then v-subject =  'shop':U.
        when 'скл':U then v-subject =  'store':U.
      end case.
      v-send = integer('0':U).
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    buffer-copy buf_clients to buf_c-clients
    assign
    buf_c-clients.obj-code           = buf_clients.obj-code
    buf_c-clients.obj-type           = buf_clients.obj-type
    buf_c-clients.chip-num           = next-value (s-cli-chip, ub)
    buf_c-clients.corr-time          = v-time
    buf_c-clients.corr-user-db-num   = g#db-num
    buf_c-clients.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                              then (chr(4) +  'ВС':U)
                                              else g#userid)
                                        )
    buf_c-clients.corr-date          = v-date
    .
    create buf_c-cli-hist.
    buffer-copy buf_c-clients to buf_c-cli-hist
    assign
    buf_c-cli-hist.action =  integer('2':U)
    buf_c-cli-hist.subject = 'clients':U
    buf_c-cli-hist.host-code = (if buf_clients.obj-type = 'орг':U
                                and
                                can-find(first ub.sysconf no-lock where
                                                  ub.sysconf.host-code = buf_clients.obj-code)
                                then buf_clients.obj-code
                                else 0)
    buf_c-cli-hist.is-news = g#news
    buf_c-cli-hist.source-type = p-source-type
    buf_c-cli-hist.source-ref = p-source-ref
    .
  end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cli-grph_write-cli-grp-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type as character no-undo .
define input parameter p-source-ref  as character no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-cli-grp for ub.c-cli-grp.
  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-cli-grp.
    buffer-copy oldb to buf_c-cli-grp
    assign
    buf_c-cli-grp.node-code           = (if p-new-record then ub.cli-grp.node-code else oldb.node-code)
    buf_c-cli-grp.chip-num           = next-value (s-cli-grp-chip, ub)
    buf_c-cli-grp.corr-time          = v-time
    buf_c-cli-grp.corr-user-db-num   = g#db-num
    buf_c-cli-grp.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                              then (chr(4) +  'ВС':U)
                                              else
                                             g#userid)
                                        )
    buf_c-cli-grp.corr-date          = v-date
    buf_c-cli-grp.is-del             = (p-action = integer('99':U))
    buf_c-cli-grp.action             =  p-action
    buf_c-cli-grp.subject            = 'cli-grp':U
    .
  end.
end procedure.
define buffer b-cli-grp for ub.cli-grp.
define buffer other_cli-grp for ub.cli-grp.
define variable name as char no-undo.
define variable uc as int no-undo.
define variable skip-proc as log no-undo.
define variable v-changed-node-code like ub.cli-grp.node-code no-undo .
define variable v-changed-node-code-2 like ub.cli-grp.node-code no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-only-is-term as logical no-undo .
define variable v-chr as character no-undo .
define buffer buf_dis-grp-rule for ub.dis-grp-rule.
define buffer buf2_dis-grp-rule for ub.dis-grp-rule.
define buffer buf_clients for ub.clients.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news and ( g#db-num > 0 ) then do:
    message
    vss-workfile vss-revision vss-description skip
    "Нельзя изменять запись ГРУППЫ КЛИЕНТОВ в УБД" skip
    "Номер текущей БД" g#db-num
    view-as alert-box error .
    undo main-block, return error .
  end.
  on write of ub.clients override do: end.
  on write of ub.cli-grp override do: end.
  on write of ub.c-clients override do: end.
  on write of ub.c-cli-hist override do: end.
  run cli-grplib-get-full-name in this-procedure
    (input ub.cli-grp.node-code
    ,output name
    ).
  if oldb.node-code <> ub.cli-grp.node-code
  then do:
    find b-cli-grp
      where b-cli-grp.node-code = ub.cli-grp.upper-code
      .
    assign
      cli-grp.lvl-num = b-cli-grp.lvl-num + 1
       b-cli-grp.is-term = no
    .
  assign
  v-changed-node-code = ub.cli-grp.node-code
  .
    for each buf_clients
      where buf_clients.grp-code = b-cli-grp.node-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      run clientsh_write-clients-proc  in this-procedure (
                                                           buffer buf_clients
                                                          ,input 'grp-chg':U
                                                          ,input string(ub.cli-grp.node-code)
                                                          ).
      assign
      buf_clients.grp-code = ub.cli-grp.node-code
      .
    end.
    for each buf_dis-grp-rule share-lock where
            buf_dis-grp-rule.classif-type = 'cli-grp':U
        and buf_dis-grp-rule.node-code = b-cli-grp.node-code
        and buf_dis-grp-rule.host-code = 0
        and buf_dis-grp-rule.obj-type = '':U
        and buf_dis-grp-rule.obj-code = 0
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
       create buf2_dis-grp-rule.
       buffer-copy buf_dis-grp-rule except node-code to buf2_dis-grp-rule
       assign
       buf2_dis-grp-rule.node-code = ub.cli-grp.node-code
       .
       delete buf_dis-grp-rule.
    end.
  end.
  else if ub.cli-grp.upper-code <> oldb.upper-code then do:
      find b-cli-grp  where
        b-cli-grp.node-code = ub.cli-grp.upper-code no-wait no-error.
    if not available b-cli-grp then do:
       undo main-block, return error substitute("cli-grp with node-code &1 is locked", ub.cli-grp.upper-code).
    end.
    assign
    b-cli-grp.is-term = no
    ub.cli-grp.lvl-num = b-cli-grp.lvl-num + 1
    .
    find first b-cli-grp where
             b-cli-grp.node-code = oldb.upper-code no-wait no-error.
    if locked(b-cli-grp) then do:
      undo main-block, return error substitute("cli-grp with node-code &1 is locked", oldb.upper-code) .
    end.
    else do:
      if available b-cli-grp then do:
        if not can-find(first other_cli-grp no-lock where
                              other_cli-grp.upper-code = oldb.upper-code
                          AND recid(other_cli-grp) <> recid(ub.cli-grp)) then do:
          assign
          b-cli-grp.is-term = yes
          .
        end.
      end.
    end.
  end.
  buffer-compare oldb to ub.cli-grp
  case-sensitive
  save result in v-chr.
  if v-chr = "is-term":U then do:
    assign
    v-only-is-term = yes
    .
  end.
  assign
    ub.cli-grp.is-term = yes
  .
  assign
  v-changed-node-code-2 = ub.cli-grp.node-code
  .
  run grp-tree in this-procedure
    (input ub.cli-grp.node-code
    ,input name
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры grp-tree" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error.
  end.
  define variable v-synch-cli-grp as integer   no-undo .
  assign
    v-synch-cli-grp = next-value (synch-cli-grp, ub)
  .
  run str/callnews.p
    (input 'cli-grp':U
    ,input (buffer ub.cli-grp:handle)
    ) no-error .
  if error-status :error then do:
    message
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box.
    undo main-block, return error.
  end.
  if not g#news then do:
    define variable v-l as logical no-undo .
    buffer-compare oldb to ub.cli-grp
    case-sensitive
    save result in v-l.
    if not v-l then
    run cli-grph_write-cli-grp-trigger in this-procedure (
                                                            new(ub.cli-grp)
                                                           ,"":U
                                                           ,"":U
                                                           , (if new(ub.cli-grp) then integer('1':U) else integer('2':U))
                                                           ).
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input 'update':U
        , input 'cli-grp':U
        , input ( buffer ub.cli-grp:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
    if new(ub.cli-grp) then
  do:
    run trg/userlog.p (
      input 'create':U
      , input 'cli-grp':U
      , input ( buffer ub.cli-grp :handle )
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
      , input 'cli-grp':U
      , input ( buffer ub.cli-grp :handle )
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
END.
procedure grp-tree :
  define input param nc as int no-undo.
  define input param cur-name as char no-undo.
  define buffer b-g-g for ub.cli-grp.
  main-block:
  do
  on error undo, return error return-value
  :
    for each b-g-g
      where b-g-g.upper-code = nc
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
      if nc = ub.cli-grp.node-code then do:
        assign
          ub.cli-grp.is-term = no
        .
      end.
      run grp-tree in this-procedure
        (input b-g-g.node-code
        ,input trim(cur-name, chr(47)) + (if cur-name = "":U then "":U else chr(47)) + b-g-g.node-name
        ).
    end.
    for each ub.clients
      where ub.clients.grp-code = nc
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
      if v-changed-node-code <> nc
      and not v-only-is-term
      then do:
        run clientsh_write-clients-proc  in this-procedure (
                                                              buffer ub.clients
                                                            ,input 'grp-chg':U
                                                            ,input string(v-changed-node-code-2)
                                                            ).
      end.
      assign
        ub.clients.grp-name = trim(cur-name , chr(47)) + chr(47)
      .
    end.
  end.
end procedure.
