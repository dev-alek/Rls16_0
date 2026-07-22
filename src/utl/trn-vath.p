block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trn-vath.p $
$Archive: utl/trn-vath.p $

толкач для Утилиты коррекции партий внешнего прихода МФ закрытого на факт

Автор: Чернова Светлана Александровна
Дата создания: 02/21/08
Author: Svetlana Chernova
Creation date: 02/21/08

*/

define input parameter parparentproc as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: trn-vath.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/trn-vath.p $":U .
define variable vss-description as character no-undo init "толкач для Утилиты коррекции партий внешнего прихода  МФ  закрытого на факт".
{ cmp/vssrevis.i }

run utl/trn-vat.p ( parparentproc , "hold" ) .