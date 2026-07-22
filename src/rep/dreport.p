block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 10 нояб. 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 10 нояб. 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
define input parameter  parParentProc  as widget-handle no-undo.
define input parameter  procname       as character no-undo . /* имя процедуры на 2 закладке  */
define input parameter  namereport     as character no-undo . /* имя процедуры на 2 закладке  */
define input parameter  param-date     as integer   no-undo . /* Дата  1 2 3 */
define input parameter  param-goods    as character no-undo . /* Товары */
define input parameter  param-obj      as character no-undo . /* Объекты */
define input parameter  param-pay      as character no-undo . /* Цены */
define input parameter  param-pay-hide as character no-undo . /* Цены - какие цены не паказывать*/
define input parameter  param-universal as character no-undo . /* многое другое см документ vss Использование d-report*/
define input parameter  param-alon     as logical   no-undo . /* 1 закладка*/
define variable mform as class ibs.th.ref.sobj.dReportTrg no-undo.
session:error-stack-trace=yes.
mform = new ibs.th.ref.sobj.dReportTrg ().
mform:setparam( parParentProc,
                procname,
                namereport,
                param-date,
                param-goods,
                param-obj,
                param-pay,
                param-pay-hide,
                param-universal,
                param-alon).
mform:FormRun().
delete object mform.