using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 12 набор правил 5".
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
define  variable garbcoll_ii as integer no-undo .
define  temp-table temp-gc no-undo
field ii as integer
field obj-r as handle
field cn as character
index pi is unique primary
ii
index icn
cn.
procedure garbcoll_create-gc-entry :
define input parameter p-cn as character no-undo .
define input parameter p-obj-r as handle no-undo .
  do
  on error undo, return error
  :
    create temp-gc.
    assign
    temp-gc.ii = garbcoll_ii
    garbcoll_ii = garbcoll_ii + 1
    temp-gc.cn = p-cn
    temp-gc.obj-r = p-obj-r
    .
  end.
end procedure.
procedure garbcoll_clear :
  do
  on error undo, return error
  :
    for each temp-gc:
      delete object temp-gc.obj-r.
      delete temp-gc.
    end.
  end.
end procedure.
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
define new global shared variable g#lib-nws as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info4 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info4, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info4, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info4 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info4, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info4, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info4, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info4, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info4, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info4, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info4 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info4, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info4 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info4 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info4, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info4, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define SHARED temp-table temp-cmd no-undo
field cmd-code as integer
field db-list as character
index pi is unique primary
db-list
index icmd
cmd-code
.
define SHARED temp-table temp-smart-route no-undo
field key-field as character
field db-num as integer
index pi is unique primary
key-field
db-num
.
define SHARED temp-table temp-no-route no-undo
field rec-ord as integer
field db-num as integer
index pi is unique primary
db-num
rec-ord
index iro
rec-ord
.
define SHARED temp-table temp-smart-link no-undo
field uniq-key-rec as character
field key-field as character
field rec-ord as integer
field is-smart as logical
index pi is unique primary
key-field
uniq-key-rec
rec-ord
index iu
uniq-key-rec
index iro
rec-ord
.
define SHARED temp-table temp-nws-outline no-undo
like ub.nws-outline.
procedure create-smart-route :
define input parameter p-key-field as character no-undo .
define input parameter p-db-num as integer no-undo .
define buffer buf_temp-smart-route for temp-smart-route.
  do
  on error undo, return error
  :
    find first buf_temp-smart-route where
              buf_temp-smart-route.key-field = p-key-field
          and buf_temp-smart-route.db-num = p-db-num no-error.
    if not available buf_temp-smart-route then do:
      create buf_temp-smart-route.
      assign
      buf_temp-smart-route.key-field = p-key-field
      buf_temp-smart-route.db-num = p-db-num
      .
    end.
  end.
end procedure.
procedure create-smart-route-link :
define input parameter p-tbl-name as character no-undo .
define input parameter p-bh_tbl-name as handle no-undo .
define input parameter p-key-field as character no-undo .
define input parameter p-rec-ord as integer no-undo .
define input parameter p-is-smart as logical no-undo .
define variable v-key-rec as character no-undo .
define buffer buf_temp-smart-link for temp-smart-link.
  do
  on error undo, return error
  :
    run gen-key-rec in this-procedure ( input p-tbl-name
                                       ,input p-bh_tbl-name
                                       ,output v-key-rec     ).
   find first buf_temp-smart-link where
              buf_temp-smart-link.uniq-key-rec = v-key-rec
           and buf_temp-smart-link.key-field = p-key-field
           and buf_temp-smart-link.rec-ord = p-rec-ord
           no-error .
   if not available buf_temp-smart-link then do:
     create buf_temp-smart-link.
     assign
     buf_temp-smart-link.uniq-key-rec = v-key-rec
     buf_temp-smart-link.key-field = p-key-field
     buf_temp-smart-link.rec-ord = p-rec-ord
     buf_temp-smart-link.is-smart = p-is-smart
     .
   end.
  end.
end procedure.
procedure create-nws-outline :
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code as integer no-undo .
define input parameter p-outline-type as character no-undo .
define input parameter p-charkey_one as character no-undo .
define input parameter p-charkey_two as character no-undo .
define input parameter p-charkey_three as character no-undo .
define input parameter p-key#_one as integer no-undo .
define input parameter p-key#_two as integer no-undo .
define input parameter p-key#_three as integer no-undo .
define variable v-no-id as integer no-undo .
define variable v-rec-ord as integer no-undo .
  do
  on error undo, return error return-value
  :
    find last temp-nws-outline use-index pi no-error .
    v-no-id = (if available temp-nws-outline
               then (temp-nws-outline.no-id  + 1)
               else 1).
    create temp-nws-outline.
    assign
    temp-nws-outline.charkeY_one = p-charkey_one
    temp-nws-outline.charkeY_two = p-charkey_two
    temp-nws-outline.charkeY_three = p-charkey_three
    temp-nws-outline.key#_one = p-key#_one
    temp-nws-outline.key#_two = p-key#_two
    temp-nws-outline.key#_three = p-key#_three
    temp-nws-outline.no-id = v-no-id
    temp-nws-outline.outline-type = p-outline-type
    .
                                run add-dump in p-cmd-proc-handle                                                                           (input p-cmd-code                                                                                         ,input 'nws-outline':U                                                                                          ,input '+update'                                                                                         ,input (buffer temp-nws-outline:handle)                                                                                    ,input ''                                                                                         ,output v-rec-ord                                                                                         ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure p-cmd-proc-handle .                                                                        undo , return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'nws-outline':U                                                                                                ,p-cmd-code                                                                                               ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    run  create-smart-route in this-procedure (
                                                input ('nws-outline':U + chr(4) + string(temp-nws-outline.no-id))
                                               ,input -1).
    run create-smart-route-link in this-procedure (
                                                   input 'nws-outline':U
                                                  ,input (buffer temp-nws-outline:handle)
                                                  ,input ('nws-outline':U + chr(4) + string(temp-nws-outline.no-id))
                                                  ,input v-rec-ord
                                                  ,input no
                                                  ).
  end.
end procedure.
procedure create-no-route :
define input parameter p-rec-ord as integer no-undo .
define input parameter p-db-num as integer no-undo .
define buffer buf_temp-no-route for temp-no-route.
do
on error undo, return error
:
   find first buf_temp-no-route where
              buf_temp-no-route.rec-ord = p-rec-ord
           and buf_temp-no-route.db-num = p-db-num no-error .
   if not available buf_temp-no-route then do:
     create buf_temp-no-route.
     assign
     buf_temp-no-route.rec-ord = p-rec-ord
     buf_temp-no-route.db-num = p-db-num
     .
   end.
end.
end procedure.
procedure clear-from-rec-ord :
define input parameter p-rec-ord as integer no-undo .
define buffer buf_temp-no-route for temp-no-route.
define buffer buf_temp-smart-link for temp-smart-link.
do
on error undo, return error
:
for each buf_temp-no-route where
        buf_temp-no-route.rec-ord > p-rec-ord:
  delete buf_temp-no-route.
end.
for each buf_temp-smart-link where
        buf_temp-smart-link.rec-ord > p-rec-ord:
   delete buf_temp-smart-link.
end.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table temp-hist-nws-option no-undo
like ub.hist-nws-option
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure library-cls_get-handle :
define input parameter p-library-name as character no-undo .
define output parameter p-library-handle as handle no-undo .
  do
  on error undo, return error
  :
    CASE p-library-name:
      when "library" then do:
        if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
        p-library-handle = g#library.
      end.
      when "library2" then do:
        if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.
        p-library-handle = g#library2.
      end.
    end case.
  end.
end procedure.
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define shared temp-table temp-xml-tables no-undo
field order as integer
field tbl-name as character
field tbl-handle_ as handle
field table-handle_ as handle
field uniq-gate-rec as character
field gate-name as character
field gate-handle_ as handle
field is-parent as logical
index pi is unique primary
uniq-gate-rec
tbl-name
index iorder
order
index gr
uniq-gate-rec
index gh
gate-handle_
index iparent
is-parent
.
define shared temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-gate-file-name :
define input parameter p-gate-rec as character no-undo .
define output  parameter p-gate-file-name as character no-undo .
define buffer buf_clob-data for ub.clob-data.
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
run gen-row-keyr in this-procedure ( input p-gate-rec
                                    ,input ?
                                    ,input "ub"
                                    ,input ?
                                    ,input no-lock
                                    ,output v-tbl-row
                                    ,output v-tbl-name) no-error.
if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                        ,vss-include-info9
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info9
                                                          ,p-gate-rec).
end.
p-gate-file-name = buf_clob-data.file-name.
end procedure.
procedure get-gate-rec :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info9 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info9 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
end.
end procedure.
procedure get-gate-by-name :
define input  parameter p-gate-name as character no-undo .
define output parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define variable v-db-num as integer no-undo .
define variable v-int64-id as int64 no-undo .
define buffer buf_clob-bind for ub.clob-bind.
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info9 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info9 )
:
    find first buf_clob-bind no-lock where
              buf_clob-bind.uniq-key-rec = p-gate-name
          and buf_clob-bind.field-name = '':U
          and buf_clob-bind.part-num = 1
          and buf_clob-bind.resource-type = 'gate':U
          no-error.
    if not available buf_clob-bind then do:
      undo, return error substitute("Неверная ссылка на XSD -файл &1 для gate"
                                      , p-gate-name
                                      ).
    end.
    find first buf_clob-data no-lock where
              buf_clob-data.db-num = buf_clob-bind.db-num
          and buf_clob-data.int64-i= buf_clob-bind.int64-id no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB c ДБ &1 id &2 - файл &3"
                                      , buf_clob-bind.db-num
                                      , buf_clob-bind.int64-id
                                      , p-gate-name
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 из БД:&2&3", p-gate-name, chr(10), error-status:get-message(1) ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    run gen-key-rec in this-procedure ( input 'clob-data':U
                              ,input buffer buf_clob-data:handle
                              ,output p-gate-rec).
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
      end.
    end.
end.
end procedure.
procedure get-gate-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define input-output parameter p-longchar  as longchar no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info9 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info9 )
:
  run gen-row-keyr in this-procedure (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1) .
    if p-longchar <> ? then do:
      p-longchar = v-longchar.
    end.
    v-longchar = '':U.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                   , p-gate-rec
                                   , p-gate-rec
                                   , v-esm
                                   ).
    end.
    p-dsh:private-data = buf_clob-data.file-name_ + chr(4) + p-gate-rec.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure get-gate-by-file :
define input  parameter p-schema-file-name as character no-undo .
define input  parameter p-gate-rec as character no-undo .
define output parameter p-dsh as handle no-undo .
define input-output  parameter p-xmlh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info9 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info9 )
:
    COPY-LOB
    FROM  FILE p-schema-file-name
    TO  OBJECT v-longchar
    no-convert
    NO-ERROR .
    if error-status :error then do:
        undo, return error substitute("Не удалось считать файл схемы &1 в память&2&3"
                                  , p-schema-file-name
                              , chr(10)
                              , error-status:get-message(1) ).
    end.
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, p-schema-file-name, chr(10), error-status:get-message(1) , return-value ).
    end.
    create dataset p-dsh .
    glog = p-dsh:READ-XMLSCHEMA( "longchar"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = ''.
    if error-status :error
    or not glog
    then do:
      undo, return error substitute("Не удалось прочитать XML-схему из файла &1&2&3"
                                   , p-schema-file-name
                                   ,chr(10)
                                   , error-status:get-message(1)
                                   ).
    end.
    if not valid-handle(p-xmlh)
    or not valid-handle(p-xmlh:buffer-field("tbl-name")) then do:
      create temp-table v-txmlh.
      v-txmlh:create-like(buffer temp-xml-tables:handle).
      v-txmlh:temp-table-prepare("temp-xml-tables").
      p-xmlh = v-txmlh:default-buffer-handle.
    end.
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1" and  uniq-gate-rec = "&2" '
                                   ,p-dsh:get-buffer-handle(v-ii):name
                                   ,p-gate-rec
                                   )) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):table
        p-xmlh::uniq-gate-rec = p-gate-rec
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
end.
end procedure.
procedure gate-clear :
define input  parameter p-dsh as handle no-undo .
define input  parameter p-xmlh as handle no-undo .
define variable v-dsh as handle no-undo .
define variable v-th as handle no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-dsh) then do:
      delete object p-dsh.
      v-dsh = p-dsh.
      p-dsh = ?.
    end.
    repeat while true:
      p-xmlh:find-first( substitute( " where gate-handle_ = &1 ", v-dsh)
                         , share-lock) no-error.
      if p-xmlh:available then do:
        assign
        v-th = p-xmlh:buffer-field("table-handle_"):buffer-value.
        if valid-handle(p-xmlh:buffer-field("table-handle_"))
        and valid-handle(v-th)
        and v-th:dynamic = yes
        then do:
          delete object p-xmlh:buffer-field("table-handle_"):buffer-value.
          p-xmlh:buffer-field("table-handle_"):buffer-value = ?.
        end.
        p-xmlh:buffer-delete().
      end.
      else do:
        leave.
      end.
    end.
    if p-xmlh:dynamic = yes
    and valid-handle(p-xmlh)
    then do:
      delete object p-xmlh:table-handle.
      p-xmlh = ?.
    end.
    v-dsh = ?.
  end.
end procedure.
procedure all-gates-clear :
define parameter buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
      if first-of(buf_temp-xml-tables.uniq-gate-rec) then do:
        delete object buf_temp-xml-tables.gate-handle_.
        buf_temp-xml-tables.gate-handle_ = ?.
      end.
      if valid-handle(buf_temp-xml-tables.table-handle_)
      and buf_temp-xml-tables.table-handle_:dynamic = no
      then do:
        delete object buf_temp-xml-tables.table-handle_.
        buf_temp-xml-tables.table-handle_ = ?.
      end.
      delete buf_temp-xml-tables.
  end.
end.
end procedure.
procedure fix-schemalocation :
define input-output  parameter p-longchar as longchar no-undo .
DEFINE VARIABLE hdoc AS HANDLE.
DEFINE VARIABLE hroot AS HANDLE.
DEFINE VARIABLE hnode-child AS HANDLE.
DEFINE VARIABLE hnode-attr AS HANDLE.
define variable v-jj as integer   no-undo .
define variable ok as logical   no-undo .
define variable v-path1                    as character                no-undo .
DEFINE VARIABLE v-full-path1               as character                no-undo .
DEFINE VARIABLE v-file-name1               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext1        as character                no-undo .
DEFINE VARIABLE v-file-name-ext1           as character                no-undo .
define variable v-schema-location          as character                no-undo .
do
on error undo, return error return-value
:
  CREATE X-DOCUMENT hdoc.
  CREATE X-noderef hroot.
  CREATE X-noderef hnode-child.
  CREATE X-noderef hnode-attr.
  hdoc:load("longchar", p-longchar, no) no-error.
  iF ERROR-STATUS:GET-MESSAGE(1) <> '' THEN message ERROR-STATUS:GET-MESSAGE(1) view-as alert-box .
  hdoc:get-document-element(hroot).
  _repeat:
  REPEAT v-jj = 1 TO hroot:NUM-CHILDREN:
    ok = hroot:GET-CHILD(hNode-Child, v-jj).
    if not ok then next.
    if hNode-Child:local-name = "include"
    then do:
      ok = hNode-Child:GET-ATTRIBUTE-NODE( hnode-attr, "schemaLocation" ).
        v-schema-location = hnode-attr:node-value.
        run gbl/filename.p (
                        input "exe/" + hnode-attr:node-value
                      ,output v-full-path1
                      ,output v-path1
                      ,output v-file-name1
                      ,output v-file-name-no-ext1
                      ,output v-file-name-ext1
                      ) no-error .
        if error-status :error then do:
          delete object hnode-attr.
          delete object hnode-child.
          delete object hroot.
          delete object hdoc.
          undo, return error substitute("Не удалось определить расположение схемы &1", v-schema-location).
        end.
      ok = hNode-Child:sET-ATTRIBUTE(  "schemaLocation", v-full-path1 ).
      leave  _repeat.
    end.
  END.
  hdoc:save("longchar", p-longchar).
  delete object hnode-attr.
  delete object hnode-child.
  delete object hroot.
  delete object hdoc.
