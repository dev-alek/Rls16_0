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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 115".
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
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info2 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info2, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info2, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info2 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info2, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info2 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info2, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info2, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info2, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info2, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info2, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info2 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info2 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info2, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info2 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info2 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info2, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info2, v-inform, v-tbl-name ).
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure statq_has-waiting-stat :
define input parameter p-oldbh              as handle no-undo .
define input parameter p-newbh              as handle no-undo .
define input parameter p-changed-fields     as character no-undo .
define input parameter p-waiting-status     as character no-undo .
define input parameter p-waiting-flag       as logical no-undo .
define input parameter p-waiting-stati      as integer no-undo .
define output parameter p-is-waiting-status as logical no-undo .
define output parameter p-direction         as character no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-changed-fields as character no-undo .
define variable v-ii as integer no-undo .
define variable v-flag as logical   no-undo .
define variable v-some-bh as handle no-undo .
assign
v-has-oldbh = valid-handle(p-oldbh) and p-oldbh:available
v-has-newbh = valid-handle(p-newbh) and p-newbh:available
v-flag = false
.
if v-has-newbh then do:
  if p-changed-fields = '' then do:
    v-changed-fields = "status_,flag_".
    do v-ii = 1 to num-entries(v-changed-fields):
      if p-oldbh:buffer-field(entry(v-ii, v-changed-fields)):buffer-value <> p-newbh:buffer-field(entry(v-ii, v-changed-fields)):buffer-value then do:
        v-flag = yes.
        leave.
      end.
    end.
    if not v-flag then do:
       assign
         p-direction          = ""
         p-is-waiting-status   = false
       .
       return .
    end.
  end.
  else do:
    if lookup("status_", p-changed-fields) = 0
    and lookup("flag_", p-changed-fields) = 0
    and not(p-newbh:new) then do:
       assign
         p-direction          = ""
         p-is-waiting-status   = false
       .
       return .
    end.
    else do:
      if lookup("status_", p-changed-fields) > 0  and lookup("flag_", p-changed-fields) > 0 and
        p-newbh::status_ = p-waiting-status and
        (p-newbh:table = 'price-doc':U or p-newbh::flag_   = p-waiting-flag)   then do:
          assign
              p-direction          = '<закрытие документа>':U
              p-is-waiting-status   = true
          .
          return .
       end.
      if lookup("status_", p-changed-fields) > 0  and lookup("flag_", p-changed-fields) = 0 and
        p-newbh::status_ = p-waiting-status  then do:
          assign
              p-direction          = '<закрытие документа>':U
              p-is-waiting-status   = true
          .
          return .
       end.
      if lookup("status_", p-changed-fields) = 0  and lookup("flag_", p-changed-fields) > 0 and
      (p-newbh:table = 'price-doc':U or p-newbh::flag_   = p-waiting-flag )  then do:
          assign
              p-direction          = '<закрытие документа>':U
              p-is-waiting-status   = true
          .
          return .
       end.
        if lookup("status_", p-changed-fields) > 0  and lookup("flag_", p-changed-fields) > 0 and
        p-newbh::status_ = p-waiting-status and
        (p-newbh:table = 'price-doc':U or p-waiting-flag = ? )  then do:
          assign
              p-direction          = '<закрытие документа>':U
              p-is-waiting-status   = true
          .
          return .
       end.
    end.
  end.
end.
else do:
  if p-changed-fields = '' then do:
    if p-oldbh::status_ = p-waiting-status
    and (p-oldbh:table = 'price-doc':U
        or
      (p-waiting-flag = ?
      or p-oldbh::flag_ = p-waiting-flag)) then do:
      assign
      p-direction = 'удаление':U
      p-is-waiting-status = yes.
      return.
    end.
    else do:
      assign
      p-direction          = ""
      p-is-waiting-status = no.
      return.
    end.
  end.
  else do:
    if lookup("status_", p-changed-fields) = 0
    and lookup("flag_", p-changed-fields) = 0
    then do:
       assign
          p-is-waiting-status  = false
          p-direction          = ""
       .
       return .
    end.
  end.
end.
if v-has-newbh then do:
  v-some-bh = p-newbh.
end.
else do:
  v-some-bh = p-oldbh.
