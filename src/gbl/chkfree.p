block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkfree.p $
$Archive: gbl/chkfree.p $

Проверка свободного места на диске.

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    p-disk-letter           - имя диска (1 символ)
    p-minimum-free-mbytes   - минимальное разрешенное место на диске в мегабайтах
Output:
    p-not-available         - yes, если места на диске нет
*/

define input parameter p-disk-letter            as character    no-undo.
define input parameter p-minimum-free-mbytes    as decimal      no-undo.
define output parameter p-not-available         as logical      no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkfree.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/chkfree.p $":U .
define variable vss-description as character no-undo init "Проверка свободного места на диске.".
{ cmp/vssrevis.i }

do
on error undo, return error
:

    define variable v-free-space    as decimal        no-undo.

    run gbl/getfree.p (
          input p-disk-letter
        , output v-free-space
    ) no-error.
    if error-status :error
    then do:
      message
             vss-workfile vss-revision vss-description
        skip "Ошибка определения свободного места на диске" p-disk-letter + ":"
        skip return-value
        skip trim(error-status :get-message(1))
             trim(error-status :get-message(2))
             trim(error-status :get-message(3))
      view-as alert-box error.
      undo, return error .
    end.
    if v-free-space < p-minimum-free-mbytes
    then do:
        assign
            p-not-available = yes
        .
    end.        /* if v-free-space < p-minimum-free-mbytes  */
    else do:
        assign
            p-not-available = no
        .
    end.        /* NOT ( if v-free-space < p-minimum-free-mbytes  ) */
end.