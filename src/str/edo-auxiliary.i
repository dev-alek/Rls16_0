/*получение  TitleType*/
{&CommentStartNoClass}
method private char GetDocTitleType
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function GetDocTitleType returns character  
{utl\comment.i} */
(iOrganizationGuid as character ,
itype as character ,
ifunction as character, 
iversion as character
):
   if iOrganizationGuid eq ? then return "".
   /* олучение чsd схемы */
   define variable vOrganization  as component-handle no-undo.
   define variable vDocumentTypes as component-handle no-undo.
   define variable vDocumentType  as component-handle no-undo.
   define variable vFunctions     as component-handle no-undo.
   define variable vFunction      as component-handle no-undo.
   define variable vVersions      as component-handle no-undo.
   define variable vVersion       as component-handle no-undo.
   define variable vTitles        as component-handle no-undo.
   define variable vTitle         as component-handle no-undo.
   define variable vi             as integer no-undo.
   define variable vii            as integer no-undo.
   define variable viii           as integer no-undo.
   define variable viiii          as integer no-undo.
   define variable oTitleType as character no-undo.
   vOrganization = mDiadocConnection:GetOrganizationById(iOrganizationGuid) no-error.
   if vOrganization eq ? then return "".
   vDocumentTypes = vOrganization:GetDocumentTypes().
   do vi =1 to vDocumentTypes:count:
      vDocumentType = vDocumentTypes:GetItem(vi - 1).
      if vDocumentType:name eq iType
      then do: 
         vFunctions = vDocumentType:Functions.
         do vii =1 to vFunctions:count:
            vFunction = vFunctions:GetItem(vii - 1 ).
            if vFunction:name eq ifunction
            then do: 
               vVersions = vFunction:Versions.
               do viii =1 to vVersions:count:
                  vVersion = vVersions:GetItem(viii - 1 ).
                  if vVersion:version eq iversion
                  then do:
                     vTitles  = vVersion:Titles.
                     do viiii =1 to vTitles:count:
                        vTitle = vTitles:GetItem(viiii - 1 ).
                        oTitleType = oTitleType + "," + vTitle:type.
                        release object vTitle.
                     end.
                     release object vTitles.
                  end.
                  release object vVersion.    
               end.
               release object vVersions.
            end.
            release object vFunction.
         end.
         release object vFunctions.
      end.
      release object vDocumentType.
   end.
   release object vDocumentTypes.
   release object vOrganization.
   return left-trim(oTitleType,",").
  
end.


/* Заполнение справочников */
define temp-table tt-type no-undo
          field id as char
          field name as character 
          index pi id .
          
define temp-table tt-Class no-undo like tt-type.

{&CommentStartNoClass}
method public void crcode
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function crcode returns character 
{utl\comment.i} */
():

   define variable vtypelist as character no-undo.
   define variable vtypename as character no-undo.
   define variable vi as integer no-undo.

   vtypelist = /*"Nonformalized|"
             + "Invoice|"
             /*+ "InvoiceRevision|"*/
/*             + "InvoiceCorrection|"*/
/*             + "InvoiceCorrectionRevision|"*/
             + "Torg12|"
             + "XmlTorg12|"
             + "AcceptanceCertificate|"
             + "XmlAcceptanceCertificate|"
             + "TrustConnectionRequest|"
             + "PriceListAgreement|"
             + "CertificateRegistry|"
             + "ReconciliationAct|"
             + "Contract|"
             + "ProformaInvoice|"
             + "ServiceDetails|" */
              "UniversalTransferDocument|"
             + "UniversalTransferDocumentRevision|"
             + "UniversalCorrectionDocument|"
             + "UniversalCorrectionDocumentRevision"
           /*  + "AnyInvoiceDocumentType|"
             + "AnyBilateralDocumentType|"
             + "AnyUnilateralDocumentType|"
             + "Any" */
             .
   vtypename = /*"неформализованный документ|"
             + "счет-фактура|"
           /*  + "исправление счета-фактуры|"*/
