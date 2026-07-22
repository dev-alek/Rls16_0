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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18 набор правил 4".
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
define shared temp-table ord-list no-undo
field host-code  like ub.ord-doc.host-code
field cli-type   like ub.ord-doc.cli-type
field cli-code   like ub.ord-doc.cli-code
field doc-date   like ub.ord-doc.doc-date
field doc-code   like ub.ord-doc.doc-code
field obj-type   like ub.ord-doc.obj-type
field obj-code   like ub.ord-doc.obj-code
field fact-num   like ub.ord-doc.fact-num
field fact-date  like ub.ord-doc.fact-date
field shift-date like ub.ord-doc.shift-date
field shift-num  like ub.ord-doc.shift-num
field shift-name like ub.ord-doc.shift-name
field ord-int1   like ub.ord-doc.ord-int1
field cli-out-doc like ub.ord-doc.cli-out-doc
field ship-date  like ub.ord-doc.ship-date
field ship-time  like ub.ord-doc.ship-time
field status_    as character
field trn-doc    as character
field fact-order as decimal
field is-trn-doc as logical
field doc-type   like ub.ord-doc.doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field ps         as character
field dm         as integer
field charkey_one as character
index xpk is primary unique doc-code doc-type trn-doc
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define temp-table ordrsp no-undo
field id as character
field creationDateTime as character
field sender as character
field recipient as character
field documentType as character
field ordrspNumber as character
field ordrspDate as character
field status_ as character
field orderNumber as character
field orderDate as character
field seller_gln as character
field buyer_gln as character
field estimatedDeliveryDateTime as character
field shipFrom_gln as character
field shipTo_gln as character
field currencyISOCode as character
.
define temp-table lineItem no-undo
field NUMBER  as character
field status_ as character
field gtin as character
field description as character
field internalBuyerCode as character
field internalSupplierCode as character
field unitOfMeasure as character
field orderedQuantity as decimal
field confirmedQuantity as decimal
field netPrice as decimal
field netAmount as decimal
field vATAmount as decimal
field netPriceWithVAT as decimal
field amount as decimal
field vATRate as decimal
index pi is primary unique
    internalBuyerCode
.
define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table temp-hist-nws-option no-undo
like ub.hist-nws-option
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define shared temp-table temp-xml-tables no-undo
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
define shared temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                                                        ,vss-include-info10
                                                        ,p-gate-rec).
find first buf_clob-data no-lock where
          rowid(buf_clob-data) = v-tbl-row no-error.
if not available buf_clob-data then do:
  if error-status:error then undo, return error substitute("&1 (get-gate-name) Несуществующий gate &2"
                                                          ,vss-include-info10
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info10, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info10 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info10 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info10, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info10 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info10 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info10, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info10 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info10 )
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info10, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info10 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info10 )
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-edi-status no-undo
like ub.edi-status.
define variable cr-edist_full-mess as longchar  no-undo .
procedure create-edi-statett :
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
define buffer buf_EDI-status for temp-EDI-status  .
define variable v-time as integer   no-undo .
define variable v-date as date   no-undo .
do
on error undo, return error return-value
:
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
  cr-edist_full-mess = cr-edist_full-mess +
                        (if cr-edist_full-mess = ''
                        then ''
                        else (chr(13) + chr(10))) +
                        (if num-entries(p-doc-code, chr(4)) > 1
                        then substitute("Товар с кодом &1: ", entry(2, p-doc-code, chr(4)))
                        else '') +
                        cr-edist_get-mess-mean (p-des)
  .
end.
end procedure.
procedure update-edi-state-lighttt :
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ord-code :
define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .
define variable          v-idop     as character no-undo .
  do
  on error undo, return error return-value
  :
case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
      else
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
    end.
    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
          else
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.
    when "chip" then do:
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          substring (v-idop , 1, index (v-idop, "-")) +
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.
end case.
  end.
end procedure.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE write-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
               ub.contract-specif-attr.contract-num = p-contract-num  and
               ub.contract-specif-attr.host-code    = p-host-code     and
               ub.contract-specif-attr.gds-code     = p-gds-code      and
               ub.contract-specif-attr.attr-code    = 'bonus':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'bonus':U
         .
      end.
      ub.contract-specif-attr.attr-value  = string (v-bonus) .
end.
END PROCEDURE.
PROCEDURE read-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'bonus':U
           no-error .
   if available ub.contract-specif-attr then  v-bonus = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-bonus = 0 .
end.
END PROCEDURE.
PROCEDURE write-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-prc-min        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              ub.contract-specif-attr.attr-value  = string (v-prc-min)
         .
      end.
      else do:
         ub.contract-specif-attr.attr-value  = string (v-prc-min) .
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-prc-min as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'prc-min':U
           no-error .
   if available ub.contract-specif-attr then  v-prc-min = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-prc-min = 0 .
end.
END PROCEDURE.
PROCEDURE write-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = "retro-bonus"
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = "retro-bonus"
         .
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
      else do:
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = "retro-bonus"
           no-error .
   if available ub.contract-specif-attr then  v-retro-bonus = ub.contract-specif-attr.attr-value  .
                                        else  v-retro-bonus = "" .
end.
END PROCEDURE.
define variable v-desadv-DELIVERYNOTENUMBER as character no-undo.
define variable v-desadv-DELIVERYNOTEDATE as date no-undo.
define variable v-cli-out-doc as character no-undo .
define variable v-desadv-invoiceNUMBER as character no-undo.
define variable v-desadv-invoiceDATE as date no-undo.
define temp-table temp-rcv-line-new no-undo like ub.ord-line-rcv .
procedure edocsord_export :
define parameter buffer buf_ord-doc for ub.ord-doc.
define input parameter p-ext-rcv-code as character no-undo .
define input parameter p-status_ as integer no-undo .
do
on error undo, return error
:
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
    find first buf_ord-doc-rcv exclusive-lock where
             buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
         and buf_ord-doc-rcv.sub-par begins string(trim(p-ext-rcv-code) + chr(4)) no-error .
  if available buf_ord-doc-rcv then do:
     assign
      buf_ord-doc-rcv.ord-int1 = p-status_
     .
  end.
  assign
    buf_ord-doc.ord-int1 = p-status_
  .
