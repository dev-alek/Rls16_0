block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на изменение таблицы abc-analysis-doc-attr

Автор: 
Дата создания: 
Author: 
Creation date: 

*/

&Glob main-tbl utd
trigger procedure for write of ub.{&main-tbl}
  new buffer new-{&main-tbl}
  old buffer old-{&main-tbl}
.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на изменение таблицы abc-analysis-doc-attr".



{ trg/trghistnws.i } 
{ gbl/objsrv.i }
def var utdTHSts as class ibs.th.str.utd.sts.th no-undo.
def var utdEDISts as class ibs.th.str.utd.sts.edi no-undo.
define variable volddb-num as integer no-undo.
define variable volddoc-id as integer no-undo.
{ gbl/key-rec.i }
{str/utd-err.i}
{str/utd.i}
define buffer buf_utd for ub.utd.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if available (old-utd) and old-utd.doc-id = 0 and not g#news
  then do:
    new-{&main-tbl}.db-num = g#db-num.
    new-{&main-tbl}.doc-id = next-value (s-utd-doc-code, {&db-name_schema}).
    new-{&main-tbl}.LoadDate = date (now).
    new-{&main-tbl}.LoadTime = time.
    new-{&main-tbl}.ModifyDate = date (now).
    new-{&main-tbl}.ModifyTime = time.
    
  end.
  if new-{&main-tbl}.DocumentExt eq "" or new-{&main-tbl}.DocumentExt eq ?
  then
     new-{&main-tbl}.DocumentExt = string(new-{&main-tbl}.db-num) + "-" +  string(new-{&main-tbl}.doc-id).
  if new-{&main-tbl}.Timestamp eq ?
  then
     new-{&main-tbl}.Timestamp = now.
  utdTHSts = objSrv:Env:Utd:Sts:TH.
  utdEDISts = objSrv:Env:Utd:Sts:EDI.
  
  define variable vOldSts as integer no-undo.
  vOldSts = new-{&main-tbl}.sts-edi.
  
   
  if   (  (    g#db-num = new-{&main-tbl}.db-num
          and g#news )
         or (    g#db-num ne new-{&main-tbl}.db-num
             and not g#news ))
     and  new-{&main-tbl}.EDocType ne objSrv:Env:Utd:EDocType:returns:KeyIntDB
  then
     assign
        new-{&main-tbl}.OrganizationExt = old-{&main-tbl}.OrganizationExt
        new-{&main-tbl}.DocumentExt     = old-{&main-tbl}.DocumentExt
     .
     
  
  if not g#news  
  then do:
     if new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:edoc:KeyIntDB
     then do:
        if new-{&main-tbl}.sts-edi ne utdEDISts:WaitingForRecipientSignature:KeyIntDB
        then
        block-ucd:
        for each buf_Utd where buf_utd.PackageId eq new-{&main-tbl}.PackageId
                         and buf_utd.EDocType    eq objSrv:Env:Utd:EDocType:ucd:KeyIntDB
                         and buf_utd.Timestamp   le new-{&main-tbl}.Timestamp
                         and buf_utd.sts-edi     ne utdEDISts:WithRecipientSignature:KeyIntDB
                         and buf_utd.sts-edi     ne utdEDISts:WithRecipientPartiallySignature:KeyIntDB
                         and buf_utd.sts-edi     ne utdEDISts:RecipientSignatureRequestReject:KeyIntDB
        no-lock:
           assign 
              new-{&main-tbl}.sts-edi = old-{&main-tbl}.sts-edi
           .
           leave block-ucd.
        end.
        if new-{&main-tbl}.sts-edi eq  utdEDISts:WithRecipientSignature:KeyIntDB
           or new-{&main-tbl}.sts-edi eq  utdEDISts:WithRecipientPartiallySignature:KeyIntDB
        then
           new-{&main-tbl}.sts = utdTHSts:Confirmed:KeyIntDB.
     end.
     else if not GetLastUTDinPack (new-{&main-tbl}.db-num, new-{&main-tbl}.doc-id, volddb-num, volddoc-id)
        and    new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:utd:KeyIntDB
     then
         new-{&main-tbl}.sts-edi =   utdEDISts:Changed:KeyIntDB.
      
     else if    new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
             or new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:Receipt:KeyIntDB
             or new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:LK_RECEIPT:KeyIntDB
             or new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
         
     then
        new-{&main-tbl}.sts-edi eq  utdEDISts:RecipientResponseStatusNotAccep:KeyIntDB.
     else if new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:returns:KeyIntDB
     then do:
         find first buf_utd where buf_utd.OrganizationExt eq new-{&main-tbl}.parentOrganizationExt
                              and buf_utd.DocumentExt     eq new-{&main-tbl}.parentDocumentExt
                   no-lock no-error.
         if     avail buf_utd
            and buf_utd.sts-edi               = utdEDISts:RecipientSignatureRequestReject:KeyIntDB
            and new-{&main-tbl}.parentDocumentExt     ne ""
            and new-{&main-tbl}.parentOrganizationExt ne ""
         then           
            new-{&main-tbl}.sts-edi = utdEDISts:WithRecipientSignature:KeyIntDB.
         else
            new-{&main-tbl}.sts-edi eq  utdEDISts:RecipientResponseStatusNotAccep:KeyIntDB.
         if new-{&main-tbl}.sts             = ObjSrv:Env:Utd:Sts:th:NewStatus:KeyIntDB
         then do: /* оставим без изменений */
         end.
         else if    new-{&main-tbl}.CounteragentId  eq ?
            or new-{&main-tbl}.CounteragentId  eq ""
            or new-{&main-tbl}.OrganizationExt eq ?
            or new-{&main-tbl}.OrganizationExt eq ""
         then
            new-{&main-tbl}.sts             = ObjSrv:Env:Utd:Sts:th:RequireFilling:KeyIntDB.
         else if new-{&main-tbl}.sts             = ObjSrv:Env:Utd:Sts:th:RequireFilling:KeyIntDB
         then
            new-{&main-tbl}.sts             = ObjSrv:Env:Utd:Sts:th:SignatureRequired:KeyIntDB.
          
      end.
      else if new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:utd:KeyIntDB
              or new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:ucd:KeyIntDB
      then do:
         if     (new-{&main-tbl}.sts-edi ne  utdEDISts:AutoRejected:KeyIntDB
                  and new-{&main-tbl}.sts-edi < utdEDISts:StatFinesh)
            or new-{&main-tbl}.sts-edi eq ?
         then do:
            if new-{&main-tbl}.sts ne  utdTHSts:RejectionUtd:KeyIntDB
            then do:   /* пользователь отказался от документа и эти статусы мы не трогаем до полного подписания документа */
               new-{&main-tbl}.sts-edi =    utdEDISts:GetKeyIntDB(new-{&main-tbl}.RevocationStatus).
               if new-{&main-tbl}.sts-edi eq ?
               then
                  new-{&main-tbl}.sts-edi =    utdEDISts:GetKeyIntDB(new-{&main-tbl}.ReceiptStatus).
            end.
            if     new-{&main-tbl}.sts-edi < utdEDISts:StatFinesh
                or new-{&main-tbl}.sts-edi eq ?
            then do:
               if   new-{&main-tbl}.sts-edi eq  utdEDISts:SignatureAdjustment:KeyIntDB
               then
                  new-{&main-tbl}.sts-edi = new-{&main-tbl}.sts-edi.
               else if     new-{&main-tbl}.sts eq  utdTHSts:CorrectionRequested:KeyIntDB
                       and not new-{&main-tbl}.AmendmentRequested
               then
                  new-{&main-tbl}.sts-edi = utdEDISts:SignatureAdjustment:KeyIntDB.
               if new-{&main-tbl}.sts-edi eq ?
               then
                  new-{&main-tbl}.sts-edi =    utdEDISts:GetKeyIntDB(new-{&main-tbl}.RecipientResponseStatus).
               if      new-{&main-tbl}.sts-edi eq utdEDISts:WaitingForRecipientSignature:KeyIntDB
               then do:
                  if new-{&main-tbl}.sts eq  utdTHSts:RejectionUtd:KeyIntDB
                  then do:
                     if vOldSts ne ?
                     then
                        new-{&main-tbl}.sts-edi = vOldSts.
                     else
                        new-{&main-tbl}.sts-edi = old-{&main-tbl}.sts-edi.
                  end.
                  else /*if new-{&main-tbl}.sts eq  utdTHSts:LoadError:KeyIntDB
                  then
                     new-{&main-tbl}.sts-edi = utdEDISts:SignatureAdjustment:KeyIntDB. 
                  else*/  if new-{&main-tbl}.sts ne  utdTHSts:SignatureRequired:KeyIntDB
                  then
                     new-{&main-tbl}.sts-edi = utdEDISts:Verification:KeyIntDB.
               end.
            end.
            if     (   old-{&main-tbl}.sts-edi eq  utdEDISts:sendAutoRejected:KeyIntDB
                    or old-{&main-tbl}.sts-edi eq  utdEDISts:AutoRejected:KeyIntDB
                    )
               and new-{&main-tbl}.sts-edi eq  utdEDISts:RecipientSignatureRequestReject:KeyIntDB
            then do:
               new-{&main-tbl}.sts-edi = utdEDISts:SignatureAutoRejected:KeyIntDB.
              
            end.
         end.
         if      new-{&main-tbl}.sts-edi eq utdEDISts:SignatureAutoRejected:KeyIntDB
            and new-{&main-tbl}.sts      eq utdTHSts:RejectionUtd:KeyIntDB
         then 
            new-{&main-tbl}.sts = utdTHSts:Rejection:KeyIntDB.
         else if      new-{&main-tbl}.sts-edi = utdEDISts:WithRecipientSignature:KeyIntDB
                  or new-{&main-tbl}.sts-edi = utdEDISts:WithRecipientPartiallySignature:KeyIntDB
         then do:
            if can-find(first utd-attr no-lock where utd-attr.doc-id = new-{&main-tbl}.doc-id 
                                                       and utd-attr.db-num = new-{&main-tbl}.db-num 
                                                       and utd-attr.attr-code = "sendcode"
                                                       and utd-attr.attr-value = "3")
            then do:
               new-{&main-tbl}.sts = utdTHSts:Rejection:KeyIntDB.
               UnLockUTDMark(new-{&main-tbl}.db-num ,new-{&main-tbl}.doc-id, yes ).
            end.
            else if new-{&main-tbl}.sts     = utdTHSts:SignatureRequired:KeyIntDB
            then
               new-{&main-tbl}.sts = utdTHSts:AwaitingConfirmation:KeyIntDB.
         end.
         
         if     vOldSts  >= utdEDISts:StatChangLoanOnlyBeg
            and vOldSts  <= utdEDISts:StatChangLoanOnlyEnd
            and new-{&main-tbl}.sts-edi <= utdEDISts:StatFinesh
         then 
            new-{&main-tbl}.sts-edi = vOldSts.
            
         if  (    (
                  new-{&main-tbl}.sts-edi = utdEDISts:WithRecipientSignature:KeyIntDB
             or   new-{&main-tbl}.sts-edi = utdEDISts:WithRecipientPartiallySignature:KeyIntDB
             or   new-{&main-tbl}.sts-edi = utdEDISts:Changed:KeyIntDB
                  )
                  and new-{&main-tbl}.sts = utdTHSts:Rejectionutd:KeyIntDB
              )
             or new-{&main-tbl}.sts-edi = utdEDISts:RecipientSignatureRequestReject:KeyIntDB
         then
            new-{&main-tbl}.sts = utdTHSts:Rejection:KeyIntDB.
         else if      new-{&main-tbl}.sts-edi = utdEDISts:RevocationAccepted:KeyIntDB
         then
            new-{&main-tbl}.sts = utdTHSts:Canceled:KeyIntDB.
         if      new-{&main-tbl}.sts-edi = utdEDISts:AutoRejected:KeyIntDB
         then
            new-{&main-tbl}.sts = utdTHSts:RejectionUtd:KeyIntDB.
           
         if     
               (    new-{&main-tbl}.sts-edi eq utdEDISts:WithRecipientSignature:KeyIntDB
                or new-{&main-tbl}.sts-edi = utdEDISts:WithRecipientPartiallySignature:KeyIntDB)
            and (       old-{&main-tbl}.sts     eq utdTHSts:DeliveryCodeMismatch:KeyIntDB
                   or
                   (     old-{&main-tbl}.sts eq utdTHSts:CorrectionRequested:KeyIntDB
                    and integer (getattrUtd(new-{&main-tbl}.db-num,new-{&main-tbl}.doc-id,"ststhbeforeCorrection")) eq utdTHSts:DeliveryCodeMismatch:KeyIntDB
                    )
                )
         then 
            new-{&main-tbl}.sts     = utdTHSts:AwaitingConfirmation:KeyIntDB.
      end.
   end.
   if     new-{&main-tbl}.EDocType eq objSrv:Env:Utd:EDocType:ucd:KeyIntDB
      and new-{&main-tbl}.sts-edi  eq utdEDISts:WithRecipientSignature:KeyIntDB
   then do:
      new-{&main-tbl}.sts = utdTHSts:Confirmed:KeyIntDB.
      block-edoc:
      for each buf_Utd where buf_utd.PackageId eq  new-{&main-tbl}.PackageId
                         and buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:edoc:KeyIntDB
                         and buf_utd.Timestamp ge new-{&main-tbl}.Timestamp
      exclusive-lock:
         buf_utd.sts-edi = utdEDISts:WithRecipientSignature:KeyIntDB.
         validate buf_utd no-error.
         if buf_utd.sts-edi ne ObjSrv:Env:Utd:Sts:edi:WithRecipientSignature:KeyIntDB
         then
            leave block-edoc.
      end.
      
   end.
   if         new-{&main-tbl}.sts      = utdTHSts:AwaitingConfirmation:KeyIntDB
       and    (   new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:utd:KeyIntDB
               or new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:edoc:KeyIntDB)
   then
       new-{&main-tbl}.sts     = utdTHSts:Confirmed:KeyIntDB.
   if new-{&main-tbl}.sts ne old-{&main-tbl}.sts
      and new-{&main-tbl}.sts eq utdTHSts:CorrectionRequested:KeyIntDB    
   then
      setattrutd (new-{&main-tbl}.db-num,new-{&main-tbl}.doc-id,"ststhbeforeCorrection",string(old-{&main-tbl}.sts)).
   if new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB
   then
      SetLockUTDMark(new-{&main-tbl}.db-num,new-{&main-tbl}.doc-id).

   if     new-{&main-tbl}.Direction  eq 'Outbound'
      and new-{&main-tbl}.sts-edi    eq utdEDISts:WithRecipientSignature:KeyIntDB
   then do:
      define variable vIdDoc as character no-undo.
      vIdDoc = getattrutdex (new-{&main-tbl}.db-num,new-{&main-tbl}.doc-id,"id_doc_th","").
      if num-entries(vIdDoc,"_") eq 2
      then do:
         for each buf_Utd where buf_utd.db-num   eq int(entry(1,vIdDoc,"_"))
                            and buf_utd.doc-id   eq int(entry(2,vIdDoc,"_"))
                            and buf_utd.EDocType eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
         exclusive-lock:
            buf_utd.sts = utdTHSts:Confirmed:KeyIntDB.
            validate buf_utd no-error.
            
         end.
      end.
      new-{&main-tbl}.sts = utdTHSts:Confirmed:KeyIntDB.
          
   end.
   changSts(new-{&main-tbl}.db-num, new-{&main-tbl}.doc-id, old-utd.RevocationStatus , new-{&main-tbl}.RevocationStatus).
   changSts(new-{&main-tbl}.db-num, new-{&main-tbl}.doc-id, old-utd.RecipientResponseStatus , new-{&main-tbl}.RecipientResponseStatus).
   
   
   for each utd-lines where utd-lines.db-num eq  new-{&main-tbl}.db-num
                        and utd-lines.doc-id eq  new-{&main-tbl}.doc-id
                        and utd-lines.gds-code eq 0
   exclusive-lock:                    
       utd-lines.gds-code = ?.
       
   end.
   for each utd-marking-lines where utd-marking-lines.db-num eq  new-{&main-tbl}.db-num
                        and utd-marking-lines.doc-id eq  new-{&main-tbl}.doc-id
                        and utd-marking-lines.gds-code eq 0
   exclusive-lock:                    
       utd-marking-lines.gds-code = ?.
       for first marking where marking.mark     eq utd-marking-lines.mark
                           and marking.gds-code eq 0
       exclusive-lock:
          marking.gds-code = ?.
       end.
   end.
   
       
&Glob main-tbl utd
{ trg/trghistnws.i 
  &hist = yes 
  &seqnamehist = "s-c-utd-chip-num"
  &histheadtbl = "c-utd-head"
  &fieldmainheadtab  = "db-num doc-id" 
  
} 
        
  if not g#news and not (buffer new-{&main-tbl}:handle:buffer-compare (buffer old-utd:handle)) 
  then do:
    new-{&main-tbl}.ModifyDate = date (now).
    new-{&main-tbl}.ModifyTime = time.
    if     not g#esys
       and new-{&main-tbl}.sts      ne old-utd.sts
       and new-{&main-tbl}.EDocType ne objSrv:Env:Utd:EDocType:returns:KeyIntDB
    then do:
       if new-{&main-tbl}.EDocType eq objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
       then do :
          find first utd-attr no-lock where utd-attr.db-num = new-{&main-tbl}.db-num
                                        and utd-attr.doc-id = new-{&main-tbl}.doc-id
                                        and utd-attr.attr-code = "is-initial-set"
                                        no-error .
          if available utd-attr
          and logical(utd-attr.attr-value)
          then do :
             run bge\send1cerp.p (?,
                        this-procedure,
                        this-procedure,
                        "edi-doc",
                        (buffer old-{&main-tbl}:handle),
                        (buffer new-{&main-tbl}:handle),
                        ?) no-error.
             if error-status:error 
             then do:
                message return-value view-as alert-box.
             end.
          end .
          else do :
             find first utd-marking-lines no-lock where utd-marking-lines.db-num  = new-{&main-tbl}.db-num
                                                    and utd-marking-lines.doc-id  = new-{&main-tbl}.doc-id
                                                    and utd-marking-lines.doc-level = 1 
                                                    and (utd-marking-lines.sts = 0
                                                      or utd-marking-lines.site = "only-send")
                                                    no-error .
             if available utd-marking-lines
             then do :
                run bge\send1cerp.p (?,
                            this-procedure,
                            this-procedure,
                            "edi-doc",
                            (buffer old-{&main-tbl}:handle),
                            (buffer new-{&main-tbl}:handle),
                            ?) no-error.
                if error-status:error 
                then do:
                   message return-value view-as alert-box.
                end.
             end .
          end .
       end . /* Mark_Collect */
       else do :
         run bge\send1cerp.p (?,
                      this-procedure,
                      this-procedure,
                      "edi-doc",
                      (buffer old-{&main-tbl}:handle),
                      (buffer new-{&main-tbl}:handle),
                      ?) no-error.
         if error-status:error 
         then do:
            message return-value view-as alert-box.
         end.
         for each utd-marking-lines where utd-marking-lines.db-num eq new-{&main-tbl}.db-num
                                      and utd-marking-lines.doc-id eq new-{&main-tbl}.doc-id
                                      and utd-marking-lines.doc-level eq 1
         no-lock:
            find first marking where marking.mark eq utd-marking-lines.mark
            no-lock no-error.
            if     available marking
               and marking.sts eq objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB 
            then
               run sendmark(marking.mark).
            /* выгружаем марку, если добавили ее в УПД вручную */
            else if available marking then 
            do:
                find first ub.utd-marking-lines-attr no-lock where 
                           ub.utd-marking-lines-attr.db-num     = utd-marking-lines.db-num
                       and ub.utd-marking-lines-attr.doc-id     = utd-marking-lines.doc-id
                       and ub.utd-marking-lines-attr.LineNum    = utd-marking-lines.LineNum
                       and ub.utd-marking-lines-attr.mark       = utd-marking-lines.mark
                       and ub.utd-marking-lines-attr.attr-code  = "AddMarkWeight"
                       and ub.utd-marking-lines-attr.attr-value = "yes"
                       no-error.
                if available ub.utd-marking-lines-attr
                then         
                   run sendmark(marking.mark).
            end.       
         end.
       end .  
    end.
    if g#db-num = 0 and 
      (
      (new-{&main-tbl}.sts <> old-utd.sts
      and (
            new-{&main-tbl}.sts = utdTHSts:AwaitingDelivery:KeyIntDB
        or  old-utd.sts = utdTHSts:AwaitingDelivery:KeyIntDB
        or  new-{&main-tbl}.sts = utdTHSts:Confirmed:KeyIntDB
        or  old-utd.sts = utdTHSts:Confirmed:KeyIntDB
        or  new-{&main-tbl}.sts = utdTHSts:Rejection:KeyIntDB
      ))
/*      or                               */
/*      (                                */
/*      new-{&main-tbl}.sts-edi <> old-utd.sts-edi*/
/*      and                                             */
/*      new-{&main-tbl}.sts-edi = ObjSrv:Env:Utd:Sts:EDI:Intoduce*/
/*      )*/
      )
    then do: 
      run str/callnews.p
        (input {&table_utd}
        ,input (buffer new-{&main-tbl}:handle)
        ) no-error .
      if error-status:error then do:
         if not G#auto
         then
             message  return-value
             view-as  alert-box.
        undo main-block,  return error return-value . 
      end.
    end.
    if g#db-num ne 0 and 
      (new-{&main-tbl}.sts <> old-utd.sts
      and (
            new-{&main-tbl}.sts ne utdTHSts:NewStatus:KeyIntDB
         
      ))
    then do: 
      run str/callnews.p
        (input {&table_utd}
        ,input (buffer new-{&main-tbl}:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block,  return error return-value .
      end.
    end.
    if new-{&main-tbl}.sts <> ? and new-{&main-tbl}.sts <> 0 and old-{&main-tbl}.sts-edi <> ? and new-{&main-tbl}.sts-edi <> ? 
    then do:
      if g#db-num = 0 and (new-{&main-tbl}.sts-edi <> old-{&main-tbl}.sts-edi
        and (
              new-{&main-tbl}.sts-edi = utdEDISts:RevocationAccepted:KeyIntDB
        ))
      then do:
        run nws/cmdchgutd.p (buffer new-{&main-tbl}).
      end.
      if g#db-num ne 0 and (new-{&main-tbl}.sts-edi <> old-{&main-tbl}.sts-edi)
      then do:
        run nws/cmdchgutd.p (buffer new-{&main-tbl}).
      end.
    end.

  end.
  
  find first ub.clients no-lock  where ub.clients.obj-type = new-{&main-tbl}.obj-type and ub.clients.obj-code = new-{&main-tbl}.obj-code no-error.
   /*
    ub.clients.db-num = g#db-num no-error.  
  if available (ub.clients) and (new-{&main-tbl}.sts <> old-utd.sts) and
    ((g#db-num ne 0 and g#news) or (g#db-num eq 0 and not g#news)) and new-{&main-tbl}.doc-code = "" and new-{&main-tbl}.sts = objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB 
    and (new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB)
 */ 
  if    (new-{&main-tbl}.sts = objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB  and new-{&main-tbl}.sts <> old-{&main-tbl}.sts)
    and (new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB)
    and ((g#db-num ne 0 and g#news) or 
    ((new-{&main-tbl}.doc-code = "" or new-{&main-tbl}.doc-code eq ?) 
    and g#db-num eq 0 and not g#news))
    and available ub.clients
    and ub.clients.db-num = g#db-num 
    and g#db-num ne 0
  then do:
    def var v-file-name as character no-undo.
    def var v-msg as character no-undo.
    run ibs\th\str\utd\adaputd.p
      (new-{&main-tbl}.db-num, /*db-num*/
      new-{&main-tbl}.doc-id, /* doc-id*/
      g#userid /*User-Id*/
      ) no-error.
    if not error-status:error
    then do:
      if return-value matches "*ошибка*"
      then v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &4', new-{&main-tbl}.DocumentNumber, string (new-{&main-tbl}.DocumentDate) , new-{&main-tbl}.doc-code, return-value).
      else do:
         if     new-{&main-tbl}.sts ne objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
              
         then    v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &5 &6 &4', new-{&main-tbl}.DocumentNumber, string (new-{&main-tbl}.DocumentDate) , new-{&main-tbl}.doc-code, return-value, 
         if ChecknotMarkUtd(new-{&main-tbl}.db-num,new-{&main-tbl}.doc-id) then "Немаркированные товары можно продавать на кассе." else "",
         if CheckMarkUtd(new-{&main-tbl}.db-num,new-{&main-tbl}.doc-id) then "Продажа маркированных товаров из данной поставки запрещена до получения дополнительного уведомления. " else "").
         
         
         else if     new-{&main-tbl}.sts eq objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
                 and CheckMarkUtd(new-{&main-tbl}.db-num,new-{&main-tbl}.doc-id) 
         then    v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &5 &4', new-{&main-tbl}.DocumentNumber, string (new-{&main-tbl}.DocumentDate) , new-{&main-tbl}.doc-code, return-value, "Маркированные товары данной поставки можно продавать на кассе.").
      end.
      
    end.
      else v-msg = substitute ('Получен УПД. Документ: &1 от &2. Ошибка при формировании ПН. &3. &4', new-{&main-tbl}.DocumentNumber, string (new-{&main-tbl}.DocumentDate), trim(return-value, ".")).
    if v-msg ne ""
    then
       run utl\proc-msg.p (v-msg) no-error.
  
  end.
  else if new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB and g#db-num > 0 
          and available (ub.clients)
  then do:
      def var v-mes as char no-undo.
      v-mes = substitute("DB&1,gnews&2,stts&3,old-stts&4,clientdb&5",g#db-num,g#news,new-{&main-tbl}.sts,old-{&main-tbl}.sts,ub.clients.db-num).
       
      if  log-manager:logfile-name ne ?
   then log-manager:write-message(v-mes, "UTDWError"). 
   else do:
       output to c:\temp\utdwerr.txt append.
       put v-mes skip.
       output close.
   end.       
  end.
  if g#db-num ne 0 and new-{&main-tbl}.sts = objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and new-{&main-tbl}.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
  then do:
      v-msg = substitute ('Получен документ первоначального ввода. Документ № &1 от &2. Обратитесь в Техническую поддержку.', new-{&main-tbl}.DocumentNumber, string (new-{&main-tbl}.DocumentDate)).
      run utl\proc-msg.p (v-msg) no-error.
  end.
  
  


end. /* main-block */

procedure sendmark:
   define input  parameter iMark as character no-undo.
   define buffer marking for marking.
   find first marking where marking.mark eq imark
   no-lock no-error.
   if     available marking
   then do:
       run bge\send1cerp.p (?,
                    this-procedure,
                    this-procedure,
                    "mark",
                    (buffer marking:handle),
                    ?,
                    ?) no-error.
      if error-status:error 
      then
         message return-value view-as alert-box.
      else do:
         if marking.sts eq objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB 
         then do:
            for each marking where marking.mark-parent eq imark
            no-lock:
               run sendmark (marking.mark).
            end.
         end.
      end.
   end.
end.