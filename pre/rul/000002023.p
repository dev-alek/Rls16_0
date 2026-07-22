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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 11 набор правил 4".
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
define variable vss-include-info12 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_grplib_grp no-undo
    field sel           as character
    field nabor         as character
    field full-name     as character
    field print-code    as character
    field sort-name     as character
    field node-code     as integer
    field upper-code    as integer
    field calc-method   as character
    field round-method  as character
    field increase-pc   as decimal
    field min-marg      as character
    field max-marg      as character
    field cli-type      as character
    field cli-code      as integer
    field notcorr      as character
    field name          as character
    field level         as integer
    field mark          as character
    index pi is primary unique sort-name
    index fn full-name
    index nc is unique node-code
    index sl sel
    index uc upper-code
.
define temp-table temp_grplib_found-grp no-undo
    field full-name   as character
    field sort-name   as character
    field node-code   as integer
    field level       as integer
    field is-terminal as logical
    index pi is primary unique sort-name
    index fn full-name
    index lv level
    index it is-terminal
.
define temp-table temp_found-result-nodelist no-undo
    field node-code     as recid
    field processed     as logical
    field sort-name     as character
    field full-name     as character
    index pi is primary unique node-code
    index ps processed
.
define variable v-grplib-not-fill-extra-info        as logical      no-undo.
define variable v-grplib-no-warning-grp-amount      as logical      no-undo.
define variable v-grplib-grp-amount-for-load        as integer      no-undo.
procedure grplib-get-parameters :
define input parameter p-store-type     as character        no-undo.
define input parameter p-store-code     as integer          no-undo.
do
on error undo, return error
:
    assign
        v-grplib-not-fill-extra-info = no
    .
end.
end procedure.
procedure grplib-get-sort-name :
do
on error undo, return error
:
define input parameter p-node-code  as integer      no-undo.
define output parameter p-sort-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-sort-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-sort-name: Ошибка составления полного имени группы"
    :
        assign
            p-sort-name  = buf_gds-grp.node-name
                         + (if p-sort-name <> "" then chr(2) else "")
                         + p-sort-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-sort-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
end.
end procedure.
define variable vss-include-info13 as character format "X(65)" no-undo
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
procedure grplib-get-root-code :
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.
end procedure.
procedure grplib-find-grp-by-full-name :
do
on error undo, return error
:
define input parameter p-search-name  as character    no-undo.
define input parameter p-fill-path    as logical      no-undo.
define output parameter p-found       as logical      no-undo.
    define variable v-upper-code    as integer          no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-level         as integer           no-undo.
    define variable v-full-name     as character         no-undo.
    define variable v-sort-name     as character         no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    assign
        p-search-name = replace( p-search-name, chr(47), chr(2) )
    .
    run grplib-get-root-code ( output v-upper-code ) no-error .
    if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
    end.
    assign
        v-full-name  = ""
        v-level      = num-entries( p-search-name, chr(2) )
    .
    for each temp_grplib_found-grp
    :
        delete temp_grplib_found-grp.
    end.
    start-name-analyze:
    do v-counter = 1 to v-level
    :
        if v-counter < v-level
        then do:
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, chr(2) )
            no-error .
            if not available buf_gds-grp
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, chr(2) ).
            end.
            else do:
                assign
                    v-full-name = v-full-name + ( if v-full-name = "" then "" else chr(47) )        + buf_gds-grp.node-name
                    v-sort-name = v-sort-name + ( if v-sort-name = "" then "" else chr(2) ) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name + chr(47)
                        temp_grplib_found-grp.sort-name = v-sort-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
        end.
        else do:
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, chr(2) )
            :
                assign
                    p-found = yes
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else chr(47) )
                                                        + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name = v-sort-name
                                                        + ( if v-sort-name = "" then "" else chr(2) )
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if p-found = no
            then do:
                assign
                    v-full-name  = p-search-name
                    v-sort-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                assign
                    p-found = no
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-find-all-subgroup :
do
on error undo, return error
:
define input parameter p-start-node-code    as integer      no-undo.
define input parameter p-terminal-only      as logical      no-undo.
    define variable v-start-full-name   as character     no-undo.
    define variable v-start-sort-name   as character     no-undo.
    define variable v-not-found         as logical       no-undo.
    define variable v-is-terminal       as logical       no-undo.
    define buffer buf_gds-grp           for ub.gds-grp.
    create temp_found-result-nodelist.
    assign
        temp_found-result-nodelist.node-code = p-start-node-code
        temp_found-result-nodelist.processed = no
    .
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-full-name
    ).
    run grplib-get-full-name in this-procedure (
          input p-start-node-code
        , output v-start-sort-name
    ).
    process-nodes:
    do while yes
    :
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.node-code = p-start-node-code
        .
        assign
            temp_found-result-nodelist.processed = yes
        .
        for each buf_gds-grp no-lock
           where buf_gds-grp.upper-code = p-start-node-code
        on error undo, return error
        :
            run grplib-is-terminal in this-procedure (
                  input buf_gds-grp.node-code
                , output v-is-terminal
            ).
            if v-is-terminal = yes
            then do:
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                        chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                        chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                    temp_grplib_found-grp.is-terminal = yes
                .
            end.
            else do:
                create temp_found-result-nodelist.
                assign
                    temp_found-result-nodelist.node-code = buf_gds-grp.node-code
                    temp_found-result-nodelist.full-name = right-trim(v-start-full-name, chr(47)) +
                                                           chr(47) + buf_gds-grp.node-name + chr(47)
                    temp_found-result-nodelist.sort-name = right-trim(v-start-sort-name, chr(2)) +
                                                           chr(2) + buf_gds-grp.node-name + chr(2)
                    temp_found-result-nodelist.processed = no
                .
                if p-terminal-only = no
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name   = right-trim(v-start-full-name, chr(47)) +
                                                            chr(47) + buf_gds-grp.node-name + chr(47)
                        temp_grplib_found-grp.sort-name   = right-trim(v-start-sort-name, chr(2)) +
                                                            chr(2) + buf_gds-grp.node-name + chr(2)
                        temp_grplib_found-grp.node-code   = buf_gds-grp.node-code
                        temp_grplib_found-grp.is-terminal = no
                    .
                end.
            end.
        end.
        find first temp_found-result-nodelist
             where temp_found-result-nodelist.processed = no
        no-error.
        if not available temp_found-result-nodelist
        then do:
            leave process-nodes.
        end.
        else do:
            assign
                p-start-node-code = temp_found-result-nodelist.node-code
                v-start-full-name = temp_found-result-nodelist.full-name
                v-start-sort-name = temp_found-result-nodelist.sort-name
            .
        end.
    end.
end.
end procedure.
procedure grplib-expand-name :
define input parameter p-start-name as character        no-undo.
define output parameter p-end-name  as character        no-undo.
    define variable v-is-terminal   as logical      no-undo.
    define variable v-found         as character    no-undo.
    define buffer buf_temp_grplib_found-grp     for temp_grplib_found-grp.
