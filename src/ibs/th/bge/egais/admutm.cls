/*------------------------------------------------------------------------
   File        : 
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : asmorozov
   Created     : 
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.bge.egais.*.
using Ibs.Th.Gbl.ProgressBar.
block-level on error undo, throw.

class ibs.th.bge.egais.admutm inherits EGAISUTM:

  {cmp/str-glbl.i class}
  {ibs/th/bge/egais/wb-egais.i}
  
&scop display-message    run write-log-and-file in inLogHandle (  ~
        input 1                                                      ~
      , input LogFileName                                            ~
      , input 1                                                      ~
      , input ~{&my-message~})  
  
  define stream outstr.
  
  define private buffer buf_ext-sys for ub.ext-system.
  define private variable parameters    as character no-undo.
  define private variable inFileName    as character no-undo.
  define private variable inData        as character no-undo.
  define private variable outData       as character no-undo.
  define private variable cmd           as character no-undo.
  define private variable prsXMLDocWB   as class     ParserXMLDocWB no-undo.
  define private variable prgObj        as class     ProgressBar    no-undo .
  define private variable FSRAR         as character no-undo.
  define private variable LogFileName   as character no-undo init "shd-free.log".
  define private variable DocDate       as date      no-undo.
  define private variable IsSentInvoVer as logical   no-undo.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  define property glog as logical no-undo
    get.
    set.

  define property urlResp as character no-undo
    get.
    set.
		
  constructor public admutm (inOjType as char, inObjCode as int, inFSRAR as char, inExtSys as int):

    super (inOjType, inObjCode).
    FSRAR = inFSRAR.
    prsXMLDocWB = new ParserXMLDocWB (inExtSys).
    IsSent.
    
  end constructor.

  destructor public admutm ():

    if valid-object (prsXMLDocWB)
      then delete object prsXMLDocWB.
    if valid-object (prgObj)
      then delete object prgObj.
    
  end destructor.

  method public override handle GetHndlTable ():
    
    assign
      StatusErr = false
      Msg = ""
    .
    
    
    GetURLUTM().
    return buffer tt-alldoc:handle.
    
  end.

  method public void SaveRecords ():
    
    def var hDoc as handle no-undo.
    def var path as char no-undo.
    def var fullFileName as char no-undo.
    
    assign
      StatusErr = false
      Msg = ""
    .
    
    find last tt-alldoc no-error.
    
    if not available (tt-alldoc)
      then return.
    
    prgObj = new ProgressBar (1, tt-alldoc.nnOrder).
    prgObj:can-cancel = true.
    prgObj:show-bar().
    
    for each tt-alldoc:
    
      prgObj:increment( substring (tt-alldoc.url_, if length (tt-alldoc.url_) <= 50 then 1 else length (tt-alldoc.url_) - 50)). 
      if prgObj:is-canceled 
        then do:
          if valid-object (prgObj)
            then do:
              prgObj:hide-bar().
              delete object prgObj.
            end.
          return.
        end.
    
      SaveRecord(tt-alldoc.url_, output fullFileName).
      tt-alldoc.date_ = DocDate.
      
      if StatusErr then do:
        if valid-object (prgObj)
          then do:
            prgObj:hide-bar().
            delete object prgObj.
          end.
        return.
      end.
      
    end.
    
    if valid-object (prgObj)
      then do:
        prgObj:hide-bar().
        delete object prgObj.
      end.
    
    
    glog = true.
    
  end.

  method protected handle ParseRequest (inFileName as char):
    
    define variable hRoot as handle  no-undo.
    define variable hDoc  as handle  no-undo.
    define variable hRow  as handle  no-undo.
    define variable hText as handle  no-undo.
    define variable ii    as integer no-undo.
    
    create x-document hDoc.
    create x-noderef  hRoot.
    create x-noderef  hRow.
    create x-noderef htext .
    
    hDoc:load ("file", inFileName, false).
    hDoc:encoding = "UTF-8".
    hDoc:get-document-element(hRoot) .
    
    do ii = 1 to hRoot:num-children:
      hRoot:get-child(hRow,ii).
      case hRow:name:
        when "url" then
          do:
            hRow:get-child (hText, 1) no-error.
            return hText.
          end.
        when "error" then
          do:
            hRow:get-child (hText, 1) no-error.
            StatusErr = true.
            return hText.
          end.
        otherwise 
          do:
            return ?.
          end.
      end case.
    end.

  end. 

  method private void GetURLUTM ():

    empty temp-table tt-alldoc.
    
    assign
      inFileName = "ReceiptListOfQuery.xml"
    .
    if search ("ReceiptListOfQuery.xml") <> ? then os-delete value (inFileName).
    if search (inFileName) <> ? then os-delete value (inFileName).
    

    cmd = substitute ("&1 --connect-timeout &2 -X GET &3/opt/out?refresh=true >&4",search ("exe/curl.exe"), TimeOut, ConPar, inFileName).
    os-command silent value (cmd).
       
    file-info:file-name = search (inFileName).
    if search (inFileName) = ? or file-info:file-size = 0 
    then do:
      assign
        StatusErr = true
        Msg = "Не удалось получить данные от UTM"
      .
      return.
    end.
    
    ParseUrl(inFileName).
    
    assign
      inFileName = "ReceiptListInDoc.xml"
    .
    if search ("ReceiptListOfQuery.xml") <> ? then os-delete value (inFileName).
    if search (inFileName) <> ? then os-delete value (inFileName).
    

    cmd = substitute ("&1 --connect-timeout &2 -X GET &3/opt/in?refresh=true >&4",search ("exe/curl.exe"), TimeOut, ConPar, inFileName).
    os-command silent value (cmd).
       
    file-info:file-name = search (inFileName).
    if search (inFileName) = ? or file-info:file-size = 0 
    then do:
      assign
        StatusErr = true
        Msg = "Не удалось получить данные от UTM"
      .
      return.
    end.

    ParseUrl(inFileName).
    
    return. 

  end.


&scop my-message 'Удаление: ' + url_
  method public void Cleaning (inBeforDays as integer, inLogHandle as handle): 
    
    def var url_ as character no-undo.
    def buffer buf_tt-alldoc for tt-alldoc.
    
    assign
      StatusErr = false
      Msg = ""
    .

    GetURLUTM().
    
    for each buf_tt-alldoc where buf_tt-alldoc.typeDirection = 'out':
      
      url_ = buf_tt-alldoc.url_.
      
      case true:
        when lookup (buf_tt-alldoc.typeDoc, "ReplyRests,INVENTORYREGINFO,ReplyAP,ReplyPartner" ) > 0 then do:
          DelRecord(buf_tt-alldoc.url_).
          if valid-handle (inLogHandle)
          then do:
            {&display-message}.
          end.
        end.
        otherwise do:
          SaveRecord(buf_tt-alldoc.url_).
          buf_tt-alldoc.date_ = DocDate.
          if buf_tt-alldoc.date_ < today - inBeforDays and buf_tt-alldoc.date_ <> ?
            then DelRecord(buf_tt-alldoc.url_).
          if valid-handle (inLogHandle)
          then do:
            {&display-message}.            
          end.
        end.
      end.
      process events.
    end.
    
    for each buf_tt-alldoc where buf_tt-alldoc.typeDirection = 'in':
      url_ = buf_tt-alldoc.url_.
      DelRecord(url_).
      {&display-message}. 
      process events.
    end.
    
  end.


  method public void LookRec (input inUrl as char): 
    
    def var fullFileName as char no-undo. 
    
    assign
      StatusErr = false
      Msg = ""
    .
    
    SaveRecord(inUrl, output fullFileName).
    if StatusErr then return.
    if not available (tt-alldoc)
      then find first tt-alldoc where tt-alldoc.url_ = inUrl no-error.
    if available (tt-alldoc) 
      then tt-alldoc.date_ = DocDate.
    os-command silent value(fullFileName).
    
  end.
  
  method public void WriteDbStatusTrue ():

    if not WriteDbStatus (integer ({&EGAIS-InfoVer}), parameters , ReplyId, true)
    then do: 
      assign
        StatusErr = true
        Msg = "Не удалось записать данные о запросе в БД. Запрос не выполен."
      .
      return.
    end.
  
  end.

  method public void SaveRecord (input inUrl as char):

    assign
      StatusErr = false
      Msg = ""
    .
    
    def var fullFileName as char no-undo.
    SaveRecord (input inUrl, output fullFileName).
    if StatusErr then return.
    if not available (tt-alldoc)
      then find first tt-alldoc where tt-alldoc.url_ = inUrl no-error.
    if available (tt-alldoc) 
      then tt-alldoc.date_ = DocDate.
  
  end.

  method public void SaveRecord (input inUrl as char, output outFullFileName as char):
    
    def var path as char no-undo.
    def var hDoc as handle no-undo.
    
    assign
      StatusErr = false
      Msg = ""
    .
    
    path = "egais_" + FSRAR + "\".
    
    file-info:file-name = right-trim (path, "\").
    if file-info:file-type = ?
    then do:
      os-create-dir value(right-trim (path, "\")).
      if os-error <> 0 then do:
        message substitute("Невозможно создать директорию &1",path) view-as alert-box error.
        leave.
      end.
    end.

    assign
      inFileName = entry (7, inUrl, "/") + "_" + entry (6, inUrl, "/").
      .
    
    os-delete value (path + "inFileName").
    os-delete value (search (path + inFileName)).
    
    outFullFileName = path + inFileName + ".xml".
    
    cmd = substitute ("&1 --connect-timeout &2 -X GET &3 >&4", search ("exe/curl.exe"), TimeOut, inUrl, outFullFileName).
    os-command silent value (cmd).

    file-info:file-name = search (outFullFileName).
    
    if file-info:file-size = ? or  file-info:file-size = 0 
      then do: 
        StatusErr = true.
        Msg = 'Не удалось получить данные от УТМ.'.
        return.
      end.

    file-info:file-name = search (outFullFileName).
    
    create x-document hDoc.
    hDoc:encoding = 'utf-8'.
    hDoc:load ("file", file-info:file-name, false) no-error.
    
    prsXMLDocWB:ParseRec (hDoc, input-output DocDate, inUrl).

    glog = true. 
    
  end.

  method public void DelRecord (input inUrl as char): 
    
    assign
      StatusErr = false
      Msg = ""
    .
    
    cmd = substitute ("&1  -X DELETE &2", search ("exe/curl.exe"), inUrl).
/*    message inUrl view-as alert-box.*/
    os-command silent value (cmd).
    
  end.

  method public void QueryResendDoc (input inWBREGID as char): 
    
    def var ContStr as char no-undo.
    def var FullFileName as char no-undo.
    def var ContLongCh as longchar no-undo.

