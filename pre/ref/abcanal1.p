block-level on error undo, throw.
DEFINE TEMP-TABLE x-abc-analysis      no-undo  LIKE ub.abc-analysis.
DEFINE TEMP-TABLE x-abc-analysis-doc  no-undo  LIKE ub.abc-analysis-doc.
DEFINE TEMP-TABLE x-abc-analysis-obj  no-undo LIKE  ub.abc-analysis-obj.
DEFINE TEMP-TABLE x-abc-analysis-period  no-undo LIKE ub.abc-analysis-period.
define input-output parameter p-doc-rec  as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter table for  x-abc-analysis.
define input parameter table for  x-abc-analysis-doc.
define input parameter table for  x-abc-analysis-obj.
define input parameter table for  x-abc-analysis-period.
define variable  v-list-obj          like ub.abc-analysis.abc-hash-string-obj          no-undo .
define variable  v-list-period       like ub.abc-analysis.abc-hash-string-period       no-undo .
define variable  v-list-doc          like ub.abc-analysis.abc-hash-string-doc          no-undo .
define variable  v-abc-hash-string-obj          like ub.abc-analysis.abc-hash-string-obj          no-undo .
define variable  v-abc-hash-string-period       like ub.abc-analysis.abc-hash-string-period       no-undo .
define variable  v-abc-hash-string-doc          like ub.abc-analysis.abc-hash-string-doc          no-undo .
define variable  v-abc-possb-keep-string-obj    like ub.abc-analysis.abc-possb-keep-string-obj    no-undo .
define variable  v-abc-possb-keep-string-period like ub.abc-analysis.abc-possb-keep-string-period no-undo .
define variable  v-abc-possb-keep-string-doc    like ub.abc-analysis.abc-possb-keep-string-doc    no-undo .
define variable  v-abc-string-obj               like ub.abc-analysis.abc-string-obj               no-undo .
define variable  v-abc-string-period            like ub.abc-analysis.abc-string-period            no-undo .
define variable  v-abc-string-doc               like ub.abc-analysis.abc-string-doc               no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: abcanal1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/abcanal1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке Заголовка АМ".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-index_name-value no-undo
field name-key  as character
field value-key as character
index pi name-key
.
define temp-table temp-sub-index_name no-undo
field name-key  as character
field nn as integer
index pi nn
.
procedure def-hash :
  do
  on error undo, return error return-value
  :
  define input  parameter p-full-string as character no-undo .
  define output parameter p-possb-keep-string as logical   no-undo .
  define output parameter p-string            as character no-undo .
  define output parameter p-hash-string       as character no-undo .
    p-full-string = trim( p-full-string ) .
    if length (p-full-string ) > 150 then do:
    assign
      p-possb-keep-string =  false
      p-string            =  substring(p-full-string,1,150)
      p-hash-string       =  encode(p-full-string)
    .
    end.
    else do:
    assign
      p-possb-keep-string =  true
      p-string            =  p-full-string
      p-hash-string       =  encode(p-full-string)
    .
    end.
  end.
end procedure.
procedure find-from-hash :
  do
  on error undo, return error return-value
  :
define input  parameter  p-full-string            as character no-undo .
define input  parameter  p-table-name             as character no-undo .
define input  parameter  p-field-possb-keep-name  as character no-undo .
define input  parameter  p-field-string-name      as character no-undo .
define input  parameter  p-field-hash-string-name as character no-undo .
define input  parameter  p-sub-table-name         as character no-undo .
define output parameter  p-recid                  as recid     no-undo .
define variable v-possb-keep-string as logical   no-undo .
define variable v-string            as character no-undo .
define variable v-hash-string       as character no-undo .
define variable v-query-prepare     as character no-undo .
define variable i  as integer no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable p-rez as logical   no-undo .
run def-hash in this-procedure (input  p-full-string ,
              output v-possb-keep-string ,
              output v-string            ,
              output v-hash-string
              ).
p-recid = ? .
create buffer bh for table p-table-name.
create query qh.
   v-query-prepare =
    "for each " + p-table-name + " no-lock where "
    + p-field-possb-keep-name   + " = "  + string(v-possb-keep-string) + " and "
    + p-field-string-name       + " = '" + v-string            + "' and "
    + p-field-hash-string-name  + " = '" + v-hash-string       + "'"
    .
if v-possb-keep-string = true then do:
    qh:set-buffers(bh).
    qh:query-prepare(v-query-prepare).
    qh:query-open.
    qh:get-first.
    p-recid = bh:recid.
end.
else do:
message false "анализ hash" .
  qh:set-buffers(bh).
  qh:query-prepare(v-query-prepare).
  qh:query-open.
  qh:get-first.
  p-recid = bh:recid.
  repeat :
    qh:get-next.
    if bh:available then do:
       qh:get-first.
       run ver-sub-table in this-procedure (
           input  p-full-string ,
           input  p-table-name ,
           input  p-sub-table-name ,
           input  bh:recid  ,
           output p-rez
           ).
       if p-rez = true  then do:
          p-recid = bh:recid .
          leave.
       end.
       else do:
         next.
       end.
    end.
    leave.
  end.
end.
delete widget bh.
delete widget qh.
  end.
end procedure.
procedure ver-sub-table :
  do
  on error undo, return error return-value
  :
define input  parameter p-full-string as character no-undo .
define input  parameter p-name-table as character no-undo .
define input  parameter p-sub-name-table as character no-undo .
define input  parameter p-recid as recid no-undo .
define output parameter p-ok as logical   no-undo .
define variable v-query-prepare     as character no-undo .
define variable i  as integer no-undo .
define variable qh as widget-handle no-undo .
define variable bh as widget-handle no-undo .
define variable p-rez as logical   no-undo .
for each temp-index_name-value : delete temp-index_name-value . end.
for each temp-sub-index_name : delete temp-sub-index_name . end.
    create buffer bh for table p-name-table.
    create query qh.
    v-query-prepare = "for each " + p-name-table + " no-lock where recid(" + p-name-table + ") = " + string ( p-recid ) .
    qh:set-buffers(bh).
    qh:query-prepare(v-query-prepare).
    qh:query-open.
    qh:get-first.
    p-recid = bh:recid.
