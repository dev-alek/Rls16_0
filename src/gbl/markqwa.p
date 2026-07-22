block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: markqwa.p $
$Archive: gbl/markqwa.p $

Подтверждение выхода из справочника без сохранения выбранных записей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/01/03
Author: Bakhtadze Natalya
Creation date: 07/01/03

*/

define input parameter p-sensitive as logical no-undo .
/*sensitive кнопки b-mark*/
define input parameter p-rid-list as character no-undo .
/*переменная в которой хранится список выбранных recid*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: markqwa.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/markqwa.p $":U .
define variable vss-description as character no-undo init "Подтверждение выхода из справочника без сохранения выбранных записей".
{ cmp/vssrevis.i }

define variable v-log as logical no-undo .

if p-sensitive and p-rid-list <> "":U then do:
  message
  "Информация о выбранных элементах будет потеряна" skip
  "Продолжить?"
  view-as alert-box QUESTION buttons YES-NO
  update v-log
  .
  if not v-log then do:
    return error.
  end.
end.