block-level on error undo, throw.
/*

$Revision: 1eba0946c2d7, 3078, rls $
$Author: DRuban $
$Date: Пт авг 05 19:16:25 2022 +0300 $
$Workfile: autousid.p $
$Archive: adm/autousid.p $

Инициализация user-id для автоматических процессов работы

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/20/06

*/

define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: autousid.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/autousid.p $":U .
define variable vss-description as character no-undo init "Инициализация user-id для автоматических процессов работы".
{ cmp/vssrevis.i }
{ adm/auto-def.i }

define buffer buf_sys-ctrl   for ub.sys-ctrl .
define buffer buf_user-login for ub.user-login .

do
on error undo, return error return-value
:
  if g#auto-user-password begins "nocrypt:"
  then
     g#auto-user-id = g#auto-user-login.
  else do:
  
     find first buf_sys-ctrl no-lock .
    
     find buf_user-login share-lock
       where buf_user-login.db-num     = buf_sys-ctrl.db-num
         and buf_user-login.status_    = {&uls-normal}
         and buf_user-login.user-login = g#auto-user-login
       no-error no-wait .
     if not available buf_user-login
     then do:
       undo, return error substitute("Не найден пользователь &1", g#auto-user-login) .
     end.
   
     assign
       g#auto-user-id = buf_user-login.user-id
     .
   end.
end.