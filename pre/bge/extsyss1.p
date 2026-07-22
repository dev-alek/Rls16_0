block-level on error undo, throw.
define input parameter p-mode as character no-undo .
define input parameter p-silent as logical no-undo .
define input-output parameter p-rec as recid no-undo .
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-esys-name as character no-undo .
define input parameter p-esys-des as character no-undo .
define input parameter p-esys-have-export as logical no-undo .
define input parameter p-esys-db-num-exp as integer no-undo .
define input parameter p-esys-send-news-exp  as logical no-undo .
define input parameter p-esys-num-days-keep-exp  as integer no-undo .
define input parameter p-esys-max-p-size as integer no-undo .
define input parameter p-exp-conf-wait as integer no-undo .
define input parameter p-max-p-queue as integer no-undo .
define input parameter p-max-p-time as integer no-undo .
define input parameter p-esys-have-import as logical no-undo .
define input parameter p-esys-db-num-imp as integer no-undo .
define input parameter p-esys-send-news-imp  as logical no-undo .
define input parameter p-esys-num-days-keep-imp  as integer no-undo .
define input parameter p-imp-conf-send as integer no-undo .
define input parameter p-esys-type as integer no-undo .
define input parameter p-delivery-method as integer no-undo .
define input parameter p-delete-pck-on as integer no-undo .
define input parameter p-save-days-pck-num as integer no-undo .
define temp-table tt-ext-system-attr no-undo like ub.ext-system-attr.
DEFINE INPUT PARAMETER TABLE FOR tt-ext-system-attr.
define variable vss-revision    as character no-undo init "$Revision: b4bfe3261567, 1895, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 07 16:26:45 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extsyss1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/extsyss1.p $":U .
define variable vss-description as character no-undo init "Сохранение ВНЕШНЕЙ СИСТЕМЫ типа спец".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure oxmlext-create :
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-current-db-num     as integer          no-undo.
define output parameter p-esys-id           as integer          no-undo.
    define variable v-today     as date         no-undo.
    define variable v-time      as integer      no-undo.
    define variable v-userid    as character    no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run oxmlext-esys-id in this-procedure (
        output p-esys-id
    ).
    run get-userid in p-mainmenu-handle (
        output v-userid
    ).
    create buf_ext-system.
    assign
        buf_ext-system.esys-id                          = p-esys-id
        buf_ext-system.db-num                           = p-current-db-num
        buf_ext-system.esys-date-change                 = v-today
        buf_ext-system.esys-chk-ingr-imp                = no
        buf_ext-system.esys-chk-seq-imp                 = no
        buf_ext-system.esys-date-change-attr            = v-today
        buf_ext-system.esys-date-change-exp             = v-today
        buf_ext-system.esys-date-change-imp             = v-today
        buf_ext-system.esys-db-num-exp                  = p-current-db-num
        buf_ext-system.esys-db-num-imp                  = p-current-db-num
        buf_ext-system.esys-des                         = ""
        buf_ext-system.esys-file-chk-ing-imp            = "":U
        buf_ext-system.esys-have-export                 = no
        buf_ext-system.esys-have-import                 = no
        buf_ext-system.esys-have-proc-chk-ing-imp       = no
        buf_ext-system.esys-last-pack                   = 0
        buf_ext-system.esys-name                        = "<Новая внешняя система>"
        buf_ext-system.esys-num-days-keep-exp           = 0
        buf_ext-system.esys-num-days-keep-imp           = 0
        buf_ext-system.esys-proc-chk-ing-imp            = "":U
        buf_ext-system.esys-send-news-exp               = no
        buf_ext-system.esys-send-news-imp               = no
        buf_ext-system.esys-status                      = integer( '-1':U )
        buf_ext-system.esys-work-update                 = no
        buf_ext-system.esys-creid                       = v-userid
        buf_ext-system.esys-sys-date                    = v-today
        buf_ext-system.esys-sys-time-int                = v-time
        buf_ext-system.esys-sys-time                    = string( v-time, "HH:MM:SS" )
        buf_ext-system.esys-user-name                   = v-userid
        buf_ext-system.esys-user-db-num                 = p-current-db-num
    .
end.
end procedure.
procedure oxmlext-start-subsystem :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 20
    then do:
        assign
            buf_ext-system.esys-status = 21
        .
    end.
    else do:
        assign
            buf_ext-system.esys-status = 1
        .
    end.
