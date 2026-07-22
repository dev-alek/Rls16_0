/*

$Revision: fd21875b889d, 1394, rls $
$Author: ASMorozov $
$Date: Thu Jun 28 15:24:33 2018 +0300 $
$Workfile: gdsmercsub.cls $
$Archive: ibs/th/str/mercury/gdsmercsub.cls $

Сущность TH товар меркурия


Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/
using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.str.mercury.*.
using ibs.th.str.gds.*.
block-level on error undo, throw.

class ibs.th.str.mercury.gdsmercsub implements ithsub: 
  
    
  define property ID as integer no-undo
    get.
    set.
    
  define property DBNum as integer no-undo
    get.
    set.  

  define property GdsCode as integer no-undo
    get.
    set. 

  define property UUID as character no-undo
    get.
    set.  

  define property GUID_ as character no-undo
    get.
    set.

  define property MercName as character no-undo
    get.
    set.
    
  define property DateCr as date no-undo
    get.
    set.
    
  define property DateUpdate as date no-undo
    get.
    set.

  define property ProdType as character no-undo
    get.
    set.

  define property GUIDType as character no-undo
    get.
    set.

  define property GUIDSubType as character no-undo
    get.
    set.

  define property StatusErr as logical no-undo
    get.
    private set.

  define property Msg as character no-undo
    get.
    private set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public gdsmercsub (  ):
    

    
  end constructor.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public logical checkuuid( uuid as character ):
    
    
    
    return true.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void setMsg( arg as character ):
    
    Msg = arg.
    
  end.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void setStatusErr( arg as logical ):
    
    StatusErr = arg.
    
  end.
  
  


end class.