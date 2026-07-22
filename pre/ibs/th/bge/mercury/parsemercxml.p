using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.clients.*.
block-level on error undo, throw.
define input parameter p-vsdId as int64 no-undo .
define variable v-appId as character no-undo .
define variable v-status as character no-undo .
define variable v-mess as character no-undo .
define variable v-issuerId as character no-undo .
define variable v-errcode as character no-undo .
define variable v-parsesub as character no-undo .
define variable v-parsesub2 as character no-undo .
define variable vsdStorage as class vsdtostorage no-undo .
define variable vsdsTHObj as class vsdsubs no-undo .
define variable temp-vsdsTHObj as class vsdsubs no-undo .
define variable vsdTHObj as class vsdsub no-undo .
define variable vsdStsType as class vsdstatustype no-undo .
define variable v-statusVSD as character no-undo .
define variable v-statusVSD2 as character no-undo .
define variable v-typeVSD as character no-undo .
define variable v-dateCr as character no-undo .
define variable v-year as character no-undo .
define variable v-month as character no-undo .
define variable v-day as character no-undo .
define variable v-hour as character no-undo .
define variable v-ignorSect as logical no-undo initial no .
define variable v-empty-answer as logical no-undo initial yes .
define buffer buf_vsd for ub.vsd .
procedure getData:
  define output parameter p-appId as character no-undo .
  define output parameter p-status as character no-undo .
  define output parameter p-mess as character no-undo .
  assign
    p-appId = v-appId
    p-status = v-status
    p-mess = v-mess
  .
end procedure.
procedure getVsds:
  define output parameter p-appId as character no-undo .
  define output parameter p-status as character no-undo .
  define output parameter p-mess as character no-undo .
  define output parameter p-Vsds as class vsdsubs no-undo .
  assign
    p-appId = v-appId
    p-status = v-status
    p-mess = v-mess
  .
  p-Vsds = vsdsTHObj .
  if v-errcode = "MERC14561"
  or v-errcode = "MERC14562"
  or v-errcode = "MERC14563"
  or v-errcode = "MERC14258"
  or v-errcode = "MERC14537"
  then p-mess = v-errcode .
end procedure.
DEFINE VARIABLE gcCurrentElement AS CHARACTER NO-UNDO.
procedure StartElement:
DEFINE INPUT PARAMETER namespaceURI AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER localName    AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER qname        AS CHARACTER NO-UNDO.
DEFINE INPUT PARAMETER hAttributes  AS HANDLE NO-UNDO.
  gcCurrentElement = qname .
  case qname :
    when "merc:stockEntry" then v-ignorSect = yes .
    when "message" then v-mess = "" .
    when "apl:error" then v-errcode = hAttributes:get-value-by-qname("code") no-error .
    when "applicationId" then v-appId = "" .
    when "status" then v-status = "" .
    when "issuerId" THEN v-issuerId = "" .
    when "vd:vetDocument" or
    when "merc:vetDocument"
    then do :
      if v-ignorSect then return .
      v-empty-answer = no .
      if not valid-object(vsdsTHObj)
      then vsdsTHObj = new vsdsubs ().
      if not valid-object(vsdStorage)
      then vsdStorage = new vsdtostorage ().
      if not valid-object(vsdStsType)
      then vsdStsType = new vsdstatustype ().
      v-parsesub = "vetDocument" .
    end.
    when "merc:getVetDocumentByUuidRequest" then v-empty-answer = no .
    when "errors" then v-empty-answer = no .
    when "apl:errors" then v-empty-answer = no .
    when "ws:receiveApplicationResultRequest" then v-empty-answer = no .
    when "receiveApplicationResultRequest" then v-empty-answer = no .
    when "ws:submitApplicationResponse" then v-empty-answer = no .
    when "bs:uuid"
    then do :
      case v-parsesub :
        otherwise do :
        end.
      end case.
    end.
    when "vd:productItem" then v-parsesub = "productItem" .
    when "vd:product" then v-parsesub = "product" .
    when "vd:subProduct" then v-parsesub = "subProduct" .
    when "vd:unit" then v-parsesub = "unit" .
    when "vd:country" then v-parsesub = "country" .
    when "dt:businessEntity" then v-parsesub = "businessEntity" .
    when "dt:enterprise" then v-parsesub = "enterprise" .
    when "vd:purpose" then v-parsesub = "purpose" .
    when "vd:broker" then v-parsesub = "broker" .
    when "dt:packingType" then v-parsesub = "packingType" .
    when "vd:laboratoryResearch" then v-parsesub = "laboratoryResearch" .
    when "vd:dateOfProduction" then v-parsesub2 = "dateOfProduction" .
    when "vd:expiryDate" then v-parsesub2 = "expiryDate" .
    when "vd:consignor" then v-parsesub2 = "consignor" .
    when "vd:consignee" then v-parsesub2 = "consignee" .
    when "vd:producer" then v-parsesub2 = "producer" .
    when "vd:referencedDocument" then v-parsesub2 = "referencedDocument" .
    when "vd:authentication" then v-parsesub2 = "authentication" .
    when "vd:origin" then v-parsesub2 = "origin" .
    when "vd:firstDate"
    then do :
      v-parsesub = "firstDate" .
      v-year = "" .
      v-month = "" .
      v-day = "" .
      v-hour = "" .
    end.
  end case.
