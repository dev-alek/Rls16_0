/*

$Revision: fd21875b889d, 1394, rls $
$Author: ASMorozov $
$Date: Thu Jun 28 15:24:33 2018 +0300 $
$Workfile: climercsub.cls $
$Archive: ibs/th/str/mercury/climercsub.cls $

Сущность TH клиент меркурия


Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/

using Progress.Lang.*.
using ibs.th.str.clients.*.
using ibs.th.str.gds.*.
using ibs.th.gbl.storage.*.
block-level on error undo, throw.

class ibs.th.str.mercury.climercsub implements ithsub: 

  define property GUID_ as integer no-undo
    get.
    set.

end class.