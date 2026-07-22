block-level on error undo, throw.
/* ***************************  Definitions  ************************** */

define variable vss-revision    as character no-undo init "$Revision: $":U.
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U.
define variable vss-date        as character no-undo init "$Date: $":U.
define variable vss-workfile    as character no-undo init "$Workfile: exp-bgecheck-shd.p $":U.
define variable vss-archive     as character no-undo init "$Archive: bge/exp-bgecheck-shd.p $":U.
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
define variable v-directory        as char      no-undo.
define variable v-ftp-address      as char      no-undo .
define variable v-per              as integer   no-undo .
define variable v-login            as char      no-undo .
define variable v-password         as char      no-undo .
define variable p-pack-lim         as int64     no-undo. /* после 90Mb закрываем пакет и делаем новый; 90 * 1024 * 1024 = 94371840 */
define variable date_exp_from      as date      no-undo.
define variable date_exp_to        as date      no-undo.
define variable p-range            as integer   no-undo.
define variable p-host-code        as integer   no-undo.
define variable p-obj-list         as char      no-undo.
define variable p-pay-type-list    as character no-undo.
define variable p-gds-type         as char      no-undo.
define variable p-doc-type-list    as character no-undo.
define variable v-dc-num-full      as character no-undo.
define variable v-inf-bonus        as logical   no-undo.
define variable v-place            as integer   no-undo.
define variable v-code_pool        as char      no-undo.
define variable tb-rs-2            as char      no-undo.
define variable tb-pay-desk-cards  as logical   no-undo.
define variable tb-pay-desk        as logical   no-undo.
define variable tb-parts           as logical   no-undo.
define variable tb-inkass-pay-code as logical   no-undo.
define variable tb-deleted         as logical   no-undo.
define variable tb-chk-pay-code    as logical   no-undo.
define variable tb-cst-code        as logical   no-undo.
define variable tb-exp-checks      as logical   no-undo.
define variable tb-chk-type as character no-undo.
{ref/shd-attr.i}


define variable v-param-list as character no-undo.
define variable v-param-type as character no-undo.

run schedule-attr-value in this-procedure (input integer(p_db-num-char),
    input p_task-type,
    input p_task-num,
    input {&attr-schedule-param-list-h},
    output v-param-list,
    output v-param-type).
/* Разберем их */


v-place  = integer(entry(1,v-param-list,{&delim-par})).
/*message v-place view-as alert-box.*/
if v-place = 1 then
do:


    assign
      
   
        v-directory        = entry (2, v-param-list, {&delim-par})
        v-per              = integer(ENTRY(3, v-param-list, {&delim-par}))
       
        p-range            = integer(entry(4,v-param-list,{&delim-par})) /*По типу кассовых платежей из чеков*/
        p-host-code        = integer(entry(5,v-param-list,{&delim-par})) /*ГТД по строке документа*/
        p-obj-list         = (entry(6,v-param-list,{&delim-par})) /*Удалённые*/
        p-pay-type-list    = (entry(7,v-param-list,{&delim-par})) /*Чеки*/
        p-gds-type         = (entry(8,v-param-list,{&delim-par})) /*По виду оплаты*/
        p-doc-type-list    = (entry(9,v-param-list,{&delim-par})) /*По партиям                */               
        v-dc-num-full      = (entry(10,v-param-list,{&delim-par})) /*По партиям*/
       
        v-inf-bonus        = logical(entry(11,v-param-list,{&delim-par})) /*Выгружать информацию по бонусам*/
        v-code_pool        = (entry(12,v-param-list,{&delim-par}))
        tb-pay-desk-cards  = logical (entry(13,v-param-list,{&delim-par}))
        tb-pay-desk        = logical (entry(14,v-param-list,{&delim-par}))
        tb-parts           = logical(entry(15,v-param-list,{&delim-par}))
        tb-inkass-pay-code = logical (entry(16,v-param-list,{&delim-par}))
        tb-deleted         = logical (entry(17,v-param-list,{&delim-par}))
        tb-chk-pay-code    = logical (entry(18,v-param-list,{&delim-par}))
        tb-cst-code        = logical (entry(19,v-param-list,{&delim-par})) 
        tb-exp-checks      = logical  (entry(20,v-param-list,{&delim-par}))
        tb-rs-2            = entry(21,v-param-list,{&delim-par})
        tb-chk-type = entry(22,v-param-list,{&delim-par})
        no-error.
        p-pack-lim         = 90 no-error.
        if p-pack-lim = ? then p-pack-lim = 0.
        
