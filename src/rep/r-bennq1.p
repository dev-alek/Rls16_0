block-level on error undo, throw.
/*

$Revision: a7aa914b2dca, 3472, rls $
$Author: SSlivenko $
$Date: 2023/10/16 15:13:35 $
$Workfile: r-bennq1.p $
$Archive: rep/r-bennq1.p $

Заполнение временной таблицы по чекам для отчета о выручке с выбором временных интервалов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
/*define variable vss-revision    as character no-undo init "$Revision: a7aa914b2dca, 3472, rls $":U .      */
/*define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .                    */
/*define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:35 $":U .*/
/*define variable vss-workfile    as character no-undo init "$Workfile: r-bennq1.p $":U .                */
/*define variable vss-archive     as character no-undo init "$Archive: rep/r-bennq1.p $":U .             */
/*define variable vss-description as character no-undo init "".                                          */

{ rep/r-beneq1.i time }
/*{ cmp/vssrevis.i }*/