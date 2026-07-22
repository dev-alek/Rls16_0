block-level on error undo, throw.
define input parameter parparentproc   as widget-handle       no-undo .
define input parameter p-parent-handle as handle              no-undo .
define input parameter p-log-handle    as handle              no-undo .
define input parameter p-cont-handle   as handle              no-undo .
define input parameter p-codex-id      as integer             no-undo .
define input parameter p-ruleset-id    as integer             no-undo .
define input parameter p-call-id       as character           no-undo .
define input parameter p-order-id      as integer             no-undo .
define input parameter p-rule-id       as integer             no-undo .
define input parameter p-profile-id    as integer             no-undo .
define input parameter p-is-dynamic    as logical             no-undo .
define input parameter p-doc-type      as character           no-undo .
define input parameter p-host-code  like ub.sysconf.host-code no-undo .
define input parameter p-obj-type   like ub.clients.obj-type  no-undo .
define input parameter p-obj-code   like ub.clients.obj-code  no-undo .
define input parameter p-doc-code      as character           no-undo .
define input parameter p-process-file-name as character       no-undo .
define input parameter p-save          as integer             no-undo .
define input parameter v-curr-r-b      as character           no-undo .
define input parameter p-cmd-proc-handle as handle            no-undo .
define input parameter p-cmd-code      as integer             no-undo .
define variable vss-revision    as character no-undo init "$Revision: 5ee64da48eb6, 3419, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:30 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 000002062.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rul/000002062.p $":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 24, набор 1".
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
def
new shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
  run create_obj-list(p-obj-type,p-obj-code).
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE fostatok :
define input parameter p-host-code   as integer no-undo .
define input parameter x-store-code  like ub.clients.obj-code    no-undo.
define input parameter x-store-type  like ub.clients.obj-type    no-undo.
define input parameter x-tog-shift   as   logical             no-undo.
define input parameter x-date-start  as date        no-undo.
define input parameter x-date-end    as date        no-undo.
define input parameter x-shift-start as integer     no-undo.
define input parameter x-shift-end   as integer     no-undo.
define input parameter xTog-obj   as logical no-undo.
define input parameter p-curr-code as integer no-undo .
define input parameter p-cashbookid as integer  no-undo .
define output parameter sum       as decimal   no-undo.
define output parameter Fact-order  as decimal  no-undo.
define variable Fact-order#   as decimal  no-undo.
define variable Fact-orderS   as character  no-undo.
define variable x-date-start-t  as date   no-undo.
define variable x-sum-type as character no-undo .
    if x-tog-shift then do:
      assign
      x-sum-type = 'shift-obj':U.
    end.
    else do:
      x-sum-type = 'obj':U.
    end.
Assign
Fact-order   = 0
sum     = 0
x-date-start-t  = x-date-start + 1 .
IF x-date-end = date('') then DO:
  Fact-order = 0 .
  For each obj-list no-lock
      WHERE  (NOT xTog-obj OR
              (x-store-type = obj-list.obj-type
              AND
              x-store-code = obj-list.obj-code))
  :
   fact-order# = 0.
   IF  x-TOG-Shift = False Then DO:
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
          arh-fin-doc-schet-nal-obj.Fact-date <=  x-date-start
          USE-INDEX fact-date  no-error .
     if Available arh-fin-doc-schet-nal-obj THEN  do:
       Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
     end.
   End.
   Else  DO :
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
           (arh-fin-doc-schet-nal-obj.shift-date  = x-date-start-t and
            arh-fin-doc-schet-nal-obj.shift-num  < x-shift-start or
            arh-fin-doc-schet-nal-obj.shift-date  < x-date-start-t  )
            and arh-fin-doc-schet-nal-obj.shift-num  > 0
            USE-INDEX Shift-num no-error .
      if Available arh-fin-doc-schet-nal-obj THEN  do:
        Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
      end.
    END.
    If Fact-order < Fact-order#  and Fact-order# <> 0  THEN  Fact-order = Fact-order# .
  End.
End.
Else DO:
  For each obj-list  no-lock WHERE
     (NOT xTog-obj
      OR
      (x-store-type = obj-list.obj-type
      AND
      x-store-code = obj-list.obj-code))
   :
   IF  x-TOG-Shift = False Then DO:
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
            arh-fin-doc-schet-nal-obj.Fact-date <= x-date-end
            and arh-fin-doc-schet-nal-obj.shift-num = 0
            USE-INDEX fact-date no-error.
     if Available arh-fin-doc-schet-nal-obj THEN  do:
       Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
     end.
   END.
   Else DO:
      find last arh-fin-doc-schet-nal-obj no-lock where     arh-fin-doc-schet-nal-obj.obj-type = obj-list.obj-type and arh-fin-doc-schet-nal-obj.obj-code = obj-list.obj-code and arh-fin-doc-schet-nal-obj.cli-code          = p-host-code and arh-fin-doc-schet-nal-obj.cli-type          = 'орг':U and arh-fin-doc-schet-nal-obj.calc-curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.cashbookid    = p-cashbookid and arh-fin-doc-schet-nal-obj.curr-code    = p-curr-code and arh-fin-doc-schet-nal-obj.sum-type = x-sum-type and
            (arh-fin-doc-schet-nal-obj.shift-date  = x-date-end and
            arh-fin-doc-schet-nal-obj.shift-num  <= x-shift-end or
            arh-fin-doc-schet-nal-obj.shift-date  < x-date-end       ) and
            arh-fin-doc-schet-nal-obj.shift-num   > 0      use-index shift-num no-error.
      if Available arh-fin-doc-schet-nal-obj THEN  do:
        Assign                          sum     = arh-fin-doc-schet-nal-obj.income - arh-fin-doc-schet-nal-obj.expense                          Fact-order#  = arh-fin-doc-schet-nal-obj.Fact-order.
      end.
    End.
    if Fact-order < Fact-order#  THEN  Fact-order = Fact-order#.
  End.
End.
END PROCEDURE.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gds-attr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
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
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
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
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
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
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fd-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-label = "Дата смены"     p-type = 'T':U      p-format = "99/99/9999"     p-label = "Дата смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-num':U then do:     assign     p-label = "П.смены"     p-type = 'I':U      p-format = "99"     p-label = "П.смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'shift-name':U then do:     assign     p-label = "№ смены"     p-type = 'C':U      p-format = "X(2)"     p-label = "№ смены"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'barcode':U then do:     assign     p-label = "Штрих-код"     p-type = 'C':U      p-format = "X(20)"     p-label = "Штрих-код"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'lockid':U then do:     assign     p-label = "ID блокировки чека"     p-type = 'C':U      p-format = "X(2)"     p-label = "ID блокировки чека"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'cover_sheet':U then do:     assign     p-label = "Разбиение по номиналам"     p-type = 'C':U      p-format = "X(4000)"     p-label = "Разбиение по номиналам"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'pre-vedom':U then do:     assign     p-label = "Атрибут для препроводительной ведомости"     p-type = 'C':U      p-format = "X(256)"     p-label = "Атрибут для препроводительной ведомости"     p-user-can-edit  = false     p-output-display = false     p-other = '':u      .   end.
            when 'contr-kb':U then do:     assign     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-type = 'I':U      p-format = ">>>9"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fd-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-tooltip = "Дата смены"     p-label = "Дата смены" .   end.
            when 'shift-num':U then do:     assign     p-tooltip = "П.смены"     p-label = "П.смены" .   end.
            when 'shift-name':U then do:     assign     p-tooltip = "№ смены"     p-label = "№ смены" .   end.
            when 'barcode':U then do:     assign     p-tooltip = "Штрих-код"     p-label = "Штрих-код" .   end.
            when 'lockid':U then do:     assign     p-tooltip = "ID блокировки чека"     p-label = "ID блокировки чека" .   end.
            when 'cover_sheet':U then do:     assign     p-tooltip = "Разбиение по номиналам"     p-label = "Разбиение по номиналам" .   end.
            when 'pre-vedom':U then do:     assign     p-tooltip = "Атрибут для препроводительной ведомости"     p-label = "Атрибут для препроводительной ведомости" .   end.
            when 'contr-kb':U then do:     assign     p-tooltip = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами"     p-label = "Код кассовой книги получателя\отправителя при перемещении ДС между кассами" .   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-attr-code     like ub.fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr  exclusive-lock  where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code    = p-host-code
      AND buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code  no-error .
  if not available  buf_fin-doc-attr then do:
      create buf_fin-doc-attr.
      assign
      buf_fin-doc-attr.attr-code    = p-attr-code
      buf_fin-doc-attr.attr-value   = p-attr-value
      buf_fin-doc-attr.host-code    = p-host-code
      buf_fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
       assign
       buf_fin-doc-attr.attr-value = p-attr-value.
  end.
 end.
end procedure.
procedure fd-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
    define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
    define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
    define output parameter p-exist   as logical  no-undo .
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error .
    if  available buf_fin-doc-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure fd-attr-delete :
  do
  on error undo, return error
  :
  define input parameter p-host-code     like ub.fin-doc-attr.host-code  no-undo .
  define input parameter p-fin-doc-code  like ub.fin-doc-attr.fin-doc-code   no-undo .
  define input parameter p-code          like ub.fin-doc-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define variable  v-type           as character no-undo .
    define variable  v-format         as character no-undo .
    define variable  v-label          as character no-undo .
    define variable  v-user-can-edit  as logical   no-undo .
    define variable  v-output-display as logical   no-undo .
    define variable  v-other          as character no-undo .
    run fd-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_fin-doc-attr exclusive-lock
      where buf_fin-doc-attr.host-code  = p-host-code
        and buf_fin-doc-attr.fin-doc-code  = p-fin-doc-code
        and buf_fin-doc-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_fin-doc-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_fin-doc-attr no-error .
      if error-status:error then do:
        undo, return error return-value .
      end.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.fin-doc-attr.fin-doc-code     no-undo .
define input  parameter p-attr-code    like ub.fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_fin-doc-attr for ub.fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_fin-doc-attr no-lock where
          buf_fin-doc-attr.attr-code    = p-attr-code
      AND buf_fin-doc-attr.host-code     = p-host-code
      AND buf_fin-doc-attr.fin-doc-code = p-fin-doc-code      no-error .
  if available  buf_fin-doc-attr then do:
    assign
    p-attr-value = buf_fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure fd-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'shift-date':U then do:     assign     p-news = no.   end.
            when 'shift-num':U then do:     assign     p-news = no.   end.
            when 'shift-name':U then do:     assign     p-news = no.   end.
            when 'barcode':U then do:     assign     p-news = no.   end.
            when 'lockid':U then do:     assign     p-news = no.   end.
            when 'cover_sheet':U then do:     assign     p-news = no.   end.
            when 'pre-vedom':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error "неизвестный атрибут платежа " + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure c-fin-doc-attr-write :
 do
 on error undo, return error return-value
 :
define input parameter p-host-code     like ub.c-fin-doc-attr.host-code  no-undo .
define input parameter p-fin-doc-code  like ub.c-fin-doc-attr.fin-doc-code   no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input parameter p-attr-code     like ub.c-fin-doc-attr.attr-code  no-undo .
define input parameter p-attr-value    like ub.c-fin-doc-attr.attr-value no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
                                  (input  p-attr-code
                                  ,output v-type
                                  ,output v-format
                                  ,output v-label
                                  ,output v-user-can-edit
                                  ,output v-output-display
                                  ,output v-other
                                  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr  exclusive-lock  where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.host-code    = p-host-code
      AND buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if not available  buf_c-fin-doc-attr then do:
      create buf_c-fin-doc-attr.
      assign
      buf_c-fin-doc-attr.attr-code    = p-attr-code
      buf_c-fin-doc-attr.attr-value   = p-attr-value
      buf_c-fin-doc-attr.host-code    = p-host-code
      buf_c-fin-doc-attr.fin-doc-code     = p-fin-doc-code
      .
  end.
  else do:
        buf_c-fin-doc-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      AND buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      AND buf_c-fin-doc-attr.host-code      = p-host-code
      AND buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fin-doc-attr.chip-num         = p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
procedure c-fin-doc-attr-value-nextchip :
 do
 on error undo, return error return-value
 :
define input  parameter p-host-code    like ub.c-fin-doc-attr.host-code    no-undo .
define input  parameter p-fin-doc-code like ub.c-fin-doc-attr.fin-doc-code     no-undo .
define input parameter p-corr-user-db-num  like ub.c-fin-doc-attr.corr-user-db-num   no-undo .
define input parameter p-chip-num      like ub.c-fin-doc-attr.chip-num   no-undo .
define input  parameter p-attr-code    like ub.c-fin-doc-attr.attr-code    no-undo .
define output parameter p-attr-value   like ub.c-fin-doc-attr.attr-value   no-undo .
define variable  v-format         as character no-undo .
define variable  v-label          as character no-undo .
define variable  v-user-can-edit  as logical   no-undo .
define variable  v-output-display as logical   no-undo .
define variable  v-other          as character no-undo .
define variable  v-type           as character no-undo .
define buffer buf_c-fin-doc-attr for ub.c-fin-doc-attr.
run fd-attr-code in this-procedure
  (input  p-attr-code
  ,output v-type
  ,output v-format
  ,output v-label
  ,output v-user-can-edit
  ,output v-output-display
  ,output v-other
  ) no-error .
if error-status :error then do:
  undo, return error return-value .
end.
find first buf_c-fin-doc-attr no-lock where
          buf_c-fin-doc-attr.attr-code    = p-attr-code
      and buf_c-fin-doc-attr.fin-doc-code      = p-fin-doc-code
      and buf_c-fin-doc-attr.host-code      = p-host-code
      and buf_c-fin-doc-attr.corr-user-db-num = p-corr-user-db-num
      and buf_c-fin-doc-attr.chip-num         > p-chip-num      no-error .
  if available  buf_c-fin-doc-attr then do:
    assign
    p-attr-value = buf_c-fin-doc-attr.attr-value
    .
  end.
  else do:
    p-attr-value = ? .
  end.
 end.
end procedure.
  define variable v-current-doc-code   as character no-undo .
  define variable log-file-name        as character no-undo init "process-fdoc.txt".
  define variable v-view-log           as logical   no-undo .
  define variable v-stop               as logical   no-undo .
  define variable v-last-error-message as character no-undo .
  define variable file-name            as character no-undo.
  define variable v-sign               as integer   no-undo.
  define variable l-res                as integer   no-undo.
  define variable v-es                 as logical   no-undo.
  define variable v-esm                as character no-undo.
  define variable v-rv                 as character no-undo.
  define variable v-err-mess           as character no-undo.
  define variable is-petrolium         as logical   no-undo.
  define variable o-uchet              as character no-undo .
  define variable v-uchet              as character no-undo .
  define variable v-value-date         as date      no-undo .
  define variable v-value-decimal      as decimal   no-undo .
  define variable v-value-integer      as INTEGER   no-undo .
  define variable v-value-logical      AS LOGICAL   no-undo .
  define variable par-type             as character no-undo .
  define variable v-tth                as handle    no-undo .
  define variable mValue               as character no-undo.
  define variable mType                as character no-undo.
  define variable mValueVne            as character no-undo.
  define variable mTypeVne             as character no-undo.
  define variable mValueAvans          as character no-undo.
  define variable mTypeAvans           as character no-undo.
  define variable mTypePay             as character no-undo.
  define variable taxVne               as character no-undo .
  define buffer buf_shift-obj for ub.shift-obj.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-error :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
     assign
     v-last-error-message = p-mess.
  end.
end procedure.
  define variable mCashBook         as class     ibs.th.ref.cashbookstorage no-undo .
  define variable p-by-cash-desk    as logical   no-undo .
  define variable p-by-petrol-goods as logical   no-undo .
  define variable p-by-osnovanie    as character no-undo .
  define variable p-by-pril         as character no-undo .
  on delete of this-procedure
    do:
      run garbcoll_clear in this-procedure .
    end.
  run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
  if error-status:error then
  do:
    undo, return error return-value .
  end.
  if return-value = "return" then return ''.
  if not this-procedure:persistent then
  do:
    run proc-main in this-procedure no-error .
    if error-status:error then
    do:
      v-esm = error-status :get-message (1).
      v-es = error-status:error .
      v-rv = return-value .
    end.
    if v-es then
    do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, chr(10), v-esm).
    end.
    run garbcoll_clear in this-procedure .
  end.
  DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
  DEFINE TEMP-TABLE ttc-fin-doc NO-UNDO LIKE ub.fin-doc.
  DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
  DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
  DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.
  define temp-table tt-cashbookAttr no-undo
    field cashbookid as int64
    field vneCli     as character
    field vneCorr    as character
    field avansCli   as character
    field avansCorr  as character
    index pi cashbookid
    .
  define temp-table tt-cashBookOst no-undo
    field cashbookid as int64
    field ost        as decimal
    field osnpko     as decimal
    field osnrko     as decimal
    index pi cashbookid.
  define temp-table tt-cashBookOstVne no-undo
    field cashbookid as int64
    field ost        as decimal
    field osnpko     as decimal
    field osnrko     as decimal
    index pi cashbookid.
  define temp-table tt-cashBookOstAvans no-undo
    field cashbookid as int64
    field ost        as decimal
    field osnpko     as decimal
    field osnrko     as decimal
    index pi cashbookid.
  define temp-table temp-fin-sum no-undo
    field cash-desk        as integer
    field curr-code        as integer
    field tot-sum          as decimal
    field tot-base         as decimal
    field tot-rubl         as decimal
    field is-petrol        as logical
    field cashbookid       as int64
    field is-expense_cash  as logical
    field num-expense_cash as int
    field pay-type         as char
    field contr-kb         as integer   init ?
    field fin-type         as character
    index pi is unique primary
    num-expense_cash is-expense_cash cash-desk curr-code is-petrol cashbookid pay-type
    .
  define temp-table temp-fin-sumVne no-undo
    field cash-desk        as integer
    field curr-code        as integer
    field tot-sum          as decimal
    field tot-base         as decimal
    field tot-rubl         as decimal
    field is-petrol        as logical
    field cashbookid       as int64
    field is-expense_cash  as logical
    field num-expense_cash as int
    field pay-type         as char
    field contr-kb         as integer   init ?
    field fin-type         as character
    index pi is unique primary
    num-expense_cash is-expense_cash cash-desk curr-code is-petrol cashbookid pay-type
    .
  define temp-table temp-fin-sumAvans no-undo
    field cash-desk        as integer
    field curr-code        as integer
    field tot-sum          as decimal
    field tot-base         as decimal
    field tot-rubl         as decimal
    field is-petrol        as logical
    field cashbookid       as int64
    field is-expense_cash  as logical
    field num-expense_cash as int
    field pay-type         as char
    field contr-kb         as integer   init ?
    field fin-type         as character
    index pi is unique primary
    num-expense_cash is-expense_cash cash-desk curr-code is-petrol cashbookid pay-type
    .
  define temp-table temp-gds no-undo
    field with-vat     as logical   init yes
    field b-code       as integer
    field node-code    as integer
    field doc-code     as character
    field doc-kind     as character
    field gds-code     as integer
    field artic        as character
    field prod-type    as character
    field prod-code    as integer
    field eff-doc-qnty as decimal
    field tot-r-b      as decimal
    field tot-rubl     as decimal
    field tot-base     as decimal
    field tot-doc      as decimal
    field vat-base     as decimal
    field vat-rubl     as decimal
    field vat-doc      as decimal
    field curr-code    as integer
    field cash-desk    as integer
    field pay-type     as char
    field is-petrol    as logical
    index pi is unique primary
    cash-desk
    b-code
    doc-kind
    curr-code
    pay-type
    .
  define temp-table temp-gdsVne no-undo
    field with-vat     as logical   init yes
    field b-code       as integer
    field node-code    as integer
    field doc-code     as character
    field doc-kind     as character
    field gds-code     as integer
    field artic        as character
    field prod-type    as character
    field prod-code    as integer
    field eff-doc-qnty as decimal
    field tot-r-b      as decimal
    field tot-rubl     as decimal
    field tot-base     as decimal
    field tot-doc      as decimal
    field vat-base     as decimal
    field vat-rubl     as decimal
    field vat-doc      as decimal
    field curr-code    as integer
    field cash-desk    as integer
    field pay-type     as char
    field is-petrol    as logical
    index pi is unique primary
    cash-desk
    b-code
    doc-kind
    curr-code
    pay-type
    .
  define temp-table temp-gdsAvans no-undo
    field with-vat     as logical   init yes
    field b-code       as integer
    field node-code    as integer
    field doc-code     as character
    field doc-kind     as character
    field gds-code     as integer
    field artic        as character
    field prod-type    as character
    field prod-code    as integer
    field eff-doc-qnty as decimal
    field tot-r-b      as decimal
    field tot-rubl     as decimal
    field tot-base     as decimal
    field tot-doc      as decimal
    field vat-base     as decimal
    field vat-rubl     as decimal
    field vat-doc      as decimal
    field curr-code    as integer
    field cash-desk    as integer
    field pay-type     as char
    field is-petrol    as logical
    index pi is unique primary
    cash-desk
    b-code
    doc-kind
    curr-code
    pay-type
    .
  define temp-table temp-tax no-undo
    field with-vat         as logical init yes
    field curr-code        as integer
    field vat-pc           as decimal
    field slt-pc           as decimal
    field vat-base         as decimal
    field vat-rubl         as decimal
    field vat-doc          as decimal
    field sum-base         as decimal
    field sum-rubl         as decimal
    field sum-doc          as decimal
    field cash-desk        as integer
    field is-petrol        as logical
    field cashbookId       as int64
    field is-expense_cash  as logical
    field pay-type         as char
    field num-expense_cash as int
    index pi is unique primary
    num-expense_cash
    is-expense_cash
    cash-desk
    curr-code
    vat-pc
    slt-pc
    is-petrol
    cashbookId
    pay-type
    .
  define temp-table temp-taxVne no-undo
    field with-vat         as logical init yes
    field curr-code        as integer
    field vat-pc           as decimal
    field slt-pc           as decimal
    field vat-base         as decimal
    field vat-rubl         as decimal
    field vat-doc          as decimal
    field sum-base         as decimal
    field sum-rubl         as decimal
    field sum-doc          as decimal
    field cash-desk        as integer
    field is-petrol        as logical
    field cashbookId       as int64
    field is-expense_cash  as logical
    field pay-type         as char
    field num-expense_cash as int
    index pi is unique primary
    num-expense_cash
    is-expense_cash
    cash-desk
    curr-code
    vat-pc
    slt-pc
    is-petrol
    cashbookId
    pay-type
    .
  define temp-table temp-taxAvans no-undo
    field with-vat         as logical init yes
    field curr-code        as integer
    field vat-pc           as decimal
    field slt-pc           as decimal
    field vat-base         as decimal
    field vat-rubl         as decimal
    field vat-doc          as decimal
    field sum-base         as decimal
    field sum-rubl         as decimal
    field sum-doc          as decimal
    field cash-desk        as integer
    field is-petrol        as logical
    field cashbookId       as int64
    field is-expense_cash  as logical
    field pay-type         as char
    field num-expense_cash as int
    index pi is unique primary
    num-expense_cash
    is-expense_cash
    cash-desk
    curr-code
    vat-pc
    slt-pc
    is-petrol
    cashbookId
    pay-type
    .
  define temp-table temp-z-number no-undo
    field z-number  as integer
    field cash-desk as integer
    index pi is unique primary
    cash-desk z-number.
  define temp-table temp-z-number-list no-undo
    field cash-desk    as integer
    field naznach-plat as character
    index pi is unique primary
    cash-desk .
  define temp-table temp-autotank no-undo
    field curr-code  as integer
    field pay-desk   as integer
    field sum-return as decimal
    field is-petrol  as logical
    field vat-pc     as decimal
    field slt-pc     as decimal
    index idx curr-code pay-desk is-petrol vat-pc slt-pc .
