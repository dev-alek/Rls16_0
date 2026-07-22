block-level on error undo, throw.
/*

$Revision: f4eb1c45dbd4, 240, rls $
$Author: ASMorozov $
$Date: Mon Aug 31 16:26:51 2015 +0400 $
$Workfile: GetLogStrProc.p $
$Archive: ibs/th/skt/Adapters/GetLogStrProc.p $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/


define shared variable g#LogStr as character no-undo.

define output parameter str as character no-undo.

str = g#LogStr. 