end.
case v-some-bh:table :
  when 'ord-doc':U  then do:
     if v-some-bh::doc-type = 'ОР':U or v-some-bh::doc-type = 'ОП':U then do:
     if v-some-bh::doc-type = 'ОР':U then do:
        run ord-orc in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
     end.
     if v-some-bh::doc-type = 'ОП':U then do:
        run ord-op in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
     end.
     end.
     else do:
       assign
          p-is-waiting-status  = false
          p-direction          = ""
       .
     end.
  end.
  when 'ord-doc-rcv':U  then do:
        run ord-rcv in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
  end.
  when 'trn-doc':U  then do:
        run stat-graf-trn in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
  end.
  when 'price-doc':U then do:
    run stat-graf-price in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
  end.
  when 'inkas':U then do:
        run stat-graf-inkas in this-procedure
        ( input  p-oldbh
         ,input  p-newbh
         ,input  p-changed-fields
         ,input  p-waiting-status
         ,input  p-waiting-flag
         ,output p-is-waiting-status
         ,output p-direction  )  .
  end.
  otherwise do:
       assign
          p-is-waiting-status  = false
          p-direction          = ""
       .
  end.
end case.
return .
end procedure.
procedure ord-op :
define input parameter p-oldbh              as handle no-undo .
define input parameter p-newbh              as handle no-undo .
define input parameter p-changed-fields     as character no-undo .
define input parameter p-waiting-status     as character no-undo .
define input parameter p-waiting-flag       as logical no-undo .
define output parameter p-is-waiting-status as logical no-undo .
define output parameter p-direction         as character no-undo .
define variable v-stat-list as character no-undo extent 5.
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl-i as integer no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error return-value
  :
assign
v-stat-list[1] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'согласование':U +  chr(3) +
                 'поставка':U    +  chr(3) +
                 'закрыто':U  +  chr(3) +
                 'факт':U
v-stat-list[2] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'отказ':U
v-stat-list[3] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'согласование':U +  chr(3) +
                 'отказ':U
v-stat-list[4] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'согласование':U +  chr(3) +
                 'поставка':U    +  chr(3) +
                 'отказ':U
v-stat-list[5] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'согласование':U +  chr(3) +
                 'поставка':U    +  chr(3) +
                 'закрыто':U  +  chr(3) +
                 'отказ':U
.
  assign
  v-waiting-stfl = p-waiting-status
  .
  assign
  v-old-stfl = p-oldbh::status_
  .
  assign
  v-new-stfl = p-newbh::status_
  .
  _ii:
  do v-ii = 1 to 5:
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], chr(3))
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], chr(3))
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], chr(3))
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
      end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to".
      return.
      end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to-up".
      return.
      end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to".
      return.
      end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to-down".
      return.
      end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "from".
      return.
    end.
  end.
  end.
end procedure.
procedure ord-orc :
define input parameter p-oldbh              as handle no-undo .
define input parameter p-newbh              as handle no-undo .
define input parameter p-changed-fields     as character no-undo .
define input parameter p-waiting-status     as character no-undo .
define input parameter p-waiting-flag       as logical no-undo .
define output parameter p-is-waiting-status as logical no-undo .
define output parameter p-direction         as character no-undo .
define variable v-stat-list as character no-undo extent 5.
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl-i as integer no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-ii as integer no-undo .
  do
  on error undo, return error return-value
  :
assign
v-stat-list[1] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'запрос':U +  chr(3) +
                 'разрешено':U    +  chr(3) +
                 'отгружено':U  +  chr(3) +
                 'факт':U
v-stat-list[2] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'отказ':U
v-stat-list[3] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'запрос':U +  chr(3) +
                 'отказ':U
v-stat-list[4] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'запрос':U +  chr(3) +
                 'разрешено':U    +  chr(3) +
                 'отказ':U
v-stat-list[5] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'запрос':U +  chr(3) +
                 'разрешено':U    +  chr(3) +
                 'отгружено':U  +  chr(3) +
                 'отказ':U
.
  assign
  v-waiting-stfl = p-waiting-status
  .
  assign
  v-old-stfl = p-oldbh::status_
  .
  assign
  v-new-stfl = p-newbh::status_
  .
  _ii:
  do v-ii = 1 to 5:
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], chr(3))
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], chr(3))
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], chr(3))
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
      end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to".
      return.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to-up".
      return.
    end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to".
      return.
      end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to-down".
      return.
      end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "from".
      return.
      end.
      end.
  end.
