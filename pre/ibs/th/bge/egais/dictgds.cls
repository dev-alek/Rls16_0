using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.DictGds inherits ParserXMLDictGds:
  define stream outstr.
  define private buffer buf_ext-sys for ub.ext-system.
  define private variable parameters as character no-undo.
  define private variable inFileName as character no-undo.
  define private variable inData     as character no-undo.
  define private variable outData    as character no-undo.
  define private variable cmd        as character no-undo.
  define private variable urlResp    as character no-undo.
  constructor public DictGds (inOjType as char, inObjCode as int, inFSRAR as char, inINN as char):
    super (inOjType, inObjCode).
    assign
      parameters = inFSRAR + chr(4) + 'ИНН' + chr(4) + inINN.
    .
    IsSent.
  end constructor.
  constructor public DictGds (inOjType as char, inObjCode as int, inFSRAR as char, inQRName as char, inQRValue as char):
    super (inOjType, inObjCode).
    assign
      parameters = inFSRAR + chr(4) + inQRName + chr(4) + inQRValue.
    .
    IsSent.
  end constructor.
  method public override logical SendRequestUTM():
    assign
      StatusErr = false
      Msg = ""
    .
    if IsSent
    then do:
      Msg = "Запрос уже был отправлен".
      StatusErr = true.
      return no.
    end.
    StatusErr = false.
    do trans:
      os-delete "ReceiptQueryAP.xml".
      assign
        inFileName = "ReceiptQueryAP.xml"
      .
      output stream outstr to value ("QueryAPSingle.xml") convert target "UTF-8".
      if VerXSD = "1" then
        outData = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:QueryAP><qp:Parameters><qp:Parameter><qp:Name>&2</qp:Name><qp:Value>&3</qp:Value></qp:Parameter></qp:Parameters></ns:QueryAP></ns:Document></ns:Documents>', entry (1, parameters, chr(4)), entry (2, parameters, chr(4)), entry (3, parameters, chr(4))).
      if VerXSD = "2" then
        outData = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:QueryAP_v2><qp:Parameters><qp:Parameter><qp:Name>&2</qp:Name><qp:Value>&3</qp:Value></qp:Parameter></qp:Parameters></ns:QueryAP_v2></ns:Document></ns:Documents>', entry (1, parameters, chr(4)), entry (2, parameters, chr(4)), entry (3, parameters, chr(4))).
      put stream outstr unformatted outData.
      put stream outstr skip.
      output stream outstr close.
      if VerXSD = "1" then
        cmd = substitute ("&1 --connect-timeout &5 -F xml_file=@&2 &3/opt/in/QueryAP >&4", search ("exe/curl.exe"), search ("QueryAPSingle.xml"), ConPar, inFileName, TimeOut).
      if VerXSD = "2" then
        cmd = substitute ("&1 --connect-timeout &5 -F xml_file=@&2 &3/opt/in/QueryAP_v2 >&4", search ("exe/curl.exe"), search ("QueryAPSingle.xml"), ConPar, inFileName, TimeOut).
      os-command silent value (cmd).
      file-info:file-name = search (inFileName).
      if search (inFileName) <> ? and file-info:file-size > 0
      then do:
        def var respValue as handle no-undo.
        respValue = ParseRequest (inFileName).
        if respValue = ?
        then do:
          assign
            StatusErr = true
            Msg = "Не удалось разобрать данные от UTM"
          .
          undo, return false.
        end.
        if not StatusErr
          then
            ReplyId = respValue:node-value.
          else do:
            assign
              StatusErr = true
              Msg = respValue:node-value
            .
            undo, return false.
          end.
      end.
      else do:
        assign
          StatusErr = true
          Msg = "Не удалось получить данные от UTM"
        .
        undo, return false.
      end.
      if not WriteDbStatus (integer ('2':U), parameters , ReplyId, false)
      then do:
        assign
          StatusErr = true
          Msg = "Не удалось записать данные о запросе в БД. Запрос не выполен."
        .
        undo, return false.
      end.
    end.
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
  method override protected logical GetIsSent ():
    def var repId as char no-undo.
    def var glog  as log  no-undo.
    glog = CheckCurrentRequest (integer ('2':U), parameters, repId).
    if glog
      then ReplyId = repId.
    return glog.
  end.
  method public class ExtGdsValue GetExtGdsObjValueFromUTM () :
    define variable extGdsObj           as class  ExtGds      no-undo.
    define variable extGdsValueObj      as class  ExtGdsValue no-undo.
    define variable bh-gds-egais-gotten as handle no-undo.
    bh-gds-egais-gotten = GetHndlTable().
    extGdsObj = new ExtGds (yes).
    if bh-gds-egais-gotten = ? or not bh-gds-egais-gotten:find-first ()
    then do:
      delete object extGdsObj.
      StatusErr = true.
      return ?.
    end.
    extGdsValueObj = extGdsObj:GetInfoObj (
      bh-gds-egais-gotten:buffer-field("prod-info"):buffer-value +
      chr(4) + bh-gds-egais-gotten:buffer-field("imp-info"):buffer-value +
      chr(4) + bh-gds-egais-gotten:buffer-field("gds-name"):buffer-value +
      chr(4) + bh-gds-egais-gotten:buffer-field("ms-base"):buffer-value).
    if extGdsObj:ReturnMsg <> ""
    then do:
      Msg = extGdsObj:ReturnMsg.
      StatusErr = true.
    end.
    extGdsValueObj:AlcCode = bh-gds-egais-gotten:buffer-field("alc-code"):buffer-value.
    delete object extGdsObj.
    return extGdsValueObj.
  end.
  method public override handle GetHndlTable() :
    assign
      StatusErr = false
      Msg = ""
    .
    if not IsSent
    then do:
      StatusErr = true.
      Msg = "Запрос еще не был отправлен".
      return ?.
    end.
    if ConPar = "" or ConPar = ?
    then do:
      StatusErr = true.
      Msg = "Не заданы настройки соединения в ini файле для EGAIS".
      return ?.
    end.
    GetSubjectOfRequestUTM().
    if StatusErr
      then return ?.
    file-info:file-name = search (inFileName).
    if search (inFileName) = ? or file-info:file-size = 0
    then do:
      assign
        StatusErr = true
        Msg = "Не удалось получить данные от UTM"
      .
      return ?.
    end.
    if not WriteDbStatus ( integer ('2':U), parameters , ReplyId, true )
    then do:
      assign
        StatusErr = true
        Msg = "Не удалось записать данные о запросе в БД. Запрос не выполен."
      .
      undo, return ?.
    end.
    urlResp = GetURLUTM(ReplyId, "in").
    cmd = substitute ("&1 --connect-timeout &2 -X DELETE &3", search ("exe/curl.exe"), TimeOut, urlResp).
    os-command silent value (cmd).
    urlResp = GetURLUTM(ReplyId, "out").
    cmd = substitute ("&1 --connect-timeout &2 -X DELETE &3", search ("exe/curl.exe"), TimeOut, urlResp).
    os-command silent value (cmd).
    assign
      inFileName = "QueryAP.xml"
    .
    return ParseResponse(inFileName).
  end.
  method public override character GetSubjectOfRequestUTM() :
    urlResp = GetURLUTM(ReplyId, "out").
    if urlResp = "" or urlResp = ?
    then do:
      StatusErr = true.
      Msg = "Еще не получен ответ от сервера EGAIS по запросу " + ReplyId.
      return ?.
    end.
    os-delete "QueryAP.xml".
    assign
      inFileName = "QueryAP.xml"
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
