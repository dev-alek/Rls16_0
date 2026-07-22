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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 30,130".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info6 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info6, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info6, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info6 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info6, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info6 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info6, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info6, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info6, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info6, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info6, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info6 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info6 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info6, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info6 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info6 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info6, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info6, v-inform, v-tbl-name ).
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
                                                        ,vss-include-info4
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info4
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info4 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info4 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info4 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info4 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info4 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info4 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info4, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info4 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info4 )
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info10, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info10 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info10 )
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    define  variable price-rubl-with-tax-sale    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-sale    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-sale like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-sale like ub.doc-line.price-base no-undo.
    define  variable vat-base-sale               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyer              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyer              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-sale               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-sale               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-sale          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-sale          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-sale            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-sale            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-sale            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-sale            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtl for ub.gds-dtl.
    define buffer out-vatp_parts       for ub.parts.
    define buffer out-vatp_sysconf     for ub.sysconf.
    define buffer out-vatp_doc-line    for ub.doc-line.
    define buffer out-vatp_goods       for ub.goods.
    define buffer out-vatp_trn-doc     for ub.trn-doc.
    define buffer out-vatp_doc-attr    for ub.doc-attr.
    define variable varprice-base-cons      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-cons      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-type         as   character                           no-undo.
    define variable varfrm-cnsv              as   character                           no-undo.
    define variable varroot-node             as   integer                             no-undo.
    define variable varempty-scale           as   logical                             no-undo.
    define variable varis-cons-parts-have    as   logical                             no-undo.
    define variable varsum-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovp  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovp      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovp   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovp       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qnty             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtl        as   logical                             no-undo.
    define variable varcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprb               as   character                           no-undo.
    define variable out-vatp-have-vat-slt    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-doco  for ub.trn-doc .
    define buffer   in-vatp-partso    for ub.parts   .
    define buffer   in-vatp-doco      for ub.trn-doc .
    define buffer   in-vatp-goodso    for ub.goods   .
    define buffer   in-vatp-sysconfo  for ub.sysconf .
    define buffer   in-vatp_doc-attro for ub.doc-attr.
    define variable in-vatp-have-vat-slto       as   logical initial yes    no-undo.
    define variable vat-pc-loco                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbo                  as   character              no-undo.
    define variable slt-pc-loco                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateo              as   decimal                no-undo.
    define variable price-rubl-with-tax-loco    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loco    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loco     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loco like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loco like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loco  like ub.doc-line.price-base no-undo.
    define variable vat-base-loco               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loco               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loco               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loco                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loco          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loco           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loco         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loco         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loco          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loco             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loco             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loco              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loco          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdo             as   character              no-undo.
    define variable varinvatp-typeo             as   character              no-undo.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cp-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-range          as integer   no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для выгрузки в XML)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'grp-code':U then do:     assign     p-label = "Группа платежа"     p-type = 'C':U      p-format = "X(45)"     p-label = "Группа платежа"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=grp-code':u      .   end.
            when 'is-use':U then do:     assign     p-label = "Используется"     p-type = 'C':U      p-format = "X(255)"     p-label = "Используется"     p-range = 4     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=is-use':u      .   end.
            when 'dop-doc':U then do:     assign     p-label = "Дополнительный документ"     p-type = 'C':U      p-format = "X(255)"     p-label = "Дополнительный документ"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=dop-doc':u      .   end.
            when 'paycard-all-prefix':U then do:     assign     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-type = 'C':U      p-format = "X(19)"     p-label = "Префиксы платежных карт, разрешенных для редактирования"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = 'spr=paycard-prefix':u      .   end.
            when 'form_km3':U then do:     assign     p-label = "Формировать КМ-3 по чекам возврата"     p-type = 'L':U      p-format = "+/-"     p-label = "Формировать КМ-3 по чекам возврата"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'bal_malina':U then do:     assign     p-label = "Оплата баллами Малина"     p-type = 'L':U      p-format = "+/-"     p-label = "Оплата баллами Малина"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'max_proc_sum':U then do:     assign     p-label = "Максимальный % порог от суммы"     p-type = 'D':U      p-format = ">>9.99"     p-label = "Максимальный % порог от суммы"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
            when 'mask_card_kup':U then do:     assign     p-label = "Маска карты\купона"     p-type = 'C':U      p-format = "x(129)"     p-label = "Маска карты\купона"     p-range = 0     p-user-can-edit  = true     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code ).
      end.
    end.
  end.
end procedure.
procedure cp-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для выгрузки в XML)"     p-label = "Префиксы платежных карт (для выгрузки в XML)" .   end.
            when 'grp-code':U then do:     assign     p-tooltip = "Группа платежа"     p-label = "Группа платежа" .   end.
            when 'is-use':U then do:     assign     p-tooltip = "Используется"     p-label = "Используется" .   end.
            when 'dop-doc':U then do:     assign     p-tooltip = "Дополнительный документ"     p-label = "Дополнительный документ" .   end.
            when 'paycard-all-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт (для разбора чеков и т.д.)"     p-label = "Префиксы платежных карт (для разбора чеков и т.д.)" .   end.
            when 'paycard-edit-prefix':U then do:     assign     p-tooltip = "Префиксы платежных карт, разрешенных для редактировани"     p-label = "Префиксы платежных карт, разрешенных для редактирования" .   end.
            when 'form_km3':U then do:     assign     p-tooltip = "Формировать КМ-3 по чекам возврата"     p-label = "Формировать КМ-3 по чекам возврата" .   end.
            when 'bal_malina':U then do:     assign     p-tooltip = "Оплата баллами Малина"     p-label = "Оплата баллами Малина" .   end.
            when 'max_proc_sum':U then do:     assign     p-tooltip = "Максимальный % порог от суммы"     p-label = "Максимальный % порог от суммы" .   end.
            when 'mask_card_kup':U then do:     assign     p-tooltip = "Маска карты\купона"     p-label = "Маска карты\купона" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут типа кассового платежа &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure cp-attr-value :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input  parameter p-code        like ub.cash-pay-attr.attr-code      no-undo .
    define output parameter p-value       like ub.cash-pay-attr.attr-value    no-undo .
    define output parameter p-type        as character no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr no-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code  = p-code
      no-error .
    if avail buf_cash-pay-attr then do:
      assign
        p-value =  buf_cash-pay-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure cp-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define input parameter p-value    like ub.cash-pay-attr.attr-value no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define buffer last_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if not available buf_cash-pay-attr then do:
      create buf_cash-pay-attr .
      assign
      buf_cash-pay-attr.cdpay-code = p-cdpay-code
      buf_cash-pay-attr.curr-code  = p-curr-code
      buf_cash-pay-attr.host-code  = p-host-code
      buf_cash-pay-attr.obj-type   = p-obj-type
      buf_cash-pay-attr.obj-code   = p-obj-code
      buf_cash-pay-attr.attr-code = p-code
      .
    end.
    assign
      buf_cash-pay-attr.attr-value = p-value
    .
    release buf_cash-pay-attr no-error .
    if error-status:error then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cp-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error .
    if  available buf_cash-pay-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure cp-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-cdpay-code   like ub.cash-pay-attr.cdpay-code     no-undo .
    define input parameter p-curr-code    like ub.cash-pay-attr.curr-code      no-undo .
    define input parameter p-host-code    like ub.cash-pay-attr.host-code      no-undo .
    define input parameter p-obj-type     like ub.cash-pay-attr.obj-type       no-undo .
    define input parameter p-obj-code     like ub.cash-pay-attr.obj-code       no-undo .
    define input parameter p-code     like ub.cash-pay-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-range          as integer   no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run cp-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-range
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_cash-pay-attr exclusive-lock
      where buf_cash-pay-attr.cdpay-code = p-cdpay-code
        and buf_cash-pay-attr.curr-code  = p-curr-code
        and buf_cash-pay-attr.host-code  = p-host-code
        and buf_cash-pay-attr.obj-type   = p-obj-type
        and buf_cash-pay-attr.obj-code   = p-obj-code
        and buf_cash-pay-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_cash-pay-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_cash-pay-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure cp-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-news = true.   end.
            when 'grp-code':U then do:     assign     p-news = true.   end.
            when 'is-use':U then do:     assign     p-news = true.   end.
            when 'dop-doc':U then do:     assign     p-news = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-news = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-news = true.   end.
            when 'form_km3':U then do:     assign     p-news = false.   end.
            when 'bal_malina':U then do:     assign     p-news = false.   end.
            when 'max_proc_sum':U then do:     assign     p-news = true.   end.
            when 'mask_card_kup':U then do:     assign     p-news = true.   end.
      otherwise do:
        p-news = no.
      end.
    end.
  end.