end procedure.
procedure ord-rcv :
define input parameter p-oldbh              as handle no-undo .
define input parameter p-newbh              as handle no-undo .
define input parameter p-changed-fields     as character no-undo .
define input parameter p-waiting-status     as character no-undo .
define input parameter p-waiting-flag       as logical no-undo .
define output parameter p-is-waiting-status as logical no-undo .
define output parameter p-direction         as character no-undo .
define variable v-stat-list as character no-undo extent 5.
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl-i as integer no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-ii as integer no-undo .
   do
   on error undo, return error return-value
   :
  assign
  v-stat-list[1] =
                  ''            +  chr(3) +
                  'новый':U    +  chr(3) +
                  'поставка':U +  chr(3) +
                  'факт':U
  v-stat-list[2] =
                  ''            +  chr(3) +
                  'новый':U    +  chr(3) +
                  'отказ':U
  v-stat-list[3] =
                  ''            +  chr(3) +
                  'новый':U    +  chr(3) +
                  'поставка':U +  chr(3) +
                  'отказ':U
  .
  assign
  v-waiting-stfl = p-waiting-status
  .
  assign
  v-old-stfl = p-oldbh::status_
  .
  assign
  v-new-stfl = p-newbh::status_
  .
  _ii:
  do v-ii = 1 to 5:
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], chr(3))
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], chr(3))
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], chr(3))
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
      end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to".
      return.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to-up".
      return.
    end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to".
      return.
    end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to-down".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "from".
      return.
      end.
      end.
   end.
end procedure.
procedure stat-graf-trn :
define input parameter  p-oldbh              as handle no-undo .
define input parameter  p-newbh              as handle no-undo .
define input parameter  p-changed-fields     as character no-undo .
define input parameter  p-waiting-status     as character no-undo .
define input parameter  p-waiting-flag       as logical no-undo .
define output parameter p-is-waiting-status  as logical no-undo .
define output parameter p-direction          as character no-undo .
define variable v-doc-code as character no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-stat-list as character no-undo extent 84.
define variable v-stat-list-all as character no-undo .
define variable v-jj as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-waiting-stfl-i as integer no-undo .
do
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1))
:
if p-newbh = ?  then do:
  v-doc-code = p-oldbh::doc-code .
  v-ext-doc-type = p-oldbh::ext-doc-type .
end.
else do:
  v-doc-code     = p-newbh::doc-code .
  v-ext-doc-type = p-newbh::ext-doc-type .
end.
assign
v-stat-list-all =
                 '' +           chr(4) + string(no) + chr(3) +
                 'запрос':U +   chr(4) + string(no) + chr(3) +
                 'запрос':U +   chr(4) + string(yes) + chr(3) +
                 'накл':U +      chr(4) + string(no) + chr(3) +
                 'накл':U +      chr(4) + string(yes) + chr(3) +
                 'разрешен':U + chr(4) + string(no) + chr(3) +
                 'разрешен':U + chr(4) + string(yes) + chr(3) +
                 'факт':U +      chr(4) + string(yes)
