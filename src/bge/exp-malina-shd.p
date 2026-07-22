block-level on error undo, throw.
/*

$Revision: 64215249eb5e, 199, rls $
$Author: EShklyar $
$Date: Mon Jun 08 18:12:30 2015 +0400 $
$Workfile: exp-malina-shd.p $
$Archive: bge/exp-malina-shd.p $

Процедура автоматического запуска выгрузки данных в Малину

Автор: Кривошеин Александр Николаевич
Дата создания: 02/09/14
Author: Krivoshein Alexander
Creation date: 02/09/14

*/

define variable vss-revision as character no-undo init "$Revision: $":U.
define variable vss-author as character no-undo init "$Author: EShklyar $":U.
define variable vss-date as character no-undo init "$Date: $":U.
define variable vss-workfile as character no-undo init "$Workfile: exp-malina-shd.p $":U.
define variable vss-archive as character no-undo init "$Archive: bge/exp-malina-shd.p $":U.
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
define variable v-goods as LOGICAL no-undo.
define variable v-chk as LOGICAL no-undo.
define variable v-category as integer no-undo.
define variable v-diapmin as integer no-undo.
define variable v-diapmax as integer no-undo.
define variable ii as integer no-undo.
define variable c_entry as character no-undo.
define variable v-location as logical no-undo.
define variable v-categ-loc as character no-undo.
/*define variable v-bonus-pay as character no-undo.*/


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
    v-goods = LOGICAL(entry(4,v-param-list,{&delim-par}))
    v-chk = LOGICAL(entry(5,v-param-list,{&delim-par}))
    v-category = integer(entry(6,v-param-list,{&delim-par}))
    v-diapmin = integer(entry(7,v-param-list,{&delim-par}))
    v-diapmax = integer(entry(8,v-param-list,{&delim-par}))
    v-location = LOGICAL(entry(9,v-param-list,{&delim-par}))
    v-categ-loc = entry(10,v-param-list,{&delim-par})
/*    v-bonus-pay  = entry(11,v-param-list,{&delim-par})*/
    NO-ERROR.

/* Получим список объектов */
run schedule-attr-value in this-procedure (input integer(p_db-num-char),
                                           input p_task-type,
                                           input p_task-num,
                                           input {&attr-schedule-obj-list-h},
                                           output v-obj-list,
                                           output v-param-type) no-error.
                                        

/* Заполним tt_obj-list */
/* Определим, по фирме или по объектам */

/* Если по фирме */
if v-obj-list begins {&cmp} then do:
    
    c_entry = entry(1,v-obj-list,{&delim-par}).
    
    /* Получим объкты */
    for each buf_clients where buf_clients.host-code = integer(entry(2,c_entry,{&comma-char})):
        
        /* Уберем удаленные объекты */
        if buf_clients.stts <> 0 then next.
        
        create tt_obj-list.
        assign
        tt_obj-list.obj-code = buf_clients.obj-code
        tt_obj-list.obj-type = buf_clients.obj-type.
        
    end.
    
end. /* if v-obj-list begins {&cmp} */

/* Если по объектам */
else do:
    do ii = 1 to num-entries(v-obj-list, {&delim-par}) on error undo, next:
        
        c_entry = entry(ii,v-obj-list,{&delim-par}).
        find first buf_clients where buf_clients.obj-type = entry(1,c_entry,{&comma-char})
            and buf_clients.obj-code = integer(entry(2,c_entry,{&comma-char})) no-lock no-error.
        
        /* Если нашли и объект не удален */
        if available(buf_clients) and buf_clients.stts = 0 then do:
            
            create tt_obj-list.
            assign
            tt_obj-list.obj-code = buf_clients.obj-code
            tt_obj-list.obj-type = buf_clients.obj-type.
            
        end. /* if available */
        
    end. /* do ii = 1 to num-entries */
end. /* else do */

/* Запуск экспорта */
    run bge\exp-malinap.p ( table tt_obj-list,
                            v-company,
                            v-directory,
                            v-prefix,
                            v-goods,
                            v-chk,
                            v-category,
                            v-diapmin,
                            v-diapmax,
                            p_log-handle,
                            v-location,
                            v-categ-loc
                       ).
