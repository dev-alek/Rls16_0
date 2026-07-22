using Progress.Lang.*.
using ibs.th.bge.egais.*.
using Ibs.Th.Gbl.ProgressBar.
block-level on error undo, throw.
class ibs.th.bge.egais.admutm inherits EGAISUTM:
  define temp-table tt-wb-header no-undo
    field wb-type-full as character label "Тип" format "X(10)"
    field num          as character label "№ пост."
    field wb-date      as date label "Дата"
    field shippingdate as date label "Дата поставки"
    field regID-Ship   as character format "X(21)" label "RegId контр."
    field NameShip     as character format "X(150)" label "Контрагент EGAIS"
    field regID-Cons   as character format "X(21)" label "Получатель EGAIS"
    field client       as character label "Контр. TH"
    field clientCons   as character label "Получ. TH"
    field cli-type     as character label "Тип клиента TH"
    field cli-code     as integer label "Код клиента TH"
    field obj-type     as character label "Тип клиента TH"
    field obj-code     as integer label "Код клиента TH"
    field ps           as character label "Примечание"
    field wbregid      as character format "X(21)" label "WBRegId"
    field Identity     as character label "ID EGAIS"
    field wb-type      as character label "Тип"
    field cargo-from   as character label  "Грузоотправитель"
    field uniq-key-rec as character
    field INNShip      as character label "ИНН контрагента"
    field KPPShip      as character label "КПП контрагента"
    field TransIdList  as character
    field UnitType     as character label "Тип единицы измерения"
    field verXSD       as character label "Версия XSD"
    index pi
    Identity
    .
  define temp-table tt-wb-gds-EG no-undo
    field gds-code       like ub.goods.gds-code label "Код товара в TH"
    field gds-name       like ub.goods.gds-name label "Полное наименование" format "X(150)"
    field alc-code       as character label "Алкогольный код" format "X(21)"
    field ms-base        like ub.goods.ms-base label "Объем" format ">>9.9<<"
    field alc-type-code  like ub.alc-type.alc-type-code label "Код АП"
    field proof          like ub.goods.proof label "Крепость" format ">9.9"
    field regID-i-p      as character format "X(21)" label "Импортер/Производитель"
    field i-p-name       as character label "Импортер/Производитель назв." format "X(150)"
    field i-p-th         as character label "Импортер/Производитель TH"
    field qnty           like ub.doc-line.doc-qnty label "Кол-во"
    field price          like ub.doc-line.price-rubl label "Цена"
    field refA           as character label "Справка A" format "X(25)"
    field refB           as character label "Справка B" format "X(25)"
    field beforRefB      as character label "Пред. справка B" format "X(25)"
    field Identity       as character label "ID EGAIS"
    field regID-Importer as character format "X(21)" label "Импортер"
    field importer-th    as character label "Импортер TH"
    field regID-Producer as character format "X(21)" label "Производитель"
    field Producer-th    as character label "Производитель TH"
    field nn             as integer label "№"
    field prod-list      as character format "x(1)"
    field importer-list  as character format "x(1)"
    field color-sts      as integer   format "99" init ?
    field UnitType       as character format "x(1)"
    index pi nn ascending
    index qntyIndex
    gds-code
    alc-code
    qnty
    .
  define temp-table tt-wb-act-header no-undo
    field num          as character label "№ пост."
    field wbregid      as character label "WBRegId" format "X(21)"
    field act-date     as date label "Дата"
    field status_      as character label "Статус"
    field note         as character label "Примечание" format "X(150)"
    index pi
    wbregid
    .
  define temp-table tt-wb-act-gds-EG no-undo
    field gds-code      as integer label "Код товара в TH"
    field gds-name      as character label "Полное наименование" format "X(150)"
    field doc-qnty      as decimal label "Кол-во по док."
    field fact-qnty     as decimal label "Кол-во факт."
    field RealQuantity  as decimal label "Кол-во акт"
    field refB          as character label "Справка B" format "X(25)"
    index pi as primary
    gds-code
    index name_
    gds-name
    .
  define temp-table tt-wb-info-client no-undo
    field obj-type        like ub.clients.obj-type
    field obj-code        like ub.clients.obj-code
    field obj-name-th     as character
    field obj-name-egais  as character
    field wb-type-client  as character
    field regID           as character format "X(21)"
    field inn             as character
    field kpp             as character
    field country         as character
    field regionCode      as character
    field district        as character
    field city            as character
    field settlement      as character
    field street          as character
    field house-number    as character
    field house-case      as character
    field house-apartment as character
    field house-litera    as character
    field postIndex       as character
    field description_    as character format "X(100)"
    index pi
    inn kpp
    .
  define temp-table tt-ticket no-undo
    field regid        as character label "RegId документа" format "X(21)"
    field doc          as character label "Документ" format "X(30)"
    field docType      as character label "Документ" format "X(30)"
    field ticket-date  as character label "Дата" format "X(29)"
    field status_      as character label "Статус"
    field comment      as character label "Коментарий" format "X(150)"
    field docId        as character label "DocId" format "X(40)"
    field TransId      as character label "TransId" format "X(40)"
    field Identity     as character label "Identity" format "X(21)"
    index pi
    regid
    .
  define temp-table tt-analiz no-undo
    field num           as character label "№ накл." format "X(50)"
    field wb-type       as character label "Тип" format "X(4)"
    field wb-date       as date      label "Дата"
    field wbregid       as character label "WBREGID" format "X(18)"
    field Identity      as character format "X(50)"
    field uniq-key-rec  as character format "X(50)"
    field url_          as character format "X(50)"
    field isMany        as logical   format "yes/no"
    field nnOrder       as integer
    field resource-type as character format "X(12)"
    index pi
    url_
    .
  define temp-table tt-alldoc no-undo
    field mark          as character format "X(1)" label "*"
    field url_          as character format "X(256)" label "URL"
    field typeDoc       as character format "X(14)" label "Тип"
    field typeDirection as character format "X(3)" label ""
    field date_         as date      label "Дата"
    field nnOrder       as integer   label "Порядковый №"
    field transId_      as date      label ""
    index pi
    nnOrder
    .
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
            run write-log-and-file in inLogHandle (          input 1                                                            , input LogFileName                                                  , input 1                                                            , input 'Удаление: ' + url_).
          end.
        end.
        otherwise do:
          SaveRecord(buf_tt-alldoc.url_).
          buf_tt-alldoc.date_ = DocDate.
          if buf_tt-alldoc.date_ < today - inBeforDays and buf_tt-alldoc.date_ <> ?
            then DelRecord(buf_tt-alldoc.url_).
          if valid-handle (inLogHandle)
          then do:
            run write-log-and-file in inLogHandle (          input 1                                                            , input LogFileName                                                  , input 1                                                            , input 'Удаление: ' + url_).
          end.
        end.
      end.
      process events.
    end.
    for each buf_tt-alldoc where buf_tt-alldoc.typeDirection = 'in':
      url_ = buf_tt-alldoc.url_.
      DelRecord(url_).
      run write-log-and-file in inLogHandle (          input 1                                                            , input LogFileName                                                  , input 1                                                            , input 'Удаление: ' + url_).
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
    if not WriteDbStatus (integer ('3':U), parameters , ReplyId, true)
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
    os-command silent value (cmd).
  end.
  method public void QueryResendDoc (input inWBREGID as char):
    def var ContStr as char no-undo.
    def var FullFileName as char no-undo.
    def var ContLongCh as longchar no-undo.
    ContStr = '<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:qp="http://fsrar.ru/WEGAIS/QueryParameters"> <ns:Owner><ns:FSRAR_ID>TH-FSRAR</ns:FSRAR_ID></ns:Owner><ns:Document><ns:QueryResendDoc><qp:Parameters><qp:Parameter><qp:Name>WBREGID</qp:Name><qp:Value>TH-WBREGID</qp:Value></qp:Parameter></qp:Parameters></ns:QueryResendDoc></ns:Document></ns:Documents>'.
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
    ContStr = '<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0"xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01"xmlns:qp="http://fsrar.ru/WEGAIS/RequestRepealWB"><ns:Owner><ns:FSRAR_ID>TH-FSRAR</ns:FSRAR_ID></ns:Owner><ns:Document><ns:RequestRepealWB><qp:ClientId>TH-FSRAR</qp:ClientId><qp:RequestNumber></qp:RequestNumber><qp:RequestDate></qp:RequestDate><qp:WBRegId>TH-WBREGID</qp:WBRegId></ns:RequestRepealWB></ns:Document></ns:Documents>'.
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
    ContStr = '<?xml version="1.0" encoding="UTF-8"?><ns:Documents Version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" xmlns:qp="http://fsrar.ru/WEGAIS/InfoVersionTTN"><ns:Owner><ns:FSRAR_ID>TH-FSRAR</ns:FSRAR_ID></ns:Owner><ns:Document><ns:InfoVersionTTN><qp:ClientId>TH-FSRAR</qp:ClientId><qp:WBTypeUsed>TH-InfoVer</qp:WBTypeUsed></ns:InfoVersionTTN></ns:Document></ns:Documents>'.
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
    if not WriteDbStatus (integer ('3':U), parameters , ReplyId, false)
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
    glog = CheckCurrentRequest (integer ('3':U), parameters, repId).
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