end.
end procedure.
procedure gate-clb_fill-xml-tables :
define input parameter p-dsh as handle no-undo .
define input-output parameter p-xmlh as handle no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error
  :
    do v-ii = 1 to p-dsh:num-buffers:
      p-xmlh:find-first(substitute(' where tbl-name = "&1"', p-dsh:get-buffer-handle(v-ii):name)) no-error.
      if not p-xmlh:available then do:
        p-xmlh:buffer-create().
        assign
        p-xmlh::tbl-name = p-dsh:get-buffer-handle(v-ii):name
        p-xmlh::tbl-handle_ = p-dsh:get-buffer-handle(v-ii)
        p-xmlh::table-handle_ = p-dsh:get-buffer-handle(v-ii):table-handle
        p-xmlh::gate-handle_ = p-dsh
        p-xmlh::uniq-gate-rec = entry(2, p-dsh:private-data, chr(4))
        p-xmlh::gate-name = p-dsh:name
        p-xmlh::is-parent = not valid-handle(p-dsh:get-buffer-handle(v-ii):parent-relation)
        .
        if lookup(p-xmlh::tbl-name, "thheader,header_") > 0 then do:
          assign
          p-xmlh::order = -3.
        end.
        p-xmlh:buffer-release().
      end.
    end.
  end.
end procedure.
procedure all-gates-empty :
define buffer buf_temp-xml-tables for temp-xml-tables.
do
on error undo, return error
:
  for each buf_temp-xml-tables
  break
  by buf_temp-xml-tables.uniq-gate-rec
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    if valid-handle(buf_temp-xml-tables.tbl-handle_) then do:
      buf_temp-xml-tables.tbl-handle_:empty-temp-table().
    end.
  end.
end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table THpck-sent no-undo
field THfilename as character field THcrc-pack as character field THcredate as date field THcrenum as integer  field THcretimeint as integer field THcretime as character   field THrcvddate  as date field THpack-num  as integer  field THrcvdtimeint as integer field THrcvdtime  as character   field THrcvd  as logical      field THsendtxtdate as date field THsendtxttimeint as integer field THsendtxttime as character  field THtotal-recs  as integer  field THesys-id  as integer     index pi is unique primary THesys-id                  THpack-num                 index ircvd                THesys-id                  THrcvd
.
define temp-table THcurr-pack no-undo
field THfilename as character field THcrc-pack as character field THcredate as date field THcrenum as integer  field THcretimeint as integer field THcretime as character   field THrcvddate  as date field THpack-num  as integer  field THrcvdtimeint as integer field THrcvdtime  as character   field THrcvd  as logical      field THsendtxtdate as date field THsendtxttimeint as integer field THsendtxttime as character  field THtotal-recs  as integer  field THesys-id  as integer     index pi is unique primary THesys-id                  THpack-num                 index ircvd                THesys-id                  THrcvd
.
define temp-table THpck-rcvd no-undo
field THfilename as character
field THesys-id  as integer
field THcrc-pack as character
field THpack-num  as integer
field THrcvd-recs  as integer
field THrcvd as logical
field THtotal-recs  as integer
field THrcvddate  as date
field THrcvdtimeint as integer
field THrcvdtime  as character
index pi is unique primary
THesys-id
THpack-num
index rcvd
THesys-id
THrcvd
.
procedure get-header-by-rec :
define input  parameter p-gate-rec as character no-undo .
define output parameter p-tth as handle no-undo .
define variable v-ii as integer   no-undo .
define variable glog as logical   no-undo .
define variable v-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-longchar as longchar no-undo .
define variable v-txmlh as handle no-undo .
define buffer buf_clob-data for ub.clob-data.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info12, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info12 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info12 )
:
  run gen-row-keyr in  this-procedure  (
                                        input  p-gate-rec
                                        ,input  ?
                                        ,input  "ub"
                                        ,input  ?
                                        ,input  NO-LOCK
                                        ,output v-rowid
                                        ,output v-tbl-name   ) no-error.
    find first buf_clob-data no-lock where
              rowid(buf_clob-data) = v-rowid  no-error.
    if not available buf_clob-data then do:
      undo, return error substitute("Не найден CLOB  &1"
                                      , p-gate-rec
                                      ).
    end.
    assign
    v-longchar = buf_clob-data.cdata
    .
    run fix-schemalocation in this-procedure ( input-output v-longchar) no-error.
    if error-status :error then do:
      undo, return error substitute("Не удалось определить расположение составных частей схемы &1 (&2) из БД&3&4&3&5", p-gate-rec, buf_clob-data.file-name_, chr(10), error-status:get-message(1) , return-value ).
    end.
    create temp-table p-tth .
    glog = p-tth:READ-XMLSCHEMA( "LONGCHAR"
                                  , v-longchar
                                  , ?
                                  , ?
                                  , ?
                                  ) no-error.
    v-longchar = '':U.
    define variable v-esm as character no-undo .
    v-esm = error-status:get-message(1).
    if error-status :error
    or not glog
    then do:
      delete object p-tth no-error.
      undo, return error substitute("Не удалось прочитать XML-схему &1 (&2) из БД&3&4"
                                 , p-gate-rec
                                 , buf_clob-data.file-name_
                                 , chr(10)
                                 , v-esm
                                  ).
    end.
end.
end procedure.
// { bge/getoxmlh.i } 23/VIII-2018 xmllib.i и tmpcxmlh.i вставлены напрямую
define variable vss-include-info13 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define stream stmXMLOut.
define stream stmXMLLog.
define stream strXMLIn.
define temp-table temp_xmllib_rec-list no-undo
    field recName       as character
    field recLevel      as integer
    field recOpenLine   as integer
    field recCloseLine  as integer
    field closed        as logical
    index pi is primary unique
        recName
        recLevel
    index cl
        closed
.
define temp-table temp_xmllib_rec-fld-list no-undo
    field recName       as character
    field recLevel      as integer
    field fldName       as character
    field fldOpenLine   as integer
    field fldCloseLine  as integer
    field closed        as logical
    index pi is primary unique
        recName
        recLevel
        fldName
    index fn
        fldName
    index cl
        closed
.
define temp-table temp_xmllib_rec no-undo
    field rec-key       as integer
    field recLevel      as integer
    field recOpenLine   as integer
    field recCloseLine  as integer
    field recName       as character
    field closed        as logical
    index pi is primary unique
        rec-key
    index nm
        recName
        closed
        rec-key
    index cl
        closed
    index rlv
        recName
        recLevel
        closed
        rec-key
.
define temp-table temp_xmllib_rec-fld no-undo
    field fld-key       as integer
    field rec-key       as integer
    field fldOpenLine   as integer
    field fldCloseLine  as integer
    field fldName       as character
    field fldValue      as character
    field closed        as logical
    index pi is primary unique
        fld-key
    index nm
        rec-key
        fldName
        closed
        fld-key
    index cl
        closed
.
define variable v-xmllib-rec-key            as integer      no-undo .
define variable v-xmllib-rec-fld-key        as integer      no-undo .
define variable v-xmllib-dirname            as character    no-undo .
define variable v-xmllib-filename           as character    no-undo .
define variable v-xmllib-log-filename       as character    no-undo .
define variable v-xmllib-log-handle         as handle       no-undo .
define variable v-xmllib-log-proc-name      as character    no-undo .
define variable v-xmllib-error-status       as logical      no-undo .
define variable v-xmllib-sax-reader-handle  as handle       no-undo .
define variable v-xmllib-prg-bar-handle     as handle       no-undo .
define variable v-xmllib-codepage-convert   as logical      no-undo .
define variable v-xmllib-codepage-source    as character    no-undo .
define variable v-xmllib-codepage-target    as character    no-undo .
procedure xmllib-clear-parse-data :
do
on error undo, return error
:
    empty temp-table temp_xmllib_rec-list.
    empty temp-table temp_xmllib_rec-fld-list.
    empty temp-table temp_xmllib_rec.
    empty temp-table temp_xmllib_rec-fld.
end.
end procedure.
procedure xmllib-add-rec-fld :
define input parameter p-rec-name       as character        no-undo.
define input parameter p-rec-fld-name   as character        no-undo.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    find first buf_rec-list
         where buf_rec-list.recName = p-rec-name
    no-error.
    if not available buf_rec-list
    then do:
        create buf_rec-list.
        assign
            buf_rec-list.recName        = p-rec-name
            buf_rec-list.recOpenLine    = 0
            buf_rec-list.recCloseLine   = 0
            buf_rec-list.closed         = yes
        .
    end.
    find first buf_rec-fld-list
         where buf_rec-fld-list.recName = p-rec-name
           and buf_rec-fld-list.fldName = p-rec-fld-name
    no-error.
    if not available buf_rec-fld-list
    then do:
        create buf_rec-fld-list.
        assign
            buf_rec-fld-list.recName        = p-rec-name
            buf_rec-fld-list.fldName        = p-rec-fld-name
            buf_rec-fld-list.fldOpenLine    = 0
            buf_rec-fld-list.fldCloseLine   = 0
            buf_rec-fld-list.closed         = yes
        .
    end.
end.
end procedure.
procedure xmllib-tag-open:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.
do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( "&1&2<&3&4&5>"
            , chr(10)
            , fill(" ", 4 * v-tag-level)
            , v-tag-name
            , ( if v-tag-value = "":U or v-tag-value = ? then "":U else " ":U )
            , v-tag-value
        )
    .
end.
end procedure.
procedure xmllib-tag-put:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.
do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "":U and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "":U and v-tag-value <> ? and v-tag-value <> "0":U))
    or (v-empty-mode = 3 and (v-tag-value <> "":U and v-tag-value <> ? and caps(v-tag-value) <> "no":U))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            substitute( "&1&2<&3>&4</&3>"
                , chr(10)
                , fill(" ":U, 4 * v-tag-level)
                , v-tag-name
                , v-tag-value
            )
        .
    end.
end.
end procedure.
procedure xmllib-tag-put-null :
define input parameter p-tag-level  as integer      no-undo.
define input parameter p-tag-name   as character    no-undo.
do
on error undo, return error
:
    assign
        p-tag-name = trim( p-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( '&1&2<&3 nil="true" /&3>'
            , chr(10)
            , fill(" ":U, 4 * p-tag-level)
            , p-tag-name
        )
    .
end.
end procedure.
procedure xmllib-tag-close:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.
do
on error undo, return error
:
    assign
        v-tag-name = trim( v-tag-name )
    .
    put stream stmXMLOut unformatted
        substitute( "&1&2</&3>"
            , chr(10)
            , fill( " ":U, 4 * v-tag-level)
            , v-tag-name
        )
    .
end.
end procedure.
procedure xmllib-write-log:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.
do
on error undo, return error
:
    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        chr(10)
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine":U
          or v-out-string = "&Line":U
          then "":U
          else cur-time-string-sec() + " ":U )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line":U
          then fill( "-":U, 80 )
          else if v-out-string = "&DLine":U
               then fill( "=":U, 80 )
               else v-out-string )
    .
    output stream stmXMLLog close.
end.
end procedure.
procedure xmllib-write-edt:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.
do
on error undo, return error
:
    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine":U
                                          or v-out-string = "&Line":U
                                          then "":U
                                          else cur-time-string-sec() + " ":U
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line":U
                                          then fill( "-":U, 80 )
                                          else if v-out-string = "&DLine":U then fill("=":U, 80)
                                          else fill( " ":U, v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( chr(10) ).
    end.
end.
end procedure.
procedure xmllib-show-cnt:
define input parameter v-fillin-handle     as handle   no-undo.
do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :visible = true
        .
    end.
end.
end procedure.
procedure xmllib-hide-cnt:
define input parameter v-fillin-handle     as handle   no-undo.
do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign v-fillin-handle :visible = false.
    end.
end.
end procedure.
procedure xmllib-write-cnt:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.
do
on error undo, return error
:
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.
procedure xmllib-write-header:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.
    define variable v-counter    as integer        no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run xmllib-tag-open( input 0, input "root"          , input "":U ).
    run xmllib-tag-open( input 0, input "THheader"        , input "":U ).
    run xmllib-tag-put( input 1 , input "THfileName"      , input p-xml-file-name + "xml":U  , input 0 ).
    run xmllib-tag-put( input 1 , input "THfileNumber"    , input string( p-file-number     ), input 0 ).
    run xmllib-tag-put( input 1 , input "THhavePrev"      , input string( p-have-prev       ), input 3 ).
    run xmllib-tag-put( input 1 , input "THprevFileName"  , input p-prev-filename            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run xmllib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run xmllib-tag-close( input 0, input "THheader" ).
    output stream stmXMLOut close.
    if p-list-file-name <> "":U
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
        if p-first-file = yes
        then do:
            put stream stmXMLOut unformatted
                "<?xml version='1.0' encoding='windows-1251'?>"
            .
            run xmllib-tag-open( input 0, input "OpenXML", input "" ).
        end.
        run xmllib-tag-open( input 1, input "THfile", input "" ).
        run xmllib-tag-put( input 2, input "THfileName"       , input p-xml-file-name + "xml":U  , input 0 ).
        run xmllib-tag-put( input 2, input "THfileNumber"     , input string( p-file-number     ), input 0 ).
        run xmllib-tag-put( input 2, input "THhavePrev"       , input string( p-have-prev       ), input 3 ).
        run xmllib-tag-put( input 2, input "THprevFileName"   , input p-prev-filename            , input 0 ).
        do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
        :
            run xmllib-tag-put(
                input 2
                , input entry( 2 * v-counter, p-parameter-list )
                , input entry( 2 * v-counter + 1, p-parameter-list )
                , input 0
            ).
        end.
        run xmllib-tag-close( input 1, input "THfile" ).
        output stream stmXMLOut close.
    end.
end.
end procedure.
procedure xmllib-write-footer:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.
    define variable v-error-num     as integer           no-undo.
do
on error undo, return error
:
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run xmllib-tag-open( input 0, input "footer", "" ).
        run xmllib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run xmllib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run xmllib-tag-close( input 0, input "footer" ).
    end.
    run xmllib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + "tmp"
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    and p-list-file-name <> "":U
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
            run xmllib-tag-close( input 0, input "OpenXML" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + "tmp"
            , input p-list-file-name + "xml":U
            , output v-error-num
        ).
    end.
end.
end procedure.
procedure xmllib-filename :
define input parameter p-subdir             as character        no-undo.
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.
    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.
do
on error undo, return error
:
    get-key-value section "OXML" key "oxml-dir" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip "Нет параметра oxml-dir в секции [OXML]."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    if p-subdir <> "":U
    then do:
        assign
            v-home-dir = substitute( "&1/out/&2", v-home-dir, p-subdir )
        .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта в ini-файле."
          skip "Не удаётся создать каталог, указанный параметром"
          skip "oxml-dir в секции [OXML]."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run bge/genfname.p (
          input v-home-dir
        , input p-prefix
        , input ""
        , input "xml"
        , input "tmp"
        , output p-xml-file-name
    ).
    assign
        p-xml-file-name     = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
        p-log-file-name     = v-home-dir + chr(92) + "actions.log"
        p-list-file-name    = v-home-dir + chr(92) + "lst":U + substring( p-xml-file-name, length( p-xml-file-name ) - 5, 5 ) + ".":U
    .
end.
end procedure.
procedure xmllib-check-file-size :
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.
    define variable v-current-position    as integer        no-undo.
do
on error undo, return error
:
    assign
        v-current-position = seek( stmXMLOut )
    .
    if v-current-position / 1024 / 1024  >= 100
    then do:
        assign
            p-is-big = yes
        .
    end.
end.
end procedure.
procedure xmllib-parse-file :
define input parameter p-full-filename      as character        no-undo.
    define variable v-num-dirs              as integer      no-undo .
    define variable v-str                   as character    no-undo .
    define variable v-str-count             as int64        no-undo .
do
on error undo, return error
:
    assign
        v-num-dirs              = num-entries( p-full-filename,"\/":U )
        v-xmllib-error-status   = no
    .
    if v-num-dirs > 1
    then do:
        assign
            v-xmllib-filename = entry( v-num-dirs, p-full-filename, "\/":U )
            v-xmllib-dirname  = substring( p-full-filename, 1, length( p-full-filename ) - length( v-xmllib-filename ) - 1 )
        .
    end.
    else do:
        assign
            v-xmllib-filename = p-full-filename
            v-xmllib-dirname  = "":U
        .
    end.
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
if session :set-wait-state( "compiler" ) then.
      input stream strXMLIn from value(p-full-filename) .
      repeat
      :
        import stream strXMLIn unformatted v-str no-error .
        assign
          v-str-count = v-str-count + 1
        .
      end.
      input stream strXMLIn close .
if session :set-wait-state( "" ) then.
      run prg-bar_init-cb-handle in this-procedure ( input v-xmllib-prg-bar-handle ) .
      run prg-bar_new in this-procedure ( input 1 , input v-str-count) .
      run prg-bar_show in this-procedure .
    end.
    create sax-reader v-xmllib-sax-reader-handle.
    v-xmllib-sax-reader-handle :set-input-source( "FILE":U, p-full-filename ).
    v-xmllib-sax-reader-handle :sax-parse( ) no-error.
    if error-status :error
    then do:
        run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                    ,vss-workfile
                                                                    ,vss-revision
                                                                    ,vss-description
                                                                    ,chr(10)
                                                                    ,return-value
                                                                    ,trim(error-status :get-message(1))
                                                                    ,trim(error-status :get-message(2))
                                                                    ,trim(error-status :get-message(3)))
                                                  ).
        undo, return error .
    end.
    if v-xmllib-error-status <> no
    then do:
        run xmllib-parse-error in this-procedure (
            input "*** При обработке XML файла были ошибки."
        ).
        delete object v-xmllib-sax-reader-handle.
    end.
    delete object v-xmllib-sax-reader-handle.
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
      run prg-bar_delete in this-procedure .
    end.
