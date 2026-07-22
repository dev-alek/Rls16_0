block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.goods OLD old-goods .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись товара".
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
      p-vss-parameters = substitute('&1|&2|&3|&4':u,ub.goods.gds-code,ub.goods.artic,ub.goods.prod-type,ub.goods.prod-code)
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
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
procedure goodsh_write-goods-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-goods for ub.c-goods.
  do
  on error undo, return error
  :
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer('0':U).
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'goods':U
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
    create buf_c-goods.
    buffer-copy old-goods to buf_c-goods
    assign
    buf_c-goods.gds-code           = (if p-new-record then ub.goods.gds-code else old-goods.gds-code)
    buf_c-goods.chip-num           = next-value (s-gds-chip, ub)
    buf_c-goods.corr-time          = v-time
    buf_c-goods.corr-user-db-num   = g#db-num
    buf_c-goods.corr-user-name     = (if g#news then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                            then (chr(4) +  'ВС':U)
                                            else g#userid)
                                      )
    buf_c-goods.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-goods to buf_c-gds-hist
    assign
    buf_c-gds-hist.gds-code           = buf_c-goods.gds-code
    buf_c-gds-hist.action = (if p-new-record
                              then integer('1':U)
                              else (if ub.goods.gds-code = old-goods.gds-code
                                    then integer('2':U)
                                    else integer('9':U))
                            )
    buf_c-gds-hist.subject = 'goods':U
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = p-source-type
    buf_c-gds-hist.source-ref = p-source-ref
    .
  end.
