define temp-table tt-pack no-undo
          field orgid as char
          field docid as char
          field packid as char
          field stamp as datetime
          index pi packid   stamp   orgid  docid 
          .

{&CommentStartNoClass}
method public logical CheckLoad
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function CheckLoad returns logical 
{utl\comment.i} */
(iDocument as component-handle,
 output ohost-code as integer ,
 output oObj-type  as character  ,
 output oObj-code  as integer ):
   define variable vFlag as logical no-undo.
   
   define variable vDocumentChild as component-handle no-undo.
   define variable vContent as component-handle no-undo.
   define variable vConsignees as component-handle no-undo.
   define variable vfilename as character no-undo.
   oObj-type  = ?.
   oObj-code  = ?.
   ohost-code = ?.
   
   
   define buffer ext-classif   for ext-classif. 
   define buffer clients       for clients.
   define buffer buf_clients   for clients.
   define buffer clients-attr  for clients-attr.
   if   iDocument:type eq "UniversalTransferDocument"
     or iDocument:type eq "UniversalTransferDocumentRevision"
   then main-block :
   do on error undo main-block, return error:
      getdesc(iDocument).
      vfilename = iDocument:filename.
     /* if not iDocument:filename  begins "ON_NSCHFDOPPRMARK_"
      then do:
         PutMes(substitute('По &1 файл &2 не начинается с "ON_NSCHFDOPPRMARK_".' ,iDocument:DocumentNumber, iDocument:filename) ).
         return no.
      end. */
      if iDocument:Direction eq "Inbound"
      then do:
         
         define variable vOrganizationGuid as character no-undo.
         define variable vDocumentid as character no-undo.
         vOrganizationGuid = iDocument:OrganizationGuid.
         vDocumentid     = iDocument:DocumentId.
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error .
         if available utd
         then do:
            assign
               Oobj-type = utd.obj-type
               Oobj-code = utd.obj-code
               ohost-code = utd.host-code.
            .
         end.
         vDocumentChild = iDocument:GetDynamicContent("Seller") no-error.
         getdesc(vDocumentChild).
         if    (Oobj-code  ne 0 and Oobj-code  ne ?
            and ohost-code ne 0 and ohost-code ne ?)
         then vFlag = no.
         if    (Oobj-code  ne 0 and Oobj-code  ne ?
            and (ohost-code eq 0 and ohost-code eq ?))
         then do:
             find first clients  where clients.obj-type   = Oobj-type
                                   and clients.obj-code   = Oobj-code
             no-lock no-error .
             if available clients
             then
                ohost-code =  clients.host-code.
             vFlag = no.
         end.
         else if vDocumentChild ne ?
         then do:
            if iDocument:version  eq "utd820_05_01_01"
            then do:
               vContent = vDocumentChild:UniversalTransferDocument no-error.
               
            end.
            else
               vContent = vDocumentChild:UniversalTransferDocumentWithHyphens no-error. /* табличная часть счета фактуры */
            release object vDocumentChild.
            if vContent ne ?
            then do:
               getdesc(vContent).
              /* getdesc(vContent:Table).
               getdesc(vContent:TransferInfo).
               getdesc(vContent:FactorInfo).
               getdesc(vContent:MainAssignMonetaryClaim).
               getdesc(vContent:Sellers).
               getdesc(vContent:Sellers:Seller).
               getdesc(vContent:Sellers:Seller:getitem(0)).
               define variable org as component-handle no-undo.
               org = vContent:Sellers:Seller:getitem(0).
               getdesc(org:OrganizationDetails).
               getdesc(org:OrganizationReference).
               
               getdesc(vContent:Buyers).
               getdesc(vContent:Buyers:Buyer).
               getdesc(vContent:Buyers:Buyer:getitem(0)).
               org = vContent:Buyers:Buyer:getitem(0).
               getdesc(org:OrganizationDetails).
               getdesc(org:OrganizationReference).
               
               
               getdesc(vContent:Shippers).
               getdesc(vContent:Shippers:Shipper).
               getdesc(vContent:Shippers:Shipper:getitem(0)).
               getdesc(vContent:Shippers:Shipper:getitem(0):items).
               
               getdesc(vContent:Consignees).
               getdesc(vContent:Consignees:Consignee).
               getdesc(vContent:Consignees:Consignee:getitem(0)).
               org = vContent:Consignees:Consignee:getitem(0).
               getdesc(org:OrganizationDetails).
               getdesc(org:OrganizationReference).
               getdesc(vContent:Signers).
               getdesc(vContent:PaymentDocuments).
               getdesc(vContent:SellerInfoCircumPublicProc).
               getdesc(vContent:DocumentShipments).
               getdesc(vContent:DocumentShipments:DocumentShipment).
               
               getdesc(vContent:AdditionalInfoId).
               getdesc(vContent:AdditionalInfoId:AdditionalInfo).
               define variable vii as integer no-undo.
               define variable vunits as component-handle no-undo.
               vunits = vContent:AdditionalInfoId:AdditionalInfo.
               do vii = 1 to vunits:count:
                  getdesc(vunits:getitem(vii - 1)).
               end.
               */
                  
               define variable vFnsParticipantId as character no-undo.
               define variable vinn as character no-undo.
               define variable vkpp as character no-undo.
               define variable vorgname as character no-undo.
               define variable vAddrOrg as character no-undo.
               define variable vAdditionalInfo as character no-undo.
               
               
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                 /* getdesc(vContent:Shippers).
                  getdesc(vContent:Shippers:Shipper).
                  getdesc(vContent:Shippers:Shipper:OrganizationInfo).*/
                  getdesc(vContent:Sellers).
                  getdesc(vContent:Sellers:Seller).
                  getdesc(vContent:Sellers:Seller:GetItem(0)).
                  getdesc(vContent:Sellers:Seller:GetItem(0):OrganizationDetails).
                  
                  getOrganizationInfo(vContent:Sellers:Seller:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  /*vFnsParticipantId =  vContent:Sellers:Seller:GetItem(0):OrganizationDetails:FnsParticipantId no-error.
                  vKpp              =  vContent:Sellers:Seller:GetItem(0):OrganizationDetails:kpp no-error.*/
               end.
               else do:
                  vFnsParticipantId =  vContent:SenderFnsParticipantId.
               end.
               find first ext-classif where ext-classif.classif-name  eq {&extclass_code_id_diadok_client}
                                        and ext-classif.charkey_three eq vFnsParticipantId
               no-lock no-error.
               if available ext-classif
               then do:
                  find first clients 
                    where clients.obj-type   = ext-classif.CharKey_One
                      and clients.obj-code   = ext-classif.Key#_One
                      and not can-find(first ub.sysconf where ub.sysconf.host-code = clients.obj-code)
                  no-lock no-error .
                  if not available clients
                  then do:
                     PutMes(substitute("По &1 отправитель &2 наша фирма." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                     return no.
                  end.
               end.
               else do:
                  PutMes(substitute("По &1 не найден отправитель  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                  return no.
                  
               end.
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  getdesc(vContent:Buyers).
                  getdesc(vContent:Buyers:Buyer).
                  getdesc(vContent:Buyers:Buyer:GetItem(0)).
                  getOrganizationInfo(vContent:Buyers:Buyer:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo,output vAddrOrg).
                  
               end.   
               else do:
                  vConsignees = vContent:Consignees.
                  getdesc(vConsignees).
                  getdesc(vConsignees:Consignee).
                  if vConsignees:Consignee:count > 0
                  then do:
                     
                     getdesc(vConsignees:Consignee:GetItem(0)).
                     
                     getOrganizationInfo(vConsignees:Consignee:GetItem(0),output vinn,output vkpp,vFnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  end.
                  release object vConsignees.
                  vFnsParticipantId = vContent:RecipientFnsParticipantId.
               end.
               release object vContent.
               define variable otext as character no-undo.
               vFlag = getObgFns 
                          (input iDocument:DocumentNumber ,
                           input vFnsParticipantId ,
                           input vkpp,
                           output ohost-code,
                           output oobj-type,
                           output oobj-code,
                           output otext ).
               if otext ne "" and otext ne ?
               then 
                  PutMes( otext).
               if vFlag  eq no
               then 
                  return vFlag .
               
            end.
            else do:
               PutMes("Error Ошибка получения данных из Диадок UniversalTransferDocument" + if iDocument:version  eq "utd820_05_01_01" then "" else "WithHyphens").
               return no.
            end.
         end.
         else do:
            PutErr(substitute ("Error Ошибка получения данных из Диадок Seller по документу с типом &1",iDocument:type)).
            return no.
         end.
      end.
      else
         return yes.
      if ohost-code eq ? or ohost-code eq 0
      then do: 
         PutMes(substitute("По &1 не удалось определить фирму по получателю  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
         return no.
      end.
        
   end.
   else do:
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vpack as character no-undo init ?.
      define variable vcli-type as character no-undo.
      define variable vcli-code as integer no-undo.
      define variable vfns as character no-undo.
      define variable vchar as character no-undo.
      vDocumentChild = iDocument:GetDynamicContent("Seller")no-error.
      if vDocumentChild eq ?
      then do:
         PutErr(substitute ("Error Ошибка получения данных из Диадок Seller по документу с типом &1",iDocument:type)).
         return no.
      end.
      vContent = vDocumentChild:UniversalCorrectionDocument no-error.
            
      if vContent ne ?
      then do:
                    /* mSellerCol = mSellers:Seller. */
         getOrganizationInfo(vContent:Seller,output vchar,output vchar,vFns, output vchar,  output vchar, output vchar).
            
         find first ext-classif where ext-classif.classif-name  eq {&extclass_code_id_diadok_client}
                                  and ext-classif.charkey_three eq vFns
         no-lock no-error.
         if available ext-classif
         then do:
            assign 
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
            vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalInvoiceNumber,date(iDocument:OriginalInvoiceDate)).
            
            GetprevUTDForPac(vpack,iDocument:Timestamp,output vdb-num,output vdoc-id ).
            release object vContent.
      
         end.
         else do:
                  PutMes(substitute("По &1 не найден отправитель  &2." ,iDocument:DocumentNumber, vFnsParticipantId) ).
                  return no.
                  
               end.
      end.
      else do:
         PutErr("Error Ошибка получения данных из Диадок Seller").
         return no.
      end.
      
      release object vDocumentChild.
      
      define buffer     utd for utd.
      find first utd where utd.db-num eq vdb-num
                       and utd.doc-id eq vdoc-id
      no-lock no-error.
      if available utd
      then do:
         assign
            oobj-type  = utd.obj-type
            oobj-code  = utd.obj-code
            ohost-code = utd.host-code
            vfilename  = getattrutd (utd.db-num,utd.doc-id,"FileName")
         .
      end.
      else do:
         PutMes(substitute("Не найден оригенальный документ по пакету &1.",vpack)).
         return no.
      end.
            
   end.
   if /* not vFlag */ yes
   then do:
      define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(oobj-type, oobj-code).
      
      if     not EDOParSec:IsEdo
         and vfilename begins "ON_NSCHFDOPPRMARK_"
      then do:
         PutMes(substitute("На объекте &1&2 не установлен параметр работы с ЭДО для маркированного товара.",oobj-type,oobj-code)).
         vFlag = no.
      end.
      else if     not EDOParSec:IsEdoNotmark
              and not vfilename begins "ON_NSCHFDOPPRMARK_"
      then do:
         PutMes(substitute("На объекте &1&2 не установлен параметр работы с ЭДО для не маркированного товара.",oobj-type,oobj-code)).
         vFlag = no.
      end.
      else
         vFlag = yes.
      
     
   end.
   
   return vFlag.
end.

{&CommentStartNoClass}
method public void UpdateUTDInformOne (iDocument as component-handle):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure  UpdateUTDInformOne : 
   define input  parameter iDocument as component-handle no-undo.
{utl\comment.i} */
   define variable vOrganizationGuid as character no-undo.
   define variable vDocumentId as character no-undo.
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
   define variable viii as integer no-undo.
   define variable vtext as longchar no-undo.
   
   define buffer utd           for ub.utd.
   define buffer old_utd           for ub.utd.
   
   define buffer utd-lines      for ub.utd-lines.
   define buffer marking       for ub.marking.
   define buffer marking-lines for ub.marking-lines.
   define buffer utd-marking-lines for ub.utd-marking-lines.
   define buffer buf_utd-marking-lines for ub.utd-marking-lines.
   
   
   
   define variable vDocumentChild               as component-handle no-undo.
   define variable vContent                     as component-handle no-undo.
   define variable vValues                      as component-handle no-undo.
   define variable vSellers                     as component-handle no-undo.
   define variable vConsignees                  as component-handle no-undo.
   define variable vInvoiceTable                as component-handle no-undo.
   define variable vItems                       as component-handle no-undo. 
   define variable vExtendedInvoiceItem         as component-handle no-undo.
   define variable vItemIdentificationNumber    as component-handle no-undo.
   define variable vTransferBaseCol             as component-handle no-undo.
   define variable vTransferBase                as component-handle no-undo.
   define variable vorgname as character no-undo.
   define variable vAddrOrg as character no-undo.
   define variable vAdditionalInfo as character no-undo.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
                  
                  
   define variable vunits  as component-handle no-undo.
   define variable vunit   as component-handle no-undo.
   define variable VValue  as character        no-undo.
   define variable vsite   as character        no-undo.
   define variable vNewUtd as logical          no-undo.
   if iDocument eq ?
   then
     return.
   vOrganizationGuid = iDocument:OrganizationGuid.
   vDocumentid     = iDocument:DocumentId.
   find first utd where utd.DocumentExt     = vDocumentid
                    and utd.OrganizationExt = vOrganizationGuid
   no-lock no-error .
      
   find first tt-recid where tt-recid.orgid eq vOrganizationGuid
                         and tt-recid.docid eq vDocumentid
   
   no-lock no-error.
   
   if not available tt-recid
   then do trans:   
      if iDocument  ne ?
         and (
                  iDocument:type eq "UniversalTransferDocument"
               or iDocument:type eq "UniversalTransferDocumentRevision"
               or iDocument:type eq "UniversalCorrectionDocument"
              )
      then do:
         PutMes(substitute("Загрузка документа  &1 от &2." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
         define variable vhost-code as integer   no-undo.
         define variable vobj-type  as character no-undo.
         define variable vobj-code  as integer   no-undo.
         if not CheckLoad(iDocument,output vhost-code,output vobj-type,output  vobj-code )
         then do:
            PutMes(substitute("Документ &1 от &2 пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
            create tt-recid.
            assign
               tt-recid.orgid = vOrganizationGuid
               tt-recid.docid = vDocumentid
            . 
            return. 
         end.
      
         
/*         run gbl/inidebug.p.*/
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error /* no-wait */ .
         if available utd 
         then do:
            if     utd.sts-edi > ObjSrv:Env:Utd:Sts:edi:StatFinesh
               and iDocument:RevocationStatus ne "RequestsMyRevocation"
            then do:
               create tt-recid.
               assign
                  tt-recid.orgid = vOrganizationGuid.
                  tt-recid.docid = vDocumentid
               .
               PutMes(substitute("Документ &1 от &2 в конечном статусе. Документ пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
/*               return false.*/
            end.
      /*         if vDocumentid ne "1ee3b874-3819-4eca-8f50-47232a192c36057cd390-615f-4942-b8b9-7272ae719422" then next.*/
            find current utd exclusive-lock no-error  no-wait  .
            
            if  not available  utd
            
            then do:
               PutMes(substitute("Документ &1 от &2 заблокирован и будет пропущен." ,iDocument:DocumentNumber,iDocument:DocumentDate )).
               return.
            end.
         end.
         subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
         MySeqUtd = ?.
         if     not available  utd
            
         then do:
            create utd.
            assign
               utd.DocumentExt      = vDocumentid
               utd.OrganizationExt  = vOrganizationGuid
/*               utd.LoadDate         = today*/
               vNewUtd              = yes
               
            .
            validate utd. /* необходимо для заполнения db-num  и doc-id */
         end.
         
         assign 
            utd.host-code = vhost-code when vhost-code ne ? and vhost-code ne 0
            utd.obj-code  = vobj-code  when vobj-code  ne ? and vobj-code  ne 0
            utd.obj-type  = vobj-type  when vobj-type  ne ? and vobj-type  ne ""
         .
            
       /*  if iDocument:DocumentNumber eq "21_4"
         then
            message "222ddd"
            view-as alert-box. */
         
         
         
         
        /* if    utd.ReceiptStatus    ne iDocument:RecipientReceiptMetadata:ReceiptStatus
            or utd.RevocationStatus ne iDocument:RevocationStatus
            or utd.RecipientResponseStatus          ne iDocument:RecipientResponseStatus
         then
            utd.sts-edi = ?. */
         setattrutd (utd.db-num,utd.doc-id,"FileName",iDocument:FileName).
         
         utd.RevocationStatus = iDocument:RevocationStatus.
         utd.RecipientResponseStatus          = iDocument:RecipientResponseStatus.
         utd.TypeId           = iDocument:type.
         utd.CounteragentId   = iDocument:Counteragent:guid.
         utd.CustomDocumentId = iDocument:CustomDocumentId.
     /*    utd.obj-type         = "".
         utd.obj-code         = 0.
         utd.host-code        = 0.
         utd.contract-code    = 0.
         utd.cli-type         = "".
         utd.cli-code         = 0.
       */  
         
         utd.sts-edi = ?.
         utd.DocumentNumber = iDocument:DocumentNumber.
         utd.DocumentDate   = date(iDocument:DocumentDate).
         utd.Timestamp      = datetime(iDocument:Timestamp) .
         utd.ReceiptStatus  = iDocument:RecipientReceiptMetadata:ReceiptStatus. 
         utd.Direction      = iDocument:Direction.
         utd.ModifyDate = today.
/*         utd.PackageId = iDocument:PackageId.*/
         utd.flagRI     =    utd.ReceiptStatus eq "GeneralReceiptStatusNotAcceptable" or utd.ReceiptStatus eq "Finished". 
         utd.EDocType = if   iDocument:type eq "UniversalTransferDocument"
                          or iDocument:type eq "UniversalTransferDocumentRevision"
                        then objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                        else objSrv:Env:Utd:EDocType:UCD:KeyIntDB.
         
         
         getdesc(iDocument).
         getdesc(iDocument:Counteragent).   
         getdesc(iDocument:RecipientReceiptMetadata).
         getdesc(iDocument:ConfirmationMetadata).
         utd.AmendmentRequested = logical(iDocument:AmendmentRequested). /*Булево, чтение - признак, был ли запрос на уточнение*/
         if iDocument:type ne "UniversalTransferDocumentRevision"
         then do:
                utd.Revised = logical(iDocument:Revised). /*Булево, чтение - признак, было ли исправление данного документа*/
                utd.Corrected = logical(iDocument:Corrected).
         end.
      /*   getdesc(iDocument:RecipientResponseStatus).*/
   
         /*mDocument:SendReceiptsAsync().
            */
            /*mDocument:MarkAsRead().*/
                     /*mDocumentchaldList = mDocument:SubordinateDocumentIds.
            vii = mDocumentchildList:Count.*/
         vDocumentChild = iDocument:GetDynamicContent("Seller").
         getdesc(vDocumentChild).
         if   iDocument:type eq "UniversalTransferDocument"
           or iDocument:type eq "UniversalTransferDocumentRevision"
         then do:
            utd.Total = iDocument:total.
            utd.Vat = iDocument:Vat. 
         end.
         else do:
            utd.Total = decimal (iDocument:TotalInc) - decimal (iDocument:TotalDec).
            utd.Vat = decimal (iDocument:VatInc) - decimal (iDocument:VatDec).  
               
         end.
   /*            Создание Reflector'а*/
         find first utd-lines where utd-lines.db-num     = utd.db-num
                                and utd-lines.doc-id     = utd.doc-id
                                no-lock no-error.
         if     (   vNewUtd 
                 or utd.Direction ne "Inbound"
                 or not available utd-lines)
            and vDocumentChild ne ?
         then do:
            if utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
            then do:
                
               if iDocument:version  eq "utd820_05_01_01"
               then do:
                  vContent = vDocumentChild:UniversalTransferDocument no-error.
                  
               end.
               else
                  vContent = vDocumentChild:UniversalTransferDocumentWithHyphens no-error. /* табличная часть счета фактуры */
               if vContent ne ?
               then do:
                  getdesc(vContent).
                  /* дополнительная информация по договору 
                  getdesc(vContent:AdditionalInfoId).
                  getdesc(vContent:AdditionalInfoId:AdditionalInfo).
                  getdesc(vContent:AdditionalInfoId:AdditionalInfo:getitem(0)). */
                  define variable vInfoCount as integer no-undo.
                  define variable vInfos as component-handle no-undo.
                  define variable vInfo as component-handle no-undo.
               
                  vInfos = vContent:AdditionalInfoId:AdditionalInfo.
                  do vInfoCount = 1 to vInfos:count:
                     vInfo = vInfos:getitem(vInfoCount - 1).
                     getdesc(vInfo).
                     setattrutd (utd.db-num,utd.doc-id,vInfo:id,vInfo:value).
                     
                  end.
               
                  getdesc(vContent:TransferInfo).
                  getdesc(vContent:TransferInfo:TransferBases).
                  vTransferBasecol = vContent:TransferInfo:TransferBases:TransferBase.
                  getdesc(vTransferBasecol).
                  do vi = 1 to min(vTransferBasecol:count,1):
                     vTransferBase = vTransferBasecol:getitem(vi - 1).
                     getdesc(vTransferBase).
                     utd.BaseDocumentNumber = vTransferBase:BaseDocumentNumber.
                     utd.BaseDocumentName   = vTransferBase:BaseDocumentName.
                     utd.BaseDocumentDate   = date(vTransferBase:BaseDocumentDate).
                     release object vTransferBase.
                  end.
                  release object vTransferBasecol.
                  vSellers = vContent:Sellers.
                  getdesc(vSellers).
                  
                  getdesc(vSellers:Seller:GetItem(0)).
                  if vSellers:Seller:count > 0
                  then
                     getOrganizationInfo(vSellers:Seller:GetItem(0),output utd.cli-inn,output utd.cli-kpp,utd.cli-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  release object vSellers.
                  if iDocument:version  ne "utd820_05_01_01"
                  then
                     utd.cli-FnsParticipantId = vContent:SenderFnsParticipantId.
                  utd.cli-info = vorgname + " " + vAddrOrg.
                  if iDocument:version  eq "utd820_05_01_01"
                  then do:
                     getOrganizationInfo(vContent:Buyers:Buyer:GetItem(0),output utd.obj-inn,output utd.obj-kpp,utd.obj-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  end.
                  else do:
                     vConsignees = vContent:Consignees.
                     getdesc(vConsignees).
                       /* mBuyerCol = mBuyers:Buyer. */
            /*         getdesc(vBuyers:Buyer:getitem(0)).*/
                     if vConsignees:Consignee:count > 0
                     then do:
                        getOrganizationInfo(vConsignees:Consignee:GetItem(0),output utd.obj-inn,output utd.obj-kpp,utd.obj-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                        setattrutd (utd.db-num,utd.doc-id,"Consignee_ИнфДляУчаст",vAdditionalInfo).
                     end.
                     utd.obj-FnsParticipantId = vContent:RecipientFnsParticipantId.
                     release object vConsignees.
                  end.
                  utd.obj-info = vorgname + " " + vAddrOrg + " ИНН: " + utd.obj-inn + " КПП: " + utd.obj-kpp.
                  
                  
                  vInvoiceTable = vContent:Table.
                  getdesc(vInvoiceTable).
                  vItems = vInvoiceTable:Item.
                  release object vInvoiceTable.
                  do vi = 1 to vItems:Count: /* Документы потомки */
                     vExtendedInvoiceItem= vItems:GetItem(vi - 1).
                       /* if VIII = 1 then*/ 
                     getdesc(vExtendedInvoiceItem).
                     find first utd-lines where utd-lines.db-num     = utd.db-num
                                            and utd-lines.doc-id     = utd.doc-id
                                            and utd-lines.LineNum    = vi 
                     exclusive-lock no-error.
                     if not available  utd-lines
                     then do:
                        create utd-lines.
                        assign
                           utd-lines.db-num   = utd.db-num
                           utd-lines.doc-id   = utd.doc-id
                           utd-lines.Linenum  = vi
                           utd-lines.gds-code = ?
                        .
                        
                     end.
                     utd-lines.ProductCode = vExtendedInvoiceItem:Product.
                     utd-lines.UnitCode    = vExtendedInvoiceItem:UnitnAME.
                     setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vExtendedInvoiceItem:Quantity)).
                     setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vExtendedInvoiceItem:unit)).
                     
                     utd-lines.Price       = vExtendedInvoiceItem:Price.
                     utd-lines.TotalWithVatExcluded   = vExtendedInvoiceItem:SubtotalWithVatExcluded.
         /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
                     utd-lines.TaxRate   =   if  vExtendedInvoiceItem:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate,"/"),"%")).
                     utd-lines.Vat       = vExtendedInvoiceItem:Vat.
                     utd-lines.Total     = vExtendedInvoiceItem:Subtotal.
                     utd-lines.Article   = vExtendedInvoiceItem:ItemVendorCode. /* ??? */
            
                       
                     getdesc(vExtendedInvoiceItem:CustomsDeclarations).
                     getdesc(vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration).
                     if vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:CustomsDeclarations:CustomsDeclaration:GETITEM(0)).
                     getdesc(vExtendedInvoiceItem:AdditionalInfos).
                     getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo).
                     if vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:GETITEM(0)).
                     getdesc(vExtendedInvoiceItem:ItemTracingInfos).
                     getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo ).
                     if vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo:COUNT >= 1
                     then
                        getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo:GETITEM(0) ).
                     getdesc(vExtendedInvoiceItem:ItemIdentificationNumbers).
                     getdesc(vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber).
                     do vii = 1 to vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber:COUNT:
                        
                        vItemIdentificationNumber = vExtendedInvoiceItem:ItemIdentificationNumbers:ItemIdentificationNumber:GETITEM(vii - 1).
                        getdesc(vItemIdentificationNumber).
                        getdesc(vItemIdentificationNumber:Unit).
                        if vItemIdentificationNumber:TransPackageId ne ? and vItemIdentificationNumber:TransPackageId ne ""
                        then do:
                           VValue = repTegforDm(vItemIdentificationNumber:TransPackageId).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
/*  ????                         marking.unit-ext = utd-lines.UnitCode .*/
                        end. 
                        vunit = vItemIdentificationNumber:Unit.
                        do viii = 1 to vunit:count:
                           vValue = vunit:GETITEM(viii - 1).
                           VValue = repTegforDm(VValue).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                               
                           
                        end.
                        release object  vunit.
                        getdesc(vItemIdentificationNumber:PackageId).
                        vunit = vItemIdentificationNumber:PackageId.
                                        
                        do viii = 1 to vunit:count:
                           VValue = vunit:GETITEM(viii - 1).
                           VValue = repTegforDm(VValue).
                           addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                           
                           
                        end.
                        release object  vunit.
                        release object vItemIdentificationNumber.
                     end.
                     
                     vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                     do vii = 1 to vunits:count:
                        vunit = vunits:GETITEM(vii - 1).
                        getdesc(vunit).
                        if     vunit:Id eq "штрихкод"
                            or vunit:Id eq "ean"
                        then do:
                           setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                           setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                                  
                           find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num     
                                                          and utd-marking-lines.doc-id     = utd-lines.doc-id 
                                                          and utd-marking-lines.Linenum    = utd-lines.Linenum        
                           no-lock no-error.
                           if not available utd-marking-lines
                           then do:
                              vtext = vunit:Value.
                              do viii = 1 to num-entries(vtext," "):
                                 VValue = entry(viii,vtext," ").
                                 addMarkforUtd (utd-lines.db-num ,
                                          utd-lines.doc-id,
                                          utd-lines.Linenum,
                                          VValue,
                                          "",
                                          iDocument:type).
                              end.
                           end.
                        end.
                        if vunit:Id eq "Документ о соответствии" then do:
                          define variable v-sert-value as character no-undo .
                          find first utd-lines-attr exclusive-lock where utd-lines-attr.doc-id = utd-lines.doc-id and
                          utd-lines-attr.db-num = utd-lines.db-num and
                          utd-lines-attr.LineNum = utd-lines.LineNum and
                          utd-lines-attr.attr-code = "doc_sertif" no-error .
                          if available (utd-lines-attr) then utd-lines-attr.attr-value = utd-lines-attr.attr-value + "; " + vunit:value .
                          else setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"doc_sertif",vunit:value).
                        end.
                        release object  vunit.
                     end.
                     release object  vunits.
                     
                     release utd-lines.  
                     release object vExtendedInvoiceItem. 
                  end.
                  release object vItems.
                  
               end.
               else do:
                  PutMes("Ошибка получения данных из Диадок UniversalTransferDocumentWithHyphens").
                  release object vDocumentChild.
                  return error "Ошибка получения данных из Диадок UniversalTransferDocumentWithHyphens".
               end.
               
            end. /*упд*/
            else do:

               
               vContent = vDocumentChild:UniversalCorrectionDocument.
               if vContent ne ?
               then do:
                  getdesc(vContent).
                  getdesc(vContent:Seller).
                  getdesc(vContent:EventContent).
                  getdesc(vContent:EventContent:CorrectionBase).
                  
                    /* mSellerCol = mSellers:Seller. */
                  getOrganizationInfo(vContent:Seller,output utd.cli-inn,output utd.cli-kpp,utd.cli-FnsParticipantId, output vorgname, output vAdditionalInfo, output vAddrOrg).
                  utd.cli-info = vorgname + " " + vAddrOrg.
                  
                  do:
                      vInvoiceTable = vContent:Table.
                      getdesc(vInvoiceTable).
                      
                      getdesc(vInvoiceTable:TotalsInc).
                      getdesc(vInvoiceTable:TotalsDec).
                      getdesc(vInvoiceTable:Items).
                      getdesc(vInvoiceTable:Items:item).
                      
                  
                      vItems = vInvoiceTable:Items:item.
                      release object vInvoiceTable.
                      do vi = 1 to vItems:Count: /* Документы потомки */
             /*            put stream File-stream  unformatted skip vi skip.*/
                         vExtendedInvoiceItem = vItems:GetItem(vi - 1).
                           /* if VIII = 1 then*/ 
                         getdesc(vExtendedInvoiceItem).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos ).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo ).
                      /*   getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:getItem(0) ).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:getItem(1) ).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:getItem(2) ).
                         getdesc(vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo:getItem(3) ).
                        */ 
                         find first utd-lines where utd-lines.db-num     = utd.db-num
                                                and utd-lines.doc-id     = utd.doc-id
                                                and utd-lines.LineNum    = vi 
                         exclusive-lock no-error.
                         if not available  utd-lines
                         then do:
                            create utd-lines.
                            assign
                               utd-lines.db-num   = utd.db-num
                               utd-lines.doc-id   = utd.doc-id
                               utd-lines.Linenum  = vi
                               utd-lines.gds-code = ?
                            .
                            
                         end.
                         utd-lines.ProductCode = vExtendedInvoiceItem:Product.
/*                         utd-lines.UnitCode    = vExtendedInvoiceItem:UnitnAME.*/
                         vValues = vExtendedInvoiceItem:CorrectedValues no-error.
                         if vValues ne ?
                         then do:
                            getdesc(vExtendedInvoiceItem:OriginalValues ).
                            getdesc(vExtendedInvoiceItem:CorrectedValues ).
                            getdesc(vExtendedInvoiceItem:AmountsInc ).
                            getdesc(vExtendedInvoiceItem:AmountsDec ).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vValues:unit)).
                        
                            define variable vQuantity as decimal no-undo.
                            vQuantity    = vValues:Quantity.
                            utd-lines.Price       = vValues:Price.
                            utd-lines.TotalWithVatExcluded   = vValues:SubtotalWithVatExcluded.