end procedure.
procedure cp-attr-hist :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-hist           as logical   no-undo .
    case p-code :
            when 'paycard-export-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-all-prefix':U then do:     assign     p-hist = true.   end.
            when 'paycard-edit-prefix':U then do:     assign     p-hist = true.   end.
            when 'form_km3':U then do:     assign     p-hist = true.   end.
            when 'bal_malina':U then do:     assign     p-hist = true.   end.
            when 'max_proc_sum':U then do:     assign     p-hist = true.   end.
            when 'mask_card_kup':U then do:     assign     p-hist = true.   end.
      otherwise do:
        p-hist = no.
      end.
    end.
  end.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-cpa-pcep no-undo
field cdpay-code like ub.cash-pay.cdpay-code
field curr-code like ub.cash-pay.cdpay-code
field prefix as character
index pi is primary
cdpay-code
curr-code
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cpapcep:
define variable ii as integer no-undo .
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr.
define buffer buf_temp-cpa-pcep for temp-cpa-pcep.
  do
  on error undo, return error
  :
     for each buf_cash-pay-attr no-lock where
            buf_Cash-pay-attr.attr-code = 'paycard-export-prefix':U:
       do ii = 1 to num-entries(buf_Cash-pay-attr.attr-value):
        create buf_temp-cpa-pcep.
        assign
        buf_temp-cpa-pcep.cdpay-code = buf_cash-pay-attr.cdpay-code
        buf_temp-cpa-pcep.curr-code = buf_cash-pay-attr.curr-code
        buf_temp-cpa-pcep.prefix = entry(ii, buf_Cash-pay-attr.attr-value)
        .
      end.
    end.
  end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-2 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS
  unique
  primary
      gds-code
      pay-desk
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-3 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS UNIQUE PRIMARY
        gds-code
        pay-desk
        cpay-code
        curr-code
        prefix
        is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE NEW SHARED TEMP-TABLE treal-4 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS UNIQUE PRIMARY
      gds-code
      pay-desk
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure strtdate :
  define input  parameter p-str         as character no-undo .
  define output parameter p-value       as date      no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
do
on error undo, return error return-value
:
  define variable v-value       as date      no-undo .
  define variable v-i           as integer   no-undo .
  define variable v-num         as integer   no-undo .
  define variable v-delim       as character no-undo .
  define variable v-delim-list  as character no-undo .
  define variable v-day         as integer   no-undo .
  define variable v-month       as integer   no-undo .
  define variable v-year        as integer   no-undo .
  define variable v-day-str     as character no-undo .
  define variable v-month-str   as character no-undo .
  define variable v-year-str    as character no-undo .
  assign
    p-value       = ?
    p-data-valid  = false
  .
  if p-str = ?
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Не задана строка для преобразования. " )
    .
    return .
  end.
  if p-str = ""
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Задана пустая строка для преобразования. " )
    .
    return .
  end.
  if length(p-str)  > 10
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверная длина строки. " )
    .
    return .
  end.
  assign
    v-delim-list = '/,-,.':U
  .
  _delim:
  do v-i = 1 to num-entries( v-delim-list )
  :
    assign
      v-delim = entry( v-i , v-delim-list )
      v-num   = num-entries( p-str , v-delim )
    .
    if v-num <> 3
    then do:
      assign
        v-delim = ''
      .
    end.
    else do:
      leave _delim.
    end.
  end.
  if v-delim = ''
  then do:
    assign
      p-message = substitute( "Ошибка при преобразовании к дате. Неправильный разделитель, либо ошибочное количество разделителей. " )
    .
    return .
  end.
  assign
    v-day-str   = entry( 1, p-str , v-delim)
    v-month-str = entry( 2, p-str , v-delim)
    v-year-str  = entry( 3, p-str , v-delim)
  .
  if  length(v-day-str) > 2   or
      length(v-day-str) < 1   or
      length(v-month-str) > 2 or
      length(v-month-str) < 1 or
      (
        length(v-year-str) <> 2 and
        length(v-year-str) <> 4
      )
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неправильное количество символов числа, месяца, либо года. " )
    .
    return .
  end.
  if length( v-year-str ) = 2
  then do:
    assign
      v-year-str = substring( string( year(today) ), 1 , 2 ) + v-year-str
    .
  end.
  assign
    v-day   = integer( v-day-str )
    v-month = integer( v-month-str)
    v-year  = integer( v-year-str)
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный формат символов числа, месяца, либо года. " )
    .
    return .
  end.
  if v-day < 1  or
     v-day > 31 or
     v-month < 1 or
     v-month > 12 or
     v-year < 0   or
     v-year > 5000
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный диапозон числа, месяца, года. " )
    .
    return .
  end.
  assign
    v-value = date( v-month, v-day, v-year )
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. &1. " , error-status :get-message(1))
    .
    return .
  end.
  assign
    p-value       = v-value
    p-data-valid  = true
  .
