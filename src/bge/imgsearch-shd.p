block-level on error undo, throw.
/*

$Revision: 575d20d95ec1, 311, rls $
$Author: EShklyar $
$Date: Tue Dec 01 19:12:40 2015 +0300 $
$Workfile: imgsearch-shd.p $
$Archive: bge/imgsearch-shd.p $

Процедура автоматического запуска утилиты Поиск изображений

Автор: Шкляр Елена Львовна
Дата создания: 02/09/14
Author: Shklyar Elena
Creation date: 02/09/14

*/

define variable vss-revision as character no-undo init "$Revision: $":U.
define variable vss-author as character no-undo init "$Author: EShklyar $":U.
define variable vss-date as character no-undo init "$Date: $":U.
define variable vss-workfile as character no-undo init "$Workfile: imgsearch-shd.p $":U.
define variable vss-archive as character no-undo init "$Archive: bge/imgsearch-shd.p $":U.
define variable vss-description as character no-undo init "".

{cmp/vssrevis.i}
{cmp/str-glbl.i}

/* ***************************  Definitions  ************************** */

/* Parameters */
define input parameter parparentproc as widget-handle no-undo.
define input parameter p_parent-handle as widget-handle no-undo.
define input parameter p_log-handle as handle no-undo.
define input parameter p_db-num-char as character no-undo.
define input parameter p_task-type as character no-undo.
define input parameter p_task-num as integer no-undo.
define input parameter p_db-num as integer no-undo.

/* Variables */
define variable v-param-list as character no-undo.
define variable v-param-type as character no-undo.
define variable v-obj-list as character no-undo.
define variable v-company as integer no-undo.
define variable v-directory as character no-undo.
define variable v-prefix as CHARACTER no-undo.
define variable v-grp-fuel as char no-undo.
define variable v-grp-spec as char no-undo.
define variable ii as integer no-undo.
define variable c_entry as character no-undo.

/* Buffers */
define buffer buf_clients for ub.clients.

/* Temp tables */
define temp-table tt_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code.

/* Includes */
{ref/shd-attr.i}

/* ***************************  Main Block  *************************** */
/* Получим атрибуты запуска */
run schedule-attr-value in this-procedure (input integer(p_db-num-char),
                                           input p_task-type,
                                           input p_task-num,
                                           input {&attr-schedule-param-list-h},
                                           output v-param-list,
                                           output v-param-type).
/* Разберем их */

assign
    v-company = integer(entry(1,v-param-list,{&delim-par}))
    v-directory = entry(2,v-param-list,{&delim-par}) 
    v-prefix = entry(3,v-param-list,{&delim-par})
    v-grp-fuel = entry(4,v-param-list,{&delim-par})
    v-grp-spec = entry(5,v-param-list,{&delim-par})
    NO-ERROR.



/* Запуск утилиты */
                           run utl\imgsearch.p (parparentproc 
                                                      
                                               ) .
