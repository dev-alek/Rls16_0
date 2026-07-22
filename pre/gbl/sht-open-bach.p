block-level on error undo, throw.
define input  parameter iUtil as class ibs.th.utl.method-for-draw-utility no-undo.
define output parameter oOk as logical no-undo.
procedure put-mes:
define input  parameter iVss    as logical   no-undo.
define input  parameter iText   as character no-undo.
define input  parameter iGetMes as logical   no-undo.
define input  parameter iRetval as character no-undo.
iUtil:put-log(substitute("&1  &2 &3 &4 &5 &6 &7"
                         ,iText
                         ,if iGetMes then trim(error-status :get-message(1)) else ""
                         ,if iGetMes then trim(error-status :get-message(2)) else ""
                         ,if iGetMes then trim(error-status :get-message(3)) else ""
                         ,if iGetMes then trim(error-status :get-message(4)) else ""
                         ,if iGetMes then trim(error-status :get-message(5)) else ""
                         ,iRetval)
  ).
end procedure.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define variable mOk as logical no-undo.
define variable mBachMode as logical no-undo.
   mBachMode = yes.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Открытие смены".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure integerm :
  define input  parameter p-string      as character no-undo .
  define input  parameter p-allow-sign  as logical   no-undo .
  define input  parameter p-allow-comma as logical   no-undo .
  define output parameter p-value       as integer   no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
  define variable v-replace-string as character no-undo .
  do
  on error undo, return error return-value
  :
    if p-string = ?
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Не задана строка для преобразования"
      .
      return .
    end.
    if p-string = ""
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = "Ошибка задания входных параметров. Задана пустая строка для преобразования"
      .
      return .
    end.
    assign
      p-value = integer(p-string) no-error
    .
    if error-status :error = true
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'"
                                 ,p-string
                                 )
      .
      return .
    end.
    if index(p-string, ' ':u) > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит символы пробела"
                                 ,p-string
                                 )
      .
      return .
    end.
    assign
      v-replace-string = p-string
      v-replace-string = replace(v-replace-string, '0':u, '9':u)
      v-replace-string = replace(v-replace-string, '1':u, '9':u)
      v-replace-string = replace(v-replace-string, '2':u, '9':u)
      v-replace-string = replace(v-replace-string, '3':u, '9':u)
      v-replace-string = replace(v-replace-string, '4':u, '9':u)
      v-replace-string = replace(v-replace-string, '5':u, '9':u)
      v-replace-string = replace(v-replace-string, '6':u, '9':u)
      v-replace-string = replace(v-replace-string, '7':u, '9':u)
      v-replace-string = replace(v-replace-string, '8':u, '9':u)
    .
    if p-allow-sign = true
    then do:
      if index('+-':u, substring(v-replace-string, 1, 1)) > 0
      then do:
        assign
          v-replace-string = substring(v-replace-string, 2)
        .
      end.
    end.
    else do:
      if substring(v-replace-string, 1, 1) = '+':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ плюс. "
                                  ,p-string
                                  )
        .
        return .
      end.
      if substring(v-replace-string, 1, 1) = '-':u
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака челого числа. "
                                  + "Строка содержит символ минус. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if p-allow-comma = true
    then do:
      assign
        v-replace-string = replace(v-replace-string, ',', '')
      .
    end.
    else do:
      if index(v-replace-string, ',') > 0
      then do:
        assign
          p-value      = ?
          p-data-valid = false
          p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                  + "Задан параметр недопустимости знака разделителя тысяч."
                                  + "Строка содержит знак разделителя тысяч. "
                                  ,p-string
                                  )
        .
        return .
      end.
    end.
    if index(p-string, '.') > 0
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Строка содержит знак десятичной точки"
                                 ,p-string
                                 )
      .
      return .
    end.
    if v-replace-string <> fill('9', length(v-replace-string))
    then do:
      assign
        p-value      = ?
        p-data-valid = false
        p-message    = substitute("Ошибка при преобразовании к целому числу строки '&1'. "
                                 + "Встречены символы, недопустимые для целого числа '&2'"
                                 ,p-string
                                 ,replace(v-replace-string, '9', '')
                                 )
      .
      return .
    end.
    assign
      p-data-valid = true
      p-message    = ""
    .
  end.