end.
end procedure.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info20, return-value, chr(10), error-status :get-message (1))
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
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info20, return-value, chr(10), error-status :get-message (1))
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
define variable v-current-doc-code as character no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-action as character no-undo .
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
define variable num-rec-pre as integer no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-esys-id-list-start as character no-undo .
define variable v-esys-id-list as character no-undo .
define variable v-doc-list-bh as handle no-undo .
define variable v-doc-list-handle as handle no-undo .
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
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
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table doc-list no-undo
field doc-date   like ub.trn-doc.doc-date
field doc-code   like ub.trn-doc.doc-code
field obj-type   like ub.trn-doc.obj-type
field obj-code   like ub.trn-doc.obj-code
field fact-num   like ub.trn-doc.fact-num
field fact-date  like ub.trn-doc.fact-date
field shift-date like ub.trn-doc.shift-date
field shift-num  like ub.trn-doc.shift-num
field shift-name like ub.trn-doc.shift-name
field fact-order as decimal
field is-trn-doc as logical
field is-del as logical
field doc-type   like ub.trn-doc.doc-type
field ext-doc-type   like ub.trn-doc.ext-doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field is-archive-exist as logical
index xpk is primary unique doc-code doc-type
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
index isdel is-del
.
define buffer inkas_trn-doc for ub.trn-doc .
define buffer c-inkas_trn-doc for ub.c-trn-doc .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table doc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
  define variable p-esys-id-list as integer no-undo .
  define variable p-xsd-file as character no-undo.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При маршрутизации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action29   as character no-undo .
  define variable v-printed29       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При маршрутизации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + log-file-name)
    ,input  7
    ,output v-user-action29
    ,output v-printed29
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
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
on stop undo, return error substitute( "&1&2&3", return-value, chr(10), error-status :get-message (1))
:
  define variable v-doc-code as character no-undo .
  define variable v-trn-doc-obj-type as character no-undo .
  define variable v-trn-doc-obj-code as integer no-undo .
  define variable v-obj-db-num as integer no-undo .
  define variable v-obj-uniq-key-rec as character no-undo .
  define variable v-doc-list-doc-type as character no-undo .
  define buffer buf_inkas for ub.inkas.
  define buffer buf_c-inkas for ub.c-inkas.
  define buffer buf_clients for ub.clients.
  define buffer buf_ext-classif for ub.ext-classif.
