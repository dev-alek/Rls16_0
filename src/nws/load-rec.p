block-level on error undo, throw.
/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ utl/gen-imp.p


Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/27/03
Author: Dmitry Ukhanov
Creation date: 01/27/03

*/

/* Импорт строки из файла */


define variable vss-revision    as character no-undo init "$Revision: b39224d84de3, 3188, rls $":U .                    
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .                 
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:26 $":U .             
define variable vss-workfile    as character no-undo init "$Workfile: gen-imp.p $":U .             
define variable vss-archive     as character no-undo init "$Archive: utl/gen-imp.p $":U . 
define variable vss-description as character no-undo init "загрузка в БД строки".                  
{ cmp/vssrevis.i }                                                                               
{ cmp/trg-def.i  }                                                                               
{ nws/nws-def.i  }                                                                               
{ gbl/key-rec.i  }                                                                               
{ gbl/attr-lib.i  }                                                                              
{ nws/imp-pck1.i }                                                                              

if valid-handle (g#load-rec)                                 
and g#load-rec <> this-procedure :handle                     
and lookup( "proc-load-abc-analysis":U, g#load-rec:internal-entries ) > 0 
then do:                                                                
  message                                                               
    vss-workfile vss-revision vss-description skip                      
    "Попытка повторной загрузки библиотеки" skip                        
    g#load-rec skip                                          
    g#load-rec :type skip                                    
    g#load-rec :file-name skip                               
    valid-handle(g#load-rec) skip                            
    this-procedure :handle skip                                         
    this-procedure :type skip                                           
    this-procedure :file-name skip                                      
    valid-handle(this-procedure) skip                                   
    view-as alert-box error .                                           
  undo, return error return-value .                                     
end.                                                                    
else do:                                                                
  assign                                                                
    g#load-rec = this-procedure :handle                      
  .                                                                     
end.                                                                    
                                                                        
if this-procedure :persistent <> true                                   
then do:                                                                
  message                                                               
    vss-workfile vss-revision vss-description skip                      
    "Ошибка запуска библиотеки" program-name(1) skip                    
    "Попытка запустить ее как обычную процедуру" skip                   
    view-as alert-box error .                                           
end.                                                                    
                                                                        
on delete of this-procedure do:                                         
  assign                                                                
    g#load-rec = ?                                           
  .                                                                     
end.                                                                    

{ nws/inc/imp/def-out/abcanaly.i }
define temp-table wt-abc-analysis no-undo like ub.abc-analysis. 
PROCEDURE proc-load-abc-analysis: /* 1 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-abc-analysis. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-abc-analysis. stop" )   
  on endkey undo, return error substitute( "$proc-load-abc-analysis. endkey" ) 
  :                                                   
    define buffer tb-abc-analysis for ub.abc-analysis.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/abcanaly.i }
    for each wt-abc-analysis  
    on error undo, return error substitute( "$proc-load-abc-analysis(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-abc-analysis . 
    end. 
    create wt-abc-analysis.                    
    run nws-impl in p-imp-handle         
      ( input {&table_abc-analysis}          
       ,input (buffer wt-abc-analysis:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-abc-analysis                 
      where tb-abc-analysis.abc-id = wt-abc-analysis.abc-id
        and tb-abc-analysis.db-num = wt-abc-analysis.db-num
      exclusive-lock no-error.
    { nws/inc/imp/abcanaly.i } 
    delete wt-abc-analysis.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-abc-analysis 1 */

{ nws/inc/imp/def-out/abcxyz-a.i }
define temp-table wt-abcxyz-analysis no-undo like ub.abcxyz-analysis. 
PROCEDURE proc-load-abcxyz-analysis: /* 2 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-abcxyz-analysis. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-abcxyz-analysis. stop" )   
  on endkey undo, return error substitute( "$proc-load-abcxyz-analysis. endkey" ) 
  :                                                   
    define buffer tb-abcxyz-analysis for ub.abcxyz-analysis.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/abcxyz-a.i }
    for each wt-abcxyz-analysis  
    on error undo, return error substitute( "$proc-load-abcxyz-analysis(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-abcxyz-analysis . 
    end. 
    create wt-abcxyz-analysis.                    
    run nws-impl in p-imp-handle         
      ( input {&table_abcxyz-analysis}          
       ,input (buffer wt-abcxyz-analysis:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-abcxyz-analysis                 
      where tb-abcxyz-analysis.abcx-id = wt-abcxyz-analysis.abcx-id
        and tb-abcxyz-analysis.db-num = wt-abcxyz-analysis.db-num
      exclusive-lock no-error.
    { nws/inc/imp/abcxyz-a.i } 
    delete wt-abcxyz-analysis.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-abcxyz-analysis 2 */

{ nws/inc/imp/def-out/add-doc.i }
define temp-table wt-add-doc no-undo like ub.add-doc. 
PROCEDURE proc-load-add-doc: /* 3 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-add-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-add-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-add-doc. endkey" ) 
  :                                                   
    define buffer tb-add-doc for ub.add-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/add-doc.i }
    for each wt-add-doc  
    on error undo, return error substitute( "$proc-load-add-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-add-doc . 
    end. 
    create wt-add-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_add-doc}          
       ,input (buffer wt-add-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-add-doc                 
      where tb-add-doc.doc-code = wt-add-doc.doc-code
      exclusive-lock no-error.
    { nws/inc/imp/add-doc.i } 
    delete wt-add-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-add-doc 3 */

define temp-table wt-bar-code no-undo like ub.bar-code. 
PROCEDURE proc-load-bar-code: /* 4 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-bar-code. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-bar-code. stop" )   
  on endkey undo, return error substitute( "$proc-load-bar-code. endkey" ) 
  :                                                   
    define buffer tb-bar-code for ub.bar-code.            
    define variable compare-log as logical no-undo.   
    for each wt-bar-code  
    on error undo, return error substitute( "$proc-load-bar-code(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-bar-code . 
    end. 
    create wt-bar-code.                    
    run nws-impl in p-imp-handle         
      ( input {&table_bar-code}          
       ,input (buffer wt-bar-code:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-bar-code                 
      where tb-bar-code.b-code = wt-bar-code.b-code
      exclusive-lock no-error.
    { nws/inc/imp/bar-code.i } 
    delete wt-bar-code.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-bar-code 4 */

{ nws/inc/imp/def-out/buyer-gr.i }
define temp-table wt-buyer-group no-undo like ub.buyer-group. 
PROCEDURE proc-load-buyer-group: /* 5 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-buyer-group. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-buyer-group. stop" )   
  on endkey undo, return error substitute( "$proc-load-buyer-group. endkey" ) 
  :                                                   
    define buffer tb-buyer-group for ub.buyer-group.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/buyer-gr.i }
    for each wt-buyer-group  
    on error undo, return error substitute( "$proc-load-buyer-group(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-buyer-group . 
    end. 
    create wt-buyer-group.                    
    run nws-impl in p-imp-handle         
      ( input {&table_buyer-group}          
       ,input (buffer wt-buyer-group:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-buyer-group                 
      where tb-buyer-group.bgr-id = wt-buyer-group.bgr-id
        and tb-buyer-group.bgr-db-num = wt-buyer-group.bgr-db-num
      exclusive-lock no-error.
    { nws/inc/imp/buyer-gr.i } 
    delete wt-buyer-group.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-buyer-group 5 */

{ nws/inc/imp/def-out/buyer-in.i }
define temp-table wt-buyer-in-buyer-group no-undo like ub.buyer-in-buyer-group. 
PROCEDURE proc-load-buyer-in-buyer-group: /* 6 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-buyer-in-buyer-group. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-buyer-in-buyer-group. stop" )   
  on endkey undo, return error substitute( "$proc-load-buyer-in-buyer-group. endkey" ) 
  :                                                   
    define buffer tb-buyer-in-buyer-group for ub.buyer-in-buyer-group.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/buyer-in.i }
    for each wt-buyer-in-buyer-group  
    on error undo, return error substitute( "$proc-load-buyer-in-buyer-group(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-buyer-in-buyer-group . 
    end. 
    create wt-buyer-in-buyer-group.                    
    run nws-impl in p-imp-handle         
      ( input {&table_buyer-in-buyer-group}          
       ,input (buffer wt-buyer-in-buyer-group:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-buyer-in-buyer-group                 
      where tb-buyer-in-buyer-group.bgr-id = wt-buyer-in-buyer-group.bgr-id
        and tb-buyer-in-buyer-group.bgr-db-num = wt-buyer-in-buyer-group.bgr-db-num
        and tb-buyer-in-buyer-group.bbg-obj-type = wt-buyer-in-buyer-group.bbg-obj-type
        and tb-buyer-in-buyer-group.bbg-obj-code = wt-buyer-in-buyer-group.bbg-obj-code
      exclusive-lock no-error.
    { nws/inc/imp/buyer-in.i } 
    delete wt-buyer-in-buyer-group.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-buyer-in-buyer-group 6 */

define temp-table wt-cash-pay no-undo like ub.cash-pay. 
PROCEDURE proc-load-cash-pay: /* 7 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-cash-pay. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-cash-pay. stop" )   
  on endkey undo, return error substitute( "$proc-load-cash-pay. endkey" ) 
  :                                                   
    define buffer tb-cash-pay for ub.cash-pay.            
    define variable compare-log as logical no-undo.   
    for each wt-cash-pay  
    on error undo, return error substitute( "$proc-load-cash-pay(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-cash-pay . 
    end. 
    create wt-cash-pay.                    
    run nws-impl in p-imp-handle         
      ( input {&table_cash-pay}          
       ,input (buffer wt-cash-pay:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-cash-pay                 
      where tb-cash-pay.cdpay-code = wt-cash-pay.cdpay-code
        and tb-cash-pay.curr-code = wt-cash-pay.curr-code
      exclusive-lock no-error.
    { nws/inc/imp/cash-pay.i } 
    delete wt-cash-pay.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-cash-pay 7 */

define temp-table wt-cash-pay-attr no-undo like ub.cash-pay-attr. 
PROCEDURE proc-load-cash-pay-attr: /* 8 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-cash-pay-attr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-cash-pay-attr. stop" )   
  on endkey undo, return error substitute( "$proc-load-cash-pay-attr. endkey" ) 
  :                                                   
    define buffer tb-cash-pay-attr for ub.cash-pay-attr.            
    define variable compare-log as logical no-undo.   
    for each wt-cash-pay-attr  
    on error undo, return error substitute( "$proc-load-cash-pay-attr(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-cash-pay-attr . 
    end. 
    create wt-cash-pay-attr.                    
    run nws-impl in p-imp-handle         
      ( input {&table_cash-pay-attr}          
       ,input (buffer wt-cash-pay-attr:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-cash-pay-attr                 
      where tb-cash-pay-attr.cdpay-code = wt-cash-pay-attr.cdpay-code
        and tb-cash-pay-attr.curr-code = wt-cash-pay-attr.curr-code
        and tb-cash-pay-attr.host-code = wt-cash-pay-attr.host-code
        and tb-cash-pay-attr.obj-type = wt-cash-pay-attr.obj-type
        and tb-cash-pay-attr.obj-code = wt-cash-pay-attr.obj-code
        and tb-cash-pay-attr.attr-code = wt-cash-pay-attr.attr-code
      exclusive-lock no-error.
    { nws/inc/imp/cshpattr.i } 
    delete wt-cash-pay-attr.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-cash-pay-attr 8 */

{ nws/inc/imp/def-out/c-chk-do.i }
define temp-table wt-c-chk-doc no-undo like ub.c-chk-doc. 
PROCEDURE proc-load-c-chk-doc: /* 9 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-chk-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-chk-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-chk-doc. endkey" ) 
  :                                                   
    define buffer tb-c-chk-doc for ub.c-chk-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-chk-do.i }
    for each wt-c-chk-doc  
    on error undo, return error substitute( "$proc-load-c-chk-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-chk-doc . 
    end. 
    create wt-c-chk-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-chk-doc}          
       ,input (buffer wt-c-chk-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-chk-doc                 
      where tb-c-chk-doc.doc-code = wt-c-chk-doc.doc-code
        and tb-c-chk-doc.corr-user-db-num = wt-c-chk-doc.corr-user-db-num
        and tb-c-chk-doc.chip-num = wt-c-chk-doc.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-chk-do.i } 
    delete wt-c-chk-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-chk-doc 9 */

define temp-table wt-clients no-undo like ub.clients. 
PROCEDURE proc-load-clients: /* 10 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-clients. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-clients. stop" )   
  on endkey undo, return error substitute( "$proc-load-clients. endkey" ) 
  :                                                   
    define buffer tb-clients for ub.clients.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/clients.i }
    for each wt-clients  
    on error undo, return error substitute( "$proc-load-clients(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-clients . 
    end. 
    create wt-clients.                    
    run nws-impl in p-imp-handle         
      ( input {&table_clients}          
       ,input (buffer wt-clients:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-clients                 
      where tb-clients.obj-type = wt-clients.obj-type
        and tb-clients.obj-code = wt-clients.obj-code
      exclusive-lock no-error.
    { nws/inc/imp/clients.i } 
    delete wt-clients.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-clients 10 */

define temp-table wt-clients-attr no-undo like ub.clients-attr. 
PROCEDURE proc-load-clients-attr: /* 11 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-clients-attr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-clients-attr. stop" )   
  on endkey undo, return error substitute( "$proc-load-clients-attr. endkey" ) 
  :                                                   
    define buffer tb-clients-attr for ub.clients-attr.            
    define variable compare-log as logical no-undo.   
    for each wt-clients-attr  
    on error undo, return error substitute( "$proc-load-clients-attr(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-clients-attr . 
    end. 
    create wt-clients-attr.                    
    run nws-impl in p-imp-handle         
      ( input {&table_clients-attr}          
       ,input (buffer wt-clients-attr:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-clients-attr                 
      where tb-clients-attr.obj-type = wt-clients-attr.obj-type
        and tb-clients-attr.obj-code = wt-clients-attr.obj-code
        and tb-clients-attr.attr-code = wt-clients-attr.attr-code
      exclusive-lock no-error.
    { nws/inc/imp/clntattr.i } 
    delete wt-clients-attr.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-clients-attr 11 */

{ nws/inc/imp/def-out/contract.i }
define temp-table wt-contract no-undo like ub.contract. 
PROCEDURE proc-load-contract: /* 12 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-contract. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-contract. stop" )   
  on endkey undo, return error substitute( "$proc-load-contract. endkey" ) 
  :                                                   
    define buffer tb-contract for ub.contract.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/contract.i }
    for each wt-contract  
    on error undo, return error substitute( "$proc-load-contract(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-contract . 
    end. 
    create wt-contract.                    
    run nws-impl in p-imp-handle         
      ( input {&table_contract}          
       ,input (buffer wt-contract:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-contract                 
      where tb-contract.host-code = wt-contract.host-code
        and tb-contract.contract-code = wt-contract.contract-code
      exclusive-lock no-error.
    { nws/inc/imp/contract.i } 
    delete wt-contract.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-contract 12 */

{ nws/inc/imp/def-out/c-contr.i }
define temp-table wt-c-contract no-undo like ub.c-contract. 
PROCEDURE proc-load-c-contract: /* 13 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-contract. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-contract. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-contract. endkey" ) 
  :                                                   
    define buffer tb-c-contract for ub.c-contract.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-contr.i }
    for each wt-c-contract  
    on error undo, return error substitute( "$proc-load-c-contract(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-contract . 
    end. 
    create wt-c-contract.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-contract}          
       ,input (buffer wt-c-contract:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-contract                 
      where tb-c-contract.host-code = wt-c-contract.host-code
        and tb-c-contract.contract-code = wt-c-contract.contract-code
        and tb-c-contract.corr-user-db-num = wt-c-contract.corr-user-db-num
        and tb-c-contract.chip-num = wt-c-contract.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-contr.i } 
    delete wt-c-contract.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-contract 13 */

{ nws/inc/imp/def-out/con-spec.i }
define temp-table wt-contract-specif no-undo like ub.contract-specif. 
PROCEDURE proc-load-contract-specif: /* 14 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-contract-specif. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-contract-specif. stop" )   
  on endkey undo, return error substitute( "$proc-load-contract-specif. endkey" ) 
  :                                                   
    define buffer tb-contract-specif for ub.contract-specif.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/con-spec.i }
    for each wt-contract-specif  
    on error undo, return error substitute( "$proc-load-contract-specif(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-contract-specif . 
    end. 
    create wt-contract-specif.                    
    run nws-impl in p-imp-handle         
      ( input {&table_contract-specif}          
       ,input (buffer wt-contract-specif:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-contract-specif                 
      where tb-contract-specif.host-code = wt-contract-specif.host-code
        and tb-contract-specif.contract-num = wt-contract-specif.contract-num
        and tb-contract-specif.gds-code = wt-contract-specif.gds-code
      exclusive-lock no-error.
    { nws/inc/imp/con-spec.i } 
    delete wt-contract-specif.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-contract-specif 14 */

define temp-table wt-db no-undo like ub.db. 
PROCEDURE proc-load-db: /* 15 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-db. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-db. stop" )   
  on endkey undo, return error substitute( "$proc-load-db. endkey" ) 
  :                                                   
    define buffer tb-db for ub.db.            
    define variable compare-log as logical no-undo.   
    for each wt-db  
    on error undo, return error substitute( "$proc-load-db(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-db . 
    end. 
    create wt-db.                    
    run nws-impl in p-imp-handle         
      ( input {&table_db}          
       ,input (buffer wt-db:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-db                 
      where tb-db.db-num = wt-db.db-num
      exclusive-lock no-error.
    { nws/inc/imp/db.i } 
    delete wt-db.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-db 15 */

define temp-table wt-db-status no-undo like ub.db-status. 
PROCEDURE proc-load-db-status: /* 16 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-db-status. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-db-status. stop" )   
  on endkey undo, return error substitute( "$proc-load-db-status. endkey" ) 
  :                                                   
    define buffer tb-db-status for ub.db-status.            
    define variable compare-log as logical no-undo.   
    for each wt-db-status  
    on error undo, return error substitute( "$proc-load-db-status(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-db-status . 
    end. 
    create wt-db-status.                    
    run nws-impl in p-imp-handle         
      ( input {&table_db-status}          
       ,input (buffer wt-db-status:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-db-status                 
      where tb-db-status.db-num = wt-db-status.db-num
      exclusive-lock no-error.
    { nws/inc/imp/db-stat.i } 
    delete wt-db-status.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-db-status 16 */

define temp-table wt-dis-card no-undo like ub.dis-card. 
PROCEDURE proc-load-dis-card: /* 17 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-dis-card. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-dis-card. stop" )   
  on endkey undo, return error substitute( "$proc-load-dis-card. endkey" ) 
  :                                                   
    define buffer tb-dis-card for ub.dis-card.            
    define variable compare-log as logical no-undo.   
    for each wt-dis-card  
    on error undo, return error substitute( "$proc-load-dis-card(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-dis-card . 
    end. 
    create wt-dis-card.                    
    run nws-impl in p-imp-handle         
      ( input {&table_dis-card}          
       ,input (buffer wt-dis-card:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-dis-card                 
      where tb-dis-card.d-card = wt-dis-card.d-card
      exclusive-lock no-error.
    { nws/inc/imp/dis-card.i } 
    delete wt-dis-card.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-dis-card 17 */

define temp-table wt-dis-card-mask no-undo like ub.dis-card-mask. 
PROCEDURE proc-load-dis-card-mask: /* 18 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-dis-card-mask. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-dis-card-mask. stop" )   
  on endkey undo, return error substitute( "$proc-load-dis-card-mask. endkey" ) 
  :                                                   
    define buffer tb-dis-card-mask for ub.dis-card-mask.            
    define variable compare-log as logical no-undo.   
    for each wt-dis-card-mask  
    on error undo, return error substitute( "$proc-load-dis-card-mask(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-dis-card-mask . 
    end. 
    create wt-dis-card-mask.                    
    run nws-impl in p-imp-handle         
      ( input {&table_dis-card-mask}          
       ,input (buffer wt-dis-card-mask:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-dis-card-mask                 
      where tb-dis-card-mask.mask-num = wt-dis-card-mask.mask-num
      exclusive-lock no-error.
    { nws/inc/imp/dc-mask.i } 
    delete wt-dis-card-mask.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-dis-card-mask 18 */

define temp-table wt-dis-card-mask-attr no-undo like ub.dis-card-mask-attr. 
PROCEDURE proc-load-dis-card-mask-attr: /* 19 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-dis-card-mask-attr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-dis-card-mask-attr. stop" )   
  on endkey undo, return error substitute( "$proc-load-dis-card-mask-attr. endkey" ) 
  :                                                   
    define buffer tb-dis-card-mask-attr for ub.dis-card-mask-attr.            
    define variable compare-log as logical no-undo.   
    for each wt-dis-card-mask-attr  
    on error undo, return error substitute( "$proc-load-dis-card-mask-attr(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-dis-card-mask-attr . 
    end. 
    create wt-dis-card-mask-attr.                    
    run nws-impl in p-imp-handle         
      ( input {&table_dis-card-mask-attr}          
       ,input (buffer wt-dis-card-mask-attr:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-dis-card-mask-attr                 
      where tb-dis-card-mask-attr.mask-num = wt-dis-card-mask-attr.mask-num
        and tb-dis-card-mask-attr.attr-code = wt-dis-card-mask-attr.attr-code
      exclusive-lock no-error.
    { nws/inc/imp/dis-ca0.i } 
    delete wt-dis-card-mask-attr.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-dis-card-mask-attr 19 */

{ nws/inc/imp/def-out/dc-prop.i }
define temp-table wt-dis-card-property no-undo like ub.dis-card-property. 
PROCEDURE proc-load-dis-card-property: /* 20 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-dis-card-property. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-dis-card-property. stop" )   
  on endkey undo, return error substitute( "$proc-load-dis-card-property. endkey" ) 
  :                                                   
    define buffer tb-dis-card-property for ub.dis-card-property.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/dc-prop.i }
    for each wt-dis-card-property  
    on error undo, return error substitute( "$proc-load-dis-card-property(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-dis-card-property . 
    end. 
    create wt-dis-card-property.                    
    run nws-impl in p-imp-handle         
      ( input {&table_dis-card-property}          
       ,input (buffer wt-dis-card-property:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-dis-card-property                 
      where tb-dis-card-property.d-card = wt-dis-card-property.d-card
        and tb-dis-card-property.dt-code = wt-dis-card-property.dt-code
        and tb-dis-card-property.node-code = wt-dis-card-property.node-code
        and tb-dis-card-property.host-code = wt-dis-card-property.host-code
        and tb-dis-card-property.obj-type = wt-dis-card-property.obj-type
        and tb-dis-card-property.obj-code = wt-dis-card-property.obj-code
      exclusive-lock no-error.
    { nws/inc/imp/dc-prop.i } 
    delete wt-dis-card-property.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-dis-card-property 20 */

{ nws/inc/imp/def-out/dis-gds.i }
define temp-table wt-dis-gds-rule no-undo like ub.dis-gds-rule. 
PROCEDURE proc-load-dis-gds-rule: /* 21 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-dis-gds-rule. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-dis-gds-rule. stop" )   
  on endkey undo, return error substitute( "$proc-load-dis-gds-rule. endkey" ) 
  :                                                   
    define buffer tb-dis-gds-rule for ub.dis-gds-rule.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/dis-gds.i }
    for each wt-dis-gds-rule  
    on error undo, return error substitute( "$proc-load-dis-gds-rule(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-dis-gds-rule . 
    end. 
    create wt-dis-gds-rule.                    
    run nws-impl in p-imp-handle         
      ( input {&table_dis-gds-rule}          
       ,input (buffer wt-dis-gds-rule:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-dis-gds-rule                 
      where tb-dis-gds-rule.obj-type = wt-dis-gds-rule.obj-type
        and tb-dis-gds-rule.obj-code = wt-dis-gds-rule.obj-code
        and tb-dis-gds-rule.gds-code = wt-dis-gds-rule.gds-code
        and tb-dis-gds-rule.pos-type = wt-dis-gds-rule.pos-type
        and tb-dis-gds-rule.discnt-role = wt-dis-gds-rule.discnt-role
        and tb-dis-gds-rule.nonunique = wt-dis-gds-rule.nonunique
      exclusive-lock no-error.
    { nws/inc/imp/dis-gds.i } 
    delete wt-dis-gds-rule.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-dis-gds-rule 21 */

{ nws/inc/imp/def-out/dis-rule.i }
define temp-table wt-dis-rule no-undo like ub.dis-rule. 
PROCEDURE proc-load-dis-rule: /* 22 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-dis-rule. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-dis-rule. stop" )   
  on endkey undo, return error substitute( "$proc-load-dis-rule. endkey" ) 
  :                                                   
    define buffer tb-dis-rule for ub.dis-rule.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/dis-rule.i }
    for each wt-dis-rule  
    on error undo, return error substitute( "$proc-load-dis-rule(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-dis-rule . 
    end. 
    create wt-dis-rule.                    
    run nws-impl in p-imp-handle         
      ( input {&table_dis-rule}          
       ,input (buffer wt-dis-rule:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-dis-rule                 
      where tb-dis-rule.rule-num = wt-dis-rule.rule-num
      exclusive-lock no-error.
    { nws/inc/imp/dis-rule.i } 
    delete wt-dis-rule.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-dis-rule 22 */

{ nws/inc/imp/def-out/dis-time.i }
define temp-table wt-dis-time-rule no-undo like ub.dis-time-rule. 
PROCEDURE proc-load-dis-time-rule: /* 23 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-dis-time-rule. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-dis-time-rule. stop" )   
  on endkey undo, return error substitute( "$proc-load-dis-time-rule. endkey" ) 
  :                                                   
    define buffer tb-dis-time-rule for ub.dis-time-rule.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/dis-time.i }
    for each wt-dis-time-rule  
    on error undo, return error substitute( "$proc-load-dis-time-rule(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-dis-time-rule . 
    end. 
    create wt-dis-time-rule.                    
    run nws-impl in p-imp-handle         
      ( input {&table_dis-time-rule}          
       ,input (buffer wt-dis-time-rule:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-dis-time-rule                 
      where tb-dis-time-rule.time-rule-num = wt-dis-time-rule.time-rule-num
      exclusive-lock no-error.
    { nws/inc/imp/dis-time.i } 
    delete wt-dis-time-rule.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-dis-time-rule 23 */

{ nws/inc/imp/def-out/docabcd.i }
define temp-table wt-doc-abc-def no-undo like ub.doc-abc-def. 
PROCEDURE proc-load-doc-abc-def: /* 24 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-doc-abc-def. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-doc-abc-def. stop" )   
  on endkey undo, return error substitute( "$proc-load-doc-abc-def. endkey" ) 
  :                                                   
    define buffer tb-doc-abc-def for ub.doc-abc-def.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/docabcd.i }
    for each wt-doc-abc-def  
    on error undo, return error substitute( "$proc-load-doc-abc-def(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-doc-abc-def . 
    end. 
    create wt-doc-abc-def.                    
    run nws-impl in p-imp-handle         
      ( input {&table_doc-abc-def}          
       ,input (buffer wt-doc-abc-def:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-doc-abc-def                 
      where tb-doc-abc-def.doad-id = wt-doc-abc-def.doad-id
        and tb-doc-abc-def.db-num = wt-doc-abc-def.db-num
      exclusive-lock no-error.
    { nws/inc/imp/docabcd.i } 
    delete wt-doc-abc-def.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-doc-abc-def 24 */

{ nws/inc/imp/def-out/docxyzdf.i }
define temp-table wt-doc-xyz-def no-undo like ub.doc-xyz-def. 
PROCEDURE proc-load-doc-xyz-def: /* 25 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-doc-xyz-def. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-doc-xyz-def. stop" )   
  on endkey undo, return error substitute( "$proc-load-doc-xyz-def. endkey" ) 
  :                                                   
    define buffer tb-doc-xyz-def for ub.doc-xyz-def.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/docxyzdf.i }
    for each wt-doc-xyz-def  
    on error undo, return error substitute( "$proc-load-doc-xyz-def(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-doc-xyz-def . 
    end. 
    create wt-doc-xyz-def.                    
    run nws-impl in p-imp-handle         
      ( input {&table_doc-xyz-def}          
       ,input (buffer wt-doc-xyz-def:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-doc-xyz-def                 
      where tb-doc-xyz-def.doxd-id = wt-doc-xyz-def.doxd-id
        and tb-doc-xyz-def.db-num = wt-doc-xyz-def.db-num
      exclusive-lock no-error.
    { nws/inc/imp/docxyzdf.i } 
    delete wt-doc-xyz-def.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-doc-xyz-def 25 */

{ nws/inc/imp/def-out/esroute.i }
define temp-table wt-esys-route no-undo like ub.esys-route. 
PROCEDURE proc-load-esys-route: /* 26 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-esys-route. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-esys-route. stop" )   
  on endkey undo, return error substitute( "$proc-load-esys-route. endkey" ) 
  :                                                   
    define buffer tb-esys-route for ub.esys-route.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/esroute.i }
    for each wt-esys-route  
    on error undo, return error substitute( "$proc-load-esys-route(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-esys-route . 
    end. 
    create wt-esys-route.                    
    run nws-impl in p-imp-handle         
      ( input {&table_esys-route}          
       ,input (buffer wt-esys-route:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-esys-route                 
      where tb-esys-route.esys-id = wt-esys-route.esys-id
        and tb-esys-route.db-num = wt-esys-route.db-num
        and tb-esys-route.esr-cr-db-num = wt-esys-route.esr-cr-db-num
        and tb-esys-route.esr-last-pack = wt-esys-route.esr-last-pack
        and tb-esys-route.esr-tbl-ord = wt-esys-route.esr-tbl-ord
      exclusive-lock no-error.
    { nws/inc/imp/esroute.i } 
    delete wt-esys-route.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-esys-route 26 */

define temp-table wt-ext-classif no-undo like ub.ext-classif. 
PROCEDURE proc-load-ext-classif: /* 27 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-ext-classif. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-ext-classif. stop" )   
  on endkey undo, return error substitute( "$proc-load-ext-classif. endkey" ) 
  :                                                   
    define buffer tb-ext-classif for ub.ext-classif.            
    define variable compare-log as logical no-undo.   
    for each wt-ext-classif  
    on error undo, return error substitute( "$proc-load-ext-classif(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-ext-classif . 
    end. 
    create wt-ext-classif.                    
    run nws-impl in p-imp-handle         
      ( input {&table_ext-classif}          
       ,input (buffer wt-ext-classif:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-ext-classif                 
      where tb-ext-classif.classif-subject = wt-ext-classif.classif-subject
        and tb-ext-classif.classif-name = wt-ext-classif.classif-name
        and tb-ext-classif.db-num = wt-ext-classif.db-num
        and tb-ext-classif.Key#_One = wt-ext-classif.Key#_One
        and tb-ext-classif.Key#_Two = wt-ext-classif.Key#_Two
        and tb-ext-classif.Key#_Three = wt-ext-classif.Key#_Three
        and tb-ext-classif.CharKey_One = wt-ext-classif.CharKey_One
        and tb-ext-classif.CharKey_Two = wt-ext-classif.CharKey_Two
        and tb-ext-classif.CharKey_Three = wt-ext-classif.CharKey_Three
        and tb-ext-classif.nonunique = wt-ext-classif.nonunique
      exclusive-lock no-error.
    { nws/inc/imp/extclass.i } 
    delete wt-ext-classif.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-ext-classif 27 */

define temp-table wt-c-ext-classif no-undo like ub.c-ext-classif. 
PROCEDURE proc-load-c-ext-classif: /* 28 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-ext-classif. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-ext-classif. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-ext-classif. endkey" ) 
  :                                                   
    define buffer tb-c-ext-classif for ub.c-ext-classif.            
    define variable compare-log as logical no-undo.   
    for each wt-c-ext-classif  
    on error undo, return error substitute( "$proc-load-c-ext-classif(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-ext-classif . 
    end. 
    create wt-c-ext-classif.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-ext-classif}          
       ,input (buffer wt-c-ext-classif:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-ext-classif                 
      where tb-c-ext-classif.classif-subject = wt-c-ext-classif.classif-subject
        and tb-c-ext-classif.classif-name = wt-c-ext-classif.classif-name
        and tb-c-ext-classif.db-num = wt-c-ext-classif.db-num
        and tb-c-ext-classif.Key#_One = wt-c-ext-classif.Key#_One
        and tb-c-ext-classif.Key#_Two = wt-c-ext-classif.Key#_Two
        and tb-c-ext-classif.Key#_Three = wt-c-ext-classif.Key#_Three
        and tb-c-ext-classif.CharKey_One = wt-c-ext-classif.CharKey_One
        and tb-c-ext-classif.CharKey_Two = wt-c-ext-classif.CharKey_Two
        and tb-c-ext-classif.CharKey_Three = wt-c-ext-classif.CharKey_Three
        and tb-c-ext-classif.nonunique = wt-c-ext-classif.nonunique
        and tb-c-ext-classif.corr-user-db-num = wt-c-ext-classif.corr-user-db-num
        and tb-c-ext-classif.chip-num = wt-c-ext-classif.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/cextclas.i } 
    delete wt-c-ext-classif.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-ext-classif 28 */

{ nws/inc/imp/def-out/factconn.i }
define temp-table wt-factur-connect no-undo like ub.factur-connect. 
PROCEDURE proc-load-factur-connect: /* 29 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-factur-connect. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-factur-connect. stop" )   
  on endkey undo, return error substitute( "$proc-load-factur-connect. endkey" ) 
  :                                                   
    define buffer tb-factur-connect for ub.factur-connect.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/factconn.i }
    for each wt-factur-connect  
    on error undo, return error substitute( "$proc-load-factur-connect(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-factur-connect . 
    end. 
    create wt-factur-connect.                    
    run nws-impl in p-imp-handle         
      ( input {&table_factur-connect}          
       ,input (buffer wt-factur-connect:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-factur-connect                 
      where tb-factur-connect.db-num = wt-factur-connect.db-num
        and tb-factur-connect.connect-code = wt-factur-connect.connect-code
      exclusive-lock no-error.
    { nws/inc/imp/factconn.i } 
    delete wt-factur-connect.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-factur-connect 29 */

{ nws/inc/imp/def-out/fbr-doc.i }
define temp-table wt-fbr-doc no-undo like ub.fbr-doc. 
PROCEDURE proc-load-fbr-doc: /* 30 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-fbr-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-fbr-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-fbr-doc. endkey" ) 
  :                                                   
    define buffer tb-fbr-doc for ub.fbr-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/fbr-doc.i }
    for each wt-fbr-doc  
    on error undo, return error substitute( "$proc-load-fbr-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-fbr-doc . 
    end. 
    create wt-fbr-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_fbr-doc}          
       ,input (buffer wt-fbr-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-fbr-doc                 
      where tb-fbr-doc.doc-code = wt-fbr-doc.doc-code
      exclusive-lock no-error.
    { nws/inc/imp/fbr-doc.i } 
    delete wt-fbr-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-fbr-doc 30 */

{ nws/inc/imp/def-out/c-fbr-do.i }
define temp-table wt-c-fbr-doc no-undo like ub.c-fbr-doc. 
PROCEDURE proc-load-c-fbr-doc: /* 31 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-fbr-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-fbr-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-fbr-doc. endkey" ) 
  :                                                   
    define buffer tb-c-fbr-doc for ub.c-fbr-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-fbr-do.i }
    for each wt-c-fbr-doc  
    on error undo, return error substitute( "$proc-load-c-fbr-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-fbr-doc . 
    end. 
    create wt-c-fbr-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-fbr-doc}          
       ,input (buffer wt-c-fbr-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-fbr-doc                 
      where tb-c-fbr-doc.doc-code = wt-c-fbr-doc.doc-code
        and tb-c-fbr-doc.corr-user-db-num = wt-c-fbr-doc.corr-user-db-num
        and tb-c-fbr-doc.chip-num = wt-c-fbr-doc.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-fbr-do.i } 
    delete wt-c-fbr-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-fbr-doc 31 */

{ nws/inc/imp/def-out/fbr-pln.i }
define temp-table wt-fbr-pln no-undo like ub.fbr-pln. 
PROCEDURE proc-load-fbr-pln: /* 32 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-fbr-pln. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-fbr-pln. stop" )   
  on endkey undo, return error substitute( "$proc-load-fbr-pln. endkey" ) 
  :                                                   
    define buffer tb-fbr-pln for ub.fbr-pln.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/fbr-pln.i }
    for each wt-fbr-pln  
    on error undo, return error substitute( "$proc-load-fbr-pln(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-fbr-pln . 
    end. 
    create wt-fbr-pln.                    
    run nws-impl in p-imp-handle         
      ( input {&table_fbr-pln}          
       ,input (buffer wt-fbr-pln:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-fbr-pln                 
      where tb-fbr-pln.doc-code = wt-fbr-pln.doc-code
      exclusive-lock no-error.
    { nws/inc/imp/fbr-pln.i } 
    delete wt-fbr-pln.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-fbr-pln 32 */

{ nws/inc/imp/def-out/cfbrpln.i }
define temp-table wt-c-fbr-pln no-undo like ub.c-fbr-pln. 
PROCEDURE proc-load-c-fbr-pln: /* 33 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-fbr-pln. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-fbr-pln. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-fbr-pln. endkey" ) 
  :                                                   
    define buffer tb-c-fbr-pln for ub.c-fbr-pln.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/cfbrpln.i }
    for each wt-c-fbr-pln  
    on error undo, return error substitute( "$proc-load-c-fbr-pln(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-fbr-pln . 
    end. 
    create wt-c-fbr-pln.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-fbr-pln}          
       ,input (buffer wt-c-fbr-pln:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-fbr-pln                 
      where tb-c-fbr-pln.doc-code = wt-c-fbr-pln.doc-code
        and tb-c-fbr-pln.corr-user-db-num = wt-c-fbr-pln.corr-user-db-num
        and tb-c-fbr-pln.chip-num = wt-c-fbr-pln.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/cfbrpln.i } 
    delete wt-c-fbr-pln.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-fbr-pln 33 */

{ nws/inc/imp/def-out/fin-doc.i }
define temp-table wt-fin-doc no-undo like ub.fin-doc. 
PROCEDURE proc-load-fin-doc: /* 34 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-fin-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-fin-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-fin-doc. endkey" ) 
  :                                                   
    define buffer tb-fin-doc for ub.fin-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/fin-doc.i }
    for each wt-fin-doc  
    on error undo, return error substitute( "$proc-load-fin-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-fin-doc . 
    end. 
    create wt-fin-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_fin-doc}          
       ,input (buffer wt-fin-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-fin-doc                 
      where tb-fin-doc.host-code = wt-fin-doc.host-code
        and tb-fin-doc.fin-doc-code = wt-fin-doc.fin-doc-code
      exclusive-lock no-error.
    { nws/inc/imp/fin-doc.i } 
    delete wt-fin-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-fin-doc 34 */

{ nws/inc/imp/def-out/c-fin-dc.i }
define temp-table wt-c-fin-doc no-undo like ub.c-fin-doc. 
PROCEDURE proc-load-c-fin-doc: /* 35 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-fin-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-fin-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-fin-doc. endkey" ) 
  :                                                   
    define buffer tb-c-fin-doc for ub.c-fin-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-fin-dc.i }
    for each wt-c-fin-doc  
    on error undo, return error substitute( "$proc-load-c-fin-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-fin-doc . 
    end. 
    create wt-c-fin-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-fin-doc}          
       ,input (buffer wt-c-fin-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-fin-doc                 
      where tb-c-fin-doc.host-code = wt-c-fin-doc.host-code
        and tb-c-fin-doc.fin-doc-code = wt-c-fin-doc.fin-doc-code
        and tb-c-fin-doc.corr-user-db-num = wt-c-fin-doc.corr-user-db-num
        and tb-c-fin-doc.chip-num = wt-c-fin-doc.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-fin-dc.i } 
    delete wt-c-fin-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-fin-doc 35 */

{ nws/inc/imp/def-out/fin-ob.i }
define temp-table wt-fin-ob no-undo like ub.fin-ob. 
PROCEDURE proc-load-fin-ob: /* 36 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-fin-ob. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-fin-ob. stop" )   
  on endkey undo, return error substitute( "$proc-load-fin-ob. endkey" ) 
  :                                                   
    define buffer tb-fin-ob for ub.fin-ob.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/fin-ob.i }
    for each wt-fin-ob  
    on error undo, return error substitute( "$proc-load-fin-ob(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-fin-ob . 
    end. 
    create wt-fin-ob.                    
    run nws-impl in p-imp-handle         
      ( input {&table_fin-ob}          
       ,input (buffer wt-fin-ob:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-fin-ob                 
      where tb-fin-ob.host-code = wt-fin-ob.host-code
        and tb-fin-ob.doc-code = wt-fin-ob.doc-code
      exclusive-lock no-error.
    { nws/inc/imp/fin-ob.i } 
    delete wt-fin-ob.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-fin-ob 36 */

{ nws/inc/imp/def-out/c-fin-ob.i }
define temp-table wt-c-fin-ob no-undo like ub.c-fin-ob. 
PROCEDURE proc-load-c-fin-ob: /* 37 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-fin-ob. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-fin-ob. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-fin-ob. endkey" ) 
  :                                                   
    define buffer tb-c-fin-ob for ub.c-fin-ob.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-fin-ob.i }
    for each wt-c-fin-ob  
    on error undo, return error substitute( "$proc-load-c-fin-ob(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-fin-ob . 
    end. 
    create wt-c-fin-ob.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-fin-ob}          
       ,input (buffer wt-c-fin-ob:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-fin-ob                 
      where tb-c-fin-ob.host-code = wt-c-fin-ob.host-code
        and tb-c-fin-ob.doc-code = wt-c-fin-ob.doc-code
        and tb-c-fin-ob.corr-user-db-num = wt-c-fin-ob.corr-user-db-num
        and tb-c-fin-ob.chip-num = wt-c-fin-ob.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-fin-ob.i } 
    delete wt-c-fin-ob.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-fin-ob 37 */

{ nws/inc/imp/def-out/fin-ob-b.i }
define temp-table wt-fin-ob-before no-undo like ub.fin-ob-before. 
PROCEDURE proc-load-fin-ob-before: /* 38 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-fin-ob-before. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-fin-ob-before. stop" )   
  on endkey undo, return error substitute( "$proc-load-fin-ob-before. endkey" ) 
  :                                                   
    define buffer tb-fin-ob-before for ub.fin-ob-before.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/fin-ob-b.i }
    for each wt-fin-ob-before  
    on error undo, return error substitute( "$proc-load-fin-ob-before(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-fin-ob-before . 
    end. 
    create wt-fin-ob-before.                    
    run nws-impl in p-imp-handle         
      ( input {&table_fin-ob-before}          
       ,input (buffer wt-fin-ob-before:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-fin-ob-before                 
      where tb-fin-ob-before.host-code = wt-fin-ob-before.host-code
        and tb-fin-ob-before.before-code = wt-fin-ob-before.before-code
      exclusive-lock no-error.
    { nws/inc/imp/fin-ob-b.i } 
    delete wt-fin-ob-before.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-fin-ob-before 38 */

{ nws/inc/imp/def-out/fin-sttm.i }
define temp-table wt-fin-statement no-undo like ub.fin-statement. 
PROCEDURE proc-load-fin-statement: /* 39 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-fin-statement. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-fin-statement. stop" )   
  on endkey undo, return error substitute( "$proc-load-fin-statement. endkey" ) 
  :                                                   
    define buffer tb-fin-statement for ub.fin-statement.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/fin-sttm.i }
    for each wt-fin-statement  
    on error undo, return error substitute( "$proc-load-fin-statement(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-fin-statement . 
    end. 
    create wt-fin-statement.                    
    run nws-impl in p-imp-handle         
      ( input {&table_fin-statement}          
       ,input (buffer wt-fin-statement:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-fin-statement                 
      where tb-fin-statement.host-code = wt-fin-statement.host-code
        and tb-fin-statement.sttm-code = wt-fin-statement.sttm-code
      exclusive-lock no-error.
    { nws/inc/imp/fin-sttm.i } 
    delete wt-fin-statement.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-fin-statement 39 */

{ nws/inc/imp/def-out/c-fin-st.i }
define temp-table wt-c-fin-statement no-undo like ub.c-fin-statement. 
PROCEDURE proc-load-c-fin-statement: /* 40 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-fin-statement. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-fin-statement. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-fin-statement. endkey" ) 
  :                                                   
    define buffer tb-c-fin-statement for ub.c-fin-statement.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-fin-st.i }
    for each wt-c-fin-statement  
    on error undo, return error substitute( "$proc-load-c-fin-statement(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-fin-statement . 
    end. 
    create wt-c-fin-statement.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-fin-statement}          
       ,input (buffer wt-c-fin-statement:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-fin-statement                 
      where tb-c-fin-statement.host-code = wt-c-fin-statement.host-code
        and tb-c-fin-statement.sttm-code = wt-c-fin-statement.sttm-code
        and tb-c-fin-statement.corr-user-db-num = wt-c-fin-statement.corr-user-db-num
        and tb-c-fin-statement.chip-num = wt-c-fin-statement.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-fin-st.i } 
    delete wt-c-fin-statement.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-fin-statement 40 */

define temp-table wt-firm no-undo like ub.firm. 
PROCEDURE proc-load-firm: /* 41 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-firm. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-firm. stop" )   
  on endkey undo, return error substitute( "$proc-load-firm. endkey" ) 
  :                                                   
    define buffer tb-firm for ub.firm.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/firm.i }
    for each wt-firm  
    on error undo, return error substitute( "$proc-load-firm(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-firm . 
    end. 
    create wt-firm.                    
    run nws-impl in p-imp-handle         
      ( input {&table_firm}          
       ,input (buffer wt-firm:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-firm                 
      where tb-firm.firm-code = wt-firm.firm-code
      exclusive-lock no-error.
    { nws/inc/imp/firm.i } 
    delete wt-firm.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-firm 41 */

{ nws/inc/imp/def-out/gds-obj.i }
define temp-table wt-gds-obj no-undo like ub.gds-obj. 
PROCEDURE proc-load-gds-obj: /* 42 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-gds-obj. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-gds-obj. stop" )   
  on endkey undo, return error substitute( "$proc-load-gds-obj. endkey" ) 
  :                                                   
    define buffer tb-gds-obj for ub.gds-obj.            
    define variable compare-log as logical no-undo.   
    for each wt-gds-obj  
    on error undo, return error substitute( "$proc-load-gds-obj(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-gds-obj . 
    end. 
    create wt-gds-obj.                    
    run nws-impl in p-imp-handle         
      ( input {&table_gds-obj}          
       ,input (buffer wt-gds-obj:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-gds-obj                 
      where tb-gds-obj.obj-type = wt-gds-obj.obj-type
        and tb-gds-obj.obj-code = wt-gds-obj.obj-code
        and tb-gds-obj.artic = wt-gds-obj.artic
        and tb-gds-obj.prod-type = wt-gds-obj.prod-type
        and tb-gds-obj.prod-code = wt-gds-obj.prod-code
      exclusive-lock no-error.
    { nws/inc/imp/gds-obj.i } 
    delete wt-gds-obj.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-gds-obj 42 */

{ nws/inc/imp/def-out/gdsoattr.i }
define temp-table wt-gds-obj-attr no-undo like ub.gds-obj-attr. 
PROCEDURE proc-load-gds-obj-attr: /* 43 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-gds-obj-attr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-gds-obj-attr. stop" )   
  on endkey undo, return error substitute( "$proc-load-gds-obj-attr. endkey" ) 
  :                                                   
    define buffer tb-gds-obj-attr for ub.gds-obj-attr.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/gdsoattr.i }
    for each wt-gds-obj-attr  
    on error undo, return error substitute( "$proc-load-gds-obj-attr(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-gds-obj-attr . 
    end. 
    create wt-gds-obj-attr.                    
    run nws-impl in p-imp-handle         
      ( input {&table_gds-obj-attr}          
       ,input (buffer wt-gds-obj-attr:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-gds-obj-attr                 
      where tb-gds-obj-attr.obj-type = wt-gds-obj-attr.obj-type
        and tb-gds-obj-attr.obj-code = wt-gds-obj-attr.obj-code
        and tb-gds-obj-attr.gds-code = wt-gds-obj-attr.gds-code
        and tb-gds-obj-attr.attr-code = wt-gds-obj-attr.attr-code
      exclusive-lock no-error.
    { nws/inc/imp/gdsoattr.i } 
    delete wt-gds-obj-attr.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-gds-obj-attr 43 */

define temp-table wt-assortment-matrix no-undo like ub.assortment-matrix. 
PROCEDURE proc-load-assortment-matrix: /* 44 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-assortment-matrix. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-assortment-matrix. stop" )   
  on endkey undo, return error substitute( "$proc-load-assortment-matrix. endkey" ) 
  :                                                   
    define buffer tb-assortment-matrix for ub.assortment-matrix.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/assortme.i }
    for each wt-assortment-matrix  
    on error undo, return error substitute( "$proc-load-assortment-matrix(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-assortment-matrix . 
    end. 
    create wt-assortment-matrix.                    
    run nws-impl in p-imp-handle         
      ( input {&table_assortment-matrix}          
       ,input (buffer wt-assortment-matrix:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-assortment-matrix                 
      where tb-assortment-matrix.asmt-id = wt-assortment-matrix.asmt-id
        and tb-assortment-matrix.db-num = wt-assortment-matrix.db-num
      exclusive-lock no-error.
    { nws/inc/imp/assortme.i } 
    delete wt-assortment-matrix.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-assortment-matrix 44 */

define temp-table wt-gds-grp-obj-attr no-undo like ub.gds-grp-obj-attr. 
PROCEDURE proc-load-gds-grp-obj-attr: /* 45 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-gds-grp-obj-attr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-gds-grp-obj-attr. stop" )   
  on endkey undo, return error substitute( "$proc-load-gds-grp-obj-attr. endkey" ) 
  :                                                   
    define buffer tb-gds-grp-obj-attr for ub.gds-grp-obj-attr.            
    define variable compare-log as logical no-undo.   
    for each wt-gds-grp-obj-attr  
    on error undo, return error substitute( "$proc-load-gds-grp-obj-attr(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-gds-grp-obj-attr . 
    end. 
    create wt-gds-grp-obj-attr.                    
    run nws-impl in p-imp-handle         
      ( input {&table_gds-grp-obj-attr}          
       ,input (buffer wt-gds-grp-obj-attr:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-gds-grp-obj-attr                 
      where tb-gds-grp-obj-attr.node-code = wt-gds-grp-obj-attr.node-code
        and tb-gds-grp-obj-attr.host-code = wt-gds-grp-obj-attr.host-code
        and tb-gds-grp-obj-attr.obj-type = wt-gds-grp-obj-attr.obj-type
        and tb-gds-grp-obj-attr.obj-code = wt-gds-grp-obj-attr.obj-code
        and tb-gds-grp-obj-attr.attr-code = wt-gds-grp-obj-attr.attr-code
      exclusive-lock no-error.
    { nws/inc/imp/gds-grp1.i } 
    delete wt-gds-grp-obj-attr.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-gds-grp-obj-attr 45 */

{ nws/inc/imp/def-out/global-s.i }
define temp-table wt-global-state no-undo like ub.global-state. 
PROCEDURE proc-load-global-state: /* 46 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-global-state. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-global-state. stop" )   
  on endkey undo, return error substitute( "$proc-load-global-state. endkey" ) 
  :                                                   
    define buffer tb-global-state for ub.global-state.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/global-s.i }
    for each wt-global-state  
    on error undo, return error substitute( "$proc-load-global-state(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-global-state . 
    end. 
    create wt-global-state.                    
    run nws-impl in p-imp-handle         
      ( input {&table_global-state}          
       ,input (buffer wt-global-state:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-global-state                 
      where tb-global-state.gls-id = wt-global-state.gls-id
      exclusive-lock no-error.
    { nws/inc/imp/global-s.i } 
    delete wt-global-state.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-global-state 46 */

{ nws/inc/imp/def-out/goods.i }
define temp-table wt-goods no-undo like ub.goods. 
PROCEDURE proc-load-goods: /* 47 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-goods. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-goods. stop" )   
  on endkey undo, return error substitute( "$proc-load-goods. endkey" ) 
  :                                                   
    define buffer tb-goods for ub.goods.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/goods.i }
    for each wt-goods  
    on error undo, return error substitute( "$proc-load-goods(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-goods . 
    end. 
    create wt-goods.                    
    run nws-impl in p-imp-handle         
      ( input {&table_goods}          
       ,input (buffer wt-goods:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-goods                 
      where tb-goods.gds-code = wt-goods.gds-code
      exclusive-lock no-error.
    { nws/inc/imp/goods.i } 
    delete wt-goods.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-goods 47 */

define temp-table wt-goods-attr no-undo like ub.goods-attr. 
PROCEDURE proc-load-goods-attr: /* 48 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-goods-attr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-goods-attr. stop" )   
  on endkey undo, return error substitute( "$proc-load-goods-attr. endkey" ) 
  :                                                   
    define buffer tb-goods-attr for ub.goods-attr.            
    define variable compare-log as logical no-undo.   
    for each wt-goods-attr  
    on error undo, return error substitute( "$proc-load-goods-attr(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-goods-attr . 
    end. 
    create wt-goods-attr.                    
    run nws-impl in p-imp-handle         
      ( input {&table_goods-attr}          
       ,input (buffer wt-goods-attr:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-goods-attr                 
      where tb-goods-attr.gds-code = wt-goods-attr.gds-code
        and tb-goods-attr.attr-code = wt-goods-attr.attr-code
      exclusive-lock no-error.
    { nws/inc/imp/gds-attr.i } 
    delete wt-goods-attr.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-goods-attr 48 */

{ nws/inc/imp/def-out/gr-obj-p.i }
define temp-table wt-grp-obj-price no-undo like ub.grp-obj-price. 
PROCEDURE proc-load-grp-obj-price: /* 49 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-grp-obj-price. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-grp-obj-price. stop" )   
  on endkey undo, return error substitute( "$proc-load-grp-obj-price. endkey" ) 
  :                                                   
    define buffer tb-grp-obj-price for ub.grp-obj-price.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/gr-obj-p.i }
    for each wt-grp-obj-price  
    on error undo, return error substitute( "$proc-load-grp-obj-price(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-grp-obj-price . 
    end. 
    create wt-grp-obj-price.                    
    run nws-impl in p-imp-handle         
      ( input {&table_grp-obj-price}          
       ,input (buffer wt-grp-obj-price:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-grp-obj-price                 
      where tb-grp-obj-price.gop-id = wt-grp-obj-price.gop-id
        and tb-grp-obj-price.gop-db-num = wt-grp-obj-price.gop-db-num
      exclusive-lock no-error.
    { nws/inc/imp/gr-obj-p.i } 
    delete wt-grp-obj-price.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-grp-obj-price 49 */

{ nws/inc/imp/def-out/icnt-doc.i }
define temp-table wt-icnt-doc no-undo like ub.icnt-doc. 
PROCEDURE proc-load-icnt-doc: /* 50 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-icnt-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-icnt-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-icnt-doc. endkey" ) 
  :                                                   
    define buffer tb-icnt-doc for ub.icnt-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/icnt-doc.i }
    for each wt-icnt-doc  
    on error undo, return error substitute( "$proc-load-icnt-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-icnt-doc . 
    end. 
    create wt-icnt-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_icnt-doc}          
       ,input (buffer wt-icnt-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-icnt-doc                 
      where tb-icnt-doc.doc-code = wt-icnt-doc.doc-code
      exclusive-lock no-error.
    { nws/inc/imp/icnt-doc.i } 
    delete wt-icnt-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-icnt-doc 50 */

{ nws/inc/imp/def-out/inkas.i }
define temp-table wt-inkas no-undo like ub.inkas. 
PROCEDURE proc-load-inkas: /* 51 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-inkas. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-inkas. stop" )   
  on endkey undo, return error substitute( "$proc-load-inkas. endkey" ) 
  :                                                   
    define buffer tb-inkas for ub.inkas.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/inkas.i }
    for each wt-inkas  
    on error undo, return error substitute( "$proc-load-inkas(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-inkas . 
    end. 
    create wt-inkas.                    
    run nws-impl in p-imp-handle         
      ( input {&table_inkas}          
       ,input (buffer wt-inkas:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-inkas                 
      where tb-inkas.inkas-code = wt-inkas.inkas-code
      exclusive-lock no-error.
    { nws/inc/imp/inkas.i } 
    delete wt-inkas.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-inkas 51 */

{ nws/inc/imp/def-out/c-inkas.i }
define temp-table wt-c-inkas no-undo like ub.c-inkas. 
PROCEDURE proc-load-c-inkas: /* 52 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-inkas. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-inkas. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-inkas. endkey" ) 
  :                                                   
    define buffer tb-c-inkas for ub.c-inkas.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-inkas.i }
    for each wt-c-inkas  
    on error undo, return error substitute( "$proc-load-c-inkas(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-inkas . 
    end. 
    create wt-c-inkas.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-inkas}          
       ,input (buffer wt-c-inkas:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-inkas                 
      where tb-c-inkas.inkas-code = wt-c-inkas.inkas-code
        and tb-c-inkas.corr-user-db-num = wt-c-inkas.corr-user-db-num
        and tb-c-inkas.chip-num = wt-c-inkas.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-inkas.i } 
    delete wt-c-inkas.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-inkas 52 */

{ nws/inc/imp/def-out/layout.i }
define temp-table wt-layout no-undo like ub.layout. 
PROCEDURE proc-load-layout: /* 53 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-layout. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-layout. stop" )   
  on endkey undo, return error substitute( "$proc-load-layout. endkey" ) 
  :                                                   
    define buffer tb-layout for ub.layout.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/layout.i }
    for each wt-layout  
    on error undo, return error substitute( "$proc-load-layout(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-layout . 
    end. 
    create wt-layout.                    
    run nws-impl in p-imp-handle         
      ( input {&table_layout}          
       ,input (buffer wt-layout:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-layout                 
      where tb-layout.layout-id = wt-layout.layout-id
      exclusive-lock no-error.
    { nws/inc/imp/layout.i } 
    delete wt-layout.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-layout 53 */

{ nws/inc/imp/def-out/marking.i }
define temp-table wt-marking no-undo like ub.marking. 
PROCEDURE proc-load-marking: /* 54 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-marking. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-marking. stop" )   
  on endkey undo, return error substitute( "$proc-load-marking. endkey" ) 
  :                                                   
    define buffer tb-marking for ub.marking.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/marking.i }
    for each wt-marking  
    on error undo, return error substitute( "$proc-load-marking(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-marking . 
    end. 
    create wt-marking.                    
    run nws-impl in p-imp-handle         
      ( input {&table_marking}          
       ,input (buffer wt-marking:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-marking                 
      where tb-marking.mark = wt-marking.mark
      exclusive-lock no-error.
    if l-counter <> 0 then do:                                                                                      
      return error substitute( "&1 &2. Ошибка обработки записи &3", vss-workfile, vss-revision, {&table_marking} ) 
                   + {&new-line} + "Есть привязанные записи, а обработка идет для одной".                         
    end.                                                                                                            
    if not available tb-marking then do:                                                                             
      create tb-marking.                                                                                             
      assign compare-log = no.                                                                                      
    end.                                                                                                            
    else do:                                                                                                        
      buffer-compare tb-marking TO wt-marking case-sensitive save result in compare-log no-error.                     
    end.                                                                                                            
    if not compare-log then do:                                                                                     
      buffer-copy wt-marking TO tb-marking.                                                                           
    end.                                                                                                            
    delete wt-marking.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-marking 54 */

{ nws/inc/imp/def-out/ord-cons.i }
define temp-table wt-ord-cons no-undo like ub.ord-cons. 
PROCEDURE proc-load-ord-cons: /* 55 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-ord-cons. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-ord-cons. stop" )   
  on endkey undo, return error substitute( "$proc-load-ord-cons. endkey" ) 
  :                                                   
    define buffer tb-ord-cons for ub.ord-cons.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/ord-cons.i }
    for each wt-ord-cons  
    on error undo, return error substitute( "$proc-load-ord-cons(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-ord-cons . 
    end. 
    create wt-ord-cons.                    
    run nws-impl in p-imp-handle         
      ( input {&table_ord-cons}          
       ,input (buffer wt-ord-cons:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-ord-cons                 
      where tb-ord-cons.cons-code = wt-ord-cons.cons-code
      exclusive-lock no-error.
    { nws/inc/imp/ord-cons.i } 
    delete wt-ord-cons.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-ord-cons 55 */

{ nws/inc/imp/def-out/ord-doc.i }
define temp-table wt-ord-doc no-undo like ub.ord-doc. 
PROCEDURE proc-load-ord-doc: /* 56 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-ord-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-ord-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-ord-doc. endkey" ) 
  :                                                   
    define buffer tb-ord-doc for ub.ord-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/ord-doc.i }
    for each wt-ord-doc  
    on error undo, return error substitute( "$proc-load-ord-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-ord-doc . 
    end. 
    create wt-ord-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_ord-doc}          
       ,input (buffer wt-ord-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-ord-doc                 
      where tb-ord-doc.doc-code = wt-ord-doc.doc-code
      exclusive-lock no-error.
    { nws/inc/imp/ord-doc.i } 
    delete wt-ord-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-ord-doc 56 */

{ nws/inc/imp/def-out/c-ord-do.i }
define temp-table wt-c-ord-doc no-undo like ub.c-ord-doc. 
PROCEDURE proc-load-c-ord-doc: /* 57 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-ord-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-ord-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-ord-doc. endkey" ) 
  :                                                   
    define buffer tb-c-ord-doc for ub.c-ord-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-ord-do.i }
    for each wt-c-ord-doc  
    on error undo, return error substitute( "$proc-load-c-ord-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-ord-doc . 
    end. 
    create wt-c-ord-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-ord-doc}          
       ,input (buffer wt-c-ord-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-ord-doc                 
      where tb-c-ord-doc.doc-code = wt-c-ord-doc.doc-code
        and tb-c-ord-doc.corr-user-db-num = wt-c-ord-doc.corr-user-db-num
        and tb-c-ord-doc.chip-num = wt-c-ord-doc.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-ord-do.i } 
    delete wt-c-ord-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-ord-doc 57 */

{ nws/inc/imp/def-out/ord-drcv.i }
define temp-table wt-ord-doc-rcv no-undo like ub.ord-doc-rcv. 
PROCEDURE proc-load-ord-doc-rcv: /* 58 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-ord-doc-rcv. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-ord-doc-rcv. stop" )   
  on endkey undo, return error substitute( "$proc-load-ord-doc-rcv. endkey" ) 
  :                                                   
    define buffer tb-ord-doc-rcv for ub.ord-doc-rcv.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/ord-drcv.i }
    for each wt-ord-doc-rcv  
    on error undo, return error substitute( "$proc-load-ord-doc-rcv(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-ord-doc-rcv . 
    end. 
    create wt-ord-doc-rcv.                    
    run nws-impl in p-imp-handle         
      ( input {&table_ord-doc-rcv}          
       ,input (buffer wt-ord-doc-rcv:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-ord-doc-rcv                 
      where tb-ord-doc-rcv.doc-code = wt-ord-doc-rcv.doc-code
        and tb-ord-doc-rcv.rcv-code = wt-ord-doc-rcv.rcv-code
      exclusive-lock no-error.
    { nws/inc/imp/ord-drcv.i } 
    delete wt-ord-doc-rcv.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-ord-doc-rcv 58 */

define temp-table wt-person no-undo like ub.person. 
PROCEDURE proc-load-person: /* 59 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-person. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-person. stop" )   
  on endkey undo, return error substitute( "$proc-load-person. endkey" ) 
  :                                                   
    define buffer tb-person for ub.person.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/person.i }
    for each wt-person  
    on error undo, return error substitute( "$proc-load-person(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-person . 
    end. 
    create wt-person.                    
    run nws-impl in p-imp-handle         
      ( input {&table_person}          
       ,input (buffer wt-person:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-person                 
      where tb-person.psn-code = wt-person.psn-code
      exclusive-lock no-error.
    { nws/inc/imp/person.i } 
    delete wt-person.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-person 59 */

{ nws/inc/imp/def-out/price-do.i }
define temp-table wt-price-doc no-undo like ub.price-doc. 
PROCEDURE proc-load-price-doc: /* 60 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-price-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-price-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-price-doc. endkey" ) 
  :                                                   
    define buffer tb-price-doc for ub.price-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/price-do.i }
    for each wt-price-doc  
    on error undo, return error substitute( "$proc-load-price-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-price-doc . 
    end. 
    create wt-price-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_price-doc}          
       ,input (buffer wt-price-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-price-doc                 
      where tb-price-doc.doc-num = wt-price-doc.doc-num
      exclusive-lock no-error.
    { nws/inc/imp/price-do.i } 
    delete wt-price-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-price-doc 60 */

{ nws/inc/imp/def-out/c-priced.i }
define temp-table wt-c-price-doc no-undo like ub.c-price-doc. 
PROCEDURE proc-load-c-price-doc: /* 61 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-price-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-price-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-price-doc. endkey" ) 
  :                                                   
    define buffer tb-c-price-doc for ub.c-price-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-priced.i }
    for each wt-c-price-doc  
    on error undo, return error substitute( "$proc-load-c-price-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-price-doc . 
    end. 
    create wt-c-price-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-price-doc}          
       ,input (buffer wt-c-price-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-price-doc                 
      where tb-c-price-doc.doc-num = wt-c-price-doc.doc-num
        and tb-c-price-doc.corr-user-db-num = wt-c-price-doc.corr-user-db-num
        and tb-c-price-doc.chip-num = wt-c-price-doc.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-priced.i } 
    delete wt-c-price-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-price-doc 61 */

{ nws/inc/imp/def-out/prcdof.i }
define temp-table wt-price-doc-forming no-undo like ub.price-doc-forming. 
PROCEDURE proc-load-price-doc-forming: /* 62 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-price-doc-forming. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-price-doc-forming. stop" )   
  on endkey undo, return error substitute( "$proc-load-price-doc-forming. endkey" ) 
  :                                                   
    define buffer tb-price-doc-forming for ub.price-doc-forming.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/prcdof.i }
    for each wt-price-doc-forming  
    on error undo, return error substitute( "$proc-load-price-doc-forming(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-price-doc-forming . 
    end. 
    create wt-price-doc-forming.                    
    run nws-impl in p-imp-handle         
      ( input {&table_price-doc-forming}          
       ,input (buffer wt-price-doc-forming:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-price-doc-forming                 
      where tb-price-doc-forming.plt-id = wt-price-doc-forming.plt-id
        and tb-price-doc-forming.plt-db-num = wt-price-doc-forming.plt-db-num
        and tb-price-doc-forming.pdf-id = wt-price-doc-forming.pdf-id
        and tb-price-doc-forming.pdf-db = wt-price-doc-forming.pdf-db
      exclusive-lock no-error.
    { nws/inc/imp/prcdof.i } 
    delete wt-price-doc-forming.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-price-doc-forming 62 */

{ nws/inc/imp/def-out/cprcdof.i }
define temp-table wt-c-price-doc-forming no-undo like ub.c-price-doc-forming. 
PROCEDURE proc-load-c-price-doc-forming: /* 63 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-price-doc-forming. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-price-doc-forming. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-price-doc-forming. endkey" ) 
  :                                                   
    define buffer tb-c-price-doc-forming for ub.c-price-doc-forming.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/cprcdof.i }
    for each wt-c-price-doc-forming  
    on error undo, return error substitute( "$proc-load-c-price-doc-forming(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-price-doc-forming . 
    end. 
    create wt-c-price-doc-forming.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-price-doc-forming}          
       ,input (buffer wt-c-price-doc-forming:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-price-doc-forming                 
      where tb-c-price-doc-forming.plt-id = wt-c-price-doc-forming.plt-id
        and tb-c-price-doc-forming.plt-db-num = wt-c-price-doc-forming.plt-db-num
        and tb-c-price-doc-forming.pdf-id = wt-c-price-doc-forming.pdf-id
        and tb-c-price-doc-forming.pdf-db = wt-c-price-doc-forming.pdf-db
        and tb-c-price-doc-forming.corr-user-db-num = wt-c-price-doc-forming.corr-user-db-num
        and tb-c-price-doc-forming.chip-num = wt-c-price-doc-forming.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/cprcdof.i } 
    delete wt-c-price-doc-forming.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-price-doc-forming 63 */

{ nws/inc/imp/def-out/prcltyp.i }
define temp-table wt-price-list-type no-undo like ub.price-list-type. 
PROCEDURE proc-load-price-list-type: /* 64 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-price-list-type. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-price-list-type. stop" )   
  on endkey undo, return error substitute( "$proc-load-price-list-type. endkey" ) 
  :                                                   
    define buffer tb-price-list-type for ub.price-list-type.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/prcltyp.i }
    for each wt-price-list-type  
    on error undo, return error substitute( "$proc-load-price-list-type(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-price-list-type . 
    end. 
    create wt-price-list-type.                    
    run nws-impl in p-imp-handle         
      ( input {&table_price-list-type}          
       ,input (buffer wt-price-list-type:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-price-list-type                 
      where tb-price-list-type.plt-id = wt-price-list-type.plt-id
        and tb-price-list-type.plt-db-num = wt-price-list-type.plt-db-num
      exclusive-lock no-error.
    { nws/inc/imp/prcltyp.i } 
    delete wt-price-list-type.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-price-list-type 64 */

{ nws/inc/imp/def-out/cprcltyp.i }
define temp-table wt-c-price-list-type no-undo like ub.c-price-list-type. 
PROCEDURE proc-load-c-price-list-type: /* 65 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-price-list-type. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-price-list-type. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-price-list-type. endkey" ) 
  :                                                   
    define buffer tb-c-price-list-type for ub.c-price-list-type.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/cprcltyp.i }
    for each wt-c-price-list-type  
    on error undo, return error substitute( "$proc-load-c-price-list-type(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-price-list-type . 
    end. 
    create wt-c-price-list-type.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-price-list-type}          
       ,input (buffer wt-c-price-list-type:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-price-list-type                 
      where tb-c-price-list-type.plt-id = wt-c-price-list-type.plt-id
        and tb-c-price-list-type.plt-db-num = wt-c-price-list-type.plt-db-num
        and tb-c-price-list-type.corr-user-db-num = wt-c-price-list-type.corr-user-db-num
        and tb-c-price-list-type.chip-num = wt-c-price-list-type.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/cprcltyp.i } 
    delete wt-c-price-list-type.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-price-list-type 65 */

define temp-table wt-prod-bc no-undo like ub.prod-bc. 
PROCEDURE proc-load-prod-bc: /* 66 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-prod-bc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-prod-bc. stop" )   
  on endkey undo, return error substitute( "$proc-load-prod-bc. endkey" ) 
  :                                                   
    define buffer tb-prod-bc for ub.prod-bc.            
    define variable compare-log as logical no-undo.   
    for each wt-prod-bc  
    on error undo, return error substitute( "$proc-load-prod-bc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-prod-bc . 
    end. 
    create wt-prod-bc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_prod-bc}          
       ,input (buffer wt-prod-bc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-prod-bc                 
      where tb-prod-bc.b-code = wt-prod-bc.b-code
        and tb-prod-bc.b-str = wt-prod-bc.b-str
      exclusive-lock no-error.
    { nws/inc/imp/prod-bc.i } 
    delete wt-prod-bc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-prod-bc 66 */

{ nws/inc/imp/def-out/qnty-gro.i }
define temp-table wt-qnty-group no-undo like ub.qnty-group. 
PROCEDURE proc-load-qnty-group: /* 67 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-qnty-group. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-qnty-group. stop" )   
  on endkey undo, return error substitute( "$proc-load-qnty-group. endkey" ) 
  :                                                   
    define buffer tb-qnty-group for ub.qnty-group.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/qnty-gro.i }
    for each wt-qnty-group  
    on error undo, return error substitute( "$proc-load-qnty-group(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-qnty-group . 
    end. 
    create wt-qnty-group.                    
    run nws-impl in p-imp-handle         
      ( input {&table_qnty-group}          
       ,input (buffer wt-qnty-group:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-qnty-group                 
      where tb-qnty-group.qgr-id = wt-qnty-group.qgr-id
        and tb-qnty-group.qgr-db-num = wt-qnty-group.qgr-db-num
      exclusive-lock no-error.
    { nws/inc/imp/qnty-gro.i } 
    delete wt-qnty-group.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-qnty-group 67 */

{ nws/inc/imp/def-out/rangabcd.i }
define temp-table wt-rang-abc-def no-undo like ub.rang-abc-def. 
PROCEDURE proc-load-rang-abc-def: /* 68 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-rang-abc-def. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-rang-abc-def. stop" )   
  on endkey undo, return error substitute( "$proc-load-rang-abc-def. endkey" ) 
  :                                                   
    define buffer tb-rang-abc-def for ub.rang-abc-def.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/rangabcd.i }
    for each wt-rang-abc-def  
    on error undo, return error substitute( "$proc-load-rang-abc-def(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-rang-abc-def . 
    end. 
    create wt-rang-abc-def.                    
    run nws-impl in p-imp-handle         
      ( input {&table_rang-abc-def}          
       ,input (buffer wt-rang-abc-def:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-rang-abc-def                 
      where tb-rang-abc-def.raad-id = wt-rang-abc-def.raad-id
        and tb-rang-abc-def.db-num = wt-rang-abc-def.db-num
      exclusive-lock no-error.
    { nws/inc/imp/rangabcd.i } 
    delete wt-rang-abc-def.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-rang-abc-def 68 */

{ nws/inc/imp/def-out/rangxyzd.i }
define temp-table wt-rang-xyz-def no-undo like ub.rang-xyz-def. 
PROCEDURE proc-load-rang-xyz-def: /* 69 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-rang-xyz-def. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-rang-xyz-def. stop" )   
  on endkey undo, return error substitute( "$proc-load-rang-xyz-def. endkey" ) 
  :                                                   
    define buffer tb-rang-xyz-def for ub.rang-xyz-def.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/rangxyzd.i }
    for each wt-rang-xyz-def  
    on error undo, return error substitute( "$proc-load-rang-xyz-def(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-rang-xyz-def . 
    end. 
    create wt-rang-xyz-def.                    
    run nws-impl in p-imp-handle         
      ( input {&table_rang-xyz-def}          
       ,input (buffer wt-rang-xyz-def:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-rang-xyz-def                 
      where tb-rang-xyz-def.raxd-id = wt-rang-xyz-def.raxd-id
        and tb-rang-xyz-def.db-num = wt-rang-xyz-def.db-num
      exclusive-lock no-error.
    { nws/inc/imp/rangxyzd.i } 
    delete wt-rang-xyz-def.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-rang-xyz-def 69 */

{ nws/inc/imp/def-out/recipe.i }
define temp-table wt-recipe no-undo like ub.recipe. 
PROCEDURE proc-load-recipe: /* 70 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-recipe. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-recipe. stop" )   
  on endkey undo, return error substitute( "$proc-load-recipe. endkey" ) 
  :                                                   
    define buffer tb-recipe for ub.recipe.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/recipe.i }
    for each wt-recipe  
    on error undo, return error substitute( "$proc-load-recipe(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-recipe . 
    end. 
    create wt-recipe.                    
    run nws-impl in p-imp-handle         
      ( input {&table_recipe}          
       ,input (buffer wt-recipe:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-recipe                 
      where tb-recipe.recipe-code = wt-recipe.recipe-code
      exclusive-lock no-error.
    { nws/inc/imp/recipe.i } 
    delete wt-recipe.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-recipe 70 */

{ nws/inc/imp/def-out/crecipe.i }
define temp-table wt-c-recipe no-undo like ub.c-recipe. 
PROCEDURE proc-load-c-recipe: /* 71 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-recipe. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-recipe. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-recipe. endkey" ) 
  :                                                   
    define buffer tb-c-recipe for ub.c-recipe.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/crecipe.i }
    for each wt-c-recipe  
    on error undo, return error substitute( "$proc-load-c-recipe(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-recipe . 
    end. 
    create wt-c-recipe.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-recipe}          
       ,input (buffer wt-c-recipe:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-recipe                 
      where tb-c-recipe.recipe-code = wt-c-recipe.recipe-code
        and tb-c-recipe.corr-user-db-num = wt-c-recipe.corr-user-db-num
        and tb-c-recipe.chip-num = wt-c-recipe.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/crecipe.i } 
    delete wt-c-recipe.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-recipe 71 */

{ nws/inc/imp/def-out/rvs-doc.i }
define temp-table wt-rvs-doc no-undo like ub.rvs-doc. 
PROCEDURE proc-load-rvs-doc: /* 72 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-rvs-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-rvs-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-rvs-doc. endkey" ) 
  :                                                   
    define buffer tb-rvs-doc for ub.rvs-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/rvs-doc.i }
    for each wt-rvs-doc  
    on error undo, return error substitute( "$proc-load-rvs-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-rvs-doc . 
    end. 
    create wt-rvs-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_rvs-doc}          
       ,input (buffer wt-rvs-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-rvs-doc                 
      where tb-rvs-doc.rvs-code = wt-rvs-doc.rvs-code
      exclusive-lock no-error.
    { nws/inc/imp/rvs-doc.i } 
    delete wt-rvs-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-rvs-doc 72 */

{ nws/inc/imp/def-out/c-rvs-do.i }
define temp-table wt-c-rvs-doc no-undo like ub.c-rvs-doc. 
PROCEDURE proc-load-c-rvs-doc: /* 73 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-rvs-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-rvs-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-rvs-doc. endkey" ) 
  :                                                   
    define buffer tb-c-rvs-doc for ub.c-rvs-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-rvs-do.i }
    for each wt-c-rvs-doc  
    on error undo, return error substitute( "$proc-load-c-rvs-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-rvs-doc . 
    end. 
    create wt-c-rvs-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-rvs-doc}          
       ,input (buffer wt-c-rvs-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-rvs-doc                 
      where tb-c-rvs-doc.rvs-code = wt-c-rvs-doc.rvs-code
        and tb-c-rvs-doc.corr-user-db-num = wt-c-rvs-doc.corr-user-db-num
        and tb-c-rvs-doc.chip-num = wt-c-rvs-doc.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-rvs-do.i } 
    delete wt-c-rvs-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-rvs-doc 73 */

{ nws/inc/imp/def-out/s-f-doc.i }
define temp-table wt-schet-fact-doc no-undo like ub.schet-fact-doc. 
PROCEDURE proc-load-schet-fact-doc: /* 74 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-schet-fact-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-schet-fact-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-schet-fact-doc. endkey" ) 
  :                                                   
    define buffer tb-schet-fact-doc for ub.schet-fact-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/s-f-doc.i }
    for each wt-schet-fact-doc  
    on error undo, return error substitute( "$proc-load-schet-fact-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-schet-fact-doc . 
    end. 
    create wt-schet-fact-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_schet-fact-doc}          
       ,input (buffer wt-schet-fact-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-schet-fact-doc                 
      where tb-schet-fact-doc.db-num = wt-schet-fact-doc.db-num
        and tb-schet-fact-doc.doc-code = wt-schet-fact-doc.doc-code
      exclusive-lock no-error.
    { nws/inc/imp/s-f-doc.i } 
    delete wt-schet-fact-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-schet-fact-doc 74 */

{ nws/inc/imp/def-out/s-f-doc1.i }
define temp-table wt-c-schet-fact-doc no-undo like ub.c-schet-fact-doc. 
PROCEDURE proc-load-c-schet-fact-doc: /* 75 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-schet-fact-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-schet-fact-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-schet-fact-doc. endkey" ) 
  :                                                   
    define buffer tb-c-schet-fact-doc for ub.c-schet-fact-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/s-f-doc1.i }
    for each wt-c-schet-fact-doc  
    on error undo, return error substitute( "$proc-load-c-schet-fact-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-schet-fact-doc . 
    end. 
    create wt-c-schet-fact-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-schet-fact-doc}          
       ,input (buffer wt-c-schet-fact-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-schet-fact-doc                 
      where tb-c-schet-fact-doc.db-num = wt-c-schet-fact-doc.db-num
        and tb-c-schet-fact-doc.doc-code = wt-c-schet-fact-doc.doc-code
        and tb-c-schet-fact-doc.corr-user-db-num = wt-c-schet-fact-doc.corr-user-db-num
        and tb-c-schet-fact-doc.chip-num = wt-c-schet-fact-doc.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/s-f-doc1.i } 
    delete wt-c-schet-fact-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-schet-fact-doc 75 */

{ nws/inc/imp/def-out/shift-ob.i }
define temp-table wt-shift-obj no-undo like ub.shift-obj. 
PROCEDURE proc-load-shift-obj: /* 76 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-shift-obj. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-shift-obj. stop" )   
  on endkey undo, return error substitute( "$proc-load-shift-obj. endkey" ) 
  :                                                   
    define buffer tb-shift-obj for ub.shift-obj.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/shift-ob.i }
    for each wt-shift-obj  
    on error undo, return error substitute( "$proc-load-shift-obj(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-shift-obj . 
    end. 
    create wt-shift-obj.                    
    run nws-impl in p-imp-handle         
      ( input {&table_shift-obj}          
       ,input (buffer wt-shift-obj:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-shift-obj                 
      where tb-shift-obj.obj-type = wt-shift-obj.obj-type
        and tb-shift-obj.obj-code = wt-shift-obj.obj-code
        and tb-shift-obj.shift-date = wt-shift-obj.shift-date
        and tb-shift-obj.shift-num = wt-shift-obj.shift-num
      exclusive-lock no-error.
    { nws/inc/imp/shift-ob.i } 
    delete wt-shift-obj.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-shift-obj 76 */

{ nws/inc/imp/def-out/c-shftob.i }
define temp-table wt-c-shift-obj no-undo like ub.c-shift-obj. 
PROCEDURE proc-load-c-shift-obj: /* 77 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-shift-obj. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-shift-obj. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-shift-obj. endkey" ) 
  :                                                   
    define buffer tb-c-shift-obj for ub.c-shift-obj.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-shftob.i }
    for each wt-c-shift-obj  
    on error undo, return error substitute( "$proc-load-c-shift-obj(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-shift-obj . 
    end. 
    create wt-c-shift-obj.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-shift-obj}          
       ,input (buffer wt-c-shift-obj:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-shift-obj                 
      where tb-c-shift-obj.obj-type = wt-c-shift-obj.obj-type
        and tb-c-shift-obj.obj-code = wt-c-shift-obj.obj-code
        and tb-c-shift-obj.shift-date = wt-c-shift-obj.shift-date
        and tb-c-shift-obj.shift-num = wt-c-shift-obj.shift-num
        and tb-c-shift-obj.corr-user-db-num = wt-c-shift-obj.corr-user-db-num
        and tb-c-shift-obj.chip-num = wt-c-shift-obj.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-shftob.i } 
    delete wt-c-shift-obj.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-shift-obj 77 */

{ nws/inc/imp/def-out/staff.i }
define temp-table wt-staff no-undo like ub.staff. 
PROCEDURE proc-load-staff: /* 78 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-staff. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-staff. stop" )   
  on endkey undo, return error substitute( "$proc-load-staff. endkey" ) 
  :                                                   
    define buffer tb-staff for ub.staff.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/staff.i }
    for each wt-staff  
    on error undo, return error substitute( "$proc-load-staff(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-staff . 
    end. 
    create wt-staff.                    
    run nws-impl in p-imp-handle         
      ( input {&table_staff}          
       ,input (buffer wt-staff:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-staff                 
      where tb-staff.role = wt-staff.role
        and tb-staff.role-level = wt-staff.role-level
        and tb-staff.work-place = wt-staff.work-place
        and tb-staff.staff-code = wt-staff.staff-code
        and tb-staff.date-start = wt-staff.date-start
      exclusive-lock no-error.
    { nws/inc/imp/staff.i } 
    delete wt-staff.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-staff 78 */

{ nws/inc/imp/def-out/stop-l.i }
define temp-table wt-stop-list no-undo like ub.stop-list. 
PROCEDURE proc-load-stop-list: /* 79 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-stop-list. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-stop-list. stop" )   
  on endkey undo, return error substitute( "$proc-load-stop-list. endkey" ) 
  :                                                   
    define buffer tb-stop-list for ub.stop-list.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/stop-l.i }
    for each wt-stop-list  
    on error undo, return error substitute( "$proc-load-stop-list(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-stop-list . 
    end. 
    create wt-stop-list.                    
    run nws-impl in p-imp-handle         
      ( input {&table_stop-list}          
       ,input (buffer wt-stop-list:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-stop-list                 
      where tb-stop-list.classif-type = wt-stop-list.classif-type
        and tb-stop-list.stop-list-code = wt-stop-list.stop-list-code
      exclusive-lock no-error.
    { nws/inc/imp/stop-l.i } 
    delete wt-stop-list.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-stop-list 79 */

{ nws/inc/imp/def-out/sum-grou.i }
define temp-table wt-sum-group no-undo like ub.sum-group. 
PROCEDURE proc-load-sum-group: /* 80 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-sum-group. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-sum-group. stop" )   
  on endkey undo, return error substitute( "$proc-load-sum-group. endkey" ) 
  :                                                   
    define buffer tb-sum-group for ub.sum-group.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/sum-grou.i }
    for each wt-sum-group  
    on error undo, return error substitute( "$proc-load-sum-group(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-sum-group . 
    end. 
    create wt-sum-group.                    
    run nws-impl in p-imp-handle         
      ( input {&table_sum-group}          
       ,input (buffer wt-sum-group:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-sum-group                 
      where tb-sum-group.sgr-id = wt-sum-group.sgr-id
        and tb-sum-group.sgr-db-num = wt-sum-group.sgr-db-num
      exclusive-lock no-error.
    { nws/inc/imp/sum-grou.i } 
    delete wt-sum-group.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-sum-group 80 */

define temp-table wt-tax no-undo like ub.tax. 
PROCEDURE proc-load-tax: /* 81 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-tax. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-tax. stop" )   
  on endkey undo, return error substitute( "$proc-load-tax. endkey" ) 
  :                                                   
    define buffer tb-tax for ub.tax.            
    define variable compare-log as logical no-undo.   
    for each wt-tax  
    on error undo, return error substitute( "$proc-load-tax(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-tax . 
    end. 
    create wt-tax.                    
    run nws-impl in p-imp-handle         
      ( input {&table_tax}          
       ,input (buffer wt-tax:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-tax                 
      where tb-tax.tax-code = wt-tax.tax-code
      exclusive-lock no-error.
    { nws/inc/imp/tax.i } 
    delete wt-tax.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-tax 81 */

define temp-table wt-tax-rate no-undo like ub.tax-rate. 
PROCEDURE proc-load-tax-rate: /* 82 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-tax-rate. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-tax-rate. stop" )   
  on endkey undo, return error substitute( "$proc-load-tax-rate. endkey" ) 
  :                                                   
    define buffer tb-tax-rate for ub.tax-rate.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/tax-rate.i }
    for each wt-tax-rate  
    on error undo, return error substitute( "$proc-load-tax-rate(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-tax-rate . 
    end. 
    create wt-tax-rate.                    
    run nws-impl in p-imp-handle         
      ( input {&table_tax-rate}          
       ,input (buffer wt-tax-rate:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-tax-rate                 
      where tb-tax-rate.tax-code = wt-tax-rate.tax-code
        and tb-tax-rate.rate-code = wt-tax-rate.rate-code
      exclusive-lock no-error.
    { nws/inc/imp/tax-rate.i } 
    delete wt-tax-rate.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-tax-rate 82 */

{ nws/inc/imp/def-out/tax-gds.i }
define temp-table wt-tax-rate-gds no-undo like ub.tax-rate-gds. 
PROCEDURE proc-load-tax-rate-gds: /* 83 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-tax-rate-gds. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-tax-rate-gds. stop" )   
  on endkey undo, return error substitute( "$proc-load-tax-rate-gds. endkey" ) 
  :                                                   
    define buffer tb-tax-rate-gds for ub.tax-rate-gds.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/tax-gds.i }
    for each wt-tax-rate-gds  
    on error undo, return error substitute( "$proc-load-tax-rate-gds(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-tax-rate-gds . 
    end. 
    create wt-tax-rate-gds.                    
    run nws-impl in p-imp-handle         
      ( input {&table_tax-rate-gds}          
       ,input (buffer wt-tax-rate-gds:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-tax-rate-gds                 
      where tb-tax-rate-gds.gds-code = wt-tax-rate-gds.gds-code
        and tb-tax-rate-gds.tax-code = wt-tax-rate-gds.tax-code
        and tb-tax-rate-gds.host-code = wt-tax-rate-gds.host-code
        and tb-tax-rate-gds.obj-type = wt-tax-rate-gds.obj-type
        and tb-tax-rate-gds.obj-code = wt-tax-rate-gds.obj-code
        and tb-tax-rate-gds.fact-order = wt-tax-rate-gds.fact-order
      exclusive-lock no-error.
    { nws/inc/imp/tax-gds.i } 
    delete wt-tax-rate-gds.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-tax-rate-gds 83 */

define temp-table wt-tax-rate-value no-undo like ub.tax-rate-value. 
PROCEDURE proc-load-tax-rate-value: /* 84 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-tax-rate-value. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-tax-rate-value. stop" )   
  on endkey undo, return error substitute( "$proc-load-tax-rate-value. endkey" ) 
  :                                                   
    define buffer tb-tax-rate-value for ub.tax-rate-value.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/tax-val.i }
    for each wt-tax-rate-value  
    on error undo, return error substitute( "$proc-load-tax-rate-value(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-tax-rate-value . 
    end. 
    create wt-tax-rate-value.                    
    run nws-impl in p-imp-handle         
      ( input {&table_tax-rate-value}          
       ,input (buffer wt-tax-rate-value:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-tax-rate-value                 
      where tb-tax-rate-value.tax-code = wt-tax-rate-value.tax-code
        and tb-tax-rate-value.rate-code = wt-tax-rate-value.rate-code
        and tb-tax-rate-value.host-code = wt-tax-rate-value.host-code
        and tb-tax-rate-value.obj-type = wt-tax-rate-value.obj-type
        and tb-tax-rate-value.obj-code = wt-tax-rate-value.obj-code
        and tb-tax-rate-value.fact-order = wt-tax-rate-value.fact-order
      exclusive-lock no-error.
    { nws/inc/imp/tax-val.i } 
    delete wt-tax-rate-value.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-tax-rate-value 84 */

define temp-table wt-thbj-attr no-undo like ub.thbj-attr. 
PROCEDURE proc-load-thbj-attr: /* 85 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-thbj-attr. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-thbj-attr. stop" )   
  on endkey undo, return error substitute( "$proc-load-thbj-attr. endkey" ) 
  :                                                   
    define buffer tb-thbj-attr for ub.thbj-attr.            
    define variable compare-log as logical no-undo.   
    for each wt-thbj-attr  
    on error undo, return error substitute( "$proc-load-thbj-attr(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-thbj-attr . 
    end. 
    create wt-thbj-attr.                    
    run nws-impl in p-imp-handle         
      ( input {&table_thbj-attr}          
       ,input (buffer wt-thbj-attr:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-thbj-attr                 
      where tb-thbj-attr.obj-type = wt-thbj-attr.obj-type
        and tb-thbj-attr.obj-code = wt-thbj-attr.obj-code
        and tb-thbj-attr.upper-prop-code = wt-thbj-attr.upper-prop-code
        and tb-thbj-attr.prop-code = wt-thbj-attr.prop-code
      exclusive-lock no-error.
    { nws/inc/imp/thbjattr.i } 
    delete wt-thbj-attr.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-thbj-attr 85 */

{ nws/inc/imp/def-out/trn-doc.i }
define temp-table wt-trn-doc no-undo like ub.trn-doc. 
PROCEDURE proc-load-trn-doc: /* 86 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-trn-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-trn-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-trn-doc. endkey" ) 
  :                                                   
    define buffer tb-trn-doc for ub.trn-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/trn-doc.i }
    for each wt-trn-doc  
    on error undo, return error substitute( "$proc-load-trn-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-trn-doc . 
    end. 
    create wt-trn-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_trn-doc}          
       ,input (buffer wt-trn-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-trn-doc                 
      where tb-trn-doc.doc-code = wt-trn-doc.doc-code
      exclusive-lock no-error.
    { nws/inc/imp/trn-doc.i } 
    delete wt-trn-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-trn-doc 86 */

{ nws/inc/imp/def-out/c-trn-do.i }
define temp-table wt-c-trn-doc no-undo like ub.c-trn-doc. 
PROCEDURE proc-load-c-trn-doc: /* 87 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-trn-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-trn-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-trn-doc. endkey" ) 
  :                                                   
    define buffer tb-c-trn-doc for ub.c-trn-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-trn-do.i }
    for each wt-c-trn-doc  
    on error undo, return error substitute( "$proc-load-c-trn-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-trn-doc . 
    end. 
    create wt-c-trn-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-trn-doc}          
       ,input (buffer wt-c-trn-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-trn-doc                 
      where tb-c-trn-doc.doc-code = wt-c-trn-doc.doc-code
        and tb-c-trn-doc.corr-user-db-num = wt-c-trn-doc.corr-user-db-num
        and tb-c-trn-doc.chip-num = wt-c-trn-doc.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-trn-do.i } 
    delete wt-c-trn-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-trn-doc 87 */

{ nws/inc/imp/def-out/turnbmai.i }
define temp-table wt-turnover-buyer-main no-undo like ub.turnover-buyer-main. 
PROCEDURE proc-load-turnover-buyer-main: /* 88 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-turnover-buyer-main. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-turnover-buyer-main. stop" )   
  on endkey undo, return error substitute( "$proc-load-turnover-buyer-main. endkey" ) 
  :                                                   
    define buffer tb-turnover-buyer-main for ub.turnover-buyer-main.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/turnbmai.i }
    for each wt-turnover-buyer-main  
    on error undo, return error substitute( "$proc-load-turnover-buyer-main(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-turnover-buyer-main . 
    end. 
    create wt-turnover-buyer-main.                    
    run nws-impl in p-imp-handle         
      ( input {&table_turnover-buyer-main}          
       ,input (buffer wt-turnover-buyer-main:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-turnover-buyer-main                 
      where tb-turnover-buyer-main.cli-type = wt-turnover-buyer-main.cli-type
        and tb-turnover-buyer-main.cli-code = wt-turnover-buyer-main.cli-code
        and tb-turnover-buyer-main.obj-type = wt-turnover-buyer-main.obj-type
        and tb-turnover-buyer-main.obj-code = wt-turnover-buyer-main.obj-code
      exclusive-lock no-error.
    { nws/inc/imp/turnbmai.i } 
    delete wt-turnover-buyer-main.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-turnover-buyer-main 88 */

{ nws/inc/imp/def-out/tnvgroup.i }
define temp-table wt-turnover-group no-undo like ub.turnover-group. 
PROCEDURE proc-load-turnover-group: /* 89 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-turnover-group. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-turnover-group. stop" )   
  on endkey undo, return error substitute( "$proc-load-turnover-group. endkey" ) 
  :                                                   
    define buffer tb-turnover-group for ub.turnover-group.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/tnvgroup.i }
    for each wt-turnover-group  
    on error undo, return error substitute( "$proc-load-turnover-group(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-turnover-group . 
    end. 
    create wt-turnover-group.                    
    run nws-impl in p-imp-handle         
      ( input {&table_turnover-group}          
       ,input (buffer wt-turnover-group:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-turnover-group                 
      where tb-turnover-group.tog-id = wt-turnover-group.tog-id
        and tb-turnover-group.tog-db-num = wt-turnover-group.tog-db-num
      exclusive-lock no-error.
    { nws/inc/imp/tnvgroup.i } 
    delete wt-turnover-group.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-turnover-group 89 */

{ nws/inc/imp/def-out/wth-doc.i }
define temp-table wt-wth-doc no-undo like ub.wth-doc. 
PROCEDURE proc-load-wth-doc: /* 90 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-wth-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-wth-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-wth-doc. endkey" ) 
  :                                                   
    define buffer tb-wth-doc for ub.wth-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/wth-doc.i }
    for each wt-wth-doc  
    on error undo, return error substitute( "$proc-load-wth-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-wth-doc . 
    end. 
    create wt-wth-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_wth-doc}          
       ,input (buffer wt-wth-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-wth-doc                 
      where tb-wth-doc.doc-code = wt-wth-doc.doc-code
      exclusive-lock no-error.
    { nws/inc/imp/wth-doc.i } 
    delete wt-wth-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-wth-doc 90 */

{ nws/inc/imp/def-out/c-wth-do.i }
define temp-table wt-c-wth-doc no-undo like ub.c-wth-doc. 
PROCEDURE proc-load-c-wth-doc: /* 91 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-c-wth-doc. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-c-wth-doc. stop" )   
  on endkey undo, return error substitute( "$proc-load-c-wth-doc. endkey" ) 
  :                                                   
    define buffer tb-c-wth-doc for ub.c-wth-doc.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/c-wth-do.i }
    for each wt-c-wth-doc  
    on error undo, return error substitute( "$proc-load-c-wth-doc(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-c-wth-doc . 
    end. 
    create wt-c-wth-doc.                    
    run nws-impl in p-imp-handle         
      ( input {&table_c-wth-doc}          
       ,input (buffer wt-c-wth-doc:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-c-wth-doc                 
      where tb-c-wth-doc.doc-code = wt-c-wth-doc.doc-code
        and tb-c-wth-doc.corr-user-db-num = wt-c-wth-doc.corr-user-db-num
        and tb-c-wth-doc.chip-num = wt-c-wth-doc.chip-num
      exclusive-lock no-error.
    { nws/inc/imp/c-wth-do.i } 
    delete wt-c-wth-doc.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-c-wth-doc 91 */

{ nws/inc/imp/def-out/xyzanaly.i }
define temp-table wt-xyz-analysis no-undo like ub.xyz-analysis. 
PROCEDURE proc-load-xyz-analysis: /* 92 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-xyz-analysis. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-xyz-analysis. stop" )   
  on endkey undo, return error substitute( "$proc-load-xyz-analysis. endkey" ) 
  :                                                   
    define buffer tb-xyz-analysis for ub.xyz-analysis.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/xyzanaly.i }
    for each wt-xyz-analysis  
    on error undo, return error substitute( "$proc-load-xyz-analysis(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-xyz-analysis . 
    end. 
    create wt-xyz-analysis.                    
    run nws-impl in p-imp-handle         
      ( input {&table_xyz-analysis}          
       ,input (buffer wt-xyz-analysis:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-xyz-analysis                 
      where tb-xyz-analysis.xyz-id = wt-xyz-analysis.xyz-id
        and tb-xyz-analysis.db-num = wt-xyz-analysis.db-num
      exclusive-lock no-error.
    { nws/inc/imp/xyzanaly.i } 
    delete wt-xyz-analysis.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-xyz-analysis 92 */

define temp-table wt-code no-undo like ub.code. 
PROCEDURE proc-load-code: /* 93 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-code. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-code. stop" )   
  on endkey undo, return error substitute( "$proc-load-code. endkey" ) 
  :                                                   
    define buffer tb-code for ub.code.            
    define variable compare-log as logical no-undo.   
    for each wt-code  
    on error undo, return error substitute( "$proc-load-code(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-code . 
    end. 
    create wt-code.                    
    run nws-impl in p-imp-handle         
      ( input {&table_code}          
       ,input (buffer wt-code:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-code                 
      where tb-code.parent = wt-code.parent
        and tb-code.code = wt-code.code
      exclusive-lock no-error.
    { nws/inc/imp/code.i } 
    delete wt-code.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-code 93 */

{ nws/inc/imp/def-out/utd.i }
define temp-table wt-utd no-undo like ub.utd. 
PROCEDURE proc-load-utd: /* 94 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-utd. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-utd. stop" )   
  on endkey undo, return error substitute( "$proc-load-utd. endkey" ) 
  :                                                   
    define buffer tb-utd for ub.utd.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/utd.i }
    for each wt-utd  
    on error undo, return error substitute( "$proc-load-utd(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-utd . 
    end. 
    create wt-utd.                    
    run nws-impl in p-imp-handle         
      ( input {&table_utd}          
       ,input (buffer wt-utd:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-utd                 
      where tb-utd.db-num = wt-utd.db-num
        and tb-utd.doc-id = wt-utd.doc-id
      exclusive-lock no-error.
    { nws/inc/imp/utd.i } 
    delete wt-utd.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-utd 94 */

define temp-table wt-chk-slip-head no-undo like ub.chk-slip-head. 
PROCEDURE proc-load-chk-slip-head: /* 95 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-chk-slip-head. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-chk-slip-head. stop" )   
  on endkey undo, return error substitute( "$proc-load-chk-slip-head. endkey" ) 
  :                                                   
    define buffer tb-chk-slip-head for ub.chk-slip-head.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/chk-slip-head.i }
    for each wt-chk-slip-head  
    on error undo, return error substitute( "$proc-load-chk-slip-head(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-chk-slip-head . 
    end. 
    create wt-chk-slip-head.                    
    run nws-impl in p-imp-handle         
      ( input {&table_chk-slip-head}          
       ,input (buffer wt-chk-slip-head:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-chk-slip-head                 
      where tb-chk-slip-head.db-num = wt-chk-slip-head.db-num
        and tb-chk-slip-head.ID = wt-chk-slip-head.ID
        and tb-chk-slip-head.CheckID = wt-chk-slip-head.CheckID
        and tb-chk-slip-head.RRN = wt-chk-slip-head.RRN
      exclusive-lock no-error.
    if l-counter <> 0 then do:                                                                                      
      return error substitute( "&1 &2. Ошибка обработки записи &3", vss-workfile, vss-revision, {&table_chk-slip-head} ) 
                   + {&new-line} + "Есть привязанные записи, а обработка идет для одной".                         
    end.                                                                                                            
    if not available tb-chk-slip-head then do:                                                                             
      create tb-chk-slip-head.                                                                                             
      assign compare-log = no.                                                                                      
    end.                                                                                                            
    else do:                                                                                                        
      buffer-compare tb-chk-slip-head TO wt-chk-slip-head case-sensitive save result in compare-log no-error.                     
    end.                                                                                                            
    if not compare-log then do:                                                                                     
      buffer-copy wt-chk-slip-head TO tb-chk-slip-head.                                                                           
    end.                                                                                                            
    delete wt-chk-slip-head.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-chk-slip-head 95 */

define temp-table wt-chk-slip-string no-undo like ub.chk-slip-string. 
PROCEDURE proc-load-chk-slip-string: /* 96 */
  define input parameter p-imp-handle as handle  no-undo.
  define input parameter p-pck-num    as integer no-undo.
  define input parameter l-counter    as integer no-undo.
  do                                                  
  on error  undo, return error substitute( "$proc-load-chk-slip-string. &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) 
  on stop   undo, return error substitute( "$proc-load-chk-slip-string. stop" )   
  on endkey undo, return error substitute( "$proc-load-chk-slip-string. endkey" ) 
  :                                                   
    define buffer tb-chk-slip-string for ub.chk-slip-string.            
    define variable compare-log as logical no-undo.   
    { nws/inc/imp/def-ins/chk-slip-string.i }
    for each wt-chk-slip-string  
    on error undo, return error substitute( "$proc-load-chk-slip-string(del-wt-). &1&2&3", return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )  
    :
      delete wt-chk-slip-string . 
    end. 
    create wt-chk-slip-string.                    
    run nws-impl in p-imp-handle         
      ( input {&table_chk-slip-string}          
       ,input (buffer wt-chk-slip-string:handle)  
      ) no-error.                        
    if error-status :error then do:      
      return error return-value .        
    end.                                 
    find first tb-chk-slip-string                 
      where tb-chk-slip-string.db-num = wt-chk-slip-string.db-num
        and tb-chk-slip-string.ID = wt-chk-slip-string.ID
        and tb-chk-slip-string.CheckID = wt-chk-slip-string.CheckID
        and tb-chk-slip-string.RRN = wt-chk-slip-string.RRN
        and tb-chk-slip-string.str-num = wt-chk-slip-string.str-num
      exclusive-lock no-error.
    if l-counter <> 0 then do:                                                                                      
      return error substitute( "&1 &2. Ошибка обработки записи &3", vss-workfile, vss-revision, {&table_chk-slip-string} ) 
                   + {&new-line} + "Есть привязанные записи, а обработка идет для одной".                         
    end.                                                                                                            
    if not available tb-chk-slip-string then do:                                                                             
      create tb-chk-slip-string.                                                                                             
      assign compare-log = no.                                                                                      
    end.                                                                                                            
    else do:                                                                                                        
      buffer-compare tb-chk-slip-string TO wt-chk-slip-string case-sensitive save result in compare-log no-error.                     
    end.                                                                                                            
    if not compare-log then do:                                                                                     
      buffer-copy wt-chk-slip-string TO tb-chk-slip-string.                                                                           
    end.                                                                                                            
    delete wt-chk-slip-string.                                                                  
  end.                                                                                 
END PROCEDURE. /* proc-load-chk-slip-string 96 */

