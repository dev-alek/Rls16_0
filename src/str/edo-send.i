{&CommentStartNoClass}
method private character SendAccept  
 (itype as character ,
  iReplyTask as component-handle,
  iOrganizationGuid as character ,
  iWorkflowId as integer,
  output oOperationCode as character  ): 
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure SendAccept:
   define input  parameter iTypeAccept     as character no-undo.
   define input  parameter iReplyTask      as component-handle no-undo.
   define input  parameter iOrganizationGuid as character no-undo.
   define input  parameter iWorkflowId     as integer no-undo.
   define input  parameter iTitleTypes    as character  no-undo.
   
   define output parameter oOperationCode as character no-undo.                                   
{utl\comment.i} */
   define variable vContentItems as component-handle no-undo.
   define variable vContentItem  as component-handle no-undo.
   define variable vSigner       as component-handle no-undo.
   define variable vBuyerTitle   as component-handle no-undo.
   define variable vEmployee     as component-handle no-undo.
   define variable vContentOperCode as component-handle no-undo.
   define variable vOrganization   as component-handle no-undo.
   define variable vUserperm   as component-handle no-undo.
   
   define variable vi as integer no-undo.

  define variable vdate as date no-undo.
  define variable vDocumentCreator as character no-undo.
  define variable vDocumentCreatorBase as character no-undo.
  define variable vOperationCode as character no-undo.
  define variable vOperationContenttext as character no-undo.
  define variable vOperationContent as character no-undo.
  define variable vThumbprint as character no-undo.
  define variable vJobTitle   as character no-undo.

  vThumbprint = mDiadocConnection:Certificate:Thumbprint.
  vOrganization = mDiadocConnection:GetOrganizationById(iOrganizationGuid) no-error.
  if vOrganization eq ?
  then do:
     run str\utdacp.w (output vdate, output  vDocumentCreator, output vDocumentCreatorBase, output vOperationCode, output vOperationContent) no-error.
     if vdate eq ?
     then
        return error "".
  end. 
  else do:
     define variable vTitleType as character no-undo.
     define variable vSignSet   as component-handle no-undo.
     define variable vSeller as logical no-undo.
     vUserperm = vOrganization:GetUserPermissions().
     vJobTitle = vUserperm:JobTitle.
     release object vUserperm.     
     blk-tit:
     do vi = 1 to num-entries(iTitleTypes):
        vTitleType = entry(vi,iTitleTypes).
        vSeller = index(vTitleType,"Seller") > 0.
        if vSeller
        then 
           next blk-tit.
        vSignSet = vOrganization:GetExtendedSignerDetails2(vThumbprint, vTitleType) no-error.
        if error-status:num-messages > 0
        then do:
           define variable vTasksetSign   as component-handle no-undo.
           define variable vTasksetSignDetal   as component-handle no-undo.
         
           vTasksetSign = vOrganization:CreateSetExtendedSignerDetailsTask(VThumbprint).  
           getdesc(vTasksetSign).
           vTasksetSign:DocumentTitleType = vTitleType.
           getdesc(vTasksetSign).
           vTasksetSignDetal = vTasksetSign:ExtendedSignerDetailsToPost.
           getdesc(vTasksetSignDetal).
           vTasksetSignDetal:JobTitle  = vJobTitle    . /* должность работника */
/*                 vTasksetSignDetal:RegistrationCertificate = "" . /* реквизиты свидетельства о регистрации ИП */*/
           vTasksetSignDetal:SignerType = "LegalEntity" . /* тип подписанта. LegalEntity представитель юридического лица */
           vTasksetSignDetal:SignerInfo = "". /* иные сведения, идентифицирующие физическое лицо*/
           vTasksetSignDetal:Powers = if VSeller then "InvoiceSigner"  else "PersonDocumentedOperation". /* область полномочий InvoiceSigner  лицо, ответственное за подписание счетов-фактур*/
           vTasksetSignDetal:Status = if VSeller then "SellerEmployee" else "BuyerEmployee". /* статус BuyerEmployee   работник организации покупателя товаров (работ, услуг, имущественных прав) */
           vTasksetSignDetal:PowersBase = "Должностные обязанности". /* основания полномочий (доверия) */
