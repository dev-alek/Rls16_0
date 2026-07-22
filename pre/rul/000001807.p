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
define input parameter p-doc-date as date no-undo .
define input parameter p-fact-date as date no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .
define input parameter p-type as character no-undo .
define input parameter p-emitent-host-code as integer no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   temp-table temp-d-card no-undo
field card-num as integer
field d-card as character
field dt-code as integer
field first-card as character
field first-main-card as character
field gds-dis-base as decimal
field gds-dis-rubl as decimal
field gds-tot-b0   as decimal
field gds-tot-base as decimal
field gds-tot-r0   as decimal
field gds-tot-rubl as decimal
field host-code as integer
field main-card as character
field num-chk as integer
field obj-code as integer
field obj-type as character
field pay-tot-base as decimal
field pay-tot-rubl as decimal
field sum-dis-base as decimal
field sum-dis-rubl as decimal
field sum-tot-base as decimal
field sum-tot-rubl as decimal
field sum-tot-r-b         as decimal
field gds-tot-r-b         as decimal
field gds-dis-r-b         as decimal
field cli-type            as character
field cli-code            as integer
field emitent-host-code   as integer
field type                as character
field exp-imp             as logical
field sale-doc            as character
field sale-type           as character
field doc-date            as date
field base-code           as integer
field smart-nws-log       as logical init ?
field action              as integer
index pi is unique primary
d-card
obj-type obj-code
index iobj obj-type obj-code
index itype type emitent-host-code
.
define INPUT parameter table for temp-d-card.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 6".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define shared temp-table dc-list no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table dc-list-hist no-undo
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def shared temp-table dcp-list no-undo like ub.dis-card-property
                        field rc as recid
                        field to-del as  logical
                        field order-num as integer
                        index rci is unique rc to-del
                        index d-card-i is primary d-card host-code obj-type obj-code dt-code node-code to-del
                        index iobj obj-type obj-code
                        index io order-num
                        .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info8 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info8, p-tbl-name ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info8, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info8, v-inform, p-tbl-name ).
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
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info8, p-tbl-name ).
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
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info8 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info8, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info8 ).
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
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info8, vTable, chr(10) ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info8, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info8, v-inform, vTable ).
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
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info8, p-key-handle:name, v-field-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info8, vTable ).
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
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info8, p-tbl-name, p-key-rec ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info8 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info8 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info8, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info8, v-inform, v-tbl-name ).
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
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info8, v-tbl-name ).
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
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info8 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info8 ).
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
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info8, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info8, v-inform, v-tbl-name ).
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table temp-hist-nws-option no-undo
like ub.hist-nws-option
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function ean-13 returns character ( input p-code as character
                                   ,input DC-PFX as character):