procedure proc-main :
  define variable v-count         as integer   no-undo .
  define variable v-tot-r-b-chk   as decimal   no-undo .
  define variable v-tot-r-b-inkas as decimal   no-undo .
  define variable v-real-obj-type as character no-undo .
  define variable v-real-obj-code as integer   no-undo .
  define variable v-host-code     as integer   no-undo .
  define variable v-host-name     as character no-undo .
  define variable v-base-code     as integer   no-undo .
  define variable v-param-type    as character no-undo .
  define variable v-naznach-plat  as character no-undo .
  define variable v-naznach-plat2 as character no-undo .
  define variable cash-book       as integer   no-undo .
  define variable v-value         as character no-undo .
  define variable v-cashier       as character no-undo .
  define variable v-limit-access  as integer   no-undo .
  define variable v-obj-db-num    as integer   no-undo .
  define variable v-vat-pc        as integer   no-undo .
  define variable v-slt-pc        as integer   no-undo .
  define buffer buf_inkas                 for ub.inkas.
  define buffer buf_inkas-pay-desk        for ub.inkas-pay-desk.
  define buffer buf_cash-pay              for ub.cash-pay.
  define buffer buf_temp-fin-sum          for temp-fin-sum.
  define buffer buf_temp-fin-sum-Pko      for temp-fin-sum.
  define buffer buf_temp-fin-sumVne       for temp-fin-sumVne.
  define buffer buf_temp-fin-sumVne-Pko   for temp-fin-sumVne.
  define buffer buf_temp-fin-sumAvans     for temp-fin-sumAvans.
  define buffer buf_temp-fin-sumAvans-Pko for temp-fin-sumAvans.
  define buffer buf_chk-gds-pay           for ub.chk-gds-pay.
  define buffer buf_chk-doc               for ub.chk-doc.
  define buffer buf_chk-pay               for ub.chk-pay.
  define buffer buf_chk-pay-attr          for ub.chk-pay-attr.
  define buffer buf_temp-gds              for temp-gds.
  define buffer buf_temp-gdsVne           for temp-gdsVne.
  define buffer buf_temp-gdsAvans         for temp-gdsAvans.
  define buffer buf_bar-code              for ub.bar-code.
  define buffer buf_goods                 for ub.goods.
  define buffer buf_sale-doc              for ub.sale-doc.
  define buffer buf_trn-doc               for ub.trn-doc.
  define buffer buf_doc-line              for ub.doc-line.
  define buffer buf_gds-dtl               for ub.gds-dtl.
  define buffer buf_temp-tax              for temp-tax.
  define buffer buf_temp-taxVne           for temp-taxVne.
  define buffer buf_temp-taxAvans         for temp-taxAvans.
  define buffer buf_fin-doc               for ub.fin-doc.
  define buffer buf_sysconf               for ub.sysconf.
  define buffer buf_shift-staff           for ub.shift-staff.
  define buffer buf_chk-gds               for ub.chk-gds.
  mCashBook = new ibs.th.ref.cashbookstorage () .
  _main:
  do
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
    define variable v-err as logical no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  buf_shift-obj.obj-type
  ,input  buf_shift-obj.obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_shift-obj.obj-type
  ,input  buf_shift-obj.obj-code
  ,output v-obj-db-num
  )  .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
    find first buf_sysconf no-lock where
      buf_sysconf.host-code = v-host-code.
    for each ub.CashBook no-lock:
      create tt-cashbookAttr .
      assign
        tt-cashbookAttr.cashbookid = ub.CashBook.id .
      for first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
        ub.CashBookRule.Code = "Vnecli-code":
        tt-cashbookAttr.vneCli = ub.CashBookRule.RuleValue .
      end.
      for first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
        ub.CashBookRule.Code = "corrPkoVne":
        tt-cashbookAttr.vneCorr = ub.CashBookRule.RuleValue .
      end.
      for first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
        ub.CashBookRule.Code = "Avanscli-code":
        tt-cashbookAttr.avansCli = ub.CashBookRule.RuleValue .
      end.
      for first ub.CashBookRule no-lock where ub.CashBookRule.CashBookID = ub.CashBook.id and
        ub.CashBookRule.Code = "corrPkoAvans":
        tt-cashbookAttr.avansCorr = ub.CashBookRule.RuleValue .
      end.
    end.
    find first buf_shift-staff no-lock
      where buf_shift-staff.obj-type   = buf_shift-obj.obj-type
      and buf_shift-staff.obj-code   = buf_shift-obj.obj-code
      and buf_shift-staff.shift-date = buf_shift-obj.shift-date
      and buf_shift-staff.shift-num  = buf_shift-obj.shift-num
      and buf_shift-staff.staff-role = yes no-error.
    if not available buf_shift-staFF THEN
    DO:
      if buf_shift-obj.status_ = 'зкр':U then
      do:
        v-cashier = "адм".
      end.
      else
      do:
        run gbl/d-prompt.w (
          'title=':u + "Менеджер смены неопределен. Введите ФИО кассира," + '\':u
          + 'text1=':u + "от имени которого будем оформлять Ордер на выручку" + '\':u
          + 'format=' + "X(40)" + '\':u
          + 'type=' + 'C':U + '\':u
          + 'fillin_row=3\':u
          + 'fillin_col=4\':u
          + 'fillin_width=41\':u
          + 'fillin_height=1\':u
          + 'max-chars=5\':u
          + 'readonly=no\':u
          , input-output v-value
          ).
        if return-value = 'false':u then
        do:
                if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Нельзя создать ордер на выручку, если кассир не определен")).
          undo, return error .
        END.
      end.
      v-cashier = v-value.
    end.
    else
    do:
      v-cashier = buf_shift-staff.name.
    end.
    for each buf_chk-gds-pay no-lock
      where buf_chk-gds-pay.obj-type   = buf_shift-obj.obj-type
      and buf_chk-gds-pay.obj-code   = buf_shift-obj.obj-code
      and buf_chk-gds-pay.shift-date = buf_shift-obj.shift-date
      and buf_chk-gds-pay.shift-num  = buf_shift-obj.shift-num
      and buf_chk-gds-pay.algo-num   = "1.8":
      assign
        v-tot-r-b-chk = v-tot-r-b-chk  + buf_chk-gds-pay.tot-r-b
        .
      if num-entries(buf_chk-gds-pay.line-type, chr(4)) > 1
        and entry(2, buf_chk-gds-pay.line-type, chr(4)) = ""
        then
      do :
        find first buf_chk-gds no-lock where buf_chk-gds.b-code = buf_chk-gds-pay.b-code
          and buf_chk-gds.doc-code = buf_chk-gds-pay.doc-code
          and buf_chk-gds.line-num = buf_chk-gds-pay.line-num
          no-error .
        if not available buf_chk-gds
          then
        do :
          find first buf_chk-gds no-lock where buf_chk-gds.b-code = buf_chk-gds-pay.b-code
            and buf_chk-gds.doc-code = buf_chk-gds-pay.doc-code .
        end.
        if num-entries(buf_chk-gds.line-type, chr(4)) > 1
          then
        do :
          find first ub.chk-gds-pay exclusive-lock where rowid(ub.chk-gds-pay) = rowid(buf_chk-gds-pay) .
          assign
            entry(2, ub.chk-gds-pay.line-type, chr(4)) = entry(2, buf_chk-gds.line-type, chr(4))
            .
          release ub.chk-gds-pay .
        end.
      end.
    end.
    for each buf_inkas no-lock
      where buf_inkas.obj-type   = buf_shift-obj.obj-type
      and buf_inkas.obj-code   = buf_shift-obj.obj-code
      and buf_inkas.status_    = 'факт':U
      and buf_inkas.shift-date = buf_shift-obj.shift-date
      and buf_inkas.shift-num  = buf_shift-obj.shift-num
      :
      assign
        v-count         = v-count + 1
        v-tot-r-b-inkas = v-tot-r-b-inkas  + buf_inkas.netto
        .
      for each buf_chk-doc no-lock
        where buf_chk-doc.obj-type    = buf_inkas.obj-type
        and buf_chk-doc.obj-code    = buf_inkas.obj-code
        and buf_chk-doc.out-code    = buf_inkas.inkas-code
        and (buf_chk-doc.chk-type    = integer('1':U)
        or  buf_chk-doc.chk-type    = integer('6':U))
        :
        if not can-find (first temp-z-number
          where temp-z-number.cash-desk = buf_chk-doc.pay-desk
          and temp-z-number.z-number  = buf_chk-doc.z-number)
          then
        do:
          create temp-z-number.
          assign
            temp-z-number.cash-desk = buf_chk-doc.pay-desk
            temp-z-number.z-number  = buf_chk-doc.z-number
            .
        end.
      end.
    end.
    if abs(v-tot-r-b-chk - v-tot-r-b-inkas) > 0.015 * v-count then
    do:
            if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("В БД нет ПОЛНОЙ информации по разбиению товарных сумм в чеках по типам кассовых платежей")).
      undo _main, return error .
    end.
        if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Создание кассовых ордеров для выручки по смене № &1 от &2 (П. &3) &6&4&5"                                 , buf_shift-obj.shift-name                                 , buf_shift-obj.shift-date                                 , buf_shift-obj.shift-nuM                                    , buf_shift-obj.obj-type                                 , buf_shift-obj.obj-code                                 , chr(10)                                 )).
    for each buf_inkas no-lock
      where buf_inkas.obj-type   = buf_shift-obj.obj-type
      and buf_inkas.obj-code   = buf_shift-obj.obj-code
      and buf_inkas.status_    = 'факт':U
      and buf_inkas.shift-date = buf_shift-obj.shift-date
      and buf_inkas.shift-num  = buf_shift-obj.shift-num
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :
      for each buf_inkas-pay-desk no-lock
        where buf_inkas-pay-desk.inkas-code = buf_inkas.inkas-code
        break
        by buf_inkas-pay-desk.inkas-code
        by buf_inkas-pay-desk.pay-code
        by buf_inkas-pay-desk.curr-code
        by buf_inkas-pay-desk.pay-desk
        on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
        on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
        on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
        :
        find first buf_cash-pay no-lock
          where buf_cash-pay.cdpay-code = buf_inkas-pay-desk.pay-code
          and buf_cash-pay.curr-code = buf_inkas-pay-desk.curr-code no-error.
        if not available buf_cash-pay then
        do:
        end.
        if not (buf_cash-pay.is-cash
          or buf_cash-pay.cdpay-code = 1) then
        do:
          next.
        end.
        if last-of(buf_inkas-pay-desk.pay-desk) then
        do:
