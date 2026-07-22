/*

$Revision: 43c09557cdee, 3584, rls $
$Author: DRuban $
$Date: 2023/12/28 12:56:36 $
$Workfile: atdclientcmd.cls $
$Archive: ibs/th/skt/Commands/atdclientcmd.cls $



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

class ibs.th.skt.Commands.atdclientcmd inherits ICommand: 
define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Обработка запросов в сокет сервер для ATD client" get.
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
   define private variable atdcli     as class  atdclient no-undo.   
   constructor public atdclientcmd (  ):
      super ().
      atdcli = new atdclient().
   end constructor.

  
  
  define private variable hndlSocket as handle no-undo.

  method public override void Execute_( input req as ibs.th.skt.Commands.IRequest, resp as class IResponse ):
    
    hndlsocket = req:HndlSocket.
    atdcli:hndler(req).
    resp:Content-Type = "application/json".
    resp:setContent(atdcli:SomeStr).
    resp:condition = resp:STSlist:WriteResponse:NameProp.   

  end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	destructor public atdclientcmd ( ):
      delete object atdcli.
   end destructor.

end class.