/*             + "корректировочный счет-фактура|"*/
/*             + "исправление корректировочного счета-фактуры|"*/
            + "неформализованная накладная ТОРГ-12|"
             + "формализованная накладная ТОРГ-12|"
             + "неформализованный акт о выполнении работ|"
             + "формализованный акт о выполнении работ|"
             + "предложение партнёрских отношений|"
             + "протокол согласования цены|"
             + "реестр сертификатов|"
             + "акт сверки|"
             + "договор|"
             + "счет на оплату|"
             + "детализация|" */
              "УПД|"
             + "Исправление УПД|"
             + "УКД|"
             + "Исправление УКД"
         /*    + "соответствует набору из четырех типов документов: Invoice, InvoiceRevision, InvoiceCorrection, InvoiceCorrectionRevision|"
             + "соответствует любому типу двусторонних документов: Nonformalized, Torg12, AcceptanceCertificate, XmlTorg12, XmlAcceptanceCertificate, TrustConnectionRequest, PriceList, PriceListAgreement CertificateRegistry ReconciliationAct Contract Torg13|"
             + "соответствует любому типу односторонних документов: ProformaInvoice, ServiceDetails|"
             + "любому типу документа|"*/
             .
          
          
   do vi = 1 to num-entries(vtypelist,"|"):
      create tt-type.
      assign
         tt-type.id   =  entry(vi,vtypelist,"|")
         tt-type.name =  entry(vi,vtypename,"|")
      .
   end.

   vtypelist = "Inbound|"
             + "Outbound|"
/*             + "Internal|"*/
             + "Proxy". 
   
   vtypename = "входящий документ|"
             + "исходящий документ|"
            /* + "внутренний документ|"*/
             + "документ, переданный через промежуточного получателя|".
   do vi = 1 to num-entries(vtypelist,"|"):
      create tt-Class.
      assign
         tt-Class.id   =  entry(vi,vtypelist,"|")
         tt-Class.name =  entry(vi,vtypename,"|")
      .
   end. 
   /*
   vtypelist = "NotRead|"
             + "NoRecipientSignatureRequest|"
             + "WaitingForRecipientSignature|"
             + "WithRecipientSignature|"
             + "WithSenderSignature|"
             + "RecipientSignatureRequestRejected|"
             + "WaitingForSenderSignature|"
             + "InvalidSenderSignature|"
             + "InvalidRecipientSignature|"
             + "Approved|"
             + "Disapproved|"
             + "WaitingForResolution|"
             + "SignatureRequestRejected|"
             + "Finished|"
             + "HaveToCreateReceip|"
             + "NotFinished|"
             + "InvoiceAmendmentRequested|"
             + "RevocationIsRequestedByMe|"
             + "RequestsMyRevocation|"
             + "RevocationAccepted|"
             + "RevocationRejected|"
             + "RevocationApproved|"
             + "RevocationDisapproved|"
             + "WaitingForRevocationApprovement|"
             + "NotRevoked|"
             + "WaitingForProxySignature|"
             + "WithProxySignature|"
             + "InvalidProxySignature|"
             + "ProxySignatureRejected|"
             + "WaitingForInvoiceReceipt|"
             + "WaitingForReceipt|"
             + "RequestsMySignature|"
             + "RoamingNotificationError".




   vtypename = "документ не прочитан|"
             + "документ без запроса ответной подписи|"
             + "документ в ожидании ответной подписи|"
             + "документ с ответной подписью|"
             + "документ с подписью отправителя|"
             + "документ с отказом от формирования ответной подписи|"
             + "документ, требующий подписания и отправки|"
             + "документ с невалидной подписью отправителя, требующий повторного подписания и отправки|"
             + "документ с невалидной подписью получателя, требующий повторного подписания и отправки|"
             + "согласованный документ|"
             + "документ с отказом согласования|"
             + "документ, находящийся на согласовании или подписи|"
             + "документ с отказом в запросе подписи сотруднику|"
             + "документ с завершенным документооборотом|"
             + "требуется подписать извещение о получении|"
             + "документ с незавершенным документооборотом|"
             + "имеет смысл только для счетов-фактур; документ, по которому было запрошено уточнение|"
             + "документ, по которому было запрошено аннулирование|"
             + "документ, по которому контрагент запросил аннулирование|"
             + "аннулированный документ|"
             + "документ, запрос на аннулирование которого был отклонен|"
             + "документ, запрос на аннулирование которого был согласован|"
             + "документ с отказом согласования запроса на аннулирование|"
             + "документ, находящийся на согласовании запроса аннулирования|"
             + "неаннулированный документ|"
             + "документ в ожидании подписи промежуточного получателя|"
             + "документ с подписью промежуточного получателя|"
             + "документ с невалидной подписью промежуточного получателя, требующий повторного подписания и отправки|"
             + "документ с отказом от формирования подписи промежуточным получателем|"
             + "документ в ожидании получения извещения о получении счета-фактуры|"
             + "документ в ожидании получения извещения о получении|"
             + "документ, по которому контрагент запросил подпись|"
             + "документ, с ошибкой доставки в роуминге".
             
   do vi = 1 to num-entries(vtypelist,"|"):
      create tt-Status.
      assign
         tt-Status.id   =  entry(vi,vtypelist,"|")
         tt-Status.name =  entry(vi,vtypename,"|")
      .
   end.        
     */        
