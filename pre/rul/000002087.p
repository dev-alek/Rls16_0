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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info5 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info5, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info5, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info5 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info5, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info5, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info5, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info5, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info5, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info5, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info5 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info5, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info5 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
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
                                                        ,vss-include-info3
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info3
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info3 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info3 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info3 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info3 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info3 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info3 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info3, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info3 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info3 )
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
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info8, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info8 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info8 )
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
define new global shared variable g#lib-gate as handle no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION status-edoc-nn RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
define variable v-obj-db-num as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients  .
define buffer obj_clients for ub.clients  .
define buffer buf_ext-classif for ub.ext-classif  .
define buffer buf2_ext-classif for ub.ext-classif  .
define buffer buf_ext-system  for ub.ext-system  .
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  loc-o-doc.obj-type
  ,input  loc-o-doc.obj-code
  ,output v-obj-db-num
  )  .
find first  buf_clients no-lock where
            buf_clients.obj-type = loc-o-doc.cli-type and
            buf_clients.obj-code = loc-o-doc.cli-code
              no-error .
if not available buf_clients then do:
  p-color = ?.
  return "" .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'clients-edoc-nn':U no-error.
if available buf_ext-classif then do :
  assign
  p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
  no-error .
  return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
end.
else do :
  find first obj_clients no-lock where
            obj_clients.obj-type = loc-o-doc.obj-type
        and obj_clients.obj-code = loc-o-doc.obj-code no-error.
  if not available obj_clients then do:
    return ''.
  end.
  run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                    , input (buffer obj_clients:handle)
                                    , output v-obj-uniq-key-rec).
  for each buf_ext-classif no-lock
        where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
          and buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name    = 'exite-edi':U,
     first buf_ext-system no-lock
        where buf_ext-system.esys-id = buf_ext-classif.key#_one
          and buf_ext-system.db-num  = 0
          and buf_ext-system.esys-have-export = yes
          and buf_ext-system.esys-db-num-exp = v-obj-db-num,
     first buf2_ext-classif no-lock
              where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
                and buf2_ext-classif.classif-subject = 'clients':U
                and buf2_ext-classif.classif-name    = 'exite-edi':U
                and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end.
  return ''.
end.
return ''.
END FUNCTION.
FUNCTION status-is-edoc-nn RETURN logical ( input p-is-edoc-nn   as logical
                                             , input p-cli-type     as character
                                             , input p-cli-code     as integer
                                             , input p-obj-type     as character
                                             , input p-obj-code     as integer
                                             ) .
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edoc-nn then do:
  return no.
end.
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
find first buf_ext-classif no-lock
     where buf_ext-classif.uniq-key-rec    = v-uniq-key-rec
       and buf_ext-classif.classif-subject = 'clients':U
       and buf_ext-classif.classif-name    = 'clients-edoc-nn':U
       no-error.
if available buf_ext-classif then do :
  return yes .
end.
return no.
END FUNCTION.
FUNCTION status-is-edi RETURN logical ( input p-is-edi as logical
                                         , input p-cli-type as character
                                         , input p-cli-code as integer
                                         , input p-obj-type     as character
                                         , input p-obj-code     as integer
                                         , output p-dm-edi as integer
                                         ) .
define variable v-obj-db-num   as integer   no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define buffer buf_clients     for ub.clients .
define buffer obj_clients     for ub.clients .
define buffer buf_ext-classif for ub.ext-classif .
define buffer buf2_ext-classif for ub.ext-classif .
define buffer buf_ext-system  for ub.ext-system  .
if not p-is-edi then do:
  return no.
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-obj-db-num
  )  .
find first buf_clients no-lock
     where buf_clients.obj-type = p-cli-type
       and buf_clients.obj-code = p-cli-code
       no-error .
if not available buf_clients then do:
  return no .
end.
find first obj_clients no-lock where
          obj_clients.obj-type = p-obj-type
      and obj_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return no .
end.
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer buf_clients:handle)
                                  , output v-uniq-key-rec).
run gen-key-rec IN THIS-PROCEDURE ( input 'clients':U
                                  , input (buffer obj_clients:handle)
                                  , output v-obj-uniq-key-rec).
