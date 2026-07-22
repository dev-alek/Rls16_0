using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.
class ibs.th.skt.Commands.markingcmd inherits ICommand:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "обработчик команд по маркам через сокет" get.
  define public property LogMsg as character no-undo
    get.
    private set.
   define private variable marking     as class  marking no-undo.
   define temp-table tt-code no-undo like ub.code.
   constructor public markingcmd (  ):
      super ().
      marking = new marking().
   end constructor.
  define private variable hndlSocket as handle no-undo.
  method public override void Execute_( input req as ibs.th.skt.Commands.IRequest, resp as class IResponse ):
    def buffer buf_code for ub.code.
    def var vNeedUpd as integer no-undo.
    def var vMarkOnlineResult as char no-undo.
    def var vMark as char no-undo.
    def var vOnlineResult as int no-undo.
    def buffer buf_marking for ub.marking.
    empty temp-table tt-code.
    vMarkOnlineResult = "".
    do transaction:
       hndlsocket = req:HndlSocket.
       marking:hndler(req).
       if not writeSock(marking:SomeStr)
       then do:
         find first buf_code where
                     buf_code.parent eq "GisMt"
                 and buf_code.code   eq "GisMtErr"
         no-lock no-error.
         if avail buf_code then do:
             create tt-code.
             buffer-copy buf_code to tt-code.
         end.
         for each buf_code no-lock where
                  buf_code.parent = "CDN_GisMt":
             create tt-code.
             buffer-copy buf_code to tt-code.
         end.
         vMarkOnlineResult = marking:GetMarkOnlineResult().
         undo.
       end.
    end.
    do transaction:
        for each tt-code:
           find first buf_code where
                      buf_code.parent = tt-code.parent
                  and buf_code.code   = tt-code.code
              exclusive-lock no-wait no-error.
           if avail buf_code then do:
               buffer-copy tt-code to buf_code no-error.
           end.
        end.
        if vMarkOnlineResult <> ""
           and num-entries(vMarkOnlineResult,chr(9)) = 2
        then do:
            assign
               vMark = entry(1,vMarkOnlineResult,chr(9))
               vOnlineResult = int(entry(2,vMarkOnlineResult,chr(9)))
               no-error.
            if vMark <> "" and vOnlineResult <> ?
            then do:
                find first buf_marking exclusive-lock where
                           buf_marking.mark begins vMark
                   no-wait no-error.
                if avail buf_marking then
                   buf_marking.online-result = vOnlineResult .
            end.
        end.
    end.
    vNeedUpd = marking:CheckCdnNeedUpd().
    if vNeedUpd <> 0 then
      run utl/pub-runcdn.p (vNeedUpd).
  end method.
  method private logical writeSock ( arg as longchar ):
    define variable mbuffer  as memptr   no-undo.
    define variable mbuffer1 as memptr   no-undo.
    define variable tempStr  as longchar no-undo.
    define variable glog     as logical  no-undo.
    set-size(mbuffer1) = length (marking:SomeStr, "RAW":U).
    copy-lob
      from object marking:SomeStr
      to object mbuffer1
      convert target codepage "UTF-8".
    if not hndlSocket:connected()
    then do:
       LogWrite:LogStr = " " + "Клиент отключился.".
       return false.
    end.
    glog = hndlsocket:write(mbuffer1,1,get-size(mbuffer1)).
    if not glog
       or hndlsocket:bytes-written ne get-size(mbuffer1)
    then do:
        set-size(mbuffer1) = 0.
        LogWrite:WriteFileToLog("Ошибка при отправке сообщения удаленному клиенту.").
        return false.
    end.
    set-size(mbuffer1) = 0.
    LogWrite:LogStr = LogWrite:LogStr + " " + string (marking:SomeStr).
    return true.
  end method.
        destructor public markingcmd ( ):
      delete object marking.
        end destructor.
end class.