define variable Dc-frmt as character no-undo INIT "ean13".
define variable FULL-B-CODE as character no-undo .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str12  as character no-undo.
  define variable tmp-num12  as character no-undo.
  define variable i12        as integer   no-undo.
  define variable sum12      as integer   no-undo.
  define variable len-code12 as integer   no-undo.
  define variable varcont12  as logical   initial yes no-undo.
  CASE Dc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str12 = string( p-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str12 = string( p-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " Dc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont12 = yes then do:
    if integer( substring( tmp-str12, 1, length( Dc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " p-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = Dc-pfx + substring( tmp-str12, length( Dc-pfx ) + 1, length( tmp-str12 ) - length( Dc-pfx ) )
        len-code12    = length( full-b-code )
      .
      define variable v-sum-char12 as character no-undo .
      assign
        sum12 = 0
      .
      do i12 = 1 to len-code12 by 2
      :
        assign
          v-sum-char12 = substr(full-b-code, len-code12 - i12 + 1, 1)
        .
        if v-sum-char12 < "0"
        or v-sum-char12 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " p-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum12 = sum12 + integer(v-sum-char12)
        .
      end.
      if varcont12 = yes then do:
        assign
          sum12 = sum12 * 3
        .
        do i12 = 2 to len-code12 by 2
        :
          assign
            v-sum-char12 = substr(full-b-code, len-code12 - i12 + 1, 1)
          .
          if v-sum-char12 < "0"
          or v-sum-char12 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " p-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum12 = sum12 + integer(v-sum-char12)
          .
        end.
        if varcont12 = yes then do:
           if sum12 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum12 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
return full-b-code .
end function.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-disprop-menu-section-num as integer no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure disproph_write-dis-card-property-proc  :
define parameter buffer buf_dis-card-property for ub.dis-card-property .
define parameter buffer buf_dis-card for ub.dis-card.
define input parameter p-d-card      like ub.dis-card-property.d-card no-undo .
define input parameter p-dt-code      like ub.dis-card-property.dt-code no-undo .
define input parameter p-host-code   like ub.dis-card-property.host-code no-undo .
define input parameter p-obj-type    like ub.dis-card-property.obj-type no-undo .
define input parameter p-obj-code    like ub.dis-card-property.obj-code no-undo .
define input parameter p-dtm-code    like ub.dis-card-property.dtm-code no-undo .
define input parameter p-card-num    like ub.dis-card-property.card-num  no-undo .
define input parameter p-main-card   like ub.dis-card-property.main-card  no-undo .
define input parameter p-first-card  like ub.dis-card-property.first-card  no-undo .
define input parameter p-first-main-card  like ub.dis-card-property.first-main-card  no-undo .
define input parameter p-node-code   like ub.dis-card-property.node-code no-undo .
define input parameter p-action      as integer no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-uniq-key-rec as character no-undo .
define variable v-send as integer no-undo .
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-card-property for ub.c-dis-card-property.
  main-block:
  do
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not available buf_dis-card-property and not p-action = integer('1':U) then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не определена запись СВОЙСТВА ДК" skip
        view-as alert-box error .
      undo, return error .
    end.
  v-send = integer('0':U).
  if not p-action = integer('1':U) then do:
    if available buf_dis-card then do:
      if g#news then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_Dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'nws-to-hist'
  ,output v-send
  ) no-error .
      end.
      else do:
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_Dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'hist-from-prim'
  ,output v-send
  ) no-error .
      end.
    end.
  end.
  if v-send >= 0 then do:
    run cur-time in this-procedure(output v-date, output v-time).
    if p-action = integer('1':U) then do:
      create buf_c-dis-card-property.
      assign
      buf_c-dis-card-property.d-card            = p-d-card
      buf_c-dis-card-property.card-num          = p-card-num
      buf_c-dis-card-property.host-code         = p-host-code
      buf_c-dis-card-property.obj-type          = p-obj-type
      buf_c-dis-card-property.obj-code          = p-obj-code
      buf_c-dis-card-property.dt-code           = p-dt-code
      buf_c-dis-card-property.node-code         = p-node-code
      buf_c-dis-card-property.dtm-code         = p-dtm-code
      buf_c-dis-card-property.main-card         = p-main-card
      buf_c-dis-card-property.first-main-card   = p-first-main-card
      buf_c-dis-card-property.first-card        = p-first-card
      buf_c-dis-card-property.chip-num          = (if p-chip-num = 0
                                                   then next-value (s-dc-chip, ub)
                                                   else p-chip-num)
      buf_c-dis-card-property.corr-time         = (if p-corr-time = ?
                                                   then v-time
                                                   else p-corr-time)
      buf_c-dis-card-property.corr-user-db-num  = g#db-num
      buf_c-dis-card-property.corr-user-name    = if g#news then (chr(4) +  'СПН':U) else g#userid
      buf_c-dis-card-property.corr-date         = (if p-corr-date = ?
                                                   then v-date
                                                   else p-corr-date)
      .
    end.
    else do:
      create buf_c-dis-card-property.
      buffer-copy buf_dis-card-property to buf_c-dis-card-property
      assign
      buf_c-dis-card-property.d-card             = buf_dis-card-property.d-card
      buf_c-dis-card-property.card-num           = buf_dis-card-property.card-num
      buf_c-dis-card-property.dt-code             = buf_dis-card-property.dt-code
      buf_c-dis-card-property.main-card          = buf_dis-card-property.main-card
      buf_c-dis-card-property.first-main-card    = buf_dis-card-property.first-main-card
      buf_c-dis-card-property.first-card         = buf_dis-card-property.first-card
      buf_c-dis-card-property.host-code          = buf_dis-card-property.host-code
      buf_c-dis-card-property.obj-type          = p-obj-type
      buf_c-dis-card-property.obj-code          = p-obj-code
      buf_c-dis-card-property.node-code         = p-node-code
      buf_c-dis-card-property.dtm-code         = p-dtm-code
      buf_c-dis-card-property.chip-num           = (if p-chip-num = 0
                                                    then next-value (s-dc-chip, ub)
                                                    else p-chip-num)
      buf_c-dis-card-property.corr-time          = (if p-corr-time = ?
                                                    then v-time
                                                    else p-corr-time)
      buf_c-dis-card-property.corr-user-db-num   = g#db-num
            buf_c-dis-card-property.corr-user-name    = (if g#news
                                                   then (chr(4) +  'СПН':U)
                                                   else (if g#esys
                                                         then (chr(4) +  'ВС':U)
                                                         else g#userid
                                                         )
                                                   )
      buf_c-dis-card-property.corr-date          = (if p-corr-date = ?
                                                    then v-date
                                                    else p-corr-date)
      .
      run gen-key-rec in this-procedure (
                                          input 'dis-card-property':U
                                        ,input buffer buf_dis-card-property:handle
                                        ,output v-uniq-key-rec).
    end.
    if p-chip-num = 0   then do:
      create buf_c-dc-hist.
      buffer-copy buf_c-dis-card-property to buf_c-dc-hist
      assign
      buf_c-dc-hist.action =  p-action
      buf_c-dc-hist.subject = 'dis-card-property':U
      buf_c-dc-hist.is-news = g#news
      buf_c-dc-hist.source-type = p-source-type
      buf_c-dc-hist.source-ref = p-source-ref
      buf_c-dc-hist.uniq-key-rec = v-uniq-key-rec
      .
    end.
    assign
    p-chip-num = buf_c-dis-card-property.chip-num
    p-corr-date = buf_c-dis-card-property.corr-date
    p-corr-time = buf_c-dis-card-property.corr-time
    .
    run disproph_send-nws in this-procedure (
                                              buffer buf_c-dis-card-property
                                             ,buffer buf_c-dc-hist
                                             ,buffer buf_dis-card
                                              ).
    end.
  end.
end procedure.
procedure disproph_send-nws :
define parameter buffer buf_c-dis-card-property for ub.c-dis-card-property.
define parameter buffer buf_c-dc-hist for ub.c-dc-hist.
define parameter buffer buf_Dis-card for ub.dis-card.
define variable v-dh-hn as integer no-undo .
main-block:
do
on error undo, return error return-value
:
  if g#news
  and g#db-num > 0
  and buf_c-dis-card-property.corr-user-db-num <> g#db-num
  then return.
  if g#db-num = 0
  or (g#news
      and g#db-num > 0
      and buf_c-dis-card-property.corr-user-name = (chr(4) +  'СПН':U)
      )
  then do:
    if not available buf_dis-card then do:
      find first buf_dis-card no-lock where
                buf_Dis-card.d-card = buf_c-dis-card-property.d-card no-error.
    end.
    if not available buf_dis-card then do:
      assign
      v-dh-hn = integer('0':U).
    end.
    else do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#lib-nws) <> true) then do:   run nws/lib-nws.p persistent no-error .   if error-status :error or (valid-handle(g#lib-nws) <> true) then do:     message       "Error starting nws/lib-nws.p" skip       g#lib-nws skip       g#lib-nws :type skip       g#lib-nws :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-nws_get-hn-option in g#lib-nws
  (input  g#db-num
  ,input  'dis-card-property':U
  ,input  0
  ,input  '':U
  ,input  0
  ,input  buf_dis-card.type
  ,input  '':U
  ,input  '':U
  ,input  buf_dis-card.emitent-host-code
  ,input  (if buf_c-dis-card-property.dt-code > 0 then 0 else -1)
  ,input  0
  ,input  'hist-to-nws'
  ,output v-dh-hn
  ) no-error .
    end.
    if v-dh-hn >= 0 then do:
      run str/callnews.p (
        input 'c-dis-card-property':U
        ,input (buffer buf_c-dis-card-property:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1) ).
      end.
      if available buf_c-dc-hist then do:
        run str/callnews.p (
          input 'c-dc-hist':U
          ,input (buffer buf_c-dc-hist:handle)
          ) no-error .
        if error-status:error then do:
          undo main-block,  return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1) ).
        end.
      end.
    end.
  end.
end.
end procedure.
procedure discprop-node-code :
define input parameter p-dtm-code as integer no-undo .
define input parameter p-node-code as integer no-undo .
define output parameter p-data-type as character no-undo .
define output parameter p-format as character no-undo .
define output parameter p-label as character no-undo .
define output parameter p-range as integer no-undo .
define output parameter p-rw-option as character no-undo .
define buffer buf_prop-map for ub.prop-map.
define buffer buf_prop-head for ub.prop-head.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
find first buf_prop-head no-lock where
          buf_prop-head.dtm-code = p-dtm-code no-error .
if available buf_prop-head then do:
  if p-node-code > 0 then do:
    find first buf_prop-map no-lock where
              buf_prop-map.dtm-code = p-dtm-code
          and buf_prop-map.node-code = p-node-code no-error .
    if available buf_prop-map then do:
      assign
      p-data-type = buf_prop-map.node-value-type
      p-format = buf_prop-map.node-format
      p-label = buf_prop-map.node-label
      p-rw-option = buf_prop-map.rw-option
      .
    end.
  end.
  if buf_prop-head.storage-place  = "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  > "":U then do:
    p-range =  12.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  > "":U then do:
    p-range =  3.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  2.
  end.
  if buf_prop-head.storage-place  = "":U
  and buf_prop-head.storage-place-host  > "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  1.
  end.
  if buf_prop-head.storage-place  > "":U
  and buf_prop-head.storage-place-host  = "":U
  and buf_prop-head.storage-place-obj  = "":U then do:
    p-range =  0.
  end.
end.
end.
end procedure.
procedure discprop-initial:
define input parameter p-dtm-code as integer no-undo .
define input parameter p-node-code as integer no-undo .
define output parameter p-init-value-character as character no-undo .
define output parameter p-init-value-date as date no-undo .
define output parameter p-init-value-decimal as decimal no-undo .
define output parameter p-init-value-integer as integer no-undo .
define output parameter p-init-value-logical as logical no-undo .
define buffer buf_prop-map for ub.prop-map.
find first buf_prop-map no-lock where
          buf_prop-map.dtm-code = p-dtm-code
      and buf_prop-map.node-code = p-node-code no-error.
if not available buf_prop-map then return error substitute("Не найдено свойство &1 для объекта &2"
                                                            , p-node-code
                                                            , p-dtm-code).
assign
p-init-value-character = buf_prop-map.init-value-character
p-init-value-date = buf_prop-map.init-value-date
p-init-value-decimal = buf_prop-map.init-value-decimal
p-init-value-integer = buf_prop-map.init-value-integer
p-init-value-logical = buf_prop-map.init-value-logical
.
end procedure.
Function discprop-usercanedit returns logical (  input p-dtm-code as integer, input p-db-num as integer):
define buffer buf_attr-prop for ub.attr-prop.
find first buf_attr-prop no-lock where
          buf_attr-prop.table-name = 'dis-card-property':U
      and buf_attr-prop.templ-rl-root = p-dtm-code
      and buf_attr-prop.upper-prop-code = "UserCanEdit"
      and buf_attr-prop.prop-code = (if p-db-num = 0 then 'DB0' else 'DBR':U) no-error.
if not available buf_attr-prop
or logical(buf_attr-prop.property-value) = no then do:
  return no.
end.
return yes.
end function.
procedure discprop-edit :
define input parameter p-dtm-code-node-name as character no-undo .
define output parameter p-edit-menu-section-num as integer no-undo .
define buffer buf_attr-prop for ub.attr-prop.
do
on error undo, return error return-value
:
  find first buf_attr-prop no-lock where
          buf_attr-prop.table-name = 'dis-card-property':U
     and  buf_attr-prop.templ-rl-root = integer(entry(1, p-dtm-code-node-name, chr(4)))
     and  buf_attr-prop.upper-prop-code = "ManualEdit":U
     and  buf_attr-prop.prop-code = "SectionNum":U no-error .
  if available buf_attr-prop then do:
    assign
    p-edit-menu-section-num = integer(buf_attr-prop.property-value).
  end.
end.
end procedure.
procedure discprop-node-name :
define input parameter p-dtm-code-node-name as character no-undo .
define output parameter p-tool-tip as character no-undo .
define output parameter p-node-label as character no-undo .
define buffer buf_prop-map for ub.prop-map.
define buffer buf_prop-head for ub.prop-head.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code = integer(entry(1, p-dtm-code-node-name, chr(4) )) no-error .
  assign
  p-tool-tip   = if available buf_prop-head
                 then buf_prop-head.prop-des
                 else entry(1, p-dtm-code-node-name, chr(4) )
  p-node-label = (if available buf_prop-head
                  then buf_prop-head.prop-label
                  else '':U)
  .
  if entry(2, p-dtm-code-node-name, chr(4) ) <> "" then do:
    find first buf_prop-map no-lock where
              buf_prop-map.dtm-code = integer(entry(1, p-dtm-code-node-name, chr(4) ))
        and  buf_prop-map.node-code = integer(entry(2, p-dtm-code-node-name, chr(4) )) no-error.
    if available buf_prop-map then do:
      assign
      p-tool-tip   = buf_prop-map.node-description
      p-node-label = (if available buf_prop-head
                      then buf_prop-head.prop-label
                      else '':U) + ":" + buf_prop-map.node-label
      .
    end.
  end.
end.
end procedure.
procedure discprop-write :
define input parameter p-d-card          like ub.dis-card-property.d-card     no-undo .
define input parameter p-host-code       like ub.dis-card-property.host-code  no-undo .
define input parameter p-obj-type        like ub.dis-card-property.obj-type   no-undo .
define input parameter p-obj-code        like ub.dis-card-property.obj-code   no-undo .
define input parameter p-dtm-code        like ub.dis-card-property.dtm-code   no-undo .
define input parameter p-node-code       like ub.dis-card-property.node-code  no-undo .
define input parameter p-dt-code         like ub.dis-card-property.dt-code    no-undo .
define input parameter p-sum-id          like ub.dis-card-property.sum-id     no-undo .
define input parameter p-value-character like ub.dis-card-property.property-value-character no-undo .
define input parameter p-value-date      like ub.dis-card-property.property-value-date no-undo .
define input parameter p-value-decimal   like ub.dis-card-property.property-value-decimal no-undo .
define input parameter p-value-integer   like ub.dis-card-property.property-value-integer no-undo .
define input parameter p-value-logical   like ub.dis-card-property.property-value-logical no-undo .
define input parameter p-source-type     as character no-undo .
define input parameter p-source-ref      as character no-undo .
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
  define buffer buf_dis-card-property for ub.dis-card-property .
  define buffer buf_dis-card for ub.dis-card.
  define buffer buf_prop-ref for ub.prop-ref.
  define variable v-data-type      as character no-undo .
  define variable v-data-type-1    as character no-undo .
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-range          as integer   no-undo .
  define variable v-rw-option      as character no-undo .
  run discprop-node-code in this-procedure
    (
     input  p-dtm-code
    ,input  p-node-code
    ,output v-data-type
    ,output v-format
    ,output v-label
    ,output v-range
    ,output v-rw-option
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  v-data-type-1 = entry(1, v-data-type).
  if p-dt-code = ? then do:
    find buf_prop-ref no-lock where
        buf_prop-ref.dtm-code = p-dtm-code
    and buf_prop-ref.sum-id = p-sum-id no-error.
    if not available buf_prop-ref then do:
      undo, return error substitute("Неопределен или неоднозначен ИТОГ/СРЕЗ для объекта-операнда &1 &2"
                                    ,p-dtm-code
                                    ,p-sum-id).
    end.
    assign
    p-dt-code = buf_prop-ref.dt-code.
  end.
  if discprop-usercanedit ( input p-dtm-code, input g#db-num)  = no then do:
    undo, return error "Нельзя редактировать свойство в данной БД".
  end.
  run discprop-check in this-procedure (
                                          input v-range
                                        ,input p-d-card
                                        ,input p-host-code
                                        ,input p-obj-type
                                        ,input p-obj-code
                                        ,input p-dtm-code
                                        ,input p-node-code
                                        ,input p-dt-code
                                      ) no-error .
  if error-status:error then undo,  return error return-value .
  find first buf_dis-card-property exclusive-lock
    where buf_dis-card-property.d-card    = p-d-card
      and buf_dis-card-property.host-code = p-host-code
      and buf_dis-card-property.obj-type  = p-obj-type
      and buf_dis-card-property.obj-code  = p-obj-code
      and buf_dis-card-property.dt-code = p-dt-code
      and buf_dis-card-property.node-code = p-node-code
    no-error .
    find first buf_dis-card no-lock where
                buf_dis-card.d-card = p-d-card.
  if not available buf_dis-card-property then do:
    create buf_dis-card-property .
    assign
      buf_dis-card-property.d-card    = p-d-card
      buf_dis-card-property.host-code = p-host-code
      buf_dis-card-property.obj-type  = p-obj-type
      buf_dis-card-property.obj-code  = p-obj-code
      buf_dis-card-property.dt-code = p-dt-code
      buf_dis-card-property.node-code = p-node-code
      buf_dis-card-property.dtm-code = p-dtm-code
      buf_dis-card-property.sum-id   = p-sum-id
      buf_dis-card-property.card-num  = buf_dis-card.card-num
      buf_dis-card-property.main-card  = buf_dis-card.main-card
      buf_dis-card-property.first-card  = buf_dis-card.first-card
      buf_dis-card-property.first-main-card  = buf_dis-card.first-main-card
    .
  end.
  else do:
    if (v-data-type-1 = 'character':U
    and buf_dis-card-property.property-value-character = p-value-character)
    or  (v-data-type-1 = 'date':U
        and buf_dis-card-property.property-value-date = p-value-date)
    or  (v-data-type-1 = 'decimal':U
        and buf_dis-card-property.property-value-decimal = p-value-decimal)
    or  (v-data-type-1 = 'integer':U
        and buf_dis-card-property.property-value-integer = p-value-integer)
    or  (v-data-type-1 = 'logical':U
        and buf_dis-card-property.property-value-logical = p-value-logical)
    then return.
  end.
  run disproph_write-dis-card-property-proc  in this-procedure (
          buffer buf_dis-card-property
          ,buffer Buf_dis-card
          ,input p-d-card
          ,input p-dt-code
          ,input p-host-code
          ,input p-obj-type
          ,input p-obj-code
          ,input p-dtm-code
          ,input buf_dis-card.card-num
          ,input buf_dis-card.main-card
          ,input buf_dis-card.first-card
          ,input buf_dis-card.first-main-card
          ,input p-node-code
          ,input (if new(buf_dis-card-property) then integer('1':U) else integer('2':U))
          ,input p-source-type
          ,input p-source-ref
          ,input-output p-chip-num
          ,input-output p-corr-date
          ,input-output p-corr-time
          ).
  assign
  buf_dis-card-property.property-value-character = (if v-data-type-1 = 'character':U
                                                    then p-value-character
                                                    else buf_dis-card-property.property-value-character)
  buf_dis-card-property.property-value-date      = (if v-data-type-1 = 'date':U
                                                    then p-value-date
                                                    else buf_dis-card-property.property-value-date)
  buf_dis-card-property.property-value-decimal   = (if v-data-type-1 = 'decimal':U
                                                    then p-value-decimal
                                                    else buf_dis-card-property.property-value-decimal)
  buf_dis-card-property.property-value-integer   = (if v-data-type-1 = 'integer':U
                                                    then p-value-integer
                                                    else buf_dis-card-property.property-value-integer)
  buf_dis-card-property.property-value-logical   = (if v-data-type-1 = 'logical':U
                                                    then p-value-logical
                                                    else buf_dis-card-property.property-value-logical)
  buf_dis-card-property.trg-param = (if p-source-type = '':U then '':U else 'no-hist':U)
  .
  release buf_dis-card-property no-error .
  if error-status:error then do:
    return error return-value .
  end.
end.
end procedure.
procedure discprop-delete :
define input parameter p-d-card    like ub.dis-card-property.d-card     no-undo .
define input parameter p-host-code like ub.dis-card-property.host-code  no-undo .
define input parameter p-obj-type  like ub.dis-card-property.obj-type   no-undo .
define input parameter p-obj-code  like ub.dis-card-property.obj-code   no-undo .
define input parameter p-dtm-code  like ub.dis-card-property.dtm-code   no-undo .
define input parameter p-node-code like ub.dis-card-property.node-code  no-undo .
define input parameter p-dt-code   like ub.dis-card-property.dt-code    no-undo .
define input parameter p-source-type as character no-undo .
define input parameter p-source-ref as character no-undo .
define output parameter p-deleted  as logical no-undo.
define input-output parameter p-chip-num as integer no-undo .
define input-output parameter p-corr-date as date no-undo .
define input-output parameter p-corr-time as integer no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
:
define buffer buf_dis-card-property for ub.dis-card-property .
define buffer buf_dis-card for ub.dis-card.
define variable v-data-type      as character no-undo .
define variable v-format         as character no-undo .
define variable v-label          as character no-undo .
define variable v-range          as integer   no-undo .
define variable v-rw-option      as character   no-undo .
  run discprop-node-code in this-procedure
    (input  p-dtm-code
    ,input  p-node-code
    ,output v-data-type
    ,output v-format
    ,output v-label
    ,output v-range
    ,output v-rw-option
    ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_dis-card-property exclusive-lock
    where buf_dis-card-property.d-card    = p-d-card
      and buf_dis-card-property.host-code = p-host-code
      and buf_dis-card-property.obj-type  = p-obj-type
      and buf_dis-card-property.obj-code  = p-obj-code
      and buf_dis-card-property.dt-code = p-dt-code
      and buf_dis-card-property.node-code = p-node-code
    no-error NO-WAIT.
  if not available buf_dis-card-property then do:
    p-deleted = no.
  end.
  else do:
    run disproph_write-dis-card-property-proc  in this-procedure (
         buffer buf_dis-card-property
        ,buffer buf_dis-card
        ,input buf_dis-card-property.d-card
        ,input buf_dis-card-property.dt-code
        ,input buf_dis-card-property.host-code
        ,input buf_dis-card-property.obj-type
        ,input buf_dis-card-property.obj-code
        ,input buf_dis-card-property.dtm-code
        ,input buf_dis-card-property.card-num
        ,input buf_dis-card-property.main-card
        ,input buf_dis-card-property.first-card
        ,input buf_dis-card-property.first-main-card
        ,input buf_dis-card-property.node-code
        ,input integer('99':U)
        ,input p-source-type
        ,input p-source-ref
        ,input-output p-chip-num
        ,input-output p-corr-date
        ,input-output p-corr-time
         ).
    buf_dis-card-property.trg-param = (if p-source-type = '':U then '':U else 'no-hist':U).
    delete buf_dis-card-property no-error .
    if error-status:error then do:
      return error return-value.
    end.
    p-deleted = yes.
  end.
end.
end procedure.
procedure discprop-check :
define input parameter p-range  as integer no-undo .
define input parameter p-d-card like ub.dis-card-property.d-card no-undo .
define input parameter p-host-code like ub.dis-card-property.host-code no-undo .
define input parameter p-obj-type like ub.dis-card-property.obj-type no-undo .
define input parameter p-obj-code like ub.dis-card-property.obj-code no-undo .
define input parameter p-dtm-code like ub.dis-card-property.dtm-code no-undo .
define input parameter p-node-code like ub.dis-card-property.node-code no-undo .
define input parameter p-dt-code like ub.dis-card-property.dt-code no-undo .
define variable v-message as character no-undo .
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_attr-prop for ub.attr-prop.
do
on error undo, return error return-value
:
  if p-host-code > 0 then do:
    FIND FIRST buf_sysconf No-LOCK WHERE
              buf_sysconf.host-code = p-host-code No-ERROR.
    IF NOT AVAIL buf_sysconf THEN DO:
      v-message = substitute("Не найдена фирма &1", p-host-code).
      RETURN ERROR v-message.
    END.
  end.
  if p-obj-type <> "":U or
      p-obj-code <> 0 then do:
    find first buf_clients No-LOCK WHERE
              buf_clients.obj-type = p-obj-type AND
              buf_clients.obj-code = p-obj-code no-error .
    if not available buf_clients then do:
      v-message = substitute("Не найден объект &1&2", p-obj-type, p-obj-code).
      RETURN ERROR v-message.
    end.
  end.
  else if NOT (p-obj-type = "":U and p-obj-code = 0) then do:
    v-message = substitute("Неверные значения параметров p-obj-type/p-obj-code и/или p-host-code: &1&2 &3"
                            , p-obj-type
                            , p-obj-code
                            , p-host-code).
    RETURN ERROR v-message.
  end.
  if p-d-card <> "":U then do:
    find first buf_dis-card No-LOCK WHERE
                buf_dis-card.d-card = p-d-card No-ERROR.
    if not avail buf_dis-card then do:
      v-message =substitute("Не найдена ДК").
      return error  v-message.
    end.
    if buf_dis-card.emitent-host-code <> 0
    and p-host-code <> buf_dis-card.emitent-host-code then do:
      v-message = substitute("Для фирменной карты свойство можно ввести только с привязкой к фирме-эмитенту").
      return error v-message.
    end.
    if buf_dis-card.emitent-host-code = 0
    and p-range = 1
    and p-host-code <> 0 then do:
      v-message = substitute("Для свойство с ОБЛАСТЬЮ ДЕЙСТВИЯ СОГЛАСНО КОДУ ЭМИТЕНТА&1" +
                            "для ГЛОБАЛЬНОЙ карты можно ввести только ГЛОБАЛЬНОЕ свойство"
                              , chr(10)
                            ).
      return error v-message.
    end.
  end.
end.
end procedure.
define variable v-current-d-card as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
define variable v-emitent-host-code as integer no-undo .
define variable v-type as character no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable num-rec-write as integer.
define variable num-rec-write-ok as integer.
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable v-end-new-line     as logical no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-error :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
     assign
     v-last-error-message = p-mess.
  end.
end procedure.
define shared temp-table tt0-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-clients_ no-undo like ub.clients.
define temp-table temp-dis-card_ no-undo like ub.dis-card.
define stream instream.
define variable log-file-name                as character      no-undo init "in-stpl1.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-seek                       as int64          no-undo .
function 00060000_get-readed-line returns character ( input p-seek as int64):
define variable v-line as character no-undo .
seek stream instream to p-seek.
import stream instream unformatted v-line.
return v-line.
end function.
function 00060000_get-error-message returns character :
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
define variable default-host like ub.shop.host-code.
define variable default-issue-host like ub.shop.host-code.
define variable s as char format "X(300)".
define variable n-entry as char no-undo extent 20.
define variable my-dcard like ub.dis-card.d-card.
define variable v-blank1 as character no-undo .
define variable v-blank2 as character no-undo .
define variable v-blank3 as character no-undo .
define variable myproductcode as integer no-undo .
define variable v-blank5 as character no-undo .
define variable myquota as decimal no-undo .
define variable mycarname as character no-undo .
define variable mycarnumber as character no-undo .
define variable my-del-status-int as integer no-undo .
define variable my-stop-list-flag as integer no-undo .
define variable my-ext-cli-code as integer no-undo .
define variable my-obj-name like ub.clients.obj-name.
define variable my-lim-kr as decimal no-undo .
DEFINE VARIABLE myaccounttype AS INTEGER NO-UNDO.
define variable v-blank9 as character no-undo .
define variable my-cli-stop-list-flag as integer no-undo .
define variable my-discount-value as decimal no-undo .
define variable my-seek1 as integer.
define variable my-seek2 as integer.
define variable my-mess as char.
define variable choice as integer no-undo.
define variable dd as decimal.
define variable my-value as integer no-undo.
define variable full-d-card as character no-undo .
define variable ii as integer.
define variable var-rid as recid no-undo .
define variable v-dop as character no-undo .
define variable ss as character no-undo .
define variable v-bas-full-path    as character no-undo .
define variable v-txt-full-path        as character no-undo .
define variable v-txt-path             as character no-undo .
define variable v-txt-file-name        as character no-undo .
define variable v-txt-file-name-no-ext as character no-undo .
define variable v-txt-file-name-ext    as character no-undo .
define variable v-txt-full-path2        as character no-undo .
define variable v-txt-path2             as character no-undo .
define variable v-txt-file-name2        as character no-undo .
define variable v-txt-file-name-no-ext2 as character no-undo .
define variable v-txt-file-name-ext2    as character no-undo .
define variable v-found as logical no-undo .
define variable v-resource-id as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-field-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-status           as character no-undo .
define variable v-stop-list-mess as character no-undo .
define variable v-value as character no-undo .
define variable v-stop-status as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-doc-date as date no-undo .
define variable v-fact-date as date no-undo .
define variable v-fact-time as integer no-undo .
define variable v-status_ as character no-undo .
define variable v-stop-list-value as character no-undo .
define variable v-global-err as logical no-undo .
define variable v-gds-attr-value as character no-undo .
define variable v-car-brand as character no-undo .
define variable v-car-reg-number as character no-undo .
define variable v-limit-type as character no-undo .
define variable v-limit as decimal no-undo .
define variable v-limit-l as decimal no-undo .
define variable v-quota-period as character no-undo .
define variable v-quota as decimal no-undo .
define variable v-cc as integer no-undo .
DEFINE VARIABLE v-account-type AS INTEGER NO-UNDO.
define variable v-pay-code as integer no-undo .
define variable v-cdpay-code as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-entry as character no-undo .
define variable v-ext-product-code as integer no-undo .
define variable v-discount-value as decimal no-undo .
define variable v-dis-kat as integer no-undo .
define variable v-dis-kat-type as character no-undo .
define temp-table ext-product-code no-undo
field ext-code as integer
field gds-code as integer
index pi is unique primary
ext-code.
define buffer buf_dis-card for ub.dis-card.
define buffer buf2_dis-card for ub.dis-card.
define buffer bufg_ext-classif for ub.ext-classif.
define buffer bufc_ext-classif for ub.ext-classif.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf0_stop-list for ub.stop-list.
define buffer buf_stop-list-line for ub.stop-list-line.
define buffer buf_dis-card-type  for ub.dis-card-type.
define buffer buf_Dis-card-property for ub.dis-card-property.
define buffer buf_clients for ub.clients.
define buffer buf_dis-rule for ub.dis-rule.
define buffer term_dis-rule for ub.dis-rule.
define buffer buf_shop for ub.shop.
define temp-table temp-imp no-undo
field src-d-card as character
field d-card as character
field product-code as integer
field quota as decimal
field car-name as character
field car-number as character
field del-status-int as integer
field stop-list-flag as integer
field ext-cli-code as integer
field lim-kr as decimal
field cli-stop-list-flag as integer
field account-type as integer
index pi is unique primary
src-d-card
index imain d-card
.
define temp-table temp-ext-discounts no-undo
field ext-cli-code as integer
field ext-code as integer
field discnt-value like ub.dis-rule.discnt-value
index pi
is unique primary
ext-cli-code
ext-code
.
define temp-table temp-discounts no-undo
field obj-type like ub.dis-rule.obj-type
field obj-code like ub.dis-rule.obj-code
field gds-code like ub.goods.gds-code
field pos-type as character
field ext-code as integer
field dis-kat  like ub.dis-rule.dis-kat
field discnt-value like ub.dis-rule.discnt-value
field value-type like ub.dis-rule.value-type
index pi is unique primary
gds-code
obj-type
obj-code
pos-type
dis-kat
index iobj
obj-type
obj-code
index ikat
dis-kat
ext-code
.
define variable p-close as logical no-undo.
define variable p-this-type-only as logical no-undo .
on delete of this-procedure do:
  run delete-procedure in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return.
if not this-procedure:persistent then do:
  run proc-main in this-procedure ( input p-type
                              ,input p-emitent-host-code ) no-error .
  if error-status:error then do:
      run delete-procedure in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.
procedure proc-main :
define input parameter p-type like ub.dis-card.type no-undo .
define input parameter p-emitent-host-code like ub.dis-card.emitent-host-code no-undo .
_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
assign
v-emitent-host-code = p-emitent-host-code
v-type = p-type.
run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт стоплиста из файла &1", file-name)).
run gbl/filename.p (
                 input  "exe/sibneft-stop-list.bas"
                ,output v-bas-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
if error-status:error  = ? then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не найден МАКРОС для импорта стоплиста по ДК -  &1", "sibneft-stop-list.bas")).
  assign
  v-view-log = yes.
  .
  return error.
end.
run gbl/_tmpfile.p ( input ""
               , ".clients"
               , output v-txt-full-path) .
run gbl/_tmpfile.p ( input ""
               , ".discounts"
               , output v-txt-full-path2) .
run gbl/xlimport.p (
      input v-full-path
    , input v-txt-full-path + chr(44) + v-txt-full-path2
    , input v-bas-full-path
) no-error.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка при чтении из .xls файла&1&2&1&3"
                        , chr(10)
                        , error-status:get-message(1)
                        , return-value
                        )).
  assign
  v-view-log = yes.
  .
  return error.
end.
if search(v-txt-full-path) = ?
or search(v-txt-full-path2) = ? then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не найдены результаты преобразования стоплиста в .txt вид&1&2&1&3"
                        , chr(10)
                        , error-status:get-message(1)
                        , return-value
                        )).
  assign
  v-view-log = yes.
  .
  return error.
end.
assign
file-name = v-txt-full-path.
output stream Instream to value(file-name) append.
put stream instream unformatted skip(1).
output stream Instream close.
run write-log  in p-log-handle(
                                 input 0
                               , "&DLine").
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт стоплиста по ДК из файла &1", file-name)).
for each ext-product-code,
    each buf_shop no-lock:
  for each buf_dis-gds-rule no-lock where
            buf_dis-gds-rule.gds-code = ext-product-code.gds-code
        and buf_dis-gds-rule.obj-type = 'маг':U
        and buf_dis-gds-rule.obj-code = buf_shop.obj-code
        and buf_dis-gds-rule.discnt-role = 'pcnt-kat':U:
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = buf_Dis-gds-rule.rule-num no-error.
    if available buf_dis-rule then do:
       for each term_dis-rule no-lock where
              term_dis-rule.upper-rule-num = buf_Dis-rule.rule-num:
          find first temp-discounts no-lock where
                    temp-discounts.obj-type = 'маг':U
                and temp-discounts.obj-code = buf_shop.obj-code
                and temp-discounts.gds-code = ext-product-code.gds-code
                and temp-discounts.dis-kat = term_dis-rule.dis-kat no-error.
          if not available temp-discounts then do:
            create temp-discounts.
            assign
            temp-discounts.obj-type = 'маг':U
            temp-discounts.obj-code = buf_shop.obj-code
            temp-discounts.gds-code = ext-product-code.gds-code
            temp-discounts.dis-kat = term_dis-rule.dis-kat
            temp-discounts.ext-code = ext-product-code.ext-code
            temp-discounts.pos-type = buf_dis-gds-rule.pos-type
            .
          end.
          assign
          temp-discounts.discnt-value = term_dis-rule.discnt-value
          temp-discounts.value-type = buf_dis-rule.value-type
          .
          release temp-discounts.
       end.
    end.
  end.
end.
find first buf0_stop-list exclusive-lock where
          buf0_stop-list.classif-type = 'dis-card':U
        and buf0_stop-list.stop-list-code = v-current-doc-code  no-error .
if not available buf0_stop-list then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не найден стоплист &1", v-current-doc-code)).
  v-view-log = yes.
  .
end.
input stream Instream from value(file-name).
_stroka:
REPEAT:
  my-seek1 = seek(Instream).
  num-rec = num-rec + 1.
  assign
  my-dcard = ?
  my-del-status-int = ?
  my-stop-list-flag = ?
  my-ext-cli-code = ?
  my-obj-name = ?
  my-lim-kr = ?
  my-cli-stop-list-flag = ?
  myproductcode = ?
  mycarname = '':U
  mycarnumber = '':U
  myquota = ?
  myaccounttype = ?
  .
  import stream INstream
  my-dcard
  myproductcode
  myquota
  mycarname
  mycarnumber
  my-del-status-int
  my-stop-list-flag
  my-ext-cli-code
  my-lim-kr
  my-cli-stop-list-flag
  myaccounttype
  No-ERROR.
  my-seek2 = seek(Instream).
  IF ERROR-STATUS:ERROR
  or (my-seek2 - my-seek1 = 2)
  or (my-seek2 - my-seek1 = 1)
  then do:
      seek STREAM Instream to my-seek1.
      import STREAM Instream unformatted ss.
      my-seek2 = seek(Instream).
      if ss =  "":U then do:
        next _stroka.
      end.
      if num-rec = 1 then do:
          v-global-err = yes.
          my-mess = "Строчка не разобрана!" + chr(10) +
                          "Требуемый формат строки(между полями пробелы - символьные поля закавычены):" + chr(10) +
                          "Номер счета(карты)" + chr(10) +
                          "код топлива" + chr(10) +
                          "квота на топливо" + chr(10) +
                          "марка ТС" + chr(10) +
                          "госномер ТС" + chr(10) +
                          "флаг удаленной карты" + chr(10) +
                          "флаг стоплиста" + chr(10) +
                          "код клиента в системе "  + chr(10) +
                          "лимит по топливу" + chr(10) +
                          "флаг стоплиста клиента" + chr(10) +
                          "Тип счета"
                          .
          DO ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
              my-mess = my-mess + "ош " + string(ERROR-STATUS:GET-NUMBER(ii)) + " - " +
                                  ERROR-STATUS:GET-MESSAGE(ii).
          END.
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input my-mess).
          v-view-log = yes.
          .
      end.
      else do:
          my-mess = "Строчка не разобрана!"  .
          DO ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
              my-mess = my-mess + "ош " + string(ERROR-STATUS:GET-NUMBER(ii)) + " - " +
                                  ERROR-STATUS:GET-MESSAGE(ii).
          END.
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
      end.
  end.
  assign
  my-mess = ""
  .
  find first temp-imp where
            temp-imp.src-d-card = my-dcard no-error.
  if available temp-imp then do:
    my-mess = substitute("!!!ДК &1 встречается в стоплисте более одного раза", temp-imp.d-card).
    run err-write in this-procedure ( input-output my-mess).
    next _stroka.
  end.
  create temp-imp.
  assign
  temp-imp.src-d-card            = my-dcard
  temp-imp.product-code          = (if myaccounttype = 6 then 0 else myproductcode)
  temp-imp.quota                 = myquota
  temp-imp.car-name              = mycarname
  temp-imp.car-number            = mycarnumber
  temp-imp.del-status-int        = my-del-status-int
  temp-imp.stop-list-flag        = my-stop-list-flag
  temp-imp.ext-cli-code          = my-ext-cli-code
  temp-imp.lim-kr                = my-lim-kr
  temp-imp.cli-stop-list-flag    = my-cli-stop-list-flag
  temp-imp.account-type          = myaccounttype
  .
  release temp-imp.
  num-rec-ok = num-rec-ok + 1.
  run show-counter in p-log-handle .
  run write-counter in p-log-handle (substitute("Стоплист: cчитано &1 из них успешно &2"
                                              , num-rec
                                              , num-rec-ok
                                              )) no-error.
  process events.
  run get-stop-state in p-log-handle (
      output v-stop
  ).
  if v-stop then do:
    leave _stroka.
  end.