end.
end procedure.
procedure oxmlext-stop-subsystem :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
    define buffer buf_ext-system        for ub.ext-system.
do
for buf_ext-system
on error undo, return error
:
    find first buf_ext-system exclusive-lock
         where buf_ext-system.esys-id = p-esys-id
           and buf_ext-system.db-num  = p-db-num
    .
    if buf_ext-system.esys-status = 21
    then do:
        assign
            buf_ext-system.esys-status = 20
        .
    end.
    else do:
        assign
            buf_ext-system.esys-status = 0
        .
    end.
end.
end procedure.
procedure oxmlext-stop-import :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
do
on error undo, return error
:
end.
end procedure.
procedure oxmlext-stop-export :
define input parameter p-esys-id    as integer          no-undo.
define input parameter p-db-num     as integer          no-undo.
do
on error undo, return error
:
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
procedure extsyssl :
define parameter buffer buf_ext-system for ub.ext-system.
define output parameter p-ok as logical   no-undo .
define variable v-resource-id as character no-undo .
define variable v-found as logical   no-undo .
define buffer buf_some-lk for ub.some-lk.
define buffer buf_ext-classif for ub.ext-classif.
do
on error undo, return error return-value
:
  for each buf_ext-classif no-lock where
        buf_ext-classif.classif-subject = 'clients':U
    and buf_ext-classif.classif-name = 'clients-esys':U
    AND buf_ext-classif.db-num = 0
    AND buf_ext-classif.key#_one = buf_ext-system.esys-id
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    v-found = yes.
    leave.
  end.
  if v-found then do:
    undo, return error substitute("К данной внешней системе привязаны объекты&1" +
                        "изменение моды экспорта/импорта или БД для экспорта/импорта НЕВОЗМОЖНО", chr(10)).
  end.
  for each buf_ext-classif no-lock where
        buf_ext-classif.classif-subject = 'clients':U
    and buf_ext-classif.classif-name = 'clients-edoc-nn':U
    AND buf_ext-classif.db-num = -1
    AND buf_ext-classif.key#_one = buf_ext-system.esys-id
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    v-found = yes.
    leave.
  end.
  if v-found then do:
    undo, return error substitute("К данной внешней системе привязаны контрагенты&1" +
                        "изменение моды экспорта/импорта или БД для экспорта/импорта НЕВОЗМОЖНО", chr(10)).
  end.
  for each buf_ext-classif no-lock where
        buf_ext-classif.classif-subject = 'clients':U
    and buf_ext-classif.classif-name = 'exite-edi':U
    AND buf_ext-classif.db-num = -1
    AND buf_ext-classif.key#_one = buf_ext-system.esys-id
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    v-found = yes.
    leave.
  end.
  if v-found then do:
    undo, return error substitute("К данной внешней системе привязаны контрагенты&1" +
                        "изменение моды экспорта/импорта или БД для экспорта/импорта НЕВОЗМОЖНО", chr(10)).
  end.
  run gen-key-rec in this-procedure ( input 'ext-system':U
                                    ,input (buffer buf_ext-system:handle)
                                    ,output v-resource-id).
  for each buf_some-lk no-lock where
          buf_some-lk.resource_id = v-resource-id :
    leave.
  end.
  if available buf_some-lk then do:
    undo, return error substitute("Внешняя система используется").
  end.
  p-ok = yes.