end.
   
   
if v-place = 2 then 
do :
    assign
                     
        v-ftp-address      = entry (2, v-param-list, {&delim-par})
        v-per              = integer(ENTRY(3, v-param-list, {&delim-par}))
        v-login            = ENTRY(4, v-param-list, {&delim-par})
        v-password         = ENTRY(5, v-param-list, {&delim-par})
        /*                            date_exp_from        = date(entry(6,v-param-list,{&delim-par}))  /*Глобально, по фирме, по объекту*/*/
        /*                            date_exp_to        = date(entry(7,v-param-list,{&delim-par})) /*Все, топливо, услуги*/              */
        p-range            = integer(entry(6,v-param-list,{&delim-par})) /*По типу кассовых платежей из чеков*/
        p-host-code        = integer(entry(7,v-param-list,{&delim-par})) /*ГТД по строке документа*/
        p-obj-list         = (entry(8,v-param-list,{&delim-par})) /*Удалённые*/
        p-pay-type-list    = (entry(9,v-param-list,{&delim-par})) /*Чеки*/
        p-gds-type         = (entry(10,v-param-list,{&delim-par})) /*По виду оплаты*/
        p-doc-type-list    = (entry(11,v-param-list,{&delim-par})) /*По партиям                */               
        v-dc-num-full      = (entry(12,v-param-list,{&delim-par})) /*По партиям*/
       
        v-inf-bonus        = logical(entry(13,v-param-list,{&delim-par})) /*Выгружать информацию по бонусам*/
        v-code_pool        = (entry(14,v-param-list,{&delim-par}))
        tb-pay-desk-cards  = logical (entry(15,v-param-list,{&delim-par}))
        tb-pay-desk        = logical (entry(16,v-param-list,{&delim-par}))
        tb-parts           = logical(entry(17,v-param-list,{&delim-par}))
        tb-inkass-pay-code = logical (entry(18,v-param-list,{&delim-par}))
        tb-deleted         = logical (entry(19,v-param-list,{&delim-par}))
        tb-chk-pay-code    = logical (entry(20,v-param-list,{&delim-par}))
        tb-cst-code        = logical (entry(21,v-param-list,{&delim-par})) 
      tb-exp-checks   =     logical(entry(22,v-param-list,{&delim-par}))
       tb-rs-2 = entry(23,v-param-list,{&delim-par}) 
         tb-chk-type = entry(24,v-param-list,{&delim-par})
       no-error
        .          
        p-pack-lim         = 90 no-error.
        if p-pack-lim = ? then p-pack-lim = 0.

                                       
              
                                 
end.     
                    
if v-place = 1  then  
                
    
    run bge\bgecheck-new.p ( p_log-handle
        , v-directory
        , v-place 
        , ""
        , "" 
        , p-pack-lim
        , date_exp_from  
        , date_exp_to
        , p-range 
        , p-host-code
        , p-obj-list  
        , p-pay-type-list 
        , p-gds-type      
        , p-doc-type-list 
        ,  v-dc-num-full  
        , v-per
        , v-inf-bonus
        , v-code_pool
        , tb-chk-type
        ) .       
           
if v-place = 2  then 
    run bge\bgecheck-new.p ( p_log-handle,
        v-ftp-address
        , v-place
        , v-login
        , v-password
        , p-pack-lim
        , date_exp_from  
        , date_exp_to
        , p-range 
        , p-host-code
        , p-obj-list  
        , p-pay-type-list 
        , p-gds-type      
        , p-doc-type-list  
        ,  v-dc-num-full 
        , v-per
        , v-inf-bonus
        , v-code_pool
        ,tb-chk-type
        ) .