/*

$Revision: 43c09557cdee, 3584, rls $
$Author: DRuban $
$Date: 2023/12/28 12:56:36 $
$Workfile: TickedCommand.cls $
$Archive: ibs/th/skt/Commands/TickedCommand.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.

class ibs.th.skt.Commands.TickedCommand inherits ICommand: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Обработка запросов в сокет по Ticked" get.
  
  &scop CRLF chr(13) + chr(10)
  &scop HdEnd chr(13) + chr(10) + chr(13) + chr(10)

  define public property ErrStatus as logical no-undo 
    get.
    set. 

  define public property LogMsg as character no-undo 
    get.
    private set. 

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   define private variable ticked     as class  Ticked no-undo.   
   constructor public TickedCommand (  ):
      super ().
      ticked = new Ticked().
   end constructor.

  
  define private variable hndlSocket as handle no-undo.

  method public override void Execute_( input req as ibs.th.skt.Commands.IRequest, resp as class IResponse ):
    hndlsocket = req:HndlSocket.
    ticked:AuthorizationTicked(req).
    writeSock("").

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method private logical writeSock ( arg as character ):
    
    define variable mbuffer  as memptr   no-undo.
    define variable mbuffer1 as memptr   no-undo.
    define variable tempStr  as longchar no-undo.
    define variable glog     as logical  no-undo.
    
    
    
    set-size(mbuffer1) = length (ticked:SomeStr, "RAW":U) + 1.
    put-string(mbuffer1,1) = ticked:SomeStr.        
    
    assign
      glog = hndlsocket:write(mbuffer1,1,get-size(mbuffer1)) no-error.
    set-size(mbuffer1) = 0.
    if not glog
      then do:
        LogWrite:LogStr = LogWrite:LogStr + " " + "Ошибка при отправке сообщения удаленному клиенту.".
        ErrStatus = true.
      end.
    return true.
      
  end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	destructor public TickedCommand ( ):
      delete object ticked.
	end destructor.

end class.