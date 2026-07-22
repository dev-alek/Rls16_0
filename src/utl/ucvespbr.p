block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ucvespbr.p $
$Archive: utl/ucvespbr.p $

утилита закачки весовых кодов для уже ИМЕЮЩИХСЯ в БД товаров - толкач

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ucvespbr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ucvespbr.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

run utl/easyimp.w ("Импорт  весовых кодов", "utl/ucvespbc.p") no-error.