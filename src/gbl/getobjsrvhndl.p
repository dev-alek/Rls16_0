block-level on error undo, throw.
/*

$Revision: 3950c9e6675a, 2392, rls $
$Author: ASMorozov $
$Date: Ср июн 10 21:13:44 2020 +0300 $
$Workfile: getobjsrvhndl.p $
$Archive: gbl/getobjsrvhndl.p $

Библиотека для объектов

Автор: Морозов Александр Сергеевич
Дата создания: 09/02/2020
Author: Alexandr Morozov
Creation date: 09/02/2020


*/

using ibs.th.gbl.sys.objsrv.

define input-output parameter ObjSrv as class objsrv no-undo.
define new global shared variable g#libobj  as handle no-undo .
if not valid-handle (g#libobj)
  then run gbl/libobj.p persistent.
run GetObjServ in g#libobj (input-output ObjSrv).