for each buf_ext-classif no-lock
      where buf_ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_ext-classif.classif-subject = 'clients':U
        and buf_ext-classif.classif-name    = 'exite-edi':U,
    first buf_ext-system no-lock
      where buf_ext-system.esys-id = buf_ext-classif.key#_one
        and buf_ext-system.db-num  = 0
        and buf_ext-system.esys-have-export = yes
        and (buf_ext-system.esys-db-num-exp = v-obj-db-num
        or buf_ext-system.esys-db-num-exp = 0),
    first buf2_ext-classif no-lock
            where buf2_ext-classif.uniq-key-rec = v-obj-uniq-key-rec
              and buf2_ext-classif.classif-subject = 'clients':U
              and buf2_ext-classif.classif-name    = 'exite-edi':U
              and buf2_ext-classif.key#_one  = buf_ext-classif.key#_one:
  leave.
end.
if available buf_ext-classif then do :
  p-dm-edi = buf_ext-system.whole-send-news.
  return yes .
end.
return no .
END FUNCTION.
FUNCTION get-gln returns character ( input p-obj-type as character
                                    ,input p-obj-code as integer):
define variable v-uniq-key-rec as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
      and buf_clients.obj-code = p-obj-code no-error.
if not available buf_clients then do:
  return chr(63).
end.
run gen-key-rec  in this-procedure ( input 'clients':U
                                    ,input (buffer buf_clients:handle)
                                    ,output v-uniq-key-rec) no-error.
if error-status:error then do:
   return chr(63).
end.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error .
if available buf_ext-classif then do:
  return buf_ext-classif.charkey_one.
end.
else do:
 return ''.
end.
END FUNCTION.
FUNCTION get-type-code-from-gln returns logical ( input  p-gln      as character
                                                    ,output p-obj-type as character
                                                    ,output p-obj-code as integer) :
define variable v-uniq-key-rec as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
find first buf_ext-classif no-lock where
          buf_ext-classif.classif-subject = 'clients':U
      and buf_ext-classif.classif-name = 'GLN':U
      and buf_ext-classif.charkey_one = p-gln no-error .
if available buf_ext-classif then do:
  assign v-uniq-key-rec = buf_ext-classif.uniq-key-rec.
end.
else do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
if v-uniq-key-rec <> '' then do:
    run gen-key-fv in this-procedure ( input  v-uniq-key-rec
                                      ,output v-field-list
                                      ,output v-value-list).
end.
assign
  p-obj-type = entry(lookup("obj-type":U
                          , v-field-list
                          , chr(3))
                          , v-value-list, chr(3))
  p-obj-code = integer(entry(lookup("obj-code":U
                                  , v-field-list
                                  , chr(3))
                                  , v-value-list, chr(3)))
no-error .
if error-status:error then do:
  assign
    p-obj-type = ''
    p-obj-code = 0
  .
  return no.
end.
else do:
  return yes.
end.
END FUNCTION.
FUNCTION status-edoc-edi-light RETURN CHAR (buffer loc-o-doc for ub.ord-doc
                                   , input is-edoc-nn as logical
                                   , input is-edi as logical
                                   , output p-color as integer ).
p-color = ?.
if not available loc-o-doc then do:
  return ''.
end.
if not ( is-edoc-nn or is-edi)
or loc-o-doc.doc-type <> 'ОП':U  then do:
  p-color = ?.
  return ''.