end.
end procedure.
procedure xmllib-parse-progressive :
define input parameter p-full-filename      as character no-undo .
define input parameter p-pack-data          as memptr no-undo .
define input parameter p-parse-first        as logical no-undo .
define input parameter p-first-err          as logical no-undo .
define output parameter p-parse-status as integer no-undo .
define variable v-num-dirs              as integer no-undo .
define variable glog                    as logical no-undo .
define variable v-pack-size             as int64 no-undo .
do
on error undo, return error
:
  if p-parse-first then do:
    if valid-handle(v-xmllib-sax-reader-handle)
    then do:
    end.
    assign
        v-num-dirs              = num-entries( p-full-filename,"\/":U )
        v-xmllib-error-status   = no
    .
    if v-num-dirs > 1
    then do:
        assign
            v-xmllib-filename = entry( v-num-dirs, p-full-filename, "\/":U )
            v-xmllib-dirname  = substring( p-full-filename, 1, length( p-full-filename ) - length( v-xmllib-filename ) - 1 )
        .
    end.
    else do:
        assign
            v-xmllib-filename = p-full-filename
            v-xmllib-dirname  = "":U
        .
    end.
    create sax-reader v-xmllib-sax-reader-handle.
    v-pack-size = get-size (p-pack-data) .
    if v-pack-size > 0 then
      glog = v-xmllib-sax-reader-handle :set-input-source( "MEMPTR":U, p-pack-data ) no-error.
    else
      glog = v-xmllib-sax-reader-handle :set-input-source( "FILE":U, p-full-filename ) no-error.
    if error-status :error
    or not glog
    then do:
      delete object v-xmllib-sax-reader-handle.
      run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                  ,vss-workfile
                                                                  ,vss-revision
                                                                  ,vss-description
                                                                  ,chr(10)
                                                                  ,return-value
                                                                  ,trim(error-status :get-message(1))
                                                                  ,trim(error-status :get-message(2))
                                                                  ,trim(error-status :get-message(3)) )
                                                ).
      undo, return error .
    end.
    v-xmllib-sax-reader-handle :sax-parse-first( ) no-error.
  end.
  else do:
    v-xmllib-sax-reader-handle :sax-parse-next( ) no-error.
  end.
  if error-status :error
  then do:
    delete object v-xmllib-sax-reader-handle.
    run xmllib-parse-error in this-procedure ( input substitute("&1 &2 &3&4Ошибка обработки XML файла.&4&5&4&5&4&7&4&8"
                                                                ,vss-workfile
                                                                ,vss-revision
                                                                ,vss-description
                                                                ,chr(10)
                                                                ,return-value
                                                                ,trim(error-status :get-message(1))
                                                                ,trim(error-status :get-message(2))
                                                                ,trim(error-status :get-message(3)) )
                                              ).
    undo, return error .
  end.
  if v-xmllib-error-status <> no
  then do:
    run xmllib-parse-error in this-procedure (
        input "*** При обработке XML файла были ошибки."
    ).
    if p-first-err then do:
      delete object v-xmllib-sax-reader-handle.
    end.
    else do:
      v-xmllib-error-status = no.
    end.
  end.
  if v-xmllib-sax-reader-handle:parse-status = SAX-COMPLETE  then do:
    p-parse-status = SAX-COMPLETE.
    delete object v-xmllib-sax-reader-handle.
    return '':U.
  end.
  else do:
    p-parse-status = v-xmllib-sax-reader-handle:parse-status.
    return '':U.
  end.
end.
end procedure.
procedure StartElement :
define input parameter p-name-space     as character        no-undo.
define input parameter p-local-name     as character        no-undo.
define input parameter p-q-name         as character        no-undo.
define input parameter p-attributes     as handle           no-undo.
    define buffer buf_rec             for temp_xmllib_rec.
    define buffer buf_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec
  , buf_rec-fld
  , buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    if valid-handle(v-xmllib-prg-bar-handle)
    then do:
      run prg-bar_stepto in this-procedure ( input SELF:LOCATOR-LINE-NUMBER ) .
    end.
    find first buf_rec-list
         where buf_rec-list.recName = p-q-name
    no-error.
    if available buf_rec-list
    then do:
        if buf_rec-list.closed = no
        then do:
            find first buf_rec-fld-list
                 where buf_rec-fld-list.recName = buf_rec-list.recName
                   and buf_rec-fld-list.fldName = p-q-name
            no-error.
            if available buf_rec-fld-list
            and buf_rec-list.recName = buf_rec-fld-list.recName
            then do:
                if buf_rec-fld-list.closed = no
                then do:
                    run xmllib-parse-error in this-procedure (
                        input substitute( "Ошибка 1 открытия поля <&1> записи <&2>: Поле с этим именем уже открыто на строке &3."
                                        , p-q-name
                                        , p-q-name
                                        , buf_rec-fld-list.fldOpenLine
                                        )
                    ).
                end.
                else do:
                    run xmllib-parse-rec-fld-open in this-procedure (
                          input buf_rec-list.recName
                        , input buf_rec-list.recLevel
                        , input buf_rec-fld-list.fldName
                    ).
                    assign
                        buf_rec-fld-list.closed         = no
                        buf_rec-fld-list.fldOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                        buf_rec-fld-list.fldCloseLine   = 0
                    .
                end.
            end.
            else do:
                assign
                    buf_rec-list.recLevel = buf_rec-list.recLevel + 1
                .
                run xmllib-parse-rec-open in this-procedure (
                      input buf_rec-list.recName
                    , input buf_rec-list.recLevel
                ).
                assign
                    buf_rec-list.closed         = no
                    buf_rec-list.recOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                    buf_rec-list.recCloseLine   = 0
                .
            end.
        end.
        else do:
            run xmllib-parse-rec-open in this-procedure (
                  input buf_rec-list.recName
                , input buf_rec-list.recLevel
            ).
            assign
                buf_rec-list.closed         = no
                buf_rec-list.recOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                buf_rec-list.recCloseLine   = 0
            .
        end.
    end.
    else do:
        open-record:
        for each buf_rec-fld-list
           where buf_rec-fld-list.fldName = p-q-name
        :
            find first buf_rec-list
                 where buf_rec-list.recName = buf_rec-fld-list.recName
                   and buf_rec-list.closed  = no
            no-error.
            if available buf_rec-list
            then do:
                run xmllib-parse-rec-fld-open in this-procedure (
                      input buf_rec-list.recName
                    , input buf_rec-list.recLevel
                    , input buf_rec-fld-list.fldName
                ).
                assign
                    buf_rec-fld-list.recLevel       = buf_rec-list.recLevel
                    buf_rec-fld-list.closed         = no
                    buf_rec-fld-list.fldOpenLine    = v-xmllib-sax-reader-handle :locator-line-number
                    buf_rec-fld-list.fldCloseLine   = 0
                .
                leave open-record.
            end.
        end.
    end.
end.
end procedure.
procedure Characters :
define input parameter p-char-data  as memptr.
define input parameter p-numchars   as integer.
    define variable v-data-string    as character    no-undo.
    define variable v-cp-utf8           as integer no-undo init 65001 .
    define variable v-cp-windows1251    as integer no-undo init 1251 .
    define buffer buf_xmllib_rec             for temp_xmllib_rec.
    define buffer buf_xmllib_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_xmllib_rec-list        for temp_xmllib_rec-list.
    define buffer buf_xmllib_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_xmllib_rec
  , buf_xmllib_rec-fld
  , buf_xmllib_rec-list
  , buf_xmllib_rec-fld-list
on error undo, return error
:
    find first buf_xmllib_rec-list
         where buf_xmllib_rec-list.closed = no
    no-error.
    if available buf_xmllib_rec-list
    then do:
        find first buf_xmllib_rec-fld-list
             where buf_xmllib_rec-fld-list.closed = no
        no-error.
        if available buf_xmllib_rec-fld-list
        and buf_xmllib_rec-fld-list.recName  = buf_xmllib_rec-list.recName
        and buf_xmllib_rec-fld-list.recLevel = buf_xmllib_rec-list.recLevel
        then do:
            find last buf_xmllib_rec
                where buf_xmllib_rec.recName  = buf_xmllib_rec-list.recName
                  and buf_xmllib_rec.recLevel = buf_xmllib_rec-list.recLevel
                  and buf_xmllib_rec.closed   = no
            use-index nm
            no-error.
            if available buf_xmllib_rec
            then do:
                find last buf_xmllib_rec-fld
                    where buf_xmllib_rec-fld.rec-key = buf_xmllib_rec.rec-key
                      and buf_xmllib_rec-fld.fldName = buf_xmllib_rec-fld-list.fldName
                      and buf_xmllib_rec-fld.closed = no
                use-index nm
                no-error.
                if available buf_xmllib_rec-fld
                then do:
                    assign
                        v-data-string = get-string( p-char-data, 1, get-size( p-char-data ) )
                    .
                    if v-xmllib-codepage-convert = yes
                    then do:
                      assign
                          v-data-string = codepage-convert( v-data-string , v-xmllib-codepage-target , v-xmllib-codepage-source )
                      .
                    end.
                    run xmlchar-decode in this-procedure (
                        input v-data-string
                        , output v-data-string
                    ).
                    assign
                        buf_xmllib_rec-fld.fldValue = trim( substitute( "&1&2", buf_xmllib_rec-fld.fldValue, v-data-string ) )
                    .
                end.
            end.
        end.
    end.
end.
end procedure.
procedure EndElement :
define input parameter p-name-space     as character        no-undo.
define input parameter p-local-name     as character        no-undo.
define input parameter p-q-name         as character        no-undo.
    define buffer buf_rec             for temp_xmllib_rec.
    define buffer buf_rec-fld         for temp_xmllib_rec-fld.
    define buffer buf_rec-list        for temp_xmllib_rec-list.
    define buffer buf_rec-fld-list    for temp_xmllib_rec-fld-list.
do
for buf_rec
  , buf_rec-fld
  , buf_rec-list
  , buf_rec-fld-list
on error undo, return error
:
    find last buf_rec-list
        where buf_rec-list.recName = p-q-name
    use-index pi
    no-error.
    if available buf_rec-list
    then do:
        if buf_rec-list.closed = yes
        then do:
            run xmllib-parse-error in this-procedure (
                input substitute( "Ошибка закрытия записи или поля <&1>: Нет метки открытой записи."
                                , p-q-name
                                )
            ).
        end.
        else do:
            find last buf_rec
                where buf_rec.recName  = buf_rec-list.recName
                  and buf_rec.recLevel = buf_rec-list.recLevel
                  and buf_rec.closed   = no
            use-index nm
            no-error.
            if not available buf_rec
            then do:
                run xmllib-parse-error in this-procedure (
                    input substitute( "Ошибка закрытия записи или поля <&1> уровня &2: Нет открытой записи."
                                    , p-q-name
                                    , buf_rec-list.recLevel
                                    )
                ).
            end.
            else do:
                find first buf_rec-fld-list
                     where buf_rec-fld-list.recName  = buf_rec.recName
                       and buf_rec-fld-list.recLevel = buf_rec.recLevel
                       and buf_rec-fld-list.fldName  = p-q-name
                       and buf_rec-fld-list.closed   = no
                no-error.
                if not available buf_rec-fld-list
                then do:
                    if buf_rec.recName <> p-q-name
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка закрытия записи <&1>: Имя открытой записи не совпадает с именем метки."
                                            , buf_rec.recName
                                            )
                        ).
                    end.
                    else do:
                        assign
                            buf_rec.closed              = yes
                            buf_rec.recCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-list.recCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                        if buf_rec-list.recLevel > 0
                        then do:
                            assign
                                buf_rec-list.recLevel = buf_rec-list.recLevel - 1
                            .
                            for each buf_rec-fld-list
                               where buf_rec-fld-list.recName = buf_rec-list.recName
                            :
                                assign
                                    buf_rec-fld-list.recLevel = buf_rec-fld-list.recLevel - 1
                                .
                            end.
                        end.
                        else do:
                            assign
                                buf_rec-list.closed         = yes
                            .
                        end.
                    end.
                end.
                else do:
                    find last buf_rec-fld
                        where buf_rec-fld.rec-key = buf_rec.rec-key
                          and buf_rec-fld.fldName = buf_rec-fld-list.fldName
                          and buf_rec-fld.closed  = no
                    use-index nm
                    no-error.
                    if not available buf_rec-fld
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка 2 закрытия поля <&1>: Не найдено открытое поле с этим именем в записи <&2> уровня &3."
                                            , buf_rec-fld-list.fldName
                                            , buf_rec.recName
                                            , buf_rec.recLevel
                                            )
                        ).
                    end.
                    else do:
                        assign
                            buf_rec-fld.closed              = yes
                            buf_rec-fld-list.closed         = yes
                            buf_rec-fld.fldCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-fld-list.fldCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                    end.
                end.
            end.
        end.
    end.
    else do:
        close-field-rec:
        for each buf_rec-fld-list
           where buf_rec-fld-list.fldName = p-q-name
        :
            find first buf_rec-list
                 where buf_rec-list.recName  = buf_rec-fld-list.recName
                   and buf_rec-list.recLevel = buf_rec-fld-list.recLevel
                   and buf_rec-list.closed   = no
            no-error.
            if available buf_rec-list
            then do:
                find last buf_rec
                    where buf_rec.recName  = buf_rec-list.recName
                      and buf_rec.recLevel = buf_rec-list.recLevel
                      and buf_rec.closed   = no
                use-index nm
                no-error.
                if not available buf_rec
                then do:
                    run xmllib-parse-error in this-procedure (
                        input substitute( "Ошибка закрытия поля <&1>: Нет открытой записи."
                                        , p-q-name
                                        )
                    ).
                end.
                else do:
                    find last buf_rec-fld
                        where buf_rec-fld.rec-key = buf_rec.rec-key
                          and buf_rec-fld.fldName = buf_rec-fld-list.fldName
                          and buf_rec-fld.closed  = no
                    use-index nm
                    no-error.
                    if not available buf_rec-fld
                    then do:
                        run xmllib-parse-error in this-procedure (
                            input substitute( "Ошибка 1 закрытия поля <&1>: Не найдено открытое поле с этим именем в записи <&2> уровня &3."
                                            , buf_rec-fld-list.fldName
                                            , buf_rec.recName
                                            , buf_rec.recLevel
                                            )
                        ).
                    end.
                    else do:
                        assign
                            buf_rec-fld.closed              = yes
                            buf_rec-fld-list.closed         = yes
                            buf_rec-fld.fldCloseLine        = v-xmllib-sax-reader-handle :locator-line-number
                            buf_rec-fld-list.fldCloseLine   = v-xmllib-sax-reader-handle :locator-line-number
                        .
                    end.
                end.
                leave close-field-rec.
            end.
        end.
    end.
