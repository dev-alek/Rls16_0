block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.pl-gds NEW BUFFER new_pl-gds OLD BUFFER old_pl-gds.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Триггер на запись pl-gds":U.
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
      p-vss-parameters = substitute('&1|&2|&3|&4'
                         , new_pl-gds.obj-type
                         , new_pl-gds.obj-code
                         , new_pl-gds.pl-code
                         , new_pl-gds.gds-code
                         )
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
main-block:
do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
  define variable v-l-ref     as logical no-undo.
  define variable v-l-rest    as logical no-undo.
  define variable v-db-num    like ub.db.db-num no-undo.
  define variable v-today     as date    no-undo .
  define variable v-time      as integer no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  define variable v-cli-qnty  as decimal no-undo .
  define variable v-sign      as decimal no-undo .
  define buffer buf_goods        for ub.goods .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_doc-pl       for ub.doc-pl .
  define buffer buf_c-pl-gds     for ub.c-pl-gds.
  define buffer buf_c-gds-hist   for ub.c-gds-hist.
  define buffer buf_c-plc-hist   for ub.c-plc-hist.
  define buffer buf_c-table-bind for ub.c-table-bind.
  buffer-compare new_pl-gds
    using PS
    gds-code
    max-qnty
    obj-code
    obj-type
    pl-code
    status_
    tolerance
    to old_pl-gds
    case-sensitive
    save result in v-l-ref.
  buffer-compare new_pl-gds
    using cli-qnty
    fact-qnty
    free-qnty
    cli-fact-qnty
    cli-free-qnty
    to old_pl-gds
    case-sensitive
    save result in v-l-rest.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  new_pl-gds.obj-type
  ,input  new_pl-gds.obj-code
  ,output v-db-num
  ) no-error .
  if error-status :error then
  do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
      "Ошибка при определении БД объекта товара на складском месте" skip
      "объект" new_pl-gds.obj-type new_pl-gds.obj-code skip
      view-as alert-box error.
    undo main-block, return error.
  end.
  find first buf_goods no-lock
    where buf_goods.gds-code = new_pl-gds.gds-code
    .
  if v-l-ref <> true then
  do:
    if g#db-num <> v-db-num
      and g#news <> yes
      then
    do:
      message
        vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
        "Нельзя изменять запись ТОВАРА НА СКЛАДСКОМ МЕСТЕ в БД, отличной от БД объекта" skip
        "Номер текущей БД " g#db-num skip
        "Номер БД объекта " v-db-num
        view-as alert-box error.
      undo, return error.
    end.
    run str/callnews.p
      ( input 'pl-gds':U
      ,input ( buffer new_pl-gds :handle )
      ).
  end.
  if v-l-rest <> true then
  do:
    if old_pl-gds.cli-free-qnty <> ?
      and new_pl-gds.cli-free-qnty = ?
      then
    do:
      undo, return error substitute( 'Ошибка в свободном количестве на месте хранения&1'
        + 'Товар &2&1'
        + 'Место хранения: &3 (&4 &5)&1'
        + 'Свободное кол-во: &7 (&6)&1'
        + 'Фактическое кол-во: &8 (&6)&1'
        ,chr(10)
        ,buf_goods.gds-code
        ,new_pl-gds.pl-code
        ,new_pl-gds.obj-type
        ,new_pl-gds.obj-code
        ,buf_goods.unit-cli
        ,new_pl-gds.cli-free-qnty
        ,new_pl-gds.cli-fact-qnty
        ).
    end.
    if new_pl-gds.free-qnty = new_pl-gds.fact-qnty
      and new_pl-gds.cli-free-qnty <> new_pl-gds.cli-fact-qnty
      then
    do:
      assign
        v-cli-qnty = 0.0
        .
      for each buf_doc-line no-lock
        where buf_doc-line.obj-type  = new_pl-gds.obj-type
        and buf_doc-line.obj-code  = new_pl-gds.obj-code
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.status_   <> 'факт':U
        ,first buf_doc-pl no-lock
        where buf_doc-pl.obj-type = buf_doc-line.obj-type
        and buf_doc-pl.obj-code = buf_doc-line.obj-code
        and buf_doc-pl.pl-code  = new_pl-gds.pl-code
        and buf_doc-pl.out-code = buf_doc-line.doc-code
        and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
        if lookup( buf_doc-line.ext-doc-type, 'ie,iv,im,re,rs,rv,vt':U ) > 0 then
        do:
          next.
        end.
        if lookup( buf_doc-line.ext-doc-type, 'ee,ep,es,we,ev,em,wm,eo':U ) > 0 then
        do:
          assign
            v-sign = -1.0
            .
        end.
        else
        do:
          assign
            v-sign = 1.0
            .
          if lookup( buf_doc-line.ext-doc-type, 'ie,re,rs,vt,vp,ap,mp,pc,iv,rv,im,io':U ) = 0 then
          do:
            undo, return error substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, buf_doc-line.ext-doc-type).
          end.
        end.
        if buf_doc-pl.doc-qnty = 0.0
          and buf_doc-pl.cli-doc-qnty <> 0.0
          then
        do:
          assign
            v-cli-qnty = v-cli-qnty + v-sign * buf_doc-pl.cli-doc-qnty
            .
        end.
      end.
      if new_pl-gds.cli-free-qnty <> new_pl-gds.cli-fact-qnty - v-cli-qnty then
      do:
        undo, return error substitute( 'Ошибка в свободном количестве на месте хранения&1'
          + 'Товар &2&1'
          + 'Место хранения: &3 (&4 &5)&1'
          + 'После документа: &7 (&6)&1'
          + 'Должно быть: &8 (&6)'
          ,chr(10)
          ,buf_goods.gds-code
          ,new_pl-gds.pl-code
          ,new_pl-gds.obj-type
          ,new_pl-gds.obj-code
          ,buf_goods.unit-cli
          ,new_pl-gds.cli-free-qnty
          ,new_pl-gds.cli-fact-qnty - v-cli-qnty
          ).
      end.
    end.
  end.
  if g#news <> true
    and v-l-ref <> true
    then
  do:
    run cur-time in this-procedure(output v-today, output v-time).
    create buf_c-pl-gds.
    buffer-copy old_pl-gds
      except
      obj-type
      obj-code
      gds-code
      pl-code
      to buf_c-pl-gds
      assign
      buf_c-pl-gds.gds-code           = new_pl-gds.gds-code
      buf_c-pl-gds.obj-type           = new_pl-gds.obj-type
      buf_c-pl-gds.obj-code           = new_pl-gds.obj-code
      buf_c-pl-gds.pl-code            = new_pl-gds.pl-code
      buf_c-pl-gds.chip-num           = next-value (s-plc-chip, ub)
      buf_c-pl-gds.corr-time          = v-time
      buf_c-pl-gds.corr-user-db-num   = g#db-num
      buf_c-pl-gds.corr-user-name     = g#userid
      buf_c-pl-gds.corr-date          = v-today
      .
    create buf_c-plc-hist.
    buffer-copy buf_c-pl-gds to buf_c-plc-hist
      assign
      buf_c-plc-hist.action = (if new new_pl-gds then integer('1':U) else integer('2':U))
      buf_c-plc-hist.subject = 'pl-gds':U
      buf_c-plc-hist.is-news = g#news
      .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  new_pl-gds.obj-type
  ,input  new_pl-gds.obj-code
  ,output v-host-code
  )  .
    create buf_c-gds-hist.
    buffer-copy buf_c-pl-gds
      except chip-num
      to buf_c-gds-hist
      assign
      buf_c-gds-hist.action = (if new new_pl-gds then integer('1':U) else integer('2':U))
      buf_c-gds-hist.subject = 'pl-gds':U
      buf_c-gds-hist.host-code = v-host-code
      buf_c-gds-hist.is-news = g#news
      buf_c-gds-hist.chip-num =   next-value (s-gds-chip, ub)
      buf_c-gds-hist.source-type = (if g#news then 'db':U else "":U)
      buf_c-gds-hist.source-ref = (if g#news then string(g#news-source-db) else "":U)
      .
    create buf_c-table-bind.
    assign
      buf_c-table-bind.chip-num-rec     = buf_c-gds-hist.chip-num
      buf_c-table-bind.chip-num-src     = buf_c-pl-gds.chip-num
      buf_c-table-bind.corr-user-db-num = buf_c-pl-gds.corr-user-db-num
      buf_c-table-bind.tbl-name-rec     = 'c-gds-hist':U
      buf_c-table-bind.tbl-name-src     = 'c-plc-hist':U
      buf_c-table-bind.is-news          = g#news
      buf_c-table-bind.corr-user-name   = g#userid
      buf_c-table-bind.subject          = 'pl-gds':U
      .
  end.
  if g#oxml = yes then
  do:
    run str/calloxml.p
      ( input 'update':U
      ,input 'pl-gds':U
      ,input ( buffer ub.pl-gds:handle )
      ) no-error.
    if error-status :error then
    do:
      undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
        , chr(10)
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) ).
    end.
  end.
  define variable v-is as logical no-undo .
  buffer-compare old_pl-gds to new_pl-gds
    case-sensitive save result in v-is .
  if  new new_pl-gds then v-is = yes .
  if v-is then
  do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input 'ref-event':U
  ,input  buffer old_pl-gds:handle
  ,input  buffer new_pl-gds:handle
  ,input ''
  ,input ''
  ) no-error .
    if error-status :error
      then
    do:
      return error substitute( "&2&1Ошибка маршрутизации записи в машину правил&1&3&1&4"
        , chr(10)
        , vss-workfile
        , return-value
        , error-status :get-message ( 1 ) ).
    end.
  end.
end.