_stroka:
do while true
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  case p-ruleset-id:
    when 30 then do:
      if v-doc-list-bh:available then do:
        v-doc-list-bh:buffer-delete().
      end.
      run cb_get-next-doc-by-doc-code in v-doc-list-handle ( input v-doc-code
                                                            ,input v-doc-list-doc-type
                                                            ,input v-doc-list-bh
                                                            ).
      if v-doc-list-bh:available then do:
        if num-rec-pre > 0 then do:
          run write-counter in p-log-handle ( input substitute("Просмотрено документов списка &1, обработано  &2, из них удачно: &3", num-rec-pre, num-rec, num-rec-ok)).
        end.
        num-rec-pre = num-rec-pre + 1.
        v-trn-doc-obj-type = v-doc-list-bh:buffer-field("obj-type"):buffer-value.
        v-trn-doc-obj-code = v-doc-list-bh:buffer-field("obj-code"):buffer-value.
        v-doc-code = v-doc-list-bh:buffer-field("doc-code"):buffer-value.
        v-doc-list-doc-type = v-doc-list-bh:buffer-field("doc-type"):buffer-value.
        if not (v-doc-list-doc-type = 'касс':U
        or v-doc-list-doc-type  = "-" + 'касс':U)
        then do:
          next _stroka.
        end.
      END.
      else do:
        v-trn-doc-obj-type = ''.
        v-trn-doc-obj-code = 0.
        v-doc-code = ''.
        leave _stroka.
      end.
    end.
    when 130 then do:
      if v-has-newbh then do:
        v-trn-doc-obj-type = v-newbh::obj-type.
        v-trn-doc-obj-code = v-newbh::obj-code.
        v-doc-code = v-newbh:buffer-field("inkas-code"):buffer-value.
      end.
      else do:
        v-trn-doc-obj-type = v-oldbh::obj-type.
        v-trn-doc-obj-code = v-oldbh::obj-code.
        v-doc-code = v-oldbh:buffer-field("inkas-code"):buffer-value.
      end.
    end.
  end case.
  find first buf_clients no-lock where
            buf_clients.obj-type = v-trn-doc-obj-type
       and  buf_clients.obj-code = v-trn-doc-obj-code.
  run gen-key-rec in this-procedure ( input 'clients':U
                                     ,input buffer buf_clients:handle
                                     ,output v-obj-uniq-key-rec).
  v-esys-id-list = ''.
  for each buf_ext-classif no-lock where
      buf_ext-classif.classif-name = 'clients-esys':U
  and buf_ext-classif.classif-subject = 'clients':U
  and buf_ext-classif.db-num = 0
  and buf_Ext-classif.uniq-key-rec = v-obj-uniq-key-rec :
    if lookup(string(buf_ext-classif.key#_one), v-esys-id-list-start, chr(1)) = 0 then next.
    v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else chr(1)) + string(buf_ext-classif.key#_one).
  end.
  case p-ruleset-id:
    when 30 then do:
      if v-esys-id-list = '' then next _stroka.
    end.
    when 130 then do:
      if v-esys-id-list = '' then leave _stroka.
    end.
  end case.
  if v-has-newbh
  or p-ruleset-id = 30
  then do:
    if p-save >= 0 then do:
      case p-ruleset-id:
        when 30 then do:
          if v-doc-list-doc-type = 'касс':U then do:
            find first buf_inkas exclusive-lock where
                      buf_inkas.inkas-code = v-doc-code
                    no-error.
            if buf_inkas.status_ <> 'факт':U then next _stroka.
            v-action = 'U':U.
          end.
          if v-doc-list-doc-type = "-" + 'касс':U then do:
            find first buf_c-inkas exclusive-lock where
                      buf_c-inkas.inkas-code = v-doc-code
                  and buf_c-inkas.is-del = yes  no-error.
            if buf_c-inkas.status_ <> 'факт':U then next _stroka.
            v-action = 'D':U.
          end.
        end.
        when 130 then do:
          find first buf_inkas exclusive-lock where
                    buf_inkas.inkas-code = v-doc-code
                  no-error.
        end.
      end case.
    end.
    else do:
      case p-ruleset-id:
        when 130 then do:
          find first buf_inkas no-lock where
                    buf_inkas.inkas-code = v-doc-code
                  no-error.
        end.
      end case.
    end.
  end.
  num-rec = num-rec + 1.
  IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  IF  context_begin-esys-command( input v-esys-id-list
                                , input-output v-esys-cmd-proc-handle
                                , output v-esys-cmd-code) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  run edocsinkas_export in this-procedure ( buffer buf_inkas
                                           ,input (if p-ruleset-id = 130
                                                   then (if v-has-newbh then v-newbh else v-oldbh)
                                                   else (if v-doc-list-doc-type = 'касс':U
                                                         then (buffer buf_Inkas:handle)
                                                         else (buffer buf_c-Inkas:handle)
                                                         )
                                                   )
                                        ) no-error.
  if error-status:error then do:
    undo _main, return error ''.
  end.
  IF  context_send-esys-command( input v-esys-id-list
                              , input v-esys-cmd-proc-handle
                              , input v-esys-cmd-code
                              , input g#userid) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  num-rec-ok = num-rec-ok + 1.
    ExpData1:Route-data_clear-data ( ) .
  if p-ruleset-id = 130 then do:
    leave _stroka.
  end.
  else do:
    run get-stop-state in p-log-handle ( output v-stop) no-error .
    if v-stop then do:
            run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Процесс прерван пользователем")).
      leave _stroka.
    end.
  end.
  end.
  if p-ruleset-id = 30
  then do:
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Просмотрено документов списка &1, обработано  &2, из них удачно: &3", num-rec-pre, num-rec, num-rec-ok)).
  end.
end.
end procedure.
procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-flag as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-is-waiting-status as logical no-undo .
define variable v-direction as character no-undo .
define variable v-direction-2 as character no-undo .
define variable v-changes-list as character no-undo .
define variable v-h as handle no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_ext-system for ub.ext-system.
do
on error undo, return error
:
case p-ruleset-id:
  when 30 then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run calltree in g#library
  (input  'cb_get-next-doc-by-doc-code'
  ,input  this-procedure:handle
  ,input  p-cont-handle
  ,output v-doc-list-handle
  )  .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run calltree in g#library
  (input  'cb_rcps-run_fill-rcp-from-tt0'
  ,input  this-procedure:handle
  ,input  p-cont-handle
  ,output v-h
  )  .
    run  cb_rcps-run_fill-rcp-from-tt0 in v-h ( input p-call-id
                                              ,input buffer buf_temp-rule-call-param:handle
                                                            ).
    for each buf_temp-rule-call-param no-lock where
    buf_temp-rule-call-param.codex_id = p-codex-id
    and buf_temp-rule-call-param.ruleset_id = p-ruleset-id
    and buf_temp-rule-call-param.call_id = p-call-id
    and buf_temp-rule-call-param.order_id = p-order-id
    and buf_temp-rule-call-param.rule_id = p-rule-id
    and buf_temp-rule-call-param.param-name = "p-esys-id-list",
      first buf_ext-system no-lock where
            buf_Ext-system.esys-id = buf_temp-rule-call-param.param-value-integer
        and buf_Ext-system.db-num = 0
        and buf_Ext-system.esys-have-export = yes
        and buf_Ext-system.esys-db-num-exp = g#db-num:
      v-esys-id-list-start = v-esys-id-list-start + (if v-esys-id-list-start = '' then '' else chr(1)) + string(buf_ext-system.esys-id).
    end.
    if v-esys-id-list-start = '' then return "return".
    find first buf_temp-rule-call-param no-lock where
    buf_temp-rule-call-param.codex_id = p-codex-id
    and buf_temp-rule-call-param.ruleset_id = p-ruleset-id
    and buf_temp-rule-call-param.call_id = p-call-id
    and buf_temp-rule-call-param.order_id = p-order-id
    and buf_temp-rule-call-param.rule_id = p-rule-id
    and buf_temp-rule-call-param.param-name = "p-xsd-file"
    no-error.
    if available buf_temp-rule-call-param then do:
      assign p-xsd-file = buf_temp-rule-call-param.param-value-character.
    end.
    v-doc-list-bh = buffer doc-list:handle.
    v-action = 'U':U.
  end.
  when 130 then do:
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
      if v-has-newbh
      and v-newbh:table <> 'inkas':U then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  'inkas':U).
      end.
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
      if num-entries(v-direction, chr(4)) > 1 then do:
        v-direction-2 = entry(2, v-direction, chr(4)).
        v-direction = entry(1, v-direction, chr(4)).
        if v-direction-2 <> "to"
        and v-direction-2 <> "from" then return "return".
        if v-direction = '<открытие документа>':U
        and v-direction-2 = "to" then return "return".
        if v-direction = '<закрытие документа>':U
        and v-direction-2 = "from" then return "return".
      end.
      if v-direction = '<открытие документа>':U
      or v-direction = 'удаление':U
      then do:
        v-action = 'D':U.
      end.
      else do:
        v-action = 'U':U.
      end.
    for each buf_rule-call-param no-lock where
    buf_rule-call-param.codex_id = p-codex-id
    and buf_rule-call-param.ruleset_id = p-ruleset-id
    and buf_rule-call-param.call_id = p-call-id
    and buf_rule-call-param.order_id = p-order-id
    and buf_rule-call-param.rule_id = p-rule-id
    and buf_rule-call-param.param-name = "p-esys-id-list",
      first buf_ext-system no-lock where
            buf_Ext-system.esys-id = buf_rule-call-param.param-value-integer
        and buf_Ext-system.db-num = 0
        and buf_Ext-system.esys-have-export = yes
        and buf_Ext-system.esys-db-num-exp = g#db-num:
      v-esys-id-list-start = v-esys-id-list-start + (if v-esys-id-list-start = '' then '' else chr(1)) + string(buf_ext-system.esys-id).
    end.
    if v-esys-id-list-start = '' then return "return".
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
  end.
  otherwise do:
    undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
  end.
end case.
end.
end procedure.
define temp-table operation no-undo
field referenceNo as character
field isDel as logical
field codeOperation as character
field host as integer
field store as character
field factOrder as decimal
field sysDateXml as date
field sysTime as character
field dateDelXml as date
field dateDocXml as date
field dateFactXml as date
field timeFact as character
field comment as character
field shiftDateXml as date
field shiftNum as integer
field shiftName as character
field techfuel as logical
field factQnty as decimal column-label "Кол-во факт."
field totalSum as decimal column-label "Сумма брутто"
field totalDsc as decimal column-label "Скидка"
field totalFact as decimal column-label 'Сумма нетто'
index pi is unique primary
referenceNo
.
define temp-table saleDoc no-undo
field saleReferenceNo as character
field referenceNo as character
field codeOperation as character
index pi is primary
saleReferenceNo
codeOperation
referenceNo
.
define temp-table cassSum no-undo
field referenceNo as character
field code as integer
field currCode as integer
field sum as decimal
field sumr as decimal
field sumb as decimal
index pi is unique primary
referenceNo
code
.
define temp-table payCode no-undo
field referenceNo as character
field good as integer
field deskcode as integer
field payCode as integer
field quantity as decimal
field sum as decimal
field sumb as decimal
field sumr as decimal
index pi is unique primary
referenceNo
good
deskcode
payCode
.
define temp-table payCard no-undo
field referenceNo as character
field good as integer
field deskcode as integer
field payCode as integer
field num as character
field quantity as decimal
field sumr as decimal
index pi is unique primary
referenceNo
good
deskcode
payCode
num
.
define temp-table check1 no-undo XML-NODE-NAME "check"
field referenceNo as character
field type as character
field num as integer
field doccode  as character
field desk as integer
field dateXml as date
field chk-time as character xml-node-name "time"
field shiftDateXml as date
field shiftNum as integer
field dCard as character
field dCardCliType as character
field dCardCliCode as integer
field discnt as decimal
field cashier as integer
field cashierPsnCode as integer
field salesMan as integer
field zNumber as integer
field manualMaked as logical
field manualChanged as logical
field subDiscnt as decimal
field totDoc  as decimal
index pi is unique primary
referenceNo
docCode
.
define temp-table checkGds no-undo
field doccode  as character
field gdsCode as integer
field qnty as decimal
field priceBase as decimal
field priceDiscnt as decimal
field lineNum as integer
field pump as integer
field roadTax as decimal
field srcCode as character
field srcQnty as decimal
field srcPrice as decimal
index pi is unique primary
doccode
linenum
.
define temp-table checkPay no-undo
field docCode as character
field payCode as integer
field payCard as character
field currCode as integer
field sumBase as decimal
field sumRubl as decimal
field sumTot as decimal
field lineNum as integer
index pi is unique primary
doccode
linenum
.
define temp-table checkDiscount no-undo
field docCode as character
field recType as integer
field lineNum as integer
field discnt-id as integer
field discntVCode as integer
field objectLineNum as integer
field discntTargetCode as integer
field discntTypeCode as integer
field discntValueAbs as decimal
field discntValuePcnt as decimal
field srcDCard as character
field discntKategory as integer
index pi is unique primary
doccode
recType
linenum
discnt-id
.
define dataset inkas-01
xml-node-name "inkas-01"
for operation, saleDoc, cassSum,
paycode, payCard,
check1, checkGds, checkPay, checkDiscount
data-relation operation-saleDoc for operation, saleDoc relation-fields (referenceNo, saleReferenceNo) nested
data-relation saleDoc-cassSum for saleDoc, cassSum relation-fields (referenceNo, referenceNo) nested
data-relation saleDoc-payCode for saleDoc, payCode relation-fields (referenceNo, referenceNo) nested
data-relation saleDoc-payCard for payCode, payCard relation-fields (referenceNo, referenceNo, good, good, deskcode, deskcode, payCode, paycode) nested
data-relation operation-check1 for operation, check1 relation-fields (referenceNo, referenceNo) nested
data-relation check1-checkGds for check1, checkGds relation-fields (docCode, docCode) nested
data-relation check1-checkPay for check1, checkPay relation-fields (docCode, docCode) nested
data-relation check1-checkDiscount for check1, checkDiscount relation-fields (docCode, docCode) nested
.
define temp-table temp_inkas-pay no-undo
field pay-code  like inkas-pay.pay-code
field curr-code  like inkas-pay.pay-code
field tot-base  like inkas-pay.tot-base
field tot-rubl  like inkas-pay.tot-rubl
field tot-sum   like inkas-pay.tot-sum
field doc-type as character
index pi is primary unique pay-code curr-code
.
define temp-table temp-inkas no-undo like ub.inkas.
procedure edocsinkas_export :
define parameter buffer buf_inkas for ub.inkas.
define input parameter p-bh as handle no-undo .
define variable v-err-mess as character no-undo .
define variable glog as logical no-undo .
define variable v-attr-type as character no-undo .
define variable v-is-out as integer no-undo .
define variable v-scale-is-empty as logical no-undo .
define variable v-is-petrol                 as logical      no-undo.
define variable v-is-pieces                 as logical      no-undo.
define variable v-petrol-weight             as decimal      no-undo.
define variable v-petrol-density            as decimal      no-undo.
define variable v-weight-not-specified      as logical      no-undo.
define variable v-date-valid as logical no-undo .
define variable v-error-message as character no-undo .
define variable v-date-char as character no-undo .
define variable v-temp-bh as handle no-undo .
define buffer buf_operation for operation.
define buffer buf_casssum for cassSum.
define buffer buf_currency for ub.currency.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer buf_c-inkas for ub.c-inkas.
define buffer buf_sale-doc for ub.sale-doc.
main-block:
do
on error undo main-block, retry main-block
:
  EMPTY TEMP-TABLE operation.
  empty temp-table cassSum.
  empty temp-table payCode.
  empty temp-table temp_inkas-pay.
  empty temp-table payCard.
  empty temp-table temp-inkas.
  if retry then do:
    EMPTY TEMP-TABLE operation.
    empty temp-table cassSum.
    empty temp-table payCode.
    empty temp-table temp_inkas-pay.
    empty temp-table payCard.
    empty temp-table temp-inkas.
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input v-err-mess).
    return error ''.
  end.
  else do:
    create temp-inkas.
    v-temp-bh = buffer temp-inkas:handle.
    v-temp-bh:buffer-copy (p-bh).
    if v-action = 'D':U then do:
      find first buf_c-inkas no-lock where
                buf_c-inkas.inkas-code = p-bh::inkas-code
            and buf_c-inkas.is-del = yes no-error.
    end.
    create buf_operation.
    assign
    buf_operation.referenceNo = temp-inkas.inkas-code
    buf_operation.isDel = (v-action = 'D':U)
    buf_operation.dateDelXml = (if v-action = 'D':U
                                then (if available buf_c-inkas
                                      then buf_c-inkas.corr-date
                                      else ?)
                                else ?)
    buf_operation.codeOperation = "sale"
    buf_operation.host = temp-inkas.host-code
    buf_operation.factorder = 0
    buf_operation.sysDateXML = temp-inkas.sys-date
    buf_operation.dateDocXML = temp-inkas.doc-date
    buf_operation.dateFactXML = temp-inkas.fact-date
    buf_operation.shiftDateXML = temp-inkas.shift-date
    buf_operation.shiftNum = temp-inkas.shift-num
    buf_operation.shiftName = temp-inkas.shift-name
    buf_operation.comment = temp-inkas.PS
    buf_operation.store = temp-inkas.obj-type + string(temp-inkas.obj-code)
    buf_operation.systime = string(temp-inkas.sys-time, "HH:MM:SS")
    buf_operation.factQnty = temp-inkas.qnty
    buf_operation.totalSum =  temp-inkas.tot-doc
    buf_operation.totalDsc = temp-inkas.discnt
    buf_operation.totalFact = temp-inkas.netto
    .
    if v-action = 'D':U then do:
      ExpData1:route-data_create-record( INPUT "operation") .
      ExpData1:route-data_copy-record ( input "operation", buffer buf_operation:handle).
      IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи operation &1:&2&3"
                                , temp-inkas.inkas-code
                                , chr(10)
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
      return.
    end.
    ExpData1:route-data_create-record( INPUT "operation") .
    ExpData1:route-data_copy-record ( input "operation", buffer buf_operation:handle).
    IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи operation &1:&2&3"
                              , buf_inkas.inkas-code
                              , chr(10)
                              , v-last-error-message
                              ).
      undo main-block, retry main-block.
    end.
    for each buf_sale-doc no-lock where
            buf_sale-doc.inkas-code = buf_inkas.inkas-code
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if not available saleDoc then do:
        create saleDoc.
      end.
      assign
      saleDoc.saleReferenceNo = buf_inkas.inkas-code
      saleDoc.referenceNo     = buf_sale-doc.doc-code
      saleDoc.codeOperation   = buf_sale-doc.doc-kind
      .
      ExpData1:route-data_create-record( INPUT "saleDoc") .
      ExpData1:route-data_copy-record ( input "saleDoc", buffer saleDoc:handle).
      IF ExpData1:esys-add-dump( INPUT "saleDoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи saleDoc &1:&2&3"
                                , buf_sale-doc.doc-code
                                , chr(10)
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
      if buf_sale-doc.in-inkas = yes then do:
        empty temp-table treal-2.
        empty temp-table treal-3.
        empty temp-table treal-4.
        empty temp-table temp_inkas-pay.
        run bge/bgepych2.p (
              input buf_inkas.inkas-code
            , input buf_sale-doc.ext-doc-type
            , input yes
            , input yes
            , input yes
            , input yes
            , input yes
        ).
        if buf_sale-doc.dir <> 0 then do:
          run get-inkas-pay-desk in this-procedure (
                  input buf_inkas.inkas-code
                , input buf_inkas.obj-type
                , input buf_inkas.obj-code
                , input (if buf_sale-doc.dir = 1
                        then 'при':U
                        else 'рас':U
                        )
            ) no-error .
          if error-status:error
          then do:
                        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("*** ERR: *** Не удалось рассчитать разбивку по кодам оплат по документу N &1", p-doc-code )).
          end.
        end.
        run export-chk-pay-code in this-procedure (
                                                   input buf_Sale-doc.doc-code
                                                  ,input buf_sale-doc.ext-doc-type
                                                  ,input buf_sale-doc.dir
                                              ).
        create buf_cassSum.
        for each temp_inkas-pay
        on error undo, return error
        :
          assign
          buf_cassSum.referenceNo = buf_sale-doc.doc-code
          buf_cassSum.code = temp_inkas-pay.pay-code
          buf_cassSum.currCode = temp_inkas-pay.curr-code
          buf_cassSum.sum = (if temp_inkas-pay.doc-type = 'при':U then 1 else -1)  * temp_inkas-pay.tot-sum
          buf_cassSum.sumb = (if temp_inkas-pay.doc-type = 'при':U then 1 else -1) * temp_inkas-pay.tot-base
          buf_cassSum.sumr = (if temp_inkas-pay.doc-type = 'при':U then 1 else -1) * temp_inkas-pay.tot-rubl
          .
          ExpData1:route-data_create-record( INPUT "cassSum") .
          ExpData1:route-data_copy-record ( input "cassSum", buffer buf_cassSum:handle).
          IF ExpData1:esys-add-dump( INPUT "cassSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи cassSum &1:&2&3"
                                    , buf_sale-doc.doc-code
                                    , chr(10)
                                    , v-last-error-message
                                    ).
            undo main-block, retry main-block.
          end.
        end.
        if available buf_cassSum then delete buf_cassSum.
      end.
    end.
    if available saleDoc then delete saleDoc.
    run export-checks in this-procedure (
                                          input buf_inkas.inkas-code
                                        , input buf_inkas.obj-type
                                        , input buf_inkas.obj-code
    ).
    if available buf_operation then delete buf_operation.
  end.