define variable v-inf-ind AS CHAR NO-UNDO.
define variable v-name-pi as character no-undo .
define variable v-num-fl-inkey as integer   no-undo .
define variable v-num-fl       as integer   no-undo .
define variable j as integer   no-undo .
v-name-pi = bh:PRIMARY .
v-inf-ind = "1".
i = 0.
DO while ( v-inf-ind <> ? )
    on error undo, return error:
    i = i + 1 .
    v-inf-ind = bh:INDEX-INFORMATION(i) .
    if v-inf-ind = ? then leave.
    if entry( 1 , v-inf-ind ) = v-name-pi then do:
       v-num-fl-inkey = ( num-entries(v-inf-ind) - 4 ) / 2 .
       v-num-fl       = ( num-entries(v-inf-ind) - 4 )     .
      if v-num-fl-inkey >= 1 then do:
          do j = 5 to v-num-fl  by 2 :
              create temp-index_name-value .
              assign
                temp-index_name-value.name-key  = entry( j , v-inf-ind )
                temp-index_name-value.value-key = bh:BUFFER-FIELD(entry( j , v-inf-ind )):BUFFER-VALUE
              .
          end.
       end.
    end.
END.
define variable qh-sub as widget-handle no-undo .
define variable bh-sub as widget-handle no-undo .
    create buffer bh-sub for table p-sub-name-table.
    create query qh-sub.
define variable k as integer   no-undo init 0 .
    v-query-prepare = "for each " + p-sub-name-table + " no-lock where " .
    for each temp-index_name-value :
        v-query-prepare = v-query-prepare  + p-sub-name-table + "." + temp-index_name-value.name-key +
                      " = " + temp-index_name-value.value-key + " and " .
    end.
    v-query-prepare = v-query-prepare + " true = true " .
    qh-sub:set-buffers(bh-sub).
    qh-sub:query-prepare(v-query-prepare).
    qh-sub:query-open.
      v-name-pi = bh-sub:PRIMARY .
      v-inf-ind = "1".
      i = 0.
      DO while ( v-inf-ind <> ? )
          on error undo, return error:
          i = i + 1 .
          v-inf-ind = bh-sub:INDEX-INFORMATION(i) .
          if v-inf-ind = ? then leave.
          if entry( 1 , v-inf-ind ) = v-name-pi then do:
            v-num-fl-inkey = ( num-entries(v-inf-ind) - 4 ) / 2 .
            v-num-fl       = ( num-entries(v-inf-ind) - 4 )     .
            if v-num-fl-inkey >= 1 then do:
                do j = 5 to v-num-fl  by 2 :
                    if not can-find (first temp-index_name-value  where temp-index_name-value.name-key =  entry( j , v-inf-ind )) then do:
                        create temp-sub-index_name .
                        assign
                          temp-sub-index_name.name-key  = entry( j , v-inf-ind )
                          temp-sub-index_name.nn  = j
                        .
                    end.
                end.
            end.
          end.
      END.
      define variable v-qw as character no-undo .
      v-qw = "".
      qh-sub:GET-first.
      DO WHILE (bh-sub:AVAILABLE):
        for each temp-sub-index_name :
            v-qw = v-qw + string(bh-sub:BUFFER-FIELD(temp-sub-index_name.name-key):BUFFER-VALUE) .
        end.
        v-qw = v-qw + ",".
        qh-sub:GET-NEXT.
      END.
      p-ok = false .
      if trim(p-full-string, ",")  =  trim (v-qw, ",") then p-ok = true  .
    delete widget bh-sub.
    delete widget qh-sub.
    delete widget bh.
    delete widget qh.
  end.
end procedure.
PROCEDURE update-rang-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-a as decimal   no-undo .
define input  parameter p-b as decimal   no-undo .
define input  parameter p-c as decimal   no-undo .
define input  parameter p-d as decimal   no-undo .
define input  parameter p-e as decimal   no-undo .
define input  parameter p-f as decimal   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define buffer buf_rang-abc-def     for ub.rang-abc-def.
define buffer buf_rang-abc-def-obj for ub.rang-abc-def-obj.
find first buf_rang-abc-def exclusive-lock where recid(buf_rang-abc-def) = p-recid no-error .
if not available buf_rang-abc-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_rang-abc-def.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
end.
else do:
  assign
      v-exist = true
      p-id = buf_rang-abc-def.raad-id
      p-db = buf_rang-abc-def.db-num
      p-hash-string-obj       = buf_rang-abc-def.raad-hash-string-obj
      p-possb-keep-string-obj = buf_rang-abc-def.raad-possb-keep-string-obj
      p-string-obj            = buf_rang-abc-def.raad-string-obj
  .
end.
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_rang-abc-def.raad-hash-string-obj       = p-hash-string-obj
          buf_rang-abc-def.raad-possb-keep-string-obj = p-possb-keep-string-obj
          buf_rang-abc-def.raad-string-obj            = p-string-obj
          buf_rang-abc-def.raad-a                     = p-a
          buf_rang-abc-def.raad-b                     = p-b
          buf_rang-abc-def.raad-c                     = p-c
          buf_rang-abc-def.raad-d                     = p-d
          buf_rang-abc-def.raad-e                     = p-e
          buf_rang-abc-def.raad-f                     = p-f
          buf_rang-abc-def.raad-id                    = p-id
          buf_rang-abc-def.raad-date                  = v-date
          buf_rang-abc-def.raad-db-num                = g#db-num
          buf_rang-abc-def.db-num                     = p-db
          buf_rang-abc-def.raad-time                  = v-time
          buf_rang-abc-def.raad-who                   = g#userid
      .
