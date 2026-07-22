 
/*------------------------------------------------------------------------
   File        : logger
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : asmorozov
   Created     : Thu Feb 20 04:32:13 MSK 2020
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.gbl.logger.putout.
block-level on error undo, throw.


class ibs.th.gbl.logger: 
  
   define private variable out as class putout no-undo.
  
    /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public logger ( inOut as class putout ):
    super ().
/*    out =  inOut.*/
  end constructor.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void EventHndlr(inMsg as char):
/*    out:PutMessage(inMsg).*/
    return.
  end method.  
  


end class.