/*

$Revision: 94ef014b26b5, 1116, rls $
$Author: EShklyar $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: specattr.cls $
$Archive: ibs/th/str/specattr.cls $



Автор: Шкляр Елена Львовна
Дата создания: 01/30/15
Author: Elena Shklyar
Creation date: 01/30/15

*/

using Progress.Lang.*.
block-level on error undo, throw.

class ibs.th.str.specattr: 

  define property ReturnMsg as character no-undo
    get.
    private set.

  define variable hndl-proc-spec-attr as handle.
 
  constructor public specattr ():
    
    run str\specattr.p persistent (output hndl-proc-spec-attr) no-error.
    
  end constructor.

  method public void write-bonus (  
         input p-contract-num as integer,
         input p-host-code as integer,
         input p-gds-code as integer,
         input v-bonus as decimal):
    
    run write-bonus in hndl-proc-spec-attr (   
       input p-contract-num
      ,input p-host-code
      ,input p-gds-code
      ,input v-bonus
      ) no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end.

  method public void read-bonus (  
         input p-contract-num as integer,
         input p-host-code as integer,
         input p-gds-code as integer,
         output v-bonus as decimal):
    
    run read-bonus in hndl-proc-spec-attr (   
       input p-contract-num
      ,input p-host-code
      ,input p-gds-code
      ,output v-bonus
      ) no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end.  
  
  
    method public void write-prc-min (  
         input p-contract-num as integer,
         input p-host-code as integer,
         input p-gds-code as integer,
         input v-prc-min as decimal):
    
    run write-pc-min in hndl-proc-spec-attr (   
       input p-contract-num
      ,input p-host-code
      ,input p-gds-code
      ,input v-prc-min
      ) no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end.
  
  
    method public void read-prc-min (  
         input p-contract-num as integer,
         input p-host-code as integer,
         input p-gds-code as integer,
         output v-prc-min as decimal):
    
    run read-prc-min in hndl-proc-spec-attr (   
       input p-contract-num
      ,input p-host-code
      ,input p-gds-code
      ,output v-prc-min
      ) no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end.
  
    method public void write-retro-bonus (  
         input p-contract-num as integer,
         input p-host-code as integer,
         input p-gds-code as integer,
         input v-retro-bonus as character):
    
    run write-retro-bonus in hndl-proc-spec-attr (   
       input p-contract-num
      ,input p-host-code
      ,input p-gds-code
      ,input v-retro-bonus
      ) no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end.
  
    method public void read-retro-bonus (  
         input p-contract-num as integer,
         input p-host-code as integer,
         input p-gds-code as integer,
         output v-retro-bonus as decimal):
    
    run read-retro-bonus in hndl-proc-spec-attr (   
       input p-contract-num
      ,input p-host-code
      ,input p-gds-code
      ,output v-retro-bonus
      ) no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end.
  
  

  destructor public specattr ():
    
    delete object hndl-proc-spec-attr no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end destructor.
  

end class.