//создание финдоков
          for each buf_chk-doc no-lock
            where buf_chk-doc.obj-code = buf_inkas.obj-code
            and buf_chk-doc.obj-type = buf_inkas.obj-type
            and buf_chk-doc.out-code = buf_inkas-pay-desk.inkas-code
            and buf_chk-doc.pay-desk = buf_inkas-pay-desk.pay-desk
            :
            for each buf_chk-gds-pay no-lock
              where buf_chk-gds-pay.out-code = buf_inkas-pay-desk.inkas-code
              and buf_chk-gds-pay.obj-code = buf_inkas.obj-code
              and buf_chk-gds-pay.pay-code = buf_inkas-pay-desk.pay-code
              and buf_chk-gds-pay.doc-code = buf_chk-doc.doc-code
              and buf_chk-gds-pay.algo-num = "1.8"
              :
              if buf_chk-gds-pay.curr-code <> buf_inkas-pay-desk.curr-code then next .
              run gds-attr-value in this-procedure (
                input buf_chk-gds-pay.gds-code
                ,input "cash-book-id"
                ,output mValue
                ,output mType) no-error.
              run gds-attr-value in this-procedure (
                input buf_chk-gds-pay.gds-code
                ,input 'item-matter-mark':U
                ,output mValueVne
                ,output mTypeVne) no-error.
              run gds-attr-value in this-procedure (
                input buf_chk-gds-pay.gds-code
                ,input 'type-method-calc':U
                ,output mValueAvans
                ,output mTypeAvans) no-error.
              if p-by-petrol-goods then
              do:
                run check-petrol in this-procedure (
                  input buf_chk-gds-pay.b-code ,
                  output is-petrolium
                  ).
              end.
              define variable msum    as decimal no-undo.
              define variable msumVne as decimal no-undo.
              case buf_chk-gds-pay.curr-code:
                when 0 then
                  do:
                    assign
                      msum = (if v-curr-r-b = 'rubl':U
                                 then buf_chk-gds-pay.tot-r-b
                                 else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                          )
                      .
                  end.
                when v-base-code then
                  do:
                    assign
                      msum = (if v-curr-r-b = 'base':U
                                then buf_chk-gds-pay.tot-r-b
                                else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                          )
                      .
                  end.
              end case.
              find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
              if not available ub.CashBook
                then
              do :
                find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
              end.
              find first tt-cashbookAttr where tt-cashbookAttr.cashbookid = ub.CashBook.id no-error .
              if not (tt-cashbookAttr.vneCli <> "" and tt-cashbookAttr.vneCorr <> "") then mValueVne = "" .
              if not (tt-cashbookAttr.avansCli <> "" and tt-cashbookAttr.avansCorr <> "") then mValueAvans = "" .
              if available ub.CashBook
                then
              do :
                find first chk-gds-attr where ub.chk-gds-attr.doc-code = buf_chk-gds-pay.doc-code
                  and ub.chk-gds-attr.line-num = buf_chk-gds-pay.line-num
                  and ub.chk-gds-attr.attr-code = "cstype"
                  no-lock no-error.
                p-by-cash-desk = ub.CashBook.FlagSepCash .
                p-by-petrol-goods = ub.CashBook.FlagSepFull .
                mTypePay          = if available chk-gds-attr and integer (chk-gds-attr.attr-value) eq 37 then 'Cash' else "".
                .
              end.
              if mValueVne = "15" then
              do:
                find first buf_temp-fin-sumVne
                  where buf_temp-fin-sumVne.curr-code = buf_cash-pay.curr-code
                  and (p-by-cash-desk    = no or buf_temp-fin-sumVne.cash-desk = buf_inkas-pay-desk.pay-desk)
                  and (p-by-petrol-goods = no or buf_temp-fin-sumVne.is-petrol = is-petrolium)
                  and buf_temp-fin-sumVne.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                  and buf_temp-fin-sumVne.is-expense_cash = (msum < 0 and mTypePay eq "cash" )
                  and buf_temp-fin-sumVne.pay-type eq mTypePay
                  no-error.
                if not available buf_temp-fin-sumVne then
                do:
                  create buf_temp-fin-sumVne.
                  assign
                    buf_temp-fin-sumVne.curr-code       = buf_cash-pay.curr-code
                    buf_temp-fin-sumVne.cash-desk       = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                    buf_temp-fin-sumVne.is-petrol       = (if p-by-petrol-goods
                                                      then is-petrolium
                                                      else no)
                    buf_temp-fin-sumVne.cashbookid      = (if available ub.CashBook then ub.CashBook.id else 0)
                    buf_temp-fin-sumVne.is-expense_cash = msum < 0 and mTypePay eq "cash"
                    buf_temp-fin-sumVne.pay-type        = mTypePay
                    .
                end.
                assign
                  buf_temp-fin-sumVne.tot-rubl = buf_temp-fin-sumVne.tot-rubl + (if v-curr-r-b = 'rubl':U
                                                                        then buf_chk-gds-pay.tot-r-b
                                                                        else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                        )
                  buf_temp-fin-sumVne.tot-base = buf_temp-fin-sumVne.tot-base + (if v-curr-r-b = 'base':U
                                                                        then buf_chk-gds-pay.tot-r-b
                                                                        else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                        )
                  buf_temp-fin-sumVne.tot-sum  = buf_temp-fin-sumVne.tot-sum + msum
                  .
              end .
              else
              do:
                if mValueAvans > "" then do:
                                  find first buf_temp-fin-sumAvans
                  where buf_temp-fin-sumAvans.curr-code = buf_cash-pay.curr-code
                  and (p-by-cash-desk    = no or buf_temp-fin-sumAvans.cash-desk = buf_inkas-pay-desk.pay-desk)
                  and (p-by-petrol-goods = no or buf_temp-fin-sumAvans.is-petrol = is-petrolium)
                  and buf_temp-fin-sumAvans.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                  and buf_temp-fin-sumAvans.is-expense_cash = (msum < 0 and mTypePay eq "cash" )
                  and buf_temp-fin-sumAvans.pay-type eq mTypePay
                  no-error.
                if not available buf_temp-fin-sumAvans then
                do:
                  create buf_temp-fin-sumAvans.
                  assign
                    buf_temp-fin-sumAvans.curr-code       = buf_cash-pay.curr-code
                    buf_temp-fin-sumAvans.cash-desk       = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                    buf_temp-fin-sumAvans.is-petrol       = (if p-by-petrol-goods
                                                      then is-petrolium
                                                      else no)
                    buf_temp-fin-sumAvans.cashbookid      = (if available ub.CashBook then ub.CashBook.id else 0)
                    buf_temp-fin-sumAvans.is-expense_cash = msum < 0 and mTypePay eq "cash"
                    buf_temp-fin-sumAvans.pay-type        = mTypePay
                    .
                end.
                assign
                  buf_temp-fin-sumAvans.tot-rubl = buf_temp-fin-sumAvans.tot-rubl + (if v-curr-r-b = 'rubl':U
                                                                        then buf_chk-gds-pay.tot-r-b
                                                                        else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                        )
                  buf_temp-fin-sumAvans.tot-base = buf_temp-fin-sumAvans.tot-base + (if v-curr-r-b = 'base':U
                                                                        then buf_chk-gds-pay.tot-r-b
                                                                        else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                        )
                  buf_temp-fin-sumAvans.tot-sum  = buf_temp-fin-sumAvans.tot-sum + msum
                  .
                end.
                else do:
                find first buf_temp-fin-sum
                  where buf_temp-fin-sum.curr-code = buf_cash-pay.curr-code
                  and (p-by-cash-desk    = no or buf_temp-fin-sum.cash-desk = buf_inkas-pay-desk.pay-desk)
                  and (p-by-petrol-goods = no or buf_temp-fin-sum.is-petrol = is-petrolium)
                  and buf_temp-fin-sum.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                  and buf_temp-fin-sum.is-expense_cash = (msum < 0 and mTypePay eq "cash" )
                  and buf_temp-fin-sum.pay-type eq mTypePay
                  no-error.
                if not available buf_temp-fin-sum then
                do:
                  create buf_temp-fin-sum.
                  assign
                    buf_temp-fin-sum.curr-code       = buf_cash-pay.curr-code
                    buf_temp-fin-sum.cash-desk       = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                    buf_temp-fin-sum.is-petrol       = (if p-by-petrol-goods
                                                      then is-petrolium
                                                      else no)
                    buf_temp-fin-sum.cashbookid      = (if available ub.CashBook then ub.CashBook.id else 0)
                    buf_temp-fin-sum.is-expense_cash = msum < 0 and mTypePay eq "cash"
                    buf_temp-fin-sum.pay-type        = mTypePay
                    .
                end.
                assign
                  buf_temp-fin-sum.tot-rubl = buf_temp-fin-sum.tot-rubl + (if v-curr-r-b = 'rubl':U
                                                                        then buf_chk-gds-pay.tot-r-b
                                                                        else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                        )
                  buf_temp-fin-sum.tot-base = buf_temp-fin-sum.tot-base + (if v-curr-r-b = 'base':U
                                                                        then buf_chk-gds-pay.tot-r-b
                                                                        else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                        )
                  buf_temp-fin-sum.tot-sum  = buf_temp-fin-sum.tot-sum + msum
                  .
              end.
             end.
            end.
          end.
          if mValueVne = "15" then
          do:
            FOR EACH buf_chk-doc NO-LOCK where buf_chk-doc.out-code = buf_inkas-pay-desk.inkas-code
              AND buf_chk-doc.pay-desk = buf_inkas-pay-desk.pay-desk
              AND buf_chk-doc.cashier  = buf_inkas-pay-desk.cashier,
              EACH buf_chk-pay NO-LOCK
              where buf_chk-pay.doc-code = buf_chk-doc.doc-code
              AND  buf_chk-pay.pay-code = buf_inkas-pay-desk.pay-code
              AND  buf_chk-pay.curr-code = buf_inkas-pay-desk.curr-code,
              FIRST buf_chk-pay-attr NO-LOCK
              WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
              AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
              AND buf_chk-pay-attr.attr-code = "autotank-sum-return":
              assign
                buf_temp-fin-sumVne.tot-sum  = buf_temp-fin-sumVne.tot-sum  - decimal(buf_chk-pay-attr.attr-value)
                buf_temp-fin-sumVne.tot-rubl = buf_temp-fin-sumVne.tot-rubl - decimal(buf_chk-pay-attr.attr-value)
                buf_temp-fin-sumVne.tot-base = buf_temp-fin-sumVne.tot-base - decimal(buf_chk-pay-attr.attr-value)
                .
              find first buf_chk-gds no-lock
                where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                no-error.
              if available buf_chk-gds then
              do:
                find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds.b-code no-error.
                if available buf_bar-code then
                do:
                  find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                  if available buf_goods then
                  do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output v-vat-pc
  ) no-error .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output v-slt-pc
  ) no-error .
                  end.
                end.
              end.
              find first temp-autotank where temp-autotank.curr-code =  buf_inkas-pay-desk.curr-code
                and temp-autotank.vat-pc    =  v-vat-pc
                and temp-autotank.slt-pc    =  v-slt-pc
                and temp-autotank.pay-desk = (if p-by-cash-desk
                then buf_inkas-pay-desk.pay-desk
                else 0)
                and temp-autotank.is-petrol = (if p-by-petrol-goods
                then buf_temp-fin-sumVne.is-petrol
                else no)
                no-error.
              if not available temp-autotank then
              do:
                create temp-autotank.
                assign
                  temp-autotank.curr-code = buf_inkas-pay-desk.curr-code
                  temp-autotank.vat-pc    = v-vat-pc
                  temp-autotank.slt-pc    = v-slt-pc
                  temp-autotank.pay-desk  = (if p-by-cash-desk
                                        then buf_inkas-pay-desk.pay-desk
                                        else 0)
                  temp-autotank.is-petrol = (if p-by-petrol-goods
                                        then buf_temp-fin-sumVne.is-petrol
                                        else no)
                  .
              end.
              assign
                temp-autotank.sum-return = temp-autotank.sum-return - decimal(buf_chk-pay-attr.attr-value)
                .
            END.
          end.
          else
          do:
            if mValueAvans > "" then
            do:
                          FOR EACH buf_chk-doc NO-LOCK where buf_chk-doc.out-code = buf_inkas-pay-desk.inkas-code
              AND buf_chk-doc.pay-desk = buf_inkas-pay-desk.pay-desk
              AND buf_chk-doc.cashier  = buf_inkas-pay-desk.cashier,
              EACH buf_chk-pay NO-LOCK
              where buf_chk-pay.doc-code = buf_chk-doc.doc-code
              AND  buf_chk-pay.pay-code = buf_inkas-pay-desk.pay-code
              AND  buf_chk-pay.curr-code = buf_inkas-pay-desk.curr-code,
              FIRST buf_chk-pay-attr NO-LOCK
              WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
              AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
              AND buf_chk-pay-attr.attr-code = "autotank-sum-return":
              assign
                buf_temp-fin-sumAvans.tot-sum  = buf_temp-fin-sumAvans.tot-sum  - decimal(buf_chk-pay-attr.attr-value)
                buf_temp-fin-sumAvans.tot-rubl = buf_temp-fin-sumAvans.tot-rubl - decimal(buf_chk-pay-attr.attr-value)
                buf_temp-fin-sumAvans.tot-base = buf_temp-fin-sumAvans.tot-base - decimal(buf_chk-pay-attr.attr-value)
                .
              find first buf_chk-gds no-lock
                where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                no-error.
              if available buf_chk-gds then
              do:
                find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds.b-code no-error.
                if available buf_bar-code then
                do:
                  find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                  if available buf_goods then
                  do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output v-vat-pc
  ) no-error .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output v-slt-pc
  ) no-error .
                  end.
                end.
              end.
              find first temp-autotank where temp-autotank.curr-code =  buf_inkas-pay-desk.curr-code
                and temp-autotank.vat-pc    =  v-vat-pc
                and temp-autotank.slt-pc    =  v-slt-pc
                and temp-autotank.pay-desk = (if p-by-cash-desk
                then buf_inkas-pay-desk.pay-desk
                else 0)
                and temp-autotank.is-petrol = (if p-by-petrol-goods
                then buf_temp-fin-sumAvans.is-petrol
                else no)
                no-error.
              if not available temp-autotank then
              do:
                create temp-autotank.
                assign
                  temp-autotank.curr-code = buf_inkas-pay-desk.curr-code
                  temp-autotank.vat-pc    = v-vat-pc
                  temp-autotank.slt-pc    = v-slt-pc
                  temp-autotank.pay-desk  = (if p-by-cash-desk
                                        then buf_inkas-pay-desk.pay-desk
                                        else 0)
                  temp-autotank.is-petrol = (if p-by-petrol-goods
                                        then buf_temp-fin-sumAvans.is-petrol
                                        else no)
                  .
              end.
              assign
                temp-autotank.sum-return = temp-autotank.sum-return - decimal(buf_chk-pay-attr.attr-value)
                .
            END.
            end.
            else
            do:
              FOR EACH buf_chk-doc NO-LOCK where buf_chk-doc.out-code = buf_inkas-pay-desk.inkas-code
                AND buf_chk-doc.pay-desk = buf_inkas-pay-desk.pay-desk
                AND buf_chk-doc.cashier  = buf_inkas-pay-desk.cashier,
                EACH buf_chk-pay NO-LOCK
                where buf_chk-pay.doc-code = buf_chk-doc.doc-code
                AND  buf_chk-pay.pay-code = buf_inkas-pay-desk.pay-code
                AND  buf_chk-pay.curr-code = buf_inkas-pay-desk.curr-code,
                FIRST buf_chk-pay-attr NO-LOCK
                WHERE buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code
                AND buf_chk-pay-attr.line-num = buf_chk-pay.line-num
                AND buf_chk-pay-attr.attr-code = "autotank-sum-return":
                assign
                  buf_temp-fin-sum.tot-sum  = buf_temp-fin-sum.tot-sum  - decimal(buf_chk-pay-attr.attr-value)
                  buf_temp-fin-sum.tot-rubl = buf_temp-fin-sum.tot-rubl - decimal(buf_chk-pay-attr.attr-value)
                  buf_temp-fin-sum.tot-base = buf_temp-fin-sum.tot-base - decimal(buf_chk-pay-attr.attr-value)
                  .
                find first buf_chk-gds no-lock
                  where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                  no-error.
                if available buf_chk-gds then
                do:
                  find first buf_bar-code no-lock where
                    buf_bar-code.b-code = buf_chk-gds.b-code no-error.
                  if available buf_bar-code then
                  do:
                    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                    if available buf_goods then
                    do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output v-vat-pc
  ) no-error .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_inkas.obj-type
  ,input  buf_inkas.obj-code
  ,output v-slt-pc
  ) no-error .
                    end.
                  end.
                end.
                find first temp-autotank where temp-autotank.curr-code =  buf_inkas-pay-desk.curr-code
                  and temp-autotank.vat-pc    =  v-vat-pc
                  and temp-autotank.slt-pc    =  v-slt-pc
                  and temp-autotank.pay-desk = (if p-by-cash-desk
                  then buf_inkas-pay-desk.pay-desk
                  else 0)
                  and temp-autotank.is-petrol = (if p-by-petrol-goods
                  then buf_temp-fin-sum.is-petrol
                  else no)
                  no-error.
                if not available temp-autotank then
                do:
                  create temp-autotank.
                  assign
                    temp-autotank.curr-code = buf_inkas-pay-desk.curr-code
                    temp-autotank.vat-pc    = v-vat-pc
                    temp-autotank.slt-pc    = v-slt-pc
                    temp-autotank.pay-desk  = (if p-by-cash-desk
                                        then buf_inkas-pay-desk.pay-desk
                                        else 0)
                    temp-autotank.is-petrol = (if p-by-petrol-goods
                                        then buf_temp-fin-sum.is-petrol
                                        else no)
                    .
                end.
                assign
                  temp-autotank.sum-return = temp-autotank.sum-return - decimal(buf_chk-pay-attr.attr-value)
                  .
              END.
            end.
          end.
          _chk-gds-pay:
          for each buf_chk-gds-pay no-lock
            where buf_chk-gds-pay.out-code = buf_inkas.inkas-code
            and buf_chk-gds-pay.obj-code = buf_inkas.obj-code
            and buf_chk-gds-pay.pay-code = buf_inkas-pay-desk.pay-code
            and buf_chk-gds-pay.algo-num = "1.8",
            first buf_chk-doc no-lock
            where buf_chk-doc.doc-code = buf_chk-gds-pay.doc-code
            and buf_chk-doc.pay-desk = buf_inkas-pay-desk.pay-desk:
            if buf_chk-gds-pay.curr-code <> buf_inkas-pay-desk.curr-code then next _chk-gds-pay.
            run gds-attr-value in this-procedure (
              input buf_chk-gds-pay.gds-code
              ,input "cash-book-id"
              ,output mValue
              ,output mType) no-error.
            run gds-attr-value in this-procedure (
              input buf_chk-gds-pay.gds-code
              ,input 'item-matter-mark':U
              ,output mValueVne
              ,output mTypeVne) no-error.
            run gds-attr-value in this-procedure (
              input buf_chk-gds-pay.gds-code
              ,input 'type-method-calc':U
              ,output mValueAvans
              ,output mTypeAvans) no-error.
            find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
            if not available ub.CashBook
              then
            do :
              find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
            end.
            if available ub.CashBook
              then
            do :
              assign
                p-by-cash-desk    = ub.CashBook.FlagSepCash
                p-by-petrol-goods = ub.CashBook.FlagSepFull
                .
            end.
            find first tt-cashbookAttr where tt-cashbookAttr.cashbookid = ub.CashBook.id no-error .
            if not (tt-cashbookAttr.vneCli <> "" and tt-cashbookAttr.vneCorr <> "") then mValueVne = "" .
            if not (tt-cashbookAttr.avansCli <> "" and tt-cashbookAttr.avansCorr <> "") then mValueAvans = "" .
            if p-by-petrol-goods then
            do:
              run check-petrol in this-procedure (
                input buf_chk-gds-pay.b-code ,
                output is-petrolium
                ).
            end.
            find first chk-gds-attr where ub.chk-gds-attr.doc-code = buf_chk-gds-pay.doc-code
              and ub.chk-gds-attr.line-num = buf_chk-gds-pay.line-num
              and ub.chk-gds-attr.attr-code = "cstype"
              no-lock no-error.
            mTypePay          = if available chk-gds-attr and integer (chk-gds-attr.attr-value) eq 37 then 'Cash' else "".
            if mValueVne = "15" then
            do:
              find first buf_temp-gdsVne no-lock where
                buf_temp-gdsVne.b-code = buf_chk-gds-pay.b-code
                and buf_temp-gdsVne.doc-kind = (if num-entries(buf_chk-gds-pay.line-type, chr(4)) > 1
                then entry(2, buf_chk-gds-pay.line-type, chr(4))
                else '')
                and buf_temp-gdsVne.curr-code = buf_inkas-pay-desk.curr-code
                and (p-by-cash-desk = no or buf_temp-gdsVne.cash-desk = buf_inkas-pay-desk.pay-desk)
                and (p-by-petrol-goods = no or buf_temp-gdsVne.is-petrol = is-petrolium)
                and buf_temp-gdsVne.pay-type = mTypePay
                no-error.
              if not available buf_temp-gdsVne then
              do:
                find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds-pay.b-code no-error.
                if available buf_bar-code then
                do:
                  find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                  if available buf_goods then
                  do:
                    if p-by-petrol-goods then
                    do:
                      run check-petrol in this-procedure (
                        input buf_chk-gds-pay.b-code ,
                        output is-petrolium
                        ).
                    end.
                    create buf_temp-gdsVne.
                    assign
                      buf_temp-gdsVne.b-code    = buf_chk-gds-pay.b-code
                      buf_temp-gdsVne.gds-code  = buf_bar-code.gds-code
                      buf_temp-gdsVne.artic     = buf_goods.artic
                      buf_temp-gdsVne.prod-type = buf_goods.prod-type
                      buf_temp-gdsVne.prod-code = buf_goods.prod-code
                      buf_temp-gdsVne.doc-kind  = (if num-entries(buf_chk-gds-pay.line-type, chr(4)) > 1
                                          then entry(2, buf_chk-gds-pay.line-type, chr(4))
                                          else '')
                      buf_temp-gdsVne.curr-code = buf_inkas-pay-desk.curr-code
                      buf_temp-gdsVne.cash-desk = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                      buf_temp-gdsVne.pay-type  = mTypePay
                      buf_temp-gdsVne.node-code = buf_bar-code.node-code
                      buf_temp-gdsVne.is-petrol = (if p-by-petrol-goods then is-petrolium else no)
                      .
                    find first chk-gds where chk-gds.doc-code eq buf_chk-gds-pay.doc-code
                      and chk-gds.line-num eq buf_chk-gds-pay.line-num
                      no-lock no-error.
                    buf_temp-gdsVne.with-vat = available chk-gds and chk-gds.VAT-pc >= 0.
                  end.
                end.
              end.
              if available buf_temp-gdsVne then
              do:
                assign
                  buf_temp-gdsVne.tot-r-b      = buf_temp-gdsVne.tot-r-b + buf_chk-gds-pay.tot-r-b
                  buf_temp-gdsVne.eff-doc-qnty = buf_temp-gdsVne.eff-doc-qnty + buf_chk-gds-pay.eff-doc-qnty
                  buf_temp-gdsVne.tot-rubl     = buf_temp-gdsVne.tot-rubl +   (if v-curr-r-b = 'rubl':U
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                              )
                  buf_temp-gdsVne.tot-base     = buf_temp-gdsVne.tot-base +   (if v-curr-r-b = 'base':U
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                              )
                  .
                case buf_chk-gds-pay.curr-code:
                  when 0 then
                    do:
                      assign
                        buf_temp-gdsVne.tot-doc = buf_temp-gdsVne.tot-doc +   (if v-curr-r-b = 'rubl':U
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                )
                        .
                    end.
                  when v-base-code then
                    do:
                      assign
                        buf_temp-gdsVne.tot-doc = buf_temp-gdsVne.tot-doc +   (if v-curr-r-b = 'base':U
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                )
                        .
                    end.
                  otherwise
                  do:
                    find first buf_chk-pay no-lock where
                      buf_chk-pay.doc-code = buf_chk-gds-pay.doc-code
                      and buf_chk-pay.line-num = buf_chk-gds-pay.cpline-num no-error.
                    if available buf_chk-pay then
                    do:
                      assign
                        buf_temp-gdsVne.tot-doc = buf_temp-gdsVne.tot-doc +   (if v-curr-r-b = 'rubl':U
                                                                  then buf_chk-gds-pay.tot-r-b
                                                                  else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate) / buf_chk-pay.calc-rate
                                                                  )
                        .
                    end.
                    else
                    do:
                    end.
                  end.
                end case.
              end.
            end .
            else
            do:
              if mValueAvans > "" then
              do:
                              find first buf_temp-gdsAvans no-lock where
                buf_temp-gdsAvans.b-code = buf_chk-gds-pay.b-code
                and buf_temp-gdsAvans.doc-kind = (if num-entries(buf_chk-gds-pay.line-type, chr(4)) > 1
                then entry(2, buf_chk-gds-pay.line-type, chr(4))
                else '')
                and buf_temp-gdsAvans.curr-code = buf_inkas-pay-desk.curr-code
                and (p-by-cash-desk = no or buf_temp-gdsAvans.cash-desk = buf_inkas-pay-desk.pay-desk)
                and (p-by-petrol-goods = no or buf_temp-gdsAvans.is-petrol = is-petrolium)
                and buf_temp-gdsAvans.pay-type = mTypePay
                no-error.
              if not available buf_temp-gdsAvans then
              do:
                find first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds-pay.b-code no-error.
                if available buf_bar-code then
                do:
                  find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                  if available buf_goods then
                  do:
                    if p-by-petrol-goods then
                    do:
                      run check-petrol in this-procedure (
                        input buf_chk-gds-pay.b-code ,
                        output is-petrolium
                        ).
                    end.
                    create buf_temp-gdsAvans.
                    assign
                      buf_temp-gdsAvans.b-code    = buf_chk-gds-pay.b-code
                      buf_temp-gdsAvans.gds-code  = buf_bar-code.gds-code
                      buf_temp-gdsAvans.artic     = buf_goods.artic
                      buf_temp-gdsAvans.prod-type = buf_goods.prod-type
                      buf_temp-gdsAvans.prod-code = buf_goods.prod-code
                      buf_temp-gdsAvans.doc-kind  = (if num-entries(buf_chk-gds-pay.line-type, chr(4)) > 1
                                          then entry(2, buf_chk-gds-pay.line-type, chr(4))
                                          else '')
                      buf_temp-gdsAvans.curr-code = buf_inkas-pay-desk.curr-code
                      buf_temp-gdsAvans.cash-desk = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                      buf_temp-gdsAvans.pay-type  = mTypePay
                      buf_temp-gdsAvans.node-code = buf_bar-code.node-code
                      buf_temp-gdsAvans.is-petrol = (if p-by-petrol-goods then is-petrolium else no)
                      .
                    find first chk-gds where chk-gds.doc-code eq buf_chk-gds-pay.doc-code
                      and chk-gds.line-num eq buf_chk-gds-pay.line-num
                      no-lock no-error.
                    buf_temp-gdsAvans.with-vat = available chk-gds and chk-gds.VAT-pc >= 0.
                  end.
                end.
              end.
              if available buf_temp-gdsAvans then
              do:
                assign
                  buf_temp-gdsAvans.tot-r-b      = buf_temp-gdsAvans.tot-r-b + buf_chk-gds-pay.tot-r-b
                  buf_temp-gdsAvans.eff-doc-qnty = buf_temp-gdsAvans.eff-doc-qnty + buf_chk-gds-pay.eff-doc-qnty
                  buf_temp-gdsAvans.tot-rubl     = buf_temp-gdsAvans.tot-rubl +   (if v-curr-r-b = 'rubl':U
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                              )
                  buf_temp-gdsAvans.tot-base     = buf_temp-gdsAvans.tot-base +   (if v-curr-r-b = 'base':U
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                              )
                  .
                case buf_chk-gds-pay.curr-code:
                  when 0 then
                    do:
                      assign
                        buf_temp-gdsAvans.tot-doc = buf_temp-gdsAvans.tot-doc +   (if v-curr-r-b = 'rubl':U
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                )
                        .
                    end.
                  when v-base-code then
                    do:
                      assign
                        buf_temp-gdsAvans.tot-doc = buf_temp-gdsAvans.tot-doc +   (if v-curr-r-b = 'base':U
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                )
                        .
                    end.
                  otherwise
                  do:
                    find first buf_chk-pay no-lock where
                      buf_chk-pay.doc-code = buf_chk-gds-pay.doc-code
                      and buf_chk-pay.line-num = buf_chk-gds-pay.cpline-num no-error.
                    if available buf_chk-pay then
                    do:
                      assign
                        buf_temp-gdsAvans.tot-doc = buf_temp-gdsAvans.tot-doc +   (if v-curr-r-b = 'rubl':U
                                                                  then buf_chk-gds-pay.tot-r-b
                                                                  else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate) / buf_chk-pay.calc-rate
                                                                  )
                        .
                    end.
                    else
                    do:
                    end.
                  end.
                end case.
              end.
              end.
              else
              do:
                find first buf_temp-gds no-lock where
                  buf_temp-gds.b-code = buf_chk-gds-pay.b-code
                  and buf_temp-gds.doc-kind = (if num-entries(buf_chk-gds-pay.line-type, chr(4)) > 1
                  then entry(2, buf_chk-gds-pay.line-type, chr(4))
                  else '')
                  and buf_temp-gds.curr-code = buf_inkas-pay-desk.curr-code
                  and (p-by-cash-desk = no or buf_temp-gds.cash-desk = buf_inkas-pay-desk.pay-desk)
                  and (p-by-petrol-goods = no or buf_temp-gds.is-petrol = is-petrolium)
                  and buf_temp-gds.pay-type = mTypePay
                  no-error.
                if not available buf_temp-gds then
                do:
                  find first buf_bar-code no-lock where
                    buf_bar-code.b-code = buf_chk-gds-pay.b-code no-error.
                  if available buf_bar-code then
                  do:
                    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
                    if available buf_goods then
                    do:
                      if p-by-petrol-goods then
                      do:
                        run check-petrol in this-procedure (
                          input buf_chk-gds-pay.b-code ,
                          output is-petrolium
                          ).
                      end.
                      create buf_temp-gds.
                      assign
                        buf_temp-gds.b-code    = buf_chk-gds-pay.b-code
                        buf_temp-gds.gds-code  = buf_bar-code.gds-code
                        buf_temp-gds.artic     = buf_goods.artic
                        buf_temp-gds.prod-type = buf_goods.prod-type
                        buf_temp-gds.prod-code = buf_goods.prod-code
                        buf_temp-gds.doc-kind  = (if num-entries(buf_chk-gds-pay.line-type, chr(4)) > 1
                                          then entry(2, buf_chk-gds-pay.line-type, chr(4))
                                          else '')
                        buf_temp-gds.curr-code = buf_inkas-pay-desk.curr-code
                        buf_temp-gds.cash-desk = (if p-by-cash-desk
                                                      then buf_inkas-pay-desk.pay-desk
                                                      else 0)
                        buf_temp-gds.pay-type  = mTypePay
                        buf_temp-gds.node-code = buf_bar-code.node-code
                        buf_temp-gds.is-petrol = (if p-by-petrol-goods then is-petrolium else no)
                        .
                      find first chk-gds where chk-gds.doc-code eq buf_chk-gds-pay.doc-code
                        and chk-gds.line-num eq buf_chk-gds-pay.line-num
                        no-lock no-error.
                      buf_temp-gds.with-vat = available chk-gds and chk-gds.VAT-pc >= 0.
                    end.
                  end.
                end.
                if available buf_temp-gds then
                do:
                  assign
                    buf_temp-gds.tot-r-b      = buf_temp-gds.tot-r-b + buf_chk-gds-pay.tot-r-b
                    buf_temp-gds.eff-doc-qnty = buf_temp-gds.eff-doc-qnty + buf_chk-gds-pay.eff-doc-qnty
                    buf_temp-gds.tot-rubl     = buf_temp-gds.tot-rubl +   (if v-curr-r-b = 'rubl':U
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                              )
                    buf_temp-gds.tot-base     = buf_temp-gds.tot-base +   (if v-curr-r-b = 'base':U
                                                              then buf_chk-gds-pay.tot-r-b
                                                              else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                              )
                    .
                  case buf_chk-gds-pay.curr-code:
                    when 0 then
                      do:
                        assign
                          buf_temp-gds.tot-doc = buf_temp-gds.tot-doc +   (if v-curr-r-b = 'rubl':U
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                                                                )
                          .
                      end.
                    when v-base-code then
                      do:
                        assign
                          buf_temp-gds.tot-doc = buf_temp-gds.tot-doc +   (if v-curr-r-b = 'base':U
                                                                then buf_chk-gds-pay.tot-r-b
                                                                else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                                                                )
                          .
                      end.
                    otherwise
                    do:
                      find first buf_chk-pay no-lock where
                        buf_chk-pay.doc-code = buf_chk-gds-pay.doc-code
                        and buf_chk-pay.line-num = buf_chk-gds-pay.cpline-num no-error.
                      if available buf_chk-pay then
                      do:
                        assign
                          buf_temp-gds.tot-doc = buf_temp-gds.tot-doc +   (if v-curr-r-b = 'rubl':U
                                                                  then buf_chk-gds-pay.tot-r-b
                                                                  else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate) / buf_chk-pay.calc-rate
                                                                  )
                          .
                      end.
                      else
                      do:
                      end.
                    end.
                  end case.
                end.
              end.
            end.
          end.
        end.
      end.
      for each buf_sale-doc no-lock where
        buf_sale-doc.inkas-code = buf_inkas.inkas-code
        and buf_sale-doc.in-inkas = yes
        and buf_sale-doc.storage = 'trn-doc':U
        ,
        first buf_trn-doc no-lock where
        buf_trn-doc.doc-code = buf_sale-doc.doc-code:
        for each buf_temp-gds no-lock
          where buf_temp-gds.doc-kind = buf_sale-doc.ext-doc-type ,
          first buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_sale-doc.doc-code
          and  buf_doc-line.artic = buf_temp-gds.artic
          and  buf_doc-line.prod-type = buf_temp-gds.prod-type
          and  buf_doc-line.prod-code = buf_temp-gds.prod-code,
          first buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_sale-doc.doc-code
          and  buf_gds-dtl.artic = buf_temp-gds.artic
          and  buf_gds-dtl.prod-type = buf_temp-gds.prod-type
          and  buf_gds-dtl.prod-code = buf_temp-gds.prod-code
          and  buf_gds-dtl.prt-code = buf_temp-gds.node-code
          :
          run gds-attr-value in this-procedure (
            input buf_temp-gds.gds-code
            ,input "cash-book-id"
            ,output mValue
            ,output mType) no-error.
          run gds-attr-value in this-procedure (
            input buf_temp-gds.gds-code
            ,input 'item-matter-mark':U
            ,output mValueVne
            ,output mTypeVne) no-error.
          run gds-attr-value in this-procedure (
            input buf_temp-gds.gds-code
            ,input 'type-method-calc':U
            ,output mValueAvans
            ,output mTypeAvans) no-error.
          find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
          if not available ub.CashBook
            then
          do :
            find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
          end.
          if available ub.CashBook
            then
          do :
            assign
              p-by-cash-desk    = ub.CashBook.FlagSepCash
              p-by-petrol-goods = ub.CashBook.FlagSepFull
              .
          end.
          find first tt-cashbookAttr where tt-cashbookAttr.cashbookid = ub.CashBook.id no-error .
          if not (tt-cashbookAttr.vneCli <> "" and tt-cashbookAttr.vneCorr <> "") then mValueVne = "" .
          if not (tt-cashbookAttr.avansCli <> "" and tt-cashbookAttr.avansCorr <> "") then mValueAvans = "" .
          find first buf_temp-tax where
            buf_temp-tax.curr-code = buf_temp-gds.curr-code
            and buf_temp-tax.vat-pc = buf_doc-line.vat-pc
            and buf_temp-tax.slt-pc = buf_doc-line.slt-pc
            and buf_temp-tax.cash-desk = buf_temp-gds.cash-desk
            and buf_temp-tax.is-petrol = buf_temp-gds.is-petrol
            and buf_temp-tax.cashbookId = (if available ub.CashBook then ub.CashBook.id else 0)
            and buf_temp-tax.is-expense_cash = (buf_temp-gds.tot-doc < 0 and buf_temp-gds.pay-type eq "cash")
            and buf_temp-tax.pay-type = buf_temp-gds.pay-type
            and buf_temp-tax.num-expense_cash = 0
            no-error.
          if not available buf_temp-tax then
          do:
            create buf_temp-tax.
            assign
              buf_temp-tax.curr-code        = buf_temp-gds.curr-code
              buf_temp-tax.vat-pc           = buf_doc-line.vat-pc
              buf_temp-tax.slt-pc           = buf_doc-line.slt-pc
              buf_temp-tax.cash-desk        = (if p-by-cash-desk
                                    then buf_temp-gds.cash-desk
                                    else 0)
              buf_temp-tax.is-petrol        = (if p-by-petrol-goods
                                    then buf_temp-gds.is-petrol
                                    else no)
              buf_temp-tax.cashbookId       = (if available ub.CashBook then ub.CashBook.id else 0)
              buf_temp-tax.is-expense_cash  = (buf_temp-gds.tot-doc < 0 and buf_temp-gds.pay-type eq "cash")
              buf_temp-tax.num-expense_cash = 0
              buf_temp-tax.pay-type         = buf_temp-gds.pay-type
              buf_temp-tax.with-vat         = buf_temp-gds.with-vat
              .
          end.
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
assign
  buf_temp-gds.vat-rubl = buf_temp-gds.eff-doc-qnty * vat-rubl-buyer
  buf_temp-gds.vat-base = buf_temp-gds.eff-doc-qnty  * vat-base-buyer
  buf_temp-gds.vat-doc  = (if buf_temp-gds.curr-code = 0
                                 then buf_temp-gds.eff-doc-qnty * vat-rubl-buyer
                                 else (if buf_temp-gds.curr-code = v-base-code
                                       then buf_temp-gds.eff-doc-qnty * vat-base-buyer
                                       else buf_temp-gds.eff-doc-qnty * vat-rubl-buyer * buf_temp-gds.tot-doc / buf_temp-gds.tot-rubl
                                       )
                                 )
  buf_temp-tax.sum-rubl = buf_temp-tax.sum-rubl + buf_temp-gds.tot-rubl
  buf_temp-tax.sum-base = buf_temp-tax.sum-base + buf_temp-gds.tot-base
  buf_temp-tax.sum-doc  = buf_temp-tax.sum-doc  + buf_temp-gds.tot-doc
  buf_temp-tax.vat-rubl = buf_temp-tax.vat-rubl + buf_temp-gds.vat-rubl
  buf_temp-tax.vat-base = buf_temp-tax.vat-base + buf_temp-gds.vat-base
  buf_temp-tax.vat-doc  = buf_temp-tax.vat-doc  + buf_temp-gds.vat-doc
  .