if v-exist = true then do:
   for each buf_rang-abc-def-obj exclusive-lock where
            buf_rang-abc-def-obj.raad-id = buf_rang-abc-def.raad-id and
            buf_rang-abc-def-obj.db-num  = buf_rang-abc-def.db-num :
            delete buf_rang-abc-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, "," ).
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_rang-abc-def-obj.
  assign
    buf_rang-abc-def-obj.raad-id  = buf_rang-abc-def.raad-id
    buf_rang-abc-def-obj.db-num   = buf_rang-abc-def.db-num
    buf_rang-abc-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_rang-abc-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
RELEASE buf_rang-abc-def .
END PROCEDURE.
PROCEDURE update-rang-xyz-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-x as decimal   no-undo .
define input  parameter p-y as decimal   no-undo .
define input  parameter p-z as decimal   no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define buffer buf_rang-xyz-def     for ub.rang-xyz-def.
define buffer buf_rang-xyz-def-obj for ub.rang-xyz-def-obj.
find first buf_rang-xyz-def exclusive-lock where recid(buf_rang-xyz-def) = p-recid no-error .
if not available buf_rang-xyz-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_rang-xyz-def.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
end.
else do:
  assign
      v-exist = true
      p-id = buf_rang-xyz-def.raxd-id
      p-db = buf_rang-xyz-def.db-num
      p-hash-string-obj       = buf_rang-xyz-def.raxd-hash-string-obj
      p-possb-keep-string-obj = buf_rang-xyz-def.raxd-possb-keep-string-obj
      p-string-obj            = buf_rang-xyz-def.raxd-string-obj
  .
end.
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_rang-xyz-def.raxd-hash-string-obj       = p-hash-string-obj
          buf_rang-xyz-def.raxd-possb-keep-string-obj = p-possb-keep-string-obj
          buf_rang-xyz-def.raxd-string-obj            = p-string-obj
          buf_rang-xyz-def.raxd-x                     = p-x
          buf_rang-xyz-def.raxd-y                     = p-y
          buf_rang-xyz-def.raxd-z                     = p-z
          buf_rang-xyz-def.raxd-id                    = p-id
          buf_rang-xyz-def.raxd-date                  = v-date
          buf_rang-xyz-def.raxd-db-num                = g#db-num
          buf_rang-xyz-def.db-num                     = p-db
          buf_rang-xyz-def.raxd-time                  = v-time
          buf_rang-xyz-def.raxd-who                   = g#userid
      .
if v-exist = true then do:
   for each buf_rang-xyz-def-obj exclusive-lock where
            buf_rang-xyz-def-obj.raxd-id = buf_rang-xyz-def.raxd-id and
            buf_rang-xyz-def-obj.db-num  = buf_rang-xyz-def.db-num :
            delete buf_rang-xyz-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, "," ).
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_rang-xyz-def-obj.
  assign
    buf_rang-xyz-def-obj.raxd-id  = buf_rang-xyz-def.raxd-id
    buf_rang-xyz-def-obj.db-num   = buf_rang-xyz-def.db-num
    buf_rang-xyz-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_rang-xyz-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
RELEASE buf_rang-xyz-def .
END PROCEDURE.
PROCEDURE update-doc-xyz-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-list-doc as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define variable  p-possb-keep-string-doc as logical   no-undo .
define variable  p-string-doc            as character no-undo .
define variable  p-hash-string-doc       as character no-undo .
define buffer buf_doc-xyz-def     for ub.doc-xyz-def.
define buffer buf_doc-xyz-def-obj for ub.doc-xyz-def-obj.
define buffer buf_doc-xyz-def-doc for ub.doc-xyz-def-doc.
    run def-hash in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
    run def-hash in this-procedure  (
         input   p-list-doc
        ,output  p-possb-keep-string-doc
        ,output  p-string-doc
        ,output  p-hash-string-doc
        ).
find first buf_doc-xyz-def exclusive-lock where recid(buf_doc-xyz-def) = p-recid no-error .
if not available buf_doc-xyz-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_doc-xyz-def.
end.
else do:
  assign
      v-exist = true
      p-id = buf_doc-xyz-def.doxd-id
      p-db = buf_doc-xyz-def.db-num
  .
end .
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_doc-xyz-def.doxd-hash-string-obj       = p-hash-string-obj
          buf_doc-xyz-def.doxd-possb-keep-string-obj = p-possb-keep-string-obj
          buf_doc-xyz-def.doxd-string-obj            = p-string-obj
          buf_doc-xyz-def.doxd-hash-string-doc       = p-hash-string-doc
          buf_doc-xyz-def.doxd-possb-keep-string-doc = p-possb-keep-string-doc
          buf_doc-xyz-def.doxd-string-doc            = p-string-doc
          buf_doc-xyz-def.doxd-id                    = p-id
          buf_doc-xyz-def.doxd-date                  = v-date
          buf_doc-xyz-def.doxd-db-num                = g#db-num
          buf_doc-xyz-def.doxd-time                  = v-time
          buf_doc-xyz-def.doxd-who                   = g#userid
          buf_doc-xyz-def.db-num                     = p-db
      .