end.     
/* ЗАГРУЖАЕМ СПРАВОЧНИК */
crcode().

/*Получене информации по контр огену*/
{&CommentStartNoClass}
method public void getOrganizationInfo
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function getOrganizationInfo returns character 
{utl\comment.i} */
(input iContAgent as component-handle,
                                                output oinn as character,  
                                                output oKpp as character,
                                                output oFnsParticipantId as character,
                                                output oOrgName as character,
                                                output oAdditionalInfo as character,
                                                output OarddrRus as character  
                                                 ):
    
   define variable vi as integer no-undo.
   define variable vContAgentOrganizationDetails   as component-handle no-undo.
/*   define variable vContAgentOrganizationReference as component-handle no-undo.*/
   define variable vAddrRus                        as component-handle no-undo.
   
   if iContAgent ne ?
   then do: 
      getdesc(iContAgent).
      vContAgentOrganizationDetails = iContAgent:OrganizationDetails.
      
      oinn = vContAgentOrganizationDetails:Inn.
      oKpp = vContAgentOrganizationDetails:Kpp.
      oFnsParticipantId = vContAgentOrganizationDetails:FnsParticipantId.
      oAdditionalInfo = vContAgentOrganizationDetails:OrganizationAdditionalInfo.
      
      getdesc(vContAgentOrganizationDetails).
      oOrgName = vContAgentOrganizationDetails:OrgName. 
      getdesc(vContAgentOrganizationDetails:Address).
      vAddrRus = vContAgentOrganizationDetails:Address:RussianAddress.
      getdesc(vAddrRus ).
      if vAddrRus ne ?
      then do:
         if vAddrRus:ZipCode ne ""
         then
            OarddrRus = OarddrRus + " " + vAddrRus:ZipCode.
         if vAddrRus:Region ne ""
         then
            OarddrRus = OarddrRus + " Регион: " + vAddrRus:Region.
         if vAddrRus:Territory ne ""
         then
            OarddrRus = OarddrRus + " Область: " + vAddrRus:Territory.
         if vAddrRus:City ne ""
         then
            OarddrRus = OarddrRus + " Город: " + vAddrRus:City.
         if vAddrRus:Locality ne ""
         then
            OarddrRus = OarddrRus + " Район: " + vAddrRus:Locality.
         if vAddrRus:Street ne ""
         then
            OarddrRus = OarddrRus + " Улица: " + vAddrRus:Street.
         if vAddrRus:Block ne ""
         then
            OarddrRus = OarddrRus + " Стр: " + vAddrRus:Block.
         if vAddrRus:Building ne ""
         then
            OarddrRus = OarddrRus + " Дом: " + vAddrRus:Building.
         if vAddrRus:Apartment ne ""
         then
            OarddrRus = OarddrRus + " Квартира: " + vAddrRus:Apartment.
       
         
      end.
      release object vAddrRus.
      /*getdesc(vContAgentOrganizationDetails:Address:ForeignAddress).
      vContAgentOrganizationReference = iContAgent:OrganizationReference.
      getdesc(vContAgentOrganizationReference).
      */
      release object vContAgentOrganizationDetails.
   end.
end.