&scop xml-rec-wb '<?xml version="1.0" encoding="UTF-8"?>~
<ns:Documents Version="1.0" ~
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ~
xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" ~
xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters"> ~
<ns:Owner><ns:FSRAR_ID>TH-FSRAR</ns:FSRAR_ID>~
</ns:Owner>~
<ns:Document>~
<ns:QueryResendDoc>~
<qp:Parameters>~
<qp:Parameter>~
<qp:Name>WBREGID</qp:Name>~
<qp:Value>TH-WBREGID</qp:Value>~
</qp:Parameter>~
</qp:Parameters>~
</ns:QueryResendDoc>~
</ns:Document>~
</ns:Documents>'
    
    ContStr = {&xml-rec-wb}.
    
    assign
      StatusErr = false
      Msg = ""
    .
    
    ContStr = replace (ContStr, "TH-FSRAR", FSRAR).
    ContStr = replace (ContStr, "TH-WBREGID", inWBREGID).
    
    ContLongCh = ContStr.
    
    copy-lob
      from  object ContLongCh
      to  file 'QueryResendDoc.xml'
      no-convert
      no-error .
    
    FullFileName = search ('QueryResendDoc.xml').
    
    cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/QueryResendDoc >&4", search ("exe/curl.exe"), FullFileName, ConPar, "RespQueryResendDoc.xml").
    os-command silent value (cmd).
    
    file-info:file-name = search ("RespQueryResendDoc.xml").
    if search (inFileName) = ? or file-info:file-size = 0 or file-info:file-size = ?
      then 
    do:
      assign
        StatusErr = true
        Msg       = substitute ("Не удалось отправить повторный запрос накладной - &1 в УТМ.", inWBREGID)
        .
      undo, return.
    end.
    
  end.

  method public void ReqRepealWB (input inWBREGID as char): 
    
    def var ContStr as char no-undo.
    def var FullFileName as char no-undo.
    def var ContLongCh as longchar no-undo.