if v-exist = true then do:
   for each buf_doc-xyz-def-doc exclusive-lock where
            buf_doc-xyz-def-doc.doxd-id = buf_doc-xyz-def.doxd-id and
            buf_doc-xyz-def-doc.db-num  = buf_doc-xyz-def.db-num :
            delete buf_doc-xyz-def-doc.
   end.
   for each buf_doc-xyz-def-obj exclusive-lock where
            buf_doc-xyz-def-obj.doxd-id = buf_doc-xyz-def.doxd-id and
            buf_doc-xyz-def-obj.db-num  = buf_doc-xyz-def.db-num :
            delete buf_doc-xyz-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, ",")  .
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_doc-xyz-def-obj.
  assign
    buf_doc-xyz-def-obj.doxd-id  = buf_doc-xyz-def.doxd-id
    buf_doc-xyz-def-obj.db-num   = buf_doc-xyz-def.db-num
    buf_doc-xyz-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_doc-xyz-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
p-list-doc = trim(p-list-doc , ",") .
k = num-entries(p-list-doc, ",") .
repeat  i = 1 to k :
  create buf_doc-xyz-def-doc.
  assign
    buf_doc-xyz-def-doc.doxd-id  = buf_doc-xyz-def.doxd-id
    buf_doc-xyz-def-doc.db-num   = buf_doc-xyz-def.db-num
    buf_doc-xyz-def-doc.dxdd-ext-doc-type = entry(i, p-list-doc)
  .
end.
RELEASE buf_doc-xyz-def .
END PROCEDURE.
PROCEDURE update-doc-def :
define input  parameter p-recid as recid     no-undo .
define input  parameter p-list-obj as character no-undo .
define input  parameter p-list-doc as character no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-exist as logical   no-undo .
define variable p-id as integer   no-undo .
define variable p-db as integer   no-undo .
define variable  p-possb-keep-string-obj as logical   no-undo .
define variable  p-string-obj            as character no-undo .
define variable  p-hash-string-obj       as character no-undo .
define variable  p-possb-keep-string-doc as logical   no-undo .
define variable  p-string-doc            as character no-undo .
define variable  p-hash-string-doc       as character no-undo .
define buffer buf_doc-abc-def     for ub.doc-abc-def.
define buffer buf_doc-abc-def-obj for ub.doc-abc-def-obj.
define buffer buf_doc-abc-def-doc for ub.doc-abc-def-doc.
    run def-hash  in this-procedure (
         input   p-list-obj
        ,output  p-possb-keep-string-obj
        ,output  p-string-obj
        ,output  p-hash-string-obj
        ).
    run def-hash  in this-procedure (
         input   p-list-doc
        ,output  p-possb-keep-string-doc
        ,output  p-string-doc
        ,output  p-hash-string-doc
        ).
find first buf_doc-abc-def exclusive-lock where recid(buf_doc-abc-def) = p-recid no-error .
if not available buf_doc-abc-def then do:
    v-exist = false  .
    assign
      p-id = next-value(s-asmt, ub)
      p-db = g#db-num
    .
    create buf_doc-abc-def.
end.
else do:
  assign
      v-exist = true
      p-id = buf_doc-abc-def.doad-id
      p-db = buf_doc-abc-def.db-num
  .
end .
run cur-time in this-procedure ( output v-date, output v-time ) .
    assign
          buf_doc-abc-def.doad-hash-string-obj       = p-hash-string-obj
          buf_doc-abc-def.doad-possb-keep-string-obj = p-possb-keep-string-obj
          buf_doc-abc-def.doad-string-obj            = p-string-obj
          buf_doc-abc-def.doad-hash-string-doc       = p-hash-string-doc
          buf_doc-abc-def.doad-possb-keep-string-doc = p-possb-keep-string-doc
          buf_doc-abc-def.doad-string-doc            = p-string-doc
          buf_doc-abc-def.doad-id                    = p-id
          buf_doc-abc-def.doad-date                  = v-date
          buf_doc-abc-def.doad-db-num                = g#db-num
          buf_doc-abc-def.doad-time                  = v-time
          buf_doc-abc-def.doad-who                   = g#userid
          buf_doc-abc-def.db-num                     = p-db
      .
if v-exist = true then do:
   for each buf_doc-abc-def-doc exclusive-lock where
            buf_doc-abc-def-doc.doad-id = buf_doc-abc-def.doad-id and
            buf_doc-abc-def-doc.db-num  = buf_doc-abc-def.db-num :
            delete buf_doc-abc-def-doc.
   end.
   for each buf_doc-abc-def-obj exclusive-lock where
            buf_doc-abc-def-obj.doad-id = buf_doc-abc-def.doad-id and
            buf_doc-abc-def-obj.db-num  = buf_doc-abc-def.db-num :
            delete buf_doc-abc-def-obj.
   end.
end.
define variable i as integer   no-undo .
define variable k as integer   no-undo .
p-list-obj = trim(p-list-obj, ",")  .
k = num-entries(p-list-obj, ",") .
repeat  i = 1 to k :
  create buf_doc-abc-def-obj.
  assign
    buf_doc-abc-def-obj.doad-id  = buf_doc-abc-def.doad-id
    buf_doc-abc-def-obj.db-num   = buf_doc-abc-def.db-num
    buf_doc-abc-def-obj.obj-type = substring(entry(i, p-list-obj) , 1 , 3 )
    buf_doc-abc-def-obj.obj-code = integer(substring(entry(i, p-list-obj) , 4 , 10 ))
  .
end.
p-list-doc = trim(p-list-doc , ",") .
k = num-entries(p-list-doc, ",") .
repeat  i = 1 to k :
  create buf_doc-abc-def-doc.
  assign
    buf_doc-abc-def-doc.doad-id  = buf_doc-abc-def.doad-id
    buf_doc-abc-def-doc.db-num   = buf_doc-abc-def.db-num
    buf_doc-abc-def-doc.dadd-ext-doc-type = entry(i, p-list-doc)
  .
