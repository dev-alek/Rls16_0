define temp-table tt-recid no-undo
          field orgid as char
          field docid as char
          field parent as char
          field stamp as datetime
          index pi orgid docid 
          index parent parent  stamp.

/*запуск отправки служебных сообщение повсему письмам подключеных ящиков*/
{&CommentStartNoClass}
method public void ProcessSystemMessStart 
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function ProcessSystemMessStart return component-handle 
{utl\comment.i} */
(IStartStop as logical):
   if mDiadocConnection eq ? then
   define variable vOrganizationList as component-handle no-undo.
   define variable vOrganization as component-handle no-undo.
   define variable vReceiptGenerationProcess as component-handle no-undo.
   define variable vi as integer no-undo.
   if mDiadocConnection ne ? 
   then do:
      vOrganizationList = mDiadocConnection:GetOrganizationList().
   
       /* Получение конкретной организации */
       do vi = 1 to vOrganizationList:count:
          vOrganization = vOrganizationList:GetItem(vi - 1 ). 
          vReceiptGenerationProcess = vOrganization:GetReceiptGenerationProcess().
          release object vOrganization.
          if IStartStop
          then
             vReceiptGenerationProcess:Start().
          else
             vReceiptGenerationProcess:Stop().
          
          release object vReceiptGenerationProcess.
       end.
       release object vOrganizationList.
   end.
end.

{&CommentStartNoClass}
method public void changeIdToGuid (iOrganization as component-handle):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure  changeIdToGuid :
define input  parameter iOrganization as component-handle no-undo. 
{utl\comment.i} */
   define variable vOrgId   as character no-undo.
   define variable vOrgGuid as character no-undo.
   define buffer utd for utd.
   assign
      vOrgId   = iOrganization:id.
      vOrgGuid = iOrganization:guid
   no-error.
    
   if     error-status:num-messages eq 0
      and vOrgId   ne ""
      and vOrgGuid ne ""
   then do:
      define variable vfirst as logical no-undo init yes.
      repeat preselect each utd where utd.OrganizationExt = vOrgId exclusive-lock:
         find next utd.
         if vfirst
         then do:
            PutMes("Конвертация документов").
            vfirst = no.
         end.
/*         myseqUtd = ?. /* отключаем групировку истории*/*/
         utd.OrganizationExt = vOrgGuid.
         validate utd.
         PutMes(substitute ("У документа &1 изменен индификатор организации с &2 на &3",ub.utd.DocumentNumber,vOrgId,utd.OrganizationExt)).
            
      end.
      if not vfirst
      then
         PutMes("Конвертация документов завершина.").
         
   end.   
end.

{&CommentStartNoClass}
method public void getNewUpd ():
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure getNewUpd :
{utl\comment.i} */
   define variable VLastDate as date no-undo init ?.
   define variable vDocument     as component-handle no-undo.
   define variable vYear         as integer no-undo.
   define variable vMonth        as integer no-undo.
   define variable vDay          as integer no-undo.
   define variable vBegLoadDate  as date    no-undo. /* Начальная дата периода, в котором разрешено обновлять документы */
   define variable vLastLoadDate as date    no-undo. /* Последняя дата загрузки документов */
   define buffer utd for utd.
   VLastDate = date( getextAttr({&attr-esys-diadoc-lastload})) no-error.
   find first sys-ctrl no-lock.
   if VLastDate eq ?
   then
      VLastDate = sys-ctrl.cut-date + 3.
   else if sys-ctrl.cut-date ne ?
   then
      VLastDate = max(VLastDate,sys-ctrl.cut-date + 3) .
   vLastLoadDate = VLastDate. /* Запоминаем последнюю дату загрузки документов */
   for each tt-recid:
      delete tt-recid.
   end.
   if chekStop() then return "Остановка пользователем".
   {&CommentStartClass} run {utl\comment.i} */ UpdateUTDInform(if VLastDate eq ? then today - 365 else VLastDate - 3,today + 1,output VLastDate).
   if chekStop() then return "Остановка пользователем".
   if VLastDate ne ?
   then do:
      setextAttr({&attr-esys-diadoc-lastload},string(VLastDate)).
