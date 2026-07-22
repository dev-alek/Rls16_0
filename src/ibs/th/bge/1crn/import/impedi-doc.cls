/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ипорта данных kass-book (типы кассовых книг) из 1С

Автор: Молотков Сергей
Дата создания: 13/02/19
Author: Molotkov Sergey
Creation date: 13/02/19

*/
&scoped-define impclass edi-doc
using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.{&impclass}.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.imp{&impclass} inherits ibs.th.gbl.sys.objth implements ibs.th.bge.1crn.import.iimpsubject : 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Импорт edi-doc" get.
    
  { cmp/str-glbl.i class } /* &add-def, &update, &deletion, &shop, &attr-cash-book-id, &attr-oper-serv-id */
  {str/edo-mark.i class}     
  
  {str\utd-err.i  class}
  {str\utd-attr.i class}
  {str\utd.i class}
  define private temp-table tt-mark no-undo 
     field mark as character case-sensitive 
  .
  define stream myProt.
  define variable isOpenProt as logical no-undo init no.
/*  define private temp-table tt-operserv no-undo like ub.OperServ .*/
  
  define property Msg as character no-undo
    get. 
    set.

  define variable GrayZoneQnty  as integer no-undo .
  { gbl/thbj-def.i }
  
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp    as class ibs.th.bge.1crn.subjects.edi-doc no-undo.
    define variable v-retfl   as logical no-undo .
    define variable v-mode    as character no-undo. /* create/update */
   
    define variable v-objlist   as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:kb-gds[]
    define variable v-gds-gd    as class ibs.th.bge.1crn.subjects.edi-gd no-undo .
    define variable v-objlistmark   as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:kb-gds[]
    define variable v-marks-mark    as class ibs.th.bge.1crn.subjects.mark no-undo .
    define variable v-i-counter as integer no-undo .
    define variable v-i-num     as integer no-undo .
    define variable v-i-counter2 as integer no-undo .
    define variable v-i-num2     as integer no-undo .
    
    define variable v-stub      as integer no-undo .
    
    define variable v-value-character     as character     no-undo .
    define variable v-value-decimal       as decimal       no-undo .
    define variable v-value-integer       as integer       no-undo .
    define variable v-value-logical       as logical       no-undo .
    define variable v-value-type          as character     no-undo .
    define variable v-value-date          as date          no-undo .
    
    define variable v-host-code  as integer no-undo .
    define buffer buf_clients    for ub.clients .
    define buffer buf_goods      for ub.goods .
    define buffer buf_goods-attr for ub.goods-attr .