do
for buf_temp_grplib_found-grp
on error undo, return error
:
    run grplib-find-grp-by-full-name in this-procedure (
          input p-start-name
        , input no
        , output v-found
    ) no-error.
    run grplib-get-max-substring in this-procedure (
                input length( p-start-name )
              , output p-end-name
    ) no-error .
    if error-status :error
    then do:
        assign
            p-end-name = ""
        .
    end.
    else do:
        find first temp_grplib_found-grp
            where temp_grplib_found-grp.full-name = p-end-name
        no-error.
        if available temp_grplib_found-grp
        then do:
            find first buf_temp_grplib_found-grp
                where buf_temp_grplib_found-grp.full-name begins p-end-name
                and recid( buf_temp_grplib_found-grp ) <> recid( temp_grplib_found-grp )
            no-error.
            if not available buf_temp_grplib_found-grp
            then do:
                run grplib-is-terminal in this-procedure (
                    input temp_grplib_found-grp.node-code
                    , output v-is-terminal
                ).
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-max-substring :
do
on error undo, return error
:
define input parameter p-min-substring-length   as integer      no-undo.
define output parameter p-substring             as character    no-undo.
        define variable v-char-counter  as integer           no-undo.
        define variable v-current-char  as character         no-undo.
        define variable v-names-counter  as integer           no-undo.
        define variable v-base-string   as character         no-undo.
        assign
            v-char-counter  = p-min-substring-length
        .
        find first temp_grplib_found-grp no-error.
        if not available temp_grplib_found-grp
        then do:
            undo, return error "grplib-get-max-substring: Нет строк для вычисления общей подстроки".
        end.
        else do:
            assign
                v-base-string  = temp_grplib_found-grp.full-name
                v-char-counter = 0
            .
            counter-block:
            do while yes
            on error undo, return error "grplib-get-max-substring: Ошибка вычисления продолжения имени группы."
            :
                assign
                    v-char-counter  = v-char-counter + 1
                    v-current-char  = substring( v-base-string, v-char-counter, 1 )
                    v-names-counter = 0
                .
                compare-block:
                for each temp_grplib_found-grp
                :
                    assign
                        v-names-counter = v-names-counter + 1
                    .
                    if v-names-counter = 1
                    then do:
                        next compare-block.
                    end.
                    if substring( temp_grplib_found-grp.full-name, v-char-counter, 1 ) <> v-current-char
                    then do:
                        leave counter-block.
                    end.
                end.
                if v-names-counter = 1
                then do:
                    assign
                        p-substring = v-base-string
                    .
                    return.
                end.
            end.
            assign
                p-substring = substring( v-base-string, 1, v-char-counter - 1 )
            .
        end.
end.
end procedure.
procedure grplib-is-terminal :
do
on error undo, return error "Ошибка процедуры grplib-is-terminal"
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-is-terminal   as logical      no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = p-node-code
    no-error .
    if not available buf_gds-grp
    then do:
        assign
            p-is-terminal = yes
        .
    end.
    else do:
        assign
            p-is-terminal = no
        .
    end.
end.
end procedure.
procedure grplib-have-goods :
do
on error undo, return error
:
define input parameter p-node-code      as integer      no-undo.
define output parameter p-have-goods   as logical      no-undo.
    define buffer buf_goods         for ub.goods.
    find first buf_goods no-lock
         where buf_goods.grp-code = p-node-code
    no-error .
    if available buf_goods
    then do:
        assign
            p-have-goods = yes
        .
    end.
    else do:
        assign
            p-have-goods = no
        .
    end.
end.
end procedure.
procedure grplib-find-by-substring :
do
on error undo, return error
:
define input parameter p-start-code         as integer      no-undo.
define input parameter p-full-search-string as character    no-undo.
define output parameter p-found-code        as integer      no-undo.
define output parameter p-full-name         as character    no-undo.
    define variable v-start-code     as integer           no-undo.
    define variable v-found          as logical  init no  no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    search-grp:
    for each buf_gds-grp no-lock
        where buf_gds-grp.node-code > p-start-code
    :
        if index( buf_gds-grp.node-name, p-full-search-string ) <> 0
        then do:
            assign
                p-found-code = buf_gds-grp.node-code
                v-found      = yes
            .
            run grplib-get-full-name in this-procedure (
                  input p-found-code
                , output p-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-find-by-substring: Ошибка вычисления полного имени группы." + chr(10) + return-value.
            end.
            leave search-grp.
        end.
    end.
    if v-found = yes
    then do:
    end.
    else do:
        assign
            p-full-name  = ""
            p-found-code = 0
        .
    end.
end.
end procedure.
procedure grplib-analyze-grp-name :
do
on error undo, return error
:
define input parameter p-grp-name       as character            no-undo.
define input parameter p-upper-code     as integer              no-undo.
define output parameter p-error-message as character init ""    no-undo.
    define variable v-char-list     as character    no-undo.
    define variable v-char-counter  as integer      no-undo.
    define variable v-full-name     as character    no-undo.
    if p-grp-name = "" then do:
        assign
            p-error-message = "Название группы не может быть пустым.".
        .
    end.
    else do:
        assign
            v-char-list = "47,92,58,63,34,60,62,171,187,183"
        .
        do v-char-counter = 1 to num-entries( v-char-list )
        :
            if index( p-grp-name, chr( integer( entry( v-char-counter, v-char-list ) ) ) ) <> 0
            then do:
                assign
                    p-error-message = 'Название группы не может содержать символы /\:*?"<>|«»·'
                .
                return.
            end.
        end.
        if p-upper-code > 0
        then do:
            run grplib-get-full-name in this-procedure (
                  input p-upper-code
                , output v-full-name
            ) no-error .
            if error-status :error
            then do:
                undo, return error "grplib-analyze-grp-name: Не удалось вычислить полное имя группы." + chr(10) + return-value.
            end.
            if length( v-full-name ) + 1 + length( p-grp-name ) > 350
            then do:
                assign
                    p-error-message = 'Полное название группы не может содержать более 350 символов.'
                .
            end.
        end.
    end.
end.
end procedure.
procedure grplib-get-lvl-num :
define input parameter p-node-code  as integer      no-undo.
define output parameter p-lvl-num   as integer      no-undo.
    define variable v-full-name    as character    no-undo.
do
on error undo, return error
:
    run grplib-get-full-name in this-procedure (
          input p-node-code
        , output v-full-name
    ).
    assign
        p-lvl-num = num-entries( v-full-name, chr(47) ) - 1
    .
    if p-lvl-num = -1
    then do:
        assign
            p-lvl-num = 0
        .
    end.
end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info14, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info14 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info14 )
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
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "X(65)" no-undo
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define new SHARED temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
FIELD fact-date like ub.tax-rate-value.fact-date
FIELD fact-order like ub.tax-rate-value.fact-order
FIELD next-order like ub.tax-rate-value.fact-order
FIELD corr-user-name like ub.tax-rate-gds.corr-user-name
FIELD corr-user-db-num   like ub.tax-rate-gds.corr-user-db-num
FIELD corr-date like ub.tax-rate-gds.corr-date
FIELD corr-time like ub.tax-rate-gds.corr-time
index tax-code is unique primary tax-code fact-order descending rate-code.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE new SHARED TEMP-TABLE TT-tnved NO-UNDO
FIELD tnved  AS CHAR FORMAT "X(10)"  LABEL 'Код ТНВЭД':U
FIELD f-name AS CHAR FORMAT "X(255)" LABEL 'Полное наименование':U
INDEX tnved IS UNIQUE PRIMARY  tnved.
def var vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure progs-name :
  define input  parameter p-action-code         as character no-undo .
  define output parameter p-main-prog-name      as character no-undo .
  define output parameter p-list-db-proc-name   as character no-undo .
  define output parameter p-commit-proc-name    as character no-undo .
  define output parameter p-execution-proc-name as character no-undo .
  define output parameter p-recover-proc-name   as character no-undo .
  define output parameter p-after-proc-name     as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-main-prog-name      = 'trg/code-rgt.p':U       p-list-db-proc-name   = 'utl/cdrg-dbl.p':U       p-commit-proc-name    = 'comm-crush-cdrg':U       p-execution-proc-name = 'exec-crush-cdrg':U       p-recover-proc-name   = 'rcvr-crush-cdrg':U       p-after-proc-name     = '':U     .   end.
            when 'delete_code-range':U then do:     assign       p-main-prog-name      = 'trg/code-rgt.p':U       p-list-db-proc-name   = 'utl/cdrg-dbl.p':U       p-commit-proc-name    = 'comm-del-cdrg':U       p-execution-proc-name = 'exec-del-cdrg':U       p-recover-proc-name   = 'rcvr-del-cdrg':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-prt-bar-code':U       p-execution-proc-name = 'delete-prt-bar-code':U       p-recover-proc-name   = 'undo-delete-prt-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-part-bar-code':U       p-execution-proc-name = 'delete-part-bar-code':U       p-recover-proc-name   = 'undo-delete-part-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-main-prog-name      = 'trg/bar-codt.p':U       p-list-db-proc-name   = 'str/barcddb.p':U       p-commit-proc-name    = 'block-del-ucli-bar-code':U       p-execution-proc-name = 'delete-ucli-bar-code':U       p-recover-proc-name   = 'undo-delete-ucli-bar-code':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-main-prog-name      = 'trg/discardt.p':U       p-list-db-proc-name   = 'trg/discardb.p':U       p-commit-proc-name    = 'block-del-dis-card':U       p-execution-proc-name = 'delete-dis-card':U       p-recover-proc-name   = 'undo-delete-dis-card':U       p-after-proc-name     = '':U     .   end.
            when 'chown-dis-card':U then do:     assign       p-main-prog-name      = 'trg/discardt.p':U       p-list-db-proc-name   = 'trg/discardb.p':U       p-commit-proc-name    = 'block-chown-dis-card':U       p-execution-proc-name = 'chown-dis-card':U       p-recover-proc-name   = 'undo-chown-dis-card':U       p-after-proc-name     = 'after-chown-dis-card':U     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-main-prog-name      = 'trg/dis-rult.p':U       p-list-db-proc-name   = 'trg/disruldb.p':U       p-commit-proc-name    = 'block-del-dis-rule':U       p-execution-proc-name = 'delete-dis-rule':U       p-recover-proc-name   = 'undo-delete-dis-rule':U       p-after-proc-name     = '':U     .   end.
            when 'ren-art':U then do:     assign       p-main-prog-name      = 'trg/goodst.p':U       p-list-db-proc-name   = 'utl/renartcd.p':U       p-commit-proc-name    = 'comm-ren-art':U       p-execution-proc-name = 'exec-ren-art':U       p-recover-proc-name   = 'rcvr-ren-art':U       p-after-proc-name     = 'after-ren-art':U     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-main-prog-name      = 'trg/clobdatt.p':U       p-list-db-proc-name   = 'trg/clbdatdb.p':U       p-commit-proc-name    = 'block-del-clob-data':U       p-execution-proc-name = 'delete-clob-data':U       p-recover-proc-name   = 'undo-delete-clob-data':U       p-after-proc-name     = '':U     .   end.
            when 'delete_nu-layout':U then do:     assign       p-main-prog-name      = 'trg/layoutt.p':U       p-list-db-proc-name   = 'trg/layoutdb.p':U       p-commit-proc-name    = 'block-del-layout':U       p-execution-proc-name = 'delete-layout':U       p-recover-proc-name   = 'undo-delete-layout':U       p-after-proc-name     = '':U     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info21, p-action-code ).
      end.
    end case.
  end.
  return.
