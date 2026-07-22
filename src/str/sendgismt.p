block-level on error undo, throw.
/*

$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Толкач отсылки настроек для проверки КМ

Автор: Белова Марина Михайловна
Дата создания: 18/12/2025
Author: Marina Belova
Creation date: 18/12/2025

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aa3cb396dbbb, 2685, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пт дек 18 18:16:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendpetrol.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendpetrol.p $":U .
define variable vss-description as character no-undo init "Отсылка настроек для проверки КМ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ str/def-thbjattr-list.i "new shared" }  

define variable p-obj-type as character no-undo .
define variable p-obj-code like ub.cash-desk.obj-code no-undo .
define variable action     as character no-undo init 'U':U.

define var choice as integer no-undo.
define var rid-list as char no-undo.
define variable log-file-name as character no-undo init "send-cd.txt":U .
define variable v-view-log as logical no-undo .


assign
p-obj-type = entry(1, p-parameter, {&delim-par})
p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
/*action     = entry(3, p-parameter, {&delim-par})*/
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).

run str/send-all.p (
                           input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input p-parameter
                          ) no-error.



