block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prdocdel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/prdocdel.p $":U .
define variable vss-description as character no-undo init "Удаление незакрытых переоценок".
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
do
on error undo, return error return-value
:
  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.
define buffer buf_c-price-doc  for ub.c-price-doc  .
define buffer buf_c-price-list for ub.c-price-list  .
define buffer buf_c-price-list-attr for ub.c-price-list-attr  .
  on delete of ub.price-doc override do: end.
  define stream slog .
  define variable v-doc-code as character no-undo .
  run gbl/d-prompt.w (
      'title=':u + "Введите номер переоценки" + '\':u
    + 'text1=':u + "Введите номер переоценки" + '\':u
    + 'text2=':u + "которую необходимо удалить" + '\':u
    + 'format=X(14)\':u
    ,input-output v-doc-code
    ).
  if return-value = 'false':u then do:
    return .
  end.
  define buffer buf_price-doc for ub.price-doc .
  find first buf_price-doc no-lock
    where buf_price-doc.doc-num = v-doc-code
    no-error .
  if not available buf_price-doc then do:
    message
      "Переоценка не найдена" skip
      "Переоценка" v-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.
  if buf_price-doc.status_ = 'акт':U then do:
    message
      "Удаление невозможно" skip
      "Переоценка закрыта до статуса" 'акт':U skip
      "Переоценка" buf_price-doc.doc-num skip
      "Объект" buf_price-doc.obj-type buf_price-doc.obj-code skip
      "Статус" buf_price-doc.status_ skip
      view-as alert-box error .
    undo, return error .
  end.
  if buf_price-doc.status_ = 'разрешен':U then do:
    message
      "Переоценка находится в статусе" 'разрешен':U skip
      "Если товары на кассе заблокированы" skip
      "вам необходимо сделать повторную переоценку по всем товарам" skip
      "удаляемой переоценки" skip
      "Переоценка" buf_price-doc.doc-num skip
      "Объект" buf_price-doc.obj-type buf_price-doc.obj-code skip
      "Статус" buf_price-doc.status_ skip
      view-as alert-box information .
  end.
  define buffer buf_clients for ub.clients .
  find first buf_clients no-lock
    where buf_clients.obj-type = buf_price-doc.obj-type
      and buf_clients.obj-code = buf_price-doc.obj-code
    no-error .
  if available buf_clients
  and buf_clients.db-num <> 0 then do:
    message
      "Переоценка принадлежит удаленной базе данных" skip
      "Возможно переоценка уже была передана в офис" skip
      "Свящитесь с администратором ГБД и попросите его удалить данную переоценку в ГБД" skip
      "Переоценка" buf_price-doc.doc-num skip
      "Объект" buf_price-doc.obj-type buf_price-doc.obj-code skip
      "Статус" buf_price-doc.status_ skip
      "База данных" buf_clients.db-num skip
      view-as alert-box information .
  end.
  define variable v-ok as logical   no-undo .
  assign
    v-ok = false
  .
  message
    "Удаление переоценки" skip
    "Переоценка" buf_price-doc.doc-num skip
    "Объект" buf_price-doc.obj-type buf_price-doc.obj-code skip
    "Статус" buf_price-doc.status_ skip
    "Продолжить?"
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true then do:
    return .
  end.
  do transaction
  on error undo, return error
  :
    define buffer buf_price-list for ub.price-list  .
    for each buf_price-list exclusive-lock
      where buf_price-list.doc-num = buf_price-doc.doc-num
    :
      define buffer buf_gds-obj for ub.gds-obj .
      find first buf_gds-obj exclusive-lock
        where buf_gds-obj.obj-type  = buf_price-list.obj-type
          and buf_gds-obj.obj-code  = buf_price-list.obj-code
          and buf_gds-obj.artic     = buf_price-list.artic
          and buf_gds-obj.prod-type = buf_price-list.prod-type
          and buf_gds-obj.prod-code = buf_price-list.prod-code
        no-error .
    end.
    find current buf_price-doc exclusive-lock .
    output stream slog to value('prdocdel.txt':u) append .
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    export stream slog string(v-today, '99/99/9999') string(v-time, 'HH:MM:SS') "delete price-doc" buf_price-doc.doc-num .
    export stream slog buf_price-doc .
    output stream slog close .
   if buf_price-doc.status_ <> 'новый':U then do:
      create buf_c-price-doc.
      BUFFER-COPY buf_price-doc TO buf_c-price-doc
      assign
        buf_c-price-doc.chip-num           = next-value (s-corr-chip, ub)
        buf_c-price-doc.corr-time          = time
        buf_c-price-doc.corr-user-db-num   = g#db-num
        buf_c-price-doc.corr-man           = g#userid
        buf_c-price-doc.corr-date          = today
        buf_c-price-doc.is-del             = true
      .
   end.
    output stream slog to value('prdocdel.gds':u) .
    output stream slog close .
    for each buf_price-list exclusive-lock
      where buf_price-list.doc-num = buf_price-doc.doc-num
    :
      output stream slog to value('prdocdel.txt':u) append .
      export stream slog buf_price-list .
      output stream slog close .
      output stream slog to value('prdocdel.gds':u) append .
      export stream slog buf_price-list.prod-type buf_price-list.prod-code buf_price-list.artic 0 .
      output stream slog close .
      if buf_price-doc.status_ = 'разрешен':U then do:
        find first buf_gds-obj exclusive-lock
          where buf_gds-obj.obj-type  = buf_price-list.obj-type
            and buf_gds-obj.obj-code  = buf_price-list.obj-code
            and buf_gds-obj.artic     = buf_price-list.artic
            and buf_gds-obj.prod-type = buf_price-list.prod-type
            and buf_gds-obj.prod-code = buf_price-list.prod-code
          no-error .
        if available buf_gds-obj
        and buf_gds-obj.ov-on = true then do:
          assign
            buf_gds-obj.ov-on = false
          .
        end.
      end.
    if buf_price-doc.status_ <> 'новый':U then do:
      create buf_c-price-list.
      BUFFER-COPY buf_price-list TO buf_c-price-list
      assign
        buf_c-price-list.chip-num           = buf_c-price-doc.chip-num
        buf_c-price-list.corr-time           = time
        buf_c-price-list.corr-user-db-num    = g#db-num
        buf_c-price-list.corr-user-name     = g#userid
        buf_c-price-list.corr-date          = today
        buf_c-price-list.is-del             = true
      .
     end.
      delete buf_price-list .
    end.
    delete buf_price-doc .
    output stream slog to value('prdocdel.txt':u) append .
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    export stream slog string(v-today, '99/99/9999') string(v-time, 'HH:MM:SS') "finish delete price-doc" v-doc-code .
    output stream slog close .
  end.
  message
    "Переоценка успешно удалена" skip
    "Информация по удаленной переоценке выведена в файл" 'prdocdel.txt':u skip
    "Список товаров выведен в файл" 'prdocdel.gds':u skip
    view-as alert-box information .
end.
