block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lib-nws.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: nws/lib-nws.p $":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы в СПН":U .
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
define new global shared variable g#lib-nws as handle no-undo .
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
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function usrnickf returns character ( input p-user-id as character):
   define variable v-nick      as character    no-undo.
   if p-user-id = ?
   OR p-user-id = "":U
   then do:
      return '':U .
   end.
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usrnick in g#library
  (input  p-user-id
  ,output v-nick
  ) no-error .
   if error-status :error
   then do:
      return p-user-id.
   end.
   else do:
      return v-nick.
   end.
end function.
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
define variable vss-include-info5 as character no-undo format "x(65)":U initial "@(#)$Workfile$ $Revision$":U.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure valid-ren-art-tbl-list :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = "cli-gds,cli-gds-attr,cli-art,cli-art-attr,contract-specif,c-contract-specif,doc-line,c-doc-line,fbr-line,c-fbr-line,fbr-recipe,fbr-recipe-gds,fbr-pln-line,c-fbr-pln-line,gds-dtl,c-gds-dtl,gds-dtl-attr,c-gds-dtl-attr,gds-obj,inv-line,inv-line-attr,c-inv-line,ot-supp-line,ot-supp-line-attr,ot-line-attr,ord-line,c-ord-line,ord-line-rcv,ord-dtl,c-ord-dtl,ord-dtl-attr,ord-dtl-rcv,ord-dtl-cons,ord-gds-cons,prt-obj,prt-obj-attr,parts,c-parts,parts-supp,parts-supp-attr,price-list,c-price-list,price-doc-forming-gds,c-price-doc-forming-gds,price-doc-forming-gds-qnty,c-price-doc-forming-gds-qnty,price-doc-forming-gds-sum,c-price-doc-forming-gds-sum,price-doc-forming-gds-tnv,c-price-doc-forming-gds-tnv,recipe,recipe-gds,c-recipe,c-recipe-gds,c-recipe-hist,stk-supp-line,stk-supp-line-attr,stk-line-attr,tmp-sale-dtl,tmp-sale-dtl-attr,tmp-sale-gds,tmp-sale-gds-attr":U
      v-ignore-list  = "c-goods,c-order-line":U
      v-special-list = "goods,ot-line,stk-line,order-line":U
    .
