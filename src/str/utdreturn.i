{ cmp/str-glbl.i {1}}
{ str/utd-err.i {1}}
{ gbl/objsrv.i {1}}
{ str/trdcalib.i {1}}
define temp-table tt-return
  field db-num as integer 
  field doc-id as integer
  field mark like marking.mark
index docid db-num doc-id.
define temp-table tt-prts
  field rec-id-line as recid
  field rec-id as recid
  field doc-code as character 
index docid doc-code rec-id.

&if "{1}" = "class"
&then
method private logical canUtdReturn
&else
function  canUtdReturn returns logical
&endif
(input idoc-code as character ):
   define variable Vflag as logical no-undo.
   find first trn-doc where trn-doc.doc-code     eq idoc-code
                        and trn-doc.ext-doc-type eq {&TDEDT_Ras_Vnesh}
   no-lock no-error.
   find first utd where utd.doc-code eq trn-doc.doc-code
                    and utd.EDocType eq objSrv:Env:Utd:EDocType:returns:KeyIntDB no-lock no-error.
   if         available trn-doc
      and not available utd
   then
      Vflag = yes.
      
   
   return Vflag.
end.

define variable mySeqUtd as int64 no-undo init ?.
procedure MySeqForUtd:
   define input  parameter iTable       as character no-undo.
   define input  parameter iseqnamehist as character no-undo.
   define input  parameter idb-name     as character no-undo.
   define output parameter Oseq         as int64 no-undo.
   if iTable begins "utd"
   then do:
      if myseqUtd eq ?
      then 
         myseqUtd = dynamic-next-value(iseqnamehist,idb-name).
      Oseq = myseqUtd.
   end.
   else
      Oseq = ?. 
   return.
end.

