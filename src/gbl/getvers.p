block-level on error undo, throw.
/*

$Revision: 1f78fe327cdf, 1091, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:52 2017 +0300 $
$Workfile: getvers.p $
$Archive: gbl/getvers.p $

Получить имя текущей версии

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/

define output parameter p-version-name as character no-undo .

do
on error undo, return error return-value
:
  assign
    p-version-name = "16.0":u
  .
end.