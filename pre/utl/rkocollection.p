block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: 12c0f79a3864, 3013, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:44 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rkocollection.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/rkocollection.p $":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 24, набор 1".
define variable vi as integer no-undo.
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
run create_obj-list(v-cntxt-obj-type, v-cntxt-obj-code).
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-curr-r-b as character no-undo.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  output to "rkoincas.log" .
  output close.
define variable v-current-doc-code as character no-undo .
define variable log-file-name                as character      no-undo init "process-fdoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-last-error-message as character no-undo .
define variable file-name    as character no-undo.
define variable v-sign       as integer   no-undo.
define variable l-res        as integer   no-undo.
define variable v-es         as logical   no-undo.
define variable v-esm        as character no-undo.
define variable v-rv         as character no-undo.
define variable v-err-mess   as character no-undo.
define variable is-petrolium as logical   no-undo.
define variable o-uchet as character no-undo .
define variable v-uchet as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable par-type as character no-undo .
define variable v-tth as handle no-undo .
define variable mValue as character no-undo.
define variable mType as character no-undo.
define buffer buf_shift-obj for ub.shift-obj.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-error :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
     assign
     v-last-error-message = p-mess.
  end.
end procedure.
run str/diallog.w (parparentproc, this-procedure, 'str/get-chkf.p':U, (v-cntxt-obj-type + chr(4) + string(v-cntxt-obj-code) + chr(4) + string(0)), yes, '', 'Прием чеков с касс') .
define variable mCashBook         as class ibs.th.ref.cashbookstorage no-undo .
define variable p-by-cash-desk    as logical no-undo .
define variable p-by-petrol-goods as logical no-undo .
define variable p-by-osnovanie    as character  no-undo .
define variable p-by-pril         as character  no-undo .
find last buf_shift-obj
          where buf_shift-obj.obj-type    = v-cntxt-obj-type
            and buf_shift-obj.obj-code    = v-cntxt-obj-code
            and buf_shift-obj.status_  = 'тек':U
      no-error.
if not available buf_shift-obj
then do:
   message
      vss-workfile vss-revision vss-description skip
           "Ошибка при поиске текущей смены" skip
            "Объект"  v-cntxt-obj-type v-cntxt-obj-code skip