end.
end procedure.
procedure get-inkas-pay-desk :
  do
  on error undo, return error
  :
  define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
  define input parameter p-obj-type   like ub.inkas.obj-type no-undo .
  define input parameter p-obj-code   like ub.inkas.obj-code no-undo .
  define input parameter p-inkas-pay-desk-type like ub.inkas-pay-desk.doc-type no-undo .
    if can-find( first ub.inkas-pay-desk  NO-LOCK WHERE
                       ub.inkas-pay-desk.inkas-code = p-inkas-code ) then.
    else do:
      run trg/inkpdcr.p (
                     p-inkas-code
                    ,p-obj-type
                    ,p-obj-code
      ) no-error .
      if error-status:error then do:
        return error.
      end.
    end.
    for each temp_inkas-pay
    :
        delete temp_inkas-pay.
    end.
    for each ub.inkas-pay-desk no-lock
       where ub.inkas-pay-desk.inkas-code = p-inkas-code
         and ub.inkas-pay-desk.doc-type = p-inkas-pay-desk-type
    break
    by ub.inkas-pay-desk.pay-code
    by ub.inkas-pay-desk.curr-code
    on error undo, return error
    :
      if first-of( ub.inkas-pay-desk.curr-code )
      then do:
        create temp_inkas-pay.
        assign
        temp_inkas-pay.pay-code  = ub.inkas-pay-desk.pay-code
        temp_inkas-pay.curr-code  = ub.inkas-pay-desk.curr-code
        temp_inkas-pay.tot-base  = 0
        temp_inkas-pay.tot-rubl  = 0
        temp_inkas-pay.tot-sum   = 0
        .
      end.
      assign
      temp_inkas-pay.tot-base  = temp_inkas-pay.tot-base + ub.inkas-pay-desk.tot-base
      temp_inkas-pay.tot-rubl  = temp_inkas-pay.tot-rubl + ub.inkas-pay-desk.tot-rubl
      temp_inkas-pay.tot-sum   = temp_inkas-pay.tot-sum  + ub.inkas-pay-desk.tot-sum
      temp_inkas-pay.doc-type  = p-inkas-pay-desk-type
      .
    end.
  end.