end.
RELEASE buf_doc-abc-def .
END PROCEDURE.
PROCEDURE find-def-analysis-obj :
define input  parameter p-type     as character no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-abc-id   as integer   no-undo .
define output parameter p-db-num   as integer   no-undo .
  do
  on error undo, return error return-value
  :
  if p-type = "abc"  then do:
      define buffer buf_abc-analysis-obj for ub.abc-analysis-obj  .
      define buffer buf_abc-analysis     for ub.abc-analysis      .
      find first buf_abc-analysis-obj no-lock where
                buf_abc-analysis-obj.obj-type = p-obj-type and
                buf_abc-analysis-obj.obj-code = p-obj-code and
                buf_abc-analysis-obj.is-def   = true use-index objdef no-error .
                if available buf_abc-analysis-obj then do:
                    p-abc-id = buf_abc-analysis-obj.abc-id .
                    p-db-num = buf_abc-analysis-obj.db-num .
                end.
                else do:
                    p-abc-id = 0 .
                    p-db-num = 0.
                    return "На объекте нет анализа по умолчанию" .
                end.
  end.
  if p-type = "xyz"  then do:
      define buffer buf_xyz-analysis-obj for ub.xyz-analysis-obj  .
      define buffer buf_xyz-analysis     for ub.xyz-analysis      .
      find first buf_xyz-analysis-obj no-lock where
                buf_xyz-analysis-obj.obj-type = p-obj-type and
                buf_xyz-analysis-obj.obj-code = p-obj-code and
                buf_xyz-analysis-obj.is-def   = true use-index objdef no-error .
                if available buf_xyz-analysis-obj then do:
                    p-abc-id = buf_xyz-analysis-obj.xyz-id .
                    p-db-num = buf_xyz-analysis-obj.db-num .
                end.
                else do:
                    p-abc-id = 0 .
                    p-db-num = 0 .
                    return "На объекте нет анализа по умолчанию" .
                end.
  end.
  return .
end.
END PROCEDURE.
procedure save-def-analysis-obj :
define input  parameter p-type     as character no-undo .
define input  parameter p-db-num   as integer   no-undo .
define input  parameter p-abc-id   as integer   no-undo .
define output parameter v-log      as logical   no-undo .
  do
  on error undo, return error return-value
  :
  v-log = true .
  if p-type = "abc"  then do:
      define buffer buf_abc-analysis-obj for ub.abc-analysis-obj  .
      define buffer buf_abc-obj          for ub.abc-analysis-obj  .
      define buffer buf_abc-analysis     for ub.abc-analysis      .
      for each buf_abc-obj no-lock where
               buf_abc-obj.abc-id = p-abc-id and
               buf_abc-obj.db-num = p-db-num :
            define variable v-exist    as logical   no-undo init false .
            define variable v-list-anal as character no-undo init ""    .
            for each  buf_abc-analysis-obj no-lock where
                      not (buf_abc-analysis-obj.abc-id = p-abc-id and
                           buf_abc-analysis-obj.db-num = p-db-num) and
                      buf_abc-analysis-obj.is-def   = true   and
                      buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                      buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code
                      :
                v-exist    = true .
                v-list-anal = string( buf_abc-analysis-obj.abc-id ) + "," .
            end.
            if v-exist then do:
                message "На объекте "
                buf_abc-obj.obj-type
                buf_abc-obj.obj-code
                skip
                "уже есть анализы по умолчанию , их внутренние номера :" skip
                v-list-anal                                              skip
                "Сделать по умолчанию анализ текущий " p-abc-id " ?"
                view-as alert-box question
                buttons yes-no update v-log .
                if v-log then do:
                    for each  buf_abc-analysis-obj exclusive-lock where
                              buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                              buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code :
                      if ( buf_abc-analysis-obj.abc-id = p-abc-id and
                           buf_abc-analysis-obj.db-num = p-db-num ) then
                              buf_abc-analysis-obj.is-def   = true .
                      else buf_abc-analysis-obj.is-def   = false  .
                    end.
                end.
            end.
            else do:
              for each  buf_abc-analysis-obj exclusive-lock where
                        buf_abc-analysis-obj.obj-type = buf_abc-obj.obj-type and
                        buf_abc-analysis-obj.obj-code = buf_abc-obj.obj-code and
                        buf_abc-analysis-obj.abc-id = p-abc-id and
                        buf_abc-analysis-obj.db-num = p-db-num
                        :
                  buf_abc-analysis-obj.is-def   = true .
              end.
            end.
      end.
  end.
  if p-type = "xyz"  then do:
      define buffer buf_xyz-analysis-obj for ub.xyz-analysis-obj  .
      define buffer buf_xyz-obj          for ub.xyz-analysis-obj  .
      define buffer buf_xyz-analysis     for ub.xyz-analysis      .
      for each buf_xyz-obj no-lock where
               buf_xyz-obj.xyz-id = p-abc-id and
               buf_xyz-obj.db-num = p-db-num :
            v-exist = false .
            v-list-anal = ""    .
            for each  buf_xyz-analysis-obj no-lock where
                      not (buf_xyz-analysis-obj.xyz-id = p-abc-id and
                           buf_xyz-analysis-obj.db-num = p-db-num) and
                      buf_xyz-analysis-obj.is-def   = true   and
                      buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                      buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code
                      :
                v-exist    = true .
                v-list-anal = string( buf_xyz-analysis-obj.xyz-id ) + "," .
            end.
            if v-exist then do:
                message "На объекте "
                buf_xyz-obj.obj-type
                buf_xyz-obj.obj-code
                skip
                "уже есть анализы по умолчанию , их внутренние номера :" skip
                v-list-anal                                              skip
                "Сделать по умолчанию анализ текущий " p-abc-id " ?"
                view-as alert-box question
                buttons yes-no update v-log .
                if v-log then do:
                    for each  buf_xyz-analysis-obj exclusive-lock where
                              buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                              buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code :
                      if ( buf_xyz-analysis-obj.xyz-id = p-abc-id and
                           buf_xyz-analysis-obj.db-num = p-db-num ) then
                              buf_xyz-analysis-obj.is-def   = true .
                      else buf_xyz-analysis-obj.is-def   = false  .
                    end.
                end.
            end.
            else do:
              for each  buf_xyz-analysis-obj exclusive-lock where
                        buf_xyz-analysis-obj.obj-type = buf_xyz-obj.obj-type and
                        buf_xyz-analysis-obj.obj-code = buf_xyz-obj.obj-code and
                        buf_xyz-analysis-obj.xyz-id = p-abc-id and
                        buf_xyz-analysis-obj.db-num = p-db-num
                        :
                  buf_xyz-analysis-obj.is-def   = true .
              end.
            end.
      end.
  end.
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info2, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .
define variable v-host-code as integer   no-undo .
define variable v-base-code as integer   no-undo .
define variable v-first-base-code as integer   no-undo .
define stream LogStream.
if p-mode <> 'ДОБАВЛЕНИЕ':U AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
find first x-abc-analysis no-error .
if error-status :error then do:
          run err-mess ("Не найдена x-abc-analysis ").
          return error "err":U.
