{&CommentStartNoClass}
method public void CRnewDocum
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function CRnewDocum return character
{utl\comment.i} */
(
iOrgGuid as character, /*vdocument:Organization:Guid */ 
iContGuid as character,/*vdocument:Counteragent:Guid */
iTypeUTD as character, /* "СЧФДОП", "Доп" */  
/* vdocument as component-handle,*/
 iFile as character 
 ):

/*(Organization, Counteragent)*/
define variable vOrganization as component-handle no-undo.
define variable vSendTask as component-handle no-undo.
/*define variable vDocumentToSend as component-handle no-undo.*/
    vOrganization = mDiadocConnection:GetOrganizationById(iOrgGuid ) no-error.
       
    if vOrganization ne ?
    then do:
    /* Создание задания на отправку */
       vSendTask = vOrganization:CreatePackageSendTask2().
       getdesc(vSendTask).
/*       vSendTask:CounterAgentId = iDocument:Counteragent:Id.*/
/* идентификатор получателя. Если получатель совпадает с отправителем, то документ будет отправлен как внутренний. Не влияет на заполнение контента*/
   
/* идентификатор подразделения получателя*/
/*   vSendTask:ToDepartmentId = "2BM-9677457292-967701000-201912060645095349255". /* ИдПол */*/
/* идентификатор подразделения отправителя */
/*   vSendTask:FromDepartmentId = "2BM-9642119246-964201000-201912060658225017772". /* ИдОтпр */*/
       /* Добавление документа для заполнения контента средствами компоненты */
       /* Предполагаем, что процедура заполнения контента уже существует */
/*       vDocumentToSend = vSendTask:AddDocument(, , ).*/
/*       getdesc(vDocumentToSend).*/
/*       vDocumentToSend:Comment = "Это УПД с заполнением контента средствами компоненты".*/
       vSendTask:CounteragentId = iContGuid  .
       vSendTask:AddDocumentFromFile("UniversalTransferDocument", iTypeUTD, "utd820_05_01_01", iFile).
       vSendTask:Send()no-error.
       if error-status:num-messages > 0 then do:
          PutErr("ERROR Ошибка отправки документа").
          return error "ERROR Ошибка отправки документа".
       end.
       else do:
          PutMes("Документ отправлен успешно.").
          message "Документ отправлен успешно."
          view-as alert-box.
       end.
       release object vSendTask.
            
  
/*       ЗаполнитьДинамическийКонтентДокумента(First_DocumentToSend.Content);

    // Добавление документа УПД с контентом, взятым из файла
    Second_DocumentToSend = SendTask.AddDocumentFromFile("UniversalTransferDocument", "СЧФДОП", "utd820_05_01_01", "С:\\Moй УПД.xml");
    Second_DocumentToSend.Comment = "Это УПД с контентом, загруженным из файла";

    // Добавление неформализованного документа
    Third_DocumentToSend = SendTask.AddDocumentFromFile("Nonformalized", "default", "v1", "С:\\Документ.pdf");
    Third_DocumentToSend.Comment = "Это неформализованный документ";
    MetaDataItem = Third_DocumentToSend.AddMetadata();
    MetaDataItem.Key   = "FileName";
    MetaDataItem.Value = "Имя Файла Для Передачи.xml";

    ОтправленныеДокументы = SendTask.Send();

КонецПроцедуры
*/
      release object vOrganization .  
   end.
   
end.