&if "{1}" = "class"
&then
method private logical crUtdReturn
&else
function  crUtdReturn returns logical
&endif
(input idoc-code as character ):
   define buffer trn-doc               for ub.trn-doc.
   define buffer doc-line              for ub.doc-line.
   
   define buffer parts                 for ub.parts.
   define buffer buf_parts             for ub.parts.
   define buffer goods                 for ub.goods.
   define buffer marking-lines         for ub.marking-lines.
   define buffer marking               for ub.marking.
   define buffer utd                   for ub.utd.
   define buffer Buf_utd               for ub.utd.
   define buffer utd-lines             for ub.utd-lines.
   define buffer Buf_utd-lines         for ub.utd-lines.
   define buffer utd-marking-lines     for ub.utd-marking-lines.
   define buffer Buf_utd-marking-lines for ub.utd-marking-lines.
   define variable vi as integer no-undo.
   define variable vFlag as logical no-undo.
   define variable vdb-num as integer no-undo.
   define variable vdoc-id as integer no-undo.
   define variable vvalue  as character no-undo.
   define variable vType   as character no-undo.
   define variable vUTDReturn as logical no-undo.
   
   for each  tt-prts:
      delete  tt-prts.
   end.
   find first trn-doc where trn-doc.doc-code     eq idoc-code
                        and trn-doc.ext-doc-type eq {&TDEDT_Ras_Vnesh}
   no-lock no-error.
   { str/tdat-val.i                                    
    trn-doc.doc-code 
    {&trdcattr-edo-return}
    vvalue 
    vType 
    no-error}
   vUTDReturn = logical(vvalue) no-error.
   if not vUTDReturn
   then
      return no.
      
   find first utd where utd.doc-code eq trn-doc.doc-code
                    and utd.EDocType eq objSrv:Env:Utd:EDocType:returns:KeyIntDB no-lock no-error.
   if         available trn-doc
      and not available utd
   then do:
      
      for each doc-line where doc-line.doc-code eq trn-doc.doc-code no-lock,
         each parts where parts.out-code  = doc-line.doc-code
                       and parts.obj-type  = doc-line.obj-type
                       and parts.obj-code  = doc-line.obj-code
                       and parts.artic     = doc-line.artic
                       and parts.prod-type = doc-line.prod-type
                       and parts.prod-code = doc-line.prod-code
      no-lock:
         define variable v-rowid    as rowid no-undo.
         define variable v-tbl-name as character no-undo.
         find first gen-attr where gen-attr.table-name = {&table_parts}
                               and gen-attr.p-key      = {key/parts.i parts } 
                               and gen-attr.attr-code  = "in-part-key"
         no-lock no-error.
         if available gen-attr
         then do:
            run gen-row-keyr in this-procedure (
                                           input  gen-attr.attr-value /*uniq-key-rec смены*/
                                           ,input ? /*p-key-handle буфер записи которую будем искать. если ищем по key-rec то ? */
                                           ,input  "ub"
                                           ,input  ? /*p-tt-handle   буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                           ,input  no-lock
                                           ,output v-rowid
                                           ,output v-tbl-name ) .
            find first buf_parts where rowid(buf_parts) eq v-rowid no-lock no-error.
         end.
         
         create tt-prts.
         assign
            tt-prts.rec-id-line = recid(doc-line)
            tt-prts.rec-id   = recid(parts)
            tt-prts.doc-code = if available  buf_parts then buf_parts.in-code  else ""
         .
         release  buf_parts.
      end.
      subscribe "getNextseq" anywhere run-procedure "MySeqForUtd".
      do trans:
            
         block-part:
         for each tt-prts,
            first doc-line where recid(doc-line) eq tt-prts.rec-id-line no-lock,
            first parts where recid(parts) eq tt-prts.rec-id no-lock
         break by  tt-prts.doc-code by tt-prts.rec-id-line:
            find first goods where goods.artic eq parts.artic
                               and goods.prod-type eq parts.prod-type
                               and goods.prod-code eq parts.prod-code
            no-lock no-error.
            if not available goods
            then do:
               message "Не найден товар по поcтавщику " parts.prod-type  parts.prod-code " с аркиклом "  parts.artic
                  view-as alert-box.
               next block-part. 
            end.
            else do:
               
               if first-of(tt-prts.doc-code)
               then do:
                  if    not  available buf_utd
                        or trn-doc.reason-code ne 23
                  then do:
                     if tt-prts.doc-code <> "" then 
                     find first utd where utd.doc-code eq tt-prts.doc-code no-lock no-error.
                     if tt-prts.doc-code <> "" 
                        and available utd
                     then do:
                        MySeqUtd = ?.
                        vFlag = yes.
                        create buf_utd.
                        buffer-copy utd  except Timestamp  
                                                RevocationStatus 
                                                RecipientResponseStatus 
                                                ReceiptStatus 
                                                ModifyTime 
                                                ModifyDate  
                                                LoadTime  
                                                LoadDate 
                                                EDocType  
                                                DocumentExt 
                                                db-num 
                                                doc-id
                                                AdditInfo
                                                doc-code
                                                sts 
                        to buf_utd
                        assign
                           buf_utd.parentDocumentExt     = utd.DocumentExt
                           buf_utd.parentOrganizationExt = utd.OrganizationExt
                           buf_utd.doc-code              = trn-doc.doc-code
                           buf_utd.EDocType              = objSrv:Env:Utd:EDocType:returns:KeyIntDB
                           buf_utd.DocumentDate    = today
                           buf_utd.DocumentNumber  = "Возврат № " + trn-doc.doc-code + (if trn-doc.reason-code ne 23 then " по УПД № " + utd.DocumentNumber + " за " + string(utd.DocumentDate,"99/99/9999") else "")
                           buf_utd.Direction       = "Inbound"
                           
                        .
                        validate buf_utd.
                        define variable mTypeUtd as character no-undo.
                        if   trn-doc.reason-code eq 23
                        then assign
                          buf_utd.PackageId = ""
                          mTypeUtd = "СЧФДОП"
                        . 
                        else if trn-doc.reason-code eq 25
                        then
                           mTypeUtd = "ДОП".
                        else
                           mTypeUtd = "".
                           
                        if   mTypeUtd ne ""
                        then
                           setattrutd (buf_utd.db-num,buf_utd.doc-id,"TypeUTD",mTypeUtd).
                        
                        /* поставим статус новы чтобы сначо создать все марки  по документу а потом отправить в новости */
                        buf_utd.sts             = ObjSrv:Env:Utd:Sts:th:newstatus:KeyIntDB.  /* меняе после получения doc-id */ 
                        Buf_utd.sts-edi               = if utd.AmendmentRequested 
                                                        then ObjSrv:Env:Utd:Sts:edi:AvailAdjustment:KeyIntDB 
                                                        else ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB.
                        assign 
                           vdb-num = Buf_utd.db-num
                           vdoc-id = Buf_utd.doc-id
                           vi      = 0
                        .
                     
                     end.
                     else do:
                        MySeqUtd = ?.
                        vFlag = yes. 
                        create buf_utd.
                        assign
                           buf_utd.contract-code   = parts.contract-code
                           buf_utd.doc-code        = trn-doc.doc-code
                           buf_utd.DocumentDate    = today
                           buf_utd.DocumentNumber  = "Возврат № " + trn-doc.doc-code + " по накладной " + parts.in-code
                           buf_utd.EDocType        = objSrv:Env:Utd:EDocType:returns:KeyIntDB
                           buf_utd.host-code       = parts.host-code
                           buf_utd.obj-type        = parts.obj-type
                           buf_utd.obj-code        = parts.obj-code
                           buf_utd.cli-type        = trn-doc.cli-type
                           buf_utd.cli-code        = trn-doc.cli-code
                        .
                        validate buf_utd.
                        if   trn-doc.reason-code eq 23
                        then assign
                           buf_utd.PackageId = ""
                           mTypeUtd = "СЧФДОП"
                        . 
                        else if trn-doc.reason-code eq 25
                        then
                           mTypeUtd = "ДОП".
                        else
                           mTypeUtd = "".
                              
                        if   mTypeUtd ne ""
                        then
                           setattrutd (buf_utd.db-num,buf_utd.doc-id,"TypeUTD",mTypeUtd).
                        /* поставим статус новы чтобы сначо создать все марки  по документу а потом отправить в новости */
                        buf_utd.sts             = ObjSrv:Env:Utd:Sts:th:newstatus:KeyIntDB. 
                        Buf_utd.sts-edi         = ObjSrv:Env:Utd:Sts:edi:WaitingForRecipientSignature:KeyIntDB.
                     
                        assign 
                           vdb-num = Buf_utd.db-num
                           vdoc-id = Buf_utd.doc-id
                           vi      = 0
                        .
                     end.
                  end.
               end.
               if first-of(tt-prts.rec-id-line)
               then do:
                  find first gds-dtl where gds-dtl.doc-code  = doc-line.doc-code
                                       and gds-dtl.artic     = doc-line.artic  
                                       and gds-dtl.prod-code = doc-line.prod-code
                                       and gds-dtl.prod-type = doc-line.prod-type 
                  no-lock no-error.
                  create buf_utd-lines.
                  assign
                     vi                      = vi + 1
                     buf_utd-lines.Article   = parts.artic
                     buf_utd-lines.db-num    = buf_utd.db-num
                     buf_utd-lines.doc-id    = buf_utd.doc-id
                     buf_utd-lines.LineNum   = vi
                     buf_utd-lines.gds-code     = goods.gds-code
                     buf_utd-lines.ProductCode  = goods.gds-name
                     buf_utd-lines.Quantity     = if available gds-dtl then gds-dtl.fact-qnty  else doc-line.fact-qnty
                     buf_utd-lines.TaxRate      = doc-line.VAT-pc
                     buf_utd-lines.Total        = (if available gds-dtl then gds-dtl.price-rubl else doc-line.price-rubl) * buf_utd-lines.Quantity
                     buf_utd-lines.UnitCode     = goods.unit-base
                     buf_utd-lines.Vat          = buf_utd-lines.Total * buf_utd-lines.TaxRate / (100 + buf_utd-lines.TaxRate)
                     buf_utd-lines.TotalWithVatExcluded = buf_utd-lines.Total  - buf_utd-lines.Vat
                     buf_utd-lines.Price                = buf_utd-lines.TotalWithVatExcluded / buf_utd-lines.Quantity
                  .
               end.
               else do:
                  find first buf_utd-lines where buf_utd-lines.db-num    = buf_utd.db-num
                                             and buf_utd-lines.doc-id    = buf_utd.doc-id
                                             and buf_utd-lines.LineNum   = vi
                  no-lock.
               end.
               for each marking-lines where marking-lines.gds-code   = goods.gds-code
                                        and marking-lines.obj-type   = parts.obj-type
                                        and marking-lines.obj-code   = parts.obj-code
                                        and marking-lines.in-code    = parts.in-code
                                        and marking-lines.out-code   = parts.out-code
                                        and marking-lines.part-code  = parts.part-code
                                        
                                        and marking-lines.doc-level  = 1
               no-lock:
                  create buf_utd-marking-lines.
                  assign
                     buf_utd-marking-lines.db-num     = buf_utd.db-num
                     buf_utd-marking-lines.doc-id     = buf_utd.doc-id
                     buf_utd-marking-lines.site       = "-"
                     buf_utd-marking-lines.doc-level  = marking-lines.doc-level
                     buf_utd-marking-lines.gds-code   = goods.gds-code
                     buf_utd-marking-lines.LineNum    = buf_utd-lines.LineNum
                     buf_utd-marking-lines.mark       = marking-lines.mark
                     buf_utd-marking-lines.sts        = marking-lines.sts
                  .
                  if buf_utd-marking-lines.doc-level eq 1
                  then 
                     AddUtdErr(buf_utd.db-num,buf_utd.doc-id,buffer buf_utd-marking-lines:handle,"return","Mark",marking-lines.mark + {&delim-par} + buf_utd-lines.ProductCode).
                  release buf_utd-marking-lines.
               end.
               if last-of(tt-prts.rec-id-line)
               then do:
                  release buf_utd-lines.
               end.
               if last-of(tt-prts.doc-code)
               then do:
                  buf_utd.Total = 0.
                  buf_utd.Vat   = 0.
                  for each buf_utd-lines where buf_utd-lines.db-num eq buf_utd.db-num
                                        and buf_utd-lines.doc-id eq buf_utd.doc-id
                  no-lock:
                     buf_utd.Total = buf_utd.Total + buf_utd-lines.Total.
                     buf_utd.Vat   = buf_utd.Vat   + buf_utd-lines.Vat.
                  end.
                  if trn-doc.reason-code ne 23
                  then
                     release buf_utd.
               end.
            end.
            
         end.
         
      end.
      release buf_utd.
      unsubscribe "getNextseq".
      /* изменим статус на правильный для отправки в новости */
      for each buf_utd where buf_utd.doc-code eq trn-doc.doc-code
                         and buf_utd.EDocType eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
      exclusive-lock:
         if    buf_utd.CounteragentId  eq ?
            or buf_utd.CounteragentId  eq ""
            or buf_utd.OrganizationExt eq ?
            or buf_utd.OrganizationExt eq ""
         then
            buf_utd.sts             = ObjSrv:Env:Utd:Sts:th:RequireFilling:KeyIntDB.
         else 
            buf_utd.sts             = ObjSrv:Env:Utd:Sts:th:SignatureRequired:KeyIntDB.
                  
      end.
   end.
   for each  tt-prts:
      delete  tt-prts.
   end.
   return vFlag.
end.