END.
input stream InStream close.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Чтение стоплиста из файла &1 завершено: из &2 записей успешно считано &3", file-name, num-rec, num-rec-ok )).
assign
num-rec = 0
num-rec-ok = 0
.
assign
file-name = v-txt-full-path2.
output stream Instream to value(file-name) append.
put stream instream unformatted skip(1).
output stream Instream close.
input stream Instream from value(file-name).
_stroka:
REPEAT:
  my-seek1 = seek(Instream).
  num-rec = num-rec + 1.
  assign
  my-ext-cli-code = ?
  myproductcode = ?
  my-discount-value = ?
  .
  import stream INstream
  my-ext-cli-code
  myproductcode
  my-discount-value
  No-ERROR.
  my-seek2 = seek(Instream).
  IF ERROR-STATUS:ERROR
  or (my-seek2 - my-seek1 = 2)
  or (my-seek2 - my-seek1 = 1)
  then do:
      seek STREAM Instream to my-seek1.
      import STREAM Instream unformatted ss.
      my-seek2 = seek(Instream).
      if ss =  "":U then do:
        next _stroka.
      end.
      if num-rec = 1 then do:
          v-global-err = yes.
          my-mess = "Строчка не разобрана!" + chr(10) +
                          "Требуемый формат строки(между полями пробелы - символьные поля закавычены):" + chr(10) +
                          "код клиента в системе "  + chr(10) +
                          "код топлива в системе "  + chr(10) +
                          "Значение скидки на топливо"
                          .
          DO ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
              my-mess = my-mess + "ош " + string(ERROR-STATUS:GET-NUMBER(ii)) + " - " +
                                  ERROR-STATUS:GET-MESSAGE(ii).
          END.
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input my-mess).
          v-view-log = yes.
          .
      end.
      else do:
          my-mess = "Строчка не разобрана!"  .
          DO ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
              my-mess = my-mess + "ош " + string(ERROR-STATUS:GET-NUMBER(ii)) + " - " +
                                  ERROR-STATUS:GET-MESSAGE(ii).
          END.
          run err-write in this-procedure ( input-output my-mess).
          next _stroka.
      end.
  end.
  assign
  my-mess = ""
  .
  find first temp-ext-discounts where
            temp-ext-discounts.ext-cli-code = my-ext-cli-code
        and temp-ext-discounts.ext-code = myproductcode
              no-error.
  if available temp-ext-discounts then do:
    my-mess = substitute("!!!Клиент &1 топливо &2 встречается в листе скидок более одного раза"
                          , temp-ext-discounts.ext-cli-code
                          , temp-ext-discounts.ext-code
                          ).
    run err-write in this-procedure ( input-output my-mess).
    next _stroka.
  end.
  create temp-ext-discounts.
  assign
  temp-ext-discounts.ext-cli-code = my-ext-cli-code
  temp-ext-discounts.ext-code     = myproductcode
  temp-ext-discounts.discnt-value = my-discount-value
  .
  release temp-ext-discounts.
  num-rec-ok = num-rec-ok + 1.
  run show-counter in p-log-handle .
  run write-counter in p-log-handle (substitute("Скидки: cчитано &1 из них успешно &2"
                                              , num-rec
                                              , num-rec-ok
                                              )) no-error.
  run get-stop-state in p-log-handle (
      output v-stop
  ).
  if v-stop then do:
    leave _stroka.
  end.
