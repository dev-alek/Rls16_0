block-level on error undo, throw.
/*

$Revision: 54ccc9e2d3ee, 3460, rls $
$Author: Ostroukhov $
$Date: 2023/10/16 15:13:33 $
$Workfile: r-beneq1.p $
$Archive: rep/r-beneq1.p $

Заполнение временной таблицы по чекам для отчета о выручке

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
{ rep/r-beneq1.i }