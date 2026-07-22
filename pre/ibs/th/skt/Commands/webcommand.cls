using ibs.th.skt.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.
class ibs.th.skt.Commands.webCommand inherits ICommand:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Обработка запросов в сокет по web" get.
  define temp-table TempTrnDoc no-undo
    field SuppInDocNo   as character
    field stts          as character
    field ext-doc-type  as character
    field doc-date      as date
    field cli-type      as character
    field cli-code      as integer
    field obj-type      as character
    field obj-code      as integer
    field ContractID    as integer
    field ContractNum   as character
    field vat-type      as character
    field tot-transp    as decimal
    field tot-other     as decimal
    field wrkr          as integer
    field agnt          as integer
    field boss          as integer
    field pay-code      as integer
    field discnt-type   as character
    field discnt-pc     as decimal
    field user-id       as character
    field reason-code   as integer
    field ps            as character
    field hold-obj-type as character
    field hold-obj-code as integer
    field ship-num      as character
    field ship-date     as date
    index pi SuppInDocNo .
  define temp-table TempDocLine no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field doc-qnty     as decimal
    field fact-qnty    as decimal
    field price-rubl   as decimal
    field vat-pc       as decimal
    field b-code       as character
    index pi
    SuppInDocNo
    line-num
    gds-code
    .
  define temp-table TempGdsDtl no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field prt-code     as integer
    field b-code       as integer
    field doc-qnty     as decimal
    field price-rubl   as decimal
    index pi
    SuppInDocNo
    line-num
    gds-code
    prt-code
    .
  define temp-table TempParts no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field part-code    as character
    field out-code     as character
    index pi
    SuppInDocNo
    line-num
    gds-code
    part-code
    .
  define temp-table TempDocAttr no-undo
    field SuppInDocNo  as character
    field attr-code    as character
    field attr-value   as character
    index pi
    SuppInDocNo
    attr-code
    .
  define public property ErrStatus as logical no-undo
    get.
    private set.
  define public property LogMsg as character no-undo
    get.
    private set.
  define private variable websrv      as class     websrv .
  define private variable hRoot       as handle    no-undo.
  define private variable hDoc        as handle    no-undo.
  define private variable hRow        as handle    no-undo.
  define private variable tthDocument as handle    no-undo.
  define private variable i           as integer   no-undo.
  define private variable userId_     as character no-undo.
  define private variable sn          as character no-undo.
  define private variable hndlSocket  as handle    no-undo.
  define private variable good        AS LOGICAL   NO-UNDO.
  define private variable line-num    as integer no-undo .
  define private variable v-type      as character no-undo .
  method public override void Execute_( input req as IRequest, resp as class IResponse ):
  do transaction:
    define variable contLength as integer   no-undo.
    define variable strLog     as character no-undo.
    define variable str        as character no-undo.
    define buffer buf_bar-code  for ub.bar-code.
    define buffer buf_prod-bc   for ub.prod-bc.
    define buffer buf_place     for ub.place.
    define buffer bfTempDocLine for TempDocLine.
    define variable ANS as logical .
    websrv = new websrv().
    create x-document hDoc.
    create x-noderef  hRoot.
    hDoc:load("longchar",req:Content,no).
    websrv:CP = hDoc:encoding.
    if hDoc:encoding <> "windows-" + session:charset then
    do:
      str = req:Content.
      str = codepage-convert (str, session:charset, hDoc:encoding) no-error.
      if error-status:error
        then return error "Ошибка при преобразовании кодировки".
      req:Content = str.
      delete object hDoc.
      create x-document hDoc.
      hDoc:load("longchar",req:Content,no).
    end.
    hDoc:encoding = if session:charset begins "12" then "windows-" + session:charset else session:charset.
    hDoc:get-document-element(hRoot) .
    assign
      websrv:ReqType = hRoot:get-attribute("item")
    .
    hndlsocket = req:HndlSocket.
    case websrv:ReqType :
      when "WAYBILL" then
        do:
          parseXML(hRoot, 1).
          websrv:ImpWB(table TempTrnDoc, table TempDocLine, table TempGdsDtl, table TempParts, table TempDocAttr, output ANS) .
            if ANS then ErrStatus = false.
            else ErrStatus = true.
        end.
      otherwise
      do:
        websrv:WriteUnknown().
      end.
    end.
    case websrv:ReqType :
      when "WAYBILL" then
        do:
          LogWrite:LogStr = 'Отправлен ответ на запрос типа "WAYBILL".' + chr(10) + LogWrite:LogStr.
        end.
    end case.
    if ErrStatus then
    do:
      writeSock("").
    end.
    else do:
      writeSock(str).
    end.
  end .
    delete object websrv.
  end method.
  method private void parseXML(hParent AS HANDLE, level AS INTEGER):
    DEFINE VARIABLE ii AS INTEGER NO-UNDO.
    DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
    DEFINE VARIABLE hText AS HANDLE NO-UNDO.
    CREATE X-NODEREF hNoderef.
    CREATE X-NODEREF hText .
    REPEAT ii = 1 TO hParent:NUM-CHILDREN:
        good = hParent:GET-CHILD(hNoderef,ii).
        IF NOT good THEN
            LEAVE.
        IF hNoderef:SUBTYPE <> "element" THEN
            NEXT.
        hNoderef:GET-CHILD(hText, 1) no-error .
        if hNoderef:NAME = "trn-doc" then do :
            create TempTrnDoc .
            line-num = 0 .
        end.
        if hNoderef:NAME = "SuppInDocNo"        then do :
            assign TempTrnDoc.SuppInDocNo =        hText:node-value no-error .
        end.
        if hNoderef:NAME = "Stts"               then assign TempTrnDoc.Stts =               hText:node-value no-error .
        if hNoderef:NAME = "ExtDocType"         then assign TempTrnDoc.ext-doc-type =       hText:node-value no-error .
        if hNoderef:NAME = "DocDate"            then assign TempTrnDoc.doc-date =           date(hText:node-value) no-error .
        if hNoderef:NAME = "ContractId"         then assign TempTrnDoc.ContractID =         integer(hText:node-value) no-error .
        if hNoderef:NAME = "ContractNum"        then assign TempTrnDoc.ContractNum =        hText:node-value no-error .
        if hNoderef:NAME = "CliType"            then assign TempTrnDoc.cli-type =           hText:node-value no-error .
        if hNoderef:NAME = "CliCode"            then assign TempTrnDoc.cli-code =           integer(hText:node-value) no-error .
        if hNoderef:NAME = "ObjType"            then assign TempTrnDoc.obj-type =           hText:node-value no-error .
        if hNoderef:NAME = "ObjCode"            then assign TempTrnDoc.obj-code =           integer(hText:node-value) no-error .
        if hNoderef:NAME = "VatType"            then assign TempTrnDoc.vat-type =           hText:node-value no-error .
        if hNoderef:NAME = "TransportExpSuppl"  then assign TempTrnDoc.tot-transp =         decimal(hText:node-value) no-error .
        if hNoderef:NAME = "OtherExpSuppl"      then assign TempTrnDoc.tot-other =          decimal(hText:node-value) no-error .
        if hNoderef:NAME = "Wrkr"               then assign TempTrnDoc.wrkr =               integer(hText:node-value) no-error .
        if hNoderef:NAME = "Agnt"               then assign TempTrnDoc.agnt =               integer(hText:node-value) no-error .
        if hNoderef:NAME = "Boss"               then assign TempTrnDoc.boss =               integer(hText:node-value) no-error .
        if hNoderef:NAME = "PayCode"            then assign TempTrnDoc.pay-code =           integer(hText:node-value) no-error .
        if hNoderef:NAME = "DiscntType"         then assign TempTrnDoc.discnt-type =        hText:node-value no-error .
        if hNoderef:NAME = "DiscntPc"           then assign TempTrnDoc.discnt-pc =          decimal(hText:node-value) no-error .
        if hNoderef:NAME = "User-id"            then assign TempTrnDoc.user-id =            hText:node-value no-error .
        if hNoderef:NAME = "PS"                 then assign TempTrnDoc.ps =                 hText:node-value no-error .
        if hNoderef:NAME = "ReasonCode"         then assign TempTrnDoc.reason-code =        integer(hText:node-value) no-error .
        if hNoderef:NAME = "hold-obj-type"      then assign TempTrnDoc.hold-obj-type =      hText:node-value no-error .
        if hNoderef:NAME = "hold-obj-code"      then assign TempTrnDoc.hold-obj-code =      integer(hText:node-value) no-error .
        if hNoderef:NAME = "ShipNum"            then assign TempTrnDoc.ship-num =           hText:node-value no-error .
        if hNoderef:NAME = "ShipDate"           then assign TempTrnDoc.ship-date =          date(hText:node-value) no-error .
        if hNoderef:NAME = "PlaceStorage" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'PlaceStorage':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "QntyPlace" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'QntyPlace':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Packer" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'Packer':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Dispath" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'Dispath':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "NFinDoc" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'NFinDoc':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "DFinDoc" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'DFinDoc':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "clcasol" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'clcasol':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "clcaswt" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'clcaswt':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "indoclnsum" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'indoclnsum':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "purchlimit" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'purchlimit':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "purchcodelist" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'purchcodelist':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "expense_own" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'expense_own':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "priceTarget" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'price-target':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "envd" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'envd':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "discntStop" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'discnt-stop':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "discntOther" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'discnt-other':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "scanfile" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'scanfile':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "addsum" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'addsum':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "F21ord_phone" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = '21ord_phone':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "F22ord_contact" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = '22ord_contact':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "F4ord_dl" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = '4ord_dl':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "F8ord_adr" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = '8ord_adr':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Auto" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'Auto':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "cargo-desc" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'cargo-desc':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "cargo-mass" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'cargo-mass':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "carry-type" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'carry-type':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ddog" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'ddog':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ddov" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'ddov':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "dids" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'dids':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "nids" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'nids':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "negais" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'negais':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "egais" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'egais':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "delivery-date" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'delivery-date':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "delivery-time" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'delivery-time':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ptbobj" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'ptbobj':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "autoent" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'autoent':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "car-num" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'car-num':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "fio-driver" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'fio-driver':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "time-income" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'time-income':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "inspection-cert" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'inspection-cert':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "date-cert" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'date-cert':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "condition" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'condition':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "seals-condition" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'seals-condition':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ptb-item-pour" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'ptb-item-pour':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "postpay" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = '1postpay':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Driver" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'Driver':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "dsf" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'dsf':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "exp-trans" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'exp-trans':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ndog" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'ndog':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ndov" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'ndov':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ndovwho" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'ndovwho':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "nosn" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'nosn':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "nsf" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'nsf':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "dateinv" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'dateinv':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "ser_on_pack" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'ser_on_pack':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "print-num" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'print-num':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Recipient" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'Recipient':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "Shipper" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'Shipper':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "oldsuppcntr" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'olsuppcntr':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "t_accept-fname" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 't_accept-fname':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "t_accept-position" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 't_accept-position':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "t_pass-fname" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 't_pass-fname':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "t_pass-position" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 't_pass-position':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "zakaz-date" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'zakaz-date':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "zakaz-number" then do :
            create TempDocAttr .
            assign
                TempDocAttr.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocAttr.attr-code   = 'zakaz-number':U
                TempDocAttr.attr-value  = hText:node-value
            no-error.
            if error-status:error then delete TempDocAttr .
        end.
        if hNoderef:NAME = "doc-Line" then do :
            v-type = "doc-line" .
            create TempDocLine .
            line-num = line-num + 1 .
            assign
                TempDocLine.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempDocLine.line-num    = line-num
            no-error.
        end.
        if hNoderef:NAME = "gdsCode"        then assign TempDocLine.gds-code        = integer(hText:node-value) no-error .
        if hNoderef:NAME = "DocQnty"        then do :
            if v-type = "doc-line"          then assign TempDocLine.doc-qnty        = decimal(hText:node-value) no-error .
            if v-type = "gds-dtl"           then assign TempGdsDtl.doc-qnty         = decimal(hText:node-value) no-error .
        end.
        if hNoderef:NAME = "PriceRubl"      then assign TempDocLine.price-rubl      = decimal(hText:node-value) no-error .
        if hNoderef:NAME = "VatPcDoc"       then assign TempDocLine.vat-pc          = decimal(hText:node-value) no-error .
        if hNoderef:NAME = "gds-dtl" then do :
            v-type = "gds-dtl" .
            create TempGdsDtl .
            assign
                TempGdsDtl.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempGdsDtl.line-num    = TempDocLine.line-num
                TempGdsDtl.gds-code    = TempDocLine.gds-code
            .
        end.
        if hNoderef:NAME = "PrtCode"        then assign TempGdsDtl.prt-code         = integer(hText:node-value) no-error .
        if hNoderef:NAME = "BarCodeUnitBase" then assign TempGdsDtl.b-code          = integer(hText:node-value) no-error .
        if hNoderef:NAME = "PriceRublDoc"   then assign TempGdsDtl.price-rubl       = decimal(hText:node-value) no-error .
        if hNoderef:NAME = "parts" then do :
            create TempParts .
            assign
                TempParts.SuppInDocNo = TempTrnDoc.SuppInDocNo
                TempParts.line-num    = TempDocLine.line-num
                TempParts.gds-code    = TempDocLine.gds-code
            .
        end.
        if hNoderef:NAME = "partCode"       then assign TempParts.part-code         = hText:node-value no-error .
        if hNoderef:NAME = "parDocNum"      then assign TempParts.out-code          = hText:node-value no-error .
        parseXML(hNoderef, (level + 1)).
    end.
    DELETE OBJECT hNoderef.
    DELETE OBJECT hText.
  end method.
  method private logical writeSock ( arg as character ):
    define variable mbuffer  as memptr   no-undo.
    define variable mbuffer1 as memptr   no-undo.
    define variable tempStr  as longchar no-undo.
    define variable glog     as logical  no-undo.
    set-size(mbuffer1) = length (websrv:SomeStr, "RAW":U) + 1.
    put-string(mbuffer1,1) = websrv:SomeStr.
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