&scop xml-RepealWB '<?xml version="1.0" encoding="UTF-8"?>~
<ns:Documents Version="1.0"~
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"~
xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"~
xmlns:qp="http://fsrar.ru/WEGAIS/RequestRepealWB">~
<ns:Owner>~
<ns:FSRAR_ID>TH-FSRAR</ns:FSRAR_ID>~
</ns:Owner>~
<ns:Document>~
<ns:RequestRepealWB>~
<qp:ClientId>TH-FSRAR</qp:ClientId>~
<qp:RequestNumber></qp:RequestNumber>~
<qp:RequestDate></qp:RequestDate>~
<qp:WBRegId>TH-WBREGID</qp:WBRegId>~
</ns:RequestRepealWB>~
</ns:Document>~
</ns:Documents>'
    
    ContStr = {&xml-RepealWB}.
   
    assign
      StatusErr = false
      Msg = ""
    .
    
    ContStr = replace (ContStr, "TH-FSRAR", FSRAR).
    ContStr = replace (ContStr, "TH-WBREGID", inWBREGID).
    
    ContLongCh = ContStr.
    
    copy-lob
      from  object ContLongCh
      to  file 'RequestRepealWB.xml'
      no-convert
      no-error .
    
    FullFileName = search ('RequestRepealWB.xml').
    
    cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/RequestRepealWB.xml >&4", search ("exe/curl.exe"), FullFileName, ConPar, "RespRequestRepealWB.xml").
    os-command silent value (cmd).
    
    file-info:file-name = search ("RespRequestRepealWB.xml").
    if search (inFileName) = ? or file-info:file-size = 0 or file-info:file-size = ?
      then 
    do:
      assign
        StatusErr = true
        Msg       = substitute ("Не удалось отправить отмену на накладную - &1 в УТМ.", inWBREGID)
        .
      undo, return.
    end.
    
  end.

  method public void SendInfoVer (input inInfoVer as char): 
    
    def var ContStr as char no-undo.
    def var FullFileName as char no-undo.
    def var ContLongCh as longchar no-undo.
    def var respValue as handle no-undo.

