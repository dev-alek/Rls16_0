block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mntusrkl.p $
$Archive: utl/mntusrkl.p $

Мониторинг за работой пользователей.

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

Запускается на сервере. Отключает пользователей которые не работают определенный промежуток времени

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mntusrkl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/mntusrkl.p $":U .
define variable vss-description as character no-undo init "Мониторинг за работой пользователей.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
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
      and buf_user-login.status_    = {&uls-normal}
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
        /*Пользователь может отключиться, а с его ID быть уже другой пользователь*/
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
/*Зачищаем отключившихся пользователей*/
for each tt-user :
  find first _UserIO where _UserIO._UserIO-ID = tt-user._UserIO-ID no-lock no-error.
  /*Пользователь может отключиться, а с его ID быть уже другой пользователь*/
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