DEFINE TEMP-TABLE tt0-rp-by-call NO-UNDO LIKE ub.rp-by-call.
DEFINE TEMP-TABLE tt0-rule-by-call NO-UNDO LIKE ub.rule-by-call.
DEFINE NEW SHARED TEMP-TABLE tt0-rule-call-param NO-UNDO LIKE ub.rule-call-param.
DEFINE BUFFER X_rp-by-call FOR ub.rp-by-call.
DEFINE BUFFER X_rule FOR ub.rule.
DEFINE BUFFER X_rule-by-call FOR ub.rule-by-call.
DEFINE BUFFER X_rule-profile FOR ub.rule-profile.
DEFINE BUFFER X_ruleset FOR ub.ruleset.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск RUM".
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
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
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info3 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info3, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info3, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info3 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info3, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info3, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info3, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info3, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info3, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info3, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info3, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info3 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info3 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info3, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info3, v-inform, v-tbl-name ).
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
FUNCTION calldscr returns character ( input p-call-id as character):
define variable v-descr as character no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo.
define variable v-prop-label as character no-undo .
define variable v-node-label as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-host-code as integer no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-label as character no-undo .
define variable v-node-code as integer no-undo .
define buffer buf_prop-head for ub.prop-head.
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf_prop-map for ub.prop-map.
run gen-key-fv in this-procedure ( input p-call-id
                                  ,output v-field-list
                                  ,output v-value-list) no-error .