release buf_temp-tax.
end.
for each buf_temp-gdsVne no-lock
  where buf_temp-gdsVne.doc-kind = buf_sale-doc.ext-doc-type ,
  first buf_doc-line no-lock
  where buf_doc-line.doc-code = buf_sale-doc.doc-code
  and  buf_doc-line.artic = buf_temp-gdsVne.artic
  and  buf_doc-line.prod-type = buf_temp-gdsVne.prod-type
  and  buf_doc-line.prod-code = buf_temp-gdsVne.prod-code,
  first buf_gds-dtl no-lock where
  buf_gds-dtl.doc-code = buf_sale-doc.doc-code
  and  buf_gds-dtl.artic = buf_temp-gdsVne.artic
  and  buf_gds-dtl.prod-type = buf_temp-gdsVne.prod-type
  and  buf_gds-dtl.prod-code = buf_temp-gdsVne.prod-code
  and  buf_gds-dtl.prt-code = buf_temp-gdsVne.node-code
  :
  run gds-attr-value in this-procedure (
    input buf_temp-gdsVne.gds-code
    ,input "cash-book-id"
    ,output mValue
    ,output mType) no-error.
  find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
  if not available ub.CashBook
    then
  do :
    find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
  end.
  if available ub.CashBook
    then
  do :
    assign
      p-by-cash-desk    = ub.CashBook.FlagSepCash
      p-by-petrol-goods = ub.CashBook.FlagSepFull
      .
  end.
  find first buf_temp-taxVne where
    buf_temp-taxVne.curr-code = buf_temp-gdsVne.curr-code
    and buf_temp-taxVne.vat-pc = buf_doc-line.vat-pc
    and buf_temp-taxVne.slt-pc = buf_doc-line.slt-pc
    and buf_temp-taxVne.cash-desk = buf_temp-gdsVne.cash-desk
    and buf_temp-taxVne.is-petrol = buf_temp-gdsVne.is-petrol
    and buf_temp-taxVne.cashbookId = (if available ub.CashBook then ub.CashBook.id else 0)
    and buf_temp-taxVne.is-expense_cash = (buf_temp-gdsVne.tot-doc < 0 and buf_temp-gdsVne.pay-type eq "cash")
    and buf_temp-taxVne.pay-type = buf_temp-gdsVne.pay-type
    and buf_temp-taxVne.num-expense_cash = 0
    no-error.
  if not available buf_temp-taxVne then
  do:
    create buf_temp-taxVne.
    assign
      buf_temp-taxVne.curr-code        = buf_temp-gdsVne.curr-code
      buf_temp-taxVne.vat-pc           = buf_doc-line.vat-pc
      buf_temp-taxVne.slt-pc           = buf_doc-line.slt-pc
      buf_temp-taxVne.cash-desk        = (if p-by-cash-desk
                                    then buf_temp-gdsVne.cash-desk
                                    else 0)
      buf_temp-taxVne.is-petrol        = (if p-by-petrol-goods
                                    then buf_temp-gdsVne.is-petrol
                                    else no)
      buf_temp-taxVne.cashbookId       = (if available ub.CashBook then ub.CashBook.id else 0)
      buf_temp-taxVne.is-expense_cash  = (buf_temp-gdsVne.tot-doc < 0 and buf_temp-gdsVne.pay-type eq "cash")
      buf_temp-taxVne.num-expense_cash = 0
      buf_temp-taxVne.pay-type         = buf_temp-gdsVne.pay-type
      buf_temp-taxVne.with-vat         = buf_temp-gdsVne.with-vat
      .
  end.
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
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
assign
  buf_temp-gdsVne.vat-rubl = buf_temp-gdsVne.eff-doc-qnty * vat-rubl-buyer
  buf_temp-gdsVne.vat-base = buf_temp-gdsVne.eff-doc-qnty  * vat-base-buyer
  buf_temp-gdsVne.vat-doc  = (if buf_temp-gdsVne.curr-code = 0
                                 then buf_temp-gdsVne.eff-doc-qnty * vat-rubl-buyer
                                 else (if buf_temp-gdsVne.curr-code = v-base-code
                                       then buf_temp-gdsVne.eff-doc-qnty * vat-base-buyer
                                       else buf_temp-gdsVne.eff-doc-qnty * vat-rubl-buyer * buf_temp-gdsVne.tot-doc / buf_temp-gds.tot-rubl
                                       )
                                 )
  buf_temp-taxVne.sum-rubl = buf_temp-taxVne.sum-rubl + buf_temp-gdsVne.tot-rubl
  buf_temp-taxVne.sum-base = buf_temp-taxVne.sum-base + buf_temp-gdsVne.tot-base
  buf_temp-taxVne.sum-doc  = buf_temp-taxVne.sum-doc  + buf_temp-gdsVne.tot-doc
  buf_temp-taxVne.vat-rubl = buf_temp-taxVne.vat-rubl + buf_temp-gdsVne.vat-rubl
  buf_temp-taxVne.vat-base = buf_temp-taxVne.vat-base + buf_temp-gdsVne.vat-base
  buf_temp-taxVne.vat-doc  = buf_temp-taxVne.vat-doc  + buf_temp-gdsVne.vat-doc
  .
release buf_temp-taxVne.
end.
for each buf_temp-gdsAvans no-lock
  where buf_temp-gdsAvans.doc-kind = buf_sale-doc.ext-doc-type ,
  first buf_doc-line no-lock
  where buf_doc-line.doc-code = buf_sale-doc.doc-code
  and  buf_doc-line.artic = buf_temp-gdsAvans.artic
  and  buf_doc-line.prod-type = buf_temp-gdsAvans.prod-type
  and  buf_doc-line.prod-code = buf_temp-gdsAvans.prod-code,
  first buf_gds-dtl no-lock where
  buf_gds-dtl.doc-code = buf_sale-doc.doc-code
  and  buf_gds-dtl.artic = buf_temp-gdsAvans.artic
  and  buf_gds-dtl.prod-type = buf_temp-gdsAvans.prod-type
  and  buf_gds-dtl.prod-code = buf_temp-gdsAvans.prod-code
  and  buf_gds-dtl.prt-code = buf_temp-gdsAvans.node-code
  :
  run gds-attr-value in this-procedure (
    input buf_temp-gdsAvans.gds-code
    ,input "cash-book-id"
    ,output mValue
    ,output mType) no-error.
  find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
  if not available ub.CashBook
    then
  do :
    find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
  end.
  if available ub.CashBook
    then
  do :
    assign
      p-by-cash-desk    = ub.CashBook.FlagSepCash
      p-by-petrol-goods = ub.CashBook.FlagSepFull
      .
  end.
  find first buf_temp-taxAvans where
    buf_temp-taxAvans.curr-code = buf_temp-gdsAvans.curr-code
    and buf_temp-taxAvans.vat-pc = buf_doc-line.vat-pc
    and buf_temp-taxAvans.slt-pc = buf_doc-line.slt-pc
    and buf_temp-taxAvans.cash-desk = buf_temp-gdsAvans.cash-desk
    and buf_temp-taxAvans.is-petrol = buf_temp-gdsAvans.is-petrol
    and buf_temp-taxAvans.cashbookId = (if available ub.CashBook then ub.CashBook.id else 0)
    and buf_temp-taxAvans.is-expense_cash = (buf_temp-gdsAvans.tot-doc < 0 and buf_temp-gdsAvans.pay-type eq "cash")
    and buf_temp-taxAvans.pay-type = buf_temp-gdsAvans.pay-type
    and buf_temp-taxAvans.num-expense_cash = 0
    no-error.
  if not available buf_temp-taxAvans then
  do:
    create buf_temp-taxAvans.
    assign
      buf_temp-taxAvans.curr-code        = buf_temp-gdsAvans.curr-code
      buf_temp-taxAvans.vat-pc           = buf_doc-line.vat-pc
      buf_temp-taxAvans.slt-pc           = buf_doc-line.slt-pc
      buf_temp-taxAvans.cash-desk        = (if p-by-cash-desk
                                    then buf_temp-gdsAvans.cash-desk
                                    else 0)
      buf_temp-taxAvans.is-petrol        = (if p-by-petrol-goods
                                    then buf_temp-gdsAvans.is-petrol
                                    else no)
      buf_temp-taxAvans.cashbookId       = (if available ub.CashBook then ub.CashBook.id else 0)
      buf_temp-taxAvans.is-expense_cash  = (buf_temp-gdsAvans.tot-doc < 0 and buf_temp-gdsAvans.pay-type eq "cash")
      buf_temp-taxAvans.num-expense_cash = 0
      buf_temp-taxAvans.pay-type         = buf_temp-gdsAvans.pay-type
      buf_temp-taxAvans.with-vat         = buf_temp-gdsAvans.with-vat
      .
  end.
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
assign
  buf_temp-gdsAvans.vat-rubl = buf_temp-gdsAvans.eff-doc-qnty * vat-rubl-buyer
  buf_temp-gdsAvans.vat-base = buf_temp-gdsAvans.eff-doc-qnty  * vat-base-buyer
  buf_temp-gdsAvans.vat-doc  = (if buf_temp-gdsAvans.curr-code = 0
                                 then buf_temp-gdsAvans.eff-doc-qnty * vat-rubl-buyer
                                 else (if buf_temp-gdsAvans.curr-code = v-base-code
                                       then buf_temp-gdsAvans.eff-doc-qnty * vat-base-buyer
                                       else buf_temp-gdsAvans.eff-doc-qnty * vat-rubl-buyer * buf_temp-gdsAvans.tot-doc / buf_temp-gds.tot-rubl
                                       )
                                 )
  buf_temp-taxAvans.sum-rubl = buf_temp-taxAvans.sum-rubl + buf_temp-gdsAvans.tot-rubl
  buf_temp-taxAvans.sum-base = buf_temp-taxAvans.sum-base + buf_temp-gdsAvans.tot-base
  buf_temp-taxAvans.sum-doc  = buf_temp-taxAvans.sum-doc  + buf_temp-gdsAvans.tot-doc
  buf_temp-taxAvans.vat-rubl = buf_temp-taxAvans.vat-rubl + buf_temp-gdsAvans.vat-rubl
  buf_temp-taxAvans.vat-base = buf_temp-taxAvans.vat-base + buf_temp-gdsAvans.vat-base
  buf_temp-taxAvans.vat-doc  = buf_temp-taxAvans.vat-doc  + buf_temp-gdsAvans.vat-doc
  .
release buf_temp-taxAvans.
end.
end.
assign
  v-real-obj-type = buf_trn-doc.cli-type
  v-real-obj-code = buf_trn-doc.cli-code
  .
empty temp-table temp-gds.
empty temp-table temp-gdsVne.
empty temp-table temp-gdsAvans.
end.
define variable Fact-order as decimal no-undo.
define buffer tt-cashBookOst0           for tt-cashBookOst.
define buffer buf_new_temp-fin-sum      for temp-fin-sum.
define buffer tt-cashBookOst0Vne        for tt-cashBookOstVne.
define buffer buf_new_temp-fin-sumVne   for temp-fin-sumVne.
define buffer tt-cashBookOst0Avans      for tt-cashBookOstAvans.
define buffer buf_new_temp-fin-sumAvans for temp-fin-sumAvans.
define variable mNumDoc as integer no-undo.
find first tt-cashBookOst0 where tt-cashBookOst0.cashbookid eq 0
  no-error.
if not available tt-cashBookOst
  then
do:
  create tt-cashBookOst0.
  tt-cashBookOst0.cashbookid =  0.
  run fostatok in this-procedure (
    input   v-host-code
    ,input   buf_shift-obj.obj-code
    ,input   buf_shift-obj.obj-type
    ,input   yes
    ,input   buf_shift-obj.close-date - 1
    ,input   date('')
    ,input   buf_shift-obj.shift-num
    ,input   buf_shift-obj.shift-num
    ,input   yes
    ,input   0
    ,input   0
    ,output  tt-cashBookOst0.ost
    ,output  Fact-order)
    no-error .
end.
find first buf_temp-fin-sum-Pko where buf_temp-fin-sum-Pko.num-expense_cash eq 0
  and buf_temp-fin-sum-Pko.is-expense_cash eq no
  and buf_temp-fin-sum-Pko.cashbookid      eq 0
  no-lock no-error.
if available buf_temp-fin-sum-Pko
  then
  tt-cashBookOst0.ost = tt-cashBookOst0.ost + buf_temp-fin-sum-Pko.tot-sum.
for each buf_temp-fin-sum where  buf_temp-fin-sum.num-expense_cash eq 0
  and  buf_temp-fin-sum.is-expense_cash  eq yes
  and  buf_temp-fin-sum.cashbookid  ne 0
  :
  find first tt-cashBookOst where tt-cashBookOst.cashbookid eq buf_temp-fin-sum.cashbookid
    no-error.
  if not available tt-cashBookOst
    then
  do:
    create tt-cashBookOst.
    tt-cashBookOst.cashbookid =  buf_temp-fin-sum.cashbookid.
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_shift-obj.obj-code
      ,input   buf_shift-obj.obj-type
      ,input   yes
      ,input   buf_shift-obj.close-date - 1
      ,input   date('')
      ,input   buf_shift-obj.shift-num
      ,input   buf_shift-obj.shift-num
      ,input   yes
      ,input   0
      ,input   buf_temp-fin-sum.cashbookid
      ,output  tt-cashBookOst.ost
      ,output  Fact-order)
      no-error .
    find first buf_temp-fin-sum-Pko where buf_temp-fin-sum-Pko.num-expense_cash eq 0
      and buf_temp-fin-sum-Pko.is-expense_cash eq (not buf_temp-fin-sum.is-expense_cash)
      and buf_temp-fin-sum-Pko.cash-desk       eq buf_temp-fin-sum.cash-desk
      and buf_temp-fin-sum-Pko.curr-code       eq buf_temp-fin-sum.curr-code
      and buf_temp-fin-sum-Pko.cashbookid      eq buf_temp-fin-sum.cashbookid
      no-lock no-error.
    if available buf_temp-fin-sum-Pko
      then
      tt-cashBookOst.ost = tt-cashBookOst.ost + buf_temp-fin-sum-Pko.tot-sum.
  end.
  msum = tt-cashBookOst.ost + buf_temp-fin-sum.tot-sum. //остаток положительный а  buf_temp-fin-sum.tot-sum отрицательный
  if msum < 0
    then
  do:
    tt-cashBookOst.ost = 0.
    if tt-cashBookOst0.ost + msum > 0
      then
    do:
      create buf_new_temp-fin-sum.
      buffer-copy buf_temp-fin-sum except cashbookid to  buf_new_temp-fin-sum
        assign
        mNumDoc = mNumDoc + 1
        buf_new_temp-fin-sum.cashbookid       = 0
        buf_new_temp-fin-sum.contr-kb         = buf_temp-fin-sum.cashbookid
        buf_new_temp-fin-sum.num-expense_cash = mNumDoc
        buf_new_temp-fin-sum.tot-sum          = msum
        buf_new_temp-fin-sum.tot-base         = msum
        buf_new_temp-fin-sum.tot-rubl         = msum
        buf_new_temp-fin-sum.pay-type         = "trans"
        tt-cashBookOst0.ost                   = tt-cashBookOst0.ost + msum.
      .
      create buf_temp-tax.
      assign
        buf_temp-tax.curr-code        = buf_new_temp-fin-sum.curr-code
        buf_temp-tax.cash-desk        = buf_new_temp-fin-sum.cash-desk
        buf_temp-tax.is-petrol        = buf_new_temp-fin-sum.is-petrol
        buf_temp-tax.cashbookId       = buf_new_temp-fin-sum.cashbookid
        buf_temp-tax.is-expense_cash  = buf_new_temp-fin-sum.is-expense_cash
        buf_temp-tax.num-expense_cash = buf_new_temp-fin-sum.num-expense_cash
        buf_temp-tax.pay-type         = buf_new_temp-fin-sum.pay-type
        buf_temp-tax.sum-rubl         = msum
        buf_temp-tax.sum-base         = msum
        buf_temp-tax.sum-doc          = msum
        .
      create buf_new_temp-fin-sum.
      buffer-copy buf_temp-fin-sum to  buf_new_temp-fin-sum
        assign
        mNumDoc = mNumDoc + 1
        msum                                  = -1 * msum
        buf_new_temp-fin-sum.tot-sum          = msum
        buf_new_temp-fin-sum.num-expense_cash = mNumDoc
        buf_new_temp-fin-sum.tot-base         = msum
        buf_new_temp-fin-sum.tot-rubl         = msum
        buf_new_temp-fin-sum.is-expense_cash  = no
        buf_new_temp-fin-sum.contr-kb         = 0
        buf_new_temp-fin-sum.pay-type         = "trans"
        .
      create buf_temp-tax.
      assign
        buf_temp-tax.curr-code        = buf_new_temp-fin-sum.curr-code
        buf_temp-tax.cash-desk        = buf_new_temp-fin-sum.cash-desk
        buf_temp-tax.is-petrol        = buf_new_temp-fin-sum.is-petrol
        buf_temp-tax.cashbookId       = buf_new_temp-fin-sum.cashbookid
        buf_temp-tax.is-expense_cash  = buf_new_temp-fin-sum.is-expense_cash
        buf_temp-tax.num-expense_cash = buf_new_temp-fin-sum.num-expense_cash
        buf_temp-tax.pay-type         = buf_new_temp-fin-sum.pay-type
        buf_temp-tax.sum-rubl         = msum
        buf_temp-tax.sum-base         = msum
        buf_temp-tax.sum-doc          = msum
        .
    end.
    else
    do:
                                    if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не возможно создать &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8 на кассой книге № 0 не достаточно средств."                                   , entry (lookup ((if buf_temp-fin-sum.tot-sum > 0 then 'пко':U else 'рко':U), 'пко,рко,ппп,рпп,апп,апр':U) + 1, ',':U + 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,приходный АПЗ,расходный АПЗ':U)                                    , buf_shift-obj.shift-name                                   , buf_shift-obj.shift-date                                   , buf_shift-obj.shift-nuM                                      , buf_shift-obj.obj-type                                   , buf_shift-obj.obj-code                                   , buf_temp-fin-sum.cashbookid                                   , abs(buf_temp-fin-sum.tot-sum)                                   , chr(10)                                   )).
             delete  buf_temp-fin-sum.
    end.
  end.
  else
    tt-cashBookOst.ost = msum.
