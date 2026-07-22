block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: usracc03.p $
$Archive: str/usracc03.p $

Удалить аккаунт пользователя (user-account)

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 01/22/07

*/

define input parameter p-user-id    as character        no-undo.
define input parameter p-db-num     as integer          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usracc03.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/usracc03.p $":U .
define variable vss-description as character no-undo init "Удалить аккаунт пользователя (user-account)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define buffer buf_user-account for ub.user-account .
define buffer buf_user-login   for ub.user-login .

do transaction
on error undo, return error return-value
:
  find first buf_user-account exclusive-lock
       where buf_user-account.user-id = p-user-id
  no-error .
  if not available buf_user-account
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден пользователь" skip
      "Идентификатор" p-user-id skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if buf_user-account.status_ <> {&bef-user-status-normal}
  then do:
    message
      "Невозможно удалить пользователя" skip
      "Идентификатор" buf_user-account.user-id skip
      "Статус" buf_user-account.status_ skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  find first buf_user-login exclusive-lock
       where buf_user-login.user-id = buf_user-account.user-id
         and buf_user-login.db-num  = p-db-num
  no-error.
  if available buf_user-login
  then do:
        run str/usrlog03.p (
              input buf_user-login.db-num
            , input buf_user-login.user-id
        ).
  end.
  assign
    buf_user-account.status_ = {&bef-user-status-deleted}
  .
end.