view-as alert-box error .
undo, return return-value .
end.
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
DEFINE TEMP-TABLE tt-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE ttc-fin-doc NO-UNDO LIKE ub.fin-doc.
DEFINE TEMP-TABLE tt0-fin-doc-attr NO-UNDO LIKE ub.fin-doc-attr.
DEFINE TEMP-TABLE tt0-fin-doc-tax NO-UNDO LIKE ub.fin-doc-tax.
DEFINE TEMP-TABLE tt0-payment NO-UNDO LIKE ub.payment.
define temp-table tt-cashBookOst no-undo
field chang      as logical
field cashbookid as int64
field cashbookname as character
field ost        as decimal
field ostrasch   as decimal
field osnpko     as decimal
field osnrko     as decimal
index pi cashbookid.
define temp-table temp-fin-sum no-undo
field cash-desk  as integer
field curr-code as integer
field tot-sum as decimal
field tot-base as decimal
field tot-rubl as decimal
field is-petrol as logical
field cashbookid as int64
field is-expense_cash as logical
field num-expense_cash as int
index pi is unique primary
num-expense_cash is-expense_cash cash-desk curr-code is-petrol cashbookid
.
define temp-table temp-gds no-undo
field with-vat as logical init yes
field b-code as integer
field node-code as integer
field doc-code as character
field doc-kind as character
field gds-code as integer
field artic as character
field prod-type as character
field prod-code as integer
field eff-doc-qnty as decimal
field tot-r-b as decimal
field tot-rubl as decimal
field tot-base as decimal
field tot-doc as decimal
field vat-base as decimal
field vat-rubl as decimal
field vat-doc as decimal
field curr-code as integer
field cash-desk  as integer
field is-petrol as logical
index pi is unique primary
cash-desk
b-code
doc-kind
curr-code
.
define temp-table temp-tax no-undo
field with-vat as logical init yes
field curr-code as integer
field vat-pc as decimal
field slt-pc as decimal
field vat-base as decimal
field vat-rubl as decimal
field vat-doc as decimal
field sum-base as decimal
field sum-rubl as decimal
field sum-doc as decimal
field cash-desk  as integer
field is-petrol as logical
field cashbookId as int64
field is-expense_cash as logical
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
.
define temp-table temp-z-number no-undo
field z-number as integer
field cash-desk as integer
index pi is unique primary
cash-desk z-number.
define temp-table temp-z-number-list no-undo
field cash-desk as integer
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
define variable fact-order      as decimal   no-undo .
define buffer buf_inkas          for ub.inkas.
define buffer buf_inkas-pay-desk for ub.inkas-pay-desk.
define buffer buf_cash-pay       for ub.cash-pay.
define buffer buf_temp-fin-sum   for temp-fin-sum.
define buffer buf_temp-fin-sum-Pko for temp-fin-sum.
define buffer buf_chk-gds-pay    for ub.chk-gds-pay.
define buffer buf_chk-doc        for ub.chk-doc.
define buffer buf_chk-pay        for ub.chk-pay.
define buffer buf_chk-pay-attr   for ub.chk-pay-attr.
define buffer buf_temp-gds       for temp-gds.
define buffer buf_bar-code       for ub.bar-code.
define buffer buf_goods          for ub.goods.
define buffer buf_sale-doc       for ub.sale-doc.
define buffer buf_trn-doc        for ub.trn-doc.
define buffer buf_doc-line       for ub.doc-line.
define buffer buf_gds-dtl        for ub.gds-dtl.
define buffer buf_temp-tax       for temp-tax.
define buffer buf_fin-doc        for ub.fin-doc.
define buffer buf_sysconf        for ub.sysconf.
define buffer buf_shift-staff    for ub.shift-staff.
define buffer buf_chk-gds        for ub.chk-gds.
mCashBook = new ibs.th.ref.cashbookstorage () .
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
define variable v-err               as logical    no-undo .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  buf_shift-obj.obj-type
  ,input  buf_shift-obj.obj-code
  ,output v-host-code
  ,output v-host-name
  )  .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdbnum in g#library
  (input  buf_shift-obj.obj-type
  ,input  buf_shift-obj.obj-code
  ,output v-obj-db-num
  )  .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
    find first buf_sysconf no-lock where
              buf_sysconf.host-code = v-host-code.
    find first buf_shift-staff no-lock
         where buf_shift-staff.obj-type   = buf_shift-obj.obj-type
           and buf_shift-staff.obj-code   = buf_shift-obj.obj-code
           and buf_shift-staff.shift-date = buf_shift-obj.shift-date
           and buf_shift-staff.shift-num  = buf_shift-obj.shift-num
           no-error.
    if not available buf_shift-staFF THEN DO:
       if buf_shift-obj.status_ = 'зкр':U then do:
          v-cashier = "адм".
       end.
       else do:
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
          if return-value = 'false':u then do:
                              if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Нельзя создать ордер на выручку, если кассир не определен")).
               undo, return error substitute("Нельзя создать ордер на выручку, если кассир не определен").
          END.
       end.
      v-cashier = v-value.
   end.
   else do:
      v-cashier = buf_shift-staff.name.
   end.
   define variable v-obj-date as date no-undo.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  buf_shift-obj.obj-type
  ,input  buf_shift-obj.obj-code
  ,output v-obj-date
  )  .
   block-chk:
   for each chk-doc where(  chk-doc.obj-type   = buf_shift-obj.obj-type
                      and chk-doc.obj-code     = buf_shift-obj.obj-code
                      and chk-doc.shift-date   = buf_shift-obj.shift-date
                      and chk-doc.shift-num    = buf_shift-obj.shift-num
                      )
                      or  (    chk-doc.obj-type eq buf_shift-obj.obj-type
                           and chk-doc.obj-code eq buf_shift-obj.obj-code
                           and chk-doc.out-code  = ?)
    no-lock:
       if     chk-doc.chk-type    ne integer('1':U)
          and chk-doc.chk-type    ne integer('6':U)
       then
          next block-chk.
       do vi = 1 to num-entries(chk-doc.office):
          if can-do('0,сум-ош,сер-ош,при-ош,опл-ош,скидка-ош,тов-ош,кол-ош,прт-ош':U,entry(vi,chk-doc.office))
          then do:
             next block-chk.
          end.
       end.
       run rep/r-pychone.p(parparentproc,chk-doc.doc-code).
       for each buf_chk-gds-pay where
           buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
        and buf_chk-gds-pay.algo-num = "1.8"
        and buf_chk-gds-pay.pay-code eq 1
       no-lock:
          run gds-attr-value in this-procedure (
                                         input buf_chk-gds-pay.gds-code
                                        ,input "cash-book-id"
                                        ,output mValue
                                        ,output mType) no-error.
          find first ub.CashBook no-lock where ub.CashBook.id = int64(mValue) no-error .
          if not available ub.CashBook
          then do :
             find first ub.CashBook no-lock where ub.CashBook.id = 0 no-error .
          end.
          if available ub.CashBook
          then do :
             p-by-cash-desk = no .
             p-by-petrol-goods = no .
          end.
          find first tt-cashBookOst where tt-cashBookOst.cashbookid eq CashBook.id
          no-error.
          if not available tt-cashBookOst
          then do:
             create tt-cashBookOst.
             assign
                tt-cashBookOst.cashbookid   =  CashBook.id
                tt-cashBookOst.cashbookname =  CashBook.CashBookName
             .
             run fostatok in this-procedure (
                 input   v-host-code
                  ,input   buf_shift-obj.obj-code
                  ,input   buf_shift-obj.obj-type
                  ,input   yes
                  ,input   buf_shift-obj.close-date - 1
                  ,input   v-obj-date
                  ,input   buf_shift-obj.shift-num
                  ,input   buf_shift-obj.shift-num
                  ,input   yes
                  ,input   0
                  ,input   CashBook.id
                  ,output  tt-cashBookOst.ostrasch
                  ,output  Fact-order)
                 no-error .
                 tt-cashBookOst.ost = tt-cashBookOst.ostrasch.
                   output to "rkoincas.log" append.
                   put unformatted "Кассовая книга " CashBook.id " остаток " tt-cashBookOst.ostrasch " статус " CashBook.Status_ skip.
                   output close.
          end.
          define variable msum as decimal no-undo.
          case buf_chk-gds-pay.curr-code:
             when 0 then do:
                assign
                   msum =  (if v-curr-r-b = 'rubl':U
                             then buf_chk-gds-pay.tot-r-b
                             else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate)
                           )
                 .
             end.
             when v-base-code then do:
                  assign
                     msum = (if v-curr-r-b = 'base':U
                             then buf_chk-gds-pay.tot-r-b
                             else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate)
                            )
                 .
             end.
          end case.
          find first buf_temp-fin-sum
               where buf_temp-fin-sum.curr-code = buf_chk-gds-pay.curr-code
                 and buf_temp-fin-sum.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                 and buf_temp-fin-sum.is-expense_cash = no
          no-error.
          if not available buf_temp-fin-sum
          then do:
             create buf_temp-fin-sum.
             assign
                buf_temp-fin-sum.curr-code = buf_chk-gds-pay.curr-code
                buf_temp-fin-sum.cash-desk = 0
                buf_temp-fin-sum.is-petrol = no
                buf_temp-fin-sum.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                buf_temp-fin-sum.is-expense_cash = no
                buf_temp-fin-sum.tot-rubl = tt-cashBookOst.ostrasch
                buf_temp-fin-sum.tot-base = tt-cashBookOst.ostrasch
                buf_temp-fin-sum.tot-sum =  tt-cashBookOst.ostrasch
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
              buf_temp-fin-sum.tot-sum = buf_temp-fin-sum.tot-sum + msum
              tt-cashBookOst.ostrasch = + tt-cashBookOst.ostrasch + msum
          .
                   output to "rkoincas.log" append.
                   put unformatted "Кассовая книга " CashBook.id " чек " chk-doc.doc-code " продажа " chk-doc.out-code " Товар " " - " " сумма " msum skip.
                   output close.
       end.
       if ub.chk-doc.out-code eq ?
       then
          for each buf_chk-gds-pay where
              buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
           and buf_chk-gds-pay.algo-num = "1.8"
          exclusive-lock:
             delete buf_chk-gds-pay.
          end.
    end.
    cashb:
    for each cashbook no-lock:
       find first tt-cashBookOst where tt-cashBookOst.cashbookid eq CashBook.id
       no-error.
       if not available tt-cashBookOst
       then do:
          create tt-cashBookOst.
          assign
             tt-cashBookOst.cashbookid   =  CashBook.id
             tt-cashBookOst.cashbookname =  CashBook.CashBookName
          .
          run fostatok in this-procedure (
                 input   v-host-code
                  ,input   buf_shift-obj.obj-code
                  ,input   buf_shift-obj.obj-type
                  ,input   yes
                  ,input   buf_shift-obj.close-date - 1
                  ,input   v-obj-date
                  ,input   buf_shift-obj.shift-num
                  ,input   buf_shift-obj.shift-num
                  ,input   yes
                  ,input   0
                  ,input   CashBook.id
                  ,output  tt-cashBookOst.ostrasch
                  ,output  Fact-order)
                 no-error .
          if ub.CashBook.Status_ = 1 and tt-cashBookOst.ostrasch = 0 then
          do:
              delete tt-cashBookOst.
              next cashb.
          end.
          tt-cashBookOst.ost = tt-cashBookOst.ostrasch.
          find first buf_temp-fin-sum
               where buf_temp-fin-sum.curr-code = 0
                 and buf_temp-fin-sum.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                 and buf_temp-fin-sum.is-expense_cash = no
          no-error.
          if not available buf_temp-fin-sum
          then do:
             create buf_temp-fin-sum.
             assign
                buf_temp-fin-sum.curr-code = 0
                buf_temp-fin-sum.cash-desk = 0
                buf_temp-fin-sum.is-petrol = no
                buf_temp-fin-sum.cashbookid = (if available ub.CashBook then ub.CashBook.id else 0)
                buf_temp-fin-sum.is-expense_cash = no
                 buf_temp-fin-sum.tot-rubl = tt-cashBookOst.ostrasch
              buf_temp-fin-sum.tot-base = tt-cashBookOst.ostrasch
              buf_temp-fin-sum.tot-sum = tt-cashBookOst.ostrasch
             .
          end.
       end.
       else
          tt-cashBookOst.ostrasch = round(tt-cashBookOst.ostrasch,2).
    end.
    define variable mSumAll as decimal no-undo.
    for each tt-cashBookOst where tt-cashBookOst.ostrasch > 0:
       mSumAll = mSumAll + tt-cashBookOst.ostrasch.
       tt-cashBookOst.chang = yes.
    end.
    for each tt-cashBookOst where tt-cashBookOst.cashbookid eq 0:
       tt-cashBookOst.chang = yes.
    end.
    define variable msumInc as decimal no-undo.
    define variable msumInc-save as decimal no-undo.
    define variable mOsnbag as character no-undo.
    define variable mMoney  as character no-undo.
    define variable mOk     as logical no-undo.
    run ref/incas.p (input-output table tt-cashBookOst
                   ,  input  mSumAll
                   , output msumInc
                   , output mOsnbag
                   , output mMoney
                   , output mOk).
    if not mOk then return.
    msumInc-save = msumInc.
    for each buf_temp-fin-sum where  buf_temp-fin-sum.num-expense_cash eq 0
                                and  buf_temp-fin-sum.is-expense_cash  eq no
                                   by buf_temp-fin-sum.cashbookid desc:
       find first tt-cashBookOst where tt-cashBookOst.cashbookid eq buf_temp-fin-sum.cashbookid and tt-cashBookOst.chang no-lock no-error.
       if available tt-cashBookOst
       then
          buf_temp-fin-sum.tot-sum = -1 * min (if  buf_temp-fin-sum.cashbookid ne 0 then max(buf_temp-fin-sum.tot-sum,0) else msumInc,msumInc).
       else
          buf_temp-fin-sum.tot-sum = 0.
       msumInc = msumInc + buf_temp-fin-sum.tot-sum.
       if buf_temp-fin-sum.tot-sum eq 0
       then delete buf_temp-fin-sum.
       else do:
          create buf_temp-tax.
          assign
             buf_temp-tax.curr-code        = buf_temp-fin-sum.curr-code
             buf_temp-tax.cash-desk        = buf_temp-fin-sum.cash-desk
             buf_temp-tax.is-petrol        = buf_temp-fin-sum.is-petrol
             buf_temp-tax.cashbookId       = buf_temp-fin-sum.cashbookid
             buf_temp-tax.is-expense_cash  = buf_temp-fin-sum.is-expense_cash
             buf_temp-tax.num-expense_cash = buf_temp-fin-sum.num-expense_cash
             buf_temp-tax.sum-rubl         = buf_temp-fin-sum.tot-sum
             buf_temp-tax.sum-base         = buf_temp-fin-sum.tot-sum
             buf_temp-tax.sum-doc          = buf_temp-fin-sum.tot-sum
          .
       end.
    end.
   for each temp-z-number
   break
   by temp-z-number.cash-desk
   :
     if first-of( temp-z-number.cash-desk) then do:
        find first temp-z-number-list
        where temp-z-number-list.cash-desk = temp-z-number.cash-desk no-error.
       if not available temp-z-number-list then do:
         create temp-z-number-list.
         assign
            temp-z-number-list.cash-desk = temp-z-number.cash-desk
          .
       end.
     end.
     assign
     v-naznach-plat = v-naznach-plat + (if v-naznach-plat = '' then '' else chr(44)) + string(temp-z-number.z-number)
     temp-z-number-list.naznach-plat = temp-z-number-list.naznach-plat + (if temp-z-number-list.naznach-plat = '' then '' else chr(44)) + string(temp-z-number.z-number)
     .
   end.
   v-naznach-plat = substitute("Z-отчет(ы) &1 от &2г.", v-naznach-plat, if v-uchet = "smen" then string(buf_shift-obj.shift-date, "99/99/99") else string(TODAY, "99/99/99")).
   for each temp-z-number-list:
     assign
     temp-z-number-list.naznach-plat = substitute("Z-отчет(ы) &1 от &2г.", temp-z-number-list.naznach-plat, if v-uchet = "smen" then string(buf_shift-obj.shift-date, "99/99/99") else string(TODAY, "99/99/99")).
   end.
   v-naznach-plat2 = v-naznach-plat .
   _temp-fin-sum:
   for each buf_temp-fin-sum no-lock
    by buf_temp-fin-sum.cashbookid desc
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :
      empty temp-table tt0-fin-doc-tax.
      empty temp-table tt0-fin-doc-attr.
      empty temp-table tt-fin-doc.
      if buf_temp-fin-sum.tot-sum = 0  then do:
        next _temp-fin-sum.
      end.
      v-naznach-plat = v-naznach-plat2 .
      find first ub.CashBook no-lock where ub.CashBook.id = buf_temp-fin-sum.CashBookId no-error .
      define variable mCashbookName as character no-undo.
      mCashbookName = string(ub.CashBook.id).
      if available CashBook then assign
         v-real-obj-type = mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, 'всем':U, 0, "CountCollect-type") .
         v-real-obj-code = int(mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, 'всем':U, 0, "CountCollect-code") ).
         mCashbookName = string(ub.CashBook.id) + " (" + CashBook.CashBookName + ")".
      .
      define variable v-doc-rec as recid no-undo .
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
                      ,input v-real-obj-type
                      ,input v-real-obj-code
                      ,input 0
                      ,input buf_temp-fin-sum.curr-code
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input 0
                      ,input buf_temp-fin-sum.cashbookid
                      ,input v-cashier
                      ,INPUT-OUTPUT table tt-fin-doc
                      ,INPUT-OUTPUT table ttc-fin-doc
                      ,output table tt0-fin-doc-attr
                      ,output v-limit-access ) no-error .
      if error-status:error then do:
                if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при заполнении фин.док-та значениями по умолчанию:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
        undo _main, return error substitute("Ошибки при заполнении фин.док-та значениями по умолчанию:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value ).
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
        if buf_temp-fin-sum.tot-sum > 0  then do :
          assign
            tt0-fin-doc-tax.sum-line-doc       = buf_temp-tax.sum-doc
            tt0-fin-doc-tax.sum-vat-line-doc   = buf_temp-tax.vat-doc
            tt0-fin-doc-tax.sum-line-rubl      = buf_temp-tax.sum-rubl
            tt0-fin-doc-tax.sum-vat-line-rubl  = buf_temp-tax.vat-rubl
            tt0-fin-doc-tax.sum-line-base      = buf_temp-tax.sum-base
            tt0-fin-doc-tax.sum-vat-line-base  = buf_temp-tax.vat-base
          .
        end.
        else do :
          assign
        tt0-fin-doc-tax.sum-line-doc       = abs(buf_temp-tax.sum-doc)
        tt0-fin-doc-tax.sum-vat-line-doc   = abs(buf_temp-tax.vat-doc)
        tt0-fin-doc-tax.sum-line-rubl      = abs(buf_temp-tax.sum-rubl)
        tt0-fin-doc-tax.sum-vat-line-rubl  = abs(buf_temp-tax.vat-rubl)
        tt0-fin-doc-tax.sum-line-base      = abs(buf_temp-tax.sum-base)
        tt0-fin-doc-tax.sum-vat-line-base  = abs(buf_temp-tax.vat-base)
        .
        end.
        find first temp-autotank no-lock
             where temp-autotank.curr-code = buf_temp-tax.curr-code
                                  and temp-autotank.pay-desk = buf_temp-tax.cash-desk
               and temp-autotank.is-petrol = buf_temp-tax.is-petrol
               and temp-autotank.vat-pc    = buf_temp-tax.vat-pc
               and temp-autotank.slt-pc    = buf_temp-tax.slt-pc
                                  no-error.
        if available temp-autotank then do:
          assign
           tt0-fin-doc-tax.sum-line-doc       =  tt0-fin-doc-tax.sum-line-doc + temp-autotank.sum-return
           tt0-fin-doc-tax.sum-vat-line-doc   =  tt0-fin-doc-tax.sum-vat-line-doc +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
           tt0-fin-doc-tax.sum-line-rubl      = tt0-fin-doc-tax.sum-line-rubl + temp-autotank.sum-return
           tt0-fin-doc-tax.sum-vat-line-rubl  = tt0-fin-doc-tax.sum-vat-line-rubl +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
           tt0-fin-doc-tax.sum-line-base      = tt0-fin-doc-tax.sum-line-base  + temp-autotank.sum-return
           tt0-fin-doc-tax.sum-vat-line-base  = tt0-fin-doc-tax.sum-vat-line-base  +
                                     round(temp-autotank.sum-return * tt0-fin-doc-tax.VAT-pc / (100 + tt0-fin-doc-tax.VAT-pc),2)
           .
        end.
        release tt0-fin-doc-tax.
      end.
      run StrTax in this-procedure ( input-output tt-fin-doc.including) .
      run RoundTax in this-procedure .
      if available ub.CashBook
      then do :
        p-by-cash-desk = ub.CashBook.FlagSepCash .
        p-by-petrol-goods = ub.CashBook.FlagSepFull .
        p-by-osnovanie = mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, 'всем':U, 0, "BasisIncas") .
        p-by-pril = ub.CashBook.RulePril .
      end.
      if p-by-cash-desk then do:
        find first temp-z-number-list no-lock
             where temp-z-number-list.cash-desk = buf_temp-fin-sum.cash-desk
             no-error.
        end.
      if trim(p-by-pril) = '0' then tt-fin-doc.enclosure = v-naznach-plat.
        v-naznach-plat = if cashbook.id eq 0 then "Поступление от продажи товаров" else "Прочие поступления".
        if available temp-z-number-list then temp-z-number-list.naznach-plat = 'Выручка от реализации'.
      assign
      tt-fin-doc.naznach-plat       = (if p-by-cash-desk
                                        then (if available temp-z-number-list
                                              then temp-z-number-list.naznach-plat
                                              else '')
                                        else  v-naznach-plat)
      .
      assign
      tt-fin-doc.CashBookId = buf_temp-fin-sum.cashbookid
      tt-fin-doc.sum-doc = abs(buf_temp-fin-sum.tot-sum)
      tt-fin-doc.sum-base = abs(buf_temp-fin-sum.tot-base)
      tt-fin-doc.sum-rubl = abs(buf_temp-fin-sum.tot-rubl)
      tt-fin-doc.exch-rate = abs(if buf_temp-fin-sum.curr-code = 0 then 1 else buf_temp-fin-sum.tot-rubl / buf_temp-fin-sum.tot-sum )
      tt-fin-doc.exch-scale = 1
      tt-fin-doc.base-rate = abs(if buf_temp-fin-sum.curr-code = v-base-code then 1 else buf_temp-fin-sum.tot-rubl / buf_temp-fin-sum.tot-base )
      tt-fin-doc.base-scale = 1
      .
      o-uchet   = mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "uchet") .
      if available ub.CashBook
      then do :
        tt-fin-doc.cor-acc-value  = mCashBook:getSinglRule(buf_temp-fin-sum.CashBookId, 'всем':U, 0, "CorrAcctIncas") .
        tt-fin-doc.cor-acc1-value = ub.CashBook.OsnAcct .
        FIND ub.fin-code-cor-acc WHERE
         ub.fin-code-cor-acc.code-value  = tt-fin-doc.cor-acc-value
         AND ub.fin-code-cor-acc.host-code  = tt-fin-doc.host-code
         AND  ub.fin-code-cor-acc.status_ = integer('0':U)
         NO-LOCK NO-error.
        if not available ub.fin-code-cor-acc
        then do:
          assign
            tt-fin-doc.cor-acc-value = chr(63)
          .
        end.
        else do:
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
        then do:
          assign
            tt-fin-doc.cor-acc1-value = chr(63)
          .
        end.
        else do:
          assign
            tt-fin-doc.cor-acc1 = ub.fin-code-cor-acc.fin-code
          .
        end.
      end.
      if tt-fin-doc.cor-acc1-value eq "" or tt-fin-doc.cor-acc1-value eq ?
      then do:
                if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не задан счет для инкасации"                                      )).
       undo _main, return error  substitute("Не задан счет для инкасации"                                      ).
      end.
      if o-uchet = "0"
      then v-uchet = "cal" .
      else v-uchet = "smen" .
       if buf_shift-obj.status_ = 'зкр':U and v-uchet = "smen" then do:
         assign
         tt-fin-doc.doc-date = buf_shift-obj.close-date
         tt-fin-doc.shift-date = buf_shift-obj.shift-date
         tt-fin-doc.shift-num  = buf_shift-obj.shift-num
         tt-fin-doc.shift-name = buf_shift-obj.shift-name
         .
       end.
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
      if error-status:error then do:
                if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
        undo _main, return error  substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value ).
      end.
      find first buf_fin-doc share-lock where
                recid(buf_fin-doc) = v-doc-rec.
      assign
      buf_fin-doc.shift-flag = integer('1':U)
      .
      find first fin-doc-attr where fin-doc-attr.host-code    eq buf_fin-doc.host-code
                                and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
                                and fin-doc-attr.attr-code    eq "pre-vedom"
                                exclusive-lock no-error.
      if not available fin-doc-attr
      then do:
         create fin-doc-attr.
         assign
            fin-doc-attr.host-code    = buf_fin-doc.host-code
            fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
            fin-doc-attr.attr-code    = "pre-vedom"
         .
      end.
      define variable mPin as character no-undo.
      mPin   = mCashBook:getSinglRule(buf_fin-doc.CashBookId, buf_fin-doc.obj-type, buf_fin-doc.obj-code, "Pin") .
      fin-doc-attr.attr-value = substitute("&1;&2;&3;&4;&5;&6;&7"
                                          ,mOsnbag
                                          ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BankDepos-code")
                                          ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BankRecip-code")
                                          ,mPin
                                          ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "SourceCode")
                                          ,msumInc-save
                                          ,mCashBook:getSinglRule(tt-fin-doc.CashBookId, tt-fin-doc.obj-type, tt-fin-doc.obj-code, "BankRecip-acct")).
      buf_fin-doc.enclosure     =  "№ сумки: " + entry(1,fin-doc-attr.attr-value,";") + " " + buf_fin-doc.enclosure.
      define variable Vparentrec as character no-undo.
      if Vparentrec eq ""
      then
         run gen-key-rec in this-procedure ("fin-doc",(buffer buf_fin-doc:handle),output Vparentrec ).
      find first fin-doc-attr where fin-doc-attr.host-code       eq buf_fin-doc.host-code
                                   and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
                                   and fin-doc-attr.attr-code    eq "ParentMoney"
                                   exclusive-lock no-error.
         if not available fin-doc-attr
         then do:
            create fin-doc-attr.
            assign
               fin-doc-attr.host-code    = buf_fin-doc.host-code
               fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
               fin-doc-attr.attr-code    = "ParentMoney"
            .
         end.
         fin-doc-attr.attr-value = Vparentrec.
      if mMoney ne ""
      then do:
         find first fin-doc-attr where fin-doc-attr.host-code eq buf_fin-doc.host-code
                                   and fin-doc-attr.fin-doc-code eq buf_fin-doc.fin-doc-code
                                   and fin-doc-attr.attr-code eq "cover_sheet"
                                   exclusive-lock no-error.
         if not available fin-doc-attr
         then do:
            create fin-doc-attr.
            assign
               fin-doc-attr.host-code    = buf_fin-doc.host-code
               fin-doc-attr.fin-doc-code = buf_fin-doc.fin-doc-code
               fin-doc-attr.attr-code    = "cover_sheet"
            .
         end.
         fin-doc-attr.attr-value = mMoney.
         mMoney = "".
      end.
      run proc-close in this-procedure ( buffer buf_fin-doc) no-error.
      if error-status :error then do:
                if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value )).
        undo _main, return error  substitute("Ошибки при сохранении фин.док-та:&1&2&1&3"                                    , chr(10)                                    , error-status:get-message(1)                                      , return-value ).
       END.
      if buf_fin-doc.status_ <> 'факт':U then do:
        run proc-close in this-procedure ( buffer buf_fin-doc) NO-ERROR.
        if error-status :error then do:
                    if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                        , return-value )).
          undo _main, return error  substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                        , return-value ).
        END.
      end.
      if buf_fin-doc.status_ <> 'факт':U then do:
        run proc-close in this-procedure ( buffer buf_fin-doc) no-error .
        if error-status :error then do:
                    if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                        , return-value )).
          undo _main, return error  substitute("Не удалось сменить статус фин.док-та:&1&2&1&3"                                      , chr(10)                                      , error-status:get-message(1)                                        , return-value ).
        END.
     end.
              if valid-handle(p-log-handle) then           run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Создаю &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8 &9"                                   , entry (lookup ((if buf_temp-fin-sum.tot-sum > 0 then 'пко':U else 'рко':U), 'пко,рко,ппп,рпп,апп,апр':U) + 1, ',':U + 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,приходный АПЗ,расходный АПЗ':U)                                    , buf_shift-obj.shift-name                                   , buf_shift-obj.shift-date                                   , buf_shift-obj.shift-nuM                                      , buf_shift-obj.obj-type                                   , buf_shift-obj.obj-code                                   , mCashbookName                                   , abs(buf_temp-fin-sum.tot-sum)                                   , chr(10)                                   )).
    message substitute("Создаю &1 для выручки по смене № &2 от &3 (П. &4)&8 для &5&6  по кассовой книге № &7 на сумму &8 &9"                                   , entry (lookup ((if buf_temp-fin-sum.tot-sum > 0 then 'пко':U else 'рко':U), 'пко,рко,ппп,рпп,апп,апр':U) + 1, ',':U + 'приходный кассовый ордер,расходный кассовый ордер,приходное платежное поручение,расходное платежное поручение,приходный АПЗ,расходный АПЗ':U)                                    , buf_shift-obj.shift-name                                   , buf_shift-obj.shift-date                                   , buf_shift-obj.shift-nuM                                      , buf_shift-obj.obj-type                                   , buf_shift-obj.obj-code                                   , mCashbookName                                   , abs(buf_temp-fin-sum.tot-sum)                                   , chr(10)                                   ) view-as alert-box.
   end.
  run rep/pre-vedom.p (
                  INPUT parParentProc
                ,input buf_fin-doc.host-code
                ,input buf_fin-doc.fin-doc-code
              ) no-error.
