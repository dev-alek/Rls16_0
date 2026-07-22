DEFINE BUFFER locked_dis-card-long FOR ub.dis-card-long.
DEFINE BUFFER locked_dis-card-property FOR ub.dis-card-property.
DEFINE TEMP-TABLE temp-dis-card NO-UNDO LIKE ub.dis-card.
DEFINE TEMP-TABLE tt0-dis-card-long NO-UNDO LIKE ub.dis-card-long.
DEFINE TEMP-TABLE tt0-dis-card-property NO-UNDO LIKE ub.dis-card-property.
define input parameter parparentproc as widget-handle no-undo .
define input parameter ref-mode as char no-undo .
define input parameter paremitent-host-code like ub.sysconf.host-code no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.shop.obj-code no-undo.
define input parameter cli-ri           as recid no-undo .
define input-output parameter dc-ri           as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Дисконтная карта - добавление,изменение" .
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
FUNCTION calc-dcpc-1 RETURNS DECIMAL(input  for-sum as decimal,
                                   input  n-d-pcnt as decimal,
                                   input  sumdiscs as char,
                                   output new-d-pcnt     as decimal):
define variable ii as integer no-undo.
ii = 1.
new-d-pcnt = n-d-pcnt.
REPEAT while (ii <= num-entries(sumdiscs, ";")):
    IF for-sum >= DECIMAL(ENTRY(1,ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs,";") OR
        for-sum < DECIMAL(ENTRY(1,ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-d-pcnt = decimal(ENTRY(2,ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
        LEAVE.
    END.
    ii = ii + 1.
END.
RETURN new-d-pcnt.
END FUNCTION.
FUNCTION calc-dckat-1 RETURNS INTEGER(input  for-sum as decimal,
                                   input  n-kat as integer,
                                   input  sumdiscs as char,
                                   output new-kat  as integer):
define variable ii as integer no-undo.
ii = 1.
new-kat = n-kat.
REPEAT while (ii <= num-entries(sumdiscs, ";")):
    IF for-sum >= DECIMAL(ENTRY(1,ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs,";") OR
        for-sum < DECIMAL(ENTRY(1,ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-kat = integer(ENTRY(2,ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
        LEAVE.
    END.
    ii = ii + 1.
END.
RETURN new-kat.
END FUNCTION.
FUNCTION calc-dcpc-2 RETURNS DECIMAL(input  for-sum as decimal,
                                    input  n-d-pcnt as decimal,
                                   input  sumdiscs as char,
                                   output new-d-pcnt     as decimal):
define variable ii as integer no-undo.
define variable v-new-ii as integer no-undo init -1.
define variable v-old-ii as integer no-undo init -1.
define variable no-support as logical no-undo .
new-d-pcnt = 0.
if n-d-pcnt = ? then do:
  no-support = yes.
  n-d-pcnt = 0.
end.
ii = 1.
REPEAT while (ii <= num-entries(sumdiscs, ";")):
    if ii = 1 and
    for-sum < DECIMAL(ENTRY(1, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-new-ii = 0.
    end.
    if ii = 1
    and  n-d-pcnt < DECIMAL(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-old-ii = 0.
    end.
    IF for-sum >= DECIMAL(ENTRY(1, ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs, ";") OR
        for-sum < DECIMAL(ENTRY(1, ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-d-pcnt = decimal(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
      v-new-ii = ii.
    END.
    IF n-d-pcnt >= DECIMAL(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs, ";") OR
        n-d-pcnt < DECIMAL(ENTRY(2, ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      v-old-ii = ii.
    end.
    if (v-new-ii <> - 1
    AND V-OLD-II <>  -1)
    and ((v-old-ii - v-new-ii) >= 1
          or
          new-d-pcnt > n-d-pcnt
          or no-support
          )
    then leave.
    ii = ii + 1.
END.
if new-d-pcnt < n-d-pcnt then
new-d-pcnt = decimal(ENTRY(2, ENTRY(v-old-ii - 1, sumdiscs, ";"), "=")) no-error .
RETURN new-d-pcnt.
END FUNCTION.
FUNCTION calc-dckat-2 RETURNS INTEGER(input  for-sum as decimal,
                                   input  n-kat as integer,
                                   input  sumdiscs as char,
                                   output new-kat  as integer):
define variable ii as integer no-undo.
define variable v-new-ii as integer no-undo init -1.
define variable v-old-ii as integer no-undo init -1.
define variable no-support as logical no-undo .
if n-kat = ? then do:
  no-support = yes.
  n-kat = 0.
end.
ii = 1.
new-kat = 0.
REPEAT while (ii <= num-entries(sumdiscs, ";")):
    if ii = 1
    and for-sum < DECIMAL(ENTRY(1, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-new-ii = 0.
    end.
    if ii = 1
    and n-kat < integer(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) then do:
       assign
       v-old-ii = 0.
    end.
    IF for-sum >= DECIMAL(ENTRY(1,ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs,";") OR
        for-sum < DECIMAL(ENTRY(1,ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      new-kat = integer(ENTRY(2,ENTRY(ii, sumdiscs, ";"), "=")) NO-ERROR.
      v-new-ii = ii.
    END.
    IF n-kat >= integer(ENTRY(2, ENTRY(ii, sumdiscs, ";"), "=")) AND
        (ii = NUM-ENTRIES(sumdiscs, ";") OR
        n-kat < integer(ENTRY(2, ENTRY(ii + 1, sumdiscs, ";"), "="))
          ) THEN do:
      assign
      v-old-ii = ii.
    END.
    if (v-new-ii <> - 1
    AND V-OLD-II <>  -1)
    and (abs(v-old-ii - v-new-ii) >= 1
         or
         no-support)
    then leave.
    ii = ii + 1.
END.
if v-new-ii < v-old-ii then
new-kat = integer(ENTRY(2, ENTRY(v-old-ii - 1, sumdiscs, ";"), "=")) no-error .
RETURN new-kat.
END FUNCTION.
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
define variable v-disprop-menu-section-num as integer no-undo .
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
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
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
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
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
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
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
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
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
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-pers-proc no-undo
field proc-name as character
field vproc-handle as handle
field vparent-handle as handle
field user-name as character
field id as integer
field vpar as character
field rank-to-delete as integer
index pi is unique primary
proc-name
id
index puser
proc-name
user-name
index ppar
proc-name
vpar
index iparent
vparent-handle
proc-name
index iid
id
index ird
rank-to-delete
.
define variable v-per-proc-num as integer no-undo .
procedure perproc-create-proc :
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-proc-name as character no-undo .
define input  parameter p-proc-handle  as handle no-undo .
define input  parameter p-run        as logical no-undo .
define input  parameter p-parameter as character no-undo .
define input  parameter p-userid as character no-undo .
define input  parameter p-rank-to-delete as integer no-undo .
define output parameter p-id as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-proc-handle as handle no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
define buffer buf0_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
    if v-per-proc-num > 200 then return error '>'.
    find first buf0_temp-pers-proc no-lock where
              buf0_temp-pers-proc.proc-name = p-proc-name use-index pi    no-error.
    if not available buf0_temp-pers-proc then do:
      if p-run then do:
        run value(p-proc-name) persistent SET v-proc-handle (input p-parameter) no-error.
        if error-status :error then undo, return error return-value .
      end.
      else v-proc-handle = p-proc-handle.
      find last buf0_temp-pers-proc no-lock use-index iid  no-error.
      create buf_temp-pers-proc.
      assign
      buf_temp-pers-proc.proc-name = p-proc-name
      buf_temp-pers-proc.id = (if not available buf0_temp-pers-proc
                                then  0
                                else buf0_temp-pers-proc.id + 1)
      buf_temp-pers-proc.user-name = p-userid
      buf_temp-pers-proc.vpar      = p-parameter
      buf_temp-pers-proc.vparent-handle = p-parent-handle
      buf_temp-pers-proc.vproc-handle = v-proc-handle
      buf_temp-pers-proc.rank-to-delete = p-rank-to-delete
      p-id = buf_temp-pers-proc.id
      v-per-proc-num = v-per-proc-num + 1
      .
    end.
    else p-id = buf0_temp-pers-proc.id.
  end.
end procedure.
procedure perproc-delete-proc-user :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-user-name as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.user-name = p-user-name:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-proc-id :
define input  parameter p-id        as integer   no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
        buf_temp-pers-proc.id        = p-id:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-by-rank :
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
    for each buf_temp-pers-proc where
    by buf_temp-pers-proc.rank-to-delete:
      APPLY "delete" to buf_temp-pers-proc.vproc-handle.
      delete procedure buf_temp-pers-proc.vproc-handle.
      delete buf_temp-pers-proc.
      v-per-proc-num = v-per-proc-num - 1.
    end.
  end.
end procedure.
procedure perproc-delete-proc-name-id :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-id        as integer   no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.id        = p-id:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-par :
define input  parameter p-proc-name as character no-undo .
define input  parameter p-parameter as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     for each buf_temp-pers-proc where
            buf_temp-pers-proc.proc-name = p-proc-name
       AND  buf_temp-pers-proc.vpar      = p-parameter:
        APPLY "delete" to buf_temp-pers-proc.vproc-handle.
        delete procedure buf_temp-pers-proc.vproc-handle.
        delete buf_temp-pers-proc.
        v-per-proc-num = v-per-proc-num - 1.
     end.
  end.
end procedure.
procedure perproc-delete-from-parent :
define input  parameter p-parent-handle as handle no-undo .
define input  parameter p-proc-name as character no-undo .
define buffer buf_temp-pers-proc for temp-pers-proc.
  do
  on error undo, return error return-value
  :
     if p-proc-name = "":u then do:
      for each buf_temp-pers-proc where
         buf_temp-pers-proc.vparent-handle      = p-parent-handle:
          APPLY "delete" to buf_temp-pers-proc.vproc-handle.
          delete procedure buf_temp-pers-proc.vproc-handle.
          delete buf_temp-pers-proc.
          v-per-proc-num = v-per-proc-num - 1.
      end.
     end.
     else do:
      for each buf_temp-pers-proc where
              buf_temp-pers-proc.proc-name = p-proc-name
        AND  buf_temp-pers-proc.vparent-handle      = p-parent-handle:
          APPLY "delete" to buf_temp-pers-proc.vproc-handle.
          delete procedure buf_temp-pers-proc.vproc-handle.
          delete buf_temp-pers-proc.
          v-per-proc-num = v-per-proc-num - 1.
      end.
    end.
  end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define NEW SHARED temp-table temp-labels no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
field f_update as logical
field f_can_update as logical
field f_parent as character
field f_visible as logical
field f_root as character
index iu f_update
index ivisible  f_visible
index iparent f_root f_parent
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
procedure tempchgs-create-lable-record :
define input parameter p-t_name as character no-undo .
define input parameter p-f_name as character no-undo .
define input parameter p-l_name as character no-undo .
define input parameter p-f_update as logical no-undo .
define input parameter p-f_parent as character no-undo .
define input parameter p-f_visible as logical no-undo .
define buffer buf_temp-labels for temp-labels.
  do
  on error undo, return error
  :
     find first buf_temp-labels where
              buf_temp-labels.t_name = p-t_name
          and buf_temp-labels.f_name = p-f_name no-error.
     if not available buf_temp-labels then do:
      create buf_temp-labels.
      assign
      buf_temp-labels.t_name = p-t_name
      buf_temp-labels.f_name = p-f_name
      buf_temp-labels.l_name = p-l_name
      .
     end.
     assign
     buf_temp-labels.f_can_update = p-f_update
     buf_temp-labels.f_parent = p-f_parent
     buf_temp-labels.f_visible = p-f_visible
     buf_temp-labels.f_root = (if p-f_parent = '':U then p-f_name else p-f_parent)
     buf_temp-labels.num_ = 0
     .
  end.
end procedure.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
      if v-old-value <> v-new-value
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcont_v-num_ as integer no-undo .
define  temp-table temp-tables no-undo
field tbl-name as character
field new-tbl-handle as handle
field new-table-handle as handle
index pi is unique primary
tbl-name.
define  temp-table temp-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
procedure tempcont_create-changes :
define input  parameter p-tbl-name   as character no-undo.
define input  parameter p-tbl-handle as handle    no-undo.
define input  parameter p-ttbl-handle as handle    no-undo.
define input  parameter p-action as integer no-undo .
define variable v-chg-fields as character no-undo .
define variable v-ii as integer no-undo .
define variable fh-main as handle no-undo .
define variable fh-temp as handle no-undo .
define variable fh as handle no-undo .
define variable th as handle no-undo .
define variable v-main-value as character no-undo .
define variable v-temp-value as character no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-ind as integer no-undo .
define variable v-keys as character no-undo .
if p-tbl-handle:available then do:
  if p-tbl-handle:buffer-compare( p-ttbl-handle) = yes then return.
end.
do v-ii = 1 to min(p-tbl-handle:num-fields, p-ttbl-handle:num-fields):
  assign
  fh-main      = p-tbl-handle:buffer-field( v-ii )
  fh-temp      = p-ttbl-handle:buffer-field( v-ii )
  .
  if fh-main:name = fh-temp:name
  and fh-main:data-type = fh-temp:data-type then do:
    if fh-main:buffer-value ne fh-temp:buffer-value then do:
      if p-action = integer('1':U) then do:
        assign
        fh = fh-temp
        th = p-ttbl-handle
        v-main-value = fh-main:initial
        v-keys  = p-ttbl-handle:keys
        .
      end.
      else do:
        assign
        fh = fh-main
        th = p-tbl-handle
        v-main-value = fh-main:string-value
        v-keys  = p-tbl-handle:keys
        .
      end.
      assign
      v-temp-value = fh-temp:string-value
     .
     if v-uniq-key-rec = '':U then do:
        v-uniq-key-rec = p-tbl-name.
        do v-ind = 1 to num-entries(v-keys)
        on error undo, return error
        :
          assign
          fh = th:buffer-field(entry(v-ind, v-keys))
          v-uniq-key-rec = v-uniq-key-rec + chr(3) + substitute("&1", fh:buffer-value())
          .
        end.
      end.
      create temp-changes.
      assign
      temp-changes.t_name = p-tbl-name
      temp-changes.f_name = fh-main:name
      temp-changes.l_name = '':U
      temp-changes.v_old  = v-main-value
      temp-changes.v_new  = v-temp-value
      temp-changes.action = p-action
      temp-changes.uniq-key-rec = v-uniq-key-rec
      temp-changes.num_   = tempcont_v-num_ + 1
      tempcont_v-num_     = tempcont_v-num_ + 1
      .
    end.
  end.
end.
end procedure.
procedure tempcont_create-record :
define input  parameter p-tbl-name   as character no-undo.
define input  parameter p-new-tbl-handle as handle    no-undo.
define input  parameter p-action as integer no-undo .
do
on error  undo, return error substitute( "&1 (tempcont_create-record). &2&3&4", vss-include-info14, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1 (tempcont_create-record). stop", vss-include-info14 )
on endkey undo, return error substitute( "&1 (tempcont_create-record). endkey", vss-include-info14 )
:
  define variable tt-name          as character no-undo .
  define variable tth              as handle    no-undo .
  define variable bh_tt            as handle    no-undo .
  define variable v-ok             as logical   no-undo .
  define variable v-full-tbl-name  as character no-undo .
  define variable v-inform         as character no-undo .
  define variable v-ind            as integer   no-undo .
  define variable v-idx-field-qnty as integer   no-undo .
  define variable v-where          as character no-undo .
  define variable v-word-link      as character no-undo .
  define variable v-field-name     as character no-undo .
  define variable fh_tbl-name      as handle    no-undo .
  define variable fh_tt            as handle    no-undo .
  define variable v-field-val      as character no-undo .
  define variable compare-log      as logical no-undo .
  define buffer buf_temp-tables  for temp-tables.
  if not p-new-tbl-handle:available then do:
    return error substitute( "&1. Переданный буфер таблицы &2 не доступен", vss-include-info14, p-tbl-name ).
  end.
  assign
    v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
  .
  find first buf_temp-tables where
            buf_temp-tables.tbl-name = p-tbl-name no-error .
  if not available buf_temp-tables then do:
    create temp-table tth.
    assign
      tt-name = "wt-" + p-tbl-name
      tth:undo = no
    .
    v-ok = yes.
    assign
      v-ok = tth:create-like( v-full-tbl-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). Ошибка при создании временной таблицы &2 (1)", vss-include-info14, tt-name ) .
    end.
    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). Ошибка при создании временной таблицы &2 (2)", vss-include-info14, tt-name ) .
    end.
    create buf_temp-tables.
    assign
    buf_temp-tables.tbl-name = p-tbl-name
    buf_temp-tables.new-tbl-handle = tth:default-buffer-handle
    buf_temp-tables.new-table-handle = tth
    .
    assign
    bh_tt = buf_temp-tables.new-tbl-handle
    .
  end.
  else do:
    if p-new-tbl-handle:table-handle = buf_temp-tables.new-tbl-handle:table-handle then do:
      assign
      bh_tt = p-new-tbl-handle
      .
    end.
    else do:
      assign
      bh_tt = buf_temp-tables.new-tbl-handle
      .
    end.
  end.
  assign
  v-inform = bh_tt:index-information(1)
  v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = bh_tt:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1 (tempcont_create-record). Таблица &2 не имеет первичного ключа в БД", vss-include-info14, p-tbl-name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1 (tempcont_create-record). Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info14, v-inform, p-tbl-name ).
  end.
  assign
    v-where     = "where":U
    v-word-link = "":U
  .
  block_where:
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh_tbl-name  = bh_tt:buffer-field( v-field-name )
      fh_tt        = p-new-tbl-handle:buffer-field( v-field-name )
      v-field-val  = fh_tt:buffer-value
      v-where      = substitute( "&1 &2 &3.&4 =", v-where, v-word-link, fh_tbl-name:table, v-field-name )
    .
    if fh_tbl-name:data-type ="character":U then do:
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
      v-where = substitute( "&1 &2", v-where, v-field-val )
    .
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  bh_tt:find-first( v-where, exclusive-lock ) no-error .
  if not bh_tt:available then do:
    assign
      v-ok = false
    .
    assign
      v-ok = bh_tt:buffer-create no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). Ошибка при создании буфера временной таблицы.", vss-include-info14, p-tbl-name ).
    end.
    assign
      compare-log = false
    .
  end.
  else do:
    assign
      compare-log = bh_tt:buffer-compare( p-new-tbl-handle )
    .
  end.
  if compare-log = false then do:
    assign
      v-ok = false
    .
    assign
      v-ok = bh_tt:buffer-copy( p-new-tbl-handle ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_create-record). BUFFER-COPY не прошел для таблицы &2", vss-include-info14, p-tbl-name ).
    end.
  end.
  assign
    v-ok = false
  .
  assign
    v-ok = bh_tt:buffer-release() no-error
  .
  if v-ok <> true then do:
    return error substitute( "&1 (tempcont_create-record). buffer-release не прошел для таблицы &2", vss-include-info14, p-tbl-name ).
  end.
  assign
    v-ok = false
  .
  assign
    fh_tbl-name  = ?
    fh_tt        = ?
    bh_tt        = ?
  .
end.
end procedure.
procedure tempcont_get-buffer-handle :
define input parameter p-tbl-name as character no-undo .
define output parameter p-new-tbl-handle as handle no-undo .
do
on error undo, return error
:
  define variable tth              as handle    no-undo .
  define variable tt-name          as character no-undo .
  define variable v-ok             as logical   no-undo .
  define variable v-full-tbl-name  as character no-undo .
  define buffer buf_temp-tables  for temp-tables.
  find first buf_temp-tables where
           buf_temp-tables.tbl-name = p-tbl-name no-error .
  if not available buf_temp-tables then do:
    create temp-table tth.
    assign
    tt-name = "wt-" + p-tbl-name
    tth:undo = no
    v-full-tbl-name = substitute( "ub.&1":U, p-tbl-name )
    .
    v-ok = yes.
    assign
    v-ok = tth:create-like( v-full-tbl-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_get-buffer-handle). Ошибка при создании временной таблицы &2 (1)", vss-include-info14, tt-name ) .
    end.
    assign
      v-ok = tth:temp-table-prepare( tt-name ) no-error
    .
    if v-ok <> true then do:
      return error substitute( "&1 (tempcont_get-buffer-handle). Ошибка при создании временной таблицы &2 (2)", vss-include-info14, tt-name ) .
    end.
    create buf_temp-tables.
    assign
    buf_temp-tables.new-table-handle = tth
    buf_temp-tables.tbl-name = p-tbl-name
    buf_temp-tables.new-tbl-handle = tth:default-buffer-handle
    .
  end.
  p-new-tbl-handle = buf_temp-tables.new-tbl-handle.
end.
end procedure.
procedure tempcont_clear :
define buffer buf_temp-tables for temp-tables.
do
on error undo, return error return-value
:
  for each buf_temp-tables:
    if valid-handle(buf_temp-tables.new-table-handle) then do:
      buf_temp-tables.new-tbl-handle:empty-temp-table().
    end.
    delete object buf_temp-tables.new-table-handle.
  end.
end.
end procedure.
define variable v-curr-r-b as character no-undo .
define buffer sourced_dis-card for ub.dis-card.
define buffer main_dis-card for ub.dis-card.
define variable v-is-copy as logical no-undo .
define variable v-is-sourced as logical no-undo .
define variable v-is-subsid as logical no-undo .
define variable v-tab-order as character no-undo .
define variable v-update-property as logical no-undo .
define variable v-found-copy-prop as logical no-undo .
define variable v-can-edit as logical no-undo .
define variable v-is-dct-client as logical no-undo .
define variable v-initial-type as character no-undo .
define variable v-initial-emitent-host-code as integer no-undo .
DEFINE BUFFER cli-buf FOR ub.clients.
DEFINE BUFFER shop-buf FOR ub.shop.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-long
     LABEL "Номера"
     SIZE 10 BY 1.
DEFINE BUTTON B-ltype
     LABEL "Тип карты"
     SIZE 10 BY 1.
DEFINE BUTTON b-prop
     LABEL "&Свойства"
     SIZE 10 BY 1.
DEFINE BUTTON b-quit
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-scard
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-shop
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 2"
     SIZE 3 BY 1.
DEFINE BUTTON B-type
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE VARIABLE emitent-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 32.3 BY 1 NO-UNDO.
DEFINE VARIABLE issue-code-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 32.4 BY 1 NO-UNDO.
DEFINE VARIABLE var-r-b-abbr AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE v-pcnt-method AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1",
"Item 2", "2",
"Item 3", "3"
     SIZE 45.3 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 3.27.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 3.13.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 96.5 BY 9.5.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 78.5 BY 1.43.
DEFINE VARIABLE T-overissue AS LOGICAL INITIAL no
     LABEL "Перевыпуск"
     VIEW-AS TOGGLE-BOX
     SIZE 15.2 BY .93 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      temp-dis-card SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-prop AT ROW 1 COL 41 WIDGET-ID 2
     B-ltype AT ROW 1 COL 51
     b-long AT ROW 1 COL 61
     B-hist AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     B-type AT ROW 2.63 COL 34.8
     temp-dis-card.d-card AT ROW 5.43 COL 15.3 COLON-ALIGNED
          LABEL "Номер карты"
          VIEW-AS FILL-IN
          SIZE 20 BY 1
          FGCOLOR 4
     temp-dis-card.is-subsid AT ROW 5.43 COL 61
          LABEL "Дополн. карта"
          VIEW-AS TOGGLE-BOX
          SIZE 16.5 BY .93
     T-overissue AT ROW 5.5 COL 38
     B-scard AT ROW 6.87 COL 39
     temp-dis-card.d-pcnt AT ROW 8.13 COL 20 COLON-ALIGNED
          LABEL "% скидки на товар"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
          FGCOLOR 4
     temp-dis-card.cash-d-pcnt AT ROW 9.3 COL 20 COLON-ALIGNED
          LABEL "% скидки на итог"
          VIEW-AS FILL-IN
          SIZE 7 BY 1
          FGCOLOR 4
     temp-dis-card.category AT ROW 9.3 COL 48.5 COLON-ALIGNED
          LABEL "Категория" FORMAT ">>>9"
          VIEW-AS FILL-IN
          SIZE 5 BY 1
          FGCOLOR 4
     v-pcnt-method AT ROW 10.47 COL 24 NO-LABEL
     temp-dis-card.credit-card AT ROW 12.13 COL 3
          LABEL "Кредитная карта"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY 1
     temp-dis-card.debet-card AT ROW 12.13 COL 38.5
          LABEL "Дебетовая карта"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY 1
     temp-dis-card.staff-card AT ROW 12.13 COL 60.5
          LABEL "Карта персонала"
          VIEW-AS TOGGLE-BOX
          SIZE 18.5 BY 1
     temp-dis-card.lim-kr AT ROW 13.53 COL 15.5 COLON-ALIGNED
          LABEL "Лимит кредита"
          VIEW-AS FILL-IN
          SIZE 19.6 BY .93
     temp-dis-card.issue-date AT ROW 15.4 COL 15.5 COLON-ALIGNED
          LABEL "Дата выдачи"
          VIEW-AS FILL-IN
          SIZE 11.3 BY 1.03
     temp-dis-card.valid-from AT ROW 15.4 COL 46.5 COLON-ALIGNED WIDGET-ID 4
          LABEL "Действует с"
          VIEW-AS FILL-IN
          SIZE 12.6 BY .97
     temp-dis-card.valid-date AT ROW 15.4 COL 75.1 COLON-ALIGNED
          LABEL "Действует до"
          VIEW-AS FILL-IN
          SIZE 12.6 BY .97
     temp-dis-card.issue-code AT ROW 16.83 COL 15.8 COLON-ALIGNED
          LABEL "Выдал магазин"
          VIEW-AS FILL-IN
          SIZE 6.6 BY .93
     B-shop AT ROW 16.83 COL 32.9
     temp-dis-card.cli-message AT ROW 18.63 COL 2.5
          LABEL "Сообщ. для клиента(POS MAGIA)"
          VIEW-AS FILL-IN
          SIZE 45.5 BY 1
     temp-dis-card.first-main-card AT ROW 2.6 COL 74 COLON-ALIGNED
          LABEL "Первичная основная карта"
           VIEW-AS TEXT
          SIZE 20 BY .67
          FGCOLOR 4
     temp-dis-card.type AT ROW 2.67 COL 15.4 COLON-ALIGNED
          LABEL "Тип карты"
           VIEW-AS TEXT
          SIZE 15.1 BY 1 TOOLTIP "Тип карты"
          FGCOLOR 4
     temp-dis-card.first-card AT ROW 3.93 COL 73.5 COLON-ALIGNED
          LABEL "Первичная карта"
           VIEW-AS TEXT
          SIZE 20.5 BY .67
          FGCOLOR 9
     temp-dis-card.emitent-host-code AT ROW 4.03 COL 15.3 COLON-ALIGNED
          LABEL "Эмитент"
                  FORMAT ">>>>>>>>99"
           VIEW-AS TEXT
          SIZE 7.1 BY 1
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME Dialog-Frame
     emitent-name AT ROW 4.17 COL 20.8 COLON-ALIGNED NO-LABEL
     temp-dis-card.sourced-card AT ROW 6.87 COL 15.5 COLON-ALIGNED
          LABEL "К карте"
           VIEW-AS TEXT
          SIZE 20 BY .67
     temp-dis-card.main-card AT ROW 6.87 COL 64.5 COLON-ALIGNED
          LABEL "Основная"
           VIEW-AS TEXT
          SIZE 25.5 BY .67
          FGCOLOR 4
     var-r-b-abbr AT ROW 13.53 COL 38 COLON-ALIGNED NO-LABEL
     issue-code-name AT ROW 16.83 COL 34.9 COLON-ALIGNED NO-LABEL
     "Использовать скидку" VIEW-AS TEXT
          SIZE 20.9 BY .93 AT ROW 10.47 COL 2.5
     RECT-1 AT ROW 11.67 COL 2
     RECT-2 AT ROW 15.03 COL 2
     RECT-3 AT ROW 2.17 COL 2
     RECT-4 AT ROW 18.37 COL 2
     SPACE(18.29) SKIP(0.02)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дисконтная карта".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-scard:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       temp-dis-card.main-card:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       temp-dis-card.sourced-card:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
   RUN check-update-prop IN THIS-PROCEDURE ( input yes) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
   dc-ri = ?.
   run perproc-delete-from-parent (  input this-procedure , input "").
   APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  run check-update-prop in this-procedure ( input no) .
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  run perproc-delete-from-parent( input this-procedure , input "").
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
    DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.
      run ref/cdchist.w (
                    INPUT parparentproc
                    ,input parhost-code
                    ,input parobj-type
                    ,input parobj-code
                    ,input "":U
                    ,input "one":U
                    ,input temp-dis-card.d-card
                    ,input temp-dis-card.card-num
                    ,input parobj-type
                    ,input parobj-code
                    ,input parhost-code
                    ,input ?
                    ,input "":U
                    ,input "":U
                    ,input ?
                    ,input-output v-list
                 ) no-error .
END.
ON CHOOSE OF b-long IN FRAME Dialog-Frame
DO:
  if not available temp-dis-card then return no-apply.
  run proc-b-long in this-procedure no-error.
END.
ON CHOOSE OF B-ltype IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-ri AS RECID NO-UNDO.
  DEFINE BUFFER buf_dis-card-type FOR ub.dis-card-type.
  IF AVAILABLE temp-dis-card THEN DO:
      FIND FIRST buf_dis-card-type NO-LOCK WHERE
                buf_dis-card-type.emitent-host-code = input frame Dialog-Frame temp-dis-card.emitent-host-code
          AND buf_dis-card-type.TYPE = input frame Dialog-Frame  temp-dis-card.TYPE
          AND buf_dis-card-type.host-code = 0
          AND buf_dis-card-type.obj-TYPE = "":U
          AND buf_dis-card-type.obj-code = 0
          NO-ERROR.
    IF AVAILABLE buf_dis-card-type  THEN DO:
        ASSIGN
            v-ri = RECID(buf_dis-card-type)
            .
        run ref/dc-typei.w (
                        input parparentproc
                      , input 'ПРОСМОТР':U
                      , input parhost-code
                      , input parobj-type
                      , input parobj-code
                      , INPUT-OUTPUT v-ri ) NO-ERROR.
    END.
  END.
END.
ON CHOOSE OF b-prop IN FRAME Dialog-Frame
DO:
    if not available temp-dis-card then return no-apply.
    run proc-b-prop in this-procedure no-error.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
  RUN check-update-prop IN THIS-PROCEDURE ( input yes) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
   dc-ri = ?.
   run perproc-delete-from-parent ( input this-procedure , input "").
   apply "go" to frame Dialog-Frame.
END.
ON CHOOSE OF B-scard IN FRAME Dialog-Frame
DO:
 run proc-b-scard in this-procedure no-error.
 if error-status:error then return no-apply.
END.
ON CHOOSE OF B-shop IN FRAME Dialog-Frame
DO:
 RUN local-shop-chk ("issue-code", "button").
  apply "entry" to temp-dis-card.issue-code in FRAME Dialog-Frame.
  return no-apply.
END.
ON CHOOSE OF B-type IN FRAME Dialog-Frame
DO:
 run proc-b-type in this-procedure no-error.
 if error-status:error then return no-apply.
END.
ON VALUE-CHANGED OF temp-dis-card.credit-card IN FRAME Dialog-Frame
DO:
  run enable-lim-kr in this-procedure.
END.
ON VALUE-CHANGED OF temp-dis-card.is-subsid IN FRAME Dialog-Frame
DO:
  ASSIGN t-overissue.
  CASE t-overissue:
    when yes then do:
        VIEW
        temp-dis-card.sourced-card
        In frame Dialog-Frame.
        DISPLAY
        b-scard
        with frame Dialog-Frame.
        ENABLE
        b-scard
        with frame Dialog-Frame.
    end.
    when no then do:
        DISABLE
        b-scard
        temp-dis-card.sourced-card
        with frame Dialog-Frame.
        HIDE
        b-scard
        temp-dis-card.sourced-card
        in frame Dialog-Frame.
    end.
  END CASE.
END.
ON LEAVE OF temp-dis-card.issue-code IN FRAME Dialog-Frame
DO:
    if input frame Dialog-Frame temp-dis-card.issue-code <> temp-dis-card.issue-code then do:
    run local-shop-chk ("issue-code", "leave-message").
  end.
END.
ON RETURN OF temp-dis-card.issue-code IN FRAME Dialog-Frame
DO:
    run local-shop-chk ("issue-code", "ret-mouse").
  apply "entry" to temp-dis-card.issue-code in frame Dialog-Frame.
  return no-apply.
END.
ON VALUE-CHANGED OF T-overissue IN FRAME Dialog-Frame
DO:
  ASSIGN t-overissue.
  CASE t-overissue:
    when yes then do:
        VIEW
        temp-dis-card.sourced-card
        In frame Dialog-Frame.
        DISPLAY
        b-scard
        with frame Dialog-Frame.
        ENABLE
        b-scard
        with frame Dialog-Frame.
    end.
    when no then do:
        DISABLE
        b-scard
        temp-dis-card.sourced-card
        with frame Dialog-Frame.
        HIDE
        b-scard
        temp-dis-card.sourced-card
        in frame Dialog-Frame.
    end.
  END CASE.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of temp-dis-card.issue-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of temp-dis-card.issue-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of temp-dis-card.issue-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of temp-dis-card.issue-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of temp-dis-card.issue-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of temp-dis-card.issue-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date19
    MENU-ITEM m-ed-date19-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date19-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date19-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date19-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if temp-dis-card.issue-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      temp-dis-card.issue-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date19 :HANDLE
      temp-dis-card.issue-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle19 as handle no-undo .
  assign
    v-label-handle19 = temp-dis-card.issue-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle19)
  then do:
    if v-label-handle19 :tooltip = ""
    or v-label-handle19 :tooltip = ?
    then do:
      assign
        v-label-handle19 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date19-1 in menu m-ed-date19 DO:
    apply "ctrl-b":U to temp-dis-card.issue-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-2 in menu m-ed-date19 DO:
    apply "ctrl-d":U to temp-dis-card.issue-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-3 in menu m-ed-date19 DO:
    apply "ctrl-e":U to temp-dis-card.issue-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date19-4 in menu m-ed-date19 DO:
    apply "ctrl-f":U to temp-dis-card.issue-date in frame Dialog-Frame .
  END.
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of temp-dis-card.valid-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of temp-dis-card.valid-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of temp-dis-card.valid-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of temp-dis-card.valid-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of temp-dis-card.valid-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of temp-dis-card.valid-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date21
    MENU-ITEM m-ed-date21-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date21-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date21-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date21-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if temp-dis-card.valid-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      temp-dis-card.valid-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date21 :HANDLE
      temp-dis-card.valid-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle21 as handle no-undo .
  assign
    v-label-handle21 = temp-dis-card.valid-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle21)
  then do:
    if v-label-handle21 :tooltip = ""
    or v-label-handle21 :tooltip = ?
    then do:
      assign
        v-label-handle21 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date21-1 in menu m-ed-date21 DO:
    apply "ctrl-b":U to temp-dis-card.valid-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-2 in menu m-ed-date21 DO:
    apply "ctrl-d":U to temp-dis-card.valid-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-3 in menu m-ed-date21 DO:
    apply "ctrl-e":U to temp-dis-card.valid-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date21-4 in menu m-ed-date21 DO:
    apply "ctrl-f":U to temp-dis-card.valid-date in frame Dialog-Frame .
  END.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of temp-dis-card.valid-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of temp-dis-card.valid-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of temp-dis-card.valid-from in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of temp-dis-card.valid-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of temp-dis-card.valid-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of temp-dis-card.valid-from in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date23
    MENU-ITEM m-ed-date23-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date23-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date23-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date23-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if temp-dis-card.valid-from :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      temp-dis-card.valid-from :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date23 :HANDLE
      temp-dis-card.valid-from :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle23 as handle no-undo .
  assign
    v-label-handle23 = temp-dis-card.valid-from :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle23)
  then do:
    if v-label-handle23 :tooltip = ""
    or v-label-handle23 :tooltip = ?
    then do:
      assign
        v-label-handle23 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date23-1 in menu m-ed-date23 DO:
    apply "ctrl-b":U to temp-dis-card.valid-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-2 in menu m-ed-date23 DO:
    apply "ctrl-d":U to temp-dis-card.valid-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-3 in menu m-ed-date23 DO:
    apply "ctrl-e":U to temp-dis-card.valid-from in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date23-4 in menu m-ed-date23 DO:
    apply "ctrl-f":U to temp-dis-card.valid-from in frame Dialog-Frame .
  END.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if ref-mode <> 'ИЗМЕНЕНИЕ':U
  and ref-mode <> 'ДОБАВЛЕНИЕ':U
  and ref-mode <> 'КОПИРОВАНИЕ':U
  and ref-mode <> 'ПРОСМОТР':U
  and ref-mode <> ('ИЗМЕНЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U)
  and ref-mode <> ('ДОБАВЛЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U)
  and ref-mode <> '@client':U
  then do:
    message vss-workfile vss-revision vss-description skip
                "Неверный параметр вызова ref-mode"
    view-as alert-box ERROR.
    return error.
  end.
  if paremitent-host-code < 0 or paremitent-host-code = ? then do:
    message vss-workfile vss-revision vss-description skip
                "Неверный параметр вызова paremitent-host-code"
    view-as alert-box ERROR.
    return error.
  end.
  for each temp-dis-card:
    delete temp-dis-card.
  end.
  for each temp-labels:
    delete temp-labels.
  end.
  for each temp-changes:
     delete temp-changes.
  end.
  if ref-mode = ('ИЗМЕНЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U) then do:
    assign
    v-is-sourced = yes
    ref-mode  = 'ДОБАВЛЕНИЕ':U
    .
  end.
  if ref-mode = ('ДОБАВЛЕНИЕ':U + chr(44) + 'КОПИРОВАНИЕ':U) then do:
    assign
    v-is-subsid = yes
    ref-mode  = 'ДОБАВЛЕНИЕ':U
    .
  end.
  if ref-mode = 'КОПИРОВАНИЕ':U then do:
    assign
    v-is-copy = yes
    ref-mode  = 'ДОБАВЛЕНИЕ':U
    .
  end.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  RUN fill-tables IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN DO:
    undo main-block, return error .
  END.
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI in this-procedure .
PROCEDURE check-update-prop :
define input parameter p-exit-without-save as logical no-undo .
DEFINE VARIABLE glog AS LOGICAL NO-UNDO.
define variable v-updated as logical no-undo .
define variable v-created as logical no-undo .
define variable v-deleted as logical no-undo .
define variable v-updated-str as character no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
if ref-mode <> 'ДОБАВЛЕНИЕ':U then do:
  if v-update-property then do:
    for each tt0-dis-card-property NO-LOCK where
            tt0-dis-card-property.d-card = ub.dis-card.d-card:
      if tt0-dis-card-property.dt-code = 0
      and tt0-dis-card-property.node-code = 0
      then next.
      find first buf_dis-card-property NO-LOCK WHERE
              buf_dis-card-property.d-card = tt0-dis-card-property.d-card
        AND   buf_dis-card-property.host-code = tt0-dis-card-property.host-code
        AND   buf_dis-card-property.obj-type = tt0-dis-card-property.obj-type
        AND   buf_dis-card-property.obj-code = tt0-dis-card-property.obj-code
        AND   buf_dis-card-property.dt-code = tt0-dis-card-property.dt-code
        AND   buf_dis-card-property.node-code = tt0-dis-card-property.node-code
        no-error.
      assign
      v-updated = no.
      if available  buf_dis-card-property then do:
        v-updated-str = "":U.
        BUFFER-COMPARE tt0-dis-card-property
                    TO buf_dis-card-property
                    case-sensitive
                    SAVE result IN v-updated-str.
        assign
        v-created = yes
        v-updated = (v-updated-str <> "":U)
        .
      end.
      else do:
        assign
        v-updated = yes.
      end.
      ASSIGN
      v-update-property = (v-update-property or v-updated).
    End.
    FOR EACH buf_dis-card-property where
            buf_dis-card-property.d-card = dis-card.d-card
            :
      if buf_dis-card-property.dt-code = 0
      and buf_dis-card-property.node-code = 0
      then next.
      FIND FIRST tt0-dis-card-property NO-LOCK WHERE
                tt0-dis-card-property.d-card   = buf_dis-card-property.d-card
            AND tt0-dis-card-property.host-code = buf_dis-card-property.host-code
            AND tt0-dis-card-property.obj-type = buf_dis-card-property.obj-type
            AND tt0-dis-card-property.obj-code = buf_dis-card-property.obj-code
            AND tt0-dis-card-property.dt-code = buf_dis-card-property.dt-code
            and tt0-dis-card-property.node-code = buf_dis-card-property.node-code   NO-ERROR.
        IF NOT AVAILABLE tt0-dis-card-property THEN DO:
          assign
          v-deleted = yes.
          ASSIGN
          v-update-property = (v-deleted OR v-update-property).
        END.
    END.
  end.
end.
if (v-is-sourced or v-is-copy or v-is-subsid) and v-found-copy-prop then v-update-property = yes.
if ref-mode = 'ДОБАВЛЕНИЕ':U then return.
if not p-exit-without-save then return.
IF v-update-property THEN DO:
    MESSAGE
    substitute("Были изменены свойства ДК &1&2"
              ,(if v-found-copy-prop then " или были унаследованы свойства ДК" else "":U)
              , chr(10)
              )
    "Сделанные изменения будут отменены" skip
    "Продолжить?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF NOT glog  THEN RETURN error.
END.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-r-b-abbr :
define variable v-curr-r-b  as character no-undo .
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  ) no-error .
if paremitent-host-code = 0
and v-curr-r-b = 'base':U
then do:
  var-r-b-abbr = ?.
end.
else do:
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-abbr in g#library
  (input  paremitent-host-code
  ,output var-r-b-abbr
  ) no-error .
end.
display var-r-b-abbr
with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE enable-lim-kr :
if temp-dis-card.credit-card:screen-value in frame Dialog-Frame = "yes" and ref-mode <> 'ПРОСМОТР':U
THEN DO:
    enable
    temp-dis-card.lim-kr with frame Dialog-Frame.
    DISABLE
    temp-dis-card.debet-card
    with frame Dialog-Frame.
END.
ELSE DO:
    disable
    temp-dis-card.lim-kr with frame Dialog-Frame.
    IF ref-mode <> 'ПРОСМОТР':U THEN
    ENABLE
    temp-dis-card.debet-card
    with frame Dialog-Frame.
END.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH temp-dis-card SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY T-overissue v-pcnt-method emitent-name var-r-b-abbr issue-code-name
      WITH FRAME Dialog-Frame.
  IF AVAILABLE temp-dis-card THEN
    DISPLAY temp-dis-card.d-card temp-dis-card.is-subsid temp-dis-card.d-pcnt
          temp-dis-card.cash-d-pcnt temp-dis-card.category
          temp-dis-card.credit-card temp-dis-card.debet-card
          temp-dis-card.staff-card temp-dis-card.lim-kr temp-dis-card.issue-date
          temp-dis-card.valid-from temp-dis-card.valid-date
          temp-dis-card.issue-code temp-dis-card.cli-message
          temp-dis-card.first-main-card temp-dis-card.type
          temp-dis-card.first-card temp-dis-card.emitent-host-code
          temp-dis-card.main-card
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-1 RECT-2 RECT-3 RECT-4 b-quit b-prop B-ltype b-long B-hist
         B-Help B-type temp-dis-card.d-card T-overissue B-scard
         temp-dis-card.d-pcnt temp-dis-card.cash-d-pcnt temp-dis-card.category
         v-pcnt-method temp-dis-card.credit-card temp-dis-card.debet-card
         temp-dis-card.staff-card temp-dis-card.lim-kr temp-dis-card.issue-date
         temp-dis-card.valid-from temp-dis-card.valid-date
         temp-dis-card.issue-code B-shop temp-dis-card.cli-message
         temp-dis-card.type temp-dis-card.first-card
         temp-dis-card.emitent-host-code emitent-name var-r-b-abbr
         issue-code-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-tables :
define variable varalien-str as character no-undo .
define variable v-type as character no-undo .
define variable v-exist as logical no-undo .
define variable v-proc-handle as handle no-undo .
define variable v-id as integer no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
FOR EACH tt0-dis-card-property:
    DELETE tt0-dis-card-property.
END.
FOR EACH temp-dis-card:
    DELETE temp-dis-card.
END.
if ref-mode = '@client':U then do:
  find first buf_dis-card-type no-lock where
            buf_dis-card-type.type = '@client':U
        and buf_dis-card-type.emitent-host-code = 0 no-error.
  if not available buf_Dis-card-type then do:
    message
    substitute("В Вашей системе невозможно работать с картами типа КЛИЕНТ-СЧЕТ&1" +
               "Отсутствует специальный тип карты КЛИЕНТ-СЧЕТ"
               , chr(10))
    view-as alert-box error .
    undo, return error .
  end.
  FIND ub.clients WHERE recid( ub.clients ) = cli-ri NO-LOCK.
  if not avail ub.clients then do:
    dc-ri = ?.
    undo, return error.
  end.
  if ub.clients.obj-type = 'маг':U OR ub.clients.obj-type = 'скл':U then do:
    dc-ri = ?.
    message
    substitute("Дисконтныe карты выдаются&1"  +
               "только внешним контрагентам"
               , chr(10))
    view-as alert-box error.
    undo, return error.
  end.
  find first ub.dis-card no-lock where
           ub.dis-card.d-card = ('K':U + string(if clients.obj-type = 'орг':U then 1 else 0) + string(clients.obj-code, '999999999')) no-error .
  if not available ub.dis-card then do:
    assign
    v-is-dct-client = yes
    ref-mode = 'ДОБАВЛЕНИЕ':U
    .
  end.
  else do:
    find first ub.dis-card exclusive-lock where
            ub.dis-card.d-card = ('K':U + string(if clients.obj-type = 'орг':U then 1 else 0) + string(clients.obj-code, '999999999')) no-error .
    if locked ub.dis-card then do:
      message vss-workfile vss-revision vss-description skip
              "Запись дисконтной карты занята"
      view-as alert-box error .
      return error.
    end.
    assign
    v-is-dct-client = yes
    ref-mode = 'ИЗМЕНЕНИЕ':U
    dc-ri = recid(dis-card)
    .
  end.
end.
  CASE ref-mode:
    when 'ИЗМЕНЕНИЕ':U then do:
      find first dis-card exclusive-lock where
                recid(dis-card) = dc-ri no-wait no-error.
      if locked dis-card then do:
        message vss-workfile vss-revision vss-description skip
                "Запись дисконтной карты занята"
        view-as alert-box error .
        return error.
      end.
      if not available dis-card then do:
        message vss-workfile vss-revision vss-description skip
                "Запись дисконтной карты не найдена"
        view-as alert-box error .
        return error.
      end.
      find first clients No-LOCK WHERE
                 clients.obj-type = dis-card.cli-type AND
                 clients.obj-code = dis-card.cli-code no-error .
      if not avail clients then do:
        message vss-workfile vss-revision vss-description skip
                "Запись клиента дисконтной карты не найдена"
        view-as alert-box error .
        return error.
      end.
      create temp-dis-card.
      buffer-copy dis-card to temp-dis-card.
      assign
      v-initial-type = temp-dis-card.type
      v-initial-emitent-host-code = temp-dis-card.emitent-host-code
      .
    end.
    when 'ПРОСМОТР':U then do:
      find first dis-card No-LOCK where recid(dis-card) = dc-ri no-error.
      if not available dis-card then do:
        message vss-workfile vss-revision vss-description skip
                "Запись дисконтной карты не найдена"
        view-as alert-box error .
        return error.
      end.
      find first clients No-LOCK WHERE
                 clients.obj-type = dis-card.cli-type AND
                 clients.obj-code = dis-card.cli-code no-error .
      if not avail clients then do:
        message vss-workfile vss-revision vss-description skip
                "Запись клиента дисконтной карты не найдена"
        view-as alert-box error .
        return error.
      end.
      create temp-dis-card.
      buffer-copy dis-card to temp-dis-card.
    end.
    when 'ДОБАВЛЕНИЕ':U then do:
      if v-is-copy then do:
        find first dis-card No-LOCK where recid(dis-card) = dc-ri no-error.
        if not available dis-card then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись дисконтной карты для копирования не найдена"
          view-as alert-box error .
          return error.
        end.
        if dis-card.type = '@client':U then do:
          message vss-workfile vss-revision vss-description skip
          "Нельзя копировать карту типа КЛИЕНТ-СЧЕТ"
          view-as alert-box error .
          return error.
        end.
        create temp-dis-card.
        if v-is-copy and dis-card.mask-card = yes then
        buffer-copy dis-card
        except cli-type cli-code issue-date sourced-card issue-code valid-from valid-date saldo-base saldo-rubl mask-card
        first-card first-main-card main-card is-subsid overissue-num
        to temp-dis-card.
        else
        buffer-copy dis-card
        except cli-type cli-code d-card issue-date sourced-card issue-code valid-from valid-date saldo-base saldo-rubl mask-card
        first-card first-main-card main-card is-subsid overissue-num
        to temp-dis-card.
      end.
      if v-is-subsid then do:
        find first main_dis-card exclusive-lock where
                  recid(main_dis-card) = dc-ri no-wait no-error.
        if locked main_dis-card then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись основной дисконтной карты занята"
          view-as alert-box error .
          return error.
        end.
        if not available main_dis-card then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись основной дисконтной карты не найдена"
          view-as alert-box error .
          return error.
        end.
        if main_dis-card.mask-card then do:
          message vss-workfile vss-revision vss-description skip
          "Нельзя выпускать дополнительную карту к карте-маске"
          view-as alert-box error .
          return error.
        end.
        if main_dis-card.type = '@client':U then do:
          message vss-workfile vss-revision vss-description skip
          "Нельзя выпускать дополнительную карту к карте типа КЛИЕНТ-СЧЕТ"
          view-as alert-box error .
          return error.
        end.
        find first clients No-LOCK WHERE
                  clients.obj-type = main_dis-card.cli-type AND
                  clients.obj-code = main_dis-card.cli-code no-error .
        if not avail clients then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись клиента основной дисконтной карты не найдена"
          view-as alert-box error .
          return error.
        end.
        create temp-dis-card.
        buffer-copy main_dis-card except d-card cli-type cli-code
        issue-date issue-code valid-from valid-date sourced-card saldo-base saldo-rubl
        to temp-dis-card
        assign
        temp-dis-card.main-card = main_dis-card.d-card
        temp-dis-card.is-subsid = yes
        .
      end.
      if v-is-sourced then do:
        find first sourced_dis-card exclusive-lock where
                  recid(sourced_dis-card) = dc-ri no-wait no-error.
        if locked sourced_dis-card then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись перевыпускаемой дисконтной карты занята"
          view-as alert-box error .
          return error.
        end.
        if not available sourced_dis-card then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись перевыпускаемой дисконтной карты не найдена"
          view-as alert-box error .
          return error.
        end.
        if sourced_dis-card.mask-card then do:
          message vss-workfile vss-revision vss-description skip
          "Нельзя перевыпускать карту-маску"
          view-as alert-box error .
          return error.
        end.
        if sourced_dis-card.type = '@client':U then do:
          message vss-workfile vss-revision vss-description skip
          "Нельзя перевыпускать карту типа КЛИЕНТ-СЧЕТ"
          view-as alert-box error .
          return error.
        end.
        find first clients No-LOCK WHERE
                  clients.obj-type = sourced_dis-card.cli-type AND
                  clients.obj-code = sourced_dis-card.cli-code no-error .
        if not avail clients then do:
          message vss-workfile vss-revision vss-description skip
                  "Запись клиента дисконтной карты не найдена"
          view-as alert-box error .
          return error.
        end.
        create temp-dis-card.
        buffer-copy sourced_dis-card except d-card
        issue-date issue-code valid-from valid-date sourced-card saldo-base saldo-rubl
        to temp-dis-card
        assign
        temp-dis-card.sourced-card = sourced_dis-card.d-card
        .
      end.
      if not v-is-sourced then do:
        FIND clients WHERE recid( clients ) = cli-ri NO-LOCK.
          if not avail clients then do:
            dc-ri = ?.
            return error.
          end.
          if clients.obj-type = 'маг':U OR clients.obj-type = 'скл':U then do:
            dc-ri = ?.
            message "Дисконтную карты выдаются" skip
                    "только внешним контрагентам"
            view-as alert-box error.
            return error.
          end.
        end.
        run clntattr-value in this-procedure (
                                              input clients.obj-type
                                              ,input  clients.obj-code
                                              ,input  'alien':U
                                              ,output varalien-str
                                              ,output v-type) no-error .
        if not error-status:error
        AND logical(varalien-str) = yes then do:
          message
          "Нельзя изменять выдать ДК ЧУЖОМУ клиенту/фирме"
          view-as alert-box error .
          undo, return error .
        end.
        if v-is-copy and available temp-dis-card then do:
          assign
          temp-dis-card.cli-type = clients.obj-type
          temp-dis-card.cli-code = clients.obj-code
          .
        end.
      if not avail temp-dis-card then create temp-dis-card.
      assign
      temp-dis-card.cli-type = clients.obj-type
      temp-dis-card.cli-code = clients.obj-code
      .
      if v-is-dct-client then do:
        assign
        temp-dis-card.type = buf_dis-card-type.type
        temp-dis-card.emitent-host-code = buf_dis-card-type.emitent-host-code
        temp-dis-card.d-card = ('K':U + string(if clients.obj-type = 'орг':U then 1 else 0) + string(clients.obj-code, '999999999'))
        .
      end.
    end.
  END CASE.
END PROCEDURE.
PROCEDURE local-shop-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "issue-code" and p-action = "ret-mouse" then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ref-rec28   as recid no-undo .
  find first cli-buf where
       cli-buf.obj-code = input frame Dialog-Frame temp-dis-card.issue-code
   and cli-buf.obj-type = 'маг':U  no-lock no-error.
  if not available cli-buf  then do:
    ref-list = string(v-ref-rec28).
    run adm/shops.w (
               input parparentproc
             , input "b-sel"
             , input-output ref-list
             , no).
    assign v-ref-rec28 = integer( ref-list ).
    find first shop-buf where
            recid (shop-buf) = v-ref-rec28  no-lock no-error.
    if available shop-buf then do:
      find first cli-buf no-lock where
                cli-buf.obj-type = 'маг':U
            and cli-buf.obj-code = shop-buf.obj-code .
    end.
    else do:
      release cli-buf.
    end.
    if not available shop-buf then do:
      find first cli-buf where
                cli-buf.obj-code = input frame Dialog-Frame temp-dis-card.issue-code
            and cli-buf.obj-type = 'маг':U
      no-lock no-error.
    end.
    if available cli-buf
    and temp-dis-card.emitent-host-code <> 0
    and cli-buf.host-code <> temp-dis-card.emitent-host-code then do:
      message
      substitute("Магазин должен принадлежать фирме с кодом &1", temp-dis-card.emitent-host-code)
      view-as alert-box error .
      find first cli-buf where
                cli-buf.obj-code = input frame Dialog-Frame temp-dis-card.issue-code
            and cli-buf.obj-type = 'маг':U
      no-lock no-error.
    end.
  end.
  if available cli-buf then do:
    display
    cli-buf.obj-code @ temp-dis-card.issue-code
    cli-buf.obj-name @ issue-code-name
    with frame Dialog-Frame.
    assign frame Dialog-Frame temp-dis-card.issue-code.
  end.
  else display ? @ temp-dis-card.issue-code
               ? @ issue-code-name with frame Dialog-Frame.
  apply "entry" to  b-exit  in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "issue-code" and p-action = "button" then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ref-rec29   as recid no-undo .
  find cli-buf where
       cli-buf.obj-code = input frame Dialog-Frame temp-dis-card.issue-code
    and cli-buf.obj-type = 'маг':U no-lock no-error.
  if available cli-buf then do:
    find first shop-buf where
            shop-buf.obj-code = cli-buf.obj-code  no-error .
  end.
  assign
  v-ref-rec29 = ( if available shop-buf then recid( shop-buf ) else ? ).
  release cli-buf.
  release shop-buf.
  if not available cli-buf  then do:
    ref-list = string(v-ref-rec29).
    run adm/shops.w (
               input parparentproc
             , input "b-sel"
             , input-output ref-list
             , no).
    assign v-ref-rec29 = integer( ref-list ).
    find first shop-buf where
            recid (shop-buf) = v-ref-rec29  no-lock no-error.
    if available shop-buf then do:
      find first cli-buf no-lock where
                cli-buf.obj-type = 'маг':U
            and cli-buf.obj-code = shop-buf.obj-code .
    end.
    else do:
      release cli-buf.
    end.
    if not available shop-buf then do:
      find first cli-buf where
                cli-buf.obj-code = input frame Dialog-Frame temp-dis-card.issue-code
            and cli-buf.obj-type = 'маг':U
      no-lock no-error.
    end.
    if available cli-buf
    and temp-dis-card.emitent-host-code <> 0
    and cli-buf.host-code <> temp-dis-card.emitent-host-code then do:
      message
      substitute("Магазин должен принадлежать фирме с кодом &1", temp-dis-card.emitent-host-code)
      view-as alert-box error .
      find first cli-buf where
                cli-buf.obj-code = input frame Dialog-Frame temp-dis-card.issue-code
            and cli-buf.obj-type = 'маг':U
      no-lock no-error.
    end.
  end.
  if available cli-buf then do:
    display
    cli-buf.obj-code @ temp-dis-card.issue-code
    cli-buf.obj-name @ issue-code-name
    with frame Dialog-Frame.
    assign frame Dialog-Frame temp-dis-card.issue-code.
  end.
  else display ? @ temp-dis-card.issue-code
               ? @ issue-code-name with frame Dialog-Frame.
  apply "entry" to  b-exit  in frame Dialog-Frame.
  return no-apply.
end.
if p-man = "issue-code" and p-action = "leave-message" then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ref-rec30   as recid no-undo .
  find first cli-buf where
       cli-buf.obj-code = input frame Dialog-Frame temp-dis-card.issue-code
   and cli-buf.obj-type = 'маг':U  no-lock no-error.
if available cli-buf then do:
    display
    cli-buf.obj-code @ temp-dis-card.issue-code
    cli-buf.obj-name @ issue-code-name
    with frame Dialog-Frame.
        assign frame Dialog-Frame temp-dis-card.issue-code.
end.
else do:
  display
  ? @ temp-dis-card.issue-code
  ? @ issue-code-name
  with frame Dialog-Frame.
end.
end.
END PROCEDURE.
PROCEDURE Myenable :
OPEN QUERY Dialog-Frame FOR EACH temp-dis-card SHARE-LOCK.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
assign
v-tab-order =
"b-quit,b-exit,b-prop,b-long,b-hist,b-ltype,b-help,b-type,":U +
"type,d-card,t-overissue,b-scard,d-pcnt,cash-d-pcnt,category,v-pcnt-method,credit-card,debet-card,staff-card,lim-kr,":U +
"valid-from,valid-date,issue-date,issue-code,b-shop,cli-message".
GET FIRST Dialog-Frame.
assign
v-pcnt-method:Radio-buttons in frame Dialog-Frame =
 "Товар" + chr(44) + string('1':U) + chr(44) +
 "Итог_чека" + chr(44) + string('2':U) + chr(44) +
 "Товары_и_итог_чека" + chr(44) + string('3':U)
v-pcnt-method = (if ref-mode = 'ДОБАВЛЕНИЕ':U and not (v-is-copy or v-is-sourced or v-is-subsid)
               then '1':U
               else string(temp-dis-card.d-pcnt-method))
.
DISPLAY emitent-name
WITH FRAME Dialog-Frame.
if avail temp-dis-card and temp-dis-card.sourced-card <> "" then
t-overissue = yes.
IF AVAILABLE temp-dis-card
THEN
DISPLAY
temp-dis-card.d-card
temp-dis-card.d-pcnt
temp-dis-card.cash-d-pcnt
temp-dis-card.category
temp-dis-card.issue-date
temp-dis-card.issue-code
temp-dis-card.category
temp-dis-card.credit-card
temp-dis-card.lim-kr
temp-dis-card.type
(IF temp-dis-card.cli-message = ? THEN "":U ELSE temp-dis-card.cli-message) temp-dis-card.cli-message
temp-dis-card.emitent-host-code
temp-dis-card.valid-from
temp-dis-card.valid-date
temp-dis-card.sourced-card
t-overissue
v-pcnt-method
WITH FRAME Dialog-Frame.
IF temp-dis-card.sourced-card <> '':U THEN DO:
  DISPLAY
  temp-dis-card.first-card
  WITH FRAME Dialog-Frame.
END.
ELSE DO:
  HIDE
  temp-dis-card.first-card
   IN FRAME Dialog-Frame.
END.
IF temp-dis-card.is-subsid THEN DO:
  DISPLAY
  temp-dis-card.is-subsid
  temp-dis-card.main-card
  WITH FRAME Dialog-Frame.
END.
ELSE DO:
  HIDE
  temp-dis-card.is-subsid
  temp-dis-card.main-card
  IN FRAME Dialog-Frame.
END.
IF temp-dis-card.sourced-card <> '':U
and temp-dis-card.is-subsid
THEN DO:
DISPLAY
temp-dis-card.first-main-card
WITH FRAME Dialog-Frame.
end.
else do:
hide
temp-dis-card.first-main-card
in FRAME Dialog-Frame.
end.
IF avail temp-dis-card then do:
if temp-dis-card.debet-card = ? THEN do:
  ASSIGN
  temp-dis-card.debet-card  = NO
  .
end.
DISPLAY
temp-dis-card.debet-card
WITH FRAME Dialog-Frame.
if ref-mode = 'ДОБАВЛЕНИЕ':U
and temp-dis-card.issue-code = 0
then do:
  temp-dis-card.issue-code = parobj-code.
end.
display
temp-dis-card.issue-code
with frame Dialog-Frame .
if not temp-dis-card.mask-card then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-ref-rec31   as recid no-undo .
  find first cli-buf where
       cli-buf.obj-code = input frame Dialog-Frame temp-dis-card.issue-code
   and cli-buf.obj-type = 'маг':U  no-lock no-error.
if not available cli-buf then do:
  if input frame Dialog-Frame temp-dis-card.issue-code <> ""
      and input frame Dialog-Frame temp-dis-card.issue-code <> ? then
    message "Из справочника магазинов Вы должны выбрать магазин.".
  display temp-dis-card.issue-code with frame Dialog-Frame.
  find first cli-buf no-lock where
            cli-buf.obj-code = input frame Dialog-Frame temp-dis-card.issue-code
       and cli-buf.obj-type = 'маг':U no-error.
end.
if available cli-buf then do:
    display
    cli-buf.obj-code @ temp-dis-card.issue-code
    cli-buf.obj-name @ issue-code-name
    with frame Dialog-Frame.
end.
else do:
  display
  ? @ temp-dis-card.issue-code
  ? @ issue-code-name
  with frame Dialog-Frame.
end.
end.
IF temp-dis-card.staff-card = ? THEN do:
      temp-dis-card.staff-card = NO.
END.
DISPLAY
temp-dis-card.staff-card
WITH FRAME Dialog-Frame.
end.
if ref-mode = 'ДОБАВЛЕНИЕ':U then do:
run cur-time in this-procedure ( output v-today, output v-time).
  display
  v-today @ temp-dis-card.issue-date
  parobj-code @ temp-dis-card.issue-code
  v-today @ temp-dis-card.valid-from
  WITH FRAME Dialog-Frame.
end.
assign
frame Dialog-Frame:title = frame Dialog-Frame:title + chr(58) + chr(32) + ub.clients.obj-name
.
ENABLE
B-exit when ref-mode <> 'ПРОСМОТР':U
b-quit
b-ltype WHEN (ref-mode <> 'ДОБАВЛЕНИЕ':U or v-is-sourced or v-is-subsid)
b-long
b-hist WHEN ref-mode <> 'ДОБАВЛЕНИЕ':U
B-Help
B-type when ref-mode <> 'ПРОСМОТР':U
t-overissue when (ref-mode = 'ДОБАВЛЕНИЕ':U and not v-is-copy and not v-is-sourced and not v-is-subsid)
temp-dis-card.d-card when ref-mode = 'ДОБАВЛЕНИЕ':U
temp-dis-card.d-pcnt when ref-mode <> 'ПРОСМОТР':U
temp-dis-card.cash-d-pcnt when ref-mode <> 'ПРОСМОТР':U
temp-dis-card.category when ref-mode <> 'ПРОСМОТР':U
temp-dis-card.issue-date when ref-mode <> 'ПРОСМОТР':U
temp-dis-card.issue-code when (ref-mode <> 'ПРОСМОТР':U and not temp-dis-card.mask-card)
temp-dis-card.valid-from  when ref-mode <> 'ПРОСМОТР':U
temp-dis-card.valid-date  when ref-mode <> 'ПРОСМОТР':U
B-shop when (ref-mode <> 'ПРОСМОТР':U and not temp-dis-card.mask-card)
temp-dis-card.credit-card when (paremitent-host-code <> 0 and
                              (ref-mode = 'ДОБАВЛЕНИЕ':U or
                               (ref-mode = 'ИЗМЕНЕНИЕ':U AND NOT temp-dis-card.credit-card)
                              )
                             ) and ref-mode <> 'ПРОСМОТР':U
temp-dis-card.debet-card WHEN    (ref-mode = 'ДОБАВЛЕНИЕ':U or
                               (ref-mode = 'ИЗМЕНЕНИЕ':U AND NOT temp-dis-card.credit-card))
temp-dis-card.staff-card when ref-mode <> 'ПРОСМОТР':U
temp-dis-card.cli-message when ref-mode <> 'ПРОСМОТР':U
b-prop
WITH FRAME Dialog-Frame.
if v-is-dct-client then do:
disable
B-type
t-overissue
temp-dis-card.d-card
with frame Dialog-Frame .
run proc-b-type in this-procedure .
display
temp-dis-card.d-card
with frame Dialog-Frame .
end.
CASE ref-mode:
when 'ПРОСМОТР':U then do:
  b-quit:label = "&Выход".
  Hide b-exit in frame Dialog-Frame.
  apply "entry" to b-quit.
end.
when 'ДОБАВЛЕНИЕ':U then do:
  if v-is-sourced then do:
    disable
    b-type
    temp-dis-card.emitent-host-code
    t-overissue
    with frame Dialog-Frame .
  end.
  if v-is-subsid then do:
    disable
    b-type
    temp-dis-card.emitent-host-code
    t-overissue
    with frame Dialog-Frame .
  end.
  APPLY "entry" to temp-dis-card.d-card.
end.
when 'ИЗМЕНЕНИЕ':U then do:
  APPLY "entry" to temp-dis-card.d-pcnt.
end.
END CASE.
hide
b-long in frame Dialog-Frame .
run enable-lim-kr in this-procedure.
run display-r-b-abbr in this-procedure no-error.
VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-b-long :
DEFINE VARIABLE v-updated-now AS LOGICAL NO-UNDO.
define variable v-proc-handle as handle no-undo .
define variable v-id as integer no-undo .
define buffer buf_dis-card-long for ub.dis-card-long.
message
"Функционал в разработке" view-as alert-box .
return.
END PROCEDURE.
PROCEDURE proc-b-prop :
define variable v-data-type as character no-undo .
define variable v-format as character no-undo .
define variable v-label as character no-undo .
define variable v-range as integer no-undo .
define variable v-rw-option as character no-undo .
DEFINE VARIABLE v-updated-now AS LOGICAL NO-UNDO.
define variable v-proc-handle as handle no-undo .
define variable v-id as integer no-undo .
define buffer buf_dis-card-property for ub.dis-card-property.
  do
  on error undo, return error
  :
assign frame Dialog-Frame
temp-dis-card.d-card
temp-dis-card.emitent-host-code
.
if ref-mode = 'ИЗМЕНЕНИЕ':U then do:
  do transaction
  on error undo, return error return-value
  on stop undo, return error return-value
  :
      Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card = temp-dis-card.d-card
          AND locked_dis-card-property.host-code = 0
          AND locked_dis-card-property.obj-type = '':U
          AND locked_dis-card-property.obj-code = 0
          and locked_dis-card-property.dt-code = 0
          and locked_dis-card-property.node-code = 0
          no-error no-wait.
      if not available locked_dis-card-property
      and not locked locked_dis-card-property then do:
        create locked_dis-card-property.
        assign
        locked_dis-card-property.host-code = 0
        locked_dis-card-property.obj-type =  '':U
        locked_dis-card-property.obj-code = 0
        locked_dis-card-property.d-card =  temp-dis-card.d-card
        locked_dis-card-property.dt-code = 0
        locked_dis-card-property.node-code = 0
        .
      end.
      if locked locked_dis-card-property then do:
      Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card =  temp-dis-card.d-card
          AND locked_dis-card-property.host-code = 0
          AND locked_dis-card-property.obj-type = '':U
          AND locked_dis-card-property.obj-code = 0
          and locked_dis-card-property.dt-code = 0
          and locked_dis-card-property.node-code = 0
          no-error .
      end.
      run trg/lock-dcp.p persistent set v-proc-handle (recid(locked_dis-card-property)) .
      run perproc-create-proc in this-procedure (
                                                 input  this-procedure
                                                ,input  "trg/lock-dcp.p"
                                                ,input  v-proc-handle
                                                ,input  no
                                                ,input  "":u
                                                ,input v-cntxt-userid
                                                ,input 0
                                                ,output v-id) .
  end.
end.
CASE ref-mode:
  WHEN 'ИЗМЕНЕНИЕ':U or
  when 'ПРОСМОТР':U
  THEN DO:
    if not v-update-property then do:
      FOR EACH buf_dis-card-property no-lock where
      buf_dis-card-property.d-card =  temp-dis-card.d-card :
      if buf_dis-card-property.dt-code = 0 then next.
        CREATE tt0-dis-card-property.
        BUFFER-COPY buf_dis-card-property TO tt0-dis-card-property.
      END.
    end.
  END.
  WHEN 'ДОБАВЛЕНИЕ':U THEN DO:
    if not v-update-property then do:
      FOR EACH buf_dis-card-property no-lock where
            buf_dis-card-property.d-card = (if v-is-copy
                                        then ub.dis-card.d-card
                                        else (if v-is-sourced
                                              then sourced_dis-card.d-card
                                              else main_dis-card.d-card))
                                              :
      if buf_dis-card-property.dt-code = 0 then next.
        run discprop-node-code in this-procedure (
                                            input buf_dis-card-property.dtm-code
                                           ,input buf_dis-card-property.dt-code
                                          ,output v-data-type
                                          ,output v-format
                                          ,output v-label
                                          ,output v-range
                                          ,output v-rw-option
                                          ).
        if error-status:error or lookup("C", v-rw-option) = 0  then next.
        assign
        v-found-copy-prop = yes.
        CREATE tt0-dis-card-property.
        BUFFER-COPY buf_dis-card-property EXCEPT d-card TO tt0-dis-card-property.
      end.
    END.
  END.
END CASE.
for each tt0-dis-card-property :
  assign
  tt0-dis-card-property.d-card            = temp-dis-card.d-card
  .
end.
run ref/discprpi.w (
                input parparentproc
              ,input ref-mode
              ,input temp-dis-card.d-card
              ,input temp-dis-card.emitent-host-code
              ,input temp-dis-card.type
              ,input parhost-code
              ,input parobj-type
              ,input parobj-code
              ,input no
              ,output v-updated-now
              ,input-output table tt0-dis-card-property
                ) no-error.
if error-status:error then do:
  return no-apply.
end.
ASSIGN
v-update-property = v-update-property OR v-updated-now
.
if v-update-property then do:
end.
else do:
  for each tt0-dis-card-property:
    delete tt0-dis-card-property.
  end.
end.
end.
end procedure.
PROCEDURE proc-b-scard :
define variable loc#log as logical no-undo.
define variable cli-list as character no-undo.
define buffer source_dis-card for ub.dis-card.
run ref/discards.w (
                     input parparentproc
                   ,input  "b-sel"
                   ,input  "client":U
                   ,input parhost-code
                   ,input parobj-type
                   ,input parobj-code
                   ,input '':U
                   ,input recid(ub.clients)
                   ,output cli-list ) .
if cli-list = "":U then return.
FIND FIRST source_dis-card no-lock where
                  recid(source_dis-card) = integer(cli-list).
if NOT
(    source_dis-card.cli-type = clients.obj-type and source_dis-card.cli-code = clients.obj-code) then do:
    message "Надо выбрать карту того же клиента"
    view-as alert-box error.
    return error.
end.
IF not (source_dis-card.emitent-host-code = paremitent-host-code) then do:
    message "Надо выбрать карту того же эмиттента"
    view-as alert-box error.
    return error.
end.
DISPLAY
source_dis-card.d-card @ temp-dis-card.sourced-card
with frame Dialog-Frame.
message
"Скопировать в новую карту параметры старой карты"
view-as alert-box QUESTION buttons YES-NO
update loc#log.
if loc#log then do:
  FIND FIRST ub.dis-card-type No-LOCK WHERE
                      ub.dis-card-type.type = source_dis-card.type AND
                      ub.dis-card-type.emitent-host-code = source_dis-card.emitent-host-code No-ERROR.
    if not available ub.dis-card-tYpe then do:
        message "Не найден тип дисконтной карты для карты" source_dis-card.d-card
        view-as alert-box error.
        return error.
    end.
    assign
    v-pcnt-method = string(source_dis-card.d-pcnt-method)
    .
    display
    dis-card-type.type @ temp-dis-card.type
    source_dis-card.d-pcnt @ temp-dis-card.d-pcnt
    source_dis-card.cash-d-pcnt @ temp-dis-card.cash-d-pcnt
    source_dis-card.category @ temp-dis-card.category
    v-pcnt-method
    with frame Dialog-Frame.
    temp-dis-card.credit-card:screen-value = string(dis-card-type.dflt-credit-card).
    run enable-lim-kr in this-procedure .
    if temp-dis-card.lim-kr:sensitive in frame Dialog-Frame then
    display
    source_dis-card.lim-kr @ temp-dis-card.lim-kr
    with frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE proc-b-type :
define variable v-rid-list as character no-undo.
define buffer b_clients for ub.clients.
DEFINE VARIABLE from-card as decimal no-undo.
DEFINE VARIABLE for-old as decimal no-undo .
DEFINE VARIABLE for-new as decimal no-undo .
DEFINE VARIABLE for-sum as decimal no-undo .
define variable choice as integer.
define variable v-ok as logical no-undo .
define variable v-d-pcnt as decimal no-undo .
define variable v-cash-d-pcnt as decimal no-undo .
define variable v-categ as integer no-undo .
define variable old-emitent-name as character no-undo .
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_temp-tables for temp-tables.
main-block:
do
on error undo, return error
:
  if avail temp-dis-card then do:
    FIND FIRST buf_dis-card-type NO-LOCK WHERE
              buf_dis-card-type.emitent-host-code = temp-dis-card.emitent-host-code AND
              buf_dis-card-type.host-code = 0 AND
              buf_dis-card-type.obj-type = "":U AND
              buf_dis-card-type.obj-code = 0 AND
              buf_dis-card-type.type = temp-dis-card.type No-ERROR.
    if not avail buf_dis-card-type then do:
    end.
    v-rid-list = string(recid(buf_dis-card-type)).
  end.
  if NOT V-IS-DCT-CLIENT then do:
    run ref/dc-types.w (
                     input parparentproc
                    ,input (if paremitent-host-code = 0 then 'все':U else 'фирма':U)
                    ,input "b-sel":U
                    ,input paremitent-host-code
                    ,input parhost-code
                    ,input parobj-type
                    ,input parobj-code
                    ,input-output v-rid-list) .
    if v-rid-list = ""
    or (available buf_dis-card-type and v-rid-list = string(recid(buf_dis-card-type)))
    then return no-apply.
    find first buf_dis-card-type no-lock where
              recid(buf_dis-card-type) = integer(v-rid-list) No-ERROR.
    if not avail buf_dis-card-type then return no-apply.
  end.
  old-emitent-name = emitent-name.
  if buf_dis-card-type.emitent-host-code = 0 then do:
    emitent-name = "Глобальная".
  end.
  else do:
    find first b_clients No-LOCK WHERE
                b_clients.obj-type = 'орг':U and
                b_clients.obj-code = buf_dis-card-type.emitent-host-code No-ERROR.
    if not avail buf_dis-card-type then return no-apply.
      emitent-name = b_clients.obj-name.
  end.
  display
  buf_dis-card-type.type @ temp-dis-card.type
  buf_dis-card-type.emitent-host-code @ temp-dis-card.emitent-host-code
  emitent-name
  with frame Dialog-Frame
  .
  if ref-mode = 'ДОБАВЛЕНИЕ':U then do:
      assign
      v-pcnt-method = string(buf_dis-card-type.dflt-d-pcnt-method)
      .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-pcnt':U
  ,output v-d-pcnt
  )  .
      if v-d-pcnt = ? then do:
        v-d-pcnt = 0.
      end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-cash-pcnt':U
  ,output v-cash-d-pcnt
  )  .
      if v-cash-d-pcnt = ? then do:
        v-cash-d-pcnt = 0.
      end.
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdpcnt in g#library
  (
   input  buf_dis-card-type.type
  ,input  buf_dis-card-type.emitent-host-code
  ,input  0
  ,input  '':U
  ,input  0
  ,input  'def-categ':U
  ,output v-categ
  )  .
      if v-categ = ? then do:
        v-categ = 0.
      end.
      display
      v-d-pcnt @ temp-dis-card.d-pcnt
      v-cash-d-pcnt @ temp-dis-card.cash-d-pcnt
      v-categ @ temp-dis-card.category
      v-pcnt-method
      with frame Dialog-Frame.
      ASSIGN
      temp-dis-card.credit-card:screen-value = string(buf_dis-card-type.dflt-credit-card)
      temp-dis-card.debet-card:SCREEN-VALUE  = string(buf_dis-card-type.dflt-debet-card)
      temp-dis-card.staff-card:SCREEN-VALUE  = string(buf_dis-card-type.dflt-staff-card)
      .
      run enable-lim-kr in this-procedure .
      if temp-dis-card.lim-kr:sensitive in frame Dialog-Frame then
      display
      buf_dis-card-type.lim-kr @ temp-dis-card.lim-kr
      with frame Dialog-Frame.
  end.
  if ref-mode = 'ИЗМЕНЕНИЕ':U then do:
    assign
    temp-dis-card.type = v-initial-type
    temp-dis-card.emitent-host-code = v-initial-emitent-host-code
    .
    run str/saledc.p
      (
       input parparentproc
      ,input this-procedure :handle
      ,input ?
      ,input 'one-card-check':U
      ,input buf_dis-card-type.emitent-host-code
      ,input buf_dis-card-type.type
      ,input 0
      ,input 0
      ,input 0
      ,input g#db-num
      ,input temp-dis-card.d-card
      ,input ?
      ,input ?
      ,input ?
      ,input 1
      ,input 1
      ,input no
      ) no-error .
    if error-status:error then do:
      display
      temp-dis-card.type
      temp-dis-card.emitent-host-code
      emitent-name
      with frame Dialog-Frame
      .
      undo main-block, return error return-value .
    end.
    find first buf_temp-tables where buf_temp-tables.tbl-name = 'dis-card':U no-error.
    if available buf_temp-tables then do:
      run ref/view-chg.w ( input parparentproc
                    ,input this-procedure:handle
                    ,input 'dis-card':U
                    ,input buffer temp-dis-card:handle
                    ,input buf_temp-tables.new-tbl-handle
                    ,input 'ИЗМЕНЕНИЕ':U + chr(44) + "available"
                    ,input 0
                    ,input substitute("Изменения в реквизитах карты, вызванные изменением типа карты &1"
                                      , temp-dis-card.d-card)
                    ,input "Текущие реквизиты карты"
                    ,input "Согласно новому типу карты должно быть"
                    ,input '':U
                    ,input substitute("Вы можете подтвердить или отвергнуть изменения,&1" +
                                      "однако после следующей операции пересчета&1" +
                                      "реквизиты карты будут изменены в соответствии с правилами,&1" +
                                      "установленными для ее текущего типа, если только карта не будет находится в статусе &2"
                                      , chr(10)
                                      , 'блок':U
                                      )
                    ,output v-ok
                    ) no-error .
      if error-status:error then do:
        display
        temp-dis-card.type
        temp-dis-card.emitent-host-code
        emitent-name
        with frame Dialog-Frame
        .
        message
        vss-workfile vss-revision vss-description skip
        error-status:get-message(1) skip
        return-value
        view-as alert-box error.
        undo, return error .
      end.
      if v-ok then do:
        for each temp-labels where temp-labels.f_update :
          if temp-labels.f_update then
          assign
          buffer temp-dis-card:handle:buffer-field(temp-labels.f_name):buffer-value = buf_temp-tables.new-tbl-handle:buffer-field(temp-labels.f_name):buffer-value
          .
        end.
        DISPLAY
        temp-dis-card.d-pcnt
        temp-dis-card.cash-d-pcnt
        temp-dis-card.category
        temp-dis-card.issue-date
        temp-dis-card.issue-code
        temp-dis-card.lim-kr
        (IF temp-dis-card.cli-message = ? THEN "":U ELSE temp-dis-card.cli-message) temp-dis-card.cli-message
        temp-dis-card.valid-date
        temp-dis-card.valid-from
        WITH FRAME Dialog-Frame.
      end.
    end.
    for each buf_temp-tables:
      if valid-handle(buf_temp-tables.new-table-handle) then do:
        delete object buf_temp-tables.new-table-handle.
      end.
      delete buf_temp-tables.
    end.
  end.
  assign
  temp-dis-card.type = buf_dis-card-type.type
  temp-dis-card.emitent-host-code = buf_dis-card-type.emitent-host-code
  .
  if buf_dis-card-type.type = '@client':U then do:
    disable
    t-overissue when t-overissue:sensitive
    temp-dis-card.d-card
    with frame Dialog-Frame.
    DISPLAY
    ('K':U + string(if temp-DIs-card.cli-type = 'орг':U then 1 else 0) + string(temp-dis-card.cli-code, '999999999')) @ TEMP-DIS-CARD.D-CARD
    with frame Dialog-Frame.
  end.
  ELSE DO:
    if input temp-dis-card.d-card = ('K':U + string(if temp-DIs-card.cli-type = 'орг':U then 1 else 0) + string(temp-dis-card.cli-code, '999999999')) then do:
      temp-dis-card.d-card:screen-value = ''.
    end.
  END.
end.
END PROCEDURE.
PROCEDURE proc-save :
define variable choice as integer no-undo .
define variable glog as logical no-undo .
define variable v-can-issue as logical no-undo .
define variable v-data-type as character no-undo .
define variable v-format as character no-undo .
define variable v-label as character no-undo .
define variable v-range as integer no-undo .
define variable v-rw-option as character no-undo .
define buffer source_dis-card for ub.dis-card.
define buffer buf_dis-card-property for ub.dis-card-property.
define buffer buf_attr-prop for ub.attr-prop.
assign
frame Dialog-Frame
temp-dis-card.type
temp-dis-card.d-card
.
if ref-mode = 'ДОБАВЛЕНИЕ':U
and not v-update-property then do:
  FOR EACH buf_dis-card-property no-lock where
        buf_dis-card-property.d-card = (if v-is-copy
                                    then ub.dis-card.d-card
                                    else (if v-is-sourced
                                          then sourced_dis-card.d-card
                                          else main_dis-card.d-card)):
    if buf_dis-card-property.dtm-code = 0 then next.
    if discprop-usercanedit( input buf_dis-card-property.dtm-code, input g#db-num) = no then next.
    run discprop-node-code in this-procedure (
                                        input buf_dis-card-property.dtm-code
                                        ,input buf_dis-card-property.dt-code
                                      ,output v-data-type
                                      ,output v-format
                                      ,output v-label
                                      ,output v-range
                                      ,output v-rw-option
                                      ).
    if error-status:error or lookup("C", v-rw-option) = 0  then next.
    assign
    v-found-copy-prop = yes.
    CREATE tt0-dis-card-property.
    BUFFER-COPY buf_dis-card-property to tt0-dis-card-property
    assign
    tt0-dis-card-property.d-card = d-card
    tt0-dis-card-property.main-card = temp-dis-card.main-card
    tt0-dis-card-property.first-card = temp-dis-card.first-card
    tt0-dis-card-property.first-main-card = temp-dis-card.first-main-card
    tt0-dis-card-property.card-num = temp-dis-card.card-num
    .
  end.
END.
if (v-is-sourced or v-is-copy or v-is-subsid) and v-found-copy-prop then v-update-property = yes.
if v-update-property then do:
  run gbl/d-askw.w (
                    input "Сохранение изменений"
                    ,input  "Были изменены свойств ДК" + (if v-found-copy-prop then " или наследуются свойства ДК" else "":U)
                    ,input "|"
                    ,input "Сохранить ВСЕ|Кроме свойств|Отмена"
                    ,input "Сохранить изменения ДК и изменения свойств ДК|Сохранить изменения ДК|Ничего не сохранять"
                    ,input 1
                    ,input 3
                    ,output choice).
  if choice = 2 then v-update-property = no.
  if choice = 3 then return.
end.
IF ref-mode = 'ПРОСМОТР':U THEN RETURN .
find first temp-dis-card  no-error.
if not avail temp-dis-card then do:
  create temp-dis-card.
  assign
  frame Dialog-Frame v-pcnt-method
  temp-dis-card.cli-type = ub.clients.obj-type
  temp-dis-card.cli-code = ub.clients.obj-code
  temp-dis-card.d-card
  temp-dis-card.emitent-host-code
  temp-dis-card.status_ = 'тек':U
  temp-dis-card.d-pcnt-method = integer(v-pcnt-method)
  .
end.
assign
temp-dis-card.type
temp-dis-card.d-card
temp-dis-card.emitent-host-code
temp-dis-card.d-pcnt
temp-dis-card.cash-d-pcnt
temp-dis-card.category
temp-dis-card.credit-card
temp-dis-card.lim-kr
temp-dis-card.debet-card
temp-dis-card.staff-card
temp-dis-card.cli-message
temp-dis-card.issue-date
temp-dis-card.issue-code
temp-dis-card.valid-from
temp-dis-card.valid-date
v-pcnt-method
temp-dis-card.d-pcnt-method = integer(v-pcnt-method)
t-overissue
.
if temp-dis-card.type = '':U then do:
  message
  "Не выбран тип ДК"
  view-as alert-box error .
  undo, return error '':U.
end.
if ref-mode = 'ДОБАВЛЕНИЕ':U and t-overissue then
assign
temp-dis-card.sourced-card
.
if ref-mode = 'ДОБАВЛЕНИЕ':U and temp-dis-card.sourced-card <> "":U then do:
  find first source_dis-card no-lock where
            source_dis-card.d-card = temp-dis-card.sourced-card no-error .
  if available source_dis-card then do:
    if source_dis-card.type <> temp-dis-card.type then do:
      message
      substitute("У перевыпускаемой карты &1 - тип &2, а у карты &3, к которой перевыпускается карта &1 - тип &4&5" +
                "Вы уверены, что хотите перевыпустить карту с другим типом?"
                , temp-dis-card.d-card
                , temp-dis-card.type
                , source_Dis-card.d-card
                , source_dis-card.type
                ,chr(10)
                )
      view-as alert-box question buttons yes-no update glog.
      if not glog then undo, return error .
    end.
    if source_dis-card.status_ = 'удал':U then do:
      message
      substitute("Карта &2, к которой перевыпускается карта &1 - имеет статус &3&4" +
                "Вы уверены, что хотите перевыпустить карту к удаленной карте?"
                , temp-dis-card.d-card
                , source_Dis-card.d-card
                , source_Dis-card.status_
                ,chr(10)
                )
      view-as alert-box question buttons yes-no update glog.
      if not glog then undo, return error .
    end.
  end.
end.
if ref-mode = 'ДОБАВЛЕНИЕ':U
then do:
   run ref/dcardi04.p (
                  input temp-dis-card.d-card
                 ,input temp-dis-card.type
                 ,input temp-dis-card.emitent-host-code
                 ,input temp-dis-card.issue-code
                 ,output v-can-issue) no-error .
   if error-status:error
   or not v-can-issue  then do:
    message
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo, return error .
   end.
end.
for each tt0-dis-card-property :
  assign
  tt0-dis-card-property.d-card            = temp-dis-card.d-card
  .
end.
DO ON ERROR UNDO, RETURN ERROR:
  run ref/dcardi01.p (
                   input parparentproc
                  ,input this-procedure
                  ,input ?
                  ,input ?
                  ,input no
                  ,input-output dc-ri
                  ,input ref-mode
                  ,input '':U
                  ,input parobj-type
                  ,input parobj-code
                  ,input temp-dis-card.d-card
                  ,input temp-dis-card.emitent-host-code
                  ,input temp-dis-card.cli-type
                  ,input temp-dis-card.cli-code
                  ,input (if ref-mode = 'ДОБАВЛЕНИЕ':U then 'тек':U else temp-dis-card.status_)
                  ,input temp-dis-card.type
                  ,input temp-dis-card.d-pcnt
                  ,input temp-dis-card.cash-d-pcnt
                  ,input temp-dis-card.category
                  ,input temp-dis-card.d-pcnt-method
                  ,input temp-dis-card.credit-card
                  ,input temp-dis-card.lim-kr
                  ,input temp-dis-card.debet-card
                  ,input temp-dis-card.staff-card
                  ,input temp-dis-card.issue-date
                  ,input temp-dis-card.issue-code
                  ,input temp-dis-card.valid-from
                  ,input temp-dis-card.valid-date
                  ,input temp-dis-card.sourced-card
                  ,input temp-dis-card.cli-message
                  ,input temp-dis-card.mask-card
                  ,input (if v-is-subsid
                          or ref-mode = 'ИЗМЕНЕНИЕ':U
                          then temp-dis-card.main-card
                          else temp-dis-card.d-card)
                  ,input temp-dis-card.is-subsid
                  ,INPUT v-update-property
                  ,INPUT table tt0-dis-card-property
                  ) no-error.
if error-status:error then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
end.
END.
END PROCEDURE.
