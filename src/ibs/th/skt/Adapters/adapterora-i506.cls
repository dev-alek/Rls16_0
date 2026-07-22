/*

$Revision: 6ef98e62eaee, 955, rls $
$Author: ASMorozov $
$Date: Thu Feb 16 15:19:51 2017 +0300 $
$Workfile: AdapterOra-i506.cls $
$Archive: ibs/th/skt/Adapters/AdapterOra-i506.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using Progress.Lang.*.
using ibs.th.skt.Adapters.*. 
block-level on error undo, throw.


class ibs.th.skt.Adapters.AdapterOra-i506 implements IAdapter: 

  {ibs/th/skt/ControlledClients/TSDTT.i}

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
    
    run ibs/th/skt/Adapters/AdapteeProcOra-i506.p
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