/*    define buffer buf_OperServ   for ub.OperServ .*/
    define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc .
    define buffer utd for ub.utd .
    define buffer utd-attr for ub.utd-attr .
    
   define buffer utd-lines              for ub.utd-lines .
   define buffer utd-lines-attr         for ub.utd-lines-attr .
   define buffer utd-marking-lines      for ub.utd-marking-lines .
   define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr .
   define buffer marking                for ub.marking .
   define buffer marking-attr           for ub.marking-attr .
   define buffer contract               for ub.contract .
   define buffer order-doc              for ub.order-doc .

    objImp = cast (subjectObj, {&impclass}).

    if objImp:del-f > 0 then
      undo, throw new Progress.Lang.AppError("физичесткое удаление edi-doc не предусмотрено") .    
    
    /* если код не задан:
         - если пришла с признаком "основная" - то обновляем CashBook.id = 0 и не грузим секцию с товарами;
         - если пришла без признака "основная" - то режим создания с автоматическим присвоением кода;
       если код задан:
         - признак "основная" игнорируется;
         - если код присутствует в БД - режим обновления;
         - если код отсутствует в БД - режим создания;
       логическое удаление - только, если код задан, присутствует в БД, и CashBook.id <> 0.
       
       чтобы при изменении записи не затирать поля, которые не приходят из 1С, значениями по умолчанию -
       читаем их значения из исходной записи;
       чтобы при изменении записи не затирать поля из необязательных тегов, которые пришли из 1С, пустыми значениями -
       читаем их значения из исходной записи.
    */
  
   
   find first utd where utd.OrganizationExt eq ""
                    and utd.DocumentExt     eq objImp:edoc-id
   exclusive-lock no-error.
   if not available utd
   then do:
      if objImp:obj-load ne "edi-doc"
      then
         undo, throw new Progress.Lang.AppError(substitute("Создание &1 не предусмотрено",objImp:obj-load)) .
      create utd.
      utd.DocumentExt     = objImp:edoc-id.
      validate utd no-error.
      if error-status:error
      then
         undo, throw new Progress.Lang.AppError(substitute("&1 &2",return-value,error-status:get-message (1))) .
         
   end.
   if objImp:obj-load eq "edi-doc-stts"
   then do:
      utd.sts  = ObjSrv:Env:Utd:Sts:th:GetKeyIntDB(objImp:edoc-stts).
      for each utd-marking-lines where utd-marking-lines.db-num    eq utd.db-num
                                   and utd-marking-lines.doc-id    eq utd.doc-id
                                   and utd-marking-lines.doc-level eq 1
      exclusive-lock:
         
         addMark(buffer utd-marking-lines ).
                     find first marking exclusive-lock where marking.mark = utd-marking-lines.mark no-error .
                       if available (marking) then do:
                       if marking.unit-ext <> "UNIT" and utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB 
                       and marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then
                       marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB.
                       end. 
      end.
   end.
   else do:
      assign
         utd.comment  = objImp:comment
         utd.CounteragentId  = objImp:contr-code                  when objImp:contr-code ne ?
         utd.contract-code  = objImp:dog-code                     when objImp:dog-code ne ? 
         utd.DocumentDate  = objImp:edoc-date
         utd.DocumentNumber  = objImp:edoc-num
         utd.sts  = ObjSrv:Env:Utd:Sts:th:GetKeyIntDB(objImp:edoc-stts)
         utd.sts-edi  = ObjSrv:Env:Utd:Sts:EDI:Verification:KeyIntDB
         utd.EDocType  = ObjSrv:Env:Utd:edoctype:GetKeyIntDB(objImp:edoc-type)
         utd.parentDocumentExt  = objImp:orig-edoc-id             when objImp:orig-edoc-id ne ?
         utd.PackageId          = objImp:orig-edoc-id             when objImp:orig-edoc-id ne ?
         utd.total  = objImp:sum                                  when objImp:sum ne ?
         utd.vat  = utd.total - objImp:sum-nonds                  when objImp:sum ne ? and objImp:sum-nonds ne ?
      .
      
      define variable vflag as logical no-undo.
      for first buf_clients no-lock
            where buf_clients.obj-type = {&cmp}
              and buf_clients.obj-code = int(objImp:contr-code) :
         assign 
            utd.cli-type   = buf_clients.obj-type
            utd.cli-code   = buf_clients.obj-code
           vflag = yes
         .
      end.
      if  not vflag
      then
         undo, throw new Progress.Lang.AppError(substitute("Не найдена организация с кодом &1 в БД &2",int(objImp:contr-code),ibs.th.gbl.gbl-var:g#db-num)) .
      for first buf_clients no-lock
            where buf_clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
              and buf_clients.obj-type = {&shop}
              and buf_clients.stts     = {&bef-current-status-int} :
         assign
            utd.obj-type   = buf_clients.obj-type
            utd.obj-code   = buf_clients.obj-code
            utd.host-code  = buf_clients.host-code
            
         .
          run adm/shattri.p (
               input "get":U
               ,input utd.obj-type
               ,input utd.obj-code
               ,input {&attr-marking}
               ,input "gray_zone_qnty"
               ,output v-value-character
               ,output v-value-date
               ,output v-value-decimal
               ,output v-value-integer
               ,output v-value-logical
               ,output v-value-type
               ,input-output TABLE thbjattr_thbj-attr
               ) no-error .
           if v-value-integer <> ?
           then 
              /* ЗАПЛАТКА: по ЗИ по коробам не должно быть проверки на "серую зону" */
              /* на случай, если надо вернуть, просто всегда берем 100              */
/*              GrayZoneQnty = v-value-integer*/
              GrayZoneQnty = 100
           . 

         find first shop where shop.obj-code eq buf_clients.obj-code
         no-lock no-error.
         if available shop
         then
            utd.obj-info = shop.addres1.
      end.
      find first contract  where contract.host-code     eq utd.host-code
                             and contract.contract-code eq utd.contract-code
      no-lock no-error.
      if  not available contract
      then
         undo, throw new Progress.Lang.AppError(substitute("В &1, указанный в УПД, не найден в системе.",utd.contract-code)) .
      
      if     contract.cli-type  ne utd.cli-type
         or  contract.cli-code  ne utd.cli-code
      then
         undo, throw new Progress.Lang.AppError(substitute("В договоре &1 и в УПД разные контр агенты",utd.contract-code)) .
      Utd.BaseDocumentNumber = contract.contract-prn-code.
      utd.BaseDocumentDate       = contract-date.
      
      if objImp:order-item ne ? and 
         can-find(first order-doc where order-doc.order-item = objImp:order-item)
      then  /* не связываем УПД с заказом, если заказ не найден */
        setattrutd(utd.db-num, utd.doc-id, "order-item", objImp:order-item).
                            
      /*define variable VContractEdo as logical no-undo init yes.
      VContractEdo = contract.whole-send-news eq 1. /* договор Едо*/
      if not VContractEdo
      then
         undo, throw new Progress.Lang.AppError(substitute("Договор с кодом &1 не ЭДО",utd.contract-code)).
      */
     /* find first contract-attr exclusive-lock where contract-attr.contract-code = contract.contract-code
                                                and contract-attr.host-code    = contract.host-code 
                                                and contract-attr.attr-code = "contract-edi" no-error .
      if    not available contract-attr
         or logical(contract-attr.attr-value) ne yes
      then 
         undo, throw new Progress.Lang.AppError(substitute("Договор с кодом &1 не ЭДО",utd.contract-code)).
     */
      v-objlist = objImp:gds .
      if valid-object(v-objlist) 
      then do :
         v-i-counter = v-objlist:iCounter .
         do v-i-num = 1 to v-i-counter :
            v-stub = v-objlist:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
            v-gds-gd = cast(v-objlist:SubjectObjCurr, ibs.th.bge.1crn.subjects.edi-gd) .
            find first utd-lines where utd-lines.db-num  eq utd.db-num
                                   and utd-lines.doc-id  eq utd.doc-id
                                   and utd-lines.LineNum eq v-gds-gd:line-num
            exclusive-lock no-error.
            if not available utd-lines
            then do:
               create utd-lines.
               assign 
                  utd-lines.db-num   = utd.db-num
                  utd-lines.doc-id   = utd.doc-id
                  utd-lines.LineNum  = v-gds-gd:line-num
               .
            end.
            utd-lines.TaxRate = v-gds-gd:nds-code.
            if v-gds-gd:gds-code ne ?
            then do:
               find first goods where goods.gds-code eq v-gds-gd:gds-code
               no-lock no-error.
               if not available goods
               then
                  undo, throw new Progress.Lang.AppError(substitute("Нет товара с кодом &1",v-gds-gd:gds-code)).
            end.
            assign
               utd-lines.Price     = v-gds-gd:price-nonds
               utd-lines.Quantity  = v-gds-gd:qnty-ttn
               utd-lines.Total     = v-gds-gd:sum
               utd-lines.gds-code  = v-gds-gd:gds-code
            .
            if available  goods
            then
               assign
                  
                  utd-lines.UnitCode  = goods.unit-base
                  utd-lines.GdsName   = goods.gds-name
               .
            release goods.
            
            
            if v-gds-gd:sum-nds eq ?
            then
               assign
                  utd-lines.TotalWithVatExcluded  = utd-lines.Price * utd-lines.Quantity
               .
            else
               assign
                  utd-lines.Vat                   = v-gds-gd:sum-nds 
                  utd-lines.TotalWithVatExcluded  = utd-lines.Total - utd-lines.Vat
               .
            if v-gds-gd:stts-desc ne ?
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,"Load1C","stts-desc-line",v-gds-gd:stts-desc + {&delim-par} + string( utd-lines.LineNum)).            

            /*Сертификаты*/
            if v-gds-gd:cert-decl ne ""
            then
               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"doc_sertif",v-gds-gd:cert-decl).
            if v-gds-gd:Qnty-accepted ne ?
            then
               setattrutdlines(utd-lines.db-num, utd-lines.doc-id, utd-lines.lineNum,"QuantityBarCode",string(v-gds-gd:Qnty-accepted)).
               
            /* разрешение ручного выбора */            
            if v-gds-gd:manual-selection eq 1 
            then 
               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"manual-selection","yes").                              
            else
               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"manual-selection",""). 
                
            define variable vqnty as integer no-undo.
            vqnty = 0.
            define variable vGdsCode as integer no-undo.
            v-objlistmark = v-gds-gd:marks .
            if valid-object(v-objlistmark) 
            then do :
               vGdsCode = 0.
            
               v-i-counter2 = v-objlistmark:iCounter .
               /*if v-i-counter2 < 1
               then
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,"loadUtd","NotMarkForLine",string(utd-lines.LineNum ) ).
                 */ 
               for each tt-mark:
                  delete tt-mark.
               end.
               for each utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                            and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                            and utd-marking-lines.LineNum eq utd-lines.LineNum
               exclusive-lock:
                  delete utd-marking-lines.
               end.
               
               do v-i-num2 = 1 to v-i-counter2 :
                  v-objlistmark:Get(v-i-num2) .
                  v-marks-mark = cast(v-objlistmark:SubjectObjCurr, ibs.th.bge.1crn.subjects.mark) .
                  define variable vmark as character no-undo.
                  vmark = repTegforDm(v-marks-mark:mark-code).

                  release marking.
                  if ismark(vmark)
                  then do:
                     find first marking where marking.mark eq vmark
                        no-lock no-error.
                     if not available marking
                     then
                        undo, throw new Progress.Lang.AppError(substitute("Нет марки &1 .",v-marks-mark:mark-code)) .
                  end.
                  define variable vrec as recid no-undo.
                  vrec = addMarkforUtd (utd-lines.db-num ,
                                 utd-lines.doc-id,
                                 utd-lines.Linenum,
                                 vmark,
                                 "1c",
                                 objImp:edoc-type).
                  
                  find first utd-marking-lines where recid(utd-marking-lines)   eq vrec
                  exclusive-lock no-error.
                  if available marking
                  then
                     utd-marking-lines.gds-code = marking.gds-code.
                  else
                     utd-marking-lines.gds-code = v-gds-gd:gds-code.
                  if     vGdsCode eq 0
                     and utd-marking-lines.gds-code ne ?
                  then
                     vGdsCode = utd-marking-lines.gds-code.
                  else if      utd-marking-lines.gds-code ne ?
                      and vGdsCode ne utd-marking-lines.gds-code
                  then
                     vGdsCode = ?.
                  if not ismark(vmark)
                  then do:
                     define variable vQntyMark as decimal no-undo.
                     vQntyMark = getQntyUTDByCodId(vmark) .
                     setattrUtdMarkingLines(utd-lines.db-num, utd-lines.doc-id, utd-lines.Linenum, vmark,"box-qnty",string(vQntyMark)).
                  end.
                  else
                     vQntyMark = marking.box-qnty.
   
                  if utd-marking-lines.doc-level eq 1
                  then
                     vqnty = vqnty + vQntyMark.
                  utd-marking-lines.sts = if not avail ub.marking then ObjSrv:Env:marking:Sts:mark:GetKeyIntDB(v-marks-mark:stts)
                                          else 
                                 if can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(ub.marking.sts)) or
                                    can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(ub.marking.sts)) or
                                    ub.marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or
                                    ub.marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
                                 then objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                                 else ub.marking.sts.
                  
                  if     v-marks-mark:stts-desc ne ?
                     and available marking
                  then
                     AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"Load1C","stts-desc-mark",v-marks-mark:stts-desc + {&delim-par} + string( utd-lines.LineNum) + {&delim-par} +  vmark).
                  release utd-marking-lines.
               end.