if error-status:error then return p-call-id.
CASE entry(1, p-call-id, chr(3)):
  when 'dis-card-type':U then do:
    v-descr = substitute("Тип ДК: эмитент &1 тип: &2"
                         ,integer(entry(lookup("emitent-host-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ,entry(lookup("type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card':U then do:
    v-descr = substitute("ДК: № &1"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'dis-card-property':U then do:
    v-dt-code = integer(entry(lookup("dt-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-node-code = integer(entry(lookup("node-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-host-code = integer(entry(lookup("host-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    v-obj-type = entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3)) .
    v-obj-code = integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) ).
    find first buf_prop-ref no-lock where
              buf_prop-ref.dt-code = v-dt-code no-error .
    if available buf_prop-ref then do:
      find first buf_prop-head no-lock where
                buf_prop-head.dtm-code = buf_prop-ref.dtm-code no-error .
      v-prop-label = buf_prop-head.prop-label.
      find first buf_prop-map no-lock where
                buf_prop-map.dtm-code = buf_prop-ref.dtm-code
            and buf_prop-map.node-code = v-node-code no-error .
      if available buf_prop-map then do:
        v-label = buf_prop-map.node-label.
      end.
    end.
    v-descr = substitute("ДК: № &1 &2:&3 &4"
                         ,entry(lookup("d-card", v-field-list, chr(3)), v-value-list, chr(3))
                         ,v-prop-label
                         ,v-label
                         ,get-region(v-host-code, v-obj-type, v-obj-code)
                         ).
  end.
  when 'clients':U then do:
    v-descr = substitute("&1&2"
                         ,entry(lookup("obj-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ,integer(entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3)) )
                         ).
  end.
  when 'ext-system':U then do:
    v-descr = substitute("Внешняя система &1"
                         ,integer(entry(lookup("esys-id", v-field-list, chr(3)), v-value-list, chr(3)))
                         ).
  end.
  WHEN 'thbj-attr':U then do:
    if entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum':U
    or entry(lookup("upper-prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rum_obj':U
    then do:
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'goods':U then do:
        v-descr = "Операции с товарами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'clients':U then do:
        v-descr = "Операции с клиентами".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'gds-grp':U then do:
        v-descr = "Операции с группами товаров".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'cli-grp':U then do:
        v-descr = "Операции с группами клиентов".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th':U then do:
        v-descr = "Операции с чеками на POS IBS-TH".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'chk-doc_ibs-th-mob':U then do:
        v-descr = "Операции с чеками на POS IBS-TH-MOB".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'edoc':U then do:
        v-descr = "Операции в системе электронного документооборота".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'thref':U then do:
        v-descr = "Операции со справочниками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'pdf':U then do:
        v-descr = "Операции с ДНЦ и переоценками".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'rep':U then do:
        v-descr = "Отчеты".
      end.
      if entry(lookup("prop-code", v-field-list, chr(3)), v-value-list, chr(3)) = 'ord':U then do:
        v-descr = "Операции с заказами".
      end.
    end.
  end.
  when 'cash-desk':U then do:
    v-descr = substitute("БД &1 Маг &2 Касса № &4 &3"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("obj-code", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("cash-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("pos-type", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
  when 'ext-file':U then do:
    v-descr = substitute("БД &1 Файл № &3 (из БД &2)"
                         ,entry(lookup("db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("from-db-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ,entry(lookup("file-num", v-field-list, chr(3)), v-value-list, chr(3))
                         ).
  end.
end case.
return v-descr.
end function.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-string no-undo
field v-string as character
field string-num as integer
index pi is unique primary string-num.
procedure temp-string_clear :
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    for each buf_temp-string
    on error undo, return error
    :
      delete buf_temp-string.
    end.
  end.
end procedure.
procedure temp-string_write :
  define input  parameter p-v-string    as character no-undo .
  define variable v-string-num as integer no-undo .
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    find last buf_temp-string no-error .
    if not available buf_temp-string then do:
      create buf_temp-string .
      assign
      buf_temp-string.string-num     = 1
      buf_temp-string.v-string       = p-v-string
      .
    end.
    else do:
      v-string-num = buf_temp-string.string-num.
      create buf_temp-string .
      assign
      buf_temp-string.string-num = v-string-num + 1
      buf_temp-string.v-string = p-v-string
      .
    end.
  end.
end procedure.
procedure temp-string_read :
  define input  parameter p-string-num    as integer   no-undo .
  define output parameter p-v-string      as character no-undo .
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    find first buf_temp-string
      where buf_temp-string.string-num     = p-string-num
      no-error .
    if available buf_temp-string then do:
      assign
        p-v-string = buf_temp-string.v-string
      .
    end.
    else do:
      assign
        p-v-string = '':U
      .
    end.
  end.
end procedure.
procedure temp-string_append :
  define input  parameter p-string-num  as integer   no-undo .
  define input  parameter p-v-string    as character no-undo .
  define input  parameter p-append-char as character no-undo .
  define buffer buf_temp-string for temp-string .
  do
  on error undo, return error return-value
  :
    find first buf_temp-string
         where buf_temp-string.string-num = p-string-num
      no-error .
    if not available buf_temp-string then do:
      create buf_temp-string .
      assign
        buf_temp-string.string-num  = p-string-num
        buf_temp-string.v-string    = p-v-string
      .
    end.
    else do:
        assign
        buf_temp-string.v-string = buf_temp-string.v-string + p-append-char + p-v-string
        .
    end.
  end.
end procedure.
procedure temp-string_get-last-num:
define output parameter p-string-num  as integer   no-undo .
define buffer buf_temp-string for temp-string .
find last buf_temp-string no-error.
if available buf_temp-string then do:
  p-string-num = buf_temp-string.string-num.
end.
end procedure.
procedure temp-string_delete-range:
define input parameter p-first-string-num  as integer   no-undo .
define input parameter p-last-string-num  as integer   no-undo .
define buffer buf_temp-string for temp-string .
for each buf_temp-string where
        buf_temp-string.string-num >= p-first-string-num
    and buf_temp-string.string-num <= p-last-string-num:
  delete buf_temp-string.
end.
end procedure.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure display-rule-call-params :
define input parameter p-mode as character no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-handle as handle no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.
define variable v-string as character no-undo .
do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  run temp-string_write in p-handle ( input "ПАРАМЕТРЫ").
  if p-mode = "text"
  or p-mode = "text-temp"
  then do:
    run temp-string_write in p-handle ( input "").
  end.
  _rr:
  for each buf_rule-call-param no-lock where
          buf_rule-call-param.codex_id = p-codex-id
      and buf_rule-call-param.ruleset_id = p-ruleset-id
      and buf_rule-call-param.call_id = p-call-id
      and buf_rule-call-param.order_id = p-order-id:
    if p-once-more >= 0 and
    buf_rule-call-param.once-more <> p-once-more then next.
    v-string = '':U.
    if lookup("LIST", buf_rule-call-param.param-3-data-type) > 0 then do:
      if buf_rule-call-param.p-index = 0 then do:
        assign
        v-string = buf_rule-call-param.param-label +  chr(32)  + "=".
        run temp-string_write in p-handle ( input v-string).
        next _rr.
      end.
      else do:
        assign
        v-string = fill( chr(32), length(buf_rule-call-param.param-label) + 2).
      end.
    end.
    else do:
      assign
      v-string = buf_rule-call-param.param-label +  chr(32)  + "=".
    end.
    CASE buf_rule-call-param.param-data-type:
      when 'character':U then do:
        v-string = v-string + buf_rule-call-param.param-value-character.
      end.
      when 'date':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-date, "99/99/9999").
      end.
      when 'logical':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-logical, "ДА/НЕТ").
      end.
      when 'decimal':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-decimal).
      end.
      when 'integer':U then do:
        v-string = v-string + string(buf_rule-call-param.param-value-integer).
      end.
    END CASE.
    run temp-string_write in p-handle ( input v-string).
  end.
  if p-mode = "text"
  or p-mode = "text-temp"
  then do:
    run temp-string_write in p-handle ( input "").
  end.
end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dops0 as character no-undo format "X(8)".
define variable dops as character no-undo format "X(250)".
define variable dopst as character no-undo format "X(1)".
define variable dopsp as character no-undo format "X(10)".
define variable v-conf-type as character no-undo .
define variable v-run as logical no-undo .
define variable v-profile-type as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-prop-code as character no-undo .
define variable v-codex-id as integer no-undo .
define variable v-ruleset-id as integer no-undo .
define variable v-ruleproc as character no-undo .
define variable v-current-file-name as character no-undo .
define variable v-current-file-index as integer no-undo .
DEFINE VARIABLE v-ii AS INTEGER NO-UNDO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-rp-by-call-uniq-key-rec as character no-undo .
define variable v-needs-ifile as logical no-undo .
define variable v-dop as character no-undo .
define buffer buf_thbj-attr for ub.thbj-attr.
DEFINE BUFFER buf_ruleset FOR ub.ruleset.
define buffer buf_rule-process for ub.rule-process.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure init-rule-call-params :
define input parameter p-uniq-key-rec as character no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_rule-call-param for ub.rule-call-param.
do
on error undo, return error
:
  empty temp-table temp-rule-call-param.
  for each buf_rule-call-param where
          buf_rule-call-param.call_id = p-uniq-key-rec:
    create buf_temp-rule-call-param.
    buffer-copy buf_rule-call-param to buf_temp-rule-call-param.
    if lookup("container", buf_rule-call-param.param-3-data-type) > 0 then do:
      find first buf_temp-rule-call-param where
            buf_temp-rule-call-param.call_id = p-uniq-key-rec
        and buf_temp-rule-call-param.codex_id = 0
        and buf_temp-rule-call-param.ruleset_id = 0
        and buf_temp-rule-call-param.order_id = 0
        and buf_temp-rule-call-param.param-name = buf_rule-call-param.param-name
        and buf_temp-rule-call-param.p-index = buf_rule-call-param.p-index no-error.
      if not available buf_temp-rule-call-param then do:
        create buf_temp-rule-call-param.
        buffer-copy buf_rule-call-param
        except
        codex_id
        ruleset_id
        order_id
        to buf_temp-rule-call-param.
      end.
    end.
  end.
end.
end procedure.
procedure update-rule-call-params :
define input parameter p-profile-type as character no-undo .
define input parameter p-uniq-key-rec as character no-undo .
do
on error undo, return error
:
  for each temp-rule-call-param where
          temp-rule-call-param.call_id = p-uniq-key-rec
      and temp-rule-call-param.codex_id = 0
      and temp-rule-call-param.ruleset_id = 0
      and temp-rule-call-param.order_id = 0:
    delete temp-rule-call-param.
  end.
  run rul/ruprcall.p (
                       input p-profile-type
                      ,input p-uniq-key-rec
                      ,input 'rule-call-param':U
                      ,input ?
                      ,input 0
                      ,INPUT TABLE tt0-rp-by-call
                      ,INPUT TABLE tt0-rule-by-call
                      ,INPUT TABLE temp-rule-call-param) no-error .
end.
end procedure.
procedure cb_rcps-run_get-value :
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT-output PARAMETER pp-index AS integer NO-UNDO.
DEFINE output parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE output parameter p-value-date AS date NO-UNDO.
DEFINE output parameter p-value-decimal AS decimal NO-UNDO.
DEFINE output parameter p-value-integer AS integer NO-UNDO.
DEFINE output parameter p-value-logical AS logical NO-UNDO.
define variable v-current-index as integer no-undo init -1.
define variable v-start as logical no-undo init yes.
DEFINE BUFFER buf_temp-rule-call-param FOR temp-rule-call-param.
do
on error undo, return error
:
 for each buf_temp-rule-call-param where
       buf_temp-rule-call-param.call_id = p-call-id
   and buf_temp-rule-call-param.codex_id = p-codex-id
   and buf_temp-rule-call-param.ruleset_id = p-ruleset-id
   and buf_temp-rule-call-param.order_id = p-order-id
   and buf_temp-rule-call-param.param-name = p-param-name
   and buf_temp-rule-call-param.p-index >= pp-index :
  if v-start then do:
      assign
      pp-index = buf_temp-rule-call-param.p-index
      p-value-character = buf_temp-rule-call-param.param-value-character
      p-value-date      = buf_temp-rule-call-param.param-value-date
      p-value-decimal   = buf_temp-rule-call-param.param-value-decimal
      p-value-integer   = buf_temp-rule-call-param.param-value-integer
      p-value-logical   = buf_temp-rule-call-param.param-value-logical
      v-start = no
      .
    end.
    else do:
      if buf_temp-rule-call-param.p-index > pp-index then do:
        v-current-index = buf_temp-rule-call-param.p-index.
        leave.
      end.
    end.
  end.
  pp-index = v-current-index.
end.
end procedure.
PROCEDURE cb_rcps-run_set-value :
DEFINE INPUT PARAMETER p-call-id AS CHARACTER NO-UNDO.
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-order-id as integer no-undo .
DEFINE INPUT PARAMETER p-param-name AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER pp-index AS integer NO-UNDO.
define input parameter p-param-mode as character no-undo .
DEFINE INPUT parameter p-value-character AS CHARACTER NO-UNDO.
DEFINE INPUT parameter p-value-date AS date NO-UNDO.
DEFINE INPUT parameter p-value-decimal AS decimal NO-UNDO.
DEFINE INPUT parameter p-value-integer AS integer NO-UNDO.
DEFINE INPUT parameter p-value-logical AS logical NO-UNDO.
define variable v-found as logical no-undo .
define variable v-rp-param-name as character no-undo .
DEFINE BUFFER buf_temp-rule-call-param FOR temp-rule-call-param.
DEFINE BUFFER buf2_temp-rule-call-param FOR temp-rule-call-param.
define buffer buf_rp-rule-param for ub.rp-rule-param.
find first buf_temp-rule-call-param WHERE
        buf_temp-rule-call-param.call_id = p-CALL-id
    AND buf_temp-rule-call-param.codex_id = p-codex-id
    AND buf_temp-rule-call-param.ruleset_id = p-ruleset-id
    AND buf_temp-rule-call-param.order_id = p-order-id
    AND buf_temp-rule-call-param.param-name = p-param-name
    AND buf_temp-rule-call-param.p-index = pp-index no-error.
if pp-index > 0
then do:
  if not available buf_temp-rule-call-param then do:
    find first buf2_temp-rule-call-param WHERE
            buf2_temp-rule-call-param.call_id = p-CALL-id
        AND buf2_temp-rule-call-param.codex_id = p-codex-id
        AND buf2_temp-rule-call-param.ruleset_id = p-ruleset-id
        AND buf2_temp-rule-call-param.order_id = p-order-id
        AND buf2_temp-rule-call-param.param-name = p-param-name
        AND buf2_temp-rule-call-param.p-index = 0 no-error.
    create buf_temp-rule-call-param.
    buffer-copy buf2_temp-rule-call-param
    except p-index
    to buf_temp-rule-call-param
    assign
    buf_temp-rule-call-param.p-index = pp-index
    .
  end.
end.
else do:
  if not available buf_temp-rule-call-param then do:
    undo, return error substitute("Отсутствует параметр &1/&6 для вызова &2 кодекс &3 набор правил &4 порядок &5"
                                  , p-param-name
                                  , p-call-id
                                  , p-codex-id
                                  , p-ruleset-id
                                  , p-order-id
                                  , pp-index).
  end.
end.
assign
buf_temp-rule-call-param.param-value-character = p-value-character
buf_temp-rule-call-param.param-value-date      = p-value-date
buf_temp-rule-call-param.param-value-decimal   = p-value-decimal
buf_temp-rule-call-param.param-value-integer   = p-value-integer
buf_temp-rule-call-param.param-value-logical   = p-value-logical
.
if not (p-codex-id = 0
        and
        p-ruleset-id = 0
        and
        p-order-id = 0)   then do:
find first buf_rp-rule-param no-lock where
         buf_rp-rule-param.profile_id = buf_temp-rule-call-param.profile_id
    and  buf_rp-rule-param.codex_id = p-codex-id
    and  buf_rp-rule-param.ruleset_id = p-ruleset-id
    and  buf_rp-rule-param.rule_id = buf_temp-rule-call-param.rule_id
    and  buf_rp-rule-param.rule-param-name = p-param-name.
assign
v-rp-param-name = buf_rp-rule-param.rp-param-name.
for each buf_rp-rule-param no-lock where
         buf_rp-rule-param.profile_id = buf_temp-rule-call-param.profile_id
     and buf_rp-rule-param.rp-param-name = v-rp-param-name,
    each buf2_temp-rule-call-param where
        buf2_temp-rule-call-param.call_id = p-call-id
    and buf2_temp-rule-call-param.profile_id = buf_temp-rule-call-param.profile_id
    and buf2_temp-rule-call-param.once-more = buf_temp-rule-call-param.once-more
    and buf2_temp-rule-call-param.codex_id = buf_rp-rule-param.codex_id
    and buf2_temp-rule-call-param.ruleset_id = buf_rp-rule-param.ruleset_id
    and buf2_temp-rule-call-param.param-name = buf_rp-rule-param.rule-param-name
    and buf2_temp-rule-call-param.p-index = pp-index
    :
  assign
  buf2_temp-rule-call-param.param-value-character = p-value-character
  buf2_temp-rule-call-param.param-value-date      = p-value-date
  buf2_temp-rule-call-param.param-value-decimal   = p-value-decimal
  buf2_temp-rule-call-param.param-value-integer   = p-value-integer
  buf2_temp-rule-call-param.param-value-logical   = p-value-logical
  .
end.
end.
end procedure.
procedure cb_rcps-run_fill-rcp-from-tt0 :
define input parameter p-call-id as character no-undo .
define input parameter p-bh as handle no-undo .
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
for each buf_tt0-rule-call-param where
       buf_tt0-rule-call-param.call_id = p-call-id
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
:
  p-bh:buffer-create ().
  p-bh:buffer-copy(buffer buf_tt0-rule-call-param:handle).
  p-bh:buffer-release.
end.
end procedure.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-param
     LABEL "&Параметры"
     SIZE 10 BY 1.
DEFINE BUTTON B-profile
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-rule
     LABEL "Правила"
     SIZE 10 BY 1.
DEFINE VARIABLE Ed-notes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 9.21
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
     VIEW-AS FILL-IN
     SIZE 78.5 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-rule-process AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Экспорт", "1"
     SIZE 71.5 BY 5 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      X_rule-profile,
      X_ruleset,
      X_rule-by-call,
      X_rp-by-call SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     rs-rule-process AT ROW 1 COL 22 NO-LABEL WIDGET-ID 22
     B-help AT ROW 1 COL 95
     ub.X_ruleset.name AT ROW 6 COL 1.5 NO-LABEL WIDGET-ID 28
          VIEW-AS EDITOR SCROLLBAR-VERTICAL
          SIZE 97 BY 2.5
     b-rule AT ROW 9 COL 77 WIDGET-ID 24
     b-param AT ROW 9 COL 87 WIDGET-ID 14
     X_rule-profile.name AT ROW 10 COL 14 COLON-ALIGNED WIDGET-ID 10
          LABEL "Профайл"
          VIEW-AS FILL-IN NATIVE
          SIZE 79 BY 1
          FGCOLOR 0
     B-profile AT ROW 10 COL 95 WIDGET-ID 12
     X_rp-by-call.once-more AT ROW 11 COL 14 COLON-ALIGNED WIDGET-ID 32
          LABEL "№ привязки" FORMAT ">>9"
          VIEW-AS FILL-IN NATIVE
          SIZE 4 BY 1
          FGCOLOR 0
     file-name AT ROW 12.25 COL 10
     B-file AT ROW 12.25 COL 95
     Ed-notes AT ROW 13.25 COL 1.5 NO-LABEL WIDGET-ID 30
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-file:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       Ed-notes:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       file-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  v-run = yes.
END.
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:
define variable v_os-file   AS CHAR NO-UNDO INIT "".
define variable ll_commit AS LOG    NO-UNDO INIT NO.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-txt-name as character no-undo .
define variable v-flt-name as character no-undo .
define variable glog as logical no-undo .
define variable v-needs-ifile as logical no-undo .
define variable v-needs-efile as logical no-undo .
define variable v-xml-file as logical no-undo .
define variable v-excel-file as logical no-undo .
define variable v-text-file as logical no-undo .
define variable v-dflt-extension as character no-undo .
define buffer buf_rule-process for ub.rule-process.
for each buf_rule-process no-lock where
          buf_rule-process.pchain-type = v-profile-type
      and buf_rule-process.pchain-id = rs-rule-process
      and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1):
if buf_rule-process.needs-ifile = 1 then do:
    v-needs-ifile = yes.
  end.
  if buf_rule-process.needs-efile = 1 then do:
    v-needs-efile = yes.
  end.
end.
if v-needs-ifile then do:
  if lookup( "xml", rs-rule-process, '-') > 0  then do:
    v-xml-file = yes.
  end.
  if lookup("excel", rs-rule-process, '-' ) > 0 then do:
    v-excel-file = yes.
  end.
  if lookup("text", rs-rule-process, '-') > 0 then do:
    v-text-file = yes.
  end.
  if rs-rule-process = "batchwork-import" then do:
    v-xml-file = yes.
  end.
  if v-xml-file then do:
  SYSTEM-DIALOG GET-FILE v_os-file
  TITLE "Задайте файл для импорта"
  FILTERS
    " Все XML файлы (*.xml) " "*.xml",
    " Все файлы (*.*) "                      "*.*"
  INITIAL-FILTER 1
  DEFAULT-EXTENSION ".xml"
  USE-FILENAME
  MUST-EXIST
  UPDATE ll_commit
  .
  end.
  if v-excel-file then do:
    SYSTEM-DIALOG GET-FILE v_os-file
    TITLE "Задайте файл для импорта"
    FILTERS
      " Все EXCEL файлы (*.xls,*.xlsx) " "*.xls,*.xlsx",
      " Все файлы (*.*) "                      "*.*"
    INITIAL-FILTER 1
    DEFAULT-EXTENSION ".xml"
    USE-FILENAME
    MUST-EXIST
    UPDATE ll_commit
    .
  end.
  if v-text-file then do:
    case rs-rule-process:
      when 'text-export_specif':U then do:
        assign
        v-txt-name = " Все TEXT файлы (*.txt), Все SPC файлы (*.spc) "
        v-flt-name = "*.txt, *.spc"
        .
      end.
      otherwise do:
        assign
        v-txt-name = " Все TEXT файлы (*.txt) "
        v-flt-name = "*.txt"
        .
      end.
    end case.
    SYSTEM-DIALOG GET-FILE v_os-file
    TITLE "Задайте файл для импорта"
    FILTERS
      v-txt-name  v-flt-name
      ," Все файлы (*.*) "                      "*.*"
    INITIAL-FILTER 1
    DEFAULT-EXTENSION ".xml"
    USE-FILENAME
    MUST-EXIST
    UPDATE ll_commit
    .
  end.
  IF ll_commit <> YES THEN do:
      RETURN NO-APPLY.
  end.
  IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
      BELL.
      MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
      RETURN NO-APPLY.
  END.
  ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
  run gbl/filename.p (
                  input  v_os-file
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
  if error-status:error  = ? then do:
    return no-apply.
  end.
  assign
  file-name = v-full-path.
  DISPlay
  file-name WITH FRAME Dialog-Frame.
END.
if v-needs-efile then do:
  if lookup( "xml", rs-rule-process, '-') > 0 then do:
    v-xml-file = yes.
  end.
  if lookup("excel", rs-rule-process, '-' ) > 0 then do:
    v-excel-file = yes.
  end.
  if lookup("text", rs-rule-process, '-') > 0 then do:
    v-text-file = yes.
  end.
  if rs-rule-process = "batchwork-export" then do:
    v-xml-file = yes.
  end.
  if v-xml-file then do:
  assign
  v_os-file = "default.xml"
  glog = yes
  .
  system-dialog get-file v_os-file
  filters "Файл экспорта *.xml" "*.xml"
  ask-overwrite
  save-as
  use-filename
  update glog
  default-extension "xml".
  end.
  if v-excel-file then do:
    assign
    v_os-file = "default.xls"
    glog = yes
    .
    system-dialog get-file v_os-file
    filters "Файл экспорта *.xls" "*.xls"
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension "xml".
  end.
  if v-text-file then do:
    case rs-rule-process:
      when 'text-export_specif':U then do:
        assign
        v-txt-name = " Все TEXT файлы (*.txt), Все SPC файлы (*.spc) "
        v-flt-name = "*.txt, *.spc"
        v_os-file = "default.spc"
        v-dflt-extension = "spc"
        .
      end.
      otherwise do:
        assign
        v-txt-name = " Все TEXT файлы (*.txt) "
        v-flt-name = "*.txt"
        v_os-file = "default.txt"
        v-dflt-extension = "txt"
        .
      end.
    end case.
    assign
    glog = yes
    .
    system-dialog get-file v_os-file
    filters v-txt-name v-flt-name
    ask-overwrite
    save-as
    use-filename
    update glog
    default-extension v-dflt-extension.
  end.
  if not glog then do:
    return no-apply.
  end.
  file-name = v_os-file.
  DISPlay
  file-name WITH FRAME Dialog-Frame.
    run gbl/filename.p (
                     input  file-name
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
    if not (error-status:error
    or v-full-path = ?
    or v-full-path = '':U) then do:
      message
      "Такой файл существует!" skip
      "перезаписывать?"
      view-as alert-box question buttons yes-no update glog.
      if not glog then return no-apply.
    end.
END.
END.
ON CHOOSE OF b-param IN FRAME Dialog-Frame
DO:
  RUN proc-b-param IN THIS-PROCEDURE ( input yes) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-profile IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable glog as logical no-undo .
define buffer buf_rule-by-profile for ub.rule-by-profile.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule-profile for ub.rule-profile.
IF AVAILABLE X_rp-by-call THEN DO:
   ASSIGN
   v-rid-list = STRING(RECID(X_rp-by-call)).
END.
run rul/rp-by-call-s.w ( INPUT parparentproc
                        ,INPUT "b-sel,instant":U
                        ,INPUT "call-id,ruleset-id"
                        ,INPUT 0
                        ,INPUT '':U
                        ,input v-uniq-key-rec
                        ,input v-codex-id
                        ,input v-ruleset-id
                        ,INPUT-OUTPUT v-rid-list
                        ) NO-ERROR.
if v-rid-list = '':U then RETURN NO-APPLY.
FIND FIRST buf_rp-by-call NO-LOCK WHERE
        recid(buf_rp-by-call) = integer(v-rid-list).
find first buf_rule-by-profile no-lock where
          buf_rule-by-profile.profile_id = buf_rp-by-call.profile_id
      and buf_rule-by-profile.codex_id = v-codeX-id
      and buf_rule-by-profile.ruleset_id = v-ruleset-id no-error.
if not available buf_rule-by-profile then do:
   message
   substitute("Для данного профайла не определено никаких правил")
   view-as alert-box error .
   return no-apply.
end.
find first buf_rule-profile no-lock where
          buf_rule-profile.profile_id = buf_rule-by-profile.profile_id.
if buf_rule-profile.action-item-id > '' then do:
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  buf_rule-profile.action-head-code
    ,input  buf_rule-profile.action-item-id
    ,input  buf_rule-profile.action-item-context
    ,input  (if buf_rule-profile.action-item-context = 'global':U then 0 else v-cntxt-host-code-obj)
    ,input  (if buf_rule-profile.action-item-context = 'object':U then v-cntxt-obj-type else '')
    ,input  (if buf_rule-profile.action-item-context = 'object':U then v-cntxt-obj-code else 0)
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
  if not glog then do:
   return no-apply.
  end.
end.
find first X_rp-by-call no-lock where
          recid(X_rp-by-call) = recid(buf_rp-by-call).
FIND FIRST X_rule-profile NO-LOCK WHERE
        X_rule-profile.profile_id = X_rp-by-call.profile_id.
DISPLAY
X_rule-profile.NAME
X_rp-by-call.once-more
WITH FRAME Dialog-Frame.
RUN  refill-rp-by-call IN THIS-PROCEDURE NO-ERROR.
ENABLE
b-param
b-rule
WITH FRAME Dialog-Frame.
run proc-b-type in this-procedure no-error.
if error-status:error then do:
  undo, return no-apply.
end.
END.
ON CHOOSE OF b-rule IN FRAME Dialog-Frame
DO:
   RUN proc-b-rule IN THIS-PROCEDURE NO-ERROR.
   IF ERROR-STATUS:error THEN RETURN NO-APPLY.
END.
ON LEAVE OF file-name IN FRAME Dialog-Frame
DO:
  CASE v-ruleproc:
    WHEN 'xml-file-import':U
    or
    WHEN 'xml-file-import':U
    or
    WHEN 'xml-file-import':U
    or
    WHEN 'xml-file-import_order':U
    or
    WHEN 'text-import_specif':U
    or
    WHEN 'excel-import_specif':U
    or
    when 'xml-file-import':U
        or
    when "recipe-xml-file-import":U
    THEN DO:
        ASSIGN file-name.
        IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
            ASSIGN FILE-INFO:FILE-NAME = file-name.
            IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
            DISP file-name WITH FRAME Dialog-Frame.
        END.
        APPLY "TAB":U TO file-name IN FRAME Dialog-Frame.
    END.
  END CASE.
END.
ON VALUE-CHANGED OF rs-rule-process IN FRAME Dialog-Frame
DO:
  define variable v-needs-ifile as logical no-undo .
  define variable v-needs-efile as logical no-undo .
  define buffer buf_rule-process for ub.rule-process.
  ASSIGN
  rs-rule-process.
  FILE-NAME = ''.
  IF AVAILABLE X_rp-by-call THEN RELEASE X_rp-by-call.
  IF AVAILABLE X_rule-profile THEN RELEASE X_rule-profile.
  X_rule-profile.NAME :SCREEN-VALUE = ''.
  disABLE
  FILE-NAME
  b-file
  WITH FRAME Dialog-Frame.
  hide
  FILE-NAME
  b-file
  IN FRAME Dialog-Frame.
  for each buf_rule-process no-lock where
            buf_rule-process.pchain-type = v-profile-type
        and buf_rule-process.pchain-id = rs-rule-process
        and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1):
    if buf_rule-process.needs-efile = 1 then do:
      v-needs-efile = yes.
    end.
    if buf_rule-process.needs-ifile = 1 then do:
      v-needs-ifile = yes.
    end.
  end.
  find first buf_rule-process no-lock where
            buf_rule-process.pchain-type = v-profile-type
        and buf_rule-process.pchain-id = rs-rule-process
      and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1)
      and buf_rule-process.main-link = 1.
  ASSIGN
  v-ruleset-id = integer(buf_rule-process.ruleset_id)
  v-ruleproc = rs-rule-process
  .
  if v-needs-efile = yes then do:
    ENABLE
    FILE-NAME
    b-file
    WITH FRAME Dialog-Frame.
    DISPLAY
    FILE-NAME
    b-file
    WITH FRAME Dialog-Frame.
  end.
  if v-needs-ifile = yes then do:
    ENABLE
    FILE-NAME
    b-file
    WITH FRAME Dialog-Frame.
    DISPLAY
    FILE-NAME
    b-file
    WITH FRAME Dialog-Frame.
  end.
  FIND first X_ruleset no-lock where
        X_ruleset.codex_id = v-codex-id
    and X_ruleset.ruleset_id = v-ruleset-id.
  DISPLAY
  X_ruleset.NAME
  WITH FRAME Dialog-Frame.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
procedure rcpscont_get-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define output parameter p-on-off as logical no-undo .
define buffer buf_tt0-rule-by-call for ub.rule-by-call.
find first buf_tt0-rule-by-call where
         buf_tt0-rule-by-call.codex_id = p-codex-id
     and buf_tt0-rule-by-call.ruleset_id = p-ruleset-id
     and buf_tt0-rule-by-call.profile_id = p-profile-id
     and buf_tt0-rule-by-call.once-more = p-once-more
     and buf_tt0-rule-by-call.rule_id = p-rule-id
     no-error .
if available buf_tt0-rule-by-call then do:
   p-on-off = buf_tt0-rule-by-call.can-calc.
end.
end procedure.
procedure rcpscont_set-rule-on-off :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer no-undo .
define input parameter p-on-off as logical no-undo .
define variable v-h as handle no-undo .
define buffer buf_tt0-rule-by-call for ub.rule-by-call.
v-h = buffer ub.rule-by-call:handle.
if v-h:table <> ''
and v-h:table <> ? then do:
  find first buf_tt0-rule-by-call where
          buf_tt0-rule-by-call.codex_id = p-codex-id
      and buf_tt0-rule-by-call.ruleset_id = p-ruleset-id
      and buf_tt0-rule-by-call.profile_id = p-profile-id
      and buf_tt0-rule-by-call.once-more = p-once-more
      and buf_tt0-rule-by-call.rule_id = p-rule-id   no-error .
  if not available buf_tt0-rule-by-call then do:
    undo, return error .
  end.
  buf_tt0-rule-by-call.can-calc = p-on-off .
  release buf_tt0-rule-by-call.
end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  v-profile-type = entry(1, p-parameter, chr(4)).
  v-dop = (if num-entries(p-parameter, chr(4)) > 2
           then entry(3, p-parameter, chr(4))
           else '').
  find first buf_rule-process no-error.
  if not available buf_rule-process
  then do:
    message
      "Нарушение целосности машины правил: нет записей в таблице rule-process. Обратитесь к администратору системы"
      view-as alert-box error.
    undo, return error.
  end.
  case v-profile-type:
    when 'goods':U then do:
      v-prop-code = 'goods':U.
      v-codex-id = 11.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame Dialog-Frame:title = buf_ruleset.name.
    end.
    when 'clients':U then do:
      v-prop-code = 'clients':U.
      v-codex-id = 12.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame Dialog-Frame:title = buf_ruleset.name.
    end.
    when 'gds-grp':U then do:
      v-prop-code = 'gds-grp':U.
      v-codex-id = 13.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame Dialog-Frame:title = buf_ruleset.name.
    end.
    when 'cli-grp':U then do:
      v-prop-code = 'cli-grp':U.
      v-codex-id = 14.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame Dialog-Frame:title = buf_ruleset.name.
    end.
    when 'edoc':U then do:
      v-prop-code = 'edoc':U.
      v-codex-id = 18.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame Dialog-Frame:title = buf_ruleset.name.
    end.
    when 'thref':U then do:
      v-prop-code = 'thref':U.
      v-codex-id = 20.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame Dialog-Frame:title = buf_ruleset.name.
    end.
    when 'rep':U then do:
      v-prop-code = 'rep':U.
      v-codex-id = 22.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame Dialog-Frame:title = buf_ruleset.name.
    end.
    when 'ord':U then do:
      v-prop-code = 'ord':U.
      v-codex-id = 23.
      FIND FIRST buf_ruleset NO-LOCK WHERE
          buf_ruleset.codex_id = v-codex-id
          AND buf_ruleset.ruleset_id = 0.
      ASSIGN
      frame Dialog-Frame:title = buf_ruleset.name.
    end.
  end case.
  DO v-ii = 1 TO NUM-ENTRIES(ENTRY(2, p-parameter, chr(4))) by 2:
      FIND FIRST buf_rule-process NO-LOCK WHERE
                buf_rule-process.pchain-type = entry(1, p-parameter, chr(4))
           AND buf_rule-process.pchain-id = entry(v-ii, ENTRY(2, p-parameter, chr(4))) NO-ERROR.
      IF NOT AVAILABLE buf_rule-process THEN DO:
          MESSAGE
          "Неверное значение параметра p-parameter" SKIP
          substitute("Не удается найти процесс &1 для типа процесса &2"
                     , entry(v-ii , ENTRY(2, p-parameter, chr(4)))
                     , entry(1, p-parameter, chr(4)))
         VIEW-AS ALERT-BOX ERROR.
          UNDO, RETURN ERROR.
      END.
  END.
  find first buf_thbj-attr no-lock where
            buf_thbj-attr.upper-prop-code = 'rum':U
        and buf_thbj-attr.prop-code = v-prop-code
        and buf_thbj-attr.obj-type = ''
        and buf_thbj-attr.obj-code = 0
        and buf_thbj-attr.property-value-logical = yes
        no-error.
  if not available buf_thbj-attr then do:
    find first buf_ruleset no-lock where
              buf_ruleset.codex_id = v-codex-id
          and buf_ruleset.ruleset_id = 0.
    message
    substitute("В Вашей системе нет настроек &1", buf_ruleset.name)
    view-as alert-box error .
    undo, return ''.
  end.
  run gen-key-rec in this-procedure (
                                    input  'thbj-attr':U
                                   ,input (buffer buf_thbj-attr:handle)
                                   ,output v-uniq-key-rec).
  run Myenable in this-procedure .
  if rs-rule-process:num-buttons = 1 then do:
    apply "CHOOSE" to b-profile.
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
run disable_UI in this-procedure .
for each buf_rule-process no-lock where
          buf_rule-process.pchain-type = v-profile-type
      and buf_rule-process.pchain-id = rs-rule-process
      and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1) :
  if buf_rule-process.needs-ifile = 1  then do:
    v-needs-ifile = yes.
  end.
end.
assign
v-current-file-name = file-name.
if v-run then do:
  _do:
  do while v-current-file-index >= 0 :
    case v-prop-code:
      when 'goods':U then do:
        if not available X_rp-by-call then do:
          message
          "Не выбрана привязка к алгоритму"
          view-as alert-box error .
        end.
        if v-ruleproc = 'goods-batchwork':U
        then do:
          run cb_set-rp-by-call in p-parent-handle (
                                                      input X_rp-by-call.call_id
                                                    ,input X_rp-by-call.profile_id
                                                    ,input X_rp-by-call.once-more
                                                    ,input table tt0-rule-call-param
                                                    ).
        end.
        else do:
        run str/goodsrum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id
          ,input v-codex-id
          ,input v-ruleset-id
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( string(next-value(s-v-doc, ub)) + chr(4) +
                        v-current-file-name
                  )
          ,input yes
          ) no-error .
      end.
      end.
      when 'clients':U then do:
        run str/clisrum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id
          ,input v-codex-id
          ,input v-ruleset-id
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( string(next-value(s-v-doc, ub)) + chr(4) +
                        v-current-file-name
                  )
          ,input yes
          ) no-error .
      end.
      when 'gds-grp':U then do:
        run str/ggrprum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id
          ,input v-codex-id
          ,input v-ruleset-id
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( string(next-value(s-v-doc, ub)) + chr(4) +
                        v-current-file-name
                  )
          ,input yes
          ) no-error .
      end.
      when 'cli-grp':U then do:
        run str/cgrprum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id
          ,input v-codex-id
          ,input v-ruleset-id
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( string(next-value(s-v-doc, ub)) + chr(4) +
                        v-current-file-name
                  )
          ,input yes
          ) no-error .
      end.
      when 'edoc':U then do:
        run str/edocrum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id
          ,input v-codex-id
          ,input v-ruleset-id
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( v-dop + chr(4) +
                        v-current-file-name
                  )
          ,input yes
          ) no-error .
      end.
      when 'thref':U then do:
        run ref/threfrum.p
          (
          input parparentproc
          ,input p-parent-handle
          ,input p-log-handle
          ,input v-ruleproc
          ,input X_rule-profile.profile_id
          ,input v-codex-id
          ,input v-ruleset-id
          ,input v-cntxt-db-num
          ,input v-uniq-key-rec
          ,input ( string(next-value(s-v-doc, ub)) + chr(4) +
                        v-current-file-name
                  )
          ,input yes
          ) no-error .
      end.
      when 'rep':U
      or
      when 'ord':U
      then do:
        if not available X_rp-by-call then do:
          message
          "Не выбрана привязка к алгоритму"
          view-as alert-box error .
        end.
        else do:
          if v-ruleproc = 'batchwork':U
          or v-ruleproc = 'batchwork':U
          then do:
            run cb_set-rp-by-call in p-parent-handle (
                                                       input X_rp-by-call.call_id
                                                      ,input X_rp-by-call.profile_id
                                                      ,input X_rp-by-call.once-more
                                                      ,input table tt0-rule-call-param
                                                      ).
          end.
          else do:
              message "Не обработано!"
              view-as alert-box .
          end.
        end.
      end.
    end case.
    if v-needs-ifile then do:
      v-current-file-index = v-current-file-index  + 1.
      assign
      v-current-file-name = rum-fn_get-next-file-name ( file-name, v-current-file-index)
      no-error.
      if error-status:error then do:
        if v-current-file-index = 1 then do:
          v-current-file-index = -2.
        end.
        else do:
          v-current-file-index = -1.
        end.
        leave _do.
      end.
      assign
      file-info:file-name = v-current-file-name
      .
      run gbl/filename.p (
                     input  v-current-file-name
                    ,output v-full-path
                    ,output v-path
                    ,output v-file-name
                    ,output v-file-name-no-ext
                    ,output v-file-name-ext
                    ) no-error .
      if error-status:error then do:
        if v-current-file-index = 0 then do:
          v-current-file-index = -2.
        end.
        else do:
          v-current-file-index = -1.
        end.
        leave _do.
      end.
    end.
    else do:
      leave _do.
    end.
  end.
  if error-status:error
  and v-current-file-index = -2
  then do:
    message
    error-status:get-message(1) view-as alert-box .
    undo, return error return-value .
  end.
end.
else do:
  return "return".
end.
PROCEDURE add-lines :
DEFINE BUFFER buf_temp-string FOR temp-string.
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
for each buf_temp-string:
  glog = ed-notes:INSERT-STRING ( buf_temp-string.v-string ) in frame Dialog-Frame .
  glog = ed-notes:INSERT-STRING ( chr(10) ) in frame Dialog-Frame .
end.
END PROCEDURE.
PROCEDURE cb_thbjrumr_is-running :
DEFINE OUTPUT PARAMETER p-is-running AS LOGICAL NO-UNDO.
p-is-running = YES.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH X_rule-profile SHARE-LOCK,       EACH X_ruleset WHERE TRUE  SHARE-LOCK,       EACH X_rule-by-call WHERE TRUE  SHARE-LOCK,       EACH X_rp-by-call WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY rs-rule-process file-name Ed-notes
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_rp-by-call THEN
    DISPLAY X_rp-by-call.once-more
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_rule-profile THEN
    DISPLAY X_rule-profile.name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE X_ruleset THEN
    DISPLAY X_ruleset.name
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-quit rs-rule-process B-help X_ruleset.name b-rule b-param
         X_rule-profile.name B-profile X_rp-by-call.once-more file-name B-file
         Ed-notes
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
define variable v-ii as integer no-undo .
define variable v-name as character no-undo .
define buffer buf_rule-process for ub.rule-process.
do v-ii = 1 to num-entries(ENTRY(2, p-parameter, chr(4))):
  find first buf_rule-process no-lock where
            buf_rule-process.pchain-type = ENTRY(1, p-parameter, chr(4))
        and buf_rule-process.pchain-id = entry(v-ii, ENTRY(2, p-parameter, chr(4)))
        and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1) no-error .
if not available buf_rule-process then do:
  message
  substitute("Не найден процесс &1 типа &2 для &3"
             ,entry(v-ii, ENTRY(2, p-parameter, chr(4)))
             ,ENTRY(1, p-parameter, chr(4))
             ,(if v-cntxt-db-num = 0 then "ГБД" else "УБД")
             )
  view-as alert-box error .
  return error.
end.
case entry(1, p-parameter, chr(4)):
  when 'clients':U then do:
    v-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import,text-import,text-export,cliadd,cliupdate':U) + 1, ',' + 'Операции по списку-экспорт,Операции по списку-маршрутизация,Импорт из xml-файла,Импорт из ВС,Импорт данных в текст.виде,Экспорт данных в текст.виде,Добавление клиента,Изменение клиента':U).
  end.
  when 'goods':U then do:
    v-name = entry (lookup (buf_rule-process.pchain-id, 'gdsadd,gdsupdate,rengdscode,addlcode,dellcode,updatelcode,addprcode,delprcode,updateprcode,xml-file-import,xml-esys-import,batchwork-export,batchwork-routing,rest-update,goods-cd-send,goods-batchwork,add-good-to-asm,del-good-from-asm':U) + 1, ',' + 'Добавление товара,Изменение товара,Смена кода товара,Добавление лок.кода,Удаление лок.кода,Изменение лок.кода,Добавление Доп.БК,Удаление Доп.БК,Изменение Доп.БК,Импорт из xml-файла,Импорт из ВС,Операции по списку-экспорт,Операции по списку-маршрутизация,Изменение остатка,Передача товаров на кассу,Работа в атоматическом режиме,add-good-to-asm,del-good-from-asm':U).
  end.
  when 'gds-grp':U then do:
    v-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import':U) + 1, ',' + 'Операции по списку-экспорт,Операции по списку-маршрутизация,Импорт из xml-файла,Импорт из ВС':U).
  end.
  when 'cli-grp':U then do:
    v-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import':U) + 1, ',' + 'Операции по списку-экспорт,Операции по списку-маршрутизация,Импорт из xml-файла,Импорт из ВС':U).
  end.
  when 'edoc':U then do:
    v-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork-export_order,batchwork-routing_order,xml-esys-import_order,xml-file-import_order,batchwork-export_rcv,batchwork-routing_rcv,xml-esys-import_rcv,xml-file-import_rcv,batchwork-routing_price-doc,xml-esys-import_price-doc,xml-esys-import_trn-doc,batchwork-routing_trn-doc,xml-esys-import_inv-doc,xml-esys-import_contract,batchwork-routing_intorder,xml-esys-import_intorder,batchwork-routing_inkas,event_order,event_rcv,event_trn-doc,event_inv-doc,event_intorder,event_price-doc,event_inkas,text-export_specif,excel-export_specif,text-import_specif,excel-import_specif':U) + 1, ',' + 'Заказы поставщику-экспорт,Заказы поставщику-маршрутизация,Заказы поставщику-импорт из ВС,Заказы поставщику-импорт из xml-файла,Поставки поставщика-экспорт,Поставки поставщика-маршрутизация,Поставка поставщика-импорт из ВС,Поставка поставщика-импорт из xml-файла,ДНЦ/переоценка-маршрутизация,ДНЦ-импорт из ВС,Накладные-импорт из ВС,Накладные-маршрутизация,Инвентаризации-импорт из ВС,Дог-ра и специф-ции-импорт из ВС,Заявки РЦ-маршрутизация,Заявки РЦ-импорт из ВС,Док-ты продажи-маршрутизация,Заказы поставщику-событие,Поставки поставщика-событие,Накладные-событие,Инвентаризация-событие,Заявки РЦ-событие,ДНЦ/переоценка-событие,Документ продажи-событие,Экспорт спецификации в текст.файл,Экспорт спецификации в Excel,Импорт спецификации из текст.файла,Импорт спецификации из Excel':U).
  end.
  when 'thref':U then do:
    v-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork-export,batchwork-routing,xml-file-import,xml-esys-import,recadd,recupdate,ref-event':U) + 1, ',' + 'Операции по списку-экспорт,Операции по списку-маршрутизация,Импорт из xml-файла,Импорт из ВС,Добавление записи,Изменение записи,События справочников':U).
  end.
  when 'rep':U then do:
    v-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork,close-shift':U) + 1, ',' + 'Выполнение отчета по расписанию,Выполнение отчета при закрытии смены':U).
  end.
  when 'ord':U then do:
    v-name = entry (lookup (buf_rule-process.pchain-id, 'batchwork':U) + 1, ',' + 'Работа с заказами по расписанию':U).
  end.
end case.
  assign
  rs-rule-process:RADIO-BUTTONS IN FRAME Dialog-Frame = (if v-ii = 1 then '' else ((rs-rule-process:RADIO-BUTTONS IN FRAME Dialog-Frame) + chr(44))) +
                                                    v-name + chr(44) + buf_rule-process.pchain-id
  .
end.
ASSIGN
rs-rule-process = ENTRY(1, ENTRY(2, p-parameter, chr(4)))
.
assign
X_rule-profile.name:read-only in frame Dialog-Frame = yes
X_rp-by-call.once-more:read-only in frame Dialog-Frame = yes
.
DISPLAY
rs-rule-process
file-name
WITH FRAME Dialog-Frame .
ENABLE
rs-rule-process
b-exit
B-quit
B-help
file-name
B-file
b-profile
ed-notes
X_ruleset.NAME
X_rule-profile.name
X_rp-by-call.once-more
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
APPLY "VALUE-CHANGED" TO rs-rule-process.
END PROCEDURE.
PROCEDURE proc-b-param :
define input parameter p-from-button as logical no-undo .
if not available X_rule-profile then do:
  message
  "Сначала необходимо выбрать профайл"
  view-as alert-box error .
  return error.
end.
define variable v-list-mode as character no-undo .
define variable v-param-form as character no-undo .
define variable v-is-esys-import as logical no-undo .
define variable v-is-routing as logical no-undo .
define buffer buf_rule-process for ub.rule-process.
for each buf_rule-process no-lock where
          buf_rule-process.pchain-type = v-profile-type
      and buf_rule-process.pchain-id = rs-rule-process
      and buf_rule-process.start-from = (if v-cntxt-db-num = 0 then 0 else 1):
  if buf_rule-process.is-esys-import = 1  then v-is-esys-import = yes.
  if buf_rule-process.is-routing = 1 then v-is-routing = yes.
end.
assign
v-param-form = (if X_rule-profile.custom-param-form > 0
                then  substitute("rul/rcps-&1.w", X_rule-profile.profile_id)
                else "ref/rulercps.w")
v-list-mode = (if X_rule-profile.custom-param-form > 0
               then 'rp-rule-param':U
               else 'rule-call-param':U)
.
run value(v-param-form) (
                     input parparentproc
                    ,input this-procedure:handle
                    ,input (if not (v-is-esys-import or  v-is-routing )
                            and v-ruleproc <> 'batchwork':U
                           and v-ruleproc <> 'batchwork':U
                           and v-ruleproc <> 'goods-batchwork':U
                           then "b-chg,running":U
                           else 'running')
                    ,input (if not (v-is-esys-import or v-is-routing )
                           then 'ИЗМЕНЕНИЕ':U
                           else 'ПРОСМОТР':U)
                    ,input v-list-mode
                    ,input X_rule-profile.profile_id
                    ,input X_rp-by-call.once-more
                    ,input X_rp-by-call.call_id
                    ,input 0
                    ,input 0
                    ,input ?
                    ,input 0
                    ,INput substitute("Профайл &1 &2"
                                      , X_rule-profile.profile_id, calldscr(X_rp-by-call.call_id))
                    ,input-output table tt0-rule-call-param  ) no-error.
RUN  refill-rp-by-call IN THIS-PROCEDURE NO-ERROR.
END PROCEDURE.
PROCEDURE proc-b-rule :
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
if not available X_rule-profile then do:
  message
  "Сначала необходимо определить профайл"
  view-as alert-box error .
  return error.
end.
run rul/rule-by-profile-s.w ( INPUT parparentproc
                             ,INPUT ''
                             ,INPUT "profile"
                             ,INPUT X_rule-profile.profile_id
                             ,INPUT v-codex-id
                             ,INPUT v-ruleset-id
                             ,INPUT 0
                             ,INPUT-OUTPUT v-rid-list) NO-ERROR.
END PROCEDURE.
PROCEDURE proc-b-type :
define variable v-found as logical no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_tt0-rule-call-param for tt0-rule-call-param.
IF NOT AVAILABLE X_rp-by-call THEN DO:
  MESSAGE
  "Сначала необходимо определить профайл"
  VIEW-AS ALERT-BOX.
  disable b-param
  with frame Dialog-Frame .
  RETURN ERROR.
END.
FOR EACH buf_tt0-rule-call-param:
   DELETE buf_tt0-rule-call-param.
END.
for each buf_Rule-call-param no-lock where
        buf_rule-call-param.call#_id = X_rp-by-call.call#_id
    and  buf_rule-call-param.profile_id = X_rp-by-call.profile_id
    AND buf_rule-call-param.once-more = X_rp-by-call.once-more:
  create buf_tt0-rule-call-param.
  buffer-copy buf_rule-call-param to buf_tt0-rule-call-param.
  v-found = yes.
end.
if v-found
and v-ruleproc <> 'batchwork':U
and v-ruleproc <> 'batchwork':U
and v-ruleproc <> 'goods-batchwork':U
then do:
  RUN proc-b-param IN THIS-PROCEDURE ( input no) NO-ERROR.
end.
END PROCEDURE.
PROCEDURE proc-save :
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable glog as logical no-undo .
if file-name:visible in frame Dialog-Frame then do:
  ASSIGN FRAME Dialog-Frame
  file-name
  .
  if file-name = '':u
  or file-name = ?
  then do:
    message
    "Не задан файл"
    view-as alert-box error .
    undo, return error .
  end.
end.
if not available X_rule-profile then do:
  message
  "Не выбран профайл!"
  view-as alert-box error .
  undo, return error .
end.
if v-cntxt-db-num = 0 then do:
  if (v-profile-type = 'rep':U
  and v-ruleproc = 'batchwork':U)
  or (v-profile-type = 'ord':U
  and v-ruleproc = 'batchwork':U)
  or (v-profile-type = 'goods':U
  and v-ruleproc = 'goods-batchwork':U)
  or (v-profile-type = 'edoc':U
  and v-ruleproc = 'batchwork-routing_order':U)
  or (v-profile-type = 'edoc':U
  and v-ruleproc = 'batchwork-routing_price-doc':U)
  or (v-profile-type = 'edoc':U
  and v-ruleproc = 'batchwork-routing_trn-doc':U)
  or (v-profile-type = 'edoc':U
  and v-ruleproc = 'batchwork-routing_inkas':U)
  or (v-profile-type = 'edoc':U
  and v-ruleproc = 'text-import_specif':U)
  or (v-profile-type = 'edoc':U
  and v-ruleproc = 'excel-import_specif':U)
  or (v-profile-type = 'edoc':U
  and v-ruleproc = 'text-export_specif':U)
  or (v-profile-type = 'edoc':U
  and v-ruleproc = 'excel-export_specif':U)
  or X_rule-profile.short-name begins "_"
  or v-ruleproc = 'recipe-xml-file-import':U
  then do:
    glog = no.
  end.
  else do:
  message
  "Сохранить изменения значений параметров (если они были) в БД?"
  view-as alert-box question buttons yes-no update glog.
  end.
  if glog then do:
    run rul/ruprcall.p ( input v-profile-type
                        ,input v-uniq-key-rec
                        ,input 'rule-call-param':U
                        ,input ?
                        ,input 0
                        ,INPUT TABLE tt0-rp-by-call
                        ,INPUT TABLE tt0-rule-by-call
                        ,INPUT TABLE tt0-rule-call-param) no-error .
  if error-status:error then do:
    message
    "Ошибка при сохранении параметров правил" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo, return error .
  end.
end.
end.
END PROCEDURE.
PROCEDURE refill-rp-by-call :
RUN temp-string_clear IN THIS-PROCEDURE.
IF AVAILABLE X_rp-by-call  THEN DO:
    run rul/rule-proc-view.p ( input v-profile-type
                              ,input v-ruleproc
                              ,input (IF v-cntxt-db-num = 0 THEN 0 ELSE 1 )
                              ,input X_rp-by-call.CALL_id
                              ,input X_rp-by-call.profile_id
                              ,input X_rp-by-call.once-more
                              ,input "text-temp"
                              ,input this-procedure:HANDLE
                              ) no-error.
    ed-notes:SCREEN-VALUE  IN FRAME Dialog-Frame = '' .
    run add-lines in THIS-PROCEDURE  .
END.
ELSE DO:
  ed-notes:SCREEN-VALUE  IN FRAME Dialog-Frame = '' .
END.
END PROCEDURE.