end.
end procedure.
procedure edocsord_edi-import :
define parameter buffer buf_ord-doc for ub.ord-doc.
define input parameter p-cli-out-doc as character no-undo .
define input parameter p-trn-code as character no-undo .
define input parameter p-status as integer no-undo .
define input parameter p-ship-date as date no-undo .
define input parameter p-ps as character no-undo .
define input parameter p-pack-num-chr as character no-undo .
define input parameter p-ediinterchangeid as character no-undo .
define output parameter p-new-ps as character no-undo .
define output parameter p-new-st as integer no-undo .
define variable v-permitted-status-list as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-number as character no-undo .
define variable v-cli-doc-date-chr as character no-undo .
define variable v-transport-cli-type-code as character no-undo .
define variable v-without as logical no-undo .
define variable v-edist-mess as character no-undo .
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_clients for ub.clients.
define buffer buf_pos for lineItem.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if num-entries(p-trn-code, chr(4) ) > 1 then do:
    v-cli-doc-date-chr = entry(2, p-trn-code, chr(4) ).
  end.
  if num-entries(p-trn-code, chr(4) ) > 2 then do:
    v-transport-cli-type-code = entry(3, p-trn-code, chr(4) ).
  end.
  p-trn-code = entry(1, p-trn-code, chr(4) ).
  case p-status :
    when integer('12':U) then do:
      assign
      v-permitted-status-list = '1':U.
      v-number = buf_ord-doc.doc-code.
    end.
    when integer('2':U) then do:
      assign
      v-permitted-status-list = '1':U + chr(44) +
                                  '12':U .
      v-number = buf_ord-doc.doc-code.
    end.
    when integer('3':U)  then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = buf_ord-doc.cli-type
            and buf_clients.obj-code = buf_ord-doc.cli-code.
      run gen-key-rec in this-procedure ( input 'clients':U
                                          ,input (buffer buf_clients:handle)
                                          ,output v-uniq-key-rec
                                          ).
      find first buf_ext-classif no-lock where
                  buf_ext-classif.classif-subject = 'clients':U
              and buf_ext-classif.classif-name = 'exite-edi':U
              and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error.
      if not available buf_ext-classif then do:
         v-permitted-status-list = ''.
      end.
      if buf_ext-classif.charkey_one = 'without-ordrsp':U then do:
        v-permitted-status-list = ''.
        v-without = yes.
      end.
      else do:
        assign
        v-permitted-status-list = '1':U + chr(44) +
                                  '2':U + chr(44) +
                                  '4':U + chr(44) +
                                  '12':U
                                  .
        v-number = entry(1, p-cli-out-doc, chr(4)).
      end.
    end.
    when integer('6':U)  then do:
      find first buf_clients no-lock where
                buf_clients.obj-type = buf_ord-doc.cli-type
            and buf_clients.obj-code = buf_ord-doc.cli-code.
      run gen-key-rec in this-procedure ( input 'clients':U
                                          ,input (buffer buf_clients:handle)
                                          ,output v-uniq-key-rec
                                          ).
      find first buf_ext-classif no-lock where
                  buf_ext-classif.classif-subject = 'clients':U
              and buf_ext-classif.classif-name = 'exite-edi':U
              and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error.
      if not available buf_ext-classif then do:
         v-permitted-status-list = ''.
      end.
      if buf_ext-classif.charkey_one = 'without-ordrsp':U then do:
        v-permitted-status-list = ''.
        v-without = yes.
      end.
      else do:
        assign
        v-permitted-status-list = '1':U + chr(44) +
                                  '2':U + chr(44) +
                                  '4':U
                                  .
        v-number = entry(1, p-cli-out-doc, chr(4)).
      end.
    end.
    when integer('7':U) or
    when integer('8':U) then do:
      if buf_ord-doc.status_ = 'отказ':U or buf_ord-doc.status_ = 'закрыто':U or buf_ord-doc.status_ = 'факт':U
      then do:
        v-edist-mess = ''.
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'ps':U
                                             , substitute("Статус заказа TH &1 в БД &2, принять поставку от поставщика не можем ", buf_ord-doc.doc-code, buf_ord-doc.status_ )).
        run create-edi-statett in this-procedure (
                                                input 'ord-doc':U
                                              , input buf_ord-doc.doc-code
                                              , input buf_ord-doc.cli-type
                                              , input buf_ord-doc.cli-code
                                              , input 'ИЗМЕНЕНИЕ':U
                                              , input -1
                                              , input integer('4':U)
                                              , input v-edist-mess
                                              , input ''
                                              , input integer('2':U)
                                              ).
        p-new-st = ?.
        return cr-edist_get-mess-mean( input v-edist-mess).
      end.
      v-number = p-trn-code.
      find first buf_clients no-lock where
                buf_clients.obj-type = buf_ord-doc.cli-type
            and buf_clients.obj-code = buf_ord-doc.cli-code.
      run gen-key-rec in this-procedure ( input 'clients':U
                                          ,input (buffer buf_clients:handle)
                                          ,output v-uniq-key-rec
                                          ).
      find first buf_ext-classif no-lock where
                  buf_ext-classif.classif-subject = 'clients':U
              and buf_ext-classif.classif-name = 'exite-edi':U
              and buf_ext-classif.uniq-key-rec = v-uniq-key-rec no-error.
      if not available buf_ext-classif then do:
         v-permitted-status-list = ''.
      end.
      if buf_ext-classif.charkey_one = 'without-ordrsp':U then do:
        assign
        v-permitted-status-list = '1':U + chr(44) +
                                  '2':U + chr(44) +
                                  '8':U + chr(44) +
                                  '9':U + chr(44) +
                                  '7':U + chr(44) +
                                  '11':U
        .
      end.
      else do:
        assign
        v-permitted-status-list = '5':U  + chr(44) +
                                  '6':U  + chr(44) +
                                  '8':U + chr(44) +
                                  '7':U + chr(44) +
                                  '9':U + chr(44) +
                                  '11':U
        .
      end.
    end.
    when integer('11':U) then do:
      v-number = p-trn-code.
      assign
      v-permitted-status-list = '9':U + chr(44) +
                                '8':U  + chr(44) +
                                '11':U  .
    end.
    when integer('99':U) then do:
      assign
      v-permitted-status-list = '1':U + chr(44) +
                                '2':U + chr(44) +
                                '4':U + chr(44) +
                                '12':U
     .                           .
    end.
    when integer('13':U) then do:
      assign
      v-permitted-status-list = '1':U + chr(44) +
                                '2':U + chr(44) +
                                '4':U + chr(44) +
                                '12':U
     .                           .
    end.
  end case.
  if lookup(string(buf_ord-doc.ord-int1), v-permitted-status-list) = 0 then do:
    for each buf_pos where
              buf_pos.number = v-number
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      delete buf_pos.
    end.
        if v-without then do:
      return error substitute("Не предусмотрен прием документа ORDRSP для поставщика &1&2"
                              , buf_ord-doc.cli-type
                              , buf_ord-doc.cli-code
                              ).
    end.
    else do:
      return error substitute("Статус заказа &1 в БД = &2, принять данные о статусе &3 от поставщика еще/уже не можем"
                              ,buf_ord-doc.doc-code
                              ,entry (lookup (string(buf_ord-doc.ord-int1), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка')
                                                            ,entry (lookup (string(p-status), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка')
                              ).
    end.
  end.
  case p-status :
    when integer('2':U) or
    when integer('12':U) or
    when integer('99':U) or
    when integer('6':U) or
    when integer('11':U) or
    when integer('13':U)
    then do:
      p-new-st = p-status.
      run proc-ord in this-procedure ( input string(p-status)
                                      ,input buf_ord-doc.doc-code
                                      ,input p-cli-out-doc
                                      ,input p-ps
                                      ) no-error .
     if error-status:error then p-new-st = ?.
      for each buf_pos where
               buf_pos.number = entry(1, p-cli-out-doc, chr(4))
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        delete buf_pos.
      end.
      if p-new-st = ? then undo main-block, return error return-value .
    end.
    when integer('3':U)
    then do:
      define variable v-new-status as integer   no-undo .
      run proc-edi-reply-process-contour in this-procedure (
                                          buffer buf_ord-doc
                                         ,input p-status
                                         ,input buf_ord-doc.doc-code
                                         ,input p-cli-out-doc
                                         ,input p-ship-date
                                         ,input p-ediinterchangeid
                                         ,output p-new-st
                                         ) no-error  .
      if error-status:error then do:
         undo, return error return-value .
      end.
      for each buf_pos where
               buf_pos.number = entry(1, p-cli-out-doc, chr(4))
     on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
     on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
     on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
     :
        delete buf_pos.
      end.
    end.
    when integer('7':U) or
    when integer('8':U)
    then do:
      p-new-st = p-status.
      for each buf_pos where
               buf_pos.number = entry(1, p-cli-out-doc, chr(4))
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        delete buf_pos.
      end.
      for each temp-rcv-line-new:
        delete temp-rcv-line-new.
      end.
    end.
    otherwise do:
            return error substitute("От поставщика получен статус &1, что непредусмотрено протоколом"
                             ,entry (lookup (string(p-status), '0,1,2,3,4,5,6,7,8,9,11,99,12,13') , ',отправлен,принят,подтвержден,подтвержден-,подтвержден+,подтвержденОк,поставка пришла,поставка принята,ПН отправлена,ПН получена,Отказ,Доставлен,Ошибка')
                             ).
    end.
  end case.
end.
end procedure.
define variable p-status-ord as character no-undo .
procedure proc-ord :
define input  parameter p-stts     as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-cli-out-doc as character no-undo .
define input  parameter p-ps as character no-undo .
define variable v-edist-mess as character no-undo .
define buffer buf_ord-doc for ub.ord-doc  .
  do
  on error undo, return error return-value
  :
  find first buf_ord-doc exclusive-lock where
             buf_ord-doc.doc-code = p-doc-code no-error .
    if available buf_ord-doc  then do:
    if buf_ord-doc.whole-send-news = integer('2':U) then do:
      assign
      buf_ord-doc.ord-int1 = integer(p-stts)
      buf_ord-doc.cli-out-doc = p-cli-out-doc
      .
      if p-stts = '6':U then do:
        run cus/ord-clos.p
          ( input  parParentProc
          , input  recid(buf_ord-doc)
          , input  buf_ord-doc.obj-type
          , input  buf_ord-doc.obj-code
          , input  g#db-num
          , input  false
          , input  "yes"
          ) no-error .
        if error-status:error then do:
          v-edist-mess = ''.
          v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'ps':U
                                               , substitute("Ошибка при переводе заказа в статус ПОСТАВКА&1&2&1&3"
                                               , chr(10)
                                               , error-status:get-message(1)
                                               , return-value )).
          run create-edi-statett in this-procedure (
                                                input 'ord-doc':U
                                              , input buf_ord-doc.doc-code
                                              , input buf_ord-doc.cli-type
                                              , input buf_ord-doc.cli-code
                                              , input 'ИЗМЕНЕНИЕ':U
                                              , input -1
                                              , input integer('4':U)
                                              , input v-edist-mess
                                              , input ''
                                              , input integer('2':U)
                                              ).
          undo, return error cr-edist_get-mess-mean( input  v-edist-mess).
        end.
      end.
      if p-stts = '99':U then do:
        buf_ord-doc.status_ = 'отказ':U .
        buf_ord-doc.ps = p-ps.
        buf_ord-doc.cli-out-doc = p-cli-out-doc.
      end.
    end.
    else do:
       assign
         buf_ord-doc.ord-int1 = lookup ( p-stts , 'stk,stk-ok,rpl,rpl-ok,acc,acc-ok,pst,pst-ok,trn,err' )
       .
       if p-stts = 'err':U then do:
          buf_ord-doc.status_ = 'отказ':U .
          buf_ord-doc.ps = p-ps.
       end.
    end.
  end.
end.
end procedure.
procedure proc-trn :
define input  parameter p-stts     as character no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-trn-code as character no-undo .
define buffer buf_ord-doc     for ub.ord-doc  .
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-chain   for ub.ord-chain  .
define buffer buf_trn-doc     for ub.trn-doc  .
main-block:
  do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
  find first buf_ord-doc-rcv no-lock  where
             buf_ord-doc-rcv.doc-code = p-doc-code and
             entry(1, buf_ord-doc-rcv.sub-par,chr(4)) = p-trn-code
    no-error .
    if available buf_ord-doc-rcv  then do:
       for each buf_ord-chain  no-lock where
                buf_ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                buf_ord-chain.doc-type = 'rcv' and
            buf_ord-chain.rel-doc-type = 'trn'
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
            find first buf_trn-doc no-lock where
                       buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code no-error .
            if available buf_trn-doc then do:
            end.
       end.
  end.
end.
end procedure.
procedure proc-edi-reply-process-contour :
define parameter buffer buf_ord-doc for ub.ord-doc.
define input  parameter p-status_ as integer no-undo .
define input  parameter p-doc-code as character no-undo .
define input  parameter p-cli-out-doc as character no-undo .
define input  parameter p-ship-date as date no-undo .
define input  parameter p-ediinterchangeid as character no-undo .
define output parameter p-new-status as integer   no-undo .
define variable v-found as logical no-undo .
define variable v-found-prc as logical no-undo .
define variable v-edist-mess as character no-undo .
define variable v-edist-mess2 as character no-undo .
define variable v-b-str as character no-undo .
define variable v-type as character no-undo .
define variable v-prc-min as decimal no-undo .
define variable v-position as integer no-undo .
define variable v-OK as logical no-undo init yes .
define buffer buf_ord-line for ub.ord-line  .
define buffer buf_contract-specif for ub.contract-specif .
define buffer buf_lineItem for lineItem.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  p-new-status = p-status_.
  v-edist-mess = ''.
  if p-ship-date <> buf_ord-doc.ship-date then do:
    v-OK = no .
    v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'shipdate-change':U
                                         , string(buf_ord-doc.ship-date, "99/99/9999")
                                          + chr(4)
                                          + string(p-ship-date) ).
  end.
  assign buf_ord-doc.cli-out-doc = p-cli-out-doc .
  run create-edi-statett in this-procedure (
                                          input 'ord-doc':U
                                        , input buf_ord-doc.doc-code
                                        , input buf_ord-doc.cli-type
                                        , input buf_ord-doc.cli-code
                                        , input 'ИЗМЕНЕНИЕ':U
                                        , input p-new-status
                                        , input integer('0':U)
                                        , input v-edist-mess
                                        , input ''
                                        , input integer('2':U)
                                        ).
  v-position = 0 .
  for each buf_ord-line exclusive-lock where
           buf_ord-line.doc-code   = buf_ord-doc.doc-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    assign
    buf_ord-line.initial-cli-qnty = (if buf_ord-line.initial-cli-qnty = 0
                                    and (buf_ord-doc.ord-int1 = integer('1':U)
                                         or
                                         buf_ord-doc.ord-int1 = integer('2':U)
                                         or
                                         buf_ord-doc.ord-int1 = integer('12':U)
                                         )
                                    then buf_ord-line.cli-qnty
                                    else buf_ord-line.initial-cli-qnty)
    buf_ord-line.order-cli-qnty   = (if buf_ord-line.order-cli-qnty = 0 then buf_ord-line.cli-qnty else buf_ord-line.order-cli-qnty)
    buf_ord-line.ord-dec1         = (if buf_ord-line.ord-dec1 = 0 then buf_ord-line.price-cli else buf_ord-line.ord-dec1)
    .
    v-position = v-position + 1 .
    v-b-str = ''.
    v-edist-mess = ''.
    RUN ordlineattr-value  IN THIS-PROCEDURE ( input  buf_ord-line.doc-code
                                              ,input  buf_ord-line.gds-code
                                              ,input  'ord-EAN13':U
                                              ,output v-b-str
                                              ,output v-type
                                              ) NO-ERROR.
    find first buf_lineItem where
              buf_lineItem.number = entry(1, p-cli-out-doc, chr(4))
          and buf_lineItem.internalBuyerCode = string(buf_ord-line.gds-code)
           no-error .
    if available buf_lineItem then do:
      find first buf_contract-specif where buf_contract-specif.host-code    = buf_ord-doc.host-code
                                       and buf_contract-specif.contract-num = buf_ord-doc.contract-code
                                       and buf_contract-specif.gds-code     = buf_ord-line.gds-code
                                       no-lock no-error .
      if available buf_contract-specif then do :
         run read-prc-min in this-procedure (
             buf_contract-specif.contract-num  ,
             buf_contract-specif.host-code     ,
             buf_contract-specif.gds-code      ,
             output v-prc-min ).
         if buf_lineItem.netPriceWithVAT > buf_contract-specif.price-cli * (1 + (buf_contract-specif.prc / 100))
         or buf_lineItem.netPriceWithVAT < buf_contract-specif.price-cli * (1 - (v-prc-min / 100))
         then do :
               v-OK = no.
               v-found-prc = yes.
               p-new-status  = ? .
               v-edist-mess = ''.
               v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'ps':U,
                                                  substitute("Арт.Поставщика &1, АртикулТН &2, &3, Количество &4, Цена &5 ;"
                                                            ,buf_lineItem.internalSupplierCode
                                                            ,buf_lineItem.internalBuyerCode
                                                            ,buf_lineItem.description
                                                            ,buf_lineItem.confirmedQuantity
                                                            ,buf_lineItem.netPriceWithVAT)).
         end.
      end.
      if buf_ord-line.ord-dec1 < buf_lineItem.netPriceWithVAT then do:
         v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'price-down':U, string(buf_lineItem.netPriceWithVAT) + chr(4) + string(buf_ord-line.ord-dec1) ).
      end.
      if buf_ord-line.ord-dec1 > buf_lineItem.netPriceWithVAT then do:
         v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'price-up':U, string(buf_lineItem.netPriceWithVAT) + chr(4) + string(buf_ord-line.ord-dec1) ).
      end.
      if buf_ord-line.cli-qnty < buf_lineItem.confirmedQuantity then do:
         v-OK = no .
         v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'qnty-down':U, string(buf_lineItem.confirmedQuantity) + chr(4) + string(buf_ord-line.order-cli-qnty) ).
      end.
      if buf_ord-line.cli-qnty > buf_lineItem.confirmedQuantity then do:
         v-OK = no .
         v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'qnty-up':U, string(buf_lineItem.confirmedQuantity) + chr(4) + string(buf_ord-line.order-cli-qnty) ).
      end.
      if buf_ord-line.vat-pc <> buf_lineItem.vATRate then do:
         v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'vat-change':U, string(buf_ord-line.vat-pc) + chr(4) + string(buf_lineItem.vATRate) ).
      end.
      if v-b-str <> buf_lineItem.gtin then do:
         v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'bstr-change':U, string(v-b-str) + chr(4) + string(buf_lineItem.gtin) ).
      end.
            assign
      buf_ord-line.cli-qnty         = (if buf_lineItem.status_ = "rejected"
                                       then 0
                                       else buf_lineItem.confirmedQuantity
                                       )
      buf_ord-line.price-cli        = buf_lineItem.netPriceWithVAT
      buf_ord-line.ord-dec2         = buf_ord-line.cli-qnty
      buf_ord-line.ord-dec3         = buf_ord-line.price-cli
      buf_ord-line.price-rubl       = buf_ord-line.price-cli * buf_ord-doc.exch-rate / buf_ord-doc.exch-scale / buf_ord-line.cli-base-rate
      buf_ord-line.qnty             = buf_ord-line.cli-qnty  * buf_ord-line.cli-base-rate
      buf_ord-line.price-base       = buf_ord-line.price-rubl / buf_ord-doc.base-rate * buf_ord-doc.base-scale
      buf_ord-line.sum-rubl         = buf_ord-line.price-rubl * buf_ord-line.qnty
      buf_ord-line.sum-base         = buf_ord-line.price-base * buf_ord-line.qnty
      buf_ord-line.sum-cli          = buf_ord-line.price-cli  * buf_ord-line.cli-qnty
      buf_ord-line.ord-int1         = ( if buf_lineItem.status_ = "Accepted" then integer('1':U)
                                        else if buf_lineItem.status_ = "Changed" then integer('2':U)
                                        else integer('3':U)
                                      )
      .
      if not v-found then v-found = (buf_ord-line.cli-qnty <> 0).
    end.
    else do:
      v-OK = no .
      v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'ps':U, "Строка удалена Поставщиком").
      assign
      buf_ord-line.cli-qnty         = 0
      buf_ord-line.price-cli        = buf_ord-line.ord-dec1
      buf_ord-line.sub-par          = "Строка удалена Поставщиком"
      buf_ord-line.price-rubl       = buf_ord-line.price-cli * buf_ord-doc.exch-rate / buf_ord-doc.exch-scale / buf_ord-line.cli-base-rate
      buf_ord-line.qnty             = buf_ord-line.cli-qnty  * buf_ord-line.cli-base-rate
      buf_ord-line.price-base       = buf_ord-line.price-rubl / buf_ord-doc.base-rate * buf_ord-doc.base-scale
      buf_ord-line.sum-rubl         = buf_ord-line.price-rubl * buf_ord-line.qnty
      buf_ord-line.sum-base         = buf_ord-line.price-base * buf_ord-line.qnty
      buf_ord-line.sum-cli          = buf_ord-line.price-cli  * buf_ord-line.cli-qnty
      buf_ord-line.ord-int1         = integer('3':U)
      .
    end.
    run create-edi-statett in this-procedure (
                                            input 'ord-line':U
                                          , input (buf_ord-line.doc-code  + chr(4)
                                                  + string(buf_ord-line.gds-code))
                                          , input buf_ord-doc.cli-type
                                          , input buf_ord-doc.cli-code
                                          , input 'ИЗМЕНЕНИЕ':U
                                          , input buf_ord-doc.ord-int1
                                          , input (if buf_ord-line.ord-int1 = integer('1':U)
                                                   then integer('0':U)
                                                   else  (if buf_ord-line.ord-int1 = integer('2':U)
                                                          then integer('1':U)
                                                          else integer('4':U)
                                                         )
                                                   )
                                          , input v-edist-mess
                                          , input ''
                                          , input integer('2':U)
                                          ).
  end.
   if not v-found then do:
     v-OK = no .
     p-new-status = integer('99':U).
   end.
   v-found = no.
   if v-found-prc then do :
      p-new-status = ?.
      run send-stat_contour ( input "ORDRSP"
                               ,input "Fail"
                               ,input "Checking"
                               ,input "Сообщение отклонено на стороне получателя"
                               ,input p-ediinterchangeid) .
      v-edist-mess = ''.
      v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'ps':U,
                                             "По одному или нескольким товарам изменение цены превышает допустимые границы.").
      run create-edi-statett in this-procedure (
                                            input 'ord-doc':U
                                          , input buf_ord-doc.doc-code
                                          , input buf_ord-doc.cli-type
                                          , input buf_ord-doc.cli-code
                                          , input 'ИЗМЕНЕНИЕ':U
                                          , input -1
                                          , input integer('4':U)
                                          , input v-edist-mess
                                          , input ''
                                          , input integer('2':U)
                                          ).
     return cr-edist_get-mess-mean(input v-edist-mess).
   end.
   v-position = 0 .
   for each buf_lineItem  where
           buf_lineItem.number = entry(1, p-cli-out-doc, chr(4))
   on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
   on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
   on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
   :
     v-position = v-position + 1 .
     find first buf_ord-line  no-lock  where
              buf_ord-line.doc-code = p-doc-code
         and  buf_ord-line.gds-code = integer(buf_lineItem.internalBuyerCode)
             no-error .
     if not available buf_ord-line then do:
       v-found = yes.
       p-new-status  = ? .
       v-edist-mess = ''.
       v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'ps':U,
                                          substitute("Арт.Поставщика &1, АртикулТН &2, &3, Количество &4, Цена &5 ;"
                                                    ,buf_lineItem.internalSupplierCode
                                                    ,buf_lineItem.internalBuyerCode
                                                    ,buf_lineItem.description
                                                    ,buf_lineItem.confirmedQuantity
                                                    ,buf_lineItem.netPriceWithVAT)).
       run create-edi-statett in this-procedure (
                                              input 'ord-doc':U
                                            , input (p-doc-code + chr(4) + string( - v-position))
                                            , input buf_ord-doc.cli-type
                                            , input buf_ord-doc.cli-code
                                            , input 'ИЗМЕНЕНИЕ':U
                                            , input buf_ord-doc.ord-int1
                                            , input integer('4':U)
                                            , input v-edist-mess
                                            , input ''
                                            , input integer('2':U)
                                            ).
     end.
   end.
   if v-found then do:
      v-OK = no .
      p-new-status = ?.
      v-edist-mess = ''.
      v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'ps':U,
                                             "Пришли товары, неуказанные в заказе").
      run create-edi-statett in this-procedure (
                                            input 'ord-doc':U
                                          , input buf_ord-doc.doc-code
                                          , input buf_ord-doc.cli-type
                                          , input buf_ord-doc.cli-code
                                          , input 'ИЗМЕНЕНИЕ':U
                                          , input -1
                                          , input integer('4':U)
                                          , input v-edist-mess
                                          , input ''
                                          , input integer('2':U)
                                          ).
      run send-stat_contour ( input "ORDRSP"
                               ,input "Fail"
                               ,input "Checking"
                               ,input "Сообщение отклонено на стороне получателя"
                               ,input p-ediinterchangeid) .
     return cr-edist_get-mess-mean(input v-edist-mess).
   end.
   if v-OK then p-new-status = integer('6':U) .
   if p-new-status <> ? then do:
    assign
    buf_ord-doc.ord-int1  =  p-new-status
    buf_ord-doc.cli-out-doc = p-cli-out-doc
    buf_ord-doc.ship-date = p-ship-date
    .
   end.
   DEFINE VARIABLE v-date as date no-undo .
   DEFINE VARIABLE v-time as integer no-undo .
   v-date = ?.
   v-edist-mess2 = "".
   v-edist-mess2 = cr-edist_add-edist-mess( v-edist-mess2, 'ediiterchangeid':U, p-ediinterchangeid).
   run create-edi-state in this-procedure (
        input 'ord-doc':U
      , input buf_ord-doc.doc-code
      , input buf_ord-doc.cli-type
      , input buf_ord-doc.cli-code
      , input 'ДОБАВЛЕНИЕ':U
      , input (if p-new-status = ? then -1 else buf_ord-doc.ord-int1)
      , input (if p-new-status = ?
              then integer('4':U)
              else integer('0':U) )
      , input ""
      , input v-edist-mess2
      , input integer('2':U)
      , input-output v-date
      , input-output v-time
      ).
   if p-new-status = integer('6':U) then do :
       run proc-ord in this-procedure ( input string(p-new-status)
                                       ,input buf_ord-doc.doc-code
                                       ,input p-cli-out-doc
                                       ,input ""
                                       ) no-error .
       if error-status:error then p-new-status = ?.
       else run send-stat_contour ( input "ORDRSP"
                                    ,input "OK"
                                    ,input "checking"
                                    ,input "Сообщение принято"
                                    ,input p-ediinterchangeid) .
   end.
 end.
