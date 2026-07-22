block-level on error undo, throw.
/*

$Revision: dbfe23dd76e1, 1141, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:54 2017 +0300 $
$Workfile: fbrlib.p $
$Archive: str/fbrlib.p $

Обёртка для использования процедур из str/fbrlib.i в классах 

Автор: Молотков Сергей Михайлович
Дата создания: 25/10/17
Author: Molotkov Sergey
Creation date: 25/10/17

*/
define variable vss-revision    as character no-undo init "$Revision: dbfe23dd76e1, 1141, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:54 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbrlib.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbrlib.p $":U .
define variable vss-description as character no-undo init "Создание рецептов, действия с рецептами".
{ cmp/str-glbl.i } /* {&new-line} */  
{ cmp/library.i  } /* g#library */
{ str/fbrcode.i }
{ str/fbrlib.i  }