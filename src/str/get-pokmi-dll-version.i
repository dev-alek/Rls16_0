
/*------------------------------------------------------------------------
    File        : get-pokmi-dll-version.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Thu Feb 15 14:57:36 MSK 2024
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

&if "{1}" = "class"
&then
method public character get-pokmi-dll-version()
&else
function get-pokmi-dll-version returns character 
&endif 
:
  define variable v-mm-dll as component-handle no-undo .
  define variable v-ret-value as character no-undo .
  
  release object v-mm-dll no-error .
  v-mm-dll = ? .
  
  create value("ADMM.CMethodOfMetering26A") v-mm-dll no-error.
  if error-status:error
  or not valid-handle(v-mm-dll)
  then do :
    release object v-mm-dll no-error .
    v-mm-dll = ? .
    return "error" .
  end .
  else do :
    v-mm-dll:Exec() no-error.
    if v-mm-dll:Result <> 0 then do :
      release object v-mm-dll no-error .
      v-mm-dll = ?.
      
      return "error" .
    end.
    else do :
      v-ret-value = v-mm-dll:DllVersion .
      
      release object v-mm-dll no-error .
      v-mm-dll = ?.
      
      return v-ret-value .
    end .
  end .
end .