run gbl/inidebug.p.
               for each utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                            and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                            and utd-marking-lines.LineNum eq utd-lines.LineNum
                                            and utd-marking-lines.doc-level = 1 
               exclusive-lock:
                  
                  do:
                     MarkGray(utd-marking-lines.mark, utd.db-num, utd.doc-id).
                     addMark( buffer utd-marking-lines).
                       find first marking exclusive-lock where marking.mark = utd-marking-lines.mark no-error .
                       if available (marking) then do:
                          if marking.unit-ext <> "UNIT" and utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB 
                          and marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then
                          marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB.
                       end. 
/*out2log(utd.db-num, utd.doc-id, utd-marking-lines.mark, 0).*/
                  end.
               end.
/*run gbl/inidebug.p.*/
               if     vGdsCode     eq ?
                  and v-i-counter2 > 0
               then
                  utd-lines.gds-code = ?.
               
            
            end. //
            release utd-lines.
         end.
      end.
   end.
   for each utd-lines where utd-lines.db-num eq utd.db-num
                        and utd-lines.doc-id eq utd.doc-id
   no-lock:
      CheckMarkUtdLine(utd-lines.db-num,
                       utd-lines.doc-id,
                       utd-lines.LineNum).
   end.
   CheckMarkUtd(utd.db-num,utd.doc-id).
   CheckMarking(utd.db-num,utd.doc-id,"CheckСontract").
