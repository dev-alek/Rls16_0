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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 1".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define  temp-table temp-xml-tables no-undo
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
define  temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                                                        ,vss-include-info6
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info6
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info6, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info6 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info6 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info6, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info6 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info6 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info6, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info6 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info6 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info6, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info6 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info6 )
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table ord-list no-undo
field host-code  like ub.ord-doc.host-code
field cli-type   like ub.ord-doc.cli-type
field cli-code   like ub.ord-doc.cli-code
field doc-date   like ub.ord-doc.doc-date
field doc-code   like ub.ord-doc.doc-code
field obj-type   like ub.ord-doc.obj-type
field obj-code   like ub.ord-doc.obj-code
field fact-num   like ub.ord-doc.fact-num
field fact-date  like ub.ord-doc.fact-date
field shift-date like ub.ord-doc.shift-date
field shift-num  like ub.ord-doc.shift-num
field shift-name like ub.ord-doc.shift-name
field ord-int1   like ub.ord-doc.ord-int1
field cli-out-doc like ub.ord-doc.cli-out-doc
field ship-date  like ub.ord-doc.ship-date
field ship-time  like ub.ord-doc.ship-time
field status_    as character
field trn-doc    as character
field fact-order as decimal
field is-trn-doc as logical
field doc-type   like ub.ord-doc.doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field ps         as character
field dm         as integer
field charkey_one as character
index xpk is primary unique doc-code doc-type trn-doc
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION rum-fn_get-next-file-name returns character (
                                    input p-base-file-name as character
                                  , input p-index as integer):
define variable v-loc-file-name as character no-undo .
v-loc-file-name = substitute("&1_&2.&3"
                            ,substring(p-base-file-name, 1, (if r-index(p-base-file-name, ".") > 1
                                                      then (r-index(p-base-file-name, ".") - 1)
                                                      else length(p-base-file-name)
                                                      )
                                        )
                            ,p-index
                            ,(if r-index(p-base-file-name, ".") > 1
                              then substring(p-base-file-name, r-index(p-base-file-name, ".") + 1)
                              else '')
                              )
                              .
