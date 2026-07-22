block-level on error undo, throw.

/*------------------------------------------------------------------------

  File: 

  Author: 

  Created: 
------------------------------------------------------------------------*/


/* ***************************  Definitions  ************************** */

define variable vss-revision    as character no-undo init "$Revision: $":U.
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U.
define variable vss-date        as character no-undo init "$Date: $":U.
define variable vss-workfile    as character no-undo init "$Workfile: exp-ATD-shd.p $":U.
define variable vss-archive     as character no-undo init "$Archive: bge/exp-ATD-shd.p $":U.
define variable vss-description as character no-undo init "".

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



define buffer buf_clients for clients.

define temp-table shd-obj-temp no-undo
    field obj-type as character
    field obj-code as integer.

define variable v-param-list      as character no-undo.
define variable v-param-type      as character no-undo.
define variable p-region          as character no-undo.

define variable FILL-IN-Dir       as character no-undo.
define variable FILL-IN_esys      as character no-undo   .
define variable RADIO-SET-Objects as integer   no-undo.
define variable t_doc_ras         as character no-undo  .
define variable t_doc_pri         as logical   no-undo.
define variable bge-shift-attr    as logical   no-undo.
define variable exp-bge-stts      as logical   no-undo.
define variable i-pit             as integer   no-undo.
define variable i-nom             as integer   no-undo.
define variable v-grp-code-nom    as character no-undo   .
define variable v-grp-code-pit    as character no-undo   .
define variable code_no-exp       as character no-undo   .
define variable v-list-pay        as character no-undo   .
define variable v-list-abbr       as character no-undo   .
define variable v-entry           as character no-undo.
define variable v-obj-list        as character no-undo.
define variable ii                as integer   no-undo.

/* Includes */
{ref/shd-attr.i}

/* Получим атрибуты запуска */
run schedule-attr-value in this-procedure (input integer(p_db-num-char),
    input p_task-type,
    input p_task-num,
    input {&attr-schedule-param-list-h},
    output v-param-list,
    output v-param-type).
/* Разберем их */

run schedule-attr-value in this-procedure (input integer(p_db-num-char),
    input p_task-type,
    input p_task-num,
    input {&attr-schedule-obj-list-h},
    output v-obj-list,
    output v-param-type) no-error.

assign
    FILL-IN-Dir = entry(1,v-param-list,{&delim-par}) 
    RADIO-SET-Objects = integer(entry(2,v-param-list,{&delim-par}) )
    p-region = entry(3,v-param-list,{&delim-par}) 
no-error.
            
            
            
do ii = 1 to num-entries(v-obj-list, {&delim-par}) on error undo, next:
    v-entry = entry(ii, v-obj-list, {&delim-par}).
    /* Проверим, что они существуют */
    find first buf_clients where buf_clients.obj-type = entry(1, v-entry, {&comma-char})
        and buf_clients.obj-code = integer(entry(2, v-entry, {&comma-char})) no-lock no-error.
   
    if available buf_clients then 
    do:
        create shd-obj-temp.
        assign 
            shd-obj-temp.obj-code = buf_clients.obj-code
            shd-obj-temp.obj-type = buf_clients.obj-type.

    end. /* if available buf_clients */
                
end. /* do ii = 1 to num-entries(v-obj-list) */

            
run bge/bge-exp-ATD.p (input table shd-obj-temp,
    input FILL-IN-Dir,
    input p_log-handle,
    input  ?,
    input 0,
    input ?,
    input 0,
    input p-region,
    input "shd"
    ) no-error.