end procedure.
define variable f-date   as date    no-undo.
define variable f-time   as integer no-undo.
define variable s-date   as date    no-undo.
define variable e-date   as date    no-undo.
define variable s-time   as integer no-undo.
define variable e-time   as integer no-undo.
define variable s-num      as integer   no-undo.
define variable s-name     as character no-undo.
define variable s-name-int as integer   no-undo.
define variable is-super as log     no-undo.
define variable varupd-obj-date as logical initial no   no-undo.
define variable varobj-date     as date                 no-undo.
define variable v-sys-date      as date                 no-undo.
define variable v-sys-time      as integer              no-undo.
define variable v-cancel        as logical              no-undo.
define variable glog as logical no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define buffer bf-trb_shift-obj   for ub.shift-obj .
define buffer open-shift         for ub.shift-obj .
define buffer buf_shift-obj      for ub.shift-obj .
define buffer closed-shift       for ub.shift-obj .
do
on error undo, return error return-value + error-status:get-message(1) + error-status:get-message(2)
:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,input  'shift-on=request'
  ,output glog
  ) no-error .
if error-status :error then do:
  run put-mes(yes ,"Ошибка при запуске процедуры objat",yes,return-value).
  return error.
end.
run cur-time in this-procedure ( output v-sys-date
                               , output v-sys-time
                               ) no-error.
if error-status:error then do:
    run put-mes(yes ,"Ошибка при чтении системной даты.",yes,return-value).
    undo, return error .
end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output varobj-date
  ) no-error .
if error-status:error then do:
  run put-mes(no ,"Ошибка при чтении календарной даты на текущем объекте.",no,"").
  return error.
end.
if not glog then do:
  run put-mes(yes ,substitute("На объекте выключены смены.~nРабота со сменами невозможна.~nОбъект:&1 &2", p-curr-obj-type, p-curr-obj-code),no,"").
  return error.
end.
is-super = no.
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_shift_super':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
if glog then do:
  is-super = yes.
end.
else do:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_shift_regular':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output glog
    )  .
end.
end.
if not glog then do:
  run put-mes(no ,substitute("Вы не имеете прав для работы со сменами.~nОбъект:&1 &2", p-curr-obj-type, p-curr-obj-code),no,"").
  return error.
end.
find last open-shift where
          open-shift.obj-type = p-curr-obj-type and
          open-shift.obj-code = p-curr-obj-code and
          open-shift.status_ = 'тек':U
          use-index pi no-error.
if available open-shift then do:
  run put-mes(no ,substitute("На объекте &1 &2 уже есть открытая смена &3 &4."
                             ,p-curr-obj-type
                             ,p-curr-obj-code
                             ,open-shift.shift-date
                             ,open-shift.shift-num
  ),no,"").
  return error.
end.
find first buf_shift-obj no-lock
     where buf_shift-obj.obj-type = p-curr-obj-type
       and buf_shift-obj.obj-code = p-curr-obj-code
       and buf_shift-obj.status_ = 'ожд':U
