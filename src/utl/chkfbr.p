block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chkfbr.p $
$Archive: utl/chkfbr.p $

Проверка рецептов и документов производства

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkfbr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chkfbr.p $":U .
define variable vss-description as character no-undo init "Проверка рецептов и документов производства".
{ cmp/vssrevis.i }


do
on error undo, return error
:
    run str/diallog.w (
          input ?
        , input this-procedure
        , input "utl/chkfbrp.p":U
        , input "":U
        , input no /*p-auto-go*/
        , input "С&топ":U
        , input "Проверка рецептов и документов производства"
    ) no-error.
    if error-status:error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка при проверке рецептов и документов производства."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
end.