end procedure.
procedure progs-title :
  define input  parameter p-action-code         as character no-undo .
  define output parameter p-action-title      as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-action-title        = "Разбиение диапазона кодов (code-range)"     .   end.
            when 'delete_code-range':U then do:     assign       p-action-title        = "Удаление диапазона кодов (code-range)"     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода признака"     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода партиии"     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-action-title        = "Удаление неисп.бар-кода на доп ед.изм."     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-action-title        = "Удаление неиспользуемой ДК"     .   end.
            when 'chown-dis-card':U then do:     assign       p-action-title        = "Смена владельца ДК"     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-action-title        = "Удаление правила скидки по фирме и глобального правила скидки"     .   end.
            when 'ren-art':U then do:     assign       p-action-title        = "Изм. артикула и(или) произв. товара"     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-action-title        = "Удаление неиспользуемой clob-data"     .   end.
            when 'delete_nu-layout':U then do:     assign       p-action-title        = "Удаление РАСКЛАДКИ"     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info21, p-action-code ).
      end.
    end case.
  end.
  return.
end procedure.
FUNCTION progs-title-function returns character(
   input  p-action-code         as character):
define variable p-action-title      as character no-undo .
  do
  on error undo, return error
  :
    case p-action-code :
            when 'crush_code-range':U then do:     assign       p-action-title        = "Разбиение диапазона кодов (code-range)"     .   end.
            when 'delete_code-range':U then do:     assign       p-action-title        = "Удаление диапазона кодов (code-range)"     .   end.
            when 'delete_nu-prt-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода признака"     .   end.
            when 'delete_nu-part-bar-code':U then do:     assign       p-action-title        = "Удаление неисп. бар-кода партиии"     .   end.
            when 'delete_nu-ucli-bar-code':U then do:     assign       p-action-title        = "Удаление неисп.бар-кода на доп ед.изм."     .   end.
            when 'delete_nu-dis-card':U then do:     assign       p-action-title        = "Удаление неиспользуемой ДК"     .   end.
            when 'chown-dis-card':U then do:     assign       p-action-title        = "Смена владельца ДК"     .   end.
            when 'delete_nu-dis-rule':U then do:     assign       p-action-title        = "Удаление правила скидки по фирме и глобального правила скидки"     .   end.
            when 'ren-art':U then do:     assign       p-action-title        = "Изм. артикула и(или) произв. товара"     .   end.
            when 'delete_nu-clob-data':U then do:     assign       p-action-title        = "Удаление неиспользуемой clob-data"     .   end.
            when 'delete_nu-layout':U then do:     assign       p-action-title        = "Удаление РАСКЛАДКИ"     .   end.
            otherwise do:
        return error substitute( "&1. Неизвестный тип операции: &2", vss-include-info21, p-action-code ).
      end.
    end case.
  end.
  return p-action-title.
