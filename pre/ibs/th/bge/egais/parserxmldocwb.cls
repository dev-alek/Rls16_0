using Progress.Lang.*.
using ibs.th.bge.egais.*.
block-level on error undo, throw.
class ibs.th.bge.egais.ParserXMLDocWB:
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define private buffer buf_clob-bind for ub.clob-bind.
  define private buffer buf_clob-data for ub.clob-data.
  define private buffer buf_clients   for ub.clients.
  define private variable inFileName     as character no-undo.
  define private variable nn             as integer   no-undo.
  define private variable parentNameOref as character no-undo.
  define property glog as logical no-undo
    get.
    set.
  define property FromFSRAR as character no-undo
    get.
    set.
  define property IsToClearTable as logical no-undo init true
    get.
    set.
  define property ExtSys as integer no-undo
    get.
    private set.
  constructor public ParserXMLDocWB (inExtSys as int):
    ExtSys = inExtSys.
  end.
  method public void ParseRec (hDoc as handle, input-output table tt-wb-header, input-output table tt-wb-act-header, input-output table tt-ticket, input-output table tt-wb-info-client, input-output table tt-wb-gds-EG):
    define variable hRoot as handle no-undo.
    glog = false.
    empty temp-table tt-wb-header.
    empty temp-table tt-wb-gds-EG.
    empty temp-table tt-wb-act-header.
    empty temp-table tt-wb-act-gds-EG.
    empty temp-table tt-ticket.
    empty temp-table tt-wb-info-client.
    if valid-handle (hDoc)
    then do:
      create x-noderef hRoot.
      nn = 0.
      hDoc:get-document-element(hRoot).
      GetChildren(hRoot, 1).
      delete object hRoot.
      delete object hDoc.
    end.
    find first tt-wb-header no-error.
    find first tt-wb-act-header no-error.
    find first tt-ticket no-error.
    if not available (tt-wb-header) and not available (tt-wb-act-header) and not available (tt-ticket) then
    do:
      glog = false.
    end.
    glog = true.
  end.
  method public void ParseRec (hDoc as handle, input-output outDate as date, url_ as char):
    define variable hRoot as handle no-undo.
    glog = false.
    empty temp-table tt-wb-header.
    empty temp-table tt-wb-gds-EG.
    empty temp-table tt-wb-act-header.
    empty temp-table tt-wb-act-gds-EG.
    empty temp-table tt-ticket.
    if valid-handle (hDoc)
    then do:
      create x-noderef hRoot.
      nn = 0.
      hDoc:get-document-element(hRoot).
      GetChildren(hRoot, 1).
      delete object hRoot.
      delete object hDoc.
    end.
    find first tt-wb-header no-error.
    find first tt-wb-act-header no-error.
    find first tt-ticket no-error.
    case true:
      when available tt-wb-header then do:
        outDate = tt-wb-header.wb-date.
      end.
      when available tt-wb-act-header then do:
        outDate = tt-wb-act-header.act-date.
      end.
      when available tt-ticket then do:
        assign
          outDate = date (   substring (entry (3, tt-ticket.ticket-date, "-"), 1, 2) + "." + entry (2, tt-ticket.ticket-date, "-") + "." + entry (1, tt-ticket.ticket-date, "-"))
        no-error.
      end.
    end case.
    glog = true.
  end.
  method public void ParseRec (hDocWB as handle, hDocRef as handle, input-output table tt-wb-header, input-output table tt-wb-gds-EG, input-output table tt-wb-info-client):
    define variable hRoot as handle no-undo.
    glog = false.
    if IsToClearTable
    then do:
      empty temp-table tt-wb-header.
      empty temp-table tt-wb-gds-EG.
      empty temp-table tt-wb-info-client.
    end.
    if valid-handle (hDocWB)
    then do:
      create x-noderef hRoot.
      nn = 0.
      hDocWB:get-document-element(hRoot).
      GetChildren(hRoot, 1).
      delete object hRoot.
      delete object hDocWB.
    end.
    if valid-handle (hDocRef)
    then do:
      create x-noderef hRoot.
      nn = 0.
      hDocRef:get-document-element(hRoot).
      GetChildren(hRoot, 1).
      delete object hRoot.
      delete object hDocRef.
    end.
    glog = true.
  end.
  method public void ParseRec (hDocAct as handle, input-output table tt-wb-act-header, input-output table tt-wb-act-gds-EG):
    define variable hRoot as handle no-undo.
    glog = false.
    if IsToClearTable
    then do:
      empty temp-table tt-wb-act-header.
      empty temp-table tt-wb-act-gds-EG.
    end.
    if valid-handle (hDocAct)
    then do:
      create x-noderef hRoot.
      nn = 0.
      hDocAct:get-document-element(hRoot).
      GetChildren(hRoot, 1).
      delete object hRoot.
      delete object hDocAct.
    end.
    glog = true.
  end.
  method public void ParseRec (hDocTicket as handle, input-output table tt-ticket):
    define variable hRoot as handle no-undo.
    glog = false.
    if IsToClearTable
    then do:
      empty temp-table tt-ticket.
    end.
    if valid-handle (hDocTicket)
    then do:
      create x-noderef hRoot.
      nn = 0.
      hDocTicket:get-document-element(hRoot).
      GetChildren(hRoot, 1).
      delete object hRoot.
      delete object hDocTicket.
    end.
    glog = true.
  end.
  method private void GetChildren(hParent as handle, level as integer):
    define variable i             as integer   no-undo.
    define variable hNoderef      as handle    no-undo.
    define variable hText         as handle    no-undo.
    define variable nameParent    as handle    no-undo.
    define variable good          as logical   no-undo.
    define variable parentName    as character no-undo.
    define variable parentNS-URI  as character no-undo.
    define variable noderefName   as character no-undo.
    define variable noderefNS-URI as character no-undo.
    create x-noderef hNoderef.
    create x-noderef hText .
    parentNS-URI = hParent:namespace-uri.
    parentName = hParent:name.
    case true:
      when parentNS-URI = "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" then do:
        parentName = "ns:" + entry (2, parentName, ":").
      end.
      when parentNS-URI = "http://fsrar.ru/WEGAIS/TTNSingle_v2" or parentNS-URI = "http://fsrar.ru/WEGAIS/TTNSingle" then do:
        parentName = "wb:" + entry (2, parentName, ":").
      end.
      when parentNS-URI = "http://fsrar.ru/WEGAIS/TTNInformF2Reg" or parentNS-URI = "http://fsrar.ru/WEGAIS/TTNInformBReg" then do:
        parentName = "wbr:" + entry (2, parentName, ":").
      end.
      when parentNS-URI = "http://fsrar.ru/WEGAIS/ActTTNSingle_v2" or parentNS-URI = "http://fsrar.ru/WEGAIS/ActTTNSingle" then do:
        parentName = "wa:" + entry (2, parentName, ":").
      end.
      when parentNS-URI = "http://fsrar.ru/WEGAIS/Ticket" then do:
        parentName = "tc:" + entry (2, parentName, ":").
      end.
      when parentName begins "wt" then do:
        parentName = "wt:" + entry (2, parentName, ":").
      end.
      when parentNS-URI = "http://fsrar.ru/WEGAIS/ClientRef_v2" or parentNS-URI = "http://fsrar.ru/WEGAIS/ClientRef" then do:
        parentName = "oref:" + entry (2, parentName, ":").
      end.
      when parentNS-URI = "http://fsrar.ru/WEGAIS/ProductRef_v2" or parentNS-URI = "http://fsrar.ru/WEGAIS/ProductRef" then do:
        parentName = "pref:" + entry (2, parentName, ":").
      end.
    end.
    repeat i = 1 to hParent:num-children:
      good = hParent:get-child(hNoderef,i).
      if not good then
        leave.
      if hNoderef:subtype <> "element" or hNoderef:num-children = 0 then
        next.
      hNoderef:get-child(hText, 1) no-error .
      if error-status:error
        then next.
      noderefNS-URI = hNoderef:namespace-uri.
      noderefName = hNoderef:name.
      case true:
        when noderefNS-URI = "http://fsrar.ru/WEGAIS/WB_DOC_SINGLE_01" then do:
          noderefName = "ns:" + entry (2, noderefName, ":").
        end.
        when noderefNS-URI = "http://fsrar.ru/WEGAIS/TTNSingle_v2" or noderefNS-URI = "http://fsrar.ru/WEGAIS/TTNSingle" then do:
          noderefName = "wb:" + entry (2, noderefName, ":").
        end.
        when noderefNS-URI = "http://fsrar.ru/WEGAIS/TTNInformF2Reg" or noderefNS-URI = "http://fsrar.ru/WEGAIS/TTNInformBReg" then do:
          noderefName = "wbr:" + entry (2, noderefName, ":").
        end.
        when noderefNS-URI = "http://fsrar.ru/WEGAIS/ActTTNSingle_v2" or noderefNS-URI = "http://fsrar.ru/WEGAIS/ActTTNSingle" then do:
          noderefName = "wa:" + entry (2, noderefName, ":").
        end.
        when noderefNS-URI = "http://fsrar.ru/WEGAIS/Ticket" then do:
          noderefName = "tc:" + entry (2, noderefName, ":").
        end.
        when noderefName begins "wt" then do:
          noderefName = "wt:" + entry (2, noderefName, ":").
        end.
        when noderefNS-URI = "http://fsrar.ru/WEGAIS/ClientRef_v2" or noderefNS-URI = "http://fsrar.ru/WEGAIS/ClientRef" then do:
          noderefName = "oref:" + entry (2, noderefName, ":").
        end.
        when noderefNS-URI = "http://fsrar.ru/WEGAIS/ProductRef_v2" or noderefNS-URI = "http://fsrar.ru/WEGAIS/ProductRef" then do:
          noderefName = "pref:" + entry (2, noderefName, ":").
        end.
      end.
      case noderefName:
        when "wb:Shipper" or
        when "wbr:Shipper" then
          do:
            parentNameOref = "".
            create tt-wb-info-client .
            tt-wb-info-client.wb-type-client = "Shipper".
          end.
        when "wb:Consignee" then
          do:
            parentNameOref = "".
            create tt-wb-info-client .
            tt-wb-info-client.wb-type-client = "Consignee".
          end.
        when "wb:Supplier" then
          do:
            parentNameOref = "".
            create tt-wb-info-client .
            tt-wb-info-client.wb-type-client = "Supplier".
          end.
        when "wb:Content" or when "wbr:Content" then
          do:
            parentNameOref = "".
            assign
              tt-wb-header.uniq-key-rec = tt-wb-header.num + chr(6) + string (tt-wb-header.wb-date) + chr(6) + tt-wb-header.regID-Ship + chr(6) + tt-wb-header.Identity.
          end.
        when "wb:Position" then
          do:
            parentNameOref = "".
            create tt-wb-gds-EG .
            tt-wb-gds-EG.prod-list = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5).
            tt-wb-gds-EG.importer-list = chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5) + chr(5).
            nn = nn + 1.
          end.
        when "wa:Header" then
          do:
            parentNameOref = "".
            create tt-wb-act-header .
          end.
        when "wa:Position" then
          do:
            parentNameOref = "".
            create tt-wb-act-gds-EG .
          end.
        when "ns:Ticket" then
          do:
            parentNameOref = "".
            create tt-ticket .
            tt-ticket.docType = "Ticket".
          end.
        when "ns:ConfirmTicket" then
          do:
            parentNameOref = "".
            create tt-ticket .
            tt-ticket.doc = 'ConfirmTicket'.
            tt-ticket.docType = 'ConfirmTicket'.
          end.
        when "ns:ConfirmRepealWB" then
          do:
            parentNameOref = "".
            create tt-ticket .
            tt-ticket.doc = 'ConfirmRepealWB'.
            tt-ticket.docType = 'ConfirmRepealWB'.
          end.
        when "ns:RequestRepealWB" then
          do:
            parentNameOref = "".
            create tt-ticket .
            tt-ticket.doc = 'RequestRepealWB'.
            tt-ticket.docType = 'RequestRepealWB'.
          end.
      end case.
      if lookup (parentName, "ns:Ticket") > 0 then do:
        if noderefName = "tc:DocId" then assign tt-ticket.docID = hText:node-value.
        if noderefName = "tc:TransportId" then assign tt-ticket.TransId = hText:node-value.
        if noderefName = "tc:TicketDate" then assign tt-ticket.ticket-date = hText:node-value.
        if noderefName = "tc:RegID"
        then do:
          assign tt-ticket.regid = hText:node-value.
        end.
        if noderefName = "tc:Identity" then assign tt-ticket.Identity = hText:node-value.
        if noderefName = "tc:DocType" then assign tt-ticket.doc = "ticket/" + hText:node-value.
      end.
      if lookup (parentName, "ns:ConfirmTicket,ns:ConfirmRepealWB") > 0 then do:
        if noderefName = "wt:Identity" then assign tt-ticket.Identity = hText:node-value.
      end.
      if lookup (parentName, "wt:Header") > 0 then do:
        if noderefName = "wt:IsConfirm" then assign tt-ticket.status_ = hText:node-value.
        if noderefName = "wt:TicketDate" then assign tt-ticket.ticket-date = hText:node-value.
        if noderefName = "wt:WBRegId" then assign tt-ticket.regid = hText:node-value.
        if noderefName = "wt:Note" then assign tt-ticket.comment = hText:node-value.
      end.
      if lookup (parentName, "ns:RequestRepealWB") > 0 then do:
        if noderefName = "qp:RequestDate" then assign tt-ticket.ticket-date = hText:node-value.
        if noderefName = "qp:WBRegId" then assign tt-ticket.regid = hText:node-value.
        if noderefName = "qp:RequestNumber" then assign tt-ticket.Identity = hText:node-value.
      end.
      if lookup (parentName, "tc:Result") > 0 then do:
        if noderefName = "tc:Conclusion" then assign tt-ticket.status_ = hText:node-value.
        if noderefName = "tc:Comments" then assign tt-ticket.comment = hText:node-value.
      end.
      if lookup (parentName, "tc:OperationResult") > 0 then do:
        if noderefName = "tc:OperationResult" then assign tt-ticket.status_ = hText:node-value.
        if noderefName = "tc:OperationComment" then assign tt-ticket.comment = hText:node-value.
      end.
      if lookup (parentName, "ns:Owner") > 0
      then do:
        if noderefName = "ns:FSRAR_ID" then assign FromFSRAR = hText:node-value.
      end.
      case noderefName:
      when 'ns:WayBill' then do:
        if not available (tt-wb-header) then create tt-wb-header.
        tt-wb-header.verXSD = 'WayBill'.
      end.
      when 'ns:WayBill_v2' then do:
        if not available (tt-wb-header) then create tt-wb-header.
        tt-wb-header.verXSD = 'WayBill_v2'.
      end.
      end case.
      if lookup (parentName, "wb:Header,ns:WayBill,ns:WayBill_v2,wbr:Header,wa:Header") > 0
        then
      do:
        if noderefName = "wb:Identity" or noderefName = "wbr:Identity" or noderefName = "wb:NUMBER" or noderefName = "wbr:WBRegId"
          then
        do:
          if not available (tt-wb-header) then create tt-wb-header.
          assign
            tt-wb-header.Identity = hText:node-value when noderefName = "wb:Identity"
            tt-wb-header.ps       = "EGAIS wb:Identity " + hText:node-value when noderefName = "wb:Identity"
            .
        end.
        if noderefName = "wb:NUMBER" or noderefName = "wbr:WBNUMBER" then assign tt-wb-header.num = hText:node-value.
        if noderefName = "wb:Date" or noderefName = "wbr:WBDate" then assign tt-wb-header.wb-date = date (entry (3, hText:node-value, "-") + "." + entry (2, hText:node-value, "-") + "." + entry (1, hText:node-value, "-")) .
        if noderefName = "wb:ShippingDate" then assign tt-wb-header.shippingdate = date (entry (3, hText:node-value, "-") + "." + entry (2, hText:node-value, "-") + "." + entry (1, hText:node-value, "-")) .
        if noderefName = "wb:Type" then
        do:
          case hText:node-value :
            when 'WBInvoiceFromMe' then
              do:
                assign
                  tt-wb-header.wb-type      = 'ie':U
                  tt-wb-header.wb-type-full = "приход вн.".
              end.
            when 'WBReturnFromMe' then
              do:
                assign
                  tt-wb-header.wb-type      = 're':U
                  tt-wb-header.wb-type-full = "возврат вн.".
              end.
            otherwise
            do:
              assign
                tt-wb-header.wb-type = ?.
            end.
          end case.
        end.
        if noderefName = "wb:UnitType"     then assign tt-wb-header.UnitType = hText:node-value .
        if noderefName = "wa:ACTNUMBER" then assign tt-wb-act-header.num = hText:node-value.
        if noderefName = "wa:ActDate" then assign tt-wb-act-header.act-date = date (entry (3, right-trim (hText:node-value), "-") + "." + entry (2, hText:node-value, "-") + "." + entry (1, left-trim (hText:node-value), "-")) .
        if noderefName = "wa:WBRegId" then assign tt-wb-act-header.wbregid = hText:node-value.
        if noderefName = "wa:IsAccept" then assign tt-wb-act-header.status_ = hText:node-value.
        if noderefName = "wa:Note" then assign tt-wb-act-header.note = hText:node-value.
      end.
      if lookup (parentName, "wb:Shipper,wb:Consignee,wb:Supplier,wbr:Shipper")  > 0 or lookup (parentNameOref, "wb:Shipper,wb:Consignee,wb:Supplier,wbr:Shipper")  > 0
      then
      do:
        if lookup (noderefName, "oref:UL,oref:FL,oref:FO,oref:TS") > 0
        then do:
          parentNameOref = parentName.
        end.
        if noderefName = "oref:ClientRegId" then
        do:
          assign
            tt-wb-info-client.regID = hText:node-value
            tt-wb-header.regID-Ship = hText:node-value
            when tt-wb-info-client.wb-type-client = 'Shipper'
            tt-wb-header.regID-Cons = hText:node-value
            when tt-wb-info-client.wb-type-client = 'Consignee'
            .
        end.
        if noderefName = "oref:FullName"    then assign tt-wb-header.NameShip = hText:node-value when parentName = 'wb:Shipper'.
        if noderefName = "oref:INN"         then assign tt-wb-header.INNShip = hText:node-value when parentName = 'wb:Shipper'.
        if noderefName = "oref:KPP"         then assign tt-wb-header.KPPShip = hText:node-value when parentName = 'wb:Shipper'.
        if noderefName = "oref:INN"         then assign tt-wb-info-client.inn = hText:node-value .
        if noderefName = "oref:KPP"         then assign tt-wb-info-client.kpp = hText:node-value .
        if noderefName = "oref:FullName"    then assign tt-wb-info-client.obj-name-egais = hText:node-value .
        if noderefName = "oref:Country"     then assign tt-wb-info-client.country = hText:node-value .
        if noderefName = "oref:Index"       then assign tt-wb-info-client.postIndex = hText:node-value .
        if noderefName = "oref:RegionCode"  then assign tt-wb-info-client.regionCode = hText:node-value .
        if noderefName = "oref:area"        then assign tt-wb-info-client.district = hText:node-value .
        if noderefName = "oref:city"        then assign tt-wb-info-client.city = hText:node-value .
        if noderefName = "oref:place"       then assign tt-wb-info-client.settlement = hText:node-value .
        if noderefName = "oref:street"      then assign tt-wb-info-client.street = hText:node-value .
        if noderefName = "oref:house"       then assign tt-wb-info-client.house-number = hText:node-value .
        if noderefName = "oref:building"    then assign tt-wb-info-client.house-case = hText:node-value .
        if noderefName = "oref:liter"       then assign tt-wb-info-client.house-litera = hText:node-value .
        if noderefName = "oref:description" then assign tt-wb-info-client.description_ = hText:node-value .
      end.
      if lookup (parentName, "wa:Position") > 0
      then
      do:
        if noderefName = "wa:InformBRegId"   then assign tt-wb-act-gds-EG.refB = hText:node-value .
        if noderefName = "wa:RealQuantity"   then assign tt-wb-act-gds-EG.RealQuantity = decimal(hText:node-value) .
      end.
      if lookup (parentName, "wb:Position,wb:Product") > 0
        then
      do:
        if tt-wb-gds-EG.gds-name = "" then
          if noderefName = "pref:ShortName"    then assign tt-wb-gds-EG.gds-name = hText:node-value.
        if noderefName = "pref:FullName"     then assign tt-wb-gds-EG.gds-name = hText:node-value.
        if noderefName = "pref:AlcCode"
          then assign tt-wb-gds-EG.alc-code = hText:node-value.
        if noderefName = "pref:Capacity"     then assign tt-wb-gds-EG.ms-base = decimal(hText:node-value) .
        if noderefName = "pref:AlcVolume"    then assign tt-wb-gds-EG.proof = decimal(hText:node-value) .
        if noderefName = "pref:ProductVCode" then assign tt-wb-gds-EG.alc-type-code = hText:node-value .
        if noderefName = "wb:Identity"
        then do:
          assign
            tt-wb-gds-EG.Identity = hText:node-value
            tt-wb-gds-EG.nn = nn
          .
        end.
        if noderefName = "wb:Price"          then assign tt-wb-gds-EG.price = decimal(hText:node-value) .
        if noderefName = "wb:Quantity"       then assign tt-wb-gds-EG.qnty = decimal(hText:node-value) .
        if noderefName = "pref:UnitType"       then assign tt-wb-gds-EG.UnitType = hText:node-value .
      end.
      if available (tt-wb-gds-EG) and lookup (parentName, "pref:Importer") > 0 then do:
        if noderefName = "oref:ClientRegId" then assign tt-wb-gds-EG.regID-Importer = hText:node-value .
        tt-wb-gds-EG.importer-th = "".
        find first ub.ext-classif no-lock
          where ub.ext-classif.classif-subject = 'clients':U
            and ub.ext-classif.classif-name = 'clients-esys':U
            and ub.ext-classif.db-num = 0
            and ub.ext-classif.key#_one = ExtSys
            and ub.ext-classif.CharKey_Three = tt-wb-gds-EG.regID-Importer
            no-error.
        if available (ub.ext-classif) then do:
          tt-wb-gds-EG.importer-th = entry (2, ub.ext-classif.uniq-key-rec, chr(3)) + entry (3, ub.ext-classif.uniq-key-rec, chr(3)).
        end.
        if noderefName = "oref:ClientRegId" then do:
          assign entry (1, tt-wb-gds-EG.importer-list, chr(5)) = hText:node-value .
          assign entry (5, tt-wb-gds-EG.importer-list, chr(5)) = "oref:address".
          assign entry (6, tt-wb-gds-EG.importer-list, chr(5)) = "oref:address".
        end.
        if noderefName = "oref:INN"         then assign entry (2, tt-wb-gds-EG.importer-list, chr(5)) = hText:node-value .
        if noderefName = "oref:KPP"         then assign entry (3, tt-wb-gds-EG.importer-list, chr(5)) = hText:node-value .
        if noderefName = "oref:FullName"    then assign entry (4, tt-wb-gds-EG.importer-list, chr(5)) = hText:node-value .
      end.
      if available (tt-wb-gds-EG) and parentName = "oref:address" and (entry (5, tt-wb-gds-EG.importer-list, chr(5)) = "oref:address" or entry (6, tt-wb-gds-EG.importer-list, chr(5)) = "oref:address")
      then do:
        if noderefName = "oref:Country"     then assign entry (5, tt-wb-gds-EG.importer-list, chr(5)) = hText:node-value .
        if noderefName = "oref:description" then assign entry (6, tt-wb-gds-EG.importer-list, chr(5)) = hText:node-value .
      end.
      if available (tt-wb-gds-EG) and
        (lookup (parentName, "pref:Producer") > 0 or lookup (parentNameOref, "pref:Producer") > 0)
      then do:
        if lookup (noderefName, "oref:UL,oref:FL,oref:FO,oref:TS") > 0
        then do:
          parentNameOref = parentName.
        end.
        case parentName:
          when "oref:UL"
            then entry (7, tt-wb-gds-EG.prod-list, chr(5)) = 'UL'.
          when "oref:FL"
            then entry (7, tt-wb-gds-EG.prod-list, chr(5)) = 'FL'.
          when "oref:FO"
            then entry (7, tt-wb-gds-EG.prod-list, chr(5)) = 'FO'.
          when "oref:TS"
            then entry (7, tt-wb-gds-EG.prod-list, chr(5)) = 'TS'.
        end case.
        if noderefName = "oref:ClientRegId" then assign tt-wb-gds-EG.regID-Producer = hText:node-value .
        tt-wb-gds-EG.producer-th = "".
        find first ub.ext-classif no-lock
          where ub.ext-classif.classif-subject = 'clients':U
            and ub.ext-classif.classif-name = 'clients-esys':U
            and ub.ext-classif.db-num = 0
            and ub.ext-classif.key#_one = ExtSys
            and ub.ext-classif.CharKey_Three = tt-wb-gds-EG.regID-Producer
            no-error.
        if available (ub.ext-classif) then do:
          tt-wb-gds-EG.producer-th = entry (2, ub.ext-classif.uniq-key-rec, chr(3)) + entry (3, ub.ext-classif.uniq-key-rec, chr(3)).
        end.
        if noderefName = "oref:ClientRegId"
        then do:
          assign entry (1, tt-wb-gds-EG.prod-list, chr(5)) = hText:node-value .
          assign entry (5, tt-wb-gds-EG.prod-list, chr(5)) = "oref:address".
          assign entry (6, tt-wb-gds-EG.prod-list, chr(5)) = "oref:address".
        end.
        if noderefName = "oref:INN"         then assign entry (2, tt-wb-gds-EG.prod-list, chr(5)) = hText:node-value .
        if noderefName = "oref:KPP"         then assign entry (3, tt-wb-gds-EG.prod-list, chr(5)) = hText:node-value .
        if noderefName = "oref:FullName"    then assign entry (4, tt-wb-gds-EG.prod-list, chr(5)) = hText:node-value .
        if noderefName = "oref:RegionCode"    then assign entry (8, tt-wb-gds-EG.prod-list, chr(5)) = hText:node-value .
      end.
      if available (tt-wb-gds-EG) and parentName = "oref:address" and (entry (5, tt-wb-gds-EG.prod-list, chr(5)) = "oref:address" or entry (6, tt-wb-gds-EG.prod-list, chr(5)) = "oref:address")
      then do:
        if noderefName = "oref:Country"     then assign entry (5, tt-wb-gds-EG.prod-list, chr(5)) = hText:node-value .
        if noderefName = "oref:description" then assign entry (6, tt-wb-gds-EG.prod-list, chr(5)) = hText:node-value .
      end.
      if lookup (parentName, "wb:InformA") > 0
        then
      do:
        if noderefName = "pref:RegId" then assign tt-wb-gds-EG.refA = hText:node-value.
      end.
      if lookup (parentName, "wb:InformF1") > 0
        then
      do:
        if noderefName = "pref:RegId" then assign tt-wb-gds-EG.refA = hText:node-value.
      end.
      if lookup (parentName, "pref:InformBItem") > 0
        then
      do:
        if noderefName = "pref:BRegId" then assign tt-wb-gds-EG.beforRefB = hText:node-value.
      end.
      if lookup (parentName, "pref:InformF2Item") > 0
        then
      do:
        if noderefName = "pref:F2RegId" then assign tt-wb-gds-EG.beforRefB = hText:node-value.
      end.
      if lookup (parentName, "wbr:Header") > 0
        then
      do:
        find first tt-wb-header no-error.
        if not available (tt-wb-header) then create tt-wb-header.
        if noderefName = "wbr:WBRegId" then assign tt-wb-header.wbregid = hText:node-value .
        if noderefName = "wbr:Identity" then assign tt-wb-header.Identity = hText:node-value .
      end.
      if lookup (parentName, "wbr:Position") > 0
        then
      do:
        if noderefName = "wbr:Identity" then
        do:
          find first tt-wb-gds-EG where tt-wb-gds-EG.Identity = hText:node-value no-error.
        end.
        if available (tt-wb-gds-EG) and (noderefName = "wbr:InformBRegId" or noderefName = "wbr:InformF2RegId") then assign tt-wb-gds-EG.refB = hText:node-value.
      end.
      if available (tt-wb-gds-EG) then do:
        if tt-wb-gds-EG.regID-Importer = ""
          then
          assign
            tt-wb-gds-EG.regID-i-p = tt-wb-gds-EG.regID-Producer
            tt-wb-gds-EG.i-p-th = tt-wb-gds-EG.producer-th
          .
          else
          assign
            tt-wb-gds-EG.regID-i-p = tt-wb-gds-EG.regID-Importer
            tt-wb-gds-EG.i-p-th = tt-wb-gds-EG.importer-th
          .
          find first ub.ext-classif no-lock
            where ub.ext-classif.classif-subject = 'clients':U
              and ub.ext-classif.classif-name = 'clients-esys':U
              and ub.ext-classif.db-num = 0
              and ub.ext-classif.key#_one = ExtSys
              and ub.ext-classif.CharKey_Three =  tt-wb-gds-EG.regID-i-p
              no-error.
          if available (ub.ext-classif) then do:
            find first buf_clients where buf_clients.obj-type = entry (2, ub.ext-classif.uniq-key-rec, chr(3)) and buf_clients.obj-code = integer (entry (3, ub.ext-classif.uniq-key-rec, chr(3))) no-error.
            if available (buf_clients)
              then tt-wb-gds-EG.i-p-name = buf_clients.obj-name.
          end.
      end.
      GetChildren(hNoderef, (level + 1)).
    end.
    delete object hNoderef.
    delete object hText.
  end.
end class.