end.
end procedure.
procedure Error :
define input parameter p-error-message     as character        no-undo.
do
on error undo, return error
:
    run xmllib-parse-error in this-procedure (
        input p-error-message
    ).
    assign
        v-xmllib-error-status = yes
    .
end.
end procedure.
procedure xmllib-parse-error :
define input parameter p-err-message    as character        no-undo.
do
on error undo, return error
:
    if valid-handle(v-xmllib-log-handle) then do:
      run value(v-xmllib-log-proc-name) in  v-xmllib-log-handle
               (input substitute("&1Файл:    &2 &3&1Строка &4&1&5"
                                 ,chr(10)
                                 ,v-xmllib-dirname
                                 ,v-xmllib-filename
                                 ,(if valid-handle(v-xmllib-sax-reader-handle)
                                   then v-xmllib-sax-reader-handle :locator-line-number
                                   else ?)
                                 ,p-err-message)).
    end.
    else do:
      if v-xmllib-log-filename = "":U
      then do:
          message
                  vss-workfile vss-revision vss-description
              skip "Файл:   " v-xmllib-dirname v-xmllib-filename
              skip "Строка: " (if valid-handle(v-xmllib-sax-reader-handle)
                               then v-xmllib-sax-reader-handle :locator-line-number
                               else ?)
              skip(1)
              skip p-err-message
              skip return-value
              skip trim( error-status :get-message( 1 ) )
                  trim( error-status :get-message( 2 ) )
                  trim( error-status :get-message( 3 ) )
          view-as alert-box error.
          undo, return error.
      end.
      else do:
        output to value( v-xmllib-log-filename ).
        put unformatted
            substitute( "&1&2", chr(10), p-err-message )
        .
        output close.
      end.
    end.
end.
end procedure.
procedure xmllib-set-log-filename :
define input parameter p-log-filename   as character        no-undo.
do
on error undo, return error
:
    run gbl/fileapnd.p (
          input p-log-filename
        , input "":U
        , input 10
    ) no-error.
    if error-status :error
    then do:
        assign
            v-xmllib-log-filename = "":U
        .
    end.
    else do:
        assign
            v-xmllib-log-filename = p-log-filename
        .
    end.
end.
end procedure.
procedure xmllib-set-log-handle :
define input parameter p-log-handle    as handle        no-undo.
define input parameter p-log-proc-name as character no-undo .
do
on error undo, return error
:
    if valid-handle(p-log-handle)
    and lookup(p-log-proc-name, p-log-handle:internal-entries) > 0
    then do:
      assign
      v-xmllib-log-handle    = p-log-handle
      v-xmllib-log-proc-name = p-log-proc-name
      .
    end.
    else do:
      assign
      v-xmllib-log-handle    = ?
      v-xmllib-log-proc-name = '':U
      .
    end.
end.
end procedure.
procedure xmllib-set-prg-bar-handle :
define input parameter p-handle    as handle        no-undo.
do
on error undo, return error
:
    if valid-handle(p-handle)
    then do:
      assign
        v-xmllib-prg-bar-handle = p-handle
      .
    end.
    else do:
      assign
        v-xmllib-prg-bar-handle = ?
      .
    end.
end.
end procedure.
procedure xmllib-set-codepage-convert :
  define input  parameter p-codepage-source as character no-undo .
  define input  parameter p-codepage-target as character no-undo .
do
on error undo, return error return-value
:
  if ( p-codepage-source <> "" and p-codepage-target <> "" )
  then do:
    assign
      v-xmllib-codepage-convert = yes
      v-xmllib-codepage-source  = p-codepage-source
      v-xmllib-codepage-target  = p-codepage-target
    .
  end.
  else do:
    assign
      v-xmllib-codepage-convert = no
      v-xmllib-codepage-source  = ""
      v-xmllib-codepage-target  = ""
    .
  end.
end.
end procedure.
procedure xmllib-parse-rec-open :
define input parameter p-rec-name   as character        no-undo.
define input parameter p-rec-level  as integer          no-undo.
    define buffer buf_temp_xmllib_rec       for temp_xmllib_rec.
do
for buf_temp_xmllib_rec
on error undo, return error
:
     find first buf_temp_xmllib_rec
         where buf_temp_xmllib_rec.recName = p-rec-name
           and buf_temp_xmllib_rec.recLevel = p-rec-level
           and buf_temp_xmllib_rec.closed  = no
    use-index nm
    no-error.
    if available buf_temp_xmllib_rec
    then do:
        run xmllib-parse-error in this-procedure (
            input substitute( "Ошибка 2 открытия записи <&1>: Запись с этим именем и уровнем &2 уже открыта на строке &3."
                            , p-rec-name
                            , p-rec-level
                            , buf_temp_xmllib_rec.recOpenLine
                            )
        ).
    end.
    else do:
        assign
            v-xmllib-rec-key    = v-xmllib-rec-key + 1
        .
        create buf_temp_xmllib_rec.
        assign
            buf_temp_xmllib_rec.rec-key         = v-xmllib-rec-key
            buf_temp_xmllib_rec.recOpenLine     = v-xmllib-sax-reader-handle :locator-line-number
            buf_temp_xmllib_rec.recCloseLine    = 0
            buf_temp_xmllib_rec.recName         = p-rec-name
            buf_temp_xmllib_rec.recLevel        = p-rec-level
            buf_temp_xmllib_rec.closed          = no
        .
    end.
end.
end procedure.
procedure xmllib-parse-rec-fld-open :
define input parameter p-rec-name   as character        no-undo.
define input parameter p-rec-level  as integer          no-undo.
define input parameter p-fld-name   as character        no-undo.
    define buffer buf_temp_xmllib_rec       for temp_xmllib_rec.
    define buffer buf_temp_xmllib_rec-fld   for temp_xmllib_rec-fld.
do
for buf_temp_xmllib_rec
  , buf_temp_xmllib_rec-fld
on error undo, return error substitute( "Ошибка в xmllib-parse-rec-fld-open. &1. &2. &3"
                                        , return-value
                                        , trim( error-status :get-message( 1 ) )
                                        , trim( error-status :get-message( 2 ) ) )
:
    find last buf_temp_xmllib_rec
        where buf_temp_xmllib_rec.recName   = p-rec-name
          and buf_temp_xmllib_rec.recLevel  = p-rec-level
          and buf_temp_xmllib_rec.closed    = no
    use-index nm
    no-error.
    if not available buf_temp_xmllib_rec
    then do:
        run xmllib-parse-error in this-procedure (
            input substitute( "Ошибка 2 открытия поля <&2> в записи <&1> уровня &3: Нет открытой записи."
                            , p-rec-name
                            , p-fld-name
                            , p-rec-level
                            )
        ).
    end.
    else do:
        find last buf_temp_xmllib_rec-fld
            where buf_temp_xmllib_rec-fld.rec-key  = buf_temp_xmllib_rec.rec-key
              and buf_temp_xmllib_rec-fld.fldName  = p-fld-name
              and buf_temp_xmllib_rec-fld.closed   = no
        use-index nm
        no-error.
        if available buf_temp_xmllib_rec-fld
        then do:
            run xmllib-parse-error in this-procedure (
                input substitute( "Ошибка 3 открытия поля <&2> в записи <&1>: Поле с этим именем уже открыто на строке &3."
                                , p-rec-name
                                , p-fld-name
                                , buf_temp_xmllib_rec-fld.fldOpenLine
                                )
            ).
        end.
        else do:
            assign
                v-xmllib-rec-fld-key    = v-xmllib-rec-fld-key + 1
            .
            create buf_temp_xmllib_rec-fld.
            assign
                buf_temp_xmllib_rec-fld.fld-key         = v-xmllib-rec-fld-key
                buf_temp_xmllib_rec-fld.rec-key         = buf_temp_xmllib_rec.rec-key
                buf_temp_xmllib_rec-fld.fldOpenLine     = v-xmllib-sax-reader-handle :locator-line-number
                buf_temp_xmllib_rec-fld.fldCloseLine    = 0
                buf_temp_xmllib_rec-fld.fldName         = p-fld-name
                buf_temp_xmllib_rec-fld.closed          = no
            .
        end.
    end.
end.
end procedure.
// { bge/tmpcxmlh.i } 23/VIII-2018 - уже было вставлено
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-rel-handle no-undo
field dh as handle
field ii as integer
field active_ as logical
field child-buffer_ as character
field parent-buffer_ as character
field child-buffer-handle as handle
field parent-buffer-handle as handle
field name_ as character
field nested_ as logical
field relation-fields_ as character
field reposition_ as logical
field type_ as character
field query_ as handle
field where-string_ as character
field tbl-handle_ as handle
index pi is unique primary
ii
index iparentname parent-buffer_ child-buffer_
index iparenthandle parent-buffer-handle child-buffer-handle
.
procedure tmpreldf_get-relations :
define input parameter p-dataseth as handle no-undo .
define variable v-ii as integer no-undo .
define buffer buf_temp-rel-handle for temp-rel-handle.
do
on error undo, return error
:
  if not valid-handle(p-dataseth)
  or p-dataseth:type <> "DATASET"
  then do:
    return error substitute("Не определен dataset с handle &1", p-dataseth).
  end.
  for each buf_temp-rel-handle where
          buf_temp-rel-handle.dh = p-dataseth:
    delete buf_temp-rel-handle.
  end.
  do v-ii = 1 to p-dataseth:num-relations:
    create buf_temp-rel-handle.
    assign
    buf_temp-rel-handle.ii = v-ii
    buf_temp-rel-handle.dh = p-dataseth
    buf_temp-rel-handle.active_ = p-dataseth:get-relation(v-ii):active
    buf_temp-rel-handle.child-buffer_ = p-dataseth:get-relation(v-ii):child-buffer:name
    buf_temp-rel-handle.parent-buffer_ = p-dataseth:get-relation(v-ii):parent-buffer:name
    buf_temp-rel-handle.child-buffer-handle = p-dataseth:get-relation(v-ii):child-buffer
    buf_temp-rel-handle.tbl-handle_ = buf_temp-rel-handle.child-buffer-handle
    buf_temp-rel-handle.parent-buffer-handle = p-dataseth:get-relation(v-ii):parent-buffer
    buf_temp-rel-handle.name_ = p-dataseth:get-relation(v-ii):name
    buf_temp-rel-handle.nested_ = p-dataseth:get-relation(v-ii):nested
    buf_temp-rel-handle.relation-fields_ = p-dataseth:get-relation(v-ii):relation-fields
    buf_temp-rel-handle.reposition_ = p-dataseth:get-relation(v-ii):reposition
    buf_temp-rel-handle.type_ = p-dataseth:get-relation(v-ii):type
    buf_temp-rel-handle.query_ = p-dataseth:get-relation(v-ii):query
    buf_temp-rel-handle.where-string_ = p-dataseth:get-relation(v-ii):where-string
    .
  end.
end.
end procedure.
procedure tmpreldf_set-relations :
define input parameter p-srcdataseth as handle no-undo .
define input parameter p-trgdataseth as handle no-undo .
define variable gh as handle no-undo .
define buffer buf_temp-rel-handle for temp-rel-handle.
do
on error undo, return error
:
  if not valid-handle(p-srcdataseth)
  or p-srcdataseth:type <> "DATASET"
  then do:
    return error substitute("Не определен dataset-источник с handle &1", p-srcdataseth).
  end.
  if not valid-handle(p-trgdataseth)
  or p-trgdataseth:type <> "DATASET"
  then do:
    return error substitute("Не определен dataset-приемник с handle &1", p-trgdataseth).
  end.
  for each buf_temp-rel-handle no-lock where
          buf_temp-rel-handle.dh = p-srcdataseth
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    gh = p-trgdataseth:ADD-RELATION ( buf_temp-rel-handle.parent-buffer-handle
                                      , buf_temp-rel-handle.child-buffer-handle
                                      , buf_temp-rel-handle.relation-fields_
                                      , buf_temp-rel-handle.reposition_
                                      , buf_temp-rel-handle.nested_).
   if error-status:error
   or not valid-handle(gh) then do:
     undo, return error substitute("Ошибка при добавлении relation &1 в dataset &2", buf_temp-rel-handle.name, p-trgdataseth:name).
   end.
  end.
end.
end procedure.
procedure tmpreld2_query :
define  parameter buffer buf_temp-rel-handle for temp-rel-handle.
define input-output parameter p-child-qh as handle no-undo .
define variable glog as logical no-undo .
define variable v-mess as character no-undo .
_main:
do
on error undo, return error
:
  create query p-child-qh .
  glog = p-child-qh:set-buffers( buf_temp-rel-handle.child-buffer-handle) no-error.
  if error-status:error
  or
  not glog then do:
    v-mess = substitute("Ошибка при попытке получить записи &1&2&3"
                        , buf_temp-rel-handle.child-buffer_
                        , chr(10)
                        , error-status:get-message(1)
                        ).
    delete object p-child-qh no-error.
    undo _main, return error v-mess.
  end.
  glog = p-child-qh:query-prepare( substitute( "for each &1 &2 "
                                            , buf_temp-rel-handle.child-buffer_
                                            , buf_temp-rel-handle.where-string_
                                            )) no-error .
  if error-status:error
  or
  not glog then do:
    v-mess =  substitute("Ошибка при попытке получить записи &1&2&3"
                        , buf_temp-rel-handle.child-buffer_
                        , chr(10)
                        , error-status:get-message(1)
                        ).
    delete object p-child-qh no-error.
    undo _main, return error v-mess.
  end.
  glog = p-child-qh:query-open no-error .
  if error-status:error
  or
  not glog then do:
    v-mess = substitute("Ошибка при попытке получить записи &1&2&3"
                        , buf_temp-rel-handle.child-buffer_
                        , chr(10)
                        , error-status:get-message(1)
                        ).
    delete object p-child-qh no-error.
    undo _main, return error v-mess.
  end.