end FUNCTION.
procedure get-row-keyr-string :
 define input  parameter p-key-rec  as character no-undo.
 define output parameter p-tbl-title as character no-undo.
 define output parameter p-rec-string  as character no-undo.
  do
  on error undo, return error
  :
    define variable v-full-tbl-name as character no-undo .
    define variable bh_tbl-name     as handle    no-undo .
    define variable fh              as handle    no-undo .
    define variable v-ok            as logical   no-undo .
    define variable v-field-num     as integer   no-undo .
    define variable v-count-fld     as integer   no-undo .
    define variable v-tbl-name as character no-undo.
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (get-row-keyr-string). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info21 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = "ub.":U + v-tbl-name
      v-field-num     = num-entries( p-key-rec, chr(3) ) - 1
      p-rec-string         = "":U
      v-count-fld     = 0
    .
    find ub._file
      where ub._file._file-name = v-tbl-name
      no-error.
    if not available ub._file then do:
      return error substitute( "&1. Таблица &2 отсутствует в БД", vss-include-info21, v-tbl-name ).
    end.
    assign
    p-tbl-title = ub._file._file-label
    .
    find ub._index
      where recid( ub._index  ) = ub._file._prime-index
      no-error.
    if not available ub._index
      or LC( ub._index._index-name ) = "default":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info21, v-tbl-name ).
    end.
    block_where :
    for each ub._index-field of ub._index  ,
        each ub._field of _index-field
        break by _index-seq
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      if p-rec-string = "":U then do:
        assign
          p-rec-string = "":U
        .
      end.
      else do:
        assign
          p-rec-string = p-rec-string + chr(32) + chr(44)
        .
      end.
      assign
        p-rec-string = p-rec-string + (if p-rec-string = "":u then "":U else chr(32)) + substitute( "&1 = &2":U, ub._field._label, entry( v-count-fld + 1 , p-key-rec, chr(3) ) )
      .
    end.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info21, v-tbl-name ).
    end.
  end.
  return.
end procedure.
FUNCTION uniq-key-rec-string-f returns character(
   input  p-uniq-key-rec         as character):
define variable v-tbl-title as character no-undo .
define variable v-rec-string as character no-undo .
  do
  on error undo, return error
  :
    run get-row-keyr-string in this-procedure (
                                              input p-uniq-key-rec
                                              ,output v-tbl-title
                                              ,output v-rec-string).
    assign
    v-rec-string = (if v-tbl-title <> ? and
                    v-tbl-title <> "":U
                    then (v-tbl-title + ":")
                   else "":U) + chr(32) + v-rec-string
    .
  end.
  return v-rec-string.
end FUNCTION.
procedure create_db-rec_route :
  define input parameter p1-uniq-key-rec as character no-undo .
  define input parameter p1-action       as character no-undo .
  define input parameter p1-operation    as character no-undo .
  define input parameter p1-send-db-list as character no-undo .
  define input parameter p1-db-init      as integer   no-undo .
  define input parameter p1-parameters   as character no-undo .
  define input parameter p1-answer-code  as integer   no-undo .
  define input parameter p1-answer-msg   as character no-undo .
  do
  on error undo, return error
  :
    define variable v-command     as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-curr-db     as integer   no-undo .
    define variable v-db-for-send as character no-undo .
    define variable v-db-num      as integer   no-undo .
    define variable v-db-num-char as character no-undo .
    define buffer buf_sys-ctrl    for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db     = buf_sys-ctrl.db-num
      v-db-for-send = "":U
    .
    if v-curr-db = 0 then do:
      if p1-answer-code >= 0 then do:
        if v-curr-db <> p1-db-init then do:
          assign
            v-db-for-send = string( p1-db-init )
          .
        end.
      end.
      else do:
        assign
          v-num-entries = num-entries( p1-send-db-list, chr(44) )
        .
        do v-ind = 1 to v-num-entries:
          assign
            v-db-num-char = entry( v-ind, p1-send-db-list, chr(44) )
            v-db-num      = integer( v-db-num-char )
          .
          if v-db-num <> v-curr-db
            and v-db-num <> p1-db-init
          then do:
            if v-db-for-send = "":U then do:
              assign
                v-db-for-send = v-db-num-char
              .
            end.
            else do:
              assign
                v-db-for-send =  v-db-for-send + chr(1) + v-db-num-char
              .
            end.
          end.
        end.
      end.
    end.
    else do:
      assign
        v-db-for-send = "0":U
      .
    end.
    if v-db-for-send <> "":U then do:
      assign
        v-command = "command":U + chr(1)
                    + "two-commit":U + chr(1)
                    + p1-action + chr(1)
                    + p1-operation + chr(1)
                    + p1-uniq-key-rec + chr(1)
                    + string( p1-db-init ) + chr(1)
                    + p1-parameters + chr(1)
                    + string( p1-answer-code ) + chr(1)
                    + p1-answer-msg
      .
      run nws/cr-route.p ( input 'send-cmd':U
                    ,input v-command
                    ,input ?
                    ,input v-db-for-send
                    ) no-error .
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  return.
end procedure.
procedure create_msg_route :
  define input parameter p2-send-db-list as character no-undo .
  define input parameter p2-msg          as character no-undo .
  do
  on error undo, return error
  :
    define variable v-msg-command as character no-undo .
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-curr-db     as integer   no-undo .
    define variable v-db-for-send as character no-undo .
    define variable v-db-num      as integer   no-undo .
    define variable v-db-num-char as character no-undo .
    define buffer buf_sys-ctrl    for ub.sys-ctrl .
    find first buf_sys-ctrl no-lock .
    assign
      v-curr-db     = buf_sys-ctrl.db-num
      v-db-for-send = "":U
    .
    if v-curr-db = 0 then do:
      assign
        v-num-entries = num-entries( p2-send-db-list, chr(44) )
      .
      do v-ind = 1 to v-num-entries:
        assign
          v-db-num-char = entry( v-ind, p2-send-db-list, chr(44) )
          v-db-num      = integer( v-db-num-char )
        .
        if v-db-num <> v-curr-db then do:
          if v-db-for-send = "":U then do:
            assign
              v-db-for-send = v-db-num-char
            .
          end.
          else do:
            assign
              v-db-for-send =  v-db-for-send + chr(1) + v-db-num-char
            .
          end.
        end.
      end.
    end.
    else do:
      assign
        v-db-for-send = "0":U
      .
    end.
    if v-db-for-send <> "":U then do:
      assign
        v-msg-command = "command":U + chr(1)
                        + "message-to-log":U + chr(1)
                        + p2-msg
      .
      run nws/cr-route.p ( input 'send-cmd':U
                    ,input v-msg-command
                    ,input ?
                    ,input v-db-for-send
                    ) no-error .
      if error-status :error then do:
        return error substitute( "&1&2&3"
                                  , return-value
                                  , chr(10)
                                  , error-status :get-message(1)
                                ).
      end.
    end.
  end.
  return.
end procedure.
function get-send-db-list returns character
  ( input p-curr-db     as integer
   ,input p-all-db-list as character
  )
:
  define variable v-send-db-list as character no-undo .
  if p-curr-db = 0 then do:
    assign
      v-send-db-list = p-all-db-list
    .
  end.
  else do:
    assign
      v-send-db-list = string(p-curr-db)
    .
  end.
  return v-send-db-list .
