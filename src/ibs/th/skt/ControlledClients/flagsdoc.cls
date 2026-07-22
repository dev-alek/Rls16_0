 
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


class ibs.th.skt.ControlledClients.flagsdoc inherits flags: 
  
  
  define property isDocMarkOn as logical no-undo /*документ включает в себя товары требующие обязательной маркировки*/
    get:
      return getflag (1).
    end.
    set (arg as log):
       setFlag (1,arg).
    end.

end class.