/*   vMarkUtd =*/
   CheckMarkUtd(utd.db-num,utd.doc-id).
   if ibs.th.gbl.gbl-var:g#db-num ne 0 and utd.sts = objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB 
      and (utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB )
     then 
   do:
     def var v-file-name as character no-undo.
     def var v-msg       as character no-undo.
     run ibs\th\str\utd\adaputd.p
       (utd.db-num, /*db-num*/
       utd.doc-id, /* doc-id*/
       ibs.th.gbl.gbl-var:g#userid /*User-Id*/
       ) no-error.
     if not error-status:error
     then do:
        v-msg = "".
        if return-value matches "*ошибка*"
        or return-value begins "need-user-action"
        then v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &4', utd.DocumentNumber, string (utd.DocumentDate) , utd.doc-code, trim(return-value, "need-user-action")).
        else do:
           if     utd.sts ne objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
           then    v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &5 &6 &4', 
                                       utd.DocumentNumber, 
                                       string (utd.DocumentDate) , 
                                       utd.doc-code, 
                                       return-value, 
                                       if ChecknotMarkUtd(utd.db-num,utd.doc-id) then "Немаркированные товары можно продавать на кассе." else "",
                                       if CheckMarkUtd(utd.db-num,utd.doc-id) then "Продажа маркированных товаров из данной поставки запрещена до получения дополнительного уведомления." else "").
           else if     utd.sts eq objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
                   and CheckMarkUtd(utd.db-num,utd.doc-id) 
           then    v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &5 &4', utd.DocumentNumber, string (utd.DocumentDate) , utd.doc-code, return-value, "Маркированные товары данной поставки можно продавать на кассе").
        end.
     end.
     else v-msg = substitute ('Документ: &1 от &2. Ошибка при формировании ПН. &3. &4', utd.DocumentNumber, string (utd.DocumentDate), trim(return-value, ".")).
     if v-msg ne ""
     then
        run utl\proc-msg.p (v-msg) no-error.
   
   end.

   if ibs.th.gbl.gbl-var:g#db-num ne 0 and utd.sts = objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
   then do:
       v-msg = substitute ('MsgBox "Докумет № &1 от &2. ", ,"Получен документ первоначального ввода"', utd.DocumentNumber, string (utd.DocumentDate)).
       v-file-name = string (guid(generate-uuid)) + ".vbs".
       output to value (v-file-name).
       put unformatted v-msg. 
       output close.
       file-info:file-name = (v-file-name).    
       os-command no-wait value (file-info:full-pathname).
   end.
   release utd.
   v-retfl = true .
    define variable i as integer no-undo .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        do i = 1 to exAppErrors:NumMessages :
          Msg = Msg + {&new-line} + exAppErrors:GetMessage(i) .
        end .
        if Msg > "" then . else Msg = "AppError в edi-doc" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      do i = 1 to exProErrors:NumMessages :
        Msg = Msg + {&new-line} + exProErrors:GetMessage(i) .
      end .
      if Msg > "" then . else Msg = "ProError в edi-doc" .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в edi-doc" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      
      return v-retfl .
    end finally .
  end method. /* end_of Excute */
  
  
  method public void MarkGray(imark as char, idb-num as int, idoc-id as int):
     define buffer marking for marking.
     define buffer BuF_marking for marking.
     define buffer bf_bar-code for ub.bar-code .
     define buffer bf2_bar-code for ub.bar-code .
     define buffer bf_goods-attr for ub.goods-attr .
     define buffer bf_utd-marking-lines for utd-marking-lines .
     define variable vAllQnty as integer no-undo init ?.
     define variable vQnty as integer no-undo.
     define variable v-must-be-childs as integer no-undo .
     define variable cisGdsCode as integer no-undo .
     define variable v-mark-type  as character no-undo .
     define variable v-err-childs as logical no-undo .
     define variable v-gray-zone  as logical no-undo .
     define variable errMsg as character no-undo .
     
     v-err-childs = false .
     v-gray-zone = false .
     
     find first marking where marking.mark eq imark
     no-lock no-error.
     if available marking
        and marking.box-qnty ne 1
     then do:
        find first bf_utd-marking-lines where bf_utd-marking-lines.db-num eq idb-num
                                          and bf_utd-marking-lines.doc-id eq idoc-id
                                          and bf_utd-marking-lines.mark   eq marking.mark
        no-lock no-error.
        if marking.gds-code > 0
        then do :
           cisGdsCode = marking.gds-code . 
        end .
        else do :
           cisGdsCode = getGdsCodeByGtin(marking.gds-ext-id) .
        end .
        v-mark-type = "" .
        for first bf_goods-attr no-lock where bf_goods-attr.attr-code = {&attr-mark-type}
                                          and bf_goods-attr.gds-code = cisGdsCode
                                          :
           v-mark-type = bf_goods-attr.attr-value .
        end .
        for each buf_marking where buf_marking.mark-parent eq marking.mark
        no-lock:
           if vAllQnty eq ?
           then
              vAllQnty = marking.box-qnty / buf_marking.box-qnty.
           vQnty = vQnty + 1.
        end.