end.
case loc-o-doc.whole-send-news:
  when integer('1':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , '14,12,?,10,10,?,?,?,?,?,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,10') , ',отправлен,принят,подтвержден,подтвержденOk,согласованный ушел,принят согласованный,поставка пришла,поставка принята,ПН отправлена,Отказ') .
  end.
  when integer('2':U) then do:
    assign
    p-color = integer(entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , '14,12,?,14,?,?,10,?,?,?,?,4,10,4'))
    no-error .
    return entry (lookup (string(loc-o-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка') .
  end .
  otherwise do:
    p-color = ?.
    return ''.
  end.
end case.
end function.
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str15  as character no-undo.
  define variable tmp-num15  as character no-undo.
  define variable i15        as integer   no-undo.
  define variable sum15      as integer   no-undo.
  define variable len-code15 as integer   no-undo.
  define variable varcont15  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str15 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str15 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont15 = yes then do:
    if integer( substring( tmp-str15, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str15, length( bc-pfx ) + 1, length( tmp-str15 ) - length( bc-pfx ) )
        len-code15    = length( full-b-code )
      .
      define variable v-sum-char15 as character no-undo .
      assign
        sum15 = 0
      .
      do i15 = 1 to len-code15 by 2
      :
        assign
          v-sum-char15 = substr(full-b-code, len-code15 - i15 + 1, 1)
        .
        if v-sum-char15 < "0"
        or v-sum-char15 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum15 = sum15 + integer(v-sum-char15)
        .
      end.
      if varcont15 = yes then do:
        assign
          sum15 = sum15 * 3
        .
        do i15 = 2 to len-code15 by 2
        :
          assign
            v-sum-char15 = substr(full-b-code, len-code15 - i15 + 1, 1)
          .
          if v-sum-char15 < "0"
          or v-sum-char15 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum15 = sum15 + integer(v-sum-char15)
          .
        end.
        if varcont15 = yes then do:
           if sum15 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum15 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info17, return-value, chr(10), error-status :get-message (1))
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
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info17, return-value, chr(10), error-status :get-message (1))
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define temp-table tt-RETANN no-undo XML-NODE-NAME "RETANN"
    field NUMBER as character
    field DATE as character
    field INFO as character
    index pi as PRIMARY UNIQUE NUMBER
.
define temp-table tt-HEAD no-undo XML-NODE-NAME "HEAD"
    field NUMBER as character
    field SUPPLIER as character
    field BUYER as character
    field DELIVERYPLACE as character
    field SENDER as character
    field RECIPIENT as character
    index pi as PRIMARY UNIQUE NUMBER
.
define temp-table tt-POSITION no-undo XML-NODE-NAME "POSITION"
    field NUMBER as character
    field POSITIONNUMBER as integer
    field PRODUCT as character
    field PRODUCTIDSUPPLIER as character
    field PRODUCTIDBUYER as character
    field RETURNQUANTITY as decimal
    field RETURNQUANTITYUNIT as character
    field PRICE as decimal
    field AMOUNT as decimal
    index pi as PRIMARY UNIQUE NUMBER POSITIONNUMBER
.
define dataset RETANN_ for tt-RETANN, tt-HEAD, tt-POSITION
    DATA-RELATION r1 for tt-RETANN, tt-HEAD RELATION-FIELDS ( NUMBER, NUMBER ) NESTED
    DATA-RELATION r2 for tt-HEAD, tt-POSITION RELATION-FIELDS ( NUMBER, NUMBER ) NESTED
.
define variable v-current-doc-code as character no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-doc-date as date no-undo .
define variable v-fact-date as date no-undo .
define variable v-fact-qnty as decimal no-undo .
define variable v-ps as character no-undo .
define variable v-changes-list as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer   no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable v-type as character no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-dm-edi    as integer   no-undo .
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable p-xsd-file as character no-undo.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function context_send-esys-command return int64
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
         return 0.
      end.
      delete procedure p-esys-cmd-proc-handle no-error.
      return v-dmp-ord-int64.
   end.
   else do:
      delete procedure p-esys-cmd-proc-handle no-error.        run set-error in this-procedure ( input substitute("Ошибка при отсылке во внешнюю систему &1 команды с кодом &2&3&4&3&5"
                                                    , p-esys-id-list
                                                    , p-cmd-code
                                                    , chr(10)
                                                    , error-status:get-message(1)
                                                    , return-value
                                                    )).
      return 0 .
   end.
end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if return-value = "return" then return ''.
define variable ExpData1 as class Route-data_ no-undo .
ExpData1 = new Route-data_( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle) .
if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  if v-es then do:
      run garbcoll_clear in this-procedure .
            if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))).
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, chr(10), v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.
procedure proc-main :
define variable v-ii as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-cli-uniq-key-rec as character no-undo .
define variable v-err as logical no-undo .
define variable v-custom-pack-name as character no-undo .
define variable v-success as logical   no-undo .
DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-ord-int1 as integer no-undo .
define variable v-obj-gln as character no-undo .
define variable v-cli-gln as character no-undo .
define variable v-frm-gln as character no-undo .
define variable v-transport-gln as character no-undo .
define variable v-mess as character no-undo .
define variable v-b-code as character no-undo .
define variable v-b-str as character no-undo .
define variable l-prod-bc-weight as logical no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
define variable l-is-petrol-code as logical no-undo .
define variable l-is-scaleable as logical no-undo .
define variable v-jj as integer   no-undo .
define variable v-cli-base-rate as decimal no-undo .
define variable v-dump-ord-int64 as int64 no-undo .
define variable v-EDIINTERCHANGEID as character no-undo .
define variable v-edist-mess as character no-undo .
define variable v-deliverynotenumber as character no-undo .
define variable v-deliverynotedate as date no-undo .
define variable v-deliverynotedate-chr as character no-undo .
define variable v-attr-type as character no-undo .
define variable v-date-status as date no-undo .
define variable v-time-status as integer no-undo .
define variable v-date-chr as character no-undo .
define buffer buf_ext-system for ub.ext-system.
define buffer buf_ord-line for ub.ord-line.
define buffer buf_object for ub.clients.
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
define buffer esys_ext-classif for ub.ext-classif.
define buffer buf_goods for ub.goods.
define buffer buf_currency for ub.currency.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_ext-artic for ub.ext-artic.
_main:
do
on error undo _main, return error substitute( "&1&2&3&2&4", return-value, chr(10), error-status :get-message (1), v-last-error-message)
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
 dataset RETANN_:handle:empty-dataset() .
 if retry then do:
        if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при обработке накладной &1&2:&3&4"                                    ,v-current-doc-code                                    , chr(10), v-mess)).
    undo _main, return error.
  end.
  else do:
    assign
    v-mess = ''
    .
    IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = v-cli-type
          and buf_clients.obj-code = v-cli-code no-error.
    if not available buf_clients then do:
      v-mess =  substitute("Не найден контрагент &1&2", v-cli-type, v-cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    run gen-key-rec in this-procedure ( input 'clients':U
                                      ,input (buffer buf_clients:handle)
                                      ,output v-cli-uniq-key-rec) no-error .
    if error-status:error then do:
      v-mess = substitute("gen-key-rec: &1&2&3&2(&4&5)"
                                , error-status:get-message(1)
                                , return-value
                                , chr(10)
                                , v-cli-type
                                , v-cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    find first esys_ext-classif no-lock where
        esys_ext-classif.classif-name = 'exite-edi':U
    and esys_ext-classif.classif-subject = 'clients':U
    and esys_ext-classif.db-num = -1
    and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec no-error .
    if not available esys_ext-classif then do:
      v-mess = substitute("Поставщик &1&2 заказа НЕ РАБОТАЕТ ПО СИСТЕМЕ EDI", v-cli-type, v-cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    find first buf_object no-lock where
              buf_object.obj-type = v-current-obj-type
          and buf_object.obj-code = v-current-obj-code no-error.
    if not available buf_object then do:
      v-mess =  substitute("Не найден объект &1&2", v-current-obj-type, v-current-obj-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    if buf_object.db-num <> g#db-num then do:
      v-mess = substitute("Объект &1&2 принадлежит другой БД", v-current-obj-type, v-current-obj-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    run gen-key-rec in this-procedure ( input 'clients':U
                                      ,input (buffer buf_object:handle)
                                      ,output v-uniq-key-rec) no-error .
    if error-status:error then do:
      v-mess =  substitute("gen-key-rec: &1&2&3&2(&4&5)"
                                , error-status:get-message(1)
                                , return-value
                                , chr(10)
                                , buf_object.obj-type
                                , buf_object.obj-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    assign
    v-obj-gln = get-gln( input buf_object.obj-type
                    ,input buf_object.obj-code) no-error.
    if error-status:error
    or v-obj-gln = chr(63)
    or v-obj-gln = '' then do:
      v-mess =  substitute("Не определен GLN для &1&2"
                                , buf_object.obj-type
                                , buf_object.obj-code) .
      v-err = yes.
      undo _main, retry _main.
    end.
    assign
    v-frm-gln = get-gln( input 'орг':U
                        ,input v-current-host-code) no-error.
    if error-status:error
    or v-frm-gln = chr(63)
    or v-frm-gln = '' then do:
      v-mess =  substitute("Не определен GLN для &1&2"
                                , 'орг':U
                                , v-current-host-code) .
      v-err = yes.
      undo _main, retry _main.
    end.
    v-cli-gln = get-gln( input v-cli-type
                        ,input v-cli-code) no-error.
    if error-status:error
    or v-cli-gln = chr(63)
    or v-cli-gln = '' then do:
      v-mess =  substitute("Не определен GLN для &1&2"
                                , buf_object.obj-type
                                , buf_object.obj-code) .
      v-err = yes.
      undo _main, retry _main.
    end.
    for each esys_ext-classif no-lock where
        esys_ext-classif.classif-name = 'exite-edi':U
    and esys_ext-classif.classif-subject = 'clients':U
    and esys_ext-classif.db-num = -1
    and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec,
      first buf_ext-system no-lock where
                buf_ext-system.esys-id = esys_ext-classif.key#_one
            and buf_ext-system.db-num = 0
            and buf_ext-system.esys-have-export = yes,
      first buf_ext-classif no-lock where
        buf_ext-classif.classif-name = 'exite-edi':U
    and buf_ext-classif.classif-subject = 'clients':U
    and buf_ext-classif.db-num = -1
    and buf_Ext-classif.uniq-key-rec = v-uniq-key-rec
    and buf_Ext-classif.key#_one = esys_ext-classif.key#_one:
      leave.
    end.
    if not available buf_ext-system then do:
      v-mess = substitute("Для поставщика &1&2 не найдена ВС, у которой есть экспорт в текущей БД").
      v-err = yes.
      undo _main, retry _main.
    end.
    IF  context_begin-esys-command( input string(buf_ext-system.esys-id), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-custom-pack-name = substitute("RETANN_&1_&&pack-num.xml"
                                  ,v-obj-gln).
    v-date-chr = subst(
        "&1-&2-&3",
        string(year(v-fact-date), "9999"),
        string(month(v-fact-date), "99"),
        string(day(v-fact-date), "99")).
    create tt-RETANN.
    assign
        tt-RETANN.NUMBER = v-current-doc-code
        tt-RETANN.DATE = v-date-chr
        tt-RETANN.INFO = v-ps
    .
    ExpData1:route-data_create-record("tt-RETANN") .
    ExpData1:route-data_copy-record("tt-RETANN", buffer tt-RETANN:handle) .
    IF ExpData1:esys-add-dump("tt-RETANN", v-esys-cmd-proc-handle, v-esys-cmd-code, '+update') = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    create tt-HEAD.
    assign
        tt-HEAD.NUMBER = v-current-doc-code
        tt-HEAD.SUPPLIER = v-cli-gln
        tt-HEAD.BUYER = v-frm-gln
        tt-HEAD.DELIVERYPLACE = v-cli-gln
        tt-HEAD.SENDER = v-obj-gln
        tt-HEAD.RECIPIENT = v-cli-gln
    .
    ExpData1:route-data_create-record("tt-HEAD") .
    ExpData1:route-data_copy-record("tt-HEAD", buffer tt-HEAD:handle) .
    IF ExpData1:esys-add-dump("tt-HEAD", v-esys-cmd-proc-handle, v-esys-cmd-code, '+update') = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    for each buf_doc-line no-lock where
              buf_doc-line.doc-code = v-current-doc-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      find first buf_goods
        where buf_goods.artic = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
        no-lock no-error.
      if not avail buf_goods then
        return error subst(
            "Не найден товар Артик: &1, Производитель: &2&3",
            buf_doc-line.artic,
            buf_doc-line.prod-type,
            buf_doc-line.prod-code
        ).
      find first buf_ext-artic
        where buf_ext-artic.cli-type = v-cli-type
        and buf_ext-artic.cli-code = v-cli-code
        and buf_ext-artic.gds-code = buf_goods.gds-code
        and buf_ext-artic.status_ = 'тек':U
        no-lock no-error.
      run find-bcod(buf_goods.gds-code, output v-b-code).
      create tt-POSITION.
      assign
        tt-POSITION.NUMBER = v-current-doc-code
        tt-POSITION.POSITIONNUMBER = buf_doc-line.line-num
        tt-POSITION.PRODUCT = v-b-code
        tt-POSITION.PRODUCTIDSUPPLIER = if avail buf_ext-artic then buf_ext-artic.ext-artic else ""
        tt-POSITION.PRODUCTIDBUYER = string(buf_goods.gds-code)
        tt-POSITION.RETURNQUANTITY = v-fact-qnty
        tt-POSITION.RETURNQUANTITYUNIT = buf_goods.unit-cli
        tt-POSITION.PRICE = buf_doc-line.price-base
        tt-POSITION.AMOUNT = tt-POSITION.PRICE * tt-POSITION.RETURNQUANTITY
      .
      ExpData1:route-data_create-record("tt-POSITION") .
      ExpData1:route-data_copy-record("tt-POSITION", buffer tt-POSITION:handle) .
      IF  ExpData1:esys-add-dump("tt-POSITION", v-esys-cmd-proc-handle, v-esys-cmd-code, '+update') = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
    end.
    IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-dump-ord-int64 = context_send-esys-command( input string(buf_ext-system.esys-id), input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid).
    if v-dump-ord-int64 = 0 THEN do:
      undo _main, return error v-last-error-message .
    end.
        ExpData1:Route-data_clear-data ( ) .
  end.
end.
end procedure.
procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-is-waiting-status as logical   no-undo .
define variable v-direction as character no-undo .
define variable v-dm as integer no-undo .
define variable v-ext-doc-type as character no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ord-chain  for ub.ord-chain.
do
on error undo, return error
:
  if g#news then
    return "return".
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
      undo, return error substitute("Передан неверный буфер вместо буфера для &1",  'ord-doc-rcv':U).
    end.
  end.
  otherwise do:
    undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
  end.
  end case.
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
  if v-is-waiting-status = no
  or entry(1, v-direction, chr(4)) = 'удаление':U
  then do:
    return "return".
  end.
  assign
      v-current-doc-code = v-newbh::doc-code
      v-doc-date = v-newbh::doc-date
      v-fact-date = v-newbh::fact-date
      v-ps = v-newbh::ps
      v-ext-doc-type = v-newbh::ext-doc-type
      v-fact-qnty = v-newbh::fact-qnty
  .
  if v-ext-doc-type <> 'ep':U then do:
    return "return".
  end.
  if not v-has-newbh then return "return".
  v-current-obj-type = v-newbh::obj-type.
  v-current-obj-code = v-newbh::obj-code.
  v-cli-type = v-newbh::cli-type.
  v-cli-code = v-newbh::cli-code.
  v-current-host-code = v-newbh::host-code.
  if not status-is-edi(
      true,
      v-cli-type,
      v-cli-code,
      v-current-obj-type,
      v-current-obj-code,
      output v-dm-edi
  ) then return "return".
  find first buf_rule-call-param no-lock
    where buf_rule-call-param.codex_id = p-codex-id
    and buf_rule-call-param.ruleset_id = p-ruleset-id
    and buf_rule-call-param.call_id = p-call-id
    and buf_rule-call-param.order_id = p-order-id
    and buf_rule-call-param.rule_id = p-rule-id
    and buf_rule-call-param.param-name = "p-xsd-file"
    no-error.
  if available buf_rule-call-param then do:
    assign p-xsd-file = buf_rule-call-param.param-value-character.
  end.
end.
end procedure.
procedure find-bcod:
    define input  parameter p-gds-code    as integer   no-undo.
    define output parameter p-bcod        as character no-undo.
    define variable v-is-new as logical no-undo.
    define variable v-flag   as logical no-undo.
    define variable v-bcod   as integer no-undo.
    define variable v-rec1   as recid   no-undo init 0.
    define buffer lc_goods      for ub.goods.
    define buffer lc_gds-prt    for ub.gds-prt.
    define buffer lc_bar-code   for ub.bar-code.
    define buffer lc_prod-bc    for ub.prod-bc.
    find first lc_goods no-lock
        where lc_goods.gds-code = p-gds-code.
    find first lc_gds-prt
        where lc_gds-prt.upper-code = lc_goods.prt-root
        no-lock.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  lc_goods.gds-code
  ,input  ?
  ,output v-bcod
  ) no-error .
    if error-status:ERROR then
        return error subst("Не удалось получить корневой БК для &1", lc_goods.gds-code).
    for each lc_prod-bc no-lock
        where lc_prod-bc.b-code = v-bcod
        and lc_prod-bc.bc-on = true
        :
            if not (length(lc_prod-bc.b-str) = 8
                or
                (length(lc_prod-bc.b-str) >= 11
                and
                length(lc_prod-bc.b-str) <= 14)
                )
                then next.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer lc_prod-bc
  ,input  'petrolium=request':u
  ,output v-flag
  ) no-error .
            if error-status:error then
                return error subst("Не удалось определить свойство для БК &1", lc_goods.gds-code).
            if v-flag then next.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer lc_prod-bc
  ,input  'pgweight=request':u
  ,output v-flag
  ) no-error .
            if error-status:error then
                return error subst("Не удалось определить свойство для БК &1", lc_goods.gds-code).
            if v-flag then next.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer lc_prod-bc
  ,input  'pgweight=request':u
  ,output v-flag
  ) no-error .
            if error-status:error then
                return error subst("Не удалось определить свойство для БК &1", lc_goods.gds-code).
            if v-flag then next.
            v-rec1 = recid(lc_prod-bc).
    end.
    if v-rec1 <> 0 then do:
        find first lc_prod-bc no-lock
            where recid(lc_prod-bc) = v-rec1.
        p-bcod = lc_prod-bc.b-str.
    end.
    else do:
        run gen-bc(v-bcod, output p-bcod).
    end.
end.