end.
IF x-abc-analysis.abc-a  >= 100 or
   x-abc-analysis.abc-b >= 100  or
   x-abc-analysis.abc-a <= 0    or
   x-abc-analysis.abc-b <= 0    then do:
          run err-mess ("Не верно установлено соотношение ранжировани ").
          return error "abc-rang":U.
END.
define variable par-type as character no-undo .
define variable par-abc-type as character no-undo .
define variable  v-value-date    as date   no-undo .
define variable  v-value-decimal as decimal   no-undo .
define variable  v-value-integer as integer   no-undo .
define variable  v-value-logical as logical   no-undo .
define variable v-found as logical   no-undo .
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   'abc-global':U ,
  input   'abc-type'  ,
  output  par-abc-type ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.
case par-abc-type:
    when "ABC":U
    then do:
      if x-abc-analysis.abc-a = 0 then do:
          run err-mess ("Нe задан уровень А!").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-b = 0 then do:
          run err-mess ("Нe задан уровень  B !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-c = 0 then do:
        assign
          x-abc-analysis.abc-c = 100
          x-abc-analysis.abc-d = 0
          x-abc-analysis.abc-e = 0
          x-abc-analysis.abc-f = 0
        .
      end.
      if  x-abc-analysis.abc-a = x-abc-analysis.abc-b then do:
          run err-mess ("Уровни ранжирования должны быть различны !").
          return error "abc-rang":U.
      end.
      if not (x-abc-analysis.abc-a < x-abc-analysis.abc-b  and
            x-abc-analysis.abc-b < x-abc-analysis.abc-c  )
           then do:
              run err-mess ("Уровни ранжирования должны идти по возрастанию !").
              return error "abc-rang":U.
           end.
    end.
    when "ABCD":U
    then do:
      if x-abc-analysis.abc-a = 0 then do:
          run err-mess ("Нe задан уровень А!").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-b = 0 then do:
          run err-mess ("Нe задан уровень  B !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-c = 0 then do:
          run err-mess ("Нe задан уровень  C !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-d = 0 then do:
        assign
          x-abc-analysis.abc-d = 100
          x-abc-analysis.abc-e = 0
          x-abc-analysis.abc-f = 0
        .
      end.
      if   (x-abc-analysis.abc-a = x-abc-analysis.abc-b)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-c)   or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-c)
        then do:
          run err-mess ("Уровни ранжирования должны быть различны !").
          return error "abc-rang":U.
      end.
      if not (x-abc-analysis.abc-a < x-abc-analysis.abc-b  and
            x-abc-analysis.abc-b < x-abc-analysis.abc-c  and
            x-abc-analysis.abc-c < x-abc-analysis.abc-d )
           then do:
              run err-mess ("Уровни ранжирования должны идти по возрастанию !").
              return error "abc-rang":U.
           end.
    end.
    when "ABCDE":U
    then do:
      if x-abc-analysis.abc-a = 0 then do:
          run err-mess ("Нe задан уровень А!").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-b = 0 then do:
          run err-mess ("Нe задан уровень  B !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-c = 0 then do:
          run err-mess ("Нe задан уровень  C !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-d = 0 then do:
          run err-mess ("Нe задан уровень  D !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-e = 0 then do:
        assign
          x-abc-analysis.abc-e = 100
          x-abc-analysis.abc-f = 0
        .
      end.
      if   (x-abc-analysis.abc-a = x-abc-analysis.abc-b)  or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-c)  or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-d)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-c)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-d)
        then do:
          run err-mess ("Уровни ранжирования должны быть различны !").
          return error "abc-rang":U.
      end.
      if not (x-abc-analysis.abc-a < x-abc-analysis.abc-b  and
            x-abc-analysis.abc-b < x-abc-analysis.abc-c  and
            x-abc-analysis.abc-c < x-abc-analysis.abc-d  and
            x-abc-analysis.abc-d < x-abc-analysis.abc-e  )
           then do:
              run err-mess ("Уровни ранжирования должны идти по возрастанию !").
              return error "abc-rang":U.
           end.
    end.
    when "ABCDEF":U
    then do:
      if x-abc-analysis.abc-a = 0 then do:
          run err-mess ("Нe задан уровень А!").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-b = 0 then do:
          run err-mess ("Нe задан уровень  B !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-c = 0 then do:
          run err-mess ("Нe задан уровень  C !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-d = 0 then do:
          run err-mess ("Нe задан уровень  D !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-f = 0 then do:
          run err-mess ("Нe задан уровень  F !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-f = 0 then do:
        assign
          x-abc-analysis.abc-f = 100
        .
      end.
      if   (x-abc-analysis.abc-a = x-abc-analysis.abc-b)  or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-c)  or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-d)  or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-e)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-c)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-d)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-e)  or
           (x-abc-analysis.abc-c = x-abc-analysis.abc-d)  or
           (x-abc-analysis.abc-c = x-abc-analysis.abc-e)
        then do:
          run err-mess ("Уровни ранжирования должны быть различны !").
          return error "abc-rang":U.
      end.
      if not (x-abc-analysis.abc-a < x-abc-analysis.abc-b  and
            x-abc-analysis.abc-b < x-abc-analysis.abc-c  and
            x-abc-analysis.abc-c < x-abc-analysis.abc-d  and
            x-abc-analysis.abc-d < x-abc-analysis.abc-e  and
            x-abc-analysis.abc-e < x-abc-analysis.abc-f)
           then do:
              run err-mess ("Уровни ранжирования должны идти по возрастанию !").
              return error "abc-rang":U.
           end.
    end.
