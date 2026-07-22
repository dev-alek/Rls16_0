/*

$Revision: 0d5da778db5d, 1549, rls $
$Author: ASMorozov $
$Date: Wed Oct 17 22:18:22 2018 +0300 $
$Workfile: AdapterOra-i506-1c.cls $
$Archive: ibs/th/skt/Adapters/AdapterOra-i506-1c.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using Progress.Lang.*.
using ibs.th.skt.Adapters.*. 
block-level on error undo, throw.


class ibs.th.skt.Adapters.AdapterOra-i506-1c implements IAdapter: 

  {ibs/th/skt/ControlledClients/TSDTT-1c.i}

  define property StrLog as character no-undo
    get.
    set.
  
  define property UserId_ as character no-undo
    get.
    set.


  /*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
		
  method public void WriteDB (output glog as log):
    
    run ibs/th/skt/Adapters/AdapteeProcOra-i506-1c.p
      (
      input table TempTrnDoc,
      input table TempDocLine,
      input UserId_
      ) no-error.
    if error-status:error then
    do:
      assign
        StrLog = return-value
        .
      glog = false.
    end.
    else
      glog = true.

  end method.

  method public void SetTempTable (input table TempTrnDoc, input table TempDocLine, input userId_ as char):
    UserId_ = userId_.
  end method.
  

end class.