end function .
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
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table temp-goods_ no-undo like ub.goods.
define temp-table temp-bar-code_ no-undo like ub.bar-code
field status_ as character
.
define temp-table temp-prod-bc_ no-undo like ub.prod-bc
field status_ as character
field on-off as logical
field rc as recid
.
define buffer buf_temp-xml-tables for temp-xml-tables.
function 00110004_get-error-message returns character :
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
function 00110004_after-import_f returns logical ( input p-d-card as character):
  run 00110004_after-import in this-procedure ( input p-d-card) no-error.
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
define variable v-current-gds-code as integer no-undo .
define variable v-line-status_ as character no-undo .
define variable v-group-code as integer no-undo .
define variable v-depart-code as integer no-undo .
define variable v-class-code as integer no-undo .
define variable v-subclass-code as integer no-undo .
define variable v-rowid as rowid no-undo .
define variable v-table-name as character no-undo .
define variable v-vat-rate-code as integer   no-undo .
define variable v-field-list as character no-undo .
define variable v-current-b-code as integer   no-undo .
define variable v-current-b-gds-code as integer no-undo .
define variable v-current-prod-bc-b-str as character no-undo .
define variable v-current-prod-bc-b-code as integer   no-undo .
define variable v-current-prod-bc-bc-on as logical   no-undo .
define variable v-current-prod-bc-status_ as character no-undo .
define variable v-node-code as integer   no-undo .
define variable v_child-qh as handle no-undo .
define variable v_child2-qh as handle no-undo .
define buffer buf_temp-goods_ for temp-goods_.
define buffer buf_temp-bar-code_ for temp-bar-code_.
define buffer buf_temp-prod-bc_ for temp-prod-bc_.
define buffer buf_temp-rel-handle for temp-rel-handle.
define buffer buf2_temp-rel-handle for temp-rel-handle.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_tax-rate for ub.tax-rate.
define variable v-rid as recid no-undo .
_main:
do transaction
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
  run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute(".............Импорт данных по товарам из ВС")).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт данных по товарам из файла &1", file-name)).
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run emptyscl in g#library
  (output v-node-code
  )  .
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
           empty temp-table buf_temp-goods_.
           empty temp-table buf_temp-bar-code_.
           empty temp-table buf_temp-prod-bc_.
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
            when 'goods':U  THEN do:
              empty temp-table buf_temp-goods_.
              empty temp-table buf_temp-bar-code_.
              empty temp-table buf_temp-prod-bc_.
              _tr:
              do
              on error undo _rule, retry _rule
              :
                v-line-num = ImpData1:route-data_get-field-integer( input 'goods':U, input "line-num") .
                v-present = no.
                num-rec = num-rec + 1.
                v-current-gds-code  = ImpData1:route-data_get-field-integer( input 'goods':U, input "gds-code") .
                find first buf_temp-goods_ where
                          buf_temp-goods_.gds-code = v-current-gds-code no-error.
                if not available buf_temp-goods_ then do:
                  create  buf_temp-goods_.
                  assign
                  buf_temp-goods_.gds-code = v-current-gds-code
                  .
                end.
                v-line-status_ = ImpData1:route-data_get-field-character( input 'goods':U, input "status_") .
                v-depart-code = ImpData1:route-data_get-field-integer( input 'goods':U, input "depart-code") .
                v-class-code = ImpData1:route-data_get-field-integer( input 'goods':U, input "class-code") .
                v-subclass-code = ImpData1:route-data_get-field-integer( input 'goods':U, input "subclass-code") .
                find first buf_ext-classif no-lock where
                          buf_ext-classif.classif-subject = 'gds-grp':U
                      and buf_ext-classif.classif-name = 'rpm_gds-grp':U
                      AND buf_ext-classif.db-num = - 1
                      and buf_ext-classif.key#_one = v-depart-code
                      and buf_ext-classif.key#_two = v-class-code
                      and buf_ext-classif.key#_three = v-subclass-code no-error.
                if not available buf_ext-classif then do:
                                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Запись &1: Не найден узел товарного классификатора .../&2/&3/&4"                                               , v-line-num                                               , v-depart-code                                               , v-class-code                                                ,v-subclass-code )).
                  undo _rule, retry _rule.
                end.
                RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                                    ,INPUT ?
                                                    ,INPUT "ub"
                                                    ,INPUT ?
                                                    ,INPUT NO-LOCK
                                                    ,OUTPUT v-rowid
                                                    ,OUTPUT v-table-name) .
                find first buf_gds-grp no-lock where
                          rowid(buf_gds-grp) = v-rowid .
                buf_temp-goods_.grp-code = buf_gds-grp.node-code.
                v-vat-rate-code = ImpData1:route-data_get-field-integer( input 'goods':U, input "rate-code") .
                v-field-list = "artic,prod-type,prod-code,gds-name,engl-name,label-name,chk-name,unit-base" +
                               ",wt-base,ms-base,unit-cli,cli-base-rate,qnty-cart,wt-cart,ms-cart,gds-type,PS,okdp" +
                               ",negative-rest,min-stock,alpha1,grp-code".
                assign
                glog = buffer buf_temp-goods_:handle:buffer-copy(ImpData1:route-data_get-record('goods':U), "gds-code") no-error.
                if not glog
                or error-status:error then do:
                                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось получить данные записи goods: &1&2&3"                                               , error-status:get-message(1)                                               , chr(10)                                               , return-value)).
                  undo _rule, retry _rule.
                end.
                assign
                buf_temp-goods_.nationality = "российский"
                .
                _rel:
                for each buf_temp-rel-handle where
                        buf_temp-rel-handle.parent-buffer_ = v-current-tbl-name:
                  run tmpreld2_query in this-procedure ( buffer buf_temp-rel-handle, input-output v_child-qh) no-error .
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
                    case buf_temp-rel-handle.child-buffer_:
                      when 'bar-code':U then do:
                        v-current-b-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_, input "b-code") .
                        v-current-b-gds-code = ImpData1:route-data_get-field-integer( buffer buf_temp-rel-handle:handle, input buf_temp-rel-handle.child-buffer_, input "gds-code") .
                        if v-current-b-gds-code <> v-current-gds-code then do:
                                                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Запись &1: нарушение схемы")).
                          delete object v_child-qh no-error.
                          undo _rule, retry _rule.
                        end.
                        find first buf_temp-bar-code_ where
                                  buf_temp-bar-code_.gds-code = v-current-b-gds-code
                              and buf_temp-bar-code_.b-code = v-current-b-code  no-error.
                        if not available buf_temp-bar-code_ then do:
                          create  buf_temp-bar-code_.
                          assign
                          buf_temp-bar-code_.gds-code = v-current-gds-code
                          buf_temp-bar-code_.b-code = v-current-b-code
                          .
                        end.
                        assign
                        glog = buffer buf_temp-bar-code_:handle:buffer-copy(buf_temp-rel-handle.child-buffer-handle
                                                                            ,"gds-code,b-code") no-error .
                        if not glog
                        or error-status:error then do:
                                                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось получить данные записи <&4>: &1&2&3"                                                       , error-status:get-message(1)                                                       , chr(10)                                                       , return-value                                                       , 'bar-code':U )).
                          undo _rule, retry _rule.
                        end.
                        _rel2:
                        for each buf2_temp-rel-handle where
                                buf2_temp-rel-handle.parent-buffer_ = 'bar-code':U:
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
                      when 'prod-bc':U
                      THEN do:
                                v-current-prod-bc-b-str = ImpData1:route-data_get-field-character( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "b-str") .
                                v-current-prod-bc-b-code = ImpData1:route-data_get-field-integer( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "b-code") .
                                v-current-prod-bc-bc-on = ImpData1:route-data_get-field-logical( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "bc-on") .
                                v-current-prod-bc-status_ = ImpData1:route-data_get-field-character( buffer buf2_temp-rel-handle:handle, input buf2_temp-rel-handle.child-buffer_, input "status_") .
                                if v-current-prod-bc-b-code <> v-current-b-code then do:
                                                                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Запись &1: нарушение схемы")).
                                  delete object v_child2-qh no-error.
                                  delete object v_child-qh no-error.
                                  undo _rule, retry _rule.
                                end.
                        find first buf_temp-prod-bc_ where
                                  buf_temp-prod-bc_.b-str = v-current-prod-bc-b-str
                              and buf_temp-prod-bc_.b-code = v-current-prod-bc-b-code
                                    no-error.
                        if not available buf_temp-prod-bc_ then do:
                          create  buf_temp-prod-bc_.
                          assign
                          buf_temp-prod-bc_.b-code = v-current-prod-bc-b-code
                          buf_temp-prod-bc_.b-str = v-current-prod-bc-b-str
                          .
                        end.
                        buf_temp-prod-bc_.bc-on = v-current-prod-bc-bc-on.
                                buf_temp-prod-bc_.status_ = v-current-prod-bc-status_.
                        release buf_temp-prod-bc_ .
                      end.
                            end case.
                          end.
                          delete object v_child2-qh no-error.
                        end.
                        release buf_temp-bar-code_ .
                      end.
                    end case.
                  end.
                  delete object v_child-qh no-error.
                end.
            run proc-save in this-procedure ( input v-line-num
                                             ,input v-line-status_
                                             ,input v-vat-rate-code
                                             ,input v-node-code
                                             ,input v-field-list
                                             ,input no
                                             ,input no
                                             ,buffer buf_temp-goods_) no-error.
            if error-status:error then do:
              run set-err-type in p-cont-handle
                ( input 'PROCESSING'
                ) no-error.
              if valid-handle(v_qh) then do:
                delete object v_qh no-error.
              end.
                            run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("&1&2&3"                                            , error-status:get-message(1)                                           , chr(10)                                           , return-value)).
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
      for each temp-goods_:
        delete temp-goods_.
      end.
      for each temp-bar-code_:
        delete temp-bar-code_.
      end.
      for each temp-prod-bc_:
        delete temp-prod-bc_.
      end.
      run garbcoll_clear in this-procedure .
  end.
