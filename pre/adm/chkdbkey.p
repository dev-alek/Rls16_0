block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkdbkey.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/chkdbkey.p $":U .
define variable vss-description as character no-undo init "Процедура проверки правильности кодировки ключей БД".
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
Function reverse returns character (str as character).
   define variable rev_incl_s as character init "" no-undo .
   define variable rev_incl_i as integer no-undo .
   define variable rev_incl_l as integer no-undo .
   rev_incl_l = length(str).
   do rev_incl_i = 1 to rev_incl_l:
      rev_incl_s = rev_incl_s + substr(str,rev_incl_l - rev_incl_i + 1,1).
   end.
   return rev_incl_s.
end.
procedure check-enc.
  define input  parameter p-db-num    as integer   no-undo .
  define input  parameter p-db-key    as character no-undo .
  define input  parameter p-code      as character no-undo .
  define input  parameter p-value     as character no-undo .
  define input  parameter p-beg-date  as date      no-undo .
  define input  parameter p-end-date  as date      no-undo .
  define input  parameter p-enc-value as character no-undo .
  define output parameter p-answer    as logical   no-undo .
  define variable tmp         as character no-undo .
  define variable v-enc-value as character no-undo .
  if p-db-num <> 0
    and p-db-key = "":U
  then do:
    assign
      p-answer = true
    .
    return.
  end.
  if p-db-key = "unload-db":U then do:
    assign
      p-answer = true
    .
    return.
  end.
  if p-code = ""  then do:
    assign
      tmp = string( p-db-num ) + reverse (p-db-key).
    .
  end.
  else do:
    assign
      tmp = string( p-db-num )
            + trim( p-db-key )
            + reverse( trim( p-code ) )
            + reverse( trim( p-value ) )
            + reverse( string( p-beg-date, "99.99.9999" ) )
            + reverse( string( p-end-date, "99.99.9999" ) )
    .
  end.
  run pswd-enc in this-procedure
    ( input tmp
     ,output v-enc-value
    ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при вызове процедуры pswd-enc" skip
      return-value skip
      error-status :get-message(1) skip
      view-as alert-box error .
    undo, return error .
  end.
  if v-enc-value = p-enc-value then do:
    assign
      p-answer = true
    .
  end.
  else do:
    assign
      p-answer = false
    .
  end.
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure pswd-enc :
  define input parameter  pswd     as character no-undo .
  define output parameter enc-pswd as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      enc-pswd = encode(pswd + string(index(pswd, "k")))
    .
  end.
end procedure.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure get-ro_get-read-only :
  define output parameter p-ro-set as logical   no-undo .
  do
  on error  undo, return error substitute( "&1(get-ro_get-read-only). &2&3&4", vss-include-info3, return-value, error-status :get-message( 1 ) )
  on stop   undo, return error substitute( "&1(get-ro_get-read-only). stop", vss-include-info3 )
  on endkey undo, return error substitute( "&1(get-ro_get-read-only). endkey", vss-include-info3 )
  :
    if lookup( 'READ-ONLY':U, DBRESTRICTIONS('ub':U) ) > 0
    then do:
      assign
        p-ro-set = true
      .
    end.
    else do:
      assign
        p-ro-set = false
      .
    end.
  end.
end procedure.
do
on error  undo, return error
:
  define variable v-ind              as integer   no-undo .
  define variable v-start-time       as int64     no-undo .
  define variable v-current-time     as character no-undo .
  define variable v-err-code         as integer   no-undo .
  define variable v-load-db-key-now  as logical   no-undo .
  define variable v-file-name        as character no-undo .
  define variable v-log              as logical   no-undo .
  define variable v-str              as character no-undo .
  define variable v-last-key         as integer no-undo .
  define variable v-delimeter        as character no-undo .
  define variable v-num-entries      as integer no-undo .
  define variable v-check-db-num     as integer   no-undo .
  define variable v-check-user-id    as character no-undo .
  define variable v-check-user-admin as logical   no-undo .
  define variable v-get-ro_read-only as logical   no-undo .
  define variable v-db-num     like ub.db.db-num no-undo .
  define variable v-db-key     like ub.db.db-key no-undo .
  define variable v-db-key-enc like ub.db.db-key-enc no-undo .
  define buffer buf_db for ub.db .
  define stream NecesDb .
  define stream FileDbKey .
  create widget-pool .
  define variable w-login as widget-handle no-undo.
  create window w-login assign
         title              = "Проверка ключей БД"
         column             = 31.5
         row                = 9
         height             = 2.0
         width              = 10
         resize             = false
         scroll-bars        = false
         status-area        = false
         three-d            = true
         message-area       = false
         sensitive          = true
         visible            = true
         .
  define frame a
    v-ind           format ">>9"   label "Обработано ключей" skip
    v-current-time  format "x(8)"       label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Проверка ключей БД"
    .
  assign
    current-window = w-login
    v-start-time   = etime
  .
  assign
    v-get-ro_read-only = false
  .
  run get-ro_get-read-only in this-procedure
    ( output v-get-ro_read-only
    ) .
  view frame a.
  disable triggers for load of ub.db .
  assign
    v-err-code        = -1
    v-load-db-key-now = TRUE
  .
  do while v-err-code <> 0
     and v-load-db-key-now = TRUE
  on error undo, return error
  :
    os-delete value( "neceskey.txt":U ) .
    assign
      v-ind = 0
    .
    display
      v-ind
      v-current-time
      with frame a .
    for each buf_db no-lock
    on error undo, return error
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind mod 10 = 0 then do:
        assign
          v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
        .
        display
          v-ind
          v-current-time
          with frame a.
      end.
      run check-enc in this-procedure
        ( input buf_db.db-num
         ,input buf_db.db-key
         ,input "":U
         ,input "":U
         ,input ?
         ,input ?
         ,input buf_db.db-key-enc
         ,output v-log
        ) no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при проверке кодированых ключей БД! (1)" ) skip
          error-status :get-message ( error-status :num-messages )
          view-as alert-box error
        .
        return error .
      end.
      if v-log <> TRUE then do:
        assign
          v-err-code = 1
        .
        output stream NecesDb to "neceskey.txt":U append.
        put stream NecesDb unformatted
          substitute( "БД: &1 Ключ: &2 Кодированое значение: &3", buf_db.db-num, buf_db.db-key, buf_db.db-key-enc ) skip
        .
        output stream NecesDb close.
      end.
    end.
    if v-err-code > 0
    then do:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output v-check-db-num
  ,output v-check-user-id
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при определении текущей БД и/или пользователя") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run user-adm in g#library2
  (input  v-check-db-num
  ,input  v-check-user-id
  ,output v-check-user-admin
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при определении является ли текущий пользователь администратором") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      if v-check-user-admin = true
        and v-get-ro_read-only = false
      then do:
        message
          "Требуется загрузка кодированых ключей БД!" skip
          "Список БД с неправильной кодировкой ключей выведен в файл" chr(32) "neceskey.txt":U skip
          "Загрузить кодированые ключи БД сейчас?" skip
          view-as alert-box question buttons yes-no update v-load-db-key-now.
        if v-load-db-key-now = TRUE then do:
          SYSTEM-DIALOG GET-FILE
            v-file-name
            FILTERS "Текстовые файлы  *.txt" "*.txt",
                    "Все файлы"  "*.*"
            MUST-EXIST
            TITLE "Выберите файл для импорта кодированых ключей"
            USE-FILENAME
            UPDATE v-log.
          if v-log <> true then do:
            return error .
          end.
          assign
            v-delimeter = chr(32)
            v-last-key  = 0
          .
          input stream FileDbKey from value(v-file-name) .
          block_read:
          repeat while v-last-key <> -2
          on error undo, return error
          :
            assign
              v-last-key   = 0
              v-str        = "":U
              v-db-num     = -1
              v-db-key     = "":U
              v-db-key-enc = "":U
            .
            do while v-last-key <> 13
                     and v-last-key <> -2
            on error undo, return error
            :
              readkey stream FileDbKey pause 0.
              assign
                v-last-key = lastkey
                v-str = v-str + chr( v-last-key )
              .
            end.
            assign
              v-str = trim( v-str )
              v-num-entries = num-entries( v-str, v-delimeter )
            .
            if v-str = "":U then do:
              next.
            end.
            if v-num-entries > 3 then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "Некорректный файл ключей БД!" ) skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              assign
                v-err-code = 1
              .
              leave block_read.
            end.
            assign
              v-db-num = integer( entry( 1, v-str, v-delimeter ) ) no-error
            .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "Ошибка при чтении файла ключей БД!" ) skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              assign
                v-err-code = 1
              .
              leave block_read.
            end.
            if v-num-entries >= 2 then do:
              assign
                v-db-key = entry( 2, v-str, v-delimeter )
              .
            end.
            if v-num-entries = 3 then do:
              assign
                v-db-key-enc = entry( 3, v-str, v-delimeter )
              .
            end.
            find first buf_db
              where buf_db.db-num = v-db-num
              no-error
            .
            if not available buf_db then do:
              next.
            end.
            if ( ( v-db-num = 0
                   and buf_db.db-key <> "":U
                 )
                 or v-db-num <> 0
               )
              and buf_db.db-key <> v-db-key
            then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "В файле импорта обнаружено несоответствие ключей по БД &1 !", v-db-num ) skip
                substitute( "В БД: Ключ - &1", buf_db.db-key ) skip
                substitute( "В файле: Ключ - &1", v-db-key ) skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              assign
                v-err-code = 1
              .
              leave block_read.
            end.
            run check-enc in this-procedure
              ( input v-db-num
               ,input v-db-key
               ,input "":U
               ,input "":U
               ,input ?
               ,input ?
               ,input v-db-key-enc
               ,output v-log
              ) no-error.
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "Ошибка при проверке кодированых ключей БД! (2)" ) skip
                return-value skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              assign
                v-err-code = 1
              .
              leave block_read.
            end.
            if v-log <> TRUE then do:
              message
                vss-workfile vss-revision vss-description skip
                substitute( "В файле импорта обнаружена ошибка кодировки ключей БД!" ) skip
                substitute( "БД: &1; Ключ БД: &2; Кодированое значение: &3", v-db-num, v-db-key, v-db-key-enc ) skip
                error-status :get-message ( error-status :num-messages )
                view-as alert-box error
              .
              assign
                v-err-code = 1
              .
              leave block_read.
            end.
            if buf_db.db-key <> v-db-key then do:
              assign
                buf_db.db-key = v-db-key
              .
            end.
            assign
              buf_db.db-key-enc = v-db-key-enc
              v-err-code        = 0
            .
          end.
          input stream FileDbKey close.
          if v-err-code = 0 then do:
            message
              "Предоставленные кодированые значения ключей БД загружены!"
              view-as alert-box information.
          end.
        end.
        else do:
          return error.
        end.
      end.
      else do:
        message "Требуется загрузка кодированых ключей БД!" skip
                "Список БД с неправильной кодировкой ключей выведен в файл" chr(32) "neceskey.txt":U skip
                "Обратитесь к администратору системы."
          view-as alert-box error.
        return error.
      end.
    end.
    else do:
      assign
        v-err-code = 0
      .
    end.
  end.
  hide frame a .
  delete object w-login .
end.
return.
