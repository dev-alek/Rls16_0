using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.
class ibs.th.skt.SktServer:
  define private variable clientControl as class     ClientControl no-undo.
  define private variable hLog          as handle no-undo.
  define public property LogMsg as character no-undo
    get.
    set.
  define private variable logWrite as class   LogWrite no-undo.
  define variable us-tmo           as integer   init 180 no-undo.
  constructor SktServer (  ):
     this-object(?).
  end.
  constructor SktServer (iLog as handle ,iUstmo as integer ):
      this-object(iLog).
      us-tmo = iUstmo.
  end.
  constructor SktServer (iLog as handle ):
         hLog = iLog.
    define variable conf-par   as character no-undo .
    define variable par-type   as character no-undo .
    define variable tsdCommand    as class TSDCommand.
    define variable tickedCommand as class TickedCommand.
    define variable tmCommand     as class TableMenuCommand.
    define variable kioskCommand  as class KioskCommand.
    define variable webCommand    as class webCommand.
    define variable atdclientcmd  as class atdclientcmd.
    define variable THGetInfoCmd  as class THGetInfoCmd.
    define variable AuthMarking   as class markingcmd.
    define variable DeferredCommand   as class DeferredCommand.
    define variable CashSend      as class CashSend.
    define variable FileSend      as class FileSend.
    define variable HelpSkt       as class HelpSkt.
    clientControl = new ClientControl(hLog).
    logWrite = new LogWrite().
    run gbl/conf-rd.p ("ser-wth", "", "", 0, "", "", "", no, output conf-par, output par-type) no-error.
    if not error-status:error  and logical (conf-par) then do:
      tickedCommand = new TickedCommand().
      clientControl:SetCommandForClient("Ticked", tickedCommand).
    end.
    tmCommand = new TableMenuCommand().
    clientControl:SetCommandForClient("TableMenu", tmCommand).
    run gbl/conf-rd.p ("is-byscr", "", "", 0, "", "", "", no, output conf-par, output par-type) no-error.
    if  not error-status:error  and logical (conf-par) then do:
      kioskCommand = new KioskCommand().
      clientControl:SetCommandForClient("kiosk", kioskCommand).
    end.
    run gbl/conf-rd.p ("is-wbsrv", "", "", 0, "", "", "", no, output conf-par, output par-type) no-error.
    if  not error-status:error  and logical (conf-par) then do:
      webCommand = new webCommand().
      clientControl:SetCommandForClient("websrv", webCommand).
    end.
    atdclientcmd = new atdclientcmd ().
    clientControl:SetCommandForClient("atdclient", atdclientcmd).
    THGetInfoCmd = new THGetInfoCmd ().
    clientControl:SetCommandForClient("ThGetInfo", THGetInfoCmd).
    AuthMarking = new markingcmd ().
    clientControl:SetCommandForClient("AuthMarking", AuthMarking).
    DeferredCommand = new DeferredCommand ().
    clientControl:SetCommandForClient("DeferredCommand", DeferredCommand).
    CashSend = new CashSend (hLog).
    clientControl:SetCommandForClient("CashSend", CashSend).
    FileSend = new FileSend ().
    clientControl:SetCommandForClient("FileSend", FileSend).
    run gbl/conf-rd.p ("is-tsd", "", "", 0, "", "", "", no, output conf-par, output par-type) no-error.
    if not error-status:error  and  logical (conf-par) then do:
      tsdCommand = new TSDCommand(FileSend).
      clientControl:SetCommandForClient("TSD", tsdCommand).
    end.
    HelpSkt = new HelpSkt ().
    clientControl:SetCommandForClient("Help", HelpSkt).
  end constructor.
   method public void RequestProcessing (HeadHttp as HeadHttp, content as memptr, hndlSocket as handle):
      define variable req           as class     IRequest      no-undo.
      define variable resp          as class     IResponse     no-undo.
      define variable client_       as character no-undo.
      define variable vDelete as logical no-undo.
      req = new SimpleRequest(HeadHttp).
      resp = new SimpleResponse().
      req:ContentBuff = content.
      logWrite:WriteFileToLog('REQUEST-CONTENT:' + req:Content).
      req:HndlSocket = hndlSocket.
      client_ = identifyClients(req).
      if client_ <> ? then
      do:
         vDelete = clientControl:SendRequest(client_, req, resp).
      end.
      define variable v-err-msg as character no-undo .
      catch exAppErrors as class Progress.Lang.AppError :
         v-err-msg = exAppErrors:ReturnValue .
         if v-err-msg > ""
         then .
         else do :
            v-err-msg = exAppErrors:GetMessage(1) .
            if v-err-msg > ""
            then .
            else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\skt\sktserver.cls" .
         end .
         logWrite:LogStr = v-err-msg + exAppErrors:CallStack.
         vDelete = yes.
      end catch .
      catch exProErrors as class Progress.Lang.ProError :
         v-err-msg = exProErrors:GetMessage(1) .
         if v-err-msg > ""
         then .
         else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\skt\sktserver.cls" .
         logWrite:LogStr = v-err-msg + exProErrors:CallStack.
         vDelete = yes.
      end catch .
      catch exAnyErrors as class Progress.Lang.Error:
         v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\skt\sktserver.cls " + exAnyErrors:GetMessage(1).
         logWrite:LogStr = v-err-msg + exAnyErrors:CallStack.
         vDelete = yes.
      end catch .
      finally:
         if vDelete
         then do:
            socketDisconnect(hndlSocket).
            delete object req no-error.
            delete object resp no-error.
         end.
      end finally.
  end.
   method public void RequestProcessing (HeadHttp as HeadHttp, content as memptr, hndlSocket as handle, lpar as character):
      define variable vDelete as logical no-undo.
      define variable req           as class     IRequest      no-undo.
      define variable resp          as class     IResponse     no-undo.
      define variable client_       as character no-undo.
      req = new SimpleRequest(HeadHttp).
      resp = new SimpleResponse().
      req:ContentBuff = content.
      req:HndlSocket = hndlSocket.
      client_ = identifyClients(req) no-error.
      if    client_ eq ""
         or client_ eq ?
      then
         client_ = "tsd".
      if client_ <> ? then
      do:
         vDelete = clientControl:SendRequest(client_, req, resp, lpar).
      end.
      define variable v-err-msg as character no-undo .
      catch exAppErrors as class Progress.Lang.AppError :
         v-err-msg = exAppErrors:ReturnValue .
         if v-err-msg > ""
         then .
         else do :
            v-err-msg = exAppErrors:GetMessage(1) .
            if v-err-msg > ""
            then .
            else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\skt\sktserver.cls" .
         end .
         logWrite:LogStr = v-err-msg.
         vDelete = yes.
      end catch .
      catch exProErrors as class Progress.Lang.ProError :
         v-err-msg = exProErrors:GetMessage(1) .
         if v-err-msg > ""
         then .
         else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\skt\sktserver.cls" .
         logWrite:LogStr = v-err-msg + exProErrors:CallStack.
         vDelete = yes.
      end catch .
      catch exAnyErrors as class Progress.Lang.Error:
         v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\skt\sktserver.cls " + exAnyErrors:GetMessage(1).
         logWrite:LogStr = v-err-msg + exAnyErrors:CallStack.
         vDelete = yes.
      end catch .
      finally:
         if vDelete
         then do:
            socketDisconnect(hndlSocket).
            delete object req no-error.
            delete object resp no-error.
         end.
      end finally.
   end.
  method private char identifyClients (req           as class     IRequest):
    define variable hRoot   as handle.
    define variable hDoc    as handle.
    def    var      mbuffer as memptr.
    define variable client_ as character no-undo.
    if req:HeadHTTP:queryAdr <> ""
    then do:
      client_ = entry(1,req:HeadHTTP:queryAdr,"/").
      if     not clientControl:availClient(client_)
         and num-entries (req:HeadHTTP:queryAdr,".") eq 2
      then
         client_= "FileSend".
      return client_.
    end.
    else
       client_ = "".
    if not    req:Content matches '*<data req="gds"*'
           or req:Content matches '*<data req="grp"*'
      then do:
      create x-document hDoc.
      create x-noderef  hRoot.
      set-size(mbuffer) = 0.
      set-size(mbuffer) = length(cast(req, ibs.th.skt.Commands.SimpleRequest):Content,'raw') + 2.
      put-string(mbuffer,1) = cast(req, ibs.th.skt.Commands.SimpleRequest):Content.
      define variable loadok as logical no-undo.
      loadok = hDoc:load("memptr",mbuffer,no) no-error.
      if error-status:error or loadok ne yes
      then
         return error "Ошибка при разборе XML документа".
      hdoc:get-document-element(hRoot) no-error.
      assign
        client_ = hRoot:name no-error.
    end.
    if client_ = "slips" or client_ = "spool" or  client_ = "config" or client_ = "fuels" or client_ = "reports"
    then do:
       req:HeadHTTP:queryAdr = client_ + ".xml".
       client_= "FileSend".
    end.
    if not clientControl:availClient(client_) then
    do:
      if    req:Content matches '*<data req="gds"*'
         or req:Content matches '*<data req="grp"*'
        then
      do:
        client_ = "TableMenu".
        logWrite:WriteFileToLog( req:Content + chr(13) + chr(10)).
      end.
      else
      do:
        client_ = "ticked".
      end.
    end.
    return client_.
  end.
  method public logical checkEnd ():
     return clientControl:checkEnd().
  end.
        destructor public SktServer ( ):
    delete object logWrite.
    delete object clientControl no-error.
        end destructor.
                   method public void connproc(hSocket as handle) :
           logWrite:WriteDebugLog(substitute ("Подключено устройстов id подключения &1 Ip: &2 Port: &3",hSocket,hSocket:REMOTE-HOST,hSocket:REMOTE-PORT)).
      def var n as int no-undo.
      define variable v-header      as character no-undo.
      define variable mbuffer-in    as memptr   no-undo.
      define variable mbuffer-hdr   as memptr   no-undo.
      define variable v-bytes       as integer  no-undo.
      define variable v-str         as char     no-undo init "".
      define variable resp-head     as longchar no-undo.
      define variable v-read        as logical  no-undo.
      define variable v-pos-buf     as integer  no-undo.
      define variable HeadHttp as HeadHttp no-undo.
      fix-codepage(resp-head) = "1251" .
      hSocket:set-socket-option('TCP-NODELAY', 'true').
      hSocket:set-socket-option('SO-KEEPALIVE', 'true').
      hSocket:set-socket-option('SO-REUSEADDR', 'true').
      assign
         v-header  = '':U
         v-bytes   = 0
         n         = 0
         v-str     = ""
      resp-head = substitute("HTTP/1.0 400 Bad Request&1Server: 4GL&2",chr(13) + chr(10),chr(13) + chr(10) + chr(13) + chr(10)).
      ContBlock:
      do:
         etime(yes).
         set-size (mbuffer-in) = 0.
         mbuffer-in = ?.
         set-size (mbuffer-hdr) = 33000.
         dwhdr_:
         do while etime < 5000 :
            if n = v-bytes
            then do:
               n = 0.
               v-bytes = hsocket:get-bytes-available().
            end.
            do while n < v-bytes :
               n = n + 1.
               v-pos-buf = v-pos-buf + 1.
               v-read = hSocket:read(mbuffer-hdr, v-pos-buf, 1, 2) no-error .
               if not v-read
               then
                  leave.
               if v-pos-buf > 4
               then
                  v-str = get-string (mbuffer-hdr, v-pos-buf - 3, 4).
               if v-pos-buf > 32000
               then
                  leave.
               if v-str = chr(13) + chr(10) + chr(13) + chr(10)
               then do:
                  v-header = get-string (mbuffer-hdr, 1).
                  v-str = "".
                  v-pos-buf = 0.
                  logWrite:WriteFileToLog('REQUEST-HEADER:' + chr(13) + chr(10) + v-header ).
                  HeadHttp = new HeadHttp(v-header).
                  set-size (mbuffer-in) = 0.
                  set-size (mbuffer-hdr) = 0.
                  set-size (mbuffer-in) = HeadHttp:contentLength.
                  leave dwhdr_.
               end.
            end.
         end.
         if v-header eq ""
         then do:
            logWrite:WriteFileToLog("Test request").
            resp-head =  substitute("HTTP/1.0 200 OK &1Server: 4GL&2",chr(13) + chr(10),chr(13) + chr(10) + chr(13) + chr(10)).
            writeResponse (hSocket , resp-head).
            leave ContBlock.
         end.
         if not valid-object (HeadHttp)
         then do:
            resp-head =  substitute("HTTP/1.0 408 Request Timeout or bad request &1Server: 4GL&2",chr(13) + chr(10),chr(13) + chr(10) + chr(13) + chr(10)).
            writeResponse (hSocket , resp-head).
            leave ContBlock.
         end.
         dw_:
         do while     HeadHttp:contentLength > v-pos-buf
           and etime < us-tmo * 1000
           and hSocket:connected () :
               v-bytes = hsocket:get-bytes-available().
               assign
                  v-read = false
               .
               if v-pos-buf + v-bytes > HeadHttp:contentLength
               then do:
                  logWrite:WriteFileToLog(substitute ('Error:  В Сontent-Length : &1 Пришло: &2 Проигнорировано &3 поледних байт',HeadHttp:contentLength, v-pos-buf + v-bytes, v-pos-buf + v-bytes - HeadHttp:contentLength)).
                  v-bytes = HeadHttp:contentLength - v-pos-buf.
               end.
               v-read = hSocket:read(mbuffer-in, v-pos-buf + 1, v-bytes) .
               if v-read
               then
               assign
                  v-pos-buf = v-pos-buf + v-bytes
               .
         end.
         if       ( mbuffer-in = ?
                  or get-size (mbuffer-in) = ?
                  or get-size (mbuffer-in) = 0)
            and (    HeadHttp:contentType <> "raw"
            and HeadHttp:queryReq = "")
         then do:
            resp-head =  substitute("HTTP/1.0 408 Request Timeout or bad request &1Server: 4GL&2",chr(13) + chr(10),chr(13) + chr(10) + chr(13) + chr(10)).
            writeResponse (hSocket , resp-head).
            leave ContBlock.
         end.
         if     HeadHttp:contentType ne 'text/xml':U
            and HeadHttp:contentType ne 'raw'
            and HeadHttp:queryReq    eq ""
         then do:
            resp-head = substitute("HTTP/1.0 501 Not Implemented&1Server: 4GL&2",chr(13) + chr(10),chr(13) + chr(10) + chr(13) + chr(10)).
            writeResponse (hSocket , resp-head).
            leave ContBlock.
         end.
         if     HeadHttp:contentLength = 0
            and HeadHttp:queryReq eq ""
         then do:
            resp-head = substitute("HTTP/1.0 411 No Content&1Server: 4GL&2",chr(13) + chr(10),chr(13) + chr(10) + chr(13) + chr(10)).
            writeResponse (hSocket , resp-head).
            leave ContBlock.
         end.
         if (
            HeadHttp:contentLength > v-pos-buf)
         then do:
            resp-head =  substitute("HTTP/1.0 408 Request Timeout&1Server: 4GL&2",chr(13) + chr(10),chr(13) + chr(10) + chr(13) + chr(10)).
            writeResponse (hSocket , resp-head).
            leave ContBlock.
         end.
         case true:
            when HeadHttp:queryAdr <> ''
            or
            when HeadHttp:contentType = 'text/xml'
            then do:
               RequestProcessing(HeadHttp,mbuffer-in, hsocket) no-error.
               resp-head = if logWrite:LogStr <> "" then logWrite:LogStr else "OK".
            end.
            when HeadHttp:contentType = 'raw'
            then do:
               RequestProcessing(HeadHttp,mbuffer-in, hsocket, HeadHttp:userAgent) no-error.
               resp-head = if logWrite:LogStr <> "" then logWrite:LogStr else "OK".
            end.
            otherwise do:
               resp-head =  substitute("HTTP/1.0 400 Bad Request&1Server: 4GL&2",chr(13) + chr(10),chr(13) + chr(10) + chr(13) + chr(10)).
               writeResponse (hSocket , resp-head).
            end.
         end case.
         logWrite:LogStr = "".
      end.
      logWrite:WriteFileToLog('RESPONSE: ' + resp-head).
   end.
   method public logical writeResponse (hSocket as handle, resp-head as longchar ):
      define variable mbuffer-out   as memptr   no-undo.
      SET-SIZE(mbuffer-out) = 0.
      SET-SIZE(mbuffer-out) = length(resp-head,'RAW') + 2.
      PUT-STRING(mbuffer-out,1) = resp-head.
      hsocket:write(mbuffer-out,1,length(resp-head,'RAW':U)) no-error.
      socketDisconnect(hsocket).
      set-size (mbuffer-out) = 0.
   end.
   method public logical socketDisconnect (hSocket as handle):
      clientControl:socketDisconnect (hSocket).
   end.
end class.
