block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: open_url.p $
$Archive: gbl/open_url.p $

Запустить любую команду операционной системы или выполнить действие по умолчания для файла

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Действие аналогично открытию пункта меню Start/Run/Команда

*/

define input parameter p-file-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: open_url.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/open_url.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

do
on error undo, return error return-value
:
  os-command no-wait value ('start ' + p-file-name).
end.