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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 1,14,100,115".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info13, return-value, chr(10), error-status :get-message (1))
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
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info13, return-value, chr(10), error-status :get-message (1))
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-error :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
     assign
     v-last-error-message = p-mess.
  end.
end procedure.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При маршрутизации произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action22   as character no-undo .
  define variable v-printed22       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При маршрутизации произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + log-file-name)
    ,input  7
    ,output v-user-action22
    ,output v-printed22
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
on stop undo, return error substitute( "&1&2&3&2&4", return-value, chr(10), error-status :get-message (1), v-last-error-message)
:
define variable v-doc-code as character no-undo .
define variable v-trn-doc-obj-type as character no-undo .
define variable v-trn-doc-obj-code as integer no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-obj-uniq-key-rec as character no-undo .
define variable v-doc-list-doc-type as character no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
_stroka:
do while true
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  v-esys-id-list = ''.
  v-trn-doc-obj-type = ''.
  v-trn-doc-obj-code = 0.
  if available buf_trn-doc then release buf_trn-doc.
  if available buf_c-trn-doc then release buf_c-trn-doc.
  if available buf_ord-doc then release buf_ord-doc.
  case p-ruleset-id:
    when 2
    or when 14
    then do:
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
        if p-ruleset-id = 2
        and v-doc-list-doc-type <> 'ОП':U then do:
          next _stroka.
        end.
        if p-ruleset-id = 14
        and not
         (lookup(v-doc-list-doc-type,  'при,рас,спи,возврат,инв':U) > 0
          or
             (v-doc-list-doc-type begins "-"
             and
             lookup(entry(2, "-", v-doc-list-doc-type),  'при,рас,спи,возврат,инв':U) > 0
             )
        )
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
    when 100
    or
    when 115
    then do:
      if v-has-newbh then do:
        v-trn-doc-obj-type = v-newbh::obj-type.
        v-trn-doc-obj-code = v-newbh::obj-code.
        v-doc-code = v-newbh:buffer-field("doc-code"):buffer-value.
      end.
      else do:
        v-trn-doc-obj-type = v-oldbh::obj-type.
        v-trn-doc-obj-code = v-oldbh::obj-code.
        v-doc-code = v-oldbh:buffer-field("doc-code"):buffer-value.
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
    when 100
    or when 115 then do:
      if v-esys-id-list = '' then leave _stroka.
    end.
    when 2
    or when 14 then do:
      if v-esys-id-list = '' then next _stroka.
    end.
  end case.
  if p-save >= 0 then do:
    case p-ruleset-id:
      when 115 then do:
        find first buf_trn-doc exclusive-lock where
                  buf_trn-doc.doc-code = v-doc-code
                no-error.
      end.
      when 14 then do:
        if v-doc-list-doc-type begins "-" then do:
          find first buf_c-trn-doc exclusive-lock where
                    buf_c-trn-doc.doc-code = v-doc-code
                and buf_c-trn-doc.is-del = yes
                  no-error.
          v-action = 'D':U.
        end.
        else do:
          find first buf_trn-doc exclusive-lock where
                    buf_trn-doc.doc-code = v-doc-code
                  no-error.
           v-action = 'U':U.
        end.
      end.
      when 100
      or
      when 2
      then do:
        find first buf_ord-doc exclusive-lock where
                  buf_ord-doc.doc-code = v-doc-code
                no-error.
      end.
    end case.
  end.
  else do:
    case p-ruleset-id:
      when 115 then do:
        find first buf_trn-doc no-lock where
                  buf_trn-doc.doc-code = v-doc-code
                no-error.
      end.
      when 14 then do:
        if v-doc-list-doc-type begins "-" then do:
          find first buf_c-trn-doc no-lock where
                    buf_c-trn-doc.doc-code = v-doc-code
                and buf_c-trn-doc.is-del = yes
                  no-error.
          v-action = 'D':U.
        end.
        else do:
          find first buf_trn-doc no-lock where
                    buf_trn-doc.doc-code = v-doc-code
                  no-error.
           v-action = 'U':U.
        end.
      end.
      when 100
      or when 2
      then do:
        find first buf_ord-doc no-lock where
                  buf_ord-doc.doc-code = v-doc-code
                no-error.
      end.
    end case.
  end.
  case p-ruleset-id:
    when 2 then do:
      if not (buf_ord-doc.status_ = 'факт':U) then next _stroka.
    end.
    when 14 then do:
      if v-doc-list-doc-type begins "-" then do:
        if not (buf_c-trn-doc.status_ = 'факт':U
        and buf_c-trn-doc.flag_ = yes) then next _stroka.
      end.
      else do:
        if not (buf_trn-doc.status_ = 'факт':U
        and buf_trn-doc.flag_ = yes) then next _stroka.
      end.
    end.
  end case.
  num-rec = num-rec + 1.
  IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  IF  context_begin-esys-command( input v-esys-id-list
                                , input-output v-esys-cmd-proc-handle
                                , output v-esys-cmd-code) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  case p-ruleset-id:
    when 115
    or when 14
    then do:
      run edocstrn_export in this-procedure ( buffer buf_trn-doc
                                             ,buffer buf_c-trn-doc
                                            ) no-error.
    end.
    when 100
    or
    when 2
    then do:
      run edocsord_export in this-procedure ( buffer buf_ord-doc
                                            ) no-error.
    end.
  end case.
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
  if p-ruleset-id = 100
  or p-ruleset-id = 115 then do:
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
if p-ruleset-id = 10
or p-ruleset-id = 14 then do:
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
on stop undo, return error
:
  case p-ruleset-id:
    when 2
    or when 14
    then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run calltree in g#library
  (input  'cb_get-next-doc-by-doc-code'
  ,input  this-procedure:handle
  ,input  p-cont-handle
  ,output v-doc-list-handle
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    when 100
    or when 115 then do:
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
          run statq_has-waiting-stat in this-procedure (
                                                          input v-oldbh
                                                        ,input v-newbh
                                                        ,input v-changes-list
                                                        ,input 'факт':U
                                                        ,input yes
                                                        ,input 0
                                                        ,output v-is-waiting-status
                                                        ,output v-direction
                                                        ) no-error.
        end.
        when 100 then do:
          if v-has-newbh
          and v-newbh:table <> 'ord-doc':U then do:
            undo, return error substitute("Передан неверный буфер вместо буфера для &1",  'ord-doc':U).
          end.
          if v-has-newbh
          and v-newbh::doc-type <> 'ОП':U then return "return".
          if not v-has-newbh
          and v-has-oldbh
          and v-oldbh::doc-type <> 'ОП':U then return "return".
          run statq_has-waiting-stat in this-procedure (
                                                          input v-oldbh
                                                        ,input v-newbh
                                                        ,input v-changes-list
                                                        ,input 'поставка':U
                                                        ,input yes
                                                        ,input 0
                                                        ,output v-is-waiting-status
                                                        ,output v-direction
                                                        ) no-error.
        end.
      end case.
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
field valutCode  as integer
field valutCodeOKV as integer
field exchCode as integer
field exchRate as decimal
field exchScale as integer
field firm as character
field extNumber as character
field OutNumber as character
field outDateXml as date
field paymentCode as integer
field InterFirmDocChild as character
field InterFirmDocParent as character
field InterFirmObjType as character
field InterFirmObjCode as integer
field authority as character
field suppInDocDateXml as date
field suppInDocNo as character
field contractSuppCode as character
field contractSuppNo as character
field contractSuppDateXml as date
field contractDateXml as date
field contractNo as character
field sfNo as character
field sfDateXml as date
field doverNo as character
field doverDateXml as date
field reasonCode as integer
field outCode as character
field comment as character
field ordDocCode as character
field ordOutDocCode as character
field shiftDateXml as date
field shiftNum as integer
field shiftName as character
field dCard as character
field techfuel as logical
field office as logical
field docQnty as decimal column-label "Кол-во по док-ту"
field factQnty as decimal column-label "Кол-во факт."
field cliQnty as decimal column-label "Кол-во в ед пост - соттвет doc-qnty."
field totalSum as decimal column-label "Сумма по док-ту"
field totalDsc as decimal column-label "Скидка по док-ту"
field totalFact as decimal column-label 'Сумма факт'
field totalDscFact as decimal column-label 'Скидка факт'
field totalPayFact as decimal column-label "К оплате факт"
field baserate as decimal column-label "Курс баз.вал"
field vatType as character
index pi is unique primary
referenceNo
.
define temp-table dtl no-undo
field referenceNo as character
field good as integer
field prtCode as integer
field dtlName as character
field qnty as decimal
field sumr as decimal
field VATr as decimal
field roadTaxr as decimal
field sumb as decimal
field VATb as decimal
field roadTaxb as decimal
index pi is unique primary
referenceNo
good
prtcode
.
define temp-table beforeSum no-undo
field referenceNo as character
field qnty as decimal
index pi is unique primary
referenceNo
.
define temp-table afterSum no-undo
field referenceNo as character
field qnty as decimal
index pi is unique primary
referenceNo
.
define temp-table beforeSumLine no-undo
field referenceNo as character
field good as integer
field qnty as decimal
field petrolweight as decimal
index pi is unique primary
referenceNo
.
define temp-table afterSumLine no-undo
field referenceNo as character
field good as integer
field qnty as decimal
field petrolweight as decimal
index pi is unique primary
referenceNo
.
define temp-table saleSumBeforeSum
field referenceNo as character
field sumr as decimal
field VATr as decimal
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
.
define temp-table saleSumAfterSum
field referenceNo as character
field sumr as decimal
field VATr as decimal
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
.
define temp-table costSumBeforeSum
field referenceNo as character
field sumr as decimal
field VATr as decimal
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
.
define temp-table costSumAfterSum
field referenceNo as character
field sumr as decimal
field VATr as decimal
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
.
define temp-table saleSumBeforeSumLine
field referenceNo as character
field good as integer
field sumr as decimal
field VATr as decimal
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
good
.
define temp-table saleSumAfterSumLine
field referenceNo as character
field good as integer
field sumr as decimal
field VATr as decimal
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
good
.
define temp-table costSumBeforeSumLine
field referenceNo as character
field good as integer
field sumr as decimal
field VATr as decimal
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
good
.
define temp-table costSumAfterSumLine
field referenceNo as character
field good as integer
field sumr as decimal
field VATr as decimal
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
index pi is unique primary
referenceNo
good
.
define temp-table linedoc no-undo
field referenceNo as character
field good as integer
field artic as character
field prodType as character
field prodCode as integer
field type as character
field unitType as character
field wait as decimal
field place as decimal
field priceCli as decimal
field cliBaseRate as decimal
field quantity as decimal
field vatPC as decimal
field petrolWeight as decimal
field petrolDensity as decimal
field petrolInvFactStk as decimal
field petrolBeforeQnty as decimal
field petrolAfterQnty as decimal
field petrolDiffQnty as decimal
field petrolAbsDiffQnty as decimal
field CSTCode as character
field cashParts as logical
index pi is unique primary
referenceNo
good
.
define temp-table part no-undo
field referenceNo as character
field good as integer
field doc_ID as character
field partCode as character
field qnty as decimal
field cst as character
field supp as character
field hostCode as integer
field contractCode as character
field sumr as decimal
field VATr as decimal
field roadTaxr as decimal
field transportr as decimal
field otherr as decimal
field exciser as decimal
field sumb as decimal
field VATb as decimal
field roadTaxb as decimal
field transportb as decimal
field otherb as decimal
field exciseb as decimal
field contractSuppCode as character
field contractSuppNo as character
field contractSuppDateXml as date
field countryCode as character
field priceCli as decimal
field cliBaseRate as decimal
field vatType as character
field exchCode as integer
field attrExchRate as decimal
field attrExchScale as integer
field attrUnitCli as character
field lastDate as date
field priceb as decimal
field pricer as decimal
field prodPrice as decimal
field fib as integer
field salePrice as decimal
field purch-code as integer
index pi is unique primary
referenceNo
good
doc_ID
partCode
.
define dataset waybill-01
xml-node-name "waybill-01"
for operation, beforeSum, salesumbeforesum, costsumbeforesum,
afterSum, salesumaftersum, costsumaftersum,
linedoc,
beforeSumLine, salesumbeforesumLine, costsumbeforesumLine,
afterSumLine, salesumaftersumLine, costsumaftersumLine,
dtl, part
data-relation operation-beforesum for operation, beforesum relation-fields (referenceNo, referenceNo) nested
data-relation beforesum-salesumbeforesum for beforesum, salesumbeforesum relation-fields (referenceNo, referenceNo) nested
data-relation beforesum-costsumbeforesum for beforesum, costsumbeforesum relation-fields (referenceNo, referenceNo) nested
data-relation operation-aftersum for operation, aftersum relation-fields (referenceNo, referenceNo) nested
data-relation aftersum-salesumaftersum for aftersum, salesumaftersum relation-fields (referenceNo, referenceNo) nested
data-relation aftersum-costsumaftersum for aftersum, costsumaftersum relation-fields (referenceNo, referenceNo) nested
data-relation operation-linedoc for operation, linedoc relation-fields (referenceNo, referenceNo) nested
data-relation linedoc-dtl for linedoc, dtl relation-fields (referenceNo, referenceNo, good, good) nested
data-relation linedoc-part for linedoc, part relation-fields (referenceNo, referenceNo, good, good) nested
data-relation linedoc-beforesumLine for linedoc, beforesumLine relation-fields (referenceNo, referenceNo, good, good) nested
data-relation beforesum-salesumbeforesumLine for beforesumLine, salesumbeforesumLine relation-fields (referenceNo, referenceNo, good, good ) nested
data-relation beforesum-costsumbeforesumLine for beforesumLine, costsumbeforesumLine relation-fields (referenceNo, referenceNo, good, good) nested
data-relation linedoc-aftersumLine for linedoc, aftersumLine relation-fields (referenceNo, referenceNo, good, good) nested
data-relation aftersum-salesumaftersumLine for aftersumLine, salesumaftersumLine relation-fields (referenceNo, referenceNo, good, good) nested
data-relation aftersum-costsumaftersumLine for aftersumLine, costsumaftersumLine relation-fields (referenceNo, referenceNo, good, good) nested
.
procedure edocstrn_export :
define parameter buffer buf_trn-doc for ub.trn-doc.
define parameter buffer buf_c-trn-doc for ub.c-trn-doc.
define buffer buf_doc-line for ub.doc-line.
define variable v-bh as handle no-undo .
define variable v-bh-line as handle no-undo .
define variable v-err-mess as character no-undo .
define variable glog as logical no-undo .
define variable v-attr-type as character no-undo .
define variable v-is-out as integer no-undo .
define variable v-inkas-pay-desk-type  as character no-undo .
define variable v-scale-is-empty as logical no-undo .
define variable v-is-petrol                 as logical      no-undo.
define variable v-is-pieces                 as logical      no-undo.
define variable v-petrol-weight             as decimal      no-undo.
define variable v-petrol-density            as decimal      no-undo.
define variable v-weight-not-specified      as logical      no-undo.
define variable v-date-valid as logical no-undo .
define variable v-error-message as character no-undo .
define variable v-linedoc-hidden as logical no-undo .
define variable v-dtl-hidden as logical no-undo .
define variable v-part-hidden as logical no-undo .
define variable v-date-char as character no-undo .
define variable v-prodPricewithvat as character no-undo .
define variable v-prodvat as decimal   no-undo .
define buffer buf_operation for operation.
define buffer buf_part for part.
define buffer buf_currency for ub.currency.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer buf_ord-chain   for ub.ord-chain.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_contract for ub.contract.
define buffer buf_inkas for ub.inkas.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_parts         for ub.parts.
define buffer buf_parts-attr    for ub.parts-attr.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
:
  EMPTY TEMP-TABLE operation.
  empty TEMP-TABLE linedoc.
  empty temp-table part.
  if retry then do:
    EMPTY TEMP-TABLE operation.
    empty TEMP-TABLE linedoc.
    empty temp-table part.
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input v-err-mess).
    return error ''.
  end.
  else do:
    v-bh = buffer buf_trn-doc:handle.
    v-bh-line = buffer buf_doc-line:handle.
    if v-action = 'D':U
    and not available buf_c-trn-doc
    then do:
      find first buf_c-trn-doc no-lock where
                buf_c-trn-doc.doc-code = buf_trn-doc.doc-code
            and buf_c-trn-doc.is-del = yes no-error.
    end.
    if available buf_trn-doc then do:
      create buf_operation.
      assign
      buf_operation.referenceNo = buf_trn-doc.doc-code
      buf_operation.isDel = (v-action = 'D':U)
      buf_operation.dateDelXml = (if v-action = 'D':U
                                  then (if available buf_c-trn-doc
                                        then buf_c-trn-doc.corr-date
                                        else ?)
                                  else ?)
      buf_operation.codeOperation = buf_trn-doc.ext-doc-type
      buf_operation.host = buf_trn-doc.host-code
      buf_operation.factOrder = buf_trn-doc.fact-order
      buf_operation.sysDateXML = buf_trn-doc.sys-date
      buf_operation.dateDocXML = buf_trn-doc.doc-date
      buf_operation.dateFactXML = buf_trn-doc.fact-date
      buf_operation.shiftDateXML = buf_trn-doc.shift-date
      buf_operation.shiftNum = buf_trn-doc.shift-num
      buf_operation.shiftName = buf_trn-doc.shift-name
      buf_operation.extNumber = buf_trn-doc.ord-num
      buf_operation.outNumber = buf_trn-doc.ship-num
      buf_operation.outDateXML = buf_trn-doc.ship-date
      buf_operation.paymentCode = buf_trn-doc.pay-code
      buf_operation.InterFirmDocChild = buf_trn-doc.hold-doc-code-child
      buf_operation.InterFirmDocParent = buf_trn-doc.hold-doc-code-parent
      buf_operation.InterFirmObjType = buf_trn-doc.hold-obj-type
      buf_operation.InterFirmObjCode = buf_trn-doc.hold-obj-code
      buf_operation.reasonCode = buf_trn-doc.reason-code
      buf_operation.outCode = buf_trn-doc.out-code
      buf_operation.comment = buf_trn-doc.PS
      buf_operation.store = buf_trn-doc.obj-type + string(buf_trn-doc.obj-code)
      buf_operation.systime = string(buf_trn-doc.sys-time-int, "HH:MM:SS")
      buf_operation.firm = buf_trn-doc.cli-type + string(buf_trn-doc.cli-code)
      buf_operation.outDateXML = buf_trn-doc.ship-date
      buf_operation.exchCode =  buf_trn-doc.exch-code
      buf_operation.exchRate =  buf_trn-doc.exch-rate
      buf_operation.exchscale  = buf_trn-doc.exch-scale
      buf_operation.dCard = buf_trn-doc.d-card
      buf_operation.office = buf_trn-doc.office
      buf_operation.docQnty = buf_trn-doc.doc-qnty
      buf_operation.factQnty = buf_trn-doc.fact-qnty
      buf_operation.totalSum = ( if buf_trn-doc.print-rubl = yes
                                then buf_trn-doc.tot-rubl
                                else buf_trn-doc.tot-doc )
      buf_operation.totalDsc = ( if buf_trn-doc.print-rubl = yes
                                then buf_trn-doc.discnt-rubl
                                else buf_trn-doc.tot-doc - buf_trn-doc.tot-cli )
      buf_operation.totalFact = (if buf_trn-doc.print-rubl
                                then buf_trn-doc.tot-sale
                                else buf_trn-doc.tot-fact)
      buf_operation.totalDscFact = ( if buf_trn-doc.print-rubl = yes
                                      then buf_trn-doc.discnt-rubl
                                      else buf_trn-doc.tot-calc )
      buf_operation.vatType = buf_trn-doc.vat-Type
      .
    end.
    else do:
      create buf_operation.
      assign
      buf_operation.referenceNo = buf_c-trn-doc.doc-code
      buf_operation.isDel = (v-action = 'D':U)
      buf_operation.dateDelXml = (if v-action = 'D':U
                                  then (if available buf_c-trn-doc
                                        then buf_c-trn-doc.corr-date
                                        else ?)
                                  else ?)
      buf_operation.codeOperation = buf_c-trn-doc.ext-doc-type
      buf_operation.host = buf_c-trn-doc.host-code
      buf_operation.factOrder = buf_c-trn-doc.fact-order
      buf_operation.sysDateXML = buf_c-trn-doc.sys-date
      buf_operation.dateDocXML = buf_c-trn-doc.doc-date
      buf_operation.dateFactXML = buf_c-trn-doc.fact-date
      buf_operation.shiftDateXML = buf_c-trn-doc.shift-date
      buf_operation.shiftNum = buf_c-trn-doc.shift-num
      buf_operation.shiftName = buf_c-trn-doc.shift-name
      buf_operation.extNumber = buf_c-trn-doc.ord-num
      buf_operation.outNumber = buf_c-trn-doc.ship-num
      buf_operation.outDateXML = buf_c-trn-doc.ship-date
      buf_operation.paymentCode = buf_c-trn-doc.pay-code
      buf_operation.InterFirmDocChild = buf_c-trn-doc.hold-doc-code-child
      buf_operation.InterFirmDocParent = buf_c-trn-doc.hold-doc-code-parent
      buf_operation.InterFirmObjType = buf_c-trn-doc.hold-obj-type
      buf_operation.InterFirmObjCode = buf_c-trn-doc.hold-obj-code
      buf_operation.reasonCode = buf_c-trn-doc.reason-code
      buf_operation.outCode = buf_c-trn-doc.out-code
      buf_operation.comment = buf_c-trn-doc.PS
      buf_operation.store = buf_c-trn-doc.obj-type + string(buf_c-trn-doc.obj-code)
      buf_operation.systime = string(buf_c-trn-doc.sys-time-int, "HH:MM:SS")
      buf_operation.firm = buf_c-trn-doc.cli-type + string(buf_c-trn-doc.cli-code)
      buf_operation.outDateXML = buf_c-trn-doc.ship-date
      buf_operation.exchCode =  buf_c-trn-doc.exch-code
      buf_operation.exchRate =  buf_c-trn-doc.exch-rate
      buf_operation.exchscale  = buf_c-trn-doc.exch-scale
      buf_operation.dCard = buf_c-trn-doc.d-card
      buf_operation.office = buf_c-trn-doc.office
      buf_operation.docQnty = buf_c-trn-doc.doc-qnty
      buf_operation.factQnty = buf_c-trn-doc.fact-qnty
      buf_operation.totalSum = ( if buf_c-trn-doc.print-rubl = yes
                                then buf_c-trn-doc.tot-rubl
                                else buf_c-trn-doc.tot-doc )
      buf_operation.totalDsc = ( if buf_c-trn-doc.print-rubl = yes
                                then buf_c-trn-doc.discnt-rubl
                                else buf_c-trn-doc.tot-doc - buf_c-trn-doc.tot-cli )
      buf_operation.totalFact = (if buf_c-trn-doc.print-rubl
                                then buf_c-trn-doc.tot-sale
                                else buf_c-trn-doc.tot-fact)
      buf_operation.totalDscFact = ( if buf_c-trn-doc.print-rubl = yes
                                      then buf_c-trn-doc.discnt-rubl
                                      else buf_c-trn-doc.tot-calc )
      buf_operation.vatType = buf_c-trn-doc.vat-Type
      .
    end.
    if v-action = 'D':U then do:
      ExpData1:route-data_create-record( INPUT "operation") .
      ExpData1:route-data_copy-record ( input "operation", buffer buf_operation:handle).
      IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи operation &1:&2&3"
                                , buf_trn-doc.doc-code
                                , chr(10)
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
      return.
    end.
    if buf_trn-doc.doc-type = 'инв':U then do:
       buf_operation.totalPayFact = ?.
    end.
    if (buf_trn-doc.ext-doc-type = 'es':U
    or buf_trn-doc.ext-doc-type = 'rs':U)
    then do:
      buf_operation.totalPayFact = ?.
    end.
    if buf_trn-doc.doc-type = 'при':U and
      buf_trn-doc.internal = no        then do:
      buf_operation.totalPayFact = buf_trn-doc.tot-calc.
    end.
    else do:
      buf_operation.totalPayFact = (if buf_trn-doc.print-rubl
                                    then (buf_trn-doc.tot-sale - buf_trn-doc.discnt-rubl)
                                    else (buf_trn-doc.tot-fact - buf_trn-doc.tot-calc)
                                    ).
    end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  buf_trn-doc.host-code
  ,output buf_operation.valutCode
  )  .
    find first buf_currency no-lock where
              buf_currency.curr-code = buf_operation.valutCode.
    buf_operation.valutCodeOKV = buf_currency.okv-code.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'dov':U ,
                       output buf_operation.authority ,
                       output v-attr-type )  .
    v-date-char = ''.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'dids':U ,
                       output v-date-char ,
                       output v-attr-type )  .
    v-date-valid = no.
    run strtdate in this-procedure ( input  v-date-char
                                 , output buf_operation.suppInDocDateXml
                                 , output v-date-valid
                                 , output v-error-message
                                 ) no-error.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'nids':U ,
                       output buf_operation.suppInDocNo ,
                       output v-attr-type )  .
    if buf_trn-doc.ext-doc-type = 'ie':U
    or buf_trn-doc.ext-doc-type = 'ap':U
    then  do:
      if buf_trn-doc.contract-code <> 0
      then do:
        assign
        buf_operation.contractSuppCode = string( buf_trn-doc.contract-code )
        .
        find first buf_contract no-lock
              where buf_contract.host-code       = buf_trn-doc.host-code
                and buf_contract.contract-code   = buf_trn-doc.contract-code
        no-error.
        if available buf_contract
        then do:
          assign
          buf_operation.contractSuppNo          =  buf_contract.contract-prn-code
          buf_operation.contractSuppDateXml          = buf_contract.contract-date
          .
        end.
      end.
    end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'ddog':U ,
                       output v-date-char ,
                       output v-attr-type ) no-error .
    if error-status :error
    then do:
              run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute( "*** ERR: *** Ошибка чтения атрибута даты договора для приходной накладной N &1 ", buf_trn-doc.doc-code )).
    end.
    v-date-valid = no.
    v-date-char = ''.
    run strtdate in this-procedure ( input v-date-char
                                 , output buf_operation.contractDateXml
                                 , output v-date-valid
                                 , output v-error-message
                                 ) no-error.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'ndog':U ,
                       output buf_operation.contractNo ,
                       output v-attr-type ) no-error .
    if error-status :error
    then do:
          end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'nsf':U ,
                       output buf_operation.sfNo ,
                       output v-attr-type )  .
    v-date-char = ''.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'dsf':U ,
                       output v-date-char ,
                       output v-attr-type )  .
    v-date-valid = no.
    run strtdate in this-procedure ( input v-date-char
                                 , output buf_operation.sfDateXml
                                 , output v-date-valid
                                 , output v-error-message
                                 ) no-error.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'ndov':U ,
                       output buf_operation.doverNo ,
                       output v-attr-type ) no-error .
    v-date-char = ''.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'ddov':U ,
                       output v-date-char ,
                       output v-attr-type ) no-error .
    v-date-valid = no.
    run strtdate in this-procedure ( input v-date-char
                                 , output buf_operation.doverDateXml
                                 , output v-date-valid
                                 , output v-error-message
                                 ) no-error.
    find first buf_ord-chain no-lock
      where buf_ord-chain.rel-doc-code =  buf_trn-doc.doc-code
        and buf_ord-chain.rel-doc-type = 'trn':u
    no-error .
    if available buf_ord-chain
    then do:
      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code
      no-error .
      if available buf_ord-doc-rcv
      then do:
        assign
        buf_operation.ordDocCode = buf_ord-doc-rcv.doc-code
        buf_operation.ordOutDocCode = buf_ord-doc-rcv.cons-code
        .
      end.
    end.
    def var v-value as character no-undo.
    def var v-type  as character no-undo.
    def var v-tech-pass as logical no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'techpass':U ,
                       output v-value ,
                       output v-type ) no-error .
    assign
      v-tech-pass = yes when v-value = "yes".
    if buf_trn-doc.ext-doc-type = 'we':U and
    (v-tech-pass or can-find(first ub.sale-doc where ub.sale-doc.doc-code = p-doc-code and ub.sale-doc.doc-kind = 'trf':U))
    then do:
      buf_operation.techfuel = yes.
    end.
    ExpData1:route-data_create-record( INPUT "operation") .
    ExpData1:route-data_copy-record ( input "operation", buffer buf_operation:handle).
    IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи operation &1:&2&3"
                              , buf_trn-doc.doc-code
                              , chr(10)
                              , v-last-error-message
                              ).
      undo main-block, retry main-block.
    end.
    if buf_trn-doc.ext-doc-type = 'vt':U
    or buf_trn-doc.ext-doc-type = 'vp':U
    or buf_trn-doc.ext-doc-type = 'ap':U
    or buf_trn-doc.ext-doc-type = 'mp':U
    then do:
        run utl/cuaddsum.p (
            input buf_trn-doc.doc-code
        ) no-error.
        if error-status :error
        then do:
          run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute( "*** WARN: *** Не удалось проверить документ инвентаризации N: &1. &2. &3. &4"                                     , buf_trn-doc.doc-code                                     , return-value                                     , trim(error-status :get-message(1))                                     , trim(error-status :get-message(2))                                 )).
        end.
        define variable v-exists-before as logical no-undo .
        define variable v-exists-after as logical no-undo .
        run export-before-and-after-inv-trn in this-procedure (
              input buf_trn-doc.doc-code
            , output v-exists-before
            , output v-exists-after
        ).
    end.
    for each buf_doc-line no-lock where
            buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error  undo main-block, retry  main-block
    on stop   undo main-block, retry  main-block
    on endkey undo main-block, retry  main-block
    :
      v-scale-is-empty = no.
      find first buf_goods no-lock where
              buf_goods.artic = buf_doc-line.artic
          and buf_goods.prod-type = buf_doc-line.prod-type
          and buf_goods.prod-code = buf_doc-line.prod-code no-error.
      if available buf_goods then do:
        find first buf_units no-lock where
                buf_units.unit-name = buf_goods.unit-base no-error.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'empty-scale=request':u
  ,output v-scale-is-empty
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) .
        if v-is-petrol  = yes
        and v-is-pieces = no
        then do:
          run get-petrol-weight in this-procedure (
                                                    input buf_trn-doc.ext-doc-type
                                                  , input recid( buf_doc-line )
                                                  , input buf_trn-doc.out-code
                                                  , output v-petrol-weight
                                                  , output v-weight-not-specified
                                              ).
          if v-weight-not-specified = no
          then do:
              assign
              v-petrol-density = ( if buf_doc-line.fact-qnty = 0
                                  then 0
                                  else v-petrol-weight / buf_doc-line.fact-qnty )
              .
          end.
          if buf_trn-doc.ext-doc-type = 'vt':U
          or buf_trn-doc.ext-doc-type = 'vp':U
          or buf_trn-doc.ext-doc-type = 'ap':U
          or buf_trn-doc.ext-doc-type = 'mp':U
          then do:
            define buffer buf_inv-line      for ub.inv-line.
            find first buf_inv-line no-lock
                  where buf_inv-line.doc-code  = buf_doc-line.doc-code
                    and buf_inv-line.artic     = buf_doc-line.artic
                    and buf_inv-line.prod-type = buf_doc-line.prod-type
                    and buf_inv-line.prod-code = buf_doc-line.prod-code
            no-error.
            if available buf_inv-line
            then do:
              linedoc.petrolInvFactStk = buf_inv-line.after-cli-qnty.
            end.
          end.
          define variable v-before-qnty      as decimal      no-undo.
          define variable v-after-qnty       as decimal      no-undo.
          define variable v-diff-qnty        as decimal      no-undo.
          define variable v-abs-diff-qnty    as decimal      no-undo.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_getwtqty in g#lib-trn3 (  input buf_doc-line.doc-code ,
                        input buf_doc-line.artic ,
                        input buf_doc-line.prod-type ,
                        input buf_doc-line.prod-code ,
                       output v-before-qnty ,
                       output v-after-qnty ,
                       output v-diff-qnty ,
                       output v-abs-diff-qnty ) no-error.
          if error-status :error
          then do:
                      end.
          else do:
            if buf_trn-doc.ext-doc-type <> 'vt':U
            and buf_trn-doc.ext-doc-type <> 'vp':U
            and buf_trn-doc.ext-doc-type <> 'ap':U
            and buf_trn-doc.ext-doc-type <> 'mp':U
            then do:
              assign
              v-diff-qnty     = ( buf_doc-line.doc-qnty - buf_doc-line.fact-qnty ) * v-diff-qnty / buf_doc-line.fact-qnty
              v-abs-diff-qnty = absolute( v-diff-qnty )
              .
            end.
            assign
            linedoc.petrolBeforeQnty =  v-before-qnty
            linedoc.petrolAfterQnty =  v-after-qnty
            linedoc.petrolDiffQnty  =  v-diff-qnty
            linedoc.petrolAbsDiffQnty = v-abs-diff-qnty
            .
          end.
        end.
      end.
      else do:
        release buf_units no-error.
      end.
      define variable v-parts-cst-code  like parts.cst-code     no-undo.
      define variable v-parts-price-sale as decimal no-undo .
      for each buf_parts no-lock
          where buf_parts.out-code   = buf_trn-doc.doc-code
              and buf_parts.obj-type   = buf_trn-doc.obj-type
              and buf_parts.obj-code   = buf_trn-doc.obj-code
              and buf_parts.prod-type  = buf_doc-line.prod-type
              and buf_parts.prod-code  = buf_doc-line.prod-code
              and buf_parts.artic      = buf_doc-line.artic
              and buf_parts.status_    = true
      on error undo main-block, retry main-block
      on stop undo main-block, retry main-block
      :
        create buf_part.
        assign
        buf_part.referenceNo = buf_trn-doc.doc-code
        buf_part.good = (if available buf_goods then buf_goods.gds-code else 0)
        buf_part.contractSuppCode = ''
        buf_part.contractSuppNo = ''
        buf_part.contractSuppDateXml = ?
        .
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
        v-parts-price-sale = ?.
        if buf_doc-line.is-parts = true
        and available buf_goods then do:
          define variable main-b-code as integer no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
          if not error-status:error then do:
            define variable v-doc-num as character no-undo .
            define variable parts-b-code as integer no-undo .
            define variable for-road as decimal no-undo .
            define variable for-excise as decimal no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer buf_parts
  ,output parts-b-code
  ) no-error .
            if not error-status:error then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  parts-b-code
  ,input  main-b-code
  ,input  0
  ,output v-doc-num
  ,output v-parts-price-sale
  ,output for-road
  ,output for-excise
  ) no-error .
            end.
          end.
        end.
        ASSIGN
        buf_part.qnty         = buf_parts.fact-qnty
        buf_part.sumr         = price-rubl-with-tax-loc * buf_part.qnty
        buf_part.vatr         = vat-rubl-loc            * buf_part.qnty
        buf_part.roadtaxr     = road-tax-rubl-loc       * buf_part.qnty
        buf_part.transportr   = transport-rubl-loc      * buf_part.qnty
        buf_part.otherr       = other-rubl-loc          * buf_part.qnty
        buf_part.exciser      = 0
        buf_part.sumb         = price-base-with-tax-loc * buf_part.qnty
        buf_part.vatb         = vat-base-loc            * buf_part.qnty
        buf_part.roadtaxb     = road-tax-base-loc       * buf_part.qnty
        buf_part.transportb   = transport-base-loc      * buf_part.qnty
        buf_part.otherb       = other-base-loc          * buf_part.qnty
        buf_part.exciseb      = 0
        buf_part.hostCode     = buf_parts.host-code
        buf_part.contractCode = string(buf_parts.contract-code)
        buf_part.priceCli     = buf_parts.price-cli
        buf_part.cliBaseRate  = buf_parts.cli-base-rate
        buf_part.vatType      = buf_parts.vat-type
        buf_part.exchCode     = buf_parts.exch-code
        buf_part.lastDate     = buf_parts.last-date
        buf_part.priceb       = buf_parts.price-base
        buf_part.pricer       = buf_parts.price-rubl
        buf_part.salePrice    = v-parts-price-sale
        buf_part.fib          = buf_parts.whole-send-news
        buf_part.purch-code   = buf_parts.purch-code
        .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partppric in g#library
