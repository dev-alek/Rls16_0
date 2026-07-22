block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter        p-dt-code as integer no-undo .
define input parameter        p-sum-id as character no-undo .
define input parameter        p-dtm-code as integer no-undo .
define input parameter        p-call-id as character no-undo .
define input parameter        p-ref-type as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сохранение prop-ref".
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
FUNCTION propreft-Date-to-String returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + chr(47) +
             string(Month(p-date), "99":U) + chr(47) +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
function propreft-string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 6, 2))
                ,integer(substring(p-string, 9, 2))
                ,integer(substring(p-string, 1, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION propreft-petrol-to-String returns character(input  p-gds-code as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = substitute("petrol-&1", p-gds-code).
return v-date-str.
END FUNCTION.
FUNCTION propreft-string-to-petrol returns integer(input  p-string as character):
define variable v-gds-code as integer no-undo .
assign
v-gds-code = integer(entry(2, p-string, "-")) no-error.
return v-gds-code.
END FUNCTION.
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
define variable v-mess as character no-undo .
define variable v-entry as character no-undo .
define variable v-dis-card-storage as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_prop-ref for ub.prop-ref.
define buffer buf2_prop-ref for ub.prop-ref.
define buffer buf_prop-head for ub.prop-head.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.
_main:
do for buf_prop-ref
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-dis-card-storage = '':U + chr(44) +
                       chr(63) + chr(44) +
                       'dis-card':U + chr(44) +
                       'dis-obj':U + chr(44) +
                       'dis-card-property':U.
  if p-dtm-code = 0 then do:
    assign
    v-mess = substitute("Неверный объект-операнд  с кодом &1", p-dtm-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'dtm-code':U).
  end.
  find first buf_prop-head no-lock where
            buf_prop-head.dtm-code  = p-dtm-code no-error.
  if not available buf_prop-head then do:
    assign
    v-mess = substitute("Не найден объект-операнд  с кодом &1", p-dtm-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'dtm-code':U).
  end.
  if lookup(buf_prop-head.storage-place, v-dis-card-storage) = 0
  and lookup(buf_prop-head.storage-place-host, v-dis-card-storage) = 0
  and lookup(buf_prop-head.storage-place-obj, v-dis-card-storage) = 0 then do:
    assign
    v-mess = substitute("Объект-операнд  с кодом &1 не предназначен для хранения данных по ДК", p-dtm-code).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'dtm-code':U).
  end.
  if p-sum-id = '':u
  then do:
    assign
    v-mess = substitute("Мнемонический идентификатор может быть пустым только&1" +
                       "для основного среза - с кодом 0").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'sum-id':U).
  end.
  if lookup(p-ref-type, 'blank,period,sel-goods,one-ptrl':U) = 0 then do:
    assign
    v-mess = substitute("Неверный тип идентификатора &1", p-ref-type).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'ref-type':U).
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    if p-dt-code = 0 then do:
      find last buf_prop-ref no-lock use-index pi no-error.
      assign
      p-dt-code = buf_prop-ref.dt-code + 1.
    end.
    else do:
      find first buf_prop-ref no-lock where
            buf_prop-ref.dt-code = p-dt-code no-error.
      if available buf_prop-ref then do:
        assign
        v-mess = "Уже существует Срез c таким кодом".
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'dt-code':U).
      end.
    end.
    find first buf2_prop-ref no-lock where
              buf2_prop-ref.dtm-code = p-dtm-code
         and  buf2_prop-ref.sum-id = p-sum-id
         and buf2_prop-ref.caller_id = p-call-id no-error.
    if available buf2_prop-ref then do:
      assign
      v-mess = substitute("Уже существует Срез c таким мнемонич идентификатором  &1 и кодом объекта &2 и доп.идентификатором &3"
                            ,p-sum-id
                            ,p-dtm-code
                            ,p-call-id).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'dtm-code':U).
    end.
    if p-ref-type = 'period':U then do:
      define variable v-date-from as date no-undo .
      define variable v-date-to as date no-undo .
      define variable v-date-from2 as date no-undo .
      define variable v-date-to2 as date no-undo .
      assign
      v-date-from = propreft-string-to-date( entry(1, p-sum-id, "-"))
      v-date-to = propreft-string-to-date( entry(2, p-sum-id, "-"))
      .
      run cur-time in this-procedure ( output v-today, output v-time).
      if v-date-from <= v-today then do:
        assign
        v-mess = substitute("Нельзя ввести частный итог для текущего периода времени").
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'dtm-code':U).
      end.
      for each buf2_prop-ref no-lock where
                buf2_prop-ref.dtm-code = p-dtm-code
            and buf2_prop-ref.caller_id = p-call-id:
        assign
        v-date-from2 = propreft-string-to-date( entry(1, buf2_prop-ref.sum-id, "-"))
        v-date-to2 = propreft-string-to-date( entry(2,  buf2_prop-ref.sum-id, "-"))
        .
        if v-date-from <= v-date-from2
        and v-date-to >= v-date-to2
        then leave.
        if v-date-from >= v-date-from2
        and v-date-to <= v-date-to2
        then leave.
        if v-date-from <= v-date-from2
        and v-date-to >= v-date-from2
        and v-date-to <= v-date-to2
        then leave.
        if v-date-from >= v-date-from2
        and v-date-from <= v-date-to2
        and v-date-to >= v-date-to2
        then leave.
      end.
      if available buf2_prop-ref then do:
        assign
        v-mess = substitute("Уже существует Срез &1 c кодом объекта &2 и доп.идентификатором &3, который захватывает период дат &4"
                              ,buf2_prop-ref.dt-code
                              ,p-dtm-code
                              ,p-call-id
                              ,p-sum-id
                              ).
        run err-mess in this-procedure ( input-output v-mess).
        return error (if p-silent = yes then v-mess else 'dtm-code':U).
      end.
    end.
    create buf_prop-ref.
    assign
    buf_prop-ref.dt-code = p-dt-code
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_prop-ref exclusive-lock where
              recid(buf_prop-ref) = p-rec .
    if buf_prop-ref.dt-code <> p-dt-code
    then do:
      assign
      v-mess = substitute("Для уже существующего среза невозможно изменение кода&1" +
                              "старые значения кода: &2"
                              , chr(10)
                              , buf_prop-ref.dt-code)
      .
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'dt-code':U).
    end.
  end.
  assign
  buf_prop-ref.sum-id  = p-sum-id
  buf_prop-ref.dtm-code  = p-dtm-code
  buf_prop-ref.caller_id  = p-call-id
  buf_prop-ref.ref-type  = p-ref-type
  p-rec = recid(buf_prop-ref)
  .
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Срез данных по ДК код: &1 &2"
                         , p-dtm-code
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
