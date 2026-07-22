block-level on error undo, throw.
TRIGGER PROCEDURE FOR DELETE OF ub.gds-grp.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление группы товара".
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
      p-vss-parameters = substitute('&1|&2|&3',ub.gds-grp.node-code,ub.gds-grp.upper-code,ub.gds-grp.node-name)
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "X(65)" no-undo
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-grph_write-gds-grp-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-gds-grp-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-grp-hist.source-ref no-undo .
define input parameter p-action as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-gds-grp for ub.c-gds-grp.
  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-grp.
    buffer-copy ub.gds-grp to buf_c-gds-grp
    assign
    buf_c-gds-grp.node-code           = (if p-new-record then ub.gds-grp.node-code else ub.gds-grp.node-code)
    buf_c-gds-grp.chip-num           = next-value (s-gds-grp-chip, ub)
    buf_c-gds-grp.corr-time          = v-time
    buf_c-gds-grp.corr-user-db-num   = g#db-num
    buf_c-gds-grp.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                             then (chr(4) +  'ВС':U)
                                             else g#userid)
                                        )
    buf_c-gds-grp.corr-date          = v-date
    .
    create buf_c-gds-grp-hist.
    buffer-copy buf_c-gds-grp to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.node-code           = buf_c-gds-grp.node-code
    buf_c-gds-grp-hist.action = p-action
    buf_c-gds-grp-hist.subject = 'gds-grp':U
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    .
  end.
end procedure.
procedure gds-grph_write-gds-grp-attr-proc  :
define parameter buffer buf_gds-grp-attr for ub.gds-grp-attr .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-gds-grp-attr for ub.c-gds-grp-attr.
  do
  on error undo, return error
  :
    if not available buf_gds-grp-attr then do:
      undo, return error (vss-workfile + chr(32) + vss-revision + chr(32) + vss-description  + chr(10) +
                    "Ошибка задания входных параметров:Не определен атрибут группы товара" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-grp-attr.
    buffer-copy buf_gds-grp-attr to buf_c-gds-grp-attr
    assign
    buf_c-gds-grp-attr.node-code          = buf_gds-grp-attr.node-code
    buf_c-gds-grp-attr.attr-code          = buf_gds-grp-attr.attr-code
    buf_c-gds-grp-attr.host-code          = buf_gds-grp-attr.host-code
    buf_c-gds-grp-attr.obj-type           = buf_gds-grp-attr.obj-type
    buf_c-gds-grp-attr.obj-code           = buf_gds-grp-attr.obj-code
    buf_c-gds-grp-attr.chip-num           = next-value (s-gds-grp-chip, ub)
    buf_c-gds-grp-attr.corr-time          = v-time
    buf_c-gds-grp-attr.corr-user-db-num   = g#db-num
    buf_c-gds-grp-attr.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                             then (chr(4) +  'ВС':U)
                                             else g#userid)
                                        )
    buf_c-gds-grp-attr.corr-date          = v-date
    .
    create buf_c-gds-grp-hist.
    buffer-copy buf_c-gds-grp-attr to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.action =  p-action
    buf_c-gds-grp-hist.subject = 'gds-grp-attr':U
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    .
  end.
end procedure.
procedure gds-grph_write-gds-grp-obj-proc  :
define parameter buffer buf_gds-grp-obj for ub.gds-grp-obj .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-gds-grp-obj for ub.c-gds-grp-obj.
  do
  on error undo, return error
  :
    if not available buf_gds-grp-obj then do:
      undo, return error (vss-workfile + chr(32) + vss-revision + chr(32) + vss-description  + chr(10) +
                    "Ошибка задания входных параметров:Не определена группы товара на объекте" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-gds-grp-obj.
    buffer-copy buf_gds-grp-obj to buf_c-gds-grp-obj
    assign
    buf_c-gds-grp-obj.node-code          = buf_gds-grp-obj.node-code
    buf_c-gds-grp-obj.host-code          = buf_gds-grp-obj.host-code
    buf_c-gds-grp-obj.obj-type           = buf_gds-grp-obj.obj-type
    buf_c-gds-grp-obj.obj-code           = buf_gds-grp-obj.obj-code
    buf_c-gds-grp-obj.chip-num           = next-value (s-gds-grp-chip, ub)
    buf_c-gds-grp-obj.corr-time          = v-time
    buf_c-gds-grp-obj.corr-user-db-num   = g#db-num
    buf_c-gds-grp-obj.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                             then (chr(4) +  'ВС':U)
                                             else g#userid)
                                        )
    buf_c-gds-grp-obj.corr-date          = v-date
    .
    create buf_c-gds-grp-hist.
    buffer-copy buf_c-gds-grp-obj to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.action =  p-action
    buf_c-gds-grp-hist.subject = 'gds-grp-obj':U
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    .
  end.
