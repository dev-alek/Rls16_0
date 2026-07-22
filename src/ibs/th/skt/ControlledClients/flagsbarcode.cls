 
 /*------------------------------------------------------------------------
    File        : flagsdoc
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : asmorozov
    Created     : Thu Mar 07 20:33:18 MSK 2019
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.gbl.*.
block-level on error undo, throw.


class ibs.th.skt.ControlledClients.flagsbarcode inherits flags: 
  
  
  define property isMark as logical no-undo /*Товар с обязательной маркировкой*/
    get:
        return getFlag(1).
    end.
    set (arg as log):
        setFlag(1, arg).
    end.

  define property isEDO as logical no-undo /*Товар с поэкземплярный учетом*/
    get:
        return getFlag(2).
    end.
    set (arg as log):
        setFlag(2, arg).
    end.
    
  define property IsArtic as logical no-undo /*Товар с объемно-артикульным учетом*/
    get:
        return getFlag(3).
    end.
    set (arg as log):
        setFlag(3, arg).
    end.
     
   define property IsTransitional as logical no-undo /*Товар переходного периода учета*/
    get:
        return getFlag(4).
    end.
    set (arg as log):
        setFlag(4, arg).
    end.    
end class.