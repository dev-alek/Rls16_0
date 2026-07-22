block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mntusrkl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mntusrkl.p $":U .
define variable vss-description as character no-undo init "Мониторинг за работой пользователей.".
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
define variable vartimeout as integer no-undo.
define stream strlog.
define stream strvip.
define temp-table tt-user no-undo like _UserIO
   field TimeLastWork as decimal .
define temp-table tt-vipuser no-undo
  field user-name as character
  index pi is primary user-name.
define variable vartimework    as int64         no-undo.
define variable varpause       as integer       no-undo.
define variable vardb-name     as character     no-undo.
define variable varprogress    as character     no-undo.
define variable varexefile     as character     no-undo .
define variable varinifile     as character     no-undo .
define variable varcomstring   as character     no-undo.
define variable vartime-string as character     no-undo.
define variable w-monitor      as widget-handle no-undo.
define variable varstr         as character     no-undo.
define frame fr-a
"Время последней проверки:" vartime-string no-label skip
"Выход из программы CTRL-BREAK"
WITH 1 DOWN NO-BOX OVERLAY
     SIDE-LABELS THREE-D
     AT COL 1 ROW 1
     SIZE 37 BY 2.
CREATE WINDOW w-monitor ASSIGN
       HIDDEN             = YES
       TITLE              = "Монитор работы пользователей"
       COLUMN             = 25.25
       ROW                = 8.5
       HEIGHT             = 2
       WIDTH              = 37
       MAX-HEIGHT         = 2
       MAX-WIDTH          = 37
       VIRTUAL-HEIGHT     = 2
       VIRTUAL-WIDTH      = 37
       RESIZE             = no
       SCROLL-BARS        = yes
       STATUS-AREA        = no
       BGCOLOR            = ?
       FGCOLOR            = ?
       THREE-D            = yes
       MESSAGE-AREA       = no
       SENSITIVE          = yes.
IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(w-monitor)
THEN w-monitor:HIDDEN = no.
ASSIGN
  CURRENT-WINDOW             = w-monitor
  SESSION:SYSTEM-ALERT-BOXES = (CURRENT-WINDOW:MESSAGE-AREA = NO)
  session:three-d = yes
.
PAUSE 0 BEFORE-HIDE.
VIEW w-monitor.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME fr-a:PARENT eq ?
THEN FRAME fr-a:PARENT = ACTIVE-WINDOW.
assign
  vartimeout = INTEGER(session:parameter) no-error.
if error-status:error or vartimeout <= 0 then do:
  message "Указаны неверные параметры сессии при запуске монитора просмотра работы пользователей mntusrkl.p." skip
          "Это должно быть целое число большее нуля (Время работы пользователя без обращения к базе данных в секундах)." skip
          "Указаны параметры сессии: "  session:parameter
  view-as alert-box error.
  output stream strlog to "./mntusrkl.log" append.
  put stream strlog unformatted today " " string(time, "hh:mm:ss") " " substitute("Указаны неверные параметры сессии при запуске монитора просмотра работы пользователей mntusrkl.p. Это должно быть целое число большее нуля (Время работы пользователя без обращения к базе данных в секундах). Указаны параметры сессии: &1 ",  session:parameter) skip.
  output stream strlog close.
  QUIT.