end procedure.
procedure goodsh_write-goods-proc  :
define parameter buffer buf_goods for ub.goods .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-hist for ub.c-gds-hist.
define buffer buf_c-goods for ub.c-goods.
  do
  on error undo, return error
  :
    if not available buf_goods then do:
      undo, return error (vss-workfile + chr(32) + vss-revision + chr(32) + vss-description  + chr(10) +
                    "Ошибка задания входных параметров:Не определен товар" ).
    end.
    if g#news then do:
      define variable v-send as integer no-undo .
      v-send = integer('0':U).
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'goods':U
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
    create buf_c-goods.
    buffer-copy buf_goods to buf_c-goods
    assign
    buf_c-goods.gds-code             = buf_goods.gds-code
    buf_c-goods.chip-num           = next-value (s-gds-chip, ub)
    buf_c-goods.corr-time          = v-time
    buf_c-goods.corr-user-db-num   = g#db-num
    buf_c-goods.corr-user-name     = (if g#news then (chr(4) +  'СПН':U)
                                      else (if g#esys
                                            then (chr(4) +  'ВС':U)
                                            else g#userid)
                                            )
    buf_c-goods.corr-date          = v-date
    .
    create buf_c-gds-hist.
    buffer-copy buf_c-goods to buf_c-gds-hist
    assign
    buf_c-gds-hist.action =  p-action
    buf_c-gds-hist.subject = 'goods':U
    buf_c-gds-hist.is-news = g#news
    buf_c-gds-hist.source-type = p-source-type
    buf_c-gds-hist.source-ref = p-source-ref
    .
  end.
end procedure.
DEFINE VARIABLE conf-par    as character no-undo .
DEFINE VARIABLE par-type    as character no-undo .
DEFINE VARIABLE v-l         as logical   no-undo .
define variable v-date      as date      no-undo .
define variable v-time      as integer   no-undo .
define variable v-node-code as integer   no-undo .
define variable v-grp-code  as integer   no-undo .
define variable v-mes       as character no-undo .
define variable v-mes0      as character no-undo .
define buffer buf_c-goods    for ub.c-goods.
define buffer buf_c-gds-hist for ub.c-gds-hist.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if new(ub.goods) then
    do:
        assign
            v-l = no.
    end.
    else
    do:
        v-l = yes.
        buffer-compare ub.goods
            to old-goods
            case-sensitive
            save result in v-l.
    end.
    if v-l = yes then return.
    if new(ub.goods) then
    do:
        if ub.goods.gds-code = 0
            or ub.goods.gds-code = ? then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не задан код товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        if  ub.goods.gds-type <> 'т':U
            and ub.goods.gds-type <> 'у':U then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не задан тип товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "ub.goods.gds-type" ub.goods.gds-type skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        if  ub.goods.prod-type <> 'чел':U
            and ub.goods.prod-type <> 'орг':U then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Недопустимый тип производителя товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "ub.goods.prod-type" ub.goods.prod-type skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        find ub.units no-lock
            where ub.units.unit-name = ub.goods.unit-base
            no-error .
        if not available ub.units then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не найдена базовая единица измерения" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "Базовая единица измерения" ub.goods.unit-base skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        find ub.gds-prt no-lock
            where ub.gds-prt.upper-code = ub.goods.prt-root
            no-error .
        if not available ub.gds-prt
            or ub.gds-prt.prt-root <> ub.goods.prt-root then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Не найдена шкала" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "Код шкалы" ub.goods.prt-root skip
                view-as alert-box error .
            undo main-block, return error .
        end.
    end.
    else
    do:
        if ub.goods.gds-code <> old-goods.gds-code then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Нельзя изменить код товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "old-goods.gds-code" old-goods.gds-code skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        if ub.goods.gds-type <> old-goods.gds-type then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Нельзя изменить тип товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "ub.goods.gds-type" ub.goods.gds-type skip
                "old-goods.gds-type" old-goods.gds-type skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        if ub.goods.prod-type <> old-goods.prod-type then
        do:
            if  ub.goods.prod-type <> 'чел':U
                and ub.goods.prod-type <> 'орг':U then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Недопустимый тип производителя товара" skip
                    "Код товара" ub.goods.gds-code skip
                    "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                    "ub.goods.prod-type" ub.goods.prod-type skip
                    view-as alert-box error .
                undo main-block, return error .
            end.
        end.
        if ub.goods.unit-base <> old-goods.unit-base then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Нельзя изменить базовую единицу измерения товара" skip
                "Код товара" ub.goods.gds-code skip
                "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                "ub.goods.unit-base" ub.goods.unit-base skip
                "old-goods.unit-base" old-goods.unit-base skip
                view-as alert-box error .
            undo main-block, return error .
        end.
        if ub.goods.prt-root <> old-goods.prt-root then
        do:
            find ub.gds-prt no-lock
                where ub.gds-prt.upper-code = ub.goods.prt-root
                no-error .
            if not available ub.gds-prt
                or ub.gds-prt.prt-root <> ub.goods.prt-root then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Не найдена шкала" skip
                    "Код товара" ub.goods.gds-code skip
                    "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                    "Код шкалы" ub.goods.prt-root skip
                    view-as alert-box error .
                undo main-block, return error .
            end.
        end.
    end.
    if new (ub.goods)
        or ub.goods.grp-code <> old-goods.grp-code then
    do:
        run grplib-get-full-name in this-procedure (input ub.goods.grp-code, output ub.goods.grp-name) no-error .
        IF error-status:error
            AND G#NEWS
            AND G#DB-NUM = 0 THEN
        DO:
            v-mes0 = substitute("&1 &2 &3&4&5&4&5&4&6"
                ,vss-workfile
                ,vss-revision
                ,vss-description
                ,chr(10)
                , error-status:get-message(1)
                ,return-value).
            v-grp-code = ub.goods.grp-code.
            if old-goods.grp-code = ? then
            do:
                error-status:error = yes.
            end.
            else
            do:
                ASSIGN
                    UB.GOODS.grp-code = old-goods.grp-code.
                run grplib-get-full-name in this-procedure (input ub.goods.grp-code, output ub.goods.grp-name) no-error .
                v-mes0 =  substitute("&7&4&1 &2 &3&4&5&4&5&4&6&4"
                    ,vss-workfile
                    ,vss-revision
                    ,vss-description
                    ,chr(10)
                    , error-status:get-message(1)
                    ,return-value
                    ,v-mes0
                    ).
            end.
            if error-status:error then
            do:
                run grplib-get-node-from-full-name ( input ub.goods.grp-name, output v-node-code) no-error.
                if error-status:error then
                do:
                    v-mes = substitute("&1 &2 &3&4&5&4&5&4&6&4&7&4&8&4&9"
                        ,vss-workfile
                        ,vss-revision
                        ,vss-description
                        ,chr(10)
                        , error-status:get-message(1)
                        ,return-value
                        ,v-mes0
                        ,substitute("Не удается поместить товар в группу с вн. кодом &1,&2" +
                        "и не удается поместить товар в группу с полным именем &3"
                        ,v-grp-code
                        ,chr(10)
                        ,ub.goods.grp-name)
                        , substitute("Возможно Вам следует СОЗДАТЬ группу товара с полным именем &1"
                        ,ub.goods.grp-name)
                        ).
                    undo main-block, return error v-mes .
                end.
                assign
                    ub.goods.grp-code = v-node-code.
            end.
        END.
        else
        do:
            if error-status:error then
            do:
                v-mes = substitute("&1 &2 &3&4&5&4&6"
                    ,vss-workfile
                    ,vss-revision
                    ,vss-description
                    ,chr(10)
                    ,error-status:get-message(1)
                    ,return-value ).
                if not g#news then
                do:
                    message
                        v-mes view-as alert-box error .
                end.
                undo main-block, return error v-mes .
            end.
        end.
    end.
    if can-find(first ub.gds-grp where ub.gds-grp.upper-code = ub.goods.grp-code) then
    do:
        v-mes = substitute("Нельзя привязать товар с кодом &1 к нетерминальной группе с вн. кодом &2"
            , ub.goods.gds-code
            , ub.goods.grp-code).
        if not g#news then
        do:
            message
                v-mes
                view-as alert-box error .
        end.
        undo main-block, return error v-mes .
    end.
    if new (ub.goods)
        or ub.goods.grp-code <> old-goods.grp-code
        or ub.goods.unit-base <> ub.goods.unit-base then
    do:
        run trg/scan-grp.p (input ub.goods.grp-code, input ub.goods.unit-base).
    end.
    if old-goods.stts     <> ub.goods.stts
        or old-goods.grp-code <> ub.goods.grp-code then
    do:
        for each ub.gds-obj
            where ub.gds-obj.artic     = ub.goods.artic
            and ub.gds-obj.prod-type = ub.goods.prod-type
            and ub.gds-obj.prod-code = ub.goods.prod-code
            on error undo main-block, return error
            :
            assign
                ub.gds-obj.grp-name = ub.goods.grp-name
                ub.gds-obj.stts     = ub.goods.stts
                .
        end.
    end.
    if old-goods.gds-name     <> ub.goods.gds-name
        then
    do:
        for each ub.contract-specif
            where ub.contract-specif.artic     = ub.goods.artic
            and ub.contract-specif.prod-type = ub.goods.prod-type
            and ub.contract-specif.prod-code = ub.goods.prod-code
            on error undo main-block, return error
            :
            assign
                ub.contract-specif.gds-name = ub.goods.gds-name
                .
        end.
    end.
    if not v-l then
    do:
        if old-goods.stts = integer('50':U)
            or old-goods.stts = integer('51':U)
            or ub.goods.stts = integer('50':U)
            or ub.goods.stts = integer('51':U)
            then
        do:
        end.
        else
        do:
            run str/callnews.p
                (input 'goods':U
                ,input (buffer ub.goods:handle)
                ) no-error .
            if error-status:error then
            do:
                if error-status :get-message(1) <> ""
                    then
                do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "Ошибка при вызове процедуры callnews.p" skip
                        error-status :get-message(1) skip
                        return-value skip
                        view-as alert-box error .
                end.
                undo main-block,  return error return-value .
            end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input  ( if new(ub.goods) then 'gdsadd':U else 'gdsupdate':U )
  ,input  buffer old-goods:handle
  ,input  buffer ub.goods:handle
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
        end.
        if new (ub.goods) and ub.goods.gds-type = 'у':U then
        do:
            for each ub.gds-obj No-LOCK WHERE
                ub.gds-obj.gds-code = ub.goods.gds-code
                ON error undo, return error return-value
                :
                run str/callnews.p
                    (input 'gds-obj':U
                    ,input (buffer ub.gds-obj:handle)
                    ) no-error .
                if error-status:error then
                do:
                    if error-status :get-message(1) <> ""
                        then
                    do:
                        message
                            vss-workfile vss-revision vss-description skip
                            "Ошибка при вызове процедуры callnews.p (gds-obj)" skip
                            error-status :get-message(1) skip
                            return-value skip
                            view-as alert-box error .
                    end.
                    undo main-block,  return error return-value .
                end.
            end.
        end.
        if not new(ub.goods) then
        do:
            find ub.units no-lock
                where ub.units.unit-name = ub.goods.unit-base
                no-error .
            if not available ub.units then
            do:
                message
                    vss-workfile vss-revision vss-description skip
                    "Не найдена базовая единица измерения" skip
                    "Код товара" ub.goods.gds-code skip
                    "Артикул" ub.goods.artic ub.goods.prod-type ub.goods.prod-code skip
                    "Базовая единица измерения" ub.goods.unit-base skip
                    view-as alert-box error .
                undo main-block, return error .
            end.
            if (old-goods.gds-name  <> ub.goods.gds-name
                or old-goods.engl-name <> ub.goods.engl-name
                or old-goods.label-name <> ub.goods.label-name
                )
                and
                (LOOKUP('вес':U, ub.units.type) > 0
                or
                (LOOKUP('шту':U, ub.units.type) > 0
                and
                can-find(first ub.code-range no-lock where ub.code-range.range-type = 'pglc':U)
                )
                )
                then
            do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-attr-code7 as character no-undo .
define buffer buf7_gds-prt for ub.gds-prt.
define buffer buf7_bar-code for ub.bar-code.
define buffer buf7_scales-gds for ub.scales-gds.
define buffer buf7_scales for ub.scales.
find buf7_gds-prt no-lock
  where buf7_gds-prt.upper-code = ub.goods.prt-root
  .
find first buf7_bar-code no-lock
  where buf7_bar-code.gds-code  = ub.goods.gds-code
    and buf7_bar-code.node-code = buf7_gds-prt.node-code
    and buf7_bar-code.part-code = ""
    and buf7_bar-code.in-code   = ""
    and buf7_bar-code.unit-cli  = ub.goods.unit-base
  no-error .
if available buf7_bar-code then do:
  for each buf7_scales-gds
    where buf7_scales-gds.db-num = g#db-num
      AND buf7_scales-gds.b-code = buf7_bar-code.b-code
  :
    find first buf7_scales
      where buf7_scales.scales-num = buf7_scales-gds.scales-num
       and buf7_scales.db-num = buf7_scales-gds.db-num
      .
    run ref/ves-pbc.p (
                    input ?
                  , input 'ИЗМЕНЕНИЕ':U
                    , input buf7_scales-gds.obj-type
                    , input buf7_scales-gds.obj-code
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , buffer buf7_bar-code
                    , buffer buf7_scales) .
  end.
end.
            end.
            if old-goods.struct <> ub.goods.struct
                and (LOOKUP('вес':U, ub.units.type) > 0
                or
                (LOOKUP('шту':U, ub.units.type) > 0
                and
                can-find(first ub.code-range no-lock where ub.code-range.range-type = 'pglc':U)
                )
                )
                then
            do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-attr-code8 as character no-undo .
define buffer buf8_gds-prt for ub.gds-prt.
define buffer buf8_bar-code for ub.bar-code.
define buffer buf8_scales-gds for ub.scales-gds.
define buffer buf8_scales for ub.scales.
find buf8_gds-prt no-lock
  where buf8_gds-prt.upper-code = ub.goods.prt-root
  .
find first buf8_bar-code no-lock
  where buf8_bar-code.gds-code  = ub.goods.gds-code
    and buf8_bar-code.node-code = buf8_gds-prt.node-code
    and buf8_bar-code.part-code = ""
    and buf8_bar-code.in-code   = ""
    and buf8_bar-code.unit-cli  = ub.goods.unit-base
  no-error .
if available buf8_bar-code then do:
  for each buf8_scales-gds
    where buf8_scales-gds.db-num = g#db-num
      AND buf8_scales-gds.b-code = buf8_bar-code.b-code
  :
    find first buf8_scales
      where buf8_scales.scales-num = buf8_scales-gds.scales-num
       and buf8_scales.db-num = buf8_scales-gds.db-num
      .
        assign
    v-attr-code8 = entry (lookup (buf8_scales.scales-type, 'CAS_lp-16x,DIGI-SM,CAS_CL5000J,CAS_CL5000,TIGER-SPCT2,TIGER-SPCT1,CAS_LP-15,SHTRIH-M,CAS_LP-15v1.6':U), '8x50,15x80,6x50,6x50,8x50,8x50,8x50,8x50,8x50':U) no-error .
    if lookup(buf8_scales.scales-type, 'CAS_lp-16x,DIGI-SM,CAS_CL5000J,CAS_CL5000,TIGER-SPCT2,TIGER-SPCT1,CAS_LP-15,SHTRIH-M,CAS_LP-15v1.6':U) > 0
    and ('struct' = "struct" or v-attr-code8 = 'struct')
    then do:
    run ref/ves-pbc.p (
                    input ?
                  , input 'ИЗМЕНЕНИЕ':U
                    , input buf8_scales-gds.obj-type
                    , input buf8_scales-gds.obj-code
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , buffer buf8_bar-code
                    , buffer buf8_scales) .
      end.
  end.
end.
            end.
        end.
        if not g#news and new(ub.goods) then
        do:
            assign
                ub.goods.cr-db-num = g#db-num.
        end.
        if not g#news and send-ref then
        do:
            if not new(ub.goods) then
            do:
                define variable v-l2 as logical no-undo .
                assign
                    v-l2 = yes
                    .
                buffer-compare ub.goods using
                    engl-name gds-name chk-name
                    to old-goods
                    case-sensitive
                    save result in v-l2 .
                if not v-l2 then
                do:
                    run trg/nu_gds.p (
                        input  ub.goods.gds-code
                        ,input  0
                        ,input  "":U
                        ,input  0
                        ,input  "U":U
                        ).
                end.
            end.
        end.
        run goodsh_write-goods-trigger in this-procedure  (
            input new(ub.goods)
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
        if error-status:error then
        do:
            message
                vss-workfile vss-revision vss-description skip
                "Ошибка при вызове процедуры goodsh_write-goods-trigger" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
            undo main-block,  return error return-value .
        end.
    end.
    if g#oxml = yes
        then
    do:
        run str/calloxml.p (
            input 'update':U
            , input 'goods':U
            , input ( buffer ub.goods:handle )
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
    if new(ub.goods) then
    do:
        run trg/userlog.p (
            input 'create':U
            , input 'goods':U
            , input ( buffer ub.goods :handle )
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
            , input 'goods':U
            , input ( buffer ub.goods :handle )
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
