block-level on error undo, throw.

/*------------------------------------------------------------------------

  File: 

  Author: 

  Created: 
------------------------------------------------------------------------*/


/* ***************************  Definitions  ************************** */

define variable vss-revision as character no-undo init "$Revision: $":U.
define variable vss-author as character no-undo init "$Author: SShalanin $":U.
define variable vss-date as character no-undo init "$Date: $":U.
define variable vss-workfile as character no-undo init "$Workfile: exp-VBRR-shd.p $":U.
define variable vss-archive as character no-undo init "$Archive: bge/exp-VBRR-shd.p $":U.
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

define variable  ptrl as character no-undo.
define variable v-param-list as character no-undo.
define variable v-param-type as character no-undo.
define variable v-directory as character no-undo.
define variable v-type-exp as integer no-undo.
define variable v-per-izm as character no-undo.
define variable  v-place as integer no-undo.
define variable v-login as char no-undo.
define variable v-password as char no-undo.
define variable v-code_TNP as char no-undo.
define variable v-code_pool as char no-undo.
define variable v-code_system as integer no-undo.
define variable v-long-code as integer no-undo.
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

assign

    v-directory = entry(1,v-param-list,{&delim-par}) 
  v-place  = integer(entry(2,v-param-list,{&delim-par}))
     v-login = entry(3,v-param-list,{&delim-par})
    v-password = entry(4,v-param-list,{&delim-par})
    v-code_TNP =entry(5,v-param-list,{&delim-par})
    v-code_pool = entry(6,v-param-list,{&delim-par})
    v-code_system = integer(entry(7,v-param-list,{&delim-par}))
    v-long-code = integer (entry(8,v-param-list,{&delim-par}))
    
   NO-ERROR.


    run bge\exp-VBRR-p.p ( p_log-handle,
        v-directory,
        v-place,
        v-login,
        v-password,
        v-code_tnp,
        v-code_pool,
        v-code_system,
        v-long-code
        ) .

