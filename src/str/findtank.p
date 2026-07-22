block-level on error undo, throw.
/*

$Revision: 3e76a53baf4c, 1133, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:54 2017 +0300 $
$Workfile: findtank.p $
$Archive: str/findtank.p $

Обёртка для использования процедур из str/findtank.i в классах 

Автор: Молотков Сергей Михайлович
Дата создания: 10/11/17
Author: Molotkov Sergey
Creation date: 10/11/17

*/
define variable vss-revision    as character no-undo init "$Revision: 3e76a53baf4c, 1133, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:54 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: findtank.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/findtank.p $":U .
define variable vss-description as character no-undo init "Поиск резервуара и пистолета по марке топлива".
{ cmp/trg-def.i  } /* &current-status */
{ str/findtank.i }