end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure del-pdf-attr-objdel :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             no-error .
      if available buf_price-doc-forming-attr then do:
         delete buf_price-doc-forming-attr .
      end.
  end.
end procedure.
procedure ins-pdf-attr-objdel :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             no-error .
      if not available  buf_price-doc-forming-attr then do:
         create buf_price-doc-forming-attr.
         assign
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num
             buf_price-doc-forming-attr.plt-id     = p-plt-id
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             buf_price-doc-forming-attr.attr-value = ""
         .
      end.
  end.
end procedure.
procedure ex-pdf-attr-objdel :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-exist      as logical   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  p-exist = false .
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             no-error .
      if available buf_price-doc-forming-attr then do:
         p-exist = true .
      end.
  end.
end procedure.
procedure pdf-exist :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-attr-code as character no-undo .
define output parameter p-exist      as logical   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  p-exist = false .
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = p-attr-code
             no-error .
      if available buf_price-doc-forming-attr then do:
         p-exist = true .
      end.
  end.
end procedure.
procedure pdf-write :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-attr-code as character no-undo .
define input  parameter p-attr-value as character no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = p-attr-code
             no-error .
      if not available buf_price-doc-forming-attr then do:
         create buf_price-doc-forming-attr.
         assign
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num
             buf_price-doc-forming-attr.plt-id     = p-plt-id
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num
             buf_price-doc-forming-attr.attr-code  = p-attr-code
         .
      end.
      buf_price-doc-forming-attr.attr-value = p-attr-value .
  end.
end procedure.
procedure pdf-value :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-attr-code  as character no-undo .
define output parameter p-attr-value as character no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  p-attr-value = "" .
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = p-attr-code
             no-error .
      if available buf_price-doc-forming-attr then do:
         p-attr-value = buf_price-doc-forming-attr.attr-value .
      end.
  end.
end procedure.
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable log-file-name                as character      no-undo .
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
define variable v-sign as integer no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-end-new-line     as logical no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .
define variable v_dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define variable v_qh as handle no-undo .
define variable glog as logical no-undo .
define variable v-esys-id as integer no-undo .
define variable v-extension as character no-undo .
define variable v-last-rec-ord as integer no-undo .
define variable v-err-type as character no-undo .
define variable v-pck-num as integer no-undo .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-error :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
     assign
     v-last-error-message = p-mess.
  end.
end procedure.
define buffer buf_temp-cmd for temp-cmd.
define temp-table tt-dis-rule no-undo like ub.dis-rule.
define temp-table tot-dis-rule_ no-undo like ub.dis-rule
field status_ as character
.
define temp-table temp-dis-rule_ no-undo like ub.dis-rule
field pos-type as character
field status_ as character
.
define temp-table temp-dis-gds-rule_ no-undo like ub.dis-gds-rule
field status_ as character
.
define buffer buf_temp-xml-tables for temp-xml-tables.
function 00200004_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
DO v-ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,chr(10)
                        ,ERROR-STATUS:GET-MESSAGE(v-ii)).
END.
return v-mess.
end function.
function 00200004_after-import_f returns logical ( input p-d-card as character):
  run 00200004_after-import in this-procedure ( input p-d-card) no-error.
  run set-error in this-procedure ( input return-value ).
  return not (error-status:error).
end function.
define variable p-esys-id as integer no-undo .
define variable p-xsd-file as character no-undo.
on delete of this-procedure do:
  run delete-procedure in this-procedure .
  run gate-clear in this-procedure ( input v_dataseth, input v-xmlh) no-error.
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return error.
define variable ImpData1 as class Route-data_ no-undo .
ImpData1 = new Route-data_( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle, input v_dataseth, input v-xmlh) .
if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
      run delete-procedure in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.
procedure proc-main :
define variable v-mode as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-present as logical no-undo .
define variable v-current-tbl-name as character no-undo .
define variable v_child-qh as handle no-undo .
define variable v_child2-qh as handle no-undo .
define variable v-status_ as character no-undo .
define variable v-category_id as integer no-undo .
define variable v-discnt-type as character no-undo .
define variable v-category-name as character no-undo .
define variable v-dtl_id as integer no-undo .
define variable v-b-dtl_id as integer no-undo .
define variable v-dtl-category_id as integer no-undo .
define variable v-b-category_id as integer no-undo .
define variable v-discnt as decimal no-undo .
define variable v-dtl-status_ as character no-undo .
define variable v-b-code as integer no-undo .
define variable v-cat-item-status_ as character no-undo .
define variable v-threshold as decimal no-undo .
define variable v-rid as recid no-undo .
define buffer buf_tot-dis-rule_ for tot-dis-rule_.
define buffer term_tot-dis-rule_ for tot-dis-rule_.
define buffer buf_temp-dis-rule_ for temp-dis-rule_.
define buffer buf_temp-dis-gds-rule_ for temp-dis-gds-rule_.
define buffer buf_temp-rel-handle for temp-rel-handle.
define buffer buf2_temp-rel-handle for temp-rel-handle.
define buffer buf_Dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.
_main:
do transaction
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
  run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute(".............Импорт данных по скидкам из ВС")).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по скидкам из файла &1", file-name)).
for each buf_temp-xml-tables where
       buf_temp-xml-tables.order >= 0
   and buf_temp-xml-tables.is-parent = yes