end.
find first tt-cashBookOst0Vne where tt-cashBookOst0Vne.cashbookid eq 0
  no-error.
if not available tt-cashBookOstVne
  then
do:
  find first temp-fin-sumVne no-error .
  if available (temp-fin-sumVne) then
  do:
    create tt-cashBookOst0Vne.
    tt-cashBookOst0Vne.cashbookid =  0.
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_shift-obj.obj-code
      ,input   buf_shift-obj.obj-type
      ,input   yes
      ,input   buf_shift-obj.close-date - 1
      ,input   date('')
      ,input   buf_shift-obj.shift-num
      ,input   buf_shift-obj.shift-num
      ,input   yes
      ,input   0
      ,input   0
      ,output  tt-cashBookOst0Vne.ost
      ,output  Fact-order)
      no-error .
  end.
end.
find first buf_temp-fin-sumVne-Pko where buf_temp-fin-sumVne-Pko.num-expense_cash eq 0
  and buf_temp-fin-sumVne-Pko.is-expense_cash eq no
  and buf_temp-fin-sumVne-Pko.cashbookid      eq 0
  no-lock no-error.
if available buf_temp-fin-sumVne-Pko
  then
  tt-cashBookOst0Vne.ost = tt-cashBookOst0Vne.ost + buf_temp-fin-sumVne-Pko.tot-sum.
for each buf_temp-fin-sumVne where  buf_temp-fin-sumVne.num-expense_cash eq 0
  and  buf_temp-fin-sumVne.is-expense_cash  eq yes
  and  buf_temp-fin-sumVne.cashbookid  ne 0
  :
  find first tt-cashBookOstVne where tt-cashBookOstVne.cashbookid eq buf_temp-fin-sumVne.cashbookid
    no-error.
  if not available tt-cashBookOstVne
    then
  do:
    create tt-cashBookOstVne.
    tt-cashBookOstVne.cashbookid =  buf_temp-fin-sumVne.cashbookid.
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_shift-obj.obj-code
      ,input   buf_shift-obj.obj-type
      ,input   yes
      ,input   buf_shift-obj.close-date - 1
      ,input   date('')
      ,input   buf_shift-obj.shift-num
      ,input   buf_shift-obj.shift-num
      ,input   yes
      ,input   0
      ,input   buf_temp-fin-sumVne.cashbookid
      ,output  tt-cashBookOstVne.ost
      ,output  Fact-order)
      no-error .
    find first buf_temp-fin-sumVne-Pko where buf_temp-fin-sumVne-Pko.num-expense_cash eq 0
      and buf_temp-fin-sumVne-Pko.is-expense_cash eq (not buf_temp-fin-sumVne.is-expense_cash)
      and buf_temp-fin-sumVne-Pko.cash-desk       eq buf_temp-fin-sumVne.cash-desk
      and buf_temp-fin-sumVne-Pko.curr-code       eq buf_temp-fin-sumVne.curr-code
      and buf_temp-fin-sumVne-Pko.cashbookid      eq buf_temp-fin-sumVne.cashbookid
      no-lock no-error.
    if available buf_temp-fin-sumVne-Pko
      then
      tt-cashBookOstVne.ost = tt-cashBookOstVne.ost + buf_temp-fin-sumVne-Pko.tot-sum.
  end.
  msum = tt-cashBookOstVne.ost + buf_temp-fin-sumVne.tot-sum. //остаток положительный а  buf_temp-fin-sum.tot-sum отрицательный
  if msum < 0
    then
  do:
    tt-cashBookOstVne.ost = 0.
    if tt-cashBookOst0Vne.ost + msum > 0
      then
    do:
      create buf_new_temp-fin-sumVne.
      buffer-copy buf_temp-fin-sumVne except cashbookid to  buf_new_temp-fin-sumVne
        assign
        mNumDoc = mNumDoc + 1
        buf_new_temp-fin-sumVne.cashbookid       = 0
        buf_new_temp-fin-sumVne.contr-kb         = buf_temp-fin-sumVne.cashbookid
        buf_new_temp-fin-sumVne.num-expense_cash = mNumDoc
        buf_new_temp-fin-sumVne.tot-sum          = msum
        buf_new_temp-fin-sumVne.tot-base         = msum
        buf_new_temp-fin-sumVne.tot-rubl         = msum
        buf_new_temp-fin-sumVne.pay-type         = "trans"
        tt-cashBookOst0Vne.ost                   = tt-cashBookOst0Vne.ost + msum.
      .
      create buf_temp-taxVne.
      assign
        buf_temp-taxVne.curr-code        = buf_new_temp-fin-sumVne.curr-code
        buf_temp-taxVne.cash-desk        = buf_new_temp-fin-sumVne.cash-desk
        buf_temp-taxVne.is-petrol        = buf_new_temp-fin-sumVne.is-petrol
        buf_temp-taxVne.cashbookId       = buf_new_temp-fin-sumVne.cashbookid
        buf_temp-taxVne.is-expense_cash  = buf_new_temp-fin-sumVne.is-expense_cash
        buf_temp-taxVne.num-expense_cash = buf_new_temp-fin-sumVne.num-expense_cash
        buf_temp-taxVne.pay-type         = buf_new_temp-fin-sumVne.pay-type
        buf_temp-taxVne.sum-rubl         = msum
        buf_temp-taxVne.sum-base         = msum
        buf_temp-taxVne.sum-doc          = msum
        .
      create buf_new_temp-fin-sumVne.
      buffer-copy buf_temp-fin-sumVne to  buf_new_temp-fin-sumVne
        assign
        mNumDoc = mNumDoc + 1
        msum                                  = -1 * msum
        buf_new_temp-fin-sumVne.tot-sum          = msum
        buf_new_temp-fin-sumVne.num-expense_cash = mNumDoc
        buf_new_temp-fin-sumVne.tot-base         = msum
        buf_new_temp-fin-sumVne.tot-rubl         = msum
        buf_new_temp-fin-sumVne.is-expense_cash  = no
        buf_new_temp-fin-sumVne.contr-kb         = 0
        buf_new_temp-fin-sumVne.pay-type         = "trans"
        .
      create buf_temp-taxVne.
      assign
        buf_temp-taxVne.curr-code        = buf_new_temp-fin-sumVne.curr-code
        buf_temp-taxVne.cash-desk        = buf_new_temp-fin-sumVne.cash-desk
        buf_temp-taxVne.is-petrol        = buf_new_temp-fin-sumVne.is-petrol
        buf_temp-taxVne.cashbookId       = buf_new_temp-fin-sumVne.cashbookid
        buf_temp-taxVne.is-expense_cash  = buf_new_temp-fin-sumVne.is-expense_cash
        buf_temp-taxVne.num-expense_cash = buf_new_temp-fin-sumVne.num-expense_cash
        buf_temp-taxVne.pay-type         = buf_new_temp-fin-sumVne.pay-type
        buf_temp-taxVne.sum-rubl         = msum
        buf_temp-taxVne.sum-base         = msum
        buf_temp-taxVne.sum-doc          = msum
        buf_temp-taxVne.vat-pc           = -1
        .
    end.
    else
    do:
                                    if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не возможно создать &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8 на кассой книге № 0 не достаточно средств."                                   , entry (lookup ((if buf_temp-fin-sumVne.tot-sum > 0 then 'пко':U else 'рко':U), 'пко,рко,ппп,рпп,апп,апр':U) + 1, ',':U + 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,приходный АПЗ,расходный АПЗ':U)                                    , buf_shift-obj.shift-name                                   , buf_shift-obj.shift-date                                   , buf_shift-obj.shift-nuM                                      , buf_shift-obj.obj-type                                   , buf_shift-obj.obj-code                                   , buf_temp-fin-sumVne.cashbookid                                   , abs(buf_temp-fin-sumVne.tot-sum)                                   , chr(10)                                   )).
             delete  buf_temp-fin-sumVne.
    end.
  end.
  else
    tt-cashBookOstVne.ost = msum.
end.
find first tt-cashBookOst0Avans where tt-cashBookOst0Avans.cashbookid eq 0
  no-error.
if not available tt-cashBookOstAvans
  then
do:
  find first temp-fin-sumAvans no-error .
  if available (temp-fin-sumAvans) then
  do:
    create tt-cashBookOst0Avans.
    tt-cashBookOst0Avans.cashbookid =  0.
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_shift-obj.obj-code
      ,input   buf_shift-obj.obj-type
      ,input   yes
      ,input   buf_shift-obj.close-date - 1
      ,input   date('')
      ,input   buf_shift-obj.shift-num
      ,input   buf_shift-obj.shift-num
      ,input   yes
      ,input   0
      ,input   0
      ,output  tt-cashBookOst0Avans.ost
      ,output  Fact-order)
      no-error .
  end.
end.
find first buf_temp-fin-sumAvans-Pko where buf_temp-fin-sumAvans-Pko.num-expense_cash eq 0
  and buf_temp-fin-sumAvans-Pko.is-expense_cash eq no
  and buf_temp-fin-sumAvans-Pko.cashbookid      eq 0
  no-lock no-error.
if available buf_temp-fin-sumAvans-Pko
  then
  tt-cashBookOst0Avans.ost = tt-cashBookOst0Avans.ost + buf_temp-fin-sumAvans-Pko.tot-sum.
for each buf_temp-fin-sumAvans where  buf_temp-fin-sumAvans.num-expense_cash eq 0
  and  buf_temp-fin-sumAvans.is-expense_cash  eq yes
  and  buf_temp-fin-sumAvans.cashbookid  ne 0
  :
  find first tt-cashBookOstAvans where tt-cashBookOstAvans.cashbookid eq buf_temp-fin-sumAvans.cashbookid
    no-error.
  if not available tt-cashBookOstAvans
    then
  do:
    create tt-cashBookOstAvans.
    tt-cashBookOstAvans.cashbookid =  buf_temp-fin-sumAvans.cashbookid.
    run fostatok in this-procedure (
      input   v-host-code
      ,input   buf_shift-obj.obj-code
      ,input   buf_shift-obj.obj-type
      ,input   yes
      ,input   buf_shift-obj.close-date - 1
      ,input   date('')
      ,input   buf_shift-obj.shift-num
      ,input   buf_shift-obj.shift-num
      ,input   yes
      ,input   0
      ,input   buf_temp-fin-sumAvans.cashbookid
      ,output  tt-cashBookOstAvans.ost
      ,output  Fact-order)
      no-error .
    find first buf_temp-fin-sumAvans-Pko where buf_temp-fin-sumAvans-Pko.num-expense_cash eq 0
      and buf_temp-fin-sumAvans-Pko.is-expense_cash eq (not buf_temp-fin-sumAvans.is-expense_cash)
      and buf_temp-fin-sumAvans-Pko.cash-desk       eq buf_temp-fin-sumAvans.cash-desk
      and buf_temp-fin-sumAvans-Pko.curr-code       eq buf_temp-fin-sumAvans.curr-code
      and buf_temp-fin-sumAvans-Pko.cashbookid      eq buf_temp-fin-sumAvans.cashbookid
      no-lock no-error.
    if available buf_temp-fin-sumAvans-Pko
      then
      tt-cashBookOstAvans.ost = tt-cashBookOstAvans.ost + buf_temp-fin-sumAvans-Pko.tot-sum.
  end.
  msum = tt-cashBookOstAvans.ost + buf_temp-fin-sumAvans.tot-sum. //остаток положительный а  buf_temp-fin-sum.tot-sum отрицательный
  if msum < 0
    then
  do:
    tt-cashBookOstAvans.ost = 0.
    if tt-cashBookOst0Avans.ost + msum > 0
      then
    do:
      create buf_new_temp-fin-sumAvans.
      buffer-copy buf_temp-fin-sumAvans except cashbookid to  buf_new_temp-fin-sumAvans
        assign
        mNumDoc = mNumDoc + 1
        buf_new_temp-fin-sumAvans.cashbookid       = 0
        buf_new_temp-fin-sumAvans.contr-kb         = buf_temp-fin-sumAvans.cashbookid
        buf_new_temp-fin-sumAvans.num-expense_cash = mNumDoc
        buf_new_temp-fin-sumAvans.tot-sum          = msum
        buf_new_temp-fin-sumAvans.tot-base         = msum
        buf_new_temp-fin-sumAvans.tot-rubl         = msum
        buf_new_temp-fin-sumAvans.pay-type         = "trans"
        tt-cashBookOst0Avans.ost                   = tt-cashBookOst0Avans.ost + msum.
      .
      create buf_temp-taxAvans.
      assign
        buf_temp-taxAvans.curr-code        = buf_new_temp-fin-sumAvans.curr-code
        buf_temp-taxAvans.cash-desk        = buf_new_temp-fin-sumAvans.cash-desk
        buf_temp-taxAvans.is-petrol        = buf_new_temp-fin-sumAvans.is-petrol
        buf_temp-taxAvans.cashbookId       = buf_new_temp-fin-sumAvans.cashbookid
        buf_temp-taxAvans.is-expense_cash  = buf_new_temp-fin-sumAvans.is-expense_cash
        buf_temp-taxAvans.num-expense_cash = buf_new_temp-fin-sumAvans.num-expense_cash
        buf_temp-taxAvans.pay-type         = buf_new_temp-fin-sumAvans.pay-type
        buf_temp-taxAvans.sum-rubl         = msum
        buf_temp-taxAvans.sum-base         = msum
        buf_temp-taxAvans.sum-doc          = msum
        .
      create buf_new_temp-fin-sumAvans.
      buffer-copy buf_temp-fin-sumAvans to  buf_new_temp-fin-sumAvans
        assign
        mNumDoc = mNumDoc + 1
        msum                                  = -1 * msum
        buf_new_temp-fin-sumAvans.tot-sum          = msum
        buf_new_temp-fin-sumAvans.num-expense_cash = mNumDoc
        buf_new_temp-fin-sumAvans.tot-base         = msum
        buf_new_temp-fin-sumAvans.tot-rubl         = msum
        buf_new_temp-fin-sumAvans.is-expense_cash  = no
        buf_new_temp-fin-sumAvans.contr-kb         = 0
        buf_new_temp-fin-sumAvans.pay-type         = "trans"
        .
      create buf_temp-taxAvans.
      assign
        buf_temp-taxAvans.curr-code        = buf_new_temp-fin-sumAvans.curr-code
        buf_temp-taxAvans.cash-desk        = buf_new_temp-fin-sumAvans.cash-desk
        buf_temp-taxAvans.is-petrol        = buf_new_temp-fin-sumAvans.is-petrol
        buf_temp-taxAvans.cashbookId       = buf_new_temp-fin-sumAvans.cashbookid
        buf_temp-taxAvans.is-expense_cash  = buf_new_temp-fin-sumAvans.is-expense_cash
        buf_temp-taxAvans.num-expense_cash = buf_new_temp-fin-sumAvans.num-expense_cash
        buf_temp-taxAvans.pay-type         = buf_new_temp-fin-sumAvans.pay-type
        buf_temp-taxAvans.sum-rubl         = msum
        buf_temp-taxAvans.sum-base         = msum
        buf_temp-taxAvans.sum-doc          = msum
        .
    end.
    else
    do:
                                    if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не возможно создать &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8 на кассой книге № 0 не достаточно средств."                                   , entry (lookup ((if buf_temp-fin-sumAvans.tot-sum > 0 then 'пко':U else 'рко':U), 'пко,рко,ппп,рпп,апп,апр':U) + 1, ',':U + 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,приходный АПЗ,расходный АПЗ':U)                                    , buf_shift-obj.shift-name                                   , buf_shift-obj.shift-date                                   , buf_shift-obj.shift-nuM                                      , buf_shift-obj.obj-type                                   , buf_shift-obj.obj-code                                   , buf_temp-fin-sumAvans.cashbookid                                   , abs(buf_temp-fin-sumAvans.tot-sum)                                   , chr(10)                                   )).
             delete  buf_temp-fin-sumAvans.
    end.
  end.
  else
    tt-cashBookOstAvans.ost = msum.
end.
for each temp-z-number
  break
  by temp-z-number.cash-desk
  :
  if first-of( temp-z-number.cash-desk) then
  do:
    find first temp-z-number-list
      where temp-z-number-list.cash-desk = temp-z-number.cash-desk no-error.
    if not available temp-z-number-list then
    do:
      create temp-z-number-list.
      assign
        temp-z-number-list.cash-desk = temp-z-number.cash-desk
        .
    end.
  end.
  assign
    v-naznach-plat                  = v-naznach-plat + (if v-naznach-plat = '' then '' else chr(44)) + string(temp-z-number.z-number)
    temp-z-number-list.naznach-plat = temp-z-number-list.naznach-plat + (if temp-z-number-list.naznach-plat = '' then '' else chr(44)) + string(temp-z-number.z-number)
    .
end.
v-naznach-plat = substitute("Z-отчет(ы) &1 от &2г.", v-naznach-plat, if v-uchet = "smen" then string(buf_shift-obj.shift-date, "99/99/99") else string(TODAY, "99/99/99")).
for each temp-z-number-list:
  assign
    temp-z-number-list.naznach-plat = substitute("Z-отчет(ы) &1 от &2г.", temp-z-number-list.naznach-plat, if v-uchet = "smen" then string(buf_shift-obj.shift-date, "99/99/99") else string(TODAY, "99/99/99")).
