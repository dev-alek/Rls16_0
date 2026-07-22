block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clntat-d.p $
$Archive: gbl/clntat-d.p $

Удалить значение атрибута клиента

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
define output parameter p-deleted  as logical no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clntat-d.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/clntat-d.p $":U .
define variable vss-description as character no-undo init "Удалить значение атрибута клиента".
{ cmp/vssrevis.i "substitute('&1|&2|&3',p-obj-type,p-obj-code,p-code)" }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }

do
on error undo, return error return-value
:
  run clntattr-delete in this-procedure
    (input  p-obj-type /* p-obj-type */
    ,input  p-obj-code /* p-obj-code */
    ,input  p-code     /* p-code     */
    ,output p-deleted  /* p-deleted  */
    ) no-error .
  if error-status :error
  then do:
    if error-status :get-message(1) <> ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры" 'clntattr-delete':u skip
        "Клиент" p-obj-type p-obj-code skip
        "Атрибут" p-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
    end.
    undo, return error return-value .
  end.
end.