/* Получаем дату vBegLoadDate, сдвинутую на 2 месяца назад */
      vYear = year(vLastLoadDate).
      vMonth = month(vLastLoadDate) - 2.
      vDay   = day(vLastLoadDate).
      if vMonth <= 0 then
         assign
            vMonth = vMonth + 12
            vYear  = vYear - 1
            .
      repeat:
         vBegLoadDate = date(vMonth, vDay, vYear) no-error. 
         if error-status:error then 
            vDay = vDay - 1.
         else
            leave.
      end.
      vBegLoadDate = vBegLoadDate + 1.
   end.
   block-rec:
   for each tt-recid break by tt-recid.parent descending by tt-recid.stamp descending :
      if  tt-recid.parent eq ""
      then next  block-rec.
      if first-of (tt-recid.parent)
      then do:
         for each utd where utd.PackageId eq tt-recid.parent
         no-lock break by utd.PackageId descending by utd.Timestamp descending :
            if chekStop() then return "Остановка пользователем".
            if utd.EDocType = objSrv:Env:Utd:EDocType:UCD:KeyIntDB
            then do:
               subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
               MySeqUtd = ?.
          
               CrEdoc(utd.PackageId,utd.Timestamp).
               unsubscribe "getNextseq".
               next block-rec.
            end.
         end.
      end.
   end.
   PutMes("Обновление информации по ранее загруженным документам за период c " + (if vBegLoadDate <> ? then
                                                                                     string(vBegLoadDate)
                                                                                  else "?")
                                                                                  + " по " + 
                                                                                  (if vLastLoadDate <> ? then
                                                                                      string(vLastLoadDate)
                                                                                   else
                                                                                      "?")
                                                                                   ).
                                                                                      
   define variable vobj as character no-undo.
   vobj = getExtAttr({&attr-esys-host-code}).
   if vobj ne "0"
   then
       for each utd where utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh  
                      and utd.host-code eq int(vobj)
                      and (   utd.EDocType eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                           or utd.EDocType eq objSrv:Env:Utd:EDocType:UCD:KeyIntDB
                           )
       no-lock break by utd.OrganizationExt:
          if chekStop() then return "Остановка пользователем".
          /* Не обновляем документы, полученные ранее 2 месяцев от даты последнего загруженного документа */
          if vBegLoadDate <> ? and utd.DocumentDate < vBegLoadDate then next. 
          find first tt-recid where tt-recid.orgid = utd.OrganizationExt
                                and tt-recid.docid = utd.DocumentExt
                 no-error.
          if     not available tt-recid
             and getdocum (utd.db-num, utd.doc-id, output vDocument) eq "" /* Получим обновленный объект */
          then do:
             {&CommentStartClass} run {utl\comment.i} */ UpdateUTDInformOne(vDocument). 
             release object vDocument no-error.
          end.
       end.
   
   vobj = getExtAttr({&attr-esys-obj}).
   if vobj ne ""
   then
       for each utd where utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatFinesh  
                      and utd.obj-type + string(utd.obj-code) eq vobj
       no-lock break by utd.OrganizationExt:
          if chekStop() then return "Остановка пользователем".
          /* Не обновляем документы, полученные ранее 2 месяцев от даты последнего загруженного документа */
          if vBegLoadDate <> ? and utd.DocumentDate < vBegLoadDate then next.           
          find first tt-recid where tt-recid.orgid = utd.OrganizationExt
                                and tt-recid.docid = utd.DocumentExt
                 no-error.
          if     not available tt-recid
             and getdocum (utd.db-num, utd.doc-id, output vDocument) eq "" /* Получим обновленный объект */
          then do:
             {&CommentStartClass} run {utl\comment.i} */ UpdateUTDInformOne(vDocument). 
             release object vDocument no-error.
          end.
       end.
end.

{&CommentStartNoClass}
method public void sendauto ():
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure  SendAuto:
{utl\comment.i} */
 define variable vOrganization as component-handle no-undo.
 define variable vOrganizationList as component-handle no-undo.
 define variable vi as integer no-undo.
   
   if mDiadocConnection eq ?
   then do:
      message "По данному сертификату не удалось подключиться к Диадок" 
      view-as alert-box.
   end.
   else do:
      for each tt-recid:
         delete tt-recid.
      end.
      vOrganizationList = mDiadocConnection:GetOrganizationList() no-error.
      if vOrganizationList eq ? then return error ?.
      vi = vOrganizationList:Count()no-error.
      if vi eq ?
      then
         return error ?.
   
      do vi = 1 to vOrganizationList:Count() :
   /*     Получение конкретной организации*/
         vOrganization = vOrganizationList:GetItem(vi - 1 ).
         define variable vorgid as character no-undo.
         vorgid = vOrganization:guid.
         for each utd where utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                        and utd.host-code eq v-cntxt-host-code-obj
                        and utd.OrganizationExt eq vorgid
         no-lock:
            {&CommentStartClass} run {utl\comment.i} */ SendReceiptsAsync(utd.db-num,utd.doc-id).
         end.
         /*
         for each utd where utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB
                        and utd.host-code eq v-cntxt-host-code-obj
                        and utd.OrganizationExt eq vorgid
         no-lock:
            run SendResponse in this-procedure (utd.db-num,utd.doc-id,yes,no).
         end.
         */
     /*    for each utd where utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:SignatureNotAccepted:KeyIntDB
                        and utd.host-code eq v-cntxt-host-code-obj
                        and utd.OrganizationExt eq vorgid
         no-lock:
            run SendResponse in this-procedure (utd.db-num,utd.doc-id,yes,no).
         end.
     */
         for each utd where utd.sts-edi   eq ObjSrv:Env:Utd:Sts:edi:HaveToCreateReceipt:KeyIntDB
                        and utd.host-code eq v-cntxt-host-code-obj
                        and utd.OrganizationExt eq vorgid
         no-lock:
            {&CommentStartClass} run {utl\comment.i} */ updOneUTD(utd.db-num,utd.doc-id).
         end.
      end.
   end.
end.
