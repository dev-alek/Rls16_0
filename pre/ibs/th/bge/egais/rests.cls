using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.Rests inherits ParserXMLRests:
  define stream outstr.
  define private buffer buf_ext-sys for ub.ext-system.
  define private variable parameters as character no-undo.
  define private variable inFileName as character no-undo.
  define private variable inData     as character no-undo.
  define private variable outData    as character no-undo.
  define private variable cmd        as character no-undo.
  define private variable urlResp    as character no-undo.
  constructor public Rests (inOjType as char, inObjCode as int, inFSRAR as char, inINN as char):
    super (inOjType, inObjCode).
    assign
      parameters = inFSRAR + chr(4) + inINN.
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
      os-delete "ReceiptQueryRests.xml".
      assign
        inFileName = "ReceiptQueryRests.xml"
      .
      output stream outstr to value ("QueryParameters.xml") convert target "UTF-8".
      if VerXSD = "1" then
        outData = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:QueryRests></ns:QueryRests></ns:Document></ns:Documents>', entry (1, parameters, chr(4))).
      if VerXSD = "2" then
        outData = substitute ('<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters"><ns:Owner><ns:FSRAR_ID>&1</ns:FSRAR_ID></ns:Owner><ns:Document><ns:QueryRests_v2></ns:QueryRests_v2></ns:Document></ns:Documents>', entry (1, parameters, chr(4))).
      put stream outstr unformatted outData.
      put stream outstr skip.
      output stream outstr close.
      if VerXSD = "1" then
        cmd = substitute ("&1 --connect-timeout &5 -F xml_file=@&2 &3/opt/in/QueryRests >&4", search ("exe/curl.exe"), search ("QueryParameters.xml"), ConPar, inFileName, TimeOut).
      if VerXSD = "2" then
        cmd = substitute ("&1 --connect-timeout &5 -F xml_file=@&2 &3/opt/in/QueryRests_v2 >&4", search ("exe/curl.exe"), search ("QueryParameters.xml"), ConPar, inFileName, TimeOut).
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
      if not WriteDbStatus (5, parameters , ReplyId, false)
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
    glog = CheckCurrentRequest (5, parameters, repId).
    if glog
      then ReplyId = repId.
    return glog.
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
      Msg = "Не заданы настройки соединения для EGAIS".
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
    if not WriteDbStatus ( 5, parameters , ReplyId, true )
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
      inFileName = "Rests-" + entry(1, parameters, chr(4)) + ".xml"
    .
    return ParseResponse(inFileName).
  end.
  method public override character GetSubjectOfRequestUTM() :
    define variable v-fn as character no-undo .
    urlResp = GetURLUTM(ReplyId, "out").
    if urlResp = "" or urlResp = ?
    then do:
      StatusErr = true.
      Msg = "Еще не получен ответ от сервера EGAIS по запросу " + ReplyId.
      return ?.
    end.
    v-fn = "Rests-" + entry(1, parameters, chr(4)) + ".xml" .
    os-delete v-fn.
    assign
      inFileName = "Rests-" + entry(1, parameters, chr(4)) + ".xml"
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