use-index pi no-error.
if available buf_shift-obj
then do:
    do transaction
    on error undo, return error "Ошибка обработки запланированной смены" :
        find first buf_shift-obj exclusive-lock
             where buf_shift-obj.obj-type   = p-curr-obj-type
               and buf_shift-obj.obj-code    = p-curr-obj-code
               and buf_shift-obj.status_     = 'ожд':U
        use-index pi no-error.
        assign
            s-date = buf_shift-obj.shift-date
            s-time = v-sys-time
            s-num  = buf_shift-obj.shift-num
            s-name = buf_shift-obj.shift-name
        .
        run gbl/shift.w (
              input parparentproc
            , input p-curr-obj-type
            , input p-curr-obj-code
            , input-output s-date
            , input-output e-date
            , input-output s-time
            , input-output e-time
            , input-output s-num
            , input-output s-name
            , input "open-planned"
            , output v-cancel
        ) no-error.
        if error-status:error then do:
                run put-mes(yes ,"Ошибка ввода времени для новой смены.",yes,return-value).
                undo, return error .
        end.
        if v-cancel = yes
        then do:
            undo, return.
        end.
        assign
            buf_shift-obj.open-sys-date = v-sys-date
            buf_shift-obj.open-sys-time = v-sys-time
        .
        define buffer bf_shift-param for ub.shift-param .
        find first bf_shift-param no-lock where bf_shift-param.obj-code = 0 and
            bf_shift-param.obj-type = "" and
            bf_shift-param.shift-date = 01.01.1900  no-error .
        if available (bf_shift-param) then
        do:
            find first ub.shift-param no-lock where ub.shift-param.obj-code = buf_shift-obj.obj-code and
                ub.shift-param.obj-type = buf_shift-obj.obj-type and
                ub.shift-param.shift-date = buf_shift-obj.shift-date and
                ub.shift-param.shift-name = buf_shift-obj.shift-name and
                ub.shift-param.shift-num = buf_shift-obj.shift-num and
                ub.shift-param.gds-code = 0 and
                ub.shift-param.pl-code = 0 no-error .
            if not available (ub.shift-param) then
            do:
                create ub.shift-param .
                assign
                    ub.shift-param.obj-code   = buf_shift-obj.obj-code
                    ub.shift-param.obj-type   = buf_shift-obj.obj-type
                    ub.shift-param.shift-date = buf_shift-obj.shift-date
                    ub.shift-param.shift-name = buf_shift-obj.shift-name
                    ub.shift-param.shift-num  = buf_shift-obj.shift-num
                    .
            end.
            assign
                ub.shift-param.prc-dev-mass   = bf_shift-param.prc-dev-mass
                ub.shift-param.dev-paid-trans = bf_shift-param.dev-paid-trans .
        end.
    end.
end.
else do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-curr-obj-type
  ,input  p-curr-obj-code
  ,output s-date
  )  .
 find last open-shift where
           open-shift.obj-type = p-curr-obj-type and
           open-shift.obj-code = p-curr-obj-code and
           open-shift.shift-date = today
          use-index pi no-error.
 s-num  = (if available open-shift then open-shift.shift-num else 0) + 1.
 s-name = "11".
 s-time = time.
 e-time = time.
    if v-cancel = yes
    then do:
        undo, return.
    end.
end.
if not mBachMode
then do:
glog = no.
message
  "Начать новую смену по" p-curr-obj-type p-curr-obj-code skip
  "Дата начала смены:" s-date skip
  "Время начала смены:" string( s-time, "hh:mm" ) skip
  "Номер смены:" s-name skip
  "Порядок смены" s-num "?"
view-as alert-box question buttons OK-Cancel update glog.
end.
else
   glog = yes.
if not glog
then do:
  return error.
end.
find first buf_shift-obj
     where buf_shift-obj.obj-type   = p-curr-obj-type
       and buf_shift-obj.obj-code   = p-curr-obj-code
       and buf_shift-obj.shift-date = s-date
       and buf_shift-obj.shift-num  = s-num
no-error.
if available buf_shift-obj then do:
  case buf_shift-obj.status_:
    when 'ожд':U then do:
    end.
    when 'тек':U then do:
      run put-mes(no ,substitute("Смена уже открыта.~nДата начала смены: &1~nНомер смены: &2~nПорядок смены: &3~n"
                             ,s-date
                             ,s-name
                             ,s-num)
  ),no,"").
      return error.
    end.
    when 'зкр':U then do:
      run put-mes(no ,substitute("Смена уже закрыта.~nДата начала смены: &1~nНомер смены: &2~nПорядок смены: &3~n"
                             ,s-date
                             ,s-name
                             ,s-num)
  ),no,"").
      return error.
    end.
    otherwise do:
      run put-mes(no ,substitute("Неизвестный статус смены: &1~nДата начала смены: &2~nНомер смены: &3~nПорядок смены: &4~n"
                             ,buf_shift-obj.status_
                             ,s-date
                             ,s-name
                             ,s-num)
  ),no,"").
      return error.
    end.
  end case.
