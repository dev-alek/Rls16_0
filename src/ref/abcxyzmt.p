block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: abcxyzmt.p $
$Archive: ref/abcxyzmt.p $

Печать Анализов ABC + XYZ

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06


*/

DEFINE INPUT PARAMETER parParentProc  AS WIDGET-HANDLE NO-UNDO.
DEFINE INPUT PARAMETER P-REZ          AS CHARACTER NO-UNDO . /* ABC */