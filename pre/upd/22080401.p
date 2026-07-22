block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
run syper-adm-set.
run password-time-set.
procedure syper-adm-set:
   define variable vBufUserLogin       as handle no-undo.
   define variable vBufUserAccaunt     as handle no-undo.
   define variable vBufUserAccauntAttr as handle no-undo.
   create buffer vBufUserLogin for table "user-login".
   vBufUserLogin:find-first ("where user-login.db-num eq 0 and user-login.user-login = 'адм':U and user-login.user-administrator and user-login.status_    = 0" , no-lock) no-error.
   if vBufUserLogin:available
   then do:
      define variable vuser-id as character no-undo.
      vuser-id = vBufUserLogin:buffer-field ("user-id"):buffer-value ().
      create buffer vBufUserAccaunt for table "user-account".
      vBufUserAccaunt:find-first (substitute ("where user-account.user-id = '&1' and user-account.status_ eq 0 ",vuser-id) , no-lock)no-error.
      if vBufUserAccaunt:available
      then do transaction:
         create buffer vBufUserAccauntAttr for table "user-account-attr".
         vBufUserAccauntAttr:find-first (substitute ("where user-account-attr.user-id = '&1' and user-account-attr.attr-code  eq 'superadm'",vuser-id) , exclusive-lock) no-error.
         if not vBufUserAccauntAttr:available
         then do:
            vBufUserAccauntAttr:buffer-create ().
            vBufUserAccauntAttr:buffer-field ("user-id"  ):buffer-value () = vuser-id.
            vBufUserAccauntAttr:buffer-field ("attr-code"):buffer-value () = "superadm".
         end.
         vBufUserAccauntAttr:buffer-field ("attr-value"  ):buffer-value ()  = "yes".
         vBufUserAccauntAttr:buffer-release ().
         delete object vBufUserAccauntAttr.
      end.
      delete object vBufUserAccaunt.
   end.
   delete object vBufUserLogin.
end.
procedure password-time-set:
   define variable vBufUserLogin   as handle no-undo.
   define variable vBufUserAccaunt as handle no-undo.
   define variable vBufSysCtrl     as handle no-undo.
   define variable vQuery          as handle no-undo.
   create buffer vBufSysCtrl for table "sys-ctrl".
   vBufSysCtrl:find-first ("" , no-lock) no-error.
   if vBufSysCtrl:available
   then do:
      create buffer vBufUserLogin for table "user-login".
      create query vQuery.
      vQuery:set-buffers(vBufUserLogin).
      vQuery:query-prepare(substitute ("preselect each user-login where user-login.db-num eq &1 and user-login.status_ = 0 and (user-login.user-password-set-mjd eq 0 or user-login.user-password-set-mjd eq ?) no-lock",
                                       vBufSysCtrl:buffer-field ("db-num"):buffer-value ()
                                       )
                           ).
      vQuery:query-open().
      vQuery:get-first().
      do while vBufUserLogin:available:
         do transaction:
            vBufUserLogin:find-current (exclusive-lock).
            vBufUserLogin:buffer-field ("user-password-set-mjd"):buffer-value () = cur-time-mjd().
            vBufUserLogin:buffer-release ().
         end.
         vQuery:get-next().
      end.
      vQuery:query-close().
      delete object vQuery.
      delete object vBufUserLogin.
   end.
   delete object vBufSysCtrl.
end.
