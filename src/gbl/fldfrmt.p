block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fldfrmt.p $
$Archive: gbl/fldfrmt.p $

Получить формат поля из базы данных

Автор: Перваков Михаил Сергеевич
Дата создания: 01/11/01
Author: Mikhail Pervakov
Creation date: 01/11/01

*/

define input  parameter p-table-name  as character no-undo .
define input  parameter p-field-name  as character no-undo .
define output parameter p-format-name as character no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: fldfrmt.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/fldfrmt.p $":U .
def var vss-description as character no-undo init "Получить формат поля из базы данных".
{ cmp/vssrevis.i }

find first _File no-lock
  where _File._File-Name = p-table-name
  no-error .
if not available _File then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка задания входных параметров" skip
    "Неизвестная таблица базы данных" p-table-name skip
    "p-table-name" p-table-name skip
    "p-field-name" p-field-name skip
    view-as alert-box error .
  undo, return error .
end.

find first _Field of _File no-lock
  where _Field._Field-Name = p-field-name
  no-error .
if not available _File then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка задания входных параметров" skip
    "Неизвестное поле в таблице" p-table-name skip
    "p-table-name" p-table-name skip
    "p-field-name" p-field-name skip
    view-as alert-box error .
  undo, return error .
end.

assign
  p-format-name = _Field._Format
.