end.
finally:
    delete object mCashBook no-error .
end finally.
end procedure.
PROCEDURE StrTax :
  do
  on error undo, return error return-value
  :
    define input-output parameter str as character no-undo .
    define variable v-envd as logical no-undo .
    assign str = " В т.ч.: "  .
    for each tt0-fin-doc-tax :
      if str <> " В т.ч.: " then str = str + "," .
      if not tt0-fin-doc-tax.with-vat then assign str = str + "без НДС - (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
      else do:
      if tt-fin-doc.curr-code = 0 then do:
        assign str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " руб. (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
      end.
      else do:
        assign str = str + string(tt0-fin-doc-tax.vat-pc,">>9.9") + "% НДС - " + string(tt0-fin-doc-tax.sum-vat-line-doc) + " (от суммы " + string(tt0-fin-doc-tax.sum-line-doc) + ") " .
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
        tt0-fin-doc-tax.sum-line-doc       =  ROUND( tt0-fin-doc-tax.sum-line-doc      , 2)
        tt0-fin-doc-tax.sum-vat-line-doc   =  ROUND( tt0-fin-doc-tax.sum-vat-line-doc  , 2)
        tt0-fin-doc-tax.sum-line-rubl      =  ROUND( tt0-fin-doc-tax.sum-line-rubl     , 2)
        tt0-fin-doc-tax.sum-vat-line-rubl  =  ROUND( tt0-fin-doc-tax.sum-vat-line-rubl , 2)
        tt0-fin-doc-tax.sum-line-base      =  ROUND( tt0-fin-doc-tax.sum-line-base     , 2)
        tt0-fin-doc-tax.sum-vat-line-base  =  ROUND( tt0-fin-doc-tax.sum-vat-line-base , 2)
      .
    end.
  end.
