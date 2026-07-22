using ibs.th.skt.Commands.*.
using ibs.th.gbl.sys.objth.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.
class ibs.th.skt.Commands.ICommand inherits objth abstract :
   define protected variable logWrite    as class     LogWrite no-undo.
   constructor public ICommand (  ):
      super ().
      logWrite = new LogWrite().
   end constructor.
  method abstract public  void Execute_(req as class IRequest, resp as class IResponse).
  method public void ContinueExecution(req as class IRequest,resp as class IResponse ):
     resp:condition = resp:STSlist:WriteResponse:NameProp.
     resp:setContent("Данный метот не должен вызываться").
  end.
        destructor public ICommand ( ):
      delete object logWrite.
        end destructor.
end class.