:
  if buf_temp-xml-tables.tbl-name = "Header_" then next.
  create query v_qh.
  glog = v_qh:set-buffers( buf_temp-xml-tables.tbl-handle_) no-error.
  if error-status:error
  or
  not glog then do:
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при попытке получить записи &1&2&3&2&4"                                                             , buf_temp-xml-tables.tbl-name                                                             , chr(10)                                                             , error-status:get-message(1)                                                             , return-value)).
    undo _main, return error ''.
  end.
  glog = v_qh:query-prepare( substitute( "for each &1 by &1.line-num", buf_temp-xml-tables.tbl-name)) no-error .
  if error-status:error
  or
  not glog then do:
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при попытке получить записи &1&2&3&2&4"                                                             , buf_temp-xml-tables.tbl-name                                                             , chr(10)                                                             , error-status:get-message(1)                                                             , return-value)).
    if valid-handle(v_qh) then do:
      delete object v_qh no-error.
    end.
    undo _main, return error ''.
  end.
  glog = v_qh:query-open no-error .
  if error-status:error
  or not glog then do:
        .
    if valid-handle(v_qh) then do:
      delete object v_qh no-error.
    end.
    undo _main, return error ''.
  end.
    _stroka:
    REPEAT:
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry then do:
          v-retry-action = v-retry-action + 1.
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при импорте записи &5 &1&2&3&2&4"                                                                   , buf_temp-xml-tables.tbl-name                                                                   , num-rec                                                                   , chr(10)                                                                   , error-status:get-message(1)                                                                   , return-value)).
          if valid-handle(v_qh) then do:
            delete object v_qh no-error.
          end.
          undo _main, return error ''.
        end.
        if v-retry-action < 1 then do:
                    ImpData1:Route-data_dump ( ) .
        end.
      end.
      _rule:
       do on error undo _rule, retry _rule:
         if retry then do:
          empty temp-table buf_tot-dis-rule_.
          empty temp-table buf_temp-dis-rule_.
          empty temp-table buf_temp-dis-gds-rule_.
           if valid-handle(v_qh) then do:
             delete object v_qh no-error.
           end.
           if valid-handle(v_child-qh) then do:
             delete object v_child-qh no-error.
           end.
           if valid-handle(v_child2-qh) then do:
             delete object v_child2-qh no-error.
           end.
                     run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("&1&2&3"                                       , error-status:get-message(1)                                       , chr(10)                                       , return-value)).
           undo _main, return error ''.
         end.
         else do:
          v_qh:get-next().
          IF v_qh:query-off-end then leave _stroka.
          assign
          v-current-tbl-name = ''
          v-current-tbl-name = ImpData1:current-tbl-name() no-error.
          case v-current-tbl-name:
            when "category"  THEN do:
              empty temp-table buf_tot-dis-rule_.
              empty temp-table buf_temp-dis-rule_.
              empty temp-table buf_temp-dis-gds-rule_.
              _tr:
              do
              on error undo _rule, retry _rule
              :
                v-line-num = ImpData1:route-data_get-field-integer( input "Category", input "line-num") .
                v-present = no.
                num-rec = num-rec + 1.
                v-line-num = ImpData1:route-data_get-field-integer( input "category", input "line-num") .
                v-status_ = ImpData1:route-data_get-field-character( input "category", input "status_") .
                v-category_id = ImpData1:route-data_get-field-integer( input "category", input "category_id") .
                v-discnt-type = ImpData1:route-data_get-field-character( input "category", input "discnt-type") .
                v-category-name = ImpData1:route-data_get-field-character( input "category", input "category_name") .
                case v-discnt-type :
                  when "temp-disc" then do:
                  end.
                  when "pcnt-tot-kateg" then do:
                    find first buf_tot-dis-rule_ where
                              buf_tot-dis-rule_.rule-num = v-category_id no-error.
                    if not available buf_tot-dis-rule_ then do:
                      find first buf_dis-rule no-lock where
                                buf_Dis-rule.rule-num = 20.
                      create  buf_tot-dis-rule_.
                      buffer-copy buf_dis-rule except
                      rule-num
                      time-templ-rl-root
                      root
                      rl-root
                      host-code
                      obj-type
                      obj-code
                      lvl-num
                      is-term
                      sts
                      time-rule-num
                      upper-rule-num
                      to buf_tot-dis-rule_
                      assign
                      buf_tot-dis-rule_.rule-num = v-category_id
                      buf_tot-dis-rule_.templ-rl-root = buf_dis-rule.rule-num
                      buf_tot-dis-rule_.time-templ-rl-root = 0
                      buf_tot-dis-rule_.root = yes
                      buf_tot-dis-rule_.rl-root = buf_tot-dis-rule_.rule-num
                      buf_tot-dis-rule_.host-code = 0
                      buf_tot-dis-rule_.obj-type = ''
                      buf_tot-dis-rule_.obj-code = 0
                      buf_tot-dis-rule_.is-term = no
                      buf_tot-dis-rule_.lvl-num = 1
                      buf_tot-dis-rule_.sts = integer('0':U)
                      buf_tot-dis-rule_.time-rule-num = 0
                      buf_tot-dis-rule_.upper-rule-num = buf_dis-rule.rule-num
                      .
                    end.
                    assign
                    buf_tot-dis-rule_.des = v-category-name
                    buf_tot-dis-rule_.status_ = v-status_
                    .
                  end.
                end case.
                _rel:
                for each buf_temp-rel-handle where
                        buf_temp-rel-handle.parent-buffer_ = v-current-tbl-name:
                  run tmpreld2_query in this-procedure ( buffer buf_temp-rel-handle, input-output v_child-qh) no-error.
                  if error-status:error then do:
                                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input return-value).
                    undo _rule, retry _rule.
                  end.
                    _child:
                    repeat:
                      v_child-qh:get-next().
                      IF v_child-qh:query-off-end then do:
                        delete object v_child-qh no-error.
                        next _rel.
                      end.
                      v-dtl_id = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "dtl_id") .
                      v-dtl-category_id = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "category_id") .
                      v-discnt = ImpData1:route-data_get-field-decimal( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "discount") .
                      v-dtl-status_ = ImpData1:route-data_get-field-character( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "status_") .
                      if v-dtl-category_id <> v-category_id then do:
                                                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Запись &1: нарушение схемы")).
                        delete object v_child-qh no-error.
                        undo _rule, retry _rule.
                      end.
                      case buf_temp-rel-handle.child-buffer_:
                        when "cat-dtl" THEN do:
                          case v-discnt-type:
                            when "temp-disc" then do:
                              define variable v-jj as integer no-undo .
                              define variable v-pos-type as character no-undo .
                              do v-jj = 1 to 2:
                                if v-jj = 1 then do:
                                  find first buf_dis-rule no-lock where
                                            buf_dis-rule.rule-num = 82 .
                                  v-pos-type = 'IBM':U.
                                end.
                                if v-jj = 2 then do:
                                  find first buf_dis-rule no-lock where
                                            buf_dis-rule.rule-num = 85 .
                                  v-pos-type = 'IBS-TH':U.
                                end.
                                find first buf_temp-dis-rule_ where
                                          buf_temp-dis-rule_.rule-num = v-dtl_id
                                      and buf_temp-dis-rule_.templ-rl-root = buf_dis-rule.rule-num
                                      no-error.
                                if not available buf_temp-dis-rule_ then do:
                                  find first buf_dis-time-rule no-lock where
                                            buf_dis-time-rule.templ-rl-root = 50001 .
                                  create  buf_temp-dis-rule_.
                                  buffer-copy buf_dis-rule
                                  except
                                  rule-num
                                  time-templ-rl-root
                                  root
                                  rl-root
                                  host-code
                                  obj-type
                                  obj-code
                                  lvl-num
                                  is-term
                                  sts
                                  time-rule-num
                                  upper-rule-num
                                  to
                                  buf_temp-dis-rule_
                                  assign
                                  buf_temp-dis-rule_.rule-num = v-dtl_id
                                  buf_temp-dis-rule_.time-templ-rl-root = 50001
                                  buf_temp-dis-rule_.root = yes
                                  buf_temp-dis-rule_.rl-root = v-dtl_id
                                  buf_temp-dis-rule_.host-code = 0
                                  buf_temp-dis-rule_.obj-type = ''
                                  buf_temp-dis-rule_.obj-code = 0
                                  buf_temp-dis-rule_.lvl-num = 1
                                  buf_temp-dis-rule_.is-term = yes
                                  buf_temp-dis-rule_.sts = integer('0':U)
                                  buf_temp-dis-rule_.time-rule-num = buf_dis-time-rule.time-rule-num
                                  buf_temp-dis-rule_.upper-rule-num =  buf_dis-rule.rule-num
                                  buf_temp-dis-rule_.pos-type = v-pos-type
                                  .
                                end.
                                buf_temp-dis-rule_.des = v-category-name.
                                buf_temp-dis-rule_.status_ = v-dtl-status_.
                                buf_temp-dis-rule_.discnt-value = v-discnt.
                                release buf_temp-dis-rule_.
                              end.
                              for each buf_temp-dis-rule_:
                              _rel2:
                              for each buf2_temp-rel-handle where
                                      buf2_temp-rel-handle.parent-buffer_ = "cat-dtl":
                                run tmpreld2_query in this-procedure ( buffer buf2_temp-rel-handle, input-output v_child2-qh) no-error .
                                if error-status:error then do:
                                                                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input return-value).
                                  undo _rule, retry _rule.
                                end.
                                _child2:
                                repeat:
                                  v_child2-qh:get-next().
                                  IF v_child2-qh:query-off-end then do:
                                    delete object v_child2-qh no-error.
                                    next _rel2.
                                  end.
                                  case buf2_temp-rel-handle.child-buffer_:
                                    when "cat-item" THEN do:
                                      v-b-code = ImpData1:route-data_get-field-integer( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "b-code") .
                                      v-b-dtl_id = ImpData1:route-data_get-field-integer( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "dtl_id") .
                                      v-b-category_id = ImpData1:route-data_get-field-integer( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "category_id") .
                                      v-cat-item-status_ = ImpData1:route-data_get-field-character( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "status_") .
                                      if v-dtl_id <> v-b-dtl_id
                                      or v-b-category_id <> v-category_id
                                      then do:
                                                                                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Запись &1: нарушение схемы")).
                                        delete object v_child-qh no-error.
                                        delete object v_child2-qh no-error.
                                        undo _rule, retry _rule.
                                      end.
                                      find first buf_temp-dis-gds-rule_ where
                                              buf_temp-dis-gds-rule_.templ-rl-root = buf_temp-dis-rule_.templ-rl-root
                                          and buf_temp-dis-gds-rule_.obj-type = ''
                                          and buf_temp-dis-gds-rule_.obj-code = 0
                                          and buf_temp-dis-gds-rule_.discnt-role = 'temp-disc':U
                                          and buf_temp-dis-gds-rule_.rule-num = buf_temp-dis-rule_.rule-num
                                          and buf_temp-dis-gds-rule_.gds-code = 0
                                          and buf_temp-dis-gds-rule_.pos-type = buf_temp-dis-rule_.pos-type
                                          and buf_temp-dis-gds-rule_.nonunique = string(v-b-code)  no-error.
                                      if not available buf_temp-dis-gds-rule_ then do:
                                        create  buf_temp-dis-gds-rule_.
                                        assign
                                        buf_temp-dis-gds-rule_.obj-type = ''
                                        buf_temp-dis-gds-rule_.obj-code = 0
                                        buf_temp-dis-gds-rule_.templ-rl-root = buf_temp-dis-rule_.templ-rl-root
                                        buf_temp-dis-gds-rule_.discnt-role = 'temp-disc':U
                                        buf_temp-dis-gds-rule_.time-templ-rl-root = buf_temp-dis-rule_.time-templ-rl-root
                                        buf_temp-dis-gds-rule_.gds-code = 0
                                        buf_temp-dis-gds-rule_.pos-type = 'IBM':U
                                        buf_temp-dis-gds-rule_.nonunique = string(v-b-code)
                                        buf_temp-dis-gds-rule_.rule-num = v-dtl_id
                                        buf_temp-dis-gds-rule_.rl-root = buf_temp-dis-rule_.rule-num
                                        .
                                      end.
                                      buf_temp-dis-gds-rule_.status_ = v-cat-item-status_.
                                      release buf_temp-dis-gds-rule_ .
                                    end.
                                  end case.
                                end.
                                delete object v_child2-qh no-error.
                              end.
                              release buf_temp-dis-rule_.
                              end.
                            end.
                            when "pcnt-tot-kateg" then do:
                              v-threshold = ImpData1:route-data_get-field-decimal( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_ , input "threshold") .
                              find first term_tot-dis-rule_ where
                                        term_tot-dis-rule_.rule-num = v-dtl_id no-error.
                            if not available term_tot-dis-rule_ then do:
                                create term_tot-dis-rule_.
                                buffer-copy buf_tot-dis-rule_
                                except rule-num
                                upper-rule-num
                                lvl-num
                                root
                                is-term
                                sts
                                to term_tot-dis-rule_
                                assign
                                term_tot-dis-rule_.upper-rule-num = v-category_id
                                term_tot-dis-rule_.rule-num = v-dtl_id
                                term_tot-dis-rule_.lvl-num = 2
                                term_tot-dis-rule_.root = no
                                term_tot-dis-rule_.is-term = yes
                                  term_tot-dis-rule_.status_ = v-dtl-status_
                                term_tot-dis-rule_.sts = integer('2':U)
                                .
                              end.
                              assign
                              term_tot-dis-rule_.tot-sum = v-threshold
                              term_tot-dis-rule_.des = string(term_tot-dis-rule_.tot-sum)
                              term_tot-dis-rule_.discnt-value = v-discnt
                              term_tot-dis-rule_.status_ = v-dtl-status_
                              .
                                release term_tot-dis-rule_.
                            end.
                          end case.
                        end.
                      end case.
                  end.
                  delete object v_child-qh no-error.
                end.
                case v-discnt-type:
                  when "temp-disc" then do:
                    run proc-save-temp-disc-rule in this-procedure (  input v-line-num
                                                      ,input v-status_
                                                      ) no-error.
                  end.
                  when "pcnt-tot-kateg" then do:
                     run proc-save-tot-pcnt in this-procedure ( input v-line-num
                                                       ,input v-status_
                                                       ,buffer buf_tot-dis-rule_) no-error.
                  end.
                end case.
                if error-status:error then do:
                  run set-err-type in p-cont-handle
                    ( input 'PROCESSING'
                    ) no-error.
                  if valid-handle(v_qh) then do:
                    delete object v_qh no-error.
                  end.
                                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("&1&2&3"                                                , error-status:get-message(1)                                               , chr(10)                                               , return-value)).
                  undo _rule, retry _rule .
                end.
              end.
            end.
          end case.
        end.
      end.
      v-retry-action = 0 .
     _release:
      do on error undo, retry:
        if  retry then do:
          v-retry-action = v-retry-action + 1.
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("&1&2&3"                                       , error-status:get-message(1)                                       , chr(10)                                       , v-last-error-message )).
          undo _main, return error ''.
        end.
      if v-retry-action < 1 then do:
                ImpData1:Route-data_dump ( ) .
      end.
      end.
      if v-retry-action = 0 then do:
        num-rec-ok = num-rec-ok + 1.
      end.
      run write-counter in p-log-handle ( input substitute("Обработано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
    end.
    v_qh:query-close().
    if valid-handle(v_qh) then do:
      delete object v_qh.
    end.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Обработано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
end.
end procedure.
procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ext-system for ub.ext-system.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.
do
on error undo, return error
:
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-esys-id"
 no-error.
if available buf_rule-call-param then do:
assign p-esys-id = buf_rule-call-param.param-value-integer.
end.
    find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-xsd-file"
 no-error.
if available buf_rule-call-param then do:
assign p-xsd-file = buf_rule-call-param.param-value-character.
end.
    case p-ruleset-id:
      when 4 then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = entry(1, p-process-file-name, chr(4))
        v_dataseth = handle(entry(2, p-process-file-name, chr(4)))
        v-xmlh = buffer buf_temp-xml-tables:handle
        v-esys-id = integer(p-doc-code)
        v-extension = entry(num-entries(file-name, "."), file-name, ".")
        v-pck-num = integer(entry(3, p-process-file-name, chr(4)))
        log-file-name = entry(4, p-process-file-name, chr(4))
        no-error
        .
        if error-status:error then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки параметров&1&2 ..."                                         , chr(10)                                         , error-status:get-message(1) )).
          undo, return error substitute("Ошибки параметров&1&2 ..."                                         , chr(10)                                         , error-status:get-message(1) ).
        end.
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = v-esys-id
              and buf_ext-system.db-num = 0 no-error .
        if not available buf_ext-system then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не найдена ВС &1&2 ..."                                         , v-esys-id                                         , chr(10)                                         )).
          undo, return error substitute("Не найдена ВС &1&2 ..."                                         , v-esys-id                                         , chr(10)                                         ).
        end.
        if v-extension = ''
        or lookup(v-extension, "dat") = 0 then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Файл &1 имеет недопустимое расширение &3&2 ..."                                         ,file-name                                         , chr(10)                                         , v-extension                                         )).
          undo, return error substitute("Файл &1 имеет недопустимое расширение &3&2 ..."                                         ,file-name                                         , chr(10)                                         , v-extension                                         ).
        end.
        find first buf_dis-time-rule no-lock where
                  buf_Dis-time-rule.templ-rl-root = 50001 no-error.
        if not available buf_Dis-time-rule then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не найдено расписание правил скидок с типом ВСЕГДА")).
          undo, return error substitute("Не найдено расписание правил скидок с типом ВСЕГДА").
        end.
        find first buf_dis-rule no-lock where
                  buf_Dis-rule.rule-num = 20 no-error.
        if not available buf_Dis-rule then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не найден ШАБЛОН правил скидок 20")).
          undo, return error substitute("Не найден ШАБЛОН правил скидок 20").
        end.
        find first buf_dis-rule no-lock where
                  buf_Dis-rule.rule-num = 82 no-error.
        if not available buf_Dis-rule then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не найден ШАБЛОН правил скидок 82 (POS IBM)")).
          undo, return error substitute("Не найден ШАБЛОН правил скидок 82 (POS IBM)").
        end.
        find first buf_dis-rule no-lock where
                  buf_Dis-rule.rule-num = 85 no-error.
        if not available buf_Dis-rule then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не найден ШАБЛОН правил скидок 85 (POS IBS TH)")).
          undo, return error substitute("Не найден ШАБЛОН правил скидок 85 (POS IBS TH)").
        end.
        run tmpreldf_get-relations in this-procedure ( input  v_dataseth).
      end.
      otherwise do:
        undo, return error "Неправильный вызов".
      end.
    end case.
  end.
end procedure.
procedure delete-procedure :
  do
  on error undo, return error
  :
      for each temp-dis-rule_:
        delete temp-dis-rule_.
      end.
      for each tot-dis-rule_:
        delete tot-dis-rule_.
      end.
      for each temp-dis-gds-rule_:
        delete temp-dis-gds-rule_.
      end.
      run garbcoll_clear in this-procedure .
  end.
end procedure.
procedure proc-save-temp-disc-rule :
define input  parameter p-line-num as integer   no-undo .
define input  parameter p-status_ as character no-undo .
define variable v-rid as recid no-undo .
define variable v-mode as character no-undo .
define variable v-work-place as character no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-err-mess as character no-undo .
define variable v-is-terminal as logical no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable dflt-cd as character no-undo .
define buffer buf_temp-dis-gds-rule_ for temp-dis-gds-rule_.
define buffer buf_clients for ub.clients.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_temp-dis-rule_ for temp-dis-rule_.
define buffer term_tt-dis-rule for tt-dis-rule.
define buffer buf_bar-code for ub.bar-code.
main-block:
do transaction
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    empty temp-table temp-dis-rule_.
    empty temp-table temp-dis-gds-rule_.
    empty temp-table tot-dis-rule_.
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input v-err-mess).
    return error ''.
  end.
  else do:
    case p-status_:
      when 'D' then do:
        _buf-clients:
        for each buf_clients no-lock where
                buf_clients.db-num = g#db-num
            and buf_clients.obj-type = 'маг':U
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          dflt-cd = ''.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type19 as character no-undo .
define variable v-value-date19 as date no-undo .
define variable v-value-decimal19 as decimal no-undo .
define variable v-value-integer19 as INTEGER no-undo .
define variable v-value-logical19 AS LOGICAL no-undo .
define variable v-tth19 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  buf_Clients.obj-type
    ,input  buf_clients.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date19
    ,output v-value-decimal19
    ,output v-value-integer19
    ,output v-value-logical19
    ,output v-param-type19
    ,INPUT-OUTPUT table-handle v-tth19
    )  .
delete object v-tth19 no-error.
          case dflt-cd :
            when 'IBM':U then do:
              v-templ-rl-root = 82.
            end.
            when 'IBS-TH':U then do:
              v-templ-rl-root = 85.
            end.
            otherwise do:
               next _buf-clients.
            end.
          end.
          for each buf_dis-rule share-lock where
                buf_dis-rule.host-code = buf_clients.host-code
            and buf_dis-rule.obj-type = buf_clients.obj-type
            and buf_dis-rule.obj-code = buf_clients.obj-code
            and buf_dis-rule.templ-rl-root = v-templ-rl-root
          on error  undo main-block, retry main-block
          on stop   undo main-block, retry main-block
          on endkey undo main-block, retry main-block
          :
            for each buf_dis-gds-rule share-lock where
                    buf_dis-gds-rule.obj-type = buf_clients.obj-type
                and buf_dis-gds-rule.obj-type = buf_clients.obj-type
                and buf_dis-gds-rule.templ-rl-root = buf_dis-rule.templ-rl-root
                and buf_dis-gds-rule.discnt-role = 'temp-disc':U
                and buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num
            on error  undo main-block, retry main-block
            on stop   undo main-block, retry main-block
            on endkey undo main-block, retry main-block
            :
              run fill-g-list in  p-cont-handle  ( input buf_dis-gds-rule.gds-code
                                                 , input buf_clients.obj-type
                                                 , input buf_clients.obj-code).
              delete buf_Dis-gds-rule no-error.
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при удалении привязки к правилу временных скидок &1 (типа &2) по &3&4 товар &8:&5&6&5&7"
                                        , buf_dis-rule.rule-num
                                        , buf_dis-rule.templ-rl-root
                                        , buf_clients.obj-type
                                        , buf_clients.obj-code
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        , buf_dis-gds-rule.gds-code
                                        ).
                undo main-block, retry main-block .
              end.
            end.
            delete buf_dis-rule no-error.
            if error-status:error then do:
              v-err-mess = substitute("Ошибка при удалении к правила временных скидок &1 (типа &2) по &3&4:&5&6&5&7"
                                      , buf_dis-rule.rule-num
                                      , buf_dis-rule.templ-rl-root
                                      , buf_clients.obj-type
                                      , buf_clients.obj-code
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
              undo main-block, retry main-block .
            end.
          end.
        end.
      end.
      when 'N'
      or
      when 'U'
      then do:
        _buf-clients:
        for each buf_clients no-lock where
                buf_clients.db-num = g#db-num
            and buf_clients.obj-type = 'маг':U
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          dflt-cd = ''.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type20 as character no-undo .
define variable v-value-date20 as date no-undo .
define variable v-value-decimal20 as decimal no-undo .
define variable v-value-integer20 as INTEGER no-undo .
define variable v-value-logical20 AS LOGICAL no-undo .
define variable v-tth20 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  buf_Clients.obj-type
    ,input  buf_clients.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date20
    ,output v-value-decimal20
    ,output v-value-integer20
    ,output v-value-logical20
    ,output v-param-type20
    ,INPUT-OUTPUT table-handle v-tth20
    )  .