return v-loc-file-name.
end function.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function context_get-thobj-es return logical
(
   input p-esys-id as integer
  ,input p-eobj-type as character
  ,input p-eobj-code as integer
  ,output p-obj-type as character
  ,output p-obj-code as integer
):
   define variable v-value-list as character no-undo .
   define variable v-field-list as character no-undo .
   define buffer buf_clients for ub.clients.
   define buffer buf_ext-classif for ub.ext-classif.
   find first buf_ext-classif no-lock where
             buf_ext-classif.classif-name = 'clients-esys':U
         and buf_ext-classif.classif-subject = 'clients':U
         and buf_ext-classif.db-num = 0
         and buf_Ext-classif.key#_one = p-esys-id
         and buf_Ext-classif.charkey_one = p-eobj-type
         and buf_Ext-classif.key#_two = p-eobj-code no-error .
   if available buf_Ext-classif
   then do:
      ObjSrv:Lib:KeyRec:GenKeyFv (
                                      input buf_Ext-classif.uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
      assign
         p-obj-type = entry(lookup("obj-type":U
                                  , v-field-list
                                  , chr(3))
                                  , v-value-list, chr(3))
         p-obj-code = integer(entry(lookup("obj-code":U
                                         , v-field-list
                                         , chr(3))
                                   , v-value-list
                                   , chr(3)))
      no-error .
   end.
   if     available buf_ext-classif
      and (p-obj-type = 'маг':U
           or
           p-obj-type = 'скл':U
           )
      and (p-obj-code > 0 and p-obj-code <= 99999)
   then do:
      find first buf_clients no-lock where
                 buf_clients.obj-type = p-obj-type
             and buf_clients.obj-code = p-obj-code no-error.
      if available buf_clients then do:
         return yes.
      end.
      else do:
         assign
            p-obj-type = '':U
            p-obj-code = 0
         .
         return no.
      end.
   end.
   else do:
      assign
         p-obj-type = '':U
         p-obj-code = 0
      .
      return no.
   end.
end.
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ext-system-attr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-code in g#attr-lib
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
procedure ext-system-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-tooltip in g#attr-lib
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
procedure ext-system-attr-value :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
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
procedure ext-system-attr-write :
  define input parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define input parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (input p-esys-id
      ,input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-exist :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-exist in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-delete :
  define input  parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-delete in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ord-code :
define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .
define variable          v-idop     as character no-undo .
  do
  on error undo, return error return-value
  :
case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
      else
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
    end.
    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
          else
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.
    when "chip" then do:
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          substring (v-idop , 1, index (v-idop, "-")) +
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.
end case.
  end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ordlineattr-value :
  do
  on error undo, return error return-value
  :
    define input  parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input  parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input  parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-value    like ub.ord-line-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr no-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if avail buf_ord-line-attr then do:
      assign
        p-value =  buf_ord-line-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure ordlineattr-write :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define input parameter p-value    like ub.ord-line-attr.attr-value no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .
      undo, return error return-value .
    end.
    find first buf_ord-line-attr exclusive-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if not available buf_ord-line-attr then do:
      create buf_ord-line-attr .
      assign
        buf_ord-line-attr.doc-code   = p-doc-code
        buf_ord-line-attr.gds-code   = p-gds-code
        buf_ord-line-attr.attr-code  = p-code
      .
    end.
    assign
      buf_ord-line-attr.attr-value = p-value
    .
end.
end procedure.
procedure ordlineattr-exist :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr no-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error .
    if  available buf_ord-line-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure ordlineattr-delete :
  do
  on error undo, return error return-value
  :
    define input parameter p-doc-code like ub.ord-line-attr.doc-code   no-undo .
    define input parameter p-gds-code like ub.ord-line-attr.gds-code   no-undo .
    define input parameter p-code     like ub.ord-line-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_ord-line-attr for ub.ord-line-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-fillin_width   as integer   no-undo .
    define variable v-fillin_height  as integer   no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-proc           as character no-undo .
    define variable v-func           as character no-undo .
    define variable v-sort           as integer   no-undo .
    define variable v-other          as character no-undo .
    run ordlineattr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-fillin_width
      ,output v-fillin_height
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-proc
      ,output v-func
      ,output v-sort
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_ord-line-attr exclusive-lock
      where buf_ord-line-attr.doc-code  = p-doc-code
        and buf_ord-line-attr.gds-code  = p-gds-code
        and buf_ord-line-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_ord-line-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_ord-line-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure ordlineattr-code :
  do on error undo, return error return-value
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-fillin_width   as integer   no-undo .
    define output parameter p-fillin_height  as integer   no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-proc           as character no-undo .
    define output parameter p-func           as character no-undo .
    define output parameter p-sort           as integer   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'cycle-cli-qnty':U then do:     assign     p-label          = "Количество"     p-type           = 'D':U      p-format         = ">>>>>>>>>>>>>>>9.999"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "Количество"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
            when 'ord-EAN13':U then do:     assign     p-label          = "EAN в EDI"     p-type           = 'C':U      p-format         = "X(13)"     p-fillin_width   = 20     p-fillin_height  = 1     p-label          = "EAN в EDI"     p-user-can-edit  = false     p-output-display = false     p-sort           = 10     p-proc           = '':u     p-func           = '':u     p-other          = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут строки заказа" + " " + p-code .
      end.
    end.
  end.
end procedure.
FUNCTION cr-edist_get-mess-mean returns character ( input p-mess as character):
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-mess as character no-undo .
do v-ii = 1 to num-entries(p-mess, chr(4) ):
  v-dop = entry(v-ii, p-mess, chr(4) ).
  case entry(1, v-dop, "="):
    when 'pack-num':U then do:
      v-dop1 =  substitute("&1 &2", 'Пакет', entry(2, v-dop, "=")).
    end.
    when 'route':U then do:
      v-dop1 =  substitute("&1 &2", 'Рут':U, entry(2, v-dop, "=")).
    end.
    when 'ediiterchangeid':U then do:
      v-dop1 =  substitute("&1 &2", 'ediiterchangeid':U, entry(2, v-dop, "=")).
    end.
    when 'price-up':U then do:
      v-dop1 =  substitute("&1 &2", 'Цена':U, entry(2, v-dop, "=")).
    end.
    when 'price-down':U then do:
      v-dop1 =  substitute("&1 &2", 'Цена':U, entry(2, v-dop, "=")).
    end.
    when 'vat-change':U then do:
      v-dop1 =  substitute("&1 &2", 'НДС':U, entry(2, v-dop, "=")).
    end.
    when 'ps':U then do:
      v-dop1 =  substitute("&1 &2", ' ':U, entry(2, v-dop, "=")).
    end.
    when 'info':U then do:
      v-dop1 =  substitute("&1 &2", 'Инф:':U, entry(2, v-dop, "=")).
    end.
    when 'qnty-up':U then do:
      v-dop1 =  substitute("&1 &2", 'Кол-во':U, entry(2, v-dop, "=")).
    end.
    when 'qnty-down':U then do:
      v-dop1 =  substitute("&1 &2", 'Кол-во':U, entry(2, v-dop, "=")).
    end.
    when 'bstr-change':U then do:
      v-dop1 =  substitute("&1 &2", 'Штрихкод:':U, entry(2, v-dop, "=")).
    end.
    when 'shipdate-change':U then do:
      v-dop1 =  substitute("&1 &2", 'Дата отгрузки:':U, entry(2, v-dop, "=")).
    end.
    when 'clioutdoc-change':U then do:
      v-dop1 =  substitute("&1 &2", '№ заказа по пост-ку:':U, entry(2, v-dop, "=")).
    end.
  end case.
  v-mess  = v-mess + (if v-mess = '' then '' else chr(32)) + v-dop1.
end.
return v-mess.
end function.
FUNCTION cr-edist_get-error-mean returns character ( input p-mess as character):
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-mess as character no-undo .
do v-ii = 1 to num-entries(p-mess, chr(4) ):
  v-dop = entry(v-ii, p-mess, chr(4) ).
  case entry(1, v-dop, "="):
    when 'pack-num':U then do:
      v-dop1 =  substitute("&1 &2", 'Пакет', entry(2, v-dop, "=")).
    end.
    when 'route':U then do:
      v-dop1 =  substitute("&1 &2", 'Рут':U, entry(2, v-dop, "=")).
    end.
    when 'ediiterchangeid':U then do:
      v-dop1 =  substitute("&1 &2", 'ediiterchangeid':U, entry(2, v-dop, "=")).
    end.
    when 'price-up':U then do:
      v-dop1 =  substitute("&1 &2", 'Цена':U, entry(2, v-dop, "=")).
    end.
    when 'price-down':U then do:
      v-dop1 =  substitute("&1 &2", 'Цена':U, entry(2, v-dop, "=")).
    end.
    when 'vat-change':U then do:
      v-dop1 =  substitute("&1 &2", 'НДС':U, entry(2, v-dop, "=")).
    end.
    when 'ps':U then do:
      v-dop1 =  substitute("&1 &2", ' ':U, entry(2, v-dop, "=")).
    end.
    when 'info':U then do:
      v-dop1 =  substitute("&1 &2", 'Инф:':U, entry(2, v-dop, "=")).
    end.
    when 'qnty-up':U then do:
      v-dop1 =  substitute("&1 &2", 'Кол-во':U, entry(2, v-dop, "=")).
    end.
    when 'qnty-down':U then do:
      v-dop1 =  substitute("&1 &2", 'Кол-во':U, entry(2, v-dop, "=")).
    end.
    when 'bstr-change':U then do:
      v-dop1 =  substitute("&1 &2", 'Штрихкод:':U, entry(2, v-dop, "=")).
    end.
    when 'shipdate-change':U then do:
      v-dop1 =  substitute("&1 &2", 'Дата отгрузки:':U, entry(2, v-dop, "=")).
    end.
    when 'clioutdoc-change':U then do:
      v-dop1 =  substitute("&1 &2", '№ заказа по пост-ку:':U, entry(2, v-dop, "=")).
    end.
  end case.
  v-mess  = v-mess + (if v-mess = '' then '' else chr(4)) + v-dop1.
end.
return v-mess.
end function.
FUNCTION cr-edist_get-mess-key-value returns character ( input p-mess as character, input p-key as character):
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-value as character no-undo .
do v-ii = 1 to num-entries(p-mess, chr(4) ):
  v-dop = entry(v-ii, p-mess, chr(4) ).
  if entry(1, v-dop, "=") = p-key then do:
    return entry(2, v-dop, "=").
  end.
end.
return v-value.
end function.
FUNCTION cr-edist_add-edist-mess returns character ( input p-mess as character
                                                     ,input p-key as character
                                                     ,input p-value as character):
define variable v-dop as character no-undo .
define variable v-modificator as character no-undo .
assign
v-modificator = entry(2, p-key, "-") no-error .
case v-modificator:
  when "up" then do:
    v-dop = substitute("&1=&2<&3", p-key, entry(1, p-value, chr(4)) , entry(2, p-value, chr(4))).
  end.
  when "down" then do:
    v-dop = substitute("&1=&2>&3", p-key, entry(1, p-value, chr(4)) , entry(2, p-value, chr(4))).
  end.
  when "change" then do:
    v-dop = substitute("&1=&2 ->&3", p-key, entry(1, p-value, chr(4)) , entry(2, p-value, chr(4))).
  end.
  otherwise do:
    v-dop = substitute("&1=&2", p-key, p-value).
  end.
end case.
if p-mess = ''
or p-mess = ? then do:
  return v-dop .
end.
else do:
  return substitute("&1&2&3", p-mess, chr(4), v-dop).
end.
end function.
procedure create-edi-state :
define input  parameter p-tbl-name   as character no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-cli-type   as character no-undo .
define input  parameter p-cli-code   as integer   no-undo .
define input  parameter p-act        as character no-undo .
define input  parameter p-state      as character no-undo .
define input  parameter p-err        as integer   no-undo .
define input  parameter p-des        as character no-undo .
define input  parameter p-mess       as character no-undo .
define input  parameter p-dm         as integer  no-undo .
define input-output parameter p-date       as date no-undo .
define input-output parameter p-time       as integer no-undo .
define buffer buf_EDI-status for ub.EDI-status  .
define variable v-time as integer   no-undo .
define variable v-date as date   no-undo .
do
on error undo, return error return-value
:
  if p-date = ? then do:
    run cur-time in this-procedure ( output v-date, output v-time).
  end.
  else do:
    assign
    v-date = p-date
    v-time = p-time
    .
  end.
  find first buf_edi-status exclusive-lock where
              buf_edi-status.date-status = v-date
          and buf_edi-status.time-status = v-time
          and buf_edi-status.tbl-name    = p-tbl-name
          and buf_edi-status.doc-code    = p-doc-code no-error .
  if not available buf_edi-status  then do:
    create buf_edi-status.
  end.
  assign
  buf_edi-status.act         = p-act        .
  buf_edi-status.cli-type    = p-cli-type   .
  buf_edi-status.cli-code    = p-cli-code   .
  buf_edi-status.des-err     = buf_edi-status.des-err + (if buf_edi-status.des-err = '' then '' else chr(4)) + p-des        .
  buf_edi-status.doc-code    = p-doc-code   .
  buf_edi-status.err-code    = p-err        .
  buf_edi-status.mess-id     = buf_edi-status.mess-id + (if buf_edi-status.mess-id = '' then '' else chr(4)) + p-mess       .
  buf_edi-status.state       = p-state      .
  buf_edi-status.tbl-name    = p-tbl-name   .
  buf_edi-status.date-status = v-date       .
  buf_edi-status.time-status = v-time       .
  buf_edi-status.whole-send-news = p-dm     .
  buf_edi-status.user-name   = (if g#news then (chr(4) +  'СПН':U)
                                    else (if g#esys
                                          then (chr(4) +  'ВС':U)
                                          else g#userid)
                                    )       .
  assign
  p-date = buf_edi-status.date-status
  p-time = buf_edi-status.time-status
  .
end.
end procedure.
procedure update-edi-state-light :
define input  parameter p-tbl-name   as character no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-date-status as date no-undo .
define input  parameter p-time-status as integer no-undo .
define input  parameter p-state      as character no-undo .
define input  parameter p-err        as integer   no-undo .
define input  parameter p-des        as character no-undo .
define input  parameter p-mess       as character no-undo .
define buffer buf_edi-status for ub.edi-status.
do
on error undo, return error
:
  find first buf_edi-status exclusive-lock where
              buf_edi-status.date-status = p-date-status
          and buf_edi-status.time-status = p-time-status
          and buf_edi-status.tbl-name    = p-tbl-name
          and buf_edi-status.doc-code    = p-doc-code no-error .
  if available buf_edi-status  then do:
    assign
    buf_edi-status.des-err     = p-des        .
    buf_edi-status.err-code    = p-err        .
    buf_edi-status.mess-id     = p-mess       .
    buf_edi-status.state       = p-state      .
  end.
end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE write-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
               ub.contract-specif-attr.contract-num = p-contract-num  and
               ub.contract-specif-attr.host-code    = p-host-code     and
               ub.contract-specif-attr.gds-code     = p-gds-code      and
               ub.contract-specif-attr.attr-code    = 'bonus':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'bonus':U
         .
      end.
      ub.contract-specif-attr.attr-value  = string (v-bonus) .
end.
END PROCEDURE.
PROCEDURE read-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'bonus':U
           no-error .
   if available ub.contract-specif-attr then  v-bonus = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-bonus = 0 .
end.
END PROCEDURE.
PROCEDURE write-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-prc-min        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              ub.contract-specif-attr.attr-value  = string (v-prc-min)
         .
      end.
      else do:
         ub.contract-specif-attr.attr-value  = string (v-prc-min) .
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-prc-min as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'prc-min':U
           no-error .
   if available ub.contract-specif-attr then  v-prc-min = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-prc-min = 0 .
end.
END PROCEDURE.
PROCEDURE write-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = "retro-bonus"
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = "retro-bonus"
         .
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
      else do:
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = "retro-bonus"
           no-error .
   if available ub.contract-specif-attr then  v-retro-bonus = ub.contract-specif-attr.attr-value  .
                                        else  v-retro-bonus = "" .
end.
END PROCEDURE.
define variable v-desadv-DELIVERYNOTENUMBER as character no-undo.
define variable v-desadv-DELIVERYNOTEDATE as date no-undo.
define variable v-cli-out-doc as character no-undo .
define variable v-desadv-invoiceNUMBER as character no-undo.
define variable v-desadv-invoiceDATE as date no-undo.
define temp-table temp-ord-line no-undo
field doc-code      as character
field trn-doc      as character
field cliart        as character
field artth         as character
field nameth        as character
field quantityquant as decimal
field pricequant    as decimal
field status_       as character
field desstatus     as character
field code39        as character
index pi  doc-code cliart trn-doc
.
define temp-table temp-rcv-line-new no-undo like ub.ord-line-rcv .
procedure edocsord_export :
define parameter buffer buf_ord-doc for ub.ord-doc.
define input parameter p-ext-rcv-code as character no-undo .
define input parameter p-status_ as integer no-undo .
do
on error undo, return error
:
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
    find first buf_ord-doc-rcv exclusive-lock where
             buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
         and buf_ord-doc-rcv.sub-par begins string(trim(p-ext-rcv-code) + chr(4)) no-error .
  if available buf_ord-doc-rcv then do:
     assign
      buf_ord-doc-rcv.ord-int1 = p-status_
     .
  end.
  assign
    buf_ord-doc.ord-int1 = p-status_
  .
end.
end procedure.
procedure edocsord_import :
define parameter buffer buf_ord-doc for ub.ord-doc.
define input parameter p-ext-status as character no-undo .
define input parameter p-trn-code as character no-undo .
define input parameter p-ps as character no-undo .
define buffer buf_ord-list for ord-list.
do
on error undo, return error
:
  case p-ext-status :
    when 'stk-ok':U or
    when 'rpl':U    or
    when 'acc-ok':U or
    when 'pst':U
    then do:
       if (p-ext-status = 'pst':U
       and buf_ord-doc.ord-int1 < integer('6':U) )
       or (p-ext-status <> 'pst':U
          and buf_ord-doc.ord-int1 <> lookup ( p-ext-status , 'stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err' ) - 1) then do:
          find first buf_ord-list where
                     buf_ord-list.doc-code = buf_ord-doc.doc-code no-error.
          buf_ord-list.ord-int1 = buf_ord-doc.ord-int1 .
          for each temp-ord-line where
                   temp-ord-line.doc-code = buf_ord-doc.doc-code:
            delete temp-ord-line.
          end.
                    return error substitute("Статус заказа &1 в БД = &2(&3), принять данные о статусе &4(&5) от поставщика еще/уже не можем"
                                  ,buf_ord-doc.doc-code
                                  ,entry (lookup (string(buf_ord-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ')
                                  ,entry (lookup (string(buf_ord-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err')
                                  ,entry(lookup(p-ext-status, 'stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err'), ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ')
                                  ,p-ext-status
                                  ).
       end.
    end.
  end case.
  case p-ext-status :
    when 'stk-ok':U or
    when 'err':U or
    when 'acc-ok':U
    then do:
      run proc-ord in this-procedure ( input p-ext-status
                                      ,input buf_ord-doc.doc-code
                                      ,input ''
                                      ,input p-ps
                                      ) .
      for each temp-ord-line where
               temp-ord-line.doc-code = buf_ord-doc.doc-code:
        delete temp-ord-line.
      end.
      find first buf_ord-list where
                buf_ord-list.doc-code = buf_ord-doc.doc-code no-error.
      if available buf_ord-list then do:
        delete buf_ord-list.
      end.
    end.
    when 'rpl':U
    then do:
      run proc-reply in this-procedure (
                                          input p-ext-status
                                         ,input buf_ord-doc.doc-code)  .
      for each temp-ord-line where
               temp-ord-line.doc-code = buf_ord-doc.doc-code:
        delete temp-ord-line.
      end.
      find first buf_ord-list where
                buf_ord-list.doc-code = buf_ord-doc.doc-code no-error.
      if available buf_ord-list then
      assign
      buf_ord-list.ord-int1 = integer('4':U)
      buf_ord-list.sel-order = 1
      buf_ord-list.dm = integer('1':U)
      .
    end.
    when 'pst':U
    then do:
      run proc-gen-rcv in this-procedure ( input p-ext-status
                                          ,input buf_ord-doc.doc-code
                                          ,input p-trn-code
                                          ,input buf_ord-doc.ship-date
                                          )  no-error.
      if error-status:error then do:
        for each temp-rcv-line-new:
          delete temp-rcv-line-new.
        end.
        undo, return error substitute("Ошибка при приеме поставки &1&2&3&2&4"
                                   , p-trn-code
                                   , chr(10)
                                   , error-status:get-message(1)
                                   , return-value
                                   ).
      end.
      for each temp-ord-line where
               temp-ord-line.doc-code = buf_ord-doc.doc-code and
               temp-ord-line.trn-doc = p-trn-code:
        delete temp-ord-line.
      end.
      find first buf_ord-list where
                buf_ord-list.doc-code = buf_ord-doc.doc-code
             and buf_ord-list.trn-doc = p-trn-code     no-error.
      if available buf_ord-list then
      assign
      buf_ord-list.ord-int1 = integer('8':U)
      buf_ord-list.sel-order = 1
      buf_ord-list.dm = integer('1':U)
      .
    end.
    otherwise do:
      return error substitute("От поставщика получен статус &1 (&2), что непредусмотрено протоколом"
                             ,p-ext-status
                             ,entry(lookup(p-ext-status, 'stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err'), ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ')
                             ).
    end.
  end case.
end.
end procedure.
define variable p-status-ord as character no-undo .
procedure proc-ord :
define input  parameter p-stts     as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-cli-out-doc as character no-undo .
define input  parameter p-ps as character no-undo .
define variable v-edist-mess as character no-undo .
define buffer buf_ord-doc for ub.ord-doc  .
  do
  on error undo, return error return-value
  :
  find first buf_ord-doc exclusive-lock where
             buf_ord-doc.doc-code = p-doc-code no-error .
    if available buf_ord-doc  then do:
    if buf_ord-doc.whole-send-news = integer('2':U) then do:
      assign
      buf_ord-doc.ord-int1 = integer(p-stts)
      buf_ord-doc.cli-out-doc = p-cli-out-doc
      .
      if p-stts = '6':U then do:
        run cus/ord-clos.p
          ( input  parParentProc
          , input  recid(buf_ord-doc)
          , input  buf_ord-doc.obj-type
          , input  buf_ord-doc.obj-code
          , input  g#db-num
          , input  false
          , input  "yes"
          ) no-error .
        if error-status:error then do:
          v-edist-mess = ''.
          v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'ps':U
                                               , substitute("Ошибка при переводе заказа в статус ПОСТАВКА&1&2&1&3"
                                               , chr(10)
                                               , error-status:get-message(1)
                                               , return-value )).
          run create-edi-statett in this-procedure (
                                                input 'ord-doc':U
                                              , input buf_ord-doc.doc-code
                                              , input buf_ord-doc.cli-type
                                              , input buf_ord-doc.cli-code
                                              , input 'ИЗМЕНЕНИЕ':U
                                              , input -1
                                              , input integer('4':U)
                                              , input v-edist-mess
                                              , input ''
                                              , input integer('2':U)
                                              ).
          undo, return error cr-edist_get-mess-mean( input  v-edist-mess).
        end.
      end.
      if p-stts = '99':U then do:
        buf_ord-doc.status_ = 'отказ':U .
        buf_ord-doc.ps = p-ps.
        buf_ord-doc.cli-out-doc = p-cli-out-doc.
      end.
    end.
    else do:
       assign
         buf_ord-doc.ord-int1 = lookup ( p-stts , 'stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err' )
       .
       if p-stts = 'err':U then do:
          buf_ord-doc.status_ = 'отказ':U .
          buf_ord-doc.ps = p-ps.
       end.
    end.
  end.
end.
end procedure.
procedure proc-trn :
define input  parameter p-stts     as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-trn-code as character no-undo .
define buffer buf_ord-doc     for ub.ord-doc  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-chain   for ub.ord-chain  .
define buffer buf_trn-doc     for ub.trn-doc  .
main-block:
  do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
  find first buf_ord-doc-rcv no-lock  where
             buf_ord-doc-rcv.doc-code = p-doc-code and
             entry(1, buf_ord-doc-rcv.sub-par,chr(4)) = p-trn-code
    no-error .
    if available buf_ord-doc-rcv  then do:
       for each buf_ord-chain  no-lock where
                buf_ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                buf_ord-chain.doc-type = 'rcv' and
            buf_ord-chain.rel-doc-type = 'trn'
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
            find first buf_trn-doc no-lock where
                       buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code no-error .
            if available buf_trn-doc then do:
            end.
       end.
  end.
end.
end procedure.
procedure proc-gen-rcv :
define input  parameter p-stts as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-trn-code as character no-undo .
define input  parameter p-ship-date as date      no-undo .
define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-line for ub.ord-line  .
define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
define variable v-all as logical   no-undo .
define variable v-psq as logical   no-undo .
define variable v-prc-diff as decimal   no-undo .
define variable v-param-type      as character  no-undo .
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-tth             as handle     no-undo .
define buffer buf_goods for ub.goods  .
define buffer buf_units for ub.units  .
  do
  on error undo, return error return-value
  :
  find first buf_ord-doc no-lock where
           buf_ord-doc.doc-code = p-doc-code no-error .
  if error-status :error then do:
     return error .
  end.
  run adm/shattri.p ( input "get":U
                    , input  buf_ord-doc.obj-type
                    , input  buf_ord-doc.obj-code
                    , input  'ord-obj':U
                    , input  'ord-wgt-div-prc':U
                    , output v-value-character
                    , output v-value-date
                    , output v-value-decimal
                    , output v-value-integer
                    , output v-value-logical
                    , output v-param-type
                    , input-output table-handle v-tth
                    ) no-error .
  if error-status :error then v-prc-diff = 0 .
  else do:
    v-prc-diff = v-value-decimal .
  end.
  delete object v-tth.
  for each temp-rcv-line-new :
    delete temp-rcv-line-new.
  end.
define variable v-ps as character no-undo .
v-ps = "".
v-all = true .
v-psq = false  .
  for each buf_ord-line no-lock where
           buf_ord-line.doc-code = p-doc-code ,
     first temp-ord-line where
           temp-ord-line.doc-code = buf_ord-line.doc-code and
           temp-ord-line.trn-doc = p-trn-code  and
           temp-ord-line.cliart   = buf_ord-line.cli-art  and
           temp-ord-line.artth    = buf_ord-line.artic
           :
           find first buf_goods no-lock where
                      buf_goods.artic     = buf_ord-line.artic     and
                      buf_goods.prod-code = buf_ord-line.prod-code and
                      buf_goods.prod-type = buf_ord-line.prod-type no-error .
                if error-status :error then do:
                   return error substitute( "По артикулу &1 &2&3 не найден товар в справочнике " , buf_ord-line.artic, buf_ord-line.prod-code, buf_ord-line.prod-type ).
                end.
            find first buf_units no-lock
              where buf_units.unit-name = buf_goods.unit-base
              no-error .
              if error-status :error then do:
        return error substitute( "По артикулу &1 не найдена ед.изм &2 " , buf_ord-line.artic,  buf_goods.unit-base  ).
              end.
           if v-prc-diff <> 0 and lookup('вес':U, buf_units.type) > 0 then do:
              if ( buf_ord-line.cli-qnty  * ( 100 + v-prc-diff ) / 100 ) < temp-ord-line.quantityquant  then do:
              return error substitute('Для весового товара количество по поставке &1 не может превышать количество по заказу &2 более чем на &3%.&4Максимальное допустимое значение &5.':u
                                          , temp-ord-line.quantityquant
                                          , buf_ord-line.cli-qnty
                                          , v-prc-diff
                                          , chr(10)
                                          , (buf_ord-line.cli-qnty  * ( 100 + v-prc-diff ) / 100 )
                                          ).
              end.
           end.
            if not (buf_ord-line.cli-qnty   = temp-ord-line.quantityquant ) then do:
               v-psq = true .
            end.
          if not ( buf_ord-line.price-cli  = temp-ord-line.pricequant ) then do:
            if v-all = true  then do :
            if length (v-ps) >= 2000  then do:
               assign
               v-ps = v-ps + "Есть еще информация о несовпадении цены, она не помещается в поле ПРИМЕЧАНИЕ "
               v-all = false .
            end.
            else do:
            v-ps = v-ps + substitute("Не совпадает цена для товара &1 &2&3 (артикул пост-ка &4) &5"
                        , buf_ord-line.artic
                        , buf_ord-line.prod-type
                        , buf_ord-line.prod-code
                        , buf_ord-line.cli-art
                        , chr(10)
                        ).
            end.
          end.
     end.
     create temp-rcv-line-new.
     buffer-copy buf_ord-line to temp-rcv-line-new
     assign
     temp-rcv-line-new.sub-par    = temp-ord-line.code39
     temp-rcv-line-new.cli-qnty   = temp-ord-line.quantityquant
     temp-rcv-line-new.price-cli  = temp-ord-line.pricequant
     temp-rcv-line-new.price-rubl = temp-rcv-line-new.price-cli * buf_ord-doc.exch-rate / buf_ord-doc.exch-scale / buf_ord-line.cli-base-rate
     temp-rcv-line-new.qnty       = temp-rcv-line-new.cli-qnty  * buf_ord-line.cli-base-rate
     temp-rcv-line-new.price-base = temp-rcv-line-new.price-rubl / buf_ord-doc.base-rate * buf_ord-doc.base-scale
     temp-rcv-line-new.sum-rubl   = temp-rcv-line-new.price-rubl * temp-rcv-line-new.qnty
     temp-rcv-line-new.sum-base   = temp-rcv-line-new.price-base * temp-rcv-line-new.qnty
     temp-rcv-line-new.sum-cli    = temp-rcv-line-new.price-cli  * temp-rcv-line-new.cli-qnty
     .
   end.
define variable loc-rcv-num as character no-undo .
define variable v-i-doc as character no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'main' ,
  input   g#db-num ,
  input   buf_ord-doc.obj-type ,
  input   buf_ord-doc.obj-code ,
  input   v-i-doc ,
  output  loc-rcv-num
 ) .
define variable ks as integer   no-undo init 0 .
  for each temp-rcv-line-new
  by temp-rcv-line-new.line-num :
  ks = ks + 1.
  create buf_ord-line-rcv.
  buffer-copy temp-rcv-line-new to buf_ord-line-rcv
  assign
    buf_ord-line-rcv.rcv-code  = loc-rcv-num
    buf_ord-line-rcv.line-num  = ks
    buf_ord-line-rcv.cli-qnty  = temp-rcv-line-new.cli-qnty
    buf_ord-line-rcv.qnty      = buf_ord-line-rcv.cli-qnty * temp-rcv-line-new.cli-base-rate
    .
end.
create buf_ord-doc-rcv.
 buffer-copy buf_ord-doc to buf_ord-doc-rcv
   assign
      buf_ord-doc-rcv.rcv-code  = loc-rcv-num
      buf_ord-doc-rcv.doc-type  = "out":u
      buf_ord-doc-rcv.doc-date  = today
      buf_ord-doc-rcv.status_   = 'поставка':U
      buf_ord-doc-rcv.ord-int1  = lookup ( p-stts , 'stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err' )
      buf_ord-doc-rcv.ord-int2  = 0
  buf_ord-doc-rcv.whole-send-news = buf_ord-doc.whole-send-news
   .
    if v-psq = true then v-ps = "Есть несовпадения по количествам . " + trim( v-ps ) .
    if v-ps <> "" then do:
        assign
          buf_ord-doc-rcv.ord-int2 = integer('2':U)
          buf_ord-doc-rcv.PS       = v-ps
        .
    end.
    if p-ship-date <> ? then buf_ord-doc-rcv.ship-date = p-ship-date .
    buf_ord-doc-rcv.sub-par = trim(p-trn-code) + chr(4) + trim(buf_ord-doc.vat-type) + chr(4) .
    assign
    buf_ord-doc.ord-int1 = integer('7':U)
    .
   find first ord-list where
              ord-list.doc-code = buf_ord-doc.doc-code and
              ord-list.trn-doc = p-trn-code.
   assign
      ord-list.ord-int1 = integer('8':U)
  ord-list.dm = integer('1':U)
   .
   release ord-list.
  end.
end procedure.
procedure proc-reply :
define input  parameter p-status_ as character no-undo .
define input  parameter p-doc-code as character no-undo .
define buffer buf_ord-doc for ub.ord-doc  .
define buffer buf_ord-line for ub.ord-line  .
  do
  on error undo, return error return-value
  :
  find first buf_ord-doc no-lock where buf_ord-doc.doc-code = p-doc-code no-error .
  if error-status :error then do:
     return error .
  end.
  for each buf_ord-line exclusive-lock where
           buf_ord-line.doc-code   = buf_ord-doc.doc-code
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
        assign
          buf_ord-line.order-cli-qnty   = buf_ord-line.cli-qnty
          buf_ord-line.ord-dec1         = buf_ord-line.price-cli
        .
          find first temp-ord-line where
                temp-ord-line.doc-code = buf_ord-line.doc-code and
                temp-ord-line.artth    = buf_ord-line.artic    and
                temp-ord-line.cliart   = buf_ord-line.cli-art no-error .
         if available temp-ord-line then do:
           assign
              buf_ord-line.cli-qnty         = temp-ord-line.quantityquant
              buf_ord-line.price-cli        = temp-ord-line.pricequant
              buf_ord-line.sub-par          = if temp-ord-line.status_    = '1' then ( temp-ord-line.desstatus + chr(4)) else chr(4)
              buf_ord-line.price-rubl       = buf_ord-line.price-cli * buf_ord-doc.exch-rate / buf_ord-doc.exch-scale / buf_ord-line.cli-base-rate
              buf_ord-line.qnty             = buf_ord-line.cli-qnty  * buf_ord-line.cli-base-rate
              buf_ord-line.price-base       = buf_ord-line.price-rubl / buf_ord-doc.base-rate * buf_ord-doc.base-scale
              buf_ord-line.sum-rubl         = buf_ord-line.price-rubl * buf_ord-line.qnty
              buf_ord-line.sum-base         = buf_ord-line.price-base * buf_ord-line.qnty
              buf_ord-line.sum-cli          = buf_ord-line.price-cli  * buf_ord-line.cli-qnty
           .
           end.
           else do:
              assign
                  buf_ord-line.cli-qnty         = 0
                  buf_ord-line.price-cli        = buf_ord-line.ord-dec1
                  buf_ord-line.sub-par          = "Строка удалена Поставщиком"
                  buf_ord-line.price-rubl       = buf_ord-line.price-cli * buf_ord-doc.exch-rate / buf_ord-doc.exch-scale / buf_ord-line.cli-base-rate
                  buf_ord-line.qnty             = buf_ord-line.cli-qnty  * buf_ord-line.cli-base-rate
                  buf_ord-line.price-base       = buf_ord-line.price-rubl / buf_ord-doc.base-rate * buf_ord-doc.base-scale
                  buf_ord-line.sum-rubl         = buf_ord-line.price-rubl * buf_ord-line.qnty
                  buf_ord-line.sum-base         = buf_ord-line.price-base * buf_ord-line.qnty
                  buf_ord-line.sum-cli          = buf_ord-line.price-cli  * buf_ord-line.cli-qnty
              .
           end.
   end.
   find first buf_ord-doc exclusive-lock where buf_ord-doc.doc-code = p-doc-code no-error .
   assign
     buf_ord-doc.ord-int1  = lookup(p-status_,'stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err')
   .
   define variable strerr as character no-undo .
   define variable v-all2 as logical   no-undo .
   strerr = "" .
   v-all2 = true .
   for each temp-ord-line  where temp-ord-line.doc-code = p-doc-code :
       find first buf_ord-line  no-lock  where
              buf_ord-line.doc-code = temp-ord-line.doc-code   and
              buf_ord-line.artic    = temp-ord-line.artth      and
              buf_ord-line.cli-art  = temp-ord-line.cliart    no-error .
   if not available buf_ord-line then do:
     if v-all2 = true  then do :
      assign
        strerr = strerr +
        substitute(" Арт.Поставщика &1, АртикулТН &2, &3, Количество &4, Цена &5 ;",
                      temp-ord-line.cliart,
                      temp-ord-line.artth ,
                      temp-ord-line.nameth,
                      temp-ord-line.quantityquant,
                      temp-ord-line.pricequant  ) .
       if length (strerr) >= 2000 then do:
          strerr = strerr + "Есть еще информация о товарах неуказанных в заказе..." .
          v-all2 = false .
       end.
      end.
      end.
   end.
   if strerr <> "" then do:
       buf_ord-doc.ord-int1  = integer('0':U).
       buf_ord-doc.PS        = "EDOC:Пришли товары неуказанные в заказе: " + chr(10) +
                               strerr + chr(10) +
                               buf_ord-doc.PS.
   end.
   find first ord-list where
              ord-list.doc-code = buf_ord-doc.doc-code.
   assign
   ord-list.ord-int1 = integer('4':U)
   ord-list.dm = integer('1':U)
   .
   release ord-list.
  end.
end procedure.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info24, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info24 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info24 )
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
define temp-table temp-esys no-undo
field esys-id as integer
field db-num as integer
field esys-name as character
field delivery-method as integer
field rowid_ as rowid
field ftp-ip as character
field ftp-login as character
field ftp-password as character
field ftp-path as character
index pi is unique primary
esys-id
.
define temp-table order-header no-undo
field ext-obj-code as integer
field doc-code as character
field trn-code as character
field status_ as character
field ship-date as date
field contract-code as character
index pi is unique primary
doc-code trn-code
.
define temp-table order-line no-undo
field doc-code as character
field trn-code as character
field cliart as character
field prod-type as character
field prod-code as integer
field artth as character
field nameth as character
field quantityquant as decimal
field pricequant  as decimal
field status_ as integer
field desstatus as character
index pi is unique primary
doc-code
artth
prod-type
prod-code
cliart
trn-code
.
define variable v-current-doc-code as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-oxml-exch-dir as character no-undo .
define variable v-oxml-heap-dir as character no-undo .
define variable v-type as character no-undo .
define variable v-cmd-line as character no-undo .
define variable ftp-prog as character no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure write-to-screen :
define input param p-str as character no-undo .
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input p-str).
end procedure.
procedure write-to-log :
define input param p-str as character no-undo .
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input p-str).
end procedure.
procedure write-to-log-notime :
define input param p-str as character no-undo .
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input p-str).
end procedure.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable p-xsd-file as character no-undo.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function context_begin-esys-command return logical
(
    input p-esys-id-list as character
   ,input-output p-esys-cmd-proc-handle as handle
   ,output p-esys-cmd-code as integer
):
   if not valid-handle(p-esys-cmd-proc-handle )
   then do:
     run nws/cmd-bush.p persistent set p-esys-cmd-proc-handle no-error .
     if error-status :error
     then do:
        delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                           "&5&4&6"
                                           ,vss-workfile
                                           ,vss-revision
                                           ,vss-description
                                           ,chr(10)
                                           ,error-status:get-message(1)
                                           ,return-value )).
     end.
     run begin-create-command in p-esys-cmd-proc-handle
       (input 'cmd-esys-general':U
       ,input p-esys-id-list
       ,output p-esys-cmd-code
       ) no-error.
     if error-status :error
     then do:
       delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при создании команды &1&2&3&1&4"
                                                        , 'cmd-esys-general':U
                                                        , error-status:get-message(1)
                                                        , return-value
                                                        )).
       return no .
     end.
     return yes.
   end.
end.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function context_send-esys-command return logical
(
    input p-esys-id-list as character
   ,input p-esys-cmd-proc-handle as handle
   ,input p-esys-cmd-code as integer
   ,input p-user-id as character
):
   define variable v-dmp-ord-int64 as int64 no-undo .
   if valid-handle(p-esys-cmd-proc-handle )
   then do:
      run send-command-esys in p-esys-cmd-proc-handle
          (input p-esys-cmd-code
          ,input p-esys-id-list
          ,input p-user-id
          ,output v-dmp-ord-int64
          ) no-error.
      if error-status :error
      then do:
         delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при отсылке во внешнюю систему &1 команды с кодом &2&3&4&3&5"
                                                        , p-esys-id-list
                                                        , p-cmd-code
                                                        , chr(10)
                                                        , error-status:get-message(1)
                                                        , return-value
                                                        )).
         return no .
      end.
      delete procedure p-esys-cmd-proc-handle no-error.
      return yes.
   end.
   else do:
      delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при отсылке во внешнюю систему &1 команды с кодом &2&3&4&3&5"
                                                    , p-esys-id-list
                                                    , p-cmd-code
                                                    , chr(10)
                                                    , error-status:get-message(1)
                                                    , return-value
                                                    )).
      return no .
   end.