end procedure.
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-doc-date as date no-undo .
define variable v-current-doc-type as character no-undo .
define variable v-current-doc-time as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
define variable v-sign as integer no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable num-rec-ok2 as integer no-undo .
define variable v-end-new-line     as logical no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .
define variable v_dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define variable v_qh as handle no-undo .
define variable glog as logical no-undo .
define variable v-esys-id as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-pack-num-chr as character no-undo .
define variable v-ediinterchangeid as character no-undo .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-error :
define input parameter p-mess as character no-undo .
  do
  on error undo, return error
  :
     assign
     v-last-error-message = p-mess.
  end.
end procedure.
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_temp-xml-tables for temp-xml-tables.
DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
DEFINE VARIABLE good AS LOGICAL NO-UNDO.
function 00180004_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
DO v-ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,chr(10)
                        ,ERROR-STATUS:GET-MESSAGE(v-ii)).
END.
end function.
define variable ExpData1 as class Route-data_ no-undo .
ExpData1 = new Route-data_( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle) .
define variable v-DATA as memptr no-undo.
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure send-stat_contour :
  define input parameter p-doc-type as character no-undo .
  define input parameter p-state as character no-undo .
  define input parameter p-stage as character no-undo .
  define input parameter p-description as character no-undo .
  define input parameter p-messID as character no-undo .
  define variable v-ii as integer no-undo .
  define variable v-uniq-key-rec as character no-undo .
  define variable v-cli-uniq-key-rec as character no-undo .
  define variable v-err as logical no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-success as logical   no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-ord-int1 as integer no-undo .
  define variable v-obj-gln as character no-undo .
  define variable v-cli-gln as character no-undo .
  define variable v-gln-net as character no-undo .
  define variable v-type as character no-undo .
  define variable v-mess as character no-undo .
  define variable v-b-code as integer no-undo .
  define variable v-b-str as character no-undo .
  define variable v-jj as integer   no-undo .
  define variable v-cli-base-rate as decimal no-undo .
  define variable v-dump-ord-int64 as int64 no-undo .
  define variable v-rcv-code as character no-undo .
  define variable v-cli-rcv-code as character no-undo .
  define variable v-EDIINTERCHANGEID as character no-undo .
  define variable v-edist-mess as character no-undo .
  define variable v-date-status as character no-undo .
  define variable v-time-status as integer no-undo .
  define variable v-error as character no-undo .
  define variable v-stringdate as character no-undo .
  define variable v-documentNumber as character no-undo .
  define variable v-documentDate as character no-undo .
  define variable sw as handle no-undo .
  define buffer buf_ext-system for ub.ext-system.
  define buffer buf_ord-doc for ub.ord-doc.
  define buffer buf_ord-line for ub.ord-line.
  define buffer buf_object for ub.clients.
  define buffer buf_clients for ub.clients.
  define buffer buf_ext-classif for ub.ext-classif.
  define buffer esys_ext-classif for ub.ext-classif.
  define buffer buf_goods for ub.goods.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
  define buffer buf_currency for ub.currency.
  define buffer buf_ord-line-attr for ub.ord-line-attr.
  define buffer buf_edi-status for ub.edi-status.
