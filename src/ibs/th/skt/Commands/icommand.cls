/*

$Revision: 43c09557cdee, 3584, rls $
$Author: DRuban $
$Date: 2023/12/28 12:56:36 $
$Workfile: ICommand.cls $
$Archive: ibs/th/skt/Commands/ICommand.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using ibs.th.skt.Commands.*.
using ibs.th.gbl.sys.objth.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.

class ibs.th.skt.Commands.ICommand inherits objth abstract :
  
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   define protected variable logWrite    as class     LogWrite no-undo.   
   constructor public ICommand (  ):
      super ().
      logWrite = new LogWrite().
   end constructor.

  method abstract public  void Execute_(req as class IRequest, resp as class IResponse).
  
  method public void ContinueExecution(req as class IRequest,resp as class IResponse ):
     resp:condition = resp:STSlist:WriteResponse:NameProp.
     resp:setContent("Данный метот не должен вызываться").
/*     resp:condition = resp:STSlist:WriteResponse:NameProp.
     define variable sss as longchar no-undo.
     define variable vvv as integer no-undo.
     
     sss = "Жизнь удалась111".
     resp:setContent(sss). */
  end.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	destructor public ICommand ( ):
      delete object logWrite.
      
	end destructor.

end class.