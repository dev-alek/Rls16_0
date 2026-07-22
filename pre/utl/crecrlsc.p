block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: crecrlsc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/crecrlsc.p $":U .
define variable vss-description as character no-undo init "отправка по новостям запроса значения seq s-sclc-code и создания, на его основе, диапазона локальных весовых кодов".
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
on delete of ub.code-range override
do :
  define variable v-cmd     as character no-undo .
  define variable v-db-send as character no-undo .
  define buffer buf_db for ub.db .
  for each buf_db no-lock
    where buf_db.db-num > 0
  on error undo, return error :
    assign
      v-cmd = "dlcr" + chr(1) + string(code-range.range-type) + chr(1) + string(code-range.first-code)
    .
    if v-db-send = "":U then do:
      assign
        v-db-send = string( buf_db.db-num )
      .
    end.
    else do:
      assign
        v-db-send = v-db-send + chr(1) + string( buf_db.db-num )
      .
    end.
  end.
  if v-db-send <> "":U then do:
    run nws/cr-route.p ( input 'send-cmd':U, input v-cmd, input ?, input v-db-send ).
  end.
end.
do
on error undo, return error :
  define temp-table tmp-c-range no-undo like ub.code-range .
  define temp-table curr-seq-value no-undo
    field db-num    like ub.db.db-num
    field seq-value as   integer
    index pi db-num
    .
  define variable g#loq         as   logical               no-undo .
  define variable db-wait       as   character             no-undo .
  define variable max-seq-value as   integer               no-undo .
  define variable ind           as   integer               no-undo .
  define variable v-cmd     as character no-undo .
  define variable v-db-send as character no-undo .
  define stream info .
  define buffer buf_code-range  for ub.code-range .
  define buffer buf_db for ub.db .
  find first ub.sys-ctrl no-lock.
  if ub.sys-ctrl.db-num <> 0 then do:
    message "Запуск утилиты возможен только в ГБД."
            view-as alert-box ERROR.
    return error.
  end.
  if can-find( first ub.code-range where ub.code-range.range-type = 'sclc':U no-lock ) then do:
    message "БД уже содержит диапазон(ы) локальных весовых кодов." skip
            "Запуск утилиты невозможен."
            view-as alert-box ERROR.
    return error.
  end.
  if can-find( first ub.db where ub.db.db-num > 0 no-lock ) then do:
    for each ub.rep
      where ub.rep.doc-num = -27091997
    on error undo, return error :
      find curr-seq-value where curr-seq-value.db-num = ub.rep.gr no-error.
      if available curr-seq-value then do:
        if ub.rep.num <= curr-seq-value.seq-value then do:
          next.
        end.
      end.
      else do:
        create curr-seq-value.
      end.
      assign
        curr-seq-value.db-num    = ub.rep.gr
        curr-seq-value.seq-value = ub.rep.num
        .
    end.
  end.
  else do:
    message "Вы действительно ходите начать процедуру создания начального диапазона локальных весовых кодов?"
            view-as alert-box QUESTION buttons YES-NO update g#loq.
    if not g#loq then do:
      return.
    end.
    create curr-seq-value.
    assign
      curr-seq-value.db-num    = 0
      curr-seq-value.seq-value = current-value( s-sclc-code, ub )
      .
  end.
  assign
    max-seq-value = 0
    db-wait = ""
  .
  for each buf_db no-lock
     where buf_db.db-num >= 0
  on error undo, return error :
    if max-seq-value <> ? then do:
      find curr-seq-value where curr-seq-value.db-num = buf_db.db-num no-lock no-error.
    end.
    if not available curr-seq-value then do:
      assign
        max-seq-value = ?
        db-wait       = db-wait + " " + string( buf_db.db-num )
      .
    end.
    else do:
      if curr-seq-value.seq-value > max-seq-value then do:
        assign
          max-seq-value = curr-seq-value.seq-value
        .
      end.
    end.
  end.
  if can-find( first curr-seq-value no-lock ) then do:
    if max-seq-value = ? then do:
      message "Еще не собрана информация из УБД" db-wait skip
              "Дождаться сбора информации и запустить эту утилиту позже?"
              view-as alert-box QUESTION buttons YES-NO update g#loq.
      if g#loq then do:
        return.
      end.
      else do:
        run clear-temp-table.
      end.
    end.
    else do:
      assign
        ind = 999
      .
      do while max-seq-value >= ind :
        assign
          ind = ind + 1000
        .
      end.
      assign
        max-seq-value = ind
      .
      output stream info to "del-cdrg.inf" append page-size 0 .
      put stream info unformatted cur-time-string-sec() skip .
      output stream info close .
      for each ub.code-range
        where ub.code-range.first-code >= 100
          and ub.code-range.last-code  <= 100000
      on error undo, return error
      :
        if lookup( ub.code-range.range-type, 'sslc,bcgb,sclc,scgb,ssgb,pglc,ptlc':U ) <> 0 then do:
          output stream info to "del-cdrg.inf" append page-size 0 .
          put stream info unformatted "code-range delete:" skip .
          export stream info ub.code-range .
          output stream info close .
          delete ub.code-range.
        end.
      end.
      for each ub.code-range
        where ub.code-range.first-code < 100
          and ub.code-range.last-code  <= 100000
      on error undo, return error
      :
        if lookup( ub.code-range.range-type, 'sslc,bcgb,sclc,scgb,ssgb,pglc,ptlc':U ) <> 0 then do:
          create tmp-c-range.
          buffer-copy ub.code-range to tmp-c-range .
          delete ub.code-range.
        end.
      end.
      for each tmp-c-range
      on error undo, return error
      :
        output stream info to "del-cdrg.inf" append page-size 0 .
        put stream info unformatted "code-range.last-code -> 99 :" skip .
        create buf_code-range.
        buffer-copy tmp-c-range to buf_code-range
          assign
            buf_code-range.range-type = 'ptlc':U
            buf_code-range.last-code  = 99
        .
        if buf_code-range.db-num = -1
           or buf_code-range.stts <> "f"
        then do:
          run str/callnews.p
            (input "code-range"
            ,input (buffer buf_code-range:handle)
            ).
        end.
        export stream info tmp-c-range .
        output stream info close .
        delete tmp-c-range.
      end.
      for each ub.code-range
        where ub.code-range.first-code < 100000
          and ub.code-range.last-code  > 100000
      on error undo, return error
      :
        if lookup( ub.code-range.range-type, 'sslc,bcgb,sclc,scgb,ssgb,pglc,ptlc':U ) <> 0 then do:
          create tmp-c-range.
          buffer-copy ub.code-range to tmp-c-range .
          delete ub.code-range.
        end.
      end.
      for each tmp-c-range
      on error undo, return error
      :
        output stream info to "del-cdrg.inf" append page-size 0 .
        put stream info unformatted "code-range.first-code -> 100000 :" skip.
        create buf_code-range.
        buffer-copy tmp-c-range to buf_code-range
          assign
            buf_code-range.first-code = 100000
        .
        if buf_code-range.db-num = -1
           or buf_code-range.stts <> "f"
        then do:
          run str/callnews.p
            (input "code-range"
            ,input (buffer buf_code-range:handle)
            ).
        end.
        export stream info tmp-c-range .
        output stream info close .
        if tmp-c-range.first-code < 100 then do:
          output stream info to "del-cdrg.inf" append page-size 0 .
          put stream info unformatted "create code-range:" skip.
          create buf_code-range.
          assign
            buf_code-range.range-type = 'ptlc':U
            buf_code-range.PS         = "auto"
            buf_code-range.beg-date   = today
            buf_code-range.first-code = 1
            buf_code-range.last-code  = 99
            buf_code-range.db-num     = 0
            buf_code-range.stts       = "u":U
          .
          export stream info buf_code-range .
          output stream info close .
          run str/callnews.p
            (input "code-range"
            ,input (buffer buf_code-range:handle)
            ).
        end.
        delete tmp-c-range.
      end.
      create ub.code-range.
      assign
        ub.code-range.range-type = 'sclc':U
        ub.code-range.PS         = "локальный весовой код"
        ub.code-range.beg-date   = today
        ub.code-range.first-code = 100
        ub.code-range.last-code  = max-seq-value
        ub.code-range.db-num     = 0
        ub.code-range.stts       = "a":U
      .
      run str/callnews.p
        (input "code-range"
        ,input (buffer ub.code-range:handle)
        ).
      release ub.code-range.
      run clear-temp-table.
      for each ub.rep
        where ub.rep.doc-num = -27091997
      on error undo, return error :
        delete ub.rep.
      end.
      message "Начальный диапазон локальных весовых кодов создан."
              view-as alert-box information.
      return.
    end.
  end.
  if not can-find( first curr-seq-value no-lock ) then do:
    message "Вы действительно ходите начать процедуру создания начального диапазона локальных весовых кодов?"
            view-as alert-box QUESTION buttons YES-NO update g#loq.
    if not g#loq then do:
      return.
    end.
    for each buf_db no-lock
      where buf_db.db-num >= 0
    on error undo, return error :
      assign
        v-cmd = "get-seq" + chr(1) + "s-sclc-code" + chr(1) + ""
      .
      if v-db-send = "":U then do:
        assign
          v-db-send = string( buf_db.db-num )
        .
      end.
      else do:
        assign
          v-db-send = v-db-send + chr(1) + string( buf_db.db-num )
        .
      end.
    end.
    if v-db-send <> "":U then do:
      run nws/cr-route.p ( input 'send-cmd':U, input v-cmd, input ?, input v-db-send ).
    end.
    create ub.rep.
    assign
      ub.rep.doc-num = -27091997
      ub.rep.gr      = 0
      ub.rep.num     = current-value( s-sclc-code, ub )
    .
    message "Процедура создания начального диапазона локальных весовых кодов начата" skip
            "Необходимо обменяться новостями со всеми УБД." skip
            "После обмена запустите эти утилиты повторно."
            view-as alert-box information.
  end.
  run clear-temp-table.
end.
procedure clear-temp-table:
  for each curr-seq-value
  on error undo, return error :
    delete curr-seq-value.
  end.
end procedure.