end.
find last closed-shift where
          closed-shift.obj-type = p-curr-obj-type and
          closed-shift.obj-code = p-curr-obj-code and
          closed-shift.status_ = 'зкр':U
          use-index pi no-error.
if not available closed-shift and
   not is-super then do:
           run put-mes(no ,substitute("Не найдена закрытая смена.~nНевозможно начать новую смену.~nОбъект: &1 &2"
                             ,p-curr-obj-type
                             ,p-curr-obj-code
  ),no,"").
  return error.
end.
if available closed-shift then do:
  if closed-shift.close-id = v-cntxt-userid and
    not is-super then do:
      run put-mes(no ,substitute("Предыдущая смена закрыта пользователем: &1 Новая смена должна быть открыта другим пользователем."
                             ,v-cntxt-userid
  ),no,"").
    return error.
  end.
  if s-date = closed-shift.shift-date then do:
    if s-num <> closed-shift.shift-num + 1 then do:
      run put-mes(no ,substitute("Последняя закрытая смена:&1 Порядок: &2~nНовая смена должна иметь порядок на 1 больше, или относиться к следующему дню."
                             ,closed-shift.shift-date
                             ,closed-shift.shift-num
  ),no,"").
        return error.
    end.
  end.
  if (s-date - closed-shift.shift-date) > 1 then do:
    if not mbachMode
    then do:
      glog = no .
    message
      "Последняя закрытая смена:" closed-shift.shift-date "Порядок:" closed-shift.shift-num skip
      "Последняя смена закрыта не вчера." skip
      "Открыть новую смену" s-date "Номер:" s-name "Порядок:" s-num "?" skip
      view-as alert-box question buttons yes-no update glog.
    end.
    else
       glog = yes.
    if not glog or
       not is-super then
      return error.
  end.
  if s-date > closed-shift.shift-date then do:
    if s-num <> 1 then do:
      run put-mes(no ,substitute("Последняя закрытая смена:&1 Порядок: &2~nПоследняя смена закрыта не сегодня.~nНовая смена должна иметь порядок 1."
                             ,closed-shift.shift-date
                             ,closed-shift.shift-num
  ),no,"").
      return error.
    end.
  end.
end.
if s-date > v-sys-date then do:
  run put-mes(no ,substitute("Дата смены &1~nДата на сервере &2~n Дата смены не может быть больше даты на сервере"
                             ,s-date
                             ,v-sys-date
  ),no,"").
   return error.
end.
if s-date < v-sys-date - 10 and
   is-super = no then do:
   run put-mes(no ,substitute("Дата смены &1~nДата на сервере &2~n Разница ~nЭта разница должна быть меньше 10 дней!"
                             ,s-date
                             ,v-sys-date
                             ,v-sys-date - s-date
  ),no,"").
   return error.
end.
if not mBachMode
then do:
    run str/dskshtop.p (
                     input parparentproc
                    ,input no
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input s-date
                    ,input s-num
        ,input s-name
                    ) no-error.
    if error-status :error then do:
      run put-mes(yes ,"Ошибка при проверке кассовых запретов",yes,return-value).
      return error.
    end.
end.
if varobj-date - s-date > 4 then do:
  run put-mes(no ,substitute("Календарная дата объекта &1~nСменная дата &2 ~nРазница &3~nРазница должна составлять не более 4 дней."
                             ,varobj-date
                             ,s-date
                             ,v-sys-date - s-date
  ),no,"").
end.
if varobj-date < s-date then do:
   message
        "Календарная дата объекта " varobj-date
   skip "Сменная дата " s-date
   skip "Календарная дата должна быть не меньше сменной даты."
   skip "Будем приравнивать календарную дату к сменной?"
   view-as alert-box question buttons yes-no update glog.
   if glog = no then return error.
                 else assign varupd-obj-date = yes.
end.
define variable vardata-valid as logical no-undo.
define variable varmessage    as character no-undo.
run integerm in this-procedure (
    input  s-name,
    input  no,
    input  no,
    output s-name-int,
    output vardata-valid,
    output varmessage ) no-error.
if error-status:error or
   vardata-valid <> yes then do:
     run put-mes(no ,"Ошибка при заведении номера смены. ",yes,varmessage).
 return error.