(  buffer buf_parts
 , output buf_part.prodPrice
 , output v-prodPricewithvat
 , output v-prodvat
        )  .
        if buf_parts.contract-code <> 0
        then do:
          assign
          buf_part.contractSuppCode = string( buf_parts.contract-code )
          .
          find first buf_contract no-lock
                  where buf_contract.host-code       = buf_trn-doc.host-code
                  and buf_contract.contract-code   = buf_parts.contract-code
          no-error.
          if available buf_contract
          then do:
            assign
            buf_part.contractSuppNo = string( buf_contract.contract-prn-code )
            buf_part.contractSuppDateXML = buf_contract.contract-date
            .
          end.
        end.
        if available buf_goods
        then do:
          find first buf_parts-attr no-lock
                  where buf_parts-attr.in-code   = buf_parts.in-code
                  and buf_parts-attr.gds-code  = buf_goods.gds-code
                  and buf_parts-attr.part-code = buf_parts.part-code
          no-error .
          if available buf_parts-attr
          then do:
            assign
            buf_part.supp         = buf_parts-attr.supp-type + string(buf_parts-attr.supp-code)
            buf_part.doc_ID       = buf_parts-attr.income-in-code
            buf_part.PartCode     = buf_parts-attr.income-part-code
            buf_part.cst          = buf_parts-attr.cst-code
            buf_part.countryCode  = string(buf_parts-attr.country-code)
            buf_part.attrExchRate = buf_parts-attr.exch-rate
            buf_part.attrExchScale = buf_parts-attr.exch-scale
            buf_part.attrUnitCli  = buf_parts-attr.unit-cli
            .
          end.
          else do:
            assign
            buf_part.supp         = buf_parts.supp-type + string(buf_parts.supp-code)
            buf_part.doc_ID       = buf_parts.in-code
            buf_part.Partcode     = buf_parts.part-code
            buf_part.cst          = buf_parts.cst-code
            buf_part.countryCode  = ''
            buf_part.attrExchRate = 0.0
            buf_part.attrExchScale = 0
            buf_part.attrUnitCli  = ''
            .
          end.
        end.
        else do:
          assign
          buf_part.supp         = buf_parts.supp-type + string(buf_parts.supp-code)
          buf_part.doc_ID       = buf_parts.in-code
          buf_part.PartCode    = buf_parts.part-code
          buf_part.cst          = buf_parts.cst-code
          buf_part.countryCode  = ''
          buf_part.attrExchRate = 0.0
          buf_part.attrExchScale = 0
          buf_part.attrUnitCli  = ''
          .
        end.
        assign
        v-parts-cst-code = v-parts-cst-code
                            + ( if ( buf_part.cst <> ?
                                and trim( buf_part.cst )   <> ""
                                and trim( v-parts-cst-code ) <> "" )
                                then "; "
                                else ""  )
                            + buf_part.cst.
        .
      end.
      if not available linedoc then do:
        create linedoc.
      end.
      assign
      linedoc.referenceNo = buf_doc-line.doc-code
      linedoc.good  = (if available buf_goods then buf_goods.gds-code else 0)
      linedoc.artic = buf_doc-line.artic
      linedoc.prodType = buf_doc-line.prod-type
      linedoc.prodCode = buf_doc-line.prod-code
      linedoc.type = (if available buf_goods then buf_goods.gds-type else '')
      linedoc.unitType = (if available buf_units then buf_units.type else '')
      linedoc.wait = buf_doc-line.wt-brutto
      linedoc.place = buf_doc-line.num-place
      linedoc.priceCli = buf_doc-line.price-cli
      linedoc.cliBaseRate = buf_doc-line.cli-base-rate
      linedoc.quantity = buf_doc-line.fact-qnty
      linedoc.vatpc = buf_doc-line.vat-pc
      linedoc.petrolweight = v-petrol-weight
      linedoc.petroldensity = v-petrol-density
      linedoc.CSTCode = v-parts-cst-code
      linedoc.cashParts = (buf_doc-line.is-parts = true )
      .
      ExpData1:route-data_create-record( INPUT "linedoc") .
      if v-linedoc-hidden = no then do:
        IF ExpData1:esys-add-dump( INPUT "linedoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_hidden=referenceNo') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи по накладной &1:&2&3"
                                  , buf_trn-doc.doc-code
                                  , chr(10)
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
        v-linedoc-hidden = yes.
      end.
      ExpData1:route-data_copy-record ( input "linedoc", buffer linedoc:handle).
      IF ExpData1:esys-add-dump( INPUT "linedoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи по накладной &1 (товар &2 &3&4):&5&6"
                                , buf_trn-doc.doc-code
                                , buf_doc-line.artic
                                , buf_doc-line.prod-type
                                , buf_doc-line.prod-code
                                , chr(10)
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
      if v-scale-is-empty = no
      then do:
        for each buf_gds-dtl no-lock
          where buf_gds-dtl.prod-type  = buf_Doc-line.prod-type
            and buf_gds-dtl.prod-code  = buf_doc-line.prod-code
            and buf_gds-dtl.artic      = buf_doc-line.artic
            and buf_gds-dtl.doc-code   = buf_doc-line.doc-code
        :
          find first buf_gds-prt no-lock
              where buf_gds-prt.node-code = buf_gds-dtl.prt-code
          no-error .
if buf_trn-doc.ext-doc-type = 'ot':U or
   buf_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-slt = yes.
end.
else do:
  find first out-vatp_doc-attr no-lock
    where out-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
      and out-vatp_doc-attr.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attr then do:
    assign
      out-vatp-have-vat-slt = yes.
  end.
  else do:
     out-vatp-have-vat-slt = no.
  end.
end.
find first out-vatp_goods where out-vatp_goods.artic     = buf_doc-line.artic     and
                                   out-vatp_goods.prod-type = buf_doc-line.prod-type and
                                   out-vatp_goods.prod-code = buf_doc-line.prod-code no-lock.
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,output varroot-node
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-node
  ,input  'empty-scale=request'
  ,output varempty-scale
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
    "Признак" varroot-node skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprb
  )  .
if varoutvprb = "base":u then do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-sale    =  (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
    excise-base-sale      =  (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   / buf_trn-doc.base-rate * buf_trn-doc.base-scale)
  .
end.
if varoutvprb = "rubl":u then do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * 1)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-sale    = (if buf_doc-line.road-tax = ? then 0 else buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale)
    excise-rubl-sale      = (if buf_doc-line.excise   = ? then 0 else buf_doc-line.excise   * buf_trn-doc.base-rate / buf_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-have =  no.
assign
  varfact-qnty       = 0
  varcons-qnty       = 0
  varprice-base-cons = 0
  varprice-rubl-cons = 0.
find first out-vatp_doc-line where
           out-vatp_doc-line.doc-code   = buf_trn-doc.doc-code
       and out-vatp_doc-line.artic      = buf_doc-line.artic
       and out-vatp_doc-line.prod-type  = buf_doc-line.prod-type
       and out-vatp_doc-line.prod-code  = buf_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-line           and
  (out-vatp_doc-line.status_ = 'запрос':U or out-vatp_goods.gds-type = 'у':U) then do:
  assign
    varfact-qnty = out-vatp_doc-line.fact-qnty.
end.
else do:
  for each out-vatp_parts where out-vatp_parts.out-code   = buf_trn-doc.doc-code
                               and out-vatp_parts.obj-type   = buf_trn-doc.obj-type
                               and out-vatp_parts.obj-code   = buf_trn-doc.obj-code
                               and out-vatp_parts.artic      = buf_doc-line.artic
                               and out-vatp_parts.prod-type  = buf_doc-line.prod-type
                               and out-vatp_parts.prod-code  = buf_doc-line.prod-code no-lock :
    if out-vatp_parts.purch-code = 2 then do:
assign
  price-rubl-with-tax-loco = out-vatp_parts.price-rubl
  price-base-with-tax-loco = out-vatp_parts.price-base
.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbo
  )  .
  if out-vatp_parts.out-code = 'free-zone':U     or
     out-vatp_parts.out-code = 'out-zone':U   or
     out-vatp_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slto = yes.
  end.
  else do:
    find first in-vatp_doc-attro no-lock
      where in-vatp_doc-attro.doc-code  = out-vatp_parts.out-code
        and in-vatp_doc-attro.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attro then do:
      assign
        in-vatp-have-vat-slto = yes.
    end.
    else do:
         in-vatp-have-vat-slto = no.
    end.
  end.
  assign
   price-cli-with-tax-loco = out-vatp_parts.price-cli
   cli-base-rateo          = out-vatp_parts.cli-base-rate.
  ASSIGN   road-tax-base-loco  = (if out-vatp_parts.road-tax-base  = ? then 0 else out-vatp_parts.road-tax-base)
           road-tax-rubl-loco  = (if out-vatp_parts.road-tax-rubl  = ? then 0 else out-vatp_parts.road-tax-rubl).
  ASSIGN  transport-base-loco = (if out-vatp_parts.transport-base = ? then 0 else out-vatp_parts.transport-base)
          transport-rubl-loco = (if out-vatp_parts.transport-rubl = ? then 0 else out-vatp_parts.transport-rubl)
          other-base-loco     = (if out-vatp_parts.other-base     = ? then 0 else out-vatp_parts.other-base)
          other-rubl-loco     = (if out-vatp_parts.other-rubl     = ? then 0 else out-vatp_parts.other-rubl)
          vat-pc-loco         = (if out-vatp_parts.vat-pc         = ? then 0 else out-vatp_parts.vat-pc)
          slt-pc-loco         = (if out-vatp_parts.slt-pc         = ? then 0 else out-vatp_parts.slt-pc).
          ASSIGN   slt-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-base-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-base-with-tax-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
    ASSIGN   slt-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco)))                           * slt-pc-loco / (100 + slt-pc-loco))                        vat-rubl-loco    = (if in-vatp-have-vat-slto = no then 0 else (price-rubl-with-tax-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))) * (1 - slt-pc-loco / (100 + slt-pc-loco)) * vat-pc-loco / (100 + vat-pc-loco)).
  assign
    exch-rate-cli-loco = (out-vatp_parts.price-rubl - transport-rubl-loco - other-rubl-loco - road-tax-rubl-loco - (if out-vatp_parts.vat-type <> 'в т. ч.':U then vat-rubl-loco else 0) - (if out-vatp_parts.slt-type <> 'в т. ч.':U then slt-rubl-loco else 0)) / out-vatp_parts.price-cli .
  assign
    slt-cli-loco        = slt-rubl-loco       / exch-rate-cli-loco
    vat-cli-loco        = vat-rubl-loco       / exch-rate-cli-loco
    road-tax-cli-loco   = road-tax-rubl-loco  / exch-rate-cli-loco
    transport-cli-loco  = 0
    other-cli-loco      = 0
  .
