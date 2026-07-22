block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dftempl.p $
$Archive: gbl/dftempl.p $

Возвращает адрес записи таблицы template

Автор: Перваков Михаил Сергеевич
Дата создания: 02/20/02
Author: Mikhail Pervakov
Creation date: 02/20/02

*/


define input  parameter p-table-name     as character no-undo .
define output parameter p-template-recid as recid     no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: dftempl.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/dftempl.p $":U .
def var vss-description as character no-undo init "Возвращает адрес записи таблицы template".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-table-name,p-template-recid)" }

do
on error undo, return error return-value
:
  find first _File no-lock
    where _File._File-Name = p-table-name
    no-error .
  if not available _File then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестная таблица" p-table-name skip
      view-as alert-box error .
  end.

  assign
    p-template-recid = _File._Template
  .

end.