end.
if s-name-int < 1 then do:
  run put-mes(no ,"Номер смены может быть только положительным целым числом.",no,"").
  return error.
end.
for each bf-trb_shift-obj where bf-trb_shift-obj.obj-type    = p-curr-obj-type and
                                bf-trb_shift-obj.obj-code    = p-curr-obj-code and
                                bf-trb_shift-obj.shift-date  = s-date          and
                                bf-trb_shift-obj.shift-name  = s-name          and
                                bf-trb_shift-obj.status_    <> 'ожд':U on error undo, return error return-value :
 run put-mes(no ,substitute("Запрещено добавлять смены с одним номером в одном сменном дне.~nНа объекте &1 &2 есть смена:~nДата смены &3~nПорядок смены &4~nНомер смены &5"
                             ,bf-trb_shift-obj.obj-type
                             ,bf-trb_shift-obj.obj-code
                             ,bf-trb_shift-obj.shift-date
                             ,bf-trb_shift-obj.shift-num
                             ,bf-trb_shift-obj.shift-name
  ),no,"").
  return error.
end.
define variable v-value-character as character  no-undo .
define variable v-value-date      as date       no-undo .
define variable v-value-decimal   as decimal    no-undo .
define variable v-value-integer   as integer    no-undo .
define variable v-value-logical   as logical    no-undo .
define variable v-tth             as handle     no-undo .
define variable v-param-type            as character no-undo .
run adm/shattri.p ( input "get":U
                  , input  '':u
                  , input  0
                  , input  'obj-date':U
                  , input  'newordsh':U
                  , output v-value-character
                  , output v-value-date
                  , output v-value-decimal
                  , output v-value-integer
                  , output v-value-logical
                  , output v-param-type
                  , input-output table-handle v-tth
                  ) no-error .
if error-status :error then do:
   assign
      v-value-logical = FALSE
   .
end.
if v-value-logical then do:
  for each bf-trb_shift-obj where bf-trb_shift-obj.obj-type    = p-curr-obj-type and
                                  bf-trb_shift-obj.obj-code    = p-curr-obj-code and
                                  bf-trb_shift-obj.shift-date  = s-date          and
                                  bf-trb_shift-obj.shift-name  > s-name          on error undo, return error return-value :
      run put-mes(no ,substitute("По настройкам конфигурации (newordsh) вам запрещено добавлять смены с меньшим номером после смены с большим номером в одном сменном дне.~nНа объекте &1 &2 есть смена:~nДата смены &3~nПорядок смены &4~nНомер смены &5"
                             ,bf-trb_shift-obj.obj-type
                             ,bf-trb_shift-obj.obj-code
                             ,bf-trb_shift-obj.shift-date
                             ,bf-trb_shift-obj.shift-num
                             ,bf-trb_shift-obj.shift-name
  ),no,"").
    return error.
  end.
end.
start-shift:
do transaction on error undo start-shift, return on stop undo start-shift, return:
  if not available buf_shift-obj then do:
    create buf_shift-obj.
    assign
      buf_shift-obj.host-code     = v-host-code
      buf_shift-obj.obj-type      = p-curr-obj-type
      buf_shift-obj.obj-code      = p-curr-obj-code
      buf_shift-obj.shift-date    = s-date
      buf_shift-obj.shift-num     = s-num
      buf_shift-obj.shift-name    = s-name
      buf_shift-obj.open-date     = s-date
    .
  end.
  assign
    buf_shift-obj.status_ = 'тек':U
    buf_shift-obj.open-sys-date = v-sys-date
    buf_shift-obj.open-sys-time = v-sys-time
    buf_shift-obj.open-time     = s-time
  .
  if varupd-obj-date = yes then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objdtset in g#library
  (input p-curr-obj-type
  ,input p-curr-obj-code
  ,input s-date
  ) no-error .
     if error-status:error then do:
       run put-mes(no ,"Ошибка при установке календарной даты.",no,"").
        return error.
     end.
  end.
end.
if not mbachMode
then
    message
      "Новая смена открыта."
    view-as alert-box.
end.
mOk =yes.
oOk = mOk.