&scop xml-info-ver '<?xml version="1.0" encoding="UTF-8"?>~
<ns:Documents Version="1.0" ~
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ~
xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" ~
xmlns:qp="http://fsrar.ru/WEGAIS/InfoVersionTTN">~
<ns:Owner>~
<ns:FSRAR_ID>TH-FSRAR</ns:FSRAR_ID>~
</ns:Owner>~
<ns:Document>~
<ns:InfoVersionTTN>~
<qp:ClientId>TH-FSRAR</qp:ClientId>~
<qp:WBTypeUsed>TH-InfoVer</qp:WBTypeUsed>~
</ns:InfoVersionTTN>~
</ns:Document>~
</ns:Documents>'
    
    ContStr = {&xml-info-ver}.
    
    assign
      StatusErr = false
      Msg = ""
    .
    
    if IsSentInvoVer 
    then do:
      Msg = "Запрос уже был отправлен.".
      StatusErr = true.
    end.
    
    ContStr = replace (ContStr, "TH-FSRAR", FSRAR).
    ContStr = replace (ContStr, "TH-InfoVer", inInfoVer).
    
    ContLongCh = ContStr.
    
    copy-lob
      from  object ContLongCh
      to  file 'InfoVersionTTN.xml'
      no-convert
      no-error .
    
    FullFileName = search ('InfoVersionTTN.xml').
    
    cmd = substitute ("&1 --connect-timeout 1 -F xml_file=@&2 &3/opt/in/InfoVersionTTN >&4", search ("exe/curl.exe"), FullFileName, ConPar, "RespInfoVersionTTN.xml").
    os-command silent value (cmd).
    
    file-info:file-name = search ("RespInfoVersionTTN.xml").
    if search (FullFileName) = ? or file-info:file-size = 0 or file-info:file-size = ?
      then 
    do:
      assign
        StatusErr = true
        Msg       = substitute ("Не удалось отправить уведомление о смене версии в УТМ на &1.", inInfoVer)
        .
      undo, return.
    end.
    
    respValue = ParseRequest (file-info:file-name).
    if respValue = ? 
      then 
    do:
      assign
        StatusErr = true
        Msg       = "Не удалось разобрать данные от УТМ"
        .
      return.
    end.
    if not StatusErr 
      then 
      ReplyId = respValue:node-value.
    else 
    do:
      assign
        StatusErr = true
        Msg       = respValue:node-value
        .
      return.
    end.
  
    if not WriteDbStatus (integer ({&EGAIS-InfoVer}), parameters , ReplyId, false)
    then do: 
      assign
        StatusErr = true
        Msg = "Не удалось записать данные о запросе в БД. Запрос не выполен."
      .
      return.
    end.
    
  end.

  method public void ParseUrl (input inFileName as char):
    
    define variable hRoot as handle  no-undo.
    define variable hDoc  as handle  no-undo.
    define variable hRow  as handle  no-undo.
    define variable hText as handle  no-undo.
    define variable ii    as integer no-undo.
    define variable jj    as integer no-undo.
    
    create x-document hDoc.
    create x-noderef  hRoot.
    create x-noderef  hRow.
    create x-noderef  hText.
    
    hDoc:load ("file", inFileName, false).
    hDoc:get-document-element(hRoot) .
    jj = 0.
    do ii = 1 to hRoot:num-children:
      hRoot:get-child(hRow,ii).
      case hRow:name:
        when "url" then
          do:
            jj = jj + 1.
            hRow:get-child (hText, 1) no-error.
            create tt-alldoc.
            assign
              tt-alldoc.url_ = hText:node-value
              tt-alldoc.nnOrder = jj.
            assign
              tt-alldoc.typeDoc = entry (6, hText:node-value, "/")
              tt-alldoc.typeDirection = entry (5, hText:node-value, "/") no-error
              .
          end.
      end case.
    end.
    
  end.

  method override protected logical GetIsSent ():
    def var repId as char no-undo.
    def var glog  as log  no-undo.
    glog = CheckCurrentRequest (integer ({&EGAIS-InfoVer}), parameters, repId).
    if glog
      then ReplyId = repId.
    return glog.
  end.

  method public override character GetSubjectOfRequestUTM() :

    assign
      StatusErr = false
      Msg = ""
    .
    
    urlResp = GetURLUTM(ReplyId, "out").
    
    if urlResp = "" or urlResp = ?
    then do:
      StatusErr = true.
      Msg = "Еще не получен ответ от сервера EGAIS по запросу " + ReplyId.
      return ?.
    end.
    
    os-delete "TicketInfoVer.xml".
    assign
      inFileName = "TicketInfoVer.xml"
    .
    
    cmd = substitute ("&1 --connect-timeout &2 -X GET &3 >&4", search ("exe/curl.exe"), TimeOut, urlResp, inFileName).
    os-command silent value (cmd).
    
  end.

  method protected character GetURLUTM (inReplyId as char, direction as char):
    
    define variable hRoot as handle  no-undo.
    define variable hDoc  as handle  no-undo.
    define variable hRow  as handle  no-undo.
    define variable hText as handle  no-undo.
    define variable ii    as integer no-undo.
    
    create x-document hDoc.
    create x-noderef  hRoot.
    create x-noderef  hRow.
    create x-noderef  hText.
    
    
    assign
      inFileName = "ReceiptListOfQuery.xml"
    .
    if search ("ReceiptListOfQuery.xml") <> ? then os-delete value (inFileName).
    if search (inFileName) <> ? then os-delete value (inFileName).
    

    cmd = substitute ("&1 --connect-timeout &2 -X GET &3/opt/&5?refresh=true >&4",search ("exe/curl.exe"), TimeOut, ConPar, inFileName, direction).
    os-command silent value (cmd).
       
    file-info:file-name = search (inFileName).
    if search (inFileName) = ? or file-info:file-size = 0 
    then do:
      assign
        StatusErr = true
        Msg = "Не удалось получить данные от UTM"
      .
      return ?.
    end.
    
    hDoc:load ("file", inFileName, false).
    hDoc:get-document-element(hRoot) .
    
    do ii = 1 to hRoot:num-children:
      hRoot:get-child(hRow,ii).
      case hRow:name:
        when "url" then
          do:
            if hRow:get-attribute("replyId") = ReplyId 
            then do:
              hRow:get-child (hText, 1) no-error.
              return hText:node-value.
            end.
          end.
      end case.
    end.
    
    return ?. 

  end.

end class.
