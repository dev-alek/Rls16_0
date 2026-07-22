block-level on error undo, throw.
define input parameter  p-action as character no-undo .
define output parameter p-permit as logical no-undo .
def var vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
def var vss-author      as character no-undo init "$Author: DRuban $":U .
def var vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: authoriz_main.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/authoriz_main.p $":U .
def var vss-description as character no-undo init "Программа авторизации пользователя для выполнения определенного действия".
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
if not ibs.th.gbl.gbl-var:rcode  and not session:debug-alert
then do:
   p-permit = yes.
   return.
end.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
assign
  p-permit = false
.
FUNCTION make-num-string RETURN CHAR
( input in-str as character )
:
  def var v-out-str as character no-undo .
  assign
    v-out-str = ''
  .
  def var ind as integer no-undo .
  do ind = 1 to length(in-str) :
    assign
      v-out-str = v-out-str + string(asc( substring(in-str, ind, 1)) - asc(' '))
    .
  end.
  return v-out-str .
end.
def var v-user-name as character no-undo .
def var passwd as character no-undo .
run input-user-and-passwd in this-procedure
  (output v-user-name
  ,output passwd
  ) no-error .
if error-status :error then do:
  return .
end.
case passwd :
  when "request" then do:
    run request-passwd in this-procedure .
  end.
  when "generate" then do:
    run generate-passwd in this-procedure .
  end.
  when "rndgen" then do:
    run random-passwd in this-procedure .
  end.
  otherwise do:
    run check-passwd in this-procedure
      (input  v-user-name
      ,input  passwd
      ) .
  end.
end.
return .
procedure input-user-and-passwd :
  define output parameter p-user-name as character no-undo .
  define output parameter p-password  as character no-undo .
  assign
    p-user-name = 'sysadm'
  .
  define buffer buf__User for ub._User .
  find first buf__User no-lock
    where buf__User._Userid = p-user-name
    no-error .
  if not available buf__User then do:
    run gbl/d-prompt.w (
        'title=Введите имя пользователя\'
      + 'text1=Введите имя пользователя\'
      + 'format=x(20)\'
      + 'type=char\'
      ,input-output p-user-name
      ).
    if return-value = 'false':u then do:
      return error .
    end.
  end.
  find first buf__User no-lock
    where buf__User._Userid = p-user-name
    no-error .
  if not available buf__User then do:
    message
      "Пользователь" p-user-name "недоступен"
      view-as alert-box .
    return error .
  end.
  run gbl/d-prompt.w (
      'title=Password Prompter\':u
    + 'text1=Enter password for user "':u + p-user-name + '"\':u
    + 'text2=or enter "request" to receive one time password (generate, rndgen)\':u
    + 'format=x(40)\':u
    + 'password=yes\':u
    + 'type=char\':u
    ,input-output p-password
    ).
  if return-value = 'false':u then do:
    return error .
  end.
end procedure.
procedure generate-passwd :
  def var v-passwd as character no-undo .
  def var v-seed as character no-undo .
  if not objSrv:SystemSetting:DeveloperMode
  then do:
     run gbl/d-prompt.w (
        'title=One time password generation\'
      + 'text1=Enter password\'
      + 'format=x(40)\'
      + 'password=yes\'
      + 'type=char\'
      ,input-output v-passwd
      ).
     if encode(v-passwd) <> "idZiiziQdcZKcbba" then do:
       run trg/userlog.p (
                 input 'one-pwd'
                , input ("Введен неправильный пароль для генерации одноразового пароля"  + chr(3) + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
       message
         "Incorrect one time generation password"
       view-as alert-box error .
       return .
     end.
  end.
  run gbl/d-prompt.w (
      'title=One time password\'
    + 'text1=Input client seed\'
    + 'format=x(40)\'
    + 'type=char\'
    ,input-output v-seed
    ).
  assign
    v-passwd = make-num-string(substring(encode( 'ab' + v-seed ), 1, 7))
  .
  run gbl/d-prompt.w (
      'title=One time password\'
    + 'text1=Client seed: "' + v-seed + '"\'
    + 'text2=Send this password to the client\'
    + 'format=x(40)\'
    + 'type=char\'
    ,input-output v-passwd
    ).
    run trg/userlog.p (
                input 'one-pwd'
                , input ("Сгенерирован одноразовый пароль"  + chr(3) + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
end procedure.
procedure request-passwd :
  def var v-passwd         as character no-undo .
  def var v-seed           as character no-undo .
  def var v-new-seed       as character no-undo .
  def var v-must-be-passwd as character no-undo .
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  assign
    v-seed = make-num-string
            (substring
              ( encode( p-action + string ( v-today ) + string(etime) )
              , 1
              , 7
              )
            )
  .
  assign
    v-passwd = v-seed
  .
  assign
    v-must-be-passwd = make-num-string(substring(encode( 'ab' + v-seed ), 1, 7))
  .
  def var ind as integer no-undo .
  do ind = 1 to 3
  :
    run gbl/d-prompt.w (
        'title=Password Prompter\'
      + 'text1=Give seed "' + v-seed + '" to developers of system\'
      + 'text2=Enter recieved password\'
      + 'format=x(40)\'
      + 'type=char\'
      ,input-output v-passwd
      ).
    if return-value = 'false':u then do:
      return .
    end.
    if v-passwd = v-must-be-passwd then do:
       run trg/userlog.p (
                input 'one-pwd'
                , input (substitute( "Введен правильный одноразовый пароль попытка № &1",ind)  + chr(3) + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
      run permit-action in this-procedure .
      return .
    end.
    run trg/userlog.p (
                input 'one-pwd'
                , input (substitute( "Введен неправильный одноразовый пароль попытка № &1",ind)  + chr(3) + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
    if ind < 3 then do:
      message
        "One-time password incorrect" skip
        "Try once more" skip
        view-as alert-box error .
    end.
    else do:
      message
        "One-time password incorrect" skip
        view-as alert-box error .
    end.
  end.
end procedure.
procedure check-passwd :
  define input  parameter p-user-name as character no-undo .
  define input  parameter p-password  as character no-undo .
  define buffer buf__User for ub._User .
  find first buf__User no-lock
    where buf__User._Userid = p-user-name
    no-error .
  if not available buf__User then do:
    message
      "Пользователь" p-user-name "недоступен"
      view-as alert-box .
    return error .
  end.
  if encode(p-password) = buf__User._Password or objSrv:SystemSetting:DeveloperMode then do:
     run trg/userlog.p (
                input 'one-pwd'
                , input (substitute("Введен пароль для &1", p-user-name)  + chr(3) + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
    run permit-action in this-procedure .
  end.
  else do:
    run trg/userlog.p (
                input 'one-pwd'
                , input (substitute("Неправильно введен пароль для &1", p-user-name)  + chr(3) + program-name(3) )
                , input ?
                , input ?
                , input "") no-error.
    message
      "Неправильно введен пароль для " p-user-name
      view-as alert-box .
  end.
end procedure.
procedure random-passwd :
  def var ind as integer no-undo .
  def var v-passwd as character no-undo .
  assign
    v-passwd = ""
  .
  do ind = 1 to 5
  :
    assign
      v-passwd = v-passwd + chr( random( asc('a'), asc('z') ) )
    .
  end.
  do ind = 1 to 3
  :
    assign
      v-passwd =  v-passwd + string(random( 0, 9 ))
    .
  end.
  message
    "Random password" skip
    v-passwd skip
    encode(v-passwd) skip
    view-as alert-box .
end procedure.
procedure permit-action :
  do
  on error undo, return error
  :
    assign
      p-permit = true
    .
  end.
end procedure.