end procedure.
PROCEDURE Characters:
  DEFINE INPUT PARAMETER ppText AS MEMPTR NO-UNDO.
  DEFINE INPUT PARAMETER piNumChars AS INTEGER NO-UNDO.
  define variable v-str as character no-undo .
  if v-ignorSect then return .
  v-str = GET-STRING(ppText,1) .
  if v-str begins chr(10) then return .
  if v-parsesub = "laboratoryResearch" then return .
  case gcCurrentElement :
    when "message" or
    when "apl:error"
    then do :
      v-mess = v-mess + chr(10) + v-str .
      v-mess = left-trim(v-mess, chr(10)) .
    end.
    when "applicationId" THEN v-appId = v-str .
    when "status" THEN v-status = v-str .
    when "issuerId" THEN v-issuerId = v-str .
    when "bs:uuid"
    then do :
      case v-parsesub :
        when "vetDocument"
        then do :
          find first buf_vsd no-lock where buf_vsd.UUID = v-str and buf_vsd.ID = p-vsdId no-error.
          if not available buf_vsd
          then do :
            vsdTHObj = new vsdsub ().
            vsdsTHObj:AddItem(vsdTHObj) .
            vsdsTHObj:VsdObjCurr:UUID = caps(v-str) .
            vsdsTHObj:VsdObjCurr:EconomicSub = v-issuerId .
            vsdsTHObj:VsdObjCurr:FactDatetime = now .
          end.
          else do :
            temp-vsdsTHObj = new vsdsubs ().
            temp-vsdsTHObj = vsdStorage:getVSDsubs(buffer buf_vsd) .
            vsdsTHObj:AddItem(temp-vsdsTHObj:VsdObjCurr) .
            vsdsTHObj:VsdObjCurr:EconomicSub = v-issuerId .
            vsdsTHObj:VsdObjCurr:TTNissueDate = "" .
            vsdsTHObj:VsdObjCurr:TTNissueNumber = "" .
            vsdsTHObj:VsdObjCurr:TTNissueSeries= "" .
            vsdsTHObj:VsdObjCurr:TTNrelationshipType = "" .
            vsdsTHObj:VsdObjCurr:TTNtype = "" .
            vsdsTHObj:VsdObjCurr:PackageGuid = "" .
            vsdsTHObj:VsdObjCurr:PackageLevel = "" .
            vsdsTHObj:VsdObjCurr:PackageQnty = "" .
            vsdsTHObj:VsdObjCurr:NumPart = "" .
          end .
        end.
      end case.
    end.
    when "vd:vetDType"
    then do :
      v-typeVSD = v-str .
      case v-typeVSD :
        when "INCOMING" then vsdsTHObj:VsdObjCurr:VSDType = 1 .
        when "OUTGOING" then vsdsTHObj:VsdObjCurr:VSDType = 2 .
        when "PRODUCTIVE" then vsdsTHObj:VsdObjCurr:VSDType = 3 .
        when "RETURNABLE" then vsdsTHObj:VsdObjCurr:VSDType = 4 .
        when "TRANSPORT" then vsdsTHObj:VsdObjCurr:VSDType = 5 .
      end case .
    end.
    when "vd:vetDStatus"
    then do :
      v-statusVSD = v-str .
    end.
    when "vd:status"
    then do :
      v-statusVSD2 = v-str .
    end.
    when "bs:guid"
    then do :
      case v-parsesub :
        when "businessEntity"
        then do :
          case v-parsesub2 :
            when "consignor" then vsdsTHObj:VsdObjCurr:CliBeGuid = v-str .
            when "consignee" then vsdsTHObj:VsdObjCurr:ObjBeGuid = v-str .
          end case.
        end.
        when "enterprise"
        then do :
          case v-parsesub2 :
            when "consignor" then vsdsTHObj:VsdObjCurr:CliEntGuid = v-str .
            when "consignee" then vsdsTHObj:VsdObjCurr:ObjEntGuid = v-str .
            when "producer" then vsdsTHObj:VsdObjCurr:ProducerGuid = v-str .
          end case.
        end.
        when "productItem"
        then do :
          if v-parsesub2 <> "origin"
          then
            vsdsTHObj:VsdObjCurr:GdsGuid = v-str .
        end.
        when "product"
        then do :
          vsdsTHObj:VsdObjCurr:ProductGuid = v-str .
        end.
        when "subProduct"
        then do :
          vsdsTHObj:VsdObjCurr:SubProductGuid = v-str .
        end.
        when "unit" then vsdsTHObj:VsdObjCurr:UnitGuid = v-str .
        when "country" then vsdsTHObj:VsdObjCurr:OrigCountryGuid = v-str .
        when "purpose" then vsdsTHObj:VsdObjCurr:PurposeGuid = v-str .
        when "broker" then vsdsTHObj:VsdObjCurr:BrokerGuid = v-str .
        when "packingType" then vsdsTHObj:VsdObjCurr:PackageGuid = vsdsTHObj:VsdObjCurr:PackageGuid + chr(4) + v-str .
      end case.
    end.
    when "dt:name"
    then do :
      case v-parsesub :
        when "productItem"
        then do :
          vsdsTHObj:VsdObjCurr:GdsName = v-str .
        end.
      end case.
    end.
    when "vd:issueDate"
    then do :
      v-dateCr = v-str .
      case v-parsesub2 :
        when "referencedDocument"
        then do :
          vsdsTHObj:VsdObjCurr:TTNissueDate = vsdsTHObj:VsdObjCurr:TTNissueDate + chr(4) + v-str .
        end.
        when "authentication" then do : end .
        otherwise do :
          vsdsTHObj:VsdObjCurr:DateCr = date(integer(substring(v-dateCr, 6,2)), integer(substring(v-dateCr, 9,2)), integer(substring(v-dateCr, 1,4))) .
        end .
      end case .
    end.
    when "vd:perishable" then vsdsTHObj:VsdObjCurr:Perishable = v-str .
    when "vd:vehicleNumber" or
    when "vd:wagonNumber" or
    when "vd:shipName" or
    when "vd:flightNumber"
    then vsdsTHObj:VsdObjCurr:CarNum = v-str.
    when "vd:containerNumber" then vsdsTHObj:VsdObjCurr:ContainerNum = v-str .
    when "vd:trailerNumber" then vsdsTHObj:VsdObjCurr:TrailerNum = v-str .
    when "vd:transportStorageType" then vsdsTHObj:VsdObjCurr:TransportType = v-str .
    when "vd:transportType" then vsdsTHObj:VsdObjCurr:Transport = v-str .
    when "vd:volume" then vsdsTHObj:VsdObjCurr:Qnty = decimal(v-str) .
    when "vd:batchId" then vsdsTHObj:VsdObjCurr:NumPart = vsdsTHObj:VsdObjCurr:NumPart + chr(4) + v-str .
    when "vd:productType" then vsdsTHObj:VsdObjCurr:TypeProd = v-str .
    when "dt:year" then v-year = v-str .
    when "dt:month" then v-month = v-str .
    when "dt:day" then v-day = v-str no-error.
    when "dt:hour" then v-hour = v-str no-error.
    when "dt:quantity" then vsdsTHObj:VsdObjCurr:PackageQnty = vsdsTHObj:VsdObjCurr:PackageQnty + chr(4) + v-str .
    when "dt:level" then vsdsTHObj:VsdObjCurr:PackageLevel = vsdsTHObj:VsdObjCurr:PackageLevel + chr(4) + v-str .
    when "dt:role"
    then do :
      case v-parsesub2 :
        when "producer" then vsdsTHObj:VsdObjCurr:ProducerRole = v-str .
        otherwise do :
        end .
      end case .
    end.
    when "vd:issueNumber"
    then do :
      case v-parsesub2 :
        when "referencedDocument"
        then do :
          vsdsTHObj:VsdObjCurr:TTNissueNumber = vsdsTHObj:VsdObjCurr:TTNissueNumber + chr(4) + v-str .
        end.
        otherwise do :
        end .
      end case .
    end.
    when "vd:issueSeries"
    then do :
      case v-parsesub2 :
        when "referencedDocument"
        then do :
          vsdsTHObj:VsdObjCurr:TTNissueSeries = vsdsTHObj:VsdObjCurr:TTNissueSeries + chr(4) + v-str .
        end.
        otherwise do :
        end .
      end case .
    end.
    when "vd:type"
    then do :
      case v-parsesub2 :
        when "referencedDocument"
        then do :
          vsdsTHObj:VsdObjCurr:TTNtype = vsdsTHObj:VsdObjCurr:TTNtype + chr(4) + v-str .
        end.
        otherwise do :
        end .
      end case .
    end.
    when "vd:relationshipType"
    then do :
      case v-parsesub2 :
        when "referencedDocument"
        then do :
          vsdsTHObj:VsdObjCurr:TTNrelationshipType = vsdsTHObj:VsdObjCurr:TTNrelationshipType + chr(4) + v-str .
        end.
        otherwise do :
        end .
      end case .
    end.
    when "vd:cargoInspected"
    then do :
      case v-parsesub2 :
        when "authentication" then vsdsTHObj:VsdObjCurr:CargoInspected = v-str .
        otherwise do :
        end .
      end case .
    end.
    when "vd:cargoExpertized"
    then do :
      case v-parsesub2 :
        when "authentication" then vsdsTHObj:VsdObjCurr:CargoExpertized = v-str .
        otherwise do :
        end .
      end case .
    end.
    when "vd:locationProsperity"
    then do :
      case v-parsesub2 :
        when "authentication" then vsdsTHObj:VsdObjCurr:LocationProsperity = v-str .
        otherwise do :
        end .
      end case .
    end.
  end case .