end procedure.
procedure gds-grph_write-tax-rate-gds-grp-proc  :
define parameter buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp .
define input parameter p-action as integer no-undo .
define input parameter p-source-type like ub.c-gds-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-gds-hist.source-ref no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define buffer buf_c-tax-rate-gds-grp for ub.c-tax-rate-gds-grp.
  do
  on error undo, return error
  :
    if not available buf_tax-rate-gds-grp then do:
      undo, return error (vss-workfile + chr(32) + vss-revision + chr(32) + vss-description  + chr(10) +
                    "Ошибка задания входных параметров:Не определена группы товара на объекте" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-tax-rate-gds-grp.
    buffer-copy buf_tax-rate-gds-grp to buf_c-tax-rate-gds-grp
    assign
    buf_c-tax-rate-gds-grp.node-code          = buf_tax-rate-gds-grp.node-code
    buf_c-tax-rate-gds-grp.tax-code           = buf_tax-rate-gds-grp.tax-code
    buf_c-tax-rate-gds-grp.host-code          = buf_tax-rate-gds-grp.host-code
    buf_c-tax-rate-gds-grp.obj-type           = buf_tax-rate-gds-grp.obj-type
    buf_c-tax-rate-gds-grp.obj-code           = buf_tax-rate-gds-grp.obj-code
    buf_c-tax-rate-gds-grp.chip-num           = next-value (s-gds-grp-chip, ub)
    buf_c-tax-rate-gds-grp.corr-time          = v-time
    buf_c-tax-rate-gds-grp.corr-user-db-num   = g#db-num
    buf_c-tax-rate-gds-grp.corr-user-name     = (if g#news
                                        then (chr(4) +  'СПН':U)
                                        else (if g#esys
                                             then (chr(4) +  'ВС':U)
                                             else g#userid)
                                        )
    buf_c-tax-rate-gds-grp.corr-date          = v-date
    .
    create buf_c-gds-grp-hist.
    buffer-copy buf_c-tax-rate-gds-grp to buf_c-gds-grp-hist
    assign
    buf_c-gds-grp-hist.action =  p-action
    buf_c-gds-grp-hist.subject = 'tax-rate-gds-grp':U
    buf_c-gds-grp-hist.is-news = g#news
    buf_c-gds-grp-hist.source-type = p-source-type
    buf_c-gds-grp-hist.source-ref = p-source-ref
    .
  end.
end procedure.
define buffer b-gds-grp          for ub.gds-grp.
define buffer other_gds-grp      for ub.gds-grp.
define buffer buf_c-gds-grp      for ub.c-gds-grp.
define buffer buf_c-gds-grp-hist for ub.c-gds-grp-hist.
define variable name   as char    no-undo.
define variable uc     as int     no-undo.
define variable v-date as date    no-undo .
define variable v-time as integer no-undo .
define buffer buf_scales-grp   for ub.scales-grp.
define buffer buf2_scales-grp  for ub.scales-grp.
define buffer buf_fbr-prn-grp  for ub.fbr-prn-grp.
define buffer buf2_fbr-prn-grp for ub.fbr-prn-grp.
main-block:
do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    on delete of ub.tax-rate-gds-grp override
        do:
        end.
    on delete of ub.gds-grp-attr override
        do:
        end.
    on delete of ub.gds-grp-obj override
        do:
        end.
    on write of ub.tax-rate-gds-grp override
        do:
        end.
    on write of ub.gds-grp-attr override
        do:
        end.
    on write of ub.gds-grp-obj override
        do:
        end.
    on write of ub.goods override
        do:
        end.
    if not g#news and g#db-num > 0 then
    do:
        message
            vss-workfile vss-revision vss-description skip
            "Нельзя удалять запись ГРУППЫ ТОВАРОВ в УБД" skip
            "Номер текущей БД" g#db-num
            view-as alert-box error .
        undo main-block, return error .
    end.
    for each ub.gds-grp-attr where
        ub.gds-grp-attr.node-code = ub.gds-grp.node-code:
        run gds-grph_write-gds-grp-attr-proc   in this-procedure (
            buffer ub.gds-grp-attr
            ,integer('99':U)
            ,'grp-chg':U
            ,string(ub.gds-grp.node-code)
            ).
        delete ub.gds-grp-attr.
    end.
    for each ub.gds-grp-obj where
        ub.gds-grp-obj.node-code = ub.gds-grp.node-code:
        run gds-grph_write-gds-grp-obj-proc   in this-procedure (
            buffer ub.gds-grp-obj
            ,integer('99':U)
            ,'grp-chg':U
            ,string(ub.gds-grp.node-code)
            ).
        delete ub.gds-grp-obj.
    end.
    run grplib-get-full-name in this-procedure
        (input ub.gds-grp.upper-code
        ,output name
        ).
    for each ub.goods
        where ub.goods.grp-code = ub.gds-grp.node-code
        on error undo main-block, return error
        :
        run goodsh_write-goods-proc   in this-procedure (
            buffer ub.goods
            ,integer('2':U)
            ,'grp-chg':U
            ,string(ub.gds-grp.node-code)
            ).
        assign
            ub.goods.grp-code = ub.gds-grp.upper-code
            ub.goods.grp-name = name
            .
        for each ub.gds-obj
            where ub.gds-obj.artic     = ub.goods.artic
            and ub.gds-obj.prod-type = ub.goods.prod-type
            and ub.gds-obj.prod-code = ub.goods.prod-code
            :
            assign
                ub.gds-obj.grp-name = name
                .
        end.
    end.
    for each buf_scales-grp where
        buf_scales-grp.node-code = ub.gds-grp.node-code
        and buf_scales-grp.db-num = g#db-num
        on error undo main-block, return error return-value  :
        find first buf2_scales-grp no-lock where
            buf2_scales-grp.node-code = ub.gds-grp.upper-code
            and buf2_scales-grp.scales-num = buf_scales-grp.scales-num
            and buf2_scales-grp.db-num     = g#db-num  no-error.
        if available buf2_scales-grp then
        do:
        end.
        else
        do:
            create buf2_scales-grp.
            assign
                buf2_scales-grp.node-code  = ub.gds-grp.upper-code
                buf2_scales-grp.db-num     = buf_scales-grp.db-num
                buf2_scales-grp.scales-num = buf_scales-grp.scales-num
                .
        end.
        delete buf_scales-grp.
    end.
    for each buf_fbr-prn-grp where
        buf_fbr-prn-grp.node-code = ub.gds-grp.node-code
        and buf_fbr-prn-grp.db-num = g#db-num
        on error undo main-block, return error return-value  :
        find first buf2_fbr-prn-grp no-lock where
            buf2_fbr-prn-grp.node-code = ub.gds-grp.upper-code
            and buf2_fbr-prn-grp.db-num = buf_fbr-prn-grp.db-num
            and buf2_fbr-prn-grp.prn-num = buf_fbr-prn-grp.prn-num  no-error.
        if available buf2_fbr-prn-grp then
        do:
        end.
        else
        do:
            create buf2_fbr-prn-grp.
            buffer-copy buf_fbr-prn-grp
                except node-code to buf2_fbr-prn-grp
                assign
                buf2_fbr-prn-grp.node-code = ub.gds-grp.upper-code
                .
        end.
        delete buf_fbr-prn-grp.
    end.
    for each ub.tax-rate-gds-grp where
        ub.tax-rate-gds-grp.node-code = ub.gds-grp.node-code:
        run gds-grph_write-tax-rate-gds-grp-proc   in this-procedure (
            buffer ub.tax-rate-gds-grp
            ,integer('99':U)
            ,'grp-chg':U
            ,string(ub.gds-grp.node-code)
            ).
        delete ub.tax-rate-gds-grp.
    end.
    for each b-gds-grp
        where b-gds-grp.upper-code = ub.gds-grp.node-code
        :
        assign
            b-gds-grp.upper-code = ub.gds-grp.upper-code
            .
    end.
    find first b-gds-grp where
        b-gds-grp.node-code = ub.gds-grp.upper-code.
    if not can-find(first other_gds-grp no-lock where
        other_gds-grp.upper-code = b-gds-grp.node-code
        AND recid(other_gds-grp) <> recid(ub.gds-grp)) then
    do:
        assign
            b-gds-grp.is-term = yes
            .
    end.
    define variable v-synch-gds-grp as integer no-undo .
    assign
        v-synch-gds-grp = next-value(synch-gds-grp, ub)
        .
    run nws/cmd-del.p
        ( input 'gds-grp':U
        ,input (buffer ub.gds-grp:handle)
        ,input "":U
        ) no-error .
    if error-status :error then
    do:
        undo main-block, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, chr(10), return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
    if not g#news then
    do:
        run gds-grph_write-gds-grp-trigger in this-procedure (
            no
            ,"":U
            ,"":U
            , integer('99':U)
            ).
    end.
    if g#oxml = yes
        then
    do:
        run str/calloxml.p (
            input 'delete':U
            , input 'gds-grp':U
            , input ( buffer ub.gds-grp:handle )
            ) no-error.
        if error-status :error
            then
        do:
            undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                , chr(10)
                , vss-workfile
                , return-value
                , error-status :get-message ( 1 ) ).
        end.
    end.
    run trg/userlog.p (
        input 'delete':U
        , input 'gds-grp':U
        , input ( buffer ub.gds-grp :handle )
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