end procedure.
procedure export-chk-pay-code :
define input parameter p-doc-code           as character        no-undo.
define input parameter p-ext-doc-type       as character        no-undo .
define input parameter p-is-out             as integer          no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_PayCode for paycode .
define buffer buf_paycard for paycard.
define buffer buf_goods for ub.goods.
main-block:
do
on error  undo main-block, retry main-block
on stop   undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    empty temp-table payCard.
    empty temp-table payCode.
  end.
  else do:
    empty temp-table payCard.
    empty temp-table payCode.
    for each treal-2 where
         treal-2.is-pay = yes,
    first buf_goods no-lock where buf_goods.gds-code = treal-2.gds-code
    break
    by treal-2.pay-desk
    by treal-2.cpay-code
    by treal-2.curr-code
    by treal-2.prefix
    on error undo, return error
    :
        if treal-2.prefix = '':U then do:
          create buf_PayCode.
          assign
          buf_PayCode.referenceNo = p-doc-code
          buf_PayCode.good = buf_goods.gds-code
          buf_PayCode.deskcode = treal-2.pay-desk
          buf_PayCode.paycode = treal-2.cpay-code
          buf_PayCode.quantity = p-is-out * treal-2.qnty1
          buf_PayCode.sumr = p-is-out * treal-2.netto
          .
          ExpData1:route-data_create-record( INPUT "payCode") .
          ExpData1:route-data_copy-record ( input "payCode", buffer buf_paycode:handle).
          IF ExpData1:esys-add-dump( INPUT "payCode", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи payCode &1:&2&3"
                                    , p-doc-code
                                    , chr(10)
                                    , v-last-error-message
                                    ).
            undo main-block, retry main-block.
          end.
        end.
        if treal-2.prefix <> '':U
        then do:
          create buf_payCard.
          assign
          buf_PayCard.good = buf_goods.gds-code
          buf_PayCard.referenceNo = p-doc-code
          buf_PayCard.deskcode = treal-2.pay-desk
          buf_PayCard.paycode = treal-2.cpay-code
          buf_PayCard.num = treal-2.prefix
          buf_PayCard.quantity = p-is-out * treal-2.qnty1
          buf_PayCard.sumr = p-is-out * treal-2.netto
          .
          ExpData1:route-data_create-record( INPUT "payCard") .
          ExpData1:route-data_copy-record ( input "payCard", buffer buf_paycard:handle).
          IF ExpData1:esys-add-dump( INPUT "payCard", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи payCard &1:&2&3"
                                    , p-doc-code
                                    , chr(10)
                                    , v-last-error-message
                                    ).
            undo main-block, retry main-block.
          end.
        end.
    end.
    for each treal-3 no-lock  where
        treal-3.is-pay = yes,
    first buf_goods no-lock where buf_goods.gds-code = treal-3.gds-code
    break
    by treal-3.pay-desk
    by treal-3.cpay-code
    by treal-3.curr-code
    by treal-3.prefix
    on error undo, return error
    :
      if treal-3.prefix = '':U then do:
        create buf_PayCode.
        assign
        buf_PayCode.referenceNo = p-doc-code
        buf_PayCode.good = buf_goods.gds-code
        buf_PayCode.deskcode = treal-3.pay-desk
        buf_PayCode.paycode = treal-3.cpay-code
        buf_PayCode.quantity = p-is-out * treal-3.qnty1
        buf_PayCode.sumr = p-is-out * treal-3.netto
        .
        ExpData1:route-data_create-record( INPUT "payCode") .
        ExpData1:route-data_copy-record ( input "payCode", buffer buf_paycode:handle).
        IF ExpData1:esys-add-dump( INPUT "payCode", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи payCode2 &1:&2&3"
                                  , p-doc-code
                                  , chr(10)
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
      end.
      if treal-3.prefix <> '':U then do:
        create buf_payCard.
        assign
        buf_PayCard.referenceNo = p-doc-code
        buf_PayCard.good = buf_goods.gds-code
        buf_PayCard.deskcode = treal-3.pay-desk
        buf_PayCard.paycode = treal-3.cpay-code
        buf_PayCard.num = treal-3.prefix
        buf_PayCard.quantity = p-is-out * treal-3.qnty1
        buf_PayCard.sumr = p-is-out * treal-3.netto
        .
        ExpData1:route-data_create-record( INPUT "payCard") .
        ExpData1:route-data_copy-record ( input "payCard", buffer buf_paycard:handle).
        IF ExpData1:esys-add-dump( INPUT "payCard", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи payCard &1:&2&3"
                                  , p-doc-code
                                  , chr(10)
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
      end.
    end.
    for each treal-4 no-lock where
           treal-4.is-pay = yes,
    first buf_goods no-lock where buf_goods.gds-code = treal-4.gds-code
    break
    by treal-4.pay-desk
    by treal-4.cpay-code
    by treal-4.curr-code
    by treal-4.prefix
    on error undo, return error
      :
      if treal-4.prefix = '':U then do:
        create buf_PayCode.
        assign
        buf_PayCode.referenceNo = p-doc-code
        buf_PayCode.good = buf_Goods.gds-code
        buf_PayCode.deskcode = treal-4.pay-desk
        buf_PayCode.paycode = treal-4.cpay-code
        buf_PayCode.quantity = p-is-out * treal-4.qnty1
        buf_PayCode.sumr = p-is-out * treal-4.netto
        .
        ExpData1:route-data_create-record( INPUT "payCode") .
        ExpData1:route-data_copy-record ( input "payCode", buffer buf_paycode:handle).
        IF ExpData1:esys-add-dump( INPUT "payCode", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи payCode &1:&2&3"
                                  , p-doc-code
                                  , chr(10)
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
      end.
      if treal-4.prefix <> '':U then do:
        create buf_payCard.
        assign
        buf_PayCard.referenceNo = p-doc-code
        buf_PayCard.good = buf_goods.gds-code
        buf_PayCard.deskcode = treal-4.pay-desk
        buf_PayCard.paycode = treal-4.cpay-code
        buf_PayCard.num = treal-4.prefix
        buf_PayCard.quantity = p-is-out * treal-4.qnty1
        buf_PayCard.sumr = p-is-out * treal-4.netto
        .
        ExpData1:route-data_create-record( INPUT "payCard") .
        ExpData1:route-data_copy-record ( input "payCard", buffer buf_paycard:handle).
        IF ExpData1:esys-add-dump( INPUT "payCard", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи payCard &1:&2&3"
                                  , p-doc-code
                                  , chr(10)
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
      end.
    end.
  end.
end.
end procedure.
procedure export-checks :
define input parameter p-doc-code       as character    no-undo.
define input parameter p-obj-type       as character    no-undo.
define input parameter p-obj-code       as integer      no-undo.
define variable v-write-off as logical no-undo .
define variable v-doc-bh as handle no-undo .
define variable v-gds-bh as handle no-undo .
define variable v-pay-bh as handle no-undo .
define variable v-discnt-bh as handle no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_chk-doc       for ub.chk-doc.
define buffer buf_chk-gds       for ub.chk-gds.
define buffer buf_chk-pay       for ub.chk-pay.
define buffer buf_bar-code      for ub.bar-code.
define buffer buf_goods         for ub.goods.
define buffer buf_c-chk-doc     for ub.c-chk-doc.
define buffer manu_c-chk-doc    for ub.c-chk-doc.
define buffer buf_chk-discnt    for ub.chk-discnt.
define buffer buf_dis-card      for ub.dis-card.
main-block:
do
for buf_chk-doc
  , buf_chk-gds
  , buf_chk-pay
  , buf_bar-code
  , buf_goods
  , buf_c-chk-doc
  , buf_chk-discnt
  , buf_dis-card
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  v-doc-bh = buffer buf_chk-doc:handle.
  v-gds-bh = buffer buf_chk-gds:handle.
  v-pay-bh = buffer buf_chk-pay:handle.
  for each buf_chk-doc no-lock
      where buf_chk-doc.out-code = p-doc-code
  :
    if buf_chk-doc.correct = no then next.
    if lookup(string(buf_chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next.
    find first buf_dis-card no-lock
          where buf_dis-card.d-card = buf_chk-doc.d-card
    no-error.
    if not available check1 then do:
      create check1.
    end.
    find first manu_c-chk-doc
          where manu_c-chk-doc.doc-code   = buf_chk-doc.doc-code
            and manu_c-chk-doc.obj-type   = buf_chk-doc.obj-type
            and manu_c-chk-doc.obj-code   = buf_chk-doc.obj-code
            and manu_c-chk-doc.is-add     = yes
    use-index pi
    no-error.
    find first buf_c-chk-doc
          where buf_c-chk-doc.doc-code   = buf_chk-doc.doc-code
            and buf_c-chk-doc.obj-type   = buf_chk-doc.obj-type
            and buf_c-chk-doc.obj-code   = buf_chk-doc.obj-code
            and buf_c-chk-doc.is-add     = no
            and buf_c-chk-doc.is-del     = no
    use-index pi
    no-error.
    assign
    v-write-off = no
    .
    if buf_chk-doc.sub-discnt <> 0 then do:
      if buf_chk-doc.chk-type = integer('96':U) then do:
        assign
            v-write-off = yes
        .
      end.
      else do:
        _for:
        for each buf_chk-gds no-lock where
                buf_chk-gds.doc-code = buf_chk-doc.doc-code :
          if buf_Chk-gds.write-off-code <> ?
          and buf_Chk-gds.write-off-code <> 0 then do:
            assign
            v-write-off = yes.
            leave _for.
          end.
        end.
      end.
    end.
    assign
    check1.referenceNo  = p-doc-code
    check1.doccode      = buf_chk-doc.doc-code
    check1.type         = buf_chk-doc.office
    check1.num          = buf_chk-doc.chk-num
    check1.desk         = buf_chk-doc.pay-desk
    check1.dateXML      = buf_chk-doc.chk-date
    check1.chk-time     = string(buf_chk-doc.chk-time, "HH:MM:SS")
    check1.shiftDateXML = buf_chk-doc.shift-date
    check1.shiftNum     = buf_chk-doc.shift-num
    check1.dCard        = buf_chk-doc.d-card
    check1.dCardCliType = buf_chk-doc.cli-type
    check1.dCardCliCode = buf_chk-doc.cli-code
    check1.discnt       = buf_chk-doc.discnt
    check1.cashier      = buf_chk-doc.cashier
    check1.cashierPsnCode = buf_chk-doc.cashier-psn-code
    check1.salesman       = buf_chk-doc.sales-man
    check1.zNumber        = buf_chk-doc.z-number
    check1.manualMaked    = (if available manu_c-chk-doc then yes else no)
    check1.manualChanged  = (if available buf_c-chk-doc then yes else no)
    check1.subDiscnt      = (if v-write-off then buf_chk-doc.sub-discnt else 0)
    check1.totdoc         = buf_chk-doc.tot-doc
    .
    ExpData1:route-data_create-record( INPUT "check1") .
    ExpData1:route-data_copy-record ( input "check1", input buffer check1:handle).
    IF ExpData1:esys-add-dump( INPUT "check1", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи check для продажи &1:&2&3"
                              , p-doc-code
                              , chr(10)
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
    for each buf_chk-gds no-lock
        where buf_chk-gds.doc-code = buf_chk-doc.doc-code
    :
      find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_chk-gds.b-code no-error.
      if not available checkGds then do:
        create checkGds.
      end.
      assign
      checkGds.doccode = buf_chk-doc.doc-code
      checkGds.gdsCode = (if available buf_bar-code then buf_bar-code.gds-code else 0)
      checkGds.qnty    = buf_chk-gds.doc-qnty
      checkGds.priceBase = buf_chk-gds.price-base
      checkGds.priceDiscnt = buf_chk-gds.discnt
      checkGds.lineNum  = buf_chk-gds.line-num
      checkGds.pump  = buf_chk-gds.pump
      checkGds.roadTax  = buf_chk-gds.road-tax
      checkGds.srcCode  = entry(1, buf_chk-gds.src-code, chr(4) )
      checkGds.srcQnty  = buf_chk-gds.src-qnty
      checkGds.srcprice = buf_chk-gds.src-price
      .
      ExpData1:route-data_create-record( INPUT "checkGds") .
      ExpData1:route-data_copy-record ( "checkGds", input buffer checkgds:handle).
      IF ExpData1:esys-add-dump( INPUT "checkGds", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи checkGds для продажи &1:&2&3"
                                , p-doc-code
                                , chr(10)
                                , v-last-error-message
                                ).
        undo main-block, return error v-err-mess.
      end.
    end.
    for each buf_chk-pay no-lock
        where buf_chk-pay.doc-code = buf_chk-doc.doc-code
    :
      if not available checkPay then do:
        create checkPay.
      end.
      assign
      checkPay.doccode = buf_chk-doc.doc-code
      checkPay.payCode = buf_chk-pay.pay-code
      checkPay.payCard = buf_chk-pay.pay-card
      checkPay.currCode = buf_chk-pay.curr-code
      checkPay.sumBase = buf_chk-pay.tot-base
      checkPay.sumrubl = buf_chk-pay.tot-rubl
      checkPay.sumtot = buf_chk-pay.tot-sum
      checkPay.lineNum = buf_chk-pay.line-num
      .
      ExpData1:route-data_create-record( INPUT "checkPay") .
      ExpData1:route-data_copy-record ( input "checkPay", input buffer checkpay:handle).
      IF ExpData1:esys-add-dump( INPUT "checkPay", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи checkPay для продажи &1:&2&3"
                                , p-doc-code
                                , chr(10)
                                , v-last-error-message
                                ).
        undo main-block, return error v-err-mess.
      end.
    end.
    define variable v-ii as integer no-undo .
    do v-ii = 0 to 2 by 2:
      for each buf_chk-discnt no-lock
        where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
          and buf_chk-discnt.record-type = v-ii
      :
        if not available checkDiscount then do:
          create checkDiscount.
        end.
        assign
        checkDiscount.doccode = buf_chk-discnt.doc-code
        checkDiscount.linenum = buf_chk-discnt.line-num
        checkDiscount.discntvCode = buf_chk-discnt.value-type
        checkDiscount.objectlinenum = buf_chk-discnt.object-line-num
        checkDiscount.discntTargetCode = buf_chk-discnt.line-type
        checkDiscount.discntTypeCode = buf_chk-discnt.discnt-type
        checkDiscount.discntValueAbs = buf_chk-discnt.discnt-value-abs
        checkDiscount.discntValuePcnt = buf_chk-discnt.discnt-value-pcnt
        checkDiscount.srcDCard = buf_chk-discnt.src-d-card
        checkDiscount.discntKategory = ( if buf_chk-discnt.src-d-card <> ''
                                          and buf_chk-discnt.src-d-card <> ?
                                          and available buf_dis-card
                                          and buf_dis-card.d-card = buf_chk-discnt.src-d-card
                                          and buf_chk-discnt.kateg = ?
                                          then buf_dis-card.category
                                          else buf_chk-discnt.kateg )
        .
        ExpData1:route-data_create-record( INPUT "checkDiscount") .
        ExpData1:route-data_copy-record ( input "checkDiscount", input buffer checkdiscount:handle).
              IF ExpData1:esys-add-dump( INPUT "checkDiscount", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи checDiscount для продажи &1:&2&3"
                                  , p-doc-code
                                  , chr(10)
                                  , v-last-error-message
                                  ).
          undo main-block, return error v-err-mess.
        end.
      end.
    end.
  end.
end.
end procedure.