end procedure .
PROCEDURE EndElement:
  DEFINE INPUT PARAMETER pcNamespaceURI AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pcLocalName AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pcElementName AS CHARACTER NO-UNDO.
  case pcElementName :
    when "merc:stockEntry" then v-ignorSect = no .
    when "vd:firstDate"
    then do :
      if v-ignorSect then return .
      case v-parsesub2 :
        when "dateOfProduction" then vsdsTHObj:VsdObjCurr:DateOut = v-year + ":" + v-month + ":" + v-day + ":" + v-hour .
        when "expiryDate" then vsdsTHObj:VsdObjCurr:ExpiryDate = v-year + ":" + v-month + ":" + v-day + ":" + v-hour .
      end case.
    end.
    when "vd:secondDate"
    then do :
      if v-ignorSect then return .
      case v-parsesub2 :
        when "dateOfProduction" then vsdsTHObj:VsdObjCurr:ExpiryOutDate = v-year + ":" + v-month + ":" + v-day + ":" + v-hour .
        when "expiryDate" then vsdsTHObj:VsdObjCurr:ExpiryDate2 = v-year + ":" + v-month + ":" + v-day + ":" + v-hour .
      end case.
    end.
    when "application"
    then do :
    end.
    when "vd:productItem"
    then do :
    end.
    when "vd:vetDocument" or
    when "merc:vetDocument"
    then do :
      if v-ignorSect then return .
      if v-statusVSD2 = "CONFIRMED"
      then do :
        if v-statusVSD = "CONFIRMED" then vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsNeedUtilized .
        if v-statusVSD = "UTILIZED" then vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsUtilized .
      end.
      else
      if v-statusVSD2 = "UTILIZED"
      then do :
        if v-statusVSD = "UTILIZED" then vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsUtilized .
      end.
      else do :
        if v-statusVSD = "CONFIRMED" then vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
        if v-statusVSD = "UTILIZED" then vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrUtilized .
        vsdsTHObj:VsdObjCurr:MsgErr = v-mess .
      end.
      v-parsesub = "" .
      delete object vsdStorage no-error .
      delete object vsdStsType no-error .
    end.
    when "vd:productItem" then v-parsesub = "" .
    when "vd:product" then v-parsesub = "" .
    when "vd:subProduct" then v-parsesub = "" .
    when "vd:unit" then v-parsesub = "" .
    when "vd:country" then v-parsesub = "" .
    when "dt:businessEntity" then v-parsesub = "" .
    when "dt:enterprise" then v-parsesub = "" .
    when "vd:purpose" then v-parsesub = "" .
    when "vd:broker" then v-parsesub = "" .
    when "dt:packingType" then v-parsesub = "" .
    when "vd:laboratoryResearch" then v-parsesub = "" .
    when "vd:dateOfProduction" then v-parsesub2 = "" .
    when "vd:expiryDate" then v-parsesub2 = "" .
    when "vd:consignor" then v-parsesub2 = "" .
    when "vd:consignee" then v-parsesub2 = "" .
    when "vd:producer" then v-parsesub2 = "" .
    when "vd:referencedDocument" then v-parsesub2 = "" .
    when "vd:authentication" then v-parsesub2 = "" .
    when "vd:origin" then v-parsesub2 = "" .
    when "vd:referencedDocument"
    then do :
      v-parsesub2 = "" .
      if valid-object(vsdsTHObj)
      and valid-object(vsdsTHObj:VsdObjCurr)
      then do :
        if num-entries(vsdsTHObj:VsdObjCurr:TTNissueSeries, chr(4)) < num-entries(vsdsTHObj:VsdObjCurr:TTNtype, chr(4))
        then do :
          vsdsTHObj:VsdObjCurr:TTNissueSeries = vsdsTHObj:VsdObjCurr:TTNissueSeries + chr(4) .
        end.
      end.
    end.
    when "vd:authentication" then v-parsesub2 = "" .
  end case.
end procedure .
procedure EndDocument:
  if v-empty-answer
  then do :
    v-status = "REJECTED" .
    v-mess = "Пустой ответ от Ветис.API..." .
  end.
end procedure .