def var vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-inform      as character no-undo .
    define variable bh_tbl-name   as handle    no-undo .
    define variable v-tbl-not-idx as character no-undo .
    define variable v-idx-avail   as logical   no-undo .
    define variable new-tbl-list  as character no-undo .
    define variable old-tbl-list  as character no-undo .
    define variable old-tbl-avail as logical   no-undo .
    define variable v-double-tbl  as character no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable v-msg         as character no-undo .
    assign
      v-msg         = "":U
      v-tbl-not-idx = "":U
      new-tbl-list  = "":U
    .
    for each ub._Field no-lock
      where ub._Field._Field-Name = 'artic':U
    ,first ub._File of ub._Field
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if  lookup( ub._File._File-Name, v-std-list     ) = 0
      and lookup( ub._File._File-Name, v-ignore-list  ) = 0
      and lookup( ub._File._File-Name, v-special-list ) = 0
      then do:
        assign
          new-tbl-list = new-tbl-list + chr(10) + ub._File._File-Name
        .
      end.
      if lookup( ub._File._File-Name, v-std-list ) <> 0
        or lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0
      then do:
        create buffer bh_tbl-name for table substitute( "ub.&1":U, ub._File._File-Name ) .
        assign
          v-idx-avail = false
          v-inform    = bh_tbl-name:index-information(1)
          v-ind       = 2
        .
        block_chk-idx:
        do while v-inform <> ?
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-inform <> ?
              and lookup( entry( 5, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 7, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 9, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
          then do:
            assign
              v-idx-avail = true
            .
            leave block_chk-idx.
          end.
          assign
            v-inform = bh_tbl-name:index-information( v-ind )
            v-ind    = v-ind + 1
          .
        end.
        if v-idx-avail = false then do:
          if lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0 then do:
            assign
              new-tbl-list = new-tbl-list + " (индекса нет)"
            .
          end.
          else do:
            assign
              v-tbl-not-idx = v-tbl-not-idx + chr(10) + ub._File._File-Name
            .
          end.
        end.
        delete object bh_tbl-name.
      end.
    end.
    assign
      old-tbl-list  = "":U
      v-double-tbl  = "":U
      v-num-entries = num-entries( v-std-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name    = entry( v-ind, v-std-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-type"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-code"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > v-ind
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-ignore-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-ignore-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-type"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-code"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > v-ind
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-special-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-special-list )
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if available ub._File then do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
      end.
      if not available ub._File
        or ( available ub._File
             and not available ub._Field
           )
      then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > v-ind
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    if v-tbl-not-idx <> "" then do:
      assign
        v-msg = v-msg + substitute( "Таблицы не имеют индекса с полями &3 на первом месте и нет спецобработки: &2&1&1", chr(10), v-tbl-not-idx, 'artic, prod-type, prod-code':U )
      .
    end.
    if new-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "Нет обработки таблиц: &2&1&1", chr(10), new-tbl-list )
      .
    end.
    if v-double-tbl <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть задублированные таблицы: &2&1&1", chr(10), v-double-tbl )
      .
    end.
    if old-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть несуществующие таблицы или таблицы в которых отсутствуют переименовываемые поля: &2&1&1", chr(10), old-tbl-list )
      .
    end.
    if v-msg <> "":U then do:
      return error substitute( "Утилита переименования &3 не корректна.&1&1&2", chr(10), v-msg, 'artic, prod-type, prod-code':U ) .
    end.
  end.
end procedure.
procedure check-use-artic :
  define input  parameter p-tbl-name  as   character                      no-undo .
  define input  parameter p-artic     like ub.goods.artic     no-undo .
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop",   vss-include-info5 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info5 )
  :
    define buffer buf_goods for ub.goods .
    if lookup( p-tbl-name, "c-goods,c-order-line":U ) = 0 then do:
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        no-error .
      if not available buf_goods then do:
        return error substitute( "&1 (check-use-artic). Не найден товар с артикулом &2 и производителем &3 &4", vss-include-info5, p-artic, p-prod-type, p-prod-code ) .
      end.
      if buf_goods.stts = integer('51':U) then do:
        return error substitute( "&1 (check-use-artic). Нельзя использовать товар с артикулом &2 и производителем &3 &4&5"
                                + "Выполняется переименование артикула и(или) производителя"
                                ,vss-include-info5
                                ,p-artic
                                ,p-prod-type
                                ,p-prod-code
                                ,chr(10)
                              ) .
      end.
    end.
    return .
  end.
end procedure.
if valid-handle (g#lib-nws)
and g#lib-nws <> this-procedure :handle
and g#lib-nws :get-signature('lib-nws_clear-fill-option':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с СПН" skip
    g#lib-nws skip
    g#lib-nws :type skip
    g#lib-nws :file-name skip
    valid-handle(g#lib-nws) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-nws = this-procedure :handle
  .
end.
define temp-table temp-hist-nws-option no-undo like ub.hist-nws-option.
define buffer locked_hist-nws-option for ub.hist-nws-option.
define variable v-lock-type as integer no-undo .
define variable v-prev-lock-type as integer no-undo .
define variable v-cashed-version as character no-undo .
define variable v-cashed-time as int64 no-undo .
on delete of this-procedure do:
  for each temp-hist-nws-option:
    delete temp-hist-nws-option.
  end.
  assign
    g#lib-nws = ?
  .
end.
define stream str-err.
procedure lib-nws_clear-fill-option:
define input parameter p-fill-option as character no-undo .
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
  do
  on error undo, return error return-value
  :
    for each buf_temp-hist-nws-option where
            buf_temp-hist-nws-option.db-num = g#db-num
        and buf_temp-hist-nws-option.fill-option = p-fill-option
    on error undo, return error :
      delete buf_temp-hist-nws-option.
    end.
    assign
    v-lock-type = v-prev-lock-type
    v-cashed-version = '':U
    v-cashed-time = 0
    .
  end.
end procedure.
procedure lib-nws_fill-dct:
define input parameter p-fill-option as character no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer buf_hist-nws-option for ub.hist-nws-option.
  do
  on error undo, return error return-value
  :
    v-prev-lock-type = v-lock-type.
    run lib-nws_clear-fill-option in this-procedure ( input 'c-dc-hist':U).
    if v-lock-type = 0 then do:
      find first locked_hist-nws-option no-lock where
                locked_hist-nws-option.db-num = g#db-num
            and locked_hist-nws-option.hn-id = 0 .
      assign
      v-lock-type = NO-LOCK
      .
    end.
    for each buf_hist-nws-option no-lock where
             buf_hist-nws-option.db-num = g#db-num
         and buf_hist-nws-option.hn-id > 0
         and buf_hist-nws-option.subject-group = 'c-dc-hist':U
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      create buf_temp-hist-nws-option.
      buffer-copy buf_hist-nws-option to buf_temp-hist-nws-option.
      assign
      buf_temp-hist-nws-option.fill-option = p-fill-option
      .
    end.
  end.
end procedure.
procedure lib-nws_fill-hn-option-table :
define input parameter p-lock-type as integer no-undo .
define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
  do
  on error undo, return error return-value
  :
    find first locked_hist-nws-option share-lock where
      locked_hist-nws-option.db-num = g#db-num
      and locked_hist-nws-option.hn-id = 0 .
    if v-cashed-version = locked_hist-nws-option.option-descr then do:
      release locked_hist-nws-option.
      return.
    end.
    assign
    v-lock-type = p-lock-type
    v-cashed-version = locked_hist-nws-option.option-descr
    v-cashed-time = etime
    .
    for each buf_temp-hist-nws-option:
      if buf_temp-hist-nws-option.charkey_one <> '':U
      or buf_temp-hist-nws-option.charkey_two <> '':U
      or buf_temp-hist-nws-option.charkey_three <> '':U
      or buf_temp-hist-nws-option.key#_one <> 0
      or buf_temp-hist-nws-option.key#_two <> 0
      or buf_temp-hist-nws-option.key#_three <> 0
      or buf_temp-hist-nws-option.host-code <> 0
      or buf_temp-hist-nws-option.obj-type <> '':U
      or buf_temp-hist-nws-option.obj-code <> 0 then next.
      delete buf_temp-hist-nws-option.
    end.
    for each buf_hist-nws-option no-lock where
             buf_hist-nws-option.db-num = g#db-num
         and buf_hist-nws-option.hn-id > 0
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      if buf_hist-nws-option.charkey_one <> '':U
      or buf_hist-nws-option.charkey_two <> '':U
      or buf_hist-nws-option.charkey_three <> '':U
      or buf_hist-nws-option.key#_one <> 0
      or buf_hist-nws-option.key#_two <> 0
      or buf_hist-nws-option.key#_three <> 0
      or buf_hist-nws-option.host-code <> 0
      or buf_hist-nws-option.obj-type <> '':U
      or buf_hist-nws-option.obj-code <> 0 then next.
      create buf_temp-hist-nws-option.
      buffer-copy buf_hist-nws-option to buf_temp-hist-nws-option.
    end.
    case p-lock-type:
      when no-lock then do:
        release locked_hist-nws-option.
      end.
      when share-lock then do:
        find current locked_hist-nws-option share-lock .
      end.
      when exclusive-lock then do:
        find current locked_hist-nws-option exclusive-lock .
      end.
    end case.
  end.
end procedure.
procedure lib-nws_get-hn-option :
define input parameter p-db-num as integer no-undo .
define input parameter p-table-name as character no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-CHarkey_one as character no-undo .
define input parameter p-CHarkey_two as character no-undo .
define input parameter p-CHarkey_three as character no-undo .
define input parameter p-key#_one as integer no-undo .
define input parameter p-key#_two as integer no-undo .
define input parameter p-key#_three as integer no-undo .
define input parameter p-option-name as character no-undo .
define output parameter p-option-value as integer no-undo .
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    if v-cashed-version = '':U
    or  (etime - v-cashed-time > 1800000)
    or etime < v-cashed-time
    then do:
      run lib-nws_fill-hn-option-table  in this-procedure ( input no-lock) no-error .
      if error-status:error then do:
        undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
      end.
    end.
    if p-option-name = 'smart-nws' then do:
      p-option-value = integer('-1':U).
    end.
    else do:
      p-option-value = integer('0':U).
    end.
    find first buf_temp-hist-nws-option where
              buf_temp-hist-nws-option.db-num = p-db-num
          and buf_temp-hist-nws-option.table-name = p-table-name
          and buf_temp-hist-nws-option.CHarkey_one = p-CHarkey_one
          and buf_temp-hist-nws-option.CHarkey_two = p-CHarkey_two
          and buf_temp-hist-nws-option.CHarkey_three = p-CHarkey_three
          and buf_temp-hist-nws-option.key#_one = p-key#_one
          and buf_temp-hist-nws-option.key#_two = p-key#_two
          and buf_temp-hist-nws-option.key#_three = p-key#_three
          and buf_temp-hist-nws-option.host-code = p-host-code
          and buf_temp-hist-nws-option.obj-type = p-obj-type
          and buf_temp-hist-nws-option.obj-code = p-obj-code
          no-error.
    if not available buf_temp-hist-nws-option then return.
    assign
    p-option-value = buffer buf_temp-hist-nws-option:buffer-field(p-option-name):buffer-value
    no-error .
  end.
end procedure.
procedure lib-nws_get-hn-option-record :
define input parameter p-db-num as integer no-undo .
define input parameter p-bh as handle no-undo.
define variable v-bh as handle no-undo .
define variable v-tbh as handle no-undo .
define variable v-phrase as character no-undo .
define variable glog as logical no-undo .
define buffer buf_temp-hist-nws-option for temp-hist-nws-option.
define buffer buf_hist-nws-option for ub.hist-nws-option.
  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  :
    if v-cashed-version = '':U
    or  (etime - v-cashed-time > 1800000)
    or etime < v-cashed-time
    then do:
      run lib-nws_fill-hn-option-table  in this-procedure ( input no-lock) no-error .
      if error-status:error then do:
        undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
      end.
    end.
    glog = p-bh:find-first('':U, v-lock-type).
    v-tbh = buffer buf_temp-hist-nws-option:handle.
    v-bh = buffer buf_hist-nws-option:handle.
    v-phrase =  substitute( 'where db-num = &1 ' +
                           'and table-name = "&2" ' +
                           'and CHarkey_one = "&3" ' +
                           'and CHarkey_two = "&4" ' +
                           'and CHarkey_three = "&5" ' +
                           'and key#_one = &6 ' +
                           'and key#_two = &7 ' +
                           'and key#_three = &8 ' +
                           'and host-code = &9 '
                           ,p-db-num
                           ,p-bh:buffer-field('table-name'):buffer-value
                           ,p-bh:buffer-field('charkey_one'):buffer-value
                           ,p-bh:buffer-field('charkey_two'):buffer-value
                           ,p-bh:buffer-field('charkey_three'):buffer-value
                           ,p-bh:buffer-field('key#_one'):buffer-value
                           ,p-bh:buffer-field('key#_two'):buffer-value
                           ,p-bh:buffer-field('key#_three'):buffer-value
                           ,p-bh:buffer-field('host-code'):buffer-value)
               + substitute('and obj-type = "&1" ' +
                            'and obj-code = &2 '
                            ,p-bh:buffer-field('obj-type'):buffer-value
                            ,p-bh:buffer-field('obj-code'):buffer-value).
    glog = v-tbh:find-first( v-phrase, no-lock) no-error .
    if not glog then do:
      glog = v-bh:find-first( v-phrase, no-lock) no-error .
      if glog then do:
        glog = p-bh:buffer-copy ( v-bh) no-error .
      end.
    end.
    else do:
      glog = p-bh:buffer-copy ( v-tbh) no-error .
    end.
  end.
end procedure.
procedure lib-nws_lock-route :
  define input  parameter p-action as character no-undo .
  define input  parameter p-db-num as integer   no-undo .
  define input  parameter p-esys-id as integer  no-undo.
  define input  parameter p-descr  as character no-undo .
  define output parameter p-msg    as character no-undo .
  define output parameter p-lock   as logical   no-undo .
  define output parameter p-ok     as logical   no-undo .
  do
  on error  undo, return error substitute( "&1 (lib-nws_lock-route). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (lib-nws_lock-route). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (lib-nws_lock-route). endkey", vss-workfile )
  :
    define variable v-date as date    no-undo .
    define variable v-time as integer no-undo .
    define variable v-CharKey_One    as character    no-undo.
    define variable v-BP_Type        as character    no-undo.
    define buffer buf_BatchProcess for ub.BatchProcess .
      if p-esys-id = 0
      then do:
          assign
              v-CharKey_One = substitute( "&1&2", p-db-num
                                              , ( if p-esys-id = 0 then "":U else ",":U + string( p-esys-id ) ) )
              v-BP_Type     = 'lkrt':U
          .
      end.
      else do:
          assign
              v-CharKey_One = substitute( "&1&2", p-db-num
                                              , ( if p-esys-id = 0 then "":U else ",":U + string( p-esys-id ) ) )
              v-BP_Type     = 'lkes':U
          .
      end.
    find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = 'N':U
        and buf_BatchProcess.BP_Type     = v-BP_Type
        and buf_BatchProcess.CharKey_One = v-CharKey_One
      no-error .
    assign
      p-ok = true
    .
    case p-action :
      when "lockfull":U
      or when "lockwnws":U
      then do:
        assign
          p-lock = true
        .
        if available buf_BatchProcess then do:
          assign
            p-ok  = false
            p-msg = substitute( "Блокировка маршрутизации для БД &1 уже установлена пользователем &2 (&3) &4 в &5 (&6)"
                                ,v-CharKey_One
                                ,usrnickf( buf_BatchProcess.User_ID )
                                ,buf_BatchProcess.User_ID
                                ,string( buf_BatchProcess.BP_SysDate, "99.99.9999" )
                                ,buf_BatchProcess.BP_SysTime
                                ,buf_BatchProcess.CharKey_Three
                              ).
          .
        end.
        else do:
          run cur-time ( output v-date
                        ,output v-time
                      ) no-error .
          if error-status :error then do:
            return error substitute( "&1. Ошибка при определении текущего времени", vss-workfile ) .
          end.
          create buf_BatchProcess .
          assign
            p-msg = substitute( "БД &1 заблокировка маршрутизации (&2)"
                                ,v-CharKey_One
                                ,p-descr
                              )
            buf_BatchProcess.BatchProcess#     = next-value (s-btpr, ub)
            buf_BatchProcess.BP_Status         = 'N':U
            buf_BatchProcess.BP_Type           = v-BP_Type
            buf_BatchProcess.User_ID           = g#userid
            buf_BatchProcess.BP_SysDate        = v-date
            buf_BatchProcess.BP_SysTimeInt     = v-time
            buf_BatchProcess.BP_SysTime        = string(v-time, 'HH:MM:SS':U)
            buf_BatchProcess.CharKey_One       = v-CharKey_One
            buf_BatchProcess.CharKey_Two       = p-action
            buf_BatchProcess.CharKey_Three     = p-descr
          .
        end.
      end.
      when "unlock":U then do:
        assign
          p-lock = false
        .
        if available buf_BatchProcess then do:
          find first buf_BatchProcess
            where buf_BatchProcess.BP_Status   = 'N':U
              and buf_BatchProcess.BP_Type     = v-BP_Type
              and buf_BatchProcess.CharKey_One = v-CharKey_One
            no-error .
          delete buf_BatchProcess .
          assign
            p-msg = "Блокировка снята"
          .
        end.
        else do:
          assign
            p-msg = "Блокировка не установлена"
          .
        end.
      end.
      when "check":U then do:
        if available buf_BatchProcess
          and ( buf_BatchProcess.CharKey_Two <> "lockwnws":U
                or
                ( buf_BatchProcess.CharKey_Two = "lockwnws":U
                  and g#news <> true
                )
              )
        then do:
          assign
            p-msg = substitute( "Маршрутизация в БД &1 заблокирована пользователем &2 (&3) &4 в &5 (&6)"
                                ,v-CharKey_One
                                ,usrnickf( buf_BatchProcess.User_ID )
                                ,buf_BatchProcess.User_ID
                                ,string( buf_BatchProcess.BP_SysDate, "99.99.9999" )
                                ,buf_BatchProcess.BP_SysTime
                                ,buf_BatchProcess.CharKey_Three
                              ).
            p-lock = true
          .
        end.
        else do:
          assign
            p-msg  = "Блокировка не установлена"
            p-lock = false
          .
        end.
      end.
      otherwise do:
        return error substitute( "&1. Нет обработки операции &2", vss-workfile, p-action ) .
      end.
    end case.
  end.
end procedure.
procedure lib-nws_route-dump-write :
  define input parameter p-tbl-name   as character           no-undo .
  define input parameter p-bh_rtd     as handle              no-undo .
  define input parameter p-bh         as handle              no-undo .
  define input parameter p-dmp-ord    like ub.route.dump-ord no-undo .
  define input parameter p-rc-ord     as integer             no-undo .
  do
  on error  undo, return error substitute( "&1 (lib-nws_route-dump-write). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (lib-nws_route-dump-write). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (lib-nws_route-dump-write). endkey", vss-workfile )
  :
    define buffer buf-rtdl_goods           for ub.goods .
    define buffer buf-rtdl_route-dump-link for ub.route-dump-link .
    define variable tt-name         as character no-undo .
    define variable tth             as handle    no-undo .
    define variable bh_tt           as handle    no-undo .
    define variable v-num-fields     as integer no-undo .
    define variable v-ind            as integer no-undo .
    define variable v-avail-gds-code as logical no-undo .
    define variable v-avail-artic    as logical no-undo .
    define variable fh_tbl-name      as handle  no-undo .
    define variable fh_gds-code      as handle  no-undo .
    define variable fh_artic         as handle  no-undo .
    define variable fh_prod-type     as handle  no-undo .
    define variable fh_prod-code     as handle  no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-loc-key-rec like ub.route-dump-link.uniq-key-rec no-undo.
    create temp-table tth.
    assign
      tth:undo = false
      tt-name  = "tt_" + p-tbl-name
    .
    if valid-handle(p-bh) then do:
      assign
        v-ok = tth:create-like( p-bh ) no-error
      .
    end.
    else do:
      assign
        v-ok = tth:create-like( p-tbl-name ) no-error
      .
    end.
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при создании временной таблицы &2 (1)", vss-workfile, tt-name ) .
    end.
    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при создании временной таблицы &2 (2)", vss-workfile, tt-name ) .
    end.
    assign
      bh_tt = tth:default-buffer-handle
    .
    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при создании буфера временной таблицы.", vss-workfile, p-tbl-name ).
    end.
    assign
      v-ok = bh_tt:raw-transfer ( false, p-bh_rtd:buffer-field("value-rec") ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. RAW-TRANSFER не прошел для таблицы &2", vss-workfile, p-tbl-name ).
    end.
    assign
      fh_artic      = bh_tt:buffer-field( "artic":U )
      fh_prod-type  = bh_tt:buffer-field( "prod-type":U )
      fh_prod-code  = bh_tt:buffer-field( "prod-code":U )
      fh_gds-code   = bh_tt:buffer-field( "gds-code":U )
      no-error
    .
    if fh_artic <> ? then do:
      assign
        v-avail-artic = true
      .
    end.
    if fh_gds-code <> ? then do:
      assign
        v-avail-gds-code = true
      .
    end.
    if v-avail-gds-code = true
      or v-avail-artic = true
    then do:
      if v-avail-gds-code = true then do:
        if fh_gds-code:buffer-value() > 0 then do:
          find first buf-rtdl_goods no-lock
            where buf-rtdl_goods.gds-code = fh_gds-code:buffer-value()
          no-error .
          if not available buf-rtdl_goods then do:
            return error substitute( "&1. Товар с кодом &2 не найден по таблице &3"
                                    ,vss-workfile
                                    ,fh_gds-code:buffer-value()
                                    ,p-tbl-name
                                  ).
          end.
        end.
      end.
      else do:
          find first buf-rtdl_goods no-lock
            where buf-rtdl_goods.artic     = fh_artic:buffer-value()
              and buf-rtdl_goods.prod-type = fh_prod-type:buffer-value()
              and buf-rtdl_goods.prod-code = fh_prod-code:buffer-value()
          no-error .
          if not available buf-rtdl_goods then do:
            return error substitute( "&1. Товар с артикулом &2 производителя &3 &4 не найден по таблице &5"
                                    ,vss-workfile
                                    ,fh_artic:buffer-value()
                                    ,fh_prod-type:buffer-value()
                                    ,fh_prod-code:buffer-value()
                                    ,p-tbl-name
                                    ).
          end.
      end.
      if available buf-rtdl_goods then do:
        if v-avail-artic = true then do:
          run check-use-artic in this-procedure
            ( input p-tbl-name
            ,input fh_artic:buffer-value()
            ,input fh_prod-type:buffer-value()
            ,input fh_prod-code:buffer-value()
            ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
        end.
        run gen-key-rec( input 'goods':U
                        ,input (buffer buf-rtdl_goods:handle)
                        ,output v-loc-key-rec
                      ) no-error.
        if error-status :error then do:
          return error substitute( "&1. Ошибка при генерации уникального ключа по таблице &2 для &3. &4"
                                  ,vss-workfile
                                  ,'goods':U
                                  ,p-tbl-name
                                  ,return-value
                                ).
        end.
        create buf-rtdl_route-dump-link .
        assign
          buf-rtdl_route-dump-link.dump-ord     = p-dmp-ord
          buf-rtdl_route-dump-link.rec-ord      = p-rc-ord
          buf-rtdl_route-dump-link.uniq-key-rec = v-loc-key-rec
          buf-rtdl_route-dump-link.dump-name    = p-tbl-name
        .
      end.
    end.
    assign
      v-ok = tth:clear() no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1. Ошибка при очистке временной таблицы &2", vss-workfile, tt-name ) .
    end.
    delete object tth no-error .
    if error-status:error then do:
      return error substitute( "&1. Ошибка при удалении временной таблицы для &2", vss-workfile, tt-name ).
    end.
  end.
end procedure.