end.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function context_set-custom-esys-pck-name return logical
(
    input p-esys-cmd-proc-handle as handle
   ,input p-esys-cmd-code as integer
   ,input p-custom-pck-name as character
):
   if valid-handle(p-esys-cmd-proc-handle )
   then do:
      run set-custom-esys-pck-name in p-esys-cmd-proc-handle (
                                                              input p-esys-cmd-code
                                                             ,input p-custom-pck-name) no-error .
      if error-status :error
      then do:
         delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при установке спец имени пакета для отсылки во внешнюю систему команды с кодом &1&2&3&2&4"
                                                     , p-cmd-code
                                                     , chr(10)
                                                     , error-status:get-message(1)
                                                     , return-value
                                                     )).
         return no .
      end.
      return yes.
   end.
   else do:
      delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при установке спец имени пакета для отсылки во внешнюю систему команды с кодом &1&2&3&2&4"
                                                    , p-cmd-code
                                                    , chr(10)
                                                    , error-status:get-message(1)
                                                    , return-value
                                                    )).
      return no .
   end.
end.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function context_delete-command return logical
(
    input p-esys-cmd-proc-handle as handle
   ,input p-esys-cmd-code as integer
):
   if valid-handle(p-esys-cmd-proc-handle )
   then do:
      run delete-command in p-esys-cmd-proc-handle
          (input p-esys-cmd-code
          ) no-error.
      if error-status :error
      then do:
         delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при удалении команды с кодом &1&2&3&2&4"
                                                           , p-cmd-code
                                                           , chr(10)
                                                           , error-status:get-message(1)
                                                           , return-value
                                                           )).
         return no .
      end.
      delete procedure p-esys-cmd-proc-handle no-error.
      return yes.
   end.
   else do:
      delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при удалении команды с кодом &1&2&3&2&4"
                                                    , p-cmd-code
                                                    , chr(10)
                                                    , error-status:get-message(1)
                                                    , return-value
                                                    )).
      return no .
   end.