end.
v-naznach-plat2 = v-naznach-plat .
define variable v-real-obj-type-save as character no-undo.
define variable v-real-obj-code-save as integer   no-undo.
define variable mosnacct             as character no-undo.
define variable mdopacct             as character no-undo.
define variable mpayer-name          as character no-undo.
define variable mreceiver-name       as character no-undo.
_temp-fin-sum:
for each buf_temp-fin-sum no-lock
  by buf_temp-fin-sum.tot-sum descending
  on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
  on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
  :
  empty temp-table tt0-fin-doc-tax.
  empty temp-table tt0-fin-doc-attr.
  empty temp-table tt-fin-doc.
  if buf_temp-fin-sum.tot-sum = 0  then
  do:
    next _temp-fin-sum.
  end.
  v-naznach-plat = v-naznach-plat2 .
  find first ub.CashBook no-lock where ub.CashBook.id = buf_temp-fin-sum.cashbookid no-error .
  if not available ub.CashBook
    then
  do :
    find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
  end.
  assign
    mreceiver-name = ""
    mpayer-name    = ""
    .
  if     buf_temp-fin-sum.pay-type eq "cash"
    and buf_temp-fin-sum.tot-sum < 0
    then
  do:
    assign
      v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "CountCash-type"  )
      v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "CountCash-code"  ))
      mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "rule-payer-rko"  )
      p-by-osnovanie       = ub.CashBook.RuleOsnRko
      mosnacct             = ub.CashBook.OsnAcct
      mdopacct             = ub.CashBook.CorrRko
      .
  end.
  else if     buf_temp-fin-sum.pay-type eq "trans"
      then
    do:
      assign
        p-by-osnovanie       = "Перемещение денежных средств"
        v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "contr-type-transf"  )
        v-real-obj-code-save = int(mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "contr-code-transf"  ))
        p-by-osnovanie       = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "rule-osn-transf")
        mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "rule-payer-transf"  )
        when buf_temp-fin-sum.tot-sum < 0
        mpayer-name          = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "rule-payer-transf"  )
        when buf_temp-fin-sum.tot-sum > 0
        mosnacct             = ub.CashBook.OsnAcct
        mdopacct             = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0, "Corr-transf")
         //mcredit              = if  buf_temp-fin-sum.tot-sum < 0 then mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, {&by_all}, 0, "Corr-transf") else ub.CashBook.OsnAcct
        .
      if p-by-osnovanie       = ""
        then
        p-by-osnovanie       = "Перемещение денежных средств".
    end.
    else if buf_temp-fin-sum.tot-sum > 0
        then
      do:
        assign
          p-by-osnovanie       = ub.CashBook.RuleOsnPko
          v-real-obj-type-save = ub.CashBook.cli-type
          v-real-obj-code-save = ub.CashBook.cli-code
          mdopacct             = ub.CashBook.CorrPko
          mosnacct             = ub.CashBook.OsnAcct
          mpayer-name          = ub.CashBook.takenfrom
          .
        if mpayer-name eq "" or mpayer-name eq ?
          then
        do:
          find first ub.clients no-lock where ub.clients.obj-type = ub.CashBook.cli-type
            and ub.clients.obj-code = ub.CashBook.cli-code
            no-error .
          if available ub.clients
            then
            mpayer-name = ub.clients.obj-name .
        end.
      end.
      else
        assign
          p-by-osnovanie       = ub.CashBook.RuleOsnRko
          v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "CountCash-type"  )
          v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "CountCash-code"  ))
          mosnacct             = ub.CashBook.OsnAcct
          mdopacct             = ub.CashBook.CorrRko
          mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sum.cashbookid, 'всем':U, 0,  "rule-payer-rko"  )
          .
  define variable v-doc-rec as recid no-undo .
  if buf_temp-fin-sum.tot-sum > 0  then
  do:
    run ref/finfnoco.p (
      INPUT parParentProc
      ,INPUT ?
      ,input v-host-code
      ,input ('ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U)
      ,input v-host-code
      ,input v-doc-rec
      ,input 0
      ,input 'пко':U
      ,input 'пко':U
      ,input buf_shift-obj.obj-type
      ,input buf_shift-obj.obj-code
      ,input 0
      ,input ''
      ,input  v-real-obj-type-save
      ,input  v-real-obj-code-save
      ,input 0
      ,input 'орг':U
      ,input v-host-code
      ,input 0
      ,input buf_temp-fin-sum.curr-code
      ,input 0
      ,input 0
      ,input 0
      ,input 0
      ,input buf_temp-fin-sum.cashbookid
      ,input ""
      ,INPUT-OUTPUT table tt-fin-doc
      ,INPUT-OUTPUT table ttc-fin-doc
      ,output table tt0-fin-doc-attr
      ,output v-limit-access ) no-error .
  end.
  else
  do:
    run ref/finfnoco.p (
      INPUT parParentProc
      ,INPUT ?
      ,input v-host-code
      ,input ('ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U)
      ,input v-host-code
      ,input v-doc-rec
      ,input 0
      ,input 'рко':U
      ,input 'рко':U
      ,input buf_shift-obj.obj-type
      ,input buf_shift-obj.obj-code
      ,input 0
      ,input ''
      ,input 'орг':U
      ,input v-host-code
      ,input 0
      ,input  v-real-obj-type-save
      ,input v-real-obj-code-save
      ,input 0
      ,input buf_temp-fin-sum.curr-code
      ,input 0
      ,input 0
      ,input 0
      ,input 0
      ,input buf_temp-fin-sum.cashbookid
      ,input ""
      ,INPUT-OUTPUT table tt-fin-doc
      ,INPUT-OUTPUT table ttc-fin-doc
      ,output table tt0-fin-doc-attr
      ,output v-limit-access ) no-error .
  end.
  if error-status:error then
  do:
            if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при заполнении фин.док-та значениями по умолчанию:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
    undo _main, return error.
  end.
  find first tt-fin-doc.
  define variable v-line-num as integer no-undo .
  for each buf_temp-tax no-lock
    where buf_temp-tax.curr-code        = buf_temp-fin-sum.curr-code
    and buf_temp-tax.cash-desk         = buf_temp-fin-sum.cash-desk
    and buf_temp-tax.is-petrol        = buf_temp-fin-sum.is-petrol
    and buf_temp-tax.cashbookId       = buf_temp-fin-sum.cashbookId
    and buf_temp-tax.is-expense_cash  = buf_temp-fin-sum.is-expense_cash
    and buf_temp-tax.num-expense_cash = buf_temp-fin-sum.num-expense_cash
    and buf_temp-tax.pay-type = buf_temp-fin-sum.pay-type
    :
    v-line-num = v-line-num + 1.
    create tt0-fin-doc-tax .
    assign
      tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
      tt0-fin-doc-tax.host-code          = tt-fin-doc.host-code
      tt0-fin-doc-tax.line-num           = v-line-num
      tt0-fin-doc-tax.VAT-pc             = buf_temp-tax.vat-pc
      tt0-fin-doc-tax.slt-pc             = buf_temp-tax.slt-pc
      tt0-fin-doc-tax.sum-line-contr     = 0
      tt0-fin-doc-tax.sum-vat-line-contr = 0
      tt0-fin-doc-tax.with-vat           = buf_temp-tax.with-vat
      .
    if buf_temp-fin-sum.tot-sum > 0  then
    do :
      assign
        tt0-fin-doc-tax.sum-line-doc      = buf_temp-tax.sum-doc
        tt0-fin-doc-tax.sum-vat-line-doc  = buf_temp-tax.vat-doc
        tt0-fin-doc-tax.sum-line-rubl     = buf_temp-tax.sum-rubl
        tt0-fin-doc-tax.sum-vat-line-rubl = buf_temp-tax.vat-rubl
        tt0-fin-doc-tax.sum-line-base     = buf_temp-tax.sum-base
        tt0-fin-doc-tax.sum-vat-line-base = buf_temp-tax.vat-base
        .
    end.
    else
    do :
      assign
        tt0-fin-doc-tax.sum-line-doc      = abs(buf_temp-tax.sum-doc)
        tt0-fin-doc-tax.sum-vat-line-doc  = abs(buf_temp-tax.vat-doc)
        tt0-fin-doc-tax.sum-line-rubl     = abs(buf_temp-tax.sum-rubl)
        tt0-fin-doc-tax.sum-vat-line-rubl = abs(buf_temp-tax.vat-rubl)
        tt0-fin-doc-tax.sum-line-base     = abs(buf_temp-tax.sum-base)
        tt0-fin-doc-tax.sum-vat-line-base = abs(buf_temp-tax.vat-base)
        .
    end.
    find first temp-autotank no-lock
      where temp-autotank.curr-code = buf_temp-tax.curr-code
      and temp-autotank.pay-desk = buf_temp-tax.cash-desk
      and temp-autotank.is-petrol = buf_temp-tax.is-petrol
      and temp-autotank.vat-pc    = buf_temp-tax.vat-pc
      and temp-autotank.slt-pc    = buf_temp-tax.slt-pc
      no-error.
    if available temp-autotank then
    do:
      assign
        tt0-fin-doc-tax.sum-line-doc      = tt0-fin-doc-tax.sum-line-doc + temp-autotank.sum-return
        tt0-fin-doc-tax.sum-vat-line-doc  = tt0-fin-doc-tax.sum-vat-line-doc +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
        tt0-fin-doc-tax.sum-line-rubl     = tt0-fin-doc-tax.sum-line-rubl + temp-autotank.sum-return
        tt0-fin-doc-tax.sum-vat-line-rubl = tt0-fin-doc-tax.sum-vat-line-rubl +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
        tt0-fin-doc-tax.sum-line-base     = tt0-fin-doc-tax.sum-line-base  + temp-autotank.sum-return
        tt0-fin-doc-tax.sum-vat-line-base = tt0-fin-doc-tax.sum-vat-line-base  +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
        .
    end.
    release tt0-fin-doc-tax.
  end.
  taxVne = "" .
  run StrTax in this-procedure ( input-output tt-fin-doc.including) .
  run RoundTax in this-procedure .
  if available ub.CashBook
    then
  do :
    p-by-cash-desk = ub.CashBook.FlagSepCash .
    p-by-petrol-goods = ub.CashBook.FlagSepFull .
    p-by-pril = ub.CashBook.RulePril .
  end.
  if p-by-cash-desk then
  do:
    find first temp-z-number-list no-lock
      where temp-z-number-list.cash-desk = buf_temp-fin-sum.cash-desk
      no-error.
  end.
  if     trim(p-by-pril) = '0'
    and buf_temp-fin-sum.pay-type ne "trans"
    then
    tt-fin-doc.enclosure = v-naznach-plat.
  case p-by-osnovanie:
    when '0' then
      do :
        v-naznach-plat = 'Выручка от реализации'.
        if available temp-z-number-list then temp-z-number-list.naznach-plat = 'Выручка от реализации'.
      end.
    when '2'          then
      do :
        v-naznach-plat = ''.
        if available temp-z-number-list then temp-z-number-list.naznach-plat = ''.
      end.
    when '1'          then
      do :
        if available temp-z-number-list then temp-z-number-list.naznach-plat = v-naznach-plat.
      end.
    otherwise
    do:
      v-naznach-plat = p-by-osnovanie.
      if available temp-z-number-list then temp-z-number-list.naznach-plat = p-by-osnovanie.
    end.
  end case .
  assign
    tt-fin-doc.naznach-plat = (if p-by-cash-desk
                                        then (if available temp-z-number-list
                                              then temp-z-number-list.naznach-plat
                                              else '')
                                        else  v-naznach-plat)
    .
  assign
    tt-fin-doc.CashBookId = buf_temp-fin-sum.cashbookid
    tt-fin-doc.sum-doc    = abs(buf_temp-fin-sum.tot-sum)
    tt-fin-doc.sum-base   = abs(buf_temp-fin-sum.tot-base)
    tt-fin-doc.sum-rubl   = abs(buf_temp-fin-sum.tot-rubl)
    tt-fin-doc.exch-rate  = abs(if buf_temp-fin-sum.curr-code = 0 then 1 else buf_temp-fin-sum.tot-rubl / buf_temp-fin-sum.tot-sum )
    tt-fin-doc.exch-scale = 1
    tt-fin-doc.base-rate  = abs(if buf_temp-fin-sum.curr-code = v-base-code then 1 else buf_temp-fin-sum.tot-rubl / buf_temp-fin-sum.tot-base )
    tt-fin-doc.base-scale = 1
    .
  if buf_temp-fin-sum.tot-sum > 0  then
  do:
    if p-by-petrol-goods then
    do:
      assign
        tt-fin-doc.payer-name     = "Выручка от реализации " + (if buf_temp-fin-sum.is-petrol then "нефтепродуктов" else "ТНП")
        tt-fin-doc.receiver-sign3 = v-cashier
        .
    end.
    else
    do:
      assign
        tt-fin-doc.payer-name     = "Выручка от реализации нефтепродуктов, ТНП"
        tt-fin-doc.receiver-sign3 = v-cashier
        .
    end.
    assign
      tt-fin-doc.payer-name = mpayer-name
      when mpayer-name ne "".
  end.
  else
  do:
    if p-by-petrol-goods then
    do:
      assign
        tt-fin-doc.payer-sign3 = v-cashier
        .
    end.
    else
    do:
      assign
        tt-fin-doc.payer-sign3 = v-cashier
        .
    end.
    assign
      tt-fin-doc.receiver-name = mreceiver-name
      when mreceiver-name ne "".
  end.
  o-uchet   = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "uchet") .
  if available ub.CashBook
    then
  do :
    tt-fin-doc.cor-acc-value  = mdopacct .
    tt-fin-doc.cor-acc1-value = mosnacct.
    if buf_temp-fin-sum.tot-sum > 0
      then
    do:
      tt-fin-doc.payer-name = mpayer-name .
    end.
    FIND ub.fin-code-cor-acc WHERE
      ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
      AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
      AND  ub.fin-code-cor-acc.status_ = integer('0':U)
      NO-LOCK NO-error.
    if not available ub.fin-code-cor-acc
      then
    do:
      assign
        tt-fin-doc.cor-acc-value = chr(63)
        .
    end.
    else
    do:
      assign
        tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code
        .
    end.
    FIND ub.fin-code-cor-acc WHERE
      ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc1-value
      AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
      AND  ub.fin-code-cor-acc.status_ = integer('0':U)
      NO-LOCK NO-error.
    if not available ub.fin-code-cor-acc
      then
    do:
      assign
        tt-fin-doc.cor-acc1-value = chr(63)
        .
    end.
    else
    do:
      assign
        tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code
        .
    end.
  end.
  if o-uchet = "0"
    then v-uchet = "cal" .
  else v-uchet = "smen" .
  if buf_shift-obj.status_ = 'зкр':U and v-uchet = "smen" then
  do:
    assign
      tt-fin-doc.doc-date   = buf_shift-obj.close-date
      tt-fin-doc.shift-date = buf_shift-obj.shift-date
      tt-fin-doc.shift-num  = buf_shift-obj.shift-num
      tt-fin-doc.shift-name = buf_shift-obj.shift-name
      .
  end.
  if v-uchet = "smen" then tt-fin-doc.doc-date = buf_shift-obj.shift-date .
  assign
    tt-fin-doc.doc-author = 'auto':U.
          run ref/findoc0.p (
      input-output v-doc-rec
            ,input 'ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U
            ,input yes
            ,input tt-fin-doc.host-code            ,input tt-fin-doc.fin-doc-code         ,input tt-fin-doc.an-uchet-code        ,input tt-fin-doc.an-uchet-value       ,input tt-fin-doc.base-rate            ,input tt-fin-doc.base-scale           ,input tt-fin-doc.cel-nazn-code        ,input tt-fin-doc.cel-nazn-value       ,input tt-fin-doc.contract-code        ,input tt-fin-doc.contract-curr        ,input tt-fin-doc.contract-rate        ,input tt-fin-doc.contract-scale       ,input tt-fin-doc.cor-acc              ,input tt-fin-doc.cor-acc-value        ,input tt-fin-doc.cor-acc1             ,input tt-fin-doc.cor-acc1-value       ,input tt-fin-doc.curr-code            ,input tt-fin-doc.doc-date             ,input tt-fin-doc.shift-date           ,input tt-fin-doc.shift-num            ,input tt-fin-doc.shift-name           ,input tt-fin-doc.enclosure            ,input tt-fin-doc.exch-rate            ,input tt-fin-doc.exch-scale           ,input tt-fin-doc.f104                 ,input tt-fin-doc.f105                 ,input tt-fin-doc.f106                 ,input tt-fin-doc.f107                 ,input tt-fin-doc.f108                 ,input tt-fin-doc.f109                 ,input tt-fin-doc.f110                 ,input tt-fin-doc.f22                  ,input tt-fin-doc.f23                  ,input tt-fin-doc.fact-date            ,input tt-fin-doc.fin-doc-type         ,input tt-fin-doc.fin-ext-doc-type     ,input tt-fin-doc.in-doc-code          ,input tt-fin-doc.in-host-code         ,input tt-fin-doc.including            ,input tt-fin-doc.nazn-pl              ,input tt-fin-doc.naznach-plat         ,input tt-fin-doc.ocher-pl             ,input tt-fin-doc.out-doc-code         ,input tt-fin-doc.out-host-code        ,input tt-fin-doc.pay-date             ,input tt-fin-doc.payer-bank-name      ,input tt-fin-doc.payer-bank-city      ,input tt-fin-doc.payer-bik            ,input tt-fin-doc.payer-c-schet        ,input tt-fin-doc.payer-code           ,input tt-fin-doc.payer-code-schet     ,input tt-fin-doc.payer-dop1           ,input tt-fin-doc.payer-dop2           ,input tt-fin-doc.payer-inn            ,input tt-fin-doc.payer-kpp            ,input tt-fin-doc.payer-name           ,input tt-fin-doc.payer-okpo           ,input tt-fin-doc.payer-passport      ,input tt-fin-doc.payer-r-schet        ,input tt-fin-doc.payer-type           ,input tt-fin-doc.perm-date            ,input tt-fin-doc.prn-doc-code         ,input tt-fin-doc.PS                   ,input tt-fin-doc.receiver-bank-name   ,input tt-fin-doc.receiver-bank-city   ,input tt-fin-doc.receiver-bik         ,input tt-fin-doc.receiver-c-schet     ,input tt-fin-doc.receiver-code        ,input tt-fin-doc.receiver-code-schet  ,input tt-fin-doc.receiver-dop1        ,input tt-fin-doc.receiver-dop2        ,input tt-fin-doc.receiver-inn         ,input tt-fin-doc.receiver-kpp         ,input tt-fin-doc.receiver-name        ,input tt-fin-doc.receiver-okpo        ,input tt-fin-doc.receiver-passport    ,input tt-fin-doc.receiver-r-schet     ,input tt-fin-doc.receiver-type        ,input tt-fin-doc.srok-pl              ,input tt-fin-doc.stat-pl              ,input tt-fin-doc.str-podr-code        ,input tt-fin-doc.str-podr-type        ,input tt-fin-doc.str-podr-name        ,input tt-fin-doc.sum-base             ,input tt-fin-doc.sum-doc              ,input tt-fin-doc.sum-rubl             ,input tt-fin-doc.sum-contr            ,input tt-fin-doc.trn-doc-code         ,input tt-fin-doc.vid-opl              ,input tt-fin-doc.vid-plat
            ,input tt-fin-doc.con-sum-rubl         ,input tt-fin-doc.con-sum-base         ,input tt-fin-doc.con-sum-doc          ,input tt-fin-doc.con-sum-contr        ,input tt-fin-doc.con-stat             ,input tt-fin-doc.payer-sign1                ,input tt-fin-doc.payer-sign2                ,input tt-fin-doc.payer-sign3                ,input tt-fin-doc.payer-sign4                ,input tt-fin-doc.receiver-sign1                ,input tt-fin-doc.receiver-sign2                ,input tt-fin-doc.receiver-sign3                ,input tt-fin-doc.receiver-sign4                ,input tt-fin-doc.obj-type                   ,input tt-fin-doc.obj-code                   ,input tt-fin-doc.doc-author                 ,input tt-fin-doc.fact-author                ,input tt-fin-doc.CashBookId
            ,input table tt0-fin-doc-tax
            ,input table tt0-fin-doc-attr
            ,input no
            ,input table tt0-payment
      ) no-error.
  if error-status:error then
  do:
            if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
    undo _main, return error.
  end.
  find first buf_fin-doc share-lock where
    recid(buf_fin-doc) = v-doc-rec.
  assign
    buf_fin-doc.shift-flag = integer('1':U)
    .
  if buf_temp-fin-sum.contr-kb ne ?
    then
  do:
    find first fin-doc-attr where fin-doc-attr.host-code eq buf_fin-doc.host-code
      and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
      and fin-doc-attr.attr-code eq "contr-kb"
      exclusive-lock no-error.
    if not available fin-doc-attr
      then
    do:
      create fin-doc-attr.
      assign
        fin-doc-attr.host-code    = buf_fin-doc.host-code
        fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
        fin-doc-attr.attr-code    = "contr-kb"
        .
    end.
    fin-doc-attr.attr-value = String(buf_temp-fin-sum.contr-kb).
  end.
  run proc-close in this-procedure ( buffer buf_fin-doc) no-error.
  if error-status :error then
  do:
            if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
    undo _main, return error.
  END.
  if buf_fin-doc.status_ <> 'факт':U then
  do:
    run proc-close in this-procedure ( buffer buf_fin-doc) NO-ERROR.
    if error-status :error then
    do:
                if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                        , return-value )).
      undo _main, return error.
    END.
  end.
  if buf_fin-doc.status_ <> 'факт':U then
  do:
    run proc-close in this-procedure ( buffer buf_fin-doc) no-error .
    if error-status :error then
    do:
                if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                        , return-value )).
      undo _main, return error.
    END.
  end.
            if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Создаю &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8"                                   , entry (lookup ((if buf_temp-fin-sum.tot-sum > 0 then 'пко':U else 'рко':U), 'пко,рко,ппп,рпп,апп,апр':U) + 1, ',':U + 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,приходный АПЗ,расходный АПЗ':U)                                    , buf_shift-obj.shift-name                                   , buf_shift-obj.shift-date                                   , buf_shift-obj.shift-nuM                                      , buf_shift-obj.obj-type                                   , buf_shift-obj.obj-code                                   , buf_temp-fin-sum.cashbookid                                   , abs(buf_temp-fin-sum.tot-sum)                                   , chr(10)                                   )).
   end.
  _temp-fin-sumVne:
  for each buf_temp-fin-sumVne no-lock
    by buf_temp-fin-sumVne.tot-sum descending
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
    empty temp-table tt0-fin-doc-tax.
    empty temp-table tt0-fin-doc-attr.
    empty temp-table tt-fin-doc.
    if buf_temp-fin-sumVne.tot-sum = 0  then
    do:
      next _temp-fin-sumVne.
    end.
    v-naznach-plat = v-naznach-plat2 .
    find first ub.CashBook no-lock where ub.CashBook.id = buf_temp-fin-sumVne.cashbookid no-error .
    if not available ub.CashBook
      then
    do :
      find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
    end.
    assign
      mreceiver-name = ""
      mpayer-name    = ""
      .
    if buf_temp-fin-sumVne.tot-sum > 0
      then
    do:
      assign
        p-by-osnovanie       = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, 'всем':U, 0,  "RuleOsnPkoVne"  )
        v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, 'всем':U, 0,  "Vnecli-type"  )
        v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, 'всем':U, 0,  "Vnecli-code"  ))
        mosnacct             = ub.CashBook.OsnAcct
        mdopacct             = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, 'всем':U, 0,  "corrPkoVne"  )
        mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, 'всем':U, 0,  "takenfromVne"  )
        .
      if mpayer-name eq "" or mpayer-name eq ?
        then
      do:
        find first ub.clients no-lock where ub.clients.obj-type = v-real-obj-type-save
          and ub.clients.obj-code = v-real-obj-code-save
          no-error .
        if available ub.clients
          then
          mpayer-name = ub.clients.obj-name .
      end.
    end.
    else
      assign
        p-by-osnovanie       = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, 'всем':U, 0,  "RuleOsnPkoVne"  )
        v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, 'всем':U, 0,  "Vnecli-type"  )
        v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, 'всем':U, 0,  "Vnecli-code"  ))
        mosnacct             = ub.CashBook.OsnAcct
        mdopacct             = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, 'всем':U, 0,  "corrPkoVne"  )
        mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sumVne.cashbookid, 'всем':U, 0,  "takenfromVne"  )
        .
    if buf_temp-fin-sumVne.tot-sum > 0  then
    do:
      run ref/finfnoco.p (
        INPUT parParentProc
        ,INPUT ?
        ,input v-host-code
        ,input ('ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U)
        ,input v-host-code
        ,input v-doc-rec
        ,input 0
        ,input 'пко':U
        ,input 'пко':U
        ,input buf_shift-obj.obj-type
        ,input buf_shift-obj.obj-code
        ,input 0
        ,input ''
        ,input  v-real-obj-type-save
        ,input  v-real-obj-code-save
        ,input 0
        ,input 'орг':U
        ,input v-host-code
        ,input 0
        ,input buf_temp-fin-sumVne.curr-code
        ,input 0
        ,input 0
        ,input 0
        ,input 0
        ,input buf_temp-fin-sumVne.cashbookid
        ,input ""
        ,INPUT-OUTPUT table tt-fin-doc
        ,INPUT-OUTPUT table ttc-fin-doc
        ,output table tt0-fin-doc-attr
        ,output v-limit-access ) no-error .
    end.
    else
    do:
      run ref/finfnoco.p (
        INPUT parParentProc
        ,INPUT ?
        ,input v-host-code
        ,input ('ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U)
        ,input v-host-code
        ,input v-doc-rec
        ,input 0
        ,input 'рко':U
        ,input 'рко':U
        ,input buf_shift-obj.obj-type
        ,input buf_shift-obj.obj-code
        ,input 0
        ,input ''
        ,input 'орг':U
        ,input v-host-code
        ,input 0
        ,input v-real-obj-type-save
        ,input v-real-obj-code-save
        ,input 0
        ,input buf_temp-fin-sumVne.curr-code
        ,input 0
        ,input 0
        ,input 0
        ,input 0
        ,input buf_temp-fin-sumVne.cashbookid
        ,input ""
        ,INPUT-OUTPUT table tt-fin-doc
        ,INPUT-OUTPUT table ttc-fin-doc
        ,output table tt0-fin-doc-attr
        ,output v-limit-access ) no-error .
    end.
    if error-status:error then
    do:
              if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при заполнении фин.док-та значениями по умолчанию:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
      undo _main, return error.
    end.
    find first tt-fin-doc.
    for each buf_temp-taxVne no-lock
      where buf_temp-taxVne.curr-code        = buf_temp-fin-sumVne.curr-code
      and buf_temp-taxVne.cash-desk         = buf_temp-fin-sumVne.cash-desk
      and buf_temp-taxVne.is-petrol        = buf_temp-fin-sumVne.is-petrol
      and buf_temp-taxVne.cashbookId       = buf_temp-fin-sumVne.cashbookId
      and buf_temp-taxVne.is-expense_cash  = buf_temp-fin-sumVne.is-expense_cash
      and buf_temp-taxVne.num-expense_cash = buf_temp-fin-sumVne.num-expense_cash
      and buf_temp-taxVne.pay-type = buf_temp-fin-sumVne.pay-type
      :
      v-line-num = v-line-num + 1.
      create tt0-fin-doc-tax .
      assign
        tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
        tt0-fin-doc-tax.host-code          = tt-fin-doc.host-code
        tt0-fin-doc-tax.line-num           = v-line-num
        tt0-fin-doc-tax.VAT-pc             = -1
        tt0-fin-doc-tax.slt-pc             = buf_temp-taxVne.slt-pc
        tt0-fin-doc-tax.sum-line-contr     = 0
        tt0-fin-doc-tax.sum-vat-line-contr = 0
        tt0-fin-doc-tax.with-vat           = no
        .
      if buf_temp-fin-sumVne.tot-sum > 0  then
      do :
        assign
          tt0-fin-doc-tax.sum-line-doc      = buf_temp-taxVne.sum-doc
          tt0-fin-doc-tax.sum-vat-line-doc  = buf_temp-taxVne.vat-doc
          tt0-fin-doc-tax.sum-line-rubl     = buf_temp-taxVne.sum-rubl
          tt0-fin-doc-tax.sum-vat-line-rubl = buf_temp-taxVne.vat-rubl
          tt0-fin-doc-tax.sum-line-base     = buf_temp-taxVne.sum-base
          tt0-fin-doc-tax.sum-vat-line-base = buf_temp-taxVne.vat-base
          .
      end.
      else
      do :
        assign
          tt0-fin-doc-tax.sum-line-doc      = abs(buf_temp-taxVne.sum-doc)
          tt0-fin-doc-tax.sum-vat-line-doc  = abs(buf_temp-taxVne.vat-doc)
          tt0-fin-doc-tax.sum-line-rubl     = abs(buf_temp-taxVne.sum-rubl)
          tt0-fin-doc-tax.sum-vat-line-rubl = abs(buf_temp-taxVne.vat-rubl)
          tt0-fin-doc-tax.sum-line-base     = abs(buf_temp-taxVne.sum-base)
          tt0-fin-doc-tax.sum-vat-line-base = abs(buf_temp-taxVne.vat-base)
          .
      end.
      find first temp-autotank no-lock
        where temp-autotank.curr-code = buf_temp-taxVne.curr-code
        and temp-autotank.pay-desk = buf_temp-taxVne.cash-desk
        and temp-autotank.is-petrol = buf_temp-taxVne.is-petrol
        and temp-autotank.vat-pc    = buf_temp-taxVne.vat-pc
        and temp-autotank.slt-pc    = buf_temp-taxVne.slt-pc
        no-error.
      if available temp-autotank then
      do:
        assign
          tt0-fin-doc-tax.sum-line-doc      = tt0-fin-doc-tax.sum-line-doc + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-doc  = tt0-fin-doc-tax.sum-vat-line-doc +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          tt0-fin-doc-tax.sum-line-rubl     = tt0-fin-doc-tax.sum-line-rubl + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-rubl = tt0-fin-doc-tax.sum-vat-line-rubl +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          tt0-fin-doc-tax.sum-line-base     = tt0-fin-doc-tax.sum-line-base  + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-base = tt0-fin-doc-tax.sum-vat-line-base  +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          .
      end.
      release tt0-fin-doc-tax.
    end.
    taxVne = "Vne" .
    run StrTax in this-procedure ( input-output tt-fin-doc.including) .
    run RoundTax in this-procedure .
    if available ub.CashBook
      then
    do :
      p-by-cash-desk = ub.CashBook.FlagSepCash .
      p-by-petrol-goods = ub.CashBook.FlagSepFull .
      p-by-pril = ub.CashBook.RulePril .
    end.
    if p-by-cash-desk then
    do:
      find first temp-z-number-list no-lock
        where temp-z-number-list.cash-desk = buf_temp-fin-sumVne.cash-desk
        no-error.
    end.
    if     trim(p-by-pril) = '0'
      and buf_temp-fin-sumVne.pay-type ne "trans"
      then
      tt-fin-doc.enclosure = v-naznach-plat.
    case p-by-osnovanie:
      when '0' then
        do :
          v-naznach-plat = 'Выручка от реализации'.
          if available temp-z-number-list then temp-z-number-list.naznach-plat = 'Выручка от реализации'.
        end.
      when '2'          then
        do :
          v-naznach-plat = ''.
          if available temp-z-number-list then temp-z-number-list.naznach-plat = ''.
        end.
      when '1'          then
        do :
          if available temp-z-number-list then temp-z-number-list.naznach-plat = v-naznach-plat.
        end.
      otherwise
      do:
        v-naznach-plat = p-by-osnovanie.
        if available temp-z-number-list then temp-z-number-list.naznach-plat = p-by-osnovanie.
      end.
    end case .
    assign
      tt-fin-doc.naznach-plat = (if p-by-cash-desk
                                        then (if available temp-z-number-list
                                              then temp-z-number-list.naznach-plat
                                              else '')
                                        else  v-naznach-plat)
      .
    assign
      tt-fin-doc.CashBookId = buf_temp-fin-sumVne.cashbookid
      tt-fin-doc.sum-doc    = abs(buf_temp-fin-sumVne.tot-sum)
      tt-fin-doc.sum-base   = abs(buf_temp-fin-sumVne.tot-base)
      tt-fin-doc.sum-rubl   = abs(buf_temp-fin-sumVne.tot-rubl)
      tt-fin-doc.exch-rate  = abs(if buf_temp-fin-sumVne.curr-code = 0 then 1 else buf_temp-fin-sumVne.tot-rubl / buf_temp-fin-sumVne.tot-sum )
      tt-fin-doc.exch-scale = 1
      tt-fin-doc.base-rate  = abs(if buf_temp-fin-sumVne.curr-code = v-base-code then 1 else buf_temp-fin-sumVne.tot-rubl / buf_temp-fin-sumVne.tot-base )
      tt-fin-doc.base-scale = 1
      .
    if buf_temp-fin-sumVne.tot-sum > 0  then
    do:
      if p-by-petrol-goods then
      do:
        assign
          tt-fin-doc.payer-name     = "Выручка от реализации " + (if buf_temp-fin-sumVne.is-petrol then "нефтепродуктов" else "ТНП")
          tt-fin-doc.receiver-sign3 = v-cashier
          .
      end.
      else
      do:
        assign
          tt-fin-doc.payer-name     = "Выручка от реализации нефтепродуктов, ТНП"
          tt-fin-doc.receiver-sign3 = v-cashier
          .
      end.
      assign
        tt-fin-doc.payer-name = mpayer-name
        when mpayer-name ne "".
    end.
    else
    do:
      if p-by-petrol-goods then
      do:
        assign
          tt-fin-doc.payer-sign3 = v-cashier
          .
      end.
      else
      do:
        assign
          tt-fin-doc.payer-sign3 = v-cashier
          .
      end.
      assign
        tt-fin-doc.receiver-name = mreceiver-name
        when mreceiver-name ne "".
    end.
    o-uchet   = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "uchet") .
    if available ub.CashBook
      then
    do :
      tt-fin-doc.cor-acc-value  = mdopacct .
      tt-fin-doc.cor-acc1-value = mosnacct.
      if buf_temp-fin-sumVne.tot-sum > 0
        then
      do:
        tt-fin-doc.payer-name = mpayer-name .
      end.
      FIND ub.fin-code-cor-acc WHERE
        ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
        AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
        AND  ub.fin-code-cor-acc.status_ = integer('0':U)
        NO-LOCK NO-error.
      if not available ub.fin-code-cor-acc
        then
      do:
        assign
          tt-fin-doc.cor-acc-value = chr(63)
          .
      end.
      else
      do:
        assign
          tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code
          .
      end.
      FIND ub.fin-code-cor-acc WHERE
        ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc1-value
        AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
        AND  ub.fin-code-cor-acc.status_ = integer('0':U)
        NO-LOCK NO-error.
      if not available ub.fin-code-cor-acc
        then
      do:
        assign
          tt-fin-doc.cor-acc1-value = chr(63)
          .
      end.
      else
      do:
        assign
          tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code
          .
      end.
    end.
    if o-uchet = "0"
      then v-uchet = "cal" .
    else v-uchet = "smen" .
    if buf_shift-obj.status_ = 'зкр':U and v-uchet = "smen" then
    do:
      assign
        tt-fin-doc.doc-date   = buf_shift-obj.close-date
        tt-fin-doc.shift-date = buf_shift-obj.shift-date
        tt-fin-doc.shift-num  = buf_shift-obj.shift-num
        tt-fin-doc.shift-name = buf_shift-obj.shift-name
        .
    end.
    if v-uchet = "smen" then tt-fin-doc.doc-date = buf_shift-obj.shift-date .
    assign
      tt-fin-doc.doc-author = 'auto':U.
          run ref/findoc0.p (
      input-output v-doc-rec
            ,input 'ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U
            ,input yes
            ,input tt-fin-doc.host-code            ,input tt-fin-doc.fin-doc-code         ,input tt-fin-doc.an-uchet-code        ,input tt-fin-doc.an-uchet-value       ,input tt-fin-doc.base-rate            ,input tt-fin-doc.base-scale           ,input tt-fin-doc.cel-nazn-code        ,input tt-fin-doc.cel-nazn-value       ,input tt-fin-doc.contract-code        ,input tt-fin-doc.contract-curr        ,input tt-fin-doc.contract-rate        ,input tt-fin-doc.contract-scale       ,input tt-fin-doc.cor-acc              ,input tt-fin-doc.cor-acc-value        ,input tt-fin-doc.cor-acc1             ,input tt-fin-doc.cor-acc1-value       ,input tt-fin-doc.curr-code            ,input tt-fin-doc.doc-date             ,input tt-fin-doc.shift-date           ,input tt-fin-doc.shift-num            ,input tt-fin-doc.shift-name           ,input tt-fin-doc.enclosure            ,input tt-fin-doc.exch-rate            ,input tt-fin-doc.exch-scale           ,input tt-fin-doc.f104                 ,input tt-fin-doc.f105                 ,input tt-fin-doc.f106                 ,input tt-fin-doc.f107                 ,input tt-fin-doc.f108                 ,input tt-fin-doc.f109                 ,input tt-fin-doc.f110                 ,input tt-fin-doc.f22                  ,input tt-fin-doc.f23                  ,input tt-fin-doc.fact-date            ,input tt-fin-doc.fin-doc-type         ,input tt-fin-doc.fin-ext-doc-type     ,input tt-fin-doc.in-doc-code          ,input tt-fin-doc.in-host-code         ,input tt-fin-doc.including            ,input tt-fin-doc.nazn-pl              ,input tt-fin-doc.naznach-plat         ,input tt-fin-doc.ocher-pl             ,input tt-fin-doc.out-doc-code         ,input tt-fin-doc.out-host-code        ,input tt-fin-doc.pay-date             ,input tt-fin-doc.payer-bank-name      ,input tt-fin-doc.payer-bank-city      ,input tt-fin-doc.payer-bik            ,input tt-fin-doc.payer-c-schet        ,input tt-fin-doc.payer-code           ,input tt-fin-doc.payer-code-schet     ,input tt-fin-doc.payer-dop1           ,input tt-fin-doc.payer-dop2           ,input tt-fin-doc.payer-inn            ,input tt-fin-doc.payer-kpp            ,input tt-fin-doc.payer-name           ,input tt-fin-doc.payer-okpo           ,input tt-fin-doc.payer-passport      ,input tt-fin-doc.payer-r-schet        ,input tt-fin-doc.payer-type           ,input tt-fin-doc.perm-date            ,input tt-fin-doc.prn-doc-code         ,input tt-fin-doc.PS                   ,input tt-fin-doc.receiver-bank-name   ,input tt-fin-doc.receiver-bank-city   ,input tt-fin-doc.receiver-bik         ,input tt-fin-doc.receiver-c-schet     ,input tt-fin-doc.receiver-code        ,input tt-fin-doc.receiver-code-schet  ,input tt-fin-doc.receiver-dop1        ,input tt-fin-doc.receiver-dop2        ,input tt-fin-doc.receiver-inn         ,input tt-fin-doc.receiver-kpp         ,input tt-fin-doc.receiver-name        ,input tt-fin-doc.receiver-okpo        ,input tt-fin-doc.receiver-passport    ,input tt-fin-doc.receiver-r-schet     ,input tt-fin-doc.receiver-type        ,input tt-fin-doc.srok-pl              ,input tt-fin-doc.stat-pl              ,input tt-fin-doc.str-podr-code        ,input tt-fin-doc.str-podr-type        ,input tt-fin-doc.str-podr-name        ,input tt-fin-doc.sum-base             ,input tt-fin-doc.sum-doc              ,input tt-fin-doc.sum-rubl             ,input tt-fin-doc.sum-contr            ,input tt-fin-doc.trn-doc-code         ,input tt-fin-doc.vid-opl              ,input tt-fin-doc.vid-plat
            ,input tt-fin-doc.con-sum-rubl         ,input tt-fin-doc.con-sum-base         ,input tt-fin-doc.con-sum-doc          ,input tt-fin-doc.con-sum-contr        ,input tt-fin-doc.con-stat             ,input tt-fin-doc.payer-sign1                ,input tt-fin-doc.payer-sign2                ,input tt-fin-doc.payer-sign3                ,input tt-fin-doc.payer-sign4                ,input tt-fin-doc.receiver-sign1                ,input tt-fin-doc.receiver-sign2                ,input tt-fin-doc.receiver-sign3                ,input tt-fin-doc.receiver-sign4                ,input tt-fin-doc.obj-type                   ,input tt-fin-doc.obj-code                   ,input tt-fin-doc.doc-author                 ,input tt-fin-doc.fact-author                ,input tt-fin-doc.CashBookId
            ,input table tt0-fin-doc-tax
            ,input table tt0-fin-doc-attr
            ,input no
            ,input table tt0-payment
      ) no-error.
    if error-status:error then
    do:
              if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
      undo _main, return error.
    end.
    find first buf_fin-doc share-lock where
      recid(buf_fin-doc) = v-doc-rec.
    assign
      buf_fin-doc.shift-flag = integer('1':U)
      .
    if buf_temp-fin-sumVne.contr-kb ne ?
      then
    do:
      find first fin-doc-attr where fin-doc-attr.host-code eq buf_fin-doc.host-code
        and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
        and fin-doc-attr.attr-code eq "contr-kb"
        exclusive-lock no-error.
      if not available fin-doc-attr
        then
      do:
        create fin-doc-attr.
        assign
          fin-doc-attr.host-code    = buf_fin-doc.host-code
          fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
          fin-doc-attr.attr-code    = "contr-kb"
          .
      end.
      fin-doc-attr.attr-value = String(buf_temp-fin-sumVne.contr-kb).
    end.
    run proc-close in this-procedure ( buffer buf_fin-doc) no-error.
    if error-status :error then
    do:
              if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
      undo _main, return error.
    END.
    if buf_fin-doc.status_ <> 'факт':U then
    do:
      run proc-close in this-procedure ( buffer buf_fin-doc) NO-ERROR.
      if error-status :error then
      do:
                  if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                        , return-value )).
        undo _main, return error.
      END.
    end.
    if buf_fin-doc.status_ <> 'факт':U then
    do:
      run proc-close in this-procedure ( buffer buf_fin-doc) no-error .
      if error-status :error then
      do:
                  if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                        , return-value )).
        undo _main, return error.
      END.
    end.
              if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Создаю &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8"                                   , entry (lookup ((if buf_temp-fin-sumVne.tot-sum > 0 then 'пко':U else 'рко':U), 'пко,рко,ппп,рпп,апп,апр':U) + 1, ',':U + 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,приходный АПЗ,расходный АПЗ':U)                                    , buf_shift-obj.shift-name                                   , buf_shift-obj.shift-date                                   , buf_shift-obj.shift-nuM                                      , buf_shift-obj.obj-type                                   , buf_shift-obj.obj-code                                   , buf_temp-fin-sumVne.cashbookid                                   , abs(buf_temp-fin-sumVne.tot-sum)                                   , chr(10)                                   )).
   end.
  _temp-fin-sumAvans:
  for each buf_temp-fin-sumAvans no-lock
    by buf_temp-fin-sumAvans.tot-sum descending
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
    empty temp-table tt0-fin-doc-tax.
    empty temp-table tt0-fin-doc-attr.
    empty temp-table tt-fin-doc.
    if buf_temp-fin-sumAvans.tot-sum = 0  then
    do:
      next _temp-fin-sumAvans.
    end.
    v-naznach-plat = v-naznach-plat2 .
    find first ub.CashBook no-lock where ub.CashBook.id = buf_temp-fin-sumAvans.cashbookid no-error .
    if not available ub.CashBook
      then
    do :
      find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
    end.
    assign
      mreceiver-name = ""
      mpayer-name    = ""
      .
    if buf_temp-fin-sumAvans.tot-sum > 0
      then
    do:
      assign
        p-by-osnovanie       = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, 'всем':U, 0,  "RuleOsnPkoAvans"  )
        v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, 'всем':U, 0,  "Avanscli-type"  )
        v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, 'всем':U, 0,  "Avanscli-code"  ))
        mosnacct             = ub.CashBook.OsnAcct
        mdopacct             = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, 'всем':U, 0,  "corrPkoAvans"  )
        mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, 'всем':U, 0,  "takenfromAvans"  )
        .
      if mpayer-name eq "" or mpayer-name eq ?
        then
      do:
        find first ub.clients no-lock where ub.clients.obj-type = v-real-obj-type-save
          and ub.clients.obj-code = v-real-obj-code-save
          no-error .
        if available ub.clients
          then
          mpayer-name = ub.clients.obj-name .
      end.
    end.
    else
      assign
        p-by-osnovanie       = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, 'всем':U, 0,  "RuleOsnPkoAvans"  )
        v-real-obj-type-save = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, 'всем':U, 0,  "Avanscli-type"  )
        v-real-obj-code-save = int( mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, 'всем':U, 0,  "Avanscli-code"  ))
        mosnacct             = ub.CashBook.OsnAcct
        mdopacct             = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, 'всем':U, 0,  "corrPkoAvans"  )
        mreceiver-name       = mCashBook:getSinglRule(buf_temp-fin-sumAvans.cashbookid, 'всем':U, 0,  "takenfromAvans"  )
        .
    if buf_temp-fin-sumAvans.tot-sum > 0  then
    do:
      run ref/finfnoco.p (
        INPUT parParentProc
        ,INPUT ?
        ,input v-host-code
        ,input ('ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U)
        ,input v-host-code
        ,input v-doc-rec
        ,input 0
        ,input 'пко':U
        ,input 'пко':U
        ,input buf_shift-obj.obj-type
        ,input buf_shift-obj.obj-code
        ,input 0
        ,input ''
        ,input  v-real-obj-type-save
        ,input  v-real-obj-code-save
        ,input 0
        ,input 'орг':U
        ,input v-host-code
        ,input 0
        ,input buf_temp-fin-sumAvans.curr-code
        ,input 0
        ,input 0
        ,input 0
        ,input 0
        ,input buf_temp-fin-sumAvans.cashbookid
        ,input ""
        ,INPUT-OUTPUT table tt-fin-doc
        ,INPUT-OUTPUT table ttc-fin-doc
        ,output table tt0-fin-doc-attr
        ,output v-limit-access ) no-error .
    end.
    else
    do:
      run ref/finfnoco.p (
        INPUT parParentProc
        ,INPUT ?
        ,input v-host-code
        ,input ('ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U)
        ,input v-host-code
        ,input v-doc-rec
        ,input 0
        ,input 'рко':U
        ,input 'рко':U
        ,input buf_shift-obj.obj-type
        ,input buf_shift-obj.obj-code
        ,input 0
        ,input ''
        ,input 'орг':U
        ,input v-host-code
        ,input 0
        ,input v-real-obj-type-save
        ,input v-real-obj-code-save
        ,input 0
        ,input buf_temp-fin-sumAvans.curr-code
        ,input 0
        ,input 0
        ,input 0
        ,input 0
        ,input buf_temp-fin-sumAvans.cashbookid
        ,input ""
        ,INPUT-OUTPUT table tt-fin-doc
        ,INPUT-OUTPUT table ttc-fin-doc
        ,output table tt0-fin-doc-attr
        ,output v-limit-access ) no-error .
    end.
    if error-status:error then
    do:
              if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при заполнении фин.док-та значениями по умолчанию:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
      undo _main, return error.
    end.
    find first tt-fin-doc.
    for each buf_temp-taxAvans no-lock
      where buf_temp-taxAvans.curr-code        = buf_temp-fin-sumAvans.curr-code
      and buf_temp-taxAvans.cash-desk         = buf_temp-fin-sumAvans.cash-desk
      and buf_temp-taxAvans.is-petrol        = buf_temp-fin-sumAvans.is-petrol
      and buf_temp-taxAvans.cashbookId       = buf_temp-fin-sumAvans.cashbookId
      and buf_temp-taxAvans.is-expense_cash  = buf_temp-fin-sumAvans.is-expense_cash
      and buf_temp-taxAvans.num-expense_cash = buf_temp-fin-sumAvans.num-expense_cash
      and buf_temp-taxAvans.pay-type = buf_temp-fin-sumAvans.pay-type
      :
      v-line-num = v-line-num + 1.
      create tt0-fin-doc-tax .
      assign
        tt0-fin-doc-tax.fin-doc-code       = tt-fin-doc.fin-doc-code
        tt0-fin-doc-tax.host-code          = tt-fin-doc.host-code
        tt0-fin-doc-tax.line-num           = v-line-num
        tt0-fin-doc-tax.VAT-pc             = buf_temp-taxAvans.vat-pc
        tt0-fin-doc-tax.slt-pc             = buf_temp-taxAvans.slt-pc
        tt0-fin-doc-tax.sum-line-contr     = 0
        tt0-fin-doc-tax.sum-vat-line-contr = 0
        tt0-fin-doc-tax.with-vat           = buf_temp-taxAvans.with-vat
        .
      if buf_temp-fin-sumAvans.tot-sum > 0  then
      do :
        assign
          tt0-fin-doc-tax.sum-line-doc      = buf_temp-taxAvans.sum-doc
          tt0-fin-doc-tax.sum-vat-line-doc  = buf_temp-taxAvans.vat-doc
          tt0-fin-doc-tax.sum-line-rubl     = buf_temp-taxAvans.sum-rubl
          tt0-fin-doc-tax.sum-vat-line-rubl = buf_temp-taxAvans.vat-rubl
          tt0-fin-doc-tax.sum-line-base     = buf_temp-taxAvans.sum-base
          tt0-fin-doc-tax.sum-vat-line-base = buf_temp-taxAvans.vat-base
          .
      end.
      else
      do :
        assign
          tt0-fin-doc-tax.sum-line-doc      = abs(buf_temp-taxAvans.sum-doc)
          tt0-fin-doc-tax.sum-vat-line-doc  = abs(buf_temp-taxAvans.vat-doc)
          tt0-fin-doc-tax.sum-line-rubl     = abs(buf_temp-taxAvans.sum-rubl)
          tt0-fin-doc-tax.sum-vat-line-rubl = abs(buf_temp-taxAvans.vat-rubl)
          tt0-fin-doc-tax.sum-line-base     = abs(buf_temp-taxAvans.sum-base)
          tt0-fin-doc-tax.sum-vat-line-base = abs(buf_temp-taxAvans.vat-base)
          .
      end.
      find first temp-autotank no-lock
        where temp-autotank.curr-code = buf_temp-taxAvans.curr-code
        and temp-autotank.pay-desk = buf_temp-taxAvans.cash-desk
        and temp-autotank.is-petrol = buf_temp-taxAvans.is-petrol
        and temp-autotank.vat-pc    = buf_temp-taxAvans.vat-pc
        and temp-autotank.slt-pc    = buf_temp-taxAvans.slt-pc
        no-error.
      if available temp-autotank then
      do:
        assign
          tt0-fin-doc-tax.sum-line-doc      = tt0-fin-doc-tax.sum-line-doc + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-doc  = tt0-fin-doc-tax.sum-vat-line-doc +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          tt0-fin-doc-tax.sum-line-rubl     = tt0-fin-doc-tax.sum-line-rubl + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-rubl = tt0-fin-doc-tax.sum-vat-line-rubl +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          tt0-fin-doc-tax.sum-line-base     = tt0-fin-doc-tax.sum-line-base  + temp-autotank.sum-return
          tt0-fin-doc-tax.sum-vat-line-base = tt0-fin-doc-tax.sum-vat-line-base  +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
          .
      end.
      release tt0-fin-doc-tax.
    end.
    taxVne = "avans" .
    run StrTax in this-procedure ( input-output tt-fin-doc.including) .
    run RoundTax in this-procedure .
    if available ub.CashBook
      then
    do :
      p-by-cash-desk = ub.CashBook.FlagSepCash .
      p-by-petrol-goods = ub.CashBook.FlagSepFull .
      p-by-pril = ub.CashBook.RulePril .
    end.
    if p-by-cash-desk then
    do:
      find first temp-z-number-list no-lock
        where temp-z-number-list.cash-desk = buf_temp-fin-sumAvans.cash-desk
        no-error.
    end.
    if     trim(p-by-pril) = '0'
      and buf_temp-fin-sumAvans.pay-type ne "trans"
      then
      tt-fin-doc.enclosure = v-naznach-plat.
    case p-by-osnovanie:
      when '0' then
        do :
          v-naznach-plat = 'Выручка от реализации'.
          if available temp-z-number-list then temp-z-number-list.naznach-plat = 'Выручка от реализации'.
        end.
      when '2'          then
        do :
          v-naznach-plat = ''.
          if available temp-z-number-list then temp-z-number-list.naznach-plat = ''.
        end.
      when '1'          then
        do :
          if available temp-z-number-list then temp-z-number-list.naznach-plat = v-naznach-plat.
        end.
      otherwise
      do:
        v-naznach-plat = p-by-osnovanie.
        if available temp-z-number-list then temp-z-number-list.naznach-plat = p-by-osnovanie.
      end.
    end case .
    assign
      tt-fin-doc.naznach-plat = (if p-by-cash-desk
                                        then (if available temp-z-number-list
                                              then temp-z-number-list.naznach-plat
                                              else '')
                                        else  v-naznach-plat)
      .
    assign
      tt-fin-doc.CashBookId = buf_temp-fin-sumAvans.cashbookid
      tt-fin-doc.sum-doc    = abs(buf_temp-fin-sumAvans.tot-sum)
      tt-fin-doc.sum-base   = abs(buf_temp-fin-sumAvans.tot-base)
      tt-fin-doc.sum-rubl   = abs(buf_temp-fin-sumAvans.tot-rubl)
      tt-fin-doc.exch-rate  = abs(if buf_temp-fin-sumAvans.curr-code = 0 then 1 else buf_temp-fin-sumAvans.tot-rubl / buf_temp-fin-sumAvans.tot-sum )
      tt-fin-doc.exch-scale = 1
      tt-fin-doc.base-rate  = abs(if buf_temp-fin-sumAvans.curr-code = v-base-code then 1 else buf_temp-fin-sumAvans.tot-rubl / buf_temp-fin-sumAvans.tot-base )
      tt-fin-doc.base-scale = 1
      .
    if buf_temp-fin-sumAvans.tot-sum > 0  then
    do:
      if p-by-petrol-goods then
      do:
        assign
          tt-fin-doc.payer-name     = "Выручка от реализации " + (if buf_temp-fin-sumAvans.is-petrol then "нефтепродуктов" else "ТНП")
          tt-fin-doc.receiver-sign3 = v-cashier
          .
      end.
      else
      do:
        assign
          tt-fin-doc.payer-name     = "Выручка от реализации нефтепродуктов, ТНП"
          tt-fin-doc.receiver-sign3 = v-cashier
          .
      end.
      assign
        tt-fin-doc.payer-name = mpayer-name
        when mpayer-name ne "".
    end.
    else
    do:
      if p-by-petrol-goods then
      do:
        assign
          tt-fin-doc.payer-sign3 = v-cashier
          .
      end.
      else
      do:
        assign
          tt-fin-doc.payer-sign3 = v-cashier
          .
      end.
      assign
        tt-fin-doc.receiver-name = mreceiver-name
        when mreceiver-name ne "".
    end.
    o-uchet   = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "uchet") .
    if available ub.CashBook
      then
    do :
      tt-fin-doc.cor-acc-value  = mdopacct .
      tt-fin-doc.cor-acc1-value = mosnacct.
      if buf_temp-fin-sumAvans.tot-sum > 0
        then
      do:
        tt-fin-doc.payer-name = mpayer-name .
      end.
      FIND ub.fin-code-cor-acc WHERE
        ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
        AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
        AND  ub.fin-code-cor-acc.status_ = integer('0':U)
        NO-LOCK NO-error.
      if not available ub.fin-code-cor-acc
        then
      do:
        assign
          tt-fin-doc.cor-acc-value = chr(63)
          .
      end.
      else
      do:
        assign
          tt-fin-doc.cor-acc = ub.fin-code-cor-acc.fin-code
          .
      end.
      FIND ub.fin-code-cor-acc WHERE
        ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc1-value
        AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
        AND  ub.fin-code-cor-acc.status_ = integer('0':U)
        NO-LOCK NO-error.
      if not available ub.fin-code-cor-acc
        then
      do:
        assign
          tt-fin-doc.cor-acc1-value = chr(63)
          .
      end.
      else
      do:
        assign
          tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code
          .
      end.
    end.
    if o-uchet = "0"
      then v-uchet = "cal" .
    else v-uchet = "smen" .
    if buf_shift-obj.status_ = 'зкр':U and v-uchet = "smen" then
    do:
      assign
        tt-fin-doc.doc-date   = buf_shift-obj.close-date
        tt-fin-doc.shift-date = buf_shift-obj.shift-date
        tt-fin-doc.shift-num  = buf_shift-obj.shift-num
        tt-fin-doc.shift-name = buf_shift-obj.shift-name
        .
    end.
    if v-uchet = "smen" then tt-fin-doc.doc-date = buf_shift-obj.shift-date .
    assign
      tt-fin-doc.doc-author = 'auto':U.
          run ref/findoc0.p (
      input-output v-doc-rec
            ,input 'ДОБАВЛЕНИЕ':U + chr(4) + 'auto':U
            ,input yes
            ,input tt-fin-doc.host-code            ,input tt-fin-doc.fin-doc-code         ,input tt-fin-doc.an-uchet-code        ,input tt-fin-doc.an-uchet-value       ,input tt-fin-doc.base-rate            ,input tt-fin-doc.base-scale           ,input tt-fin-doc.cel-nazn-code        ,input tt-fin-doc.cel-nazn-value       ,input tt-fin-doc.contract-code        ,input tt-fin-doc.contract-curr        ,input tt-fin-doc.contract-rate        ,input tt-fin-doc.contract-scale       ,input tt-fin-doc.cor-acc              ,input tt-fin-doc.cor-acc-value        ,input tt-fin-doc.cor-acc1             ,input tt-fin-doc.cor-acc1-value       ,input tt-fin-doc.curr-code            ,input tt-fin-doc.doc-date             ,input tt-fin-doc.shift-date           ,input tt-fin-doc.shift-num            ,input tt-fin-doc.shift-name           ,input tt-fin-doc.enclosure            ,input tt-fin-doc.exch-rate            ,input tt-fin-doc.exch-scale           ,input tt-fin-doc.f104                 ,input tt-fin-doc.f105                 ,input tt-fin-doc.f106                 ,input tt-fin-doc.f107                 ,input tt-fin-doc.f108                 ,input tt-fin-doc.f109                 ,input tt-fin-doc.f110                 ,input tt-fin-doc.f22                  ,input tt-fin-doc.f23                  ,input tt-fin-doc.fact-date            ,input tt-fin-doc.fin-doc-type         ,input tt-fin-doc.fin-ext-doc-type     ,input tt-fin-doc.in-doc-code          ,input tt-fin-doc.in-host-code         ,input tt-fin-doc.including            ,input tt-fin-doc.nazn-pl              ,input tt-fin-doc.naznach-plat         ,input tt-fin-doc.ocher-pl             ,input tt-fin-doc.out-doc-code         ,input tt-fin-doc.out-host-code        ,input tt-fin-doc.pay-date             ,input tt-fin-doc.payer-bank-name      ,input tt-fin-doc.payer-bank-city      ,input tt-fin-doc.payer-bik            ,input tt-fin-doc.payer-c-schet        ,input tt-fin-doc.payer-code           ,input tt-fin-doc.payer-code-schet     ,input tt-fin-doc.payer-dop1           ,input tt-fin-doc.payer-dop2           ,input tt-fin-doc.payer-inn            ,input tt-fin-doc.payer-kpp            ,input tt-fin-doc.payer-name           ,input tt-fin-doc.payer-okpo           ,input tt-fin-doc.payer-passport      ,input tt-fin-doc.payer-r-schet        ,input tt-fin-doc.payer-type           ,input tt-fin-doc.perm-date            ,input tt-fin-doc.prn-doc-code         ,input tt-fin-doc.PS                   ,input tt-fin-doc.receiver-bank-name   ,input tt-fin-doc.receiver-bank-city   ,input tt-fin-doc.receiver-bik         ,input tt-fin-doc.receiver-c-schet     ,input tt-fin-doc.receiver-code        ,input tt-fin-doc.receiver-code-schet  ,input tt-fin-doc.receiver-dop1        ,input tt-fin-doc.receiver-dop2        ,input tt-fin-doc.receiver-inn         ,input tt-fin-doc.receiver-kpp         ,input tt-fin-doc.receiver-name        ,input tt-fin-doc.receiver-okpo        ,input tt-fin-doc.receiver-passport    ,input tt-fin-doc.receiver-r-schet     ,input tt-fin-doc.receiver-type        ,input tt-fin-doc.srok-pl              ,input tt-fin-doc.stat-pl              ,input tt-fin-doc.str-podr-code        ,input tt-fin-doc.str-podr-type        ,input tt-fin-doc.str-podr-name        ,input tt-fin-doc.sum-base             ,input tt-fin-doc.sum-doc              ,input tt-fin-doc.sum-rubl             ,input tt-fin-doc.sum-contr            ,input tt-fin-doc.trn-doc-code         ,input tt-fin-doc.vid-opl              ,input tt-fin-doc.vid-plat
            ,input tt-fin-doc.con-sum-rubl         ,input tt-fin-doc.con-sum-base         ,input tt-fin-doc.con-sum-doc          ,input tt-fin-doc.con-sum-contr        ,input tt-fin-doc.con-stat             ,input tt-fin-doc.payer-sign1                ,input tt-fin-doc.payer-sign2                ,input tt-fin-doc.payer-sign3                ,input tt-fin-doc.payer-sign4                ,input tt-fin-doc.receiver-sign1                ,input tt-fin-doc.receiver-sign2                ,input tt-fin-doc.receiver-sign3                ,input tt-fin-doc.receiver-sign4                ,input tt-fin-doc.obj-type                   ,input tt-fin-doc.obj-code                   ,input tt-fin-doc.doc-author                 ,input tt-fin-doc.fact-author                ,input tt-fin-doc.CashBookId
            ,input table tt0-fin-doc-tax
            ,input table tt0-fin-doc-attr
            ,input no
            ,input table tt0-payment
      ) no-error.
    if error-status:error then
    do:
              if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
      undo _main, return error.
    end.
    find first buf_fin-doc share-lock where
      recid(buf_fin-doc) = v-doc-rec.
    assign
      buf_fin-doc.shift-flag = integer('1':U)
      .
    if buf_temp-fin-sumAvans.contr-kb ne ?
      then
    do:
      find first fin-doc-attr where fin-doc-attr.host-code eq buf_fin-doc.host-code
        and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
        and fin-doc-attr.attr-code eq "contr-kb"
        exclusive-lock no-error.
      if not available fin-doc-attr
        then
      do:
        create fin-doc-attr.
        assign
          fin-doc-attr.host-code    = buf_fin-doc.host-code
          fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
          fin-doc-attr.attr-code    = "contr-kb"
          .
      end.
      fin-doc-attr.attr-value = String(buf_temp-fin-sumAvans.contr-kb).
    end.
    run proc-close in this-procedure ( buffer buf_fin-doc) no-error.
    if error-status :error then
    do:
              if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
      undo _main, return error.
    END.
    if buf_fin-doc.status_ <> 'факт':U then
    do:
      run proc-close in this-procedure ( buffer buf_fin-doc) NO-ERROR.
      if error-status :error then
      do:
                  if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                        , return-value )).
        undo _main, return error.
      END.
    end.
    if buf_fin-doc.status_ <> 'факт':U then
    do:
      run proc-close in this-procedure ( buffer buf_fin-doc) no-error .
      if error-status :error then
      do:
                  if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                        , return-value )).
        undo _main, return error.
      END.
    end.
              if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Создаю &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8"                                   , entry (lookup ((if buf_temp-fin-sumAvans.tot-sum > 0 then 'пко':U else 'рко':U), 'пко,рко,ппп,рпп,апп,апр':U) + 1, ',':U + 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,приходный АПЗ,расходный АПЗ':U)                                    , buf_shift-obj.shift-name                                   , buf_shift-obj.shift-date                                   , buf_shift-obj.shift-nuM                                      , buf_shift-obj.obj-type                                   , buf_shift-obj.obj-code                                   , buf_temp-fin-sumAvans.cashbookid                                   , abs(buf_temp-fin-sumAvans.tot-sum)                                   , chr(10)                                   )).
   end.
  end.
  finally:
    delete object mCashBook no-error .
  end finally.