END PROCEDURE.
procedure proc-close :
define parameter buffer buf_fin-doc for ub.fin-doc.
define variable v-status_ as character no-undo .
define variable v-old-status_ as character no-undo .
define variable v-ask-date as logical no-undo .
define variable v-ask-message as character no-undo .
define variable v-status-date-chr as character no-undo.
define variable v-date1 as date no-undo .
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
if error-status:error then do:
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
if error-status:error then do:
  return error substitute("Ошибка при переводе статуса финансового документа:&1&2&1&3"
                           ,'<закрытие документа>':U
                           , chr(10)
                           , return-value ).
end.
end procedure.
procedure check-petrol :
define input  parameter p-b-code       like ub.chk-gds-pay.b-code no-undo.
define output parameter p-is-petrolium as logical                 no-undo.
define variable is-petrol    as logical   no-undo.
define variable is-pieces    as logical   no-undo.
define variable v-value      as character no-undo.
define variable v-type       as character no-undo.
define buffer buf_bar-code       for ub.bar-code.
define buffer buf_goods          for ub.goods.
  find first buf_bar-code no-lock where
          buf_bar-code.b-code = p-b-code no-error.
  if available buf_bar-code then do:
    find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
    if available buf_goods then do:
      assign p-is-petrolium = false .
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
      then do :
        run gds-attr-value in this-procedure (
                                         input buf_goods.gds-code
                                        ,input 'ptrl-as-good':U
                                        ,output v-value
                                        ,output v-type
                                        ) no-error.
        if NOT logical(v-value) = yes then do:
          assign p-is-petrolium = yes.
        end.
      end.
    end.
  end.
end procedure.
