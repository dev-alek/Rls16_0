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


&scoped-define vssseq {&sequence}             
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

assign                                             
  v-proc-name = substitute( "proc-load-&1", {1} ) 
  v-proc-avail = FALSE                             
.                                                  
if (valid-handle(g#load-rec) <> true) then do:                                           
  run nws/load-rec.p persistent no-error .                                                           
  if error-status :error or (valid-handle(g#load-rec) <> true) then do:                  
    message                                                                                         
      "Error starting nws/load-rec.p" skip                                                           
      error-status :get-message(1) skip                                                             
      return-value skip                                                                             
      view-as alert-box error .                                                                     
    stop .                                                                                          
  end.                                                                                              
end.                                                                                                
if lookup( v-proc-name, g#load-rec:internal-entries ) > 0 then do:                       
  if v-proc-avail = TRUE then do:                                                                   
    return error substitute( "&1. Рассогласованы библиотеки приема новостей для таблицы &2"         
                             ,vss-workfile                                                          
                             ,{1}                                                                 
                           ).                                                                       
  end.                                                                                              
  run value(v-proc-name) in g#load-rec                                                   
      ( input this-procedure                                                                        
       ,input {3}                                                                                 
       ,input {4}                                                                                 
      ).                                                                                            
  assign                                                                                            
    v-proc-avail = TRUE                                                                             
  .                                                                                                 
end.                                                                                                

if v-proc-avail = FALSE then do:                                                                    
  run proc-load-standart in this-procedure                                                          
      ( input {1}                                                                                 
       ,input {2}                                                                                 
       ,input ?                                                                                     
       ,input this-procedure                                                                        
       ,input {4}                                                                                 
       ,output {5}                                                                                
      ) .                                                                                           
end.                                                                                                