delete object v-tth20 no-error.
          case dflt-cd :
            when 'IBM':U then do:
              v-templ-rl-root = 82.
            end.
            when 'IBS-TH':U then do:
              v-templ-rl-root = 85.
            end.
            otherwise do:
               next _buf-clients.
            end.
          end.
          for each buf_temp-dis-rule_
          on error  undo main-block, retry main-block
          on stop   undo main-block, retry main-block
          on endkey undo main-block, retry main-block
          :
            if v-templ-rl-root <> buf_temp-dis-rule_.templ-rl-root then next .
            if buf_temp-dis-rule_.status_ = 'D' then do:
              for each buf_dis-rule share-lock where
                    buf_dis-rule.host-code = buf_clients.host-code
                and buf_dis-rule.obj-type = buf_clients.obj-type
                and buf_dis-rule.obj-code = buf_clients.obj-code
                and buf_dis-rule.templ-rl-root = v-templ-rl-root
              on error  undo main-block, retry main-block
              on stop   undo main-block, retry main-block
              on endkey undo main-block, retry main-block
              :
                if buf_dis-rule.discnt-value = buf_temp-dis-rule_.discnt-value then do:
                  for each buf_dis-gds-rule share-lock where
                          buf_dis-gds-rule.obj-type = buf_clients.obj-type
                      and buf_dis-gds-rule.obj-type = buf_clients.obj-type
                      and buf_dis-gds-rule.templ-rl-root = buf_dis-rule.templ-rl-root
                      and buf_dis-gds-rule.discnt-role = 'temp-disc':U
                      and buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num
                  on error  undo main-block, retry main-block
                  on stop   undo main-block, retry main-block
                  on endkey undo main-block, retry main-block
                  :
                    run fill-g-list in  p-cont-handle  ( input buf_dis-gds-rule.gds-code
                                                      , input buf_clients.obj-type
                                                      , input buf_clients.obj-code).
                    delete buf_Dis-gds-rule no-error.
                    if error-status:error then do:
                      v-err-mess = substitute("Ошибка при удалении привязки к правилу временных скидок &1 (типа &2) по &3&4 товар &8:&5&6&5&7"
                                              , buf_dis-rule.rule-num
                                              , buf_dis-rule.templ-rl-root
                                              , buf_clients.obj-type
                                              , buf_clients.obj-code
                                              , chr(10)
                                              , error-status:get-message(1)
                                              , return-value
                                              , buf_dis-gds-rule.gds-code
                                              ).
                      undo main-block, retry main-block .
                    end.
                  end.
                  delete buf_dis-rule no-error.
                  if error-status:error then do:
                    v-err-mess = substitute("Ошибка при удалении к правила временных скидок &1 (типа &2) по &3&4:&5&6&5&7"
                                            , buf_dis-rule.rule-num
                                            , buf_dis-rule.templ-rl-root
                                            , buf_clients.obj-type
                                            , buf_clients.obj-code
                                            , chr(10)
                                            , error-status:get-message(1)
                                            , return-value
                                            ).
                    undo main-block, retry main-block .
                  end.
                end.
              end.
            end.
            else do:
            find first buf_dis-rule share-lock where
                      buf_Dis-rule.host-code = buf_clients.host-code
                  and buf_Dis-rule.obj-type = buf_clients.obj-type
                  and buf_Dis-rule.obj-type = buf_clients.obj-type
                  and buf_Dis-rule.templ-rl-root = v-templ-rl-root
                  and buf_Dis-rule.is-term = yes
                  and buf_Dis-rule.discnt-value = buf_temp-dis-rule_.discnt-value no-error.
            if not available buf_dis-rule
            and buf_temp-dis-rule_.status_ <> 'N' then do:
              v-err-mess = substitute("Ошибка при изменении/удалении правила временных скидок с процентом &1 (типа &2)&3нет правила"
                                      , buf_temp-dis-rule_.discnt-value
                                      , buf_temp-dis-rule_.templ-rl-root
                                      , chr(10)
                                      ).
              run set-err-type in p-cont-handle
                ( input 'SYNCHRONIZATION'
                ) no-error.
              undo main-block, retry main-block .
            end.
            if not available buf_dis-rule then do:
              v-rid = ?.
              run ref/dis-rul1.p (
              input ?
              ,input dflt-cd
              ,input buf_temp-dis-rule_.templ-rl-root
              ,input buf_temp-dis-rule_.templ-rl-root
              ,input buf_temp-dis-rule_.des
              ,input buf_temp-dis-rule_.dis-kat
              ,input buf_temp-dis-rule_.discnt-type
              ,input buf_temp-dis-rule_.doc-qnty
              ,input buf_temp-dis-rule_.tot-sum
              ,input buf_temp-dis-rule_.charkey_one
              ,input buf_temp-dis-rule_.charkey_two
              ,input buf_temp-dis-rule_.charkey_three
              ,input buf_temp-dis-rule_.deckey_one
              ,input buf_temp-dis-rule_.deckey_two
              ,input buf_temp-dis-rule_.deckey_three
              ,input buf_temp-dis-rule_.key#_one
              ,input buf_temp-dis-rule_.key#_two
              ,input buf_temp-dis-rule_.key#_three
              ,input buf_temp-dis-rule_.subject-type
              ,input buf_temp-dis-rule_.time-templ-rl-root
              ,input buf_temp-dis-rule_.time-rule-num
              ,input buf_temp-dis-rule_.upper-rule-num
              ,input buf_temp-dis-rule_.value-type
              ,input buf_clients.host-code
              ,INPUT buf_clients.obj-type
              ,INPUT buf_clients.obj-code
              ,INPUT buf_temp-dis-rule_.discnt-value
              ,input table term_tt-dis-rule
              ,input-output v-rid
              ,input 'ДОБАВЛЕНИЕ':U
              ,input yes
              ) NO-ERROR.
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при создании правила временной скидки с % &6 в &1&2:&3&4&3&5"
                                        , buf_clients.obj-type
                                        , buf_clients.obj-code
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        , buf_temp-dis-rule_.discnt-value
                                        ).
              end.
              find first buf_dis-rule share-lock where
                      recid(buf_dis-rule) = v-rid .
            end.
            else do:
              if buf_temp-dis-rule_.status_ <> 'D' then do:
                v-rid = recid(buf_dis-rule).
                run ref/dis-rul1.p (
                input buf_dis-rule.rule-num
                ,input dflt-cd
                ,input buf_dis-rule.rl-root
                ,input buf_dis-rule.templ-rl-root
                ,input buf_temp-dis-rule_.des
                ,input buf_dis-rule.dis-kat
                ,input buf_dis-rule.discnt-type
                ,input buf_dis-rule.doc-qnty
                ,input buf_dis-rule.tot-sum
                ,input buf_dis-rule.charkey_one
                ,input buf_dis-rule.charkey_two
                ,input buf_dis-rule.charkey_three
                ,input buf_dis-rule.deckey_one
                ,input buf_dis-rule.deckey_two
                ,input buf_dis-rule.deckey_three
                ,input buf_dis-rule.key#_one
                ,input buf_dis-rule.key#_two
                ,input buf_dis-rule.key#_three
                ,input buf_dis-rule.subject-type
                ,input buf_dis-rule.time-templ-rl-root
                ,input buf_dis-rule.time-rule-num
                ,input buf_dis-rule.upper-rule-num
                ,input buf_dis-rule.value-type
                ,input buf_clients.host-code
                ,INPUT buf_clients.obj-type
                ,INPUT buf_clients.obj-code
                ,INPUT buf_temp-dis-rule_.discnt-value
                ,input table term_tt-dis-rule
                ,input-output v-rid
                ,input 'ИЗМЕНЕНИЕ':U
                ,input yes
                ) NO-ERROR.
                if error-status:error then do:
                  v-err-mess = substitute("Ошибка при изменении правила временной скидки с % &6 в &1&2:&3&4&3&5"
                                          , buf_clients.obj-type
                                          , buf_clients.obj-code
                                          , chr(10)
                                          , error-status:get-message(1)
                                          , return-value
                                          , buf_temp-dis-rule_.discnt-value
                                          ).
                end.
              end.
            end.
              for each buf_temp-dis-gds-rule_ where
                      buf_temp-dis-gds-rule_.rule-num = buf_temp-dis-rule_.rule-num
              on error  undo main-block, retry main-block
              on stop   undo main-block, retry main-block
              on endkey undo main-block, retry main-block
              :
                find first buf_bar-code no-lock where
                          buf_bar-code.b-code = integer(buf_temp-dis-gds-rule_.nonunique) no-error.
                if not available buf_bar-code then do:
                  v-err-mess = substitute("Ошибка при изменении/добавлении/удалении привязки правила временных скидок с процентом &1 (типа &2) на бар-код &3 в &4&5&6не найден бар-код"
                                          , buf_temp-dis-rule_.discnt-value
                                          , buf_temp-dis-rule_.templ-rl-root
                                          , buf_temp-dis-gds-rule_.nonunique
                                          , buf_clients.obj-type
                                          , buf_clients.obj-code
                                          , chr(10)
                                          ).
                  run set-err-type in p-cont-handle
                    ( input 'SYNCHRONIZATION'
                    ) no-error.
                  undo main-block, retry main-block .
                end.
                assign
                buf_temp-dis-gds-rule_.gds-code = buf_bar-code.gds-code.
                find first buf_dis-gds-rule share-lock where
                        buf_Dis-gds-rule.obj-type = buf_clients.obj-type
                    and buf_Dis-gds-rule.obj-code = buf_clients.obj-code
                    and buf_Dis-gds-rule.pos-type = dflt-cd
                    and buf_Dis-gds-rule.templ-rl-root = buf_temp-Dis-rule_.templ-rl-root
                    and buf_Dis-gds-rule.gds-code = buf_temp-dis-gds-rule_.gds-code
                    and buf_Dis-gds-rule.discnt-role = buf_temp-dis-gds-rule_.discnt-role
                    and buf_Dis-gds-rule.nonunique = buf_temp-dis-gds-rule_.nonunique
                    and buf_Dis-gds-rule.rule-num = buf_dis-rule.rule-num
                    no-error.
                if not available buf_dis-gds-rule
                and buf_temp-dis-gds-rule_.status_ = 'D' then do:
                  v-err-mess = substitute("Ошибка при удалении привязки правила временных скидок с процентом &1 (типа &2) на бар-код &3 в &4&5&6не найдена привязка"
                                          , buf_temp-dis-rule_.discnt-value
                                          , buf_temp-dis-rule_.templ-rl-root
                                          , buf_temp-dis-gds-rule_.nonunique
                                          , buf_clients.obj-type
                                          , buf_clients.obj-code
                                          , chr(10)
                                          ).
                  run set-err-type in p-cont-handle
                    ( input 'SYNCHRONIZATION'
                    ) no-error.
                  undo main-block, retry main-block .
                end.
                if not available buf_dis-gds-rule then do:
                  find first buf_dis-gds-rule share-lock where
                          buf_Dis-gds-rule.obj-type = buf_clients.obj-type
                      and buf_Dis-gds-rule.obj-code = buf_clients.obj-code
                      and buf_Dis-gds-rule.pos-type = dflt-cd
                      and buf_Dis-gds-rule.templ-rl-root = buf_temp-Dis-rule_.templ-rl-root
                      and buf_Dis-gds-rule.gds-code = buf_temp-dis-gds-rule_.gds-code
                      and buf_Dis-gds-rule.discnt-role = buf_temp-dis-gds-rule_.discnt-role
                    and buf_dis-gds-rule.nonunique  = buf_temp-dis-gds-rule_.nonunique
                      no-error.
                  if available buf_dis-gds-rule
                  and buf_dis-gds-rule.nonunique = ''
                  then do:
                    v-err-mess = substitute("Ошибка при добавлении/изменении привязки правила временных скидок с процентом &1 (типа &2) на бар-код &3 в &4&5&6уже есть привязка К ПРАВИЛУ ДРУГОГО ТИПА"
                                            , buf_temp-dis-rule_.discnt-value
                                            , buf_temp-dis-rule_.templ-rl-root
                                            , buf_temp-dis-gds-rule_.nonunique
                                            , buf_clients.obj-type
                                            , buf_clients.obj-code
                                            , chr(10)
                                            ).
                    run set-err-type in p-cont-handle
                      ( input 'SYNCHRONIZATION'
                      ) no-error.
                    undo main-block, retry main-block .
                end.
                if not available buf_dis-gds-rule
                and (buf_temp-dis-rule_.status_ = 'N'
                      or
                      buf_temp-dis-rule_.status_ = 'U'
                      )
                then do:
                  create buf_dis-gds-rule.
                  buffer-copy buf_temp-dis-gds-rule_
                  except
                  rule-num
                  rl-root
                  to buf_dis-gds-rule
                  assign
                  buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num
                  buf_dis-gds-rule.rl-root = buf_dis-rule.rule-num
                buf_dis-gds-rule.obj-type = buf_clients.obj-type
                buf_dis-gds-rule.obj-code = buf_clients.obj-code
                buf_dis-gds-rule.nonunique  = buf_temp-dis-gds-rule_.nonunique
                  .
              end.
              run fill-g-list in  p-cont-handle  ( input buf_dis-gds-rule.gds-code
                                                 , input buf_clients.obj-type
                                                 , input buf_clients.obj-code).
                if (buf_temp-dis-rule_.status_ = 'N'
                      or
                      buf_temp-dis-rule_.status_ = 'U'
                      ) then do:
                    assign
                    buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num
                    .
                    release buf_Dis-gds-rule no-error.
                end.
                if buf_temp-dis-rule_.status_ = 'D' then do:
                  delete buf_Dis-gds-rule no-error.
                end.
                if error-status:error then do:
                    v-err-mess = substitute("Ошибка при создании привязки правила временной скидки с % &6 к бар-коду &7 в &1&2:&3&4&3&5"
                                            , buf_clients.obj-type
                                            , buf_clients.obj-code
                                            , chr(10)
                                            , error-status:get-message(1)
                                            , return-value
                                            , buf_temp-dis-rule_.discnt-value
                                            , buf_temp-dis-gds-rule_.nonunique
                                            ).
                  end.
                end.
              end.
            if buf_temp-dis-rule_.status_ <> 'D' then do:
              for each buf_dis-gds-rule no-lock where
                      buf_Dis-gds-rule.rule-num = buf_dis-rule.rule-num:
                run fill-g-list in p-cont-handle ( input buf_dis-gds-rule.gds-code
                                                ,input buf_dis-gds-rule.obj-type
                                                ,input buf_dis-gds-rule.obj-code
                                                ).
              end.
              end.
            end.
          end.
        end.
      end.
    end case.
  end.
end.
end procedure.
procedure proc-save-tot-pcnt :
define input  parameter p-line-num as integer   no-undo .
define input  parameter p-status_ as character no-undo .
define parameter buffer buf_tot-dis-rule_ for tot-dis-rule_.
define variable v-rid as recid no-undo .
define variable v-mode as character no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-err-mess as character no-undo .
define variable dflt-cd as character no-undo .
define variable v-rule-num as integer no-undo .
define variable v-templ-rl-root as integer no-undo .
define variable ii as integer no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-sts as integer no-undo .
define buffer term_tot-dis-rule_ for tot-dis-rule_.
define buffer buf_term-dis-rule for ub.dis-rule.
define buffer buf_clients for ub.clients.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
define buffer term_tt-dis-rule for tt-dis-rule.
main-block:
do transaction
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    empty temp-table tot-dis-rule_.
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input v-err-mess).
    return error ''.
  end.
  else do:
    case p-status_:
      when 'D'  then do:
        for each buf_clients no-lock where
                buf_clients.db-num = g#db-num
            and buf_clients.obj-type = 'маг':U
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          dflt-cd = ''.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type21 as character no-undo .
define variable v-value-date21 as date no-undo .
define variable v-value-decimal21 as decimal no-undo .
define variable v-value-integer21 as INTEGER no-undo .
define variable v-value-logical21 AS LOGICAL no-undo .
define variable v-tth21 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  buf_Clients.obj-type
    ,input  buf_clients.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date21
    ,output v-value-decimal21
    ,output v-value-integer21
    ,output v-value-logical21
    ,output v-param-type21
    ,INPUT-OUTPUT table-handle v-tth21
    )  .
delete object v-tth21 no-error.
          find first buf_dis-thbj-rule share-lock where
                    buf_dis-thbj-rule.obj-type = buf_clients.obj-type
                and buf_dis-thbj-rule.obj-code = buf_clients.obj-code
                and buf_dis-thbj-rule.host-code = buf_clients.host-code
                and buf_dis-thbj-rule.pos-type = dflt-cd
                and buf_dis-thbj-rule.discnt-role = 'pcnt-tot-kateg':U
                and buf_dis-thbj-rule.nonunique = '' no-error.
          if available buf_dis-thbj-rule then do:
            v-rule-num = buf_dis-thbj-rule.rule-num.
            v-templ-rl-root = buf_dis-thbj-rule.templ-rl-root.
            find first buf_Dis-rule exclusive-lock where
                     buf_Dis-rule.rule-num = v-rule-num no-error.
            delete buf_dis-thbj-rule no-error.
            if error-status:error then do:
              v-err-mess = substitute("Ошибка при удалении привязки к правилу скидок на итог &1 (типа &2) по &3&4:&5&6&5&7"
                                      , v-rule-num
                                      , v-templ-rl-root
                                      , buf_clients.obj-type
                                      , buf_clients.obj-code
                                      , chr(10)
                                      , error-status:get-message(1)
                                      , return-value
                                      ).
              undo main-block, retry main-block .
            end.
            if available buf_dis-rule then do:
              run ref/disrul30.p (
                                buffer buf_dis-rule
                              ) no-error.
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при удалении правила скидок на итог &1 (типа &2):&3&4&3&5"
                                        , v-rule-num
                                        , v-templ-rl-root
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
                undo main-block, retry main-block .
              end.
            end.
          end.
        end.
      end.
      when 'U' then do:
        for each buf_clients no-lock where
                buf_clients.db-num = g#db-num
            and buf_clients.obj-type = 'маг':U
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          empty temp-table term_tt-dis-rule.
          for each term_tot-dis-rule_ where
                 term_tot-dis-rule_.upper-rule-num = buf_tot-dis-rule_.rule-num:
            if term_tot-dis-rule_.status_ = '' then delete term_tot-dis-rule_.
          end.
          dflt-cd = ''.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type22 as character no-undo .