/*                            utd-lines.UnitCode    = vValues:unitname.*/
                /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
                            utd-lines.TaxRate   =   if  vValues:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vValues:TaxRate,"/"),"%")).
                            utd-lines.Vat       = vValues:Vat.
                            utd-lines.Total     = vValues:Subtotal.
   /*                         utd-lines.Article   = vExtendedInvoiceItem:ItemVendorCode. /* ??? */*/
                            release object vValues.
                            vValues = vExtendedInvoiceItem:OriginalValues.
                            vQuantity    = vQuantity - vValues:Quantity.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vQuantity)).
                            utd-lines.Price       = utd-lines.Price - vValues:Price.
                            utd-lines.Vat       = utd-lines.Vat - vValues:Vat.
                            utd-lines.Total     = utd-lines.Total  - vValues:Subtotal.
                            utd-lines.TotalWithVatExcluded   = utd-lines.TotalWithVatExcluded - vValues:SubtotalWithVatExcluded.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old",string( vValues:Quantity)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Price_old"   ,string( vValues:Price)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TotalWithVatExcluded", string( vValues:SubtotalWithVatExcluded)).
                /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TaxRate_old", string(  if  vValues:TaxRate eq "без ндс" then -1 else decimal(trim(entry(1,vValues:TaxRate,"/"),"%")))).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Vat_old"    , string( vValues:Vat)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Total_old",       string( vValues:Subtotal)).
                            release object vValues.
                            vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                            do vii = 1 to vunits:count:
                               vunit = vunits:GETITEM(vii - 1).
                               getdesc(vunit).
                               if     vunit:Id eq "cis"
                                  or vunit:Id eq "cis_до"
                                  or vunit:Id eq "sscc"
                                  or vunit:Id eq "sscc_до"
                               then do:
                                  
                                  vtext = vunit:Value.
                                  if vtext ne "-"
                                  then do viii = 1 to num-entries(vtext," "):
                                     VValue = entry(viii,vtext," ").
                                     vsite = if     vunit:Id eq "cis" or vunit:Id eq "sscc" then "+" else "-".
                                     addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                                    
                                        
                                  end.
                               end.
                               release object vunit.
                            end.
                            do vii = 1 to vunits:count:
                               vunit = vunits:GETITEM(vii - 1).
                               getdesc(vunit).
                               if     vunit:Id eq "штрихкод"
                                   or vunit:Id eq "ean"
                               then do:
                                  setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                                  setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                                  find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num     
                                                                 and utd-marking-lines.doc-id     = utd-lines.doc-id 
                                                                 and utd-marking-lines.Linenum    = utd-lines.Linenum        
                                  no-lock no-error.
                                  if not available utd-marking-lines
                                  then do:
                                    vtext = vunit:Value.
                                    do viii = 1 to num-entries(vtext," "):
                                       VValue = entry(viii,vtext," ").
                                       addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, "",iDocument:type).
                                    end.
                                 end.
                                 
                              end.
                              release object  vunit.
                              
                           end.
                            release object vunits.
                            release utd-lines.
                            release utd-marking-lines.
                         end.
                         else do:
                            
                            getdesc(vExtendedInvoiceItem:OriginalItemIdentificationNumbers ).
                            getdesc(vExtendedInvoiceItem:OriginalItemIdentificationNumbers:ItemIdentificationNumber).
                            vunits = vExtendedInvoiceItem:OriginalItemIdentificationNumbers:ItemIdentificationNumber.
                            getdesc(vunits).
                            vsite =  "-".
                                  
                            do vii = 1 to vunits:count:
                               getdesc(vunits:GETITEM(vii - 1)).
                               vunit = vunits:GETITEM(vii - 1):unit.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                                          
                               end.
                               release object vunit.
                               vunit = vunits:GETITEM(vii - 1):PackageId.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                                       
                               end.
                               release object vunit.   
                            end.
                            release object vunits.   
                            getdesc(vExtendedInvoiceItem:CorrectedItemIdentificationNumbers).
                            vunits = vExtendedInvoiceItem:CorrectedItemIdentificationNumbers:ItemIdentificationNumber.
                            
                            getdesc(vunits).
                            vsite =  "+".
                                  
                            do vii = 1 to vunits:count:
                               getdesc(vunits:GETITEM(vii - 1)).
                               vunit = vunits:GETITEM(vii - 1):unit.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                                          
                               end.
                               release object vunit.
                               vunit = vunits:GETITEM(vii - 1):PackageId.
                               getdesc(vunit).
                               do viii = 1 to vunit:count:
                                  vvalue = vunit:GETITEM(viii - 1).
                                  addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, vsite,iDocument:type).
                                       
                               end.
                               release object vunit.   
                            end.
                            release object vunits.   
                               
                            getdesc(vExtendedInvoiceItem:TaxRate ).
                            getdesc(vExtendedInvoiceItem:UnitName ).
                            getdesc(vExtendedInvoiceItem:Unit ).
                            getdesc(vExtendedInvoiceItem:Quantity ).
                            getdesc(vExtendedInvoiceItem:Price ).
                            getdesc(vExtendedInvoiceItem:Excise ).
                            getdesc(vExtendedInvoiceItem:SubtotalWithVatExcluded ).
                            getdesc(vExtendedInvoiceItem:Vat ).
                            getdesc(vExtendedInvoiceItem:WithoutVat).
                            getdesc(vExtendedInvoiceItem:Subtotal ).
                            getdesc(vExtendedInvoiceItem:ItemTracingInfos ).
                            getdesc(vExtendedInvoiceItem:ItemTracingInfos:ItemTracingInfo ).
                            vValues = vExtendedInvoiceItem:CorrectedItemIdentificationNumbers.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Unit",string(vExtendedInvoiceItem:Unit:CorrectedValue)).
                            utd-lines.Price       = vExtendedInvoiceItem:Price:CorrectedValue.
                            utd-lines.TotalWithVatExcluded   = vExtendedInvoiceItem:SubtotalWithVatExcluded:CorrectedValue.
                            utd-lines.UnitCode    = vExtendedInvoiceItem:UnitName:CorrectedValue.
                /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
                            utd-lines.TaxRate   =   if  vExtendedInvoiceItem:TaxRate:CorrectedValue eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate:CorrectedValue,"/"),"%")).
                            utd-lines.Vat       = vExtendedInvoiceItem:Vat:CorrectedValue.
                            utd-lines.Total     = vExtendedInvoiceItem:Subtotal:CorrectedValue.
   /*                         utd-lines.Article   = vExtendedInvoiceItem:ItemVendorCode. /* ??? */*/
                            
                            vQuantity    = dec(vExtendedInvoiceItem:Quantity:CorrectedValue) - dec(vExtendedInvoiceItem:Quantity:OriginalValue).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(vQuantity)).
                            utd-lines.Price       = utd-lines.Price - vExtendedInvoiceItem:Price:OriginalValue.
                            utd-lines.Vat       = utd-lines.Vat - vExtendedInvoiceItem:Vat:OriginalValue.
                            utd-lines.Total     = utd-lines.Total  - vExtendedInvoiceItem:Subtotal:OriginalValue.
                            utd-lines.TotalWithVatExcluded   = utd-lines.TotalWithVatExcluded - vExtendedInvoiceItem:SubtotalWithVatExcluded:OriginalValue.
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old",string( vExtendedInvoiceItem:Quantity:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Price_old"   ,string( vExtendedInvoiceItem:Price:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TotalWithVatExcluded", string( vExtendedInvoiceItem:SubtotalWithVatExcluded:OriginalValue)).
                /*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"TaxRate_old", string(  if  vExtendedInvoiceItem:TaxRate:OriginalValue eq "без ндс" then -1 else decimal(trim(entry(1,vExtendedInvoiceItem:TaxRate:OriginalValue,"/"),"%")))).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Vat_old"    , string( vExtendedInvoiceItem:Vat:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Total_old",       string( vExtendedInvoiceItem:Subtotal:OriginalValue)).
                            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"UnitCode_old", vExtendedInvoiceItem:UnitName:OriginalValue).
                            
                         
                         end.
                         
                         
                         vunits = vExtendedInvoiceItem:AdditionalInfos:AdditionalInfo.
                         getdesc(vunits).
                         do vii = 1 to vunits:count:
                            vunit = vunits:GETITEM(vii - 1).
                            getdesc(vunit).
                            if     vunit:Id eq "штрихкод"
                                or vunit:Id eq "ean"
                            then do:
                               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,vunit:Id,vunit:value).
                               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode",vunit:value).
                               find first utd-marking-lines where       utd-marking-lines.db-num     = utd-lines.db-num     
                                                              and utd-marking-lines.doc-id     = utd-lines.doc-id 
                                                              and utd-marking-lines.Linenum    = utd-lines.Linenum        
                               no-lock no-error.
                               if not available utd-marking-lines
                               then do:
                                 vtext = vunit:Value.
                                 do viii = 1 to num-entries(vtext," "):
                                    VValue = entry(viii,vtext," ").
                                    addMarkforUtd (utd-lines.db-num, utd-lines.doc-id, utd-lines.LineNum, VValue, "",iDocument:type).
                                    
                                 end.
                              end.
                              
                           end.
                           release object  vunit.
                           
                        end.
                        release object  vunits.
                         
                         release object vExtendedInvoiceItem.   
                      end.
                      release object vItems. 
                  end.
                  release object vContent.
               end.
               else do:
                  create tt-recid.
                  assign
                     tt-recid.orgid = vOrganizationGuid
                     tt-recid.docid = vDocumentid
                  .
                  PutMes("Error Ошибка получения данных из Диадок UniversalCorrectionDocument").
                  release object vDocumentChild.
                  return error "Ошибка получения данных из Диадок UniversalCorrectionDocument".
               end.
            end.
            
         
            
         end.
         release object vDocumentChild.
         define variable vsetPAck as logical no-undo.
         define variable vcli-type as character no-undo.
         define variable vcli-code as integer no-undo.
         find first ext-classif where ext-classif.classif-name  eq {&extclass_code_id_diadok_client}
                                  and ext-classif.charkey_three eq utd.cli-FnsParticipantId
         no-lock no-error.
         if available ext-classif
         then do:
            assign 
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
            define variable vPack as character no-undo.
            if   iDocument:type eq "UniversalTransferDocument"
            then
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,utd.DocumentNumber,utd.DocumentDate).
            else if iDocument:type eq "UniversalTransferDocumentRevision"
            then
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalDocumentNumber,date(iDocument:OriginalDocumentDate)).
            else
               vPack = substitute("&1|&2|&3|&4",vcli-type,vcli-code,iDocument:OriginalInvoiceNumber,date(iDocument:OriginalInvoiceDate)).
            if vPack ne utd.PackageId
            then 
               assign
                  vsetPAck      = yes
                  utd.PackageId = vPack
               . 
         end.
         if vNewUtd or vsetPAck then do:
            if utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
            then do:
               if vNewUtd  then do:
                  GetLastUTDinPackbef(utd.db-num,utd.doc-id,volddb-num,volddoc-id).
                  find first old_utd where old_utd.db-num eq volddb-num
                                       and old_utd.doc-id eq volddoc-id
                     no-lock no-error.
                  for each utd-marking-lines where utd-marking-lines.db-num eq utd.db-num
                                               and utd-marking-lines.doc-id eq utd.doc-id
                  exclusive-lock:
                  
                     if available old_utd
                        and utd.db-num ne volddb-num
                        and utd.doc-id ne volddoc-id
                     then
                        find first buf_utd-marking-lines where buf_utd-marking-lines.mark       = utd-marking-lines.mark
                                                           and buf_utd-marking-lines.db-num     = old_utd.db-num     
                                                           and buf_utd-marking-lines.doc-id     = old_utd.doc-id
                        no-lock no-error.
                     utd-marking-lines.sts = if available buf_utd-marking-lines then buf_utd-marking-lines.sts else  objSrv:Env:marking:Sts:Mark:PendingVerification:KeyIntDB.
                  end.
                  validate utd. /* необходимо для привязки марок */
                  ReCheckload( utd.db-num, utd.doc-id,yes).
                  subscribe "getNextseq" anywhere run-procedure "MySeqForUtd". /*Подпишимся еще раз так как в нутир отписались от события */
               end.
            end.
            else do:
               GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
               find first old_utd where old_utd.db-num eq volddb-num
                                    and old_utd.doc-id eq volddoc-id
               no-lock no-error.
               if not available old_utd
                  or (   utd.db-num eq volddb-num
                     and utd.doc-id eq volddoc-id)
               then
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoAvailDoc",string(utd.PackageId) + {&delim-par} + string(utd.db-num) + {&delim-par} + string(utd.doc-id)).
               else do:
                   assign
                       utd.obj-inn               = old_utd.obj-inn
                       utd.obj-kpp               = old_utd.obj-kpp
                       utd.obj-FnsParticipantId  = old_utd.obj-FnsParticipantId
                       utd.obj-info              = old_utd.obj-info
                       utd.parentDocumentExt     = old_utd.DocumentExt
                       utd.parentOrganizationExt = old_utd.OrganizationExt
                       utd.contract-code         = old_utd.contract-code
                   .
               end.
               validate utd. /* необходимо для привязки марок */
               SaturateAndCheckUTD( utd.db-num, utd.doc-id).
            end.
            
         end.   
         GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
         find first old_utd where old_utd.db-num eq volddb-num
                              and old_utd.doc-id eq volddoc-id
         no-lock no-error.
         if available old_utd
         then 
            assign
               utd.parentDocumentExt     = old_utd.DocumentExt
               utd.parentOrganizationExt = old_utd.OrganizationExt
            .
        /* if utd.DocumentNumber eq "1103_3"
         then
            run gbl/inidebug.p.*/
         create tt-recid.
         assign
            tt-recid.orgid = vOrganizationGuid
            tt-recid.docid = vDocumentid
         .
         if utd.EDocType = objSrv:Env:Utd:EDocType:UCD:KeyIntDB
         then do:
            tt-recid.parent = utd.PackageId.
            tt-recid.stamp  = utd.Timestamp.
         end.
         release utd no-error. /* необходимо для сохранения истории */
         if error-status:error
         then
            PutMes(substitute("Документ &1 от &2 не загружен. &3" ,iDocument:DocumentNumber,iDocument:DocumentDate,return-value) ).
         else
            PutMes(substitute("Документ &1 от &2 загружен." ,iDocument:DocumentNumber,iDocument:DocumentDate) ).
         unsubscribe "getNextseq". 
         
      end.
   end.
end.

{&CommentStartNoClass}
method public date pacetupdd
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function packetupdd returns date 
{utl\comment.i} */
(iOrganization as component-handle, iDocument as component-handle):
   define variable VPack as character no-undo.
   define variable vorgid as character no-undo.
   define variable vdocid as character no-undo.
   define variable vstamp as datetime no-undo.
   define variable VPack2 as character no-undo.
   define variable vorgid2 as character no-undo.
   define variable vdocid2 as character no-undo.
   define variable vstamp2 as datetime no-undo.
   
   define variable VPackage as component-handle no-undo.
   define variable vi as integer no-undo.
   define variable vDocument as component-handle no-undo.
   define variable vDocuments as component-handle no-undo.
   
   
      VPack = iDocument:PackageId.
      vorgid = iDocument:OrganizationGuid.
      vdocid = iDocument:DocumentId.
      vstamp = iDocument:Timestamp.
  
      find first tt-pack where tt-pack.packid eq VPack
                           and tt-pack.stamp  eq vstamp
                           and tt-pack.orgid  eq vorgid
                           and tt-pack.docid  eq vdocid
      no-lock no-error.
      if not available tt-pack
      then do:
         create tt-pack.
         assign
            tt-pack.packid = VPack
            tt-pack.stamp  = vstamp
            tt-pack.orgid  = vorgid
            tt-pack.docid  = vdocid
         .
      end.
      getdesc(iDocument ).
      getdesc(iDocument:InitialDocumentIds ).
         
        /* VPackage = iDocument:GetDocumentPackage().
         getdesc(VPackage ).
         vDocuments = VPackage:Documents.*/
      vDocuments = iDocument:InitialDocumentIds.
         
      do vi= 1 to vDocuments:Count:
         vDocument = iOrganization:GetDocumentById(vDocuments:GetItem(vi - 1),false).
         getdesc(vDocument ).
         vorgid2 = vDocument:OrganizationGuid.
         vdocid2 = vDocument:DocumentId.
         vstamp2 = vDocument:Timestamp.
         find first tt-pack where tt-pack.packid eq VPack
                              and tt-pack.stamp  eq vstamp2
                              and tt-pack.orgid  eq vorgid2
                              and tt-pack.docid  eq vdocid2
         no-lock no-error.
         if not available tt-pack
         then do:
            create tt-pack.
            assign
               tt-pack.packid = VPack
               tt-pack.stamp  = vstamp2
               tt-pack.orgid  = vorgid2
               tt-pack.docid  = vdocid2
            .
         
         end.
         release object vDocument.
      end.
      release object vDocuments.
end.
  
{&CommentStartNoClass}
method public void UpdateUTDInform (ibeg-date as date,iend-date as date,output odatelast as date):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure UpdateUTDInform:
   define input  parameter ibeg-date as date no-undo.
   define input  parameter iend-date as date no-undo.
   define output parameter odatelast as date no-undo. 
{utl\comment.i} */
   define variable vOrganizationList as component-handle no-undo.
   define variable vOrganization as component-handle no-undo.
   define variable vDocumentsTask as component-handle no-undo.
   define variable vDocumentList  as component-handle no-undo.
   define variable vDocumentchildList  as component-handle no-undo.
   define variable vDocument       as component-handle no-undo.
   
   define buffer ext-classif_obj for ext-classif.
   define buffer ext-classif_Cli  for ext-classif.
   
   define variable vi  as integer no-undo.
   define variable vii as integer no-undo.
   odatelast = ibeg-date.
   vOrganizationList = mDiadocConnection:GetOrganizationList() no-error.
   if vOrganizationList eq ? then return error ?.
   vi = vOrganizationList:Count()no-error.
   if vi eq ?
   then
      return error ?.
   for each tt-recid:
      delete tt-recid.
   end.
   for each tt-pack:
      delete tt-pack.
   end.
   do vi = 1 to vOrganizationList:Count() :
   /*     Получение конкретной организации*/
      vOrganization = vOrganizationList:GetItem(vi - 1 ).
      getdesc(vOrganization).
      run changeIdtoGuid(vOrganization).
      vDocumentsTask = vOrganization:GetDocumentsTask().
     /* for each ext-classif_Cli where ext-classif_Cli.classif-name  eq {&extclass_code_id_diadok_client}
      no-lock:
         find first clients 
                 where clients.obj-type   = ext-classif_cli.CharKey_One
                   and clients.obj-code   = ext-classif_cli.Key#_One
                   and not can-find(first ub.sysconf where ub.sysconf.host-code = clients.obj-code)
         no-lock no-error .
         if available  clients
         then do:
            for each ext-classif_obj where ext-classif_obj.classif-name  eq {&extclass_code_id_diadok_client}
            no-lock:
               find first clients 
                    where clients.obj-type   = ext-classif_obj.CharKey_One
                      and clients.obj-code   = ext-classif_obj.Key#_One
                      and can-find(first ub.sysconf where ub.sysconf.host-code = clients.obj-code)
               no-lock no-error .
               if available  clients
               then do:*/
       /*    Заполняем параметры отбора документов*/
                  vDocumentsTask:FromSendDate = ibeg-date  .
                  vDocumentsTask:ToSendDate   = iend-date.
                  
                              /* mDocumentsTask:Category     = "XmlTorg12.InboundWaitingForRecipientSignature".*/
                  for each tt-type, each tt-Class:
                    /* if tt-Class.id eq "Inbound"
                     then do:
                        vDocumentsTask:ToDepartmentId   = ext-classif_obj.charkey_three .
                        vDocumentsTask:FromDepartmentId = ext-classif_Cli.charkey_three .
                     end.
                     else if tt-Class.id eq "Outbound"
                     then do:
                        vDocumentsTask:ToDepartmentId   = ext-classif_Cli.charkey_three.
                        vDocumentsTask:FromDepartmentId = ext-classif_obj.charkey_three.
                     end.*/
                      vDocumentsTask:Category     = tt-type.id + "." + tt-Class.id.
                     PutMes(substitute("Формируем список зависимых документов за период с &2 по &3  &1Категория: &4 &5",
                                       /*"Загрузка документов за период с &2 по &3  &1Отправитель &4&1Получатель &5&1Категория &6.&7",*/
                                       {&new-line},    
                                       ibeg-date ,
                                       iend-date,
                                    /*   vDocumentsTask:FromDepartmentId,
                                       vDocumentsTask:ToDepartmentId,*/
                                       
                                       if tt-type .id eq "Any" then "" else tt-type.name,
                                       tt-Class.name)). 
                  /*       Получаем коллекцию документов*/
          
                      vDocumentList = vDocumentsTask:GetDocuments() no-error.
                      if vDocumentList ne ?
                      then do: 
                        do vii= 1 to vDocumentList:Count:
                           if chekStop() then return ?.
                           vDocument = vDocumentList:GetItem(vii - 1).
/*                         message vDocument:DocumentNumber                     view-as alert-box.*/
                           odatelast = max(odatelast,vDocument:DocumentDate) no-error.
                           odatelast = min(odatelast,today).
                           packetupdd(vOrganization, vDocument).
                           release object vDocument.
                         end.
                         release object vDocumentList.
                      end.
                   end.
                   define variable VAlldoc    as integer no-undo.
                   define variable vprocessed as integer no-undo.
                   for each tt-pack :
                      VAlldoc = VAlldoc + 1.
                   end.
                   for each tt-pack :
                       if chekStop() then return ?.
                      if GetDocumforid (tt-pack.orgid, tt-pack.docid, output vDocument) eq "" /* Получим обновленный объект */
                      then do:
                         {&CommentStartClass} run {utl\comment.i} */ UpdateUTDInformOne(vDocument). 
                         release object vDocument.
                     end.
                     vprocessed = vprocessed + 1.
                     PutStat (substitute ("Обработано документов &1 из &2",vprocessed,vAllDoc),yes).   
                  end.
              /*  end.
             end.
          end.
      end.*/
      release object vOrganization.
      release object vDocumentsTask.
   end.
   /*pause 60.*/
   release object vOrganizationList.
end.

{&CommentStartNoClass}
method public void updOneUTD
(idb-num as integer ,
 idoc-id as integer  ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure updOneUTD:
   define input  parameter idb-num as integer no-undo. 
   define input  parameter idoc-id as integer no-undo.
{utl\comment.i} */
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   for each tt-recid:
      delete tt-recid.
   end.
   if getdocum (idb-num, idoc-id, output vDocument) eq "" /* Получим обновленный объект */
   then do:
      {&CommentStartClass} run {utl\comment.i} */ UpdateUTDInformOne(vDocument). 
      release object vDocument.
   end.
   
end.