END.
output to temp-ext-discounts.txt.
for each temp-ext-discounts:
 export temp-ext-discounts.
end.
output close.
os-delete value(v-txt-full-path).
os-delete value(v-txt-full-path2).
run show-counter in p-log-handle .
run write-counter in p-log-handle (substitute("Сохранение..." )) no-error.
if not v-stop then do:
  _stroka2:
  for each temp-imp
  on error undo _stroka2, next _stroka2 :
    if temp-imp.src-d-card = '':U then next _stroka2.
    num-rec-write = num-rec-write + 1.
    IF NOT temp-imp.src-d-card  = ? then do:
      assign
      full-d-card = ean-13("99" + temp-imp.src-d-card + "1", "")
      no-error
      .
      if error-status:error
      or full-d-card = ? then do:
        my-mess = substitute("!!!Ошибка попытке восстановить полный номер карты &1"
                              , temp-imp.src-d-card).
        run err-write2 in this-procedure ( input-output my-mess).
        NEXT _stroka2.
      end.
      assign
      temp-imp.d-card = full-d-card.
      FIND FIRST buf_dis-card NO-LOCK WHERE
                  buf_dis-card.d-card = temp-imp.d-card NO-ERROR.
      if not available buf_dis-card then do:
        my-mess = substitute("!!!Нет дисконтной карты с номером &1"
                              , temp-imp.d-card).
        run err-write2 in this-procedure ( input-output my-mess).
        NEXT _stroka2.
      end.
      if p-this-type-only = yes
      and not (buf_dis-card.type = v-type
               and
               buf_dis-card.emitent-host-code = v-emitent-host-code) then do:
        my-mess = substitute("В импортируемом стоплисте встретилась карта &1 ДРУГОГО типа/эмитента: &2 эмитент &3&4" +
                             "согласно параметрам импорта - пропускаем"
                             , buf_dis-card.d-card
                             , buf_dis-card.type
                             , buf_Dis-card.emitent-host-code
                             , chr(10)
                             ).
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input my-mess).
        next _stroka2.
      end.
    END.
    else do:
      my-mess = "!!!Не задан номер дисконтной карты" .
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    find first buf_dis-card-type no-lock where
            buf_dis-card-type.emitent-host-code = buf_dis-card.emitent-host-code
      and  buf_dis-card-type.type = buf_dis-card.type no-error.
    if not available buf_dis-card-type then do:
      my-mess = substitute("!!!Не удалось определить тип ДК для ДК &1", buf_dis-card.d-card).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    v-pay-code = buf_dis-card-type.pay-code.
    if temp-imp.product-code = ?
    or (temp-imp.product-code = 0 and temp-imp.account-type <> 6) then do:
      my-mess = substitute("!!!Не задан код топлива").
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.product-code > 0
    and temp-imp.account-type <> 6 then do:
      find first ext-product-code no-lock where
                          ext-product-code.ext-code = temp-imp.product-code no-error.
      if not available ext-product-code then do:
        my-mess = substitute("!!!Неизвестное значение кода топлива &1", temp-imp.product-code).
        run err-write2 in this-procedure ( input-output my-mess).
        NEXT _stroka2.
      end.
    end.
    assign
    v-car-reg-number = '':U
    v-car-brand  = '':U
    v-limit-type = '':U
    v-limit = 0.0
    v-limit-l = 0.0
    v-quota-period = '':U
    v-quota = 0.0
    v-account-type = 0
    v-cdpay-code = 0
    .
    v-found = no.
    for each buf_dis-card-property no-lock where
            buf_Dis-card-property.d-card = temp-imp.d-card
       and buf_Dis-card-property.dtm-code = 18
    break
    by buf_Dis-card-property.dt-code:
      if buf_dis-card-property.sum-id <> substitute("petrol-&1"
                                              ,(if temp-imp.product-code > 0
                                                then ext-product-code.gds-code else 0)) then next.
      v-found = yes.
      case buf_dis-card-property.node-code:
        when
        1 then do:
          assign
          v-car-reg-number = buf_Dis-card-property.property-value-character
          .
        end.
        when
        2 then do:
          assign
          v-car-brand  = buf_Dis-card-property.property-value-character
          .
        end.
        when
        3 then do:
          assign
          v-limit-type = buf_Dis-card-property.property-value-character
          .
        end.
        when
        4 then do:
          assign
          v-limit = buf_Dis-card-property.property-value-decimal
          .
        end.
        when
        5 then do:
          assign
          v-limit-l = buf_Dis-card-property.property-value-decimal
          .
        end.
        when
        6 then do:
          assign
          v-quota-period = buf_Dis-card-property.property-value-character
          .
        end.
        when
        7 then do:
          assign
          v-quota = buf_Dis-card-property.property-value-decimal
          .
            end.
        when
        8 then do:
          assign
          v-account-type = buf_Dis-card-property.property-value-integer
          .
        end.
        when
        9 then do:
          assign
          v-cdpay-code = buf_Dis-card-property.property-value-integer
          .
        end.
      end case.
    end.
    if not v-found then do:
      my-mess = substitute("!!!Ошибка при определении Транспортных средств и лимитов по топливу &1&3" +
                             "для ДК &4&3&5&3&6&3" +
                             "они не определены или неправильно заполнены&3"
                            , temp-imp.product-code
                            , v-pay-code
                            , chr(10)
                            , temp-imp.d-card
                            , error-status:get-message(1)
                            , return-value
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if v-cdpay-code <> v-pay-code then do:
      my-mess = substitute("!!!Неверно задан тип кассового платежа для оплаты топлива:&1согласно типу ДК должно быть &2, в свойствах ДК - &3"
                           , chr(10)
                           , v-pay-code
                           , v-cdpay-code
                           ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if
    temp-imp.car-name = ?
    then do:
      my-mess = substitute("!!!Не задана марка транспортного средства").
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if
    temp-imp.car-number = ?
    then do:
      my-mess = substitute("!!!Не задан гос.рег.номер транспортного средства").
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.car-name <> v-car-brand then do:
      my-mess = substitute("!!!Марка транспортного средства = &1 для ДК &2 в системе IBS TH &3" +
                            "не совпадает с маркой транспортного средства =&4, указанной в стоплисте"
                            , v-car-brand
                            , temp-imp.d-card
                            , chr(10)
                            , temp-imp.car-name
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.car-number <> v-car-reg-number then do:
      my-mess = substitute("!!!Гос.рег.номер транспортного средства =&1 для ДК &2 в системе IBS TH &3" +
                            "не совпадает с гос.рег.номером транспортного средства &4, указанным в стоплисте"
                            , v-car-reg-number
                            , temp-imp.d-card
                            , chr(10)
                            , temp-imp.car-number
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.quota <> v-quota then do:
      my-mess = substitute("!!!Значение квоты по топливу &1 =&2 для ДК &3 в системе IBS TH&4" +
                            "не совпадает со значением квоты =&5, указанным в стоплисте"
                            , temp-imp.product-code
                            , v-quota
                            , temp-imp.d-card
                            , chr(10)
                            , temp-imp.quota
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_Dis-card.cli-type
          and buf_clients.obj-code = buf_Dis-card.cli-code no-error .
    if not available buf_clients then do:
      my-mess = substitute("!!!Не найден держатель карты &1 - &2&3"
                            , buf_Dis-card.d-card
                            , buf_Dis-card.cli-type
                            , buf_Dis-card.cli-code
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if integer(v-account-type) <> temp-imp.account-type then do:
      my-mess = substitute("!!!Значение ТИП СЧЕТА КАРТЫ для ДК &2 в системе IBS TH&3" +
                            "не совпадает со значением ТИПА СЧЕТА КАРТЫ =&4, указанным в стоплисте"
                            , integer(v-account-type)
                            , temp-imp.d-card
                            , chr(10)
                            , temp-imp.account-type
                            ).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.del-status-int <> 0
    and temp-imp.del-status-int <> 1 then do:
      my-mess = substitute("!!!Неверное значение флага удаленной карты= &1", temp-imp.del-status-int).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.stop-list-flag <> 0
    and temp-imp.stop-list-flag <> 1 then do:
      my-mess = substitute("!!!Неверное значение флага стоплиста= &1", temp-imp.stop-list-flag).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    if temp-imp.cli-stop-list-flag <> 0
    and temp-imp.cli-stop-list-flag <> 1 then do:
      my-mess = substitute("!!!Неверное значение флага стоплиста клиента= &1", temp-imp.cli-stop-list-flag).
      run err-write2 in this-procedure ( input-output my-mess).
      NEXT _stroka2.
    end.
    v-dis-kat = buf_Dis-card.category.
    define variable v-found as logical no-undo .
    _discounts:
    for each temp-ext-discounts where
              temp-ext-discounts.ext-cli-code = temp-imp.ext-cli-code:
      if temp-imp.account-type <> 6
      and temp-ext-discounts.ext-code <> temp-imp.product-code then next _discounts.
      v-found = no.
      for each temp-discounts  where
              temp-discounts.dis-kat = v-dis-kat
          and temp-discounts.ext-code = temp-ext-discounts.ext-code :
        v-found = yes.
        if not (temp-discounts.discnt-value = temp-ext-discounts.discnt-value
              and
              temp-discounts.value-type = integer('2':U)
              ) then do:
          my-mess = substitute("!!!Неверное значение атрибута КАТЕГОРИЯ СКИДКИ=&1&2" +
                              "на объекте &3&4 для места использования &8 значение скидки на товар &5=&6, а должно быть &7"
                             ,v-dis-kat
                             ,chr(10)
                             ,temp-discounts.obj-type
                             ,temp-discounts.obj-code
                             ,temp-discounts.gds-code
                             ,temp-discounts.discnt-value
                             ,temp-ext-discounts.discnt-value
                             ,temp-discounts.pos-type
                             ).
          run err-write2 in this-procedure ( input-output my-mess).
          NEXT _stroka2.
        end.
      end.
      if not v-found then do:
        my-mess = substitute("!!!Неверное значение КАТЕГОРИЯ СКИДКИ=&1&2" +
                            "для такой категории не задано значение скидки на товар &3"
                            ,v-dis-kat
                            ,chr(10)
                            ,temp-ext-discounts.ext-code
                            ).
        run err-write2 in this-procedure ( input-output my-mess).
        NEXT _stroka2.
      end.
    end.
    if p-save = 0 then do:
      DO ON STOP UNDO _stroka2, NEXT _stroka2
      ON ERROR UNDO _stroka2, NEXT _stroka2:
        if temp-imp.del-status-int = 1
        then do:
         if not p-this-type-only
            or (buf_dis-card.type = v-type
          and buf_dis-card.emitent-host-code = v-emitent-host-code) then do:
            find first buf_stop-list-line no-lock where
                      buf_stop-list-line.classif-type = 'dis-card':U
                  and buf_stop-list-line.stop-list-code = v-current-doc-code
                  and buf_stop-list-line.charkey_one = buf_dis-card.d-card no-error.
            if not available buf_stop-list-line then do:
            v-stop-status = integer('4':U).
                        v-stop-list-mess = entry (lookup (string(v-stop-status), '1,2,3,4':U) + 1, ',':U + 'стоп-карта,стоп-клиент,стоп-карта;стоп-клиент,удал-карта':U).
              run gen-key-rec in this-procedure ( input 'dis-card':U
                                                  ,input (buffer buf_dis-card:handle)
                                                  ,output v-resource-id).
              find last buf_stop-list-line no-lock where
                        buf_stop-list-line.classif-type = 'dis-card':U
                    and buf_stop-list-line.stop-list-code = v-current-doc-code  no-error.
              if available buf_stop-list-line then do:
                v-line-num = buf_stop-list-line.line-num.
              end.
              else do:
                v-line-num = 0.
              end.
              create buf_stop-list-line.
              assign
              buf_stop-list-line.classif-type = 'dis-card':U
              buf_stop-list-line.stop-list-code = v-current-doc-code
              buf_stop-list-line.line-message = v-stop-list-mess
              buf_stop-list-line.resource_id = v-resource-id
              buf_stop-list-line.charkey_one = buf_dis-card.d-card
              buf_stop-list-line.key#_one = v-stop-status
              buf_stop-list-line.line-num = v-line-num + 1
              v-line-num = v-line-num + 1
              .
              release buf_stop-list-line no-error .
              if error-status:error then do:
                my-mess =  substitute("!!!Ошибка при внесении карты ДК &1 клиента &2&3 в стоплист &4&5" +
                                        "&6&5&7"
                                        ,buf_dis-card.d-card
                                        ,buf_dis-card.cli-type
                                        ,buf_dis-card.cli-code
                                        ,v-current-doc-code
                                        ,chr(10)
                                        ,error-status:get-message(1)
                                        ,return-value ).
                run err-write2 in this-procedure ( input-output my-mess).
                NEXT _stroka2.
              end.
            end.
          end.
        end.
        else do:
          if temp-imp.cli-stop-list-flag = 1 then do:
            if temp-imp.stop-list-flag = 0 then do:
              v-stop-status = integer('2':U).
                      v-stop-list-mess = entry (lookup (string(v-stop-status), '1,2,3,4':U) + 1, ',':U + 'стоп-карта,стоп-клиент,стоп-карта;стоп-клиент,удал-карта':U).
            end.
            else do:
              v-stop-status = 3.
              v-stop-status = integer('3':U).
                      v-stop-list-mess = entry (lookup (string(v-stop-status), '1,2,3,4':U) + 1, ',':U + 'стоп-карта,стоп-клиент,стоп-карта;стоп-клиент,удал-карта':U).
            end.
            find first buf_clients no-lock where
                      buf_clients.obj-type = buf_Dis-card.cli-type
                  and buf_clients.obj-code = buf_Dis-card.cli-code.
            run gen-key-rec in this-procedure ( input 'clients':U
                                                ,input (buffer buf_clients:handle)
                                                ,output v-resource-id).
            find last buf_stop-list-line no-lock where
                      buf_stop-list-line.classif-type = 'dis-card':U
                  and buf_stop-list-line.stop-list-code = v-current-doc-code  no-error.
            if available buf_stop-list-line then do:
              v-line-num = buf_stop-list-line.line-num.
            end.
            else do:
              v-line-num = 0.
            end.
            _buf2:
            FOR EACH buf2_dis-card no-lock WHERE
                  buf2_dis-card.cli-type = buf_dis-card.cli-type
            AND  buf2_dis-card.cli-code = buf_dis-card.cli-code
            on error  undo _stroka2, next _stroka2
            on stop   undo _stroka2, next _stroka2
            on endkey undo _stroka2, next _stroka2
            :
              if p-this-type-only
              and not (buf2_dis-card.type = v-type
                      and
                      buf2_dis-card.emitent-host-code = v-emitent-host-code) then next _buf2.
              find first buf_stop-list-line no-lock where
                        buf_stop-list-line.classif-type = 'dis-card':U
                    and buf_stop-list-line.stop-list-code = v-current-doc-code
                    and buf_stop-list-line.charkey_one = buf2_dis-card.d-card no-error.
              if not available buf_stop-list-line then do:
                create buf_stop-list-line.
                assign
                buf_stop-list-line.classif-type = 'dis-card':U
                buf_stop-list-line.stop-list-code = v-current-doc-code
                buf_stop-list-line.line-message = v-stop-list-mess
                buf_stop-list-line.resource_id = v-resource-id
                buf_stop-list-line.charkey_one = buf2_dis-card.d-card
                buf_stop-list-line.key#_one = v-stop-status
                buf_stop-list-line.line-num = v-line-num + 1
                v-line-num = v-line-num + 1
                .
                release buf_stop-list-line no-error .
                if error-status:error then do:
                  my-mess =  substitute("!!!Ошибка при внесении карты ДК &1 клиента &2&3 в стоплист &4&5" +
                                          "&6&5&7"
                                          ,buf2_dis-card.d-card
                                          ,buf2_dis-card.cli-type
                                          ,buf2_dis-card.cli-code
                                          ,v-current-doc-code
                                          ,chr(10)
                                          ,error-status:get-message(1)
                                          ,return-value ).
                  run err-write2 in this-procedure ( input-output my-mess).
                  NEXT _stroka2.
                end.
              end.
            END.
          end.
          else do:
            if temp-imp.stop-list-flag = 1 then do:
              if p-this-type-only
              and not (buf_dis-card.type = v-type
                        and
                        buf_dis-card.emitent-host-code = v-emitent-host-code) then do:
              end.
              else do:
                find first buf_stop-list-line no-lock where
                          buf_stop-list-line.classif-type = 'dis-card':U
                      and buf_stop-list-line.stop-list-code = v-current-doc-code
                      and buf_stop-list-line.charkey_one = buf_dis-card.d-card no-error.
                if not available buf_stop-list-line then do:
                v-stop-status = integer('1':U).
                                v-stop-list-mess = entry (lookup (string(v-stop-status), '1,2,3,4':U) + 1, ',':U + 'стоп-карта,стоп-клиент,стоп-карта;стоп-клиент,удал-карта':U).
                  run gen-key-rec in this-procedure ( input 'dis-card':U
                                                      ,input (buffer buf_dis-card:handle)
                                                      ,output v-resource-id).
                  find last buf_stop-list-line no-lock where
                            buf_stop-list-line.classif-type = 'dis-card':U
                        and buf_stop-list-line.stop-list-code = v-current-doc-code  no-error.
                  if available buf_stop-list-line then do:
                    v-line-num = buf_stop-list-line.line-num.
                  end.
                  else do:
                    v-line-num = 0.
                  end.
                  create buf_stop-list-line.
                  assign
                  buf_stop-list-line.classif-type = 'dis-card':U
                  buf_stop-list-line.stop-list-code = v-current-doc-code
                  buf_stop-list-line.line-message = v-stop-list-mess
                  buf_stop-list-line.resource_id = v-resource-id
                  buf_stop-list-line.charkey_one = buf_dis-card.d-card
                  buf_stop-list-line.key#_one = v-stop-status
                  buf_stop-list-line.line-num = v-line-num + 1
                  v-line-num = v-line-num + 1
                  .
                  release buf_stop-list-line no-error .
                  if error-status:error then do:
                    my-mess =  substitute("!!!Ошибка при внесении карты ДК &1 клиента &2&3 в стоплист &4&5" +
                                            "&6&5&7"
                                            ,buf_dis-card.d-card
                                            ,buf_dis-card.cli-type
                                            ,buf_dis-card.cli-code
                                            ,v-current-doc-code
                                            ,chr(10)
                                            ,error-status:get-message(1)
                                            ,return-value ).
                    run err-write2 in this-procedure ( input-output my-mess).
                    NEXT _stroka2.
                  end.
                  num-rec-write-ok = num-rec-write-ok + 1.
                end.
              end.
            end.
          end.
        end.
      END.
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Сохранялось &1 из них успешно &2"
                                                  , num-rec-write
                                                  , num-rec-write-ok
                                                  )) no-error.
    end.
    run get-stop-state in p-log-handle (
        output v-stop
    ).
    if v-stop then do:
      leave _stroka2.
    end.
  end.
  if not v-stop then do:
    for each buf_dis-card no-lock:
      if buf_dis-card.status_ = 'тек':U then do:
        find first temp-imp where
                  temp-imp.d-card = buf_dis-card.d-card no-error.
        if not available temp-imp then do:
          my-mess =  substitute("!!!В системе IBS TH обнаружена лишняя ДК &1 в статусе &2,&3" +
                                  "которой нет в стоплисте &4"
                                  ,buf_dis-card.d-card
                                  ,'тек':U
                                  ,chr(10)
                                  ,v-current-doc-code).
          run err-write3 in this-procedure ( input-output my-mess).
        end.
      end.
      find   buf_dis-card-property no-lock where
                                        buf_dis-card-property.dtm-code = 18
                                    and buf_dis-card-property.d-card = buf_dis-card.d-card
                                    and buf_dis-card-property.host-code = 0
                                    and buf_dis-card-property.obj-type = '':U
                                    and buf_dis-card-property.obj-code = 0
                                    and buf_dis-card-property.node-code = 8
                                    no-error.
      if ambiguous buf_dis-card-property then do:
        my-mess =  substitute("!!!В системе IBS TH обнаружено более одного&2свойства типа ТОПЛИВО для ДК &1&2"
                                ,buf_dis-card.d-card
                                ,chr(10)
                                ).
        run err-write3 in this-procedure ( input-output my-mess).
      end.
    end.
  end.
  run write-counter in p-log-handle ( input "") no-error.
end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Сохранение стоплиста из файла &1 завершено: из &2 записей успешно сохранено &3", file-name, num-rec-write, num-rec-write-ok )).
if p-close
and v-global-err = no then do:
  run ref/stop-l2.p (
                  input parparentproc
                 ,input recid(buf0_stop-list)
                 ,input yes) no-error.
  if error-status:error then do:
    my-mess =  substitute("!!!Ошибка при записи шапки стоплиста &1&2" +
                            "&3&2&4"
                            ,v-current-doc-code
                            ,chr(10)
                            ,error-status:get-message(1)
                            ,return-value ).
    run err-write2 in this-procedure (input-output my-mess).
  end.
end.
  end.
end procedure.
procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for tt0-rule-call-param.
  do
  on error undo, return error
  :
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-close"
 no-error.
if available buf_rule-call-param then do:
assign p-close = buf_rule-call-param.param-value-logical.
end.
 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-this-type-only"
 no-error.
if available buf_rule-call-param then do:
assign p-this-type-only = buf_rule-call-param.param-value-logical.
end.
    case p-ruleset-id:
      when 1 then do:
        assign
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        v-current-date = p-doc-date
        v-current-doc-code = p-doc-code
        file-name  = p-process-file-name
        .
        if NOT g#db-num = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Импорт стоплистов возможен только в ГБД")).
          assign
          v-view-log = yes.
          .
          return "return".
        end.
        run gbl/filename.p (
                        input  file-name
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("Не найден файл &1 для импорта стоплистов", file-name)).
          assign
          v-view-log = yes.
          .
          return "return".
        end.
        assign
        file-name = v-full-path.
      end.
    end case.
  end.
end procedure.
procedure delete-procedure :
  do
  on error undo, return error
  :
      run garbcoll_clear in this-procedure .
  end.
end procedure.
PROCEDURE err-write:
  DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
  seek STREAM Instream to my-seek1.
  import stream InStream unformatted
  s.
  v-global-err = yes.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input mess + chr(10) + s).
  assign
  v-view-log = yes.
  mess = "".
  seek STREAM Instream to my-seek2.
END PROCEDURE.
PROCEDURE err-write2:
  DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
  v-global-err = yes.
  mess = substitute("&1&2Счет &3"
                    ,mess
                    ,chr(10)
                    ,temp-imp.src-d-card
                    ).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input mess).
  assign
  v-view-log = yes.
  mess = "".
END PROCEDURE.
PROCEDURE err-write3:
  DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
  v-global-err = yes.
  mess = substitute("&1&2Карта &3"
                    ,mess
                    ,chr(10)
                    ,buf_dis-card.d-card
                    ).
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input mess).
  assign
  v-view-log = yes.
  mess = "".
END PROCEDURE.
