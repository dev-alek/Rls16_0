using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.
class ibs.th.skt.Commands.TableMenuCommand inherits ICommand:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Обработка запросов в сокет сервер для TableMenu" get.
  define public property ErrStatus as logical no-undo
    get.
    set.
  define public property LogMsg as character no-undo
    get.
    set.
   define         variable tm         as class  TableMenu no-undo.
   constructor public TableMenuCommand (  ):
      super ().
      tm = new TableMenu().
   end constructor.
  define private variable hndlSocket as handle no-undo.
  method override public void Execute_( input req as ibs.th.skt.Commands.IRequest, input resp as class IResponse ):
    hndlsocket = req:HndlSocket.
    case true:
      when req:Content matches '*<data req="grp"*' then
        do:
          tm:WriteCSVGrp().
        end.
      when req:Content matches '*<data req="gds"*' then
        do:
          tm:WriteCSVGds(req:Content).
        end.
    end case.
writeSock("").
  end method.
        destructor public TableMenuCommand ( ):
      delete object tm.
        end destructor.
  method private logical writeSock ( arg as character ):
    define variable mbuffer  as memptr   no-undo.
    define variable mbuffer1 as memptr   no-undo.
    define variable tempStr  as longchar no-undo.
    define variable glog     as logical  no-undo.
    set-size(mbuffer1) = 0.
    set-size(mbuffer1) = length (tm:SomeStr, "RAW":U) + 1.
    put-string(mbuffer1,1) = tm:SomeStr.
    tempStr = substitute("HTTP/1.0 200 OK&1Server: 4GL&1Content-Type: text/csv&1Content-Length: &3&2",chr(13) + chr(10),chr(13) + chr(10) + chr(13) + chr(10),get-size(mbuffer1)).
    set-size(mbuffer) = 0.
    set-size(mbuffer) = length (tempStr, "RAW":U) + 1.
    put-string(mbuffer,1) = tempstr.
    assign
      glog = hndlsocket:write(mbuffer,1,length(tempStr,'RAW':U)) no-error.
    set-size(mbuffer) = 0.
    if not glog
      then do:
        LogWrite:LogStr = LogWrite:LogStr + " " + "Ошибка при отправке сообщения удаленному клиенту.".
        ErrStatus = true.
      end.
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
end class.