end case.
if x-abc-analysis.abc-name = "":U then do:
  run err-mess ("Название ABC анализа не может быть пустым").
  return error "abc-name":U.
end.
if x-abc-analysis.cral-id = 0 then do:
  run err-mess ("Не выбран КРИТЕРИЙ АНАЛИЗА").
  return error "cral-id":U.
end.
if not can-find ( first x-abc-analysis-doc) then do: run err-mess ("Не заданы типы документов для анализа"). return error "doc":U. end.
if not can-find ( first x-abc-analysis-obj) then do: run err-mess ("Не заданы объекты для анализа"). return error "obj":U. end.
if not can-find ( first x-abc-analysis-period) then do: run err-mess ("Не заданы периоды для анализа"). return error "period":U. end.
find first ub.criterion-analysis no-lock where ub.criterion-analysis.cral-id = x-abc-analysis.cral-id no-error .
if not available ub.criterion-analysis then do: run err-mess ("Не верно задан критерий анализа.Ошибка поиска"). return error "cral-id":U. end.
if available ub.criterion-analysis and ub.criterion-analysis.cral-status <> 0  then do: run err-mess ("Критерий анализа не активный"). return error "cral-id":U. end.
define variable fl as logical   no-undo init false .
if lookup(string(criterion-analysis.cral-id) ,"5,7,9,11,13,15") > 0 then do:
    for each x-abc-analysis-obj break by x-abc-analysis-obj.obj-type by x-abc-analysis-obj.obj-code :
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x-abc-analysis-obj.obj-type
  ,input  x-abc-analysis-obj.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-host-code
  ,output v-base-code
  )  .
      if fl = false then
          assign
            v-first-base-code = v-base-code
            fl = true
          .
      if v-first-base-code <> v-base-code then do:
          run err-mess ("При выбранном валютном критерии анализа , выбранные объекты принадлежат к разным валютным фирмам. Анализ не возможен !!!").
          return error "obj":U.
      end.
    end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
run cur-time in this-procedure(output v-date, output v-time).
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.abc-analysis.
    assign
    ub.abc-analysis.abc-id = next-value(s-asmt, ub)
    ub.abc-analysis.abc-date-create    = v-date
    ub.abc-analysis.abc-time-create    = v-time
    ub.abc-analysis.abc-db-num-create  = g#db-num
    ub.abc-analysis.abc-who-create     = g#userid
    ub.abc-analysis.db-num             = g#db-num
.
    p-doc-rec = recid(ub.abc-analysis)
    .
  end.
  else do:
    FIND FIRST ub.abc-analysis where
              recid(ub.abc-analysis) = p-doc-rec No-ERROR.
    if not available ub.abc-analysis then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
  end.
  assign
    ub.abc-analysis.cral-id     =  x-abc-analysis.cral-id
    ub.abc-analysis.abc-name    =  x-abc-analysis.abc-name
    ub.abc-analysis.abc-des     =  x-abc-analysis.abc-des
    ub.abc-analysis.raad-a      =  x-abc-analysis.raad-a
    ub.abc-analysis.raad-b      =  x-abc-analysis.raad-b
    ub.abc-analysis.raad-c      =  x-abc-analysis.raad-c
    ub.abc-analysis.raad-d      =  x-abc-analysis.raad-d
    ub.abc-analysis.raad-e      =  x-abc-analysis.raad-e
    ub.abc-analysis.raad-f      =  x-abc-analysis.raad-f
    ub.abc-analysis.abc-a       =  x-abc-analysis.abc-a
    ub.abc-analysis.abc-b       =  x-abc-analysis.abc-b
    ub.abc-analysis.abc-c       =  x-abc-analysis.abc-c
    ub.abc-analysis.abc-d       =  x-abc-analysis.abc-d
    ub.abc-analysis.abc-e       =  x-abc-analysis.abc-e
    ub.abc-analysis.abc-f       =  x-abc-analysis.abc-f
    ub.abc-analysis.abc-a-prc-qnty  =  x-abc-analysis.abc-a-prc-qnty
    ub.abc-analysis.abc-a-qnty      =  x-abc-analysis.abc-a-qnty
    ub.abc-analysis.abc-a-sum-prc   =  x-abc-analysis.abc-a-sum-prc
    ub.abc-analysis.abc-a-sum       =  x-abc-analysis.abc-a-sum
    ub.abc-analysis.abc-b-prc-qnty  =  x-abc-analysis.abc-b-prc-qnty
    ub.abc-analysis.abc-b-qnty      =  x-abc-analysis.abc-b-qnty
    ub.abc-analysis.abc-b-sum-prc   =  x-abc-analysis.abc-b-sum-prc
    ub.abc-analysis.abc-b-sum       =  x-abc-analysis.abc-b-sum
    ub.abc-analysis.abc-c-prc-qnty  =  x-abc-analysis.abc-c-prc-qnty
    ub.abc-analysis.abc-c-qnty      =  x-abc-analysis.abc-c-qnty
    ub.abc-analysis.abc-c-sum-prc   =  x-abc-analysis.abc-c-sum-prc
    ub.abc-analysis.abc-c-sum       =  x-abc-analysis.abc-c-sum
    ub.abc-analysis.abc-d-prc-qnty  =  x-abc-analysis.abc-d-prc-qnty
    ub.abc-analysis.abc-d-qnty      =  x-abc-analysis.abc-d-qnty
    ub.abc-analysis.abc-d-sum-prc   =  x-abc-analysis.abc-d-sum-prc
    ub.abc-analysis.abc-d-sum       =  x-abc-analysis.abc-d-sum
    ub.abc-analysis.abc-e-prc-qnty  =  x-abc-analysis.abc-e-prc-qnty
    ub.abc-analysis.abc-e-qnty      =  x-abc-analysis.abc-e-qnty
    ub.abc-analysis.abc-e-sum-prc   =  x-abc-analysis.abc-e-sum-prc
    ub.abc-analysis.abc-e-sum       =  x-abc-analysis.abc-e-sum
    ub.abc-analysis.abc-f-prc-qnty  =  x-abc-analysis.abc-f-prc-qnty
    ub.abc-analysis.abc-f-qnty      =  x-abc-analysis.abc-f-qnty
    ub.abc-analysis.abc-f-sum-prc   =  x-abc-analysis.abc-f-sum-prc
    ub.abc-analysis.abc-f-sum       =  x-abc-analysis.abc-f-sum
    ub.abc-analysis.R-GOODS         =  x-abc-analysis.r-goods
    ub.abc-analysis.double-line-proc          =  x-abc-analysis.double-line-proc
    ub.abc-analysis.le-proc         =  x-abc-analysis.le-proc
    ub.abc-analysis.abc-type        =  x-abc-analysis.abc-type
  .
