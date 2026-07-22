/*

$Revision: c40b85de8d6c, 956, rls $
$Author: SSlivenko $
$Date: Thu Feb 16 15:19:57 2017 +0300 $
$Workfile: AdapterWebSrv-TrnDoc.cls $
$Archive: ibs/th/skt/Adapters/AdapterWebSrv-TrnDoc.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using Progress.Lang.*.
using ibs.th.skt.Adapters.*. 
block-level on error undo, throw.


class ibs.th.skt.Adapters.AdapterWebSrv-TrnDoc implements IAdapter: 

  {ibs/th/skt/ControlledClients/websrvTT.i}

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
    define variable ERR as logical no-undo init no .
    run ibs/th/skt/Adapters/AdapteeWebSrv-TrnDoc.p
      (
      input table TempTrnDoc,
      input table TempDocLine,
      input table TempDocAttr,
      input table TempGdsDtl,
      input table TempParts,
      output ERR
      ) no-error.
    if ERR then
    do:
      assign
        StrLog = return-value
        .
      glog = false.
    end.
    else
      glog = true.

  end method.
  
  method public void SetTempTable (input table TempTrnDoc,
                                   input table TempDocLine,
                                   input table TempGdsDtl,
                                   input table TempParts,
                                   input table TempDocAttr):
    
    
  end method.

end class.