block-level on error undo, throw.
/* ***************************  Definitions  ************************** */
/*

$Revision: da70ce2a1328, 1072, rls $
$Author: SMMolotkov $ Shalanin Sergey   $  
$Date: Fri Oct 06 18:35:13 2017 +0300 $ 
$Workfile: bge-active-vbrr-shd.p $ active-vbrr.p $
$Archive: bge/bge-active-vbrr-shd.p $ bge/bge-active-vbrr-shd.p $

Процедура запуска автоматической выгрузки информации по пополнениям и активации для сверки с ВБРР

Автор: Шаланини Сергей
Дата создания: 22/04/2016
Author: Shalanin Sergey 
Creation date:  22/04/2016

*/

define variable vss-revision    as character no-undo init "$Revision: $":U.
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U.
define variable vss-date        as character no-undo init "$Date: $":U.
define variable vss-workfile    as character no-undo init "$Workfile: bge-active-vbrr-shd.p $":U.
define variable vss-archive     as character no-undo init "$Archive: bge/bge-active-vbrr-shd.p $":U.
define variable vss-description as character no-undo init "Процедура запуска автоматической выгрузки информации по пополнениям и активации для сверки с ВБРР".

{cmp/vssrevis.i}
{cmp/str-glbl.i}

/* Parameters */
define input parameter parparentproc as widget-handle no-undo.
define input parameter p_parent-handle as widget-handle no-undo.
define input parameter p_log-handle as handle no-undo.
define input parameter p_db-num-char as character no-undo.
define input parameter p_task-type as character no-undo.
define input parameter p_task-num as integer no-undo.
define input parameter p_db-num as integer no-undo.
define variable p-date-to    as date      no-undo.
define variable p-date-from  as date      no-undo.
define variable p-gds-inf-po as integer   no-undo.
define variable p-gds-active as integer   no-undo.
define variable p-directory  as character no-undo.
define variable p-code_pnpo  as character no-undo.
define variable p-bge-active as logical   no-undo.
define variable p-bge-inf-po as logical   no-undo.
define variable p-per        as integer   no-undo.
define variable v-obj-list   as char      no-undo.
{ref/shd-attr.i}

define variable v-param-list as character no-undo.
define variable v-param-type as character no-undo.


run schedule-attr-value in this-procedure (input integer(p_db-num-char),
    input p_task-type,
    input p_task-num,
    input {&attr-schedule-param-list-h},
    output v-param-list,
    output v-param-type) no-error.
    if v-param-list = "" then do:
        message "Не заданы параметры!"
  VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
        
        end.    
    
/* Разберем их */

assign
    p-gds-inf-po = integer(entry (1, v-param-list, {&delim-par}))
    p-gds-active = integer(entry (2, v-param-list, {&delim-par}))
    p-directory  = entry (3, v-param-list, {&delim-par})
    p-code_pnpo  = entry (4, v-param-list, {&delim-par})
    p-bge-active = logical(entry (5, v-param-list, {&delim-par}))
    p-bge-inf-po = logical(entry (6, v-param-list, {&delim-par}))
    p-per        = integer(ENTRY(7, v-param-list, {&delim-par}))
    .
    
define variable v-param2-list as character no-undo.
define variable v-param2-type as character no-undo.
define variable v-obj-range   as integer   no-undo .
define variable v-host-code   like ub.sysconf.host-code no-undo .
                

run schedule-attr-value in this-procedure (input integer(p_db-num-char),
    input p_task-type,
    input p_task-num,
    input {&attr-schedule-obj-list-h},
    output v-param2-list,
    output v-param2-type) no-error.
    if v-param2-list = "" then do:
        message "Не заданы параметры!"
  VIEW-AS ALERT-BOX ERROR.
        UNDO, RETURN ERROR.
        
        end.

    if num-entries(v-param2-list,':') = 2
    then do:
      assign
        v-obj-range = integer(entry(1, v-param2-list, ':'))
        v-obj-list  = entry(2, v-param2-list, ':')
      .
      if v-obj-range = 2 then v-host-code = integer(v-obj-list) no-error. 
    end. /* if num-entries(v-str,':') = 2 */


run bge/active-vbrr.p (input parparentproc
    ,input v-obj-range
    ,input v-host-code
    ,input v-obj-list
    ,input p-date-to
    ,input p-date-from
    ,input p-gds-inf-po
    ,input p-gds-active
    ,input p-directory
    ,input p-code_pnpo
    ,input p-bge-active 
    ,input p-bge-inf-po
    ,input p-per
        
    ) no-error .
    
        if error-status:error then
    do:
   message
   return-value  error-status:get-message(1) view-as alert-box.
    end.
    
