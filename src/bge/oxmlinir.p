block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: oxmlinir.p $
$Archive: bge/oxmlinir.p $

Получение настроек Open-XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/11/08
Author: Bakhtadze Natalya
Creation date: 10/11/08

*/

define output parameter p-oxml-exch-dir as character no-undo .
define output parameter p-oxml-heap-dir as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxmlinir.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxmlinir.p $":U .
define variable vss-description as character no-undo init "Получение настроек Open-XML".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/oxml-def.i new }

run bge/oxml-ini.p no-error.

if error-status :error then do:
  message
  vss-workfile vss-revision vss-description skip
  "Ошибка Получения/инициализации переменных для системы OpenXML" skip
  return-value
  view-as alert-box error.
end.
assign
p-oxml-exch-dir = oxml-exch-dir
p-oxml-heap-dir = oxml-heap-dir
.