ASSIGN
          price-base-without-tax-loco = price-base-with-tax-loco - vat-base-loco - slt-base-loco - ((if road-tax-base-loco  = ? then 0 else road-tax-base-loco) + (if transport-base-loco = ? then 0 else transport-base-loco) + (if other-base-loco = ? then 0 else other-base-loco))
    price-rubl-without-tax-loco = price-rubl-with-tax-loco - vat-rubl-loco - slt-rubl-loco - ((if road-tax-rubl-loco  = ? then 0 else road-tax-rubl-loco) + (if transport-rubl-loco = ? then 0 else transport-rubl-loco) + (if other-rubl-loco = ? then 0 else other-rubl-loco))
.
      assign
        varprice-base-cons = varprice-base-cons + (price-base-with-tax-loco - (if road-tax-base-loco = ? then 0 else road-tax-base-loco))* out-vatp_parts.fact-qnty
        varprice-rubl-cons = varprice-rubl-cons + (price-rubl-with-tax-loco - (if road-tax-rubl-loco = ? then 0 else road-tax-rubl-loco))* out-vatp_parts.fact-qnty.
      assign
        varis-cons-parts-have = yes
        varcons-qnty          = varcons-qnty + out-vatp_parts.fact-qnty.
    end.
    assign
      varfact-qnty = varfact-qnty + out-vatp_parts.fact-qnty.
  end.