/*                 vTasksetSignDetal:OrganizationPowersBase = "". /* основания полномочий (доверия) организации*/*/
           getdesc(vTasksetSignDetal).
           release object vTasksetSignDetal.
           vTasksetSign:send() no-error.
           if error-status:num-messages > 0 then do:
         
              PutErr(substitute("Error Ошибка при установке подписанта по документу &1 ", vTitleType )).
           end.
           release object vTasksetSign.
         
        end.
        else do: 
           getdesc(vSignSet).
           release object vSignSet.
        end.
     end.
        
     vOperationContent = if iTypeAccept eq "AcceptDocumentWithDisc" 
                         then "2" 
                         else if iTypeAccept eq "AcceptDocumentNotAccepted" 
                         then "3" 
                         else "1".
     vdate = today.
     vDocumentCreator = substitute("&1, ИНН~/КПП &2~/&3", vOrganization:name , vOrganization:inn , vOrganization:kpp).
     release object vOrganization.
  end.
     
     
  if    vJobTitle eq ?
     or vJobTitle eq ""
  then
     vJobTitle = mDiadocConnection:Certificate:JobTitle.
  
                      
   if (   iWorkflowId = 3
      or iWorkflowId = 5
      or iWorkflowId = 8
      or iWorkflowId = 11
      or iWorkflowId = 12
      or iWorkflowId = 13
      or iWorkflowId = 16)
      
      and iReplyTask ne ?
   then do:
      getdesc(iReplyTask).
      vContentItems = iReplyTask:ContentItems.
      getdesc(vContentItems).
      do vi = 1 to vContentItems:count:
         getdesc(vContentItems:GetItem(vi - 1 )).
         getdesc(vContentItems:GetItem(vi - 1 ):document).
         vContentItem = vContentItems:GetItem(vi - 1 ):Content.
         getdesc(vContentItem).
         
         vBuyerTitle = vContentItem:UniversalTransferDocumentBuyerTitle no-error.
         getdesc(vBuyerTitle).
           if vBuyerTitle eq ?
         then do:
            vBuyerTitle = vContentItem:UniversalCorrectionDocumentBuyerTitle.
            getdesc(vBuyerTitle).
            vOperationContenttext = "C изменением стоимости согласен".
         end.
         else do:
            oOperationCode = vOperationContent.
   vOperationContenttext = if vOperationContent eq "1"
                       then "Принято без разногласий"
                       else if vOperationContent eq "2"
                       then "Принято с разногласиями"
                       else if vOperationContent eq "3"
                       then "Товары не приняты"
                       else vOperationContent.
            getdesc(vBuyerTitle).
            vEmployee = vBuyerTitle:Employee.
            getdesc(vEmployee).
            define variable vUser   as component-handle no-undo.
            vUser = mDiadocConnection:GetMyUser().
            getdesc(vUser).
            vEmployee:position        = vJobTitle    . /* должность работника */
            vEmployee:FirstName       = vUser:FirstName  . /* фамилия */
            vEmployee:LastName        = vUser:LastName   . /* имя */
            vEmployee:MiddleName      = vUser:MiddleName . /* отчество */
   /*         vEmployee:EmployeeInfo     = /* иные сведения, идентифицирующие физическое лицо */   */
            vEmployee:EmployeeBase     = "Должностные обязанности". /* основание полномочий представителя */ 
            release object vUser.
            getdesc(vEmployee).
            getdesc(mDiadocConnection:Certificate).
   
            
            getdesc(vContentItem:UniversalTransferDocumentBuyerTitle).
            getdesc(vBuyerTitle:ContentOperCode).
            vContentOperCode = vBuyerTitle:ContentOperCode. /* КодСодОпер */
         /*   vContentOperCode:IdDiscrepDocument = "IdDiscrepDocument". /* ИдФайлДокРасх */
            vContentOperCode:DateDiscrepDocument = string(today,"99.99.9999"). /* ДатаДокРасх */
            vContentOperCode:NumberDiscrepDocument = "NumberDiscrepDocument". /* НомДокРасх */
            vContentOperCode:TypeDiscrepDocument = "3".                       /* ВидДокРасх Принимает значение: 
   2 – документ о приемке с расходениями   |
   3 – документ о расхождениях
            */
            vContentOperCode:NameDiscrepDocument = "NameDiscrepDocument". /* НаимДокРасх */ */
            vContentOperCode:TotalCode = vOperationContent. /* КодИтога  Принимает значение:
   1 – товары (работы, услуги, права) приняты без расхождений (претензий)   |
   2 – товары (работы, услуги, права) приняты с расхождениями (претензией)   |
   3 – товары (работы, услуги, права) не приняты
            */
            vBuyerTitle:OperationCode   = oOperationCode. /*"вид операции".*/
            release object vContentOperCode.
            release object vEmployee.
         end. 
         vBuyerTitle:DocumentCreator = vDocumentCreator . /*"составитель файла обмена счета-фактуры (информации покупателя)".*/
         vBuyerTitle:DocumentCreatorBase     = vDocumentCreatorBase. /*"основание, по которому экономический субъект является составителем файла обмена счета-фактуры".*/
         
         vBuyerTitle:OperationContent =  vOperationContenttext. /* "содержание операции".*/
         vBuyerTitle:AcceptanceDate   = vdate. /*"Дата, чтение/запись - дата принятия товаров (результатов выполненных работ) или имущественных прав (подтверждения факта оказания услуг)" */
         /* mContentItem:Comment = "Норм".*/
         getdesc(vBuyerTitle).
         getdesc(vBuyerTitle:Signers).
         
         vSigner = vBuyerTitle:Signers:additems().
         getdesc(vSigner).
         getdesc(vSigner:SignerReference).
         getdesc(vSigner:SignerDetails).
         
   /*      для подписи должнобыть заполнено только одно из либо vSigner:SignerReference либо vSigner:SignerDetails
   
   
   vSigner:SignerDetails:Firstname    = "Фамилия1".
         vSigner:SignerDetails:LastName  = "Имя2".
         vSigner:SignerDetails:middlename = "Отчество3".
         vSigner:SignerDetails:SignerStatus = "SellerEmployee" .
   /*Значение Status Описание
   SellerEmployee работник организации продавца товаров (работ, услуг, имущественных прав)
   InformationCreatorEmployee работник организации - составителя информации продавца
   OtherOrganizationEmployee  работник иной уполномоченной организации
   AuthorizedPerson  уполномоченное физическое лицо (в том числе индивидуальный предприниматель)
   BuyerEmployee  работник организации покупателя товаров (работ, услуг, имущественных прав)
   InformationCreatorBuyerEmployee  работник организации - составителя информации покупателя*/
   vSigner:SignerDetails:SignerPowers = "PersonMadeOperation".
   /*Значение Powers Описание
   InvoiceSigner  лицо, ответственное за подписание счетов-фактур
   PersonMadeOperation  лицо, совершившее сделку, операцию
   MadeAndSignOperation лицо, совершившее сделку, операцию и ответственное за её оформление
   PersonDocumentedOperation  лицо, ответственное за оформление свершившегося события
   MadeOperationAndSignedInvoice лицо, совершившее сделку, операцию и ответственное за подписание счетов-фактур
   MadeAndResponsibleForOperationAndSignedInvoice  лицо, совершившее сделку, операцию и ответственное за её оформление и за подписание счетов-фактур
   ResponsibleForOperationAndSignerForInvoice   лицо, ответственное за оформление свершившегося события и за подписание счетов-фактур*/
   vSigner:SignerDetails:SignerOrgPowersBase = " основания полномочий (доверия) организации" .
   vSigner:SignerDetails:SignerPowersBase = "основания полномочий (доверия)".
   vSigner:SignerDetails:SignerInfo = "иные сведения, идентифицирующие физическое лицо".
   vSigner:SignerDetails:SignerOrganizationName = "наименование организации" .
   vSigner:SignerDetails:SignerType = "LegalEntity".
   /* LegalEntity представитель юридического лица
   IndividualEntity  индивидуальный предприниматель
   PhysicalPerson физическое лицо
   */
   vSigner:SignerDetails:RegistrationCertificate = "реквизиты свидетельства о регистрации ИП". 
   vSigner:SignerDetails:Inn = mDiadocConnection:Certificate:inn.
   
         
         
   */
         vSigner:SignerReference:CertificateThumbprint = mDiadocConnection:Certificate:Thumbprint.
         vSigner:SignerReference:boxid = iOrganizationGuid.
         getdesc(vSigner:SignerReference).
         release object vBuyerTitle no-error.
         release object vContentItem.
      end.
      release object vContentItems.
   end.

