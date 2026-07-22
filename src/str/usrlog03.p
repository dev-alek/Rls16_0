block-level on error undo, throw.
/*

$Revision: 8118e8855adf, 3171, rls $
$Author: DRuban $
$Date: 2022/12/27 12:54:23 $
$Workfile: usrlog03.p $
$Archive: str/usrlog03.p $

Удалить логин пользователя (user-login)

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/22/07

*/

define input  parameter p-db-num  as integer   no-undo .
define input  parameter p-user-id as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 8118e8855adf, 3171, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:23 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usrlog03.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/usrlog03.p $":U .
define variable vss-description as character no-undo init "Удалить логин пользователя (user-login)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i}
define buffer buf_user-login for ub.user-login .

do transaction
on error undo, return error return-value
:
  find first buf_user-login exclusive-lock
    where buf_user-login.db-num  = p-db-num
      and buf_user-login.user-id = p-user-id
    no-error .
  if not available buf_user-login
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "БД" p-db-num skip
      "Идентификатор" p-user-id skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* todo проверка того, что можно удалять логин в текущей БД */
  buf_user-login.status_ = {&bef-user-status-deleted}.
  /* delete buf_user-login . */
end.