block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fileqnty.p $
$Archive: str/fileqnty.p $

Проверка количества файлов в директории

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

Если файлов больше 500, то возвращает true

*/

define input parameter DirPath as char no-undo.
define output parameter BadRetFlag as log no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fileqnty.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fileqnty.p $":U .
define variable vss-description as character no-undo init "Проверка количества файлов в директории".
{ cmp/vssrevis.i "substitute('&1',DirPath)" }
{ cmp/str-glbl.i }

define variable file as char no-undo.
define variable path as char no-undo.
define variable atr as char no-undo.

define variable ii as integer no-undo .

input from os-dir ( DirPath ) .
REPEAT :
    import file path atr.
    if can-do( "f", atr ) then
        ii = ii + 1 .
END .
input close.
if ii > 500 then
    BadRetFlag = TRUE.
else
    BadRetFlag = FALSE .