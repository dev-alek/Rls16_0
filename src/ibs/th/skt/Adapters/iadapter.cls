/*

$Revision: 6ef98e62eaee, 955, rls $
$Author: ASMorozov $
$Date: Thu Feb 16 15:19:51 2017 +0300 $
$Workfile: IAdapter.cls $
$Archive: ibs/th/skt/Adapters/IAdapter.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using Progress.Lang.*.
block-level on error undo, throw.

interface ibs.th.skt.Adapters.IAdapter:  
      
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void WriteDB(output arg as log).


end interface.