end procedure.
procedure proc-save :
define input  parameter p-line-num as integer   no-undo .
define input  parameter p-line-status_ as character no-undo .
define input  parameter p-vat-rate-code as integer   no-undo .
define input  parameter p-node-code as integer   no-undo .
define input  parameter p-field-list as character no-undo .
define input  parameter p-dif-nam1 as logical   no-undo .
define input  parameter p-dif-nam2 as logical   no-undo .
define parameter buffer buf_temp-goods_ for temp-goods_.
define buffer buf_temp-bar-code_ for temp-bar-code_.
define buffer buf_temp-prod-bc_ for temp-prod-bc_.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_sysconf for ub.sysconf.
define variable v-rid as recid no-undo .
define variable v-gds-mode as character no-undo .
define variable v-bc-mode as character no-undo .
define variable v-pbc-mode as character no-undo .
define variable v-b-str as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-nbc as integer   no-undo .
define variable v-stts as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-ii as integer   no-undo .
define variable v-cmp as logical   no-undo .
define variable v-cmp-tax as logical no-undo init yes.
define variable v-key-rec as character no-undo .
define variable v-param as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-taxvalue as decimal no-undo .
main-block:
do transaction
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    empty temp-table buf_temp-goods_.
    empty temp-table buf_temp-bar-code_.
    empty temp-table buf_temp-prod-bc_.
          run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input v-err-mess).
     return error ''.
  end.
  else do:
    find first buf_goods share-lock where
            buf_goods.gds-code = buf_temp-goods_.gds-code no-error.
    if not available buf_goods then do:
      v-gds-mode = 'ДОБАВЛЕНИЕ':U.
      v-rid = ?.
    end.
    else do:
      if not (buf_temp-goods_.prod-type = buf_goods.prod-type
              and
              buf_temp-goods_.prod-code = buf_goods.prod-code) then do:
        v-err-mess =  substitute("Запись &1: Изменение производителя товара &2 недопустимо!!!"
                                      ,p-line-num
                                      ,buf_temp-goods_.gds-code
                                      ,p-line-status_ ).
        run set-err-type in p-cont-handle
          ( input 'SYNCHRONIZATION'
          ) no-error.
        undo main-block, retry main-block .
      end.
      v-gds-mode = 'ИЗМЕНЕНИЕ':U.
      v-rid = recid( buf_goods).
      buffer buf_temp-goods_:handle:buffer-copy(buffer buf_goods:handle, p-field-list).
    end.
    if ((v-gds-mode = 'ДОБАВЛЕНИЕ':U and not p-line-status_ = 'N')
    or (v-gds-mode = 'ИЗМЕНЕНИЕ':U and not (p-line-status_ = 'U' or p-line-status_ = 'D'))
        )
    and not (available buf_goods and  buf_goods.stts = integer('1':U) and p-line-status_ = 'N')
    then do:
      v-err-mess =  substitute("Запись &1: Неверное действие над товаром &2 (&3)"
                                    ,p-line-num
                                    ,buf_temp-goods_.gds-code
                                    ,p-line-status_ ).
      run set-err-type in p-cont-handle
        ( input 'SYNCHRONIZATION'
        ) no-error.
      undo main-block, retry main-block .
    end.
    for each tt-tax:
      delete tt-tax.
    end.
    run ref/dtaxgdss.p (
          input yes
        , input   buf_temp-goods_.unit-base
        , input   p-node-code
        , input (if v-gds-mode = 'ДОБАВЛЕНИЕ':U THEN ? ELSE v-rid)
        , input (if v-gds-mode = 'ДОБАВЛЕНИЕ':U THEN ? ELSE v-rid)
        , input   0
        , input    ''
        , input   0
          ) no-error.
    if error-status:error then do:
      v-err-mess = substitute("Запись &1: Ошибки при определении налогов на товар:&2&3&2&4"
                               , p-line-num
                               , chr(10)
                               , error-status:get-message(1)
                               , return-value ).
      undo main-block, retry main-block.
    end.
    find first tt-tax where
              tt-tax.tax-code = integer('1':U).
    if tt-tax.rate-code <> p-vat-rate-code then do:
      v-cmp-tax = no.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  tt-tax.tax-code
  ,input  tt-tax.rate-code
  ,input  v-today
  ,input  0
  ,input  ''
  ,input  0
  ,output v-taxvalue
  ) no-error .
    if error-status:error or v-taxvalue = ? then do:
      v-err-mess = substitute("Запись &1: Ошибка при поиске НДС (код ставкм &6) на текущую дату для товара &2&3&4&3&5"
                                , p-line-num
                                , buf_temp-goods_.gds-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                                , tt-tax.rate-code
                                ).
      undo main-block, retry main-block.
    end.
    if not v-gds-mode = 'ДОБАВЛЕНИЕ':U then do:
      tt-tax.fact-date = v-today.
    end.
    assign
    tt-tax.rate-code = p-vat-rate-code
    .
    if buf_temp-goods_.unit-cli = ''
    or buf_temp-goods_.unit-cli = ? then do:
      assign
      buf_temp-goods_.unit-cli = buf_temp-goods_.unit-base
      buf_temp-goods_.cli-base-rate = 1
      .
    end.
    if buf_temp-goods_.cli-base-rate = 0
    or buf_temp-goods_.cli-base-rate = ?
    then do:
      buf_temp-goods_.cli-base-rate = 1.
    end.
    if v-gds-mode = 'ИЗМЕНЕНИЕ':U then do:
      buffer buf_temp-goods_:handle:buffer-copy(buffer buf_goods:handle, p-field-list).
      do v-ii = 1 to num-entries(p-field-list):
        v-field-list = v-field-list + (if v-ii = 1 then "" else chr(44)) + entry(v-ii, p-field-list) + chr(44) + entry(v-ii, p-field-list).
    end.
      v-cmp = buffer buf_temp-goods_ :handle:buffer-compare(buffer buf_goods:handle, "CASE-SENSITIVE", "", v-field-list).
    end.
    if v-gds-mode = 'ДОБАВЛЕНИЕ':U
    or not v-cmp
    or not v-cmp-tax
    then do:
    run ref/goods01.p (
                        input parparentproc
                        , input v-gds-mode
                      , input no
                      , input 0
                      , input no
                      , input yes
                      , input no
                      , input no
                      , input no
                      , input 0
                      , input ''
                      , input 0
                      , input (if buf_temp-goods_.gds-type = 'т':U then  yes else no)
                      , input ?
                      , input buf_temp-goods_.gds-code
                      , input buf_temp-goods_.artic
                      , input buf_temp-goods_.prod-type
                      , input buf_temp-goods_.prod-code
                      , input p-node-code
                      , input buf_temp-goods_.grp-code
                      , input buf_temp-goods_.gds-name
                      , input "":U
                      , input buf_temp-goods_.engl-name
                      , input buf_temp-goods_.label-name
                      , input buf_temp-goods_.chk-name
                      , input buf_temp-goods_.alpha1
                      , input buf_temp-goods_.unit-base
                      , input buf_temp-goods_.unit-cli
                      , input 0
                      , input 0
                      , input buf_temp-goods_.cli-base-rate
                      , input buf_temp-goods_.qnty-cart
                      , input buf_temp-goods_.ms-base
                      , input buf_temp-goods_.wt-base
                      , input buf_temp-goods_.ms-cart
                      , input buf_temp-goods_.wt-cart
                      , input 'Группа':U
                      , input 0
                      , input buf_temp-goods_.negative-rest
                      , input 0
                      , input 0
                      , input buf_temp-goods_.okdp
                      , input buf_temp-goods_.destin
                      , input buf_temp-goods_.attrib
                      , input buf_temp-goods_.user-rule
                      , input buf_temp-goods_.sert
                      , input buf_temp-goods_.struct
                      , input buf_temp-goods_.deadline
                      , input 0
                      , input buf_temp-goods_.sort
                      , input 0
                      , input 0
                      , input 0
                      , input ''
                      , input buf_temp-goods_.nationality
                      , input buf_temp-goods_.unit-cli
                      , input buf_temp-goods_.cli-base-rate
                      , input ?
                      , input buf_temp-goods_.PS
                      , input no
                      , input no
                      , input no
                      , input no
                      , input "no"
                      , input p-dif-nam1
                      , input p-dif-nam2
                      , input no
                      , input 2
                      , input-output v-rid
                      , output v-nbc
                    ) no-error .
    if error-status :error then do:
      v-err-mess = substitute("Запись &1: Ошибка при сохранении goods &2&3&4&3&5"
                                , p-line-num
                                , buf_temp-goods_.gds-code
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value ).
      undo main-block, retry main-block.
    end.
    end.
    find first buf_goods share-lock where
              recid(buf_goods) = v-rid .
    if (p-line-status_ = 'D'
    and buf_goods.stts = integer('0':U))
    or (p-line-status_ <> 'D'
    and buf_goods.stts <> integer('0':U)) then do:
      v-stts = (if p-line-status_ = 'D'
                then integer('1':U)
                else integer('0':U)).
      run ref/goods02.p (
                    input recid(buf_goods)
                    ,input yes
                    ,input-output v-stts) no-error.
    end.
    if v-gds-mode = 'ДОБАВЛЕНИЕ':U then do:
      find first buf_goods where
                recid(buf_goods) = v-rid.
    end.
    for each buf_temp-bar-code_ no-lock where
            buf_temp-bar-code_.gds-code = buf_temp-goods_.gds-code
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      find first buf_bar-code share-lock where
                buf_bar-code.b-code = buf_temp-bar-code_.b-code no-error.
      if available buf_bar-code then do:
        if buf_bar-code.stts_ = integer('79':U)
        and buf_temp-bar-code_.b-code <> buf_temp-goods_.gds-code
        then do:
          v-bc-mode = 'ДОБАВЛЕНИЕ':U.
        end.
        else do:
        v-bc-mode = 'ИЗМЕНЕНИЕ':U.
        end.
        v-rid = recid(buf_bar-code).
      end.
      else do:
        v-bc-mode = 'ДОБАВЛЕНИЕ':U.
        v-rid = ?.
      end.
      if  buf_temp-bar-code_.b-code = buf_temp-goods_.gds-code
      and v-gds-mode = 'ДОБАВЛЕНИЕ':U then do:
      end.
      else do:
        if (v-bc-mode = 'ДОБАВЛЕНИЕ':U and not buf_temp-bar-code_.status_ = 'N')
        or (v-bc-mode = 'ИЗМЕНЕНИЕ':U
            and not (buf_temp-bar-code_.status_ = 'U' or buf_temp-bar-code_.status_ = 'D')
            and buf_temp-bar-code_.b-code <> buf_temp-goods_.gds-code
            )
      then do:
          v-err-mess =  substitute("Запись &1: Неверное действие над бар-кодом &2 (&3) товара &4"
                                      ,p-line-num
                                        ,buf_temp-bar-code_.b-code
                                        ,buf_temp-bar-code_.status_
                                      ,buf_temp-goods_.gds-code
                                        ).
        run set-err-type in p-cont-handle
          ( input 'SYNCHRONIZATION'
          ) no-error.
        undo main-block, retry main-block .
      end.
        if v-bc-mode = 'ДОБАВЛЕНИЕ':U
        and available buf_bar-code
        and buf_bar-code.stts_ = integer('79':U) then do:
          v-bc-mode = 'ИЗМЕНЕНИЕ':U.
        end.
      end.
      if buf_temp-bar-code_.status_ = 'D' then do:
      end.
      else do:
      if buf_temp-bar-code_.b-code <> buf_temp-goods_.gds-code then do:
      run ref/barcode1.p (
          input (v-bc-mode + chr(44) + 'ДОБАВЛЕНИЕ-ИМПОРТ':U)
      ,input yes
      ,input buf_temp-bar-code_.b-code
      ,input buf_temp-bar-code_.gds-code
      ,input p-node-code
      ,input '':U
      ,input '':U
      ,input buf_temp-bar-code_.unit-cli
      ,input buf_temp-bar-code_.cli-base-rate
      ,output v-rid
      )
      no-error.
      if error-status :error then do:
        v-err-mess = substitute("Запись &1: Ошибка при сохранении bar-code  &2&3&4&5&4&6"
                                  , p-line-num
                                  , buf_temp-bar-code_.b-code
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value
                                  ).
        undo main-block, retry main-block.
      end.
      end.
      end.
      for each buf_temp-prod-bc_ no-lock where
              buf_temp-prod-bc_.b-code = buf_temp-bar-code_.b-code
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        find first buf_prod-bc share-lock where
                  buf_prod-bc.b-code = buf_temp-prod-bc_.b-code
              and buf_prod-bc.b-str = buf_temp-prod-bc_.b-str no-error.
        if available buf_prod-bc then do:
          v-pbc-mode = 'ИЗМЕНЕНИЕ':U.
          v-rid = recid(buf_prod-bc).
          buf_temp-prod-bc_.rc = recid(buf_prod-bc).
        end.
        else do:
          v-pbc-mode = 'ДОБАВЛЕНИЕ':U.
          v-rid = ?.
        end.
        if (v-pbc-mode = 'ДОБАВЛЕНИЕ':U and not buf_temp-prod-bc_.status_ = 'N')
        or (v-pbc-mode = 'ИЗМЕНЕНИЕ':U and not (buf_temp-prod-bc_.status_ = 'U' or buf_temp-prod-bc_.status_ = 'D'))
        then do:
          v-err-mess =  substitute("Запись &1: Неверное действие над ДопБк &2 (&3)"
                                        ,p-line-num
                                        ,buf_temp-prod-bc_.b-str
                                        ,buf_temp-prod-bc_.status_ ).
          run set-err-type in p-cont-handle
            ( input 'SYNCHRONIZATION'
            ) no-error.
          undo main-block, retry main-block .
        end.
        if buf_temp-prod-bc_.status_ = 'D'
        and not available buf_prod-bc then do:
          v-err-mess =  substitute("Запись &1: Неверное действие над ДопБк &2 (&3)"
                                        ,p-line-num
                                        ,buf_temp-prod-bc_.b-str
                                        ,buf_temp-prod-bc_.status_ ).
          run set-err-type in p-cont-handle
            ( input 'SYNCHRONIZATION'
            ) no-error.
          undo main-block, retry main-block .
        end.
        if buf_temp-prod-bc_.status_ = 'N' then do:
        v-b-str = buf_temp-prod-bc_.b-str.
        run trg/prod-bc1.p (
                            input parparentproc
                           ,input yes
                           ,input no
                           ,input yes
                           ,input no
                           ,input ''
                           ,input ''
                           ,buffer buf_goods
                           ,input buf_temp-bar-code_.b-code
                           ,input-output v-b-str
                           ,output v-rid
                      ) no-error .
          if error-status :error
          or v-rid = ?
          then do:
            v-err-mess = substitute("Запись &1: Ошибка при сохранении ДопБк &2 (бар-код &3) &4&5&4&6"
                                    , p-line-num
                                    , buf_temp-prod-bc_.b-str
                                    , buf_temp-prod-bc_.b-code
                                    , chr(10)
                                    , error-status:get-message(1)
                                    , return-value
                                    ).
          undo main-block, retry main-block.
        end.
          buf_temp-prod-bc_.rc = v-rid.
      end.
        if buf_temp-prod-bc_.status_ = 'U' then do:
          if buf_temp-prod-bc_.bc-on <> buf_prod-bc.bc-on then do:
            buf_temp-prod-bc_.on-off = yes.
            run trg/bc-upd.p (
                          input parparentproc
                        ,input buf_temp-prod-bc_.b-code
                        ,input buf_temp-prod-bc_.b-str
                        ,input buf_temp-prod-bc_.bc-on
                        ,input yes
                        ,input no
                        ,input ?
                        ,input this-procedure:handle
                        ) no-error  .
            if error-status:error then do:
              v-err-mess = substitute("Запись &1: Ошибки при вкл/выкл ДопБК &2:&3&4&3&5"
                                      , p-line-num
                                      , buf_temp-prod-bc_.b-str
                                      ,chr(10)
                                      , error-status:get-message(1)
                                      , return-value ).
              undo main-block, retry main-block.
            end.
          end.
        end.
        if buf_temp-prod-bc_.status_ = 'D' then do:
          if buf_prod-bc.bc-on-type <> '' then do:
            v-err-mess = substitute("Запись &1: Нельзя удалить ДопБК типа &2", buf_prod-bc.bc-on-type).
            undo main-block, retry main-block.
          end.
          assign
          buf_prod-bc.bc-on = no
          buf_temp-prod-bc_.bc-on = no
          .
          delete buf_prod-bc.
        end.
      end.
      if buf_temp-bar-code_.status_ = 'D'
      and buf_temp-bar-code_.unit-cli <> buf_goods.unit-base
      then do:
        find first buf_prod-bc no-lock where
                  buf_prod-bc.b-code = buf_temp-bar-code_.b-code no-error.
         if available buf_prod-bc then do:
           v-err-mess = substitute("Невозможно удалить(выключить) бар-код &1 - существуют привязанные к нему ДопБК", buf_temp-prod-bc_.b-code).
            run set-err-type in p-cont-handle
              ( input 'SYNCHRONIZATION'
              ) no-error.
            undo main-block, retry main-block .
         end.
          assign
        buf_temp-bar-code_.stts = integer('79':U)
        buf_bar-code.stts = integer('79':U).
        release buf_bar-code no-error.
        if error-status:error then do:
          v-err-mess = substitute("Запись &1: Невозможно удалить бар-код &2:&3&4"
                                  , p-line-num
                                  , buf_temp-bar-code_.b-code
                                  , chr(10)
                                  , return-value
                                  ).
          run set-err-type in p-cont-handle
            ( input 'SYNCHRONIZATION'
            ) no-error.
          undo main-block, retry main-block .
        end.
      end.
    end.
    run fill-g-list in  p-cont-handle  ( input buf_temp-goods_.gds-code, input '':U, input 0).
    for each buf_temp-bar-code_ :
      if buf_temp-bar-code_.status_ = 'D' then do:
        run fill-bar-code in p-cont-handle (
                                                input  buf_temp-bar-code_.b-code
                                               ,input  buf_temp-bar-code_.gds-code
                                               ,input  (if buf_temp-bar-code_.status_ = 'D'
                                                        then yes
                                                        else no)
                                               ,input  p-node-code
                                               ,input  buf_temp-bar-code_.in-code
                                               ,input  buf_temp-bar-code_.part-code
                                               ,input  buf_temp-bar-code_.cli-base-rate
                                               ,input  buf_temp-bar-code_.unit-cli
                                                ) no-error.
      end.
    end.
    for each buf_temp-prod-bc_,
         first buf_temp-bar-code_ where
             buf_temp-bar-code_.b-code = buf_temp-prod-bc_.b-code
         :
       if buf_temp-prod-bc_.status_ = 'D'
       or buf_temp-prod-bc_.on-off then do:
         run fill-pbc-list in p-cont-handle (
                                                 input buf_temp-prod-bc_.rc
                                               , input buf_temp-goods_.gds-code
                                               , input buf_temp-prod-bc_.b-code
                                               , input buf_temp-prod-bc_.b-str
                                               , input buf_temp-prod-bc_.bc-on
                                               , input (if buf_temp-prod-bc_.status_ = 'D'
                                                        or buf_temp-prod-bc_.bc-on = no
                                                        or buf_temp-bar-code_.status_ = 'D'
                                                        then yes
                                                        else no)
                                               ).
       end.
    end.
  end.
end.
end procedure.
procedure write-file :
define input parameter p-mess as character no-undo .
do
on error undo, return error
:
      run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input p-mess).
end.
end procedure.
