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
  define public property ErrStatus as logical no-undo
    get.
    set.
  define public property LogMsg as character no-undo
    get.
    private set.
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
        destructor public atdclientcmd ( ):
      delete object atdcli.
   end destructor.
end class.