define variable v-value-date22 as date no-undo .
define variable v-value-decimal22 as decimal no-undo .
define variable v-value-integer22 as INTEGER no-undo .
define variable v-value-logical22 AS LOGICAL no-undo .
define variable v-tth22 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  buf_Clients.obj-type
    ,input  buf_clients.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date22
    ,output v-value-decimal22
    ,output v-value-integer22
    ,output v-value-logical22
    ,output v-param-type22
    ,INPUT-OUTPUT table-handle v-tth22
    )  .
delete object v-tth22 no-error.
          find first buf_dis-thbj-rule share-lock where
                    buf_dis-thbj-rule.obj-type = buf_clients.obj-type
                and buf_dis-thbj-rule.obj-code = buf_clients.obj-code
                and buf_dis-thbj-rule.host-code = buf_clients.host-code
                and buf_dis-thbj-rule.pos-type = dflt-cd
                and buf_dis-thbj-rule.discnt-role = 'pcnt-tot-kateg':U
                and buf_dis-thbj-rule.nonunique = '' no-error.
          if available buf_dis-thbj-rule then do:
            v-rule-num = buf_dis-thbj-rule.rule-num.
            v-templ-rl-root = buf_dis-thbj-rule.templ-rl-root.
            find first buf_Dis-rule exclusive-lock where
                     buf_Dis-rule.rule-num = v-rule-num no-error.
            if available buf_dis-rule then do:
              ii = 0.
              for each term_tot-dis-rule_ where
                     term_tot-dis-rule_.upper-rule-num = buf_tot-dis-rule_.rule-num
              by term_tot-dis-rule_.tot-sum  descending
              :
                ii = ii + 1.
                find first buf_term-dis-rule no-lock where
                          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
                      and buf_term-dis-rule.tot-sum = term_tot-dis-rule_.tot-sum no-error.
                if not available buf_term-dis-rule
                and term_tot-dis-rule_.status_ <> 'N' then do:
                  v-err-mess = substitute("Ошибка при изменении правила скидок на итог &1 (типа &2)&3нет ветки с суммой &4"
                                          , v-rule-num
                                          , v-templ-rl-root
                                          , chr(10)
                                          , term_tot-dis-rule_.tot-sum
                                          ).
                  run set-err-type in p-cont-handle
                    ( input 'SYNCHRONIZATION'
                    ) no-error.
                  undo main-block, retry main-block .
                end.
                if available buf_term-dis-rule
                and term_tot-dis-rule_.status_ = 'N' then do:
                  v-err-mess = substitute("Ошибка при изменении правила скидок на итог &1 (типа &2)&3уже есть ветка с суммой &4"
                                          , v-rule-num
                                          , v-templ-rl-root
                                          , chr(10)
                                          , term_tot-dis-rule_.tot-sum
                                          ).
                  run set-err-type in p-cont-handle
                    ( input 'SYNCHRONIZATION'
                    ) no-error.
                  undo main-block, retry main-block .
                end.
                if available buf_term-dis-rule
                and term_tot-dis-rule_.status_ = 'U'
                and term_tot-dis-rule_.tot-sum = buf_term-dis-rule.tot-sum
                then do:
                  v-err-mess = substitute("Ошибка при изменении правила скидок на итог &1 (типа &2)&3ветка с суммой &4 уже имеет скидку &5"
                                          , v-rule-num
                                          , v-templ-rl-root
                                          , chr(10)
                                          , term_tot-dis-rule_.tot-sum
                                          , term_tot-dis-rule_.discnt-value
                                          ).
                  run set-err-type in p-cont-handle
                    ( input 'SYNCHRONIZATION'
                    ) no-error.
                  undo main-block, retry main-block .
                end.
              end.
              ii = 0.
              for each buf_term-dis-rule no-lock where
                      buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
                find first term_tot-dis-rule_ where
                          term_tot-dis-rule_.tot-sum = buf_term-dis-rule.tot-sum no-error.
                if not available term_tot-dis-rule_ then do:
                  ii = ii + 1.
                  create term_tot-dis-rule_.
                  buffer-copy buf_term-dis-rule
                  except rule-num upper-rule-num rl-root des
                  to  term_tot-dis-rule_
                  assign
                  term_tot-dis-rule_.upper-rule-num = buf_tot-dis-rule_.rule-num
                  term_tot-dis-rule_.rl-root = buf_tot-dis-rule_.rule-num
                  term_tot-dis-rule_.rule-num = - ii
                  .
                  release term_tot-dis-rule_.
                end.
              end.
              ii = 0.
              for each term_tot-dis-rule_ where
                     term_tot-dis-rule_.upper-rule-num = buf_tot-dis-rule_.rule-num
              by term_tot-dis-rule_.tot-sum  descending
              :
                if term_tot-dis-rule_.status_ <> 'D' then do:
                  ii = ii + 1.
                  create term_tt-dis-rule.
                  buffer-copy term_tot-dis-rule_
                  except rule-num upper-rule-num des rl-root host-code obj-type obj-code
                  to
                  term_tt-dis-rule
                  assign
                  term_tt-dis-rule.rule-num = ii
                  term_tt-dis-rule.upper-rule-num = term_tot-dis-rule_.templ-rl-root
                  term_tt-dis-rule.rl-root = term_tot-dis-rule_.templ-rl-root
                  term_tt-dis-rule.host-code = buf_clients.host-code
                  term_tt-dis-rule.obj-type = buf_clients.obj-type
                  term_tt-dis-rule.obj-code = buf_clients.obj-code
                  term_tt-dis-rule.des =  term_tt-dis-rule.des + (IF term_tt-dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                              substitute("&1 &2"
                                                        ,(IF ii = 1
                                                          THEN SUBstitute("свыше &1", term_tot-dis-rule_.tot-sum)
                                                          ELSE SUBSTITUTE("от &1 до &2"
                                                                        , term_tot-dis-rule_.tot-sum
                                                                        , v-tot-sum)
                                                          ))
                  v-tot-sum = term_tt-dis-rule.tot-sum
                  .
                end.
              end.
              v-sts = integer('1':U).
              run ref/dis-rul2.p (
                                buffer buf_dis-rule
                              , input yes
                              , input dflt-cd
                              , input-output v-sts
                              ) no-error.
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при логическом удалении правила скидок на итог &1 (типа &2):&3&4&3&5"
                                        , v-rule-num
                                        , v-templ-rl-root
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
                undo main-block, retry main-block .
              end.
              v-rid = ?.
              run ref/dis-rul1.p (
              input ?
              ,input dflt-cd
              ,input buf_tot-dis-rule_.templ-rl-root
              ,input buf_tot-dis-rule_.templ-rl-root
              ,input buf_tot-dis-rule_.des
              ,input buf_tot-dis-rule_.dis-kat
              ,input buf_tot-dis-rule_.discnt-type
              ,input buf_tot-dis-rule_.doc-qnty
              ,input buf_tot-dis-rule_.tot-sum
              ,input buf_tot-dis-rule_.charkey_one
              ,input buf_tot-dis-rule_.charkey_two
              ,input buf_tot-dis-rule_.charkey_three
              ,input buf_tot-dis-rule_.deckey_one
              ,input buf_tot-dis-rule_.deckey_two
              ,input buf_tot-dis-rule_.deckey_three
              ,input buf_tot-dis-rule_.key#_one
              ,input buf_tot-dis-rule_.key#_two
              ,input buf_tot-dis-rule_.key#_three
              ,input buf_tot-dis-rule_.subject-type
              ,input buf_tot-dis-rule_.time-templ-rl-root
              ,input buf_tot-dis-rule_.time-rule-num
              ,input buf_tot-dis-rule_.upper-rule-num
              ,input buf_tot-dis-rule_.value-type
              ,input buf_clients.host-code
              ,INPUT buf_clients.obj-type
              ,INPUT buf_clients.obj-code
              ,INPUT buf_tot-dis-rule_.discnt-value
              ,input table term_tt-dis-rule
              ,input-output v-rid
              ,input 'ДОБАВЛЕНИЕ':U
              ,input yes
              ) NO-ERROR.
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при изменении правила скидок на итог &1 (типа &2):&3&4&3&5"
                                        , v-rule-num
                                        , v-templ-rl-root
                                        , chr(10)
                                        , error-status:get-message(1)
                                        , return-value
                                        ).
                undo main-block, retry main-block .
              end.
            end.
            else do:
              v-err-mess = substitute("Невозможно изменить правило скидок на итог &1 (типа &2) - правило не существует"
                                        , v-rule-num
                                        , v-templ-rl-root
                                        , return-value
                                        ).
            end.
          end.
          else do:
            v-err-mess = substitute("Ошибка при изменении правила скидок на итог &1 (типа &2)&3Нет такого правила"
                                    , v-rule-num
                                    , v-templ-rl-root
                                    , chr(10)
                                    ).
            run set-err-type in p-cont-handle
              ( input 'SYNCHRONIZATION'
              ) no-error.
            undo main-block, retry main-block .
          end.
        end.
      end.
      when 'N' then do:
        for each buf_clients no-lock where
                buf_clients.db-num = g#db-num
            and buf_clients.obj-type = 'маг':U
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          empty temp-table term_tt-dis-rule.
          dflt-cd = ''.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type23 as character no-undo .
define variable v-value-date23 as date no-undo .
define variable v-value-decimal23 as decimal no-undo .
define variable v-value-integer23 as INTEGER no-undo .
define variable v-value-logical23 AS LOGICAL no-undo .
define variable v-tth23 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  buf_Clients.obj-type
    ,input  buf_clients.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date23
    ,output v-value-decimal23
    ,output v-value-integer23
    ,output v-value-logical23
    ,output v-param-type23
    ,INPUT-OUTPUT table-handle v-tth23
    )  .
delete object v-tth23 no-error.
          find first buf_dis-thbj-rule share-lock where
                    buf_dis-thbj-rule.obj-type = buf_clients.obj-type
                and buf_dis-thbj-rule.obj-code = buf_clients.obj-code
                and buf_dis-thbj-rule.host-code = buf_clients.host-code
                and buf_dis-thbj-rule.pos-type = dflt-cd
                and buf_dis-thbj-rule.discnt-role = 'pcnt-tot-kateg':U
                and buf_dis-thbj-rule.nonunique = '' no-error.
          if available buf_dis-thbj-rule then do:
            find first buf_dis-rule share-lock where
                      buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num no-error.
            if available buf_dis-rule then do:
              v-err-mess = substitute("Невозможно создать правило скидки на итог в &1&2 - такое правило уже есть (&3)"
                                      , buf_dis-thbj-rule.obj-type
                                      , buf_dis-thbj-rule.obj-code
                                      , buf_dis-rule.rule-num
                                      ).
              run set-err-type in p-cont-handle
                ( input 'SYNCHRONIZATION'
                ) no-error.
              undo main-block, retry main-block .
            end.
          end.
          ii = 0.
          FOR EACH term_tot-dis-rule_
          where term_tot-dis-rule_.upper-rule-num = buf_tot-dis-rule_.rule-num
          BY term_tot-dis-rule_.tot-sum DESCENDING:
            if term_tot-dis-rule_.status_ <> 'N' then do:
              v-err-mess = substitute("Невозможно создать правило скидки на итог в &1&2 - неверный статус для ветки с суммой &3:&4&5"
                                      , buf_clients.obj-type
                                      , buf_clients.obj-code
                                      , term_tot-dis-rule_.tot-sum
                                      ).
              run set-err-type in p-cont-handle
                ( input 'SYNCHRONIZATION'
                ) no-error.
              undo main-block, retry main-block .
            end.
            create term_tt-dis-rule.
            buffer-copy term_tot-dis-rule_
            except rule-num upper-rule-num rl-root obj-type obj-code host-code
            to term_tt-dis-rule
            ASSIGN
            ii = ii + 1
            term_tt-dis-rule.rule-num = ii
            term_tt-dis-rule.upper-rule-num = term_tot-dis-rule_.templ-rl-root
            term_tt-dis-rule.rl-root = term_tot-dis-rule_.templ-rl-root
            term_tt-dis-rule.host-code = buf_clients.host-code
            term_tt-dis-rule.obj-type = buf_clients.obj-type
            term_tt-dis-rule.obj-code = buf_clients.obj-code
            term_tt-dis-rule.des =  term_tt-dis-rule.des + (IF term_tt-dis-rule.des = "":U THEN "@":U ELSE "":U) +
                                        substitute("&1 &2"
                                                  ,(IF ii = 1
                                                    THEN SUBstitute("свыше &1", term_tot-dis-rule_.tot-sum)
                                                    ELSE SUBSTITUTE("от &1 до &2"
                                                                  , term_tot-dis-rule_.tot-sum
                                                                  , v-tot-sum)
                                                    ))
            v-tot-sum = term_tt-dis-rule.tot-sum
            .
          END.
          v-rid = ?.
          run ref/dis-rul1.p (
           input ?
          ,input dflt-cd
          ,input buf_tot-dis-rule_.templ-rl-root
          ,input buf_tot-dis-rule_.templ-rl-root
          ,input buf_tot-dis-rule_.des
          ,input buf_tot-dis-rule_.dis-kat
          ,input buf_tot-dis-rule_.discnt-type
          ,input buf_tot-dis-rule_.doc-qnty
          ,input buf_tot-dis-rule_.tot-sum
          ,input buf_tot-dis-rule_.charkey_one
          ,input buf_tot-dis-rule_.charkey_two
          ,input buf_tot-dis-rule_.charkey_three
          ,input buf_tot-dis-rule_.deckey_one
          ,input buf_tot-dis-rule_.deckey_two
          ,input buf_tot-dis-rule_.deckey_three
          ,input buf_tot-dis-rule_.key#_one
          ,input buf_tot-dis-rule_.key#_two
          ,input buf_tot-dis-rule_.key#_three
          ,input buf_tot-dis-rule_.subject-type
          ,input buf_tot-dis-rule_.time-templ-rl-root
          ,input buf_tot-dis-rule_.time-rule-num
          ,input buf_tot-dis-rule_.upper-rule-num
          ,input buf_tot-dis-rule_.value-type
          ,input buf_clients.host-code
          ,INPUT buf_clients.obj-type
          ,INPUT buf_clients.obj-code
          ,INPUT buf_tot-dis-rule_.discnt-value
          ,input table term_tt-dis-rule
          ,input-output v-rid
          ,input 'ДОБАВЛЕНИЕ':U
          ,input yes
          ) NO-ERROR.
          if error-status:error then do:
            v-err-mess = substitute("Ошибка при создании правила скидки на итог в &1&2:&3&4&3&5"
                                    , buf_clients.obj-type
                                    , buf_clients.obj-code
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
          end.
        end.
      end.
    end case.
  end.
end.
end procedure.
