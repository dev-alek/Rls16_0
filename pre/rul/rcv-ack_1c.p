block-level on error undo, throw.
define input parameter p-pack-data  as memptr no-undo . // с 26/IX-2018 xml-файл читаетс€ из memptr, а не из файла
define input parameter p-esys-id    as integer no-undo .
define output parameter p-status_   as integer no-undo .
define output parameter p-error     as character no-undo .
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
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дн€" ] .
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
  return "ƒата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
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
define variable v-num   as integer no-undo .
define variable v-sender-id as character no-undo .
define variable v-receiver-id as character no-undo .
define variable hDoc as handle no-undo.
define variable hRoot as handle no-undo.
define variable log_         as logical   no-undo.
define variable v-today            as date      no-undo .
define variable v-time             as integer   no-undo .
define buffer buf_sent for ub.esys-pck-sent .
define buffer buf_route for ub.esys-route .
define buffer buf_dump for ub.esys-route-dump .
v-num = ? .
p-status_ = ? .
create x-document hDoc.
create x-noderef hRoot.
hDoc:load("MEMPTR", p-pack-data, false).
hDoc:get-document-element(hRoot).
run GetChildren(hRoot, 1).
delete object hDoc.
delete object hRoot.
if v-num <> ? and p-status_ = 0
then do :
    find first buf_sent exclusive-lock where buf_sent.db-num = 0
                                         and buf_sent.esys-id = p-esys-id
                                         and buf_sent.esps-cr-db-num = g#db-num
                                         and buf_sent.esps-pack-num = v-num
                                         no-error.
    if not available buf_sent
    then do :
    end.
    else do :
      run cur-time in this-procedure
          ( output v-today
           ,output v-time
          ) no-error .
      assign
        buf_sent.esps-rcvd = yes
        buf_sent.esps-rcvdDate = v-today
        buf_sent.esps-rcvdtime = string(v-time, "HH:MM:SS")
        buf_sent.esps-rcvdtimeint = v-time
      .
      for each buf_route exclusive-lock where buf_route.esys-id = buf_sent.esys-id
                                          and buf_route.db-num = buf_sent.db-num
                                          and buf_route.esr-last-pack = buf_sent.esps-pack-num :
        for each buf_dump where buf_dump.esrd-dump-ord = buf_route.esr-dump-ord:
          delete buf_dump no-error .
        end.
        delete buf_route .
      end.
    end.
end.
procedure GetChildren :
  define input parameter hParent as handle .
  define input parameter level as integer .
  define variable i            as integer   no-undo.
  define variable hNoderef     as handle    no-undo.
  define variable hText        as handle    no-undo.
  create x-noderef hNoderef.
  create x-noderef hText .
  repeat i = 1 to hParent:num-children:
      log_ = hparent:get-child(hnoderef,i).
      if not log_ then
          leave.
      if hnoderef:subtype <> "element" then
          next.
      hnoderef:get-child(htext, 1) no-error .
      if hNoderef:name = "num" then v-num = integer(hText:node-value) no-error .
      if hNoderef:name = "sender-id" then v-sender-id = hText:node-value no-error .
      if hNoderef:name = "receiver-id" then v-receiver-id = hText:node-value no-error .
      if hNoderef:name = "status" then p-status_ = integer(hText:node-value) no-error .
      if hNoderef:name = "error" then p-error = hText:node-value no-error .
      run GetChildren (hNoderef, (level + 1)).
  end.
  DELETE OBJECT hNoderef.
  DELETE OBJECT hText.
end procedure .