.
assign
v-stat-list[lookup('ie':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('ee':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('ee':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 2] =
                                                                 '' +           chr(4) + string(no) + chr(3) +
                                                                 'готов':U     + chr(4) + string(yes)
v-stat-list[lookup('ee':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 1] =
                                                                 '' +           chr(4) + string(no) + chr(3) +
                                                                 'отказ':U  +  chr(4) + string(yes)
v-stat-list[lookup('ep':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('re':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('we':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('vp':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] =
                                                                ''              + chr(4) + string(no) + chr(3) +
                                                                'накл':U         + chr(4) + string(no) + chr(3) +
                                                                'факт':U         + chr(4) + string(yes)
v-stat-list[lookup('iv':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('ev':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('io':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('eo':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('rv':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('em':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] = v-stat-list-all
v-stat-list[lookup('wm':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] =
                                                                ''              + chr(4) + string(no) + chr(3) +
                                                                'прво':U + chr(4) + string(yes) + chr(3) +
                                                                'факт':U         + chr(4) + string(yes)
v-stat-list[lookup('im':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] =
                                                                ''              + chr(4) + string(no) + chr(3) +
                                                                'факт':U         + chr(4) + string(yes)
v-stat-list[lookup('ap':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] =
                                                                      ''              + chr(4) + string(no) + chr(3) +
                                                                      'накл':U         + chr(4) + string(no) + chr(3) +
                                                                      'факт':U         + chr(4) + string(yes)
v-stat-list[lookup('mp':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] =
                                                                      ''              + chr(4) + string(no) + chr(3) +
                                                                      'факт':U         + chr(4) + string(yes)
v-stat-list[lookup('pc':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] =
                                                                      ''              + chr(4) + string(no) + chr(3) +
                                                                      'факт':U         + chr(4) + string(yes)
.
assign
v-stat-list[lookup('ie':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 2] =
                 '' +           chr(4) + string(no) + chr(3) +
                 'запрос':U +   chr(4) + string(no) + chr(3) +
                 'запрос':U +   chr(4) + string(yes) + chr(3) +
                 'накл':U +      chr(4) + string(no) + chr(3) +
                 'накл':U +      chr(4) + string(yes) + chr(3) +
                 'разрешен':U + chr(4) + string(no) + chr(3) +
                 'разрешен':U + chr(4) + string(yes) + chr(3) +
                 'факт':U +      chr(4) + string(no)
.
assign
v-stat-list[lookup('vt':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] =
                 '' +           chr(4) + string(no) + chr(3) +
                 'запрос':U +   chr(4) + string(no) + chr(3) +
                 'запрос':U +   chr(4) + string(yes) + chr(3) +
                 'накл':U +      chr(4) + string(no) + chr(3) +
                 'накл':U +      chr(4) + string(yes) + chr(3) +
                 'разрешен':U + chr(4) + string(yes) + chr(3) +
                 'разрешен':U + chr(4) + string(no) + chr(3) +
                 'факт':U +      chr(4) + string(yes)
.
assign
v-stat-list[lookup('vt':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 2] =
                 '' +           chr(4) + string(no) + chr(3) +
                 'запрос':U +   chr(4) + string(no) + chr(3) +
                 'запрос':U +   chr(4) + string(yes) + chr(3) +
                 'накл':U +      chr(4) + string(no) + chr(3) +
                 'накл':U +      chr(4) + string(yes) + chr(3) +
                 'разрешен':U + chr(4) + string(yes) + chr(3) +
                 'разрешен':U + chr(4) + string(no) + chr(3) +
                 'факт':U +      chr(4) + string(no)
.
assign
v-stat-list[lookup('es':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] =
                 '' +           chr(4) + string(no) + chr(3) +
                 'касс':U + chr(4) + string(no) + chr(3) +
                 'касс':U + chr(4) + string(yes) + chr(3) +
                 'нередакт':U + chr(4) + string(yes) + chr(3) +
                 'факт':U +      chr(4) + string(yes)
v-stat-list[lookup('rs':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3] =
                 '' +           chr(4) + string(no) + chr(3) +
                 'касс':U + chr(4) + string(no) + chr(3) +
                 'касс':U + chr(4) + string(yes) + chr(3) +
                 'нередакт':U + chr(4) + string(yes) + chr(3) +
                 'факт':U +      chr(4) + string(yes)
v-stat-list[lookup('es':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 2] =
                 '' +         chr(4) + string(no) + chr(3) +
                 'запрос':U + chr(4) + string(no)
v-stat-list[lookup('rs':U, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 2] =
                 '' +         chr(4) + string(no) + chr(3) +
                 'запрос':U + chr(4) + string(no)
.
_jj:
do v-jj = 1 to 2:
  if v-jj = 1 then do:
    assign
    v-waiting-stfl = p-waiting-status + chr(4) + string(if p-waiting-flag = ? then yes else p-waiting-flag)
    .
  end.
  if v-jj = 2 then do:
    if p-waiting-flag <> ? then leave  _jj.
    assign
    v-waiting-stfl = p-waiting-status + chr(4) + string(no)
    .
  end.
  assign
  v-old-stfl = p-oldbh::status_ + chr(4) + string(p-oldbh::flag_)
  .
  assign
  v-new-stfl = p-newbh::status_ + chr(4) + string(p-newbh::flag_)
  .
  _ii:
  do v-ii = (lookup(v-ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4 - 3) to (lookup(v-ext-doc-type, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U) * 4):
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], chr(3))
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], chr(3))
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], chr(3))
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to".
      return.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to-up".
      return.
    end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to".
      return.
    end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to-down".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "from".
      return.
    end.
  end.
end.
end.
end procedure .
procedure stat-graf-price :
define input parameter p-oldbh              as handle no-undo .
define input parameter p-newbh              as handle no-undo .
define input parameter p-changed-fields     as character no-undo .
define input parameter p-waiting-status     as character no-undo .
define input parameter p-waiting-flag       as logical no-undo .
define output parameter p-is-waiting-status as logical no-undo .
define output parameter p-direction         as character no-undo .
define variable v-stat-list as character no-undo extent 5.
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl-i as integer no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-ii as integer no-undo .
do
on error undo, return error return-value
:
assign
v-stat-list[1] =
                 ''            +  chr(3) +
                 'новый':U    +  chr(3) +
                 'приказ':U      +  chr(3) +
                 'разрешен':U  +  chr(3) +
                 'акт':U
.
  assign
  v-waiting-stfl = p-waiting-status
  .
  assign
  v-old-stfl = p-oldbh::status_
  .
  assign
  v-new-stfl = p-newbh::status_
  .
  _ii:
  do v-ii = 1 to 5:
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], chr(3))
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], chr(3))
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], chr(3))
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to".
      return.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to-up".
      return.
    end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to".
      return.
    end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to-down".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "from".
      return.
    end.
  end.
end.
end procedure.
procedure stat-graf-inkas :
define input parameter  p-oldbh              as handle no-undo .
define input parameter  p-newbh              as handle no-undo .
define input parameter  p-changed-fields     as character no-undo .
define input parameter  p-waiting-status     as character no-undo .
define input parameter  p-waiting-flag       as logical no-undo .
define output parameter p-is-waiting-status  as logical no-undo .
define output parameter p-direction          as character no-undo .
define variable v-doc-code as character no-undo .
define variable v-ext-doc-type as character no-undo .
define variable v-stat-list as character no-undo extent 3.
define variable v-jj as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-old-stfl as character no-undo .
define variable v-new-stfl as character no-undo .
define variable v-waiting-stfl as character no-undo .
define variable v-old-stfl-i as integer no-undo .
define variable v-new-stfl-i as integer no-undo .
define variable v-waiting-stfl-i as integer no-undo .
do
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1))
:
if p-newbh = ?  then do:
  v-doc-code = p-oldbh::inkas-code .
end.
else do:
  v-doc-code     = p-newbh::inkas-code .
end.
assign
v-stat-list[1] =
                 '' +           chr(4) + string(no) + chr(3) +
                 'новый':U + chr(4) + string(no) + chr(3) +
                 'факт':U +      chr(4) + string(no)
v-stat-list[2] =
                 '' +           chr(4) + string(no) + chr(3) +
                 'новый':U + chr(4) + string(no) + chr(3) +
                 'новый':U + chr(4) + string(yes) + chr(3) +
                 'нередакт':U + chr(4) + string(yes) + chr(3) +
                 'факт':U +      chr(4) + string(no)
v-stat-list[3] =
                 '' +         chr(4) + string(no) + chr(3) +
                 'запрос':U + chr(4) + string(no)
.
_jj:
do v-jj = 1 to 2:
  if v-jj = 1 then do:
    assign
    v-waiting-stfl = p-waiting-status + chr(4) + string(if p-waiting-flag = ? then no else p-waiting-flag)
    .
  end.
  if v-jj = 2 then do:
    if p-waiting-flag <> ? then leave  _jj.
    assign
    v-waiting-stfl = p-waiting-status + chr(4) + string(yes)
    .
  end.
  assign
  v-old-stfl = p-oldbh::status_ + chr(4) + string(p-oldbh::flag_)
  .
  assign
  v-new-stfl = p-newbh::status_ + chr(4) + string(p-newbh::flag_)
  .
  _ii:
  do v-ii = 1 to 3:
    if v-stat-list[v-ii] = '' then next.
    assign
    v-waiting-stfl-i = lookup(v-waiting-stfl, v-stat-list[v-ii], chr(3))
    v-old-stfl-i = lookup(v-old-stfl, v-stat-list[v-ii], chr(3))
    v-new-stfl-i = lookup(v-new-stfl, v-stat-list[v-ii], chr(3))
    .
    if v-waiting-stfl-i = 0
    or v-old-stfl-i = 0
    or v-new-stfl-i = 0
    then do:
      next _ii.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i = v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to".
      return.
    end.
    if v-old-stfl-i < v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "to-up".
      return.
    end.
    if v-new-stfl-i = v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to".
      return.
    end.
    if v-new-stfl-i < v-waiting-stfl-i
    and v-old-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "to-down".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i > v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<закрытие документа>':U + chr(4) + "from".
      return.
    end.
    if v-old-stfl-i = v-waiting-stfl-i
    and v-new-stfl-i < v-waiting-stfl-i then do:
      assign
      p-is-waiting-status = yes
      p-direction = '<открытие документа>':U + chr(4) + "from".
      return.
    end.
  end.
end.
end.
end procedure .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 define new global shared variable g#partolib as handle no-undo.
define variable v-current-doc-code as character no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-changes-list as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-thref.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-last-error-message as character no-undo .
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-action as character no-undo .
define variable v-doc-code          as character  no-undo .
define variable v-ext-doc-type      as character  no-undo .
define variable v-trn-doc-obj-type  as character  no-undo .
define variable v-trn-doc-obj-code  as integer    no-undo .
define variable v-trn-doc-cli-type as character no-undo .
define variable v-trn-doc-cli-code as integer no-undo .
define variable v-trn-doc-doc-type as character no-undo .
define variable v-obj-db-num        as integer    no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-error :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
     assign
     v-last-error-message = p-mess.
  end.
end procedure.
  define variable p-xsd-file as character no-undo.
on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.
if return-value = "return" then return ''.
if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
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
define variable v-err               as logical    no-undo .
define variable v-rsrv-code as character no-undo .
define variable v-unrv-code as character no-undo .
define variable v-need-rsrv as logical   no-undo .
define variable v-need-unrv as logical   no-undo .
define variable v-rsrv-sign as integer   no-undo .
define variable v-unrv-sign as integer   no-undo .
define variable v-action as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-value as character no-undo .
define variable v-deleted as logical no-undo .
define buffer buf_doc-line for ub.doc-line.
define buffer buf_parts for ub.parts.
define buffer free_parts for ub.parts.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_goods for ub.goods.
for each buf_doc-line no-lock where
        buf_doc-line.doc-code = v-doc-code,
  first  buf_gds-obj no-lock where
        buf_gds-obj.obj-type = v-trn-doc-obj-type
    and buf_gds-obj.obj-code = v-trn-doc-obj-code
    and buf_gds-obj.artic = buf_doc-line.artic
    and buf_gds-obj.prod-type = buf_doc-line.prod-type
    and buf_gds-obj.prod-code = buf_doc-line.prod-code
    :
  if buf_gds-obj.cash-parts = no then next.
  FOR EACH buf_parts NO-LOCK WHERE
          buf_parts.artic = buf_doc-line.artic AND
          buf_parts.prod-type = buf_doc-line.prod-type AND
          buf_parts.prod-code = buf_doc-line.prod-code AND
          buf_parts.out-code = v-doc-code AND
          buf_parts.obj-type = buf_doc-line.obj-type AND
          buf_parts.obj-code = buf_doc-line.obj-code:
    find first free_parts no-lock where
          free_parts.obj-type = buf_parts.obj-type
        and free_parts.obj-code = buf_parts.obj-code
        and free_parts.artic = buf_parts.artic
        and free_parts.prod-type = buf_parts.prod-type
        and free_parts.prod-code = buf_parts.prod-code
        and free_parts.in-code = buf_parts.in-code
        and free_parts.part-code = buf_parts.part-code
        and free_parts.out-code  = 'free-zone':U
        and free_parts.status_   = false no-error.
    if available free_parts then do:
if valid-handle( g#partolib ) <> yes then do:       run str/partolib.p persistent no-error.       if error-status :error or valid-handle( g#partolib ) <> yes then do:         message "Error starting partolib.p"    skip( 0 )                 g#partolib                     skip( 0 )                 g#partolib   :type             skip( 0 )                 g#partolib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run partolib_partodel in g#partolib (  input buf_parts.obj-type
                       ,input buf_parts.obj-code
                       ,input buf_gds-obj.gds-code
                       ,input buf_parts.prt-code
                       ,input buf_parts.in-code
                       ,input 'out-zone':U
                       ,input ''
                       ,input 'parts-end':U
                       ,output v-deleted )  .
    end.
    else do:
     if v-action = 'удаление':U then do:
        assign
        v-unrv-code = ''
        v-need-unrv = no.
        if buf_parts.fact-qnty <> 0
        then do:
          define variable v-create-part as logical   no-undo .
          define variable v-old-return  as logical   no-undo .
          assign
            v-create-part = false
            v-old-return  = false
          .
          if buf_parts.in-code = v-doc-code
          then do:
            assign
              v-create-part = true
            .
            if buf_parts.supp-type <>
        ( if v-trn-doc-doc-type = 'при':U then v-trn-doc-cli-type else v-trn-doc-obj-type )
            or buf_parts.supp-code <>
        ( if v-trn-doc-doc-type = 'при':U then v-trn-doc-cli-code else v-trn-doc-obj-code )
            then do:
              assign
                v-old-return = true
              .
            end.
          end.
          define variable v-is-hold as logical   no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  v-doc-code
  ,output v-is-hold
  ) no-error .
          if error-status :error
          then do:
                        undo, return error substitute("&1 &2 &3&4Ошибка при определении типа документа hold-doc.i&4" +                                        "Документ &5 &6&7&4&8&4&9"                                       ,vss-workfile                                                 ,vss-revision                                                 ,vss-description                                              ,chr(10)                                        ,v-doc-code                                           ,v-trn-doc-obj-type                                       ,v-trn-doc-obj-code                                        , error-status:get-message(1)                                       , return-value ).
          end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partcond in g#library
  (input  v-ext-doc-type
  ,input  v-is-hold
  ,input  buf_parts.fact-qnty
  ,input  v-create-part
  ,input  v-old-return
  ,output v-rsrv-code
  ,output v-unrv-code
  ,output v-need-rsrv
  ,output v-need-unrv
  ,output v-rsrv-sign
  ,output v-unrv-sign
  ) no-error .
          if error-status :error
          then do:
                        undo, return error substitute("&1 &2 &3&4Ошибка при определении параметров резервирования партии.i&4" +                                 "Документ &5 &6&7&4&8&4&9"                               , vss-workfile                                           ,vss-revision                                            ,vss-description                                         ,chr(10)                              ,v-doc-code                                 ,v-trn-doc-obj-type                              ,v-trn-doc-obj-code                               , error-status:get-message(1)                              , return-value ).
          end.
        end.
        if v-need-unrv
        and v-unrv-code = 'free-zone':U then do:
if valid-handle( g#partolib ) <> yes then do:       run str/partolib.p persistent no-error.       if error-status :error or valid-handle( g#partolib ) <> yes then do:         message "Error starting partolib.p"    skip( 0 )                 g#partolib                     skip( 0 )                 g#partolib   :type             skip( 0 )                 g#partolib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run partolib_partodel in g#partolib (  input buf_parts.obj-type
                       ,input buf_parts.obj-code
                       ,input buf_gds-obj.gds-code
                       ,input buf_parts.prt-code
                       ,input buf_parts.in-code
                       ,input 'out-zone':U
                       ,input ''
                       ,input 'parts-end':U
                       ,output v-deleted )  .
        end.
      end.
     else do:
      run cur-time in this-procedure ( output v-today, output v-time).
      v-value = substitute("&1-&2-&3", string(year(v-today),"9999"), string(month(v-today), "99"), string(day(v-today), "99")).
if valid-handle( g#partolib ) <> yes then do:       run str/partolib.p persistent no-error.       if error-status :error or valid-handle( g#partolib ) <> yes then do:         message "Error starting partolib.p"    skip( 0 )                 g#partolib                     skip( 0 )                 g#partolib   :type             skip( 0 )                 g#partolib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run partolib_partowrt in g#partolib (  input buf_parts.obj-type
                       ,input buf_parts.obj-code
                       ,input buf_gds-obj.gds-code
                       ,input buf_parts.prt-code
                       ,input buf_parts.in-code
                       ,input buf_parts.out-code
                       ,input 'out-zone':U
                       ,input 'parts-end':U
                       ,input v-value) .
      end.
    end.
  end.
end.
end.
end procedure.
procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-flag as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-changes-list2 as character no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-is-waiting-status as logical no-undo .
define variable v-direction as character no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_clients for ub.clients.
do
on error undo, return error
:
  assign
  v-oldbh = widget-handle (entry(2, p-doc-code, chr(4)))
  v-newbh = widget-handle (entry(3, p-doc-code, chr(4)))
  v-changes-list = entry(4, p-doc-code, chr(4))
  file-name  = p-process-file-name
  v-has-oldbh = valid-handle(v-oldbh) and v-oldbh:available
  v-has-newbh = valid-handle(v-newbh) and v-newbh:available
  .
  if not v-has-newbh
  and not v-has-oldbh then do:
    undo, return error substitute("Не определено ни одного буфера - ни старый, ни новый").
  end.
  if not v-has-oldbh
  and v-changes-list  = '' then do:
     undo, return error substitute("Не определен старый буфер и список изменений").
  end.
  case p-ruleset-id:
    when 115 then do:
      if v-has-newbh
      and v-newbh:table <> 'trn-doc':U then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  'trn-doc':U).
      end.
      if v-has-oldbh
      and v-oldbh:table <> 'trn-doc':U then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  'trn-doc':U).
      end.
    end.
    otherwise do:
      undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
    end.
  end case.
  if v-has-newbh then do:
    v-trn-doc-obj-type = v-newbh::obj-type.
    v-trn-doc-obj-code = v-newbh::obj-code.
    v-doc-code = v-newbh:buffer-field("doc-code"):buffer-value.
    v-ext-doc-type = v-newbh:buffer-field("ext-doc-type"):buffer-value.
    assign
    v-trn-doc-doc-type = v-newbh::doc-type
    v-trn-doc-cli-type = v-newbh::cli-type
    v-trn-doc-cli-code = v-newbh::cli-code
    v-trn-doc-doc-type = v-newbh::doc-type
    .
  end.
  else do:
    v-trn-doc-obj-type = v-oldbh::obj-type.
    v-trn-doc-obj-code = v-oldbh::obj-code.
    v-doc-code = v-oldbh:buffer-field("doc-code"):buffer-value.
    v-ext-doc-type = v-oldbh:buffer-field("ext-doc-type"):buffer-value.
    assign
    v-trn-doc-doc-type = v-oldbh::doc-type
    v-trn-doc-cli-type = v-oldbh::cli-type
    v-trn-doc-cli-code = v-oldbh::cli-code
    v-trn-doc-doc-type = v-oldbh::doc-type.
    v-action = 'удаление':U.
  end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  v-trn-doc-obj-type
  ,input  v-trn-doc-obj-code
  ,output v-obj-db-num
  )  .
  if g#db-num <> 0 and v-obj-db-num <> g#db-num then do:
    return 'return'.
  end.
  for each buf_rule-call-param no-lock where
  buf_rule-call-param.codex_id = p-codex-id
  and buf_rule-call-param.ruleset_id = p-ruleset-id
  and buf_rule-call-param.call_id = p-call-id
  and buf_rule-call-param.order_id = p-order-id
  and buf_rule-call-param.rule_id = p-rule-id
  and buf_rule-call-param.param-name = "p-objects"
  and buf_rule-call-param.p-index > 0
  :
    if buf_rule-call-param.param-value-character = v-trn-doc-obj-type + string(v-trn-doc-obj-code) then leave.
  end.
  if not available buf_rule-call-param then return "return".
    run statq_has-waiting-stat in this-procedure (
                                                  input v-oldbh
                                                 ,input v-newbh
                                                 ,input v-changes-list
                                                 ,input 'факт':U
                                                 ,input ?
                                                 ,input 0
                                                 ,output v-is-waiting-status
                                                 ,output v-direction
                                                 ) no-error.
  if v-is-waiting-status = no then return "return".
end.
end procedure.