end.
assign
  varprice-base-cons = varprice-base-cons / varcons-qnty
  varprice-rubl-cons = varprice-rubl-cons / varcons-qnty.
if varprice-base-cons = ? then do:
  assign
    varprice-base-cons = 0.
end.
if varprice-rubl-cons = ? then do:
  assign
    varprice-rubl-cons = 0.
end.
assign
    slt-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-base-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-base-sale            = buf_gds-dtl.discnt-base
  price-base-with-tax-sale    = (buf_gds-dtl.price-base - buf_gds-dtl.discnt-base)
    slt-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc)
  vat-rubl-buyer              = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
  discnt-rubl-sale            = buf_gds-dtl.discnt-rubl
  price-rubl-with-tax-sale    = (buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl)
  .
if buf_trn-doc.doc-type = 'инв':U then do:
  assign
    varfact-qnty = buf_gds-dtl.doc-qnty.
end.
else do:
  assign
    varfact-qnty = buf_gds-dtl.fact-qnty.
end.
if varis-cons-parts-have = no then do:
  assign
        vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc)
        vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc).
end.
else do:
  if buf_trn-doc.doc-type = 'инв':U then do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.doc-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.doc-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
  else do:
    assign
            vat-base-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-base-sale - varprice-base-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-base - buf_gds-dtl.discnt-base) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-base - buf_gds-dtl.discnt-base                - road-tax-base-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-base-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
            vat-rubl-sale               = (if out-vatp-have-vat-slt = no then 0 else (((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - road-tax-rubl-sale - varprice-rubl-cons) * buf_doc-line.cons-vat-pc / (100 + buf_doc-line.cons-vat-pc) * buf_gds-dtl.fact-qnty * varcons-qnty / varfact-qnty + ((buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl) - (if out-vatp-have-vat-slt = no then 0 else buf_gds-dtl.price-rubl - buf_gds-dtl.discnt-rubl                - road-tax-rubl-sale) * buf_doc-line.SLT-pc / (100 + buf_doc-line.SLT-pc) - varprice-rubl-cons) * buf_doc-line.vat-pc / (100 + buf_doc-line.vat-pc) * buf_gds-dtl.fact-qnty * (varfact-qnty - varcons-qnty) / varfact-qnty) / varfact-qnty)
     .
  end.
end.
assign
price-base-without-tax-sale = price-base-with-tax-sale - vat-base-sale - slt-base-sale - road-tax-base-sale
price-rubl-without-tax-sale = price-rubl-with-tax-sale - vat-rubl-sale - slt-rubl-sale - road-tax-rubl-sale.
          if not available dtl then do:
            create dtl.
          end.
          assign
          dtl.referenceNo = buf_trn-doc.doc-code
          dtl.good = (if available buf_goods then buf_goods.gds-code else 0)
          dtl.prtCode = (if available buf_gds-prt then buf_gds-prt.node-code else 0)
          dtl.dtlName = (if available buf_gds-prt then buf_gds-prt.f-name else '')
          dtl.qnty = buf_gds-dtl.fact-qnty
          dtl.sumr = price-rubl-with-tax-sale * buf_gds-dtl.fact-qnty
          dtl.VATr = vat-rubl-buyer * buf_gds-dtl.fact-qnty
          dtl.roadTaxr = road-tax-rubl-sale  * buf_gds-dtl.fact-qnty
          dtl.sumb = price-base-with-tax-sale * buf_gds-dtl.fact-qnty
          dtl.VATb = vat-base-buyer * buf_gds-dtl.fact-qnty
          dtl.roadTaxb = road-tax-base-sale  * buf_gds-dtl.fact-qnty
          .
          ExpData1:route-data_create-record( INPUT "dtl") .
          if v-dtl-hidden = no then do:
            IF ExpData1:esys-add-dump( INPUT "dtl", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_hidden=referenceNo') = false  THEN do:
              v-err-mess = substitute("Ошибка при маршрутизации записи по накладной &1:&2&3"
                                      , buf_trn-doc.doc-code
                                      , chr(10)
                                      , v-last-error-message
                                      ).
              undo main-block, retry main-block.
            end.
            v-dtl-hidden = yes.
          end.
          ExpData1:route-data_copy-record ( input "dtl", buffer dtl:handle).
          IF ExpData1:esys-add-dump( INPUT "dtl", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи dtl &1:&2&3"
                                    , buf_trn-doc.doc-code
                                    , chr(10)
                                    , v-last-error-message
                                    ).
            undo main-block, retry main-block.
          end.
        end.
      end.
      for each buf_part:
        ExpData1:route-data_create-record( INPUT "part") .
        ExpData1:route-data_copy-record ( input "part", buffer buf_part:handle).
        IF ExpData1:esys-add-dump( INPUT "part", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи part &1:&2&3"
                                  , buf_trn-doc.doc-code
                                  , chr(10)
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
        delete buf_part.
      end.
    end.
    if buf_trn-doc.ext-doc-type = 'vt':U
    or buf_trn-doc.ext-doc-type = 'vp':U
    or buf_trn-doc.ext-doc-type = 'ap':U
    or buf_trn-doc.ext-doc-type = 'mp':U
    then do:
        run export-before-and-after-inv-line in this-procedure (
                input buf_trn-doc.doc-code
            , input (if available buf_goods then buf_goods.gds-code else 0)
            , input v-exists-before
            , input v-exists-after
            , input ( v-is-petrol = yes and v-is-pieces = no and v-weight-not-specified  = no )
            , input v-petrol-density
        ).
    end.
    if available buf_operation then delete buf_operation.
  end.
end.
end procedure.
procedure get-petrol-weight :
do
on error undo, return error
:
define input parameter p-ext-doc-type           as character    no-undo.
define input parameter p-doc-line-recid         as recid        no-undo.
define input parameter p-trn-doc-out-code       as character    no-undo.
define output parameter p-petrol-weight         as decimal      no-undo.
define output parameter p-weight-not-specified  as logical      no-undo.
    define variable v-rvs-code              as character     no-undo.
    define variable v-found-last-rvs-doc    as logical       no-undo.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_rvs-doc       for rvs-doc.
    define buffer buf_rvs-line      for rvs-line.
    define buffer buf_goods         for goods.
    define buffer buf_doc-pl        for doc-pl.
    find first buf_doc-line no-lock
        where recid( buf_doc-line ) = p-doc-line-recid
    .
    find first buf_goods no-lock
         where buf_goods.artic      = buf_doc-line.artic
           and buf_goods.prod-type  = buf_doc-line.prod-type
           and buf_goods.prod-code  = buf_doc-line.prod-code
    .
    assign
        p-weight-not-specified = yes
    .
    case p-ext-doc-type:
        when 'ie':U
        then do:
            assign
                p-petrol-weight        = buf_doc-line.fact-qnty * buf_doc-line.fact-density
                p-weight-not-specified = no
            .
        end.
        when 'vt':U
        or when 'vp':U
        or when 'ap':U
        or when 'mp':U
        then do:
            find first buf_rvs-doc no-lock
                 where buf_rvs-doc.rvs-code = p-trn-doc-out-code
                   and buf_rvs-doc.status_  = 'факт':U
            no-error.
            if available buf_rvs-doc
            then do:
                assign
                    v-rvs-code           = buf_rvs-doc.rvs-code
                .
                for each buf_doc-pl no-lock
                   where buf_doc-pl.out-code = buf_doc-line.doc-code
                     and buf_doc-pl.gds-code = buf_goods.gds-code
                     and buf_doc-pl.obj-type = buf_doc-line.obj-type
                     and buf_doc-pl.obj-code = buf_doc-line.obj-code
                on error undo, return error
                :
                    for each buf_rvs-line no-lock
                       where buf_rvs-line.gds-code  = buf_doc-pl.gds-code
                         and buf_rvs-line.rvs-code  = v-rvs-code
                         and buf_rvs-line.obj-type  = buf_doc-pl.obj-type
                         and buf_rvs-line.obj-code  = buf_doc-pl.obj-code
                         and buf_rvs-line.pl-code   = buf_doc-pl.pl-code
                    on error undo, return error
                    :
                        assign
                            p-petrol-weight         = p-petrol-weight + buf_doc-pl.fact-qnty * buf_rvs-line.state-density
                            p-weight-not-specified  = no
                        .
                    end.
                end.
            end.
            else do:
                assign
                    v-found-last-rvs-doc = no
                .
                find-last-rvs:
                for each buf_rvs-doc no-lock
                   where buf_rvs-doc.obj-type = buf_doc-line.obj-type
                     and buf_rvs-doc.obj-code = buf_doc-line.obj-code
                     and buf_rvs-doc.status_  = 'факт':U
                use-index shift
                on error undo, return error
                :
                    assign
                        v-rvs-code           = buf_rvs-doc.rvs-code
                    .
                    for each buf_doc-pl no-lock
                       where buf_doc-pl.out-code = buf_doc-line.doc-code
                         and buf_doc-pl.gds-code = buf_goods.gds-code
                         and buf_doc-pl.obj-type = buf_doc-line.obj-type
                         and buf_doc-pl.obj-code = buf_doc-line.obj-code
                    on error undo, return error
                    :
                        for each buf_rvs-line no-lock
                           where buf_rvs-line.gds-code  = buf_doc-pl.gds-code
                             and buf_rvs-line.rvs-code  = v-rvs-code
                             and buf_rvs-line.obj-type  = buf_doc-pl.obj-type
                             and buf_rvs-line.obj-code  = buf_doc-pl.obj-code
                             and buf_rvs-line.pl-code   = buf_doc-pl.pl-code
                        on error undo, return error
                        :
                            assign
                                v-found-last-rvs-doc    = yes
                                p-petrol-weight         = p-petrol-weight + buf_doc-pl.fact-qnty * buf_rvs-line.state-density
                                p-weight-not-specified  = no
                            .
                            leave find-last-rvs.
                        end.
                    end.
                end.
            end.
        end.
        otherwise do:
            assign
                p-weight-not-specified = yes
            .
        end.
    end case.
end.
end procedure.
procedure export-before-and-after-inv-trn :
define input parameter p-doc-code as character no-undo .
define output parameter p-exists-before as logical no-undo .
define output parameter p-exists-after as logical no-undo .
define variable v-attr-value    as character     no-undo.
define variable v-attr-type     as character     no-undo.
define variable v-bh as handle no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_trn-doc-sum       for ub.trn-doc-sum.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'addsum':U ,
                       output v-attr-value ,
                       output v-attr-type )  .
    if lookup( 'bd':U, v-attr-value ) <> 0
    then do:
        assign
            p-exists-before = yes
        .
        find first buf_trn-doc-sum no-lock
             where buf_trn-doc-sum.doc-code = p-doc-code
               and buf_trn-doc-sum.sum-type = 'bd':U
        no-error.
        if available buf_trn-doc-sum
        then do:
          create beforesum.
          assign
          beforesum.referenceNo = buf_trn-doc-sum.doc-code
          beforesum.qnty = buf_trn-doc-sum.fact-qnty
          .
          ExpData1:route-data_create-record( INPUT "beforeSum") .
          ExpData1:route-data_copy-record ( input "beforeSum", buffer beforesum:handle).
          IF ExpData1:esys-add-dump( INPUT "beforeSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи beforeSum &1:&2&3"
                                    , p-doc-code
                                    , chr(10)
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
          create salesumbeforesum.
          buffer-copy beforesum to salesumbeforesum
          assign
          saleSumBeforeSum.sumR = buf_trn-doc-sum.crsa-sum-rubl
          saleSumBeforeSum.vatR = buf_trn-doc-sum.crsa-vat-rubl
          saleSumBeforeSum.roadTaxR = buf_trn-doc-sum.crsa-road-tax-rubl
          saleSumBeforeSum.transportR = buf_trn-doc-sum.crsa-transport-rubl
          saleSumBeforeSum.otherR = buf_trn-doc-sum.crsa-other-rubl
          saleSumBeforeSum.exciseR = buf_trn-doc-sum.crsa-excise-rubl
          saleSumBeforeSum.sumb = buf_trn-doc-sum.crsa-sum-base
          saleSumBeforeSum.vatb = buf_trn-doc-sum.crsa-vat-base
          saleSumBeforeSum.roadTaxb = buf_trn-doc-sum.crsa-road-tax-base
          saleSumBeforeSum.transportb = buf_trn-doc-sum.crsa-transport-base
          saleSumBeforeSum.otherb = buf_trn-doc-sum.crsa-other-base
          saleSumBeforeSum.exciseb = buf_trn-doc-sum.crsa-excise-base
          .
          ExpData1:route-data_create-record( INPUT "saleSumBeforeSum") .
          ExpData1:route-data_copy-record ( input "saleSumBeforeSum", buffer salesumbeforesum:handle).
          IF ExpData1:esys-add-dump( INPUT "saleSumBeforeSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи saleSumBeforeSum &1:&2&3"
                                    , p-doc-code
                                    , chr(10)
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
          create costsumbeforesum.
          buffer-copy beforesum to costsumbeforesum
          assign
          costsumBeforeSum.sumR = buf_trn-doc-sum.crsa-sum-rubl
          costsumBeforeSum.vatR = buf_trn-doc-sum.crsa-vat-rubl
          costsumBeforeSum.roadTaxR = buf_trn-doc-sum.crsa-road-tax-rubl
          costsumBeforeSum.transportR = buf_trn-doc-sum.crsa-transport-rubl
          costsumBeforeSum.otherR = buf_trn-doc-sum.crsa-other-rubl
          costsumBeforeSum.exciseR = buf_trn-doc-sum.crsa-excise-rubl
          costsumBeforeSum.sumb = buf_trn-doc-sum.crsa-sum-base
          costsumBeforeSum.vatb = buf_trn-doc-sum.crsa-vat-base
          costsumBeforeSum.roadTaxb = buf_trn-doc-sum.crsa-road-tax-base
          costsumBeforeSum.transportb = buf_trn-doc-sum.crsa-transport-base
          costsumBeforeSum.otherb = buf_trn-doc-sum.crsa-other-base
          costsumBeforeSum.exciseb = buf_trn-doc-sum.crsa-excise-base
          .
          ExpData1:route-data_create-record( INPUT "costsumBeforeSum") .
          ExpData1:route-data_copy-record ( input "costsumBeforeSum", buffer costsumbeforesum:handle).
          IF ExpData1:esys-add-dump( INPUT "costsumBeforeSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи costsumBeforeSum &1:&2&3"
                                    , p-doc-code
                                    , chr(10)
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
        end.
        else do:
          v-err-mess = "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = 'bd':U для документа " + string( p-doc-code ).
        end.
    end.
    if lookup( 'ad':U, v-attr-value ) <> 0
    then do:
        assign
            p-exists-after  = yes
        .
        find first buf_trn-doc-sum no-lock
             where buf_trn-doc-sum.doc-code = p-doc-code
               and buf_trn-doc-sum.sum-type = 'ad':U
        no-error.
        if available buf_trn-doc-sum
        then do:
          create aftersum.
          assign
          aftersum.referenceNo = buf_trn-doc-sum.doc-code
          aftersum.qnty = buf_trn-doc-sum.fact-qnty
          .
          ExpData1:route-data_create-record( INPUT "afterSum") .
          ExpData1:route-data_copy-record ( input "afterSum", buffer aftersum:handle).
          IF ExpData1:esys-add-dump( INPUT "afterSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи afterSum &1:&2&3"
                                    , p-doc-code
                                    , chr(10)
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
          create salesumaftersum.
          buffer-copy aftersum to salesumaftersum
          assign
          saleSumafterSum.sumR = buf_trn-doc-sum.crsa-sum-rubl
          saleSumafterSum.vatR = buf_trn-doc-sum.crsa-vat-rubl
          saleSumafterSum.roadTaxR = buf_trn-doc-sum.crsa-road-tax-rubl
          saleSumafterSum.transportR = buf_trn-doc-sum.crsa-transport-rubl
          saleSumafterSum.otherR = buf_trn-doc-sum.crsa-other-rubl
          saleSumafterSum.exciseR = buf_trn-doc-sum.crsa-excise-rubl
          saleSumafterSum.sumb = buf_trn-doc-sum.crsa-sum-base
          saleSumafterSum.vatb = buf_trn-doc-sum.crsa-vat-base
          saleSumafterSum.roadTaxb = buf_trn-doc-sum.crsa-road-tax-base
          saleSumafterSum.transportb = buf_trn-doc-sum.crsa-transport-base
          saleSumafterSum.otherb = buf_trn-doc-sum.crsa-other-base
          saleSumafterSum.exciseb = buf_trn-doc-sum.crsa-excise-base
          .
          ExpData1:route-data_create-record( INPUT "saleSumafterSum") .
          ExpData1:route-data_copy-record ( input "saleSumafterSum", buffer salesumaftersum:handle).
          IF ExpData1:esys-add-dump( INPUT "saleSumafterSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи saleSumafterSum &1:&2&3"
                                    , p-doc-code
                                    , chr(10)
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
          create costsumaftersum.
          buffer-copy aftersum to costsumaftersum
          assign
          costsumafterSum.sumR = buf_trn-doc-sum.crsa-sum-rubl
          costsumafterSum.vatR = buf_trn-doc-sum.crsa-vat-rubl
          costsumafterSum.roadTaxR = buf_trn-doc-sum.crsa-road-tax-rubl
          costsumafterSum.transportR = buf_trn-doc-sum.crsa-transport-rubl
          costsumafterSum.otherR = buf_trn-doc-sum.crsa-other-rubl
          costsumafterSum.exciseR = buf_trn-doc-sum.crsa-excise-rubl
          costsumafterSum.sumb = buf_trn-doc-sum.crsa-sum-base
          costsumafterSum.vatb = buf_trn-doc-sum.crsa-vat-base
          costsumafterSum.roadTaxb = buf_trn-doc-sum.crsa-road-tax-base
          costsumafterSum.transportb = buf_trn-doc-sum.crsa-transport-base
          costsumafterSum.otherb = buf_trn-doc-sum.crsa-other-base
          costsumafterSum.exciseb = buf_trn-doc-sum.crsa-excise-base
          .
          ExpData1:route-data_create-record( INPUT "costsumafterSum") .
          ExpData1:route-data_copy-record ( input "costsumafterSum", buffer costsumaftersum:handle).
          IF ExpData1:esys-add-dump( INPUT "costsumafterSum", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            v-err-mess = substitute("Ошибка при маршрутизации записи costsumafterSum &1:&2&3"
                                    , p-doc-code
                                    , chr(10)
                                    , v-last-error-message
                                    ).
            undo main-block, return error v-err-mess.
          end.
        end.
        else do:
          v-err-mess = "*** ERR: *** Не найдена запись trn-doc-sum с sum-type = 'ad':U для документа " + string( p-doc-code ).
          undo main-block, return error v-err-mess.
        end.
    end.
  end.
end procedure.
procedure export-before-and-after-inv-line :
define input parameter p-doc-code           as character    no-undo.
define input parameter p-gds-code           as integer      no-undo.
define input parameter p-exists-before      as logical      no-undo.
define input parameter p-exists-after       as logical      no-undo.
define input parameter p-need-petrol-weight as logical      no-undo.
define input parameter p-petrol-density     as decimal      no-undo.
define variable v-err-mess as character no-undo .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
define buffer buf_doc-line-sum      for ub.doc-line-sum.
empty temp-table beforesumline.
empty temp-table salesumbeforesumline.
empty temp-table costsumbeforesumline.
empty temp-table aftersumline.
empty temp-table salesumaftersumline.
empty temp-table costsumaftersumline.
if p-exists-before = yes
then do:
  find first buf_doc-line-sum no-lock
        where buf_doc-line-sum.doc-code = p-doc-code
          and buf_doc-line-sum.gds-code = p-gds-code
          and buf_doc-line-sum.sum-type = 'bd':U
  no-error.
  if available buf_doc-line-sum
  then do:
    create beforesumline.
    assign
    beforesumline.referenceNo = buf_doc-line-sum.doc-code
    beforesumline.qnty = buf_doc-line-sum.fact-qnty
    beforesumline.petrolweight = buf_doc-line-sum.fact-qnty * p-petrol-density
    beforesumline.good = p-gds-code
    .
    ExpData1:route-data_create-record( INPUT "beforeSumLine") .
    ExpData1:route-data_copy-record ( input "beforeSumLine", buffer beforesumline:handle).
    IF ExpData1:esys-add-dump( INPUT "beforeSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи beforeSumLine &1:&2&3"
                              , p-doc-code
                              , chr(10)
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
    create salesumbeforesumline.
    buffer-copy beforesumline to salesumbeforesumline
    assign
    saleSumBeforeSumLine.sumR = buf_doc-line-sum.crsa-sum-rubl
    saleSumBeforeSumLine.vatR = buf_doc-line-sum.crsa-vat-rubl
    saleSumBeforeSumLine.roadTaxR = buf_doc-line-sum.crsa-road-tax-rubl
    saleSumBeforeSumLine.transportR = buf_doc-line-sum.crsa-transport-rubl
    saleSumBeforeSumLine.otherR = buf_doc-line-sum.crsa-other-rubl
    saleSumBeforeSumLine.exciseR = buf_doc-line-sum.crsa-excise-rubl
    saleSumBeforeSumLine.sumb = buf_doc-line-sum.crsa-sum-base
    saleSumBeforeSumLine.vatb = buf_doc-line-sum.crsa-vat-base
    saleSumBeforeSumLine.roadTaxb = buf_doc-line-sum.crsa-road-tax-base
    saleSumBeforeSumLine.transportb = buf_doc-line-sum.crsa-transport-base
    saleSumBeforeSumLine.otherb = buf_doc-line-sum.crsa-other-base
    saleSumBeforeSumLine.exciseb = buf_doc-line-sum.crsa-excise-base
    .
    ExpData1:route-data_create-record( INPUT "saleSumBeforeSumLine") .
    ExpData1:route-data_copy-record ( input "saleSumBeforeSumLine", buffer salesumbeforesumline:handle).
    IF ExpData1:esys-add-dump( INPUT "saleSumBeforeSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи saleSumBeforeSumLine &1:&2&3"
                              , p-doc-code
                              , chr(10)
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
    create costsumbeforesumline.
    buffer-copy beforesumline to costsumbeforesumline
    assign
    costsumBeforeSumLine.sumR = buf_doc-line-sum.crsa-sum-rubl
    costsumBeforeSumLine.vatR = buf_doc-line-sum.crsa-vat-rubl
    costsumBeforeSumLine.roadTaxR = buf_doc-line-sum.crsa-road-tax-rubl
    costsumBeforeSumLine.transportR = buf_doc-line-sum.crsa-transport-rubl
    costsumBeforeSumLine.otherR = buf_doc-line-sum.crsa-other-rubl
    costsumBeforeSumLine.exciseR = buf_doc-line-sum.crsa-excise-rubl
    costsumBeforeSumLine.sumb = buf_doc-line-sum.crsa-sum-base
    costsumBeforeSumLine.vatb = buf_doc-line-sum.crsa-vat-base
    costsumBeforeSumLine.roadTaxb = buf_doc-line-sum.crsa-road-tax-base
    costsumBeforeSumLine.transportb = buf_doc-line-sum.crsa-transport-base
    costsumBeforeSumLine.otherb = buf_doc-line-sum.crsa-other-base
    costsumBeforeSumLine.exciseb = buf_doc-line-sum.crsa-excise-base
    .
    ExpData1:route-data_create-record( INPUT "costsumBeforeSumLine") .
    ExpData1:route-data_copy-record ( input "costsumBeforeSumLine", buffer costsumbeforesumline:handle).
    IF ExpData1:esys-add-dump( INPUT "costsumBeforeSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи costsumBeforeSumLine &1:&2&3"
                              , p-doc-code
                              , chr(10)
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
  end.
  else do:
    v-err-mess = "*** ERR: *** Не найдена запись doc-line-sum с sum-type = 'bd':U для документа " + string( p-doc-code ).
  end.
end.
if p-exists-after = yes
then do:
  find first buf_doc-line-sum no-lock
        where buf_doc-line-sum.doc-code = p-doc-code
          and buf_doc-line-sum.gds-code = p-gds-code
          and buf_doc-line-sum.sum-type = 'ad':U
  no-error.
  if available buf_doc-line-sum
  then do:
    create aftersumline.
    assign
    aftersumline.referenceNo = buf_doc-line-sum.doc-code
    aftersumline.qnty = buf_doc-line-sum.fact-qnty
    aftersumline.petrolweight = buf_doc-line-sum.fact-qnty * p-petrol-density
    aftersumline.good = p-gds-code
    .
    ExpData1:route-data_create-record( INPUT "afterSumLine") .
    ExpData1:route-data_copy-record ( input "afterSumLine", buffer aftersumline:handle).
    IF ExpData1:esys-add-dump( INPUT "afterSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи afterSumLine &1:&2&3"
                              , p-doc-code
                              , chr(10)
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
    create salesumaftersumline.
    buffer-copy aftersumline to salesumaftersumline
    assign
    saleSumafterSumLine.sumR = buf_doc-line-sum.crsa-sum-rubl
    saleSumafterSumLine.vatR = buf_doc-line-sum.crsa-vat-rubl
    saleSumafterSumLine.roadTaxR = buf_doc-line-sum.crsa-road-tax-rubl
    saleSumafterSumLine.transportR = buf_doc-line-sum.crsa-transport-rubl
    saleSumafterSumLine.otherR = buf_doc-line-sum.crsa-other-rubl
    saleSumafterSumLine.exciseR = buf_doc-line-sum.crsa-excise-rubl
    saleSumafterSumLine.sumb = buf_doc-line-sum.crsa-sum-base
    saleSumafterSumLine.vatb = buf_doc-line-sum.crsa-vat-base
    saleSumafterSumLine.roadTaxb = buf_doc-line-sum.crsa-road-tax-base
    saleSumafterSumLine.transportb = buf_doc-line-sum.crsa-transport-base
    saleSumafterSumLine.otherb = buf_doc-line-sum.crsa-other-base
    saleSumafterSumLine.exciseb = buf_doc-line-sum.crsa-excise-base
    .
    ExpData1:route-data_create-record( INPUT "saleSumafterSumLine") .
    ExpData1:route-data_copy-record ( input "saleSumafterSumLine", buffer salesumaftersumline:handle).
    IF ExpData1:esys-add-dump( INPUT "saleSumafterSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи saleSumafterSumLine &1:&2&3"
                              , p-doc-code
                              , chr(10)
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
    create costsumaftersumline.
    buffer-copy aftersumline to costsumaftersumline
    assign
    costsumafterSumLine.sumR = buf_doc-line-sum.crsa-sum-rubl
    costsumafterSumLine.vatR = buf_doc-line-sum.crsa-vat-rubl
    costsumafterSumLine.roadTaxR = buf_doc-line-sum.crsa-road-tax-rubl
    costsumafterSumLine.transportR = buf_doc-line-sum.crsa-transport-rubl
    costsumafterSumLine.otherR = buf_doc-line-sum.crsa-other-rubl
    costsumafterSumLine.exciseR = buf_doc-line-sum.crsa-excise-rubl
    costsumafterSumLine.sumb = buf_doc-line-sum.crsa-sum-base
    costsumafterSumLine.vatb = buf_doc-line-sum.crsa-vat-base
    costsumafterSumLine.roadTaxb = buf_doc-line-sum.crsa-road-tax-base
    costsumafterSumLine.transportb = buf_doc-line-sum.crsa-transport-base
    costsumafterSumLine.otherb = buf_doc-line-sum.crsa-other-base
    costsumafterSumLine.exciseb = buf_doc-line-sum.crsa-excise-base
    .
    ExpData1:route-data_create-record( INPUT "costsumafterSumLine") .
    ExpData1:route-data_copy-record ( input "costsumafterSumLine", buffer costsumaftersumline:handle).
    IF ExpData1:esys-add-dump( INPUT "costsumafterSumLine", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи costsumafterSumLine &1:&2&3"
                              , p-doc-code
                              , chr(10)
                              , v-last-error-message
                              ).
      undo main-block, return error v-err-mess.
    end.
  end.
  else do:
    v-err-mess = "*** ERR: *** Не найдена запись doc-line-sum с sum-type = 'ad':U для документа " + string( p-doc-code ).
  end.
end.
end.
end procedure.
procedure edocsord_export :
define parameter buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ord-line for ub.ord-line.
define variable v-bh as handle no-undo .
define variable v-bh-line as handle no-undo .
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
define variable v-linedoc-hidden as logical no-undo .
define variable v-dtl-hidden as logical no-undo .
define variable v-part-hidden as logical no-undo .
define variable v-date-char as character no-undo .
define buffer buf_operation for operation.
define buffer buf_currency for ub.currency.
define buffer buf_goods for ub.goods.
define buffer buf_units for ub.units.
define buffer buf_ord-chain   for ub.ord-chain.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_contract for ub.contract.
define buffer buf_gds-prt for ub.gds-prt.
main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
:
  EMPTY TEMP-TABLE operation.
  if retry then do:
    EMPTY TEMP-TABLE operation.
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input v-err-mess).
    return error ''.
  end.
  else do:
    v-bh = buffer buf_ord-doc:handle.
    v-bh-line = buffer buf_ord-line:handle.
    if v-action = 'D':U then do:
    end.
    create buf_operation.
    assign
    buf_operation.referenceNo = buf_ord-doc.doc-code
    buf_operation.codeOperation = buf_ord-doc.doc-type
    buf_operation.host = buf_ord-doc.host-code
    buf_operation.factOrder = buf_ord-doc.fact-order
    buf_operation.sysDateXML = buf_ord-doc.sys-date
    buf_operation.dateDocXML = buf_ord-doc.doc-date
    buf_operation.dateFactXML = buf_ord-doc.fact-date
    buf_operation.timeFact = string(buf_ord-doc.fact-time, "HH:MM:SS")
    buf_operation.outDateXML = buf_ord-doc.ship-date
    buf_operation.paymentCode = buf_ord-doc.pay-code
    buf_operation.outCode = buf_ord-doc.out-code
    buf_operation.comment = buf_ord-doc.PS
    buf_operation.store = buf_ord-doc.obj-type + string(buf_ord-doc.obj-code)
    buf_operation.systime = string(buf_ord-doc.sys-time-int, "HH:MM:SS")
    buf_operation.firm = buf_ord-doc.cli-type + string(buf_ord-doc.cli-code)
    buf_operation.outDateXML = buf_ord-doc.ship-date
    buf_operation.exchCode =  buf_ord-doc.exch-code
    buf_operation.exchRate =  buf_ord-doc.exch-rate
    buf_operation.exchscale  = buf_ord-doc.exch-scale
    buf_operation.ordOutDocCode = buf_ord-doc.cons-code
    buf_operation.vatType = buf_ord-doc.vat-Type
    buf_operation.shiftDateXML = buf_ord-doc.shift-date
    buf_operation.shiftNum = buf_ord-doc.shift-num
    buf_operation.shiftName = buf_ord-doc.shift-name
    buf_operation.cliQnty = buf_ord-doc.cli-qnty
    buf_operation.docQnty = buf_ord-doc.qnty
    buf_operation.factQnty = buf_ord-doc.qnty
    .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  buf_ord-doc.host-code
  ,output buf_operation.valutCode
  )  .
    find first buf_currency no-lock where
              buf_currency.curr-code = buf_operation.valutCode.
    assign
    buf_operation.valutCodeOKV = buf_currency.okv-code
    buf_operation.totalSum = ( if buf_operation.valutCode = 0
                               then buf_ord-doc.sum-rubl
                               else buf_ord-doc.sum-base )
    buf_operation.totalDsc = buf_operation.totalSum
    buf_operation.totalFact = buf_operation.totalSum
    buf_operation.totalDscFact = buf_operation.totalDsc
    .
    ExpData1:route-data_create-record( INPUT "operation") .
    ExpData1:route-data_copy-record ( input "operation", buffer buf_operation:handle).
    IF ExpData1:esys-add-dump( INPUT "operation", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      v-err-mess = substitute("Ошибка при маршрутизации записи operation &1:&2&3"
                              , buf_ord-doc.doc-code
                              , chr(10)
                              , v-last-error-message
                              ).
      undo main-block, retry main-block.
    end.
    if v-action = 'D':U then do:
      return.
    end.
    for each buf_ord-line no-lock
      where buf_ord-line.doc-code = buf_ord-doc.doc-code
    on error undo, return error return-value
    on stop undo, return error return-value
    :
      if not available linedoc then do:
        create linedoc.
      end.
      assign
      linedoc.referenceNo = buf_ord-line.doc-code
      .
      find first buf_goods no-lock where
              buf_goods.artic = buf_ord-line.artic
          and buf_goods.prod-type = buf_ord-line.prod-type
          and buf_goods.prod-code = buf_ord-line.prod-code no-error.
      if available buf_goods then do:
        find first buf_units no-lock where
                buf_units.unit-name = buf_goods.unit-base no-error.
      end.
      else do:
        release buf_units no-error.
      end.
      assign
      linedoc.good  = (if available buf_goods then buf_goods.gds-code else 0)
      linedoc.artic = buf_ord-line.artic
      linedoc.prodType = buf_ord-line.prod-type
      linedoc.prodCode = buf_ord-line.prod-code
      linedoc.type = (if available buf_goods then buf_goods.gds-type else '')
      linedoc.unitType = (if available buf_units then buf_units.type else '')
      linedoc.priceCli = buf_ord-line.price-cli
      linedoc.cliBaseRate = buf_ord-line.cli-base-rate
      linedoc.quantity = buf_ord-line.qnty
      linedoc.vatpc = buf_ord-line.vat-pc
      .
      ExpData1:route-data_create-record( INPUT "linedoc") .
      if v-linedoc-hidden = no then do:
        IF ExpData1:esys-add-dump( INPUT "linedoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_hidden=referenceNo') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи по заказу &1:&2&3"
                                  , buf_ord-doc.doc-code
                                  , chr(10)
                                  , v-last-error-message
                                  ).
          undo main-block, retry main-block.
        end.
        v-linedoc-hidden = yes.
      end.
      ExpData1:route-data_copy-record ( input "linedoc", buffer linedoc:handle).
      IF ExpData1:esys-add-dump( INPUT "linedoc", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи по заказу &1 (товар &2 &3&4):&5&6"
                                , buf_ord-doc.doc-code
                                , buf_ord-line.artic
                                , buf_ord-line.prod-type
                                , buf_ord-line.prod-code
                                , chr(10)
                                , v-last-error-message
                                ).
        undo main-block, retry main-block.
      end.
    end.
    if available linedoc then do:
      delete linedoc.
    end.
    if available buf_operation then delete buf_operation.
  end.
end.
end procedure.