_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, chr(10), error-status :get-message (1), v-last-error-message)
on stop undo, return error substitute( "&1&2&3&2&4", return-value, chr(10), error-status :get-message (1), v-last-error-message)
:
  if retry then do:
        .
    undo _main, return error.
  end.
  else do:
    assign
    v-mess = ''
    .
    find first buf_ord-doc exclusive-lock where
              buf_ord-doc.doc-code = v-current-doc-code no-error .
    if not available buf_ord-doc then do:
      v-mess = substitute("Не найден заказ для поставки").
      v-err = yes.
      undo _main, retry _main.
    end.
    if p-doc-type = "DESADV" then do :
        find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.doc-code = v-current-doc-code no-error .
        if available buf_ord-doc-rcv then assign v-rcv-code = buf_ord-doc-rcv.rcv-code .
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_ord-doc.cli-type
          and buf_clients.obj-code = buf_ord-doc.cli-code no-error.
    if not available buf_clients then do:
      v-mess =  substitute("Не найден контрагент &1&2", buf_ord-doc.cli-type, buf_ord-doc.cli-code).
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
                                , buf_ord-doc.cli-type
                                , buf_ord-doc.cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    find first esys_ext-classif no-lock where
        esys_ext-classif.classif-name = 'exite-edi':U
    and esys_ext-classif.classif-subject = 'clients':U
    and esys_ext-classif.db-num = -1
    and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec no-error .
    if not available esys_ext-classif then do:
      v-mess = substitute("Поставщик &1&2 заказа НЕ РАБОТАЕТ ПО СИСТЕМЕ EDI", buf_ord-doc.cli-type, buf_ord-doc.cli-code).
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
    v-cli-gln = get-gln( input buf_ord-doc.cli-type
                        ,input buf_ord-doc.cli-code) no-error.
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
    run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                 ,input buf_ext-system.db-num
                                                 ,input 'gln-net':U
                                                 ,output v-gln-net
                                                 ,output v-type) no-error.
    IF  context_begin-esys-command( input string(buf_ext-system.esys-id), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-stringdate = substring(string(NOW), 7, 4) + substring(string(NOW), 4, 2) + substring(string(NOW), 1, 2)
                 + substring(string(NOW), 12, 2) + substring(string(NOW), 15, 2) + substring(string(NOW), 18, 2).
    v-custom-pack-name = p-state + "_" + v-stringdate + "_" + p-doc-type + "_" + buf_ord-doc.doc-code + "_&pack-num.xml".
    if p-doc-type = "ORDRSP" then do :
        if p-stage = "Read" then
        assign
            v-documentNumber = entry(1, v-cli-out-doc, chr(4))
            v-documentDate = entry(2, v-cli-out-doc, chr(4))
        .
        else
        assign
            v-documentNumber = entry(1, buf_ord-doc.cli-out-doc, chr(4))
            v-documentDate = entry(2, buf_ord-doc.cli-out-doc, chr(4))
        .
        for each buf_edi-status no-lock where
                buf_edi-status.tbl-name = 'ord-doc':U
           and buf_edi-status.doc-code = v-current-doc-code
           and (buf_edi-status.state = '1':U or buf_edi-status.state = '12':U or buf_edi-status.state = '6':U or buf_edi-status.state = '3':U)
           and buf_edi-status.err-code < 3 :
          assign
            v-EDIINTERCHANGEID = cr-edist_get-mess-key-value(buf_edi-status.mess, 'ediiterchangeid':U)
          .
          if v-EDIINTERCHANGEID <> ? and trim(v-EDIINTERCHANGEID) <> "" then leave .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-doc':U
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-line':U
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
    end.
    if p-doc-type = "DESADV" then do :
        assign
            v-documentNumber = v-desadv-DELIVERYNOTENUMBER
            v-documentDate = iso-date(v-desadv-DELIVERYNOTEDATE)
        .
        for each buf_edi-status no-lock where
                buf_edi-status.tbl-name = 'ord-doc-rcv':U
           and buf_edi-status.doc-code = v-rcv-code
           and buf_edi-status.state = '8':U
           and buf_edi-status.err-code < 3 :
          assign
          v-EDIINTERCHANGEID = cr-edist_get-mess-key-value(buf_edi-status.mess, 'ediiterchangeid':U).
          if v-EDIINTERCHANGEID <> ? and trim(v-EDIINTERCHANGEID) <> "" then leave .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-doc':U
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-line':U
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-doc-rcv':U
           and temp-edi-status.doc-code begins v-rcv-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = 'ord-line-rcv':U
           and temp-edi-status.doc-code begins v-rcv-code :
          assign
            v-error = v-error +
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             +
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
    end.
    if v-EDIINTERCHANGEID <> ? and v-EDIINTERCHANGEID <> "" and p-messID = ? then p-messID = v-EDIINTERCHANGEID .
    if p-messID = ? then p-messID = "" .
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("memptr", v-DATA).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("statusReport") .
        sw:write-data-element ("reportDateTime", substring(iso-date(NOW), 1, 23) + "Z") .
        sw:write-data-element ("reportRecipient", v-cli-gln) .
        sw:start-element ("reportItem") .
            sw:write-data-element ("messageId", p-messID) .
            sw:write-data-element ("documentId", p-messID) .
            sw:write-data-element ("messageSender", v-cli-gln) .
            sw:write-data-element ("messageRecepient", v-gln-net) .
            sw:write-data-element ("documentType", p-doc-type) .
            sw:write-data-element ("documentNumber", v-documentNumber) .
            sw:write-data-element ("documentDate", v-documentDate) no-error .
            sw:start-element ("statusItem") .
                sw:write-data-element ("dateTime", substring(iso-date(NOW), 1, 23) + "Z") .
                sw:write-data-element ("stage", p-stage) .
                sw:write-data-element ("state", p-state) .
                sw:write-data-element ("description", p-description) .
                if p-stage = "Checking" and p-state = "Ok" and p-description = "Сообщение отклонено на стороне получателя" then
                do :
                    sw:write-data-element ("error", "Заказ УЖЕ в статусе Подтвержден или ПодтвержденОК") .
                end.
                else if p-stage = "Checking" and p-state = "Fail" and p-doc-type = "DESADV" and p-description = "Сообщение отклонено на стороне получателя в УБД" then
                do :
                    sw:write-data-element ("error", "Поставка уже в работе в УБД") .
                end.
                else if p-state = "Fail" then
                do :
                    v-error = replace(v-error, chr(4), " ") .
                    v-error = replace(v-error, ";", "; ") .
                    if trim(v-error) <> "" then
                    do v-ii = 1 to num-entries(v-error, chr(30) ):
                        if trim(entry(v-ii, v-error, chr(30) )) <> "" then
                        sw:write-data-element ("error", trim(entry(v-ii, v-error, chr(30)))) .
                    end.
                end.
                else do :
                end.
            sw:end-element ("statusItem") .
        sw:end-element ("reportItem") .
    sw:end-element ("statusReport") .
    sw:end-document () .
    delete object sw.
    IF ExpData1:esys-add-dump-data ( INPUT v-DATA, INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-dump-ord-int64 = context_send-esys-command( input string(buf_ext-system.esys-id), input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid).
    if v-dump-ord-int64 = 0 THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-edist-mess = ''.
    v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'route':U, string(v-dump-ord-int64)).
    v-date-status = ?.
    run create-edi-state in this-procedure (
                                            input 'ord-doc-rcv':U
                                          , input v-rcv-code
                                          , input buf_ord-doc.cli-type
                                          , input buf_ord-doc.cli-code
                                          , input 'ИЗМЕНЕНИЕ':U
                                          , input buf_ord-doc.ord-int1
                                          , input integer('0':U)
                                          , input buf_ord-doc.PS
                                          , input v-edist-mess
                                          , input integer('2':U)
                                          , input-output v-date-status
                                          , input-output v-time-status
                                          ).
        ExpData1:Route-data_clear-data ( ) .
  end.
end.
end procedure.
  define variable p-xsd-file as character no-undo.
on delete of this-procedure do:
  run delete-procedure in this-procedure .
end.
run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return.
if not this-procedure:persistent then do:
  run proc-main in this-procedure  no-error .
  if error-status:error then do:
      v-esm = error-status :get-message (1).
      v-es = error-status:error .
      v-rv = return-value .
      run delete-procedure in this-procedure .
            run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute( "&1. &2&3&4", vss-workfile, v-rv, chr(10), v-esm)).                      assign v-view-log = yes.
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.
procedure proc-main :
define variable v-ii as integer   no-undo .
define variable v-mess as character no-undo .
define variable v-trn-code as character no-undo .
define variable v-dump-ord-int64 as int64 no-undo .
define variable v-new-ps as character no-undo .
define variable v-ord-int1 as integer no-undo .
define variable v-ps as character no-undo .
define variable v-new-st as integer no-undo .
define variable v-ship-date as date no-undo .
define variable v-edist-mess as character no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-date-status as date no-undo .
define variable v-time-status as integer no-undo .
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_edi-status for ub.edi-status.
define buffer buf_esys-route for ub.esys-route.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-crc-pack as character no-undo .
define variable v-dm-edi as integer no-undo .
_ordrsp:
do transaction
on error  undo _ordrsp, retry _ordrsp
on stop   undo _ordrsp, retry _ordrsp
on endkey undo _ordrsp, retry _ordrsp
:
  if retry then do:
        run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при импорте подтверждений заказа &1 из ВС &2&3&4"                                 ,v-current-doc-code                                 , v-esys-id                                  , chr(10)                                 , v-mess)).                      assign v-view-log = yes.
    assign
    v-view-log = yes.
    run delete-ord-list in this-procedure ( input v-cli-out-doc
                                            ).
    undo _ordrsp, return error substitute("Ошибка при импорте подтверждений заказа &1 из ВС &2&3&4"                                 ,v-current-doc-code                                 , v-esys-id                                  , chr(10)                                 , v-mess).
  end.
  else do:
    find first ordrsp.
    run write-log  in p-log-handle (
                                    input 0
                                  , "&DLine").
          run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute(".............Импорт подтверждений заказа из ВС")).                      assign v-view-log = yes.
    num-rec = num-rec + 1.
    find first buf_ord-doc exclusive-lock where
              buf_ord-doc.doc-code = ordrsp.ordernumber no-error.
    if not available buf_ord-doc then do:
      v-mess =  substitute("Не найден заказ поставщику с номером &1", ordrsp.ordernumber).
      undo _ordrsp, retry _ordrsp.
    end.
    assign
    v-current-doc-code = buf_ord-doc.doc-code
    v-cli-type = buf_ord-doc.cli-type
    v-cli-code = buf_ord-doc.cli-code
    .
    if buf_ord-doc.ord-int1 = integer('3':U)
    or buf_ord-doc.ord-int1 = integer('6':U)
    then do :
        v-edist-mess = ''.
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'ps':U, "Заказ УЖЕ в статусе Подтвержден или ПодтвержденОК" ).
        v-date-status = ?.
        run create-edi-state in this-procedure (
                                              input 'ord-doc':U
                                            , input buf_ord-doc.doc-code
                                            , input buf_ord-doc.cli-type
                                            , input buf_ord-doc.cli-code
                                            , input 'ИЗМЕНЕНИЕ':U
                                            , input buf_ord-doc.ord-int1
                                            , input integer('0':U)
                                            , input v-edist-mess
                                            , input ""
                                            , input integer('2':U)
                                            , input-output v-date-status
                                            , input-output v-time-status
                                            ).
        run send-stat_contour ( input "ORDRSP"
                               ,input "Ok"
                               ,input "Checking"
                               ,input "Сообщение отклонено на стороне получателя"
                               ,input ordrsp.id) .
                run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при импорте подтверждений заказа &1 из ВС &2&3Заказ УЖЕ в статусе Подтвержден или ПодтвержденОК"                                 ,v-current-doc-code                                 , v-esys-id                                  , chr(10))).                      assign v-view-log = yes.
        assign
        v-view-log = yes.
        run delete-ord-list in this-procedure ( input v-cli-out-doc
                                                ).
        return substitute("Ошибка при импорте подтверждений заказа &1 из ВС &2&3Заказ УЖЕ в статусе Подтвержден или ПодтвержденОК"                                 ,v-current-doc-code                                 , v-esys-id                                  , chr(10)).
    end.
    assign
    glog = status-is-edi ( input yes
                        , input buf_ord-doc.cli-type
                        , input buf_ord-doc.cli-code
                        , input buf_ord-doc.obj-type
                        , input buf_ord-doc.obj-code
                        , output v-dm-edi
                        ) no-error.
    if not glog = yes then do:
      v-mess = substitute("Нет обмена Документами по EDI для поставщика &1&2 и &3&4 в БД &5)"
                          , buf_ord-doc.cli-type
                          , buf_ord-doc.cli-code
                          , buf_ord-doc.obj-type
                          , buf_ord-doc.obj-code
                          , g#db-num).
      undo _ordrsp, retry _ordrsp.
    end.
    assign
    v-ps = ""
    v-ord-int1 = (if ordrsp.status_ = "Accepted"
                          then integer('3':U)
                          else (if ordrsp.status_ = "Rejected"
                                then integer('99':U)
                                else integer('3':U)
                                )
                          )
    v-cli-out-doc = ordrsp.ordrspNumber + chr(4) + ordrsp.ordrspDate
    v-ship-date = (if ordrsp.estimatedDeliveryDateTime = ? or ordrsp.estimatedDeliveryDateTime = ""
                          then ord-list.ship-date
                          else date(substring(ordrsp.estimatedDeliveryDateTime, 9, 2) + "/" + substring(ordrsp.estimatedDeliveryDateTime, 6, 2) + "/" + substring(ordrsp.estimatedDeliveryDateTime, 1, 4))
                          )
    .
    v-ediinterchangeid = ordrsp.id.
    run edocsord_edi-import in this-procedure (
                                            buffer buf_ord-doc
                                          ,input v-cli-out-doc
                                          ,input ''
                                          ,input v-ord-int1
                                          ,input v-ship-date
                                          ,input v-ps
                                          ,input v-pack-num-chr
                                          ,input v-ediinterchangeid
                                          ,output v-new-ps
                                          ,output v-new-st
                                          ) no-error.
    if error-status:error then do:
      if return-value <> '' then do:
        v-mess = substitute("Ошибка при изменении статуса заказа при приеме данных:&1&2", chr(10), return-value ).
        undo _ordrsp, retry _ordrsp.
      end.
    end.
    else do:
      if v-new-st = ? then do:
        define variable v-tmp-file as character no-undo .
        run gbl/_tmpfile.p ( input "mes":U  , input ".txt":U, output v-tmp-file ).
        COPY-LOB  FROM OBJECT cr-edist_full-mess
        TO FILE v-tmp-file NO-ERROR.
        cr-edist_full-mess = ''.
        run send-msg-to-email in parparentproc
            ( input substitute( "ТН БД &1. Ошибка EDI при импорте пакета &2 из ВС &3"
                                , g#db-num
                                , v-pack-num-chr
                                , v-esys-id )
            ,input substitute("Пакет принят без сохранения данных в БД. См. EDI-информацию по заказу &1&2"
                              , buf_ord-doc.doc-code
                              , chr(10)
                              )
            ,input v-tmp-file
            ) no-error .
        os-delete value(v-tmp-file).
      end.
      v-edist-mess = ''.
      v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'pack-num':U, "->" + v-pack-num-chr ).
      v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'ediiterchangeid':U, ordrsp.id ).
      v-date-status = ?.
      run create-edi-state in this-procedure (
                                              input 'ord-doc':U
                                            , input buf_ord-doc.doc-code
                                            , input buf_ord-doc.cli-type
                                            , input buf_ord-doc.cli-code
                                            , input 'ИЗМЕНЕНИЕ':U
                                            , input (if v-new-st = ? then -1 else buf_ord-doc.ord-int1)
                                            , input (if v-new-st = ?
                                                    then  integer('4':U)
                                                    else integer('0':U))
                                            , input buf_ord-doc.PS
                                            , input v-edist-mess
                                            , input integer('2':U)
                                            , input-output v-date-status
                                            , input-output v-time-status
                                            ).
      _edist:
      for each temp-edi-status
      on error  undo _edist, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
      on stop   undo _edist, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _edist, return error substitute( "&1. endkey", vss-workfile )
      :
        v-edist-mess = temp-edi-status.mess.
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, 'pack-num':U, "->" + v-pack-num-chr ).
        run create-edi-state in this-procedure (
                                                input temp-edi-status.tbl-name
                                              , input temp-edi-status.doc-code
                                              , input temp-edi-status.cli-type
                                              , input temp-edi-status.cli-code
                                              , input temp-edi-status.act
                                              , input (if v-new-st = ? then -1 else buf_ord-doc.ord-int1)
                                              , input temp-edi-status.err-code
                                              , input temp-edi-status.des-err
                                              , input v-edist-mess
                                              , input integer('2':U)
                                              , input-output v-date-status
                                              , input-output v-time-status
                                              ).
      end.
      if v-new-st <> ? then do:
        run cur-time in this-procedure ( output v-today, output v-time).
        run get-xcnf_create-temp-esys-pck-sent in p-cont-handle (
                                                                  input v-esys-id
                                                                ,input integer(v-pack-num-chr)
                                                                ,input v-crc-pack
                                                                ,input yes
                                                                ,input 1
                                                                ,input 1
                                                                ,input v-today
                                                                ,input v-time
                                                                ,input string(v-time, "HH:MM:SS")
                                                                ) .
        num-rec-ok = num-rec-ok + 1.
      end.
    end.
  end.
  run write-counter in p-log-handle ( input substitute("Прочитано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
end.
run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Прочитано записей: &1, из них удачно обработано: &2", num-rec, num-rec-ok)).                      assign v-view-log = yes.
end procedure.
PROCEDURE GetChildren:
DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
DEFINE VARIABLE hText AS HANDLE NO-UNDO.
define variable client as character no-undo.
CREATE X-NODEREF hNoderef.
CREATE X-NODEREF hText .
if hParent:name = "eDIMessage" then
assign
    ordrsp.id = hParent:get-attribute("id")
    ordrsp.creationDateTime = hParent:get-attribute("creationDateTime")
.
REPEAT i = 1 TO hParent:NUM-CHILDREN:
    good = hParent:GET-CHILD(hNoderef,i).
    IF NOT good THEN
        LEAVE.
    IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
    hNoderef:GET-CHILD(hText, 1) no-error.
    IF hNoderef:NAME = "sender" THEN
        assign ordrsp.sender = hText:node-value .
    IF hNoderef:NAME = "recipient" THEN
        assign ordrsp.recipient = hText:node-value .
    IF hNoderef:NAME = "orderResponse" THEN
        assign
            ordrsp.ordrspNumber = hNoderef:get-attribute("number")
            ordrsp.ordrspDate = hNoderef:get-attribute("date")
            ordrsp.status_ = hNoderef:get-attribute("status")
        .
    IF hNoderef:NAME = "originOrder" THEN
        assign
            ordrsp.orderNumber = hNoderef:get-attribute("number")
            ordrsp.orderDate = hNoderef:get-attribute("date")
        .
    IF hNoderef:NAME = "documentType" THEN
        assign ordrsp.documentType = hText:node-value .
    IF hNoderef:NAME = "seller" THEN
        assign client = "seller".
    IF hNoderef:NAME = "buyer" THEN
        assign client = "buyer".
    IF hNoderef:NAME = "shipFrom" THEN
        assign client = "shipFrom".
    IF hNoderef:NAME = "shipTo" THEN
        assign client = "shipTo".
    IF hNoderef:NAME = "gln" THEN do :
        case client :
            when "seller" then assign ordrsp.seller_gln = hText:node-value .
            when "buyer" then assign ordrsp.buyer_gln = hText:node-value .
            when "shipFrom" then assign ordrsp.shipFrom_gln = hText:node-value .
            when "shipTo" then assign ordrsp.shipTo_gln = hText:node-value .
        end case.
    end.
    IF hNoderef:NAME = "estimatedDeliveryDateTime" THEN
        assign ordrsp.estimatedDeliveryDateTime = hText:node-value .
    IF hNoderef:NAME = "currencyISOCode" THEN
        assign ordrsp.currencyISOCode = hText:node-value .
    IF hNoderef:NAME = "lineItem" THEN do :
        create lineItem .
        assign
            lineItem.status_ = hNoderef:get-attribute("status")
            lineItem.NUMBER  = ordrsp.ordrspNumber
        .
    end.
    IF hNoderef:NAME = "gtin" THEN
        assign lineItem.gtin = hText:node-value .
    IF hNoderef:NAME = "description" THEN
        assign lineItem.description = hText:node-value .
    IF hNoderef:NAME = "internalBuyerCode" THEN
        assign lineItem.internalBuyerCode = hText:node-value .
    IF hNoderef:NAME = "internalSupplierCode" THEN
        assign lineItem.internalSupplierCode = hText:node-value .
    IF hNoderef:NAME = "orderedQuantity" THEN
        assign lineItem.orderedQuantity = decimal(hText:node-value) .
    IF hNoderef:NAME = "confirmedQuantity" THEN
        assign
            lineItem.confirmedQuantity = decimal(hText:node-value)
            lineItem.unitOfMeasure = hNoderef:get-attribute("unitOfMeasure")
        .
    IF hNoderef:NAME = "netPrice" THEN
        assign lineItem.netPrice = decimal(hText:node-value) .
    IF hNoderef:NAME = "netAmount" THEN
        assign lineItem.netAmount = decimal(hText:node-value) .
    IF hNoderef:NAME = "vATAmount" THEN
        assign lineItem.vATAmount = decimal(hText:node-value) .
    IF hNoderef:NAME = "netPriceWithVAT" THEN
        assign lineItem.netPriceWithVAT = decimal(hText:node-value) .
    IF hNoderef:NAME = "amount" THEN
        assign lineItem.amount = decimal(hText:node-value) .
    IF hNoderef:NAME = "vATRate" THEN
        assign lineItem.vATRate = decimal(hText:node-value) .
    RUN GetChildren(hNoderef, (level + 1)).
END.
DELETE OBJECT hNoderef.
DELETE OBJECT hText.
END PROCEDURE.
procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable glog as logical no-undo .
define variable v-mess as character no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_ext-system for ub.ext-system.
  do
  on error undo, return error
  :
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
    case p-ruleset-id:
      when 4 then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-doc-code = p-doc-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = entry(1, p-process-file-name, chr(4))
        v_dataseth = handle(entry(2, p-process-file-name, chr(4)))
        v-xmlh = buffer buf_temp-xml-tables:handle
        v-esys-id = integer(p-doc-code)
        v-pack-num-chr = entry(3, p-process-file-name, chr(4))
        no-error
       .
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = v-esys-id
              and buf_ext-system.db-num = 0 no-error .
        if not available buf_ext-system
        or buf_ext-system.esys-type <> integer('9':U)
        then do:
                    run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Не найдена ВС &1&2пропускаем ..."                                         , v-esys-id                                         , chr(10)                                         )).                      assign v-view-log = yes.
          undo, return error substitute("Не найдена ВС &1&2пропускаем ..."                                         , v-esys-id                                         , chr(10)                                         ).
        end.
        empty temp-table ordrsp .
        empty temp-table lineItem .
        CREATE X-DOCUMENT hDoc.
        CREATE X-NODEREF hRoot.
        hDoc:LOAD("file",file-name,FALSE).
        hDoc:GET-DOCUMENT-ELEMENT(hRoot).
        create ordrsp .
        RUN GetChildren(hRoot, 1).
        DELETE OBJECT hDoc.
        DELETE OBJECT hRoot.
        find first ub.ord-doc no-lock where ub.ord-doc.doc-code = ordrsp.orderNumber no-error.
        if not available ub.ord-doc then do:
          v-mess =  substitute("Не найден заказ поставщику с номером &1", ordrsp.ordernumber).
          run write-log-and-file in p-log-handle (                 input 1                                          , input log-file-name                              , input 1                                          , input substitute("Ошибка при импорте поставок по  заказу &1 из ВС &2&3&4"                                 ,ordrsp.ordernumber                                 , v-esys-id                                  , chr(10)                                 , v-mess)).                      assign v-view-log = yes.
        end.
        if available ub.ord-doc then
        assign
        v-current-doc-code = ub.ord-doc.doc-code
        v-current-obj-type = ub.ord-doc.obj-type
        v-current-obj-code = ub.ord-doc.obj-code
        v-cli-out-doc = ordrsp.ordrspNumber + chr(4) + ordrsp.ordrspDate
        .
        run send-stat_contour ( input "ORDRSP"
                               ,input "Ok"
                               ,input "Read"
                               ,input "сообщение доставлено"
                               ,input ordrsp.id) .
      end.
      otherwise do:
        undo, return error "Неправильный вызов".
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
procedure delete-ord-list :
define input parameter p-cli-out-doc as character no-undo .
define buffer buf_ord-list for ord-list.
for each lineItem where
        lineItem.number = p-cli-out-doc:
  delete lineItem.
end.
find first buf_ord-list where
          buf_ord-list.doc-code = p-doc-code
      and buf_ord-list.trn-doc = ''
         no-error .
if available buf_ord-list then delete buf_ord-list.
end procedure.