end.
on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.
define variable ExpData1 as class Route-data_ no-undo .
ExpData1 = new Route-data_( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle) .
if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
      if p-ruleset-id = 1
      or p-ruleset-id = 5 then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При экспорте произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action32   as character no-undo .
  define variable v-printed32       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При экспорте произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + log-file-name)
    ,input  7
    ,output v-user-action32
    ,output v-printed32
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
      end.
      if p-ruleset-id = 2
      or p-ruleset-id = 6 then do:
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При маршрутизации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action34   as character no-undo .
  define variable v-printed34       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При маршрутизации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + log-file-name)
    ,input  7
    ,output v-user-action34
    ,output v-printed34
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
      end.
  if v-es then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, chr(10), v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.
procedure proc-main :
_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, chr(10), error-status :get-message (1), v-last-error-message)
:
  define variable v-ii as integer no-undo .
  define variable v-loc-file-name as character no-undo .
  define variable v-pck-num-rec as integer no-undo init 1000.
  define variable v-uniq-key-rec as character no-undo .
  define variable v-cli-uniq-key-rec as character no-undo .
  define variable v-ext-obj-code as integer no-undo .
  define variable v-err as logical no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-success as logical   no-undo .
  define variable v-pack-num as integer   no-undo .
  define variable v-heap-dir as character no-undo .
  define variable v-exchange-dir as character no-undo .
  define variable v-temp-dir as character no-undo .
  define variable v-log-file-name as character no-undo .
  define variable v-list-file-name as character no-undo .
  define variable v-custom-pack-flag as logical   no-undo .
  define variable v-parameter as character no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-ord-int1 as integer no-undo .
  define variable v-found-rcv as logical no-undo .
  define buffer buf_ext-system for ub.ext-system.
  define buffer buf_ord-doc for ub.ord-doc.
  define buffer buf_ord-line for ub.ord-line.
  define buffer buf_object for ub.clients.
  define buffer buf_clients for ub.clients.
  define buffer buf_ext-classif for ub.ext-classif.
  define buffer esys_ext-classif for ub.ext-classif.
  define buffer buf_goods for ub.goods.
  define buffer buf_esys-pck-sent for ub.esys-pck-sent.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
  define buffer buf_ord-list for ord-list.
  define buffer buf_contract for ub.contract.
  for each order-header:
    delete  order-header.
  end.
  for each order-line:
    delete  order-line.
  end.
  if p-ruleset-id = 1
  or p-ruleset-id = 5
  then do:
    run write-log  in p-log-handle (
                                    input 0
                                  , "&DLine").
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute(".............Экспорт заказов в XML для передачи поставщику")).
  end.
  if p-ruleset-id = 2
  or p-ruleset-id = 6
  then do:
    run write-log  in p-log-handle (
                                    input 0
                                  , "&DLine").
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute(".............Маршрутизация заказов поставщику")).
  end.
  for each ord-list:
    if ord-list.is-trn-doc = no
    and ord-list.sel-order = 0
    then do:
      if ord-list.ord-int1 = int('7':U) then do:
        if ord-list.trn-doc = '' then do:
          v-found-rcv = no.
          for each  buf_ord-doc-rcv no-lock where
                  buf_ord-doc-rcv.doc-code = ord-list.doc-code
              and buf_ord-doc-rcv.ord-int1 = integer('7':U):
            find first buf_ord-list where
                      buf_ord-list.doc-code = ord-list.doc-code
                  and  buf_ord-list.doc-type = ord-list.doc-type
                  and  buf_ord-list.trn-doc = entry(1, buf_ord-doc-rcv.sub-par, chr(4)) no-error .
            if not available buf_ord-list then do:
              create buf_ord-list.
              buffer-copy ord-list to buf_ord-list
              assign
              buf_ord-list.trn-doc = entry(1, buf_ord-doc-rcv.sub-par, chr(4) )
              buf_ord-list.ord-int1 = integer('8':U)
              v-found-rcv = yes
              .
              release buf_ord-list.
            end.
          end.
          if v-found-rcv then do:
            delete ord-list.
          end.
          else do:
            assign
            ord-list.ord-int1 = integer('8':U)
            .
            release ord-list.
          end.
        end.
      end.
    end.
   end.
  _stroka:
  for each ord-list
  break
  by ord-list.host-code
  by ord-list.cli-type
  by ord-list.cli-code
  by ord-list.obj-type
  by ord-list.obj-code
  by ord-list.doc-code
  by ord-list.trn-doc
  On error undo _stroka, next _stroka
  :
    assign
    v-current-doc-code = ord-list.doc-code
    num-rec = num-rec + 1
    .
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Обработка заказа &1 &2", ord-list.doc-code , ord-list.trn-doc)).
    if v-err then next.
    IF num-rec = 1
    THEN do:
      IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
    end.
    if first-of(ord-list.cli-code) then do:
      for each order-header:
        delete  order-header.
      end.
      for each order-line:
        delete  order-line.
      end.
      v-err = no.
      find first buf_clients no-lock where
                buf_clients.obj-type = ord-list.cli-type
            and buf_clients.obj-code = ord-list.cli-code no-error.
      if not available buf_clients then do:
                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не найден контрагент &1&2", ord-list.cli-typ, ord-list.cli-code)).
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      if ord-list.is-trn-doc = no
      and ord-list.sel-order = 0
      then do:
        if ord-list.ord-int1 = integer('2':U)
        or ord-list.ord-int1 = integer('6':U)
        or ord-list.ord-int1 = integer('10':U)
        then do:
                              run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Нельзя отправить Заказ в статусе <&1>!", entry (lookup (string(ord-list.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') )).
          assign v-view-log = yes.
          v-err = yes.
          next _stroka.
        end.
        if ord-list.doc-type = 'ОП':U
        and ord-list.status_  = 'новый':U
        and ord-list.ord-int1 = integer('0':U) then do:
          assign
          v-ord-int1 = integer('1':U).
        end.
        if (ord-list.ord-int1 = integer('4':U)
          or
          ord-list.ord-int1 = int ('3':U))
          and ord-list.doc-type = 'ОП':U
          and ord-list.status_  = 'поставка':U
          then do:
          assign
          v-ord-int1 = integer('5':U).
        end.
        if v-ord-int1 = integer('1':U) then do:
          if ord-list.status_ <> 'новый':U
          or ord-list.ord-int1 = int('1':U)
          then do:
                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Заказ &1 НЕ НОВЫЙ. Отправить можно только НОВЫЙ заказ!", ord-list.doc-code )).
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
          if ord-list.ord-int1 <> integer('0':U) then do:
                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Заказ &1 уже был отправлен. Отправить можно только НОВЫЙ заказ (желтый)!", ord-list.doc-code)).
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
        end.
        if v-ord-int1 = int('5':U) then do:
          if ord-list.status_ <> 'поставка':U then do:
                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Нельзя отправить заказ &1, он не в статусе ПОСТАВКА!" , ord-list.doc-code)).
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
        end.
        if v-ord-int1 = integer('5':U)
        or v-ord-int1 = integer('1':U) then do:
          if not ( ord-list.doc-type = 'ОП':U )   then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Нельзя отправить заказ &1, отправить можно только заказ ОП !", ord-list.doc-code)).
          assign v-view-log = yes.
          v-err = yes.
          next _stroka.
          end.
        end.
        if v-ord-int1 = integer('5':U)
        or v-ord-int1 = integer('1':U) then do:
          if not can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  ord-list.doc-code ) or
          can-find (first ub.ord-line no-lock where  ub.ord-line.doc-code =  ord-list.doc-code and ub.ord-line.qnty = 0 ) or
          can-find (first ub.ord-line no-lock where  ub.ord-line.doc-code =  ord-list.doc-code and ub.ord-line.price-cli = 0 ) or
          can-find (first ub.ord-line no-lock where  ub.ord-line.doc-code =  ord-list.doc-code and ub.ord-line.cli-art = "" )
        then do:
                      run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Заказ &1 полностью не создан. Проверьте наличие строк, количеств, цены и артикула поставщика !", ord-list.doc-code)).
            v-err = yes.
            assign v-view-log = yes.
            next _stroka.
          end.
        end.
        if ord-list.doc-type = 'ОП':U
        and ord-list.status_  = 'новый':U
        and ord-list.ord-int1 = integer('0':U) then do:
          assign
          ord-list.ord-int1 = integer('1':U).
        end.
        if (ord-list.ord-int1 = int ('4':U) or
            ord-list.ord-int1 = int ('3':U))
          and ord-list.doc-type = 'ОП':U
          and ord-list.status_  = 'поставка':U then do:
          assign
          ord-list.ord-int1 = integer('5':U).
        end.
        if ord-list.ord-int1 = int('3':U) then do:
          assign
          ord-list.ord-int1 = integer('4':U).
        end.
      end.
      if ord-list.is-trn-doc then do:
        ord-list.ord-int1 = integer('9':U).
      end.
      run gen-key-rec in this-procedure ( input 'clients':U
                                         ,input (buffer buf_clients:handle)
                                         ,output v-cli-uniq-key-rec) no-error .
      if error-status:error then do:
                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("gen-key-rec: &1&2&3&2(&4&5)"                                   , error-status:get-message(1)                                     , return-value                                                     , chr(10)                                                    , ord-list.cli-type                                                , ord-list.cli-code)).
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      find first esys_ext-classif no-lock where
          esys_ext-classif.classif-name = 'clients-edoc-nn':U
      and esys_ext-classif.classif-subject = 'clients':U
      and esys_ext-classif.db-num = -1
      and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec no-error .
      if not available esys_ext-classif then do:
                   run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Поставщик &1&2 заказа &3 НЕ РАБОТАЕТ ПО СИСТЕМЕ EDOC-NN", ord-list.cli-type, ord-list.cli-code, ord-list.doc-code)).
          assign v-view-log = yes.
          v-err = yes.
          next _stroka.
      end.
      for each temp-esys:
        delete temp-esys.
      end.
      for each esys_ext-classif no-lock where
          esys_ext-classif.classif-name = 'clients-edoc-nn':U
      and esys_ext-classif.classif-subject = 'clients':U
      and esys_ext-classif.db-num = -1
      and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec,
        first buf_ext-system no-lock where
                  buf_ext-system.esys-id = esys_ext-classif.key#_one
              and buf_ext-system.db-num = 0
              and buf_ext-system.esys-db-num-exp = g#db-num
              and buf_ext-system.esys-have-export = yes
              :
        if buf_ext-system.delivery-method <> integer('2':U) then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Неверный метод доставки для ВС &1"                                       , buf_ext-system.esys-id)).
          assign v-view-log = yes.
          v-err = yes.
          next _stroka.
        end.
        create temp-esys.
        assign
        temp-esys.esys-id = buf_ext-system.esys-id
        temp-esys.db-num  = buf_ext-system.db-num
        temp-esys.esys-name  = buf_ext-system.esys-name
        temp-esys.delivery-method  = buf_ext-system.delivery-method
        temp-esys.rowid_  = rowid(buf_ext-system)
        .
        run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                     ,input buf_ext-system.db-num
                                                     ,input 'FTP':U
                                                     ,output temp-esys.ftp-ip
                                                     ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                     ,input buf_ext-system.db-num
                                                     ,input 'Login':U
                                                     ,output temp-esys.ftp-login
                                                     ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                     ,input buf_ext-system.db-num
                                                     ,input 'Password':U
                                                     ,output temp-esys.ftp-password
                                                     ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                     ,input buf_ext-system.db-num
                                                     ,input 'Path':U
                                                     ,output temp-esys.ftp-path
                                                     ,output v-type) no-error.
        release temp-esys.
        leave.
      end.
      find first temp-esys no-error.
      if not available temp-esys then do:
                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Для поставщика &1&2 не найдена ВС, у которой есть экспорт в текущей БД")).
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
    end.
    if first-of(ord-list.obj-code) then do:
      find first buf_object no-lock where
                buf_object.obj-type = ord-list.obj-type
            and buf_object.obj-code = ord-list.obj-code no-error.
      if not available buf_object then do:
                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не найден объект &1&2", ord-list.obj-type, ord-list.obj-code)).
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      if buf_object.db-num <> g#db-num then do:
                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Объект &1&2 принадлежит другой БД", ord-list.obj-type, ord-list.obj-code)).
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      run gen-key-rec in this-procedure ( input 'clients':U
                                         ,input (buffer buf_object:handle)
                                         ,output v-uniq-key-rec) no-error .
      if error-status:error then do:
                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("gen-key-rec: &1&2&3&2(&4&5)"                                   , error-status:get-message(1)                                     , return-value                                                    , chr(10)                                                   , buf_object.obj-type                                             , buf_object.obj-code)).
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      find first buf_ext-classif no-lock where
          buf_ext-classif.classif-name = 'clients-esys':U
      and buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.db-num = 0
      and buf_Ext-classif.key#_one = temp-esys.esys-id
      and buf_Ext-classif.uniq-key-rec = v-uniq-key-rec no-error .
      if not available buf_ext-classif then do:
                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не найдено соответствие объекту &1&2 во внешней системе &3"                                     , ord-list.obj-type                                     , ord-list.obj-code                                     , temp-esys.esys-id                                     )).
        assign v-view-log = yes.
        v-err = yes.
        next _stroka.
      end.
      else do:
        v-ext-obj-code = buf_Ext-classif.key#_two.
      end.
    end.
    if p-save >= 0 then do:
      find first buf_ord-doc exclusive-lock where
                buf_ord-doc.doc-code = ord-list.doc-code
             no-error.
    end.
    else do:
      find first buf_ord-doc no-lock where
                buf_ord-doc.doc-code = ord-list.doc-code
             no-error.
    end.
    if not available buf_ord-doc then do:
            run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не найден содержащийся в списке заказ &1", ord-list.doc-code)).
      assign v-view-log = yes.
      v-err = yes.
      next _stroka.
    end.
    for each temp-esys:
      if p-ruleset-id = 1
      or p-ruleset-id = 5
      then do:
        do :
          v-success = no.
          find first buf_ext-system no-lock where
                    buf_ext-system.esys-id = temp-esys.esys-id
                and buf_ext-system.db-num = temp-esys.db-num.
          run bge/lockesys.p (
            input buf_ext-system.esys-id
            ,input buf_ext-system.db-num
            ,buffer buf_ext-system
                                          ,output v-success) no-error.
          if error-status :error
          or not v-success then do:
                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось захватить ВС для экспорта:&1&2&1&3"                                        , chr(10)                                        , error-status:get-message(1)                                        , return-value                                        )).
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
        end.
      end.
      if p-ruleset-id = 2
      or p-ruleset-id = 6
      then do:
        IF  context_begin-esys-command( input string(temp-esys.esys-id), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
          undo _main, return error v-last-error-message .
        end.
      end.
      if temp-esys.delivery-method = integer('1':U) then do:
                if ord-list.trn-doc = "" then do:
      v-custom-pack-name = substitute("&1_&2_&3-&4-&5.&6"
                                     , v-ext-obj-code
                                     , buf_ord-doc.doc-code
                                     , string(year(buf_ord-doc.ship-date), "9999")
                                     ,string(month(buf_ord-doc.ship-date), "99")
                                     ,string(day(buf_ord-doc.ship-date), "99")
                                     ,entry (lookup (string(ord-list.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err')
                                     ).
      end .
      else do:
      v-custom-pack-name = substitute("&1_&2_&7_&3-&4-&5.&6"
                                     ,v-ext-obj-code
                                     ,buf_ord-doc.doc-code
                                     ,string(year(buf_ord-doc.ship-date), "9999")
                                     ,string(month(buf_ord-doc.ship-date), "99")
                                     ,string(day(buf_ord-doc.ship-date), "99")
                                     ,entry (lookup (string(ord-list.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err')
                                        ,ord-list.trn-doc
                                     ).
       end.
      end.
      if p-ruleset-id = 1
      or p-ruleset-id = 5
      then do:
        if temp-esys.delivery-method = integer('2':U) then do:
          v-pack-num = -1.
          v-custom-pack-name = ''.
        end.
        run bge/espcknum.p ( input (if temp-esys.delivery-method = integer('1':U)
                                    then "fput":U
                                    else "put":U)
                      ,input temp-esys.esys-id
                      ,input temp-esys.db-num
                      ,input temp-esys.delivery-method
                      ,input v-oxml-exch-dir
                      ,input v-oxml-heap-dir
                      ,input ""
                      ,input-output v-pack-num
                      ,input-output v-custom-pack-name
                      ,output v-loc-file-name
                      ,output v-heap-dir
                      ,output v-exchange-dir
                      ,output v-temp-dir
                      ,output v-log-file-name
                      ,output v-list-file-name
                      ,output v-custom-pack-flag
                    ) no-error.
        if error-status :error then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при получении директории и имен файла для экспорта&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                       , return-value                                      )).
          assign v-view-log = yes.
          v-err = yes.
          next _stroka.
        end.
        if temp-esys.delivery-method = integer('2':U) then do:
          v-loc-file-name = v-loc-file-name + "xml".
        end.
      end.
            create order-header.
      assign
      order-header.doc-code = buf_ord-doc.doc-code
      order-header.ship-date = buf_ord-doc.ship-date
      order-header.status_ = entry (lookup (string(ord-list.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err')
      order-header.trn-code  =  ord-list.trn-doc
      order-header.ext-obj-code = v-ext-obj-code
      .
      find first buf_contract no-lock
           where buf_contract.host-code     = buf_ord-doc.host-code
             and buf_contract.contract-code = buf_ord-doc.contract-code no-error.
      if available buf_contract then do:
        assign order-header.contract-code = buf_contract.contract-prn-code .
      end.
      ExpData1:route-data_create-record( INPUT "order-header") .
      ExpData1:route-data_copy-record( INPUT "order-header", INPUT  (buffer order-header:handle) ) .
      if p-ruleset-id = 2
      or p-ruleset-id = 6
      then do:
        IF ExpData1:esys-add-dump( INPUT "order-header", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          undo _main, return error v-last-error-message .
        end.
      end.
      if order-header.trn-code = ""
      or ord-list.ord-int1 = integer('8':U)
      then do:
        if ord-list.ord-int1 = integer('8':U) then do:
        end.
        else do:
      for each buf_ord-line no-lock where
                  buf_ord-line.doc-code = ord-list.doc-code
                  by buf_ord-line.line-num
          on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
          on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
          on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
          :
            find first buf_goods no-lock where
                      buf_goods.gds-code = buf_ord-line.gds-code no-error.
            if not available buf_goods then do:
              undo _main, return error v-last-error-message .
            end.
            find first order-line where
                      order-line.doc-code = buf_ord-doc.doc-code
                  and order-line.cliart = buf_ord-line.cli-art no-error .
            if available order-line then do:
                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("В заказе &1 две строки с одинаковым артикулом поставщика &2: пропускаем ..."                                           , ord-list.doc-code                                       , buf_ord-line.cli-art                                       )).
              assign v-view-log = yes.
            if p-ruleset-id = 2
            or p-ruleset-id = 6
            then do:
            IF  context_delete-command( input v-esys-cmd-proc-handle, input v-esys-cmd-code) = false  THEN do:
              undo _main, return error v-last-error-message .
            end.
          end.
                    ExpData1:Route-data_clear-data ( ) .
          next _stroka.
        end.
        else do:
          create order-line.
          assign
          order-line.doc-code = buf_ord-doc.doc-code
              order-line.trn-code      = ord-list.trn-doc
          order-line.cliart = buf_ord-line.cli-art
          order-line.status_ = 0
          order-line.desstatus = ""
          order-line.artth =  buf_ord-line.artic
          order-line.prod-type =  buf_ord-line.prod-type
          order-line.prod-code =  buf_ord-line.prod-code
          order-line.nameth =  buf_goods.gds-name
          order-line.quantityquant =  buf_ord-line.cli-qnty
          order-line.pricequant =  buf_ord-line.price-cli
          .
          ExpData1:route-data_create-record( INPUT "order-line") .
          ExpData1:route-data_copy-record( INPUT "order-line", INPUT  (buffer order-line:handle) ) .
            if p-ruleset-id = 2
            or p-ruleset-id = 6
            then do:
            IF  ExpData1:esys-add-dump( INPUT "order-line", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
              undo _main, return error v-last-error-message .
            end.
          end.
          release order-line.
        end.
      end.
      end.
      end.
      else do:
        define buffer buf_doc-line for ub.doc-line  .
        for each buf_doc-line no-lock where
                 buf_doc-line.doc-code = ord-list.doc-type
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
        :
          find first buf_goods no-lock where
                    buf_goods.artic     = buf_doc-line.artic     and
                    buf_goods.prod-type = buf_doc-line.prod-type and
                    buf_goods.prod-code = buf_doc-line.prod-code no-error.
          if not available buf_goods then do:
            undo _main, return error v-last-error-message .
          end.
          find first buf_ord-line no-lock where
                    buf_ord-line.doc-code  = ord-list.doc-code      and
                    buf_ord-line.artic     = buf_doc-line.artic     and
                    buf_ord-line.prod-type = buf_doc-line.prod-type and
                    buf_ord-line.prod-code = buf_doc-line.prod-code no-error.
          if not available buf_ord-line then do:
            undo _main, return error v-last-error-message .
          end.
          find first order-line where
                     order-line.doc-code  = ord-list.doc-code
                 and order-line.cliart    = buf_ord-line.cli-art
                 no-error .
          if available order-line then do:
                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("В ПН &1 две строки с одинаковым артикулом поставщика &2: пропускаем ..."                                         , ord-list.doc-code                                         , buf_ord-line.cli-art                                         )).
            assign v-view-log = yes.
            if p-ruleset-id = 2
            or p-ruleset-id = 6
            then do:
              IF  context_delete-command( input v-esys-cmd-proc-handle, input v-esys-cmd-code) = false  THEN do:
                undo _main, return error v-last-error-message .
              end.
            end.
                        ExpData1:Route-data_clear-data ( ) .
            next _stroka.
          end.
          else do:
            create order-line.
            assign
            order-line.doc-code      = buf_ord-doc.doc-code
            order-line.trn-code      = ord-list.trn-doc
            order-line.cliart        = buf_ord-line.cli-art
            order-line.status_       = 0
            order-line.desstatus     = ""
            order-line.artth         =  buf_ord-line.artic
            order-line.prod-type     =  buf_ord-line.prod-type
            order-line.prod-code     =  buf_ord-line.prod-code
            order-line.nameth        =  buf_goods.gds-name
            order-line.quantityquant =  buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate
            order-line.pricequant    =  buf_doc-line.price-cli
            .
            ExpData1:route-data_create-record( INPUT "order-line") .
            ExpData1:route-data_copy-record( INPUT "order-line", INPUT  (buffer order-line:handle) ) .
            if p-ruleset-id = 2
            or p-ruleset-id = 6
            then do:
              IF  ExpData1:esys-add-dump( INPUT "order-line", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
                undo _main, return error v-last-error-message .
              end.
            end.
            release order-line.
          end.
        end.
      end.
      for each order-line:
        delete order-line.
      end.
      run edocsord_export in this-procedure ( buffer buf_ord-doc
                                             ,input ord-list.trn-doc
                                             ,input ord-list.ord-int1
                                            ) no-error.
      if p-ruleset-id = 2
      or p-ruleset-id = 6
      then do:
        if temp-esys.delivery-method = integer('1':U) then do:
        IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false  THEN do:
          undo _main, return error v-last-error-message .
        end.
        end.
        IF  context_send-esys-command( input string(temp-esys.esys-id), input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid) = false  THEN do:
          undo _main, return error v-last-error-message .
        end.
        if ord-list.sel-order = 1 then delete ord-list.
      end.
      if p-ruleset-id = 1
      or p-ruleset-id = 5
      then do:
        if not ExpData1:set-esys( temp-esys.esys-id, temp-esys.esys-name) then do:
          undo _main, return error .
        end.
        if temp-esys.delivery-method = integer('2':U) then do:
          if not ExpData1:set-pack-num( v-pack-num) then do:
            undo _main, return error .
          end.
        end.
        if not ExpData1:write-xml(v-exchange-dir + chr(47) + v-loc-file-name, 1) then do:
          undo _main, return error .
        end.
        assign
        v-parameter = temp-esys.ftp-ip + chr(4) +
                      temp-esys.ftp-login + chr(4) +
                      temp-esys.ftp-password + chr(4) +
                      string(0)  + chr(4) +
                      (if temp-esys.ftp-path <> ''
                      then (trim (trim (trim(temp-esys.ftp-path
                                      , chr(92))
                                 ,chr(47))
                            ,chr(92)) + chr(47))
                      else '') +
                      "out" + chr(47) + v-loc-file-name  + chr(4) +
                      v-exchange-dir + chr(47) + v-loc-file-name + chr(4) +
                      string(no) + chr(4) +
                      "process-edoc.txt"
        .
        run gbl/ftp-put.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input v-parameter ) no-error.
        if error-status:error then do:
                      run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при передаче файла заказа &1 по FTP"                                       , v-loc-file-name  )).
           assign v-view-log = yes.
           v-err = yes.
           undo _stroka, next _stroka.
        end.
        else do:
          run cur-time in this-procedure ( output v-today, output v-time).
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
create buf_esys-pck-sent.
assign
buf_esys-pck-sent.esps-CreDate        = v-today
buf_esys-pck-sent.esps-CreTimeInt     = v-time
buf_esys-pck-sent.esps-CreTime        = string( v-time, "HH:MM:SS" )
buf_esys-pck-sent.esys-id             = temp-esys.esys-id
buf_esys-pck-sent.db-num              = temp-esys.db-num
buf_esys-pck-sent.esps-cr-db-num      = g#db-num
buf_esys-pck-sent.esps-pack-num       = v-pack-num
buf_esys-pck-sent.esps-rcvd           = no
buf_esys-pck-sent.esps-total-recs     = ?
buf_esys-pck-sent.esps-CreNum         = 0
buf_esys-pck-sent.esps-SendTxtDate    = ?
buf_esys-pck-sent.esps-SendTxtTimeInt = 0
buf_esys-pck-sent.esps-SendTxtTime    = "":U
buf_esys-pck-sent.esps-rcvdDate       = ?
buf_esys-pck-sent.esps-RcvdTimeInt    = 0
buf_esys-pck-sent.esps-RcvdTime       = "":U
buf_esys-pck-sent.esps-CRC-pack       = substitute( "&1 &2 &3 &4", today, time, etime, DBTASKID( "ub":U ) )
.
          assign
          buf_esys-pck-sent.esps-rcvd = yes
          buf_esys-pck-sent.esps-total-recs = 2
          buf_esys-pck-sent.esps-CreNum         = 1
          buf_esys-pck-sent.esps-SendTxtDate    = v-today
          buf_esys-pck-sent.esps-SendTxtTimeInt = v-time
          buf_esys-pck-sent.esps-SendTxtTime    = string( v-time, "HH:MM:SS" )
          buf_esys-pck-sent.esps-rcvdDate       = v-today
          buf_esys-pck-sent.esps-RcvdTimeInt    = v-time
          buf_esys-pck-sent.esps-RcvdTime       = string( v-time, "HH:MM:SS" )
          .
          run bge/sxg-pack.p (
                         input parparentproc
                        ,input this-procedure:handle
                        ,input p-log-handle
                        ,input "fput":U
                        ,input false
                        ,input v-loc-file-name
                        ,input v-exchange-dir
                        ,input v-heap-dir
                        ,input v-temp-dir
                        ,input 0
                        ,input temp-esys.esys-id
                        ,input temp-esys.db-num
                        ,input g#db-num
                        ,input temp-esys.delivery-method
                        ) no-error.
          if error-status :error then do:
                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при перемещении файла заказа &1 из директории обмена &2 в архивную директорию &3"                                         , v-loc-file-name                                         , v-exchange-dir                                         , v-heap-dir                                         )).
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
          run gbl/del-file.p ( input v-temp-dir ) no-error .
          if error-status :error then do:
                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при удалении временной директории &1"                                         , v-temp-dir                                         )).
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
          run gbl/del-file.p ( input v-exchange-dir + chr(47) + v-loc-file-name ) no-error .
          if error-status :error then do:
                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при удалении файла в директории обмена &1"                                         , v-exchange-dir + chr(47) + v-loc-file-name                                         )).
            assign v-view-log = yes.
            v-err = yes.
            next _stroka.
          end.
        end.
      end.
            ExpData1:Route-data_clear-data ( ) .
    end.
    num-rec-ok = num-rec-ok + 1.
    run write-counter in p-log-handle ( input substitute("Обработано заказов списка экспорта: &1, из них удачно: &2", num-rec, num-rec-ok)).
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
        run write-log-and-file in p-log-handle (
                                                input 1
                                              , input log-file-name
                                              , input 1
                                              , input substitute("Процесс прерван пользователем")).
        leave _stroka.
    end.
  end.
  ExpData1:route-data_clear-xmlschema ( ).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Обработано заказов списка экспорта: &1, из них удачно: &2", num-rec, num-rec-ok)).
end.
end procedure.
procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
  do
  on error undo, return error
  :
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
      when 1
      or
      when 5
      then do:
        assign
        v-sign = 2
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = p-process-file-name
        .
        run bge/oxmlinir.p ( output v-oxml-exch-dir
                            ,output v-oxml-heap-dir) .
      end.
      when 2
      or
      when 6
      then do:
        assign
        v-sign = 2
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = p-process-file-name
        .
      end.
    end case.
  end.
end procedure.