end.

{&CommentStartNoClass}
method private void SendAnswer
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function SendAnswer returns character  
{utl\comment.i} */
(iReplyTask as component-handle,iorg as char,iTypeAnswer as character,imes as longchar ):

   define variable vContent       as component-handle no-undo.
   define variable vContentItems  as component-handle no-undo.
   define variable vSigner        as component-handle no-undo.
   define variable vSignTask      as component-handle no-undo.
   define variable vOrganization  as component-handle no-undo. 
   define variable vUserperm      as component-handle no-undo. 
   define variable vUser          as component-handle no-undo. 
   
   
   define variable vi as integer no-undo.
   
   if     itypeAnswer ne "AcceptRevocation" 
      and iReplyTask  ne ? 
   then do:
      getdesc(iReplyTask).
      vContentItems = iReplyTask:ContentItems.
      getdesc(vContentItems).
      do vi = 1 to vContentItems:count:
         getdesc(vContentItems:GetItem(vi - 1 )).
         getdesc(vContentItems:GetItem(vi - 1 ):document).
         vContent = vContentItems:GetItem(vi - 1 ):Content.
         /*vContent:comment = "отказ".*/
       /*  define variable vii as integer no-undo.
         define variable txt as longchar no-undo.
         do vii = 1 to 800:
            txt = txt + "1234567890" no-error.
         end.
         */
         vContent:comment =  imes.
         /*   не нужно должно быть подпи серетификатом */
        
        getdesc(vContent).
         vSigner = vContent:Signer.
         getdesc(vSigner).
         vOrganization = mDiadocConnection:GetOrganizationById(iOrg) no-error.
            
         vUserperm = vOrganization:GetUserPermissions().
         define variable vJobTitle as character no-undo.
         vJobTitle = vUserperm:JobTitle.
         if    vJobTitle eq ?
            or vJobTitle eq ""
         then
            vJobTitle = mDiadocConnection:Certificate:JobTitle.
         release object vUserperm.
         release object vOrganization.     
         vUser = mDiadocConnection:GetMyUser().
         getdesc(vUser).
         vSigner:Surname    = vUser:FirstName.
         vSigner:FirstName  = vUser:LastName.
         vSigner:Patronymic = vUser:MiddleName.
         vSigner:JobTitle   = vJobTitle.
         vSigner:Inn        = mDiadocConnection:Certificate:inn.
         getdesc(vSigner).
         
         release object vUser.
         release object vSigner.
         release object vContent.
      end.
      release object vContentItems.
   end.
   
