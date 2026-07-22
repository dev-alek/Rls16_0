block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-psn.p $
$Archive: rep/get-psn.p $

Получение имени клиента (для person)

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/
define input parameter p-psn-code      as integer      no-undo.
define output parameter p-obj-name     as character    no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-psn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/get-psn.p $":U .
define variable vss-description as character no-undo init "Получение имени клиента (для person)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

    define buffer buf_clients       for clients.
do
for buf_clients
on error undo, return error
:
    find first buf_clients no-lock
         where buf_clients.obj-type = {&prs}
           and buf_clients.obj-code = p-psn-code
    no-error.
    if not available buf_clients
    then do:
        assign
            p-obj-name = "?"
        .
    end.
    else do:
        assign
            p-obj-name = buf_clients.obj-name
        .
    end.
end.