end procedure.
procedure load-ruleset-context :
  define input parameter p-ruleset-id as integer no-undo .
  define variable v-rowid    as rowid     no-undo .
  define variable v-tbl-name as character no-undo .
  define buffer buf_rule-call-param for ub.rule-call-param.
  main-block:
  do
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
    if g#news = yes then
    do:
      return "return".
    end.
    run gen-row-keyr in this-procedure (
      input  p-doc-code
      ,input ?
      ,input  "ub"
      ,input  ?
      ,input  no-lock
      ,output v-rowid
      ,output v-tbl-name ) .
    find first buf_shift-obj no-lock where
      rowid(buf_shift-obj) = v-rowid.
  end.
end procedure.
PROCEDURE StrTax :
  do
    on error undo, return error return-value
    :
    define input-output parameter str as character no-undo .
    define variable v-envd as logical no-undo .
    assign
      str = " В т.ч.: "  .
    for each tt0-fin-doc-tax :
      if str <> " В т.ч.: " then str = str + "," .
      if not tt0-fin-doc-tax.with-vat then assign str = str + "без налога (НДС) - (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
      else
      do:
        if tt-fin-doc.curr-code = 0 then
        do:
            case taxVne:
              when "vne" then
                do:
                  str = str + "без налога (НДС) - (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                end.
              when "avans" then
                do:
                  str = str + string(tt0-fin-doc-tax.vat-pc,">>9") + "/" + string(tt0-fin-doc-tax.vat-pc + 100,">>9") + " НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " руб. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                end.
              otherwise
              do:
                str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " руб. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
              end.
            end case .
        end.
        else
        do:
            case taxVne:
              when "vne" then
                do:
                  str = str + "без налога (НДС) - (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                end.
              when "avans" then
                do:
                  str = str + string(tt0-fin-doc-tax.vat-pc,">>9") + "/" + string(tt0-fin-doc-tax.vat-pc + 100,">>9") + " НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + "(от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
                end.
              otherwise
              do:
                str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + "(от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
              end.
            end case .
        end.
      end.
      if str = " В т.ч.: " then assign str = "" .
    end.
  end.
END PROCEDURE.
PROCEDURE RoundTax :
  do
    on error undo, return error return-value
    :
    for each tt0-fin-doc-tax :
      assign
        tt0-fin-doc-tax.sum-line-doc      = ROUND( tt0-fin-doc-tax.sum-line-doc      , 2)
        tt0-fin-doc-tax.sum-vat-line-doc  = ROUND( tt0-fin-doc-tax.sum-vat-line-doc  , 2)
        tt0-fin-doc-tax.sum-line-rubl     = ROUND( tt0-fin-doc-tax.sum-line-rubl     , 2)
        tt0-fin-doc-tax.sum-vat-line-rubl = ROUND( tt0-fin-doc-tax.sum-vat-line-rubl , 2)
        tt0-fin-doc-tax.sum-line-base     = ROUND( tt0-fin-doc-tax.sum-line-base     , 2)
        tt0-fin-doc-tax.sum-vat-line-base = ROUND( tt0-fin-doc-tax.sum-vat-line-base , 2)
        .
    end.
  end.
END PROCEDURE.
procedure proc-close :
  define parameter buffer buf_fin-doc for ub.fin-doc.
  define variable v-status_         as character no-undo .
  define variable v-old-status_     as character no-undo .
  define variable v-ask-date        as logical   no-undo .
  define variable v-ask-message     as character no-undo .
  define variable v-status-date-chr as character no-undo.
  define variable v-date1           as date      no-undo .
  assign
    v-old-status_ = buf_fin-doc.status_
    .
  run trg/findgraf.p (
    input  buf_fin-doc.host-code
    ,input  buf_fin-doc.fin-doc-code
    ,input  '<закрытие документа>':U
    ,input  ''
    ,input  v-old-status_
    ,input  ?
    ,output v-status_
    ,output v-ask-date
    ,output v-ask-message
    ) no-error.
  if error-status:error then
  do:
    return error substitute("Ошибка при проверке возможности &1&2&3"
      ,'<закрытие документа>':U
      , chr(10)
      , return-value ).
  end.
  v-date1 = buf_fin-doc.doc-date.
  run trg/findstat.p (
    input parparentproc
    ,input buf_fin-doc.host-code
    ,input buf_fin-doc.fin-doc-code
    ,input '<закрытие документа>':U
    ,input 'auto':U
    ,input v-status_
    ,input-output v-date1
    ,input no
    ) no-error .
  if error-status:error then
  do:
    return error substitute("Ошибка при переводе статуса финансового документа:&1&2&1&3"
      ,'<закрытие документа>':U
      , chr(10)
      , return-value ).
  end.
end procedure.
procedure check-petrol :
  define input  parameter p-b-code       like ub.chk-gds-pay.b-code no-undo.
  define output parameter p-is-petrolium as logical                 no-undo.
  define variable is-petrol as logical   no-undo.
  define variable is-pieces as logical   no-undo.
  define variable v-value   as character no-undo.
  define variable v-type    as character no-undo.
  define buffer buf_bar-code for ub.bar-code.
  define buffer buf_goods    for ub.goods.
  find first buf_bar-code no-lock where
    buf_bar-code.b-code = p-b-code no-error.
  if available buf_bar-code then
  do:
    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
    if available buf_goods then
    do:
      assign
        p-is-petrolium = false .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
  if  is-petrol = yes
    and is-pieces = no
    then
  do :
    run gds-attr-value in this-procedure (
      input buf_goods.gds-code
      ,input 'ptrl-as-good':U
      ,output v-value
      ,output v-type
      ) no-error.
    if NOT logical(v-value) = yes then
    do:
      assign
        p-is-petrolium = yes.
    end.
  end.
end.
end.
end procedure.