for each ub.abc-analysis-doc exclusive-lock where
         ub.abc-analysis-doc.abc-id = ub.abc-analysis.abc-id and
         ub.abc-analysis-doc.db-num = ub.abc-analysis.db-num   :
    delete ub.abc-analysis-doc .
end.
v-list-doc = "".
for each x-abc-analysis-doc :
     create ub.abc-analysis-doc.
     BUFFER-COPY x-abc-analysis-doc  TO ub.abc-analysis-doc
         assign
           ub.abc-analysis-doc.abc-id = ub.abc-analysis.abc-id
           ub.abc-analysis-doc.db-num = ub.abc-analysis.db-num
         .
          v-list-doc = v-list-doc +  x-abc-analysis-doc.abcd-ext-doc-type + "," .
end.
for each ub.abc-analysis-obj exclusive-lock where
         ub.abc-analysis-obj.abc-id = ub.abc-analysis.abc-id and
         ub.abc-analysis-obj.db-num = ub.abc-analysis.db-num   :
    delete ub.abc-analysis-obj .
end.
 v-list-obj = "".
for each x-abc-analysis-obj :
     create ub.abc-analysis-obj.
     BUFFER-COPY x-abc-analysis-obj  TO ub.abc-analysis-obj
         assign
           ub.abc-analysis-obj.abc-id = ub.abc-analysis.abc-id
           ub.abc-analysis-obj.db-num = ub.abc-analysis.db-num
         .
     v-list-obj = v-list-obj + x-abc-analysis-obj.obj-type + string(x-abc-analysis-obj.obj-code) + "," .
end.
for each ub.abc-analysis-period exclusive-lock where
         ub.abc-analysis-period.abc-id = ub.abc-analysis.abc-id and
         ub.abc-analysis-period.db-num = ub.abc-analysis.db-num   :
    delete ub.abc-analysis-period .
end.
v-list-period = "".
for each x-abc-analysis-period :
     create ub.abc-analysis-period.
     BUFFER-COPY x-abc-analysis-period TO ub.abc-analysis-period
         assign
           ub.abc-analysis-period.abc-id = ub.abc-analysis.abc-id
           ub.abc-analysis-period.db-num = ub.abc-analysis.db-num
         .
         v-list-period = v-list-period + string ( x-abc-analysis-period.abcp-start,"99/99/9999") + "-"
                                       + string ( x-abc-analysis-period.abcp-end,"99/99/9999")    + "," .
end.
  run def-hash ( input   v-list-obj ,
                 output  v-abc-possb-keep-string-obj,
                 output  v-abc-string-obj ,
                 output  v-abc-hash-string-obj       )
                 .
  run def-hash ( input   v-list-period ,
                 output  v-abc-possb-keep-string-period,
                 output  v-abc-string-period ,
                 output  v-abc-hash-string-period       )
                 .
  run def-hash ( input   v-list-doc ,
                 output  v-abc-possb-keep-string-doc,
                 output  v-abc-string-doc ,
                 output  v-abc-hash-string-doc       )
                 .
  assign
    ub.abc-analysis.abc-hash-string-obj          =  v-abc-hash-string-obj
    ub.abc-analysis.abc-hash-string-period       =  v-abc-hash-string-period
    ub.abc-analysis.abc-hash-string-doc          =  v-abc-hash-string-doc
    ub.abc-analysis.abc-possb-keep-string-obj    =  v-abc-possb-keep-string-obj
    ub.abc-analysis.abc-possb-keep-string-period =  v-abc-possb-keep-string-period
    ub.abc-analysis.abc-possb-keep-string-doc    =  v-abc-possb-keep-string-doc
    ub.abc-analysis.abc-string-obj               =  v-abc-string-obj
    ub.abc-analysis.abc-string-period            =  v-abc-string-period
    ub.abc-analysis.abc-string-doc               =  v-abc-string-doc
  .
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
      message
      p-mess
      view-as alert-box error .
END PROCEDURE.
