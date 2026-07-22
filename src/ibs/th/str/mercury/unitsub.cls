/*

$Revision: 0f3280859945, 1577, rls $
$Author: SSlivenko $
$Date: Tue Nov 06 04:41:35 2018 +0300 $
$Workfile: unitsub.cls $
$Archive: ibs/th/str/mercury/unitsub.cls $

Сущность TH ВСД


Автор: Морозов Александр Сергеевич
Дата создания: 04/23/18
Author: Morozov Alexandr
Creation date: 04/23/18


*/

using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.str.clients.*.
using ibs.th.str.mercury.*.
block-level on error undo, throw.

class ibs.th.str.mercury.unitsub implements ithsub: 
  
  { cmp/str-glbl.i class}
  

  define property Msg as character no-undo
    get.
    private set.

    
  define property UnitName as character no-undo
    get.
    set.
    
  define property UnitFullName as character no-undo
    get.
    set.
    
  define property UnitGuid as character no-undo
    get.
    set.
  
  define property UnitCoef as decimal no-undo
    get.
    set.


  define property StatusErr as logical no-undo
    get:
      def var err as log no-undo.
      err = StatusErr.
      StatusErr = false.
      return err.
    end.
    private set.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public unitsub (  ):
    
  end constructor.



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