end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-mess as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-ok as logical no-undo .
define variable v-ii as integer   no-undo .
define variable v-exp-nums as integer no-undo .
define variable v-imp-nums as integer no-undo .
define variable v-exp-nums-already as integer no-undo .
define variable v-imp-nums-already as integer no-undo .
define variable v-exp-nums-permitted as integer no-undo .
define variable v-imp-nums-permitted as integer no-undo .
define variable v-exp-nums-permitted-chr as character no-undo .
define variable v-imp-nums-permitted-chr as character no-undo .
define variable v-type as character no-undo .
define buffer buf_db for ub.db.
define buffer buf_ext-system for ub.ext-system.
define buffer buf2_ext-system for ub.ext-system.
define buffer buf_ext-classif for ub.ext-classif.
do : // проверки
  if ibs.th.gbl.gbl-var:g#db-num <> 0 then do:
    v-mess = "Запрещено вызывать процедуру в УБД" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else '':U).
  end.
  if p-esys-name = '':U then do:
      v-mess = substitute("Не задано Название внешней системы").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else 'esys-name':U).
  end.
  if lookup(string(p-delivery-method), '0,2,3,4,5,9,10,11':U) = 0 then do:
    v-mess = substitute("Неверный метод доставки").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else 'delivery-method':U).
  end.
  if p-delivery-method = integer('3':U)
   and p-imp-conf-send = INTEGER('1':U) then do:
    v-mess = substitute("Нельзя установить опцию &1&2и метод доставки &3 одновременно"
                        , '1':U
                        , chr(10)
                        , 'Oracle Retail':U
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else 'T-imp-conf-send':U).
  end.
  if p-delivery-method = integer('3':U)
   and p-exp-conf-wait = INTEGER('1':U) then do:
    v-mess = substitute("Нельзя установить опцию &1&2и метод доставки &3 одновременно"
                        , '1':U
                        , chr(10)
                        , 'Oracle Retail':U
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else 'T-exp-conf-wait':U).
  end.
  if lookup(string(p-esys-type), '0,1,2,3,4,5,6,7,8,9,10,11,12':U) = 0 then do:
    v-mess = substitute("Неверный тип ВС").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else 'esys-type':U).
  end.
  if p-esys-type = integer('9':U)
  and (p-delivery-method <> integer('5':U) and p-delivery-method <> integer('9':U)) then do:
        v-mess = substitute("Для ВС типа &2 (&1)&3 метод доставки должен быть Exite-EDI или Контур.EDI"
                        , p-esys-type
                        , entry (lookup (string(p-esys-type), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)
                        , chr(10)
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else '':U).
  end.
  if p-delete-pck-on <> 0 and p-delete-pck-on <> 1 then do:
    v-mess = substitute("Неверное значение поля Удалять файлы из HEAP = &1", p-delete-pck-on).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent then v-mess else 'delete-pck-on':U).
  end.
  if p-esys-have-export and p-esys-db-num-exp > 0 then do:
    if not can-find (first buf_db where buf_db.db-num = p-esys-db-num-exp) then do:
      v-mess = substitute("Неверно задан номер БД для экспорта &1", p-esys-db-num-exp).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
    end.
  end.
  if p-esys-have-import and p-esys-db-num-imp > 0 then do:
    if not can-find (first buf_db where buf_db.db-num = p-esys-db-num-imp) then do:
      v-mess = substitute("Неверно задан номер БД для импорта &1", p-esys-db-num-imp).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
    end.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    if can-find (first ext-system where ext-system.esys-id = p-esys-id) then do :
      v-mess = substitute("ВС с кодом &1 уже существует. Повторное добавление запрещено.", p-esys-id) .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent then v-mess else '':U).
    end.
  end .
  else if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
    message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
    view-as alert-box error .
    return error '':u.
  end.