end.

{&CommentStartNoClass}
method public void Send
(iDocument as component-handle,iTypeAnswer as character,icomment as character,output oOperationCode as character  ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure send:
   define input  parameter iDocument as component-handle no-undo.
   define input  parameter iTypeAnswer as character no-undo.
   define input  parameter icomment as character no-undo. 
   define output parameter oOperationCode as character no-undo.
{utl\comment.i} */
   define variable vReplyTask    as component-handle no-undo.
   define variable vTypeAnswer as character no-undo.
   define variable vTypeAnswer_orig as character no-undo.
   define variable Vmes as longchar  no-undo.
   define variable vOrganizationGuid as character no-undo.
   define variable vDocumentid as character no-undo.
   define variable vi as integer no-undo.
   if iDocument ne ? 
   then do:
      case iTypeAnswer:
         when "Подписания"                 then vTypeAnswer =  "AcceptDocument".
         when "отказ подписи"              then vTypeAnswer =  "RejectDocument".
         when "запрос коректировки"        then vTypeAnswer =  "CorrectionRequest".
         when "Запрос анулирование"        then vTypeAnswer =  "RevocationRequest".
         when "Подтверждение анулирования" then vTypeAnswer =  "AcceptRevocation".
         when "отказ анулирования"         then vTypeAnswer =  "RejectRevocation".
         when "подписать с расхождениями"  then vTypeAnswer =  "AcceptDocumentWithDisc".
         when "подписать товар не принят"  then vTypeAnswer =  "AcceptDocumentNotAccepted".
         otherwise vTypeAnswer = iTypeAnswer .
      end case.
      
      vTypeAnswer_orig = vTypeAnswer.
      if    vTypeAnswer =  "AcceptDocumentWithDisc"
         or vTypeAnswer =  "AcceptDocumentNotAccepted"
      then
         vTypeAnswer =  "AcceptDocument".  
      if mDiadocConnection:AuthenticateType ne "Certificate" then return error "не сертификат".
      vReplyTask = iDocument:CreateReplySendTask2(vTypeAnswer).
      vOrganizationGuid = iDocument:OrganizationGuid.
      vDocumentid     = iDocument:DocumentId.
      getdesc(iDocument).
         
      if vTypeAnswer =  "AcceptDocument" 
      then do:
         define variable vtitletype as character no-undo.
         vTitleType = GetDocTitleType(vOrganizationGuid,iDocument:TypeNamedId,iDocument:DocumentFunction,iDocument:Version).
         &if "{1}" = "class"
         &then
             sendAccept  (vTypeAnswer_orig,
                          vReplyTask,
                          iDocument:OrganizationGuid,
                          iDocument:WorkflowId,
                          vtitletype,
                          output oOperationCode ) no-error.
         &else
         run sendAccept in this-procedure (vTypeAnswer_orig,
                                           vReplyTask,
                                           iDocument:OrganizationGuid,
                                           iDocument:WorkflowId,
                                           vtitletype,
                                           output oOperationCode ) no-error.
         &endif
         if error-status:error
         then
            return error "".
      end.
      else do:
         
    /*         if vDocumentid ne "1ee3b874-3819-4eca-8f50-47232a192c36057cd390-615f-4942-b8b9-7272ae719422" then next.*/
         find first utd where utd.DocumentExt     = vDocumentid
                          and utd.OrganizationExt = vOrganizationGuid
         no-lock no-error.
         if available utd
         then do:
            if   vTypeAnswer ne  "CorrectionRequest"
                and vTypeAnswer ne  "RejectDocument"
            then 
               icomment = "".  
            if vTypeAnswer eq  "RejectDocument"
            then do:
               if icomment eq ? or icomment eq "" then icomment = utd.comment.
               Vmes = (if icomment ne ? and icomment ne "" then icomment + "," else "" ) + GetErrForUtdStr(utd.db-num,utd.doc-id,?).
            end.
            else do:
                Vmes = GetErrForUtd(utd.db-num,utd.doc-id,?) .
                Vmes = GetErrComText(icomment,Vmes).
            end.
            if mFlaftest
            then do:
               output stream File-stream to "SendAnswer.txt" .
               put stream File-stream unformatted string(Vmes).
               output stream File-stream close.
               message "сформирован файл " search("SendAnswer.txt")
               view-as alert-box.
               return error "ничего не отправляем".
            end.
            else  
               SendAnswer(vReplyTask,iDocument:OrganizationGuid, iTypeAnswer,Vmes) no-error.
            if error-status:error
            then
               return error "".
            end.
         end.
      if not mFlaftest
      then do:
         getdesc(vReplyTask).
          vReplyTask:Send() no-error.
         if error-status:num-messages > 0 then do:
            Puterr(substitute("Error Ошибка при выполнение действия по документу &1. ", vDocumentid )).
               
            release object vReplyTask.
            return error "Ошибка при выполнение дейстия с документом".
         end.
         /*
         define variable vAsyncResult   as component-handle no-undo.
   
         vAsyncResult = vReplyTask:SendAsync() no-error.
         getdesc(vAsyncResult).
         pause 5.
         getdesc(vAsyncResult).
         
         release object vReplyTask.
         
         message vAsyncResult:IsCompleted vAsyncResult:Result
         view-as alert-box.
         message vAsyncResult:IsCompleted vAsyncResult:Result
         view-as alert-box.
         getdesc(vAsyncResult).
         message 555
         view-as alert-box.
         */
         /*do trans:
            find first utd where utd.DocumentExt     = vDocumentid
                             and utd.OrganizationExt = vOrganizationGuid
            exclusive-lock no-error.
            if available utd
            then do:
               case iTypeAnswer:
                  when   "AcceptDocument"               then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                  when   "RejectDocument"               then utd.sts-edi = if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:SignatureAutoRejected:KeyIntDB
                                                                           then ObjSrv:Env:Utd:Sts:edi:sendAutoRejected:KeyIntDB
                                                                           else ObjSrv:Env:Utd:Sts:edi:sendRejected:KeyIntDB.
                  when   "CorrectionRequest"            then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendAdjustment:KeyIntDB.
/*                  when   "RevocationRequest"          then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:CorrectionRequested:KeyIntDB.*/
                  when   "AcceptRevocation"             then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRevocation:KeyIntDB.
                  when   "RejectRevocation"             then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRevocation:KeyIntDB.
                  when   "AcceptDocumentWithDisc"       then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                  when   "AcceptDocumentNotAccepted"    then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                   
               end case.
               if iTypeAnswer eq "CorrectionRequest"
               then
                  utd.sts = ObjSrv:Env:Utd:Sts:th:CorrectionRequested:KeyIntDB.
            end.
         end.*/ 
      end.
   end.
end.

{&CommentStartNoClass}
method public void SendReceiptsAsync 
(idb-num as integer ,
 idoc-id as integer  ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure SendReceiptsAsync :
define input  parameter idb-num as integer no-undo.
define input  parameter idoc-id as integer no-undo. 
{utl\comment.i} */
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   if getdocum (idb-num, idoc-id, output vDocument ) eq ""
   then do:
      PutMes(substitute("Обработка подписи ИОП по документу ДБ &1 ID &2",idb-num,idoc-id)).
      define variable vAsyncResult   as component-handle no-undo.
      vAsyncResult = vDocument:SendReceiptsAsync().
      release object vDocument.
      PutMes(substitute("Запущена асинхронная обработка ИОП по документу ДБ &1 ID &2",idb-num,idoc-id)).
      find first utd where utd.db-num eq idb-num 
                       and utd.doc-id eq idoc-id
      exclusive-lock no-error.
      if available utd
      then do:
         if getdocum (idb-num, idoc-id, output vDocument) eq "" /* Получим обновленный объект */
         then do:
            {&CommentStartClass} run {utl\comment.i} */ UpdateUTDInformOne(vDocument). 
            release object vDocument.
         end.
         utd.flagRI = yes.
        /* if utd.sts = ObjSrv:Env:Utd:Sts:TH:loaderror:KeyIntDB
         then 
            SaturateAndCheckUTD( utd.db-num, utd.doc-id). */ 
/* vAsyncResult:IsCompleted vAsyncResult:Result
  */    end.
      PutMes(vAsyncResult:Result).
      release object vAsyncResult.
      if getdocum (idb-num, idoc-id, output vDocument) eq "" /* Получим обновленный объект */
      then do:
         {&CommentStartClass} run {utl\comment.i} */ UpdateUTDInformOne(vDocument).
         release object vDocument.
      end.
   end.

end.

{&CommentStartNoClass}
method public void SendAnsver
(idb-num as integer ,
 idoc-id as integer, 
 iTypeAnswer as character,
 iComment as character   ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure SendAnsver:
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define input  parameter iTypeAnswer as character no-undo.
   define input  parameter iComment as character no-undo. 
{utl\comment.i} */
   define variable vSendcode as character no-undo.
   define variable vDocument as component-handle no-undo.
   define buffer utd for utd.
   if getdocum (idb-num, idoc-id, output vDocument ) eq ""
   then do:
      PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2",idb-num,idoc-id,iTypeAnswer)).
      {&CommentStartClass} run {utl\comment.i} */  SendReceiptsAsync(idb-num,idoc-id).
      /*if     logical(vDocument:AmendmentRequested)
         and iTypeAnswer eq "CorrectionRequest"
      then 
         iTypeAnswer = "RejectDocument".*/
         find first utd where utd.db-num eq idb-num
                                and utd.doc-id eq idoc-id
               no-lock.
      if      (not utd.AmendmentRequested
          and  iTypeAnswer eq "CorrectionRequest")
          or iTypeAnswer ne "CorrectionRequest"
      then do:
         {&CommentStartClass} run {utl\comment.i} */  send in this-procedure (vDocument,iTypeAnswer,iComment,output vSendcode) no-error.
         if error-status:error
         then do:
            release object vDocument.
            return error return-value.
         end.
         PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2 Завершина",idb-num,idoc-id,iTypeAnswer)).
      end.
      else
         PutMes(substitute("Обработка запроса &3 по документу ДБ &1 ID &2 пропущена",idb-num,idoc-id,iTypeAnswer)).
      
      release object vDocument.
      if     vSendcode ne ?
         and vSendcode ne ""
      then
         setattrutd (idb-num,idoc-id,"sendcode",vSendcode).
      if not mFlaftest
      then do:
         if getdocum (idb-num, idoc-id, output vDocument) eq "" /* Получим обновленный объект */
         then do:
            {&CommentStartClass} run {utl\comment.i} */  UpdateUTDInformOne(vDocument). 
            release object vDocument.
         end.
         if    iTypeAnswer eq "CorrectionRequest" /* запрошена коректировка */ 
            or iTypeAnswer eq "AcceptRevocation" /* подпись ануляции */
            or iTypeAnswer eq "RejectRevocation" /* отказано ануляции */
            or iTypeAnswer eq "RejectDocument" /* отказ по документу */
            or iTypeAnswer eq "AcceptDocument" /* подписать документ*/
            or iTypeAnswer eq "AcceptDocumentWithDisc"
            or iTypeAnswer eq "AcceptDocumentNotAccepted"
         then do:
            if getdocum (idb-num, idoc-id, output vDocument) eq "" /* Получим обновленный объект */
            then do:
               {&CommentStartClass} run {utl\comment.i} */ UpdateUTDInformOne(vDocument). 
               release object vDocument.
            end.
            if   not mFlaftest  
               
            then do trans:
               find first utd where utd.db-num eq idb-num
                                and utd.doc-id eq idoc-id
                                and utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh /*только не по завершенным документам*/
               exclusive-lock no-error.
               if available utd
               then do :
                  
                  case iTypeAnswer:
                     when   "AcceptDocument"               then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                     when   "RejectDocument"               then utd.sts-edi = if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB
                                                                              then ObjSrv:Env:Utd:Sts:edi:sendAutoRejected:KeyIntDB
                                                                              else ObjSrv:Env:Utd:Sts:edi:sendRejected:KeyIntDB.
                     when   "CorrectionRequest"            then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendAdjustment:KeyIntDB.
   /*                  when   "RevocationRequest"          then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:CorrectionRequested:KeyIntDB.*/
                     when   "AcceptRevocation"             then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRevocation:KeyIntDB.
                     when   "RejectRevocation"             then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRevocation:KeyIntDB.
                     when   "AcceptDocumentWithDisc"       then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                     when   "AcceptDocumentNotAccepted"    then utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:sendRecipient:KeyIntDB.
                      
                  end case.
                  if iTypeAnswer eq "CorrectionRequest"
                  then do:
                     utd.sts = ObjSrv:Env:Utd:Sts:th:CorrectionRequested:KeyIntDB.
                     if     utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh
                     then do:
                        {&CommentStartClass} run {utl\comment.i} */  SendAnsver(idb-num,idoc-id,"AcceptDocumentWithDisc",iComment).
                     end.
                  end.
               end.
            end.
         end.
      end.
   end.
end.

{&CommentStartNoClass}
method public void SendResponse
(idb-num as integer ,
 idoc-id as integer,
 iAccept as logical,
 itestMod as logical):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure  SendResponse :
   define input  parameter idb-num as integer no-undo.
   define input  parameter idoc-id as integer no-undo.
   define input  parameter iAccept as logical no-undo.
   define input  parameter itestMod as logical no-undo.
{utl\comment.i} */
    define buffer utd for utd.
    define buffer buf_utd for utd.
    itestMod = not itestMod.
    
    define variable vreturn as logical no-undo.
    find first utd where utd.db-num eq idb-num
                     and utd.doc-id eq idoc-id
    no-lock no-error.
    if available utd
    then do:
       if utd.EDocType              = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB
       then do:
          if     iAccept
             and utd.sts-edi     ne objSrv:Env:Utd:sts:edi:WithRecipientSignature:KeyIntDB
             and utd.sts-edi     ne objSrv:Env:Utd:sts:edi:WithRecipientPartiallySignature:KeyIntDB
          then do:
             vreturn = yes.
             if itestMod
             then do:
                for each buf_utd where buf_utd.PackageId eq utd.PackageId
                                   and buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:ucd:KeyIntDB
                                   and buf_utd.Timestamp <= utd.Timestamp
                                   and (     buf_utd.sts-edi   eq objSrv:Env:Utd:sts:edi:WaitingForRecipientSignature:KeyIntDB
                                         or  buf_utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                                         or  buf_utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB)
                no-lock :
                   {&CommentStartClass} run {utl\comment.i} */ SendAnsver in this-procedure (buf_utd.db-num,buf_utd.doc-id,"AcceptDocument","")no-error.
                   if error-status:error then return error return-value.
                end.
                 
             end.
          end.
       end.
       else if utd.EDocType              = objSrv:Env:Utd:EDocType:returns:KeyIntDB
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                define variable vsend as logical no-undo.
                vsend = logical(getattrutdex (idb-num,idoc-id,"returnSend","no")).
                if vsend
                then
                   return error "Документ был отправлен рание. Повторная отправка возможна через сервис.".
                 
                find first buf_utd where buf_utd.OrganizationExt eq utd.parentOrganizationExt
                                     and buf_utd.DocumentExt     eq utd.parentDocumentExt
                no-lock no-error.
                if available buf_utd
                then do:
                   if getattrutd (idb-num,idoc-id,"TypeUTD") ne "счфДОП"
                   then do:
                      {&CommentStartClass} run {utl\comment.i} */ SendAnsver in this-procedure (buf_utd.db-num,buf_utd.doc-id,"CorrectionRequest",GetErrForUtd(utd.db-num,utd.doc-id,"return"))no-error.
                      if error-status:error then return error return-value.
                   end.
                end.
                run bge/sendutd.p(
                     parparentproc,
                     mDiadocConnection:Certificate:Thumbprint,
                     idb-num,
                     idoc-id) no-error.
                if error-status:error then return error return-value.
                do trans :
                    
                   find first utd where utd.db-num eq idb-num
                                    and utd.doc-id eq idoc-id
                   exclusive-lock no-error.
                   utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:WithRecipientSignature:KeyIntDB.
                   setattrutd (idb-num,idoc-id,"returnSend","yes").
                end.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB /*"Требует подписи ИОП"*/
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then
                {&CommentStartClass} run {utl\comment.i} */ SendReceiptsAsync(idb-num,idoc-id).
          end.
          /*else
             vreturn = no.*/
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:Verification:KeyIntDB /*проверка"*/
       then do:
          if not iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                {&CommentStartClass} run {utl\comment.i} */ SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
          /*else
             vreturn = no.*/
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:RequestsMyRevocation:KeyIntDB /*"Получено предложение об аннулировании документа"*/
       then do:
          vreturn = yes.
          if iAccept
          then do:
             if itestMod
             then do:
                {&CommentStartClass} run {utl\comment.i} */ SendAnsver in this-procedure (idb-num,idoc-id,"AcceptRevocation","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
          else do:
             if itestMod
             then do:
                {&CommentStartClass} run {utl\comment.i} */ SendAnsver in this-procedure (idb-num,idoc-id,"RejectRevocation","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if   utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:Changed:KeyIntDB
              or utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB  /*"Ожидается ответное действие получателя"*/
       then do:
          vreturn = yes.
          if iAccept
          then do:
             if itestMod
             then do:
                {&CommentStartClass} run {utl\comment.i} */ SendAnsver in this-procedure (idb-num,idoc-id,"AcceptDocument","")no-error.
                if error-status:error then return error return-value.
             end.
          end.
          else do:
             if itestMod
             then do:
                {&CommentStartClass} run {utl\comment.i} */ SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB /*"Подписать отказ"*/
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                {&CommentStartClass} run {utl\comment.i} */ SendAnsver in this-procedure (idb-num,idoc-id,"RejectDocument","") no-error.
                if error-status:error then return error return-value.
             end.
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:SignatureAdjustment:KeyIntDB /*"Подписать коректировку"*/
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                {&CommentStartClass} run {utl\comment.i} */ SendAnsver in this-procedure (idb-num,idoc-id,"CorrectionRequest","")no-error.
                if error-status:error then return error return-value.
             end.   
          end.
       end.
       else if utd.sts-edi eq  ObjSrv:Env:Utd:Sts:edi:SignatureNotAccepted:KeyIntDB /*"Подписать с отказом"*/
       then do:
          if iAccept
          then do:
             vreturn = yes.
             if itestMod
             then do:
                {&CommentStartClass} run {utl\comment.i} */ SendAnsver in this-procedure (idb-num,idoc-id,"AcceptDocumentNotAccepted","")no-error.
                if error-status:error then return error return-value.
             end.   
          end.
       end.
       if itestmod and not vreturn
       then do:
          PutMes (substitute('Error Документ с № "&5" в.н. "&2" по БД "&1" в статусе "&3" выполнить операцию "&4" не возможно.',
                             utd.db-num,
                             utd.doc-id,
                             ObjSrv:Env:Utd:Sts:EDI:GetLabel(utd.sts-edi),
                             if iAccept then "Подписать" else "Отказать",
                             utd.DocumentNumber)
                             ).
       end.
    end.
    return string(vreturn).
end.