end.
if INDEX(PDBNAME("ub"), "\") > 0 or INDEX(PDBNAME("ub"), "/") > 0 then do:
  assign
    vardb-name = PDBNAME("ub") + ".db".
end.
else do:
  assign
    vardb-name = ".\" + PDBNAME("ub") + ".db".
end.
if search (vardb-name) = ? then do:
  message "Не найдена база данных " vardb-name "."
  view-as alert-box error.
  output stream strlog to "./mntusrkl.log" append.
  put stream strlog unformatted today " " string(time, "hh:mm:ss") " " substitute("Не найдена база данных &1.", vardb-name ) skip.
  output stream strlog close.
  QUIT.
end.
if search ("./vipuser.txt") <> ? then do:
  input stream strvip from "./vipuser.txt".
  repeat :
    assign
      varstr = "":u.
    import stream strvip unformatted varstr.
    if varstr <> ? and varstr <> "":u then do:
      create tt-vipuser.
      assign
        tt-vipuser.user-name = varstr.
    end.
  end.
end.
run main-procedure in this-procedure no-error.
QUIT.
procedure main-procedure:
do
on stop undo, return error
:
define buffer buf_sys-ctrl   for ub.sys-ctrl .
define buffer buf_user-login for ub.user-login .
run gbl/getexini.p
    (output varexefile
    ,output varinifile
    ).
assign
  varprogress = replace (varexefile, "prowin32.exe", "proshut.bat").
output stream strlog to "./mntusrkl.log" append.
put stream strlog unformatted today " " string(time, "hh:mm:ss") " Начало работы монитора." skip.
output stream strlog close.
find first tt-vipuser no-error.
if available tt-vipuser then do:
  for each tt-vipuser :
    output stream strlog to "./mntusrkl.log" append.
    put stream strlog unformatted today " " string(time, "hh:mm:ss") substitute("Пользователь &1 объявлен неотключаемым.", tt-vipuser.user-name) skip.
    output stream strlog close.
  end.
end.
repeat on stop   undo, return error
       on error  undo, retry
       on endkey undo, retry :
assign
  vartime-string = STRING(TIME, "HH:MM:SS").
display vartime-string with frame fr-a.
assign
  varTimeWork = etime.
find first buf_sys-ctrl no-lock .
for each _UserIO no-lock
:
  find first buf_user-login no-lock
    where buf_user-login.db-num     = buf_sys-ctrl.db-num
      and buf_user-login.status_    = 0
      and buf_user-login.user-login = _UserIO._UserIO-Name
    no-error .
  if available buf_user-login
    and trim(buf_user-login.user-login) <> "":U
  then do:
    find first tt-vipuser where tt-vipuser.user-name = buf_user-login.user-login no-error.
    if not available tt-vipuser then do:
      find first tt-user where tt-user._UserIO-ID = _UserIO._UserIO-ID no-error.
      if not available tt-user then do:
        create tt-user.
        buffer-copy _UserIO to tt-user.
        assign
          tt-user.TimeLastWork = cur-time-mjd().
        output stream strlog to "./mntusrkl.log" append.
        put stream strlog unformatted today " " string(time, "hh:mm:ss") " " substitute("Пользователь &1 начал работу с базой данных.", _UserIO._UserIO-Name) skip.
        output stream strlog close.
      end.
      else do:
        if _UserIO._UserIO-Name <> tt-user._UserIO-Name then do:
          output stream strlog to "./mntusrkl.log" append.
          put stream strlog unformatted today " " string(time, "hh:mm:ss") " " substitute("Пользователь &1 самостоятельно отключился от базы данных.", tt-user._UserIO-Name) skip.
          output stream strlog close.
          delete tt-user.
          create tt-user.
          buffer-copy _UserIO to tt-user.
          assign
            tt-user.TimeLastWork = cur-time-mjd().
          output stream strlog to "./mntusrkl.log" append.
          put stream strlog unformatted today " " string(time, "hh:mm:ss") " " substitute("Пользователь &1 начал работу с базой данных.", _UserIO._UserIO-Name) skip.
          output stream strlog close.
        end.
        else do:
          if _UserIO._UserIO-DbAccess <> tt-user._UserIO-DbAccess then do:
            buffer-copy _UserIO to tt-user.
            assign
              tt-user.TimeLastWork = cur-time-mjd().
          end.
          else do:
            if cur-time-mjd() - tt-user.TimeLastWork > vartimeout / 86400 then do:
              find first _Connect where _Connect._Connect-Id = _UserIO._UserIO-ID no-lock no-error.
              if available _Connect then do:
                os-command silent value("net send " + _Connect._Connect-device + " Вы были отключены от базы данных монитором слежения за работой пользователей.").
              end.
              assign
                varcomstring = varprogress + " " + vardb-name + " -C disconnect " + string(_UserIO._UserIO-Usr).
              os-command silent value(varcomstring).
              output stream strlog to "./mntusrkl.log" append.
              put stream strlog unformatted today " " string(time, "hh:mm:ss") " " substitute("Был отключен пользователь &1. Время без обращения к БД &2.", _UserIO._UserIO-Name, cur-time-mjd-to-string( cur-time-mjd() - tt-user.TimeLastWork) ) skip.
              output stream strlog close.
              delete tt-user.
            end.
          end.
        end.
      end.
    end.
  end.
end.
for each tt-user :
  find first _UserIO where _UserIO._UserIO-ID = tt-user._UserIO-ID no-lock no-error.
  if not available _UserIO or _UserIO._UserIO-Name <> tt-user._UserIO-Name then do:
    output stream strlog to "./mntusrkl.log" append.
    put stream strlog unformatted today " " string(time, "hh:mm:ss") " " substitute("Пользователь &1 самостоятельно отключился от базы данных.", tt-user._UserIO-Name) skip.
    output stream strlog close.
    delete tt-user.
  end.
end.
assign
  varTimeWork = (etime - varTimeWork) / 1000.
if 60 - varTimeWork > 0 then do:
  assign
    varPause = 60 - varTimeWork.
end.
else do:
  assign
    varPause = 0.
end.
pause varPause no-message.
end.
end.
end procedure.
