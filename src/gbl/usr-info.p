block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: usr-info.p $
$Archive: gbl/usr-info.p $

Показать информацию о текущем пользователе

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/16/07

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usr-info.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/usr-info.p $":U .
define variable vss-description as character no-undo init "Показать информацию о текущем пользователе".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/sys-time.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define buffer buf_user-login for ub.user-login .

do
on error undo, return error return-value
:
  find buf_user-login no-lock
    where buf_user-login.db-num  = v-cntxt-db-num
      and buf_user-login.user-id = v-cntxt-userid
    no-error .
  if not available buf_user-login
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден логин пользователя" skip
      "БД" v-cntxt-db-num skip
      "Идентификатор" v-cntxt-userid skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  define variable v-user-name as character no-undo .
  { gbl/usrfulnm.i
    v-cntxt-userid
    v-user-name
  }

  message
    "Идентификатор пользователя"   buf_user-login.user-id skip
    "Имя пользователя"             v-user-name skip
    "Компьютер"                    buf_user-login.last-login-computer-name skip
    "Пользователь компьютера"      buf_user-login.last-login-computer-user skip
    "TCP имя компьютера"           buf_user-login.last-login-computer-tcp-name skip
    "IP адрес компьютера"          buf_user-login.last-login-computer-ip-addr skip
    "Идентификатор процесса"       buf_user-login.last-login-process-id skip
    "Номер подключения к БД"       buf_user-login.last-login-connection-id skip
    "Дата и время входа в систему" sys-time_mjd-to-loc-str-func(buf_user-login.last-login-mjd) skip
    view-as alert-box information .

end.