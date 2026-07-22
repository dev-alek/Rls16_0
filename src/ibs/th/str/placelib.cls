/*

$Revision: 1d6ea42ddaad, 1178, rls $
$Author: EShklyar $
$Date: Thu Dec 14 02:20:27 2017 +0300 $
$Workfile: placelib.cls $
$Archive: ibs/th/str/placelib.cls $



Автор: Шкляр Елена Львовна
Дата создания: 01/30/15
Author: Elena Shklyar
Creation date: 01/30/15

*/

using Progress.Lang.*.
block-level on error undo, throw.

class ibs.th.str.placelib: 

  define property ReturnMsg as character no-undo
    get.
    private set.

  define variable hndl-proc-placelib as handle.
 
  constructor public placelib ():
    
    run str\placelib.p persistent (output hndl-proc-placelib) no-error.
    
  end constructor.

  method public void placelib_get-attr (  
    input p-code as character,
    input p-obj-code as integer,
    input p-obj-type as character,
    input p-pl-code  as integer,
    output v-value   as character,
    output p-ok      as logical):
    
    run placelib_get-attr in hndl-proc-placelib (   
      input p-code,
      input p-obj-code,
      input p-obj-type,
      input p-pl-code,
      output v-value,
      output p-ok) no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end.


  method public void placelib_write-attr (  
    input p-code as character,
    input p-obj-code as integer,
    input p-obj-type as character,
    input p-pl-code  as integer,
    input v-value   as character,
    output p-ok      as logical):
    
    run placelib_write-attr in hndl-proc-placelib (   
      input p-code,
      input p-obj-code,
      input p-obj-type,
      input p-pl-code,
      input v-value,
      output p-ok) no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end.

  destructor public placelib ():
    
    delete object hndl-proc-placelib no-error.
    
    if error-status:error
      then 
    do:
      
    end.
    
  end destructor.
  

end class.