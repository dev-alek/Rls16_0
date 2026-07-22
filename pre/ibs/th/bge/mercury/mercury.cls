using Progress.Lang.*.
using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.clients.*.
block-level on error undo, throw.
class ibs.th.bge.mercury.mercury:
  define variable vsdStat as class ibs.th.str.mercury.vsdstatustype no-undo.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define property apiKey as character no-undo init ?
    get.
    private set.
  define property issuerId as character no-undo init ?
    get.
    private set.
  define property login as character no-undo init ?
    get.
    private set.
  define property login_is as character no-undo init ?
    get.
    private set.
  define property password as character no-undo init ?
    get.
    private set.
  define property proxy-addr as character no-undo init ?
    get.
    private set.
  define property proxy-login as character no-undo init ?
    get.
    private set.
  define property proxy-pswd as character no-undo init ?
    get.
    private set.
  define property proxy-ssl as logical no-undo init ?
    get.
    private set.
  define property esysId as integer no-undo init ?
    get.
    private set.
  define property DbNum as integer no-undo init ?
    get.
    private set.
  define property server_ as character no-undo init ?
    get.
    private set.
  define property applicationId as character no-undo
    get.
    protected set.
  define property vsdId as int64 no-undo
    get.
    set.
  define property Status_ as character no-undo
    get.
    protected set.
  define property Msg as character no-undo
    get.
    protected set.
  define property StatusErr as logical no-undo init false
    get.
    protected set.
  define variable vsds as class vsdsubs no-undo .
  define variable vsdStorage as class vsdtostorage no-undo .
  define variable gdsMercsubsObj as class gdsmercsubs no-undo .
  define variable gdsmercstrObj as class gdsmercstr no-undo .
  define buffer buf_ext-classif        for ub.ext-classif.
  define buffer buf_ext-system         for ub.ext-system.
  def var ii as integer no-undo .
  constructor public mercury (inApiKey as char,
                              inIssuerId as char,
                              inLogin as char,
                              inPassword as char,
                              inLogin_is as char,
                              inEsysId as int,
                              inServer as int,
                              inProxyAddr as char,
                              inProxyLogin as char,
                              inProxyPswd as char,
                              inProxySSL as logical,
                              inDbNum as int):
    assign
      apiKey   = inApiKey
      issuerId = inIssuerId
      login    = inLogin
      password = inPassword
      login_is = inLogin_is
      esysId   = inEsysId
      proxy-addr = inProxyAddr
      proxy-login = inProxyLogin
      proxy-pswd = inProxyPswd
      proxy-ssl = inProxySSL
      DbNum = inDbNum
    .
    if inServer = 1 then server_ = "https://api2.vetrf.ru:8002" .
    if inServer = 2 then server_ = "https://api.vetrf.ru" .
                vsdStat = new vsdstatustype () .
  end constructor.
  destructor public mercury ( ):
    delete object vsds no-error .
    delete object vsdStorage no-error .
    delete object gdsMercsubsObj no-error .
    delete object gdsmercstrObj no-error .
  end destructor.
  method public void GetVetDocumentByUuid
  (
   input inUuid as char,
   input inEntGuid as char,
   output p-applicationId as char,
   output p-Status_ as char,
   output p-Msg  as char
  ) :
    define variable cmd as character no-undo .
    define variable sw as handle no-undo .
    define variable v-file  as character no-undo .
    v-file = "GetVetDocumentByUuid_DB" + string(DbNum) + ".xml" .
    define variable v-resp-file as character no-undo .
    v-resp-file = "ApplicationResponse_DB" + string(DbNum) + ".xml" .
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("se:Envelope") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:dt", "http://api.vetrf.ru/schema/cdm/dictionary/v2") .
    sw:insert-attribute ("xmlns:bs", "http://api.vetrf.ru/schema/cdm/base") .
    sw:insert-attribute ("xmlns:merc", "http://api.vetrf.ru/schema/cdm/mercury/g2b/applications/v2") .
    sw:insert-attribute ("xmlns:apldef", "http://api.vetrf.ru/schema/cdm/application/ws-definitions") .
    sw:insert-attribute ("xmlns:apl", "http://api.vetrf.ru/schema/cdm/application") .
    sw:insert-attribute ("xmlns:vd", "http://api.vetrf.ru/schema/cdm/mercury/vet-document/v2") .
    sw:insert-attribute ("xmlns:se", "http://schemas.xmlsoap.org/soap/envelope/") .
      sw:start-element ("se:Body") .
        sw:start-element ("apldef:submitApplicationRequest") .
          sw:write-data-element ("apldef:apiKey", apiKey) .
          sw:start-element ("apl:application") .
            sw:write-data-element ("apl:serviceId", "mercury-g2b.service:2.1") .
            sw:write-data-element ("apl:issuerId", issuerId) .
            sw:write-data-element ("apl:issueDate", iso-date(now)) .
            sw:start-element ("apl:data") .
              sw:start-element ("merc:getVetDocumentByUuidRequest") .
                sw:write-data-element ("merc:localTransactionId", "1") .
                sw:start-element ("merc:initiator") .
                  sw:write-data-element ("vd:login", login_is) .
                sw:end-element ("merc:initiator") .
                sw:write-data-element ("bs:uuid", inUuid) .
                sw:write-data-element ("dt:enterpriseGuid", inEntGuid) .
              sw:end-element ("merc:getVetDocumentByUuidRequest") .
            sw:end-element ("apl:data") .
          sw:end-element ("apl:application") .
        sw:end-element ("apldef:submitApplicationRequest") .
      sw:end-element ("se:Body") .
    sw:end-element ("se:Envelope") .
    sw:end-document () .
    delete object sw.
    if trim(proxy-addr) <> "" and proxy-addr <> ?
    then do :
      if proxy-ssl
      then do :
        cmd = substitute ("&1 -k --proxy-negotiate -x &7 -U : -u &4:&5 -d @&2 &6/platform/services/2.1/ApplicationManagementService >&3",
                        search ("exe/curl.exe"), SearchFile(v-file), v-resp-file, login, password, server_, proxy-addr).
      end.
      else do :
        cmd = substitute ("&1 -x &7 -U &8:&9 -u &4:&5 -d @&2 &6/platform/services/2.1/ApplicationManagementService >&3",
                        search ("exe/curl.exe"), SearchFile(v-file), v-resp-file, login, password, server_, proxy-addr, proxy-login, proxy-pswd).
      end.
    end.
    else do :
      cmd = substitute ("&1 -u &4:&5 -d @&2 &6/platform/services/2.1/ApplicationManagementService >&3",
                      search ("exe/curl.exe"), SearchFile(v-file), v-resp-file, login, password, server_).
    end.
    os-command silent value (cmd).
    ParseXML(input SearchFile(v-resp-file)) .
    p-applicationId = applicationId .
    p-Status_ = Status_ .
    p-Msg = Msg .
    pause 0.2 .
  end method.
  method public void processIncomingConsignment
  (
   input inVsdSubs as class vsdsubs,
   input p-qnty as decimal,
   input p-fact-qnty as decimal,
   output p-applicationId as char,
   output p-Status_ as char,
   output p-Msg  as char
  ) :
    define variable cmd as character no-undo .
    define variable sw as handle no-undo .
    define variable v-file  as character no-undo .
    v-file = "processIncomingConsignment_DB" + string(DbNum) + ".xml" .
    define variable v-resp-file as character no-undo .
    v-resp-file = "ApplicationResponse_DB" + string(DbNum) + ".xml" .
    define variable v-cli-be-guid as character no-undo .
    define variable v-cli-ent-guid as character no-undo .
    define variable v-obj-be-guid as character no-undo .
    define variable v-obj-ent-guid as character no-undo .
    define variable rd as integer no-undo .
    define variable bi as integer no-undo .
    define variable v-util-qnty as decimal no-undo .
    define variable v-return-qnty as decimal no-undo .
    define variable jj as integer no-undo .
    define variable v-is-return as logical no-undo .
    define variable unitsMercObj as class unitsubs no-undo .
    define variable unitMercStr as class unitmercstr no-undo .
    define buffer buf_goods for ub.goods .
    define buffer buf_units-attr for ub.units-attr .
    gdsMercsubsObj = new gdsmercsubs ().
    gdsmercstrObj = new gdsmercstr ().
    unitsMercObj = new unitsubs ().
    unitMercStr = new unitmercstr ().
    find first buf_ext-system no-lock where buf_ext-system.esys-type = integer('10':U) no-error.
    if not available buf_ext-system
    then do :
    end.
    v-obj-be-guid = inVsdSubs:VsdObjCurr:ObjBeGuid no-error .
    v-obj-ent-guid = inVsdSubs:VsdObjCurr:ObjEntGuid no-error .
    find first buf_ext-classif no-lock
        where buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name = 'clients-esys':U
          and buf_ext-classif.db-num = 0
          and buf_ext-classif.key#_one = buf_ext-system.esys-id
          and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + inVsdSubs:VsdObjCurr:ObjType + chr(3) + string (inVsdSubs:VsdObjCurr:ObjCode)
          no-error.
    if v-obj-be-guid = "" or v-obj-be-guid = ? then
      v-obj-be-guid = entry(1, buf_ext-classif.charKey_Two, chr(6)) no-error.
    if v-obj-ent-guid = "" or v-obj-ent-guid = ? then
      v-obj-ent-guid = entry(2, buf_ext-classif.charKey_Two, chr(6)) no-error.
    if v-obj-be-guid = "" or v-obj-be-guid = ? then v-obj-be-guid = issuerId .
    v-cli-be-guid = inVsdSubs:VsdObjCurr:CliBeGuid no-error .
    v-cli-ent-guid = inVsdSubs:VsdObjCurr:CliEntGuid no-error .
    find first buf_ext-classif no-lock
        where buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name = 'clients-esys':U
          and buf_ext-classif.db-num = 0
          and buf_ext-classif.key#_one = buf_ext-system.esys-id
          and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + inVsdSubs:VsdObjCurr:CliType + chr(3) + string (inVsdSubs:VsdObjCurr:CliCode)
          no-error.
    if v-cli-be-guid = "" or v-cli-be-guid = ? then
      v-cli-be-guid = entry(1, buf_ext-classif.charKey_Two, chr(6)) no-error.
    if v-cli-ent-guid = "" or v-cli-ent-guid = ? then
      v-cli-ent-guid = entry(2, buf_ext-classif.charKey_Two, chr(6)) no-error.
    if (v-cli-be-guid = "" or v-cli-be-guid = ?) and inVsdSubs:VsdObjCurr:CliType = 'маг' then v-cli-be-guid = issuerId .
    find first buf_goods no-lock where buf_goods.gds-code = inVsdSubs:VsdObjCurr:GdsCode no-error .
    if not available buf_goods
    then do :
      p-Status_ = "CritErr_GdsCode" .
      p-Msg = "Не найден товар из ВСД. Код товара в ВСД - " + string(inVsdSubs:VsdObjCurr:GdsCode) . .
      return .
    end .
    find first buf_units-attr no-lock where buf_units-attr.unit-name = buf_goods.unit-base
                                        and buf_units-attr.attr-code = "MercGuid"
                                        no-error .
    if available buf_units-attr
    and buf_units-attr.attr-value = inVsdSubs:VsdObjCurr:UnitGuid
    then do :
      if p-qnty = p-fact-qnty
      then do :
        v-util-qnty = p-qnty .
        v-return-qnty = 0 .
        v-is-return = false .
      end.
      else do :
        v-util-qnty = p-fact-qnty .
        v-return-qnty = p-qnty - v-util-qnty .
        v-is-return = true .
      end.
    end.
    else do :
      unitsMercObj = unitMercStr:getunitmercs(inVsdSubs:VsdObjCurr:GdsCode) .
      units_ :
      do jj = 1 to unitsMercObj:GetItem (jj):
        find first buf_units-attr no-lock where buf_units-attr.unit-name = unitsMercObj:UnitObjCurr:UnitName
                                            and buf_units-attr.attr-code = "MercGuid"
                                            no-error .
        if not available buf_units-attr then next units_ .
        if buf_units-attr.attr-value = inVsdSubs:VsdObjCurr:UnitGuid
        then do :
          if p-qnty = p-fact-qnty
          then do :
            v-util-qnty = p-qnty * unitsMercObj:UnitObjCurr:UnitCoef .
            v-return-qnty = 0 .
            v-is-return = false .
          end.
          else do :
            v-util-qnty = p-fact-qnty * unitsMercObj:UnitObjCurr:UnitCoef .
            v-return-qnty = (p-qnty - p-fact-qnty) * unitsMercObj:UnitObjCurr:UnitCoef .
            v-is-return = true .
          end.
          leave units_ .
        end.
      end.
    end.
    gdsMercsubsObj = gdsmercstrObj:getgdsmercs(inVsdSubs:VsdObjCurr:GdsCode).
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("se:Envelope") .
    sw:insert-attribute ("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance") .
    sw:insert-attribute ("xmlns:dt", "http://api.vetrf.ru/schema/cdm/dictionary/v2") .
    sw:insert-attribute ("xmlns:bs", "http://api.vetrf.ru/schema/cdm/base") .
    sw:insert-attribute ("xmlns:merc", "http://api.vetrf.ru/schema/cdm/mercury/g2b/applications/v2") .
    sw:insert-attribute ("xmlns:apldef", "http://api.vetrf.ru/schema/cdm/application/ws-definitions") .
    sw:insert-attribute ("xmlns:apl", "http://api.vetrf.ru/schema/cdm/application") .
    sw:insert-attribute ("xmlns:vd", "http://api.vetrf.ru/schema/cdm/mercury/vet-document/v2") .
    sw:insert-attribute ("xmlns:se", "http://schemas.xmlsoap.org/soap/envelope/") .
      sw:start-element ("se:Body") .
        sw:start-element ("apldef:submitApplicationRequest") .
          sw:write-data-element ("apldef:apiKey", apiKey) .
          sw:start-element ("apl:application") .
            sw:write-data-element ("apl:serviceId", "mercury-g2b.service:2.1") .
            sw:write-data-element ("apl:issuerId", issuerId) .
            sw:write-data-element ("apl:issueDate", iso-date(now)) .
            sw:start-element ("apl:data") .
              sw:start-element ("merc:processIncomingConsignmentRequest") .
                sw:write-data-element ("merc:localTransactionId", "1") .
                sw:start-element ("merc:initiator") .
                  sw:write-data-element ("vd:login", login_is) .
                sw:end-element ("merc:initiator") .
                sw:start-element ("merc:delivery") .
                  sw:write-data-element ("vd:deliveryDate", iso-date(inVsdSubs:VsdObjCurr:FactDatetime)) .
                  sw:start-element ("vd:consignor") .
                    sw:start-element ("dt:businessEntity") .
                      sw:write-data-element ("bs:guid", LC(v-cli-be-guid)) .
                    sw:end-element ("dt:businessEntity") .
                    sw:start-element ("dt:enterprise") .
                      sw:write-data-element ("bs:guid", LC(v-cli-ent-guid)) .
                    sw:end-element ("dt:enterprise") .
                  sw:end-element ("vd:consignor") .
                  sw:start-element ("vd:consignee") .
                    sw:start-element ("dt:businessEntity") .
                      sw:write-data-element ("bs:guid", LC(v-obj-be-guid)) .
                    sw:end-element ("dt:businessEntity") .
                    sw:start-element ("dt:enterprise") .
                      sw:write-data-element ("bs:guid", LC(v-obj-ent-guid)) .
                    sw:end-element ("dt:enterprise") .
                  sw:end-element ("vd:consignee") .
                if v-util-qnty > 0
                then do :
                  sw:start-element ("vd:consignment") .
                    sw:write-data-element ("vd:productType", inVsdSubs:VsdObjCurr:TypeProd) .
                    sw:start-element ("vd:product") .
                      if inVsdSubs:VsdObjCurr:ProductGuid <> "" and inVsdSubs:VsdObjCurr:ProductGuid <> ?
                      then sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:ProductGuid)) .
                      else sw:write-data-element ("bs:guid", LC(gdsMercsubsObj:GdsMercsubsCurr:GUIDType)) .
                    sw:end-element ("vd:product") .
                    sw:start-element ("vd:subProduct") .
                      if inVsdSubs:VsdObjCurr:SubProductGuid <> "" and inVsdSubs:VsdObjCurr:SubProductGuid <> ?
                      then sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:SubProductGuid)) .
                      else sw:write-data-element ("bs:guid", LC(gdsMercsubsObj:GdsMercsubsCurr:GUIDSubType)) .
                    sw:end-element ("vd:subProduct") .
                    sw:start-element ("vd:productItem") .
                      if inVsdSubs:VsdObjCurr:GdsGuid <> ? and inVsdSubs:VsdObjCurr:GdsGuid <> ""
                      then sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:GdsGuid)) .
                      if inVsdSubs:VsdObjCurr:GdsName <> ? and inVsdSubs:VsdObjCurr:GdsName <> ""
                      then sw:write-data-element ("dt:name", inVsdSubs:VsdObjCurr:GdsName) .
                    sw:end-element ("vd:productItem") .
                    sw:write-data-element ("vd:volume", string(round(v-util-qnty, 6))) .
                    sw:start-element ("vd:unit") .
                      sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:UnitGuid)) .
                    sw:end-element ("vd:unit") .
                    sw:start-element ("vd:dateOfProduction") .
                      sw:start-element ("vd:firstDate") .
                        sw:write-data-element ("dt:year", entry(1, inVsdSubs:VsdObjCurr:DateOut, ":")) .
                        if entry(2, inVsdSubs:VsdObjCurr:DateOut, ":") <> ""
                        then sw:write-data-element ("dt:month", entry(2, inVsdSubs:VsdObjCurr:DateOut, ":")) .
                        if entry(3, inVsdSubs:VsdObjCurr:DateOut, ":") <> ""
                        then sw:write-data-element ("dt:day", entry(3, inVsdSubs:VsdObjCurr:DateOut, ":")) .
                        if entry(4, inVsdSubs:VsdObjCurr:DateOut, ":") <> ""
                        then sw:write-data-element ("dt:hour", entry(4, inVsdSubs:VsdObjCurr:DateOut, ":")) .
                      sw:end-element ("vd:firstDate") .
                    if inVsdSubs:VsdObjCurr:ExpiryOutDate <> ? and inVsdSubs:VsdObjCurr:ExpiryOutDate <> ":::" and inVsdSubs:VsdObjCurr:ExpiryOutDate <> ""
                    then do :
                      sw:start-element ("vd:secondDate") .
                        sw:write-data-element ("dt:year", entry(1, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":")) .
                        if entry(2, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":") <> ""
                        then sw:write-data-element ("dt:month", entry(2, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":")) .
                        if entry(3, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":") <> ""
                        then sw:write-data-element ("dt:day", entry(3, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":")) .
                        if entry(4, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":") <> ""
                        then sw:write-data-element ("dt:hour", entry(4, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":")) .
                      sw:end-element ("vd:secondDate") .
                    end.
                    sw:end-element ("vd:dateOfProduction") .
                    sw:start-element ("vd:expiryDate") .
                      sw:start-element ("vd:firstDate") .
                        sw:write-data-element ("dt:year", entry(1, inVsdSubs:VsdObjCurr:ExpiryDate, ":")) .
                        if entry(2, inVsdSubs:VsdObjCurr:ExpiryDate, ":") <> ""
                        then sw:write-data-element ("dt:month", entry(2, inVsdSubs:VsdObjCurr:ExpiryDate, ":")) .
                        if entry(3, inVsdSubs:VsdObjCurr:ExpiryDate, ":") <> ""
                        then sw:write-data-element ("dt:day", entry(3, inVsdSubs:VsdObjCurr:ExpiryDate, ":")) .
                        if entry(4, inVsdSubs:VsdObjCurr:ExpiryDate, ":") <> ""
                        then sw:write-data-element ("dt:hour", entry(4, inVsdSubs:VsdObjCurr:ExpiryDate, ":")) .
                      sw:end-element ("vd:firstDate") .
                    if inVsdSubs:VsdObjCurr:ExpiryDate2 <> ? and inVsdSubs:VsdObjCurr:ExpiryDate2 <> ":::" and inVsdSubs:VsdObjCurr:ExpiryDate2 <> ""
                    then do :
                      sw:start-element ("vd:secondDate") .
                        sw:write-data-element ("dt:year", entry(1, inVsdSubs:VsdObjCurr:ExpiryDate2, ":")) .
                        if entry(2, inVsdSubs:VsdObjCurr:ExpiryDate2, ":") <> ""
                        then sw:write-data-element ("dt:month", entry(2, inVsdSubs:VsdObjCurr:ExpiryDate2, ":")) .
                        if entry(3, inVsdSubs:VsdObjCurr:ExpiryDate2, ":") <> ""
                        then sw:write-data-element ("dt:day", entry(3, inVsdSubs:VsdObjCurr:ExpiryDate2, ":")) .
                        if entry(4, inVsdSubs:VsdObjCurr:ExpiryDate2, ":") <> ""
                        then sw:write-data-element ("dt:hour", entry(4, inVsdSubs:VsdObjCurr:ExpiryDate2, ":")) .
                      sw:end-element ("vd:secondDate") .
                    end.
                    sw:end-element ("vd:expiryDate") .
                    do bi = 2 to num-entries(inVsdSubs:VsdObjCurr:NumPart, chr(4)) :
                      sw:write-data-element ("vd:batchID", entry(bi, inVsdSubs:VsdObjCurr:NumPart, chr(4))) .
                    end .
                    sw:write-data-element ("vd:perishable", inVsdSubs:VsdObjCurr:Perishable) .
                    sw:start-element ("vd:origin") .
                      sw:start-element ("vd:country") .
                        sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:OrigCountryGuid)) .
                      sw:end-element ("vd:country") .
                      sw:start-element ("vd:producer") .
                        if inVsdSubs:VsdObjCurr:ProducerGuid <> "" and inVsdSubs:VsdObjCurr:ProducerGuid <> ?
                        then do :
                          sw:start-element ("dt:enterprise") .
                            sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:ProducerGuid)) .
                          sw:end-element ("dt:enterprise") .
                        end.
                        else sw:write-empty-element ("dt:enterprise") .
                        if inVsdSubs:VsdObjCurr:ProducerRole <> ""
                        then  sw:write-data-element ("dt:role", inVsdSubs:VsdObjCurr:ProducerRole) .
                      sw:end-element ("vd:producer") .
                    sw:end-element ("vd:origin") .
                  sw:end-element ("vd:consignment") .
                end.
                if inVsdSubs:VsdObjCurr:BrokerGuid <> ""
                then do :
                  sw:start-element ("vd:broker") .
                    sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:BrokerGuid)) .
                  sw:end-element ("vd:broker") .
                end.
                  sw:start-element ("vd:transportInfo") .
                    sw:write-data-element ("vd:transportType", inVsdSubs:VsdObjCurr:Transport) .
                    sw:start-element ("vd:transportNumber") .
                      if inVsdSubs:VsdObjCurr:ContainerNum <> ""
                      then sw:write-data-element ("vd:containerNumber", inVsdSubs:VsdObjCurr:ContainerNum) .
                      case inVsdSubs:VsdObjCurr:Transport :
                        when "1" then sw:write-data-element ("vd:vehicleNumber", inVsdSubs:VsdObjCurr:CarNum) .
                        when "2" then sw:write-data-element ("vd:wagonNumber", inVsdSubs:VsdObjCurr:CarNum) .
                        when "3" then sw:write-data-element ("vd:flightNumber", inVsdSubs:VsdObjCurr:CarNum) .
                        when "4" or
                        when "5 "then sw:write-data-element ("vd:shipName", inVsdSubs:VsdObjCurr:CarNum) .
                      end case .
                      if inVsdSubs:VsdObjCurr:TrailerNum <> ""
                      then sw:write-data-element ("vd:trailerNumber", inVsdSubs:VsdObjCurr:TrailerNum) .
                    sw:end-element ("vd:transportNumber") .
                  sw:end-element ("vd:transportInfo") .
                  sw:write-data-element ("vd:transportStorageType", inVsdSubs:VsdObjCurr:TransportType) .
                  sw:start-element ("vd:accompanyingForms") .
                    do rd = 2 to num-entries(inVsdSubs:VsdObjCurr:TTNtype, chr(4)) :
                      if entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) = "1"
                      or entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) = "2"
                      or entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) = "3"
                      or entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) = "4"
                      or entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) = "5"
                      then do :
                        sw:start-element ("vd:waybill") .
                          if  entry(rd, inVsdSubs:VsdObjCurr:TTNissueSeries, chr(4)) <> ""
                          then sw:write-data-element ("vd:issueSeries", entry(rd, inVsdSubs:VsdObjCurr:TTNissueSeries, chr(4))) .
                          sw:write-data-element ("vd:issueNumber", entry(rd, inVsdSubs:VsdObjCurr:TTNissueNumber, chr(4))) .
                          sw:write-data-element ("vd:issueDate", entry(rd, inVsdSubs:VsdObjCurr:TTNissueDate, chr(4))) .
                          sw:write-data-element ("vd:type", entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4))) .
                        sw:end-element ("vd:waybill") .
                      end.
                    end.
                    sw:start-element ("vd:vetCertificate") .
                      sw:write-data-element ("bs:uuid", LC(inVsdSubs:VsdObjCurr:UUID)) .
                    sw:end-element ("vd:vetCertificate") .
                  sw:end-element ("vd:accompanyingForms") .
                sw:end-element ("merc:delivery") .
                sw:start-element ("merc:deliveryFacts") .
                  sw:write-data-element ("vd:vetCertificatePresence", "ELECTRONIC") .
                  sw:start-element ("vd:docInspection") .
                    sw:start-element ("vd:responsible") .
                      sw:write-data-element ("vd:login", login_is) .
                    sw:end-element ("vd:responsible") .
                    sw:write-data-element ("vd:result", "CORRESPONDS") .
                  sw:end-element ("vd:docInspection") .
                  sw:start-element ("vd:vetInspection") .
                    sw:start-element ("vd:responsible") .
                      sw:write-data-element ("vd:login", login_is) .
                    sw:end-element ("vd:responsible") .
                    sw:write-data-element ("vd:result", "CORRESPONDS") .
                  sw:end-element ("vd:vetInspection") .
                  if v-util-qnty = 0
                  then sw:write-data-element ("vd:decision", "RETURN_ALL") .
                  else
                  if v-is-return
                  then sw:write-data-element ("vd:decision", "PARTIALLY") .
                  else sw:write-data-element ("vd:decision", "ACCEPT_ALL") .
                sw:end-element ("merc:deliveryFacts") .
              if v-is-return
              then do :
                sw:start-element ("merc:returnedDelivery") .
                  sw:write-data-element ("vd:deliveryDate", iso-date(inVsdSubs:VsdObjCurr:FactDatetime)) .
                  sw:start-element ("vd:consignor") .
                    sw:start-element ("dt:businessEntity") .
                      sw:write-data-element ("bs:guid", LC(v-obj-be-guid)) .
                    sw:end-element ("dt:businessEntity") .
                    sw:start-element ("dt:enterprise") .
                      sw:write-data-element ("bs:guid", LC(v-obj-ent-guid)) .
                    sw:end-element ("dt:enterprise") .
                  sw:end-element ("vd:consignor") .
                  sw:start-element ("vd:consignee") .
                    sw:start-element ("dt:businessEntity") .
                      sw:write-data-element ("bs:guid", LC(v-cli-be-guid)) .
                    sw:end-element ("dt:businessEntity") .
                    sw:start-element ("dt:enterprise") .
                      sw:write-data-element ("bs:guid", LC(v-cli-ent-guid)) .
                    sw:end-element ("dt:enterprise") .
                  sw:end-element ("vd:consignee") .
                  sw:start-element ("vd:consignment") .
                    sw:write-data-element ("vd:productType", inVsdSubs:VsdObjCurr:TypeProd) .
                    sw:start-element ("vd:product") .
                      if inVsdSubs:VsdObjCurr:ProductGuid <> "" and inVsdSubs:VsdObjCurr:ProductGuid <> ?
                      then sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:ProductGuid)) .
                      else sw:write-data-element ("bs:guid", LC(gdsMercsubsObj:GdsMercsubsCurr:GUIDType)) .
                    sw:end-element ("vd:product") .
                    sw:start-element ("vd:subProduct") .
                      if inVsdSubs:VsdObjCurr:SubProductGuid <> "" and inVsdSubs:VsdObjCurr:SubProductGuid <> ?
                      then sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:SubProductGuid)) .
                      else sw:write-data-element ("bs:guid", LC(gdsMercsubsObj:GdsMercsubsCurr:GUIDSubType)) .
                    sw:end-element ("vd:subProduct") .
                    sw:start-element ("vd:productItem") .
                      if inVsdSubs:VsdObjCurr:GdsGuid <> ? and inVsdSubs:VsdObjCurr:GdsGuid <> ""
                      then sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:GdsGuid)) .
                      if inVsdSubs:VsdObjCurr:GdsName <> ? and inVsdSubs:VsdObjCurr:GdsName <> ""
                      then sw:write-data-element ("dt:name", inVsdSubs:VsdObjCurr:GdsName) .
                    sw:end-element ("vd:productItem") .
                    sw:write-data-element ("vd:volume", string(round(v-return-qnty, 6))) .
                    sw:start-element ("vd:unit") .
                      sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:UnitGuid)) .
                    sw:end-element ("vd:unit") .
                    sw:start-element ("vd:dateOfProduction") .
                      sw:start-element ("vd:firstDate") .
                        sw:write-data-element ("dt:year", entry(1, inVsdSubs:VsdObjCurr:DateOut, ":")) .
                        if entry(2, inVsdSubs:VsdObjCurr:DateOut, ":") <> ""
                        then sw:write-data-element ("dt:month", entry(2, inVsdSubs:VsdObjCurr:DateOut, ":")) .
                        if entry(3, inVsdSubs:VsdObjCurr:DateOut, ":") <> ""
                        then sw:write-data-element ("dt:day", entry(3, inVsdSubs:VsdObjCurr:DateOut, ":")) .
                        if entry(4, inVsdSubs:VsdObjCurr:DateOut, ":") <> ""
                        then sw:write-data-element ("dt:hour", entry(4, inVsdSubs:VsdObjCurr:DateOut, ":")) .
                      sw:end-element ("vd:firstDate") .
                    if inVsdSubs:VsdObjCurr:ExpiryOutDate <> ? and inVsdSubs:VsdObjCurr:ExpiryOutDate <> ":::" and inVsdSubs:VsdObjCurr:ExpiryOutDate <> ""
                    then do :
                      sw:start-element ("vd:secondDate") .
                        sw:write-data-element ("dt:year", entry(1, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":")) .
                        if entry(2, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":") <> ""
                        then sw:write-data-element ("dt:month", entry(2, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":")) .
                        if entry(3, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":") <> ""
                        then sw:write-data-element ("dt:day", entry(3, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":")) .
                        if entry(4, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":") <> ""
                        then sw:write-data-element ("dt:hour", entry(4, inVsdSubs:VsdObjCurr:ExpiryOutDate, ":")) .
                      sw:end-element ("vd:secondDate") .
                    end.
                    sw:end-element ("vd:dateOfProduction") .
                    sw:start-element ("vd:expiryDate") .
                      sw:start-element ("vd:firstDate") .
                        sw:write-data-element ("dt:year", entry(1, inVsdSubs:VsdObjCurr:ExpiryDate, ":")) .
                        if entry(2, inVsdSubs:VsdObjCurr:ExpiryDate, ":") <> ""
                        then sw:write-data-element ("dt:month", entry(2, inVsdSubs:VsdObjCurr:ExpiryDate, ":")) .
                        if entry(3, inVsdSubs:VsdObjCurr:ExpiryDate, ":") <> ""
                        then sw:write-data-element ("dt:day", entry(3, inVsdSubs:VsdObjCurr:ExpiryDate, ":")) .
                        if entry(4, inVsdSubs:VsdObjCurr:ExpiryDate, ":") <> ""
                        then sw:write-data-element ("dt:hour", entry(4, inVsdSubs:VsdObjCurr:ExpiryDate, ":")) .
                      sw:end-element ("vd:firstDate") .
                    if inVsdSubs:VsdObjCurr:ExpiryDate2 <> ? and inVsdSubs:VsdObjCurr:ExpiryDate2 <> ":::" and inVsdSubs:VsdObjCurr:ExpiryDate2 <> ""
                    then do :
                      sw:start-element ("vd:secondDate") .
                        sw:write-data-element ("dt:year", entry(1, inVsdSubs:VsdObjCurr:ExpiryDate2, ":")) .
                        if entry(2, inVsdSubs:VsdObjCurr:ExpiryDate2, ":") <> ""
                        then sw:write-data-element ("dt:month", entry(2, inVsdSubs:VsdObjCurr:ExpiryDate2, ":")) .
                        if entry(3, inVsdSubs:VsdObjCurr:ExpiryDate2, ":") <> ""
                        then sw:write-data-element ("dt:day", entry(3, inVsdSubs:VsdObjCurr:ExpiryDate2, ":")) .
                        if entry(4, inVsdSubs:VsdObjCurr:ExpiryDate2, ":") <> ""
                        then sw:write-data-element ("dt:hour", entry(4, inVsdSubs:VsdObjCurr:ExpiryDate2, ":")) .
                      sw:end-element ("vd:secondDate") .
                    end.
                    sw:end-element ("vd:expiryDate") .
                    do bi = 2 to num-entries(inVsdSubs:VsdObjCurr:NumPart, chr(4)) :
                      sw:write-data-element ("vd:batchID", entry(bi, inVsdSubs:VsdObjCurr:NumPart, chr(4))) .
                    end .
                    sw:write-data-element ("vd:perishable", inVsdSubs:VsdObjCurr:Perishable) .
                    sw:start-element ("vd:origin") .
                      sw:start-element ("vd:country") .
                        sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:OrigCountryGuid)) .
                      sw:end-element ("vd:country") .
                      sw:start-element ("vd:producer") .
                        if inVsdSubs:VsdObjCurr:ProducerGuid <> "" and inVsdSubs:VsdObjCurr:ProducerGuid <> ?
                        then do :
                          sw:start-element ("dt:enterprise") .
                            sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:ProducerGuid)) .
                          sw:end-element ("dt:enterprise") .
                        end.
                        else sw:write-empty-element ("dt:enterprise") .
                        if inVsdSubs:VsdObjCurr:ProducerRole <> ""
                        then  sw:write-data-element ("dt:role", inVsdSubs:VsdObjCurr:ProducerRole) .
                      sw:end-element ("vd:producer") .
                    sw:end-element ("vd:origin") .
                  sw:end-element ("vd:consignment") .
                if inVsdSubs:VsdObjCurr:BrokerGuid <> ""
                then do :
                  sw:start-element ("vd:broker") .
                    sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:BrokerGuid)) .
                  sw:end-element ("vd:broker") .
                end.
                  sw:start-element ("vd:transportInfo") .
                    sw:write-data-element ("vd:transportType", inVsdSubs:VsdObjCurr:Transport) .
                    sw:start-element ("vd:transportNumber") .
                      if inVsdSubs:VsdObjCurr:ContainerNum <> ""
                      then sw:write-data-element ("vd:containerNumber", inVsdSubs:VsdObjCurr:ContainerNum) .
                      case inVsdSubs:VsdObjCurr:Transport :
                        when "1" then sw:write-data-element ("vd:vehicleNumber", inVsdSubs:VsdObjCurr:CarNum) .
                        when "2" then sw:write-data-element ("vd:wagonNumber", inVsdSubs:VsdObjCurr:CarNum) .
                        when "3" then sw:write-data-element ("vd:flightNumber", inVsdSubs:VsdObjCurr:CarNum) .
                        when "4" or
                        when "5 "then sw:write-data-element ("vd:shipName", inVsdSubs:VsdObjCurr:CarNum) .
                      end case .
                      if inVsdSubs:VsdObjCurr:TrailerNum <> ""
                      then sw:write-data-element ("vd:trailerNumber", inVsdSubs:VsdObjCurr:TrailerNum) .
                    sw:end-element ("vd:transportNumber") .
                  sw:end-element ("vd:transportInfo") .
                  sw:write-data-element ("vd:transportStorageType", inVsdSubs:VsdObjCurr:TransportType) .
                  sw:start-element ("vd:accompanyingForms") .
                    do rd = 2 to num-entries(inVsdSubs:VsdObjCurr:TTNtype, chr(4)) :
                      if entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) = "1"
                      or entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) = "2"
                      or entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) = "3"
                      or entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) = "4"
                      or entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) = "5"
                      then do :
                        sw:start-element ("vd:waybill") .
                          if  entry(rd, inVsdSubs:VsdObjCurr:TTNissueSeries, chr(4)) <> ""
                          then sw:write-data-element ("vd:issueSeries", entry(rd, inVsdSubs:VsdObjCurr:TTNissueSeries, chr(4))) .
                          sw:write-data-element ("vd:issueNumber", entry(rd, inVsdSubs:VsdObjCurr:TTNissueNumber, chr(4))) .
                          sw:write-data-element ("vd:issueDate", entry(rd, inVsdSubs:VsdObjCurr:TTNissueDate, chr(4))) .
                          sw:write-data-element ("vd:type", entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4))) .
                        sw:end-element ("vd:waybill") .
                      end.
                    end.
                    sw:start-element ("vd:vetCertificate") .
                      sw:start-element ("vd:authentication") .
                        sw:start-element ("vd:purpose") .
                          sw:write-data-element ("bs:guid", LC(inVsdSubs:VsdObjCurr:PurposeGuid)) .
                        sw:end-element ("vd:purpose") .
                        if inVsdSubs:VsdObjCurr:CargoInspected <> ""
                        then sw:write-data-element ("vd:cargoInspected", inVsdSubs:VsdObjCurr:CargoInspected) .
                        sw:write-data-element ("vd:cargoExpertized", inVsdSubs:VsdObjCurr:CargoExpertized) .
                        if inVsdSubs:VsdObjCurr:LocationProsperity <> ""
                        then sw:write-data-element ("vd:locationProsperity", inVsdSubs:VsdObjCurr:LocationProsperity) .
                      sw:end-element ("vd:authentication") .
                    sw:end-element ("vd:vetCertificate") .
                    do rd = 2 to num-entries(inVsdSubs:VsdObjCurr:TTNtype, chr(4)) :
                      if  entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) <> "1"
                      and entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) <> "2"
                      and entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) <> "3"
                      and entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) <> "4"
                      and entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4)) <> "5"
                      then do :
                        sw:start-element ("vd:relatedDocument") .
                          if  entry(rd, inVsdSubs:VsdObjCurr:TTNissueSeries, chr(4)) <> ""
                          then sw:write-data-element ("vd:issueSeries", entry(rd, inVsdSubs:VsdObjCurr:TTNissueSeries, chr(4))) .
                          sw:write-data-element ("vd:issueNumber", entry(rd, inVsdSubs:VsdObjCurr:TTNissueNumber, chr(4))) .
                          sw:write-data-element ("vd:issueDate", entry(rd, inVsdSubs:VsdObjCurr:TTNissueDate, chr(4))) .
                          sw:write-data-element ("vd:type", entry(rd, inVsdSubs:VsdObjCurr:TTNtype, chr(4))) .
                          sw:write-data-element ("vd:relationshipType", entry(rd, inVsdSubs:VsdObjCurr:TTNrelationshipType, chr(4))) .
                        sw:end-element ("vd:relatedDocument") .
                      end.
                    end.
                  sw:end-element ("vd:accompanyingForms") .
                sw:end-element ("merc:returnedDelivery") .
              end.
              if inVsdSubs:VsdObjCurr:MsgErr = "MERC14561"
              or inVsdSubs:VsdObjCurr:MsgErr = "MERC14562"
              or inVsdSubs:VsdObjCurr:MsgErr = "MERC14563"
              or inVsdSubs:VsdObjCurr:MsgErr = "MERC14258"
              or inVsdSubs:VsdObjCurr:MsgErr = "MERC14537"
              then do :
                sw:start-element ("merc:discrepancyReport") .
                  sw:write-data-element ("vd:description", inVsdSubs:VsdObjCurr:MsgErr ) .
                  inVsdSubs:VsdObjCurr:Note = inVsdSubs:VsdObjCurr:MsgErr + " | Гашение с актом несоответсвия." .
                sw:end-element ("merc:discrepancyReport") .
              end.
              sw:end-element ("merc:processIncomingConsignmentRequest") .
            sw:end-element ("apl:data") .
          sw:end-element ("apl:application") .
        sw:end-element ("apldef:submitApplicationRequest") .
      sw:end-element ("se:Body") .
    sw:end-element ("se:Envelope") .
    sw:end-document () .
    delete object sw.
    delete object gdsMercsubsObj no-error .
    delete object gdsmercstrObj no-error .
    delete object unitMercStr no-error.
    delete object unitsMercObj no-error.
    if trim(proxy-addr) <> "" and proxy-addr <> ?
    then do :
      if proxy-ssl
      then do :
        cmd = substitute ("&1 -k --proxy-negotiate -x &7 -U : -u &4:&5 -d @&2 &6/platform/services/2.1/ApplicationManagementService >&3",
                        search ("exe/curl.exe"), SearchFile(v-file), v-resp-file, login, password, server_, proxy-addr).
      end.
      else do :
        cmd = substitute ("&1 -x &7 -U &8:&9 -u &4:&5 -d @&2 &6/platform/services/2.1/ApplicationManagementService >&3",
                        search ("exe/curl.exe"), SearchFile(v-file), v-resp-file, login, password, server_, proxy-addr, proxy-login, proxy-pswd).
      end.
    end.
    else do :
      cmd = substitute ("&1 -u &4:&5 -d @&2 &6/platform/services/2.1/ApplicationManagementService >&3",
                      search ("exe/curl.exe"), SearchFile(v-file), v-resp-file, login, password, server_).
    end.
    os-command silent value (cmd).
    ParseXML(input SearchFile(v-resp-file)) .
    p-applicationId = applicationId .
    p-Status_ = Status_ .
    p-Msg = Msg .
    pause 0.2 .
  end method.
  method public void receiveVetDoc
  (
   input inApplicationId as char,
   input inUUID as char,
   input p-qnty as decimal,
   input p-fact-qnty as decimal,
   input is-utilized as logical,
   output p-Status_ as char,
   output p-Msg  as char
  ) :
    define variable gdsMercsubsObj as class gdsmercsubs no-undo .
    define variable gdsMercsubObj as class gdsmercsub no-undo .
    define variable gdsMercstrObj as class gdsmercstr no-undo .
    define variable unitsMercObj as class unitsubs no-undo .
    define variable unitMercStr as class unitmercstr no-undo .
    define variable is-err as logical no-undo .
    define variable v-found-unit as logical no-undo .
    define variable v-found-cli as logical no-undo .
    define variable v-calc-qnty as decimal no-undo .
    define variable jj as integer no-undo .
    define variable v-resp-file as character no-undo .
    v-resp-file = "VetDocumentByUuidResponse_DB" + string(DbNum) + ".xml" .
    define buffer buf_ext-classif for ext-classif .
    define buffer buf_goods for ub.goods .
    define buffer buf_units-attr for ub.units-attr .
    define buffer bf_vsd for vsd .
    vsds = new vsdsubs() .
    vsdStorage = new vsdtostorage ().
    gdsMercsubsObj = new gdsmercsubs ().
    gdsMercsubObj = new gdsmercsub ().
    gdsMercstrObj = new gdsmercstr ().
    unitsMercObj = new unitsubs ().
    unitMercStr = new unitmercstr ().
    is-err = false .
    v-found-unit = false .
    receiveApplicationResult (v-resp-file, inApplicationId) .
    if Status_ = "COMPLETED"
    then
    do ii = 1 to vsds:GetItem (ii):
      vsds:VsdObjCurr:MsgErr = "" .
      if is-utilized then vsds:VsdObjCurr:Status_ = vsdStat:IsUtilized .
      gdsMercsubsObj = gdsMercstrObj:getgdsmercs(vsds:VsdObjCurr:GdsCode) .
      if valid-object(gdsMercsubsObj:GdsMercsubsCurr)
      and gdsMercsubsObj:GdsMercsubsCurr:GUID_ <> vsds:VsdObjCurr:GdsGuid
      and vsds:VsdObjCurr:GdsGuid <> ""
      and vsds:VsdObjCurr:Status_ <> vsdStat:IsUtilized
      then do :
        Msg = Msg + chr(10) + "GUID'ы товаров не совпадают." .
        os-copy value(search(v-resp-file)) value ("ERR_vetDoc_" + inUUID + ".xml" ) .
        is-err = true .
      end .
      if not valid-object(gdsMercsubsObj:GdsMercsubsCurr)
      and vsds:VsdObjCurr:GdsGuid <> ""
      and vsds:VsdObjCurr:Status_ <> vsdStat:IsUtilized
      then do :
        Msg = Msg + chr(10) + "В ВСД товар с GUID'ом. В TH товар не синхронизирован с ФГИС Меркурий (нет GUID'а)" .
        os-copy value(search(v-resp-file)) value ("ERR_vetDoc_" + inUUID + ".xml" ) .
        is-err = true .
      end .
      if issuerId <> vsds:VsdObjCurr:ObjBeGuid
      and vsds:VsdObjCurr:Status_ <> vsdStat:IsUtilized
      then do :
        Msg = Msg + chr(10) + "GUID'ы хоз. субъекта получателя не совпадают." .
        os-copy value(search(v-resp-file)) value ("ERR_vetDoc_" + inUUID + ".xml" ) .
        is-err = true .
      end.
      v-found-cli = no .
      for each buf_ext-classif no-lock
        where buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name = 'clients-esys':U
          and buf_ext-classif.db-num = 0
          and buf_ext-classif.key#_one = esysId
          and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + vsds:VsdObjCurr:ObjType + chr(3) + string (vsds:VsdObjCurr:ObjCode)
          :
        if entry(2, buf_ext-classif.charKey_Two, chr(6)) = vsds:VsdObjCurr:ObjEntGuid
        then do :
          v-found-cli = yes .
          leave.
        end.
      end.
      if v-found-cli = no
      and vsds:VsdObjCurr:Status_ <> vsdStat:IsUtilized
      then do :
        Msg = Msg + chr(10) + "GUID'ы предприятия получателя не совпадают." .
        os-copy value(search(v-resp-file)) value ("ERR_vetDoc_" + inUUID + ".xml" ) .
        is-err = true .
      end.
      v-found-cli = no .
      for each buf_ext-classif no-lock
        where buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name = 'clients-esys':U
          and buf_ext-classif.db-num = 0
          and buf_ext-classif.key#_one = esysId
          and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + vsds:VsdObjCurr:CliType + chr(3) + string (vsds:VsdObjCurr:CliCode)
          :
        if ( entry(1, buf_ext-classif.charKey_Two, chr(6)) = vsds:VsdObjCurr:CliBeGuid or vsds:VsdObjCurr:CliType = 'маг' )
        and entry(2, buf_ext-classif.charKey_Two, chr(6)) = vsds:VsdObjCurr:CliEntGuid
        then do :
          v-found-cli = yes .
          leave.
        end.
      end .
      if v-found-cli = no
      and vsds:VsdObjCurr:Status_ <> vsdStat:IsUtilized
      then do :
        Msg = Msg + chr(10) + "GUID'ы хоз. субъекта и/или предприятия отправителя не совпадают." .
        os-copy value(search(v-resp-file)) value ("ERR_vetDoc_" + inUUID + ".xml" ) .
        is-err = true .
      end.
      find first buf_goods no-lock where buf_goods.gds-code = vsds:VsdObjCurr:GdsCode .
      find first buf_units-attr no-lock where buf_units-attr.unit-name = buf_goods.unit-base
                                          and buf_units-attr.attr-code = "MercGuid"
                                          no-error .
      if available buf_units-attr
      and buf_units-attr.attr-value = vsds:VsdObjCurr:UnitGuid
      then do :
        v-found-unit = true .
        v-calc-qnty = p-qnty .
      end.
      else do :
        unitsMercObj = unitMercStr:getunitmercs(vsds:VsdObjCurr:GdsCode) .
        units_ :
        do jj = 1 to unitsMercObj:GetItem (jj):
          find first buf_units-attr no-lock where buf_units-attr.unit-name = unitsMercObj:UnitObjCurr:UnitName
                                              and buf_units-attr.attr-code = "MercGuid"
                                              no-error .
          if not available buf_units-attr then next units_ .
          if buf_units-attr.attr-value = vsds:VsdObjCurr:UnitGuid
          then do :
            v-found-unit = true .
            v-calc-qnty = p-qnty * unitsMercObj:UnitObjCurr:UnitCoef .
            leave units_ .
          end.
        end.
      end.
      if not v-found-unit
      then do :
        Msg = Msg + chr(10) + "Не найдено соответствие единицы измерения из ВСД с единицами измерения TH." .
        os-copy value(search(v-resp-file)) value ("ERR_vetDoc_" + inUUID + ".xml" ) .
        is-err = true .
      end.
      if v-calc-qnty > (vsds:VsdObjCurr:Qnty * 1.05)
      and vsds:VsdObjCurr:Status_ <> vsdStat:IsUtilized
      and v-found-unit = true
      then do :
        Msg = Msg + chr(10) + "Документарное количество в TH превосходит количество в ВСД более чем на 5%." .
        os-copy value(search(v-resp-file)) value ("ERR_vetDoc_" + inUUID + ".xml" ) .
        is-err = true .
      end.
      if v-calc-qnty < (vsds:VsdObjCurr:Qnty * 0.95)
      and vsds:VsdObjCurr:Status_ <> vsdStat:IsUtilized
      and v-found-unit = true
      then do :
        Msg = Msg + chr(10) + "Документарное количество в TH меньше количества в ВСД более чем на 5%." .
        os-copy value(search(v-resp-file)) value ("ERR_vetDoc_" + inUUID + ".xml" ) .
        is-err = true .
      end.
      vsdStorage:updateDB(vsds:VsdObjCurr) .
    end .
    if Status_ = "REJECTED"
    or is-err
    then do :
      find first bf_vsd no-lock where bf_vsd.UUID = inUUID and bf_vsd.ID = vsdId no-error.
      if available bf_vsd
      then do :
        vsds = vsdStorage:getVSDsubs (buffer bf_vsd) .
        do ii = 1 to vsds:GetItem(ii):
          Msg = left-trim(Msg, chr(10)) .
          vsds:VsdObjCurr:Status_ = vsdStat:IsErrCheck .
          vsds:VsdObjCurr:MsgErr = Msg .
          if is-utilized then vsds:VsdObjCurr:Status_ = vsdStat:IsUtilized .
          vsdStorage:updateDB(vsds:VsdObjCurr) .
        end.
      end.
    end .
    delete object vsds no-error.
    delete object vsdStorage no-error.
    delete object gdsMercsubsObj no-error.
    delete object gdsMercsubObj no-error.
    delete object gdsMercstrObj no-error.
    delete object unitMercStr no-error.
    delete object unitsMercObj no-error.
    p-Status_ = Status_ .
    p-Msg = Msg .
  end method .
  method public void receiveIncomingConsignmentResponse
  (
   input inApplicationId as char,
   input inUUID as char,
   output p-Status_ as char,
   output p-Msg  as char
  ) :
    define variable v-resp-file as character no-undo .
    v-resp-file = "IncomingConsignmentResponse_DB" + string(DbNum) + ".xml" .
    define buffer buf_vsd for ub.vsd .
    vsds = new vsdsubs() .
    vsdStorage = new vsdtostorage ().
    receiveApplicationResult (v-resp-file, inApplicationId) .
    if Status_ = "COMPLETED"
    then
    do ii = 1 to vsds:GetItem (ii):
      vsds:VsdObjCurr:MsgErr = "" .
      if vsds:VsdObjCurr:ID > 0
      then do :
        vsdStorage:updateDB(vsds:VsdObjCurr) .
      end.
      else do :
        find first buf_vsd no-lock where buf_vsd.UUID = inUUID and buf_vsd.ID = vsdId no-error .
        if available buf_vsd
        then do :
          vsds:VsdObjCurr:PartKey     = buf_vsd.part-key .
          vsds:VsdObjCurr:GdsCode     = buf_vsd.gds-code .
          vsds:VsdObjCurr:ObjType     = buf_vsd.obj-type .
          vsds:VsdObjCurr:ObjCode     = buf_vsd.obj-code .
          vsds:VsdObjCurr:CliType     = buf_vsd.cli-type .
          vsds:VsdObjCurr:CliCode     = buf_vsd.cli-code .
          vsds:VsdObjCurr:Status_     = vsdStat:IsSent .
        end.
        vsdStorage:insertDB(vsds:VsdObjCurr) .
      end.
    end .
    if Status_ = "REJECTED"
    then do :
      find first buf_vsd no-lock where buf_vsd.UUID = inUUID and buf_vsd.ID = vsdId no-error .
      if available buf_vsd
      then do :
        vsds = vsdStorage:getVSDsubs (buffer buf_vsd) .
        do ii = 1 to vsds:GetItem(ii):
          Msg = left-trim(Msg, chr(10)) .
          if Msg = "MERC14561"
          or Msg = "MERC14562"
          or Msg = "MERC14563"
          or Msg = "MERC14258"
          or Msg = "MERC14537"
          then
            vsds:VsdObjCurr:Status_ = vsdStat:IsNeedUtilized .
          else
            vsds:VsdObjCurr:Status_ = vsdStat:IsErrUtilized .
          vsds:VsdObjCurr:MsgErr = Msg .
          vsdStorage:updateDB(vsds:VsdObjCurr) .
        end.
      end.
    end .
    delete object vsds no-error.
    delete object vsdStorage no-error.
    p-Status_ = Status_ .
    p-Msg = Msg .
  end method .
  method private void receiveApplicationResult
  (
   input v-result-file as char,
   input inApplicationId as char
  ) :
    define variable cmd as character no-undo .
    define variable sw as handle no-undo .
    define variable v-file  as character no-undo .
    v-file = "receiveApplicationResult_DB" + string(DbNum) + ".xml" .
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("file", v-file).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("se:Envelope") .
    sw:insert-attribute ("xmlns:se", "http://schemas.xmlsoap.org/soap/envelope/") .
    sw:insert-attribute ("xmlns:ws", "http://api.vetrf.ru/schema/cdm/application/ws-definitions") .
      sw:start-element ("se:Body") .
        sw:start-element ("ws:receiveApplicationResultRequest") .
          sw:write-data-element ("ws:apiKey", apiKey) .
          sw:write-data-element ("ws:issuerId", issuerId) .
          sw:write-data-element ("ws:applicationId", inApplicationId) .
        sw:end-element ("ws:receiveApplicationResultRequest") .
      sw:end-element ("se:Body") .
    sw:end-element ("se:Envelope") .
    sw:end-document () .
    delete object sw.
    if trim(proxy-addr) <> "" and proxy-addr <> ?
    then do :
      if proxy-ssl
      then do :
        cmd = substitute ("&1 -k --proxy-negotiate -x &7 -U : -u &4:&5 -d @&2 &6/platform/services/2.1/ApplicationManagementService >&3",
                        search ("exe/curl.exe"), SearchFile(v-file), v-result-file, login, password, server_, proxy-addr).
      end.
      else do :
        cmd = substitute ("&1 -x &7 -U &8:&9 -u &4:&5 -d @&2 &6/platform/services/2.1/ApplicationManagementService >&3",
                        search ("exe/curl.exe"), SearchFile(v-file), v-result-file, login, password, server_, proxy-addr, proxy-login, proxy-pswd).
      end.
    end.
    else do :
      cmd = substitute ("&1 -u &4:&5 -d @&2 &6/platform/services/2.1/ApplicationManagementService >&3",
                      search ("exe/curl.exe"), SearchFile(v-file), v-result-file, login, password, server_).
    end.
    os-command silent value (cmd).
    ParseXML(input SearchFile(v-result-file)) .
  end method .
  method public void ParseXML
  (
    input p-inFileName as character
  ):
    define variable hHandler as handle no-undo.
    define variable hParser  as handle no-undo.
    define variable nameChildrenCurr as character no-undo.
    define variable iNum             as integer   no-undo.
    run ibs/th/bge/mercury/parseMercXML.p persistent set hHandler (input vsdID).
    create sax-reader hParser.
    hParser:handler = hHandler.
    hParser:set-input-source("FILE", p-inFileName).
    hParser:SUPPRESS-NAMESPACE-PROCESSING = true.
    hParser:VALIDATION-ENABLED = false.
    hParser:SCHEMA-LOCATION = "".
    hParser:NONAMESPACE-SCHEMA-LOCATION = "".
    iNum = 0.
    hParser:sax-parse ( ).
    if p-inFileName = SearchFile("ApplicationResponse_DB" + string(DbNum) + ".xml")
    then do :
      run getData in hHandler (output applicationId, output Status_, output Msg).
    end.
    if p-inFileName = SearchFile("VetDocumentByUuidResponse_DB" + string(DbNum) + ".xml")
    or p-inFileName = SearchFile("IncomingConsignmentResponse_DB" + string(DbNum) + ".xml")
    then do :
      run getVsds in hHandler (output applicationId, output Status_, output Msg, output vsds).
    end.
    delete object hParser.
    delete procedure hHandler.
  end method.
method public character objExists
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
method public character SearchFile
(input  ifile as character):
   return objExists(ifile,?).
end.
method public character SearchPFile
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
end class.