end . // end_of проверки
_main:
do for buf_ext-system
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    p-esys-id = next-value( s-ext-system, ub ) . // @NOTE !! p-esys-id - INPUT parameter, не OUTPUT !!
    create buf_ext-system.
    assign
    buf_ext-system.esys-id = p-esys-id
    buf_ext-system.db-num =  0
    buf_ext-system.esys-type = p-esys-type
    .
    for each tt-ext-system-attr
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      assign
      tt-ext-system-attr.esys-id = p-esys-id
      tt-ext-system-attr.db-num = 0
      .
    end.
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_ext-system exclusive-lock where
              recid(buf_ext-system) = p-rec .
    if not (buf_ext-system.esys-type > integer('0':U))
    then do:
      assign
      v-mess = substitute("Данная система не имеет типа СПЕЦИАЛЬНАЯ").
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    if (p-esys-have-export
    and p-esys-db-num-exp <>  buf_ext-system.esys-db-num-exp
    and buf_ext-system.esys-have-export)
    or (p-esys-have-import
    and p-esys-db-num-imp <>  buf_ext-system.esys-db-num-imp
    and buf_ext-system.esys-have-import)
    or (p-esys-have-export <> buf_ext-system.esys-have-export)
    or (p-esys-have-import <> buf_ext-system.esys-have-import)
    then do:
      run extsyssl in this-procedure ( buffer buf_ext-system
                                      ,output v-ok) no-error.
      if not v-ok then do:
        assign
        v-mess = return-value .
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end.
  if lookup(string(p-esys-type), '7,9':U) > 0 then do:
    if p-esys-have-export then do:
      for each buf2_ext-system no-lock where
            buf2_ext-system.esys-have-export = yes
            and buf2_ext-system.esys-db-num-exp = p-esys-db-num-exp
            and buf2_ext-system.esys-type = p-esys-type
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :
        v-exp-nums = v-exp-nums + 1.
      end.
    end.
    if p-esys-have-import then do:
      for each buf2_ext-system no-lock where
            buf2_ext-system.esys-have-import = yes
            and buf2_ext-system.esys-db-num-imp = p-esys-db-num-imp
            and buf2_ext-system.esys-type = p-esys-type
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :
        v-imp-nums = v-imp-nums + 1.
      end.
    end.
    assign
    v-exp-nums-already = v-exp-nums
    v-imp-nums-already = v-imp-nums
    .
    if p-mode = 'ДОБАВЛЕНИЕ':U then do:
      assign
      v-exp-nums = v-exp-nums + 1
      v-imp-nums = v-imp-nums + 1
      .
    end.
    if p-mode = 'ИЗМЕНЕНИЕ':U
    and buf_ext-system.esys-type <> p-esys-type then do:
      assign
      v-exp-nums = v-exp-nums + 1
      v-imp-nums = v-imp-nums + 1
      .
    end.
    define variable v-param-code as character no-undo .
    v-param-code = substitute("esys-&1", string(p-esys-type, "999")).
    if v-exp-nums > 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run confrddb in g#library
  (input  v-param-code
  ,input  p-esys-db-num-exp
  ,input  0
  ,input  ''
  ,input  0
  ,input  p-silent
  ,output v-exp-nums-permitted-chr
  ,output v-type
  ) no-error .
      assign
      v-exp-nums-permitted = integer(v-exp-nums-permitted-chr)
      no-error .
      if v-exp-nums-permitted < v-exp-nums then do:
                v-mess = substitute("Количество разрешенных согласно параметру <esys-&7>  ВС с типом &2 (&1)&5 для БД &4 (БД экспорта) = &3,&5 количество ВС такого типа в БД &4 уже = &6"
                            , p-esys-type
                            , entry (lookup (string(p-esys-type), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)
                            , v-exp-nums-permitted
                            , p-esys-db-num-exp
                            , chr(10)
                            , v-exp-nums-already
                            , string(p-esys-type, "999")
                            ).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    if v-imp-nums > 0 then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run confrddb in g#library
  (input  v-param-code
  ,input  p-esys-db-num-imp
  ,input  0
  ,input  ''
  ,input  0
  ,input  p-silent
  ,output v-imp-nums-permitted-chr
  ,output v-type
  ) no-error .
      assign
      v-imp-nums-permitted = integer(v-imp-nums-permitted-chr)
      no-error .
      if v-imp-nums-permitted < v-imp-nums then do:
                v-mess = substitute("Количество разрешенных согласно параметру <esys-&7> ВС с типом &2 (&1)&5 для БД &4 (БД импорта) = &3,&5 количество ВС такого типа в БД &4 уже = &6 "
                            , p-esys-type
                            , entry (lookup (string(p-esys-type), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)
                            , v-imp-nums-permitted
                            , p-esys-db-num-imp
                            , chr(10)
                            , v-imp-nums-already
                            , string(p-esys-type, "999")
                            ).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end.
  if lookup(string(p-esys-type), '9':U + chr(44) +
                         '5':U + chr(44) +
                         '7':U) > 0
  and  (p-esys-have-export <> p-esys-have-import
        or
        p-esys-db-num-exp <> p-esys-db-num-imp
        ) then do:
        v-mess = substitute("Для ВС типа &2 (&1)&3 БД импорта и экспорта должны быть одной и той же БД"
                        , p-esys-type
                        , entry (lookup (string(p-esys-type), '0,1,2,3,4,5,6,7,8,9,10,11,12':U), 'НЕспециальная,Специальная,IBS TH,Oracle Retail,Lantab,EDOC-НН,Панель Руководителя,ДатаКрат DKLink,1C,EDI,Меркурий,ИС МОТП,ИС Диадок':U)
                        , chr(10)
                        ).
    run err-mess in this-procedure ( input-output v-mess).
    undo _main, return error (if p-silent = yes then v-mess else '':U).
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  assign
  buf_ext-system.esys-name                = p-esys-name
  buf_ext-system.esys-des                 = p-esys-des
  buf_ext-system.esys-have-export         = p-esys-have-export
  buf_ext-system.esys-db-num-exp          = (if p-esys-have-export then p-esys-db-num-exp        else 0)
  buf_ext-system.esys-send-news-exp       = (if p-esys-have-export then p-esys-send-news-exp     else no)
  buf_ext-system.esys-num-days-keep-exp   = (if p-esys-have-export then p-esys-num-days-keep-exp else 0)
  buf_ext-system.esys-max-p-size          = (if p-esys-have-export then p-esys-max-p-size        else 0)
  buf_ext-system.exp-conf-wait            = p-exp-conf-wait
  buf_ext-system.max-p-queue              = p-max-p-queue
  buf_ext-system.max-p-time               = p-max-p-time
  buf_ext-system.esys-have-import         = p-esys-have-import
  buf_ext-system.esys-db-num-imp          = (if p-esys-have-import then p-esys-db-num-imp        else 0)
  buf_ext-system.esys-send-news-imp       = (if p-esys-have-import then p-esys-send-news-imp     else no)
  buf_ext-system.esys-num-days-keep-imp   = (if p-esys-have-import then p-esys-num-days-keep-imp else 0)
  buf_ext-system.imp-conf-send            = p-imp-conf-send
  buf_ext-system.esys-date-change         = v-today
  buf_ext-system.esys-chk-ingr-imp                = yes
  buf_ext-system.esys-chk-seq-imp                 = yes
  buf_ext-system.esys-date-change-attr            = v-today
  buf_ext-system.esys-date-change-exp             = v-today
  buf_ext-system.esys-date-change-imp             = v-today
  buf_ext-system.esys-status                      = integer( '1':U )
  buf_ext-system.esys-work-update                 = no
  buf_ext-system.esys-creid                       = ibs.th.gbl.gbl-var:g#userid
  buf_ext-system.delivery-method                  = p-delivery-method
  buf_ext-system.delete-pck-on                    = p-delete-pck-on
  buf_ext-system.save-days-pck-num                = p-save-days-pck-num
  buf_ext-system.esys-type                        = p-esys-type
  .
  p-rec = recid(buf_ext-system).
  release  buf_ext-system no-error.
  if error-status:error then do:
      assign
      v-mess = substitute("Ошибка при сохранении внешней системы&1&2&1&3"
                           , chr(10)
                           , error-status:get-message(1)
                           , return-value
                           ).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
  end.
  do v-ii = 1 to num-entries('FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U):
     find first tt-ext-system-attr where
              tt-ext-system-attr.esya-attr-code  = entry(v-ii, 'FTP,Login,Password,Path,IN-dir,OUT-dir,cert-sign,cert-sign-subject,cert-sign-issuer,cert-file-ext,cert-repository,AuthToken,AuthTokenDT,host-code,obj,user-id,server-addr,proxy-addr,proxy-login,proxy-pswd,proxy-ssl,AuthToken-send,mail-list,diadoc-user,diadoc-pwd,diadoc-key,diadoc-lastload,diadoc-ssl':U)
          and tt-ext-system-attr.esys-id = p-esys-id
          and tt-ext-system-attr.db-num = p-db-num no-error.
     if available tt-ext-system-attr then do:
      run ext-system-attr-write in this-procedure (
                                                     input p-esys-id
                                                    ,input p-db-num
                                                    ,input tt-ext-system-attr.esya-attr-code
                                                    ,input tt-ext-system-attr.esya-attr-value) no-error .
      if error-status :error then do:
        assign
        v-mess = substitute("Ошибка при сохранении внешней системы (атрибут &4)&1&2&1&3"
                            , chr(10)
                            , error-status:get-message(1)
                            , return-value
                            , tt-ext-system-attr.esya-attr-code
                            ).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Специальная внешняя система &1:&2&3"
                         , p-esys-id
                         , chr(10)
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