/*        BTS-2564 Убираем проверку LEVEL2 для всех типов маркировки                                        */
/*        if marking.unit-ext = "LEVEL2" and                                                                */
/*           v-mark-type <> "tabak" and                                                                     */
/*           v-mark-type <> "stiki" and                                                                     */
/*           v-mark-type <> "water"                                                                         */
/*           /* (ZI-701 по коробам) для табака и воды кол-во по коробу не проверяем*/                       */
/*        then do :                                                                                         */
/*           if cisGdsCode > 0                                                                              */
/*           then do :                                                                                      */
/*              v-must-be-childs = 50 .                                                                     */
/*              find first bf_bar-code no-lock where bf_bar-code.gds-code = cisGdsCode                      */
/*                                               and bf_bar-code.unit-cli = "кор"                           */
/*                                               and bf_bar-code.stts_ = 0                                  */
/*              no-error .                                                                                  */
/*              if available bf_bar-code                                                                    */
/*              then do :                                                                                   */
/*                v-must-be-childs = bf_bar-code.cli-base-rate .                                            */
/*                find first bf2_bar-code no-lock where bf2_bar-code.gds-code = cisGdsCode                  */
/*                                                  and bf2_bar-code.unit-cli = "бл"                        */
/*                                                  and bf2_bar-code.stts_ = 0                              */
/*                no-error .                                                                                */
/*                if available bf2_bar-code                                                                 */
/*                then do :                                                                                 */
/*                  v-must-be-childs = v-must-be-childs / bf2_bar-code.cli-base-rate .                      */
/*                end .                                                                                     */
/*                else do :                                                                                 */
/*                  errMSG = "Для товара с кодом " + string(cisGdsCode) + " не найден код с ед. изм. 'бл'" .*/
/*                  v-err-childs = true .                                                                   */
/*                end .                                                                                     */
/*              end .                                                                                       */
/*              else do :                                                                                   */
/*                errMSG = "Для товара с кодом " + string(cisGdsCode) + " не найден код с ед. изм. 'кор'" . */
/*                v-err-childs = true .                                                                     */
/*              end .                                                                                       */
/*              if not v-err-childs                                                                         */
/*              then do :                                                                                   */
/*                if v-mark-type = "tabak"                                                                  */
/*                or v-mark-type = "stiki"                                                                  */
/*                then do :                                                                                 */
/*                  if vQnty <> v-must-be-childs                                                            */
/*                  then do:                                                                                */
/*                    if GrayZoneQnty = 100                                                                 */
/*                    then do :                                                                             */
/*                      v-gray-zone = true .                                                                */
/*                    end .                                                                                 */
/*                    else do :                                                                             */
/*                      if (v-must-be-childs - vQnty) <= GrayZoneQnty                                       */
/*                      then v-gray-zone = true .                                                           */
/*                      else v-err-childs = true .                                                          */
/*                    end .                                                                                 */
/*                  end .                                                                                   */
/*                  if v-gray-zone                                                                          */
/*                  then do :                                                                               */
/*                     MarkChangeSts(marking.mark,                                                          */
/*                                   objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB,                         */
/*                                   "",                                                                    */
/*                                   no).                                                                   */
/*                  end .                                                                                   */
/*                end .                                                                                     */
/*                else do :                                                                                 */
/*                  if vQnty <> v-must-be-childs then v-err-childs = true .                                 */
/*                end .                                                                                     */
/*                if v-err-childs                                                                           */
/*                then do :                                                                                 */
/*                  errMSG = "В коробе " + string(vQnty) + " блоков." .                                     */
/*                end .                                                                                     */
/*              end .                                                                                       */
/*              if v-err-childs                                                                             */
/*              then do :                                                                                   */
/*                 MarkChangeSts(marking.mark,                                                              */
/*                               objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB,                            */
/*                               errMSG,                                                                    */
/*                               yes).                                                                      */
/*                 if marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB                          */
/*                 then                                                                                     */
/*                 AddUtdErr(idb-num,                                                                       */
/*                           idoc-id,                                                                       */
/*                           if available bf_utd-marking-lines                                              */
/*                           then buffer bf_utd-marking-lines:handle                                        */
/*                           else buffer marking:handle,                                                    */
/*                           "CheckMOTP",                                                                   */
/*                           "MotpMarkErr",                                                                 */
/*                           (marking.mark + {&delim-par} + errMSG)).                                       */
/*              end .                                                                                       */
/*           end .                                                                                          */
/*        end .                                                                                             */
/*        else*/
        if marking.unit-ext = "LEVEL1"
        or marking.unit-ext = "GROUP"
        then do :
           if cisGdsCode > 0
           then do :
              v-must-be-childs = 10 .
              if v-mark-type = "tabak" 
              then do:
                find first bf_bar-code no-lock where bf_bar-code.gds-code = cisGdsCode
                                                 and bf_bar-code.unit-cli = "бл"
                                                 and bf_bar-code.stts_ = 0
                no-error .
                if available bf_bar-code
                then do :
                  v-must-be-childs = bf_bar-code.cli-base-rate .
                end .
                else do :
                  errMSG = "Для товара с кодом " + string(cisGdsCode) + " не найден код с ед. изм. 'бл'" .
                  v-err-childs = true .
                end .
              end.
              else do:
                  v-must-be-childs = getQntyCodeByGtin(marking.gds-ext-id).     
                  if v-must-be-childs = ?
                  then do:
                    errMSG = "Для товара с кодом " + string(cisGdsCode) + " не найден коэф. ед. изм. по GTIN" .
                    v-err-childs = true .
                  end.      
              end.
              if not v-err-childs
              then do :
                if v-mark-type = "tabak"
                or v-mark-type = "stiki"
                then do :
                  if vQnty <> v-must-be-childs and GrayZoneQnty <> 100
                  then do:
                    if (v-must-be-childs - vQnty) <= GrayZoneQnty
                    then v-gray-zone = true .
                    else v-err-childs = true .
                  end .
                  if v-gray-zone
                  then do :
                     MarkChangeSts(marking.mark, 
                                   objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB, 
                                   "", 
                                   no).                      
                  end .
                end .
                else do :
                  if vQnty <> v-must-be-childs then v-err-childs = true .
                end .
                if v-err-childs
                then do :
                  errMSG = "В блоке " + string(vQnty) + " пачек." .
                end .
              end .
              if v-err-childs
              then do :                                  
                 MarkChangeSts(marking.mark, 
                               objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB, 
                               errMSG, 
                               yes).
                 if marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
                 then              
                 AddUtdErr(idb-num,
                           idoc-id,
                           if available bf_utd-marking-lines 
                           then buffer bf_utd-marking-lines:handle
                           else buffer marking:handle,
                           "CheckMOTP",
                           "MotpMarkErr",
                           (marking.mark + {&delim-par} + errMSG)).
              end .
           end .
        end .
        else do :
           if vAllQnty <> vQnty and GrayZoneQnty <> 100
           then do:              
              if vAllQnty - vQnty <= GrayZoneQnty
              then do :
                 MarkChangeSts(marking.mark, 
                               objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB, 
                               "", 
                               no).                     
              end .
              else do :
                errMSG = "В блоке " + string(vQnty) + " пачек." .
                MarkChangeSts(marking.mark, 
                               objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB, 
                               errMSG, 
                               yes).                
                if marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
                then
                AddUtdErr(idb-num,
                          idoc-id,
                          if available bf_utd-marking-lines 
                          then buffer bf_utd-marking-lines:handle
                          else buffer marking:handle,
                          "CheckMOTP",
                          "MotpMarkErr",
                          (marking.mark + {&delim-par} + errMSG)).
              end .
           end.
        end.
     end.
     else if available marking 
     then do:
        if marking.gds-code > 0
        then do :
           cisGdsCode = marking.gds-code . 
        end .
        else do :
           cisGdsCode = getGdsCodeByGtin(marking.gds-ext-id) .
        end .
        /* если товар с переменным весом, то у марки должен быть вес */
        if cisGdsCode > 0 and 
           WeighedProd(cisGdsCode) and 
           MarkWeight(marking.mark) = 0 then do:
            find first bf_utd-marking-lines where bf_utd-marking-lines.db-num eq idb-num
                                              and bf_utd-marking-lines.doc-id eq idoc-id
                                              and bf_utd-marking-lines.mark   eq marking.mark
            no-lock no-error.
            errMSG = "Марка не содержит информации о весе товара." .
            MarkChangeSts(marking.mark, 
                           objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB, 
                           errMSG, 
                           yes).                
            if marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
               and available bf_utd-marking-lines
            then             
                AddUtdErr(idb-num,
                          idoc-id,
                          if available bf_utd-marking-lines 
                          then buffer bf_utd-marking-lines:handle
                          else buffer marking:handle,
                          "LoadUtd",
                          "NoWeightMark",
                          (marking.mark + {&delim-par} + errMSG)).                                      
        end.    
     end.    
  end.
  
  method public void MarkChangeSts(imark as char, ists as int, ierrMSG as char, ichld as log):     
     define buffer buf_marking for ub.marking.
     define buffer chld_marking for ub.marking.
     
     do transaction
     on error undo, return:
         find first buf_marking where buf_marking.mark eq imark
         exclusive-lock no-error no-wait.
         if available buf_marking and
            buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
         then do:             
            buf_marking.sts = ists.
            if ierrMSG > "" then  
               buf_marking.comment = ierrMSG.  
            if ichld then                
            for each chld_marking exclusive-lock where 
                     chld_marking.mark-parent = buf_marking.mark:
                chld_marking.sts = ists.         
            end.               
         end.                        
     end.    
  end method.
  
  method private void out2log (iDbNum as integer, iDocId as integer, imark as char, iLevel as int):
    /* Для отладки: пишет в файл статусы марок после обработки */
    define buffer bf_utd-marking-lines for ub.utd-marking-lines.
    define buffer bf_marking for ub.marking.

    if not isOpenProt then
    do:
      output stream myProt to c:\wrk\impedi-doc.log.
      isOpenProt = yes.
    end.
    else
      output stream myProt to c:\wrk\impedi-doc.log append.
    
    for first bf_utd-marking-lines no-lock where 
              bf_utd-marking-lines.db-num = iDbNum
          and bf_utd-marking-lines.doc-id = iDocId
          and bf_utd-marking-lines.mark   = imark,
        first bf_marking no-lock where 
              bf_marking.mark = imark
    :
      put stream myProt unformatted
        fill("  ", iLevel)
        bf_utd-marking-lines.gds-code " "
        bf_utd-marking-lines.doc-level " "
        bf_marking.mark " "
        objSrv:Env:Marking:Sts:Mark:GetLabel(bf_marking.sts) " "
        objSrv:Env:Marking:Sts:Mark:GetLabel(bf_utd-marking-lines.sts)
        skip
      .
    end.
    output stream myProt close.

    for each bf_marking no-lock where
             bf_marking.mark-parent eq iMark,
        first bf_utd-marking-lines no-lock where 
              bf_utd-marking-lines.db-num = iDbNum
          and bf_utd-marking-lines.doc-id = iDocId
          and bf_utd-marking-lines.mark = bf_marking.mark
    :
      out2log(iDbNum, iDocId, bf_marking.mark, iLevel + 1).
    end.
  end method.

end class.

     
